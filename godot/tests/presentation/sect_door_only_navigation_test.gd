extends SceneTree

# DD-09.2: sect jobs stop at EXTERIOR building doors, never inside their
# footprints. Sect movement must not depend on PvE AStar or painted roads.
# Official Godot 4.7.2 headless QA:
# --headless --path godot --script res://tests/presentation/sect_door_only_navigation_test.gd

func _initialize() -> void:
    call_deferred("_run")

func _require(condition: bool, reason: String) -> bool:
    if condition:
        return true
    push_error("DD09_DOOR_ONLY_FAIL: " + reason)
    quit(1)
    return false

func _run() -> void:
    var map := SectIsoMapModelV1.new(Vector2i(192, 192), Vector2i(96, 102))
    var tested := 0
    # Original three PV01 building doors must match canonical footprint
    # geometry, including rotation-zero exterior entrance direction.
    for kind in ["main_hall", "warehouse", "forge"]:
        var origin: Vector2i = SectIsometricWorldV1.TYPE_ANCHORS[kind]
        var door := SectIsometricWorldV1.exterior_door_cell(StringName(kind), 1)
        if not _require(door == map.doorway(kind, origin, 0),
                "model door and sect actor destination disagree for " + kind):
            return
        if not _require(not map.cells_for(kind, origin, 0).has(door),
                "actor door is inside " + kind + " footprint"):
            return
        tested += 1

    # All House instances use independent deterministic exterior entrance
    # cells; no painted road or path-to-spawn is consulted in production.
    var residence_doors: Dictionary = {}
    for index in range(1, 11):
        var origin := SectIsometricWorldV1.producer_cell(SectMapPresentation.DEST_RESIDENCE,index)
        var door := SectIsometricWorldV1.exterior_door_cell(SectMapPresentation.DEST_RESIDENCE,index)
        if not _require(SectIsometricWorldV1.GRID.x > door.x and SectIsometricWorldV1.GRID.y > door.y
                and SectIsometricWorldV1.STARTER.has_point(door),
                "House entrance outside starter for residence #%d" % index):
            return
        if not _require(not Rect2i(origin,Vector2i(3,3)).has_point(door),
                "House door lies inside residence #%d" % index):
            return
        if not _require(not residence_doors.has(door),
                "two Houses have the same entrance tile"):
            return
        residence_doors[door] = true
        var id := StringName("residence_%03d" % index)
        var expected := SectIsometricWorldV1.LEGACY_ANCHOR + SectIsometricWorldV1.project(Vector2(door)) - SectIsometricWorldV1.project(SectIsometricWorldV1.CENTER_CELL)
        if not _require(SectIsometricWorldV1.virtual_legacy_point(SectMapPresentation.DEST_RESIDENCE,id).distance_to(expected) < 0.001,
                "live actor is targeting roof/center instead of exterior door #" + str(index)):
            return
        tested += 1

    # The actual live Annex #2 is a paid in-progress construction: no need
    # to build or maintain a road to reach its door and no beds unlock early.
    var state := P37Factory.create_state(20261101)
    if not _require(bool(SectHallSystemV1.ensure_live(state).get("ok",false)),
            "cannot initialize canonical Hall and House"):
        return
    SectHallSystemV1.hall(state).level = 11
    var warehouse := WarehouseSystem.new()
    if not _require(warehouse.add(state,BuildingSystem.MATERIAL_WOOD,1000)
            and warehouse.add(state,BuildingSystem.MATERIAL_ORE,1000),
            "isolated construction materials not granted"):
        return
    state.sect.spirit_stones = 25000
    var result := SectResidenceSystemV1.construct(state,"qa-door-entrance-only")
    if not _require(bool(result.get("ok",false))
            and SectResidenceSystemV1.total_beds(state) == 8
            and str(state.buildings["residence_002"].status) == "constructing",
            "painted roads incorrectly gate Annex purchase or unfinished House grants beds"):
        return

    print("DD09_DOOR_ONLY_PASS exterior_entrances=%d no_interior_path=1 no_road_build_gate=1" % tested)
    quit(0)
