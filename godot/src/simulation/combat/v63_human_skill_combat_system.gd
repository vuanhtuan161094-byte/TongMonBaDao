class_name V63HumanSkillCombatSystem
extends RefCounted

const CATALOGUE_PATH := "res://data/combat/v63_human_combat_catalog.json"
const MAX_SKILLS_PER_DISCIPLE := 12

static func load_catalogue(path: String = CATALOGUE_PATH) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {"ok":false,"errors":["cannot_open_human_combat_catalogue"],"data":{}}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary):
        return {"ok":false,"errors":["human_combat_catalogue_not_object"],"data":{}}
    var errors := validate_catalogue(parsed)
    return {"ok":errors.is_empty(),"errors":errors,"data":parsed}

static func validate_catalogue(data: Dictionary) -> Array[String]:
    var errors: Array[String] = []
    if int(data.get("schema_version",-1)) != 1 or bool(data.get("enabled",true)):
        errors.append("bad_human_combat_schema_or_release_gate")
    var skills = data.get("skills",null)
    var bosses = data.get("bosses",null)
    if not (skills is Array) or not (bosses is Array):
        errors.append("missing_human_combat_arrays")
        return errors
    var ids: Dictionary = {}
    for raw in skills:
        if not (raw is Dictionary):
            errors.append("human_skill_not_object")
            continue
        var id := str(raw.get("id",""))
        if not _valid_id(id) or ids.has(id):
            errors.append("bad_or_duplicate_human_skill:"+id)
        ids[id] = true
        if str(raw.get("tier","")) != "human" or str(raw.get("effect","")) != "damage":
            errors.append("unsupported_human_skill_effect:"+id)
        if str(raw.get("source_codex_id","")).is_empty() or str(raw.get("node_id","")).is_empty():
            errors.append("human_skill_missing_learning_identity:"+id)
        if str(raw.get("slot","")) not in ["basic","active","ultimate","mobility","passive"]:
            errors.append("human_skill_bad_slot:"+id)
        if float(raw.get("damage_ratio",0.0)) <= 0.0 or float(raw.get("range",0.0)) <= 0.0 or float(raw.get("cast_time",-1.0)) < 0.0 or float(raw.get("cooldown",0.0)) <= 0.0 or float(raw.get("projectile_speed",0.0)) < 0.0 or not CombatStatsV2.ELEMENTS.has(str(raw.get("element",""))):
            errors.append("human_skill_bad_action_values:"+id)
    var boss_ids: Dictionary = {}
    for raw_boss in bosses:
        if not (raw_boss is Dictionary):
            errors.append("human_boss_not_object")
            continue
        var boss_id := str(raw_boss.get("id",""))
        if not _valid_id(boss_id) or boss_ids.has(boss_id):
            errors.append("bad_or_duplicate_human_boss:"+boss_id)
        boss_ids[boss_id] = true
        if str(raw_boss.get("tier_band","")) != "human" or not MonsterCatalogueV2.SPECIES.has(str(raw_boss.get("origin_species_id",""))):
            errors.append("human_boss_missing_human_tier_or_source_species:"+boss_id)
        var thresholds = raw_boss.get("phase_thresholds",[])
        if not (thresholds is Array) or thresholds.size() != 2 or float(thresholds[0]) >= 1.0 or float(thresholds[0]) <= float(thresholds[1]) or float(thresholds[1]) <= 0.0:
            errors.append("human_boss_bad_phase_thresholds:"+boss_id)
        var boss_skills = raw_boss.get("skills",[])
        if not (boss_skills is Array) or boss_skills.is_empty():
            errors.append("human_boss_missing_skills:"+boss_id)
            continue
        var observed: Array = []
        for raw_skill in boss_skills:
            if not (raw_skill is Dictionary):
                errors.append("human_boss_skill_not_object:"+boss_id)
                continue
            var skill_id := str(raw_skill.get("id",""))
            if not skill_id.begins_with("tmb.bossskill.") or observed.has(skill_id):
                errors.append("bad_or_duplicate_human_boss_skill:"+skill_id)
            observed.append(skill_id)
            if not ["circle","single_target"].has(str(raw_skill.get("shape",""))):
                errors.append("unsupported_human_boss_shape:"+skill_id)
            if float(raw_skill.get("damage_ratio",0.0)) <= 0.0 or float(raw_skill.get("range",0.0)) <= 0.0 or float(raw_skill.get("cast_time",0.0)) <= 0.0 or float(raw_skill.get("cooldown",0.0)) <= 0.0 or float(raw_skill.get("radius",-1.0)) < 0.0 or int(raw_skill.get("target_limit",0)) < 1 or not CombatStatsV2.ELEMENTS.has(str(raw_skill.get("element",""))):
                errors.append("human_boss_bad_action_values:"+skill_id)
        if not (raw_boss.get("skill_ids",[]) is Array) or raw_boss.skill_ids != observed:
            errors.append("human_boss_skill_index_mismatch:"+boss_id)
    if skills.is_empty() or bosses.is_empty():
        errors.append("empty_human_combat_pilot")
    return errors

static func is_enabled(state: SimulationState, preview_overrides: Dictionary = {}) -> bool:
    return state != null and state.sect.v63_skill_combat_opt_in and V63FeatureGates.is_enabled("human_skill_combat",preview_overrides)

static func skill_definitions() -> Dictionary:
    var result: Dictionary = {}
    var loaded := load_catalogue()
    if bool(loaded.get("ok",false)):
        for row in loaded.data.skills:
            result[str(row.id)] = row.duplicate(true)
    return result

static func skill_definition(skill_id: String) -> Dictionary:
    return skill_definitions().get(skill_id,{})

static func boss_definition(boss_id: String) -> Dictionary:
    var loaded := load_catalogue()
    if not bool(loaded.get("ok",false)):
        return {}
    for row in loaded.data.bosses:
        if str(row.get("id","")) == boss_id:
            return row.duplicate(true)
    return {}

static func boss_skill_definitions(boss_id: String) -> Dictionary:
    var result: Dictionary = {}
    for row in boss_definition(boss_id).get("skills",[]):
        result[str(row.get("id",""))] = row.duplicate(true)
    return result

static func learn_skill(state: SimulationState, disciple: DiscipleState, skill_id: String, preview_overrides: Dictionary = {}) -> Dictionary:
    if not is_enabled(state,preview_overrides):
        return _failure("human_skill_combat_disabled")
    if disciple == null or not state.disciples.has(disciple.id):
        return _failure("unknown_disciple")
    var definition := skill_definition(skill_id)
    if definition.is_empty():
        return _failure("unknown_human_skill")
    var codex_id := str(definition.get("source_codex_id",""))
    if not V63SectArchiveSystem.transmission_available_for_disciple(state,disciple.id,codex_id,preview_overrides):
        return _failure("required_manual_not_archived")
    if disciple.v63_learned_skill_nodes.has(skill_id):
        return {"ok":true,"duplicate":true,"skill_id":skill_id}
    disciple.v63_learned_skill_nodes[skill_id] = {"source_codex_id":codex_id,"learned_tick":maxi(state.tick,0),"mastery_xp":0.0}
    return {"ok":true,"skill_id":skill_id,"codex_id":codex_id}

static func equip_skill(state: SimulationState, disciple: DiscipleState, skill_id: String, preview_overrides: Dictionary = {}) -> Dictionary:
    if not is_enabled(state,preview_overrides):
        return _failure("human_skill_combat_disabled")
    if disciple == null or not state.disciples.has(disciple.id):
        return _failure("unknown_disciple")
    var definition := skill_definition(skill_id)
    if definition.is_empty() or not disciple.v63_learned_skill_nodes.has(skill_id) or str(definition.get("effect","")) != "damage":
        return _failure("skill_not_personally_learned")
    if disciple.v63_equipped_skill_ids.has(skill_id):
        return {"ok":true,"duplicate":true,"skill_id":skill_id}
    var slot := str(definition.get("slot",""))
    var limit := 4 if slot == "active" else (1 if slot in ["basic","ultimate","mobility"] else 5)
    var same_slot := 0
    for existing in disciple.v63_equipped_skill_ids:
        if str(skill_definition(str(existing)).get("slot","")) == slot:
            same_slot += 1
    if same_slot >= limit or disciple.v63_equipped_skill_ids.size() >= MAX_SKILLS_PER_DISCIPLE:
        return _failure("skill_slot_full")
    disciple.v63_equipped_skill_ids.append(skill_id)
    disciple.v63_equipped_skill_ids.sort()
    return {"ok":true,"skill_id":skill_id,"slot":slot}

static func attach_disciple_loadout(state: SimulationState, actor: Dictionary, preview_overrides: Dictionary = {}) -> Dictionary:
    if not is_enabled(state,preview_overrides):
        return {"ok":true,"attached":false}
    var id := StringName(str(actor.get("id","")))
    if not state.disciples.has(id):
        return _failure("unknown_disciple")
    var disciple: DiscipleState = state.disciples[id]
    var definitions := skill_definitions()
    var skills: Array = []
    for raw_id in disciple.v63_equipped_skill_ids:
        var skill_id := str(raw_id)
        if disciple.v63_learned_skill_nodes.has(skill_id) and definitions.has(skill_id):
            skills.append(skill_id)
    skills.sort()
    actor["v63_skill_loadout"] = skills
    actor["v63_skill_ready"] = {}
    actor["v63_combat_enabled"] = true
    return {"ok":true,"attached":not skills.is_empty(),"skill_ids":skills}

static func handles_actor(actor: Dictionary) -> bool:
    return bool(actor.get("v63_custom_boss_ai",false)) or not actor.get("v63_skill_loadout",[]).is_empty()

static func try_cast(battle: MapBattleV2, actor: Dictionary, target: Dictionary, guard_only: bool = false) -> bool:
    if guard_only or battle == null or target.is_empty() or not bool(actor.get("v63_combat_enabled",false)):
        return false
    if str(actor.get("side","")) == "monster" and bool(actor.get("v63_custom_boss_ai",false)):
        return _try_boss_cast(battle,actor,target)
    return _try_human_cast(battle,actor,target)

static func _try_human_cast(battle: MapBattleV2, actor: Dictionary, target: Dictionary) -> bool:
    var definitions := skill_definitions()
    var ready: Dictionary = actor.get("v63_skill_ready",{})
    for raw_id in actor.get("v63_skill_loadout",[]):
        var skill_id := str(raw_id)
        var definition: Dictionary = definitions.get(skill_id,{})
        if definition.is_empty() or battle.now < float(ready.get(skill_id,0.0)) or str(target.get("side","")) == str(actor.get("side","")):
            continue
        var distance := (actor["position"] as Vector2).distance_to(target["position"])
        if distance > float(definition.get("range",0.0)):
            continue
        var stats: Dictionary = actor.get("stats",{})
        var cast_rate := maxf(0.1,1.0+float(stats.get("cast_speed",0.0)))
        var cooldown_rate := maxf(0.1,1.0+float(stats.get("cooldown_recovery",0.0)))
        var seconds := maxf(MapBattleV2.STEP_SECONDS,float(definition.get("cast_time",0.0))/cast_rate)
        var speed := float(definition.get("projectile_speed",0.0))
        var ready_at := battle.now+seconds+(distance/speed if speed > 0.0 else 0.0)
        actor["v63_pending_cast"] = {"caster":str(actor["id"]),"target_id":str(target["id"]),"v63_skill_id":skill_id,"ready":ready_at,"ratio":float(definition.damage_ratio),"element":str(definition.element)}
        ready[skill_id] = battle.now+maxf(MapBattleV2.STEP_SECONDS,float(definition.cooldown)/cooldown_rate)
        actor["v63_skill_ready"] = ready
        actor["next_skill"] = battle.now+MapBattleV2.STEP_SECONDS
        battle._event("skill_cast",{"actor_id":str(actor["id"]),"target":str(target["id"]),"skill_id":skill_id,"release_at":ready_at,"combat_family":"v63_human"})
        battle.actions += 1
        return true
    return false

static func _try_boss_cast(battle: MapBattleV2, actor: Dictionary, target: Dictionary) -> bool:
    var boss_id := str(actor.get("v63_boss_id",""))
    var boss := boss_definition(boss_id)
    var definitions := boss_skill_definitions(boss_id)
    var ready: Dictionary = actor.get("v63_skill_ready",{})
    var phase := clampi(int(actor.get("v63_boss_phase",1)),1,3)
    for raw_id in boss.get("skill_ids",[]):
        var skill_id := str(raw_id)
        var skill: Dictionary = definitions.get(skill_id,{})
        if skill.is_empty() or phase < int(skill.get("minimum_phase",1)) or battle.now < float(ready.get(skill_id,0.0)):
            continue
        var distance := (actor["position"] as Vector2).distance_to(target["position"])
        if distance > float(skill.get("range",0.0)):
            continue
        var stats: Dictionary = actor.get("stats",{})
        var cast_rate := maxf(0.1,1.0+float(stats.get("cast_speed",0.0)))
        var cooldown_rate := maxf(0.1,1.0+float(stats.get("cooldown_recovery",0.0)))
        var ready_at := battle.now+maxf(MapBattleV2.STEP_SECONDS,float(skill.cast_time)/cast_rate)
        var center: Vector2 = target["position"]
        var cast := {"caster":str(actor["id"]),"target_id":str(target["id"]),"v63_skill_id":skill_id,"v63_boss_id":boss_id,"ready":ready_at,"ratio":float(skill.damage_ratio),"element":str(skill.element),"shape":str(skill.shape),"maximum":mini(int(skill.target_limit),MapBattleV2.MAX_TARGETS_AOE)}
        if str(skill.shape) == "circle":
            cast["center"] = center
            cast["radius"] = float(skill.radius)
        actor["v63_pending_cast"] = cast
        ready[skill_id] = battle.now+maxf(MapBattleV2.STEP_SECONDS,float(skill.cooldown)/cooldown_rate)
        actor["v63_skill_ready"] = ready
        actor["next_skill"] = battle.now+MapBattleV2.STEP_SECONDS
        battle._event("telegraph",{"caster":str(actor["id"]),"boss_id":boss_id,"skill":skill_id,"skill_id":skill_id,"center":center,"radius":float(skill.radius),"release_at":ready_at})
        battle.actions += 1
        return true
    return false

static func release_cast(battle: MapBattleV2, cast: Dictionary, caster: Dictionary) -> void:
    var skill_id := str(cast.get("v63_skill_id",""))
    var boss_id := str(cast.get("v63_boss_id",""))
    var definition: Dictionary = boss_skill_definitions(boss_id).get(skill_id,{}) if not boss_id.is_empty() else skill_definition(skill_id)
    if definition.is_empty():
        return
    var targets: Array = []
    if str(cast.get("shape","")) == "circle":
        targets = battle._area_targets(str(caster.get("side","")),cast.get("center",Vector2.ZERO),float(cast.get("radius",0.0)),mini(int(cast.get("maximum",1)),MapBattleV2.MAX_TARGETS_AOE))
    else:
        var target: Dictionary = battle.actors.get(str(cast.get("target_id","")),{})
        if not target.is_empty() and str(target.get("side","")) != str(caster.get("side","")):
            targets.append(target)
    for target in targets:
        if float(target.get("hp",0.0)) <= 0.0 or str(target.get("side","")) == str(caster.get("side","")):
            continue
        var hp_before := float(target["hp"])
        var damage := battle._deal_direct(caster,target,float(cast.get("ratio",0.0)),"v63_skill",true,str(cast.get("element","")))
        battle._event("v63_skill_hit",{"caster":str(caster.id),"target":str(target.id),"skill_id":skill_id,"damage":damage,"target_hp_before":hp_before,"target_hp_after":float(target.hp)})

static func observe_boss_damage(battle: MapBattleV2, actor: Dictionary, hp_before: float) -> void:
    if battle == null or not bool(actor.get("v63_custom_boss_ai",false)):
        return
    var definition := boss_definition(str(actor.get("v63_boss_id","")))
    var thresholds: Array = definition.get("phase_thresholds",[0.7,0.35])
    var ratio := float(actor.get("hp",0.0))/maxf(1.0,float(actor.get("max_hp",1.0)))
    var phase := clampi(int(actor.get("v63_boss_phase",1)),1,3)
    var next_phase := 3 if ratio <= float(thresholds[1]) and phase < 3 else (2 if ratio <= float(thresholds[0]) and phase < 2 else phase)
    if next_phase > phase:
        actor["v63_boss_phase"] = next_phase
        battle._event("v63_boss_phase",{"boss_id":str(actor.get("v63_boss_id","")),"actor_id":str(actor.id),"phase":next_phase,"hp_before":hp_before,"hp_after":float(actor.hp),"hp_ratio":ratio})

static func install_boss_spawn(spawn_data: Dictionary, boss_id: String) -> Dictionary:
    var boss := boss_definition(boss_id)
    var monsters = spawn_data.get("monsters",null)
    if boss.is_empty() or not bool(spawn_data.get("ok",false)) or not (monsters is Array) or monsters.is_empty():
        return _failure("unknown_boss_or_spawn")
    var region_id := str(spawn_data.get("region_id",""))
    var level := int(spawn_data.get("level",0))
    if not HuntingMapV2.valid_choice(region_id,level):
        return _failure("boss_spawn_map_identity_invalid")
    var region: Dictionary = HuntingMapV2.REGION_CONTENT[region_id]
    var row: Dictionary = monsters[0]
    var origin := MonsterCatalogueV2.create_actor(str(boss.origin_species_id),int(region.realm),int(region.floor),str(spawn_data.encounter_id)+"/v63_boss")
    if not bool(origin.get("ok",false)):
        return origin
    var spec: Dictionary = HuntingMapV2.LEVELS[level]
    var base_factor: Dictionary = MonsterCatalogueV2.TIERS[str(origin.tier)]
    var boss_factor: Dictionary = MonsterCatalogueV2.TIERS["boss"]
    var stats: Dictionary = origin.stats.duplicate(true)
    for stat in ["max_hp","attack","defense"]:
        var difficulty_key: String = "hp" if stat == "max_hp" else stat
        stats[stat] = float(stats[stat])*float(spec[difficulty_key])*float(boss_factor[stat])/maxf(0.001,float(base_factor[stat]))*float(boss.get("boss_"+("hp" if stat == "max_hp" else stat)+"_factor",1.0))
    origin["id"] = str(row.get("id",""))
    origin["encounter_id"] = str(spawn_data.encounter_id)+"/"+str(row.get("id",""))
    origin["position"] = row.get("position",Vector2(23,8))
    origin["region_id"] = region_id
    origin["difficulty_level"] = level
    origin["tier"] = "boss"
    origin["stats"] = stats
    origin["hp"] = float(stats.max_hp)
    origin["v63_boss_id"] = boss_id
    origin["v63_custom_boss_ai"] = true
    origin["v63_combat_enabled"] = true
    origin["v63_boss_phase"] = 1
    origin["v63_skill_ready"] = {}
    var result: Dictionary = spawn_data.duplicate(true)
    var updated: Array = monsters.duplicate(true)
    updated[0] = origin
    result["monsters"] = updated
    result["has_boss"] = true
    result["v63_boss_id"] = boss_id
    return {"ok":true,"spawn_data":result,"boss_actor":origin.duplicate(true)}

static func validate_battle(battle: MapBattleV2, expected_boss_id: String = "") -> Array[String]:
    var errors: Array[String] = []
    if battle == null:
        errors.append("missing_human_battle")
        return errors
    var observed_boss := ""
    for raw_id in battle.actors.keys():
        var actor: Dictionary = battle.actors[raw_id]
        var loadout = actor.get("v63_skill_loadout",[])
        var ready = actor.get("v63_skill_ready",{})
        if not (loadout is Array) or not (ready is Dictionary):
            errors.append("invalid_v63_actor_action_state:"+str(raw_id))
            continue
        var custom_boss := bool(actor.get("v63_custom_boss_ai",false))
        var boss_id := str(actor.get("v63_boss_id",""))
        var valid_actions: Dictionary = {}
        if custom_boss:
            var boss := boss_definition(boss_id)
            if boss.is_empty() or not observed_boss.is_empty():
                errors.append("unknown_or_duplicate_v63_boss:"+boss_id)
            else:
                var species: Dictionary = MonsterCatalogueV2.SPECIES.get(str(boss.get("origin_species_id","")),{})
                if str(actor.get("race_id","")) != str(species.get("race_id","")) or str(actor.get("tier","")) != "boss":
                    errors.append("v63_boss_identity_mismatch:"+boss_id)
                for skill_id in boss.get("skill_ids",[]):
                    valid_actions[str(skill_id)] = true
            observed_boss = boss_id
        elif not boss_id.is_empty():
            errors.append("v63_boss_marker_without_ai:"+str(raw_id))
        for raw_skill_id in loadout:
            var skill_id := str(raw_skill_id)
            if skill_definition(skill_id).is_empty() or valid_actions.has(skill_id):
                errors.append("unknown_or_duplicate_v63_actor_skill:"+skill_id)
            valid_actions[skill_id] = true
        for ready_id in ready.keys():
            var ready_value = ready[ready_id]
            if (not valid_actions.has(str(ready_id)) or not (ready_value is int or ready_value is float) or
                is_nan(float(ready_value)) or is_inf(float(ready_value)) or float(ready_value) < 0.0 or
                float(ready_value) > battle.now+90.0):
                errors.append("invalid_v63_skill_cooldown:"+str(ready_id))
        var pending = actor.get("v63_pending_cast",{})
        if not (pending is Dictionary):
            errors.append("invalid_v63_pending_cast_record:"+str(raw_id))
        elif not pending.is_empty():
            var cast_id := str(pending.get("v63_skill_id",""))
            var cast_boss_id := str(pending.get("v63_boss_id",""))
            var definition: Dictionary = boss_skill_definitions(cast_boss_id).get(cast_id,{}) if not cast_boss_id.is_empty() else skill_definition(cast_id)
            var target_id := str(pending.get("target_id",""))
            var target: Dictionary = battle.actors.get(target_id,{})
            var deadline = pending.get("ready",null)
            var ratio := float(pending.get("ratio",-1.0))
            var valid_identity := not definition.is_empty() and valid_actions.has(cast_id)
            if custom_boss:
                valid_identity = valid_identity and cast_boss_id == boss_id and str(pending.get("shape","")) == str(definition.get("shape",""))
            else:
                valid_identity = valid_identity and cast_boss_id.is_empty() and str(pending.get("shape","")).is_empty()
            if (not valid_identity or str(pending.get("caster","")) != str(raw_id) or target.is_empty() or
                str(target.get("side","")) == str(actor.get("side","")) or
                not (deadline is int or deadline is float) or is_nan(float(deadline)) or is_inf(float(deadline)) or
                float(deadline) < battle.now or float(deadline) > battle.now+90.0 or
                is_nan(ratio) or is_inf(ratio) or ratio <= 0.0 or ratio > 1000.0 or
                not CombatStatsV2.ELEMENTS.has(str(pending.get("element","")))):
                errors.append("invalid_v63_pending_cast:"+cast_id)
    if expected_boss_id.is_empty() and not observed_boss.is_empty():
        errors.append("unexpected_v63_boss")
    elif not expected_boss_id.is_empty() and observed_boss != expected_boss_id:
        errors.append("v63_boss_identity_mismatch")
    return errors
static func validate_state(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if state == null:
        return ["missing_human_combat_state"]
    var loaded := load_catalogue()
    if not bool(loaded.get("ok",false)):
        errors.append_array(loaded.get("errors",[]))
        return errors
    var definitions := skill_definitions()
    for raw_disciple in state.disciples.values():
        var disciple: DiscipleState = raw_disciple
        for raw_id in disciple.v63_learned_skill_nodes.keys():
            var id := str(raw_id)
            var row = disciple.v63_learned_skill_nodes[raw_id]
            var definition: Dictionary = definitions.get(id,{})
            if definition.is_empty() or not (row is Dictionary) or str(row.get("source_codex_id","")) != str(definition.get("source_codex_id","")) or int(row.get("learned_tick",-1)) < 0 or float(row.get("mastery_xp",-1.0)) < 0.0:
                errors.append("%s has invalid V6.3 skill knowledge %s." % [disciple.display_name,id])
        var seen: Dictionary = {}
        var active_count := 0
        for raw_id in disciple.v63_equipped_skill_ids:
            var id := str(raw_id)
            var definition: Dictionary = definitions.get(id,{})
            if definition.is_empty() or not disciple.v63_learned_skill_nodes.has(id) or seen.has(id):
                errors.append("%s has an unlearned or duplicate V6.3 equipped skill." % disciple.display_name)
            else:
                seen[id] = true
                if str(definition.get("slot","")) == "active":
                    active_count += 1
        if disciple.v63_equipped_skill_ids.size() > MAX_SKILLS_PER_DISCIPLE or active_count > 4:
            errors.append("%s exceeds V6.3 skill slot bounds." % disciple.display_name)
    return errors

static func _valid_id(value: String) -> bool:
    return value.length() >= 12 and value.length() <= 128 and value.begins_with("tmb.")

static func _failure(reason: String) -> Dictionary:
    return {"ok":false,"reason":reason}
