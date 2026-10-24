class_name DiscipleGeneratorV2
extends RefCounted

const SOURCE_ORDINARY := &"ordinary"
const SOURCE_GACHA := &"gacha"
const SOURCE_FATE := &"fate"
const VALID_SOURCES := [SOURCE_ORDINARY, SOURCE_GACHA, SOURCE_FATE]

const QUALITY_COMMON := &"common"
const QUALITY_OUTSTANDING := &"outstanding"
const QUALITY_PRODIGY := &"prodigy"
const QUALITY_PEERLESS := &"peerless"
const QUALITY_HEAVEN_DEFYING := &"heaven_defying"
const VALID_QUALITIES := [QUALITY_COMMON, QUALITY_OUTSTANDING, QUALITY_PRODIGY, QUALITY_PEERLESS, QUALITY_HEAVEN_DEFYING]

const QUALITY_NAMES := {
    "common": "Phàm Thường",
    "outstanding": "Xuất Chúng",
    "prodigy": "Thiên Kiêu",
    "peerless": "Tuyệt Luân",
    "heaven_defying": "Nghịch Thiên"
}

const RACE_HUMAN := &"human"
const SEX_MALE := &"male"
const SEX_FEMALE := &"female"

const ORIGINS := ["commoner", "merchant_family", "martial_family", "wanderer", "mountain_village", "minor_clan"]
const SURNAMES := ["Lâm", "Trần", "Bạch", "Cố", "Triệu", "Tần", "Mạc", "Tô", "Lý", "Vương", "Đỗ", "Hạ"]
const GIVEN_NAMES := ["An", "Minh", "Phong", "Nguyệt", "Vũ", "Thanh", "Nhi", "Mặc", "Huyền", "Linh", "Trúc", "Thiên"]

const ARCHETYPE_IDS := ["daring", "cautious", "balanced", "frugal_guarded", "reckless", "prudent"]
const ARCHETYPES := {
    "daring": {"risk":0.80, "spend":0.50, "survival":0.35},
    "cautious": {"risk":0.20, "spend":0.32, "survival":0.86},
    "balanced": {"risk":0.50, "spend":0.50, "survival":0.55},
    "frugal_guarded": {"risk":0.28, "spend":0.22, "survival":0.74},
    "reckless": {"risk":0.92, "spend":0.58, "survival":0.22},
    "prudent": {"risk":0.42, "spend":0.62, "survival":0.82}
}

const PROFESSION_TRAITS := ["forge_talent", "miner_instinct", "diligent", "lazy"]
const HASH_MODULUS := 2147483629
const PROFILE_OFFSET := 82811
const PROFILE_MULTIPLIER := 104729

func generate_candidate(state: SimulationState, source: StringName, generation_index: int) -> CandidateState:
    if not VALID_SOURCES.has(source) or generation_index <= 0:
        return null

    var profile_seed := _profile_seed(state.seed, source, generation_index)
    var rng := GameRng.new(profile_seed)
    var surname := str(SURNAMES[rng.randi_range(0, SURNAMES.size() - 1)])
    var given_name := str(GIVEN_NAMES[rng.randi_range(0, GIVEN_NAMES.size() - 1)])
    var archetype_id := str(ARCHETYPE_IDS[rng.randi_range(0, ARCHETYPE_IDS.size() - 1)])
    var archetype: Dictionary = ARCHETYPES[archetype_id]

    var aptitude := _roll_dimension(rng, source)
    var constitution := _roll_dimension(rng, source)
    var fortune := _roll_dimension(rng, source)
    var comprehension := _roll_dimension(rng, source)
    var charisma := _roll_dimension(rng, source)
    var potential := _roll_dimension(rng, source)

    if source == SOURCE_GACHA:
        var guaranteed_index := rng.randi_range(0, 5)
        var dimensions := [aptitude, constitution, fortune, comprehension, charisma, potential]
        dimensions[guaranteed_index] = maxf(float(dimensions[guaranteed_index]), 0.78)
        aptitude = float(dimensions[0])
        constitution = float(dimensions[1])
        fortune = float(dimensions[2])
        comprehension = float(dimensions[3])
        charisma = float(dimensions[4])
        potential = float(dimensions[5])
    elif source == SOURCE_FATE:
        fortune = maxf(fortune, 0.68)

    var quality := quality_for_foundation(aptitude, constitution, fortune, comprehension, charisma, potential)
    var root_purity := _roll_root_purity(rng, source)
    var root_elements := _roll_root_elements(rng, source)
    var root_quality := _legacy_root_quality(root_purity)
    var profession_traits := _roll_profession_traits(rng, source)

    var age := _roll_age(rng, source)
    var base_lifespan := int(round(88.0 + constitution * 26.0 + potential * 16.0))
    var max_lifespan := base_lifespan
    var stage_index := _roll_starting_stage(rng, source, aptitude, potential, age)
    var stage: Dictionary = CultivationSystem.STAGES[stage_index]
    var cultivation_bonus := float(stage.get("combat_bonus", 0.0))
    var hp_bonus := float(stage.get("hp_bonus", 0.0))
    var required := float(stage.get("required", 0.0))
    var cultivation_progress := 0.0
    if required > 0.0:
        cultivation_progress = required * rng.randf_range(0.0, 0.30)

    # Intrinsic power only. Realm power remains in P2.1 cultivation_combat_bonus.
    var intrinsic_power := 10.0 + constitution * 8.0 + potential * 5.0 + aptitude * 3.0
    var latent_seed := _stable_hash("latent:%d:%s:%d" % [state.seed, str(source), generation_index])

    return CandidateState.new({
        "id": "candidate_%04d" % generation_index,
        "name": "%s %s" % [surname, given_name],
        "combat_power": intrinsic_power,
        "risk_bias": clampf(float(archetype["risk"]) + rng.randf_range(-0.07, 0.07), 0.05, 0.95),
        "spend_bias": clampf(float(archetype["spend"]) + rng.randf_range(-0.07, 0.07), 0.05, 0.95),
        "survival_bias": clampf(float(archetype["survival"]) + rng.randf_range(-0.07, 0.07), 0.05, 0.95),
        "personality_id": archetype_id,
        "generated_index": generation_index,
        "profile_seed": profile_seed,
        "recruitment_source": str(source),
        "race_id": str(RACE_HUMAN),
        "sex_id": str(SEX_MALE if rng.randi_range(0, 1) == 0 else SEX_FEMALE),
        "origin_id": str(ORIGINS[rng.randi_range(0, ORIGINS.size() - 1)]),
        "aptitude": aptitude,
        "constitution": constitution,
        "fortune": fortune,
        "comprehension": comprehension,
        "charisma": charisma,
        "potential": potential,
        "disciple_quality": str(quality),
        "spiritual_root_quality": str(root_quality),
        "spiritual_root_purity": root_purity,
        "spiritual_root_elements": root_elements,
        "profession_traits": profession_traits,
        "age": age,
        "base_lifespan": base_lifespan,
        "max_lifespan": max_lifespan,
        "latent_identity_seed": latent_seed,
        "cultivation_stage_index": stage_index,
        "cultivation_progress": cultivation_progress,
        "cultivation_combat_bonus": cultivation_bonus,
        "cultivation_hp_bonus": hp_bonus
    })

func foundation_score_values(aptitude: float, constitution: float, fortune: float, comprehension: float, charisma: float, potential: float) -> float:
    return (aptitude + constitution + fortune + comprehension + charisma + potential) / 6.0 * 100.0

func quality_for_foundation(aptitude: float, constitution: float, fortune: float, comprehension: float, charisma: float, potential: float) -> StringName:
    var score := foundation_score_values(aptitude, constitution, fortune, comprehension, charisma, potential)
    if score >= 84.0:
        return QUALITY_HEAVEN_DEFYING
    if score >= 72.0:
        return QUALITY_PEERLESS
    if score >= 60.0:
        return QUALITY_PRODIGY
    if score >= 48.0:
        return QUALITY_OUTSTANDING
    return QUALITY_COMMON

func recompute_candidate_quality(candidate: CandidateState) -> StringName:
    if candidate.foundation_model_version >= FoundationSystem.MODEL_OPEN_POINTS:
        return FoundationSystem.new().recompute_candidate_quality(candidate)
    candidate.disciple_quality = quality_for_foundation(candidate.aptitude, candidate.constitution, candidate.fortune, candidate.comprehension, candidate.charisma, candidate.potential)
    return candidate.disciple_quality

func recompute_disciple_quality(disciple: DiscipleState) -> StringName:
    if disciple.foundation_model_version >= FoundationSystem.MODEL_OPEN_POINTS:
        return FoundationSystem.new().recompute_disciple_quality(disciple)
    disciple.disciple_quality = quality_for_foundation(disciple.aptitude, disciple.constitution, disciple.fortune, disciple.comprehension, disciple.charisma, disciple.potential)
    return disciple.disciple_quality

func quality_name(quality: StringName) -> String:
    return str(QUALITY_NAMES.get(str(quality), str(quality)))

func profession_suitability(candidate: CandidateState, profession_id: StringName) -> float:
    var score := candidate.comprehension * 65.0
    if candidate.foundation_model_version < FoundationSystem.MODEL_D7:
        score += candidate.potential * 20.0
    if profession_id == WorkforceSystem.PROF_FORGING and candidate.profession_traits.has(WorkforceSystem.TRAIT_FORGE):
        score += 35.0
    elif profession_id == WorkforceSystem.PROF_MINING and candidate.profession_traits.has(WorkforceSystem.TRAIT_MINER):
        score += 35.0
    if candidate.profession_traits.has(WorkforceSystem.TRAIT_DILIGENT):
        score += 8.0
    if candidate.profession_traits.has(WorkforceSystem.TRAIT_LAZY):
        score -= 8.0
    return score

func validate_candidate(candidate: CandidateState) -> Array[String]:
    if candidate.foundation_model_version >= FoundationSystem.MODEL_OPEN_POINTS:
        return FoundationSystem.new().validate_candidate(candidate)
    var errors: Array[String] = []
    if candidate.profile_seed <= 0:
        errors.append("V2 candidate has invalid profile seed.")
    if not VALID_SOURCES.has(candidate.recruitment_source):
        errors.append("V2 candidate has invalid recruitment source.")
    if not VALID_QUALITIES.has(candidate.disciple_quality):
        errors.append("V2 candidate has invalid disciple quality.")
    for value in [candidate.aptitude, candidate.constitution, candidate.fortune, candidate.comprehension, candidate.charisma, candidate.potential, candidate.spiritual_root_purity]:
        if value <= 0.0 or value > 1.0:
            errors.append("V2 candidate has an out-of-range foundation value.")
            break
    if candidate.spiritual_root_elements.is_empty():
        errors.append("V2 candidate has no spiritual-root elements.")
    if candidate.age < 12 or candidate.base_lifespan <= candidate.age or candidate.max_lifespan < candidate.base_lifespan:
        errors.append("V2 candidate has invalid lifespan schema.")
    if candidate.latent_identity_seed <= 0:
        errors.append("V2 candidate has invalid latent identity seed.")
    return errors

func _roll_dimension(rng: GameRng, source: StringName) -> float:
    match source:
        SOURCE_GACHA:
            return rng.randf_range(0.34, 0.96)
        SOURCE_FATE:
            return rng.randf_range(0.22, 0.94)
        _:
            return rng.randf_range(0.20, 0.84)

func _roll_root_purity(rng: GameRng, source: StringName) -> float:
    match source:
        SOURCE_GACHA:
            return rng.randf_range(0.45, 0.96)
        SOURCE_FATE:
            return rng.randf_range(0.30, 0.98)
        _:
            return rng.randf_range(0.30, 0.88)

func _roll_root_elements(rng: GameRng, source: StringName) -> Array:
    var pool: Array = ["metal", "wood", "water", "fire", "earth"]
    var count_roll := rng.randf_range(0.0, 1.0)
    var count := 1
    if source == SOURCE_FATE:
        count = 1 if count_roll < 0.32 else (2 if count_roll < 0.66 else (3 if count_roll < 0.90 else 4))
    else:
        count = 1 if count_roll < 0.30 else (2 if count_roll < 0.67 else (3 if count_roll < 0.92 else 4))
    var result: Array = []
    while result.size() < count and not pool.is_empty():
        var index := rng.randi_range(0, pool.size() - 1)
        result.append(pool[index])
        pool.remove_at(index)
    result.sort()
    return result

func _legacy_root_quality(purity: float) -> StringName:
    if purity >= 0.82:
        return SpiritualRootSystem.QUALITY_HEAVEN
    if purity >= 0.65:
        return SpiritualRootSystem.QUALITY_EARTH
    if purity >= 0.48:
        return SpiritualRootSystem.QUALITY_ORDINARY
    return SpiritualRootSystem.QUALITY_MIXED

func _roll_profession_traits(rng: GameRng, source: StringName) -> Array:
    var result: Array = []
    var talent_chance := 0.32 if source == SOURCE_ORDINARY else 0.42
    if rng.randf_range(0.0, 1.0) < talent_chance:
        result.append("forge_talent" if rng.randi_range(0, 1) == 0 else "miner_instinct")
    var temperament_chance := 0.22 if source != SOURCE_FATE else 0.32
    if rng.randf_range(0.0, 1.0) < temperament_chance:
        result.append("diligent" if rng.randi_range(0, 1) == 0 else "lazy")
    result.sort()
    return result

func _roll_age(rng: GameRng, source: StringName) -> int:
    if source == SOURCE_FATE:
        return rng.randi_range(16, 48)
    return rng.randi_range(14, 34)

func _roll_starting_stage(rng: GameRng, source: StringName, aptitude: float, potential: float, age: int) -> int:
    var score := aptitude * 0.45 + potential * 0.35 + clampf((float(age) - 14.0) / 40.0, 0.0, 1.0) * 0.20
    var stage := 0
    if score >= 0.50:
        stage = 1
    if score >= 0.68:
        stage = 2
    if source == SOURCE_GACHA and score >= 0.74 and rng.randf_range(0.0, 1.0) < 0.35:
        stage = 3
    return clampi(stage, 0, 3)

func _profile_seed(base_seed: int, source: StringName, generation_index: int) -> int:
    var source_hash := _stable_hash(str(source))
    var value := int((base_seed + generation_index * PROFILE_MULTIPLIER + source_hash * 31 + PROFILE_OFFSET) % HASH_MODULUS)
    return value if value > 0 else value + HASH_MODULUS

func _stable_hash(value: String) -> int:
    var result := 17
    for index in range(value.length()):
        result = int((result * 131 + value.unicode_at(index)) % HASH_MODULUS)
    return result
