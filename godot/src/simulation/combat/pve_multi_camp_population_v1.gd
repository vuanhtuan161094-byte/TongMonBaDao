class_name PveMultiCampPopulationV1
extends RefCounted

# PVE-FOUNDATION / NOT YET B3-COMBAT CONNECTED.
# Deterministic 20-camp *spawn-slot registry* for Thanh Truc Lam.
# This class tracks no HP, DPS, pathfinding, kill rewards, disciples or ticks.
# In particular, 300 slots here DO NOT mean 300 active MapBattleV2 actors.
# Any hp0 must come from a real trusted combat event before record_hp0().
# Receipt acknowledgement must occur only AFTER canonical Warehouse+Save
# settlement by a future B3 multi-camp adapter; no currencies are minted here.
const VERSION := 1
const ZONE := "thanh_truc_lam"
const WORLD_SIZE := Vector2(256.0,192.0)
const COLUMNS := [28.0,76.0,124.0,172.0,220.0]
const ROWS := [24.0,64.0,104.0,144.0]
const CAMP_COUNT := 20
const MIN_SLOTS_PER_CAMP := 10
const MAX_SLOTS_PER_CAMP := 20
const BRIDGE_ROWS := [0,2,3]
const UNBRIDGED_ROW := 1

static func camp_index(column: int, row: int) -> int:
    return row*5+column

static func camp_id(index: int) -> String:
    return "C%02d" % (index+1)

static func camp_position(index: int) -> Vector2:
    if index < 0 or index >= CAMP_COUNT:
        return Vector2(-1.0,-1.0)
    return Vector2(COLUMNS[index%5],ROWS[index/5])

static func slot_id(camp: int, ordinal: int) -> String:
    return "%s:S%02d" % [camp_id(camp),ordinal+1]

static func slot_position(camp: int, ordinal: int) -> Vector2:
    # Up to 20 locations per camp, in five columns and four rows.
    var middle := camp_position(camp)
    return middle+Vector2(float(ordinal%5-2)*3.2,float(int(ordinal/5)-1.5)*3.0)

static func road_edges() -> Array[Vector2i]:
    var edges: Array[Vector2i] = []
    for row in range(4):
        for col in range(5):
            var node := camp_index(col,row)
            if col < 4 and not (col == 2 and row == UNBRIDGED_ROW):
                edges.append(Vector2i(node,node+1))
            if row < 3:
                edges.append(Vector2i(node,node+5))
    return edges

static func graph_connected() -> bool:
    var seen := {0:true}
    var queue: Array[int] = [0]
    var edges := road_edges()
    while not queue.is_empty():
        var node := queue.pop_front()
        for edge in edges:
            var next_id := -1
            if edge.x == node:
                next_id = edge.y
            elif edge.y == node:
                next_id = edge.x
            if next_id >= 0 and not seen.has(next_id):
                seen[next_id] = true
                queue.append(next_id)
    return seen.size() == CAMP_COUNT

static func new_registry(slots_per_camp: int) -> Dictionary:
    if slots_per_camp < MIN_SLOTS_PER_CAMP or slots_per_camp > MAX_SLOTS_PER_CAMP:
        return {"ok":false,"reason":"camp_population_out_of_range"}
    var slots: Dictionary = {}
    var camps: Array = []
    for camp in range(CAMP_COUNT):
        var point := camp_position(camp)
        camps.append({"id":camp_id(camp),"x":point.x,"y":point.y,
            "slot_count":slots_per_camp})
        for i in range(slots_per_camp):
            var id := slot_id(camp,i)
            var at := slot_position(camp,i)
            if not Rect2(Vector2.ZERO,WORLD_SIZE).has_point(at) or slots.has(id):
                return {"ok":false,"reason":"invalid_spawn_slot_geometry"}
            slots[id] = {
                "id":id,"camp_id":camp_id(camp),"x":at.x,"y":at.y,
                "generation":1,"phase":"READY","due_at":0.0,
                "kill_id":"","receipt_acknowledged":false
            }
    return {"ok":true,"version":VERSION,"zone":ZONE,"slots_per_camp":slots_per_camp,
        "camps":camps,"slots":slots,"last_seconds":0.0}

# Forward-compatible read-only bridge to REAL MapBattleV2 HP0 event.
# The original domain journal and monster actor must both corroborate the
# kill. This function STILL DOES NOT GRANT LOOT or mutate SaveService.
static func record_authoritative_battle_kill(registry: Dictionary,
        battle: MapBattleV2, event: Dictionary, respawn_delay_seconds: float) -> Dictionary:
    if battle == null or not battle.continuous_mode or battle.encounter_id.is_empty():
        return {"ok":false,"reason":"not_an_active_continuous_battle"}
    var event_id := str(event.get("kill_id",""))
    var actor_id := str(event.get("monster_instance_id",""))
    var slot_id_value := str(event.get("spawn_slot_id",""))
    var generation := int(event.get("slot_generation",0))
    var expected_event_id := "%s:slot:%s:g%d" % [battle.encounter_id,slot_id_value,generation]
    if event_id.is_empty() or event_id != expected_event_id or str(event.get("world_id","")) != battle.encounter_id:
        return {"ok":false,"reason":"event_not_from_this_world"}
    var official_event: Dictionary = {}
    for pending in battle.pending_kill_events():
        if str(pending.get("kill_id","")) == event_id and str(pending.get("monster_instance_id","")) == actor_id and str(pending.get("spawn_slot_id","")) == slot_id_value and int(pending.get("slot_generation",0)) == generation:
            official_event = pending
            break
    if official_event.is_empty() or not battle.actors.has(actor_id):
        return {"ok":false,"reason":"kill_not_in_authoritative_journal"}
    var actor: Dictionary = battle.actors[actor_id]
    if str(actor.get("side","")) != "monster" or float(actor.get("hp",1.0)) != 0.0:
        return {"ok":false,"reason":"monster_not_dead_in_combat"}
    if str(actor.get("spawn_slot_id","")) != slot_id_value or int(actor.get("slot_generation",0)) != generation:
        return {"ok":false,"reason":"monster_slot_generation_mismatch"}
    if str(actor.get("species_id","")) != str(official_event.get("species_id","")):
        return {"ok":false,"reason":"monster_species_mismatch"}
    # Never trust caller-supplied death time for cooldown or world ordering.
    # The only accepted timestamp comes from the combat kernel's own journal.
    return record_hp0(registry,slot_id_value,generation,event_id,true,
        float(official_event.get("at_seconds",-1.0)),respawn_delay_seconds)


static func record_hp0(registry: Dictionary, id: String, generation: int,
        kill_id: String, verified_hp0: bool, at_seconds: float,
        respawn_delay_seconds: float) -> Dictionary:
    # No mutation unless the exact current life has been proved dead by a
    # separate authoritative battle. Deliberately never add loot here.
    if not bool(registry.get("ok",false)) or not verified_hp0 or kill_id.is_empty() or not is_finite(at_seconds) or not is_finite(respawn_delay_seconds) or respawn_delay_seconds <= 0.0:
        return {"ok":false,"reason":"missing_authoritative_hp0_or_bad_time"}
    var slots: Dictionary = registry.get("slots",{})
    if not slots.has(id):
        return {"ok":false,"reason":"unknown_spawn_slot"}
    var slot: Dictionary = slots[id]
    if str(slot.get("phase","")) != "READY" or int(slot.get("generation",0)) != generation:
        return {"ok":false,"reason":"slot_generation_not_current"}
    if at_seconds < float(registry.get("last_seconds",0.0)):
        return {"ok":false,"reason":"death_time_regressed"}
    slot["phase"] = "UNPAID_HP0"
    slot["kill_id"] = kill_id
    slot["due_at"] = at_seconds+respawn_delay_seconds
    slot["receipt_acknowledged"] = false
    registry["last_seconds"] = at_seconds
    return {"ok":true,"pending_kill":{"kill_id":kill_id,"slot_id":id,
        "generation":generation,"camp_id":str(slot["camp_id"]),
        "at_seconds":at_seconds},"rewards_granted":false}

static func acknowledge_paid_receipt(registry: Dictionary, id: String,
        kill_id: String) -> Dictionary:
    # A later B3 adapter may call this ONLY after the original kill event,
    # exact-once Warehouse settlement and complete SaveService barrier.
    # It is NOT a settlement function and cannot grant resources.
    var slots: Dictionary = registry.get("slots",{})
    if not slots.has(id):
        return {"ok":false,"reason":"unknown_spawn_slot"}
    var slot: Dictionary = slots[id]
    if str(slot.get("phase","")) != "UNPAID_HP0" or str(slot.get("kill_id","")) != kill_id:
        return {"ok":false,"reason":"not_pending_this_life"}
    slot["receipt_acknowledged"] = true
    slot["phase"] = "COOLDOWN"
    return {"ok":true,"rewards_granted":false}

static func advance_respawns(registry: Dictionary, world_seconds: float) -> Dictionary:
    if not bool(registry.get("ok",false)) or not is_finite(world_seconds) or world_seconds < float(registry.get("last_seconds",0.0)):
        return {"ok":false,"reason":"world_clock_regression"}
    var count := 0
    var slots: Dictionary = registry["slots"]
    for id in slots.keys():
        var slot: Dictionary = slots[id]
        if str(slot["phase"]) != "COOLDOWN" or not bool(slot["receipt_acknowledged"]):
            continue
        if world_seconds < float(slot["due_at"]):
            continue
        slot["generation"] = int(slot["generation"])+1
        slot["phase"] = "READY"
        slot["due_at"] = 0.0
        slot["kill_id"] = ""
        slot["receipt_acknowledged"] = false
        count += 1
    registry["last_seconds"] = world_seconds
    return {"ok":true,"respawned":count,"rewards_granted":false}

static func verify_structure(registry: Dictionary) -> String:
    if not bool(registry.get("ok",false)) or int(registry.get("version",0)) != VERSION or str(registry.get("zone","")) != ZONE:
        return "invalid_registry_header"
    var per_camp := int(registry.get("slots_per_camp",0))
    var slots: Dictionary = registry.get("slots",{})
    var camps: Array = registry.get("camps",[])
    if per_camp < MIN_SLOTS_PER_CAMP or per_camp > MAX_SLOTS_PER_CAMP or camps.size() != CAMP_COUNT or slots.size() != per_camp*CAMP_COUNT:
        return "invalid_population_count"
    for camp in range(CAMP_COUNT):
        var row: Dictionary = camps[camp]
        if str(row.get("id","")) != camp_id(camp):
            return "invalid_camp_id"
        for i in range(per_camp):
            var id := slot_id(camp,i)
            if not slots.has(id):
                return "missing_slot"
            var slot: Dictionary = slots[id]
            var point := slot_position(camp,i)
            if str(slot.get("camp_id","")) != camp_id(camp) or not is_equal_approx(float(slot.get("x",-1)),point.x) or not is_equal_approx(float(slot.get("y",-1)),point.y):
                return "invalid_slot_coordinate"
            if int(slot.get("generation",0)) < 1 or not ["READY","UNPAID_HP0","COOLDOWN"].has(str(slot.get("phase",""))):
                return "invalid_life_cycle"
            if str(slot["phase"]) == "READY" and (not str(slot["kill_id"]).is_empty() or bool(slot["receipt_acknowledged"])):
                return "ready_slot_holds_stale_kill"
    return ""
