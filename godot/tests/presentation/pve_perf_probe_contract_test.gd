extends SceneTree

# Pure stats regression: no Godot GUI or PvE simulation needed to verify
# sample percentile computation. Still requires Godot 4.7.2 to execute.
const PROBE := preload("res://tools/qa/pve_playable_perf_probe.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(condition: bool, reason: String) -> bool:
    if condition:
        return true
    push_error("PVE PERF QA PROBE FAIL: "+reason)
    quit(1)
    return false

func _run() -> void:
    var no_frames: Array[float] = []
    var empty := PROBE.summarize_ms(no_frames)
    if not _check(empty["p95_ms"] == 0.0 and empty["max_ms"] == 0.0,
            "zero-frame window must be harmless"):
        return
    var frames: Array[float] = [10.0,20.0,30.0,40.0,50.0]
    var original := frames.duplicate()
    var summary := PROBE.summarize_ms(frames)
    if not _check(is_equal_approx(float(summary["mean_ms"]),30.0)
            and is_equal_approx(float(summary["p50_ms"]),30.0)
            and is_equal_approx(float(summary["p95_ms"]),50.0)
            and is_equal_approx(float(summary["max_ms"]),50.0),
            "normal percentile/mean calculations are incorrect"):
        return
    if not _check(frames == original,
            "profiler modified the caller's frame samples"):
        return
    var slow: Array[float] = [450.0,470.0,430.0,500.0]
    var freeze := PROBE.summarize_ms(slow)
    if not _check(float(freeze["p95_ms"]) >= 500.0
            and float(freeze["mean_ms"]) >= 450.0,
            "2-FPS-sized frame spikes were incorrectly smoothed away"):
        return
    print("PVE PERF QA PROBE CONTRACT PASS (empty, p50/p95/max, immutable, low-FPS spikes)")
    quit(0)
