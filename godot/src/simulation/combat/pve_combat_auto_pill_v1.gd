class_name PveCombatAutoPillV1
extends RefCounted

# PVE-CARE03: the SAME canonical B3 daily pill meter, Warehouse and medicine
# catalogue as in-sect usage. Combat actors own battle HP; no P0 HP overwrite.
# No health service, synthetic potion, reward or secondary Save ledger.
const USE_AT_OR_BELOW_HP_RATIO := 0.80
const COOLDOWN_COMBAT_SECONDS := 5.0
const MIN_USEFUL_MAX_HP_RATIO := 0.02
const ACTOR_NEXT_AT := "pve_care03_next_pill_at"

static func _source_pill(state: SimulationState, d: DiscipleState,
        missing_hp: float) -> Dictionary:
    var realm := int(d.v2_realm_progress.get("cultivation",{}).get("realm",0))
    if realm < 1 or realm > MedicineCatalogueV2.MAX_REALM:
        return {}
    var warehouse := WarehouseSystem.new()
    var selected := &""
    var selected_power := 0.0
    var selected_heal := 0.0
    # Max useful restoration first; at equal effective recovery use the
    # weakest quality, preventing an expensive Q4 from being wasted.
    for quality in range(1, MedicineCatalogueV2.MAX_QUALITY+1):
        var item := MedicineCatalogueV2.item_id(
            MedicineCatalogueV2.FAMILY_HEAL,realm,quality)
        var definition := MedicineCatalogueV2.definition(item)
        if item == &"" or definition.is_empty() or not warehouse.can_consume(state,item,1):
            continue
        var power := float(definition.get("potency",0.0))
        var useful := minf(missing_hp,power)
        if power <= 0.0 or useful < maxf(1.0,d.max_hp*MIN_USEFUL_MAX_HP_RATIO):
            continue
        if useful > selected_heal+0.00001 or (
                is_equal_approx(useful,selected_heal) and power < selected_power):
            selected = item
            selected_power = power
            selected_heal = useful
    if selected == &"":
        return {}
    return {"item":selected,"potency":selected_power,"healed":selected_heal}

static func heal_one(state: SimulationState, battle: MapBattleV2,
        disciple_id: StringName) -> Dictionary:
    if state == null or battle == null or not battle.active \
            or not battle.continuous_mode or not state.sect.p3_7_resources_enabled \
            or not state.disciples.has(disciple_id):
        return {"ok":false,"reason":"combat_pill_context_unavailable"}
    var actor_id := str(disciple_id)
    var actor: Dictionary = battle.actors.get(actor_id,{})
    var disciple: DiscipleState = state.disciples[disciple_id]
    if str(actor.get("side","")) != "disciple" \
            or disciple.active_pve_encounter_id != battle.encounter_id \
            or not DiscipleRealmProgressV2.progression_ready(disciple) \
            or disciple.injury_level != 0:
        return {"ok":false,"reason":"combat_pill_owner_invalid"}
    var hp := float(actor.get("hp",-1.0))
    var max_hp := float(actor.get("max_hp",0.0))
    if not is_finite(hp) or not is_finite(max_hp) or hp <= 0.0 \
            or max_hp <= 0.0 or hp > max_hp:
        return {"ok":false,"reason":"combat_pill_hp_invalid"}
    if hp/max_hp > USE_AT_OR_BELOW_HP_RATIO:
        return {"ok":true,"used":false,"reason":"above_auto_hp_threshold"}
    if battle.now+0.00001 < float(actor.get(ACTOR_NEXT_AT,0.0)):
        return {"ok":true,"used":false,"reason":"pill_on_combat_cooldown"}
    # Verify one actual gameplay medicine, not the disciple's (stale during P0)
    # out-of-combat HP field. Medical satiety is the existing B3 authority.
    var candidate := _source_pill(state,disciple,max_hp-hp)
    if candidate.is_empty():
        return {"ok":true,"used":false,"reason":"no_source_backed_healing_medicine"}
    var meter_ready := B3PillSatietyV1.enable(state,disciple)
    if not bool(meter_ready.get("ok",false)):
        return {"ok":false,"reason":"combat_pill_meter_invalid",
            "detail":meter_ready.get("reason","unknown")}
    var pill: StringName = candidate["item"]
    var medicine := MedicineCatalogueV2.definition(pill)
    var cost := int(medicine.get("satiety_cost",-1))
    var meter: Dictionary = disciple.b3_pill_state
    var sequence := B3PillSatietyV1.next_sequence(disciple)
    if cost < 0 or cost > B3PillSatietyV1.CAPACITY-B3PillSatietyV1.spent_today(state,disciple) \
            or sequence > B3PillSatietyV1.MAX_SEQUENCE:
        return {"ok":true,"used":false,"reason":"pill_daily_cap"}
    var warehouse := WarehouseSystem.new()
    if not warehouse.consume(state,pill,1):
        return {"ok":true,"used":false,"reason":"pill_no_available_warehouse_stock"}
    var restored := float(candidate["healed"])
    actor["hp"] = minf(max_hp,hp+restored)
    actor[ACTOR_NEXT_AT] = battle.now+COOLDOWN_COMBAT_SECONDS
    meter["version"] = B3PillSatietyV1.VERSION
    meter["capacity"] = B3PillSatietyV1.CAPACITY
    meter["day"] = int(state.tick/B3PillSatietyV1.DAY_TICKS)
    meter["spent"] = B3PillSatietyV1.spent_today(state,disciple)+cost
    meter["sequence"] = sequence
    meter["receipt"] = {
        "sequence":sequence,"pill":str(pill),"state":"COMMITTED",
        "day":meter["day"],"tick":state.tick,"cost":cost,
        "spent_after":meter["spent"],"hp_delta":restored,
        "tuvi":0.0,"body_xp":0.0,
        "injury":disciple.injury_level,"recover_tick":disciple.injury_recover_at_tick,
        "medicine_version":MedicineCatalogueV2.VERSION,
        "medicine_potency":int(medicine["potency"]),
        "context":"pve_care03","encounter_id":battle.encounter_id,
        "combat_at":battle.now
    }
    # Battle actor's HP is authority during P0; B3's live discipline HP mirror
    # is updated via B3HuntWorld after the frame. No extra HP is minted.
    state.sect.needs_stats["healing_pills_used"] = int(
        state.sect.needs_stats.get("healing_pills_used",0))+1
    state.sect.needs_event_count += 1
    battle._event("combat_pill_used",{"actor_id":actor_id,
        "pill_id":str(pill),"hp_restored":restored,"sequence":sequence})
    return {"ok":true,"used":true,"pill":str(pill),"sequence":sequence,
        "hp_restored":restored,"save_required":true}

static func review(state: SimulationState, battle: MapBattleV2) -> Dictionary:
    if state == null or battle == null or not battle.active \
            or not battle.continuous_mode:
        return {"ok":true,"used":0}
    var used := 0
    var actor_ids: Array = battle.actors.keys()
    actor_ids.sort()
    for raw in actor_ids:
        var row: Dictionary = battle.actors[raw]
        if str(row.get("side","")) != "disciple" \
                or float(row.get("hp",0.0)) <= 0.0:
            continue
        var disciple_id := StringName(str(raw))
        if not state.disciples.has(disciple_id):
            return {"ok":false,"reason":"pve_pill_unknown_disciple"}
        var d: DiscipleState = state.disciples[disciple_id]
        if d.active_pve_encounter_id != battle.encounter_id:
            continue
        var result := heal_one(state,battle,disciple_id)
        if not bool(result.get("ok",false)):
            return {"ok":false,"reason":"pve_pill_commit_failed",
                "detail":result.get("reason","unknown")}
        if bool(result.get("used",false)):
            used += 1
    return {"ok":true,"used":used,"barrier":used > 0}
