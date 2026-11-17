extends Node2D
var frame_count := 0
var large_actor: AnimatedSprite2D
var small_actor: AnimatedSprite2D
var mode := "Walk_Front"
func _ready() -> void:
    var frames: SpriteFrames = load("res://assets/spriteframes/AS48_V9_candidate.tres")
    if frames == null:
        push_error("SPRITEFRAMES_LOAD_FAIL")
        get_tree().quit(2)
        return
    large_actor = AnimatedSprite2D.new()
    large_actor.sprite_frames = frames
    large_actor.animation = "Walk_Front"
    large_actor.position = Vector2(430, 520)
    large_actor.scale = Vector2(0.56, 0.56)
    large_actor.play()
    add_child(large_actor)
    small_actor = AnimatedSprite2D.new()
    small_actor.sprite_frames = frames
    small_actor.animation = "Walk_Front"
    small_actor.position = Vector2(960, 569)
    small_actor.scale = Vector2(0.17, 0.17)
    small_actor.play()
    add_child(small_actor)
    queue_redraw()
func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, Vector2(1280,720)), Color("102126"), true)
    draw_rect(Rect2(36,32,1208,656), Color("172c30"), true)
    draw_rect(Rect2(36,32,1208,5), Color("c9a96a"), true)
    draw_line(Vector2(72,111),Vector2(1208,111),Color("6b795f"),1.0)
    draw_line(Vector2(72,638),Vector2(670,638),Color("8a754e"),2.0)
    draw_line(Vector2(780,605),Vector2(1138,605),Color("8a754e"),2.0)
    draw_string(ThemeDB.fallback_font, Vector2(72,80), "AS-CHAR-48  |  KIẾM TU NAM", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("f2e7c9"))
    draw_string(ThemeDB.fallback_font, Vector2(72,151), "BODY CEL  ·  NO RIG  ·  GODOT 4.7.2", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("91c6c4"))
    draw_string(ThemeDB.fallback_font, Vector2(130,190), "ZOOM REVIEW", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("d2b87c"))
    draw_string(ThemeDB.fallback_font, Vector2(815,190), "MAP SCALE  ≈ 73 PX", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("d2b87c"))
    draw_string(ThemeDB.fallback_font, Vector2(760,248), "WALK_FRONT  /  ATTACK_FRONT", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("f2e7c9"))
    draw_string(ThemeDB.fallback_font, Vector2(760,282), "4 + 4 distinct source cels", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("b7c1b0"))
    draw_string(ThemeDB.fallback_font, Vector2(760,315), "CANDIDATE — WEAPON OVERLAY PENDING", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("e3a991"))
    draw_string(ThemeDB.fallback_font, Vector2(72,665), "Foot baseline registered · 400×440 cel · 8 unique frames", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("b7c1b0"))
func _process(_delta: float) -> void:
    frame_count += 1
    if frame_count == 45:
        call_deferred("_capture", "AS48_WALK_FRONT_NATIVE_1280x720.png")
    if frame_count == 90:
        mode = "Attack_Front"
        large_actor.play(mode)
        small_actor.play(mode)
    if frame_count == 125:
        call_deferred("_capture", "AS48_ATTACK_FRONT_NATIVE_1280x720.png")
    if frame_count == 165:
        mode = "Walk_Front"
        large_actor.play(mode)
        small_actor.play(mode)
    if frame_count == 220:
        call_deferred("_capture", "AS48_WALK_FRONT_RETURN_NATIVE_1280x720.png")
func _capture(file_name: String) -> void:
    await RenderingServer.frame_post_draw
    var image := get_viewport().get_texture().get_image()
    var path := ProjectSettings.globalize_path("res://captures/" + file_name)
    var err := image.save_png(path)
    print("NATIVE_VIEWPORT_CAPTURE=", file_name, " size=", image.get_size(), " exit_error=", err)
