class_name TechniqueSystem
extends RefCounted

const MAX_LEARNED_TECHNIQUES := 3
const MAX_TECHNIQUE_LEVEL := 5
const GACHA_COST := 100
const INITIAL_SECT_SPIRIT_STONES := 500
const MASTERY_GAIN := 12.0

const SPECIAL_STONE_ITEM := "p23:spirit_stone"
const FRAGMENT_PREFIX := "p23:fragment:"
const MATERIAL_PREFIX := "p23:material:"

const RARITY_COMMON := &"common"
const RARITY_MYSTERIOUS := &"mysterious"
const RARITY_EARTH := &"earth"
const RARITY_HEAVEN := &"heaven"
const VALID_RARITIES := [RARITY_COMMON, RARITY_MYSTERIOUS, RARITY_EARTH, RARITY_HEAVEN]

const MATERIAL_ESSENCE := &"linh_tuy"
const MATERIAL_IRON := &"huyen_thiet"
const MATERIAL_CORE := &"yeu_dan"
const VALID_MATERIALS := [MATERIAL_ESSENCE, MATERIAL_IRON, MATERIAL_CORE]

const RARITY_NAMES := {
    "common": "Phàm phẩm",
    "mysterious": "Huyền phẩm",
    "earth": "Địa phẩm",
    "heaven": "Thiên phẩm"
}

const PATH_NAMES := {
    "sword": "Kiếm",
    "body": "Thể",
    "spell": "Pháp"
}

const ROLE_NAMES := {
    "growth": "Tu luyện",
    "offense": "Công kích",
    "defense": "Phòng thủ",
    "stability": "Ổn định"
}

const TECHNIQUES := {
    "duong_khi_quyet": {
        "name": "Dưỡng Khí Quyết",
        "rarity": "common",
        "path": "spell",
        "element": "wood",
        "role": "growth",
        "gacha_weight": 38.0,
        "fragment_required": 8,
        "learn_contribution": 40,
        "learn_stones": 15,
        "sale_stones": 28,
        "cultivation_per_level": 0.05,
        "combat_per_level": 0.0,
        "defense_per_level": 0.0,
        "breakthrough_per_level": 0.008,
        "failure_reduction_per_level": 0.02,
        "upgrade_materials": {"linh_tuy": 2}
    },
    "huyen_giap_cong": {
        "name": "Huyền Giáp Công",
        "rarity": "mysterious",
        "path": "body",
        "element": "earth",
        "role": "defense",
        "gacha_weight": 20.0,
        "fragment_required": 12,
        "learn_contribution": 75,
        "learn_stones": 30,
        "sale_stones": 65,
        "cultivation_per_level": 0.01,
        "combat_per_level": 0.6,
        "defense_per_level": 0.035,
        "breakthrough_per_level": 0.004,
        "failure_reduction_per_level": 0.02,
        "upgrade_materials": {"linh_tuy": 1, "huyen_thiet": 2}
    },
    "liet_chien_quyet": {
        "name": "Liệt Chiến Quyết",
        "rarity": "mysterious",
        "path": "body",
        "element": "fire",
        "role": "offense",
        "gacha_weight": 18.0,
        "fragment_required": 12,
        "learn_contribution": 80,
        "learn_stones": 32,
        "sale_stones": 70,
        "cultivation_per_level": 0.00,
        "combat_per_level": 2.0,
        "defense_per_level": 0.0,
        "breakthrough_per_level": 0.0,
        "failure_reduction_per_level": 0.0,
        "upgrade_materials": {"huyen_thiet": 1, "yeu_dan": 1}
    },
    "thanh_phong_kiem_quyet": {
        "name": "Thanh Phong Kiếm Quyết",
        "rarity": "earth",
        "path": "sword",
        "element": "metal",
        "role": "offense",
        "gacha_weight": 10.0,
        "fragment_required": 18,
        "learn_contribution": 145,
        "learn_stones": 55,
        "sale_stones": 150,
        "cultivation_per_level": 0.015,
        "combat_per_level": 3.0,
        "defense_per_level": 0.0,
        "breakthrough_per_level": 0.004,
        "failure_reduction_per_level": 0.0,
        "upgrade_materials": {"huyen_thiet": 2, "yeu_dan": 1}
    },
    "xich_viem_chan_quyet": {
        "name": "Xích Viêm Chân Quyết",
        "rarity": "earth",
        "path": "spell",
        "element": "fire",
        "role": "offense",
        "gacha_weight": 9.0,
        "fragment_required": 18,
        "learn_contribution": 150,
        "learn_stones": 58,
        "sale_stones": 160,
        "cultivation_per_level": 0.02,
        "combat_per_level": 2.6,
        "defense_per_level": 0.0,
        "breakthrough_per_level": 0.006,
        "failure_reduction_per_level": 0.0,
        "upgrade_materials": {"linh_tuy": 1, "yeu_dan": 2}
    },
    "han_nguyet_tam_phap": {
        "name": "Hàn Nguyệt Tâm Pháp",
        "rarity": "heaven",
        "path": "spell",
        "element": "water",
        "role": "stability",
        "gacha_weight": 5.0,
        "fragment_required": 30,
        "learn_contribution": 280,
        "learn_stones": 95,
        "sale_stones": 360,
        "cultivation_per_level": 0.025,
        "combat_per_level": 1.0,
        "defense_per_level": 0.015,
        "breakthrough_per_level": 0.018,
        "failure_reduction_per_level": 0.06,
        "upgrade_materials": {"linh_tuy": 2, "huyen_thiet": 2, "yeu_dan": 2}
    }
}

const GACHA_SEED_OFFSET := 55291
const FARM_SEED_OFFSET := 88069
const HASH_MODULUS := 2147483629

var roots := SpiritualRootSystem.new()
var warehouse := WarehouseSystem.new()

func initialize(state: SimulationState) -> void:
    if not state.sect.spiritual_roots_enabled:
        return
    state.sect.techniques_enabled = true
    if state.sect.spirit_stones <= 0:
        state.sect.spirit_stones = INITIAL_SECT_SPIRIT_STONES

    var disciple_ids: Array = state.disciples.keys()
    disciple_ids.sort()
    for raw_id in disciple_ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        roots.ensure_disciple_elements(state, disciple)

    var candidate_ids: Array = state.recruitment_candidates.keys()
    candidate_ids.sort()
    for raw_id in candidate_ids:
        var candidate: CandidateState = state.recruitment_candidates[raw_id]
        roots.ensure_candidate_elements(state, candidate)

func definition(technique_id: StringName) -> Dictionary:
    return TECHNIQUES.get(str(technique_id), {})

func technique_name(technique_id: StringName) -> String:
    return str(definition(technique_id).get("name", technique_id))

func rarity_name(technique_id: StringName) -> String:
    var rarity := str(definition(technique_id).get("rarity", "common"))
    return str(RARITY_NAMES.get(rarity, rarity))

func path_name(technique_id: StringName) -> String:
    var path := str(definition(technique_id).get("path", "spell"))
    return str(PATH_NAMES.get(path, path))

func role_name(technique_id: StringName) -> String:
    var role := str(definition(technique_id).get("role", "growth"))
    return str(ROLE_NAMES.get(role, role))

func element_name(technique_id: StringName) -> String:
    return roots.element_name(StringName(definition(technique_id).get("element", "")))

func fragment_required(technique_id: StringName) -> int:
    return int(definition(technique_id).get("fragment_required", 0))

func is_archived(state: SimulationState, technique_id: StringName) -> bool:
    return bool(state.sect.technique_library.get(str(technique_id), false))

func manual_count(state: SimulationState, technique_id: StringName) -> int:
    return int(state.sect.technique_manuals.get(str(technique_id), 0))

func gacha(state: SimulationState) -> Dictionary:
    if not state.sect.techniques_enabled:
        return _result(false, "techniques_disabled")
    if state.sect.spirit_stones < GACHA_COST:
        return _result(false, "not_enough_sect_spirit_stones")

    state.sect.spirit_stones -= GACHA_COST
    state.sect.technique_gacha_index += 1
    var rng := GameRng.new(state.seed + GACHA_SEED_OFFSET + state.sect.technique_gacha_index * 104729)
    var technique_id := _weighted_technique_pick(rng, 4)
    _add_manual(state, technique_id, 1)
    state.sect.technique_event_count += 1
    return {
        "ok": true,
        "reason": "gacha",
        "technique_id": str(technique_id),
        "name": technique_name(technique_id),
        "rarity": str(definition(technique_id).get("rarity", "common"))
    }

func archive_manual(state: SimulationState, technique_id: StringName) -> Dictionary:
    if not state.sect.techniques_enabled or definition(technique_id).is_empty():
        return _result(false, "invalid_technique")
    if is_archived(state, technique_id):
        return _result(false, "already_archived")
    if manual_count(state, technique_id) <= 0:
        return _result(false, "manual_missing")

    _add_manual(state, technique_id, -1)
    state.sect.technique_library[str(technique_id)] = true
    state.sect.technique_event_count += 1
    return _result(true, "archived")

func sell_manual(state: SimulationState, technique_id: StringName, quantity: int = 1) -> Dictionary:
    if not state.sect.techniques_enabled or definition(technique_id).is_empty() or quantity <= 0:
        return _result(false, "invalid_sale")
    if manual_count(state, technique_id) < quantity:
        return _result(false, "manual_missing")

    var unit_value := int(definition(technique_id).get("sale_stones", 0))
    _add_manual(state, technique_id, -quantity)
    state.sect.spirit_stones += unit_value * quantity
    state.sect.technique_event_count += 1
    return {"ok": true, "reason": "sold", "spirit_stones": unit_value * quantity}

func craft_manual(state: SimulationState, technique_id: StringName) -> Dictionary:
    if not state.sect.techniques_enabled or definition(technique_id).is_empty():
        return _result(false, "invalid_technique")
    var required := fragment_required(technique_id)
    var owned := int(state.sect.technique_fragments.get(str(technique_id), 0))
    if required <= 0 or owned < required:
        return _result(false, "not_enough_fragments")

    _add_int(state.sect.technique_fragments, str(technique_id), -required)
    _add_manual(state, technique_id, 1)
    state.sect.technique_event_count += 1
    return _result(true, "crafted")

func learn_technique(state: SimulationState, disciple: DiscipleState, technique_id: StringName) -> Dictionary:
    if not state.sect.techniques_enabled or not is_archived(state, technique_id):
        return _result(false, "not_archived")
    if disciple.learned_techniques.has(str(technique_id)):
        return _result(false, "already_learned")
    if disciple.learned_techniques.size() >= MAX_LEARNED_TECHNIQUES:
        return _result(false, "technique_slots_full")

    var info := definition(technique_id)
    var contribution_cost := int(info.get("learn_contribution", 0))
    var stone_cost := int(info.get("learn_stones", 0))
    if disciple.contribution_points < contribution_cost:
        return _result(false, "not_enough_contribution")
    if disciple.spirit_stones < stone_cost:
        return _result(false, "not_enough_personal_spirit_stones")

    disciple.contribution_points -= contribution_cost
    disciple.spirit_stones -= stone_cost
    state.sect.spirit_stones += stone_cost
    disciple.learned_techniques[str(technique_id)] = {"level": 1, "xp": 0.0}
    if disciple.active_technique_id == &"":
        disciple.active_technique_id = technique_id
    disciple.metrics["techniques_learned"] = int(disciple.metrics.get("techniques_learned", 0)) + 1
    state.sect.technique_event_count += 1
    return _result(true, "learned")

func set_active_technique(state: SimulationState, disciple: DiscipleState, technique_id: StringName) -> bool:
    if not state.sect.techniques_enabled or not disciple.learned_techniques.has(str(technique_id)):
        return false
    disciple.active_technique_id = technique_id
    state.sect.technique_event_count += 1
    return true

func mastery_required(level: int) -> float:
    if level >= MAX_TECHNIQUE_LEVEL:
        return 0.0
    return 80.0 * float(level * level)

func train_active_technique(state: SimulationState, disciple: DiscipleState) -> float:
    if not state.sect.techniques_enabled or disciple.active_technique_id == &"":
        return 0.0
    var key := str(disciple.active_technique_id)
    if not disciple.learned_techniques.has(key):
        return 0.0
    var mastery: Dictionary = disciple.learned_techniques[key]
    var level := int(mastery.get("level", 1))
    if level >= MAX_TECHNIQUE_LEVEL:
        return 0.0
    var required := mastery_required(level)
    var before := float(mastery.get("xp", 0.0))
    if before >= required - 0.000001:
        return 0.0

    var info := definition(disciple.active_technique_id)
    var element := StringName(info.get("element", ""))
    var gained := MASTERY_GAIN * roots.technique_mastery_multiplier(disciple, element)
    mastery["xp"] = minf(required, before + gained)
    disciple.learned_techniques[key] = mastery
    disciple.metrics["technique_training_sessions"] = int(disciple.metrics.get("technique_training_sessions", 0)) + 1
    return float(mastery["xp"]) - before

func upgrade_technique(state: SimulationState, disciple: DiscipleState, technique_id: StringName) -> Dictionary:
    if not state.sect.techniques_enabled or not disciple.learned_techniques.has(str(technique_id)):
        return _result(false, "not_learned")
    var key := str(technique_id)
    var mastery: Dictionary = disciple.learned_techniques[key]
    var level := int(mastery.get("level", 1))
    if level >= MAX_TECHNIQUE_LEVEL:
        return _result(false, "max_level")
    if float(mastery.get("xp", 0.0)) + 0.000001 < mastery_required(level):
        return _result(false, "mastery_not_ready")

    var costs := upgrade_material_cost(technique_id, level)
    if state.sect.p3_7_resources_enabled:
        if not warehouse.consume_requirements(state, costs):
            return _result(false, "materials_missing")
    else:
        for material_id in costs.keys():
            if int(state.sect.technique_materials.get(material_id, 0)) < int(costs[material_id]):
                return _result(false, "materials_missing")
        for material_id in costs.keys():
            _add_int(state.sect.technique_materials, str(material_id), -int(costs[material_id]))

    mastery["level"] = level + 1
    mastery["xp"] = 0.0
    disciple.learned_techniques[key] = mastery
    disciple.metrics["technique_upgrades"] = int(disciple.metrics.get("technique_upgrades", 0)) + 1
    state.sect.technique_event_count += 1
    return {"ok": true, "reason": "upgraded", "level": level + 1, "costs": costs}

func upgrade_material_cost(technique_id: StringName, current_level: int) -> Dictionary:
    var result: Dictionary = {}
    var base: Dictionary = definition(technique_id).get("upgrade_materials", {})
    for material_id in base.keys():
        result[str(material_id)] = int(base[material_id]) * maxi(current_level, 1)
    return result

func cultivation_gain_multiplier(state: SimulationState, disciple: DiscipleState) -> float:
    var context := _active_context(state, disciple)
    if context.is_empty():
        return 1.0
    var info: Dictionary = context["definition"]
    var level := int(context["level"])
    var compatibility := float(context["effect_compatibility"])
    return maxf(0.5, 1.0 + float(info.get("cultivation_per_level", 0.0)) * level * compatibility)

func combat_power_bonus(state: SimulationState, disciple: DiscipleState) -> float:
    var context := _active_context(state, disciple)
    if context.is_empty():
        return 0.0
    var info: Dictionary = context["definition"]
    return float(info.get("combat_per_level", 0.0)) * int(context["level"]) * float(context["effect_compatibility"])

func incoming_damage_multiplier(state: SimulationState, disciple: DiscipleState) -> float:
    var context := _active_context(state, disciple)
    if context.is_empty():
        return 1.0
    var info: Dictionary = context["definition"]
    var reduction := float(info.get("defense_per_level", 0.0)) * int(context["level"]) * float(context["effect_compatibility"])
    return clampf(1.0 - reduction, 0.55, 1.0)

func breakthrough_bonus(state: SimulationState, disciple: DiscipleState) -> float:
    var context := _active_context(state, disciple)
    if context.is_empty():
        return 0.0
    var info: Dictionary = context["definition"]
    return float(info.get("breakthrough_per_level", 0.0)) * int(context["level"]) * float(context["effect_compatibility"])

func breakthrough_failure_multiplier(state: SimulationState, disciple: DiscipleState) -> float:
    var context := _active_context(state, disciple)
    if context.is_empty():
        return 1.0
    var info: Dictionary = context["definition"]
    var reduction := float(info.get("failure_reduction_per_level", 0.0)) * int(context["level"]) * float(context["effect_compatibility"])
    return clampf(1.0 - reduction, 0.45, 1.0)

func roll_farm_loot(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    if not state.sect.techniques_enabled or disciple.region_id == &"sect":
        return {}
    var region: RegionState = state.regions.get(disciple.region_id)
    if region == null:
        return {}

    var combat_index := int(disciple.metrics.get("combats", 0))
    var rng := GameRng.new(_farm_seed(state.seed, state.tick, str(disciple.id), combat_index))
    var loot: Dictionary = {}
    var danger := clampi(region.danger, 1, 3)

    var personal_stones := rng.randi_range(0, danger + 1)
    if personal_stones > 0:
        loot[SPECIAL_STONE_ITEM] = personal_stones

    var material_id := str(MATERIAL_ESSENCE)
    if danger == 2:
        material_id = str(MATERIAL_IRON) if rng.chance(0.45) else str(MATERIAL_ESSENCE)
    elif danger >= 3:
        material_id = str(MATERIAL_CORE) if rng.chance(0.50) else str(MATERIAL_IRON)
    loot[MATERIAL_PREFIX + material_id] = 1

    var fragment_chance := 0.18 + float(danger) * 0.08
    if rng.chance(fragment_chance):
        var max_rarity := danger + 1
        var technique_id := _weighted_technique_pick(rng, max_rarity)
        loot[FRAGMENT_PREFIX + str(technique_id)] = 1

    return loot

func deposit_special_inventory(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    if not state.sect.techniques_enabled or disciple.region_id != &"sect":
        return {"stones": 0, "fragments": 0, "materials": 0, "contribution": 0}

    var stone_gain := 0
    var fragment_gain := 0
    var material_gain := 0
    var contribution_gain := 0
    var remove_keys: Array = []
    var item_keys: Array = disciple.inventory.keys()
    item_keys.sort()

    for raw_key in item_keys:
        var key := str(raw_key)
        var quantity := int(disciple.inventory[raw_key])
        if quantity <= 0:
            continue
        if key == SPECIAL_STONE_ITEM:
            stone_gain += quantity
            disciple.spirit_stones += quantity
            remove_keys.append(raw_key)
        elif key.begins_with(FRAGMENT_PREFIX):
            var technique_id := key.substr(FRAGMENT_PREFIX.length())
            if TECHNIQUES.has(technique_id):
                _add_int(state.sect.technique_fragments, technique_id, quantity)
                fragment_gain += quantity
                contribution_gain += quantity * _fragment_contribution(StringName(technique_id))
                remove_keys.append(raw_key)
        elif key.begins_with(MATERIAL_PREFIX):
            var material_id := key.substr(MATERIAL_PREFIX.length())
            if VALID_MATERIALS.has(StringName(material_id)):
                var deposited := false
                if state.sect.p3_7_resources_enabled:
                    deposited = warehouse.add(state, StringName(material_id), quantity)
                else:
                    _add_int(state.sect.technique_materials, material_id, quantity)
                    deposited = true
                if deposited:
                    material_gain += quantity
                    contribution_gain += quantity * 2
                    remove_keys.append(raw_key)

    for key in remove_keys:
        disciple.inventory.erase(key)
    if contribution_gain > 0:
        disciple.contribution_points += contribution_gain
    if stone_gain > 0 or fragment_gain > 0 or material_gain > 0:
        disciple.metrics["special_deposits"] = int(disciple.metrics.get("special_deposits", 0)) + 1
        state.sect.technique_event_count += 1

    return {"stones": stone_gain, "fragments": fragment_gain, "materials": material_gain, "contribution": contribution_gain}

func validate_invariants(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if not state.sect.techniques_enabled:
        return errors
    if state.sect.spirit_stones < 0 or state.sect.technique_gacha_index < 0 or state.sect.technique_event_count < 0:
        errors.append("Technique sect counters/resources cannot be negative.")

    for technique_id in state.sect.technique_library.keys():
        if not TECHNIQUES.has(str(technique_id)) or not bool(state.sect.technique_library[technique_id]):
            errors.append("Technique library contains an invalid entry %s." % technique_id)
    for bucket in [state.sect.technique_manuals, state.sect.technique_fragments]:
        for technique_id in bucket.keys():
            if not TECHNIQUES.has(str(technique_id)) or int(bucket[technique_id]) < 0:
                errors.append("Technique inventory contains an invalid entry %s." % technique_id)
    if state.sect.p3_7_resources_enabled:
        if not state.sect.technique_materials.is_empty():
            errors.append("Legacy technique materials must be empty under P3.7 warehouse authority.")
    else:
        for material_id in state.sect.technique_materials.keys():
            if not VALID_MATERIALS.has(StringName(material_id)) or int(state.sect.technique_materials[material_id]) < 0:
                errors.append("Technique material inventory contains invalid entry %s." % material_id)

    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        if disciple.contribution_points < 0 or disciple.spirit_stones < 0:
            errors.append("%s has negative contribution/spirit stones." % disciple.display_name)
        if disciple.learned_techniques.size() > MAX_LEARNED_TECHNIQUES:
            errors.append("%s exceeds the learned-technique cap." % disciple.display_name)
        if disciple.active_technique_id != &"" and not disciple.learned_techniques.has(str(disciple.active_technique_id)):
            errors.append("%s active technique is not learned." % disciple.display_name)
        for technique_id in disciple.learned_techniques.keys():
            if not TECHNIQUES.has(str(technique_id)):
                errors.append("%s learned invalid technique %s." % [disciple.display_name, technique_id])
                continue
            var mastery = disciple.learned_techniques[technique_id]
            if not (mastery is Dictionary):
                errors.append("%s technique mastery has invalid storage." % disciple.display_name)
                continue
            var level := int(mastery.get("level", 0))
            var xp := float(mastery.get("xp", -1.0))
            if level < 1 or level > MAX_TECHNIQUE_LEVEL or xp < -0.000001:
                errors.append("%s technique mastery is out of bounds." % disciple.display_name)
            var required := mastery_required(level)
            if required > 0.0 and xp > required + 0.000001:
                errors.append("%s technique XP exceeds upgrade threshold." % disciple.display_name)
    return errors

func _active_context(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    if not state.sect.techniques_enabled or disciple.active_technique_id == &"":
        return {}
    var key := str(disciple.active_technique_id)
    if not disciple.learned_techniques.has(key):
        return {}
    var info := definition(disciple.active_technique_id)
    if info.is_empty():
        return {}
    var mastery: Dictionary = disciple.learned_techniques[key]
    var element := StringName(info.get("element", ""))
    return {
        "definition": info,
        "level": int(mastery.get("level", 1)),
        "effect_compatibility": roots.technique_effect_multiplier(disciple, element)
    }

func _weighted_technique_pick(rng: GameRng, max_rarity_rank: int) -> StringName:
    var weighted: Dictionary = {}
    var ids: Array = TECHNIQUES.keys()
    ids.sort()
    for technique_id in ids:
        var info: Dictionary = TECHNIQUES[technique_id]
        if _rarity_rank(StringName(info.get("rarity", "common"))) <= max_rarity_rank:
            weighted[str(technique_id)] = float(info.get("gacha_weight", 1.0))
    return rng.weighted_pick(weighted)

func _rarity_rank(rarity: StringName) -> int:
    match rarity:
        RARITY_COMMON:
            return 1
        RARITY_MYSTERIOUS:
            return 2
        RARITY_EARTH:
            return 3
        RARITY_HEAVEN:
            return 4
        _:
            return 1

func _fragment_contribution(technique_id: StringName) -> int:
    match StringName(definition(technique_id).get("rarity", "common")):
        RARITY_COMMON:
            return 2
        RARITY_MYSTERIOUS:
            return 4
        RARITY_EARTH:
            return 7
        RARITY_HEAVEN:
            return 12
        _:
            return 1

func _add_manual(state: SimulationState, technique_id: StringName, delta: int) -> void:
    _add_int(state.sect.technique_manuals, str(technique_id), delta)

func _add_int(bucket: Dictionary, key: String, delta: int) -> void:
    var next := int(bucket.get(key, 0)) + delta
    if next <= 0:
        bucket.erase(key)
    else:
        bucket[key] = next

func _farm_seed(base_seed: int, tick: int, disciple_id: String, combat_index: int) -> int:
    return base_seed + FARM_SEED_OFFSET + tick * 1009 + combat_index * 7919 + _stable_hash(disciple_id) * 17

func _stable_hash(value: String) -> int:
    var result := 17
    for index in range(value.length()):
        result = int((result * 131 + value.unicode_at(index)) % HASH_MODULUS)
    return result

func _result(ok: bool, reason: String) -> Dictionary:
    return {"ok": ok, "reason": reason}
