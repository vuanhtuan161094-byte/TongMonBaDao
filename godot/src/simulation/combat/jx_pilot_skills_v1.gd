class_name JxPilotSkillsV1
extends RefCounted

# C4 pilot: explicit opt-in actor skills; never auto-teach from faction/root.
# Only these five V2-authored consumers are implemented. Other proposed JX
# abilities remain design-only. Raw JX IDs are traceability, not damage rules.
const SKILLS := {
    "jx_shaolin_15":{
        "source_id":15,"name":"Bất Động Minh Vương","school":"shaolin",
        "element":"metal","effect":"guard","cast_ticks":2,"cd_ticks":56,"duration_ticks":12
    },
    "jx_wudang_158":{
        "source_id":158,"name":"Kiếm Phi Kinh Thiên","school":"wudang",
        "element":"earth","effect":"projectile","ratio":1.10,"range":6.0,
        "cast_ticks":2,"cd_ticks":20,"speed":8.0
    },
    "jx_wudang_159":{
        "source_id":159,"name":"Thất Tinh Trận","school":"wudang",
        "element":"earth","effect":"party_defense","range":5.0,
        "cast_ticks":2,"cd_ticks":64,"duration_ticks":24
    },
    "jx_wudu_63":{
        "source_id":63,"name":"Độc Sa Chưởng","school":"wudu",
        "element":"wood","effect":"poison_hit","ratio":0.75,"range":5.0,
        "cast_ticks":2,"cd_ticks":20,"speed":8.0
    },
    "jx_emei_93":{
        "source_id":93,"name":"Từ Hàng Phổ Độ","school":"emei",
        "element":"water","effect":"heal_over_time","range":6.0,
        "cast_ticks":2,"cd_ticks":32
    }
}

static func valid_loadout(values: Variant) -> bool:
    if not (values is Array) or values.size() > 4:
        return false
    var seen: Dictionary = {}
    for value in values:
        if not (value is String or value is StringName):
            return false
        var key := str(value)
        if not SKILLS.has(key) or seen.has(key):
            return false
        seen[key] = true
    return true

static func definition(skill_id: String) -> Dictionary:
    return SKILLS.get(skill_id,{})

static func elemental_matchup(skill_element: String, target_primary: String) -> float:
    # Root V2 counter: metal>wood>earth>water>fire>metal.
    # A faction's element never silently replaces the actual skill element.
    var counters := {"metal":"wood","wood":"earth","earth":"water",
        "water":"fire","fire":"metal"}
    if not counters.has(skill_element) or not counters.has(target_primary):
        return 1.0
    if str(counters[skill_element]) == target_primary:
        return 1.25
    if str(counters[target_primary]) == skill_element:
        return 0.85
    return 1.0

static func matching_root_multiplier(values: Dictionary, skill_element: String) -> float:
    if not values.has(skill_element):
        return 1.0
    var perfected := 0
    for value in values.values():
        if int(value) == 100:
            perfected += 1
    var resonance := [1.0,1.1,1.25,1.45,1.70,2.0][mini(perfected,5)]
    var purity := clampi(int(values[skill_element]),1,100)
    return 1.0 + float(purity)*0.003*resonance

static func valid_roots(values: Variant) -> bool:
    if not (values is Dictionary):
        return false
    for key in values.keys():
        if not ["metal","wood","water","fire","earth"].has(str(key)):
            return false
        if not (values[key] is int) or int(values[key]) < 1 or int(values[key]) > 100:
            return false
    return true
