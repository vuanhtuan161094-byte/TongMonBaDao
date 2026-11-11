extends "res://src/presentation/art02_onegame_visual_layer.gd"
## ART-05: screenshot-led responsive OneGame polish, Godot 4.7.2.
## Pure presentation. Real BuildingSystem/Warehouse/Save/UI buttons are inherited unchanged.
## The 7 virtual GUI captures at d48d8d21 are the BEFORE visual baseline.
const ART05_GOLD := Color(0.97,0.79,0.43)
const ART05_WHITE := Color(0.96,0.94,0.86)
const ART05_MUTE := Color(0.73,0.82,0.78)
const ART05_DEEP := Color(0.025,0.09,0.108)
const ART05_JADE := Color(0.08,0.205,0.216)
const ART05_FRAME = preload("res://src/presentation/uiux/sect_premium_panel_v1.gd")

func _build_building_operation_panel() -> void:
    super._build_building_operation_panel()
    if building_operation_panel == null:
        return
    var frame := ART05_FRAME.new()
    frame.name = "Art05PremiumJadeFrame"
    frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
    building_operation_panel.add_child(frame)
    building_operation_panel.move_child(frame,0)
    var previous := building_operation_panel.get_node_or_null("Art04CultivationFrame")
    if previous != null:
        previous.visible = false
    _art05_reflow()

func _refresh_building_operation_content(rebuild_management_controls: bool = true) -> void:
    super._refresh_building_operation_content(rebuild_management_controls)
    if _building_operation_is_open():
        _art05_reflow()
        _art05_tint()

func _art05_accent() -> Color:
    match selected_building:
        SectMapPresentation.DEST_MINE: return Color(1.0,0.72,0.35)
        SectMapPresentation.DEST_LINH_FOREST: return Color(0.43,0.93,0.65)
        SectMapPresentation.DEST_SPIRIT_FIELD: return Color(0.43,0.86,0.96)
        SectMapPresentation.DEST_ALCHEMY_HALL: return Color(0.81,0.60,1.0)
        SectMapPresentation.DEST_WAREHOUSE: return Color(0.98,0.81,0.46)
        SectMapPresentation.DEST_MAIN_HALL: return Color(0.99,0.77,0.41)
        _: return Color(0.64,0.91,0.81)

func _art05_style(bg: Color,border: Color,thickness: int = 2,corner: int = 13) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = bg
    s.border_color = border
    s.set_border_width_all(thickness)
    s.set_corner_radius_all(corner)
    s.shadow_color = Color(0,0.02,0.03,0.45)
    s.shadow_size = 6
    s.shadow_offset = Vector2(0,3)
    return s

func _art05_reflow() -> void:
    if building_operation_panel == null:
        return
    # The original 1184px modal hid virtually the entire playable map.
    # Keep the world visible, and make both existing live/management columns scroll.
    building_operation_panel.position = Vector2(418,75)
    building_operation_panel.size = Vector2(832,554)
    building_operation_panel.add_theme_stylebox_override("panel",_art05_style(
        Color(0.023,0.095,0.110,0.965),_art05_accent(),2,15))
    building_operation_title.position = Vector2(19,10)
    building_operation_title.size = Vector2(650,35)
    building_operation_title.add_theme_font_size_override("font_size",26)
    building_operation_title.add_theme_color_override("font_color",ART05_GOLD)
    building_operation_body.position = Vector2(284,146)
    building_operation_body.size = Vector2(532,65 if selected_building in [
        SectMapPresentation.DEST_MINE,SectMapPresentation.DEST_LINH_FOREST
    ] else 140)
    building_operation_body.add_theme_color_override("font_color",ART05_WHITE)
    building_operation_body.add_theme_font_size_override("font_size",14)
    var subtitle := building_operation_panel.get_node_or_null("Label")
    # Preserve the original management caption's node identity.
    for child in building_operation_panel.get_children():
        if child is Label and child != building_operation_title and child != building_operation_body:
            var label := child as Label
            label.position = Vector2(21,47)
            label.size = Vector2(650,18)
            label.add_theme_font_size_override("font_size",11)
            label.add_theme_color_override("font_color",ART05_MUTE)
    var close := building_operation_panel.get_node_or_null("CloseBuildingOperation") as Button
    if close != null:
        close.position = Vector2(769,9)
        close.size = Vector2(44,44)
        close.custom_minimum_size = Vector2(44,44)
        close.add_theme_stylebox_override("normal",_art05_style(ART05_JADE,ART05_GOLD,1,13))
        close.add_theme_color_override("font_color",ART05_WHITE)
    if building_operation_metrics != null:
        building_operation_metrics.position = Vector2(15,68)
        building_operation_metrics.size = Vector2(802,70)
        building_operation_metrics.add_theme_constant_override("separation",6)
        var count := maxi(1,building_operation_metrics.get_child_count())
        var target := floorf((802.0-float(count-1)*6.0)/float(count))
        for metric in building_operation_metrics.get_children():
            if metric is Control:
                metric.custom_minimum_size.x = target
    var frame := building_operation_panel.get_node_or_null("BuildingOperationArtFrame") as Panel
    if frame != null:
        frame.position = Vector2(16,145)
        frame.size = Vector2(251,149)
        frame.add_theme_stylebox_override("panel",_art05_style(
            Color(0.025,0.095,0.12,0.98),_art05_accent(),1,10))
    var picker := building_operation_panel.get_node_or_null("MineOreHero") as HBoxContainer
    if picker != null:
        picker.position = Vector2(280,217)
        picker.size = Vector2(535,78)
        picker.add_theme_constant_override("separation",5)
        for control in picker.get_children():
            if control is Button:
                control.custom_minimum_size = Vector2(0,72)
                control.add_theme_font_size_override("font_size",11)
                var art := control.get_child(control.get_child_count()-1) as TextureRect if control.get_child_count() > 0 else null
                if art != null:
                    art.position = Vector2(4,3)
                    art.size = Vector2(31,31)
    for child in building_operation_panel.get_children():
        if child is HSeparator:
            child.position = Vector2(16,301)
            child.size = Vector2(799,2)
    if building_operation_scroll != null:
        building_operation_scroll.position = Vector2(16,314)
        building_operation_scroll.size = Vector2(371,223)
        building_operation_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    if building_operation_content != null:
        building_operation_content.custom_minimum_size.x = 348
    if building_management_container != null:
        building_management_container.custom_minimum_size.x = 348
    if building_operation_live_panel != null:
        building_operation_live_panel.position = Vector2(400,314)
        building_operation_live_panel.size = Vector2(414,224)
        building_operation_live_panel.add_theme_stylebox_override("panel",_art05_style(
            Color(0.032,0.126,0.148,0.99),Color(0.42,0.58,0.53,0.55),1,10))
    if building_operation_live_scroll != null:
        building_operation_live_scroll.position = Vector2(9,8)
        building_operation_live_scroll.size = Vector2(395,207)
        building_operation_live_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    if building_operation_live_content != null:
        building_operation_live_content.custom_minimum_size.x = 370
    _art05_repack_galleries()

func _art05_repack_galleries() -> void:
    if building_operation_live_content == null:
        return
    var gallery := building_operation_live_content.get_node_or_null("Art02WarehouseStockGallery") as GridContainer
    if gallery != null:
        gallery.columns = 2
        for child in gallery.get_children():
            if child is Control:
                child.custom_minimum_size.x = 174
    var alchemy := building_operation_live_content.get_node_or_null("Art02AlchemyIngredientGallery") as HBoxContainer
    if alchemy != null:
        # Turn an overflowing horizontal recipe strip into a two-column real inventory view.
        var grid := GridContainer.new()
        grid.name = "Art05AlchemyRecipeGrid"
        grid.columns = 2
        grid.add_theme_constant_override("h_separation",6)
        grid.add_theme_constant_override("v_separation",6)
        var parent := alchemy.get_parent()
        var idx := alchemy.get_index()
        for item in alchemy.get_children():
            alchemy.remove_child(item)
            item.custom_minimum_size.x = 170
            grid.add_child(item)
        parent.remove_child(alchemy)
        alchemy.queue_free()
        parent.add_child(grid)
        parent.move_child(grid,idx)

func _art05_tint() -> void:
    var accent := _art05_accent()
    var frame := building_operation_panel.get_node_or_null("Art05PremiumJadeFrame")
    if frame != null:
        frame.set("accent",accent)
        frame.queue_redraw()
    if building_operation_scroll != null:
        _art05_style_content_tree(building_operation_scroll)
    if building_operation_live_content != null:
        _art05_style_content_tree(building_operation_live_content)

func _art05_style_content_tree(node: Node) -> void:
    for child in node.get_children():
        if child is Label:
            var label := child as Label
            label.add_theme_color_override("font_color",ART05_WHITE)
            label.add_theme_font_size_override("font_size",maxi(12,label.get_theme_font_size("font_size")))
            if label.text.length() > 90:
                label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        elif child is PanelContainer:
            var card := child as PanelContainer
            if card.name.begins_with("Art02Item_") or card.name.begins_with("ResourceBatchCard") or card.name.begins_with("SpiritPlotCard") or card.name.begins_with("LegacyResourceCycleCard"):
                card.add_theme_stylebox_override("panel",_art05_style(
                    Color(0.07,0.18,0.21,0.96),Color(0.42,0.61,0.55,0.6),1,8))
        elif child is Button:
            var button := child as Button
            button.custom_minimum_size.x = minf(button.custom_minimum_size.x,338.0)
            button.add_theme_font_size_override("font_size",maxi(12,button.get_theme_font_size("font_size")))
        elif child is ProgressBar:
            var bar := child as ProgressBar
            bar.custom_minimum_size.y = 7
        _art05_style_content_tree(child)
