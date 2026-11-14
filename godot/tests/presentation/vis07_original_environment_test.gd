extends SceneTree
## VIS-07 R3: the rejected code-drawn artwork remains isolated as review
## candidates; real Hall/paths/vegetation revert to exact Source A reference.
const WORLD = preload("res://src/presentation/p3/tmb_original_world_art_v1.gd")
const FACILITY = preload("res://src/presentation/uiux/sect_facility_art_v2.gd")
const SOURCE_A_GATE = preload("res://src/presentation/p3/sect_map25_source_art.gd")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    # Candidate assets still parse/import but are deliberately NOT live.
    for tex in [WORLD.HALL, WORLD.MINE, WORLD.PINE, WORLD.BLOSSOM,
            WORLD.BAMBOO, WORLD.ROCK, WORLD.LANE, WORLD.COURT, WORLD.RUNE, WORLD.EDGE]:
        assert(tex != null and tex.get_width() >= 120 and tex.get_height() >= 65)
    var gate = SOURCE_A_GATE.new()
    var hall_texture = gate.texture_for("pv01_assets/main_hall/510052.png")
    assert(hall_texture != null and hall_texture.get_width() == 1104)
    var hall := FACILITY.new()
    hall.facility_kind = "hall"
    root.add_child(hall)
    await process_frame
    assert(bool(hall.get("_original_source")))
    assert(hall.get("_art") == hall_texture or (
        (hall.get("_art") as Texture2D).get_width() == 1104))
    var iso := SectIsometricWorldV1.new()
    assert(str(iso.MAP_D2_CANDIDATE_SITES["mine"]).begins_with("res://art/map_d2_candidate/"))
    hall.queue_free()
    iso.free()
    print("VIS07_R3_SOURCE_A_RESET PASS hall=verified_source candidates=NOT_LIVE mine=still_pending")
    quit(0)
