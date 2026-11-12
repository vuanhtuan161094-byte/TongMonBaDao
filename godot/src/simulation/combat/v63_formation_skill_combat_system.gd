class_name V63FormationSkillCombatSystem
extends RefCounted

# S8 Trận candidate. Source manuals and balance are pending; the school gate is OFF.
const CATALOGUE_PATH := "res://data/combat/v63_formation_combat_catalog.json"
const REGISTRY_EXTENSION_PATH := "res://data/combat/v63_formation_registry_extension.json"
const MAX_TARGETS := 3
const MAX_ZONE_DURATION := 30.0
const MAX_ZONE_RADIUS := 12.0
const VALID_EFFECTS := ["damage", "mobility", "guard", "slow", "formation_zone", "passive", "innate"]
static var _catalogue_cache: Dictionary = {}
static var _skill_cache: Dictionary = {}
static var _branch_cache: Dictionary = {}

static func load_catalogue(path: String = CATALOGUE_PATH) -> Dictionary:
    if path == CATALOGUE_PATH and not _catalogue_cache.is_empty():
        return {"ok":true,"errors":[],"data":_catalogue_cache.duplicate(true)}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {"ok":false,"errors":["cannot_open_formation_catalogue"],"data":{}}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary):
        return {"ok":false,"errors":["formation_catalogue_not_object"],"data":{}}
    var errors := validate_catalogue(parsed)
    if errors.is_empty() and path == CATALOGUE_PATH:
        _catalogue_cache = parsed.duplicate(true)
    return {"ok":errors.is_empty(),"errors":errors,"data":parsed}

static func validate_catalogue(data: Dictionary) -> Array[String]:
    var errors: Array[String] = []
    if int(data.get("schema_version", -1)) != 1 or bool(data.get("enabled", true)) or str(data.get("release_gate", "")) != "OFF":
        errors.append("formation_catalogue_must_remain_off")
    if str(data.get("school", "")) != "formation" or int(data.get("branch_count", 0)) != 3:
        errors.append("formation_school_or_branch_count_invalid")
    var skills: Variant = data.get("skills", null)
    var branches: Variant = data.get("branches", null)
    if not (skills is Array) or not (branches is Array):
        errors.append("formation_catalogue_arrays_missing")
        return errors
    if skills.size() != 183 or int(data.get("skill_count", 0)) != 183:
        errors.append("formation_node_count_not_183")
    if branches.size() != 3:
        errors.append("formation_branch_count_not_three")
    if str(data.get("source_status", "")) != "SOURCE_PENDING" or bool(data.get("archivable", true)):
        errors.append("formation_source_must_remain_pending")
    var branch_ids: Dictionary = {}
    for branch in branches:
        if not (branch is Dictionary):
            errors.append("formation_branch_not_object")
            continue
        var branch_id := str(branch.get("id", ""))
        if branch_id not in ["tu_linh_tran", "phong_toa_tran", "sat_phat_tran"] or branch_ids.has(branch_id):
            errors.append("formation_branch_identity_invalid:" + branch_id)
        branch_ids[branch_id] = true
    var ids: Dictionary = {}
    var names: Dictionary = {}
    var families: Dictionary = {}
    var branch_counts := {"tu_linh_tran":0, "phong_toa_tran":0, "sat_phat_tran":0}
    var tier_counts := {"human":0, "immortal":0, "divine":0}
    for raw in skills:
        if not (raw is Dictionary):
            errors.append("formation_skill_not_object")
            continue
        var skill: Dictionary = raw
        var id := str(skill.get("id", ""))
        var name := str(skill.get("name", ""))
        var family := str(skill.get("family_id", ""))
        var branch := str(skill.get("branch", ""))
        var slot := str(skill.get("slot", ""))
        var tier := str(skill.get("generation", skill.get("tier", "")))
        var effect := str(skill.get("effect", ""))
        if not id.begins_with("tmb.skill.formation.") or ids.has(id) or str(skill.get("node_id", "")) != id:
            errors.append("formation_skill_id_invalid:" + id)
        ids[id] = true
        if name.strip_edges().is_empty() or names.has(name):
            errors.append("formation_skill_name_invalid:" + id)
        names[name] = true
        families[family] = true
        if str(skill.get("school", "")) != "formation" or not VALID_EFFECTS.has(effect):
            errors.append("formation_skill_school_or_effect_invalid:" + id)
        if slot not in ["basic", "mobility", "active", "ultimate", "passive", "innate"]:
            errors.append("formation_skill_slot_invalid:" + id)
        if tier not in ["human", "immortal", "divine"]:
            errors.append("formation_skill_tier_invalid:" + id)
        if branch.is_empty():
            if slot not in ["basic", "mobility"]:
                errors.append("formation_noncommon_skill_missing_branch:" + id)
        elif not branch_ids.has(branch):
            errors.append("formation_skill_unknown_branch:" + id)
        elif branch_counts.has(branch):
            branch_counts[branch] += 1
        if tier_counts.has(tier):
            tier_counts[tier] += 1
        if str(skill.get("source_codex_id", "")) != "" or bool(skill.get("archivable", true)) or str(skill.get("candidate_status", "")) != "CANDIDATE_GATED_SOURCE_PENDING":
            errors.append("formation_learning_source_not_blocked:" + id)
        var active_slot := slot in ["basic", "mobility", "active", "ultimate"]
        if active_slot and (float(skill.get("cooldown", 0.0)) <= 0.0 or float(skill.get("range", 0.0)) <= 0.0 or float(skill.get("cast_time", -1.0)) < 0.0):
            errors.append("formation_action_bounds_invalid:" + id)
        if effect == "damage" and float(skill.get("damage_ratio", 0.0)) <= 0.0:
            errors.append("formation_damage_ratio_invalid:" + id)
        if effect in ["passive", "innate"] and (str(skill.get("effect")) != slot or not (skill.get("passive_modifiers", null) is Dictionary)):
            errors.append("formation_passive_contract_invalid:" + id)
        if effect == "guard" and (float(skill.get("power", 0.0)) < 0.05 or float(skill.get("power", 0.0)) > 0.8 or float(skill.get("duration", 0.0)) <= 0.0):
            errors.append("formation_guard_bounds_invalid:" + id)
        if effect == "slow" and (float(skill.get("damage_ratio", 0.0)) <= 0.0 or float(skill.get("duration", 0.0)) <= 0.0 or float(skill.get("slow_movement_factor", 1.0)) < 0.5 or float(skill.get("slow_movement_factor", 1.0)) >= 1.0):
            errors.append("formation_slow_bounds_invalid:" + id)
        if effect == "formation_zone":
            var interval := float(skill.get("formation_zone_tick_interval", 0.0))
            if float(skill.get("damage_ratio", 0.0)) <= 0.0 or float(skill.get("radius", 0.0)) <= 0.0 or float(skill.get("radius", 0.0)) > MAX_ZONE_RADIUS or float(skill.get("duration", 0.0)) <= 0.0 or float(skill.get("duration", 0.0)) > MAX_ZONE_DURATION or interval < MapBattleV2.STEP_SECONDS or interval > 5.0 or int(skill.get("target_limit", 0)) < 1 or int(skill.get("target_limit", 0)) > MAX_TARGETS:
                errors.append("formation_zone_bounds_invalid:" + id)
    if ids.size() != 183 or names.size() != 183 or families.size() != 35:
        errors.append("formation_unique_node_name_family_counts_invalid")
    if branch_counts != {"tu_linh_tran":59, "phong_toa_tran":59, "sat_phat_tran":59}:
        errors.append("formation_branch_distribution_invalid")
    if tier_counts != {"human":35, "immortal":68, "divine":80}:
        errors.append("formation_tier_distribution_invalid")
    return errors

static func skill_definitions() -> Dictionary:
    if not _skill_cache.is_empty():
        return _skill_cache.duplicate(true)
    var loaded := load_catalogue()
    var result: Dictionary = {}
    if not bool(loaded.get("ok", false)):
        return result
    for row in loaded.data.get("skills", []):
        result[str(row.get("id", ""))] = row.duplicate(true)
    if result.size() == 183:
        _skill_cache = result.duplicate(true)
    return result

static func skill_definition(skill_id: String) -> Dictionary:
    return skill_definitions().get(skill_id, {}).duplicate(true)

static func branch_definitions() -> Dictionary:
    if not _branch_cache.is_empty():
        return _branch_cache.duplicate(true)
    var file := FileAccess.open(REGISTRY_EXTENSION_PATH, FileAccess.READ)
    if file == null:
        return {}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary) or str(parsed.get("release_gate", "")) != "OFF":
        return {}
    var result: Dictionary = {}
    for raw in parsed.get("paths", []):
        if not (raw is Dictionary):
            continue
        var row: Dictionary = raw.duplicate(true)
        var branch_id := str(row.get("id", "")).get_slice(".", 3)
        row["branch_id"] = branch_id
        row["innate_node_id"] = "tmb.skill.formation.%s.innate.human" % branch_id
        row["innate_node_ids"] = {
            "a":"tmb.skill.formation.%s.innate.immortal.a" % branch_id,
            "b":"tmb.skill.formation.%s.innate.immortal.b" % branch_id
        }
        row["divine_innate_node_ids"] = {
            "a":"tmb.skill.formation.%s.innate.divine.a" % branch_id,
            "b":"tmb.skill.formation.%s.innate.divine.b" % branch_id
        }
        result[branch_id] = row
    if result.size() == 3:
        _branch_cache = result.duplicate(true)
    return result

static func is_formation_skill(skill_id: String) -> bool:
    return skill_id.begins_with("tmb.skill.formation.")

static func can_learn(definition: Dictionary) -> Dictionary:
    if definition.is_empty() or str(definition.get("school", "")) != "formation":
        return {"ok":false,"reason":"unknown_formation_skill"}
    return {"ok":false,"reason":"skill_source_pending","skill_id":str(definition.get("id", ""))}

static func can_cast(actor: Dictionary, skill_id: String) -> bool:
    if not bool(actor.get("v63_formation_combat_enabled", false)):
        return false
    var skill := skill_definition(skill_id)
    return not skill.is_empty() and str(skill.get("school", "")) == "formation" and str(skill.get("slot", "")) in ["active", "ultimate", "mobility"]

static func preferred_offensive_range(actor: Dictionary) -> float:
    if not bool(actor.get("v63_formation_combat_enabled", false)):
        return 0.0
    var best := 0.0
    for raw_id in actor.get("v63_skill_loadout", []):
        var skill := skill_definition(str(raw_id))
        if str(skill.get("school", "")) == "formation" and str(skill.get("effect", "")) in ["damage", "slow", "formation_zone"] and str(skill.get("slot", "")) in ["basic", "active", "ultimate"]:
            best = maxf(best, float(skill.get("range", 0.0)))
    return best

static func should_cast(battle: MapBattleV2, actor: Dictionary, target: Dictionary, skill: Dictionary) -> bool:
    if battle == null or target.is_empty() or not can_cast(actor, str(skill.get("id", ""))):
        return false
    var effect := str(skill.get("effect", ""))
    if effect == "guard":
        var wanted := 1.0 - clampf(float(skill.get("power", 0.0)), 0.05, 0.8)
        return float(target.get("learned_guard_until", -1.0)) <= battle.now or float(target.get("learned_guard_factor", 1.0)) > wanted + 0.000001
    if effect == "slow":
        var active: Dictionary = target.get("status_effects", {}).get("slow", {})
        if not active.is_empty() and battle.now < float(active.get("until", -1.0)):
            var requested := clampf(float(skill.get("slow_movement_factor", 1.0)), 0.5, 1.0)
            var strength := 1.0 - requested
            if str(target.get("tier", "")) == "boss" or not str(target.get("v63_boss_id", "")).is_empty():
                strength *= clampf(float(skill.get("boss_effect_strength_factor", 0.35)), 0.0, 1.0)
            var wanted_factor := clampf(1.0 - strength, 0.5, 1.0)
            if float(active.get("movement_factor", 1.0)) <= wanted_factor + 0.000001 and float(active.get("until", 0.0)) - battle.now > MapBattleV2.STEP_SECONDS * 2.0:
                return false
    if effect == "formation_zone":
        for raw in actor.get("v63_formation_zones", []):
            if raw is Dictionary and battle.now < float(raw.get("expires_at", -1.0)):
                return false
    return true

static func release_cast(battle: MapBattleV2, cast: Dictionary, caster: Dictionary) -> void:
    var id := str(cast.get("v63_skill_id", ""))
    var skill := skill_definition(id)
    if skill.is_empty():
        return
    if str(skill.get("effect", "")) == "formation_zone":
        _create_zone(battle, cast, caster, skill)
        return
    V63HumanSkillCombatSystem.release_cast_base(battle, cast, caster)

static func _create_zone(battle: MapBattleV2, cast: Dictionary, caster: Dictionary, skill: Dictionary) -> void:
    if battle == null or float(caster.get("hp", 0.0)) <= 0.0 or not bool(caster.get("v63_formation_combat_enabled", false)):
        return
    var center_value: Variant = cast.get("center", caster.get("position", Vector2.ZERO))
    if not (center_value is Vector2):
        battle._event("skill_miss", {"caster":str(caster.get("id", "")), "skill_id":str(skill.get("id", "")), "reason":"formation_zone_center_invalid"})
        return
    var center: Vector2 = center_value
    if not battle.is_world_position_allowed(center) or (caster.get("position", Vector2.ZERO) as Vector2).distance_to(center) > float(skill.get("range", 0.0)):
        battle._event("skill_miss", {"caster":str(caster.get("id", "")), "skill_id":str(skill.get("id", "")), "reason":"formation_zone_out_of_bounds"})
        return
    var zones: Array = caster.get("v63_formation_zones", []).duplicate(true)
    for raw in zones:
        if raw is Dictionary and battle.now < float(raw.get("expires_at", -1.0)):
            battle._event("skill_miss", {"caster":str(caster.get("id", "")), "skill_id":str(skill.get("id", "")), "reason":"formation_zone_caster_cap"})
            return
    var sequence := int(caster.get("v63_formation_zone_sequence", 0)) + 1
    caster["v63_formation_zone_sequence"] = sequence
    var duration := clampf(float(cast.get("duration", skill.get("duration", 0.0))), MapBattleV2.STEP_SECONDS, MAX_ZONE_DURATION)
    var interval := clampf(float(skill.get("formation_zone_tick_interval", 1.0)), MapBattleV2.STEP_SECONDS, 5.0)
    var zone := {
        "zone_id":"%s/%s/%s/%d" % [battle.encounter_id, str(caster.get("id", "")), str(skill.get("id", "")), sequence],
        "owner_id":str(caster.get("id", "")),
        "skill_id":str(skill.get("id", "")),
        "generation":str(skill.get("generation", "human")),
        "lineage":str(skill.get("lineage", "")),
        "center_x":center.x,
        "center_y":center.y,
        "radius":clampf(float(cast.get("radius", 0.0)), 0.1, MAX_ZONE_RADIUS),
        "ratio":maxf(0.0, float(cast.get("ratio", 0.0))),
        "element":str(cast.get("element", skill.get("element", ""))),
        "target_limit":clampi(int(cast.get("maximum", skill.get("target_limit", 1))), 1, MAX_TARGETS),
        "tick_interval":interval,
        "next_tick":battle.now + interval,
        "expires_at":battle.now + duration
    }
    if zone.ratio <= 0.0:
        battle._event("skill_miss", {"caster":str(caster.get("id", "")), "skill_id":str(skill.get("id", "")), "reason":"formation_zone_ratio_invalid"})
        return
    zones.append(zone)
    caster["v63_formation_zones"] = zones
    battle._event("v63_formation_zone_created", {
        "caster":str(caster.get("id", "")),
        "skill_id":str(skill.get("id", "")),
        "zone_id":str(zone.zone_id),
        "center":center,
        "radius":float(zone.radius),
        "expires_at":float(zone.expires_at),
        "target_limit":int(zone.target_limit)
    })

static func process_zones(battle: MapBattleV2) -> void:
    if battle == null:
        return
    var owner_ids: Array = battle.actors.keys()
    owner_ids.sort()
    for raw_owner_id in owner_ids:
        var owner_id := str(raw_owner_id)
        var owner: Dictionary = battle.actors.get(owner_id, {})
        var source_zones: Array = owner.get("v63_formation_zones", [])
        if source_zones.is_empty():
            continue
        var kept: Array = []
        for raw_zone in source_zones:
            if not (raw_zone is Dictionary):
                continue
            var zone: Dictionary = raw_zone
            if float(owner.get("hp", 0.0)) <= 0.0 or not bool(owner.get("v63_formation_combat_enabled", false)):
                continue
            if battle.now >= float(zone.get("expires_at", -1.0)):
                battle._event("v63_formation_zone_expired", {
                    "caster":owner_id,"skill_id":str(zone.get("skill_id", "")),
                    "zone_id":str(zone.get("zone_id", "")),"at":battle.now
                })
                continue
            if battle.now + 0.000001 < float(zone.get("next_tick", INF)):
                kept.append(zone)
                continue
            var center := Vector2(float(zone.get("center_x", NAN)), float(zone.get("center_y", NAN)))
            if not battle.is_world_position_allowed(center):
                battle._event("v63_formation_zone_expired", {
                    "caster":owner_id,"skill_id":str(zone.get("skill_id", "")),
                    "zone_id":str(zone.get("zone_id", "")),"reason":"center_no_longer_valid","at":battle.now
                })
                continue
            var targets: Array[Dictionary] = []
            var target_ids: Array = battle.actors.keys()
            target_ids.sort()
            for raw_target_id in target_ids:
                var target: Dictionary = battle.actors[raw_target_id]
                if float(target.get("hp", 0.0)) <= 0.0 or str(target.get("side", "")) == str(owner.get("side", "")):
                    continue
                var position: Vector2 = target.get("position", Vector2.ZERO)
                if not battle.is_world_position_allowed(position) or position.distance_to(center) > float(zone.get("radius", 0.0)):
                    continue
                targets.append(target)
            targets.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
                var da: float = (a.get("position", Vector2.ZERO) as Vector2).distance_squared_to(center)
                var db: float = (b.get("position", Vector2.ZERO) as Vector2).distance_squared_to(center)
                return da < db if not is_equal_approx(da, db) else str(a.get("id", "")) < str(b.get("id", ""))
            )
            var hit_ids: Array[String] = []
            var total_damage := 0.0
            var limit := mini(int(zone.get("target_limit", 1)), MAX_TARGETS)
            for index in range(mini(targets.size(), limit)):
                var target: Dictionary = targets[index]
                var damage := battle._deal_direct(
                    owner, target, float(zone.get("ratio", 0.0)), "v63_skill", false,
                    str(zone.get("element", "")), true, str(zone.get("skill_id", ""))
                )
                if damage > 0.0:
                    total_damage += damage
                    hit_ids.append(str(target.get("id", "")))
            zone["next_tick"] = battle.now + maxf(MapBattleV2.STEP_SECONDS, float(zone.get("tick_interval", 1.0)))
            kept.append(zone)
            battle._event("v63_formation_zone_tick", {
                "caster":owner_id,"owner_id":owner_id,"skill_id":str(zone.get("skill_id", "")),
                "zone_id":str(zone.get("zone_id", "")),"target_ids":hit_ids,
                "damage":total_damage,"at":battle.now
            })
        owner["v63_formation_zones"] = kept
