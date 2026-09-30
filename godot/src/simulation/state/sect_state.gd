class_name SectState
extends RefCounted

var treasury: int = 1000
var market_stock: Dictionary = {}
var base_prices: Dictionary = {
    "truc_linh_thao": 8,
    "lang_bi": 12,
    "lang_huyet": 18,
    "hac_lang_cot": 28
}

func to_dict() -> Dictionary:
    return {
        "treasury": treasury,
        "market_stock": market_stock.duplicate(true),
        "base_prices": base_prices.duplicate(true)
    }

static func from_dict(data: Dictionary) -> SectState:
    var state := SectState.new()
    state.treasury = int(data.get("treasury", 1000))
    state.market_stock = data.get("market_stock", {}).duplicate(true)
    state.base_prices = data.get("base_prices", state.base_prices).duplicate(true)
    return state
