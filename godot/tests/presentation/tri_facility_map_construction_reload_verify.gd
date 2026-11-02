extends SceneTree
## Separate Godot process verifies the saved paid map-build transaction and replay.
const ROUNDTRIP_PATH := "user://tri03_map_build_roundtrip.json"
const EXPECTED_PATH := "user://tri03_map_build_expected.json"

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> bool:
    if ok:
        return true
    push_error("TRI_MAP_BUILD_RELOAD_FAIL: " + message)
    quit(1)
    return false

func _clean(path: String) -> void:
    var absolute := ProjectSettings.globalize_path(path)
    for suffix in ["", ".bak", ".tmp"]:
        if FileAccess.file_exists(absolute+suffix):
            DirAccess.remove_absolute(absolute+suffix)

func _run() -> void:
    var expected_path := ProjectSettings.globalize_path(EXPECTED_PATH)
    var file := FileAccess.open(expected_path,FileAccess.READ)
    if not _check(file != null,"first process did not produce an expected manifest"):
        return
    var parsed := JSON.new()
    var parse_error := parsed.parse(file.get_as_text())
    file.close()
    if not _check(parse_error == OK and parsed.data is Dictionary,"expected manifest is invalid"):
        return
    var expected: Dictionary = parsed.data
    var state := SaveService.new().load_from_path(ProjectSettings.globalize_path(ROUNDTRIP_PATH))
    if not _check(state != null and SectHallSystemV1.validate(state).is_empty(),"independent process could not load a valid canonical state"):
        return
    var building_id := str(expected.get("building_id",""))
    var house := state.buildings.get(building_id) as BuildingState
    var original_site := Vector2i(int(expected.get("original_site_x",-1)),int(expected.get("original_site_y",-1)))
    var expected_site := Vector2i(int(expected.get("site_x",-1)),int(expected.get("site_y",-1)))
    if not _check(house != null and house.status == BuildingSystem.STATUS_ACTIVE
            and SectResidenceSiteV1.origin_of(house) == expected_site,
            "saved completed house identity, state or relocated map site changed"):
        return
    var receipts: Dictionary = state.sect.hall_governance.get("residence_build_receipts",{})
    if not _check(receipts.get(str(expected.get("request_id","")),"") == building_id
            and receipts.size() == int(expected.get("receipt_count",-1)),
            "saved exactly-once build receipt changed"):
        return
    var move_request_id := str(expected.get("move_request_id",""))
    var move_receipts: Dictionary = state.sect.hall_governance.get("residence_move_receipts",{})
    var move_receipt: Dictionary = move_receipts.get(move_request_id,{})
    if not _check(not move_request_id.is_empty() and move_receipts.size() == int(expected.get("move_receipt_count",-1))
            and str(move_receipt.get("house_id","")) == building_id
            and int(move_receipt.get("previous_x",-1)) == original_site.x
            and int(move_receipt.get("previous_y",-1)) == original_site.y
            and int(move_receipt.get("site_x",-1)) == expected_site.x
            and int(move_receipt.get("site_y",-1)) == expected_site.y,
            "Save/Reload changed the canonical relocation receipt"):
        return
    var warehouse := WarehouseSystem.new()
    if not _check(warehouse.available_quantity(state,BuildingSystem.MATERIAL_WOOD) == int(expected.get("wood",-1))
            and warehouse.available_quantity(state,BuildingSystem.MATERIAL_ORE) == int(expected.get("ore",-1))
            and state.sect.spirit_stones == int(expected.get("stones",-1))
            and SectResidenceSystemV1.all_houses(state).size() == int(expected.get("house_count",-1)),
            "Save/Reload changed canonical resources or house count"):
        return
    var before_wood := warehouse.available_quantity(state,BuildingSystem.MATERIAL_WOOD)
    var before_ore := warehouse.available_quantity(state,BuildingSystem.MATERIAL_ORE)
    var before_stones := state.sect.spirit_stones
    var before_count := SectResidenceSystemV1.all_houses(state).size()
    var replay_build := SectResidenceSystemV1.construct(state,str(expected.get("request_id","")),original_site)
    var replay_move := SectResidenceSystemV1.move_house(state,move_request_id,house.id,expected_site)
    if not _check(bool(replay_build.get("ok",false)) and bool(replay_build.get("already_settled",false))
            and str(replay_build.get("building_id","")) == building_id
            and bool(replay_move.get("ok",false)) and bool(replay_move.get("already_settled",false))
            and warehouse.available_quantity(state,BuildingSystem.MATERIAL_WOOD) == before_wood
            and warehouse.available_quantity(state,BuildingSystem.MATERIAL_ORE) == before_ore
            and state.sect.spirit_stones == before_stones
            and SectResidenceSystemV1.all_houses(state).size() == before_count,
            "build/move replay after independent reload duplicated state or payment"):
        return
    print("TRI_MAP_BUILD_CROSS_PROCESS_RELOAD_PASS building=%s site=%d,%d exact_once=1 costs=preserved" % [building_id,expected_site.x,expected_site.y])
    print("TRI_MAP_RELOCATION_CROSS_PROCESS_PASS building=%s old=%d,%d new=%d,%d exact_once=1" % [
        building_id,original_site.x,original_site.y,expected_site.x,expected_site.y])
    _clean(ROUNDTRIP_PATH)
    _clean(EXPECTED_PATH)
    _clean(RUNTIME_PATH)
    quit(0)

const RUNTIME_PATH := "user://tri03_map_build_runtime_isolated.json"
