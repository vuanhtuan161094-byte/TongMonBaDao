class_name BloodlineSystem
extends RefCounted

const BLOODLINE_NONE := &"none"
const BLOODLINE_TRUE_DRAGON := &"true_dragon"
const BLOODLINE_PHOENIX := &"phoenix"
const BLOODLINE_WHITE_TIGER := &"white_tiger"
const BLOODLINE_BLACK_TORTOISE := &"black_tortoise"
const BLOODLINE_TAOTIE_REMNANT := &"taotie_remnant"

const VALID_BLOODLINES := [
    BLOODLINE_NONE,
    BLOODLINE_TRUE_DRAGON,
    BLOODLINE_PHOENIX,
    BLOODLINE_WHITE_TIGER,
    BLOODLINE_BLACK_TORTOISE,
    BLOODLINE_TAOTIE_REMNANT
]

const BLOODLINE_NAMES := {
    "none": "Không có huyết mạch đặc biệt",
    "true_dragon": "Chân Long Huyết",
    "phoenix": "Phượng Hoàng Huyết",
    "white_tiger": "Bạch Hổ Huyết",
    "black_tortoise": "Huyền Vũ Huyết",
    "taotie_remnant": "Thao Thiết Tàn Huyết"
}

const PROFILE_SEED_OFFSET := 271331
const MAX_PURITY := 0.95
const MATERIAL_ID := "yeu_dan"

func initialize(state: SimulationState) -> void:
    if not state.sect.disciple_generation_v2_enabled:
        return
    state.sect.bloodlines_enabled = true

    var candidate_ids: Array = state.recruitment_candidates.keys()
    candidate_ids.sort()
    for raw_id in candidate_ids:
        var candidate: CandidateState = state.recruitment_candidates[raw_id]
        ensure_candidate_profile(state, candidate)

    var disciple_ids: Array = state.disciples.keys()
    disciple_ids.sort()
    for raw_id in disciple_ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.profile_seed > 0:
            ensure_disciple_profile(state, disciple)

func ensure_candidate_profile(state: SimulationState, candidate: CandidateState) -> Dictionary:
    if not state.sect.bloodlines_enabled or candidate.profile_seed <= 0:
        return {}
    return _ensure_profile(state, str(candidate.id), candidate.latent_identity_seed, candidate.recruitment_source)

func ensure_disciple_profile(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    if not state.sect.bloodlines_enabled or disciple.profile_seed <= 0:
        return {}
    return _ensure_profile(state, str(disciple.id), disciple.latent_identity_seed, disciple.recruitment_source)

func remove_profile(state: SimulationState, character_id: StringName) -> void:
    if state.sect.bloodline_profiles.erase(str(character_id)):
        state.sect.bloodline_event_count += 1

func profile_for(state: SimulationState, character_id: StringName) -> Dictionary:
    var raw = state.sect.bloodline_profiles.get(str(character_id), {})
    return raw if raw is Dictionary else {}

func bloodline_id(state: SimulationState, character_id: StringName) -> StringName:
    return StringName(profile_for(state, character_id).get("bloodline_id", "none"))

func bloodline_name(id: StringName) -> String:
    return str(BLOODLINE_NAMES.get(str(id), str(id)))

func purity(state: SimulationState, character_id: StringName) -> float:
    return clampf(float(profile_for(state, character_id).get("purity", 0.0)), 0.0, 1.0)

func is_revealed(state: SimulationState, character_id: StringName) -> bool:
    return bool(profile_for(state, character_id).get("revealed", false))

func is_awakened(state: SimulationState, character_id: StringName) -> bool:
    return bool(profile_for(state, character_id).get("awakened", false))

func process_reveal(state: SimulationState, disciple: DiscipleState) -> bool:
    if not state.sect.bloodlines_enabled or disciple.profile_seed <= 0:
        return false
    var profile := ensure_disciple_profile(state, disciple)
    if profile.is_empty() or bool(profile.get("revealed", false)):
        return false
    var id := StringName(profile.get("bloodline_id", "none"))
    if id == BLOODLINE_NONE or not _reveal_condition_met(disciple, id):
        return false

    profile["revealed"] = true
    state.sect.bloodline_profiles[str(disciple.id)] = profile
    state.sect.bloodline_event_count += 1
    disciple.metrics["bloodline_reveals"] = int(disciple.metrics.get("bloodline_reveals", 0)) + 1
    return true

func awaken_bloodline(state: SimulationState, disciple_id: StringName) -> Dictionary:
    if not state.sect.bloodlines_enabled or not state.disciples.has(disciple_id):
        return {"ok":false, "reason":"bloodlines_disabled_or_disciple_missing"}
    var disciple: DiscipleState = state.disciples[disciple_id]
    var profile := ensure_disciple_profile(state, disciple)
    if profile.is_empty():
        return {"ok":false, "reason":"profile_missing"}
    var id := StringName(profile.get("bloodline_id", "none"))
    if id == BLOODLINE_NONE:
        return {"ok":false, "reason":"no_special_bloodline"}
    if not bool(profile.get("revealed", false)):
        return {"ok":false, "reason":"bloodline_hidden"}
    if bool(profile.get("awakened", false)):
        return {"ok":false, "reason":"already_awakened"}
    if int(state.sect.technique_materials.get(MATERIAL_ID, 0)) <= 0:
        return {"ok":false, "reason":"yao_core_missing"}

    _consume_material(state, MATERIAL_ID, 1)
    profile["awakened"] = true
    state.sect.bloodline_profiles[str(disciple.id)] = profile
    state.sect.bloodline_event_count += 1
    disciple.metrics["bloodline_awakenings"] = int(disciple.metrics.get("bloodline_awakenings", 0)) + 1
    return {
        "ok":true,
        "reason":"awakened",
        "bloodline_id":str(id),
        "bloodline_name":bloodline_name(id),
        "purity":float(profile.get("purity", 0.0))
    }

func refine_bloodline(state: SimulationState, disciple_id: StringName) -> Dictionary:
    if not state.sect.bloodlines_enabled or not state.disciples.has(disciple_id):
        return {"ok":false, "reason":"bloodlines_disabled_or_disciple_missing"}
    var disciple: DiscipleState = state.disciples[disciple_id]
    var profile := ensure_disciple_profile(state, disciple)
    if profile.is_empty() or not bool(profile.get("awakened", false)):
        return {"ok":false, "reason":"bloodline_not_awakened"}
    if float(profile.get("purity", 0.0)) >= MAX_PURITY - 0.000001:
        return {"ok":false, "reason":"max_purity"}
    if int(state.sect.technique_materials.get(MATERIAL_ID, 0)) <= 0:
        return {"ok":false, "reason":"yao_core_missing"}

    _consume_material(state, MATERIAL_ID, 1)
    var before := clampf(float(profile.get("purity", 0.0)), 0.0, MAX_PURITY)
    var gain := _refinement_gain(disciple, before)
    profile["purity"] = minf(MAX_PURITY, before + gain)
    profile["refinement_count"] = int(profile.get("refinement_count", 0)) + 1
    state.sect.bloodline_profiles[str(disciple.id)] = profile
    state.sect.bloodline_event_count += 1
    disciple.metrics["bloodline_refinements"] = int(disciple.metrics.get("bloodline_refinements", 0)) + 1
    return {
        "ok":true,
        "reason":"refined",
        "purity_before":before,
        "purity_after":float(profile["purity"]),
        "refinement_count":int(profile["refinement_count"])
    }

func combat_power_bonus(state: SimulationState, disciple: DiscipleState) -> float:
    if not _active(state, disciple):
        return 0.0
    var id := bloodline_id(state, disciple.id)
    var p := purity(state, disciple.id)
    match id:
        BLOODLINE_TRUE_DRAGON:
            return 1.5 + p * 4.5
        BLOODLINE_WHITE_TIGER:
            return 2.0 + p * 6.0
        _:
            return 0.0

func breakthrough_bonus(state: SimulationState, disciple: DiscipleState) -> float:
    if not _active(state, disciple):
        return 0.0
    if bloodline_id(state, disciple.id) != BLOODLINE_TRUE_DRAGON:
        return 0.0
    return 0.008 + purity(state, disciple.id) * 0.025

func incoming_damage_multiplier(state: SimulationState, disciple: DiscipleState) -> float:
    if not _active(state, disciple):
        return 1.0
    if bloodline_id(state, disciple.id) != BLOODLINE_BLACK_TORTOISE:
        return 1.0
    return clampf(0.94 - purity(state, disciple.id) * 0.18, 0.72, 1.0)

func rest_recovery_multiplier(state: SimulationState, disciple: DiscipleState) -> float:
    if not _active(state, disciple):
        return 1.0
    var p := purity(state, disciple.id)
    match bloodline_id(state, disciple.id):
        BLOODLINE_PHOENIX:
            return 1.15 + p * 0.35
        BLOODLINE_TAOTIE_REMNANT:
            return 1.20 + p * 0.30
        _:
            return 1.0

func extra_departure_supply_cost(state: SimulationState, disciple: DiscipleState) -> int:
    if not _active(state, disciple):
        return 0
    return 1 if bloodline_id(state, disciple.id) == BLOODLINE_TAOTIE_REMNANT else 0

func validate_invariants(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if not state.sect.bloodlines_enabled:
        return errors

    var profile_ids: Array = state.sect.bloodline_profiles.keys()
    profile_ids.sort()
    for raw_id in profile_ids:
        var owner_id := StringName(raw_id)
        if not state.disciples.has(owner_id) and not state.recruitment_candidates.has(owner_id):
            errors.append("Bloodline profile %s has no candidate/disciple owner." % owner_id)
            continue
        var profile = state.sect.bloodline_profiles[raw_id]
        if not (profile is Dictionary) or not bool(profile.get("initialized", false)):
            errors.append("Bloodline profile %s is invalid/uninitialized." % owner_id)
            continue
        var id := StringName(profile.get("bloodline_id", "none"))
        if not VALID_BLOODLINES.has(id):
            errors.append("Bloodline profile %s has invalid bloodline id %s." % [owner_id, id])
        var p := float(profile.get("purity", 0.0))
        if p < -0.000001 or p > MAX_PURITY + 0.000001:
            errors.append("Bloodline profile %s has invalid purity." % owner_id)
        if id == BLOODLINE_NONE and p > 0.000001:
            errors.append("Bloodline profile %s has purity without a special bloodline." % owner_id)
        if bool(profile.get("awakened", false)) and (id == BLOODLINE_NONE or not bool(profile.get("revealed", false))):
            errors.append("Bloodline profile %s has an impossible awakened state." % owner_id)
        if int(profile.get("refinement_count", 0)) < 0:
            errors.append("Bloodline profile %s has negative refinement count." % owner_id)
    if state.sect.bloodline_event_count < 0:
        errors.append("Bloodline event count cannot be negative.")
    return errors

func _ensure_profile(state: SimulationState, character_id: String, latent_seed: int, source: StringName) -> Dictionary:
    var existing = state.sect.bloodline_profiles.get(character_id, {})
    if existing is Dictionary and bool(existing.get("initialized", false)):
        return existing

    var seed_value := latent_seed if latent_seed > 0 else _stable_hash(character_id)
    var rng := GameRng.new(seed_value + PROFILE_SEED_OFFSET)
    var special_chance := 0.18
    var reveal_chance := 0.20
    var purity_bonus := 0.0
    if source == DiscipleGeneratorV2.SOURCE_GACHA:
        special_chance = 0.28
        reveal_chance = 0.45
        purity_bonus = 0.03
    elif source == DiscipleGeneratorV2.SOURCE_FATE:
        special_chance = 0.42
        reveal_chance = 0.30
        purity_bonus = 0.06

    var id := BLOODLINE_NONE
    var p := 0.0
    var revealed := true
    if rng.randf_range(0.0, 1.0) < special_chance:
        id = _roll_special_bloodline(rng)
        p = clampf(rng.randf_range(0.08, 0.30) + purity_bonus, 0.08, 0.45)
        revealed = rng.randf_range(0.0, 1.0) < reveal_chance

    var profile := {
        "initialized":true,
        "bloodline_id":str(id),
        "purity":p,
        "revealed":revealed,
        "awakened":false,
        "refinement_count":0
    }
    state.sect.bloodline_profiles[character_id] = profile
    state.sect.bloodline_event_count += 1
    return profile

func _roll_special_bloodline(rng: GameRng) -> StringName:
    var roll := rng.randf_range(0.0, 100.0)
    if roll < 20.0:
        return BLOODLINE_TRUE_DRAGON
    if roll < 36.0:
        return BLOODLINE_PHOENIX
    if roll < 60.0:
        return BLOODLINE_WHITE_TIGER
    if roll < 84.0:
        return BLOODLINE_BLACK_TORTOISE
    return BLOODLINE_TAOTIE_REMNANT

func _reveal_condition_met(disciple: DiscipleState, id: StringName) -> bool:
    match id:
        BLOODLINE_TRUE_DRAGON:
            return int(disciple.metrics.get("combats", 0)) >= 3
        BLOODLINE_PHOENIX:
            return int(disciple.metrics.get("defeats", 0)) >= 1 and int(disciple.metrics.get("rests", 0)) >= 1
        BLOODLINE_WHITE_TIGER:
            return int(disciple.metrics.get("wins", 0)) >= 3
        BLOODLINE_BLACK_TORTOISE:
            return int(disciple.metrics.get("retreats", 0)) >= 2
        BLOODLINE_TAOTIE_REMNANT:
            return int(disciple.metrics.get("rests", 0)) >= 3
        _:
            return false

func _active(state: SimulationState, disciple: DiscipleState) -> bool:
    return state.sect.bloodlines_enabled and disciple.profile_seed > 0 and is_awakened(state, disciple.id)

func _refinement_gain(disciple: DiscipleState, current_purity: float) -> float:
    var base := 0.035 + clampf(disciple.potential, 0.0, 1.0) * 0.030
    var diminishing := lerpf(1.0, 0.40, clampf(current_purity, 0.0, 1.0))
    return maxf(base * diminishing, 0.008)

func _consume_material(state: SimulationState, material_id: String, quantity: int) -> void:
    var next := int(state.sect.technique_materials.get(material_id, 0)) - quantity
    if next <= 0:
        state.sect.technique_materials.erase(material_id)
    else:
        state.sect.technique_materials[material_id] = next

func _stable_hash(value: String) -> int:
    var result := 17
    for index in range(value.length()):
        result = int((result * 131 + value.unicode_at(index)) % 2147483629)
    return maxi(result, 1)
