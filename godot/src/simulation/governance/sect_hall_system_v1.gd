class_name SectHallSystemV1
extends RefCounted

# DD-01: one live authority for early Hall offices. This is intentionally
# opt-in: old P0/P1/P3.7 fixtures are not migrated by merely loading a script.
const SCHEMA_VERSION := 1
const MAIN_HALL_ID := &"main_hall_001"
const OFFICE_MASTER := "master"
const OFFICE_GUIDE := "guide"
const OFFICE_TEACHER := "teacher"
const OFFICES := [OFFICE_MASTER, OFFICE_GUIDE, OFFICE_TEACHER]
const LABELS := {
    OFFICE_MASTER: "Chưởng Môn",
    OFFICE_GUIDE: "Tiếp Dẫn Trưởng Lão",
    OFFICE_TEACHER: "Truyền Công Trưởng Lão"
}
const MAX_MASTERY := 10
const DAY_TICKS := 1440
const ACTIVITY_EXP := 5

static func default_state() -> Dictionary:
    return {
        "version": SCHEMA_VERSION,
        "sect_rank_index": 1,
        "assignments": {},
        "mastery": {},
        "appointment_sequence": 0
    }

static func installed(state: SimulationState) -> bool:
    return state != null and not state.sect.hall_governance.is_empty() \
        and int(state.sect.hall_governance.get("version", 0)) == SCHEMA_VERSION

static func ensure_live(state: SimulationState) -> Dictionary:
    if state == null or not state.p3_7_buildings_enabled:
        return {"ok": false, "reason": "hall_requires_live_buildings"}
    var building_system := BuildingSystem.new()
    var existing := building_system.primary_building(state, BuildingSystem.TYPE_MAIN_HALL)
    if existing == null:
        var hall := building_system.create_building(BuildingSystem.TYPE_MAIN_HALL, 1)
        if hall == null or state.buildings.has(str(MAIN_HALL_ID)):
            return {"ok": false, "reason": "hall_id_collision"}
        state.buildings[str(hall.id)] = hall
        state.building_event_count += 1
    if state.sect.hall_governance.is_empty():
        state.sect.hall_governance = default_state()
    if not installed(state):
        return {"ok": false, "reason": "unsupported_hall_schema"}
    return {"ok": true}

static func hall(state: SimulationState) -> BuildingState:
    if state == null:
        return null
    return BuildingSystem.new().primary_building(state, BuildingSystem.TYPE_MAIN_HALL)

static func label(office_id: String) -> String:
    return str(LABELS.get(office_id, office_id))

static func holder_id(state: SimulationState, office_id: String) -> String:
    if not installed(state) or not OFFICES.has(office_id):
        return ""
    if office_id == OFFICE_GUIDE:
        var platform := BuildingSystem.new().primary_building(state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
        if platform == null:
            return ""
        return str(platform.production_state.get("main_guide_id", ""))
    var assignments: Dictionary = state.sect.hall_governance.get("assignments", {})
    return str(assignments.get(office_id, ""))

static func mastery(state: SimulationState, office_id: String, disciple_id: String) -> Dictionary:
    if not installed(state):
        return {"level": 1, "xp": 0, "last_award_day": -1}
    var records: Dictionary = state.sect.hall_governance.get("mastery", {})
    var key := "%s:%s" % [disciple_id, office_id]
    var item = records.get(key, {})
    if not (item is Dictionary):
        return {"level": 1, "xp": 0, "last_award_day": -1}
    return {
        "level": clampi(int(item.get("level", 1)), 1, MAX_MASTERY),
        "xp": maxi(0, int(item.get("xp", 0))),
        "last_award_day": int(item.get("last_award_day", -1))
    }

static func required_xp(level: int) -> int:
    return 40 + 20 * level + 5 * level * level

static func office_bonus(state: SimulationState, office_id: String) -> float:
    var id := holder_id(state, office_id)
    if id.is_empty() or not state.disciples.has(StringName(id)):
        return 0.0
    var owner: DiscipleState = state.disciples[StringName(id)]
    if owner.injury_level != 0 or owner.hp <= 0.0:
        return 0.0
    var level := int(mastery(state, office_id, id)["level"])
    var t := float(level - 1) / float(MAX_MASTERY - 1)
    match office_id:
        OFFICE_MASTER:
            return lerpf(0.08, 0.14, t)
        OFFICE_TEACHER:
            return lerpf(0.03, 0.09, t)
        _:
            return 0.0

static func can_appoint(state: SimulationState, office_id: String, disciple_id: StringName) -> Dictionary:
    if not installed(state) or not OFFICES.has(office_id):
        return {"ok": false, "reason": "office_not_available"}
    var hall_state := hall(state)
    if hall_state == null or hall_state.level < 1:
        return {"ok": false, "reason": "main_hall_missing"}
    if not state.disciples.has(disciple_id):
        return {"ok": false, "reason": "disciple_missing"}
    var candidate: DiscipleState = state.disciples[disciple_id]
    if candidate.injury_level != 0 or candidate.hp <= 0.0:
        return {"ok": false, "reason": "disciple_injured"}
    for other in OFFICES:
        if other != office_id and holder_id(state, other) == str(disciple_id):
            return {"ok": false, "reason": "already_owns_other_office", "other": other}
    if office_id == OFFICE_GUIDE and not RecruitmentSystem.new().guidance_guide_eligible(state, disciple_id):
        return {"ok": false, "reason": "guide_busy_or_injured"}
    return {"ok": true}

static func appoint(state: SimulationState, office_id: String, disciple_id: StringName) -> Dictionary:
    var allowed := can_appoint(state, office_id, disciple_id)
    if not bool(allowed.get("ok", false)):
        return allowed
    if holder_id(state, office_id) == str(disciple_id):
        return {"ok": true, "unchanged": true}
    if office_id == OFFICE_GUIDE:
        var assigned := RecruitmentSystem.new().assign_guidance_main(state, disciple_id)
        if not bool(assigned.get("ok", false)):
            return assigned
    else:
        var assignments: Dictionary = state.sect.hall_governance.get("assignments", {}).duplicate(true)
        assignments[office_id] = str(disciple_id)
        state.sect.hall_governance["assignments"] = assignments
    state.sect.hall_governance["appointment_sequence"] = int(state.sect.hall_governance.get("appointment_sequence", 0)) + 1
    # Do not reset mastery on appointment. The actual XP channel is consulted at
    # its next committed minute; no mutation of immutable D7 birth values.
    return {"ok": true, "office": office_id, "disciple_id": str(disciple_id)}

static func dismiss(state: SimulationState, office_id: String) -> Dictionary:
    if not installed(state) or not OFFICES.has(office_id):
        return {"ok": false, "reason": "office_not_available"}
    if holder_id(state, office_id).is_empty():
        return {"ok": true, "unchanged": true}
    if office_id == OFFICE_GUIDE:
        var clear := RecruitmentSystem.new().assign_guidance_main(state, &"")
        if not bool(clear.get("ok", false)):
            return clear
    else:
        var assignments: Dictionary = state.sect.hall_governance.get("assignments", {}).duplicate(true)
        assignments.erase(office_id)
        state.sect.hall_governance["assignments"] = assignments
    state.sect.hall_governance["appointment_sequence"] = int(state.sect.hall_governance.get("appointment_sequence", 0)) + 1
    return {"ok": true}

static func cultivation_sources(state: SimulationState, disciple: DiscipleState) -> Array:
    var result: Array = []
    if not installed(state) or disciple == null:
        return result
    if holder_id(state, OFFICE_MASTER) == str(disciple.id):
        var own_bonus := office_bonus(state, OFFICE_MASTER)
        if own_bonus > 0.0:
            result.append({
                "source_id": "hall_v1:master_personal",
                "channel": "cultivation_xp_gain",
                "mode": "percent_add",
                "value": own_bonus
            })
    var teacher_bonus := office_bonus(state, OFFICE_TEACHER)
    if teacher_bonus > 0.0:
        result.append({
            "source_id": "hall_v1:teaching",
            "channel": "cultivation_xp_gain",
            "mode": "percent_add",
            "value": teacher_bonus
        })
    return result

static func record_cultivation(state: SimulationState, gained: float) -> void:
    if not installed(state) or gained <= 0.0:
        return
    # One genuine settled natural-Tu-Vi event/day may grant each holder XP.
    # A day-scoped key prevents per-minute farming and survives Save/Reload.
    for office_id in [OFFICE_MASTER, OFFICE_TEACHER]:
        var id := holder_id(state, office_id)
        if id.is_empty() or office_bonus(state, office_id) <= 0.0:
            continue
        var all_records: Dictionary = state.sect.hall_governance.get("mastery", {}).duplicate(true)
        var key := "%s:%s" % [id, office_id]
        var record := mastery(state, office_id, id)
        var day := int(state.tick / DAY_TICKS)
        if day <= int(record.get("last_award_day", -1)):
            continue
        record["last_award_day"] = day
        if int(record["level"]) < MAX_MASTERY:
            var xp := int(record["xp"]) + ACTIVITY_EXP
            while int(record["level"]) < MAX_MASTERY and xp >= required_xp(int(record["level"])):
                xp -= required_xp(int(record["level"]))
                record["level"] = int(record["level"]) + 1
            record["xp"] = 0 if int(record["level"]) >= MAX_MASTERY else xp
        all_records[key] = record
        state.sect.hall_governance["mastery"] = all_records

static func validate(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if not installed(state):
        return errors
    var hall_state := hall(state)
    if hall_state == null or hall_state.id != MAIN_HALL_ID:
        errors.append("Hall V1 missing singleton main_hall_001.")
    var used: Dictionary = {}
    for office_id in OFFICES:
        var id := holder_id(state, office_id)
        if id.is_empty():
            continue
        if not state.disciples.has(StringName(id)):
            errors.append("Hall office references missing disciple: " + office_id)
        elif used.has(id):
            errors.append("A disciple holds multiple main offices.")
        else:
            used[id] = true
    var saved_records = state.sect.hall_governance.get("mastery", {})
    if not (saved_records is Dictionary):
        errors.append("Hall mastery ledger is invalid.")
    else:
        for raw in saved_records.values():
            if not (raw is Dictionary):
                errors.append("Hall mastery record is not a dictionary.")
                continue
            if int(raw.get("level", 0)) < 1 or int(raw.get("level", 0)) > MAX_MASTERY or int(raw.get("xp", -1)) < 0:
                errors.append("Hall mastery record out of bounds.")
    return errors
