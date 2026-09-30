extends SceneTree

const TEST_SEED := 1526262
const DETERMINISM_TICKS := 600
const CONTINUATION_TICKS := 400
const SAVE_PATH := "user://p2_6_equipment_test.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var legacy := P25Factory.create_state(TEST_SEED)
    if legacy.sect.equipment_enabled:
        _fail("P2.5 must remain equipment-disabled.")
        return

    var state := P26Factory.create_state(TEST_SEED)
    if not state.sect.equipment_enabled or not state.sect.combat_skills_enabled:
        _fail("P2.6 factory did not preserve P2.5 and enable equipment.")
        return

    if not _verify_hunt_to_forge_loop():
        return
    if not _verify_deterministic_forging():
        return
    if not _verify_personalized_auto_choice_and_closed_money():
        return
    if not _verify_manual_equip_lock_and_return_to_auto():
        return
    if not _verify_equipment_changes_region_choice():
        return
    if not _verify_equipment_changes_real_combat():
        return

    var state_a := P26Factory.create_state(TEST_SEED + 100)
    var state_b := P26Factory.create_state(TEST_SEED + 100)
    _seed_forge_materials(state_a)
    _seed_forge_materials(state_b)
    EquipmentSystem.new().craft(state_a, &"thanh_thiet_kiem", true)
    EquipmentSystem.new().craft(state_b, &"thanh_thiet_kiem", true)
    _prepare_buyer(state_a, &"bach_nguyet", &"sword", "metal")
    _prepare_buyer(state_b, &"bach_nguyet", &"sword", "metal")

    var scheduler_a := SimulationScheduler.new(state_a)
    var scheduler_b := SimulationScheduler.new(state_b)
    scheduler_a.run_ticks(DETERMINISM_TICKS)
    scheduler_b.run_ticks(DETERMINISM_TICKS)
    if state_a.to_dict() != state_b.to_dict():
        _fail("P2.6 same-seed simulation diverged.")
        return

    var errors := _invariants(state_a)
    if not errors.is_empty():
        _fail("P2.6 invariant failure: %s" % " | ".join(errors))
        return

    var service := SaveService.new()
    if service.save_to_path(state_a, SAVE_PATH) != OK:
        _fail("P2.6 save failed.")
        return
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null or not loaded.sect.equipment_enabled:
        _fail("P2.6 save could not restore equipment state.")
        return
    if state_a.to_dict() != loaded.to_dict():
        _fail("P2.6 forge/equipment state was not preserved by save/load.")
        return

    var control_scheduler := SimulationScheduler.new(state_a)
    var loaded_scheduler := SimulationScheduler.new(loaded)
    control_scheduler.run_ticks(CONTINUATION_TICKS)
    loaded_scheduler.run_ticks(CONTINUATION_TICKS)
    if state_a.to_dict() != loaded.to_dict():
        _fail("P2.6 deterministic continuation diverged after save/load.")
        return

    errors = _invariants(loaded)
    if not errors.is_empty():
        _fail("P2.6 resumed invariant failure: %s" % " | ".join(errors))
        return

    _cleanup()
    print("P2.6 FORGE + EQUIPMENT TYCOON TEST PASS")
    print("seed=", TEST_SEED, " ticks=", loaded.tick, " items=", loaded.sect.equipment_items.size(), " forge_index=", loaded.sect.equipment_forge_index, " equipment_events=", loaded.sect.equipment_event_count)
    quit(0)

func _verify_hunt_to_forge_loop() -> bool:
    var state := P26Factory.create_state(TEST_SEED + 1)
    var equipment := EquipmentSystem.new()
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    var loot := equipment.forge_loot_for_victory(state, {"outcome":"win", "species_id":"hac_lang"})
    if int(loot.get("thanh_thiet", 0)) != 2 or int(loot.get("yeu_dan", 0)) != 1:
        _fail("P2.6 Hắc Lang did not produce the expected forge materials.")
        return false
    for raw_id in loot.keys():
        actor.add_item(str(raw_id), int(loot[raw_id]))
    var moved := equipment.deposit_forge_inventory(state, actor)
    if moved <= 0 or int(state.sect.forge_materials.get("thanh_thiet", 0)) != 2 or actor.inventory.has("thanh_thiet"):
        _fail("P2.6 hunted forge materials were not transferred to the sect forge store.")
        return false
    return true

func _verify_deterministic_forging() -> bool:
    var state_a := P26Factory.create_state(TEST_SEED + 2)
    var state_b := P26Factory.create_state(TEST_SEED + 2)
    var equipment := EquipmentSystem.new()
    _seed_forge_materials(state_a)
    _seed_forge_materials(state_b)
    var item_a := equipment.craft(state_a, &"thanh_thiet_kiem", true)
    var item_b := equipment.craft(state_b, &"thanh_thiet_kiem", true)
    if item_a.is_empty() or item_b.is_empty() or item_a != item_b:
        _fail("P2.6 forging was not deterministic for the same seed/index/recipe.")
        return false
    if str(item_a.get("location", "")) != "shop" or int(state_a.sect.forge_materials.get("thanh_thiet", 0)) != 17:
        _fail("P2.6 forging did not consume materials and place the result in the shop.")
        return false
    return true

func _verify_personalized_auto_choice_and_closed_money() -> bool:
    var state := P26Factory.create_state(TEST_SEED + 3)
    var equipment := EquipmentSystem.new()
    _seed_forge_materials(state)
    var sword := equipment.craft(state, &"thanh_thiet_kiem", true)
    var staff := equipment.craft(state, &"linh_moc_phap_truong", true)
    if sword.is_empty() or staff.is_empty():
        _fail("P2.6 choice probe could not forge shop items.")
        return false

    var sword_user: DiscipleState = state.disciples.get(&"bach_nguyet")
    var spell_user: DiscipleState = state.disciples.get(&"trieu_linh_nhi")
    _prepare_buyer(state, sword_user.id, &"sword", "metal")
    _prepare_buyer(state, spell_user.id, &"spell", "wood")

    if equipment.equipment_score(state, sword_user, sword) <= equipment.equipment_score(state, sword_user, staff):
        _fail("P2.6 sword-oriented disciple did not prefer the sword-compatible item.")
        return false
    if equipment.equipment_score(state, spell_user, staff) <= equipment.equipment_score(state, spell_user, sword):
        _fail("P2.6 spell-oriented disciple did not prefer the spell-compatible item.")
        return false
    if equipment.effective_combat_bonus_for_item(sword_user, sword) <= equipment.effective_combat_bonus_for_item(sword_user, staff):
        _fail("P2.6 path/root compatibility did not make the sword more effective for the sword build.")
        return false
    if equipment.effective_combat_bonus_for_item(spell_user, staff) <= equipment.effective_combat_bonus_for_item(spell_user, sword):
        _fail("P2.6 path/root compatibility did not make the staff more effective for the spell build.")
        return false

    var money_before := state.total_money()
    if not equipment.try_auto_upgrade(state, sword_user):
        _fail("P2.6 autonomous buyer did not purchase a meaningful upgrade.")
        return false
    if state.total_money() != money_before:
        _fail("P2.6 internal equipment purchase created or destroyed money.")
        return false
    var equipped := equipment.equipped_item(state, sword_user, EquipmentSystem.SLOT_WEAPON)
    if str(equipped.get("recipe_id", "")) != "thanh_thiet_kiem":
        _fail("P2.6 autonomous buyer chose the wrong build item.")
        return false
    return true

func _verify_manual_equip_lock_and_return_to_auto() -> bool:
    var state := P26Factory.create_state(TEST_SEED + 4)
    var equipment := EquipmentSystem.new()
    _seed_forge_materials(state)
    var sword := equipment.craft(state, &"thanh_thiet_kiem", false)
    var staff := equipment.craft(state, &"linh_moc_phap_truong", true)
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    _prepare_buyer(state, actor.id, &"spell", "wood")

    if not equipment.manual_equip(state, actor.id, StringName(sword.get("id", "")), true):
        _fail("P2.6 player could not manually equip and lock an item.")
        return false
    if equipment.try_auto_upgrade(state, actor):
        _fail("P2.6 AI replaced a player-locked equipment slot.")
        return false
    var locked_item := equipment.equipped_item(state, actor, EquipmentSystem.SLOT_WEAPON)
    if str(locked_item.get("id", "")) != str(sword.get("id", "")):
        _fail("P2.6 manual equipment lock did not retain the chosen item.")
        return false

    if not equipment.return_slot_to_auto(state, actor.id, EquipmentSystem.SLOT_WEAPON):
        _fail("P2.6 player could not return a slot to autonomous equipment control.")
        return false
    if actor.locked_equipment_slots.has("weapon"):
        _fail("P2.6 unlocked slot left a non-canonical false lock entry behind.")
        return false
    if not equipment.try_auto_upgrade(state, actor):
        _fail("P2.6 autonomous equipment did not resume after unlocking the slot.")
        return false
    var auto_item := equipment.equipped_item(state, actor, EquipmentSystem.SLOT_WEAPON)
    if str(auto_item.get("id", "")) != str(staff.get("id", "")):
        _fail("P2.6 unlocked slot did not switch to the better build item.")
        return false
    return true

func _verify_equipment_changes_region_choice() -> bool:
    var state := P26Factory.create_state(TEST_SEED + 5)
    var equipment := EquipmentSystem.new()
    var decisions := DecisionSystem.new()
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    state.relationships = {}
    state.memories = {}
    state.companion_assignments = {}
    state.teams = {}
    state.disciple_team_ids = {}
    state.role_assignments = {}
    state.sect.supply_stock = NeedsSystem.SUPPLY_CAP
    actor.region_id = &"sect"
    actor.target_region_id = &""
    actor.combat_power = 14.0
    actor.risk_bias = 0.50
    actor.active_goal = GoalSystem.GOAL_PREPARE
    actor.cultivation_stage_index = 0
    actor.cultivation_combat_bonus = 0.0
    actor.cultivation_path_xp = {"sword":0.0, "body":0.0, "spell":0.0}
    actor.active_technique_id = &""

    var before := decisions.choose_region(state, actor)
    if before != &"thanh_truc_lam":
        _fail("P2.6 region-power probe expected the unequipped disciple to choose Thanh Trúc Lâm.")
        return false

    _seed_forge_materials(state)
    var sword := equipment.craft(state, &"thanh_thiet_kiem", false)
    if not equipment.manual_equip(state, actor.id, StringName(sword.get("id", "")), true):
        _fail("P2.6 region-power probe could not equip the forged sword.")
        return false
    var after := decisions.choose_region(state, actor)
    if after == before:
        _fail("P2.6 equipment power did not change autonomous region choice.")
        return false
    return true

func _verify_equipment_changes_real_combat() -> bool:
    var weak_state := P26Factory.create_state(TEST_SEED + 6)
    var strong_state := P26Factory.create_state(TEST_SEED + 6)
    var equipment := EquipmentSystem.new()
    _seed_forge_materials(strong_state)
    var sword := equipment.craft(strong_state, &"thanh_thiet_kiem", false)
    var weak: DiscipleState = weak_state.disciples.get(&"bach_nguyet")
    var strong: DiscipleState = strong_state.disciples.get(&"bach_nguyet")
    for actor in [weak, strong]:
        actor.combat_power = 0.5
        actor.max_hp = 500.0
        actor.hp = 500.0
        actor.stamina = 100.0
        actor.region_id = &"thanh_truc_lam"
        actor.current_action = &"COMBAT"
        actor.learned_combat_skills = {}
    var weak_region: RegionState = weak_state.regions.get(&"thanh_truc_lam")
    var strong_region: RegionState = strong_state.regions.get(&"thanh_truc_lam")
    weak_region.monster_weights = {"truc_thu":1.0}
    strong_region.monster_weights = {"truc_thu":1.0}
    if not equipment.manual_equip(strong_state, strong.id, StringName(sword.get("id", "")), true):
        _fail("P2.6 combat probe could not equip the forged weapon.")
        return false
    if equipment.combat_power_bonus(strong_state, strong) <= 0.0:
        _fail("P2.6 forged weapon has no measurable combat-power effect.")
        return false

    SimulationScheduler.new(weak_state).step()
    SimulationScheduler.new(strong_state).step()
    var weak_wins := int(weak.metrics.get("wins", 0))
    var strong_wins := int(strong.metrics.get("wins", 0))
    if strong_wins <= weak_wins:
        _fail("P2.6 equipped combat power did not improve the controlled real combat outcome.")
        return false
    return true

func _prepare_buyer(state: SimulationState, disciple_id: StringName, path_id: StringName, element: String) -> void:
    var actor: DiscipleState = state.disciples.get(disciple_id)
    actor.region_id = &"sect"
    actor.wallet = 1000
    actor.spend_bias = 0.90
    actor.cultivation_path_xp = {"sword":0.0, "body":0.0, "spell":0.0}
    actor.cultivation_path_xp[str(path_id)] = CultivationPathSystem.DEPTH_XP
    actor.spiritual_root_elements = [element]
    match path_id:
        &"sword":
            actor.learned_techniques["thanh_phong_kiem_quyet"] = {"level":1, "xp":0.0}
            actor.active_technique_id = &"thanh_phong_kiem_quyet"
        &"body":
            actor.learned_techniques["huyen_giap_cong"] = {"level":1, "xp":0.0}
            actor.active_technique_id = &"huyen_giap_cong"
        _:
            actor.learned_techniques["xich_viem_chan_quyet"] = {"level":1, "xp":0.0}
            actor.active_technique_id = &"xich_viem_chan_quyet"
    state.initial_total_money = state.total_money()

func _seed_forge_materials(state: SimulationState) -> void:
    state.sect.forge_materials = {
        "linh_moc":20,
        "thanh_thiet":20,
        "tinh_lang_bi":20,
        "yeu_dan":20
    }

func _invariants(state: SimulationState) -> Array[String]:
    var errors := state.validate_invariants()
    errors.append_array(NeedsSystem.new().validate_invariants(state))
    errors.append_array(CultivationSystem.new().validate_invariants(state))
    errors.append_array(SpiritualRootSystem.new().validate_invariants(state))
    errors.append_array(TechniqueSystem.new().validate_invariants(state))
    errors.append_array(CultivationPathSystem.new().validate_invariants(state))
    errors.append_array(CombatSkillSystem.new().validate_invariants(state))
    errors.append_array(EquipmentSystem.new().validate_invariants(state))
    return errors

func _cleanup() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _fail(message: String) -> void:
    push_error(message)
    _cleanup()
    quit(1)
