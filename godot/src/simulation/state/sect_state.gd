class_name SectState
extends RefCounted

var treasury: int = 1000
var disciple_capacity: int = 6
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
        "disciple_capacity": disciple_capacity,
        "market_stock": market_stock.duplicate(true),
        "base_prices": base_prices.duplicate(true)
    }

static func from_dict(data: Dictionary) -> SectState:
    var state := SectState.new()
    state.treasury = int(data.get("treasury", 1000))
    state.disciple_capacity = int(data.get("disciple_capacity", 6))
    state.market_stock = _int_dictionary(data.get("market_stock", {}))
    state.base_prices = _int_dictionary(data.get("base_prices", state.base_prices))
    return state

static func _int_dictionary(value: Variant) -> Dictionary:
    var normalized: Dictionary = {}
    if not (value is Dictionary):
        return normalized

    var keys: Array = value.keys()
    keys.sort()
    for key in keys:
        normalized[str(key)] = int(value[key])
    return normalized
