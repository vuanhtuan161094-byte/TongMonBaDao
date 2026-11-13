extends SceneTree
const FX = preload("res://labs/combat_lab/research02/flowing_sword_fx.gd")
const SCENE = preload("res://labs/combat_lab/research02/research02_arena.tscn")
var fails := 0

func check(value: bool, reason: String) -> void:
    if not value:
        fails += 1
        push_error("VFX_RESEARCH02_FAIL " + reason)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var target := Vector2(855, 328)
    var caster := Vector2(298, 464)
    var low := FX.visual_indices(0)
    var med := FX.visual_indices(1)
    var high := FX.visual_indices(2)
    check(low == PackedInt32Array([1, 4, 7]) and
        med == PackedInt32Array([0, 2, 3, 5, 6, 8]) and
        high.size() == 9,
        "three attack waves preserved at all LOD; 9/6/3 visual copies")
    for wave in range(3):
        var f := FX.flight_window(wave, 0)
        var hit := FX.impact_window(wave, 0)
        check(f.x < f.y and is_equal_approx(f.y, hit.x) and
            hit.x < hit.y and hit.y < 1.0,
            "wave " + str(wave) + ": flight arrival equals impact start")
        var from := FX.flight_point(caster, target, wave, 0, 0.0)
        var to := FX.flight_point(caster, target, wave, 0, 1.0)
        check(from.distance_to(to) > 200.0 and
            to.is_equal_approx(target + Vector2(-42, -31)),
            "wave " + str(wave) + ": deterministic route terminates pre-contact")
        check(FX.flight_axis(caster, target, wave, 0, 0.65).length() > 0.99,
            "wave " + str(wave) + ": unit tangent")
    var scene := SCENE.instantiate() as Control
    check(scene != null, "independent scene instantiates")
    if scene != null:
        root.add_child(scene)
        check(scene.approved_hits.size() == 3 and
            not scene.approved_hits.has(Vector2(974, 446)),
            "visual-only caller supplies EXACTLY 3 approved demo victims")
        scene.queue_free()
    print("VFX_RESEARCH02_FOCUSED_RESULT=" +
        ("PASS" if fails == 0 else "FAIL") + " failures=" + str(fails))
    quit(0 if fails == 0 else 1)
