class_name HS09DualFoundationRadar
extends Control

## Read-only D7 profile chart; values are presentation data, never normalized in state.
## Tâm Tính belongs to Tam Căn and contributes to D7 quality, with no direct runtime modifier.
const D7_KEYS := ["aptitude", "constitution", "mind_nature", "potential", "comprehension", "fortune", "charisma"]
const D7_NAMES := ["Tư Chất", "Căn Cốt", "Tâm Tính", "Tiềm Lực", "Thông Tuệ", "Cơ Duyên", "Mị Lực"]
const JADE := Color(0.13, 0.48, 0.36, 1.0)
const GRID := Color(0.37, 0.38, 0.28, 0.30)
const INK := Color(0.18, 0.24, 0.19, 1.0)

var compact := false
var model_version := 0
var dimension_values: Array[float] = []
var chart_ceiling := 1.0

func apply_snapshot(snapshot: Dictionary) -> bool:
	if not bool(snapshot.get("ok", false)):
		return false
	var foundations: Dictionary = snapshot.get("foundations", {})
	var next_model_version := int(foundations.get("model_version", 0))
	if next_model_version < FoundationSystem.MODEL_D7:
		return false
	var current: Dictionary = foundations.get("current", {})
	var next_values: Array[float] = []
	var maximum := 0.0
	for key in D7_KEYS:
		if not current.has(key):
			return false
		var value := float(current[key])
		if is_nan(value) or is_inf(value) or value < 0.0:
			return false
		next_values.append(value)
		maximum = maxf(maximum, value)
	model_version = next_model_version
	dimension_values = next_values
	chart_ceiling = _drawing_ceiling(maximum)
	tooltip_text = "D7 · Tam Căn (3) / Tứ Tính (4) · đọc theo hồ sơ, không sửa chỉ số"
	queue_redraw()
	return true

static func _drawing_ceiling(maximum: float) -> float:
	if maximum <= 0.0:
		return 1.0
	var step := pow(10.0, floor(log(maximum) / log(10.0)))
	return maxf(ceil(maximum / step) * step, maximum)

func _draw() -> void:
	if dimension_values.size() != D7_KEYS.size():
		return
	var center := Vector2(size.x * 0.5, size.y * 0.43)
	var radius := minf(size.x * (0.28 if compact else 0.29), size.y * (0.235 if compact else 0.25))
	var font := get_theme_default_font()
	if font == null:
		return
	var polygon := PackedVector2Array()
	var label_width := 76.0 if compact else 82.0
	var label_size := 9 if compact else 10
	for ring in [0.25, 0.5, 0.75, 1.0]:
		var outline := PackedVector2Array()
		for index in range(D7_KEYS.size() + 1):
			var angle := -PI * 0.5 + TAU * float(index % D7_KEYS.size()) / float(D7_KEYS.size())
			outline.append(center + Vector2(cos(angle), sin(angle)) * radius * ring)
		draw_polyline(outline, GRID, 1.0, true)
	for index in range(D7_KEYS.size()):
		var angle := -PI * 0.5 + TAU * float(index) / float(D7_KEYS.size())
		var direction := Vector2(cos(angle), sin(angle))
		draw_line(center, center + direction * radius, GRID, 1.0, true)
		var value := dimension_values[index]
		var point := center + direction * radius * clampf(value / maxf(chart_ceiling, 1.0), 0.0, 1.0)
		polygon.append(point)
		var label_point := center + direction * (radius + 14.0)
		draw_string(font, Vector2(label_point.x - label_width * 0.5, label_point.y + 3.0), D7_NAMES[index], HORIZONTAL_ALIGNMENT_CENTER, label_width, label_size, JADE)
		draw_string(font, Vector2(label_point.x - 28.0, label_point.y + label_size + 3.0), "%.0f" % value, HORIZONTAL_ALIGNMENT_CENTER, 56.0, label_size, INK)
	draw_colored_polygon(polygon, Color(0.22, 0.57, 0.42, 0.22))
	var closed := polygon.duplicate()
	closed.append(polygon[0])
	draw_polyline(closed, JADE, 2.0, true)
	for point in polygon:
		draw_circle(point, 3.0, JADE)
	draw_string(font, Vector2(0.0, size.y - 4.0), "TAM CĂN (3)  ·  TỨ TÍNH (4)  ·  thang %.0f" % chart_ceiling,
		HORIZONTAL_ALIGNMENT_CENTER, size.x, 9 if compact else 10, INK)
