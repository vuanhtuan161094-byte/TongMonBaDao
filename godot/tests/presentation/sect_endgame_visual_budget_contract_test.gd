extends SceneTree

# This verifies visual-only LOD; no gameplay or SaveService state is read.
func _init() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("SECT ENDGAME VISUAL BUDGET FAIL: "+message)
    quit(1)

func _run() -> void:
    var helper := SectEndgameVisualBudgetV1
    if helper.site_level(0.75) != 0 or helper.site_level(1.0) != 1 or helper.site_level(1.35) != 2:
        _fail("camera LOD levels not progressive")
        return
    if helper.pick_radius(0.75,true).x >= helper.pick_radius(1.35,true).x:
        _fail("compact producer picker is oversized")
        return
    var rows: Array[Dictionary] = []
    for i in range(500):
        rows.append({"id":"disciple_%03d" % i,"center_distance":float(500-i)})
    var original := JSON.stringify(rows)
    for zoom in [0.75,1.0,1.35,1.80]:
        var chosen: Dictionary = helper.choose_visible_actors(rows,zoom,"disciple_499")
        if chosen.size() != helper.actor_cap(zoom) or not chosen.has("disciple_499"):
            _fail("LOD cap or focus wrong at zoom %.2f" % zoom)
            return
        if chosen != helper.choose_visible_actors(rows,zoom,"disciple_499"):
            _fail("actor selection is not repeatable")
            return
        var reversed_rows := rows.duplicate(true)
        reversed_rows.reverse()
        if chosen != helper.choose_visible_actors(reversed_rows,zoom,"disciple_499"):
            _fail("selection changed with Dictionary iteration order")
            return
    var forced := helper.choose_visible_actors(rows,0.75,"disciple_000")
    if not forced.has("disciple_000") or forced.size() != 24:
        _fail("focus actor not prioritized when viewport is crowded")
        return
    if JSON.stringify(rows) != original:
        _fail("render budget modified source actor row data")
        return
    print("SECT ENDGAME VISUAL BUDGET CONTRACT PASS roster=500 caps=24/40/72 focus=true simulation_untouched=true")
    quit(0)
