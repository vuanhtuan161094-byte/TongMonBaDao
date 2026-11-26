class_name SectMapD2Landscape
extends RefCounted

# MAP-D2: presentation-only palette and scenery. No tile placement, nav,
# worker action, resource yield or saved state is created by this helper.
# All details are ORIGINAL UNAPPROVED CANDIDATES, never Source A masters.
const SCENIC_SPRITES := {
    "pond":preload("res://art/map_d2_candidate/scenery_v2/lotus_pond.svg"),
    "reeds":preload("res://art/map_d2_candidate/scenery_v2/reeds.svg"),
    "flowers":preload("res://art/map_d2_candidate/scenery_v2/flowers.svg"),
    "stone":preload("res://art/map_d2_candidate/scenery_v2/moss_stones.svg"),
    "lantern":preload("res://art/map_d2_candidate/scenery_v2/jade_lantern.svg"),
    "stele":preload("res://art/map_d2_candidate/scenery_v6r/stone_stele.svg"),
    "bamboo":preload("res://art/map_d2_candidate/scenery_v6r/bamboo_water_garden.svg"),
    "plum":preload("res://art/map_d2_candidate/scenery_v9/plum_terrace.svg")
}
const SCENIC_ACCENTS := [
    {"cell":Vector2i(110,108),"kind":"pond"},
    {"cell":Vector2i(105,111),"kind":"bamboo"},
    {"cell":Vector2i(77,109),"kind":"flowers"},
    {"cell":Vector2i(80,113),"kind":"plum"},
    {"cell":Vector2i(91,79),"kind":"lantern"},
    {"cell":Vector2i(100,108),"kind":"stone"},
    {"cell":Vector2i(76,85),"kind":"stele"}
]


static func ground_color(cell: Vector2i, starter: Rect2i, roads: Dictionary, layout_version: int = 0) -> Color:
    var within := starter.has_point(cell)
    # Broad coherent landforms, rather than independently alternating
    # green tiles (the prior renderer's highly visible checkerboard).
    var slow := sin(float(cell.x)*0.18+float(cell.y)*0.11)*0.5
    slow += cos(float(cell.y)*0.16-float(cell.x)*0.09)*0.30
    var ridge := sin(float(cell.x)*0.075-float(cell.y)*0.057)*0.5+cos(float(cell.y)*0.09)*0.5
    var tint := clampf(slow*0.038+ridge*0.038,-0.07,0.07)
    var ground := Color(0.245+tint,0.365+tint,0.285+tint*0.7)
    if not within:
        return ground.darkened(0.025)
    var edge_distance := minf(minf(float(cell.x-starter.position.x),float(starter.end.x-1-cell.x)),minf(float(cell.y-starter.position.y),float(starter.end.y-1-cell.y)))
    var interior := smoothstep(0.0,8.0,edge_distance)
    ground = ground.lerp(Color(0.37+tint,0.50+tint,0.35+tint*0.75),interior)
    # Broad falloffs instead of the visibly rectangular district bands.
    # Only ground material changes; the masterplan remains authoritative.
    if layout_version >= 2:
        var point := Vector2(cell)
        var residence := (1.0-smoothstep(4.0,14.0,point.distance_to(Vector2(80,101))))*interior
        var cultivation := (1.0-smoothstep(4.0,13.0,point.distance_to(Vector2(88,82))))*interior
        var production := (1.0-smoothstep(5.0,16.0,point.distance_to(Vector2(103,94))))*interior
        var civic := (1.0-smoothstep(3.0,12.0,point.distance_to(Vector2(89,96))))*interior
        ground = ground.lerp(Color(0.35,0.53,0.37),residence*0.45)
        ground = ground.lerp(Color(0.32,0.48,0.45),cultivation*0.38)
        ground = ground.lerp(Color(0.52,0.49,0.34),production*0.43)
        ground = ground.lerp(Color(0.54,0.55,0.40),civic*0.30)
    elif cell.x < 84 and cell.y >= 100:
        ground = ground.blend(Color(0.31,0.47,0.36,0.44))
    elif cell.x >= 94 and cell.y >= 88:
        ground = ground.blend(Color(0.49,0.48,0.37,0.26))
    elif cell.y < 88:
        ground = ground.blend(Color(0.40,0.49,0.39,0.20))
    # A recognizable courtyard silhouette beneath the verified Main Hall.
    var court_weight := 1.0-smoothstep(2.0,6.5,Vector2(cell).distance_to(Vector2(88.5,95.5)))
    ground = ground.lerp(Color(0.61,0.63,0.54),court_weight*0.42)
    if roads.has(cell):
        ground = ground.blend(Color(0.64,0.60,0.48,0.62))
    return ground


static func road_shoulder_color(cell: Vector2i) -> Color:
    var noise := sin(float(cell.x)*0.41+float(cell.y)*0.32)
    return Color(0.51+noise*0.02,0.49+noise*0.02,0.39,0.46)


static func draw_scenic_accents(world: Node2D, active_chunks: Array[Vector2i], camera_center: Vector2, half_view: Vector2) -> void:
    for row in SCENIC_ACCENTS:
        var cell: Vector2i = row["cell"]
        var chunk := Vector2i(floori(float(cell.x)/16.0),floori(float(cell.y)/16.0))
        if chunk not in active_chunks:
            continue
        var point := Vector2(float(cell.x-cell.y)*25.0,float(cell.x+cell.y)*13.0)
        # Avoid calling an undeclared private method on generic Node2D.
        var distance := (point-camera_center).abs()
        if distance.x > half_view.x or distance.y > half_view.y:
            continue
        var kind := str(row["kind"])
        var texture := SCENIC_SPRITES.get(kind) as Texture2D
        if texture == null:
            continue
        var size := texture.get_size()
        # Sprite-only scenery at the original authored map positions and scale.
        # No collision, resources, buildings or navigation changes.
        var extent := size * (0.90 if kind == "pond" else 0.74)
        # Tall lantern artwork includes a base at the bottom of the image.
        # Ground it at the tile foot instead of burying its base across adjacent tiles.
        var foot_ratio := 0.94 if kind in ["lantern","stele","bamboo","plum"] else 0.72
        var anchor := Vector2(extent.x*0.5,extent.y*foot_ratio)
        world.draw_texture_rect(texture,Rect2(point-anchor,extent),false)


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
