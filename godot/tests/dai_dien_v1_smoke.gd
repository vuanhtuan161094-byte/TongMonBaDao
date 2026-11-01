extends SceneTree

# DD-01 focused candidate smoke. Must run with OFFICIAL Godot 4.7.2 Windows.
# godot --headless --path godot --script res://tests/dai_dien_v1_smoke.gd

func _initialize() -> void:
    call_deferred("_run")

func _check(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error("DAI_DIEN_V1_FAIL: " + message)
    quit(1)
    return false

func _run() -> void:
    var state: SimulationState = P37Factory.create_state(20261101)
    var installed := SectHallSystemV1.ensure_live(state)
    if not _check(bool(installed.get("ok", false)), "Hall install failed"):
        return
    var hall := SectHallSystemV1.hall(state)
    if not _check(hall != null and hall.id == &"main_hall_001" and hall.level == 1, "missing canonical Hall"):
        return
    SectHallSystemV1.ensure_live(state)
    var count := 0
    for building in state.buildings.values():
        if building is BuildingState and building.building_type == BuildingSystem.TYPE_MAIN_HALL:
            count += 1
    if not _check(count == 1, "duplicate Hall instance after repeated installation"):
        return

    # New V2 recruits own a complete realm progression, unlike older founders
    # that may legitimately retain legacy progression fields.
    state.sect.disciple_v2_birth_enabled = true
    var candidates: Array = state.recruitment_candidates.keys()
    candidates.sort()
    if not _check(not candidates.is_empty(), "missing initial recruit candidates"):
        return
    var accepted := RecruitmentSystem.new().accept_candidate(state, StringName(str(candidates[0])))
    if not _check(bool(accepted.get("ok", false)), "could not create V2 recruitment fixture"):
        return
    var master_id := StringName(str(accepted.get("disciple_id", "")))
    var ids: Array = state.disciples.keys()
    ids.sort()
    var teacher_id := &""
    for raw_id in ids:
        if StringName(raw_id) != master_id:
            teacher_id = StringName(raw_id)
            break
    if not _check(teacher_id != &"", "second real disciple missing"):
        return
    if not _check(bool(SectHallSystemV1.appoint(state, SectHallSystemV1.OFFICE_MASTER, master_id).get("ok", false)), "cannot appoint real Chưởng Môn"):
        return
    if not _check(bool(SectHallSystemV1.appoint(state, SectHallSystemV1.OFFICE_TEACHER, teacher_id).get("ok", false)), "cannot appoint Truyền Công"):
        return
    var duplicate := SectHallSystemV1.can_appoint(state, SectHallSystemV1.OFFICE_TEACHER, master_id)
    if not _check(not bool(duplicate.get("ok", true)), "a disciple can hold two main offices"):
        return
    var actor: DiscipleState = state.disciples[master_id]
    var sources := SectHallSystemV1.cultivation_sources(state, actor)
    if not _check(sources.size() == 3, "Master D7 and the two natural-XP roles must expose exactly three additive sources"):
        return
    var baseline_factor := FoundationSystem.new().cultivation_gain_factor(actor.aptitude)
    # Preview's contract is tested by real source factory, without granting XP.
    var preview := DiscipleRealmProgressV2.grant_xp(
        actor, "cultivation", 10.0, "natural",
        DiscipleProgressionBalanceV2.floor_costs(), sources, true
    )
    if not _check(bool(preview.get("ok", false)), "natural XP source rejected"):
        return
    var exact_sources := 0.0
    for source in sources:
        exact_sources += float(source.get("value", 0.0))
    if not _check(absf(float(preview.get("natural_factor", 0.0)) - baseline_factor - exact_sources) < 0.0001,
            "office sources did not combine additively on natural XP"):
        return
    var fixed := DiscipleRealmProgressV2.grant_xp(
        actor, "cultivation", 100.0, "fixed",
        DiscipleProgressionBalanceV2.floor_costs(), sources, true
    )
    if not _check(bool(fixed.get("ok", false)) and absf(float(fixed.get("gained", 0.0)) - 100.0) < 0.001,
            "offices must never multiply fixed-value pill XP"):
        return

    state.tick = 10
    SectHallSystemV1.record_cultivation(state, actor, 10.0)
    var first := SectHallSystemV1.mastery(state, SectHallSystemV1.OFFICE_MASTER, str(master_id))
    if not _check(int(first["xp"]) == SectHallSystemV1.ACTIVITY_EXP, "genuine activity did not award mastery"):
        return
    SectHallSystemV1.record_cultivation(state, actor, 10.0)
    var replay := SectHallSystemV1.mastery(state, SectHallSystemV1.OFFICE_MASTER, str(master_id))
    if not _check(int(replay["xp"]) == int(first["xp"]), "same-day mastery duplicated"):
        return

    # No source scenes and no second SaveService: check the exact existing state codec.
    var restored := SimulationState.from_dict(state.to_dict())
    if not _check(restored != null, "simulation roundtrip failed"):
        return
    if not _check(SectHallSystemV1.holder_id(restored, SectHallSystemV1.OFFICE_MASTER) == str(master_id),
            "appointment missing after reload"):
        return
    if not _check(int(SectHallSystemV1.mastery(restored, SectHallSystemV1.OFFICE_MASTER, str(master_id))["xp"]) == int(first["xp"]),
            "mastery missing after reload"):
        return
    if not _check(SectHallSystemV1.validate(restored).is_empty(), "restored office invariants failed"):
        return

    # Real native Godot UI node; no HTML proxy.
    var view := DaiDienScreenV1.new()
    view.attach_state(restored)
    root.add_child(view)
    if not _check(view.get_node_or_null("DaiDienDialog") != null, "native Hall dialog not constructed"):
        return
    view._tab(1)
    if not _check(view.active_tab == 1, "office tab not interactive"):
        return
    root.remove_child(view)
    view.free()

    if not _check(bool(SectHallSystemV1.dismiss(restored, SectHallSystemV1.OFFICE_MASTER).get("ok", false)),
            "dismissal failed"):
        return
    if not _check(SectHallSystemV1.cultivation_sources(restored, restored.disciples[master_id]).size() == 1,
            "personal buff persists after dismissal"):
        return
    if not _check(int(SectHallSystemV1.mastery(restored, SectHallSystemV1.OFFICE_MASTER, str(master_id))["xp"]) == int(first["xp"]),
            "dismissal erased career growth"):
        return
    print("DAI_DIEN_V1_SMOKE_PASS hall_singleton=1 offices=2 natural_xp=1 fixed_xp_untouched=1 mastery_exactly_once=1 save_roundtrip=1 native_ui=1")
    quit(0)
