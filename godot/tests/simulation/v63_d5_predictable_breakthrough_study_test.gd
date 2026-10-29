extends SceneTree

const PREVIEW := {"sect_codex":true,"technique_learning":true,"human_skill_combat":true}

func _init() -> void:
	call_deferred("_run")

func _fail(message: String) -> void:
	push_error("V63_D5_BREAKTHROUGH_FAIL: " + message)
	quit(1)

func _check(value: bool, message: String) -> bool:
	if not value:
		_fail(message)
		return false
	return true

func _run() -> void:
	var loaded := V63LearningSystem.load_catalogue()
	if not _check(bool(loaded.get("ok", false)), "learning catalog invalid: " + str(loaded.get("errors", []))):
		return
	var catalog: Dictionary = loaded.data
	var target: Dictionary = {}
	for row in catalog.techniques:
		if str(row.get("id", "")) == "tmb.technique.bow.liep_anh.immortal.a":
			target = row
			break
	if not _check(not target.is_empty(), "Immortal Truy Hồn breakthrough study missing"):
		return
	var state := SimulationState.new()
	state.sect.disciple_capacity = 8
	state.p3_7_buildings_enabled = true
	state.sect.p3_7_resources_enabled = true
	state.sect.v63_archive_opt_in = true
	state.sect.v63_learning_opt_in = true
	state.sect.v63_skill_combat_opt_in = true
	var disciple := DiscipleState.new({"id":"d5_breakthrough","name":"D5 Breakthrough"})
	disciple.contribution_points = 9000
	disciple.spirit_stones = 600000
	disciple.current_action = &"HOLD"
	state.disciples[disciple.id] = disciple
	if not _archive_manual(state, str(target.source_codex_id)):
		return
	var branch_technique := "tmb.technique.bow.liep_anh.human.base"
	var common_technique := "tmb.technique.bow.common.human.base"
	disciple.known_techniques[common_technique] = {"mastery_xp":0.0,"mastery_stage":1,"learned_tick":0}
	disciple.known_techniques[branch_technique] = {"mastery_xp":400.0,"mastery_stage":2,"learned_tick":0}
	disciple.active_technique_main = StringName(branch_technique)
	if not _archive_and_learn_human_skill(state, disciple, "tmb.skill.bow.liep_anh.active_01.human"):
		return
	if not _archive_and_learn_human_skill(state, disciple, "tmb.skill.bow.liep_anh.ultimate.human"):
		return
	var learning := V63LearningSystem.new()
	var gated := learning.can_start_study(state, disciple, StringName(target.id), PREVIEW)
	if not _check(str(gated.get("reason", "")) == "immortal_realm_profile_required", "study accepted a disciple with no realm profile: " + str(gated)):
		return
	disciple.v2_realm_progress = _realm_profile(10, 10)
	gated = learning.can_start_study(state, disciple, StringName(target.id), PREVIEW)
	if not _check(str(gated.get("reason", "")) == "immortal_realm_or_body_11_required", "study ignored realm/body gate: " + str(gated)):
		return
	disciple.v2_realm_progress = _realm_profile(11, 10)
	gated = learning.can_start_study(state, disciple, StringName(target.id), PREVIEW)
	if not _check(str(gated.get("reason", "")) == "immortal_main_technique_mastery_stage_3_required", "study ignored compatible main mastery: " + str(gated)):
		return
	disciple.known_techniques[branch_technique]["mastery_stage"] = 3
	disciple.v63_learned_skill_nodes["tmb.skill.bow.liep_anh.active_01.human"]["level"] = 6
	gated = learning.can_start_study(state, disciple, StringName(target.id), PREVIEW)
	if not _check(str(gated.get("reason", "")) == "human_branch_active_level_7_required", "study ignored Human active level 7 gate: " + str(gated)):
		return
	disciple.v63_learned_skill_nodes["tmb.skill.bow.liep_anh.active_01.human"]["level"] = 7
	disciple.v63_learned_skill_nodes["tmb.skill.bow.liep_anh.ultimate.human"]["level"] = 3
	gated = learning.can_start_study(state, disciple, StringName(target.id), PREVIEW)
	if not _check(str(gated.get("reason", "")) == "human_branch_ultimate_level_4_required", "study ignored Human ultimate level 4 gate: " + str(gated)):
		return
	disciple.v63_learned_skill_nodes["tmb.skill.bow.liep_anh.ultimate.human"]["level"] = 4
	gated = learning.can_start_study(state, disciple, StringName(target.id), PREVIEW)
	if not _check(bool(gated.get("ok", false)), "all deterministic breakthrough gates should now pass: " + str(gated)):
		return
	var contribution_before := disciple.contribution_points
	var stones_before := disciple.spirit_stones
	var started := learning.start_study(state, disciple, StringName(target.id), "d5:study:lineage", PREVIEW)
	if not _check(bool(started.get("ok", false)) and str(disciple.active_job_id) == str(started.job.job_id), "D5 did not reserve the D3 single active job slot"):
		return
	if not _check(disciple.contribution_points == contribution_before - int(target.cost.contribution)
		and disciple.spirit_stones == stones_before - int(target.cost.spirit_stones), "D5 candidate study costs were not atomically reserved"):
		return
	var retried := learning.start_study(state, disciple, StringName(target.id), "d5:study:lineage", PREVIEW)
	if not _check(bool(retried.get("duplicate", false)) and disciple.contribution_points == contribution_before - int(target.cost.contribution)
		and disciple.spirit_stones == stones_before - int(target.cost.spirit_stones), "repeated D5 request charged twice"):
		return
	var scheduler := SimulationScheduler.new(state)
	scheduler.v63_preview_overrides = PREVIEW.duplicate(true)
	scheduler.run_ticks(int(target.study_ticks))
	var completion_id := "study:complete:" + str(started.job.job_id)
	if not _check(disciple.known_techniques.has(str(target.id)) and disciple.v63_study_job.is_empty()
		and disciple.active_job_id == &"" and state.sect.v63_learning_operation_receipts.has(completion_id),
		"D5 study did not finish through D3 with one durable completion receipt"):
		return
	var charges := {"contribution":disciple.contribution_points,"stones":disciple.spirit_stones}
	if not _check(learning.process_tick(state, PREVIEW) == 0 and charges.contribution == disciple.contribution_points
		and charges.stones == disciple.spirit_stones, "D5 completion retry repeated cost or knowledge effects"):
		return
	var loaded_state := SimulationState.from_dict(state.to_dict())
	var loaded_disciple: DiscipleState = loaded_state.disciples[disciple.id]
	if not _check(loaded_disciple.known_techniques.has(str(target.id))
		and loaded_state.sect.v63_learning_operation_receipts.has(completion_id)
		and loaded_disciple.v63_study_job.is_empty(), "D5 lineage knowledge or exactly-once receipt did not round-trip"):
		return
	if not _check(V63LearningSystem.lineage_study_complete(loaded_disciple, "liep_anh", "a"), "completed D5 study did not unlock its A-lineage combat nodes"):
		return
	print("V63_D5_PREDICTABLE_BREAKTHROUGH_PASS: realm/body, compatible main mastery, Human skill L7/ultimate L4, archive source, candidate costs, One Active Job, exactly-once completion and save/load")
	quit(0)

func _archive_manual(state: SimulationState, codex_id: String) -> bool:
	var codex := V63SectArchiveSystem.codex_definition(codex_id)
	if not _check(not codex.is_empty(), "D5 study source manual missing: " + codex_id):
		return false
	var warehouse := WarehouseSystem.new()
	var item_id := StringName(str(codex.get("manual_item_id", "")))
	if not _check(warehouse.registry.has(item_id) and warehouse.add(state, item_id, 1), "Warehouse rejected D5 source manual: " + str(item_id)):
		return false
	var result := V63SectArchiveSystem.archive_manual(state, codex_id, PREVIEW)
	return _check(bool(result.get("ok", false)), "could not archive D5 manual: " + str(result))

func _archive_and_learn_human_skill(state: SimulationState, disciple: DiscipleState, skill_id: String) -> bool:
	var skill := V63HumanSkillCombatSystem.skill_definition(skill_id)
	if not _check(not skill.is_empty(), "Human prerequisite skill missing: " + skill_id):
		return false
	if not _archive_manual(state, str(skill.source_codex_id)):
		return false
	var learned := V63HumanSkillCombatSystem.learn_skill(state, disciple, skill_id, PREVIEW)
	if not _check(bool(learned.get("ok", false)), "Human prerequisite skill could not be learned: " + str(learned)):
		return false
	disciple.v63_learned_skill_nodes[skill_id]["level"] = 1
	return true

func _realm_profile(cultivation_realm: int, body_realm: int) -> Dictionary:
	var track := func(realm: int) -> Dictionary:
		return {"realm":realm,"floor":1,"xp":0.0,"gate_failures":0,"lifetime_failures":0,
			"auto_breakthrough":false,"breakthrough_history":[],"last_training_event_id":""}
	return {"version":1,"initialized":true,"last_training_tick":-1,"last_passive_tuvi_tick":-1,
		"last_body_xp_tick":-1,"training_policy":"balanced","cultivation":track.call(cultivation_realm),"body":track.call(body_realm)}
