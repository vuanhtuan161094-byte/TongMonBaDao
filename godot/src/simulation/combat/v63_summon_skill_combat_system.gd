class_name V63SummonSkillCombatSystem
extends RefCounted

# S9 Triệu Hồi is candidate-only. Authentic manuals, balance approval and visual acceptance remain pending; this patch supplies bounded procedural event-bound Godot rendering, with no external art asset.
const CATALOGUE_PATH := "res://data/combat/v63_summon_combat_catalog.json"
const REGISTRY_EXTENSION_PATH := "res://data/combat/v63_summon_registry_extension.json"
const MAX_ACTIVE_SUMMONS := 6
const MAX_PER_OWNER := 1
const MAX_SUMMON_DURATION := 60.0
const MAX_ATTACK_INTERVAL := 8.0
const MAX_ATTACK_RANGE := 24.0
const MAX_DAMAGE_RATIO := 3.0
const VALID_EFFECTS := ["damage", "mobility", "summon", "guard", "passive", "innate"]
const VALID_FORMS := ["blade_spirit", "covenant_beast", "guardian_construct"]
const VALID_BEHAVIORS := ["ranged", "flanker", "guardian"]
const VALID_PASSIVE_MODIFIERS := [
    "summon_hp_factor", "summon_damage_factor", "summon_duration_factor",
    "summon_attack_speed_factor", "summon_damage_reduction"
]
static var _catalogue_cache: Dictionary = {}
static var _skill_cache: Dictionary = {}
static var _branch_cache: Dictionary = {}

static func load_catalogue(path: String = CATALOGUE_PATH) -> Dictionary:
    if path == CATALOGUE_PATH and not _catalogue_cache.is_empty():
        return {"ok":true,"errors":[],"data":_catalogue_cache.duplicate(true)}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {"ok":false,"errors":["cannot_open_summon_catalogue"],"data":{}}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary):
        return {"ok":false,"errors":["summon_catalogue_not_object"],"data":{}}
    var errors := validate_catalogue(parsed)
    if errors.is_empty() and path == CATALOGUE_PATH:
        _catalogue_cache = parsed.duplicate(true)
    return {"ok":errors.is_empty(),"errors":errors,"data":parsed}

static func validate_catalogue(data: Dictionary) -> Array[String]:
    var errors: Array[String] = []
    if int(data.get("schema_version",-1)) != 1 or bool(data.get("enabled",true)) or str(data.get("release_gate","")) != "OFF":
        errors.append("summon_catalogue_must_remain_off")
    if str(data.get("school","")) != "summon" or int(data.get("branch_count",0)) != 3:
        errors.append("summon_school_or_branch_count_invalid")
    if str(data.get("source_status","")) != "SOURCE_PENDING" or bool(data.get("archivable",true)):
        errors.append("summon_source_must_remain_pending")
    var skills: Variant = data.get("skills",null)
    var branches: Variant = data.get("branches",null)
    if not (skills is Array) or not (branches is Array):
        errors.append("summon_catalogue_arrays_missing")
        return errors
    if skills.size() != 183 or int(data.get("skill_count",0)) != 183 or branches.size() != 3:
        errors.append("summon_catalogue_node_or_branch_count_invalid")
    var branch_ids: Dictionary = {}
    for branch in branches:
        if not (branch is Dictionary):
            errors.append("summon_branch_not_object")
            continue
        var branch_id := str(branch.get("id",""))
        if branch_id not in ["kiem_linh","linh_thu","khoi_loi_ho_phap"] or branch_ids.has(branch_id):
            errors.append("summon_branch_identity_invalid:"+branch_id)
        branch_ids[branch_id] = true
    var ids: Dictionary = {}
    var names: Dictionary = {}
    var families: Dictionary = {}
    var branch_counts := {"kiem_linh":0,"linh_thu":0,"khoi_loi_ho_phap":0}
    var tier_counts := {"human":0,"immortal":0,"divine":0}
    for raw in skills:
        if not (raw is Dictionary):
            errors.append("summon_skill_not_object")
            continue
        var skill: Dictionary = raw
        var id := str(skill.get("id",""))
        var name := str(skill.get("name",""))
        var family := str(skill.get("family_id",""))
        var branch := str(skill.get("branch",""))
        var slot := str(skill.get("slot",""))
        var family_slot := str(skill.get("family_slot",""))
        var tier := str(skill.get("generation",skill.get("tier","")))
        var effect := str(skill.get("effect",""))
        if not id.begins_with("tmb.skill.summon.") or ids.has(id) or str(skill.get("node_id","")) != id:
            errors.append("summon_skill_id_invalid:"+id)
        ids[id] = true
        if name.strip_edges().is_empty() or names.has(name):
            errors.append("summon_skill_name_invalid:"+id)
        names[name] = true
        families[family] = true
        if str(skill.get("school","")) != "summon" or not VALID_EFFECTS.has(effect):
            errors.append("summon_skill_school_or_effect_invalid:"+id)
        if slot not in ["basic","mobility","active","ultimate","passive","innate"]:
            errors.append("summon_skill_slot_invalid:"+id)
        if tier not in ["human","immortal","divine"]:
            errors.append("summon_skill_tier_invalid:"+id)
        if branch.is_empty():
            if slot not in ["basic","mobility"]:
                errors.append("summon_common_skill_branch_invalid:"+id)
        elif not branch_ids.has(branch):
            errors.append("summon_skill_unknown_branch:"+id)
        elif branch_counts.has(branch):
            branch_counts[branch] += 1
        if tier_counts.has(tier):
            tier_counts[tier] += 1
        if str(skill.get("source_codex_id","")) != "" or bool(skill.get("archivable",true)) or str(skill.get("candidate_status","")) != "CANDIDATE_GATED_SOURCE_PENDING":
            errors.append("summon_learning_source_not_blocked:"+id)
        if str(skill.get("parent_skill_id","")) != "" and not str(skill.get("parent_skill_id","")).begins_with("tmb.skill.summon."):
            errors.append("summon_parent_identity_invalid:"+id)
        if str(skill.get("replaces_skill_id","")) != "" and not str(skill.get("replaces_skill_id","")).begins_with("tmb.skill.summon."):
            errors.append("summon_replacement_identity_invalid:"+id)
        if slot in ["basic","mobility","active","ultimate"] and (float(skill.get("cooldown",0.0)) <= 0.0 or float(skill.get("range",0.0)) <= 0.0 or float(skill.get("cast_time",-1.0)) < 0.0):
            errors.append("summon_action_bounds_invalid:"+id)
        if effect == "damage" and float(skill.get("damage_ratio",0.0)) <= 0.0:
            errors.append("summon_damage_ratio_invalid:"+id)
        if effect in ["passive","innate"]:
            var modifiers: Variant = skill.get("passive_modifiers",null)
            if str(skill.get("effect","")) != slot or not (modifiers is Dictionary) or modifiers.is_empty():
                errors.append("summon_passive_contract_invalid:"+id)
            else:
                for modifier in modifiers.keys():
                    if not VALID_PASSIVE_MODIFIERS.has(str(modifier)):
                        errors.append("summon_passive_modifier_unknown:"+id+":"+str(modifier))
                    var modifier_value := float(modifiers[modifier])
                    if is_nan(modifier_value) or is_inf(modifier_value) or modifier_value < 0.0 or modifier_value > 0.25:
                        errors.append("summon_passive_modifier_bounds_invalid:"+id+":"+str(modifier))
        if effect == "guard" and (float(skill.get("power",0.0)) < 0.05 or float(skill.get("power",0.0)) > 0.8 or float(skill.get("duration",0.0)) <= 0.0):
            errors.append("summon_guard_bounds_invalid:"+id)
        if effect == "summon":
            var profile: Variant = skill.get("summon_profile",null)
            if slot not in ["active","ultimate"] or not (profile is Dictionary):
                errors.append("summon_profile_missing:"+id)
                continue
            var duration := float(profile.get("duration_seconds",0.0))
            var hp_ratio := float(profile.get("hp_ratio",0.0))
            var ratio := float(profile.get("attack_damage_ratio",0.0))
            var interval := float(profile.get("attack_interval_seconds",0.0))
            var attack_range := float(profile.get("attack_range",0.0))
            var speed_ratio := float(profile.get("move_speed_ratio",0.0))
            var targets := int(profile.get("target_limit",0))
            if str(profile.get("form","")) not in VALID_FORMS or str(profile.get("behavior","")) not in VALID_BEHAVIORS:
                errors.append("summon_profile_identity_invalid:"+id)
            if is_nan(duration) or is_inf(duration) or duration < MapBattleV2.STEP_SECONDS or duration > MAX_SUMMON_DURATION                 or is_nan(hp_ratio) or is_inf(hp_ratio) or hp_ratio <= 0.0 or hp_ratio > 4.0                 or is_nan(ratio) or is_inf(ratio) or ratio <= 0.0 or ratio > MAX_DAMAGE_RATIO                 or is_nan(interval) or is_inf(interval) or interval < MapBattleV2.STEP_SECONDS or interval > MAX_ATTACK_INTERVAL                 or is_nan(attack_range) or is_inf(attack_range) or attack_range <= 0.0 or attack_range > MAX_ATTACK_RANGE                 or is_nan(speed_ratio) or is_inf(speed_ratio) or speed_ratio <= 0.0 or speed_ratio > 2.0                 or targets < 1 or targets > MapBattleV2.MAX_TARGETS_AOE:
                errors.append("summon_profile_bounds_invalid:"+id)
    if ids.size() != 183 or names.size() != 183 or families.size() != 35:
        errors.append("summon_unique_node_name_family_counts_invalid")
    if branch_counts != {"kiem_linh":59,"linh_thu":59,"khoi_loi_ho_phap":59}:
        errors.append("summon_branch_distribution_invalid")
    if tier_counts != {"human":35,"immortal":68,"divine":80}:
        errors.append("summon_tier_distribution_invalid")
    if str(data.get("candidate_status","")) != "CANDIDATE_GATED_SOURCE_PENDING":
        errors.append("summon_candidate_status_invalid")
    if str(data.get("school_story_vi","")).split(" ",false).size() < 120:
        errors.append("summon_school_story_too_short")
    return errors

static func skill_definitions() -> Dictionary:
    if not _skill_cache.is_empty():
        return _skill_cache.duplicate(true)
    var loaded := load_catalogue()
    var result: Dictionary = {}
    if not bool(loaded.get("ok",false)):
        return result
    for row in loaded.data.get("skills",[]):
        result[str(row.get("id",""))] = row.duplicate(true)
    if result.size() == 183:
        _skill_cache = result.duplicate(true)
    return result

static func skill_definition(skill_id: String) -> Dictionary:
    return skill_definitions().get(skill_id,{}).duplicate(true)

static func branch_definitions() -> Dictionary:
    if not _branch_cache.is_empty():
        return _branch_cache.duplicate(true)
    var file := FileAccess.open(REGISTRY_EXTENSION_PATH,FileAccess.READ)
    if file == null:
        return {}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary) or str(parsed.get("release_gate","")) != "OFF":
        return {}
    var result: Dictionary = {}
    for raw in parsed.get("paths",[]):
        if not (raw is Dictionary):
            continue
        var row: Dictionary = raw.duplicate(true)
        var branch_id := str(row.get("id","")).get_slice(".",3)
        row["branch_id"] = branch_id
        row["innate_node_id"] = "tmb.skill.summon.%s.innate.human" % branch_id
        row["innate_node_ids"] = {
            "a":"tmb.skill.summon.%s.innate.immortal.a" % branch_id,
            "b":"tmb.skill.summon.%s.innate.immortal.b" % branch_id
        }
        row["divine_innate_node_ids"] = {
            "a":"tmb.skill.summon.%s.innate.divine.a" % branch_id,
            "b":"tmb.skill.summon.%s.innate.divine.b" % branch_id
        }
        result[branch_id] = row
    if result.size() == 3:
        _branch_cache = result.duplicate(true)
    return result

static func is_summon_skill(skill_id: String) -> bool:
    return skill_id.begins_with("tmb.skill.summon.")

static func can_learn(definition: Dictionary) -> Dictionary:
    if definition.is_empty() or str(definition.get("school","")) != "summon":
        return {"ok":false,"reason":"unknown_summon_skill"}
    return {"ok":false,"reason":"skill_source_pending","skill_id":str(definition.get("id",""))}

static func can_cast(actor: Dictionary, skill_id: String) -> bool:
    if not bool(actor.get("v63_summon_combat_enabled",false)):
        return false
    var skill := skill_definition(skill_id)
    return not skill.is_empty() and str(skill.get("school","")) == "summon"         and str(skill.get("slot","")) in ["active","ultimate","mobility"]

static func preferred_offensive_range(actor: Dictionary) -> float:
    if not bool(actor.get("v63_summon_combat_enabled",false)):
        return 0.0
    var best := 0.0
    for raw_id in actor.get("v63_skill_loadout",[]):
        var skill := skill_definition(str(raw_id))
        if str(skill.get("school","")) == "summon" and str(skill.get("slot","")) in ["active","ultimate"]             and str(skill.get("effect","")) in ["damage","summon"]:
            best = maxf(best,float(skill.get("range",0.0)))
    return best

static func should_cast(battle: MapBattleV2, actor: Dictionary, skill: Dictionary) -> bool:
    if battle == null or not can_cast(actor,str(skill.get("id",""))):
        return false
    if str(skill.get("effect","")) != "summon":
        return true
    if _living_summons_for_owner(battle,str(actor.get("id",""))) >= MAX_PER_OWNER:
        return false
    if _living_summons(battle) >= mini(MAX_ACTIVE_SUMMONS,MapBattleV2.MAX_SUMMON_ACTORS):
        return false
    return true

static func release_cast(battle: MapBattleV2, cast: Dictionary, caster: Dictionary) -> void:
    var id := str(cast.get("v63_skill_id",""))
    var skill := skill_definition(id)
    if skill.is_empty() or not is_summon_skill(id):
        return
    if str(skill.get("effect","")) == "summon":
        _create_summon(battle,cast,caster,skill)
        return
    V63HumanSkillCombatSystem.release_cast_base(battle,cast,caster)

static func _create_summon(battle: MapBattleV2, cast: Dictionary, caster: Dictionary, skill: Dictionary) -> void:
    var owner_id := str(caster.get("id",""))
    if battle == null or not battle.active or owner_id.is_empty() or float(caster.get("hp",0.0)) <= 0.0         or not bool(caster.get("v63_summon_combat_enabled",false)):
        return
    if not battle.actors.has(owner_id) or _living_summons_for_owner(battle,owner_id) >= MAX_PER_OWNER         or _living_summons(battle) >= mini(MAX_ACTIVE_SUMMONS,MapBattleV2.MAX_SUMMON_ACTORS):
        battle._event("skill_miss",{"caster":owner_id,"skill_id":str(skill.get("id","")),"reason":"summon_actor_cap"})
        return
    var profile: Dictionary = skill.get("summon_profile",{})
    var spawn := _spawn_position(battle,caster)
    if not bool(spawn.get("ok",false)):
        battle._event("skill_miss",{"caster":owner_id,"skill_id":str(skill.get("id","")),"reason":"summon_spawn_blocked"})
        return
    var sequence := int(caster.get("v63_summon_sequence",0))+1
    caster["v63_summon_sequence"] = sequence
    var summon_id := "%s/v63_summon/%s/%d" % [battle.encounter_id,owner_id,sequence]
    var hp_factor := clampf(_owner_modifier(caster,"summon_hp_factor"),0.0,0.5)
    var damage_factor := clampf(_owner_modifier(caster,"summon_damage_factor"),0.0,0.5)
    var duration_factor := clampf(_owner_modifier(caster,"summon_duration_factor"),0.0,0.5)
    var speed_factor := clampf(_owner_modifier(caster,"summon_attack_speed_factor"),0.0,0.5)
    var damage_reduction := clampf(_owner_modifier(caster,"summon_damage_reduction"),0.0,0.25)
    var max_hp := float(caster.get("max_hp",0.0))*float(profile.get("hp_ratio",0.0))*(1.0+hp_factor)
    if max_hp <= 0.0:
        battle._event("skill_miss",{"caster":owner_id,"skill_id":str(skill.get("id","")),"reason":"summon_owner_hp_invalid"})
        return
    var summon_stats: Dictionary = caster.get("stats",{}).duplicate(true)
    summon_stats["max_hp"] = max_hp
    summon_stats["damage_reduction"] = clampf(float(summon_stats.get("damage_reduction",0.0))+damage_reduction,0.0,0.8)
    var duration := clampf(float(profile.get("duration_seconds",0.0))*(1.0+duration_factor),MapBattleV2.STEP_SECONDS,MAX_SUMMON_DURATION)
    var interval := clampf(float(profile.get("attack_interval_seconds",1.0))/(1.0+speed_factor),MapBattleV2.STEP_SECONDS,MAX_ATTACK_INTERVAL)
    var position: Vector2 = spawn.get("position",caster.get("position",Vector2.ZERO))
    var summon := {
        "id":summon_id,"side":"disciple","party_id":str(caster.get("party_id","")),
        "role":"frontline" if str(profile.get("behavior","")) in ["flanker","guardian"] else "ranged",
        "position":position,"hp":max_hp,"max_hp":max_hp,"range":float(profile.get("attack_range",1.8)),
        "move_speed":maxf(0.1,float(caster.get("move_speed",1.0))*float(profile.get("move_speed_ratio",1.0))),
        "tier":"normal","stats":summon_stats,"resistances":caster.get("resistances",{}).duplicate(true),
        "status_effects":{},"context_sources":caster.get("context_sources",[]).duplicate(true),
        "v63_combat_enabled":false,"v63_summon_combat_enabled":false,
        "v63_skill_ready":{},"v63_skill_loadout":[],"v63_passive_ids":[],
        "v63_combat_clock":-1.0,"next_skill":0.0,"learned_guard_factor":1.0,"learned_guard_until":-1.0,
        "linked_disciple":null,"is_v63_summon":true,"summon_owner_id":owner_id,
        "summon_skill_id":str(skill.get("id","")),"summon_source_generation_id":str(skill.get("generation","human")),
        "summon_form":str(profile.get("form","")),"summon_behavior":str(profile.get("behavior","")),
        "summon_expires_at":battle.now+duration,"summon_next_attack_at":battle.now,
        "summon_attack_interval_seconds":interval,"summon_attack_range":float(profile.get("attack_range",1.8)),
        "summon_attack_damage_ratio":float(profile.get("attack_damage_ratio",0.0))*(1.0+damage_factor),
        "summon_target_limit":int(profile.get("target_limit",1)),"summon_element":str(skill.get("element","")),
        "home_position":position,"move_order_position":position,"move_order_active":false,
        "hunt_policy":"hold","hunt_after_move":"hold","hunt_radius":float(caster.get("hunt_radius",0.0))
    }
    battle.actors[summon_id] = summon
    battle._event("v63_summon_created",{"owner_id":owner_id,"summon_id":summon_id,"skill_id":str(skill.get("id","")),
        "form":str(profile.get("form","")),"expires_at":float(summon["summon_expires_at"])})

static func _spawn_position(battle: MapBattleV2, caster: Dictionary) -> Dictionary:
    var origin: Vector2 = caster.get("position",Vector2.ZERO)
    var offsets := [Vector2(0.8,0.0),Vector2(0.0,0.8),Vector2(-0.8,0.0),Vector2(0.0,-0.8),
        Vector2(0.6,0.6),Vector2(-0.6,0.6),Vector2(-0.6,-0.6),Vector2(0.6,-0.6)]
    for offset in offsets:
        var candidate := origin+offset
        if battle.world_mode:
            var cell := battle._nearest_walkable_cell(Vector2i(floori(candidate.x),floori(candidate.y)))
            if cell.x < 0:
                continue
            candidate = Vector2(cell)+Vector2(0.5,0.5)
        if not battle.is_world_position_allowed(candidate):
            continue
        var occupied := false
        for other in battle.actors.values():
            if float(other.get("hp",0.0)) > 0.0 and (other.get("position",Vector2.ZERO) as Vector2).distance_to(candidate) < 0.45:
                occupied = true
                break
        if not occupied:
            return {"ok":true,"position":candidate}
    return {"ok":false,"position":origin}

static func process_summons(battle: MapBattleV2) -> void:
    if battle == null:
        return
    var ids: Array = battle.actors.keys()
    ids.sort()
    var remove_ids: Array[String] = []
    for raw_id in ids:
        var summon: Dictionary = battle.actors.get(str(raw_id),{})
        if not bool(summon.get("is_v63_summon",false)):
            continue
        var owner_id := str(summon.get("summon_owner_id",""))
        var owner: Dictionary = battle.actors.get(owner_id,{})
        var reason := ""
        if float(summon.get("hp",0.0)) <= 0.0:
            reason = "downed"
        elif owner.is_empty() or float(owner.get("hp",0.0)) <= 0.0:
            reason = "owner_unavailable"
        elif not bool(owner.get("v63_summon_combat_enabled",false)):
            reason = "feature_gate_off"
        elif battle.now >= float(summon.get("summon_expires_at",-1.0)):
            reason = "contract_expired"
        if not reason.is_empty():
            battle._event("v63_summon_expired",{"owner_id":owner_id,"summon_id":str(summon.get("id","")),
                "skill_id":str(summon.get("summon_skill_id","")),"form":str(summon.get("summon_form","")),"reason":reason})
            remove_ids.append(str(summon.get("id","")))
            continue
        var skill_id := str(summon.get("summon_skill_id",""))
        if skill_id.is_empty() or skill_definition(skill_id).is_empty():
            battle._event("v63_summon_expired",{"owner_id":owner_id,"summon_id":str(summon.get("id","")),
                "skill_id":skill_id,"reason":"source_skill_missing"})
            remove_ids.append(str(summon.get("id","")))
            continue
        var target := _nearest_eligible_enemy(battle,summon)
        if target.is_empty():
            continue
        var attack_range := float(summon.get("summon_attack_range",0.0))
        var distance := (summon.get("position",Vector2.ZERO) as Vector2).distance_to(target.get("position",Vector2.ZERO))
        if distance > attack_range:
            var speed := maxf(0.1,float(summon.get("move_speed",0.1)))
            if battle.world_mode:
                battle._move_world_actor(summon,target.get("position",Vector2.ZERO),speed,attack_range)
            else:
                var next_position: Vector2 = (summon.get("position",Vector2.ZERO) as Vector2).move_toward(target.get("position",Vector2.ZERO),speed*MapBattleV2.STEP_SECONDS)
                if battle.is_world_position_allowed(next_position):
                    summon["position"] = next_position
            continue
        if battle.now+0.000001 < float(summon.get("summon_next_attack_at",-1.0)):
            continue
        var targets := _eligible_targets_in_range(battle,summon,attack_range,int(summon.get("summon_target_limit",1)))
        if targets.is_empty():
            continue
        var ratio := clampf(float(summon.get("summon_attack_damage_ratio",0.0)),0.0,MAX_DAMAGE_RATIO)
        if ratio <= 0.0:
            continue
        for target_value in targets:
            var live_target: Dictionary = battle.actors.get(str(target_value.get("id","")),{})
            if live_target.is_empty() or float(live_target.get("hp",0.0)) <= 0.0:
                continue
            var actual := battle._deal_direct(owner,live_target,ratio,"v63_summon",false,
                str(summon.get("summon_element","")),false,skill_id)
            if actual > 0.0:
                battle._event("v63_summon_attack",{"owner_id":owner_id,"summon_id":str(summon.get("id","")),
                    "skill_id":skill_id,"target_id":str(live_target.get("id","")),"form":str(summon.get("summon_form","")),
                    "damage":actual})
        var speed_factor := clampf(_owner_modifier(owner,"summon_attack_speed_factor"),0.0,0.5)
        var base_interval := maxf(MapBattleV2.STEP_SECONDS,float(summon.get("summon_attack_interval_seconds",1.0)))
        summon["summon_next_attack_at"] = battle.now+maxf(MapBattleV2.STEP_SECONDS,base_interval/(1.0+speed_factor))
    for summon_id in remove_ids:
        battle.actors.erase(summon_id)

static func _nearest_eligible_enemy(battle: MapBattleV2, summon: Dictionary) -> Dictionary:
    var candidates: Array = []
    var ids: Array = battle.actors.keys()
    ids.sort()
    for raw_id in ids:
        var enemy: Dictionary = battle.actors[raw_id]
        if str(enemy.get("side","")) == str(summon.get("side","")) or float(enemy.get("hp",0.0)) <= 0.0:
            continue
        if battle.world_mode:
            var radius := float(summon.get("hunt_radius",0.0))
            if radius > 0.0 and (enemy.get("position",Vector2.ZERO) as Vector2).distance_squared_to(summon.get("position",Vector2.ZERO)) > radius*radius:
                continue
        candidates.append(enemy)
    candidates.sort_custom(func(a: Dictionary,b: Dictionary):
        var da := (summon.get("position",Vector2.ZERO) as Vector2).distance_squared_to(a.get("position",Vector2.ZERO))
        var db := (summon.get("position",Vector2.ZERO) as Vector2).distance_squared_to(b.get("position",Vector2.ZERO))
        return da < db if not is_equal_approx(da,db) else str(a.get("id","")) < str(b.get("id","")))
    return candidates[0] if not candidates.is_empty() else {}

static func _eligible_targets_in_range(battle: MapBattleV2, summon: Dictionary, max_range: float, limit: int) -> Array[Dictionary]:
    var candidates: Array[Dictionary] = []
    var ids: Array = battle.actors.keys()
    ids.sort()
    var origin: Vector2 = summon.get("position",Vector2.ZERO)
    for raw_id in ids:
        var enemy: Dictionary = battle.actors[raw_id]
        if str(enemy.get("side","")) == str(summon.get("side","")) or float(enemy.get("hp",0.0)) <= 0.0:
            continue
        if origin.distance_to(enemy.get("position",Vector2.ZERO)) <= max_range:
            candidates.append(enemy)
    candidates.sort_custom(func(a: Dictionary,b: Dictionary):
        var da := origin.distance_squared_to(a.get("position",Vector2.ZERO))
        var db := origin.distance_squared_to(b.get("position",Vector2.ZERO))
        return da < db if not is_equal_approx(da,db) else str(a.get("id","")) < str(b.get("id","")))
    var selected: Array[Dictionary] = []
    for index in range(mini(candidates.size(),clampi(limit,1,MapBattleV2.MAX_TARGETS_AOE))):
        selected.append(candidates[index])
    return selected

static func _living_summons(battle: MapBattleV2) -> int:
    var count := 0
    for actor in battle.actors.values():
        if bool(actor.get("is_v63_summon",false)) and float(actor.get("hp",0.0)) > 0.0 and battle.now < float(actor.get("summon_expires_at",-1.0)):
            count += 1
    return count

static func _living_summons_for_owner(battle: MapBattleV2, owner_id: String) -> int:
    var count := 0
    for actor in battle.actors.values():
        if bool(actor.get("is_v63_summon",false)) and str(actor.get("summon_owner_id","")) == owner_id             and float(actor.get("hp",0.0)) > 0.0 and battle.now < float(actor.get("summon_expires_at",-1.0)):
            count += 1
    return count

static func _owner_modifier(owner: Dictionary, modifier_key: String) -> float:
    var result := 0.0
    var seen: Dictionary = {}
    var ids: Array = owner.get("v63_passive_ids",[]).duplicate()
    var innate_id := str(owner.get("v63_innate_skill_id",""))
    if not innate_id.is_empty():
        ids.append(innate_id)
    for raw_id in ids:
        var skill_id := str(raw_id)
        if seen.has(skill_id):
            continue
        seen[skill_id] = true
        var skill := skill_definition(skill_id)
        if str(skill.get("school","")) != "summon":
            continue
        result += float(skill.get("passive_modifiers",{}).get(modifier_key,0.0))
    return result

static func reset_cache_for_tests() -> void:
    _catalogue_cache.clear()
    _skill_cache.clear()
    _branch_cache.clear()
