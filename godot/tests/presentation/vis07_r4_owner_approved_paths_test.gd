extends SceneTree
## R4 path and fallback contract: no fake asset integration claims.
const APPROVED = preload("res://src/presentation/p3/tmb_approved_building_art_v4.gd")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    assert(APPROVED.HALL_PATH.ends_with("main_hall_approved_300x201.png"))
    assert(APPROVED.MINE_PATH.ends_with("mine_approved_166x121.png"))
    var hall_tex := APPROVED.texture_for(&"main_hall")
    var mine_tex := APPROVED.texture_for(&"mine")
    assert((hall_tex == null) == (mine_tex == null), "Both approved assets must be imported together")
    if hall_tex != null:
        assert(hall_tex.get_width() == 300 and hall_tex.get_height() == 201)
        assert(mine_tex.get_width() == 166 and mine_tex.get_height() == 121)
        var h := hall_tex.get_image()
        var m := mine_tex.get_image()
        assert(h != null and m != null, "Approved artwork pixels not readable")
        assert(h.get_pixel(0,0).a < 0.04 and m.get_pixel(0,0).a < 0.04, "Source images must have transparent corners")
        print("VIS07_R4_OWNER_ART_IMPORTED PASS hall=300x201 mine=166x121 alpha=PASS")
    else:
        print("VIS07_R4_TRANSPORT_PENDING; path integration verified but PNGs ABSENT; do not claim live replacement")
    quit(0)
