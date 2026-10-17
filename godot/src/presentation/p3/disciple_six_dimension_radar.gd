class_name DiscipleSixDimensionRadar
extends Control

# Presentation-only: never normalizes, caps or modifies canonical six stats.
const KEYS := ["aptitude","constitution","fortune","comprehension","charisma","potential"]
const NAMES := ["Tư Chất","Căn Cốt","Cơ Duyên","Thông Tuệ","Mị Lực","Tiềm Lực"]
const JADE := Color(0.17,0.45,0.35,1.0)
const GRID := Color(0.37,0.38,0.28,0.32)
const INK := Color(0.18,0.24,0.19,1.0)

var dimension_values: Array[float] = []
var chart_ceiling := 1.0
var model_version := 1

func apply_snapshot(snapshot: Dictionary) -> bool:
    if not bool(snapshot.get("ok",false)):
        return false
    var foundations: Dictionary = snapshot.get("foundations",{})
    var current: Dictionary = foundations.get("current",{})
    var values: Array[float] = []
    var maximum := 0.0
    for key in KEYS:
        if not current.has(key):
            return false
        var value := float(current[key])
        if is_nan(value) or is_inf(value) or value < 0.0:
            return false
        values.append(value)
        maximum = maxf(maximum,value)
    dimension_values = values
    model_version = int(foundations.get("model_version",1))
    chart_ceiling = maxf(1.0,maximum) if model_version < 2 else _drawing_ceiling(maximum)
    tooltip_text = "Lục Duy hiện tại · Thang vẽ tự điều chỉnh, không phải giới hạn chỉ số"
    queue_redraw()
    return true

static func _drawing_ceiling(maximum: float) -> float:
    if maximum <= 0.0:
        return 1.0
    var step := pow(10.0,floor(log(maximum)/log(10.0)))
    return maxf(ceil(maximum/step)*step,maximum)

func _axis_point(index: int, distance: float, center: Vector2) -> Vector2:
    var radians := -PI*0.5 + TAU*float(index)/6.0
    return center + Vector2(cos(radians),sin(radians))*distance

func _draw() -> void:
    if dimension_values.size() != 6:
        return
    var center := Vector2(size.x*0.5,size.y*0.48)
    var radius := minf(size.x*0.32,size.y*0.29)
    var font := get_theme_default_font()
    var polygon := PackedVector2Array()
    for ring in [0.25,0.5,0.75,1.0]:
        var outline := PackedVector2Array()
        for index in range(7):
            outline.append(_axis_point(index%6,radius*ring,center))
        draw_polyline(outline,GRID,1.0,true)
    for index in range(6):
        draw_line(center,_axis_point(index,radius,center),GRID,1.0,true)
        var value := dimension_values[index]
        polygon.append(_axis_point(index,radius*clampf(value/chart_ceiling,0.0,1.0),center))
        if font != null:
            var point := _axis_point(index,radius+19.0,center)
            draw_string(font,Vector2(point.x-35.0,point.y),NAMES[index],HORIZONTAL_ALIGNMENT_CENTER,70.0,11,INK)
            var text_value := "%.0f" % value if model_version >= 2 else "%.2f" % value
            draw_string(font,Vector2(point.x-35.0,point.y+13.0),text_value,HORIZONTAL_ALIGNMENT_CENTER,70.0,11,JADE)
    draw_colored_polygon(polygon,Color(0.22,0.57,0.42,0.30))
    var closed := polygon.duplicate()
    closed.append(polygon[0])
    draw_polyline(closed,JADE,2.0,true)
    for point in polygon:
        draw_circle(point,3.0,JADE)
    if font != null:
        var ceiling_text := "%.0f" % chart_ceiling if model_version >= 2 else "%.2f" % chart_ceiling
        draw_string(font,Vector2(0.0,size.y-9.0),"Thang: "+ceiling_text+" · không phải giới hạn",HORIZONTAL_ALIGNMENT_CENTER,size.x,11,INK)
