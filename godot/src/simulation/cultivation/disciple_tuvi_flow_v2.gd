class_name DiscipleTuViFlowV2
extends RefCounted

# Canonical DV2 natural Tu Vi time source.
# Balance is authored in Tu Vi / simulation minute. One SimulationScheduler
# step is already one simulation minute in the P3.7 time contract.
# Presentation/wall-clock cadence must not change this rate.

static func validate_rule(
    disciple: DiscipleState, data: Variant, require_preview: bool = true
) -> Dictionary:
    if disciple == null or not DiscipleRealmProgressV2.progression_ready(disciple):
        return {"ok":false,"reason":"training_profile_not_ready"}
    if not (data is Dictionary):
        return {"ok":false,"reason":"missing_authored_training_rules"}
    var rule: Dictionary = data
    if str(rule.get("action","")) != "CULTIVATE" or str(rule.get("authority_id","")).is_empty():
        return {"ok":false,"reason":"invalid_training_rule_authority"}

    var raw_rate = rule.get("base_tuvi_per_minute",null)
    if not (raw_rate is int or raw_rate is float):
        return {"ok":false,"reason":"missing_tuvi_per_minute"}
    var base_rate := float(raw_rate)
    if is_nan(base_rate) or is_inf(base_rate) or base_rate <= 0.0:
        return {"ok":false,"reason":"invalid_tuvi_per_minute"}

    var raw_multiplier = rule.get("cultivate_multiplier",null)
    if not (raw_multiplier is int or raw_multiplier is float):
        return {"ok":false,"reason":"missing_cultivate_multiplier"}
    var cultivate_multiplier := float(raw_multiplier)
    if is_nan(cultivate_multiplier) or is_inf(cultivate_multiplier) or cultivate_multiplier < 1.0:
        return {"ok":false,"reason":"invalid_cultivate_multiplier"}

    var costs = rule.get("floor_costs",null)
    if not (costs is Dictionary):
        return {"ok":false,"reason":"missing_authored_floor_costs"}
    var sources = rule.get("sources",[])
    if not (sources is Array):
        return {"ok":false,"reason":"invalid_training_source_list"}

    # Explicit previews still perform the full read-only grant_xp preflight.
    # resolve_minute() immediately performs the same authoritative grant_xp
    # with commit and can skip this duplicate computation. Any invalid cost,
    # source or progression state is still rejected by that live grant before
    # its XP is mutated. This matters at 1,000–3,000 disciples per minute.
    if require_preview:
        var preview := DiscipleRealmProgressV2.grant_xp(
            disciple,"cultivation",base_rate,"natural",costs,sources,true
        )
        if not bool(preview.get("ok",false)):
            return {"ok":false,"reason":str(preview.get("reason","invalid_tuvi_preview"))}

    return {
        "ok":true,
        "base_tuvi_per_minute":base_rate,
        "cultivate_multiplier":cultivate_multiplier,
        "rate":base_rate,
        "costs":costs,
        "floor_costs":costs,
        "sources":sources
    }

static func preview_rate(state: SimulationState, disciple: DiscipleState, specialized: bool = false) -> Dictionary:
    if state == null or disciple == null or not state.sect.v2_training_enabled:
        return {"ok":false,"reason":"v2_training_not_enabled"}
    if not state.disciples.has(disciple.id) or state.disciples[disciple.id] != disciple:
        return {"ok":false,"reason":"training_actor_not_owned_by_state"}
    var ready := validate_rule(
        disciple,state.sect.v2_training_rules.get("cultivation",null)
    )
    if not bool(ready.get("ok",false)):
        return ready
    var base_rate := float(ready["base_tuvi_per_minute"])
    var multiplier := float(ready["cultivate_multiplier"]) if specialized else 1.0
    var dry := DiscipleRealmProgressV2.grant_xp(
        disciple,"cultivation",base_rate*multiplier,"natural",
        ready["floor_costs"],ready["sources"],true
    )
    if not bool(dry.get("ok",false)):
        return dry
    return {
        "ok":true,
        "unit":"tuvi_per_minute",
        "specialized":specialized,
        "base_tuvi_per_minute":base_rate,
        "cultivate_multiplier":multiplier,
        "effective_tuvi_per_minute":float(dry.get("gained",0.0)),
        "natural_factor":float(dry.get("natural_factor",1.0))
    }

static func resolve_minute(
    state: SimulationState, disciple: DiscipleState, specialized: bool
) -> Dictionary:
    if state == null or disciple == null or not state.sect.v2_training_enabled:
        return {"ok":false,"reason":"v2_training_not_enabled"}
    if not state.disciples.has(disciple.id) or state.disciples[disciple.id] != disciple:
        return {"ok":false,"reason":"training_actor_not_owned_by_state"}
    if state.tick <= 0:
        return {"ok":false,"reason":"no_committed_simulation_tick"}
    if not DiscipleRealmProgressV2.progression_ready(disciple):
        return {"ok":false,"reason":"training_profile_not_ready"}
    if int(disciple.v2_realm_progress.get("last_passive_tuvi_tick",-1)) == state.tick:
        return {"ok":false,"reason":"passive_tuvi_tick_already_awarded"}

    var ready := validate_rule(
        disciple,state.sect.v2_training_rules.get("cultivation",null),false
    )
    if not bool(ready.get("ok",false)):
        return ready

    var multiplier := float(ready["cultivate_multiplier"]) if specialized else 1.0
    var authored_base := float(ready["base_tuvi_per_minute"])
    var grant := DiscipleRealmProgressV2.grant_xp(
        disciple,"cultivation",authored_base*multiplier,"natural",
        ready["floor_costs"],ready["sources"]
    )
    if not bool(grant.get("ok",false)):
        return grant

    disciple.v2_realm_progress["last_passive_tuvi_tick"] = state.tick
    return {
        "ok":true,
        "event_id":"%d:%s:PASSIVE_TUVI" % [state.tick,str(disciple.id)],
        "tick":state.tick,
        "unit":"tuvi_per_minute",
        "specialized":specialized,
        "base_tuvi_per_minute":authored_base,
        "cultivate_multiplier":multiplier,
        "gained":grant["gained"],
        "natural_factor":grant.get("natural_factor",1.0),
        "realm":grant["realm"],
        "floor":grant["floor"],
        "floors_earned":grant["floors_earned"],
        "xp":grant["xp"],
        "at_major_gate":grant["at_major_gate"],
        "unapplied_overflow":grant["unapplied_overflow"]
    }
