class_name SpiritualRootSystem
extends RefCounted

const QUALITY_MIXED := &"mixed"
const QUALITY_ORDINARY := &"ordinary"
const QUALITY_EARTH := &"earth"
const QUALITY_HEAVEN := &"heaven"
const VALID_QUALITIES := [QUALITY_MIXED, QUALITY_ORDINARY, QUALITY_EARTH, QUALITY_HEAVEN]

const QUALITY_DEFINITIONS := {
    "mixed": {
        "name": "Tạp linh căn",
        "cultivation_multiplier": 0.75,
        "breakthrough_modifier": -0.08,
        "weight": 45.0
    },
    "ordinary": {
        "name": "Phàm linh căn",
        "cultivation_multiplier": 1.00,
        "breakthrough_modifier": 0.00,
        "weight": 38.0
    },
    "earth": {
        "name": "Địa linh căn",
        "cultivation_multiplier": 1.20,
        "breakthrough_modifier": 0.05,
        "weight": 14.0
    },
    "heaven": {
        "name": "Thiên linh căn",
        "cultivation_multiplier": 1.45,
        "breakthrough_modifier": 0.10,
        "weight": 3.0
    }
}

const ROOT_SEED_OFFSET := 23891
const ROOT_SALT_MULTIPLIER := 104729
const HASH_MODULUS := 2147483629

func initialize(state: SimulationState) -> void:
    if not state.sect.cultivation_enabled:
        return
    state.sect.spiritual_roots_enabled = true

    var disciple_ids: Array = state.disciples.keys()
    disciple_ids.sort()
    for raw_id in disciple_ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        ensure_disciple_root(state, disciple)

    var candidate_ids: Array = state.recruitment_candidates.keys()
    candidate_ids.sort()
    for raw_id in candidate_ids:
        var candidate: CandidateState = state.recruitment_candidates[raw_id]
        ensure_candidate_root(state, candidate)

func ensure_disciple_root(state: SimulationState, disciple: DiscipleState) -> StringName:
    if not state.sect.spiritual_roots_enabled:
        return disciple.spiritual_root_quality
    if VALID_QUALITIES.has(disciple.spiritual_root_quality):
        return disciple.spiritual_root_quality

    disciple.spiritual_root_quality = quality_for_identity(state.seed, str(disciple.id), 0)
    state.sect.spiritual_root_event_count += 1
    return disciple.spiritual_root_quality

func ensure_candidate_root(state: SimulationState, candidate: CandidateState) -> StringName:
    if not state.sect.spiritual_roots_enabled:
        return candidate.spiritual_root_quality
    if VALID_QUALITIES.has(candidate.spiritual_root_quality):
        return candidate.spiritual_root_quality

    candidate.spiritual_root_quality = quality_for_identity(state.seed, str(candidate.id), candidate.generated_index)
    state.sect.spiritual_root_event_count += 1
    return candidate.spiritual_root_quality

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

func definition(quality: StringName) -> Dictionary:
    return QUALITY_DEFINITIONS.get(str(quality), QUALITY_DEFINITIONS["ordinary"])

func quality_name(quality: StringName) -> String:
    return str(definition(quality).get("name", "Phàm linh căn"))

func cultivation_multiplier(quality: StringName) -> float:
    return float(definition(quality).get("cultivation_multiplier", 1.0))

func breakthrough_modifier(quality: StringName) -> float:
    return float(definition(quality).get("breakthrough_modifier", 0.0))

func validate_invariants(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if not state.sect.spiritual_roots_enabled:
        return errors

    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        if not VALID_QUALITIES.has(disciple.spiritual_root_quality):
            errors.append("%s has invalid spiritual root quality %s." % [disciple.display_name, disciple.spiritual_root_quality])

    for candidate_value in state.recruitment_candidates.values():
        var candidate: CandidateState = candidate_value
        if not VALID_QUALITIES.has(candidate.spiritual_root_quality):
            errors.append("Candidate %s has invalid spiritual root quality %s." % [candidate.display_name, candidate.spiritual_root_quality])

    if state.sect.spiritual_root_event_count < 0:
        errors.append("Spiritual root event count cannot be negative.")
    return errors

func _root_seed(base_seed: int, stable_id: String, salt: int) -> int:
    var hash_value := 17
    for index in range(stable_id.length()):
        hash_value = int((hash_value * 131 + stable_id.unicode_at(index)) % HASH_MODULUS)
    return base_seed + hash_value * 17 + salt * ROOT_SALT_MULTIPLIER + ROOT_SEED_OFFSET
