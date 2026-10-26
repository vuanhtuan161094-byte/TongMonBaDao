extends SceneTree

# Starts the original P3.2 scene with a fresh, isolated 130-disciple QA save.
const MAIN_SCENE := "res://scenes/p3/p3_2_landscape_sect.tscn"
const QA_SEED_SAVE := "res://outputs/endgame_qa_20261026/gameplay/roster_130/endgame_capture_save_1792953798.json"
const QA_ROOT := "outputs/pve_perf_qa_20261026"
const PROBE_SCRIPT := preload("res://tools/qa/pve_playable_perf_probe.gd")

func _initialize() -> void:
	call_deferred("_launch")

func _launch() -> void:
	if DisplayServer.get_name() == "headless":
		printerr("TMB_PVE_PERF_LAUNCH_FAIL: requires normal GUI, not headless")
		quit(2)
		return
	var launch_usec := Time.get_ticks_usec()
	var run_id := "%d_%d" % [int(Time.get_unix_time_from_system()),launch_usec]
	var project_root := ProjectSettings.globalize_path("res://")
	var seed_path := ProjectSettings.globalize_path(QA_SEED_SAVE)
	var run_root := project_root.path_join(QA_ROOT)
	var save_path := run_root.path_join("userdata").path_join("pve_perf_%s.json" % run_id)
	if not FileAccess.file_exists(seed_path):
		printerr("TMB_PVE_PERF_LAUNCH_FAIL: missing canonical 130-disciple QA seed: "+seed_path)
		quit(2)
		return
	var seed_state := SaveService.new().load_from_path(seed_path)
	if seed_state == null or seed_state.disciples.size() != 130:
		printerr("TMB_PVE_PERF_LAUNCH_FAIL: canonical QA seed failed SaveService validation")
		quit(2)
		return
	seed_state.runtime_last_wall_unix = int(Time.get_unix_time_from_system())
	seed_state.runtime_unconsumed_wall_seconds = 0.0
	DirAccess.make_dir_recursive_absolute(save_path.get_base_dir())
	if FileAccess.file_exists(save_path) or SaveService.new().save_to_path(seed_state,save_path) != OK:
		printerr("TMB_PVE_PERF_LAUNCH_FAIL: could not create a new isolated QA save")
		quit(3)
		return
	if SaveService.new().load_from_path(save_path) == null:
		printerr("TMB_PVE_PERF_LAUNCH_FAIL: isolated save failed canonical validation")
		quit(3)
		return
	ProjectSettings.set_setting("runtime/live_save_path",save_path)
	DisplayServer.window_set_size(Vector2i(1280,720))
	var packed := load(MAIN_SCENE) as PackedScene
	if packed == null:
		printerr("TMB_PVE_PERF_LAUNCH_FAIL: production P3.2 scene unavailable")
		quit(3)
		return
	var game := packed.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	if not bool(game.get("runtime_ready")):
		printerr("TMB_PVE_PERF_LAUNCH_FAIL: main-game runtime not ready")
		quit(3)
		return
	var metrics_dir := run_root.path_join("metrics")
	DirAccess.make_dir_recursive_absolute(metrics_dir)
	var logger_enabled := OS.get_environment("TMB_PVE_PERF_LOG") == "1"
	var metrics_path := metrics_dir.path_join("normal_gui_%s.jsonl" % run_id)
	var probe := PROBE_SCRIPT.new()
	probe.configure(game,metrics_path,run_id,logger_enabled)
	root.add_child(probe)
	var log_path := run_root.path_join("logs").path_join("normal_gui_%s.godot.log" % run_id)
	print("TMB_PVE_PERF_GAME_READY run=%s sha=%s main=P3.2_source_a viewport=1280x720 disciples=%d logger=%s isolated_save=%s metrics=%s godot_log=%s" % [
		run_id,OS.get_environment("TMB_PVE_EXACT_SHA"),seed_state.disciples.size(),
		str(logger_enabled),save_path,metrics_path,log_path])
	print("TMB_PVE_PERF_INSTRUCTIONS: spend 15s in sect; use the visible Săn quái button; select 6; play 30-60s; Save, return, then reload. No MovieWriter. Use the provided Godot profiler monitor fields for spikes.")
