extends SceneTree

# Exact 30-realm source values. Real Mine -> Forest -> Field Warehouse receipts,
# earned gross to Disciple, site-tax transfer to Sect, paid W2 from Sect,
# cold Save, one receipt per job. Economic activation is QA-ONLY; public OFF.
const SAVE_PATH := "user://sx_v55_r12_real_labor_tax_wage_save_test.json"
var economy := EconomySystem.new()
var buildings := BuildingSystem.new()
var warehouse := WarehouseSystem.new()
var workforce := WorkforceSystem.new()

func _init() -> void:
    call_deferred("_run")

func _check(condition: bool, message: String) -> bool:
    if not condition:
        push_error("SX-V55 R12 GENUINE INCOME TAX WAGE FAIL: "+message)
        quit(1)
        return false
    return true

func _reload(state: SimulationState) -> SimulationState:
    var saver := SaveService.new()
    if saver.save_to_path(state,SAVE_PATH) != OK:
        return null
    return saver.load_from_path(SAVE_PATH)

func _run() -> void:
    _cleanup()
    var raw = JSON.parse_string(FileAccess.get_file_as_string(
        "res://data/economy/v55d_30_realm_reference.json"))
    if not _check(raw is Dictionary and raw.get("runtime_activation",true) == false
        and (raw.get("realms",[]) as Array).size() == 30,
        "30 source rows must remain DESIGN_ONLY and runtime off"):
        return
    var rows: Array = raw["realms"]
    if not _check(int(rows[0].get("lt2_per_minute",0)) == 1000
        and int(rows[1].get("lt2_per_minute",0)) == 2000
        and int(rows[0].get("w2_min_wage_per_job",0)) == 2000
        and int(rows[1].get("w2_min_wage_per_job",0)) == 4000,
        "the first two earned rates differ from the original 30-realm sheet"):
        return
    var state := P37Factory.create_state(5521012)
    if not _check(bool(economy.enable_v1(state).get("ok",false))
        and bool(buildings.sx_v55_enable_bulk(state).get("ok",false))
        and not economy.sx_v55_r12_enabled(state),
        "R12 must default OFF even after genuine owner bulk opt-in"):
        return
    if not _check(not bool(economy.configure_v1(state,
        EconomySystem.SX_V55_R12_POLICY,true).get("ok",false)),
        "player control must not open unfunded economy pilot"):
        return
    state.sect.disciple_v2_birth_enabled = true
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    var founding: Array = state.disciples.keys()
    founding.sort()
    for raw_id in founding:
        if not _check(workforce.assign_group(state,StringName(raw_id),&""),
            "cannot release original worker"):
            return
    state.sect.disciple_capacity = state.disciples.size()+1
    var recruit := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,455)
    if not _check(recruit != null,"failed to generate legitimate V2 worker"):
        return
    state.recruitment_candidates[recruit.id] = recruit
    if not _check(bool(RecruitmentSystem.new().accept_candidate(
        state,recruit.id).get("ok",false)),
        "actual V2 recruitment rejected"):
        return
    var actor: DiscipleState = state.disciples[recruit.id]
    if not _check(DiscipleRealmProgressV2.progression_ready(actor)
        and int(actor.v2_realm_progress["cultivation"]["realm"]) == 1,
        "pilot requires authentic grade-1 V2 actor"):
        return
    # Internal QA-only gate; no UI/button/configure_v1 can set it.
    state.sect.economy_a_policy[EconomySystem.SX_V55_R12_POLICY] = true
    if not _check(economy.sx_v55_r12_enabled(state),
        "real-source R12 test authorization failed"):
        return

    var mine := buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    var forest := buildings.primary_building(state,BuildingSystem.TYPE_LINH_FOREST)
    var field := buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    if not _check(mine != null and forest != null and field != null,
        "canonical producers absent"):
        return
    if not _check(workforce.assign_group(state,actor.id,&"mining_crew")
        and workforce.assign_worksite(state,actor.id,mine.id),
        "real mining appointment failed"):
        return
    if not _check(bool(workforce.perform_work(state,actor,
        WorkforceSystem.PROF_MINING).get("started",false)),
        "no real Mine job started"):
        return
    var mine_job := buildings.active_resource_timer_for_worker(state,actor.id)
    var mine_snapshot: Dictionary = mine_job.get("sx_v55_r12_work",{})
    if not _check(mine_snapshot.get("realm",0) == 1
        and int(mine_snapshot.get("gross",0)) == int(mine_snapshot.get("minutes",0))*1000
        and int(mine_snapshot.get("tax",0)) == int(mine_snapshot.get("gross",0))*70/100
        and int(mine_snapshot.get("wage",0)) == 2000,
        "real Mine 1 source, 70% tax or W2 floor not frozen"):
        return
    # W2 floor is not an extra wage on a long job. A 1-minute thought
    # experiment still requires a genuine treasury-funded topup.
    var minute_floor := economy.sx_v55_r12_work_snapshot(
        state,actor,BuildingSystem.TYPE_MINE,"mine_thanh_thiet_t1",1)
    var minute_preview := economy.sx_v55_r12_can_settle(
        state,actor,"qa:minute-floor-preview",minute_floor)
    if not _check(bool(minute_preview.get("ok",false))
        and int(minute_preview.get("gross",0)) == 1000
        and int(minute_preview.get("wage_floor",0)) == 2000
        and int(minute_preview.get("wage_due",-1)) == 1000
        and int(minute_preview.get("taxable",0)) == 1000+int(minute_preview.get("wage_paid",-1))
        and int(minute_preview.get("tax",0)) == int(minute_preview.get("taxable",0))*70/100,
        "original W2 topup-floor formula/taxable paid portion is wrong"):
        return
    var mine_id := str(mine_job.get("job_id",""))
    state = _reload(state)
    if not _check(state != null and economy.sx_v55_r12_enabled(state),
        "pilot policy and real Mine job not persisted"):
        return
    actor = state.disciples[recruit.id]
    mine = buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    forest = buildings.primary_building(state,BuildingSystem.TYPE_LINH_FOREST)
    field = buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    if not _check(mine != null and forest != null and field != null,
        "canonical producer handles must be reacquired after cold Save"):
        return
    var before_stones := state.sect.spirit_stones+actor.spirit_stones
    var before_mine := warehouse.quantity(state,&"thanh_thiet")
    state.tick = int(mine_job["finish_tick"])
    buildings.process_tick(state)
    var mine_gross := int(mine_snapshot["gross"])
    if not _check(warehouse.quantity(state,&"thanh_thiet") == before_mine+10000
        and state.sect.spirit_stones+actor.spirit_stones == before_stones+mine_gross
        and state.sect.economy_a_receipts.has("sxv55-work:"+mine_id)
        and state.sect.economy_a_receipts.has("wage:"+mine_id)
        and int(state.sect.economy_a_receipts["wage:"+mine_id].get("due",-1)) == 0
        and int(state.sect.economy_a_receipts["wage:"+mine_id].get("paid",-1)) == 0
        and int(state.sect.economy_a_receipts["wage:"+mine_id].get("w2_floor",-1)) == 2000
        and int(state.sect.economy_a_receipts["sxv55-work:"+mine_id].get("taxable",-1)) == mine_gross,
        "actual Mine Warehouse→gross/T2/W2 floor (NO double wage) failed"):
        return
    var mine_wallet := state.sect.spirit_stones+actor.spirit_stones
    buildings.process_tick(state)
    if not _check(state.sect.spirit_stones+actor.spirit_stones == mine_wallet
        and warehouse.quantity(state,&"thanh_thiet") == before_mine+10000,
        "mine double settlement in same tick"):
        return

    # Stage 2 is a real V2 progression coordinate, not an invented r3 source.
    actor.v2_realm_progress["cultivation"]["realm"] = 2
    if not _check(DiscipleRealmProgressV2.valid_profile(actor.v2_realm_progress)
        and workforce.assign_group(state,actor.id,&"forestry_crew")
        and workforce.assign_worksite(state,actor.id,forest.id),
        "stage-2 actor cannot enter authentic Forest"):
        return
    if not _check(bool(workforce.perform_work(state,actor,
        WorkforceSystem.PROF_FORESTRY).get("started",false)),
        "no real Forest job started"):
        return
    var forest_job := buildings.active_resource_timer_for_worker(state,actor.id)
    var forest_snapshot: Dictionary = forest_job.get("sx_v55_r12_work",{})
    if not _check(int(forest_snapshot.get("realm",0)) == 2
        and int(forest_snapshot.get("gross",0)) == int(forest_snapshot.get("minutes",0))*2000
        and int(forest_snapshot.get("tax",0)) == int(forest_snapshot.get("gross",0))*30/100
        and int(forest_snapshot.get("wage",0)) == 4000,
        "real Forest 2 source/30% tax/4k W2 not pinned"):
        return
    # Reject a manipulated money envelope BEFORE depositing any materials.
    var forest_jobs := buildings.resource_timer_jobs(forest)
    if not _check(not forest_jobs.is_empty(),
        "real Forest timer missing after V2 work start / cold Save"):
        return
    var tampered: Dictionary = forest_jobs[0].duplicate(true)
    var wrong: Dictionary = tampered["sx_v55_r12_work"].duplicate(true)
    wrong["gross"] = int(wrong["gross"])+1000
    tampered["sx_v55_r12_work"] = wrong
    forest_jobs[0] = tampered
    var forest_state := forest.production_state.duplicate(true)
    forest_state["economy_a_jobs"] = forest_jobs
    forest.production_state = forest_state
    var before_wood := warehouse.quantity(state,&"linh_moc")
    var forest_cash := state.sect.spirit_stones+actor.spirit_stones
    state.tick = int(forest_job["finish_tick"])
    buildings.process_tick(state)
    if not _check(warehouse.quantity(state,&"linh_moc") == before_wood
        and state.sect.spirit_stones+actor.spirit_stones == forest_cash
        and not state.sect.economy_a_receipts.has("sxv55-work:"+str(forest_job["job_id"])),
        "altered earnings snapshot minted material or Stone"):
        return
    # The attacker may modify all monetary fields coherently. A genuinely
    # frozen start/finish duration and actual resource plan still reject it.
    var coherent: Dictionary = forest_job.duplicate(true)
    var longer: Dictionary = forest_snapshot.duplicate(true)
    longer["minutes"] = int(longer["minutes"])+1
    longer["gross"] = int(longer["minutes"])*2000
    longer["tax"] = int(longer["gross"])*30/100
    longer["net"] = int(longer["gross"])-int(longer["tax"])
    coherent["sx_v55_r12_work"] = longer
    forest_state = forest.production_state.duplicate(true)
    forest_state["economy_a_jobs"] = [coherent]
    forest.production_state = forest_state
    buildings.process_tick(state)
    if not _check(warehouse.quantity(state,&"linh_moc") == before_wood
        and state.sect.spirit_stones+actor.spirit_stones == forest_cash,
        "coherently forged LT2 minutes bypassed actual saved job duration"):
        return
    # Restore only the genuine, previously frozen job and complete it once.
    forest_state = forest.production_state.duplicate(true)
    forest_state["economy_a_jobs"] = [forest_job]
    forest.production_state = forest_state
    buildings.process_tick(state)
    var forest_gross := int(forest_snapshot["gross"])
    var forest_id := str(forest_job["job_id"])
    if not _check(warehouse.quantity(state,&"linh_moc") == before_wood+8000
        and state.sect.spirit_stones+actor.spirit_stones == forest_cash+forest_gross
        and int(state.sect.economy_a_receipts.get("wage:"+forest_id,{}).get("due",-1)) == 0
        and int(state.sect.economy_a_receipts.get("wage:"+forest_id,{}).get("paid",-1)) == 0,
        "real Forest grade-2 gross paid, W2 floor no extra wage failed"):
        return
    state = _reload(state)
    if not _check(state != null and economy.sx_v55_r12_enabled(state),
        "cold Save lost Forest tax/wage/receipt"):
        return
    actor = state.disciples[recruit.id]
    mine = buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    field = buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    # V5.5-D tab 04_NangCap342: Mine Lv1→2 costs 24,000 Stone.
    # Only genuine credited Mine+Forest production can pay this upgrade.
    var mine_cost := buildings.sx_v55_upgrade_cost(state,mine)
    if not _check(int(mine_cost.get("spirit_stones",-1)) == 24000
        and int(mine_cost.get("linh_moc",-1)) == 5000
        and int(mine_cost.get("thanh_thiet",-1)) == 7000,
        "stage1 real mine upgrade not priced to original workbook"):
        return
    var before_upgrade_stones := state.sect.spirit_stones
    var before_upgrade_wood := warehouse.quantity(state,&"linh_moc")
    var before_upgrade_ore := warehouse.quantity(state,&"thanh_thiet")
    var paid_upgrade := buildings.start_upgrade(state,mine.id)
    if not _check(bool(paid_upgrade.get("ok",false))
        and state.sect.spirit_stones == before_upgrade_stones-24000
        and warehouse.quantity(state,&"linh_moc") == before_upgrade_wood-5000
        and warehouse.quantity(state,&"thanh_thiet") == before_upgrade_ore-7000,
        "real work taxes did not fund real priced mine upgrade debit"):
        return
    state = _reload(state)
    if not _check(state != null,"cold Save after actual Mine upgrade failed"):
        return
    actor = state.disciples[recruit.id]
    mine = buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    field = buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    if not _check(mine.is_upgrading() and state.sect.spirit_stones == before_upgrade_stones-24000
        and warehouse.quantity(state,&"linh_moc") == before_upgrade_wood-5000
        and warehouse.quantity(state,&"thanh_thiet") == before_upgrade_ore-7000,
        "cold Save applied paid upgrade costs a second time"):
        return
    if not _check(workforce.assign_group(state,actor.id,&"herbalism_crew")
        and workforce.assign_worksite(state,actor.id,field.id),
        "cannot claim genuine Field plot"):
        return
    var set_plot := buildings.set_spirit_plot_crop(state,field.id,
        &"plot_001",&"thanh_linh_thao")
    if not _check(bool(set_plot.get("ok",false)),
        "cannot choose real herb source "+str(set_plot)):
        return
    if not _check(bool(workforce.perform_work(state,actor,
        WorkforceSystem.PROF_HERBALISM).get("started",false)),
        "actual Field crop failed to plant"):
        return
    var plot: Dictionary = {}
    for raw_plot in buildings.spirit_field_plots(state,field):
        if str(raw_plot.get("status","")) == "growing":
            plot = raw_plot
            break
    var crop_snapshot: Dictionary = plot.get("sx_v55_r12_work",{})
    if not _check(int(crop_snapshot.get("realm",0)) == 2
        and int(crop_snapshot.get("wage",0)) == 4000
        and int(crop_snapshot.get("tax",0)) == int(crop_snapshot.get("gross",0))*40/100,
        "real grade-2 Field snapshot failed"):
        return
    var crop_id := str(plot.get("economy_a_wage_job_id",""))
    var herb_before := warehouse.quantity(state,&"thanh_linh_thao")
    var money_before := state.sect.spirit_stones+actor.spirit_stones
    state = _reload(state)
    if not _check(state != null,"cold Save lost pending Field snapshot"):
        return
    actor = state.disciples[recruit.id]
    field = buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    state.tick = int(plot["finish_tick"])
    buildings.process_tick(state)
    var gross_field := int(crop_snapshot["gross"])
    if not _check(warehouse.quantity(state,&"thanh_linh_thao") >= herb_before+2000
        and state.sect.spirit_stones+actor.spirit_stones == money_before+gross_field
        and state.sect.economy_a_receipts.has("sxv55-work:"+crop_id)
        and state.sect.economy_a_receipts.has("wage:"+crop_id)
        and int(state.sect.economy_a_receipts["wage:"+crop_id].get("due",-1)) == 0
        and int(state.sect.economy_a_receipts["wage:"+crop_id].get("paid",-1)) == 0,
        "real Field grade-2 goods, LT2, T2 and no-double-W2 floor failed"):
        return
    var final_goods := warehouse.quantity(state,&"thanh_linh_thao")
    var final_money := state.sect.spirit_stones+actor.spirit_stones
    state = _reload(state)
    if not _check(state != null,"final cold Save failed"):
        return
    buildings.process_tick(state)
    if not _check(warehouse.quantity(state,&"thanh_linh_thao") == final_goods
        and state.sect.spirit_stones+(state.disciples[recruit.id] as DiscipleState).spirit_stones == final_money
        and state.validate_invariants().is_empty(),
        "cold replay doubled stage-1/2 money, materials or invalidated Save"):
        return
    # Full 30-row workbook remains reference-only. Stage3 cannot produce
    # money through the R12 gate, even if that worker has a valid V2 profile.
    actor = state.disciples[recruit.id]
    actor.v2_realm_progress["cultivation"]["realm"] = 3
    if not _check(economy.sx_v55_r12_work_snapshot(
        state,actor,BuildingSystem.TYPE_MINE,"mine_thanh_thiet_t1",60).is_empty(),
        "stage-3 source unlocked without true r3 producer"):
        return
    _cleanup()
    print("SX V55 R1-R2 REAL MINE FOREST FIELD -> LT2 GROSS T2 TAX W2 WAGE SAVE/REPLAY: PASS; R3+ PUBLIC HOLD")
    quit(0)

func _cleanup() -> void:
    for suffix in ["",".tmp",".bak"]:
        var path := SAVE_PATH+str(suffix)
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
