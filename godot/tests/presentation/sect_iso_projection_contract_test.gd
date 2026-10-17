extends SceneTree

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    # All checked projection/size data are class constants; no Node2D is needed.
    # Do not allocate a CanvasItem outside the scene tree and leak its RID.
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
        SectIsometricWorldV1.STARTER != Rect2i(72,72,48,48)
        or SectIsometricWorldV1.GRID.x/SectIsometricWorldV1.CHUNK != 12
    ):
        _fail("starter or 16-cell chunk changed")
        return
    for kind in [SectMapPresentation.DEST_MINE,SectMapPresentation.DEST_SPIRIT_FIELD]:
        if SectIsometricWorldV1.virtual_legacy_point(kind) == Vector2.ZERO:
            _fail("landmark has no screen projection")
            return
    # ENV02A PV01 3 buildings display at footprint centers, not top-left.
    for kind in ["main_hall","warehouse","forge"]:
        var at: Vector2i = SectIsometricWorldV1.TYPE_ANCHORS[kind]
        var footprint: Vector2 = SectIsometricWorldV1.HOUSE_FOOTPRINT_CENTERS[kind]
        var projected := SectIsometricWorldV1.project(
            SectIsometricWorldV1.visual_anchor(StringName(kind),at)
        )
        if projected.distance_to(SectIsometricWorldV1.project(Vector2(at)+footprint)) > 0.001:
            _fail("PV01 display anchor diverged from footprint center for "+kind)
            return
    print("MAP-2.5D PROJECTION %d CASES PASS" % actual)
    quit(0)

func _fail(reason: String) -> void:
    push_error("MAP 2.5D PROJECTION FAIL: "+reason)
    quit(1)
