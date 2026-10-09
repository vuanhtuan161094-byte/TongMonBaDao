extends SceneTree

func _init() -> void:
    call_deferred("_run")

func _assert(valid: bool, reason: String) -> bool:
    if not valid:
        push_error(reason)
        quit(1)
        return false
    return true

func _costs(realm: int, price: float) -> Dictionary:
    var result: Dictionary = {}
    for floor_index in range(1,11):
        result["%d:%d" % [realm,floor_index]] = price
    return result

func _run() -> void:
    var state := P37Factory.create_state(90317)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)

    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,319
    )
    if not _assert(candidate != null and
        DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile),
        "Could not generate a complete V2 candidate."):
        return
    var malformed_birth: Dictionary = candidate.v2_birth_profile.duplicate(true)
    malformed_birth["layers"]["spiritual_root"]["birth_values"] = {}
    if not _assert(not DiscipleBirthProfileV2.valid_complete_birth(malformed_birth),
        "Initialized flags alone incorrectly passed as an authentic V2 birth identity."):
        return
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    if not _assert(bool(accepted.get("ok",false)),
        "V2 candidate could not enter the sect with progression ownership."):
        return
    var disciple: DiscipleState = state.disciples[candidate.id]
    if not _assert(DiscipleRealmProgressV2.owns_v2_progression(disciple) and
        DiscipleRealmProgressV2.progression_ready(disciple),
        "Accepted V2 disciple has no canonical progression profile."):
        return
    var start := DiscipleRealmProgressV2.current(disciple)
    if not _assert(int(start["cultivation"]["realm"])==1 and
        int(start["cultivation"]["floor"])==1 and
        int(start["body"]["realm"])==1 and int(start["body"]["floor"])==1,
        "New V2 recruit did not start Phàm Nhân 1 + Phàm Thân 1."):
        return

    # Pre-DV2-03 saves with a complete birth identity but no progress migrate
    # once; a present malformed progress payload must NOT be silently reset.
    var old_v2_save := disciple.to_dict()
    old_v2_save.erase("v2_realm_progress")
    old_v2_save["max_hp"] = 100.0
    old_v2_save["hp"] = 37.0
    var migrated_old := DiscipleState.from_dict(old_v2_save)
    if not _assert(DiscipleRealmProgressV2.progression_ready(migrated_old) and
        int(migrated_old.v2_realm_progress["cultivation"]["realm"])==2 and
        int(migrated_old.v2_realm_progress["cultivation"]["floor"])==candidate.cultivation_stage_index+1 and
        absf(migrated_old.hp/migrated_old.max_hp-0.37)<0.000001,
        "Old V2 identity-only save did not migrate progression/HP ratio deterministically."):
        return
    var corrupt_v2_save := disciple.to_dict()
    corrupt_v2_save["v2_realm_progress"] = {"version":1,"initialized":true}
    var corrupt_loaded := DiscipleState.from_dict(corrupt_v2_save)
    if not _assert(DiscipleRealmProgressV2.owns_v2_progression(corrupt_loaded) and
        not DiscipleRealmProgressV2.progression_ready(corrupt_loaded) and
        corrupt_loaded.v2_realm_progress.is_empty(),
        "Malformed saved V2 progress was silently rerolled instead of failing closed."):
        return

    state.sect.cultivation_enabled = true
    var workforce := WorkforceSystem.new()

    # Compatibility UI command must fail/clear instead of falling into P2 or
    # sticking forever when V2 authored training content is not ready.
    state.sect.workforce_enabled = true
    state.sect.v2_training_enabled = false
    disciple.direct_command = {
        "kind":"CULTIVATE","target":"","issued_tick":state.tick,
        "expires_tick":state.tick+20
    }
    var unavailable_action := workforce.next_action(state,disciple)
    var unavailable_result: Dictionary = disciple.last_decision.get("v2_training_result",{})
    if not _assert(unavailable_action==&"" and disciple.direct_command.is_empty() and
        str(unavailable_result.get("reason",""))=="v2_training_not_ready",
        "Unavailable V2 cultivate command was not rejected/cleared cleanly."):
        return

    state.sect.v2_training_enabled = true
    var cult_realm := int(disciple.v2_realm_progress["cultivation"]["realm"])
    state.sect.v2_training_rules = {
        "cultivation":{
            "authority_id":"qa-v2-isolation-cultivation",
            "action":"CULTIVATE","base_tuvi_per_minute":10.0,
            "cultivate_multiplier":2.0,
            "floor_costs":_costs(cult_realm,1000.0),"sources":[]
        },
        "body":{
            "authority_id":"qa-v2-isolation-body-costs",
            "training_mechanic":"unresolved",
            "floor_costs":_costs(1,1000.0),"sources":[]
        }
    }

    # Decision AI may see expedition stamina for whether to leave the sect, but
    # must not read P2 cultivation or use in-sect REST as a stamina refill.
    disciple.region_id = &"sect"
    disciple.hp = disciple.max_hp
    disciple.stamina = 5.0
    disciple.inventory.clear()
    var decision := DecisionSystem.new().evaluate(state,disciple)
    if not _assert(str(decision.get("action","")) != "REST" and
        not decision.has("cultivation_stage") and
        not decision.has("cultivation_progress") and
        decision.has("v2_progression"),
        "V2 AI still exposed/used P2 cultivation or chose legacy stamina REST."):
        return

    # The existing UI/workforce CULTIVATE command may route into V2 when the
    # V2 rule exists, regardless of low expedition stamina.
    disciple.direct_command = {
        "kind":"CULTIVATE","target":"","issued_tick":state.tick,
        "expires_tick":state.tick+20
    }
    if not _assert(workforce.next_action(state,disciple)==&"CULTIVATE",
        "Legacy UI cultivate command did not route to the V2 action owner."):
        return
    disciple.direct_command.clear()

    # In-sect work cannot consume expedition stamina for a V2 disciple.
    var stamina_before_work := disciple.stamina
    var work_result := workforce.perform_work(state,disciple,WorkforceSystem.PROF_FORGING)
    if not _assert(bool(work_result.get("ok",false)) and
        absf(disciple.stamina-stamina_before_work)<0.000001,
        "In-sect work consumed V2 expedition stamina."):
        return

    # Ordinary V2 work has no SECOND Tu Vi award. Passive Tu Vi belongs to
    # the scheduler minute source, not WorkforceSystem.
    var p2_before_work := disciple.cultivation_progress
    var v2_before_work := float(disciple.v2_realm_progress["cultivation"]["xp"])
    var work_cultivation := workforce._grant_p3_7_work_cultivation(
        state,disciple,WorkforceSystem.PROF_MINING
    )
    if not _assert(absf(work_cultivation)<0.000001 and
        absf(float(disciple.v2_realm_progress["cultivation"]["xp"])-v2_before_work)<0.000001 and
        absf(disciple.cultivation_progress-p2_before_work)<0.000001,
        "Ordinary work still created a separate V2/P2 cultivation award."):
        return

    var scheduler := SimulationScheduler.new(state)

    # REST and HOLD inside the sect do not refill expedition stamina.
    var stamina_before_rest := disciple.stamina
    disciple.current_action = &"REST"
    scheduler.step()
    if not _assert(absf(disciple.stamina-stamina_before_rest)<0.000001,
        "V2 REST refilled expedition stamina."):
        return
    disciple.current_action = &"HOLD"
    scheduler.step()
    if not _assert(absf(disciple.stamina-stamina_before_rest)<0.000001,
        "V2 HOLD refilled expedition stamina."):
        return

    # BREAKTHROUGH action must never call the old P2 attempt for a V2 owner.
    var old_stage := disciple.cultivation_stage_index
    var old_p2_xp := disciple.cultivation_progress
    var old_hp := disciple.hp
    var old_stamina := disciple.stamina
    var old_v2 := disciple.v2_realm_progress.duplicate(true)
    disciple.current_action = &"BREAKTHROUGH"
    scheduler.step()
    var blocked_gate: Dictionary = disciple.last_decision.get("v2_breakthrough_result",{})
    if not _assert(disciple.cultivation_stage_index==old_stage and
        absf(disciple.cultivation_progress-old_p2_xp)<0.000001 and
        absf(disciple.hp-old_hp)<0.000001 and
        absf(disciple.stamina-old_stamina)<0.000001 and
        int(disciple.v2_realm_progress["cultivation"]["realm"])==int(old_v2["cultivation"]["realm"]) and
        int(disciple.v2_realm_progress["cultivation"]["floor"])==int(old_v2["cultivation"]["floor"]) and
        str(blocked_gate.get("reason",""))=="v2_breakthrough_content_not_authorized",
        "V2 BREAKTHROUGH leaked into the P2 gate or mutated V2 without authored content."):
        return

    # A guaranteed legacy combat win may spend expedition stamina, but it must
    # not award the old P2 cultivation progress or P2 realm power.
    var region_ids: Array = state.regions.keys()
    if not _assert(not region_ids.is_empty(),"Test state has no hunting region."):
        return
    disciple.region_id = region_ids[0]
    disciple.combat_power = 1000000.0
    disciple.hp = disciple.max_hp
    disciple.stamina = 100.0
    var p2_before_combat := disciple.cultivation_progress
    var stage_before_combat := disciple.cultivation_stage_index
    var wins_before := int(disciple.metrics.get("wins",0))
    disciple.current_action = &"COMBAT"
    scheduler.step()
    if not _assert(int(disciple.metrics.get("wins",0))>wins_before and
        disciple.cultivation_stage_index==stage_before_combat and
        absf(disciple.cultivation_progress-p2_before_combat)<0.000001,
        "Combat win still mutated the P2 cultivation track for a V2 disciple."):
        return

    # A true V2 cultivation action remains independent of the P2 meter.
    disciple.region_id = &"sect"
    disciple.current_action = &"CULTIVATE"
    var p2_before_training := disciple.cultivation_progress
    var v2_before_training := float(disciple.v2_realm_progress["cultivation"]["xp"])
    scheduler.step()
    if not _assert(float(disciple.v2_realm_progress["cultivation"]["xp"])>v2_before_training and
        absf(disciple.cultivation_progress-p2_before_training)<0.000001,
        "V2 CULTIVATE action still wrote the P2 cultivation meter."):
        return

    print("DV2-03M P2/V2 PROGRESSION + STAMINA ISOLATION: PASS")
    quit()
