extends SceneTree

# Six-disciple PvE regression: each disciple learns/equips through Archive, then
# a mixed Human / Immortal A+B / Divine rare B party casts in Combat V2.
# Run in the isolated QA checkout with the official Godot 4.7.2 executable.
const PREVIEW := {"sect_codex":true,"technique_learning":true,"human_skill_combat":true,"divine_skill_combat":true}
const PARTY_ID := "cung_six_regression"
const LOADOUTS := [
    {
        "branch":"liep_anh","lineage":"","innate":"tmb.skill.bow.liep_anh.innate.human",
        "skills":[
            "tmb.skill.bow.liep_anh.active_01.human",
            "tmb.skill.bow.liep_anh.active_02.human",
            "tmb.skill.bow.liep_anh.active_03.human",
            "tmb.skill.bow.liep_anh.active_04.human",
            "tmb.skill.bow.liep_anh.ultimate.human"
        ]
    },
    {
        "branch":"linh_tien","lineage":"","innate":"tmb.skill.bow.linh_tien.innate.human",
        "skills":["tmb.skill.bow.linh_tien.active_01.human"]
    },
    {
        "branch":"liep_anh","lineage":"a","innate":"tmb.skill.bow.liep_anh.innate.immortal.a",
        "skills":["tmb.skill.bow.liep_anh.active_01.immortal.a"]
    },
    {
        "branch":"liep_anh","lineage":"b","innate":"tmb.skill.bow.liep_anh.innate.immortal.b",
        "skills":["tmb.skill.bow.liep_anh.active_01.immortal.b"]
    },
    {
        "branch":"liep_anh","lineage":"a","innate":"tmb.skill.bow.liep_anh.innate.divine.a",
        "skills":["tmb.skill.bow.liep_anh.active_01.divine.a"]
    },
    {
        "branch":"liep_anh","lineage":"b","innate":"tmb.skill.bow.liep_anh.innate.divine.b",
        "skills":["tmb.skill.bow.liep_anh.ultimate.rare.b"]
    }
]
const POSITIONS := [
    Vector2(10.0,9.0),Vector2(10.0,10.0),Vector2(10.0,11.0),
    Vector2(9.0,9.0),Vector2(9.0,10.0),Vector2(9.0,11.0)
]
var failures := 0

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> bool:
    if not ok:
        failures += 1
        push_error("V63_CUNG_SIX_PVE_FAIL: "+message)
    return ok

func _new_state() -> SimulationState:
    var state := SimulationState.new()
    state.sect.disciple_capacity = 32
    state.p3_7_buildings_enabled = true
    state.sect.p3_7_resources_enabled = true
    state.sect.v63_archive_opt_in = true
    state.sect.v63_learning_opt_in = true
    state.sect.v63_skill_combat_opt_in = true
    return state

func _seed_study(disciple: DiscipleState, generation: String, branch_id: String, lineage: String) -> void:
    if lineage not in ["a","b"]:
        return
    if generation == "immortal":
        var branch: Dictionary = V63ImmortalSkillCombatSystem.branch_definitions().get(branch_id,{})
        var technique_id := str(branch.get("lineage_technique_ids",{}).get(lineage,""))
        if not technique_id.is_empty():
            disciple.known_techniques[technique_id] = {"mastery_xp":0.0,"mastery_stage":0,"learned_tick":0}
    elif generation == "divine":
        var branch: Dictionary = V63DivineSkillCombatSystem.branch_definitions().get(branch_id,{})
        var techniques: Array = branch.get("divine_technique_ids",{}).get(lineage,[])
        for technique in techniques:
            disciple.known_techniques[str(technique)] = {"mastery_xp":0.0,"mastery_stage":0,"learned_tick":0}

func _archive_manual(state: SimulationState, codex_id: String) -> bool:
    var codex: Dictionary = V63SectArchiveSystem.codex_definition(codex_id)
    if codex.is_empty() or not bool(codex.get("archivable",false)):
        return false
    var warehouse := WarehouseSystem.new()
    var item_id := StringName(str(codex.get("manual_item_id","")))
    if not warehouse.registry.has(item_id) or not warehouse.add(state,item_id,1):
        return false
    return bool(V63SectArchiveSystem.archive_manual(state,codex_id,PREVIEW).get("ok",false))

func _make_actor(id: String, position: Vector2) -> Dictionary:
    var core := CombatStatsV2.derive(11,1,10,1,0.0)
    var stats: Dictionary = core.stats.duplicate(true)
    stats["max_hp"] = 100000.0
    stats["attack"] = 180.0
    stats["defense"] = 100.0
    return {
        "id":id,"party_id":PARTY_ID,"role":"ranged","tier":"disciple",
        "race_id":"nhan_toc","position":position,"stats":stats,
        "hp":100000.0,"max_hp":100000.0,"resistances":core.resistances.duplicate(true),
        "basic_range":5.5,"move_speed":2.0,"basic_ratio":0.0,"basic_interval":90.0,
        "skill_loadout":[],"skill_factors":{},"context_sources":[],"disciple":null
    }

func _prepare_disciple(index: int) -> Dictionary:
    var spec: Dictionary = LOADOUTS[index]
    var state := _new_state()
    var disciple_id := "cung_six_%02d" % index
    var disciple := DiscipleState.new({"id":disciple_id,"name":disciple_id})
    disciple.v63_combat_branch_id = StringName(str(spec.branch))
    state.disciples[disciple.id] = disciple
    var first_skill := V63HumanSkillCombatSystem.skill_definition(str(spec.skills[0]))
    var generation := str(first_skill.get("generation","human"))
    _seed_study(disciple,generation,str(spec.branch),str(spec.lineage))

    var ids_to_learn: Array[String] = []
    for raw_id in spec.skills:
        var id := str(raw_id)
        if (id.contains(".rare.") or id.contains(".rare_passive.")):
            var predecessor := id.replace(".rare.",".divine.").replace(".rare_passive.",".divine.")
            if not ids_to_learn.has(predecessor):
                ids_to_learn.append(predecessor)
        ids_to_learn.append(id)
    for skill_id in ids_to_learn:
        var definition: Dictionary = V63HumanSkillCombatSystem.skill_definition(skill_id)
        if definition.is_empty():
            return {"ok":false,"reason":"missing skill definition "+skill_id}
        if not bool(definition.get("archivable",false)):
            continue
        if not _archive_manual(state,str(definition.get("source_codex_id",""))):
            return {"ok":false,"reason":"Archive failed for "+skill_id}
        var learned := V63HumanSkillCombatSystem.learn_skill(state,disciple,skill_id,PREVIEW)
        if not bool(learned.get("ok",false)):
            return {"ok":false,"reason":"learn failed for "+skill_id+": "+str(learned)}
        var equipped := V63HumanSkillCombatSystem.equip_skill(state,disciple,skill_id,PREVIEW)
        if not bool(equipped.get("ok",false)):
            return {"ok":false,"reason":"equip failed for "+skill_id+": "+str(equipped)}

    var actor := _make_actor(disciple_id,POSITIONS[index])
    actor["disciple"] = disciple
    var attached := V63HumanSkillCombatSystem.attach_disciple_loadout(state,actor,PREVIEW)
    if not bool(attached.get("ok",false)) or not bool(attached.get("attached",false)):
        return {"ok":false,"reason":"attach failed: "+str(attached)}
    for wanted in spec.skills:
        if not actor.get("v63_skill_loadout",[]).has(str(wanted)):
            return {"ok":false,"reason":"equipped skill missing from actor loadout: "+str(wanted)}
    if str(actor.get("v63_innate_skill_id","")) != str(spec.innate):
        return {"ok":false,"reason":"derived innate mismatch: "+str(actor.get("v63_innate_skill_id",""))}
    return {"ok":true,"actor":actor,"disciple":disciple}

func _run() -> void:
    var party: Array = []
    for index in range(LOADOUTS.size()):
        var prepared := _prepare_disciple(index)
        if not _check(bool(prepared.get("ok",false)),"disciple %d prep failed: %s" % [index,str(prepared.get("reason",""))]):
            quit(1)
            return
        party.append(prepared.actor)

    var monster: Dictionary = MonsterCatalogueV2.create_actor("truc_thu",11,1,"cung_six_target")
    monster["id"] = "cung_six_target"
    monster["position"] = Vector2(13.0,10.0)
    monster["move_speed"] = 0.0
    monster["hp"] = 100000000.0
    monster["max_hp"] = 100000000.0
    var monster_stats: Dictionary = monster.get("stats",{}).duplicate(true)
    monster_stats["max_hp"] = 100000000.0
    monster["stats"] = monster_stats

    var battle := MapBattleV2.new(791001)
    var started := battle.setup("cung_six_disciple_pve",party,[monster])
    if not _check(bool(started.get("ok",false)),"six-disciple Combat V2 setup failed: "+str(started)):
        quit(1)
        return
    if not _check(battle.actors.size()==7,"battle did not contain six disciples and one monster"):
        quit(1)
        return
    var actor_errors := V63HumanSkillCombatSystem.validate_battle(battle)
    if not _check(actor_errors.is_empty(),"six-disciple loadout validation failed: "+str(actor_errors)):
        quit(1)
        return

    battle.step()
    var saved := MapBattleSnapshotV2.save(battle)
    var restored := MapBattleSnapshotV2.load(saved)
    if not _check(bool(saved.get("ok",false)) and bool(restored.get("ok",false)),
        "six-disciple mid-cast snapshot did not round-trip: "+str(restored)):
        quit(1)
        return
    var resumed: MapBattleV2 = restored.battle
    var restored_roster := 0
    for index in range(LOADOUTS.size()):
        var actor_id := "cung_six_%02d" % index
        var actor: Dictionary = resumed.actors.get(actor_id,{})
        var all_actions_present := not actor.is_empty()
        if not actor.is_empty():
            for wanted in LOADOUTS[index].skills:
                all_actions_present = all_actions_present and actor.get("v63_skill_loadout",[]).has(str(wanted))
        if all_actions_present:
            restored_roster += 1
    if not _check(restored_roster==6,"snapshot changed one or more learned/equipped skill loadouts"):
        quit(1)
        return

    resumed.run(450)
    var casts_by_actor: Dictionary = {}
    var hits_by_actor: Dictionary = {}
    var skills_by_rotation_actor: Dictionary = {}
    var positive_damage := 0.0
    for event in resumed.events:
        var kind := str(event.get("type",""))
        if kind == "skill_cast" and str(event.get("combat_family","")) == "v63_human":
            var actor_id := str(event.get("actor_id",""))
            var skill_id := str(event.get("skill_id",""))
            casts_by_actor[actor_id] = int(casts_by_actor.get(actor_id,0))+1
            if actor_id == "cung_six_00":
                skills_by_rotation_actor[skill_id] = true
        elif kind == "v63_skill_hit":
            var hit_actor := str(event.get("caster",""))
            if (float(event.get("damage",0.0)) > 0.0 and
                    float(event.get("target_hp_after",INF)) < float(event.get("target_hp_before",INF))):
                hits_by_actor[hit_actor] = int(hits_by_actor.get(hit_actor,0))+1
                positive_damage += float(event.get("damage",0.0))

    var all_six_cast := true
    var all_six_hit := true
    for index in range(LOADOUTS.size()):
        var actor_id := "cung_six_%02d" % index
        all_six_cast = all_six_cast and int(casts_by_actor.get(actor_id,0))>0
        all_six_hit = all_six_hit and int(hits_by_actor.get(actor_id,0))>0
    var multi_skill_ok := skills_by_rotation_actor.size()>=2
    print("V63_CUNG_SIX_PVE_RECEIPT "+JSON.stringify({
        "encounter":"cung_six_disciple_pve","disciple_count":6,
        "casts_by_actor":casts_by_actor,"positive_damage_by_actor":hits_by_actor,
        "rotation_actor_distinct_skills":skills_by_rotation_actor.size(),
        "target_hp_after":resumed.actors["cung_six_target"].hp,
        "positive_damage_total":positive_damage,"snapshot_restored":restored_roster==6,
        "status":"PASS" if failures == 0 else "FAIL"
    }))
    _check(all_six_cast,"one or more of the six disciples did not auto-cast")
    _check(all_six_hit and positive_damage>0.0,"one or more disciples had no positive skill HP delta")
    _check(multi_skill_ok,"AI only used one action from the multi-skill Liệp Ảnh loadout")
    _check(float(resumed.actors["cung_six_target"].hp)<100000000.0,
        "six-disciple PvE did not reduce monster HP")
    if failures == 0:
        print("V63 CUNG SIX DISCIPLE PVE PASS")
    else:
        push_error("V63 CUNG SIX DISCIPLE PVE FAILURES: "+str(failures))
    quit(1 if failures>0 else 0)
