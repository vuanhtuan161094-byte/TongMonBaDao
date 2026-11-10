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
    for index in [0,1]:
        var row: Dictionary = all_rows[index]
        var realm := int(row["realm"])
        var rate := int(row["lt2_per_minute"])
        var wage := int(row["w2_min_wage_per_job"])
        if not _check(EconomySystem.SX_V55_R12_RATES[realm]["gross_per_minute"] == rate
            and EconomySystem.SX_V55_R12_RATES[realm]["wage_per_job"] == wage,
            "coded pilot rate drifts from 30-stage workbook"):
            return
        var daily_mine_gross := site_min*rate
        var daily_forest_gross := site_min*rate
        var daily_field_gross := site_min*rate
        var gross := daily_mine_gross+daily_forest_gross+daily_field_gross
        var taxes := daily_mine_gross*70/100 + daily_forest_gross*30/100 \
            + daily_field_gross*40/100
        var wage_spend := jobs*wage
        var sect_net := taxes-wage_spend-seed_cost+npc_max
        var personal_net := gross-taxes+wage_spend
        if not _check(gross == 2160*rate and taxes == 1008*rate
            and gross == sect_net+personal_net+seed_cost-npc_max,
            "gross→worker/tax/wage monetary conservation violated"):
            return
        # This is a real issue for balancing: current paid upgrade pricing is
        # far smaller than the work-income faucet, even at stage-1.
        if not _check(sect_net > 900000 and not economy.sx_v55_r12_enabled(state),
            "large surplus should remain an explicit HOLD, not auto-activated"):
            return
        for day_count in [1,7,30]:
            print("SX_V55_R12_FUNDING_HOLD realm=",realm," days=",day_count,
                " gross_earned=",gross*day_count,
                " taxes_to_sect=",taxes*day_count,
                " w2_to_workers=",wage_spend*day_count,
                " seed_cost=",seed_cost*day_count,
                " npc_sale_ceiling=",npc_max*day_count,
                " sect_surplus_before_upgrades=",sect_net*day_count,
                " worker_net=",personal_net*day_count)
    if not _check(state.sect.economy_a_receipts.is_empty()
        and state.sect.economy_a_market_units_sold == 0
        and state.validate_invariants().is_empty(),
        "read-only 1/7/30-day simulation mutated a real wallet or receipt"):
        return
    print("SX-V55 R1/R2 SOURCE-BACKED WORK FINANCE MODEL: PASS; PLAYER ACTIVATION HOLD DUE OVERFUNDING")
    quit(0)
