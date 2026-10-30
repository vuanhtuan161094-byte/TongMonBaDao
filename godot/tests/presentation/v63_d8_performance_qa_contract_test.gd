extends SceneTree

const PERF_PROBE := preload("res://tools/qa/pve_playable_perf_probe.gd")

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, why: String) -> bool:
    if not ok:
        push_error("V63_D8_PERFORMANCE_QA_CONTRACT_FAIL: " + why)
        quit(1)
        return false
    return true

func _run() -> void:
    var gaps: Array[float] = [10.0,20.0,30.0,40.0,1000.0]
    var summary: Dictionary = PERF_PROBE.summarize_ms(gaps)
    if not _check(is_equal_approx(float(summary.get("mean_ms",-1.0)),220.0) and
        is_equal_approx(float(summary.get("p50_ms",-1.0)),30.0) and
        is_equal_approx(float(summary.get("p95_ms",-1.0)),1000.0) and
        is_equal_approx(float(summary.get("p99_ms",-1.0)),1000.0) and
        is_equal_approx(float(summary.get("fps_1pct_low",-1.0)),1.0),
        "P50/P95/P99/1-percent-low observer math changed"):
        return
    var empty: Array[Dictionary] = []
    var phase := PERF_PROBE.phase_summary_record("pve",gaps,0.0,2.0,empty)
    if not _check(str(phase.get("kind","")) == "phase_summary" and
        str(phase.get("phase","")) == "pve" and
        int(phase.get("frame_count",0)) == gaps.size() and
        phase.get("frame_gaps_ms",[]) == gaps and
        phase.has("top_spikes") and phase.has("fps_1pct_low"),
        "phase summary lost raw samples or acceptance metrics"):
        return
    var launcher := FileAccess.get_file_as_string(
        "res://tools/qa/pve_playable_perf_launcher.gd"
    )
    var probe := FileAccess.get_file_as_string(
        "res://tools/qa/pve_playable_perf_probe.gd"
    )
    if not _check(launcher.contains("DisplayServer.get_name() == \"headless\"") and
        launcher.contains("DisplayServer.window_set_size(Vector2i(1280,720))") and
        launcher.contains("TMB_PVE_PERF_LOG") and
        launcher.contains("normal_gui_") and
        probe.contains("static_memory_peak_mb") and
        probe.contains("video_memory_peak_mb") and
        probe.contains("phase_summary_record") and
        probe.contains("TMB_PVE_PERF_QA_ACTIVE"),
        "existing GUI launcher/probe no longer exposes the required isolated run contract"):
        return
    print("V63_D8_PERFORMANCE_QA_CONTRACT_PASS: isolated_1280x720_gui=true metrics=FPS,P50,P95,P99,1pct_low,static_RAM,video_RAM real_gui_run=NOT_MEASURED")
    quit(0)
