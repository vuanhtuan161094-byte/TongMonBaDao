class_name HuntingExpeditionEntryV2
extends RefCounted

# Single-entry adapter for the existing HuntingPveRunV2 authority.
# No fake actor levels, no scheduler, save schema or combat RNG ownership.
# All turn progression, rewards and injury remain with HuntingPveRunV2.
static func eligible_roster(state: SimulationState) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    if state == null:
        return result
    var ids: Array = state.disciples.keys()
    ids.sort()
    var buildings := BuildingSystem.new()
    for raw in ids:
        var disciple: DiscipleState = state.disciples[raw]
        if disciple == null:
            continue
        if disciple.hp <= 0.0 or disciple.injury_level != 0:
            continue
        if disciple.region_id != &"sect" or not (disciple.current_action in [
            &"EVALUATE", &"IDLE", &"HOLD"
        ]):
            continue
        if not disciple.active_pve_encounter_id.is_empty() or not disciple.work_cycle_state.is_empty():
            continue
        if buildings.disciple_has_active_spirit_plot(state,disciple.id) or \
                buildings.disciple_has_active_timed_recipe(state,disciple.id) or \
                DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,disciple):
            continue
        if not DiscipleRealmProgressV2.progression_ready(disciple):
            # Legacy/non-V2 disciples may need a separately authorized
            # migration, never infer cultivation from legacy combat_power.
            continue
        var track: Dictionary = disciple.v2_realm_progress
        var tuvi: Dictionary = track["cultivation"]
        var body: Dictionary = track["body"]
        result.append({
            "id":str(disciple.id),
            "name":disciple.display_name,
            "realm":int(tuvi["realm"]),"floor":int(tuvi["floor"]),
            "body_realm":int(body["realm"]),"body_floor":int(body["floor"])
        })
    return result

static func build_party(state: SimulationState, selected_ids: Array) -> Dictionary:
    if state == null or selected_ids.is_empty() or selected_ids.size() > MapBattleV2.MAX_DISCIPLES:
        return {"ok":false,"reason":"invalid_hunt_party_size"}
    var roster: Dictionary = {}
    for row in eligible_roster(state):
        roster[str(row["id"])] = row
    var unique: Dictionary = {}
    var party: Array = []
    for raw in selected_ids:
        var id := str(raw)
        if id.is_empty() or unique.has(id) or not roster.has(id):
            return {"ok":false,"reason":"invalid_or_unavailable_hunt_member"}
        unique[id] = true
        var record: Dictionary = roster[id]
        var i := party.size()
        var role := ["frontline","ranged","mage","healer"][i%4]
        party.append({
            "disciple_id":id,
            "realm":int(record["realm"]),"floor":int(record["floor"]),
            "body_realm":int(record["body_realm"]),"body_floor":int(record["body_floor"]),
            "role":role,"party_id":"hunting_%02d" % int(i/6),
            "position":Vector2(5.0+float(i%6)*0.9,5.0+float(i/6)*1.2)
        })
    return {"ok":true,"party":party}

static func display_metadata(state: SimulationState, run: HuntingPveRunV2) -> Dictionary:
    var rows: Dictionary = {}
    if state == null or run == null or run.battle == null:
        return rows
    for raw in run.battle.actors.keys():
        var id := str(raw)
        var actor: Dictionary = run.battle.actors[raw]
        if str(actor.get("side","")) == "disciple":
            if not state.disciples.has(StringName(id)):
                continue
            var living: DiscipleState = state.disciples[StringName(id)]
            if not DiscipleRealmProgressV2.valid_profile(living.v2_realm_progress):
                continue
            var tuvi: Dictionary = living.v2_realm_progress["cultivation"]
            var body: Dictionary = living.v2_realm_progress["body"]
            rows[id] = {"display_name":living.display_name,
                "realm_index":int(tuvi["realm"]),"floor_index":int(tuvi["floor"]),
                "body_realm_index":int(body["realm"]),"body_floor_index":int(body["floor"])}
        else:
            for m in run.spawn_data.get("monsters",[]):
                if str(m.get("id","")) == id:
                    rows[id] = {"realm_index":int(m.get("realm_index",0)),
                        "floor_index":int(m.get("floor_index",0))}
                    break
    return rows

static func next_encounter_id(state: SimulationState) -> String:
    # Distinct player-issued encounters, no gameplay RNG consumption.
    # Scan all canonical journals, never reuse a completed reward ID.
    var base := "hunt/%d" % state.tick
    var suffix := 0
    while true:
        var candidate := "%s/%d" % [base,suffix]
        if not state.sect.v2_pve_active_runs.has(candidate) and \
                not state.sect.v2_pve_reward_claims.has(candidate) and \
                not state.sect.v2_pve_settlement_receipts.has(candidate):
            return candidate
        suffix += 1
    return ""
