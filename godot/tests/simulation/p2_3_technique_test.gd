extends SceneTree

const TEST_SEED := 1323232
const DETERMINISM_TICKS := 1200
const CONTINUATION_TICKS := 800
const SAVE_PATH := "user://p2_3_technique_test.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var techniques := TechniqueSystem.new()
    var state_a := P23Factory.create_state(TEST_SEED)
    var state_b := P23Factory.create_state(TEST_SEED)

    if not state_a.sect.techniques_enabled or not state_a.sect.spiritual_roots_enabled:
        _fail("P2.3 factory did not preserve P2.2 and enable techniques.")
        return
    if state_a.to_dict() != state_b.to_dict():
        _fail("Same-seed P2.3 initial state diverged.")
        return
    if not _all_invariants(state_a).is_empty():
        _fail("P2.3 initial state violated invariants.")
        return

    if not _verify_p22_path_unchanged(): return
    if not _verify_element_generation(): return
    if not _verify_gacha_manual_archive_sale_and_rng_isolation(): return
    if not _verify_farm_deposit_and_fragment_craft(): return
    if not _verify_learning_economy_and_slots(): return
    if not _verify_mastery_and_material_upgrade(): return
    if not _verify_technique_effects_are_real(): return

    var scheduler_a := SimulationScheduler.new(state_a)
    var scheduler_b := SimulationScheduler.new(state_b)
    scheduler_a.run_ticks(DETERMINISM_TICKS)
    scheduler_b.run_ticks(DETERMINISM_TICKS)
    if state_a.to_dict() != state_b.to_dict():
        _fail("P2.3 same-seed simulation diverged.")
        return
    var errors := _all_invariants(state_a)
    if not errors.is_empty():
        _fail("P2.3 invariant failure: %s" % " | ".join(errors))
        return

    var service := SaveService.new()
    if service.save_to_path(state_a, SAVE_PATH) != OK:
        _fail("P2.3 save failed.")
        return
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null or not loaded.sect.techniques_enabled:
        _fail("P2.3 save did not restore technique state.")
        return
    if state_a.to_dict() != loaded.to_dict():
        _fail("P2.3 technique state was not preserved by save/load.")
        return

    var control_scheduler := SimulationScheduler.new(state_a)
    var loaded_scheduler := SimulationScheduler.new(loaded)
    control_scheduler.run_ticks(CONTINUATION_TICKS)
    loaded_scheduler.run_ticks(CONTINUATION_TICKS)
    if state_a.to_dict() != loaded.to_dict():
        _fail("P2.3 deterministic continuation diverged after save/load.")
        return
    errors = _all_invariants(loaded)
    if not errors.is_empty():
        _fail("P2.3 resumed invariant failure: %s" % " | ".join(errors))
        return

    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

    print("P2.3 TECHNIQUE ECONOMY + MASTERY CONSEQUENCE TEST PASS")
    print("seed=", TEST_SEED, " ticks=", loaded.tick, " sect_stones=", loaded.sect.spirit_stones, " manuals=", loaded.sect.technique_manuals.size(), " fragments=", loaded.sect.technique_fragments.size(), " materials=", loaded.sect.technique_materials.size(), " technique_events=", loaded.sect.technique_event_count)
    quit(0)

func _verify_p22_path_unchanged() -> bool:
    var state := P22Factory.create_state(TEST_SEED + 1)
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    if state.sect.techniques_enabled or not actor.spiritual_root_elements.is_empty():
        _fail("P2.2 path unexpectedly enabled P2.3 technique/element state.")
        return false
    actor.region_id = &"sect"
    actor.stamina = 100.0
    actor.cultivation_progress = 0.0
    var expected := CultivationSystem.CULTIVATE_GAIN * SpiritualRootSystem.new().cultivation_multiplier(actor.spiritual_root_quality)
    var gained := CultivationSystem.new().cultivate(state, actor)
    if absf(gained - expected) > 0.000001:
        _fail("P2.3 changed P2.2 cultivation behavior while disabled.")
        return false
    return true

func _verify_element_generation() -> bool:
    var a := P23Factory.create_state(TEST_SEED + 2)
    var b := P23Factory.create_state(TEST_SEED + 2)
    for disciple_id in a.disciples.keys():
        var left: DiscipleState = a.disciples[disciple_id]
        var right: DiscipleState = b.disciples[disciple_id]
        if left.spiritual_root_elements.is_empty() or left.spiritual_root_elements != right.spiritual_root_elements:
            _fail("P2.3 elemental roots were missing or non-deterministic.")
            return false
    return true

func _verify_gacha_manual_archive_sale_and_rng_isolation() -> bool:
    var state := P23Factory.create_state(TEST_SEED + 3)
    var control := P23Factory.create_state(TEST_SEED + 3)
    var techniques := TechniqueSystem.new()
    var recruitment := RecruitmentSystem.new()
    var stones_before := state.sect.spirit_stones
    var rng_state_before := state.rng_state
    var result := techniques.gacha(state)
    if not bool(result.get("ok", false)):
        _fail("P2.3 gacha failed with enough sect spirit stones.")
        return false
    if state.sect.spirit_stones != stones_before - TechniqueSystem.GACHA_COST or state.rng_state != rng_state_before:
        _fail("P2.3 gacha cost/RNG isolation contract failed.")
        return false
    var technique_id := StringName(result.get("technique_id", ""))
    if techniques.manual_count(state, technique_id) != 1 or techniques.is_archived(state, technique_id):
        _fail("P2.3 gacha did not create a tradable manual before archive.")
        return false
    if not bool(techniques.archive_manual(state, technique_id).get("ok", false)):
        _fail("P2.3 could not archive a complete manual.")
        return false
    if not techniques.is_archived(state, technique_id) or techniques.manual_count(state, technique_id) != 0:
        _fail("P2.3 archive did not consume exactly one manual into permanent library access.")
        return false

    state.sect.technique_manuals[str(technique_id)] = 1
    var sale_before := state.sect.spirit_stones
    var sale := techniques.sell_manual(state, technique_id)
    if not bool(sale.get("ok", false)) or state.sect.spirit_stones <= sale_before or not techniques.is_archived(state, technique_id):
        _fail("P2.3 selling a spare manual did not return spirit stones while preserving the archive.")
        return false

    var next_after_gacha := recruitment.generate_candidate(state)
    var next_control := recruitment.generate_candidate(control)
    if next_after_gacha == null or next_control == null:
        _fail("P2.3 candidate RNG isolation probe could not generate candidates.")
        return false
    for key in ["id", "name", "combat_power", "risk_bias", "spend_bias", "survival_bias", "personality_id", "generated_index", "spiritual_root_quality", "spiritual_root_elements"]:
        if next_after_gacha.to_dict().get(key) != next_control.to_dict().get(key):
            _fail("P2.3 gacha changed recruitment field %s." % key)
            return false
    return true

func _verify_farm_deposit_and_fragment_craft() -> bool:
    var state := P23Factory.create_state(TEST_SEED + 4)
    var techniques := TechniqueSystem.new()
    var actor: DiscipleState = state.disciples.get(&"co_truong_phong")
    actor.region_id = &"hac_phong_coc"
    actor.inventory.clear()
    var found_fragment := false
    for index in range(80):
        state.tick = index + 1
        actor.metrics["combats"] = index + 1
        var loot := techniques.roll_farm_loot(state, actor)
        for item_id in loot.keys():
            actor.add_item(str(item_id), int(loot[item_id]))
            if str(item_id).begins_with(TechniqueSystem.FRAGMENT_PREFIX):
                found_fragment = true
        if found_fragment and actor.inventory.has(TechniqueSystem.SPECIAL_STONE_ITEM):
            break
    if not found_fragment:
        _fail("P2.3 farm probe did not produce any technique fragment.")
        return false
    actor.region_id = &"sect"
    var contribution_before := actor.contribution_points
    var personal_stones_before := actor.spirit_stones
    var deposited := techniques.deposit_special_inventory(state, actor)
    if int(deposited.get("fragments", 0)) <= 0 or int(deposited.get("materials", 0)) <= 0:
        _fail("P2.3 returning farm loot did not deposit fragments/materials.")
        return false
    if actor.contribution_points <= contribution_before:
        _fail("P2.3 farm deposit did not award personal contribution.")
        return false
    if int(deposited.get("stones", 0)) > 0 and actor.spirit_stones <= personal_stones_before:
        _fail("P2.3 personal spirit-stone loot did not enter the disciple wallet.")
        return false

    var technique_id := StringName("duong_khi_quyet")
    state.sect.technique_fragments[str(technique_id)] = techniques.fragment_required(technique_id)
    var manual_before := techniques.manual_count(state, technique_id)
    if not bool(techniques.craft_manual(state, technique_id).get("ok", false)):
        _fail("P2.3 could not combine sufficient fragments into a manual.")
        return false
    if techniques.manual_count(state, technique_id) != manual_before + 1 or int(state.sect.technique_fragments.get(str(technique_id), 0)) != 0:
        _fail("P2.3 fragment crafting did not consume fragments/create a manual exactly.")
        return false
    return true

func _verify_learning_economy_and_slots() -> bool:
    var state := P23Factory.create_state(TEST_SEED + 5)
    var techniques := TechniqueSystem.new()
    var actor: DiscipleState = state.disciples.get(&"tran_mac")
    actor.contribution_points = 2000
    actor.spirit_stones = 1000
    var ids: Array = TechniqueSystem.TECHNIQUES.keys()
    ids.sort()
    for technique_id in ids:
        state.sect.technique_library[str(technique_id)] = true

    var first_id := StringName(ids[0])
    var info := techniques.definition(first_id)
    var contribution_before := actor.contribution_points
    var personal_before := actor.spirit_stones
    var sect_before := state.sect.spirit_stones
    var learned := techniques.learn_technique(state, actor, first_id)
    if not bool(learned.get("ok", false)):
        _fail("P2.3 valid archived technique could not be learned.")
        return false
    if actor.contribution_points != contribution_before - int(info.get("learn_contribution", 0)):
        _fail("P2.3 learning did not consume personal contribution.")
        return false
    var stone_cost := int(info.get("learn_stones", 0))
    if actor.spirit_stones != personal_before - stone_cost or state.sect.spirit_stones != sect_before + stone_cost:
        _fail("P2.3 learning did not transfer personal spirit stones into the sect pool.")
        return false
    if actor.active_technique_id != first_id:
        _fail("P2.3 first learned technique was not made active.")
        return false

    var cursor := 1
    while actor.learned_techniques.size() < TechniqueSystem.MAX_LEARNED_TECHNIQUES:
        if not bool(techniques.learn_technique(state, actor, StringName(ids[cursor])).get("ok", false)):
            _fail("P2.3 could not fill valid technique slots.")
            return false
        cursor += 1
    var blocked := techniques.learn_technique(state, actor, StringName(ids[cursor]))
    if bool(blocked.get("ok", false)) or str(blocked.get("reason", "")) != "technique_slots_full":
        _fail("P2.3 learned-technique cap did not create a real selection constraint.")
        return false
    return true

func _verify_mastery_and_material_upgrade() -> bool:
    var state := P23Factory.create_state(TEST_SEED + 6)
    var techniques := TechniqueSystem.new()
    var actor: DiscipleState = state.disciples.get(&"bach_nguyet")
    var technique_id := StringName("duong_khi_quyet")
    state.sect.technique_library[str(technique_id)] = true
    actor.contribution_points = 1000
    actor.spirit_stones = 1000
    actor.spiritual_root_elements = ["wood"]
    if not bool(techniques.learn_technique(state, actor, technique_id).get("ok", false)):
        _fail("P2.3 mastery probe could not learn technique.")
        return false
    var gained := techniques.train_active_technique(state, actor)
    if gained <= TechniqueSystem.MASTERY_GAIN:
        _fail("P2.3 matching elemental root did not accelerate technique mastery.")
        return false

    var mastery: Dictionary = actor.learned_techniques[str(technique_id)]
    mastery["xp"] = techniques.mastery_required(1)
    actor.learned_techniques[str(technique_id)] = mastery
    var costs := techniques.upgrade_material_cost(technique_id, 1)
    for material_id in costs.keys():
        state.sect.technique_materials[str(material_id)] = int(costs[material_id])
    var result := techniques.upgrade_technique(state, actor, technique_id)
    if not bool(result.get("ok", false)) or int(actor.learned_techniques[str(technique_id)].get("level", 0)) != 2:
        _fail("P2.3 ready technique did not upgrade with required materials.")
        return false
    for material_id in costs.keys():
        if int(state.sect.technique_materials.get(str(material_id), 0)) != 0:
            _fail("P2.3 technique upgrade did not consume required materials.")
            return false
    return true

func _verify_technique_effects_are_real() -> bool:
    var techniques := TechniqueSystem.new()
    var cultivation := CultivationSystem.new()

    var growth_state := P23Factory.create_state(TEST_SEED + 7)
    var control_state := P23Factory.create_state(TEST_SEED + 7)
    var growth: DiscipleState = growth_state.disciples.get(&"bach_nguyet")
    var control: DiscipleState = control_state.disciples.get(&"bach_nguyet")
    for actor in [growth, control]:
        actor.region_id = &"sect"
        actor.stamina = 100.0
        actor.cultivation_progress = 0.0
        actor.spiritual_root_quality = SpiritualRootSystem.QUALITY_ORDINARY
        actor.spiritual_root_elements = ["wood"]
    growth.learned_techniques["duong_khi_quyet"] = {"level": 3, "xp": 0.0}
    growth.active_technique_id = &"duong_khi_quyet"
    var growth_gain := cultivation.cultivate(growth_state, growth)
    var control_gain := cultivation.cultivate(control_state, control)
    if growth_gain <= control_gain:
        _fail("P2.3 growth technique did not measurably increase cultivation gain.")
        return false

    var stable_state := P23Factory.create_state(TEST_SEED + 8)
    var stable: DiscipleState = stable_state.disciples.get(&"tran_mac")
    stable.spiritual_root_quality = SpiritualRootSystem.QUALITY_ORDINARY
    stable.spiritual_root_elements = ["water"]
    stable.learned_techniques["han_nguyet_tam_phap"] = {"level": 5, "xp": 0.0}
    stable.active_technique_id = &"han_nguyet_tam_phap"
    stable.cultivation_stage_index = 8
    stable.hp = stable.max_hp
    stable.stamina = 100.0
    stable.cultivation_progress = cultivation.required_progress(stable)
    var with_technique := cultivation.breakthrough_success_chance(stable, stable_state)
    stable.active_technique_id = &""
    var without_technique := cultivation.breakthrough_success_chance(stable, stable_state)
    if with_technique <= without_technique:
        _fail("P2.3 stability technique did not improve breakthrough probability.")
        return false

    var combat_state := P23Factory.create_state(TEST_SEED + 9)
    var fighter: DiscipleState = combat_state.disciples.get(&"co_truong_phong")
    fighter.spiritual_root_elements = ["metal"]
    fighter.learned_techniques["thanh_phong_kiem_quyet"] = {"level": 5, "xp": 0.0}
    fighter.active_technique_id = &"thanh_phong_kiem_quyet"
    var boosted_power := cultivation.effective_combat_power(combat_state, fighter)
    fighter.active_technique_id = &""
    var base_power := cultivation.effective_combat_power(combat_state, fighter)
    if boosted_power <= base_power:
        _fail("P2.3 offense technique did not change effective combat power.")
        return false

    fighter.learned_techniques["huyen_giap_cong"] = {"level": 5, "xp": 0.0}
    fighter.active_technique_id = &"huyen_giap_cong"
    if techniques.incoming_damage_multiplier(combat_state, fighter) >= 1.0:
        _fail("P2.3 defense technique did not reduce incoming combat damage.")
        return false
    return true

func _all_invariants(state: SimulationState) -> Array[String]:
    var errors := state.validate_invariants()
    errors.append_array(NeedsSystem.new().validate_invariants(state))
    errors.append_array(CultivationSystem.new().validate_invariants(state))
    errors.append_array(SpiritualRootSystem.new().validate_invariants(state))
    errors.append_array(TechniqueSystem.new().validate_invariants(state))
    return errors

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
