extends Node

const LAB_SCENE := "res://labs/combat_lab/as_char49_vfx_playtest/playtest.tscn"
const CAPTURE_ROOT := "user://qa49_capture"
const SAMPLE_RATE := 15.0
const SKILL_TIMINGS := [
    [0.83, 1.63, 2.85, 3.48],
    [0.60, 1.55, 2.60, 3.12],
    [0.79, 1.35, 3.20, 4.05],
    [0.62, 1.39, 1.76, 2.72],
    [0.50, 0.88, 6.88, 7.14],
    [0.52, 1.37, 1.72, 2.62],
    [0.52, 1.30, 1.81, 2.36],
]
const SKILL_NAMES := [
    "POI02 Xa Anh Quan Mach",
    "POI03 Phu Cot Co",
    "POI04 Co Vu Me Tung",
    "TAL02 Thien Loi Dan Net",
    "TAL03 Loi Van Truy An",
    "HF02 Lien Diem Phan Gioi R6",
    "HF03 Hoa Tam Ngung Phu R2",
]

var lab: Node2D
var recording := false
var sample_accumulator := 0.0
var frame_index := 0
var failures: Array[String] = []
var skill_results: Array[Dictionary] = []
var hero_start := Vector2.ZERO
var hero_move_distance := 0.0
var monster_move_distance := 0.0

func _ready() -> void:
    call_deferred("_run")

func _process(delta: float) -> void:
    if not recording:
        return
    sample_accumulator += delta
    if sample_accumulator >= 1.0 / SAMPLE_RATE:
        sample_accumulator = 0.0
        _save_video_frame()

func _run() -> void:
    var capture_path := ProjectSettings.globalize_path(CAPTURE_ROOT)
    DirAccess.make_dir_recursive_absolute(capture_path)
    var frame_path := capture_path.path_join("frames")
    DirAccess.make_dir_recursive_absolute(frame_path)

    var packed := load(LAB_SCENE) as PackedScene
    if packed == null:
        _fail("LAB_SCENE_LOAD_FAILED")
        _finish()
        return
    lab = packed.instantiate() as Node2D
    add_child(lab)
    await get_tree().process_frame
    await RenderingServer.frame_post_draw
    await get_tree().process_frame

    if not bool(lab.get("main_ready")):
        _fail("LAB_NOT_READY")
        _finish()
        return
    var asset_errors: Array = lab.get("errors")
    if not asset_errors.is_empty():
        _fail("ASSET_ERRORS=" + str(asset_errors))
    if lab.get("hero") == null:
        _fail("REAL_V10_HERO_MISSING")
    var mobs: Array = lab.get("mobs")
    if mobs.size() != 3:
        _fail("EXPECTED_THREE_REAL_MONSTERS got=" + str(mobs.size()))
        _finish()
        return

    hero_start = (lab.get("hero") as AnimatedSprite2D).position
    var monster_start: Vector2 = (mobs[0]["node"] as AnimatedSprite2D).position
    recording = true

    _send_key(KEY_D, true)
    await _wait_lab_elapsed(float(lab.get("elapsed")) + 1.1)
    _send_key(KEY_D, false)
    await _wait_lab_elapsed(float(lab.get("elapsed")) + 0.12)
    hero_move_distance = hero_start.distance_to((lab.get("hero") as AnimatedSprite2D).position)
    monster_move_distance = monster_start.distance_to((mobs[0]["node"] as AnimatedSprite2D).position)
    if hero_move_distance < 50.0:
        _fail("INPUT_EVENT_MOVEMENT_NOT_OBSERVED distance=" + str(hero_move_distance))
    if monster_move_distance < 20.0:
        _fail("REAL_MONSTER_MOVEMENT_NOT_OBSERVED distance=" + str(monster_move_distance))
    await _capture_png("00_walk_and_moving_monster")

    for skill_index in range(7):
        var emitted_before := int(lab.get("emitted"))
        var collisions_before := int(lab.get("collision_count"))
        var start_elapsed := float(lab.get("elapsed"))
        _send_key(KEY_1 + skill_index, true)
        await get_tree().process_frame
        _send_key(KEY_1 + skill_index, false)
        await _wait_lab_elapsed(start_elapsed + float(SKILL_TIMINGS[skill_index][0]) + 0.08)
        await _capture_png("skill_%02d_charge" % (skill_index + 1))
        await _wait_lab_elapsed(start_elapsed + float(SKILL_TIMINGS[skill_index][1]) + 0.08)
        await _capture_png("skill_%02d_release" % (skill_index + 1))
        await _wait_lab_elapsed(start_elapsed + float(SKILL_TIMINGS[skill_index][2]) + 0.10)
        await _capture_png("skill_%02d_contact" % (skill_index + 1))
        var emitted_after := int(lab.get("emitted"))
        var collisions_after := int(lab.get("collision_count"))
        var event_text := str(lab.get("last_event"))
        if emitted_after != emitted_before + 1:
            _fail("SKILL_INPUT_NOT_EMITTED skill=" + str(skill_index + 1) + " before=" + str(emitted_before) + " after=" + str(emitted_after))
        skill_results.append({
            "skill_index": skill_index + 1,
            "source_contract": SKILL_NAMES[skill_index],
            "input_event_emitted_once": emitted_after == emitted_before + 1,
            "visual_contact_count_delta": collisions_after - collisions_before,
            "observed_event": event_text,
            "art_loaded": true
        })
        await _wait_lab_elapsed(start_elapsed + float(SKILL_TIMINGS[skill_index][3]) + 0.14)

    recording = false
    await RenderingServer.frame_post_draw
    await _capture_png("99_final")
    _write_report(capture_path)
    _finish()

func _send_key(code: Key, pressed: bool) -> void:
    var event := InputEventKey.new()
    event.keycode = code
    event.physical_keycode = code
    event.pressed = pressed
    Input.parse_input_event(event)

func _wait_lab_elapsed(target: float) -> void:
    var guard := 0
    while float(lab.get("elapsed")) < target and guard < 4000:
        await get_tree().process_frame
        guard += 1
    if guard >= 4000:
        _fail("LAB_TIME_TIMEOUT target=" + str(target))

func _capture_png(name: String) -> void:
    await RenderingServer.frame_post_draw
    var image := get_viewport().get_texture().get_image()
    if image == null:
        _fail("VIEWPORT_IMAGE_NULL " + name)
        return
    if image.get_width() != 1280 or image.get_height() != 720:
        _fail("VIEWPORT_SIZE_INVALID " + str(image.get_size()))
        return
    var path := ProjectSettings.globalize_path(CAPTURE_ROOT.path_join(name + ".png"))
    var result := image.save_png(path)
    if result != OK:
        _fail("PNG_SAVE_FAILED " + path)
    else:
        print("QA49_NATIVE_VIEWPORT_PNG name=", name, " size=1280x720 path=", path)

func _save_video_frame() -> void:
    var image := get_viewport().get_texture().get_image()
    if image == null or image.get_width() != 1280 or image.get_height() != 720:
        return
    var path := ProjectSettings.globalize_path(CAPTURE_ROOT.path_join("frames").path_join("%05d.jpg" % frame_index))
    var result := image.save_jpg(path, 0.82)
    if result == OK:
        frame_index += 1

func _write_report(capture_path: String) -> void:
    var report := {
        "passed": failures.is_empty(),
        "engine": Engine.get_version_info(),
        "viewport": "1280x720",
        "input_method": "Input.parse_input_event synthetic GUI harness; not physical mouse/keyboard",
        "hero_move_distance_px": hero_move_distance,
        "moving_monster_distance_px": monster_move_distance,
        "real_monsters": (lab.get("mobs") as Array).size(),
        "skill_count": skill_results.size(),
        "skills": skill_results,
        "visual_only_no_hp_or_status": true,
        "frame_count": frame_index,
        "capture_path": capture_path,
        "failures": failures
    }
    var file := FileAccess.open(CAPTURE_ROOT.path_join("qa49_capture_report.json"), FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify(report, "  "))
        file.close()
    print("QA49_CAPTURE_SUMMARY ", JSON.stringify(report))

func _fail(message: String) -> void:
    failures.append(message)
    push_error("QA49_CAPTURE_FAIL " + message)

func _finish() -> void:
    recording = false
    await RenderingServer.frame_post_draw
    get_tree().quit(1 if not failures.is_empty() else 0)

