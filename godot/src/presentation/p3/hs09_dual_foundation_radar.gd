class_name HS09DualFoundationRadar
extends Control

# Presentation-only view of the persisted seven-point foundation snapshot.
# The two groups share a center, but use separate drawing scales and colors.
const TAM_CAN_KEYS := ["aptitude","constitution","mind_nature"]
const TAM_CAN_NAMES := ["Tư Chất","Căn Cốt","Tâm Tính"]
const TU_TINH_KEYS := ["potential","comprehension","fortune","charisma"]
const TU_TINH_NAMES := ["Tiềm Lực","Thông Tuệ","Cơ Duyên","Mị Lực"]
const AMBER := Color(0.83,0.43,0.12,1.0)
const JADE := Color(0.13,0.48,0.36,1.0)
const GRID := Color(0.37,0.38,0.28,0.30)
const INK := Color(0.18,0.24,0.19,1.0)

var compact := false
var model_version := 0
var tam_can_values: Array[float] = []
var tu_tinh_values: Array[float] = []
var tam_can_ceiling := 1.0
var tu_tinh_ceiling := 1.0

func apply_snapshot(snapshot: Dictionary) -> bool:
    if not bool(snapshot.get("ok",false)):
        return false
    var foundations: Dictionary = snapshot.get("foundations",{})
    var next_model_version := int(foundations.get("model_version",0))
    if next_model_version < FoundationSystem.MODEL_D7:
        return false
    var current: Dictionary = foundations.get("current",{})
    var next_tam: Array[float] = []
    var next_tu: Array[float] = []
    var tam_max := 0.0
    var tu_max := 0.0
    for key in TAM_CAN_KEYS:
        if not current.has(key):
            return false
        var value := float(current[key])
        if is_nan(value) or is_inf(value) or value < 0.0:
            return false
        next_tam.append(value)
        tam_max = maxf(tam_max,value)
    for key in TU_TINH_KEYS:
        if not current.has(key):
            return false
        var value := float(current[key])
        if is_nan(value) or is_inf(value) or value < 0.0:
            return false
        next_tu.append(value)
        tu_max = maxf(tu_max,value)
    model_version = next_model_version
    tam_can_values = next_tam
    tu_tinh_values = next_tu
    tam_can_ceiling = _drawing_ceiling(tam_max)
    tu_tinh_ceiling = _drawing_ceiling(tu_max)
    tooltip_text = "Tam Căn và Tứ Tính dùng hai thang vẽ độc lập; điểm gốc không bị giới hạn hay thay đổi."
    queue_redraw()
    return true

static func _drawing_ceiling(maximum: float) -> float:
    if maximum <= 0.0:
        return 1.0
    var step := pow(10.0,floor(log(maximum)/log(10.0)))
    return maxf(ceil(maximum/step)*step,maximum)

func _axis_point(index: int, count: int, distance: float, start_angle: float, center: Vector2) -> Vector2:
    var angle := start_angle + TAU*float(index)/float(count)
    return center + Vector2(cos(angle),sin(angle))*distance

func _draw_group_grid(count: int, start_angle: float, center: Vector2, radius: float) -> void:
    for ring in [0.25,0.5,0.75,1.0]:
        var outline := PackedVector2Array()
        for index in range(count+1):
            outline.append(_axis_point(index % count,count,radius*ring,start_angle,center))
        draw_polyline(outline,GRID,1.0,true)
    for index in range(count):
        draw_line(center,_axis_point(index,count,radius,start_angle,center),GRID,1.0,true)

func _draw_group(values: Array[float], names: Array, ceiling: float, start_angle: float,
        color: Color, center: Vector2, radius: float, font: Font, font_size: int) -> void:
    var polygon := PackedVector2Array()
    var label_width := 72.0 if compact else 86.0
    for index in range(values.size()):
        var ratio := clampf(values[index]/maxf(ceiling,1.0),0.0,1.0)
        var point := _axis_point(index,values.size(),radius*ratio,start_angle,center)
        polygon.append(point)
    if polygon.size() < 3:
        return
    draw_colored_polygon(polygon,Color(color.r,color.g,color.b,0.14))
    var closed := polygon.duplicate()
    closed.append(polygon[0])
    draw_polyline(closed,color,2.0,true)
    for index in range(values.size()):
        var axis := _axis_point(index,values.size(),radius,start_angle,center)
        draw_circle(polygon[index],2.8,color)
        var label_point := axis + Vector2.ZERO
        var label := "%s\n%.0f" % [str(names[index]),values[index]]
        var pos := Vector2(label_point.x-label_width*0.5,label_point.y + (7.0 if label_point.y < center.y else 14.0))
        draw_string(font,pos,label,HORIZONTAL_ALIGNMENT_CENTER,label_width,font_size,color)

func _draw() -> void:
    if tam_can_values.size() != TAM_CAN_KEYS.size() or tu_tinh_values.size() != TU_TINH_KEYS.size():
        return
    var center := Vector2(size.x*0.5,size.y*0.46)
    var radius := minf(size.x*(0.27 if compact else 0.29),size.y*(0.25 if compact else 0.27))
    _draw_group_grid(TAM_CAN_KEYS.size(),-PI*0.5,center,radius)
    _draw_group_grid(TU_TINH_KEYS.size(),-PI*0.25,center,radius)
    var font := get_theme_default_font()
    if font == null:
        return
    var label_size := 9 if compact else 11
    _draw_group(tam_can_values,TAM_CAN_NAMES,tam_can_ceiling,-PI*0.5,AMBER,center,radius,font,label_size)
    _draw_group(tu_tinh_values,TU_TINH_NAMES,tu_tinh_ceiling,-PI*0.25,JADE,center,radius,font,label_size)
    var footer_size := 9 if compact else 10
    var midpoint := size.x*0.5
    draw_string(font,Vector2(2.0,size.y-7.0),"Tam Căn · thang %.0f" % tam_can_ceiling,
        HORIZONTAL_ALIGNMENT_CENTER,midpoint-3.0,footer_size,AMBER)
    draw_string(font,Vector2(midpoint+1.0,size.y-7.0),"Tứ Tính · thang %.0f" % tu_tinh_ceiling,
        HORIZONTAL_ALIGNMENT_CENTER,midpoint-3.0,footer_size,JADE)
