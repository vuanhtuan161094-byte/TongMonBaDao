extends Control
## Read-only D7 candidate chart. Tam Căn and Tứ Tính are shown in canonical order.
## Tâm Tính is a D7 profile/quality input, not a separate gameplay modifier.
const D7_KEYS := ["aptitude", "constitution", "mind_nature", "potential", "comprehension", "fortune", "charisma"]
const D7_LABELS := ["Tư Chất", "Căn Cốt", "Tâm Tính", "Tiềm Lực", "Thông Tuệ", "Cơ Duyên", "Mị Lực"]
const JADE := Color(0.30, 0.77, 0.67, 0.92)
const GRID := Color(0.45, 0.61, 0.55, 0.47)
const TEXT := Color(0.85, 0.89, 0.81, 0.98)
var dimension_values: Array[float] = []

func set_values(tam_values: Array, tu_values: Array) -> void:
	dimension_values.clear()
	if tam_values.size() != 3 or tu_values.size() != 4:
		queue_redraw()
		return
	for raw_value in tam_values + tu_values:
		if not (raw_value is int or raw_value is float) or is_nan(float(raw_value)) or is_inf(float(raw_value)) or float(raw_value) < 0.0:
			dimension_values.clear()
			queue_redraw()
			return
		dimension_values.append(float(raw_value))
	queue_redraw()

func _draw() -> void:
	if size.x < 180.0 or size.y < 150.0 or dimension_values.size() != D7_LABELS.size():
		return
	var center := Vector2(size.x * 0.5, size.y * 0.42)
	var radius := minf(size.x * 0.235, size.y * 0.28)
	var max_value := 1.0
	for value in dimension_values:
		max_value = maxf(max_value, value)
	for ring in range(1, 5):
		var points := PackedVector2Array()
		for axis in range(D7_LABELS.size()):
			var angle := -PI * 0.5 + TAU * float(axis) / float(D7_LABELS.size())
			points.append(center + Vector2(cos(angle), sin(angle)) * radius * float(ring) / 4.0)
		points.append(points[0])
		draw_polyline(points, GRID, 1.0, true)
	var polygon := PackedVector2Array()
	var font := ThemeDB.fallback_font
	for index in range(D7_LABELS.size()):
		var angle := -PI * 0.5 + TAU * float(index) / float(D7_LABELS.size())
		var direction := Vector2(cos(angle), sin(angle))
		draw_line(center, center + direction * radius, GRID, 1.0, true)
		var value := dimension_values[index]
		polygon.append(center + direction * radius * clampf(value / max_value, 0.0, 1.0))
		var label_point := center + direction * (radius + 15.0)
		draw_string(font, Vector2(label_point.x - 43.0, label_point.y + 3.0), D7_LABELS[index], HORIZONTAL_ALIGNMENT_CENTER, 86.0, 9, JADE)
		draw_string(font, Vector2(label_point.x - 34.0, label_point.y + 14.0), "%.0f" % value, HORIZONTAL_ALIGNMENT_CENTER, 68.0, 9, TEXT)
	var fill := JADE
	fill.a = 0.16
	draw_colored_polygon(polygon, fill)
	var closed := polygon.duplicate()
	closed.append(polygon[0])
	draw_polyline(closed, JADE, 2.0, true)
	for point in polygon:
		draw_circle(point, 3.0, JADE)
	draw_string(font, Vector2(0.0, size.y - 2.0), "TAM CĂN (3)  ·  TỨ TÍNH (4)", HORIZONTAL_ALIGNMENT_CENTER, size.x, 9, TEXT)
