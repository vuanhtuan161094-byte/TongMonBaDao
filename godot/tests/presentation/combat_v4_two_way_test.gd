extends SceneTree
## Two-way presentation test: no Up/Down art for human or beasts.
const LAB = preload("res://scenes/labs/combat_v4_visual_pilot.tscn")

func _init() -> void:
    call_deferred("_run")

func _assert_ok(ok: bool, message: String) -> bool:
    if ok:
        return true
    push_error("CMB-V4 TWO-WAY: " + message)
    quit(1)
    return false

func _run() -> void:
    var facing := CombatV4TwoWayFacing.RIGHT
    if not _assert_ok(
        CombatV4TwoWayFacing.for_motion(Vector2.LEFT, facing) == CombatV4TwoWayFacing.LEFT
        and CombatV4TwoWayFacing.for_motion(Vector2(0, -9), CombatV4TwoWayFacing.LEFT) == CombatV4TwoWayFacing.LEFT
        and CombatV4TwoWayFacing.for_motion(Vector2(0, 12), CombatV4TwoWayFacing.RIGHT) == CombatV4TwoWayFacing.RIGHT
        and CombatV4TwoWayFacing.for_motion(Vector2.RIGHT, CombatV4TwoWayFacing.LEFT) == CombatV4TwoWayFacing.RIGHT,
        "vertical travel should preserve side; horizontal motion changes side"
    ):
        return
    if not _assert_ok(
        CombatV4TwoWayFacing.flip_h(CombatV4TwoWayFacing.LEFT) and
        not CombatV4TwoWayFacing.flip_h(CombatV4TwoWayFacing.RIGHT) and
        CombatV4TwoWayFacing.flip_h(CombatV4TwoWayFacing.RIGHT, true) and
        not CombatV4TwoWayFacing.flip_h(CombatV4TwoWayFacing.LEFT, true),
        "native mirror must account for original PNG authored side"
    ):
        return
    var lib := CombatV4TwoWayMotion.build()
    if not _assert_ok(
        lib.has_animation(&"attack_right") and lib.has_animation(&"hit_right") and
        not lib.has_animation(&"attack_up") and not lib.has_animation(&"hit_down"),
        "combat motion must be one authored SIDE plus mirrored LEFT"
    ):
        return
    var lab := LAB.instantiate()
    root.add_child(lab)
    await process_frame
    lab.set("paused", true)
    var battle: MapBattleV2 = lab.get("battle")
    var view: Node2D = lab.get("world")
    if not _assert_ok(battle != null and view != null, "fixture did not load"):
        return
    var female: ModularDiscipleActor = view.get("disciple_visual")
    if not _assert_ok(female != null and female.animation_player.has_animation(&"attack_right") and
        female.animation_player.has_animation(&"hit_right"),
        "combat Stage A rig missing authored SIDE attack/hit clips"
    ):
        return

    var disciple: Dictionary = battle.actors["pilot_female"]
    var at: Vector2 = disciple["position"]
    disciple["position"] = at + Vector2(-1, 0)
    view.call("sync_visuals")
    if not _assert_ok(female.facing == &"left" and female.uses_mirrored_left() and
        female.current_playback_animation_name() == &"walk_right",
        "female left walk must mirror authored right clip"
    ):
        return
    disciple["position"] = at + Vector2(-1, -3)
    view.call("sync_visuals")
    if not _assert_ok(female.facing == &"left" and female.uses_mirrored_left(),
        "female moving UP must retain side-facing mirror"
    ):
        return
    disciple["position"] = at + Vector2(1, -3)
    view.call("sync_visuals")
    if not _assert_ok(female.facing == &"right" and not female.uses_mirrored_left(),
        "female moving RIGHT must restore authored profile"
    ):
        return
    var nodes: Dictionary = view.get("monster_nodes")
    if nodes.has("pilot_wolf"):
        var wolf: Dictionary = battle.actors["pilot_wolf"]
        var initial: Vector2 = wolf["position"]
        wolf["position"] = initial + Vector2(1, 0)
        view.call("sync_visuals")
        var sprite: Sprite2D = nodes["pilot_wolf"]
        if not _assert_ok(sprite.flip_h, "wolf source faces LEFT, moving RIGHT must mirror"):
            return
        wolf["position"] = initial + Vector2(1, 2)
        view.call("sync_visuals")
        if not _assert_ok(sprite.flip_h, "wolf vertical motion must retain its rightward flip"):
            return
    print("CMB-V4 TWO-WAY SIDE/MIRROR/STAGEA/BOSS: STATIC-CONTRACT PASS")
    print("Wolf concept art present: ", nodes.has("pilot_wolf"), " (optional art QA separate)")
    lab.queue_free()
    await process_frame
    quit(0)
