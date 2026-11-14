extends SceneTree

# ECO-BAL-01 read-only scenario export. This calls current QA quote/cap
# functions only; it does not settle transactions, save, or modify live files.
# Roster rows beyond New Game use count-only fixtures because the market cap
# helper reads disciples.size(); those rows are not workers or recruited actors.
var _checks := 0
var _rows := 0

func _init() -> void:
    call_deferred("_run")

func _ok(condition: bool, detail: String) -> bool:
    _checks += 1
    if condition:
        return true
    push_error("ECO_BAL01_MATRIX_FAIL " + detail)
    quit(1)
    return false

func _emit(row: Dictionary) -> void:
    _rows += 1
    print("ECO_BAL01_JSON=" + JSON.stringify(row))

func _run() -> void:
    var economy := EconomySystem.new()
    for opening_cash in [0, 500]:
        for tax_pct in [0, 30, 70, 100]:
            for minutes in [1, 60, 90, 180]:
                var quote: Dictionary = economy.sx_v55_r1_tax_preview_qa(
                    int(minutes), int(tax_pct), int(opening_cash), 0, 0)
                var gross := 1000 * int(minutes)
                var topup_paid := mini(maxi(2000 - gross, 0), int(opening_cash))
                var taxable := gross + topup_paid
                var tax := taxable * int(tax_pct) / 100
                if not _ok(bool(quote.get("ok", false))
                    and int(quote.get("gross", -1)) == gross
                    and int(quote.get("tax", -1)) == tax
                    and int(quote.get("net", -1)) == taxable - tax
                    and int(quote.get("wage_paid", -1)) == topup_paid
                    and int(quote.get("wage_due", -1)) == maxi(2000 - gross, 0)
                    and int(quote.get("sect_delta", 999999)) == tax - topup_paid,
                    "tax preview cash=" + str(opening_cash) + " pct=" + str(tax_pct) + " minutes=" + str(minutes)):
                    return
                quote["scenario"] = "r1_read_only_qa_tax_preview"
                quote["opening_sect_stones"] = int(opening_cash)
                quote["sim_minutes"] = int(minutes)
                quote["public_activation"] = "HOLD"
                quote["state_or_save_mutated"] = false
                _emit(quote)

    for opening_cash in [0, 500]:
        for roster in [6, 15, 30]:
            var state: SimulationState = P37Factory.create_state(78011 + int(roster))
            state.sect.spirit_stones = int(opening_cash)
            if not bool(economy.enable_v1(state).get("ok", false)):
                push_error("ECO_BAL01_MATRIX_FAIL Economy-A fixture enable")
                quit(1)
                return
            var authentic_roster := state.disciples.size()
            while state.disciples.size() < int(roster):
                state.disciples["qa_count_only_%02d" % state.disciples.size()] = null
            for npc_open in [false, true]:
                state.sect.economy_a_policy["market_daily_units"] = 20 if npc_open else 0
                var effective := economy.effective_market_daily_units(state)
                var sell_remaining := economy.market_remaining(state)
                var buy_remaining := economy.market_buy_remaining(state)
                var expected_trade_cap := 0 if not npc_open else (240 if int(roster) >= 30 else 20)
                if not _ok(sell_remaining == expected_trade_cap and buy_remaining == expected_trade_cap,
                    "market remaining cash=" + str(opening_cash) + " roster=" + str(roster) + " npc=" + str(npc_open)):
                    return
                var ore_price := economy.market_sell_price(&"thanh_thiet")
                _emit({
                    "scenario":"market_cap_read_only",
                    "opening_sect_stones":int(opening_cash),
                    "requested_roster_count":int(roster),
                    "authentic_factory_roster":authentic_roster,
                    "roster_mode":"authentic_factory" if int(roster) == authentic_roster else "count_only_fixture_no_workers",
                    "npc_open":bool(npc_open),
                    "market_daily_policy":20 if npc_open else 0,
                    "effective_cap_helper_units":effective,
                    "actual_sell_cap_remaining_units":sell_remaining,
                    "actual_buy_cap_remaining_units":buy_remaining,
                    "thanh_thiet_sell_price":ore_price,
                    "best_case_ore_sale_ceiling_lt":sell_remaining * ore_price,
                    "demand_guaranteed":false,
                    "transaction_executed":false,
                    "warehouse_or_save_mutated":false
                })

    var economy_a_state: SimulationState = P37Factory.create_state(78099)
    economy.enable_v1(economy_a_state)
    if not _ok(economy_a_state.sect.economy_a_enabled
        and not bool(economy_a_state.sect.economy_a_policy.get("sx_v55_bulk_production", false))
        and not economy.sx_v55_r12_enabled(economy_a_state), "Economy-A-only gate"):
        return
    _emit({
        "scenario":"mode_gate", "mode":"economy_a_only",
        "economy_a_enabled":economy_a_state.sect.economy_a_enabled,
        "bulk_opt_in":bool(economy_a_state.sect.economy_a_policy.get("sx_v55_bulk_production", false)),
        "r12_enabled":economy.sx_v55_r12_enabled(economy_a_state),
        "player_activation":"Economy-A existing mode"
    })
    var bulk := BuildingSystem.new().sx_v55_enable_bulk(economy_a_state)
    if not _ok(bool(bulk.get("ok", false))
        and bool(economy_a_state.sect.economy_a_policy.get("sx_v55_bulk_production", false))
        and not economy.sx_v55_r12_enabled(economy_a_state), "Bulk must not activate R12"):
        return
    _emit({
        "scenario":"mode_gate", "mode":"bulk_opt_in_only",
        "bulk_enable_ok":bool(bulk.get("ok", false)),
        "economy_a_enabled":economy_a_state.sect.economy_a_enabled,
        "bulk_opt_in":bool(economy_a_state.sect.economy_a_policy.get("sx_v55_bulk_production", false)),
        "r12_enabled":economy.sx_v55_r12_enabled(economy_a_state),
        "player_activation":"opt-in for new bulk jobs only; R12 stays off"
    })
    var r12_attempt := economy.configure_v1(economy_a_state, EconomySystem.SX_V55_R12_POLICY, true)
    if not _ok(not bool(r12_attempt.get("ok", true))
        and str(r12_attempt.get("reason", "")) == "design_hold_r12_no_player_activation"
        and not economy.sx_v55_r12_enabled(economy_a_state), "R12 player activation must stay held"):
        return
    _emit({
        "scenario":"mode_gate", "mode":"r12_player_activation_attempt",
        "attempt_ok":bool(r12_attempt.get("ok", false)),
        "reason":str(r12_attempt.get("reason", "")),
        "r12_enabled":economy.sx_v55_r12_enabled(economy_a_state),
        "player_activation":"blocked_by_design_hold"
    })
    var buildings := BuildingSystem.new()
    for building_type in [BuildingSystem.TYPE_MAIN_HALL, BuildingSystem.TYPE_RESIDENCE,
        BuildingSystem.TYPE_MINE, BuildingSystem.TYPE_LINH_FOREST,
        BuildingSystem.TYPE_ALCHEMY_HALL, BuildingSystem.TYPE_SPIRIT_FIELD,
        BuildingSystem.TYPE_GUIDANCE_PLATFORM]:
        var building: BuildingState = buildings.create_building(building_type, 1)
        var total: Dictionary = {"linh_moc":0,"thanh_thiet":0,"spirit_stones":0}
        var first_cost: Dictionary = {}
        var work_sum := 0.0
        var milestone_totals: Dictionary = {}
        for target_level in range(2, 101):
            building.level = target_level - 1
            var cost: Dictionary = buildings.upgrade_cost(building)
            if target_level == 2:
                first_cost = cost.duplicate(true)
            for raw_id in cost.keys():
                var item := str(raw_id)
                total[item] = int(total.get(item,0)) + int(cost[raw_id])
                if item not in ["linh_moc","thanh_thiet","spirit_stones"]:
                    milestone_totals[item] = int(milestone_totals.get(item,0)) + int(cost[raw_id])
            work_sum += buildings.upgrade_required_work(building)
        var status := "FORMULA_PRESENT_WITH_HALL_GATE"
        var upper_level := 100
        if building_type == BuildingSystem.TYPE_GUIDANCE_PLATFORM:
            status = "HARD_GATE_AFTER_LV20_MISSING_SECT_PROGRESSION_AUTHORITY"
            upper_level = 20
        elif building_type == BuildingSystem.TYPE_BODY_TRAINING:
            status = "UPGRADE_CONTENT_PENDING"
            upper_level = 1
        _emit({
            "scenario":"building_lv1_to_lv100_cost_curve",
            "building_type":str(building_type),
            "cost_mode":"base_curve_economy_a_no_bulk_no_r12",
            "first_lv1_to_lv2_cost":first_cost,
            "theoretical_lv1_to_lv100_total":total,
            "milestone_component_total":milestone_totals,
            "theoretical_work_points_lv1_to_lv100":work_sum,
            "current_progression_status":status,
            "highest_individually_authorized_level":upper_level,
            "must_not_be_read_as":"proof all required resources or Hall gates are achievable"
        })
    print("ECO_BAL01_READONLY_MATRIX_PASS checks=%d rows=%d; no transaction/save performed" % [_checks, _rows])
    quit(0)
