class_name EconomySystem
extends RefCounted

const HEAL_FEE := 15
const SUPPLY_FEE := 20
const MIN_TREASURY_RESERVE := 200

func market_buy_price(state: SimulationState, item_id: String) -> int:
    var base_price := int(state.sect.base_prices.get(item_id, 1))
    var stock := int(state.sect.market_stock.get(item_id, 0))
    var multiplier := clampf(1.15 - float(stock) * 0.01, 0.8, 1.2)
    return maxi(1, int(round(float(base_price) * multiplier)))

func sell_inventory(state: SimulationState, disciple: DiscipleState) -> int:
    var earned := 0
    var sold: Dictionary = {}
    var item_keys: Array = disciple.inventory.keys()
    item_keys.sort()

    for item_key in item_keys:
        var item_id := str(item_key)
        var quantity := int(disciple.inventory[item_key])
        if quantity <= 0:
            continue

        var unit_price := market_buy_price(state, item_id)
        var spendable := maxi(0, state.sect.treasury - MIN_TREASURY_RESERVE)
        var affordable_quantity := mini(quantity, int(spendable / maxi(unit_price, 1)))
        if affordable_quantity <= 0:
            continue

        var transfer := unit_price * affordable_quantity
        state.sect.treasury -= transfer
        disciple.wallet += transfer
        state.sect.market_stock[item_id] = int(state.sect.market_stock.get(item_id, 0)) + affordable_quantity
        earned += transfer
        sold[item_id] = affordable_quantity

    for item_id in sold.keys():
        var remaining := int(disciple.inventory.get(item_id, 0)) - int(sold[item_id])
        if remaining <= 0:
            disciple.inventory.erase(item_id)
        else:
            disciple.inventory[item_id] = remaining

    if earned > 0:
        disciple.metrics["sales"] = int(disciple.metrics.get("sales", 0)) + 1

    return earned

func heal(state: SimulationState, disciple: DiscipleState) -> bool:
    if disciple.wallet < HEAL_FEE:
        return false
    disciple.wallet -= HEAL_FEE
    state.sect.treasury += HEAL_FEE
    disciple.hp = minf(disciple.max_hp, disciple.hp + 55.0)
    disciple.metrics["heals"] = int(disciple.metrics.get("heals", 0)) + 1
    return true

func buy_supplies(state: SimulationState, disciple: DiscipleState) -> bool:
    if disciple.wallet < SUPPLY_FEE:
        return false
    disciple.wallet -= SUPPLY_FEE
    state.sect.treasury += SUPPLY_FEE
    disciple.stamina = minf(100.0, disciple.stamina + 30.0)
    disciple.metrics["buys"] = int(disciple.metrics.get("buys", 0)) + 1
    return true


# ECONOMY-A: independent, optional V2 Stone accounting. Pilot values live in
# SectState.economy_a_policy and are NOT locked balance. Old P2 money is untouched.
const V2_MAX_STONES := 9000000000000000
const V2_DAY_TICKS := 1440

func enable_v1(state: SimulationState) -> Dictionary:
    if state == null or not state.p3_7_buildings_enabled or not state.sect.p3_7_resources_enabled:
        return {"ok":false,"reason":"v2_economy_requires_canonical_warehouse"}
    state.sect.economy_a_enabled = true
    return {"ok":true}

func configure_v1(state: SimulationState, key: String, value: Variant) -> Dictionary:
    if state == null or not state.sect.economy_a_enabled:
        return {"ok":false,"reason":"economy_a_disabled"}
    var policy: Dictionary = state.sect.economy_a_policy
    if not policy.has(key) and key != "market_daily_stone_budget":
        return {"ok":false,"reason":"unknown_policy"}
    if key == "auto_hp_service":
        if not (value is bool):
            return {"ok":false,"reason":"policy_type"}
        policy[key] = value
    else:
        if not (value is int or value is float) or int(value) != value:
            return {"ok":false,"reason":"policy_type"}
        var minimum := 0 if key in ["sect_pay_reserve","wage_per_batch","auto_hp_daily_stone_limit"] else 1
        var maximum := 100000 if key != "resource_duration_ticks" else 1440
        if int(value) < minimum or int(value) > maximum:
            return {"ok":false,"reason":"policy_out_of_bounds"}
        policy[key] = int(value)
    state.sect.economy_a_event_count += 1
    return {"ok":true,"key":key,"value":policy[key]}

# Only a completed, genuinely delivered work receipt may pay wages. A missing
# budget creates a durable unpaid receipt (zero money minted), not a phantom wage.
func settle_work_wage(state: SimulationState, worker: DiscipleState, job_id: String) -> Dictionary:
    if state == null or not state.sect.economy_a_enabled or worker == null or job_id.is_empty():
        return {"ok":false,"reason":"invalid_wage_context"}
    var receipt_id := "wage:%s" % job_id
    if state.sect.economy_a_receipts.has(receipt_id):
        return {"ok":true,"already_settled":true,"receipt":state.sect.economy_a_receipts[receipt_id]}
    var wage := maxi(int(state.sect.economy_a_policy.get("wage_per_batch",2)),0)
    var reserve := maxi(int(state.sect.economy_a_policy.get("sect_pay_reserve",0)),0)
    var paid := wage if state.sect.spirit_stones >= wage + reserve and worker.spirit_stones <= V2_MAX_STONES - wage else 0
    if paid > 0:
        state.sect.spirit_stones -= paid
        worker.spirit_stones += paid
    var receipt := {"kind":"wage","job_id":job_id,"worker_id":str(worker.id),"paid":paid,"due":wage,"tick":state.tick}
    state.sect.economy_a_receipts[receipt_id] = receipt
    state.sect.economy_a_event_count += 1
    return {"ok":true,"already_settled":false,"receipt":receipt.duplicate(true)}

const V2_MARKET_CATALOG := ["linh_moc", "thanh_thiet", "thanh_linh_thao", "linh_coc"]

# Merchant stock is separate from the Sect Warehouse and legacy P2 market.
# Daily replenishment uses the canonical simulation tick; existing stock from
# player sales survives until purchased.
func sync_market_day(state: SimulationState) -> void:
    if state == null or not state.sect.economy_a_enabled:
        return
    var day := int(state.tick / V2_DAY_TICKS)
    if state.sect.economy_a_market_stock_day == day:
        return
    var target := maxi(int(state.sect.economy_a_policy.get("market_stock_target",20)),0)
    for raw_id in V2_MARKET_CATALOG:
        state.sect.economy_a_market_stock[raw_id] = maxi(
            int(state.sect.economy_a_market_stock.get(raw_id,0)),target)
    state.sect.economy_a_market_stock_day = day
    state.sect.economy_a_market_units_bought = 0
    if state.sect.economy_a_market_day != day:
        state.sect.economy_a_market_day = day
        state.sect.economy_a_market_units_sold = 0

func market_buy_remaining(state: SimulationState) -> int:
    if state == null or not state.sect.economy_a_enabled:
        return 0
    var day := int(state.tick / V2_DAY_TICKS)
    var bought := state.sect.economy_a_market_units_bought if state.sect.economy_a_market_stock_day == day else 0
    return maxi(int(state.sect.economy_a_policy.get("market_daily_units",20))-bought,0)

func market_sell_price(resource_id: StringName) -> int:
    if not V2_MARKET_CATALOG.has(str(resource_id)):
        return 0
    return int(ResourceRegistry.new().definition(resource_id).get("market_value",0))

func market_purchase_price(state: SimulationState, resource_id: StringName) -> int:
    return market_sell_price(resource_id)*maxi(int(state.sect.economy_a_policy.get("market_buy_markup",2)),1)

# Player buys from durable NPC stock; Warehouse receives the actual item before
# Sect Stones are debited. Every rejection leaves currency and goods unchanged.
func buy_from_npc_v1(state: SimulationState, resource_id: StringName, quantity: int, request_id: String) -> Dictionary:
    if state == null or not state.sect.economy_a_enabled:
        return {"ok":false,"reason":"economy_a_disabled"}
    if request_id.is_empty():
        return {"ok":false,"reason":"missing_request_id"}
    var receipt_id := "market-buy:%s" % request_id
    if state.sect.economy_a_receipts.has(receipt_id):
        var prior = state.sect.economy_a_receipts[receipt_id]
        if not (prior is Dictionary) or str(prior.get("resource_id","")) != str(resource_id) or int(prior.get("quantity",-1)) != quantity:
            return {"ok":false,"reason":"conflicting_market_replay"}
        return {"ok":true,"already_settled":true,"receipt":prior.duplicate(true)}
    sync_market_day(state)
    var per_buy := maxi(int(state.sect.economy_a_policy.get("market_max_per_buy",5)),1)
    var unit_price := market_purchase_price(state,resource_id)
    if quantity <= 0 or quantity > per_buy or quantity > market_buy_remaining(state) or unit_price <= 0:
        return {"ok":false,"reason":"invalid_or_over_demand_buy"}
    var available := int(state.sect.economy_a_market_stock.get(str(resource_id),0))
    if available < quantity:
        return {"ok":false,"reason":"merchant_stock_missing"}
    var cost := unit_price*quantity
    if state.sect.spirit_stones < cost:
        return {"ok":false,"reason":"insufficient_spirit_stones"}
    var warehouse := WarehouseSystem.new()
    if not warehouse.add(state,resource_id,quantity):
        return {"ok":false,"reason":"warehouse_rejected"}
    state.sect.economy_a_market_stock[str(resource_id)] = available-quantity
    state.sect.economy_a_market_units_bought += quantity
    state.sect.spirit_stones -= cost
    var day := int(state.tick / V2_DAY_TICKS)
    var receipt := {"kind":"market_buy","request_id":request_id,"resource_id":str(resource_id),"quantity":quantity,"unit_price":unit_price,"cost":cost,"day":day,"tick":state.tick}
    state.sect.economy_a_receipts[receipt_id] = receipt
    state.sect.economy_a_event_count += 1
    return {"ok":true,"already_settled":false,"receipt":receipt.duplicate(true)}

func market_remaining(state: SimulationState) -> int:
    if state == null or not state.sect.economy_a_enabled:
        return 0
    var current_day := int(state.tick / V2_DAY_TICKS)
    var spent := state.sect.economy_a_market_units_sold if state.sect.economy_a_market_day == current_day else 0
    return maxi(int(state.sect.economy_a_policy.get("market_daily_units",20))-spent,0)

# Daily NPC Stone capacity is independent of the item quota. Reconstructing
# spent budget from durable sale receipts keeps old saves compatible and makes
# reload/replay use the same authority without another counter to migrate.
func market_stone_budget_remaining(state: SimulationState) -> int:
    if state == null or not state.sect.economy_a_enabled:
        return 0
    var budget := maxi(int(state.sect.economy_a_policy.get("market_daily_stone_budget",120)),0)
    var day := int(state.tick / V2_DAY_TICKS)
    for raw_receipt in state.sect.economy_a_receipts.values():
        if raw_receipt is Dictionary and str(raw_receipt.get("kind","")) == "market" and int(raw_receipt.get("day",-1)) == day:
            budget = maxi(budget - maxi(int(raw_receipt.get("earned",0)),0),0)
    return budget

# NPC purchases create external Stones only against an actual, unreserved Sect
# Warehouse debit. request_id is user-action idempotency key across reloads.
func sell_to_npc_v1(state: SimulationState, resource_id: StringName, quantity: int, request_id: String) -> Dictionary:
    if state == null or not state.sect.economy_a_enabled:
        return {"ok":false,"reason":"economy_a_disabled"}
    if request_id.is_empty():
        return {"ok":false,"reason":"missing_request_id"}
    var receipt_id := "market:%s" % request_id
    if state.sect.economy_a_receipts.has(receipt_id):
        var prior = state.sect.economy_a_receipts[receipt_id]
        if not (prior is Dictionary) or str(prior.get("resource_id","")) != str(resource_id) or int(prior.get("quantity",-1)) != quantity:
            return {"ok":false,"reason":"conflicting_market_replay"}
        return {"ok":true,"already_settled":true,"receipt":prior.duplicate(true)}
    sync_market_day(state)
    var unit_price := market_sell_price(resource_id)
    var per_sale := maxi(int(state.sect.economy_a_policy.get("market_max_per_sale",5)),1)
    if quantity <= 0 or quantity > per_sale or quantity > market_remaining(state) or unit_price <= 0:
        return {"ok":false,"reason":"invalid_or_over_demand_sale"}
    var earned := unit_price*quantity
    if earned > market_stone_budget_remaining(state):
        return {"ok":false,"reason":"merchant_stone_budget_exhausted"}
    if earned > V2_MAX_STONES-state.sect.spirit_stones:
        return {"ok":false,"reason":"stone_overflow"}
    var merchant_stock := int(state.sect.economy_a_market_stock.get(str(resource_id),0))
    if quantity > WarehouseSystem.MAX_SAFE_STACK-merchant_stock:
        return {"ok":false,"reason":"merchant_stock_overflow"}
    var warehouse := WarehouseSystem.new()
    if not warehouse.consume(state,resource_id,quantity):
        return {"ok":false,"reason":"stock_missing_or_reserved"}
    var day := int(state.tick / V2_DAY_TICKS)
    if state.sect.economy_a_market_day != day:
        state.sect.economy_a_market_day = day
        state.sect.economy_a_market_units_sold = 0
    state.sect.economy_a_market_units_sold += quantity
    state.sect.economy_a_market_stock[str(resource_id)] = merchant_stock+quantity
    state.sect.spirit_stones += earned
    var receipt := {"kind":"market","request_id":request_id,"resource_id":str(resource_id),"quantity":quantity,"unit_price":unit_price,"earned":earned,"day":day,"tick":state.tick}
    state.sect.economy_a_receipts[receipt_id] = receipt
    state.sect.economy_a_event_count += 1
    return {"ok":true,"already_settled":false,"receipt":receipt.duplicate(true)}

# Actual HP restoration service; never alters Injury, EXP, equipment or any
# Sect-owned resource. Personal Stone debit is matched by Sect Stone credit.
func buy_personal_hp_service(state: SimulationState, disciple_id: StringName, request_id: String) -> Dictionary:
    if state == null or not state.sect.economy_a_enabled or not state.disciples.has(disciple_id) or request_id.is_empty():
        return {"ok":false,"reason":"invalid_personal_service"}
    var receipt_id := "service:%s" % request_id
    if state.sect.economy_a_receipts.has(receipt_id):
        var previous = state.sect.economy_a_receipts[receipt_id]
        if not (previous is Dictionary) or str(previous.get("disciple_id","")) != str(disciple_id):
            return {"ok":false,"reason":"conflicting_service_replay"}
        return {"ok":true,"already_settled":true,"receipt":previous.duplicate(true)}
    var actor: DiscipleState = state.disciples[disciple_id]
    var cost := maxi(int(state.sect.economy_a_policy.get("personal_heal_cost",3)),1)
    # No circular dependency on BuildingSystem: inspect the actual saved
    # worker reservations already owned by each building's production_state.
    var reserved := actor.work_group_id == &"body_training_crew"
    for building_value in state.buildings.values():
        if not (building_value is BuildingState):
            continue
        var stored: Dictionary = (building_value as BuildingState).production_state
        for job_key in ["jobs","economy_a_jobs"]:
            var jobs = stored.get(job_key,[])
            if jobs is Array:
                for saved_job in jobs:
                    if saved_job is Dictionary and str(saved_job.get("worker_id","")) == str(disciple_id):
                        reserved = true
        var plots = stored.get("plots",[])
        if plots is Array:
            for saved_plot in plots:
                if saved_plot is Dictionary and str(saved_plot.get("status","")) == "growing" and str(saved_plot.get("assigned_worker_id","")) == str(disciple_id):
                    reserved = true
    if actor.region_id != &"sect" or not actor.active_pve_encounter_id.is_empty() or not actor.work_cycle_state.is_empty() or reserved:
        return {"ok":false,"reason":"personal_service_worker_busy"}
    if actor.hp >= actor.max_hp or actor.hp <= 0.0 or actor.spirit_stones < cost:
        return {"ok":false,"reason":"personal_service_unavailable"}
    if state.sect.spirit_stones > V2_MAX_STONES-cost:
        return {"ok":false,"reason":"stone_overflow"}
    var restored := minf(10.0,actor.max_hp-actor.hp)
    actor.spirit_stones -= cost
    state.sect.spirit_stones += cost
    actor.hp += restored
    var receipt := {"kind":"personal_hp_service","disciple_id":str(disciple_id),"cost":cost,"hp_restored":restored,"tick":state.tick}
    state.sect.economy_a_receipts[receipt_id] = receipt
    state.sect.economy_a_event_count += 1
    return {"ok":true,"already_settled":false,"receipt":receipt.duplicate(true)}

func auto_personal_service_tick(state: SimulationState, actor: DiscipleState) -> void:
    if not state.sect.economy_a_enabled or not bool(state.sect.economy_a_policy.get("auto_hp_service",false)):
        return
    if actor.hp <= 0.0 or actor.hp >= actor.max_hp*0.5:
        return
    var cost := int(state.sect.economy_a_policy.get("personal_heal_cost",3))
    if actor.spirit_stones < cost:
        return
    var day := int(state.tick / V2_DAY_TICKS)
    if state.sect.economy_a_auto_spend_day != day:
        state.sect.economy_a_auto_spend_day = day
        state.sect.economy_a_auto_spend_by_disciple.clear()
    var actor_id := str(actor.id)
    var spent := int(state.sect.economy_a_auto_spend_by_disciple.get(actor_id,0))
    var limit := maxi(int(state.sect.economy_a_policy.get("auto_hp_daily_stone_limit",6)),0)
    if cost > limit-spent:
        return
    var result := buy_personal_hp_service(state,actor.id,"auto:%s:%d" % [actor_id,state.tick])
    if bool(result.get("ok",false)) and not bool(result.get("already_settled",false)):
        state.sect.economy_a_auto_spend_by_disciple[actor_id] = spent+cost

func validate_v1(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if not state.sect.economy_a_enabled:
        return errors
    if not state.sect.p3_7_resources_enabled or not state.p3_7_buildings_enabled:
        errors.append("Economy-A must use canonical Warehouse.")
    if state.sect.spirit_stones < 0 or state.sect.spirit_stones > V2_MAX_STONES:
        errors.append("Economy-A Sect Stone balance invalid.")
    if state.sect.economy_a_market_units_sold < 0 or state.sect.economy_a_market_units_sold > int(state.sect.economy_a_policy.get("market_daily_units",20)):
        errors.append("Economy-A market quota invalid.")
    if state.sect.economy_a_market_units_bought < 0 or state.sect.economy_a_market_units_bought > int(state.sect.economy_a_policy.get("market_daily_units",20)):
        errors.append("Economy-A market buy quota invalid.")
    for raw_id in state.sect.economy_a_market_stock.keys():
        if not V2_MARKET_CATALOG.has(str(raw_id)) or int(state.sect.economy_a_market_stock[raw_id]) < 0 or int(state.sect.economy_a_market_stock[raw_id]) > WarehouseSystem.MAX_SAFE_STACK:
            errors.append("Economy-A merchant stock invalid.")
    for raw_id in state.sect.economy_a_auto_spend_by_disciple.keys():
        if not state.disciples.has(StringName(raw_id)) or int(state.sect.economy_a_auto_spend_by_disciple[raw_id]) < 0:
            errors.append("Economy-A auto spending record invalid.")
    for actor in state.disciples.values():
        if (actor as DiscipleState).spirit_stones < 0 or (actor as DiscipleState).spirit_stones > V2_MAX_STONES:
            errors.append("Economy-A personal Stone balance invalid.")
    for key in state.sect.economy_a_receipts.keys():
        var receipt = state.sect.economy_a_receipts[key]
        if not (receipt is Dictionary) or str(key).is_empty():
            errors.append("Economy-A has malformed receipt.")
    return errors
