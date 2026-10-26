extends SceneTree

# Pure percentile regression; the real-window probe is measured separately.
const PROBE := preload("res://tools/qa/pve_playable_perf_probe.gd")

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool,reason: String) -> bool:
	if condition:
		return true
	push_error("PVE PERF QA PROBE FAIL: "+reason)
	quit(1)
	return false

func _run() -> void:
	var none: Array[float] = []
	var empty := PROBE.summarize_ms(none)
	if not _check(empty["p95_ms"] == 0.0 and empty["p99_ms"] == 0.0
			and empty["max_ms"] == 0.0 and empty["fps_1pct_low"] == 0.0,
			"zero-frame window must be harmless"):
		return
	var frames: Array[float] = [10.0,20.0,30.0,40.0,50.0]
	var original := frames.duplicate()
	var summary := PROBE.summarize_ms(frames)
	if not _check(is_equal_approx(float(summary["mean_ms"]),30.0)
			and is_equal_approx(float(summary["p50_ms"]),30.0)
			and is_equal_approx(float(summary["p95_ms"]),50.0)
			and is_equal_approx(float(summary["p99_ms"]),50.0)
			and is_equal_approx(float(summary["max_ms"]),50.0)
			and is_equal_approx(float(summary["fps_1pct_low"]),20.0),
			"P50/P95/P99/max/1%-low nearest-rank stats are incorrect"):
		return
	if not _check(frames == original,"profiler modified caller frame samples"):
		return
	var phase_frames: Array[float] = [16.0,50.0,150.0,16.0,80.0]
	var phase_original := phase_frames.duplicate()
	var spike_rows: Array[Dictionary] = [{"frame_ms":150.0,"phase":"pve","elapsed_s":2.0}]
	var spike_original := spike_rows.duplicate(true)
	var phase := PROBE.phase_summary_record("pve",phase_frames,1.0,2.0,spike_rows)
	if not _check(int(phase["frame_count"]) == 5
			and phase["frame_gaps_ms"] == phase_frames
			and is_equal_approx(float(phase["frame_ms_p50"]),50.0)
			and is_equal_approx(float(phase["frame_ms_p95"]),150.0)
			and is_equal_approx(float(phase["frame_ms_p99"]),150.0)
			and is_equal_approx(float(phase["fps_1pct_low"]),6.67)
			and phase["top_spikes"][0]["frame_ms"] == 150.0,
			"phase records must retain raw frame gaps and exact aggregate statistics"):
		return
	if not _check(phase_frames == phase_original and spike_rows == spike_original,
			"phase summary modified caller samples or spikes"):
		return
	var slow: Array[float] = [450.0,470.0,430.0,500.0]
	var freeze := PROBE.summarize_ms(slow)
	if not _check(float(freeze["p99_ms"]) >= 500.0
			and float(freeze["fps_1pct_low"]) <= 2.0,
			"two-FPS-sized spikes were incorrectly smoothed away"):
		return
	print("PVE PERF QA PROBE CONTRACT PASS p50/p95/p99/max/1pct_low/spikes/immutable")
	quit(0)
