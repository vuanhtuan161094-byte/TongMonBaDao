extends SceneTree
## ART-02 focused visual truth: real OneGame scene, canonical state, no fake stock/job.
const ITEMS = preload("res://src/presentation/uiux/sect_item_visual_v1.gd")
const SAVE_PATH := "user://art02_visual_isolated_test.json"
func _init() -> void:
    call_deferred("_run")
func _run() -> void:
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    assert(scene != null,"OneGame scene missing")
    var screen := scene.instantiate() as Control
    root.add_child(screen)
    for _i in range(7):
        await process_frame
    assert(bool(screen.get("runtime_ready")),"Canonical runtime is not ready")
    var checked := 0
    for item_id in [&"thanh_thiet",&"ore_r01_c2",&"linh_moc",&"thanh_linh_thao",&"tu_van_thao",&"linh_coc",&"hoi_xuan_dan",&"tu_khi_dan"]:
        var tile := ITEMS.icon(item_id,38)
        assert(tile.texture != null,"Missing imported item texture "+str(item_id))
        checked += 1
    for destination in [
        SectMapPresentation.DEST_MINE,SectMapPresentation.DEST_LINH_FOREST,
        SectMapPresentation.DEST_SPIRIT_FIELD,SectMapPresentation.DEST_WAREHOUSE,
        SectMapPresentation.DEST_ALCHEMY_HALL
    ]:
        screen.call("_open_building",destination)
        for _i in range(3):
            await process_frame
        assert(StringName(screen.get("selected_building")) == destination,"Cannot open canonical management panel "+str(destination))
        var room := screen.find_child("Art02FacilityAmbient",true,false)
        assert(room != null,"ART-02 facility illustration missing at "+str(destination))
        if destination in [SectMapPresentation.DEST_MINE,SectMapPresentation.DEST_LINH_FOREST]:
            var picker := screen.find_child("MineOreHero",true,false) as HBoxContainer
            assert(picker != null and picker.get_child_count() == 4,"Resource selector requires exactly four authentic options")
            for child in picker.get_children():
                var painted := false
                for button_child in child.get_children():
                    if str(button_child.name).begins_with("ResourceArtwork_"):
                        painted = true
                assert(painted,"Resource selector option lacks actual rendered texture")
        if destination == SectMapPresentation.DEST_WAREHOUSE:
            assert(screen.find_child("Art02WarehouseStockGallery",true,false) != null or screen.find_child("Art02WarehouseEmpty",true,false) != null,"Warehouse must show real stock art or true empty state")
        if destination == SectMapPresentation.DEST_ALCHEMY_HALL:
            assert(screen.find_child("Art02AlchemyIngredientGallery",true,false) != null,"Alchemy must render the current recipe and inputs")
        checked += 1
    assert(checked == 13,"Missing ART02 visual checks")
    print("ART02 ONEGAME_SOURCE_BACKED_VISUAL PASS checks=",checked)
    screen.set("runtime_ready",false)
    screen.queue_free()
    await process_frame
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)
    quit(0)
