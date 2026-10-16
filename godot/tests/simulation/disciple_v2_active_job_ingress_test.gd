extends SceneTree

# Direct backend ingress gates; no fake completion, dummy Warehouse or minted
# work product. Run on official Godot 4.7.2 before calling this PASS.
var workforce := WorkforceSystem.new()
var buildings := BuildingSystem.new()

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, reason: String) -> bool:
    if ok:
        return true
    push_error("DV2 ONE ACTIVE JOB INGRESS FAIL: " + reason)
    quit(1)
    return false

func _recruit(state: SimulationState, ordinal: int) -> DiscipleState:
    state.sect.disciple_capacity = state.disciples.size() + 1
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,ordinal
    )
    if candidate == null:
        return null
    state.recruitment_candidates[candidate.id] = candidate
    if not bool(RecruitmentSystem.new().accept_candidate(state,candidate.id).get("ok",false)):
        return null
    return state.disciples[candidate.id]

func _run() -> void:
    var state := P37Factory.create_state(987700)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    state.sect.spirit_stones = 1000
    buildings.ensure_body_training_facility(state)
    var actor := _recruit(state,987701)
    var other := _recruit(state,987702)
    if not _check(actor != null and other != null
        and DiscipleRealmProgressV2.progression_ready(actor)
        and DiscipleRealmProgressV2.progression_ready(other),
        "failed to recruit two authentic V2 actors"):
        return

    var mine := buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    if not _check(mine != null,"missing canonical Mine"):
        return
    var occupied := buildings.active_worker_ids(state,mine)
    if not _check(occupied.size() == 1
        and workforce.assign_group(state,occupied[0],&""),
        "could not release legacy miner for focused real timer"):
        return
    actor.current_action = &"EVALUATE"
    var assigned := workforce.assign_mine_worker(state,actor.id,mine.id)
    if not _check(bool(assigned.get("ok",false))
        and bool(EconomySystem.new().enable_v1(state).get("ok",false)),
        "cannot establish authentic V2 timed Mine assignment"):
        return
    var started := workforce.perform_work(state,actor,WorkforceSystem.PROF_MINING)
    var timed := buildings.active_resource_timer_for_worker(state,actor.id)
    if not _check(bool(started.get("ok",false))
        and not timed.is_empty(),"Mine did not reserve the real worker"):
        return
    var before := actor.to_dict()
    var stock := state.sect.warehouse_resources.duplicate(true)
    var events := state.sect.workforce_event_count
    # Old bug allowed a busy Miner to move to Alchemy because the guard
    # compared the destination to the Alchemy group rather than current group.
    state.sect.work_groups["alchemy_crew"] = {
        "name":"Focused real Alchemy crew","priorities":{"alchemy":3}
    }
    var switch_group := workforce.assign_group(state,actor.id,&"alchemy_crew")
    var clear_site := workforce.assign_worksite(state,actor.id,&"")
    var other_work := workforce.perform_work(state,actor,WorkforceSystem.PROF_FORGING)
    var train := DiscipleTrainingActionV2.request_training(state,actor.id,"cultivation")
    var reserve := DiscipleBodyTrainingFacilityV2.reserve_slot(state,actor.id)
    var command := workforce.issue_command(state,actor.id,WorkforceSystem.COMMAND_CULTIVATE,"",40)
    if not _check(
        not switch_group and not clear_site
        and not bool(other_work.get("ok",false))
        and str(other_work.get("reason","")) == "busy_timed_job"
        and not bool(train.get("ok",false))
        and not bool(reserve.get("ok",false))
        and not command
        and actor.to_dict() == before
        and state.sect.warehouse_resources == stock
        and state.sect.workforce_event_count == events
        and not buildings.active_resource_timer_for_worker(state,actor.id).is_empty(),
        "competing command/group/worksite/training stole a reserved Miner"
    ):
        return

    other.current_action = &"EVALUATE"
    if not _check(workforce.issue_command(
        state,other.id,WorkforceSystem.COMMAND_HOLD,"",90
    ),"could not set real Hold command"):
        return
    var direct_before := other.to_dict()
    var blocked_reserve := DiscipleBodyTrainingFacilityV2.reserve_slot(state,other.id)
    var blocked_train := DiscipleTrainingActionV2.request_training(state,other.id,"cultivation")
    if not _check(not bool(blocked_reserve.get("ok",false))
        and not bool(blocked_train.get("ok",false))
        and other.to_dict() == direct_before,
        "Body or Cultivation silently overwrote a live Hold command"):
        return

    workforce.clear_command(state,other)
    if not _check(workforce.assign_group(state,other.id,&"forge_hall"),
        "could not establish existing Forge group assignment"):
        return
    var group_before := other.to_dict()
    if not _check(
        not bool(DiscipleBodyTrainingFacilityV2.reserve_slot(state,other.id).get("ok",false))
        and other.to_dict() == group_before,
        "Body stole a work-group assignment without explicit release"):
        return
    if not _check(workforce.assign_group(state,other.id,&""),
        "could not explicitly release Forge group"):
        return
    var booked := DiscipleBodyTrainingFacilityV2.reserve_slot(state,other.id)
    var busy_work := workforce.perform_work(state,other,WorkforceSystem.PROF_FORGING)
    if not _check(bool(booked.get("ok",false))
        and DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,other)
        and not bool(busy_work.get("ok",false))
        and str(busy_work.get("reason","")) == "busy_body_training",
        "reserved Body trainee performed a competing Forge action"):
        return

    if not _check(_verify_nonfinite_foundations(),
        "nonfinite six-stat candidate or disciple passed validation"):
        return

    print("DISCIPLE V2 ONE ACTIVE JOB INGRESS TEST PASS")
    quit(0)

func _verify_nonfinite_foundations() -> bool:
    var state := P37Factory.create_state(987703)
    state.sect.disciple_v2_birth_enabled = true
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,987704
    )
    if candidate == null:
        return false
    candidate.aptitude = NAN
    var bad_candidate := FoundationSystem.new().validate_candidate(candidate)
    if not ("nonfinite" in " | ".join(bad_candidate)):
        return false
    # An independently recruited authentic actor must also fail closed if
    # a loaded/dev payload contains an invalid open-point dimension.
    var disciple := _recruit(state,987705)
    if disciple == null:
        return false
    disciple.comprehension = INF
    var bad_disciple := FoundationSystem.new().validate_disciple(disciple)
    return "nonfinite" in " | ".join(bad_disciple)
