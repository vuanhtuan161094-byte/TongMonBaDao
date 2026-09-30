class_name MemorySystem
extends RefCounted

const MAX_MEMORIES_PER_DISCIPLE := 24
const MAX_LOCAL_CONTACTS := 3

const EVENT_PERSONAL_VICTORY := &"personal_victory"
const EVENT_PERSONAL_RETREAT := &"personal_retreat"
const EVENT_PERSONAL_DEFEAT := &"personal_defeat"
const EVENT_SHARED_VICTORY := &"shared_victory"
const EVENT_WITNESS_RETREAT := &"witness_retreat"
const EVENT_WITNESS_DEFEAT := &"witness_defeat"

func record_event(
    state: SimulationState,
    owner_id: StringName,
    event_id: StringName,
    target_id: StringName = &"",
    region_id: StringName = &"",
    player_linked: bool = false
) -> MemoryState:
    if not state.p1_memory_enabled or not state.disciples.has(owner_id):
        return null
    if target_id != &"" and not state.disciples.has(target_id):
        return null
    if region_id != &"" and not state.regions.has(region_id):
        return null

    var profile := _event_profile(event_id)
    if profile.is_empty():
        return null

    var owner: DiscipleState = state.disciples[owner_id]
    var valence := float(profile["valence"])
    var base_importance := float(profile["importance"])
    var importance := _shape_importance(owner, valence, base_importance, player_linked)
    var owner_key := str(owner_id)
    var memories: Array = state.memories.get(owner_key, [])

    for value in memories:
        var existing: MemoryState = value
        if (
            existing.event_id == event_id
            and existing.target_id == target_id
            and existing.region_id == region_id
        ):
            existing.occurrences += 1
            existing.importance = minf(100.0, existing.importance + importance * 0.12)
            existing.last_event_tick = state.tick
            existing.player_linked = existing.player_linked or player_linked
            state.memory_event_count += 1
            state.memories[owner_key] = memories
            return existing

    state.memory_event_count += 1
    var memory := MemoryState.new({
        "id": "memory_%06d" % state.memory_event_count,
        "owner_id": str(owner_id),
        "event_id": str(event_id),
        "target_id": str(target_id),
        "region_id": str(region_id),
        "valence": valence,
        "importance": importance,
        "occurrences": 1,
        "created_tick": state.tick,
        "last_event_tick": state.tick,
        "player_linked": player_linked
    })
    memories.append(memory)
    state.memories[owner_key] = memories
    _trim_memories(state, owner_id)
    return memory

func record_combat_outcome(state: SimulationState, actor: DiscipleState, outcome: String) -> void:
    if not state.p1_memory_enabled or actor.region_id == &"sect":
        return

    match outcome:
        "win":
            record_event(state, actor.id, EVENT_PERSONAL_VICTORY, &"", actor.region_id)
        "retreat":
            record_event(state, actor.id, EVENT_PERSONAL_RETREAT, &"", actor.region_id)
        "defeat":
            record_event(state, actor.id, EVENT_PERSONAL_DEFEAT, &"", actor.region_id)
        _:
            return

    var source_map: Dictionary = state.relationships.get(str(actor.id), {})
    if source_map.is_empty():
        return

    var target_ids: Array = source_map.keys()
    target_ids.sort()
    var affected := 0
    for raw_target_id in target_ids:
        if affected >= MAX_LOCAL_CONTACTS:
            break
        var target_id := StringName(raw_target_id)
        var target: DiscipleState = state.disciples.get(target_id)
        if target == null or target.region_id != actor.region_id:
            continue

        var linked := _is_player_linked(state, actor.id, target.id)
        match outcome:
            "win":
                record_event(state, actor.id, EVENT_SHARED_VICTORY, target.id, actor.region_id, linked)
                record_event(state, target.id, EVENT_SHARED_VICTORY, actor.id, actor.region_id, linked)
            "retreat":
                record_event(state, target.id, EVENT_WITNESS_RETREAT, actor.id, actor.region_id, linked)
            "defeat":
                record_event(state, target.id, EVENT_WITNESS_DEFEAT, actor.id, actor.region_id, linked)
        affected += 1

func region_memory_modifier(state: SimulationState, disciple: DiscipleState, region_id: StringName) -> float:
    if not state.p1_memory_enabled:
        return 0.0

    var memories: Array = state.memories.get(str(disciple.id), [])
    if memories.is_empty():
        return 0.0

    var modifier := 0.0
    for value in memories:
        var memory: MemoryState = value
        var strength := memory.effective_strength(state.tick)

        if memory.region_id == region_id:
            match memory.event_id:
                EVENT_PERSONAL_VICTORY:
                    modifier += strength * 0.16
                EVENT_PERSONAL_RETREAT:
                    modifier += memory.valence * strength * 0.22
                EVENT_PERSONAL_DEFEAT:
                    modifier += memory.valence * strength * 0.26
                EVENT_SHARED_VICTORY:
                    modifier += strength * 0.06

        if memory.target_id == &"" or not state.disciples.has(memory.target_id):
            continue
        var target: DiscipleState = state.disciples[memory.target_id]
        var target_region := target.target_region_id if target.target_region_id != &"" else target.region_id
        if target_region != region_id:
            continue

        var social_weight := 0.0
        match memory.event_id:
            EVENT_SHARED_VICTORY:
                social_weight = 0.18
            EVENT_WITNESS_RETREAT:
                social_weight = 0.20
            EVENT_WITNESS_DEFEAT:
                social_weight = 0.22
            _:
                social_weight = 0.0
        if social_weight > 0.0:
            var linked_multiplier := 1.25 if memory.player_linked else 1.0
            modifier += memory.valence * strength * social_weight * linked_multiplier

    return clampf(modifier, -35.0, 35.0)

func memory_count(state: SimulationState, owner_id: StringName = &"") -> int:
    if owner_id != &"":
        var memories: Array = state.memories.get(str(owner_id), [])
        return memories.size()

    var total := 0
    for value in state.memories.values():
        if value is Array:
            total += value.size()
    return total

func _event_profile(event_id: StringName) -> Dictionary:
    match event_id:
        EVENT_PERSONAL_VICTORY:
            return {"valence": 1.0, "importance": 48.0}
        EVENT_PERSONAL_RETREAT:
            return {"valence": -0.65, "importance": 58.0}
        EVENT_PERSONAL_DEFEAT:
            return {"valence": -1.0, "importance": 72.0}
        EVENT_SHARED_VICTORY:
            return {"valence": 0.80, "importance": 58.0}
        EVENT_WITNESS_RETREAT:
            return {"valence": -0.45, "importance": 48.0}
        EVENT_WITNESS_DEFEAT:
            return {"valence": -0.70, "importance": 60.0}
        _:
            return {}

func _shape_importance(owner: DiscipleState, valence: float, base_importance: float, player_linked: bool) -> float:
    var shaped := base_importance
    if valence < 0.0:
        shaped *= 0.80 + clampf(owner.survival_bias, 0.0, 1.0) * 0.45
    else:
        shaped *= 0.80 + clampf(owner.risk_bias, 0.0, 1.0) * 0.35
    if player_linked:
        shaped += 12.0
    return clampf(shaped, 1.0, 100.0)

func _is_player_linked(state: SimulationState, left_id: StringName, right_id: StringName) -> bool:
    return (
        str(state.companion_assignments.get(str(left_id), "")) == str(right_id)
        or str(state.companion_assignments.get(str(right_id), "")) == str(left_id)
    )

func _trim_memories(state: SimulationState, owner_id: StringName) -> void:
    var owner_key := str(owner_id)
    var memories: Array = state.memories.get(owner_key, [])
    while memories.size() > MAX_MEMORIES_PER_DISCIPLE:
        var weakest_index := 0
        var weakest_score := 1.0e30
        for index in range(memories.size()):
            var memory: MemoryState = memories[index]
            var score := memory.effective_strength(state.tick) + float(memory.occurrences) * 3.0
            if memory.player_linked:
                score += 10.0
            if score < weakest_score:
                weakest_score = score
                weakest_index = index
        memories.remove_at(weakest_index)
    state.memories[owner_key] = memories
