class_name DiscipleGeneratorOpenPoints
extends RefCounted

const HASH_MODULUS := 2147483629
const PROFILE_OFFSET := 183811
const PROFILE_MULTIPLIER := 104729

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

var foundations := FoundationSystem.new()

func generate_candidate(state: SimulationState, source: StringName, generation_index: int, forced_quality: StringName = &"") -> CandidateState:
    if not DiscipleGeneratorV2.VALID_SOURCES.has(source) or generation_index <= 0:
        return null
    if forced_quality != &"" and not DiscipleGeneratorV2.VALID_QUALITIES.has(forced_quality):
        return null

    var profile_seed := _profile_seed(state.seed, source, generation_index)
    var rng := GameRng.new(profile_seed)
    var surname := str(SURNAMES[rng.randi_range(0, SURNAMES.size() - 1)])
    var given_name := str(GIVEN_NAMES[rng.randi_range(0, GIVEN_NAMES.size() - 1)])
    var archetype_id := str(ARCHETYPE_IDS[rng.randi_range(0, ARCHETYPE_IDS.size() - 1)])
    var archetype: Dictionary = ARCHETYPES[archetype_id]

    var quality := forced_quality if forced_quality != &"" else _roll_source_quality(rng, source)
    var total := _roll_total_for_quality(rng, quality)
    var values := _distribute_total(rng, total, source)
    var aptitude := float(values[0])
    var constitution := float(values[1])
    var fortune := float(values[2])
    var comprehension := float(values[3])
    var charisma := float(values[4])
    var potential := float(values[5])
    quality = foundations.quality_for_total(float(total))

    var root_purity := _roll_root_purity(rng, source)
    var root_elements := _roll_root_elements(rng, source)
    var root_quality := _legacy_root_quality(root_purity)
    var profession_traits := _roll_profession_traits(rng, source)

    var age := _roll_age(rng, source)
    var base_lifespan := rng.randi_range(88, 110)
    base_lifespan = maxi(base_lifespan, age + 30)
    var stage_index := _roll_starting_stage(rng, source, age)
    var stage: Dictionary = CultivationSystem.STAGES[stage_index]
    var cultivation_bonus := float(stage.get("combat_bonus", 0.0))
    var hp_bonus := float(stage.get("hp_bonus", 0.0))
    var required := float(stage.get("required", 0.0))
    var cultivation_progress := required * rng.randf_range(0.0, 0.30) if required > 0.0 else 0.0
    var intrinsic_power := 10.0 + float(stage_index) * 2.0
    var latent_seed := _stable_hash("latent-open:%d:%s:%d" % [state.seed, str(source), generation_index])
    var birth_values := {
        "aptitude": aptitude,
        "constitution": constitution,
        "fortune": fortune,
        "comprehension": comprehension,
        "charisma": charisma,
        "potential": potential
    }

    var candidate := CandidateState.new({
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
        "race_id": "human",
        "sex_id": "male" if rng.randi_range(0, 1) == 0 else "female",
        "origin_id": str(ORIGINS[rng.randi_range(0, ORIGINS.size() - 1)]),
        "aptitude": aptitude,
        "constitution": constitution,
        "fortune": fortune,
        "comprehension": comprehension,
        "charisma": charisma,
        "potential": potential,
        "foundation_model_version": FoundationSystem.MODEL_OPEN_POINTS,
        "foundation_birth_values": birth_values,
        "disciple_quality": str(quality),
        "spiritual_root_quality": str(root_quality),
        "spiritual_root_purity": root_purity,
        "spiritual_root_elements": root_elements,
        "profession_traits": profession_traits,
        "age": age,
        "base_lifespan": base_lifespan,
        "max_lifespan": base_lifespan,
        "latent_identity_seed": latent_seed,
        "cultivation_stage_index": stage_index,
        "cultivation_progress": cultivation_progress,
        "cultivation_combat_bonus": cultivation_bonus,
        "cultivation_hp_bonus": hp_bonus
    })
    if state.sect.disciple_v2_birth_enabled:
        candidate.v2_birth_profile = DiscipleBirthRollV2.populate(
            DiscipleBirthProfileV2.create_envelope(candidate), candidate
        )
        if not DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile):
            push_error("DV2-01B: invalid complete birth profile for " + str(candidate.id))
            return null
    return candidate

func _roll_source_quality(rng: GameRng, source: StringName) -> StringName:
    var rates := [0.65, 0.25, 0.08, 0.018, 0.002]
    if source == DiscipleGeneratorV2.SOURCE_GACHA:
        rates = [0.42, 0.30, 0.18, 0.08, 0.02]
    elif source == DiscipleGeneratorV2.SOURCE_FATE:
        rates = [0.50, 0.28, 0.14, 0.06, 0.02]
    var roll := rng.randf_range(0.0, 1.0)
    var cumulative := 0.0
    for index in range(DiscipleGeneratorV2.VALID_QUALITIES.size()):
        cumulative += float(rates[index])
        if roll < cumulative:
            return DiscipleGeneratorV2.VALID_QUALITIES[index]
    return DiscipleGeneratorV2.QUALITY_HEAVEN_DEFYING

func _roll_total_for_quality(rng: GameRng, quality: StringName) -> int:
    match quality:
        DiscipleGeneratorV2.QUALITY_COMMON:
            return rng.randi_range(120, 359)
        DiscipleGeneratorV2.QUALITY_OUTSTANDING:
            return rng.randi_range(360, 599)
        DiscipleGeneratorV2.QUALITY_PRODIGY:
            return rng.randi_range(600, 999)
        DiscipleGeneratorV2.QUALITY_PEERLESS:
            return rng.randi_range(1000, 1799)
        DiscipleGeneratorV2.QUALITY_HEAVEN_DEFYING:
            var floor_value := 1800
            var span := 1200
            while rng.randf_range(0.0, 1.0) < 0.12:
                floor_value += span
                span *= 2
            return floor_value + rng.randi_range(0, span - 1)
        _:
            return rng.randi_range(120, 359)

func _distribute_total(rng: GameRng, total: int, source: StringName) -> Array:
    var minimum := maxi(int(floor(float(total) / 12.0)), 1)
    var maximum := maxi(int(floor(float(total) / 2.0)), minimum)
    var values := [minimum, minimum, minimum, minimum, minimum, minimum]
    var remaining := total - minimum * values.size()
    var order := [0, 1, 2, 3, 4, 5]
    for i in range(order.size() - 1, 0, -1):
        var j := rng.randi_range(0, i)
        var tmp = order[i]
        order[i] = order[j]
        order[j] = tmp

    for position in range(order.size()):
        var index := int(order[position])
        var capacity := maximum - int(values[index])
        var rest_capacity := 0
        for next_position in range(position + 1, order.size()):
            rest_capacity += maximum - int(values[int(order[next_position])])
        var min_add := maxi(remaining - rest_capacity, 0)
        var max_add := mini(capacity, remaining)
        var add := remaining if position == order.size() - 1 else rng.randi_range(min_add, max_add)
        values[index] = int(values[index]) + add
        remaining -= add

    if source == DiscipleGeneratorV2.SOURCE_FATE and rng.randf_range(0.0, 1.0) < 0.70:
        var max_index := 0
        for index in range(1, values.size()):
            if int(values[index]) > int(values[max_index]):
                max_index = index
        if max_index != 2:
            var swap = values[2]
            values[2] = values[max_index]
            values[max_index] = swap
    return values

func _roll_root_purity(rng: GameRng, source: StringName) -> float:
    match source:
        DiscipleGeneratorV2.SOURCE_GACHA:
            return rng.randf_range(0.45, 0.96)
        DiscipleGeneratorV2.SOURCE_FATE:
            return rng.randf_range(0.30, 0.98)
        _:
            return rng.randf_range(0.30, 0.88)

func _roll_root_elements(rng: GameRng, source: StringName) -> Array:
    var pool: Array = ["metal", "wood", "water", "fire", "earth"]
    var roll := rng.randf_range(0.0, 1.0)
    var count := 1
    if source == DiscipleGeneratorV2.SOURCE_FATE:
        count = 1 if roll < 0.32 else (2 if roll < 0.66 else (3 if roll < 0.90 else 4))
    else:
        count = 1 if roll < 0.30 else (2 if roll < 0.67 else (3 if roll < 0.92 else 4))
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
    var talent_chance := 0.30 if source == DiscipleGeneratorV2.SOURCE_ORDINARY else (0.40 if source == DiscipleGeneratorV2.SOURCE_GACHA else 0.50)
    if rng.randf_range(0.0, 1.0) < talent_chance:
        result.append("forge_talent" if rng.randi_range(0, 1) == 0 else "miner_instinct")
    if rng.randf_range(0.0, 1.0) < 0.22:
        result.append("diligent" if rng.randi_range(0, 1) == 0 else "lazy")
    result.sort()
    return result

func _roll_age(rng: GameRng, source: StringName) -> int:
    return rng.randi_range(16, 48) if source == DiscipleGeneratorV2.SOURCE_FATE else rng.randi_range(14, 34)

func _roll_starting_stage(rng: GameRng, source: StringName, age: int) -> int:
    var stage := 0
    if age >= 18 and rng.randf_range(0.0, 1.0) < 0.55:
        stage = 1
    if age >= 24 and rng.randf_range(0.0, 1.0) < 0.35:
        stage = 2
    if source == DiscipleGeneratorV2.SOURCE_GACHA and age >= 26 and rng.randf_range(0.0, 1.0) < 0.20:
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
