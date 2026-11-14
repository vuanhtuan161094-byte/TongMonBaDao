extends RefCounted
## VIS-11: individually drawn 2D A and B views from owner's approved
## 2026-11-14 building sheet, not flipped Source A pixels or skeletal rigs.
## All six type pairs retain their native map rectangles.
const ROOT := "res://art/tmb_buildings_ab_v7/"
const TARGET_SIZE := {
    "main_hall": Vector2i(300,201),
    "mine": Vector2i(166,121),
    "residence": Vector2i(174,135),
    "warehouse": Vector2i(162,138),
    "forge": Vector2i(205,164),
    "guidance": Vector2i(182,203)
}
const HALL_A: Texture2D = preload("res://art/tmb_buildings_ab_v7/hall_A.png")
const HALL_B: Texture2D = preload("res://art/tmb_buildings_ab_v7/hall_B.png")
const MINE_A: Texture2D = preload("res://art/tmb_buildings_ab_v7/mine_A.png")
const MINE_B: Texture2D = preload("res://art/tmb_buildings_ab_v7/mine_B.png")
const RESIDENCE_A: Texture2D = preload("res://art/tmb_buildings_ab_v7/residence_A.png")
const RESIDENCE_B: Texture2D = preload("res://art/tmb_buildings_ab_v7/residence_B.png")
const WAREHOUSE_A: Texture2D = preload("res://art/tmb_buildings_ab_v7/warehouse_A.png")
const WAREHOUSE_B: Texture2D = preload("res://art/tmb_buildings_ab_v7/warehouse_B.png")
const FORGE_A: Texture2D = preload("res://art/tmb_buildings_ab_v7/forge_A.png")
const FORGE_B: Texture2D = preload("res://art/tmb_buildings_ab_v7/forge_B.png")
const GUIDANCE_A: Texture2D = preload("res://art/tmb_buildings_ab_v7/guidance_A.png")
const GUIDANCE_B: Texture2D = preload("res://art/tmb_buildings_ab_v7/guidance_B.png")

static func texture_for(kind: StringName,direction: StringName = &"A") -> Texture2D:
    var view := str(direction).to_upper()
    if view not in ["A","B"]:
        return null
    match str(kind):
        "hall","main_hall":
            return HALL_B if view == "B" else HALL_A
        "mine":
            return MINE_B if view == "B" else MINE_A
        "residence":
            return RESIDENCE_B if view == "B" else RESIDENCE_A
        "warehouse":
            return WAREHOUSE_B if view == "B" else WAREHOUSE_A
        "forge":
            return FORGE_B if view == "B" else FORGE_A
        "guidance":
            return GUIDANCE_B if view == "B" else GUIDANCE_A
    return null

static func size_for(kind: StringName) -> Vector2i:
    var key := "main_hall" if str(kind) == "hall" else str(kind)
    return TARGET_SIZE.get(key,Vector2i.ZERO)

static func all_paths() -> Array[String]:
    var result: Array[String] = []
    for kind in ["hall","mine","residence","warehouse","forge","guidance"]:
        for side in ["A","B"]:
            result.append(ROOT + kind + "_" + side + ".png")
    return result
