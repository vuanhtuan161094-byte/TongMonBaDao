extends SceneTree

# AUX-01 isolated diagnostic for owner.save_to_path -> error=FAILED (1).
# No production SaveService/RuntimeOwner mutations. All artifacts use user://.
# Records which read-path phase first rejects the staged clock-owner state.
const SAVE_PATH := "user://pve_clock_owner_roundtrip_diagnostic.json"
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

func _new_owner() -> SimulationRuntimeOwnerV2:
    var state := P37Factory.create_state(77221)
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
    if not bool(owner.attach(state,2000).get("ok",false)):
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
    var file := FileAccess.open(SAVE_PATH+".manual",FileAccess.WRITE)
    if file == null:
        return {"ok":false,"reason":"manual_file_write_failed"}
    file.store_string(text_payload)
    file.flush()
    var write_error := file.get_error()
    file.close()
    var wire = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH+".manual"))
    var wire_valid := wire is Dictionary
    var round_trip: SimulationState = null
    if wire_valid:
        var unpacked: Dictionary = service._decode_floats(wire)
        if int(unpacked.get("save_version",-1)) == SaveService.CARE_VERSION:
            unpacked["save_version"] = SaveService.CURRENT_VERSION
        round_trip = SimulationState.from_dict(unpacked)
    var load_exact := service._load_exact(SAVE_PATH+".manual")
    var save_error := service.save_to_path(state,SAVE_PATH)
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
        "primary_exists":FileAccess.file_exists(SAVE_PATH)
    }
    print("AUX01 CLOCK SAVE DIAG: "+JSON.stringify(result))
    DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH+".manual"))
    return result

func _run() -> void:
    for suffix in ["",".tmp",".bak",".manual"]:
        var p := SAVE_PATH+suffix
        if FileAccess.file_exists(p):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(p))
    var owner := _new_owner()
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
    print("AUX01 CLOCK SAVE DIAGNOSTIC COMPLETE checks=%d first=%s second=%s root_cause=NOT_ASSUMED" % [
        checks,JSON.stringify(one),JSON.stringify(two)])
    # This script characterizes the save round-trip; a failed save is not a
    # PASS. Exit 2 so CI and Codex cannot accidentally certify the defect.
    if int(two.get("save_error",FAILED)) != OK:
        quit(2)
    else:
        quit(0)
