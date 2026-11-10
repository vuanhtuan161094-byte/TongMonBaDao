extends SceneTree

# PVE-CARE03 canonical live NewGame + source-backed seeded test inventory.
# The potion is seeded ONLY as a QA fixture, not as a free gameplay drop.
# Proves actual Warehouse debit, B3 daily receipt, exact battle HP, 5-second
# cooldown, replay resistance and cold SaveService reload in BOTH PvE modes.
const NOW := 1801000000
const SEED := 330703
const P0_PATH := "user://pve_care03_p0_qa.json"
const B3_PATH := "user://pve_care03_b3_qa.json"

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> bool:
    if not ok:
        push_error("PVE_CARE03_FAIL "+message)
        quit(1)
        return false
    return true

func _cleanup(path: String) -> void:
    for suffix in ["",".tmp",".bak"]:
        if FileAccess.file_exists(path+suffix):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path+suffix))

func _run() -> void:
    _cleanup(P0_PATH)
    _cleanup(B3_PATH)
    if not _p0() or not _b3():
        return
    _cleanup(P0_PATH)
    _cleanup(B3_PATH)
    print("PVE_CARE03_BOTH_REAL_PVE_PILL_WAREHOUSE_RECEIPT_COOLDOWN_SAVE_PASS")
    quit(0)

func _p0() -> bool:
    var runtime := LiveGameRuntimeV2.new()
    var begun := runtime.start(P0_PATH,NOW,SEED)
    if not _check(bool(begun.get("ok",false)) and bool(begun.get("created",false)),"P0-new-game"):
        return false
    var state: SimulationState = runtime.state()
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    if not _check(not ids.is_empty(),"P0-no-candidates"):
        return false
    var id := StringName(str(ids[0]))
    if not _check(bool(RecruitmentSystem.new().accept_candidate(state,id).get("ok",false)),"P0-recruit"):
        return false
    var d: DiscipleState = state.disciples[id]
    var realm := int(d.v2_realm_progress.get("cultivation",{}).get("realm",0))
    var pill := MedicineCatalogueV2.item_id(MedicineCatalogueV2.FAMILY_HEAL,realm,1)
    var definition := MedicineCatalogueV2.definition(pill)
    var warehouse := WarehouseSystem.new()
    if not _check(not definition.is_empty() and warehouse.add(state,pill,3),"P0-QA-potion-seed"):
        return false
    var nav := SectIsometricWorldV1.pve_navigation_grid()
    var opts := PveOpenWorldTopologyV1.build(
        nav,Vector2(SectIsometricWorldV1.PVE_SPAWN_CELL)+Vector2(0.5,0.5))
    if not _check(bool(opts.get("ok",false)),"P0-navigation"):
        return false
    opts["p0_distributed_world"] = true
    opts["respawn_delay_sim_seconds"] = 30.0
    var deployed := PveP0CommandsV1.deploy(
        runtime.owner,"pve_care03_real_1",SEED,[str(id)],opts)
    var session := runtime.owner.get_active_multicamp_session()
    if not _check(bool(deployed.get("ok",false)) and session != null,"P0-deploy"):
        return false
    var actor: Dictionary = session.battle.actors[str(id)]
    # QA injury-free wound fixture, no kill or fake monster reward.
    var max_hp := float(actor["max_hp"])
    actor["hp"] = maxf(1.0,max_hp*0.50)
    var before_hp := float(actor["hp"])
    var before_stock := warehouse.quantity(state,pill)
    if not _check(not bool(PveCombatAutoPillV1.heal_one(
            state,session.battle,id).get("used",false))
            == false,"P0-consumer"):
        return false
    var first_receipt: Dictionary = d.b3_pill_state.get("receipt",{})
    var restored_hp := float(actor["hp"])-before_hp
    if not _check(warehouse.quantity(state,pill) == before_stock-1
            and restored_hp > 0.0
            and restored_hp <= float(definition["potency"])
            and int(first_receipt.get("sequence",0)) == 1
            and str(first_receipt.get("context","")) == "pve_care03"
            and B3PillSatietyV1.validate(state,d).is_empty(),
            "P0-one-true-item-and-meter"):
        return false
    var replay := PveCombatAutoPillV1.heal_one(state,session.battle,id)
    if not _check(bool(replay.get("ok",false)) and not bool(replay.get("used",true))
            and warehouse.quantity(state,pill) == before_stock-1
            and int(d.b3_pill_state.get("sequence",0)) == 1,
            "P0-same-frame-cooldown-and-idempotency"):
        return false
    if not _check(bool(session._persist_live_state().get("ok",false))
            and bool(runtime.save(NOW).get("ok",false)),"P0-canonical-save"):
        return false
    var loaded := SaveService.new().load_from_path(P0_PATH)
    if not _check(loaded != null and loaded.disciples.has(id)
            and warehouse.quantity(loaded,pill) == before_stock-1
            and int(loaded.disciples[id].b3_pill_state.get("sequence",0)) == 1
            and B3PillSatietyV1.validate(loaded,loaded.disciples[id]).is_empty(),
            "P0-cold-save-receipt-stock"):
        return false
    var resumed := HuntingPveRunV2.resume_active(loaded,session.battle.encounter_id)
    if not _check(bool(resumed.get("ok",false)),"P0-resume"):
        return false
    var cold_battle: MapBattleV2 = (resumed["session"] as HuntingPveRunV2).battle
    if not _check(is_equal_approx(float(cold_battle.actors[str(id)]["hp"]),float(actor["hp"]))
            and is_equal_approx(float(cold_battle.actors[str(id)][PveCombatAutoPillV1.ACTOR_NEXT_AT]),
                session.battle.now+PveCombatAutoPillV1.COOLDOWN_COMBAT_SECONDS),
            "P0-cold-battle-health-and-cooldown"):
        return false
    var duplicate := PveCombatAutoPillV1.heal_one(loaded,cold_battle,id)
    return _check(bool(duplicate.get("ok",false)) and not bool(duplicate.get("used",true))
        and warehouse.quantity(loaded,pill) == before_stock-1,
        "P0-after-reload-no-double-spend")

func _b3() -> bool:
    var runtime := LiveGameRuntimeV2.new()
    var begun := runtime.start(B3_PATH,NOW,930211)
    if not _check(bool(begun.get("ok",false)),"B3-new-game"):
        return false
    var setup := B3DemoSetup.prepare(runtime)
    if not _check(bool(setup.get("ok",false)),"B3-authentic-recruit"):
        return false
    var id: StringName = setup["disciple_id"]
    var state: SimulationState = runtime.state()
    var d: DiscipleState = state.disciples[id]
    var realm := int(d.v2_realm_progress.get("cultivation",{}).get("realm",0))
    var pill := MedicineCatalogueV2.item_id(MedicineCatalogueV2.FAMILY_HEAL,realm,1)
    var warehouse := WarehouseSystem.new()
    if not _check(warehouse.add(state,pill,2),"B3-QA-potion-seed"):
        return false
    if not _check(bool(B3HuntWorld.begin(runtime.owner,id).get("ok",false)),
            "B3-authentic-deploy"):
        return false
    var current := B3HuntWorld.restore(state)
    if not _check(bool(current.get("ok",false)),"B3-snapshot"):
        return false
    var battle: MapBattleV2 = current["battle"]
    var actor: Dictionary = battle.actors[str(id)]
    actor["hp"] = maxf(1.0,float(actor["max_hp"])*0.50)
    var before := warehouse.quantity(state,pill)
    var outcome := B3HuntWorld.advance_frame(state,battle)
    if not _check(bool(outcome.get("ok",false)) and bool(outcome.get("barrier",false))
            and int(outcome.get("combat_pills_used",0)) == 1
            and warehouse.quantity(state,pill) == before-1
            and int(d.b3_pill_state.get("sequence",0)) == 1
            and is_equal_approx(d.hp,d.max_hp*float(battle.actors[str(id)]["hp"])/float(battle.actors[str(id)]["max_hp"])),
            "B3-real-frame-consumed-one"):
        return false
    B3HuntWorld.checkpoint(state,battle)
    if not _check(bool(B3HuntWorld.commit(runtime.owner).get("ok",false)),
            "B3-save-commit"):
        return false
    var restored := SaveService.new().load_from_path(B3_PATH)
    if not _check(restored != null and restored.disciples.has(id)
            and warehouse.quantity(restored,pill) == before-1
            and int(restored.disciples[id].b3_pill_state.get("sequence",0)) == 1
            and B3PillSatietyV1.validate(restored,restored.disciples[id]).is_empty(),
            "B3-cold-save-stock-and-meter"):
        return false
    var cold := B3HuntWorld.restore(restored)
    return _check(bool(cold.get("ok",false))
        and is_equal_approx(float((cold["battle"] as MapBattleV2).actors[str(id)]["hp"]),float(battle.actors[str(id)]["hp"]))
        and (cold["battle"] as MapBattleV2).actors[str(id)].has(PveCombatAutoPillV1.ACTOR_NEXT_AT),
        "B3-cold-battle-hp-and-cooldown")
