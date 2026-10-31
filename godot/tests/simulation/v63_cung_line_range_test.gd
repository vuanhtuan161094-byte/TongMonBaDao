extends SceneTree

const SKILL_IDS := [
    "tmb.skill.bow.liep_anh.ultimate.divine.b",
    "tmb.skill.bow.liep_anh.ultimate.rare.b"
]
var failures := 0

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    for skill_id in SKILL_IDS:
        _check(_in_range_target_resolves(skill_id),skill_id+" did not damage a target between radius and cast range")
        _check(_out_of_range_cast_rejected(skill_id),skill_id+" accepted a target beyond cast range")
    if failures == 0:
        print("V63 CUNG LIỆP ẢNH LINE RANGE PASS")
    else:
        push_error("V63 CUNG LINE RANGE FAILURES: "+str(failures))
    quit(1 if failures > 0 else 0)

func _check(value: bool, message: String) -> bool:
    if not value:
        failures += 1
        push_error(message)
    return value

func _actor() -> Dictionary:
    var core := CombatStatsV2.derive(11,1,10,1,0.0)
    var stats: Dictionary = core.stats.duplicate(true)
    stats["max_hp"] = 100000.0
    stats["attack"] = 180.0
    stats["defense"] = 100.0
    return {
        "id":"liep_line_caster","party_id":"line_test","role":"ranged","tier":"disciple",
        "race_id":"nhan_toc","position":Vector2(10.0,10.0),"stats":stats,
        "hp":100000.0,"max_hp":100000.0,"resistances":core.resistances.duplicate(true),
        "basic_range":2.0,"move_speed":1.0,"basic_ratio":0.0,"basic_interval":20.0,
        "skill_loadout":[],"skill_factors":{},"context_sources":[],"disciple":null,
        "v63_combat_enabled":true
    }

func _monster(id: String, position: Vector2) -> Dictionary:
    var actor: Dictionary = MonsterCatalogueV2.create_actor("truc_thu",11,1,id)
    actor["id"] = id
    actor["position"] = position
    actor["hp"] = 100000000.0
    actor["max_hp"] = 100000000.0
    var stats: Dictionary = actor.get("stats",{}).duplicate(true)
    stats["max_hp"] = 100000000.0
    actor["stats"] = stats
    return actor

func _battle(skill_id: String, near_distance: float, include_far: bool) -> Dictionary:
    var caster := _actor()
    caster["v63_skill_loadout"] = [skill_id]
    var enemies: Array = [_monster("near_target",Vector2(10.0+near_distance,10.0))]
    if include_far:
        enemies.append(_monster("far_target",Vector2(19.1,10.0)))
    var battle := MapBattleV2.new(770000+SKILL_IDS.find(skill_id))
    var started := battle.setup("liep_line_"+str(SKILL_IDS.find(skill_id)),[caster],enemies)
    if not bool(started.get("ok",false)):
        return {"ok":false,"reason":str(started)}
    return {"ok":true,"battle":battle}

func _in_range_target_resolves(skill_id: String) -> bool:
    var setup := _battle(skill_id,7.0,true)
    if not bool(setup.get("ok",false)):
        return _check(false,skill_id+" setup failed: "+str(setup.get("reason","")))
    var battle: MapBattleV2 = setup.battle
    var caster: Dictionary = battle.actors["liep_line_caster"]
    var target: Dictionary = battle.actors["near_target"]
    var far: Dictionary = battle.actors["far_target"]
    var skill := V63HumanSkillCombatSystem.skill_definition(skill_id)
    if not _check(float(target.position.x)-float(caster.position.x) > float(skill.radius),
            skill_id+" fixture must lie beyond radius"):
        return false
    if not _check(float(target.position.x)-float(caster.position.x) <= float(skill.range),
            skill_id+" fixture must remain inside cast range"):
        return false
    var cast_started := V63HumanSkillCombatSystem._try_human_cast(battle,caster,target)
    if not _check(cast_started,skill_id+" was not cast at an in-range target"):
        return false
    var cast: Dictionary = caster.get("v63_pending_cast",{})
    if not _check(not cast.is_empty() and float(cast.get("range",0.0)) == float(skill.range),
            skill_id+" cast record lost its configured range"):
        return false
    var near_before := float(target.hp)
    var far_before := float(far.hp)
    battle.now = float(cast.ready)
    caster.erase("v63_pending_cast")
    V63HumanSkillCombatSystem.release_cast_base(battle,cast,caster)
    var near_hit := false
    var far_hit := false
    for event in battle.events:
        if str(event.get("type","")) != "v63_skill_hit" or str(event.get("skill_id","")) != skill_id:
            continue
        if str(event.get("target","")) == "near_target" and float(event.get("damage",0.0)) > 0.0:
            near_hit = true
        if str(event.get("target","")) == "far_target":
            far_hit = true
    return _check(near_hit and float(target.hp) < near_before and
            not far_hit and is_equal_approx(float(far.hp),far_before),
            skill_id+" did not respect max range while settling numeric HP damage")

func _out_of_range_cast_rejected(skill_id: String) -> bool:
    var setup := _battle(skill_id,9.2,false)
    if not bool(setup.get("ok",false)):
        return _check(false,skill_id+" out-of-range setup failed")
    var battle: MapBattleV2 = setup.battle
    var caster: Dictionary = battle.actors["liep_line_caster"]
    var target: Dictionary = battle.actors["near_target"]
    var started := V63HumanSkillCombatSystem._try_human_cast(battle,caster,target)
    return _check(not started and caster.get("v63_pending_cast",{}).is_empty(),
            skill_id+" cast despite target being beyond its declared range")
