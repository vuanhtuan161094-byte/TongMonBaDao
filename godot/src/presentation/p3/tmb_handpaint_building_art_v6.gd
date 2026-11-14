extends RefCounted
## VIS-09: original 2D handpainted map sprite candidates, independent from Source A.
## Exact art: generated Hall/Mine from user-accepted 2026-11-14 style pass;
## composed at native map pixel dimensions with transparency, no scene/UI bake.
const ROOT := "res://art/tmb_handpaint_v6/"
const HALL_PATH := ROOT + "hall_handpaint_v6_300x201.png"
const MINE_PATH := ROOT + "mine_handpaint_v6_166x121.png"
const HALL: Texture2D = preload("res://art/tmb_handpaint_v6/hall_handpaint_v6_300x201.png")
const MINE: Texture2D = preload("res://art/tmb_handpaint_v6/mine_handpaint_v6_166x121.png")
const HALL_SIZE := Vector2i(300,201)
const MINE_SIZE := Vector2i(166,121)

static func texture_for(kind: StringName) -> Texture2D:
    var tex: Texture2D = null
    var expected := Vector2i.ZERO
    match str(kind):
        "hall", "main_hall":
            tex = HALL
            expected = HALL_SIZE
        "mine":
            tex = MINE
            expected = MINE_SIZE
    if tex == null or Vector2i(tex.get_width(),tex.get_height()) != expected:
        return null
    return tex
