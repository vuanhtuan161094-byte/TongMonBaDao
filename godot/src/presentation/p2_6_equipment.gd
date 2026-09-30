extends Control

const TEST_SEED := 1626262

var state: SimulationState
var actor: DiscipleState
var equipment := EquipmentSystem.new()
var summary_label: Label
var detail_label: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    state = P26Factory.create_state(TEST_SEED)
    actor = state.disciples.get(&"bach_nguyet")
    actor.wallet = 600
    actor.spend_bias = 0.90
    actor.cultivation_path_xp = {"sword":CultivationPathSystem.DEPTH_XP, "body":0.0, "spell":0.0}
    actor.spiritual_root_elements = ["metal"]
    actor.learned_techniques["thanh_phong_kiem_quyet"] = {"level":1, "xp":0.0}
    actor.active_technique_id = &"thanh_phong_kiem_quyet"
    state.sect.forge_materials = {"linh_moc":12, "thanh_thiet":12, "tinh_lang_bi":12, "yeu_dan":12}
    _build_ui()
    _refresh()

func _build_ui() -> void:
    var background := ColorRect.new()
    background.color = Color(0.055, 0.07, 0.065, 1.0)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 14)
    margin.add_theme_constant_override("margin_right", 14)
    margin.add_theme_constant_override("margin_top", 18)
    margin.add_theme_constant_override("margin_bottom", 18)
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(margin)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 10)
    margin.add_child(column)

    var title := Label.new()
    title.text = "TÔNG MÔN TYCOON — P2.6 LUYỆN KHÍ & TRANG BỊ"
    title.add_theme_font_size_override("font_size", 21)
    column.add_child(title)

    summary_label = Label.new()
    summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(summary_label)

    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 8)
    column.add_child(row)

    var forge_button := Button.new()
    forge_button.text = "Rèn Thanh Thiết Kiếm"
    forge_button.pressed.connect(_forge_sword)
    row.add_child(forge_button)

    var auto_button := Button.new()
    auto_button.text = "Cho đệ tử tự mua"
    auto_button.pressed.connect(_auto_buy)
    row.add_child(auto_button)

    var lock_button := Button.new()
    lock_button.text = "Khóa vũ khí"
    lock_button.pressed.connect(_lock_weapon)
    row.add_child(lock_button)

    var unlock_button := Button.new()
    unlock_button.text = "Trả về tự động"
    unlock_button.pressed.connect(_unlock_weapon)
    row.add_child(unlock_button)

    detail_label = Label.new()
    detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(detail_label)

func _forge_sword() -> void:
    equipment.craft(state, &"thanh_thiet_kiem", true)
    _refresh()

func _auto_buy() -> void:
    equipment.try_auto_upgrade(state, actor)
    _refresh()

func _lock_weapon() -> void:
    equipment.set_slot_lock(state, actor.id, EquipmentSystem.SLOT_WEAPON, true)
    _refresh()

func _unlock_weapon() -> void:
    equipment.return_slot_to_auto(state, actor.id, EquipmentSystem.SLOT_WEAPON)
    _refresh()

func _refresh() -> void:
    var equipped := equipment.equipped_item(state, actor, EquipmentSystem.SLOT_WEAPON)
    var equipped_name := "Chưa có"
    if not equipped.is_empty():
        equipped_name = "%s — %s" % [str(equipped.get("name", "?")), equipment.quality_name(StringName(equipped.get("quality", "pham")))]
    var locked := bool(actor.locked_equipment_slots.get("weapon", false))
    summary_label.text = "%s | ví %d | ngân khố %d | vũ khí: %s | khóa: %s" % [actor.display_name, actor.wallet, state.sect.treasury, equipped_name, "Có" if locked else "Không"]

    var shop_rows: Array[String] = []
    var ids: Array = state.sect.equipment_items.keys()
    ids.sort()
    for raw_id in ids:
        var item: Dictionary = state.sect.equipment_items[raw_id]
        if str(item.get("location", "")) == "shop":
            shop_rows.append("%s | %s | giá %d | điểm phù hợp %.1f" % [str(item.get("name", "?")), equipment.quality_name(StringName(item.get("quality", "pham"))), int(item.get("price", 0)), equipment.equipment_score(state, actor, item)])
    if shop_rows.is_empty():
        shop_rows.append("Cửa hàng chưa có trang bị. Hãy rèn một món trước.")

    detail_label.text = "Nguyên liệu Luyện Khí Đường: %s\n\nCửa hàng:\n%s\n\nLuồng P2.6: săn → nhập nguyên liệu → rèn → bán/cấp → tự chọn hoặc khóa tay → mạnh hơn → săn vùng khó hơn." % [str(state.sect.forge_materials), "\n".join(shop_rows)]
