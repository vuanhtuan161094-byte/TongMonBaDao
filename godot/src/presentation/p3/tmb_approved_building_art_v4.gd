extends RefCounted
## VIS-07 R4. Owner-approved (2026-11-14) original 2D building sprite paths.
## Separate from the five SHA-pinned historical Source A texture records.
## Never substitute a candidate if the corresponding reviewed PNG is absent.
const HALL_PATH := "res://art/tmb_approved_v4/main_hall_approved_300x201.png"
const MINE_PATH := "res://art/tmb_approved_v4/mine_approved_166x121.png"
const HALL_SIZE := Vector2i(300,201)
const MINE_SIZE := Vector2i(166,121)

static func path_for(kind: StringName) -> String:
    match str(kind):
        "main_hall", "hall": return HALL_PATH
        "mine": return MINE_PATH
    return ""

static func texture_for(kind: StringName) -> Texture2D:
    var path := path_for(kind)
    if path.is_empty() or not ResourceLoader.exists(path, "Texture2D"):
        return null
    var art := ResourceLoader.load(path) as Texture2D
    if art == null:
        return null
    var expected := HALL_SIZE if str(kind) in ["main_hall","hall"] else MINE_SIZE
    if art.get_width() != expected.x or art.get_height() != expected.y:
        push_warning("VIS07 approved art has wrong native dimensions: "+path)
        return null
    return art
