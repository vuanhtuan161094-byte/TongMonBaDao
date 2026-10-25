class_name PveWorldTopologyPreviewV1
extends Control

# DESIGN-ONLY prototype of the separately proposed Thanh Trúc Lâm world.
# 20 proposed camp nodes, not 20 live encounters. Numbers shown are planned
# populations, NOT spawned monsters. No CARE, combat, loot or save authority.
# 256x192 is design-space for THIS world, not sect MAP25 geometry.
const WORLD_CELLS := Vector2(256,192)
const VIEWPORT_SIZE := Vector2(1280,720)
const MAP_PANEL := Rect2(Vector2(24,82),Vector2(951,603))
const COLUMN_CELLS := [28,76,124,172,220]
const ROW_CELLS := [24,64,104,144]
const CAMP_COUNTS := [
    10,11,12,13,14,15,16,17,18,19,
    20,19,18,17,16,15,14,13,12,11
]
const BOOTSTRAP_GATE := Vector2(12,96)
const RIVER_X := 148.0
const BRIDGE_ROWS := [0,2,3] # No bridge C08 -> C09 at y=64.
const TREE_A: Texture2D = preload("res://art/source_a_env02a/env01_assets/vegetation/570036.png")
const TREE_B: Texture2D = preload("res://art/source_a_env02a/env01_assets/vegetation/570041.png")
const TREE_C: Texture2D = preload("res://art/source_a_env02a/env01_assets/vegetation/570073.png")
const PREVIEW_TREES := [
    Vector2(14,23),Vector2(46,14),Vector2(95,10),Vector2(143,12),
    Vector2(244,29),Vector2(14,47),Vector2(53,84),Vector2(103,52),
    Vector2(202,43),Vector2(244,82),Vector2(11,139),Vector2(48,174),
    Vector2(112,171),Vector2(173,166),Vector2(244,163)
]
const BG := Color(0.15,0.27,0.23,1.0)
const TEXT := Color(0.91,0.88,0.74,1.0)
const ACCENT := Color(0.88,0.71,0.41,1.0)

var camera_pan := Vector2.ZERO
var camera_zoom := 1.0
var selected_camp := -1
var is_dragging := false
var drag_start := Vector2.ZERO
var drag_sum := Vector2.ZERO


func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    custom_minimum_size = VIEWPORT_SIZE
    queue_redraw()


static func camp_index(column: int, row: int) -> int:
    return row*5+column


static func camp_id(index: int) -> String:
    return "C%02d" % (index+1)


static func camp_cell(index: int) -> Vector2:
    if index < 0 or index >= 20:
        return Vector2(-1,-1)
    return Vector2(COLUMN_CELLS[index%5],ROW_CELLS[index/5])


static func design_edges() -> Array[Vector2i]:
    var edges: Array[Vector2i] = []
    for row in range(4):
        for col in range(5):
            var i := camp_index(col,row)
            if col < 4 and not (row == 1 and col == 2):
                # C08/C09 crossing intentionally disconnected at y=64.
                edges.append(Vector2i(i,i+1))
            if row < 3:
                edges.append(Vector2i(i,i+5))
    return edges


static func design_population() -> int:
    var total := 0
    for count in CAMP_COUNTS:
        total += count
    return total


static func design_graph_connected() -> bool:
    var queue: Array[int] = [0]
    var visited := {0:true}
    var links := design_edges()
    while not queue.is_empty():
        var current := queue.pop_front()
        for link in links:
            var other := -1
            if link.x == current:
                other = link.y
            elif link.y == current:
                other = link.x
            if other >= 0 and not visited.has(other):
                visited[other] = true
                queue.append(other)
    return visited.size() == 20


func _scale() -> float:
    return minf((MAP_PANEL.size.x-36.0)/WORLD_CELLS.x,
        (MAP_PANEL.size.y-24.0)/WORLD_CELLS.y)*camera_zoom


func cell_to_screen(cell: Vector2) -> Vector2:
    return MAP_PANEL.get_center()+camera_pan+(cell-WORLD_CELLS*0.5)*_scale()


func screen_to_cell(screen: Vector2) -> Vector2:
    return ((screen-MAP_PANEL.get_center()-camera_pan)/_scale())+WORLD_CELLS*0.5


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        var mouse := event as InputEventMouseButton
        if not MAP_PANEL.has_point(mouse.position):
            return
        if mouse.button_index == MOUSE_BUTTON_WHEEL_UP and mouse.pressed:
            _zoom_at(mouse.position,1.12)
            accept_event()
        elif mouse.button_index == MOUSE_BUTTON_WHEEL_DOWN and mouse.pressed:
            _zoom_at(mouse.position,1.0/1.12)
            accept_event()
        elif mouse.button_index == MOUSE_BUTTON_LEFT:
            if mouse.pressed:
                is_dragging = true
                drag_start = mouse.position
                drag_sum = Vector2.ZERO
            else:
                if is_dragging and drag_sum.length_squared() < 64.0:
                    select_at(mouse.position)
                is_dragging = false
            accept_event()
    elif event is InputEventMouseMotion and is_dragging:
        var motion := event as InputEventMouseMotion
        camera_pan += motion.relative
        drag_sum += motion.relative
        _clamp_pan()
        queue_redraw()
        accept_event()
    elif event is InputEventScreenDrag:
        var drag := event as InputEventScreenDrag
        if MAP_PANEL.has_point(drag.position):
            camera_pan += drag.relative
            _clamp_pan()
            queue_redraw()
            accept_event()
    elif event is InputEventScreenTouch:
        var touch := event as InputEventScreenTouch
        if not touch.pressed and MAP_PANEL.has_point(touch.position):
            select_at(touch.position)
            accept_event()


func _zoom_at(screen: Vector2, factor: float) -> void:
    var before := screen_to_cell(screen)
    camera_zoom = clampf(camera_zoom*factor,0.70,2.30)
    camera_pan += screen-cell_to_screen(before)
    _clamp_pan()
    queue_redraw()


func _clamp_pan() -> void:
    # Keep some geography always within the map frame, without asserting a
    # new world boundary/collision rule for the future hunting simulation.
    var slack := MAP_PANEL.size*0.60
    camera_pan = camera_pan.clamp(-slack,slack)


func select_at(screen: Vector2) -> int:
    var best := -1
    var nearest := 18.0*18.0
    for i in range(20):
        var distance := cell_to_screen(camp_cell(i)).distance_squared_to(screen)
        if distance < nearest:
            nearest = distance
            best = i
    selected_camp = best
    queue_redraw()
    return best


func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO,VIEWPORT_SIZE),BG)
    draw_rect(Rect2(Vector2(0,0),Vector2(1280,70)),Color(0.09,0.21,0.18))
    _text(Vector2(25,30),"THANH TRÚC LÂM  /  BẢN ĐỒ PvE — QUY HOẠCH",24,ACCENT)
    _text(Vector2(26,57),"NGUYÊN MẪU ĐỒ HỌA • 20 bãi dự kiến • không phải world combat đang chạy",15,TEXT)
    draw_rect(MAP_PANEL,Color(0.31,0.46,0.34))
    _draw_biome_and_terrain()
    _draw_river()
    _draw_routes()
    _draw_trees()
    _draw_camps()
    _draw_sidebar()
    draw_rect(Rect2(Vector2(24,690),Vector2(1210,20)),Color(0.12,0.25,0.22))
    _text(Vector2(32,706),"Kéo: di chuyển bản đồ   •   Cuộn: zoom   •   Bấm bãi: xem quy hoạch   •   Không có quái/loot thật ở scene này",12,TEXT)


func _draw_biome_and_terrain() -> void:
    # Muted broad brush patches. Static scenery only; all drawn features
    # remain deliberately free of collision and simulation-side resources.
    for row in range(4):
        for col in range(5):
            var center := cell_to_screen(Vector2(COLUMN_CELLS[col],ROW_CELLS[row]))
            var scale := _scale()
            var width := Vector2(35.0*scale,22.0*scale)
            if not MAP_PANEL.grow(80).has_point(center):
                continue
            var tone := Color(0.26,0.39,0.30,0.32) if col <= 1 else (
                Color(0.37,0.43,0.34,0.35) if col == 2 else Color(0.37,0.40,0.31,0.34))
            if row == 3:
                tone = tone.blend(Color(0.24,0.40,0.30,0.48))
            draw_set_transform(center,0.0,width)
            draw_circle(Vector2.ZERO,1.0,tone)
            draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
    var entrance := cell_to_screen(BOOTSTRAP_GATE)
    draw_circle(entrance,7.0,ACCENT)
    _text(entrance+Vector2(-1,22),"VÀO",13,ACCENT)


func _draw_river() -> void:
    var points := PackedVector2Array()
    for y in range(0,193,8):
        var shift := sin(float(y)*0.047)*3.8
        points.append(cell_to_screen(Vector2(RIVER_X+shift,float(y))))
    draw_polyline(points,Color(0.25,0.51,0.52,0.70),17.0*camera_zoom,true)
    draw_polyline(points,Color(0.54,0.74,0.68,0.45),3.0*camera_zoom,true)


func _draw_routes() -> void:
    # Road graph is the DESIGN topology. The no-bridge C08/C09 edge is not
    # drawn. These are not gameplay movement paths or AStar obstacles.
    for edge in design_edges():
        var a := cell_to_screen(camp_cell(edge.x))
        var b := cell_to_screen(camp_cell(edge.y))
        if edge.x/5 == edge.y/5 and edge.x%5 == 2 and edge.y%5 == 3:
            draw_line(a,b,Color(0.64,0.51,0.32,0.86),12.0*camera_zoom,true)
            draw_line(a,b,Color(0.84,0.74,0.53,0.92),5.0*camera_zoom,true)
        else:
            draw_line(a,b,Color(0.43,0.43,0.32,0.70),9.0*camera_zoom,true)
            draw_line(a,b,Color(0.72,0.64,0.48,0.61),3.0*camera_zoom,true)


func _draw_trees() -> void:
    var source := [TREE_A,TREE_B,TREE_C]
    for i in range(PREVIEW_TREES.size()):
        var at := cell_to_screen(PREVIEW_TREES[i])
        var tex: Texture2D = source[i%source.size()]
        if tex == null or not MAP_PANEL.grow(75).has_point(at):
            continue
        var height := 40.0*clampf(camera_zoom,0.7,2.3)
        var width := height*tex.get_width()/maxf(1.0,float(tex.get_height()))
        draw_texture_rect(tex,Rect2(at-Vector2(width*0.5,height),Vector2(width,height)),
            false,Color(0.95,0.98,0.89,0.88))


func _draw_camps() -> void:
    for index in range(20):
        var at := cell_to_screen(camp_cell(index))
        if not MAP_PANEL.grow(20).has_point(at):
            continue
        var chosen := index == selected_camp
        draw_circle(at,20.0*clampf(camera_zoom,0.75,1.5),
            Color(0.18,0.31,0.24,0.94))
        draw_arc(at,15.0*clampf(camera_zoom,0.75,1.5),0,TAU,36,
            ACCENT if chosen else Color(0.68,0.77,0.58,0.85),2.4,true)
        _text(at+Vector2(-14,5),camp_id(index),13,ACCENT if chosen else TEXT)


func _draw_sidebar() -> void:
    var panel := Rect2(Vector2(988,83),Vector2(266,600))
    draw_rect(panel,Color(0.12,0.24,0.20,0.96))
    _text(Vector2(1003,117),"TỔNG QUAN",20,ACCENT)
    _text(Vector2(1003,148),"1 thế giới / 20 bãi",15,TEXT)
    _text(Vector2(1003,178),"300 quái — số thiết kế",14,Color(0.88,0.73,0.57))
    _text(Vector2(1003,207),"30 đệ tử — mục tiêu",14,TEXT)
    _text(Vector2(1003,239),"3 cầu qua suối",14,TEXT)
    _text(Vector2(1003,269),"KHÔNG có spawn thật",13,Color(0.85,0.49,0.43))
    _text(Vector2(1003,296),"KHÔNG có Boss thật",13,Color(0.85,0.49,0.43))
    draw_line(Vector2(1003,318),Vector2(1233,318),Color(0.45,0.54,0.43,0.65))
    if selected_camp >= 0:
        _text(Vector2(1003,348),camp_id(selected_camp),21,ACCENT)
        _text(Vector2(1003,383),"Số dự kiến: %d" % CAMP_COUNTS[selected_camp],15,TEXT)
        var place := camp_cell(selected_camp)
        _text(Vector2(1003,414),"Tọa độ: %d, %d" % [int(place.x),int(place.y)],15,TEXT)
        _text(Vector2(1003,449),"Chưa duyệt spawn/AI",13,Color(0.88,0.73,0.57))
    else:
        _text(Vector2(1003,349),"Chọn một bãi C01–C20",15,TEXT)
    _text(Vector2(1003,526),"C08 ↔ C09: không có cầu",12,TEXT)
    _text(Vector2(1003,555),"Combat live: arena 36×20",12,TEXT)
    _text(Vector2(1003,584),"Thế giới này: 256×192",12,TEXT)
    _text(Vector2(1003,636),"DESIGN ONLY  /  NO LOOT",14,ACCENT)


func _text(pos: Vector2, value: String, font_size: int,
        tint: Color = TEXT) -> void:
    var font := ThemeDB.fallback_font
    if font != null:
        draw_string_outline(font,pos,value,HORIZONTAL_ALIGNMENT_LEFT,-1,
            font_size,2,Color(0.06,0.11,0.10,0.85))
        draw_string(font,pos,value,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,tint)
