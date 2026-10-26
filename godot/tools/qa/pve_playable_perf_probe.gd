extends Node

# QA-only observer of the ACTUAL P3.2 scene. Does not advance a simulation,
# call Combat V2, change visibility/viewport, save gameplay or record video.
# Intervals use monotonic real wall time rather than simulation _delta.
const SAMPLE_INTERVAL_SEC := 3.0
const MEGABYTE := 1048576.0

var observed_scene: Node
var metrics_path := ""
var launch_ms := 0
var _metrics_file: FileAccess
var _last_frame_usec := 0
var _window_start_usec := 0
var _frame_count := 0
var _frame_gaps_ms: Array[float] = []
var _samples := 0

func configure(game_scene: Node, output_file: String, startup_ms: int) -> void:
    observed_scene = game_scene
    metrics_path = output_file
    launch_ms = startup_ms

func _ready() -> void:
    _window_start_usec = Time.get_ticks_usec()
    _last_frame_usec = _window_start_usec
    if metrics_path.is_empty():
        push_error("PVE_PERF_QA: missing metrics path")
        return
    DirAccess.make_dir_recursive_absolute(metrics_path.get_base_dir())
    _metrics_file = FileAccess.open(metrics_path, FileAccess.WRITE)
    if _metrics_file == null:
        push_error("PVE_PERF_QA: cannot open diagnostic output; error=%d" % FileAccess.get_open_error())
        return
    _emit_record({
        "kind":"start","schema":1,
        "engine":Engine.get_version_info().get("string","unknown"),
        "renderer":"game_project_default",
        "headless":DisplayServer.get_name() == "headless",
        "startup_ms":launch_ms,
        "metric_notes":"2D Compatibility: draw-call counters may not capture every canvas operation; MEMORY_STATIC is debug-build-dependent; profile separately from MovieWriter"
    })
    print("TMB_PVE_PERF_QA_ACTIVE output="+metrics_path)

func _process(_delta: float) -> void:
    var now_usec := Time.get_ticks_usec()
    var gap_ms := float(now_usec-_last_frame_usec)/1000.0
    _last_frame_usec = now_usec
    # Skip the first frame's setup interval; it isn't a normal gameplay frame.
    if _frame_count > 0 and gap_ms > 0.0:
        _frame_gaps_ms.append(gap_ms)
    _frame_count += 1
    var elapsed := float(now_usec-_window_start_usec)/1000000.0
    if elapsed < SAMPLE_INTERVAL_SEC:
        return
    var summary := summarize_ms(_frame_gaps_ms)
    var runtime_mode := _detect_phase()
    var fps := float(_frame_count)/maxf(0.001,elapsed)
    var record := {
        "kind":"sample","schema":1,
        "seconds":snappedf(elapsed,0.01),
        "phase":runtime_mode,
        "fps_measured":snappedf(fps,0.01),
        "fps_engine":Engine.get_frames_per_second(),
        "frame_ms_avg":summary.get("mean_ms",0.0),
        "frame_ms_p50":summary.get("p50_ms",0.0),
        "frame_ms_p95":summary.get("p95_ms",0.0),
        "frame_ms_max":summary.get("max_ms",0.0),
        "process_ms":snappedf(1000.0*Performance.get_monitor(Performance.TIME_PROCESS),0.01),
        "physics_ms":snappedf(1000.0*Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS),0.01),
        "node_count":int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
        "draw_calls_counter":int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
        "static_memory_mb":snappedf(Performance.get_monitor(Performance.MEMORY_STATIC)/MEGABYTE,0.1),
        "video_memory_mb":snappedf(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)/MEGABYTE,0.1),
        "frame_samples":_frame_gaps_ms.size()
    }
    _emit_record(record)
    print("TMB_PVE_PERF_SAMPLE phase=%s fps=%.2f p95_ms=%.2f process_ms=%.2f nodes=%d" % [
        runtime_mode,fps,float(record["frame_ms_p95"]),float(record["process_ms"]),
        int(record["node_count"])])
    _samples += 1
    _window_start_usec = now_usec
    _frame_count = 0
    _frame_gaps_ms.clear()

func _detect_phase() -> String:
    if observed_scene == null or not is_instance_valid(observed_scene):
        return "no_game"
    if not bool(observed_scene.get("runtime_ready")):
        return "loading"
    var mode := str(observed_scene.get("active_hunt_mode"))
    var panel := observed_scene.get("b3_hunt_panel") as Control
    var panel_visible := panel != null and panel.is_visible_in_tree()
    if mode == "multicamp" and panel_visible:
        return "pve_active"
    if panel_visible:
        return "hunt_panel_other"
    return "sect"

static func summarize_ms(samples: Array[float]) -> Dictionary:
    if samples.is_empty():
        return {"mean_ms":0.0,"p50_ms":0.0,"p95_ms":0.0,"max_ms":0.0}
    var sorted := samples.duplicate()
    sorted.sort()
    var total := 0.0
    for value in sorted:
        total += value
    var mid := int(floor(float(sorted.size()-1)*0.5))
    var tail := int(ceil(float(sorted.size()-1)*0.95))
    return {
        "mean_ms":snappedf(total/float(sorted.size()),0.01),
        "p50_ms":snappedf(sorted[mid],0.01),
        "p95_ms":snappedf(sorted[tail],0.01),
        "max_ms":snappedf(sorted[sorted.size()-1],0.01)
    }

func _emit_record(data: Dictionary) -> void:
    if _metrics_file == null:
        return
    _metrics_file.store_line(JSON.stringify(data))
    _metrics_file.flush()

func _exit_tree() -> void:
    _emit_record({"kind":"stop","schema":1,"samples":_samples})
    if _metrics_file != null:
        _metrics_file.close()
        _metrics_file = null
