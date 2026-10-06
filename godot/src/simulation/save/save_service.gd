class_name SaveService
extends RefCounted

const CURRENT_VERSION := 2

func save_to_path(state: SimulationState, path: String) -> Error:
    var payload := state.to_dict()
    payload["save_version"] = CURRENT_VERSION

    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        return FileAccess.get_open_error()

    # JSON decimal parsing can shift a float by one ULP even with full_precision.
    # Version 2 stores float64 bytes losslessly; runtime state stays unchanged.
    file.store_string(JSON.stringify(_encode_floats(payload), "", true, true))
    file.close()
    return OK

func load_from_path(path: String) -> SimulationState:
    if not FileAccess.file_exists(path):
        return null

    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return null

    var raw := file.get_as_text()
    file.close()

    var parsed = JSON.parse_string(raw)
    if not (parsed is Dictionary):
        return null

    var data: Dictionary = parsed
    var version := int(data.get("save_version", 0))
    if version < 0:
        push_error("SaveService: invalid negative save version %d." % version)
        return null
    if version > CURRENT_VERSION:
        push_error("SaveService: save version %d is newer than supported %d." % [version, CURRENT_VERSION])
        return null

    if version == 2:
        data = _decode_floats(data)

    data = _migrate(data, version)
    if data.is_empty():
        return null
    if not _is_payload_shape_valid(data):
        push_error("SaveService: malformed save payload for version %d." % CURRENT_VERSION)
        return null

    var state := SimulationState.from_dict(data)
    # P3.7A saves created before the canonical warehouse existed still contain
    # forge_materials / technique_materials. Migrate them exactly once on load.
    if state != null and state.p3_7_buildings_enabled:
        WarehouseSystem.new().initialize(state)
        var workforce := WorkforceSystem.new()
        var disciple_ids: Array = state.disciples.keys()
        disciple_ids.sort()
        for raw_id in disciple_ids:
            workforce.ensure_p3_7_disciple_profile(state, state.disciples[raw_id])
        var candidate_ids: Array = state.recruitment_candidates.keys()
        candidate_ids.sort()
        for raw_id in candidate_ids:
            workforce.ensure_p3_7_candidate_profile(state, state.recruitment_candidates[raw_id])
    return state

func _migrate(data: Dictionary, version: int) -> Dictionary:
    var current := version
    var migrated := data.duplicate(true)

    while current < CURRENT_VERSION:
        match current:
            0:
                migrated["save_version"] = 1
                current = 1
            1:
                migrated["save_version"] = 2
                current = 2
            _:
                push_error("SaveService: unknown migration path from version %d." % current)
                return {}

    return migrated

func _is_payload_shape_valid(data: Dictionary) -> bool:
    if int(data.get("save_version", 0)) != CURRENT_VERSION:
        return false

    for key in ["tick", "seed", "rng_state", "initial_total_money", "sect", "disciples", "regions"]:
        if not data.has(key):
            return false

    if not (data.get("sect") is Dictionary):
        return false
    if not (data.get("disciples") is Array):
        return false
    if not (data.get("regions") is Array):
        return false

    return true

# This tag is reserved by the version-2 wire format, never exposed to state/UI.
func _encode_floats(value: Variant) -> Variant:
    if value is float:
        var bytes := PackedByteArray()
        bytes.resize(8)
        bytes.encode_double(0, value)
        return {"__float64": bytes.hex_encode()}
    if value is Dictionary:
        var result: Dictionary = {}
        for key in value:
            result[key] = _encode_floats(value[key])
        return result
    if value is Array:
        var result: Array = []
        for item in value:
            result.append(_encode_floats(item))
        return result
    return value

func _decode_floats(value: Variant) -> Variant:
    if value is Dictionary:
        if value.size() == 1 and value.has("__float64"):
            var bytes := str(value["__float64"]).hex_decode()
            if bytes.size() == 8:
                return bytes.decode_double(0)
        var result: Dictionary = {}
        for key in value:
            result[key] = _decode_floats(value[key])
        return result
    if value is Array:
        var result: Array = []
        for item in value:
            result.append(_decode_floats(item))
        return result
    return value