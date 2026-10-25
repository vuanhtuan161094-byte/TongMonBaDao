extends SceneTree

# PvE forest-map visual regression: the background follows the same
# read-only projection as Source A actors, without altering combat authority.
func _init() -> void:
    call_deferred("_run")


func _fail(reason: String) -> void:
    push_error("B3 PVE LANDSCAPE CONTRACT FAIL: "+reason)
    quit(1)


func _run() -> void:
    var derived: Dictionary = CombatStatsV2.derive(1,1,1,1,0.0)
    var stats: Dictionary = derived["stats"].duplicate(true)
    stats["max_hp"] = 2000.0
    stats["attack"] = 75.0
    var player := {
        "id":"pve_visual_disciple","party_id":"party_0","role":"frontline",
        "position":Vector2(11.0,10.0),"stats":stats,"hp":2000.0,
        "skill_loadout":[],"skill_factors":{}
    }
    var monster: Dictionary = MonsterCatalogueV2.create_actor(
        "thanh_lang",1,1,"pve_visual_wolf")
    monster["id"] = "pve_visual_wolf"
    monster["position"] = Vector2(23.0,10.0)
    var battle := MapBattleV2.new(20261025)
    if not bool(battle.setup("visual_only_pve", [player], [monster]).get("ok",false)):
        _fail("canonical MapBattleV2 test fixture did not initialize")
        return

    var canvas := B3CareCombatV5Presenter.new()
    canvas.enable_source_vl_art = true
    canvas.enable_spectator_framing = true
    canvas.draw_pilot_ground = true
    root.add_child(canvas)
    canvas.attach_session(battle)
    var before := MapBattleSnapshotV2.save(battle)
    if not B3CareHuntLandscapeV2.valid_layout(battle.ARENA.size):
        _fail("deterministic forest art escaped canonical 36x20 bounds")
        return
    if B3CareHuntLandscapeV2.PATCHES.size() < 6 or B3CareHuntLandscapeV2.EDGE_GRASS.size() < 10:
        _fail("source-backed forest stage has no discernible environmental accents")
        return

    var actor_position := Vector2(11.0,10.0)
    var projected_1 := canvas.point_on_map(actor_position)
    var floor_1 := canvas._source_a_floor_point(actor_position)
    if projected_1.distance_to(floor_1) > 0.001:
        _fail("floor and actor projection disagree before camera motion")
        return
    canvas.pan_camera_pixels(Vector2(74.0,-28.0))
    var projected_2 := canvas.point_on_map(actor_position)
    var floor_2 := canvas._source_a_floor_point(actor_position)
    if projected_2.distance_to(floor_2) > 0.001 or floor_1.distance_to(floor_2) < 5.0:
        _fail("PvE floor did not move with manual spectator pan")
        return
    canvas.set_spectator_zoom(1.45)
    var projected_3 := canvas.point_on_map(actor_position)
    var floor_3 := canvas._source_a_floor_point(actor_position)
    if projected_3.distance_to(floor_3) > 0.001 or canvas.spectator_zoom() < 1.44:
        _fail("PvE floor and actors diverged after zoom")
        return
    # Drawing occurs only in the CanvasItem notification; neither explicit
    # renderer calls nor their state must ever step MapBattleV2.
    canvas.queue_redraw()
    await process_frame
    await process_frame
    if MapBattleSnapshotV2.save(battle) != before:
        _fail("camera, landscape or forest sprites mutated combat state")
        return
    print("B3 PVE LANDSCAPE CONTRACT PASS arena=36x20 patches=%d trees=12 camera=pan_zoom battle_unchanged=true" % B3CareHuntLandscapeV2.PATCHES.size())
    quit(0)
