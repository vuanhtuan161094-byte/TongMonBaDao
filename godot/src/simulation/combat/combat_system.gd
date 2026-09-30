class_name CombatSystem
extends RefCounted

var cultivation_system := CultivationSystem.new()
var technique_system := TechniqueSystem.new()

func resolve_encounter(state: SimulationState, disciple: DiscipleState, rng: GameRng) -> Dictionary:
    var region: RegionState = state.regions.get(disciple.region_id)
    if region == null:
        return {"outcome":"invalid", "loot":{}}

    var species_id := rng.weighted_pick(region.monster_weights)
    var definition: Dictionary = P0Content.MONSTERS.get(str(species_id), {})
    if definition.is_empty():
        return {"outcome":"invalid", "loot":{}}

    var monster_hp := float(definition.get("hp", 30.0))
    var monster_power := float(definition.get("power", 10.0))
    var effective_power := cultivation_system.effective_combat_power(state, disciple) if state.sect.cultivation_enabled else disciple.combat_power
    var damage_multiplier := technique_system.incoming_damage_multiplier(state, disciple) if state.sect.techniques_enabled else 1.0
    disciple.metrics["combats"] = int(disciple.metrics.get("combats", 0)) + 1

    for _round in range(20):
        if disciple.hp / maxf(disciple.max_hp, 1.0) <= disciple.retreat_hp_ratio():
            disciple.metrics["retreats"] = int(disciple.metrics.get("retreats", 0)) + 1
            return {"outcome":"retreat", "loot":{}}

        var dealt := effective_power * rng.randf_range(0.72, 1.28)
        monster_hp -= dealt
        if monster_hp <= 0.0:
            disciple.metrics["wins"] = int(disciple.metrics.get("wins", 0)) + 1
            return {
                "outcome":"win",
                "species_id":str(species_id),
                "monster_name":str(definition.get("name", species_id)),
                "loot":definition.get("loot", {}).duplicate(true)
            }

        var taken := monster_power * rng.randf_range(0.65, 1.22) * damage_multiplier
        disciple.hp = maxf(0.0, disciple.hp - taken)

        if disciple.hp <= 0.0:
            disciple.hp = 1.0
            disciple.metrics["defeats"] = int(disciple.metrics.get("defeats", 0)) + 1
            return {"outcome":"defeat", "loot":{}}

    disciple.metrics["retreats"] = int(disciple.metrics.get("retreats", 0)) + 1
    return {"outcome":"retreat", "loot":{}}
