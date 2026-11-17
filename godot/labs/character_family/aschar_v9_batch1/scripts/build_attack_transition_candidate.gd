extends SceneTree
const CLIP := "Attack_Front"
const FRAME_PATHS := [
    "res://assets/frames/AS48/attack_front_consistency_v2/attack_front_00.png",
    "res://assets/frames/AS48/attack_front_consistency_v2/attack_front_01.png",
    "res://assets/frames/AS48/attack_front_consistency_v2/attack_front_transition_01_5_registered_candidate.png",
    "res://assets/frames/AS48/attack_front_consistency_v2/attack_front_02.png",
    "res://assets/frames/AS48/attack_front_consistency_v2/attack_front_03.png"
]
const OUTPUT := "res://assets/spriteframes/AS48_V9_attack_transition_candidate.tres"
func _initialize() -> void:
    var collection := SpriteFrames.new()
    collection.add_animation(CLIP)
    collection.set_animation_speed(CLIP, 7.0)
    collection.set_animation_loop(CLIP, false)
    var hash_set := {}
    for path in FRAME_PATHS:
        var texture := load(path) as Texture2D
        if texture == null or texture.get_size() != Vector2(400.0, 440.0):
            push_error("TRANSITION_FRAME_LOAD_OR_SIZE_FAIL=" + path)
            quit(2)
            return
        var bytes := FileAccess.get_file_as_bytes(ProjectSettings.globalize_path(path))
        var digest := sha256(bytes)
        if hash_set.has(digest):
            push_error("TRANSITION_DUPLICATE_FRAME=" + path)
            quit(3)
            return
        hash_set[digest] = true
        collection.add_frame(CLIP, texture)
    var error := ResourceSaver.save(collection, OUTPUT)
    if error != OK:
        push_error("TRANSITION_SPRITEFRAMES_SAVE_FAIL=" + str(error))
        quit(4)
        return
    print("AS48_ATTACK_TRANSITION_SPRITEFRAMES=PASS frames=5 distinct=%d fps=7 loop=false body_only=true" % hash_set.size())
    quit(0)
func sha256(bytes: PackedByteArray) -> String:
    var h := HashingContext.new()
    h.start(HashingContext.HASH_SHA256)
    h.update(bytes)
    return h.finish().hex_encode()

