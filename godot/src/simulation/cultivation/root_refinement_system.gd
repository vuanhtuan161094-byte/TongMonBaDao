class_name RootRefinementSystem
extends RefCounted

const MATERIAL_ID := "linh_tuy"
const MAX_PURITY := 0.98
const MUTATION_NONE := &"none"
const MUTATION_METAL := &"canh_kim_di_can"
const MUTATION_WOOD := &"thanh_moc_di_can"
const MUTATION_WATER := &"han_thuy_di_can"
const MUTATION_FIRE := &"xich_viem_di_can"
const MUTATION_EARTH := &"hau_tho_di_can"
const VALID_MUTATIONS := [MUTATION_NONE, MUTATION_METAL, MUTATION_WOOD, MUTATION_WATER, MUTATION_FIRE, MUTATION_EARTH]
const MUTATION_NAMES := {
    "none": "Không",
    "canh_kim_di_can": "Canh Kim Dị Căn",
    "thanh_moc_di_can": "Thanh Mộc Dị Căn",
    "han_thuy_di_can": "Hàn Thủy Dị Căn",
    "xich_viem_di_can": "Xích Viêm Dị Căn",
    "hau_tho_di_can": "Hậu Thổ Dị Căn"
}
const MUTATION_ELEMENT := {
    "canh_kim_di_can": "metal",
    "thanh_moc_di_can": "wood",
    "han_thuy_di_can": "water",
    "xich_viem_di_can": "fire",
    "hau_tho_di_can": "earth"
}
const PROFILE_SEED_OFFSET := 163841

func initialize(state: SimulationState) -> void:
    if not state.sect.disciple_generation_v2_enabled or not state.sect.spiritual_roots_enabled:
        return
    state.sect.spiritual_root_refinement_enabled = true
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
    if not state.sect.spiritual_root_refinement_enabled or candidate.profile_seed <= 0:
        return {}
    return _ensure_profile(state, str(candidate.id), candidate.latent_identity_seed, candidate.recruitment_source, candidate.spiritual_root_elements)

func ensure_disciple_profile(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    if not state.sect.spiritual_root_refinement_enabled or disciple.profile_seed <= 0:
        return {}
    return _ensure_profile(state, str(disciple.id), disciple.latent_identity_seed, disciple.recruitment_source, disciple.spiritual_root_elements)

func remove_profile(state: SimulationState, character_id: StringName) -> void:
    if state.sect.spiritual_root_profiles.erase(str(character_id)):
        state.sect.spiritual_root_refinement_event_count += 1

func profile_for(state: SimulationState, character_id: StringName) -> Dictionary:
    var raw = state.sect.spiritual_root_profiles.get(str(character_id), {})
    return raw if raw is Dictionary else {}

func refinement_count(state: SimulationState, character_id: StringName) -> int:
    return maxi(int(profile_for(state, character_id).get("refinement_count", 0)), 0)

func revealed_mutation(state: SimulationState, character_id: StringName) -> StringName:
    return StringName(profile_for(state, character_id).get("revealed_mutation", ""))

func mutation_name(mutation_id: StringName) -> String:
    return str(MUTATION_NAMES.get(str(mutation_id), str(mutation_id)))

func mutation_element(mutation_id: StringName) -> StringName:
    return StringName(MUTATION_ELEMENT.get(str(mutation_id), ""))

func can_refine(state: SimulationState, disciple: DiscipleState) -> bool:
    if not state.sect.spiritual_root_refinement_enabled or disciple.profile_seed <= 0:
        return false
    if disciple.spiritual_root_purity >= MAX_PURITY - 0.000001:
        return false
    return int(state.sect.technique_materials.get(MATERIAL_ID, 0)) > 0

func refine_disciple(state: SimulationState, disciple_id: StringName) -> Dictionary:
    if not state.disciples.has(disciple_id):
        return {"ok":false, "reason":"disciple_missing"}
    var disciple: DiscipleState = state.disciples[disciple_id]
    if not state.sect.spiritual_root_refinement_enabled or disciple.profile_seed <= 0:
        return {"ok":false, "reason":"refinement_disabled"}
    if disciple.spiritual_root_purity >= MAX_PURITY - 0.000001:
        return {"ok":false, "reason":"max_purity"}
    if int(state.sect.technique_materials.get(MATERIAL_ID, 0)) <= 0:
        return {"ok":false, "reason":"linh_tuy_missing"}

    var profile := ensure_disciple_profile(state, disciple)
    if profile.is_empty():
        return {"ok":false, "reason":"profile_missing"}
    state.sect.technique_materials[MATERIAL_ID] = int(state.sect.technique_materials.get(MATERIAL_ID, 0)) - 1
    if int(state.sect.technique_materials[MATERIAL_ID]) <= 0:
        state.sect.technique_materials.erase(MATERIAL_ID)

    var before := clampf(disciple.spiritual_root_purity, 0.0, MAX_PURITY)
    var gain := _refinement_gain(disciple, before)
    disciple.spiritual_root_purity = minf(MAX_PURITY, before + gain)
    disciple.spiritual_root_quality = SpiritualRootSystem.new().quality_for_purity(disciple.spiritual_root_purity)
    profile["refinement_count"] = int(profile.get("refinement_count", 0)) + 1
    state.sect.spiritual_root_profiles[str(disciple.id)] = profile
    state.sect.spiritual_root_refinement_event_count += 1
    state.sect.spiritual_root_event_count += 1

    var mutation_result := _try_reveal_mutation(state, disciple, profile)
    return {
        "ok":true,
        "reason":"refined",
        "purity_before":before,
        "purity_after":disciple.spiritual_root_purity,
        "quality":str(disciple.spiritual_root_quality),
        "refinement_count":int(profile.get("refinement_count", 0)),
        "mutation_revealed":str(mutation_result)
    }

func cultivation_multiplier(state: SimulationState, disciple: DiscipleState) -> float:
    var purity := clampf(disciple.spiritual_root_purity, 0.0, 1.0)
    var result := lerpf(0.76, 1.48, purity)
    if revealed_mutation(state, disciple.id) != &"":
        result *= 1.04
    return result

func breakthrough_modifier(state: SimulationState, disciple: DiscipleState) -> float:
    var purity := clampf(disciple.spiritual_root_purity, 0.0, 1.0)
    var result := lerpf(-0.08, 0.10, purity)
    if revealed_mutation(state, disciple.id) != &"":
        result += 0.015
    return result

func technique_mastery_multiplier(state: SimulationState, disciple: DiscipleState, element: StringName) -> float:
    if element == &"":
        return 1.0
    if not disciple.spiritual_root_elements.has(str(element)):
        return 0.90
    var purity := clampf(disciple.spiritual_root_purity, 0.0, 1.0)
    var result := 1.0 + purity * 0.12 + _concentration_bonus(disciple)
    if mutation_element(revealed_mutation(state, disciple.id)) == element:
        result += 0.07
    return result

func technique_effect_multiplier(state: SimulationState, disciple: DiscipleState, element: StringName) -> float:
    if element == &"":
        return 1.0
    if not disciple.spiritual_root_elements.has(str(element)):
        return 0.92
    var purity := clampf(disciple.spiritual_root_purity, 0.0, 1.0)
    var result := 1.0 + purity * 0.10 + _concentration_bonus(disciple)
    if mutation_element(revealed_mutation(state, disciple.id)) == element:
        result += 0.06
    return result

func validate_invariants(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if not state.sect.spiritual_root_refinement_enabled:
        return errors
    var profile_ids: Array = state.sect.spiritual_root_profiles.keys()
    profile_ids.sort()
    for raw_id in profile_ids:
        var owner_id := StringName(raw_id)
        if not state.disciples.has(owner_id) and not state.recruitment_candidates.has(owner_id):
            errors.append("Root profile %s has no candidate/disciple owner." % owner_id)
            continue
        var profile = state.sect.spiritual_root_profiles[raw_id]
        if not (profile is Dictionary) or not bool(profile.get("initialized", false)):
            errors.append("Root profile %s is invalid/uninitialized." % owner_id)
            continue
        var latent := StringName(profile.get("latent_mutation", "none"))
        var revealed := StringName(profile.get("revealed_mutation", ""))
        if not VALID_MUTATIONS.has(latent):
            errors.append("Root profile %s has invalid latent mutation." % owner_id)
        if revealed != &"" and (not VALID_MUTATIONS.has(revealed) or revealed != latent):
            errors.append("Root profile %s has invalid revealed mutation." % owner_id)
        if int(profile.get("refinement_count", 0)) < 0:
            errors.append("Root profile %s has negative refinement count." % owner_id)
    if state.sect.spiritual_root_refinement_event_count < 0:
        errors.append("Spiritual root refinement event count cannot be negative.")
    return errors

func _ensure_profile(state: SimulationState, character_id: String, latent_seed: int, source: StringName, elements: Array) -> Dictionary:
    var existing = state.sect.spiritual_root_profiles.get(character_id, {})
    if existing is Dictionary and bool(existing.get("initialized", false)):
        return existing
    var seed_value := latent_seed if latent_seed > 0 else _stable_hash(character_id)
    var rng := GameRng.new(seed_value + PROFILE_SEED_OFFSET)
    var chance := 0.18
    if source == DiscipleGeneratorV2.SOURCE_GACHA:
        chance = 0.28
    elif source == DiscipleGeneratorV2.SOURCE_FATE:
        chance = 0.42
    var latent := MUTATION_NONE
    if not elements.is_empty() and rng.randf_range(0.0, 1.0) < chance:
        var chosen := StringName(elements[rng.randi_range(0, elements.size() - 1)])
        latent = _mutation_for_element(chosen)
    var profile := {
        "initialized":true,
        "refinement_count":0,
        "latent_mutation":str(latent),
        "revealed_mutation":""
    }
    state.sect.spiritual_root_profiles[character_id] = profile
    state.sect.spiritual_root_refinement_event_count += 1
    return profile

func _try_reveal_mutation(state: SimulationState, disciple: DiscipleState, profile: Dictionary) -> StringName:
    var latent := StringName(profile.get("latent_mutation", "none"))
    if latent == MUTATION_NONE or StringName(profile.get("revealed_mutation", "")) != &"":
        return &""
    if int(profile.get("refinement_count", 0)) < 3 or disciple.spiritual_root_purity < 0.72:
        return &""
    profile["revealed_mutation"] = str(latent)
    state.sect.spiritual_root_profiles[str(disciple.id)] = profile
    state.sect.spiritual_root_refinement_event_count += 1
    disciple.metrics["root_mutations_revealed"] = int(disciple.metrics.get("root_mutations_revealed", 0)) + 1
    return latent

func _refinement_gain(disciple: DiscipleState, purity: float) -> float:
    var foundation := 0.025 + clampf(disciple.potential, 0.0, 1.0) * 0.025
    var diminishing := lerpf(1.0, 0.45, clampf(purity, 0.0, 1.0))
    return maxf(foundation * diminishing, 0.008)

func _concentration_bonus(disciple: DiscipleState) -> float:
    var count := clampi(disciple.spiritual_root_elements.size(), 1, 5)
    return float(maxi(4 - count, 0)) * 0.02

func _mutation_for_element(element: StringName) -> StringName:
    match element:
        SpiritualRootSystem.ELEMENT_METAL:
            return MUTATION_METAL
        SpiritualRootSystem.ELEMENT_WOOD:
            return MUTATION_WOOD
        SpiritualRootSystem.ELEMENT_WATER:
            return MUTATION_WATER
        SpiritualRootSystem.ELEMENT_FIRE:
            return MUTATION_FIRE
        SpiritualRootSystem.ELEMENT_EARTH:
            return MUTATION_EARTH
        _:
            return MUTATION_NONE

func _stable_hash(value: String) -> int:
    var result := 17
    for index in range(value.length()):
        result = int((result * 131 + value.unicode_at(index)) % 2147483629)
    return maxi(result, 1)
