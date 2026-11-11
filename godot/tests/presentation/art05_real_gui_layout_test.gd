extends SceneTree
## Screenshot-driven ART05 visual layout contract on authentic Godot OneGame.
const SAVE_PATH := "user://art05_visual_contract_isolated.json"
func _init() -> void:
    call_deferred("_run")
func _run() -> void:
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    assert(scene != null,"Live OneGame scene missing")
    var game := scene.instantiate() as Control
    root.add_child(game)
    for i in range(10):
        await process_frame
    assert(bool(game.get("runtime_ready")),"Canonical state not initialized")
    assert(game.find_child("Art06WorldAtmosphere",true,false) != null,"World ambient visual is not present")
    var checked := 0
    for destination in [
        SectMapPresentation.DEST_MAIN_HALL,
        SectMapPresentation.DEST_MINE,
        SectMapPresentation.DEST_LINH_FOREST,
        SectMapPresentation.DEST_SPIRIT_FIELD,
        SectMapPresentation.DEST_WAREHOUSE,
        SectMapPresentation.DEST_ALCHEMY_HALL
    ]:
        game.call("_open_building",destination)
        for i in range(3):
            await process_frame
        var panel := game.find_child("BuildingOperationPanel",true,false) as Control
        assert(panel != null and panel.visible,"Management panel should remain open")
        assert(panel.position.x >= 400.0 and panel.size.x <= 850.0,
            "Screenshot regression: management modal hides actual world")
        assert(panel.position.x+panel.size.x <= 1280.0 and panel.position.y+panel.size.y < 645.0,
            "Management panel clipped 1280x720 navigation")
        assert(panel.find_child("Art05PremiumJadeFrame",true,false) != null,
            "Cohesive decorative frame not integrated in real OneGame")
        var action_scroll := panel.find_child("BuildingOperationScroll",true,false) as ScrollContainer
        var live_scroll := panel.find_child("BuildingOperationLiveScroll",true,false) as ScrollContainer
        assert(action_scroll != null and live_scroll != null,"Real actions must be reachable by scroll")
        assert(action_scroll.size.x >= 350.0 and live_scroll.size.x >= 380.0,
            "Touch management columns must remain operable")
        if destination == SectMapPresentation.DEST_WAREHOUSE:
            var stock := panel.find_child("Art02WarehouseStockGallery",true,false) as GridContainer
            if stock != null:
                assert(stock.columns == 2,"Warehouse gallery must fit compact dock")
        if destination == SectMapPresentation.DEST_ALCHEMY_HALL:
            assert(panel.find_child("Art02AlchemyIngredientGallery",true,false) is GridContainer,
                "Alchemy recipe items should wrap without horizontal clipping")
        checked += 1
    print("ART05 REAL_ONEGAME_VISUAL_LAYOUT PASS screens=",checked)
    game.set("runtime_ready",false)
    game.queue_free()
    for i in range(6):
        await process_frame
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)
    quit(0)
