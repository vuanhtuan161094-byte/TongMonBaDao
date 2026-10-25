class_name B3CareHuntLandscapeV2
extends RefCounted

# A strictly visual landscape supplement for the real CARE MapBattleV2 arena.
# Uses existing screen projection; creates NO navigation, barriers, spawns,
# combat zones, encounter rewards, clock, saved map state or actor motion.
# Do not call this an implementation of the future 20-camp / 200-monster map.
# Colors are ORIGINAL S4 presentation candidates, not Source A artwork.
const PATCHES := [
    {"at":Vector2(4.0,3.4),"radius":Vector2(4.0,2.7),"color":Color(0.23,0.40,0.31,0.22)},
    {"at":Vector2(9.0,17.4),"radius":Vector2(5.5,2.9),"color":Color(0.30,0.46,0.32,0.27)},
    {"at":Vector2(29.6,3.0),"radius":Vector2(5.6,2.8),"color":Color(0.32,0.44,0.33,0.31)},
    {"at":Vector2(32.0,16.5),"radius":Vector2(4.4,2.5),"color":Color(0.29,0.42,0.31,0.27)},
    {"at":Vector2(18.0,16.5),"radius":Vector2(6.4,2.4),"color":Color(0.47,0.44,0.33,0.17)},
    {"at":Vector2(17.4,3.0),"radius":Vector2(6.0,2.2),"color":Color(0.38,0.47,0.36,0.22)}
]
const BRUSH_STROKES := [
    {"at":Vector2(5.0,4.8),"radius":Vector2(0.9,0.35)},
    {"at":Vector2(8.0,16.0),"radius":Vector2(1.5,0.46)},
    {"at":Vector2(13.0,2.1),"radius":Vector2(1.1,0.40)},
    {"at":Vector2(22.7,17.0),"radius":Vector2(1.2,0.42)},
    {"at":Vector2(30.4,5.1),"radius":Vector2(1.4,0.36)},
    {"at":Vector2(34.2,14.6),"radius":Vector2(1.1,0.43)}
]
const EDGE_GRASS := [
    Vector2(2.2,2.8),Vector2(5.0,18.0),Vector2(7.6,1.8),
    Vector2(9.6,17.4),Vector2(12.4,2.5),Vector2(16.5,18.7),
    Vector2(19.2,1.9),Vector2(22.3,17.9),Vector2(26.3,1.9),
    Vector2(30.1,18.2),Vector2(33.8,3.2),Vector2(34.2,16.8)
]


static func valid_layout(grid_size: Vector2) -> bool:
    if grid_size.x <= 0.0 or grid_size.y <= 0.0:
        return false
    for patch in PATCHES:
        var center: Vector2 = patch["at"]
        var radius: Vector2 = patch["radius"]
        if radius.x <= 0.0 or radius.y <= 0.0:
            return false
        if center.x < 0.0 or center.y < 0.0 or center.x >= grid_size.x or center.y >= grid_size.y:
            return false
    for cell in EDGE_GRASS:
        if cell.x < 0.0 or cell.y < 0.0 or cell.x >= grid_size.x or cell.y >= grid_size.y:
            return false
    return true


static func draw_hunt_floor(target: Node2D, viewport: Rect2,
        grid: Vector2, logical_to_screen: Callable, zoom: float) -> void:
    if not valid_layout(grid) or not logical_to_screen.is_valid() or zoom <= 0.0:
        return
    # The projection is exactly the existing battle presenter's projection:
    # all accents pan and zoom together with the real actor feet. At all times
    # the whole battle stays walkable according to MapBattleV2, not this art.
    var screen_units := viewport.size/grid*zoom
    for patch in PATCHES:
        var p: Vector2 = logical_to_screen.call(patch["at"])
        var radius: Vector2 = patch["radius"]*screen_units
        if not viewport.grow(maxf(radius.x,radius.y)).has_point(p):
            continue
        target.draw_set_transform(p,0.0,radius)
        target.draw_circle(Vector2.ZERO,1.0,patch["color"])
        target.draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

    # Lightly worn clearings are visual texture only, NOT simulated paths or
    # collision obstacles; keep central fight and AoE telegraphs readable.
    for brush in BRUSH_STROKES:
        var p: Vector2 = logical_to_screen.call(brush["at"])
        var radius: Vector2 = brush["radius"]*screen_units
        if not viewport.grow(80.0).has_point(p):
            continue
        target.draw_set_transform(p,0.0,radius)
        target.draw_circle(Vector2.ZERO,1.0,Color(0.64,0.59,0.45,0.12))
        target.draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

    for cell in EDGE_GRASS:
        var foot: Vector2 = logical_to_screen.call(cell)
        if not viewport.has_point(foot):
            continue
        var scale := clampf(zoom,0.75,2.25)
        for offset in [-6.0,0.0,7.0]:
            var ground := foot+Vector2(offset*scale,0.0)
            var tip := ground+Vector2((offset+4.0)*0.15*scale,-(9.0+absf(offset)*0.3)*scale)
            target.draw_line(ground,tip,Color(0.31,0.51,0.36,0.40),1.5*scale,true)
        target.draw_line(foot+Vector2(-5.0*scale,-3.0*scale),
            foot+Vector2(6.0*scale,-6.0*scale),
            Color(0.66,0.72,0.47,0.23),1.1*scale,true)
