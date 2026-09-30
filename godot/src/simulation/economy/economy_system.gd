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
