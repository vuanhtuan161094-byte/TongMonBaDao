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
const ART06_WORLD = preload("res://src/presentation/uiux/sect_world_atmosphere_v1.gd")
const ART05_BUILDING_VARIANT = preload("res://src/presentation/uiux/sect_building_art_variant_v3.gd")
const VIS07_APPROVED = preload("res://src/presentation/p3/tmb_approved_building_art_v4.gd")

func _ready() -> void:
    super._ready()
    _art05_style_global_hud()
    var aura := ART06_WORLD.new()
    aura.name = "Art06WorldAtmosphere"
    aura.position = Vector2(0,72)
    aura.size = Vector2(415,565)
    aura.mouse_filter = Control.MOUSE_FILTER_IGNORE
    aura.z_index = 4
    add_child(aura)

func _refresh_building_operation_art() -> void:
    super._refresh_building_operation_art()
    if building_operation_panel == null:
        return
    if selected_building == SectMapPresentation.DEST_MINE:
        var mine_texture := VIS07_APPROVED.texture_for(&"mine")
        if mine_texture != null:
            var mine_host := building_operation_panel.get_node_or_null("BuildingOperationArtFrame/BuildingOperationArt") as Control
            if mine_host != null:
                var mine_picture := mine_host.get_node_or_null("VIS07OwnerApprovedMine") as TextureRect
                if mine_picture == null:
                    for old_picture in mine_host.get_children():
                        if old_picture is CanvasItem:
                            old_picture.visible = false
                    mine_picture = TextureRect.new()
                    mine_picture.name = "VIS07OwnerApprovedMine"
                    mine_picture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
                    mine_picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                    mine_picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                    mine_picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
                    mine_host.add_child(mine_picture)
                mine_picture.texture = mine_texture
                mine_picture.visible = true
        return
    if not ART05_BUILDING_VARIANT.supported(selected_building):
        return
    var host := building_operation_panel.get_node_or_null("BuildingOperationArtFrame/BuildingOperationArt") as Control
    if host == null:
        return
    var site := _selected_operation_building()
    var direction := &"B" if site != null and site.instance_index % 2 == 0 else &"A"
    var active := site != null and state != null and ART05_BUILDING_VARIANT.is_canonical_working(site,state.tick)
    var tex := ART05_BUILDING_VARIANT.texture_for(selected_building,direction,active)
    if tex == null and active:
        tex = ART05_BUILDING_VARIANT.texture_for(selected_building,direction,false)
    if tex == null:
        return
    # The base sketch remains only when a real asset import fails.
    for child in host.get_children():
        if child is CanvasItem:
            child.visible = false
    var picture := TextureRect.new()
    picture.name = "ASBuildV3FacilitySprite"
    picture.texture = tex
    picture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
    host.add_child(picture)
    var room := host.get_node_or_null("Art02FacilityAmbient") as Control
    if room != null and active and selected_building != SectMapPresentation.DEST_ALCHEMY_HALL:
        room.visible = true
        host.move_child(room,host.get_child_count()-1)

func _art05_style_global_hud() -> void:
    var bottom := get_node_or_null("PlayerBottomBar") as Panel
    if bottom != null:
        bottom.add_theme_stylebox_override("panel",_art05_style(
            Color(0.022,0.094,0.110,0.99),ART05_GOLD,2,0))
        var buttons: Array[Button] = []
        for node in bottom.get_children():
            if node is Button:
                buttons.append(node as Button)
        for idx in range(buttons.size()):
            var button := buttons[idx]
            var hunting := button.name == "PveHuntQuickEntry"
            button.position = Vector2(950 if hunting else 126+idx*203,11)
            button.size = Vector2(275 if hunting else 185,54)
            button.add_theme_font_size_override("font_size",15)
            button.add_theme_color_override("font_color",ART05_WHITE)
            button.add_theme_color_override("font_hover_color",ART05_GOLD)
            button.add_theme_stylebox_override("normal",_art05_style(
                Color(0.05,0.19,0.21,0.98),Color(0.59,0.68,0.53,0.9),1,10))
            button.add_theme_stylebox_override("hover",_art05_style(
                Color(0.11,0.28,0.29,0.99),ART05_GOLD,2,10))
            button.add_theme_stylebox_override("pressed",_art05_style(
                Color(0.23,0.28,0.21,0.98),ART05_GOLD,2,10))
            var icon := SECT_UI_ICON.new()
            icon.name = "Art05NavigationGlyph"
            icon.kind = "gate" if hunting else ["hall","person","resource","map"][mini(idx,3)]
            icon.tint = ART05_GOLD
            icon.position = Vector2(10,11)
            icon.size = Vector2(30,30)
            icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
            button.add_child(icon)
    # Replace the incompatible beige onboarding card's palette, never hide its instructions.
    if gp1_guide_panel != null:
        gp1_guide_panel.add_theme_stylebox_override("panel",_art05_style(
            Color(0.035,0.13,0.15,0.98),ART05_GOLD,1,10))
        _art05_tint_onboarding(gp1_guide_panel)

func _art05_tint_onboarding(root: Node) -> void:
    for child in root.get_children():
        if child is Label:
            child.add_theme_color_override("font_color",ART05_WHITE)
            child.add_theme_font_size_override("font_size",maxi(12,child.get_theme_font_size("font_size")))
        _art05_tint_onboarding(child)

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
                var value := metric.find_child("MetricValue",true,false) as Label
                if value != null:
                    value.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
                    value.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
                    value.max_lines_visible = 2
                    value.add_theme_font_size_override("font_size",14)
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
    if building_operation_scroll != null:
        building_operation_scroll.clip_contents = true
    if building_operation_live_panel != null:
        building_operation_live_panel.clip_contents = true

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
        grid.name = "Art02AlchemyIngredientGallery"
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
    var aura := get_node_or_null("Art06WorldAtmosphere") as Control
    if aura != null:
        aura.set("accent",accent)
        aura.call("set_activity",_art02_working_now())
    if building_operation_scroll != null:
        _art05_style_content_tree(building_operation_scroll)
    if building_operation_live_content != null:
        _art05_style_content_tree(building_operation_live_content)

func _art05_style_content_tree(node: Node) -> void:
    for child in node.get_children():
        if child is Label:
            var label := child as Label
            label.add_theme_color_override("font_color",ART05_WHITE)
            label.custom_minimum_size.x = minf(label.custom_minimum_size.x,357.0)
            label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            # VIS-07 screenshot review: operation details were too fine at
            # 1280x720. Enforce a restrained 13px floor inside scrolling panels.
            label.add_theme_font_size_override("font_size",maxi(13,label.get_theme_font_size("font_size")))
            if label.text.length() > 90:
                label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        elif child is PanelContainer:
            var card := child as PanelContainer
            if card.name.begins_with("Art02Item_") or card.name.begins_with("ResourceBatchCard") or card.name.begins_with("SpiritPlotCard") or card.name.begins_with("LegacyResourceCycleCard"):
                # VIS-06: consistent material for genuine warehouse/alchemy
                # cards; do not invent a grade for an ungraded stack.
                var accent := _art05_accent()
                var finish := _art05_style(Color(0.054,0.142,0.166,0.98),
                    Color(accent.r,accent.g,accent.b,0.74),1,8)
                finish.shadow_color = Color(accent.r,accent.g,accent.b,0.13)
                finish.shadow_size = 3
                card.add_theme_stylebox_override("panel",finish)
        elif child is Button:
            var button := child as Button
            button.custom_minimum_size.x = minf(button.custom_minimum_size.x,338.0)
            button.clip_text = true
            if button.text.contains("Xây thêm") and button.text.length() > 22:
                button.tooltip_text = button.text
                button.text = "＋ Xây thêm công trình"
            button.add_theme_font_size_override("font_size",maxi(12,button.get_theme_font_size("font_size")))
        elif child is ProgressBar:
            var bar := child as ProgressBar
            bar.custom_minimum_size.y = 7
        _art05_style_content_tree(child)


# VIS-01/02: additive quality presentation on the one real playable scene.
const VIS_QUALITY = preload("res://src/presentation/uiux/sect_quality_visual_v1.gd")
const VIS_EQUIPMENT = preload("res://src/presentation/uiux/sect_equipment_material_v1.gd")

func _refresh_disciple_summary_content() -> void:
    super._refresh_disciple_summary_content()
    if disciple_summary_panel == null or state == null or not state.disciples.has(selected_id):
        return
    var actor: DiscipleState = state.disciples[selected_id]
    var quality := str(actor.disciple_quality)
    VIS_QUALITY.apply_name(disciple_summary_name, quality)
    VIS_QUALITY.apply_edge(disciple_summary_panel, quality)

func _open_disciple_deep_screen(disciple_id: StringName, tab_name: String = "Tổng Quan", preserve_feedback: bool = false) -> void:
    super._open_disciple_deep_screen(disciple_id, tab_name, preserve_feedback)
    if state == null or not state.disciples.has(disciple_id) or popup_layer == null:
        return
    var panel := popup_layer.find_child("DiscipleDeepScreen", true, false) as Panel
    if panel == null:
        return
    var quality := str((state.disciples[disciple_id] as DiscipleState).disciple_quality)
    var portrait := panel.find_child("SourceAProfilePortrait", true, false) as Control
    if portrait == null:
        portrait = panel.find_child("VisualCatalogPortraitFallback", true, false) as Control
    if portrait != null:
        var showcase := portrait.get_parent() as Control
        VIS_QUALITY.apply_edge(showcase, quality)
        VIS_QUALITY.apply_frame_material(showcase, quality)
        VIS_QUALITY.apply_backlight(showcase, Rect2(Vector2(12, 6), Vector2(276, 224)), quality)
        var actor_name := (state.disciples[disciple_id] as DiscipleState).display_name
        for child in showcase.get_children():
            if child is Label:
                var label := child as Label
                if label.text == actor_name or label.text.begins_with(str(DiscipleGeneratorV2.QUALITY_NAMES.get(quality, "---")) + " · "):
                    VIS_QUALITY.apply_name(label, quality)
    var roster := panel.find_child("DeepDiscipleRoster", true, false) as VBoxContainer
    if roster != null:
        for raw_entry in roster.get_children():
            if not (raw_entry is Button):
                continue
            var entry := raw_entry as Button
            var pieces := entry.tooltip_text.split(" · ")
            if pieces.size() < 2:
                continue
            var entry_quality := VIS_QUALITY.id_from_name(pieces[1])
            if entry_quality.is_empty():
                continue
            var old_style := entry.get_theme_stylebox("normal") as StyleBoxFlat
            if old_style != null:
                var new_style := old_style.duplicate() as StyleBoxFlat
                new_style.border_color = VIS_QUALITY.color_for(entry_quality)
                entry.add_theme_stylebox_override("normal", new_style)
            var portrait_row := entry.get_node_or_null("VerifiedSourceARosterCard")
            if portrait_row != null:
                for inner in portrait_row.find_children("*", "Label", true, false):
                    if inner is Label and (inner as Label).text == pieces[0]:
                        VIS_QUALITY.apply_name(inner as Label, entry_quality)
            else:
                VIS_QUALITY.apply_button(entry, entry_quality)
    var toggle := Button.new()
    toggle.name = "VISReducedMotionToggle"
    toggle.text = "HIỆU ỨNG: %s" % VIS_QUALITY.mode_label()
    toggle.tooltip_text = "Chỉ giảm hiệu ứng phẩm chất; không thay đổi kỹ năng, thông số hoặc Save."
    toggle.position = Vector2(515, 15)
    toggle.size = Vector2(205, 38)
    toggle.add_theme_font_size_override("font_size", 12)
    toggle.add_theme_color_override("font_color", ART05_WHITE)
    toggle.add_theme_stylebox_override("normal", _art05_style(ART05_JADE, ART05_GOLD, 1, 9))
    toggle.pressed.connect(Callable(self, "_vis_toggle_profile_reduced").bind(disciple_id, tab_name))
    panel.add_child(toggle)
    if tab_name == "Trang bị":
        VIS_EQUIPMENT.apply_profile(panel, state.disciples[disciple_id] as DiscipleState, state)

func _vis_toggle_profile_reduced(disciple_id: StringName, tab_name: String) -> void:
    VIS_QUALITY.cycle_mode()
    _open_disciple_deep_screen(disciple_id, tab_name, true)
