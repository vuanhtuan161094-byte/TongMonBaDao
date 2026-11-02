extends SceneTree
## Capture the genuine P3.2 main scene and open each B1 screen via its live management button.
## A dedicated user:// QA save path is used; no default player save is read or written.
const GAME = preload("res://scenes/p3/p3_2_landscape_sect.tscn")
const SAVE_PATH := "user://tri02_live_ui_capture_isolated.json"
const CAPTURE_FILES := {
    "hall":"01_hall_live_state.png",
    "residence":"02_residence_live_state.png",
    "guidance":"03_guidance_live_state.png"
}
const REQUIRED_MAP_ART := {
    "main_hall": "pv01_assets/main_hall/510052.png",
    "residence": "pv01_assets/residence/510076.png",
    "guidance": "pv01_assets/guidance/510111.png"
}

var game: Control

func _initialize() -> void:
    call_deferred("_capture")

func _capture() -> void:
    print("TRI02_CAPTURE_STAGE=start")
    var argv := OS.get_cmdline_user_args()
    if argv.is_empty():
        _fail("Pass isolated absolute screenshot output directory after --.")
        return
    var out_dir: String = argv[0]
    DirAccess.make_dir_recursive_absolute(out_dir)
    _remove_test_save()
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    DisplayServer.window_set_size(Vector2i(1280,720))

    game = GAME.instantiate() as Control
    if game == null:
        _fail("Could not instantiate the real P3.2 main scene.")
        return
    root.add_child(game)
    print("TRI02_CAPTURE_STAGE=scene_added")
    await process_frame
    await process_frame
    print("TRI02_CAPTURE_STAGE=two_frames")
    if game.get("state") == null or not bool(game.get("runtime_ready")):
        _fail("P3.2 live runtime did not start with the isolated QA save.")
        return

    print("TRI02_CAPTURE_STAGE=runtime_ready")
    var state: SimulationState = game.get("state") as SimulationState
    if not SectHallSystemV1.installed(state):
        var install: Dictionary = SectHallSystemV1.ensure_live(state)
        if not bool(install.get("ok",false)):
            _fail("Canonical Hall/Residence prerequisites are unavailable.")
            return
        game.call("_refresh_all")
        await process_frame

    var world = game.get("iso_world")
    if world == null:
        _fail("P3.2 main scene has no isometric world renderer.")
        return
    var loaded_art: Dictionary = world.get("render_art")
    var world_script := world.get_script() as Script
    if world_script == null:
        _fail("P3.2 world renderer script is unavailable.")
        return
    var constants: Dictionary = world_script.get_script_constant_map()
    var texture_map: Dictionary = constants.get("HOUSE_TEXTURES",{})
    var size_map: Dictionary = constants.get("HOUSE_SIZES",{})
    print("TRI02_CAPTURE_STAGE=verify_map_art")
    for kind in REQUIRED_MAP_ART:
        var relative: String = REQUIRED_MAP_ART[kind]
        if str(texture_map.get(kind,"")) != relative or not loaded_art.has(relative):
            _fail("P3.2 map did not bind its SHA-gated Source A %s sprite." % kind)
            return
        var texture: Texture2D = loaded_art[relative] as Texture2D
        var target_size: Vector2 = size_map.get(kind,Vector2.ZERO)
        if texture == null or target_size.x <= 0.0 or target_size.y <= 0.0:
            _fail("P3.2 map has no renderable texture/size for %s." % kind)
            return
        var source_ratio := float(texture.get_width())/float(texture.get_height())
        if absf(source_ratio-target_size.x/target_size.y) > 0.01:
            _fail("P3.2 map would distort Source A %s." % kind)
            return
        if not _verify_source_alpha(relative,kind):
            return

    print("TRI02_CAPTURE_STAGE=map_art_verified")
    if not await _save_frame(out_dir,"00_p3_2_map_context.png"):
        return
    game.call("_enter_build_mode")
    await process_frame
    await process_frame
    var map_build_button := _find_button(game,"BuildCatalogResidence")
    var map_confirm_button := _find_button(game,"ConfirmMapConstruction")
    print("TRI02_BUILD_MODE_STATE residence_catalog=%s confirm_disabled=%s" % [
        str(map_build_button != null),str(map_confirm_button == null or map_confirm_button.disabled)
    ])
    if not await _save_frame(out_dir,"04_build_mode_new_game_gates.png"):
        return
    game.call("_leave_build_mode",true)
    await process_frame
    if not await _open_from_map("hall","510052",SectMapPresentation.DEST_MAIN_HALL,"OpenDaiDienScreenV1",out_dir,CAPTURE_FILES["hall"]):
        return
    if not await _open_from_map("residence","510076",SectMapPresentation.DEST_RESIDENCE,"OpenResidenceManagementV1",out_dir,CAPTURE_FILES["residence"]):
        return
    if not await _open_from_map("guidance","510111",SectMapPresentation.DEST_GUIDANCE,"OpenDanTienScreenV2",out_dir,CAPTURE_FILES["guidance"]):
        return

    # Continue the real New Game journey through the B1 controls: the map opens
    # the facility, the player confirms a valid candidate, the canonical roster
    # changes once, and the success reveal is rendered and saved in QA user://.
    var state_after_open: SimulationState = game.get("state") as SimulationState
    if state_after_open == null:
        _fail("Recruitment reveal QA lost the canonical P3.2 state.")
        return
    var roster_before := state_after_open.disciples.size()
    var ids_before: Dictionary = {}
    for raw_id in state_after_open.disciples.keys():
        ids_before[str(raw_id)] = true
    game.call("_open_building",SectMapPresentation.DEST_GUIDANCE)
    await process_frame
    await process_frame
    var guidance_route := _find_button(game,"OpenDanTienScreenV2")
    if guidance_route == null or guidance_route.disabled:
        _fail("Cannot reopen the live Dẫn Tiên Đài from the P3.2 map for recruitment.")
        return
    guidance_route.pressed.emit()
    await process_frame
    await process_frame
    var guidance := game.get_node_or_null("DanTienScreenV2")
    var accept := _find_button(guidance,"AcceptCandidate") if guidance != null else null
    if accept == null or accept.disabled:
        _fail("New Game must expose at least one genuinely eligible candidate with spare canonical capacity.")
        return
    accept.pressed.emit()
    await process_frame
    accept = _find_button(guidance,"AcceptCandidate")
    if accept == null or not accept.text.contains("XÁC NHẬN"):
        _fail("Candidate acceptance must show the existing second-confirmation state.")
        return
    accept.pressed.emit()
    await process_frame
    await process_frame
    if state_after_open.disciples.size() != roster_before + 1:
        _fail("Confirmed candidate did not enter the single canonical disciple roster exactly once.")
        return
    var recruited_id := ""
    for raw_id in state_after_open.disciples.keys():
        if not ids_before.has(str(raw_id)):
            recruited_id = str(raw_id)
            break
    var recruited_state: DiscipleState = state_after_open.disciples.get(StringName(recruited_id))
    var recruited_scene_path := DiscipleSourceAVisualPool.scene_path_for_disciple(recruited_state) if recruited_state != null else ""
    var recruited_portrait: Variant = game.call("_disciple_source_a_portrait_texture",recruited_state) if recruited_state != null else null
    var adapter := guidance.get_node_or_null("TriFacilityB1LiveAdapterV1") if guidance != null else null
    var reveal := guidance.find_child("RecruitmentReveal",true,false) if guidance != null else null
    if recruited_id.is_empty() or adapter == null or str(adapter.get("_last_recruited_disciple_id")) != recruited_id or reveal == null:
        _fail("Successful recruitment must show the newly added canonical disciple in the B1 reveal.")
        return
    if recruited_scene_path.is_empty() or not (recruited_portrait is Texture2D):
        _fail("Newly recruited disciple did not resolve a real mapped Source A portrait for the success reveal.")
        return
    for action_name in ["RecruitedDiscipleProfile","RecruitedDiscipleAssignment","RecruitedDiscipleWorld"]:
        var action := _find_button(reveal,action_name)
        if action == null or action.disabled:
            _fail("Recruitment reveal is missing its real next-step action: %s." % action_name)
            return
    if not await _save_frame(out_dir,"05_recruitment_success_reveal_qa_fixture.png"):
        return
    var isolated_save := ProjectSettings.globalize_path(SAVE_PATH)
    if SaveService.new().save_to_path(state_after_open,isolated_save) != OK:
        _fail("Recruitment reveal state could not be saved through SaveService to the isolated QA profile.")
        return
    var reloaded: SimulationState = SaveService.new().load_from_path(isolated_save)
    if reloaded == null or not reloaded.disciples.has(StringName(recruited_id)) or reloaded.disciples.size() != state_after_open.disciples.size():
        _fail("Save/Reload did not preserve the newly recruited disciple identity and roster count.")
        return
    print("TRI03_RECRUITMENT_REVEAL_CAPTURE_PASS disciple=%s roster=%d source_a_portrait=1 save_reload=1" % [recruited_id,reloaded.disciples.size()])

    game.set("runtime_ready",false)
    game.queue_free()
    await process_frame
    game = null
    _remove_test_save()
    print("TRI02_P32_CONTEXT_CAPTURE_PASS map=1 hall=1 residence=1 guidance=1 size=1280x720")
    quit(0)

func _verify_source_alpha(relative: String, kind: String) -> bool:
    var source_path := ProjectSettings.globalize_path("res://art/source_a_env02a/" + relative)
    var source_image := Image.new()
    if source_image.load(source_path) != OK or source_image.is_empty() or not source_image.detect_alpha() != Image.ALPHA_NONE:
        _fail("Source A %s original PNG did not preserve its alpha channel." % kind)
        return false
    source_image.convert(Image.FORMAT_RGBA8)
    var rgba: PackedByteArray = source_image.get_data()
    var image_width: int = source_image.get_width()
    print("TRI02_SOURCE_ALPHA_SCAN_START model=%s size=%dx%d" % [kind,image_width,source_image.get_height()])
    var has_clear := false
    var has_opaque := false
    var has_semitransparent := false
    for y in range(0,source_image.get_height(),8):
        for x in range(0,image_width,8):
            var alpha_byte: int = rgba[(y*image_width+x)*4+3]
            var alpha: float = float(alpha_byte)/255.0
            has_clear = has_clear or alpha_byte <= 0
            has_opaque = has_opaque or alpha_byte >= 255
            has_semitransparent = has_semitransparent or (alpha_byte > 0 and alpha_byte < 255)
            if has_clear and has_opaque and has_semitransparent:
                break
        if has_clear and has_opaque and has_semitransparent:
            break
    if not has_clear or not has_opaque or not has_semitransparent:
        _fail("Source A %s must retain transparent, opaque and antialiased pixels." % kind)
        return false
    print("TRI02_SOURCE_ALPHA_PASS model=%s clear=1 opaque=1 antialias=1" % kind)
    return true

func _open_from_map(kind: String, model_id: String, destination: StringName, button_name: String, out_dir: String, filename: String) -> bool:
    print("TRI02_CAPTURE_STAGE=open_%s" % kind)
    game.call("_open_building",destination)
    await process_frame
    await process_frame
    print("TRI02_CAPTURE_STAGE=building_panel_%s" % kind)
    var button := _find_button(game,button_name)
    if button == null or button.disabled:
        _fail("Live P3.2 facility button is absent or disabled: %s." % button_name)
        return false
    print("TRI02_CAPTURE_STAGE=button_found_%s" % kind)
    button.pressed.emit()
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    print("TRI02_CAPTURE_STAGE=button_emitted_%s" % kind)
    var screen_name := "DanTienScreenV2" if button_name == "OpenDanTienScreenV2" else "DaiDienScreenV1"
    var screen := game.get_node_or_null(screen_name)
    if screen == null:
        _fail("Live P3.2 route did not create the expected B1 screen: %s." % screen_name)
        return false
    var facility_art := _find_facility_art(screen,kind)
    if facility_art == null or not bool(facility_art.get("_original_source")):
        _fail("Live B1 %s screen did not resolve its verified Source A art." % kind)
        return false
    if str(facility_art.get("_source_model_id")) != model_id:
        _fail("Live B1 %s screen resolved a different Source A model." % kind)
        return false
    var ui_texture: Variant = facility_art.get("_art")
    if not (ui_texture is Texture2D):
        _fail("Live B1 %s screen has no rendered Source A texture." % kind)
        return false
    if kind == "guidance":
        var has_approved_portrait := screen.find_child("VerifiedSourceACandidatePreview",true,false) != null
        var explicit_neutral_portrait := screen.find_child("CandidateUnverifiedPortrait",true,false) != null
        if not has_approved_portrait and not explicit_neutral_portrait:
            _fail("Guidance must show a verified mapped Source A portrait or explicitly mark the portrait unavailable.")
            return false
    if not await _save_frame(out_dir,filename):
        return false
    if kind == "residence":
        var plan_button := _find_button(screen,"ManageResidenceRooms")
        if plan_button == null:
            _fail("Residence B1 is missing its map planning route.")
            return false
        plan_button.pressed.emit()
        await process_frame
        await process_frame
        if not bool(game.get("build_mode_active")):
            _fail("Residence B1 map planning did not enter the real P3.2 build mode.")
            return false
        print("TRI02_B1_MAP_PLAN_ROUTE_PASS route=real_p3_2_build_mode")
        game.call("_leave_build_mode",true)
        await process_frame
    var route_screen := game.get_node_or_null(screen_name)
    if route_screen != null:
        route_screen.queue_free()
    await process_frame
    return true

func _find_facility_art(node: Node, kind: String) -> Control:
    var script := node.get_script() as Script
    if script != null and script.resource_path == "res://src/presentation/uiux/sect_facility_art_v2.gd":
        if str(node.get("facility_kind")) == kind:
            return node as Control
    for child in node.get_children():
        var found := _find_facility_art(child,kind)
        if found != null:
            return found
    return null

func _find_button(node: Node, expected_name: String) -> Button:
    if node is Button and node.name == expected_name:
        return node as Button
    for child in node.get_children():
        var found := _find_button(child,expected_name)
        if found != null:
            return found
    return null

func _save_frame(out_dir: String, filename: String) -> bool:
    print("TRI02_CAPTURE_STAGE=frame_post_draw_%s" % filename)
    await RenderingServer.frame_post_draw
    print("TRI02_CAPTURE_STAGE=frame_rendered_%s" % filename)
    var rendered: Image = root.get_texture().get_image()
    if rendered == null or rendered.is_empty() or rendered.get_size() != Vector2i(1280,720):
        _fail("Godot rendered no native 1280x720 frame for %s." % filename)
        return false
    var file_path := out_dir.path_join(filename)
    if rendered.save_png(file_path) != OK:
        _fail("Cannot save P3.2 screen capture %s." % file_path)
        return false
    var preview_image := rendered.duplicate()
    preview_image.resize(320,180,Image.INTERPOLATE_BILINEAR)
    var preview_png: PackedByteArray = preview_image.save_png_to_buffer()
    print("TRI02_VISUAL_REVIEW_%s=%s" % [filename,Marshalls.raw_to_base64(preview_png)])
    print("TRI02_P32_CAPTURE_OK path=%s size=1280x720" % file_path)
    return true

func _remove_test_save() -> void:
    var path := ProjectSettings.globalize_path(SAVE_PATH)
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(path)

func _fail(message: String) -> void:
    if game != null and is_instance_valid(game):
        game.set("runtime_ready",false)
        game.queue_free()
        game = null
    _remove_test_save()
    push_error("TRI02_P32_CAPTURE_FAIL: " + message)
    quit(1)
