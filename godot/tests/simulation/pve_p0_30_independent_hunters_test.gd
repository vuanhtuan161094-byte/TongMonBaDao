extends SceneTree

# PVE-P0 synthetic ENGINE capacity fixture on the REAL 192x192 Source A
# navigation. 30 independent actors and 20 occupied camps, <=40 live mobs;
# not a natural-newgame recruitment acceptance and never awards fake loot.
const SHA_REQUIREMENT := "sect_isometric_source_a_pve_v1"
var checks := 0
var world: PveSectWorldViewV1
var battle: MapBattleV2
var session: HuntingPveRunV2
var sent: Array = []

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool,what: String) -> bool:
    checks += 1
    if not ok:
        push_error("PVE_P0_30_HUNTERS_RED "+what)
        quit(1)
        return false
    return true

func _make_world() -> Dictionary:
    var navigation := SectIsometricWorldV1.pve_navigation_grid()
    if navigation.is_empty():
        return {}
    return PveOpenWorldTopologyV1.build(
        navigation,Vector2(SectIsometricWorldV1.PVE_SPAWN_CELL)+Vector2(0.5,0.5))

func _new_party(camps: Array) -> Array:
    var party: Array = []
    for i in range(30):
        var zone := i%20
        var position: Vector2 = camps[zone]
        var team := "team_alpha" if i < 6 else "solo_%02d" % i
        party.append({
            "id":"hunter_%02d" % i,"party_id":team,
            "role":"frontline","position":position,
            "hp":1000.0,"move_speed":3.0,
            "stats":{"max_hp":1000.0,"attack":12.0,"defense":10.0},
            "hunt_radius":PveDistributedWorldV1.HUNT_RADIUS
        })
    return party

func _registry(options: Dictionary) -> Dictionary:
    var registry := PveMultiCampPopulationV1.new_registry(10)
    if not bool(registry.get("ok",false)):
        return registry
    registry["world_camp_positions"] = []
    for point_value in options["camp_positions"]:
        var point: Vector2 = point_value
        registry["world_camp_positions"].append({"x":point.x,"y":point.y})
    var slots: Dictionary = options["slot_positions"]
    for raw_id in slots.keys():
        var at: Vector2 = slots[raw_id]
        registry["slots"][raw_id]["world_x"] = at.x
        registry["slots"][raw_id]["world_y"] = at.y
    registry["p0_distributed_world"] = true
    registry["p0_dormant_monsters"] = {}
    registry["p0_active_camps"] = []
    registry["p0_kill_rewards"] = {}
    registry["world_source_map"] = options.get("source_map","")
    registry["world_source_sha"] = options["source_blob_sha"]
    registry["world_respawn_delay"] = 30.0
    return registry

func _on_move(ids: Array,point: Vector2) -> void:
    sent.append({"ids":ids.duplicate(),"point":point})

func _run() -> void:
    var options := _make_world()
    if not _check(bool(options.get("ok",false))
            and str(options.get("source_map","")) == SHA_REQUIREMENT
            and options.get("camp_positions",[]).size() == 20,
            "official Source A navigation must contain 20 real camps"):
        return
    var party := _new_party(options["camp_positions"])
    battle = MapBattleV2.new(20261103)
    var started := battle.setup_open_world("p0_independent_thirty",party,[],options)
    if not _check(bool(started.get("ok",false))
            and battle._count_alive("disciple") == 30
            and battle._count_monster_records() == 0,
            "30 mixed solo/group actors cannot start same continuous world: "+str(started)):
        return
    session = HuntingPveRunV2.new()
    session.battle = battle
    session.mode = "multicamp"
    session.camp_index = 0
    session.camp_population = _registry(options)
    session.camp_slot_ids = []
    session.spawn_data = {"reward_seed":20261103}
    if not _check(bool(session.camp_population.get("ok",false)),
            "200 legitimate world slot registry did not initialize"):
        return
    var first := PveDistributedWorldV1.synchronize(session)
    if not _check(bool(first.get("ok",false)) and first.get("camps",[]).size() == 20
            and int(first.get("per_zone",0)) == 2
            and session.camp_slot_ids.size() == 40
            and battle._count_monster_records() == 40
            and session.camp_population.get("slots",{}).size() == 200,
            "20 occupied areas must load only 40/200 monsters: "+str(first)):
        return
    var valid := PveDistributedWorldV1.validate_saved(session)
    if not _check(valid.is_empty(),"distributed world validation failed: "+valid):
        return
    print("PVE_P0_30X20_ACTIVE_PASS "+JSON.stringify({
        "hunters":30,"areas":20,"active_monsters":40,"registered_slots":200,
        "mandatory_team":false,"six_team_members":6
    }))
    # Solo actor hold: keep its exact position while other party members
    # retain AUTO and combat continues without a global hunt-policy switch.
    var held := battle.set_disciple_hunt_policy(["hunter_20"],"hold")
    if not _check(bool(held.get("ok",false))
            and str(battle.actors["hunter_20"]["hunt_policy"]) == "hold"
            and str(battle.actors["hunter_21"]["hunt_policy"]) == "auto",
            "independent hold accidentally toggled 30 hunters"):
        return
    var invalid := battle.set_disciple_hunt_policy(["hunter_20","invalid"],"auto")
    if not _check(not bool(invalid.get("ok",true))
            and str(battle.actors["hunter_20"]["hunt_policy"]) == "hold",
            "invalid command must not partially override a guard order"):
        return
    var held_at: Vector2 = battle.actors["hunter_20"]["position"]
    for _frame in range(3):
        var stepped := battle.step()
        if not _check(bool(stepped.get("ok",false)),"real AI step failed"):
            return
    if not _check((battle.actors["hunter_20"]["position"] as Vector2).distance_to(held_at) < 0.0001,
            "hold actor chased monsters despite explicit guard order"):
        return
    var snapshot := MapBattleSnapshotV2.save(battle)
    var restored := MapBattleSnapshotV2.load(snapshot)
    if not _check(bool(snapshot.get("ok",false)) and bool(restored.get("ok",false)),
            "30 disciples / 40 live Source A monsters cannot survive snapshot"):
        return
    if not _check(str((restored["battle"] as MapBattleV2).actors["hunter_20"].get("hunt_policy","")) == "hold",
            "per-actor hold policy lost after Save/Reload"):
        return
    # Changing individual positions here is a QA LOD fixture ONLY, not a
    # production teleport or fast-travel ability. The real move route is tested
    # separately through order_group_move and the real minimap signal.
    for i in range(30):
        battle.actors["hunter_%02d" % i]["position"] = options["camp_positions"][0]
    var condensed := PveDistributedWorldV1.synchronize(session)
    if not _check(bool(condensed.get("ok",false))
            and condensed.get("camps",[]).size() == 1
            and battle._count_monster_records() == 10
            and session.camp_population.get("p0_dormant_monsters",{}).size() >= 30,
            "offscreen zones did not suspend existing monster lives: "+str(condensed)):
        return
    for i in range(30):
        battle.actors["hunter_%02d" % i]["position"] = options["camp_positions"][i%20]
    var reactivated := PveDistributedWorldV1.synchronize(session)
    if not _check(bool(reactivated.get("ok",false)) and battle._count_monster_records() == 40
            and session.camp_slot_ids.size() == 40
            and session.camp_population["p0_dormant_monsters"].is_empty(),
            "dormant monsters could not reactivate without duplicate new lives: "+str(reactivated)):
        return
    print("PVE_P0_WORLD_LOD_RESTORE_PASS "+JSON.stringify({
        "condensed":10,"distributed":40,"camp_count":20,"dormant_after_reactivation":0
    }))
    # Real presentation minimap orders only selected IDs; with nobody
    # selected the same click is a camera-focus command.
    world = PveSectWorldViewV1.new()
    world.size = Vector2(800,520)
    root.add_child(world)
    await process_frame
    var prepared := world.prepare_world()
    if not _check(bool(prepared.get("ok",false)),
            "real Source A minimap could not prepare"):
        return
    world.show_authority_snapshot(battle,session.camp_population,0,{},{})
    world.move_ordered.connect(_on_move)
    var at: Vector2 = options["camp_positions"][19]
    var before := world.camera_center
    world.selected_actor_ids = ["hunter_20"]
    world._focus_minimap(world.minimap_world_to_screen(at))
    if not _check(sent.size() == 1 and sent[0]["ids"] == ["hunter_20"]
            and (sent[0]["point"] as Vector2).distance_to(at) < 2.0
            and world.camera_center.distance_to(before) < 0.001,
            "selected minimap click must order that solo hunter to C20"):
        return
    world.selected_actor_ids.clear()
    world._focus_minimap(world.minimap_world_to_screen(at))
    if not _check(world.camera_center.distance_to(before) > 1.0
            and sent.size() == 1,
            "minimap without selection must focus camera, not issue movement"):
        return
    print("PVE_P0_MINIMAP_SOLO_ORDER_PASS "+JSON.stringify({
        "requested_zone":"C20","ordered_actor":"hunter_20",
        "no_selection_pans":true
    }))
    print("PVE_P0_30_HUNTERS_PASS checks=%d engine=Godot4.7.2" % checks)
    world.queue_free()
    quit(0)
