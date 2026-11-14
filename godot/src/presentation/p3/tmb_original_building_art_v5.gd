extends RefCounted
## VIS-08 — Independently generated TMB building sprites, NOT Source A pixels.
## These 5 RGBA PNGs belong to one coherent generated art-sheet family.
## VIS-07 R4 owner-approved mine art stays separate; V3 12 variants unchanged.
const ROOT := "res://art/tmb_original_buildings_v5/"
const HALL: Texture2D = preload("res://art/tmb_original_buildings_v5/hall_original_1x.png")
const RESIDENCE: Texture2D = preload("res://art/tmb_original_buildings_v5/residence_original_1x.png")
const WAREHOUSE: Texture2D = preload("res://art/tmb_original_buildings_v5/warehouse_original_1x.png")
const FORGE: Texture2D = preload("res://art/tmb_original_buildings_v5/forge_original_1x.png")
const GUIDANCE: Texture2D = preload("res://art/tmb_original_buildings_v5/guidance_original_1x.png")
const SIZES := {
    "main_hall": Vector2i(300,201),
    "residence": Vector2i(174,135),
    "warehouse": Vector2i(162,138),
    "forge": Vector2i(205,164),
    "guidance": Vector2i(182,203)
}

static func texture_for(kind: StringName) -> Texture2D:
    match str(kind):
        "hall", "main_hall": return HALL
        "residence": return RESIDENCE
        "warehouse": return WAREHOUSE
        "forge": return FORGE
        "guidance": return GUIDANCE
    return null

static func is_original_building(kind: StringName) -> bool:
    return texture_for(kind) != null
