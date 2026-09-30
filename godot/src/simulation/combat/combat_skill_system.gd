class_name CombatSkillSystem
extends RefCounted

const PATH_SWORD := &"sword"
const PATH_BODY := &"body"
const PATH_SPELL := &"spell"

const EFFECT_DAMAGE := &"damage"
const EFFECT_DASH := &"dash"
const EFFECT_GUARD := &"guard"
const EFFECT_BURN := &"burn"
const EFFECT_WEAKEN := &"weaken"
const EFFECT_FIRE_COMBO := &"fire_combo"

const SKILLS := {
    "thanh_phong_tram": {
        "name":"Thanh Phong Trảm", "path":"sword", "element":"metal", "min_stage":0,
        "effect":"damage", "damage_ratio":1.35, "range":2.0, "cast_time":0.30, "cooldown":2.8
    },
    "truy_phong_bo": {
        "name":"Truy Phong Bộ", "path":"sword", "element":"wood", "min_stage":4,
        "effect":"dash", "damage_ratio":0.75, "range":7.0, "cast_time":0.25, "cooldown":5.0, "dash_to":1.35
    },
    "ngu_kiem_thuat": {
        "name":"Ngự Kiếm Thuật", "path":"sword", "element":"metal", "min_stage":9,
        "effect":"damage", "damage_ratio":1.70, "range":7.0, "cast_time":0.65, "cooldown":6.5, "projectile_speed":10.0
    },
    "chan_son_quyen": {
        "name":"Chấn Sơn Quyền", "path":"body", "element":"earth", "min_stage":0,
        "effect":"weaken", "damage_ratio":1.45, "range":1.45, "cast_time":0.45, "cooldown":3.4,
        "weaken_multiplier":0.82, "weaken_duration":2.5
    },
    "kim_cuong_ho_the": {
        "name":"Kim Cương Hộ Thể", "path":"body", "element":"earth", "min_stage":3,
        "effect":"guard", "damage_ratio":0.0, "self_target":true, "range":0.0, "cast_time":0.25, "cooldown":8.0,
        "guard_multiplier":0.62, "guard_duration":3.5
    },
    "bat_dong_than": {
        "name":"Bất Động Thân", "path":"body", "element":"earth", "min_stage":9,
        "effect":"guard", "damage_ratio":0.0, "self_target":true, "range":0.0, "cast_time":0.45, "cooldown":14.0,
        "guard_multiplier":0.42, "guard_duration":4.5
    },
    "hoa_cau": {
        "name":"Hỏa Cầu", "path":"spell", "element":"fire", "min_stage":0,
        "effect":"burn", "damage_ratio":1.15, "range":7.5, "cast_time":0.65, "cooldown":3.8, "projectile_speed":8.0,
        "burn_ratio":0.16, "burn_duration":3.2
    },
    "han_suong_an": {
        "name":"Hàn Sương Ấn", "path":"spell", "element":"water", "min_stage":3,
        "effect":"weaken", "damage_ratio":0.90, "range":6.5, "cast_time":0.80, "cooldown":5.5, "projectile_speed":9.0,
        "weaken_multiplier":0.72, "weaken_duration":4.0
    },
    "liet_diem": {
        "name":"Liệt Diễm", "path":"spell", "element":"fire", "min_stage":9,
        "effect":"fire_combo", "damage_ratio":1.45, "range":6.0, "cast_time":1.00, "cooldown":7.0, "projectile_speed":8.5,
        "burning_bonus":1.35
    }
}

var roots := SpiritualRootSystem.new()
var paths := CultivationPathSystem.new()

func initialize(state: SimulationState) -> void:
    if not state.sect.cultivation_paths_enabled:
        return
    state.sect.combat_skills_enabled = true

func definition(skill_id: StringName) -> Dictionary:
    return SKILLS.get(str(skill_id), {})

func skill_name(skill_id: StringName) -> String:
    return str(definition(skill_id).get("name", skill_id))

func can_learn_skill(state: SimulationState, disciple: DiscipleState, skill_id: StringName) -> bool:
    if not state.sect.combat_skills_enabled:
        return false
    var data := definition(skill_id)
    if data.is_empty():
        return false
    return disciple.cultivation_stage_index >= int(data.get("min_stage", 0))

func learn_skill(state: SimulationState, disciple: DiscipleState, skill_id: StringName) -> bool:
    if not can_learn_skill(state, disciple, skill_id):
        return false
    var key := str(skill_id)
    if bool(disciple.learned_combat_skills.get(key, false)):
        return false
    disciple.learned_combat_skills[key] = true
    state.sect.combat_skill_event_count += 1
    return true

func usable_skills(state: SimulationState, disciple: DiscipleState) -> Array[StringName]:
    var result: Array[StringName] = []
    if not state.sect.combat_skills_enabled:
        return result
    var keys: Array = disciple.learned_combat_skills.keys()
    keys.sort()
    for raw_id in keys:
        var skill_id := StringName(raw_id)
        if bool(disciple.learned_combat_skills.get(str(skill_id), false)) and can_learn_skill(state, disciple, skill_id):
            result.append(skill_id)
    return result

func effect_multiplier(state: SimulationState, disciple: DiscipleState, skill_id: StringName) -> float:
    if not state.sect.combat_skills_enabled:
        return 1.0
    var data := definition(skill_id)
    if data.is_empty():
        return 1.0
    var multiplier := 1.0
    var skill_path := StringName(data.get("path", ""))
    var skill_element := StringName(data.get("element", ""))
    if state.sect.spiritual_roots_enabled:
        multiplier *= roots.technique_effect_multiplier(disciple, skill_element)
    if state.sect.cultivation_paths_enabled:
        multiplier *= paths.technique_effect_multiplier(state, disciple, skill_path)
    if state.sect.techniques_enabled and disciple.active_technique_id != &"":
        var technique := TechniqueSystem.TECHNIQUES.get(str(disciple.active_technique_id), {})
        if not technique.is_empty() and str(technique.get("path", "")) == str(skill_path):
            multiplier *= 1.08
            if str(technique.get("element", "")) == str(skill_element):
                multiplier *= 1.04
    return multiplier

func style_profile(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    var path := paths.active_technique_path(disciple) if state.sect.cultivation_paths_enabled else &""
    match path:
        PATH_SWORD:
            return {"id":"sword", "preferred_distance":1.65, "move_speed":3.10, "basic_range":1.90, "basic_interval":1.10, "basic_ratio":1.00}
        PATH_BODY:
            return {"id":"body", "preferred_distance":1.00, "move_speed":2.50, "basic_range":1.35, "basic_interval":1.45, "basic_ratio":1.15}
        PATH_SPELL:
            return {"id":"spell", "preferred_distance":5.00, "move_speed":2.70, "basic_range":5.50, "basic_interval":1.65, "basic_ratio":0.85}
        _:
            return {"id":"balanced", "preferred_distance":1.60, "move_speed":2.70, "basic_range":1.75, "basic_interval":1.35, "basic_ratio":1.00}

func validate_invariants(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if not state.sect.combat_skills_enabled:
        return errors
    if not state.sect.cultivation_paths_enabled:
        errors.append("Combat skills require P2.4 cultivation paths to be enabled.")
    if state.sect.combat_skill_event_count < 0:
        errors.append("Combat skill event count cannot be negative.")
    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        for raw_id in disciple.learned_combat_skills.keys():
            var skill_id := StringName(raw_id)
            if definition(skill_id).is_empty():
                errors.append("%s knows missing combat skill %s." % [disciple.display_name, skill_id])
            elif not bool(disciple.learned_combat_skills.get(str(skill_id), false)):
                errors.append("%s has invalid combat skill state for %s." % [disciple.display_name, skill_id])
            elif disciple.cultivation_stage_index < int(definition(skill_id).get("min_stage", 0)):
                errors.append("%s knows combat skill %s above their realm." % [disciple.display_name, skill_id])
    return errors
