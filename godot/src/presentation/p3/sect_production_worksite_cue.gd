class_name SectProductionWorksiteCue
extends Control

# Small, read-only map badge. Never schedules work, mutates BuildingState,
# pays wages, settles inventory, or infers the outcome of a growing crop.
const CARD_SIZE := Vector2(170.0,66.0)
const INK := Color(0.16,0.14,0.11,1.0)
const PAPER := Color(0.96,0.92,0.80,0.97)
const JADE := Color(0.17,0.40,0.31,1.0)

var heading: Label
var detail: Label
var progress: ProgressBar
var receipt: Label
var receipt_tween: Tween
var last_display_signature := ""

func _ready() -> void:
    name = "WorksiteCue"
    size = CARD_SIZE
    custom_minimum_size = CARD_SIZE
    mouse_filter = Control.MOUSE_FILTER_IGNORE

    var background := Panel.new()
    background.name = "Background"
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var style := StyleBoxFlat.new()
    style.bg_color = PAPER
    style.border_color = INK
    style.set_border_width_all(1)
    style.set_corner_radius_all(7)
    background.add_theme_stylebox_override("panel",style)
    add_child(background)

    heading = Label.new()
    heading.name = "WorksiteHeading"
    heading.position = Vector2(8,4)
    heading.size = Vector2(155,20)
    heading.add_theme_font_size_override("font_size",12)
    heading.add_theme_color_override("font_color",INK)
    heading.clip_text = true
    heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(heading)

    detail = Label.new()
    detail.name = "WorksiteDetail"
    detail.position = Vector2(8,26)
    detail.size = Vector2(155,20)
    detail.add_theme_font_size_override("font_size",11)
    detail.add_theme_color_override("font_color",INK)
    detail.clip_text = true
    detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(detail)

    progress = ProgressBar.new()
    progress.name = "WorksiteProgress"
    progress.position = Vector2(8,52)
    progress.size = Vector2(154,8)
    progress.max_value = 100.0
    progress.show_percentage = false
    progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var fill := StyleBoxFlat.new()
    fill.bg_color = JADE
    fill.set_corner_radius_all(4)
    progress.add_theme_stylebox_override("fill",fill)
    var track := StyleBoxFlat.new()
    track.bg_color = Color(0.74,0.75,0.69,1.0)
    track.set_corner_radius_all(4)
    progress.add_theme_stylebox_override("background",track)
    add_child(progress)

    receipt = Label.new()
    receipt.name = "WorksiteSettledReceipt"
    receipt.position = Vector2(9,-27)
    receipt.size = Vector2(156,24)
    receipt.add_theme_font_size_override("font_size",12)
    receipt.add_theme_color_override("font_color",Color(0.08,0.31,0.21))
    receipt.mouse_filter = Control.MOUSE_FILTER_IGNORE
    receipt.visible = false
    add_child(receipt)

func display(snapshot: Dictionary) -> void:
    var title_text := str(snapshot.get("heading",""))
    var detail_text := str(snapshot.get("detail",""))
    var fraction := clampf(float(snapshot.get("progress",0.0)),0.0,100.0)
    var signature := "%s|%s|%.2f" % [title_text,detail_text,fraction]
    if signature == last_display_signature:
        return
    last_display_signature = signature
    heading.text = title_text
    detail.text = detail_text
    progress.value = fraction

func show_delivered(amount: int) -> void:
    if amount <= 0:
        return
    if receipt_tween != null and receipt_tween.is_valid():
        receipt_tween.kill()
    receipt.text = "+%d đã vào kho" % amount
    receipt.visible = true
    receipt.modulate.a = 1.0
    receipt_tween = create_tween()
    receipt_tween.tween_interval(2.3)
    receipt_tween.tween_property(receipt,"modulate:a",0.0,0.5)
    receipt_tween.tween_callback(func() -> void:
        if is_instance_valid(receipt):
            receipt.visible = false
    )
