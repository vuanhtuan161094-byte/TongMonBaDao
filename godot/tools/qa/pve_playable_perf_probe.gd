extends Node

## Passive observer for the real P3.2 GUI. It never advances or mutates game state.
## Monotonic frame gaps are split into 3 s windows and explicit journey phases.
const SAMPLE_INTERVAL_SEC := 3.0
const MEGABYTE := 1048576.0
const TOP_SPIKE_COUNT := 5

var observed_scene: Node
var metrics_path := ""
var run_id := ""
var logger_enabled := false
var _metrics_file: FileAccess
var _run_start_usec := 0
var _last_frame_usec := 0
var _window_start_usec := 0
var _phase_start_usec := 0
var _active_phase := ""
var _pve_seen := false
var _frames: Array[Dictionary] = []
var _frame_gaps_ms: Array[float] = []
var _top_spikes: Array[Dictionary] = []
var _phase_frames: Array[Dictionary] = []
var _phase_frame_gaps_ms: Array[float] = []
var _phase_top_spikes: Array[Dictionary] = []
var _samples := 0

func configure(game_scene: Node,output_file: String,qa_run_id: String,
		app_logger_enabled: bool) -> void:
	observed_scene = game_scene
	metrics_path = output_file
	run_id = qa_run_id
	logger_enabled = app_logger_enabled

func _ready() -> void:
	_run_start_usec = Time.get_ticks_usec()
	_last_frame_usec = 0
	_window_start_usec = _run_start_usec
	_phase_start_usec = _run_start_usec
	if metrics_path.is_empty():
		push_error("PVE_PERF_QA: missing metrics path")
		return
	DirAccess.make_dir_recursive_absolute(metrics_path.get_base_dir())
	_metrics_file = FileAccess.open(metrics_path,FileAccess.WRITE)
	if _metrics_file == null:
		push_error("PVE_PERF_QA: cannot open diagnostic output; error=%d" % FileAccess.get_open_error())
		return
	_active_phase = _detect_phase()
	_emit_record({
		"kind":"start","schema":2,"run_id":run_id,
		"pid":OS.get_process_id(),
		"engine":Engine.get_version_info().get("string","unknown"),
		"renderer":RenderingServer.get_video_adapter_name(),
		"headless":DisplayServer.get_name() == "headless",
		"logger_enabled":logger_enabled,"monotonic_usec":_run_start_usec,
		"phase_plan":"production -> party_selection -> pve -> pve_save -> save_return",
		"metric_notes":"frame_ms is monotonic callback-to-callback wall time; every 3 s sample and phase_summary retain raw frame_gaps_ms for exact phase P50/P95/P99/1%-low; Godot TIME_PROCESS/TIME_PHYSICS_PROCESS and top spike rows help attribute main-thread/physics spikes; FPS excludes MovieWriter"
	})
	print("TMB_PVE_PERF_QA_ACTIVE run=%s logger=%s output=%s" % [run_id,str(logger_enabled),metrics_path])

func _process(_delta: float) -> void:
	var now_usec := Time.get_ticks_usec()
	var phase := _detect_phase()
	if not _active_phase.is_empty() and phase != _active_phase:
		_flush_sample(now_usec,true)
		_flush_phase_summary(now_usec)
		_emit_record({"kind":"phase_transition","run_id":run_id,
			"from":_active_phase,"to":phase,
			"elapsed_s":snappedf(float(now_usec-_run_start_usec)/1000000.0,0.001)})
		_window_start_usec = now_usec
		_phase_start_usec = now_usec
		_active_phase = phase
	var gap_ms := float(now_usec-_last_frame_usec)/1000.0 if _last_frame_usec > 0 else 0.0
	_last_frame_usec = now_usec
	if gap_ms > 0.0:
		var process_ms := 1000.0*Performance.get_monitor(Performance.TIME_PROCESS)
		var physics_ms := 1000.0*Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
		var row := {
			"frame_ms":gap_ms,
			"elapsed_s":float(now_usec-_run_start_usec)/1000000.0,
			"godot_process_ms":process_ms,
			"godot_physics_ms":physics_ms,
			"draw_calls":int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
			"nodes":int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
			"static_memory_mb":float(Performance.get_monitor(Performance.MEMORY_STATIC))/MEGABYTE,
			"video_memory_mb":float(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED))/MEGABYTE
		}
		_frames.append(row)
		_frame_gaps_ms.append(gap_ms)
		_phase_frames.append(row)
		_phase_frame_gaps_ms.append(gap_ms)
		_track_spike(row,phase)
	var elapsed := float(now_usec-_window_start_usec)/1000000.0
	if elapsed >= SAMPLE_INTERVAL_SEC:
		_flush_sample(now_usec,false)

func _detect_phase() -> String:
	if observed_scene == null or not is_instance_valid(observed_scene):
		return "no_game"
	if not bool(observed_scene.get("runtime_ready")):
		return "loading"
	var picker := observed_scene.get("pve_party_picker_shade") as Control
	if picker != null and picker.is_visible_in_tree():
		return "party_selection"
	var panel := observed_scene.get("b3_hunt_panel") as Control
	var panel_visible := panel != null and panel.is_visible_in_tree()
	var mode := str(observed_scene.get("active_hunt_mode"))
	if mode == "multicamp" and panel_visible:
		_pve_seen = true
		var feedback := observed_scene.get("b3_hunt_feedback") as Label
		if feedback != null and feedback.text.begins_with("Đã lưu qua SaveService"):
			return "pve_save"
		return "pve"
	return "save_return" if _pve_seen else "production"

func _track_spike(row: Dictionary,phase: String) -> void:
	var spike := row.duplicate()
	spike["phase"] = phase
	_retain_top_spikes(_top_spikes,spike)
	_retain_top_spikes(_phase_top_spikes,spike)

static func _retain_top_spikes(target: Array[Dictionary],spike: Dictionary) -> void:
	if target.size() < TOP_SPIKE_COUNT:
		target.append(spike)
		return
	var smallest_index := 0
	for index in range(1,target.size()):
		if float(target[index].get("frame_ms",0.0)) < float(target[smallest_index].get("frame_ms",0.0)):
			smallest_index = index
	if float(spike["frame_ms"]) > float(target[smallest_index].get("frame_ms",0.0)):
		target[smallest_index] = spike

func _flush_sample(now_usec: int,phase_boundary: bool) -> void:
	if _frame_gaps_ms.is_empty():
		_window_start_usec = now_usec
		return
	var summary := summarize_ms(_frame_gaps_ms)
	var process_values: Array[float] = []
	var physics_values: Array[float] = []
	var node_peak := 0
	var draw_peak := 0
	var ram_peak := 0.0
	var video_peak := 0.0
	for frame in _frames:
		process_values.append(float(frame["godot_process_ms"]))
		physics_values.append(float(frame["godot_physics_ms"]))
		node_peak = maxi(node_peak,int(frame["nodes"]))
		draw_peak = maxi(draw_peak,int(frame["draw_calls"]))
		ram_peak = maxf(ram_peak,float(frame["static_memory_mb"]))
		video_peak = maxf(video_peak,float(frame["video_memory_mb"]))
	var process_summary := summarize_ms(process_values)
	var physics_summary := summarize_ms(physics_values)
	_top_spikes.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
		return float(a.get("frame_ms",0.0)) > float(b.get("frame_ms",0.0)))
	_emit_record({
		"kind":"sample","schema":2,"run_id":run_id,"phase":_active_phase,
		"pid":OS.get_process_id(),
		"start_elapsed_s":snappedf(float(_window_start_usec-_run_start_usec)/1000000.0,0.001),
		"end_elapsed_s":snappedf(float(now_usec-_run_start_usec)/1000000.0,0.001),
		"elapsed_s":snappedf(float(now_usec-_window_start_usec)/1000000.0,0.001),
		"phase_boundary":phase_boundary,"frame_count":_frame_gaps_ms.size(),
		"fps_measured":snappedf(float(_frame_gaps_ms.size())/maxf(0.001,float(now_usec-_window_start_usec)/1000000.0),0.01),
		"frame_ms_mean":summary["mean_ms"],"frame_ms_p50":summary["p50_ms"],
		"frame_ms_p95":summary["p95_ms"],"frame_ms_p99":summary["p99_ms"],
		"frame_ms_max":summary["max_ms"],"slow_1pct_avg_ms":summary["slow_1pct_avg_ms"],
		"fps_1pct_low":summary["fps_1pct_low"],
		"frame_gaps_ms":_frame_gaps_ms.duplicate(),
		"godot_process_ms_p95":process_summary["p95_ms"],
		"godot_process_ms_max":process_summary["max_ms"],
		"godot_physics_ms_p95":physics_summary["p95_ms"],
		"godot_physics_ms_max":physics_summary["max_ms"],
		"node_count_peak":node_peak,"draw_calls_peak":draw_peak,
		"static_memory_peak_mb":snappedf(ram_peak,0.1),
		"video_memory_peak_mb":snappedf(video_peak,0.1),
		"top_spikes":_top_spikes.duplicate(true)
	})
	_samples += 1
	_frames.clear()
	_frame_gaps_ms.clear()
	_top_spikes.clear()
	_window_start_usec = now_usec

func _flush_phase_summary(now_usec: int) -> void:
	if _phase_frame_gaps_ms.is_empty():
		_phase_start_usec = now_usec
		return
	var process_values: Array[float] = []
	var physics_values: Array[float] = []
	var node_peak := 0
	var draw_peak := 0
	var ram_peak := 0.0
	var video_peak := 0.0
	for frame in _phase_frames:
		process_values.append(float(frame.get("godot_process_ms",0.0)))
		physics_values.append(float(frame.get("godot_physics_ms",0.0)))
		node_peak = maxi(node_peak,int(frame.get("nodes",0)))
		draw_peak = maxi(draw_peak,int(frame.get("draw_calls",0)))
		ram_peak = maxf(ram_peak,float(frame.get("static_memory_mb",0.0)))
		video_peak = maxf(video_peak,float(frame.get("video_memory_mb",0.0)))
	var record := phase_summary_record(_active_phase,_phase_frame_gaps_ms,
		float(_phase_start_usec-_run_start_usec)/1000000.0,
		float(now_usec-_run_start_usec)/1000000.0,_phase_top_spikes)
	var process_summary := summarize_ms(process_values)
	var physics_summary := summarize_ms(physics_values)
	record["run_id"] = run_id
	record["pid"] = OS.get_process_id()
	record["godot_process_ms_p95"] = process_summary["p95_ms"]
	record["godot_process_ms_max"] = process_summary["max_ms"]
	record["godot_physics_ms_p95"] = physics_summary["p95_ms"]
	record["godot_physics_ms_max"] = physics_summary["max_ms"]
	record["node_count_peak"] = node_peak
	record["draw_calls_peak"] = draw_peak
	record["static_memory_peak_mb"] = snappedf(ram_peak,0.1)
	record["video_memory_peak_mb"] = snappedf(video_peak,0.1)
	_emit_record(record)
	_phase_frames.clear()
	_phase_frame_gaps_ms.clear()
	_phase_top_spikes.clear()
	_phase_start_usec = now_usec

static func phase_summary_record(phase: String,frame_gaps: Array[float],
		start_elapsed_s: float,end_elapsed_s: float,
		top_spikes: Array[Dictionary]) -> Dictionary:
	var summary := summarize_ms(frame_gaps)
	var sorted_spikes := top_spikes.duplicate(true)
	sorted_spikes.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
		return float(a.get("frame_ms",0.0)) > float(b.get("frame_ms",0.0)))
	return {
		"kind":"phase_summary","schema":2,"phase":phase,
		"start_elapsed_s":snappedf(start_elapsed_s,0.001),
		"end_elapsed_s":snappedf(end_elapsed_s,0.001),
		"elapsed_s":snappedf(maxf(0.0,end_elapsed_s-start_elapsed_s),0.001),
		"frame_count":frame_gaps.size(),
		"fps_measured":snappedf(float(frame_gaps.size())/maxf(0.001,end_elapsed_s-start_elapsed_s),0.01),
		"frame_ms_mean":summary["mean_ms"],"frame_ms_p50":summary["p50_ms"],
		"frame_ms_p95":summary["p95_ms"],"frame_ms_p99":summary["p99_ms"],
		"frame_ms_max":summary["max_ms"],
		"slow_1pct_avg_ms":summary["slow_1pct_avg_ms"],
		"fps_1pct_low":summary["fps_1pct_low"],
		"frame_gaps_ms":frame_gaps.duplicate(),
		"top_spikes":sorted_spikes
	}

static func summarize_ms(values: Array[float]) -> Dictionary:
	if values.is_empty():
		return {"mean_ms":0.0,"p50_ms":0.0,"p95_ms":0.0,"p99_ms":0.0,
			"max_ms":0.0,"slow_1pct_avg_ms":0.0,"fps_1pct_low":0.0}
	var sorted := values.duplicate()
	sorted.sort()
	var total := 0.0
	for value in sorted:
		total += value
	var tail_count := maxi(1,ceili(float(sorted.size())*0.01))
	var tail_total := 0.0
	for index in range(sorted.size()-tail_count,sorted.size()):
		tail_total += sorted[index]
	var slow_average := tail_total/float(tail_count)
	return {
		"mean_ms":snappedf(total/float(sorted.size()),0.01),
		"p50_ms":snappedf(_nearest_rank(sorted,0.50),0.01),
		"p95_ms":snappedf(_nearest_rank(sorted,0.95),0.01),
		"p99_ms":snappedf(_nearest_rank(sorted,0.99),0.01),
		"max_ms":snappedf(sorted[sorted.size()-1],0.01),
		"slow_1pct_avg_ms":snappedf(slow_average,0.01),
		"fps_1pct_low":snappedf(1000.0/maxf(0.001,slow_average),0.01)
	}

static func _nearest_rank(sorted: Array[float],percentile: float) -> float:
	var index := clampi(ceili(float(sorted.size())*percentile)-1,0,sorted.size()-1)
	return sorted[index]

func _emit_record(data: Dictionary) -> void:
	if _metrics_file == null:
		return
	_metrics_file.store_line(JSON.stringify(data))
	_metrics_file.flush()

func _exit_tree() -> void:
	if _metrics_file != null:
		_flush_sample(Time.get_ticks_usec(),true)
		_flush_phase_summary(Time.get_ticks_usec())
		_emit_record({"kind":"stop","schema":2,"run_id":run_id,"samples":_samples,
			"elapsed_s":snappedf(float(Time.get_ticks_usec()-_run_start_usec)/1000000.0,0.001)})
		_metrics_file.close()
		_metrics_file = null
