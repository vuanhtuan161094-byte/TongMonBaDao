extends SceneTree
## VIS-08 original buildings are runtime-canonical, historical SHA-only art
## stays in the repo but is NEVER rendered as a house.
const CUSTOM = preload("res://src/presentation/p3/tmb_original_building_art_v5.gd")
const FACILITY = preload("res://src/presentation/uiux/sect_facility_art_v2.gd")
const WORLD = preload("res://src/presentation/p3/sect_isometric_world_v1.gd")
const SOURCE_A_GATE = preload("res://src/presentation/p3/sect_map25_source_art.gd")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var expected := {
        "main_hall": Vector2i(300,201),
        "residence": Vector2i(174,135),
        "warehouse": Vector2i(162,138),
        "forge": Vector2i(205,164),
        "guidance": Vector2i(182,203)
    }
    var old := SOURCE_A_GATE.new()
    for kind in expected:
        var art: Texture2D = CUSTOM.texture_for(StringName(kind))
        assert(art != null and art.get_size() == Vector2(expected[kind]), "Bad original art import: "+kind)
        var im := art.get_image()
        assert(im != null and im.get_pixel(0,0).a <= 0.04, "PNG not transparent: "+kind)
        assert(im.get_pixel(art.get_width()-1,0).a <= 0.04, "PNG upper-right corner not transparent: "+kind)
        var historical: Texture2D = old.texture_for(str(WORLD.HOUSE_TEXTURES[kind]))
        assert(historical != null, "Keep historical Source A checksum for reference: "+kind)
        assert(historical != art, "Not independently authored art: "+kind)
    for kind in ["hall", "residence", "guidance"]:
        var picture := FACILITY.new()
        picture.facility_kind = kind
        root.add_child(picture)
        await process_frame
        assert(picture.get("_art") == CUSTOM.texture_for(StringName(kind)))
        assert(not bool(picture.get("_original_source")), "Source A still live in panel: "+kind)
        picture.queue_free()
    print("VIS08_SOURCE_A_HOUSE_RETIREMENT PASS five_original_sprites alpha=5/5 source_a_historical_bytes_preserved v3_unmodified")
    quit(0)
