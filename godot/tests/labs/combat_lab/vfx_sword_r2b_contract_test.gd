extends SceneTree
const SOURCE := "res://labs/combat_lab/sword_human_phi_kiem_truy_anh/r2b/source/phi_kiem_human_r2b_atlas_rgba.png"
const FX := preload("res://labs/combat_lab/sword_human_phi_kiem_truy_anh/r2b/phi_kiem_r2b_vfx_layer.gd")
const CATALOG := "res://data/combat/v63_sword_combat_catalog.json"
var errors := 0

func must(value: bool, tag: String) -> void:
    if not value:
        errors += 1
        push_error("SWORD_R2B_CONTRACT_FAIL " + tag)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(CATALOG))
    must(data is Dictionary, "catalog parse")
    if data is Dictionary:
        var found: Dictionary = {}
        for row in data.get("skills", []):
            if str(row.get("id", "")) == "tmb.skill.sword.ngu_kiem.active_01.human":
                found = row
                break
        must(not found.is_empty(), "canonical skill ID")
        must(str(found.get("effect", "")) == "damage", "damage")
        must(str(found.get("shape", "")) == "single_target" and int(found.get("target_limit", -1)) == 1, "single target")
        must(is_equal_approx(float(found.get("cast_time", -1)), 0.28), "cast")
        must(is_equal_approx(float(found.get("cooldown", -1)), 8.0), "cooldown")
        must(is_equal_approx(float(found.get("projectile_speed", -1)), 10.0), "speed")
    var atlas := Image.new()
    must(atlas.load(SOURCE) == OK, "PNG source load")
    must(atlas.get_size() == Vector2i(2048, 1024), "four-by-two RGBA atlas")
    if atlas.get_size() == Vector2i(2048, 1024):
        for n in range(8):
            var alpha_count := 0
            var x0 := (n % 4) * 512
            var y0 := int(n / 4) * 512
            for y in range(y0, y0 + 512, 16):
                for x in range(x0, x0 + 512, 16):
                    if atlas.get_pixel(x, y).a > 0.1:
                        alpha_count += 1
            must(alpha_count > 3, "pose %d alpha content" % n)
    must(FX.phase_at(0.12) == "charge", "charge phase")
    must(FX.phase_at(0.51) == "projectile", "single flight phase")
    must(FX.phase_at(0.87) == "contact", "contact phase")
    must(FX.phase_at(1.20) == "ended", "fade and expiry")
    var code := FileAccess.get_file_as_string("res://labs/combat_lab/sword_human_phi_kiem_truy_anh/r2b/phi_kiem_r2b_vfx_layer.gd")
    for forbidden in ["SaveService.", "CombatV2.", "apply_damage(", "apply_status(", "apply_heal("]:
        must(not code.contains(forbidden), "view only " + forbidden)
    print("SWORD_R2B_FOCUSED_RESULT=" + ("PASS" if errors == 0 else "FAIL") + " failures=" + str(errors))
    quit(0 if errors == 0 else 1)