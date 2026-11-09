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
    if not policy.has(key):
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

# Resource-sale income is earned against Warehouse stock. The NPC also
# stocks one paid Tầm Mạch Bàn per day for the real Mine Lv10+ gates.
# Selling building components back would enable artificial market recycling.
# V5.7: paid NPC route for EXISTING registered Body-gate ingredients.
# Prices are pilot base values; market markup is applied by the live buyer.
# These cannot be sold back to the NPC; no exploitative buy->sell loop.
const V57_BODY_GATE_BASE_PRICES := {
    "thanh_linh_thao":6,
    "tinh_lang_bi":10,
    "tu_van_thao":16,
    "linh_tuy":14,
    "huyet_linh_sam":120,
    "huyet_thu_tinh_huyet":180,
    "kim_cot_thao":350,
    "linh_thu_cot_ngoc":600,
    "tien_tuy_lien":1500,
    "tien_thu_chan_cot":2500,
    "bat_hoai_tuy_dich":6500,
    "dai_la_kim_cot":9500,
    "than_mach_tinh":23000,
    "than_thu_cot":38000,
    "hon_don_tuy_hoa":125000,
    "bat_diet_than_cot":195000,
    "an_nhan_gioi":9000,
    "an_tien_gioi":380000,
    "an_than_gioi":9500000
}
const V57_BODY_GATE_DAILY_STOCK := 40

static func body_gate_source_available(state: SimulationState, source_realm: int) -> bool:
    if state == null or not state.sect.economy_a_enabled or source_realm < 1 or source_realm > 29:
        return false
    var recipe := DiscipleBodyGateContentV2.recipe(source_realm)
    if recipe.is_empty():
        return false
    var registry := ResourceRegistry.new()
    for field in ["main_id","aux_id"]:
        var item_id := str(recipe.get(field,""))
        if not V57_BODY_GATE_BASE_PRICES.has(item_id) or not registry.has(StringName(item_id)):
            return false
    var seal_id := str(recipe.get("seal_id",""))
    return seal_id.is_empty() or (
        V57_BODY_GATE_BASE_PRICES.has(seal_id) and registry.has(StringName(seal_id))
    )

const V2_MARKET_SELLABLE := ["linh_moc", "thanh_thiet", "thanh_linh_thao", "linh_coc", "huyen_thiet"]
const V2_MARKET_CATALOG := ["linh_moc","thanh_thiet","thanh_linh_thao","linh_coc","huyen_thiet","tam_mach_ban","linh_tuyen_chi_tam_manh","tinh_lang_bi","tu_van_thao","linh_tuy","huyet_linh_sam","huyet_thu_tinh_huyet","kim_cot_thao","linh_thu_cot_ngoc","tien_tuy_lien","tien_thu_chan_cot","bat_hoai_tuy_dich","dai_la_kim_cot","than_mach_tinh","than_thu_cot","hon_don_tuy_hoa","bat_diet_than_cot","an_nhan_gioi","an_tien_gioi","an_than_gioi"]
# A second earned source for the 100-fragment Field heart beyond rare actual
# harvest drops. Each fragment is paid, is never resellable to this NPC, and
# conversion still needs 100 real owned fragments.
const V2_MARKET_DAILY_SPECIAL_STOCK := {"tam_mach_ban": 1, "linh_tuyen_chi_tam_manh": 20}

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
        var restock_target := V57_BODY_GATE_DAILY_STOCK if V57_BODY_GATE_BASE_PRICES.has(raw_id) else int(V2_MARKET_DAILY_SPECIAL_STOCK.get(raw_id,target))
        state.sect.economy_a_market_stock[raw_id] = maxi(
            int(state.sect.economy_a_market_stock.get(raw_id,0)),restock_target)
    state.sect.economy_a_market_stock_day = day
    state.sect.economy_a_market_units_bought = 0
    if state.sect.economy_a_market_day != day:
        state.sect.economy_a_market_day = day
        state.sect.economy_a_market_units_sold = 0

# Read-only daily accounting from settled canonical receipts. This is a
# transparent partial ledger: crop expenses and building/technique upgrades
# have different owners and are intentionally NOT invented here.
func daily_market_cashflow(state: SimulationState) -> Dictionary:
    if state == null or not state.sect.economy_a_enabled:
        return {"income":0,"purchases":0,"wages":0,"net_market_and_wages":0}
    var day := int(state.tick/V2_DAY_TICKS)
    var income := 0
    var purchases := 0
    var wages := 0
    for raw_receipt in state.sect.economy_a_receipts.values():
        if not (raw_receipt is Dictionary):
            continue
        var receipt: Dictionary = raw_receipt
        var receipt_day := int(receipt.get("day",int(receipt.get("tick",-V2_DAY_TICKS))/V2_DAY_TICKS))
        if receipt_day != day:
            continue
        match str(receipt.get("kind","")):
            "market":
                income += maxi(int(receipt.get("earned",0)),0)
            "market_buy":
                purchases += maxi(int(receipt.get("cost",0)),0)
            "wage":
                wages += maxi(int(receipt.get("paid",0)),0)
    return {
        "income":income,"purchases":purchases,"wages":wages,
        "net_market_and_wages":income-purchases-wages
    }

# SX-05: market throughput scales only after the Sect actually has 30+
# owned disciples. All sales still require available Warehouse resources and
# all purchases still debit real Spirit Stones and merchant stock.
func effective_market_daily_units(state: SimulationState) -> int:
    if state == null:
        return 0
    var baseline := maxi(int(state.sect.economy_a_policy.get("market_daily_units",20)),1)
    # A smaller roster later in the same market day cannot invalidate
    # previously settled, legitimate 480-player purchases and sales.
    var settled := maxi(state.sect.economy_a_market_units_sold,
        state.sect.economy_a_market_units_bought)
    if state.disciples.size() < 30:
        return maxi(baseline,settled)
    return maxi(maxi(baseline,mini(4000,state.disciples.size()*8)),settled)

func market_buy_remaining(state: SimulationState) -> int:
    if state == null or not state.sect.economy_a_enabled:
        return 0
    var day := int(state.tick / V2_DAY_TICKS)
    var bought := state.sect.economy_a_market_units_bought if state.sect.economy_a_market_stock_day == day else 0
    return maxi(effective_market_daily_units(state)-bought,0)

func market_sell_price(resource_id: StringName) -> int:
    if not V2_MARKET_SELLABLE.has(str(resource_id)):
        return 0
    return int(ResourceRegistry.new().definition(resource_id).get("market_value",0))

func market_purchase_price(state: SimulationState, resource_id: StringName) -> int:
    if not V2_MARKET_CATALOG.has(str(resource_id)):
        return 0
    var base_value := int(V57_BODY_GATE_BASE_PRICES.get(str(resource_id),0))
    if base_value <= 0:
        base_value = int(ResourceRegistry.new().definition(resource_id).get("market_value",0))
    return base_value * maxi(int(state.sect.economy_a_policy.get("market_buy_markup",2)),1)

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
    if resource_id == &"linh_tuyen_chi_tam_manh":
        # Keep the existing exact 100 fragments -> one real heart rule.
        # A purchase never creates a heart until the Warehouse has 100.
        BuildingSystem.new().convert_linh_tuyen_fragments(state)
    var day := int(state.tick / V2_DAY_TICKS)
    var receipt := {"kind":"market_buy","request_id":request_id,"resource_id":str(resource_id),"quantity":quantity,"unit_price":unit_price,"cost":cost,"day":day,"tick":state.tick}
    state.sect.economy_a_receipts[receipt_id] = receipt
    state.sect.economy_a_event_count += 1
    return {"ok":true,"already_settled":false,"receipt":receipt.duplicate(true)}

# SX-05: one click can buy the currently missing Body-gate kit without
# issuing dozens of 5-unit market orders. Partial, source-limited purchases
# are reported as partial and never claim the gate has become clear.
# All stock, player funds and Warehouse effects settle under one receipt.
func buy_missing_body_gate_materials(state: SimulationState,
        disciple_id: StringName, request_id: String) -> Dictionary:
    if state == null or not state.sect.economy_a_enabled or request_id.is_empty()             or request_id.length() > 160 or not state.disciples.has(disciple_id):
        return {"ok":false,"reason":"invalid_body_bundle_request"}
    var receipt_id := "market-body-bundle:"+request_id
    if state.sect.economy_a_receipts.has(receipt_id):
        var old: Dictionary = state.sect.economy_a_receipts[receipt_id]
        var current_realm := int((state.disciples[disciple_id] as DiscipleState).v2_realm_progress.get(
            "body",{}).get("realm",0))
        if str(old.get("disciple_id","")) != str(disciple_id) or int(old.get("source_realm",0)) != current_realm:
            return {"ok":false,"reason":"body_bundle_request_conflict"}
        return {"ok":true,"already_settled":true,"receipt":old.duplicate(true)}
    var preview := DiscipleBodyGateTransactionV2.new().preview_gate(state,disciple_id)
    if not bool(preview.get("ok",false)) or not bool(preview.get("content_available",false)):
        return {"ok":false,"reason":str(preview.get("reason","body_gate_content_missing"))}
    sync_market_day(state)
    var remaining := market_buy_remaining(state)
    var stones := int(state.sect.spirit_stones)
    var lines: Array[Dictionary] = []
    var total_cost := 0
    var total_qty := 0
    var warehouse := WarehouseSystem.new()
    for raw_component in preview.get("requirements",[]):
        if not (raw_component is Dictionary):
            continue
        var comp: Dictionary = raw_component
        var item := StringName(comp.get("item_id",""))
        var missing := maxi(0,int(comp.get("need",0))-int(comp.get("available",0)))
        if missing == 0:
            continue
        if bool(comp.get("locked",false)):
            return {"ok":false,"reason":"body_bundle_warehouse_locked"}
        var unit := market_purchase_price(state,item)
        if unit <= 0:
            return {"ok":false,"reason":"body_bundle_item_not_purchasable"}
        var merchant := maxi(0,int(state.sect.economy_a_market_stock.get(str(item),0)))
        var amount := mini(missing,mini(merchant,remaining))
        amount = mini(amount,int((stones-total_cost)/unit))
        if amount <= 0:
            continue
        if amount > WarehouseSystem.MAX_SAFE_STACK-warehouse.quantity(state,item):
            return {"ok":false,"reason":"body_bundle_warehouse_overflow"}
        lines.append({"resource_id":str(item),"quantity":amount,"unit_price":unit})
        total_cost += amount*unit
        total_qty += amount
        remaining -= amount
    if total_qty <= 0 or total_cost <= 0:
        return {"ok":false,"reason":"body_bundle_out_of_stock_quota_or_stones"}
    if total_cost > stones or total_qty > market_buy_remaining(state):
        return {"ok":false,"reason":"body_bundle_balance_changed"}
    var resources_before := state.sect.warehouse_resources.duplicate(true)
    var warehouse_events_before := state.sect.warehouse_event_count
    for line in lines:
        if not warehouse.add(state,StringName(line["resource_id"]),int(line["quantity"])):
            state.sect.warehouse_resources = resources_before
            state.sect.warehouse_event_count = warehouse_events_before
            return {"ok":false,"reason":"body_bundle_stock_commit_failed"}
    for line in lines:
        var id := str(line["resource_id"])
        state.sect.economy_a_market_stock[id] = int(state.sect.economy_a_market_stock.get(id,0))-int(line["quantity"])
    state.sect.economy_a_market_units_bought += total_qty
    state.sect.spirit_stones -= total_cost
    var receipt := {"kind":"market_buy","bundle":"body_gate",
        "disciple_id":str(disciple_id),"source_realm":int(preview.get("source_realm",0)),
        "request_id":request_id,"lines":lines.duplicate(true),
        "quantity":total_qty,"cost":total_cost,
        "day":int(state.tick/V2_DAY_TICKS),"tick":state.tick}
    state.sect.economy_a_receipts[receipt_id] = receipt
    state.sect.economy_a_event_count += 1
    var after := DiscipleBodyGateTransactionV2.new().preview_gate(state,disciple_id)
    var missing_after := 0
    for component in after.get("requirements",[]):
        if component is Dictionary:
            missing_after += maxi(0,int(component.get("need",0))-int(component.get("available",0)))
    return {"ok":true,"already_settled":false,"receipt":receipt.duplicate(true),
        "complete":missing_after == 0,"remaining_missing_units":missing_after}

func market_remaining(state: SimulationState) -> int:
    if state == null or not state.sect.economy_a_enabled:
        return 0
    var current_day := int(state.tick / V2_DAY_TICKS)
    var spent := state.sect.economy_a_market_units_sold if state.sect.economy_a_market_day == current_day else 0
    return maxi(effective_market_daily_units(state)-spent,0)

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
    if state.sect.economy_a_market_units_sold < 0 or state.sect.economy_a_market_units_sold > effective_market_daily_units(state):
        errors.append("Economy-A market quota invalid.")
    if state.sect.economy_a_market_units_bought < 0 or state.sect.economy_a_market_units_bought > effective_market_daily_units(state):
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
