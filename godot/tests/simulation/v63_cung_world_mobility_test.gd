extends SceneTree

const MOBILITY_IDS := [
    "tmb.skill.bow.mobility.human",
    "tmb.skill.bow.mobility.immortal.base",
    "tmb.skill.bow.mobility.divine.base"
]
var failures := 0

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    for skill_id in MOBILITY_IDS:
        _check(_reachable_world_route(skill_id), skill_id+" did not path along a walkable world route")
        _check(_blocked_world_route_rejected(skill_id), skill_id+" activated through a disconnected blocked map")
    if failures == 0:
        print("V63 CUNG WORLD MOBILITY PASS")
    else:
        push_error("V63 CUNG WORLD MOBILITY FAILURES: "+str(failures))
    quit(1 if failures > 0 else 0)

func _check(value: bool, message: String) -> bool:
    if not value:
        failures += 1
        push_error(message)
    return value

func _new_open_world(skill_id: String, gap_y: int) -> Dictionary:
    var width := 16
    var height := 12
    var blocked := PackedByteArray()
    blocked.resize(width*height)
    blocked.fill(0)
    for y in range(height):
        if y != gap_y:
            blocked[y*width+4] = 1
    var navigation := {
        "width":width,"height":height,"blocked":blocked,
        "source_blob_sha":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    }
    var core := CombatStatsV2.derive(11,1,10,1,0.0)
    var stats: Dictionary = core.stats.duplicate(true)
    stats["max_hp"] = 100000.0
    stats["attack"] = 180.0
    stats["defense"] = 100.0
    var actor := {
        "id":"cung_actor","party_id":"cung_world_test","role":"ranged","tier":"disciple",
        "race_id":"nhan_toc","position":Vector2(2.5,6.5),"stats":stats,
        "hp":100000.0,"max_hp":100000.0,"resistances":core.resistances.duplicate(true),
        "basic_range":2.0,"move_speed":2.0,"basic_ratio":0.0,"basic_interval":20.0,
        "skill_loadout":[],"skill_factors":{},"context_sources":[],"disciple":null,
        "v63_combat_enabled":true,"v63_skill_loadout":[skill_id],"v63_skill_ready":{}
    }
    var target: Dictionary = MonsterCatalogueV2.create_actor("truc_thu",11,1,"world_target")
    target["id"] = "world_target"
    target["position"] = Vector2(7.5,6.5)
    target["spawn_slot_id"] = "cung_world_target_" + skill_id
    target["slot_generation"] = 1
    var battle := MapBattleV2.new(760001+MOBILITY_IDS.find(skill_id))
    var started := battle.setup_open_world(
        "cung_world_"+str(MOBILITY_IDS.find(skill_id)),
        [actor],[target],
        {"bounds":Rect2(Vector2.ZERO,Vector2(width,height)),"navigation":navigation}
    )
    if not bool(started.get("ok",false)):
        return {"ok":false,"reason":str(started)}
    battle.actors["world_target"]["move_speed"] = 0.0
    battle.actors["world_target"]["aggro_range"] = 0.0
    return {"ok":true,"battle":battle}

func _reachable_world_route(skill_id: String) -> bool:
    var setup := _new_open_world(skill_id,8)
    if not bool(setup.get("ok",false)):
        return _check(false,skill_id+" world setup failed: "+str(setup.get("reason","")))
    var battle: MapBattleV2 = setup.battle
    var actor: Dictionary = battle.actors["cung_actor"]
    var target: Dictionary = battle.actors["world_target"]
    var skill := V63HumanSkillCombatSystem.skill_definition(skill_id)
    var ready: Dictionary = {}
    var origin: Vector2 = actor.position
    var path: Array[Vector2i] = battle._world_path(origin,target.position)
    if not _check(path.size() > 1,skill_id+" fixture did not produce a route"):
        return false
    var route_distance := battle._world_route_distance(origin,path)
    if not _check(route_distance <= float(skill.range),skill_id+" fixture route exceeds skill range"):
        return false
    if not _check(V63HumanSkillCombatSystem._try_mobility(battle,actor,target,skill_id,skill,ready),
            skill_id+" did not start mobility on a valid world route"):
        return false
    if not _check(bool(actor.get("move_order_active",false)),
            skill_id+" did not schedule path-following movement"):
        return false
    var mobility_event := false
    for event in battle.events:
        if str(event.get("type","")) == "v63_mobility" and str(event.get("skill_id","")) == skill_id:
            mobility_event = bool(event.get("world_path",false)) and float(event.get("route_distance",0.0)) > 0.0
    if not _check(mobility_event,skill_id+" lacks world-path mobility receipt"):
        return false

    var snapshot := MapBattleSnapshotV2.save(battle)
    var restored := MapBattleSnapshotV2.load(snapshot)
    if not _check(bool(snapshot.get("ok",false)) and bool(restored.get("ok",false)),
            skill_id+" world mobility order did not survive Combat V2 snapshot"):
        return false
    var resumed: MapBattleV2 = restored.battle
    actor = resumed.actors["cung_actor"]
    var destination: Vector2 = actor.get("move_order_position",actor.position)
    var previous: Vector2 = actor.position
    for _i in range(80):
        if previous.distance_to(destination) <= 0.08:
            break
        resumed._move_world_actor(actor,destination,float(actor.move_speed))
        var current: Vector2 = actor.position
        if not resumed._position_allowed(current):
            return _check(false,skill_id+" crossed into a blocked cell")
        if previous.distance_to(current) > float(actor.move_speed)*MapBattleV2.STEP_SECONDS+0.001:
            return _check(false,skill_id+" jumped between path steps")
        previous = current
    var final_distance := (actor.position as Vector2).distance_to(resumed.actors["world_target"].position)
    var reached_destination := (actor.position as Vector2).distance_to(destination) <= 0.08
    return _check(reached_destination and final_distance <= float(actor.get("range",2.0))+1.0,
            skill_id+" did not finish its scheduled reachable path close to the target")

func _blocked_world_route_rejected(skill_id: String) -> bool:
    var setup := _new_open_world(skill_id,-1)
    if not bool(setup.get("ok",false)):
        return _check(false,skill_id+" blocked-world setup failed: "+str(setup.get("reason","")))
    var battle: MapBattleV2 = setup.battle
    var actor: Dictionary = battle.actors["cung_actor"]
    var target: Dictionary = battle.actors["world_target"]
    var original: Vector2 = actor.position
    var skill := V63HumanSkillCombatSystem.skill_definition(skill_id)
    var started := V63HumanSkillCombatSystem._try_mobility(battle,actor,target,skill_id,skill,{})
    var event_seen := false
    for event in battle.events:
        event_seen = event_seen or str(event.get("type","")) == "v63_mobility"
    return _check(not started and not event_seen and actor.position == original,
            skill_id+" mobility should not activate when the world grid disconnects target from caster")
