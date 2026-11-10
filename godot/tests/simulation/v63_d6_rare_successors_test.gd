extends SceneTree

const PREVIEW := {"sect_codex":true,"technique_learning":true,"human_skill_combat":true,"divine_skill_combat":true}

func _init() -> void:
    call_deferred("_run")

func _check(value: bool, message: String) -> bool:
    if not value:
        push_error("V63_D6_RARE_FAIL: " + message)
        quit(1)
    return value

func _run() -> void:
    if not _check(not V63FeatureGates.is_enabled("divine_skill_combat"), "Divine gate must default OFF"):
        return
    for branch in V63DivineSkillCombatSystem.branch_definitions().values():
        for lineage in ["a", "b"]:
            if not _rare_path(branch, lineage):
                return
    if not _divine_study():
        return
    if not _poison_snapshot():
        return
    if not _passive_safety():
        return
    if not _blood_rules():
        return
    print("V63_D6_RARE_PASS: 18/18 ultimate and elective replacements; real releases; 30-stack fair poison + snapshot; Blood Ma/Life heal boundaries")
    quit(0)

func _rare_path(branch: Dictionary, lineage: String) -> bool:
    var created := _new_state("rare_" + str(branch.id) + lineage)
    var state: SimulationState = created.state
    var disciple: DiscipleState = created.disciple
    var codex := "tmb.codex.%s.%s.rare_lineage_%s.divine" % [str(branch.school), str(branch.id), lineage]
    var normal_codex := "tmb.codex.%s.%s.lineage_%s.divine" % [str(branch.school), str(branch.id), lineage]
    if not _archive_manual(state, codex) or not _archive_manual(state, normal_codex):
        return false
    var ultimate := "tmb.skill.%s.%s.ultimate.rare.%s" % [str(branch.school), str(branch.id), lineage]
    if not _check(not bool(V63HumanSkillCombatSystem.learn_skill(state, disciple, ultimate, PREVIEW).get("ok", false)), "Rare unlocked without stage III"):
        return false
    for technique in branch.divine_technique_ids[lineage]:
        disciple.known_techniques[str(technique)] = {"mastery_xp":0.0,"mastery_stage":0,"learned_tick":0}
    for slot in ["ultimate", "passive_05"]:
        var normal := "tmb.skill.%s.%s.%s.divine.%s" % [str(branch.school), str(branch.id), slot, lineage]
        var rare := "tmb.skill.%s.%s.%s.%s.%s" % [str(branch.school), str(branch.id), slot, "rare" if slot == "ultimate" else "rare_passive", lineage]
        for id in [normal, rare]:
            if not _check(bool(V63HumanSkillCombatSystem.learn_skill(state, disciple, id, PREVIEW).get("ok", false)), "Rare learn rejected " + id):
                return false
            if not _check(bool(V63HumanSkillCombatSystem.equip_skill(state, disciple, id, PREVIEW).get("ok", false)), "Rare equip rejected " + id):
                return false
        if not _check(not disciple.v63_equipped_skill_ids.has(normal) and disciple.v63_equipped_skill_ids.has(rare), "Rare added a slot instead of replacing"):
            return false
    var actor := _actor(str(disciple.id), Vector2(18, 8))
    actor["disciple"] = disciple
    if not bool(V63HumanSkillCombatSystem.attach_disciple_loadout(state, actor, PREVIEW).get("ok", false)):
        return _check(false, "Divine attach failed")
    var monster := MonsterCatalogueV2.create_actor("truc_thu", 11, 1, "rare_target")
    monster["id"] = "rare_target"
    monster["position"] = Vector2(19, 8)
    var battle := MapBattleV2.new(67001)
    if not _check(bool(battle.setup("rare_test", [actor], [monster]).get("ok", false)), "Rare battle setup"):
        return false
    # Let the actual decision/cast/release pipeline resolve the equipped successor.
    battle.run(100)
    for event in battle.events:
        if str(event.get("type", "")) == "divine_action" and str(event.get("skill_id", "")) == ultimate:
            var record: Dictionary = disciple.v63_learned_skill_nodes[ultimate]
            if not _check(float(record.mastery_xp) > 0.0, "Real cast did not award personal mastery"):
                return false
            var receipt := str(record.mastery_cast_receipts.keys()[0])
            if not _check(not V63HumanSkillCombatSystem.record_cast_mastery(battle.actors[str(disciple.id)], ultimate, receipt), "Cast mastery replay awarded XP twice"):
                return false
            return true
    return _check(false, "Rare ultimate did not release: " + ultimate)

func _actor(id: String, position: Vector2) -> Dictionary:
    var core := CombatStatsV2.derive(11, 1, 10, 1, 0.0)
    var stats: Dictionary = core.stats.duplicate(true)
    stats["max_hp"] = 10000.0
    stats["attack"] = 100.0
    stats["defense"] = 40.0
    return {"id":id,"party_id":"d6","role":"frontline","tier":"disciple","race_id":"nhan_toc","position":position,"stats":stats,"hp":10000.0,"max_hp":10000.0,"resistances":core.resistances,"basic_range":2.0,"move_speed":1.0,"basic_ratio":0.1,"basic_interval":20.0,"skill_loadout":[],"skill_factors":{},"context_sources":[],"disciple":null}

func _poison_snapshot() -> bool:
    var party: Array = []
    for index in range(6):
        party.append(_actor("owner_" + str(index), Vector2(18, 6 + index)))
    var monster := MonsterCatalogueV2.create_actor("truc_thu", 11, 1, "poison_target")
    monster["id"] = "poison_target"
    monster["position"] = Vector2(22, 8)
    monster.stats["max_hp"] = 10000000.0
    monster["hp"] = 10000000.0
    var battle := MapBattleV2.new(67002)
    if not _check(bool(battle.setup("owned_poison", party, [monster]).get("ok", false)), "Poison battle setup"):
        return false
    var target: Dictionary = battle.actors.poison_target
    var skill := "tmb.skill.poison.doc_cham.active_02.divine.a"
    var poison_definition := V63HumanSkillCombatSystem.skill_definition(skill)
    if not _check(str(poison_definition.get("effect", "")) == "poison", "snapshot fixture must use a canonical poison action"):
        return false
    for index in range(6):
        battle.actors["owner_" + str(index)]["v63_skill_loadout"] = [skill]
        battle.actors["owner_" + str(index)]["v63_combat_enabled"] = true
        for _cast_index in range(3):
            V63HumanSkillCombatSystem._apply_poison(battle, battle.actors["owner_" + str(index)], target, skill,
                float(poison_definition.get("power", 0.0)), float(poison_definition.get("duration", 0.0)),
                int(poison_definition.get("poison_stacks", 0)), str(poison_definition.get("element", "")))
    if not _check(target.status_effects.v63_poison.size() == 30, "Poison owner cap/target cap"):
        return false
    var restored := MapBattleSnapshotV2.load(MapBattleSnapshotV2.save(battle))
    if not _check(bool(restored.get("ok", false)), "Owned poison snapshot failed: " + str(restored)):
        return false
    battle = restored.battle
    battle.now = 1.0
    V63HumanSkillCombatSystem.process_status_effects(battle)
    var ticks := 0
    for event in battle.events:
        if str(event.get("type", "")) == "status_tick":
            ticks += 1
            if not _check(is_equal_approx(float(event.diminishing_factor), 0.65), "Order-biased poison allocation"):
                return false
    return _check(ticks == 30, "Poison ticks missing")

func _blood_rules() -> bool:
    var target := {"id":"blood","hp":3500.0,"max_hp":6500.0,"v63_base_max_hp":10000.0,"v63_blood_mode":"blood_ma"}
    var ally := {"id":"ally"}
    if not _check(V63DivineSkillCombatSystem.healing_amount(ally, target, 100.0) == 0.0, "Blood Ma threshold must use original HP"):
        return false
    target.hp = 3499.0
    if not _check(V63DivineSkillCombatSystem.healing_amount(ally, target, 100.0) == 50.0 and V63DivineSkillCombatSystem.healing_amount(target, target, 100.0) == 0.0, "Blood Ma half allied heal / no self heal"):
        return false
    target.v63_blood_mode = "blood_covenant"
    if not _check(V63DivineSkillCombatSystem.healing_amount(ally, target, 100.0) == 0.0, "Rare covenant permits healing"):
        return false
    target.v63_blood_mode = "blood_life"
    return _check(V63DivineSkillCombatSystem.healing_amount(target, target, 100.0) == 100.0, "Blood Life incorrectly sealed")

func _new_state(disciple_id: String) -> Dictionary:
    var state := SimulationState.new()
    state.sect.disciple_capacity = 32
    state.p3_7_buildings_enabled = true
    state.sect.p3_7_resources_enabled = true
    state.sect.v63_archive_opt_in = true
    state.sect.v63_learning_opt_in = true
    state.sect.v63_skill_combat_opt_in = true
    var disciple := DiscipleState.new({"id":disciple_id,"name":disciple_id})
    state.disciples[disciple.id] = disciple
    return {"state":state,"disciple":disciple}

func _archive_manual(state: SimulationState, codex_id: String) -> bool:
    var codex := V63SectArchiveSystem.codex_definition(codex_id)
    if not _check(not codex.is_empty() and bool(codex.get("archivable", false)), "manual source missing: " + codex_id):
        return false
    var warehouse := WarehouseSystem.new()
    var item_id := StringName(str(codex.get("manual_item_id", "")))
    if not _check(warehouse.registry.has(item_id) and warehouse.add(state, item_id, 1), "canonical Warehouse rejected manual: " + str(item_id)):
        return false
    var result := V63SectArchiveSystem.archive_manual(state, codex_id, PREVIEW)
    return _check(bool(result.get("ok", false)), "Archive rejected D5 manual: " + str(result))



func _divine_study() -> bool:
    var created := _new_state("divine_student")
    var state: SimulationState = created.state
    var disciple: DiscipleState = created.disciple
    disciple.current_action = &"HOLD"
    disciple.contribution_points = 100000
    disciple.spirit_stones = 20000000
    var codex := "tmb.codex.bow.liep_anh.lineage_a.divine"
    var immortal_codex := "tmb.codex.bow.liep_anh.lineage_a.immortal"
    if not _archive_manual(state, codex) or not _archive_manual(state, immortal_codex):
        return false
    var main := "tmb.technique.bow.liep_anh.immortal.a"
    disciple.known_techniques[main] = {"mastery_xp":1000.0,"mastery_stage":3,"learned_tick":0,"source_codex_id":immortal_codex}
    disciple.active_technique_main = StringName(main)
    var ultimate := "tmb.skill.bow.liep_anh.ultimate.immortal.a"
    if not _check(bool(V63HumanSkillCombatSystem.learn_skill(state, disciple, ultimate, PREVIEW).get("ok", false)), "Immortal prerequisite learning failed"):
        return false
    disciple.v63_learned_skill_nodes[ultimate]["level"] = 2
    var branch: Dictionary = V63DivineSkillCombatSystem.branch_definitions().liep_anh
    var learning := V63LearningSystem.new()
    for stage in range(3):
        var id := StringName(branch.divine_technique_ids.a[stage])
        var realm: int = [21,25,29][stage]
        disciple.v2_realm_progress = _realm_profile(realm - 1, 10)
        var denied := learning.can_start_study(state, disciple, id, PREVIEW)
        if not _check(str(denied.get("reason", "")) == "divine_realm_gate_required", "Divine stage ignored realm gate"):
            return false
        disciple.v2_realm_progress = _realm_profile(realm, 10)
        var request := "d6:study:" + str(stage)
        var started := learning.start_study(state, disciple, id, request, PREVIEW)
        if not _check(bool(started.get("ok", false)) and not disciple.active_job_id.is_empty(), "Divine study did not claim One Active Job: " + str(started)):
            return false
        var balances := [disciple.contribution_points, disciple.spirit_stones]
        var retry := learning.start_study(state, disciple, id, request, PREVIEW)
        if not _check(bool(retry.get("duplicate", false)) and balances == [disciple.contribution_points, disciple.spirit_stones], "Divine study retry charged twice"):
            return false
        state.tick += int(started.job.duration_ticks)
        if not _check(learning.process_tick(state, PREVIEW) == 1 and disciple.known_techniques.has(str(id)) and disciple.active_job_id.is_empty(), "Divine study did not complete exactly once"):
            return false
        if not _check(learning.process_tick(state, PREVIEW) == 0, "Divine study completed twice"):
            return false
    var loaded := SimulationState.from_dict(state.to_dict())
    return _check(loaded != null and V63LearningSystem.divine_lineage_stage(loaded.disciples[disciple.id], "liep_anh", "a") == 3, "Divine study/save stage lost")

func _realm_profile(cultivation_realm: int, body_realm: int) -> Dictionary:
    var track := func(realm: int) -> Dictionary:
        return {"realm":realm,"floor":1,"xp":0.0,"gate_failures":0,"lifetime_failures":0,
            "auto_breakthrough":false,"breakthrough_history":[],"last_training_event_id":""}
    return {"version":1,"initialized":true,"last_training_tick":-1,"last_passive_tuvi_tick":-1,
        "last_body_xp_tick":-1,"training_policy":"balanced","cultivation":track.call(cultivation_realm),"body":track.call(body_realm)}


func _passive_safety() -> bool:
    for lineage in ["a", "b"]:
        var actor := _actor("protected", Vector2(18,8))
        actor["v63_passive_ids"] = ["tmb.skill.fist.kim_cang.passive_05.rare_passive." + lineage]
        actor["v63_combat_enabled"] = true
        var monster := MonsterCatalogueV2.create_actor("truc_thu", 11, 1, "safety_attacker")
        monster["id"] = "safety_attacker"
        monster["position"] = Vector2(19,8)
        monster.stats["max_hp"] = 10000000.0
        monster["hp"] = 10000000.0
        var battle := MapBattleV2.new(67003)
        if not _check(bool(battle.setup("passive_safety", [actor], [monster]).get("ok", false)), "Passive safety setup"):
            return false
        var target: Dictionary = battle.actors.protected
        var attacker: Dictionary = battle.actors.safety_attacker
        if lineage == "a":
            battle._deal_direct(attacker, target, 1000000.0, "v63_skill", false, "earth", false)
            if not _check(float(target.hp) == 1.0 and float(target.get("v63_fatal_save_ready_at", 0.0)) == 90.0, "Fatal protection did not prevent lethal HP0"):
                return false
            battle._deal_direct(attacker, target, 1000000.0, "v63_skill", false, "earth", false)
            if not _check(float(target.hp) == 0.0, "Fatal protection ignored family cooldown"):
                return false
        else:
            var before := float(attacker.hp)
            battle._deal_direct(attacker, target, 0.1, "v63_skill", false, "earth", false)
            var reflections := 0
            for event in battle.events:
                if str(event.get("kind", "")) == "v63_reflection":
                    reflections += 1
            if not _check(float(attacker.hp) < before and reflections == 1, "Committed-damage reflection missing or recursive"):
                return false
    return true
