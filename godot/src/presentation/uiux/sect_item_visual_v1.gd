extends RefCounted
## ART-01 original code-drawn SVG item atlas, presentation only.
const ATLAS: Texture2D = preload("res://art/uiux/items/art01_resource_atlas.svg")
const CELLS := {
    "thanh_thiet":Vector2i(0,0),
    "ore_r01_c2":Vector2i(1,0),
    "huyen_thiet":Vector2i(2,0),
    "ore_r02_c2":Vector2i(3,0),
    "linh_moc":Vector2i(0,1),
    "forest_r01_wood2":Vector2i(1,1),
    "forest_r02_wood":Vector2i(2,1),
    "forest_r02_wood2":Vector2i(3,1),
    "thanh_linh_thao":Vector2i(0,2),
    "tu_van_thao":Vector2i(1,2),
    "linh_coc":Vector2i(2,2),
    "hoi_xuan_dan":Vector2i(3,2),
    "tu_khi_dan":Vector2i(0,3),
    "linh_tuy":Vector2i(1,3),
    "yeu_dan":Vector2i(2,3),
    "tinh_lang_bi":Vector2i(3,3),
    "linh_tuyen_chi_tam":Vector2i(0,4),
    "spirit_stone":Vector2i(1,4),
    "generic_resource":Vector2i(2,4)
}
static func cell_for(resource_id: StringName) -> Vector2i:
    var id := str(resource_id)
    if CELLS.has(id):
        return CELLS[id]
    if id.contains("dan") or id.contains("pill"):
        return CELLS["tu_khi_dan"]
    var definition: Dictionary = ResourceRegistry.new().definition(resource_id)
    match str(definition.get("family","")):
        "mineral": return CELLS["thanh_thiet"]
        "wood": return CELLS["linh_moc"]
        "herb": return CELLS["thanh_linh_thao"]
        "crop": return CELLS["linh_coc"]
        "pill": return CELLS["tu_khi_dan"]
        "essence","monster_core": return CELLS["linh_tuy"]
        "beast_material": return CELLS["tinh_lang_bi"]
    return CELLS["generic_resource"]
static func icon(resource_id: StringName, dimensions: int = 40) -> TextureRect:
    var node := TextureRect.new()
    node.name = "ResourceArtwork_" + str(resource_id).replace(".","_")
    node.custom_minimum_size = Vector2(dimensions,dimensions)
    node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    node.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var region := AtlasTexture.new()
    region.atlas = ATLAS
    var cell: Vector2i = cell_for(resource_id)
    region.region = Rect2(Vector2(cell) * 128.0,Vector2(128.0,128.0))
    node.texture = region
    return node
