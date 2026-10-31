extends SceneTree

# Full Cung skill matrix runner for exact candidate HEAD 400baa11403720fb816075d65f3cb74e8f4ad505 plus isolated patch branch.
# Run only in the isolated QA checkout after Codex 1 releases Godot. This harness has NOT_RUN status until a Godot 4.7.2 log is attached.
# It acquires archivable actions through Archive -> learn -> equip, then records Combat V2
# receipts. It does not write production saves or files.
const PREVIEW := {"sect_codex":true,"technique_learning":true,"human_skill_combat":true,"divine_skill_combat":true}
var serial := 0
var failures := 0
var action_cases := 0
var passive_cases := 0
var innate_cases := 0
var basic_cases := 0
var mobility_cases := 0
var matrix_ids: Dictionary = {}
var slot_counts: Dictionary = {}

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
            var id := str(skill.get("id",""))
            var slot := str(skill.get("slot",""))
            matrix_ids[id] = true
            slot_counts[slot] = int(slot_counts.get(slot,0))+1
            if slot in ["active","ultimate"]:
                _probe_action(skill)
            elif slot == "passive":
                _probe_passive(skill)
            elif slot == "innate":
                _probe_innate(skill)
    _probe_basic("human")
    _probe_basic("immortal")
    _probe_basic("divine")
    _probe_mobility("human")
    _probe_mobility("immortal")
    _probe_mobility("divine")
    _probe_rotation()
    _probe_kill_receipt()
    _check(matrix_ids.size() == 183, "Cung catalogue matrix did not enumerate all 183 IDs")
    _check(action_cases == 81, "active/ultimate probe count mismatch: "+str(action_cases))
    _check(passive_cases == 81, "passive probe count mismatch: "+str(passive_cases))
    _check(innate_cases == 15, "innate probe count mismatch: "+str(innate_cases))
    _check(basic_cases == 3 and mobility_cases == 3, "basic/mobility probe count mismatch")
    _check(int(slot_counts.get("active",0)) == 60 and int(slot_counts.get("ultimate",0)) == 21,
        "active/ultimate catalogue slot counts changed")
    _check(int(slot_counts.get("passive",0)) == 81 and int(slot_counts.get("innate",0)) == 15,
        "passive/innate catalogue slot counts changed")
    _check(int(slot_counts.get("basic",0)) == 3 and int(slot_counts.get("mobility",0)) == 3,
        "basic/mobility catalogue slot counts changed")
    print("CUNG_MATRIX_SUMMARY "+JSON.stringify({
        "candidate_head":"400baa11403720fb816075d65f3cb74e8f4ad505",
        "catalogue_ids":matrix_ids.size(),
        "slot_counts":slot_counts,
        "active_ultimate_cases":action_cases,
        "passive_effect_cases":passive_cases,
        "innate_effect_cases":innate_cases,
        "basic_cases":basic_cases,
        "isolated_mobility_cases":mobility_cases,
        "rotation_cases":1,
        "failures":failures,
        "runtime_status":"NOT_RUN until official Godot 4.7.2 exit code and log are recorded",
        "scope":"Simulation matrix only; separate world-mode, PvE adapter, save/reload, VFX and physical QA remain independent gates."
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
    var id := str(skill.get("id",""))
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
    var center := Vector2(10.0+distance,10.0)
    var enemies: Array = [
        _make_monster("enemy_%d_a" % serial,center),
        _make_monster("enemy_%d_b" % serial,center+Vector2(0.05,0.0)),
        _make_monster("enemy_%d_c" % serial,center+Vector2(0.10,0.0))
    ]
    var battle := MapBattleV2.new(700000+serial)
    if not _check(bool(battle.setup("cung_audit_"+str(serial),party,enemies).get("ok",false)),id+" battle setup"):
        return
    var primary_id := str(enemies[0].id)
    var measured_target_id := heal_target_id if not heal_target_id.is_empty() else primary_id
    var hp_before := float(battle.actors[measured_target_id].hp)
    battle.run(90)
    var live_actor: Dictionary = battle.actors[str(actor.id)]
    var casts := 0
    var hits := 0
    var damage_total := 0.0
    var healing_total := 0.0
    var release_time := -1.0
    var last_cast_start := -1.0
    var first_cast_start := -1.0
    var event_targets: Dictionary = {}
    var hp_before_by_target: Dictionary = {}
    var hp_after_by_target: Dictionary = {}
    var hp_damage_proven := false
    var projectile_timing_match := true
    var event_ids: Array[String] = []
    var cast_stats := V63HumanSkillCombatSystem.effective_attack_stats(live_actor,live_actor.get("stats",{}))
    var cast_rate := maxf(0.1,1.0+float(cast_stats.get("cast_speed",0.0)))
    for index in range(battle.events.size()):
        var event: Dictionary = battle.events[index]
        if str(event.get("skill_id","")) != id:
            continue
        var kind := str(event.get("type",""))
        event_ids.append("%s#%d" % [kind,index])
        if kind == "skill_cast":
            casts += 1
            var started_at := float(event.get("time",0.0))
            last_cast_start = started_at
            if first_cast_start < 0.0:
                first_cast_start = started_at
            var release_at := float(event.get("release_at",-1.0))
            var target_id := str(event.get("target",""))
            var cast_target: Dictionary = battle.actors.get(target_id,{})
            var travel := 0.0
            var projectile_speed := float(skill.get("projectile_speed",0.0))
            if projectile_speed > 0.0 and not cast_target.is_empty():
                travel = (live_actor.position as Vector2).distance_to(cast_target.position as Vector2)/projectile_speed
            var expected_delay := maxf(MapBattleV2.STEP_SECONDS,float(skill.get("cast_time",0.0))/cast_rate)+travel
            if absf((release_at-started_at)-expected_delay) > 0.03:
                projectile_timing_match = false
        elif kind == "v63_skill_hit":
            hits += 1
            damage_total += float(event.get("damage",0.0))
            var hit_target_id := str(event.get("target",""))
            event_targets[hit_target_id] = true
            hp_before_by_target[hit_target_id] = float(event.get("target_hp_before",0.0))
            hp_after_by_target[hit_target_id] = float(event.get("target_hp_after",0.0))
            if float(event.get("damage",0.0)) > 0.0 and float(event.get("target_hp_after",INF)) < float(event.get("target_hp_before",INF)):
                hp_damage_proven = true
            release_time = float(event.get("time",-1.0))
        elif kind == "heal":
            healing_total += float(event.get("amount",0.0))
    var live_target: Dictionary = battle.actors.get(measured_target_id,{})
    var hp_after := float(live_target.get("hp",0.0))
    var effect := str(skill.get("effect",""))
    var passed := casts > 0 and hits > 0 and release_time >= first_cast_start
    var expected := "cast -> release/hit -> positive target HP delta"
    if effect == "heal":
        expected = "cast -> hit -> heal amount>0 -> ally HP increases"
        passed = passed and healing_total > 0.0 and hp_after > hp_before
    else:
        passed = passed and damage_total > 0.0 and hp_damage_proven
    var mark_proven := effect != "mark"
    if effect == "mark":
        for target_id in event_targets.keys():
            var marked: Dictionary = battle.actors.get(str(target_id),{})
            var marks: Dictionary = marked.get("v63_marks",{})
            mark_proven = mark_proven or marks.has(str(actor.id))
        passed = passed and mark_proven
    var limit := mini(int(skill.get("target_limit",1)),3)
    var aoe_ok := event_targets.size() <= limit and event_targets.size() > 0
    if str(skill.get("shape","")) in ["circle","line"] and limit > 1:
        aoe_ok = aoe_ok and event_targets.size() >= limit
    var cooldown_rate := maxf(0.1,1.0+float(cast_stats.get("cooldown_recovery",0.0)))
    var ready_at := float(live_actor.get("v63_skill_ready",{}).get(id,-1.0))
    var expected_ready := last_cast_start+maxf(MapBattleV2.STEP_SECONDS,float(skill.get("cooldown",0.0))/cooldown_rate)
    var cooldown_ok := casts > 0 and ready_at >= expected_ready-0.03
    var snapshot := MapBattleSnapshotV2.save(battle)
    var restored := MapBattleSnapshotV2.load(snapshot)
    var snapshot_ok := bool(snapshot.get("ok",false)) and bool(restored.get("ok",false))
    var loadout: Array = actor.get("v63_skill_loadout",[])
    var hp_target := event_targets.keys()[0] if not event_targets.is_empty() else measured_target_id
    var hp_record: Dictionary = battle.actors.get(str(hp_target),{})
    print("CUNG_MATRIX_RECEIPT "+JSON.stringify({
        "caster":str(actor.id),"target":str(hp_target),"skill_id":id,"effect":effect,
        "shape":str(skill.get("shape","")),"target_limit":limit,"targets_hit":event_targets.size(),
        "target_hp_before":hp_before_by_target.get(str(hp_target),hp_record.get("hp",null)),
        "target_hp_after":hp_after_by_target.get(str(hp_target),hp_record.get("hp",null)),
        "hp_before_primary":hp_before,"hp_after_primary":hp_after,
        "damage_actual":damage_total,"heal_actual":healing_total,"mark_applied":mark_proven,
        "cast_count":casts,"cast_start":first_cast_start,"release_or_impact":release_time,
        "projectile_speed":float(skill.get("projectile_speed",0.0)),"travel_deadline_match":projectile_timing_match,
        "cooldown_ready":ready_at,"cooldown_schedule_match":cooldown_ok,
        "event_ids":event_ids,"learned":true,"equipped":loadout.has(id),
        "snapshot_roundtrip":snapshot_ok
    }))
    _check(passed,id+" did not satisfy "+expected)
    _check(aoe_ok,id+" AoE/target-limit resolution mismatch")
    _check(projectile_timing_match,id+" cast/projectile release deadline mismatch")
    _check(cooldown_ok,id+" cooldown was not scheduled from the cast time")
    _check(snapshot_ok,id+" Combat V2 snapshot failed round-trip")
func _modifier_changed(skill: Dictionary, actor: Dictionary, without_skill: Dictionary, is_innate: bool) -> bool:
    var mods: Dictionary = skill.get("passive_modifiers",{})
    var after_attack := V63HumanSkillCombatSystem.effective_attack_stats(actor,actor.get("stats",{}))
    var before_attack := V63HumanSkillCombatSystem.effective_attack_stats(without_skill,without_skill.get("stats",{}))
    var after_defense := V63HumanSkillCombatSystem.effective_defense_stats(actor,actor.get("stats",{}))
    var before_defense := V63HumanSkillCombatSystem.effective_defense_stats(without_skill,without_skill.get("stats",{}))
    var candidates := [
        {"modifier":"outgoing_factor","field":"attack","defense":false},
        {"modifier":"crit_bonus","field":"crit_chance","defense":false},
        {"modifier":"attack_speed_factor","field":"attack_speed","defense":false},
        {"modifier":"cast_speed_factor","field":"cast_speed","defense":false},
        {"modifier":"cooldown_recovery_factor","field":"cooldown_recovery","defense":false},
        {"modifier":"lifesteal","field":"lifesteal","defense":false},
        {"modifier":"guard_factor","field":"damage_reduction","defense":true}
    ]
    for candidate in candidates:
        var modifier := str(candidate.modifier)
        if absf(float(mods.get(modifier,0.0))) <= 0.000001:
            continue
        var field := str(candidate.field)
        var after := float(after_defense.get(field,0.0)) if bool(candidate.defense) else float(after_attack.get(field,0.0))
        var before := float(before_defense.get(field,0.0)) if bool(candidate.defense) else float(before_attack.get(field,0.0))
        if not is_equal_approx(after,before):
            return true
    return false

func _probe_passive(skill: Dictionary) -> void:
    passive_cases += 1
    var prepared := _prepare(skill)
    var id := str(skill.get("id",""))
    if not _check(bool(prepared.get("ok",false)),id+" passive preparation: "+str(prepared.get("reason",""))):
        return
    var actor: Dictionary = prepared.actor
    var attached: Array = actor.get("v63_passive_ids",[])
    var present := attached.has(id)
    var without_skill: Dictionary = actor.duplicate(true)
    var without_ids: Array = without_skill.get("v63_passive_ids",[]).duplicate(true)
    without_ids.erase(id)
    without_skill["v63_passive_ids"] = without_ids
    var modifier_proven := _modifier_changed(skill,actor,without_skill,false)
    print("CUNG_MATRIX_PASSIVE "+JSON.stringify({
        "skill_id":id,"learned":true,"equipped":true,"attached":present,
        "modifier_delta_proven":modifier_proven,"passive_modifiers":skill.get("passive_modifiers",{})
    }))
    _check(present,id+" passive not attached")
    _check(modifier_proven,id+" passive produced no effective stat delta")

func _probe_innate(skill: Dictionary) -> void:
    innate_cases += 1
    var prepared := _prepare(skill)
    var id := str(skill.get("id",""))
    if not _check(bool(prepared.get("ok",false)),id+" innate preparation: "+str(prepared.get("reason",""))):
        return
    var actor: Dictionary = prepared.actor
    var derived_id := str(actor.get("v63_innate_skill_id",""))
    var without_skill: Dictionary = actor.duplicate(true)
    without_skill.erase("v63_innate_skill_id")
    var modifier_proven := _modifier_changed(skill,actor,without_skill,true)
    print("CUNG_MATRIX_INNATE "+JSON.stringify({
        "skill_id":id,"derived_skill_id":derived_id,"derived":derived_id==id,
        "modifier_delta_proven":modifier_proven,"passive_modifiers":skill.get("passive_modifiers",{})
    }))
    _check(derived_id==id,id+" innate was not derived for the chosen branch/lineage")
    _check(modifier_proven,id+" innate produced no effective stat delta")

func _probe_basic(tier: String) -> void:
    basic_cases += 1
    var prep: Dictionary
    var skill_id := ""
    if tier == "human":
        prep = V63HumanSkillCombatSystem.skill_definition("tmb.skill.bow.liep_anh.active_01.human")
        skill_id = "tmb.skill.bow.basic.human"
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
    var basic: Dictionary = V63HumanSkillCombatSystem.skill_definition(skill_id)
    actor["v63_skill_loadout"] = []
    actor["basic_interval"] = 1.0
    actor["basic_ratio"] = float(basic.get("damage_ratio",1.0))
    var battle := MapBattleV2.new(710000+serial)
    var target := _make_monster("basic_target_"+tier,Vector2(13.0,10.0))
    if not _check(bool(battle.setup("cung_basic_"+tier,[actor],[target]).get("ok",false)),tier+" basic setup"):
        return
    var hp_before := float(battle.actors[str(target.id)].hp)
    battle.run(4)
    var damage := 0.0
    for event in battle.events:
        if str(event.get("type","")) == "hit" and str(event.get("attacker","")) == str(actor.id) and str(event.get("kind","")) == "basic":
            damage += float(event.get("damage",0.0))
    var hp_after := float(battle.actors[str(target.id)].hp)
    print("CUNG_MATRIX_BASIC "+JSON.stringify({
        "tier":tier,"skill_id":skill_id,"expected":"basic damage>0 and target HP decreases",
        "hp_before":hp_before,"hp_after":hp_after,"damage_actual":damage
    }))
    _check(damage>0.0 and hp_after<hp_before,tier+" basic did not reduce HP")

func _probe_mobility(tier: String) -> void:
    mobility_cases += 1
    var seed: Dictionary
    var mobility_id := "tmb.skill.bow.mobility.human"
    if tier == "human":
        seed = V63HumanSkillCombatSystem.skill_definition("tmb.skill.bow.liep_anh.active_01.human")
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
    var battle := MapBattleV2.new(720000+serial)
    var target := _make_monster("mobility_target_"+tier,Vector2(20.0,10.0))
    if not _check(bool(battle.setup("cung_mobility_"+tier,[actor],[target]).get("ok",false)),tier+" mobility setup"):
        return
    var origin: Vector2 = battle.actors[str(actor.id)].position
    battle.step()
    var moved: Vector2 = battle.actors[str(actor.id)].position
    var evasion_until := float(battle.actors[str(actor.id)].get("v63_evasion_until",-1.0))
    var event_seen := false
    for event in battle.events:
        if str(event.get("type","")) == "v63_mobility" and str(event.get("skill_id","")) == mobility_id:
            event_seen = true
    var passed := moved.distance_to(origin)>0.1 and event_seen and evasion_until>battle.now
    print("CUNG_MATRIX_MOBILITY_ISOLATED "+JSON.stringify({
        "tier":tier,"skill_id":mobility_id,"moved":moved.distance_to(origin)>0.1,
        "evasion_active":evasion_until>battle.now,"event_seen":event_seen,
        "world_mode":"covered by v63_cung_world_mobility_test.gd"
    }))
    _check(passed,tier+" mobility did not move/evasion-event in isolated encounter")

func _probe_rotation() -> void:
    var loadout := [
        "tmb.skill.bow.liep_anh.active_01.human",
        "tmb.skill.bow.liep_anh.active_02.human",
        "tmb.skill.bow.liep_anh.active_03.human",
        "tmb.skill.bow.liep_anh.active_04.human",
        "tmb.skill.bow.liep_anh.ultimate.human"
    ]
    var actor := _make_actor("cung_rotation_actor",Vector2(10.0,10.0))
    actor["v63_combat_enabled"] = true
    actor["v63_combat_branch_id"] = "liep_anh"
    actor["v63_innate_skill_id"] = "tmb.skill.bow.liep_anh.innate.human"
    actor["v63_skill_loadout"] = loadout
    actor["basic_ratio"] = 0.0
    actor["basic_interval"] = 90.0
    actor["range"] = 5.5
    var target := _make_monster("cung_rotation_target",Vector2(13.0,10.0))
    var battle := MapBattleV2.new(790001)
    if not _check(bool(battle.setup("cung_multi_skill_rotation",[actor],[target]).get("ok",false)),"rotation battle setup"):
        return
    var validation := V63HumanSkillCombatSystem.validate_battle(battle)
    if not _check(validation.is_empty(),"multi-skill loadout failed combat validation: "+str(validation)):
        return
    battle.run(600)
    var by_skill: Dictionary = {}
    for event in battle.events:
        if str(event.get("type","")) == "skill_cast" and str(event.get("actor_id","")) == "cung_rotation_actor":
            var id := str(event.get("skill_id",""))
            by_skill[id] = int(by_skill.get(id,0))+1
    var non_first := false
    for id in by_skill.keys():
        if str(id) != loadout[0]:
            non_first = true
    print("CUNG_MATRIX_ROTATION "+JSON.stringify({"cast_counts":by_skill,"distinct_skills":by_skill.size(),"steps":600}))
    _check(by_skill.size()>=2 and by_skill.has(loadout[0]) and non_first,
        "AI did not rotate from active_01 to another ready Cung skill")

func _probe_kill_receipt() -> void:
    var skill_id := "tmb.skill.bow.liep_anh.active_01.human"
    var actor := _make_actor("cung_kill_actor",Vector2(10.0,10.0))
    actor["v63_combat_enabled"] = true
    actor["v63_combat_branch_id"] = "liep_anh"
    actor["v63_innate_skill_id"] = "tmb.skill.bow.liep_anh.innate.human"
    actor["v63_skill_loadout"] = [skill_id]
    actor["basic_ratio"] = 0.0
    actor["basic_interval"] = 90.0
    var target := _make_monster("cung_kill_target",Vector2(13.0,10.0))
    target["hp"] = 1.0
    target["max_hp"] = 1.0
    var target_stats: Dictionary = target.stats.duplicate(true)
    target_stats["max_hp"] = 1.0
    target["stats"] = target_stats
    target["spawn_slot_id"] = "cung_kill_slot"
    target["slot_generation"] = 1
    var battle := MapBattleV2.new(790002)
    var setup := battle.setup("cung_skill_kill_receipt",[actor],[target],true)
    if not _check(bool(setup.get("ok",false)),"kill receipt battle setup: "+str(setup)):
        return
    battle.run(40)
    var hit_seen := false
    for event in battle.events:
        if str(event.get("type","")) == "v63_skill_hit" and str(event.get("skill_id","")) == skill_id:
            hit_seen = hit_seen or float(event.get("damage",0.0)) > 0.0
    var kill_seen := false
    for receipt in battle.pending_kill_events():
        if str(receipt.get("world_id","")) == "cung_skill_kill_receipt" \
                and str(receipt.get("killer_actor_id","")) == "cung_kill_actor" \
                and str(receipt.get("damage_kind","")) == "skill" \
                and float(receipt.get("actual_damage",0.0)) > 0.0:
            kill_seen = true
    print("CUNG_MATRIX_KILL "+JSON.stringify({
        "skill_id":skill_id,"target_hp_after":battle.actors["cung_kill_target"].hp,
        "skill_hit":hit_seen,"pending_kill_receipt":kill_seen,
        "pending_kill_events":battle.pending_kill_events()
    }))
    _check(hit_seen and kill_seen and float(battle.actors["cung_kill_target"].hp)<=0.0,
        "Cung active did not produce a real HP0/continuous PvE kill receipt")

