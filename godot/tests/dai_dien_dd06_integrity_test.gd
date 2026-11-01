extends SceneTree

# DD-06 regression: authorization bypasses and corrupted Hall/Residence data.
# Pending execution by official Godot 4.7.2 in an isolated QA profile.
# godot --headless --path godot --script res://tests/dai_dien_dd06_integrity_test.gd

func _initialize() -> void:
    call_deferred("_run")

func _expect(ok: bool, message: String) -> bool:
    if ok:
        return true
    push_error("DD06_INTEGRITY_FAIL: " + message)
    quit(1)
    return false

func _run() -> void:
    var state := P37Factory.create_state(20261101)
    if not _expect(bool(SectHallSystemV1.ensure_live(state).get("ok", false)),
            "Live Hall/Residence opt-in installation"):
        return
    var hall := SectHallSystemV1.hall(state)
    if not _expect(hall != null and hall.id == &"main_hall_001", "canonical Hall ID"):
        return
    hall.level = 10 # Isolated test fixture: no production upgrade shortcut.
    var available: Array = state.recruitment_candidates.keys()
    available.sort()
    if not _expect(not available.is_empty(), "real recruitment candidate fixture"):
        return
    var recruited := RecruitmentSystem.new().accept_candidate(state, StringName(str(available[0])))
    if not _expect(bool(recruited.get("ok", false)), "real recruitment admission"):
        return
    var recruit_id := StringName(str(recruited.get("disciple_id", "")))
    var actor: DiscipleState = state.disciples[recruit_id]
    actor.region_id = &"sect"
    actor.active_pve_encounter_id = ""
    actor.work_cycle_state = {}
    actor.direct_command = {}
    actor.current_action = &"IDLE"
    if not _expect(RecruitmentSystem.new().guidance_guide_eligible(state, recruit_id),
            "recruit must be genuinely eligible for Dẫn Tiên"):
        return

    # Every one of the six OTHER offices must block direct bypass via Dẫn Tiên.
    for office_id in SectHallSystemV1.OFFICES:
        if office_id == SectHallSystemV1.OFFICE_GUIDE:
            continue
        var installed := SectHallSystemV1.appoint(state, office_id, recruit_id)
        if not _expect(bool(installed.get("ok", false)),
                "fixture appointment to " + office_id):
            return
        var forbidden := RecruitmentSystem.new().assign_guidance_main(state, recruit_id)
        if not _expect(not bool(forbidden.get("ok", true))
                and str(forbidden.get("reason", "")) == "disciple_owns_other_office",
                "Dẫn Tiên bypassed main-office uniqueness for " + office_id):
            return
        if not _expect(bool(SectHallSystemV1.dismiss(state, office_id).get("ok", false)),
                "dismiss fixture office " + office_id):
            return

    if not _expect(bool(RecruitmentSystem.new().assign_guidance_main(state, recruit_id).get("ok", false)),
            "eligible unassigned guide cannot be appointed"):
        return
    if not _expect(SectHallSystemV1.holder_id(state, SectHallSystemV1.OFFICE_GUIDE) == str(recruit_id),
            "direct Dẫn Tiên and Hall must agree on holder"):
        return

    if not _expect(SectHallSystemV1.rank_label(9) == "Nhân 9/9"
            and SectHallSystemV1.rank_label(10) == "Tiên 1/9"
            and SectHallSystemV1.rank_label(19) == "Thần 1/9"
            and SectHallSystemV1.rank_label(27) == "Thần 9/9",
            "27-rank realm presentation boundary"):
        return

    # Corrupt rank must not pass because the display function clamps it.
    var invalid_rank := SimulationState.from_dict(state.to_dict())
    if not _expect(invalid_rank != null, "test codec roundtrip"):
        return
    invalid_rank.sect.hall_governance["sect_rank_index"] = 99
    if not _expect(not SectHallSystemV1.validate(invalid_rank).is_empty()
            and not bool(SectHallSystemV1.ensure_live(invalid_rank).get("ok", true)),
            "raw corrupt rank must fail closed"):
        return

    # Corrupted room ledgers are reported without an unchecked Dictionary cast.
    var invalid_rooms := SimulationState.from_dict(state.to_dict())
    if not _expect(invalid_rooms != null, "test room codec roundtrip"):
        return
    invalid_rooms.sect.hall_governance["residence_assignments"] = "broken"
    if not _expect(not SectResidenceSystemV1.validate(invalid_rooms).is_empty()
            and not bool(SectResidenceSystemV1.ensure_live(invalid_rooms).get("ok", true)),
            "corrupt room ledger must fail closed without runtime type error"):
        return

    # An inconsistent second Hall is rejected, never silently selected.
    var duplicate := SimulationState.from_dict(state.to_dict())
    if not _expect(duplicate != null, "test Hall codec roundtrip"):
        return
    var hall2 := BuildingSystem.new().create_building(BuildingSystem.TYPE_MAIN_HALL, 2)
    duplicate.buildings[str(hall2.id)] = hall2
    if not _expect(not bool(SectHallSystemV1.ensure_live(duplicate).get("ok", true))
            and not SectHallSystemV1.validate(duplicate).is_empty(),
            "duplicate Hall must never be accepted as a singleton"):
        return

    # An orphaned office must not emit benefits when its building has vanished.
    if not _expect(bool(SectHallSystemV1.dismiss(state, SectHallSystemV1.OFFICE_GUIDE).get("ok", false)),
            "dismiss guide before assigning Chưởng Môn"):
        return
    if not _expect(bool(SectHallSystemV1.appoint(state, SectHallSystemV1.OFFICE_MASTER,
            recruit_id).get("ok", false)),
            "appoint Chưởng Môn before missing-Hall check"):
        return
    state.buildings.erase("main_hall_001")
    if not _expect(SectHallSystemV1.office_bonus(state, SectHallSystemV1.OFFICE_MASTER) == 0.0,
            "orphaned Chưởng Môn still grants a hidden buff"):
        return

    print("DD06_INTEGRITY_PASS guide_conflicts=6 rank_boundaries=4 malformed_rank=1 malformed_rooms=1 duplicate_hall=1 orphaned_bonus=0")
    quit(0)
