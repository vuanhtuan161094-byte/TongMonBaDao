extends SceneTree

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var world := SectIsometricWorldV1.new()
    var actual := 0
    for x in [0,1,72,96,119,191]:
        for y in [0,1,72,96,119,191]:
            var cell := Vector2(x,y)
            var invert := SectIsometricWorldV1.inverse(
                SectIsometricWorldV1.project(cell)
            )
            if invert.distance_to(cell) > 0.0001:
                _fail("isometric projection inverse mismatch")
                return
            actual += 1
    if (
        world.STARTER != Rect2i(72,72,48,48)
        or world.GRID.x/world.CHUNK != 12
    ):
        _fail("starter or 16-cell chunk changed")
        return
    for kind in [SectMapPresentation.DEST_MINE,SectMapPresentation.DEST_SPIRIT_FIELD]:
        if SectIsometricWorldV1.virtual_legacy_point(kind) == Vector2.ZERO:
            _fail("landmark has no screen projection")
            return
    print("MAP-2.5D PROJECTION %d CASES PASS" % actual)
    quit(0)

func _fail(reason: String) -> void:
    push_error("MAP 2.5D PROJECTION FAIL: "+reason)
    quit(1)
