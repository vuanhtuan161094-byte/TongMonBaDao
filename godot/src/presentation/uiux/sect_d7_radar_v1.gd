extends Control
## Presentation-only radar for the six canonical disciple stats. The legacy mind_nature
## compatibility value is intentionally omitted because it has no gameplay consumer.
const SIX_LABELS := ["Tư Chất", "Căn Cốt", "Tiềm Lực", "Thông Tuệ", "Cơ Duyên", "Mị Lực"]
const JADE := Color(0.30, 0.77, 0.67, 0.92)
const GRID := Color(0.45, 0.61, 0.55, 0.47)
const TEXT := Color(0.85, 0.89, 0.81, 0.98)
var values_six: Array[float] = []

func set_values(tam_values: Array, tu_values: Array) -> void:
	values_six.clear()
	if tam_values.size() < 2 or tu_values.size() != 4:
		queue_redraw()
		return
	# Candidate payload retains the old Tam/Tu grouping, but only the first two
	# values in Tam and all four canonical Tu values are gameplay stats.
	var next_values := [tam_values[0], tam_values[1], tu_values[0], tu_values[1], tu_values[2], tu_values[3]]
	for raw_value in next_values:
		if not (raw_value is int or raw_value is float) or is_nan(float(raw_value)) or is_inf(float(raw_value)) or float(raw_value) < 0.0:
			queue_redraw()
			return
		values_six.append(float(raw_value))
	queue_redraw()

func _draw() -> void:
	if size.x < 120.0 or size.y < 100.0 or values_six.size() != SIX_LABELS.size():
		return
	var center := Vector2(size.x * 0.5, size.y * 0.45)
	var radius := minf(size.x * 0.26, size.y * 0.29)
	var max_value := 1.0
	for value in values_six:
		max_value = maxf(max_value, value)
	for ring in range(1, 5):
		var points := PackedVector2Array()
		for axis in range(SIX_LABELS.size()):
			var angle := -PI * 0.5 + TAU * float(axis) / float(SIX_LABELS.size())
			points.append(center + Vector2(cos(angle), sin(angle)) * radius * float(ring) / 4.0)
		points.append(points[0])
		draw_polyline(points, GRID, 1.0, true)
	var polygon := PackedVector2Array()
	var font := ThemeDB.fallback_font
	for index in range(SIX_LABELS.size()):
		var angle := -PI * 0.5 + TAU * float(index) / float(SIX_LABELS.size())
		var direction := Vector2(cos(angle), sin(angle))
		draw_line(center, center + direction * radius, GRID, 1.0, true)
		polygon.append(center + direction * radius * clampf(values_six[index] / max_value, 0.0, 1.0))
		var label_point := center + direction * (radius + 18.0)
		draw_string(font, Vector2(label_point.x - 43.0, label_point.y + 3.0), SIX_LABELS[index], HORIZONTAL_ALIGNMENT_CENTER, 86.0, 10, JADE)
		draw_string(font, Vector2(label_point.x - 36.0, label_point.y + 15.0), "%.0f" % values_six[index], HORIZONTAL_ALIGNMENT_CENTER, 72.0, 10, TEXT)
	var fill := JADE
	fill.a = 0.16
	draw_colored_polygon(polygon, fill)
	var closed := polygon.duplicate()
	closed.append(polygon[0])
	draw_polyline(closed, JADE, 2.0, true)
	for point in polygon:
		draw_circle(point, 3.0, JADE)
	draw_string(font, Vector2(0.0, size.y - 5.0), "LỤC DUY · thang vẽ tự điều chỉnh", HORIZONTAL_ALIGNMENT_CENTER, size.x, 10, TEXT)