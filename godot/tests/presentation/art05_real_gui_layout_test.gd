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
        assert(panel.position.distance_to(Vector2.ZERO) < 1.0 and panel.size.distance_to(Vector2(1280,720)) < 2.0,
            "Facility must occupy the full game viewport, not a floating management window")
        assert(panel.find_child("Art05PremiumJadeFrame",true,false) != null,
            "Cohesive decorative frame not integrated in real OneGame")
        var action_scroll := panel.find_child("BuildingOperationScroll",true,false) as ScrollContainer
        var live_scroll := panel.find_child("BuildingOperationLiveScroll",true,false) as ScrollContainer
        assert(action_scroll != null and live_scroll != null,"Real actions must be reachable by scroll")
        assert(action_scroll.size.x >= 540.0 and live_scroll.size.x >= 530.0,
            "Each shared full-screen facility tab must have a usable command and status width")
        for index in range(3):
            var facility_tab := panel.find_child("FacilityTab_%d" % index,true,false) as Button
            assert(facility_tab != null and facility_tab.get_global_rect().end.x <= 200.0,
                "Missing common facility navigation or rail overlaps artwork")
        var scene_art := panel.find_child("BuildingOperationArtFrame",true,false) as Control
        assert(scene_art != null and scene_art.size.x >= 400.0 and scene_art.size.y >= 340.0,
            "Shared facility hero asset must remain prominent on every tab")
        var action_caption := panel.get_node_or_null("R2ActionCaption") as Label
        var live_caption := panel.get_node_or_null("R2LiveCaption") as Label
        assert(action_caption != null and live_caption != null,"Readable operation headings must be mounted")
        assert(not action_caption.visible and not live_caption.visible,
            "Old floating-modal captions must not overlay the full-screen view")
        var section := panel.find_child("FacilitySectionTitle",true,false) as Label
        assert(section != null and section.get_global_rect().end.y < action_scroll.get_global_rect().position.y,
            "Shared full-screen facility section heading must not overlap controls")
        var host := panel.get_node_or_null("BuildingOperationArtFrame/BuildingOperationArt") as Control
        assert(host != null,"Real building art host missing")
        var before_count := host.get_child_count()
        for _refresh in range(4):
            game.call("_refresh_building_operation_art")
        assert(host.get_child_count() == before_count,"Building art refresh must not accumulate duplicate visual nodes")
        if destination == SectMapPresentation.DEST_WAREHOUSE:
            var stock := panel.find_child("Art02WarehouseStockGallery",true,false) as GridContainer
            if stock != null:
                assert(stock.columns == 2,"Warehouse gallery must preserve its inventory grouping")
        if destination == SectMapPresentation.DEST_ALCHEMY_HALL:
            assert(panel.find_child("Art02AlchemyIngredientGallery",true,false) is GridContainer,
                "Alchemy recipe items should wrap without horizontal clipping")
        if destination in [SectMapPresentation.DEST_LINH_FOREST,
                SectMapPresentation.DEST_SPIRIT_FIELD,SectMapPresentation.DEST_ALCHEMY_HALL]:
            var v3 := panel.find_child("ASBuildV3FacilitySprite",true,false) as TextureRect
            assert(v3 != null and v3.texture != null,
                "True V3 imported building PNG must replace placeholder in actual panel")
        checked += 1
    print("ART05 REAL_ONEGAME_VISUAL_LAYOUT PASS screens=",checked)
    game.set("runtime_ready",false)
    game.queue_free()
    for i in range(6):
        await process_frame
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)
    quit(0)
