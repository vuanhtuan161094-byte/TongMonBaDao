extends SceneTree

# DD-09.2: plot placement needs ONLY a 3x3 footprint and one exterior door.
# No road purchase, start-to-door connectivity check, AStar or interior path.
const QA_PATH := "user://qa_dd092_door_plot_20261101.json"

func _initialize() -> void:
    call_deferred("_run")

func _require(ok: bool, reason: String) -> bool:
    if ok:
        return true
    push_error("DD092_DOOR_PLOT_FAIL: " + reason)
    quit(1)
    return false

func _cleanup() -> void:
    for suffix in ["", ".bak", ".tmp"]:
        if FileAccess.file_exists(QA_PATH + suffix):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(QA_PATH + suffix))

func _run() -> void:
    var state := P37Factory.create_state(20261101)
    if not _require(bool(SectHallSystemV1.ensure_live(state).get("ok", false)),
            "initial Hall and Residence"):
        return
    var hall := SectHallSystemV1.hall(state)
    hall.level = 11 # isolated QA fixture only: unlocks second House.
    var warehouse := WarehouseSystem.new()
    if not _require(warehouse.add(state,BuildingSystem.MATERIAL_WOOD,1500)
            and warehouse.add(state,BuildingSystem.MATERIAL_ORE,1000),
            "cannot seed isolated QA construction supplies"):
        return
    state.sect.spirit_stones = 25000
    var stones_before := state.sect.spirit_stones

    var alternate_plot := Vector2i(104,108) # Not the historical Annex #2 slot.
    var door := SectResidenceSiteV1.doorway(alternate_plot)
    if not _require(door == Vector2i(105,107) \
            and bool(SectResidenceSiteV1.check(state,alternate_plot).get("ok", false)),
            "expected free outdoor doorway plot unavailable"):
        return
    var bad_plot := SectResidenceSystemV1.construct(state,"qa-bad-door-plot",Vector2i(81,89))
    if not _require(not bool(bad_plot.get("ok", true))
            and state.sect.spirit_stones == stones_before
            and SectResidenceSystemV1.all_houses(state).size() == 1,
            "invalid House site mutated currency or created an instance"):
        return

    var built := SectResidenceSystemV1.construct(state,"qa-house-chosen-plot",alternate_plot)
    if not _require(bool(built.get("ok",false)) and state.sect.spirit_stones < stones_before
            and str(built.get("building_id","")) == "residence_002",
            "selected plot was not actually purchased"):
        return
    var house: BuildingState = state.buildings["residence_002"]
    if not _require(SectResidenceSiteV1.origin_of(house) == alternate_plot
            and house.status == BuildingSystem.STATUS_CONSTRUCTING
            and SectResidenceSystemV1.total_beds(state) == 8
            and SectHallSystemV1.validate(state).is_empty(),
            "paid plot, construction status or bed authority invalid"):
        return
    var repeated := SectResidenceSystemV1.construct(state,"qa-house-chosen-plot",alternate_plot)
    var conflicting := SectResidenceSystemV1.construct(state,"qa-house-chosen-plot",Vector2i(86,108))
    if not _require(bool(repeated.get("already_settled",false))
            and not bool(conflicting.get("ok",true))
            and state.sect.spirit_stones == stones_before - int(built["cost"]["spirit_stones"]),
            "same request replay duplicated payment or changed the location"):
        return
    if not _require(not bool(SectResidenceSiteV1.check(state,alternate_plot).get("ok",true)),
            "same plot can be purchased twice"):
        return

    var iso := SectIsometricWorldV1.new()
    root.add_child(iso)
    iso.refresh_from_state(state)
    var projected: Dictionary = {}
    for row in iso.display_instances:
        if str(row.get("building_id","")) == "residence_002":
            projected = row
            break
    if not _require(not projected.is_empty() and projected["cell"] == alternate_plot,
            "map art/picking ignored canonical House location"):
        return
    var actor_point := SectIsometricWorldV1.virtual_legacy_point(
        SectMapPresentation.DEST_RESIDENCE,&"residence_002",alternate_plot)
    var expected := SectIsometricWorldV1.LEGACY_ANCHOR \
        + SectIsometricWorldV1.project(Vector2(door)) \
        - SectIsometricWorldV1.project(SectIsometricWorldV1.CENTER_CELL)
    if not _require(actor_point.distance_to(expected) < 0.001,
            "actor target moved to building center rather than chosen door"):
        return
    root.remove_child(iso)
    iso.free()

    # Check actual native Godot UI plot selection, not just backend geometry:
    # the player can choose another plot without paving a connected road.
    hall.level = 21 # QA-only capacity prerequisite for third House.
    var panel := DaiDienScreenV1.new()
    panel.attach_state(state)
    root.add_child(panel)
    panel._tab(5)
    var chooser := panel.find_child("ResidencePlotSelector",true,false) as OptionButton
    var third_site := Vector2i(110,114)
    var selector_index := panel._residence_site_options.find(third_site)
    if not _require(chooser != null and selector_index >= 0,
            "native plot selector missing available non-overlapping lot"):
        return
    panel._select_house_site(selector_index)
    panel._construct_house()
    var third: BuildingState = state.buildings.get("residence_003")
    if not _require(third != null and SectResidenceSiteV1.origin_of(third) == third_site
            and third.status == BuildingSystem.STATUS_CONSTRUCTING
            and SectResidenceSystemV1.total_beds(state) == 8
            and SectHallSystemV1.validate(state).is_empty(),
            "native UI did not construct at selected plot, or unlocked free beds"):
        return
    root.remove_child(panel)
    panel.free()

    var damaged := SimulationState.from_dict(state.to_dict())
    damaged.buildings["residence_002"].production_state.erase("site_x")
    if not _require(not SectHallSystemV1.validate(damaged).is_empty(),
            "half-persisted House site was silently migrated"):
        return
    _cleanup()
    var saver := SaveService.new()
    if not _require(saver.save_to_path(state,QA_PATH) == OK,
            "cannot persist selected House plot"):
        return
    var loaded := saver.load_from_path(QA_PATH)
    if not _require(loaded != null
            and SectResidenceSiteV1.origin_of(loaded.buildings["residence_002"]) == alternate_plot
            and SectHallSystemV1.validate(loaded).is_empty(),
            "SaveService lost or changed the chosen House plot"):
        return
    _cleanup()
    print("DD092_DOOR_PLOT_PASS road_gate=none chosen_plot=1 exterior_door=1 save_reload=1 conflict=1")
    quit(0)
