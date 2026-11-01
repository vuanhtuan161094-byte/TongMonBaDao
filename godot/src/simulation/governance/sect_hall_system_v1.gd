class_name SectHallSystemV1
extends RefCounted

# DD-01: one live authority for early Hall offices. This is intentionally
# opt-in: old P0/P1/P3.7 fixtures are not migrated by merely loading a script.
const SCHEMA_VERSION := 1
const MAIN_HALL_ID := &"main_hall_001"
const OFFICE_MASTER := "master"
const OFFICE_GUIDE := "guide"
const OFFICE_TEACHER := "teacher"
const OFFICE_STEWARD := "steward"
const OFFICE_GUARDIAN := "guardian"
const OFFICE_ALCHEMIST := "alchemist"
const OFFICE_DISCIPLINE := "discipline"
const OFFICES := [OFFICE_MASTER, OFFICE_GUIDE, OFFICE_TEACHER,
    OFFICE_STEWARD, OFFICE_GUARDIAN, OFFICE_ALCHEMIST, OFFICE_DISCIPLINE]
const OFFICE_UNLOCK := {
    OFFICE_MASTER: 1, OFFICE_GUIDE: 1, OFFICE_TEACHER: 1,
    OFFICE_STEWARD: 3, OFFICE_GUARDIAN: 5, OFFICE_ALCHEMIST: 7,
    OFFICE_DISCIPLINE: 10
}
# Proposed numeric authority table, distinct from Hall building level.
const RANK_LIMITS := [
    12, 18, 26, 36, 48, 60, 70, 80, 90,
    105, 120, 135, 150, 165, 175, 185, 195, 200,
    230, 260, 290, 320, 350, 380, 410, 445, 480
]
const RANK_HALL_LEVELS := [
    1, 5, 9, 13, 17, 21, 25, 29, 33,
    37, 41, 45, 49, 53, 57, 61, 65, 69,
    73, 77, 81, 85, 89, 93, 96, 98, 100
]
const LABELS := {
    OFFICE_MASTER: "Chưởng Môn",
    OFFICE_GUIDE: "Tiếp Dẫn Trưởng Lão",
    OFFICE_TEACHER: "Truyền Công Trưởng Lão",
    OFFICE_STEWARD: "Nội Vụ Chấp Sự",
    OFFICE_GUARDIAN: "Hộ Pháp Trưởng Lão",
    OFFICE_ALCHEMIST: "Đan Đạo Trưởng Lão",
    OFFICE_DISCIPLINE: "Giới Luật Trưởng Lão"
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
        # One office can mint at most one EXP grant/day across all holders,
        # preventing a same-day reappointment farm.
        "office_award_day": {},
        "appointment_sequence": 0,
        "prestige": 0,
        "promotion_receipts": {},
        "upgrade_receipts": {}
    }

static func installed(state: SimulationState) -> bool:
    return state != null and not state.sect.hall_governance.is_empty() \
        and int(state.sect.hall_governance.get("version", 0)) == SCHEMA_VERSION

static func ensure_live(state: SimulationState) -> Dictionary:
    if state == null or not state.p3_7_buildings_enabled:
        return {"ok": false, "reason": "hall_requires_live_buildings"}
    var building_system := BuildingSystem.new()
    # Refuse noncanonical or multiple Hall instances before any migration grant.
    # Do not silently adopt a different saved building ID as the singleton.
    var hall_count := 0
    for value in state.buildings.values():
        if value is BuildingState and value.building_type == BuildingSystem.TYPE_MAIN_HALL:
            hall_count += 1
            if value.id != MAIN_HALL_ID:
                return {"ok": false, "reason": "noncanonical_main_hall_id"}
    if hall_count > 1:
        return {"ok": false, "reason": "duplicate_main_hall"}
    var existing := building_system.primary_building(state, BuildingSystem.TYPE_MAIN_HALL)
    # A real saved governance ledger must NEVER silently receive a newly
    # minted Lv1 Hall if its original building has gone missing.
    if existing == null and not state.sect.hall_governance.is_empty():
        return {"ok": false, "reason": "persisted_hall_building_missing"}
    if not state.sect.hall_governance.is_empty() and not installed(state):
        return {"ok": false, "reason": "unsupported_hall_schema"}
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
    for field in ["assignments", "mastery", "office_award_day", "promotion_receipts"]:
        if not (state.sect.hall_governance.get(field, {}) is Dictionary):
            return {"ok": false, "reason": "malformed_hall_" + field}
    var saved_rank = state.sect.hall_governance.get("sect_rank_index", 1)
    if not (saved_rank is int or saved_rank is float) or float(saved_rank) != float(int(saved_rank)) or int(saved_rank) < 1 or int(saved_rank) > 27:
        return {"ok": false, "reason": "invalid_sect_rank_index"}
    var housing := SectResidenceSystemV1.ensure_live(state)
    if not bool(housing.get("ok", false)):
        return housing
    return {"ok": true}

static func hall(state: SimulationState) -> BuildingState:
    if state == null:
        return null
    # DD-07: called on every disciple's natural Tu Vi tick. Resolve the
    # canonical singleton by stable key in O(1), not a fresh BuildingSystem
    # with a sort/scan of all owned buildings (up to hundreds per tick).
    var candidate = state.buildings.get(str(MAIN_HALL_ID))
    if candidate is BuildingState and candidate.id == MAIN_HALL_ID \
            and candidate.building_type == BuildingSystem.TYPE_MAIN_HALL:
        return candidate
    return null

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

static func affinity_score(disciple: DiscipleState, office_id: String) -> float:
    if disciple == null:
        return 0.0
    match office_id:
        OFFICE_MASTER:
            return maxf(0.0, (disciple.mind_nature + disciple.potential) * 0.5)
        OFFICE_GUIDE:
            return maxf(0.0, (disciple.charisma + disciple.fortune) * 0.5)
        OFFICE_TEACHER:
            return maxf(0.0, (disciple.comprehension + disciple.aptitude) * 0.5)
        OFFICE_STEWARD:
            return maxf(0.0, (disciple.comprehension + disciple.mind_nature) * 0.5)
        OFFICE_GUARDIAN:
            return maxf(0.0, (disciple.constitution + disciple.potential) * 0.5)
        OFFICE_ALCHEMIST:
            return maxf(0.0, (disciple.comprehension + disciple.fortune) * 0.5)
        OFFICE_DISCIPLINE:
            return maxf(0.0, (disciple.mind_nature + disciple.constitution) * 0.5)
        _:
            return 0.0

static func affinity_factor(disciple: DiscipleState, office_id: String) -> float:
    # Small differentiator rather than a hidden dramatic quality reroll.
    return clampf(0.90 + 0.0001 * affinity_score(disciple, office_id), 0.90, 1.15)

static func office_bonus(state: SimulationState, office_id: String) -> float:
    if not installed(state) or not OFFICES.has(office_id):
        return 0.0
    var hall_state := hall(state)
    if hall_state == null or hall_state.level < int(OFFICE_UNLOCK.get(office_id, 101)):
        return 0.0
    var id := holder_id(state, office_id)
    if id.is_empty() or not state.disciples.has(StringName(id)):
        return 0.0
    var owner: DiscipleState = state.disciples[StringName(id)]
    if owner.injury_level != 0 or owner.hp <= 0.0:
        return 0.0
    var level := int(mastery(state, office_id, id)["level"])
    var t := float(level - 1) / float(MAX_MASTERY - 1)
    var fit := affinity_factor(owner, office_id)
    match office_id:
        OFFICE_MASTER:
            return lerpf(0.08, 0.14, t) * fit
        OFFICE_TEACHER:
            return lerpf(0.03, 0.09, t) * fit
        _:
            return 0.0

static func can_appoint(state: SimulationState, office_id: String, disciple_id: StringName) -> Dictionary:
    if not installed(state) or not OFFICES.has(office_id):
        return {"ok": false, "reason": "office_not_available"}
    var hall_state := hall(state)
    if hall_state != null and hall_state.level < int(OFFICE_UNLOCK.get(office_id, 101)):
        return {"ok": false, "reason": "office_requires_hall_level", "need": OFFICE_UNLOCK.get(office_id, 101)}
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

static func master_effective_d7_points(state: SimulationState, disciple: DiscipleState) -> float:
    if not installed(state) or disciple == null or holder_id(state, OFFICE_MASTER) != str(disciple.id):
        return 0.0
    if office_bonus(state, OFFICE_MASTER) <= 0.0:
        return 0.0
    return lerpf(25.0, 70.0, float(int(mastery(state, OFFICE_MASTER, str(disciple.id))["level"]) - 1) / 9.0) * affinity_factor(disciple, OFFICE_MASTER)

static func master_hp_bonus(state: SimulationState, disciple: DiscipleState) -> float:
    if master_effective_d7_points(state, disciple) <= 0.0:
        return 0.0
    return lerpf(0.03, 0.07, float(int(mastery(state, OFFICE_MASTER, str(disciple.id))["level"]) - 1) / 9.0) * affinity_factor(disciple, OFFICE_MASTER)

static func cultivation_sources(state: SimulationState, disciple: DiscipleState) -> Array:
    var result: Array = []
    if not installed(state) or disciple == null:
        return result
    if holder_id(state, OFFICE_MASTER) == str(disciple.id):
        var own_bonus := office_bonus(state, OFFICE_MASTER)
        if own_bonus > 0.0:
            var d7_points := master_effective_d7_points(state, disciple)
            if d7_points > 0.0:
                result.append({
                    "source_id": "hall_v1:master_effective_aptitude",
                    "channel": "cultivation_xp_gain",
                    "mode": "percent_add",
                    "value": 0.0025 * d7_points
                })
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

static func record_cultivation(state: SimulationState, actor: DiscipleState, gained: float) -> void:
    if not installed(state) or actor == null or gained <= 0.0:
        return
    # One genuine settled natural-Tu-Vi event/day may grant each holder XP.
    # A day-scoped key prevents per-minute farming and survives Save/Reload.
    for office_id in [OFFICE_MASTER, OFFICE_TEACHER]:
        var id := holder_id(state, office_id)
        if id.is_empty() or office_bonus(state, office_id) <= 0.0:
            continue
        # Chưởng Môn earns this training mastery from their own real training.
        # Truyền Công earns it from a real eligible sect disciple's training.
        if office_id == OFFICE_MASTER and id != str(actor.id):
            continue
        var all_records: Dictionary = state.sect.hall_governance.get("mastery", {}).duplicate(true)
        var key := "%s:%s" % [id, office_id]
        var record := mastery(state, office_id, id)
        var day := int(state.tick / DAY_TICKS)
        var office_awards: Dictionary = state.sect.hall_governance.get("office_award_day", {}).duplicate(true)
        if day <= int(record.get("last_award_day", -1)) or day <= int(office_awards.get(office_id, -1)):
            continue
        record["last_award_day"] = day
        if int(record["level"]) < MAX_MASTERY:
            var xp := int(record["xp"]) + ACTIVITY_EXP
            while int(record["level"]) < MAX_MASTERY and xp >= required_xp(int(record["level"])):
                xp -= required_xp(int(record["level"]))
                record["level"] = int(record["level"]) + 1
            record["xp"] = 0 if int(record["level"]) >= MAX_MASTERY else xp
        all_records[key] = record
        office_awards[office_id] = day
        state.sect.hall_governance["mastery"] = all_records
        state.sect.hall_governance["office_award_day"] = office_awards

static func rank_index(state: SimulationState) -> int:
    if not installed(state):
        return 1
    return clampi(int(state.sect.hall_governance.get("sect_rank_index", 1)), 1, 27)

static func rank_population_limit(state: SimulationState) -> int:
    return int(RANK_LIMITS[rank_index(state) - 1])

static func rank_label(index: int) -> String:
    var step := clampi(index, 1, 27)
    var world := "Nhân" if step <= 9 else ("Tiên" if step <= 18 else "Thần")
    return "%s %d/9" % [world, (step - 1) % 9 + 1]

static func promotion_requirements(state: SimulationState) -> Dictionary:
    if not installed(state):
        return {"ok": false, "reason": "hall_governance_missing"}
    var current := rank_index(state)
    if current >= 27:
        return {"ok": false, "reason": "rank_complete"}
    var next_index := current + 1
    var hall_state := hall(state)
    var hall_need := int(RANK_HALL_LEVELS[next_index - 1])
    var roster_need := mini(int(RANK_LIMITS[current - 1]), 6 + (next_index - 1) * 2)
    var batches := 0
    var real_mine_or_forest := 0
    for building in state.buildings.values():
        if not (building is BuildingState):
            continue
        if building.building_type in [BuildingSystem.TYPE_MINE, BuildingSystem.TYPE_LINH_FOREST, BuildingSystem.TYPE_SPIRIT_FIELD]:
            var completed := int(building.metrics.get("production_batches", 0))
            batches += completed
            if building.building_type in [BuildingSystem.TYPE_MINE, BuildingSystem.TYPE_LINH_FOREST]:
                real_mine_or_forest += completed
    var production_need := 2 * (next_index - 1)
    # Realm qualification is checked from the canonical V2 progression only.
    # Founders with older progression remain retained but cannot fake a high-tier gate.
    var min_realm := 1 if next_index <= 9 else (10 if next_index <= 18 else 20)
    var realm_need := 1 if next_index <= 9 else maxi(1, int(ceil(float(roster_need) / 10.0)))
    var realm_eligible := 0
    for disciple_value in state.disciples.values():
        var recruit: DiscipleState = disciple_value
        if DiscipleRealmProgressV2.valid_profile(recruit.v2_realm_progress):
            var realm_profile := DiscipleRealmProgressV2.current(recruit)
            if bool(realm_profile.get("ok", false)) and int(realm_profile["cultivation"]["realm"]) >= min_realm:
                realm_eligible += 1
    var prestige_need := 25 * (next_index - 1) * next_index
    var renown := int(state.sect.hall_governance.get("prestige", 0))
    var costs := {
        BuildingSystem.MATERIAL_WOOD: 20 * next_index,
        BuildingSystem.MATERIAL_ORE: 12 * next_index,
        "spirit_stones": 100 * next_index
    }
    var blockers: Array[String] = []
    if hall_state == null or hall_state.level < hall_need:
        blockers.append("hall_level")
    if state.disciples.size() < roster_need:
        blockers.append("disciple_roster")
    if realm_eligible < realm_need:
        blockers.append("disciple_realm")
    if batches < production_need or real_mine_or_forest <= 0:
        blockers.append("real_production")
    if renown < prestige_need:
        blockers.append("prestige")
    var system := BuildingSystem.new()
    for key in costs.keys():
        if str(key) == "spirit_stones":
            if state.sect.spirit_stones < int(costs[key]):
                blockers.append("spirit_stones")
        elif system._resource_available(state, StringName(key)) < int(costs[key]):
            blockers.append(str(key))
    return {
        "ok": blockers.is_empty(), "next": next_index, "next_name": rank_label(next_index),
        "hall_level": hall_state.level if hall_state != null else 0, "hall_need": hall_need,
        "roster": state.disciples.size(), "roster_need": roster_need,
        "realm": realm_eligible, "realm_need": realm_need, "min_realm": min_realm,
        "production": batches, "production_need": production_need,
        "prestige": renown, "prestige_need": prestige_need,
        "cost": costs, "blockers": blockers
    }

static func promote(state: SimulationState, request_id: String) -> Dictionary:
    if request_id.is_empty() or request_id.length() > 100 or not installed(state):
        return {"ok": false, "reason": "invalid_promotion_request"}
    var receipts: Dictionary = state.sect.hall_governance.get("promotion_receipts", {})
    if receipts.has(request_id):
        return {"ok": true, "already_settled": true, "new_rank": int(receipts[request_id])}
    var check := promotion_requirements(state)
    if not bool(check.get("ok", false)):
        return check
    var costs: Dictionary = check["cost"]
    var materials := costs.duplicate(true)
    materials.erase("spirit_stones")
    if not BuildingSystem.new()._consume_resources(state, materials):
        return {"ok": false, "reason": "materials_changed"}
    state.sect.spirit_stones -= int(costs["spirit_stones"])
    var new_rank := rank_index(state) + 1
    state.sect.hall_governance["sect_rank_index"] = new_rank
    receipts = receipts.duplicate(true)
    receipts[request_id] = new_rank
    state.sect.hall_governance["promotion_receipts"] = receipts
    SectResidenceSystemV1.refresh_capacity(state)
    return {"ok": true, "new_rank": new_rank, "name": rank_label(new_rank), "cost": costs}

static func record_prestige(state: SimulationState, amount: int) -> void:
    # The only callers must be genuine committed recruitment or production
    # receipts. No click/preview/save-read may mint renown.
    if installed(state) and amount > 0:
        state.sect.hall_governance["prestige"] = maxi(0, int(state.sect.hall_governance.get("prestige", 0))) + amount

static func role_effect(state: SimulationState, office_id: String) -> float:
    if not installed(state):
        return 0.0
    var id := holder_id(state, office_id)
    if id.is_empty() or not state.disciples.has(StringName(id)):
        return 0.0
    var actor: DiscipleState = state.disciples[StringName(id)]
    if actor.injury_level != 0 or actor.hp <= 0.0:
        return 0.0
    var hall_state := hall(state)
    if hall_state == null or hall_state.level < int(OFFICE_UNLOCK.get(office_id, 101)):
        return 0.0
    var level := int(mastery(state, office_id, id).get("level", 1))
    var t := float(level - 1) / 9.0
    var fit := affinity_factor(actor, office_id)
    match office_id:
        OFFICE_GUIDE:
            return lerpf(60.0, 285.0, t) * fit
        OFFICE_STEWARD, OFFICE_ALCHEMIST:
            return lerpf(0.02, 0.08, t) * fit
        OFFICE_GUARDIAN:
            return lerpf(0.02, 0.06, t) * fit
        OFFICE_DISCIPLINE:
            return lerpf(0.03, 0.09, t) * fit
        _:
            return office_bonus(state, office_id)

static func record_office_event(state: SimulationState, office_id: String, completed: bool) -> void:
    if not completed or not installed(state) or not OFFICES.has(office_id):
        return
    var id := holder_id(state, office_id)
    if id.is_empty() or role_effect(state, office_id) <= 0.0:
        return
    _award_mastery(state, office_id, id)

static func _award_mastery(state: SimulationState, office_id: String, id: String) -> void:
    var day := int(state.tick / DAY_TICKS)
    var all_days: Dictionary = state.sect.hall_governance.get("office_award_day", {}).duplicate(true)
    var record := mastery(state, office_id, id)
    if day <= int(all_days.get(office_id, -1)) or day <= int(record.get("last_award_day", -1)):
        return
    var all_records: Dictionary = state.sect.hall_governance.get("mastery", {}).duplicate(true)
    record["last_award_day"] = day
    if int(record["level"]) < MAX_MASTERY:
        var xp := int(record["xp"]) + ACTIVITY_EXP
        while int(record["level"]) < MAX_MASTERY and xp >= required_xp(int(record["level"])):
            xp -= required_xp(int(record["level"]))
            record["level"] = int(record["level"]) + 1
        record["xp"] = 0 if int(record["level"]) >= MAX_MASTERY else xp
    all_records["%s:%s" % [id, office_id]] = record
    all_days[office_id] = day
    state.sect.hall_governance["mastery"] = all_records
    state.sect.hall_governance["office_award_day"] = all_days

static func validate(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if state == null:
        errors.append("Hall validation received null simulation state.")
        return errors
    if state.sect.hall_governance.is_empty():
        return errors # Truly legacy save, with no Hall payload.
    if not installed(state):
        errors.append("Hall governance schema unsupported or malformed.")
        return errors # Never allow an unknown schema to validate as clean.
    # Validate dictionary shapes before holder_id()/mastery() dereference them.
    # A corrupted saved assignment string must return a normal validation error
    # so SaveService can recover the last good backup, not throw an engine error.
    for ledger_key in ["assignments", "mastery", "office_award_day", "promotion_receipts"]:
        if not state.sect.hall_governance.has(ledger_key) \
                or not (state.sect.hall_governance[ledger_key] is Dictionary):
            errors.append("Hall invalid ledger: " + ledger_key)
    if not errors.is_empty():
        return errors
    var saved_assignments: Dictionary = state.sect.hall_governance["assignments"]
    for saved_role in saved_assignments.keys():
        if not OFFICES.has(str(saved_role)) or str(saved_role) == OFFICE_GUIDE:
            errors.append("Hall has invalid or duplicated Guide assignment ledger key.")
        elif not (saved_assignments[saved_role] is String or saved_assignments[saved_role] is StringName):
            errors.append("Hall office holder must be a saved string ID.")
    if not errors.is_empty():
        return errors
    errors.append_array(SectResidenceSystemV1.validate(state))
    # Check the raw persisted value: rank_index() deliberately clamps for
    # display and must not mask a corrupt save from invariant validation.
    var raw_rank = state.sect.hall_governance.get("sect_rank_index", null)
    if not (raw_rank is int or raw_rank is float) or (raw_rank is float and (is_nan(raw_rank) or is_inf(raw_rank))) \
            or float(raw_rank) != float(int(raw_rank)) or int(raw_rank) < 1 or int(raw_rank) > 27:
        errors.append("Hall sect rank invalid.")
    var hall_count := 0
    for value in state.buildings.values():
        if value is BuildingState and value.building_type == BuildingSystem.TYPE_MAIN_HALL:
            hall_count += 1
            if value.id != MAIN_HALL_ID:
                errors.append("Hall V1 contains noncanonical main hall ID.")
    if hall_count != 1:
        errors.append("Hall V1 must own exactly one main_hall_001.")
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
    # DD-08: upgrade receipts are optional in older V2 saves, but if present
    # they must point to a real paid target and the correct building.
    var upgrade_receipts = state.sect.hall_governance.get("upgrade_receipts", {})
    if not (upgrade_receipts is Dictionary):
        errors.append("Hall upgrade receipt ledger is malformed.")
    else:
        var seen_upgrades: Dictionary = {}
        for raw_request in upgrade_receipts.keys():
            var request_id := str(raw_request)
            var receipt = upgrade_receipts[raw_request]
            if request_id.is_empty() or request_id.length() > 120 or not (receipt is Dictionary):
                errors.append("Hall upgrade receipt entry malformed.")
                continue
            var bid := str(receipt.get("building_id", ""))
            var target_value = receipt.get("target_level", null)
            var paid_building = state.buildings.get(bid)
            if not (paid_building is BuildingState) or not paid_building.building_type in [
                    BuildingSystem.TYPE_MAIN_HALL, BuildingSystem.TYPE_RESIDENCE]:
                errors.append("Hall upgrade receipt missing governed building.")
                continue
            if not (target_value is int or target_value is float):
                errors.append("Hall upgrade target must be integral.")
                continue
            var target_level := int(target_value)
            var max_settled := paid_building.upgrade_target_level if paid_building.is_upgrading() else paid_building.level
            var receipt_identity := "%s:%d" % [bid, target_level]
            if float(target_value) != float(target_level) or target_level < 2 \
                    or target_level > max_settled or seen_upgrades.has(receipt_identity):
                errors.append("Hall upgrade receipt has future/duplicate building target.")
                continue
            seen_upgrades[receipt_identity] = true
    # DD-07: do not accept a replay ledger pointing to future ranks or
    # malformed requests. Lost receipts can charge a promotion twice; bogus
    # receipts can claim already_settled without an actual rank transaction.
    var promotions = state.sect.hall_governance.get("promotion_receipts", null)
    if not (promotions is Dictionary):
        errors.append("Hall promotion receipt ledger is malformed.")
    else:
        var redeemed_ranks: Dictionary = {}
        for request in promotions.keys():
            var value = promotions[request]
            if str(request).is_empty() or not (value is int or value is float):
                errors.append("Hall promotion receipt request/value malformed.")
                continue
            var promoted_rank := int(value)
            if float(value) != float(promoted_rank) or promoted_rank <= 1 \
                    or promoted_rank > rank_index(state) or redeemed_ranks.has(promoted_rank):
                errors.append("Hall promotion receipt rank is invalid or duplicated.")
                continue
            redeemed_ranks[promoted_rank] = true
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
