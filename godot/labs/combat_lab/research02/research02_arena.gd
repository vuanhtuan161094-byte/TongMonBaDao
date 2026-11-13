extends "res://labs/combat_lab/research01/research01_arena.gd"
# LAB-only same actors / same 3 permitted visual victims as Research01.
# The untouched V14/A/B footage is the control group; this scene is C.
const FLOW = preload("res://labs/combat_lab/research02/flowing_sword_fx.gd")

func _ready() -> void:
    super._ready()
    title_label.text = "VFX RESEARCH 02 | C / LUU QUANG KIEM KHI"
    detail_label.text = (
        "Than kiem V14 + 3 luong lua tam bay + du anh theo quy dao / "
        + "LIVE PVE OFF   |   SPACE phat lai   P tam dung")
    queue_redraw()

func _draw() -> void:
    var t := fposmod(elapsed, LOOP_SECONDS) / LOOP_SECONDS
    _arena()
    for i in range(MOBS.size()):
        var p: Vector2 = MOBS[i]
        draw_circle(p + Vector2(0, 10), 23.0, _tint(Color.BLACK, 0.3))
        RIG.render(self,
            {"id": "research02_mob_" + str(i), "side": "monster",
                "tier": "normal", "hp": 100.0},
            p, "fist", "idle", elapsed, 1.72, -1.0, 0.0)
    RIG.render(self,
        {"id": "research02_caster", "side": "disciple", "hp": 100.0},
        CASTER, "fist", "cast", elapsed, 2.0, 1.0, 0.18)
    _target_telegraph(t)
    FLOW.render(self, CASTER, approved_hits, t, 1.24, 2)
    draw_arc(MOBS[3] + Vector2(0, 12), 21, 0.0, TAU,
        30, _tint(Color("8c949d"), 0.28), 1.2, true)
    draw_line(Vector2(20, 625), Vector2(1260, 625),
        _tint(CYAN, 0.12), 1.0, true)
