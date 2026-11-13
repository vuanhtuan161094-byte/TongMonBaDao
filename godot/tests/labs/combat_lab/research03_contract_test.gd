extends SceneTree

const STUDY = preload("res://labs/combat_lab/research03/research03_arena.gd")
const SCENE = preload("res://labs/combat_lab/research03/research03_arena.tscn")
const LIGHT = preload("res://labs/combat_lab/research03/light_core_2d.gdshader")
const HIT = preload("res://labs/combat_lab/research03/light_contact_2d.gdshader")
const AURORA = preload("res://labs/combat_lab/research03/light_orbit_aurora.gdshader")
var failures := 0

func chk(b: bool, label: String) -> void:
    if not b:
        failures += 1
        push_error("VFX18_FAIL " + label)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    chk(LIGHT is Shader and HIT is Shader and AURORA is Shader,
        "three original light shaders load")
    chk(STUDY.ORBIT_COUNT == 16, "bounded array of sixteen display streaks")
    chk(STUDY.start_point().distance_to(STUDY.stop_point()) > 350.0,
        "single qi crosses meaningful distance")
    chk(STUDY.stop_point().distance_to(STUDY.approved_target()) > 40.0,
        "light tip stops BEFORE monster chest")
    chk(STUDY.CONTACT > STUDY.PROJECTILE_START and
        STUDY.CONTACT_END > STUDY.CONTACT and
        STUDY.CONTACT_END < 1.0, "charge, flight, contact and decay sequenced")
    for k in range(17):
        var u := float(k) / 16.0
        var pt: Vector2 = STUDY.flight_head(u)
        var axis: Vector2 = STUDY.flight_direction(u)
        chk(is_finite(pt.x) and is_finite(pt.y) and
            absf(axis.length() - 1.0) < 0.0001,
            "cubic path finite and tangent unit @" + str(k))
    chk(STUDY.flight_head(1.0).is_equal_approx(STUDY.stop_point()),
        "projectile reaches precontact boundary, never victim origin")
    var visible_right := 0
    var visible_left := 0
    for i in range(5):
        var source: Vector2 = STUDY.charge_source(i, 0.12)
        chk(is_finite(source.x) and is_finite(source.y) and
            source.distance_to(STUDY.start_point()) < 150.0,
            "charge filaments must originate near caster " + str(i))
        if source.x > STUDY.start_point().x + 30.0:
            visible_right += 1
        if source.x < STUDY.start_point().x - 30.0:
            visible_left += 1
    chk(visible_right >= 3 and visible_left >= 2,
        "charge light strands must visibly reach both sides of caster")
    for i in range(16):
        var candidate: Dictionary = STUDY.orbit_streak(i, 0.4)
        chk(candidate.has("position") and candidate.has("axis") and
            candidate.has("length") and candidate.has("energy"),
            "orbit candidate data present " + str(i))
        var axis: Vector2 = candidate["axis"]
        chk(absf(axis.length() - 1.0) < 0.0001,
            "orbit tangent must be normalized " + str(i))
        var at: Vector2 = candidate["position"]
        chk(at.distance_to(STUDY.FIELD_CENTER) >= 119.0,
            "orbit inner sanctuary remains empty " + str(i))
    var scene := SCENE.instantiate() as Control
    chk(scene != null, "research03 independent scene instantiates")
    if scene != null:
        root.add_child(scene)
        chk(scene.blades.size() == 16 and scene.contacts.size() == 1,
            "bounded sixteen shaders and one mock contact cue")
        chk(scene.approved_hits.size() == 3 and
            not scene.approved_hits.has(Vector2(974, 446)),
            "ancestor 3/4 target fixture not promoted into false hit")
        scene.study_mode = 0
        scene.elapsed = 1.1
        scene._update_visuals()
        chk(scene.contacts[0].visible == false and
            not scene.orbit_actor.visible and not scene.atmosphere.visible,
            "single mode must never display orbit actor/haze or early impact")
        var prog: float = ((float(scene.elapsed) / STUDY.CYCLE_SECONDS) -
            STUDY.PROJECTILE_START) / (STUDY.CONTACT - STUDY.PROJECTILE_START)
        var head: Vector2 = STUDY.flight_head(prog)
        var carrier: Sprite2D = scene.blades[0]
        var local_tip := Vector2(4.0 * (STUDY.PROJECTILE_REACH - 0.5), 0.0)
        var visual_tip: Vector2 = carrier.to_global(local_tip)
        chk(visual_tip.distance_to(head) < 0.65,
            "shader local tip MUST be aligned to actual curved flight path")

        scene.elapsed = STUDY.CONTACT * STUDY.CYCLE_SECONDS + 0.025
        scene._update_visuals()
        chk(scene.contacts[0].visible == true,
            "exactly one contact cue in allowed demo window")
        scene.study_mode = 1
        scene.elapsed = 0.41 * STUDY.CYCLE_SECONDS
        scene._update_visuals()
        chk(scene.contacts[0].visible == false,
            "orbit mode does NOT generate hits or impact effects")
        chk(scene.orbit_actor != null and scene.orbit_actor.visible and
            scene.atmosphere != null and scene.atmosphere.visible,
            "orbit caster and atmospheric light sheet must be layered")
        var front_count := 0
        var back_count := 0
        for i in range(STUDY.ORBIT_COUNT):
            var shard: Dictionary = STUDY.orbit_streak(i, 0.41)
            var sprite: Sprite2D = scene.blades[i]
            if bool(shard["front"]):
                front_count += 1
                chk(sprite.z_index > scene.orbit_actor.z_index,
                    "front light should layer ABOVE actor " + str(i))
            else:
                back_count += 1
                chk(sprite.z_index < scene.orbit_actor.z_index,
                    "back light should layer BEHIND actor " + str(i))
        chk(front_count >= 3 and back_count >= 3,
            "two distinct orbit depth groups must both exist")
        chk(scene.atmosphere.z_index < scene.orbit_actor.z_index,
            "aurora sheet stays behind real visible actor")
        chk(scene.blades.size() == STUDY.ORBIT_COUNT,
            "new wakelets never spawn extra decorated sword shaders")
        scene.queue_free()
    print("VFX18_LIGHTCORE_FOCUSED_RESULT=" +
        ("PASS" if failures == 0 else "FAIL") +
        " failures=" + str(failures))
    quit(0 if failures == 0 else 1)
