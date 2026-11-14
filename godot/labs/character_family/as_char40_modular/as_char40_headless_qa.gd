extends SceneTree
# Isolated Godot 4.7.2 technical QA. Uses TEST ONLY packs; never unlocks production art.
# Invocation: Godot_v4.7.2 --headless --path godot --script \
#   res://labs/character_family/as_char40_modular/as_char40_headless_qa.gd \
#   -- --modular-proof-path=res://labs/character_family/as_char40_modular/proof/export_cobalt

const DIRECTIONS = ["front", "right", "back", "left"]
const STATES = ["idle", "walk", "attack", "cast", "hit", "death"]
const ITEMS = ["jian_blue", "jian_gold"]

func _initialize() -> void:
    var root: String = "res://labs/character_family/as_char40_modular/proof/export_cobalt"
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--modular-proof-path="):
            root = arg.trim_prefix("--modular-proof-path=")
    var failures: Array[String] = []
    var manifest_path: String = root.path_join("export_manifest.json")
    if not FileAccess.file_exists(manifest_path):
        failures.append("missing manifest: " + manifest_path)
    else:
        var manifest: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
        if not manifest is Dictionary:
            failures.append("invalid JSON manifest")
        elif manifest.get("art_approved", true) != false or manifest.get("godot_runtime_pass", true) != false:
            failures.append("fixture must not claim production art/runtime approval")
        elif manifest.get("source_frame_count", 0) != 96 or manifest.get("clip_count", 0) != 24:
            failures.append("unexpected synthetic frame or clip count")
    var names: Array[String] = ["feasibility_lab__body"]
    for item in ITEMS:
        names.append("feasibility_lab__" + item + "_front")
        names.append("feasibility_lab__" + item + "_back")
    var loaded: Array[SpriteFrames] = []
    for name in names:
        var resource_path: String = root.path_join(name + ".tres")
        var resource: Resource = load(resource_path)
        if not resource is SpriteFrames:
            failures.append("not a valid imported SpriteFrames: " + resource_path)
            continue
        var sf: SpriteFrames = resource as SpriteFrames
        loaded.append(sf)
        if sf.get_animation_names().size() != 24:
            failures.append("expected 24 named clips: " + name)
        for state in STATES:
            for direction in DIRECTIONS:
                var clip: String = state + "_" + direction
                if not sf.has_animation(clip):
                    failures.append("missing animation: " + name + " / " + clip)
                elif sf.get_frame_count(clip) != 4:
                    failures.append("not four fixture frames: " + name + " / " + clip)
    if loaded.size() == names.size():
        # An actual Godot AnimatedSprite2D API exercise for each role.
        var roles: Array[AnimatedSprite2D] = []
        for sf in loaded:
            var role := AnimatedSprite2D.new()
            role.sprite_frames = sf
            role.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
            role.animation = "walk_front"
            role.set_frame_and_progress(2, 0.5)
            roles.append(role)
        for role in roles:
            if role.frame != 2 or not is_equal_approx(role.frame_progress, 0.5):
                failures.append("frame/progress sync failed")
            role.free()
    if failures.is_empty():
        print("AS_CHAR40_ENGINE_TECHNICAL_PASS: 24 clips, 96 frames, 2 weapon variants, no art approval")
        quit(0)
    else:
        for error in failures:
            printerr("AS_CHAR40_ENGINE_FAIL: " + error)
        quit(1)
