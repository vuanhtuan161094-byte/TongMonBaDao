class_name PvePerKillRewardV1
extends RefCounted

# PVE-P0 authored PILOT values, not final economic balance. Real Source A
# HP=0 kill IDs are the only trigger. No generic rewards on map-clear/retreat.
# All material IDs already exist in ResourceRegistry. 0 drops is a valid roll.
# Persistent ledger is bounded at ONE latest life receipt per spawn slot.

const VERSION := 1
const TU_VI_XP_PER_NORMAL_KILL := 75.0
const BODY_XP_PER_NORMAL_KILL := 25.0
const TEAM_SHARE_RATIO := 0.40
const TEAM_SHARE_RANGE := 12.0

const DROP_TABLES := {
    "truc_thu":[
        {"id":"linh_moc","chance":0.25,"amount":1},
        {"id":"thanh_linh_thao","chance":0.05,"amount":1}
    ],
    "thanh_lang":[
        {"id":"tinh_lang_bi","chance":0.35,"amount":1},
        {"id":"yeu_dan","chance":0.03,"amount":1}
    ],
    "hac_lang":[
        {"id":"tinh_lang_bi","chance":0.30,"amount":1},
        {"id":"yeu_dan","chance":0.08,"amount":1}
    ]
}

static func preview(state: SimulationState,battle: MapBattleV2,
        event: Dictionary,world_seed: int) -> Dictionary:
    if state == null or battle == null or not battle.world_mode:
        return {"ok":false,"reason":"p0_kill_reward_requires_canonical_world"}
    var kill_id := str(event.get("kill_id",""))
    var species := str(event.get("species_id",""))
    var slot_id := str(event.get("spawn_slot_id",""))
    var killer_id := str(event.get("killer_actor_id",""))
    var corpse_id := str(event.get("monster_instance_id",""))
    var killer: Dictionary = battle.actors.get(killer_id,{})
    var corpse: Dictionary = battle.actors.get(corpse_id,{})
    if kill_id.is_empty() or slot_id.is_empty() or killer_id.is_empty() \
            or not kill_id.begins_with(battle.encounter_id+":slot:") \
            or str(killer.get("side","")) != "disciple" \
            or str(corpse.get("side","")) != "monster" \
            or str(corpse.get("spawn_slot_id","")) != slot_id \
            or str(corpse.get("species_id","")) != species \
            or float(corpse.get("hp",1.0)) != 0.0 \
            or not state.disciples.has(StringName(killer_id)):
        return {"ok":false,"reason":"p0_reward_not_authoritative_hp0"}
    if not MonsterCatalogueV2.SPECIES.has(species):
        return {"ok":false,"reason":"p0_unknown_reward_species"}
    var items: Dictionary = {}
    if bool(MonsterCatalogueV2.SPECIES[species].get("loot_ready",false)):
        var rng := GameRng.new(world_seed ^ int(hash(kill_id)))
        var registry := ResourceRegistry.new()
        for row in DROP_TABLES.get(species,[]):
            var item := str(row.get("id",""))
            var chance := float(row.get("chance",-1.0))
            var amount := int(row.get("amount",0))
            if not registry.has(StringName(item)) or chance < 0.0 \
                    or chance > 1.0 or amount < 1:
                return {"ok":false,"reason":"p0_unregistered_or_invalid_drop"}
            if rng.chance(chance):
                items[item] = int(items.get(item,0))+amount
    var actor_xp: Dictionary = {}
    var party_id := str(killer.get("party_id",""))
    var target_position: Vector2 = corpse.get("position",Vector2.ZERO)
    actor_xp[killer_id] = {
        "cultivation":TU_VI_XP_PER_NORMAL_KILL,
        "body":BODY_XP_PER_NORMAL_KILL
    }
    # Optional teams share only with living members of THE SAME party ID
    # physically near this kill. Solo actors never create a global team aura.
    if not party_id.is_empty():
        var ids: Array = battle.actors.keys()
        ids.sort()
        for raw_id in ids:
            var actor: Dictionary = battle.actors[raw_id]
            var id := str(raw_id)
            if id == killer_id or str(actor.get("side","")) != "disciple" \
                    or str(actor.get("party_id","")) != party_id \
                    or float(actor.get("hp",0.0)) <= 0.0 \
                    or not state.disciples.has(StringName(id)):
                continue
            var at: Vector2 = actor.get("position",Vector2.ZERO)
            if at.distance_to(target_position) > TEAM_SHARE_RANGE:
                continue
            actor_xp[id] = {
                "cultivation":TU_VI_XP_PER_NORMAL_KILL*TEAM_SHARE_RATIO,
                "body":BODY_XP_PER_NORMAL_KILL*TEAM_SHARE_RATIO
            }
    return {"ok":true,"kill_id":kill_id,"slot_id":slot_id,
        "generation":int(event.get("slot_generation",0)),"species":species,
        "killer_actor_id":killer_id,"items":items,"actor_xp":actor_xp,
        "has_drop":not items.is_empty()}

static func commit(state: SimulationState,battle: MapBattleV2,
        population: Dictionary,event: Dictionary,world_seed: int) -> Dictionary:
    if state == null or battle == null or not bool(population.get("p0_distributed_world",false)):
        return {"ok":false,"reason":"p0_reward_not_enabled"}
    var plan := preview(state,battle,event,world_seed)
    if not bool(plan.get("ok",false)):
        return plan
    var slot_id := str(plan["slot_id"])
    var kill_id := str(plan["kill_id"])
    var generation := int(plan["generation"])
    var slot: Dictionary = population.get("slots",{}).get(slot_id,{})
    if slot.is_empty() or int(slot.get("generation",0)) != generation \
            or str(slot.get("kill_id","")) != kill_id \
            or not ["UNPAID_HP0","COOLDOWN"].has(str(slot.get("phase",""))):
        return {"ok":false,"reason":"p0_kill_slot_generation_not_pending"}
    var ledger: Dictionary = population.get("p0_kill_rewards",{})
    var earlier: Dictionary = ledger.get(slot_id,{})
    if not earlier.is_empty():
        if str(earlier.get("kill_id","")) == kill_id:
            return {"ok":true,"duplicate":true,"receipt":earlier.duplicate(true),
                "items":earlier.get("items",{}),"actor_xp":earlier.get("actor_xp",{})}
        if int(earlier.get("generation",0)) >= generation:
            return {"ok":false,"reason":"p0_duplicate_or_rewound_slot_life"}

    var warehouse := WarehouseSystem.new()
    if not state.sect.p3_7_resources_enabled:
        return {"ok":false,"reason":"p0_warehouse_authority_disabled"}
    var items: Dictionary = plan["items"]
    for raw_item in items.keys():
        var item := StringName(str(raw_item))
        var amount := int(items[raw_item])
        if not warehouse.registry.has(item) or amount <= 0 \
                or amount > warehouse.MAX_SAFE_STACK-warehouse.quantity(state,item):
            return {"ok":false,"reason":"p0_warehouse_capacity_backpressure","barrier":true}
    var xp: Dictionary = plan["actor_xp"]
    var ids: Array = xp.keys()
    ids.sort()
    var costs := DiscipleProgressionBalanceV2.floor_costs()
    var before_disciples: Dictionary = {}
    for raw_id in ids:
        var id := StringName(str(raw_id))
        var disciple: DiscipleState = state.disciples.get(id,null)
        if disciple == null or not DiscipleRealmProgressV2.progression_ready(disciple):
            return {"ok":false,"reason":"p0_kill_xp_not_eligible"}
        var award: Dictionary = xp[raw_id]
        for track in ["cultivation","body"]:
            var check := DiscipleRealmProgressV2.grant_xp(
                disciple,track,float(award[track]),"natural",costs,[],true)
            if not bool(check.get("ok",false)):
                return {"ok":false,"reason":"p0_canonical_xp_preflight_failed",
                    "detail":check.get("reason","unknown")}
        before_disciples[str(id)] = {
            "progress":disciple.v2_realm_progress.duplicate(true),
            "hp":disciple.hp,"max_hp":disciple.max_hp
        }
    # In-memory transaction: restore canonical stock/progression if any
    # operation surprisingly rejects after the pure preflight above.
    var stock_before: Dictionary = state.sect.warehouse_resources.duplicate(true)
    var stock_events_before := state.sect.warehouse_event_count
    var failed := ""
    var item_ids: Array = items.keys()
    item_ids.sort()
    for raw_item in item_ids:
        if not warehouse.add(state,StringName(str(raw_item)),int(items[raw_item])):
            failed = "p0_warehouse_commit_failed"
            break
    if failed.is_empty():
        for raw_id in ids:
            var disciple: DiscipleState = state.disciples[StringName(str(raw_id))]
            var award: Dictionary = xp[raw_id]
            for track in ["cultivation","body"]:
                var granted := DiscipleRealmProgressV2.grant_xp(
                    disciple,track,float(award[track]),"natural",costs)
                if not bool(granted.get("ok",false)):
                    failed = "p0_canonical_xp_commit_failed"
                    break
            if not failed.is_empty():
                break
    if not failed.is_empty():
        state.sect.warehouse_resources = stock_before
        state.sect.warehouse_event_count = stock_events_before
        for raw_id in before_disciples.keys():
            var disciple: DiscipleState = state.disciples[StringName(str(raw_id))]
            var prior: Dictionary = before_disciples[raw_id]
            disciple.v2_realm_progress = prior["progress"]
            disciple.hp = float(prior["hp"])
            disciple.max_hp = float(prior["max_hp"])
        return {"ok":false,"reason":failed,"barrier":true}
    var receipt := {
        "version":VERSION,"kill_id":kill_id,"slot_id":slot_id,
        "generation":generation,"killer_actor_id":str(plan["killer_actor_id"]),
        "species":str(plan["species"]),"items":items.duplicate(true),
        "actor_xp":xp.duplicate(true),"disposition":"DROPPED" if not items.is_empty() else "NO_DROP"
    }
    ledger[slot_id] = receipt
    population["p0_kill_rewards"] = ledger
    return {"ok":true,"duplicate":false,"receipt":receipt,
        "items":items,"actor_xp":xp}
