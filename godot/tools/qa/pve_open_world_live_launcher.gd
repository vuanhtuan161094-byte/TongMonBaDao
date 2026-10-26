extends Node

const MAIN_SCENE := "res://scenes/p3/p3_2_landscape_sect.tscn"
const QA_SEED_SAVE := "res://outputs/endgame_qa_20261026/gameplay/roster_130/endgame_capture_save_1792953798.json"
const PLAYABLE_SAVE_RELATIVE := "outputs/pve_jx_world_20261026/userdata/pve_open_world_130.json"
const SOURCE_ROOT := "E:/codex/work/jxqy2_slice/source"

func _ready() -> void:
    call_deferred("_launch")

func _launch() -> void:
    var seed_path := ProjectSettings.globalize_path(QA_SEED_SAVE)
    var project_root := ProjectSettings.globalize_path("res://")
    var save_path := project_root.path_join(PLAYABLE_SAVE_RELATIVE)
    var root_path := OS.get_environment("TMB_JXQY2_ASSET_ROOT")
    if root_path.is_empty():
        root_path = SOURCE_ROOT
    if not DirAccess.dir_exists_absolute(root_path):
        printerr("TMB_PVE_JX_WORLD_LAUNCH_FAIL JX source library missing: %s" % root_path)
        get_tree().quit(2)
        return
    if not FileAccess.file_exists(seed_path):
        printerr("TMB_PVE_JX_WORLD_LAUNCH_FAIL QA seed missing: %s" % seed_path)
        get_tree().quit(2)
        return
    DirAccess.make_dir_recursive_absolute(save_path.get_base_dir())
    if not FileAccess.file_exists(save_path) and not _copy_seed_with_fresh_clock(seed_path,save_path):
        printerr("TMB_PVE_JX_WORLD_LAUNCH_FAIL isolated QA save could not be created")
        get_tree().quit(2)
        return
    var loaded_state := SaveService.new().load_from_path(save_path)
    if loaded_state == null:
        printerr("TMB_PVE_JX_WORLD_LAUNCH_FAIL isolated QA save failed SaveService validation")
        get_tree().quit(3)
        return
    ProjectSettings.set_setting("runtime/live_save_path",save_path)
    if DisplayServer.get_name() != "headless":
        DisplayServer.window_set_size(Vector2i(1280,720))
    var packed := load(MAIN_SCENE) as PackedScene
    if packed == null:
        printerr("TMB_PVE_JX_WORLD_LAUNCH_FAIL production P3.2 scene did not load")
        get_tree().quit(3)
        return
    var scene := packed.instantiate()
    get_tree().root.add_child(scene)
    await get_tree().process_frame
    await get_tree().process_frame
    if not bool(scene.get("runtime_ready")):
        printerr("TMB_PVE_JX_WORLD_LAUNCH_FAIL canonical P3.2 runtime did not start")
        get_tree().quit(3)
        return
    var world_view := scene.get_node_or_null("B3MainHuntShade/B3MainHuntPanel/B3MainHuntArena/PveJxContinuousWorldViewV1") as PveJxContinuousWorldViewV1
    if world_view == null:
        printerr("TMB_PVE_JX_WORLD_LAUNCH_FAIL P3.2 continuous-world view missing")
        get_tree().quit(3)
        return
    var world := world_view.prepare_world()
    if not bool(world.get("ok",false)) or int(world.get("verified_files",0)) != 44:
        printerr("TMB_PVE_JX_WORLD_LAUNCH_FAIL JX assets failed pinned-source check: %s" % str(world.get("reason","unknown")))
        get_tree().quit(4)
        return
    var state: SimulationState = scene.get("state")
    var ready_v2 := 0
    for disciple in state.disciples.values():
        if DiscipleRealmProgressV2.progression_ready(disciple):
            ready_v2 += 1
    print("TMB_PVE_JX_WORLD_LAUNCH_READY "+JSON.stringify({
        "engine":"Godot 4.7.2 official",
        "scene":MAIN_SCENE,
        "viewport":"1280x720",
        "save_path":save_path,
        "disciple_count":state.disciples.size(),
        "v2_progression_ready":ready_v2,
        "world_source":world.get("source_map",""),
        "source_hashes_verified":world.get("verified_files",0),
        "source_blob_sha":world.get("topology",{}).get("source_blob_sha",""),
        "spawn_zones":20,
        "loot":"LOOT_PENDING"
    }))

func _copy_seed_with_fresh_clock(seed_path: String, save_path: String) -> bool:
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(seed_path))
    if not (parsed is Dictionary) or not parsed.has("runtime_last_wall_unix"):
        return false
    parsed["runtime_last_wall_unix"] = int(Time.get_unix_time_from_system())
    var output := FileAccess.open(save_path,FileAccess.WRITE)
    if output == null:
        return false
    output.store_string(JSON.stringify(parsed))
    output.flush()
    var error := output.get_error()
    output.close()
    return error == OK and SaveService.new().load_from_path(save_path) != null
