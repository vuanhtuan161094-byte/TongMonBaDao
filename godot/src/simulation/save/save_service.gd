class_name SaveService
extends RefCounted

const CURRENT_VERSION := 2

func save_to_path(state: SimulationState, path: String) -> Error:
    if state == null or path.is_empty():
        return ERR_INVALID_PARAMETER
    var payload := state.to_dict()
    payload["save_version"] = CURRENT_VERSION
    var staged := path + ".tmp"
    var backup := path + ".bak"
    var content := JSON.stringify(_encode_floats(payload), "", true, true)

    # Stage and verify a complete save before touching the only good copy.
    var file := FileAccess.open(staged, FileAccess.WRITE)
    if file == null:
        return FileAccess.get_open_error()
    file.store_string(content)
    file.flush()
    var write_error := file.get_error()
    file.close()
    if write_error != OK or _load_exact(staged) == null:
        _remove_if_present(staged)
        return FAILED

    var had_primary := FileAccess.file_exists(path)
    var valid_primary := had_primary and _load_exact(path) != null
    if had_primary and not valid_primary:
        # Do not discard a broken primary if there is no valid recovery copy.
        if _load_exact(backup) == null:
            _remove_if_present(staged)
            return ERR_FILE_CORRUPT
        var remove_error := _remove_if_present(path)
        if remove_error != OK:
            _remove_if_present(staged)
            return remove_error
    elif valid_primary:
        # Old primary becomes the last-known-good recovery copy.
        var clear_error := _remove_if_present(backup)
        if clear_error != OK:
            _remove_if_present(staged)
            return clear_error
        var rotate_error := DirAccess.rename_absolute(
            ProjectSettings.globalize_path(path),
            ProjectSettings.globalize_path(backup)
        )
        if rotate_error != OK:
            _remove_if_present(staged)
            return rotate_error

    var install_error := DirAccess.rename_absolute(
        ProjectSettings.globalize_path(staged),
        ProjectSettings.globalize_path(path)
    )
    if install_error != OK:
        # Restore the previously valid primary if the publish failed.
        if valid_primary and not FileAccess.file_exists(path):
            DirAccess.rename_absolute(
                ProjectSettings.globalize_path(backup),
                ProjectSettings.globalize_path(path)
            )
        return install_error
    return OK

func _remove_if_present(path: String) -> Error:
    if not FileAccess.file_exists(path):
        return OK
    return DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func load_from_path(path: String) -> SimulationState:
    var current := _load_exact(path)
    if current != null:
        return current
    return _load_exact(path + ".bak")

func _load_exact(path: String) -> SimulationState:
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
        # P3.7C1 migration is idempotent: old P3.7 saves are upgraded to the
        # open-point lục-duy model and receive the Dẫn Tiên building/runtime.
        FoundationSystem.new().enable_open_points(state)
        state.sect.guidance_recruitment_enabled = true
        BuildingSystem.new().initialize(state)
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