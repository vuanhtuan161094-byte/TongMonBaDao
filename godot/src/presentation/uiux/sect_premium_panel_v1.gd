extends Control
## ART-05 screen-scaled original code-art filigree. Draw-only, mouse ignores events.
var accent := Color(0.9,0.78,0.42)
var _phase := 0.0
var _redraw_accum := 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process(true)

func _process(delta: float) -> void:
    if not is_visible_in_tree():
        return
    _phase = fmod(_phase+delta*0.43,TAU)
    _redraw_accum += delta
    if _redraw_accum >= 0.12:
        _redraw_accum = 0.0
        queue_redraw()

func _draw() -> void:
    var w := size.x
    var h := size.y
    if w < 200 or h < 200:
        return
    var edge := Color(accent.r,accent.g,accent.b,0.78)
    # A subtle area-color glow extends behind the illustration, never obscures labels.
    for strip in range(20):
        var k := float(strip)/19.0
        draw_rect(Rect2(14,144+float(strip)*7.4,w-28,7.5),
            Color(accent.r,accent.g,accent.b,(1.0-k)*0.035))
    for i in range(18):
        var x := 38.0+float((i*71)%233)
        var y := 160.0+float((i*47)%125)+3.0*sin(_phase*2.0+float(i))
        var alpha := 0.18+0.16*(0.5+0.5*sin(_phase*2.0+float(i)*0.7))
        draw_circle(Vector2(x,y),1.3+float(i%3)*0.65,
            Color(accent.r,accent.g,accent.b,alpha))
    draw_rect(Rect2(7,7,w-14,h-14),Color(accent.r,accent.g,accent.b,0.23),false,1.0,true)
    draw_rect(Rect2(10,10,w-20,h-20),Color(0.91,0.75,0.43,0.14),false,1.0,true)
    draw_line(Vector2(17,62),Vector2(w-17,62),edge,2.0,true)
    draw_line(Vector2(17,140),Vector2(w-17,140),Color(accent.r,accent.g,accent.b,0.48),1.1,true)
    draw_line(Vector2(17,307),Vector2(w-17,307),Color(accent.r,accent.g,accent.b,0.55),1.1,true)
    draw_line(Vector2(393,318),Vector2(393,h-17),Color(accent.r,accent.g,accent.b,0.40),1.0,true)
    var corners := [Vector2(20,20),Vector2(w-20,20),Vector2(20,h-20),Vector2(w-20,h-20)]
    for c in corners:
        draw_arc(c,11,0,TAU,24,Color(accent.r,accent.g,accent.b,0.55),1.5,true)
        draw_circle(c,3.5,Color(1.0,0.84,0.52,0.84))
        draw_circle(c,6.0,Color(0.98,0.81,0.44,0.24))
    for i in range(9):
        var x := w-335.0+float(i)*27.0
        var y := 31.0+1.8*sin(_phase+float(i)*0.8)
        draw_colored_polygon(PackedVector2Array([
            Vector2(x-5,y),Vector2(x,y-10),Vector2(x+5,y),Vector2(x,y+10)
        ]),Color(accent.r,accent.g,accent.b,0.16))
        draw_circle(Vector2(x,y),1.4,Color(1,0.84,0.5,0.55))
    for i in range(4):
        var x := 29.0+float(i)*13.0
        draw_arc(Vector2(x,305),6.5,PI,TAU,12,Color(accent.r,accent.g,accent.b,0.37),1.5,true)
        draw_arc(Vector2(w-x,305),6.5,0,PI,12,Color(accent.r,accent.g,accent.b,0.37),1.5,true)
