extends SceneTree

const SAVE_PATH := "res://outputs/pve_jx_world_20261026/qa_vis01_live_save.json"
const SAVE_PATH_ENV := "TMB_PVE_LIVE_SAVE_PATH"
const KEEP_SAVE_ENV := "TMB_KEEP_PVE_LIVE_SAVE"
const GUI_CAPTURE_ENV := "TMB_PVE_GUI_CAPTURE_PATH"
const FORMATION_CAPTURE_ENV := "TMB_PVE_FORMATION_CAPTURE_PATH"
const RING_CAPTURE_DIR_ENV := "TMB_PVE_RING_CAPTURE_DIR"
const VFX_FIXTURE_ENV := "TMB_PVE_VFX_TEST_SKILL"
const VFX_STYLE_ENV := "TMB_PVE_VFX_STYLE"
const VFX_CAPTURE_WAIT_ENV := "TMB_PVE_VFX_CAPTURE_WAIT"
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
	print("PVE P3.2 INTEGRATION START headless=%s vfx_fixture=%s" % [str(DisplayServer.get_name() == "headless"),str(OS.get_environment(VFX_FIXTURE_ENV) == "1")])
	root.size = Vector2i(1280,720)
	print("PVE P3.2 INPUT_VIEWPORT size=%s" % str(root.size))
	var keep := OS.get_environment(KEEP_SAVE_ENV) == "1"
	var save_path := OS.get_environment(SAVE_PATH_ENV)
	if save_path.is_empty():
		save_path = SAVE_PATH
	ProjectSettings.set_setting("runtime/live_save_path",save_path)
	if not keep:
		_remove_save(save_path)
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(save_path.get_base_dir()))
		var seed_state := SaveService.new().load_from_path(QA_SEED_SAVE)
		if not _check(seed_state != null and seed_state.disciples.size() == 130,
			"canonical 130-disciple endgame QA seed did not validate"):
			return
		seed_state.runtime_last_wall_unix = int(Time.get_unix_time_from_system())
		seed_state.runtime_unconsumed_wall_seconds = 0.0
		if not _check(SaveService.new().save_to_path(seed_state,save_path) == OK,
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
	print("PVE P3.2 INTEGRATION scene_ready disciples=%d" % (ui.get("state") as SimulationState).disciples.size())
	state = ui.get("state") as SimulationState
	var runtime := ui.get("runtime_session") as LiveGameRuntimeV2
	if not _check(state != null and runtime != null and runtime.owner.state == state,
		"P3.2 is not bound to one authoritative runtime state"):
		return
	var perf_probe_path := OS.get_environment("TMB_PVE_PERF_PROBE_PATH").strip_edges()
	if not perf_probe_path.is_empty():
		var perf_probe_script := load("res://tools/qa/pve_playable_perf_probe.gd") as GDScript
		if not _check(perf_probe_script != null,
			"passive QA frame probe script did not load"):
			return
		var perf_probe: Node = perf_probe_script.new()
		perf_probe.call("configure",ui,perf_probe_path,
			OS.get_environment("TMB_PVE_PERF_RUN_ID"),
			OS.get_environment("TMB_PVE_PERF_LOG") == "1")
		ui.add_child(perf_probe)
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
	var vfx_fixture := OS.get_environment(VFX_FIXTURE_ENV) == "1"
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
	var vfx_caster_id := first_id
	if vfx_fixture:
		# Place the visual skill fixture on the actual team's mage slot. The
		# frontline auto-guard policy can otherwise defer its damage skill while
		# it manages the live defensive cooldown. This changes only this isolated
		# QA copy and calls the canonical CombatSkillSystem API.
		vfx_caster_id = StringName(str(selected_party[2].get("disciple_id","")))
		var fixture_disciple: DiscipleState = state.disciples[vfx_caster_id]
		fixture_disciple.cultivation_stage_index = maxi(9,fixture_disciple.cultivation_stage_index)
		if not _check(CombatSkillSystem.new().learn_skill(state,fixture_disciple,&"ngu_kiem_thuat")
			and CombatSkillSystem.new().usable_skills(state,fixture_disciple).has(&"ngu_kiem_thuat"),
			"isolated QA fixture could not learn Ngự Kiếm Thuật through CombatSkillSystem"):
			return
		print("PVE VFX VISUAL FIXTURE enabled=1 disciple=%s role=%s skill=ngu_kiem_thuat source=CombatSkillSystem scope=isolated_endgame_copy production_progression_unchanged=true" % [str(vfx_caster_id),str(selected_party[2].get("role",""))])
	ui.call("_open_disciple",first_id)
	var enter := ui.get_node_or_null("DiscipleSummaryPanel/SummaryCampHunt") as Button
	if not _check(enter != null and enter.visible and not enter.disabled,
		"the selected real disciple lost the legacy Thanh Trúc Lâm entry command"):
		return
	var quick_entry := ui.get_node_or_null("PlayerBottomBar/PveHuntQuickEntry") as Button
	if not _check(quick_entry != null and quick_entry.visible
			and quick_entry.text == "Săn quái / Thanh Trúc Lâm"
			and quick_entry.size.x >= 280.0,
		"the main sect screen does not expose the clear Thanh Trúc Lâm entry"):
		return
	quick_entry.emit_signal("pressed")
	var picker := ui.get_node_or_null("PvePartyPickerShade") as Control
	var picker_start := ui.get_node_or_null("PvePartyPickerShade/PvePartyPicker/PvePartyPickerStart") as Button
	var picker_reasons := ui.get_node_or_null("PvePartyPickerShade/PvePartyPicker/PvePartyEligibilityReasons") as Label
	if not _check(picker != null and picker.visible and picker_start != null
			and not picker_start.disabled and ui.get("pve_party_selected_ids").size() == 6
			and picker_reasons != null and picker_reasons.text.contains("Điều kiện:"),
		"quick entry did not show six selectable healthy/free V2 members and actionable eligibility rules"):
		return
	picker_start.emit_signal("pressed")
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
	print("PVE P3.2 INTEGRATION hunt_started encounter=%s" % encounter)
	var session: HuntingPveRunV2 = restored["session"]
	var battle: MapBattleV2 = session.battle
	if not _check(battle.active and battle.continuous_mode and battle.world_mode
		and battle._count_monster_records() == 10 and battle._count_alive("monster") == 10
		and battle._count_alive("disciple") == 6,
		"the continuous Source A forest world is not six real disciples against ten live Combat V2 monsters"):
		return
	if vfx_fixture:
		var real_swordsman: Dictionary = battle.actors.get(str(vfx_caster_id),{})
		if not _check(real_swordsman.get("skill_loadout",[]).has("ngu_kiem_thuat"),
			"Combat V2 open-world actor did not receive the isolated real skill loadout"):
			return
	for id in ids:
		if not _check(battle.actors.has(str(id)) and state.disciples[id].active_pve_encounter_id == encounter,
			"a real disciple is missing or not reserved in the canonical active hunt"):
			return
	var arena := ui.get_node("B3MainHuntShade/B3MainHuntPanel/B3MainHuntArena") as Control
	var map := arena.get_node_or_null("PveSectWorldViewV1") as PveSectWorldViewV1
	var combat_view := ui.get_node("B3MainHuntShade/B3MainHuntPanel/B3MainHuntFactsPanel/B3PveCombatV5View") as Control
	var facts_panel := ui.get_node("B3MainHuntShade/B3MainHuntPanel/B3MainHuntFactsPanel") as Control
	var world_status := ui.get_node("B3MainHuntShade/B3MainHuntPanel/B3MainHuntFactsPanel/B3MainHuntStatus") as Label
	if not _check(bool(ui.get_node("B3MainHuntShade").visible) and bool(arena.visible)
		and map != null and map.visible and not combat_view.visible
		and map.size.x >= 1200.0 and map.size.y >= 680.0
		and facts_panel.size.x <= 320.0 and facts_panel.size.y <= 120.0
		and world_status != null and world_status.visible
		and map.world != null and map.world.pve_landscape and map.world.art_source_status.get("accepted_count",0) >= 10,
		"the main P3.2 hunt view did not show the near-full-screen Source A world and compact live HUD; shade=%s arena=%s map=%s size=%s status=%s renderer=%s assets=%d combat=%s error=%s" % [
		str(ui.get_node("B3MainHuntShade").visible),str(arena.visible),str(map != null and map.visible),
		str(map.size if map != null else Vector2.ZERO),str(world_status.visible if world_status != null else false),
		map.world.get_class() if map != null and map.world != null else "missing renderer",map.world.art_source_status.get("accepted_count",0) if map != null and map.world != null else -1,
			str(combat_view.visible),map.source_error if map != null else "missing map node"] + "; panel=%s panel_visible=%s mode=%s active_id=%s" % [
		str(ui.get("b3_hunt_panel") != null),str(ui.get("b3_hunt_panel") != null and (ui.get("b3_hunt_panel") as Control).visible),
		str(ui.get("active_hunt_mode")),encounter]):
		return
	if not _check(not world_status.text.contains("LOOT_PENDING")
		and world_status.text.contains("Chiến lợi phẩm: chưa xác nhận"),
		"the live HUD exposed a debug loot placeholder or implied an unverified reward"):
		return
	if not _check(PveMultiCampPopulationV1.CAMP_COUNT == 20
		and PveMultiCampPopulationV1.verify_structure(session.camp_population).is_empty()
		and session.camp_population["camps"].size() == 20
		and session.camp_population["slots"].size() == 200,
		"map sites do not come from the real persisted 20-camp world model"):
		return
	if not _check(map.battle != null and map.battle.encounter_id == encounter
		and map.battle.world_mode and map.battle.actors.size() == battle.actors.size(),
		"Source A isometric view does not read the saved authoritative Combat V2 world snapshot"):
		return
	var production_viewport := ui.get("iso_viewport") as SubViewport
	if not _check(map._viewport.render_target_update_mode == SubViewport.UPDATE_WHEN_VISIBLE
		and production_viewport != null
		and production_viewport.render_target_update_mode == SubViewport.UPDATE_DISABLED,
		"hidden PvE view is still rendered or the production underlay was not frozen while hunting: pve_mode=%d production_mode=%d frozen=%s overlay_open=%s expected_pve=%d expected_production=%d pve_script=%s viewport_path=%s" % [
			map._viewport.render_target_update_mode,
			int(production_viewport.render_target_update_mode) if production_viewport != null else -1,
			str(ui.get("production_underlay_frozen")),str(ui.call("_pve_hunt_overlay_is_open")),
			int(SubViewport.UPDATE_WHEN_VISIBLE),int(SubViewport.UPDATE_DISABLED),
			str(map.get_script().resource_path),str(map._viewport.get_path())]):
		return
	var selected_for_ring_test: Array[String] = []
	for selected_id in ids:
		selected_for_ring_test.append(str(selected_id))
	map.selected_actor_ids = selected_for_ring_test.duplicate()
	map.world.pve_selected_actor_ids = selected_for_ring_test.duplicate()
	for zoom in [0.80,1.35]:
		map.camera_zoom = zoom
		map._clamp_camera()
		map.world.queue_redraw()
		map._queue_overlay_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		var actor_draw_scale := map.world.pve_actor_draw_scale()
		if not _check(actor_draw_scale <= 0.82 and actor_draw_scale > 0.0
				and (zoom <= 1.0 or is_equal_approx(actor_draw_scale,0.82)),
			"Source A actor screen size was not capped at close zoom %.2f; scale=%.3f" % [zoom,actor_draw_scale]):
			return
		print("PVE ACTOR SCREEN SCALE PASS zoom=%.2f actor_draw_scale=%.3f cap=0.82" % [zoom,actor_draw_scale])
		var centers: Array[Vector2] = []
		var radii: Array[float] = []
		for selected_id in selected_for_ring_test:
			var member: Dictionary = battle.actors.get(selected_id,{})
			if str(member.get("side","")) != "disciple" or float(member.get("hp",0.0)) <= 0.0:
				continue
			var visual_cell: Vector2 = map._render_positions.get(selected_id,member.get("position",Vector2.ZERO))
			centers.append(map.world_to_screen(visual_cell))
			radii.append(map.world.selected_actor_ring_radius_screen(selected_id))
		var minimum_ring_gap := INF
		for first in range(centers.size()):
			if radii[first] <= 0.0:
				minimum_ring_gap = -INF
				break
			for second in range(first+1,centers.size()):
				minimum_ring_gap = minf(minimum_ring_gap,centers[first].distance_to(centers[second])-radii[first]-radii[second]-1.5)
		if not _check(centers.size() == 6 and minimum_ring_gap >= 3.5,
			"selected circles touch at zoom %.2f; visible=%d min_edge_gap=%.2f px" % [zoom,centers.size(),minimum_ring_gap]):
			return
		print("PVE SELECTION RING GAP PASS zoom=%.2f visible=%d min_edge_gap_px=%.2f" % [zoom,centers.size(),minimum_ring_gap])
		var ring_capture_dir := OS.get_environment(RING_CAPTURE_DIR_ENV).strip_edges()
		if not ring_capture_dir.is_empty():
			DirAccess.make_dir_recursive_absolute(ring_capture_dir)
			var ring_capture_path := ring_capture_dir.path_join("pve_selection_rings_zoom_%03d.png" % roundi(zoom*100.0))
			var ring_frame := root.get_texture().get_image()
			var ring_save_error := ring_frame.save_png(ring_capture_path) if ring_frame != null else ERR_UNAVAILABLE
			if not _check(ring_frame != null and ring_frame.get_size() == Vector2i(1280,720)
				and ring_save_error == OK,
				"could not capture the measured selection-ring layout at zoom %.2f" % zoom):
				return
			print("PVE SELECTION RING IMAGE PASS zoom=%.2f size=1280x720 path=%s sha256=%s" % [
				zoom,ring_capture_path,FileAccess.get_sha256(ring_capture_path)])
	var path_actor: Dictionary = battle.actors.get(str(ids[0]),{})
	var path_start: Vector2 = path_actor.get("position",Vector2.ZERO)
	var path_goal: Vector2 = map.topology["camp_positions"][1]
	var first_cached_path := battle._world_path(path_start,path_goal)
	var cache_hits_before := battle.performance_world_path_cache_hit_count
	var second_cached_path := battle._world_path(path_start,path_goal)
	if not _check(not first_cached_path.is_empty() and first_cached_path == second_cached_path
		and battle.performance_world_path_cache_hit_count == cache_hits_before+1,
		"bounded path cache changed the deterministic route or missed an identical navigation query"):
		return
	print("PVE PATH CACHE PASS path_cells=%d cache_hits=%d deterministic=true" % [first_cached_path.size(),battle.performance_world_path_cache_hit_count])
	var source_a_rows: Dictionary = ui.call("_b3_hunt_visual_rows",battle)
	for disciple_id in ids:
		var visual_key := str(source_a_rows.get(str(disciple_id),{}).get("source_a_visual_key",""))
		if not _check(visual_key in ["disciple_male","disciple_female"]
			and map.source_a_atlas.has_actor(visual_key)
			and not map.source_a_atlas.frame_region(visual_key,"walk",Vector2.RIGHT,0.0).is_empty()
			and not map.source_a_atlas.frame_region(visual_key,"attack",Vector2.RIGHT,0.0).is_empty(),
			"real V2 disciple did not resolve to a verified animated Source A actor for the open world: "+str(disciple_id)):
			return
	if not _check(map.minimap_rect().position.x >= map.size.x-170.0
		and map.minimap_rect().position.y == 10.0,
		"minimap is not fixed to the viewport corner"):
		return
	if not _check(map.topology.get("camp_positions",[]).size() == 20
		and map.topology.get("slot_positions",{}).size() == 200,
		"the 20 spawn zones are not attached to the same continuous world topology"):
		return
	var cached_navigation_sha := str(map.world.pve_navigation.get("source_blob_sha",""))
	var cached_minimap_id := map.world.pve_mini_texture.get_instance_id() if map.world.pve_mini_texture != null else 0
	for _refresh in range(80):
		var prepared := map.prepare_world()
		if not _check(bool(prepared.get("ok",false)),"cached Source A world could not be reused on HUD refresh"):
			return
	if not _check(map.topology_build_count == 1 and map.minimap_build_count == 0
		and map.world.pve_navigation.get("source_blob_sha","") == cached_navigation_sha
		and map.world.pve_mini_texture != null and map.world.pve_mini_texture.get_instance_id() == cached_minimap_id,
		"repeated HUD refresh rebuilt static Source A topology/minimap data; topology_builds=%d minimap_builds=%d calls=%d" % [
		map.topology_build_count,map.minimap_build_count,map.prepare_world_call_count]):
		return
	print("PVE WORLD VIEW CACHE PASS prepare_calls=%d topology_builds=%d minimap_builds=%d source_sha=%s" % [
		map.prepare_world_call_count,map.topology_build_count,map.minimap_build_count,cached_navigation_sha])
	var layout_apply_count_before := int(ui.get("b3_hunt_layout_apply_count"))
	ui.call("_refresh_multicamp_hunt_panel")
	if not _check(int(ui.get("b3_hunt_layout_apply_count")) == layout_apply_count_before,
		"steady PVE HUD refresh reapplied identical full-screen control layouts"):
		return
	print("PVE HUD LAYOUT CACHE PASS apply_count=%d stable_viewport=1280x720" % [layout_apply_count_before])
	map.camera_zoom = 0.70
	var center_before := map.camera_center
	map._gui_input(_make_minimap_click(map,map.minimap_world_to_screen(map.topology["camp_positions"][19])))
	if not _check(map.camera_center.distance_to(center_before) > 1.0
		and session.camp_index == 0,
		"minimap did not pan the free camera without changing world/gameplay zone"):
		return
	var zoom_before := map.camera_zoom
	var wheel_point := map.map_rect().get_center()+Vector2(120.0,-24.0)
	var anchor_before := map.world.pve_screen_to_cell(wheel_point,map.size)
	_route_mouse_motion(map, wheel_point)
	await process_frame
	_route_mouse_button(map, MOUSE_BUTTON_WHEEL_UP, wheel_point, true)
	await process_frame
	var zoomed_in := map.camera_zoom
	var anchor_after_in := map.world.pve_screen_to_cell(wheel_point,map.size)
	if not _check(zoomed_in > zoom_before and zoomed_in <= PveSectWorldViewV1.MAX_ZOOM
		and anchor_before.distance_to(anchor_after_in) < 0.03,
		"viewport-routed mouse wheel up failed: zoom %.3f->%.3f anchor_delta=%.4f map_size=%s" % [
			zoom_before,zoomed_in,anchor_before.distance_to(anchor_after_in),str(map.size)]):
		return
	_route_mouse_motion(map, wheel_point)
	await process_frame
	_route_mouse_button(map, MOUSE_BUTTON_WHEEL_DOWN, wheel_point, true)
	await process_frame
	var zoomed_out := map.camera_zoom
	var anchor_after_out := map.world.pve_screen_to_cell(wheel_point,map.size)
	if not _check(zoomed_out < zoomed_in and absf(zoomed_out-zoom_before) < 0.002
		and anchor_before.distance_to(anchor_after_out) < 0.03,
		"viewport-routed mouse wheel down did not restore zoom and keep the world anchor"):
		return
	var zoom_in_button := map.get_node_or_null("PveWorldZoomIn") as Button
	var zoom_out_button := map.get_node_or_null("PveWorldZoomOut") as Button
	if not _check(zoom_in_button != null and zoom_out_button != null
		and zoom_in_button.is_visible_in_tree() and zoom_out_button.is_visible_in_tree()
		and zoom_in_button.get_global_rect().size.x >= 44.0
		and zoom_out_button.get_global_rect().size.y >= 44.0,
		"the mouse/touch-friendly plus/minus zoom controls are missing or too small"):
		return
	var plus_screen := zoom_in_button.get_global_rect().get_center()
	_route_mouse_motion(map, plus_screen, true)
	await process_frame
	_route_mouse_button(map, MOUSE_BUTTON_LEFT, plus_screen, true, true)
	_route_mouse_button(map, MOUSE_BUTTON_LEFT, plus_screen, false, true)
	await process_frame
	if not _check(map.camera_zoom > zoom_before,
		"clicking the visible plus button through the viewport did not zoom in"):
		return
	var minus_screen := zoom_out_button.get_global_rect().get_center()
	_route_mouse_motion(map, minus_screen, true)
	await process_frame
	_route_mouse_button(map, MOUSE_BUTTON_LEFT, minus_screen, true, true)
	_route_mouse_button(map, MOUSE_BUTTON_LEFT, minus_screen, false, true)
	await process_frame
	if not _check(absf(map.camera_zoom-zoom_before) < 0.002,
		"clicking the visible minus button through the viewport did not zoom out"):
		return
	var refreshed_zoom := map.camera_zoom
	var refreshed_center := map.camera_center
	ui.call("_refresh_multicamp_hunt_panel")
	await process_frame
	if not _check(absf(map.camera_zoom-refreshed_zoom) < 0.0001
		and map.camera_center.distance_to(refreshed_center) < 0.0001,
		"the once-per-second PvE HUD/snapshot refresh reset the user's camera zoom or center"):
		return
	print("PVE WORLD VIEW INPUT PASS wheel_up_down=1 anchor_stable=1 hud_plus_minus=1 refresh_keeps_camera=1 zoom=%.3f" % map.camera_zoom)
	map.camera_center = map.topology["camp_positions"][0]
	map.camera_zoom = 0.70
	var target_run := HuntingPveRunV2.resume_active(state,encounter)
	if not _check(bool(target_run.get("ok",false)),"world could not refresh its snapshot before click-to-move verification"):
		return
	session = target_run["session"]
	battle = session.battle
	map.show_authority_snapshot(battle,session.camp_population,session.camp_index,state.disciples,source_a_rows)
	if not vfx_fixture:
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
		var ordered_slots_by_actor: Dictionary = {}
		for event in battle.events:
			if str(event.get("type","")) != "move_order":
				continue
			var actor_id := str(event.get("actor_id",""))
			if ids.has(StringName(actor_id)):
				ordered_actor_ids[actor_id] = true
				ordered_slots_by_actor[actor_id] = event.get("position",Vector2.ZERO)
		ordered_count = ordered_actor_ids.size()
		var unique_slots: Dictionary = {}
		var minimum_slot_distance := INF
		var formation_positions: Array[Vector2] = []
		for slot in ordered_slots_by_actor.values():
			var slot_position: Vector2 = slot
			formation_positions.append(slot_position)
			unique_slots[Vector2i(roundi(slot_position.x),roundi(slot_position.y))] = true
		for first in range(formation_positions.size()):
			for second in range(first+1,formation_positions.size()):
				minimum_slot_distance = minf(minimum_slot_distance,
					formation_positions[first].distance_to(formation_positions[second]))
		print("PVE P3.2 INTEGRATION movement_slots positions=%s" % str(ordered_slots_by_actor))
		for actor_id in battle.actors:
			var actor: Dictionary = battle.actors[actor_id]
			if str(actor.get("side","")) != "disciple":
				continue
			if ordered_actor_ids.has(str(actor_id)) and move_origin_positions.has(str(actor_id)):
				var path := battle._world_path(move_origin_positions[str(actor_id)],move_target)
				if path.size() > 1:
					path_around_terrain = true
		if not _check(ordered_count == 6 and unique_slots.size() == 6
			and minimum_slot_distance >= 2.5 and path_around_terrain,
				"clicking open ground did not issue six spaced saved pathfinding orders through the Source A forest obstacle grid; orders=%d slots=%d min_spacing=%.2f selected=%s alive=%d target=%s" % [
				ordered_count,unique_slots.size(),minimum_slot_distance,str(map.selected_actor_ids),battle._count_alive("disciple"),str(move_target)]):
			return
		print("PVE P3.2 INTEGRATION movement_verified orders=%d formation_slots=%d min_spacing=%.2f" % [
			ordered_count,unique_slots.size(),minimum_slot_distance])
	else:
		var move_target := _find_c01_ground_target(map,battle,2.5)
		if not _check(move_target.x >= 0.0,"VFX capture could not find open ground for the six-member formation order"):
			return
		map._select_or_move(map.world_to_screen(move_target),false)
		var formation_run := HuntingPveRunV2.resume_active(state,encounter)
		if not _check(bool(formation_run.get("ok",false)),"VFX capture formation order could not restore the canonical world"):
			return
		session = formation_run["session"]
		battle = session.battle
		var slots_by_actor: Dictionary = {}
		for event in battle.events:
			if str(event.get("type","")) != "move_order":
				continue
			var ordered_id := str(event.get("actor_id",""))
			if ids.has(StringName(ordered_id)):
				slots_by_actor[ordered_id] = event.get("position",Vector2.ZERO)
		var unique_slots: Dictionary = {}
		var visual_formation_positions: Array[Vector2] = []
		for slot in slots_by_actor.values():
			var slot_position: Vector2 = slot
			visual_formation_positions.append(slot_position)
			unique_slots[Vector2i(roundi(slot_position.x),roundi(slot_position.y))] = true
		var minimum_visual_spacing := INF
		for first in range(visual_formation_positions.size()):
			for second in range(first+1,visual_formation_positions.size()):
				minimum_visual_spacing = minf(minimum_visual_spacing,
					visual_formation_positions[first].distance_to(visual_formation_positions[second]))
		if not _check(slots_by_actor.size() == 6 and unique_slots.size() == 6 and minimum_visual_spacing >= 2.5,
			"the real six-disciple move command did not create six spaced walkable formation slots; actors=%d slots=%d min_spacing=%.2f" % [
			slots_by_actor.size(),unique_slots.size(),minimum_visual_spacing]):
			return
		print("PVE P3.2 INTEGRATION movement_verified orders=%d formation_slots=%d min_spacing=%.2f" % [
			slots_by_actor.size(),unique_slots.size(),minimum_visual_spacing])
		var formation_capture_path := OS.get_environment(FORMATION_CAPTURE_ENV)
		if not formation_capture_path.is_empty():
			DirAccess.make_dir_recursive_absolute(formation_capture_path.get_base_dir())
			map.world.queue_redraw()
			map._queue_overlay_redraw()
			await process_frame
			await RenderingServer.frame_post_draw
			var formation_frame := root.get_texture().get_image()
			var formation_size := formation_frame.get_size() if formation_frame != null else Vector2i.ZERO
			var formation_save_result := ERR_UNAVAILABLE
			if formation_frame != null:
				formation_save_result = formation_frame.save_png(formation_capture_path)
			if not _check(formation_frame != null and formation_frame.get_size() == Vector2i(1280,720)
				and battle._count_alive("disciple") == 6 and battle._count_monster_records() == 10
				and battle._count_alive("monster") >= 1
				and formation_save_result == OK,
				"could not capture 1280x720 gameplay after the real six-slot move order; size=%s party=%d monster_records=%d alive_monsters=%d save_error=%s" % [
				str(formation_size),battle._count_alive("disciple"),battle._count_monster_records(),battle._count_alive("monster"),error_string(formation_save_result)]):
				return
			print("PVE GUI FORMATION CAPTURE PASS path=%s sha256=%s size=1280x720 party=6 monster_records=10 alive_monsters=%d slots=%d min_spacing=%.2f" % [
				formation_capture_path,FileAccess.get_sha256(formation_capture_path),battle._count_alive("monster"),unique_slots.size(),minimum_visual_spacing])
	var before_positions: Dictionary = {}
	var before_actions := 0
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
		var save_wait_frames := 0
		var save_wait_started_msec := Time.get_ticks_msec()
		while (bool(ui.get("runtime_poll_pending")) or save_button.disabled) \
				and Time.get_ticks_msec()-save_wait_started_msec < 15000:
			await process_frame
			save_wait_frames += 1
		if not _check(not bool(ui.get("runtime_poll_pending")) and not save_button.disabled,
			"normal PvE Save button did not finish its async durability barrier within 15s; frames=%d pending=%s disabled=%s save_worker=%s write_blocked=%s" % [
				save_wait_frames,str(bool(ui.get("runtime_poll_pending"))),str(save_button.disabled),
				str(runtime.owner.saves.has_async_save_pending()),str(runtime.owner.runtime_write_blocked)]):
			return
	else:
		# The normal button polls wall time first; during a slow GUI asset load
		# that legitimately catches up and may settle this low-level QA party
		# before a frame can be photographed. Save through the canonical runtime
		# owner so its live session snapshot is refreshed before SaveService writes.
		# The preceding movement can have queued an async checkpoint; finish that
		# durability barrier before the owner starts another write.
		var prior_gui_save: Dictionary = await runtime.owner.saves.wait_for_async_save(self)
		if not _check(bool(prior_gui_save.get("ok",false))
				and not bool(prior_gui_save.get("pending",false)),
			"runtime-owned async SaveService barrier did not finish before the GUI checkpoint"):
			return
		var gui_checkpoint: Dictionary = runtime.owner.save_to_path(save_path,start_wall)
		if not _check(bool(gui_checkpoint.get("ok",false)),
			"canonical SaveService could not checkpoint the active GUI world"):
			return
	var loaded := SaveService.new().load_from_path(save_path)
	if not _check(loaded != null and loaded.sect.b3_hunt.is_empty()
		and loaded.sect.v2_pve_active_runs.has(encounter)
		and HuntingPveRunV2.active_multicamp_id(loaded) == encounter,
		"canonical SaveService did not retain the active world after saving"):
		return
	var loaded_run := HuntingPveRunV2.resume_active(loaded,encounter)
	if not _check(bool(loaded_run.get("ok",false)),"saved active world did not pass Save/Load validation"):
		return
	print("PVE P3.2 INTEGRATION active_save_load_verified")
	var loaded_battle: MapBattleV2 = loaded_run["session"].battle
	print("PVE P3.2 INTEGRATION save_load_snapshot_ready")
	var expected_run := HuntingPveRunV2.resume_active(state,encounter)
	if not _check(bool(expected_run.get("ok",false)),"runtime fight ended before the active Save/Load comparison"):
		return
	print("PVE P3.2 INTEGRATION in_memory_snapshot_ready")
	var expected_battle: MapBattleV2 = expected_run["session"].battle
	var saved_battle_actions := expected_battle.actions
	var saved_battle_now := expected_battle.now
	var saved_pending_kill_count := expected_battle.pending_kill_events().size()
	var gui_captured := false
	if not OS.get_environment(GUI_CAPTURE_ENV).is_empty():
		var visual_session: HuntingPveRunV2 = expected_run["session"]
		var capture_battle: MapBattleV2 = visual_session.battle
		var saw_visual_cast := false
		var saw_visual_positive_hit := false
		var vfx_capture_mode := OS.get_environment(VFX_FIXTURE_ENV) == "1"
		var requested_style := "hybrid"
		if vfx_capture_mode:
			requested_style = OS.get_environment(VFX_STYLE_ENV)
			if requested_style.is_empty():
				requested_style = "hybrid"
			if not _check(["source_a","jx1","hybrid","all"].has(requested_style),
				"unknown comparison style: "+requested_style):
				return
			map.world.pve_jx_sword_vfx.comparison_style = "hybrid" if requested_style == "all" else requested_style
		map.camera_zoom = 1.35
		map.camera_center = map.topology["camp_positions"][int(envelope_for_capture(state,encounter).get("camp_index",0))]
		map._clamp_camera()
		ui.call("_refresh_multicamp_hunt_panel")
		# Advance capture on the ONE canonical runtime clock. Advancing the
		# view's HuntingPveRun directly would commit Combat V2 frames without
		# consuming wall seconds or minute_phase.
		var visual_wall_start := int(state.runtime_last_wall_unix)
		var visual_battle_start := capture_battle.now
		var impact_frame_image: Image = null
		var impact_capture_froze_world := false
		for _visual_step in range(30):
			if capture_battle._count_alive("disciple") <= 0:
				break
			if not vfx_capture_mode and capture_battle.actions > 0:
				break
			if vfx_capture_mode:
				for event in capture_battle.events:
					if str(event.get("type","")) == "skill_cast" and str(event.get("skill_id","")) == "ngu_kiem_thuat":
						saw_visual_cast = true
					if (str(event.get("type","")) == "hit" and str(event.get("kind","")) == "learned_skill"
						and str(event.get("attacker","")) == str(vfx_caster_id) and float(event.get("damage",0.0)) > 0.0):
						saw_visual_positive_hit = true
				if saw_visual_cast and saw_visual_positive_hit:
					map.show_authority_snapshot(capture_battle,visual_session.camp_population,
						visual_session.camp_index,state.disciples,source_a_rows)
					var impact_wait_frames := 0
					while int(map.world.pve_jx_sword_vfx.counters.get("impacts",0)) == 0 \
							and impact_wait_frames < 90:
						await process_frame
						impact_wait_frames += 1
					var impact_cues: Array[Dictionary] = map.world.pve_jx_sword_vfx.render_cues()
					var impact_cue_found := false
					var impact_region_ok := false
					var impact_on_map := false
					for cue in impact_cues:
						if str(cue.get("phase","")) != "impact":
							continue
						impact_cue_found = true
						impact_region_ok = not map.world.pve_jx_sword_vfx.atlas.frame_region(
							str(cue.get("effect","")),float(cue.get("elapsed",0.0))).is_empty()
						var impact_point := map.world_to_screen(cue.get("at",Vector2.ZERO))
						impact_on_map = map.map_rect().has_point(impact_point) \
							and not map.minimap_rect().has_point(impact_point)
						if impact_cue_found and impact_region_ok and impact_on_map:
							map.world.set_process(false)
							impact_capture_froze_world = true
							map.world.queue_redraw()
							map._queue_overlay_redraw()
							await process_frame
							await RenderingServer.frame_post_draw
							impact_frame_image = root.get_texture().get_image()
					if not _check(impact_cue_found and impact_region_ok and impact_on_map
							and impact_frame_image != null
							and impact_frame_image.get_size() == Vector2i(1280,720),
						"JX #158 impact did not remain drawable and onscreen for a real GUI frame; waits=%d cues=%d atlas=%s on_map=%s impacts=%d" % [
							impact_wait_frames,impact_cues.size(),str(impact_region_ok),str(impact_on_map),
							int(map.world.pve_jx_sword_vfx.counters.get("impacts",0))]):
						return
					print("PVE JX IMPACT DRAW PASS wait_frames=%d cues=%d atlas_region=%s on_map=%s screenshot=1280x720" % [
						impact_wait_frames,impact_cues.size(),str(impact_region_ok),str(impact_on_map)])
					break
			var visual_wall_target := int(state.runtime_last_wall_unix)+1
			var visual_step := runtime.poll(visual_wall_target)
			var visual_drain_cycles := 0
			while true:
				if not _check(bool(visual_step.get("ok",false))
						and (bool(visual_step.get("barrier",false))
							or int(visual_step.get("frames_run",0)) > 0),
						"canonical PvE owner could not advance visible combat: %s" % str(visual_step)):
					return
				if bool(visual_step.get("barrier",false)):
					# Real combat can kill during a visual step; that frame correctly
					# stops at the exactly-once SaveService barrier. Let the canonical
					# async checkpoint finish before consuming this wall tick's backlog.
					var visual_barrier_save: Dictionary = await runtime.owner.saves.wait_for_async_save(self)
					if not _check(bool(visual_barrier_save.get("ok",false))
							and not bool(visual_barrier_save.get("pending",false)),
						"exactly-once visual combat barrier did not finish its async save"):
						return
				if not bool(visual_step.get("backlog_pending",false)):
					break
				visual_drain_cycles += 1
				if not _check(visual_drain_cycles <= 64,
					"visible combat wall tick could not drain its bounded 1s backlog"):
					return
				# Do not add another wall second while the current one still has
				# Combat V2 frames waiting behind an exactly-once barrier.
				visual_step = runtime.poll(visual_wall_target)
			var capture_restored: HuntingPveRunV2 = runtime.owner.get_active_multicamp_session(encounter)
			if not _check(capture_restored != null and capture_restored.battle != null
					and capture_restored.battle.active,
				"live runtime session was unavailable for a visible fighting frame"):
				return
			visual_session = capture_restored
			capture_battle = visual_session.battle
			if vfx_capture_mode:
				# Drive the same read-only snapshot adapter used by the live P3.2 HUD
				# once per simulation step, so cast and hit are not collapsed into a
				# single presentation update by the QA harness.
				map.show_authority_snapshot(capture_battle,visual_session.camp_population,
					visual_session.camp_index,state.disciples,source_a_rows)
		if not _check(is_equal_approx(capture_battle.now-visual_battle_start,
				float(state.runtime_last_wall_unix-visual_wall_start))
				and is_equal_approx(float(state.runtime_unconsumed_wall_seconds),0.0),
			"GUI evidence advanced battle outside canonical owner wall time"):
			return
		var same_wall := int(state.runtime_last_wall_unix)
		var same_battle_now := capture_battle.now
		var same_time_poll := runtime.poll(same_wall)
		var same_time_run: HuntingPveRunV2 = runtime.owner.get_active_multicamp_session(encounter)
		if not _check(bool(same_time_poll.get("ok",false))
				and int(same_time_poll.get("frames_run",0)) == 0
				and same_time_run != null
				and is_equal_approx(same_time_run.battle.now,same_battle_now),
			"same timestamp replayed Combat V2 frames in GUI harness"):
			return
		var post_combat_save: Dictionary = runtime.owner.save_to_path(save_path,same_wall)
		if not _check(bool(post_combat_save.get("ok",false)),
			"canonical SaveService could not persist the post-combat GUI snapshot"):
			return
		var durable_visual_state := SaveService.new().load_from_path(save_path)
		var durable_visual_run := HuntingPveRunV2.resume_active(
			durable_visual_state,encounter) if durable_visual_state != null else {"ok":false}
		if not _check(durable_visual_state != null
				and bool(durable_visual_run.get("ok",false))
				and durable_visual_state.runtime_last_wall_unix == same_wall
				and is_equal_approx(durable_visual_run["session"].battle.now,same_battle_now)
				and is_equal_approx(float(durable_visual_run["session"].minute_phase),
					float(same_time_run.minute_phase)),
			"active PvE SaveService checkpoint disagrees with the shared battle clock"):
			return
		if not _check(capture_battle._count_alive("disciple") >= (1 if vfx_capture_mode else 6)
			and capture_battle._count_alive("monster") >= 1 and capture_battle.actions > 0,
			"first visible Combat V2 frame lacks a living party member or an active monster; party=%d monsters=%d actions=%d now=%.3f" % [
			capture_battle._count_alive("disciple"),capture_battle._count_alive("monster"),capture_battle.actions,capture_battle.now]):
			return
		if vfx_capture_mode and not _check(
			saw_visual_cast and saw_visual_positive_hit
				and int(map.world.pve_jx_sword_vfx.counters.get("positive_hits",0)) > 0
				and int(map.world.pve_jx_sword_vfx.counters.get("impacts",0)) > 0,
			"visual capture did not observe a real Ngự Kiếm Thuật cast, positive Combat V2 damage, and completed JX impact; caster=%s loadout=%s ready=%s cast=%s positive_hit=%s adapter_positive=%d impact=%d now=%.3f alive=%d last_events=%s" % [
				str(vfx_caster_id),
				str(capture_battle.actors.get(str(vfx_caster_id),{}).get("skill_loadout",[])),
				str(capture_battle.actors.get(str(vfx_caster_id),{}).get("skill_ready",{})),
				str(saw_visual_cast),str(saw_visual_positive_hit),
				int(map.world.pve_jx_sword_vfx.counters.get("positive_hits",0)),
				int(map.world.pve_jx_sword_vfx.counters.get("impacts",0)),capture_battle.now,
				capture_battle._count_alive("disciple"),
				str(capture_battle.events.slice(maxi(0,capture_battle.events.size()-12)))
			]):
			return
		print("PVE P3.2 INTEGRATION capture_battle_ready actions=%d now=%.3f" % [capture_battle.actions,capture_battle.now])
		var wait_seconds := float(OS.get_environment(VFX_CAPTURE_WAIT_ENV)) if vfx_capture_mode else 0.0
		var capture_frames := 0
		var capture_path := OS.get_environment(GUI_CAPTURE_ENV)
		DirAccess.make_dir_recursive_absolute(capture_path.get_base_dir())
		var styles_to_capture: Array[String] = []
		if vfx_capture_mode and requested_style == "all":
			styles_to_capture.append("source_a")
			styles_to_capture.append("jx1")
			styles_to_capture.append("hybrid")
		else:
			styles_to_capture.append(requested_style)
		if requested_style == "all":
			# Freeze one rendered Combat V2 snapshot and its view clock so A/B/C
			# frames are pixel captures of the same map, actors and event moment.
			map.world.set_process(false)
		for style in styles_to_capture:
			if vfx_capture_mode:
				map.world.pve_jx_sword_vfx.comparison_style = style
				map.world.queue_redraw()
				map._queue_overlay_redraw()
			var frame: Image
			if vfx_capture_mode and requested_style != "all" and impact_frame_image != null:
				frame = impact_frame_image
			else:
				await process_frame
				await RenderingServer.frame_post_draw
				frame = root.get_texture().get_image()
			var style_capture_path := capture_path
			if requested_style == "all":
				style_capture_path = capture_path.get_basename()+"_"+style+".png"
			if not _check(DisplayServer.get_name() != "headless"
				and frame != null and frame.get_size() == Vector2i(1280,720)
				and frame.save_png(style_capture_path) == OK,
				"could not save actual 1280x720 Godot GUI frame for style="+style):
				return
			map.world._ensure_pve_static_draw_queue()
			var active_vegetation_rows := 0
			for chunk_id in map.world.active_chunks:
				active_vegetation_rows += (map.world.decoration_items_by_chunk.get(chunk_id,[]) as Array).size()
			print("PVE RENDER PERF viewport=%s chunks=%d/144 ground_meshes=%d active_vegetation_rows=%d visible_static=%d live_actors=%d zoom=%.2f" % [
				str(map._viewport.size),map.world.active_chunks.size(),map.world.ground_chunk_meshes.size(),
				active_vegetation_rows,map.world.pve_static_draw_queue.size(),capture_battle.actors.size(),map.camera_zoom])
			print("PVE GUI CAPTURE PASS path=%s sha256=%s size=1280x720 renderer=SectIsometricWorldV1 map=192x192 live_party=%d live_monsters=%d actions=%d style=%s" % [
				style_capture_path,FileAccess.get_sha256(style_capture_path),capture_battle._count_alive("disciple"),capture_battle._count_alive("monster"),capture_battle.actions,style])
		gui_captured = true
		if impact_capture_froze_world and requested_style != "all":
			map.world.set_process(true)
		var capture_start := Time.get_ticks_msec()
		if requested_style == "all":
			map.world.set_process(true)
			map.world.pve_jx_sword_vfx.comparison_style = "hybrid"
		while float(Time.get_ticks_msec()-capture_start)/1000.0 < wait_seconds:
			await process_frame
			capture_frames += 1
		if vfx_capture_mode:
			var measured_seconds := maxf(0.001,float(Time.get_ticks_msec()-capture_start)/1000.0)
			var atlas_counters: Dictionary = map.world.pve_jx_sword_vfx.counters
			print("PVE VFX GUI CAPTURE PASS comparison=%s captured=%s cast_seen=%s positive_hit_seen=%s counters=%s frame_rate_sample=%.2f wait_seconds=%.3f" % [
				requested_style,str(styles_to_capture),str(saw_visual_cast),str(saw_visual_positive_hit),str(atlas_counters),float(capture_frames)/measured_seconds,measured_seconds])
	var loaded_disciple_records := 0
	for actor in loaded_battle.actors.values():
		if str(actor.get("side","")) == "disciple":
			loaded_disciple_records += 1
	if not _check(loaded_battle._count_monster_records() == 10
		and loaded_disciple_records == 6 and loaded_battle._count_alive("disciple") > 0
		and loaded_battle.world_mode and loaded_battle.auto_hunt
		and loaded_battle.actions == saved_battle_actions
		and is_equal_approx(loaded_battle.now,saved_battle_now)
		and loaded_battle.pending_kill_events().size() == saved_pending_kill_count
		and loaded.sect.v2_pve_settlement_receipts.is_empty()
		and loaded.sect.v2_pve_reward_claims.is_empty(),
		"Save/Load changed the active world or created an unearned reward; monster_records=%d living_dis=%d world=%s auto=%s action=%d/%d time=%.3f/%.3f pending=%d/%d receipts=%d claims=%d" % [
		loaded_battle._count_monster_records(),loaded_battle._count_alive("disciple"),str(loaded_battle.world_mode),str(loaded_battle.auto_hunt),
		loaded_battle.actions,saved_battle_actions,loaded_battle.now,saved_battle_now,
		loaded_battle.pending_kill_events().size(),saved_pending_kill_count,
		loaded.sect.v2_pve_settlement_receipts.size(),loaded.sect.v2_pve_reward_claims.size()]):
		return
	var clock_baseline_result := HuntingPveRunV2.resume_active(state,encounter)
	if not _check(bool(clock_baseline_result.get("ok",false)),
		"the active world could not be restored immediately before the shared-clock check"):
		return
	var clock_baseline_session: HuntingPveRunV2 = clock_baseline_result["session"]
	var clock_baseline_battle: MapBattleV2 = clock_baseline_session.battle
	before_positions = clock_baseline_battle.summary()["positions"]
	before_actions = clock_baseline_battle.actions
	var before_clock_now := clock_baseline_battle.now
	var last_progress: Dictionary = {"ok":true}
	var shared_clock_test_steps := 120 if OS.get_environment(GUI_CAPTURE_ENV).is_empty() else 1
	var frame_budget_batches := 0
	var max_frames_in_batch := 0
	var backlog_drain_frames := 0
	var lazy_snapshot_checkpoint_verified := false
	runtime.multicamp_battle_frame_budget = 1
	for _second in range(shared_clock_test_steps):
		if _second % 10 == 0:
			print("PVE P3.2 INTEGRATION shared_clock_step=%d" % _second)
		var now := int(state.runtime_last_wall_unix)+1
		# The real P3.2 _process loop also drains elapsed time. Hold its gate while
		# the harness drives this same canonical async API, so a test poll cannot
		# overlap a second presentation poll against the single runtime/save owner.
		ui.set("runtime_poll_pending",true)
		var snapshot_before_poll: Dictionary = state.sect.v2_pve_active_runs.get(encounter,{})
		var payload_before_poll := str(snapshot_before_poll.get("battle",{}).get("payload",""))
		var live_session_before_poll: HuntingPveRunV2 = runtime.owner.get_active_multicamp_session()
		var battle_time_before_poll := live_session_before_poll.battle.now if live_session_before_poll != null else -1.0
		last_progress = runtime.poll_async(now,-1)
		runtime.multicamp_poll_now_override = now
		if not _check(bool(last_progress.get("ok",false)),
			"shared async runtime clock failed during the visible C01 battle: %s" % str(last_progress)):
			return
		var batch_frames := int(last_progress.get("frames_run",0))
		frame_budget_batches += 1
		max_frames_in_batch = maxi(max_frames_in_batch,batch_frames)
		if not _check(batch_frames <= 1,
			"active Combat V2 runtime exceeded one battle frame per rendered update: %s" % str(last_progress)):
			return
		if not lazy_snapshot_checkpoint_verified and batch_frames > 0 \
				and not bool(last_progress.get("barrier",false)):
			var live_session_after_poll: HuntingPveRunV2 = runtime.owner.get_active_multicamp_session()
			var snapshot_after_poll: Dictionary = state.sect.v2_pve_active_runs.get(encounter,{})
			var payload_after_poll := str(snapshot_after_poll.get("battle",{}).get("payload",""))
			if not _check(live_session_after_poll != null
					and live_session_after_poll.battle.now > battle_time_before_poll
					and not payload_before_poll.is_empty()
					and payload_after_poll == payload_before_poll
					and bool(last_progress.get("runtime_save_deferred",false))
					and not runtime.owner.saves.has_async_save_pending(),
				"ordinary Combat V2 frame rebuilt or wrote a full world snapshot instead of deferring until a durable barrier"):
				return
			lazy_snapshot_checkpoint_verified = true
		var drain_wait := 0
		var drain_wait_started_msec := Time.get_ticks_msec()
		while ((not HuntingPveRunV2.active_multicamp_id(state).is_empty()
				and state.runtime_unconsumed_wall_seconds >= MapBattleV2.STEP_SECONDS)
			or runtime.owner.saves.has_async_save_pending()
			or bool(last_progress.get("runtime_save_pending",false))) \
				and Time.get_ticks_msec()-drain_wait_started_msec < 30000:
			if runtime.owner.saves.has_async_save_pending() or bool(last_progress.get("runtime_save_pending",false)):
				var saved: Dictionary = await runtime.wait_for_pending_save(self)
				if not _check(bool(saved.get("ok",false)),
					"async runtime durability barrier failed while draining one wall second: %s" % str(saved)):
					return
				last_progress["runtime_save_pending"] = false
				continue
			if HuntingPveRunV2.active_multicamp_id(state).is_empty():
				break
			await process_frame
			drain_wait += 1
			backlog_drain_frames += 1
			last_progress = runtime.poll_async(now,-1)
			var drained_frames := int(last_progress.get("frames_run",0))
			max_frames_in_batch = maxi(max_frames_in_batch,drained_frames)
			if not _check(bool(last_progress.get("ok",false)) and drained_frames <= 1,
				"one render update exceeded the async Combat V2 frame budget: %s" % str(last_progress)):
				return
		if not _check(drain_wait == 0 or (Time.get_ticks_msec()-drain_wait_started_msec < 30000
				and (HuntingPveRunV2.active_multicamp_id(state).is_empty()
					or state.runtime_unconsumed_wall_seconds < MapBattleV2.STEP_SECONDS)
				and not runtime.owner.saves.has_async_save_pending()
				and not bool(last_progress.get("runtime_save_pending",false))),
			"one-second Combat V2 backlog failed to drain within 30s; frames=%d remainder=%.3f poll_pending=%s save_pending=%s write_blocked=%s" % [
				drain_wait,float(state.runtime_unconsumed_wall_seconds),str(bool(ui.get("runtime_poll_pending"))),
				str(runtime.owner.saves.has_async_save_pending()),str(runtime.owner.runtime_write_blocked)]):
			return
		ui.set("runtime_poll_pending",false)
		if HuntingPveRunV2.active_multicamp_id(state).is_empty():
			break
	runtime.multicamp_battle_frame_budget = -1
	ui.set("runtime_poll_pending",false)
	runtime.multicamp_poll_now_override = -1
	print("PVE P3.2 INTEGRATION FRAME BUDGET PASS requested=1 max_batch=%d batches=%d drained_render_frames=%d pending=%.3f barrier_saves=authoritative_kill_respawn_zone" % [
		max_frames_in_batch,frame_budget_batches,backlog_drain_frames,float(state.runtime_unconsumed_wall_seconds)])
	print("PVE P3.2 INTEGRATION shared_clock_progress elapsed=%d frames=%d baseline_actions=%d baseline_time=%.3f remainder=%.3f" % [
		int(last_progress.get("elapsed_wall_seconds",0)),int(last_progress.get("frames_run",0)),
		before_actions,before_clock_now,
		float(last_progress.get("remainder_seconds",0.0))])
	print("PVE P3.2 INTEGRATION shared_clock_complete active=%s" % str(not HuntingPveRunV2.active_multicamp_id(state).is_empty()))
	if not OS.get_environment(GUI_CAPTURE_ENV).is_empty():
		pass
	elif not _check(lazy_snapshot_checkpoint_verified,
		"the integrated fight did not produce an ordinary frame with a deferred durable snapshot"):
		return
	if not OS.get_environment(GUI_CAPTURE_ENV).is_empty() and not gui_captured:
		var latest_capture := HuntingPveRunV2.resume_active(state,encounter)
		var live_capture_battle: MapBattleV2 = latest_capture.get("session").battle if bool(latest_capture.get("ok",false)) else null
		var live_capture_minimum := 1 if OS.get_environment(VFX_FIXTURE_ENV) == "1" else 6
		return _check(false,"GUI capture never reached the required living party >=%d with an active attack; party=%d monsters=%d actions=%d battle_now=%.3f active=%s" % [
			live_capture_minimum,
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
		var latest: HuntingPveRunV2 = runtime.owner.get_active_multicamp_session(encounter)
		if not _check(latest != null and latest.battle != null and latest.battle.active,
			"live runtime session was unavailable after shared-clock progress"):
			return
		session = latest
		final_battle = session.battle
		final_kills = int(session.camp_population.get("world_total_kills",0))
		zone_hop = session.camp_index > 0
		var moved := false
		var positions: Dictionary = final_battle.summary()["positions"]
		for id in positions.keys():
			if before_positions.has(id) and (positions[id] as Vector2).distance_to(before_positions[id]) > 0.05:
				moved = true
				break
		var clock_frames := int(last_progress.get("frames_run",0))
		var clock_time_advanced := final_battle.now > before_clock_now + MapBattleV2.STEP_SECONDS * 0.5
		if not _check(clock_frames > 0 and clock_time_advanced
			and (final_battle.actions > before_actions or moved),
			"same-clock Combat V2 stalled: frames=%d actions=%d/%d time=%.3f/%.3f moved=%s poll=%s" % [
			clock_frames,final_battle.actions,before_actions,final_battle.now,before_clock_now,str(moved),str(last_progress)]):
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
		var saved_terminal := runtime.save(int(state.runtime_last_wall_unix))
		if not _check(bool(saved_terminal.get("ok",false)),"SaveService rejected the terminal Injury120 world result"):
			return
		var terminal_loaded := SaveService.new().load_from_path(save_path)
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
	print("PVE P3.2 INTEGRATION clock_and_b3_care_verified")
	if active_after.is_empty():
		var final_receipt: Dictionary = state.sect.v2_pve_settlement_receipts[encounter]
		var final_snapshot := MapBattleSnapshotV2.load(final_receipt.get("battle",{}))
		if bool(final_snapshot.get("ok",false)):
			final_battle = final_snapshot["battle"]
	else:
		final_battle = session.battle
	if not keep:
		_remove_save(save_path)
	var injury120_result := "NOT_REACHED" if not active_after.is_empty() else "PASS"
	var zone_hop_result := "PASS" if zone_hop else "NOT_REACHED"
	print("PVE SOURCE A CONTINUOUS WORLD P3.2 INTEGRATION PASS sha="+str(OS.get_environment("TMB_SOURCE_SHA"))
		+" renderer=SectIsometricWorldV1 map=192x192 zones=20 party=6 real_monsters=10 reserved=6 shared_clock_seconds=%.2f actions=%d path_order=true zone_hop=%s result=%s kills=%d injury120=%s minimap=live camera=pan_zoom active_save_load=true no_duplicate_or_fabricated_rewards=true loot=LOOT_PENDING" % [final_battle.now if final_battle != null else 0.0,final_battle.actions if final_battle != null else 0,zone_hop_result,final_outcome,final_kills,injury120_result])
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

func _find_c01_ground_target(map: PveSectWorldViewV1, battle: MapBattleV2,
		maximum_target_distance: float = 8.0) -> Vector2:
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
			if world.distance_to(center) > maximum_target_distance:
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
				var actor_screen := map.world_to_screen(rendered_position)
				if screen.distance_to(actor_screen) < 26.0:
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

func _make_minimap_click(map: PveSectWorldViewV1, position: Vector2) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = position
	return event

func _route_mouse_motion(map: PveSectWorldViewV1, position: Vector2, is_viewport_position: bool = false) -> void:
	var event := InputEventMouseMotion.new()
	event.position = position if is_viewport_position else map.get_global_transform_with_canvas()*position
	event.global_position = event.position
	Input.parse_input_event(event)

func _route_mouse_button(map: PveSectWorldViewV1, button_index: int, position: Vector2,
		pressed: bool, is_viewport_position: bool = false) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button_index
	event.pressed = pressed
	event.position = position if is_viewport_position else map.get_global_transform_with_canvas()*position
	event.global_position = event.position
	Input.parse_input_event(event)

func _remove_save(save_path: String) -> void:
	for path in [save_path,save_path+".bak"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
