extends Control
## ART-06: harmless animated atmosphere. Only canonical active jobs produce stronger sparks.
var accent := Color(0.45,0.9,0.73,1.0)
var job_active := false
var elapsed := 0.0
var accumulated := 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process(false)
    queue_redraw()

func set_activity(is_active: bool) -> void:
    if job_active == is_active:
        return
    job_active = is_active
    set_process(job_active)
    queue_redraw()

func _process(delta: float) -> void:
    if not visible:
        return
    elapsed = fmod(elapsed+delta,100.0)
    accumulated += delta
    if accumulated >= 0.13:
        accumulated = 0.0
        queue_redraw()

func _draw() -> void:
    if size.x < 100 or size.y < 100:
        return
    var w := size.x
    var h := size.y
    for band in range(6):
        var y := float(band)*h/6.0
        draw_rect(Rect2(0,y,w,h/6.0+1.0),Color(0.04,0.10,0.13,0.025+float(band)*0.001))
    for i in range(23):
        var x := fmod(33.0+float((i*71)%389)+elapsed*(2.0+float(i%4)),w)
        var y := fmod(31.0+float((i*101)%527)-elapsed*(1.7+float(i%3))+h*4.0,h)
        var pulse := 0.5+0.5*sin(elapsed*1.4+float(i)*0.74)
        var alpha := 0.18+0.28*pulse
        if i%6 == 0:
            var pink := Color(1.0,0.66,0.87,0.23+0.26*pulse)
            var corners := PackedVector2Array([
                Vector2(x-5,y),Vector2(x,y-2.8),
                Vector2(x+6,y+1.2),Vector2(x+1.0,y+4)
            ])
            draw_colored_polygon(corners,pink)
        else:
            draw_circle(Vector2(x,y),2.0+float(i%3),Color(accent.r,accent.g,accent.b,alpha*0.16))
            draw_circle(Vector2(x,y),0.8+float(i%2)*0.5,Color(0.92,0.98,0.91,alpha))
    if job_active:
        for i in range(10):
            var x := 35.0+float(i)*31.0
            var y := 190.0+float((i*83)%245)-fmod(elapsed*14.0+float(i*12),65.0)
            draw_circle(Vector2(x,y),2.0+float(i%3),Color(accent.r,accent.g,accent.b,0.55))
        var center := Vector2(w*0.52,h*0.5)
        draw_arc(center,92.0,elapsed*0.5,elapsed*0.5+1.4,32,Color(accent.r,accent.g,accent.b,0.22),1.6,true)
