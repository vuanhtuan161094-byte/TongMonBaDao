class_name SectMapD2Landscape
extends RefCounted

# MAP-D2: presentation-only palette and scenery. No tile placement, nav,
# worker action, resource yield or saved state is created by this helper.
# All details are ORIGINAL UNAPPROVED CANDIDATES, never Source A masters.
const SCENIC_ACCENTS := [
    {"cell":Vector2i(110,108),"kind":"pond"},
    {"cell":Vector2i(105,111),"kind":"reeds"},
    {"cell":Vector2i(77,109),"kind":"flowers"},
    {"cell":Vector2i(80,113),"kind":"flowers"},
    {"cell":Vector2i(91,79),"kind":"flowers"},
    {"cell":Vector2i(100,108),"kind":"stone"},
    {"cell":Vector2i(76,85),"kind":"stone"}
]


static func ground_color(cell: Vector2i, starter: Rect2i, roads: Dictionary) -> Color:
    var within := starter.has_point(cell)
    # Broad coherent landforms, rather than independently alternating
    # green tiles (the prior renderer's highly visible checkerboard).
    var slow := sin(float(cell.x)*0.18+float(cell.y)*0.11)*0.5
    slow += cos(float(cell.y)*0.16-float(cell.x)*0.09)*0.30
    var tint := clampf(slow*0.045,-0.05,0.05)
    var ground := Color(0.285+tint,0.405+tint,0.330+tint*0.7)
    if not within:
        return ground.darkened(0.07)
    ground = Color(0.37+tint,0.49+tint,0.38+tint*0.75)
    # A subdued natural forest shoulder and warmer service/work district;
    # these are world *visuals*, not a district-unlock or terrain authority.
    if cell.x < 84 and cell.y >= 100:
        ground = ground.blend(Color(0.31,0.47,0.36,0.44))
    elif cell.x >= 94 and cell.y >= 88:
        ground = ground.blend(Color(0.49,0.48,0.37,0.26))
    elif cell.y < 88:
        ground = ground.blend(Color(0.40,0.49,0.39,0.20))
    # A recognizable courtyard silhouette beneath the verified Main Hall.
    if cell.x >= 84 and cell.x <= 92 and cell.y >= 91 and cell.y <= 98:
        ground = ground.blend(Color(0.61,0.63,0.54,0.56))
    if roads.has(cell):
        ground = ground.blend(Color(0.64,0.60,0.48,0.62))
    return ground


static func road_shoulder_color(cell: Vector2i) -> Color:
    var noise := sin(float(cell.x)*0.41+float(cell.y)*0.32)
    return Color(0.51+noise*0.02,0.49+noise*0.02,0.39,0.46)


static func draw_scenic_accents(world: Node2D, active_chunks: Array[Vector2i]) -> void:
    for row in SCENIC_ACCENTS:
        var cell: Vector2i = row["cell"]
        var chunk := Vector2i(floori(float(cell.x)/16.0),floori(float(cell.y)/16.0))
        if chunk not in active_chunks:
            continue
        var point := SectIsometricWorldV1.project(Vector2(cell))
        if not world._visible_world(point):
            continue
        match str(row["kind"]):
            "pond":
                _draw_pond(world,point)
            "reeds":
                _draw_reeds(world,point)
            "flowers":
                _draw_flowers(world,point)
            "stone":
                _draw_stones(world,point)


static func _draw_pond(world: Node2D, p: Vector2) -> void:
    # Tiny scenic pond only: no water source, resource/node or swim collision.
    var outer := PackedVector2Array([
        p+Vector2(-108,0),p+Vector2(-75,-24),p+Vector2(-15,-34),
        p+Vector2(60,-23),p+Vector2(98,-7),p+Vector2(112,12),
        p+Vector2(49,29),p+Vector2(-34,33)
    ])
    var inner := PackedVector2Array([
        p+Vector2(-88,0),p+Vector2(-54,-17),p+Vector2(-10,-25),
        p+Vector2(50,-17),p+Vector2(91,-4),p+Vector2(90,10),
        p+Vector2(38,20),p+Vector2(-27,24)
    ])
    world.draw_colored_polygon(outer,Color(0.45,0.51,0.43,0.91))
    world.draw_colored_polygon(inner,Color(0.30,0.51,0.49,0.94))
    world.draw_polyline(outer,Color(0.65,0.66,0.55,0.83),2.0,true)
    for shift in [-1.0,1.0]:
        world.draw_line(p+Vector2(-39+shift*8,-4),p+Vector2(18+shift*8,-10),Color(0.64,0.79,0.72,0.35),2.0,true)
    world.draw_line(p+Vector2(5,13),p+Vector2(42,11),Color(0.80,0.84,0.69,0.33),1.8,true)


static func _draw_reeds(world: Node2D, p: Vector2) -> void:
    for x in [-18.0,-6.0,9.0,21.0]:
        world.draw_line(p+Vector2(x,7),p+Vector2(x-5,-22),Color(0.39,0.54,0.34,0.8),2.0,true)
        world.draw_line(p+Vector2(x,-5),p+Vector2(x+7,-16),Color(0.62,0.70,0.43,0.78),1.6,true)


static func _draw_flowers(world: Node2D, p: Vector2) -> void:
    for dx in [-19.0,-4.0,14.0]:
        var center := p+Vector2(dx,2.0+sin(dx)*4.0)
        world.draw_line(center+Vector2(0,5),center+Vector2(0,-8),Color(0.33,0.52,0.35,0.7),1.7,true)
        for q in [Vector2(-3,0),Vector2(3,0),Vector2(0,-3),Vector2(0,3)]:
            world.draw_circle(center+Vector2(0,-8)+q,2.5,Color(0.88,0.72,0.72,0.78))
        world.draw_circle(center+Vector2(0,-8),2.3,Color(0.85,0.78,0.45,0.9))


static func _draw_stones(world: Node2D, p: Vector2) -> void:
    for offset in [Vector2(-14,0),Vector2(8,-4),Vector2(21,4)]:
        var stone := PackedVector2Array([
            p+offset+Vector2(-13,5),p+offset+Vector2(-7,-7),
            p+offset+Vector2(4,-11),p+offset+Vector2(13,3),
            p+offset+Vector2(7,9)
        ])
        world.draw_colored_polygon(stone,Color(0.54,0.62,0.57,0.79))
        world.draw_line(stone[1],stone[2],Color(0.73,0.77,0.67,0.60),1.5,true)
