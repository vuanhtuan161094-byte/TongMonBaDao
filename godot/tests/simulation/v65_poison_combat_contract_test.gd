extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _check(value: bool, message: String) -> bool:
	if not value:
		push_error("V65_POISON_FAIL: " + message)
		quit(1)
	return value

func _run() -> void:
	if not _catalogue_coverage() or not _healer_targeting() or not _real_poison_cast() or not _owned_poison_snapshot() or not _marked_punish():
		return
	if not _poison_kill_and_respawn():
		return
	print("V65_POISON_PASS: 183 records routed; heal target gating; owner consume; 30-stack snapshot/tick idempotence; marked punish; DoT kill attribution and generation-safe respawn")
	quit(0)

func _catalogue_coverage() -> bool:
	var counts := {"human":0,"immortal":0,"divine":0}
	var pending_rule_counts := {"single_spread_poison":0,"removed_debuff_counter":0}
	var files := {
		"human":"res://data/combat/v63_human_combat_catalog.json",
		"immortal":"res://data/combat/v63_immortal_combat_catalog.json",
		"divine":"res://data/combat/v63_divine_combat_catalog.json"
	}
	for generation in files:
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(str(files[generation])))
		if not _check(parsed is Dictionary and parsed.get("skills", null) is Array, "invalid catalogue: " + str(generation)):
			return false
		for raw in parsed.skills:
			var skill: Dictionary = raw
			if not str(skill.get("id", "")).begins_with("tmb.skill.poison."):
				continue
			counts[generation] = int(counts[generation]) + 1
			if not _check(V63HumanSkillCombatSystem.skill_definition(str(skill.id)).size() > 0, "unresolved skill id: " + str(skill.id)):
				return false
			var effects: Array = V63HumanSkillCombatSystem.EFFECTS
			if not _check(effects.has(str(skill.get("effect", ""))), "effect has no Combat V2 handler: " + str(skill.id)):
				return false
			var rule := str(skill.get("divine_rule", ""))
			if generation == "divine" and pending_rule_counts.has(rule):
				if not _check(str(skill.get("divine_rule_status", "")) == "CODE_CANDIDATE_QA_PENDING", "underdetailed Divine rule is not gated as a code candidate pending QA: " + str(skill.id)):
					return false
				pending_rule_counts[rule] = int(pending_rule_counts[rule]) + 1
	return _check(counts == {"human":35,"immortal":68,"divine":80} and pending_rule_counts == {"single_spread_poison":13,"removed_debuff_counter":13},
		"poison record or CODE_CANDIDATE_QA_PENDING rule count mismatch: %s / %s" % [str(counts), str(pending_rule_counts)])

func _healer_targeting() -> bool:
	var party := [_actor("healer", Vector2(18,8)), _actor("wounded", Vector2(19,8))]
	var enemy := _monster("heal_target", Vector2(20,8), 10000.0, false)
	var battle := MapBattleV2.new(65001)
	if not _check(bool(battle.setup("heal_ai", party, [enemy]).get("ok", false)), "heal AI battle setup"):
		return false
	var healer: Dictionary = battle.actors.healer
	var wounded: Dictionary = battle.actors.wounded
	var skill := V63HumanSkillCombatSystem.skill_definition("tmb.skill.poison.duoc_doc.active_02.human")
	wounded["v63_combat_enabled"] = true
	wounded["hp"] = 2500.0
	if not _check(V63HumanSkillCombatSystem._support_target(battle, healer, skill).is_empty(), "poison healer selected missing HP without a real damage receipt"):
		return false
	var enemy_actor: Dictionary = battle.actors.heal_target
	var actual_damage := battle._deal_direct(enemy_actor, wounded, 1.0, "basic", false)
	if not _check(actual_damage > 0.0 and V63PoisonEvolutionV1.heal_capacity(wounded, battle.now) > 0.0, "real combat damage did not create bounded poison-heal budget"):
		return false
	if not _check(str(skill.get("effect", "")) == "heal" and str(V63HumanSkillCombatSystem._support_target(battle, healer, skill).get("id", "")) == "wounded", "AI did not select an injured ally"):
		return false
	wounded["hp"] = float(wounded.max_hp)
	if not _check(V63HumanSkillCombatSystem._support_target(battle, healer, skill).is_empty(), "AI selected an ally at full HP"):
		return false
	wounded["hp"] = 2500.0
	wounded["v63_blood_mode"] = "blood_covenant"
	if not _check(V63HumanSkillCombatSystem._support_target(battle, healer, skill).is_empty(), "AI selected an unhealable Blood Covenant target"):
		return false
	wounded["v63_blood_mode"] = "blood_ma"
	wounded["v63_base_max_hp"] = float(wounded.max_hp)
	wounded["hp"] = 3000.0
	return _check(str(V63HumanSkillCombatSystem._support_target(battle, healer, skill).get("id", "")) == "wounded", "Blood Ma low-HP ally was incorrectly excluded")

func _real_poison_cast() -> bool:
	var caster_row := _actor("needle_owner", Vector2(18,8))
	var target_row := _monster("needle_target", Vector2(19,8), 100000.0, false)
	var battle := MapBattleV2.new(65006)
	if not _check(bool(battle.setup("needle_cast", [caster_row], [target_row]).get("ok", false)), "poison cast setup"):
		return false
	var caster: Dictionary = battle.actors.needle_owner
	var target: Dictionary = battle.actors.needle_target
	var skill_id := "tmb.skill.poison.doc_cham.active_02.human"
	caster["v63_skill_loadout"] = [skill_id]
	var skill := V63HumanSkillCombatSystem.skill_definition(skill_id)
	var hp_before := float(target.hp)
	V63HumanSkillCombatSystem.release_cast(battle, _cast(skill, caster, target), caster)
	var stacks: Array = target.get("status_effects", {}).get("v63_poison", [])
	if not _check(float(target.hp) < hp_before and stacks.size() == 1, "Độc Châm cast failed to damage and poison a normal monster"):
		return false
	return _check(str(stacks[0].get("owner_id", "")) == "needle_owner" and str(stacks[0].get("source_skill_id", "")) == skill_id and
		int(stacks[0].get("stack_ordinal", 0)) == 1 and is_equal_approx(float(stacks[0].get("next_tick", -1.0)), 1.0),
		"real cast lost poison source/timer attribution")

func _owned_poison_snapshot() -> bool:
	var party: Array = []
	for index in range(6):
		party.append(_actor("owner_" + str(index), Vector2(18, 5 + index)))
	var target_row := _monster("poison_boss", Vector2(22,8), 10000000.0, true)
	var battle := MapBattleV2.new(65002)
	if not _check(bool(battle.setup("poison_snapshot", party, [target_row]).get("ok", false)), "poison battle setup"):
		return false
	var target: Dictionary = battle.actors.poison_boss
	var skill_id := "tmb.skill.poison.co_doc.active_02.divine.b"
	for index in range(6):
		var owner: Dictionary = battle.actors["owner_" + str(index)]
		owner["v63_skill_loadout"] = [skill_id]
		V63HumanSkillCombatSystem._apply_poison(battle, owner, target, skill_id, 0.2, 10.0, 9, "nether")
	var stacks: Array = target.status_effects.v63_poison
	if not _check(stacks.size() == 30, "six-owner boss stack cap is not 30"):
		return false
	var saved_owner := str(stacks[0].owner_id)
	var saved_source := str(stacks[0].source_skill_id)
	var saved_ordinal := int(stacks[0].stack_ordinal)
	var saved_next_tick := float(stacks[0].next_tick)
	var saved_expiry := float(stacks[0].expires_at)
	battle.now = 0.75
	var loaded := MapBattleSnapshotV2.load(MapBattleSnapshotV2.save(battle))
	if not _check(bool(loaded.get("ok", false)), "poison snapshot restore failed: " + str(loaded)):
		return false
	battle = loaded.battle
	target = battle.actors.poison_boss
	stacks = target.status_effects.v63_poison
	if not _check(str(stacks[0].owner_id) == saved_owner and str(stacks[0].source_skill_id) == saved_source and int(stacks[0].stack_ordinal) == saved_ordinal and
		is_equal_approx(float(stacks[0].next_tick), saved_next_tick) and is_equal_approx(float(stacks[0].expires_at), saved_expiry),
		"snapshot lost poison owner, source, or timers"):
		return false
	for step in range(1, 14):
		battle.now = 0.75 + float(step) * 0.25
		V63HumanSkillCombatSystem.process_status_effects(battle)
		var expected_ticks := int(floor(battle.now)) * 30
		if not _check(_event_count(battle, "status_tick") == expected_ticks, "poison tick cadence mismatch at %.2fs" % battle.now):
			return false
		for event in battle.events:
			if str(event.get("type", "")) == "status_tick":
				if not _check(is_equal_approx(float(event.get("diminishing_factor", 0.0)), 0.65), "boss diminishing factor is not 19.5/30"):
					return false
	V63HumanSkillCombatSystem.process_status_effects(battle)
	if not _check(_event_count(battle, "status_tick") == 120, "same-time status processing duplicated poison ticks"):
		return false
	var poison_hits := 0
	for event in battle.events:
		if str(event.get("type", "")) == "hit" and str(event.get("kind", "")) == "v63_poison":
			poison_hits += 1
			if not _check(not bool(event.get("critical", false)) and float(event.get("lifesteal", 0.0)) == 0.0, "poison tick crit/lifesteal is forbidden"):
				return false
	if not _check(poison_hits == 120 and float(target.hp) < 10000000.0, "poison failed to deal real direct HP damage"):
		return false
	var consumer_id := "tmb.skill.poison.co_doc.active_04.divine.b"
	var consumer: Dictionary = V63HumanSkillCombatSystem.skill_definition(consumer_id)
	if not _check(str(consumer.get("effect", "")) == "consume_poison", "consumer fixture does not name a consume_poison skill"):
		return false
	var consuming_owner: Dictionary = battle.actors.owner_0
	var loadout: Array = consuming_owner.get("v63_skill_loadout", []).duplicate()
	loadout.append(consumer_id)
	consuming_owner["v63_skill_loadout"] = loadout
	var cast := _cast(consumer, battle.actors.owner_0, target)
	V63HumanSkillCombatSystem.release_cast(battle, cast, battle.actors.owner_0)
	var retained: Array = target.get("status_effects", {}).get("v63_poison", [])
	var owner_count := 0
	for stack in retained:
		if str(stack.get("owner_id", "")) == "owner_0":
			owner_count += 1
	if not _check(owner_count == 0 and retained.size() == 25, "consume removed another caster's poison or left owned stacks"):
		return false
	return _poison_resistance()

func _poison_resistance() -> bool:
	var damages: Array[float] = []
	for resisted in [false, true]:
		var caster_row := _actor("resist_owner", Vector2(18,8))
		var target_row := _monster("resist_target", Vector2(19,8), 10000.0, true)
		if resisted:
			target_row["resistances"]["nether"] = 0.5
		var battle := MapBattleV2.new(65005)
		if not _check(bool(battle.setup("poison_resistance_" + str(resisted), [caster_row], [target_row]).get("ok", false)), "resistance setup"):
			return false
		var caster: Dictionary = battle.actors.resist_owner
		var target: Dictionary = battle.actors.resist_target
		var skill_id := "tmb.skill.poison.doc_cham.active_02.human"
		V63HumanSkillCombatSystem._apply_poison(battle, caster, target, skill_id, 0.2, 3.0, 1, "nether")
		battle.now = 1.0
		V63HumanSkillCombatSystem.process_status_effects(battle)
		for event in battle.events:
			if str(event.get("type", "")) == "status_tick":
				damages.append(float(event.get("damage", 0.0)))
				break
	if not _check(damages.size() == 2 and damages[0] > damages[1] and damages[1] > 0.0,
		"boss Nether resistance did not reduce real poison HP damage: " + str(damages)):
		return false
	return true

func _marked_punish() -> bool:
	var caster_row := _actor("mark_owner", Vector2(18,8))
	caster_row["v63_combat_enabled"] = true
	caster_row["v63_combat_generation"] = "divine"
	caster_row["v63_combat_branch_id"] = "co_doc"
	caster_row["v63_combat_lineage"] = "b"
	var target_row := _monster("mark_target", Vector2(19,8), 100000.0, false)
	var mark_id := "tmb.skill.poison.co_doc.active_01.divine.b"
	var punish_id := "tmb.skill.poison.co_doc.active_02.divine.b"
	caster_row["v63_skill_loadout"] = [mark_id, punish_id]
	var battle := MapBattleV2.new(65003)
	if not _check(bool(battle.setup("marked_punish", [caster_row], [target_row]).get("ok", false)), "marked punish setup"):
		return false
	var caster: Dictionary = battle.actors.mark_owner
	var target: Dictionary = battle.actors.mark_target
	if not _check(V63PoisonEvolutionV1.rule_for_actor(caster) == "marked_target_punish", "V63 actor lineage did not resolve the mark rule"):
		return false
	var mark_skill := V63HumanSkillCombatSystem.skill_definition(mark_id)
	V63HumanSkillCombatSystem.release_cast(battle, _cast(mark_skill, caster, target), caster)
	if not _check(not target.get("v63_marks", {}).get(str(caster.id), {}).is_empty(), "real mark cast did not apply owner mark"):
		return false
	var punish_skill := V63HumanSkillCombatSystem.skill_definition(punish_id)
	V63HumanSkillCombatSystem.release_cast(battle, _cast(punish_skill, caster, target), caster)
	var punish_events := 0
	var actual_bonus_damage := 0.0
	for event in battle.events:
		if str(event.get("type", "")) == "poison_mark_punish":
			punish_events += 1
			actual_bonus_damage += float(event.get("actual_damage", 0.0))
	if not _check(target.get("v63_marks", {}).is_empty() and _event_count(battle, "mark_consumed") == 1 and
		punish_events == 1 and actual_bonus_damage > 0.0, "real Phệ Cổ hit did not consume its own mark and settle one bonus hit"):
		return false
	V63HumanSkillCombatSystem.release_cast(battle, _cast(punish_skill, caster, target), caster)
	return _check(_event_count(battle, "poison_mark_punish") == 1, "mark ICD allowed a duplicate punish proc")

func _poison_kill_and_respawn() -> bool:
	var caster_row := _actor("dot_owner", Vector2(18,8))
	var monster_row := _monster("dot_victim", Vector2(19,8), 100.0, false)
	monster_row["hp"] = 1.0
	monster_row["spawn_slot_id"] = "poison_slot"
	monster_row["slot_generation"] = 1
	var battle := MapBattleV2.new(65004)
	if not _check(bool(battle.setup("poison_kill", [caster_row], [monster_row], true).get("ok", false)), "DoT kill battle setup"):
		return false
	var caster: Dictionary = battle.actors.dot_owner
	var target: Dictionary = battle.actors.dot_victim
	var skill_id := "tmb.skill.poison.doc_cham.active_02.human"
	caster["v63_skill_loadout"] = [skill_id]
	V63HumanSkillCombatSystem._apply_poison(battle, caster, target, skill_id, 0.2, 5.0, 1, "nether")
	battle.now = 1.0
	V63HumanSkillCombatSystem.process_status_effects(battle)
	var kills := battle.pending_kill_events()
	if not _check(float(target.hp) == 0.0 and kills.size() == 1, "DoT failed to kill or produced duplicate kill journal entries"):
		return false
	if not _check(str(kills[0].get("damage_kind", "")) == "v63_poison" and str(kills[0].get("killer_actor_id", "")) == "dot_owner" and
		str(kills[0].get("source_skill_id", "")) == skill_id and str(kills[0].get("source_skill_generation_id", "")) == skill_id and
		int(kills[0].get("poison_stack_ordinal", 0)) == 1, "DoT kill receipt lost exact owner/skill/stack attribution"):
		return false
	if not _check(_event_count(battle, "downed") == 1, "DoT kill did not emit exactly one downed event"):
		return false
	var restored := MapBattleSnapshotV2.load(MapBattleSnapshotV2.save(battle))
	if not _check(bool(restored.get("ok", false)), "post-kill snapshot restore failed: " + str(restored)):
		return false
	battle = restored.battle
	V63HumanSkillCombatSystem.process_status_effects(battle)
	if not _check(battle.pending_kill_events().size() == 1 and _event_count(battle, "downed") == 1,
		"save/reload replay duplicated a DoT kill or downed event"):
		return false
	if not _check(battle.remove_downed_monster("dot_victim"), "could not remove dead poison target"):
		return false
	var respawn := _monster("dot_victim_g2", Vector2(20,8), 100.0, false)
	respawn["spawn_slot_id"] = "poison_slot"
	respawn["slot_generation"] = 2
	var added := battle.add_continuous_monster(respawn)
	if not _check(bool(added.get("ok", false)), "next monster generation did not spawn"):
		return false
	return _check(not battle.actors.dot_victim_g2.get("status_effects", {}).has("v63_poison"), "respawn inherited poison from previous generation")

func _actor(id: String, position: Vector2) -> Dictionary:
	var core := CombatStatsV2.derive(11, 1, 10, 1, 0.0)
	var stats: Dictionary = core.stats.duplicate(true)
	stats["max_hp"] = 10000.0
	stats["attack"] = 100.0
	stats["defense"] = 40.0
	stats["crit_chance"] = 0.0
	return {"id":id,"party_id":"poison_test","role":"frontline","tier":"disciple","race_id":"nhan_toc",
		"position":position,"stats":stats,"hp":10000.0,"max_hp":10000.0,"resistances":core.resistances,
		"basic_range":2.0,"move_speed":1.0,"basic_ratio":0.1,"basic_interval":1000.0,"skill_loadout":[],
		"skill_factors":{},"context_sources":[],"disciple":null}

func _monster(id: String, position: Vector2, hp: float, boss: bool) -> Dictionary:
	var row := MonsterCatalogueV2.create_actor("truc_thu", 11, 1, id)
	row["id"] = id
	row["position"] = position
	row["tier"] = "boss" if boss else "normal"
	row["stats"]["max_hp"] = hp
	row["stats"]["attack"] = 100.0
	row["stats"]["defense"] = 0.0
	row["hp"] = hp
	return row

func _cast(skill: Dictionary, caster: Dictionary, target: Dictionary) -> Dictionary:
	var cast := {"caster":str(caster.id),"target_id":str(target.id),"v63_skill_id":str(skill.id),"ready":1.0,
		"ratio":float(skill.get("damage_ratio", 0.0)),"element":str(skill.get("element", "nether")),"effect":str(skill.effect),
		"shape":str(skill.get("shape", "single")),"power":float(skill.get("power", 0.0)),"duration":float(skill.get("duration", 0.0)),
		"poison_stacks":int(skill.get("poison_stacks", 1)),"radius":float(skill.get("radius", 0.0)),
		"maximum":mini(3, maxi(1, int(skill.get("target_limit", 1))))}
	if str(cast.shape) == "circle":
		cast["center"] = target.get("position", Vector2.ZERO)
	return cast

func _event_count(battle: MapBattleV2, event_type: String) -> int:
	var count := 0
	for event in battle.events:
		if str(event.get("type", "")) == event_type:
			count += 1
	return count
