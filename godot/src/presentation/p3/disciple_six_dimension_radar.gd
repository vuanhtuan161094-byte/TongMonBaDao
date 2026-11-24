class_name DiscipleSixDimensionRadar
extends Control
const A2_RADAR = preload("res://src/presentation/p3/sect_six_axis_view.gd")

# Presentation-only: never normalizes, caps or modifies canonical foundation data.
const KEYS := ["aptitude","constitution","fortune","comprehension","charisma","potential"]
const NAMES := ["Tư Chất","Căn Cốt","Cơ Duyên","Thông Tuệ","Mị Lực","Tiềm Lực"]
const D7_KEYS := ["aptitude","constitution","mind_nature","potential","comprehension","fortune","charisma"]
const D7_NAMES := ["Tư Chất","Căn Cốt","Tâm Tính","Tiềm Lực","Thông Tuệ","Cơ Duyên","Mị Lực"]
const JADE := Color(0.17,0.45,0.35,1.0)
const GRID := Color(0.37,0.38,0.28,0.32)
const INK := Color(0.18,0.24,0.19,1.0)

var dimension_values: Array[float] = []
var chart_ceiling := 1.0
var model_version := 1
var dimension_keys: Array = []
var dimension_names: Array = []

func apply_snapshot(snapshot: Dictionary) -> bool:
    if not bool(snapshot.get("ok",false)):
        return false
    var foundations: Dictionary = snapshot.get("foundations",{})
    var current: Dictionary = foundations.get("current",{})
    var values: Array[float] = []
    var maximum := 0.0
    model_version = int(foundations.get("model_version",1))
    dimension_keys = D7_KEYS.duplicate() if model_version >= FoundationSystem.MODEL_D7 else KEYS.duplicate()
    dimension_names = D7_NAMES.duplicate() if model_version >= FoundationSystem.MODEL_D7 else NAMES.duplicate()
    for key in dimension_keys:
        if not current.has(key):
            return false
        var value := float(current[key])
        if is_nan(value) or is_inf(value) or value < 0.0:
            return false
        values.append(value)
        maximum = maxf(maximum,value)
    dimension_values = values
    chart_ceiling = maxf(1.0,maximum) if model_version < 2 else _drawing_ceiling(maximum)
    tooltip_text = ("D7 · Tam Căn/Tứ Tính hiện tại" if model_version >= FoundationSystem.MODEL_D7 else "Thuộc tính nền tảng kế thừa") + " · Thang vẽ tự điều chỉnh, không phải giới hạn chỉ số"
    queue_redraw()
    return true

static func _drawing_ceiling(maximum: float) -> float:
    if maximum <= 0.0:
        return 1.0
    var step := pow(10.0,floor(log(maximum)/log(10.0)))
    return maxf(ceil(maximum/step)*step,maximum)

func _axis_point(index: int, distance: float, center: Vector2) -> Vector2:
    var count := maxi(1,dimension_values.size())
    var radians := -PI*0.5 + TAU*float(index)/float(count)
    return center + Vector2(cos(radians),sin(radians))*distance

func _draw() -> void:
    A2_RADAR.draw_chart(self,dimension_values,model_version >= FoundationSystem.MODEL_D7,INK,JADE,GRID,model_version < 2)
