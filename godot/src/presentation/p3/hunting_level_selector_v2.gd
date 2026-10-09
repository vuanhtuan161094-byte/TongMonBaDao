class_name HuntingLevelSelectorV2
extends Control

# Reusable five-tier map choice screen. It changes the REAL persisted
# per-region selection; only the owner can start a live encounter.
# It is not mounted on SectMap by default (regions are outside the sect).
signal level_selected(region_id: String, level: int)
signal selection_refused(reason: String)

var game_state: SimulationState
var region_id: String = ""
var buttons: Dictionary = {}
var headline: Label
var resource_label: Label
var chosen_label: Label
var choices_root: VBoxContainer

func _ready() -> void:
    _build()
    _refresh()

func show_region(state: SimulationState, region: String) -> Dictionary:
    game_state = state
    region_id = region
    _build()
    _refresh()
    if state == null or not HuntingMapV2.REGION_CONTENT.has(region):
        return {"ok":false,"reason":"unknown_region_or_state"}
    return {"ok":true,"region_id":region,"selected_level":HuntingMapV2.selected_level(state,region)}

func select_level(level: int) -> Dictionary:
    if game_state == null:
        selection_refused.emit("missing_state")
        return {"ok":false,"reason":"missing_state"}
    var result := HuntingMapV2.choose_level(game_state,region_id,level)
    if bool(result.get("ok",false)):
        _refresh()
        level_selected.emit(region_id,level)
    else:
        selection_refused.emit(str(result.get("reason","unknown_error")))
    return result

func _build() -> void:
    if choices_root != null:
        return
    custom_minimum_size = Vector2(460,465)
    var root := VBoxContainer.new()
    root.name = "HuntingDifficultyChoices"
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(root)
    choices_root = root
    headline = Label.new()
    root.add_child(headline)
    resource_label = Label.new()
    resource_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    root.add_child(resource_label)
    for i in range(1,6):
        var button := Button.new()
        button.name = "Difficulty%d" % i
        button.custom_minimum_size = Vector2(420.0,48.0)
        button.pressed.connect(Callable(self,"select_level").bind(i))
        root.add_child(button)
        buttons[i] = button
    chosen_label = Label.new()
    root.add_child(chosen_label)

func _refresh() -> void:
    if choices_root == null:
        return
    var overview := HuntingMapV2.overview(region_id)
    if not bool(overview.get("ok",false)) or game_state == null:
        headline.text = "Chọn khu vực săn quái"
        resource_label.text = ""
        chosen_label.text = ""
        for b in buttons.values():
            b.disabled = true
        return
    headline.text = "%s — chọn độ khó" % str(overview["name"])
    var names: Array = overview["normal_resources"].keys()
    names.sort()
    var resource_names: PackedStringArray = PackedStringArray()
    var registry := ResourceRegistry.new()
    for id in names:
        resource_names.append(registry.display_name(StringName(id)))
    resource_names.append("Hiếm: "+registry.display_name(StringName(overview["rare_resource"])))
    resource_label.text = "Nguyên liệu: " + ", ".join(resource_names)
    var selected := HuntingMapV2.selected_level(game_state,region_id)
    for row in overview["levels"]:
        var tier := int(row["level"])
        var button: Button = buttons[tier]
        button.disabled = not game_state.sect.p3_7_resources_enabled
        button.text = "%d. %s  |  Quái: %d  |  HP: %.2fx  |  Nguyên liệu: %.2fx%s" % [
            tier,str(row["name"]),int(row["monster_count"]),
            float(row["monster_hp_factor"]),float(row["resource_yield_factor"]),
            "  ✓" if selected == tier else ""
        ]
    chosen_label.text = "Đã chọn cấp %d cho %s" % [selected,str(overview["name"])]
