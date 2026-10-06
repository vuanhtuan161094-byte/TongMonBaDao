class_name ProfessionModifierSystem
extends RefCounted

const GRADE_MIN := 1
const GRADE_MAX := 5

const PROFESSION_TALENT_IDS := {
    "forging": "forge_talent",
    "mining": "miner_instinct",
    "herbalism": "herbalist_affinity",
    "alchemy": "alchemy_talent",
    "logistics": "logistics_talent"
}

var character_modifiers := CharacterModifierSystem.new()

func grade_bonus(grade: int) -> float:
    return float(clampi(grade, 0, GRADE_MAX)) * 0.05

func roll_grade(rng: GameRng) -> int:
    var roll := rng.randf_range(0.0, 1.0)
    if roll < 0.50:
        return 1
    if roll < 0.80:
        return 2
    if roll < 0.93:
        return 3
    if roll < 0.99:
        return 4
    return 5

func profession_speed_factor(level: int) -> float:
    return 1.0 + float(maxi(level, 0)) * 0.01

func comprehension_xp_factor(disciple: DiscipleState) -> float:
    return character_modifiers.foundation_channel_factor(disciple, CharacterModifierSystem.CHANNEL_PROFESSION_XP)

func fortune_factor(disciple: DiscipleState) -> float:
    return character_modifiers.foundation_channel_factor(disciple, CharacterModifierSystem.CHANNEL_RARE_CHANCE)

func profession_talent_id(profession_id: StringName) -> StringName:
    return StringName(PROFESSION_TALENT_IDS.get(str(profession_id), ""))

func profession_talent_grade(disciple: DiscipleState, profession_id: StringName) -> int:
    var talent_id := profession_talent_id(profession_id)
    if talent_id == &"" or not disciple.profession_traits.has(str(talent_id)):
        return 0
    return clampi(int(disciple.profession_trait_grades.get(str(talent_id), 1)), GRADE_MIN, GRADE_MAX)

func profession_talent_xp_factor(disciple: DiscipleState, profession_id: StringName) -> float:
    return 1.0 + grade_bonus(profession_talent_grade(disciple, profession_id))

func general_work_trait_factor(state: SimulationState, disciple: DiscipleState) -> float:
    return character_modifiers.trait_factor(state, disciple, CharacterModifierSystem.CHANNEL_WORK_SPEED)

func total_work_speed_factor(state: SimulationState, disciple: DiscipleState, profession_level: int) -> float:
    return maxf(profession_speed_factor(profession_level) * general_work_trait_factor(state, disciple), 0.25)

func profession_xp_factor(disciple: DiscipleState, profession_id: StringName) -> float:
    var comprehension_factor := comprehension_xp_factor(disciple)
    var talent_factor := profession_talent_xp_factor(disciple, profession_id)
    if disciple.foundation_model_version >= FoundationSystem.MODEL_OPEN_POINTS:
        return maxf(1.0 + (comprehension_factor - 1.0) + (talent_factor - 1.0), 0.05)
    return comprehension_factor * talent_factor

func total_profession_xp_factor(state: SimulationState, disciple: DiscipleState, profession_id: StringName) -> float:
    var base_factor := profession_xp_factor(disciple, profession_id)
    var trait_factor := character_modifiers.trait_factor(state, disciple, CharacterModifierSystem.CHANNEL_PROFESSION_XP)
    if disciple.foundation_model_version >= FoundationSystem.MODEL_OPEN_POINTS:
        return maxf(1.0 + (base_factor - 1.0) + (trait_factor - 1.0), 0.05)
    return base_factor * trait_factor

func rare_event_factor(state: SimulationState, disciple: DiscipleState) -> float:
    return fortune_factor(disciple) * character_modifiers.trait_factor(state, disciple, CharacterModifierSystem.CHANNEL_RARE_CHANCE)

func raw_work_cultivation_ratio_per_hour(profession_level: int) -> float:
    return 0.0005 * (1.0 + 0.0005 * float(maxi(profession_level, 0)))
