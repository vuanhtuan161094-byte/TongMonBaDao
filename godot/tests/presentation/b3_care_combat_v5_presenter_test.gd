extends SceneTree

const DEFAULT_SAVE_PATH := "user://b3_care_v5_presenter_test.json"
const SAVE_PATH_ENV := "TMB_B3_V5_PRESENTER_TEST_SAVE_PATH"

var ui: Control
var test_save_path := DEFAULT_SAVE_PATH

func _init() -> void:
	call_deferred("_run")

func _fail(message: String) -> void:
	push_error("B3 CARE / COMBAT V5 PRESENTATION FAIL: " + message)
	_cleanup()
	quit(1)

func _remove_save(path: String) -> void:
	for candidate in [path,path + ".bak"]:
		if FileAccess.file_exists(candidate):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(candidate))

func _cleanup() -> void:
	if ui != null:
		for timer_name in ["runtime_poll_timer","autosave_timer"]:
			var timer := ui.get(timer_name) as Timer
			if timer != null:
				timer.stop()
		ui.set("runtime_ready",false)
		ui.queue_free()
		ui = null
	_remove_save(test_save_path)
	ProjectSettings.set_setting("runtime/live_save_path",null)

func _recruit_real_v2(state: SimulationState) -> DiscipleState:
	state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
	var generation_index := 73021
	var candidate_id := StringName("candidate_%04d" % generation_index)
	while state.disciples.has(candidate_id) or state.recruitment_candidates.has(candidate_id):
		generation_index += 1
		candidate_id = StringName("candidate_%04d" % generation_index)
	var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
		state,DiscipleGeneratorV2.SOURCE_ORDINARY,generation_index
	)
	if candidate == null or candidate.v2_birth_profile.is_empty():
		return null
	state.recruitment_candidates[candidate.id] = candidate
	var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
	return state.disciples.get(candidate.id) if accepted.get("ok",false) else null

func _run() -> void:
	var supplied_path := OS.get_environment(SAVE_PATH_ENV).strip_edges()
	if not supplied_path.is_empty():
		test_save_path = supplied_path
	_cleanup()
	ProjectSettings.set_setting("runtime/live_save_path",test_save_path)
	var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
	if packed == null:
		_fail("actual P3.2 scene failed to load")
		return
	ui = packed.instantiate() as Control
	if ui == null:
		_fail("actual P3.2 scene failed to instantiate")
		return
	root.add_child(ui)
	await process_frame
	if not bool(ui.get("runtime_ready")):
		_fail("main runtime did not start")
		return
	for timer_name in ["runtime_poll_timer","autosave_timer"]:
		var timer := ui.get(timer_name) as Timer
		if timer != null:
			timer.stop()
	var runtime := ui.get("runtime_session") as LiveGameRuntimeV2
	var state := ui.get("state") as SimulationState
	if runtime == null or state == null or runtime.owner.state != state:
		_fail("P3.2 presenter is not attached to the canonical live runtime state")
		return
	var disciple := _recruit_real_v2(state)
	if disciple == null or not DiscipleRealmProgressV2.progression_ready(disciple):
		_fail("canonical recruitment did not produce an authentic V2 disciple")
		return
	if not WorkforceSystem.new().issue_command(state,disciple.id,WorkforceSystem.COMMAND_HOLD,"",1000000):
		_fail("could not put the real V2 recruit into an admissible idle state")
		return
	var begun := B3HuntWorld.begin(runtime.owner,disciple.id)
	if not bool(begun.get("ok",false)):
		_fail("CARE could not start its canonical hunt: " + str(begun))
		return
	var world_before: Dictionary = state.sect.b3_hunt.duplicate(true)
	var tick_before := state.tick
	var stock_before := WarehouseSystem.new().quantity(state,B3PilotContent.RESOURCE)
	ui.call("_open_b3_hunt_panel",disciple.id)
	await process_frame
	await process_frame
	var arena := ui.get("b3_hunt_arena") as Control
	var presenter := arena.get("presenter") as B3CareCombatV5Presenter if arena != null else null
	if presenter == null or presenter.battle == null:
		_fail("P3.2 did not bind the Combat V5 presenter to the CARE snapshot")
		return
	if not presenter.enable_source_a_combat_visuals or not presenter.enable_source_vl_art or not presenter.draw_pilot_ground:
		_fail("P3.2 did not enable the verified Source A V5 actors and ground presentation paths")
		return
	var battle_snapshot := B3HuntWorld.restore(state)
	if not bool(battle_snapshot.get("ok",false)):
		_fail("CARE battle snapshot failed to restore")
		return
	var expected_rows: Dictionary = ui.call("_b3_hunt_visual_rows",battle_snapshot["battle"])
	var disciple_actor_id := str(disciple.id)
	var monster_actor_id := ""
	for actor_id in battle_snapshot["battle"].actors:
		var actor: Dictionary = battle_snapshot["battle"].actors[actor_id]
		if str(actor.get("side","")) == "monster":
			monster_actor_id = str(actor_id)
			break
	if not expected_rows.has(disciple_actor_id) or monster_actor_id.is_empty() or not expected_rows.has(monster_actor_id):
		_fail("CARE actor ids did not resolve to real disciple / pilot-monster presentation rows")
		return
	var disciple_key := str(expected_rows[disciple_actor_id].get("source_a_visual_key",""))
	var monster_key := str(expected_rows[monster_actor_id].get("source_a_visual_key",""))
	if disciple_key not in ["disciple_male","disciple_female"] or monster_key != "monster_1113031_1":
		_fail("presentation mapping used an unverified actor key: %s / %s" % [disciple_key,monster_key])
		return
	for visual_key in [disciple_key,monster_key]:
		if not presenter._source_atlas.has_actor(visual_key):
			_fail("V5 manifest actor did not import: " + visual_key)
			return
		for action in ["idle","walk","attack","hit","die"]:
			var frame := presenter._source_atlas.frame_region(visual_key,action,Vector2.RIGHT,0.0)
			if frame.is_empty() or frame.get("texture") == null:
				_fail("Source A %s clip/frame is unavailable: %s" % [action,visual_key])
				return
	var boss_key := "boss_slot_410041_1"
	if not presenter._source_atlas.has_actor(boss_key):
		_fail("verified V5 Boss-slot manifest actor did not import")
		return
	for action in ["idle","walk","attack","hit","die"]:
		if presenter._source_atlas.frame_region(boss_key,action,Vector2.LEFT,0.0).is_empty():
			_fail("verified Boss-slot %s clip/frame is unavailable" % action)
			return
	var before_presentation := MapBattleSnapshotV2.save(presenter.battle)
	var before_saved_world: Dictionary = state.sect.b3_hunt.duplicate(true)
	presenter.refresh_from_authority()
	presenter.set_actor_view_metadata(expected_rows)
	presenter.queue_redraw()
	await process_frame
	if MapBattleSnapshotV2.save(presenter.battle) != before_presentation:
		_fail("Combat V5 view refresh mutated the battle state")
		return
	if state.sect.b3_hunt != before_saved_world or state.tick != tick_before:
		_fail("presentation refresh mutated saved CARE world or canonical time")
		return
	if WarehouseSystem.new().quantity(state,B3PilotContent.RESOURCE) != stock_before:
		_fail("presentation refresh mutated canonical Warehouse stock")
		return
	if expected_rows[disciple_actor_id].get("display_name","") != disciple.display_name:
		_fail("real V2 disciple identity did not flow into the view metadata")
		return
	# CARE PH0 snapshots keep a rolling 96-event presentation ring and have no
	# global event_sequence. Confirm the adapter consumes appended events once,
	# including when the ring rolls, without modifying saved CARE authority.
	var initial_cursor := presenter._event_cursor
	for index in range(95):
		presenter.battle.events.append({
			"type":"presentation_probe","time":presenter.battle.now,
			"encounter_id":presenter.battle.encounter_id,"probe_index":index
		})
	presenter.refresh_from_authority()
	if presenter._event_cursor != initial_cursor + 95:
		_fail("adapter failed to ingest append-only CARE event-ring updates")
		return
	presenter.battle.events.append({
		"type":"presentation_probe","time":presenter.battle.now,
		"encounter_id":presenter.battle.encounter_id,"probe_index":95
	})
	presenter.battle.events = presenter.battle.events.slice(presenter.battle.events.size()-96)
	presenter.refresh_from_authority()
	if presenter._event_cursor != initial_cursor + 96:
		_fail("adapter failed to ingest one new event after the CARE ring rolled")
		return
	presenter.refresh_from_authority()
	if presenter._event_cursor != initial_cursor + 96:
		_fail("adapter replayed an already-rendered event from the CARE ring")
		return
	print("B3 CARE → COMBAT V5 SOURCE A VIEW-ONLY PRESENTATION: PASS")
	print("disciple=%s key=%s monster=%s key=%s tick=%d real_clip_routes=idle,walk,attack,hit,die boss_asset_verified=true boss_event_mapped=false" % [
		str(disciple.id),disciple_key,monster_actor_id,monster_key,tick_before
	])
	_cleanup()
	quit(0)
