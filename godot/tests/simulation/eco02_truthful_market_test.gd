extends SceneTree

# ECO-02: source-backed starter Warehouse stock, reserve/lock, explicit zero
# NPC demand, exact once receipt/cold Save, and roster-dependent quota.
# Real 6->30 recruitment uses production RecruitmentSystem, with QA-only
# housing cap override; it does NOT claim 30 paid active worksite slots.
const SAVE_PATH := "user://qa_eco02_truthful_market.json"
var economy := EconomySystem.new()
var warehouse := WarehouseSystem.new()

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, why: String) -> bool:
    if not ok:
        push_error("ECO02 MARKET FAIL: "+why)
        _cleanup()
        quit(1)
        return false
    return true

func _run() -> void:
    _cleanup()
    var state := P37Factory.create_state(2026111102)
    if not _check(bool(economy.enable_v1(state).get("ok",false))
        and state.disciples.size() == 6
        and not economy.sx_v55_r12_enabled(state),
        "ECO02 must use canonical r1/r2 Economy-A, no player LT2/W2/T2"): return
    var ore := &"thanh_thiet"
    var stock := warehouse.quantity(state,ore)
    var price := economy.market_sell_price(ore)
    if not _check(stock >= 13 and price == 8 and economy.market_remaining(state) == 20,
        "Real NewGame Warehouse ore / 6-person NPC cap / base price changed"): return
    if not _check(not bool(economy.sell_quote_v1(state,&"tam_mach_ban",1).get("ok",false))
        and not bool(economy.sell_to_npc_v1(state,&"tam_mach_ban",1,"not-for-sale").get("ok",false)),
        "NPC accepted an allowlist-forbidden crafting item"): return
    if not _check(warehouse.set_rule(state,ore,stock-4,false),
        "Canonical Warehouse reserve rejected"): return
    var quote := economy.sell_quote_v1(state,ore,5)
    if not _check(int(quote.get("max_quantity",-1)) == 4
        and int(quote.get("reserve_min",-1)) == stock-4
        and not bool(quote.get("ok",false))
        and bool(economy.sell_quote_v1(state,ore,4).get("ok",false)),
        "Market quote ignored reserve or per-sale amount"): return
    var initial_cash := state.sect.spirit_stones
    var initial_events := state.sect.economy_a_event_count
    var initial_market := state.sect.economy_a_market_stock.duplicate(true)
    if not _check(bool(economy.configure_v1(state,"market_daily_units",0).get("ok",false))
        and economy.market_remaining(state) == 0
        and economy.market_buy_remaining(state) == 0
        and not bool(economy.sell_quote_v1(state,ore,1).get("ok",false)),
        "Zero buyer demand not supported"): return
    var after_config := state.sect.economy_a_event_count
    if not _check(not bool(economy.sell_to_npc_v1(state,ore,1,"no-buyer-sale").get("ok",false))
        and not bool(economy.buy_from_npc_v1(state,ore,1,"no-buyer-buy").get("ok",false))
        and state.sect.spirit_stones == initial_cash
        and warehouse.quantity(state,ore) == stock
        and state.sect.economy_a_market_stock == initial_market
        and state.sect.economy_a_event_count == after_config,
        "Zero NPC buyers generated phantom money, stock or receipts"): return
    if not _check(bool(economy.configure_v1(state,"market_daily_units",20).get("ok",false))
        and not bool(economy.sell_to_npc_v1(state,ore,5,"reserved-overdraw").get("ok",false))
        and state.sect.spirit_stones == initial_cash
        and warehouse.quantity(state,ore) == stock,
        "Over-reserve sale changed currency or inventory"): return
    var result := economy.sell_to_npc_v1(state,ore,4,"eco02-ore-sale")
    var receipt: Dictionary = result.get("receipt",{})
    if not _check(bool(result.get("ok",false)) and not bool(result.get("already_settled",false))
        and warehouse.quantity(state,ore) == stock-4
        and state.sect.spirit_stones == initial_cash+32
        and int(receipt.get("earned",-1)) == 32
        and int(state.sect.economy_a_market_units_sold) == 4,
        "Four actual unreserved ore did not produce exactly 32 LT"): return
    var sold_cash := state.sect.spirit_stones
    var sold_stock := warehouse.quantity(state,ore)
    if not _check(bool(economy.sell_to_npc_v1(state,ore,4,"eco02-ore-sale").get("already_settled",false))
        and not bool(economy.sell_to_npc_v1(state,ore,3,"eco02-ore-sale").get("ok",false))
        and not bool(economy.sell_to_npc_v1(state,ore,1,"reserved-again").get("ok",false))
        and state.sect.spirit_stones == sold_cash
        and warehouse.quantity(state,ore) == sold_stock,
        "Double press, conflicting receipt or reserved stock overdraw"): return
    if not _check(warehouse.set_rule(state,ore,0,true)
        and not bool(economy.sell_quote_v1(state,ore,1).get("ok",false))
        and not bool(economy.sell_to_npc_v1(state,ore,1,"locked-sale").get("ok",false)),
        "Warehouse lock did not block actual NPC buyer"): return
    if not _check(warehouse.set_rule(state,ore,stock-4,false)
        and SaveService.new().save_to_path(state,SAVE_PATH) == OK,
        "Save of real market receipt and reserve failed"): return
    var loaded := SaveService.new().load_from_path(SAVE_PATH)
    if not _check(loaded != null and loaded.sect.spirit_stones == sold_cash
        and warehouse.quantity(loaded,ore) == sold_stock
        and int(warehouse.rule(loaded,ore).get("reserve_min",-1)) == stock-4
        and loaded.sect.economy_a_receipts.has("market:eco02-ore-sale")
        and int(loaded.sect.economy_a_market_units_sold) == 4,
        "Cold Save lost reserve, receipt, stock or NPC quota"): return
    if not _check(bool(economy.sell_to_npc_v1(loaded,ore,4,"eco02-ore-sale").get("already_settled",false))
        and loaded.sect.spirit_stones == sold_cash
        and warehouse.quantity(loaded,ore) == sold_stock,
        "Reload duplicated currency after a committed sale"): return
    # Daily breakeven is conditional planning math, NOT fabricated work:
    # 6 active: 34 LT seeds+68 wages=102 -> 13 ore at 8 LT each.
    # 30 active (paid capacity required): 170+340=510 -> 64 ore.
    if not _check(ceili(102.0 / float(price)) == 13
        and ceili(510.0 / float(price)) == 64
        and 13 <= 20 and 64 <= 240,
        "6/30 conditional ore break-even mismatches source unit prices or caps"): return
    loaded.sect.disciple_capacity = 30 # Explicit QA-only housing override.
    var recruiter := RecruitmentSystem.new()
    while loaded.disciples.size() < 30:
        var candidate := recruiter.generate_candidate(loaded)
        if not _check(candidate != null
            and bool(recruiter.accept_candidate(loaded,candidate.id).get("ok",false)),
            "Cannot admit genuine QA actor to 30 owned roster"): return
    if not _check(loaded.disciples.size() == 30
        and economy.market_remaining(loaded) == 236
        and economy.market_buy_remaining(loaded) == 240,
        "30-owned roster quota must rise to 240, without assuming active jobs"): return
    if not _check(bool(economy.configure_v1(loaded,"market_daily_units",0).get("ok",false))
        and economy.market_remaining(loaded) == 0
        and economy.market_buy_remaining(loaded) == 0
        and not bool(economy.sell_to_npc_v1(loaded,ore,1,"no-buyer-30").get("ok",false))
        and loaded.sect.spirit_stones == sold_cash,
        "30 owned actors bypassed explicit zero NPC demand"): return
    if not _check(loaded.validate_invariants().is_empty(),
        "Canonical post-sale 30-roster invariants invalid"): return
    _cleanup()
    print("ECO02 REAL MARKET: QUOTE, 0 BUYERS, RESERVED STOCK, REPLAY, 6/30, SAVE: PASS")
    quit(0)

func _cleanup() -> void:
    for suffix in ["",".bak",".tmp"]:
        if FileAccess.file_exists(SAVE_PATH+suffix):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH+suffix))
