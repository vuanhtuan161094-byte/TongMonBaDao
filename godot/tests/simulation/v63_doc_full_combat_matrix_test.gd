extends SceneTree

# Full Doc skill matrix runner for the ONE GAME integration tree.
# Run in the isolated QA checkout with the official Godot 4.7.2 executable.
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
            if str(skill.get("school","")) != "poison":
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
    _check(V63FeatureGates.all_disabled(), "release feature gates changed during isolated tests")
    _check(matrix_ids.size() == 183, "Doc catalogue matrix did not enumerate all 183 IDs")
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
    print("DOC_MATRIX_SUMMARY "+JSON.stringify({
        "integration_base_head":"70fc703a14108c42c32c5ca554c002504b6f96c3",
        "catalogue_ids":matrix_ids.size(),
        "slot_counts":slot_counts,
        "active_ultimate_cases":action_cases,
        "passive_effect_cases":passive_cases,
        "innate_effect_cases":innate_cases,
        "basic_cases":basic_cases,
        "isolated_mobility_cases":mobility_cases,
        "rotation_cases":1,
        "failures":failures,
        "runtime_status":"PASS_BASELINE_ONLY" if failures == 0 else "FAIL",
        "scope":"Per-ID baseline semantics only. Special Divine DESIGN_PENDING mechanics, live manual sourcing, world/PvE, VFX and physical QA are separate gates."
    }))
    quit(1 if failures > 0 else 0)

func _check(ok: bool, message: String) -> bool:
    if not ok:
        failures += 1
        push_error("DOC_AUDIT_FAIL "+message)
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
        "id":actor_id,"party_id":"doc_audit","role":"ranged","tier":"disciple",
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
    var state := _new_state("doc_audit_%d" % serial)
    var disciple := _new_disciple(state,branch_id,"doc_audit_%d" % serial)
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
    var id := str(skill.get("id", ""))
    var effect := str(skill.get("effect", ""))
    var prepared := _prepare(skill)
    if not _check(bool(prepared.get("ok", false)), id+" preparation failed: "+str(prepared.get("reason", ""))):
        return
    var actor: Dictionary = prepared.actor
    actor["basic_ratio"] = 0.0
    actor["basic_interval"] = 90.0
    var party: Array = [actor]
    var support_id := "doc_support_%d" % serial
    if effect in ["heal", "cleanse"]:
        var ally := _make_actor(support_id, Vector2(10.5, 10.0))
        ally["hp"] = 1000.0
        party.append(ally)
    var monsters: Array = [
        _make_monster("doc_enemy_%d_0" % serial, Vector2(11.5, 10.0)),
        _make_monster("doc_enemy_%d_1" % serial, Vector2(11.55, 10.0)),
        _make_monster("doc_enemy_%d_2" % serial, Vector2(11.60, 10.0))
    ]
    var battle := MapBattleV2.new(900000 + serial)
    var setup := battle.setup("doc_id_%d" % serial, party, monsters)
    if not _check(bool(setup.get("ok", false)), id+" battle setup: "+str(setup)):
        return
    var caster: Dictionary = battle.actors[str(actor.id)]
    var enemy: Dictionary = battle.actors[str(monsters[0].id)]
    if effect == "cleanse":
        var ally: Dictionary = battle.actors[support_id]
        var statuses: Dictionary = ally.get("status_effects", {})
        statuses["weaken"] = {"until":15.0, "factor":0.85}
        ally["status_effects"] = statuses
    if effect == "consume_poison":
        var real_source := "tmb.skill.poison.doc_cham.active_02.human"
        if not _check(str(V63HumanSkillCombatSystem.skill_definition(real_source).get("effect", "")) == "poison", id+" poison source not authored"):
            return
        for raw_target in monsters:
            var victim: Dictionary = battle.actors[str(raw_target.id)]
            V63HumanSkillCombatSystem._apply_poison(battle, caster, victim, real_source, 0.02, 8.0, 2, "nether")
    var initial_support_hp := float(battle.actors[support_id].hp) if battle.actors.has(support_id) else 0.0
    var initial_enemy_hp := float(enemy.hp)
    var began := V63HumanSkillCombatSystem.try_cast(battle, caster, enemy)
    if not _check(began, id+" could not begin a real cast"):
        return
    var pending: Dictionary = caster.get("v63_pending_cast", {})
    if not _check(not pending.is_empty(), id+" missing pending cast"):
        return
    var release_deadline := float(pending.get("ready", -1.0))
    var cast_row: Dictionary = {}
    for event in battle.events:
        if str(event.get("type", "")) == "skill_cast" and str(event.get("skill_id", "")) == id:
            cast_row = event
            break
    if not _check(not cast_row.is_empty() and release_deadline >= float(cast_row.get("time", INF))
            and is_equal_approx(release_deadline, float(cast_row.get("release_at", -2.0))),
            id+" cast event/deadline mismatch"):
        return
    battle.now = release_deadline
    battle._release_casts()
    var releases := 0
    var hits := 0
    var impacted: Dictionary = {}
    var damage := 0.0
    var heal := 0.0
    var cleansed := 0
    var consumed := 0
    var marked := 0
    var poison_applied := 0
    var valid_hp_delta := false
    for event in battle.events:
        if str(event.get("skill_id", "")) != id:
            continue
        var kind := str(event.get("type", ""))
        if kind == "skill_release":
            releases += 1
        elif kind == "v63_skill_hit":
            hits += 1
            impacted[str(event.get("target", ""))] = true
            damage += float(event.get("damage", 0.0))
            valid_hp_delta = valid_hp_delta or (float(event.get("damage", 0.0)) > 0.0
                and float(event.get("target_hp_after", 0.0)) < float(event.get("target_hp_before", 0.0)))
        elif kind == "heal":
            heal += float(event.get("amount", 0.0))
        elif kind == "cleanse":
            cleansed += int(event.get("removed_debuff_count", 0))
        elif kind == "poison_consumed":
            consumed += int(event.get("stacks", 0))
        elif kind == "status_applied":
            if str(event.get("status", "")) == "mark":
                marked += 1
            if str(event.get("status", "")) == "poison":
                poison_applied += int(event.get("added", 0))
    var limit := mini(3, int(skill.get("target_limit", 1)))
    _check(releases == 1 and hits >= 1 and impacted.size() <= limit,
        id+" cast/release/target limit failed: "+str([releases, hits, impacted.size(), limit]))
    var semantic_ok := false
    match effect:
        "damage":
            semantic_ok = damage > 0.0 and valid_hp_delta and float(enemy.hp) < initial_enemy_hp
        "poison":
            var stacks: Array = enemy.get("status_effects", {}).get("v63_poison", [])
            var owned := false
            for stack in stacks:
                if str(stack.get("owner_id", "")) == str(caster.id) and str(stack.get("source_skill_id", "")) == id:
                    owned = true
            var before_tick := float(enemy.hp)
            battle.now += 1.0
            V63HumanSkillCombatSystem.process_status_effects(battle)
            var dot_tick := false
            for event in battle.events:
                if str(event.get("type", "")) == "status_tick" and str(event.get("source_skill_id", "")) == id:
                    dot_tick = dot_tick or (float(event.get("damage", 0.0)) > 0.0
                        and float(event.get("target_hp_after", INF)) < float(event.get("target_hp_before", INF)))
            semantic_ok = damage > 0.0 and valid_hp_delta and owned and poison_applied > 0 and dot_tick and float(enemy.hp) < before_tick
        "consume_poison":
            semantic_ok = damage > 0.0 and valid_hp_delta and consumed > 0
            for raw_target in monsters:
                var victim: Dictionary = battle.actors[str(raw_target.id)]
                for stack in victim.get("status_effects", {}).get("v63_poison", []):
                    if str(stack.get("owner_id", "")) == str(caster.id):
                        semantic_ok = false
        "mark":
            semantic_ok = damage > 0.0 and valid_hp_delta and marked > 0 and enemy.get("v63_marks", {}).has(str(caster.id))
        "heal":
            semantic_ok = heal > 0.0 and float(battle.actors[support_id].hp) > initial_support_hp
        "cleanse":
            semantic_ok = cleansed > 0 and not battle.actors[support_id].get("status_effects", {}).has("weaken")
        _:
            _check(false, id+" unsupported authored action effect: "+effect)
    _check(semantic_ok, id+" semantic effect not committed: "+effect)
    var cooldown_at := float(caster.get("v63_skill_ready", {}).get(id, -1.0))
    _check(cooldown_at > float(cast_row.get("time", 0.0))
        and is_equal_approx(cooldown_at, float(cast_row.get("cooldown_ready_at", -2.0))),
        id+" cooldown authority mismatch")
    var snapshot := MapBattleSnapshotV2.save(battle)
    var loaded := MapBattleSnapshotV2.load(snapshot)
    _check(bool(snapshot.get("ok", false)) and bool(loaded.get("ok", false))
        and (loaded.get("battle", null) is MapBattleV2),
        id+" post-effect snapshot roundtrip failed")
    print("DOC_MATRIX_ID "+JSON.stringify({
        "id":id, "tier":str(skill.get("generation", skill.get("tier", "human"))),
        "branch":str(skill.get("branch", "")), "lineage":str(skill.get("lineage", "")),
        "effect":effect, "release_count":releases, "hits":hits,
        "targets":impacted.size(), "damage":damage, "heal":heal,
        "cleanse_count":cleansed, "consumed":consumed,
        "poison_applied":poison_applied, "mark_count":marked,
        "cooldown_ready":cooldown_at, "snapshot_ok":bool(loaded.get("ok", false)),
        "semantic_ok":semantic_ok, "special_rule_status":str(skill.get("divine_rule_status", ""))
    }))

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
    print("DOC_MATRIX_PASSIVE "+JSON.stringify({
        "skill_id":id,"learned":true,"equipped":true,"attached":present,
        "modifier_delta_proven":modifier_proven,"passive_modifiers":skill.get("passive_modifiers",{})
    }))
    _check(present,id+" passive not attached")
    _check(modifier_proven,id+" passive produced no effective stat delta")

func _probe_innate(skill: Dictionary) -> void:
    innate_cases += 1
    var id := str(skill.get("id",""))
    var anchor_id := id.replace(".innate.",".active_01.")
    var anchor_skill := V63HumanSkillCombatSystem.skill_definition(anchor_id)
    if not _check(not anchor_skill.is_empty(),id+" missing active lineage anchor "+anchor_id):
        return
    var prepared := _prepare(anchor_skill)
    if not _check(bool(prepared.get("ok",false)),id+" innate preparation: "+str(prepared.get("reason",""))):
        return
    var actor: Dictionary = prepared.actor
    var derived_id := str(actor.get("v63_innate_skill_id",""))
    var without_skill: Dictionary = actor.duplicate(true)
    without_skill.erase("v63_innate_skill_id")
    var modifier_proven := _modifier_changed(skill,actor,without_skill,true)
    print("DOC_MATRIX_INNATE "+JSON.stringify({
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
        prep = V63HumanSkillCombatSystem.skill_definition("tmb.skill.poison.doc_cham.active_01.human")
        skill_id = "tmb.skill.poison.basic.human"
    elif tier == "immortal":
        prep = V63HumanSkillCombatSystem.skill_definition("tmb.skill.poison.doc_cham.active_01.immortal.a")
        skill_id = "tmb.skill.poison.basic.immortal.base"
    else:
        prep = V63HumanSkillCombatSystem.skill_definition("tmb.skill.poison.doc_cham.active_01.divine.a")
        skill_id = "tmb.skill.poison.basic.divine.base"
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
    if not _check(bool(battle.setup("doc_basic_"+tier,[actor],[target]).get("ok",false)),tier+" basic setup"):
        return
    var hp_before := float(battle.actors[str(target.id)].hp)
    battle.run(4)
    var damage := 0.0
    for event in battle.events:
        if str(event.get("type","")) == "hit" and str(event.get("attacker","")) == str(actor.id) and str(event.get("kind","")) == "basic":
            damage += float(event.get("damage",0.0))
    var hp_after := float(battle.actors[str(target.id)].hp)
    print("DOC_MATRIX_BASIC "+JSON.stringify({
        "tier":tier,"skill_id":skill_id,"expected":"basic damage>0 and target HP decreases",
        "hp_before":hp_before,"hp_after":hp_after,"damage_actual":damage
    }))
    _check(damage>0.0 and hp_after<hp_before,tier+" basic did not reduce HP")

func _probe_mobility(tier: String) -> void:
    mobility_cases += 1
    var seed: Dictionary
    var mobility_id := "tmb.skill.poison.mobility.human"
    if tier == "human":
        seed = V63HumanSkillCombatSystem.skill_definition("tmb.skill.poison.doc_cham.active_01.human")
    elif tier == "immortal":
        seed = V63HumanSkillCombatSystem.skill_definition("tmb.skill.poison.doc_cham.active_01.immortal.a")
        mobility_id = "tmb.skill.poison.mobility.immortal.base"
    else:
        seed = V63HumanSkillCombatSystem.skill_definition("tmb.skill.poison.doc_cham.active_01.divine.a")
        mobility_id = "tmb.skill.poison.mobility.divine.base"
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
    if not _check(bool(battle.setup("doc_mobility_"+tier,[actor],[target]).get("ok",false)),tier+" mobility setup"):
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
    print("DOC_MATRIX_MOBILITY_ISOLATED "+JSON.stringify({
        "tier":tier,"skill_id":mobility_id,"moved":moved.distance_to(origin)>0.1,
        "evasion_active":evasion_until>battle.now,"event_seen":event_seen,
        "world_mode":"NOT_TESTED_IN_THIS_SUITE"
    }))
    _check(passed,tier+" mobility did not move/evasion-event in isolated encounter")

func _probe_rotation() -> void:
    var loadout := [
        "tmb.skill.poison.doc_cham.active_01.human",
        "tmb.skill.poison.doc_cham.active_02.human",
        "tmb.skill.poison.doc_cham.active_03.human",
        "tmb.skill.poison.doc_cham.active_04.human",
        "tmb.skill.poison.doc_cham.ultimate.human"
    ]
    var actor := _make_actor("doc_rotation_actor",Vector2(10.0,10.0))
    actor["v63_combat_enabled"] = true
    actor["v63_combat_branch_id"] = "doc_cham"
    actor["v63_innate_skill_id"] = "tmb.skill.poison.doc_cham.innate.human"
    actor["v63_skill_loadout"] = loadout
    actor["basic_ratio"] = 0.0
    actor["basic_interval"] = 90.0
    actor["range"] = 5.5
    var target := _make_monster("doc_rotation_target",Vector2(13.0,10.0))
    var battle := MapBattleV2.new(790001)
    if not _check(bool(battle.setup("doc_multi_skill_rotation",[actor],[target]).get("ok",false)),"rotation battle setup"):
        return
    var validation := V63HumanSkillCombatSystem.validate_battle(battle)
    if not _check(validation.is_empty(),"multi-skill loadout failed combat validation: "+str(validation)):
        return
    battle.run(600)
    var by_skill: Dictionary = {}
    for event in battle.events:
        if str(event.get("type","")) == "skill_cast" and str(event.get("actor_id","")) == "doc_rotation_actor":
            var id := str(event.get("skill_id",""))
            by_skill[id] = int(by_skill.get(id,0))+1
    var non_first := false
    for id in by_skill.keys():
        if str(id) != loadout[0]:
            non_first = true
    print("DOC_MATRIX_ROTATION "+JSON.stringify({"cast_counts":by_skill,"distinct_skills":by_skill.size(),"steps":600}))
    _check(by_skill.size()>=2 and by_skill.has(loadout[0]) and non_first,
        "AI did not rotate from active_01 to another ready Doc skill")

func _probe_kill_receipt() -> void:
    var skill_id := "tmb.skill.poison.doc_cham.active_01.human"
    var actor := _make_actor("doc_kill_actor",Vector2(10.0,10.0))
    actor["v63_combat_enabled"] = true
    actor["v63_combat_branch_id"] = "doc_cham"
    actor["v63_innate_skill_id"] = "tmb.skill.poison.doc_cham.innate.human"
    actor["v63_skill_loadout"] = [skill_id]
    actor["basic_ratio"] = 0.0
    actor["basic_interval"] = 90.0
    var target := _make_monster("doc_kill_target",Vector2(13.0,10.0))
    target["hp"] = 1.0
    target["max_hp"] = 1.0
    var target_stats: Dictionary = target.stats.duplicate(true)
    target_stats["max_hp"] = 1.0
    target["stats"] = target_stats
    target["spawn_slot_id"] = "doc_kill_slot"
    target["slot_generation"] = 1
    var battle := MapBattleV2.new(790002)
    var setup := battle.setup("doc_skill_kill_receipt",[actor],[target],true)
    if not _check(bool(setup.get("ok",false)),"kill receipt battle setup: "+str(setup)):
        return
    battle.run(40)
    var hit_seen := false
    for event in battle.events:
        if str(event.get("type","")) == "v63_skill_hit" and str(event.get("skill_id","")) == skill_id:
            hit_seen = hit_seen or float(event.get("damage",0.0)) > 0.0
    var kill_seen := false
    for receipt in battle.pending_kill_events():
        if str(receipt.get("world_id","")) == "doc_skill_kill_receipt" \
                and str(receipt.get("killer_actor_id","")) == "doc_kill_actor" \
                and str(receipt.get("damage_kind","")) in ["skill","v63_skill"] \
                and float(receipt.get("actual_damage",0.0)) > 0.0:
            kill_seen = true
    print("DOC_MATRIX_KILL "+JSON.stringify({
        "skill_id":skill_id,"target_hp_after":battle.actors["doc_kill_target"].hp,
        "skill_hit":hit_seen,"pending_kill_receipt":kill_seen,
        "pending_kill_events":battle.pending_kill_events()
    }))
    _check(hit_seen and kill_seen and float(battle.actors["doc_kill_target"].hp)<=0.0,
        "Doc active did not produce a real HP0/continuous PvE kill receipt")

