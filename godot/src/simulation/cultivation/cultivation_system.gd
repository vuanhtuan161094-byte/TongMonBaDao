class_name CultivationSystem
extends RefCounted

const DIRECTIVE_BALANCED := &"balanced"
const DIRECTIVE_CULTIVATE := &"cultivate"
const DIRECTIVE_FIELD := &"field"
const VALID_DIRECTIVES := [DIRECTIVE_BALANCED, DIRECTIVE_CULTIVATE, DIRECTIVE_FIELD]

const CULTIVATE_GAIN := 8.0
const COMBAT_WIN_GAIN := 2.0
const CULTIVATE_STAMINA_COST := 12.0
const BREAKTHROUGH_SUCCESS_STAMINA_COST := 30.0
const BREAKTHROUGH_FAILURE_STAMINA_COST := 40.0
const BREAKTHROUGH_FAILURE_HP_RATIO := 0.18
const BREAKTHROUGH_FAILURE_PROGRESS_LOSS := 0.20
const BREAKTHROUGH_FAILURE_COOLDOWN := 90
const BREAKTHROUGH_SUCCESS_COOLDOWN := 20
const MIN_BREAKTHROUGH_HP_RATIO := 0.75
const MIN_BREAKTHROUGH_STAMINA := 65.0

var spiritual_root_system := SpiritualRootSystem.new()
var root_refinement_system := RootRefinementSystem.new()
var technique_system := TechniqueSystem.new()
var cultivation_path_system := CultivationPathSystem.new()
var trait_system := TraitSystem.new()
var bloodline_system := BloodlineSystem.new()
var physique_system := PhysiqueSystem.new()
var character_modifiers := CharacterModifierSystem.new()

const STAGES := [
    {"id":"qi_1", "name":"Luyện Khí tầng 1", "required":500.0, "combat_bonus":0.0, "hp_bonus":0.0, "chance":0.98},
    {"id":"qi_2", "name":"Luyện Khí tầng 2", "required":700.0, "combat_bonus":1.0, "hp_bonus":2.0, "chance":0.97},
    {"id":"qi_3", "name":"Luyện Khí tầng 3", "required":950.0, "combat_bonus":2.0, "hp_bonus":4.0, "chance":0.96},
    {"id":"qi_4", "name":"Luyện Khí tầng 4", "required":1200.0, "combat_bonus":3.0, "hp_bonus":6.0, "chance":0.94},
    {"id":"qi_5", "name":"Luyện Khí tầng 5", "required":1500.0, "combat_bonus":4.0, "hp_bonus":8.0, "chance":0.92},
    {"id":"qi_6", "name":"Luyện Khí tầng 6", "required":1850.0, "combat_bonus":5.0, "hp_bonus":10.0, "chance":0.90},
    {"id":"qi_7", "name":"Luyện Khí tầng 7", "required":2200.0, "combat_bonus":6.0, "hp_bonus":12.0, "chance":0.88},
    {"id":"qi_8", "name":"Luyện Khí tầng 8", "required":2600.0, "combat_bonus":7.0, "hp_bonus":14.0, "chance":0.85},
    {"id":"qi_9", "name":"Luyện Khí tầng 9", "required":3500.0, "combat_bonus":8.0, "hp_bonus":16.0, "chance":0.78},
    {"id":"foundation_early", "name":"Trúc Cơ sơ kỳ", "required":6000.0, "combat_bonus":12.0, "hp_bonus":30.0, "chance":0.90},
    {"id":"foundation_mid", "name":"Trúc Cơ trung kỳ", "required":9000.0, "combat_bonus":15.0, "hp_bonus":38.0, "chance":0.86},
    {"id":"foundation_late", "name":"Trúc Cơ hậu kỳ", "required":13000.0, "combat_bonus":18.0, "hp_bonus":46.0, "chance":0.82},
    {"id":"foundation_perfect", "name":"Trúc Cơ viên mãn", "required":18000.0, "combat_bonus":22.0, "hp_bonus":55.0, "chance":0.72},
    {"id":"core_early", "name":"Kim Đan sơ kỳ", "required":26000.0, "combat_bonus":30.0, "hp_bonus":75.0, "chance":0.86},
    {"id":"core_mid", "name":"Kim Đan trung kỳ", "required":36000.0, "combat_bonus":36.0, "hp_bonus":88.0, "chance":0.80},
    {"id":"core_late", "name":"Kim Đan hậu kỳ", "required":48000.0, "combat_bonus":42.0, "hp_bonus":102.0, "chance":0.74},
    {"id":"core_perfect", "name":"Kim Đan viên mãn", "required":0.0, "combat_bonus":50.0, "hp_bonus":120.0, "chance":0.0}
]

func initialize(state: SimulationState) -> void:
    state.sect.cultivation_enabled = true
    for disciple_value in state.disciples.values():
        _normalize_disciple(disciple_value)

func set_directive(state: SimulationState, disciple_id: StringName, directive: StringName) -> bool:
    if not state.sect.cultivation_enabled or not state.disciples.has(disciple_id) or not VALID_DIRECTIVES.has(directive):
        return false
    var disciple: DiscipleState = state.disciples[disciple_id]
    disciple.cultivation_directive = directive
    state.sect.cultivation_event_count += 1
    return true

func stage_definition(disciple: DiscipleState) -> Dictionary:
    return STAGES[clampi(disciple.cultivation_stage_index, 0, STAGES.size() - 1)]

func stage_name(disciple: DiscipleState) -> String:
    return str(stage_definition(disciple).get("name", "Luyện Khí tầng 1"))

func required_progress(disciple: DiscipleState) -> float:
    return float(stage_definition(disciple).get("required", 0.0))

func is_max_stage(disciple: DiscipleState) -> bool:
    return disciple.cultivation_stage_index >= STAGES.size() - 1

func is_ready(disciple: DiscipleState) -> bool:
    var required := required_progress(disciple)
    return required > 0.0 and disciple.cultivation_progress + 0.000001 >= required

func can_breakthrough(state: SimulationState, disciple: DiscipleState) -> bool:
    if not state.sect.cultivation_enabled or is_max_stage(disciple) or not is_ready(disciple):
        return false
    if state.tick < disciple.next_breakthrough_tick:
        return false
    if disciple.hp / maxf(disciple.max_hp, 1.0) < MIN_BREAKTHROUGH_HP_RATIO:
        return false
    return disciple.stamina >= MIN_BREAKTHROUGH_STAMINA

func cultivate(state: SimulationState, disciple: DiscipleState) -> float:
    if not state.sect.cultivation_enabled or disciple.region_id != &"sect" or is_max_stage(disciple) or is_ready(disciple):
        return 0.0
    if disciple.stamina < CULTIVATE_STAMINA_COST:
        return 0.0
    var base_gain := CULTIVATE_GAIN
    if state.sect.techniques_enabled:
        base_gain *= technique_system.cultivation_gain_multiplier(state, disciple)
    if state.sect.cultivation_paths_enabled:
        base_gain *= cultivation_path_system.cultivation_gain_multiplier(state, disciple)
        var active_path := cultivation_path_system.active_technique_path(disciple)
        base_gain *= cultivation_path_system.technique_effect_multiplier(state, disciple, active_path)
    var gained := add_progress(state, disciple, base_gain)
    disciple.stamina = maxf(0.0, disciple.stamina - CULTIVATE_STAMINA_COST)
    disciple.metrics["cultivation_sessions"] = int(disciple.metrics.get("cultivation_sessions", 0)) + 1
    return gained

func add_combat_win_progress(state: SimulationState, disciple: DiscipleState) -> float:
    if not state.sect.cultivation_enabled:
        return 0.0
    return add_progress(state, disciple, COMBAT_WIN_GAIN)

func add_progress(state: SimulationState, disciple: DiscipleState, amount: float) -> float:
    if not state.sect.cultivation_enabled or amount <= 0.0 or is_max_stage(disciple):
        return 0.0
    var required := required_progress(disciple)
    var effective_amount := amount
    if state.sect.spiritual_roots_enabled:
        if state.sect.spiritual_root_refinement_enabled and disciple.profile_seed > 0:
            effective_amount *= root_refinement_system.cultivation_multiplier(state, disciple)
        else:
            effective_amount *= spiritual_root_system.cultivation_multiplier(disciple.spiritual_root_quality)
    if state.sect.disciple_generation_v2_enabled and disciple.profile_seed > 0:
        effective_amount *= character_modifiers.foundation_channel_factor(disciple, CharacterModifierSystem.CHANNEL_CULTIVATION_GAIN)
    if state.sect.disciple_traits_enabled:
        effective_amount *= trait_system.cultivation_gain_multiplier(state, disciple)
    if state.sect.bloodlines_enabled:
        effective_amount *= bloodline_system.cultivation_gain_multiplier(state, disciple)
    if state.sect.physiques_enabled:
        effective_amount *= physique_system.cultivation_multiplier(state, disciple)
    var before := disciple.cultivation_progress
    disciple.cultivation_progress = minf(required, before + effective_amount)
    var gained := disciple.cultivation_progress - before
    if gained > 0.0:
        disciple.metrics["cultivation_gained"] = int(disciple.metrics.get("cultivation_gained", 0)) + int(round(gained))
    return gained

func breakthrough_success_chance(disciple: DiscipleState, state: SimulationState = null) -> float:
    var definition := stage_definition(disciple)
    var base := float(definition.get("chance", 0.0))
    if base <= 0.0:
        return 0.0
    var hp_ratio := disciple.hp / maxf(disciple.max_hp, 1.0)
    var hp_bonus := clampf((hp_ratio - MIN_BREAKTHROUGH_HP_RATIO) * 0.08, 0.0, 0.02)
    var stamina_bonus := clampf((disciple.stamina - MIN_BREAKTHROUGH_STAMINA) / 35.0 * 0.02, 0.0, 0.02)
    var modifier := 0.0
    if state != null and state.sect.spiritual_roots_enabled:
        if state.sect.spiritual_root_refinement_enabled and disciple.profile_seed > 0:
            modifier += root_refinement_system.breakthrough_modifier(state, disciple)
        else:
            modifier += spiritual_root_system.breakthrough_modifier(disciple.spiritual_root_quality)
    if state != null and state.sect.techniques_enabled:
        var technique_bonus := technique_system.breakthrough_bonus(state, disciple)
        if state.sect.cultivation_paths_enabled:
            technique_bonus *= cultivation_path_system.technique_effect_multiplier(state, disciple, cultivation_path_system.active_technique_path(disciple))
        modifier += technique_bonus
    if state != null and state.sect.bloodlines_enabled:
        modifier += bloodline_system.breakthrough_bonus(state, disciple)
    if state != null and state.sect.physiques_enabled:
        modifier += physique_system.breakthrough_bonus(state, disciple)
    return clampf(base + hp_bonus + stamina_bonus + modifier, 0.45, 0.99)

func attempt_breakthrough(state: SimulationState, disciple: DiscipleState, rng: GameRng) -> Dictionary:
    return resolve_breakthrough(state, disciple, rng.randf())

func resolve_breakthrough(state: SimulationState, disciple: DiscipleState, roll: float) -> Dictionary:
    if not can_breakthrough(state, disciple):
        return {"ok": false, "outcome": "blocked"}
    var required := required_progress(disciple)
    var chance := breakthrough_success_chance(disciple, state)
    state.sect.cultivation_event_count += 1
    if clampf(roll, 0.0, 1.0) < chance:
        disciple.cultivation_progress = maxf(0.0, disciple.cultivation_progress - required)
        disciple.cultivation_stage_index = mini(disciple.cultivation_stage_index + 1, STAGES.size() - 1)
        _apply_stage_bonus(disciple)
        disciple.stamina = maxf(0.0, disciple.stamina - BREAKTHROUGH_SUCCESS_STAMINA_COST)
        disciple.next_breakthrough_tick = state.tick + BREAKTHROUGH_SUCCESS_COOLDOWN
        disciple.last_breakthrough_outcome = &"success"
        disciple.metrics["breakthrough_successes"] = int(disciple.metrics.get("breakthrough_successes", 0)) + 1
        return {"ok": true, "outcome": "success", "stage_index": disciple.cultivation_stage_index, "stage_name": stage_name(disciple), "chance": chance}

    var failure_multiplier := technique_system.breakthrough_failure_multiplier(state, disciple) if state.sect.techniques_enabled else 1.0
    if state.sect.cultivation_paths_enabled and state.sect.techniques_enabled:
        var path_effect := cultivation_path_system.technique_effect_multiplier(state, disciple, cultivation_path_system.active_technique_path(disciple))
        failure_multiplier = clampf(1.0 - (1.0 - failure_multiplier) * path_effect, 0.35, 1.0)
    disciple.cultivation_progress = maxf(0.0, disciple.cultivation_progress - required * BREAKTHROUGH_FAILURE_PROGRESS_LOSS * failure_multiplier)
    disciple.stamina = maxf(0.0, disciple.stamina - BREAKTHROUGH_FAILURE_STAMINA_COST * failure_multiplier)
    disciple.hp = maxf(1.0, disciple.hp - disciple.max_hp * BREAKTHROUGH_FAILURE_HP_RATIO * failure_multiplier)
    disciple.breakthrough_failures += 1
    disciple.next_breakthrough_tick = state.tick + BREAKTHROUGH_FAILURE_COOLDOWN
    disciple.last_breakthrough_outcome = &"failure"
    disciple.metrics["breakthrough_failures"] = int(disciple.metrics.get("breakthrough_failures", 0)) + 1
    return {"ok": true, "outcome": "failure", "chance": chance}

func effective_combat_power(state: SimulationState, disciple: DiscipleState) -> float:
    if not state.sect.cultivation_enabled:
        return disciple.combat_power
    var power := disciple.combat_power + disciple.cultivation_combat_bonus
    if state.sect.techniques_enabled:
        var technique_bonus := technique_system.combat_power_bonus(state, disciple)
        if state.sect.cultivation_paths_enabled:
            technique_bonus *= cultivation_path_system.technique_effect_multiplier(state, disciple, cultivation_path_system.active_technique_path(disciple))
        power += technique_bonus
    if state.sect.cultivation_paths_enabled:
        power += cultivation_path_system.intrinsic_combat_bonus(state, disciple)
    if state.sect.disciple_traits_enabled:
        power += trait_system.combat_power_bonus(state, disciple)
    if state.sect.bloodlines_enabled:
        power += bloodline_system.combat_power_bonus(state, disciple)
    if state.sect.physiques_enabled:
        power += physique_system.combat_power_bonus(state, disciple)
    return power

func apply_action_modifiers(state: SimulationState, disciple: DiscipleState, scores: Dictionary) -> void:
    if not state.sect.cultivation_enabled:
        return
    var cultivate_score := 35.0 + (1.0 - clampf(disciple.risk_bias, 0.0, 1.0)) * 22.0 + clampf(disciple.survival_bias, 0.0, 1.0) * 8.0
    var breakthrough_score := -1.0e20
    match disciple.active_goal:
        GoalSystem.GOAL_GROWTH:
            cultivate_score += 25.0
        GoalSystem.GOAL_SECURITY:
            cultivate_score += 10.0
        GoalSystem.GOAL_GLORY:
            cultivate_score -= 8.0
        GoalSystem.GOAL_WEALTH:
            cultivate_score -= 10.0
    match disciple.cultivation_directive:
        DIRECTIVE_CULTIVATE:
            cultivate_score += 45.0
            scores["HUNT"] = float(scores.get("HUNT", 0.0)) - 15.0
        DIRECTIVE_FIELD:
            cultivate_score -= 30.0
            scores["HUNT"] = float(scores.get("HUNT", 0.0)) + 35.0
        _:
            pass
    if is_max_stage(disciple):
        cultivate_score = -1.0e20
    elif is_ready(disciple):
        cultivate_score = -1.0e20
        if can_breakthrough(state, disciple):
            breakthrough_score = 160.0
            if disciple.cultivation_directive == DIRECTIVE_CULTIVATE:
                breakthrough_score += 20.0
            elif disciple.cultivation_directive == DIRECTIVE_FIELD:
                breakthrough_score -= 85.0
    scores["CULTIVATE"] = cultivate_score
    scores["BREAKTHROUGH"] = breakthrough_score
    if state.sect.cultivation_paths_enabled:
        cultivation_path_system.apply_action_modifiers(state, disciple, scores)

func validate_invariants(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if not state.sect.cultivation_enabled:
        return errors
    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        if disciple.cultivation_stage_index < 0 or disciple.cultivation_stage_index >= STAGES.size():
            errors.append("%s has invalid cultivation stage index." % disciple.display_name)
            continue
        if disciple.cultivation_progress < -0.000001:
            errors.append("%s has negative cultivation progress." % disciple.display_name)
        var required := required_progress(disciple)
        if required > 0.0 and disciple.cultivation_progress > required + 0.000001:
            errors.append("%s cultivation progress exceeds the current stage threshold." % disciple.display_name)
        if disciple.breakthrough_failures < 0 or disciple.next_breakthrough_tick < 0:
            errors.append("%s has invalid breakthrough state." % disciple.display_name)
        if not VALID_DIRECTIVES.has(disciple.cultivation_directive):
            errors.append("%s has invalid cultivation directive." % disciple.display_name)
        var expected := stage_definition(disciple)
        if absf(disciple.cultivation_combat_bonus - float(expected.get("combat_bonus", 0.0))) > 0.000001:
            errors.append("%s cultivation combat bonus is inconsistent with stage." % disciple.display_name)
        if absf(disciple.cultivation_hp_bonus - float(expected.get("hp_bonus", 0.0))) > 0.000001:
            errors.append("%s cultivation HP bonus is inconsistent with stage." % disciple.display_name)
    return errors

func _normalize_disciple(disciple: DiscipleState) -> void:
    disciple.cultivation_stage_index = clampi(disciple.cultivation_stage_index, 0, STAGES.size() - 1)
    if not VALID_DIRECTIVES.has(disciple.cultivation_directive):
        disciple.cultivation_directive = DIRECTIVE_BALANCED
    _apply_stage_bonus(disciple)
    var required := required_progress(disciple)
    disciple.cultivation_progress = clampf(disciple.cultivation_progress, 0.0, required) if required > 0.0 else 0.0

func _apply_stage_bonus(disciple: DiscipleState) -> void:
    var definition := stage_definition(disciple)
    var new_combat_bonus := float(definition.get("combat_bonus", 0.0))
    var new_hp_bonus := float(definition.get("hp_bonus", 0.0))
    var hp_delta := new_hp_bonus - disciple.cultivation_hp_bonus
    disciple.cultivation_combat_bonus = new_combat_bonus
    disciple.cultivation_hp_bonus = new_hp_bonus
    if absf(hp_delta) > 0.000001:
        disciple.max_hp = maxf(1.0, disciple.max_hp + hp_delta)
        if hp_delta > 0.0:
            disciple.hp = minf(disciple.max_hp, disciple.hp + hp_delta * 0.5)
        else:
            disciple.hp = minf(disciple.hp, disciple.max_hp)
