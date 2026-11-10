class_name V63PoisonEvolutionV1
extends RefCounted

# PVB1: Authoritative, bounded mechanics for candidate Poison Nhân/Tiên/Thần.
# All V63 feature gates remain OFF by default. No SaveService/schema mutation.
const HEAL_WINDOW_SECONDS := 600.0
const DAMAGE_HISTORY_CAP := 256
const HEAL_HISTORY_CAP := 256
const HEAL_MAX_HP_FACTOR := 0.12
const HEAL_DAMAGE_FACTOR := 0.35
const CONSUME_RATIO_CAP := 0.60
const SPREAD_ICD_SECONDS := 6.0
const MARK_ICD_SECONDS := 8.0
const COUNTER_ICD_SECONDS := 12.0

static func predecessor_ready(definition: Dictionary, learned_nodes: Dictionary) -> bool:
    var parent_id := str(definition.get("parent_skill_id", ""))
    if parent_id.is_empty() or str(definition.get("school", "")) != "poison":
        return true
    return learned_nodes.has(parent_id)

static func rule_for_actor(actor: Dictionary) -> String:
    if str(actor.get("v63_combat_generation", "")) != "divine":
        return ""
    var branch := str(actor.get("v63_combat_branch_id", ""))
    var lineage := str(actor.get("v63_combat_lineage", ""))
    match branch + "/" + lineage:
        "doc_cham/a":
            return "owned_poison_maintain"
        "doc_cham/b":
            return "owned_poison_consume"
        "co_doc/a":
            return "single_spread_poison"
        "co_doc/b":
            return "marked_target_punish"
        "duoc_doc/a":
            return "cleanse_heal_fatal_save"
        "duoc_doc/b":
            return "removed_debuff_counter"
    return ""

static func remaining_tick_ratio(stacks: Array, owner_id: String, now: float) -> Dictionary:
    var count := 0
    var live := 0
    for raw in stacks:
        if raw is Dictionary and float(raw.get("expires_at", -1.0)) > now:
            live += 1
    var effective_count := float(mini(live, 12)) + float(clampi(live - 12, 0, 12)) * 0.5 \
        + float(maxi(0, live - 24)) * 0.25
    var fair_factor := effective_count / maxf(1.0, float(live))
    var remaining_ratio := 0.0
    for raw in stacks:
        if not (raw is Dictionary):
            continue
        var stack: Dictionary = raw
        if str(stack.get("owner_id", "")) != owner_id:
            continue
        var expires := float(stack.get("expires_at", -1.0))
        if expires <= now:
            continue
        count += 1
        var next_tick := maxf(now, float(stack.get("next_tick", now + 1.0)))
        var tick_count := clampi(ceili(maxf(0.0, expires - next_tick)), 0, 10)
        remaining_ratio += clampf(float(stack.get("ratio", 0.0)), 0.0, 0.20) * float(tick_count) * fair_factor
    return {"stacks":mini(count, 5), "ratio":maxf(0.0, remaining_ratio)}

static func consume_bonus_ratio(stacks: Array, owner_id: String, now: float) -> float:
    var budget := remaining_tick_ratio(stacks, owner_id, now)
    return minf(CONSUME_RATIO_CAP, float(budget.stacks) * 0.08 + float(budget.ratio) * 0.40)

static func _prune_receipts(raw: Array, now: float, cap: int) -> Array:
    var kept: Array = []
    for item in raw:
        if not (item is Dictionary):
            continue
        var stamped := float(item.get("time", -1.0))
        var amount := float(item.get("amount", 0.0))
        if stamped >= 0.0 and stamped <= now and stamped > now - HEAL_WINDOW_SECONDS \
                and amount > 0.0 and not is_nan(amount) and not is_inf(amount):
            kept.append({"time":stamped, "amount":amount})
    while kept.size() > cap:
        kept.pop_front()
    return kept

static func record_damage_taken(target: Dictionary, actual_damage: float, now: float) -> void:
    if str(target.get("side", "")) != "disciple" or not bool(target.get("v63_combat_enabled", false)):
        return
    if actual_damage <= 0.0 or is_nan(actual_damage) or is_inf(actual_damage):
        return
    var history := _prune_receipts(target.get("v63_poison_damage_receipts", []), now, DAMAGE_HISTORY_CAP - 1)
    history.append({"time":now, "amount":minf(actual_damage, maxf(1.0, float(target.get("max_hp", 1.0))))})
    target["v63_poison_damage_receipts"] = history

static func heal_capacity(target: Dictionary, now: float) -> float:
    var damages := _prune_receipts(target.get("v63_poison_damage_receipts", []), now, DAMAGE_HISTORY_CAP)
    var heals := _prune_receipts(target.get("v63_poison_heal_receipts", []), now, HEAL_HISTORY_CAP)
    var damage_total := 0.0
    var healed_total := 0.0
    for row in damages:
        damage_total += float(row.amount)
    for row in heals:
        healed_total += float(row.amount)
    var max_hp := maxf(1.0, float(target.get("max_hp", 1.0)))
    return maxf(0.0, minf(max_hp * HEAL_MAX_HP_FACTOR, damage_total * HEAL_DAMAGE_FACTOR) - healed_total)

static func heal_allowed(target: Dictionary, requested: float, now: float) -> float:
    if requested <= 0.0:
        return 0.0
    var damages := _prune_receipts(target.get("v63_poison_damage_receipts", []), now, DAMAGE_HISTORY_CAP)
    var heals := _prune_receipts(target.get("v63_poison_heal_receipts", []), now, HEAL_HISTORY_CAP)
    target["v63_poison_damage_receipts"] = damages
    target["v63_poison_heal_receipts"] = heals
    var damage_amount := 0.0
    var healed_amount := 0.0
    for row in damages:
        damage_amount += float(row.amount)
    for row in heals:
        healed_amount += float(row.amount)
    var max_hp := maxf(1.0, float(target.get("max_hp", 1.0)))
    var allowance := maxf(0.0, minf(max_hp * HEAL_MAX_HP_FACTOR, damage_amount * HEAL_DAMAGE_FACTOR) - healed_amount)
    var granted := minf(maxf(0.0, requested), allowance)
    if granted > 0.0:
        heals = _prune_receipts(heals, now, HEAL_HISTORY_CAP - 1)
        heals.append({"time":now, "amount":granted})
        target["v63_poison_heal_receipts"] = heals
    return granted

static func peek_mark_bonus(caster: Dictionary, target: Dictionary, now: float) -> float:
    if rule_for_actor(caster) != "marked_target_punish":
        return 0.0
    if now < float(caster.get("v63_poison_mark_ready_at", -1.0)):
        return 0.0
    var marks: Dictionary = target.get("v63_marks", {})
    var mark: Dictionary = marks.get(str(caster.get("id", "")), {})
    if mark.is_empty() or now >= float(mark.get("until", -1.0)):
        return 0.0
    return 0.12

static func commit_mark_bonus(caster: Dictionary, now: float) -> void:
    caster["v63_poison_mark_ready_at"] = now + MARK_ICD_SECONDS

# Isolated pure-math harness compatibility. Battle runtime uses peek+commit
# only after actual_damage > 0 to prevent spending a mark on dodged hits.
static func try_mark_bonus(caster: Dictionary, target: Dictionary, now: float) -> float:
    var bonus := peek_mark_bonus(caster, target, now)
    if bonus > 0.0:
        commit_mark_bonus(caster, now)
    return bonus

static func arm_cleanse_counter(caster: Dictionary, removed_count: int, now: float) -> bool:
    if rule_for_actor(caster) != "removed_debuff_counter" or removed_count <= 0:
        return false
    caster["v63_poison_counter_until"] = now + 5.0
    return true

static func peek_cleanse_counter(caster: Dictionary, now: float) -> float:
    if rule_for_actor(caster) != "removed_debuff_counter":
        return 0.0
    if now > float(caster.get("v63_poison_counter_until", -1.0)) \
            or now < float(caster.get("v63_poison_counter_ready_at", -1.0)):
        return 0.0
    return 0.08

static func commit_cleanse_counter(caster: Dictionary, now: float) -> void:
    caster.erase("v63_poison_counter_until")
    caster["v63_poison_counter_ready_at"] = now + COUNTER_ICD_SECONDS

static func consume_cleanse_counter(caster: Dictionary, now: float) -> float:
    var bonus := peek_cleanse_counter(caster, now)
    if bonus > 0.0:
        commit_cleanse_counter(caster, now)
    return bonus

static func refresh_oldest_owned_poison(target: Dictionary, owner_id: String, duration: float, now: float) -> bool:
    var statuses: Dictionary = target.get("status_effects", {})
    var stacks: Array = statuses.get("v63_poison", [])
    var oldest_index := -1
    var oldest_time := INF
    for index in range(stacks.size()):
        var s: Dictionary = stacks[index]
        if str(s.get("owner_id", "")) == owner_id and float(s.get("applied_at", INF)) < oldest_time:
            oldest_time = float(s.get("applied_at", INF))
            oldest_index = index
    if oldest_index < 0:
        return false
    var stack: Dictionary = stacks[oldest_index]
    stack["expires_at"] = minf(now + 10.0, maxf(float(stack.get("expires_at", now)), now + clampf(duration, 1.0, 10.0)))
    stacks[oldest_index] = stack
    statuses["v63_poison"] = stacks
    target["status_effects"] = statuses
    return true

static func spread_one(battle: MapBattleV2, caster: Dictionary, primary: Dictionary,
        skill_id: String, dot_ratio: float, duration: float, element: String) -> bool:
    if rule_for_actor(caster) != "single_spread_poison" \
            or battle.now < float(caster.get("v63_poison_spread_ready_at", -1.0)):
        return false
    var candidates: Array = []
    for raw_id in battle.actors.keys():
        var enemy: Dictionary = battle.actors[raw_id]
        if str(enemy.get("id", "")) == str(primary.get("id", "")) or \
                str(enemy.get("side", "")) == str(caster.get("side", "")) or float(enemy.get("hp", 0.0)) <= 0.0:
            continue
        var distance := (enemy.get("position", Vector2.ZERO) as Vector2).distance_to(primary.get("position", Vector2.ZERO))
        if distance <= 2.5:
            candidates.append({"id":str(enemy.id), "distance":distance})
    candidates.sort_custom(func(a: Dictionary,b: Dictionary):
        return float(a.distance) < float(b.distance) if not is_equal_approx(float(a.distance), float(b.distance)) else str(a.id) < str(b.id))
    if candidates.is_empty():
        return false
    var secondary: Dictionary = battle.actors[str(candidates[0].id)]
    caster["v63_poison_spread_ready_at"] = battle.now + SPREAD_ICD_SECONDS
    var before: int = secondary.get("status_effects", {}).get("v63_poison", []).size()
    V63HumanSkillCombatSystem._apply_poison(battle, caster, secondary, skill_id,
        clampf(dot_ratio * 0.65, 0.0, 0.20), minf(duration, 5.0), 1, element)
    var after: int = secondary.get("status_effects", {}).get("v63_poison", []).size()
    battle._event("v63_poison_spread", {"caster":str(caster.id),"source_skill_id":skill_id,
        "primary":str(primary.id),"secondary":str(secondary.id),"added":after-before})
    return after > before
