class_name RelationshipSystem
extends RefCounted

const INITIAL_CONTACTS_PER_DISCIPLE := 2
const MAX_EVENT_CONTACTS := 3

func seed_initial_network(state: SimulationState, contacts_per_disciple: int = INITIAL_CONTACTS_PER_DISCIPLE) -> void:
    if not state.p1_relationships_enabled:
        return

    var ids: Array = state.disciples.keys()
    ids.sort()
    if ids.size() < 2:
        return

    var contact_count := mini(maxi(contacts_per_disciple, 0), ids.size() - 1)
    for source_index in range(ids.size()):
        var source_id := StringName(ids[source_index])
        for offset in range(1, contact_count + 1):
            var target_id := StringName(ids[(source_index + offset) % ids.size()])
            _seed_relation(state, source_id, target_id, offset)

func introduce_new_disciple(state: SimulationState, disciple: DiscipleState) -> void:
    if not state.p1_relationships_enabled:
        return

    var ids: Array = state.disciples.keys()
    ids.sort()
    var others: Array[StringName] = []
    for raw_id in ids:
        var other_id := StringName(raw_id)
        if other_id != disciple.id:
            others.append(other_id)

    var contact_count := mini(INITIAL_CONTACTS_PER_DISCIPLE, others.size())
    for index in range(contact_count):
        var target_id := others[index]
        _seed_relation(state, disciple.id, target_id, index + 1)
        _seed_relation(state, target_id, disciple.id, index + 7)

func get_relation(state: SimulationState, source_id: StringName, target_id: StringName, create_if_missing: bool = false) -> RelationshipState:
    if source_id == target_id:
        return null

    var source_key := str(source_id)
    var target_key := str(target_id)
    var source_map: Dictionary = state.relationships.get(source_key, {})
    if source_map.has(target_key):
        return source_map[target_key]
    if not create_if_missing:
        return null

    var relation := RelationshipState.new({
        "source_id": source_key,
        "target_id": target_key
    })
    source_map[target_key] = relation
    state.relationships[source_key] = source_map
    return relation

func apply_event(state: SimulationState, source_id: StringName, target_id: StringName, event_id: StringName) -> bool:
    if not state.p1_relationships_enabled:
        return false
    if source_id == target_id:
        return false
    if not state.disciples.has(source_id) or not state.disciples.has(target_id):
        return false

    var source: DiscipleState = state.disciples[source_id]
    var relation := get_relation(state, source_id, target_id, true)
    var affinity_delta := 0.0
    var trust_delta := 0.0
    var respect_delta := 0.0

    match event_id:
        &"shared_success":
            affinity_delta = 4.0
            trust_delta = 6.0
            respect_delta = 4.0
        &"reliable_support":
            affinity_delta = 3.0
            trust_delta = 8.0
            respect_delta = 2.0
        &"admire_strength":
            affinity_delta = 1.0
            trust_delta = 1.0
            respect_delta = 8.0
        &"conflict":
            affinity_delta = -8.0
            trust_delta = -7.0
            respect_delta = -2.0
        &"witness_retreat":
            affinity_delta = 1.0
            trust_delta = -2.0
            respect_delta = -1.0
        &"witness_defeat":
            affinity_delta = 2.0
            trust_delta = -3.0
            respect_delta = -2.0
        _:
            return false

    if trust_delta > 0.0:
        trust_delta *= lerpf(1.0, 0.55, clampf(source.survival_bias, 0.0, 1.0))
    elif trust_delta < 0.0:
        trust_delta *= 1.0 + clampf(source.survival_bias, 0.0, 1.0) * 0.35

    if respect_delta > 0.0:
        respect_delta *= 0.80 + clampf(source.risk_bias, 0.0, 1.0) * 0.50

    relation.affinity = clampf(relation.affinity + affinity_delta, 0.0, 100.0)
    relation.trust = clampf(relation.trust + trust_delta, 0.0, 100.0)
    relation.respect = clampf(relation.respect + respect_delta, 0.0, 100.0)
    relation.interactions += 1
    relation.last_event_tick = state.tick
    relation.last_event = event_id
    state.relationship_event_count += 1
    return true

func assign_companion(state: SimulationState, source_id: StringName, target_id: StringName) -> bool:
    if not state.p1_relationships_enabled:
        return false
    if source_id == target_id:
        return false
    if not state.disciples.has(source_id) or not state.disciples.has(target_id):
        return false

    get_relation(state, source_id, target_id, true)
    state.companion_assignments[str(source_id)] = str(target_id)
    return true

func clear_companion(state: SimulationState, source_id: StringName) -> void:
    state.companion_assignments.erase(str(source_id))

func region_social_modifier(state: SimulationState, disciple: DiscipleState, region_id: StringName) -> float:
    if not state.p1_relationships_enabled:
        return 0.0

    var source_map: Dictionary = state.relationships.get(str(disciple.id), {})
    if source_map.is_empty():
        return 0.0

    var assigned_target := str(state.companion_assignments.get(str(disciple.id), ""))
    var target_ids: Array = source_map.keys()
    target_ids.sort()
    var modifier := 0.0

    for raw_target_id in target_ids:
        var target_id := StringName(raw_target_id)
        var target: DiscipleState = state.disciples.get(target_id)
        if target == null:
            continue

        var target_region := target.target_region_id if target.target_region_id != &"" else target.region_id
        if target_region != region_id:
            continue

        var relation: RelationshipState = source_map[str(target_id)]
        var deviation := relation.composite_deviation()
        modifier += clampf(deviation * 0.40, -20.0, 20.0)

        if assigned_target == str(target_id):
            modifier += 8.0 + clampf(deviation * 0.35, -17.5, 17.5)

    return clampf(modifier, -35.0, 45.0)

func record_local_combat_outcome(state: SimulationState, actor: DiscipleState, outcome: String) -> void:
    if not state.p1_relationships_enabled or actor.region_id == &"sect":
        return

    var source_map: Dictionary = state.relationships.get(str(actor.id), {})
    if source_map.is_empty():
        return

    var target_ids: Array = source_map.keys()
    target_ids.sort()
    var affected := 0
    for raw_target_id in target_ids:
        if affected >= MAX_EVENT_CONTACTS:
            break
        var target_id := StringName(raw_target_id)
        var target: DiscipleState = state.disciples.get(target_id)
        if target == null or target.region_id != actor.region_id:
            continue

        match outcome:
            "win":
                apply_event(state, actor.id, target.id, &"shared_success")
                apply_event(state, target.id, actor.id, &"admire_strength")
            "retreat":
                apply_event(state, target.id, actor.id, &"witness_retreat")
            "defeat":
                apply_event(state, target.id, actor.id, &"witness_defeat")
            _:
                continue
        affected += 1

func relationship_count(state: SimulationState) -> int:
    var total := 0
    for source_value in state.relationships.values():
        if source_value is Dictionary:
            total += source_value.size()
    return total

func _seed_relation(state: SimulationState, source_id: StringName, target_id: StringName, salt: int) -> void:
    if get_relation(state, source_id, target_id, false) != null:
        return
    if not state.disciples.has(source_id) or not state.disciples.has(target_id):
        return

    var source: DiscipleState = state.disciples[source_id]
    var target: DiscipleState = state.disciples[target_id]
    var seed_value := state.seed + _stable_id_value(str(source_id)) * 31 + _stable_id_value(str(target_id)) * 17 + salt * 104729
    var rng := GameRng.new(seed_value)
    var relation := get_relation(state, source_id, target_id, true)
    relation.affinity = rng.randf_range(44.0, 58.0)
    relation.trust = clampf(rng.randf_range(45.0, 58.0) - source.survival_bias * 4.0, 0.0, 100.0)
    relation.respect = clampf(50.0 + (target.combat_power - source.combat_power) * 1.2 + rng.randf_range(-5.0, 5.0), 0.0, 100.0)

func _stable_id_value(value: String) -> int:
    var result: int = 17
    for index in range(value.length()):
        result = int((result * 131 + value.unicode_at(index)) % 1000003)
    return result
