extends Control
## VIS-02 original sparse stardust, edge-bound and capped at 8 redraws/s.
## This is a decoration over source artwork, never a replacement texture.
var motion_enabled: bool = true
var _clock := 0.0
var _redraw_time := 0.0
const COLORS := [
    Color(0.69, 0.93, 0.88), Color(0.94, 0.83, 0.67),
    Color(0.83, 0.73, 1.0), Color(0.74, 0.88, 1.0)
]

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process(true)

func _process(delta: float) -> void:
    if not visible or not motion_enabled:
        return
    _clock = fmod(_clock + delta * 0.018, 1.0)
    _redraw_time += delta
    if _redraw_time >= 0.125:
        _redraw_time = 0.0
        queue_redraw()

func _draw() -> void:
    if size.x < 40.0 or size.y < 40.0:
        return
    var w := size.x - 8.0
    var h := size.y - 8.0
    var perimeter := 2.0 * (w + h)
    for i in range(7):
        var phase := fposmod(float(i) * 0.381966 + _clock, 1.0)
        var distance := phase * perimeter
        var position: Vector2
        if distance < w:
            position = Vector2(distance, 0.0)
        elif distance < w + h:
            position = Vector2(w, distance - w)
        elif distance < w * 2.0 + h:
            position = Vector2(w - (distance - w - h), h)
        else:
            position = Vector2(0.0, h - (distance - 2.0 * w - h))
        position += Vector2(4,4)
        var alpha := 0.24 + 0.25 * (0.5 + 0.5 * sin(float(i) * 2.5 + _clock * 14.0))
        var tint: Color = COLORS[i % COLORS.size()]
        tint.a = alpha
        draw_circle(position, 1.1 if i % 2 == 0 else 1.55, tint)
        if i % 3 == 0:
            tint.a *= 0.45
            draw_line(position + Vector2(-3.0, 0.0), position + Vector2(3.0,0.0), tint, 0.75, true)
            draw_line(position + Vector2(0.0,-3.0), position + Vector2(0.0,3.0), tint, 0.75, true)
