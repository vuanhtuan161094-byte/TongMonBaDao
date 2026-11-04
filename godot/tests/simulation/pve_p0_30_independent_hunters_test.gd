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
var hunt_commands: Array = []

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

func _on_hunt_policy(ids: Array,policy: String) -> void:
    hunt_commands.append({"ids":ids.duplicate(),"policy":policy})

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
    # Engine-only synthetic 31st actor is rejected without changing the
    # true 30-hunter world. This cannot be used as New Game recruitment QA.
    var overflow: Dictionary = party[0].duplicate(true)
    overflow["id"] = "hunter_30"
    overflow["party_id"] = "solo_30"
    var forbidden := battle.add_world_disciple(overflow)
    if not _check(not bool(forbidden.get("ok",true))
            and str(forbidden.get("reason","")) == "p0_world_hunter_cap"
            and not battle.actors.has("hunter_30")
            and battle._count_alive("disciple") == 30,
            "31st synthetic actor bypassed 30-hunter authority"):
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
            and session.camp_population["p0_dormant_monsters"].size() == 8,
            "20 zones use 2/10 active slots each; eight C01 mobs must stay dormant: "+str(reactivated)):
        return
    print("PVE_P0_WORLD_LOD_RESTORE_PASS "+JSON.stringify({
        "condensed":10,"distributed":40,"camp_count":20,"dormant_after_reactivation":8
    }))
    # V6.3 support must affect SAME voluntary party only, not all 30
    # independent hunters standing nearby. This checks both targeting and AoE.
    var h0: Dictionary = battle.actors["hunter_00"]
    var h1: Dictionary = battle.actors["hunter_01"]
    var solo: Dictionary = battle.actors["hunter_20"]
    var anchor: Vector2 = options["camp_positions"][0]
    h0["position"] = anchor
    h1["position"] = anchor+Vector2(0.5,0.0)
    solo["position"] = anchor+Vector2(0.0,0.5)
    h0["hp"] = 500.0
    h1["hp"] = 400.0
    solo["hp"] = 100.0
    var support_skill := {"effect":"heal","range":9.0,"power":0.2}
    var team_target := V63HumanSkillCombatSystem._support_target(
        battle,h0,support_skill)
    if not _check(str(team_target.get("id","")) == "hunter_01",
            "V6.3 heal targeted lower-HP unaffiliated solo hunter instead of team member"):
        return
    var solo_target := V63HumanSkillCombatSystem._support_target(
        battle,solo,support_skill)
    if not _check(str(solo_target.get("id","")) == "hunter_20",
            "solo disciple must be able to heal self but not another voluntary party"):
        return
    var aoe_cast := {"shape":"circle","center":anchor,"radius":9.0,"maximum":6}
    var targets := V63HumanSkillCombatSystem._cast_targets(battle,h0,aoe_cast,"heal")
    var teammates := targets.map(func(x: Dictionary): return str(x.get("id","")))
    if not _check(teammates.has("hunter_00") and teammates.has("hunter_01")
            and not teammates.has("hunter_20"),
            "V6.3 area healing leaked across optional party boundary"):
        return
    print("PVE_P0_OPTIONAL_PARTY_SUPPORT_PASS "+JSON.stringify({
        "team_members":["hunter_00","hunter_01"],"solo":"hunter_20",
        "aoe_excludes_unauthorized_solo":true
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
    var auto_button := world.get_node_or_null("PveP0HuntAuto") as Button
    var hold_button := world.get_node_or_null("PveP0HuntHold") as Button
    if not _check(world.selected_actor_ids.is_empty()
            and auto_button != null and hold_button != null
            and not auto_button.visible and not hold_button.visible,
            "P0 must not auto-select all 30 hunters; unbound command buttons must be hidden"):
        return
    world.hunt_policy_ordered.connect(_on_hunt_policy)
    world.selected_actor_ids = ["hunter_20"]
    world.refresh_hunt_controls()
    if not _check(auto_button.visible and hold_button.visible
            and not auto_button.disabled and not hold_button.disabled,
            "bound P0 AUTO/HOLD buttons unavailable for selected solo hunter"):
        return
    hold_button.pressed.emit()
    if not _check(hunt_commands.size() == 1
            and hunt_commands[0]["ids"] == ["hunter_20"]
            and str(hunt_commands[0]["policy"]) == "hold"
            and str(battle.actors["hunter_20"].get("hunt_policy","")) == "hold",
            "HOLD must emit selected solo IDs without unsaved direct UI mutation"):
        return
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
    # Regression: minimap travel must not switch OFF the departure zone's
    # active monsters while the hunter is still physically standing there.
    # Both departure C01 and target C20 are real authorized world zones.
    var solo_battle := MapBattleV2.new(20261104)
    var solo_started := solo_battle.setup_open_world(
        "p0_travel_origin_and_target",[_new_party(options["camp_positions"])[0]],[],options)
    if not _check(bool(solo_started.get("ok",false)),
            "solo travel regression could not start official Source A map"):
        return
    var solo_session := HuntingPveRunV2.new()
    solo_session.battle = solo_battle
    solo_session.mode = "multicamp"
    solo_session.camp_index = 0
    solo_session.camp_population = _registry(options)
    solo_session.camp_slot_ids = []
    solo_session.spawn_data = {"reward_seed":20261104}
    var departure := PveDistributedWorldV1.synchronize(solo_session)
    if not _check(bool(departure.get("ok",false))
            and departure.get("camps",[]) == [0]
            and solo_battle._count_monster_records() == 10,
            "departure camp must begin with its ten real spawn slots"):
        return
    var hold_before_move := solo_battle.set_disciple_hunt_policy(["hunter_00"],"hold")
    var travel := solo_battle.order_group_move(
        ["hunter_00"],options["camp_positions"][19])
    var while_travelling := PveDistributedWorldV1.synchronize(solo_session)
    if not _check(bool(hold_before_move.get("ok",false))
            and bool(travel.get("ok",false))
            and str(solo_battle.actors["hunter_00"].get("hunt_after_move","")) == "hold"
            and bool(while_travelling.get("ok",false))
            and while_travelling.get("camps",[]) == [0,19]
            and solo_battle._count_monster_records() == 20
            and bool(solo_battle.actors["hunter_00"].get("move_order_active",false))
            and PveDistributedWorldV1.zone_for_point(
                solo_session.camp_population["world_camp_positions"],
                solo_battle.actors["hunter_00"]["position"]) == 0,
            "traveling solo lost origin camp monsters before physical arrival: "
            +str(while_travelling)):
        return
    print("PVE_P0_TRAVEL_ORIGIN_CAMP_PASS camps=2 monsters=20 physical_zone=C01 target=C20")
    # A hunter may stand precisely on the canonical monster spawn tile.
    # Activation must keep the slot identity but place the new monster on a
    # nearby legal free cell, rather than create an overlapping sprite/collider.
    var occupied_slot := PveMultiCampPopulationV1.slot_id(0,0)
    var occupied_at: Vector2 = options["slot_positions"][occupied_slot]
    var crowded_actor: Dictionary = _new_party(options["camp_positions"])[0]
    crowded_actor["position"] = occupied_at
    var crowded_battle := MapBattleV2.new(20261105)
    var crowded_start := crowded_battle.setup_open_world(
        "p0_occupied_monster_spawn",[crowded_actor],[],options)
    if not _check(bool(crowded_start.get("ok",false)),
            "actual slot location is not a legal world coordinate"):
        return
    var crowded_session := HuntingPveRunV2.new()
    crowded_session.battle = crowded_battle
    crowded_session.mode = "multicamp"
    crowded_session.camp_index = 0
    crowded_session.camp_population = _registry(options)
    crowded_session.camp_slot_ids = []
    crowded_session.spawn_data = {"reward_seed":20261105}
    var safe_spawned := PveDistributedWorldV1.synchronize(crowded_session)
    if not _check(bool(safe_spawned.get("ok",false))
            and crowded_battle._count_monster_records() == 10,
            "occupied Source A spawn blocked legal neighboring spawn cells"):
        return
    var monsters_collide := false
    var original_slot_preserved := false
    for mob_value in crowded_battle.actors.values():
        var mob: Dictionary = mob_value
        if str(mob.get("side","")) != "monster":
            continue
        monsters_collide = monsters_collide or (
            mob["position"] as Vector2).distance_squared_to(occupied_at) < 0.64
        if str(mob.get("spawn_slot_id","")) == occupied_slot:
            original_slot_preserved = (
                mob["position"] as Vector2).distance_squared_to(occupied_at) >= 0.64 \
                and str(mob.get("id","")).contains(occupied_slot)
    if not _check(not monsters_collide and original_slot_preserved,
            "new monster overlapped existing hunter or changed official slot ID"):
        return
    print("PVE_P0_SAFE_MONSTER_RESPAWN_PASS slot="+occupied_slot
        +" active_monsters=10 no_overlap=true")
    print("PVE_P0_30_HUNTERS_PASS checks=%d engine=Godot4.7.2" % checks)
    world.queue_free()
    quit(0)
