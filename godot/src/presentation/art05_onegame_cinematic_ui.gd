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
const VIS08_ORIGINAL_BUILDINGS = preload("res://src/presentation/p3/tmb_original_building_art_v5.gd")
const VIS09_HANDPAINT = preload("res://src/presentation/p3/tmb_handpaint_building_art_v6.gd")
const VIS11_AB = preload("res://src/presentation/p3/tmb_building_art_ab_v7.gd")

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
    var current_site := _selected_operation_building()
    var op_direction: StringName = &"B" if current_site != null and current_site.instance_index % 2 == 0 and selected_building != SectMapPresentation.DEST_MAIN_HALL else &"A"
    var override_texture: Texture2D = VIS11_AB.texture_for(selected_building,op_direction)
    if override_texture == null:
        override_texture = VIS08_ORIGINAL_BUILDINGS.texture_for(selected_building)
    if override_texture == null and selected_building == SectMapPresentation.DEST_MINE:
        override_texture = VIS09_HANDPAINT.texture_for(&"mine")
    if override_texture != null:
        var override_host := building_operation_panel.get_node_or_null("BuildingOperationArtFrame/BuildingOperationArt") as Control
        if override_host != null:
            var picture := override_host.get_node_or_null("VIS08OriginalBuildingSprite") as TextureRect
            if picture == null:
                for old_picture in override_host.get_children():
                    if old_picture is CanvasItem:
                        old_picture.visible = false
                picture = TextureRect.new()
                picture.name = "VIS08OriginalBuildingSprite"
                picture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
                picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
                override_host.add_child(picture)
            picture.texture = override_texture
            picture.visible = true
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
        # A readable, quiet sect signature occupies the unused left margin.
        # It is strictly presentation-only and never obscures navigation.
        var signature := Panel.new()
        signature.name = "Art05SectSignature"
        signature.position = Vector2(12,11)
        signature.size = Vector2(106,55)
        signature.mouse_filter = Control.MOUSE_FILTER_IGNORE
        signature.add_theme_stylebox_override("panel",_art05_style(
            Color(0.048,0.157,0.163,0.98),Color(ART05_GOLD.r,ART05_GOLD.g,ART05_GOLD.b,0.68),1,9))
        bottom.add_child(signature)
        var signature_top := Label.new()
        signature_top.text = "TÔNG MÔN"
        signature_top.position = Vector2(7,7)
        signature_top.size = Vector2(92,20)
        signature_top.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        signature_top.add_theme_font_size_override("font_size",12)
        signature_top.add_theme_color_override("font_color",ART05_MUTE)
        signature_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
        signature.add_child(signature_top)
        var signature_name := Label.new()
        signature_name.text = "BÁ ĐẠO"
        signature_name.position = Vector2(7,25)
        signature_name.size = Vector2(92,23)
        signature_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        signature_name.add_theme_font_size_override("font_size",18)
        signature_name.add_theme_color_override("font_color",ART05_GOLD)
        signature_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
        signature.add_child(signature_name)
        var buttons: Array[Button] = []
        for node in bottom.get_children():
            if node is Button:
                buttons.append(node as Button)
        for idx in range(buttons.size()):
            var button := buttons[idx]
            var hunting := button.name == "PveHuntQuickEntry"
            button.position = Vector2(950 if hunting else 132+idx*202,11)
            button.size = Vector2(275 if hunting else 186,54)
            button.add_theme_font_size_override("font_size",16 if hunting else 15)
            button.add_theme_color_override("font_color",ART05_GOLD if hunting else ART05_WHITE)
            button.add_theme_color_override("font_hover_color",ART05_WHITE)
            button.add_theme_color_override("font_pressed_color",ART05_WHITE)
            button.tooltip_text = button.text
            button.add_theme_stylebox_override("normal",_art05_style(
                Color(0.27,0.155,0.065,0.99) if hunting else Color(0.05,0.19,0.21,0.98),
                ART05_GOLD if hunting else Color(0.49,0.67,0.57,0.75),2 if hunting else 1,10))
            button.add_theme_stylebox_override("hover",_art05_style(
                Color(0.36,0.21,0.08,0.99) if hunting else Color(0.11,0.28,0.29,0.99),
                ART05_GOLD,2,10))
            button.add_theme_stylebox_override("pressed",_art05_style(
                Color(0.23,0.28,0.21,0.98),ART05_GOLD,2,10))
            button.add_theme_stylebox_override("focus",_art05_style(
                Color(0.05,0.19,0.21,0.03),ART05_GOLD,2,10))
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
            Color(0.035,0.13,0.15,0.985),ART05_GOLD,2,12))
        _art05_tint_onboarding(gp1_guide_panel)
        if gp1_guide_title != null:
            gp1_guide_title.add_theme_color_override("font_color",ART05_GOLD)
            gp1_guide_title.add_theme_font_size_override("font_size",17)
        if gp1_guide_description != null:
            gp1_guide_description.add_theme_color_override("font_color",ART05_WHITE)
            gp1_guide_description.add_theme_font_size_override("font_size",13)
        if gp1_guide_button != null:
            gp1_guide_button.add_theme_color_override("font_color",ART05_DEEP)
            gp1_guide_button.add_theme_color_override("font_hover_color",ART05_DEEP)
            gp1_guide_button.add_theme_stylebox_override("normal",_art05_style(
                ART05_GOLD,Color(0.98,0.87,0.59),1,8))
            gp1_guide_button.add_theme_stylebox_override("hover",_art05_style(
                Color(1.0,0.87,0.57),ART05_WHITE,2,8))
        var dismiss := gp1_guide_panel.get_node_or_null("Gp1GuideDismiss") as Button
        if dismiss != null:
            dismiss.add_theme_color_override("font_color",ART05_MUTE)
            dismiss.add_theme_color_override("font_hover_color",ART05_WHITE)
            dismiss.add_theme_stylebox_override("normal",_art05_style(
                Color(0.08,0.18,0.20,0.9),ART05_MUTE,1,8))
            dismiss.add_theme_stylebox_override("hover",_art05_style(
                ART05_JADE,ART05_GOLD,1,8))

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


# MASTERPLAN-01: only map/UI policy, no new world-placement Save field.
# The existing paid ResidenceSystem is preserved. New UI offers a preplanned
# lot rather than exposing player placement or relocation on the map.
const MASTERPLAN_DISTRICT_TABS := [
    {"name":"ĐẠI ĐIỆN","key":"main_hall","hint":"Trung tâm quyền lực và chính sách"},
    {"name":"NỘI VIỆN","key":"residence","hint":"Đệ Tử Xá, Dẫn Tiên và chăm sóc"},
    {"name":"TU LUYỆN","key":"cultivation","hint":"Tu luyện và rèn thân"},
    {"name":"SẢN XUẤT","key":"forge","hint":"Kho, luyện khí, luyện đan và tài nguyên"},
    {"name":"XUẤT CHINH","key":"gate","hint":"Cổng tông môn và đường ra thế giới"}
]

func _build_construction_ui() -> void:
    super._build_construction_ui()
    if state == null or int(state.sect.world_layout_version) != 2:
        return
    if build_mode_button != null:
        build_mode_button.text = "QUY HOẠCH"
        build_mode_button.position = Vector2(20,90)
        build_mode_button.size = Vector2(167,45)
        build_mode_button.tooltip_text = "Mở rộng nhà theo lô đã quy hoạch; không kéo-thả công trình."
    if build_mode_panel != null:
        build_mode_panel.size = Vector2(392,450)
        build_mode_panel.add_theme_stylebox_override("panel",
            _art05_style(Color(0.026,0.10,0.12,0.99),ART05_GOLD,2,13))
        for child in build_mode_panel.get_children():
            if child is Label:
                var label := child as Label
                if label.text == "KIẾN THIẾT TÔNG MÔN":
                    label.text = "QUY HOẠCH TÔNG MÔN"
                    label.add_theme_color_override("font_color",ART05_GOLD)
                elif label.text == "ĐẶT TRÊN BẢN ĐỒ":
                    label.text = "KHU NỘI VIỆN · ĐỆ TỬ XÁ"
                    label.add_theme_color_override("font_color",ART05_MUTE)
                elif label.text.begins_with("Đệ Tử Xá: có giao dịch"):
                    label.text = "Vị trí được chọn sẵn theo quy hoạch.\nGiữ nguyên chi phí xây và điều kiện Đại Điện."
                    label.add_theme_color_override("font_color",ART05_WHITE)
                elif label.text == "DI DỜI NHÀ PHỤ ĐỦ ĐIỀU KIỆN":
                    label.visible = false
        var moves := build_mode_panel.get_node_or_null("RelocatableResidenceList") as Control
        if moves != null:
            moves.visible = false
        var open_hall := build_mode_panel.get_node_or_null("BuildModeOpenHall") as Button
        if open_hall != null:
            open_hall.position = Vector2(18,247)
            open_hall.text = "ĐẠI ĐIỆN · XEM ĐIỀU KIỆN MỞ RỘNG"
        if build_mode_feedback != null:
            build_mode_feedback.position = Vector2(18,291)
        if build_mode_site_label != null:
            build_mode_site_label.position = Vector2(18,337)
        if build_mode_confirm != null:
            build_mode_confirm.position = Vector2(18,393)
        var cancel := build_mode_panel.get_node_or_null("CancelMapConstruction") as Button
        if cancel != null:
            cancel.position = Vector2(198,393)
    # District tabs operate on the same camera as building hitboxes.
    for index in range(MASTERPLAN_DISTRICT_TABS.size()):
        var row: Dictionary = MASTERPLAN_DISTRICT_TABS[index]
        var key := str(row["key"])
        var nav := Button.new()
        nav.name = "MasterplanDistrict_"+key
        nav.text = str(row["name"])
        nav.tooltip_text = str(row["hint"])
        nav.position = Vector2(205+index*196,90)
        nav.size = Vector2(185,45)
        nav.z_index = 28
        nav.add_theme_font_size_override("font_size",13)
        nav.add_theme_color_override("font_color",ART05_WHITE)
        nav.add_theme_color_override("font_hover_color",ART05_GOLD)
        nav.add_theme_stylebox_override("normal",_art05_style(
            Color(0.035,0.15,0.16,0.95),Color(0.54,0.68,0.60,0.7),1,9))
        nav.add_theme_stylebox_override("hover",_art05_style(
            Color(0.11,0.25,0.25,0.99),ART05_GOLD,2,9))
        nav.add_theme_stylebox_override("pressed",_art05_style(
            Color(0.18,0.25,0.19,0.99),ART05_GOLD,2,9))
        nav.pressed.connect(Callable(self,"_art05_focus_masterplan_district").bind(key))
        add_child(nav)

func _art05_focus_masterplan_district(destination: String, close_panels: bool = true) -> void:
    if iso_world == null or state == null:
        return
    if close_panels:
        _leave_build_mode(true)
        _close_building_operation_panel(true)
        _close_disciple_summary(true)
    var anchors := SectResidenceSiteV1.map_anchors(int(state.sect.world_layout_version))
    var cell: Vector2i = anchors.get(destination,Vector2i(89,96))
    var world_point := SectIsometricWorldV1.LEGACY_ANCHOR \
        + SectIsometricWorldV1.project(Vector2(cell)) \
        - SectIsometricWorldV1.project(SectIsometricWorldV1.CENTER_CELL)
    var transform := SectMapCamera.focus_transform(world_point,0.88)
    _apply_camera(float(transform["zoom"]),transform["position"],true)

func _focus_buildable_residence_area() -> void:
    if state == null or int(state.sect.world_layout_version) != 2:
        super._focus_buildable_residence_area()
        return
    _art05_focus_masterplan_district("residence",false)

func _begin_residence_construction() -> void:
    super._begin_residence_construction()
    if state == null or int(state.sect.world_layout_version) != 2:
        return
    var chosen := SectResidenceSiteV1.UNSELECTED
    for raw_site in SectResidenceSiteV1.MASTERPLAN_ANNEX_SITES:
        var site: Vector2i = raw_site
        if not bool(SectResidenceSiteV1.check(state,site).get("ok",false)):
            continue
        if not _residence_site_actor_conflict_reason(site).is_empty():
            continue
        chosen = site
        break
    if chosen == SectResidenceSiteV1.UNSELECTED:
        build_mode_kind = ""
        if build_mode_feedback != null:
            build_mode_feedback.text = "Các lô đã quy hoạch hiện chưa đủ điều kiện. Hãy nâng cấp Đại Điện hoặc chờ lô trống."
        _refresh_build_mode_panel()
        return
    # Use the existing real build quote and click-confirm transaction.
    super._select_build_mode_site(chosen)

func _select_build_mode_site(site: Vector2i) -> void:
    if state != null and int(state.sect.world_layout_version) == 2 and build_mode_active:
        # The user cannot override the planned plot by tapping arbitrary terrain.
        return
    super._select_build_mode_site(site)

func _begin_residence_relocation(house_id: StringName) -> void:
    if state != null and int(state.sect.world_layout_version) == 2:
        if build_mode_feedback != null:
            build_mode_feedback.text = "Chế độ quy hoạch cố định chưa hỗ trợ di dời nhà."
        return
    super._begin_residence_relocation(house_id)

func _refresh_build_mode_panel(last_check: Dictionary = {}) -> void:
    super._refresh_build_mode_panel(last_check)
    if state == null or int(state.sect.world_layout_version) != 2 or build_mode_panel == null:
        return
    var build_house := build_mode_panel.get_node_or_null("BuildCatalogResidence") as Button
    if build_house != null:
        build_house.text = "MỞ RỘNG ĐỆ TỬ XÁ · LÔ CỐ ĐỊNH"
    if build_mode_site_label != null:
        if build_mode_site == SectResidenceSiteV1.UNSELECTED:
            build_mode_site_label.text = "Chọn Mở rộng Đệ Tử Xá. Tông môn tự xác định lô hợp lệ; không cần bấm đất."
        else:
            build_mode_site_label.text = "Lô đã quy hoạch (%d, %d) · Xác nhận để khởi công." % [
                build_mode_site.x,build_mode_site.y]
    if build_mode_kind == "relocate":
        build_mode_kind = ""
        if build_mode_confirm != null:
            build_mode_confirm.disabled = true
