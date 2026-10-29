extends SceneTree

const PREVIEW := {"sect_codex":true}

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, detail: String) -> bool:
    if not ok:
        push_error("V63_D2_REWARD_FAIL: "+detail)
        quit(1)
        return false
    return true

func _enabled_state() -> SimulationState:
    var state := SimulationState.new()
    state.p3_7_buildings_enabled = true
    state.sect.p3_7_resources_enabled = true
    state.sect.v63_archive_opt_in = true
    return state

func _run() -> void:
    var loaded := V63SectArchiveSystem.load_catalogue()
    if not _check(bool(loaded.get("ok",false)),"archive catalogue did not load"): return
    var codex: Dictionary = {}
    for row in loaded.data.codices:
        if bool(row.get("archivable",false)):
            codex = row
            break
    if not _check(not codex.is_empty(),"missing codex fixture"): return
    var fragment_id := StringName(codex.fragment_resource_id)
    var manual_id := StringName(codex.manual_item_id)
    var state := _enabled_state()
    var encounter_id := "d2-victory-001"
    var spawn := HuntingMapV2.spawn("thanh_truc_lam",1,encounter_id,777)
    if not _check(bool(spawn.get("ok",false)),"could not create existing V2 PvE reward fixture"): return
    spawn["v63_codex_rewards"] = {str(fragment_id):2,str(manual_id):1}
    var battle := MapBattleV2.new()
    battle.encounter_id = encounter_id
    battle.active = false
    battle.outcome = "win"
    var first := HuntingMapV2.claim_reward(state,spawn,battle,PREVIEW)
    if not _check(bool(first.get("ok",false)),"V2 victory claim rejected codex rewards: "+str(first)): return
    var warehouse := WarehouseSystem.new()
    var fragment_after := warehouse.quantity(state,fragment_id)
    var manual_after := warehouse.quantity(state,manual_id)
    if not _check(fragment_after==2 and manual_after==1,"victory reward did not reach the canonical Warehouse exactly once"): return
    var victory_key := encounter_id+":victory"
    if not _check(state.sect.v63_codex_drop_receipts.has(victory_key),"victory did not persist its codex reward receipt"): return
    var duplicate_claim := HuntingMapV2.claim_reward(state,spawn,battle,PREVIEW)
    if not _check(not bool(duplicate_claim.get("ok",false)) and warehouse.quantity(state,fragment_id)==fragment_after and warehouse.quantity(state,manual_id)==manual_after,"victory retry duplicated resources"): return

    var legacy_state := _enabled_state()
    legacy_state.sect.v63_archive_opt_in = false
    var gated := HuntingMapV2.claim_reward(legacy_state,spawn,battle)
    if not _check(not bool(gated.get("ok",false)) and warehouse.quantity(legacy_state,fragment_id)==0,"feature-gated payload was silently granted or stored"): return

    var world_state := _enabled_state()
    var world_id := "d2-world-001"
    var slot_id := PveMultiCampPopulationV1.slot_id(0,0)
    var kill_id := "%s:slot:%s:g1" % [world_id,slot_id]
    var population := PveMultiCampPopulationV1.new_registry(10)
    var hp0 := PveMultiCampPopulationV1.record_hp0(population,slot_id,1,kill_id,true,1.0,30.0)
    if not _check(bool(hp0.get("ok",false)),"could not create authoritative pending kill receipt"): return
    var drop_items := {str(fragment_id):3,str(manual_id):1}
    var settled := V63SectArchiveSystem.settle_codex_kill_drop_once(
        world_state,world_id,kill_id,"test_species",drop_items,PREVIEW)
    if not _check(bool(settled.get("ok",false)) and not bool(settled.get("duplicate",false)),"first kill receipt settlement failed: "+str(settled)): return
    var ack := PveMultiCampPopulationV1.acknowledge_codex_reward_receipt(population,slot_id,kill_id,kill_id)
    if not _check(bool(ack.get("ok",false)) and bool(ack.get("rewards_granted",false)),"population did not acknowledge settled codex reward"): return
    var duplicate_settlement := V63SectArchiveSystem.settle_codex_kill_drop_once(
        world_state,world_id,kill_id,"test_species",drop_items,PREVIEW)
    var duplicate_ack := PveMultiCampPopulationV1.acknowledge_codex_reward_receipt(population,slot_id,kill_id,kill_id)
    if not _check(bool(duplicate_settlement.get("duplicate",false)) and bool(duplicate_ack.get("already_acknowledged",false)),"open-world retry did not return the same paid receipt"): return
    if not _check(warehouse.quantity(state,fragment_id)==fragment_after,"per-kill receipt mutated the unrelated encounter state"): return
    var world_warehouse := WarehouseSystem.new()
    if not _check(world_warehouse.quantity(world_state,fragment_id)==3 and world_warehouse.quantity(world_state,manual_id)==1,"open-world kill did not pay one canonical Warehouse receipt"): return
    var changed_retry := V63SectArchiveSystem.settle_codex_kill_drop_once(
        world_state,world_id,kill_id,"test_species",{str(fragment_id):4},PREVIEW)
    if not _check(not bool(changed_retry.get("ok",false)) and world_warehouse.quantity(world_state,fragment_id)==3,"same receipt id accepted a changed payout"): return

    var before_invalid: Dictionary = world_state.sect.warehouse_resources.duplicate(true)
    var invalid := V63SectArchiveSystem.settle_codex_kill_drop_once(
        world_state,world_id,world_id+":slot:other:g1","test_species",
        {str(fragment_id):2,"unknown_codex_material":1},PREVIEW)
    if not _check(not bool(invalid.get("ok",false)) and world_state.sect.warehouse_resources==before_invalid,"invalid payload partially mutated Warehouse state"): return

    var integrated_state := _enabled_state()
    var integrated_id := "d2-open-world-integrated"
    var integrated_slot := PveMultiCampPopulationV1.slot_id(0,0)
    var integrated_population := PveMultiCampPopulationV1.new_registry(10)
    var integrated_battle := MapBattleV2.new()
    integrated_battle.encounter_id = integrated_id
    integrated_battle.continuous_mode = true
    integrated_battle.world_mode = true
    integrated_battle.now = 1.0
    var monster := {"id":"d2_monster_1","side":"monster","hp":0.0,
        "spawn_slot_id":integrated_slot,"slot_generation":1,"species_id":"test_species"}
    integrated_battle.actors["d2_monster_1"] = monster.duplicate(true)
    integrated_battle._record_monster_kill({"id":"d2_disciple"},monster,"basic",100.0)
    var session := HuntingPveRunV2.new()
    session.owner_state = integrated_state
    session.battle = integrated_battle
    session.spawn_data = {"v63_codex_drop_table":{"test_species":{str(fragment_id):1}}}
    session.camp_population = integrated_population
    session.world_respawn_delay = 30.0
    session.v63_preview_overrides = PREVIEW
    integrated_state.sect.p3_7_resources_enabled = false
    var failed_first_attempt := session._record_open_world_kills()
    var pending_slot: Dictionary = integrated_population.slots[integrated_slot]
    if not _check(not bool(failed_first_attempt.get("ok",false)) and str(pending_slot.get("phase",""))=="UNPAID_HP0" and integrated_battle.pending_kill_events().size()==1,"failed Warehouse settlement did not keep the authoritative kill pending for retry"): return
    integrated_state.sect.p3_7_resources_enabled = true
    var integrated_result := session._record_open_world_kills()
    if not _check(bool(integrated_result.get("ok",false)) and bool(integrated_result.get("codex_rewards_granted",false)),"open-world run did not settle the authored codex reward"): return
    var integrated_slot_state: Dictionary = integrated_population.slots[integrated_slot]
    if not _check(str(integrated_slot_state.get("phase",""))=="COOLDOWN" and str(integrated_slot_state.get("reward_disposition",""))=="CODEX_SETTLED" and integrated_battle.pending_kill_events().is_empty(),"open-world population and combat journals were not acknowledged together"): return
    if not _check(WarehouseSystem.new().quantity(integrated_state,fragment_id)==1,"open-world run did not deposit through the canonical Warehouse"): return
    var integrated_restored := SimulationState.from_dict(integrated_state.to_dict())
    if not _check(integrated_restored.sect.v63_codex_drop_receipts==integrated_state.sect.v63_codex_drop_receipts and WarehouseSystem.new().quantity(integrated_restored,fragment_id)==1,"open-world receipt or payout did not survive save/load"): return

    var restored := SimulationState.from_dict(world_state.to_dict())
    if not _check(restored.sect.v63_codex_drop_receipts==world_state.sect.v63_codex_drop_receipts,"kill reward receipt did not survive save/load"): return
    if not _check(restored.sect.warehouse_resources==world_state.sect.warehouse_resources,"kill reward inventory did not survive save/load"): return
    print("V63_D2_REWARD_PASS: victory and per-kill receipts settle through one Warehouse; retries, changed payload, gated payload, partial failure and save/load covered")
    quit(0)

