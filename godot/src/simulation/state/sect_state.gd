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

# P1.6
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

# P2.1
var cultivation_enabled: bool = false
var cultivation_event_count: int = 0

# P2.2
var spiritual_roots_enabled: bool = false
var spiritual_root_event_count: int = 0

# P2.3 sect-owned technique economy.
var techniques_enabled: bool = false
var spirit_stones: int = 0
var technique_library: Dictionary = {}
var technique_manuals: Dictionary = {}
var technique_fragments: Dictionary = {}
var technique_materials: Dictionary = {}
var technique_gacha_index: int = 0
var technique_event_count: int = 0

# P2.4 path identity is derived from per-disciple accumulated path XP.
var cultivation_paths_enabled: bool = false
var cultivation_path_event_count: int = 0

# P2.5 real-time autonomous combat skills.
var combat_skills_enabled: bool = false
var combat_skill_event_count: int = 0

func to_dict() -> Dictionary:
    var data := {
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
    if spiritual_roots_enabled or spiritual_root_event_count > 0:
        data["spiritual_roots_enabled"] = spiritual_roots_enabled
        data["spiritual_root_event_count"] = spiritual_root_event_count
    if techniques_enabled or technique_event_count > 0 or spirit_stones > 0:
        data["techniques_enabled"] = techniques_enabled
        data["spirit_stones"] = spirit_stones
        data["technique_library"] = technique_library.duplicate(true)
        data["technique_manuals"] = technique_manuals.duplicate(true)
        data["technique_fragments"] = technique_fragments.duplicate(true)
        data["technique_materials"] = technique_materials.duplicate(true)
        data["technique_gacha_index"] = technique_gacha_index
        data["technique_event_count"] = technique_event_count
    if cultivation_paths_enabled or cultivation_path_event_count > 0:
        data["cultivation_paths_enabled"] = cultivation_paths_enabled
        data["cultivation_path_event_count"] = cultivation_path_event_count
    if combat_skills_enabled or combat_skill_event_count > 0:
        data["combat_skills_enabled"] = combat_skills_enabled
        data["combat_skill_event_count"] = combat_skill_event_count
    return data

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
    state.spiritual_roots_enabled = bool(data.get("spiritual_roots_enabled", false))
    state.spiritual_root_event_count = maxi(int(data.get("spiritual_root_event_count", 0)), 0)
    state.techniques_enabled = bool(data.get("techniques_enabled", false))
    state.spirit_stones = maxi(int(data.get("spirit_stones", 0)), 0)
    state.technique_library = _bool_dictionary(data.get("technique_library", {}))
    state.technique_manuals = _int_dictionary(data.get("technique_manuals", {}))
    state.technique_fragments = _int_dictionary(data.get("technique_fragments", {}))
    state.technique_materials = _int_dictionary(data.get("technique_materials", {}))
    state.technique_gacha_index = maxi(int(data.get("technique_gacha_index", 0)), 0)
    state.technique_event_count = maxi(int(data.get("technique_event_count", 0)), 0)
    state.cultivation_paths_enabled = bool(data.get("cultivation_paths_enabled", false))
    state.cultivation_path_event_count = maxi(int(data.get("cultivation_path_event_count", 0)), 0)
    state.combat_skills_enabled = bool(data.get("combat_skills_enabled", false))
    state.combat_skill_event_count = maxi(int(data.get("combat_skill_event_count", 0)), 0)

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
        normalized[str(key)] = maxi(int(value[key]), 0)
    return normalized

static func _bool_dictionary(value: Variant) -> Dictionary:
    var normalized: Dictionary = {}
    if not (value is Dictionary):
        return normalized
    var keys: Array = value.keys()
    keys.sort()
    for key in keys:
        if bool(value[key]):
            normalized[str(key)] = true
    return normalized
