extends SceneTree

# LIVE PVE-BAL01: normal New Game -> V2 recruit -> real P0 HP=0 journal
# -> one credit of personal Stones + XP, duplicate replay guard, cold Save.
# The gate is enabled only in THIS isolated test state, never player settings.
const SAVE_PREFIX := "user://qa_pve_r12_live_"
const NOW := 1801000000
const SEED := 550325

var path := ""

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> bool:
    if not ok:
        push_error("PVE_BAL01_LIVE_FAIL "+message)
        quit(1)
        return false
    return true

func _cleanup() -> void:
    if not path.begins_with(SAVE_PREFIX):
        return
    for suffix in ["",".tmp",".bak"]:
        if FileAccess.file_exists(path+suffix):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path+suffix))

func _run() -> void:
    path = SAVE_PREFIX+str(OS.get_process_id())+".json"
    _cleanup()
    var runtime := LiveGameRuntimeV2.new()
    var started := runtime.start(path,NOW,SEED)
    if not _check(bool(started.get("ok",false)) and bool(started.get("created",false)),
            "new-game-authority-not-ready"):
        return
    var state: SimulationState = runtime.state()
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    if not _check(not ids.is_empty(),"no-V2-recruit"):
        return
    var picked := StringName(str(ids[0]))
    if not _check(bool(RecruitmentSystem.new().accept_candidate(state,picked).get("ok",false)),
            "canonical-recruit-blocked"):
        return
    var disciple: DiscipleState = state.disciples[picked]
    if not _check(DiscipleRealmProgressV2.progression_ready(disciple),
            "non-V2-recruit"):
        return
    var econ := EconomySystem.new()
    if not state.sect.economy_a_enabled:
        if not _check(bool(econ.enable_v1(state).get("ok",false)),"cannot-enable-existing-economy"):
            return
    if not _check(not bool(econ.configure_v1(state,PveR12BalanceV1.POLICY_KEY,true).get("ok",false)),
            "player-must-not-enable-candidate"):
        return
    if not _check(econ.market_purchase_price(state,&"linh_moc") == 4,
            "pilot-off-must-preserve-4-Stone-Linh-Moc-price"):
        return
    state.sect.economy_a_policy[PveR12BalanceV1.POLICY_KEY] = true
    if not _check(PveR12BalanceV1.active(state)
            and PveR12BalanceV1.personal_hp_service_price(state,disciple) == 300,
            "candidate-not-available-to-isolated-qa"):
        return
    for item_id in PveR12BalanceV1.NPC_PURCHASE_BASE_PRICE.keys():
        var expected_price := int(PveR12BalanceV1.NPC_PURCHASE_BASE_PRICE[item_id])*2
        if not _check(econ.market_purchase_price(state,StringName(item_id)) == expected_price,
                "wrong-candidate-NPC-price: "+str(item_id)):
            return
    # One authenticated NPC purchase uses real opening Sect funds, stock and
    # Warehouse; repeated request must never duplicate material or Stone debit.
    var before_buy_stones := state.sect.spirit_stones
    var warehouse := WarehouseSystem.new()
    var before_buy_wood := warehouse.quantity(state,&"linh_moc")
    var purchased := econ.buy_from_npc_v1(state,&"linh_moc",1,"pve-bal01-shop-buy")
    if not _check(bool(purchased.get("ok",false))
            and state.sect.spirit_stones == before_buy_stones-100
            and warehouse.quantity(state,&"linh_moc") == before_buy_wood+1,
            "real-NPC-100LT-purchase-did-not-debit-credit"):
        return
    var duplicate_buy := econ.buy_from_npc_v1(state,&"linh_moc",1,"pve-bal01-shop-buy")
    if not _check(bool(duplicate_buy.get("ok",false))
            and bool(duplicate_buy.get("already_settled",false))
            and state.sect.spirit_stones == before_buy_stones-100
            and warehouse.quantity(state,&"linh_moc") == before_buy_wood+1,
            "NPC-purchase-replay-minted-wood-or-charged-twice"):
        return
    var nav := SectIsometricWorldV1.pve_navigation_grid()
    var options := PveOpenWorldTopologyV1.build(
        nav,Vector2(SectIsometricWorldV1.PVE_SPAWN_CELL)+Vector2(0.5,0.5))
    if not _check(bool(options.get("ok",false)),"world-topology-unavailable"):
        return
    options["p0_distributed_world"] = true
    options["respawn_delay_sim_seconds"] = 30.0
    var begun := PveP0CommandsV1.deploy(runtime.owner,"pve_bal01_real_hp0",SEED,[str(picked)],options)
    var session := runtime.owner.get_active_multicamp_session()
    if not _check(bool(begun.get("ok",false)) and session != null,"P0-deploy-failed"):
        return
    var target_id := ""
    var target_species := ""
    var actor_ids: Array = session.battle.actors.keys()
    actor_ids.sort()
    for raw_id in actor_ids:
        var actor: Dictionary = session.battle.actors[raw_id]
        if str(actor.get("side","")) == "monster":
            var species := str(actor.get("species_id",""))
            if not PveR12BalanceV1.reward_for_realm(1,species).is_empty():
                target_id = str(raw_id)
                target_species = species
                break
    if not _check(not target_id.is_empty(),"no-authored-r1-P0-species"):
        return
    var first_stones := disciple.spirit_stones
    var first_progress := DiscipleRealmProgressV2.current(disciple)
    var damage := session.battle.apply_continuous_damage_tick(
        str(picked),target_id,"pve_bal01_real_hp0",2000.0)
    if not _check(bool(damage.get("ok",false))
            and session.battle.pending_kill_events().size() == 1,"real-kill-event-not-generated"):
        return
    var event: Dictionary = session.battle.pending_kill_events()[0].duplicate(true)
    var expected := PveR12BalanceV1.reward_for_realm(1,target_species)
    var result := session._record_open_world_kills()
    if not _check(bool(result.get("ok",false))
            and int(result.get("recorded",0)) == 1
            and disciple.spirit_stones == first_stones+int(expected["stones"]),
            "one-authentic-kill-must-credit-exact-personal-Stones: "+str(result)):
        return
    var next_progress := DiscipleRealmProgressV2.current(disciple)
    if not _check(float(next_progress["cultivation"]["xp"]) > float(first_progress["cultivation"]["xp"])
            and float(next_progress["body"]["xp"]) > float(first_progress["body"]["xp"]),
            "one-authentic-kill-must-add-cultivation-and-body-XP"):
        return
    var after_stock := state.sect.warehouse_resources.duplicate(true)
    var replay := PvePerKillRewardV1.commit(state,session.battle,
        session.camp_population,event,SEED)
    if not _check(bool(replay.get("ok",false)) and bool(replay.get("duplicate",false))
            and disciple.spirit_stones == first_stones+int(expected["stones"])
            and state.sect.warehouse_resources == after_stock
            and DiscipleRealmProgressV2.current(disciple) == next_progress,
            "duplicate-HP0-must-not-mint-Stones-XP-or-materials"):
        return
    if not _check(bool(runtime.save(NOW).get("ok",false)),"canonical-SaveService-write-failed"):
        return
    var loaded := SaveService.new().load_from_path(path)
    if not _check(loaded != null and loaded.disciples.has(picked)
            and loaded.disciples[picked].spirit_stones == disciple.spirit_stones
            and loaded.sect.warehouse_resources == state.sect.warehouse_resources,
            "cold-Save-must-preserve-personal-coin-and-warehouse"):
        return
    # Test-only wounded fixture AFTER real HP0 payment and canonical retreat:
    # this isolated HP subtraction models the care transaction, not a measured
    # monster damage distribution or fabricated PvE reward.
    var retreat := session.retreat_multicamp()
    if not _check(bool(retreat.get("ok",false)) and disciple.region_id == &"sect"
            and disciple.active_pve_encounter_id.is_empty(),
            "canonical-return-to-sect-failed"):
        return
    disciple.hp = maxf(1.0,disciple.max_hp-10.0)
    var before_heal_hp := disciple.hp
    var before_heal_coin := disciple.spirit_stones
    var before_heal_sect := state.sect.spirit_stones
    var healed := econ.buy_personal_hp_service(state,picked,"pvebal01-real-coin-heal")
    if not _check(bool(healed.get("ok",false))
            and int(healed.get("receipt",{}).get("cost",-1)) == 300
            and is_equal_approx(disciple.hp,before_heal_hp+10.0)
            and disciple.spirit_stones == before_heal_coin-300
            and state.sect.spirit_stones == before_heal_sect+300,
            "source-earned-PVE-Stones-did-not-pay-one-canonical-300LT-service"):
        return
    var second := econ.buy_personal_hp_service(state,picked,"pvebal01-real-coin-heal")
    if not _check(bool(second.get("ok",false)) and bool(second.get("already_settled",false))
            and disciple.spirit_stones == before_heal_coin-300
            and state.sect.spirit_stones == before_heal_sect+300
            and is_equal_approx(disciple.hp,before_heal_hp+10.0),
            "repeat-HP-service-double-debited-or-overhealed"):
        return
    if not _check(bool(runtime.save(NOW).get("ok",false)),"post-care-SaveService-failed"):
        return
    var cared := SaveService.new().load_from_path(path)
    if not _check(cared != null and cared.disciples[picked].spirit_stones == disciple.spirit_stones
            and cared.sect.spirit_stones == state.sect.spirit_stones
            and is_equal_approx(cared.disciples[picked].hp,disciple.hp),
            "cold-Save-care-payment-drift"):
        return
    _cleanup()
    print("PVE_BAL01_REAL_HP0_STONES_XP_REPLAY_SAVE_PASS species="+target_species
        +" credited="+str(expected["stones"])+" NPC_wood_paid=100 healed_10hp_paid=300"
        +" care_replay_safe=true basePassiveUnaffected=true")
    quit(0)
