extends SceneTree

const PREVIEW := {"sect_codex":true,"human_skill_combat":true}
const BRANCH_IDS := ["liep_anh","linh_tien","thien_vu","ba_quyen","kim_cang","huyet_quyen","doc_cham","co_doc","duoc_doc"]

func _init() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("V63_D4B_BRANCH_BOSS_FAIL: "+message)
    quit(1)

func _check(value: bool, message: String) -> bool:
    if not value:
        _fail(message)
        return false
    return true

func _run() -> void:
    if V63FeatureGates.is_enabled("human_skill_combat"):
        _fail("Human combat gate must remain OFF by default")
        return
    var loaded := V63HumanSkillCombatSystem.load_catalogue()
    if not bool(loaded.get("ok",false)):
        _fail("D4-B catalog invalid: "+str(loaded.get("errors",[])))
        return
    if not _check(loaded.data.skills.size() == 105 and loaded.data.branches.size() == 9 and loaded.data.bosses.size() == 3,"catalog does not cover 105 Human nodes, 9 branches, 3 bosses"):
        return
    for branch_id in BRANCH_IDS:
        if not _check(_branch_coverage(loaded.data.skills,branch_id),"slot coverage is incomplete for "+branch_id):
            return
        var skill_id := "tmb.skill.%s.%s.active_01.human" % [_school(branch_id),branch_id]
        var definition := V63HumanSkillCombatSystem.skill_definition(skill_id)
        if not _check(not definition.is_empty() and bool(definition.get("archivable",false)),"active_01 missing for "+branch_id):
            return
        var state := _new_state()
        var disciple := DiscipleState.new({"id":"d4b_"+branch_id,"name":branch_id})
        state.disciples[disciple.id] = disciple
        if not _archive_learn_equip(state,disciple,skill_id):
            return
        var core := CombatStatsV2.derive(1,1,1,1,0.0)
        var stats: Dictionary = core.stats.duplicate(true)
        stats["max_hp"] = 5000.0
        stats["attack"] = 90.0
        stats["defense"] = 30.0
        var actor := {"id":str(disciple.id),"party_id":"d4b_"+branch_id,"role":"ranged","tier":"disciple",
            "race_id":"nhan_toc","position":Vector2(18.0,8.0),"stats":stats,"hp":5000.0,"max_hp":5000.0,
            "resistances":core.resistances.duplicate(true),"basic_range":5.5,"move_speed":2.0,
            "basic_ratio":1.0,"basic_interval":1.5,"skill_loadout":[],"skill_factors":{},
            "context_sources":[],"disciple":null}
        var attached := V63HumanSkillCombatSystem.attach_disciple_loadout(state,actor,PREVIEW)
        if not _check(bool(attached.get("ok",false)) and str(actor.get("v63_innate_skill_id","")) == str(_branch_innate(loaded.data.branches,branch_id)),"derived branch innate not attached: "+branch_id):
            return
        var monster_result := MonsterCatalogueV2.create_actor("truc_thu",1,1,"d4b_target_"+branch_id)
        var monster: Dictionary = monster_result.duplicate(true)
        monster["id"] = "target_"+branch_id
        monster["position"] = Vector2(22.0,8.0)
        var battle := MapBattleV2.new(90100+BRANCH_IDS.find(branch_id))
        var setup := battle.setup("d4b_branch_"+branch_id,[actor],[monster])
        if not _check(bool(setup.get("ok",false)),"MapBattle rejected "+branch_id+": "+str(setup)):
            return
        battle.run(120)
        var cast_seen := false
        var hit_seen := false
        for event in battle.events:
            if str(event.get("type","")) == "skill_cast" and str(event.get("skill_id","")) == skill_id:
                cast_seen = true
            if str(event.get("type","")) == "v63_skill_hit" and str(event.get("skill_id","")) == skill_id and float(event.get("damage",0.0)) > 0.0:
                hit_seen = true
        if not _check(cast_seen and hit_seen,"branch did not cast through Combat V2: "+branch_id):
            return
    if not _shared_school_test():
        return
    if not _full_loadout_test():
        return
    for boss in loaded.data.bosses:
        if not _boss_combat(str(boss.id)):
            return
    print("V63 D4-B HUMAN BRANCHES/BOSSES PASS: 9/9 manual-backed branch casts; 105 nodes; 3/3 real boss AI telegraph/release; derived innates and one-time phases")
    quit(0)

func _shared_school_test() -> bool:
    for school in ["bow","fist","poison"]:
        var state := _new_state()
        var disciple := DiscipleState.new({"id":"shared_"+school,"name":school})
        state.disciples[disciple.id] = disciple
        var basic_id := "tmb.skill.%s.basic.human" % school
        var mobility_id := "tmb.skill.%s.mobility.human" % school
        if not _archive_learn_equip(state,disciple,basic_id) or not _archive_learn_equip(state,disciple,mobility_id):
            return false
        var core := CombatStatsV2.derive(1,1,1,1,0.0)
        var stats: Dictionary = core.stats.duplicate(true)
        stats["max_hp"] = 10000.0
        stats["attack"] = 80.0
        var actor := {"id":str(disciple.id),"party_id":"shared_"+school,"role":"ranged","tier":"disciple",
            "race_id":"nhan_toc","position":Vector2(10.0,10.0),"stats":stats,"hp":10000.0,"max_hp":10000.0,
            "resistances":core.resistances.duplicate(true),"basic_range":5.5,"move_speed":2.0,
            "basic_ratio":1.0,"basic_interval":1.5,"skill_loadout":[],"skill_factors":{},
            "context_sources":[],"disciple":null}
        if not _check(bool(V63HumanSkillCombatSystem.attach_disciple_loadout(state,actor,PREVIEW).get("ok",false)),"shared school skills failed attach: "+school):
            return false
        var monster_result := MonsterCatalogueV2.create_actor("truc_thu",1,1,"shared_target_"+school)
        var monster: Dictionary = monster_result.duplicate(true)
        monster["id"] = "shared_target_"+school
        monster["position"] = Vector2(20.0,10.0)
        var battle := MapBattleV2.new(91200+["bow","fist","poison"].find(school))
        if not _check(bool(battle.setup("shared_"+school,[actor],[monster]).get("ok",false)),"MapBattle rejected shared school loadout: "+school):
            return false
        battle.run(40)
        var mobility_seen := false
        var basic_seen := false
        for event in battle.events:
            if str(event.get("type","")) == "v63_mobility" and str(event.get("skill_id","")) == mobility_id:
                mobility_seen = true
            if str(event.get("type","")) == "hit" and str(event.get("attacker","")) == str(disciple.id) and str(event.get("kind","")) == "basic" and float(event.get("damage",0.0)) > 0.0:
                basic_seen = true
        if not _check(mobility_seen and basic_seen,"shared basic/mobility did not execute for school "+school):
            return false
    return true
func _full_loadout_test() -> bool:
    var state := _new_state()
    var disciple := DiscipleState.new({"id":"full_liep_anh","name":"Full Loadout"})
    state.disciples[disciple.id] = disciple
    var skill_ids: Array[String] = ["tmb.skill.bow.basic.human","tmb.skill.bow.mobility.human"]
    for slot_index in range(1,5):
        skill_ids.append("tmb.skill.bow.liep_anh.active_%02d.human" % slot_index)
    skill_ids.append("tmb.skill.bow.liep_anh.ultimate.human")
    for passive_index in range(1,6):
        skill_ids.append("tmb.skill.bow.liep_anh.passive_%02d.human" % passive_index)
    for skill_id in skill_ids:
        if not _archive_learn_equip(state,disciple,skill_id):
            return false
    if not _check(disciple.v63_equipped_skill_ids.size() == 12 and disciple.v63_combat_branch_id == &"liep_anh","one basic + four active + ultimate + mobility + five passive did not fit the twelve authored slots"):
        return false
    var actor: Dictionary = {"id":str(disciple.id)}
    var attached := V63HumanSkillCombatSystem.attach_disciple_loadout(state,actor,PREVIEW)
    var canonical_basic: Dictionary = V63HumanSkillCombatSystem.skill_definition("tmb.skill.bow.basic.human")
    var expected_basic_range := float(canonical_basic.get("range",-1.0))
    var actual_basic_range := float(actor.get("basic_range",0.0))
    if not _check(bool(attached.get("ok",false)) and actor.v63_skill_loadout.size() == 12 and actor.v63_passive_ids.size() == 5
            and str(actor.get("v63_basic_skill_id","")) == "tmb.skill.bow.basic.human"
            and expected_basic_range > 0.0 and is_equal_approx(actual_basic_range,expected_basic_range),
            "full personal loadout did not attach canonical basic range: expected=%s actual=%s skill=%s" % [expected_basic_range,actual_basic_range,str(actor.get("v63_basic_skill_id",""))]):
        return false
    return _check(V63HumanSkillCombatSystem.validate_state(state).is_empty(),"full Human branch loadout failed state invariants")
func _branch_coverage(skills: Array, branch_id: String) -> bool:
    var counts := {"active":0,"passive":0,"ultimate":0,"innate":0}
    for row in skills:
        if str(row.get("branch","")) == branch_id:
            var slot := str(row.get("slot",""))
            if counts.has(slot):
                counts[slot] += 1
    return counts.active == 4 and counts.passive == 5 and counts.ultimate == 1 and counts.innate == 1

func _school(branch_id: String) -> String:
    if branch_id in ["liep_anh","linh_tien","thien_vu"]:
        return "bow"
    if branch_id in ["ba_quyen","kim_cang","huyet_quyen"]:
        return "fist"
    return "poison"

func _branch_innate(branches: Array, branch_id: String) -> String:
    for row in branches:
        if str(row.id) == branch_id:
            return str(row.innate_node_id)
    return ""

func _new_state() -> SimulationState:
    var state := SimulationState.new()
    state.sect.disciple_capacity = 12
    state.p3_7_buildings_enabled = true
    state.sect.p3_7_resources_enabled = true
    state.sect.v63_archive_opt_in = true
    state.sect.v63_skill_combat_opt_in = true
    return state

func _archive_learn_equip(state: SimulationState, disciple: DiscipleState, skill_id: String) -> bool:
    var skill := V63HumanSkillCombatSystem.skill_definition(skill_id)
    var codex_id := str(skill.get("source_codex_id",""))
    var codex := V63SectArchiveSystem.codex_definition(codex_id)
    var manual_id := StringName(str(codex.get("manual_item_id","")))
    var warehouse := WarehouseSystem.new()
    if codex.is_empty() or not warehouse.registry.has(manual_id) or not warehouse.add(state,manual_id,1):
        _fail("could not put authentic archive manual in Warehouse for "+skill_id)
        return false
    if not bool(V63SectArchiveSystem.archive_manual(state,codex_id,PREVIEW).get("ok",false)):
        _fail("D2 Archive rejected source manual "+codex_id)
        return false
    if not bool(V63HumanSkillCombatSystem.learn_skill(state,disciple,skill_id,PREVIEW).get("ok",false)):
        _fail("disciple could not learn archived skill "+skill_id)
        return false
    if not bool(V63HumanSkillCombatSystem.equip_skill(state,disciple,skill_id,PREVIEW).get("ok",false)):
        _fail("disciple could not equip personally learned skill "+skill_id)
        return false
    return true

func _boss_combat(boss_id: String) -> bool:
    var spawned := HuntingMapV2.spawn("thanh_truc_lam",1,"d4b_boss_"+boss_id,91400+abs(boss_id.hash()%5000))
    if not bool(spawned.get("ok",false)):
        return _check(false,"map source failed for "+boss_id)
    var installed := V63HumanSkillCombatSystem.install_boss_spawn(spawned,boss_id)
    if not bool(installed.get("ok",false)):
        return _check(false,"Human boss did not install from existing map: "+boss_id+" "+str(installed))
    var boss: Dictionary = installed.boss_actor.duplicate(true)
    var pos: Vector2 = boss.get("position",Vector2(20,8))
    var core := CombatStatsV2.derive(1,1,1,1,0.0)
    var stats: Dictionary = core.stats.duplicate(true)
    stats["max_hp"] = 5000.0
    stats["attack"] = 1.0
    stats["defense"] = 25.0
    var party := [{"id":"party_"+boss_id,"party_id":"party_boss","role":"frontline","tier":"disciple","race_id":"nhan_toc",
        "position":pos+Vector2(-1.0,0.0),"stats":stats,"hp":5000.0,"max_hp":5000.0,
        "resistances":core.resistances.duplicate(true),"basic_range":1.5,"move_speed":1.0,
        "basic_ratio":0.01,"basic_interval":9.0,"skill_loadout":[],"skill_factors":{},"context_sources":[],"disciple":null}]
    var battle := MapBattleV2.new(abs(boss_id.hash()))
    if not _check(bool(battle.setup("d4b_real_boss_"+boss_id,party,[boss]).get("ok",false)),"boss could not enter MapBattleV2: "+boss_id):
        return false
    var boss_actor_precast: Dictionary = battle.actors.get(str(boss.id),{})
    for _step in range(40):
        battle.step()
        var pending = boss_actor_precast.get("v63_pending_cast",{})
        if pending is Dictionary and not pending.is_empty():
            break
    var boss_pending = boss_actor_precast.get("v63_pending_cast",{})
    if not _check(boss_pending is Dictionary and not boss_pending.is_empty(),"boss did not save a pending telegraph before resume: "+boss_id):
        return false
    var snapshot := MapBattleSnapshotV2.save(battle)
    var restored := MapBattleSnapshotV2.load(snapshot)
    if not _check(bool(restored.get("ok",false)) and not V63HumanSkillCombatSystem.validate_battle(restored.battle,boss_id).size(),"boss pending cast snapshot failed: "+boss_id):
        return false
    var resumed: MapBattleV2 = restored.battle
    resumed.run(120)
    var telegraph := false
    var released := false
    for event in resumed.events:
        if str(event.get("type","")) == "telegraph" and str(event.get("boss_id","")) == boss_id:
            telegraph = true
        if str(event.get("type","")) == "v63_skill_hit" and str(event.get("skill_id","")).begins_with("tmb.bossskill.") and (float(event.get("damage",0.0)) > 0.0 or str(event.get("effect","")) in ["guard","poison","mark"]):
            released = true
    if not _check(telegraph and released,"boss did not telegraph and release an action: "+boss_id):
        return false
    var boss_actor: Dictionary = resumed.actors.get(str(boss.id),{})
    var hp_before := float(boss_actor.get("hp",0.0))
    boss_actor["hp"] = float(boss_actor.get("max_hp",1.0))*0.30
    V63HumanSkillCombatSystem.observe_boss_damage(resumed,boss_actor,hp_before)
    var phases := []
    for event in resumed.events:
        if str(event.get("type","")) == "v63_boss_phase" and str(event.get("boss_id","")) == boss_id:
            phases.append(int(event.get("phase",0)))
    if not _check(phases.has(2) and phases.has(3),"boss 70/35 transitions were skipped or not idempotent: "+boss_id+" "+str(phases)):
        return false
    var prior := phases.size()
    V63HumanSkillCombatSystem.observe_boss_damage(resumed,boss_actor,hp_before)
    var after := 0
    for event in resumed.events:
        if str(event.get("type","")) == "v63_boss_phase" and str(event.get("boss_id","")) == boss_id:
            after += 1
    return _check(prior == after,"boss phase transition repeated after threshold: "+boss_id)
