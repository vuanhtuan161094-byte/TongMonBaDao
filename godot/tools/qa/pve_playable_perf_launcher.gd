extends SceneTree

# Runs the ORIGINAL P3.2/main-game scene with a fresh, isolated QA save and
# passive FPS probe. It does not use the retired JXQY2 snow-map launcher.
const MAIN_SCENE := "res://scenes/p3/p3_2_landscape_sect.tscn"
const QA_SEED_SAVE := "res://qa/endgame_qa_save.json"
const QA_ROOT := "outputs/pve_perf_qa_20261026"
const PLAYABLE_SAVE := QA_ROOT+"/userdata/pve_perf_playable_130.json"
const PROBE_SCRIPT := preload("res://tools/qa/pve_playable_perf_probe.gd")

func _initialize() -> void:
    call_deferred("_launch")

func _launch() -> void:
    if DisplayServer.get_name() == "headless":
        printerr("TMB_PVE_PERF_LAUNCH_FAIL: requires normal GUI, not headless")
        quit(2)
        return
    var begun_at := Time.get_ticks_msec()
    var project_root := ProjectSettings.globalize_path("res://")
    var save_path := project_root.path_join(PLAYABLE_SAVE)
    var seed_path := ProjectSettings.globalize_path(QA_SEED_SAVE)
    if not FileAccess.file_exists(seed_path):
        printerr("TMB_PVE_PERF_LAUNCH_FAIL: missing canonical 130-disciple QA seed")
        quit(2)
        return
    DirAccess.make_dir_recursive_absolute(save_path.get_base_dir())
    if not FileAccess.file_exists(save_path):
        if not _seed_clocked_playable_copy(seed_path,save_path):
            printerr("TMB_PVE_PERF_LAUNCH_FAIL: could not initialize isolated QA save")
            quit(2)
            return
    if SaveService.new().load_from_path(save_path) == null:
        printerr("TMB_PVE_PERF_LAUNCH_FAIL: isolated save corrupt (not overwritten)")
        quit(3)
        return
    ProjectSettings.set_setting("runtime/live_save_path",save_path)
    DisplayServer.window_set_size(Vector2i(1280,720))
    var game := load(MAIN_SCENE) as PackedScene
    if game == null:
        printerr("TMB_PVE_PERF_LAUNCH_FAIL: production P3.2 scene unavailable")
        quit(3)
        return
    var scene := game.instantiate()
    root.add_child(scene)
    await process_frame
    await process_frame
    if not bool(scene.get("runtime_ready")):
        printerr("TMB_PVE_PERF_LAUNCH_FAIL: main-game runtime not ready")
        quit(3)
        return
    var output_dir := project_root.path_join(QA_ROOT).path_join("metrics")
    DirAccess.make_dir_recursive_absolute(output_dir)
    var metrics_path := output_dir.path_join("normal_gui_%d_%d.jsonl" % [
        int(Time.get_unix_time_from_system()),Time.get_ticks_msec()])
    var probe := PROBE_SCRIPT.new()
    probe.configure(scene,metrics_path,Time.get_ticks_msec()-begun_at)
    root.add_child(probe)
    var state: SimulationState = scene.get("state")
    print("TMB_PVE_PERF_GAME_READY main=P3.2_source_a profile=130 viewport=1280x720"
        +" disciples=%d isolated_save=%s metrics=%s" % [
            state.disciples.size(),save_path,metrics_path])
    print("TMB_PVE_PERF_INSTRUCTIONS: sample 15s Sect -> enter Thanh Truc Lam"
        +" -> move/attack 30s -> Save/Return -> close normally; no MovieWriter")

func _seed_clocked_playable_copy(seed_path: String, dest: String) -> bool:
    var raw = JSON.parse_string(FileAccess.get_file_as_string(seed_path))
    if not (raw is Dictionary) or not raw.has("runtime_last_wall_unix"):
        return false
    raw["runtime_last_wall_unix"] = int(Time.get_unix_time_from_system())
    var file := FileAccess.open(dest,FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(raw))
    file.flush()
    var write_error := file.get_error()
    file.close()
    return write_error == OK and SaveService.new().load_from_path(dest) != null
