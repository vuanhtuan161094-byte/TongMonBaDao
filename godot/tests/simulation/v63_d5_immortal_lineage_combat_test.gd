extends SceneTree

const PREVIEW := {"sect_codex":true,"technique_learning":true,"human_skill_combat":true}
const BRANCH_IDS := ["liep_anh","linh_tien","thien_vu","ba_quyen","kim_cang","huyet_quyen","doc_cham","co_doc","duoc_doc"]

func _init() -> void:
	call_deferred("_run")

func _fail(message: String) -> void:
	push_error("V63_D5_IMMORTAL_COMBAT_FAIL: " + message)
	quit(1)

func _check(value: bool, message: String) -> bool:
	if not value:
		_fail(message)
		return false
	return true

func _run() -> void:
	if not _check(not V63FeatureGates.is_enabled("human_skill_combat"), "Combat V2 feature gate must remain OFF by default"):
		return
	var loaded := V63ImmortalSkillCombatSystem.load_catalogue()
	if not _check(bool(loaded.get("ok", false)), "Immortal catalog invalid: " + str(loaded.get("errors", []))):
		return
	var catalog: Dictionary = loaded.data
	if not _check(catalog.branches.size() == 9 and catalog.skills.size() == 204 and catalog.bosses.size() == 3,
		"D5 coverage must be nine branches, 186 actions, 18 derived innates and three bosses"):
		return
	for branch in catalog.branches:
		var a_id := "tmb.skill.%s.%s.active_01.immortal.a" % [str(branch.school), str(branch.id)]
		var b_id := "tmb.skill.%s.%s.active_01.immortal.b" % [str(branch.school), str(branch.id)]
		var a: Dictionary = V63HumanSkillCombatSystem.skill_definition(a_id)
		var b: Dictionary = V63HumanSkillCombatSystem.skill_definition(b_id)
		if not _check(not a.is_empty() and not b.is_empty() and a.effect != b.effect,
			"both lineage variants must have distinct combat actions: " + str(branch.id)):
			return
		for lineage in ["a", "b"]:
			if not _combat_branch_path(str(branch.id), lineage):
				return
	for boss in catalog.bosses:
		if not _boss_counter_test(str(boss.id)):
			return
	if not _reaction_test():
		return
	print("V63_D5_IMMORTAL_COMBAT_PASS: 18/18 manual-backed lineage casts; A/B family replacement; 3/3 Combat V2 boss counter interruptions; elemental reaction; gates OFF")
	quit(0)

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

func _combat_branch_path(branch_id: String, lineage: String) -> bool:
	var branch: Dictionary = V63ImmortalSkillCombatSystem.branch_definitions().get(branch_id, {})
	var school := str(branch.get("school", ""))
	var skill_id := "tmb.skill.%s.%s.active_01.immortal.%s" % [school, branch_id, lineage]
	var codex_id := "tmb.codex.%s.%s.lineage_%s.immortal" % [school, branch_id, lineage]
	var state_result := _new_state("d5_%s_%s" % [branch_id, lineage])
	var state: SimulationState = state_result.state
	var disciple: DiscipleState = state_result.disciple
	if not _archive_manual(state, codex_id):
		return false
	var technique_id := str(branch.get("lineage_technique_ids", {}).get(lineage, ""))
	disciple.known_techniques[technique_id] = {"mastery_xp":0.0,"mastery_stage":0,"learned_tick":0,"source_codex_id":codex_id}
	var learned := V63HumanSkillCombatSystem.learn_skill(state, disciple, skill_id, PREVIEW)
	if not _check(bool(learned.get("ok", false)), "lineage skill did not require completed path study and archived manual: " + str(learned)):
		return false
	var equipped := V63HumanSkillCombatSystem.equip_skill(state, disciple, skill_id, PREVIEW)
	if not _check(bool(equipped.get("ok", false)), "lineage skill did not equip: " + str(equipped)):
		return false
	if lineage == "a":
		var other_id := "tmb.skill.%s.%s.active_01.immortal.b" % [school, branch_id]
		var other_codex := "tmb.codex.%s.%s.lineage_b.immortal" % [school, branch_id]
		if not _archive_manual(state, other_codex):
			return false
		var other_technique := str(branch.get("lineage_technique_ids", {}).get("b", ""))
		disciple.known_techniques[other_technique] = {"mastery_xp":0.0,"mastery_stage":0,"learned_tick":0,"source_codex_id":other_codex}
		if not _check(bool(V63HumanSkillCombatSystem.learn_skill(state, disciple, other_id, PREVIEW).get("ok", false)), "alternate path history was not learnable"):
			return false
		var switch := V63HumanSkillCombatSystem.equip_skill(state, disciple, other_id, PREVIEW)
		if not _check(bool(switch.get("ok", false)) and disciple.v63_equipped_skill_ids.has(other_id)
			and not disciple.v63_equipped_skill_ids.has(skill_id), "only one A/B descendant may remain equipped per family"):
			return false
		disciple.v63_equipped_skill_ids.append(skill_id)
		var invalid_loadout := V63HumanSkillCombatSystem.validate_state(state)
		if not _check(not invalid_loadout.is_empty(), "state validation accepted conflicting family/path successors"):
			return false
		disciple.v63_equipped_skill_ids.erase(skill_id)
		# Exercise A's actual cast before the deliberate path switch below by restoring it as the only active descendant.
		disciple.v63_equipped_skill_ids.erase(other_id)
		disciple.v63_equipped_skill_ids.append(skill_id)
	var core := CombatStatsV2.derive(11,1,10,1,0.0)
	var stats: Dictionary = core.stats.duplicate(true)
	stats["max_hp"] = 20000.0
	stats["attack"] = 180.0
	stats["defense"] = 50.0
	var actor := {"id":str(disciple.id),"party_id":"d5_"+branch_id+lineage,"role":"frontline","tier":"disciple",
		"race_id":"nhan_toc","position":Vector2(18.0,8.0),"stats":stats,"hp":18000.0,"max_hp":20000.0,
		"resistances":core.resistances.duplicate(true),"basic_range":5.5,"move_speed":2.0,"basic_ratio":0.4,
		"basic_interval":2.0,"skill_loadout":[],"skill_factors":{},"context_sources":[],"disciple":null}
	var attach := V63HumanSkillCombatSystem.attach_disciple_loadout(state, actor, PREVIEW)
	if not _check(bool(attach.get("ok", false)) and str(actor.get("v63_innate_skill_id", "")) == str(branch.innate_node_ids[lineage]),
		"derived Immortal path innate did not attach: " + branch_id + "/" + lineage):
		return false
	var target_result := MonsterCatalogueV2.create_actor("truc_thu", 11, 1, "d5_target_"+branch_id+lineage)
	if not bool(target_result.get("ok", false)):
		return _check(false, "could not create Combat V2 target for " + skill_id)
	var target: Dictionary = target_result.duplicate(true)
	target["id"] = "target_" + branch_id + lineage
	target["position"] = Vector2(21.0,8.0)
	var battle := MapBattleV2.new(95000 + abs((branch_id+lineage).hash() % 1000))
	if not _check(bool(battle.setup("d5_lineage_"+branch_id+lineage, [actor], [target]).get("ok", false)), "Combat V2 rejected D5 loadout: " + skill_id):
		return false
	battle.run(100)
	var cast_seen := false
	var hit_seen := false
	for event in battle.events:
		if str(event.get("type", "")) == "skill_cast" and str(event.get("skill_id", "")) == skill_id:
			cast_seen = true
		if str(event.get("type", "")) == "v63_skill_hit" and str(event.get("skill_id", "")) == skill_id:
			hit_seen = true
	return _check(cast_seen and hit_seen, "Immortal lineage did not cast and resolve through Combat V2: " + branch_id + "/" + lineage)

func _boss_counter_test(boss_id: String) -> bool:
	var spawned := HuntingMapV2.spawn("thanh_truc_lam", 1, "d5_boss_"+boss_id, 96000 + abs(boss_id.hash() % 1000))
	if not _check(bool(spawned.get("ok", false)), "D5 boss source map failed: " + boss_id):
		return false
	var installed := V63HumanSkillCombatSystem.install_boss_spawn(spawned, boss_id)
	if not _check(bool(installed.get("ok", false)), "D5 boss did not install from HuntingMap V2: " + str(installed)):
		return false
	var boss: Dictionary = installed.boss_actor.duplicate(true)
	var pos: Vector2 = boss.get("position", Vector2(20, 8))
	var core := CombatStatsV2.derive(11,1,10,1,0.0)
	var stats: Dictionary = core.stats.duplicate(true)
	stats["max_hp"] = 100000.0
	stats["attack"] = 250.0
	stats["defense"] = 100.0
	var party := [{"id":"party_"+boss_id,"party_id":"party_d5_boss","role":"frontline","tier":"disciple","race_id":"nhan_toc",
		"position":pos+Vector2(-1.0,0.0),"stats":stats,"hp":100000.0,"max_hp":100000.0,
		"resistances":core.resistances.duplicate(true),"basic_range":1.5,"move_speed":1.0,"basic_ratio":0.1,"basic_interval":8.0,
		"skill_loadout":[],"skill_factors":{},"context_sources":[],"disciple":null}]
	var battle := MapBattleV2.new(97000 + abs(boss_id.hash() % 1000))
	if not _check(bool(battle.setup("d5_counter_"+boss_id, party, [boss]).get("ok", false)), "D5 boss could not enter Combat V2: " + boss_id):
		return false
	var boss_actor: Dictionary = battle.actors.get(str(boss.id), {})
	var player_actor: Dictionary = battle.actors.get("party_"+boss_id, {})
	if not _check(V63HumanSkillCombatSystem.try_cast(battle, boss_actor, player_actor), "D5 boss did not telegraph its Combat V2 action: " + boss_id):
		return false
	var pending: Dictionary = boss_actor.get("v63_pending_cast", {})
	var counter: Dictionary = boss_actor.get("v63_boss_counter_window", {})
	if not _check(not pending.is_empty() and not counter.is_empty(), "boss telegraph lacks a counter window: " + boss_id):
		return false
	var snapshot := MapBattleSnapshotV2.save(battle)
	var resumed := MapBattleSnapshotV2.load(snapshot)
	if not _check(bool(resumed.get("ok", false)), "D5 pending telegraph did not survive Combat V2 snapshot: " + boss_id):
		return false
	var resumed_battle: MapBattleV2 = resumed.battle
	boss_actor = resumed_battle.actors.get(str(boss.id), {})
	player_actor = resumed_battle.actors.get("party_"+boss_id, {})
	if not _check(boss_actor.get("v63_boss_counter_window", {}) == counter, "counter window did not round-trip: " + boss_id):
		return false
	var element := str(counter.get("element", ""))
	var required := int(counter.get("hits_required", 1))
	for _index in range(required):
		resumed_battle._deal_direct(player_actor, boss_actor, 0.01, "v63_skill", false, element, false)
	if not _check(boss_actor.get("v63_pending_cast", {}).is_empty() and boss_actor.get("v63_boss_counter_window", {}).is_empty(),
		"matching elemental counter did not interrupt the telegraphed action: " + boss_id):
		return false
	for event in resumed_battle.events:
		if str(event.get("type", "")) == "boss_counter_break" and str(event.get("boss_id", "")) == boss_id:
			return true
	return _check(false, "counter break event was missing for " + boss_id)

func _reaction_test() -> bool:
	var core := CombatStatsV2.derive(11,1,10,1,0.0)
	var stats: Dictionary = core.stats.duplicate(true)
	stats["max_hp"] = 10000.0
	stats["attack"] = 180.0
	stats["defense"] = 40.0
	var actor := {"id":"reaction_owner","party_id":"reaction","role":"frontline","tier":"disciple","race_id":"nhan_toc",
		"position":Vector2(18,8),"stats":stats,"hp":10000.0,"max_hp":10000.0,"resistances":core.resistances.duplicate(true),
		"basic_range":2.0,"move_speed":1.0,"basic_ratio":1.0,"basic_interval":8.0,"skill_loadout":[],"skill_factors":[],"context_sources":[],"disciple":null}
	var target_result := MonsterCatalogueV2.create_actor("truc_thu",11,1,"d5_reaction_target")
	if not bool(target_result.get("ok",false)):
		return _check(false,"could not create elemental reaction target")
	var target: Dictionary = target_result.duplicate(true)
	target["id"] = "reaction_target"
	target["position"] = Vector2(19,8)
	var battle := MapBattleV2.new(98123)
	if not _check(bool(battle.setup("d5_reaction",[actor],[target]).get("ok",false)),"reaction test actors failed Combat V2 setup"):
		return false
	var live_owner: Dictionary = battle.actors["reaction_owner"]
	var live_target: Dictionary = battle.actors["reaction_target"]
	V63ImmortalSkillCombatSystem.apply_elemental_reaction(battle,live_owner,live_target,"tmb.skill.fist.huyet_quyen.active_01.immortal.a","fire")
	var before := float(live_target.hp)
	V63ImmortalSkillCombatSystem.apply_elemental_reaction(battle,live_owner,live_target,"tmb.skill.poison.duoc_doc.active_03.immortal.a","water")
	var found := false
	for event in battle.events:
		if str(event.get("type", "")) == "elemental_reaction" and str(event.get("name", "")) == "steam_burst":
			found = true
	return _check(found and float(live_target.hp) < before, "fire/water reaction did not deal bounded Combat V2 damage")
