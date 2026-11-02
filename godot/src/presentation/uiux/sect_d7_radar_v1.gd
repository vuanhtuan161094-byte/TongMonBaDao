extends Control
## Read-only D7 foundation radar display. Tam and Tu series normalize independently,
## matching the existing dan_tien_d7_radar display contract; it never derives values.

const TAM_LABELS := ["Tư Chất", "Căn Cốt", "Tâm Tính"]
const TU_LABELS := ["Tiềm Lực", "Thông Tuệ", "Cơ Duyên", "Mị Lực"]
const TAM_COLOR := Color(0.30, 0.77, 0.67, 0.92)
const TU_COLOR := Color(0.95, 0.69, 0.35, 0.92)
const GRID_COLOR := Color(0.45, 0.61, 0.55, 0.47)
var values_tam: Array = []
var values_tu: Array = []

func set_values(tam_values: Array, tu_values: Array) -> void:
	values_tam = tam_values.duplicate()
	values_tu = tu_values.duplicate()
	queue_redraw()

func _draw() -> void:
	if size.x < 80.0 or size.y < 80.0:
		return
	var center := Vector2(size.x * 0.5, size.y * 0.47)
	var radius := minf(size.x * 0.34, size.y * 0.34)
	for ring in range(1, 5):
		var points := PackedVector2Array()
		for axis in range(84):
			var angle := float(axis) / 84.0 * TAU - PI * 0.5
			points.append(center + Vector2(cos(angle), sin(angle)) * radius * float(ring) / 4.0)
		points.append(points[0])
		draw_polyline(points, GRID_COLOR, 1.0, true)
	_draw_series(center, radius, values_tam, TAM_LABELS.size(), TAM_COLOR, -PI * 0.5)
	_draw_series(center, radius, values_tu, TU_LABELS.size(), TU_COLOR, -PI * 0.5 + PI / 4.0)
	# Two independent scales, one shared centered radar. Label each axis, not
	# just the colored polygons; colors remain consistent with the legend.
	_draw_axis_labels(center, radius, TAM_LABELS, TAM_COLOR, -PI * 0.5)
	_draw_axis_labels(center, radius, TU_LABELS, TU_COLOR, -PI * 0.5 + PI / 4.0)
	var legend_y := size.y - 16.0
	draw_circle(Vector2(24, legend_y), 4.0, TAM_COLOR)
	draw_string(ThemeDB.fallback_font, Vector2(34, legend_y + 4.0), "Tam", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, TEXT_COLOR)
	draw_circle(Vector2(89, legend_y), 4.0, TU_COLOR)
	draw_string(ThemeDB.fallback_font, Vector2(99, legend_y + 4.0), "Tứ", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, TEXT_COLOR)

const TEXT_COLOR := Color(0.85, 0.89, 0.81, 0.95)

func _draw_axis_labels(center: Vector2, radius: float, labels: Array, tint: Color, angle_start: float) -> void:
	for index in range(labels.size()):
		var angle := angle_start + TAU * float(index) / float(labels.size())
		var p := center + Vector2(cos(angle), sin(angle)) * (radius + 16.0)
		draw_string(ThemeDB.fallback_font, Vector2(p.x - 58.0, p.y + 4.0),
			str(labels[index]), HORIZONTAL_ALIGNMENT_CENTER, 116, 11, tint)


func _draw_series(center: Vector2, radius: float, data: Array, axis_count: int, tint: Color, angle_start: float) -> void:
	if data.size() != axis_count:
		return
	var max_value := 1.0
	for value in data:
		if value is int or value is float:
			max_value = maxf(max_value, float(value))
	var points := PackedVector2Array()
	for index in range(axis_count):
		var angle := angle_start + TAU * float(index) / float(axis_count)
		var axis := center + Vector2(cos(angle), sin(angle)) * radius
		draw_line(center, axis, GRID_COLOR, 1.0, true)
		var raw = data[index]
		var normalized := clampf(float(raw) / max_value, 0.0, 1.0) if raw is int or raw is float else 0.0
		points.append(center + Vector2(cos(angle), sin(angle)) * radius * normalized)
	if points.size() < 3:
		return
	var fill := tint
	fill.a = 0.18
	draw_colored_polygon(points, fill)
	var outline := points.duplicate()
	outline.append(points[0])
	draw_polyline(outline, tint, 2.0, true)
	for point in points:
		draw_circle(point, 3.0, tint)
