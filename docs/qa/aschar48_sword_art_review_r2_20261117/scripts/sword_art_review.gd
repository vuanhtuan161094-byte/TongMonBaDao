extends Control

const CANVAS_SIZE := Vector2(1280.0, 720.0)
const CHAR_MALE := "res://assets/characters/AS48_MALE_IDENTITY_SOURCE.png"
const CHAR_FEMALE := "res://assets/characters/AS49_FEMALE_IDENTITY_SOURCE.png"
const OPTIONS := [
    {
        "id": "A",
        "title": "Huyền Mộc · Tứ Khung",
        "subtitle": "Lưỡi thon thẳng · hộ thủ khung đồng lệch",
        "path": "res://assets/weapons/SWORD_OPTION_A_HUYEN_MOC_TU_KHUNG_CANDIDATE.png",
        "detail": "Thép hun + đồng cổ + ngọc lục sẫm; hộ thủ hình khung giao lệch.",
        "shape": "Dáng hẹp, đường sống thẳng."
    },
    {
        "id": "B",
        "title": "Tử Yên · Song Khuyết",
        "subtitle": "Bản lá rộng · hai cửa rỗng · nút tím",
        "path": "res://assets/weapons/SWORD_OPTION_B_TU_YEN_SONG_KHUYET_CANDIDATE.png",
        "detail": "Thép ngà + men tím mận + đồng nhạt; hai khoảng âm trên lưỡi.",
        "shape": "Bản rộng, hộ thủ đan nút."
    },
    {
        "id": "C",
        "title": "Thanh Xà · Lưu Vân",
        "subtitle": "Lưỡi cong dài · hộ thủ dải gấp",
        "path": "res://assets/weapons/SWORD_OPTION_C_THANH_XA_LUU_VAN_CANDIDATE.png",
        "detail": "Men ngọc đen + đồng khắc; đường cong liên tục, hilt bất đối xứng.",
        "shape": "Lưỡi cong, profile khác hai mẫu thẳng."
    }
]

func _ready() -> void:
    get_window().size = Vector2i(1280, 720)
    _build_review()
    if OS.get_environment("TMB_CAPTURE_ONLY") == "1":
        call_deferred("_capture_native_viewport")

func _build_review() -> void:
    var background := ColorRect.new()
    background.color = Color("#17242d")
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(background)

    var header := PanelContainer.new()
    header.position = Vector2(22, 16)
    header.size = Vector2(1236, 86)
    header.add_theme_stylebox_override("panel", _panel_style("#213934", "#bda96d", 14))
    add_child(header)
    var header_box := VBoxContainer.new()
    header_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    header_box.offset_left = 18
    header_box.offset_top = 8
    header_box.offset_right = -18
    header_box.offset_bottom = -7
    header.add_child(header_box)

    var title := _label("KIẾM TU · DUYỆT 3 PHƯƠNG ÁN VŨ KHÍ", 25, "#f2d58a", HORIZONTAL_ALIGNMENT_CENTER)
    header_box.add_child(title)
    var subtitle := _label("AS-CHAR-48 Nam Kiếm Tu  +  AS-CHAR-49 Nữ Kiếm Tu  ·  1280×720  ·  concept art, chưa owner-approved", 14, "#e6eadf", HORIZONTAL_ALIGNMENT_CENTER)
    header_box.add_child(subtitle)

    for i in range(OPTIONS.size()):
        _build_card(i, OPTIONS[i])

    var footer := _label("52×52 là kích thước ô chân dung hiện tại ở P3.1 (PR72 HEAD); hàng nhỏ so sánh đúng kích thước này.\nPhần kiếm phóng to chỉ để soi chế tác. Sprite AS48/49 giữ kiếm bake cũ để nhận diện; A/B/C chưa ghép tay, pivot hay occlusion.", 12, "#e6d9bd", HORIZONTAL_ALIGNMENT_CENTER)
    footer.position = Vector2(30, 663)
    footer.size = Vector2(1220, 48)
    footer.clip_text = false
    add_child(footer)

func _build_card(index: int, data: Dictionary) -> void:
    var card_width := 394.0
    var x := 24.0 + index * 414.0
    var card := PanelContainer.new()
    card.position = Vector2(x, 116)
    card.size = Vector2(card_width, 548)
    card.add_theme_stylebox_override("panel", _panel_style("#f1ead7", "#9f8757", 12))
    add_child(card)

    var content := VBoxContainer.new()
    content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    content.offset_left = 12
    content.offset_top = 10
    content.offset_right = -12
    content.offset_bottom = -10
    content.add_theme_constant_override("separation", 3)
    card.add_child(content)

    var heading := _label("MẪU " + str(data["id"]) + "  ·  " + str(data["title"]), 18, "#24362f", HORIZONTAL_ALIGNMENT_CENTER)
    content.add_child(heading)
    var subtitle := _label(str(data["subtitle"]), 12, "#685b43", HORIZONTAL_ALIGNMENT_CENTER)
    content.add_child(subtitle)

    var display := PanelContainer.new()
    display.custom_minimum_size = Vector2(0, 315)
    display.size_flags_vertical = Control.SIZE_EXPAND_FILL
    display.add_theme_stylebox_override("panel", _panel_style("#e4dcc7", "#c7b990", 8))
    content.add_child(display)

    var stage := Control.new()
    stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    display.add_child(stage)

    var zoom_heading := _label("CHI TIẾT THIẾT KẾ · PHÓNG TO", 10, "#5d503a", HORIZONTAL_ALIGNMENT_CENTER)
    zoom_heading.position = Vector2(8, 7)
    zoom_heading.size = Vector2(350, 18)
    stage.add_child(zoom_heading)
    var weapon_detail := _make_texture_rect(str(data["path"]), Vector2(122, 26), Vector2(115, 230))
    stage.add_child(weapon_detail)

    var scale_heading := _label("SO SÁNH 52×52 · KÍCH THƯỚC Ô CHÂN DUNG HIỆN TẠI", 10, "#5d503a", HORIZONTAL_ALIGNMENT_CENTER)
    scale_heading.position = Vector2(8, 270)
    scale_heading.size = Vector2(350, 18)
    stage.add_child(scale_heading)
    var male := _make_texture_rect(CHAR_MALE, Vector2(54, 294), Vector2(52, 52))
    stage.add_child(male)
    var female := _make_texture_rect(CHAR_FEMALE, Vector2(142, 294), Vector2(52, 52))
    stage.add_child(female)
    var weapon_game_scale := _make_texture_rect(str(data["path"]), Vector2(242, 294), Vector2(52, 52))
    stage.add_child(weapon_game_scale)

    var male_tag := _label("AS-48 NAM", 9, "#33453e", HORIZONTAL_ALIGNMENT_CENTER)
    male_tag.position = Vector2(48, 346)
    male_tag.size = Vector2(64, 17)
    stage.add_child(male_tag)
    var female_tag := _label("AS-49 NỮ", 9, "#33453e", HORIZONTAL_ALIGNMENT_CENTER)
    female_tag.position = Vector2(136, 346)
    female_tag.size = Vector2(64, 17)
    stage.add_child(female_tag)
    var weapon_tag := _label("KIẾM 1×", 9, "#33453e", HORIZONTAL_ALIGNMENT_CENTER)
    weapon_tag.position = Vector2(236, 346)
    weapon_tag.size = Vector2(64, 17)
    stage.add_child(weapon_tag)

    var detail := _label(str(data["detail"]), 12, "#37483e", HORIZONTAL_ALIGNMENT_CENTER)
    detail.custom_minimum_size = Vector2(0, 40)
    detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content.add_child(detail)
    var shape := _label(str(data["shape"]), 11, "#765a35", HORIZONTAL_ALIGNMENT_CENTER)
    content.add_child(shape)

    var candidate := _label("CANDIDATE · chỉ duyệt mỹ thuật, chưa phải asset runtime", 10, "#8c3e2a", HORIZONTAL_ALIGNMENT_CENTER)
    candidate.custom_minimum_size = Vector2(0, 18)
    content.add_child(candidate)

func _make_texture_rect(path: String, position_value: Vector2, size_value: Vector2) -> TextureRect:
    var rect := TextureRect.new()
    rect.position = position_value
    rect.size = size_value
    rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    rect.texture = _crop_to_alpha(path)
    rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    return rect

func _crop_to_alpha(path: String) -> Texture2D:
    var source := load(path) as Texture2D
    if source == null:
        push_error("Missing review texture: " + path)
        return null
    var image := source.get_image()
    var region := image.get_used_rect()
    if region.size.x <= 0 or region.size.y <= 0:
        return source
    var crop := AtlasTexture.new()
    crop.atlas = source
    crop.region = region
    return crop

func _label(text_value: String, font_size: int, color_value: String, alignment: int) -> Label:
    var label := Label.new()
    label.text = text_value
    label.horizontal_alignment = alignment
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", Color(color_value))
    label.clip_text = true
    return label

func _panel_style(background: String, border: String, radius: int) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = Color(background)
    style.border_color = Color(border)
    style.set_border_width_all(1)
    style.set_corner_radius_all(radius)
    style.content_margin_left = 8
    style.content_margin_right = 8
    style.content_margin_top = 6
    style.content_margin_bottom = 6
    return style

func _capture_native_viewport() -> void:
    await get_tree().process_frame
    await get_tree().process_frame
    await RenderingServer.frame_post_draw
    var folder := ProjectSettings.globalize_path("res://captures")
    DirAccess.make_dir_recursive_absolute(folder)
    var output := folder.path_join("SWORD_ART_REVIEW_1280x720_GODOT.png")
    var image := get_viewport().get_texture().get_image()
    var error := image.save_png(output)
    if error != OK:
        push_error("Viewport PNG capture failed: " + str(error))
        get_tree().quit(1)
        return
    print("ASCHAR_V7_SWORD_REVIEW_CAPTURE size=1280x720 source=GodotViewport options=3 owner_approval=PENDING path=" + output)
    get_tree().quit(0)




