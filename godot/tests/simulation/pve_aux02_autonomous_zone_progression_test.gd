extends SceneTree

# Autonomous integration only: real saved V2 disciples, real Source A topology,
# canonical runtime clock, and actual Combat V2 AI. No injected movement, direct
# damage, or synthetic reward/loot is used in this test.
const QA_SEED_SAVE := "res://outputs/endgame_qa_20261026/gameplay/roster_130/endgame_capture_save_1792953798.json"
const SAVE_PATH := "user://codex1_autonomous_zone_progression.json"
const START_WALL := 1_800_000_000
const SEED := 410272
const ENCOUNTER := "codex1_autonomous_zone_progression"
const POLL_SECONDS := 5
const MAX_SIM_SECONDS := 240

var checks := 0

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> bool:
	checks += 1
	if condition:
		return true
	push_error("PVE AUX-02 AUTONOMOUS PROGRESSION FAIL: " + message)
	_cleanup()
	quit(1)
	return false

func _remove(path: String) -> void:
	for suffix in ["", ".tmp", ".bak"]:
		var artifact: String = path + suffix
		if FileAccess.file_exists(artifact):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(artifact))

func _cleanup() -> void:
	_remove(SAVE_PATH)

func _eligible(state: SimulationState, member: DiscipleState) -> bool:
	if member == null or not DiscipleRealmProgressV2.progression_ready(member):
		return false
	if member.hp <= 0.0 or member.injury_level != 0 or not member.active_pve_encounter_id.is_empty():
		return false
	if member.region_id != &"sect" or not [&"EVALUATE", &"IDLE", &"HOLD"].has(member.current_action):
		return false
	if not member.work_cycle_state.is_empty() or member.worksite_building_id != &"" or not member.work_progress.is_empty():
		return false
	var buildings := BuildingSystem.new()
	return not buildings.disciple_has_active_spirit_plot(state, member.id) \
		and not buildings.disciple_has_active_timed_recipe(state, member.id) \
		and buildings.active_resource_timer_for_worker(state, member.id).is_empty() \
		and not DiscipleBodyTrainingFacilityV2.has_reserved_slot(state, member)

func _rating(state: SimulationState, member: DiscipleState) -> float:
	var profile := DiscipleRealmProgressV2.current(member)
	var cultivation: Dictionary = profile["cultivation"]
	var body: Dictionary = profile["body"]
	var preview := DiscipleCombatLoadoutV2.build(state, member,
		int(cultivation["realm"]), int(cultivation["floor"]),
		int(body["realm"]), int(body["floor"]), "frontline", Vector2.ZERO, "codex1_rating")
	if not bool(preview.get("ok", false)):
		return -INF
	var stats: Dictionary = preview["stats"]
	return float(preview.get("hp", 0.0)) + float(stats.get("max_hp", 0.0)) * 0.35 \
		+ float(stats.get("attack", 0.0)) * 3.0 + float(stats.get("defense", 0.0)) * 2.0 \
		+ float((preview.get("skill_factors", {}) as Dictionary).size()) * 20.0

func _party(state: SimulationState) -> Array:
	var candidates: Array[Dictionary] = []
	for raw_id in state.disciples.keys():
		var member: DiscipleState = state.disciples[StringName(raw_id)]
		if _eligible(state, member):
			candidates.append({"id": member.id, "rating": _rating(state, member)})
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if not is_equal_approx(float(a["rating"]), float(b["rating"])):
			return float(a["rating"]) > float(b["rating"])
		return str(a["id"]) < str(b["id"]))
	if candidates.size() < 6:
		return []
	var party: Array = []
	var roles := ["frontline", "frontline", "mage", "healer", "ranged", "ranged"]
	for index in range(6):
		var id := StringName(candidates[index]["id"])
		var profile := DiscipleRealmProgressV2.current(state.disciples[id])
		party.append({
			"disciple_id": str(id), "party_id": "codex1_autonomous_party",
			"role": roles[index],
			"position": Vector2(8.0 + float(index % 3) * 0.55,
				8.7 + float(int(index / 3)) * 0.55),
			"realm": int(profile["cultivation"]["realm"]),
			"floor": int(profile["cultivation"]["floor"]),
			"body_realm": int(profile["body"]["realm"]),
			"body_floor": int(profile["body"]["floor"])
		})
	return party

func _world_options() -> Dictionary:
	var navigation: Dictionary = SectIsometricWorldV1.pve_navigation_grid()
	if navigation.is_empty():
		return {}
	var options := PveOpenWorldTopologyV1.build(
		navigation, Vector2(SectIsometricWorldV1.PVE_SPAWN_CELL) + Vector2(0.5, 0.5))
	if not bool(options.get("ok", false)):
		return {}
	options["respawn_delay_sim_seconds"] = 30.0
	options["auto_hunt"] = true
	return options

func _count_first_camp_respawns(population: Dictionary) -> int:
	var count := 0
	for ordinal in range(PveMultiCampPopulationV1.MIN_SLOTS_PER_CAMP):
		var slot: Dictionary = population.get("slots", {}).get(
			PveMultiCampPopulationV1.slot_id(0, ordinal), {})
		if int(slot.get("generation", 0)) >= 2 and str(slot.get("phase", "")) == "READY":
			count += 1
	return count

func _run() -> void:
	_cleanup()
	var output_dir := ProjectSettings.globalize_path(SAVE_PATH.get_base_dir())
	if not _check(DirAccess.make_dir_recursive_absolute(output_dir) == OK
			or DirAccess.dir_exists_absolute(output_dir), "could not create isolated SaveService directory"):
		return
	var seed_state := SaveService.new().load_from_path(QA_SEED_SAVE)
	if not _check(seed_state != null and seed_state.disciples.size() == 130,
		"real P3.2 QA seed did not load with its 130-member roster"):
		return
	seed_state.runtime_last_wall_unix = START_WALL
	seed_state.runtime_unconsumed_wall_seconds = 0.0
	if not _check(SaveService.new().save_to_path(seed_state, SAVE_PATH) == OK,
		"could not stage an isolated copy of the canonical QA save"):
		return
	var runtime := LiveGameRuntimeV2.new()
	var opened := runtime.start(SAVE_PATH, START_WALL, SEED)
	var state: SimulationState = runtime.state()
	if not _check(bool(opened.get("ok", false)) and state != null,
		"canonical runtime could not open the isolated QA save"):
		return
	var party := _party(state)
	if not _check(party.size() == 6,
		"production-equivalent eligibility/rating picker found fewer than six free healthy real V2 disciples"):
		return
	var options := _world_options()
	if not _check(bool(options.get("ok", false))
		and options.get("camp_positions", []).size() == PveMultiCampPopulationV1.CAMP_COUNT,
		"pinned Source A continuous topology did not expose all 20 camps"):
		return
	var warehouse_before: Dictionary = state.sect.warehouse_resources.duplicate(true)
	var begun := HuntingPveRunV2.new().begin_multicamp(
		runtime.owner, ENCOUNTER, SEED, party, 10, options)
	if not _check(bool(begun.get("ok", false)) and int(begun.get("party_size", 0)) == 6
		and int(begun.get("monster_count", 0)) == 10
		and str(begun.get("resource_payout", "LOOT_PENDING")) == "LOOT_PENDING",
		"real Combat V2 6v10 open-world run did not begin: " + str(begun)):
		return
	var encounter := HuntingPveRunV2.active_multicamp_id(state)
	var initial := HuntingPveRunV2.resume_active(state, encounter)
	if not _check(bool(initial.get("ok", false)), "initial 6v10 Combat V2 snapshot did not restore"):
		return
	var first_session: HuntingPveRunV2 = initial["session"]
	if not _check(first_session.battle.auto_hunt and first_session.battle._count_alive("disciple") == 6
		and first_session.battle._count_alive("monster") == 10
		and first_session.camp_population.get("camps", []).size() == 20,
		"initial snapshot is not six authentic hunters against ten live monsters across a 20-camp registry"):
		return
	var wall := START_WALL
	var simulated := 0
	var reloaded := false
	var zone_changed := false
	var respawned_first_camp := 0
	var last_counts := {"kills": 0, "alive": 10, "camp": 0, "time": 0.0}
	while simulated < MAX_SIM_SECONDS and not HuntingPveRunV2.active_multicamp_id(state).is_empty():
		wall += POLL_SECONDS
		simulated += POLL_SECONDS
		var poll := runtime.poll(wall)
		if not _check(bool(poll.get("ok", false)),
			"canonical auto-hunt runtime poll failed at +%d seconds: %s" % [simulated, str(poll)]):
			return
		var active_id := HuntingPveRunV2.active_multicamp_id(state)
		if active_id.is_empty():
			break
		var restored := HuntingPveRunV2.resume_active(state, active_id)
		if not _check(bool(restored.get("ok", false)), "live auto-hunt snapshot failed to restore"):
			return
		var session: HuntingPveRunV2 = restored["session"]
		last_counts = {
			"kills": int(session.camp_population.get("world_total_kills", 0)),
			"alive": session.battle._count_alive("monster"),
			"camp": session.camp_index,
			"time": session.battle.now
		}
		respawned_first_camp = _count_first_camp_respawns(session.camp_population)
		zone_changed = session.camp_index > 0
		if simulated == 20 and not reloaded:
			var before_save_result := HuntingPveRunV2.resume_active(state, ENCOUNTER)
			if not _check(bool(before_save_result.get("ok", false)),
				"active world could not restore at the SaveService checkpoint"):
				return
			var before_save_battle: MapBattleV2 = before_save_result["session"].battle
			var saved_alive_disciple_count := before_save_battle._count_alive("disciple")
			var saved_alive_monster_count := before_save_battle._count_alive("monster")
			if not _check(bool(runtime.save(wall).get("ok", false)),
				"active autonomous battle failed canonical SaveService save"):
				return
			var disk_state := SaveService.new().load_from_path(SAVE_PATH)
			var disk_run := HuntingPveRunV2.resume_active(disk_state, ENCOUNTER) if disk_state != null else {"ok": false}
			var disk_session: HuntingPveRunV2 = disk_run.get("session") if bool(disk_run.get("ok", false)) else null
			var disk_battle: MapBattleV2 = disk_session.battle if disk_session != null else null
			var party_records_valid := disk_battle != null
			if disk_battle != null:
				for member_row in party:
					var actor: Dictionary = disk_battle.actors.get(str(member_row["disciple_id"]), {})
					party_records_valid = party_records_valid and str(actor.get("side", "")) == "disciple"
			print("PVE AUX-02 AUTONOMOUS SAVE_RELOAD detail=%s disciples=%d monsters=%d auto=%s warehouse_equal=%s claims=%d active=%s" % [
				str(disk_run), disk_battle._count_alive("disciple") if disk_battle != null else -1,
				disk_battle._count_monster_records() if disk_battle != null else -1,
				str(disk_battle.auto_hunt if disk_battle != null else false),
				str(disk_state.sect.warehouse_resources == warehouse_before) if disk_state != null else "null",
				disk_state.sect.v2_pve_reward_claims.size() if disk_state != null else -1,
				HuntingPveRunV2.active_multicamp_id(disk_state) if disk_state != null else "null"])
			if not _check(bool(disk_run.get("ok", false))
				and disk_battle != null and party_records_valid
				and disk_battle._count_alive("disciple") == saved_alive_disciple_count
				and disk_battle._count_alive("monster") == saved_alive_monster_count
				and disk_battle._count_monster_records() == 10
				and disk_battle.auto_hunt
				and disk_state.sect.warehouse_resources == warehouse_before
				and disk_state.sect.v2_pve_reward_claims.is_empty(),
				"disk reload changed active party, 10 monster records, auto-hunt, or reward authority"):
				return
			runtime = LiveGameRuntimeV2.new()
			var reopened := runtime.start(SAVE_PATH, wall, SEED)
			state = runtime.state()
			if not _check(bool(reopened.get("ok", false)) and bool(reopened.get("loaded", false)),
				"new canonical runtime owner could not reopen active battle at same wall clock"):
				return
			reloaded = true
		if simulated % 25 == 0:
			print("PVE AUX-02 AUTONOMOUS PROGRESS seconds=%d camp=%02d kills=%d alive_monsters=%d battle_time=%.1f respawned_c01=%d" % [
				simulated, int(last_counts["camp"]) + 1, int(last_counts["kills"]),
				int(last_counts["alive"]), float(last_counts["time"]), respawned_first_camp])
		if zone_changed and respawned_first_camp > 0:
			break
	if HuntingPveRunV2.active_multicamp_id(state).is_empty():
		var receipt: Dictionary = state.sect.v2_pve_settlement_receipts.get(ENCOUNTER, {})
		return _check(false, "auto-hunt terminated before an active camp transition; outcome=%s kills=%s camp=%s" % [
			str(receipt.get("outcome", "unknown")), str(receipt.get("kills", "?")), str(receipt.get("camp_id", "?"))])
	var final_run := HuntingPveRunV2.resume_active(state, ENCOUNTER)
	if not _check(bool(final_run.get("ok", false)), "final auto-hunt world did not restore"):
		return
	var final_session: HuntingPveRunV2 = final_run["session"]
	var final_battle: MapBattleV2 = final_session.battle
	var final_zone_event := false
	var final_zone_spawn_count := 0
	var final_party_records_valid := true
	for member_row in party:
		var actor: Dictionary = final_battle.actors.get(str(member_row["disciple_id"]), {})
		final_party_records_valid = final_party_records_valid and str(actor.get("side", "")) == "disciple"
	for event in final_battle.events:
		if str(event.get("type", "")) == "world_zone_entered" and str(event.get("camp_id", "")) != "C01":
			final_zone_event = true
			final_zone_spawn_count = int(event.get("actor_count", 0))
	print("PVE AUX-02 AUTONOMOUS FINAL detail zone_changed=%s camp=%d party_records=%s living=%d monsters=%d zone_event=%s kills=%d respawns=%d time=%.1f" % [
		str(zone_changed), final_session.camp_index, str(final_party_records_valid),
		final_battle._count_alive("disciple"), final_battle._count_alive("monster"),
		str(final_zone_event), int(final_session.camp_population.get("world_total_kills", 0)),
		respawned_first_camp, final_battle.now])
	if not _check(zone_changed and final_session.camp_index > 0 and final_party_records_valid
		and final_battle._count_alive("disciple") > 0
		and final_battle._count_monster_records() == 10
		and final_zone_event and final_zone_spawn_count == 10,
		"natural autonomous combat did not carry all six party records into the next camp and spawn ten monsters"):
		return
	if not _check(reloaded and final_battle.world_mode and final_battle.auto_hunt
		and final_session.camp_population["camps"].size() == 20,
		"Save/Reload lost the active autonomous world, 20-camp registry, or auto-hunt authority"):
		return
	if not _check(respawned_first_camp > 0,
		"C01 has not naturally respawned any acknowledged HP0 slot after its 30-second cooldown"):
		return
	if not _check(final_session.camp_population.get("world_total_kills", 0) >= 10
		and state.sect.v2_pve_reward_claims.is_empty()
		and state.sect.v2_pve_settlement_receipts.is_empty()
		and state.sect.warehouse_resources == warehouse_before,
		"real Combat V2 HP0 was not acknowledged without granting unauthorized loot or settlement"):
		return
	print("PVE AUX-02 AUTONOMOUS ZONE PROGRESSION PASS checks=%d elapsed=%d wall_seconds camp=%02d kills=%d c01_respawns=%d party_records=6 living_party=%d zone_spawn_count=%d alive_monsters=%d save_reload=true auto_hunt=true injected_movement=false forced_damage=false loot=none physical_mouse=NOT_TESTED" % [
		checks, simulated, final_session.camp_index + 1,
		int(final_session.camp_population.get("world_total_kills", 0)), respawned_first_camp,
		final_battle._count_alive("disciple"), final_zone_spawn_count,
		final_battle._count_alive("monster")])
	_cleanup()
	quit(0)
