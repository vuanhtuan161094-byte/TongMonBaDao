extends SceneTree

# This verifies visual-only LOD; no gameplay or SaveService state is read.
func _init() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("SECT ENDGAME VISUAL BUDGET FAIL: "+message)
    quit(1)

func _run() -> void:
    if SectEndgameVisualBudgetV1.site_level(0.75) != 0 or SectEndgameVisualBudgetV1.site_level(1.0) != 1 or SectEndgameVisualBudgetV1.site_level(1.35) != 2:
        _fail("camera LOD levels not progressive")
        return
    if SectEndgameVisualBudgetV1.pick_radius(0.75,true).x >= SectEndgameVisualBudgetV1.pick_radius(1.35,true).x:
        _fail("compact producer picker is oversized")
        return
    var rows: Array[Dictionary] = []
    for i in range(500):
        rows.append({"id":"disciple_%03d" % i,"center_distance":float(500-i)})
    var original := JSON.stringify(rows)
    for zoom in [0.75,1.0,1.35,1.80]:
        var chosen: Dictionary = SectEndgameVisualBudgetV1.choose_visible_actors(rows,zoom,"disciple_499")
        if chosen.size() != SectEndgameVisualBudgetV1.actor_cap(zoom) or not chosen.has("disciple_499"):
            _fail("LOD cap or focus wrong at zoom %.2f" % zoom)
            return
        if chosen != SectEndgameVisualBudgetV1.choose_visible_actors(rows,zoom,"disciple_499"):
            _fail("actor selection is not repeatable")
            return
        var reversed_rows := rows.duplicate(true)
        reversed_rows.reverse()
        if chosen != SectEndgameVisualBudgetV1.choose_visible_actors(reversed_rows,zoom,"disciple_499"):
            _fail("selection changed with Dictionary iteration order")
            return
    var forced := SectEndgameVisualBudgetV1.choose_visible_actors(rows,0.75,"disciple_000")
    if not forced.has("disciple_000") or forced.size() != 24:
        _fail("focus actor not prioritized when viewport is crowded")
        return
    # 500 people standing on the SAME world spot must render as a single
    # avatar at wide zoom, regardless of the canonical roster size.
    var crowd: Array[Dictionary] = []
    for i in range(500):
        crowd.append({"id":"crowd_%03d" % i,"center_distance":float(i),
            "screen_point":Vector2(400.0,300.0)})
    var sparse := SectEndgameVisualBudgetV1.choose_visible_actors(crowd,0.75,"crowd_499")
    if sparse.size() != 1 or not sparse.has("crowd_499"):
        _fail("screen-space thinning cannot resolve a 500-person pile")
        return
    if JSON.stringify(rows) != original:
        _fail("render budget modified source actor row data")
        return
    print("SECT ENDGAME VISUAL BUDGET CONTRACT PASS roster=500 caps=24/40/72 spatial_pile=1 focus=true simulation_untouched=true")
    quit(0)
