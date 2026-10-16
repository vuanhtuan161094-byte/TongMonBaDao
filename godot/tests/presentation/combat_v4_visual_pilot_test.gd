extends SceneTree
## Focused evidence for the reduced VIEW LAB, not Android visual acceptance.
const WORLD = preload("res://src/presentation/labs/combat_v4_world_view.gd")
const SCENE = preload("res://scenes/labs/combat_v4_visual_pilot.tscn")

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> bool:
    if ok:
        return true
    push_error("CMB-V4 VP01: " + message)
    quit(1)
    return false

func _run() -> void:
    var ui := SCENE.instantiate()
    root.add_child(ui)
    await process_frame
    ui.set("paused", true)
    var battle: MapBattleV2 = ui.get("battle")
    var view: Node2D = ui.get("world")
    var camera: Camera2D = ui.get("camera")
    if not _check(battle != null and view != null and camera != null, "lab setup missing"):
        return
    if not _check(battle.encounter_id == "CMBV4_LAB_ONLY" and battle.actors.size() == 3,
        "fixture must have one true disciple actor and two catalogue monsters"):
        return
    if not _check(str(battle.actors["pilot_wolf"]["species_id"]) == "thanh_lang" and
        str(battle.actors["pilot_boss"]["species_id"]) == "hac_lang_vuong",
        "monster identities must come from canonical catalogue"):
        return
    if not _check(WORLD.world_point(Vector2.ZERO) == WORLD.MAP_RECT.position and
        WORLD.world_point(MapBattleV2.ARENA.size).distance_to(WORLD.MAP_RECT.end) < 0.001,
        "logical world / screen projection drifted"):
        return

    var before := MapBattleSnapshotV2.save(battle)
    if not _check(bool(before.get("ok", false)), "cannot snapshot before viewing"):
        return
    var rng_before := battle.rng.snapshot_seed_state()
    view.call("sync_visuals")
    view.call("consume_events", [{"type": "hit", "target": "pilot_wolf"}])
    view.call("advance_cosmetics", 0.016)
    ui.call("_set_zoom", 1.15, Vector2(640, 360))
    await process_frame
    var after := MapBattleSnapshotV2.save(battle)
    if not _check(before == after and battle.rng.snapshot_seed_state() == rng_before,
        "VIEW/camera/VFX mutated live battle snapshot or RNG"):
        return
    if not _check(absf(camera.zoom.x - 1.15) < 0.00001,
        "camera zoom did not apply"):
        return
    if not _check(bool(view.get("stage_art_loaded")) ==
        (view.get("disciple_visual") as ModularDiscipleActor).production_body_active(),
        "stage A status misrepresents body readiness"):
        return
    var trial := battle.step(false)
    if not _check(bool(trial.get("ok", false)) and battle.now == MapBattleV2.STEP_SECONDS,
        "only explicit fixture step should advance battle"):
        return
    view.call("sync_visuals")
    if not _check(battle.now == MapBattleV2.STEP_SECONDS,
        "visual refresh advanced battle"):
        return
    print("CMB-V4 VP01 VIEW ISOLATION/3 ACTORS/CAMERA: PASS")
    print("CMB-V4 Stage A art loaded: ", view.get("stage_art_loaded"),
        " (false means fallback; NOT visual acceptance)")
    ui.queue_free()
    await process_frame
    quit(0)
