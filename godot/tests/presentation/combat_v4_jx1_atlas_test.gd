extends SceneTree
## CMB-V4 original JX1 art contract. NO binary art is bundled or required for static gate.
const ATLAS = preload("res://src/presentation/labs/combat_v4_jx1_atlas.gd")

func _init() -> void:
    call_deferred("_run")

func _expect(truth: bool, message: String) -> bool:
    if truth:
        return true
    push_error("CMB-V4 JX1: " + message)
    quit(1)
    return false

func _run() -> void:
    if not _expect(ATLAS.CLIPS.size() == 5, "one authentic wolf must provide five clips"):
        return
    if not _expect(ATLAS._git_blob_sha1("abc".to_utf8_buffer()) ==
        "f2ba8f84ab5c1bce84a7b441cb1959cfc7093b7f", "Git blob SHA helper differs from git"):
        return
    for clip in ["st", "run", "at", "hurt", "die"]:
        var meta: Dictionary = ATLAS.CLIPS[clip]
        if not _expect(int(meta["d"]) == 8 and int(meta["n"]) > 0 and int(meta["ms"]) > 0 and
            str(meta["git_sha"]).length() == 40,
            "metadata incomplete for " + clip):
            return
    if not _expect(ATLAS.clip_for_state("walk") == "run" and
        ATLAS.clip_for_state("attack") == "at" and
        ATLAS.clip_for_state("hit") == "hurt" and
        ATLAS.clip_for_state("downed") == "die",
        "presentation clips mapping changed"):
        return
    var actual: Dictionary = ATLAS.load_verified()
    if actual.is_empty():
        print("CMB-V4 JX1 ORIGINAL ASSETS: PENDING LOCAL STAGE, NOT AN ART PASS")
    else:
        if not _expect(actual.size() == 5, "staged JX1 art must contain ALL verified clips"):
            return
        var sprite := Sprite2D.new()
        ATLAS.setup_sprite(sprite, actual, "run", 2, 0.143, false)
        if not _expect(sprite.hframes == 8 and sprite.vframes == 8 and
            sprite.frame_coords == Vector2i(2, 2) and
            absf(sprite.offset.y - (46.0 * 0.5 - 43.0)) < 0.001,
            "8x8 JX1 sprite or origin anchor incorrect"):
            return
        print("CMB-V4 JX1 ORIGINAL ASSETS: FIVE FILES VERIFIED. VISUAL/FPS STILL PENDING")
    print("CMB-V4 JX1 METADATA/HASH STATIC CONTRACT: PASS")
    quit(0)
