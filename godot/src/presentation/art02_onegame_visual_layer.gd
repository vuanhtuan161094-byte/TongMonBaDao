extends "res://src/presentation/p3_2_landscape_sect.gd"
## ART-02: presentation-only OneGame visual layer. All values come from canonical simulation.
## Deliberately avoids editing SaveService, BuildingSystem, Warehouse and combat.
const ITEM_ART = preload("res://src/presentation/uiux/sect_item_visual_v1.gd")
const ROOM_ART = preload("res://src/presentation/uiux/sect_facility_ambient_v1.gd")
const PANEL_ORNAMENT = preload("res://src/presentation/uiux/sect_operation_ornament_v1.gd")
const ART_GOLD := Color(0.95,0.75,0.43,1.0)
const ART_JADE := Color(0.30,0.84,0.68,1.0)
const ART_PURPLE := Color(0.72,0.51,0.96,1.0)
const ART_TRACK := Color(0.07,0.13,0.16,0.94)

func _build_building_operation_panel() -> void:
    super._build_building_operation_panel()
    if building_operation_panel == null:
        return
    var ornament := PANEL_ORNAMENT.new()
    ornament.name = "Art04CultivationFrame"
    ornament.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    ornament.mouse_filter = Control.MOUSE_FILTER_IGNORE
    building_operation_panel.add_child(ornament)
    building_operation_panel.move_child(ornament,0)

func _refresh_building_operation_art() -> void:
    super._refresh_building_operation_art()
    if building_operation_panel != null:
        var ornament := building_operation_panel.get_node_or_null("Art04CultivationFrame") as Control
        if ornament != null and str(ornament.get("facility_kind")) != str(selected_building):
            ornament.set("facility_kind",str(selected_building))
            ornament.queue_redraw()
    if building_operation_panel == null:
        return
    var host := building_operation_panel.get_node_or_null("BuildingOperationArtFrame/BuildingOperationArt") as Control
    if host == null:
        return
    var room := host.get_node_or_null("Art02FacilityAmbient") as Control
    if room == null:
        room = ROOM_ART.new()
        room.name = "Art02FacilityAmbient"
        room.mouse_filter = Control.MOUSE_FILTER_IGNORE
        room.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        host.add_child(room)
    room.set("facility_kind",str(selected_building))
    room.set("working",_art02_working_now())
    room.queue_redraw()

func _art02_working_now() -> bool:
    var site := _selected_operation_building()
    if site == null:
        return false
    var bs := BuildingSystem.new()
    match site.building_type:
        BuildingSystem.TYPE_MINE, BuildingSystem.TYPE_LINH_FOREST:
            return not bs.resource_timer_jobs(site).is_empty() or not _legacy_carry_cycle_rows(site).is_empty()
        BuildingSystem.TYPE_SPIRIT_FIELD:
            for raw_plot in bs.spirit_field_plots(state,site):
                if raw_plot is Dictionary and StringName(raw_plot.get("status","")) == BuildingSystem.PLOT_GROWING:
                    return true
        BuildingSystem.TYPE_ALCHEMY_HALL:
            return not bs.alchemy_jobs(state,site).is_empty()
    return false

func _refresh_mine_ore_hero() -> void:
    super._refresh_mine_ore_hero()
    if selected_building not in [SectMapPresentation.DEST_MINE,SectMapPresentation.DEST_LINH_FOREST]:
        return
    var picker := building_operation_panel.get_node_or_null("MineOreHero") as HBoxContainer
    if picker == null:
        return
    for node in picker.get_children():
        var button := node as Button
        if button == null:
            continue
        var id := ""
        if button.name.begins_with("MineOre_"):
            id = button.name.trim_prefix("MineOre_")
        elif button.name.begins_with("ForestMaterial_"):
            id = button.name.trim_prefix("ForestMaterial_")
        if id.is_empty() or not ResourceRegistry.new().has(StringName(id)):
            continue
        var art := ITEM_ART.icon(StringName(id),42)
        art.position = Vector2(6,17)
        art.size = Vector2(42,42)
        button.alignment = HORIZONTAL_ALIGNMENT_RIGHT
        button.add_child(art)

func _refresh_building_operation_live(operation_text: String) -> void:
    super._refresh_building_operation_live(operation_text)
    if building_operation_live_content == null:
        return
    match selected_building:
        SectMapPresentation.DEST_MINE, SectMapPresentation.DEST_LINH_FOREST:
            _art02_decorate_resource_jobs()
        SectMapPresentation.DEST_SPIRIT_FIELD:
            _art02_decorate_field_plots()
        SectMapPresentation.DEST_WAREHOUSE:
            _art02_show_warehouse_items()
        SectMapPresentation.DEST_ALCHEMY_HALL:
            _art02_show_alchemy_items()
    _art02_style_progress(building_operation_live_content)

func _art02_style_progress(parent: Node) -> void:
    for node in parent.get_children():
        if node is ProgressBar:
            var bar := node as ProgressBar
            bar.custom_minimum_size.y = 7
            bar.show_percentage = false
            var bg := StyleBoxFlat.new()
            bg.bg_color = ART_TRACK
            bg.border_color = Color(0.56,0.63,0.61,0.7)
            bg.set_border_width_all(1)
            bg.set_corner_radius_all(4)
            var fill := StyleBoxFlat.new()
            fill.bg_color = ART_PURPLE if selected_building == SectMapPresentation.DEST_ALCHEMY_HALL else (ART_GOLD if selected_building == SectMapPresentation.DEST_MINE else ART_JADE)
            fill.set_corner_radius_all(4)
            bar.add_theme_stylebox_override("background",bg)
            bar.add_theme_stylebox_override("fill",fill)
        else:
            _art02_style_progress(node)

func _art02_decorate_resource_jobs() -> void:
    var site := _selected_operation_building()
    if site == null:
        return
    var jobs := BuildingSystem.new().resource_timer_jobs(site)
    for index in range(jobs.size()):
        var job: Dictionary = jobs[index]
        var id := StringName(job.get("resource_id",""))
        var card := building_operation_live_content.get_node_or_null("ResourceBatchCard_%d" % index) as PanelContainer
        if card == null or not ResourceRegistry.new().has(id):
            continue
        var stack := card.get_child(0) as VBoxContainer
        if stack == null or stack.get_child_count() == 0:
            continue
        var title := stack.get_child(0) as Label
        if title == null:
            continue
        stack.remove_child(title)
        var header := HBoxContainer.new()
        header.name = "Art02ResourceBatchHeader"
        header.add_theme_constant_override("separation",5)
        header.add_child(ITEM_ART.icon(id,28))
        header.add_child(title)
        title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        stack.add_child(header)
        stack.move_child(header,0)
    if not jobs.is_empty():
        return
    var legacy := _legacy_carry_cycle_rows(site)
    for index in range(legacy.size()):
        var card := building_operation_live_content.get_node_or_null("LegacyResourceCycleCard_%d" % index) as PanelContainer
        if card == null:
            continue
        var stack := card.get_child(0) as VBoxContainer
        var header := stack.get_child(0) as HBoxContainer if stack != null and stack.get_child_count() > 0 else null
        if header == null:
            continue
        var old_icon := header.get_node_or_null("LegacyCycleResourceIcon")
        if old_icon != null:
            header.remove_child(old_icon)
            old_icon.queue_free()
        var id := StringName(legacy[index].get("resource_id",""))
        header.add_child(ITEM_ART.icon(id,28))
        header.move_child(header.get_child(header.get_child_count()-1),0)

func _art02_decorate_field_plots() -> void:
    var site := _selected_operation_building()
    if site == null:
        return
    var plots := BuildingSystem.new().spirit_field_plots(state,site)
    for index in range(plots.size()):
        var plot: Dictionary = plots[index]
        var card := building_operation_live_content.get_node_or_null("SpiritPlotCard_%d" % index) as PanelContainer
        if card == null:
            continue
        var stack := card.get_child(0) as VBoxContainer
        var header := stack.get_child(0) as HBoxContainer if stack != null and stack.get_child_count() > 0 else null
        if header == null:
            continue
        var glyph := header.get_node_or_null("SpiritPlotCropIcon_%d" % index)
        if glyph != null:
            header.remove_child(glyph)
            glyph.queue_free()
        var crop_id := StringName(plot.get("crop_id",""))
        var icon := ITEM_ART.icon(crop_id,29)
        header.add_child(icon)
        header.move_child(icon,0)

func _art02_item_card(id: StringName, title: String, detail: String, accent: Color) -> PanelContainer:
    var card := PanelContainer.new()
    card.name = "Art02Item_" + str(id).replace(".","_")
    card.custom_minimum_size = Vector2(126,82)
    var frame := StyleBoxFlat.new()
    frame.bg_color = Color(0.09,0.17,0.19,0.96)
    frame.border_color = accent.darkened(0.24)
    frame.set_border_width_all(1)
    frame.set_corner_radius_all(9)
    frame.content_margin_left = 4
    frame.content_margin_right = 4
    frame.content_margin_top = 3
    frame.content_margin_bottom = 3
    card.add_theme_stylebox_override("panel",frame)
    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation",1)
    card.add_child(stack)
    var top := HBoxContainer.new()
    top.add_theme_constant_override("separation",3)
    top.add_child(ITEM_ART.icon(id,39))
    var top_text := Label.new()
    top_text.text = title
    top_text.custom_minimum_size.x = 72
    top_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    top_text.add_theme_font_size_override("font_size",10)
    top_text.add_theme_color_override("font_color",Color(0.97,0.92,0.76))
    top.add_child(top_text)
    stack.add_child(top)
    var info := Label.new()
    info.text = detail
    info.add_theme_font_size_override("font_size",10)
    info.add_theme_color_override("font_color",accent)
    info.clip_text = true
    info.tooltip_text = detail
    stack.add_child(info)
    return card

func _art02_show_warehouse_items() -> void:
    if state == null:
        return
    var warehouse := WarehouseSystem.new()
    var gallery := GridContainer.new()
    gallery.name = "Art02WarehouseStockGallery"
    gallery.columns = 4
    gallery.add_theme_constant_override("h_separation",5)
    gallery.add_theme_constant_override("v_separation",5)
    var ids: Array[StringName] = warehouse_display_resource_ids
    if ids.is_empty():
        ids = ResourceRegistry.new().all_resource_ids()
    var shown := 0
    var more := 0
    for id in ids:
        var amount := warehouse.quantity(state,id)
        if amount <= 0:
            continue
        if shown >= 24:
            more += 1
            continue
        var available := warehouse.available_quantity(state,id)
        gallery.add_child(_art02_item_card(id,ResourceRegistry.new().display_name(id),"Kho %d · dùng %d" % [amount,available],ART_GOLD))
        shown += 1
    if shown == 0:
        var no_stock := Label.new()
        no_stock.name = "Art02WarehouseEmpty"
        no_stock.text = "Kho chưa có vật phẩm. Hình chỉ xuất hiện khi có tồn kho thật."
        no_stock.add_theme_color_override("font_color",Color(0.29,0.42,0.35))
        building_operation_live_content.add_child(no_stock)
        building_operation_live_content.move_child(no_stock,1)
        return
    gallery.tooltip_text = "%d loại đang hiển thị; còn %d loại, xem danh sách chi tiết bên dưới." % [shown,more]
    building_operation_live_content.add_child(gallery)
    building_operation_live_content.move_child(gallery,1)

func _art02_show_alchemy_items() -> void:
    if state == null:
        return
    var hall := _selected_operation_building()
    if hall == null or hall.building_type != BuildingSystem.TYPE_ALCHEMY_HALL:
        return
    var registry := AlchemyRecipeRegistry.new()
    var selected := StringName(hall.production_state.get("recipe_id","hoi_xuan_dan"))
    if not registry.has(selected):
        return
    var output := registry.output_resource_id(selected)
    var warehouse := WarehouseSystem.new()
    var gallery := HBoxContainer.new()
    gallery.name = "Art02AlchemyIngredientGallery"
    gallery.add_theme_constant_override("separation",5)
    var recipe_inputs := BuildingSystem.new().sx_v55_common_requirements(state,registry.inputs(selected))
    var ids: Array = recipe_inputs.keys()
    ids.sort()
    for raw_id in ids:
        var id := StringName(raw_id)
        var need := maxi(0,int(recipe_inputs[raw_id]))
        gallery.add_child(_art02_item_card(id,ResourceRegistry.new().display_name(id),"Có %d / cần %d" % [warehouse.available_quantity(state,id),need],ART_JADE))
    if output != &"":
        gallery.add_child(_art02_item_card(output,ResourceRegistry.new().display_name(output),"Mẻ ×%d · kho %d" % [registry.output_quantity(selected),warehouse.quantity(state,output)],ART_PURPLE))
    building_operation_live_content.add_child(gallery)
    building_operation_live_content.move_child(gallery,1)
    var jobs := BuildingSystem.new().alchemy_jobs(state,hall)
    for index in range(jobs.size()):
        var job: Dictionary = jobs[index]
        var from_tick := int(job.get("started_tick",-1))
        var end_tick := int(job.get("finish_tick",state.tick))
        var label := Label.new()
        label.name = "Art02AlchemyJobETA_%d" % index
        label.text = "Đan lô %d · còn %d phút mô phỏng · chưa nhập Kho" % [index+1,maxi(0,end_tick-state.tick)]
        label.add_theme_color_override("font_color",Color(0.24,0.45,0.43))
        label.add_theme_font_size_override("font_size",11)
        building_operation_live_content.add_child(label)
        building_operation_live_content.move_child(label,2+index*2)
        if from_tick >= 0 and end_tick > from_tick:
            var progress := ProgressBar.new()
            progress.name = "Art02AlchemyJobProgress_%d" % index
            progress.max_value = 100
            progress.value = 100.0*float(clampi(state.tick-from_tick,0,end_tick-from_tick))/float(end_tick-from_tick)
            progress.show_percentage = false
            progress.custom_minimum_size.y = 7
            building_operation_live_content.add_child(progress)
            building_operation_live_content.move_child(progress,3+index*2)
