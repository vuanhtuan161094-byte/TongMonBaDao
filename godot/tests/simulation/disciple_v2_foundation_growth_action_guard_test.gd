extends SceneTree

# DV2 growth/guard contract. This file is authored, not runtime-verified.
# Fixtures seed actual registered Warehouse stock; gameplay has only the
# canonical Field Lv30 Tử Vân Thảo production source.
var warehouse := WarehouseSystem.new()
var buildings := BuildingSystem.new()
var workforce := WorkforceSystem.new()
var growth := FoundationGrowthV2.new()
var foundation := FoundationSystem.new()
const SAVE_PATH := "user://dv2_foundation_growth_action_guard_test.json"

func _cleanup() -> void:
    for suffix in ["", ".tmp", ".bak"]:
        var path := SAVE_PATH + suffix
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, reason: String) -> bool:
    if not ok:
        push_error("DV2 FOUNDATION + ACTION GUARD FAIL: " + reason)
        _cleanup()
        quit(1)
        return false
    return true

func _actor(state: SimulationState, index: int) -> DiscipleState:
    state.sect.disciple_v2_birth_enabled = true
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,index
    )
    if candidate == null:
        return null
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    if not bool(accepted.get("ok",false)):
        return null
    return state.disciples[candidate.id]

func _run() -> void:
    _cleanup()
    if not _verify_growth():
        return
    if not _verify_active_job_guards():
        return
    _cleanup()
    print("DV2 FOUNDATION + ACTION GUARD TEST PASS")
    quit(0)

func _verify_growth() -> bool:
    var state := P37Factory.create_state(956601)
    var actor := _actor(state,956602)
    if not _check(actor != null and DiscipleRealmProgressV2.progression_ready(actor),
        "authentic V2 actor is unavailable"):
        return false
    actor.current_action = &"HOLD"
    if not _check(state.sect.p3_7_resources_enabled, "canonical Warehouse not enabled"):
        return false
    var before_birth := actor.foundation_birth_values.duplicate(true)
    var before_potential := actor.potential
    var before_hp := actor.hp
    var before_max := actor.max_hp
    var core_before := DiscipleRealmProgressV2.derive_stats(actor)
    if not _check(bool(core_before.get("ok",false)),"core stats unavailable"):
        return false

    if not _check(
        warehouse.add(state,FoundationGrowthV2.RESOURCE_ID,1500)
        and warehouse.set_rule(state,FoundationGrowthV2.RESOURCE_ID,600,false),
        "could not seed fixture with a protected crop reserve"
    ):
        return false
    var denied := growth.commit(state,actor.id,"potential-001")
    if not _check(not bool(denied.get("ok",false))
        and warehouse.quantity(state,FoundationGrowthV2.RESOURCE_ID) == 1500
        and actor.potential == before_potential,
        "reserve must block both material debit and stat grant"):
        return false

    if not _check(warehouse.set_rule(state,FoundationGrowthV2.RESOURCE_ID,500,false),
        "could not unlock exactly the expendable 1,000 herbs"):
        return false
    var complete := growth.commit(state,actor.id,"potential-001")
    if not _check(bool(complete.get("ok",false))
        and not bool(complete.get("already_settled",true))
        and warehouse.quantity(state,FoundationGrowthV2.RESOURCE_ID) == 500
        and is_equal_approx(actor.potential,before_potential+1.0),
        "real Warehouse debit and permanent Potential did not settle together"):
        return false

    var core_after := DiscipleRealmProgressV2.derive_stats(actor)
    if not _check(bool(core_after.get("ok",false))
        and float(core_after["stats"]["attack"]) > float(core_before["stats"]["attack"])
        and float(core_after["stats"]["defense"]) > float(core_before["stats"]["defense"])
        and is_equal_approx(actor.max_hp,float(core_after["stats"]["max_hp"]))
        and is_equal_approx(actor.hp / actor.max_hp,before_hp / before_max)
        and actor.foundation_birth_values == before_birth,
        "Potential must increase only Realm/Body core and sync HP without healing/birth rewrite"):
        return false

    var stable_hp := actor.hp
    var stable_max := actor.max_hp
    var stable_potential := actor.potential
    var stable_stock := warehouse.quantity(state,FoundationGrowthV2.RESOURCE_ID)
    var replay := growth.commit(state,actor.id,"potential-001")
    if not _check(bool(replay.get("ok",false)) and bool(replay.get("already_settled",false))
        and actor.potential == stable_potential and actor.hp == stable_hp
        and actor.max_hp == stable_max and warehouse.quantity(state,FoundationGrowthV2.RESOURCE_ID) == stable_stock,
        "same request must replay receipt, never regrant or re-debit"):
        return false
    var unknown_actor_id := StringName("someone_else")
    var conflict := growth.commit(state,unknown_actor_id,"potential-001")
    if not _check(not bool(conflict.get("ok",false))
        and str(conflict.get("reason","")) == "foundation_request_id_conflict",
        "cross-actor request ID reuse was not rejected"):
        return false

    var restored := SectState.from_dict(state.sect.to_dict())
    if not _check(restored.v2_foundation_growth_receipts.has("potential-001")
        and restored.v2_foundation_growth_receipts["potential-001"] == state.sect.v2_foundation_growth_receipts["potential-001"],
        "exactly-once receipt did not survive SectState save/load"):
        return false

    # Exercise the real SaveService path, not just a SectState dictionary.
    var saves := SaveService.new()
    if not _check(saves.save_to_path(state,SAVE_PATH) == OK,
        "growth state could not be persisted through canonical SaveService"):
        return false
    var loaded := saves.load_from_path(SAVE_PATH)
    if not _check(loaded != null and loaded.disciples.has(actor.id),
        "saved growth state could not be reloaded"):
        return false
    var loaded_actor: DiscipleState = loaded.disciples[actor.id]
    if not _check(
        loaded.sect.v2_foundation_growth_receipts.has("potential-001")
        and is_equal_approx(loaded_actor.potential,stable_potential)
        and warehouse.quantity(loaded,FoundationGrowthV2.RESOURCE_ID) == stable_stock,
        "SaveService lost crop debit, permanent Potential or committed receipt"
    ):
        return false
    var loaded_replay := growth.commit(loaded,actor.id,"potential-001")
    if not _check(bool(loaded_replay.get("ok",false))
        and bool(loaded_replay.get("already_settled",false))
        and is_equal_approx(loaded_actor.potential,stable_potential)
        and warehouse.quantity(loaded,FoundationGrowthV2.RESOURCE_ID) == stable_stock,
        "reloaded request granted Potential or spent crop twice"):
        return false

    var bad := foundation.add_permanent_points(actor,FoundationSystem.DIM_POTENTIAL,INF)
    return _check(not bad and actor.potential == stable_potential
        and actor.foundation_birth_values == before_birth,"invalid growth mutated V2 foundation")

func _verify_active_job_guards() -> bool:
    var state := P37Factory.create_state(956603)
    var mine := buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    if not _check(mine != null,"Mine fixture missing"):
        return false
    state.sect.economy_a_enabled = true
    var workers := buildings.active_worker_ids(state,mine)
    if not _check(not workers.is_empty(),"Mine has no assigned operator"):
        return false
    var miner: DiscipleState = state.disciples[workers[0]]
    miner.current_action = &"HOLD"
    # Saved in-flight timer fixture: real timer owner and worker ID, not an
    # arbitrary "busy" flag on the actor.
    var jobs := [{
        "job_id":"guard:mining:1","worker_id":str(miner.id),
        "resource_id":"thanh_thiet","finish_tick":state.tick+60,
        "output_quantity":10000
    }]
    mine.production_state["economy_a_jobs"] = jobs
    if not _check(buildings.disciple_has_active_timed_recipe(state,miner.id),
        "saved Mine timer does not reserve the actor"):
        return false
    var before_xp := miner.profession_xp.duplicate(true)
    var before_progress := miner.work_progress.duplicate(true)
    var refused := workforce.perform_work(state,miner,WorkforceSystem.PROF_FORGING)
    if not _check(not bool(refused.get("ok",false))
        and str(refused.get("reason","")) == "busy_timed_job"
        and miner.profession_xp == before_xp
        and miner.work_progress == before_progress
        and mine.production_state["economy_a_jobs"] == jobs,
        "direct Forge call bypassed an existing timer"):
        return false
    # Body-gate entrypoint must also reject a disguised HOLD actor who still
    # owns an in-flight production transaction.
    var growth_actor := _actor(state,956604)
    if not _check(growth_actor != null, "growth reservation actor missing"):
        return false
    growth_actor.current_action = &"HOLD"
    growth_actor.work_cycle_state = {"profession":"mining","phase":"extract"}
    var growth_denied := growth.preview(state,growth_actor.id)
    if not _check(not bool(growth_denied.get("ok",false))
        and str(growth_denied.get("reason","")) == "foundation_reserved_occupation",
        "growth entrypoint bypassed saved active work"):
        return false
    var other_profession := workforce.perform_work(state,growth_actor,WorkforceSystem.PROF_FORGING)
    if not _check(
        not bool(other_profession.get("ok",false))
        and str(other_profession.get("reason","")) == "busy_work_cycle",
        "direct Forge bypassed an active legacy carry cycle"
    ):
        return false
    var body_gate := DiscipleBodyGateTransactionV2.new().preview_gate(state,growth_actor.id)
    if not _check(str(body_gate.get("reason","")) == "body_gate_disciple_reserved",
        "Body gate bypassed active legacy production cycle"):
        return false
    var growth_commit := growth.commit(state,growth_actor.id,"busy-growth")
    return _check(not bool(growth_commit.get("ok",false))
        and str(growth_commit.get("reason","")) == "foundation_reserved_occupation",
        "busy actor committed growth despite active job")
