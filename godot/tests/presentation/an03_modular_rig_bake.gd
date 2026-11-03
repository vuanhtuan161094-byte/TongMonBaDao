extends SceneTree
## AN-03 actual GPU sprite bake, requires official Godot GUI/graphics context.
## Outputs 768x768 RGBA from ONE skeletal rig, ONE camera, three real motions.
## Bakes TECHNICAL GUIDE ONLY; NOT final user-approved Shadow art/model.
const ACTOR := preload("res://src/presentation/labs/an03_modular_character.gd")
const BASE_DIR := "res://outputs/an03_lab/bake"
const SIZE := Vector2i(768,768)
const CLIPS: Array[Dictionary] = [
    {"name":"idle","frames":18,"duration":1.8,"loop":true},
    {"name":"walk","frames":12,"duration":0.9,"loop":true},
    {"name":"attack","frames":16,"duration":1.1,"loop":false}
]

func _init() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("AN03_BAKE_FAIL: " + message)
    quit(1)

func _run() -> void:
    if DisplayServer.get_name() == "headless":
        _fail("real renderer needed; cannot count headless PNGs as art")
        return
    var viewport := SubViewport.new()
    viewport.size = SIZE
    viewport.transparent_bg = true
    viewport.own_world_3d = true
    viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var stage := Node3D.new()
    viewport.add_child(stage)
    var world_env := WorldEnvironment.new()
    world_env.environment = Environment.new()
    world_env.environment.background_mode = Environment.BG_CLEAR_COLOR
    stage.add_child(world_env)
    var camera := Camera3D.new()
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.size = 3.4
    camera.position = Vector3(2.3,2.1,5.5)
    stage.add_child(camera)
    camera.look_at(Vector3(0,1.17,0),Vector3.UP)
    camera.current = true
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-48,-24,0)
    light.light_energy = 1.7
    stage.add_child(light)
    var actor := ACTOR.new()
    actor.name = "SingleRigForAllBakedClips"
    stage.add_child(actor)
    await process_frame
    actor.equip_weapon("none")
    actor.pause()
    var folder := BASE_DIR + "/" + Time.get_datetime_string_from_system().replace(":","-")
    if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder)) != OK:
        _fail("could not create output directory")
        return
    var manifest := {
        "asset_id":"AN03_PROCEDURAL_GUIDE_NOT_SHADOW_CHARACTER",
        "source_model":"procedural_mesh_primitives",
        "actual_owner_glb_imported":false,
        "character_visual_approved":false,
        "bone_count":18,
        "texture_size":[SIZE.x,SIZE.y],
        "camera_angles":1,
        "export_type":"actual_Godot_3D_render_png_RGBA",
        "weapon":"none; detachable right hand socket provided",
        "authoritative_damage":false,
        "animations":[]
    }
    var total := 0
    for row in CLIPS:
        var action := str(row["name"])
        var frames := int(row["frames"])
        var duration := float(row["duration"])
        var frame_dir := folder + "/" + action
        if DirAccess.make_dir_recursive_absolute(
                ProjectSettings.globalize_path(frame_dir)) != OK:
            _fail("cannot create directory for " + action)
            return
        actor.select_motion(action)
        actor.pause()
        for frame_index in range(frames):
            # Important: last frame of non-looping attack includes recovery,
            # but looped clips omit their duplicate final/initial pose.
            var t := duration * float(frame_index) / float(
                frames - 1 if action == "attack" else frames)
            actor.seek(t)
            await RenderingServer.frame_post_draw
            var image := viewport.get_texture().get_image()
            if image == null or image.get_width() != SIZE.x or image.get_height() != SIZE.y:
                _fail("wrong viewport pixels at " + action + " " + str(frame_index))
                return
            var filename := "%s/%s_%03d.png" % [frame_dir,action,frame_index]
            if image.save_png(filename) != OK:
                _fail("failed actual framebuffer save: " + filename)
                return
            total += 1
        manifest["animations"].append({
            "name":action,
            "frames":frames,
            "duration_seconds":duration,
            "fps_effective":float(frames)/duration,
            "loop":bool(row["loop"]),
            "height_px":SIZE.y,
            "direction":"fixed_camera_only"
        })
        print("AN03_BAKE_CLIP " + action + " frames=" + str(frames))
    var manifest_file := folder + "/manifest.json"
    var file := FileAccess.open(manifest_file,FileAccess.WRITE)
    if file == null:
        _fail("manifest could not be written")
        return
    file.store_string(JSON.stringify(manifest,"\t"))
    file.close()
    print("AN03_BAKE_GUIDE PASS | actual 3D framebuffer frames=%d | 768x768 | 1 direction | owner mesh PENDING" % total)
    print("AN03_BAKE_DIR: " + ProjectSettings.globalize_path(folder))
    viewport.queue_free()
    quit(0)
