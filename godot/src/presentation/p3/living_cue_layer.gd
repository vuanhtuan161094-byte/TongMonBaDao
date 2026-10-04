class_name LivingCueLayer
extends Control

signal cue_pressed(cue: Dictionary)

const DISCIPLE_OFFSET := Vector2(-66.0, -82.0)
const BUILDING_OFFSET := Vector2(-66.0, -58.0)
const CUE_SIZE := Vector2(132.0, 32.0)

var buttons: Dictionary = {}
var cue_by_key: Dictionary = {}

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    clip_contents = false
    z_index = 50

func show_cues(cues: Array[Dictionary], anchor_positions: Dictionary) -> void:
    var wanted: Dictionary = {}
    cue_by_key.clear()

    for cue_value in cues:
        var cue: Dictionary = cue_value
        var key := str(cue.get("stable_key", ""))
        if key == "":
            continue
        wanted[key] = true
        cue_by_key[key] = cue.duplicate(true)

        var button: Button
        if buttons.has(key) and is_instance_valid(buttons[key]):
            button = buttons[key] as Button
        else:
            button = Button.new()
            button.name = "LivingCue_%s" % key.replace(":", "_")
            button.size = CUE_SIZE
            button.add_theme_font_size_override("font_size", 11)
            button.mouse_filter = Control.MOUSE_FILTER_STOP
            button.pressed.connect(Callable(self, "_on_cue_pressed").bind(key))
            add_child(button)
            buttons[key] = button
            button.scale = Vector2(0.92, 0.92)
            var tween := create_tween()
            tween.tween_property(button, "scale", Vector2.ONE, 0.12)

        button.text = str(cue.get("text", ""))
        button.tooltip_text = str(cue.get("reason", ""))
        button.modulate = _severity_modulate(int(cue.get("severity", LivingCueResolver.SEVERITY_INFO)))
        _place_button(button, cue, anchor_positions.get(key, Vector2.ZERO))

    var stale: Array = []
    for key in buttons.keys():
        if not wanted.has(key):
            stale.append(key)
    for key in stale:
        var stale_button := buttons[key] as Button
        if stale_button != null and is_instance_valid(stale_button):
            stale_button.queue_free()
        buttons.erase(key)

func refresh_positions(cues: Array[Dictionary], anchor_positions: Dictionary) -> void:
    for cue_value in cues:
        var cue: Dictionary = cue_value
        var key := str(cue.get("stable_key", ""))
        if not buttons.has(key):
            continue
        var button := buttons[key] as Button
        if button == null or not is_instance_valid(button):
            continue
        _place_button(button, cue, anchor_positions.get(key, Vector2.ZERO))

func visible_count() -> int:
    var count := 0
    for value in buttons.values():
        var button := value as Button
        if button != null and is_instance_valid(button) and button.visible:
            count += 1
    return count

func _place_button(button: Button, cue: Dictionary, anchor: Vector2) -> void:
    var offset := BUILDING_OFFSET if StringName(cue.get("target_kind", "")) == LivingCueResolver.TARGET_BUILDING else DISCIPLE_OFFSET
    button.position = anchor + offset

func _on_cue_pressed(key: String) -> void:
    if not cue_by_key.has(key):
        return
    var cue: Dictionary = cue_by_key[key]
    cue_pressed.emit(cue.duplicate(true))

func _severity_modulate(severity: int) -> Color:
    match severity:
        LivingCueResolver.SEVERITY_CRITICAL:
            return Color(1.0, 0.78, 0.72, 1.0)
        LivingCueResolver.SEVERITY_ACTIONABLE:
            return Color(1.0, 0.92, 0.72, 1.0)
        LivingCueResolver.SEVERITY_OPERATIONAL:
            return Color(0.92, 0.95, 0.82, 1.0)
        _:
            return Color(0.90, 0.94, 0.98, 1.0)
