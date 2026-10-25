extends SceneTree

const MAIN_SCENE := "res://scenes/p3/p3_2_landscape_sect.tscn"
const QA_SEED_SAVE := "res://qa/endgame_qa_save.json"
const PLAYABLE_SAVE_RELATIVE := "outputs/endgame_qa_20261026/userdata/endgame_playable_save_130.json"

func _initialize() -> void:
	call_deferred("_launch")

func _launch() -> void:
	var requested_population := 130
	for arg in OS.get_cmdline_user_args():
		if not str(arg).begins_with("--tmb-roster="):
			continue
		var digits := str(arg).trim_prefix("--tmb-roster=")
		if not digits.is_valid_int() or not [130,200,500].has(int(digits)):
			printerr("TMB_ENDGAME_LAUNCH_FAIL profile must be 130, 200 or 500")
			quit(2)
			return
		requested_population = int(digits)
	var chosen_seed := QA_SEED_SAVE
	var chosen_playable := PLAYABLE_SAVE_RELATIVE
	if requested_population != 130:
		chosen_seed = "res://qa/endgame_qa_save_%d.json" % requested_population
		chosen_playable = "outputs/endgame_qa_20261026/userdata/endgame_playable_save_%d.json" % requested_population
	var seed_path := ProjectSettings.globalize_path(chosen_seed)
	if not FileAccess.file_exists(seed_path):
		printerr("TMB_ENDGAME_LAUNCH_FAIL missing deterministic QA seed: %s" % seed_path)
		quit(2)
		return
	var project_root := ProjectSettings.globalize_path("res://")
	var save_path := project_root.path_join(chosen_playable)
	DirAccess.make_dir_recursive_absolute(save_path.get_base_dir())
	if not FileAccess.file_exists(save_path):
		if not _copy_seed_with_fresh_clock(seed_path,save_path):
			printerr("TMB_ENDGAME_LAUNCH_FAIL isolated save copy could not be written")
			quit(2)
			return
		if SaveService.new().load_from_path(save_path) == null:
			printerr("TMB_ENDGAME_LAUNCH_FAIL isolated save copy did not verify")
			quit(2)
			return
	ProjectSettings.set_setting("runtime/live_save_path", save_path)
	var packed := load(MAIN_SCENE) as PackedScene
	if packed == null:
		printerr("TMB_ENDGAME_LAUNCH_FAIL missing production P3.2 scene")
		quit(2)
		return
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_size(Vector2i(1280, 720))
	var scene := packed.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	if not bool(scene.get("runtime_ready")):
		printerr("TMB_ENDGAME_LAUNCH_FAIL P3.2 runtime did not load the fixture")
		quit(3)
		return
	var state: SimulationState = scene.get("state")
	print("TMB_ENDGAME_LIVE_P3_2_READY %s" % JSON.stringify({
		"scene": MAIN_SCENE,
		"seed_save": save_path,
		"tick": state.tick,
		"disciple_count": state.disciples.size(),
		"requested_population_profile": requested_population,
		"building_count": state.buildings.size()
	}))

func _copy_seed_with_fresh_clock(seed_path: String, save_path: String) -> bool:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(seed_path))
	if not (parsed is Dictionary) or not parsed.has("runtime_last_wall_unix"):
		return false
	parsed["runtime_last_wall_unix"] = int(Time.get_unix_time_from_system())
	var seeded := FileAccess.open(save_path,FileAccess.WRITE)
	if seeded == null:
		return false
	seeded.store_string(JSON.stringify(parsed))
	seeded.flush()
	var write_error := seeded.get_error()
	seeded.close()
	return write_error == OK
