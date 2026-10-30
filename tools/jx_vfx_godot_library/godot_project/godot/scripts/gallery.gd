extends Control

const PAGE_SIZE := 24
const VIEW_SIZE := Vector2i(340, 240)

var catalog := JXVfxCatalog.new()
var player := JXVfxPlayer.new()
var filtered: Array = []
var selected: Dictionary = {}
var page := 0
var play_handle := 0

var search_box: LineEdit
var source_filter: OptionButton
var status_filter: OptionButton
var page_label: Label
var grid: GridContainer
var detail: Label
var direction_filter: SpinBox
var preview_size_filter: OptionButton
var display_root: Node2D
var display_viewport: SubViewport

func _ready() -> void:
	var error := catalog.load_index("res://catalog/library_index.json")
	if error != OK:
		push_error("Could not load catalog/library_index.json: %s" % error)
		return
	player.set_catalog(catalog)
	add_child(player)
	_build_ui()
	_build_filters()
	_render_page()

func _build_ui() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)
	var root := VBoxContainer.new()
	margin.add_child(root)
	var heading := Label.new()
	heading.text = "JX VFX Local Library · Godot Gallery"
	heading.add_theme_font_size_override("font_size", 21)
	root.add_child(heading)
	var note := Label.new()
	note.text = "Presentation-only preview · source WebP textures remain local · engine playback must be verified on this machine"
	note.add_theme_color_override("font_color", Color(0.65, 0.78, 0.78))
	root.add_child(note)
	var filters := HBoxContainer.new()
	root.add_child(filters)
	search_box = LineEdit.new()
	search_box.placeholder_text = "Search file, skill, or SHA"
	search_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search_box.text_changed.connect(_on_filter_changed)
	filters.add_child(search_box)
	source_filter = OptionButton.new()
	source_filter.item_selected.connect(_on_filter_changed)
	filters.add_child(source_filter)
	status_filter = OptionButton.new()
	status_filter.item_selected.connect(_on_filter_changed)
	filters.add_child(status_filter)
	var split := HSplitContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(split)
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_child(scroll)
	grid = GridContainer.new()
	grid.columns = 4
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)
	var inspector := VBoxContainer.new()
	inspector.custom_minimum_size.x = 390
	split.add_child(inspector)
	var preview_panel := PanelContainer.new()
	preview_panel.custom_minimum_size = Vector2(VIEW_SIZE.x, VIEW_SIZE.y)
	inspector.add_child(preview_panel)
	display_viewport = SubViewport.new()
	display_viewport.size = VIEW_SIZE
	display_viewport.transparent_bg = true
	display_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var viewport_box := SubViewportContainer.new()
	viewport_box.stretch = true
	viewport_box.custom_minimum_size = Vector2(VIEW_SIZE)
	preview_panel.add_child(viewport_box)
	viewport_box.add_child(display_viewport)
	display_root = Node2D.new()
	display_viewport.add_child(display_root)
	detail = Label.new()
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inspector.add_child(detail)
	var controls := HBoxContainer.new()
	inspector.add_child(controls)
	direction_filter = SpinBox.new()
	direction_filter.min_value = 0
	direction_filter.max_value = 15
	direction_filter.step = 1
	direction_filter.prefix = "row "
	controls.add_child(direction_filter)
	preview_size_filter = OptionButton.new()
	for pixel_size in [48, 64, 75, 96]:
		preview_size_filter.add_item("%d px" % pixel_size)
	preview_size_filter.select(3)
	controls.add_child(preview_size_filter)
	var play_button := Button.new()
	play_button.text = "Play source-timed frames"
	play_button.pressed.connect(_play_selected)
	controls.add_child(play_button)
	var stop_button := Button.new()
	stop_button.text = "Stop"
	stop_button.pressed.connect(_stop_selected)
	controls.add_child(stop_button)
	var pages := HBoxContainer.new()
	root.add_child(pages)
	var prev := Button.new()
	prev.text = "Previous"
	prev.pressed.connect(_previous_page)
	pages.add_child(prev)
	page_label = Label.new()
	page_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pages.add_child(page_label)
	var next := Button.new()
	next.text = "Next"
	next.pressed.connect(_next_page)
	pages.add_child(next)

func _previous_page() -> void:
	page = maxi(0, page - 1)
	_render_page()

func _next_page() -> void:
	page += 1
	_render_page()

func _build_filters() -> void:
	source_filter.clear()
	source_filter.add_item("All sources")
	var source_ids: Array = []
	for record in catalog.all_records:
		var source_id := String(record.get("source_id", ""))
		if not source_ids.has(source_id):
			source_ids.append(source_id)
	source_ids.sort()
	for source_id in source_ids:
		source_filter.add_item(source_id)
	status_filter.clear()
	status_filter.add_item("All metadata states")
	var statuses: Array = []
	for record in catalog.all_records:
		var value := String(record.get("catalog_status", "UNKNOWN"))
		if not statuses.has(value):
			statuses.append(value)
	statuses.sort()
	for value in statuses:
		status_filter.add_item(value)

func _on_filter_changed(_value: Variant = null) -> void:
	page = 0
	_render_page()

func _render_page() -> void:
	for child in grid.get_children():
		grid.remove_child(child)
		child.free()
	filtered.clear()
	var query := search_box.text.strip_edges().to_lower()
	var source_value := "" if source_filter.selected == 0 else source_filter.get_item_text(source_filter.selected)
	var status_value := "" if status_filter.selected == 0 else status_filter.get_item_text(status_filter.selected)
	for record in catalog.all_records:
		if not source_value.is_empty() and String(record.get("source_id", "")) != source_value:
			continue
		if not status_value.is_empty() and String(record.get("catalog_status", "")) != status_value:
			continue
		if not query.is_empty() and not JSON.stringify(record).to_lower().contains(query):
			continue
		filtered.append(record)
	var page_count := maxi(1, ceili(float(filtered.size()) / PAGE_SIZE))
	page = clampi(page, 0, page_count - 1)
	page_label.text = "%d entries · page %d / %d · Godot status: PENDING_ENGINE" % [filtered.size(), page + 1, page_count]
	var start := page * PAGE_SIZE
	var stop := mini(filtered.size(), start + PAGE_SIZE)
	var visible_ids: Array[String] = []
	for index in range(start, stop):
		var record: Dictionary = filtered[index]
		var effect_id := String(record.get("record_id", ""))
		visible_ids.append(effect_id)
		var card := VBoxContainer.new()
		card.custom_minimum_size = Vector2(180, 142)
		var texture_view := TextureRect.new()
		texture_view.custom_minimum_size = Vector2(176, 98)
		texture_view.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		texture_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_view.texture = player.get_texture(effect_id)
		card.add_child(texture_view)
		var choose := Button.new()
		choose.text = String(record.get("filename", effect_id))
		choose.pressed.connect(_select_record.bind(record))
		card.add_child(choose)
		var state := Label.new()
		state.text = String(record.get("catalog_status", ""))
		state.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		state.add_theme_font_size_override("font_size", 10)
		card.add_child(state)
		grid.add_child(card)
	player.release_unused(visible_ids)

func _select_record(record: Dictionary) -> void:
	_stop_selected()
	selected = record
	var id := String(record.get("record_id", ""))
	var texture := player.get_texture(id)
	for child in display_root.get_children():
		child.queue_free()
	if texture != null:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.position = Vector2(VIEW_SIZE) * 0.5
		sprite.scale = Vector2.ONE * minf(float(VIEW_SIZE.x) / texture.get_width(), float(VIEW_SIZE.y) / texture.get_height())
		display_root.add_child(sprite)
	var animation: Dictionary = record.get("animation", {})
	direction_filter.max_value = maxi(0, int(animation.get("directions", 1)) - 1)
	detail.text = "%s\n%s · %s px\nSHA-256 %s\n%s\nTimed playback requires explicit verified millisecond timing." % [String(record.get("filename", id)), String(record.get("source_id", "")), str(record.get("size_px", [])), String(record.get("sha256", "")), String(record.get("catalog_status", ""))]

func _play_selected() -> void:
	if selected.is_empty():
		return
	_stop_selected()
	for child in display_root.get_children():
		child.queue_free()
	var animation: Dictionary = selected.get("animation", {})
	var frame_width := 1.0
	var frame_height := 1.0
	var frame_size: Array = animation.get("frame_size", [])
	if frame_size.size() == 2:
		frame_width = float(frame_size[0])
		frame_height = float(frame_size[1])
	elif String(animation.get("layout", "")) == "rects":
		var rects: Array = animation.get("rects", [])
		if not rects.is_empty() and rects[0] is Array and rects[0].size() >= 4:
			frame_width = float(rects[0][2])
			frame_height = float(rects[0][3])
	elif String(animation.get("layout", "")) == "paged_rects":
		var regions: Array = animation.get("frame_regions", [])
		if not regions.is_empty() and regions[0] is Dictionary:
			var region_rect: Array = regions[0].get("rect", [])
			if region_rect.size() == 4:
				frame_width = float(region_rect[2])
				frame_height = float(region_rect[3])
	var pixel_size := int(preview_size_filter.get_item_text(preview_size_filter.selected).replace(" px", ""))
	var preview_scale := float(pixel_size) / maxf(frame_width, frame_height)
	play_handle = player.play(String(selected.get("record_id", "")), display_root, Vector2(VIEW_SIZE) * 0.5, {"loop": true, "direction": int(direction_filter.value), "scale": preview_scale})
	if play_handle == 0:
		detail.text += "\nPlayback unavailable: inspect player error signal or metadata status."

func _stop_selected() -> void:
	if play_handle != 0:
		player.stop(play_handle)
		play_handle = 0
