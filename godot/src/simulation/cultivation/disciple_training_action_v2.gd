class_name DiscipleTrainingActionV2
extends RefCounted

# DV2-03 action bridge. Rates are normalized per simulation minute.
# Tu Vi itself is passive-time owned; CULTIVATE only selects Chuyên Tu.
# Luyện Thể dedicated Rèn Thân action is owned by the real building/slot/cost consumer.
const ACTION_TRACKS := {"CULTIVATE":"cultivation","TRAIN_BODY":"body"}

# Validate the same real EXP operation without changing a floor, XP or action.
# This rejects bad authored inputs before a player command can be accepted.
static func _validated_rule(disciple: DiscipleState, track: String, data: Variant) -> Dictionary:
    if track == "cultivation":
        return DiscipleTuViFlowV2.validate_rule(disciple,data)
    if track == "body":
        return {"ok":false,"reason":"body_training_requires_facility_context"}
    return {"ok":false,"reason":"unsupported_training_track"}

# Read-only eligibility/ratio surface shared by autonomous policy and UI.
# It uses the same authored rule validation as the eventual committed action.
static func preview_training(state: SimulationState, disciple: DiscipleState, track: String) -> Dictionary:
    if disciple != null and not disciple.active_pve_encounter_id.is_empty():
        return {"ok":false,"reason":"disciple_in_v2_pve"}
    if state == null or disciple == null or not state.sect.v2_training_enabled or not DiscipleRealmProgressV2.TRACKS.has(track):
        return {"ok":false,"reason":"invalid_or_disabled_training_preview"}
    if not state.disciples.has(disciple.id) or state.disciples[disciple.id] != disciple:
        return {"ok":false,"reason":"training_actor_not_owned_by_state"}
    if not DiscipleRealmProgressV2.progression_ready(disciple):
        return {"ok":false,"reason":"training_profile_not_ready"}
    if disciple.region_id != &"sect" or disciple.hp <= 0.0:
        return {"ok":false,"reason":"training_disciple_not_present"}
    var ready := (
        DiscipleBodyTrainingFacilityV2.preview_minute(state,disciple)
        if track == "body"
        else _validated_rule(disciple,track,state.sect.v2_training_rules.get(track,null))
    )
    if not bool(ready.get("ok",false)):
        return {"ok":false,"reason":str(ready.get("reason","invalid_training_rule"))}
    var row: Dictionary = disciple.v2_realm_progress[track]
    var key := "%d:%d" % [int(row["realm"]),int(row["floor"])]
    var costs: Dictionary = (
        state.sect.v2_training_rules.get("body",{}).get("floor_costs",{})
        if track == "body" else ready["costs"]
    )
    if not costs.has(key):
        return {"ok":false,"reason":"xp_cost_content_not_authorized"}
    var current_cost := float(costs[key])
    var current_xp := float(row["xp"])
    if int(row["floor"]) == DiscipleRealmProgressV2.MAX_FLOOR and current_xp+0.0000001 >= current_cost:
        return {
            "ok":false,"reason":"major_gate_waiting",
            "track":track,"current_xp":current_xp,"current_cost":current_cost,
            "progress_ratio":1.0
        }
    return {
        "ok":true,"track":track,
        "action":"CULTIVATE" if track=="cultivation" else "TRAIN_BODY",
        "current_xp":current_xp,"current_cost":current_cost,
        "progress_ratio":clampf(current_xp/current_cost,0.0,1.0),
        "global_floor":DiscipleRealmProgressV2.global_floor(int(row["realm"]),int(row["floor"]))
    }

# One real player-facing command boundary, with NO immediate reward.
# The simulation scheduler still owns the actual elapsed-minute result. This does not
# add a second timer or let commands interrupt hunting/combat/urgent healing.
static func request_training(state: SimulationState, disciple_id: StringName, track: String) -> Dictionary:
    if state == null or not state.sect.v2_training_enabled or not DiscipleRealmProgressV2.TRACKS.has(track):
        return {"ok":false,"reason":"invalid_or_disabled_training_request"}
    if not state.disciples.has(disciple_id):
        return {"ok":false,"reason":"unknown_training_disciple"}
    var disciple: DiscipleState = state.disciples[disciple_id]
    if not DiscipleRealmProgressV2.progression_ready(disciple):
        return {"ok":false,"reason":"training_profile_not_ready"}
    if disciple.region_id != &"sect" or disciple.hp <= 0.0:
        return {"ok":false,"reason":"training_disciple_not_present"}
    if not [&"EVALUATE",&"IDLE",&"HOLD",&"CULTIVATE",&"TRAIN_BODY"].has(disciple.current_action):
        return {"ok":false,"reason":"training_cannot_interrupt_active_work"}
    if not disciple.active_pve_encounter_id.is_empty():
        return {"ok":false,"reason":"disciple_in_v2_pve"}
    # GP-02B1: current_action=EVALUATE does not mean unoccupied.
    # The real production cycle and timed building jobs own the actor until
    # their completion. Every backend caller must obey this gate, not only UI.
    if not disciple.work_cycle_state.is_empty():
        return {"ok":false,"reason":"training_cannot_interrupt_active_work"}
    # Do not queue a training action behind an outstanding Work/Hunt/Rest/Hold
    # command: on the next EVALUATE it would overwrite the requested action.
    # A matching legacy CULTIVATE command is the sole compatible exception.
    if not disciple.direct_command.is_empty():
        var cmd_kind := str(disciple.direct_command.get("kind",""))
        if track != "cultivation" or cmd_kind != "cultivate":
            return {"ok":false,"reason":"training_conflicting_direct_command"}
    var buildings := BuildingSystem.new()
    if buildings.disciple_has_active_spirit_plot(state,disciple.id):
        return {"ok":false,"reason":"busy_spirit_plot"}
    if buildings.disciple_has_active_timed_recipe(state,disciple.id):
        return {"ok":false,"reason":"busy_timed_recipe"}
    var action := "TRAIN_BODY" if track == "body" else "CULTIVATE"
    var ready := preview_training(state,disciple,track)
    if not bool(ready.get("ok",false)):
        return {"ok":false,"reason":str(ready.get("reason","invalid_training_rule"))}
    # An approved explicit Chuyên Tu command is a transfer, not an
    # additional job occupying the scarce 2-slot Rèn Thân facility.
    # Check *after* the new track's preview has succeeded so a refused
    # cultivation request never evicts the original trainee.
    if track == "cultivation" and DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,disciple):
        var released := DiscipleBodyTrainingFacilityV2.release_slot(state,disciple_id)
        if not bool(released.get("ok",false)):
            return released
    disciple.current_action = StringName(action)
    return {"ok":true,"track":track,"queued_action":action}

static func resolve(state: SimulationState, disciple: DiscipleState, action: String) -> Dictionary:
    if state == null or disciple == null or not state.sect.v2_training_enabled:
        return {"ok":false,"reason":"v2_training_not_enabled"}
    if not ACTION_TRACKS.has(action):
        return {"ok":false,"reason":"unsupported_training_action"}
    if not state.disciples.has(disciple.id) or state.disciples[disciple.id] != disciple:
        return {"ok":false,"reason":"training_actor_not_owned_by_state"}
    if not disciple.active_pve_encounter_id.is_empty():
        return {"ok":false,"reason":"disciple_in_v2_pve"}
    if disciple.current_action != StringName(action):
        return {"ok":false,"reason":"training_action_not_current"}
    if state.tick <= 0:
        return {"ok":false,"reason":"no_committed_simulation_tick"}
    if not DiscipleRealmProgressV2.progression_ready(disciple):
        return {"ok":false,"reason":"v2_disciple_not_initialized"}
    # Cultivation and body training occur at the sect in this first bridge.
    # No expedition stamina / HP drain is invented for Body training.
    if disciple.region_id != &"sect" or disciple.hp <= 0.0:
        return {"ok":false,"reason":"training_actor_not_available"}
    var track: String = ACTION_TRACKS[action]
    if track == "cultivation":
        return {"ok":false,"reason":"cultivation_resolves_via_passive_time"}
    return DiscipleBodyTrainingFacilityV2.commit_minute(state,disciple)
