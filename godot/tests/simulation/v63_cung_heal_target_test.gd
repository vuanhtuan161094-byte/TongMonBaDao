extends SceneTree

const SKILL_ID := "tmb.skill.bow.linh_tien.active_02.human"
var failures := 0

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _check(_full_party_does_not_consume_heal(), "Linh Tiễn heal cast at full HP")
    _check(_injured_party_receives_real_heal(), "Linh Tiễn failed to heal an injured ally")
    if failures == 0:
        print("V63 CUNG HEAL TARGET PASS")
    else:
        push_error("V63 CUNG HEAL TARGET FAILURES: "+str(failures))
    quit(1 if failures > 0 else 0)

func _check(value: bool, message: String) -> bool:
    if not value:
        failures += 1
        push_error(message)
    return value

func _actor(id: String, position: Vector2, hp: float, max_hp: float) -> Dictionary:
    var core := CombatStatsV2.derive(11,1,10,1,0.0)
    var stats: Dictionary = core.stats.duplicate(true)
    stats["max_hp"] = max_hp
    stats["attack"] = 180.0
    stats["defense"] = 100.0
    return {
        "id":id,"party_id":"linh_heal_test","role":"ranged","tier":"disciple",
        "race_id":"nhan_toc","position":position,"stats":stats,
        "hp":hp,"max_hp":max_hp,"resistances":core.resistances.duplicate(true),
        "basic_range":2.0,"move_speed":1.0,"basic_ratio":0.0,"basic_interval":20.0,
        "skill_loadout":[],"skill_factors":{},"context_sources":[],"disciple":null
    }

func _battle(ally_hp: float) -> Dictionary:
    var caster := _actor("healer",Vector2(10.0,10.0),10000.0,10000.0)
    caster["v63_combat_enabled"] = true
    caster["v63_skill_loadout"] = [SKILL_ID]
    var ally := _actor("ally",Vector2(11.0,10.0),ally_hp,10000.0)
    var enemy: Dictionary = MonsterCatalogueV2.create_actor("truc_thu",11,1,"enemy")
    enemy["id"] = "enemy"
    enemy["position"] = Vector2(15.0,10.0)
    enemy["hp"] = 10000000.0
    enemy["max_hp"] = 10000000.0
    var stats: Dictionary = enemy.get("stats",{}).duplicate(true)
    stats["max_hp"] = 10000000.0
    enemy["stats"] = stats
    var battle := MapBattleV2.new(780001)
    var started := battle.setup("linh_heal_test",[caster,ally],[enemy])
    if not bool(started.get("ok",false)):
        return {"ok":false,"reason":str(started)}
    return {"ok":true,"battle":battle}

func _full_party_does_not_consume_heal() -> bool:
    var setup := _battle(10000.0)
    if not bool(setup.get("ok",false)):
        return false
    var battle: MapBattleV2 = setup.battle
    var caster: Dictionary = battle.actors["healer"]
    var target: Dictionary = battle.actors["enemy"]
    var cast := V63HumanSkillCombatSystem._try_human_cast(battle,caster,target)
    return not cast and caster.get("v63_pending_cast",{}).is_empty() \
        and caster.get("v63_skill_ready",{}).is_empty()

func _injured_party_receives_real_heal() -> bool:
    var setup := _battle(1000.0)
    if not bool(setup.get("ok",false)):
        return false
    var battle: MapBattleV2 = setup.battle
    var caster: Dictionary = battle.actors["healer"]
    var ally: Dictionary = battle.actors["ally"]
    var target: Dictionary = battle.actors["enemy"]
    if not V63HumanSkillCombatSystem._try_human_cast(battle,caster,target):
        return false
    var cast: Dictionary = caster.get("v63_pending_cast",{})
    if str(cast.get("target_id","")) != "ally":
        return false
    var before := float(ally.hp)
    battle.now = float(cast.ready)
    caster.erase("v63_pending_cast")
    V63HumanSkillCombatSystem.release_cast_base(battle,cast,caster)
    var heal_event := false
    for event in battle.events:
        if str(event.get("type","")) == "heal" and str(event.get("skill_id","")) == SKILL_ID \
            and str(event.get("target","")) == "ally" and float(event.get("amount",0.0)) > 0.0:
            heal_event = true
    return heal_event and float(ally.hp) > before
