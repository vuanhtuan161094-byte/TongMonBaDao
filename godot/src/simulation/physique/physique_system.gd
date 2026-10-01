class_name PhysiqueSystem
extends RefCounted

const PHYSIQUE_ORDINARY := &"ordinary_body"
const PHYSIQUE_SWORD_BONE := &"sword_bone"
const PHYSIQUE_DIAMOND_OVERLORD := &"diamond_overlord_body"
const PHYSIQUE_COLD_YIN := &"cold_yin_body"
const PHYSIQUE_FIRE_SPIRIT := &"fire_spirit_body"
const PHYSIQUE_PURE_DAO := &"pure_dao_body"

const VALID_PHYSIQUES := [
    PHYSIQUE_ORDINARY,
    PHYSIQUE_SWORD_BONE,
    PHYSIQUE_DIAMOND_OVERLORD,
    PHYSIQUE_COLD_YIN,
    PHYSIQUE_FIRE_SPIRIT,
    PHYSIQUE_PURE_DAO
]

const SPECIAL_PHYSIQUES := [
    PHYSIQUE_SWORD_BONE,
    PHYSIQUE_DIAMOND_OVERLORD,
    PHYSIQUE_COLD_YIN,
    PHYSIQUE_FIRE_SPIRIT,
    PHYSIQUE_PURE_DAO
]

const PHYSIQUE_NAMES := {
    "ordinary_body": "Phàm Thể",
    "sword_bone": "Kiếm Cốt",
    "diamond_overlord_body": "Kim Cương Bá Thể",
    "cold_yin_body": "Hàn Âm Thể",
    "fire_spirit_body": "Hỏa Linh Thể",
    "pure_dao_body": "Vô Cấu Đạo Thể"
}

const PROFILE_SEED_OFFSET := 413557
const MAX_TEMPER_LEVEL := 5
const TEMPER_MATERIAL_ID := "yeu_dan"
const TRANSFORM_MATERIAL_ID := "linh_tuy"
const TRANSFORM_MATERIAL_COST := 2

func initialize(state: SimulationState) -> void:
    if not state.sect.disciple_generation_v2_enabled:
        return
    state.sect.physiques_enabled = true

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
    if not state.sect.physiques_enabled or candidate.profile_seed <= 0:
        return {}
    return _ensure_profile(state, str(candidate.id), candidate.latent_identity_seed, candidate.recruitment_source)

func ensure_disciple_profile(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    if not state.sect.physiques_enabled or disciple.profile_seed <= 0:
        return {}
    return _ensure_profile(state, str(disciple.id), disciple.latent_identity_seed, disciple.recruitment_source)

func remove_profile(state: SimulationState, character_id: StringName) -> void:
    if state.sect.physique_profiles.erase(str(character_id)):
        state.sect.physique_event_count += 1

func profile_for(state: SimulationState, character_id: StringName) -> Dictionary:
    var raw = state.sect.physique_profiles.get(str(character_id), {})
    return raw if raw is Dictionary else {}

func physique_id(state: SimulationState, character_id: StringName) -> StringName:
    return StringName(profile_for(state, character_id).get("physique_id", "ordinary_body"))

func physique_name(id: StringName) -> String:
    return str(PHYSIQUE_NAMES.get(str(id), str(id)))

func temper_level(state: SimulationState, character_id: StringName) -> int:
    return clampi(int(profile_for(state, character_id).get("temper_level", 0)), 0, MAX_TEMPER_LEVEL)

func temper_body(state: SimulationState, disciple_id: StringName) -> Dictionary:
    if not state.sect.physiques_enabled or not state.disciples.has(disciple_id):
        return {"ok":false, "reason":"physiques_disabled_or_disciple_missing"}
    var disciple: DiscipleState = state.disciples[disciple_id]
    var profile := ensure_disciple_profile(state, disciple)
    if profile.is_empty():
        return {"ok":false, "reason":"profile_missing"}
    var level := clampi(int(profile.get("temper_level", 0)), 0, MAX_TEMPER_LEVEL)
    if level >= MAX_TEMPER_LEVEL:
        return {"ok":false, "reason":"max_temper_level"}
    if int(state.sect.technique_materials.get(TEMPER_MATERIAL_ID, 0)) <= 0:
        return {"ok":false, "reason":"yao_core_missing"}

    _consume_material(state, TEMPER_MATERIAL_ID, 1)
    profile["temper_level"] = level + 1
    state.sect.physique_profiles[str(disciple.id)] = profile
    state.sect.physique_event_count += 1
    disciple.metrics["physique_tempering"] = int(disciple.metrics.get("physique_tempering", 0)) + 1
    return {
        "ok":true,
        "reason":"tempered",
        "temper_level":int(profile["temper_level"]),
        "physique_id":str(profile.get("physique_id", "ordinary_body"))
    }

func can_transform(state: SimulationState, disciple_id: StringName) -> bool:
    if not state.sect.physiques_enabled or not state.disciples.has(disciple_id):
        return false
    var disciple: DiscipleState = state.disciples[disciple_id]
    var profile := ensure_disciple_profile(state, disciple)
    if profile.is_empty():
        return false
    if StringName(profile.get("physique_id", "ordinary_body")) != PHYSIQUE_ORDINARY:
        return false
    if int(profile.get("temper_level", 0)) < 3:
        return false
    var target := StringName(profile.get("latent_transformation", ""))
    if not SPECIAL_PHYSIQUES.has(target):
        return false
    return int(state.sect.technique_materials.get(TRANSFORM_MATERIAL_ID, 0)) >= TRANSFORM_MATERIAL_COST

func transform_body(state: SimulationState, disciple_id: StringName) -> Dictionary:
    if not state.sect.physiques_enabled or not state.disciples.has(disciple_id):
        return {"ok":false, "reason":"physiques_disabled_or_disciple_missing"}
    var disciple: DiscipleState = state.disciples[disciple_id]
    var profile := ensure_disciple_profile(state, disciple)
    if profile.is_empty():
        return {"ok":false, "reason":"profile_missing"}
    if StringName(profile.get("physique_id", "ordinary_body")) != PHYSIQUE_ORDINARY:
        return {"ok":false, "reason":"already_special_physique"}
    if int(profile.get("temper_level", 0)) < 3:
        return {"ok":false, "reason":"temper_level_too_low"}
    var target := StringName(profile.get("latent_transformation", ""))
    if not SPECIAL_PHYSIQUES.has(target):
        return {"ok":false, "reason":"transformation_target_missing"}
    if int(state.sect.technique_materials.get(TRANSFORM_MATERIAL_ID, 0)) < TRANSFORM_MATERIAL_COST:
        return {"ok":false, "reason":"spirit_essence_missing"}

    _consume_material(state, TRANSFORM_MATERIAL_ID, TRANSFORM_MATERIAL_COST)
    profile["physique_id"] = str(target)
    profile["transformed"] = true
    state.sect.physique_profiles[str(disciple.id)] = profile
    state.sect.physique_event_count += 1
    disciple.metrics["physique_transformations"] = int(disciple.metrics.get("physique_transformations", 0)) + 1
    return {
        "ok":true,
        "reason":"transformed",
        "physique_id":str(target),
        "physique_name":physique_name(target),
        "temper_level":int(profile.get("temper_level", 0))
    }

func stat_profile(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    var neutral := {
        "attack_bonus":0.0,
        "incoming_damage_multiplier":1.0,
        "cultivation_multiplier":1.0,
        "breakthrough_bonus":0.0,
        "recovery_multiplier":1.0,
        "sword_xp_multiplier":1.0,
        "body_xp_multiplier":1.0,
        "spell_xp_multiplier":1.0
    }
    if not state.sect.physiques_enabled or disciple.profile_seed <= 0:
        return neutral
    var profile := ensure_disciple_profile(state, disciple)
    if profile.is_empty():
        return neutral

    var id := StringName(profile.get("physique_id", "ordinary_body"))
    var level := clampi(int(profile.get("temper_level", 0)), 0, MAX_TEMPER_LEVEL)
    var scale := 1.0 + float(level) * 0.08
    var has_water := disciple.spiritual_root_elements.has("water")
    var has_fire := disciple.spiritual_root_elements.has("fire")

    match id:
        PHYSIQUE_ORDINARY:
            neutral["attack_bonus"] = 0.5 * float(level)
            neutral["incoming_damage_multiplier"] = clampf(1.0 - 0.01 * float(level), 0.94, 1.0)
            neutral["cultivation_multiplier"] = 1.0 + 0.01 * float(level)
            neutral["breakthrough_bonus"] = 0.001 * float(level)
            neutral["recovery_multiplier"] = 1.0 + 0.01 * float(level)
            neutral["sword_xp_multiplier"] = 1.0 + 0.01 * float(level)
            neutral["body_xp_multiplier"] = 1.0 + 0.01 * float(level)
            neutral["spell_xp_multiplier"] = 1.0 + 0.01 * float(level)
        PHYSIQUE_SWORD_BONE:
            neutral["attack_bonus"] = 4.0 * scale
            neutral["incoming_damage_multiplier"] = clampf(0.98 - 0.006 * float(level), 0.94, 0.98)
            neutral["cultivation_multiplier"] = 1.0 + 0.06 * scale
            neutral["breakthrough_bonus"] = 0.006 * scale
            neutral["recovery_multiplier"] = minf(1.0, 0.95 + 0.008 * float(level))
            neutral["sword_xp_multiplier"] = 1.0 + 0.25 * scale
        PHYSIQUE_DIAMOND_OVERLORD:
            neutral["attack_bonus"] = 3.5 * scale
            neutral["incoming_damage_multiplier"] = clampf(1.0 - 0.14 * scale, 0.76, 0.90)
            neutral["cultivation_multiplier"] = minf(0.98, 0.92 + 0.01 * float(level))
            neutral["breakthrough_bonus"] = 0.004 * scale
            neutral["recovery_multiplier"] = 1.0 + 0.15 * scale
            neutral["body_xp_multiplier"] = 1.0 + 0.35 * scale
        PHYSIQUE_COLD_YIN:
            if has_water:
                neutral["attack_bonus"] = 4.0 * scale
                neutral["incoming_damage_multiplier"] = clampf(1.0 - 0.10 * scale, 0.82, 0.92)
                neutral["cultivation_multiplier"] = 1.0 + 0.13 * scale
                neutral["breakthrough_bonus"] = 0.018 * scale
                neutral["recovery_multiplier"] = 1.0 + 0.08 * scale
                neutral["spell_xp_multiplier"] = 1.0 + 0.20 * scale
            else:
                neutral["attack_bonus"] = 1.5 * scale
                neutral["incoming_damage_multiplier"] = clampf(1.0 - 0.05 * scale, 0.90, 0.96)
                neutral["cultivation_multiplier"] = minf(0.99, 0.94 + 0.01 * float(level))
                neutral["recovery_multiplier"] = minf(0.97, 0.86 + 0.02 * float(level))
                neutral["spell_xp_multiplier"] = 1.0 + 0.08 * scale
        PHYSIQUE_FIRE_SPIRIT:
            if has_fire:
                neutral["attack_bonus"] = 7.0 * scale
                neutral["incoming_damage_multiplier"] = clampf(0.98 - 0.003 * float(level), 0.96, 0.98)
                neutral["cultivation_multiplier"] = 1.0 + 0.12 * scale
                neutral["breakthrough_bonus"] = 0.015 * scale
                neutral["recovery_multiplier"] = minf(1.0, 0.97 + 0.006 * float(level))
                neutral["spell_xp_multiplier"] = 1.0 + 0.22 * scale
            else:
                neutral["attack_bonus"] = 3.5 * scale
                neutral["cultivation_multiplier"] = 1.0 + 0.04 * scale
                neutral["breakthrough_bonus"] = 0.004 * scale
                neutral["recovery_multiplier"] = minf(0.99, 0.94 + 0.008 * float(level))
                neutral["spell_xp_multiplier"] = 1.0 + 0.10 * scale
        PHYSIQUE_PURE_DAO:
            neutral["attack_bonus"] = 5.0 * scale
            neutral["incoming_damage_multiplier"] = clampf(1.0 - 0.10 * scale, 0.82, 0.92)
            neutral["cultivation_multiplier"] = 1.0 + 0.16 * scale
            neutral["breakthrough_bonus"] = 0.025 * scale
            neutral["recovery_multiplier"] = 1.0 + 0.12 * scale
            neutral["sword_xp_multiplier"] = 1.0 + 0.18 * scale
            neutral["body_xp_multiplier"] = 1.0 + 0.18 * scale
            neutral["spell_xp_multiplier"] = 1.0 + 0.18 * scale
        _:
            pass
    return neutral

func combat_power_bonus(state: SimulationState, disciple: DiscipleState) -> float:
    return float(stat_profile(state, disciple).get("attack_bonus", 0.0))

func incoming_damage_multiplier(state: SimulationState, disciple: DiscipleState) -> float:
    return float(stat_profile(state, disciple).get("incoming_damage_multiplier", 1.0))

func cultivation_multiplier(state: SimulationState, disciple: DiscipleState) -> float:
    return float(stat_profile(state, disciple).get("cultivation_multiplier", 1.0))

func breakthrough_bonus(state: SimulationState, disciple: DiscipleState) -> float:
    return float(stat_profile(state, disciple).get("breakthrough_bonus", 0.0))

func recovery_multiplier(state: SimulationState, disciple: DiscipleState) -> float:
    return float(stat_profile(state, disciple).get("recovery_multiplier", 1.0))

func path_xp_multiplier(state: SimulationState, disciple: DiscipleState, path_id: StringName) -> float:
    var stats := stat_profile(state, disciple)
    match str(path_id):
        "sword":
            return float(stats.get("sword_xp_multiplier", 1.0))
        "body":
            return float(stats.get("body_xp_multiplier", 1.0))
        "spell":
            return float(stats.get("spell_xp_multiplier", 1.0))
        _:
            return 1.0

func validate_invariants(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if not state.sect.physiques_enabled:
        return errors

    var profile_ids: Array = state.sect.physique_profiles.keys()
    profile_ids.sort()
    for raw_id in profile_ids:
        var owner_id := StringName(raw_id)
        if not state.disciples.has(owner_id) and not state.recruitment_candidates.has(owner_id):
            errors.append("Physique profile %s has no candidate/disciple owner." % owner_id)
            continue
        var profile = state.sect.physique_profiles[raw_id]
        if not (profile is Dictionary) or not bool(profile.get("initialized", false)):
            errors.append("Physique profile %s is invalid/uninitialized." % owner_id)
            continue
        var id := StringName(profile.get("physique_id", "ordinary_body"))
        if not VALID_PHYSIQUES.has(id):
            errors.append("Physique profile %s has invalid physique id %s." % [owner_id, id])
        var initial_id := StringName(profile.get("initial_physique_id", "ordinary_body"))
        if not VALID_PHYSIQUES.has(initial_id):
            errors.append("Physique profile %s has invalid initial physique id." % owner_id)
        var level := int(profile.get("temper_level", 0))
        if level < 0 or level > MAX_TEMPER_LEVEL:
            errors.append("Physique profile %s has invalid temper level." % owner_id)
        var latent := StringName(profile.get("latent_transformation", ""))
        if initial_id == PHYSIQUE_ORDINARY and not SPECIAL_PHYSIQUES.has(latent):
            errors.append("Ordinary physique profile %s has no deterministic transformation route." % owner_id)
        if bool(profile.get("transformed", false)) and initial_id != PHYSIQUE_ORDINARY:
            errors.append("Physique profile %s claims transformation despite special innate body." % owner_id)
    if state.sect.physique_event_count < 0:
        errors.append("Physique event count cannot be negative.")
    return errors

func _ensure_profile(state: SimulationState, character_id: String, latent_seed: int, source: StringName) -> Dictionary:
    var existing = state.sect.physique_profiles.get(character_id, {})
    if existing is Dictionary and bool(existing.get("initialized", false)):
        return existing

    var seed_value := latent_seed if latent_seed > 0 else _stable_hash(character_id)
    var rng := GameRng.new(seed_value + PROFILE_SEED_OFFSET)
    var special_chance := 0.15
    if source == DiscipleGeneratorV2.SOURCE_GACHA:
        special_chance = 0.28
    elif source == DiscipleGeneratorV2.SOURCE_FATE:
        special_chance = 0.40

    var id := PHYSIQUE_ORDINARY
    if rng.randf_range(0.0, 1.0) < special_chance:
        id = _roll_innate_physique(rng, source)

    var latent := ""
    if id == PHYSIQUE_ORDINARY:
        latent = str(_roll_latent_transformation(rng, source))

    var profile := {
        "initialized":true,
        "physique_id":str(id),
        "initial_physique_id":str(id),
        "temper_level":0,
        "transformed":false,
        "latent_transformation":latent
    }
    state.sect.physique_profiles[character_id] = profile
    state.sect.physique_event_count += 1
    return profile

func _roll_innate_physique(rng: GameRng, source: StringName) -> StringName:
    var roll := rng.randf_range(0.0, 100.0)
    var pure_dao_threshold := 96.0
    if source == DiscipleGeneratorV2.SOURCE_GACHA:
        pure_dao_threshold = 93.0
    elif source == DiscipleGeneratorV2.SOURCE_FATE:
        pure_dao_threshold = 88.0
    if roll >= pure_dao_threshold:
        return PHYSIQUE_PURE_DAO
    if roll < 24.0:
        return PHYSIQUE_SWORD_BONE
    if roll < 48.0:
        return PHYSIQUE_DIAMOND_OVERLORD
    if roll < 72.0:
        return PHYSIQUE_COLD_YIN
    return PHYSIQUE_FIRE_SPIRIT

func _roll_latent_transformation(rng: GameRng, source: StringName) -> StringName:
    var roll := rng.randf_range(0.0, 100.0)
    var pure_dao_threshold := 99.0
    if source == DiscipleGeneratorV2.SOURCE_GACHA:
        pure_dao_threshold = 97.0
    elif source == DiscipleGeneratorV2.SOURCE_FATE:
        pure_dao_threshold = 94.0
    if roll >= pure_dao_threshold:
        return PHYSIQUE_PURE_DAO
    var common_roll := rng.randi_range(0, 3)
    match common_roll:
        0:
            return PHYSIQUE_SWORD_BONE
        1:
            return PHYSIQUE_DIAMOND_OVERLORD
        2:
            return PHYSIQUE_COLD_YIN
        _:
            return PHYSIQUE_FIRE_SPIRIT

func _consume_material(state: SimulationState, material_id: String, quantity: int) -> void:
    var next_amount := int(state.sect.technique_materials.get(material_id, 0)) - quantity
    if next_amount <= 0:
        state.sect.technique_materials.erase(material_id)
    else:
        state.sect.technique_materials[material_id] = next_amount

func _stable_hash(value: String) -> int:
    var result := 17
    for index in range(value.length()):
        result = int((result * 131 + value.unicode_at(index)) % 2147483629)
    return maxi(result, 1)
