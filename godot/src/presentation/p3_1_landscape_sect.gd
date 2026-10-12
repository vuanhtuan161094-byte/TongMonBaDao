extends Control

const DEMO_SEED := 31012026
const BASE_SIZE := Vector2(1280.0, 720.0)
const LIVE_SAVE_PATH := LiveGameRuntimeV2.DEFAULT_SAVE_PATH
const LIVE_SAVE_PATH_SETTING := "runtime/live_save_path"
const RUNTIME_POLL_SECONDS := 1.0
const AUTOSAVE_SECONDS := 15.0

const INK := Color(0.12, 0.11, 0.09, 1.0)
const PAPER := Color(0.91, 0.86, 0.72, 0.98)
const PAPER_LIGHT := Color(0.97, 0.94, 0.84, 0.98)
const JADE := Color(0.28, 0.48, 0.37, 1.0)
const JADE_DARK := Color(0.10, 0.22, 0.17, 0.97)
const CINNABAR := Color(0.72, 0.27, 0.15, 1.0)
const GOLD := Color(0.78, 0.61, 0.25, 1.0)

var state: SimulationState
var runtime_session: LiveGameRuntimeV2
var runtime_ready := false
var runtime_failure_reason := ""
var runtime_poll_timer: Timer
var autosave_timer: Timer
var workforce := WorkforceSystem.new()
var warehouse_ui := WarehouseSystem.new()
var bloodlines := BloodlineSystem.new()
var physiques := PhysiqueSystem.new()
var cultivation := CultivationSystem.new()
var generator := DiscipleGeneratorV2.new()

var map_layer: Control
var popup_layer: Control
var resource_label: Label
var time_label: Label
var task_label: Label
var selected_id: StringName = &""

var actor_nodes: Dictionary = {}
var actor_destinations: Dictionary = {}
var actor_status_labels: Dictionary = {}

var saw_work := false
var saw_cultivation := false
var opened_disciple_profile := false

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    custom_minimum_size = BASE_SIZE

    runtime_session = LiveGameRuntimeV2.new()
    var started := runtime_session.start(_resolved_live_save_path(), -1, DEMO_SEED)
    if not bool(started.get("ok", false)):
        runtime_failure_reason = str(started.get("reason", "live_runtime_start_failed"))
        push_error("P3 live runtime failed: %s" % runtime_failure_reason)
        _build_runtime_failure_shell()
        return

    state = runtime_session.state()
    runtime_ready = state != null
    if not runtime_ready:
        runtime_failure_reason = "live_runtime_state_missing"
        push_error("P3 live runtime returned no state.")
        _build_runtime_failure_shell()
        return

    _build_shell()
    _spawn_all_disciples()
    _refresh_all()
    _start_runtime_timers()

func _resolved_live_save_path() -> String:
    var configured := str(ProjectSettings.get_setting(
        LIVE_SAVE_PATH_SETTING,LIVE_SAVE_PATH
    )).strip_edges()
    return LIVE_SAVE_PATH if configured.is_empty() else configured

func _start_runtime_timers() -> void:
    runtime_poll_timer = Timer.new()
    runtime_poll_timer.name = "RuntimeWallClockPoll"
    runtime_poll_timer.wait_time = RUNTIME_POLL_SECONDS
    runtime_poll_timer.one_shot = false
    runtime_poll_timer.autostart = true
    runtime_poll_timer.timeout.connect(_advance_simulation)
    add_child(runtime_poll_timer)

    autosave_timer = Timer.new()
    autosave_timer.name = "RuntimeAutosave"
    autosave_timer.wait_time = AUTOSAVE_SECONDS
    autosave_timer.one_shot = false
    autosave_timer.autostart = true
    autosave_timer.timeout.connect(_autosave_runtime)
    add_child(autosave_timer)

func _build_runtime_failure_shell() -> void:
    var background := ColorRect.new()
    background.color = Color(0.10, 0.11, 0.10, 1.0)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    var title := Label.new()
    title.text = "Không thể tải dữ liệu Tông Môn"
    title.position = Vector2(260, 250)
    title.size = Vector2(760, 48)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 28)
    title.add_theme_color_override("font_color", Color(0.94, 0.82, 0.47, 1.0))
    add_child(title)

    var detail := Label.new()
    detail.text = "Runtime dừng để bảo vệ save. Lý do: %s" % runtime_failure_reason
    detail.position = Vector2(260, 310)
    detail.size = Vector2(760, 72)
    detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail.add_theme_font_size_override("font_size", 16)
    detail.add_theme_color_override("font_color", Color(0.92, 0.90, 0.84, 1.0))
    add_child(detail)

func _build_shell() -> void:
    var background := ColorRect.new()
    background.color = Color(0.67, 0.75, 0.59, 1.0)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    map_layer = Control.new()
    map_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(map_layer)

    _build_map_decoration()
    _build_buildings()
    _build_top_bar()
    _build_bottom_bar()

    popup_layer = Control.new()
    popup_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    # The empty overlay must never steal map taps. Children (dim/panels/buttons)
    # still receive their own events when a popup exists.
    popup_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(popup_layer)

func _build_map_decoration() -> void:
    var inner := Panel.new()
    inner.name = "SectTerrainBase"
    inner.position = Vector2(250, 78)
    inner.size = Vector2(1012, 558)
    inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
    inner.add_theme_stylebox_override("panel", _style(Color(0.76, 0.80, 0.63, 1.0), Color(0.24, 0.31, 0.20, 0.78), 2, 30))
    map_layer.add_child(inner)

    var earth_patch := Polygon2D.new()
    earth_patch.polygon = PackedVector2Array([
        Vector2(278, 110), Vector2(520, 92), Vector2(662, 154), Vector2(610, 278),
        Vector2(394, 298), Vector2(282, 226)
    ])
    earth_patch.color = Color(0.72, 0.72, 0.54, 0.42)
    map_layer.add_child(earth_patch)

    var stone_patch := Polygon2D.new()
    stone_patch.polygon = PackedVector2Array([
        Vector2(862, 102), Vector2(1188, 112), Vector2(1218, 284), Vector2(1090, 340),
        Vector2(882, 286), Vector2(820, 178)
    ])
    stone_patch.color = Color(0.68, 0.73, 0.62, 0.35)
    map_layer.add_child(stone_patch)

    var river := Line2D.new()
    river.name = "SectStream"
    river.points = PackedVector2Array([
        Vector2(268, 430), Vector2(404, 414), Vector2(540, 424), Vector2(686, 452),
        Vector2(820, 446), Vector2(972, 424), Vector2(1215, 440)
    ])
    river.width = 46.0
    river.default_color = Color(0.40, 0.68, 0.70, 0.68)
    river.antialiased = true
    map_layer.add_child(river)

    var river_light := Line2D.new()
    river_light.points = river.points
    river_light.width = 12.0
    river_light.default_color = Color(0.72, 0.88, 0.84, 0.38)
    river_light.antialiased = true
    map_layer.add_child(river_light)

    _add_map_path(PackedVector2Array([
        Vector2(1120, 520), Vector2(1005, 430), Vector2(790, 365), Vector2(690, 330), Vector2(620, 210)
    ]))
    _add_map_path(PackedVector2Array([
        Vector2(690, 330), Vector2(510, 385), Vector2(356, 365)
    ]))
    _add_map_path(PackedVector2Array([
        Vector2(690, 330), Vector2(815, 505)
    ]))
    _add_map_path(PackedVector2Array([
        Vector2(790, 365), Vector2(912, 220)
    ]))
    _add_map_path(PackedVector2Array([
        Vector2(790, 365), Vector2(1005, 385)
    ]))
    _add_map_path(PackedVector2Array([
        Vector2(620, 210), Vector2(690, 330), Vector2(540, 485)
    ]))

    var courtyard := Panel.new()
    courtyard.position = Vector2(644, 294)
    courtyard.size = Vector2(94, 70)
    courtyard.mouse_filter = Control.MOUSE_FILTER_IGNORE
    courtyard.add_theme_stylebox_override("panel", _style(Color(0.82, 0.76, 0.60, 0.86), Color(0.50, 0.43, 0.30, 0.65), 2, 34))
    map_layer.add_child(courtyard)

    for tree_pos in [
        Vector2(278, 126), Vector2(330, 150), Vector2(388, 118), Vector2(1162, 152),
        Vector2(1120, 210), Vector2(1180, 300), Vector2(302, 540), Vector2(366, 574),
        Vector2(1010, 566), Vector2(1160, 574), Vector2(904, 590)
    ]:
        _add_map_tree(tree_pos)

    for rock_pos in [
        Vector2(286, 278), Vector2(334, 258), Vector2(1185, 380),
        Vector2(440, 590), Vector2(1080, 594), Vector2(742, 592)
    ]:
        _add_map_rock(rock_pos)

func _add_map_path(points: PackedVector2Array) -> void:
    var path := Line2D.new()
    path.points = points
    path.width = 20.0
    path.default_color = Color(0.75, 0.67, 0.50, 0.80)
    path.antialiased = true
    map_layer.add_child(path)

    var center := Line2D.new()
    center.points = points
    center.width = 4.0
    center.default_color = Color(0.84, 0.78, 0.62, 0.42)
    center.antialiased = true
    map_layer.add_child(center)

func _add_map_tree(pos: Vector2) -> void:
    var trunk := ColorRect.new()
    trunk.position = pos + Vector2(13, 24)
    trunk.size = Vector2(7, 18)
    trunk.color = Color(0.38, 0.29, 0.19, 0.90)
    trunk.mouse_filter = Control.MOUSE_FILTER_IGNORE
    map_layer.add_child(trunk)

    var crown := Panel.new()
    crown.position = pos
    crown.size = Vector2(34, 34)
    crown.mouse_filter = Control.MOUSE_FILTER_IGNORE
    crown.add_theme_stylebox_override("panel", _style(Color(0.29, 0.48, 0.31, 0.94), Color(0.20, 0.36, 0.24, 0.72), 1, 18))
    map_layer.add_child(crown)

    var crown_small := Panel.new()
    crown_small.position = pos + Vector2(18, 8)
    crown_small.size = Vector2(25, 25)
    crown_small.mouse_filter = Control.MOUSE_FILTER_IGNORE
    crown_small.add_theme_stylebox_override("panel", _style(Color(0.36, 0.55, 0.36, 0.90), Color(0.22, 0.38, 0.25, 0.60), 1, 14))
    map_layer.add_child(crown_small)

func _add_map_rock(pos: Vector2) -> void:
    var rock := Panel.new()
    rock.position = pos
    rock.size = Vector2(30, 20)
    rock.mouse_filter = Control.MOUSE_FILTER_IGNORE
    rock.add_theme_stylebox_override("panel", _style(Color(0.48, 0.50, 0.45, 0.78), Color(0.34, 0.36, 0.32, 0.60), 1, 12))
    map_layer.add_child(rock)

func _build_buildings() -> void:
    var buildings := [
        {"id":"main_hall", "name":"Đại Điện", "pos":Vector2(548, 112), "size":Vector2(184, 112), "body":Color(0.48, 0.34, 0.22, 1.0), "roof":Color(0.22, 0.32, 0.29, 1.0), "kind":"hall"},
        {"id":"residence", "name":"Đệ Tử Xá", "pos":Vector2(848, 142), "size":Vector2(158, 96), "body":Color(0.53, 0.43, 0.29, 1.0), "roof":Color(0.28, 0.38, 0.34, 1.0), "kind":"residence"},
        {"id":"ren_than_duong", "name":"Rèn Thân Đường", "pos":Vector2(290, 157), "size":Vector2(174, 112), "body":Color(0.52, 0.42, 0.32, 1.0), "roof":Color(0.35, 0.30, 0.25, 1.0), "kind":"body_training"},
        {"id":"cultivation", "name":"Tu Luyện Đài", "pos":Vector2(715, 288), "size":Vector2(160, 104), "body":Color(0.35, 0.50, 0.45, 1.0), "roof":Color(0.68, 0.61, 0.40, 1.0), "kind":"platform"},
        {"id":"warehouse", "name":"Kho", "pos":Vector2(952, 332), "size":Vector2(132, 92), "body":Color(0.52, 0.39, 0.24, 1.0), "roof":Color(0.26, 0.34, 0.31, 1.0), "kind":"warehouse"},
        {"id":"forge", "name":"Luyện Khí Đường", "pos":Vector2(466, 432), "size":Vector2(158, 112), "body":Color(0.56, 0.31, 0.20, 1.0), "roof":Color(0.30, 0.29, 0.27, 1.0), "kind":"forge"},
        {"id":"medicine", "name":"Dược Phòng", "pos":Vector2(748, 466), "size":Vector2(152, 100), "body":Color(0.40, 0.55, 0.34, 1.0), "roof":Color(0.24, 0.38, 0.31, 1.0), "kind":"medicine"},
        {"id":"alchemy_hall", "name":"Luyện Đan Điện", "pos":Vector2(910, 470), "size":Vector2(142, 96), "body":Color(0.52, 0.45, 0.31, 1.0), "roof":Color(0.43, 0.28, 0.24, 1.0), "kind":"alchemy"},
        {"id":"mine", "name":"Khai Khoáng", "pos":Vector2(288, 304), "size":Vector2(142, 108), "body":Color(0.43, 0.40, 0.35, 1.0), "roof":Color(0.23, 0.24, 0.23, 1.0), "kind":"mine"},
        {"id":"linh_forest", "name":"Linh Lâm", "pos":Vector2(105, 315), "size":Vector2(150, 100), "body":Color(0.31, 0.50, 0.29, 1.0), "roof":Color(0.20, 0.38, 0.24, 1.0), "kind":"forest"},
        {"id":"spirit_field", "name":"Linh Điền", "pos":Vector2(105, 455), "size":Vector2(160, 98), "body":Color(0.43, 0.55, 0.32, 1.0), "roof":Color(0.33, 0.42, 0.25, 1.0), "kind":"field"},
        {"id":"guidance", "name":"Dẫn Tiên Đài", "pos":Vector2(1060, 244), "size":Vector2(150, 94), "body":Color(0.45, 0.57, 0.44, 1.0), "roof":Color(0.69, 0.59, 0.34, 1.0), "kind":"platform"},
        {"id":"gate", "name":"Đại Môn", "pos":Vector2(1068, 454), "size":Vector2(164, 116), "body":Color(0.47, 0.34, 0.23, 1.0), "roof":Color(0.24, 0.31, 0.28, 1.0), "kind":"gate"}
    ]

    for data_value in buildings:
        var data: Dictionary = data_value
        _build_playable_building_token(data)

func _build_playable_building_token(data: Dictionary) -> void:
    var holder := Control.new()
    var destination := StringName(data.get("id", ""))
    holder.name = "BuildingToken_%s" % str(destination)
    var holder_position: Vector2 = data.get("pos", Vector2.ZERO)
    var holder_size: Vector2 = data.get("size", Vector2(140, 96))
    holder.position = holder_position
    holder.size = holder_size
    holder.mouse_filter = Control.MOUSE_FILTER_PASS
    map_layer.add_child(holder)

    var body: Color = data.get("body", Color(0.5, 0.4, 0.3, 1.0))
    var roof: Color = data.get("roof", Color(0.25, 0.32, 0.28, 1.0))
    var kind := str(data.get("kind", "hall"))
    var w := holder.size.x
    var h := holder.size.y

    var shadow := Panel.new()
    shadow.position = Vector2(8, h * 0.32 + 8)
    shadow.size = Vector2(w - 16, h * 0.54)
    shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
    shadow.add_theme_stylebox_override("panel", _style(Color(0.10, 0.12, 0.10, 0.18), Color.TRANSPARENT, 0, 22))
    holder.add_child(shadow)

    match kind:
        "platform":
            var ring := Panel.new()
            ring.position = Vector2(w * 0.16, 8)
            ring.size = Vector2(w * 0.68, h * 0.68)
            ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
            ring.add_theme_stylebox_override("panel", _style(body, GOLD.darkened(0.12), 3, 44))
            holder.add_child(ring)
            var core := Panel.new()
            core.position = Vector2(w * 0.34, 25)
            core.size = Vector2(w * 0.32, h * 0.32)
            core.mouse_filter = Control.MOUSE_FILTER_IGNORE
            core.add_theme_stylebox_override("panel", _style(Color(0.82, 0.78, 0.57, 0.92), JADE_DARK, 2, 28))
            holder.add_child(core)
        "body_training":
            _add_building_block(holder, Vector2(14, h * 0.37), Vector2(w - 28, h * 0.45), body, 10)
            _add_building_block(holder, Vector2(6, h * 0.18), Vector2(w - 12, h * 0.28), roof, 14)
            _add_building_block(holder, Vector2(32, 10), Vector2(18, 23), GOLD.darkened(0.23), 5)
            _add_building_block(holder, Vector2(w - 50, 10), Vector2(18, 23), GOLD.darkened(0.23), 5)
        "field":
            _add_building_block(holder, Vector2(8, 14), Vector2(w - 16, h * 0.64), Color(0.39, 0.31, 0.20, 1.0), 10)
            for row_index in range(4):
                _add_building_block(
                    holder,
                    Vector2(17, 20 + row_index * 13),
                    Vector2(w - 34, 7),
                    body.lightened(0.05 * float(row_index)),
                    4
                )
        "forest":
            _add_building_block(holder, Vector2(10, h * 0.58), Vector2(w - 20, h * 0.20), Color(0.37, 0.29, 0.18, 1.0), 8)
            for tree_index in range(4):
                var tree_x := 18.0 + float(tree_index) * ((w - 42.0) / 3.0)
                _add_building_block(holder, Vector2(tree_x, h * 0.30), Vector2(8, h * 0.34), Color(0.33, 0.24, 0.15, 1.0), 4)
                _add_building_block(holder, Vector2(tree_x - 11, 8 + (tree_index % 2) * 5), Vector2(30, h * 0.40), body.lightened(0.04 * float(tree_index)), 18)
        "mine":
            var rock := Panel.new()
            rock.position = Vector2(12, 10)
            rock.size = Vector2(w - 24, h * 0.68)
            rock.mouse_filter = Control.MOUSE_FILTER_IGNORE
            rock.add_theme_stylebox_override("panel", _style(body, Color(0.22, 0.22, 0.20, 1.0), 3, 38))
            holder.add_child(rock)
            var mouth := Panel.new()
            mouth.position = Vector2(w * 0.31, h * 0.30)
            mouth.size = Vector2(w * 0.38, h * 0.40)
            mouth.mouse_filter = Control.MOUSE_FILTER_IGNORE
            mouth.add_theme_stylebox_override("panel", _style(Color(0.11, 0.12, 0.11, 1.0), Color(0.28, 0.25, 0.20, 1.0), 2, 24))
            holder.add_child(mouth)
        "gate":
            _add_building_block(holder, Vector2(18, 22), Vector2(26, h * 0.60), body, 8)
            _add_building_block(holder, Vector2(w - 44, 22), Vector2(26, h * 0.60), body, 8)
            _add_building_block(holder, Vector2(9, 14), Vector2(w - 18, 24), roof, 10)
            _add_building_block(holder, Vector2(30, 2), Vector2(w - 60, 19), roof.lightened(0.06), 9)
        _:
            var base := Panel.new()
            base.position = Vector2(12, h * 0.34)
            base.size = Vector2(w - 24, h * 0.48)
            base.mouse_filter = Control.MOUSE_FILTER_IGNORE
            base.add_theme_stylebox_override("panel", _style(body, body.darkened(0.38), 2, 12))
            holder.add_child(base)

            var roof_panel := Panel.new()
            roof_panel.position = Vector2(3, h * 0.18)
            roof_panel.size = Vector2(w - 6, h * 0.30)
            roof_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
            roof_panel.add_theme_stylebox_override("panel", _style(roof, roof.darkened(0.35), 2, 18))
            holder.add_child(roof_panel)

            if kind == "residence":
                _add_building_block(holder, Vector2(28, 8), Vector2(42, 24), roof.lightened(0.05), 10)
                _add_building_block(holder, Vector2(w - 70, 12), Vector2(42, 22), roof.lightened(0.05), 10)
            elif kind == "warehouse":
                _add_building_block(holder, Vector2(24, h * 0.56), Vector2(28, 24), Color(0.63, 0.48, 0.27, 1.0), 4)
                _add_building_block(holder, Vector2(55, h * 0.53), Vector2(30, 27), Color(0.69, 0.52, 0.29, 1.0), 4)
            elif kind == "forge":
                _add_building_block(holder, Vector2(w - 38, 2), Vector2(20, 40), Color(0.31, 0.27, 0.24, 1.0), 5)
                _add_building_block(holder, Vector2(25, h * 0.59), Vector2(24, 17), Color(0.83, 0.42, 0.18, 1.0), 8)
            elif kind == "medicine":
                _add_building_block(holder, Vector2(22, h * 0.66), Vector2(22, 11), Color(0.29, 0.48, 0.25, 1.0), 6)
                _add_building_block(holder, Vector2(50, h * 0.66), Vector2(22, 11), Color(0.33, 0.55, 0.28, 1.0), 6)
                _add_building_block(holder, Vector2(78, h * 0.66), Vector2(22, 11), Color(0.27, 0.45, 0.24, 1.0), 6)
            elif kind == "alchemy":
                _add_building_block(holder, Vector2(w * 0.37, h * 0.52), Vector2(w * 0.26, h * 0.26), Color(0.30, 0.31, 0.28, 1.0), 10)
                _add_building_block(holder, Vector2(w * 0.43, h * 0.36), Vector2(w * 0.14, h * 0.20), Color(0.74, 0.48, 0.20, 1.0), 8)

    var name_plate := Label.new()
    name_plate.text = str(data.get("name", destination))
    name_plate.position = Vector2(4, h - 25)
    name_plate.size = Vector2(w - 8, 24)
    name_plate.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    name_plate.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    name_plate.add_theme_font_size_override("font_size", 13)
    name_plate.add_theme_color_override("font_color", INK)
    name_plate.add_theme_color_override("font_shadow_color", PAPER_LIGHT)
    name_plate.add_theme_constant_override("shadow_offset_x", 1)
    name_plate.add_theme_constant_override("shadow_offset_y", 1)
    name_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
    holder.add_child(name_plate)

    var hit := Button.new()
    hit.name = "BuildingHit_%s" % str(destination)
    hit.position = Vector2.ZERO
    hit.size = holder.size
    hit.text = ""
    hit.tooltip_text = str(data.get("name", destination))
    hit.add_theme_stylebox_override("normal", _style(Color(1, 1, 1, 0.01), Color(1, 1, 1, 0.0), 0, 14))
    hit.add_theme_stylebox_override("hover", _style(Color(1, 0.92, 0.60, 0.07), GOLD, 3, 14))
    hit.add_theme_stylebox_override("pressed", _style(Color(1, 0.85, 0.45, 0.10), GOLD, 3, 14))
    hit.pressed.connect(Callable(self, "_open_building").bind(destination))
    holder.add_child(hit)

func _add_building_block(parent: Control, pos: Vector2, block_size: Vector2, fill: Color, radius: int) -> void:
    var block := Panel.new()
    block.position = pos
    block.size = block_size
    block.mouse_filter = Control.MOUSE_FILTER_IGNORE
    block.add_theme_stylebox_override("panel", _style(fill, fill.darkened(0.35), 1, radius))
    parent.add_child(block)

func _build_top_bar() -> void:
    var top := Panel.new()
    top.position = Vector2.ZERO
    top.size = Vector2(1280, 72)
    top.add_theme_stylebox_override("panel", _style(JADE_DARK, Color(0.06, 0.10, 0.08, 1.0), 3, 0))
    add_child(top)

    var name_label := _label(top, "TÔNG MÔN BÁ ĐẠO", Vector2(22, 12), Vector2(280, 30), 22)
    name_label.add_theme_color_override("font_color", Color(0.94, 0.82, 0.47, 1.0))

    time_label = _label(top, "", Vector2(22, 42), Vector2(260, 22), 13)
    time_label.add_theme_color_override("font_color", Color(0.78, 0.83, 0.72, 1.0))

    var crest := _label(top, "TÔNG SƯ", Vector2(564, 13), Vector2(150, 42), 20)
    crest.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    crest.add_theme_color_override("font_color", PAPER_LIGHT)

    resource_label = _label(top, "", Vector2(735, 18), Vector2(525, 34), 15)
    resource_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    resource_label.add_theme_color_override("font_color", PAPER_LIGHT)

func _build_task_rail() -> void:
    # P3.6A: the old proof checklist is intentionally hidden from normal play.
    task_label = null


func _build_bottom_bar() -> void:
    var bottom := Panel.new()
    bottom.name = "PlayerBottomBar"
    bottom.position = Vector2(0, 642)
    bottom.size = Vector2(1280, 78)
    bottom.add_theme_stylebox_override("panel", _style(Color(0.88, 0.82, 0.66, 0.98), INK, 2, 0))
    add_child(bottom)

    var entries := [
        {"text":"Tông Môn", "x":425, "action":"home"},
        {"text":"Đệ Tử", "x":545, "action":"disciples"},
        {"text":"Kho", "x":665, "action":"warehouse"},
        {"text":"Thế Giới", "x":785, "action":"world"}
    ]
    for entry_value in entries:
        var entry: Dictionary = entry_value
        var button := Button.new()
        button.text = str(entry["text"])
        button.position = Vector2(float(entry["x"]), 14)
        button.size = Vector2(108, 50)
        button.add_theme_font_size_override("font_size", 15)
        button.add_theme_color_override("font_color", INK)
        button.add_theme_stylebox_override("normal", _style(PAPER_LIGHT, Color(0.35, 0.27, 0.18, 1.0), 2, 10))
        button.add_theme_stylebox_override("hover", _style(Color(0.97, 0.87, 0.62, 1.0), GOLD, 3, 10))
        button.pressed.connect(Callable(self, "_bottom_action").bind(str(entry["action"])))
        bottom.add_child(button)


func _bottom_action(action: String) -> void:
    match action:
        "home":
            _clear_popup()
        "disciples":
            var ids: Array = state.disciples.keys()
            ids.sort()
            if not ids.is_empty():
                _open_disciple(StringName(ids[0]))
        "warehouse":
            _open_building(SectMapPresentation.DEST_WAREHOUSE)
        "world":
            _open_building(SectMapPresentation.DEST_GATE)


func _spawn_all_disciples() -> void:
    var ids: Array = state.disciples.keys()
    ids.sort()
    for index in range(ids.size()):
        var disciple_id := StringName(ids[index])
        var disciple: DiscipleState = state.disciples[disciple_id]
        var destination := _initial_destination(disciple)
        actor_destinations[str(disciple_id)] = str(destination)

        var actor := VBoxContainer.new()
        actor.position = SectMapPresentation.position_for_destination(destination) + _actor_offset(index) - Vector2(30, 30)
        actor.size = Vector2(86, 78)
        actor.mouse_filter = Control.MOUSE_FILTER_PASS

        var portrait := Button.new()
        portrait.text = disciple.display_name.substr(0, 1)
        portrait.custom_minimum_size = Vector2(52, 52)
        portrait.tooltip_text = disciple.display_name
        portrait.add_theme_font_size_override("font_size", 20)
        portrait.add_theme_color_override("font_color", PAPER_LIGHT)
        portrait.add_theme_stylebox_override("normal", _style(JADE, INK, 2, 26))
        portrait.add_theme_stylebox_override("hover", _style(JADE.lightened(0.10), GOLD, 3, 26))
        portrait.pressed.connect(Callable(self, "_open_disciple").bind(disciple_id))
        actor.add_child(portrait)

        var status := Label.new()
        status.text = SectMapPresentation.action_label(disciple.current_action)
        status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        status.add_theme_font_size_override("font_size", 10)
        status.add_theme_color_override("font_color", INK)
        actor.add_child(status)

        map_layer.add_child(actor)
        actor_nodes[str(disciple_id)] = actor
        actor_status_labels[str(disciple_id)] = status

func _initial_destination(disciple: DiscipleState) -> StringName:
    if disciple.work_group_id == &"mining_crew":
        return SectMapPresentation.DEST_MINE
    if disciple.work_group_id == &"forge_hall":
        return SectMapPresentation.DEST_FORGE
    if disciple.work_group_id == &"body_training_crew":
        return SectMapPresentation.DEST_BODY_TRAINING
    return SectMapPresentation.DEST_COURTYARD

func _advance_simulation() -> void:
    if not runtime_ready or runtime_session == null:
        return
    var result := runtime_session.poll()
    if not bool(result.get("ok", false)):
        push_error("P3 live runtime poll failed: %s" % str(result.get("reason", "unknown")))
        return
    if int(result.get("steps_run", 0)) > 0:
        _refresh_all()

func _autosave_runtime() -> void:
    if not runtime_ready or runtime_session == null:
        return
    var result := runtime_session.save()
    if not bool(result.get("ok", false)):
        push_error("P3 live runtime autosave failed: %s" % str(result.get("reason", result.get("error", "unknown"))))

func _exit_tree() -> void:
    if runtime_ready and runtime_session != null:
        var result := runtime_session.save()
        if not bool(result.get("ok", false)):
            push_error("P3 live runtime exit save failed: %s" % str(result.get("reason", result.get("error", "unknown"))))

func _notification(what: int) -> void:
    if not runtime_ready or runtime_session == null:
        return
    if what == NOTIFICATION_APPLICATION_PAUSED:
        _autosave_runtime()
    elif what == NOTIFICATION_APPLICATION_RESUMED:
        _advance_simulation()

func _refresh_all() -> void:
    _observe_tasks()
    _refresh_top_bar()
    _refresh_tasks()
    _sync_actor_positions()

func _observe_tasks() -> void:
    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        if disciple.current_action in [&"WORK_MINING", &"WORK_FORGING"]:
            saw_work = true
        if disciple.current_action in [&"CULTIVATE", &"BREAKTHROUGH"]:
            saw_cultivation = true

# Read-only P3.7 UI projection. Legacy fields are consulted only on old/P2 states.
func _warehouse_quantity(resource_id: StringName, legacy_technique: bool = false) -> int:
    if state.sect.p3_7_resources_enabled:
        return warehouse_ui.quantity(state, resource_id)
    var legacy: Dictionary = state.sect.technique_materials if legacy_technique else state.sect.forge_materials
    return maxi(int(legacy.get(str(resource_id), 0)), 0)

func _warehouse_available(resource_id: StringName, legacy_technique: bool = false) -> int:
    if state.sect.p3_7_resources_enabled:
        return warehouse_ui.available_quantity(state, resource_id)
    return _warehouse_quantity(resource_id, legacy_technique)

func _warehouse_pair(resource_id: StringName, legacy_technique: bool = false) -> String:
    return "%d (dùng %d)" % [
        _warehouse_quantity(resource_id, legacy_technique),
        _warehouse_available(resource_id, legacy_technique)
    ]

func _refresh_top_bar() -> void:
    time_label.text = "Năm đầu · Nhịp vận hành %d" % state.tick
    # Compact total/usable pairs; see Warehouse for the full stock/reserve legend.
    resource_label.text = "Tiền %s ◆ Linh thạch %s ▣ Thiết %s/%s ◉ Đan %s/%s ✦ Tủy %s/%s" % [
        _compact_number(state.sect.treasury),
        _compact_number(state.sect.spirit_stones),
        _compact_number(_warehouse_quantity(&"thanh_thiet")),
        _compact_number(_warehouse_available(&"thanh_thiet")),
        _compact_number(_warehouse_quantity(&"yeu_dan", true)),
        _compact_number(_warehouse_available(&"yeu_dan", true)),
        _compact_number(_warehouse_quantity(&"linh_tuy", true)),
        _compact_number(_warehouse_available(&"linh_tuy", true))
    ]

func _refresh_tasks() -> void:
    if task_label != null:
        task_label.text = _task_text()

func _task_text() -> String:
    var has_iron := _warehouse_quantity(&"thanh_thiet") > 0
    return "%s Quan sát đệ tử làm việc\n\n%s Có Thanh Thiết trong kho\n\n%s Quan sát đệ tử tu luyện\n\n%s Mở hồ sơ một đệ tử" % [
        _check(saw_work),
        _check(has_iron),
        _check(saw_cultivation),
        _check(opened_disciple_profile)
    ]

func _sync_actor_positions() -> void:
    var ids: Array = state.disciples.keys()
    ids.sort()
    for index in range(ids.size()):
        var disciple_id := StringName(ids[index])
        if not actor_nodes.has(str(disciple_id)):
            continue
        var disciple: DiscipleState = state.disciples[disciple_id]
        var previous := StringName(actor_destinations.get(str(disciple_id), str(SectMapPresentation.DEST_COURTYARD)))
        var destination := SectMapPresentation.destination_for_action(disciple.current_action, previous)
        actor_destinations[str(disciple_id)] = str(destination)
        var target := SectMapPresentation.position_for_destination(destination) + _actor_offset(index) - Vector2(30, 30)
        var actor: Control = actor_nodes[str(disciple_id)]
        if actor.position.distance_to(target) > 1.0:
            var tween := create_tween()
            tween.set_trans(Tween.TRANS_QUAD)
            tween.set_ease(Tween.EASE_IN_OUT)
            tween.tween_property(actor, "position", target, 0.32)
        var status: Label = actor_status_labels[str(disciple_id)]
        status.text = SectMapPresentation.action_label(disciple.current_action)

func _open_building(destination: StringName) -> void:
    _clear_popup()
    _add_dim()
    var panel := Panel.new()
    panel.position = Vector2(390, 150)
    panel.size = Vector2(520, 390)
    panel.add_theme_stylebox_override("panel", _style(PAPER_LIGHT, INK, 3, 18))
    popup_layer.add_child(panel)

    var title := _label(panel, _building_name(destination), Vector2(24, 18), Vector2(390, 34), 23)
    title.add_theme_color_override("font_color", CINNABAR.darkened(0.18))

    var detail := _label(panel, _building_detail(destination), Vector2(26, 68), Vector2(468, 245), 15)
    detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail.add_theme_color_override("font_color", INK)

    var close := Button.new()
    close.text = "Đóng"
    close.position = Vector2(378, 326)
    close.size = Vector2(112, 42)
    close.add_theme_stylebox_override("normal", _style(CINNABAR, PAPER_LIGHT, 2, 9))
    close.pressed.connect(_clear_popup)
    panel.add_child(close)

func _building_name(destination: StringName) -> String:
    match destination:
        SectMapPresentation.DEST_MAIN_HALL: return "Tông Môn Đại Điện"
        SectMapPresentation.DEST_RESIDENCE: return "Đệ Tử Xá"
        SectMapPresentation.DEST_CULTIVATION: return "Tu Luyện Đài"
        SectMapPresentation.DEST_BODY_TRAINING: return "Rèn Thân Đường"
        SectMapPresentation.DEST_WAREHOUSE: return "Kho Tông Môn"
        SectMapPresentation.DEST_FORGE: return "Luyện Khí Đường"
        SectMapPresentation.DEST_MEDICINE: return "Dược Phòng"
        SectMapPresentation.DEST_MINE: return "Khu Khai Khoáng"
        SectMapPresentation.DEST_LINH_FOREST: return "Linh Lâm"
        SectMapPresentation.DEST_ALCHEMY_HALL: return "Luyện Đan Điện"
        SectMapPresentation.DEST_SPIRIT_FIELD: return "Linh Điền"
        SectMapPresentation.DEST_GUIDANCE: return "Dẫn Tiên Đài"
        SectMapPresentation.DEST_GATE: return "Tông Môn Đại Môn"
        _: return "Sân Tông Môn"

func _building_detail(destination: StringName) -> String:
    match destination:
        SectMapPresentation.DEST_MAIN_HALL:
            return "Đệ tử: %d/%d\nChính sách lao động: %s\nNgân khố: %d\n\nTrung tâm điều hành các chính sách của tông môn." % [state.disciples.size(), state.sect.disciple_capacity, str(state.sect.work_policy), state.sect.treasury]
        SectMapPresentation.DEST_WAREHOUSE:
            return "TỒN KHO (số tồn / có thể dùng)\nThanh Thiết: %s\nLinh Mộc: %s\nYêu Đan: %s\nLinh Tủy: %s\nLinh Thạch: %d\n\nDự trữ và khóa không được phép tiêu dùng." % [
                _warehouse_pair(&"thanh_thiet"),
                _warehouse_pair(&"linh_moc"),
                _warehouse_pair(&"yeu_dan", true),
                _warehouse_pair(&"linh_tuy", true),
                state.sect.spirit_stones
            ]
        SectMapPresentation.DEST_FORGE:
            return "Đệ tử đang luyện khí: %d\nĐiểm hỗ trợ rèn: %d\nThanh Thiết tồn (dùng): %s\n\nNgười phụ trách luyện khí sẽ làm việc tại đây." % [_count_action(&"WORK_FORGING"), state.sect.forge_support_points, _warehouse_pair(&"thanh_thiet")]
        SectMapPresentation.DEST_MINE:
            return "Đệ tử đang khai khoáng: %d\nThanh Thiết tồn (dùng): %s\n\nMỗi chu kỳ khai khoáng hoàn thành sẽ đưa Thanh Thiết về kho." % [_count_action(&"WORK_MINING"), _warehouse_pair(&"thanh_thiet")]
        SectMapPresentation.DEST_LINH_FOREST:
            var forest := BuildingSystem.new().primary_building(state, BuildingSystem.TYPE_LINH_FOREST)
            if forest == null:
                return "Linh Lâm chưa sẵn sàng."
            return "Cấp: %d\nĐệ tử hoạt động: %d/%d\nLinh Mộc tồn (dùng): %s\n\nChu kỳ thật: đi tới Linh Lâm → thu hoạch → vận chuyển Linh Mộc về Kho." % [
                forest.level,
                BuildingSystem.new().active_worker_ids(state, forest).size(),
                BuildingSystem.new().worker_slots(forest),
                _warehouse_pair(&"linh_moc")
            ]
        SectMapPresentation.DEST_ALCHEMY_HALL:
            var hall := BuildingSystem.new().primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
            if hall == null:
                return "Luyện Đan Điện chưa sẵn sàng."
            var jobs := BuildingSystem.new().alchemy_jobs(state, hall)
            return "Cấp: %d\nĐệ tử hoạt động: %d/%d\nMẻ đang luyện: %d\nThanh Linh Thảo: %s\nHồi Xuân Đan: %s\n\nNguyên liệu commit đúng một lần khi bắt đầu; thành phẩm chỉ vào Kho khi đủ thời gian." % [
                hall.level,
                BuildingSystem.new().active_worker_ids(state, hall).size(),
                BuildingSystem.new().worker_slots(hall),
                jobs.size(),
                _warehouse_pair(&"thanh_linh_thao", true),
                _warehouse_pair(&"hoi_xuan_dan", true)
            ]
        SectMapPresentation.DEST_SPIRIT_FIELD:
            var field := BuildingSystem.new().primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
            if field == null:
                return "Linh Điền chưa sẵn sàng."
            var plots := BuildingSystem.new().spirit_field_plots(state, field)
            var growing := 0
            for raw_plot in plots:
                if raw_plot is Dictionary and StringName(raw_plot.get("status", "")) == BuildingSystem.PLOT_GROWING:
                    growing += 1
            return "Cấp: %d\nÔ đang trồng: %d/%d\nĐệ tử hoạt động: %d/%d\nLinh Thạch: %d\nThanh Linh Thảo: %s\nLinh Cốc: %s\n\nMỗi ô trừ phí đúng một lần khi bắt đầu và tự thu hoạch vào Kho khi đủ thời gian." % [
                field.level, growing, plots.size(),
                BuildingSystem.new().active_worker_ids(state, field).size(), BuildingSystem.new().worker_slots(field),
                state.sect.spirit_stones,
                _warehouse_pair(&"thanh_linh_thao", true),
                _warehouse_pair(&"linh_coc", true)
            ]
        SectMapPresentation.DEST_GUIDANCE:
            return "Ứng viên đang chờ: %d\nĐệ tử: %d/%d\nChiêu Mộ Lệnh: %d\n\nDẫn Tiên Đài tiếp nhận và sàng lọc ứng viên bằng hệ tuyển mộ hiện có." % [state.recruitment_candidates.size(), state.disciples.size(), state.sect.disciple_capacity, state.sect.disciple_recruitment_tokens]
        SectMapPresentation.DEST_BODY_TRAINING:
            var hall := BuildingSystem.new().primary_building(state, BuildingSystem.TYPE_BODY_TRAINING)
            if hall == null:
                return "Rèn Thân Đường chưa sẵn sàng."
            var owners := BuildingSystem.new().active_worker_ids(state, hall)
            return "Cấp: %d\nChỗ luyện: %d/%d\nLinh Thạch: %d\nMỗi phút: 1 Linh Thạch → 1.500 EXP Luyện Thể nền.\nKhông cấp EXP nếu chưa có lượt huấn luyện thật." % [hall.level, owners.size(), BuildingSystem.new().worker_slots(hall), state.sect.spirit_stones]
        SectMapPresentation.DEST_CULTIVATION:
            return "Đang tu luyện/phá cảnh: %d\n\nĐệ tử tới đây để tu luyện và chuẩn bị phá cảnh khi đủ điều kiện." % [_count_actions([&"CULTIVATE", &"BREAKTHROUGH"])]
        SectMapPresentation.DEST_RESIDENCE:
            return "Đệ tử đang nghỉ: %d\nSức chứa chỗ ở: %d\n\nNghỉ ngơi giúp hồi thể lực và một phần thương thế." % [_count_action(&"REST"), state.sect.lodging_capacity]
        SectMapPresentation.DEST_MEDICINE:
            return "Đệ tử đang trị thương: %d\nThuốc hậu cần: %d\nHồi Xuân Đan: %s\n\nDược Phòng có thể dùng Hồi Xuân Đan canonical mà không tiêu thuốc hậu cần." % [_count_action(&"HEAL"), state.sect.medicine_stock, _warehouse_pair(&"hoi_xuan_dan", true)]
        SectMapPresentation.DEST_GATE:
            return "Đệ tử ngoài tông: %d\nĐang săn/di chuyển/chiến đấu: %d\n\nĐại Môn là nơi theo dõi người đang xuất môn và triệu hồi họ khi cần." % [_count_outside(), _count_actions([&"HUNT", &"TRAVEL", &"COMBAT", &"LOOT", &"RETURN_SECT"])]
        _:
            return "Sân trung tâm — nơi avatar giữ vị trí khi chờ lệnh."

func _open_disciple(disciple_id: StringName) -> void:
    if not state.disciples.has(disciple_id):
        return
    selected_id = disciple_id
    opened_disciple_profile = true
    _refresh_tasks()
    _clear_popup()
    _add_dim()

    var panel := Panel.new()
    panel.position = Vector2(110, 82)
    panel.size = Vector2(1060, 548)
    panel.add_theme_stylebox_override("panel", _style(PAPER_LIGHT, INK, 3, 18))
    popup_layer.add_child(panel)

    var header := _label(panel, "Đệ Tử", Vector2(20, 12), Vector2(140, 36), 24)
    header.add_theme_color_override("font_color", CINNABAR.darkened(0.18))

    var close := Button.new()
    close.text = "×"
    close.position = Vector2(1008, 12)
    close.size = Vector2(36, 34)
    close.add_theme_font_size_override("font_size", 22)
    close.add_theme_stylebox_override("normal", _style(Color(0.76, 0.70, 0.58, 1.0), INK, 1, 16))
    close.pressed.connect(_clear_popup)
    panel.add_child(close)

    var roster_panel := Panel.new()
    roster_panel.position = Vector2(18, 54)
    roster_panel.size = Vector2(185, 430)
    roster_panel.add_theme_stylebox_override("panel", _style(Color(0.86, 0.80, 0.66, 1.0), Color(0.40, 0.31, 0.20, 1.0), 2, 10))
    panel.add_child(roster_panel)

    var scroll := ScrollContainer.new()
    scroll.position = Vector2(8, 8)
    scroll.size = Vector2(169, 414)
    roster_panel.add_child(scroll)
    var roster := VBoxContainer.new()
    roster.custom_minimum_size = Vector2(150, 0)
    roster.add_theme_constant_override("separation", 6)
    scroll.add_child(roster)

    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var id := StringName(raw_id)
        var disciple: DiscipleState = state.disciples[id]
        var entry := Button.new()
        entry.text = disciple.display_name
        entry.custom_minimum_size = Vector2(148, 44)
        entry.add_theme_font_size_override("font_size", 13)
        var selected := id == selected_id
        entry.add_theme_stylebox_override("normal", _style(Color(0.97, 0.90, 0.70, 1.0) if selected else Color(0.91, 0.86, 0.72, 1.0), GOLD if selected else Color(0.45, 0.37, 0.25, 1.0), 2, 8))
        entry.pressed.connect(Callable(self, "_open_disciple").bind(id))
        roster.add_child(entry)

    var disciple: DiscipleState = state.disciples[selected_id]
    var portrait_panel := Panel.new()
    portrait_panel.position = Vector2(226, 66)
    portrait_panel.size = Vector2(300, 350)
    portrait_panel.add_theme_stylebox_override("panel", _style(Color(0.76, 0.84, 0.72, 1.0), Color(0.31, 0.40, 0.28, 1.0), 2, 120))
    panel.add_child(portrait_panel)
    var initial := _label(portrait_panel, disciple.display_name.substr(0, 1), Vector2(70, 74), Vector2(160, 170), 90)
    initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    initial.add_theme_color_override("font_color", JADE_DARK)
    var name := _label(panel, disciple.display_name, Vector2(228, 426), Vector2(296, 34), 23)
    name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    name.add_theme_color_override("font_color", INK)
    var stage := _label(panel, cultivation.stage_name(disciple), Vector2(228, 462), Vector2(296, 24), 14)
    stage.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    stage.add_theme_color_override("font_color", CINNABAR)

    var detail := _label(panel, _disciple_detail(disciple), Vector2(550, 62), Vector2(482, 330), 14)
    detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail.add_theme_color_override("font_color", INK)

    _add_quick_order_button(panel, "Tu luyện", Vector2(552, 405), WorkforceSystem.COMMAND_CULTIVATE)
    _add_quick_order_button(panel, "Khai khoáng", Vector2(652, 405), WorkforceSystem.COMMAND_WORK, str(WorkforceSystem.PROF_MINING))
    _add_quick_order_button(panel, "Luyện khí", Vector2(770, 405), WorkforceSystem.COMMAND_WORK, str(WorkforceSystem.PROF_FORGING))
    _add_quick_order_button(panel, "Nghỉ", Vector2(872, 405), WorkforceSystem.COMMAND_REST)
    _add_quick_order_button(panel, "Về tông", Vector2(952, 405), WorkforceSystem.COMMAND_RETURN_SECT)

    var tab_names := ["Thuộc tính", "Công pháp", "Trang bị", "Huyết Mạch", "Thể Chất", "Quan hệ"]
    for index in range(tab_names.size()):
        var tab := Button.new()
        tab.text = tab_names[index]
        tab.position = Vector2(225 + index * 128, 500)
        tab.size = Vector2(118, 36)
        tab.add_theme_font_size_override("font_size", 12)
        tab.add_theme_stylebox_override("normal", _style(Color(0.88, 0.82, 0.67, 1.0), Color(0.45, 0.37, 0.25, 1.0), 1, 6))
        tab.pressed.connect(Callable(self, "_tab_notice").bind(tab_names[index]))
        panel.add_child(tab)

func _disciple_detail(disciple: DiscipleState) -> String:
    var quality := "—"
    if disciple.disciple_quality != &"":
        quality = generator.quality_name(disciple.disciple_quality)

    var roots := "—"
    if not disciple.spiritual_root_elements.is_empty():
        var parts: Array[String] = []
        for element in disciple.spiritual_root_elements:
            parts.append(_element_name(str(element)))
        roots = "-".join(parts) + " · %.0f%%" % (disciple.spiritual_root_purity * 100.0)

    var bloodline_text := "—"
    var bloodline_profile := bloodlines.profile_for(state, disciple.id)
    if not bloodline_profile.is_empty():
        if bool(bloodline_profile.get("revealed", false)):
            var bid := StringName(bloodline_profile.get("bloodline_id", "none"))
            bloodline_text = "%s · %.0f%%" % [bloodlines.bloodline_name(bid), float(bloodline_profile.get("purity", 0.0)) * 100.0]
            if bool(bloodline_profile.get("awakened", false)):
                bloodline_text += " · Đã thức tỉnh"
        else:
            bloodline_text = "Chưa xác định"

    var physique_text := "—"
    var physique_profile := physiques.profile_for(state, disciple.id)
    if not physique_profile.is_empty():
        physique_text = physiques.display_physique(state, disciple.id)
        physique_text += " · Tôi thể %d/%d" % [physiques.temper_level(state, disciple.id), PhysiqueSystem.MAX_TEMPER_LEVEL]

    var command_text := _player_command_text(disciple)

    return "Phẩm chất: %s\nCảnh giới: %s\nHP: %.0f/%.0f    Thể lực: %.0f/100\n\nLinh căn: %s\nHuyết mạch: %s\nThể chất: %s\n\nTư Chất: %s    Căn Cốt: %s\nCơ Duyên: %s    Thông Tuệ: %s\nMị Lực: %s    Tiềm Lực: %s\n\nĐang làm: %s\nNhóm việc: %s\nLệnh Tông Chủ: %s" % [
        quality,
        cultivation.stage_name(disciple),
        disciple.hp,
        disciple.max_hp,
        disciple.stamina,
        roots,
        bloodline_text,
        physique_text,
        _score(disciple.aptitude),
        _score(disciple.constitution),
        _score(disciple.fortune),
        _score(disciple.comprehension),
        _score(disciple.charisma),
        _score(disciple.potential),
        SectMapPresentation.action_label(disciple.current_action),
        str(disciple.work_group_id) if disciple.work_group_id != &"" else "—",
        command_text
    ]

func _player_command_text(disciple: DiscipleState) -> String:
    if disciple.direct_command.is_empty():
        return "Không"
    var kind := StringName(disciple.direct_command.get("kind", ""))
    var target := StringName(disciple.direct_command.get("target", ""))
    match kind:
        WorkforceSystem.COMMAND_CULTIVATE: return "Tu luyện"
        WorkforceSystem.COMMAND_REST: return "Nghỉ"
        WorkforceSystem.COMMAND_RETURN_SECT: return "Về tông"
        WorkforceSystem.COMMAND_HOLD: return "Ở lại tông"
        WorkforceSystem.COMMAND_WORK:
            if target == WorkforceSystem.PROF_MINING:
                return "Khai khoáng"
            if target == WorkforceSystem.PROF_FORGING:
                return "Luyện khí"
            return "Làm việc"
        WorkforceSystem.COMMAND_HUNT_REGION: return "Xuất môn"
        _: return "Đang chờ thực hiện"

func _add_quick_order_button(parent: Control, text: String, pos: Vector2, kind: StringName, target: String = "") -> void:
    var button := Button.new()
    button.text = text
    button.position = pos
    button.size = Vector2(94 if text != "Khai khoáng" else 112, 40)
    button.add_theme_font_size_override("font_size", 12)
    button.add_theme_stylebox_override("normal", _style(CINNABAR, PAPER_LIGHT, 2, 8))
    button.add_theme_stylebox_override("hover", _style(CINNABAR.lightened(0.08), GOLD, 3, 8))
    button.pressed.connect(Callable(self, "_issue_order").bind(kind, target))
    parent.add_child(button)

func _issue_order(kind: StringName, target: String) -> void:
    if selected_id == &"":
        return
    workforce.issue_command(state, selected_id, kind, target, 40)
    _open_disciple(selected_id)

func _tab_notice(tab_name: String) -> void:
    _open_notice(tab_name, "Mục này chưa có nội dung quản lý riêng.")

func _open_notice(title_text: String, body: String) -> void:
    _clear_popup()
    _add_dim()
    var panel := Panel.new()
    panel.position = Vector2(420, 205)
    panel.size = Vector2(440, 280)
    panel.add_theme_stylebox_override("panel", _style(PAPER_LIGHT, INK, 3, 18))
    popup_layer.add_child(panel)
    var title := _label(panel, title_text, Vector2(22, 18), Vector2(300, 34), 22)
    title.add_theme_color_override("font_color", CINNABAR.darkened(0.18))
    var text := _label(panel, body, Vector2(24, 68), Vector2(392, 145), 14)
    text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    var close := Button.new()
    close.text = "Đóng"
    close.position = Vector2(302, 222)
    close.size = Vector2(112, 38)
    close.add_theme_stylebox_override("normal", _style(CINNABAR, PAPER_LIGHT, 2, 8))
    close.pressed.connect(_clear_popup)
    panel.add_child(close)

func _add_dim() -> void:
    var dim := ColorRect.new()
    dim.color = Color(0.04, 0.05, 0.04, 0.50)
    dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    dim.mouse_filter = Control.MOUSE_FILTER_STOP
    popup_layer.add_child(dim)

func _clear_popup() -> void:
    if popup_layer == null:
        return
    for child in popup_layer.get_children():
        popup_layer.remove_child(child)
        child.queue_free()

func _count_action(action: StringName) -> int:
    var count := 0
    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        if disciple.current_action == action:
            count += 1
    return count

func _count_actions(actions: Array) -> int:
    var count := 0
    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        if actions.has(disciple.current_action):
            count += 1
    return count

func _count_outside() -> int:
    var count := 0
    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        if disciple.region_id != &"sect":
            count += 1
    return count

func _actor_offset(index: int) -> Vector2:
    var offsets: Array[Vector2] = [
        Vector2(-64.0, 10.0),
        Vector2(64.0, 10.0),
        Vector2(0.0, -48.0),
        Vector2(-64.0, -48.0),
        Vector2(64.0, -48.0),
        Vector2(-32.0, 54.0),
        Vector2(32.0, 54.0),
        Vector2(-92.0, 28.0),
        Vector2(92.0, 28.0)
    ]
    return offsets[index % offsets.size()]

func _element_name(element: String) -> String:
    match element:
        "metal": return "Kim"
        "wood": return "Mộc"
        "water": return "Thủy"
        "fire": return "Hỏa"
        "earth": return "Thổ"
        _: return element

func _score(value: float) -> String:
    if value <= 0.0:
        return "—"
    return "%d" % int(round(value * 100.0))

func _check(ok: bool) -> String:
    return "✓" if ok else "□"

func _compact_number(value: int) -> String:
    if abs(value) >= 1000000:
        return "%.1fTr" % (float(value) / 1000000.0)
    if abs(value) >= 1000:
        return "%.1fK" % (float(value) / 1000.0)
    return str(value)

func _label(parent: Control, text: String, pos: Vector2, label_size: Vector2, font_size: int) -> Label:
    var label := Label.new()
    label.text = text
    label.position = pos
    label.size = label_size
    label.add_theme_font_size_override("font_size", font_size)
    parent.add_child(label)
    return label

func _style(fill: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = fill
    style.border_color = border
    style.border_width_left = border_width
    style.border_width_top = border_width
    style.border_width_right = border_width
    style.border_width_bottom = border_width
    style.corner_radius_top_left = radius
    style.corner_radius_top_right = radius
    style.corner_radius_bottom_left = radius
    style.corner_radius_bottom_right = radius
    style.content_margin_left = 8.0
    style.content_margin_right = 8.0
    style.content_margin_top = 6.0
    style.content_margin_bottom = 6.0
    return style
