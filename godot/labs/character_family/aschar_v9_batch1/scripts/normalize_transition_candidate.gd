extends SceneTree
const SOURCE := "res://assets/frames/AS48/attack_front_consistency_v2/attack_front_transition_01_5_raw_candidate.png"
const OUTPUT := "res://assets/frames/AS48/attack_front_consistency_v2/attack_front_transition_01_5_registered_candidate.png"
const CELL := Vector2i(400, 440)
const FOOT_ROW := 429
const TARGET_BODY_HEIGHT := 338
func _initialize() -> void:
    var src_path := ProjectSettings.globalize_path(SOURCE)
    var image := Image.load_from_file(src_path)
    if image == null or image.detect_alpha() != Image.ALPHA_BLEND:
        push_error("TRANSITION_NORMALIZE_SOURCE_FAIL")
        quit(2)
        return
    var minp := Vector2i(image.get_width(), image.get_height())
    var maxp := Vector2i(-1, -1)
    for y in range(image.get_height()):
        for x in range(image.get_width()):
            if image.get_pixel(x, y).a >= 0.01:
                minp.x = mini(minp.x, x)
                minp.y = mini(minp.y, y)
                maxp.x = maxi(maxp.x, x)
                maxp.y = maxi(maxp.y, y)
    if maxp.x < minp.x or maxp.y < minp.y:
        push_error("TRANSITION_NORMALIZE_EMPTY_ALPHA")
        quit(3)
        return
    minp = Vector2i(maxi(0, minp.x - 4), maxi(0, minp.y - 4))
    maxp = Vector2i(mini(image.get_width() - 1, maxp.x + 4), mini(image.get_height() - 1, maxp.y + 4))
    var crop_size := maxp - minp + Vector2i.ONE
    var cropped := image.get_region(Rect2i(minp, crop_size))
    var out_h := TARGET_BODY_HEIGHT
    var out_w := int(round(float(crop_size.x) * float(out_h) / float(crop_size.y)))
    cropped.resize(out_w, out_h, Image.INTERPOLATE_LANCZOS)
    var canvas := Image.create(CELL.x, CELL.y, false, Image.FORMAT_RGBA8)
    var dst := Vector2i((CELL.x - out_w) / 2, FOOT_ROW - out_h + 1)
    canvas.blit_rect(cropped, Rect2i(Vector2i.ZERO, Vector2i(out_w, out_h)), dst)
    if canvas.save_png(ProjectSettings.globalize_path(OUTPUT)) != OK:
        push_error("TRANSITION_NORMALIZE_SAVE_FAIL")
        quit(4)
        return
    var bounds := canvas.get_used_rect()
    var out_hash := sha256(FileAccess.get_file_as_bytes(ProjectSettings.globalize_path(OUTPUT)))
    print("TRANSITION_NORMALIZE=PASS raw=%s alpha_crop=%s output=%s bbox=%s foot_row=%d scale=%.6f sha256=%s" % [image.get_size(), crop_size, CELL, bounds, bounds.position.y + bounds.size.y - 1, float(out_h) / float(crop_size.y), out_hash])
    quit(0)
func sha256(bytes: PackedByteArray) -> String:
    var h := HashingContext.new()
    h.start(HashingContext.HASH_SHA256)
    h.update(bytes)
    return h.finish().hex_encode()
