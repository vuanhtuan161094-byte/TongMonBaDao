class_name DiscipleCombatLoadoutV2
extends RefCounted

# Bridge from ACTUAL owned P2 gear and LEARNED P2 skills to a V2 actor.
# V2 realm/body progress remains explicit input until DV2-03 owns persistence.
# Never transform legacy "combat_power" into V2 ATK.
static func build(
    state: SimulationState, disciple: DiscipleState,
    realm: int, floor_index: int, body_realm: int, body_floor: int,
    role: String, position: Vector2, party_id: String
) -> Dictionary:
    if state == null or disciple == null or party_id.is_empty():
        return {"ok":false,"reason":"missing_state_disciple_or_party"}
    if not ["frontline","ranged","mage","healer"].has(role):
        return {"ok":false,"reason":"invalid_role"}
    var sources: Array = []
    var gear := EquipmentSystem.new()
    var basic_ratio_bonus := 0.0
    var range_bonus := 0.0
    var item_ids: Array = []
    if state.sect.equipment_enabled:
        for slot in EquipmentSystem.VALID_SLOTS:
            var item: Dictionary = gear.equipped_item(state,disciple,slot)
            if item.is_empty():
                continue
            var id := str(item.get("id",disciple.equipped_items.get(str(slot),"")))
            item_ids.append(id)
            var stat: Dictionary = item.get("stats",{})
            var prefix := "equipped/"+id
            if float(stat.get("defense_reduction",0.0)) > 0.0:
                sources.append({"source_id":prefix,"channel":"damage_reduction",
                    "mode":"remaining_reduction",
                    "value":clampf(float(stat["defense_reduction"]),0.0,0.99)})
            if float(stat.get("basic_speed",0.0)) != 0.0:
                sources.append({"source_id":prefix,"channel":"attack_speed",
                    "mode":"percent_add","value":float(stat["basic_speed"])})
            if float(stat.get("move_speed",0.0)) != 0.0:
                sources.append({"source_id":prefix,"channel":"move_speed",
                    "mode":"percent_add","value":float(stat["move_speed"])})
            range_bonus += float(stat.get("basic_range",0.0))
            basic_ratio_bonus += float(stat.get("basic_ratio",0.0))
            # "combat_power" and skill_effect are NOT global ATK channels.
    var calculated := CombatStatsV2.derive(
        realm,floor_index,body_realm,body_floor,disciple.potential,sources
    )
    if not bool(calculated.get("ok",false)):
        return calculated
    var stats: Dictionary = calculated["stats"]
    var style := CombatSkillSystem.new().style_profile(state,disciple)
    var basic_range := maxf(0.5,float(style.get("basic_range",1.5))+range_bonus)
    var basic_ratio := maxf(0.1,float(style.get("basic_ratio",1.0))*(1.0+basic_ratio_bonus))
    var move_speed := maxf(0.1,float(style.get("move_speed",2.5))*float(stats["move_speed"]))
    var base_interval := maxf(0.25,float(style.get("basic_interval",1.6)))
    var learned_damage_skills: Array = []
    var skill_factors: Dictionary = {}
    var deferred_skills: Array = []
    if state.sect.combat_skills_enabled:
        var skill_system := CombatSkillSystem.new()
        for skill_id in skill_system.usable_skills(state,disciple):
            var definition := skill_system.definition(skill_id)
            if str(definition.get("effect","")) != "damage":
                deferred_skills.append(str(skill_id))
                continue
            var factor := skill_system.effect_multiplier(state,disciple,skill_id)
            if state.sect.equipment_enabled:
                factor *= gear.skill_effect_multiplier(
                    state,disciple,StringName(definition["path"]),StringName(definition["element"])
                )
            learned_damage_skills.append(str(skill_id))
            skill_factors[str(skill_id)] = factor
    learned_damage_skills.sort()
    # Source attribution retained for player breakdown; no hidden gear buff.
    # Legacy and V2 HP scales differ. Do not mutate persistent DiscipleState.hp
    # until the V2 max-HP migration commits its own correct ratio authority.
    var safe_live_link = disciple if is_equal_approx(disciple.max_hp,float(stats["max_hp"])) else null
    return {
        "ok":true,"id":str(disciple.id),"party_id":party_id,
        "role":role,"position":position,"disciple":safe_live_link,
        "origin_disciple_id":str(disciple.id),
        # Read-only source identity for the fight HUD and lossless replay.
        # These are the SAME validated 30x10 coordinates passed to derive.
        "display_name":disciple.display_name,
        "realm_index":realm,"floor_index":floor_index,
        "body_realm_index":body_realm,"body_floor_index":body_floor,
        "hp":CombatStatsV2.rescale_current_hp(
            disciple.hp,maxf(0.0001,disciple.max_hp),float(stats["max_hp"])
        ),
        "stats":stats,"resistances":calculated["resistances"],
        "stat_breakdown":calculated["core_breakdown"],
        "applied_sources":calculated["applied_sources"],
        "equipped_item_ids":item_ids,
        "basic_range":basic_range,"basic_ratio":basic_ratio,
        "move_speed":move_speed,"basic_interval":base_interval,
        "skill_loadout":learned_damage_skills,
        "skill_factors":skill_factors,
        "deferred_skill_ids":deferred_skills
    }
