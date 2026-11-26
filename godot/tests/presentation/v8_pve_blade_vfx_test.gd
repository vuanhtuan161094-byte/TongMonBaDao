extends SceneTree
const FX = preload("res://src/presentation/p3/pve_v8_blade_vfx.gd")
const CURSOR = preload("res://src/presentation/p3/pve_jx_sword_vfx_adapter_v1.gd")

func _initialize() -> void:
    call_deferred("_run")

func _actor(id: String,side: String,position: Vector2) -> Dictionary:
    var resistances: Dictionary = {}
    for element in CombatStatsV2.ELEMENTS:
        resistances[element] = 0.0
    return {"id":id,"side":side,"role":"melee","position":position,"hp":2000.0,"max_hp":2000.0,"range":1.8,"move_speed":2.0,
        "stats":{"attack":40.0,"defense":0.0,"damage_reduction":0.0,"crit_chance":0.0,"crit_damage":1.5,"crit_resistance":0.0,"defense_penetration":0.0,"lifesteal":0.0,"lifesteal_reduction":0.0},
        "resistances":resistances,"tier":"normal","race_id":"yeu_thu","status_effects":{},"context_sources":[],"v63_combat_enabled":true,"v63_blade_combat_enabled":true,"v63_skill_ready":{},"v63_skill_loadout":[],"v63_passive_ids":[],"v63_combat_clock":-1.0,"next_skill":0.0}

func _fail(reason: String) -> void:
    push_error("V8_BLADE_PVE_FAIL "+reason)
    quit(1)

func _run() -> void:
    if not V63FeatureGates.all_disabled() or bool(ProjectSettings.get_setting(FX.PREVIEW_SETTING,false)):
        _fail("default release gate open")
        return
    if FX.BINDINGS.size() != 6:
        _fail("six exact skills required")
        return
    for raw_id in FX.BINDINGS:
        var id := str(raw_id)
        var binding: Dictionary = FX.BINDINGS[id]
        var definition := V63HumanSkillCombatSystem.skill_definition(id)
        if str(definition.get("shape","")) != binding["shape"] or int(definition.get("target_limit",0)) != int(binding["limit"]) or str(definition.get("effect","")) != "damage":
            _fail("semantic binding "+id)
            return
        var fx = FX.new()
        if not fx.source_ready(id):
            _fail("source assets "+id)
            return
        var battle := MapBattleV2.new(761)
        battle.encounter_id = "v8_blade_"+id
        var caster := _actor("caster","disciple",Vector2(2,2))
        var target := _actor("target","monster",Vector2(3,2))
        caster["v63_combat_branch_id"] = str(definition.get("branch",""))
        caster["v63_skill_loadout"] = [id]
        battle.actors["caster"] = caster
        battle.actors["target"] = target
        var cursor = CURSOR.new()
        fx.observe(cursor.observe_snapshot(battle),battle,true)
        if not V63HumanSkillCombatSystem.try_cast(battle,caster,target,false):
            _fail("real cast rejected "+id)
            return
        fx.observe(cursor.observe_snapshot(battle),battle,true)
        if fx.cast_count() != 1 or fx.contact_count() != 0:
            _fail("charge must not invent contact "+id)
            return
        var pending: Dictionary = caster.get("v63_pending_cast",{})
        battle.now = float(pending.get("ready",0.0))
        battle._release_casts()
        var events: Array[Dictionary] = cursor.observe_snapshot(battle)
        var hp := float(target["hp"])
        var history := battle.events.duplicate(true)
        fx.observe(events,battle,true)
        var contacts: int = fx.contact_count()
        if hp >= 2000.0 or contacts <= 0:
            _fail("real hit contact "+id)
            return
        fx.observe(events,battle,true)
        if fx.contact_count() != contacts or target["hp"] != hp or battle.events != history:
            _fail("duplicate visual or authority mutation "+id)
            return
        fx.observe([],battle,false)
        if fx.cast_count() != 0 or fx.contact_count() != 0:
            _fail("preview hold did not clear")
            return
    print("V8_BLADE_PVE_CONTRACT_PASS six_exact_skills=6 real_receipts=1 default_hold=1")
    quit(0)
