class_name CultivationPathSystem
extends RefCounted

const PATH_SWORD := &"sword"
const PATH_BODY := &"body"
const PATH_SPELL := &"spell"
const VALID_PATHS := [PATH_SWORD, PATH_BODY, PATH_SPELL]

const CULTIVATION_XP := 10.0
const COMBAT_WIN_XP := 4.0
const COMBAT_OTHER_XP := 1.0
const DEPTH_XP := 1200.0
const IDENTITY_MIN_XP := 100.0
const PRIMARY_SHARE := 0.65
const MIXED_SHARE := 0.25

const PATH_NAMES := {
    "sword": "Kiếm",
    "body": "Thể",
    "spell": "Pháp"
}

var physique_system := PhysiqueSystem.new()

func initialize(state: SimulationState) -> void:
    if not state.sect.techniques_enabled:
        return
    state.sect.cultivation_paths_enabled = true
    for disciple_value in state.disciples.values():
        _normalize_disciple(disciple_value)

func add_experience(state: SimulationState, disciple: DiscipleState, path_id: StringName, amount: float) -> float:
    if not state.sect.cultivation_paths_enabled or not VALID_PATHS.has(path_id) or amount <= 0.0:
        return 0.0
    var effective_amount := amount
    if state.sect.physiques_enabled:
        effective_amount *= physique_system.path_xp_multiplier(state, disciple, path_id)
    var key := str(path_id)
    var before := float(disciple.cultivation_path_xp.get(key, 0.0))
    disciple.cultivation_path_xp[key] = before + effective_amount
    state.sect.cultivation_path_event_count += 1
    return effective_amount

func record_cultivation(state: SimulationState, disciple: DiscipleState) -> float:
    var path_id := active_technique_path(disciple)
    if path_id == &"":
        return 0.0
    return add_experience(state, disciple, path_id, CULTIVATION_XP)

func record_combat(state: SimulationState, disciple: DiscipleState, outcome: String) -> float:
    var path_id := active_technique_path(disciple)
    if path_id == &"":
        return 0.0
    var amount := COMBAT_WIN_XP if outcome == "win" else COMBAT_OTHER_XP
    return add_experience(state, disciple, path_id, amount)

func active_technique_path(disciple: DiscipleState) -> StringName:
    if disciple.active_technique_id == &"" or not disciple.learned_techniques.has(str(disciple.active_technique_id)):
        return &""
    var info: Dictionary = TechniqueSystem.TECHNIQUES.get(str(disciple.active_technique_id), {})
    var path_id := StringName(info.get("path", ""))
    return path_id if VALID_PATHS.has(path_id) else &""

func path_xp(disciple: DiscipleState, path_id: StringName) -> float:
    return maxf(float(disciple.cultivation_path_xp.get(str(path_id), 0.0)), 0.0)

func depth(disciple: DiscipleState, path_id: StringName) -> float:
    return clampf(path_xp(disciple, path_id) / DEPTH_XP, 0.0, 1.0)

func technique_effect_multiplier(state: SimulationState, disciple: DiscipleState, technique_path: StringName) -> float:
    if not state.sect.cultivation_paths_enabled or not VALID_PATHS.has(technique_path):
        return 1.0
    return 1.0 + 0.20 * depth(disciple, technique_path)

func intrinsic_combat_bonus(state: SimulationState, disciple: DiscipleState) -> float:
    if not state.sect.cultivation_paths_enabled:
        return 0.0
    return 4.0 * depth(disciple, PATH_SWORD)

func incoming_damage_multiplier(state: SimulationState, disciple: DiscipleState) -> float:
    if not state.sect.cultivation_paths_enabled:
        return 1.0
    return clampf(1.0 - 0.12 * depth(disciple, PATH_BODY), 0.88, 1.0)

func cultivation_gain_multiplier(state: SimulationState, disciple: DiscipleState) -> float:
    if not state.sect.cultivation_paths_enabled:
        return 1.0
    return 1.0 + 0.12 * depth(disciple, PATH_SPELL)

func apply_action_modifiers(state: SimulationState, disciple: DiscipleState, scores: Dictionary) -> void:
    if not state.sect.cultivation_paths_enabled:
        return
    scores["HUNT"] = float(scores.get("HUNT", 0.0)) + 18.0 * depth(disciple, PATH_SWORD) + 5.0 * depth(disciple, PATH_BODY)
    scores["CULTIVATE"] = float(scores.get("CULTIVATE", 0.0)) + 18.0 * depth(disciple, PATH_SPELL)
    scores["REST"] = float(scores.get("REST", 0.0)) + 5.0 * depth(disciple, PATH_BODY)

func identity_label(disciple: DiscipleState) -> String:
    var rows: Array = []
    var total := 0.0
    for path_id in VALID_PATHS:
        var xp := path_xp(disciple, path_id)
        total += xp
        rows.append({"path": path_id, "xp": xp})
    if total < IDENTITY_MIN_XP:
        return "Chưa định hình"
    rows.sort_custom(func(a, b): return float(a["xp"]) > float(b["xp"]))
    var first: Dictionary = rows[0]
    var second: Dictionary = rows[1]
    var first_share := float(first["xp"]) / total
    var second_share := float(second["xp"]) / total
    if first_share >= PRIMARY_SHARE:
        return "%s tu" % path_name(StringName(first["path"]))
    if second_share >= MIXED_SHARE:
        return "%s–%s song tu" % [path_name(StringName(first["path"])), path_name(StringName(second["path"]))]
    return "%s tu thiên hỗn hợp" % path_name(StringName(first["path"]))

func path_name(path_id: StringName) -> String:
    return str(PATH_NAMES.get(str(path_id), str(path_id)))

func validate_invariants(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if not state.sect.cultivation_paths_enabled:
        return errors
    if state.sect.cultivation_path_event_count < 0:
        errors.append("Cultivation path event count cannot be negative.")
    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        for path_id in VALID_PATHS:
            if path_xp(disciple, path_id) < 0.0:
                errors.append("%s has negative %s path XP." % [disciple.display_name, path_name(path_id)])
        for key in disciple.cultivation_path_xp.keys():
            if not VALID_PATHS.has(StringName(key)):
                errors.append("%s has invalid cultivation path %s." % [disciple.display_name, key])
    return errors

func _normalize_disciple(disciple: DiscipleState) -> void:
    var normalized: Dictionary = {}
    for path_id in VALID_PATHS:
        normalized[str(path_id)] = maxf(float(disciple.cultivation_path_xp.get(str(path_id), 0.0)), 0.0)
    disciple.cultivation_path_xp = normalized
