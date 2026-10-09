class_name DiscipleTrainingActionV2
extends RefCounted

# DV2-03 opt-in bridge for real 15-second simulation actions.
# No global fabricated XP curve, no chance rolls, no second timer.
# Content authority MUST explicitly provide each applicable cost/rate.
const ACTION_TRACKS := {"CULTIVATE":"cultivation","TRAIN_BODY":"body"}

static func resolve(state: SimulationState, disciple: DiscipleState, action: String) -> Dictionary:
    if state == null or disciple == null or not state.sect.v2_training_enabled:
        return {"ok":false,"reason":"v2_training_not_enabled"}
    if not ACTION_TRACKS.has(action):
        return {"ok":false,"reason":"unsupported_training_action"}
    if not DiscipleRealmProgressV2.valid_profile(disciple.v2_realm_progress):
        return {"ok":false,"reason":"v2_disciple_not_initialized"}
    # Cultivation and body training occur at the sect in this first bridge.
    # No expedition stamina / HP drain is invented for Body training.
    if disciple.region_id != &"sect" or disciple.hp <= 0.0:
        return {"ok":false,"reason":"training_actor_not_available"}
    var track: String = ACTION_TRACKS[action]
    var training_data = state.sect.v2_training_rules.get(track,null)
    if not (training_data is Dictionary):
        return {"ok":false,"reason":"missing_authored_training_rules"}
    var rule: Dictionary = training_data
    if str(rule.get("action","")) != action or str(rule.get("authority_id","")).is_empty():
        return {"ok":false,"reason":"invalid_training_rule_authority"}
    var configured_rate = rule.get("base_xp_per_action",null)
    if not (configured_rate is float or configured_rate is int):
        return {"ok":false,"reason":"missing_training_base_rate"}
    var rate := float(configured_rate)
    if is_nan(rate) or is_inf(rate) or rate <= 0.0:
        return {"ok":false,"reason":"invalid_training_base_rate"}
    var costs = rule.get("floor_costs",null)
    if not (costs is Dictionary):
        return {"ok":false,"reason":"missing_authored_floor_costs"}
    var source_values = rule.get("sources",[])
    if not (source_values is Array):
        return {"ok":false,"reason":"invalid_training_source_list"}
    var row: Dictionary = disciple.v2_realm_progress[track]
    var event_id := "%d:%s:%s" % [state.tick,str(disciple.id),action]
    if str(row.get("last_training_event_id","")) == event_id:
        return {"ok":false,"reason":"training_event_already_awarded"}
    var gain := DiscipleRealmProgressV2.grant_xp(
        disciple,track,rate,"natural",costs,source_values
    )
    if not bool(gain.get("ok",false)):
        return gain
    disciple.v2_realm_progress[track]["last_training_event_id"] = event_id
    return {
        "ok":true,"event_id":event_id,
        "track":track,"action":action,"tick":state.tick,
        "base_xp":rate,"gained":gain["gained"],
        "realm":gain["realm"],"floor":gain["floor"],
        "floors_earned":gain["floors_earned"],
        "xp":gain["xp"],"at_major_gate":gain["at_major_gate"],
        "unapplied_overflow":gain["unapplied_overflow"]
    }
