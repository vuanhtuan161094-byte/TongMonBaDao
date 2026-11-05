extends Control
## Read-only D7 candidate chart. Tam Căn and Tứ Tính are shown in canonical order.
## Tâm Tính is a D7 profile/quality input, not a separate gameplay modifier.
const D7_KEYS := ["aptitude", "constitution", "mind_nature", "potential", "comprehension", "fortune", "charisma"]
const D7_LABELS := ["Tư Chất", "Căn Cốt", "Tâm Tính", "Tiềm Lực", "Thông Tuệ", "Cơ Duyên", "Mị Lực"]
const JADE := Color(0.30, 0.77, 0.67, 0.92)
const GOLD := Color(0.92, 0.72, 0.34, 0.95)
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
	var center := Vector2(size.x * 0.5, size.y * 0.46)
	var radius := minf(size.x * 0.235, size.y * 0.31)
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
		var label_point := center + direction * (radius + 16.0)
		var axis_color := JADE if index < 3 else GOLD
		draw_string(font, Vector2(label_point.x - 48.0, label_point.y + 3.0), D7_LABELS[index], HORIZONTAL_ALIGNMENT_CENTER, 96.0, 13, axis_color)
		draw_string(font, Vector2(label_point.x - 34.0, label_point.y + 16.0), "%.0f" % value, HORIZONTAL_ALIGNMENT_CENTER, 68.0, 12, TEXT)
	var fill := JADE
	fill.a = 0.16
	draw_colored_polygon(polygon, fill)
	var closed := polygon.duplicate()
	closed.append(polygon[0])
	for index in range(polygon.size()):
		var next_index := (index + 1) % polygon.size()
		var edge_color := Color(0.83, 0.78, 0.46, 0.95)
		if index < 2:
			edge_color = JADE
		elif index >= 3:
			edge_color = GOLD
		draw_line(polygon[index], polygon[next_index], edge_color, 2.5, true)
	for index in range(polygon.size()):
		draw_circle(polygon[index], 4.0, JADE if index < 3 else GOLD)
	draw_string(font, Vector2(0.0, size.y - 4.0), "TAM CĂN · 3 TRỤC", HORIZONTAL_ALIGNMENT_CENTER, size.x * 0.5, 11, JADE)
	draw_string(font, Vector2(size.x * 0.5, size.y - 4.0), "TỨ TÍNH · 4 TRỤC", HORIZONTAL_ALIGNMENT_CENTER, size.x * 0.5, 11, GOLD)
