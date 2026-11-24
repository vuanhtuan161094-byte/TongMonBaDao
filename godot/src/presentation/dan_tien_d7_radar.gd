class_name DanTienD7Radar
extends Control
const A2_RADAR = preload("res://src/presentation/p3/sect_six_axis_view.gd")

# Read-only C2 D7 illustration: one canvas, independent Tam/Tu normalization.
# No permanent balancing effects are inferred from the drawing.
const TAM := ["Tư Chất", "Căn Cốt", "Tâm Tính"]
const TU := ["Tiềm Lực", "Thông Tuệ", "Cơ Duyên", "Mị Lực"]
const TAM_COLOR := Color(0.27, 0.72, 0.65, 0.87)
const TU_COLOR := Color(0.98, 0.70, 0.33, 0.87)
const GRID_COLOR := Color(0.40, 0.49, 0.47, 0.50)
var mind_nature_available := false
var values_tam: Array[float] = [0.0, 0.0, 0.0]
var values_tu: Array[float] = [0.0, 0.0, 0.0, 0.0]

func set_candidate(candidate: CandidateState) -> void:
    if candidate == null:
        return
    mind_nature_available = candidate.foundation_model_version >= FoundationSystem.MODEL_D7
    values_tam = [candidate.aptitude, candidate.constitution, candidate.mind_nature]
    values_tu = [candidate.potential, candidate.comprehension, candidate.fortune, candidate.charisma]
    queue_redraw()

func _draw() -> void:
    A2_RADAR.draw_chart(self,values_tam+values_tu,mind_nature_available,Color(0.88,0.91,0.84),TAM_COLOR,GRID_COLOR)
