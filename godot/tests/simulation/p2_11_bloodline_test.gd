extends SceneTree

const TEST_SEED := 2031122
const SAVE_PATH := "user://p2_11_bloodline_test.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _verify_p2_10_gate_unchanged():
        return
    if not _verify_profiles_are_deterministic_and_none_is_stable():
        return
    if not _verify_reveal_does_not_reroll_identity():
        return
    if not _verify_unawakened_has_no_effect():
        return
    if not _verify_awakening_consumes_real_resource_and_has_consequence():
        return
    if not _verify_all_special_bloodlines_have_real_core_advantages():
        return
    if not _verify_huyen_vu_defense():
        return
    if not _verify_phuong_hoang_recovery():
        return
    if not _verify_taotie_tradeoff():
        return
    if not _verify_refinement_and_diminishing_returns():
        return
    if not _verify_recruitment_profile_lifecycle():
        return
    if not _verify_persistence_and_continuation():
        return

    print("P2.11 BLOODLINE + AWAKENING TEST PASS")
    quit(0)

func _verify_p2_10_gate_unchanged() -> bool:
    var legacy := P210Factory.create_state(TEST_SEED)
    if legacy.sect.bloodlines_enabled:
        return _fail("P2.10 must remain bloodline-disabled.")
    if not legacy.sect.bloodline_profiles.is_empty():
        return _fail("P2.11 bloodline state leaked into P2.10.")
    return true

func _verify_profiles_are_deterministic_and_none_is_stable() -> bool:
    var state_a := P211Factory.create_state(TEST_SEED + 1)
    var state_b := P211Factory.create_state(TEST_SEED + 1)
    if state_a.sect.bloodline_profiles != state_b.sect.bloodline_profiles:
        return _fail("P2.11 same-seed bloodline profiles diverged.")

    var probe_state := P210Factory.create_state(TEST_SEED + 2)
    probe_state.sect.bloodlines_enabled = true
    var generator := DiscipleGeneratorV2.new()
    var system := BloodlineSystem.new()
    var found_none := false
    for index in range(20, 140):
        var candidate := generator.generate_candidate(probe_state, DiscipleGeneratorV2.SOURCE_ORDINARY, index)
        var first := system.ensure_candidate_profile(probe_state, candidate).duplicate(true)
        if StringName(first.get("bloodline_id", "none")) == BloodlineSystem.BLOODLINE_NONE:
            var second := system.ensure_candidate_profile(probe_state, candidate).duplicate(true)
            if first != second:
                return _fail("P2.11 no-bloodline result was rerolled.")
            found_none = true
            break
    if not found_none:
        return _fail("P2.11 deterministic sample could not produce a valid no-bloodline candidate.")
    return true

func _verify_reveal_does_not_reroll_identity() -> bool:
    var state := P211Factory.create_state(TEST_SEED + 3)
    var actor := _probe_disciple("reveal_probe")
    state.disciples[actor.id] = actor
    _set_profile(state, actor.id, BloodlineSystem.BLOODLINE_TRUE_DRAGON, 0.22, false, false, 0)
    actor.metrics["combats"] = 3
    var system := BloodlineSystem.new()
    var before := system.profile_for(state, actor.id).duplicate(true)
    if not system.process_reveal(state, actor):
        return _fail("P2.11 hidden bloodline did not reveal at its history threshold.")
    var after := system.profile_for(state, actor.id)
    if StringName(after.get("bloodline_id", "none")) != StringName(before.get("bloodline_id", "none")):
        return _fail("P2.11 reveal rerolled bloodline identity.")
    if absf(float(after.get("purity", 0.0)) - float(before.get("purity", 0.0))) > 0.000001:
        return _fail("P2.11 reveal changed pre-generated bloodline purity.")
    if not bool(after.get("revealed", false)) or bool(after.get("awakened", false)):
        return _fail("P2.11 reveal incorrectly awakened the bloodline.")
    return true

func _verify_unawakened_has_no_effect() -> bool:
    var state := P211Factory.create_state(TEST_SEED + 4)
    var neutral := _probe_disciple("neutral_dragon")
    var dormant := _probe_disciple("dormant_dragon")
    neutral.cultivation_stage_index = 8
    dormant.cultivation_stage_index = 8
    state.disciples[neutral.id] = neutral
    state.disciples[dormant.id] = dormant
    _set_profile(state, neutral.id, BloodlineSystem.BLOODLINE_NONE, 0.0, true, false, 0)
    _set_profile(state, dormant.id, BloodlineSystem.BLOODLINE_TRUE_DRAGON, 0.30, true, false, 0)
    var cultivation := CultivationSystem.new()
    if absf(cultivation.effective_combat_power(state, dormant) - cultivation.effective_combat_power(state, neutral)) > 0.000001:
        return _fail("P2.11 dormant bloodline affected combat before awakening.")
    if absf(cultivation.breakthrough_success_chance(dormant, state) - cultivation.breakthrough_success_chance(neutral, state)) > 0.000001:
        return _fail("P2.11 dormant bloodline affected breakthrough before awakening.")
    return true

func _verify_awakening_consumes_real_resource_and_has_consequence() -> bool:
    var state := P211Factory.create_state(TEST_SEED + 5)
    var actor := _probe_disciple("awaken_dragon")
    actor.cultivation_stage_index = 8
    state.disciples[actor.id] = actor
    _set_profile(state, actor.id, BloodlineSystem.BLOODLINE_TRUE_DRAGON, 0.30, true, false, 0)
    state.sect.technique_materials[BloodlineSystem.MATERIAL_ID] = 3
    var system := BloodlineSystem.new()
    var cultivation := CultivationSystem.new()
    var power_before := cultivation.effective_combat_power(state, actor)
    var breakthrough_before := cultivation.breakthrough_success_chance(actor, state)
    var material_before := int(state.sect.technique_materials.get(BloodlineSystem.MATERIAL_ID, 0))
    var result := system.awaken_bloodline(state, actor.id)
    if not bool(result.get("ok", false)):
        return _fail("P2.11 bloodline awakening failed.")
    if int(state.sect.technique_materials.get(BloodlineSystem.MATERIAL_ID, 0)) != material_before - 1:
        return _fail("P2.11 awakening did not consume exactly one real Yêu Đan.")
    if cultivation.effective_combat_power(state, actor) <= power_before:
        return _fail("P2.11 awakened Chân Long has no real combat consequence.")
    if cultivation.breakthrough_success_chance(actor, state) <= breakthrough_before:
        return _fail("P2.11 awakened Chân Long has no real breakthrough consequence.")
    return true

func _verify_all_special_bloodlines_have_real_core_advantages() -> bool:
    var state := P211Factory.create_state(TEST_SEED + 50)
    var system := BloodlineSystem.new()
    var ids := [
        BloodlineSystem.BLOODLINE_TRUE_DRAGON,
        BloodlineSystem.BLOODLINE_PHOENIX,
        BloodlineSystem.BLOODLINE_WHITE_TIGER,
        BloodlineSystem.BLOODLINE_BLACK_TORTOISE,
        BloodlineSystem.BLOODLINE_TAOTIE_REMNANT
    ]
    for index in range(ids.size()):
        var actor := _probe_disciple("core_stats_%d" % index)
        state.disciples[actor.id] = actor
        _set_profile(state, actor.id, ids[index], 0.50, true, true, 0)
        var stats := system.stat_profile(state, actor)
        var attack := float(stats.get("combat_power_bonus", 0.0))
        var defense := float(stats.get("damage_reduction_pct", 0.0))
        if attack <= 0.0 and defense <= 0.0:
            return _fail("P2.11 special bloodline %s has no real attack/defense advantage." % str(ids[index]))
        var advantageous_axes := 0
        for key in ["combat_power_bonus", "damage_reduction_pct", "cultivation_bonus_pct", "breakthrough_bonus_pct", "recovery_bonus_pct"]:
            if float(stats.get(key, 0.0)) > 0.000001:
                advantageous_axes += 1
        if advantageous_axes < 2:
            return _fail("P2.11 special bloodline %s has fewer than two real beneficial stat axes." % str(ids[index]))
    return true

func _verify_huyen_vu_defense() -> bool:
    var state := P211Factory.create_state(TEST_SEED + 6)
    var neutral := _probe_disciple("defense_neutral")
    var turtle := _probe_disciple("defense_turtle")
    state.disciples[neutral.id] = neutral
    state.disciples[turtle.id] = turtle
    _set_profile(state, neutral.id, BloodlineSystem.BLOODLINE_NONE, 0.0, true, false, 0)
    _set_profile(state, turtle.id, BloodlineSystem.BLOODLINE_BLACK_TORTOISE, 0.40, true, true, 0)
    var system := BloodlineSystem.new()
    if system.incoming_damage_multiplier(state, turtle) >= system.incoming_damage_multiplier(state, neutral):
        return _fail("P2.11 awakened Huyền Vũ does not reduce real combat incoming damage multiplier.")
    return true

func _verify_phuong_hoang_recovery() -> bool:
    var state := P211Factory.create_state(TEST_SEED + 7)
    state.sect.lodging_capacity = 20
    var neutral := _probe_disciple("rest_neutral")
    var phoenix := _probe_disciple("rest_phoenix")
    state.disciples[neutral.id] = neutral
    state.disciples[phoenix.id] = phoenix
    neutral.hp = 50.0
    phoenix.hp = 50.0
    neutral.stamina = 20.0
    phoenix.stamina = 20.0
    _set_profile(state, neutral.id, BloodlineSystem.BLOODLINE_NONE, 0.0, true, false, 0)
    _set_profile(state, phoenix.id, BloodlineSystem.BLOODLINE_PHOENIX, 0.40, true, true, 0)
    var needs := NeedsSystem.new()
    var neutral_before := neutral.stamina
    var phoenix_before := phoenix.stamina
    needs.apply_rest(state, neutral)
    needs.apply_rest(state, phoenix)
    if phoenix.stamina - phoenix_before <= neutral.stamina - neutral_before:
        return _fail("P2.11 awakened Phượng Hoàng does not improve real rest recovery.")
    return true

func _verify_taotie_tradeoff() -> bool:
    var state := P211Factory.create_state(TEST_SEED + 8)
    var neutral := _probe_disciple("supply_neutral")
    var taotie := _probe_disciple("supply_taotie")
    state.disciples[neutral.id] = neutral
    state.disciples[taotie.id] = taotie
    _set_profile(state, neutral.id, BloodlineSystem.BLOODLINE_NONE, 0.0, true, false, 0)
    _set_profile(state, taotie.id, BloodlineSystem.BLOODLINE_TAOTIE_REMNANT, 0.35, true, true, 0)
    var needs := NeedsSystem.new()

    state.sect.supply_stock = 10
    needs.prepare_departure(state, neutral)
    var neutral_used := 10 - state.sect.supply_stock

    state.sect.supply_stock = 10
    needs.prepare_departure(state, taotie)
    var taotie_used := 10 - state.sect.supply_stock
    if taotie_used != neutral_used + 1:
        return _fail("P2.11 Thao Thiết did not consume one extra real supply on departure.")

    neutral.hp = 50.0
    taotie.hp = 50.0
    neutral.stamina = 20.0
    taotie.stamina = 20.0
    state.sect.lodging_capacity = 20
    var neutral_before := neutral.stamina
    var taotie_before := taotie.stamina
    needs.apply_rest(state, neutral)
    needs.apply_rest(state, taotie)
    if taotie.stamina - taotie_before <= neutral.stamina - neutral_before:
        return _fail("P2.11 Thao Thiết pays extra supplies but gets no recovery benefit.")
    if BloodlineSystem.new().combat_power_bonus(state, taotie) <= 0.0:
        return _fail("P2.11 Thao Thiết tradeoff exists but the bloodline has no core combat advantage.")
    return true

func _verify_refinement_and_diminishing_returns() -> bool:
    var state := P211Factory.create_state(TEST_SEED + 9)
    var low := _probe_disciple("blood_low")
    var high := _probe_disciple("blood_high")
    low.potential = 0.70
    high.potential = 0.70
    state.disciples[low.id] = low
    state.disciples[high.id] = high
    _set_profile(state, low.id, BloodlineSystem.BLOODLINE_WHITE_TIGER, 0.20, true, true, 0)
    _set_profile(state, high.id, BloodlineSystem.BLOODLINE_WHITE_TIGER, 0.82, true, true, 0)
    state.sect.technique_materials[BloodlineSystem.MATERIAL_ID] = 4
    var system := BloodlineSystem.new()
    var low_before := system.purity(state, low.id)
    var high_before := system.purity(state, high.id)
    var low_power_before := system.combat_power_bonus(state, low)
    var low_result := system.refine_bloodline(state, low.id)
    var high_result := system.refine_bloodline(state, high.id)
    if not bool(low_result.get("ok", false)) or not bool(high_result.get("ok", false)):
        return _fail("P2.11 bloodline refinement failed.")
    var low_gain := system.purity(state, low.id) - low_before
    var high_gain := system.purity(state, high.id) - high_before
    if low_gain <= 0.0 or high_gain <= 0.0:
        return _fail("P2.11 bloodline refinement did not increase purity.")
    if low_gain <= high_gain:
        return _fail("P2.11 bloodline refinement has no diminishing returns at high purity.")
    if system.combat_power_bonus(state, low) <= low_power_before:
        return _fail("P2.11 higher bloodline purity did not strengthen a real core stat.")
    return true

func _verify_recruitment_profile_lifecycle() -> bool:
    var state := P211Factory.create_state(TEST_SEED + 10)
    state.sect.disciple_capacity += 3
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    if ids.size() < 2:
        return _fail("P2.11 recruitment lifecycle needs at least two candidates.")
    var accepted_id := StringName(ids[0])
    var rejected_id := StringName(ids[1])
    var system := BloodlineSystem.new()
    var accepted_profile := system.profile_for(state, accepted_id).duplicate(true)
    if accepted_profile.is_empty():
        return _fail("P2.11 candidate has no bloodline profile.")
    if not bool(RecruitmentSystem.new().accept_candidate(state, accepted_id).get("ok", false)):
        return _fail("P2.11 could not accept candidate.")
    if system.profile_for(state, accepted_id) != accepted_profile:
        return _fail("P2.11 candidate -> disciple acceptance changed bloodline identity.")
    if not bool(RecruitmentSystem.new().reject_candidate(state, rejected_id).get("ok", false)):
        return _fail("P2.11 could not reject candidate.")
    if not system.profile_for(state, rejected_id).is_empty():
        return _fail("P2.11 rejected candidate left an orphan bloodline profile.")
    return true

func _verify_persistence_and_continuation() -> bool:
    var state_a := P211Factory.create_state(TEST_SEED + 11)
    var actor := _accept_first_candidate(state_a)
    if actor == null:
        return _fail("P2.11 persistence probe could not accept candidate.")
    _set_profile(state_a, actor.id, BloodlineSystem.BLOODLINE_TRUE_DRAGON, 0.30, true, true, 1)
    state_a.sect.technique_materials[BloodlineSystem.MATERIAL_ID] = 5
    BloodlineSystem.new().refine_bloodline(state_a, actor.id)

    var service := SaveService.new()
    if service.save_to_path(state_a, SAVE_PATH) != OK:
        return _fail("P2.11 save failed.")
    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null or not loaded.sect.bloodlines_enabled:
        return _fail("P2.11 save did not restore bloodline feature state.")
    if state_a.to_dict() != loaded.to_dict():
        return _fail("P2.11 exact save/load state diverged.")

    SimulationScheduler.new(state_a).run_ticks(80)
    SimulationScheduler.new(loaded).run_ticks(80)
    if state_a.to_dict() != loaded.to_dict():
        return _fail("P2.11 deterministic continuation diverged after save/load.")
    var errors := _all_invariants(loaded)
    if not errors.is_empty():
        return _fail("P2.11 invariant failure after continuation: %s" % " | ".join(errors))
    _cleanup()
    return true

func _accept_first_candidate(state: SimulationState) -> DiscipleState:
    state.sect.disciple_capacity += 2
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    if ids.is_empty():
        return null
    var candidate_id := StringName(ids[0])
    var result := RecruitmentSystem.new().accept_candidate(state, candidate_id)
    if not bool(result.get("ok", false)):
        return null
    return state.disciples.get(candidate_id)

func _probe_disciple(id_text: String) -> DiscipleState:
    return DiscipleState.new({
        "id":id_text,
        "name":id_text,
        "profile_seed":101,
        "recruitment_source":"ordinary",
        "latent_identity_seed":303,
        "combat_power":18.0,
        "potential":0.60,
        "aptitude":0.55,
        "spiritual_root_quality":"ordinary",
        "spiritual_root_purity":0.55,
        "spiritual_root_elements":["fire"],
        "cultivation_stage_index":0,
        "cultivation_progress":0.0,
        "cultivation_combat_bonus":0.0,
        "cultivation_hp_bonus":0.0,
        "hp":100.0,
        "max_hp":100.0,
        "stamina":100.0
    })

func _set_profile(state: SimulationState, character_id: StringName, lineage_id: StringName, lineage_purity: float, revealed: bool, awakened: bool, refinement_count: int) -> void:
    state.sect.bloodline_profiles[str(character_id)] = {
        "initialized":true,
        "bloodline_id":str(lineage_id),
        "purity":lineage_purity,
        "revealed":revealed,
        "awakened":awakened,
        "refinement_count":refinement_count
    }

func _all_invariants(state: SimulationState) -> Array[String]:
    var errors := state.validate_invariants()
    errors.append_array(NeedsSystem.new().validate_invariants(state))
    errors.append_array(CultivationSystem.new().validate_invariants(state))
    errors.append_array(SpiritualRootSystem.new().validate_invariants(state))
    errors.append_array(TechniqueSystem.new().validate_invariants(state))
    errors.append_array(CultivationPathSystem.new().validate_invariants(state))
    errors.append_array(CombatSkillSystem.new().validate_invariants(state))
    errors.append_array(EquipmentSystem.new().validate_invariants(state))
    errors.append_array(WorkforceSystem.new().validate_invariants(state))
    errors.append_array(TraitSystem.new().validate_invariants(state))
    errors.append_array(RootRefinementSystem.new().validate_invariants(state))
    errors.append_array(BloodlineSystem.new().validate_invariants(state))
    return errors

func _cleanup() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _fail(message: String) -> bool:
    _cleanup()
    push_error(message)
    quit(1)
    return false
