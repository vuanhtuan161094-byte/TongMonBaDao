extends SceneTree

const SAVE_PATH := "user://tong_mon_ba_dao_live_v2.json"
const KEEP_SAVE_ENV := "TMB_KEEP_PVE_LIVE_SAVE"
const GUI_CAPTURE_ENV := "TMB_PVE_GUI_CAPTURE_PATH"

var ui: Control
var state: SimulationState
var ids: Array[StringName] = []

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error("PVE MULTICAMP P3.2 LIVE FAIL: "+message)
	_cleanup_ui()
	quit(1)
	return false

func _cleanup_ui() -> void:
	if ui == null:
		return
	for property in ["runtime_poll_timer","autosave_timer"]:
		var timer := ui.get(property) as Timer
		if timer != null:
			timer.stop()
	ui.set("runtime_ready",false)
	ui.queue_free()
	ui = null

func _recruit_one(seed: int) -> DiscipleState:
	state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
	var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
		state,DiscipleGeneratorV2.SOURCE_ORDINARY,seed
	)
	if candidate == null or candidate.v2_birth_profile.is_empty():
		return null
	state.recruitment_candidates[candidate.id] = candidate
	var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
	if not bool(accepted.get("ok",false)):
		return null
	var disciple: DiscipleState = state.disciples[candidate.id]
	if not WorkforceSystem.new().issue_command(state,disciple.id,
		WorkforceSystem.COMMAND_HOLD,"",1000000):
		return null
	return disciple

func _run() -> void:
	var keep := OS.get_environment(KEEP_SAVE_ENV) == "1"
	ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
	if not keep:
		_remove_save()
	var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
	if not _check(packed != null,"actual P3.2 scene did not load"):
		return
	ui = packed.instantiate() as Control
	root.add_child(ui)
	await process_frame
	if not _check(bool(ui.get("runtime_ready")),"P3.2 did not start its canonical LiveGameRuntimeV2"):
		return
	for property in ["runtime_poll_timer","autosave_timer"]:
		var timer := ui.get(property) as Timer
		if timer != null:
			timer.start()
	state = ui.get("state") as SimulationState
	var runtime := ui.get("runtime_session") as LiveGameRuntimeV2
	if not _check(state != null and runtime != null and runtime.owner.state == state,
		"P3.2 is not bound to one authoritative runtime state"):
		return
	for i in range(6):
		var recruit := _recruit_one(880100+i)
		if not _check(recruit != null and DiscipleRealmProgressV2.progression_ready(recruit),
			"could not recruit six authentic, available V2 disciples"):
			return
		ids.append(recruit.id)
	ui.call("_open_disciple",ids[0])
	var enter := ui.get_node_or_null("DiscipleSummaryPanel/SummaryCampHunt") as Button
	if not _check(enter != null and enter.visible and not enter.disabled,
		"the selected real disciple has no active Thanh Trúc Lâm entry command"):
		return
	enter.emit_signal("pressed")
	await process_frame
	var encounter := HuntingPveRunV2.active_multicamp_id(state)
	var restored := HuntingPveRunV2.resume_active(state,encounter)
	if not _check(not encounter.is_empty() and bool(restored.get("ok",false)),
		"entry did not create a restorable live C01 run"):
		return
	var session: HuntingPveRunV2 = restored["session"]
	var battle: MapBattleV2 = session.battle
	if not _check(battle.active and battle.continuous_mode
		and battle._count_monster_records() == 10 and battle._count_alive("monster") == 10
		and battle._count_alive("disciple") == 6,
		"C01 is not six real disciples against ten live Combat V2 monsters"):
		return
	for id in ids:
		if not _check(battle.actors.has(str(id)) and state.disciples[id].active_pve_encounter_id == encounter,
			"a real disciple is missing or not reserved in the canonical active hunt"):
			return
	var arena := ui.get_node("B3MainHuntShade/B3MainHuntPanel/B3MainHuntArena") as Control
	var map := arena.get_node_or_null("PveLiveWorldMapV1") as PveLiveWorldMapV1
	var combat_view := ui.get_node("B3MainHuntShade/B3MainHuntPanel/B3MainHuntFactsPanel/B3PveCombatV5View") as Control
	if not _check(bool(ui.get_node("B3MainHuntShade").visible) and bool(arena.visible)
		and map != null and map.visible and combat_view.visible,
		"the main P3.2 hunt view did not show live map, minimap and Combat V5 view together"):
		return
	if not _check(PveMultiCampPopulationV1.CAMP_COUNT == 20
		and PveMultiCampPopulationV1.verify_structure(session.camp_population).is_empty()
		and session.camp_population["camps"].size() == 20
		and session.camp_population["slots"].size() == 200,
		"map sites do not come from the real persisted 20-camp world model"):
		return
	if not _check(map.battle == combat_view.presenter.battle and map.battle.encounter_id == encounter,
		"map and V5 presenter do not read the same authoritative Combat V2 snapshot"):
		return
	if not _check(map.minimap_rect().position.x > map.size.x-200.0
		and map.minimap_rect().position.y < 12.0,
		"minimap is not fixed to the viewport corner"):
		return
	map.camera_zoom = 1.7
	var center_before := map.camera_center
	map._gui_input(_make_minimap_click(map,_camp_minimap_position(map,19)))
	if not _check(map.camera_center.distance_to(center_before) > 1.0
		and map.selected_camp_index == 0,
		"minimap did not pan the free camera without changing world/gameplay selection"):
		return
	var zoom_before := map.camera_zoom
	map._zoom_at(map.map_rect().get_center(),1.12)
	if not _check(map.camera_zoom > zoom_before and map.camera_zoom <= 3.2,
		"map zoom control did not update camera presentation"):
		return
	var before_positions: Dictionary = battle.summary()["positions"]
	var before_actions := battle.actions
	var start_wall := int(state.runtime_last_wall_unix)
	for _second in range(7):
		await create_timer(1.0).timeout
		var now := int(Time.get_unix_time_from_system())
		var progressed := runtime.poll(now)
		if not _check(bool(progressed.get("ok",false)),
			"shared runtime clock failed during the visible C01 battle: %s" % str(progressed)):
			return
		if _second == 1 and not OS.get_environment(GUI_CAPTURE_ENV).is_empty():
			var capture_run := HuntingPveRunV2.resume_active(state,encounter)
			if not _check(bool(capture_run.get("ok",false)),"GUI capture could not refresh the live fight"):
				return
			var capture_battle: MapBattleV2 = capture_run["session"].battle
			if not _check(capture_battle._count_alive("disciple") == 6
				and capture_battle._count_alive("monster") >= 1
				and capture_battle.actions > 0,
				"GUI capture point does not show six live disciples actively fighting real monsters"):
				return
			# Restore the camera to the live C01 clearing after the pan/zoom input
			# checks above, then capture the rendered P3.2 window itself.
			map.camera_zoom = 1.0
			map.camera_center = PveMultiCampPopulationV1.camp_position(0)
			map._clamp_camera()
			ui.call("_refresh_multicamp_hunt_panel")
			await process_frame
			await RenderingServer.frame_post_draw
			var capture_path := OS.get_environment(GUI_CAPTURE_ENV)
			DirAccess.make_dir_recursive_absolute(capture_path.get_base_dir())
			var frame := root.get_texture().get_image()
			if not _check(DisplayServer.get_name() != "headless"
				and frame != null and frame.get_size() == Vector2i(1280,720)
				and frame.save_png(capture_path) == OK,
				"could not save actual 1280x720 Godot GUI frame" ):
				return
			print("PVE GUI CAPTURE PASS path=%s sha256=%s size=1280x720 live_party=6 live_monsters=%d actions=%d" % [
				capture_path,FileAccess.get_sha256(capture_path),capture_battle._count_alive("monster"),capture_battle.actions])
	var latest := HuntingPveRunV2.resume_active(state,encounter)
	if not _check(bool(latest.get("ok",false)),"active C01 snapshot failed to restore after runtime progress"):
		return
	session = latest["session"]
	battle = session.battle
	var moved := false
	var positions: Dictionary = battle.summary()["positions"]
	for id in positions.keys():
		if before_positions.has(id) and (positions[id] as Vector2).distance_to(before_positions[id]) > 0.05:
			moved = true
			break
	if not _check(battle.now >= 3.0 and battle.actions > before_actions and moved,
		"same-clock Combat V2 did not move or execute attacks in the live camp"):
		return
	if not _check(state.runtime_last_wall_unix >= start_wall and state.tick >= 0
		and state.sect.b3_hunt.is_empty(),
		"runtime clock was replaced or the B3 CARE world was overwritten"):
		return
	var save_button := ui.get_node("B3MainHuntShade/B3MainHuntPanel/B3MainHuntSave") as Button
	save_button.emit_signal("pressed")
	await process_frame
	var loaded := SaveService.new().load_from_path(SAVE_PATH)
	if not _check(loaded != null and loaded.sect.b3_hunt.is_empty()
		and loaded.sect.v2_pve_active_runs.has(encounter)
		and HuntingPveRunV2.active_multicamp_id(loaded) == encounter,
		"canonical SaveService did not retain the active world after saving"):
		return
	var loaded_run := HuntingPveRunV2.resume_active(loaded,encounter)
	if not _check(bool(loaded_run.get("ok",false)),"saved C01 combat snapshot failed exact Save/Load validation"):
		return
	var loaded_battle: MapBattleV2 = loaded_run["session"].battle
	var expected_run := HuntingPveRunV2.resume_active(state,encounter)
	if not _check(bool(expected_run.get("ok",false)),"runtime fight ended before the active Save/Load comparison"):
		return
	var expected_battle: MapBattleV2 = expected_run["session"].battle
	print("PVE SAVELOAD DIAGNOSTIC active=%s alive_dis=%d dead_monsters=%d actions_saved=%d actions_runtime=%d pending=%d receipts=%d reward_claims=%d"
		% [str(loaded.sect.v2_pve_active_runs.has(encounter)),
		loaded_battle._count_alive("disciple"),10-loaded_battle._count_alive("monster"),
		loaded_battle.actions,expected_battle.actions,loaded_battle.pending_kill_events().size(),
		loaded.sect.v2_pve_settlement_receipts.size(),loaded.sect.v2_pve_reward_claims.size()])
	var disciple_records := 0
	for actor in loaded_battle.actors.values():
		if str(actor.get("side","")) == "disciple":
			disciple_records += 1
	if not _check(loaded_battle._count_monster_records() == 10
		and disciple_records == 6
		and loaded_battle.actions == expected_battle.actions
		and is_equal_approx(loaded_battle.now,expected_battle.now)
		and loaded_battle.pending_kill_events().size() == expected_battle.pending_kill_events().size()
		and loaded.sect.v2_pve_settlement_receipts.is_empty()
		and loaded.sect.v2_pve_reward_claims.is_empty(),
		"Save/Load changed combat or created an unearned duplicate reward"):
		return
	if not keep:
		_remove_save()
	print("PVE MULTICAMP P3.2 LIVE INTEGRATION PASS sha="+str(OS.get_environment("TMB_SOURCE_SHA"))
		+" party=6 real_monsters=10 live_sites=20 reserved=6 shared_clock_seconds=%.2f actions=%d movement=true minimap=live fixed=true camera=pan_zoom save_load=true loot=LOOT_PENDING" % [battle.now,battle.actions])
	_cleanup_ui()
	quit(0)

func _camp_minimap_position(map: PveLiveWorldMapV1, index: int) -> Vector2:
	return map._minimap_world_to_screen(PveMultiCampPopulationV1.camp_position(index))

func _make_minimap_click(map: PveLiveWorldMapV1, position: Vector2) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = position
	return event

func _remove_save() -> void:
	for path in [SAVE_PATH,SAVE_PATH+".bak"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
