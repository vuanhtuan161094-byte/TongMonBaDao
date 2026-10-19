extends SceneTree

# PRES-01 ONLY: view interpolation, role identification, HUD layout and V2 isolation.
# Run: godot --headless --path godot -s res://tests/presentation/c4_pres01_view_motion_readability_test.gd
func _init() -> void:
    call_deferred("_run")

func _check(condition: bool, label: String) -> bool:
    if not condition:
        push_error("C4 PRES-01: " + label)
        quit(1)
        return false
    return true

func _run() -> void:
    var model: Dictionary = CombatStatsV2.derive(2,1,2,1,0.0)
    if not _check(bool(model.get("ok",false)),"V2 fixture invalid"):
        return
    var member := {"id":"c4_member","party_id":"c4",
        "role":"frontline","position":Vector2(6.0,9.0),
        "stats":model["stats"],"hp":float(model["stats"]["max_hp"]),
        "pilot_skill_loadout":["jx_shaolin_15"]}
    var wolf: Dictionary = MonsterCatalogueV2.create_actor("thanh_lang",1,1,"c4_wolf")
    if not _check(bool(wolf.get("ok",false)),"V2 wolf unavailable"):
        return
    wolf["id"] = "c4_wolf"
    wolf["position"] = Vector2(15.0,9.0)
    var battle := MapBattleV2.new(41726)
    if not _check(bool(battle.setup("pres01_observation",[member],[wolf]).get("ok",false)),
            "V2 setup rejected"):
        return
    var layer := MapBattleWorldLayerV2.new()
    layer.enable_source_vl_art = true
    layer.draw_pilot_ground = true
    get_root().add_child(layer)
    layer.attach_session(battle)
    var original_position: Vector2 = battle.actors["c4_member"]["position"]
    if not _check(layer.visual_position("c4_member",original_position) == original_position,
            "initial displayed endpoint differs from authority"):
        return
    if not _check(layer._school_tag(battle.actors["c4_member"]) == "TL",
            "actual equipped pilot ID not reflected in role marker"):
        return
    var advanced := false
    for i in range(12):
        if not battle.active:
            break
        battle.step(true)
        var next_pos: Vector2 = battle.actors["c4_member"]["position"]
        if next_pos != original_position:
            advanced = true
            layer.refresh_from_authority()
            if not _check(layer.visual_position("c4_member",next_pos).is_equal_approx(original_position),
                    "new sim tick must not teleport the rendered actor"):
                return
            var snapshot_now := battle.now
            var snapshot_rng := battle.rng.snapshot_seed_state()
            var snapshot_actor: Dictionary = battle.actors.duplicate(true)
            var snapshot_events: Array = battle.events.duplicate(true)
            layer._view_elapsed = MapBattleV2.STEP_SECONDS*0.5
            var middle := layer.visual_position("c4_member",next_pos)
            if not _check(middle.is_equal_approx(original_position.lerp(next_pos,0.5)),
                    "250ms position interpolation mid-point is wrong"):
                return
            layer._view_elapsed = MapBattleV2.STEP_SECONDS*5.0
            if not _check(layer.visual_position("c4_member",next_pos).is_equal_approx(next_pos),
                    "view interpolator overshot authoritative endpoint"):
                return
            layer.refresh_from_authority()
            if not _check(battle.now == snapshot_now and
                    battle.rng.snapshot_seed_state() == snapshot_rng and
                    battle.actors == snapshot_actor and battle.events == snapshot_events,
                    "view touched battle event/HP/position/RNG/time authority"):
                return
            break
        layer.refresh_from_authority()
        original_position = next_pos
    if not _check(advanced,"V2 character did not move for interpolation fixture"):
        return
    var bar1: Rect2 = Rect2(Vector2(300,150),Vector2(52,6))
    var bar2: Rect2 = Rect2(Vector2(308,152),Vector2(52,6))
    var placed := layer.layout_hp_overlays([
        {"rect":bar1,"fill":Color.GREEN,"ratio":0.5},
        {"rect":bar2,"fill":Color.RED,"ratio":0.7}
    ])
    if not _check(placed.size() == 2 and
            not (placed[0]["rect"] as Rect2).grow(3.0).intersects(
                (placed[1]["rect"] as Rect2).grow(3.0)),
            "two overlapping health bars remained unreadable"):
        return
    if not _check((placed[0]["rect"] as Rect2) == bar1,
            "bar layout must never mutate original entry"):
        return
    # Two separate display interactions do not step 0.25s simulation.
    var now_before := battle.now
    var actors_before: Dictionary = battle.actors.duplicate(true)
    var events_before: Array = battle.events.duplicate(true)
    var rng_before := battle.rng.snapshot_seed_state()
    layer._process(0.1)
    layer.queue_redraw()
    await process_frame
    await process_frame
    if not _check(battle.now == now_before and battle.actors == actors_before and
            battle.events == events_before and battle.rng.snapshot_seed_state() == rng_before,
            "view frame changed authoritative simulation"):
        return
    layer.queue_free()
    print("C4 PRES-01 VIEW MOTION READABILITY: PASS")
    quit(0)
