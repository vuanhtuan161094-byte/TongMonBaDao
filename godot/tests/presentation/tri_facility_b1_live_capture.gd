extends SceneTree
## Genuine Godot-rendered B1 overlays on canonical gameplay host and P37 state.
## Unlike B1 gallery captures, all displayed state is read from the real P37Factory.
const LIVE_B1 = preload("res://src/presentation/uiux/tri_facility_live_adapter_v1.gd")
const CAPTURE_FILES := {
    "hall":"01_hall_live_state.png",
    "residence":"02_residence_live_state.png",
    "guidance":"03_guidance_live_state.png"
}

func _initialize() -> void:
    call_deferred("_capture")

func _capture() -> void:
    var argv := OS.get_cmdline_user_args()
    if argv.is_empty():
        push_error("Pass isolated absolute screenshot output directory after --.")
        quit(2)
        return
    var out_dir: String = argv[0]
    DirAccess.make_dir_recursive_absolute(out_dir)
    DisplayServer.window_set_size(Vector2i(1280,720))
    var sim: SimulationState = P37Factory.create_state(20261102)
    sim.sect.disciple_v2_birth_enabled = true
    if not bool(SectHallSystemV1.ensure_live(sim).get("ok",false)):
        push_error("Cannot initialize canonical Hall/Residence for live UI capture.")
        quit(1)
        return
    var recruitment := RecruitmentSystem.new()
    for mode in ["hall","residence","guidance"]:
        var host: Control
        if mode == "guidance":
            var guidance := DanTienScreenV2.new()
            guidance.attach_state(sim,recruitment)
            host = guidance
        else:
            var management := DaiDienScreenV1.new()
            management.attach_state(sim)
            host = management
        root.add_child(host)
        host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        if mode == "residence":
            host.call("_tab",5)
        var adapter: Control = LIVE_B1.new()
        adapter.call("configure",host,sim,recruitment,mode)
        host.add_child(adapter)
        adapter.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        await process_frame
        await process_frame
        await RenderingServer.frame_post_draw
        var rendered: Image = root.get_texture().get_image()
        if rendered == null or rendered.is_empty():
            push_error("Live UI renderer produced no image for " + mode)
            quit(1)
            return
        if rendered.get_size() != Vector2i(1280,720):
            push_error("Live UI capture must be 1280x720, got " + str(rendered.get_size()))
            quit(1)
            return
        var file_path := out_dir.path_join(str(CAPTURE_FILES[mode]))
        if rendered.save_png(file_path) != OK:
            push_error("Cannot save live UI capture " + file_path)
            quit(1)
            return
        print("TRI_B1_LIVE_CAPTURE_OK mode=%s path=%s size=1280x720" % [mode,file_path])
        root.remove_child(host)
        host.queue_free()
        await process_frame
    quit(0)
