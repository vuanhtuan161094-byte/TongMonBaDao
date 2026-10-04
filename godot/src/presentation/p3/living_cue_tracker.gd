class_name LivingCueTracker
extends RefCounted

const INFO_LIFETIME_MS := 2800
const CRITICAL_LIFETIME_MS := 4000

var snapshots: Dictionary = {}
var active_events: Dictionary = {}
var observation_now_msec: int = 0

func seed(state: SimulationState) -> void:
    snapshots.clear()
    active_events.clear()
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        snapshots[str(disciple.id)] = _snapshot(disciple)

func observe(state: SimulationState, now_msec: int) -> Array[Dictionary]:
    observation_now_msec = now_msec
    if snapshots.is_empty():
        seed(state)
        return []

    _expire(now_msec)

    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        var key := str(disciple.id)
        var current := _snapshot(disciple)
        var previous: Dictionary = snapshots.get(key, current)

        _metric_event(
            disciple,
            "breakthrough_successes",
            previous,
            current,
            "breakthrough_success",
            LivingCueResolver.SEVERITY_INFO,
            "Đột phá thành công!",
            INFO_LIFETIME_MS,
            "breakthrough"
        )
        _metric_event(
            disciple,
            "breakthrough_failures",
            previous,
            current,
            "breakthrough_failure",
            LivingCueResolver.SEVERITY_CRITICAL,
            "Đột phá thất bại",
            CRITICAL_LIFETIME_MS,
            "breakthrough_failure"
        )
        _metric_event(
            disciple,
            "mining_completions",
            previous,
            current,
            "mining_complete",
            LivingCueResolver.SEVERITY_INFO,
            "Khai khoáng xong",
            INFO_LIFETIME_MS,
            "work_complete"
        )
        _metric_event(
            disciple,
            "forging_completions",
            previous,
            current,
            "forging_complete",
            LivingCueResolver.SEVERITY_INFO,
            "Luyện khí xong",
            INFO_LIFETIME_MS,
            "work_complete"
        )
        _metric_event(
            disciple,
            "heals",
            previous,
            current,
            "heal_complete",
            LivingCueResolver.SEVERITY_INFO,
            "Đã trị thương",
            INFO_LIFETIME_MS,
            "heal_complete"
        )

        var previous_region := str(previous.get("region_id", "sect"))
        var current_region := str(current.get("region_id", "sect"))
        if previous_region != "sect" and current_region == "sect":
            _emit_event(
                disciple,
                "returned_to_sect",
                int(current.get("return_serial", 0)),
                LivingCueResolver.SEVERITY_INFO,
                "Đã về tông",
                INFO_LIFETIME_MS,
                "returned_to_sect"
            )

        snapshots[key] = current

    var result: Array[Dictionary] = []
    var event_keys: Array = active_events.keys()
    event_keys.sort()
    for event_key in event_keys:
        var event: Dictionary = active_events[event_key]
        if int(event.get("expires_at_msec", 0)) > now_msec:
            result.append(event.duplicate(true))
    return result

func _metric_event(
    disciple: DiscipleState,
    metric_key: String,
    previous: Dictionary,
    current: Dictionary,
    cue_id: String,
    severity: int,
    text: String,
    lifetime_ms: int,
    semantic_group: String
) -> void:
    var before := int(previous.get(metric_key, 0))
    var after := int(current.get(metric_key, 0))
    if after <= before:
        return
    _emit_event(disciple, cue_id, after, severity, text, lifetime_ms, semantic_group)

func _emit_event(
    disciple: DiscipleState,
    cue_id: String,
    serial: int,
    severity: int,
    text: String,
    lifetime_ms: int,
    semantic_group: String
) -> void:
    var stable_key := "event:%s:%s:%d" % [cue_id, str(disciple.id), serial]
    if active_events.has(stable_key):
        return
    active_events[stable_key] = {
        "cue_id": cue_id,
        "target_kind": str(LivingCueResolver.TARGET_DISCIPLE),
        "target_id": str(disciple.id),
        "severity": severity,
        "text": text,
        "reason": "Presentation-only metric/transition delta.",
        "semantic_group": semantic_group,
        "event": true,
        "stable_key": stable_key,
        "expires_at_msec": observation_now_msec + lifetime_ms
    }

func _expire(now_msec: int) -> void:
    var expired: Array = []
    for event_key in active_events.keys():
        var event: Dictionary = active_events[event_key]
        if int(event.get("expires_at_msec", 0)) <= now_msec:
            expired.append(event_key)
    for event_key in expired:
        active_events.erase(event_key)

func _snapshot(disciple: DiscipleState) -> Dictionary:
    return {
        "breakthrough_successes": int(disciple.metrics.get("breakthrough_successes", 0)),
        "breakthrough_failures": int(disciple.metrics.get("breakthrough_failures", 0)),
        "mining_completions": int(disciple.metrics.get("mining_completions", 0)),
        "forging_completions": int(disciple.metrics.get("forging_completions", 0)),
        "heals": int(disciple.metrics.get("heals", 0)),
        "region_id": str(disciple.region_id),
        "return_serial": int(disciple.metrics.get("returns_to_sect", 0))
    }
