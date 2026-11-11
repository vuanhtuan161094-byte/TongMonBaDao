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

# SX-V55-D stage 1-2 is deliberately QA-locked. These source-backed gross
# work values are the EXACT first two rows of the approved 30-realm workbook.
# Existing Economy-A remains live; no player/UI command enables this pilot.
const SX_V55_R12_POLICY := "sx_v55_r12_economy"
const SX_V55_R12_RATES := {
    1: {"gross_per_minute":1000,"wage_per_job":2000},
    2: {"gross_per_minute":2000,"wage_per_job":4000}
}
# T2 design BASE scenarios: 70% Mine, 30% Forest, 40% Field.
# Kept stage-1/2 only; no imaginary r3+ real-work source.
const SX_V55_R12_TAX := {"mine":70,"linh_forest":30,"spirit_field":40}

func sx_v55_r12_enabled(state: SimulationState) -> bool:
    return state != null and state.sect.economy_a_enabled \
        and state.sect.p3_7_resources_enabled and state.p3_7_buildings_enabled \
        and bool(state.sect.economy_a_policy.get("sx_v55_bulk_production",false)) \
        and bool(state.sect.economy_a_policy.get(SX_V55_R12_POLICY,false))

# This is pinned at job START so a realm change, later policy adjustment or
# cold Save cannot retroactively mint extra pay for unfinished old jobs.
func sx_v55_r12_work_snapshot(state: SimulationState, worker: DiscipleState,
        building_type: StringName, plan_id: String, duration: int) -> Dictionary:
    if not sx_v55_r12_enabled(state) or worker == null or plan_id.is_empty() \
            or duration <= 0 or duration > 1440 or not DiscipleRealmProgressV2.progression_ready(worker):
        return {}
    var track = worker.v2_realm_progress.get("cultivation",{})
    var realm := int(track.get("realm",0))
    if not SX_V55_R12_RATES.has(realm) or not SX_V55_R12_TAX.has(str(building_type)):
        return {}
    var rate: Dictionary = SX_V55_R12_RATES[realm]
    var gross := int(rate["gross_per_minute"])*duration
    var tax_pct := int(SX_V55_R12_TAX[str(building_type)])
    var tax := gross*tax_pct/100
    return {"version":1,"realm":realm,"minutes":duration,"plan_id":plan_id,
        "site":str(building_type),"gross":gross,"tax":tax,
        "net":gross-tax,"wage":int(rate["wage_per_job"]),
        "tax_pct":tax_pct}

# ECO-04 reusable read-only arithmetic: never credits money or claims a
# producer job. The optional QA entry point explores tax 0-100 without exposing
# player tax controls or bypassing frozen real-job tax.
func _r12_cash_split(gross: int, wage_floor: int, tax_pct: int,
        sect_cash: int, worker_cash: int, reserve: int) -> Dictionary:
    if gross <= 0 or gross > V2_MAX_STONES or wage_floor < 0 \
            or tax_pct < 0 or tax_pct > 100 or sect_cash < 0 \
            or worker_cash < 0 or reserve < 0:
        return {"ok":false,"reason":"invalid_r12_cash_input"}
    var topup_due := maxi(wage_floor-gross,0)
    var topup_paid := mini(topup_due,maxi(0,sect_cash-reserve))
    var taxable := gross+topup_paid
    var tax := int(taxable*tax_pct/100)
    var worker_net := taxable-tax
    var sect_delta := tax-topup_paid
    if taxable > V2_MAX_STONES or worker_cash > V2_MAX_STONES-worker_net \
            or (sect_delta >= 0 and sect_cash > V2_MAX_STONES-sect_delta) \
            or (sect_delta < 0 and sect_cash < -sect_delta):
        return {"ok":false,"reason":"r12_money_overflow"}
    return {"ok":true,"gross":gross,"tax":tax,"net":worker_net,
        "taxable":taxable,"wage_floor":wage_floor,
        "wage_due":topup_due,"wage_paid":topup_paid,"tax_pct":tax_pct,
        "sect_delta":sect_delta}

func sx_v55_r1_tax_preview_qa(minutes: int, tax_pct: int, sect_cash: int,
        worker_cash: int = 0, reserve: int = 0) -> Dictionary:
    # Math-only design laboratory; NOT an authorization, settlement or faucet.
    if minutes < 1 or minutes > 1440:
        return {"ok":false,"reason":"invalid_qa_duration"}
    var rate: Dictionary = SX_V55_R12_RATES[1]
    return _r12_cash_split(int(rate["gross_per_minute"])*minutes,
        int(rate["wage_per_job"]),tax_pct,sect_cash,worker_cash,reserve)

# Preview must be approved BEFORE Warehouse credit, so overflow or malformed
# saved snapshots cannot create a product while its money receipt is rejected.
# V5.5-D W2 is an EARNINGS FLOOR, not an additional wage per batch.
# Topup is the uncovered shortfall: max(0, floor - LT2 gross). Settled
# topup is a Sect→worker transfer, and only actually paid topup is taxable.
func sx_v55_r12_can_settle(state: SimulationState, worker: DiscipleState,
        job_id: String, snapshot: Dictionary) -> Dictionary:
    if not sx_v55_r12_enabled(state) or worker == null or job_id.is_empty() \
            or snapshot.is_empty() or not state.disciples.has(worker.id):
        return {"ok":false,"reason":"r12_context_not_authorized"}
    if state.sect.economy_a_receipts.has("sxv55-work:"+job_id) \
            or state.sect.economy_a_receipts.has("wage:"+job_id):
        return {"ok":false,"reason":"already_settled"}
    var realm := int(snapshot.get("realm",0))
    var rate: Dictionary = SX_V55_R12_RATES.get(realm,{})
    var site := str(snapshot.get("site",""))
    var minutes := int(snapshot.get("minutes",0))
    if int(snapshot.get("version",0)) != 1 or rate.is_empty() \
            or not SX_V55_R12_TAX.has(site) or minutes <= 0 or minutes > 1440 \
            or str(snapshot.get("plan_id","")).is_empty():
        return {"ok":false,"reason":"invalid_r12_snapshot"}
    var gross := int(rate.get("gross_per_minute",0))*minutes
    var tax_pct := int(SX_V55_R12_TAX[site])
    var gross_tax := gross*tax_pct/100
    var wage_floor := int(rate.get("wage_per_job",0))
    # Legacy in-flight snapshots have no tax_pct, so preserve their ORIGINAL
    # fixed-base policy, not a new runtime migration or surprise withholding.
    if int(snapshot.get("gross",-1)) != gross or int(snapshot.get("tax",-1)) != gross_tax \
            or int(snapshot.get("net",-1)) != gross-gross_tax \
            or int(snapshot.get("wage",-1)) != wage_floor \
            or int(snapshot.get("tax_pct",tax_pct)) != tax_pct:
        return {"ok":false,"reason":"tampered_r12_work_value"}
    var reserve := maxi(0,int(state.sect.economy_a_policy.get("sect_pay_reserve",0)))
    var verdict := _r12_cash_split(gross,wage_floor,tax_pct,
        state.sect.spirit_stones,worker.spirit_stones,reserve)
    if not bool(verdict.get("ok",false)):
        return verdict
    verdict["realm"] = realm
    verdict["minutes"] = minutes
    return verdict

# Called only after actual Warehouse deposit has succeeded. All money remains
# in existing Sect/Disciple accounts; W2 is a real Sect-funded shortfall only.
func sx_v55_r12_settle(state: SimulationState, worker: DiscipleState,
        job_id: String, snapshot: Dictionary) -> Dictionary:
    var verdict := sx_v55_r12_can_settle(state,worker,job_id,snapshot)
    if not bool(verdict.get("ok",false)):
        return verdict
    var tax := int(verdict["tax"])
    var net := int(verdict["net"])
    var paid := int(verdict["wage_paid"])
    var due := int(verdict["wage_due"])
    state.sect.spirit_stones += tax-paid
    worker.spirit_stones += net
    state.sect.economy_a_receipts["sxv55-work:"+job_id] = {
        "kind":"sx_v55_work_income","job_id":job_id,"worker_id":str(worker.id),
        "plan_id":str(snapshot["plan_id"]),"site":str(snapshot["site"]),
        "realm":int(verdict["realm"]),"minutes":int(verdict["minutes"]),
        "gross":int(verdict["gross"]),"taxable":int(verdict["taxable"]),
        "tax":tax,"net":net,"tax_pct":int(verdict["tax_pct"]),
        "w2_floor":int(verdict["wage_floor"]),"tick":state.tick
    }
    # Old wage arrears tooling reads due/paid from the SAME receipt family.
    # Long jobs with gross >= floor correctly have due=0 and NO phantom debt.
    state.sect.economy_a_receipts["wage:"+job_id] = {
        "kind":"wage","job_id":job_id,"worker_id":str(worker.id),
        "paid":paid,"due":due,"w2_floor":int(verdict["wage_floor"]),
        "gross":int(verdict["gross"]),"tick":state.tick}
    state.sect.economy_a_event_count += 2
    return {"ok":true,"already_settled":false,"gross":int(verdict["gross"]),
        "tax":tax,"net":net,"wage_floor":int(verdict["wage_floor"]),
        "wage_paid":paid,"wage_due":due}

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
    if key == SX_V55_R12_POLICY:
        return {"ok":false,"reason":"design_hold_r12_no_player_activation"}
    if key == PveR12BalanceV1.POLICY_KEY:
        return {"ok":false,"reason":"design_hold_pve_r12_no_player_activation"}
    if key == "auto_hp_service":
        if not (value is bool):
            return {"ok":false,"reason":"policy_type"}
        policy[key] = value
    else:
        if not (value is int or value is float) or int(value) != value:
            return {"ok":false,"reason":"policy_type"}
        var minimum := 0 if key in ["sect_pay_reserve","wage_per_batch","auto_hp_daily_stone_limit","market_daily_units"] else 1
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


# W2 debt foundation: use persisted receipts, not a second SaveService ledger.
# Original wage receipts remain immutable; late payments belong to today's cashflow.
func unpaid_work_wages(state: SimulationState) -> Dictionary:
    if state == null or not state.sect.economy_a_enabled:
        return {"total":0,"entries":[]}
    var receipts: Dictionary = state.sect.economy_a_receipts
    var later_paid: Dictionary = {}
    for raw in receipts.values():
        if not (raw is Dictionary) or str(raw.get("kind","")) != "wage_arrears_payment":
            continue
        for raw_line in raw.get("lines",[]):
            if not (raw_line is Dictionary):
                continue
            var source := str(raw_line.get("wage_receipt_id",""))
            if not source.is_empty():
                later_paid[source] = maxi(0,int(later_paid.get(source,0))) + maxi(0,int(raw_line.get("paid",0)))
    var keys: Array = receipts.keys()
    keys.sort()
    var entries: Array = []
    var total := 0
    for raw_id in keys:
        var wage_id := str(raw_id)
        var original = receipts[raw_id]
        if not (original is Dictionary) or str(original.get("kind","")) != "wage":
            continue
        var due := maxi(0,int(original.get("due",0)))
        var credited := maxi(0,int(original.get("paid",0))) + maxi(0,int(later_paid.get(wage_id,0)))
        var remaining := maxi(0,due-credited)
        if remaining <= 0:
            continue
        var worker_id := StringName(original.get("worker_id",""))
        if not state.disciples.has(worker_id):
            continue
        entries.append({"wage_receipt_id":wage_id,"worker_id":str(worker_id),
            "remaining":remaining,"tick":int(original.get("tick",0))})
        total += remaining
    return {"total":total,"entries":entries}

# A real treasury-to-disciple transfer; no Stone creation or retroactive salary.
# Stable request_id prevents a second debit across cold Save/Load and retries.
func pay_work_wage_arrears(state: SimulationState, request_id: String) -> Dictionary:
    if state == null or not state.sect.economy_a_enabled:
        return {"ok":false,"reason":"economy_a_disabled"}
    if request_id.is_empty() or request_id.length() > 120:
        return {"ok":false,"reason":"invalid_request_id"}
    var receipt_id := "wage-arrears:%s" % request_id
    if state.sect.economy_a_receipts.has(receipt_id):
        var existing = state.sect.economy_a_receipts[receipt_id]
        if not (existing is Dictionary) or str(existing.get("kind","")) != "wage_arrears_payment":
            return {"ok":false,"reason":"conflicting_arrears_replay"}
        return {"ok":true,"already_settled":true,"receipt":existing.duplicate(true)}
    var reserve := maxi(0,int(state.sect.economy_a_policy.get("sect_pay_reserve",0)))
    var available := maxi(0,state.sect.spirit_stones-reserve)
    var entries: Array = unpaid_work_wages(state).get("entries",[])
    # ECO-04: preflight ALL r1/r2 W2 rows before changing ANY wallet.
    # Old Economy-A wage arrears have no W2 evidence and retain full payment.
    var r12_contexts: Dictionary = {}
    for item in entries:
        var wage_id := str(item.get("wage_receipt_id",""))
        var original = state.sect.economy_a_receipts.get(wage_id,{})
        if not (original is Dictionary):
            return {"ok":false,"reason":"invalid_wage_receipt"}
        if not original.has("w2_floor"):
            continue
        var job_id := str(original.get("job_id",""))
        var income = state.sect.economy_a_receipts.get("sxv55-work:"+job_id,{})
        if not (income is Dictionary) or str(income.get("kind","")) != "sx_v55_work_income" \
                or str(income.get("job_id","")) != job_id \
                or str(income.get("worker_id","")) != str(item.get("worker_id","")) \
                or int(income.get("gross",-1)) != int(original.get("gross",-2)) \
                or int(original.get("due",-1)) != maxi(
                    int(original.get("w2_floor",0))-int(original.get("gross",0)),0):
            return {"ok":false,"reason":"unverified_r12_wage_arrears"}
        var site := str(income.get("site",""))
        if not SX_V55_R12_TAX.has(site):
            return {"ok":false,"reason":"unverified_r12_tax_site"}
        var pct := int(income.get("tax_pct",SX_V55_R12_TAX[site]))
        if pct < 0 or pct > 100:
            return {"ok":false,"reason":"invalid_r12_tax_percent"}
        r12_contexts[wage_id] = {"gross":int(original.get("gross",0)),
            "due":int(original.get("due",0)),"tax_pct":pct}
    var paid_lines: Array = []
    var spent := 0
    var cleared := 0
    var withheld := 0
    for item in entries:
        if available <= 0:
            break
        var worker_id := StringName(item.get("worker_id",""))
        if not state.disciples.has(worker_id):
            continue
        var worker: DiscipleState = state.disciples[worker_id]
        var room := maxi(0,V2_MAX_STONES-worker.spirit_stones)
        var payment := mini(int(item.get("remaining",0)),mini(available,room))
        if payment <= 0:
            continue
        var wage_id := str(item.get("wage_receipt_id",""))
        var tax_on_late_w2 := 0
        if r12_contexts.has(wage_id):
            var r12: Dictionary = r12_contexts[wage_id]
            # Tax on actual funded topup, with cumulative rounding:
            # splitting 1000 LT into 1-LT requests cannot evade T2.
            var gross := int(r12["gross"])
            var already_funded := int(r12["due"])-int(item.get("remaining",0))
            var pct := int(r12["tax_pct"])
            tax_on_late_w2 = int((gross+already_funded+payment)*pct/100) \
                -int((gross+already_funded)*pct/100)
        var net_paid := payment-tax_on_late_w2
        available -= payment # Funding must exist for gross W2 liability.
        cleared += payment
        withheld += tax_on_late_w2
        spent += net_paid
        worker.spirit_stones += net_paid
        paid_lines.append({"wage_receipt_id":wage_id,
            "worker_id":str(worker_id),"paid":payment,
            "net_paid":net_paid,"tax_withheld":tax_on_late_w2})
    if cleared <= 0:
        return {"ok":false,"reason":"no_payable_arrears_or_funds"}
    state.sect.spirit_stones -= spent
    var receipt := {"kind":"wage_arrears_payment","request_id":request_id,
        "paid":spent,"gross_cleared":cleared,"tax_withheld":withheld,
        "lines":paid_lines,"tick":state.tick}
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

# ECO-03: read-only affordability quote. This does NOT reserve or debit any
# money, does not create a seed/item, and does not promise future wages:
# actual wage settlement at harvest is authoritative, including arrears.
func field_seed_preflight_v1(state: SimulationState, crop_id: StringName) -> Dictionary:
    var registry := SpiritCropRegistry.new()
    if state == null or not state.sect.p3_7_resources_enabled or not registry.has(crop_id):
        return {"ok":false,"reason":"unauthored_or_unavailable_crop"}
    var cost := registry.cost(crop_id)
    if cost <= 0:
        return {"ok":false,"reason":"invalid_crop_cost"}
    var cash := state.sect.spirit_stones
    var wage_due := maxi(int(state.sect.economy_a_policy.get("wage_per_batch",2)),0) \
        if state.sect.economy_a_enabled else 0
    var reserve := maxi(int(state.sect.economy_a_policy.get("sect_pay_reserve",0)),0)
    var after_seed := maxi(0,cash-cost)
    var expected_unfunded_wage := maxi(0,wage_due-maxi(0,after_seed-reserve))
    return {
        "ok":cash >= cost,
        "reason":"" if cash >= cost else "insufficient_spirit_stones",
        "crop_id":str(crop_id),"cost":cost,
        "sect_cash":cash,"cash_after_seed":after_seed,
        "wage_due_estimate":wage_due,
        "wage_unfunded_if_no_new_income":expected_unfunded_wage
    }

# Read-only daily accounting from genuine canonical receipts. The result is
# still PARTIAL: building upgrades, cultivation and recruitment sinks have
# separate owners and are not fabricated here.
func daily_market_cashflow(state: SimulationState) -> Dictionary:
    if state == null or not state.sect.economy_a_enabled:
        return {"income":0,"origin_income":0,"purchases":0,
            "seed_costs":0,"wages":0,"net_market_and_wages":0,
            "net_recorded":0}
    var day := int(state.tick/V2_DAY_TICKS)
    var income := 0
    var origin_income := 0
    var purchases := 0
    var seed_costs := 0
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
            "eco01_origin_vein":
                origin_income += maxi(int(receipt.get("gross",0)),0)
            "market_buy":
                purchases += maxi(int(receipt.get("cost",0)),0)
            "field_seed":
                seed_costs += maxi(int(receipt.get("cost",0)),0)
            "wage", "wage_arrears_payment":
                wages += maxi(int(receipt.get("paid",0)),0)
    return {
        "income":income,"origin_income":origin_income,
        "purchases":purchases,"seed_costs":seed_costs,"wages":wages,
        "net_market_and_wages":income-purchases-wages,
        "net_recorded":income+origin_income-purchases-seed_costs-wages
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
    # ECO-02: zero capacity is an explicit no-buyer/no-seller scenario.
    # A 30+ roster must not silently re-enable the market.
    if int(state.sect.economy_a_policy.get("market_daily_units",20)) == 0:
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
    # Internal PVE-BAL01 Shop prices use existing NPC stock/quota/receipt
    # and keep the player/legacy prices untouched while pilot is disabled.
    var base_value := PveR12BalanceV1.npc_purchase_base_price(state,resource_id)
    if base_value <= 0:
        base_value = int(V57_BODY_GATE_BASE_PRICES.get(str(resource_id),0))
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
    # ECO-02: a closed NPC market must reject before even generating
    # merchant restock. An attempted purchase is not a valid stock source.
    if int(state.sect.economy_a_policy.get("market_daily_units",20)) == 0:
        return {"ok":false,"reason":"npc_no_buyers_or_daily_quota"}
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
    if int(state.sect.economy_a_policy.get("market_daily_units",20)) == 0:
        return 0
    var current_day := int(state.tick / V2_DAY_TICKS)
    var spent := state.sect.economy_a_market_units_sold if state.sect.economy_a_market_day == current_day else 0
    return maxi(effective_market_daily_units(state)-spent,0)

# ECO-02: read-only, canonical sell quote. One truth for the Hall UI
# and the transaction: warehouse reserve/lock, NPC quota and exact sale price.
# A quote never debits stock, pays money, or replenishes NPC stock.
func sell_quote_v1(state: SimulationState, resource_id: StringName, quantity: int) -> Dictionary:
    if state == null or not state.sect.economy_a_enabled:
        return {"ok":false,"reason":"economy_a_disabled","max_quantity":0}
    var warehouse := WarehouseSystem.new()
    var stock := warehouse.quantity(state,resource_id)
    var rule := warehouse.rule(state,resource_id)
    var locked := bool(rule.get("locked",false))
    var reserve_min := int(rule.get("reserve_min",0))
    var available := warehouse.available_quantity(state,resource_id)
    var unit_price := market_sell_price(resource_id)
    var quota := market_remaining(state)
    var per_sale := maxi(int(state.sect.economy_a_policy.get("market_max_per_sale",5)),1)
    var maximum := mini(available,mini(per_sale,quota)) if unit_price > 0 else 0
    var reason := ""
    if unit_price <= 0:
        reason = "resource_not_sellable"
    elif quota <= 0:
        reason = "npc_no_buyers_or_daily_quota"
    elif locked or available <= 0:
        reason = "stock_missing_or_reserved"
    elif quantity <= 0 or quantity > maximum:
        reason = "invalid_or_over_demand_sale"
    return {
        "ok":reason.is_empty(),"reason":reason,"resource_id":str(resource_id),
        "stock":stock,"reserve_min":reserve_min,"locked":locked,
        "available":available,"quota":quota,"max_per_sale":per_sale,
        "max_quantity":maximum,"quantity":quantity,"unit_price":unit_price,
        "earned":unit_price*quantity if reason.is_empty() else 0
    }

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
    var quote := sell_quote_v1(state,resource_id,quantity)
    if not bool(quote.get("ok",false)):
        return {"ok":false,"reason":str(quote.get("reason","invalid_or_over_demand_sale"))}
    # No callback can mint Stones without the canonical quote plus actual
    # Warehouse.consume below. Do not mutate even NPC restock on rejection.
    sync_market_day(state)
    var unit_price := int(quote["unit_price"])
    var earned := int(quote["earned"])
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
    # The new pilot has no Stone-for-HP service. Injury is treated at the
    # clinic; normal HP comes from medicines and battle skills.
    # Retain historical HP service for old Saves when the pilot is OFF.
    # All authentic V2 disciples follow medicines/skills for HP and the
    # Injury clinic for wounds, even while PVE reward pilot stays disabled.
    # Existing non-V2 saves keep the legacy HP-service behavior.
    if DiscipleRealmProgressV2.owns_v2_progression(actor):
        return {"ok":false,"reason":"hp_service_replaced_by_injury_care_and_pills"}
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
    if not state.sect.economy_a_enabled or not bool(state.sect.economy_a_policy.get("auto_hp_service",false)) or PveR12BalanceV1.active(state):
        return
    if DiscipleRealmProgressV2.owns_v2_progression(actor):
        return
    if actor.hp <= 0.0 or actor.hp >= actor.max_hp*0.5:
        return
    var cost := maxi(int(state.sect.economy_a_policy.get("personal_heal_cost",3)),1)
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
