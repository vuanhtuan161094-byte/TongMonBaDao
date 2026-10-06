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
    return 0.75 + 0.50 * clampf(disciple.comprehension, 0.0, 1.0)

func stamina_cost_factor(disciple: DiscipleState) -> float:
    return 1.0 - 0.25 * clampf(disciple.constitution, 0.0, 1.0)

func fortune_factor(disciple: DiscipleState) -> float:
    return 1.0 + 2.0 * clampf(disciple.fortune, 0.0, 1.0)

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
    if state.sect.disciple_traits_enabled:
        var active := TraitSystem.new().active_trait_ids(state, disciple)
        if active.has(str(TraitSystem.TRAIT_DILIGENT_WORKER)):
            return 1.0 + grade_bonus(_general_trait_grade(state, disciple.id, TraitSystem.TRAIT_DILIGENT_WORKER))
        if active.has(str(TraitSystem.TRAIT_CARELESS_WORKER)):
            return 1.0 - grade_bonus(_general_trait_grade(state, disciple.id, TraitSystem.TRAIT_CARELESS_WORKER))

    # Backward-compatible bridge for P2.7 ungraded temperament traits.
    if disciple.profession_traits.has("diligent"):
        return 1.05
    if disciple.profession_traits.has("lazy"):
        return 0.95
    return 1.0

func total_work_speed_factor(state: SimulationState, disciple: DiscipleState, profession_level: int) -> float:
    return maxf(profession_speed_factor(profession_level) * general_work_trait_factor(state, disciple), 0.25)

func profession_xp_factor(disciple: DiscipleState, profession_id: StringName) -> float:
    return comprehension_xp_factor(disciple) * profession_talent_xp_factor(disciple, profession_id)

func raw_work_cultivation_ratio_per_hour(profession_level: int) -> float:
    return 0.0005 * (1.0 + 0.0005 * float(maxi(profession_level, 0)))

func _general_trait_grade(state: SimulationState, disciple_id: StringName, trait_id: StringName) -> int:
    var profile = state.sect.disciple_trait_profiles.get(str(disciple_id), {})
    if not (profile is Dictionary):
        return 1
    var grades = profile.get("grades", {})
    if not (grades is Dictionary):
        return 1
    return clampi(int(grades.get(str(trait_id), 1)), GRADE_MIN, GRADE_MAX)
