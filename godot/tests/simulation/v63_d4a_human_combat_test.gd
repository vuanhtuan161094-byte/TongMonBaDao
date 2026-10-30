extends SceneTree

const PREVIEW := {"sect_codex":true,"human_skill_combat":true}
const SKILL_ID := "tmb.skill.bow.liep_anh.active_01.human"
const CODEX_ID := "tmb.codex.bow.liep_anh.ch1_active_01.human.base"
const BOSS_ID := "tmb.boss.thiet_giap_son_vien"

func _init() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("V63_D4A_HUMAN_COMBAT_FAIL: "+message)
    quit(1)

func _run() -> void:
    if V63FeatureGates.is_enabled("human_skill_combat"):
        _fail("D4 human combat gate must default OFF")
        return
    var loaded := V63HumanSkillCombatSystem.load_catalogue()
    if not bool(loaded.get("ok",false)):
        _fail("candidate catalogue did not validate: "+str(loaded.get("errors",[])))
        return
    var state := SimulationState.new()
    state.sect.disciple_capacity = 12
    state.p3_7_buildings_enabled = true
    state.sect.p3_7_resources_enabled = true
    state.sect.v63_archive_opt_in = true
    state.sect.v63_skill_combat_opt_in = true
    var codex := V63SectArchiveSystem.codex_definition(CODEX_ID)
    var manual_id := StringName(str(codex.get("manual_item_id","")))
    var warehouse := WarehouseSystem.new()
    if codex.is_empty() or not warehouse.registry.has(manual_id) or not warehouse.add(state,manual_id,1):
        _fail("could not place the authentic D2 manual in the canonical Warehouse")
        return
    var archive_result := V63SectArchiveSystem.archive_manual(state,CODEX_ID,PREVIEW)
    if not bool(archive_result.get("ok",false)):
        _fail("D2 archive did not grant the combat transmission: "+str(archive_result))
        return
    var system := V63HumanSkillCombatSystem.new()
    var disciples: Array = []
    for index in range(6):
        var disciple := DiscipleState.new({"id":"d4_archer_%02d" % index,"name":"Liệp Ảnh %d" % index})
        state.disciples[disciple.id] = disciple
        disciples.append(disciple)
        var learned := system.learn_skill(state,disciple,SKILL_ID,PREVIEW)
        if not bool(learned.get("ok",false)):
            _fail("archived manual did not grant personal knowledge: "+str(learned))
            return
        var equipped := system.equip_skill(state,disciple,SKILL_ID,PREVIEW)
        if not bool(equipped.get("ok",false)):
            _fail("personally learned Human skill did not equip: "+str(equipped))
            return
    var gate_disciple := DiscipleState.new({"id":"gate_off"})
    state.disciples[gate_disciple.id] = gate_disciple
    var legacy_denial := system.learn_skill(state,gate_disciple,SKILL_ID,{})
    if bool(legacy_denial.get("ok",false)):
        _fail("gate-off request learned a V6.3 combat skill")
        return
    if system.try_cast(null,{"side":"monster","v63_custom_boss_ai":true,"v63_combat_enabled":false},{"id":"target"},false):
        _fail("gate-off Human boss attempted to start a V6.3 cast")
        return

    var spawned := HuntingMapV2.spawn("thanh_truc_lam",1,"d4a_human_boss",740531)
    if not bool(spawned.get("ok",false)):
        _fail("existing map spawn source failed: "+str(spawned))
        return
    var installed := V63HumanSkillCombatSystem.install_boss_spawn(spawned,BOSS_ID)
    if not bool(installed.get("ok",false)):
        _fail("Human-stage boss did not install into the existing map roster: "+str(installed))
        return
    var boss: Dictionary = installed.boss_actor.duplicate(true)
    var boss_stats: Dictionary = boss.stats.duplicate(true)
    boss_stats["max_hp"] = float(boss_stats.max_hp)*6.0
    boss_stats["attack"] = 24.0
    boss_stats["defense"] = 18.0
    boss["stats"] = boss_stats
    boss["hp"] = float(boss_stats.max_hp)*0.65

    var core := CombatStatsV2.derive(1,1,1,1,0.0)
    if not bool(core.get("ok",false)):
        _fail("CombatStatsV2 test actor core did not derive")
        return
    var party: Array = []
    var positions := [Vector2(19,7),Vector2(20,8),Vector2(19,10),Vector2(20,11),Vector2(18,9),Vector2(21,9)]
    for index in range(6):
        var disciple: DiscipleState = disciples[index]
        var stats: Dictionary = core.stats.duplicate(true)
        stats["max_hp"] = 5000.0
        stats["attack"] = 12.0
        stats["defense"] = 20.0
        var actor := {
            "id":str(disciple.id),"party_id":"d4_six","role":"ranged",
            "tier":"disciple","race_id":"nhan_toc","position":positions[index],
            "stats":stats,"hp":5000.0,"max_hp":5000.0,
            "resistances":core.resistances.duplicate(true),
            "basic_range":5.5,"move_speed":2.0,"basic_ratio":1.0,"basic_interval":2.0,
            "skill_loadout":[],"skill_factors":{},"context_sources":[],"disciple":null
        }
        var attached := V63HumanSkillCombatSystem.attach_disciple_loadout(state,actor,PREVIEW)
        if not bool(attached.get("ok",false)) or not bool(attached.get("attached",false)):
            _fail("D4 actor did not receive its own equipped skill: "+str(attached))
            return
        party.append(actor)
    var battle := MapBattleV2.new(740531)
    var setup := battle.setup("d4a_human_boss",party,[boss])
    if not bool(setup.get("ok",false)):
        _fail("Combat V2 rejected the six-person/boss roster: "+str(setup))
        return
    if not _check_step(battle.step()):
        return
    var saved := MapBattleSnapshotV2.save(battle)
    if not _check(bool(saved.get("ok",false)),"mid-cast Combat V2 snapshot failed"):
        return
    var decoded := MapBattleSnapshotV2.load(saved)
    if not _check(bool(decoded.get("ok",false)),"mid-cast Combat V2 snapshot did not reload: "+str(decoded)):
        return
    var resumed: MapBattleV2 = decoded.battle
    var pending_v63 := 0
    for actor_value in resumed.actors.values():
        var actor: Dictionary = actor_value
        var cast = actor.get("v63_pending_cast",{})
        if cast is Dictionary and str(cast.get("v63_skill_id","")) == SKILL_ID:
            pending_v63 += 1
    if not _check(pending_v63 == 6,"snapshot lost one or more six-actor Human casts: %d" % pending_v63):
        return
    for disciple in disciples:
        var actor: Dictionary = resumed.actors[str(disciple.id)]
        if not _check(actor.get("v63_skill_loadout",[]) == [SKILL_ID],
            "snapshot lost personal equipped action for "+str(disciple.id)):
            return
    var snapshot_errors := V63HumanSkillCombatSystem.validate_battle(resumed,BOSS_ID)
    if not _check(snapshot_errors.is_empty(),"D4 snapshot failed actor/cast provenance: "+str(snapshot_errors)):
        return
    resumed.run(220)
    var actor_casts: Dictionary = {}
    var real_human_hits := 0
    var boss_telegraphs := 0
    var boss_phase_changes := 0
    var boss_skill_hits := 0
    for event in resumed.events:
        var event_type := str(event.get("type",""))
        if event_type == "skill_cast" and str(event.get("combat_family","")) == "v63_human":
            actor_casts[str(event.get("actor_id",""))] = true
        elif event_type == "v63_skill_hit":
            if str(event.get("skill_id","")).begins_with("tmb.bossskill."):
                boss_skill_hits += 1
            elif str(event.get("skill_id","")) == SKILL_ID and float(event.get("damage",0.0)) > 0.0:
                real_human_hits += 1
        elif event_type == "telegraph" and str(event.get("boss_id","")) == BOSS_ID:
            boss_telegraphs += 1
        elif event_type == "v63_boss_phase":
            boss_phase_changes += 1
    if not _check(actor_casts.size() == 6,"not all six actors auto-cast the personally equipped Human skill: "+str(actor_casts)):
        return
    if not _check(real_human_hits >= 6,"Xuyên Tâm Tiễn did not settle actual CombatStatsV2 damage for all six casters"):
        return
    if not _check(boss_telegraphs > 0 and boss_skill_hits > 0,
        "Human-stage boss did not telegraph and settle a real skill hit: telegraph=%d hits=%d" % [boss_telegraphs,boss_skill_hits]):
        return
    if not _check(boss_phase_changes > 0,"boss health crossing did not advance its authored phase"):
        return

    state.sect.v2_pve_enabled = true
    state.sect.v2_pve_selected_levels["thanh_truc_lam"] = 1
    state.regions[&"thanh_truc_lam"] = RegionState.new({"id":"thanh_truc_lam","name":"Thanh Trúc Lâm","danger":1})
    var pve_party: Array = []
    var roles := ["frontline","ranged","mage","healer","frontline","ranged"]
    for index in range(6):
        pve_party.append({"disciple_id":str(disciples[index].id),"party_id":"d4_real_pve","role":roles[index],
            "position":Vector2(8.0+float(index%3)*2.0,8.0+float(int(index/3))*2.0),
            "realm":1,"floor":1,"body_realm":1,"body_floor":1})
    var pve := HuntingPveRunV2.new()
    var begun := pve.begin(state,"thanh_truc_lam","d4a_pve_adapter",740532,pve_party,BOSS_ID,PREVIEW)
    if not _check(bool(begun.get("ok",false)),"existing HuntingPveRunV2 did not start the gated boss encounter: "+str(begun)):
        return
    var active_save := pve.save_state()
    if not _check(bool(active_save.get("ok",false)),"adapted PvE run did not save its Combat V2 boss snapshot"):
        return
    var restored_run := HuntingPveRunV2.restore_state(state,active_save,PREVIEW)
    if not _check(bool(restored_run.get("ok",false)),"adapted PvE run did not restore its boss identity and actor actions: "+str(restored_run)):
        return
    var restored_session: HuntingPveRunV2 = restored_run.session
    var restored_boss := ""
    var loaded_players := 0
    for actor_value in restored_session.battle.actors.values():
        var actor: Dictionary = actor_value
        if bool(actor.get("v63_custom_boss_ai",false)):
            restored_boss = str(actor.get("v63_boss_id",""))
        elif str(actor.get("side","")) == "disciple" and actor.get("v63_skill_loadout",[]).has(SKILL_ID):
            loaded_players += 1
    if not _check(restored_boss == BOSS_ID and loaded_players == 6,"PvE save/restore dropped boss or personal Human actor identity"):
        return
    var adapter_step := restored_session.advance()
    if not _check(bool(adapter_step.get("ok",false)),"Combat V2 did not advance through the existing PvE session adapter: "+str(adapter_step)):
        return
    print("V63 D4-A HUMAN COMBAT PASS: six personal casts, real CombatStatsV2 damage, boss phase/telegraph, snapshot resume and HuntingPveRunV2 adapter")
    quit(0)

func _check(ok: bool, message: String) -> bool:
    if not ok:
        _fail(message)
        return false
    return true

func _check_step(result: Dictionary) -> bool:
    return _check(bool(result.get("ok",false)),"Combat V2 step failed: "+str(result))

