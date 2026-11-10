extends SceneTree

# Read-only feasibility model for *earned* R1/R2 work gross, suggested
# T2 BASE site taxes, and W2 minimum. Not a real 30-day playthrough, income
# event, or permission to enable the QA-locked policy for the player.
const MINUTES_PER_WORKER_DAY := 360
const WORKERS_PER_SITE := 2

func _init() -> void:
    call_deferred("_run")

func _check(value: bool, reason: String) -> bool:
    if not value:
        push_error("SX V55 R12 FUNDING PRESSURE FAIL: "+reason)
        quit(1)
        return false
    return true

func _run() -> void:
    var economy := EconomySystem.new()
    var state := P37Factory.create_state(550321)
    if not _check(bool(economy.enable_v1(state).get("ok",false))
        and not economy.sx_v55_r12_enabled(state),
        "simulated design must not activate player income"):
        return
    var plan := BuildingSystem.SX_V55_BULK_PLANS
    var site_min := WORKERS_PER_SITE*MINUTES_PER_WORKER_DAY
    var mine_jobs := WORKERS_PER_SITE*int(floor(float(MINUTES_PER_WORKER_DAY) / float(plan["thanh_thiet"]["cycle_ticks"])))
    var forest_jobs := WORKERS_PER_SITE*int(floor(float(MINUTES_PER_WORKER_DAY) / float(plan["linh_moc"]["cycle_ticks"])))
    var grain_jobs := int(floor(float(MINUTES_PER_WORKER_DAY)/float(plan["linh_coc"]["cycle_ticks"])))
    var herb_jobs := int(floor(float(MINUTES_PER_WORKER_DAY)/float(plan["thanh_linh_thao"]["cycle_ticks"])))
    var jobs := mine_jobs+forest_jobs+grain_jobs+herb_jobs
    if not _check(mine_jobs == 12 and forest_jobs == 12 and grain_jobs == 6
        and herb_jobs == 4 and jobs == 34,"real producer schedule changed"):
        return
    var seed_cost := grain_jobs*SpiritCropRegistry.new().cost(&"linh_coc") \
        +herb_jobs*SpiritCropRegistry.new().cost(&"thanh_linh_thao")
    var npc_max := economy.effective_market_daily_units(state)*economy.market_sell_price(&"thanh_thiet")
    if not _check(seed_cost == 34 and npc_max == 160,"real pilot sink or sale ceiling changed"):
        return
    var reference = JSON.parse_string(FileAccess.get_file_as_string(
        "res://data/economy/v55d_30_realm_reference.json"))
    if not _check(reference is Dictionary and reference.get("runtime_activation",true) == false,
        "approved V5.5-D 30-stage sheet not reference-only"):
        return
    var all_rows: Array = reference.get("realms",[])
    if not _check(all_rows.size() == 30,"original 30-stage workbook incomplete"):
        return
    # The original V5.5-D tab 04_NangCap342 authorizes ×1000 on
    # Spirit Stone NEW upgrade prices. Legacy gameplay stays unchanged.
    var buildings := BuildingSystem.new()
    if not _check(bool(buildings.sx_v55_enable_bulk(state).get("ok",false))
        and not economy.sx_v55_r12_enabled(state),
        "new bulk production must NOT also activate QA economy"):
        return
    state.sect.economy_a_policy[EconomySystem.SX_V55_R12_POLICY] = true
    # P37Factory has no Hall; production LiveGameRuntimeV2 creates it
    # through this existing canonical function. No free materials or money.
    if not _check(buildings.ensure_main_hall(state) != null,
        "actual live-runtime Main Hall authority not constructible"):
        return
    var upgrades := [
        {"kind":BuildingSystem.TYPE_MAIN_HALL,"stone":580000},
        {"kind":BuildingSystem.TYPE_SPIRIT_FIELD,"stone":21000},
        {"kind":BuildingSystem.TYPE_MINE,"stone":24000},
        {"kind":BuildingSystem.TYPE_LINH_FOREST,"stone":24000}
    ]
    var first_wave_stone := 0
    var first_wave_wood := 0
    var first_wave_ore := 0
    for entry in upgrades:
        var building := buildings.primary_building(state,entry["kind"])
        if not _check(building != null and building.level == 1,
            "source-backed four founding facilities missing or not Lv1"):
            return
        var original := buildings.upgrade_cost(building)
        var quoted := buildings.sx_v55_upgrade_cost(state,building)
        if not _check(int(quoted.get("spirit_stones",-1)) == int(entry["stone"])
            and int(quoted.get("spirit_stones",-1)) == int(original.get("spirit_stones",0))*1000
            and int(quoted.get("linh_moc",-1)) == int(original.get("linh_moc",0))*1000
            and int(quoted.get("thanh_thiet",-1)) == int(original.get("thanh_thiet",0))*1000,
            "original 04_NangCap342 money scale / already-live bulk material scale mismatch"):
            return
        first_wave_stone += int(quoted["spirit_stones"])
        first_wave_wood += int(quoted["linh_moc"])
        first_wave_ore += int(quoted["thanh_thiet"])
    if not _check(first_wave_stone == 649000
        and first_wave_wood == 46000 and first_wave_ore == 42000,
        "first real material + money four-upgrade spend changed"):
        return
    # Two Mine and two Forest workers, six hours each, produce enough
    # real material to pay four ordinary upgrades; no fake stock injection.
    var mine_output_daily := mine_jobs*int(plan["thanh_thiet"]["yield"])
    var forest_output_daily := forest_jobs*int(plan["linh_moc"]["yield"])
    if not _check(mine_output_daily == 120000
        and forest_output_daily == 96000
        and mine_output_daily >= first_wave_ore
        and forest_output_daily >= first_wave_wood,
        "real ore/wood supply cannot cover one staged upgrade wave"):
        return
    for index in [0,1]:
        var row: Dictionary = all_rows[index]
        var realm := int(row["realm"])
        var rate := int(row["lt2_per_minute"])
        var wage_floor := int(row["w2_min_wage_per_job"])
        if not _check(EconomySystem.SX_V55_R12_RATES[realm]["gross_per_minute"] == rate
            and EconomySystem.SX_V55_R12_RATES[realm]["wage_per_job"] == wage_floor,
            "coded pilot rate drifts from 30-stage workbook"):
            return
        var daily_mine_gross := site_min*rate
        var daily_forest_gross := site_min*rate
        var daily_field_gross := site_min*rate
        var gross := daily_mine_gross+daily_forest_gross+daily_field_gross
        var taxes := daily_mine_gross*70/100+daily_forest_gross*30/100 \
            +daily_field_gross*40/100
        # V5.5-D W2 is a FLOOR; for 60/90min real jobs, each LT2
        # gross already exceeds the floor and topup=0, NOT jobs*W2.
        var wage_topup_due := mine_jobs*maxi(wage_floor-rate*int(plan["thanh_thiet"]["cycle_ticks"]),0) \
            +forest_jobs*maxi(wage_floor-rate*int(plan["linh_moc"]["cycle_ticks"]),0) \
            +grain_jobs*maxi(wage_floor-rate*int(plan["linh_coc"]["cycle_ticks"]),0) \
            +herb_jobs*maxi(wage_floor-rate*int(plan["thanh_linh_thao"]["cycle_ticks"]),0)
        var sect_net := taxes-wage_topup_due-seed_cost+npc_max
        var personal_net := gross-taxes+wage_topup_due
        if not _check(gross == 2160*rate and taxes == 1008*rate \
            and wage_topup_due == 0 \
            and gross+npc_max == sect_net+personal_net+seed_cost,
            "gross/W2 floor/T2/seed/NPC conservation violated"):
            return
        var after_one_wave := sect_net-first_wave_stone
        if not _check(after_one_wave > 0 and sect_net > 1000000
            and not state.sect.economy_a_receipts.has("sxv55-work:qa"),
            "source-backed gross too small for real founding upgrade wave"):
            return
        # The original V5.5-D 06_MoPhong720 tab models r1 Field sowing
        # around 240,000 Stones/day, versus current actual 34/day.
        # Source CSV price and cadence are NOT yet reconciled; log this
        # as a hard player-activation blocker, not a guessed crop-price patch.
        for days in [1,7,30]:
            print("SX_V55_R12_TRUE_COST_HOLD realm=",realm,
                " days=",days,
                " gross=",gross*days,
                " tax=",taxes*days,
                " w2_topup=",wage_topup_due*days,
                " current_seed=",seed_cost*days,
                " npc_sale_best_case=",npc_max*days,
                " first_real_upgrade_wave_LTs=",first_wave_stone,
                " first_real_upgrade_wave_wood=",first_wave_wood,
                " first_real_upgrade_wave_ore=",first_wave_ore,
                " sect_surplus_before_upgrades=",sect_net*days,
                " sect_after_one_wave_only=",sect_net*days-first_wave_stone)
    state.sect.economy_a_policy[EconomySystem.SX_V55_R12_POLICY] = false
    if not _check(state.sect.economy_a_receipts.is_empty()
        and state.sect.economy_a_market_units_sold == 0
        and state.validate_invariants().is_empty(),
        "read-only 1/7/30-day simulation mutated a real wallet or receipt"):
        return
    print("SX-V55 R1/R2 ORIGINAL W2 FLOOR, TRUE ×1000 UPGRADE DEBITS, NPC, SEED CASHFLOW: PASS; FIELD SEED RECONCILIATION AND PLAYER ACTIVATION HOLD")
    quit(0)
