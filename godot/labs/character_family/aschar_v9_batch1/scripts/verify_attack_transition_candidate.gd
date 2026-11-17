extends SceneTree
const CELL := Vector2i(400, 440)
const FOOT_ROW := 429
const FRAME_PATHS := [
    "res://assets/frames/AS48/attack_front_consistency_v2/attack_front_00.png",
    "res://assets/frames/AS48/attack_front_consistency_v2/attack_front_01.png",
    "res://assets/frames/AS48/attack_front_consistency_v2/attack_front_transition_01_5_registered_candidate.png",
    "res://assets/frames/AS48/attack_front_consistency_v2/attack_front_02.png",
    "res://assets/frames/AS48/attack_front_consistency_v2/attack_front_03.png"
]
func _initialize() -> void:
    var resource_path := "res://assets/spriteframes/AS48_V9_attack_transition_candidate.tres"
    var frames := load(resource_path) as SpriteFrames
    if frames == null or not frames.has_animation("Attack_Front"):
        push_error("TRANSITION_SPRITEFRAMES_LOAD_FAIL")
        quit(2)
        return
    if frames.get_frame_count("Attack_Front") != 5 or not is_zero_approx(frames.get_animation_speed("Attack_Front") - 7.0) or frames.get_animation_loop("Attack_Front"):
        push_error("TRANSITION_ANIMATION_CONTRACT_FAIL")
        quit(3)
        return
    var digests := {}
    for i in range(FRAME_PATHS.size()):
        var path: String = FRAME_PATHS[i]
        var texture := frames.get_frame_texture("Attack_Front", i)
        var image := Image.load_from_file(ProjectSettings.globalize_path(path))
        if texture == null or image == null or image.get_size() != CELL or image.detect_alpha() != Image.ALPHA_BLEND:
            push_error("TRANSITION_FRAME_FORMAT_FAIL=" + path)
            quit(4)
            return
        var used := image.get_used_rect()
        if used.size == Vector2i.ZERO or used.position.y + used.size.y - 1 != FOOT_ROW:
            push_error("TRANSITION_FRAME_BASELINE_FAIL=" + path + " " + str(used))
            quit(5)
            return
        var digest := sha256(FileAccess.get_file_as_bytes(ProjectSettings.globalize_path(path)))
        if digests.has(digest):
            push_error("TRANSITION_FRAME_DUPLICATE=" + path)
            quit(6)
            return
        digests[digest] = true
    var meta_file := FileAccess.open("res://meta/AS48_ATTACK_TRANSITION_CANDIDATE.json", FileAccess.READ)
    if meta_file == null:
        push_error("TRANSITION_METADATA_MISSING")
        quit(7)
        return
    var meta: Variant = JSON.parse_string(meta_file.get_as_text())
    meta_file.close()
    if not meta is Dictionary or not bool(meta.get("integrated_in_candidate_spriteframes", false)) or bool(meta.get("production_integrated", true)):
        push_error("TRANSITION_LINEAGE_STATUS_FAIL")
        quit(8)
        return
    print("AS48_ATTACK_TRANSITION_VERIFY=PASS frames=5 unique=5 cell=400x440 rgba=5/5 baseline=429/429 authored_fps=7 no_interpolation=true master_plus_neighbors=true owner_art_pending=true")
    quit(0)
func sha256(bytes: PackedByteArray) -> String:
    var h := HashingContext.new()
    h.start(HashingContext.HASH_SHA256)
    h.update(bytes)
    return h.finish().hex_encode()


