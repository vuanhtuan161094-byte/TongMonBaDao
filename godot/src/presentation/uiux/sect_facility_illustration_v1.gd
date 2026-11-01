extends Control
## Original Godot-drawn facility illustration used until a caller provides approved art.

var facility_kind := "hall"

func _ready() -> void:
	if custom_minimum_size == Vector2.ZERO:
		custom_minimum_size = Vector2(300, 185)
	queue_redraw()

func _draw() -> void:
	if size.x < 2.0 or size.y < 2.0:
		return
	var scale_factor := minf(size.x / 360.0, size.y / 240.0)
	var offset := (size - Vector2(360.0, 240.0) * scale_factor) * 0.5
	draw_set_transform(offset, 0.0, Vector2(scale_factor, scale_factor))
	var night := Color(0.055, 0.14, 0.15, 1.0)
	var jade := Color(0.25, 0.54, 0.46, 1.0)
	var jade_light := Color(0.43, 0.72, 0.60, 1.0)
	var gold := Color(0.86, 0.68, 0.36, 1.0)
	var paper := Color(0.90, 0.84, 0.68, 1.0)
	var mist := Color(0.54, 0.72, 0.62, 0.18)
	draw_rect(Rect2(0, 0, 360, 240), night)
	draw_circle(Vector2(286, 52), 31.0, Color(0.86, 0.72, 0.44, 0.12))
	draw_circle(Vector2(286, 52), 20.0, Color(0.90, 0.78, 0.53, 0.13))
	draw_colored_polygon(PackedVector2Array([Vector2(0, 163), Vector2(68, 100), Vector2(122, 158), Vector2(180, 92), Vector2(263, 166), Vector2(322, 112), Vector2(360, 151), Vector2(360, 240), Vector2(0, 240)]), Color(0.10, 0.25, 0.23, 0.86))
	draw_colored_polygon(PackedVector2Array([Vector2(0, 186), Vector2(86, 141), Vector2(147, 190), Vector2(230, 132), Vector2(298, 190), Vector2(360, 148), Vector2(360, 240), Vector2(0, 240)]), Color(0.15, 0.32, 0.27, 0.94))
	draw_rect(Rect2(0, 200, 360, 40), Color(0.14, 0.31, 0.26, 1.0))
	for x in [26.0, 49.0, 304.0, 330.0]:
		draw_line(Vector2(x, 190), Vector2(x - 5.0, 174), mist, 1.2, true)
		draw_circle(Vector2(x, 171), 3.0, gold * Color(1, 1, 1, 0.5))
	match facility_kind:
		"residence":
			_draw_residence(jade, jade_light, gold, paper)
		"guidance":
			_draw_guidance(jade, jade_light, gold, paper)
		_:
			_draw_hall(jade, jade_light, gold, paper)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_hall(jade: Color, jade_light: Color, gold: Color, paper: Color) -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(84, 190), Vector2(275, 190), Vector2(314, 218), Vector2(45, 218)]), Color(0.24, 0.38, 0.30, 1.0))
	draw_rect(Rect2(108, 120, 145, 67), Color(0.27, 0.31, 0.24, 1.0))
	draw_rect(Rect2(120, 133, 121, 48), Color(0.40, 0.31, 0.20, 1.0))
	draw_colored_polygon(PackedVector2Array([Vector2(75, 124), Vector2(119, 82), Vector2(179, 63), Vector2(239, 82), Vector2(287, 124), Vector2(264, 127), Vector2(179, 97), Vector2(96, 128)]), jade)
	draw_colored_polygon(PackedVector2Array([Vector2(57, 121), Vector2(117, 73), Vector2(179, 52), Vector2(243, 74), Vector2(306, 121), Vector2(278, 119), Vector2(179, 88), Vector2(84, 123)]), jade_light)
	draw_polyline(PackedVector2Array([Vector2(61, 120), Vector2(118, 75), Vector2(179, 54), Vector2(242, 76), Vector2(302, 120)]), gold, 1.7, true)
	for x in [127.0, 164.0, 201.0, 238.0]:
		draw_rect(Rect2(x, 127, 7, 57), paper)
		draw_rect(Rect2(x + 1.0, 144, 5, 22), Color(0.89, 0.68, 0.37, 0.8))
	draw_rect(Rect2(170, 146, 20, 41), Color(0.13, 0.20, 0.17, 1.0))
	draw_line(Vector2(82, 190), Vector2(279, 190), gold, 2.0, true)
	draw_circle(Vector2(180, 45), 3.0, gold)

func _draw_residence(jade: Color, jade_light: Color, gold: Color, paper: Color) -> void:
	draw_colored_polygon(_ellipse_points(Vector2(180, 210), Vector2(126, 13)), Color(0.20, 0.39, 0.31, 0.9))
	draw_rect(Rect2(116, 116, 132, 79), Color(0.42, 0.34, 0.25, 1.0))
	draw_rect(Rect2(128, 129, 108, 60), Color(0.55, 0.43, 0.30, 1.0))
	draw_colored_polygon(PackedVector2Array([Vector2(94, 124), Vector2(133, 88), Vector2(183, 75), Vector2(236, 92), Vector2(271, 126), Vector2(250, 127), Vector2(182, 104), Vector2(112, 129)]), jade)
	draw_polyline(PackedVector2Array([Vector2(98, 122), Vector2(135, 88), Vector2(183, 76), Vector2(236, 93), Vector2(267, 124)]), gold, 1.5, true)
	draw_rect(Rect2(145, 143, 22, 24), Color(0.12, 0.22, 0.20, 1.0))
	draw_rect(Rect2(199, 143, 22, 24), Color(0.12, 0.22, 0.20, 1.0))
	draw_rect(Rect2(172, 155, 19, 40), Color(0.18, 0.23, 0.20, 1.0))
	draw_line(Vector2(100, 199), Vector2(265, 199), paper, 1.4, true)
	draw_line(Vector2(77, 214), Vector2(112, 214), gold, 1.5, true)
	draw_circle(Vector2(82, 205), 8.0, jade_light)
	draw_circle(Vector2(294, 183), 15.0, jade)
	draw_line(Vector2(294, 197), Vector2(294, 217), jade_light, 2.0, true)
	draw_circle(Vector2(294, 174), 5.0, Color(0.56, 0.77, 0.61, 1.0))

func _draw_guidance(jade: Color, jade_light: Color, gold: Color, paper: Color) -> void:
	draw_colored_polygon(_ellipse_points(Vector2(180, 204), Vector2(111, 15)), Color(0.24, 0.41, 0.32, 1.0))
	draw_arc(Vector2(180, 137), 77.0, PI, TAU, 64, jade_light, 5.0, true)
	draw_arc(Vector2(180, 137), 62.0, PI, TAU, 64, gold, 1.5, true)
	draw_line(Vector2(103, 137), Vector2(103, 207), paper, 5.0, true)
	draw_line(Vector2(257, 137), Vector2(257, 207), paper, 5.0, true)
	draw_line(Vector2(91, 207), Vector2(269, 207), jade_light, 4.0, true)
	draw_line(Vector2(115, 146), Vector2(115, 193), gold, 1.5, true)
	draw_line(Vector2(245, 146), Vector2(245, 193), gold, 1.5, true)
	draw_circle(Vector2(180, 136), 30.0, Color(0.31, 0.75, 0.68, 0.25))
	draw_circle(Vector2(180, 136), 18.0, Color(0.46, 0.89, 0.79, 0.25))
	draw_arc(Vector2(180, 136), 19.0, 0.0, TAU, 48, jade_light, 2.0, true)
	draw_colored_polygon(PackedVector2Array([Vector2(174, 142), Vector2(180, 126), Vector2(186, 142), Vector2(180, 151)]), paper)
	draw_circle(Vector2(180, 120), 3.0, gold)
	draw_circle(Vector2(96, 137), 4.0, gold)
	draw_circle(Vector2(264, 137), 4.0, gold)


func _ellipse_points(center: Vector2, radii: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(40):
		var angle := TAU * float(index) / 40.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	return points
