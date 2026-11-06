extends SceneTree

# Verifies the read-only worksite receipt labels the canonical delivered item.
# The receipt is triggered by the caller only after Warehouse settlement.
var failures := 0

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var cue := SectProductionWorksiteCue.new()
    root.add_child(cue)
    await process_frame

    cue.display({
        "heading":"Mỏ · Thanh Thiết",
        "worker":"Đệ tử QA",
        "detail":"Mẻ ×2 · Chờ nhập kho",
        "display_detail":"×2 · chờ kho",
        "received":0,
        "progress":100.0,
        "active":true,
        "waiting":true
    })
    cue.show_delivered(2)
    _check(cue.receipt.text == "+2 Thanh Thiết → Kho", "Mine receipt should name its output resource.")
    _check(cue.receipt.tooltip_text == "+2 Thanh Thiết đã nhập kho", "Mine receipt tooltip should retain exact canonical quantity.")

    cue.display({
        "heading":"Linh Điền · 1/2 ô",
        "worker":"Đệ tử QA",
        "detail":"Thường ×9 · Chờ nhập kho",
        "display_detail":"Thanh Linh Thảo ×9 · chờ kho",
        "received":0,
        "progress":100.0,
        "active":true,
        "waiting":true
    })
    cue.show_delivered(9)
    _check(cue.receipt.text == "+9 Thanh Linh Thảo → Kho", "Field receipt should name its canonical crop, not the plot count.")
    var previous_receipt := cue.receipt.text
    cue.show_delivered(0)
    _check(cue.receipt.text == previous_receipt, "A zero delivery must not replace the prior receipt.")

    if failures == 0:
        print("SECT PRODUCTION WORKSITE RECEIPT TEST PASS checks=4")
    else:
        printerr("SECT PRODUCTION WORKSITE RECEIPT TEST FAIL failures=%d" % failures)
    cue.queue_free()
    await process_frame
    quit(0 if failures == 0 else 1)

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures += 1
        printerr("FAIL: "+message)
