extends SceneTree
const META_PATH := "res://meta/AS48_ATTACK_WEAPON_OVERLAY_CANDIDATE.json"
const EXPECTED_SIZE := Vector2i(887, 1774)
func _initialize() -> void:
    var file := FileAccess.open(META_PATH, FileAccess.READ)
    if file == null:
        push_error("WEAPON_META_MISSING")
        quit(2)
        return
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    file.close()
    if not parsed is Dictionary:
        push_error("WEAPON_META_PARSE_FAIL")
        quit(3)
        return
    var meta: Dictionary = parsed
    if str(meta.get("status", "")) != "CANDIDATE_TECHNICAL_OWNER_ART_APPROVAL_PENDING" or str(meta.get("identity", "")) != "AS-CHAR-48":
        push_error("WEAPON_META_STATUS_FAIL")
        quit(4)
        return
    var asset_path := "res://" + str(meta.get("weapon_asset", ""))
    var abs_path := ProjectSettings.globalize_path(asset_path)
    var image := Image.load_from_file(abs_path)
    if image == null or image.get_size() != EXPECTED_SIZE or image.detect_alpha() != Image.ALPHA_BLEND:
        push_error("WEAPON_IMAGE_FORMAT_FAIL")
        quit(5)
        return
    if sha256(FileAccess.get_file_as_bytes(abs_path)) != str(meta.get("weapon_sha256", "")):
        push_error("WEAPON_IMAGE_SHA_FAIL")
        quit(6)
        return
    var data: Array = meta.get("frame_data", [])
    if data.size() != 4:
        push_error("WEAPON_FRAME_DATA_COUNT_FAIL")
        quit(7)
        return
    var verified := 0
    for i in range(data.size()):
        var record: Dictionary = data[i]
        var body_path := "res://" + str(record.get("body_frame", ""))
        var body_abs := ProjectSettings.globalize_path(body_path)
        var body := Image.load_from_file(body_abs)
        if body == null or body.get_size() != Vector2i(400, 440) or sha256(FileAccess.get_file_as_bytes(body_abs)) != str(record.get("body_frame_sha256", "")):
            push_error("WEAPON_BODY_SOURCE_FAIL=" + str(i))
            quit(8)
            return
        var grip: Array = record.get("hand_grip_body_canvas_px", [])
        if grip.size() != 2:
            push_error("WEAPON_HAND_GRIP_SCHEMA_FAIL=" + str(i))
            quit(9)
            return
        var has_skin_near_grip := false
        for dy in range(-6, 7):
            for dx in range(-6, 7):
                var x := int(grip[0]) + dx
                var y := int(grip[1]) + dy
                if x >= 0 and y >= 0 and x < body.get_width() and y < body.get_height():
                    var color := body.get_pixel(x, y)
                    if color.a > 0.2 and color.r > 0.58 and color.g > 0.36 and color.b > 0.28 and color.r > color.b * 1.15:
                        has_skin_near_grip = true
        if not has_skin_near_grip or str(record.get("occlusion_order", "")) != "WEAPON_BEHIND_WHOLE_MONOLITHIC_BODY":
            push_error("WEAPON_GRIP_OCCLUSION_REVIEW_FAIL=" + str(i))
            quit(10)
            return
        verified += 1
    print("AS48_WEAPON_OVERLAY_VERIFY=PASS weapon_rgba=%dx%d sha=match manual_anchor_near_body=%d/4 whole_body_occlusion=4/4 owner_art_pending=true" % [image.get_width(), image.get_height(), verified])
    quit(0)
func sha256(bytes: PackedByteArray) -> String:
    var h := HashingContext.new()
    h.start(HashingContext.HASH_SHA256)
    h.update(bytes)
    return h.finish().hex_encode()


