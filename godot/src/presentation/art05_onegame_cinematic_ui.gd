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
const SECT_RUNTIME_PERF_HUD = preload("res://src/presentation/p3/sect_runtime_perf_hud.gd")
const SCHOOL_SKILLS_SCREEN = preload("res://src/presentation/p3/sect_school_skills_screen_v1.gd")
const ART05_BUILDING_VARIANT = preload("res://src/presentation/uiux/sect_building_art_variant_v3.gd")
const VIS07_APPROVED = preload("res://src/presentation/p3/tmb_approved_building_art_v4.gd")
const VIS08_ORIGINAL_BUILDINGS = preload("res://src/presentation/p3/tmb_original_building_art_v5.gd")
const VIS09_HANDPAINT = preload("res://src/presentation/p3/tmb_handpaint_building_art_v6.gd")
const VIS11_AB = preload("res://src/presentation/p3/tmb_building_art_ab_v7.gd")

func _ready() -> void:
    super._ready()
    if not runtime_ready:
        return
    _art05_style_global_hud()
    _art05_install_mockup_shell()
    _r2_skin_party_picker()
    _art05_build_sect_master_dock()
    _art05_refresh_sect_master_dock()
    _art05_sync_map_chrome()
    var aura := ART06_WORLD.new()
    aura.name = "Art06WorldAtmosphere"
    aura.position = Vector2(0,72)
    aura.size = Vector2(415,565)
    aura.mouse_filter = Control.MOUSE_FILTER_IGNORE
    aura.z_index = 4
    add_child(aura)
    # Opt-in performance telemetry works in the same Web Godot build. F8
    # toggles it; when hidden it has no per-frame sampling or UI updates.
    var perf_hud := SECT_RUNTIME_PERF_HUD.new()
    perf_hud.name = "SectRuntimePerfHud"
    add_child(perf_hud)

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
            # Re-evaluate visible siblings on every refresh, including a
            # previously active V3/ambient layer.
            for old_picture in override_host.get_children():
                if old_picture is CanvasItem and old_picture != picture:
                    old_picture.visible = false
            if picture == null:
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
    # A production tick may refresh this view many times. Reuse a single
    # imported sprite instead of retaining hidden copies indefinitely.
    var picture := host.get_node_or_null("ASBuildV3FacilitySprite") as TextureRect
    if picture == null:
        picture = TextureRect.new()
        picture.name = "ASBuildV3FacilitySprite"
        picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
        host.add_child(picture)
        picture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    picture.texture = tex
    picture.visible = true
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
            if hunting:
                # Keep the destination in the tooltip; long subtitles used to
                # collide with the actual left-side navigation glyph at 1×.
                button.text = "Săn quái"
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
        if child is Label and child != building_operation_title and child != building_operation_body and not str(child.name).begins_with("R2"):
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
            child.position = Vector2(16,300)
            child.size = Vector2(799,2)
    if building_operation_scroll != null:
        building_operation_scroll.position = Vector2(16,328)
        building_operation_scroll.size = Vector2(371,209)
        building_operation_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    if building_operation_content != null:
        building_operation_content.custom_minimum_size.x = 348
    if building_management_container != null:
        building_management_container.custom_minimum_size.x = 348
    if building_operation_live_panel != null:
        building_operation_live_panel.position = Vector2(400,328)
        building_operation_live_panel.size = Vector2(414,210)
        building_operation_live_panel.add_theme_stylebox_override("panel",_art05_style(
            Color(0.032,0.126,0.148,0.99),Color(0.42,0.58,0.53,0.55),1,10))
    if building_operation_live_scroll != null:
        building_operation_live_scroll.position = Vector2(9,8)
        building_operation_live_scroll.size = Vector2(395,193)
        building_operation_live_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    if building_operation_live_content != null:
        building_operation_live_content.custom_minimum_size.x = 370
    _art05_repack_galleries()
    _r2_operation_caption("R2ActionCaption","ĐIỀU PHỐI NHÂN SỰ",Vector2(18,304),Vector2(355,20))
    _r2_operation_caption("R2LiveCaption","HOẠT ĐỘNG THỰC TẾ",Vector2(405,304),Vector2(397,20))
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
    var portrait := panel.find_child("ASCharProfilePortrait", true, false) as Control
    if portrait == null:
        portrait = panel.find_child("SourceAProfilePortrait", true, false) as Control
    if portrait == null:
        portrait = panel.find_child("VisualCatalogPortraitFallback", true, false) as Control
    if portrait != null:
        var showcase := portrait.get_parent() as Control
        # The original TextureRect size was assigned before its expand mode,
        # so large imported portraits could keep a texture-sized minimum rect.
        # Assign the display bounds after disabling that minimum and reserve
        # an independent text region below the portrait.
        showcase.clip_contents = true
        if portrait is TextureRect:
            var art := portrait as TextureRect
            art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
            art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
            art.position = Vector2(24,10)
            art.size = Vector2(252,206)
        VIS_QUALITY.apply_edge(showcase, quality)
        VIS_QUALITY.apply_frame_material(showcase, quality)
        VIS_QUALITY.apply_backlight(showcase, Rect2(Vector2(12, 6), Vector2(276, 224)), quality)
        var actor_name := (state.disciples[disciple_id] as DiscipleState).display_name
        for child in showcase.get_children():
            if child is Label:
                var label := child as Label
                if label.text == actor_name or label.text.begins_with(str(DiscipleGeneratorV2.QUALITY_NAMES.get(quality, "---")) + " · "):
                    VIS_QUALITY.apply_name(label, quality)
                label.z_index = 2
                label.clip_text = true
                label.mouse_filter = Control.MOUSE_FILTER_IGNORE
        var caption_panel := Panel.new()
        caption_panel.name = "ProfileIdentityBackdrop"
        caption_panel.position = Vector2(8,220)
        caption_panel.size = Vector2(284,166)
        caption_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
        caption_panel.add_theme_stylebox_override("panel",_art05_style(Color(0.035,0.105,0.11,0.99),Color(0.48,0.59,0.51,0.75),1,10))
        showcase.add_child(caption_panel)
        showcase.move_child(caption_panel,portrait.get_index()+1)
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
            if portrait_row == null:
                portrait_row = entry.get_node_or_null("ASCharRosterCard")
            if portrait_row != null:
                for inner in portrait_row.find_children("*", "Label", true, false):
                    if inner is Label and (inner as Label).text == pieces[0]:
                        VIS_QUALITY.apply_name(inner as Label, entry_quality)
            else:
                VIS_QUALITY.apply_button(entry, entry_quality)
    # Reuse the canonical school action. Two overlapping school buttons previously
    # competed with the effects control for actual mouse input.
    var school_button := panel.get_node_or_null("DeepSchoolSkillsButton") as Button
    if school_button != null:
        school_button.text = "MÔN PHÁI / KỸ NĂNG"
        # The ART05 screen has a single canonical close/back flow.
        var old_action := Callable(self,"_open_aschar_school_screen").bind(disciple_id)
        if school_button.pressed.is_connected(old_action):
            school_button.pressed.disconnect(old_action)
        school_button.pressed.connect(Callable(self,"_aschar_open_school_skills").bind(disciple_id))
        school_button.position = Vector2(414,12)
        school_button.size = Vector2(323,44)
        school_button.add_theme_font_size_override("font_size",14)
        school_button.add_theme_stylebox_override("normal",_art05_style(ART05_JADE,ART05_GOLD,1,9))
    var toggle := Button.new()
    toggle.name = "VISReducedMotionToggle"
    toggle.text = "HIỆU ỨNG: %s" % VIS_QUALITY.mode_label()
    toggle.tooltip_text = "Chỉ giảm hiệu ứng phẩm chất; không thay đổi kỹ năng, thông số hoặc Save."
    toggle.position = Vector2(244,12)
    toggle.size = Vector2(158,44)
    toggle.add_theme_font_size_override("font_size",12)
    toggle.add_theme_color_override("font_color",ART05_WHITE)
    toggle.add_theme_stylebox_override("normal",_art05_style(ART05_JADE,ART05_GOLD,1,9))
    toggle.pressed.connect(Callable(self,"_vis_toggle_profile_reduced").bind(disciple_id,tab_name),CONNECT_DEFERRED)
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
        # These three dynamic labels were inherited from the light-paper
        # panel and rendered nearly black on the dark ART05 surface.
        if build_mode_description != null:
            build_mode_description.add_theme_color_override("font_color",ART05_WHITE)
            build_mode_description.add_theme_font_size_override("font_size",14)
            build_mode_description.position = Vector2(18,52)
            build_mode_description.size = Vector2(354,74)
        if build_mode_feedback != null:
            build_mode_feedback.position = Vector2(18,291)
            build_mode_feedback.size = Vector2(354,44)
            build_mode_feedback.add_theme_color_override("font_color",ART05_GOLD)
            build_mode_feedback.add_theme_font_size_override("font_size",12)
        if build_mode_site_label != null:
            build_mode_site_label.position = Vector2(18,337)
            build_mode_site_label.size = Vector2(354,52)
            build_mode_site_label.add_theme_color_override("font_color",ART05_WHITE)
            build_mode_site_label.add_theme_font_size_override("font_size",12)
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
    _art05_dock_destination = StringName(destination)
    _art05_dock_collapsed = false
    _art05_refresh_sect_master_dock()
    var anchors := SectResidenceSiteV1.map_anchors(int(state.sect.world_layout_version))
    var cell: Vector2i = anchors.get(destination,Vector2i(89,96))
    var world_point := SectIsometricWorldV1.LEGACY_ANCHOR \
        + SectIsometricWorldV1.project(Vector2(cell)) \
        - SectIsometricWorldV1.project(SectIsometricWorldV1.CENTER_CELL)
    # Shift the chosen landmark into the unobstructed center-left map area.
    var transform := SectMapCamera.focus_transform(world_point,0.88)
    var target: Vector2 = transform["position"]
    target.x -= 78.0
    _apply_camera(float(transform["zoom"]),SectMapCamera.clamp_position(target,float(transform["zoom"])),true)
    _art05_sync_map_chrome()

func _enter_build_mode() -> void:
    super._enter_build_mode()
    if iso_world != null and state != null and int(state.sect.world_layout_version) == 2:
        iso_world.set_masterplan_plots_visible(true)
        if iso_viewport != null:
            iso_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func _leave_build_mode(clear_selection: bool = true) -> void:
    if iso_world != null:
        iso_world.set_masterplan_plots_visible(false)
    super._leave_build_mode(clear_selection)

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
            build_mode_site_label.text = "Lô vàng: vị trí dự kiến. Chọn Mở rộng để tự tìm lô hợp lệ; không cần bấm đất."
        elif build_mode_confirm != null and build_mode_confirm.disabled:
            # Keep the canonical rejection reason instead of telling players to
            # confirm a blocked transaction. The fixed plan has no free pick.
            var conflict := _residence_site_actor_conflict_reason(build_mode_site)
            if conflict == "house_plot_actor_occupied":
                build_mode_site_label.text = "Lô quy hoạch (%d, %d): Đệ tử đang đứng trên lô/lối ra. Chờ di chuyển rồi thử lại." % [
                    build_mode_site.x,build_mode_site.y]
            # Other failed cost/site/Hall gates retain the base human-readable
            # reason authored by P3.2.
        else:
            build_mode_site_label.text = "Lô đã quy hoạch (%d, %d) · Xác nhận để khởi công." % [
                build_mode_site.x,build_mode_site.y]
    if build_mode_site_label != null:
        var blocked := build_mode_site != SectResidenceSiteV1.UNSELECTED and build_mode_confirm != null and build_mode_confirm.disabled
        build_mode_site_label.add_theme_color_override("font_color",Color(1.0,0.72,0.51) if blocked else ART05_WHITE)
    if build_mode_kind == "relocate":
        build_mode_kind = ""
        if build_mode_confirm != null:
            build_mode_confirm.disabled = true


# UI-MOCKUP-01: one real Godot screen, one resource authority, no fabricated
# inventory, combat state, construction progress, map pixels or saved settings.
var _art05_dock_panel: Panel
var _art05_dock_heading: Label
var _art05_dock_status: Label
var _art05_dock_body: Label
var _art05_dock_portrait: TextureRect
var _art05_dock_manage: Button
var _art05_district_links: Array[Button] = []
const A2_DISTRICT_LINKS := [
    [["main_hall","Đại Điện"]],
    [["residence","Đệ Tử Xá"],["guidance","Dẫn Tiên"],["medicine","Dược Phòng"]],
    [["cultivation","Tu Luyện"],["ren_than_duong","Rèn Thân"]],
    [["forge","Luyện Khí"],["warehouse","Kho"],["alchemy_hall","Luyện Đan"],["mine","Mỏ Khoáng"],["linh_forest","Linh Lâm"],["spirit_field","Linh Điền"]],
    [["gate","Xuất Chinh"]]
]
var _art05_dock_destination: StringName = &"main_hall"
var _art05_dock_collapsed := false
var _art05_active_nav := "home"

const ART05_SECT_DESCRIPTIONS := {
    "main_hall":"Điều hành tông môn, mở giới hạn và ban chính sách.",
    "residence":"Theo dõi sức chứa, sinh hoạt và quản lý đệ tử.",
    "cultivation":"Điều phối tu luyện, tu vi và rèn thân.",
    "forge":"Luyện khí, chế tác và kiểm soát sản xuất.",
    "warehouse":"Quản lý vật tư, đan dược, nguyên liệu và trang bị.",
    "guidance":"Chiêu mộ ứng viên, xem Lục Duy và phẩm chất.",
    "mine":"Khai thác khoáng vật và phân công đệ tử.",
    "linh_forest":"Thu hoạch linh mộc theo chu kỳ sản xuất.",
    "spirit_field":"Canh tác linh điền, thu hoạch và nhập Kho.",
    "gate":"Chuyển đến Thế Giới để thám hiểm hoặc xuất chinh."
}

# Keep the compact ART05 two-line header. Iron is the immediately actionable
# construction stock; the full material list remains in Warehouse and tooltip.
func _refresh_top_bar() -> void:
    if state == null or resource_label == null or time_label == null:
        return
    super._refresh_top_bar()
    resource_label.text = "Tiền %s   ◆  Linh thạch %s\nĐệ tử %d/%d  ·  Thiết %d/%d" % [
        _compact_number(state.sect.treasury),
        _compact_number(state.sect.spirit_stones),
        state.disciples.size(),
        state.sect.disciple_capacity,
        _warehouse_quantity(&"thanh_thiet"),
        _warehouse_available(&"thanh_thiet")
    ]

func _refresh_all() -> void:
    super._refresh_all()
    _art05_sync_map_chrome()
    if _art05_dock_panel != null:
        _art05_refresh_sect_master_dock()

# CanvasItem z_index changes rendering, not Control input order. A map
# shortcut added after the popup used to intercept real clicks on profiles.
func _art05_sync_map_chrome() -> void:
    var modal := _popup_is_open() or _pve_hunt_overlay_is_open()
    for entry in MASTERPLAN_DISTRICT_TABS:
        var tab := get_node_or_null("MasterplanDistrict_"+str(entry["key"])) as Button
        if tab != null:
            tab.visible = not modal
            var active := str(entry["key"]) == str(_art05_dock_destination)
            tab.add_theme_color_override("font_color",ART05_DEEP if active else ART05_WHITE)
            tab.add_theme_stylebox_override("normal",_art05_style(ART05_GOLD if active else Color(0.035,0.15,0.16,0.95),ART05_GOLD if active else ART05_MUTE,1,8))
    if gp1_guide_panel != null and (modal or _art05_dock_destination != &"main_hall" or _art05_dock_collapsed):
        gp1_guide_panel.visible = false

func _add_dim() -> void:
    super._add_dim()
    if popup_layer != null and popup_layer.get_parent() == self:
        move_child(popup_layer,get_child_count()-1)
    _art05_sync_map_chrome()

func _clear_popup() -> void:
    super._clear_popup()
    _art05_sync_map_chrome()

# Reuse the canonical buttons, actual map camera and existing actions.
# This is not a standalone HTML shell and introduces no duplicate controls.
func _art05_install_mockup_shell() -> void:
    if resource_label == null:
        return
    var top := resource_label.get_parent() as Panel
    if top != null:
        top.add_theme_stylebox_override("panel",_art05_style(
            Color(0.021,0.115,0.111,0.99),ART05_GOLD,1,0))
        for child in top.get_children():
            if not (child is Label):
                continue
            var label := child as Label
            if label.text == "TÔNG MÔN BÁ ĐẠO":
                label.position = Vector2(21,9)
                label.size = Vector2(420,34)
                label.add_theme_font_size_override("font_size",24)
                label.add_theme_color_override("font_color",ART05_GOLD)
            elif label.text == "TÔNG SƯ":
                label.position = Vector2(455,12)
                label.size = Vector2(166,45)
                label.add_theme_font_size_override("font_size",21)
                label.add_theme_color_override("font_color",ART05_GOLD)
        time_label.position = Vector2(23,43)
        time_label.size = Vector2(435,22)
        time_label.add_theme_color_override("font_color",ART05_MUTE)
        var playbook := Button.new()
        playbook.name = "OneGamePlaybookButton"
        playbook.text = "CÁCH CHƠI"
        playbook.tooltip_text = "Mở lộ trình phát triển tông môn bất cứ lúc nào"
        playbook.position = Vector2(632,16)
        playbook.size = Vector2(188,42)
        playbook.add_theme_font_size_override("font_size",16)
        playbook.add_theme_color_override("font_color",ART05_WHITE)
        playbook.add_theme_stylebox_override("normal",_art05_style(ART05_JADE,ART05_GOLD,1,10))
        playbook.add_theme_stylebox_override("hover",_art05_style(Color(0.16,0.30,0.25),ART05_GOLD,2,10))
        playbook.pressed.connect(_art05_open_playbook)
        top.add_child(playbook)
    resource_label.position = Vector2(840,10)
    resource_label.size = Vector2(414,57)
    resource_label.add_theme_font_size_override("font_size",15)
    resource_label.add_theme_color_override("font_color",ART05_WHITE)
    resource_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    resource_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _refresh_top_bar()
    # The first-minute card should guide without masking a full district.
    if gp1_guide_panel != null:
        gp1_guide_panel.position = Vector2(16,128)
        gp1_guide_panel.size = Vector2(260,124)
        if gp1_guide_title != null:
            gp1_guide_title.position = Vector2(12,9)
            gp1_guide_title.size = Vector2(222,27)
            gp1_guide_title.add_theme_font_size_override("font_size",15)
        if gp1_guide_description != null:
            gp1_guide_description.position = Vector2(12,39)
            gp1_guide_description.size = Vector2(236,44)
            gp1_guide_description.add_theme_font_size_override("font_size",12)
        if gp1_guide_button != null:
            gp1_guide_button.position = Vector2(12,83)
            gp1_guide_button.size = Vector2(236,32)
            gp1_guide_button.add_theme_font_size_override("font_size",13)
        var guide_close := gp1_guide_panel.get_node_or_null("Gp1GuideDismiss") as Button
        if guide_close != null:
            guide_close.position = Vector2(226,5)
            guide_close.size = Vector2(30,29)

    var bottom := get_node_or_null("PlayerBottomBar") as Panel
    if bottom != null:
        bottom.add_theme_stylebox_override("panel",_art05_style(
            Color(0.017,0.092,0.101,0.99),ART05_GOLD,1,0))
        var old_mark := bottom.get_node_or_null("Art05SectSignature") as Control
        if old_mark != null:
            old_mark.visible = false
        var ordered: Array[Button] = []
        for child in bottom.get_children():
            if child is Button:
                ordered.append(child as Button)
        if ordered.size() == 5:
            for i in range(ordered.size()):
                var button := ordered[i]
                var active := i == 0
                button.position = Vector2(43+i*245,10)
                button.size = Vector2(214,56)
                button.text = ["Tông Môn","Đệ Tử","Kho","Thế Giới","Săn Quái"][i]
                button.tooltip_text = [
                    "Về bản đồ tông môn và quản lý công trình",
                    "Xem tư chất, linh căn, công pháp và trang bị đệ tử",
                    "Xem tài nguyên thực có và lượng dùng được",
                    "Chọn khu vực lịch luyện và đường ra ngoài",
                    "Lập đội và vào bãi săn Thanh Trúc Lâm"
                ][i]
                button.add_theme_font_size_override("font_size",17)
                button.add_theme_color_override("font_color",ART05_DEEP if active else ART05_WHITE)
                button.add_theme_color_override("font_hover_color",ART05_GOLD)
                button.add_theme_color_override("font_pressed_color",ART05_DEEP)
                button.add_theme_stylebox_override("normal",_art05_style(
                    Color(0.97,0.87,0.65,1.0) if active else Color(0.045,0.17,0.17,0.99),
                    ART05_GOLD if active else Color(0.58,0.67,0.53,0.75),2 if active else 1,12))
                button.add_theme_stylebox_override("hover",_art05_style(
                    Color(0.12,0.27,0.26,0.99),ART05_GOLD,2,12))
                button.add_theme_stylebox_override("pressed",_art05_style(
                    Color(0.90,0.76,0.50,0.99),ART05_GOLD,2,12))
                button.add_theme_stylebox_override("focus",_art05_style(
                    Color(0.02,0.15,0.16,0.05),ART05_GOLD,2,12))
                var glyph := button.get_node_or_null("Art05NavigationGlyph") as Control
                if glyph != null:
                    glyph.position = Vector2(14,13)
                    glyph.size = Vector2(29,29)
                    glyph.set("tint",ART05_DEEP if active else ART05_GOLD)
                    glyph.queue_redraw()
                button.pressed.connect(Callable(self,"_art05_activate_nav").bind(i))
    # Narrow horizontal navigation ribbon leaves more of the terrain visible.
    if build_mode_button != null:
        build_mode_button.position = Vector2(16,80)
        build_mode_button.size = Vector2(144,36)
    for i in range(MASTERPLAN_DISTRICT_TABS.size()):
        var key := str(MASTERPLAN_DISTRICT_TABS[i]["key"])
        var tab := get_node_or_null("MasterplanDistrict_"+key) as Button
        if tab != null:
            tab.position = Vector2(168+i*131,80)
            tab.size = Vector2(123,36)
            tab.add_theme_font_size_override("font_size",12)
            tab.clip_text = true
    if camera_controls_panel != null:
        camera_controls_panel.position = Vector2(18,365)
        if focus_readout != null:
            focus_readout.visible = false
        camera_controls_panel.size = Vector2(58,252)
        camera_controls_panel.add_theme_stylebox_override("panel",_art05_style(
            Color(0.032,0.15,0.16,0.96),ART05_GOLD,1,12))
        for c in camera_controls_panel.get_children():
            if c is Button:
                var camera_button := c as Button
                camera_button.add_theme_color_override("font_color",ART05_WHITE)
                camera_button.add_theme_stylebox_override("normal",_art05_style(
                    Color(0.06,0.20,0.19,0.99),ART05_GOLD,1,8))
            elif c is Label:
                (c as Label).add_theme_color_override("font_color",ART05_WHITE)
    var camera_help := get_node_or_null("CameraHintBackground") as Control
    if camera_help != null:
        camera_help.position = Vector2(382,604)
        camera_help.size = Vector2(440,28)
    if camera_hint != null:
        camera_hint.position = Vector2(393,606)
        camera_hint.size = Vector2(422,24)
        camera_hint.text = "Kéo bản đồ · Cuộn để zoom · Chạm công trình để quản lý"

func _art05_activate_nav(index: int) -> void:
    _art05_active_nav = ["home","disciples","warehouse","world","hunt"][clampi(index,0,4)]
    var bottom := get_node_or_null("PlayerBottomBar") as Panel
    if bottom == null:
        return
    var i := 0
    for child in bottom.get_children():
        if not (child is Button):
            continue
        var active := i == index
        var button := child as Button
        button.add_theme_color_override("font_color",ART05_DEEP if active else ART05_WHITE)
        button.add_theme_stylebox_override("normal",_art05_style(
            Color(0.97,0.87,0.65,1) if active else Color(0.045,0.17,0.17,0.99),
            ART05_GOLD if active else Color(0.58,0.67,0.53,0.75),2 if active else 1,12))
        var glyph := button.get_node_or_null("Art05NavigationGlyph") as Control
        if glyph != null:
            glyph.set("tint",ART05_DEEP if active else ART05_GOLD)
            glyph.queue_redraw()
        i += 1

func _art05_dock_label(parent: Control, content: String, at: Vector2,
        size_px: Vector2, font_size: int, color: Color) -> Label:
    var label := Label.new()
    label.text = content
    label.position = at
    label.size = size_px
    label.add_theme_font_size_override("font_size",font_size)
    label.add_theme_color_override("font_color",color)
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(label)
    return label

func _art05_build_sect_master_dock() -> void:
    _art05_dock_panel = Panel.new()
    _art05_dock_panel.name = "SectMasterOverviewDock"
    _art05_dock_panel.position = Vector2(1000,128)
    _art05_dock_panel.size = Vector2(264,362)
    _art05_dock_panel.z_index = 31
    _art05_dock_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    _art05_dock_panel.add_theme_stylebox_override("panel",_art05_style(
        Color(0.022,0.115,0.119,0.965),ART05_GOLD,2,15))
    add_child(_art05_dock_panel)
    _art05_dock_portrait = TextureRect.new()
    _art05_dock_portrait.name = "SectMasterBuildingPortrait"
    _art05_dock_portrait.position = Vector2(11,12)
    _art05_dock_portrait.size = Vector2(78,68)
    _art05_dock_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _art05_dock_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    _art05_dock_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _art05_dock_panel.add_child(_art05_dock_portrait)
    _art05_dock_heading = _art05_dock_label(_art05_dock_panel,"ĐẠI ĐIỆN",
        Vector2(91,13),Vector2(142,48),19,ART05_GOLD)
    _art05_dock_status = _art05_dock_label(_art05_dock_panel,"",
        Vector2(14,82),Vector2(236,48),14,ART05_WHITE)
    var section1 := _art05_dock_label(_art05_dock_panel,"CHỨC NĂNG",
        Vector2(14,137),Vector2(236,19),13,ART05_GOLD)
    section1.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    _art05_dock_body = _art05_dock_label(_art05_dock_panel,"",
        Vector2(14,158),Vector2(236,62),12,ART05_WHITE)
    for index in range(6):
        var shortcut := Button.new()
        shortcut.name = "A2DistrictLink%d" % index
        shortcut.position = Vector2(14+(index%2)*120,224+floori(float(index)/2.0)*28)
        shortcut.size = Vector2(114,25)
        shortcut.add_theme_font_size_override("font_size",12)
        shortcut.add_theme_color_override("font_color",ART05_WHITE)
        shortcut.add_theme_stylebox_override("normal",_art05_style(Color(0.055,0.20,0.19,0.99),ART05_MUTE,1,7))
        shortcut.add_theme_stylebox_override("hover",_art05_style(Color(0.12,0.27,0.24,0.99),ART05_GOLD,1,7))
        shortcut.pressed.connect(_art05_open_district_link.bind(index))
        shortcut.visible = false
        _art05_dock_panel.add_child(shortcut)
        _art05_district_links.append(shortcut)
    _art05_dock_manage = Button.new()
    _art05_dock_manage.name = "SectMasterManage"
    _art05_dock_manage.text = "QUẢN LÝ"
    _art05_dock_manage.position = Vector2(14,310)
    _art05_dock_manage.size = Vector2(236,40)
    _art05_dock_manage.add_theme_font_size_override("font_size",18)
    _art05_dock_manage.add_theme_color_override("font_color",ART05_DEEP)
    _art05_dock_manage.add_theme_stylebox_override("normal",_art05_style(
        ART05_GOLD,Color(1.0,0.87,0.57,1.0),2,12))
    _art05_dock_manage.add_theme_stylebox_override("hover",_art05_style(
        Color(1.0,0.89,0.64),ART05_WHITE,2,12))
    _art05_dock_manage.pressed.connect(_art05_manage_selected_district)
    _art05_dock_panel.add_child(_art05_dock_manage)
    var close := Button.new()
    close.name = "SectMasterDockClose"
    close.text = "×"
    close.position = Vector2(227,6)
    close.size = Vector2(31,30)
    close.tooltip_text = "Ẩn thẻ thông tin. Chọn một khu để mở lại."
    close.add_theme_font_size_override("font_size",18)
    close.add_theme_color_override("font_color",ART05_GOLD)
    close.pressed.connect(_art05_collapse_dock)
    _art05_dock_panel.add_child(close)

func _art05_open_district_link(index: int) -> void:
    if index < 0 or index >= _art05_district_links.size():
        return
    var destination := str(_art05_district_links[index].get_meta("destination",""))
    if destination.is_empty():
        return
    _art05_dock_destination = StringName(destination)
    _art05_manage_selected_district()

func _art05_refresh_district_links(destination: String) -> void:
    var links: Array = []
    for district in A2_DISTRICT_LINKS:
        for entry in district:
            if str(entry[0]) == destination:
                links = district
                break
        if not links.is_empty():
            break
    # A one-link district already has its manage button. Do not waste a
    # line on a disabled duplicate. Short districts use a smaller card.
    # Keep only alternative destinations: the current site already has
    # its primary manage action, so no dead duplicate buttons.
    var alternatives: Array = []
    for entry in links:
        if str(entry[0]) != destination:
            alternatives.append(entry)
    links = alternatives
    var shown := links.size()
    var shortcut_rows := ceili(float(shown)/2.0)
    var action_y := 224.0+float(shortcut_rows)*28.0
    _art05_dock_manage.position.y = action_y
    _art05_dock_panel.size.y = action_y+52.0
    for index in range(_art05_district_links.size()):
        var shortcut := _art05_district_links[index]
        shortcut.visible = index < shown
        if shortcut.visible:
            var entry: Array = links[index]
            shortcut.text = str(entry[1])
            shortcut.set_meta("destination",str(entry[0]))
            shortcut.disabled = false

func _art05_collapse_dock() -> void:
    _art05_dock_collapsed = true
    _art05_refresh_sect_master_dock()
    _art05_sync_map_chrome()

func _art05_manage_selected_district() -> void:
    if _art05_dock_destination == SectMapPresentation.DEST_GATE:
        _bottom_action("world")
        _art05_activate_nav(3)
        return
    _open_building(_art05_dock_destination)

func _open_building(destination: StringName, instance_id: StringName = &"") -> void:
    _art05_dock_destination = destination
    _art05_dock_collapsed = false
    super._open_building(destination,instance_id)
    # Hide onboarding immediately, not only after the next simulation refresh:
    # it must never compete with a newly opened management panel.
    if gp1_guide_panel != null:
        gp1_guide_panel.visible = false
    _art05_refresh_sect_master_dock()

func _art05_refresh_sect_master_dock() -> void:
    if _art05_dock_panel == null or state == null:
        return
    _art05_dock_panel.visible = not _art05_dock_collapsed \
        and not _building_operation_is_open() and not _popup_is_open() \
        and not (build_mode_panel != null and build_mode_panel.visible) \
        and not _disciple_summary_is_open() and not _pve_hunt_overlay_is_open()
    if not _art05_dock_panel.visible:
        return
    var dest := str(_art05_dock_destination)
    var short_names := {
        "main_hall":"ĐẠI ĐIỆN","residence":"ĐỆ TỬ XÁ",
        "guidance":"DẪN TIÊN ĐÀI","cultivation":"TU LUYỆN",
        "forge":"LUYỆN KHÍ","warehouse":"KHO TÔNG MÔN",
        "mine":"MỎ KHOÁNG","linh_forest":"LINH LÂM",
        "spirit_field":"LINH ĐIỀN","gate":"CỔNG TÔNG MÔN"
    }
    _art05_dock_heading.text = str(short_names.get(dest,_building_name(_art05_dock_destination)))
    var live: BuildingState = null
    if _art05_dock_destination == SectMapPresentation.DEST_MAIN_HALL:
        live = SectHallSystemV1.hall(state)
    elif _art05_dock_destination == SectMapPresentation.DEST_RESIDENCE:
        var houses := SectResidenceSystemV1.all_houses(state)
        if not houses.is_empty():
            live = houses[0]
    else:
        for raw in state.buildings.values():
            if raw is BuildingState and str(raw.building_type) == dest:
                live = raw as BuildingState
                break
    var level := "Lv%d" % live.level if live != null else "Điểm điều phối"
    var assigned := 0
    if live != null:
        for raw_disciple in state.disciples.values():
            if raw_disciple is DiscipleState and str(raw_disciple.worksite_building_id) == str(live.id):
                assigned += 1
    _art05_dock_status.text = "CẤP / KHU VỰC    %s\nĐỆ TỬ                 %d / %d" % [
        level,state.disciples.size(),state.sect.disciple_capacity]
    if dest in ["mine","linh_forest","spirit_field"] and live != null:
        _art05_dock_status.text = "%s · %d người phân công\nĐã sản xuất: %d đơn vị" % [level,assigned,maxi(0,int(live.metrics.get("units_produced",0)))]
    var description := str(ART05_SECT_DESCRIPTIONS.get(dest,
        "Chọn Quản lý để xem số liệu và điều phối thực tế."))
    if dest == "main_hall":
        description += "\nChiêu mộ lệnh: %d" % state.sect.disciple_recruitment_tokens
    elif dest == "residence":
        description += "\nĐệ Tử Xá: %d nhà" % SectResidenceSystemV1.all_houses(state).size()
    _art05_dock_body.text = description
    _art05_refresh_district_links(dest)
    _art05_dock_manage.text = str({"gate":"RA THẾ GIỚI","guidance":"CHIÊU MỘ","mine":"ĐIỀU PHỐI MỎ","linh_forest":"ĐIỀU PHỐI RỪNG","spirit_field":"ĐIỀU PHỐI RUỘNG","warehouse":"MỞ KHO","cultivation":"TU LUYỆN"}.get(dest,"QUẢN LÝ"))
    if _art05_dock_portrait != null:
        var source: Texture2D = VIS11_AB.texture_for(_art05_dock_destination,&"A")
        if source == null:
            source = VIS08_ORIGINAL_BUILDINGS.texture_for(_art05_dock_destination)
        if source == null and SectIsometricWorldV1.MAP01_LANDMARKS.has(dest):
            source = SectIsometricWorldV1.MAP01_LANDMARKS[dest]
        if source == null and ART05_BUILDING_VARIANT.supported(_art05_dock_destination):
            source = ART05_BUILDING_VARIANT.texture_for(_art05_dock_destination,&"A",false)
        _art05_dock_portrait.texture = source


# UI-MOCKUP-02: categorized inventory in the existing real Warehouse modal.
# Read-only; the actual stock, reservations and item rules remain in WarehouseSystem.
func _art02_show_warehouse_items() -> void:
    if state == null or building_operation_live_content == null:
        return
    var warehouse := WarehouseSystem.new()
    var registry := ResourceRegistry.new()
    var ids: Array[StringName] = warehouse_display_resource_ids
    if ids.is_empty():
        ids = registry.all_resource_ids()
    var groups := {
        "KHOÁNG · LINH MỘC":[],
        "YÊU ĐAN · LINH TỦY · LINH DƯỢC":[],
        "CÔNG PHÁP · PHỤ KIỆN":[],
        "VẬT PHẨM KHÁC":[]
    }
    # These three genuine resource IDs were previously overexposed in the
    # universal top bar. Pin them in the appropriate Warehouse categories.
    var ordered: Array[StringName] = [
        &"thanh_thiet",&"yeu_dan",&"linh_tuy"
    ]
    for resource_id in ids:
        if resource_id not in ordered:
            ordered.append(resource_id)
    for resource_id in ordered:
        var amount := warehouse.quantity(state,resource_id)
        if amount <= 0:
            continue
        var family := str(registry.family(resource_id))
        var group := "VẬT PHẨM KHÁC"
        if family in ["mineral","wood","building_component"]:
            group = "KHOÁNG · LINH MỘC"
        elif family in ["monster_core","essence","herb","alchemy_material","medicine","pill"]:
            group = "YÊU ĐAN · LINH TỦY · LINH DƯỢC"
        elif family.begins_with("v63_codex") or family in ["manual","fragment","technique_material"]:
            group = "CÔNG PHÁP · PHỤ KIỆN"
        (groups[group] as Array).append(resource_id)
    var body := VBoxContainer.new()
    body.name = "SectWarehouseCategoryGroups"
    body.add_theme_constant_override("separation",9)
    building_operation_live_content.add_child(body)
    building_operation_live_content.move_child(body,1)
    var displayed := 0
    var total_nonzero := 0
    for rows in groups.values():
        total_nonzero += (rows as Array).size()
    var group_order := ["KHOÁNG · LINH MỘC",
        "YÊU ĐAN · LINH TỦY · LINH DƯỢC",
        "CÔNG PHÁP · PHỤ KIỆN","VẬT PHẨM KHÁC"]
    for group in group_order:
        var records := groups[group] as Array
        if records.is_empty() or displayed >= 24:
            continue
        var heading := Label.new()
        heading.name = "WarehouseGroupLabel_%d" % displayed
        heading.text = "%s   ·   %d loại" % [group,records.size()]
        heading.add_theme_font_size_override("font_size",13)
        heading.add_theme_color_override("font_color",ART05_GOLD)
        body.add_child(heading)
        var grid := GridContainer.new()
        grid.name = "Art02WarehouseStockGallery" if displayed == 0 else "WarehouseGrid_%d" % displayed
        grid.columns = 2
        grid.add_theme_constant_override("h_separation",6)
        grid.add_theme_constant_override("v_separation",6)
        body.add_child(grid)
        for id in records:
            if displayed >= 24:
                break
            var quantity := warehouse.quantity(state,id)
            var usable := warehouse.available_quantity(state,id)
            var card := _art02_item_card(id,registry.display_name(id),
                "Có %d  ·  Dùng %d" % [quantity,usable],ART05_GOLD)
            card.custom_minimum_size.x = 174
            grid.add_child(card)
            displayed += 1
    if displayed == 0:
        var empty := Label.new()
        empty.name = "SectWarehouseEmpty"
        empty.text = "Kho hiện chưa có vật tư có thể hiển thị."
        empty.add_theme_color_override("font_color",ART05_MUTE)
        body.add_child(empty)
    else:
        body.tooltip_text = "%d loại có tồn · hiện %d; xem chi tiết phía trái." % [
            total_nonzero,displayed]


# ASCHAR-GAME-01: real 12-school/36-branch onboarding from the disciple profile.
# School choice uses existing serialized v63_combat_branch_id, never a new Save
# schema or fake combat unlock; every learning/equipping request is delegated to
# the canonical V63 combat authority and respects its release gate.
var _aschar_school_screen: SectSchoolSkillsScreenV1

func _aschar_open_school_skills(disciple_id: StringName) -> void:
    if state == null or not state.disciples.has(disciple_id):
        return
    _clear_popup()
    _add_dim()
    var screen: SectSchoolSkillsScreenV1 = SCHOOL_SKILLS_SCREEN.new()
    screen.name = "SectSchoolSkillsScreenV1"
    screen.position = Vector2(48,81)
    screen.size = Vector2(1184,549)
    screen.attach(state,disciple_id)
    screen.branch_requested.connect(_aschar_assign_branch)
    screen.skill_action_requested.connect(_aschar_skill_action)
    screen.close_requested.connect(Callable(self,"_aschar_close_school_skills").bind(disciple_id))
    popup_layer.add_child(screen)
    _aschar_school_screen = screen

func _aschar_close_school_skills(disciple_id: StringName) -> void:
    _aschar_school_screen = null
    _open_disciple_deep_screen(disciple_id,"Công pháp")

func _aschar_assign_branch(disciple_id: StringName, branch_id: String) -> void:
    if state == null or not state.disciples.has(disciple_id):
        return
    var disciple: DiscipleState = state.disciples[disciple_id]
    var result := {"ok":false,"reason":"Phiên chơi chưa cho phép ghi dữ liệu"}
    if runtime_session != null and runtime_session.owner != null and not runtime_session.owner.runtime_write_blocked:
        if disciple.region_id == &"sect" and disciple.active_pve_encounter_id.is_empty() and disciple.injury_level == 0 and disciple.hp > 0.0:
            result = SectASCharCandidateBridgeV1.assign_branch(state,disciple,branch_id)
        else:
            result.reason = "Đệ tử phải ở tông môn và đủ sức khỏe"
    if bool(result.get("ok",false)):
        # Recreate only this presentation actor, keeping its live simulation ID,
        # route, job, inventory and position completely intact.
        _recycle_modular_actor(str(disciple_id))
        _refresh_world_actor_visibility()
        _autosave_runtime()
        if _aschar_school_screen != null and is_instance_valid(_aschar_school_screen):
            _aschar_school_screen.show_feedback("Đã bái môn: %s. Ngoại hình đổi theo môn phái." % str(result.get("name","")))
    else:
        if _aschar_school_screen != null and is_instance_valid(_aschar_school_screen):
            _aschar_school_screen.show_feedback("Không thể bái môn: "+str(result.get("reason","")))
    if _aschar_school_screen != null and is_instance_valid(_aschar_school_screen):
        _aschar_school_screen.refresh()

func _aschar_skill_action(disciple_id: StringName,skill_id: String,action: String) -> void:
    # Use the canonical profile implementation: it also handles V2 study,
    # equip/cancel methods, legacy method upgrades and Save authority.
    super._aschar_skill_action(disciple_id,skill_id,action)

# PRODUCT-UX: a reopenable player guide, not a second simulation or fake rewards.
# Every card invokes the existing authoritative OneGame navigation.
func _art05_open_playbook() -> void:
    if state == null or popup_layer == null or _pve_hunt_overlay_is_open():
        return
    _close_building_operation_panel(true)
    _close_disciple_summary(true)
    _clear_popup()
    _add_dim()
    var panel := Panel.new()
    panel.name = "OneGamePlaybook"
    panel.position = Vector2(170,98)
    panel.size = Vector2(940,520)
    panel.z_index = 45
    panel.mouse_filter = Control.MOUSE_FILTER_STOP
    panel.add_theme_stylebox_override("panel",_art05_style(ART05_DEEP,ART05_GOLD,2,18))
    popup_layer.add_child(panel)
    var heading := _art05_dock_label(panel,"LỘ TRÌNH TÔNG CHỦ",Vector2(24,16),Vector2(760,42),26,ART05_GOLD)
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    var intro := _art05_dock_label(panel,"Chọn một mục để mở đúng màn hình trong game. Không cần hoàn thành theo thứ tự cứng.",Vector2(25,58),Vector2(875,34),14,ART05_MUTE)
    intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    var close := Button.new()
    close.name = "OneGamePlaybookClose"
    close.text = "Đóng"
    close.position = Vector2(828,20)
    close.size = Vector2(88,36)
    close.add_theme_color_override("font_color",ART05_WHITE)
    close.add_theme_stylebox_override("normal",_art05_style(ART05_JADE,ART05_GOLD,1,8))
    close.pressed.connect(_clear_popup)
    panel.add_child(close)
    var cards := [
        ["01  TUYỂN ĐỆ TỬ","Xem phẩm chất và chỗ ở trước khi chiêu mộ. Mỗi lần nhận người dùng điều kiện thật.","recruit"],
        ["02  MÔN PHÁI & KỸ NĂNG","Xem linh căn, chọn nhánh một lần. Học và trang bị kỹ năng đủ điều kiện.","school"],
        ["03  SẢN XUẤT","Chọn người rảnh, phân công Mỏ, Linh Lâm hoặc Linh Điền. Theo dõi sản lượng và ETA.","production"],
        ["04  TU LUYỆN","Xem công pháp, tu vi, luyện thể và điều kiện đột phá trong hồ sơ đệ tử.","cultivation"],
        ["05  LỊCH LUYỆN","Lập đội đệ tử đủ sức khỏe. Chọn bãi săn, theo dõi giao chiến và chiến lợi phẩm.","hunt"],
        ["06  ĐAN DƯỢC & TRANG BỊ","Dùng vật liệu thực trong kho để luyện đan, luyện khí và mở rộng tông môn.","craft"]
    ]
    for i in range(cards.size()):
        var item: Array = cards[i]
        var tile := Panel.new()
        tile.position = Vector2(24+(i%2)*454,104+floori(float(i)/2.0)*132)
        tile.size = Vector2(438,120)
        tile.add_theme_stylebox_override("panel",_art05_style(ART05_JADE,Color(0.32,0.49,0.42),1,12))
        panel.add_child(tile)
        var title := _art05_dock_label(tile,str(item[0]),Vector2(13,9),Vector2(409,29),17,ART05_GOLD)
        title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
        var action := str(item[2])
        var needs_disciple := action in ["school","cultivation","hunt"]
        var recruit_first := needs_disciple and state.disciples.is_empty()
        var hint := str(item[1])
        if recruit_first:
            hint = "Chưa có đệ tử. Hãy chiêu mộ tại Dẫn Tiên Đài trước khi sử dụng chức năng này."
        elif action == "recruit":
            hint = "Đệ tử %d/%d • Chiêu mộ lệnh: %d. Xem ứng viên tại Dẫn Tiên Đài." % [state.disciples.size(),state.sect.disciple_capacity,state.sect.disciple_recruitment_tokens]
        var description := _art05_dock_label(tile,hint,Vector2(13,39),Vector2(409,41),13,ART05_WHITE)
        description.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
        var button := Button.new()
        button.name = "OneGamePlaybook_"+str(item[2])
        button.text = "TUYỂN TRƯỚC" if recruit_first else "MỞ"
        button.position = Vector2(298,82)
        button.size = Vector2(125,30)
        button.add_theme_color_override("font_color",ART05_DEEP)
        button.add_theme_stylebox_override("normal",_art05_style(ART05_GOLD,ART05_GOLD,1,7))
        button.pressed.connect(_art05_playbook_action.bind("recruit" if recruit_first else action))
        tile.add_child(button)
    if gp1_guide_panel != null:
        gp1_guide_panel.visible = false
    _art05_refresh_sect_master_dock()

func _art05_playbook_action(action: String) -> void:
    if state == null:
        return
    _clear_popup()
    var ids: Array = state.disciples.keys()
    ids.sort()
    var target_id: StringName = &""
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.region_id == &"sect" and disciple.active_pve_encounter_id.is_empty() and disciple.injury_level == 0 and disciple.hp > 0.0:
            target_id = disciple.id
            if str(disciple.v63_combat_branch_id).is_empty():
                break
    if target_id == &"" and not ids.is_empty():
        target_id = StringName(ids[0])
    if ids.is_empty() and action in ["school","cultivation","hunt"]:
        _open_building(SectMapPresentation.DEST_GUIDANCE)
        return
    match action:
        "recruit":
            _open_building(SectMapPresentation.DEST_GUIDANCE)
        "school":
            if target_id != &"":
                _aschar_open_school_skills(target_id)
        "production":
            _open_building(SectMapPresentation.DEST_MINE)
        "cultivation":
            if target_id != &"":
                _open_disciple_deep_screen(target_id,"Công pháp")
        "hunt":
            _open_pve_party_picker()
        "craft":
            _open_building(SectMapPresentation.DEST_ALCHEMY_HALL)

func _r2_operation_caption(node_name: String, caption: String, at: Vector2, dimensions: Vector2) -> void:
    var label := building_operation_panel.get_node_or_null(node_name) as Label
    if label == null:
        label = Label.new()
        label.name = node_name
        label.mouse_filter = Control.MOUSE_FILTER_IGNORE
        building_operation_panel.add_child(label)
    label.text = caption
    label.position = at
    label.size = dimensions
    label.add_theme_font_size_override("font_size",13)
    label.add_theme_color_override("font_color",ART05_GOLD)
    label.z_index = 2

func _r2_skin_party_picker() -> void:
    if pve_party_picker_panel == null:
        return
    pve_party_picker_panel.add_theme_stylebox_override("panel",_art05_style(ART05_DEEP,ART05_GOLD,2,18))
    for node in pve_party_picker_panel.get_children():
        if node is Label:
            var label := node as Label
            label.add_theme_color_override("font_color",ART05_GOLD if label.text.begins_with("CHỌN ĐỘI") else ART05_WHITE)
        elif node is Button:
            var button := node as Button
            var primary := button == pve_party_picker_start
            button.add_theme_color_override("font_color",ART05_DEEP if primary else ART05_WHITE)
            button.add_theme_stylebox_override("normal",_art05_style(ART05_GOLD if primary else ART05_JADE,ART05_GOLD,1,9))
            button.add_theme_stylebox_override("hover",_art05_style(Color(0.23,0.43,0.35),ART05_GOLD,2,9))
    if pve_party_picker_feedback != null:
        pve_party_picker_feedback.add_theme_color_override("font_color",Color(1.0,0.68,0.43))
