extends Control
## Original vector drawing, not a simulated producer and not a reward renderer.
## Smooth atmospheric FX only when the canonical building actually has active jobs.
var facility_kind := ""
var working := false
var phase := 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
    if not working or not visible:
        return
    phase = fmod(phase + delta*1.35,TAU)
    queue_redraw()

func _draw() -> void:
    if size.x < 10.0:
        return
    draw_set_transform(Vector2.ZERO,0.0,Vector2(size.x/250.0,size.y/150.0))
    match facility_kind:
        "mine","linh_forest","spirit_field":
            _draw_worksite_aura()
        "alchemy_hall":
            _draw_room(Color(0.045,0.10,0.17),Color(0.23,0.47,0.53))
            _draw_furnace()
        "warehouse":
            _draw_room(Color(0.10,0.13,0.14),Color(0.50,0.39,0.22))
            _draw_warehouse()
        "forge":
            _draw_room(Color(0.14,0.08,0.11),Color(0.68,0.33,0.17))
            _draw_furnace()
        "cultivation":
            _draw_room(Color(0.05,0.11,0.17),Color(0.26,0.57,0.57))
            _draw_meditation()
        "medicine":
            _draw_room(Color(0.08,0.13,0.13),Color(0.43,0.72,0.47))
            _draw_meditation()
        "ren_than_duong":
            _draw_room(Color(0.10,0.12,0.15),Color(0.67,0.45,0.26))
            _draw_meditation()
        "gate":
            _draw_room(Color(0.07,0.11,0.15),Color(0.45,0.55,0.75))
            _draw_meditation()
        _:
            _draw_worksite_aura()
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _draw_room(ground: Color, glow: Color) -> void:
    draw_rect(Rect2(0,0,250,150),ground)
    for layer in range(5):
        draw_circle(Vector2(126,68),100.0-float(layer)*18.0,Color(glow.r,glow.g,glow.b,0.025+float(layer)*0.015))
    for x in [20.0,105.0,195.0]:
        draw_line(Vector2(x,0),Vector2(x+15,150),Color(glow.r,glow.g,glow.b,0.12),2.0)
    draw_colored_polygon(PackedVector2Array([Vector2(0,120),Vector2(250,117),Vector2(250,150),Vector2(0,150)]),ground.lightened(0.10))
    draw_line(Vector2(0,120),Vector2(250,117),Color(glow.r,glow.g,glow.b,0.65),1.3)
    for index in range(9):
        var x := 11.0 + float((index*83)%230)
        var y := 9.0 + float((index*47)%100)
        draw_circle(Vector2(x,y),1.4,Color(0.9,0.86,0.70,0.38+0.20*sin(phase+float(index))))

func _draw_furnace() -> void:
    draw_rect(Rect2(48,120,154,12),Color(0.0,0.0,0.0,0.34))
    draw_colored_polygon(PackedVector2Array([Vector2(85,72),Vector2(171,72),Vector2(185,120),Vector2(69,120)]),Color(0.25,0.34,0.39))
    draw_colored_polygon(PackedVector2Array([Vector2(85,75),Vector2(171,75),Vector2(156,115),Vector2(99,115)]),Color(0.38,0.51,0.52))
    draw_arc(Vector2(128,73),45,PI,TAU,45,Color(0.96,0.77,0.43),4.0)
    draw_circle(Vector2(128,97),15,Color(0.10,0.19,0.20))
    draw_circle(Vector2(128,97),9,Color(0.88,0.52,0.29,0.85))
    for i in range(4):
        var x := 108.0 + float(i)*14.0
        var lift := 10.0*sin(phase+float(i)*0.9) if working else 0.0
        draw_circle(Vector2(x,58-lift),8.0+float(i%2)*3.0,Color(0.45,0.95,0.89,0.18 if working else 0.05))
        draw_arc(Vector2(x,62-lift),11,PI,TAU,12,Color(0.94,0.82,0.50,0.65 if working else 0.2),1.8)
    draw_line(Vector2(75,132),Vector2(179,132),Color(0.98,0.76,0.41),2.0)

func _draw_warehouse() -> void:
    for i in range(3):
        var x := 37.0+float(i)*61.0
        draw_rect(Rect2(x,52,48,65),Color(0.39,0.28,0.19))
        draw_rect(Rect2(x+4,59,40,49),Color(0.58,0.42,0.25))
        draw_line(Vector2(x+8,66),Vector2(x+39,97),Color(0.91,0.71,0.38),2.0)
        draw_line(Vector2(x+39,66),Vector2(x+8,97),Color(0.91,0.71,0.38),2.0)
        draw_circle(Vector2(x+24,84),6,Color(0.96,0.78,0.43))
    for i in range(6):
        var x := 42.0+float(i)*29.0
        draw_colored_polygon(PackedVector2Array([Vector2(x,30),Vector2(x+7,15),Vector2(x+18,27),Vector2(x+12,47)]),Color(0.31+0.04*float(i%2),0.75,0.70,0.72))
        draw_line(Vector2(x+7,15),Vector2(x+12,47),Color(0.95,0.95,0.83),1.2)
    draw_line(Vector2(19,121),Vector2(232,121),Color(0.93,0.71,0.36),2.5)

func _draw_meditation() -> void:
    for radius in [52.0,42.0,30.0]:
        draw_arc(Vector2(128,77),radius,0,TAU,60,Color(0.43,0.89,0.80,0.18),2.0)
    draw_colored_polygon(PackedVector2Array([Vector2(69,121),Vector2(86,103),Vector2(164,103),Vector2(186,121)]),Color(0.45,0.58,0.56))
    draw_circle(Vector2(128,62),16,Color(0.87,0.74,0.56))
    draw_colored_polygon(PackedVector2Array([Vector2(104,111),Vector2(116,80),Vector2(141,80),Vector2(154,111)]),Color(0.20,0.62,0.58))
    draw_line(Vector2(89,120),Vector2(169,120),Color(0.98,0.78,0.47),2.0)
    if working:
        for i in range(6):
            var angle := phase+float(i)*TAU/6.0
            draw_circle(Vector2(128,77)+Vector2(cos(angle),sin(angle))*47.0,3.0,Color(0.92,0.89,0.59,0.75))

func _draw_worksite_aura() -> void:
    if not working:
        return
    var color := Color(0.98,0.77,0.40,0.70) if facility_kind == "mine" else (Color(0.56,0.92,0.73,0.70) if facility_kind == "linh_forest" else Color(0.67,0.85,0.99,0.70))
    for i in range(13):
        var x := 24.0+float((i*57)%197)
        var y := 24.0+float((i*39)%98)-6.0*sin(phase+float(i))
        draw_circle(Vector2(x,y),1.6+float(i%3),color)
    draw_arc(Vector2(125,85),66,phase,phase+1.15,26,Color(color.r,color.g,color.b,0.55),2.0)
