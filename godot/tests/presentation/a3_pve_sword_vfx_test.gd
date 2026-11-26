extends SceneTree
const FX = preload("res://src/presentation/p3/pve_a3_sword_vfx.gd")
const RENDERER = preload("res://src/presentation/p3/pve_aschar_frame_renderer_v1.gd")
const HSC = preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const CURSOR = preload("res://src/presentation/p3/pve_jx_sword_vfx_adapter_v1.gd")

func _initialize() -> void:
    call_deferred("_run")

func _actor(id: String,side: String,position: Vector2) -> Dictionary:
    var resistances: Dictionary = {}
    for element in ["metal","wood","water","fire","earth","lightning","wind","ice","yang","nether"]:
        resistances[element] = 0.0
    return {"id":id,"side":side,"role":"melee","position":position,"hp":2000.0,"max_hp":2000.0,"range":1.8,"move_speed":2.0,
        "stats":{"attack":40.0,"defense":0.0,"damage_reduction":0.0,"crit_chance":0.0,"crit_damage":1.5,"crit_resistance":0.0,"defense_penetration":0.0,"lifesteal":0.0,"lifesteal_reduction":0.0},
        "resistances":resistances,"tier":"normal","race_id":"yeu_thu","status_effects":{},"context_sources":[],"v63_combat_enabled":true,"v63_sword_combat_enabled":true,"v63_skill_ready":{},"v63_skill_loadout":[],"v63_passive_ids":[],"v63_combat_clock":-1.0,"next_skill":0.0}

func _fail(reason: String) -> void:
    push_error("A3_PVE_FAIL "+reason)
    quit(1)

func _run() -> void:
    if V63FeatureGates.is_enabled("sword_skill_combat") or bool(ProjectSettings.get_setting(FX.PREVIEW_SETTING,false)):
        _fail("default gate opened")
        return
    if RENDERER.frame_index("cast",0.40,4,0.40) != 3 or RENDERER.frame_index("attack",2.0,4) != 3 or RENDERER.frame_index("walk",0.5,4) != 0:
        _fail("one-shot or loop contract")
        return
    for id in FX.BINDINGS:
        var binding: Dictionary = FX.BINDINGS[id]
        var definition := HSC.skill_definition(str(id))
        if str(definition.get("shape","")) != binding["shape"] or int(definition.get("target_limit",0)) != int(binding["limit"]) or str(definition.get("effect","")) != "damage":
            _fail("semantic mapping "+str(id))
            return
        var fx = FX.new()
        if fx.texture_for(str(id)) == null:
            _fail("runtime atlas "+str(id))
            return
        var battle := MapBattleV2.new(761)
        battle.encounter_id = "a3_"+str(binding["tag"])
        var caster := _actor("caster","disciple",Vector2(2,2))
        var target := _actor("target","monster",Vector2(3,2))
        caster["v63_combat_branch_id"] = str(definition.get("branch",""))
        caster["v63_skill_loadout"] = [str(id)]
        battle.actors["caster"] = caster
        battle.actors["target"] = target
        var cursor = CURSOR.new()
        fx.observe(cursor.observe_snapshot(battle),battle,true)
        if not HSC.try_cast(battle,caster,target,false):
            _fail("real cast "+str(id))
            return
        var events: Array[Dictionary] = cursor.observe_snapshot(battle)
        fx.observe(events,battle,true)
        if fx.cues().size() != 1 or str(fx.cues()[0]["phase"]) != "charge":
            _fail("real charge "+str(id))
            return
        var pending: Dictionary = caster.get("v63_pending_cast",{})
        battle.now = float(pending.get("ready",0.0))
        battle._release_casts()
        events = cursor.observe_snapshot(battle)
        var hp := float(target["hp"])
        var snapshot := battle.events.duplicate(true)
        fx.observe(events,battle,true)
        var contact_count := 0
        for cue in fx.cues():
            if str(cue["phase"]) == "contact":
                contact_count += 1
        if hp >= 2000.0 or contact_count != 1:
            _fail("real confirmed hit "+str(id)+" hp="+str(hp)+" contacts="+str(contact_count)+" events="+str(events))
            return
        fx.observe(events,battle,true)
        if fx.cues().size() != 1 or target["hp"] != hp or battle.events != snapshot:
            _fail("duplicate or authority mutation "+str(id))
            return
        var restored = FX.new()
        restored.observe([],battle,true)
        if not restored.cues().is_empty():
            _fail("historic event replay")
            return
        fx.observe([],battle,false)
        if not fx.cues().is_empty():
            _fail("hold did not clear")
            return
    print("A3_PVE_CONTRACT_PASS skills=%d real_casts=%d real_positive_hits=%d default_hold=1" % [FX.BINDINGS.size(),FX.BINDINGS.size(),FX.BINDINGS.size()])
    quit(0)
