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
    var d7_snapshot := {"ok":true,"foundations":{"model_version":3,"current":{
        "aptitude":90.0,"constitution":100.0,"mind_nature":75.0,
        "potential":120.0,"comprehension":110.0,"fortune":80.0,"charisma":95.0
    }}}
    if not radar.apply_snapshot(d7_snapshot) or radar.dimension_values.size() != 7 or radar.dimension_keys != DiscipleSixDimensionRadar.D7_KEYS:
        _fail("D7 profile did not switch to the seven authentic Tam Can/Tu Tinh axes")
        return
    if radar.dimension_values[2] != 75.0 or radar.dimension_values[6] != 95.0:
        _fail("D7 seventh-axis values do not match the saved snapshot")
        return
    # CanvasItem allocated without a parent must be explicitly released.
    radar.free()

    var female := DiscipleState.new({"id":"visual_female","name":"Nữ Thử","sex_id":"female","profile_seed":31})
    var male := DiscipleState.new({"id":"visual_male","name":"Nam Thử","sex_id":"male","profile_seed":31})
    var female_path := DiscipleSourceAVisualPool.scene_path_for_disciple(female)
    if female_path != "res://assets/actors/1113028_1/actor.tscn" or female_path != DiscipleSourceAVisualPool.scene_path_for_disciple(female):
        _fail("female visual is not verified and deterministic")
        return
    if DiscipleSourceAVisualPool.scene_for_disciple(female) == null:
        _fail("verified female PackedScene missing")
        return
    var male_path := DiscipleSourceAVisualPool.scene_path_for_disciple(male)
    if male_path.is_empty() or male_path != DiscipleSourceAVisualPool.scene_path_for_disciple(male) or male_path == female_path:
        _fail("verified male visual missing, unstable or using female art")
        return
    for id in ["body_1110201","body_1120402"]:
        var base := "res://assets/actors/%s/" % id
        var manifest := JSON.parse_string(FileAccess.get_file_as_string(base+"asset.json")) as Dictionary
        if manifest.is_empty() or str(manifest.get("id","")) != id:
            _fail("male Source A provenance manifest missing: "+id)
            return
        var hashes := manifest.get("file_sha256",{}) as Dictionary
        if hashes.is_empty():
            _fail("male Source A hashes missing: "+id)
            return
        for filename in hashes.keys():
            if FileAccess.get_sha256(base+str(filename)).to_lower() != str(hashes[filename]):
                _fail("male Source A SHA-256 mismatch: "+id+"/"+str(filename))
                return
        var rig := load(base+"actor.tscn") as PackedScene
        var sprite := rig.instantiate() as AnimatedSprite2D if rig != null else null
        if sprite == null or sprite.sprite_frames == null:
            _fail("male Source A PackedScene missing: "+id)
            return
        if not sprite.sprite_frames.has_animation(&"stand") or not sprite.sprite_frames.has_animation(&"walk"):
            sprite.free()
            _fail("male Source A stand/walk missing: "+id)
            return
        var crop := manifest.get("crop",[]) as Array
        var foot := manifest.get("foot_anchor",[]) as Array
        var frame := sprite.sprite_frames.get_frame_texture(&"stand",0)
        if crop.size() != 4 or foot.size() != 2 or frame == null or frame.get_size() != Vector2(crop[2],crop[3]) or sprite.offset != Vector2(float(crop[0])-float(foot[0]),float(crop[1])-float(foot[1])):
            sprite.free()
            _fail("male Source A crop/foot anchor mismatch: "+id)
            return
        sprite.free()
    if DiscipleSourceAVisualPool.scene_for_disciple(male) == null:
        _fail("verified male Source A scene unavailable")
        return

    # The fallback still covers unavailable/production-body cases,
    # driven only by the same stable cosmetic appearance seed.
    var fallback := ModularDiscipleActor.new()
    fallback.configure(male)
    var robe := fallback.fallback_visual.get_node_or_null("Torso") as Panel
    var head := fallback.fallback_visual.get_node_or_null("Head") as Panel
    var hair := fallback.fallback_visual.get_node_or_null("Hair") as Panel
    if robe == null or head == null or hair == null:
        fallback.free()
        _fail("male fallback missing robe/face/hair")
        return
    var robe_style := robe.get_theme_stylebox("panel") as StyleBoxFlat
    var head_style := head.get_theme_stylebox("panel") as StyleBoxFlat
    var hair_style := hair.get_theme_stylebox("panel") as StyleBoxFlat
    var palette_ok := robe_style != null and head_style != null and hair_style != null
    if palette_ok:
        palette_ok = (
            not robe_style.bg_color.is_equal_approx(ModularDiscipleActor.PLACEHOLDER_FILL)
            and not head_style.bg_color.is_equal_approx(hair_style.bg_color)
        )
    fallback.free()
    if not palette_ok:
        _fail("unconverted male still renders as a uniform green marker")
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

    # Characters can be listed before they have a live map actor (roster
    # paging / large sect); verified Source A art must still be their portrait.
    # Check the exact same shared Texture2D is reused, not per-actor atlases.
    for visual_disciple in [male,female]:
        if (ui.get("actor_nodes") as Dictionary).has(str(visual_disciple.id)):
            _fail("off-map portrait fixture was unexpectedly added to map")
            return
        var off_map_avatar := ui.call("_disciple_avatar_button",visual_disciple,44.0) as Button
        var true_portrait := off_map_avatar.get_node_or_null("VerifiedSourceAPortrait") as TextureRect
        var shared_texture := ui.call("_disciple_source_a_portrait_texture",visual_disciple) as Texture2D
        if true_portrait == null or shared_texture == null or true_portrait.texture != shared_texture:
            off_map_avatar.free()
            _fail("off-map disciple avatar did not use cached verified Source A")
            return
        off_map_avatar.free()
    var portrait_cache := ui.get("source_a_portrait_textures") as Dictionary
    if (
        not portrait_cache.has(DiscipleSourceAVisualPool.scene_path_for_disciple(male))
        or not portrait_cache.has(DiscipleSourceAVisualPool.scene_path_for_disciple(female))
        or portrait_cache.size() > DiscipleSourceAVisualPool.VERIFIED_ACTORS.size()
    ):
        _fail("off-map Source A cache does not match the verified scene pool")
        return
    # Recruit an authentic V2 actor through the real state/recruitment API.
    # The initial sect roster may include historical P2 compatibility actors.
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
    # Use the canonical deterministic generator, but choose an index whose
    # generated candidate id is not already occupied by the fixture roster.
    var generation_index := 778
    var candidate_id := StringName("candidate_%04d" % generation_index)
    while state.disciples.has(candidate_id) or state.recruitment_candidates.has(candidate_id):
        generation_index += 1
        candidate_id = StringName("candidate_%04d" % generation_index)
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,generation_index
    )
    if candidate == null or candidate.v2_birth_profile.is_empty():
        _fail("cannot generate canonical V2 recruit")
        return
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    if not bool(accepted.get("ok",false)):
        _fail("canonical recruitment failed: "+str(accepted))
        return
    var disciple := state.disciples.get(candidate.id) as DiscipleState
    if disciple == null or not DiscipleRealmProgressV2.progression_ready(disciple):
        _fail("recruit was not authentic Realm/Body V2")
        return
    var saved := disciple.to_dict()

    # G1.5 UI-only: all listed choices must correspond to REAL buildings.
    # Merely opening/closing this selector cannot commit a job or mutate V2.
    ui.call("_open_disciple_quick_assignment",disciple.id)
    await process_frame
    var chooser := (ui.get("popup_layer") as Control).get_node_or_null("DiscipleQuickAssignment")
    if chooser == null or chooser.find_child("DiscipleQuickAssignmentScroll",true,false) == null:
        _fail("playable quick-assignment panel missing")
        return
    var existing_count := 0
    for building_type in [BuildingSystem.TYPE_MINE,BuildingSystem.TYPE_LINH_FOREST,BuildingSystem.TYPE_SPIRIT_FIELD]:
        var actual_instances: Array[BuildingState] = []
        for raw_building in state.buildings.values():
            if raw_building is BuildingState and (raw_building as BuildingState).building_type == building_type:
                actual_instances.append(raw_building)
        for building in actual_instances:
            existing_count += 1
            var target_button := chooser.find_child("QuickAssignTarget_%s" % str(building.id),true,false) as Button
            if target_button == null:
                _fail("a real production instance cannot be selected: "+str(building.id))
                return
            if target_button.disabled and target_button.tooltip_text.is_empty():
                _fail("blocked building does not show eligibility reason")
                return
    if existing_count == 0:
        _fail("quick assignment listed no actual producer instances")
        return
    if disciple.to_dict() != saved:
        _fail("opening quick assignment modified the disciple's job")
        return
    ui.call("_return_from_disciple_quick_assignment",disciple.id,false)
    await process_frame
    var returned := (ui.get("popup_layer") as Control).get_node_or_null("DiscipleDeepScreen")
    if returned == null or returned.find_child("DeepQuickAssignment",true,false) == null:
        _fail("assignment back button did not restore disciple profile")
        return

    # User video 17:33: all quick targets disabled on a pending command.
    # Press the real button and ensure only the pending command is cleared.
    # Prefer a Mine, then use another real idle producer if every Mine is
    # already staffed in this canonical fixture.
    var live_producer: BuildingState = null
    var building_system := BuildingSystem.new()
    for preferred_type in [BuildingSystem.TYPE_MINE,BuildingSystem.TYPE_LINH_FOREST,BuildingSystem.TYPE_SPIRIT_FIELD]:
        var matching: Array[BuildingState] = []
        for raw_building in state.buildings.values():
            if raw_building is BuildingState and (raw_building as BuildingState).building_type == preferred_type:
                matching.append(raw_building)
        matching.sort_custom(func(a: BuildingState,b: BuildingState) -> bool: return str(a.id)<str(b.id))
        for producer in matching:
            if building_system.assigned_worker_ids(state,producer).is_empty():
                live_producer = producer
                break
        if live_producer != null:
            break
    if live_producer == null:
        _fail("quick-cancel fixture has no idle real producer")
        return
    var before_workers := building_system.assigned_worker_ids(state,live_producer)
    var before_items := disciple.inventory.duplicate(true)
    if not WorkforceSystem.new().issue_command(
        state,disciple.id,WorkforceSystem.COMMAND_HOLD,"",40
    ):
        _fail("cannot stage a legitimate pending Workforce HOLD")
        return
    ui.call("_open_disciple_quick_assignment",disciple.id)
    await process_frame
    chooser = (ui.get("popup_layer") as Control).get_node_or_null("DiscipleQuickAssignment")
    var cancel_pending := chooser.find_child("QuickAssignmentCancelPendingCommand",true,false) as Button if chooser != null else null
    var producer_before := chooser.find_child("QuickAssignTarget_%s" % str(live_producer.id),true,false) as Button if chooser != null else null
    if cancel_pending == null or producer_before == null or not producer_before.disabled:
        _fail("pending job is not safely blocked with a visible cancel action")
        return
    cancel_pending.pressed.emit()
    await process_frame
    chooser = (ui.get("popup_layer") as Control).get_node_or_null("DiscipleQuickAssignment")
    var producer_after := chooser.find_child("QuickAssignTarget_%s" % str(live_producer.id),true,false) as Button if chooser != null else null
    if not disciple.direct_command.is_empty() or producer_after == null or producer_after.disabled:
        var occupants_after := building_system.assigned_worker_ids(state,live_producer)
        var reason_after := str(ui.call("_workforce_candidate_reason",disciple,live_producer,occupants_after))
        _fail("explicit pending-command cancellation failed to enable idle producer choice; type=%s direct=%s action=%s occupants=%s reason=%s tooltip=%s" % [str(live_producer.building_type),str(disciple.direct_command),str(disciple.current_action),str(occupants_after),reason_after,"<missing>" if producer_after == null else producer_after.tooltip_text])
        return
    if disciple.inventory != before_items or not disciple.work_cycle_state.is_empty():
        _fail("quick cancel touched inventory or an active work cycle")
        return
    if building_system.assigned_worker_ids(state,live_producer) != before_workers:
        _fail("cancel button implicitly assigned or removed a worker")
        return
    ui.call("_return_from_disciple_quick_assignment",disciple.id,false)
    await process_frame

    var attributes := str(ui.call("_disciple_tab_text","Thuộc tính",disciple))
    if not attributes.contains("ẢNH HƯỞNG LỤC DUY") or not attributes.contains("Tiềm Lực: +0,05% Tu Vi RealmCore") or attributes.contains("Tâm Tính"):
        _fail("attribute explanations are missing or do not match V2 authority")
        return
    ui.call("_open_disciple_deep_screen",disciple.id,"Thuộc tính")
    await process_frame
    var deep := (ui.get("popup_layer") as Control).get_node_or_null("DiscipleDeepScreen")
    if deep == null:
        _fail("deep screen missing")
        return
    var chart := deep.find_child("DiscipleFoundationRadar",true,false) as DiscipleSixDimensionRadar
    if chart == null or chart.dimension_values.size() != 7:
        _fail("D7 seven-axis read-only chart missing")
        return
    var snapshot := DisciplePresentationSnapshotV2.build(state,disciple)
    var real_points: Dictionary = snapshot["foundations"]["current"]
    for idx in range(DiscipleSixDimensionRadar.D7_KEYS.size()):
        var key := str(DiscipleSixDimensionRadar.D7_KEYS[idx])
        if not is_equal_approx(chart.dimension_values[idx],float(real_points[key])):
            _fail("chart differs from saved foundation: "+key)
            return
    ui.call("_open_disciple_deep_screen",disciple.id,"Trang bị")
    await process_frame
    deep = (ui.get("popup_layer") as Control).get_node_or_null("DiscipleDeepScreen")
    if deep == null or deep.find_child("DiscipleFoundationRadar",true,false) != null:
        _fail("chart leaked into another tab")
        return
    if disciple.to_dict() != saved:
        _fail("read-only G1 UI mutated gameplay")
        return
    ui.queue_free()
    await process_frame
    ui = null
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
    print("G1 DISCIPLE RADAR + VERIFIED SOURCE A POOL: PASS")
    quit(0)
