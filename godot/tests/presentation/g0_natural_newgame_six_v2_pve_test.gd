extends SceneTree
## Real New Game -> paid map construction -> B1 Dẫn Tiên -> recruit -> HS-09
## assignment -> Save/Reload. UI events run in Godot; this is not physical mouse QA.
const SAVE_PREFIX := "user://tri03_recruited_hs09_flow_"

var game: Control
var state: SimulationState
var save_path := ""
var capture_dir := ""
var g1_build_request_id := ""
var g1_house_id := ""
var g1_house_site := SectResidenceSiteV1.UNSELECTED
var g1_build_cost: Dictionary = {}
var g1_wood_after := -1
var g1_ore_after := -1
var g1_stones_after := -1

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
    var cli := OS.get_cmdline_user_args()
    if cli.size() >= 2 and str(cli[0]) == "process2":
        save_path = str(cli[1])
        _process2_reload()
        return
    save_path = SAVE_PREFIX + "natural_six_v2_" + str(OS.get_process_id()) + ".json"
    if not save_path.begins_with(SAVE_PREFIX):
        _fail("Natural New Game test save path escaped isolated QA namespace")
        return
    _cleanup_save()
    ProjectSettings.set_setting("runtime/live_save_path",save_path)
    if not await _open_game():
        return
    var runtime: LiveGameRuntimeV2 = game.get("runtime_session")
    if not _require(runtime != null and runtime.save_path == save_path,
            "Natural New Game failed to bind isolated SaveService path"):
        return
    var natural_v2_initial := _ready_v2_ids()
    if not _require(state.disciples.size() == 6 and state.sect.disciple_capacity == 8
            and natural_v2_initial.is_empty(),
            "Natural New Game must start 6 legacy founders, 8 beds, 0 PvE-ready V2"):
        return
    print("G0_NATURAL_NEWGAME_BASELINE_PASS " + JSON.stringify({
        "founders":6, "ready_v2":0, "beds":SectResidenceSystemV1.total_beds(state),
        "tokens":state.sect.disciple_recruitment_tokens,
        "initial_candidates":state.recruitment_candidates.size(),
        "initial_stones":state.sect.spirit_stones
    }))
    if not await _verify_natural_new_game_build_gate():
        return
    var house: BuildingState = state.buildings.get("residence_002")
    if not _require(house != null and house.status == BuildingSystem.STATUS_CONSTRUCTING
            and SectResidenceSystemV1.total_beds(state) == 8,
            "Annex construction must not grant any beds before actual completion"):
        return
    var start_tick := state.tick
    var duration := SectResidenceSystemV1.construction_duration_ticks(2)
    # Test accelerates clock by running the ONE canonical production scheduler,
    # never sets building.status, finish_tick, disciple_capacity or inventory.
    # 60 simulation-minute steps are legitimate game rules, not wall-clock sleep.
    runtime.owner.scheduler.run_ticks(duration - 1)
    if not _require(state.tick == start_tick + duration - 1
            and house.status == BuildingSystem.STATUS_CONSTRUCTING
            and SectResidenceSystemV1.total_beds(state) == 8,
            "Annex prematurely completed or scheduler tick accounting incorrect"):
        return
    runtime.owner.scheduler.run_ticks(1)
    if not _require(house.status == BuildingSystem.STATUS_ACTIVE
            and state.tick == start_tick + duration
            and SectResidenceSystemV1.total_beds(state) == 16
            and SectResidenceSystemV1.current_limit(state) == 12
            and SectHallSystemV1.rank_population_limit(state) == 12,
            "Actual 60-tick annex completion did not expose 16 beds / 12 legal seats"):
        return
    var receipt: Dictionary = state.sect.hall_governance.get("residence_build_receipts",{})
    if not _require(receipt.get(g1_build_request_id,"") == "residence_002"
            and SectHallSystemV1.validate(state).is_empty(),
            "Completed real annex lost its canonical paid receipt or Hall invariant"):
        return
    print("G0_NATURAL_ANNEX_COMPLETE_PASS " + JSON.stringify({
        "start_tick":start_tick, "end_tick":state.tick,
        "duration":duration, "beds":SectResidenceSystemV1.total_beds(state),
        "limit":SectResidenceSystemV1.current_limit(state),
        "paid_receipt":g1_build_request_id
    }))
    if not await _open_guidance_ui():
        return
    var accepted: Array[String] = []
    var recruited_ids: Dictionary = {}
    for index in range(6):
        var available := _eligible_candidates()
        if available.is_empty():
            var order := _find_button(game,"UseRecruitmentOrder")
            if order != null and not order.disabled and state.sect.disciple_recruitment_tokens > 0:
                var before_token := state.sect.disciple_recruitment_tokens
                if not await _press(order,"real Chiêu Mộ Lệnh for V2 member %d" % (index+1)):
                    return
                if not _require(state.sect.disciple_recruitment_tokens == before_token-1,
                        "Guidance paid order was not debited exactly once"):
                    return
            available = _eligible_candidates()
        # Real Dẫn Tiên arrivals on a later day are allowed. Do not inject
        # a candidate or a token when the queue is empty.
        if available.is_empty():
            var day_before := RecruitmentSystem.new().guidance_day_index(state)
            runtime.owner.scheduler.run_ticks(RecruitmentSystem.GUIDANCE_DAY_TICKS)
            if not _require(RecruitmentSystem.new().guidance_day_index(state) > day_before,
                    "Scheduler could not advance Dẫn Tiên to next authentic daily arrival"):
                return
            available = _eligible_candidates()
            print("G0_NATURAL_GUIDANCE_NEXT_DAY " + JSON.stringify({
                "day":RecruitmentSystem.new().guidance_day_index(state),
                "candidate_count":state.recruitment_candidates.size(),
                "eligible":available.size(),
                "tokens":state.sect.disciple_recruitment_tokens
            }))
        if available.is_empty():
            _fail("BLOCKER_CANDIDATE_SUPPLY: no authentic V2 candidate after real paid order or daily arrival for recruit %d" % (index+1))
            return
        var before := state.disciples.size()
        var recruit_id: StringName = await _accept_visible_candidate()
        if recruit_id == &"":
            return
        var disciple: DiscipleState = state.disciples.get(recruit_id)
        if not _require(disciple != null
                and not recruited_ids.has(str(recruit_id))
                and state.disciples.size() == before + 1
                and DiscipleRealmProgressV2.progression_ready(disciple)
                and DiscipleBirthProfileV2.valid_complete_birth(disciple.v2_birth_profile)
                and disciple.hp > 0.0 and disciple.injury_level == 0,
                "Natural B1 recruit was duplicate, legacy, injured, dead or not admitted"):
            return
        recruited_ids[str(recruit_id)] = true
        accepted.append(str(recruit_id))
        print("G0_NATURAL_RECRUIT_ACCEPT_PASS " + JSON.stringify({
            "ordinal":index+1, "id":str(recruit_id), "roster":state.disciples.size(),
            "tokens":state.sect.disciple_recruitment_tokens,
            "ready_v2":_ready_v2_ids().size()
        }))
    if not _require(accepted.size() == 6 and state.disciples.size() == 12
            and SectResidenceSystemV1.current_limit(state) == 12
            and _ready_v2_ids().size() == 6,
            "After six legal recruitments New Game must have 12 roster and six PvE-ready V2"):
        return
    # After 6 admissions, close B1 and use the REAL P3.2 party selection
    # button, rather than starting a hand-constructed PvE QA fixture.
    var adapter: Node = game.get_node_or_null("DanTienScreenV2/TriFacilityB1LiveAdapterV1")
    if adapter != null:
        adapter.call("_close_host")
        await process_frame
    game.call("_open_pve_party_picker")
    await process_frame
    var selected: Array = game.get("pve_party_selected_ids")
    var start_button := game.get("pve_party_picker_start") as Button
    if not _require(selected.size() == 6 and start_button != null
            and not start_button.disabled and _party_is_only_authentic_v2(selected, recruited_ids),
            "P3.2 real 6-member picker did not admit six genuine healthy idle V2 recruits"):
        return
    print("G0_NATURAL_PVE_SELECTOR_PASS " + JSON.stringify({
        "selected":selected.map(func(x):return str(x)), "ready_v2":_ready_v2_ids().size(),
        "button_enabled":not start_button.disabled
    }))
    if not await _press(start_button,"P3.2 enter actual Source A Thanh Trúc Lâm"):
        return
    var encounter_id := HuntingPveRunV2.active_multicamp_id(state)
    var resumed := HuntingPveRunV2.resume_active(state, encounter_id)
    if not _require(not encounter_id.is_empty() and bool(resumed.get("ok",false))
            and state.sect.v2_pve_active_runs.size() == 1,
            "P3.2 player-facing PvE action did not create one durable world encounter"):
        return
    var session: HuntingPveRunV2 = resumed["session"]
    var live_actors := _battle_actor_counts(session.battle)
    if not _require(int(live_actors.get("disciples",0)) == 6
            and int(live_actors.get("monsters",0)) == 10
            and state.sect.v2_pve_reward_claims.is_empty()
            and state.sect.v2_pve_settlement_receipts.is_empty(),
            "Player-started Source A battle is not authentic 6v10 or grants early loot"):
        return
    print("G0_NATURAL_SOURCE_A_6V10_PASS " + JSON.stringify({
        "encounter_id":encounter_id,"disciples":live_actors.get("disciples"),
        "monsters":live_actors.get("monsters"),"roster":state.disciples.size()
    }))
    var warehouse_before: Dictionary = state.sect.warehouse_resources.duplicate(true)
    var saved: Dictionary = await game.call("_save_runtime_async_barrier")
    if not _require(bool(saved.get("ok",false)) and FileAccess.file_exists(save_path),
            "New Game→6V2→PvE SaveService barrier failed: " + str(saved)):
        return
    var child: Array = []
    var args := PackedStringArray([
        "--headless","--path",ProjectSettings.globalize_path("res://"),
        "-s","res://tests/presentation/g0_natural_newgame_six_v2_pve_test.gd",
        "--","process2",save_path
    ])
    var exit_code := OS.execute(OS.get_executable_path(),args,child,true)
    var transcript := ""
    for line in child:
        transcript += str(line)
    print("G0_NATURAL_PROCESS2_BEGIN")
    print(transcript)
    print("G0_NATURAL_PROCESS2_END")
    if not _require(exit_code == 0 and transcript.contains("G0_NATURAL_PROCESS2_SAVE_RELOAD_PASS")
            and state.sect.warehouse_resources == warehouse_before
            and state.sect.v2_pve_reward_claims.is_empty()
            and state.sect.v2_pve_settlement_receipts.is_empty(),
            "Cross-process real Source A Save/Reload failed or generated premature loot; exit=%d" % exit_code):
        return
    print("G0_NATURAL_NEWGAME_SIX_V2_PVE_PASS "+JSON.stringify({
        "founders":6,"recruited_v2":6,"roster":12,
        "annex_completed":true,"source_a_6v10":true,
        "save_reload_second_process":true,"loot_not_fabricated":true
    }))
    _close_game()
    _cleanup_save()
    quit(0)

func _process2_reload() -> void:
    if not save_path.begins_with(SAVE_PREFIX) or not FileAccess.file_exists(save_path):
        _fail("G0 process-2 save path invalid or unavailable")
        return
    var owner := LiveGameRuntimeV2.new()
    var started := owner.start(save_path,int(Time.get_unix_time_from_system())+1)
    if not _require(bool(started.get("ok",false)) and bool(started.get("loaded",false)),
            "G0 process-2 cannot load genuine player SaveService snapshot: "+str(started)):
        return
    state = owner.state()
    var v2_ids := _ready_v2_ids()
    var house: BuildingState = state.buildings.get("residence_002")
    var encounter_id := HuntingPveRunV2.active_multicamp_id(state)
    var resumed := HuntingPveRunV2.resume_active(state,encounter_id)
    if not _require(state.disciples.size() == 12 and v2_ids.size() == 6
            and house != null and house.status == BuildingSystem.STATUS_ACTIVE
            and SectResidenceSystemV1.total_beds(state) == 16
            and SectResidenceSystemV1.current_limit(state) == 12
            and not encounter_id.is_empty() and state.sect.v2_pve_active_runs.size() == 1
            and bool(resumed.get("ok",false))
            and state.sect.v2_pve_reward_claims.is_empty()
            and state.sect.v2_pve_settlement_receipts.is_empty(),
            "G0 second process lost canonical six-V2 roster, active 6v10, annex or receipts"):
        return
    var counts := _battle_actor_counts((resumed["session"] as HuntingPveRunV2).battle)
    if not _require(int(counts.get("disciples",0)) == 6 and int(counts.get("monsters",0)) == 10,
            "G0 second-process Source A actor identity 6v10 did not persist"):
        return
    print("G0_NATURAL_PROCESS2_SAVE_RELOAD_PASS "+JSON.stringify({
        "roster":state.disciples.size(),"v2_eligible":v2_ids.size(),
        "houses":SectResidenceSystemV1.all_houses(state).size(),
        "encounter":encounter_id,"actors":counts,"reward_claims":0,"settlements":0
    }))
    quit(0)

func _ready_v2_ids() -> Array[String]:
    var ids: Array[String] = []
    if state == null:
        return ids
    for id in state.disciples.keys():
        var d: DiscipleState = state.disciples[id]
        if DiscipleRealmProgressV2.progression_ready(d):
            ids.append(str(id))
    ids.sort()
    return ids

func _eligible_candidates() -> Array[StringName]:
    var ids: Array[StringName] = []
    for raw_id in state.recruitment_candidates.keys():
        var candidate: CandidateState = state.recruitment_candidates[raw_id]
        if candidate != null and DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile):
            ids.append(StringName(str(raw_id)))
    ids.sort()
    return ids

func _party_is_only_authentic_v2(selected: Array, recruited_ids: Dictionary) -> bool:
    for raw_id in selected:
        var id := StringName(str(raw_id))
        if not recruited_ids.has(str(id)) or not state.disciples.has(id):
            return false
        var d: DiscipleState = state.disciples[id]
        if not DiscipleRealmProgressV2.progression_ready(d) or d.hp <= 0.0 \
                or d.injury_level != 0 or d.region_id != &"sect" \
                or not [&"IDLE",&"HOLD",&"EVALUATE"].has(d.current_action) \
                or not d.active_pve_encounter_id.is_empty() \
                or not d.work_cycle_state.is_empty() or d.worksite_building_id != &"":
            return false
    return true

func _open_guidance_ui() -> bool:
    var target := _find_button(game,"BuildingHit_guidance")
    if not await _press(target,"real map Dẫn Tiên entry"):
        return false
    var open_guidance := _find_button(game,"OpenDanTienScreenV2")
    if not await _press(open_guidance,"B1 Dẫn Tiên open"):
        return false
    return _require(game.get_node_or_null("DanTienScreenV2/TriFacilityB1LiveAdapterV1") != null,
        "B1 real adapter did not appear after Guidance UI opened")

func _battle_actor_counts(battle: MapBattleV2) -> Dictionary:
    var disciple_count := 0
    var monster_count := 0
    if battle == null:
        return {}
    for raw_id in battle.actors.keys():
        var actor: Dictionary = battle.actors[raw_id]
        if str(actor.get("side","")) == "disciple":
            disciple_count += 1
        elif str(actor.get("side","")) == "monster":
            monster_count += 1
    return {"disciples":disciple_count,"monsters":monster_count}

func _verify_natural_new_game_build_gate() -> bool:
	var hall := SectHallSystemV1.hall(state)
	var houses := SectResidenceSystemV1.all_houses(state)
	if not _require(hall != null and hall.level == 1 and houses.size() == 1,
		"fresh game did not start from the canonical Hall Lv1 / one starter residence state"):
		return false
	var buildings_before := state.buildings.size()
	var event_count_before := state.building_event_count
	var warehouse := WarehouseSystem.new()
	var wood_before := warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_WOOD))
	var ore_before := warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_ORE))
	var stones_before := state.sect.spirit_stones
	g1_build_cost = SectResidenceSystemV1.build_cost(state).duplicate(true)
	var real_gate := SectResidenceSystemV1.can_construct(state)
	if not _require(bool(real_gate.get("ok",false)),
		"canonical New Game stock cannot pay for its first optional Residence expansion: %s" % str(real_gate)):
		return false
	if not _require(wood_before >= int(g1_build_cost.get(BuildingSystem.MATERIAL_WOOD,0))
		and ore_before >= int(g1_build_cost.get(BuildingSystem.MATERIAL_ORE,0))
		and stones_before >= int(g1_build_cost.get("spirit_stones",0)),
		"real New Game Warehouse/treasury is below the displayed Residence cost"):
		return false
	game.call("_enter_build_mode")
	await process_frame
	var catalog := _find_button(game,"BuildCatalogResidence")
	var catalog_art := game.find_child("BuildCatalogResidenceArt",true,false) as Control
	var description := game.get("build_mode_description") as Label
	if not await _capture_frame("01_new_game_build_catalog_ready.png"):
		return false
	if not _require(catalog_art != null
		and bool(catalog_art.get("_original_source"))
		and str(catalog_art.get("_source_model_id")) == "510076",
		"player build catalog did not render the SHA-gated Source A Residence model 510076"):
		return false
	if not _require(catalog != null and not catalog.disabled
		and catalog.tooltip_text.contains("Đủ điều kiện")
		and catalog.tooltip_text.contains("40/40 Mộc")
		and catalog.tooltip_text.contains("40/30 Thiết")
		and catalog.tooltip_text.contains("500/500 Linh Thạch")
		and description != null and description.text.contains("Đại Điện Lv1")
		and description.text.contains("mở ở Lv1"),
		"New Game build catalog does not explain current access/cost: tooltip=%s description=%s" % [
			catalog.tooltip_text if catalog != null else "<missing>",
			description.text if description != null else "<missing>"]):
		return false
	if not await _press(catalog,"choose paid Residence from the real build catalog"):
		return false
	await process_frame
	if not _require(str(game.get("build_mode_kind")) == "construct",
		"Residence catalog did not enter the canonical map placement mode"):
		return false
	var iso := game.get("iso_world") as SectIsometricWorldV1
	var camera := iso.get("camera") as Camera2D if iso != null else null
	if not _require(iso != null and camera != null,
		"P3.2 map camera is unavailable during real construction"):
		return false
	var actor_cells := _actor_ground_cells()
	var actor_plot := SectResidenceSiteV1.UNSELECTED
	var actor_plot_point := Vector2.ZERO
	for candidate in SectResidenceSiteV1.available_plots(state):
		if not _plot_overlaps_actor_cell(candidate,actor_cells):
			continue
		var candidate_point := _visible_residence_plot_screen_point(candidate,camera,game)
		if candidate_point.x < 0.0:
			continue
		actor_plot = candidate
		actor_plot_point = candidate_point
		break
	if not _require(actor_plot != SectResidenceSiteV1.UNSELECTED,
		"fresh map has no visible legal plot occupied by a real disciple actor for collision QA"):
		return false
	_send_map_click(actor_plot_point)
	await process_frame
	var blocked_confirm := _find_button(game,"ConfirmMapConstruction")
	var blocked_label := game.get("build_mode_site_label") as Label
	if not _require(Vector2i(game.get("build_mode_site")) == actor_plot
		and blocked_confirm != null and blocked_confirm.disabled
		and blocked_label != null and blocked_label.text.contains("đang đứng")
		and state.buildings.size() == buildings_before
		and state.building_event_count == event_count_before
		and warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_WOOD)) == wood_before
		and warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_ORE)) == ore_before
		and state.sect.spirit_stones == stones_before,
		"live disciple collision did not block placement without charging or mutating state"):
		return false
	if not await _capture_frame("02a_actor_occupied_plot_rejected.png"):
		return false
	var target := SectResidenceSiteV1.UNSELECTED
	var screen_point := Vector2.ZERO
	for candidate in SectResidenceSiteV1.available_plots(state):
		if _plot_overlaps_actor_cell(candidate,actor_cells):
			continue
		var candidate_screen := _visible_residence_plot_screen_point(candidate,camera,game)
		if candidate_screen.x < 0.0:
			continue
		target = candidate
		screen_point = candidate_screen
		break
	if not _require(target != SectResidenceSiteV1.UNSELECTED,
		"could not find a legal, visible New Game plot for the actual P3.2 input path"):
		return false
	_send_map_click(screen_point)
	await process_frame
	if not _require(Vector2i(game.get("build_mode_site")) == target,
		"map pointer event did not choose the visible legal plot"):
		return false
	var confirm := _find_button(game,"ConfirmMapConstruction")
	if not _require(confirm != null and not confirm.disabled,
		"a real valid New Game plot did not enable the paid construction button"):
		return false
	if not await _capture_frame("02_new_game_residence_valid_placement.png"):
		return false
	g1_build_request_id = "map-house:%d:%d:%d:new" % [state.tick,target.x,target.y]
	if not await _press(confirm,"confirm canonical paid Residence construction"):
		return false
	await process_frame
	var built: BuildingState = state.buildings.get("residence_002")
	var cost := g1_build_cost
	var wood_after := warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_WOOD))
	var ore_after := warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_ORE))
	var stones_after := state.sect.spirit_stones
	var receipts: Dictionary = state.sect.hall_governance.get("residence_build_receipts",{})
	var duration := SectResidenceSystemV1.construction_duration_ticks(2)
	var operation_text := str(game.call("_residence_operation_text"))
	if not _require(built != null and built.status == BuildingSystem.STATUS_CONSTRUCTING
		and SectResidenceSiteV1.origin_of(built) == target
		and int(built.production_state.get("construction_finish_tick",-1)) == state.tick+duration
		and SectResidenceSystemV1.construction_remaining_ticks(state,built) == duration
		and operation_text.contains("Đang thi công")
		and operation_text.contains("còn %d nhịp" % duration),
		"real UI build did not create the selected paid House with its canonical timer/site"):
		return false
	if not _require(state.buildings.size() == buildings_before+1
		and state.building_event_count == event_count_before+1
		and receipts.get(g1_build_request_id,"") == "residence_002"
		and wood_after == wood_before-int(cost[BuildingSystem.MATERIAL_WOOD])
		and ore_after == ore_before-int(cost[BuildingSystem.MATERIAL_ORE])
		and stones_after == stones_before-int(cost["spirit_stones"]),
		"canonical construction did not debit exact resources once and write one durable receipt"):
		return false
	g1_house_id = str(built.id)
	g1_house_site = target
	g1_wood_after = wood_after
	g1_ore_after = ore_after
	g1_stones_after = stones_after
	var replay := SectResidenceSystemV1.construct(state,g1_build_request_id,target)
	if not _require(bool(replay.get("already_settled",false))
		and state.buildings.size() == buildings_before+1
		and warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_WOOD)) == wood_after
		and warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_ORE)) == ore_after
		and state.sect.spirit_stones == stones_after,
		"replaying the real map construction duplicated the House or charged again"):
		return false
	if not await _capture_frame("03_new_game_paid_residence_constructing.png"):
		return false
	var close_building := _find_button(game,"CloseBuildingOperation")
	if close_building != null and not close_building.disabled:
		if not await _press(close_building,"close the new House operation panel"):
			return false
	if not _require(state.buildings.size() == buildings_before+1
		and SectResidenceSystemV1.all_houses(state).size() == 2
		and SectHallSystemV1.validate(state).is_empty(),
		"closing the UI changed the paid Residence or canonical Hall/bed invariants"):
		return false
	print("TRI03_G1_NEW_GAME_BUILD_PASS house=%s site=%d,%d cost=%s actor_blocked=1 exactly_once=1 timer=%d route=1" % [
			 g1_house_id,g1_house_site.x,g1_house_site.y,str(g1_build_cost),SectResidenceSystemV1.construction_duration_ticks(2)])
	return true

func _actor_ground_cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var positions: Dictionary = game.get("actor_virtual_positions")
	for raw_id in positions.keys():
		if not state.disciples.has(StringName(str(raw_id))):
			continue
		var top_left: Vector2 = positions[raw_id]
		var foot := top_left+DiscipleActorVisualCatalog.ACTOR_FOOT_POINT
		var map_point := foot-SectIsometricWorldV1.LEGACY_ANCHOR \
			+ SectIsometricWorldV1.project(Vector2(SectIsometricWorldV1.CENTER_CELL))
		var fractional := SectIsometricWorldV1.inverse(map_point)
		result.append(Vector2i(roundi(fractional.x),roundi(fractional.y)))
	return result

func _plot_overlaps_actor_cell(site: Vector2i, actor_cells: Array[Vector2i]) -> bool:
	var footprint := Rect2i(site,SectResidenceSiteV1.HOUSE_FOOTPRINT)
	var door := SectResidenceSiteV1.doorway(site)
	for cell in actor_cells:
		if footprint.has_point(cell) or door == cell:
			return true
	return false

func _visible_residence_plot_screen_point(site: Vector2i, camera: Camera2D,
		map_game: Control) -> Vector2:
	var world_point := SectIsometricWorldV1.project(Vector2(site))
	var local_view := SectIsometricWorldV1.VIEW_SIZE*0.5 + (world_point-camera.position)*camera.zoom.x
	var screen_point := local_view+SectIsometricWorldV1.MAP_SCREEN_OFFSET
	if not SectMapCamera.is_map_screen_point(screen_point):
		return Vector2(-1,-1)
	if Rect2(Vector2(18,144),Vector2(392,510)).has_point(screen_point):
		return Vector2(-1,-1)
	if Vector2i(map_game.call("_cell_at_map_screen",screen_point)) != site:
		return Vector2(-1,-1)
	return screen_point

func _send_map_click(screen_point: Vector2) -> void:
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.position = screen_point
	down.pressed = true
	game.call("_input",down)
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.position = screen_point
	up.pressed = false
	game.call("_input",up)

func _accept_visible_candidate() -> StringName:
	var ids: Array = state.recruitment_candidates.keys()
	ids.sort()
	for raw_id in ids:
		var id := StringName(str(raw_id))
		var candidate: CandidateState = state.recruitment_candidates.get(id)
		if candidate == null or (state.sect.disciple_v2_birth_enabled
			and not DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile)):
			continue
		var pick := _find_button(game,"CandidatePick_%s" % str(id))
		if pick == null:
			var search := game.find_child("CandidateSearch",true,false) as LineEdit
			if search == null:
				continue
			search.text = candidate.display_name
			search.text_submitted.emit(search.text)
			await process_frame
			pick = _find_button(game,"CandidatePick_%s" % str(id))
		if pick == null:
			continue
		if not pick.disabled:
			pick.pressed.emit()
			await process_frame
		else:
			var screen := game.get_node_or_null("DanTienScreenV2")
			if screen == null or StringName(screen.get("selected_candidate_id")) != id:
				continue
		var accept := _find_button(game,"AcceptCandidate")
		if accept == null or accept.disabled:
			continue
		accept.pressed.emit()
		await process_frame
		accept = _find_button(game,"AcceptCandidate")
		if accept == null or not accept.text.contains("XÁC NHẬN"):
			_fail("B1 acceptance did not ask for its visible second confirmation")
			return &""
		accept.pressed.emit()
		await process_frame
		if state.disciples.has(id):
			return id
	_fail("no authentic visible candidate could be accepted through B1")
	return &""

func _open_game() -> bool:
	var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
	if not _require(packed != null,"cannot load P3.2 game entry scene"):
		return false
	game = packed.instantiate() as Control
	if not _require(game != null,"cannot instantiate P3.2 game entry scene"):
		return false
	root.add_child(game)
	await process_frame
	state = game.get("state") as SimulationState
	if not _require(state != null and bool(game.get("runtime_ready")),
		"P3.2 did not start its canonical live runtime"):
		return false
	_stop_timers(game)
	return true

func _press(button: Button, action: String) -> bool:
	if not _require(button != null and not button.disabled,"missing/disabled real UI control: %s" % action):
		return false
	button.pressed.emit()
	await process_frame
	return true

func _capture_frame(file_name: String) -> bool:
	if capture_dir.is_empty():
		return true
	await RenderingServer.frame_post_draw
	var frame := root.get_texture().get_image()
	if frame == null or frame.get_size() != Vector2i(1280,720):
		return _require(false,"Godot did not render a native 1280x720 frame for %s" % file_name)
	return _require(frame.save_png(capture_dir.path_join(file_name)) == OK,
		"could not save 1280x720 Godot frame: %s" % file_name)

func _find_button(node: Node, button_name: String) -> Button:
	if node == null:
		return null
	if node is Button and node.name == button_name:
		return node as Button
	for child in node.get_children():
		var found := _find_button(child,button_name)
		if found != null:
			return found
	return null

func _stop_timers(node: Node) -> void:
	if node is Timer:
		(node as Timer).stop()
	for child in node.get_children():
		_stop_timers(child)

func _require(ok: bool,reason: String) -> bool:
	if ok:
		return true
	_fail(reason)
	return false

func _fail(reason: String) -> void:
	push_error("G0_NATURAL_SIX_V2_FAIL: "+reason)
	_close_game()
	_cleanup_save()
	quit(1)

func _close_game() -> void:
	if game != null and is_instance_valid(game):
		game.set("runtime_ready",false)
		if game.get_parent() != null:
			game.get_parent().remove_child(game)
		game.queue_free()
	game = null
	state = null

func _cleanup_save() -> void:
	var absolute := ProjectSettings.globalize_path(save_path)
	for suffix in ["",".bak",".tmp",".expected.json"]:
		if FileAccess.file_exists(absolute+suffix):
			DirAccess.remove_absolute(absolute+suffix)
	ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)
