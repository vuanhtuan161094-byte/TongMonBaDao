class_name SectProductionWorksiteCue
extends Control

# Small, read-only map badge. Never schedules work, mutates BuildingState,
# pays wages, settles inventory, or infers the outcome of a growing crop.
const CARD_SIZE := Vector2(202.0,110.0)
const INK := Color(0.16,0.14,0.11,1.0)
const PAPER := Color(0.96,0.92,0.80,0.97)
const JADE := Color(0.17,0.40,0.31,1.0)

var heading: Label
var worker: Label
var detail: Label
var received: Label
var progress: ProgressBar
var percentage: Label
var receipt: Label
var receipt_tween: Tween
var last_display_signature := ""

func _ready() -> void:
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
    heading.size = Vector2(186,20)
    heading.add_theme_font_size_override("font_size",13)
    heading.add_theme_color_override("font_color",INK)
    heading.clip_text = true
    heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(heading)

    worker = Label.new()
    worker.name = "WorksiteWorker"
    worker.position = Vector2(8,25)
    worker.size = Vector2(186,20)
    worker.add_theme_font_size_override("font_size",12)
    worker.add_theme_color_override("font_color",INK)
    worker.clip_text = true
    worker.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(worker)

    detail = Label.new()
    detail.name = "WorksiteDetail"
    detail.position = Vector2(8,47)
    detail.size = Vector2(186,20)
    detail.add_theme_font_size_override("font_size",12)
    detail.add_theme_color_override("font_color",INK)
    detail.clip_text = true
    detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(detail)

    received = Label.new()
    received.name = "WorksiteReceived"
    received.position = Vector2(8,69)
    received.size = Vector2(186,20)
    received.add_theme_font_size_override("font_size",12)
    received.add_theme_color_override("font_color",INK)
    received.clip_text = true
    received.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(received)

    progress = ProgressBar.new()
    progress.name = "WorksiteProgress"
    progress.position = Vector2(8,94)
    progress.size = Vector2(150,9)
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

    percentage = Label.new()
    percentage.name = "WorksitePercentage"
    percentage.position = Vector2(162,88)
    percentage.size = Vector2(36,20)
    percentage.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    percentage.add_theme_font_size_override("font_size",12)
    percentage.add_theme_color_override("font_color",INK)
    percentage.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(percentage)

    receipt = Label.new()
    receipt.name = "WorksiteSettledReceipt"
    receipt.position = Vector2(9,-27)
    receipt.size = Vector2(190,24)
    receipt.add_theme_font_size_override("font_size",12)
    receipt.add_theme_color_override("font_color",Color(0.08,0.31,0.21))
    receipt.mouse_filter = Control.MOUSE_FILTER_IGNORE
    receipt.visible = false
    add_child(receipt)

func display(snapshot: Dictionary) -> void:
    var title_text := str(snapshot.get("heading",""))
    var worker_text := "Người: %s" % str(snapshot.get("worker","Chưa phân công"))
    var detail_text := str(snapshot.get("detail",""))
    var received_text := "Đã nhập kho: %d" % maxi(0,int(snapshot.get("received",0)))
    var fraction := clampf(float(snapshot.get("progress",0.0)),0.0,100.0)
    var active := bool(snapshot.get("active",false))
    var signature := "%s|%s|%s|%s|%.2f|%s" % [
        title_text,worker_text,detail_text,received_text,fraction,str(active)
    ]
    if signature == last_display_signature:
        return
    last_display_signature = signature
    heading.text = title_text
    worker.text = worker_text
    detail.text = detail_text
    received.text = received_text
    progress.value = fraction
    percentage.text = "%d%%" % roundi(fraction) if active else "—"

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
