extends SceneTree

const SAVE_PATH := "user://tong_mon_ba_dao_live_v2.json"
const KEEP_SAVE_ENV := "TMB_KEEP_PVE_LIVE_SAVE"
const GUI_CAPTURE_ENV := "TMB_PVE_GUI_CAPTURE_PATH"
const QA_SEED_SAVE := "res://outputs/endgame_qa_20261026/gameplay/roster_130/endgame_capture_save_1792953798.json"

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

func _run() -> void:
	var keep := OS.get_environment(KEEP_SAVE_ENV) == "1"
	ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
	if not keep:
		_remove_save()
		var seed_state := SaveService.new().load_from_path(QA_SEED_SAVE)
		if not _check(seed_state != null and seed_state.disciples.size() == 130,
			"canonical 130-disciple endgame QA seed did not validate"):
			return
		seed_state.runtime_last_wall_unix = int(Time.get_unix_time_from_system())
		seed_state.runtime_unconsumed_wall_seconds = 0.0
		if not _check(SaveService.new().save_to_path(seed_state,SAVE_PATH) == OK,
			"could not stage isolated exact copy of endgame QA seed through SaveService"):
			return
	var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
	if not _check(packed != null,"actual P3.2 scene did not load"):
		return
	ui = packed.instantiate() as Control
	# P3.1 autostarts its wall timer at the end of _ready. Pause the scene tree
	# through the first frame so a slow 130-actor GUI build cannot accumulate a
	# large frame delta and fast-forward the newly opened fight before QA pauses
	# those timers.
	paused = true
	root.add_child(ui)
	for property in ["runtime_poll_timer","autosave_timer"]:
		var timer := ui.get(property) as Timer
		if timer != null:
			# This harness advances the canonical runtime explicitly below. Pause
			# scene timers so GUI frame timing during setup cannot fast-forward the
			# fight before it can be inspected or captured.
			timer.stop()
	paused = false
	await process_frame
	if not _check(bool(ui.get("runtime_ready")),"P3.2 did not start its canonical LiveGameRuntimeV2"):
		return
	state = ui.get("state") as SimulationState
	var runtime := ui.get("runtime_session") as LiveGameRuntimeV2
	if not _check(state != null and runtime != null and runtime.owner.state == state,
		"P3.2 is not bound to one authoritative runtime state"):
		return
	var free_v2_ids: Array = state.disciples.keys()
	free_v2_ids.sort()
	var eligible_ids: Array[StringName] = []
	for raw_id in free_v2_ids:
		var member: DiscipleState = state.disciples[StringName(raw_id)]
		if DiscipleRealmProgressV2.progression_ready(member) and bool(ui.call("_multicamp_member_eligible",member)):
			eligible_ids.append(member.id)
	if not _check(eligible_ids.size() >= 6,
		"130-disciple endgame QA save did not contain six real, free V2 participants; eligible=%d" % eligible_ids.size()):
		return
	var first_id := eligible_ids[0]
	var strongest_rating := float(ui.call("_multicamp_combat_rating",state.disciples[first_id]))
	for candidate_id in eligible_ids:
		var rating := float(ui.call("_multicamp_combat_rating",state.disciples[candidate_id]))
		if rating > strongest_rating:
			strongest_rating = rating
			first_id = candidate_id
	var selected_party: Array = ui.call("_multicamp_party_for_selected",first_id)
	for member_row in selected_party:
		ids.append(StringName(str(member_row.get("disciple_id",""))))
	if not _check(ids.size() == 6,
		"the production strongest-ready team picker did not return six canonical disciples"):
		return
	ui.call("_open_disciple",first_id)
	var enter := ui.get_node_or_null("DiscipleSummaryPanel/SummaryCampHunt") as Button
	if not _check(enter != null and enter.visible and not enter.disabled,
		"the selected real disciple has no active Thanh Trúc Lâm entry command"):
		return
	enter.emit_signal("pressed")
	if not OS.get_environment(GUI_CAPTURE_ENV).is_empty():
		# Freeze elapsed setup time at entry; the game scene is deliberately heavy
		# with its real 130-person roster, while the GUI evidence needs the first
		# Combat V2 seconds rather than replaying QA setup latency as combat.
		state.runtime_last_wall_unix = int(Time.get_unix_time_from_system())
		state.runtime_unconsumed_wall_seconds = 0.0
	await process_frame
	var encounter := HuntingPveRunV2.active_multicamp_id(state)
	var restored := HuntingPveRunV2.resume_active(state,encounter)
	if not _check(not encounter.is_empty() and bool(restored.get("ok",false)),
		"entry did not create a restorable live C01 run"):
		return
	var session: HuntingPveRunV2 = restored["session"]
	var battle: MapBattleV2 = session.battle
	if not _check(battle.active and battle.continuous_mode and battle.world_mode
		and battle._count_monster_records() == 10 and battle._count_alive("monster") == 10
		and battle._count_alive("disciple") == 6,
		"the JX open world is not six real disciples against ten live Combat V2 monsters"):
		return
	for id in ids:
		if not _check(battle.actors.has(str(id)) and state.disciples[id].active_pve_encounter_id == encounter,
			"a real disciple is missing or not reserved in the canonical active hunt"):
			return
	var arena := ui.get_node("B3MainHuntShade/B3MainHuntPanel/B3MainHuntArena") as Control
	var map := arena.get_node_or_null("PveJxContinuousWorldViewV1") as PveJxContinuousWorldViewV1
	var combat_view := ui.get_node("B3MainHuntShade/B3MainHuntPanel/B3MainHuntFactsPanel/B3PveCombatV5View") as Control
	if not _check(bool(ui.get_node("B3MainHuntShade").visible) and bool(arena.visible)
		and map != null and map.visible and not combat_view.visible
		and map.source != null and map.source.verified_files == 44,
		"the main P3.2 hunt view did not show the hash-verified JX map and live minimap; shade=%s arena=%s map=%s source=%s verified=%d combat=%s error=%s" % [
		str(ui.get_node("B3MainHuntShade").visible),str(arena.visible),str(map != null and map.visible),
		str(map != null and map.source != null),map.source.verified_files if map != null and map.source != null else -1,
			str(combat_view.visible),map.source_error if map != null else "missing map node"] + "; panel=%s panel_visible=%s mode=%s active_id=%s" % [
		str(ui.get("b3_hunt_panel") != null),str(ui.get("b3_hunt_panel") != null and (ui.get("b3_hunt_panel") as Control).visible),
		str(ui.get("active_hunt_mode")),encounter]):
		return
	if not _check(PveMultiCampPopulationV1.CAMP_COUNT == 20
		and PveMultiCampPopulationV1.verify_structure(session.camp_population).is_empty()
		and session.camp_population["camps"].size() == 20
		and session.camp_population["slots"].size() == 200,
		"map sites do not come from the real persisted 20-camp world model"):
		return
	if not _check(map.battle != null and map.battle.encounter_id == encounter
		and map.battle.world_mode and map.battle.actors.size() == battle.actors.size(),
		"JX map does not read the saved authoritative Combat V2 world snapshot"):
		return
	var source_a_rows: Dictionary = ui.call("_b3_hunt_visual_rows",battle)
	for disciple_id in ids:
		var visual_key := str(source_a_rows.get(str(disciple_id),{}).get("source_a_visual_key",""))
		if not _check(visual_key in ["disciple_male","disciple_female"]
			and map.source_a_atlas.has_actor(visual_key)
			and not map.source_a_atlas.frame_region(visual_key,"walk",Vector2.RIGHT,0.0).is_empty()
			and not map.source_a_atlas.frame_region(visual_key,"attack",Vector2.RIGHT,0.0).is_empty(),
			"real V2 disciple did not resolve to a verified animated Source A actor for the open world: "+str(disciple_id)):
			return
	if not _check(map.minimap_rect().position.x >= map.size.x-202.0
		and map.minimap_rect().position.y == 12.0,
		"minimap is not fixed to the viewport corner"):
		return
	if not _check(map.topology.get("camp_positions",[]).size() == 20
		and map.topology.get("slot_positions",{}).size() == 200,
		"the 20 spawn zones are not attached to the same continuous world topology"):
		return
	map.camera_zoom = 0.70
	var center_before := map.camera_center
	map._gui_input(_make_minimap_click(map,map.minimap_world_to_screen(map.topology["camp_positions"][19])))
	if not _check(map.camera_center.distance_to(center_before) > 1.0
		and session.camp_index == 0,
		"minimap did not pan the free camera without changing world/gameplay zone"):
		return
	var zoom_before := map.camera_zoom
	map._zoom_at(map.map_rect().get_center(),1.12)
	if not _check(map.camera_zoom > zoom_before and map.camera_zoom <= 1.15,
		"map zoom control did not update camera presentation"):
		return
	map.camera_center = map.topology["camp_positions"][0]
	map.camera_zoom = 0.70
	var target_run := HuntingPveRunV2.resume_active(state,encounter)
	if not _check(bool(target_run.get("ok",false)),"world could not refresh its snapshot before click-to-move verification"):
		return
	session = target_run["session"]
	battle = session.battle
	map.show_authority_snapshot(battle,session.camp_population,session.camp_index,state.disciples,source_a_rows)
	var move_target := _find_c01_ground_target(map,battle)
	if not _check(move_target.x >= 0.0,"no reachable open ground was found inside the real C01 world view"):
		return
	var move_origin_positions: Dictionary = battle.summary()["positions"]
	map._select_or_move(map.world_to_screen(move_target),false)
	var ordered_run := HuntingPveRunV2.resume_active(state,encounter)
	if not _check(bool(ordered_run.get("ok",false)),"move order could not restore the canonical world"):
		return
	session = ordered_run["session"]
	battle = session.battle
	var ordered_count := 0
	var path_around_terrain := false
	var ordered_actor_ids: Dictionary = {}
	for event in battle.events:
		if str(event.get("type","")) != "move_order":
			continue
		var actor_id := str(event.get("actor_id",""))
		if ids.has(StringName(actor_id)):
			ordered_actor_ids[actor_id] = true
	ordered_count = ordered_actor_ids.size()
	for actor_id in battle.actors:
		var actor: Dictionary = battle.actors[actor_id]
		if str(actor.get("side","")) != "disciple":
			continue
		if ordered_actor_ids.has(str(actor_id)) and move_origin_positions.has(str(actor_id)):
			var path := battle._world_path(move_origin_positions[str(actor_id)],move_target)
			if path.size() > 1:
				path_around_terrain = true
	if not _check(ordered_count == 6 and path_around_terrain,
		"clicking open ground did not issue six saved pathfinding orders through the JX collision grid; orders=%d selected=%s alive=%d target=%s" % [
			ordered_count,str(map.selected_actor_ids),battle._count_alive("disciple"),str(move_target)]):
		return
	var before_positions: Dictionary = battle.summary()["positions"]
	var before_actions := battle.actions
	# The GUI harness does synchronous map/asset validation while paused. Mark
	# its current shared-clock baseline before exercising the normal Save button,
	# so test setup time is not replayed as offline combat catch-up.
	var start_wall := int(Time.get_unix_time_from_system())
	state.runtime_last_wall_unix = start_wall
	if not OS.get_environment(GUI_CAPTURE_ENV).is_empty():
		state.runtime_unconsumed_wall_seconds = 0.0
	var warehouse_before: Dictionary = state.sect.warehouse_resources.duplicate(true)
	var save_button := ui.get_node("B3MainHuntShade/B3MainHuntPanel/B3MainHuntSave") as Button
	if OS.get_environment(GUI_CAPTURE_ENV).is_empty():
		save_button.emit_signal("pressed")
		await process_frame
	else:
		# The normal button polls wall time first; during a slow GUI asset load
		# that legitimately catches up and may settle this low-level QA party
		# before a frame can be photographed. Save the exact active state through
		# the same canonical SaveService, then exercise clock progression below.
		if not _check(SaveService.new().save_to_path(state,SAVE_PATH) == OK,
			"canonical SaveService could not checkpoint the active GUI world"):
			return
	var loaded := SaveService.new().load_from_path(SAVE_PATH)
	if not _check(loaded != null and loaded.sect.b3_hunt.is_empty()
		and loaded.sect.v2_pve_active_runs.has(encounter)
		and HuntingPveRunV2.active_multicamp_id(loaded) == encounter,
		"canonical SaveService did not retain the active world after saving"):
		return
	var loaded_run := HuntingPveRunV2.resume_active(loaded,encounter)
	if not _check(bool(loaded_run.get("ok",false)),"saved active world did not pass Save/Load validation"):
		return
	var loaded_battle: MapBattleV2 = loaded_run["session"].battle
	var expected_run := HuntingPveRunV2.resume_active(state,encounter)
	if not _check(bool(expected_run.get("ok",false)),"runtime fight ended before the active Save/Load comparison"):
		return
	var expected_battle: MapBattleV2 = expected_run["session"].battle
	var gui_captured := false
	if not OS.get_environment(GUI_CAPTURE_ENV).is_empty():
		var visual_session: HuntingPveRunV2 = expected_run["session"]
		var capture_battle: MapBattleV2 = visual_session.battle
		for _visual_step in range(50):
			if capture_battle._count_alive("disciple") < 6 or capture_battle.actions > 0:
				break
			var visual_step := visual_session.advance(true)
			if not _check(bool(visual_step.get("ok",false)) and not bool(visual_step.get("barrier",false)),
				"Combat V2 could not produce a visible open-world frame: %s" % str(visual_step)):
				return
			capture_battle = visual_session.battle
		if not _check(capture_battle._count_alive("disciple") == 6
			and capture_battle._count_alive("monster") >= 1 and capture_battle.actions > 0,
			"first visible Combat V2 frame lacks six live disciples or an active monster; party=%d monsters=%d actions=%d now=%.3f" % [
			capture_battle._count_alive("disciple"),capture_battle._count_alive("monster"),capture_battle.actions,capture_battle.now]):
			return
		map.camera_zoom = 0.90
		map.camera_center = map.topology["camp_positions"][int(envelope_for_capture(state,encounter).get("camp_index",0))]
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
			"could not save actual 1280x720 Godot GUI frame"):
			return
		gui_captured = true
		print("PVE GUI CAPTURE PASS path=%s sha256=%s size=1280x720 jx_map=50x100 verified_files=44 live_party=6 live_monsters=%d actions=%d" % [
			capture_path,FileAccess.get_sha256(capture_path),capture_battle._count_alive("monster"),capture_battle.actions])
	var loaded_disciple_records := 0
	for actor in loaded_battle.actors.values():
		if str(actor.get("side","")) == "disciple":
			loaded_disciple_records += 1
	if not _check(loaded_battle._count_monster_records() == 10
		and loaded_disciple_records == 6 and loaded_battle._count_alive("disciple") > 0
		and loaded_battle.world_mode and loaded_battle.auto_hunt
		and loaded_battle.actions == expected_battle.actions
		and is_equal_approx(loaded_battle.now,expected_battle.now)
		and loaded_battle.pending_kill_events().size() == expected_battle.pending_kill_events().size()
		and loaded.sect.v2_pve_settlement_receipts.is_empty()
		and loaded.sect.v2_pve_reward_claims.is_empty(),
		"Save/Load changed the active world or created an unearned reward; monster_records=%d living_dis=%d world=%s auto=%s action=%d/%d time=%.3f/%.3f pending=%d/%d receipts=%d claims=%d" % [
		loaded_battle._count_monster_records(),loaded_battle._count_alive("disciple"),str(loaded_battle.world_mode),str(loaded_battle.auto_hunt),
		loaded_battle.actions,expected_battle.actions,loaded_battle.now,expected_battle.now,
		loaded_battle.pending_kill_events().size(),expected_battle.pending_kill_events().size(),
		loaded.sect.v2_pve_settlement_receipts.size(),loaded.sect.v2_pve_reward_claims.size()]):
		return
	var last_progress: Dictionary = {"ok":true}
	for _second in range(50):
		var now := int(state.runtime_last_wall_unix)+1
		last_progress = runtime.poll(now)
		if not _check(bool(last_progress.get("ok",false)),
			"shared runtime clock failed during the visible C01 battle: %s" % str(last_progress)):
			return
		if HuntingPveRunV2.active_multicamp_id(state).is_empty():
			break
	if not OS.get_environment(GUI_CAPTURE_ENV).is_empty() and not gui_captured:
		var latest_capture := HuntingPveRunV2.resume_active(state,encounter)
		var live_capture_battle: MapBattleV2 = latest_capture.get("session").battle if bool(latest_capture.get("ok",false)) else null
		return _check(false,"GUI capture never reached six living disciples with an active attack; party=%d monsters=%d actions=%d battle_now=%.3f active=%s" % [
			live_capture_battle._count_alive("disciple") if live_capture_battle != null else -1,
			live_capture_battle._count_alive("monster") if live_capture_battle != null else -1,
			live_capture_battle.actions if live_capture_battle != null else -1,
			live_capture_battle.now if live_capture_battle != null else -1.0,
			str(HuntingPveRunV2.active_multicamp_id(state))])
	var active_after := HuntingPveRunV2.active_multicamp_id(state)
	var zone_hop := false
	var final_battle: MapBattleV2
	var final_kills := 0
	var final_outcome := "active"
	if not active_after.is_empty():
		var latest := HuntingPveRunV2.resume_active(state,encounter)
		if not _check(bool(latest.get("ok",false)),"active world snapshot failed to restore after shared-clock progress"):
			return
		session = latest["session"]
		final_battle = session.battle
		final_kills = int(session.camp_population.get("world_total_kills",0))
		zone_hop = session.camp_index > 0
		var moved := false
		var positions: Dictionary = final_battle.summary()["positions"]
		for id in positions.keys():
			if before_positions.has(id) and (positions[id] as Vector2).distance_to(before_positions[id]) > 0.05:
				moved = true
				break
		if not _check(final_battle.actions > before_actions and moved,
			"same-clock Combat V2 did not move or execute attacks in the continuous world"):
			return
	else:
		var receipt: Dictionary = state.sect.v2_pve_settlement_receipts.get(encounter,{})
		final_outcome = str(receipt.get("outcome",""))
		final_kills = int(receipt.get("kills",0))
		zone_hop = str(receipt.get("camp_id","")) != "C01"
		var injury_valid := true
		for id in ids:
			var disciple: DiscipleState = state.disciples[id]
			injury_valid = injury_valid and disciple.region_id == &"sect" and disciple.active_pve_encounter_id.is_empty()
			injury_valid = injury_valid and disciple.injury_level == 1 and disciple.injury_recover_at_tick == state.tick+120
		if not _check(final_outcome == "defeat" and final_kills >= 10 and zone_hop and injury_valid,
			"live combat did not record defeat, cross into another continuous-map region, and return the real V2 team with Injury120; outcome=%s kills=%d camp=%s injury_valid=%s" % [
			final_outcome,final_kills,str(receipt.get("camp_id","")),str(injury_valid)]):
			return
		if not _check(state.sect.v2_pve_reward_claims.is_empty()
			and state.sect.warehouse_resources == warehouse_before,
			"open-world kills created an unapproved Warehouse payout or reward claim"):
			return
		var saved_terminal := runtime.save()
		if not _check(bool(saved_terminal.get("ok",false)),"SaveService rejected the terminal Injury120 world result"):
			return
		var terminal_loaded := SaveService.new().load_from_path(SAVE_PATH)
		if not _check(terminal_loaded != null and terminal_loaded.sect.v2_pve_active_runs.is_empty()
			and terminal_loaded.sect.v2_pve_settlement_receipts.has(encounter)
			and str(terminal_loaded.sect.v2_pve_settlement_receipts[encounter].get("outcome","")) == "defeat"
			and terminal_loaded.sect.v2_pve_reward_claims.is_empty()
			and terminal_loaded.sect.warehouse_resources == warehouse_before,
			"terminal Save/Load duplicated a reward or lost the Injury120 result"):
			return
	if not _check(state.runtime_last_wall_unix >= start_wall and state.sect.b3_hunt.is_empty(),
		"runtime clock was replaced or the B3 CARE world was overwritten"):
		return
	if active_after.is_empty():
		var final_receipt: Dictionary = state.sect.v2_pve_settlement_receipts[encounter]
		var final_snapshot := MapBattleSnapshotV2.load(final_receipt.get("battle",{}))
		if bool(final_snapshot.get("ok",false)):
			final_battle = final_snapshot["battle"]
	else:
		final_battle = session.battle
	if not keep:
		_remove_save()
	print("PVE JX CONTINUOUS WORLD P3.2 INTEGRATION PASS sha="+str(OS.get_environment("TMB_SOURCE_SHA"))
		+" map=50x100 source_hashes=44 zones=20 party=6 real_monsters=10 reserved=6 shared_clock_seconds=%.2f actions=%d path_order=true zone_hop=%s result=%s kills=%d injury120=%s minimap=live camera=pan_zoom active_save_load=true no_duplicate_or_fabricated_rewards=true loot=LOOT_PENDING" % [final_battle.now if final_battle != null else 0.0,final_battle.actions if final_battle != null else 0,str(zone_hop),final_outcome,final_kills,str(active_after.is_empty())])
	_cleanup_ui()
	quit(0)

func _count_respawned_ready_slots(population: Dictionary, camp: int) -> int:
	var ready_count := 0
	for ordinal in range(PveMultiCampPopulationV1.MIN_SLOTS_PER_CAMP):
		var slot: Dictionary = population.get("slots",{}).get(PveMultiCampPopulationV1.slot_id(camp,ordinal),{})
		if str(slot.get("phase","")) == "READY" and int(slot.get("generation",0)) > 1:
			ready_count += 1
	return ready_count

func envelope_for_capture(source_state: SimulationState, encounter_id: String) -> Dictionary:
	return source_state.sect.v2_pve_active_runs.get(encounter_id,{})

func _find_c01_ground_target(map: PveJxContinuousWorldViewV1, battle: MapBattleV2) -> Vector2:
	var center: Vector2 = map.topology["camp_positions"][0]
	var navigation: Dictionary = battle.world_navigation
	var bounds: Rect2 = map.topology["bounds"]
	var best := Vector2(-1.0,-1.0)
	var best_score := -INF
	for y in range(maxi(0,floori(center.y)-8),mini(int(bounds.size.y),ceili(center.y)+8)):
		for x in range(maxi(0,floori(center.x)-8),mini(int(bounds.size.x),ceili(center.x)+8)):
			var cell := Vector2i(x,y)
			if not PveOpenWorldTopologyV1._walkable(navigation,cell):
				continue
			var world := Vector2(x+0.5,y+0.5)
			if world.distance_to(center) > 8.0:
				continue
			var screen := map.world_to_screen(world)
			if not map.map_rect().has_point(screen) or map.minimap_rect().has_point(screen):
				continue
			var distant_from_party := true
			for actor_id in battle.actors:
				var actor: Dictionary = battle.actors[actor_id]
				if str(actor.get("side","")) != "disciple" or float(actor.get("hp",0.0)) <= 0.0:
					continue
				var rendered_position: Vector2 = map._render_positions.get(str(actor_id),actor["position"])
				if world.distance_to(actor["position"]) < 5.0 or world.distance_to(rendered_position) < 5.0:
					distant_from_party = false
					break
			if not distant_from_party:
				continue
			var paths_long_enough := true
			for actor_id in battle.actors:
				var actor: Dictionary = battle.actors[actor_id]
				if str(actor.get("side","")) == "disciple" and float(actor.get("hp",0.0)) > 0.0:
					if battle._world_path(actor["position"],world).size() < 3:
						paths_long_enough = false
						break
			if not paths_long_enough:
				continue
			var score: float = world.distance_to(center)
			if score > best_score:
				best_score = score
				best = world
	return best

func _make_minimap_click(map: PveJxContinuousWorldViewV1, position: Vector2) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = position
	return event

func _remove_save() -> void:
	for path in [SAVE_PATH,SAVE_PATH+".bak"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
