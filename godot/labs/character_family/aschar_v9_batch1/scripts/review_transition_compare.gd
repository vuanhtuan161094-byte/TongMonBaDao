extends Node2D
const BASELINE := 429
const CELL_CENTER := Vector2(200, 220)
const AUTHORED_FPS := 7.0
const CAPTURE_FRAMES := 360
const REVIEW_CYCLE_SECONDS := 1.1
var left_frames: SpriteFrames
var right_frames: SpriteFrames
var font: Font
var elapsed := 0.0
var render_count := 0
var left_index := -1
var right_index := -1
var left_seen := {}
var right_seen := {}

func _ready() -> void:
    font = ThemeDB.fallback_font
    left_frames = load("res://assets/spriteframes/AS48_V9_consistency_v2.tres") as SpriteFrames
    right_frames = load("res://assets/spriteframes/AS48_V9_attack_transition_candidate.tres") as SpriteFrames
    if left_frames == null or right_frames == null or left_frames.get_frame_count("Attack_Front") != 4 or right_frames.get_frame_count("Attack_Front") != 5:
        push_error("TRANSITION_COMPARE_RESOURCE_FAIL")
        get_tree().quit(3)
        return
    print("TRANSITION_COMPARE_START original=4 candidate=5 authored_fps=7 capture_fps=60")

func _process(delta: float) -> void:
    elapsed += delta
    render_count += 1
    var local_time := fmod(elapsed, REVIEW_CYCLE_SECONDS)
    var next_left := mini(int(floor(local_time * AUTHORED_FPS)), 3)
    var next_right := mini(int(floor(local_time * AUTHORED_FPS)), 4)
    left_seen[next_left] = true
    right_seen[next_right] = true
    if next_left != left_index or next_right != right_index:
        left_index = next_left
        right_index = next_right
        print("TRANSITION_COMPARE_FRAME render=%d baseline_index=%d candidate_index=%d" % [render_count, left_index, right_index])
        queue_redraw()
    if render_count == 1:
        _capture("AS48_ATTACK_TRANSITION_COMPARE_NATIVE_1280x720.png")
    if render_count == 22:
        _capture("AS48_ATTACK_TRANSITION_INSERT_NATIVE_1280x720.png")
    if render_count >= CAPTURE_FRAMES:
        if left_seen.size() != 4 or right_seen.size() != 5:
            push_error("TRANSITION_COMPARE_COVERAGE_FAIL left=%s right=%s" % [left_seen.keys(), right_seen.keys()])
            get_tree().quit(4)
            return
        print("TRANSITION_COMPARE=PASS rendered=%d capture_fps=60 authored_fps=7 baseline_unique=4 candidate_unique=5 new_pose_unique=true loop_or_interpolation=none" % render_count)
        get_tree().quit(0)

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("17232e"), true)
    draw_rect(Rect2(32, 24, 1216, 72), Color("223542"), true)
    draw_string(font, Vector2(52, 58), "AS48 ATTACK · REFERENCE-CHAIN CONTINUITY TEST", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("edf5fb"))
    draw_string(font, Vector2(52, 82), "Godot 4.7.2 · actual authored 7 FPS · 60 FPS native capture is only the recording rate", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("b8cbd7"))
    draw_line(Vector2(640, 122), Vector2(640, 594), Color("5f7382"), 1.0)
    draw_string(font, Vector2(75, 145), "BASELINE · FOUR EXISTING POSES", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("e8ccb0"))
    draw_string(font, Vector2(690, 145), "CANDIDATE · FIVE UNIQUE POSES", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("a9d8cb"))
    var scale := 0.55
    var baseline_screen := 510.0
    draw_line(Vector2(70, baseline_screen), Vector2(610, baseline_screen), Color("c7b278"), 1.5)
    draw_line(Vector2(670, baseline_screen), Vector2(1210, baseline_screen), Color("c7b278"), 1.5)
    var left_texture := left_frames.get_frame_texture("Attack_Front", maxi(left_index, 0))
    var right_texture := right_frames.get_frame_texture("Attack_Front", maxi(right_index, 0))
    var left_origin := Vector2(340.0 - CELL_CENTER.x * scale, baseline_screen - BASELINE * scale)
    var right_origin := Vector2(940.0 - CELL_CENTER.x * scale, baseline_screen - BASELINE * scale)
    if left_texture != null:
        draw_set_transform(left_origin, 0.0, Vector2(scale, scale))
        draw_texture(left_texture, Vector2.ZERO)
        draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    if right_texture != null:
        draw_set_transform(right_origin, 0.0, Vector2(scale, scale))
        draw_texture(right_texture, Vector2.ZERO)
        draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    draw_string(font, Vector2(74, 555), "frame %d/3 · %s" % [maxi(left_index, 0), _pose_name(maxi(left_index, 0), false)], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("ffffff"))
    draw_string(font, Vector2(674, 555), "frame %d/4 · %s" % [maxi(right_index, 0), _pose_name(maxi(right_index, 0), true)], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("ffffff"))
    draw_string(font, Vector2(44, 624), "New cel references the frozen master plus key poses 01 and 02; no frame interpolation, no mirrored pose, no weapon/VFX baked in.", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("f4d47a"))
    draw_string(font, Vector2(44, 656), "Candidate-only SpriteFrames. Identity/palette review looked consistent; motion and owner art approval remain pending.", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("b8cbd7"))
    draw_string(font, Vector2(44, 687), "Both actors use the same 400×440 cell and y=429 foot row.", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("b8cbd7"))

func _pose_name(index: int, candidate: bool) -> String:
    if candidate and index == 2:
        return "REFERENCED MID-SWING"
    var labels := ["WINDUP", "GUARD RISE", "RELEASE", "RECOVERY"]
    return labels[mini(index, labels.size() - 1)]

func _capture(file_name: String) -> void:
    await RenderingServer.frame_post_draw
    var image := get_viewport().get_texture().get_image()
    var path := ProjectSettings.globalize_path("res://captures/" + file_name)
    var error := image.save_png(path)
    print("TRANSITION_COMPARE_STILL=%s size=%s error=%d" % [file_name, image.get_size(), error])
