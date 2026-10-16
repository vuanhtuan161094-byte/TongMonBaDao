extends SceneTree

# Authored regression only. Official Godot 4.7.2 runtime NOT RUN.
const SAVE_PATH := "user://disciple_v2_potential_paid_growth_test.json"
var warehouse := WarehouseSystem.new()

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, reason: String) -> bool:
    if ok:
        return true
    push_error("DV2 POTENTIAL GROWTH FAIL: " + reason)
    _cleanup()
    quit(1)
    return false

func _cleanup() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _run() -> void:
    _cleanup()
    var state := P37Factory.create_state(987610)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.foundation_points_enabled = true
    state.sect.disciple_capacity = state.disciples.size() + 1
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,987611
    )
    if not _check(candidate != null,"no authentic V2 candidate"):
        return
    state.recruitment_candidates[candidate.id] = candidate
    if not _check(bool(RecruitmentSystem.new().accept_candidate(state,candidate.id).get("ok",false)),
        "recruitment failed"):
        return
    var actor: DiscipleState = state.disciples[candidate.id]
    if not _check(DiscipleRealmProgressV2.progression_ready(actor),
        "recruitment did not initialize V2 realm/body tracks"):
        return
    if not _check(bool(DiscipleRealmProgressV2.sync_live_hp(actor).get("ok",false)),
        "cannot initialize V2 HP"):
        return
    actor.hp = actor.max_hp * 0.375
    var birth := actor.foundation_birth_values.duplicate(true)
    var before_max := actor.max_hp
    var before_hp := actor.hp
    var previous := actor.potential
    var prior_quality := actor.disciple_quality
    if not _check(warehouse.add(state,&"linh_tuy",15),
        "QA fixture could not deposit a real registered earned-resource ID"):
        return
    if not _check(warehouse.set_rule(state,&"linh_tuy",6,false),
        "Warehouse reserve setup failed"):
        return
    var blocked := DiscipleFoundationGrowthV2.commit(state,actor.id,1,"growth-0001")
    if not _check(not bool(blocked.get("ok",false))
        and warehouse.quantity(state,&"linh_tuy") == 15
        and actor.potential == previous
        and state.sect.foundation_growth_receipts.is_empty(),
        "reserve bypass minted free foundation points"):
        return
    if not _check(warehouse.set_rule(state,&"linh_tuy",5,false),
        "reserve adjustment failed"):
        return
    var forecast := DiscipleFoundationGrowthV2.preview(state,actor.id,1)
    if not _check(bool(forecast.get("ok",false))
        and int(forecast.get("resource_amount",0)) == 10,
        "paid growth preview is not source-validated"):
        return
    var paid := DiscipleFoundationGrowthV2.commit(state,actor.id,1,"growth-0001")
    if not _check(bool(paid.get("ok",false))
        and not bool(paid.get("already_settled",true))
        and warehouse.quantity(state,&"linh_tuy") == 5
        and is_equal_approx(actor.potential,previous+1.0)
        and actor.foundation_birth_values == birth
        and is_equal_approx(actor.hp/actor.max_hp,0.375)
        and actor.max_hp > before_max
        and actor.hp > before_hp,
        "genuine earned-resource transaction failed or gave free heal"):
        return
    if not _check(
        actor.disciple_quality == FoundationSystem.new().quality_for_total(
            FoundationSystem.new().total_disciple(actor)
        ) and (actor.disciple_quality == prior_quality or actor.disciple_quality != &""),
        "quality not recomputed from permanent six-stat total"):
        return

    var foundation := FoundationSystem.new()
    var now_potential := actor.potential
    var now_max := actor.max_hp
    var invalid_nan := foundation.add_permanent_points(actor,FoundationSystem.DIM_POTENTIAL,NAN)
    var invalid_inf := foundation.add_permanent_points(actor,FoundationSystem.DIM_POTENTIAL,INF)
    if not _check(not invalid_nan and not invalid_inf and actor.potential == now_potential
        and actor.max_hp == now_max,"nonfinite Lục Duy points changed live core"):
        return

    var replay := DiscipleFoundationGrowthV2.commit(state,actor.id,1,"growth-0001")
    var conflict := DiscipleFoundationGrowthV2.commit(state,actor.id,2,"growth-0001")
    if not _check(bool(replay.get("already_settled",false))
        and not bool(conflict.get("ok",false))
        and warehouse.quantity(state,&"linh_tuy") == 5
        and actor.potential == now_potential,
        "duplicate/changed request minted resources or changed core"):
        return
    if not _check(SaveService.new().save_to_path(state,SAVE_PATH)==OK,
        "could not persist foundation receipt"):
        return
    var loaded: SimulationState = SaveService.new().load_from_path(SAVE_PATH)
    if not _check(loaded != null and loaded.sect.foundation_growth_receipts.size() == 1,
        "save/load dropped paid-growth receipt"):
        return
    var loaded_actor: DiscipleState = loaded.disciples[actor.id]
    var loaded_replay := DiscipleFoundationGrowthV2.commit(loaded,actor.id,1,"growth-0001")
    if not _check(bool(loaded_replay.get("already_settled",false))
        and warehouse.quantity(loaded,&"linh_tuy") == 5
        and is_equal_approx(loaded_actor.potential,now_potential)
        and is_equal_approx(loaded_actor.hp/loaded_actor.max_hp,0.375),
        "offline/reload replay delivered the same Potential point twice"):
        return

    # Potential scales Realm+Body core and never multiplies independent flat
    # equipment-like attack/defense bonuses.
    var with_flat := CombatStatsV2.derive(
        1,1,1,1,loaded_actor.potential,
        [{"source_id":"test_flat","channel":"attack","mode":"flat","value":100.0}]
    )
    var without_flat := CombatStatsV2.derive(
        1,1,1,1,loaded_actor.potential
    )
    if not _check(bool(with_flat.get("ok",false))
        and is_equal_approx(
            float(with_flat["stats"]["attack"])-float(without_flat["stats"]["attack"]),100.0
        ),
        "Tiềm Lực multiplied unrelated flat equipment stats"):
        return

    print("DISCIPLE V2 PAID POTENTIAL GROWTH + SAVE/REPLAY CONTRACT PASS")
    _cleanup()
    quit(0)
