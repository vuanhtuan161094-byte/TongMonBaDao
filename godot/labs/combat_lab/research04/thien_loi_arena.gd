extends "res://labs/combat_lab/research01/research01_arena.gd"
# VFX19.1 Thiên Lôi | original sky-bolt and chain-lightning variants.
# Entirely independent ART LAB. No HP/target/AI/combat or Save mutation.
const LAYER = preload("res://labs/combat_lab/research04/thien_loi_overlay.gd")
const FX = preload("res://labs/combat_lab/research04/thien_loi_vfx.gd")
const SOIL := Color("353939")
const ASH := Color("232c35")
var thunder_mode := 0
var thunder_layer: Node2D

func _ready() -> void:
    super._ready()
    thunder_mode = 1 if OS.get_environment("TMB_VFX19_MODE") == "chain" else 0
    title_label.text = "VFX19 | THIEN LOI - CUU TIEU / LOI LIEN"
    detail_label.text = "1: Loi giang  2: Loi lien  SPACE: lap lai  P: dung    |    VFX LAB / PVE OFF"
    thunder_layer = LAYER.new()
    thunder_layer.z_index = 6
    add_child(thunder_layer)
    thunder_layer.queue_redraw()
    queue_redraw()

func _process(delta: float) -> void:
    super._process(delta)
    if thunder_layer != null and not paused:
        thunder_layer.queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    match event.keycode:
        KEY_1:
            thunder_mode = 0
            elapsed = 0.0
        KEY_2:
            thunder_mode = 1
            elapsed = 0.0
        KEY_SPACE:
            elapsed = 0.0
        KEY_P:
            paused = not paused
    queue_redraw()
    if thunder_layer != null:
        thunder_layer.queue_redraw()

func _draw() -> void:
    var t := fposmod(elapsed, FX.LOOP_SECONDS) / FX.LOOP_SECONDS
    _ground()
    # The sprites are real existing Combat Lab actor rigs.
    for i in range(MOBS.size()):
        var p: Vector2 = MOBS[i]
        draw_circle(p + Vector2(0.0, 10.0), 24.0,
            Color(0.0, 0.0, 0.0, 0.24))
        RIG.render(self, {"id": "vfx19_mob_" + str(i),
            "side": "monster", "tier": "normal", "hp": 100.0},
            p, "fist", "idle", elapsed, 1.75, -1.0, 0.0)
    RIG.render(self,
        {"id": "vfx19_caster", "side": "disciple", "hp": 100.0},
        CASTER, "fist", "cast", elapsed, 2.08, 1.0, 0.18)
    # One unselected monster stays dim; NEVER gets any fake impact or mark.
    var p4: Vector2 = MOBS[3]
    draw_arc(p4 + Vector2(0.0, 11.0), 17.0,
        0.0, TAU, 27, Color("667386", 0.16), 1.0, true)
    if t > 0.31 and t < 0.78:
        # Micro-illumination on the actual gravel only. No AoE target ring.
        var flash := 1.0 - smoothstep(0.48, 0.78, t)
        for slot in range(3):
            var contact: Vector2 = FX.mock_contact_target(
                approved_hits, slot)
            var window := FX.impact_window(thunder_mode, slot)
            if t < window.x or t > window.y:
                continue
            var age := (t - window.x) / (window.y - window.x)
            var lit := flash * (1.0 - smoothstep(0.0, 0.93, age))
            draw_circle(contact + Vector2(0.0, 24.0), 20.0,
                Color(0.13, 0.34, 0.75, 0.050 * lit))
    draw_line(Vector2(18.0, 617.0), Vector2(1261.0, 617.0),
        Color(0.23, 0.59, 0.78, 0.11), 1.0, true)

func _ground() -> void:
    draw_rect(Rect2(0.0, 0.0, 1280.0, 720.0), Color("0a1120"))
    draw_rect(Rect2(17.0, 91.0, 1246.0, 526.0), SOIL)
    # Deterministic low-contrast soil instead of a dark UI grid.
    for lane in range(5):
        draw_rect(Rect2(17.0, 91.0 + float(lane) * 105.0,
            1246.0, 105.0), Color(0.01, 0.02, 0.03,
            0.11 + 0.016 * float(lane % 2)))
    for i in range(270):
        var k := float(i)
        var x := 21.0 + fposmod(k * 97.713 + 42.0 * sin(k * 7.7), 1234.0)
        var y := 97.0 + fposmod(k * 47.227 + 33.0 * cos(k * 8.3), 510.0)
        var radius := 0.5 + fposmod(k * 0.141, 1.0)
        draw_circle(Vector2(x, y), radius,
            Color(0.68, 0.74, 0.73, 0.052 + 0.07 * fposmod(k * 0.173, 1.0)))
