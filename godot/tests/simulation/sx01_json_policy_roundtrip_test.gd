extends SceneTree

# Regression for SX-01 policy state from JSON (exact-SHA Godot 4.7.2 QA needed).
# Direct SectState roundtrip complements full SaveService and B3 CARE tests.
var checks := 0
var failed := false

func _init() -> void:
    call_deferred("_run")

func _check(condition: bool, message: String) -> void:
    checks += 1
    if not condition:
        failed = true
        push_error("SX01 JSON ROUNDTRIP FAIL: " + message)

func _run() -> void:
    var sect := SectState.new()
    sect.sx01_pill_policy = SX01PillPolicy.DEFAULTS.duplicate(true)
    sect.sx01_pill_policy["target_hoi_xuan_dan"] = 17
    sect.sx01_pill_policy["target_tu_khi_dan"] = 29
    sect.sx01_pill_policy["auto_day"] = 42
    sect.sx01_pill_policy["auto_tu_khi_used"] = {"disciple_1": 2, "disciple_2": 1}
    sect.sx01_pill_policy["priority_tuvi_ids"] = {"disciple_1": true, "disciple_2": false}
    sect.sx01_pill_policy["recipe_mode"] = "demand"
    sect.sx01_pill_policy["auto_use_tu_khi_dan"] = false

    var parsed = JSON.parse_string(JSON.stringify(sect.to_dict()))
    _check(parsed is Dictionary, "JSON parse must produce a dictionary")
    if not (parsed is Dictionary):
        quit(1)
        return
    var restored := SectState.from_dict(parsed)
    _check(restored.sx01_pill_policy == sect.sx01_pill_policy,
        "JSON numeric and nested daily policy values roundtrip exactly")
    _check(restored.sx01_pill_policy["auto_day"] == 42,
        "integral daily marker survives")
    _check(restored.sx01_pill_policy["auto_tu_khi_used"]["disciple_1"] == 2,
        "nested daily quota persists as integer")
    _check(not bool(restored.sx01_pill_policy["auto_use_tu_khi_dan"]),
        "disabled auto-use boolean survives")
    _check(restored.sx01_pill_policy["priority_tuvi_ids"].has("disciple_2"),
        "false priority entry is preserved")

    var legacy := SectState.from_dict({})
    _check(legacy.sx01_pill_policy.is_empty(), "legacy default must stay opted out")

    var corrupt: Dictionary = sect.to_dict().duplicate(true)
    corrupt["sx01_pill_policy"]["auto_day"] = 2.25
    corrupt["sx01_pill_policy"]["target_tu_khi_dan"] = "88"
    corrupt["sx01_pill_policy"]["auto_tu_khi_used"] = {
        "disciple_1": 2.5, "disciple_2": "3", "disciple_3": true, "disciple_4": 3.0
    }
    corrupt["sx01_pill_policy"]["priority_tuvi_ids"] = {
        "disciple_1": 1.0, "disciple_2": true
    }
    corrupt["sx01_pill_policy"]["unknown_future_field"] = 999
    var rejected := SectState.from_dict(corrupt).sx01_pill_policy
    _check(int(rejected["auto_day"]) == -1, "fractional day is not truncated")
    _check(int(rejected["target_tu_khi_dan"]) == 12, "string target is not coerced")
    _check(rejected["auto_tu_khi_used"] == {"disciple_4": 3},
        "nested counters reject fractional, bool and string values")
    _check(rejected["priority_tuvi_ids"] == {"disciple_2": true},
        "priority dictionary rejects non-boolean values")
    _check(not rejected.has("unknown_future_field"), "unknown keys cannot enter policy")
    var wrong_version := sect.to_dict().duplicate(true)
    wrong_version["sx01_pill_policy"]["version"] = 1.5
    _check(SectState.from_dict(wrong_version).sx01_pill_policy.is_empty(),
        "fractional schema version cannot opt in")
    if not failed:
        print("SX01 JSON POLICY ROUNDTRIP PASS (%d checks)" % checks)
    quit(1 if failed else 0)
