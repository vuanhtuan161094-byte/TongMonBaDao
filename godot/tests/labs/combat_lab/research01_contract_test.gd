extends SceneTree
# Static and runtime contract of an isolated visual comparison.
# Never treated as gameplay acceptance.
const LAB = preload("res://labs/combat_lab/research01/research01_arena.tscn")
const SOURCE = preload("res://labs/combat_lab/research01/research01_arena.gd")
var failures := 0

func check(condition: bool, label: String) -> void:
    if not condition:
        failures += 1
        push_error("VFX_RESEARCH01_FAIL " + label)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var initial := SOURCE.flight_window(0, 0)
    var second := SOURCE.flight_window(1, 0)
    var third := SOURCE.flight_window(2, 0)
    check(initial.x < initial.y and initial.y < second.y and
        second.x < third.x and third.x < third.y,
        "three ordered and bounded visual attack waves")
    var hits := SOURCE.approved_demo_hits()
    check(hits.size() == 3 and hits.has(Vector2(855, 328)) and
        not hits.has(Vector2(974, 446)),
        "three visual-hit recipients; fourth mock monster excluded")
    check(SOURCE.ink_alpha(0.1) > SOURCE.ink_alpha(0.7) and
        SOURCE.ink_alpha(1.0) < 0.001,
        "a bounded contact with fade; no infinite impact")
    var stage := LAB.instantiate() as Control
    check(stage != null, "independent Combat Lab scene loads")
    if stage != null:
        root.add_child(stage)
        check(stage.mode_id >= 0 and stage.mode_id <= 2,
            "default or environment preview mode valid")
        check(stage.approved_hits.size() == 3 and
            not stage.approved_hits.has(Vector2(974, 446)),
            "all modes share fixed, legitimate visual target list")
        for mode in range(3):
            stage.set_mode_id(mode)
            check(stage.mode_id == mode and is_zero_approx(stage.elapsed),
                "mode " + str(mode) + " selected and timeline reset")
        stage.queue_free()
    print("VFX_RESEARCH01_FOCUSED_RESULT=" +
        ("PASS" if failures == 0 else "FAIL") +
        " failures=" + str(failures))
    quit(0 if failures == 0 else 1)
