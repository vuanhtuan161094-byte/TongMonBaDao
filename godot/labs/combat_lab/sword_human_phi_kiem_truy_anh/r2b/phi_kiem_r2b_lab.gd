extends "res://labs/visual_bridge_v1/as48_sword_anchor_lab.gd"
# Isolated Human Sword R2B preview; preserves all source actor/monster and
# read-only LAB event routing of AS48. The rejected R1 layer remains immutable.
const R2B := preload("res://labs/combat_lab/sword_human_phi_kiem_truy_anh/r2b/phi_kiem_r2b_vfx_layer.gd")

func _ready() -> void:
    super._ready()
    if not _good:
        return
    var old := get_node_or_null("OriginalSwordHumanR1RGBA")
    if old != null:
        old.visible = false
        old.set_process(false)
    var layer := Node2D.new()
    layer.name = "OriginalSwordHumanR2BRGBA"
    layer.set_script(R2B)
    add_child(layer)
    print("VFX_SWORD_R2B_LAB_READY=PASS actor=REAL_AS48 monster=REAL_WALK direction=FRONT_ONLY owner=PROVISIONAL PvE=HOLD")
    queue_redraw()

func _redraw_source_vfx() -> void:
    var layer := get_node_or_null("OriginalSwordHumanR2BRGBA")
    if layer != null:
        layer.queue_redraw()

func review_seek_phase(phase: String) -> void:
    super.review_seek_phase(phase)
    print("VFX_SWORD_R2B_PHASE_HELD=" + phase + " LAB_ONLY=true")

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color("d9e6ed") if _review_bright else Color("17212b"))
    draw_rect(Rect2(0, 420, 1280, 300), Color("b2baae") if _review_bright else Color("383e3c"))
    draw_rect(Rect2(0, 496, 1280, 6), Color("869b8d") if _review_bright else Color("59665b"))
    draw_line(Vector2(80, 604), Vector2(1200, 604), Color("737f75"), 1.0)
    _draw_original_actor_and_monster()
    var font := ThemeDB.fallback_font
    draw_string(font, Vector2(24, 42), "KIEM TU NHAN - PHI KIEM TRUY ANH R2B - ILLUSTRATED RGBA + REAL JIAN",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("163247") if _review_bright else Color("e7f3fa"))
    draw_string(font, Vector2(24, 68), "REAL AS48 4 FRAME FRONT + REAL WALK MONSTER / LAB EVENTS SYNTHETIC",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("643d17") if _review_bright else Color("f4cf90"))
    draw_string(font, Vector2(24, 94), "1 CHARGE  2 FLIGHT  3 CONTACT / SPACE REPLAY / M MONSTER WALK",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("304d63") if _review_bright else Color("bed2e0"))
    draw_string(font, Vector2(24, 682), "OWNER PROVISIONAL - NATIVE / WEB GATES INDEPENDENT - PVE HOLD - NOT GAMEPLAY",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("68472c") if _review_bright else Color("f0d7b9"))