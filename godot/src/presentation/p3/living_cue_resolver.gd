class_name LivingCueResolver
extends RefCounted

const SEVERITY_CRITICAL := 0
const SEVERITY_ACTIONABLE := 1
const SEVERITY_OPERATIONAL := 2
const SEVERITY_INFO := 3

const TARGET_DISCIPLE := &"disciple"
const TARGET_BUILDING := &"building"

func resolve_state_cues(
    state: SimulationState,
    cultivation_system: CultivationSystem,
    equipment_system: EquipmentSystem
) -> Array[Dictionary]:
    var cues: Array[Dictionary] = []
    var disciple_ids: Array = state.disciples.keys()
    disciple_ids.sort()

    var injured_in_sect := 0
    var dangerous_outside := 0
    var breakthrough_ready := 0

    for raw_id in disciple_ids:
        var disciple_id := StringName(raw_id)
        var disciple: DiscipleState = state.disciples[disciple_id]
        var hp_ratio := disciple.hp / maxf(disciple.max_hp, 1.0)

        if disciple.region_id != &"sect":
            if hp_ratio <= disciple.retreat_hp_ratio() or disciple.stamina <= 22.0:
                dangerous_outside += 1
                cues.append(_cue(
                    "disciple_danger",
                    TARGET_DISCIPLE,
                    disciple.id,
                    SEVERITY_CRITICAL,
                    "Nguy hiểm!",
                    "Outside disciple crossed the real retreat threshold.",
                    "outside_danger"
                ))
            continue

        if hp_ratio < 0.72:
            injured_in_sect += 1
            cues.append(_cue(
                "disciple_injured",
                TARGET_DISCIPLE,
                disciple.id,
                SEVERITY_ACTIONABLE,
                "Bị thương",
                "HP ratio is below 0.72.",
                "disciple_health"
            ))
            continue

        if cultivation_system.can_breakthrough(state, disciple):
            breakthrough_ready += 1
            cues.append(_cue(
                "disciple_breakthrough_ready",
                TARGET_DISCIPLE,
                disciple.id,
                SEVERITY_ACTIONABLE,
                "Có thể đột phá",
                "CultivationSystem.can_breakthrough() is true.",
                "breakthrough"
            ))
            continue

        if disciple.stamina < 42.0:
            cues.append(_cue(
                "disciple_tired",
                TARGET_DISCIPLE,
                disciple.id,
                SEVERITY_OPERATIONAL,
                "Mệt",
                "Stamina is below the real rest/workforce threshold.",
                "disciple_stamina"
            ))

    if state.sect.medicine_stock <= 0 and injured_in_sect > 0:
        cues.append(_cue(
            "medicine_empty",
            TARGET_BUILDING,
            SectMapPresentation.DEST_MEDICINE,
            SEVERITY_ACTIONABLE,
            "Hết thuốc",
            "Medicine stock is empty while an injured in-sect disciple exists.",
            "medicine_shortage"
        ))

    if state.disciples.size() > state.sect.lodging_capacity:
        cues.append(_cue(
            "lodging_overloaded",
            TARGET_BUILDING,
            SectMapPresentation.DEST_RESIDENCE,
            SEVERITY_ACTIONABLE,
            "Quá tải",
            "Disciple population exceeds lodging capacity.",
            "lodging_overload"
        ))

    if state.sect.workforce_enabled:
        var mining_members := _count_group_members(state, &"mining_crew")
        var forge_members := _count_group_members(state, &"forge_hall")

        if mining_members <= 0:
            cues.append(_cue(
                "mine_missing_people",
                TARGET_BUILDING,
                SectMapPresentation.DEST_MINE,
                SEVERITY_OPERATIONAL,
                "Thiếu người",
                "No disciple is assigned to mining_crew.",
                "mine_staffing"
            ))

        if forge_members <= 0:
            cues.append(_cue(
                "forge_missing_people",
                TARGET_BUILDING,
                SectMapPresentation.DEST_FORGE,
                SEVERITY_OPERATIONAL,
                "Thiếu người",
                "No disciple is assigned to forge_hall.",
                "forge_staffing"
            ))
        elif state.sect.equipment_enabled and not _has_craftable_recipe(state, equipment_system):
            cues.append(_cue(
                "forge_missing_materials",
                TARGET_BUILDING,
                SectMapPresentation.DEST_FORGE,
                SEVERITY_OPERATIONAL,
                "Thiếu vật liệu",
                "Forge has staff but no real recipe is currently craftable.",
                "forge_materials"
            ))

    if breakthrough_ready > 0:
        cues.append(_cue(
            "cultivation_breakthrough_ready",
            TARGET_BUILDING,
            SectMapPresentation.DEST_CULTIVATION,
            SEVERITY_ACTIONABLE,
            "%d người có thể đột phá" % breakthrough_ready if breakthrough_ready > 1 else "Có người đột phá",
            "Aggregate cultivation opportunity.",
            "breakthrough"
        ))

    if dangerous_outside > 0:
        cues.append(_cue(
            "gate_outside_danger",
            TARGET_BUILDING,
            SectMapPresentation.DEST_GATE,
            SEVERITY_CRITICAL,
            "%d người gặp nguy" % dangerous_outside if dangerous_outside > 1 else "Có người gặp nguy",
            "Aggregate outside danger.",
            "outside_danger"
        ))

    return cues

func select_visible(candidates: Array[Dictionary], max_count: int = 3) -> Array[Dictionary]:
    if max_count <= 0 or candidates.is_empty():
        return []

    var by_target: Dictionary = {}
    for raw_cue in candidates:
        var cue: Dictionary = raw_cue.duplicate(true)
        var target_key := _target_key(cue)
        if not by_target.has(target_key):
            by_target[target_key] = cue
            continue
        var current: Dictionary = by_target[target_key]
        if _sort_before(cue, current):
            by_target[target_key] = cue

    var ordered: Array[Dictionary] = []
    for value in by_target.values():
        ordered.append((value as Dictionary).duplicate(true))
    ordered.sort_custom(Callable(self, "_sort_before"))

    var result: Array[Dictionary] = []
    var semantic_seen: Dictionary = {}
    for cue in ordered:
        var semantic := str(cue.get("semantic_group", ""))
        if semantic != "" and semantic_seen.has(semantic):
            continue
        result.append(cue)
        if semantic != "":
            semantic_seen[semantic] = true
        if result.size() >= max_count:
            break
    return result

func _sort_before(a: Dictionary, b: Dictionary) -> bool:
    var severity_a := int(a.get("severity", SEVERITY_INFO))
    var severity_b := int(b.get("severity", SEVERITY_INFO))
    if severity_a != severity_b:
        return severity_a < severity_b

    var in_view_a := bool(a.get("in_view", true))
    var in_view_b := bool(b.get("in_view", true))
    if in_view_a != in_view_b:
        return in_view_a

    var distance_a := float(a.get("distance_to_camera", 0.0))
    var distance_b := float(b.get("distance_to_camera", 0.0))
    if absf(distance_a - distance_b) > 0.0001:
        return distance_a < distance_b

    return _stable_key(a) < _stable_key(b)

func _count_group_members(state: SimulationState, group_id: StringName) -> int:
    var count := 0
    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        if disciple.work_group_id == group_id:
            count += 1
    return count

func _has_craftable_recipe(state: SimulationState, equipment_system: EquipmentSystem) -> bool:
    var recipe_ids: Array = EquipmentSystem.RECIPES.keys()
    recipe_ids.sort()
    for raw_id in recipe_ids:
        if equipment_system.can_craft(state, StringName(raw_id)):
            return true
    return false

func _cue(
    cue_id: String,
    target_kind: StringName,
    target_id: StringName,
    severity: int,
    text: String,
    reason: String,
    semantic_group: String
) -> Dictionary:
    return {
        "cue_id": cue_id,
        "target_kind": str(target_kind),
        "target_id": str(target_id),
        "severity": severity,
        "text": text,
        "reason": reason,
        "semantic_group": semantic_group,
        "event": false,
        "stable_key": "%s:%s:%s" % [cue_id, str(target_kind), str(target_id)]
    }

func _target_key(cue: Dictionary) -> String:
    return "%s:%s" % [str(cue.get("target_kind", "")), str(cue.get("target_id", ""))]

func _stable_key(cue: Dictionary) -> String:
    return str(cue.get("stable_key", "%s:%s:%s" % [
        str(cue.get("cue_id", "")),
        str(cue.get("target_kind", "")),
        str(cue.get("target_id", ""))
    ]))
