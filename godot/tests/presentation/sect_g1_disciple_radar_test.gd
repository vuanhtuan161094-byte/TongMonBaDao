extends SceneTree

const SAVE_PATH := "user://sect_g1_disciple_radar_test.json"
var ui: Control

func _init() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("G1 RADAR/SOURCE A FAIL: "+message)
    if ui != null:
        ui.queue_free()
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)
    quit(1)

func _run() -> void:
    var radar := DiscipleSixDimensionRadar.new()
    var payload := {"ok":true,"foundations":{"model_version":2,"current":{
        "aptitude":4400.0,"constitution":3200.0,"fortune":2800.0,
        "comprehension":3700.0,"charisma":6500.0,"potential":5100.0
    }}}
    if not radar.apply_snapshot(payload):
        _fail("valid foundation snapshot rejected")
        return
    if radar.dimension_values.size() != 6 or radar.dimension_values[4] != 6500.0 or radar.chart_ceiling != 7000.0:
        _fail("canonical points or dynamic drawing scale wrong")
        return
    if radar.apply_snapshot({"ok":true,"foundations":{"current":{"aptitude":1.0}}}):
        _fail("incomplete six-point payload accepted")
        return
    if radar.dimension_values[4] != 6500.0:
        _fail("rejected payload mutated a previously valid chart")
        return

    var female := DiscipleState.new({"id":"visual_female","name":"Nữ Thử","sex_id":"female","profile_seed":31})
    var male := DiscipleState.new({"id":"visual_male","name":"Nam Thử","sex_id":"male","profile_seed":31})
    var female_path := DiscipleSourceAVisualPool.scene_path_for_disciple(female)
    if female_path != "res://assets/actors/1113028_1/actor.tscn" or female_path != DiscipleSourceAVisualPool.scene_path_for_disciple(female):
        _fail("female visual is not verified and deterministic")
        return
    if DiscipleSourceAVisualPool.scene_for_disciple(female) == null:
        _fail("verified female PackedScene missing")
        return
    if DiscipleSourceAVisualPool.scene_path_for_disciple(male) != "" or DiscipleSourceAVisualPool.scene_for_disciple(male) != null:
        _fail("female-only art assigned to male")
        return

    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed == null:
        _fail("real map scene missing")
        return
    ui = packed.instantiate() as Control
    root.add_child(ui)
    for i in range(3):
        await process_frame
    if not bool(ui.get("runtime_ready")):
        _fail("scene runtime not ready")
        return
    var state := ui.get("state") as SimulationState
    if state == null or state.disciples.is_empty():
        _fail("real scene has no canonical disciples")
        return
    # Recruit an authentic V2 actor through the real state/recruitment API.
    # The initial sect roster may include historical P2 compatibility actors.
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,778
    )
    if candidate == null or candidate.v2_birth_profile.is_empty():
        _fail("cannot generate canonical V2 recruit")
        return
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    if not bool(accepted.get("ok",false)):
        _fail("canonical recruitment failed")
        return
    var disciple := state.disciples.get(candidate.id) as DiscipleState
    if disciple == null or not DiscipleRealmProgressV2.progression_ready(disciple):
        _fail("recruit was not authentic Realm/Body V2")
        return
    var saved := disciple.to_dict()
    var attributes := str(ui.call("_disciple_tab_text","Thuộc tính",disciple))
    if not attributes.contains("ẢNH HƯỞNG LỤC DUY") or not attributes.contains("Tiềm Lực: +0,05%"):
        _fail("attribute explanations are missing or do not match V2 authority")
        return
    ui.call("_open_disciple_deep_screen",disciple.id,"Thuộc tính")
    await process_frame
    var deep := (ui.get("popup_layer") as Control).get_node_or_null("DiscipleDeepScreen")
    if deep == null:
        _fail("deep screen missing")
        return
    var chart := deep.find_child("DiscipleSixDimensionRadar",true,false) as DiscipleSixDimensionRadar
    if chart == null or chart.dimension_values.size() != 6:
        _fail("six-axis read-only chart missing")
        return
    var snapshot := DisciplePresentationSnapshotV2.build(state,disciple)
    var real_points: Dictionary = snapshot["foundations"]["current"]
    for idx in range(DiscipleSixDimensionRadar.KEYS.size()):
        var key := str(DiscipleSixDimensionRadar.KEYS[idx])
        if not is_equal_approx(chart.dimension_values[idx],float(real_points[key])):
            _fail("chart differs from saved foundation: "+key)
            return
    ui.call("_open_disciple_deep_screen",disciple.id,"Trang bị")
    await process_frame
    deep = (ui.get("popup_layer") as Control).get_node_or_null("DiscipleDeepScreen")
    if deep == null or deep.find_child("DiscipleSixDimensionRadar",true,false) != null:
        _fail("chart leaked into another tab")
        return
    if disciple.to_dict() != saved:
        _fail("read-only G1 UI mutated gameplay")
        return
    ui.queue_free()
    ui = null
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
    print("G1 DISCIPLE RADAR + VERIFIED SOURCE A POOL: PASS")
    quit(0)
