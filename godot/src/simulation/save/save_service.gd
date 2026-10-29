class_name SaveService
extends RefCounted

const CURRENT_VERSION := 3
const LEGACY_CARE_VERSION := 3
const CARE_VERSION := 4

func save_to_path(state: SimulationState, path: String) -> Error:
    if state == null or path.is_empty():
        return ERR_INVALID_PARAMETER
    var payload := state.to_dict()
    var care := _has_care_payload(payload)
    payload["save_version"] = CARE_VERSION if care else CURRENT_VERSION
    if care: payload["b3_care_version"] = B3MedicalAutoplayV1.VERSION
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
    if version > CARE_VERSION:
        push_error("SaveService: save version %d is newer than supported %d." % [version, CARE_VERSION])
        return null

    if version >= 2:
        data = _decode_floats(data)
    var care := _has_care_payload(data)
    var care_tag_present := data.has("b3_care_version")
    var care_envelope_valid := false
    if version == CARE_VERSION:
        care_envelope_valid = care and care_tag_present and int(data.get("b3_care_version",0)) == B3MedicalAutoplayV1.VERSION
    elif version == LEGACY_CARE_VERSION and care:
        care_envelope_valid = care_tag_present and int(data.get("b3_care_version",0)) == B3MedicalAutoplayV1.VERSION
    else:
        care_envelope_valid = not care and not care_tag_present
    if not care_envelope_valid:
        push_error("SaveService: CARE capability mismatch; refusing downgraded or incomplete save.")
        return null
    if version == CARE_VERSION:
        data["save_version"] = CURRENT_VERSION
    data = _migrate(data, mini(version,CURRENT_VERSION))
    if data.is_empty():
        return null
    if not _is_payload_shape_valid(data):
        push_error("SaveService: malformed save payload for version %d." % CURRENT_VERSION)
        return null

    var state := SimulationState.from_dict(data)
    # P3.7A saves created before the canonical warehouse existed still contain
    # forge_materials / technique_materials. Migrate them exactly once on load.
    if state != null and state.p3_7_buildings_enabled:
        # D7 migration is idempotent and requires persisted six-stat birth
        # provenance. Refuse incomplete provenance instead of inventing it.
        var d7_upgraded_ids: Array = []
        for raw_id in state.disciples:
            var existing: DiscipleState = state.disciples[raw_id]
            if existing.foundation_model_version == FoundationSystem.MODEL_OPEN_POINTS:
                d7_upgraded_ids.append(existing.id)
        if not FoundationSystem.new().enable_d7(state):
            return null
        for disciple_id in d7_upgraded_ids:
            var upgraded: DiscipleState = state.disciples.get(disciple_id)
            if upgraded != null and DiscipleRealmProgressV2.progression_ready(upgraded):
                var hp_migration := DiscipleRealmProgressV2.sync_live_hp(upgraded)
                if not bool(hp_migration.get("ok",false)):
                    return null
        state.sect.guidance_recruitment_enabled = true
        BuildingSystem.new().initialize(state)
        if not WarehouseSystem.new().initialize(state):
            # Keep the old save intact; a failed migration is not a new game.
            return null
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

# Detect features that an older reader would silently drop or normalize.
func _has_care_payload(data: Dictionary) -> bool:
    for row in data.get("disciples",[]):
        if row is Dictionary and row.has("b3_pill_state"): return true
    var sect = data.get("sect",{})
    if sect is Dictionary:
        var world = sect.get("b3_hunt",{})
        if world is Dictionary and world.has("care"): return true
        var stock = sect.get("warehouse_resources",{})
        if stock is Dictionary and stock.has("tu_khi_dan"): return true
    for row in data.get("buildings",[]):
        if not (row is Dictionary): continue
        var production = row.get("production_state",{})
        if not (production is Dictionary): continue
        if production.has("b3_command") or str(production.get("recipe_id","")) == "tu_khi_dan": return true
        for job in production.get("jobs",[]):
            if job is Dictionary and (str(job.get("recipe_id","")) == "tu_khi_dan" or str(job.get("output_resource_id","")) == "tu_khi_dan"): return true
    return false

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
            2:
                migrated["save_version"] = 3
                current = 3
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
