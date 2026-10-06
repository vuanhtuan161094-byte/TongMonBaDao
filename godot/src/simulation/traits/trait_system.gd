class_name TraitSystem
extends RefCounted

const TRAIT_STEADY_MERIDIANS := &"steady_meridians"
const TRAIT_DILIGENT_WORKER := &"diligent_worker"
const TRAIT_FEARLESS := &"fearless"
const TRAIT_FRAGILE_MERIDIANS := &"fragile_meridians"
const TRAIT_CARELESS_WORKER := &"careless_worker"
const TRAIT_TIMID := &"timid"

const TRAIT_BATTLE_INSTINCT := &"battle_instinct"
const TRAIT_CRAFTSMAN_EYE := &"craftsman_eye"
const TRAIT_MEDITATIVE_INSIGHT := &"meditative_insight"

const VISIBLE_TRAITS := [
    TRAIT_STEADY_MERIDIANS,
    TRAIT_DILIGENT_WORKER,
    TRAIT_FEARLESS,
    TRAIT_FRAGILE_MERIDIANS,
    TRAIT_CARELESS_WORKER,
    TRAIT_TIMID
]
const LATENT_TRAITS := [TRAIT_BATTLE_INSTINCT, TRAIT_CRAFTSMAN_EYE, TRAIT_MEDITATIVE_INSIGHT]
const ALL_TRAITS := VISIBLE_TRAITS + LATENT_TRAITS

const TRAIT_NAMES := {
    "steady_meridians": "Kinh Mạch Ổn Định",
    "diligent_worker": "Cần Mẫn",
    "fearless": "Gan Dạ",
    "fragile_meridians": "Kinh Mạch Yếu",
    "careless_worker": "Cẩu Thả",
    "timid": "Nhát Chiến",
    "battle_instinct": "Bản Năng Chiến Đấu",
    "craftsman_eye": "Nhãn Lực Luyện Khí",
    "meditative_insight": "Ngộ Tĩnh"
}

const PROFILE_SEED_OFFSET := 99173

func initialize(state: SimulationState) -> void:
    if not state.sect.disciple_generation_v2_enabled:
        return
    state.sect.disciple_traits_enabled = true
    var candidate_ids: Array = state.recruitment_candidates.keys()
    candidate_ids.sort()
    for candidate_id in candidate_ids:
        var candidate: CandidateState = state.recruitment_candidates[candidate_id]
        ensure_candidate_profile(state, candidate)

func ensure_candidate_profile(state: SimulationState, candidate: CandidateState) -> Dictionary:
    if not state.sect.disciple_traits_enabled or candidate.profile_seed <= 0:
        return {}
    return _ensure_profile(state, str(candidate.id), candidate.latent_identity_seed, candidate.recruitment_source)

func ensure_disciple_profile(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    if not state.sect.disciple_traits_enabled or disciple.profile_seed <= 0:
        return {}
    return _ensure_profile(state, str(disciple.id), disciple.latent_identity_seed, disciple.recruitment_source)

func remove_profile(state: SimulationState, character_id: StringName) -> void:
    if state.sect.disciple_trait_profiles.erase(str(character_id)):
        state.sect.disciple_trait_event_count += 1

func profile_for(state: SimulationState, character_id: StringName) -> Dictionary:
    var raw = state.sect.disciple_trait_profiles.get(str(character_id), {})
    return raw if raw is Dictionary else {}

func visible_trait_ids(state: SimulationState, character_id: StringName) -> Array:
    var profile := profile_for(state, character_id)
    return _string_array(profile.get("visible", []))

func latent_trait_ids(state: SimulationState, character_id: StringName) -> Array:
    var profile := profile_for(state, character_id)
    return _string_array(profile.get("latent", []))

func revealed_trait_ids(state: SimulationState, character_id: StringName) -> Array:
    var profile := profile_for(state, character_id)
    return _string_array(profile.get("revealed", []))

func active_trait_ids(state: SimulationState, disciple: DiscipleState) -> Array:
    if not state.sect.disciple_traits_enabled:
        return []
    var result := visible_trait_ids(state, disciple.id)
    for trait_id in revealed_trait_ids(state, disciple.id):
        if not result.has(str(trait_id)):
            result.append(str(trait_id))
    result.sort()
    return result

func trait_name(trait_id: StringName) -> String:
    return str(TRAIT_NAMES.get(str(trait_id), str(trait_id)))

func trait_grade(state: SimulationState, character_id: StringName, trait_id: StringName) -> int:
    var profile = state.sect.disciple_trait_profiles.get(str(character_id), {})
    if not (profile is Dictionary):
        return 1
    var grades = profile.get("grades", {})
    if not (grades is Dictionary):
        return 1
    return clampi(int(grades.get(str(trait_id), 1)), 1, 5)

func cultivation_gain_multiplier(state: SimulationState, disciple: DiscipleState) -> float:
    if not state.sect.disciple_traits_enabled:
        return 1.0
    var active := active_trait_ids(state, disciple)
    var multiplier := 1.0
    if active.has(str(TRAIT_STEADY_MERIDIANS)):
        multiplier *= 1.08
    if active.has(str(TRAIT_FRAGILE_MERIDIANS)):
        multiplier *= 0.92
    if active.has(str(TRAIT_MEDITATIVE_INSIGHT)):
        multiplier *= 1.10
    return multiplier

func work_speed_multiplier(state: SimulationState, disciple: DiscipleState) -> float:
    if not state.sect.disciple_traits_enabled:
        return 1.0
    var active := active_trait_ids(state, disciple)
    var multiplier := 1.0
    if active.has(str(TRAIT_DILIGENT_WORKER)):
        multiplier *= 1.08
    if active.has(str(TRAIT_CARELESS_WORKER)):
        multiplier *= 0.90
    if active.has(str(TRAIT_CRAFTSMAN_EYE)):
        multiplier *= 1.12
    return multiplier

func profession_learning_multiplier(state: SimulationState, disciple: DiscipleState) -> float:
    if not state.sect.disciple_traits_enabled:
        return 1.0
    var active := active_trait_ids(state, disciple)
    var multiplier := 1.0
    if active.has(str(TRAIT_DILIGENT_WORKER)):
        multiplier *= 1.08
    if active.has(str(TRAIT_CRAFTSMAN_EYE)):
        multiplier *= 1.10
    return multiplier

func combat_power_bonus(state: SimulationState, disciple: DiscipleState) -> float:
    if not state.sect.disciple_traits_enabled:
        return 0.0
    var active := active_trait_ids(state, disciple)
    var bonus := 0.0
    if active.has(str(TRAIT_FEARLESS)):
        bonus += 1.5
    if active.has(str(TRAIT_TIMID)):
        bonus -= 1.0
    if active.has(str(TRAIT_BATTLE_INSTINCT)):
        bonus += 2.5
    return bonus

func process_reveals(state: SimulationState, disciple: DiscipleState) -> Array:
    var revealed_now: Array = []
    if not state.sect.disciple_traits_enabled or disciple.profile_seed <= 0:
        return revealed_now
    var profile := ensure_disciple_profile(state, disciple)
    if profile.is_empty():
        return revealed_now
    var latent := _string_array(profile.get("latent", []))
    var revealed := _string_array(profile.get("revealed", []))
    for raw_id in latent:
        var trait_id := StringName(raw_id)
        if revealed.has(str(trait_id)):
            continue
        if _reveal_condition_met(disciple, trait_id):
            revealed.append(str(trait_id))
            revealed_now.append(str(trait_id))
    if revealed_now.is_empty():
        return revealed_now
    revealed.sort()
    profile["revealed"] = revealed
    state.sect.disciple_trait_profiles[str(disciple.id)] = profile
    state.sect.disciple_trait_event_count += revealed_now.size()
    disciple.metrics["trait_reveals"] = int(disciple.metrics.get("trait_reveals", 0)) + revealed_now.size()
    return revealed_now

func validate_invariants(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if not state.sect.disciple_traits_enabled:
        return errors
    var profile_ids: Array = state.sect.disciple_trait_profiles.keys()
    profile_ids.sort()
    for raw_id in profile_ids:
        var owner_id := StringName(raw_id)
        if not state.disciples.has(owner_id) and not state.recruitment_candidates.has(owner_id):
            errors.append("Trait profile %s has no candidate/disciple owner." % owner_id)
            continue
        var profile = state.sect.disciple_trait_profiles[raw_id]
        if not (profile is Dictionary) or not bool(profile.get("initialized", false)):
            errors.append("Trait profile %s is invalid/uninitialized." % owner_id)
            continue
        var visible := _string_array(profile.get("visible", []))
        var latent := _string_array(profile.get("latent", []))
        var revealed := _string_array(profile.get("revealed", []))
        for trait_id in visible + latent + revealed:
            if not ALL_TRAITS.has(StringName(trait_id)):
                errors.append("Trait profile %s contains invalid trait %s." % [owner_id, trait_id])
        for revealed_id in revealed:
            if not latent.has(str(revealed_id)):
                errors.append("Trait profile %s revealed a non-latent trait %s." % [owner_id, revealed_id])
        var grades = profile.get("grades", {})
        if not (grades is Dictionary):
            errors.append("Trait profile %s has invalid grade storage." % owner_id)
        else:
            for trait_id in visible + latent:
                var grade := int(grades.get(str(trait_id), 1))
                if grade < 1 or grade > 5:
                    errors.append("Trait profile %s has invalid grade for %s." % [owner_id, trait_id])
    if state.sect.disciple_trait_event_count < 0:
        errors.append("Disciple trait event count cannot be negative.")
    return errors

func _ensure_profile(state: SimulationState, character_id: String, latent_seed: int, source: StringName) -> Dictionary:
    var existing = state.sect.disciple_trait_profiles.get(character_id, {})
    if existing is Dictionary and bool(existing.get("initialized", false)):
        if not existing.has("grades"):
            var migrated_grades: Dictionary = {}
            for trait_id in _string_array(existing.get("visible", [])) + _string_array(existing.get("latent", [])):
                migrated_grades[str(trait_id)] = 1
            existing["grades"] = migrated_grades
            state.sect.disciple_trait_profiles[character_id] = existing
            state.sect.disciple_trait_event_count += 1
        return existing
    var seed_value := latent_seed if latent_seed > 0 else _stable_hash(character_id)
    var rng := GameRng.new(seed_value + PROFILE_SEED_OFFSET)
    var visible := _roll_visible(rng, source)
    var latent := _roll_latent(rng, source)
    var grades: Dictionary = {}
    for trait_id in visible + latent:
        grades[str(trait_id)] = _roll_grade(rng)
    var profile := {
        "initialized": true,
        "visible": visible,
        "latent": latent,
        "revealed": [],
        "grades": grades
    }
    state.sect.disciple_trait_profiles[character_id] = profile
    state.sect.disciple_trait_event_count += 1
    return profile

func _roll_visible(rng: GameRng, source: StringName) -> Array:
    var pool: Array = []
    for trait_id in VISIBLE_TRAITS:
        pool.append(str(trait_id))
    var roll := rng.randf_range(0.0, 1.0)
    var count := 0
    if source == DiscipleGeneratorV2.SOURCE_GACHA:
        count = 1 if roll < 0.58 else (2 if roll < 0.86 else 0)
    elif source == DiscipleGeneratorV2.SOURCE_FATE:
        count = 1 if roll < 0.46 else (2 if roll < 0.76 else 0)
    else:
        count = 1 if roll < 0.40 else (2 if roll < 0.62 else 0)
    var result: Array = []
    while result.size() < count and not pool.is_empty():
        var index := rng.randi_range(0, pool.size() - 1)
        result.append(pool[index])
        pool.remove_at(index)
    result.sort()
    return result

func _roll_latent(rng: GameRng, source: StringName) -> Array:
    var chance := 0.38
    if source == DiscipleGeneratorV2.SOURCE_GACHA:
        chance = 0.48
    elif source == DiscipleGeneratorV2.SOURCE_FATE:
        chance = 0.62
    if rng.randf_range(0.0, 1.0) >= chance:
        return []
    return [str(LATENT_TRAITS[rng.randi_range(0, LATENT_TRAITS.size() - 1)])]

func _roll_grade(rng: GameRng) -> int:
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

func _reveal_condition_met(disciple: DiscipleState, trait_id: StringName) -> bool:
    match trait_id:
        TRAIT_BATTLE_INSTINCT:
            return int(disciple.metrics.get("combats", 0)) >= 3
        TRAIT_CRAFTSMAN_EYE:
            return int(disciple.metrics.get("work_completions", 0)) >= 2
        TRAIT_MEDITATIVE_INSIGHT:
            return int(disciple.metrics.get("cultivation_sessions", 0)) >= 3
        _:
            return false

func _string_array(value: Variant) -> Array:
    var result: Array = []
    if not (value is Array):
        return result
    for item in value:
        var text := str(item)
        if text != "" and not result.has(text):
            result.append(text)
    result.sort()
    return result

func _stable_hash(value: String) -> int:
    var result := 17
    for index in range(value.length()):
        result = int((result * 131 + value.unicode_at(index)) % 2147483629)
    return maxi(result, 1)
