class_name DanTienD7Radar
extends Control

# Read-only C2 D7 illustration: one canvas, independent Tam/Tu normalization.
# No permanent balancing effects are inferred from the drawing.
const TAM := ["Tư Chất", "Căn Cốt", "Tâm Tính"]
const TU := ["Tiềm Lực", "Thông Tuệ", "Cơ Duyên", "Mị Lực"]
const TAM_COLOR := Color(0.27, 0.72, 0.65, 0.87)
const TU_COLOR := Color(0.98, 0.70, 0.33, 0.87)
const GRID_COLOR := Color(0.40, 0.49, 0.47, 0.50)
var values_tam: Array[float] = [0.0, 0.0, 0.0]
var values_tu: Array[float] = [0.0, 0.0, 0.0, 0.0]

func set_candidate(candidate: CandidateState) -> void:
    if candidate == null:
        return
    values_tam = [candidate.aptitude, candidate.constitution, candidate.mind_nature]
    values_tu = [candidate.potential, candidate.comprehension, candidate.fortune, candidate.charisma]
    queue_redraw()

func _draw() -> void:
    var center := Vector2(size.x * 0.5, size.y * 0.52)
    var radius := minf(size.x * 0.36, size.y * 0.35)
    if radius <= 4.0:
        return
    for count in range(1, 5):
        var points := PackedVector2Array()
        for angle_i in range(60):
            var angle := float(angle_i) / 60.0 * TAU - PI * 0.5
            points.append(center + Vector2(cos(angle), sin(angle)) * radius * float(count) / 4.0)
        if points.size() > 0:
            points.append(points[0])
            draw_polyline(points, GRID_COLOR, 1.0, true)
    # Three and four independently scaled vertices occupy the same common canvas.
    _draw_series(center, radius * 0.95, values_tam, TAM_COLOR, -PI * 0.5)
    _draw_series(center, radius * 0.95, values_tu, TU_COLOR, -PI * 0.5 + PI / 4.0)

func _draw_series(center: Vector2, radius: float, data: Array[float], tint: Color, angle0: float) -> void:
    if data.is_empty():
        return
    var max_value := 1.0
    for entry in data:
        max_value = maxf(max_value, entry)
    var points := PackedVector2Array()
    for index in range(data.size()):
        var a := angle0 + TAU * float(index) / float(data.size())
        var axis := center + Vector2(cos(a), sin(a)) * radius
        draw_line(center, axis, GRID_COLOR, 1.0, true)
        points.append(center + Vector2(cos(a), sin(a)) * radius * clampf(data[index] / max_value, 0.0, 1.0))
    var fill := tint
    fill.a = 0.20
    draw_colored_polygon(points, fill)
    var outline := points.duplicate()
    outline.append(points[0])
    draw_polyline(outline, tint, 2.0, true)
    for pt in points:
        draw_circle(pt, 3.0, tint)
