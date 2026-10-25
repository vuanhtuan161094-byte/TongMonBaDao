extends SceneTree

const MAIN_SCENE := "res://scenes/p3/p3_2_landscape_sect.tscn"
const QA_SEED_SAVE := "res://qa/endgame_qa_save.json"
const PLAYABLE_SAVE_RELATIVE := "outputs/endgame_qa_20261025/userdata/endgame_playable_save.json"

func _initialize() -> void:
	call_deferred("_launch")

func _launch() -> void:
	var seed_path := ProjectSettings.globalize_path(QA_SEED_SAVE)
	if not FileAccess.file_exists(seed_path):
		printerr("TMB_ENDGAME_LAUNCH_FAIL missing deterministic QA seed: %s" % seed_path)
		quit(2)
		return
	var project_root := ProjectSettings.globalize_path("res://")
	var save_path := project_root.path_join(PLAYABLE_SAVE_RELATIVE)
	DirAccess.make_dir_recursive_absolute(save_path.get_base_dir())
	if not FileAccess.file_exists(save_path):
		var source := FileAccess.open(seed_path,FileAccess.READ)
		if source == null:
			printerr("TMB_ENDGAME_LAUNCH_FAIL could not open deterministic QA seed")
			quit(2)
			return
		var seeded := FileAccess.open(save_path,FileAccess.WRITE)
		if seeded == null:
			source.close()
			printerr("TMB_ENDGAME_LAUNCH_FAIL could not create isolated playable save")
			quit(2)
			return
		seeded.store_buffer(source.get_buffer(source.get_length()))
		seeded.flush()
		var write_error := seeded.get_error()
		seeded.close()
		source.close()
		if write_error != OK or SaveService.new().load_from_path(save_path) == null:
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
		"building_count": state.buildings.size()
	}))
