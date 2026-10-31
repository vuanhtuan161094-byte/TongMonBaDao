extends SceneTree

# Scratch-only runner for TongMonBaDao HEAD 095ff2f90df8260dd123c06964d20c4f9b571d32.
# Copy into an isolated QA project/worktree and run only after Codex 1 releases Godot.
# It acquires archivable actions through Archive -> learn -> equip, then records Combat V2
# receipts. It does not write production saves or files.
const PREVIEW := {"sect_codex":true,"technique_learning":true,"human_skill_combat":true,"divine_skill_combat":true}
var serial := 0
var failures := 0
var action_cases := 0
var passive_cases := 0

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var catalogues := [
        {"tier":"human","result":V63HumanSkillCombatSystem.load_catalogue()},
        {"tier":"immortal","result":V63ImmortalSkillCombatSystem.load_catalogue()},
        {"tier":"divine","result":V63DivineSkillCombatSystem.load_catalogue()}
    ]
    for entry in catalogues:
        var loaded: Dictionary = entry.result
        if not _check(bool(loaded.get("ok",false)), "catalogue failed: "+str(entry.tier)):
            continue
        for raw in loaded.get("data",{}).get("skills",[]):
            var skill: Dictionary = raw
            if str(skill.get("school","")) != "bow":
                continue
            var slot := str(skill.get("slot",""))
            if slot in ["active","ultimate"]:
                _probe_action(skill)
            elif slot == "passive":
                _probe_passive(skill)
    _probe_basic("human")
    _probe_basic("immortal")
    _probe_basic("divine")
    _probe_mobility("human")
    _probe_mobility("immortal")
    _probe_mobility("divine")
    print("CUNG_AUDIT_SUMMARY "+JSON.stringify({
        "active_ultimate_cases":action_cases,
        "passive_attach_cases":passive_cases,
        "failures":failures,
        "scope":"Runtime evidence only; SaveService/New Game journey needs owner QA."
    }))
    quit(1 if failures > 0 else 0)

func _check(ok: bool, message: String) -> bool:
    if not ok:
        failures += 1
        push_error("CUNG_AUDIT_FAIL "+message)
    return ok

func _new_state(disciple_id: String) -> SimulationState:
    var state := SimulationState.new()
    state.sect.disciple_capacity = 32
    state.p3_7_buildings_enabled = true
    state.sect.p3_7_resources_enabled = true
    state.sect.v63_archive_opt_in = true
    state.sect.v63_learning_opt_in = true
    state.sect.v63_skill_combat_opt_in = true
    return state

func _new_disciple(state: SimulationState, branch: String, disciple_id: String) -> DiscipleState:
    var disciple := DiscipleState.new({"id":disciple_id,"name":disciple_id})
    if not branch.is_empty():
        disciple.v63_combat_branch_id = StringName(branch)
    state.disciples[disciple.id] = disciple
    return disciple

func _seed_study(disciple: DiscipleState, tier: String, branch_id: String, lineage: String) -> void:
    if branch_id.is_empty() or lineage not in ["a","b"]:
        return
    if tier == "immortal":
        var branch: Dictionary = V63ImmortalSkillCombatSystem.branch_definitions().get(branch_id,{})
        var technique_id := str(branch.get("lineage_technique_ids",{}).get(lineage,""))
        if not technique_id.is_empty():
            disciple.known_techniques[technique_id] = {"mastery_xp":0.0,"mastery_stage":0,"learned_tick":0}
    elif tier == "divine":
        var branch: Dictionary = V63DivineSkillCombatSystem.branch_definitions().get(branch_id,{})
        var techniques: Array = branch.get("divine_technique_ids",{}).get(lineage,[])
        for technique in techniques:
            disciple.known_techniques[str(technique)] = {"mastery_xp":0.0,"mastery_stage":0,"learned_tick":0}

func _archive_manual(state: SimulationState, codex_id: String) -> bool:
    if codex_id.is_empty():
        return false
    var codex: Dictionary = V63SectArchiveSystem.codex_definition(codex_id)
    if codex.is_empty() or not bool(codex.get("archivable",false)):
        return false
    var warehouse := WarehouseSystem.new()
    var item_id := StringName(str(codex.get("manual_item_id","")))
    if not warehouse.registry.has(item_id) or not warehouse.add(state,item_id,1):
        return false
    return bool(V63SectArchiveSystem.archive_manual(state,codex_id,PREVIEW).get("ok",false))

func _make_actor(actor_id: String, position: Vector2) -> Dictionary:
    var core := CombatStatsV2.derive(11,1,10,1,0.0)
    var stats: Dictionary = core.stats.duplicate(true)
    stats["max_hp"] = 100000.0
    stats["attack"] = 180.0
    stats["defense"] = 100.0
    return {
        "id":actor_id,"party_id":"cung_audit","role":"ranged","tier":"disciple",
        "race_id":"nhan_toc","position":position,"stats":stats,
        "hp":100000.0,"max_hp":100000.0,"resistances":core.resistances.duplicate(true),
        "basic_range":5.5,"move_speed":2.0,"basic_ratio":0.0,"basic_interval":90.0,
        "skill_loadout":[],"skill_factors":{},"context_sources":[],"disciple":null
    }

func _make_monster(monster_id: String, position: Vector2) -> Dictionary:
    var monster: Dictionary = MonsterCatalogueV2.create_actor("truc_thu",11,1,monster_id)
    monster["id"] = monster_id
    monster["position"] = position
    monster["move_speed"] = 0.0
    monster["hp"] = 100000000.0
    monster["max_hp"] = 100000000.0
    var stats: Dictionary = monster.get("stats",{}).duplicate(true)
    stats["max_hp"] = 100000000.0
    monster["stats"] = stats
    return monster

func _prepare(skill: Dictionary) -> Dictionary:
    serial += 1
    var tier := str(skill.get("generation",skill.get("tier","human")))
    var branch_id := str(skill.get("branch",""))
    var lineage := str(skill.get("lineage",""))
    var state := _new_state("cung_audit_%d" % serial)
    var disciple := _new_disciple(state,branch_id,"cung_audit_%d" % serial)
    _seed_study(disciple,tier,branch_id,lineage)
    var ids_to_learn: Array[String] = []
    var id := str(skill.get("id",""))
    if tier == "divine" and (id.contains(".rare.") or id.contains(".rare_passive.")):
        ids_to_learn.append(id.replace(".rare.",".divine.").replace(".rare_passive.",".divine."))
    ids_to_learn.append(id)
    for skill_id in ids_to_learn:
        var definition: Dictionary = V63HumanSkillCombatSystem.skill_definition(skill_id)
        if definition.is_empty():
            return {"ok":false,"reason":"missing definition "+skill_id}
        if not bool(definition.get("archivable",false)):
            continue
        if not _archive_manual(state,str(definition.get("source_codex_id",""))):
            return {"ok":false,"reason":"manual/archive failed "+skill_id}
        var learned := V63HumanSkillCombatSystem.learn_skill(state,disciple,skill_id,PREVIEW)
        if not bool(learned.get("ok",false)):
            return {"ok":false,"reason":"learn failed "+skill_id+" "+str(learned)}
        var equipped := V63HumanSkillCombatSystem.equip_skill(state,disciple,skill_id,PREVIEW)
        if not bool(equipped.get("ok",false)):
            return {"ok":false,"reason":"equip failed "+skill_id+" "+str(equipped)}
    var actor := _make_actor(str(disciple.id),Vector2(10.0,10.0))
    var attached := V63HumanSkillCombatSystem.attach_disciple_loadout(state,actor,PREVIEW)
    if not bool(attached.get("ok",false)):
        return {"ok":false,"reason":"attach failed "+id+" "+str(attached)}
    if not branch_id.is_empty():
        var expected_innate := ""
        if tier == "human":
            expected_innate = str(V63HumanSkillCombatSystem.branch_definitions().get(branch_id,{}).get("innate_node_id",""))
        elif tier == "immortal":
            expected_innate = str(V63ImmortalSkillCombatSystem.branch_definitions().get(branch_id,{}).get("innate_node_ids",{}).get(lineage,""))
        else:
            expected_innate = str(V63DivineSkillCombatSystem.branch_definitions().get(branch_id,{}).get("divine_innate_node_ids",{}).get(lineage,""))
        if not expected_innate.is_empty() and str(actor.get("v63_innate_skill_id","")) != expected_innate:
            return {"ok":false,"reason":"derived innate mismatch "+id}
    return {"ok":true,"state":state,"disciple":disciple,"actor":actor}

func _probe_action(skill: Dictionary) -> void:
    action_cases += 1
    var prepared := _prepare(skill)
    var id := str(skill.id)
    if not _check(bool(prepared.get("ok",false)),id+" preparation: "+str(prepared.get("reason",""))):
        return
    var actor: Dictionary = prepared.actor
    var range := float(skill.get("range",7.0))
    var radius := float(skill.get("radius",0.0))
    var distance := minf(3.0,maxf(1.0,range-0.25))
    if str(skill.get("shape","")) == "line" and radius > 0.0 and range > radius:
        distance = minf(range-0.1,radius+1.0)
    actor["basic_ratio"] = 0.0
    actor["basic_interval"] = 90.0
    var party: Array = [actor]
    var heal_target_id := ""
    if str(skill.get("effect","")) == "heal":
        var ally := _make_actor("wounded_ally_%d" % serial,Vector2(10.5,10.0))
        ally["hp"] = 1000.0
        ally["max_hp"] = 100000.0
        party.append(ally)
        heal_target_id = str(ally.id)
    var enemies: Array = [
        _make_monster("enemy_%d_a" % serial,Vector2(10.0+distance,10.0)),
        _make_monster("enemy_%d_b" % serial,Vector2(10.0+distance+0.5,10.35)),
        _make_monster("enemy_%d_c" % serial,Vector2(10.0+distance+1.0,10.65))
    ]
    var battle := MapBattleV2.new(700000+serial)
    if not _check(bool(battle.setup("cung_audit_"+str(serial),party,enemies).get("ok",false)),id+" battle setup"):
        return
    var primary_id := str(enemies[0].id)
    var measured_target_id := heal_target_id if not heal_target_id.is_empty() else primary_id
    var hp_before := float(battle.actors[measured_target_id].hp)
    battle.run(90.0)
    var live_actor: Dictionary = battle.actors[str(actor.id)]
    var live_target: Dictionary = battle.actors[measured_target_id]
    var casts := 0
    var hits := 0
    var damage_total := 0.0
    var healing_total := 0.0
    var cast_start := -1.0
    var release_time := -1.0
    var event_ids: Array[String] = []
    for index in range(battle.events.size()):
        var event: Dictionary = battle.events[index]
        if str(event.get("skill_id","")) != id:
            continue
        var kind := str(event.get("type",""))
        event_ids.append("%s#%d" % [kind,index])
        if kind == "skill_cast":
            casts += 1
            if cast_start < 0.0:
                cast_start = float(event.get("time",-1.0))
        elif kind == "v63_skill_hit":
            hits += 1
            damage_total += float(event.get("damage",0.0))
            if release_time < 0.0:
                release_time = float(event.get("time",-1.0))
        elif kind == "heal":
            healing_total += float(event.get("amount",0.0))
    var hp_after := float(live_target.hp)
    var effect := str(skill.get("effect",""))
    var passed := casts > 0
    var expected := ""
    if effect == "heal":
        expected = "cast + heal amount>0 + target HP increases"
        passed = passed and healing_total > 0.0 and hp_after > hp_before
    else:
        expected = "cast + hit + damage>0 + target HP decreases"
        passed = passed and hits > 0 and damage_total > 0.0 and hp_after < hp_before
    var snapshot := MapBattleSnapshotV2.save(battle)
    var restored := MapBattleSnapshotV2.load(snapshot)
    var snapshot_ok := bool(snapshot.get("ok",false)) and bool(restored.get("ok",false))
    var loadout: Array = actor.get("v63_skill_loadout",[])
    print("CUNG_AUDIT_RECEIPT "+JSON.stringify({
        "caster":str(actor.id),"target":measured_target_id,"skill_id":id,
        "hp_before":hp_before,"hp_after":hp_after,"damage_expected":expected,
        "damage_actual":damage_total,"heal_actual":healing_total,
        "event_ids":event_ids,"cast_start":cast_start,"release_or_impact":release_time,
        "cooldown_ready":live_actor.get("v63_skill_ready",{}).get(id,-1.0),
        "status_before":{},"status_after":live_target.get("status_effects",{}),
        "targets_hit":hits,"learned":true,"equipped":loadout.has(id),
        "snapshot_roundtrip":snapshot_ok
    }))
    _check(passed,id+" did not satisfy "+expected)
    _check(snapshot_ok,id+" Combat V2 snapshot failed round-trip")

func _probe_passive(skill: Dictionary) -> void:
    passive_cases += 1
    var prepared := _prepare(skill)
    var id := str(skill.id)
    if not _check(bool(prepared.get("ok",false)),id+" passive preparation: "+str(prepared.get("reason",""))):
        return
    var actor: Dictionary = prepared.actor
    var attached: Array = actor.get("v63_passive_ids",[])
    var present := attached.has(id)
    print("CUNG_AUDIT_PASSIVE "+JSON.stringify({
        "skill_id":id,"learned":true,"equipped":true,"attached":present,
        "passive_modifiers":skill.get("passive_modifiers",{}),
        "effect_trigger_assertion":"follow-up required per modifier family"
    }))
    _check(present,id+" passive not attached")

func _probe_basic(tier: String) -> void:
    var prep: Dictionary
    var skill_id := ""
    if tier == "human":
        skill_id = "tmb.skill.bow.basic.human"
        prep = V63HumanSkillCombatSystem.skill_definition(skill_id)
    elif tier == "immortal":
        prep = V63HumanSkillCombatSystem.skill_definition("tmb.skill.bow.liep_anh.active_01.immortal.a")
        skill_id = "tmb.skill.bow.basic.immortal.base"
    else:
        prep = V63HumanSkillCombatSystem.skill_definition("tmb.skill.bow.liep_anh.active_01.divine.a")
        skill_id = "tmb.skill.bow.basic.divine.base"
    var prepared := _prepare(prep)
    if not _check(bool(prepared.get("ok",false)),tier+" basic prep: "+str(prepared.get("reason",""))):
        return
    var actor: Dictionary = prepared.actor
    actor["basic_interval"] = 1.0
    var battle := MapBattleV2.new(710000+serial)
    var target := _make_monster("basic_target_"+tier,Vector2(13.0,10.0))
    if not _check(bool(battle.setup("cung_basic_"+tier,[actor],[target]).get("ok",false)),tier+" basic setup"):
        return
    battle.run(4.0)
    var damage := 0.0
    for event in battle.events:
        if str(event.get("type","")) == "hit" and str(event.get("attacker","")) == str(actor.id) and str(event.get("kind","")) == "basic":
            damage += float(event.get("damage",0.0))
    var hp_after := float(battle.actors[target.id].hp)
    print("CUNG_AUDIT_BASIC "+JSON.stringify({
        "tier":tier,"skill_id":skill_id,"expected":"basic damage>0 and target HP decreases",
        "damage_actual":damage,"target_hp_after":hp_after
    }))
    _check(damage>0.0 and hp_after<100000000.0,tier+" basic did not reduce HP")

func _probe_mobility(tier: String) -> void:
    var seed: Dictionary
    var mobility_id := "tmb.skill.bow.mobility.human"
    if tier == "human":
        seed = V63HumanSkillCombatSystem.skill_definition(mobility_id)
    elif tier == "immortal":
        seed = V63HumanSkillCombatSystem.skill_definition("tmb.skill.bow.liep_anh.active_01.immortal.a")
        mobility_id = "tmb.skill.bow.mobility.immortal.base"
    else:
        seed = V63HumanSkillCombatSystem.skill_definition("tmb.skill.bow.liep_anh.active_01.divine.a")
        mobility_id = "tmb.skill.bow.mobility.divine.base"
    var prepared := _prepare(seed)
    if not _check(bool(prepared.get("ok",false)),tier+" mobility prep: "+str(prepared.get("reason",""))):
        return
    var actor: Dictionary = prepared.actor
    actor["v63_skill_loadout"] = [mobility_id]
    actor["basic_ratio"] = 0.0
    actor["range"] = 2.0
    actor["basic_range"] = 2.0
    actor["position"] = Vector2(10.0,10.0)
    var isolated := MapBattleV2.new(720000+serial)
    var target := _make_monster("mobility_target_"+tier,Vector2(20.0,10.0))
    if not _check(bool(isolated.setup("cung_mobility_"+tier,[actor],[target]).get("ok",false)),tier+" mobility setup"):
        return
    var origin: Vector2 = isolated.actors[str(actor.id)].position
    isolated.step()
    isolated.step()
    isolated.step()
    var moved := (isolated.actors[str(actor.id)].position as Vector2).distance_to(origin)>0.1
    var event_seen := false
    for event in isolated.events:
        if str(event.get("type","")) == "v63_mobility" and str(event.get("skill_id","")) == mobility_id:
            event_seen = true
    _check(moved and event_seen,tier+" mobility unavailable in isolated encounter")
    var world := MapBattleV2.new(730000+serial)
    var world_actor: Dictionary = actor.duplicate(true)
    world_actor["id"] = "mobility_world_"+tier
    var world_target := _make_monster("mobility_world_target_"+tier,Vector2(20.0,10.0))
    if not _check(bool(world.setup("cung_mobility_world_"+tier,[world_actor],[world_target]).get("ok",false)),tier+" world mobility setup"):
        return
    world.world_mode = true
    var world_origin: Vector2 = world.actors[str(world_actor.id)].position
    world.step()
    world.step()
    world.step()
    var world_event := false
    for event in world.events:
        if str(event.get("type","")) == "v63_mobility":
            world_event = true
    print("CUNG_AUDIT_MOBILITY "+JSON.stringify({
        "tier":tier,"skill_id":mobility_id,"isolated_available":moved and event_seen,
        "world_mode_available":world_event,
        "world_position_unchanged":(world.actors[str(world_actor.id)].position as Vector2).distance_to(world_origin)<0.1
    }))


