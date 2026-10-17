extends SceneTree

# QA-only, read-only scene driving. Same probe runs against old pre-repair
# commit and the live PR HEAD in separate TEMP worktrees.
# Run in a real graphical Godot 4.7.2 window, never --headless.
const SAVE_PATH := "user://map25_visual_perf_probe.json"
const FRAMES_PER_CASE := 120
var scene: Control
var output_dir := ""
var raw_csv := "scenario,frame,interval_ms,process_ms,fps,draw_calls,nodes,memory_bytes\n"
var summary_csv := "scenario,count,avg_interval_ms,p95_interval_ms,avg_process_ms,avg_fps,avg_draw_calls,peak_nodes\n"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    output_dir = OS.get_environment("MAP25_QA_OUT").replace("\\","/")
    if output_dir == "" or not output_dir.is_absolute_path():
        _fail("MAP25_QA_OUT must be a dedicated absolute QA output path")
        return
    if DirAccess.make_dir_recursive_absolute(output_dir) != OK:
        _fail("could not create QA directory")
        return
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    DisplayServer.window_set_size(Vector2i(1280,720))
    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed == null:
        _fail("main sect scene missing")
        return
    scene = packed.instantiate() as Control
    root.add_child(scene)
    for _i in range(45):
        await process_frame
    if not bool(scene.get("runtime_ready")):
        _fail("main scene runtime not ready")
        return
    var iso := scene.get("iso_world") as SectIsometricWorldV1
    if iso == null or iso.camera == null:
        _fail("real MAP25 camera missing")
        return
    # A screenshot failure must not destroy measurements from later scenarios.
    # Keep the 1280x720 contract strict; never rescale an incorrect screenshot.
    var failed_captures: Array[String] = []
    if not await _capture("01_idle"):
        failed_captures.append("01_idle")
    await _sample("idle",false)
    await _sample("pan",true)
    if not await _capture("02_pan"):
        failed_captures.append("02_pan")
    scene.call("_zoom_at",Vector2(620,340),1.25,false)
    for _i in range(20):
        await process_frame
    await _sample("zoom",false)
    if not await _capture("03_zoom"):
        failed_captures.append("03_zoom")
    scene.call("_open_building",SectMapPresentation.DEST_MINE)
    for _i in range(20):
        await process_frame
    var panel := scene.find_child("BuildingOperationPanel",true,false) as Panel
    if panel == null or not panel.visible:
        _fail("Mine panel not visible")
        return
    if not await _capture("04_mine"):
        failed_captures.append("04_mine")
    await _sample("mine_panel",false)
    var state := scene.get("state") as SimulationState
    var mine := BuildingSystem.new().primary_building(state,BuildingSystem.TYPE_MINE)
    if mine == null:
        _fail("canonical Mine missing")
        return
    scene.call("_open_workforce_picker",mine.id)
    for _i in range(20):
        await process_frame
    var picker := scene.find_child("WorkforcePicker",true,false) as Panel
    if picker == null or not picker.visible:
        _fail("Workforce picker not visible")
        return
    if not await _capture("05_picker"):
        failed_captures.append("05_picker")
    await _sample("picker",false)
    if not _write("frame_samples.csv",raw_csv) or not _write("performance_summary.csv",summary_csv):
        _fail("could not write QA performance CSV")
        return
    var meta := {
        "head":OS.get_environment("MAP25_QA_SHA"),
        "godot":Engine.get_version_info(),
        "user_data_dir":OS.get_user_data_dir(),
        "viewport":root.get_viewport().get_visible_rect().size,
        "display_server":DisplayServer.get_name(),
        "sample_frames":FRAMES_PER_CASE,
        "failed_capture_tags":failed_captures,
        "note":"Graphic-window observed frame intervals, not GPU-profiler timings; compare on identical machine/settings."
    }
    if not _write("capture_metadata.json",JSON.stringify(meta,"  ")):
        _fail("could not write metadata")
        return
    if not failed_captures.is_empty():
        _fail("not all genuine 1280x720 images captured: "+str(failed_captures)+"; all five scenario metrics are preserved in CSV")
        return
    print("MAP25 VISUAL PERFORMANCE CAPTURE PASS out=",output_dir)
    scene.queue_free()
    await process_frame
    quit(0)

func _sample(label: String, pan: bool) -> void:
    var intervals: Array[float] = []
    var total_process := 0.0
    var total_fps := 0.0
    var total_draw := 0.0
    var peak_nodes := 0
    var last_usec := Time.get_ticks_usec()
    for index in range(FRAMES_PER_CASE):
        if pan:
            scene.call("_pan_camera",Vector2(1.6,0.35))
        elif label == "zoom":
            # Sample active pinch-like zoom changes, not just a static
            # camera left at zoom=125% after the transition.
            scene.call("_zoom_at",Vector2(620,340),1.12+0.18*sin(float(index)/7.0),false)
        await process_frame
        var now_usec := Time.get_ticks_usec()
        var elapsed_ms := float(now_usec-last_usec)/1000.0
        last_usec = now_usec
        var process_ms := float(Performance.get_monitor(Performance.TIME_PROCESS))*1000.0
        var fps := float(Performance.get_monitor(Performance.TIME_FPS))
        var draw_calls := float(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
        var nodes := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
        var memory := float(Performance.get_monitor(Performance.MEMORY_STATIC))
        peak_nodes = maxi(peak_nodes,nodes)
        intervals.append(elapsed_ms)
        total_process += process_ms
        total_fps += fps
        total_draw += draw_calls
        raw_csv += "%s,%d,%.3f,%.3f,%.2f,%.1f,%d,%.0f\n" % [
            label,index,elapsed_ms,process_ms,fps,draw_calls,nodes,memory
        ]
    intervals.sort()
    var count := intervals.size()
    var average := 0.0
    for delta_ms in intervals:
        average += delta_ms
    average /= float(count)
    var p95 := intervals[mini(count-1,ceili(float(count)*0.95)-1)]
    summary_csv += "%s,%d,%.3f,%.3f,%.3f,%.2f,%.1f,%d\n" % [
        label,count,average,p95,total_process/float(count),
        total_fps/float(count),total_draw/float(count),peak_nodes
    ]
    # Crash-safe evidence: each completed scenario is available even if a
    # subsequent screenshot fails before the final five-scenario gate.
    _write("frame_samples.csv",raw_csv)
    _write("performance_summary.csv",summary_csv)
    print("MAP25 PERF ",label," avg_interval_ms=",average," p95_interval_ms=",p95)

func _capture(label: String) -> bool:
    # In an official window capture, GPU readback can be transient during
    # zoom. Retry after real rendered frames. If the OS resized the client
    # window, request 1280x720 again and report the observed resize, not an
    # invented/rescaled screenshot.
    var expected := Vector2i(1280,720)
    var observed := Vector2i.ZERO
    var observed_window := Vector2i.ZERO
    var observed_rect := Vector2i.ZERO
    for attempt in range(8):
        await process_frame
        var viewport := root.get_viewport()
        observed_window = DisplayServer.window_get_size()
        observed_rect = Vector2i(viewport.get_visible_rect().size)
        var image: Image = viewport.get_texture().get_image()
        if image != null and not image.is_empty():
            observed = Vector2i(image.get_width(),image.get_height())
            if observed == expected:
                var err := image.save_png(output_dir.path_join(label+".png"))
                if err != OK:
                    print("MAP25 CAPTURE FILE_WRITE_FAIL ",label," ",error_string(err))
                    return false
                print("MAP25 CAPTURE_OK ",label," image=",observed," window=",observed_window," viewport=",observed_rect," retries=",attempt)
                return true
        if attempt == 0:
            print("MAP25 CAPTURE_DIM_WARNING ",label," image=",observed," window=",observed_window," viewport=",observed_rect)
        if attempt == 2 and observed_window != expected:
            DisplayServer.window_set_size(expected)
            print("MAP25 CAPTURE_WINDOW_RESTORE_REQUEST ",label," previous=",observed_window," requested=",expected)
    print("MAP25 CAPTURE_DIM_FAIL ",label," image=",observed," window=",observed_window," viewport=",observed_rect)
    return false

func _write(filename: String, body: String) -> bool:
    var file := FileAccess.open(output_dir.path_join(filename),FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(body)
    file.close()
    return true

func _fail(message: String) -> void:
    push_error("MAP25 VISUAL/PERFORMANCE CAPTURE FAIL: "+message)
    if scene != null:
        scene.queue_free()
    quit(1)
