class_name V63PveMasteryReceipts
extends RefCounted

# G1B: Detached MapBattleV2 actors must never directly mutate DiscipleState.
# A meaningful cast creates a bounded, deterministic receipt in the battle
# snapshot. The canonical HuntingPveRunV2 owner settles it exactly once.
const MAX_PENDING_PER_ACTOR := 256
const MAX_HISTORICAL_PER_SKILL := 4096
const MAX_MASTERY_XP := 1000000.0

static func queue_cast(actor: Dictionary, skill_id: String, event_id: String) -> bool:
    var owner_id := str(actor.get("id", ""))
    var loadout = actor.get("v63_skill_loadout", [])
    if not bool(actor.get("v63_combat_enabled", false)) or owner_id.is_empty() \
            or event_id.is_empty() or event_id.length() > 512 \
            or not (loadout is Array) or not loadout.has(skill_id) \
            or V63HumanSkillCombatSystem.skill_definition(skill_id).is_empty():
        return false
    var pending: Dictionary = actor.get("v63_pending_mastery", {}).duplicate(true)
    if pending.has(event_id) or pending.size() >= MAX_PENDING_PER_ACTOR:
        return false
    var xp_delta := V63SpiritualRootEvaluator.attached_skill_mastery_factor(actor, skill_id)
    if not is_finite(xp_delta) or xp_delta < 1.0 or xp_delta > 1.3:
        return false
    pending[event_id] = {"skill_id": skill_id, "xp_delta": xp_delta}
    actor["v63_pending_mastery"] = pending
    return true

# Preflight ALL pending receipts into detached knowledge copies before any
# DiscipleState mutation. The caller owns the existing persistence/save barrier.
static func settle(state: SimulationState, battle: MapBattleV2) -> Dictionary:
    if state == null or battle == null or battle.encounter_id.is_empty():
        return {"ok": false, "reason": "missing_mastery_settlement_context"}
    var prepared: Dictionary = {}
    var actor_ids: Array = battle.actors.keys()
    actor_ids.sort()
    var awarded := 0
    var acknowledged := 0
    for raw_actor_id in actor_ids:
        var actor_id := str(raw_actor_id)
        var actor: Dictionary = battle.actors[raw_actor_id]
        var pending_value = actor.get("v63_pending_mastery", {})
        if not (pending_value is Dictionary):
            return {"ok": false, "reason": "invalid_pending_mastery_type"}
        var pending: Dictionary = pending_value
        if pending.is_empty():
            continue
        if pending.size() > MAX_PENDING_PER_ACTOR or str(actor.get("side", "")) != "disciple" \
                or not state.disciples.has(StringName(actor_id)):
            return {"ok": false, "reason": "invalid_pending_mastery_owner"}
        var disciple: DiscipleState = state.disciples[StringName(actor_id)]
        if disciple.active_pve_encounter_id != battle.encounter_id:
            return {"ok": false, "reason": "pending_mastery_reservation_mismatch"}
        var known: Dictionary = disciple.v63_learned_skill_nodes.duplicate(true)
        var event_ids: Array = pending.keys()
        event_ids.sort()
        var prefix := "%s/%s/" % [battle.encounter_id, actor_id]
        var loadout = actor.get("v63_skill_loadout", [])
        if not (loadout is Array):
            return {"ok": false, "reason": "pending_mastery_loadout_missing"}
        for raw_event_id in event_ids:
            var event_id := str(raw_event_id)
            var suffix := event_id.substr(prefix.length()) if event_id.begins_with(prefix) else ""
            if suffix.is_empty() or not suffix.is_valid_int() or int(suffix) <= 0 or event_id.length() > 512:
                return {"ok": false, "reason": "invalid_pending_mastery_event_id"}
            var payload_value = pending[raw_event_id]
            if not (payload_value is Dictionary):
                return {"ok": false, "reason": "invalid_pending_mastery_payload"}
            var payload: Dictionary = payload_value
            var skill_id := str(payload.get("skill_id", ""))
            var xp_delta := float(payload.get("xp_delta", 0.0))
            var definition := V63HumanSkillCombatSystem.skill_definition(skill_id)
            if definition.is_empty() or not loadout.has(skill_id) or not known.has(skill_id) \
                    or not is_finite(xp_delta) or xp_delta < 1.0 or xp_delta > 1.3:
                return {"ok": false, "reason": "invalid_pending_mastery_skill_or_xp"}
            if not (known[skill_id] is Dictionary):
                return {"ok": false, "reason": "invalid_pending_mastery_knowledge"}
            var record: Dictionary = known[skill_id].duplicate(true)
            var receipts_value = record.get("mastery_cast_receipts", {})
            if not (receipts_value is Dictionary):
                return {"ok": false, "reason": "invalid_mastery_receipt_history"}
            var receipts: Dictionary = receipts_value
            if receipts.has(event_id):
                acknowledged += 1
                continue
            if receipts.size() >= MAX_HISTORICAL_PER_SKILL:
                return {"ok": false, "reason": "mastery_receipt_history_full"}
            var prior_xp := float(record.get("mastery_xp", -1.0))
            if not is_finite(prior_xp) or prior_xp < 0.0 or prior_xp > MAX_MASTERY_XP:
                return {"ok": false, "reason": "invalid_mastery_prior_xp"}
            receipts[event_id] = true
            record["mastery_cast_receipts"] = receipts
            record["mastery_xp"] = minf(MAX_MASTERY_XP, prior_xp + xp_delta)
            var generation := str(definition.get("generation", "human"))
            var maximum := 12 if generation == "human" else 3
            record["level"] = mini(maximum, 1 + int(float(record["mastery_xp"]) / 100.0))
            known[skill_id] = record
            awarded += 1
            acknowledged += 1
        prepared[actor_id] = known
    # Commit only after all participants/skills pass preflight; clear the actor
    # journals alongside the owner record in this same SimulationState barrier.
    for raw_actor_id in prepared.keys():
        var actor_id := str(raw_actor_id)
        var disciple: DiscipleState = state.disciples[StringName(actor_id)]
        disciple.v63_learned_skill_nodes = prepared[actor_id]
        var settled_actor: Dictionary = battle.actors[actor_id]
        settled_actor.erase("v63_pending_mastery")
    return {"ok": true, "awarded": awarded, "acknowledged": acknowledged}
