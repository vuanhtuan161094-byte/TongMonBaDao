class_name SaveService
extends RefCounted

const CURRENT_VERSION := 4
const LEGACY_CARE_VERSION := 3
const PREVIOUS_CARE_VERSION := 4
const CARE_VERSION := 5
var _async_save_thread: Thread

func save_to_path(state: SimulationState, path: String) -> Error:
    if state == null or path.is_empty():
        return ERR_INVALID_PARAMETER
    if _async_save_thread != null:
        var prior := _finish_async_save_blocking()
        if not bool(prior.get("ok",false)):
            return int(prior.get("error",FAILED))
    var perf_enabled := OS.get_environment("TMB_PVE_PERF_LOG") == "1"
    var perf_total_started_usec := Time.get_ticks_usec() if perf_enabled else 0
    var perf_state_started_usec := Time.get_ticks_usec() if perf_enabled else 0
    var payload := _build_payload(state)
    var perf_state_usec := Time.get_ticks_usec()-perf_state_started_usec if perf_enabled else 0
    return _save_payload_to_path(payload,path,perf_state_usec,perf_total_started_usec,"sync")

func start_save_to_path_async(state: SimulationState, path: String) -> Error:
    if state == null or path.is_empty():
        return ERR_INVALID_PARAMETER
    if _async_save_thread != null:
        return ERR_BUSY
    var perf_enabled := OS.get_environment("TMB_PVE_PERF_LOG") == "1"
    var perf_total_started_usec := Time.get_ticks_usec() if perf_enabled else 0
    var perf_state_started_usec := Time.get_ticks_usec() if perf_enabled else 0
    var payload := _build_payload(state)
    var perf_state_usec := Time.get_ticks_usec()-perf_state_started_usec if perf_enabled else 0
    _async_save_thread = Thread.new()
    var start_error := _async_save_thread.start(Callable(self,"_save_async_worker").bind(
        payload,path,perf_state_usec,perf_total_started_usec
    ))
    if start_error != OK:
        _async_save_thread = null
        return start_error
    return OK

func has_async_save_pending() -> bool:
    return _async_save_thread != null

func finish_async_save() -> Dictionary:
    if _async_save_thread == null:
        return {"ok":true,"pending":false,"error":OK}
    if _async_save_thread.is_alive():
        return {"ok":true,"pending":true,"error":OK}
    var error := int(_async_save_thread.wait_to_finish())
    _async_save_thread = null
    return {"ok":error == OK,"pending":false,"error":error}

func wait_for_async_save(tree: SceneTree) -> Dictionary:
    while _async_save_thread != null and _async_save_thread.is_alive():
        await tree.process_frame
    return finish_async_save()

func _finish_async_save_blocking() -> Dictionary:
    if _async_save_thread == null:
        return {"ok":true,"pending":false,"error":OK}
    var error := int(_async_save_thread.wait_to_finish())
    _async_save_thread = null
    return {"ok":error == OK,"pending":false,"error":error}

func _save_async_worker(payload: Dictionary, path: String,
        state_to_dict_usec: int, total_started_usec: int) -> int:
    _trace_save_stage("async","worker_enter",0)
    return _save_payload_to_path(payload,path,state_to_dict_usec,total_started_usec,"async")

func _build_payload(state: SimulationState) -> Dictionary:
    var payload := state.to_dict()
    var care := _has_care_payload(payload)
    payload["save_version"] = CARE_VERSION if care else CURRENT_VERSION
    if care: payload["b3_care_version"] = B3MedicalAutoplayV1.VERSION
    return payload

func _save_payload_to_path(payload: Dictionary, path: String,
        perf_state_usec: int = 0, perf_total_started_usec: int = 0,
        save_mode: String = "sync") -> Error:
    if path.is_empty():
        return ERR_INVALID_PARAMETER
    var perf_enabled := OS.get_environment("TMB_PVE_PERF_LOG") == "1"
    if perf_enabled and perf_total_started_usec <= 0:
        perf_total_started_usec = Time.get_ticks_usec()
    var perf_encode_started_usec := Time.get_ticks_usec() if perf_enabled else 0
    var staged := path + ".tmp"
    var backup := path + ".bak"
    var encode_meter: Dictionary = {"nodes":0,"started_usec":perf_encode_started_usec,
        "last_report_usec":perf_encode_started_usec} if perf_enabled else {}
    var encoded_payload: Variant = _encode_floats(payload,encode_meter)
    var transform_usec := Time.get_ticks_usec()-perf_encode_started_usec if perf_enabled else 0
    _trace_save_stage(save_mode,"float_transform",transform_usec)
    var perf_json_started_usec := Time.get_ticks_usec() if perf_enabled else 0
    var content := JSON.stringify(encoded_payload, "", true, true)
    if perf_enabled:
        _trace_save_stage(save_mode,"json_stringify",Time.get_ticks_usec()-perf_json_started_usec)
    var perf_encode_usec := Time.get_ticks_usec()-perf_encode_started_usec if perf_enabled else 0
    _trace_save_stage(save_mode,"encode",perf_encode_usec)

    # Stage and verify a complete save before touching the only good copy.
    var perf_write_started_usec := Time.get_ticks_usec() if perf_enabled else 0
    var file := FileAccess.open(staged, FileAccess.WRITE)
    if file == null:
        return FileAccess.get_open_error()
    file.store_string(content)
    file.flush()
    var write_error := file.get_error()
    file.close()
    var perf_write_usec := Time.get_ticks_usec()-perf_write_started_usec if perf_enabled else 0
    _trace_save_stage(save_mode,"write_flush",perf_write_usec)
    var perf_validate_staged_started_usec := Time.get_ticks_usec() if perf_enabled else 0
    if write_error != OK or _load_exact(staged) == null:
        _remove_if_present(staged)
        return FAILED
    var perf_validate_staged_usec := Time.get_ticks_usec()-perf_validate_staged_started_usec if perf_enabled else 0
    _trace_save_stage(save_mode,"staged_validation",perf_validate_staged_usec)

    var perf_validate_primary_started_usec := Time.get_ticks_usec() if perf_enabled else 0
    var had_primary := FileAccess.file_exists(path)
    var valid_primary := had_primary and _load_exact(path) != null
    var perf_validate_primary_usec := Time.get_ticks_usec()-perf_validate_primary_started_usec if perf_enabled else 0
    _trace_save_stage(save_mode,"primary_validation",perf_validate_primary_usec)
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
        var perf_rotate_started_usec := Time.get_ticks_usec() if perf_enabled else 0
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
        if perf_enabled:
            perf_validate_primary_usec += Time.get_ticks_usec()-perf_rotate_started_usec

    var perf_publish_started_usec := Time.get_ticks_usec() if perf_enabled else 0
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
    _trace_save_stage(save_mode,"publish",Time.get_ticks_usec()-perf_publish_started_usec if perf_enabled else 0)
    if perf_enabled:
        print("TMB_SAVE_SERVICE_METRIC " + JSON.stringify({
            "mode":save_mode,
            "state_to_dict_usec":perf_state_usec,
            "encode_usec":perf_encode_usec,
            "write_flush_usec":perf_write_usec,
            "staged_validation_usec":perf_validate_staged_usec,
            "primary_validation_rotate_usec":perf_validate_primary_usec,
            "publish_usec":Time.get_ticks_usec()-perf_publish_started_usec,
            "total_usec":Time.get_ticks_usec()-perf_total_started_usec if perf_total_started_usec > 0 else 0,
            "content_chars":content.length()
        }))
    return OK

func _trace_save_stage(save_mode: String, phase: String, elapsed_usec: int) -> void:
    if OS.get_environment("TMB_PVE_PERF_LOG") != "1":
        return
    print("TMB_SAVE_SERVICE_STAGE mode=%s phase=%s elapsed_usec=%d" % [save_mode,phase,elapsed_usec])

func _remove_if_present(path: String) -> Error:
    if not FileAccess.file_exists(path):
        return OK
    return DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func load_from_path(path: String) -> SimulationState:
    if _async_save_thread != null:
        _finish_async_save_blocking()
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
    elif version == PREVIOUS_CARE_VERSION and care:
        care_envelope_valid = care_tag_present and int(data.get("b3_care_version",0)) == B3MedicalAutoplayV1.VERSION
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
    # DD-07: protect real Hall/Residence ownership before declaring the
    # primary save valid. Invalid saves must fall back to the .bak through
    # load_from_path(), not be quietly reset during live bootstrap.
    if state != null and not state.sect.hall_governance.is_empty():
        var hall_errors := SectHallSystemV1.validate(state)
        if not hall_errors.is_empty():
            push_error("DD-07: invalid saved Hall/Residence: " + "; ".join(PackedStringArray(hall_errors)))
            return null
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
            3:
                # D3 adds optional learning/job fields; state decoders default empty.
                # Legacy P2.3 knowledge and loadouts are preserved without ID remapping.
                migrated["save_version"] = 4
                current = 4
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
func _encode_floats(value: Variant, meter: Dictionary = {}) -> Variant:
    if not meter.is_empty():
        meter["nodes"] = int(meter.get("nodes",0))+1
        var now_usec := Time.get_ticks_usec()
        if now_usec-int(meter.get("last_report_usec",now_usec)) >= 1000000:
            meter["last_report_usec"] = now_usec
            print("TMB_SAVE_ENCODE_PROGRESS nodes=%d elapsed_usec=%d" % [
                int(meter["nodes"]),now_usec-int(meter.get("started_usec",now_usec))])
    if value is float:
        var bytes := PackedByteArray()
        bytes.resize(8)
        bytes.encode_double(0, value)
        return {"__float64": bytes.hex_encode()}
    if value is Dictionary:
        var result: Dictionary = {}
        for key in value:
            result[key] = _encode_floats(value[key],meter)
        return result
    if value is Array:
        var result: Array = []
        for item in value:
            result.append(_encode_floats(item,meter))
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
