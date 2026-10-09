class_name DiscipleBodyXpSourceV2
extends RefCounted

# DV2-03 Body EXP source authority.
# This class does NOT invent a training building, resource IDs, costs, map
# pressure values, profession eligibility or production rates. It only owns the
# shared accounting contract after an owning consumer has verified the context.
#
# User lock 2026-10-09:
# - production, dedicated body training and expedition are distinct natural
#   Luyện Thể sources;
# - dedicated body training is measured per simulation minute;
# - ordinary fixed +X Body EXP remains a separate fixed reward path;
# - one disciple may receive at most one natural Body source in one simulation
#   minute. Buffs/modifiers belong inside that source, not as duplicate grants.

const SOURCE_PRODUCTION := "production"
const SOURCE_BODY_TRAINING := "body_training"
const SOURCE_EXPEDITION := "expedition"
const NATURAL_SOURCE_KINDS := [
    SOURCE_PRODUCTION,
    SOURCE_BODY_TRAINING,
    SOURCE_EXPEDITION
]
const RATE_UNIT := "body_xp_per_simulation_minute"

static func validate_source(raw: Variant) -> Dictionary:
    if not (raw is Dictionary):
        return {"ok":false,"reason":"invalid_body_xp_source"}
    var source: Dictionary = raw
    var source_id := str(source.get("source_id",""))
    var source_kind := str(source.get("source_kind",""))
    if source_id.is_empty():
        return {"ok":false,"reason":"missing_body_xp_source_id"}
    if not NATURAL_SOURCE_KINDS.has(source_kind):
        return {"ok":false,"reason":"invalid_body_xp_source_kind"}

    var raw_rate = source.get("base_body_xp_per_minute",null)
    if not (raw_rate is int or raw_rate is float):
        return {"ok":false,"reason":"missing_body_xp_rate"}
    var rate := float(raw_rate)
    if is_nan(rate) or is_inf(rate) or rate <= 0.0:
        return {"ok":false,"reason":"invalid_body_xp_rate"}

    var floor_costs = source.get("floor_costs",null)
    if not (floor_costs is Dictionary):
        return {"ok":false,"reason":"missing_authored_floor_costs"}
    var modifiers = source.get("modifiers",[])
    if not (modifiers is Array):
        return {"ok":false,"reason":"invalid_body_xp_modifiers"}

    # Dedicated Rèn Thân is intentionally stricter than the other two sources:
    # its future building/content owner must prove both access/grade eligibility
    # and that this minute's economic cost was actually committed.
    if source_kind == SOURCE_BODY_TRAINING:
        if not bool(source.get("training_access_verified",false)):
            return {"ok":false,"reason":"body_training_access_not_verified"}
        if not bool(source.get("training_cost_committed",false)):
            return {"ok":false,"reason":"body_training_cost_not_committed"}

    # Production and expedition consumers must prove the disciple is actively
    # performing the eligible context. Passive facility countdown/standing idle
    # may not call this source merely because a job or expedition is assigned.
    if source_kind == SOURCE_PRODUCTION and not bool(source.get("active_work_verified",false)):
        return {"ok":false,"reason":"production_body_load_not_active"}
    if source_kind == SOURCE_EXPEDITION and not bool(source.get("active_expedition_verified",false)):
        return {"ok":false,"reason":"expedition_body_load_not_active"}

    return {
        "ok":true,
        "source_id":source_id,
        "source_kind":source_kind,
        "base_body_xp_per_minute":rate,
        "floor_costs":floor_costs,
        "modifiers":modifiers
    }

static func preview_minute(
    state: SimulationState, disciple: DiscipleState, raw_source: Variant
) -> Dictionary:
    var ready := _validate_actor_and_source(state,disciple,raw_source)
    if not bool(ready.get("ok",false)):
        return ready
    var grant := DiscipleRealmProgressV2.grant_xp(
        disciple,"body",float(ready["base_body_xp_per_minute"]),"natural",
        ready["floor_costs"],ready["modifiers"],true
    )
    if not bool(grant.get("ok",false)):
        return grant
    return _receipt(ready,grant,state.tick,true)

static func commit_minute(
    state: SimulationState, disciple: DiscipleState, raw_source: Variant,
    event_id: String
) -> Dictionary:
    var ready := _validate_actor_and_source(state,disciple,raw_source)
    if not bool(ready.get("ok",false)):
        return ready
    if event_id.is_empty():
        return {"ok":false,"reason":"missing_body_xp_event_id"}
    if state.tick <= 0:
        return {"ok":false,"reason":"no_committed_simulation_tick"}
    if int(disciple.v2_realm_progress.get("last_body_xp_tick",-1)) == state.tick:
        return {"ok":false,"reason":"body_xp_tick_already_awarded"}

    var body: Dictionary = disciple.v2_realm_progress["body"]
    if str(body.get("last_training_event_id","")) == event_id:
        return {"ok":false,"reason":"body_xp_event_replayed"}

    var grant := DiscipleRealmProgressV2.grant_xp(
        disciple,"body",float(ready["base_body_xp_per_minute"]),"natural",
        ready["floor_costs"],ready["modifiers"]
    )
    if not bool(grant.get("ok",false)):
        return grant

    disciple.v2_realm_progress["last_body_xp_tick"] = state.tick
    disciple.v2_realm_progress["body"]["last_training_event_id"] = event_id
    var result := _receipt(ready,grant,state.tick,false)
    result["event_id"] = event_id
    return result

static func _validate_actor_and_source(
    state: SimulationState, disciple: DiscipleState, raw_source: Variant
) -> Dictionary:
    if state == null or disciple == null:
        return {"ok":false,"reason":"invalid_body_xp_actor"}
    if not state.disciples.has(disciple.id) or state.disciples[disciple.id] != disciple:
        return {"ok":false,"reason":"body_xp_actor_not_owned_by_state"}
    if not DiscipleRealmProgressV2.progression_ready(disciple):
        return {"ok":false,"reason":"training_profile_not_ready"}
    if disciple.hp <= 0.0:
        return {"ok":false,"reason":"body_xp_actor_not_available"}
    var ready := validate_source(raw_source)
    if not bool(ready.get("ok",false)):
        return ready
    var kind := str(ready["source_kind"])
    if kind == SOURCE_EXPEDITION and disciple.region_id == &"sect":
        return {"ok":false,"reason":"expedition_body_source_requires_outside_map"}
    if kind != SOURCE_EXPEDITION and disciple.region_id != &"sect":
        return {"ok":false,"reason":"sect_body_source_requires_sect"}
    return ready

static func _receipt(
    ready: Dictionary, grant: Dictionary, tick: int, preview: bool
) -> Dictionary:
    return {
        "ok":true,
        "preview":preview,
        "tick":tick,
        "track":"body",
        "source_id":ready["source_id"],
        "source_kind":ready["source_kind"],
        "unit":RATE_UNIT,
        "base_body_xp_per_minute":ready["base_body_xp_per_minute"],
        "gained":grant["gained"],
        "natural_factor":grant.get("natural_factor",1.0),
        "realm":grant["realm"],
        "floor":grant["floor"],
        "floors_earned":grant["floors_earned"],
        "xp":grant["xp"],
        "at_major_gate":grant["at_major_gate"],
        "unapplied_overflow":grant["unapplied_overflow"]
    }
