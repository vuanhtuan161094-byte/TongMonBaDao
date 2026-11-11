class_name SectProductionWorksiteCue
extends Control

# Small, read-only map badge. Never schedules work, mutates BuildingState,
# pays wages, settles inventory, or infers the outcome of a growing crop.
const CARD_SIZE := Vector2(202.0,110.0)
const ART03_FLOW = preload("res://src/presentation/uiux/sect_worksite_fx_v1.gd")
const INK := Color(0.16,0.14,0.11,1.0)
const PAPER := Color(0.96,0.92,0.80,0.97)
const JADE := Color(0.17,0.40,0.31,1.0)
const PENDING_COLOR := Color(0.61,0.37,0.10,1.0)

var heading: Label
var worker: Label
var detail: Label
var received: Label
var progress: ProgressBar
var percentage: Label
var receipt: Label
var receipt_tween: Tween
var delivery_item_label := "sản phẩm"
var last_display_signature := ""
var art03_flow: Control

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

    art03_flow = ART03_FLOW.new()
    art03_flow.name = "Art03CanonicalWorkingFX"
    art03_flow.position = Vector2.ZERO
    art03_flow.size = CARD_SIZE
    art03_flow.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(art03_flow)

    heading = Label.new()
    heading.name = "WorksiteHeading"
    heading.position = Vector2(8,4)
    heading.size = Vector2(186,20)
    heading.add_theme_font_size_override("font_size",14)
    heading.add_theme_color_override("font_color",INK)
    heading.clip_text = true
    heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(heading)

    worker = Label.new()
    worker.name = "WorksiteWorker"
    worker.position = Vector2(8,25)
    worker.size = Vector2(186,20)
    worker.add_theme_font_size_override("font_size",13)
    worker.add_theme_color_override("font_color",INK)
    worker.clip_text = true
    worker.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(worker)

    detail = Label.new()
    detail.name = "WorksiteDetail"
    detail.position = Vector2(8,47)
    detail.size = Vector2(186,20)
    detail.add_theme_font_size_override("font_size",13)
    detail.add_theme_color_override("font_color",INK)
    detail.clip_text = true
    detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(detail)

    received = Label.new()
    received.name = "WorksiteReceived"
    received.position = Vector2(8,69)
    received.size = Vector2(186,20)
    received.add_theme_font_size_override("font_size",13)
    received.add_theme_color_override("font_color",INK)
    received.clip_text = true
    received.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(received)

    progress = ProgressBar.new()
    progress.name = "WorksiteProgress"
    progress.position = Vector2(8,95)
    progress.size = Vector2(150,6)
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
    percentage.add_theme_font_size_override("font_size",13)
    percentage.add_theme_color_override("font_color",INK)
    percentage.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(percentage)

    receipt = Label.new()
    receipt.name = "WorksiteSettledReceipt"
    receipt.position = Vector2(9,-27)
    receipt.size = Vector2(190,24)
    receipt.add_theme_font_size_override("font_size",13)
    receipt.add_theme_color_override("font_color",Color(0.08,0.31,0.21))
    receipt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    receipt.clip_text = true
    # Green text alone disappears against terrain. Keep the receipt tied to
    # a real Warehouse-settled production delta, only improve readability.
    var receipt_background := StyleBoxFlat.new()
    receipt_background.bg_color = Color(0.96,0.94,0.82,0.98)
    receipt_background.border_color = Color(0.16,0.40,0.30,1.0)
    receipt_background.set_border_width_all(1)
    receipt_background.set_corner_radius_all(5)
    receipt.add_theme_stylebox_override("normal",receipt_background)
    receipt.mouse_filter = Control.MOUSE_FILTER_IGNORE
    receipt.visible = false
    add_child(receipt)

# Preserve exact quantities in the snapshot, panel and warehouse; compress
# the tiny world badge ONLY when a value cannot fit at 1280x720.
static func _map_quantity(value: int) -> String:
    if value >= 1000000:
        return "≈%.1fTr" % (float(value)/1000000.0)
    if value >= 100000:
        return "≈%.1fK" % (float(value)/1000.0)
    return str(value)

func display(snapshot: Dictionary) -> void:
    var title_text := str(snapshot.get("heading",""))
    var worker_text := "Người: %s" % str(snapshot.get("worker","Chưa phân công"))
    var detail_text := str(snapshot.get("detail",""))
    var display_detail := str(snapshot.get("display_detail",detail_text))
    delivery_item_label = str(snapshot.get("output_name","")).strip_edges()
    if delivery_item_label.is_empty():
        # Mine/forest snapshots put the exact resource in the heading and
        # compact output in display_detail; field snapshots put the crop
        # name before the multiplication sign in display_detail.
        var quantity_marker := display_detail.find(" ×")
        if quantity_marker > 0:
            delivery_item_label = display_detail.substr(0,quantity_marker).strip_edges()
        else:
            var heading_marker := title_text.rfind(" · ")
            if heading_marker >= 0:
                var heading_suffix := title_text.substr(heading_marker+3).strip_edges()
                if not heading_suffix.contains("/") and not heading_suffix.ends_with("ô"):
                    delivery_item_label = heading_suffix
    if delivery_item_label.is_empty():
        delivery_item_label = "sản phẩm"
    var received_count := maxi(0,int(snapshot.get("received",0)))
    var received_text := "Đã nhập: %s" % _map_quantity(received_count)
    var fraction := clampf(float(snapshot.get("progress",0.0)),0.0,100.0)
    var active := bool(snapshot.get("active",false))
    # A full timer is NOT a completed warehouse receipt.
    var waiting := bool(snapshot.get("waiting",false))
    var signature := "%s|%s|%s|%s|%s|%s|%.2f|%s|%s" % [
        title_text,worker_text,detail_text,display_detail,delivery_item_label,received_text,fraction,str(active),str(waiting)
    ]
    if signature == last_display_signature:
        return
    last_display_signature = signature
    heading.text = title_text
    heading.tooltip_text = title_text
    worker.text = worker_text
    worker.tooltip_text = worker_text
    detail.text = display_detail
    detail.tooltip_text = detail_text
    received.text = received_text
    received.tooltip_text = "Đã nhập kho: %d" % received_count
    progress.value = fraction
    var fill := progress.get_theme_stylebox("fill") as StyleBoxFlat
    if fill != null:
        var source_color := Color(0.88,0.61,0.27,1.0) if title_text.begins_with("Mỏ") else (Color(0.25,0.70,0.53,1.0) if title_text.begins_with("Linh Lâm") else Color(0.36,0.68,0.91,1.0))
        fill.bg_color = PENDING_COLOR if waiting else source_color
        if art03_flow != null:
            art03_flow.call("set_activity",active and not waiting,source_color)
    progress.tooltip_text = "Chờ scheduler kết toán, chưa nhập kho" if waiting else detail_text
    percentage.text = "%d%%" % roundi(fraction) if active else "—"
    percentage.tooltip_text = progress.tooltip_text

func show_delivered(amount: int) -> void:
    if amount <= 0:
        return
    if receipt_tween != null and receipt_tween.is_valid():
        receipt_tween.kill()
    if art03_flow != null:
        art03_flow.call("show_receipt_burst")
    receipt.text = "+%d %s → Kho" % [amount,delivery_item_label]
    receipt.tooltip_text = "+%d %s đã nhập kho" % [amount,delivery_item_label]
    receipt.visible = true
    receipt.modulate.a = 1.0
    receipt_tween = create_tween()
    receipt_tween.tween_interval(2.3)
    receipt_tween.tween_property(receipt,"modulate:a",0.0,0.5)
    receipt_tween.tween_callback(func() -> void:
        if is_instance_valid(receipt):
            receipt.visible = false
    )
