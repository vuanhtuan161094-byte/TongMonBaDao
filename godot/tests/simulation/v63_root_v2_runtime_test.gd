extends SceneTree

var failures := 0
var checks := 0

func _init() -> void:
	call_deferred("_run")

func _check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("V63_ROOT_RUNTIME_FAIL " + message)

func _run() -> void:
	_check(V63FeatureGates.all_disabled(), "all release flags must stay off by default")
	_check(not V63FeatureGates.is_enabled("spiritual_root_v2"), "RootV2 must stay off without explicit preview")
	var no_affinity := V63SpiritualRootEvaluator.evaluate_base_roots({})
	_check(bool(no_affinity.get("ok", false)) and int(no_affinity.get("root_count", -1)) == 0
		and float(no_affinity.get("resonance_multiplier", 0.0)) == 1.0,
		"missing root affinity remains neutral without synthesizing a root")
	_check(not bool(V63SpiritualRootEvaluator.evaluate_base_roots({"metal": 0}).get("ok", true)),
		"zero-purity roots are rejected rather than treated as owned")
	var expected_beats := {"metal": "wood", "wood": "earth", "earth": "water", "water": "fire", "fire": "metal"}
	var ten_tags := ["metal", "wood", "water", "fire", "earth", "lightning", "wind", "ice", "yang", "nether"]
	for root_element in V63SpiritualRootEvaluator.BASE_ELEMENTS:
		for purity_value in [1, 80, 100]:
			var one_root := V63SpiritualRootEvaluator.evaluate_base_roots({root_element: purity_value})
			var expected_resonance := 1.10 if purity_value == 100 else 1.0
			_check(bool(one_root.get("ok", false))
				and absf(float(one_root.get("total_contributions", {}).get("matching_skill_effect", -1.0))
					- float(purity_value) * 0.003 * expected_resonance) < 0.000001,
				"single-root skill effect must follow locked per-purity/resonance formula: " + root_element)
			var one_root_sources := V63SpiritualRootEvaluator.combat_stat_sources({root_element: purity_value}, "edge_" + root_element)
			_check(bool(one_root_sources.get("ok", false)), "registered root channels must derive for each purity: " + root_element)
			for source in one_root_sources.get("sources", []):
				_check(CombatStatsV2.valid_source(source), "root bonus must use a registered CombatStatsV2 channel")
	var five_perfected := V63SpiritualRootEvaluator.evaluate_base_roots({
		"metal": 100, "wood": 100, "water": 100, "fire": 100, "earth": 100})
	_check(bool(five_perfected.get("ok", false)) and int(five_perfected.get("perfected_root_count", 0)) == 5
		and absf(float(five_perfected.get("resonance_multiplier", 0.0)) - 2.0) < 0.000001
		and absf(float(five_perfected.get("total_contributions", {}).get("matching_skill_effect", 0.0)) - 3.0) < 0.000001,
		"five perfected roots use one non-compounding 2.0 resonance multiplier")
	var multi_root := V63SpiritualRootEvaluator.required_multi_element_skill_effect_bonus(
		{"metal": 20, "water": 80, "fire": 60}, ["metal", "water"])
	_check(bool(multi_root.get("ok", false)) and bool(multi_root.get("compatible", false))
		and absf(float(multi_root.get("effective_purity", 0.0)) - 32.0) < 0.000001,
		"multi-root compatibility uses weakest 60% plus mean 40% purity")
	for attacker_element in ten_tags:
		for defender_element in ten_tags:
			var expected_matchup := 1.0
			if expected_beats.get(attacker_element, "") == defender_element:
				expected_matchup = 1.25
			elif expected_beats.get(defender_element, "") == attacker_element:
				expected_matchup = 0.85
			_check(absf(V63SpiritualRootEvaluator.elemental_matchup_factor(attacker_element, defender_element)
				- expected_matchup) < 0.000001,
				"ten-element matchup must preserve only the five authored base-element relations")
	for neutral_element in ["", "neutral", "none"]:
		_check(absf(V63SpiritualRootEvaluator.elemental_matchup_factor("metal", neutral_element) - 1.0) < 0.000001,
			"neutral combat identity must not receive an elemental matchup")
	var candidate := CandidateState.new({"id":"root-runtime-candidate","generated_index":1,
		"profile_seed":889177,"recruitment_source":"ordinary"})
	var envelope := DiscipleBirthProfileV2.create_envelope(candidate)
	var profile := DiscipleBirthRollV2.populate(envelope, candidate)
	_check(not profile.is_empty(), "use the real deterministic birth-profile producer for the test fixture")
	if profile.is_empty():
		_print_summary()
		return
	profile["layers"]["spiritual_root"] = {"initialized":true,
		"birth_values":{"metal":80,"fire":80},"current_values":{"metal":80,"fire":80}}
	profile["layers"]["root_mutation"] = {"initialized":true,"mutation_id":"none"}
	_check(DiscipleBirthProfileV2.valid_complete_birth(profile), "complete V2 profile should accept fixture roots")

	var disciple := DiscipleState.new({"id":"root-runtime-disciple","name":"Root runtime"})
	disciple.v2_birth_profile = profile.duplicate(true)
	disciple.spiritual_root_elements = ["metal","fire"]
	disciple.spiritual_root_purity = 0.8
	var state := SimulationState.new()
	state.sect.disciple_capacity = 32
	state.sect.v63_archive_opt_in = true
	state.sect.v63_learning_opt_in = true
	state.sect.v63_skill_combat_opt_in = true
	state.disciples[disciple.id] = disciple

	var unchanged_before := disciple.to_dict().duplicate(true)
	var current_roots := V63SpiritualRootEvaluator.current_values_for_disciple(disciple)
	_check(bool(current_roots.get("ok",false)) and current_roots.get("root_values",{}) == {"metal":80,"fire":80},
		"combat adapter must read per-root current values from the saved V2 birth profile")
	_check(disciple.to_dict() == unchanged_before, "reading a root profile must not write or migrate disciple state")
	var corrupt := DiscipleState.from_dict(disciple.to_dict())
	corrupt.v2_birth_profile = {"version":999,"invalid":true}
	corrupt.spiritual_root_elements = ["wood"]
	corrupt.spiritual_root_purity = 0.8
	var rejected_profile := V63SpiritualRootEvaluator.current_values_for_disciple(corrupt)
	_check(not bool(rejected_profile.get("ok",true)), "invalid non-empty V2 envelope must fail closed, not use legacy fallback")
	var legacy := DiscipleState.new({"id":"root-runtime-legacy","spiritual_root_elements":["wood"],"spiritual_root_purity":0.8})
	var legacy_before := legacy.to_dict().duplicate(true)
	var legacy_values := V63SpiritualRootEvaluator.current_values_for_disciple(legacy)
	_check(bool(legacy_values.get("ok",false)) and legacy_values.get("source","") == "legacy_global_purity_preview_only"
		and legacy_values.get("root_values",{}) == {"wood":80}, "legacy bridge must read only the stored list and scalar purity")
	_check(legacy.to_dict() == legacy_before, "legacy read bridge must not mutate or reroll historical data")

	var plain_loadout := DiscipleCombatLoadoutV2.build(state,disciple,1,1,1,1,"frontline",Vector2(1,1),"root-test")
	var preview_loadout := DiscipleCombatLoadoutV2.build(state,disciple,1,1,1,1,"frontline",Vector2(1,1),"root-test",
		{"spiritual_root_v2":true})
	_check(bool(plain_loadout.get("ok",false)) and not bool(plain_loadout.get("v63_spiritual_root_enabled",true)),
		"production loadout without explicit RootV2 preview must remain unchanged")
	_check(bool(preview_loadout.get("ok",false)), "explicit RootV2 preview loadout should pass canonical CombatStatsV2 validation: " + str(preview_loadout.get("reason","")))
	if bool(preview_loadout.get("ok",false)):
		_check(bool(preview_loadout.get("v63_spiritual_root_enabled",false)), "explicit preview must attach RootV2 to the combat actor")
		_check(absf(float(preview_loadout.get("resistances",{}).get("fire",0.0))-0.12) < 0.00001,
			"fire root 80 should add the documented candidate 12% fire resistance once")
		_check(absf(float(preview_loadout.get("stats",{}).get("defense_penetration",0.0))-0.08) < 0.00001,
			"metal root 80 should add the documented candidate 8 percentage points penetration once")
		_check(absf(float(preview_loadout.get("v63_root_global_all_damage_bonus",-1.0))-0.08) < 0.00001,
			"fire root global-damage channel must be separate from registered CombatStatsV2 sources")
		var seen_sources: Dictionary = {}
		for source in preview_loadout.get("applied_sources",[]):
			var source_key := str(source.get("source_id","")) + ":" + str(source.get("channel",""))
			_check(CombatStatsV2.valid_source(source), "root derived source must use a registered CombatStatsV2 channel: " + source_key)
			_check(not seen_sources.has(source_key), "no root source may be applied twice: " + source_key)
			seen_sources[source_key] = true
			_check(str(source.get("channel","")) != "all_damage", "global damage must not bypass the canonical stat channel registry")

	var compatible := V63SpiritualRootEvaluator.skill_effect_factor({"fire":80},{"element":"fire"})
	var incompatible := V63SpiritualRootEvaluator.skill_effect_factor({"metal":80},{"element":"fire"})
	var advanced := V63SpiritualRootEvaluator.skill_effect_factor({"metal":80},{"element":"lightning"})
	_check(bool(compatible.get("ok",false)) and absf(float(compatible.get("factor",0.0))-1.24) < 0.00001,
		"matching Fire 80 skill effect should scale its own magnitude by 24%")
	_check(bool(incompatible.get("ok",false)) and absf(float(incompatible.get("factor",0.0))-1.0) < 0.00001,
		"incompatible roots must not boost skill effect")
	_check(bool(advanced.get("ok",false)) and absf(float(advanced.get("factor",0.0))-1.0) < 0.00001,
		"advanced elements must not alias into an unowned base root")

	var skill_defs := V63HumanSkillCombatSystem.skill_definitions()
	var skill_ids: Array = skill_defs.keys()
	skill_ids.sort()
	var matching_active_id := ""
	var matching_passive_id := ""
	var active_definition: Dictionary = {}
	for skill_id_value in skill_ids:
		var skill: Dictionary = skill_defs[str(skill_id_value)]
		if str(skill.get("school","")) == "bow" and str(skill.get("generation","human")) == "human" \
				and str(skill.get("slot","")) == "active" and str(skill.get("element","")) == "metal":
			matching_active_id = str(skill.id)
			break
	if not matching_active_id.is_empty():
		active_definition = skill_defs[matching_active_id]
		for skill_id_value in skill_ids:
			var skill: Dictionary = skill_defs[str(skill_id_value)]
			if str(skill.get("school","")) == "bow" and str(skill.get("generation","human")) == "human" \
					and str(skill.get("branch","")) == str(active_definition.get("branch","")) \
					and str(skill.get("slot","")) == "passive" and str(skill.get("element","")) == "metal" \
					and not Dictionary(skill.get("passive_modifiers",{})).is_empty():
				matching_passive_id = str(skill.id)
				break
		_add_skill_fixture(disciple, matching_active_id)
		_add_skill_fixture(disciple, matching_passive_id)
		disciple.v63_combat_branch_id = StringName(active_definition.get("branch",""))
		var attach := V63HumanSkillCombatSystem.attach_disciple_loadout(state,preview_loadout,
			{"human_skill_combat":true,"spiritual_root_v2":true})
		_check(bool(attach.get("ok",false)), "RootV2 must attach through the explicit V63 combat preview gate")
		var effect_map: Dictionary = preview_loadout.get("skill_factors",{}).get("__v63_root_skill_effect_factors",{})
		var mastery_map: Dictionary = preview_loadout.get("skill_factors",{}).get("__v63_root_skill_mastery_factors",{})
		_check(absf(float(effect_map.get(matching_active_id,0.0))-1.24) < 0.00001,
			"actual V63 loadout attachment should record matching metal skill effect once")
		_check(absf(float(mastery_map.get(matching_active_id,0.0))-1.12) < 0.00001,
			"actual V63 loadout attachment should record matching mastery at half effect coefficient")
		preview_loadout["linked_disciple"] = disciple
		var cast_target := {"id":"root-runtime-target","position":Vector2(2,1)}
		var cast := V63HumanSkillCombatSystem._cast_record(preview_loadout,cast_target,matching_active_id,
			active_definition,1.0)
		_check(absf(float(cast.get("ratio",0.0))-float(active_definition.get("damage_ratio",0.0))*1.24) < 0.00001,
			"matching root bonus must be snapshotted into actual V63 cast ratio")
		var expected_power := float(active_definition.get("power",0.0))
		if str(active_definition.get("effect","")) in ["poison","heal","guard","mark"]:
			expected_power *= 1.24
		_check(absf(float(cast.get("power",0.0))-expected_power) < 0.00001,
			"only authored scalable skill power should receive the root factor")
		_check(absf(float(cast.get("duration",0.0))-float(active_definition.get("duration",0.0))) < 0.00001,
			"RootV2 must not scale status duration")
		var xp_before := float(disciple.v63_learned_skill_nodes[matching_active_id].get("mastery_xp",0.0))
		_check(V63HumanSkillCombatSystem.record_cast_mastery(preview_loadout,matching_active_id,"root-v2-cast-1"),
			"committed cast should update matching mastery")
		var xp_after := float(disciple.v63_learned_skill_nodes[matching_active_id].get("mastery_xp",0.0))
		_check(absf(xp_after-xp_before-1.12) < 0.00001,
			"one matching root cast should add +12% candidate mastery XP")
		_check(not V63HumanSkillCombatSystem.record_cast_mastery(preview_loadout,matching_active_id,"root-v2-cast-1")
			and absf(float(disciple.v63_learned_skill_nodes[matching_active_id].get("mastery_xp",0.0))-xp_after) < 0.00001,
			"mastery must retain the existing exactly-once receipt")
		if not matching_passive_id.is_empty():
			var passive_before: Dictionary = skill_defs[matching_passive_id].get("passive_modifiers",{})
			var passive_after := V63HumanSkillCombatSystem._root_scaled_passive_modifiers(preview_loadout,matching_passive_id)
			for field in ["outgoing_factor","poison_factor","heal_factor"]:
				if passive_before.has(field):
					_check(absf(float(passive_after.get(field,0.0))-float(passive_before[field])*1.24) < 0.00001,
						"matching root should scale only authored effect magnitude: " + str(field))
			for field in ["crit_bonus","attack_speed_factor","cast_speed_factor",
					"cooldown_recovery_factor","lifesteal"]:
				if passive_before.has(field):
					_check(absf(float(passive_after.get(field,0.0))-float(passive_before[field])) < 0.00001,
						"root must not automatically scale passive haste, cooldown, crit or lifesteal: " + str(field))
			if passive_before.has("guard_factor"):
				var expected_guard := clampf(1.0-(1.0-float(passive_before.guard_factor))*1.24,0.5,1.0)
				_check(absf(float(passive_after.get("guard_factor",1.0))-expected_guard) < 0.00001,
					"guard root scaling must affect reduction strength, not duration")
	else:
		_check(false, "source catalog must expose an authored metal active for the real V63 loadout bridge")

	var serialized := disciple.to_dict()
	var cold_disciple := DiscipleState.from_dict(serialized)
	var cold_roots := V63SpiritualRootEvaluator.current_values_for_disciple(cold_disciple)
	_check(bool(cold_roots.get("ok",false)) and cold_roots.get("root_values",{}) == current_roots.get("root_values",{}),
		"cold DiscipleState reconstruction must preserve exact V2 roots")
	var cold_sources := V63SpiritualRootEvaluator.combat_stat_sources(cold_roots.get("root_values",{}),str(cold_disciple.id))
	var warm_sources := V63SpiritualRootEvaluator.combat_stat_sources(current_roots.get("root_values",{}),str(disciple.id))
	_check(cold_sources.get("sources",[]) == warm_sources.get("sources",[]),
		"cold reload must derive identical source IDs and values without SaveService writes")
	if bool(preview_loadout.get("ok",false)) and not matching_active_id.is_empty():
		var battle := MapBattleV2.new(707701)
		var target_stats := {"max_hp":100000.0,"attack":1.0,"defense":10.0,"crit_chance":0.0,
			"crit_damage":1.5,"crit_resistance":0.0,"defense_penetration":0.0,"effect_hit":0.0,
			"effect_resistance":0.0,"damage_reduction":0.0,"lifesteal":0.0,"lifesteal_reduction":0.0}
		var target_row := {"id":"root-runtime-wood-target","tier":"normal","race_id":"yeu_thu",
			"primary_element":"wood","position":Vector2(2,1),"stats":target_stats,"hp":100000.0,
			"resistances":{},"species_id":"root-runtime-test-species"}
		var battle_setup := battle.setup("root-v2-matchup-preview",[preview_loadout],[target_row])
		_check(bool(battle_setup.get("ok",false)), "preview RootV2 actors should enter canonical MapBattleV2: " + str(battle_setup.get("reason","")))
		if bool(battle_setup.get("ok",false)):
			var attacker: Dictionary = battle.actors[str(disciple.id)]
			var target: Dictionary = battle.actors["root-runtime-wood-target"]
			_check(str(target.get("primary_element","")) == "wood", "MapBattle must carry the explicit target element")
			var battle_snapshot := MapBattleSnapshotV2.save(battle)
			_check(bool(battle_snapshot.get("ok", false)), "RootV2 preview battle must serialize through the existing snapshot")
			if bool(battle_snapshot.get("ok", false)):
				var cold_battle_result := MapBattleSnapshotV2.load(battle_snapshot)
				_check(bool(cold_battle_result.get("ok", false)), "RootV2 preview battle snapshot must cold-load")
				if bool(cold_battle_result.get("ok", false)):
					var cold_battle: MapBattleV2 = cold_battle_result.get("battle")
					var cold_attacker: Dictionary = cold_battle.actors[str(disciple.id)]
					_check(bool(cold_attacker.get("v63_spiritual_root_enabled", false))
						and cold_attacker.get("skill_factors", {}).get("__v63_root_skill_effect_factors", {})
							== attacker.get("skill_factors", {}).get("__v63_root_skill_effect_factors", {}),
						"RootV2 gate and derived skill factors must survive the existing battle snapshot exactly")
			var skill_factor := V63SpiritualRootEvaluator.attached_skill_effect_factor(attacker,matching_active_id)
			var attacker_stats := V63HumanSkillCombatSystem.effective_attack_stats(attacker,attacker.stats)
			var defender_stats := V63HumanSkillCombatSystem.effective_defense_stats(target,target.stats)
			var expected_hit := CombatStatsV2.resolve_direct_hit(attacker_stats,defender_stats,target.resistances,
				float(active_definition.get("damage_ratio",0.0))*skill_factor*1.08,false,"metal",1.25,false)
			var actual_damage := battle._deal_direct(attacker,target,
				float(active_definition.get("damage_ratio",0.0))*skill_factor,"v63_skill",false,"metal",false)
			_check(bool(expected_hit.get("ok",false)) and absf(actual_damage-float(expected_hit.get("damage",0.0))) < 0.001,
				"MapBattle must apply the gated fire global bonus and metal-over-wood matchup once")

	# Guard against silently turning elemental affinity into a second
	# cooldown, cast speed, attack speed or crit talent multiplier.
	for case in [
		["tmb.skill.bow.liep_anh.passive_02.human","crit_bonus"],
		["tmb.skill.bow.liep_anh.passive_03.human","attack_speed_factor"],
		["tmb.skill.bow.liep_anh.passive_04.human","cooldown_recovery_factor"],
		["tmb.skill.bow.linh_tien.passive_04.human","cast_speed_factor"]
	]:
		var passive_id := str(case[0])
		var channel := str(case[1])
		var source_mods: Dictionary = V63HumanSkillCombatSystem.skill_definition(passive_id).get("passive_modifiers",{})
		var source_magnitude := float(source_mods.get(channel,0.0))
		_check(source_magnitude > 0.0, "real source passive must exercise nonzero: " + channel)
		var applied_factors: Dictionary = {}
		applied_factors[passive_id] = 1.24
		var preview_actor := {"skill_factors":{"__v63_root_skill_effect_factors":applied_factors}}
		_check(is_equal_approx(V63SpiritualRootEvaluator.attached_skill_effect_factor(preview_actor,passive_id),1.24),
			"test must apply a real non-neutral root factor to the passive")
		var after_mods := V63HumanSkillCombatSystem._root_scaled_passive_modifiers(preview_actor,passive_id)
		_check(absf(float(after_mods.get(channel,0.0))-source_magnitude) < 0.000001,
			"root cannot multiply a nonzero passive haste/cooldown/crit channel: " + channel)

	_check(V63FeatureGates.all_disabled(), "tests must not switch the release defaults")
	_print_summary()

func _print_summary() -> void:
	print("V63_ROOT_RUNTIME_SUMMARY " + JSON.stringify({"checks":checks,"failures":failures,
		"status":"PASS_PREVIEW_ONLY" if failures == 0 else "FAIL",
		"scope":"V2 profile adapter, legacy read-only bridge, derived CombatStatsV2 sources, default-off gate, deterministic cold DiscipleState reconstruction; no SaveService or player save access"}))
	quit(1 if failures > 0 else 0)

func _add_skill_fixture(disciple: DiscipleState, skill_id: String) -> void:
	if skill_id.is_empty():
		return
	disciple.v63_learned_skill_nodes[skill_id] = {"source_codex_id":"fixture","learned_tick":0,
		"mastery_xp":0.0,"level":1,"mastery_cast_receipts":{}}
	disciple.v63_equipped_skill_ids.append(skill_id)
