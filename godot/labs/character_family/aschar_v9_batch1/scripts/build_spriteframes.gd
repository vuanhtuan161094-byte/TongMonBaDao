extends SceneTree
func _initialize() -> void:
    var sf := SpriteFrames.new()
    sf.clear_all()
    var specs := {
      "Walk_Front": {"atlas":"res://assets/atlases/AS48_walk_front_atlas.png", "fps":8.0, "loop":true},
      "Attack_Front": {"atlas":"res://assets/atlases/AS48_attack_front_atlas.png", "fps":7.0, "loop":false}
    }
    for name in specs:
        var spec: Dictionary = specs[name]
        var tex: Texture2D = load(spec.atlas)
        if tex == null:
            push_error("ATLAS_IMPORT_FAIL=" + spec.atlas); quit(2); return
        sf.add_animation(name)
        sf.set_animation_speed(name, float(spec.fps))
        sf.set_animation_loop(name, bool(spec.loop))
        for i in range(4):
            var atlas := AtlasTexture.new()
            atlas.atlas = tex
            atlas.region = Rect2(i * 400, 0, 400, 440)
            sf.add_frame(name, atlas)
    var err := ResourceSaver.save(sf, "res://assets/spriteframes/AS48_V9_candidate.tres")
    if err != OK:
        push_error("SPRITEFRAMES_SAVE_ERROR=" + str(err)); quit(3); return
    print("AS48_SPRITEFRAMES_BUILD=PASS clips=2 frames=8")
    quit(0)

