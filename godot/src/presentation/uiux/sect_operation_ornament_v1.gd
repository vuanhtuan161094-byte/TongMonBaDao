extends Control
## ART-04: original vector cultivation frame; no gameplay ownership.
## Drawn below interactive controls; 1280×720 landscape layout uses 1184×552 panel.
var facility_kind := ""

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func _tone() -> Color:
    match facility_kind:
        "mine": return Color(0.78,0.53,0.24)
        "linh_forest": return Color(0.30,0.63,0.43)
        "spirit_field": return Color(0.30,0.59,0.70)
        "alchemy_hall": return Color(0.59,0.44,0.77)
        "warehouse": return Color(0.74,0.59,0.28)
        "cultivation": return Color(0.40,0.65,0.61)
        "medicine": return Color(0.46,0.67,0.48)
        "forge": return Color(0.76,0.40,0.28)
        _: return Color(0.62,0.48,0.28)

func _draw() -> void:
    var w := size.x
    var h := size.y
    if w < 100.0 or h < 100.0:
        return
    var accent := _tone()
    var gold := Color(0.78,0.61,0.32,0.90)
    draw_rect(Rect2(4,4,w-8,h-8),Color(accent.r,accent.g,accent.b,0.60),false,1.8,true)
    draw_rect(Rect2(10,9,w-20,h-18),Color(0.74,0.62,0.40,0.28),false,1.0,true)
    draw_rect(Rect2(12,7,w-24,57),Color(accent.r,accent.g,accent.b,0.075))
    draw_line(Vector2(18,70),Vector2(w-18,70),gold,2.0,true)
    draw_line(Vector2(18,73),Vector2(w-18,73),Color(accent.r,accent.g,accent.b,0.34),1.0,true)
    draw_line(Vector2(18,304),Vector2(w-18,304),Color(accent.r,accent.g,accent.b,0.42),1.5,true)
    draw_line(Vector2(20,535),Vector2(w-20,535),Color(accent.r,accent.g,accent.b,0.25),1.0,true)
    draw_line(Vector2(544,321),Vector2(544,529),Color(accent.r,accent.g,accent.b,0.36),1.3,true)
    for corner in [Vector2(22,24),Vector2(w-22,24),Vector2(22,h-23),Vector2(w-22,h-23)]:
        draw_arc(corner,9,0,TAU,28,Color(accent.r,accent.g,accent.b,0.57),1.4,true)
        draw_circle(corner,2.8,Color(0.93,0.77,0.48,0.96))
    for i in range(8):
        var x := 800.0+float(i)*37.0
        if x > w-80.0:
            break
        var y := 40.0+4.0*sin(float(i)*1.3)
        draw_colored_polygon(PackedVector2Array([
            Vector2(x-5,y),Vector2(x,y-9),Vector2(x+5,y),Vector2(x,y+9)
        ]),Color(accent.r,accent.g,accent.b,0.19))
        draw_circle(Vector2(x,y),1.3,Color(0.95,0.81,0.53,0.74))
    for x in [282.0,547.0]:
        draw_line(Vector2(x,153),Vector2(x,296),Color(accent.r,accent.g,accent.b,0.18),1.0)
    for i in range(4):
        var x := 20.0+float(i)*8.0
        draw_line(Vector2(x,63),Vector2(x+10,51),Color(accent.r,accent.g,accent.b,0.24),1.0,true)
        draw_line(Vector2(w-x,63),Vector2(w-x-10,51),Color(accent.r,accent.g,accent.b,0.24),1.0,true)
