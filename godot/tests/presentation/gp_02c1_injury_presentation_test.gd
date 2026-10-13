extends SceneTree

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var state := P37Factory.create_state(34892)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.disciple_capacity = state.disciples.size() + 1
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state, DiscipleGeneratorV2.SOURCE_ORDINARY, 9345)
    if candidate == null:
        push_error("GP-02C1 presentation: missing real V2 candidate")
        quit(1)
        return
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    if not bool(accepted.get("ok",false)):
        push_error("GP-02C1 presentation: V2 recruitment not accepted")
        quit(1)
        return
    var actor: DiscipleState = state.disciples[candidate.id]
    actor.injury_level = 1
    actor.injury_recover_at_tick = state.tick + 120
    var snap := DisciplePresentationSnapshotV2.build(state,actor)
    var life: Dictionary = snap.get("life",{})
    if not bool(snap.get("ok",false)) or int(life.get("injury_level",-1)) != 1 or int(life.get("injury_remaining_ticks",-1)) != 120:
        push_error("GP-02C1 presentation: real Injury projection failed")
        quit(1)
        return
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        push_error("GP-02C1 presentation: missing existing P3.2 landscape scene")
        quit(1)
        return
    var ui := scene.instantiate() as Control
    root.add_child(ui)
    await process_frame
    var desc := str(ui.call("_v2_disciple_summary_text",snap))
    var healthy_snap := snap.duplicate(true)
    healthy_snap["life"] = life.duplicate(true)
    healthy_snap["life"]["injury_level"] = 0
    healthy_snap["life"]["injury_remaining_ticks"] = 0
    var clear_desc := str(ui.call("_v2_disciple_summary_text",healthy_snap))
    if not desc.contains("Thương Thế: Đang hồi phục") or not desc.contains("120 phút") or not clear_desc.contains("Thương Thế: Khỏe mạnh"):
        push_error("GP-02C1 presentation: landscape summary did not render real Injury states")
        quit(1)
        return
    root.remove_child(ui)
    ui.queue_free()
    print("GP-02C1 V2 REAL INJURY PRESENTATION PASS")
    quit(0)
