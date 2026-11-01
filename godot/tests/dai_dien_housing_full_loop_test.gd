extends SceneTree

# DD-02/04 exact end-to-end backend/GUI smoke — official Godot 4.7.2.
# Run: godot --headless --path . --script res://tests/dai_dien_housing_full_loop_test.gd

func _initialize() -> void:
    call_deferred("_run")

func _assert(works: bool, message: String) -> bool:
    if works:
        return true
    push_error("DD_HOUSING_LOOP_FAIL: " + message)
    quit(1)
    return false

func _run() -> void:
    var state := P37Factory.create_state(20261101)
    state.sect.disciple_v2_birth_enabled = true
    var ready := SectHallSystemV1.ensure_live(state)
    if not _assert(bool(ready.get("ok", false)), "Hall/Residence initialization"):
        return
    if not _assert(SectResidenceSystemV1.all_houses(state).size() == 1, "must start with one real house"):
        return
    if not _assert(state.sect.disciple_capacity == 8 and state.sect.lodging_capacity == 8,
            "8 beds must govern 8 recruitment slots at New Game"):
        return
    var houses := SectResidenceSystemV1.all_houses(state)
    var first: BuildingState = houses[0]
    if not _assert(str(first.id) == "residence_001" and first.level == 1, "starter Residence ID/level"):
        return

    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    if not _assert(ids.size() >= 3, "3 starter applicants"):
        return
    var recruit := RecruitmentSystem.new()
    for i in range(2):
        var accepted := recruit.accept_candidate(state, StringName(str(ids[i])))
        if not _assert(bool(accepted.get("ok", false)), "first two genuine applicants"):
            return
    if not _assert(state.disciples.size() == 8 and not recruit.can_accept_more(state), "8/8 must close admissions"):
        return
    var blocked := recruit.accept_candidate(state, StringName(str(ids[2])))
    if not _assert(not bool(blocked.get("ok", true)) and str(blocked.get("reason", "")) == "capacity_full",
            "third applicant should be blocked before Residence upgrade"):
        return
    var prior_supply := state.sect.supply_stock
    if not _assert(not NeedsSystem.new().expand_lodging(state, 1)
            and state.sect.supply_stock == prior_supply, "old +1 supply exploit still active"):
        return

    # Isolated authored QA treasury. Only the existing production/warehouse
    # consumer can actually commit materials; not a production player grant.
    var wh := WarehouseSystem.new()
    if not _assert(wh.add(state, BuildingSystem.MATERIAL_WOOD, 25000), "QA wood fixture failed"):
        return
    if not _assert(wh.add(state, BuildingSystem.MATERIAL_ORE, 18000), "QA ore fixture failed"):
        return
    state.sect.spirit_stones = 1000000
    var buildings := BuildingSystem.new()
    var cost := buildings.upgrade_cost(first)
    var money_before := state.sect.spirit_stones
    var begin := buildings.start_upgrade(state, first.id, "qa-house-upgrade-001-to-002")
    if not _assert(bool(begin.get("ok", false)), "cannot start Lv1→2 real building upgrade"):
        return
    if not _assert(state.sect.spirit_stones == money_before - int(cost["spirit_stones"]),
            "Residence upgrade did not debit exactly once"):
        return
    var repeated := buildings.start_upgrade(state, first.id, "qa-house-upgrade-001-to-002")
    if not _assert(bool(repeated.get("already_settled", false)) \
            and state.sect.spirit_stones == money_before - int(cost["spirit_stones"]),
            "repeat click must replay one paid start, not double debit"):
        return
    for _step in range(int(ceil(first.upgrade_required_work)) + 1):
        state.tick += 1
        buildings.process_tick(state)
    if not _assert(first.level == 2 and state.sect.lodging_capacity == 10 and state.sect.disciple_capacity == 10,
            "Lv2 upgrade did not grant 2 actual beds"):
        return
    # Replay of a delayed pre-upgrade UI event AFTER completion must not
    # advance the same House to Lv3 or spend a second time.
    var old_upgrade_replay := buildings.start_upgrade(state, first.id, "qa-house-upgrade-001-to-002")
    if not _assert(bool(old_upgrade_replay.get("already_settled", false)) \
            and first.level == 2 and not first.is_upgrading() \
            and state.sect.spirit_stones == money_before - int(cost["spirit_stones"]),
            "delayed duplicate upgrade advanced another level"):
        return
    if not _assert(recruit.can_accept_more(state), "Residence upgrade did not unlock ninth disciple"):
        return
    var ninth := recruit.accept_candidate(state, StringName(str(ids[2])))
    if not _assert(bool(ninth.get("ok", false)) and state.disciples.size() == 9, "third candidate not recruitable after upgrade"):
        return
    var ninth_id := StringName(str(ninth.get("disciple_id", "")))
    if not _assert(SectResidenceSystemV1.house_of(state, ninth_id) == str(first.id),
            "new disciple must be assigned to a real reserved bed"):
        return

    # A higher Hall is a test fixture only. Real game uses the paid timer.
    var hall := SectHallSystemV1.hall(state)
    hall.level = 11
    var second_cost := SectResidenceSystemV1.build_cost(state)
    var before_second := state.sect.spirit_stones
    var built := SectResidenceSystemV1.construct(state, "qa-house-build-002")
    if not _assert(bool(built.get("ok", false)), "second real Residence construction"):
        return
    if not _assert(SectResidenceSystemV1.all_houses(state).size() == 2
            and state.sect.spirit_stones == before_second - int(second_cost["spirit_stones"]),
            "second house count/cost incorrect"):
        return
    var duplicate := SectResidenceSystemV1.construct(state, "qa-house-build-002")
    if not _assert(bool(duplicate.get("already_settled", false))
            and state.sect.spirit_stones == before_second - int(second_cost["spirit_stones"])
            and SectResidenceSystemV1.all_houses(state).size() == 2, "replayed construction double-billed/duplicated"):
        return
    if not _assert(SectResidenceSystemV1.total_beds(state) == 18
            and SectResidenceSystemV1.current_limit(state) == 12,
            "rank 1 administrative cap must bind 2 houses with 18 beds"):
        return
    # DD-08: Hall level-up also has one durable paid start, both before and
    # after completion, not only an in-memory is_upgrading() click guard.
    var hall_cost := buildings.upgrade_cost(hall)
    var hall_stones_before := state.sect.spirit_stones
    var hall_start := buildings.start_upgrade(state, hall.id, "qa-hall-upgrade-012")
    if not _assert(bool(hall_start.get("ok", false)) and hall.is_upgrading(),
            "Hall paid upgrade not started"):
        return
    var hall_retry := buildings.start_upgrade(state, hall.id, "qa-hall-upgrade-012")
    if not _assert(bool(hall_retry.get("already_settled", false))
            and state.sect.spirit_stones == hall_stones_before - int(hall_cost["spirit_stones"]),
            "Hall upgrade replay double billed"):
        return
    for _hall_step in range(int(ceil(hall.upgrade_required_work)) + 1):
        state.tick += 1
        buildings.process_tick(state)
    var hall_late_retry := buildings.start_upgrade(state, hall.id, "qa-hall-upgrade-012")
    if not _assert(hall.level == 12 and not hall.is_upgrading()
            and bool(hall_late_retry.get("already_settled", false))
            and state.sect.spirit_stones == hall_stones_before - int(hall_cost["spirit_stones"]),
            "Hall late replay incorrectly triggered Lv13"):
        return
    # The extra house must be represented by an actual selectable canonical
    # building ID in the map projection, not only in UI text.
    var iso := SectIsometricWorldV1.new()
    root.add_child(iso)
    iso.refresh_from_state(state)
    var visible_houses: Dictionary = {}
    for row in iso.display_instances:
        if row["destination"] == SectMapPresentation.DEST_RESIDENCE and bool(row.get("managed", false)):
            visible_houses[str(row["building_id"])] = true
    if not _assert(visible_houses.has("residence_001") and visible_houses.has("residence_002")
            and visible_houses.size() == 2, "multi-house IDs not present on actual isometric world"):
        return
    root.remove_child(iso)
    iso.free()

    # Commit two real worksite warehouse deposits for an economic promotion
    # qualification; we don't invent production or prestige from a UI preview.
    var mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    var forest := buildings.primary_building(state, BuildingSystem.TYPE_LINH_FOREST)
    if not _assert(buildings._deposit_resource(state, mine, BuildingSystem.MATERIAL_ORE, 1)
            and buildings._deposit_resource(state, forest, BuildingSystem.MATERIAL_WOOD, 1),
            "real production receipt fixtures failed"):
        return
    var promotion := SectHallSystemV1.promotion_requirements(state)
    if not _assert(bool(promotion.get("ok", false)), "rank2 must evaluate genuine Hall/roster/production/prestige/cost"):
        return
    var before_promote := state.sect.spirit_stones
    var promote := SectHallSystemV1.promote(state, "qa-promotion-2")
    if not _assert(bool(promote.get("ok", false))
            and SectHallSystemV1.rank_index(state) == 2
            and state.sect.disciple_capacity == 18, "promotion didn't raise administrative population cap"):
        return
    var repeated_promotion := SectHallSystemV1.promote(state, "qa-promotion-2")
    if not _assert(bool(repeated_promotion.get("already_settled", false))
            and state.sect.spirit_stones == before_promote - int(promotion["cost"]["spirit_stones"]),
            "replaying promotion charged twice"):
        return

    var saved := SimulationState.from_dict(state.to_dict())
    if not _assert(saved != null and SectResidenceSystemV1.total_beds(saved) == 18
            and SectHallSystemV1.rank_index(saved) == 2
            and SectResidenceSystemV1.all_houses(saved).size() == 2,
            "Save/Reload lost houses or rank"):
        return
    if not _assert(SectResidenceSystemV1.house_of(saved, ninth_id) == str(first.id),
            "room assignment lost during reload"):
        return
    if not _assert(SectHallSystemV1.validate(saved).is_empty(), "Hall/Residence loaded invariants fail"):
        return
    # Durable SaveService path, not only an in-memory to_dict roundtrip.
    var qa_path := "user://qa_dd02_housing_20261101.json"
    var saver := SaveService.new()
    if not _assert(saver.save_to_path(saved, qa_path) == OK, "SaveService durable write failed"):
        return
    var durable := saver.load_from_path(qa_path)
    if not _assert(durable != null and SectHallSystemV1.rank_index(durable) == 2
            and SectResidenceSystemV1.total_beds(durable) == 18
            and SectResidenceSystemV1.house_of(durable, ninth_id) == str(first.id),
            "SaveService durable reload failed"):
        return
    if not _assert(SectHallSystemV1.validate(durable).is_empty(),
            "durable loaded Hall/Residence invariant fail"):
        return
    # Use only the dedicated QA path. Never remove other user saves.
    DirAccess.remove_absolute(ProjectSettings.globalize_path(qa_path))
    DirAccess.remove_absolute(ProjectSettings.globalize_path(qa_path + ".bak"))
    if not _assert(SectHallSystemV1.RANK_LIMITS.size() == 27
            and SectHallSystemV1.RANK_HALL_LEVELS.size() == 27
            and SectHallSystemV1.RANK_LIMITS[8] == 90
            and SectHallSystemV1.RANK_LIMITS[17] == 200
            and SectHallSystemV1.RANK_LIMITS[26] == 480
            and SectResidenceSystemV1.beds_for_level(100) == 206,
            "invalid 27-rank / 100-level residence content catalogue"):
        return
    var corrupt := SimulationState.from_dict(saved.to_dict())
    corrupt.sect.hall_governance["residence_assignments"] = "malformed"
    var invalid := SectHallSystemV1.ensure_live(corrupt)
    if not _assert(not bool(invalid.get("ok", true)),
            "malformed house save must fail closed, not silently reset rooms"):
        return
    var view := DaiDienScreenV1.new()
    view.attach_state(saved)
    root.add_child(view)
    view._tab(5)
    if not _assert(view.get_node_or_null("DaiDienDialog") != null and view.active_tab == 5,
            "Godot Residence tab not instantiated"):
        return
    if not _assert(view.get_node_or_null("DaiDienDialog") != null
            and not view._room_disciple_ids.is_empty() and view._room_house_ids.size() == 2,
            "compact room assignment selectors must exist"):
        return
    var move_disciple := view._room_disciple_ids.find(ninth_id)
    var move_house := view._room_house_ids.find(&"residence_002")
    if not _assert(move_disciple >= 0 and move_house >= 0, "ninth disciple / second Residence selectable"):
        return
    view._room_selected_disciple = move_disciple
    view._room_selected_house = move_house
    view._assign_room()
    if not _assert(SectResidenceSystemV1.house_of(saved, ninth_id) == "residence_002",
            "real UI manual room assignment did not update canonical state"):
        return
    root.remove_child(view)
    view.free()
    print("DAI_DIEN_HOUSING_FULL_LOOP_PASS recruit=8to9 beds=8to10 house_instances=2 price_once=1 rank=2 save_reload=1 godot_ui=1")
    quit(0)
