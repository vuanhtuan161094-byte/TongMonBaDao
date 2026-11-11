extends Control
## ART-03: atmospheric production flow only; warehouse receipt flare triggered from
## canonical show_delivered(amount) after accepted settlement.
var working := false
var tint := Color(0.40,0.85,0.73,1.0)
var elapsed := 0.0
var receipt_flash := 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process(false)

func set_activity(is_working: bool, color: Color) -> void:
    working = is_working
    tint = color
    set_process(working or receipt_flash > 0.0)
    queue_redraw()

func show_receipt_burst() -> void:
    receipt_flash = 1.0
    set_process(true)
    queue_redraw()

func _process(delta: float) -> void:
    elapsed = fmod(elapsed+delta,100.0)
    receipt_flash = maxf(0.0,receipt_flash-delta/1.0)
    if not working and receipt_flash <= 0.0:
        set_process(false)
    queue_redraw()

func _draw() -> void:
    if working:
        for i in range(10):
            var x := 12.0+float((i*41)%178)
            var lift := fmod(elapsed*13.0+float(i*17),57.0)
            var y := 87.0-lift
            var fade := clampf((57.0-lift)/57.0,0.0,1.0)*0.42
            var color := Color(tint.r,tint.g,tint.b,fade)
            draw_circle(Vector2(x,y),2.8+float(i%3),Color(tint.r,tint.g,tint.b,fade*0.19))
            draw_circle(Vector2(x,y),0.9+float(i%2),color)
        var track_x := 9.0+fmod(elapsed*28.0,143.0)
        draw_line(Vector2(track_x,99),Vector2(minf(track_x+17.0,158.0),99),Color(tint.r,tint.g,tint.b,0.48),1.0)
    if receipt_flash > 0.0:
        var center := Vector2(99,-10)
        for i in range(12):
            var angle := float(i)*TAU/12.0
            var distance := (1.0-receipt_flash)*42.0
            var offset := Vector2(cos(angle),sin(angle))*distance
            draw_circle(center+offset,1.8+receipt_flash*1.8,Color(1.0,0.86,0.48,receipt_flash*0.85))
