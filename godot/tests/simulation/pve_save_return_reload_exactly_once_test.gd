extends SceneTree

# AUX-01 regression fixture. Uses an isolated user:// save and real V2 state,
# Combat V2, the canonical runtime owner and SaveService. The one lethal hit is
# an explicit test stimulus for the unpaid LOOT_PENDING life receipt; it does
# not create an item entitlement or mutate production code.
const SAVE_PATH := "res://outputs/qa_aux01_save_return_reload_20261027/save.json"
const START_WALL := 1_800_000_000
const SEED := 410271
const ENCOUNTER := "aux01_save_return_reload_c01"

var checks := 0

func _init() -> void:
	call_deferred("_run")

func _check(valid: bool, reason: String) -> bool:
	if not valid:
		push_error("PVE AUX-01 SAVE/RETURN/RELOAD FAIL: "+reason)
		_cleanup()
		quit(1)
		return false
	checks += 1
	return true

func _remove(path: String) -> void:
	for candidate in [path,path+".tmp",path+".bak"]:
		if FileAccess.file_exists(candidate):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(candidate))

func _cleanup() -> void:
	_remove(SAVE_PATH)

func _make_party(state: SimulationState) -> Array:
	var party: Array = []
	var roles := ["frontline","ranged","mage","healer","frontline","ranged"]
	state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+6)
	for index in range(6):
		var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
			state,DiscipleGeneratorV2.SOURCE_ORDINARY,SEED+index+1
		)
		if candidate == null or candidate.v2_birth_profile.is_empty():
			return []
		state.recruitment_candidates[candidate.id] = candidate
		var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
		if not bool(accepted.get("ok",false)):
			return []
		var disciple: DiscipleState = state.disciples.get(candidate.id)
		if disciple == null or not DiscipleRealmProgressV2.progression_ready(disciple):
			return []
		disciple.current_action = &"HOLD"
		party.append({
			"disciple_id":str(disciple.id),
			"party_id":"aux01_party",
			"role":roles[index],
			"position":Vector2(8.0+float(index%3)*2.0,8.0+float(int(index/3))*2.0)
		})
	return party

func _world_options() -> Dictionary:
	var navigation: Dictionary = SectIsometricWorldV1.pve_navigation_grid()
	if navigation.is_empty():
		return {}
	var topology := PveOpenWorldTopologyV1.build(
		navigation,
		Vector2(SectIsometricWorldV1.PVE_SPAWN_CELL)+Vector2(0.5,0.5)
	)
	if not bool(topology.get("ok",false)):
		return {}
	topology["respawn_delay_sim_seconds"] = 30.0
	topology["auto_hunt"] = true
	return topology

func _corrupt_and_reject(source_path: String, field: String,
		bad_value: String, encounter_id: String,
		warehouse_before: Dictionary) -> bool:
	var damaged := SaveService.new().load_from_path(source_path)
	if damaged == null or not damaged.sect.v2_pve_active_runs.has(encounter_id):
		return _check(false,"could not load an isolated active save for identity corruption")
	var envelope: Dictionary = damaged.sect.v2_pve_active_runs[encounter_id].duplicate(true)
	var population: Dictionary = envelope.get("camp_population",{}).duplicate(true)
	population[field] = bad_value
	envelope["camp_population"] = population
	damaged.sect.v2_pve_active_runs[encounter_id] = envelope
	var before_receipts := damaged.sect.v2_pve_settlement_receipts.duplicate(true)
	var before_claims := damaged.sect.v2_pve_reward_claims.duplicate(true)
	var before_wall := damaged.runtime_last_wall_unix
	var result := HuntingPveRunV2.resume_active(damaged,encounter_id)
	return _check(not bool(result.get("ok",false))
			and damaged.sect.warehouse_resources == warehouse_before
			and damaged.sect.v2_pve_settlement_receipts == before_receipts
			and damaged.sect.v2_pve_reward_claims == before_claims
			and damaged.runtime_last_wall_unix == before_wall,
			"mismatched saved %s identity was not rejected without side effects: %s" % [field,str(result)])

func _run() -> void:
	_cleanup()
	var output_dir := ProjectSettings.globalize_path(SAVE_PATH.get_base_dir())
	if not _check(DirAccess.make_dir_recursive_absolute(output_dir) == OK
			or DirAccess.dir_exists_absolute(output_dir),
		"could not create the isolated AUX-01 SaveService output directory"):
		return
	var runtime := LiveGameRuntimeV2.new()
	var opened := runtime.start(SAVE_PATH,START_WALL,SEED)
	if not _check(bool(opened.get("ok",false)) and bool(opened.get("created",false)),
		"isolated canonical runtime could not create its QA save"):
		return
	var state: SimulationState = runtime.state()
	var party := _make_party(state)
	if not _check(party.size() == 6,
		"fixture could not recruit six initialized V2 disciples"):
		return
	if not _check(bool(HuntingMapV2.choose_level(
		state,PveMultiCampPopulationV1.ZONE,1).get("ok",false)),
		"could not choose the canonical Thanh Trúc Lâm pilot region"):
		return
	var options := _world_options()
	if not _check(not options.is_empty() and str(options.get("source_blob_sha","")) == str(options.get("navigation",{}).get("source_blob_sha","")),
		"pinned Source A world topology is unavailable or inconsistent"):
		return
	if not _check(bool(runtime.save(START_WALL).get("ok",false)),
		"canonical runtime could not save the seeded V2 party"):
		return
	var begun := HuntingPveRunV2.new().begin_multicamp(
		runtime.owner,ENCOUNTER,SEED,party,10,options
	)
	if not _check(bool(begun.get("ok",false))
			and bool(begun.get("world_mode",false))
			and int(begun.get("party_size",0)) == 6
			and int(begun.get("monster_count",0)) == 10
			and str(begun.get("resource_payout","")) == "LOOT_PENDING",
		"canonical owner did not start a real Source A 6v10 pilot with loot disabled: %s" % str(begun)):
		return
	for row in party:
		var member: DiscipleState = state.disciples[StringName(row["disciple_id"])]
		if not _check(member.active_pve_encounter_id == ENCOUNTER,
			"active world did not reserve each canonical party member exactly once"):
			return
	var active_ids_before := HuntingPveRunV2.active_multicamp_id(state)
	if not _check(active_ids_before == ENCOUNTER
			and state.sect.v2_pve_active_runs.size() == 1
			and state.sect.v2_pve_settlement_receipts.is_empty()
			and state.sect.v2_pve_reward_claims.is_empty(),
		"start created duplicate active-job, settlement, or reward authority"):
		return
	var warehouse_before: Dictionary = state.sect.warehouse_resources.duplicate(true)
	var start_run := HuntingPveRunV2.resume_active(state,ENCOUNTER)
	if not _check(bool(start_run.get("ok",false)),"active Source A state did not restore before clock step"):
		return
	var start_session: HuntingPveRunV2 = start_run["session"]
	var start_battle: MapBattleV2 = start_session.battle
	var battle_time_before := start_battle.now
	var poll_wall := START_WALL+1
	var first_poll := runtime.poll(poll_wall)
	var first_run := HuntingPveRunV2.resume_active(state,ENCOUNTER)
	if not _check(bool(first_poll.get("ok",false))
			and int(first_poll.get("frames_run",0)) > 0
			and bool(first_run.get("ok",false)),
		"canonical wall clock did not step the active Combat V2 encounter: %s" % str(first_poll)):
		return
	var first_session: HuntingPveRunV2 = first_run["session"]
	var first_battle: MapBattleV2 = first_session.battle
	if not _check(is_equal_approx(first_battle.now-battle_time_before,1.0)
			and state.runtime_last_wall_unix == poll_wall,
		"one wall second did not produce exactly one combat second and matching owner timestamp"):
		return
	var time_after_first := first_battle.now
	var actions_after_first := first_battle.actions
	var same_wall_poll := runtime.poll(poll_wall)
	var same_wall_run := HuntingPveRunV2.resume_active(state,ENCOUNTER)
	if not _check(bool(same_wall_poll.get("ok",false))
			and int(same_wall_poll.get("frames_run",-1)) == 0
			and bool(same_wall_run.get("ok",false))
			and is_equal_approx(same_wall_run["session"].battle.now,time_after_first)
			and same_wall_run["session"].battle.actions == actions_after_first,
		"replaying the same injected wall timestamp advanced or acted in Combat V2"):
		return
	if not _check(bool(runtime.save(poll_wall).get("ok",false)),
		"active 6v10 snapshot could not be saved through the canonical runtime"):
		return
	var saved_state := SaveService.new().load_from_path(SAVE_PATH)
	var saved_run := HuntingPveRunV2.resume_active(saved_state,ENCOUNTER) if saved_state != null else {"ok":false}
	if not _check(saved_state != null and bool(saved_run.get("ok",false)),
		"disk reload rejected the active world save"):
		return
	var saved_session: HuntingPveRunV2 = saved_run["session"]
	if not _check(saved_session.battle._count_alive("disciple") == 6
			and saved_session.battle._count_monster_records() == 10
			and saved_session.battle._count_alive("monster") == 10
			and is_equal_approx(saved_session.battle.now,time_after_first)
			and is_equal_approx(saved_session.minute_phase,first_session.minute_phase)
			and saved_state.runtime_last_wall_unix == poll_wall
			and HuntingPveRunV2.saved_world_identity_matches(saved_session.battle,saved_session.camp_population),
		"disk reload changed V2 party/monsters, Source A SHA, wall clock, or minute phase"):
		return
	var source_run := HuntingPveRunV2.resume_active(state,ENCOUNTER)
	if not _check(bool(source_run.get("ok",false)),
		"original runtime lost its active world after independent disk validation"):
		return
	var source_session: HuntingPveRunV2 = source_run["session"]
	if not _check(_corrupt_and_reject(SAVE_PATH,
		"world_source_sha","0123456789abcdef0123456789abcdef01234567",ENCOUNTER,warehouse_before),
		"valid-length wrong world SHA was accepted or had effects"):
		return
	if not _check(_corrupt_and_reject(SAVE_PATH,
		"world_source_map","JXQY2:unregistered_map",ENCOUNTER,warehouse_before),
		"wrong world label was accepted or had effects"):
		return
	# Test-only direct Combat V2 hit at its current simulation instant creates one
	# authentic HP0 journal event without advancing or fabricating clock time.
	var combat: MapBattleV2 = source_session.battle
	var attacker: Dictionary = {}
	var target: Dictionary = {}
	for id in combat.actors:
		var actor: Dictionary = combat.actors[id]
		if str(actor.get("side","")) == "disciple" and attacker.is_empty():
			attacker = actor
		elif str(actor.get("side","")) == "monster" and float(actor.get("hp",0.0)) > 0.0 and target.is_empty():
			target = actor
	if not _check(not attacker.is_empty() and not target.is_empty(),
		"loaded Combat V2 snapshot lacks a live source and target actor"):
		return
	var lethal_ratio := maxf(1000.0,float(target["max_hp"])*1000.0/maxf(float(attacker["stats"].get("attack",1.0)),1.0))
	var dealt := combat._deal_direct(attacker,target,lethal_ratio,"basic",true)
	if not _check(dealt > 0.0 and float(target["hp"]) == 0.0
			and combat.pending_kill_events().size() == 1,
		"legal Combat V2 damage did not emit exactly one HP0 journal event"):
		return
	var kill_id := str(combat.pending_kill_events()[0].get("kill_id",""))
	var kill_slot := str(combat.pending_kill_events()[0].get("spawn_slot_id",""))
	var kill_result := source_session._record_open_world_kills()
	if not _check(bool(kill_result.get("ok",false))
			and int(kill_result.get("recorded",0)) == 1
			and not bool(kill_result.get("rewards_granted",true))
			and combat.pending_kill_events().is_empty()
			and int(source_session.camp_population.get("world_total_kills",0)) == 1,
		"HP0 receipt did not ACK exactly once under LOOT_PENDING; result=%s pending=%d total=%d" % [
			str(kill_result),combat.pending_kill_events().size(),int(source_session.camp_population.get("world_total_kills",0))]):
		return
	var slot_after_kill: Dictionary = source_session.camp_population["slots"][kill_slot]
	if not _check(str(slot_after_kill.get("phase","")) == "COOLDOWN"
			and str(slot_after_kill.get("kill_id","")) == kill_id
			and str(slot_after_kill.get("reward_disposition","")) == "LOOT_PENDING"
			and state.sect.warehouse_resources == warehouse_before
			and state.sect.v2_pve_reward_claims.is_empty()
			and state.sect.v2_pve_settlement_receipts.is_empty(),
		"HP0 journal credited unauthorized Warehouse stock or a reward/settlement claim"):
		return
	if not _check(bool(source_session._persist_live_state().get("ok",false))
			and bool(runtime.save(poll_wall).get("ok",false)),
		"acknowledged HP0 receipt did not cross the canonical SaveService barrier"):
		return
	var active_reloaded := LiveGameRuntimeV2.new()
	var active_reopen := active_reloaded.start(SAVE_PATH,poll_wall,SEED)
	var active_state: SimulationState = active_reloaded.state()
	var active_run := HuntingPveRunV2.resume_active(active_state,ENCOUNTER) if active_state != null else {"ok":false}
	if not _check(bool(active_reopen.get("ok",false)) and bool(active_run.get("ok",false)),
		"reopening the active SaveService file failed"):
		return
	var active_session: HuntingPveRunV2 = active_run["session"]
	var duplicate_scan := active_session._record_open_world_kills()
	var reloaded_slot: Dictionary = active_session.camp_population["slots"][kill_slot]
	if not _check(int(duplicate_scan.get("recorded",-1)) == 0
			and int(active_session.camp_population.get("world_total_kills",0)) == 1
			and str(reloaded_slot.get("kill_id","")) == kill_id
			and active_state.sect.warehouse_resources == warehouse_before
			and active_state.sect.v2_pve_reward_claims.is_empty(),
		"reload replayed the HP0 receipt or granted Warehouse stock"):
		return
	var active_battle_time := active_session.battle.now
	var active_clock_wall := active_state.runtime_last_wall_unix
	var retreat := active_session.retreat_multicamp()
	if not _check(bool(retreat.get("ok",false))
			and str(retreat.get("outcome","")) == "timeout_retreat"
			and int(retreat.get("kills",-1)) == 1
			and str(retreat.get("loot_disposition","")) == "LOOT_PENDING",
		"manual return did not settle exactly one no-reward receipt"):
		return
	var terminal: Dictionary = active_state.sect.v2_pve_settlement_receipts.get(ENCOUNTER,{})
	if not _check(not active_state.sect.v2_pve_active_runs.has(ENCOUNTER)
			and active_state.sect.v2_pve_settlement_receipts.size() == 1
			and active_state.sect.v2_pve_reward_claims.is_empty()
			and terminal.get("items",{}) == {}
			and active_state.sect.warehouse_resources == warehouse_before,
		"manual return left a live run or created duplicate settlement/loot"):
		return
	for row in party:
		var member: DiscipleState = active_state.disciples[StringName(row["disciple_id"])]
		if not _check(member.region_id == &"sect"
				and member.active_pve_encounter_id.is_empty()
				and member.injury_level == 0
				and member.injury_recover_at_tick == 0,
			"clean retreat failed to release the reservation or invented Injury120"):
			return
	var receipt_json := JSON.stringify(terminal,"",false,true)
	var second_retreat := active_session.retreat_multicamp()
	if not _check(not bool(second_retreat.get("ok",false))
			and JSON.stringify(active_state.sect.v2_pve_settlement_receipts[ENCOUNTER],"",false,true) == receipt_json
			and active_state.sect.v2_pve_reward_claims.is_empty()
			and active_state.sect.warehouse_resources == warehouse_before,
		"a duplicate return modified the terminal receipt or canonical stock"):
		return
	if not _check(bool(active_reloaded.save(poll_wall).get("ok",false)),
		"terminal return state could not be saved through the runtime owner"):
		return
	var returned_runtime := LiveGameRuntimeV2.new()
	var returned_open := returned_runtime.start(SAVE_PATH,poll_wall,SEED)
	var returned_state: SimulationState = returned_runtime.state()
	var final_receipt: Dictionary = returned_state.sect.v2_pve_settlement_receipts.get(ENCOUNTER,{}) if returned_state != null else {}
	var terminal_battle := MapBattleSnapshotV2.load(final_receipt.get("battle",{})) if not final_receipt.is_empty() else {"ok":false}
	var repeat_after_reload := returned_runtime.poll(poll_wall) if returned_state != null else {"ok":false}
	if not _check(bool(returned_open.get("ok",false))
			and returned_state != null
			and HuntingPveRunV2.active_multicamp_id(returned_state).is_empty()
			and returned_state.sect.v2_pve_active_runs.is_empty()
			and returned_state.sect.v2_pve_settlement_receipts.size() == 1
			and str(final_receipt.get("outcome","")) == "timeout_retreat"
			and int(final_receipt.get("kills",-1)) == 1
			and final_receipt.get("items",{}) == {}
			and bool(terminal_battle.get("ok",false))
			and is_equal_approx(terminal_battle["battle"].now,active_battle_time)
			and returned_state.runtime_last_wall_unix == active_clock_wall
			and int(repeat_after_reload.get("frames_run",repeat_after_reload.get("steps_run",-1))) == 0
			and returned_state.sect.warehouse_resources == warehouse_before
			and returned_state.sect.v2_pve_reward_claims.is_empty(),
		"terminal reload duplicated return/kill, changed wall identity, or paid unapproved loot"):
		return
	for row in party:
		var member: DiscipleState = returned_state.disciples[StringName(row["disciple_id"])]
		if not _check(member.region_id == &"sect"
				and member.active_pve_encounter_id.is_empty()
				and member.injury_level == 0,
			"terminal reload did not preserve released party reservations"):
			return
	print("PVE AUX-01 SAVE/RETURN/RELOAD PASS checks=%d exact_sha=%s party=6 monsters=10 active_reload=true same_wall_no_step=true hp0_receipt_once=true warehouse_delta=0 injury_retreat=0 injury120_contract=gp_02c1_injury_settlement_test loot=LOOT_PENDING" % [checks,str(OS.get_environment("TMB_SOURCE_SHA"))])
	_cleanup()
	quit(0)
