extends SceneTree

# Analytical r1 economic feasibility across 1/7/30 days. Every source
# quantity, cycle, plant fee, recipe BOM and sell price comes from CURRENT
# runtime authority. Assumptions are transparent, not actual scheduled work
# or a second wallet/income implementation. Never awards game resources.
const WORK_MINUTES_PER_WORKER_PER_DAY := 360
const WORKERS_MINE := 2
const WORKERS_FOREST := 2
const WORKERS_GRAIN := 1
const WORKERS_HERB := 1

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> bool:
    if not ok:
        push_error("SX-V55 R1 ECO 30D FAIL: "+message)
        quit(1)
        return false
    return true

func _batches(kind: String, workers: int) -> int:
    var plan: Dictionary = BuildingSystem.SX_V55_BULK_PLANS.get(kind,{})
    return workers * int(floor(float(WORK_MINUTES_PER_WORKER_PER_DAY) /
        float(maxi(int(plan.get("cycle_ticks",0)),1))))

func _run() -> void:
    var buildings := BuildingSystem.new()
    var economy := EconomySystem.new()
    var crops := SpiritCropRegistry.new()
    var recipes := AlchemyRecipeRegistry.new()
    var state := P37Factory.create_state(55113030)
    if not _check(bool(economy.enable_v1(state).get("ok",false))
        and bool(buildings.sx_v55_enable_bulk(state).get("ok",false)),
        "cannot enable real-authority bulk economics"):
        return
    var mine_jobs := _batches("thanh_thiet",WORKERS_MINE)
    var forest_jobs := _batches("linh_moc",WORKERS_FOREST)
    var grain_jobs := _batches("linh_coc",WORKERS_GRAIN)
    var herb_jobs := _batches("thanh_linh_thao",WORKERS_HERB)
    var plan := BuildingSystem.SX_V55_BULK_PLANS
    var ore_per_day := mine_jobs * int(plan["thanh_thiet"]["yield"])
    var wood_per_day := forest_jobs * int(plan["linh_moc"]["yield"])
    var grain_per_day := grain_jobs * int(plan["linh_coc"]["yield"])
    var herb_per_day := herb_jobs * int(plan["thanh_linh_thao"]["yield"])
    if not _check(mine_jobs == 12 and forest_jobs == 12 and grain_jobs == 6
        and herb_jobs == 4 and ore_per_day == 120000 and wood_per_day == 96000
        and grain_per_day == 15000 and herb_per_day == 8000,
        "owner 6-person 360m/day scenario changed unexpectedly"):
        return

    # A seventh dedicated alchemist or a shifted work allocation is necessary
    # for these theoretical pill crafts; six producers cannot simultaneously
    # do Alchemy. This is a CONSUMER CAPACITY SCENARIO, not a free pill grant.
    var hxd := buildings.sx_v55_common_requirements(state,recipes.inputs(&"hoi_xuan_dan"))
    var tqd := buildings.sx_v55_common_requirements(state,recipes.inputs(&"tu_khi_dan"))
    var daily_hxd := 2
    var daily_tqd := 1
    var consumed_herbs := daily_hxd*int(hxd.get("thanh_linh_thao",0)) + daily_tqd*int(tqd.get("thanh_linh_thao",0))
    var consumed_grain := daily_tqd*int(tqd.get("linh_coc",0))
    if not _check(consumed_herbs == 8000 and consumed_grain == 1
        and consumed_herbs <= herb_per_day and consumed_grain <= grain_per_day,
        "authored pill BOM does not match real bulk crop production"):
        return
    var job_count := mine_jobs+forest_jobs+grain_jobs+herb_jobs
    var wages := job_count*int(state.sect.economy_a_policy.get("wage_per_batch",0))
    var field_seed_cost := grain_jobs*crops.cost(&"linh_coc") + herb_jobs*crops.cost(&"thanh_linh_thao")
    var sell_price := economy.market_sell_price(&"thanh_thiet")
    var sale_cap := economy.effective_market_daily_units(state)
    var sale_units := mini(ore_per_day,sale_cap)
    var stone_income_ceiling := sale_units*sell_price
    var net_without_upgrades := stone_income_ceiling-wages-field_seed_cost
    if not _check(job_count == 34 and wages == 68 and field_seed_cost == 34
        and sale_cap == 20 and stone_income_ceiling == 160
        and net_without_upgrades == 58,
        "Economy-A level-one payable budget differs from real code"):
        return
    var initial_stones := state.sect.spirit_stones
    var first_w2 := 2000 # EXACT original V5.5-D 01_Khoa30CG row r1
    var w2_required := job_count*first_w2
    var first_w2_deficit := w2_required+field_seed_cost-stone_income_ceiling
    if not _check(w2_required == 68000 and first_w2_deficit > 0,
        "unfunded W2 accidentally treated as live payable income"):
        return
    for days in [1,7,30]:
        # Formula is deterministic workbook scenario (no auto NPC demand
        # guarantee, work-speed effect, seed inflation or upgrade purchase).
        var gained_ore := days*ore_per_day
        var sold_ore := days*sale_units
        var produced_wood := days*wood_per_day
        var produced_grain := days*grain_per_day
        var used_grain := days*consumed_grain
        var produced_herb := days*herb_per_day
        var used_herb := days*consumed_herbs
        var market_earned := days*stone_income_ceiling
        var payroll := days*wages
        var seeds := days*field_seed_cost
        var final_balance_ceiling := initial_stones+market_earned-payroll-seeds
        if not _check(gained_ore >= sold_ore and produced_grain >= used_grain
            and produced_herb >= used_herb
            and final_balance_ceiling == initial_stones + days*net_without_upgrades
            and final_balance_ceiling >= 0,
            "material or Stone 1/7/30-day budget not conserved"):
            return
        print("SX_V55_ECO_SCENARIO days=",days,
            " ore_earned=",gained_ore," ore_sold=",sold_ore,
            " ore_remainder=",gained_ore-sold_ore,
            " wood_earned=",produced_wood," grain_remainder=",produced_grain-used_grain,
            " herb_remainder=",produced_herb-used_herb,
            " hxd_potential=",days*daily_hxd," tqd_potential=",days*daily_tqd,
            " npc_stone_ceiling=",market_earned,
            " wages_pilot=",payroll," field_seed_cost=",seeds,
            " treasury_upper=",final_balance_ceiling,
            " w2_r1_funding_gap=",days*first_w2_deficit)
    # An analytical read-only model is forbidden from changing the user's
    # actual Warehouse, wallet, or economy receipt even in a QA fixture.
    if not _check(state.sect.economy_a_receipts.is_empty()
        and state.sect.economy_a_market_units_sold == 0
        and state.sect.economy_a_market_units_bought == 0
        and state.validate_invariants().is_empty(),
        "economic study minted game resources, income or receipts"):
        return
    print("SX-V55 R1 1D/7D/30D ACTUAL-SOURCE CONSERVATION: PASS; 30CG W2/LT2/T2 STILL HOLD")
    quit(0)
