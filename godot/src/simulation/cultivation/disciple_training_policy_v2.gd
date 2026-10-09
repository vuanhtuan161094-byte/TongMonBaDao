class_name DiscipleTrainingPolicyV2
extends RefCounted

# DV2-03D1: autonomous selection ONLY. This class never grants EXP, never
# attempts a major breakthrough and never invents an XP rate or time cadence.
const POLICY_BALANCED := "balanced"
const POLICY_CULTIVATION := "cultivation_focus"
const POLICY_BODY := "body_focus"
const POLICY_MANUAL := "manual"
const VALID_POLICIES := [
    POLICY_BALANCED,
    POLICY_CULTIVATION,
    POLICY_BODY,
    POLICY_MANUAL
]

static func current_policy(disciple: DiscipleState) -> String:
    if not DiscipleRealmProgressV2.progression_ready(disciple):
        return ""
    return str(disciple.v2_realm_progress.get(
        "training_policy",DiscipleRealmProgressV2.DEFAULT_TRAINING_POLICY
    ))

static func set_policy(
    state: SimulationState, disciple_id: StringName, policy: String
) -> Dictionary:
    if state == null or not VALID_POLICIES.has(policy):
        return {"ok":false,"reason":"invalid_training_policy"}
    if policy == POLICY_BODY:
        return {"ok":false,"reason":"body_training_mechanic_not_locked"}
    if not state.disciples.has(disciple_id):
        return {"ok":false,"reason":"unknown_training_disciple"}
    var disciple: DiscipleState = state.disciples[disciple_id]
    if not DiscipleRealmProgressV2.progression_ready(disciple):
        return {"ok":false,"reason":"training_profile_not_ready"}
    var previous := current_policy(disciple)
    disciple.v2_realm_progress["training_policy"] = policy
    return {
        "ok":true,
        "disciple_id":str(disciple_id),
        "previous_policy":previous,
        "policy":policy
    }

static func choose_auto_action(
    state: SimulationState, disciple: DiscipleState
) -> Dictionary:
    if state == null or disciple == null:
        return {"ok":false,"reason":"invalid_training_actor"}
    if not DiscipleRealmProgressV2.progression_ready(disciple):
        return {"ok":false,"reason":"training_profile_not_ready"}
    if not state.sect.v2_training_enabled:
        return {"ok":false,"reason":"v2_training_not_enabled"}
    if disciple.region_id != &"sect" or disciple.hp <= 0.0:
        return {"ok":false,"reason":"training_actor_not_available"}

    var policy := current_policy(disciple)
    if policy == POLICY_MANUAL:
        return {"ok":false,"reason":"manual_training_policy","policy":policy}

    var cultivation := DiscipleTrainingActionV2.preview_training(
        state,disciple,"cultivation"
    )
    var body := DiscipleTrainingActionV2.preview_training(
        state,disciple,"body"
    )

    if policy == POLICY_CULTIVATION:
        return _preferred(
            policy,cultivation,body,"cultivation_focus",
            "body_fallback"
        )
    if policy == POLICY_BODY:
        return {
            "ok":false,
            "reason":"body_training_mechanic_not_locked",
            "policy":policy
        }
    if policy != POLICY_BALANCED:
        return {"ok":false,"reason":"invalid_training_policy","policy":policy}

    return _balanced(state,disciple,cultivation,body)

static func _preferred(
    policy: String, preferred: Dictionary, fallback: Dictionary,
    preferred_reason: String, fallback_reason: String
) -> Dictionary:
    if bool(preferred.get("ok",false)):
        return _selected(policy,preferred,preferred_reason)
    if bool(fallback.get("ok",false)):
        return _selected(policy,fallback,fallback_reason)
    return {
        "ok":false,
        "reason":"no_trainable_v2_track",
        "policy":policy,
        "preferred_block":str(preferred.get("reason","unavailable")),
        "fallback_block":str(fallback.get("reason","unavailable"))
    }

static func _balanced(
    state: SimulationState, disciple: DiscipleState,
    cultivation: Dictionary, body: Dictionary
) -> Dictionary:
    var cult_ok := bool(cultivation.get("ok",false))
    var body_ok := bool(body.get("ok",false))
    if cult_ok and not body_ok:
        return _selected(POLICY_BALANCED,cultivation,"only_trainable_track")
    if body_ok and not cult_ok:
        return _selected(POLICY_BALANCED,body,"only_trainable_track")
    if not cult_ok and not body_ok:
        return {
            "ok":false,
            "reason":"no_trainable_v2_track",
            "policy":POLICY_BALANCED,
            "cultivation_block":str(cultivation.get("reason","unavailable")),
            "body_block":str(body.get("reason","unavailable"))
        }

    var cult_floor := int(cultivation.get("global_floor",0))
    var body_floor := int(body.get("global_floor",0))
    if cult_floor < body_floor:
        return _selected(POLICY_BALANCED,cultivation,"lower_global_floor")
    if body_floor < cult_floor:
        return _selected(POLICY_BALANCED,body,"lower_global_floor")

    var cult_ratio := float(cultivation.get("progress_ratio",0.0))
    var body_ratio := float(body.get("progress_ratio",0.0))
    if cult_ratio+0.0000001 < body_ratio:
        return _selected(POLICY_BALANCED,cultivation,"lower_current_floor_progress")
    if body_ratio+0.0000001 < cult_ratio:
        return _selected(POLICY_BALANCED,body,"lower_current_floor_progress")

    # Exact ties alternate deterministically without a hidden weight. The
    # stable disciple hash prevents a large roster from always choosing the
    # same track on the same simulation tick.
    var choose_cultivation := (
        (state.tick + _stable_id_value(str(disciple.id))) % 2 == 0
    )
    return _selected(
        POLICY_BALANCED,
        cultivation if choose_cultivation else body,
        "deterministic_equal_progress_tie"
    )

static func _selected(
    policy: String, preview: Dictionary, reason: String
) -> Dictionary:
    return {
        "ok":true,
        "policy":policy,
        "track":str(preview.get("track","")),
        "action":str(preview.get("action","")),
        "reason":reason,
        "global_floor":int(preview.get("global_floor",0)),
        "progress_ratio":float(preview.get("progress_ratio",0.0))
    }

static func _stable_id_value(value: String) -> int:
    var result := 17
    for index in range(value.length()):
        result = int((result*131 + value.unicode_at(index)) % 2147483629)
    return result
