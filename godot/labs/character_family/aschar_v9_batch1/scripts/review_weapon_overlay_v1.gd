extends Node2D

const BODY_CELL := Vector2(400.0, 440.0)
const HAND_GRIP_ASSET_PX := Vector2(443.0, 360.0)
const DISPLAY_SCALE := 0.48
const WEAPON_BODY_RATIO := 0.19
const FRAME_PATHS := [
    "res://assets/frames/AS48/attack_front_consistency_v2/attack_front_00.png",
    "res://assets/frames/AS48/attack_front_consistency_v2/attack_front_01.png",
    "res://assets/frames/AS48/attack_front_consistency_v2/attack_front_02.png",
    "res://assets/frames/AS48/attack_front_consistency_v2/attack_front_03.png"
]
const HAND_GRIPS: Array[Vector2] = [Vector2(266, 336), Vector2(311, 221), Vector2(290, 315), Vector2(263, 263)]
const ROTATIONS_DEG := [-95.0, -150.0, -95.0, -30.0]
const POSE_NAMES := ["WINDUP", "GUARD RISE", "RELEASE", "RECOVERY"]

var bodies: Array[Texture2D] = []
var weapon: Texture2D
var font: Font
var capture_done := false

func _ready() -> void:
    font = ThemeDB.fallback_font
    weapon = load("res://assets/weapons/AS48_KIEMTU_JIAN_CANDIDATE.png") as Texture2D
    if weapon == null:
        push_error("WEAPON_OVERLAY_TEXTURE=FAIL")
        get_tree().quit(3)
        return
    for path in FRAME_PATHS:
        var body := load(path) as Texture2D
        if body == null:
            push_error("WEAPON_OVERLAY_BODY=FAIL path=" + path)
            get_tree().quit(3)
            return
        bodies.append(body)
    queue_redraw()
    call_deferred("_capture_viewport")

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("17232e"), true)
    draw_rect(Rect2(24, 20, 1232, 76), Color("223542"), true)
    draw_string(font, Vector2(48, 55), "KIẾM TU — ATTACK OVERLAY STUDY · CANDIDATE", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("edf5fb"))
    draw_string(font, Vector2(48, 82), "Front body cel stays monolithic · weapon is an independent RGBA layer · no VFX", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("a9c2d2"))
    var centers := [Vector2(160, 355), Vector2(480, 355), Vector2(800, 355), Vector2(1120, 355)]
    for i in range(4):
        draw_rect(Rect2(centers[i].x - 146, 112, 292, 468), Color("20313d"), true)
        draw_rect(Rect2(centers[i].x - 146, 112, 292, 468), Color("587180"), false, 1.0)
        var hand: Vector2 = HAND_GRIPS[i]
        var grip_screen: Vector2 = centers[i] + (hand - BODY_CELL * 0.5) * DISPLAY_SCALE
        var overlay_scale := DISPLAY_SCALE * WEAPON_BODY_RATIO
        draw_set_transform(grip_screen, deg_to_rad(ROTATIONS_DEG[i]), Vector2(overlay_scale, overlay_scale))
        draw_texture(weapon, -HAND_GRIP_ASSET_PX)
        draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
        draw_set_transform(centers[i] - BODY_CELL * 0.5 * DISPLAY_SCALE, 0.0, Vector2(DISPLAY_SCALE, DISPLAY_SCALE))
        draw_texture(bodies[i], Vector2.ZERO)
        draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
        draw_circle(grip_screen, 4.0, Color("ffdc71"))
        draw_arc(grip_screen, 8.0, 0.0, TAU, 32, Color("ffdc71"), 1.5)
        draw_string(font, Vector2(centers[i].x - 130, 535), "F%02d · %s" % [i, POSE_NAMES[i]], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("ffffff"))
        draw_string(font, Vector2(centers[i].x - 130, 558), "grip %d,%d  rot %.0f°" % [int(hand.x), int(hand.y), ROTATIONS_DEG[i]], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("b8cbd7"))
    draw_string(font, Vector2(42, 620), "Yellow marker = manually estimated grip anchor · occlusion study: sword drawn BEHIND the whole body cel", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("f4d47a"))
    draw_string(font, Vector2(42, 650), "This avoids body splitting; final hand-over-hilt occlusion and all anchors still need measured visual acceptance.", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("d3e0e8"))
    draw_string(font, Vector2(42, 685), "400×440 source cell · y=430 foot baseline · enlarged 0.48× preview (not game-size proof)", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("a9c2d2"))

func _capture_viewport() -> void:
    await get_tree().process_frame
    await RenderingServer.frame_post_draw
    var image := get_viewport().get_texture().get_image()
    if image == null or image.is_empty():
        push_error("WEAPON_OVERLAY_VIEWPORT_CAPTURE=FAIL empty viewport")
        return
    var output := ProjectSettings.globalize_path("res://captures/AS48_ATTACK_WEAPON_OVERLAY_NATIVE_1280x720.png")
    var err := image.save_png(output)
    print("WEAPON_OVERLAY_VIEWPORT_CAPTURE=%s size=%dx%d path=%s" % ["PASS" if err == OK else "FAIL", image.get_width(), image.get_height(), output])
    capture_done = true



