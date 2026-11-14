extends RefCounted
## VIS-04. Equipment material is independent of disciple identity quality.
## Read genuine EquipmentSystem grade IDs only. No save/stat/balance writes.
const GRADE_COLORS := {
    "pham": Color(0.42, 0.64, 0.60),
    "tinh": Color(0.36, 0.75, 0.82),
    "thuong": Color(0.98, 0.77, 0.45)
}

static func color_for(grade_id: String) -> Color:
    return GRADE_COLORS.get(grade_id, GRADE_COLORS["pham"])

static func apply_profile(panel: Control, disciple: DiscipleState, state: SimulationState) -> void:
    if panel == null or disciple == null or state == null:
        return
    var system := EquipmentSystem.new()
    for slot in EquipmentSystem.VALID_SLOTS:
        var key := str(slot)
        var equipped: Dictionary = system.equipped_item(state, disciple, slot)
        var label := panel.find_child("EquipmentCurrent_" + key, true, false) as Label
        if label != null and not equipped.is_empty():
            var grade := str(equipped.get("quality", "pham"))
            label.add_theme_color_override("font_color", color_for(grade))
            label.add_theme_color_override("font_outline_color", Color(0.015, 0.05, 0.06, 0.90))
            label.add_theme_constant_override("outline_size", 1)
            label.tooltip_text = "%s · %s" % [
                str(equipped.get("name", equipped.get("id", ""))),
                system.quality_name(StringName(grade))
            ]
        var picker := panel.find_child("EquipmentPicker_" + key, true, false) as OptionButton
        if picker == null or picker.item_count == 0 or picker.selected < 0:
            continue
        var id := str(picker.get_item_metadata(picker.selected))
        var item: Dictionary = state.sect.equipment_items.get(id, {})
        if item.is_empty():
            continue
        var accent := color_for(str(item.get("quality", "pham")))
        var style := StyleBoxFlat.new()
        style.bg_color = Color(0.045, 0.14, 0.165, 0.98)
        style.border_color = accent
        style.set_border_width_all(2)
        style.set_corner_radius_all(7)
        picker.add_theme_stylebox_override("normal", style)
        picker.add_theme_color_override("font_color", accent)
