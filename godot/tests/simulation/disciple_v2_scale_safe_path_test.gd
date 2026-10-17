extends SceneTree

# Disciple V2 scale-safe paths: deterministic contract, not benchmark PASS.
# Uses authentic V2 actor; no production balance or scheduler authority change.
var buildings := BuildingSystem.new()
var workforce := WorkforceSystem.new()

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, reason: String) -> bool:
    if not ok:
        push_error("DISCIPLE SCALE SAFE PATH FAIL: " + reason)
        quit(1)
        return false
    return true

func _run() -> void:
    if not _check(_verify_tuvi_equivalence(), "Tu Vi fast path differs from full preflight"):
        return
    if not _check(_verify_worksite_guards(), "worksite fast-rejection contract differs"):
        return
    print("DISCIPLE SCALE SAFE PATH TEST PASS")
    quit(0)

func _authentic_actor(state: SimulationState, generation_index: int) -> DiscipleState:
    state.sect.disciple_v2_birth_enabled = true
    state.sect.disciple_capacity = state.disciples.size() + 1
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state, DiscipleGeneratorV2.SOURCE_ORDINARY, generation_index
    )
    if candidate == null:
        return null
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    if not bool(accepted.get("ok",false)):
        return null
    return state.disciples[candidate.id]

func _verify_tuvi_equivalence() -> bool:
    var state := P37Factory.create_state(951011)
    var actor := _authentic_actor(state,951012)
    if actor == null or not DiscipleRealmProgressV2.progression_ready(actor):
        return false
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    var rule: Dictionary = state.sect.v2_training_rules["cultivation"]
    var full := DiscipleTuViFlowV2.validate_rule(actor,rule)
    var fast := DiscipleTuViFlowV2.validate_rule(actor,rule,false)
    if not bool(full.get("ok",false)) or not bool(fast.get("ok",false)):
        return false
    if float(full["base_tuvi_per_minute"]) != float(fast["base_tuvi_per_minute"]):
        return false

    var before := actor.v2_realm_progress.duplicate(true)
    var expected := DiscipleRealmProgressV2.grant_xp(
        actor,"cultivation",float(full["base_tuvi_per_minute"]),
        "natural",full["floor_costs"],full["sources"],true
    )
    if not bool(expected.get("ok",false)) or actor.v2_realm_progress != before:
        return false
    state.tick = 1
    var actual := DiscipleTuViFlowV2.resolve_minute(state,actor,false)
    if not bool(actual.get("ok",false)):
        return false
    if (
        not is_equal_approx(float(actual["gained"]),float(expected["gained"]))
        or int(actual["realm"]) != int(expected["realm"])
        or int(actual["floor"]) != int(expected["floor"])
        or not is_equal_approx(float(actual["xp"]),float(expected["xp"]))
        or int(actor.v2_realm_progress["last_passive_tuvi_tick"]) != 1
    ):
        return false
    var after := actor.v2_realm_progress.duplicate(true)
    var replay := DiscipleTuViFlowV2.resolve_minute(state,actor,false)
    if bool(replay.get("ok",false)) or actor.v2_realm_progress != after:
        return false

    # Invalid source structure must still be rejected BEFORE any committed XP.
    var bad_rule := rule.duplicate(true)
    bad_rule["sources"] = [{"source_id":"bad","channel":"invalid","mode":"percent_add","value":0.5}]
    state.sect.v2_training_rules["cultivation"] = bad_rule
    state.tick = 2
    before = actor.v2_realm_progress.duplicate(true)
    var rejected := DiscipleTuViFlowV2.resolve_minute(state,actor,false)
    return (
        not bool(rejected.get("ok",false))
        and str(rejected.get("reason","")) == "unsupported_xp_source_channel"
        and actor.v2_realm_progress == before
    )

func _verify_worksite_guards() -> bool:
    var state := P37Factory.create_state(951013)
    var mine := buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    if mine == null:
        return false

    var assigned := buildings.active_worker_ids(state,mine)
    for worker_id in assigned:
        var worker: DiscipleState = state.disciples[worker_id]
        if worker.region_id == &"sect" and worker.active_pve_encounter_id == &"":
            if not buildings.can_disciple_work(state,mine,worker):
                return false

    var free: DiscipleState = null
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var actor: DiscipleState = state.disciples[raw_id]
        if actor.work_group_id == &"" and actor.region_id == &"sect":
            free = actor
            break
    if free == null or buildings.can_disciple_work(state,mine,free):
        return false

    # A false worksite match must never accidentally inherit the Mine's
    # primary-instance fallback, even if the group ID matches.
    var previous_group := free.work_group_id
    var previous_worksite := free.worksite_building_id
    free.work_group_id = mine.worker_group_id
    free.worksite_building_id = &"different_worksite"
    var incorrectly_admitted := buildings.can_disciple_work(state,mine,free)
    free.work_group_id = previous_group
    free.worksite_building_id = previous_worksite
    if incorrectly_admitted:
        return false

    # No explicit priority => no profession can win; avoid availability
    # queries without changing choice semantics for unassigned actors.
    for profession in WorkforceSystem.VALID_PROFESSIONS:
        free.work_preferences[str(profession)] = 0
    return workforce.choose_work_profession(state,free) == &""
