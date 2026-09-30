extends SceneTree

const TEST_SEED := 1726262
const COMBAT_RNG_SEED := 424242

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _verify_armor_reduces_real_damage():
        return
    if not _verify_equipment_boosts_real_skill_damage():
        return
    if not _verify_weapon_style_changes_real_basic_combat():
        return

    print("P2.6 EQUIPMENT COMBAT EFFECTS TEST PASS")
    quit(0)

func _verify_armor_reduces_real_damage() -> bool:
    var plain_state := P26Factory.create_state(TEST_SEED + 1)
    var geared_state := P26Factory.create_state(TEST_SEED + 1)
    var equipment := EquipmentSystem.new()
    var plain: DiscipleState = plain_state.disciples.get(&"bach_nguyet")
    var geared: DiscipleState = geared_state.disciples.get(&"bach_nguyet")
    _configure_basic_actor(plain_state, plain, &"thanh_truc_lam", 10.0, 500.0)
    _configure_basic_actor(geared_state, geared, &"thanh_truc_lam", 10.0, 500.0)

    _seed_forge_materials(geared_state)
    var armor := equipment.craft(geared_state, &"tinh_lang_giap", false)
    if armor.is_empty():
        return _fail_bool("P2.6 defense probe could not forge armor.")
    var armor_id := str(armor.get("id", ""))
    _set_item_stat(geared_state, armor_id, "combat_power", 0.0)
    _set_item_stat(geared_state, armor_id, "move_speed", 0.0)
    if not equipment.manual_equip(geared_state, geared.id, StringName(armor_id), true):
        return _fail_bool("P2.6 defense probe could not equip armor.")

    var plain_result: Dictionary = CombatSystem.new().resolve_encounter(plain_state, plain, GameRng.new(COMBAT_RNG_SEED))
    var geared_result: Dictionary = CombatSystem.new().resolve_encounter(geared_state, geared, GameRng.new(COMBAT_RNG_SEED))
    var plain_hp := float(plain_result.get("disciple_hp", plain.hp))
    var geared_hp := float(geared_result.get("disciple_hp", geared.hp))
    if geared_hp <= plain_hp + 0.000001:
        return _fail_bool("P2.6 armor defense_reduction did not reduce damage in the real P2.5 resolver.")
    return true

func _verify_equipment_boosts_real_skill_damage() -> bool:
    var plain_state := P26Factory.create_state(TEST_SEED + 2)
    var geared_state := P26Factory.create_state(TEST_SEED + 2)
    var equipment := EquipmentSystem.new()
    var plain: DiscipleState = plain_state.disciples.get(&"trieu_linh_nhi")
    var geared: DiscipleState = geared_state.disciples.get(&"trieu_linh_nhi")
    _configure_spell_actor(plain_state, plain)
    _configure_spell_actor(geared_state, geared)

    _seed_forge_materials(geared_state)
    var talisman := equipment.craft(geared_state, &"hoa_van_ngoc", false)
    if talisman.is_empty():
        return _fail_bool("P2.6 skill-effect probe could not forge Hỏa Vân Ngọc.")
    var talisman_id := str(talisman.get("id", ""))
    _set_item_stat(geared_state, talisman_id, "combat_power", 0.0)
    _set_item_stat(geared_state, talisman_id, "basic_range", 0.0)
    if not equipment.manual_equip(geared_state, geared.id, StringName(talisman_id), true):
        return _fail_bool("P2.6 skill-effect probe could not equip Hỏa Vân Ngọc.")

    var plain_result: Dictionary = CombatSystem.new().resolve_encounter(plain_state, plain, GameRng.new(COMBAT_RNG_SEED))
    var geared_result: Dictionary = CombatSystem.new().resolve_encounter(geared_state, geared, GameRng.new(COMBAT_RNG_SEED))
    var plain_damage := _first_skill_hit_damage(plain_result, "hoa_cau")
    var geared_damage := _first_skill_hit_damage(geared_result, "hoa_cau")
    if plain_damage <= 0.0 or geared_damage <= plain_damage + 0.000001:
        return _fail_bool("P2.6 equipment skill_effect did not increase real Hỏa Cầu damage.")
    return true

func _verify_weapon_style_changes_real_basic_combat() -> bool:
    var plain_state := P26Factory.create_state(TEST_SEED + 3)
    var geared_state := P26Factory.create_state(TEST_SEED + 3)
    var equipment := EquipmentSystem.new()
    var plain: DiscipleState = plain_state.disciples.get(&"bach_nguyet")
    var geared: DiscipleState = geared_state.disciples.get(&"bach_nguyet")
    _configure_basic_actor(plain_state, plain, &"hac_phong_coc", 2.0, 2000.0)
    _configure_basic_actor(geared_state, geared, &"hac_phong_coc", 2.0, 2000.0)

    _seed_forge_materials(geared_state)
    var weapon := equipment.craft(geared_state, &"linh_moc_phap_truong", false)
    if weapon.is_empty():
        return _fail_bool("P2.6 style probe could not forge a weapon.")
    var weapon_id := str(weapon.get("id", ""))
    _set_item_stat(geared_state, weapon_id, "combat_power", 0.0)
    _set_item_stat(geared_state, weapon_id, "skill_effect", 0.0)
    _set_item_stat(geared_state, weapon_id, "basic_speed", 0.50)
    _set_item_stat(geared_state, weapon_id, "basic_range", 1.50)
    _set_item_stat(geared_state, weapon_id, "basic_ratio", 0.0)
    if not equipment.manual_equip(geared_state, geared.id, StringName(weapon_id), true):
        return _fail_bool("P2.6 style probe could not equip its weapon.")

    var plain_result: Dictionary = CombatSystem.new().resolve_encounter(plain_state, plain, GameRng.new(COMBAT_RNG_SEED))
    var geared_result: Dictionary = CombatSystem.new().resolve_encounter(geared_state, geared, GameRng.new(COMBAT_RNG_SEED))
    var plain_attacks := int(plain_result.get("basic_attacks", 0))
    var geared_attacks := int(geared_result.get("basic_attacks", 0))
    if geared_attacks <= plain_attacks:
        return _fail_bool("P2.6 basic_speed/basic_range equipment did not change real basic-combat behavior.")
    return true

func _configure_basic_actor(state: SimulationState, actor: DiscipleState, region_id: StringName, power: float, max_hp: float) -> void:
    actor.region_id = region_id
    actor.target_region_id = &""
    actor.combat_power = power
    actor.max_hp = max_hp
    actor.hp = max_hp
    actor.stamina = 100.0
    actor.risk_bias = 1.0
    actor.learned_combat_skills = {}
    actor.active_technique_id = &""
    actor.cultivation_path_xp = {"sword":0.0, "body":0.0, "spell":0.0}
    var region: RegionState = state.regions.get(region_id)
    if region_id == &"hac_phong_coc":
        region.monster_weights = {"hac_lang":1.0}
    else:
        region.monster_weights = {"truc_thu":1.0}

func _configure_spell_actor(state: SimulationState, actor: DiscipleState) -> void:
    actor.region_id = &"thanh_truc_lam"
    actor.target_region_id = &""
    actor.combat_power = 12.0
    actor.max_hp = 500.0
    actor.hp = 500.0
    actor.stamina = 100.0
    actor.risk_bias = 0.5
    actor.cultivation_stage_index = 0
    actor.cultivation_path_xp = {"sword":0.0, "body":0.0, "spell":CultivationPathSystem.DEPTH_XP}
    actor.spiritual_root_elements = ["fire"]
    actor.learned_techniques = {"xich_viem_chan_quyet":{"level":1, "xp":0.0}}
    actor.active_technique_id = &"xich_viem_chan_quyet"
    actor.learned_combat_skills = {"hoa_cau":true}
    var region: RegionState = state.regions.get(&"thanh_truc_lam")
    region.monster_weights = {"truc_thu":1.0}

func _first_skill_hit_damage(result: Dictionary, skill_id: String) -> float:
    var trace_value = result.get("trace", [])
    if not (trace_value is Array):
        return 0.0
    var trace: Array = trace_value
    for event_value in trace:
        if not (event_value is Dictionary):
            continue
        var event: Dictionary = event_value
        if str(event.get("type", "")) == "skill_hit" and str(event.get("skill_id", "")) == skill_id:
            return float(event.get("damage", 0.0))
    return 0.0

func _set_item_stat(state: SimulationState, item_id: String, stat_id: String, value: float) -> void:
    var item: Dictionary = state.sect.equipment_items.get(item_id, {}).duplicate(true)
    var stats: Dictionary = item.get("stats", {}).duplicate(true)
    stats[stat_id] = value
    item["stats"] = stats
    state.sect.equipment_items[item_id] = item

func _seed_forge_materials(state: SimulationState) -> void:
    state.sect.forge_materials = {
        "linh_moc":20,
        "thanh_thiet":20,
        "tinh_lang_bi":20,
        "yeu_dan":20
    }

func _fail_bool(message: String) -> bool:
    push_error(message)
    quit(1)
    return false
