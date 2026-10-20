extends SceneTree

func _init() -> void:
    call_deferred("_run")

func check(condition: bool, detail: String) -> bool:
    if not condition:
        push_error("JXQY2 FOCUSED FAIL: "+detail)
        quit(1)
    return condition

func _run() -> void:
    var root := OS.get_environment("TMB_JXQY2_ASSET_ROOT")
    if root.is_empty():
        print("JXQY2 FOCUSED PENDING: TMB_JXQY2_ASSET_ROOT is missing")
        quit(2)
        return
    var source := Jxqy2SourceSliceV1.new()
    var loaded := source.load_sources(root)
    if not check(bool(loaded.get("ok",false)),str(loaded)):
        return
    if not check(source.verified_files == 44,"the bounded source manifest is incomplete"):
        return
    if not check(int(source.map_data["width"]) == 50 and int(source.map_data["height"]) == 100,"native MAP dimensions differ"):
        return
    var cells: PackedByteArray = source.map_data["cells"]
    var blocked_count := 0
    var trap_count := 0
    for i in range(5000):
        blocked_count += 1 if (int(cells[i*10+6]) & 0xC0) != 0 else 0
        trap_count += 1 if int(cells[i*10+7]) != 0 else 0
    if not check(blocked_count == 525 and trap_count == 26,"source collision/trap bytes differ"):
        return
    var grid := source.navigation_grid()
    var from := Vector2(21.5,45.5)
    var target := Vector2(23.5,45.5)
    if not check(not CombatWorldGridV2.segment_open(grid,from,target),"source obstacle fixture does not block the direct segment"):
        return
    for i in range(80):
        var next := CombatWorldGridV2.move_toward(grid,from,target,0.25)
        if not check(CombatWorldGridV2.segment_open(grid,from,next),"navigation crossed source collision"):
            return
        from = next
    if not check(from.distance_to(target) < 0.01,"navigation could not route around a source obstacle"):
        return
    for point in [Vector2(0.5,0.5),Vector2(14.5,5.25),Vector2(25.9,17.9)]:
        if not check(source.unproject(source.project(point)).distance_to(point) < 0.0001,"staggered projection roundtrip failed"):
            return
    for key in ["hero","wolf","boss"]:
        var actions: Array = ["idle","run","attack","hit","die"]
        if key == "hero":
            actions.append("cast")
        for action in actions:
            var resource := source.actor_resource(key,action)
            if not check(int(resource.get("directions",0)) == 8 and int(resource.get("frames_per_direction",0)) > 1,key+"/"+action+" lacks real directional animation"):
                return
            var first := source.frame_at(resource,6,0.0,true)
            var last := source.frame_at(resource,6,999.0,true)
            if not check(int(first["index"]) == 6*int(resource["frames_per_direction"]) and int(last["index"]) == 7*int(resource["frames_per_direction"])-1,"one-shot directional clip did not retain its source frame order"):
                return
    var corrupt := FileAccess.get_file_as_bytes(root.path_join("mpc/magic/天意剑诀.mpc"))
    corrupt.resize(50)
    if not check(not bool(Jxqy2SourceSliceV1.decode_mpc(corrupt).get("ok",false)),"truncated art was accepted"):
        return
    # Real dispatch must carry the selected disabled policy, reserve the one
    # canonical participant, persist source navigation and resume identically.
    var built := Jxqy2DemoProfileV1.create()
    if not check(bool(built.get("ok",false)),str(built)):
        return
    var state: SimulationState = built["state"]
    var id := StringName(str(built["source_hunter_id"]))
    var disciple: DiscipleState = state.disciples[id]
    var skills := CombatSkillSystem.new()
    if not check(&"ngu_kiem_thuat" in skills.usable_skills(state,disciple),"legal skill fixture could not learn via the canonical API"):
        return
    var owned: Array = []
    for skill in skills.usable_skills(state,disciple):
        if str(skills.definition(skill).get("effect","")) == "damage":
            owned.append(str(skill))
    var policy := AutoSkillPolicyV2.default_policy(owned)
    for row in policy["skills"]:
        row["enabled"] = false
    HuntingMapV2.choose_level(state,"thanh_truc_lam",5)
    var run := HuntingPveRunV2.new()
    var started := run.begin(state,"thanh_truc_lam","jxqy2_source_focused",20261020,
        [{"disciple_id":str(id),"party_id":"source_party","role":"ranged","position":Vector2(4.0,3.0),"auto_skill_policy":policy}],true,{"navigation_grid":grid,"spawn_offset":Vector2(7,40)})
    if not check(bool(started.get("ok",false)),str(started)):
        return
    if not check(run.battle.world_bounds().size == Vector2(50,100),"source world retained the legacy arena bounds"):
        return
    if not check(str(run.battle.actors[str(id)].get("visual_weapon_path","")) == "sword","source sword actor was paired with another weapon family"):
        return
    ProjectSettings.set_setting("runtime/live_save_path","user://demo_sandbox/jxqy2_focused_save.json")
    if not check(DemoAutoSkillPolicyStoreV1.path_for_active_save() != DemoAutoSkillPolicyStoreV1.SAVE_PATH,"source-slice policies overlap the M1 demo policy file"):
        return
    for row in run.battle.actors[str(id)]["auto_skill_policy"]["skills"]:
        if not check(not bool(row["enabled"]),"real hunting dispatch discarded the user's disabled skill policy"):
            return
    if not check(disciple.active_pve_encounter_id == run.battle.encounter_id,"canonical active-job reservation was not retained"):
        return
    var strict_restored := MapBattleSnapshotV2.load(MapBattleSnapshotV2.save(run.battle))
    if not check(bool(strict_restored.get("ok",false)),"configured policy checkpoint did not restore"):
        return
    var strict: MapBattleV2 = strict_restored["battle"]
    var strict_actor: Dictionary = strict.actors[str(id)]
    strict_actor["auto_skill_policy"]["basic_fallback"] = false
    strict_actor["hp"] = float(strict_actor["max_hp"])*0.5
    strict_actor["role"] = "healer"
    strict.step()
    strict_actor["role"] = "frontline"
    strict_actor["next_skill"] = 0.0
    strict.step()
    for event in strict.events:
        if not check(str(event.get("type","")) not in ["heal","guard","cast"],"configured auto-combat granted an unlearned role spell"):
            return
    for i in range(420):
        run.battle.step()
    if not check(run.battle.active and run.battle.now > 90.0 and run.battle.world_waves_completed > 0,"source-map roaming did not continue past 90 seconds with respawns"):
        return
    var view := MapBattleWorldLayerV2.new()
    view.enable_source_vl_art = true
    view.enable_spectator_framing = true
    view.jxqy2 = source
    view.attach_session(run.battle)
    var original_camera: Vector2 = view._camera_center
    view.pan_camera_pixels(Vector2(0,-250))
    if not check(view._camera_center.y > 20.0 and view._camera_center.distance_to(original_camera) > 5.0 and view.current_camera_follow_id().is_empty(),"free source-map camera remained constrained to the legacy arena"):
        return
    var monster_id := ""
    for actor_id in run.battle.actors:
        if str(run.battle.actors[actor_id]["side"]) == "monster":
            monster_id = str(actor_id)
            break
    view._action_cues[monster_id] = {"action":"die","started":0.0,"until":INF}
    run.battle._event("world_wave_spawned",{"wave":run.battle.world_waves_completed+1})
    view.refresh_from_authority()
    if not check(not view._action_cues.has(monster_id),"respawn retained the dead actor's animation cue"):
        return
    view.free()
    var restored := MapBattleSnapshotV2.load(MapBattleSnapshotV2.save(run.battle))
    if not check(bool(restored.get("ok",false)),str(restored)):
        return
    var resumed: MapBattleV2 = restored["battle"]
    if not check(resumed.navigation_grid == grid,"source navigation was lost through the save checkpoint"):
        return
    for i in range(24):
        run.battle.step()
        resumed.step()
    for actor_id in run.battle.actors:
        if not check(run.battle.actors[actor_id]["position"] == resumed.actors[actor_id]["position"] and run.battle.actors[actor_id]["hp"] == resumed.actors[actor_id]["hp"],"resumed navigation/damage diverged"):
            return
    for event in run.battle.events:
        if not check(str(event.get("type","")) != "skill_cast","a disabled skill was cast after real dispatch"):
            return
    print("JXQY2 FOCUSED PASS: 44 hashes; full 50x100 MAP; 525 blocked; 26 trap; 16 directional clips including native acMagic; navigation; 111s continuous; learned/configured spells only; actual dispatch policy; deterministic checkpoint. School/weapon learning constraints remain partial.")
    quit(0)
