extends SceneTree

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _test_sell_transfer():
        return
    if not _test_heal_transfer():
        return
    if not _test_supply_transfer():
        return
    if not _test_market_reserve():
        return

    print("P0 ECONOMY CONTRACT TEST PASS")
    quit(0)

func _test_sell_transfer() -> bool:
    var state := P0Factory.create_state(101)
    var economy := EconomySystem.new()
    var disciple: DiscipleState = state.disciples.get(&"lam_thanh_vu")
    disciple.clear_inventory()
    disciple.add_item("lang_bi", 2)

    var money_before := state.total_money()
    var treasury_before := state.sect.treasury
    var wallet_before := disciple.wallet
    var earned := economy.sell_inventory(state, disciple)

    if earned <= 0:
        return _fail_bool("Sell contract failed: expected a positive transfer.")
    if state.total_money() != money_before:
        return _fail_bool("Sell contract failed: internal sale changed total money.")
    if state.sect.treasury != treasury_before - earned:
        return _fail_bool("Sell contract failed: sect treasury did not decrease by earned amount.")
    if disciple.wallet != wallet_before + earned:
        return _fail_bool("Sell contract failed: disciple wallet did not increase by earned amount.")
    return true

func _test_heal_transfer() -> bool:
    var state := P0Factory.create_state(202)
    var economy := EconomySystem.new()
    var disciple: DiscipleState = state.disciples.get(&"tran_mac")
    disciple.hp = 25.0
    disciple.wallet = 100

    var money_before := state.total_money()
    var treasury_before := state.sect.treasury
    var wallet_before := disciple.wallet

    if not economy.heal(state, disciple):
        return _fail_bool("Heal contract failed: funded heal was rejected.")
    if state.total_money() != money_before:
        return _fail_bool("Heal contract failed: internal healing changed total money.")
    if state.sect.treasury != treasury_before + EconomySystem.HEAL_FEE:
        return _fail_bool("Heal contract failed: sect treasury did not receive the heal fee.")
    if disciple.wallet != wallet_before - EconomySystem.HEAL_FEE:
        return _fail_bool("Heal contract failed: disciple wallet did not pay the heal fee.")
    if disciple.hp <= 25.0:
        return _fail_bool("Heal contract failed: HP did not recover.")
    return true

func _test_supply_transfer() -> bool:
    var state := P0Factory.create_state(303)
    var economy := EconomySystem.new()
    var disciple: DiscipleState = state.disciples.get(&"bach_nguyet")
    disciple.stamina = 35.0
    disciple.wallet = 100

    var money_before := state.total_money()
    var treasury_before := state.sect.treasury
    var wallet_before := disciple.wallet

    if not economy.buy_supplies(state, disciple):
        return _fail_bool("Supply contract failed: funded purchase was rejected.")
    if state.total_money() != money_before:
        return _fail_bool("Supply contract failed: internal purchase changed total money.")
    if state.sect.treasury != treasury_before + EconomySystem.SUPPLY_FEE:
        return _fail_bool("Supply contract failed: sect treasury did not receive the supply fee.")
    if disciple.wallet != wallet_before - EconomySystem.SUPPLY_FEE:
        return _fail_bool("Supply contract failed: disciple wallet did not pay the supply fee.")
    if disciple.stamina <= 35.0:
        return _fail_bool("Supply contract failed: stamina did not recover.")
    return true

func _test_market_reserve() -> bool:
    var state := P0Factory.create_state(404)
    var economy := EconomySystem.new()
    var disciple: DiscipleState = state.disciples.get(&"lam_an")
    state.sect.treasury = EconomySystem.MIN_TREASURY_RESERVE + 5
    disciple.clear_inventory()
    disciple.add_item("hac_lang_cot", 50)

    var treasury_before := state.sect.treasury
    var money_before := state.total_money()
    var earned := economy.sell_inventory(state, disciple)

    if state.sect.treasury < EconomySystem.MIN_TREASURY_RESERVE:
        return _fail_bool("Reserve contract failed: market purchase crossed the operating reserve.")
    if state.total_money() != money_before:
        return _fail_bool("Reserve contract failed: attempted market purchase changed total money.")
    if earned > treasury_before - EconomySystem.MIN_TREASURY_RESERVE:
        return _fail_bool("Reserve contract failed: market spent more than spendable treasury.")
    return true

func _fail_bool(message: String) -> bool:
    push_error(message)
    quit(1)
    return false
