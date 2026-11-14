extends RefCounted
## VIS-07. Original source-controlled vector art, presentation ONLY.
## Artwork created from scratch specifically for TMB (art_source: code).
## Distinct from Source A verification: old originals remain for rollback,
## never substituted for these art references at runtime.
const HALL: Texture2D = preload("res://art/tmb_original_v1/hall_isometric.svg")
const MINE: Texture2D = preload("res://art/tmb_original_v1/mine_isometric.svg")
const PINE: Texture2D = preload("res://art/tmb_original_v1/tree_pine.svg")
const BLOSSOM: Texture2D = preload("res://art/tmb_original_v1/tree_blossom.svg")
const BAMBOO: Texture2D = preload("res://art/tmb_original_v1/tree_bamboo.svg")
const ROCK: Texture2D = preload("res://art/tmb_original_v1/rock_garden.svg")
const LANE: Texture2D = preload("res://art/tmb_original_v1/stone_lane.svg")
const COURT: Texture2D = preload("res://art/tmb_original_v1/stone_court.svg")
const RUNE: Texture2D = preload("res://art/tmb_original_v1/stone_rune.svg")
const EDGE: Texture2D = preload("res://art/tmb_original_v1/stone_edge.svg")

static func hall() -> Texture2D:
    return HALL

static func mine() -> Texture2D:
    return MINE

static func stone_for(source_key: String) -> Texture2D:
    if source_key.contains("runes"):
        return RUNE
    if source_key.contains("border") or source_key.contains("scatter"):
        return EDGE
    if source_key.contains("courtyard") or source_key.contains("cross"):
        return COURT
    return LANE

static func foliage_for(id: String) -> Texture2D:
    if id in ["570036", "570038", "570041", "570042", "570185"]:
        return PINE
    if id in ["570037", "570171", "570172", "570173", "570181"]:
        return BLOSSOM
    if id in ["570073", "570144", "570399"]:
        return ROCK
    return BAMBOO
