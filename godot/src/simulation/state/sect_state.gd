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

# P1.6 is kept inside sect state so older SimulationState save payloads remain valid.
var needs_enabled: bool = false
var medicine_stock: int = 0
var supply_stock: int = 0
var lodging_capacity: int = 6
var needs_priority: StringName = &"balanced"
var needs_event_count: int = 0
var needs_stats: Dictionary = {
    "medicine_used": 0,
    "supplies_used": 0,
    "medicine_produced": 0,
    "supplies_produced": 0,
    "lodging_expansions": 0,
    "overcrowded_rests": 0
}

# P2.1 global switch/counter. Per-disciple cultivation state lives on DiscipleState.
var cultivation_enabled: bool = false
var cultivation_event_count: int = 0

func to_dict() -> Dictionary:
    return {
        "treasury": treasury,
        "disciple_capacity": disciple_capacity,
        "market_stock": market_stock.duplicate(true),
        "base_prices": base_prices.duplicate(true),
        "needs_enabled": needs_enabled,
        "medicine_stock": medicine_stock,
        "supply_stock": supply_stock,
        "lodging_capacity": lodging_capacity,
        "needs_priority": str(needs_priority),
        "needs_event_count": needs_event_count,
        "needs_stats": needs_stats.duplicate(true),
        "cultivation_enabled": cultivation_enabled,
        "cultivation_event_count": cultivation_event_count
    }

static func from_dict(data: Dictionary) -> SectState:
    var state := SectState.new()
    state.treasury = int(data.get("treasury", 1000))
    state.disciple_capacity = int(data.get("disciple_capacity", 6))
    state.market_stock = _int_dictionary(data.get("market_stock", {}))
    state.base_prices = _int_dictionary(data.get("base_prices", state.base_prices))
    state.needs_enabled = bool(data.get("needs_enabled", false))
    state.medicine_stock = maxi(int(data.get("medicine_stock", 0)), 0)
    state.supply_stock = maxi(int(data.get("supply_stock", 0)), 0)
    state.lodging_capacity = maxi(int(data.get("lodging_capacity", state.disciple_capacity)), 1)
    state.needs_priority = StringName(data.get("needs_priority", "balanced"))
    state.needs_event_count = maxi(int(data.get("needs_event_count", 0)), 0)
    state.cultivation_enabled = bool(data.get("cultivation_enabled", false))
    state.cultivation_event_count = maxi(int(data.get("cultivation_event_count", 0)), 0)

    var saved_stats = data.get("needs_stats", {})
    if saved_stats is Dictionary:
        for key in state.needs_stats.keys():
            state.needs_stats[key] = maxi(int(saved_stats.get(key, 0)), 0)
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
