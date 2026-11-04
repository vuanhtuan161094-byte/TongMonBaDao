extends SceneTree

# One isolated SaveService lineage across three independent Godot processes:
# New Game -> real Residence construction -> Mine/Warehouse production ->
# real V2 recruitment -> canonical PvE HP0/loot -> cold reload -> continue
# production and hunt -> another cold reload. No injected resources/actors.
const SAVE_PATH := "user://qa_r3_one_game_lineage_20261104.json"
const EXPECTED_PATH := "user://qa_r3_one_game_lineage_20261104.expected.json"
const FINAL_PATH := "user://qa_r3_one_game_lineage_20261104.final.json"
const ENCOUNTER_ID := "r3_one_game_lineage_hunt"
const NOW := 1802400000
const SEED := 311042026

var checks := 0

func _init() -> void:
    call_deferred("_run")

func _ok(condition: bool, detail: String) -> bool:
    checks += 1
    if condition:
        return true
    push_error("ONE_GAME_R3_CONTINUOUS_FAIL " + detail)
    quit(1)
    return false

func _world() -> Dictionary:
    var nav := SectIsometricWorldV1.pve_navigation_grid()
    if nav.is_empty():
        return {}
    var options := PveOpenWorldTopologyV1.build(
        nav, Vector2(SectIsometricWorldV1.PVE_SPAWN_CELL) + Vector2(0.5, 0.5))
    if bool(options.get("ok", false)):
        options["p0_distributed_world"] = true
        options["respawn_delay_sim_seconds"] = 30.0
    return options

func _read_json(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    file.close()
    return parsed if parsed is Dictionary else {}

func _write_json(path: String, value: Dictionary) -> bool:
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(value, "\t"))
    file.close()
    return true

func _same_resource_map(left: Dictionary, right: Dictionary) -> bool:
    if left.size() != right.size():
        return false
    for key in left.keys():
        if not right.has(key) or int(left[key]) != int(right[key]):
            return false
    return true

func _run() -> void:
    var args := OS.get_cmdline_user_args()
    var phase := str(args[0]) if not args.is_empty() else "create"
    if not SAVE_PATH.begins_with("user://qa_r3_one_game_lineage_"):
        _ok(false, "save path escaped isolated QA namespace")
        return
    match phase:
        "create":
            _create_first_life()
        "continue":
            _continue_after_cold_reload()
        "verify":
            _verify_second_cold_reload()
        _:
            _ok(false, "unknown R3 phase: " + phase)

func _create_first_life() -> void:
    for path in [SAVE_PATH, SAVE_PATH + ".tmp", SAVE_PATH + ".bak", EXPECTED_PATH, FINAL_PATH]:
        var absolute := ProjectSettings.globalize_path(path)
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(absolute)
    var runtime := LiveGameRuntimeV2.new()
    var opened := runtime.start(SAVE_PATH, NOW, SEED)
    if not _ok(bool(opened.get("ok", false)) and bool(opened.get("created", false)),
            "phase 1 did not create a canonical New Game through LiveGameRuntimeV2"):
        return
    var state: SimulationState = runtime.state()
    if not _ok(state.disciples.size() == 6 and state.buildings.has("residence_001"),
            "New Game must retain six founders and its canonical starter Residence"):
        return

    var warehouse := WarehouseSystem.new()
    var residence_count_before := SectResidenceSystemV1.all_houses(state).size()
    var cost: Dictionary = SectResidenceSystemV1.build_cost(state)
    var sites := SectResidenceSiteV1.available_plots(state)
    if not _ok(residence_count_before == 1 and not sites.is_empty()
            and bool(SectResidenceSystemV1.can_construct(state, sites[0]).get("ok", false)),
            "fresh canonical state has no legal paid Residence site"):
        return
    var wood_before := warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_WOOD))
    var ore_before := warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_ORE))
    var stones_before := state.sect.spirit_stones
    var build := SectResidenceSystemV1.construct(state, "r3_build_residence_002", sites[0])
    if not _ok(bool(build.get("ok", false)) and str(build.get("building_id", "")) == "residence_002"
            and SectResidenceSystemV1.all_houses(state).size() == 2,
            "canonical Residence build transaction failed: " + str(build)):
        return
    var buildEventsAfterCommit := state.building_event_count
    var replay_build := SectResidenceSystemV1.construct(state, "r3_build_residence_002", sites[0])
    if not _ok(bool(replay_build.get("ok", false)) and bool(replay_build.get("already_settled", false))
            and state.building_event_count == buildEventsAfterCommit,
            "Residence build replay was not idempotent"):
        return
    if not _ok(warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_WOOD))
                == wood_before - int(cost.get(BuildingSystem.MATERIAL_WOOD, 0))
            and warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_ORE))
                == ore_before - int(cost.get(BuildingSystem.MATERIAL_ORE, 0))
            and state.sect.spirit_stones == stones_before - int(cost.get("spirit_stones", 0)),
            "Residence did not debit its exact canonical Warehouse/treasury cost"):
        return
    var construction_ticks := SectResidenceSystemV1.construction_duration_ticks(2)
    var advanced := runtime.poll(NOW + construction_ticks * 60)
    var annex: BuildingState = state.buildings.get("residence_002")
    if not _ok(bool(advanced.get("ok", false)) and int(advanced.get("steps_run", 0)) >= construction_ticks
            and annex != null and annex.status == BuildingSystem.STATUS_ACTIVE
            and SectResidenceSystemV1.total_beds(state) == SectResidenceSystemV1.START_BEDS * 2,
            "simulated canonical time did not complete the paid Residence and add beds"):
        return

    var mine := BuildingSystem.new().primary_building(state, BuildingSystem.TYPE_MINE)
    var workers := BuildingSystem.new().active_worker_ids(state, mine) if mine != null else []
    if not _ok(mine != null and not workers.is_empty(),
            "New Game has no canonical active Mine worker"):
        return
    var miner: DiscipleState = state.disciples[workers[0]]
    var ore_before_work := warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_ORE))
    var batch_count_before := int(mine.metrics.get("production_batches", 0))
    var mining_done := false
    for _step in range(80):
        var result := WorkforceSystem.new().perform_work(state, miner, WorkforceSystem.PROF_MINING)
        if not _ok(bool(result.get("ok", false)),
                "real canonical Mine work step failed: " + str(result)):
            return
        if bool(result.get("completed", false)):
            mining_done = str(result.get("deposited_to", "")) == "sect_main_warehouse"
            break
    if not _ok(mining_done and warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_ORE)) > ore_before_work
            and int(mine.metrics.get("production_batches", 0)) > batch_count_before,
            "Mine did not produce and deposit a real batch into the canonical Warehouse"):
        return

    var candidates: Array = state.recruitment_candidates.keys()
    candidates.sort()
    var hunter_id := StringName(str(candidates[0])) if not candidates.is_empty() else &""
    if not _ok(hunter_id != &"" and DiscipleBirthProfileV2.valid_complete_birth(
            state.recruitment_candidates[hunter_id].v2_birth_profile),
            "New Game lacks a genuine P37Factory V2 recruit candidate"):
        return
    var recruit := RecruitmentSystem.new().accept_candidate(state, hunter_id)
    var hunter: DiscipleState = state.disciples.get(hunter_id)
    if not _ok(bool(recruit.get("ok", false)) and hunter != null
            and state.disciples.size() == 7 and DiscipleRealmProgressV2.progression_ready(hunter),
            "canonical recruitment did not add the actual V2 hunter"):
        return
    var topology := _world()
    if not _ok(bool(topology.get("ok", false)) and topology.get("camp_positions", []).size() == 20,
            "PvE topology was not derived from the Source A navigation grid"):
        return
    var deployed := PveP0CommandsV1.deploy(runtime.owner, ENCOUNTER_ID, SEED,
        [str(hunter_id)], topology)
    var session := runtime.owner.get_active_multicamp_session(ENCOUNTER_ID)
    if not _ok(bool(deployed.get("ok", false)) and session != null
            and session.battle._count_alive("monster") == 10,
            "real recruited V2 hunter could not enter canonical 20-zone P0 PvE"):
        return
    var initial_progress := DiscipleRealmProgressV2.current(hunter)
    var kill_ids: Array[String] = []
    for key in session.battle.actors.keys():
        if str(session.battle.actors[key].get("side", "")) == "monster":
            kill_ids.append(str(key))
    kill_ids.sort()
    if not _ok(kill_ids.size() == 10, "PvE did not spawn ten authentic catalogue monsters"):
        return
    var first_event: Dictionary = {}
    for index in range(kill_ids.size()):
        var target := kill_ids[index]
        var damage := session.battle.apply_continuous_damage_tick(
            str(hunter_id), target, "r3_hp0_%02d" % index, 2000.0)
        var pending := session.battle.pending_kill_events()
        if not _ok(bool(damage.get("ok", false)) and pending.size() == 1
                and float(session.battle.actors[target].get("hp", 1.0)) == 0.0,
                "combat kernel did not produce a genuine unique HP0 event for " + target):
            return
        if index == 0:
            first_event = pending[0].duplicate(true)
        var settled := session._record_open_world_kills()
        if not _ok(bool(settled.get("ok", false)) and int(settled.get("recorded", 0)) == 1
                and session.battle.pending_kill_events().is_empty(),
                "canonical exact-once loot/XP receipt commit failed: " + str(settled)):
            return
    var receipts: Dictionary = session.camp_population.get("p0_kill_rewards", {})
    var after_progress := DiscipleRealmProgressV2.current(hunter)
    var goods_after_loot := state.sect.warehouse_resources.duplicate(true)
    var duplicate := PvePerKillRewardV1.commit(state, session.battle,
        session.camp_population, first_event, SEED)
    if not _ok(receipts.size() == 10 and int(session.camp_population.get("world_total_kills", 0)) == 10
            and after_progress != initial_progress and bool(duplicate.get("duplicate", false))
            and state.sect.warehouse_resources == goods_after_loot,
            "ten kills did not persist exact-once receipts/XP/materials"):
        return
    if not _ok(bool(runtime.owner.cache_active_multicamp_session(session)),
            "active world could not be attached to its single SaveService owner"):
        return
    var saved := runtime.save(NOW + construction_ticks * 60)
    if not _ok(bool(saved.get("ok", false)) and FileAccess.file_exists(SAVE_PATH),
            "SaveService failed phase-1 one-lineage checkpoint: " + str(saved)):
        return
    var manifest := {
        "save_path": SAVE_PATH,
        "residence_count": SectResidenceSystemV1.all_houses(state).size(),
        "residence_id": "residence_002",
        "residence_build_receipt_count": state.sect.hall_governance.get("residence_build_receipts", {}).size(),
        "mine_id": str(mine.id),
        "mine_batches": int(mine.metrics.get("production_batches", 0)),
        "mine_warehouse_ore": warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_ORE)),
        "hunter_id": str(hunter_id),
        "roster_count": state.disciples.size(),
        "pve_kills": int(session.camp_population.get("world_total_kills", 0)),
        "pve_receipts": receipts.size(),
        "cultivation_xp": after_progress["cultivation"]["xp"],
        "body_xp": after_progress["body"]["xp"],
        "warehouse": state.sect.warehouse_resources.duplicate(true),
        "first_kill": first_event
    }
    if not _ok(_write_json(EXPECTED_PATH, manifest), "phase-1 expected-state witness could not be written"):
        return
    print("ONE_GAME_R3_PHASE1_NEW_GAME_PRODUCTION_PVE_SAVE_PASS " + JSON.stringify(manifest))
    print("ONE_GAME_R3_PHASE1_CHECKS=%d" % checks)
    quit(0)

func _continue_after_cold_reload() -> void:
    var expected := _read_json(EXPECTED_PATH)
    if not _ok(not expected.is_empty(), "cold reload expected-state witness is missing"):
        return
    var runtime := LiveGameRuntimeV2.new()
    var opened := runtime.start(SAVE_PATH, NOW + 3600)
    if not _ok(bool(opened.get("ok", false)) and bool(opened.get("loaded", false)),
            "separate process could not cold-load phase-1 SaveService state: " + str(opened)):
        return
    var state: SimulationState = runtime.state()
    var warehouse := WarehouseSystem.new()
    var mine: BuildingState = state.buildings.get(str(expected["mine_id"]))
    var hunter_id := StringName(str(expected["hunter_id"]))
    var hunter: DiscipleState = state.disciples.get(hunter_id)
    print("ONE_GAME_R3_RELOAD_DIAGNOSTIC " + JSON.stringify({
        "residences": SectResidenceSystemV1.all_houses(state).size(),
        "expected_residences": int(expected["residence_count"]),
        "receipts": state.sect.hall_governance.get("residence_build_receipts", {}).size(),
        "expected_receipts": int(expected["residence_build_receipt_count"]),
        "mine_found": mine != null,
        "mine_batches": int(mine.metrics.get("production_batches", 0)) if mine != null else -1,
        "expected_mine_batches": int(expected["mine_batches"]),
        "hunter_found": hunter != null,
        "roster": state.disciples.size(),
        "expected_roster": int(expected["roster_count"]),
        "warehouse": state.sect.warehouse_resources,
        "expected_warehouse": expected["warehouse"]
    }))
    if not _ok(SectResidenceSystemV1.all_houses(state).size() == int(expected["residence_count"])
            and state.sect.hall_governance.get("residence_build_receipts", {}).size() == int(expected["residence_build_receipt_count"])
            and mine != null and int(mine.metrics.get("production_batches", 0)) == int(expected["mine_batches"])
            and hunter != null and state.disciples.size() == int(expected["roster_count"])
            and _same_resource_map(state.sect.warehouse_resources, expected["warehouse"]),
            "cold reload changed Residence/receipt/Mine/roster/Warehouse values"):
        return
    var restored := HuntingPveRunV2.resume_active(state, ENCOUNTER_ID)
    if not _ok(bool(restored.get("ok", false)), "cold reload did not restore the active open world"):
        return
    var session: HuntingPveRunV2 = restored["session"]
    if not _ok(bool(runtime.owner.cache_active_multicamp_session(session)),
            "cold-reloaded world session could not be attached to the runtime owner"):
        return
    var receipts: Dictionary = session.camp_population.get("p0_kill_rewards", {})
    if not _ok(receipts.size() == 10 and int(session.camp_population.get("world_total_kills", 0)) == 10
            and session.battle.pending_kill_events().is_empty()
            and DiscipleRealmProgressV2.current(hunter)["cultivation"]["xp"] == expected["cultivation_xp"]
            and DiscipleRealmProgressV2.current(hunter)["body"]["xp"] == expected["body_xp"],
            "cold reload lost HP0 receipts, XP, or journal exactly-once state"):
        return

    # Continue genuine Mine work after process restart and assert Warehouse
    # output changes only when the canonical travel/extract/haul cycle deposits.
    var miner_ids := BuildingSystem.new().active_worker_ids(state, mine)
    if not _ok(not miner_ids.is_empty(), "cold reload did not retain an assigned real Mine worker"):
        return
    var miner: DiscipleState = state.disciples[miner_ids[0]]
    var ore_before := warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_ORE))
    var batches_before := int(mine.metrics.get("production_batches", 0))
    var produced := false
    for _step in range(80):
        var work := WorkforceSystem.new().perform_work(state, miner, WorkforceSystem.PROF_MINING)
        if not _ok(bool(work.get("ok", false)), "post-reload canonical Mine work failed: " + str(work)):
            return
        if bool(work.get("completed", false)):
            produced = str(work.get("deposited_to", "")) == "sect_main_warehouse"
            break
    if not _ok(produced and warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_ORE)) > ore_before
            and int(mine.metrics.get("production_batches", 0)) == batches_before + 1,
            "production did not continue exactly once after cold reload"):
        return

    var first_event: Dictionary = expected["first_kill"]
    var old_slot := str(first_event.get("spawn_slot_id", ""))
    var old_receipt: Dictionary = receipts.get(old_slot, {})
    if not _ok(not old_slot.is_empty() and not old_receipt.is_empty(),
            "persisted first-life reward receipt is missing"):
        return
    var respawned := false
    for _frame in range(150):
        var step := session.advance(false)
        if not _ok(bool(step.get("ok", false)), "cold-reloaded PvE world stopped advancing: " + str(step)):
            return
        if int(session.camp_population["slots"][old_slot].get("generation", 0)) >= 2:
            respawned = true
            break
    var slot: Dictionary = session.camp_population["slots"][old_slot]
    var second_id := ENCOUNTER_ID + "/" + old_slot + "/g2"
    if not _ok(respawned and str(slot.get("phase", "")) == "READY"
            and session.battle.actors.has(second_id),
            "persisted source world did not respawn a genuine generation-2 monster"):
        return
    var damage := session.battle.apply_continuous_damage_tick(
        str(hunter_id), second_id, "r3_hp0_generation2", 2000.0)
    var pending := session.battle.pending_kill_events()
    if not _ok(bool(damage.get("ok", false)) and pending.size() == 1
            and int(pending[0].get("slot_generation", 0)) == 2,
            "continued hunt did not produce generation-2 HP0"):
        return
    var secondEvent: Dictionary = pending[0].duplicate(true)
    var beforeSecondLoot := state.sect.warehouse_resources.duplicate(true)
    var authoritativeLife := PveMultiCampPopulationV1.record_authoritative_battle_kill(
        session.camp_population, session.battle, secondEvent, session.world_respawn_delay, true)
    if not _ok(bool(authoritativeLife.get("ok", false)),
            "generation-2 battle event was rejected by the canonical respawn ledger: " + str(authoritativeLife)):
        return
    var secondSettle := session._record_open_world_kills()
    var secondReceipt: Dictionary = receipts.get(old_slot, {})
    if not _ok(bool(secondSettle.get("ok", false)) and int(secondSettle.get("recorded", 0)) == 1
            and int(session.camp_population.get("world_total_kills", 0)) == 11
            and receipts.size() == 10 and int(secondReceipt.get("generation", 0)) == 2,
            "generation-2 HP0 did not replace the bounded slot receipt exactly once"):
        return
    var afterSecondLoot := state.sect.warehouse_resources.duplicate(true)
    var duplicate := PvePerKillRewardV1.commit(state, session.battle,
        session.camp_population, secondEvent, SEED)
    if not _ok(bool(duplicate.get("duplicate", false))
            and state.sect.warehouse_resources == afterSecondLoot
            and beforeSecondLoot != afterSecondLoot,
            "replayed generation-2 receipt minted duplicate materials"):
        return
    var checkpoint := session._persist_live_state()
    var saved := runtime.save(NOW + 3600)
    if not _ok(bool(checkpoint.get("ok", false)) and bool(saved.get("ok", false)),
            "SaveService failed the post-reload production/hunt continuation"):
        return
    var finalManifest := expected.duplicate(true)
    finalManifest["mine_batches"] = int(mine.metrics.get("production_batches", 0))
    finalManifest["mine_warehouse_ore"] = warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_ORE))
    finalManifest["pve_kills"] = int(session.camp_population.get("world_total_kills", 0))
    finalManifest["pve_receipts"] = receipts.size()
    finalManifest["warehouse"] = state.sect.warehouse_resources.duplicate(true)
    finalManifest["generation2_receipt"] = secondReceipt.duplicate(true)
    finalManifest["cultivation_xp"] = DiscipleRealmProgressV2.current(hunter)["cultivation"]["xp"]
    finalManifest["body_xp"] = DiscipleRealmProgressV2.current(hunter)["body"]["xp"]
    if not _ok(_write_json(FINAL_PATH, finalManifest), "final expected-state witness could not be written"):
        return
    print("ONE_GAME_R3_COLD_RELOAD_CONTINUED_PRODUCTION_HUNT_PASS " + JSON.stringify(finalManifest))
    print("ONE_GAME_R3_PHASE2_CHECKS=%d" % checks)
    quit(0)

func _verify_second_cold_reload() -> void:
    var expected := _read_json(FINAL_PATH)
    if not _ok(not expected.is_empty(), "final-state witness is missing"):
        return
    var runtime := LiveGameRuntimeV2.new()
    var opened := runtime.start(SAVE_PATH, NOW + 3600)
    if not _ok(bool(opened.get("ok", false)) and bool(opened.get("loaded", false)),
            "third independent Godot process could not load the same QA save"):
        return
    var state: SimulationState = runtime.state()
    var mine: BuildingState = state.buildings.get(str(expected["mine_id"]))
    var hunter: DiscipleState = state.disciples.get(StringName(str(expected["hunter_id"])))
    var restored := HuntingPveRunV2.resume_active(state, ENCOUNTER_ID)
    if not _ok(mine != null and int(mine.metrics.get("production_batches", 0)) == int(expected["mine_batches"])
            and SectResidenceSystemV1.all_houses(state).size() == int(expected["residence_count"])
            and int(state.sect.hall_governance.get("residence_build_receipts", {}).size()) == int(expected["residence_build_receipt_count"])
            and state.disciples.size() == int(expected["roster_count"])
            and hunter != null and _same_resource_map(state.sect.warehouse_resources, expected["warehouse"])
            and bool(restored.get("ok", false)),
            "second cold reload changed production, building, roster or Warehouse ledger"):
        return
    var session: HuntingPveRunV2 = restored["session"]
    var receipts: Dictionary = session.camp_population.get("p0_kill_rewards", {})
    var receipt: Dictionary = receipts.get(str(expected["generation2_receipt"].get("slot_id", "")), {})
    var errors := state.validate_invariants()
    if not _ok(int(session.camp_population.get("world_total_kills", 0)) == 11
            and receipts.size() == 10
            and receipt == expected["generation2_receipt"]
            and session.battle.pending_kill_events().is_empty()
            and DiscipleRealmProgressV2.current(hunter)["cultivation"]["xp"] == expected["cultivation_xp"]
            and DiscipleRealmProgressV2.current(hunter)["body"]["xp"] == expected["body_xp"]
            and errors.is_empty(),
            "final reload lost exact-once receipts/XP or violated canonical state invariants: " + str(errors)):
        return
    print("ONE_GAME_R3_THREE_PROCESS_SAME_SAVE_PASS " + JSON.stringify({
        "new_game": true, "paid_residence": expected["residence_id"],
        "mine_batches": expected["mine_batches"], "hunter": expected["hunter_id"],
        "hp0_kills": 11, "unique_slot_receipts": 10,
        "generation2_receipt_persisted": true, "warehouse_exact": true,
        "processes": 3, "save": ProjectSettings.globalize_path(SAVE_PATH)
    }))
    print("ONE_GAME_R3_PHASE3_CHECKS=%d" % checks)
    quit(0)
