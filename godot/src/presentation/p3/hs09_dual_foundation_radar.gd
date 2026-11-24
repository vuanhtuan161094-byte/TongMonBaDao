class_name HS09DualFoundationRadar
extends Control
const A2_RADAR = preload("res://src/presentation/p3/sect_six_axis_view.gd")

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
# Founding/legacy disciples have six known foundation values. Keep the same
# seven-axis form, but mark Tâm Tính unavailable instead of inventing a score.
var mind_nature_available := true

func apply_snapshot(snapshot: Dictionary) -> bool:
	if not bool(snapshot.get("ok", false)):
		return false
	var foundations: Dictionary = snapshot.get("foundations", {})
	var next_model_version := int(foundations.get("model_version", 0))
	var legacy_profile := next_model_version < FoundationSystem.MODEL_D7
	var current: Dictionary = foundations.get("current", {})
	var next_values: Array[float] = []
	var maximum := 0.0
	for key in D7_KEYS:
		if legacy_profile and key == "mind_nature":
			# Geometry placeholder only. This value is never presented as a
			# genuine stat, used in quality calculations, or written to Save.
			next_values.append(0.0)
			continue
		if not current.has(key):
			return false
		var value := float(current[key])
		if is_nan(value) or is_inf(value) or value < 0.0:
			return false
		next_values.append(value)
		maximum = maxf(maximum, value)
	model_version = next_model_version
	mind_nature_available = not legacy_profile
	dimension_values = next_values
	chart_ceiling = _drawing_ceiling(maximum)
	tooltip_text = ("Lục Duy · Tâm Tính riêng trong hồ sơ D7 · không sửa chỉ số"
		if mind_nature_available else
		"Lục Duy · Hồ sơ cũ: Tâm Tính chưa có dữ liệu; không tự gán giá trị")
	queue_redraw()
	return true

static func _drawing_ceiling(maximum: float) -> float:
	if maximum <= 0.0:
		return 1.0
	var step := pow(10.0, floor(log(maximum) / log(10.0)))
	return maxf(ceil(maximum / step) * step, maximum)

func _draw() -> void:
	A2_RADAR.draw_chart(self,dimension_values,mind_nature_available,INK,JADE,GRID,model_version < 2)
