class_name FoundationSystem
extends RefCounted

const MODEL_LEGACY_NORMALIZED := 1
const MODEL_OPEN_POINTS := 2

const DIM_APTITUDE := &"aptitude"
const DIM_CONSTITUTION := &"constitution"
const DIM_FORTUNE := &"fortune"
const DIM_COMPREHENSION := &"comprehension"
const DIM_CHARISMA := &"charisma"
const DIM_POTENTIAL := &"potential"
const DIMENSIONS := [
    DIM_APTITUDE,
    DIM_CONSTITUTION,
    DIM_FORTUNE,
    DIM_COMPREHENSION,
    DIM_CHARISMA,
    DIM_POTENTIAL
]

# P3.7C1 starting balance. These are tuning constants, never hard caps.
const APTITUDE_PERCENT_PER_POINT := 0.0025
const CONSTITUTION_PERCENT_PER_POINT := 0.0020
const COMPREHENSION_PERCENT_PER_POINT := 0.0015
const POTENTIAL_PERCENT_PER_POINT := 0.0005

const QUALITY_OUTSTANDING_TOTAL := 360.0
const QUALITY_PRODIGY_TOTAL := 600.0
const QUALITY_PEERLESS_TOTAL := 1000.0
const QUALITY_HEAVEN_TOTAL := 1800.0

const LUCK_TIER_NORMAL := &"normal"
const LUCK_TIER_GOOD := &"good"
const LUCK_TIER_RARE := &"rare"
const LUCK_TIER_VERY_RARE := &"very_rare"
const LUCK_TIER_GREAT_FORTUNE := &"great_fortune"

func cultivation_gain_factor(aptitude_points: float) -> float:
    return 1.0 + maxf(aptitude_points, 0.0) * APTITUDE_PERCENT_PER_POINT

func body_training_gain_factor(constitution_points: float) -> float:
    return 1.0 + maxf(constitution_points, 0.0) * CONSTITUTION_PERCENT_PER_POINT

func learning_gain_factor(comprehension_points: float) -> float:
    return 1.0 + maxf(comprehension_points, 0.0) * COMPREHENSION_PERCENT_PER_POINT

func potential_growth_factor(potential_points: float) -> float:
    return 1.0 + maxf(potential_points, 0.0) * POTENTIAL_PERCENT_PER_POINT

func legacy_bridge_factor(points: float) -> float:
    # Compatibility only for old percentage-based consumers not yet migrated
    # to a meaningful Fortune/Social check. Large open-point values cannot
    # explode those locked subsystems.
    return 0.75 + 0.50 * clampf(maxf(points, 0.0) / 100.0, 0.0, 1.0)

func luck_score(fortune_points: float, difficulty: float, random_0_to_9999: int) -> float:
    return float(clampi(random_0_to_9999, 0, 9999)) + maxf(fortune_points, 0.0) - maxf(difficulty, 0.0)

func luck_tier_for_score(score: float) -> StringName:
    if score >= 9900.0:
        return LUCK_TIER_GREAT_FORTUNE
    if score >= 9500.0:
        return LUCK_TIER_VERY_RARE
    if score >= 8500.0:
        return LUCK_TIER_RARE
    if score >= 6000.0:
        return LUCK_TIER_GOOD
    return LUCK_TIER_NORMAL

func social_score(charisma_points: float, resistance: float, random_0_to_9999: int) -> float:
    return float(clampi(random_0_to_9999, 0, 9999)) + maxf(charisma_points, 0.0) - maxf(resistance, 0.0)

func total_values(aptitude: float, constitution: float, fortune: float, comprehension: float, charisma: float, potential: float) -> float:
    return maxf(aptitude, 0.0) + maxf(constitution, 0.0) + maxf(fortune, 0.0) + maxf(comprehension, 0.0) + maxf(charisma, 0.0) + maxf(potential, 0.0)

func total_candidate(candidate: CandidateState) -> float:
    return total_values(candidate.aptitude, candidate.constitution, candidate.fortune, candidate.comprehension, candidate.charisma, candidate.potential)

func total_disciple(disciple: DiscipleState) -> float:
    return total_values(disciple.aptitude, disciple.constitution, disciple.fortune, disciple.comprehension, disciple.charisma, disciple.potential)

func quality_for_total(total: float) -> StringName:
    if total >= QUALITY_HEAVEN_TOTAL:
        return DiscipleGeneratorV2.QUALITY_HEAVEN_DEFYING
    if total >= QUALITY_PEERLESS_TOTAL:
        return DiscipleGeneratorV2.QUALITY_PEERLESS
    if total >= QUALITY_PRODIGY_TOTAL:
        return DiscipleGeneratorV2.QUALITY_PRODIGY
    if total >= QUALITY_OUTSTANDING_TOTAL:
        return DiscipleGeneratorV2.QUALITY_OUTSTANDING
    return DiscipleGeneratorV2.QUALITY_COMMON

func recompute_candidate_quality(candidate: CandidateState) -> StringName:
    candidate.disciple_quality = quality_for_total(total_candidate(candidate))
    return candidate.disciple_quality

func recompute_disciple_quality(disciple: DiscipleState) -> StringName:
    disciple.disciple_quality = quality_for_total(total_disciple(disciple))
    return disciple.disciple_quality

# Low-level permanent foundation mutation, NOT a source of free points.
# Player-facing growth must pay through DiscipleFoundationGrowthV2.
# Preserve birth snapshot and live HP ratio when Potential changes V2 core.
func add_permanent_points(disciple: DiscipleState, dimension: StringName, amount: float) -> bool:
    if disciple == null or disciple.foundation_model_version < MODEL_OPEN_POINTS or not DIMENSIONS.has(dimension):
        return false
    if is_nan(amount) or is_inf(amount) or amount <= 0.0:
        return false
    var current := float(disciple.get(str(dimension)))
    var increased := current + amount
    if is_nan(current) or is_inf(current) or current < 0.0 or is_nan(increased) or is_inf(increased):
        return false
    var original_quality := disciple.disciple_quality
    var old_hp := disciple.hp
    var old_max_hp := disciple.max_hp
    disciple.set(str(dimension), increased)
    recompute_disciple_quality(disciple)
    if dimension == DIM_POTENTIAL and DiscipleRealmProgressV2.owns_v2_progression(disciple):
        var sync := DiscipleRealmProgressV2.sync_live_hp(disciple)
        if not bool(sync.get("ok",false)):
            disciple.set(str(dimension), current)
            disciple.disciple_quality = original_quality
            disciple.hp = old_hp
            disciple.max_hp = old_max_hp
            return false
    return true

func birth_total(values: Dictionary) -> float:
    var total := 0.0
    for dimension in DIMENSIONS:
        total += maxf(float(values.get(str(dimension), 0.0)), 0.0)
    return total

func enable_open_points(state: SimulationState) -> void:
    state.sect.foundation_points_enabled = true
    var disciple_ids: Array = state.disciples.keys()
    disciple_ids.sort()
    for raw_id in disciple_ids:
        _migrate_disciple(state, state.disciples[raw_id])
    var candidate_ids: Array = state.recruitment_candidates.keys()
    candidate_ids.sort()
    for raw_id in candidate_ids:
        _migrate_candidate(state, state.recruitment_candidates[raw_id])

func validate_candidate(candidate: CandidateState) -> Array[String]:
    var errors: Array[String] = []
    if candidate.profile_seed <= 0:
        errors.append("Open-point candidate has invalid profile seed.")
    if candidate.foundation_model_version < MODEL_OPEN_POINTS:
        errors.append("Open-point candidate has the wrong foundation model.")
    for value in _candidate_values(candidate):
        if is_nan(value) or is_inf(value) or value < 0.0:
            errors.append("Open-point candidate has an invalid or nonfinite foundation value.")
            break
    if candidate.foundation_birth_values.is_empty() or birth_total(candidate.foundation_birth_values) <= 0.0:
        errors.append("Open-point candidate has no birth-foundation snapshot.")
    if candidate.disciple_quality != quality_for_total(total_candidate(candidate)):
        errors.append("Open-point candidate quality is inconsistent with total lục duy.")
    if candidate.spiritual_root_elements.is_empty():
        errors.append("Open-point candidate has no spiritual-root elements.")
    if candidate.age < 12 or candidate.base_lifespan <= candidate.age or candidate.max_lifespan < candidate.base_lifespan:
        errors.append("Open-point candidate has invalid lifespan schema.")
    if candidate.latent_identity_seed <= 0:
        errors.append("Open-point candidate has invalid latent identity seed.")
    return errors

func validate_disciple(disciple: DiscipleState) -> Array[String]:
    var errors: Array[String] = []
    if disciple.foundation_model_version < MODEL_OPEN_POINTS:
        return errors
    for value in _disciple_values(disciple):
        if is_nan(value) or is_inf(value) or value < 0.0:
            errors.append("%s has an invalid or nonfinite foundation value." % disciple.display_name)
            break
    if disciple.foundation_birth_values.is_empty() or birth_total(disciple.foundation_birth_values) <= 0.0:
        errors.append("%s has no birth-foundation snapshot." % disciple.display_name)
    if disciple.disciple_quality != quality_for_total(total_disciple(disciple)):
        errors.append("%s quality is inconsistent with total lục duy." % disciple.display_name)
    return errors

func _migrate_disciple(state: SimulationState, disciple: DiscipleState) -> void:
    if disciple.foundation_model_version >= MODEL_OPEN_POINTS:
        if disciple.foundation_birth_values.is_empty():
            disciple.foundation_birth_values = _birth_dict_from_disciple(disciple)
        recompute_disciple_quality(disciple)
        return
    var rng := GameRng.new(_migration_seed(state.seed, str(disciple.id), 7301))
    disciple.aptitude = _legacy_to_points(disciple.aptitude, rng)
    disciple.constitution = _legacy_to_points(disciple.constitution, rng)
    disciple.fortune = _legacy_to_points(disciple.fortune, rng)
    disciple.comprehension = _legacy_to_points(disciple.comprehension, rng)
    disciple.charisma = _legacy_to_points(disciple.charisma, rng)
    disciple.potential = _legacy_to_points(disciple.potential, rng)
    disciple.foundation_model_version = MODEL_OPEN_POINTS
    disciple.foundation_birth_values = _birth_dict_from_disciple(disciple)
    recompute_disciple_quality(disciple)

func _migrate_candidate(state: SimulationState, candidate: CandidateState) -> void:
    if candidate.foundation_model_version >= MODEL_OPEN_POINTS:
        if candidate.foundation_birth_values.is_empty():
            candidate.foundation_birth_values = _birth_dict_from_candidate(candidate)
        recompute_candidate_quality(candidate)
        return
    var rng := GameRng.new(_migration_seed(state.seed, str(candidate.id), 9109))
    candidate.aptitude = _legacy_to_points(candidate.aptitude, rng)
    candidate.constitution = _legacy_to_points(candidate.constitution, rng)
    candidate.fortune = _legacy_to_points(candidate.fortune, rng)
    candidate.comprehension = _legacy_to_points(candidate.comprehension, rng)
    candidate.charisma = _legacy_to_points(candidate.charisma, rng)
    candidate.potential = _legacy_to_points(candidate.potential, rng)
    candidate.foundation_model_version = MODEL_OPEN_POINTS
    candidate.foundation_birth_values = _birth_dict_from_candidate(candidate)
    recompute_candidate_quality(candidate)

func _legacy_to_points(value: float, rng: GameRng) -> float:
    if value > 1.5:
        return value
    if value > 0.0:
        return float(maxi(int(round(value * 100.0)), 1))
    # Some locked pre-P2.8 disciples never had all six fields. Migration fills
    # only missing history deterministically; fresh open-point people use the
    # strict total-budget generator.
    return float(rng.randi_range(25, 75))

func _birth_dict_from_disciple(disciple: DiscipleState) -> Dictionary:
    return {
        "aptitude": disciple.aptitude,
        "constitution": disciple.constitution,
        "fortune": disciple.fortune,
        "comprehension": disciple.comprehension,
        "charisma": disciple.charisma,
        "potential": disciple.potential
    }

func _birth_dict_from_candidate(candidate: CandidateState) -> Dictionary:
    return {
        "aptitude": candidate.aptitude,
        "constitution": candidate.constitution,
        "fortune": candidate.fortune,
        "comprehension": candidate.comprehension,
        "charisma": candidate.charisma,
        "potential": candidate.potential
    }

func _candidate_values(candidate: CandidateState) -> Array:
    return [candidate.aptitude, candidate.constitution, candidate.fortune, candidate.comprehension, candidate.charisma, candidate.potential]

func _disciple_values(disciple: DiscipleState) -> Array:
    return [disciple.aptitude, disciple.constitution, disciple.fortune, disciple.comprehension, disciple.charisma, disciple.potential]

func _migration_seed(base_seed: int, identity: String, salt: int) -> int:
    var value := int((base_seed + salt) % 2147483629)
    for index in range(identity.length()):
        value = int((value * 131 + identity.unicode_at(index)) % 2147483629)
    return value if value > 0 else value + 2147483629
