extends SceneTree
## VIS-07 R4: preserve historical Source A checksum; switch only the two
## selected LIVE building-image sources to owner's independently authored art.
const APPROVED = preload("res://src/presentation/p3/tmb_approved_building_art_v4.gd")
const FACILITY = preload("res://src/presentation/uiux/sect_facility_art_v2.gd")
const SOURCE_A_GATE = preload("res://src/presentation/p3/sect_map25_source_art.gd")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var gate = SOURCE_A_GATE.new()
    var historic := gate.texture_for("pv01_assets/main_hall/510052.png")
    assert(historic != null and historic.get_width() == 1104, "Source A historical verification lost")
    var owner_hall := APPROVED.texture_for(&"main_hall")
    var owner_mine := APPROVED.texture_for(&"mine")
    assert(owner_hall != null and owner_hall.get_width() == 300, "Missing Owner Hall PNG")
    assert(owner_mine != null and owner_mine.get_width() == 166, "Missing Owner Mine PNG")
    assert(owner_hall != historic, "New art is mistakenly referencing Source A")
    var hall := FACILITY.new()
    hall.facility_kind = "hall"
    root.add_child(hall)
    await process_frame
    assert(not bool(hall.get("_original_source")), "Hall visual still uses Source A")
    assert(bool(hall.get("_owner_approved")), "Hall did not render the approved replacement")
    assert((hall.get("_art") as Texture2D).get_width() == 300)
    hall.queue_free()
    print("VIS07_R4_OWNER_APPROVED PASS hall=original mine=original historical_SHA=preserved")
    quit(0)
