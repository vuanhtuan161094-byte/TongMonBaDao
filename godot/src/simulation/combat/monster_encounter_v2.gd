class_name MonsterEncounterV2
extends RefCounted

# DV2-02 pilot action adapter: real monster HP + real DiscipleState HP, exactly
# once per encounter hit ID. No legacy PvE routing/rewards are modified.
static func player_hit(
    attacker: DiscipleState, attacker_stats: Dictionary, monster: Dictionary,
    context_sources: Array, rng: GameRng, hit_id: String,
    attack_kind: String = "basic", skill_ratio: float = 1.0,
    can_crit: bool = true
) -> Dictionary:
    if attacker == null or hit_id.is_empty() or not bool(monster.get("ok",false)):
        return {"ok":false,"reason":"invalid_actor_or_hit"}
    if not ["basic","skill"].has(attack_kind) or skill_ratio < 0.0:
        return {"ok":false,"reason":"invalid_attack_kind_or_ratio"}
    var seen = monster.get("v2_hit_ids",{})
    if not (seen is Dictionary) or seen.has(hit_id):
        return {"ok":false,"reason":"duplicate_or_invalid_hit"}
    if float(monster.get("hp",0.0)) <= 0.0:
        return {"ok":false,"reason":"monster_already_defeated"}
    var target_stats: Dictionary = monster.get("stats",{})
    var resistances: Dictionary = monster.get("resistances",{})
    if target_stats.is_empty():
        return {"ok":false,"reason":"missing_monster_stats"}
    var contextual := CombatContextEffectsV2.resolve_context(
        context_sources,monster,attack_kind
    )
    if not bool(contextual.get("ok",false)):
        return contextual
    var crit := can_crit and rng.chance(CombatStatsV2.effective_crit_chance(attacker_stats,target_stats))
    var primary := CombatStatsV2.resolve_direct_hit(
        attacker_stats,target_stats,resistances,
        skill_ratio*float(contextual["outgoing_damage_factor"]),
        crit,str(monster.get("element","")),1.0,can_crit
    )
    if not bool(primary.get("ok",false)):
        return primary
    var settled := CombatStatsV2.settle_damage_and_lifesteal(
        primary,attacker_stats,target_stats,
        attacker.hp,attacker.max_hp,float(monster["hp"]),true
    )
    if not bool(settled.get("ok",false)):
        return settled
    var second_damage := 0.0
    var hp_after_primary := float(settled["target_hp_after"])
    var followed := CombatContextEffectsV2.roll_basic_followup(
        rng,contextual,attack_kind,hp_after_primary
    )
    if followed:
        # The bonus basic hit is not eligible for another followup, crit or
        # lifesteal. It cannot trigger other skill/proc events in this pilot.
        var extra := CombatStatsV2.resolve_direct_hit(
            attacker_stats,target_stats,resistances,
            skill_ratio*float(contextual["outgoing_damage_factor"])*float(contextual["basic_followup_ratio"]),
            false,str(monster.get("element","")),1.0,false
        )
        if not bool(extra.get("ok",false)):
            return extra
        second_damage = minf(float(extra["damage"]),hp_after_primary)
    var total_damage := float(settled["actual_damage"])+second_damage
    monster["hp"] = maxf(0.0,hp_after_primary-second_damage)
    attacker.hp = float(settled["attacker_hp_after"])
    seen[hit_id] = true
    monster["v2_hit_ids"] = seen
    return {
        "ok":true,"hit_id":hit_id,"kind":attack_kind,
        "target_tier":str(monster["tier"]),"target_race":str(monster["race_id"]),
        "outgoing_factor":float(contextual["outgoing_damage_factor"]),
        "primary_damage":float(settled["actual_damage"]),
        "extra_basic_damage":second_damage,"followup":followed,
        "actual_damage":total_damage,"lifesteal_heal":float(settled["lifesteal_heal"]),
        "attacker_hp_after":attacker.hp,"monster_hp_after":float(monster["hp"])
    }

static func monster_basic_hit(
    monster: Dictionary, target: DiscipleState, target_stats: Dictionary,
    hit_id: String
) -> Dictionary:
    if target == null or hit_id.is_empty() or not bool(monster.get("ok",false)):
        return {"ok":false,"reason":"invalid_monster_or_target"}
    var seen = monster.get("v2_hit_ids",{})
    if not (seen is Dictionary) or seen.has(hit_id):
        return {"ok":false,"reason":"duplicate_or_invalid_hit"}
    if float(monster.get("hp",0.0)) <= 0.0:
        return {"ok":false,"reason":"defeated_monster_cannot_attack"}
    var attack_stats: Dictionary = monster.get("stats",{})
    if attack_stats.is_empty():
        return {"ok":false,"reason":"missing_monster_stats"}
    # A plain monster basic hit is not automatically crit/elemental skill.
    # Later authored monster skills use the same direct-hit primitive.
    var hit := CombatStatsV2.resolve_direct_hit(
        attack_stats,target_stats,{},1.0,false,"",1.0,false
    )
    if not bool(hit.get("ok",false)):
        return hit
    var actual_damage := minf(maxf(0.0,float(hit.get("damage",0.0))),maxf(0.0,target.hp))
    target.hp = maxf(0.0,target.hp-actual_damage)
    seen[hit_id] = true
    monster["v2_hit_ids"] = seen
    return {"ok":true,"hit_id":hit_id,"actual_damage":actual_damage,"target_hp_after":target.hp}
