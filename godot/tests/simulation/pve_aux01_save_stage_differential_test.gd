extends SceneTree

# PVE AUX-01: offline-safe differential SaveService diagnosis.
# Every written path belongs to this QA suite under user://. It never touches
# the owner's canonical save, Combat V2 or the runtime clock implementation.
#
# This script exits 2 when the original cross-seed owner save still fails.
# An exit 2 is an INVESTIGATED FAILURE, never a false PASS.
const QA_ROOT := "user://qa_pve_save_forensics_20261027"
var checked := 0
var case_rows: Array[Dictionary] = []
var detected_defect := false

func _init() -> void:
    call_deferred("_run")

func _expect(ok: bool, why: String) -> bool:
    checked += 1
    if not ok:
        push_error("PVE SAVE FORENSICS: " + why)
        quit(1)
        return false
    return true

func _path(label: String) -> String:
    return QA_ROOT + "/" + label + ".json"

func _cleanup_one(path: String) -> void:
    for suffix in ["", ".tmp", ".bak"]:
        var target: String = path + suffix
        if FileAccess.file_exists(target):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(target))

func _owner(seed: int, wall: int, zero_aptitude: bool = true) -> SimulationRuntimeOwnerV2:
    # Reconstruct the exact AUX-01 DV2-03 seed, candidate and training policy.
    var state := P37Factory.create_state(seed)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.disciple_capacity = maxi(
        state.sect.disciple_capacity, state.disciples.size() + 1)
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state, DiscipleGeneratorV2.SOURCE_ORDINARY, 913)
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state, candidate.id)
    if not bool(accepted.get("ok", false)):
        return null
    var disciple: DiscipleState = state.disciples[candidate.id]
    if zero_aptitude:
        # Historical DV2-03 test directly edits an already-authored D7 stat.
        # This is a suspected fixture integrity issue, not a production fix.
        disciple.aptitude = 0.0
    disciple.current_action = &"HOLD"
    disciple.v2_realm_progress["training_policy"] = "manual"
    state.sect.workforce_enabled = false
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    var owner := SimulationRuntimeOwnerV2.new()
    if not bool(owner.attach(state, wall).get("ok", false)):
        return null
    return owner

func _foundation_error_count(state: SimulationState) -> int:
    var count := 0
    var foundation := FoundationSystem.new()
    for entry in state.disciples.values():
        var disciple: DiscipleState = entry
        if disciple.foundation_model_version >= FoundationSystem.MODEL_OPEN_POINTS:
            count += foundation.validate_disciple(disciple).size()
    return count

func _probe_wire(state: SimulationState, label: String) -> Dictionary:
    # Mirror serialization into an isolated read-only-for-game QA path. A
    # successful .wire round-trip narrows the production failure to file
    # publication/rotation rather than the newly encoded state contents.
    var service := SaveService.new()
    var payload: Dictionary = state.to_dict()
    var care: bool = service._has_care_payload(payload)
    payload["save_version"] = SaveService.CARE_VERSION if care else SaveService.CURRENT_VERSION
    if care:
        payload["b3_care_version"] = B3MedicalAutoplayV1.VERSION

    var wire_path := _path(label + "_wire")
    _cleanup_one(wire_path)
    var file := FileAccess.open(wire_path, FileAccess.WRITE)
    if file == null:
        return {"stage_open_error": FileAccess.get_open_error(), "wire_read": false}
    file.store_string(JSON.stringify(service._encode_floats(payload), "", true, true))
    file.flush()
    var stage_write_error: int = file.get_error()
    file.close()

    var parsed = JSON.parse_string(FileAccess.get_file_as_string(wire_path))
    var wire_read: bool = parsed is Dictionary
    var envelope_ok := false
    var shape_ok := false
    var from_dict_ok := false
    var care_check := ""
    var exact_read := false
    if wire_read:
        var data: Dictionary = service._decode_floats(parsed)
        var version: int = int(data.get("save_version", -1))
        var detected_care: bool = service._has_care_payload(data)
        if version == SaveService.CARE_VERSION:
            envelope_ok = detected_care and data.has("b3_care_version") \
                and int(data.get("b3_care_version", 0)) == B3MedicalAutoplayV1.VERSION
        elif version == SaveService.CURRENT_VERSION:
            envelope_ok = not detected_care and not data.has("b3_care_version")
        if version == SaveService.CARE_VERSION:
            data["save_version"] = SaveService.CURRENT_VERSION
        data = service._migrate(data, mini(version, SaveService.CURRENT_VERSION))
        shape_ok = service._is_payload_shape_valid(data)
        if shape_ok:
            var decoded_state: SimulationState = SimulationState.from_dict(data)
            from_dict_ok = decoded_state != null
            if from_dict_ok:
                care_check = B3MedicalAutoplayV1.validate(decoded_state)
        exact_read = service._load_exact(wire_path) != null
    var result := {
        "stage_write_error": stage_write_error,
        "wire_read": wire_read, "care": care,
        "envelope_ok": envelope_ok, "shape_ok": shape_ok,
        "from_dict_ok": from_dict_ok, "care_check": care_check,
        "exact_read": exact_read,
        "source_invariant_errors": state.validate_invariants().size(),
        "foundation_errors": _foundation_error_count(state)
    }
    _cleanup_one(wire_path)
    return result

func _case(label: String, owner: SimulationRuntimeOwnerV2, now_unix: int,
        preload: SimulationRuntimeOwnerV2 = null, preload_time: int = 0,
        zero_aptitude: bool = true) -> Dictionary:
    var path := _path(label)
    _cleanup_one(path)
    var old_save := -1
    if preload != null:
        var pre_progress := preload.update_to(preload_time)
        if not bool(pre_progress.get("ok", false)):
            return {"label": label, "preload_progress": false}
        old_save = SaveService.new().save_to_path(preload.state, path)
        if old_save != OK:
            return {"label": label, "preload_error": old_save}
    var sha_before := FileAccess.get_sha256(path) if FileAccess.file_exists(path) else ""
    # Advance a separate identical fixture for wire diagnosis. The actual
    # owner below MUST do the 120-second catch-up inside save_to_path, as in
    # the original dv2_03_runtime_clock_test (steps_run must be 2).
    var probe_owner := _owner(77221, 2000, zero_aptitude)
    if probe_owner == null:
        return {"label": label, "probe_owner_missing": true}
    var probe_advance := probe_owner.update_to(now_unix)
    if not bool(probe_advance.get("ok", false)):
        return {"label": label, "probe_update": probe_advance}
    var probe := _probe_wire(probe_owner.state, label)
    var result := owner.save_to_path(path, now_unix)
    var service := SaveService.new()
    var primary: SimulationState = service._load_exact(path)
    var recovered: SimulationState = service.load_from_path(path)
    var sha_after := FileAccess.get_sha256(path) if FileAccess.file_exists(path) else ""
    var row := {
        "label": label,
        "preload_error": old_save,
        "owner_tick": owner.state.tick,
        "wall": owner.state.runtime_last_wall_unix,
        "remainder": owner.state.runtime_unconsumed_wall_seconds,
        "owner_ok": bool(result.get("ok", false)),
        "save_error": int(result.get("error", -1)),
        "owner_steps": int(result.get("steps_run", -1)),
        "primary_exists": FileAccess.file_exists(path),
        "backup_exists": FileAccess.file_exists(path + ".bak"),
        "primary_exact_loadable": primary != null,
        "recovery_loadable": recovered != null,
        "saved_identity_equal": primary != null and primary.seed == owner.state.seed
            and primary.tick == owner.state.tick
            and primary.runtime_last_wall_unix == now_unix,
        "clock_exact": owner.state.tick == 2
            and owner.state.runtime_last_wall_unix == now_unix
            and absf(owner.state.runtime_unconsumed_wall_seconds) < 0.000001
            and int(result.get("steps_run", -1)) == 2,
        "primary_unchanged_on_failure": sha_before == sha_after,
        "wire_probe": probe
    }
    _cleanup_one(path)
    print("PVE SAVE FORENSICS CASE: " + JSON.stringify(row))
    return row

func _invalid_stage() -> Dictionary:
    var path := _path("invalid_payload_guard")
    _cleanup_one(path)
    var owner := _owner(77221, 2000, false)
    if owner == null:
        return {"fixture": false}
    var service := SaveService.new()
    var initial_error: int = service.save_to_path(owner.state, path)
    if initial_error != OK:
        return {"baseline_error": initial_error}
    var hash_before := FileAccess.get_sha256(path)
    # Deliberately invalid CARE envelope in this isolated QA instance.
    owner.state.sect.b3_hunt = {"care": {"version": -1}}
    var write_error: int = service.save_to_path(owner.state, path)
    var persisted: SimulationState = service.load_from_path(path)
    var row := {
        "baseline_error": initial_error,
        "invalid_save_error": write_error,
        "preserved_primary": FileAccess.file_exists(path)
            and FileAccess.get_sha256(path) == hash_before,
        "existing_save_loadable": persisted != null
    }
    _cleanup_one(path)
    return row

func _missing_directory_write() -> Dictionary:
    # The nested directory is intentionally never created; this exercises the
    # actual file-open failure, independently of stage read validation.
    var path := QA_ROOT + "/missing_parent/file.json"
    var owner := _owner(77221, 2000, false)
    if owner == null:
        return {"fixture": false}
    return {"write_error": SaveService.new().save_to_path(owner.state, path),
        "primary_created": FileAccess.file_exists(path)}


func _schema_migration_probe() -> Dictionary:
    # Probe the public legacy reader in an isolated file, without altering
    # any game save. Versions 0-3 are supported; V4 requires a real CARE tag.
    # P0 has no modern D7/V2/Care capabilities, so historical version
    # headers do not misrepresent a modern state as a real legacy save.
    var legacy_state := P0Factory.create_state(556677)
    var service := SaveService.new()
    var source: Dictionary = legacy_state.to_dict()
    var output: Dictionary = {}
    for version in [0, 1, 2, 3, 4, 99]:
        var path := _path("migration_v%02d" % int(version))
        _cleanup_one(path)
        var payload := source.duplicate(true)
        payload["save_version"] = int(version)
        payload.erase("b3_care_version")
        var file := FileAccess.open(path, FileAccess.WRITE)
        if file == null:
            output[str(version)] = {"open_error": FileAccess.get_open_error()}
            continue
        # Pre-v2 files used ordinary JSON floats; v2+ uses bit-exact wrappers.
        var serialized = payload if int(version) < 2 else service._encode_floats(payload)
        file.store_string(JSON.stringify(serialized, "", true, true))
        file.close()
        output[str(version)] = {
            "exact_read": service._load_exact(path) != null,
            "expected": int(version) <= SaveService.CURRENT_VERSION
        }
        _cleanup_one(path)
    return output

func _rename_probe() -> Dictionary:
    # Test real OS rename of two harmless sentinel files in the same user://
    # directory. This cannot prove a later SaveService file rename succeeds,
    # but separates a general directory permission problem from data failure.
    var primary := _path("rename_sentinel")
    var backup := primary + ".bak"
    var staged := primary + ".tmp"
    _cleanup_one(primary)
    for entry in [{"path":primary, "text":"original"},
                  {"path":staged, "text":"staged"}]:
        var file := FileAccess.open(str(entry["path"]), FileAccess.WRITE)
        if file == null:
            return {"open_error": FileAccess.get_open_error()}
        file.store_string(str(entry["text"]))
        file.close()
    var first := DirAccess.rename_absolute(
        ProjectSettings.globalize_path(primary),
        ProjectSettings.globalize_path(backup))
    var second := -1
    if first == OK:
        second = DirAccess.rename_absolute(
            ProjectSettings.globalize_path(staged),
            ProjectSettings.globalize_path(primary))
    var correct := first == OK and second == OK \
        and FileAccess.get_file_as_string(primary) == "staged" \
        and FileAccess.get_file_as_string(backup) == "original"
    var result := {"rotate_error":first, "publish_error":second, "contents_ok":correct}
    _cleanup_one(primary)
    return result

func _run() -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(QA_ROOT))
    var cases := ["fresh", "same_seed_rotation", "cross_seed_rotation"]
    for name in cases:
        var own := _owner(77221, 2000)
        if not _expect(own != null, "owner fixture " + name):
            return
        var preload: SimulationRuntimeOwnerV2 = null
        var pre_time := 0
        if name == "same_seed_rotation":
            # Seed 77221 at t2060 becomes the old primary.
            preload = _owner(77221, 2000)
            pre_time = 2060
        elif name == "cross_seed_rotation":
            # Matches dv2_03_runtime_clock_test: seed 44421 saved at t1060,
            # then seed 77221 owner replaces it at t2120.
            preload = _owner(44421, 1000)
            pre_time = 1060
        var row := _case(name, own, 2120, preload, pre_time)
        case_rows.append(row)
        if not bool(row.get("owner_ok", false))                 or not bool(row.get("clock_exact", false))                 or not bool(row.get("saved_identity_equal", false)):
            detected_defect = true
    # A/B control: the production-compatible D7 candidate keeps its authored
    # aptitude and quality; unlike the historical test fixture, no field is
    # modified behind the Foundation authority.
    var control_owner := _owner(77221, 2000, false)
    if not _expect(control_owner != null, "natural-aptitude control fixture failed"):
        return
    var control_row := _case("control_natural_aptitude", control_owner, 2120,
        null, 0, false)
    case_rows.append(control_row)
    var control_cross_owner := _owner(77221, 2000, false)
    var control_cross_previous := _owner(44421, 1000, false)
    if not _expect(control_cross_owner != null and control_cross_previous != null,
        "cross-seed natural-aptitude control fixture failed"):
        return
    var control_cross_row := _case("control_cross_seed", control_cross_owner,
        2120, control_cross_previous, 1060, false)
    case_rows.append(control_cross_row)
    for control in [control_row, control_cross_row]:
        if not (bool(control.get("owner_ok", false))
                and bool(control.get("clock_exact", false))
                and bool(control.get("saved_identity_equal", false))):
            detected_defect = true
    var negative := _invalid_stage()
    var missing_dir := _missing_directory_write()
    var schema := _schema_migration_probe()
    var rename_result := _rename_probe()
    print("PVE SAVE FORENSICS NEGATIVE: " + JSON.stringify({
        "invalid_stage": negative, "missing_dir": missing_dir,
        "schema_migrations": schema, "rename_probe": rename_result}))
    if not _expect(int(negative.get("baseline_error", -1)) == OK
        and int(negative.get("invalid_save_error", OK)) != OK
        and bool(negative.get("preserved_primary", false))
        and bool(negative.get("existing_save_loadable", false)),
        "invalid saved state overwrote the last known good primary"):
        return
    if not _expect(int(missing_dir.get("write_error", OK)) != OK
        and not bool(missing_dir.get("primary_created", true)),
        "missing-directory file-open negative fixture was not rejected"):
        return
    if not _expect(bool(rename_result.get("contents_ok", false)),
        "QA directory could not atomically publish harmless sentinel files"):
        return
    for supported in [0, 1, 2, 3]:
        var status: Dictionary = schema.get(str(supported), {})
        if not _expect(bool(status.get("exact_read", false)),
            "supported migration v%d failed isolated state roundtrip" % supported):
            return
    for unsupported in [4, 99]:
        var status: Dictionary = schema.get(str(unsupported), {})
        if not _expect(not bool(status.get("exact_read", true)),
            "unqualified/future schema v%d was not rejected" % unsupported):
            return
    print("PVE SAVE FORENSICS COMPLETE cases=" + str(case_rows.size())
        + " defect=" + str(detected_defect) + " checks=" + str(checked)
        + " engine=" + str(Engine.get_version_info().get("string", "unknown")))
    quit(2 if detected_defect else 0)
