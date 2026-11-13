extends SceneTree

const FX = preload("res://labs/combat_lab/research04/thien_loi_vfx.gd")
const ART = preload("res://labs/combat_lab/research04/thien_loi_arena.tscn")
const LAYER = preload("res://labs/combat_lab/research04/thien_loi_overlay.gd")
const V9_SHADER = preload("res://labs/combat_lab/combat_lab_v9_energy_light.gdshader")
var failed := 0

func check(ok: bool, reason: String) -> void:
    if not ok:
        failed += 1
        push_error("VFX19_TEST_FAIL " + reason)

func _initialize() -> void:
    call_deferred("_go")

func _go() -> void:
    check(V9_SHADER is Shader, "reuse native V9 light blend shader")
    check(FX.HIT_COUNT == 3 and FX.MAX_BRANCHES <= 6 and
        FX.MAX_SPLINTERS <= 7,
        "visual cap is stable and no 4th mock target can be hit")
    check(FX.MAIN_BEGIN < FX.MAIN_CONTACT and
        FX.MAIN_CONTACT < FX.MAIN_END and
        FX.MAIN_END > FX.SECOND_BEGIN,
        "sky leader phase/relay order preserved")
    var mock := [Vector2(855, 328), Vector2(974, 328),
        Vector2(855, 446)]
    for mode in range(2):
        check(FX.active_mock_contacts(mode, 0.10).size() == 0,
            "no fake hits during charge")
        check(FX.active_mock_contacts(mode, 0.90).size() == 0,
            "no lingering phantom damage")
        check(FX.active_mock_contacts(mode, 0.62).has(1),
            "second approved target is allowed during relay")
        check(not FX.active_mock_contacts(mode, 0.66).has(3),
            "fourth ignored monster must never be hit")
        for slot in range(3):
            var contact := FX.mock_contact_target(mock, slot)
            check(contact.is_equal_approx(mock[slot] + Vector2(0,-29)),
                "mock lightning contact stays anchored slot " + str(slot))
        var root := FX.discharge_root(mode, Vector2(298,464))
        check(root.distance_to(FX.mock_contact_target(mock,0)) > 210,
            "master lightning discharge is long enough to read at native size")
        for beat in range(4):
            var path := FX.bolt_path(root,
                FX.mock_contact_target(mock,0), 179, beat, 4, 34.0)
            check(path.size() == 17,
                "lightning hierarchy produces 17 vertices")
            check(path[0].is_equal_approx(root) and
                path[path.size()-1].is_equal_approx(
                FX.mock_contact_target(mock,0)),
                "lightning origin/impact endpoints must remain exact")
            for point in path:
                check(is_finite(point.x) and is_finite(point.y),
                    "all fractal samples finite")
            check(FX.bolt_endpoint(path, 0.0).is_equal_approx(root) and
                FX.bolt_endpoint(path, 1.0).is_equal_approx(
                FX.mock_contact_target(mock,0)),
                "progressive bolt lead never overshoots target")
        var p1 := FX.bolt_path(root,FX.mock_contact_target(mock,0),
            179, 1, 4, 34.0)
        var p2 := FX.bolt_path(root,FX.mock_contact_target(mock,0),
            179, 2, 4, 34.0)
        check(p1[4].distance_to(p2[4]) > 0.02,
            "lightning must morph, not freeze into a static ladder")
    var scene := ART.instantiate() as Control
    check(scene != null, "Thiên Lôi LAB scene loads")
    if scene != null:
        root.add_child(scene)
        check(scene.approved_hits.size() == 3 and
            not scene.approved_hits.has(Vector2(974,446)),
            "3 explicitly authorized demo victims only")
        check(scene.thunder_layer is Node2D,
            "light layer is separate from normal-blended actors")
        check(scene.thunder_layer.material is ShaderMaterial,
            "original V9 light material belongs only on light layer")
        check(scene.thunder_layer.z_index > 0,
            "light layer renders over actor normal materials")
        scene.queue_free()
    check(LAYER != null, "light layer source is available")
    print("VFX19_THIEN_LOI_FOCUSED_RESULT=" +
        ("PASS" if failed == 0 else "FAIL") +
        " failures=" + str(failed))
    quit(0 if failed == 0 else 1)
