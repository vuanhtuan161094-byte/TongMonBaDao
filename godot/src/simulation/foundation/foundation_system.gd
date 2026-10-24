class_name FoundationSystem
extends RefCounted

const MODEL_LEGACY_NORMALIZED := 1
const MODEL_OPEN_POINTS := 2
const MODEL_D7 := 3

const DIM_APTITUDE := &"aptitude"
const DIM_CONSTITUTION := &"constitution"
const DIM_MIND_NATURE := &"mind_nature"
const DIM_POTENTIAL := &"potential"
const DIM_COMPREHENSION := &"comprehension"
const DIM_FORTUNE := &"fortune"
const DIM_CHARISMA := &"charisma"
const LEGACY_DIMENSIONS := [DIM_APTITUDE,DIM_CONSTITUTION,DIM_FORTUNE,DIM_COMPREHENSION,DIM_CHARISMA,DIM_POTENTIAL]
const TAM_CAN_DIMENSIONS := [DIM_APTITUDE,DIM_CONSTITUTION,DIM_MIND_NATURE]
const TU_TINH_DIMENSIONS := [DIM_POTENTIAL,DIM_COMPREHENSION,DIM_FORTUNE,DIM_CHARISMA]
const DIMENSIONS := [DIM_APTITUDE,DIM_CONSTITUTION,DIM_MIND_NATURE,DIM_POTENTIAL,DIM_COMPREHENSION,DIM_FORTUNE,DIM_CHARISMA]

# P3.7C1 / D7 point effects. Tâm Tính has no runtime consumer yet by design.
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
	return 0.75 + 0.50 * clampf(maxf(points, 0.0) / 100.0, 0.0, 1.0)

func luck_score(fortune_points: float, difficulty: float, random_0_to_9999: int) -> float:
	return float(clampi(random_0_to_9999, 0, 9999)) + maxf(fortune_points, 0.0) - maxf(difficulty, 0.0)

func luck_tier_for_score(score: float) -> StringName:
	if score >= 9900.0: return LUCK_TIER_GREAT_FORTUNE
	if score >= 9500.0: return LUCK_TIER_VERY_RARE
	if score >= 8500.0: return LUCK_TIER_RARE
	if score >= 6000.0: return LUCK_TIER_GOOD
	return LUCK_TIER_NORMAL

func social_score(charisma_points: float, resistance: float, random_0_to_9999: int) -> float:
	return float(clampi(random_0_to_9999, 0, 9999)) + maxf(charisma_points, 0.0) - maxf(resistance, 0.0)

func total_values(aptitude: float, constitution: float, fortune: float, comprehension: float, charisma: float, potential: float) -> float:
	return maxf(aptitude, 0.0) + maxf(constitution, 0.0) + maxf(fortune, 0.0) + maxf(comprehension, 0.0) + maxf(charisma, 0.0) + maxf(potential, 0.0)

func total_candidate(candidate: CandidateState) -> float:
	if candidate.foundation_model_version >= MODEL_D7:
		return _quality_total(_candidate_values_d7(candidate),candidate.foundation_birth_values)
	return total_values(candidate.aptitude,candidate.constitution,candidate.fortune,candidate.comprehension,candidate.charisma,candidate.potential)

func total_disciple(disciple: DiscipleState) -> float:
	if disciple.foundation_model_version >= MODEL_D7:
		return _quality_total(_disciple_values_d7(disciple),disciple.foundation_birth_values)
	return total_values(disciple.aptitude,disciple.constitution,disciple.fortune,disciple.comprehension,disciple.charisma,disciple.potential)

func quality_for_total(total: float) -> StringName:
	if total >= QUALITY_HEAVEN_TOTAL: return DiscipleGeneratorV2.QUALITY_HEAVEN_DEFYING
	if total >= QUALITY_PEERLESS_TOTAL: return DiscipleGeneratorV2.QUALITY_PEERLESS
	if total >= QUALITY_PRODIGY_TOTAL: return DiscipleGeneratorV2.QUALITY_PRODIGY
	if total >= QUALITY_OUTSTANDING_TOTAL: return DiscipleGeneratorV2.QUALITY_OUTSTANDING
	return DiscipleGeneratorV2.QUALITY_COMMON

func recompute_candidate_quality(candidate: CandidateState) -> StringName:
	candidate.disciple_quality = quality_for_total(total_candidate(candidate))
	return candidate.disciple_quality

func recompute_disciple_quality(disciple: DiscipleState) -> StringName:
	disciple.disciple_quality = quality_for_total(total_disciple(disciple))
	return disciple.disciple_quality

func add_permanent_points(disciple: DiscipleState, dimension: StringName, amount: float) -> bool:
	if disciple == null or disciple.foundation_model_version < MODEL_OPEN_POINTS or amount <= 0.0 or not DIMENSIONS.has(dimension):
		return false
	if dimension == DIM_MIND_NATURE and disciple.foundation_model_version < MODEL_D7:
		return false
	match dimension:
		DIM_APTITUDE: disciple.aptitude += amount
		DIM_CONSTITUTION: disciple.constitution += amount
		DIM_MIND_NATURE: disciple.mind_nature += amount
		DIM_POTENTIAL: disciple.potential += amount
		DIM_COMPREHENSION: disciple.comprehension += amount
		DIM_FORTUNE: disciple.fortune += amount
		DIM_CHARISMA: disciple.charisma += amount
	recompute_disciple_quality(disciple)
	return true

# Returns the stored point sum (six dimensions for old saves, seven for D7).
func birth_total(values: Dictionary) -> float:
	var dimensions: Array = DIMENSIONS if values.has("mind_nature") else LEGACY_DIMENSIONS
	var total := 0.0
	for dimension in dimensions:
		total += maxf(float(values.get(str(dimension),0.0)),0.0)
	return total

# Atomic in-memory migration used by SaveService. D7 is not guessed when the
# old save lacks birth provenance; callers must refuse that save.
func enable_d7(state: SimulationState) -> bool:
	if state == null:
		return false
	var disciples: Array = state.disciples.keys()
	disciples.sort()
	for raw_id in disciples:
		var disciple: DiscipleState = state.disciples[raw_id]
		if not _can_migrate_disciple_to_d7(disciple): return false
	var candidates: Array = state.recruitment_candidates.keys()
	candidates.sort()
	for raw_id in candidates:
		var candidate: CandidateState = state.recruitment_candidates[raw_id]
		if not _can_migrate_candidate_to_d7(candidate): return false
	for raw_id in disciples:
		if not _migrate_disciple_to_d7(state.disciples[raw_id]): return false
	for raw_id in candidates:
		if not _migrate_candidate_to_d7(state.recruitment_candidates[raw_id]): return false
	state.sect.foundation_points_enabled = true
	return true

func enable_open_points(state: SimulationState) -> void:
	state.sect.foundation_points_enabled = true
	var disciple_ids: Array = state.disciples.keys()
	disciple_ids.sort()
	for raw_id in disciple_ids:
		_migrate_disciple(state,state.disciples[raw_id])
	var candidate_ids: Array = state.recruitment_candidates.keys()
	candidate_ids.sort()
	for raw_id in candidate_ids:
		_migrate_candidate(state,state.recruitment_candidates[raw_id])

func validate_candidate(candidate: CandidateState) -> Array[String]:
	var errors: Array[String] = []
	if candidate.profile_seed <= 0: errors.append("Open-point candidate has invalid profile seed.")
	if candidate.foundation_model_version < MODEL_OPEN_POINTS: errors.append("Open-point candidate has the wrong foundation model.")
	for value in _candidate_values_for_model(candidate):
		if not _valid_point(value):
			errors.append("Open-point candidate has an invalid foundation value.")
			break
	if not _has_complete_birth(candidate.foundation_birth_values,candidate.foundation_model_version):
		errors.append("Open-point candidate has no complete birth-foundation snapshot.")
	if candidate.disciple_quality != quality_for_total(total_candidate(candidate)):
		errors.append("Open-point candidate quality is inconsistent with its foundation values.")
	if candidate.spiritual_root_elements.is_empty(): errors.append("Open-point candidate has no spiritual-root elements.")
	if candidate.age < 12 or candidate.base_lifespan <= candidate.age or candidate.max_lifespan < candidate.base_lifespan:
		errors.append("Open-point candidate has invalid lifespan schema.")
	if candidate.latent_identity_seed <= 0: errors.append("Open-point candidate has invalid latent identity seed.")
	return errors

func validate_disciple(disciple: DiscipleState) -> Array[String]:
	var errors: Array[String] = []
	if disciple.foundation_model_version < MODEL_OPEN_POINTS: return errors
	for value in _disciple_values_for_model(disciple):
		if not _valid_point(value):
			errors.append("%s has an invalid foundation value." % disciple.display_name)
			break
	if not _has_complete_birth(disciple.foundation_birth_values,disciple.foundation_model_version):
		errors.append("%s has no complete birth-foundation snapshot." % disciple.display_name)
	if disciple.disciple_quality != quality_for_total(total_disciple(disciple)):
		errors.append("%s quality is inconsistent with foundation values." % disciple.display_name)
	return errors

func _migrate_disciple_to_d7(disciple: DiscipleState) -> bool:
	if disciple.foundation_model_version == MODEL_LEGACY_NORMALIZED and disciple.profile_seed <= 0:
		return true # Unprofiled P2 residents retain their legacy six-stat model.
	if disciple.foundation_model_version == MODEL_D7:
		return _has_complete_birth(disciple.foundation_birth_values,MODEL_D7) and disciple.disciple_quality == quality_for_total(total_disciple(disciple)) and _all_valid(_disciple_values_d7(disciple))
	if disciple.foundation_model_version != MODEL_OPEN_POINTS or not _has_complete_birth(disciple.foundation_birth_values,MODEL_OPEN_POINTS):
		return false
	var old_quality := disciple.disciple_quality
	disciple.mind_nature = _mean_six_birth(disciple.foundation_birth_values)
	disciple.foundation_birth_values["mind_nature"] = disciple.mind_nature
	disciple.foundation_model_version = MODEL_D7
	recompute_disciple_quality(disciple)
	return disciple.disciple_quality == old_quality

func _migrate_candidate_to_d7(candidate: CandidateState) -> bool:
	if candidate.foundation_model_version == MODEL_LEGACY_NORMALIZED and candidate.profile_seed <= 0:
		return true # Legacy pending residents are not assigned invented birth data.
	if candidate.foundation_model_version == MODEL_D7:
		return _has_complete_birth(candidate.foundation_birth_values,MODEL_D7) and candidate.disciple_quality == quality_for_total(total_candidate(candidate)) and _all_valid(_candidate_values_d7(candidate))
	if candidate.foundation_model_version != MODEL_OPEN_POINTS or not _has_complete_birth(candidate.foundation_birth_values,MODEL_OPEN_POINTS):
		return false
	var old_quality := candidate.disciple_quality
	candidate.mind_nature = _mean_six_birth(candidate.foundation_birth_values)
	candidate.foundation_birth_values["mind_nature"] = candidate.mind_nature
	candidate.foundation_model_version = MODEL_D7
	recompute_candidate_quality(candidate)
	return candidate.disciple_quality == old_quality

func _can_migrate_disciple_to_d7(disciple: DiscipleState) -> bool:
	if disciple.foundation_model_version == MODEL_LEGACY_NORMALIZED and disciple.profile_seed <= 0: return true
	if disciple.foundation_model_version == MODEL_D7:
		return _has_complete_birth(disciple.foundation_birth_values,MODEL_D7) and _all_valid(_disciple_values_d7(disciple)) and disciple.disciple_quality == quality_for_total(total_disciple(disciple))
	return disciple.foundation_model_version == MODEL_OPEN_POINTS and _has_complete_birth(disciple.foundation_birth_values,MODEL_OPEN_POINTS) and _all_valid(_disciple_values_for_model(disciple)) and disciple.disciple_quality == quality_for_total(total_disciple(disciple))

func _can_migrate_candidate_to_d7(candidate: CandidateState) -> bool:
	if candidate.foundation_model_version == MODEL_LEGACY_NORMALIZED and candidate.profile_seed <= 0: return true
	if candidate.foundation_model_version == MODEL_D7:
		return _has_complete_birth(candidate.foundation_birth_values,MODEL_D7) and _all_valid(_candidate_values_d7(candidate)) and candidate.disciple_quality == quality_for_total(total_candidate(candidate))
	return candidate.foundation_model_version == MODEL_OPEN_POINTS and _has_complete_birth(candidate.foundation_birth_values,MODEL_OPEN_POINTS) and _all_valid(_candidate_values_for_model(candidate)) and candidate.disciple_quality == quality_for_total(total_candidate(candidate))

func _migrate_disciple(state: SimulationState, disciple: DiscipleState) -> void:
	if disciple.foundation_model_version >= MODEL_OPEN_POINTS:
		if disciple.foundation_birth_values.is_empty(): disciple.foundation_birth_values = _birth_dict_from_disciple(disciple)
		recompute_disciple_quality(disciple)
		return
	var rng := GameRng.new(_migration_seed(state.seed,str(disciple.id),7301))
	disciple.aptitude = _legacy_to_points(disciple.aptitude,rng)
	disciple.constitution = _legacy_to_points(disciple.constitution,rng)
	disciple.fortune = _legacy_to_points(disciple.fortune,rng)
	disciple.comprehension = _legacy_to_points(disciple.comprehension,rng)
	disciple.charisma = _legacy_to_points(disciple.charisma,rng)
	disciple.potential = _legacy_to_points(disciple.potential,rng)
	disciple.foundation_model_version = MODEL_OPEN_POINTS
	disciple.foundation_birth_values = _birth_dict_from_disciple(disciple)
	recompute_disciple_quality(disciple)

func _migrate_candidate(state: SimulationState, candidate: CandidateState) -> void:
	if candidate.foundation_model_version >= MODEL_OPEN_POINTS:
		if candidate.foundation_birth_values.is_empty(): candidate.foundation_birth_values = _birth_dict_from_candidate(candidate)
		recompute_candidate_quality(candidate)
		return
	var rng := GameRng.new(_migration_seed(state.seed,str(candidate.id),9109))
	candidate.aptitude = _legacy_to_points(candidate.aptitude,rng)
	candidate.constitution = _legacy_to_points(candidate.constitution,rng)
	candidate.fortune = _legacy_to_points(candidate.fortune,rng)
	candidate.comprehension = _legacy_to_points(candidate.comprehension,rng)
	candidate.charisma = _legacy_to_points(candidate.charisma,rng)
	candidate.potential = _legacy_to_points(candidate.potential,rng)
	candidate.foundation_model_version = MODEL_OPEN_POINTS
	candidate.foundation_birth_values = _birth_dict_from_candidate(candidate)
	recompute_candidate_quality(candidate)

func _quality_total(values: Array, birth: Dictionary) -> float:
	if values.size() != DIMENSIONS.size() or not _has_complete_birth(birth,MODEL_D7):
		return NAN
	var birth_sum := birth_total(birth)
	var delta := 0.0
	for index in range(DIMENSIONS.size()):
		delta += float(values[index])-float(birth[str(DIMENSIONS[index])])
	return birth_sum*(6.0/7.0)+delta

func _mean_six_birth(birth: Dictionary) -> float:
	var total := 0.0
	for key in LEGACY_DIMENSIONS: total += float(birth[str(key)])
	return total/6.0

func _has_complete_birth(values: Dictionary, model: int) -> bool:
	var dimensions: Array = DIMENSIONS if model >= MODEL_D7 else LEGACY_DIMENSIONS
	for key in dimensions:
		if not values.has(str(key)) or not _valid_point(float(values[str(key)])):
			return false
	return true

func _valid_point(value: float) -> bool:
	return not is_nan(value) and not is_inf(value) and value >= 0.0

func _all_valid(values: Array) -> bool:
	for value in values:
		if not _valid_point(float(value)): return false
	return true

func _legacy_to_points(value: float, rng: GameRng) -> float:
	if value > 1.5: return value
	if value > 0.0: return float(maxi(int(round(value*100.0)),1))
	return float(rng.randi_range(25,75))

func _birth_dict_from_disciple(disciple: DiscipleState) -> Dictionary:
	return {"aptitude":disciple.aptitude,"constitution":disciple.constitution,"fortune":disciple.fortune,"comprehension":disciple.comprehension,"charisma":disciple.charisma,"potential":disciple.potential}

func _birth_dict_from_candidate(candidate: CandidateState) -> Dictionary:
	return {"aptitude":candidate.aptitude,"constitution":candidate.constitution,"fortune":candidate.fortune,"comprehension":candidate.comprehension,"charisma":candidate.charisma,"potential":candidate.potential}

func _candidate_values_for_model(candidate: CandidateState) -> Array:
	return _candidate_values_d7(candidate) if candidate.foundation_model_version >= MODEL_D7 else [candidate.aptitude,candidate.constitution,candidate.fortune,candidate.comprehension,candidate.charisma,candidate.potential]

func _disciple_values_for_model(disciple: DiscipleState) -> Array:
	return _disciple_values_d7(disciple) if disciple.foundation_model_version >= MODEL_D7 else [disciple.aptitude,disciple.constitution,disciple.fortune,disciple.comprehension,disciple.charisma,disciple.potential]

func _candidate_values_d7(candidate: CandidateState) -> Array:
	return [candidate.aptitude,candidate.constitution,candidate.mind_nature,candidate.potential,candidate.comprehension,candidate.fortune,candidate.charisma]

func _disciple_values_d7(disciple: DiscipleState) -> Array:
	return [disciple.aptitude,disciple.constitution,disciple.mind_nature,disciple.potential,disciple.comprehension,disciple.fortune,disciple.charisma]

func _migration_seed(base_seed: int, identity: String, salt: int) -> int:
	var value := int((base_seed+salt)%2147483629)
	for index in range(identity.length()): value = int((value*131+identity.unicode_at(index))%2147483629)
	return value if value > 0 else value+2147483629
