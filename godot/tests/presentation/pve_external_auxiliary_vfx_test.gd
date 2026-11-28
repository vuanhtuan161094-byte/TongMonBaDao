extends SceneTree
const FX = preload("res://src/presentation/p3/pve_factory_sprite_v1.gd")
const CURSOR = preload("res://src/presentation/p3/pve_jx_sword_vfx_adapter_v1.gd")
func _initialize() -> void:
    call_deferred("_run")
func _fail(message: String) -> void:
    push_error("EXTERNAL_AUX_FAIL "+message)
    quit(1)
func _actor(id: String,side: String,position: Vector2) -> Dictionary:
    var resistances: Dictionary = {}
    for element in CombatStatsV2.ELEMENTS:
        resistances[element]=0.0
    return {"id":id,"side":side,"role":"healer","position":position,"hp":800.0,"max_hp":2000.0,"range":2.0,"move_speed":2.0,"tier":"normal","race_id":"yeu_thu","stats":{"attack":40.0,"defense":0.0,"damage_reduction":0.0,"crit_chance":0.0,"crit_damage":1.5,"crit_resistance":0.0,"defense_penetration":0.0,"lifesteal":0.0,"lifesteal_reduction":0.0},"resistances":resistances,"status_effects":{"slow":{"until":20.0,"movement_factor":0.7}},"context_sources":[],"v63_combat_enabled":true,"v63_palm_combat_enabled":true,"v63_skill_ready":{},"v63_skill_loadout":[],"v63_passive_ids":[],"v63_combat_clock":-1.0,"next_skill":0.0}
func _run() -> void:
    var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(FX.EXTERNAL_INDEX))
    var bindings: Dictionary = raw.get("bindings",{})
    if bindings.size() != 19 or bool(ProjectSettings.get_setting(FX.EXTERNAL_PREVIEW_SETTING,false)):
        _fail("candidate count/default gate")
        return
    var disabled = FX.new()
    disabled._ensure_index()
    for raw_id in bindings:
        var id := str(raw_id)
        if not disabled._binding(id).is_empty():
            _fail("default gate exposed "+id)
            return
    ProjectSettings.set_setting(FX.EXTERNAL_PREVIEW_SETTING,true)
    var enabled = FX.new()
    enabled._ensure_index()
    for raw_id in bindings:
        var id := str(raw_id)
        var e: Dictionary = enabled._binding(id)
        var d := V63HumanSkillCombatSystem.skill_definition(id)
        if e.is_empty() or str(d.get("effect",""))!=str(e["effect"]) or str(d.get("shape",""))!=str(e["shape"]) or int(d.get("target_limit",0))!=int(e["limit"]):
            _fail("canonical mismatch "+id)
            return
        if FX.external_receipt_allowed(e,{"type":"heal","amount":0.0}) or FX.external_receipt_allowed(e,{"type":"cleanse","removed_debuff_count":0}) or FX.external_receipt_allowed(e,{"type":"status_applied","status":"slow"}):
            _fail("false auxiliary receipt "+id)
            return
        for frame in e["phases"]["contact"]["frames"]:
            var tex := load(str(frame["path"])) as Texture2D
            var b: Array=frame["region"]
            if tex==null or not Rect2(Vector2.ZERO,tex.get_size()).encloses(Rect2(float(b[0]),float(b[1]),float(b[2]),float(b[3]))):
                _fail("texture/region "+id)
                return
    var real_count := 0
    for id in ["tmb.skill.palm.hoi_phong_chuong.active_01.human","tmb.skill.palm.hoi_phong_chuong.active_03.human","tmb.skill.palm.hoi_phong_chuong.active_04.human"]:
        var battle := MapBattleV2.new(761)
        battle.encounter_id = "external_aux_"+id
        var caster := _actor("caster","disciple",Vector2(2,2))
        var target := _actor("enemy","monster",Vector2(3,2))
        caster["v63_combat_branch_id"]="hoi_phong_chuong"
        caster["v63_skill_loadout"]=[id]
        battle.actors["caster"]=caster
        battle.actors["enemy"]=target
        var renderer = FX.new()
        var cursor = CURSOR.new()
        renderer.observe(cursor.observe_snapshot(battle),battle)
        if not V63HumanSkillCombatSystem.try_cast(battle,caster,target,false):
            _fail("real cast rejected "+id)
            return
        renderer.observe(cursor.observe_snapshot(battle),battle)
        if not renderer._cues.is_empty():
            _fail("premature auxiliary cue "+id)
            return
        battle.now=float(caster.get("v63_pending_cast",{}).get("ready",0.0))
        battle._release_casts()
        var events: Array[Dictionary]=cursor.observe_snapshot(battle)
        var snapshot := battle.events.duplicate(true)
        renderer.observe(events,battle)
        if renderer._cues.is_empty() or battle.events!=snapshot:
            _fail("real receipt absent or mutated "+id+" "+str(events))
            return
        real_count+=1
    # Exercise the same renderer instance used by OneGame when the player
    # toggles the preview; no stale cached bindings after disabling.
    enabled._ensure_index()
    ProjectSettings.set_setting(FX.EXTERNAL_PREVIEW_SETTING,false)
    enabled._ensure_index()
    for raw_id in bindings:
        if not enabled._binding(str(raw_id)).is_empty():
            _fail("stale external binding after disable "+str(raw_id))
            return
    ProjectSettings.set_setting(FX.EXTERNAL_PREVIEW_SETTING,true)
    enabled._ensure_index()
    for raw_id in bindings:
        if enabled._binding(str(raw_id)).is_empty():
            _fail("missing external binding after re-enable "+str(raw_id))
            return
    ProjectSettings.set_setting(FX.EXTERNAL_PREVIEW_SETTING,false)
    print("EXTERNAL_AUX_CONTRACT_PASS candidate_bindings=19 real_casts=",real_count," default_hold=1 hot_toggle=1")
    quit(0)
