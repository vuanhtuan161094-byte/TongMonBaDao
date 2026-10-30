extends SceneTree

const PREVIEW := {"sect_codex":true}

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, detail: String) -> bool:
    if not ok:
        push_error("ONE_GAME_R2_CODEX_FAIL: "+detail)
        quit(1)
        return false
    return true

func _run() -> void:
    var catalogue := V63SectArchiveSystem.load_catalogue()
    if not _check(bool(catalogue.get("ok",false)),"archive catalogue did not load"): return
    var codex: Dictionary = {}
    for row in catalogue.data.codices:
        if bool(row.get("archivable",false)):
            codex = row
            break
    if not _check(not codex.is_empty(),"no codex drop fixture"): return

    var state := SimulationState.new()
    state.p3_7_buildings_enabled = true
    state.sect.p3_7_resources_enabled = true
    state.sect.v63_archive_opt_in = true

    var encounter_id := "one-game-r2-open-world"
    var slot_id := PveMultiCampPopulationV1.slot_id(0,0)
    var population := PveMultiCampPopulationV1.new_registry(10)
    if not _check(bool(population.get("ok",false)),"could not create canonical camp population"): return

    var battle := MapBattleV2.new()
    battle.encounter_id = encounter_id
    battle.continuous_mode = true
    battle.world_mode = true
    battle.now = 1.0
    var monster := {"id":"d2_monster_1","side":"monster","hp":0.0,"max_hp":10.0,
        "spawn_slot_id":slot_id,"slot_generation":1,"species_id":"test_species"}
    battle.actors["d2_monster_1"] = monster.duplicate(true)
    battle._record_monster_kill({"id":"d2_disciple"},monster,"basic",100.0)
    var pending := battle.pending_kill_events()
    if not _check(pending.size()==1,"Combat V2 did not emit a pending HP0 journal"): return
    var kill_id := str(pending[0].get("kill_id",""))
    var items := {str(codex.fragment_resource_id):1}

    var session := HuntingPveRunV2.new()
    session.owner_state = state
    session.battle = battle
    session.spawn_data = {"v63_codex_drop_table":{"test_species":items.duplicate(true)}}
    session.camp_population = population
    session.world_respawn_delay = 30.0
    session.v63_preview_overrides = PREVIEW

    state.sect.p3_7_resources_enabled = false
    var failed := session._record_open_world_kills()
    var slot_after_failure: Dictionary = population.slots[slot_id]
    if not _check(not bool(failed.get("ok",false)) and str(slot_after_failure.get("phase",""))=="UNPAID_HP0" and battle.pending_kill_events().size()==1,
            "failed Warehouse settlement did not retain the original HP0 event for retry"): return

    state.sect.p3_7_resources_enabled = true
    var settled := session._record_open_world_kills()
    var slot_after_settlement: Dictionary = population.slots[slot_id]
    var warehouse := WarehouseSystem.new()
    if not _check(bool(settled.get("ok",false)) and bool(settled.get("codex_rewards_granted",false)),
            "open-world V63 codex reward did not settle"): return
    if not _check(str(slot_after_settlement.get("phase",""))=="COOLDOWN" and
            str(slot_after_settlement.get("reward_disposition",""))=="CODEX_SETTLED" and
            str(slot_after_settlement.get("reward_receipt_id",""))==kill_id and
            battle.pending_kill_events().is_empty(),
            "population and Combat V2 receipt acknowledgements did not commit together"): return
    if not _check(warehouse.quantity(state,StringName(codex.fragment_resource_id))==1,
            "codex fragment did not reach the single canonical Warehouse"): return

    var duplicate := V63SectArchiveSystem.settle_codex_kill_drop_once(
        state,encounter_id,kill_id,"test_species",items,PREVIEW)
    if not _check(bool(duplicate.get("ok",false)) and bool(duplicate.get("duplicate",false)) and
            warehouse.quantity(state,StringName(codex.fragment_resource_id))==1,
            "retry duplicated the settled Warehouse reward"): return

    var changed := V63SectArchiveSystem.settle_codex_kill_drop_once(
        state,encounter_id,kill_id,"test_species",
        {str(codex.fragment_resource_id):2},PREVIEW)
    if not _check(not bool(changed.get("ok",false)) and
            warehouse.quantity(state,StringName(codex.fragment_resource_id))==1,
            "same receipt ID accepted a changed payout"): return

    var restored := SimulationState.from_dict(state.to_dict())
    if not _check(restored != null and
            restored.sect.v63_codex_drop_receipts==state.sect.v63_codex_drop_receipts and
            WarehouseSystem.new().quantity(restored,StringName(codex.fragment_resource_id))==1,
            "codex receipt and Warehouse inventory did not survive save/load"): return
    print("ONE_GAME_R2_CODEX_PASS: Combat V2 HP0 -> one Warehouse receipt; retry-safe after failed settlement; exact-once save/load")
    quit(0)
