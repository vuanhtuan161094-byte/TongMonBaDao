extends Control

const SEED := 31012026
const DEMO_MAX_SAVE := "user://demo_sandbox/demo_max_v1.json"
const NEW_GAME_SAVE := "user://demo_sandbox/new_game_v1.json"
const GAME_SCENE := "res://scenes/p3/p3_2_landscape_sect.tscn"
const INK := Color(0.14, 0.13, 0.10, 1.0)
const PAPER := Color(0.94, 0.90, 0.78, 1.0)
const JADE := Color(0.14, 0.32, 0.24, 1.0)
const GOLD := Color(0.80, 0.61, 0.26, 1.0)

var status_label: Label
var play_max_button: Button
var new_game_button: Button
var continue_button: Button

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _build_launcher()
    print("TMB_DEMO_USER_DATA_DIR=" + OS.get_user_data_dir())

func _build_launcher() -> void:
    var background := ColorRect.new()
    background.color = Color(0.075, 0.12, 0.095, 1.0)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    var card := PanelContainer.new()
    card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    card.position = Vector2(-390, -285)
    card.size = Vector2(780, 570)
    var parchment := StyleBoxFlat.new()
    parchment.bg_color = PAPER
    parchment.border_color = GOLD
    parchment.set_border_width_all(3)
    parchment.set_corner_radius_all(18)
    parchment.content_margin_left = 38.0
    parchment.content_margin_right = 38.0
    parchment.content_margin_top = 28.0
    parchment.content_margin_bottom = 28.0
    card.add_theme_stylebox_override("panel", parchment)
    add_child(card)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 14)
    card.add_child(column)

    var title := Label.new()
    title.text = "TÔNG MÔN BÁ ĐẠO"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 34)
    title.add_theme_color_override("font_color", JADE)
    column.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "DEMO CHƠI NGAY · COMBAT V2 · JX1 PRESENTATION"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 14)
    subtitle.add_theme_color_override("font_color", INK)
    column.add_child(subtitle)

    play_max_button = _add_button(column, "CHƠI NGAY — DEMO MAX", _start_demo_max, true)
    play_max_button.name = "PlayDemoMax"
    new_game_button = _add_button(column, "CHƠI TỪ ĐẦU", _start_new_game)
    new_game_button.name = "StartNewGame"
    continue_button = _add_button(column, "TIẾP TỤC DEMO", _continue_demo)
    continue_button.name = "ContinueDemo"
    continue_button.disabled = not FileAccess.file_exists(DEMO_MAX_SAVE) and not FileAccess.file_exists(NEW_GAME_SAVE)

    var details := Label.new()
    details.text = "6 đệ tử V2 30.10/30.10 · Mỏ + Linh Lâm + Linh Điền · Tuyệt Địa có Boss"
    details.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    details.add_theme_font_size_override("font_size", 14)
    details.add_theme_color_override("font_color", INK)
    column.add_child(details)

    var provenance := Label.new()
    provenance.text = "VFX JX1 #158/#63/#93 đã đối chiếu SHA-256 · bản đồ JX1: ASSET_INCOMPLETE."
    provenance.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    provenance.add_theme_font_size_override("font_size", 13)
    provenance.add_theme_color_override("font_color", Color(0.22, 0.30, 0.23, 1.0))
    column.add_child(provenance)

    status_label = Label.new()
    status_label.text = "Save của DEMO nằm riêng trong thư mục người dùng của bản DEMO."
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.custom_minimum_size.y = 40
    status_label.add_theme_color_override("font_color", INK)
    column.add_child(status_label)

func _add_button(parent: VBoxContainer, caption: String, action: Callable, primary: bool = false) -> Button:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(0, 58 if primary else 48)
    button.add_theme_font_size_override("font_size", 19 if primary else 16)
    button.add_theme_color_override("font_color", PAPER if primary else INK)
    button.add_theme_color_override("font_hover_color", PAPER if primary else JADE)
    var style := StyleBoxFlat.new()
    style.bg_color = JADE if primary else Color(0.98, 0.95, 0.87, 1.0)
    style.border_color = GOLD if primary else Color(0.51, 0.43, 0.29, 1.0)
    style.set_border_width_all(2)
    style.set_corner_radius_all(10)
    button.add_theme_stylebox_override("normal", style)
    var hover := style.duplicate() as StyleBoxFlat
    hover.bg_color = Color(0.22, 0.43, 0.32, 1.0) if primary else Color(0.91, 0.88, 0.76, 1.0)
    button.add_theme_stylebox_override("hover", hover)
    button.pressed.connect(action)
    parent.add_child(button)
    return button

func _start_demo_max() -> void:
    _set_busy(true, "Đang dựng đội hình DEMO MAX từ hệ thống tuyển mộ và V2...")
    var built := DemoSandboxFactoryV1.create_max_state(SEED)
    if not bool(built.get("ok", false)):
        _set_busy(false, "Không tạo được DEMO MAX: " + str(built.get("reason", "unknown")))
        push_error("DEMO MAX creation failed: " + str(built))
        return
    var directory_error := DirAccess.make_dir_recursive_absolute(
        ProjectSettings.globalize_path("user://demo_sandbox")
    )
    if directory_error != OK and directory_error != ERR_ALREADY_EXISTS:
        _set_busy(false, "Không tạo được thư mục save DEMO: " + str(directory_error))
        return
    var saved := SaveService.new().save_to_path(built["state"], DEMO_MAX_SAVE)
    if saved != OK:
        _set_busy(false, "Không lưu được sandbox DEMO MAX: " + error_string(saved))
        return
    _configure_demo_route(built["hunter_ids"], true)
    _write_short_log("PLAY_DEMO_MAX", "hunters=6 workers=6 assigned=%d" % built["assigned_worker_ids"].size())
    _open_game()

func _start_new_game() -> void:
    _set_busy(true, "Đang mở state khởi đầu bình thường...")
    var directory_error := DirAccess.make_dir_recursive_absolute(
        ProjectSettings.globalize_path("user://demo_sandbox")
    )
    if directory_error != OK and directory_error != ERR_ALREADY_EXISTS:
        _set_busy(false, "Không tạo được thư mục save DEMO: " + str(directory_error))
        return
    var runtime := LiveGameRuntimeV2.new()
    var started := runtime.start(NEW_GAME_SAVE, -1, SEED + 1)
    if not bool(started.get("ok", false)):
        _set_busy(false, "Không mở được state mới: " + str(started.get("reason", "unknown")))
        return
    _configure_demo_route([], false)
    _write_short_log("NEW_GAME", "canonical_starting_state=true")
    _open_game()

func _continue_demo() -> void:
    if FileAccess.file_exists(DEMO_MAX_SAVE):
        _configure_demo_route(DemoSandboxFactoryV1.hunter_ids(), true)
        _write_short_log("CONTINUE_DEMO", "mode=max")
        _open_game()
        return
    if FileAccess.file_exists(NEW_GAME_SAVE):
        _configure_demo_route([], false)
        _write_short_log("CONTINUE_DEMO", "mode=normal")
        _open_game()
        return
    _set_busy(false, "Chưa có save DEMO để tiếp tục.")

func _configure_demo_route(hunter_ids: Array, quick_hunt: bool) -> void:
    ProjectSettings.set_setting("runtime/live_save_path", DEMO_MAX_SAVE if quick_hunt else NEW_GAME_SAVE)
    ProjectSettings.set_setting("demo/quick_hunt", quick_hunt)
    ProjectSettings.set_setting("demo/hunter_ids", hunter_ids.duplicate())
    var jx_loadouts := {}
    if quick_hunt and hunter_ids.size() == 6:
        jx_loadouts[str(hunter_ids[1])] = ["jx_wudang_158"]
        jx_loadouts[str(hunter_ids[2])] = ["jx_wudu_63"]
        jx_loadouts[str(hunter_ids[3])] = ["jx_emei_93"]
    ProjectSettings.set_setting("demo/jx_loadouts", jx_loadouts)

func _open_game() -> void:
    var result := get_tree().change_scene_to_file(GAME_SCENE)
    if result != OK:
        _set_busy(false, "Không mở được bản đồ tông môn: " + error_string(result))

func _set_busy(busy: bool, message: String) -> void:
    if status_label != null:
        status_label.text = message
    if play_max_button != null:
        play_max_button.disabled = busy
        new_game_button.disabled = busy
        continue_button.disabled = busy

func _write_short_log(action: String, detail: String) -> void:
    var log_path := "user://demo_sandbox/demo.log"
    var file := FileAccess.open(log_path, FileAccess.READ_WRITE)
    if file == null:
        file = FileAccess.open(log_path, FileAccess.WRITE)
    if file == null:
        return
    file.seek_end()
    file.store_line("%s | Godot %s | %s | %s" % [Time.get_datetime_string_from_system(), Engine.get_version_info().get("string","unknown"), action, detail])
    file.close()
