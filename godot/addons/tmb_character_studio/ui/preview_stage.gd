@tool
extends Node2D

var floor_y := 232.0
var pivot_origin := Vector2(170.0, 232.0)

func configure(stage_floor_y: float, pivot: Vector2) -> void:
	floor_y = stage_floor_y
	pivot_origin = pivot
	queue_redraw()

func _draw() -> void:
	draw_line(Vector2(12.0, floor_y), Vector2(328.0, floor_y), Color(0.52, 0.68, 0.58, 0.95), 2.0)
	draw_line(pivot_origin + Vector2(-8.0, 0.0), pivot_origin + Vector2(8.0, 0.0), Color(1.0, 0.72, 0.22, 1.0), 2.0)
	draw_line(pivot_origin + Vector2(0.0, -8.0), pivot_origin + Vector2(0.0, 8.0), Color(1.0, 0.72, 0.22, 1.0), 2.0)
