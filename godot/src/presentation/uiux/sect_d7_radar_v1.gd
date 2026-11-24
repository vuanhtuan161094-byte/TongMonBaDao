extends Control
const A2_RADAR = preload("res://src/presentation/p3/sect_six_axis_view.gd")
## Read-only D7 candidate chart. Tam Căn and Tứ Tính are shown in canonical order.
## Tâm Tính is a D7 profile/quality input, not a separate gameplay modifier.
const D7_KEYS := ["aptitude", "constitution", "mind_nature", "potential", "comprehension", "fortune", "charisma"]
const D7_LABELS := ["Tư Chất", "Căn Cốt", "Tâm Tính", "Tiềm Lực", "Thông Tuệ", "Cơ Duyên", "Mị Lực"]
const JADE := Color(0.30, 0.77, 0.67, 0.92)
const GOLD := Color(0.92, 0.72, 0.34, 0.95)
const GRID := Color(0.45, 0.61, 0.55, 0.47)
const TEXT := Color(0.85, 0.89, 0.81, 0.98)
var dimension_values: Array[float] = []
var mind_nature_available := true

func set_mind_nature_available(available: bool) -> void:
	mind_nature_available = available
	queue_redraw()

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
	A2_RADAR.draw_chart(self,dimension_values,mind_nature_available,TEXT,JADE,GRID)
