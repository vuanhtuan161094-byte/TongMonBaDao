extends SceneTree

# MINE-V2 P1: one worker per individual Mine, profession/typed lục-duy
# throughput and actual Economy-A timer/warehouse/wage once-only.
const SAVE_PATH := "user://mine_v2_one_worker_test.json"

var buildings := BuildingSystem.new()
var workforce := WorkforceSystem.new()
var warehouse := WarehouseSystem.new()

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, reason: String) -> bool:
    if not ok:
        push_error("MINE-V2 TEST FAIL: " + reason)
        quit(1)
        return false
    return true

func _run() -> void:
    _cleanup()
    if not _verify_fresh_slots_and_atomic_assignment():
        return
    if not _verify_no_arbitrary_foundation_ore_bonus():
        return
    if not _verify_real_timed_packet_save_and_wage():
        return
    print("MINE-V2 ONE WORKER + PROFESSION TIME + SAVE/RECEIPT TEST PASS")
    _cleanup()
    quit(0)

func _verify_fresh_slots_and_atomic_assignment() -> bool:
    var state := P37Factory.create_state(900501)
    var mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    if not _check(mine != null, "fresh primary Mine missing"):
        return false
    var first := buildings.active_worker_ids(state, mine)
    if not _check(first.size() == 1 and buildings.assigned_worker_ids(state, mine).size() == 1,
        "fresh mine does not own exactly one disciple"):
        return false
    for level in [1, 5, 10, 20, 50, 100]:
        mine.level = level
        if not _check(buildings.worker_slots(mine) == 1, "Mine slot grew with building level"):
            return false
    mine.level = 1

    var candidate: DiscipleState = null
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var d: DiscipleState = state.disciples[raw_id]
        if d.work_group_id == &"" and d.region_id == &"sect":
            candidate = d
            break
    if not _check(candidate != null, "no idle worker to verify slot"):
        return false

    if not _check(not workforce.assign_group(state, candidate.id, &"mining_crew"),
        "legacy group path overbooked full mine"):
        return false
    var reject := workforce.assign_mine_worker(state, candidate.id, mine.id)
    if not _check(not bool(reject.get("ok", false)) and str(reject.get("reason", "")) == "mine_full",
        "atomic assignment overbooked full Mine"):
        return false
    if not _check(buildings.assigned_worker_ids(state, mine) == first,
        "rejected assignment changed Mine roster"):
        return false

    # The second Mine is an independent instance with a separate valid owner.
    var second := buildings.create_building(BuildingSystem.TYPE_MINE, 2)
    state.buildings[str(second.id)] = second
    var assigned := workforce.assign_mine_worker(state, candidate.id, second.id)
    if not _check(bool(assigned.get("ok", false)) and
        buildings.active_worker_ids(state, second) == [candidate.id] and
        buildings.active_worker_ids(state, mine) == first,
        "two Mỏ instances did not hold one independent worker each"):
        return false
    if not _check(bool(workforce.assign_mine_worker(state, candidate.id, second.id).get("already_assigned", false)),
        "repeating exact atomic assignment was not idempotent"):
        return false

    var another: DiscipleState = null
    for raw_id in ids:
        var d: DiscipleState = state.disciples[raw_id]
        if d.id != candidate.id and d.work_group_id == &"" and d.region_id == &"sect":
            another = d
            break
    if not _check(another != null, "no worker available to probe safe replacement"):
        return false
    var replaced := workforce.assign_mine_worker(state, another.id, second.id, true)
    if not _check(bool(replaced.get("ok", false)) and bool(replaced.get("replaced", false))
        and candidate.work_group_id == &"" and candidate.worksite_building_id == &""
        and buildings.assigned_worker_ids(state, second) == [another.id],
        "atomic Mine replacement did not release prior operator"):
        return false

    var errors := buildings.validate_invariants(state)
    errors.append_array(workforce.validate_invariants(state))
    return _check(errors.is_empty(), "new 2-Mine state violates invariants: %s" % " | ".join(errors))

func _verify_no_arbitrary_foundation_ore_bonus() -> bool:
    var state := P37Factory.create_state(900502)
    var mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    var actor: DiscipleState = state.disciples[buildings.active_worker_ids(state, mine)[0]]
    var base := buildings._resource_job_batch_units(mine)
    # Căn Cốt has its canonical Body training role; mining must not turn
    # 1,000 points into a gratuitous extra ore. Output formula is a mine
    # building/content value until an independently approved result rule.
    for points in [0.0, 999.0, 1000.0, 2500.0, 10000.0]:
        actor.constitution = points
        if not _check(buildings._resource_job_batch_units(mine) == base,
            "Mine received an unapproved Căn Cốt-to-ore bonus"):
            return false
    var realm_before := buildings._resource_job_batch_units(mine)
    actor.cultivation_stage_index += 1
    if not _check(buildings._resource_job_batch_units(mine) == realm_before,
        "Cultivation realm incorrectly changes ore quantity"):
        return false
    return true

func _verify_real_timed_packet_save_and_wage() -> bool:
    var state := P37Factory.create_state(900503)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    state.sect.disciple_capacity = state.disciples.size() + 1
    state.sect.spirit_stones = 500
    var mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    var founder_id: StringName = buildings.active_worker_ids(state, mine)[0]
    if not _check(workforce.assign_group(state, founder_id, &""),
        "could not free sole fresh miner"):
        return false

    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state, DiscipleGeneratorV2.SOURCE_ORDINARY, 1002
    )
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state, candidate.id)
    if not _check(bool(accepted.get("ok", false)), "could not recruit real V2 miner"):
        return false
    var actor: DiscipleState = state.disciples[candidate.id]
    if not _check(DiscipleRealmProgressV2.owns_v2_progression(actor),
        "test actor is not real V2"):
        return false
    actor.profession_xp["mining"] = 2400.0 # canonical profession Lv10
    if not _check(workforce.profession_level_for_state(state, actor, &"mining") == 10,
        "Mine pilot did not use canonical profession level"):
        return false
    var assigned := workforce.assign_mine_worker(state, actor.id, mine.id)
    if not _check(bool(assigned.get("ok", false)), "V2 miner could not claim one Mine slot"):
        return false
    if not _check(bool(EconomySystem.new().enable_v1(state).get("ok", false)),
        "could not activate authentic Economy-A timer"):
        return false

    # Hold other actors so the ore delta is attributable to this Mine only.
    for raw_id in state.disciples.keys():
        var id := StringName(raw_id)
        if id == actor.id:
            continue
        if not _check(workforce.issue_command(state, id, WorkforceSystem.COMMAND_HOLD, "", 1000),
            "could not isolate unrelated opening actor"):
            return false
    var before := warehouse.quantity(state, &"thanh_thiet")
    var stones_before := state.sect.spirit_stones
    var expected := buildings._resource_job_batch_units(mine)
    var started := workforce.perform_work(state, actor, WorkforceSystem.PROF_MINING)
    if not _check(bool(started.get("ok", false)) and bool(started.get("started", false)),
        "V2 Mine did not start real Economy-A timed job"):
        return false
    var timer := buildings.active_resource_timer_for_worker(state, actor.id)
    if not _check(not timer.is_empty() and int(timer.get("output_quantity", -1)) == expected,
        "Mine timer did not snapshot authored Mine quantity"):
        return false
    if not _check(not bool(workforce.perform_work(state, actor, WorkforceSystem.PROF_MINING).get("ok", false)),
        "same actor started a competing Mine timer"):
        return false
    var replacement_id: StringName = &""
    for raw_id in state.disciples.keys():
        var d: DiscipleState = state.disciples[raw_id]
        if d.work_group_id == &"" and d.region_id == &"sect":
            replacement_id = d.id
            break
    if not _check(replacement_id != &"", "no replacement disciple available"):
        return false
    # The fixture placed everyone else on HOLD to isolate output. Clear
    # only this candidate's HOLD before checking busy-owner rejection.
    workforce.clear_command(state, state.disciples[replacement_id])
    var forbidden := workforce.assign_mine_worker(state, replacement_id, mine.id, true)
    if not _check(not bool(forbidden.get("ok", false))
        and str(forbidden.get("reason", "")) == "previous_miner_busy"
        and buildings.active_worker_ids(state, mine) == [actor.id],
        "replacement canceled or displaced an active timed Mine packet"):
        return false
    if not _check(SaveService.new().save_to_path(state, SAVE_PATH) == OK,
        "cannot save active Mine V2 packet"):
        return false
    var loaded := SaveService.new().load_from_path(SAVE_PATH)
    if not _check(loaded != null, "cannot reload saved Mine V2 packet"):
        return false
    var resumed_mine := buildings.primary_building(loaded, BuildingSystem.TYPE_MINE)
    var resumed_actor: DiscipleState = loaded.disciples[actor.id]
    var runner := SimulationScheduler.new(loaded)
    while loaded.tick < int(timer["finish_tick"]):
        runner.step()
    if not _check(warehouse.quantity(loaded, &"thanh_thiet") == before + expected,
        "completed Mine V2 timer did not add expected canonical ore"):
        return false
    var receipt := "wage:%s" % str(timer["job_id"])
    if not _check(loaded.sect.economy_a_receipts.has(receipt)
        and loaded.sect.spirit_stones == stones_before - int(loaded.sect.economy_a_policy.get("wage_per_batch", 2))
        and resumed_actor.spirit_stones == int(loaded.sect.economy_a_policy.get("wage_per_batch", 2)),
        "Mine output wage was not exactly-once and zero sum"):
        return false
    var stable_ore := warehouse.quantity(loaded, &"thanh_thiet")
    if not _check(workforce.issue_command(loaded, actor.id, WorkforceSystem.COMMAND_HOLD, "", 200),
        "could not hold sole Mine worker after paid packet"):
        return false
    for _i in range(5):
        runner.step()
    if not _check(warehouse.quantity(loaded, &"thanh_thiet") == stable_ore
        and buildings.resource_timer_jobs(resumed_mine).is_empty(),
        "Mine packet credited output again after settlement"):
        return false
    return true

func _cleanup() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
    if FileAccess.file_exists(SAVE_PATH + ".bak"):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH + ".bak"))
    if FileAccess.file_exists(SAVE_PATH + ".tmp"):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH + ".tmp"))
