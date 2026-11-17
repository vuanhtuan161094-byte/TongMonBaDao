extends Node2D

const BODY_CELL := Vector2(400.0, 440.0)
const HAND_GRIPS: Array[Vector2] = [Vector2(266, 336), Vector2(311, 221), Vector2(290, 315), Vector2(263, 263)]
const ROTATIONS_DEG: Array[float] = [-95.0, -150.0, -95.0, -30.0]
const POSE_NAMES: Array[String] = ["WINDUP", "GUARD RISE", "RELEASE", "RECOVERY"]
const AUTHORED_FPS := 7.0
const CAPTURE_FRAMES := 360
var bodies: Array[Texture2D] = []
var weapon: Texture2D
var font: Font
var elapsed := 0.0
var rendered_frames := 0
var frame_index := 0
var previous_frame := -1
var visited := {}

func _ready() -> void:
    font = ThemeDB.fallback_font
    weapon = load("res://assets/weapons/AS48_KIEMTU_JIAN_CANDIDATE.png") as Texture2D
    if weapon == null:
        push_error("WEAPON_PLAYBACK_LOAD_FAIL=weapon")
        get_tree().quit(3)
        return
    for i in range(4):
        var path := "res://assets/frames/AS48/attack_front_consistency_v2/attack_front_0%d.png" % i
        var texture := load(path) as Texture2D
        if texture == null:
            push_error("WEAPON_PLAYBACK_LOAD_FAIL=" + path)
            get_tree().quit(4)
            return
        bodies.append(texture)
    print("WEAPON_PLAYBACK_START authored_fps=7 capture_fps=60 frames=4 identity=AS48 overlay=separate occlusion=behind_full_body")
    set_process(true)
    queue_redraw()

func _process(delta: float) -> void:
    elapsed += delta
    rendered_frames += 1
    frame_index = int(floor(elapsed * AUTHORED_FPS)) % 4
    visited[frame_index] = true
    if frame_index != previous_frame:
        print("WEAPON_FRAME_TRANSITION capture_frame=%d authored_pose=%d name=%s" % [rendered_frames, frame_index, POSE_NAMES[frame_index]])
        previous_frame = frame_index
        queue_redraw()
    if rendered_frames == 1:
        _capture("AS48_ATTACK_WEAPON_PLAYBACK_NATIVE_1280x720.png")
    if rendered_frames >= CAPTURE_FRAMES:
        if visited.size() != 4:
            push_error("WEAPON_PLAYBACK_COVERAGE_FAIL=" + str(visited.keys()))
            get_tree().quit(5)
            return
        print("WEAPON_PLAYBACK=PASS rendered_frames=%d capture_fps=60 authored_fps=7 unique_poses=%d no_interpolation=true" % [rendered_frames, visited.size()])
        get_tree().quit(0)

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("17232e"), true)
    draw_rect(Rect2(32, 24, 1216, 70), Color("223542"), true)
    draw_string(font, Vector2(52, 58), "AS48 KIẾM TU · ATTACK PLAYBACK · CANDIDATE", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("edf5fb"))
    draw_string(font, Vector2(52, 82), "Godot 4.7.2 · authored clip 7 FPS · native MovieWriter capture 60 FPS", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("b8cbd7"))
    var center := Vector2(438, 388)
    var body_scale := 0.62
    var grip_screen := center + (HAND_GRIPS[frame_index] - BODY_CELL * 0.5) * body_scale
    draw_line(Vector2(118, 518), Vector2(754, 518), Color("c7b278"), 1.5)
    draw_set_transform(grip_screen, deg_to_rad(ROTATIONS_DEG[frame_index]), Vector2(body_scale * 0.19, body_scale * 0.19))
    draw_texture(weapon, -Vector2(443, 360))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    draw_set_transform(center - BODY_CELL * 0.5 * body_scale, 0.0, Vector2(body_scale, body_scale))
    draw_texture(bodies[frame_index], Vector2.ZERO)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    draw_circle(grip_screen, 4.0, Color("ffdc71"))
    draw_arc(grip_screen, 9.0, 0.0, TAU, 32, Color("ffdc71"), 1.5)
    draw_string(font, Vector2(820, 176), "MAP-SCALE CHECK", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("e8dfce"))
    draw_line(Vector2(832, 514), Vector2(1150, 514), Color("c7b278"), 1.0)
    var small_scale := 0.17
    var small_center := Vector2(1000, 460)
    var small_grip := small_center + (HAND_GRIPS[frame_index] - BODY_CELL * 0.5) * small_scale
    draw_set_transform(small_grip, deg_to_rad(ROTATIONS_DEG[frame_index]), Vector2(small_scale * 0.19, small_scale * 0.19))
    draw_texture(weapon, -Vector2(443, 360))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    draw_set_transform(small_center - BODY_CELL * 0.5 * small_scale, 0.0, Vector2(small_scale, small_scale))
    draw_texture(bodies[frame_index], Vector2.ZERO)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    draw_circle(small_grip, 2.5, Color("ffdc71"))
    draw_string(font, Vector2(818, 564), "Frame %02d/03 · %s" % [frame_index, POSE_NAMES[frame_index]], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("ffffff"))
    draw_string(font, Vector2(818, 594), "Separate sword texture · full body remains one RGBA cel", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("b8cbd7"))
    draw_string(font, Vector2(818, 620), "Sword drawn behind the whole body to preserve no-split rule", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("b8cbd7"))
    draw_string(font, Vector2(818, 646), "Contact marks are manual anchors; final art acceptance pending", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("f4d47a"))

func _capture(file_name: String) -> void:
    await RenderingServer.frame_post_draw
    var image := get_viewport().get_texture().get_image()
    if image == null or image.is_empty():
        push_error("WEAPON_PLAYBACK_CAPTURE_FAIL=empty")
        return
    var path := ProjectSettings.globalize_path("res://captures/" + file_name)
    var error := image.save_png(path)
    print("WEAPON_PLAYBACK_STILL=%s size=%dx%d error=%d" % [file_name, image.get_width(), image.get_height(), error])

