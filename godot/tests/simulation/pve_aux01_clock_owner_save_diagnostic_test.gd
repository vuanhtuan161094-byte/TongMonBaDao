extends SceneTree

# AUX-01 isolated diagnostic for owner.save_to_path -> error=FAILED (1).
# No production SaveService/RuntimeOwner mutations. All artifacts use user://.
# Records which read-path phase first rejects the staged clock-owner state.
const SAVE_PATH := "user://pve_clock_owner_roundtrip_diagnostic.json"
const PROBE_PATH := "user://pve_clock_owner_stage_probe.json"
var checks := 0

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool,reason: String) -> bool:
    checks += 1
    if not ok:
        push_error("AUX01 CLOCK SAVE DIAGNOSTIC BLOCKED: "+reason)
        quit(1)
        return false
    return true

func _new_owner(seed: int,wall: int) -> SimulationRuntimeOwnerV2:
    var state := P37Factory.create_state(seed)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,913)
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    if not bool(accepted.get("ok",false)):
        return null
    var disciple: DiscipleState = state.disciples[candidate.id]
    disciple.aptitude = 0.0
    disciple.current_action = &"HOLD"
    disciple.v2_realm_progress["training_policy"] = "manual"
    state.sect.workforce_enabled = false
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    var owner := SimulationRuntimeOwnerV2.new()
    if not bool(owner.attach(state,wall).get("ok",false)):
        return null
    return owner

func _probe(state: SimulationState,label: String) -> Dictionary:
    var service := SaveService.new()
    var payload: Dictionary = state.to_dict()
    var care := service._has_care_payload(payload)
    payload["save_version"] = SaveService.CARE_VERSION if care else SaveService.CURRENT_VERSION
    if care:
        payload["b3_care_version"] = B3MedicalAutoplayV1.VERSION
    var encoded := service._encode_floats(payload)
    var text_payload := JSON.stringify(encoded,"",true,true)
    var file := FileAccess.open(PROBE_PATH+".manual",FileAccess.WRITE)
    if file == null:
        return {"ok":false,"reason":"manual_file_write_failed"}
    file.store_string(text_payload)
    file.flush()
    var write_error := file.get_error()
    file.close()
    var wire = JSON.parse_string(FileAccess.get_file_as_string(PROBE_PATH+".manual"))
    var wire_valid := wire is Dictionary
    var round_trip: SimulationState = null
    if wire_valid:
        var unpacked: Dictionary = service._decode_floats(wire)
        if int(unpacked.get("save_version",-1)) == SaveService.CARE_VERSION:
            unpacked["save_version"] = SaveService.CURRENT_VERSION
        round_trip = SimulationState.from_dict(unpacked)
    var load_exact := service._load_exact(PROBE_PATH+".manual")
    var save_error := service.save_to_path(state,PROBE_PATH)
    var result := {
        "phase":label,"tick":state.tick,"wall":state.runtime_last_wall_unix,
        "care":care,"shape_valid":service._is_payload_shape_valid(
            {"save_version":SaveService.CURRENT_VERSION,
             "tick":payload.get("tick"),"seed":payload.get("seed"),
             "rng_state":payload.get("rng_state"),"initial_total_money":payload.get("initial_total_money"),
             "sect":payload.get("sect"),"disciples":payload.get("disciples"),"regions":payload.get("regions")}),
        "wire_valid":wire_valid,"direct_from_dict":round_trip != null,
        "load_exact":load_exact != null,"save_error":save_error,
        "invariant_count":state.validate_invariants().size(),
        "primary_exists":FileAccess.file_exists(PROBE_PATH)
    }
    print("AUX01 CLOCK SAVE DIAG: "+JSON.stringify(result))
    DirAccess.remove_absolute(ProjectSettings.globalize_path(PROBE_PATH+".manual"))
    return result

func _run() -> void:
    for path_base in [SAVE_PATH,PROBE_PATH]:
        for suffix in ["",".tmp",".bak",".manual"]:
            var p := path_base+suffix
            if FileAccess.file_exists(p):
                DirAccess.remove_absolute(ProjectSettings.globalize_path(p))
    # Exact original test writes a different 44421 seed fixture to the same
    # SAVE_PATH at t1060 before the 77221 owner attempts its t2120 checkpoint.
    var baseline_owner := _new_owner(44421,1000)
    if not _check(baseline_owner != null,"baseline canonical state failed"):
        return
    var baseline_step := baseline_owner.update_to(1060)
    var baseline_save := SaveService.new().save_to_path(baseline_owner.state,SAVE_PATH)
    if not _check(bool(baseline_step.get("ok",false)) and baseline_save == OK,
        "original seed44421/t1060 baseline save could not be staged"):
        return
    var owner := _new_owner(77221,2000)
    if not _check(owner != null,"canonical owner fixture setup failed"):
        return
    var first := owner.update_to(2060)
    if not _check(bool(first.get("ok",false)) and owner.state.tick == 1,
        "first minute did not advance"):
        return
    var one := _probe(owner.state,"t2060")
    if not _check(bool(one.get("wire_valid",false)),"serialized first minute is not JSON"):
        return
    var next := owner.update_to(2120)
    if not _check(bool(next.get("ok",false)) and owner.state.tick == 2,
        "second minute did not advance"):
        return
    var two := _probe(owner.state,"t2120")
    if not _check(bool(two.get("wire_valid",false)),"serialized second minute is not JSON"):
        return
    # Reproduce the original one-shot save on an independent identical
    # fixture, with the actual first seed still stored under SAVE_PATH.
    var exact_owner := _new_owner(77221,2000)
    if not _check(exact_owner != null,"exact owner fixture setup failed"):
        return
    var exact := exact_owner.save_to_path(SAVE_PATH,2120)
    print("AUX01 CLOCK SAVE DIAGNOSTIC COMPLETE checks=%d first=%s second=%s exact_owner=%s root_cause=NOT_ASSUMED" % [
        checks,JSON.stringify(one),JSON.stringify(two),JSON.stringify(exact)])
    # A failing exact owner save remains red; this is a diagnostic, not a fix.
    if not bool(exact.get("ok",false)):
        quit(2)
    else:
        quit(0)
