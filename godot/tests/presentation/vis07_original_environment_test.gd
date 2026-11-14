extends SceneTree
## Tiny targeted import gate; actual 1280x720 view is captured by ART-05.
const WORLD = preload("res://src/presentation/p3/tmb_original_world_art_v1.gd")
const FACILITY = preload("res://src/presentation/uiux/sect_facility_art_v2.gd")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    for tex in [WORLD.HALL, WORLD.MINE, WORLD.PINE, WORLD.BLOSSOM,
            WORLD.BAMBOO, WORLD.ROCK, WORLD.LANE, WORLD.COURT, WORLD.RUNE, WORLD.EDGE]:
        assert(tex != null and tex.get_width() >= 120 and tex.get_height() >= 65)
    var hall := FACILITY.new()
    hall.facility_kind = "hall"
    root.add_child(hall)
    await process_frame
    assert(hall.get("_art") == WORLD.HALL)
    assert(not bool(hall.get("_original_source")))
    var iso := SectIsometricWorldV1.new()
    assert(str(iso.MAP_D2_CANDIDATE_SITES["mine"]).begins_with("res://art/tmb_original_v1/"))
    assert(WORLD.stone_for("stone_runes") == WORLD.RUNE)
    assert(WORLD.foliage_for("570036") == WORLD.PINE)
    hall.queue_free()
    iso.free()
    print("VIS07_ORIGINAL_ENVIRONMENT PASS hall=original mine=original tiles=original vegetation=original")
    quit(0)
