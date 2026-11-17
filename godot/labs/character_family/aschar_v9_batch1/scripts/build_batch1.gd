extends SceneTree
const CELL := Vector2i(400, 440)
const TARGET := Vector2i(360, 420)
const BASELINE := 430
const CLIPS := {
    "Walk_Front": {"folder":"walk_front", "loop":true, "fps":8.0, "files":[
        "AS48_walk_front_f00_left_contact.png", "AS48_walk_front_f01_passing.png", "AS48_walk_front_f02_right_contact.png", "AS48_walk_front_f03_passing.png"]},
    "Attack_Front": {"folder":"attack_front", "loop":false, "fps":7.0, "files":[
        "AS48_attack_front_f00_windup.png", "AS48_attack_front_f01_guard_rise.png", "AS48_attack_front_f02_release.png", "AS48_attack_front_f03_recovery.png"]}
}
func _initialize() -> void:
    var manifest := {"schema":"tmb.aschar.v9.batch1.candidate.v1", "engine":"Godot 4.7.2 official", "identity":"AS-CHAR-48 Kiếm Tu Nam", "candidate_status":"OWNER_ART_APPROVAL_PENDING", "body_mode":"monolithic full-body cel per frame; no rig; no body part splitting", "canvas":{ "frame":CELL, "foot_baseline_y":BASELINE, "visual_target_px":TARGET }, "weapon_overlay":{"status":"PENDING_APPROVED_WEAPON_ASSET_AND_GRIP_CALIBRATION", "embedded_in_body":false}, "clips":{}}
    for clip_name in CLIPS:
        var spec: Dictionary = CLIPS[clip_name]
        var atlas_img := Image.create(CELL.x * spec.files.size(), CELL.y, false, Image.FORMAT_RGBA8)
        var clip_manifest := {"fps":spec.fps, "loop":spec.loop, "direction":"Front", "frames":[]}
        var unique_hashes := {}
        for i in range(spec.files.size()):
            var rel := "res://assets/frames/AS48/%s/%s" % [spec.folder, spec.files[i]]
            var abs := ProjectSettings.globalize_path(rel)
            var src := Image.load_from_file(abs)
            if src == null:
                push_error("ASSET_LOAD_FAIL=" + abs); quit(2); return
            var bounds := src.get_used_rect()
            if bounds.size.x <= 0 or bounds.size.y <= 0:
                push_error("EMPTY_ALPHA=" + abs); quit(3); return
            var crop := src.get_region(bounds)
            var s: float = minf(float(TARGET.x) / float(crop.get_width()), float(TARGET.y) / float(crop.get_height()))
            var new_size := Vector2i(maxi(1, int(round(crop.get_width() * s))), maxi(1, int(round(crop.get_height() * s))))
            crop.resize(new_size.x, new_size.y, Image.INTERPOLATE_LANCZOS)
            var cel := Image.create(CELL.x, CELL.y, false, Image.FORMAT_RGBA8)
            var dest := Vector2i((CELL.x - new_size.x) / 2, BASELINE - new_size.y)
            cel.blit_rect(crop, Rect2i(Vector2i.ZERO, new_size), dest)
            var out_rel := "res://assets/frames/AS48/%s_registered/%s_%02d.png" % [spec.folder, clip_name.to_lower(), i]
            var out_abs := ProjectSettings.globalize_path(out_rel)
            DirAccess.make_dir_recursive_absolute(out_abs.get_base_dir())
            var save_err := cel.save_png(out_abs)
            if save_err != OK:
                push_error("FRAME_SAVE_FAIL=" + out_abs + " code=" + str(save_err)); quit(4); return
            atlas_img.blit_rect(cel, Rect2i(Vector2i.ZERO, CELL), Vector2i(i * CELL.x, 0))
            var source_bytes := FileAccess.get_file_as_bytes(abs)
            var source_sha := sha256(source_bytes)
            var cel_sha := sha256(cel.get_data())
            unique_hashes[cel_sha] = true
            clip_manifest.frames.append({"source":rel.replace("res://", ""), "source_sha256":source_sha, "alpha_bounds":{ "x":bounds.position.x, "y":bounds.position.y, "w":bounds.size.x, "h":bounds.size.y }, "registered":out_rel.replace("res://", ""), "registered_sha256":cel_sha, "registered_size":CELL, "foot_baseline_y":BASELINE, "estimated_not_pose_locked":true})
        if unique_hashes.size() != spec.files.size():
            push_error("DUPLICATE_REGISTERED_FRAME=" + clip_name); quit(5); return
        var atlas_rel := "res://assets/atlases/AS48_%s_atlas.png" % clip_name.to_lower()
        var atlas_abs := ProjectSettings.globalize_path(atlas_rel)
        var atlas_err := atlas_img.save_png(atlas_abs)
        if atlas_err != OK:
            push_error("ATLAS_SAVE_FAIL=" + atlas_abs); quit(6); return
        clip_manifest["atlas"] = atlas_rel.replace("res://", "")
        clip_manifest["atlas_sha256"] = sha256(atlas_img.get_data())
        clip_manifest["frame_count"] = spec.files.size()
        manifest.clips[clip_name] = clip_manifest
    var json := JSON.stringify(manifest, "  ")
    var mf := FileAccess.open("res://meta/AS48_V9_ANIMATION_CANDIDATE_MANIFEST.json", FileAccess.WRITE)
    if mf == null:
        push_error("MANIFEST_OPEN_FAIL"); quit(8); return
    mf.store_string(json + "\n")
    mf.close()
    print("ASCHAR_V9_ATLASES=PASS clips=2 frames=8 unique=8 atlas=2 body=monolithic weapon=separate_pending status=OWNER_ART_APPROVAL_PENDING")
    quit(0)
func sha256(bytes: PackedByteArray) -> String:
    var ctx := HashingContext.new()
    ctx.start(HashingContext.HASH_SHA256)
    ctx.update(bytes)
    return ctx.finish().hex_encode()




