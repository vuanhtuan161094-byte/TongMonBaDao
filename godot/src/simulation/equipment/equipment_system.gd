class_name EquipmentSystem
extends RefCounted

const SLOT_WEAPON := &"weapon"
const SLOT_ARMOR := &"armor"
const SLOT_TALISMAN := &"talisman"
const VALID_SLOTS := [SLOT_WEAPON, SLOT_ARMOR, SLOT_TALISMAN]

const POLICY_BALANCED := &"balanced"
const POLICY_COMBAT := &"combat"
const POLICY_FRUGAL := &"frugal"
const VALID_POLICIES := [POLICY_BALANCED, POLICY_COMBAT, POLICY_FRUGAL]

const LOCATION_STORAGE := &"storage"
const LOCATION_SHOP := &"shop"
const LOCATION_EQUIPPED := &"equipped"
const VALID_LOCATIONS := [LOCATION_STORAGE, LOCATION_SHOP, LOCATION_EQUIPPED]

const MATERIAL_NAMES := {
    "linh_moc": "Linh Mộc",
    "thanh_thiet": "Thanh Thiết",
    "tinh_lang_bi": "Tinh Lang Bì",
    "yeu_dan": "Yêu Đan",
    "tam_mach_ban": "Tầm Mạch Bàn",
    "thanh_linh_thao": "Thanh Linh Thảo",
    "linh_tuyen_chi_tam": "Linh Tuyền Chi Tâm"
}

const QUALITY_DEFINITIONS := {
    "pham": {"name":"Phàm phẩm", "stat_multiplier":1.00, "price_multiplier":1.00},
    "tinh": {"name":"Tinh phẩm", "stat_multiplier":1.16, "price_multiplier":1.22},
    "thuong": {"name":"Thượng phẩm", "stat_multiplier":1.34, "price_multiplier":1.52}
}

const RECIPES := {
    "thanh_thiet_kiem": {
        "name":"Thanh Thiết Kiếm", "slot":"weapon", "path":"sword", "element":"metal", "base_price":84,
        "materials":{"thanh_thiet":3, "linh_moc":1},
        "cultivation_realm_tier":2, "body_realm_tier":0,
        "stats":{"combat_power":6.0, "skill_effect":0.10, "basic_speed":0.08, "basic_ratio":0.05}
    },
    "huyen_thiet_quyen_sao": {
        "name":"Huyền Thiết Quyền Sáo", "slot":"weapon", "path":"body", "element":"earth", "base_price":82,
        "materials":{"thanh_thiet":3, "tinh_lang_bi":1},
        "cultivation_realm_tier":2, "body_realm_tier":1,
        "stats":{"combat_power":5.5, "skill_effect":0.11, "defense_reduction":0.04, "basic_ratio":0.09}
    },
    "linh_moc_phap_truong": {
        "name":"Linh Mộc Pháp Trượng", "slot":"weapon", "path":"spell", "element":"wood", "base_price":88,
        "materials":{"linh_moc":3, "yeu_dan":1},
        "cultivation_realm_tier":2, "body_realm_tier":0,
        "stats":{"combat_power":4.5, "skill_effect":0.13, "basic_range":0.45, "basic_speed":0.04}
    },
    "tinh_lang_giap": {
        "name":"Tinh Lang Giáp", "slot":"armor", "path":"body", "element":"earth", "base_price":76,
        "materials":{"tinh_lang_bi":3, "thanh_thiet":1},
        "cultivation_realm_tier":2, "body_realm_tier":1,
        "stats":{"combat_power":1.5, "defense_reduction":0.12, "move_speed":-0.03}
    },
    "hoa_van_ngoc": {
        "name":"Hỏa Vân Ngọc", "slot":"talisman", "path":"spell", "element":"fire", "base_price":92,
        "materials":{"yeu_dan":2, "linh_moc":1},
        "cultivation_realm_tier":2, "body_realm_tier":0,
        "stats":{"combat_power":2.0, "skill_effect":0.16, "basic_range":0.20}
    }
}

const FORGE_SEED_OFFSET := 262147
const FORGE_SEED_MULTIPLIER := 104729
const HASH_MODULUS := 2147483629

var paths := CultivationPathSystem.new()
var combat_skills := CombatSkillSystem.new()
var warehouse := WarehouseSystem.new()
var production_plans := ProductionPlanRegistry.new()

func initialize(state: SimulationState) -> void:
    if not state.sect.combat_skills_enabled:
        return
    state.sect.equipment_enabled = true
    if not VALID_POLICIES.has(state.sect.equipment_policy):
        state.sect.equipment_policy = POLICY_BALANCED

func material_name(material_id: StringName) -> String:
    return str(MATERIAL_NAMES.get(str(material_id), str(material_id)))

func recipe(recipe_id: StringName) -> Dictionary:
    return RECIPES.get(str(recipe_id), {})

func quality_name(quality_id: StringName) -> String:
    return str(QUALITY_DEFINITIONS.get(str(quality_id), QUALITY_DEFINITIONS["pham"]).get("name", quality_id))

func set_policy(state: SimulationState, policy: StringName) -> bool:
    if not state.sect.equipment_enabled or not VALID_POLICIES.has(policy):
        return false
    state.sect.equipment_policy = policy
    state.sect.equipment_event_count += 1
    return true

func forge_loot_for_victory(state: SimulationState, result: Dictionary) -> Dictionary:
    var loot: Dictionary = {}
    if not state.sect.equipment_enabled or str(result.get("outcome", "")) != "win":
        return loot
    match str(result.get("species_id", "")):
        "truc_thu":
            loot["linh_moc"] = 1
        "thanh_lang":
            loot["thanh_thiet"] = 1
            loot["tinh_lang_bi"] = 1
        "hac_lang":
            loot["thanh_thiet"] = 2
            loot["tinh_lang_bi"] = 1
            loot["yeu_dan"] = 1
        _:
            pass
    return loot

func deposit_forge_inventory(state: SimulationState, disciple: DiscipleState) -> int:
    if not state.sect.equipment_enabled:
        return 0
    var moved := 0
    var material_ids: Array = MATERIAL_NAMES.keys()
    material_ids.sort()
    for raw_id in material_ids:
        var material_id := str(raw_id)
        var quantity := int(disciple.inventory.get(material_id, 0))
        if quantity <= 0:
            continue
        var deposited := false
        if state.sect.p3_7_resources_enabled:
            deposited = warehouse.add(state, StringName(material_id), quantity)
        else:
            state.sect.forge_materials[material_id] = int(state.sect.forge_materials.get(material_id, 0)) + quantity
            deposited = true
        if not deposited:
            continue
        disciple.inventory.erase(material_id)
        moved += quantity
    if moved > 0:
        state.sect.equipment_event_count += 1
    return moved

func crafting_requirements(state: SimulationState, recipe_id: StringName) -> Dictionary:
    var data := recipe(recipe_id)
    var raw = data.get("materials", {})
    var result: Dictionary = raw.duplicate(true) if raw is Dictionary else {}
    if (
        state == null
        or not state.sect.p3_7_resources_enabled
        or not state.sect.economy_a_enabled
    ):
        return result

    # Scale only abundant common materials. Rare/discrete drops keep their
    # original unit counts so a bulk economy does not inflate boss/rare loot.
    var ids: Array = result.keys()
    for raw_id in ids:
        var material_id := StringName(raw_id)
        result[str(material_id)] = production_plans.scale_common_requirement(
            material_id, int(result[raw_id])
        )
        if str(raw_id) != str(material_id):
            result.erase(raw_id)
    return result

func cultivation_realm_tier(recipe_id: StringName) -> int:
    return clampi(int(recipe(recipe_id).get("cultivation_realm_tier",0)),0,DiscipleRealmProgressV2.MAX_REALM)

func body_realm_tier(recipe_id: StringName) -> int:
    return clampi(int(recipe(recipe_id).get("body_realm_tier",0)),0,DiscipleRealmProgressV2.MAX_REALM)

func can_craft(state: SimulationState, recipe_id: StringName) -> bool:
    if not state.sect.equipment_enabled:
        return false
    var data: Dictionary = recipe(recipe_id)
    if data.is_empty():
        return false
    var materials: Dictionary = crafting_requirements(state,recipe_id)
    if state.sect.p3_7_resources_enabled:
        return warehouse.can_consume_requirements(state, materials)
    for raw_id in materials.keys():
        if int(state.sect.forge_materials.get(str(raw_id), 0)) < int(materials[raw_id]):
            return false
    return true

func craft(state: SimulationState, recipe_id: StringName, list_for_sale: bool = true) -> Dictionary:
    if not can_craft(state, recipe_id):
        return {}
    var data: Dictionary = recipe(recipe_id)
    var materials: Dictionary = crafting_requirements(state,recipe_id)
    if state.sect.p3_7_resources_enabled:
        if not warehouse.consume_requirements(state, materials):
            return {}
    else:
        var material_ids: Array = materials.keys()
        material_ids.sort()
        for raw_id in material_ids:
            var material_id := str(raw_id)
            state.sect.forge_materials[material_id] = int(state.sect.forge_materials.get(material_id, 0)) - int(materials[raw_id])

    state.sect.equipment_forge_index += 1
    var quality_id := _roll_quality(state.seed, state.sect.equipment_forge_index, str(recipe_id))
    var quality: Dictionary = QUALITY_DEFINITIONS[str(quality_id)]
    var stat_multiplier := float(quality.get("stat_multiplier", 1.0))
    if state.sect.workforce_enabled and state.sect.forge_support_points > 0:
        state.sect.forge_support_points -= 1
        state.sect.workforce_event_count += 1
        stat_multiplier *= 1.05
    var stats := _scaled_stats(data.get("stats", {}), stat_multiplier)
    var item_id := "equip_%06d" % state.sect.equipment_forge_index
    var price := maxi(1, int(round(float(data.get("base_price", 1)) * float(quality.get("price_multiplier", 1.0)))))
    var item := {
        "id": item_id,
        "recipe_id": str(recipe_id),
        "name": str(data.get("name", recipe_id)),
        "slot": str(data.get("slot", SLOT_WEAPON)),
        "quality": str(quality_id),
        "path": str(data.get("path", "")),
        "element": str(data.get("element", "")),
        "stats": stats,
        "price": price,
        "location": str(LOCATION_SHOP if list_for_sale else LOCATION_STORAGE),
        "owner_id": ""
    }
    state.sect.equipment_items[item_id] = item
    state.sect.equipment_event_count += 1
    return item.duplicate(true)

func move_to_shop(state: SimulationState, item_id: StringName) -> bool:
    return _move_unowned_item(state, item_id, LOCATION_SHOP)

func move_to_storage(state: SimulationState, item_id: StringName) -> bool:
    return _move_unowned_item(state, item_id, LOCATION_STORAGE)

func equipment_score(state: SimulationState, disciple: DiscipleState, item: Dictionary) -> float:
    if item.is_empty():
        return 0.0
    var stats: Dictionary = item.get("stats", {})
    var score := 0.0
    score += effective_combat_bonus_for_item(disciple, item) * 4.0
    score += float(stats.get("defense_reduction", 0.0)) * 120.0 * (0.75 + clampf(disciple.survival_bias, 0.0, 1.0))
    score += float(stats.get("skill_effect", 0.0)) * 72.0
    score += float(stats.get("basic_speed", 0.0)) * 52.0
    score += float(stats.get("basic_range", 0.0)) * 9.0
    score += float(stats.get("basic_ratio", 0.0)) * 58.0
    score += float(stats.get("move_speed", 0.0)) * 30.0

    var item_path := StringName(item.get("path", ""))
    if CultivationPathSystem.VALID_PATHS.has(item_path):
        score += paths.depth(disciple, item_path) * 22.0
        if paths.active_technique_path(disciple) == item_path:
            score += 14.0
        score += float(_matching_skill_count(disciple, item_path)) * 3.0

    var element := str(item.get("element", ""))
    if element != "":
        score += 10.0 if disciple.spiritual_root_elements.has(element) else -3.0

    var slot := StringName(item.get("slot", ""))
    if slot == SLOT_ARMOR:
        score += clampf(disciple.survival_bias - disciple.risk_bias, -1.0, 1.0) * 10.0
    elif slot == SLOT_WEAPON:
        score += clampf(disciple.risk_bias, 0.0, 1.0) * 4.0
    return score

func try_auto_upgrade(state: SimulationState, disciple: DiscipleState) -> bool:
    if not state.sect.equipment_enabled or disciple.region_id != &"sect":
        return false
    var item_ids: Array = state.sect.equipment_items.keys()
    item_ids.sort()
    var best_id := ""
    var best_utility := -1.0e30
    for raw_id in item_ids:
        var item_id := str(raw_id)
        var item: Dictionary = state.sect.equipment_items[item_id]
        if StringName(item.get("location", "")) != LOCATION_SHOP:
            continue
        var slot := StringName(item.get("slot", ""))
        if not VALID_SLOTS.has(slot) or bool(disciple.locked_equipment_slots.get(str(slot), false)):
            continue
        var price := int(item.get("price", 0))
        var reserve := _wallet_reserve(state, disciple)
        if price <= 0 or disciple.wallet - price < reserve:
            continue
        var current := equipped_item(state, disciple, slot)
        var improvement := equipment_score(state, disciple, item) - equipment_score(state, disciple, current)
        if improvement + 0.000001 < _minimum_upgrade_score(state, disciple):
            continue
        var price_sensitivity := 0.05 + (1.0 - clampf(disciple.spend_bias, 0.0, 1.0)) * 0.12
        var utility := improvement - float(price) * price_sensitivity
        if utility > best_utility + 0.000001 or (absf(utility - best_utility) <= 0.000001 and (best_id == "" or item_id < best_id)):
            best_id = item_id
            best_utility = utility
    if best_id == "":
        return false
    return purchase_and_equip(state, disciple, StringName(best_id))

func purchase_and_equip(state: SimulationState, disciple: DiscipleState, item_id: StringName) -> bool:
    if not state.sect.equipment_enabled or not state.sect.equipment_items.has(str(item_id)):
        return false
    var item: Dictionary = state.sect.equipment_items[str(item_id)]
    if StringName(item.get("location", "")) != LOCATION_SHOP:
        return false
    var price := int(item.get("price", 0))
    if price <= 0 or disciple.wallet < price:
        return false
    disciple.wallet -= price
    state.sect.treasury += price
    if not _equip_item(state, disciple, item_id):
        disciple.wallet += price
        state.sect.treasury -= price
        return false
    disciple.metrics["equipment_purchases"] = int(disciple.metrics.get("equipment_purchases", 0)) + 1
    state.sect.equipment_event_count += 1
    return true

func manual_equip(state: SimulationState, disciple_id: StringName, item_id: StringName, lock_slot: bool = true) -> bool:
    if not state.sect.equipment_enabled or not state.disciples.has(disciple_id) or not state.sect.equipment_items.has(str(item_id)):
        return false
    var item: Dictionary = state.sect.equipment_items[str(item_id)]
    if StringName(item.get("location", "")) == LOCATION_EQUIPPED:
        return false
    var disciple: DiscipleState = state.disciples[disciple_id]
    if not _equip_item(state, disciple, item_id):
        return false
    var slot := str(item.get("slot", ""))
    if lock_slot:
        disciple.locked_equipment_slots[slot] = true
    else:
        disciple.locked_equipment_slots.erase(slot)
    disciple.metrics["manual_equips"] = int(disciple.metrics.get("manual_equips", 0)) + 1
    state.sect.equipment_event_count += 1
    return true

func set_slot_lock(state: SimulationState, disciple_id: StringName, slot: StringName, locked: bool) -> bool:
    if not state.sect.equipment_enabled or not state.disciples.has(disciple_id) or not VALID_SLOTS.has(slot):
        return false
    var disciple: DiscipleState = state.disciples[disciple_id]
    if locked:
        disciple.locked_equipment_slots[str(slot)] = true
    else:
        disciple.locked_equipment_slots.erase(str(slot))
    state.sect.equipment_event_count += 1
    return true

func return_slot_to_auto(state: SimulationState, disciple_id: StringName, slot: StringName) -> bool:
    return set_slot_lock(state, disciple_id, slot, false)

func unequip_to_storage(state: SimulationState, disciple_id: StringName, slot: StringName) -> bool:
    if not state.sect.equipment_enabled or not state.disciples.has(disciple_id) or not VALID_SLOTS.has(slot):
        return false
    var disciple: DiscipleState = state.disciples[disciple_id]
    var item_id := str(disciple.equipped_items.get(str(slot), ""))
    if item_id == "" or not state.sect.equipment_items.has(item_id):
        return false
    var item: Dictionary = state.sect.equipment_items[item_id]
    item["location"] = str(LOCATION_STORAGE)
    item["owner_id"] = ""
    state.sect.equipment_items[item_id] = item
    disciple.equipped_items.erase(str(slot))
    disciple.locked_equipment_slots.erase(str(slot))
    state.sect.equipment_event_count += 1
    return true

func equipped_item(state: SimulationState, disciple: DiscipleState, slot: StringName) -> Dictionary:
    var item_id := str(disciple.equipped_items.get(str(slot), ""))
    if item_id == "" or not state.sect.equipment_items.has(item_id):
        return {}
    var item: Dictionary = state.sect.equipment_items[item_id]
    if StringName(item.get("location", "")) != LOCATION_EQUIPPED or str(item.get("owner_id", "")) != str(disciple.id):
        return {}
    return item

func effective_combat_bonus_for_item(disciple: DiscipleState, item: Dictionary) -> float:
    if item.is_empty():
        return 0.0
    var raw_bonus := float(item.get("stats", {}).get("combat_power", 0.0))
    if raw_bonus <= 0.0:
        return 0.0
    return raw_bonus * _compatibility_multiplier(disciple, item)

func combat_power_bonus(state: SimulationState, disciple: DiscipleState) -> float:
    if not state.sect.equipment_enabled:
        return 0.0
    var total := 0.0
    for slot in VALID_SLOTS:
        var item := equipped_item(state, disciple, slot)
        if not item.is_empty():
            total += effective_combat_bonus_for_item(disciple, item)
    return total

func incoming_damage_multiplier(state: SimulationState, disciple: DiscipleState) -> float:
    if not state.sect.equipment_enabled:
        return 1.0
    var multiplier := 1.0
    for slot in VALID_SLOTS:
        var item := equipped_item(state, disciple, slot)
        if item.is_empty():
            continue
        multiplier *= 1.0 - clampf(float(item.get("stats", {}).get("defense_reduction", 0.0)), 0.0, 0.40)
    return clampf(multiplier, 0.60, 1.0)

func skill_effect_multiplier(state: SimulationState, disciple: DiscipleState, skill_path: StringName, skill_element: StringName) -> float:
    if not state.sect.equipment_enabled:
        return 1.0
    var bonus := 0.0
    for slot in VALID_SLOTS:
        var item := equipped_item(state, disciple, slot)
        if item.is_empty():
            continue
        var effect_bonus := maxf(float(item.get("stats", {}).get("skill_effect", 0.0)), 0.0)
        if effect_bonus <= 0.0:
            continue
        if str(item.get("path", "")) == str(skill_path):
            bonus += effect_bonus
        if str(skill_element) != "" and str(item.get("element", "")) == str(skill_element):
            bonus += effect_bonus * 0.50
    return 1.0 + bonus

func apply_style_modifiers(state: SimulationState, disciple: DiscipleState, style: Dictionary) -> Dictionary:
    if not state.sect.equipment_enabled:
        return style
    var result := style.duplicate(true)
    var move_bonus := 0.0
    var speed_bonus := 0.0
    var range_bonus := 0.0
    var ratio_bonus := 0.0
    for slot in VALID_SLOTS:
        var item := equipped_item(state, disciple, slot)
        if item.is_empty():
            continue
        var stats: Dictionary = item.get("stats", {})
        move_bonus += float(stats.get("move_speed", 0.0))
        speed_bonus += float(stats.get("basic_speed", 0.0))
        range_bonus += float(stats.get("basic_range", 0.0))
        ratio_bonus += float(stats.get("basic_ratio", 0.0))
    result["move_speed"] = maxf(0.5, float(result.get("move_speed", 2.7)) * (1.0 + move_bonus))
    result["basic_interval"] = maxf(0.45, float(result.get("basic_interval", 1.35)) * (1.0 - clampf(speed_bonus, -0.35, 0.45)))
    result["basic_range"] = maxf(0.5, float(result.get("basic_range", 1.75)) + range_bonus)
    result["basic_ratio"] = maxf(0.2, float(result.get("basic_ratio", 1.0)) * (1.0 + ratio_bonus))
    return result

func validate_invariants(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if not state.sect.equipment_enabled:
        return errors
    if not state.sect.combat_skills_enabled:
        errors.append("Equipment requires P2.5 combat skills to be enabled.")
    if not VALID_POLICIES.has(state.sect.equipment_policy):
        errors.append("Equipment policy is invalid.")
    if state.sect.equipment_forge_index < 0 or state.sect.equipment_event_count < 0:
        errors.append("Equipment counters cannot be negative.")
    for raw_recipe_id in RECIPES.keys():
        var recipe_id := StringName(raw_recipe_id)
        var recipe_data := recipe(recipe_id)
        var cultivation_tier := int(recipe_data.get("cultivation_realm_tier",-1))
        var body_tier := int(recipe_data.get("body_realm_tier",-1))
        if cultivation_tier <= 0 or cultivation_tier > DiscipleRealmProgressV2.MAX_REALM:
            errors.append("Equipment recipe %s has invalid Tu Vi tier." % recipe_id)
        if body_tier < 0 or body_tier > DiscipleRealmProgressV2.MAX_REALM:
            errors.append("Equipment recipe %s has invalid Luyện Thể tier." % recipe_id)
        var requirements := crafting_requirements(state,recipe_id)
        for raw_material in requirements.keys():
            if not MATERIAL_NAMES.has(str(raw_material)) or int(requirements[raw_material]) <= 0:
                errors.append("Equipment recipe %s has invalid material %s." % [recipe_id,raw_material])
    if state.sect.p3_7_resources_enabled:
        if not state.sect.forge_materials.is_empty():
            errors.append("Legacy forge materials must be empty under P3.7 warehouse authority.")
    else:
        for raw_material in state.sect.forge_materials.keys():
            if not MATERIAL_NAMES.has(str(raw_material)) or int(state.sect.forge_materials[raw_material]) < 0:
                errors.append("Invalid forge material %s." % raw_material)

    var equipped_seen: Dictionary = {}
    var item_ids: Array = state.sect.equipment_items.keys()
    item_ids.sort()
    for raw_id in item_ids:
        var item_id := str(raw_id)
        var item = state.sect.equipment_items[item_id]
        if not (item is Dictionary):
            errors.append("Equipment %s has invalid storage." % item_id)
            continue
        var item_dict: Dictionary = item
        if str(item_dict.get("id", "")) != item_id or recipe(StringName(item_dict.get("recipe_id", ""))).is_empty():
            errors.append("Equipment %s has invalid identity/recipe." % item_id)
        var slot := StringName(item_dict.get("slot", ""))
        var location := StringName(item_dict.get("location", ""))
        if not VALID_SLOTS.has(slot) or not VALID_LOCATIONS.has(location):
            errors.append("Equipment %s has invalid slot/location." % item_id)
        if not QUALITY_DEFINITIONS.has(str(item_dict.get("quality", ""))):
            errors.append("Equipment %s has invalid quality." % item_id)
        if not (item_dict.get("stats", {}) is Dictionary):
            errors.append("Equipment %s has invalid stats storage." % item_id)
        if int(item_dict.get("price", 0)) <= 0:
            errors.append("Equipment %s has invalid price." % item_id)
        var owner_id := StringName(item_dict.get("owner_id", ""))
        if location == LOCATION_EQUIPPED:
            if owner_id == &"" or not state.disciples.has(owner_id):
                errors.append("Equipped item %s has missing owner." % item_id)
            elif equipped_seen.has(item_id):
                errors.append("Equipment %s is equipped more than once." % item_id)
            else:
                equipped_seen[item_id] = true
                var owner: DiscipleState = state.disciples[owner_id]
                if str(owner.equipped_items.get(str(slot), "")) != item_id:
                    errors.append("Equipment %s owner mapping is inconsistent." % item_id)
        elif owner_id != &"":
            errors.append("Unequipped item %s still has an owner." % item_id)

    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        for raw_slot in disciple.equipped_items.keys():
            var slot := StringName(raw_slot)
            var item_id := str(disciple.equipped_items[raw_slot])
            if not VALID_SLOTS.has(slot) or not state.sect.equipment_items.has(item_id):
                errors.append("%s has invalid equipment slot/item." % disciple.display_name)
                continue
            var item: Dictionary = state.sect.equipment_items[item_id]
            if str(item.get("slot", "")) != str(slot) or str(item.get("owner_id", "")) != str(disciple.id) or StringName(item.get("location", "")) != LOCATION_EQUIPPED:
                errors.append("%s equipment mapping is inconsistent for %s." % [disciple.display_name, slot])
        for raw_slot in disciple.locked_equipment_slots.keys():
            if not VALID_SLOTS.has(StringName(raw_slot)) or not bool(disciple.locked_equipment_slots[raw_slot]):
                errors.append("%s has invalid locked equipment slot %s." % [disciple.display_name, raw_slot])
    return errors

func _compatibility_multiplier(disciple: DiscipleState, item: Dictionary) -> float:
    var multiplier := 1.0
    var item_path := StringName(item.get("path", ""))
    if CultivationPathSystem.VALID_PATHS.has(item_path):
        multiplier += (paths.depth(disciple, item_path) - 0.5) * 0.20
        if paths.active_technique_path(disciple) == item_path:
            multiplier += 0.06
        multiplier += float(mini(_matching_skill_count(disciple, item_path), 3)) * 0.02
    var element := str(item.get("element", ""))
    if element != "":
        multiplier += 0.08 if disciple.spiritual_root_elements.has(element) else -0.04
    return clampf(multiplier, 0.80, 1.30)

func _equip_item(state: SimulationState, disciple: DiscipleState, item_id: StringName) -> bool:
    var key := str(item_id)
    if not state.sect.equipment_items.has(key):
        return false
    var item: Dictionary = state.sect.equipment_items[key]
    var slot := StringName(item.get("slot", ""))
    if not VALID_SLOTS.has(slot):
        return false
    var old_id := str(disciple.equipped_items.get(str(slot), ""))
    if old_id != "" and old_id != key and state.sect.equipment_items.has(old_id):
        var old_item: Dictionary = state.sect.equipment_items[old_id]
        old_item["location"] = str(LOCATION_STORAGE)
        old_item["owner_id"] = ""
        state.sect.equipment_items[old_id] = old_item
    item["location"] = str(LOCATION_EQUIPPED)
    item["owner_id"] = str(disciple.id)
    state.sect.equipment_items[key] = item
    disciple.equipped_items[str(slot)] = key
    return true

func _move_unowned_item(state: SimulationState, item_id: StringName, location: StringName) -> bool:
    if not state.sect.equipment_enabled or not state.sect.equipment_items.has(str(item_id)) or location not in [LOCATION_SHOP, LOCATION_STORAGE]:
        return false
    var item: Dictionary = state.sect.equipment_items[str(item_id)]
    if StringName(item.get("location", "")) == LOCATION_EQUIPPED:
        return false
    item["location"] = str(location)
    item["owner_id"] = ""
    state.sect.equipment_items[str(item_id)] = item
    state.sect.equipment_event_count += 1
    return true

func _wallet_reserve(state: SimulationState, disciple: DiscipleState) -> int:
    var reserve := 20 + int(round((1.0 - clampf(disciple.spend_bias, 0.0, 1.0)) * 55.0))
    if state.sect.equipment_policy == POLICY_FRUGAL:
        reserve += 20
    elif state.sect.equipment_policy == POLICY_COMBAT:
        reserve = maxi(10, reserve - 15)
    return reserve

func _minimum_upgrade_score(state: SimulationState, disciple: DiscipleState) -> float:
    var threshold := 6.0 + (1.0 - clampf(disciple.spend_bias, 0.0, 1.0)) * 14.0
    if state.sect.equipment_policy == POLICY_FRUGAL:
        threshold += 7.0
    elif state.sect.equipment_policy == POLICY_COMBAT:
        threshold = maxf(3.0, threshold - 5.0)
    return threshold

func _matching_skill_count(disciple: DiscipleState, path_id: StringName) -> int:
    var count := 0
    var skill_ids: Array = disciple.learned_combat_skills.keys()
    skill_ids.sort()
    for raw_id in skill_ids:
        if not bool(disciple.learned_combat_skills.get(str(raw_id), false)):
            continue
        var definition := combat_skills.definition(StringName(raw_id))
        if str(definition.get("path", "")) == str(path_id):
            count += 1
    return count

func _scaled_stats(raw_stats: Variant, multiplier: float) -> Dictionary:
    var result: Dictionary = {}
    if not (raw_stats is Dictionary):
        return result
    var stats: Dictionary = raw_stats
    var keys: Array = stats.keys()
    keys.sort()
    for raw_key in keys:
        var key := str(raw_key)
        var value := float(stats[raw_key])
        result[key] = value * multiplier if value >= 0.0 else value
    return result

func _roll_quality(base_seed: int, forge_index: int, recipe_id: String) -> StringName:
    var rng := GameRng.new(base_seed + forge_index * FORGE_SEED_MULTIPLIER + _stable_hash(recipe_id) * 31 + FORGE_SEED_OFFSET)
    var roll := rng.randf()
    if roll < 0.10:
        return &"thuong"
    if roll < 0.40:
        return &"tinh"
    return &"pham"

func _stable_hash(value: String) -> int:
    var result := 17
    for index in range(value.length()):
        result = int((result * 131 + value.unicode_at(index)) % HASH_MODULUS)
    return result
