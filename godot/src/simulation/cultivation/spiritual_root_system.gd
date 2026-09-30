class_name SpiritualRootSystem
extends RefCounted

const QUALITY_MIXED := &"mixed"
const QUALITY_ORDINARY := &"ordinary"
const QUALITY_EARTH := &"earth"
const QUALITY_HEAVEN := &"heaven"
const VALID_QUALITIES := [QUALITY_MIXED, QUALITY_ORDINARY, QUALITY_EARTH, QUALITY_HEAVEN]

const ELEMENT_METAL := &"metal"
const ELEMENT_WOOD := &"wood"
const ELEMENT_WATER := &"water"
const ELEMENT_FIRE := &"fire"
const ELEMENT_EARTH := &"earth"
const VALID_ELEMENTS := [ELEMENT_METAL, ELEMENT_WOOD, ELEMENT_WATER, ELEMENT_FIRE, ELEMENT_EARTH]
const ELEMENT_NAMES := {
    "metal": "Kim",
    "wood": "Mộc",
    "water": "Thủy",
    "fire": "Hỏa",
    "earth": "Thổ"
}

const QUALITY_DEFINITIONS := {
    "mixed": {"name":"Tạp linh căn", "cultivation_multiplier":0.75, "breakthrough_modifier":-0.08, "weight":45.0, "element_count":3},
    "ordinary": {"name":"Phàm linh căn", "cultivation_multiplier":1.00, "breakthrough_modifier":0.00, "weight":38.0, "element_count":2},
    "earth": {"name":"Địa linh căn", "cultivation_multiplier":1.20, "breakthrough_modifier":0.05, "weight":14.0, "element_count":1},
    "heaven": {"name":"Thiên linh căn", "cultivation_multiplier":1.45, "breakthrough_modifier":0.10, "weight":3.0, "element_count":1}
}

const ROOT_SEED_OFFSET := 23891
const ELEMENT_SEED_OFFSET := 77171
const ROOT_SALT_MULTIPLIER := 104729
const HASH_MODULUS := 2147483629

func initialize(state: SimulationState) -> void:
    if not state.sect.cultivation_enabled:
        return
    state.sect.spiritual_roots_enabled = true
    var disciple_ids: Array = state.disciples.keys()
    disciple_ids.sort()
    for raw_id in disciple_ids:
        ensure_disciple_root(state, state.disciples[raw_id])
    var candidate_ids: Array = state.recruitment_candidates.keys()
    candidate_ids.sort()
    for raw_id in candidate_ids:
        ensure_candidate_root(state, state.recruitment_candidates[raw_id])

func ensure_disciple_root(state: SimulationState, disciple: DiscipleState) -> StringName:
    if not state.sect.spiritual_roots_enabled:
        return disciple.spiritual_root_quality
    if not VALID_QUALITIES.has(disciple.spiritual_root_quality):
        disciple.spiritual_root_quality = quality_for_identity(state.seed, str(disciple.id), 0)
        state.sect.spiritual_root_event_count += 1
    if state.sect.techniques_enabled:
        ensure_disciple_elements(state, disciple)
    return disciple.spiritual_root_quality

func ensure_candidate_root(state: SimulationState, candidate: CandidateState) -> StringName:
    if not state.sect.spiritual_roots_enabled:
        return candidate.spiritual_root_quality
    if not VALID_QUALITIES.has(candidate.spiritual_root_quality):
        candidate.spiritual_root_quality = quality_for_identity(state.seed, str(candidate.id), candidate.generated_index)
        state.sect.spiritual_root_event_count += 1
    if state.sect.techniques_enabled:
        ensure_candidate_elements(state, candidate)
    return candidate.spiritual_root_quality

func ensure_disciple_elements(state: SimulationState, disciple: DiscipleState) -> Array:
    if not state.sect.techniques_enabled:
        return disciple.spiritual_root_elements
    if _valid_elements(disciple.spiritual_root_elements):
        return disciple.spiritual_root_elements
    disciple.spiritual_root_elements = elements_for_identity(state.seed, str(disciple.id), 0, disciple.spiritual_root_quality)
    state.sect.spiritual_root_event_count += 1
    return disciple.spiritual_root_elements

func ensure_candidate_elements(state: SimulationState, candidate: CandidateState) -> Array:
    if not state.sect.techniques_enabled:
        return candidate.spiritual_root_elements
    if _valid_elements(candidate.spiritual_root_elements):
        return candidate.spiritual_root_elements
    candidate.spiritual_root_elements = elements_for_identity(state.seed, str(candidate.id), candidate.generated_index, candidate.spiritual_root_quality)
    state.sect.spiritual_root_event_count += 1
    return candidate.spiritual_root_elements

func quality_for_identity(base_seed: int, stable_id: String, salt: int = 0) -> StringName:
    var rng := GameRng.new(_root_seed(base_seed, stable_id, salt))
    var total_weight := 0.0
    for quality in VALID_QUALITIES:
        total_weight += float(definition(quality).get("weight", 0.0))
    var roll := rng.randf_range(0.0, total_weight)
    var cursor := 0.0
    for quality in VALID_QUALITIES:
        cursor += float(definition(quality).get("weight", 0.0))
        if roll <= cursor:
            return quality
    return QUALITY_ORDINARY

func elements_for_identity(base_seed: int, stable_id: String, salt: int, quality: StringName) -> Array:
    var rng := GameRng.new(_element_seed(base_seed, stable_id, salt))
    var pool: Array = []
    for element in VALID_ELEMENTS:
        pool.append(str(element))
    var count := clampi(int(definition(quality).get("element_count", 2)), 1, pool.size())
    var result: Array = []
    while result.size() < count and not pool.is_empty():
        var index := rng.randi_range(0, pool.size() - 1)
        result.append(pool[index])
        pool.remove_at(index)
    result.sort()
    return result

func definition(quality: StringName) -> Dictionary:
    return QUALITY_DEFINITIONS.get(str(quality), QUALITY_DEFINITIONS["ordinary"])

func quality_name(quality: StringName) -> String:
    return str(definition(quality).get("name", "Phàm linh căn"))

func element_name(element: StringName) -> String:
    return str(ELEMENT_NAMES.get(str(element), str(element)))

func cultivation_multiplier(quality: StringName) -> float:
    return float(definition(quality).get("cultivation_multiplier", 1.0))

func breakthrough_modifier(quality: StringName) -> float:
    return float(definition(quality).get("breakthrough_modifier", 0.0))

func technique_mastery_multiplier(disciple: DiscipleState, element: StringName) -> float:
    if element == &"":
        return 1.0
    return 1.15 if disciple.spiritual_root_elements.has(str(element)) else 0.90

func technique_effect_multiplier(disciple: DiscipleState, element: StringName) -> float:
    if element == &"":
        return 1.0
    if not disciple.spiritual_root_elements.has(str(element)):
        return 0.92
    match disciple.spiritual_root_quality:
        QUALITY_HEAVEN:
            return 1.15
        QUALITY_EARTH:
            return 1.12
        QUALITY_ORDINARY:
            return 1.08
        QUALITY_MIXED:
            return 1.05
        _:
            return 1.05

func validate_invariants(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if not state.sect.spiritual_roots_enabled:
        return errors
    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        if not VALID_QUALITIES.has(disciple.spiritual_root_quality):
            errors.append("%s has invalid spiritual root quality %s." % [disciple.display_name, disciple.spiritual_root_quality])
        if state.sect.techniques_enabled and not _valid_elements(disciple.spiritual_root_elements):
            errors.append("%s has invalid spiritual root elements." % disciple.display_name)
    for candidate_value in state.recruitment_candidates.values():
        var candidate: CandidateState = candidate_value
        if not VALID_QUALITIES.has(candidate.spiritual_root_quality):
            errors.append("Candidate %s has invalid spiritual root quality %s." % [candidate.display_name, candidate.spiritual_root_quality])
        if state.sect.techniques_enabled and not _valid_elements(candidate.spiritual_root_elements):
            errors.append("Candidate %s has invalid spiritual root elements." % candidate.display_name)
    if state.sect.spiritual_root_event_count < 0:
        errors.append("Spiritual root event count cannot be negative.")
    return errors

func _valid_elements(value: Array) -> bool:
    if value.is_empty():
        return false
    var seen: Dictionary = {}
    for raw in value:
        var element := StringName(raw)
        if not VALID_ELEMENTS.has(element) or seen.has(str(element)):
            return false
        seen[str(element)] = true
    return true

func _root_seed(base_seed: int, stable_id: String, salt: int) -> int:
    return base_seed + _stable_hash(stable_id) * 17 + salt * ROOT_SALT_MULTIPLIER + ROOT_SEED_OFFSET

func _element_seed(base_seed: int, stable_id: String, salt: int) -> int:
    return base_seed + _stable_hash(stable_id) * 31 + salt * ROOT_SALT_MULTIPLIER + ELEMENT_SEED_OFFSET

func _stable_hash(value: String) -> int:
    var result := 17
    for index in range(value.length()):
        result = int((result * 131 + value.unicode_at(index)) % HASH_MODULUS)
    return result
