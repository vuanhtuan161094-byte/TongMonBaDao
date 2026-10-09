class_name MapBattleV2
extends RefCounted

# DV2-02D: deterministic, event-driven, group-versus-group map battle.
# Local world coordinates (0..36, 0..20), never pixel/screen coordinates.
# The scene renders actor positions/events; camera/visibility is NOT simulation input.
# This is a V2-only encounter; legacy P3.7 CombatSystem routing is untouched.
const STEP_SECONDS := 0.25
const MAX_SECONDS := 90.0
const MAX_EVENTS := 2400
const ARENA := Rect2(Vector2.ZERO,Vector2(36.0,20.0))
const MAX_DISCIPLES := 30
const MAX_MONSTERS := 40
const MAX_TARGETS_AOE := 3

var rng: GameRng
var now: float = 0.0
var encounter_id: String = ""
var actors: Dictionary = {}
var pending_casts: Array = []
var events: Array = []
var active: bool = false
var outcome: String = "uninitialized"
var actions: int = 0
var downed_disciples: int = 0

func _init(seed_value: int = 515151) -> void:
    rng = GameRng.new(seed_value)

func setup(id: String, party: Array, monsters: Array) -> Dictionary:
    if active or id.is_empty() or party.is_empty() or party.size() > MAX_DISCIPLES:
        return {"ok":false,"reason":"invalid_encounter_or_party"}
    if monsters.is_empty() or monsters.size() > MAX_MONSTERS:
        return {"ok":false,"reason":"invalid_monster_group"}
    actors.clear()
    events.clear()
    pending_casts.clear()
    now = 0.0
    encounter_id = id
    actions = 0
    downed_disciples = 0
    var entries: Array = []
    for raw in party:
        if not (raw is Dictionary):
            return {"ok":false,"reason":"invalid_party_entry"}
        var row: Dictionary = raw
        var actor_id := str(row.get("id",""))
        var stats: Dictionary = row.get("stats",{})
        var pos: Vector2 = row.get("position",Vector2(-1.0,-1.0))
        var role := str(row.get("role","frontline"))
        if actor_id.is_empty() or stats.is_empty() or not ARENA.has_point(pos) or not ["frontline","ranged","mage","healer"].has(role):
            return {"ok":false,"reason":"invalid_party_actor"}
        var hp := float(row.get("hp",float(stats.get("max_hp",0.0))))
        var max_hp := float(stats.get("max_hp",0.0))
        if hp <= 0.0 or max_hp <= 0.0 or hp > max_hp or float(stats.get("attack",0.0)) <= 0.0:
            return {"ok":false,"reason":"invalid_party_hp_or_attack"}
        entries.append({
            "id":actor_id,"side":"disciple","role":role,"tier":"disciple",
            "race_id":"nhan_toc","position":pos,"stats":stats.duplicate(true),
            "hp":hp,"max_hp":max_hp,"resistances":row.get("resistances",{}).duplicate(true),
            "range":1.5 if role == "frontline" else (4.8 if role == "healer" else 5.5),
            "move_speed":2.35 if role == "frontline" else 2.05,
            "next_basic":0.0,"next_skill":0.0,
            "linked_disciple":row.get("disciple",null)
        })
    for raw in monsters:
        if not (raw is Dictionary):
            return {"ok":false,"reason":"invalid_monster_entry"}
        var row: Dictionary = raw
        var actor_id := str(row.get("id",row.get("encounter_id","")))
        var stats: Dictionary = row.get("stats",{})
        var position: Vector2 = row.get("position",Vector2(-1.0,-1.0))
        var tier := str(row.get("tier",""))
        if actor_id.is_empty() or not ARENA.has_point(position) or not ["normal","elite","boss"].has(tier):
            return {"ok":false,"reason":"invalid_monster_actor"}
        if stats.is_empty() or float(stats.get("max_hp",0.0)) <= 0.0 or float(stats.get("attack",0.0)) <= 0.0:
            return {"ok":false,"reason":"invalid_monster_stats"}
        entries.append({
            "id":actor_id,"side":"monster","role":"monster","tier":tier,
            "race_id":str(row.get("race_id","")),
            "position":position,"stats":stats.duplicate(true),
            "hp":float(row.get("hp",stats["max_hp"])),
            "max_hp":float(stats["max_hp"]),
            "resistances":row.get("resistances",{}).duplicate(true),
            "range":1.65 if tier == "boss" else 1.50,
            "move_speed":1.9 if tier == "boss" else 2.2,
            "next_basic":0.0,"next_skill":3.5 if tier == "boss" else 4.0,
            "linked_disciple":null
        })
    entries.sort_custom(func(a,b): return str(a["id"]) < str(b["id"]))
    for actor in entries:
        var actor_id := str(actor["id"])
        if actors.has(actor_id) or float(actor["hp"]) <= 0.0 or float(actor["hp"]) > float(actor["max_hp"]):
            actors.clear()
            return {"ok":false,"reason":"duplicate_actor_or_invalid_monster_hp"}
        actors[actor_id] = actor
    active = true
    outcome = "fighting"
    _event("battle_start",{"encounter_id":id,"disciples":party.size(),"monsters":monsters.size()})
    return {"ok":true,"encounter_id":id}

func step(viewed_map: bool = false) -> Dictionary:
    # viewed_map deliberately not consulted; same deterministic simulation.
    if not active:
        return {"ok":false,"reason":"encounter_not_active","outcome":outcome}
    now += STEP_SECONDS
    _release_casts()
    var actor_ids: Array = actors.keys()
    actor_ids.sort()
    for id_value in actor_ids:
        var id := str(id_value)
        var actor: Dictionary = actors[id]
        if float(actor["hp"]) <= 0.0:
            continue
        if _count_alive("disciple") == 0 or _count_alive("monster") == 0:
            break
        # Pending cast commits an action and blocks another action by that actor.
        if _actor_casting(id):
            continue
        var target: Dictionary = _nearest_enemy(actor)
        if target.is_empty():
            continue
        if str(actor["role"]) == "healer" and now >= float(actor["next_skill"]):
            if _heal_ally(actor):
                continue
        var distance := (actor["position"] as Vector2).distance_to(target["position"])
        var attack_range := float(actor["range"])
        if distance > attack_range:
            var delta := minf(float(actor["move_speed"])*STEP_SECONDS,maxf(0.0,distance-attack_range+0.02))
            if delta > 0.0:
                var direction := ((target["position"] as Vector2)-(actor["position"] as Vector2)).normalized()
                actor["position"] = _keep_inside((actor["position"] as Vector2)+direction*delta)
                _event("move",{"actor_id":id,"position":actor["position"]})
            continue
        if now >= float(actor["next_skill"]):
            if str(actor["tier"]) == "elite" or str(actor["tier"]) == "boss":
                _begin_telegraphed_aoe(actor,target)
                continue
            if str(actor["role"]) == "mage" and _enemies_near(target,3.0)>=2:
                _cast_mage_aoe(actor,target)
                continue
        if now >= float(actor["next_basic"]):
            _deal_direct(actor,target,1.0,"basic",true)
            var interval := CombatStatsV2.effective_interval(
                1.65 if str(actor["side"]) == "monster" else 1.6,
                float(actor["stats"].get("attack_speed",0.0))
            )
            actor["next_basic"] = now+maxf(STEP_SECONDS,interval)
    if _count_alive("monster") == 0:
        outcome = "win"
        active = false
    elif _count_alive("disciple") == 0:
        outcome = "defeat"
        active = false
    elif now >= MAX_SECONDS:
        outcome = "timeout_retreat"
        active = false
    if not active:
        _event("battle_end",{"outcome":outcome,"elapsed":now,"downed_disciples":downed_disciples})
    return {"ok":true,"outcome":outcome,"time":now,"alive_disciples":_count_alive("disciple"),"alive_monsters":_count_alive("monster")}

func run(max_steps: int = 400, viewed_map: bool = false) -> Dictionary:
    for _step in range(mini(max_steps,int(ceil(MAX_SECONDS/STEP_SECONDS))+1)):
        if not active:
            break
        step(viewed_map)
    return summary()

func summary() -> Dictionary:
    var remaining_hp := 0.0
    var remaining_max_hp := 0.0
    var positions: Dictionary = {}
    var ids: Array = actors.keys()
    ids.sort()
    for id in ids:
        var actor: Dictionary = actors[id]
        positions[str(id)] = actor["position"]
        if str(actor["side"]) == "disciple":
            remaining_hp += float(actor["hp"])
            remaining_max_hp += float(actor["max_hp"])
    return {
        "outcome":outcome,"time":now,"actions":actions,
        "alive_disciples":_count_alive("disciple"),"alive_monsters":_count_alive("monster"),
        "downed_disciples":downed_disciples,
        "disciple_remaining_hp_ratio":remaining_hp/maxf(remaining_max_hp,1.0),
        "positions":positions,"events":events.duplicate(true)
    }

func _nearest_enemy(actor: Dictionary) -> Dictionary:
    var best: Dictionary = {}
    var best_distance := INF
    var ids: Array = actors.keys()
    ids.sort()
    for id in ids:
        var other: Dictionary = actors[id]
        if str(other["side"]) == str(actor["side"]) or float(other["hp"]) <= 0.0:
            continue
        var distance := (actor["position"] as Vector2).distance_squared_to(other["position"])
        if distance+0.00001 < best_distance:
            best = other
            best_distance = distance
    return best

func _heal_ally(actor: Dictionary) -> bool:
    var candidates: Array = []
    for ally in actors.values():
        if str(ally["side"]) != str(actor["side"]) or float(ally["hp"]) <= 0.0:
            continue
        if float(ally["hp"])/maxf(1.0,float(ally["max_hp"])) >= 0.65:
            continue
        if (ally["position"] as Vector2).distance_to(actor["position"]) > 6.0:
            continue
        candidates.append(ally)
    if candidates.is_empty():
        return false
    candidates.sort_custom(func(a,b):
        var ar := float(a["hp"])/float(a["max_hp"])
        var br := float(b["hp"])/float(b["max_hp"])
        return str(a["id"]) < str(b["id"]) if absf(ar-br)<0.000001 else ar<br
    )
    var target: Dictionary = candidates[0]
    var healed := minf(float(target["max_hp"])-float(target["hp"]),float(actor["stats"]["attack"])*1.25)
    target["hp"] = minf(float(target["max_hp"]),float(target["hp"])+healed)
    _sync_linked_hp(target)
    actor["next_skill"] = now+6.0
    _event("heal",{"caster":actor["id"],"target":target["id"],"amount":healed})
    actions += 1
    return true

func _deal_direct(attacker: Dictionary, target: Dictionary, ratio: float, kind: String, eligible_lifesteal: bool) -> float:
    if float(attacker["hp"]) <= 0.0 or float(target["hp"]) <= 0.0:
        return 0.0
    var a_stats: Dictionary = attacker["stats"]
    var t_stats: Dictionary = target["stats"]
    var crit := rng.chance(CombatStatsV2.effective_crit_chance(a_stats,t_stats))
    var hit := CombatStatsV2.resolve_direct_hit(
        a_stats,t_stats,target["resistances"],ratio,crit,"",1.0,true
    )
    if not bool(hit.get("ok",false)):
        return 0.0
    var settlement := CombatStatsV2.settle_damage_and_lifesteal(
        hit,a_stats,t_stats,float(attacker["hp"]),float(attacker["max_hp"]),
        float(target["hp"]),eligible_lifesteal
    )
    if not bool(settlement.get("ok",false)):
        return 0.0
    var actual_damage := float(settlement["actual_damage"])
    target["hp"] = float(settlement["target_hp_after"])
    attacker["hp"] = float(settlement["attacker_hp_after"])
    _sync_linked_hp(attacker)
    _sync_linked_hp(target)
    actions += 1
    _event("hit",{"attacker":attacker["id"],"target":target["id"],"damage":actual_damage,
        "kind":kind,"critical":crit,"lifesteal":settlement["lifesteal_heal"]})
    if float(target["hp"]) <= 0.0:
        _event("downed",{"actor_id":target["id"],"side":target["side"]})
        if str(target["side"]) == "disciple":
            downed_disciples += 1
    return actual_damage

func _cast_mage_aoe(actor: Dictionary, target: Dictionary) -> void:
    actor["next_skill"] = now+7.0
    var selected := _area_targets(str(actor["side"]),target["position"],3.0,MAX_TARGETS_AOE)
    _event("cast",{"actor_id":actor["id"],"skill":"area_burst","target_count":selected.size()})
    for enemy in selected:
        _deal_direct(actor,enemy,0.90,"area_burst",false)

func _begin_telegraphed_aoe(actor: Dictionary, target: Dictionary) -> void:
    var tier := str(actor["tier"])
    var center: Vector2 = target["position"]
    var radius := 2.8 if tier == "boss" else 2.2
    var cast_time := 1.0 if tier == "boss" else 0.75
    pending_casts.append({
        "caster":str(actor["id"]),"center":center,"radius":radius,
        "ready":now+cast_time,"ratio":1.1 if tier == "boss" else 0.85,
        "maximum":MAX_TARGETS_AOE
    })
    actor["next_skill"] = now+(7.5 if tier == "boss" else 8.0)
    _event("telegraph",{"caster":actor["id"],"center":center,"radius":radius,
        "release_at":now+cast_time,"skill":"area_slam"})

func _release_casts() -> void:
    var remaining: Array = []
    for cast_value in pending_casts:
        var cast: Dictionary = cast_value
        if now+0.000001 < float(cast["ready"]):
            remaining.append(cast)
            continue
        var caster: Dictionary = actors.get(str(cast["caster"]),{})
        if caster.is_empty() or float(caster["hp"]) <= 0.0:
            continue
        var selected := _area_targets(str(caster["side"]),cast["center"],float(cast["radius"]),int(cast["maximum"]))
        _event("area_release",{"caster":caster["id"],"target_count":selected.size(),"center":cast["center"]})
        for target in selected:
            _deal_direct(caster,target,float(cast["ratio"]),"area_slam",false)
    pending_casts = remaining

func _area_targets(caster_side: String, center: Vector2, radius: float, limit: int) -> Array:
    var candidates: Array = []
    for actor in actors.values():
        if str(actor["side"]) != caster_side and float(actor["hp"]) > 0.0:
            var ds: float = (actor["position"] as Vector2).distance_squared_to(center)
            if ds <= radius*radius:
                candidates.append({"actor":actor,"distance":ds})
    candidates.sort_custom(func(a,b):
        var delta := float(a["distance"])-float(b["distance"])
        return str(a["actor"]["id"]) < str(b["actor"]["id"]) if absf(delta) < 0.000001 else delta < 0.0
    )
    var selected: Array = []
    for i in range(mini(candidates.size(),limit)):
        selected.append(candidates[i]["actor"])
    return selected

func _enemies_near(center: Dictionary, radius: float) -> int:
    var count := 0
    for actor in actors.values():
        if str(actor["side"]) == "monster" and float(actor["hp"]) > 0.0:
            if (actor["position"] as Vector2).distance_to(center["position"]) <= radius:
                count += 1
    return count

func _actor_casting(actor_id: String) -> bool:
    for cast in pending_casts:
        if str(cast["caster"]) == actor_id:
            return true
    return false

func _count_alive(side: String) -> int:
    var count := 0
    for actor in actors.values():
        if str(actor["side"]) == side and float(actor["hp"]) > 0.0:
            count += 1
    return count

func _sync_linked_hp(actor: Dictionary) -> void:
    var linked = actor.get("linked_disciple",null)
    if linked is DiscipleState:
        linked.hp = float(actor["hp"])

func _keep_inside(position: Vector2) -> Vector2:
    return Vector2(clampf(position.x,0.0,36.0),clampf(position.y,0.0,20.0))

func _event(kind: String, payload: Dictionary) -> void:
    if events.size() >= MAX_EVENTS:
        return
    var row := {"type":kind,"time":now,"encounter_id":encounter_id}
    row.merge(payload)
    events.append(row)
