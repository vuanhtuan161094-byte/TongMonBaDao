class_name JxPilotRuntimeV1
extends RefCounted

# Event consumers for explicitly equipped pilot skills only.
# Source JX ID is provenance, not a game stat or an implicit learned skill.
static func heal_target(battle: Variant, caster: Dictionary, radius: float) -> Dictionary:
    var keys: Array = battle.actors.keys()
    keys.sort()
    var selected: Dictionary = {}
    var lowest := 0.70
    for key in keys:
        var other: Dictionary = battle.actors[key]
        if str(other.get("side","")) != "disciple" or str(other.get("party_id","")) != str(caster["party_id"]):
            continue
        if float(other.get("hp",0.0)) <= 0.0 or (other["position"] as Vector2).distance_to(caster["position"]) > radius:
            continue
        var fraction := float(other["hp"])/maxf(1.0,float(other["max_hp"]))
        if fraction >= lowest:
            continue
        var already_hot := false
        for fx in other.get("pilot_effects",[]):
            if str(fx.get("kind","")) == "hot":
                already_hot = true
                break
        if already_hot:
            continue
        selected = other
        lowest = fraction
    return selected

static func try_cast(battle: Variant, caster: Dictionary, target: Dictionary) -> bool:
    if str(caster.get("side","")) != "disciple":
        return false
    var loadout: Array = caster.get("pilot_loadout",[])
    var ready: Dictionary = caster.get("pilot_ready",{})
    var distance := (caster["position"] as Vector2).distance_to(target["position"])
    for value in loadout:
        var sid := str(value)
        var skill: Dictionary = JxPilotSkillsV1.definition(sid)
        if skill.is_empty() or battle.now+0.000001 < float(ready.get(sid,0.0)):
            continue
        var kind := str(skill["effect"])
        var victim: Dictionary = target
        if kind == "guard":
            if float(caster["hp"])/maxf(1.0,float(caster["max_hp"])) >= 0.70:
                continue
            victim = caster
        elif kind == "party_defense":
            var count := 0
            for ally in battle.actors.values():
                if str(ally.get("side","")) == "disciple" and str(ally.get("party_id","")) == str(caster["party_id"]) and float(ally.get("hp",0.0)) > 0.0:
                    if (ally["position"] as Vector2).distance_to(caster["position"]) <= float(skill["range"]) and battle.now >= float(ally.get("pilot_def_until",-1.0)):
                        count += 1
            if count < 2:
                continue
            victim = caster
        elif kind == "heal_over_time":
            victim = heal_target(battle,caster,float(skill["range"]))
            if victim.is_empty():
                continue
        elif distance > float(skill.get("range",0.0)):
            continue
        var travel_ticks := 0
        if kind == "projectile" or kind == "poison_hit":
            travel_ticks = int(ceil(distance/(float(skill.get("speed",8.0))*MapBattleV2.STEP_SECONDS)))
        var release_time := battle.now + float(int(skill["cast_ticks"])+travel_ticks)*MapBattleV2.STEP_SECONDS
        battle.pending_casts.append({
            "caster":str(caster["id"]),"target_id":str(victim["id"]),
            "pilot_id":sid,"ready":release_time
        })
        ready[sid] = battle.now+float(int(skill["cd_ticks"]))*MapBattleV2.STEP_SECONDS
        caster["pilot_ready"] = ready
        battle._event("pilot_cast",{"caster":caster["id"],"target":victim["id"],
            "pilot_id":sid,"release_at":release_time})
        battle.actions += 1
        return true
    return false

static func release(battle: Variant, caster: Dictionary, cast: Dictionary) -> void:
    var sid := str(cast.get("pilot_id",""))
    var skill: Dictionary = JxPilotSkillsV1.definition(sid)
    if skill.is_empty():
        return
    var target: Dictionary = battle.actors.get(str(cast.get("target_id","")),{})
    if target.is_empty() or float(target.get("hp",0.0)) <= 0.0:
        return
    var kind := str(skill["effect"])
    var element := str(skill["element"])
    var multiplier := JxPilotSkillsV1.matching_root_multiplier(caster.get("pilot_roots",{}),element)
    if kind == "guard":
        caster["pilot_guard_until"] = battle.now + float(int(skill["duration_ticks"]))*MapBattleV2.STEP_SECONDS
        battle._event("pilot_guard",{"caster":caster["id"],"until":caster["pilot_guard_until"],"pilot_id":sid})
        return
    if kind == "party_defense":
        var keys: Array = battle.actors.keys()
        keys.sort()
        var affected := 0
        for key in keys:
            var ally: Dictionary = battle.actors[key]
            if str(ally.get("side","")) == "disciple" and str(ally.get("party_id","")) == str(caster["party_id"]) and float(ally.get("hp",0.0)) > 0.0:
                if (ally["position"] as Vector2).distance_to(caster["position"]) <= float(skill["range"]):
                    ally["pilot_def_until"] = maxf(float(ally.get("pilot_def_until",-1.0)),
                        battle.now+float(int(skill["duration_ticks"]))*MapBattleV2.STEP_SECONDS)
                    affected += 1
        battle._event("pilot_party_defense",{"caster":caster["id"],"members":affected,"pilot_id":sid})
        return
    if kind == "heal_over_time":
        if str(target["side"]) != "disciple" or str(target["party_id"]) != str(caster["party_id"]):
            return
        if (target["position"] as Vector2).distance_to(caster["position"]) > float(skill["range"]):
            return
        for fx in target.get("pilot_effects",[]):
            if str(fx.get("kind","")) == "hot":
                return
        var effects: Array = target.get("pilot_effects",[])
        effects.append({"kind":"hot","caster":str(caster["id"]),"pilot_id":sid,
            "per_tick":float(caster["stats"]["attack"])*0.40*multiplier,
            "ticks_left":3,"next_tick":battle.now+1.0})
        target["pilot_effects"] = effects
        battle._event("pilot_hot_applied",{"caster":caster["id"],"target":target["id"],"pilot_id":sid})
        return
    if str(target["side"]) != "monster":
        return
    var matchup := JxPilotSkillsV1.elemental_matchup(element,str(target.get("primary_element","")))
    var damage := battle._deal_direct(caster,target,float(skill.get("ratio",0.0))*multiplier,
        "pilot_skill",true,element,matchup)
    battle._event("pilot_impact",{"caster":caster["id"],"target":target["id"],
        "pilot_id":sid,"effective_damage":damage})
    if kind != "poison_hit" or damage <= 0.0 or float(target["hp"]) <= 0.0:
        return
    var chance := CombatStatsV2.ordinary_status_chance(0.85,caster["stats"],target["stats"])
    if not battle.rng.chance(chance):
        return
    var statuses: Array = target.get("pilot_effects",[])
    var same := -1
    var stacks := 0
    for i in range(statuses.size()):
        var fx: Dictionary = statuses[i]
        if str(fx.get("kind","")) != "poison":
            continue
        stacks += 1
        if str(fx.get("caster","")) == str(caster["id"]) and str(fx.get("pilot_id","")) == sid:
            same = i
    var poison := {"kind":"poison","caster":str(caster["id"]),"pilot_id":sid,
        "attack_snapshot":float(caster["stats"]["attack"]),"root_scale":multiplier,
        "matchup":matchup,"ticks_left":3,"next_tick":battle.now+1.0}
    if same >= 0:
        statuses[same] = poison
    elif stacks < 3:
        statuses.append(poison)
    else:
        return
    target["pilot_effects"] = statuses
    battle._event("pilot_poison_applied",{"caster":caster["id"],"target":target["id"],"pilot_id":sid,"stacks":stacks if same >= 0 else stacks+1})

static func tick(battle: Variant) -> void:
    var keys: Array = battle.actors.keys()
    keys.sort()
    for key in keys:
        var target: Dictionary = battle.actors[key]
        var statuses: Array = target.get("pilot_effects",[])
        if statuses.is_empty():
            continue
        if float(target["hp"]) <= 0.0:
            target["pilot_effects"] = []
            continue
        var keep: Array = []
        for entry in statuses:
            var fx: Dictionary = entry
            if battle.now+0.000001 >= float(fx.get("next_tick",INF)):
                var kind := str(fx.get("kind",""))
                if kind == "hot":
                    var amount := minf(float(fx.get("per_tick",0.0)),
                        maxf(0.0,float(target["max_hp"])-float(target["hp"])))
                    target["hp"] = float(target["hp"])+amount
                    battle._sync_linked_hp(target)
                    battle._event("pilot_hot_tick",{"caster":fx["caster"],"target":target["id"],"amount":amount})
                elif kind == "poison":
                    var caster: Dictionary = battle.actors.get(str(fx.get("caster","")),{})
                    if not caster.is_empty():
                        var source_stats: Dictionary = caster["stats"].duplicate(true)
                        source_stats["attack"] = float(fx.get("attack_snapshot",0.0))
                        var hit := CombatStatsV2.resolve_direct_hit(
                            source_stats,target["stats"],target["resistances"],
                            0.12*float(fx.get("root_scale",1.0)),false,
                            "wood",float(fx.get("matchup",1.0)),false)
                        if bool(hit.get("ok",false)):
                            var damage := minf(float(target["hp"]),float(hit["damage"]))
                            target["hp"] = float(target["hp"])-damage
                            battle._sync_linked_hp(target)
                            battle._event("pilot_poison_tick",{"caster":fx["caster"],
                                "target":target["id"],"damage":damage})
                            if float(target["hp"]) <= 0.0:
                                battle._event("downed",{"actor_id":target["id"],"side":target["side"]})
                fx["ticks_left"] = int(fx.get("ticks_left",0))-1
                fx["next_tick"] = float(fx["next_tick"])+1.0
            if int(fx.get("ticks_left",0)) > 0 and float(target["hp"]) > 0.0:
                keep.append(fx)
        target["pilot_effects"] = keep
