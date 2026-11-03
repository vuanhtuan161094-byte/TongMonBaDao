extends Control
## Shared Source A-compatible presentation icon atlas.
## The atlas is original AI-generated artwork; it is not Source A or a licensed source asset.

const ICON_ATLAS: Texture2D = preload("res://art/uiux/sect_management_icons_generated_v1.png")
const ICON_CELLS := {
	"gold": Vector2i(0, 0), "spirit_stone": Vector2i(0, 0),
	"leaf": Vector2i(1, 0), "wood": Vector2i(1, 0),
	"resource": Vector2i(2, 0), "ore": Vector2i(2, 0),
	"recruit_order": Vector2i(3, 0),
	"bed": Vector2i(0, 1),
	"guide": Vector2i(1, 1), "gate": Vector2i(1, 1), "hall": Vector2i(1, 1), "temple": Vector2i(1, 1),
	"build": Vector2i(2, 1), "upgrade": Vector2i(3, 1),
	"timer": Vector2i(0, 2),
	"person": Vector2i(1, 2), "portrait": Vector2i(1, 2), "worker": Vector2i(1, 2),
	"assignment": Vector2i(2, 2),
	"rank": Vector2i(3, 2), "quality": Vector2i(3, 2),
	"root": Vector2i(0, 3), "search": Vector2i(1, 3),
	"map": Vector2i(2, 3), "office": Vector2i(3, 3), "profession": Vector2i(3, 3)
}

var kind := "jade"
var tint := Color(0.85, 0.66, 0.34, 1.0)

func _ready() -> void:
	custom_minimum_size = Vector2(24, 24)
	queue_redraw()

func _draw() -> void:
	var scale_factor := minf(size.x, size.y) / 24.0
	if scale_factor <= 0.0:
		return
	var offset := (size - Vector2(24.0, 24.0) * scale_factor) * 0.5
	draw_set_transform(offset, 0.0, Vector2(scale_factor, scale_factor))
	if ICON_CELLS.has(kind):
		var cell: Vector2i = ICON_CELLS[kind]
		var atlas_size := ICON_ATLAS.get_size()
		var left := roundi(float(cell.x) * atlas_size.x / 4.0)
		var right := roundi(float(cell.x + 1) * atlas_size.x / 4.0)
		var top := roundi(float(cell.y) * atlas_size.y / 4.0)
		var bottom := roundi(float(cell.y + 1) * atlas_size.y / 4.0)
		var source := Rect2(Vector2(left, top), Vector2(right - left, bottom - top))
		draw_texture_rect_region(ICON_ATLAS, Rect2(Vector2.ZERO, Vector2(24.0, 24.0)), source)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	_draw_fallback_glyph()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

static func has_atlas_icon(icon_kind: String) -> bool:
	return ICON_CELLS.has(icon_kind)

static func atlas_cell(icon_kind: String) -> Vector2i:
	return ICON_CELLS.get(icon_kind, Vector2i(-1, -1))

func _draw_fallback_glyph() -> void:
	var pale := Color(0.92, 0.86, 0.69, 0.95)
	var dark := Color(0.08, 0.15, 0.15, 1.0)
	match kind:
		"hall", "temple":
			draw_colored_polygon(PackedVector2Array([Vector2(2, 9), Vector2(12, 3), Vector2(22, 9), Vector2(20, 10), Vector2(12, 6), Vector2(4, 10)]), tint)
			draw_line(Vector2(4, 10), Vector2(20, 10), pale, 1.4, true)
			for x in [6.0, 11.0, 16.0]:
				draw_line(Vector2(x, 11), Vector2(x, 20), tint, 1.8, true)
			draw_line(Vector2(4, 21), Vector2(20, 21), pale, 1.5, true)
			draw_line(Vector2(3, 23), Vector2(21, 23), tint, 1.3, true)
		"bed":
			draw_line(Vector2(3, 7), Vector2(3, 20), pale, 1.8, true)
			draw_line(Vector2(3, 12), Vector2(21, 12), tint, 2.2, true)
			draw_line(Vector2(4, 12), Vector2(8, 9), pale, 1.7, true)
			draw_line(Vector2(8, 9), Vector2(13, 9), pale, 1.7, true)
			draw_line(Vector2(13, 9), Vector2(18, 12), pale, 1.7, true)
			draw_line(Vector2(21, 12), Vector2(21, 20), tint, 1.8, true)
			draw_line(Vector2(3, 20), Vector2(21, 20), pale, 1.5, true)
		"person", "portrait":
			draw_circle(Vector2(12, 7), 4.0, tint)
			draw_colored_polygon(PackedVector2Array([Vector2(5, 22), Vector2(6, 17), Vector2(9, 13), Vector2(15, 13), Vector2(18, 17), Vector2(19, 22)]), pale)
			draw_arc(Vector2(12, 8), 5.2, PI, TAU, 16, tint, 1.4, true)
		"rank":
			for i in range(4):
				var h := 5.0 + float(i) * 3.2
				draw_rect(Rect2(3.0 + i * 5.0, 21.0 - h, 3.0, h), tint if i < 3 else pale)
			draw_line(Vector2(2, 22), Vector2(22, 22), pale, 1.2, true)
		"gold", "resource":
			draw_circle(Vector2(12, 12), 8.5, tint)
			draw_circle(Vector2(12, 12), 6.4, dark)
			draw_circle(Vector2(12, 12), 5.2, tint)
			draw_line(Vector2(12, 7), Vector2(12, 17), dark, 1.6, true)
			draw_line(Vector2(9, 9), Vector2(15, 9), dark, 1.4, true)
			draw_line(Vector2(9, 15), Vector2(15, 15), dark, 1.4, true)
		"guide", "gate":
			draw_arc(Vector2(12, 12), 9.0, PI, TAU, 24, tint, 2.2, true)
			draw_line(Vector2(3, 12), Vector2(3, 22), pale, 1.6, true)
			draw_line(Vector2(21, 12), Vector2(21, 22), pale, 1.6, true)
			draw_line(Vector2(3, 22), Vector2(21, 22), tint, 1.5, true)
			draw_circle(Vector2(12, 12), 3.0, pale)
		"leaf":
			draw_colored_polygon(PackedVector2Array([Vector2(3, 19), Vector2(6, 7), Vector2(18, 3), Vector2(21, 15), Vector2(12, 21)]), tint)
			draw_line(Vector2(5, 20), Vector2(18, 6), pale, 1.4, true)
		"check":
			draw_polyline(PackedVector2Array([Vector2(3, 13), Vector2(9, 19), Vector2(21, 5)]), tint, 2.8, true)
		"lock":
			draw_rect(Rect2(4, 10, 16, 12), tint)
			draw_arc(Vector2(12, 10), 5.5, PI, TAU, 20, pale, 1.8, true)
			draw_circle(Vector2(12, 15), 1.2, dark)
		"flame":
			draw_colored_polygon(PackedVector2Array([Vector2(12, 2), Vector2(18, 10), Vector2(21, 15), Vector2(17, 21), Vector2(9, 22), Vector2(4, 17), Vector2(6, 10)]), tint)
			draw_colored_polygon(PackedVector2Array([Vector2(12, 11), Vector2(15, 16), Vector2(12, 20), Vector2(9, 17)]), pale)
		_:
			draw_circle(Vector2(12, 12), 8.0, tint)
			draw_line(Vector2(12, 4), Vector2(12, 20), pale, 1.4, true)
			draw_line(Vector2(4, 12), Vector2(20, 12), pale, 1.4, true)
