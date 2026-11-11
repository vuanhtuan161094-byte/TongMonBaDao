extends "res://src/presentation/p3_1_landscape_sect.gd"

const TRI_B1_LIVE_ADAPTER = preload("res://src/presentation/uiux/tri_facility_live_adapter_v1.gd")
const TRI_FACILITY_ART = preload("res://src/presentation/uiux/sect_facility_art_v2.gd")
const SECT_UI_THEME = preload("res://src/presentation/uiux/sect_ui_theme_v1.gd")
const SECT_UI_ICON = preload("res://src/presentation/uiux/sect_ui_icon_v1.gd")
const ZOOM_STEP := 1.12
const CAMERA_TWEEN_SECONDS := 0.22
const FOCUS_MARKER_SIZE := Vector2(82.0, 82.0)
# Runtime authority polls once per second; avoid decoding the same saved battle
# snapshot four times between authoritative updates.
const B3_HUNT_REFRESH_SECONDS := 1.0
const MAP_WORKSITE_MAX_CUES := 4
const MAP_WORKSITE_REFRESH_SECONDS := 0.25
const MAX_RETAINED_ACTOR_POOL := 72
const MAX_VISIBLE_SECT_DISCIPLE_ACTORS := 16
const MAX_VISIBLE_ACTORS_PER_DESTINATION := 6
const IDLE_PATROL_DESTINATIONS := [
    SectMapPresentation.DEST_COURTYARD,
    SectMapPresentation.DEST_MAIN_HALL,
    SectMapPresentation.DEST_RESIDENCE,
    SectMapPresentation.DEST_CULTIVATION,
    SectMapPresentation.DEST_WAREHOUSE,
    SectMapPresentation.DEST_MEDICINE,
    SectMapPresentation.DEST_GATE
]
const IDLE_AMBIENT_LINES := [
    "Linh khí thật dễ chịu.",
    "Ta đi dạo một vòng.",
    "Đường tu còn dài.",
    "Tông môn thật yên bình.",
    "Chờ Chưởng Môn giao việc.",
    "Linh Điền xanh tốt quá."
]
const PERFORMANCE_SAMPLE_SECONDS := 3.0
var _v63_hunt_resource_registry := ResourceRegistry.new()
var sx02_selected_medicine: StringName = &""
const RAW_FRAME_LOG_ENV := "TMB_PVE_RAW_FRAME_LOG_PATH"

class B3MainHuntArena:
    extends Control

    var battle: MapBattleV2
    var presenter: B3CareCombatV5Presenter
    var combat_view: B3MainHuntCombatView
    var live_map: PveLiveWorldMapV1
    var sect_world: PveSectWorldViewV1

    func _ready() -> void:
        clip_contents = true
        live_map = PveLiveWorldMapV1.new()
        live_map.name = "PveLiveWorldMapV1"
        live_map.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        live_map.visible = false
        add_child(live_map)
        sect_world = PveSectWorldViewV1.new()
        sect_world.name = "PveSectWorldViewV1"
        sect_world.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        sect_world.visible = false
        add_child(sect_world)
        presenter = B3CareCombatV5Presenter.new()
        presenter.name = "B3CareCombatV5Presenter"
        presenter.position = Vector2.ZERO
        presenter.enable_source_vl_art = true
        presenter.enable_source_a_combat_visuals = true
        presenter.draw_pilot_ground = true
        presenter.enable_spectator_framing = true
        presenter.compact_source_a_actor_overlays = true
        presenter.stage_rect = Rect2(Vector2.ZERO,size)
        add_child(presenter)

    func _notification(what: int) -> void:
        if what == NOTIFICATION_RESIZED and presenter != null:
            presenter.stage_rect = Rect2(Vector2.ZERO,size)
            presenter.queue_redraw()

    func show_authority_snapshot(snapshot: MapBattleV2, view_rows: Dictionary = {},
            camp_population: Dictionary = {}, use_live_map: bool = false) -> void:
        battle = snapshot
        live_map.visible = use_live_map
        sect_world.visible = false
        presenter.visible = not use_live_map
        if live_map != null:
            live_map.show_authority_snapshot(snapshot,camp_population)
        if combat_view != null:
            combat_view.visible = use_live_map
            if use_live_map:
                combat_view.show_authority_snapshot(snapshot,view_rows)
        if use_live_map or presenter == null:
            return
        _update_presenter(presenter,snapshot,view_rows)

    func show_open_world_snapshot(snapshot: MapBattleV2, world_population: Dictionary,
            camp_index: int = 0, disciples: Dictionary = {}, view_rows: Dictionary = {}) -> void:
        battle = snapshot
        live_map.visible = false
        sect_world.visible = true
        presenter.visible = false
        if combat_view != null:
            combat_view.visible = false
        sect_world.show_authority_snapshot(snapshot,world_population,camp_index,disciples,view_rows)

    func _update_presenter(target: B3CareCombatV5Presenter,
            snapshot: MapBattleV2, view_rows: Dictionary) -> void:
        if target.battle == null or (snapshot != null and target.battle.encounter_id != snapshot.encounter_id):
            target.attach_session(snapshot)
        else:
            # Replace only the read-only snapshot; keep renderer interpolation,
            # camera and event cursor across 250ms UI refreshes.
            target.battle = snapshot
            target.refresh_from_authority()
        target.set_actor_view_metadata(view_rows)
        target.queue_redraw()

class B3MainHuntCombatView:
    extends Control

    var presenter: B3CareCombatV5Presenter

    func _ready() -> void:
        mouse_filter = Control.MOUSE_FILTER_IGNORE
        presenter = B3CareCombatV5Presenter.new()
        presenter.name = "B3PveCombatV5Presenter"
        presenter.position = Vector2.ZERO
        presenter.enable_source_vl_art = true
        presenter.enable_source_a_combat_visuals = true
        presenter.draw_pilot_ground = true
        presenter.enable_spectator_framing = true
        presenter.compact_source_a_actor_overlays = true
        presenter.stage_rect = Rect2(Vector2.ZERO,size)
        add_child(presenter)

    func _notification(what: int) -> void:
        if what == NOTIFICATION_RESIZED and presenter != null:
            presenter.stage_rect = Rect2(Vector2.ZERO,size)
            presenter.queue_redraw()

    func show_authority_snapshot(snapshot: MapBattleV2, view_rows: Dictionary) -> void:
        if presenter == null:
            return
        if presenter.battle == null or (snapshot != null and presenter.battle.encounter_id != snapshot.encounter_id):
            presenter.attach_session(snapshot)
        else:
            presenter.battle = snapshot
            presenter.refresh_from_authority()
        presenter.set_actor_view_metadata(view_rows)
        presenter.queue_redraw()

var map_zoom: float = SectMapCamera.DEFAULT_ZOOM
var touch_points: Dictionary = {}
var last_pinch_distance: float = 0.0
var mouse_panning := false
var camera_tween: Tween
var focus_marker_tween: Tween
var zoom_readout: Label
var focus_readout: Label
var focus_target_button: Button
var focus_marker: Panel
var focused_world_point := Vector2.ZERO
var focused_kind: StringName = &""
var focused_id: StringName = &""
var focused_label := ""
var has_focus_target := false
var tab_status_text := ""
var disciple_profile_search_query := ""
var disciple_profile_roster_collapsed := false
var disciple_profile_sort_mode := 0
var disciple_profile_active_tab_name := "Tổng Quan"
var disciple_profile_tab_scroll_positions: Dictionary = {}
var disciple_quick_assignment_return_to_summary := false
var technique_system := TechniqueSystem.new()
var equipment_system := EquipmentSystem.new()
var needs_system := NeedsSystem.new()
var recruitment_system := RecruitmentSystem.new()
var spirit_crop_registry := SpiritCropRegistry.new()
var living_cue_resolver := LivingCueResolver.new()
var living_cue_tracker := LivingCueTracker.new()
var living_cue_layer: LivingCueLayer
var visible_living_cues: Array[Dictionary] = []
var female_motion_library: AnimationLibrary
var modular_live_actor_ids: Dictionary = {}
var actor_virtual_positions: Dictionary = {}
var actor_pool: Array[ModularDiscipleActor] = []
var actor_position_tweens: Dictionary = {}
var actor_position_tween_targets: Dictionary = {}
var actor_idle_wander_destinations: Dictionary = {}
var actor_idle_wander_indices: Dictionary = {}
var actor_idle_wander_due_msec: Dictionary = {}
var actor_transition_origins: Dictionary = {}
var actor_transition_deadline_msec: Dictionary = {}
var actor_last_actions: Dictionary = {}
var actor_ambient_bubbles: Dictionary = {}
var warehouse_display_resource_ids: Array[StringName] = []
var npc_motion_elapsed := 0.0
var npc_ambient_elapsed := 0.0
var npc_ambient_delay := 6.0
var npc_ambient_cursor := 0
var source_a_portrait_textures: Dictionary = {}

var gp1_guide_panel: Panel
var gp1_guide_title: Label
var gp1_guide_description: Label
var gp1_guide_button: Button
var gp1_hall_viewed := false
var gp1_residence_viewed := false
var gp1_guide_dismissed := false
var camera_controls_panel: Panel
var camera_hint: Label
var disciple_summary_panel: Panel
var disciple_summary_initial: Label
var disciple_summary_name: Label
var disciple_summary_meta: Label
var disciple_summary_body: Label
var summary_feedback := ""

var build_mode_button: Button
var build_mode_panel: Panel
var build_mode_description: Label
var build_mode_feedback: Label
var build_mode_site_label: Label
var build_mode_confirm: Button
var build_mode_move_list: VBoxContainer
var build_mode_active := false
var build_mode_kind := ""
var build_mode_house_id: StringName = &""
var build_mode_site := SectResidenceSiteV1.UNSELECTED
var building_operation_panel: Panel
var building_operation_title: Label
var building_operation_body: Label
var building_operation_content: VBoxContainer
var building_management_container: VBoxContainer
var building_operation_metrics: HBoxContainer
var building_operation_scroll: ScrollContainer
var building_operation_live_panel: Panel
var building_operation_live_scroll: ScrollContainer
var building_operation_live_content: VBoxContainer
var building_operation_progress: ProgressBar
var building_operation_progress_label: Label
var building_management_feedback := ""
var building_management_last_sim_tick := -1
var building_management_last_refresh_frame := -1
var selected_building: StringName = &""
var deep_restore_summary := false
var screen_pointer_dragged := false
var mouse_pointer_dragged := false
var b3_hunt_panel: Panel
var b3_hunt_arena: B3MainHuntArena
var b3_pve_world_view: PveSectWorldViewV1
var b3_hunt_combat_view: B3MainHuntCombatView
var b3_hunt_facts: Label
var b3_hunt_facts_panel: Panel
var b3_hunt_world_status: Label
var b3_hunt_title: Label
var b3_hunt_subtitle: Label
var b3_hunt_feedback: Label
var b3_hunt_auto_button: Button
var b3_hunt_deploy_button: Button
var b3_hunt_return_button: Button
var b3_hunt_save_button: Button
var p0_add_hunter_button: Button
var p0_withdraw_hunter_button: Button
var p0_close_map_button: Button
var b3_hunt_disciple_id: StringName = &""
var b3_hunt_refresh_elapsed := 0.0
var production_underlay_frozen := false
var production_underlay_mode_before_freeze := -1
var active_hunt_mode := "care"
var multicamp_encounter_id := ""
var pve_party_picker_shade: ColorRect
var pve_party_picker_panel: Panel
var pve_party_picker_count: Label
var pve_party_picker_reasons: Label
var pve_party_picker_feedback: Label
var pve_party_picker_list: VBoxContainer
var pve_party_picker_start: Button
var pve_party_picker_boss_selector: OptionButton
var pve_party_picker_boss_start: Button
var v63_combat_hud: V63CombatHudV1
var v63_archive_screen: Control
var v63_preview_overrides: Dictionary = {}
var pve_party_picker_checks: Dictionary = {}
var pve_party_selected_ids: Array[StringName] = []
var pve_party_picker_join_mode := false
var iso_view_container: SubViewportContainer
var iso_viewport: SubViewport
var iso_world: SectIsometricWorldV1
var selected_production_instance_id: StringName = &""
var map_worksite_cues: Dictionary = {}
var map_worksite_receipt_baseline: Dictionary = {}
var map_worksite_refresh_elapsed := 0.0
var map_worksite_cues_dirty := false
var actor_visibility_refresh_elapsed := 0.0
var map_worksite_last_scale := 0.0
var map_worksite_anchors: Dictionary = {}
var map_worksite_screen_offsets: Dictionary = {}
var performance_logging_enabled := false
var performance_sample_elapsed := 0.0
var performance_sample_frame_count := 0
var performance_sample_delta_total := 0.0
var performance_sample_delta_max := 0.0
var performance_hunt_refresh_count := 0
var performance_hunt_refresh_usec_total := 0
var performance_hunt_refresh_usec_max := 0
var performance_hunt_restore_usec_total := 0
var performance_hunt_restore_usec_max := 0
var performance_hunt_visual_rows_usec_total := 0
var performance_hunt_visual_rows_usec_max := 0
var performance_hunt_view_update_usec_total := 0
var performance_hunt_view_update_usec_max := 0
var performance_hunt_hud_update_usec_total := 0
var performance_hunt_hud_update_usec_max := 0
var b3_hunt_layout_initialized := false
var b3_hunt_layout_live_mode := false
var b3_hunt_layout_viewport_size := Vector2.ZERO
var b3_hunt_layout_apply_count := 0
var performance_move_pathfinding_count := 0
var performance_move_pathfinding_usec_total := 0
var performance_move_pathfinding_usec_max := 0
var performance_sync_actor_usec_total := 0
var performance_sync_actor_usec_max := 0
var performance_map_worksite_refresh_count := 0
var performance_map_worksite_refresh_usec_total := 0
var performance_map_worksite_refresh_usec_max := 0
var performance_iso_refresh_usec_total := 0
var performance_iso_refresh_usec_max := 0
var performance_runtime_poll_count := 0
var performance_runtime_poll_usec_total := 0
var performance_runtime_poll_usec_max := 0
var performance_runtime_update_usec_total := 0
var performance_runtime_update_usec_max := 0
var performance_runtime_refresh_usec_total := 0
var performance_runtime_refresh_usec_max := 0
var performance_runtime_save_wait_usec_total := 0
var performance_runtime_save_wait_usec_max := 0
var performance_save_count := 0
var performance_save_usec_total := 0
var performance_save_usec_max := 0
var performance_autosave_prepare_usec_total := 0
var performance_autosave_prepare_usec_max := 0
var performance_autosave_wait_usec_total := 0
var performance_autosave_wait_usec_max := 0
var performance_checkpoint_count := 0
var performance_checkpoint_usec_total := 0
var performance_checkpoint_usec_max := 0
var raw_frame_log: FileAccess
var raw_frame_log_buffer := PackedStringArray()
var raw_frame_log_index := 0

func _ready() -> void:
    super._ready()
    if not runtime_ready:
        return
    performance_logging_enabled = OS.get_environment("TMB_PVE_PERF_LOG") == "1"
    _open_raw_frame_log()
    female_motion_library = FemaleNormalV1MotionLibrary.build()
    warehouse_display_resource_ids = _v63_hunt_resource_registry.all_resource_ids()
    _install_modular_live_actors()
    _install_main_isometric_world()
    _sync_actor_positions()
    popup_layer.z_index = 100
    _reset_camera(false)
    _build_focus_marker()
    _build_camera_controls()
    _build_disciple_summary_panel()
    _build_building_operation_panel()
    _build_construction_ui()
    _build_gp1_first_minutes_guide()
    _build_living_cue_layer()
    _seed_map_worksite_receipts()
    _refresh_map_worksite_cues()
    living_cue_tracker.seed_from_state(state)
    _refresh_living_cues()
    _build_b3_hunt_panel()
    _build_pve_quick_entry()
    _build_pve_party_picker()
    if state.sect.v63_archive_opt_in and state.sect.v63_skill_combat_opt_in:
        await _set_v63_preview_gate(true,false)
    _resume_saved_b3_hunt()

func _exit_tree() -> void:
    # P3.1 owns the canonical final save. Preserve that lifecycle when the
    # P3.2 presentation is torn down; runtime_ready is still true here during
    # a normal game exit. QA disposal deliberately clears it after an awaited
    # async-save barrier and therefore remains non-writing.
    super._exit_tree()
    _flush_raw_frame_log()
    if raw_frame_log != null:
        raw_frame_log.close()
        raw_frame_log = null
    for tween_value in actor_position_tweens.values():
        var tween := tween_value as Tween
        if tween != null and tween.is_running():
            tween.kill()
    actor_position_tweens.clear()
    actor_position_tween_targets.clear()
    # Recycled actors live outside the scene tree between viewport changes;
    # release them explicitly when P3.2 is torn down/reloaded.
    for actor in actor_pool:
        if actor != null and is_instance_valid(actor):
            actor.free()
    actor_pool.clear()

func _spawn_all_disciples() -> void:
    # P3.1 builds a VBox/portrait/status subtree per canonical disciple here.
    # P3.2 owns the pooled Source A actor layer, so avoid creating and freeing
    # a second UI subtree per roster member. The viewport actor pool materializes
    # only nearby idle residents and short assignment transits.
    if state == null:
        return
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple_id := StringName(raw_id)
        actor_destinations[str(disciple_id)] = str(_initial_destination(state.disciples[disciple_id]))

func _point_over_build_mode_panel(screen_point: Vector2) -> bool:
    return build_mode_panel != null and build_mode_panel.visible \
        and Rect2(build_mode_panel.position,build_mode_panel.size).has_point(screen_point)

# _input is called before GUI controls. A tap on an open facility is NOT a map click.
func _point_over_building_management(screen_point: Vector2) -> bool:
    return _building_operation_is_open() and building_operation_panel.get_global_rect().has_point(screen_point)

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and _point_over_building_management((event as InputEventMouseButton).position):
        _clear_pointer_state()
        return
    if event is InputEventScreenTouch and _point_over_building_management((event as InputEventScreenTouch).position):
        _clear_pointer_state()
        return
    if event is InputEventMouseButton and _point_over_build_mode_panel((event as InputEventMouseButton).position):
        return
    if event is InputEventScreenTouch and _point_over_build_mode_panel((event as InputEventScreenTouch).position):
        return
    # Map picking must see a physical tap before Control descendants consume
    # the release. Drag still goes through the same canonical map transform.
    if _popup_is_open():
        _clear_pointer_state()
        return
    if event is InputEventMouseButton:
        var mouse := event as InputEventMouseButton
        if mouse.button_index != MOUSE_BUTTON_LEFT:
            return
        if mouse.pressed:
            mouse_panning = SectMapCamera.is_map_screen_point(mouse.position)
            mouse_pointer_dragged = false
            return
        var was_map_tap := mouse_panning and not mouse_pointer_dragged
        var was_map_drag := mouse_panning and mouse_pointer_dragged
        if was_map_tap and _try_iso_map_pick(mouse.position):
            _clear_pointer_state()
            get_viewport().set_input_as_handled()
        elif was_map_drag:
            _clear_pointer_state()
            get_viewport().set_input_as_handled()
        return
    if event is InputEventMouseMotion and mouse_panning:
        var motion := event as InputEventMouseMotion
        if (motion.button_mask & MOUSE_BUTTON_MASK_LEFT) == 0:
            _clear_pointer_state()
            return
        if motion.relative.length() > 2.0:
            mouse_pointer_dragged = true
            _pan_camera(motion.relative)
            get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey:
        var key_event := event as InputEventKey
        if key_event.pressed and not key_event.echo and key_event.keycode == KEY_ESCAPE:
            _close_top_management_screen()
            get_viewport().set_input_as_handled()
            return
    if event is InputEventMouseButton and _point_over_building_management((event as InputEventMouseButton).position):
        return
    if event is InputEventMouseMotion and _point_over_building_management((event as InputEventMouseMotion).position):
        return
    if event is InputEventScreenTouch and _point_over_building_management((event as InputEventScreenTouch).position):
        return
    if event is InputEventMouseButton and _point_over_build_mode_panel((event as InputEventMouseButton).position):
        return
    if event is InputEventMouseMotion and _point_over_build_mode_panel((event as InputEventMouseMotion).position):
        return
    if event is InputEventScreenTouch and _point_over_build_mode_panel((event as InputEventScreenTouch).position):
        return
    if _popup_is_open():
        _clear_pointer_state()
        return

    if event is InputEventScreenTouch:
        _handle_screen_touch(event as InputEventScreenTouch)
        return
    if event is InputEventScreenDrag:
        _handle_screen_drag(event as InputEventScreenDrag)
        return
    if event is InputEventMouseButton:
        _handle_mouse_button(event as InputEventMouseButton)
        return
    if event is InputEventMouseMotion:
        _handle_mouse_motion(event as InputEventMouseMotion)


# GP1: A contextual map hint, never a second task owner or save authority.
# No reward, stage flag, or tutorial progression is written to the canonical Save.
func _build_gp1_first_minutes_guide() -> void:
    gp1_guide_panel = Panel.new()
    gp1_guide_panel.name = "Gp1StarterGuide"
    gp1_guide_panel.position = Vector2(20, 145)
    gp1_guide_panel.size = Vector2(352, 149)
    gp1_guide_panel.z_index = 26
    gp1_guide_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    gp1_guide_panel.add_theme_stylebox_override("panel",_style(Color(0.95,0.92,0.82,0.97),JADE_DARK,2,12))
    add_child(gp1_guide_panel)

    gp1_guide_title = _label(gp1_guide_panel,"",Vector2(13,10),Vector2(294,24),15)
    gp1_guide_title.name = "Gp1GuideTitle"
    gp1_guide_title.add_theme_color_override("font_color",JADE_DARK)
    gp1_guide_description = _label(gp1_guide_panel,"",Vector2(13,38),Vector2(325,51),12)
    gp1_guide_description.name = "Gp1GuideDescription"
    gp1_guide_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    gp1_guide_description.add_theme_color_override("font_color",INK)

    gp1_guide_button = Button.new()
    gp1_guide_button.name = "Gp1GuideAction"
    gp1_guide_button.position = Vector2(13,99)
    gp1_guide_button.size = Vector2(325,40)
    gp1_guide_button.add_theme_font_size_override("font_size",14)
    gp1_guide_button.add_theme_color_override("font_color",PAPER_LIGHT)
    gp1_guide_button.add_theme_stylebox_override("normal",_style(JADE_DARK,PAPER_LIGHT,1,8))
    gp1_guide_button.pressed.connect(_gp1_guide_action)
    gp1_guide_panel.add_child(gp1_guide_button)

    var dismiss := Button.new()
    dismiss.name = "Gp1GuideDismiss"
    dismiss.text = "×"
    dismiss.position = Vector2(310,5)
    dismiss.size = Vector2(35,33)
    dismiss.tooltip_text = "Ẩn gợi ý trong phiên chơi hiện tại"
    dismiss.add_theme_font_size_override("font_size",17)
    dismiss.pressed.connect(_gp1_dismiss_guide)
    gp1_guide_panel.add_child(dismiss)
    _refresh_gp1_first_minutes_guide()

func _gp1_dismiss_guide() -> void:
    gp1_guide_dismissed = true
    if gp1_guide_panel != null:
        gp1_guide_panel.visible = false

func _gp1_first_minutes_model() -> Dictionary:
    if state == null or not runtime_ready:
        return {}
    var roster := state.disciples.size()
    if roster < 6 or roster > 12:
        return {}
    var capacity := state.sect.disciple_capacity
    if roster <= 6:
        if not gp1_hall_viewed:
            return {
                "stage":"hall","title":"BƯỚC 1/5 · ĐẠI ĐIỆN",
                "detail":"Khởi lập Tông Môn. Mở Đại Điện xem quản lý trước khi tuyển người.",
                "button":"MỞ ĐẠI ĐIỆN","action":"hall"
            }
        if not gp1_residence_viewed or roster >= capacity:
            var full := roster >= capacity
            return {
                "stage":"housing","title":"BƯỚC 2/5 · ĐỆ TỬ XÁ",
                "detail":("Đã đủ %d/%d chỗ. Xem điều kiện xây Nhà phụ; vật tư sẽ trừ thật." if full
                    else "Hiện có %d/%d đệ tử. Nhà khởi đầu còn chỗ, chưa cần xây thêm.") % [roster,capacity],
                "button":"XEM NHÀ Ở","action":"housing"
            }
        return {
            "stage":"recruit","title":"BƯỚC 3/5 · DẪN TIÊN ĐÀI",
            "detail":"Đệ tử %d/%d · Chiêu Mộ Lệnh %d. Mở tuyển mộ, chỉ nhận khi còn giường." % [
                roster,capacity,state.sect.disciple_recruitment_tokens],
            "button":"MỞ TUYỂN MỘ","action":"recruit"
        }

    var ids: Array = state.disciples.keys()
    ids.sort()
    var eligible_id: StringName = &""
    var any_unassigned := false
    var active_building_id: StringName = &""
    var active_destination: StringName = &""
    var building_system := BuildingSystem.new()
    var worksite_types := [
        BuildingSystem.TYPE_MINE, BuildingSystem.TYPE_LINH_FOREST,
        BuildingSystem.TYPE_SPIRIT_FIELD
    ]
    var sites: Array[BuildingState] = []
    for building_type in worksite_types:
        var site: BuildingState = building_system.primary_building(state,building_type)
        if site != null:
            sites.append(site)
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.worksite_building_id != &"" and state.buildings.has(str(disciple.worksite_building_id)):
            if active_building_id == &"":
                active_building_id = disciple.worksite_building_id
                active_destination = _sect_production_destination(
                    (state.buildings[str(active_building_id)] as BuildingState).building_type)
            continue
        if disciple.work_group_id != &"":
            continue
        any_unassigned = true
        for site in sites:
            if _workforce_candidate_reason(disciple,site,_workforce_occupants(site)).is_empty():
                eligible_id = disciple.id
                break
        if eligible_id != &"":
            break
    if eligible_id != &"":
        return {
            "stage":"assignment","title":"BƯỚC 4/5 · PHÂN CÔNG",
            "detail":"Có đệ tử rảnh. Chọn Mỏ, Linh Lâm hoặc Linh Điền đang đủ điều kiện.",
            "button":"CHỌN NGƯỜI LÀM VIỆC","action":"assignment","disciple_id":eligible_id
        }
    if any_unassigned:
        return {
            "stage":"blocked","title":"BƯỚC 4/5 · NGƯỜI ĐANG BẬN",
            "detail":"Chưa có người đủ điều kiện. Xem trạng thái hoặc chờ công việc kết thúc.",
            "button":"XEM ĐỆ TỬ","action":"disciples"
        }
    if active_destination != &"":
        return {
            "stage":"production","title":"BƯỚC 5/5 · XEM CÔNG VIỆC",
            "detail":"Đã có phân công thật. Mở công trình để xem mẻ, số liệu Kho và ETA.",
            "button":"MỞ CÔNG TRÌNH","action":"production",
            "building_id":active_building_id,"destination":active_destination
        }
    return {}

func _refresh_gp1_first_minutes_guide() -> void:
    if gp1_guide_panel == null:
        return
    var model := _gp1_first_minutes_model()
    var cover := build_mode_active or _building_operation_is_open() or _popup_is_open() \
        or _pve_hunt_overlay_is_open()
    for overlay_name in ["DaiDienScreenV1","DanTienScreenV2","DeTuXaScreenB1V1","DaiDienScreenB1V1"]:
        if get_node_or_null(overlay_name) != null:
            cover = true
    gp1_guide_panel.visible = not gp1_guide_dismissed and not cover and not model.is_empty()
    if not gp1_guide_panel.visible:
        return
    gp1_guide_title.text = str(model.get("title",""))
    gp1_guide_description.text = str(model.get("detail",""))
    gp1_guide_button.text = str(model.get("button",""))

func _gp1_guide_action() -> void:
    var model := _gp1_first_minutes_model()
    match str(model.get("action","")):
        "hall":
            _open_building(SectMapPresentation.DEST_MAIN_HALL)
        "housing":
            _open_building(SectMapPresentation.DEST_RESIDENCE)
        "recruit":
            _open_building(SectMapPresentation.DEST_GUIDANCE)
        "assignment":
            var target_id := StringName(model.get("disciple_id",""))
            if state.disciples.has(target_id):
                _open_disciple_quick_assignment(target_id)
        "disciples":
            _bottom_action("disciples")
        "production":
            var destination := StringName(model.get("destination",""))
            var building_id := StringName(model.get("building_id",""))
            if destination != &"" and state.buildings.has(str(building_id)):
                _open_building(destination,building_id)
    _refresh_gp1_first_minutes_guide()

func _build_focus_marker() -> void:
    focus_marker = Panel.new()
    focus_marker.size = FOCUS_MARKER_SIZE
    focus_marker.visible = false
    focus_marker.z_index = 80
    focus_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
    focus_marker.add_theme_stylebox_override("panel", _style(Color(1.0, 1.0, 1.0, 0.02), GOLD, 3, 41))
    map_layer.add_child(focus_marker)

func _build_camera_controls() -> void:
    var panel := Panel.new()
    camera_controls_panel = panel
    panel.position = Vector2(1204, 150)
    panel.size = Vector2(60, 252)
    panel.z_index = 20
    panel.mouse_filter = Control.MOUSE_FILTER_STOP
    panel.add_theme_stylebox_override("panel", _style(Color(0.91, 0.86, 0.72, 0.92), INK, 2, 14))
    add_child(panel)

    var plus := Button.new()
    plus.text = "+"
    plus.position = Vector2(8, 8)
    plus.size = Vector2(44, 44)
    plus.add_theme_font_size_override("font_size", 22)
    plus.tooltip_text = "Phóng to"
    plus.pressed.connect(_zoom_in)
    panel.add_child(plus)

    zoom_readout = Label.new()
    zoom_readout.position = Vector2(4, 55)
    zoom_readout.size = Vector2(52, 26)
    zoom_readout.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    zoom_readout.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    zoom_readout.add_theme_font_size_override("font_size", 12)
    zoom_readout.add_theme_color_override("font_color", INK)
    panel.add_child(zoom_readout)

    var minus := Button.new()
    minus.text = "−"
    minus.position = Vector2(8, 84)
    minus.size = Vector2(44, 44)
    minus.add_theme_font_size_override("font_size", 22)
    minus.tooltip_text = "Thu nhỏ"
    minus.pressed.connect(_zoom_out)
    panel.add_child(minus)

    focus_target_button = Button.new()
    focus_target_button.text = "Mục"
    focus_target_button.position = Vector2(8, 134)
    focus_target_button.size = Vector2(44, 44)
    focus_target_button.add_theme_font_size_override("font_size", 12)
    focus_target_button.tooltip_text = "Tới mục tiêu đang chọn"
    focus_target_button.disabled = true
    focus_target_button.pressed.connect(_focus_current_target)
    panel.add_child(focus_target_button)

    var reset := Button.new()
    reset.text = "Toàn"
    reset.position = Vector2(8, 184)
    reset.size = Vector2(44, 44)
    reset.add_theme_font_size_override("font_size", 12)
    reset.tooltip_text = "Về toàn cảnh"
    reset.pressed.connect(_reset_camera.bind(true))
    panel.add_child(reset)

    focus_readout = Label.new()
    focus_readout.text = ""
    focus_readout.position = Vector2(-156, 228)
    focus_readout.size = Vector2(208, 20)
    focus_readout.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    focus_readout.add_theme_font_size_override("font_size", 10)
    focus_readout.add_theme_color_override("font_color", Color(0.16, 0.16, 0.13, 0.74))
    focus_readout.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.add_child(focus_readout)

    var hint_background := Panel.new()
    hint_background.name = "CameraHintBackground"
    hint_background.position = Vector2(690, 598)
    hint_background.size = Vector2(494, 34)
    hint_background.z_index = 19
    hint_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hint_background.add_theme_stylebox_override("panel", _style(Color(0.06, 0.14, 0.12, 0.92), JADE, 1, 7))
    add_child(hint_background)
    var hint := Label.new()
    camera_hint = hint
    hint.text = "Chụm 2 ngón: zoom  •  Kéo: di chuyển  •  Chạm đúp: phóng nhanh"
    hint.position = Vector2(698, 602)
    hint.size = Vector2(478, 26)
    hint.z_index = 20
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    hint.add_theme_font_size_override("font_size", 11)
    hint.add_theme_color_override("font_color", Color(0.96, 0.92, 0.80, 1.0))
    hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(hint)

    _refresh_zoom_readout()
    _refresh_focus_readout()

func _handle_screen_touch(touch: InputEventScreenTouch) -> void:
    if touch.pressed:
        if not SectMapCamera.is_map_screen_point(touch.position):
            return
        if touch_points.is_empty():
            screen_pointer_dragged = false
        else:
            screen_pointer_dragged = true
        touch_points[touch.index] = touch.position
        if touch.double_tap:
            screen_pointer_dragged = true
            _zoom_at(touch.position, maxf(map_zoom, SectMapCamera.FOCUS_ZOOM), true)
            get_viewport().set_input_as_handled()
        _refresh_pinch_baseline()
        return

    var was_single_pointer := touch_points.size() == 1 and touch_points.has(touch.index)
    touch_points.erase(touch.index)
    _refresh_pinch_baseline()
    if was_single_pointer and not screen_pointer_dragged:
        if _try_iso_map_pick(touch.position):
            return
        if _disciple_summary_is_open():
            _close_disciple_summary(true)
        elif _building_operation_is_open():
            _close_building_operation_panel(true)

func _handle_screen_drag(drag: InputEventScreenDrag) -> void:
    if not touch_points.has(drag.index):
        return
    touch_points[drag.index] = drag.position

    if touch_points.size() >= 2:
        var pair := _first_two_touch_points()
        if pair.size() < 2:
            return
        var point_a: Vector2 = pair[0]
        var point_b: Vector2 = pair[1]
        var distance := point_a.distance_to(point_b)
        var center := (point_a + point_b) * 0.5
        if last_pinch_distance > 0.0001:
            var ratio := distance / last_pinch_distance
            if absf(ratio - 1.0) > 0.002:
                _zoom_at(center, map_zoom * ratio, false)
        last_pinch_distance = distance
        get_viewport().set_input_as_handled()
        return

    if drag.relative.length() > 2.0:
        screen_pointer_dragged = true
    _pan_camera(drag.relative)
    get_viewport().set_input_as_handled()

func _handle_mouse_button(mouse: InputEventMouseButton) -> void:
    if mouse.button_index == MOUSE_BUTTON_WHEEL_UP and mouse.pressed:
        if SectMapCamera.is_map_screen_point(mouse.position):
            _zoom_at(mouse.position, map_zoom * ZOOM_STEP, false)
            get_viewport().set_input_as_handled()
        return

    if mouse.button_index == MOUSE_BUTTON_WHEEL_DOWN and mouse.pressed:
        if SectMapCamera.is_map_screen_point(mouse.position):
            _zoom_at(mouse.position, map_zoom / ZOOM_STEP, false)
            get_viewport().set_input_as_handled()
        return

    if mouse.button_index != MOUSE_BUTTON_LEFT:
        return

    if mouse.pressed:
        if not SectMapCamera.is_map_screen_point(mouse.position):
            return
        mouse_pointer_dragged = false
        if mouse.double_click:
            mouse_pointer_dragged = true
            _zoom_at(mouse.position, maxf(map_zoom, SectMapCamera.FOCUS_ZOOM), true)
            get_viewport().set_input_as_handled()
            return
        mouse_panning = true
    else:
        var was_map_tap := mouse_panning and not mouse_pointer_dragged
        var should_close_summary := mouse_panning and not mouse_pointer_dragged and _disciple_summary_is_open()
        var should_close_building := mouse_panning and not mouse_pointer_dragged and _building_operation_is_open()
        mouse_panning = false
        if was_map_tap and _try_iso_map_pick(mouse.position):
            return
        if should_close_summary:
            _close_disciple_summary(true)
        elif should_close_building:
            _close_building_operation_panel(true)

func _handle_mouse_motion(motion: InputEventMouseMotion) -> void:
    if not mouse_panning:
        return
    if (motion.button_mask & MOUSE_BUTTON_MASK_LEFT) == 0:
        mouse_panning = false
        return
    if motion.relative.length() > 2.0:
        mouse_pointer_dragged = true
    _pan_camera(motion.relative)
    get_viewport().set_input_as_handled()

func _zoom_in() -> void:
    _zoom_at(_camera_center(), map_zoom * ZOOM_STEP, true)

func _zoom_out() -> void:
    _zoom_at(_camera_center(), map_zoom / ZOOM_STEP, true)

func _zoom_at(screen_point: Vector2, requested_zoom: float, animate: bool) -> void:
    var transform := SectMapCamera.zoom_around_screen_point(map_layer.position, map_zoom, requested_zoom, screen_point)
    var target_position: Vector2 = transform["position"]
    _apply_camera(float(transform["zoom"]), target_position, animate)

func _pan_camera(delta: Vector2) -> void:
    var next_position := SectMapCamera.pan_position(map_layer.position, delta, map_zoom)
    _apply_camera(map_zoom, next_position, false)

func _focus_world_point(world_point: Vector2, requested_zoom: float = SectMapCamera.FOCUS_ZOOM) -> void:
    var target_zoom := maxf(map_zoom, requested_zoom)
    var transform := SectMapCamera.focus_transform(world_point, target_zoom)
    var target_position: Vector2 = transform["position"]
    _apply_camera(float(transform["zoom"]), target_position, true)

func _focus_current_target() -> void:
    if not has_focus_target:
        return
    if focused_kind == &"disciple":
        _refresh_focused_disciple_point()
    _refresh_disciple_summary_content()
    _refresh_building_operation_content()
    _refresh_living_cues()
    _focus_world_point(focused_world_point)
    _pulse_focus_marker()

func _set_focus_target(world_point: Vector2, kind: StringName, target_id: StringName, label: String, focus_now: bool) -> void:
    focused_world_point = world_point
    focused_kind = kind
    focused_id = target_id
    focused_label = label
    has_focus_target = true
    # Selecting a site does not reconfigure a single BuildingState: the
    # renderer only promotes its temporary illustration to detail LOD.
    if iso_world != null:
        iso_world.set_selected_visual_site(target_id if kind == &"building" else &"")
    _position_focus_marker(world_point)
    if focus_target_button != null:
        focus_target_button.disabled = false
    _refresh_focus_readout()
    _refresh_actor_status_label_visibility()
    if focus_now:
        _focus_world_point(world_point)
    _pulse_focus_marker()

func _position_focus_marker(world_point: Vector2) -> void:
    if focus_marker == null:
        return
    focus_marker.position = world_point - FOCUS_MARKER_SIZE * 0.5
    focus_marker.visible = true

func _pulse_focus_marker() -> void:
    if focus_marker == null or not focus_marker.visible:
        return
    if focus_marker_tween != null and focus_marker_tween.is_valid():
        focus_marker_tween.kill()
    focus_marker.modulate = Color(1.0, 1.0, 1.0, 0.45)
    focus_marker_tween = create_tween()
    focus_marker_tween.set_loops(2)
    focus_marker_tween.tween_property(focus_marker, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.14)
    focus_marker_tween.tween_property(focus_marker, "modulate", Color(1.0, 1.0, 1.0, 0.45), 0.14)

func _refresh_focused_disciple_point() -> void:
    if focused_id == &"":
        return
    if not actor_virtual_positions.has(str(focused_id)):
        return
    focused_world_point = _disciple_map_point(focused_id)
    _position_focus_marker(focused_world_point)

func _disciple_map_point(disciple_id: StringName) -> Vector2:
    var key := str(disciple_id)
    var actor := actor_nodes.get(key) as Control
    if actor != null and is_instance_valid(actor):
        return actor.position + actor.size * 0.5
    if actor_virtual_positions.has(key):
        var virtual_position: Vector2 = actor_virtual_positions[key]
        return virtual_position + DiscipleActorVisualCatalog.ACTOR_BOX_SIZE * 0.5
    return SectMapPresentation.position_for_destination(SectMapPresentation.DEST_COURTYARD)

func _refresh_focus_readout() -> void:
    if focus_readout != null:
        focus_readout.text = focused_label if has_focus_target else ""

func _reset_camera(animate: bool = true) -> void:
    if state != null and int(state.sect.world_layout_version) == 2:
        var focus_delta: Vector2 = SectIsometricWorldV1.project(SectIsometricWorldV1.NEW_GAME_FOCUS_CELL) \
            - SectIsometricWorldV1.project(SectIsometricWorldV1.CENTER_CELL)
        var focus_world := SectIsometricWorldV1.LEGACY_ANCHOR+focus_delta
        var layout_transform := SectMapCamera.focus_transform(focus_world,0.75)
        _apply_camera(float(layout_transform["zoom"]),layout_transform["position"],animate)
        return
    var transform := SectMapCamera.reset_transform()
    var target_position: Vector2 = transform["position"]
    _apply_camera(float(transform["zoom"]), target_position, animate)

func _apply_camera(zoom: float, position: Vector2, animate: bool) -> void:
    map_zoom = SectMapCamera.clamp_zoom(zoom)
    var target_scale := Vector2.ONE * map_zoom
    var target_position := SectMapCamera.clamp_position(position, map_zoom)

    if camera_tween != null and camera_tween.is_valid():
        camera_tween.kill()

    if animate:
        camera_tween = create_tween()
        camera_tween.set_parallel(true)
        camera_tween.set_trans(Tween.TRANS_QUAD)
        camera_tween.set_ease(Tween.EASE_OUT)
        camera_tween.tween_property(map_layer, "scale", target_scale, CAMERA_TWEEN_SECONDS)
        camera_tween.tween_property(map_layer, "position", target_position, CAMERA_TWEEN_SECONDS)
    else:
        map_layer.scale = target_scale
        map_layer.position = target_position

    _refresh_world_actor_visibility()
    _refresh_zoom_readout()

func _refresh_world_actor_visibility() -> void:
    # Materialize a bounded set of sect NPCs in the camera viewport. Selected
    # and working disciples take priority; off-screen and remote disciples keep
    # their canonical simulation state without allocating presentation actors.
    if map_layer == null or state == null:
        return
    var view := SectMapCamera.VIEW_RECT
    var visible_ids: Dictionary = {}
    var candidates: Array[Dictionary] = []
    var screen_transform: Transform2D = map_layer.get_global_transform()
    var actor_size := DiscipleActorVisualCatalog.ACTOR_BOX_SIZE
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple_id := StringName(raw_id)
        var key := str(disciple_id)
        if not actor_virtual_positions.has(key):
            continue
        var disciple: DiscipleState = state.disciples[disciple_id]
        if disciple.region_id != &"sect" or not disciple.active_pve_encounter_id.is_empty():
            continue
        var idle_in_sect := _is_idle_map_actor(disciple)
        var phase := StringName(disciple.work_cycle_state.get("phase",""))
        var travelling_to_work := disciple.work_group_id != &"" and phase == &"travel_out"
        var visual_transition := Time.get_ticks_msec() < int(actor_transition_deadline_msec.get(key,0))
        # Busy workers are represented by the worksite panel while inside. Show
        # idle residents and short assignment transitions on the sect map.
        if not idle_in_sect and not travelling_to_work and not visual_transition:
            continue
        var local_top_left: Vector2 = actor_virtual_positions[key]
        var screen_top_left: Vector2 = screen_transform * local_top_left
        var screen_size := Vector2(
            absf(screen_transform.x.x)*actor_size.x+absf(screen_transform.y.x)*actor_size.y,
            absf(screen_transform.x.y)*actor_size.x+absf(screen_transform.y.y)*actor_size.y
        )
        var rect := Rect2(screen_top_left,screen_size)
        if not view.encloses(rect):
            continue
        var is_selected := disciple_id == selected_id and focused_kind != &"building"
        var priority := 4
        if is_selected:
            priority = 0
        elif travelling_to_work or visual_transition:
            priority = 1
        elif disciple.current_action in [&"IDLE",&"EVALUATE"]:
            priority = 2
        candidates.append({
            "key":key,
            "destination":str(actor_destinations.get(key,SectMapPresentation.DEST_COURTYARD)),
            "priority":priority
        })
    candidates.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
        var priority_a := int(a.get("priority",4))
        var priority_b := int(b.get("priority",4))
        if priority_a != priority_b:
            return priority_a < priority_b
        return str(a.get("key","")) < str(b.get("key",""))
    )
    var destination_counts: Dictionary = {}
    for candidate in candidates:
        if visible_ids.size() >= MAX_VISIBLE_SECT_DISCIPLE_ACTORS:
            break
        var key := str(candidate.get("key",""))
        var destination := str(candidate.get("destination",SectMapPresentation.DEST_COURTYARD))
        var count := int(destination_counts.get(destination,0))
        if count >= MAX_VISIBLE_ACTORS_PER_DESTINATION:
            continue
        destination_counts[destination] = count + 1
        visible_ids[key] = true
    for raw_id in actor_nodes.keys().duplicate():
        var key := str(raw_id)
        if not visible_ids.has(key):
            _recycle_modular_actor(key)
    for raw_id in visible_ids.keys():
        var key := str(raw_id)
        if not actor_nodes.has(key):
            _materialize_modular_actor(key)
        var actor := actor_nodes.get(key) as ModularDiscipleActor
        if actor != null and is_instance_valid(actor):
            actor.visible = true
    _refresh_actor_status_label_visibility()

func _selected_worker_is_inside_producer(disciple: DiscipleState) -> bool:
    # Indoor workers are represented by their real building roster/timer panel,
    # not a second character sprite outside the building. Simulation is untouched.
    if disciple == null or state == null or disciple.region_id != &"sect" \
            or not disciple.active_pve_encounter_id.is_empty() \
            or disciple.worksite_building_id == &"":
        return false
    var building = state.buildings.get(str(disciple.worksite_building_id))
    if not (building is BuildingState) \
            or _sect_production_destination(building.building_type) == &"":
        return false
    return str(disciple.current_action).begins_with("WORK_") \
        or disciple.current_action in [&"HOLD", &"EVALUATE", &"IDLE"]

func _refresh_zoom_readout() -> void:
    if zoom_readout != null:
        zoom_readout.text = "%d%%" % int(round(map_zoom * 100.0))

func _refresh_pinch_baseline() -> void:
    if touch_points.size() < 2:
        last_pinch_distance = 0.0
        return
    var pair := _first_two_touch_points()
    if pair.size() >= 2:
        var point_a: Vector2 = pair[0]
        var point_b: Vector2 = pair[1]
        last_pinch_distance = point_a.distance_to(point_b)

func _first_two_touch_points() -> Array:
    var keys: Array = touch_points.keys()
    keys.sort()
    if keys.size() < 2:
        return []
    var point_a: Vector2 = touch_points[keys[0]]
    var point_b: Vector2 = touch_points[keys[1]]
    return [point_a, point_b]

func _camera_center() -> Vector2:
    return SectMapCamera.VIEW_RECT.position + SectMapCamera.VIEW_RECT.size * 0.5

func _popup_is_open() -> bool:
    if (popup_layer != null and popup_layer.get_child_count() > 0) \
            or (pve_party_picker_shade != null and pve_party_picker_shade.visible):
        return true
    # B1 facility screens sit outside popup_layer. Keep map pointer handling
    # from consuming their button releases before Control dispatches clicks.
    for overlay_name in [
        "DaiDienScreenV1", "DaiDienScreenB1V1", "DeTuXaScreenB1V1",
        "DanTienScreenV2", "DanTienScreenB1V1"
    ]:
        if get_node_or_null(overlay_name) != null:
            return true
    return false

func _close_top_management_screen() -> void:
    _clear_pointer_state()
    if popup_layer != null and popup_layer.get_child_count() > 0:
        if popup_layer.get_node_or_null("DiscipleDeepScreen") != null:
            _return_to_disciple_summary()
        else:
            _clear_popup()
        return
    for overlay_name in ["DaiDienScreenV1", "DaiDienScreenB1V1", "DeTuXaScreenB1V1", "DanTienScreenV2", "DanTienScreenB1V1"]:
        var overlay := get_node_or_null(overlay_name)
        if overlay != null:
            overlay.queue_free()
            opened_disciple_profile = false
            return
    if _building_operation_is_open():
        _close_building_operation_panel(true)
        return
    if _disciple_summary_is_open():
        _close_disciple_summary(true)

func _clear_pointer_state() -> void:
    touch_points.clear()
    last_pinch_distance = 0.0
    mouse_panning = false
    screen_pointer_dragged = false
    mouse_pointer_dragged = false

func _open_building(destination: StringName, instance_id: StringName = &"") -> void:
    if build_mode_active:
        _leave_build_mode(false)
    _dismiss_facility_screens()
    _clear_popup()
    opened_disciple_profile = false
    _close_disciple_summary(true)
    selected_building = destination
    if destination == SectMapPresentation.DEST_MAIN_HALL:
        gp1_hall_viewed = true
    elif destination == SectMapPresentation.DEST_RESIDENCE:
        gp1_residence_viewed = true
    selected_production_instance_id = &""
    var point := _iso_actor_point(destination)
    if instance_id != &"" and state.buildings.has(str(instance_id)):
        var requested: BuildingState = state.buildings[str(instance_id)]
        if _sect_production_destination(requested.building_type) == destination:
            selected_production_instance_id = requested.id
            point = _iso_actor_point(destination,requested.id)
    _set_focus_target(point, &"building", destination, _building_name(destination), true)
    if iso_world != null:
        # Focused_kind preserves the original destination contract; only the
        # VIEW detail selector uses a distinct canonical worksite instance ID.
        iso_world.set_selected_visual_site(selected_production_instance_id)
    _show_building_operation_panel()
    _refresh_map_worksite_cues()

func _dismiss_facility_screens() -> void:
    for overlay_name in ["DaiDienScreenV1", "DaiDienScreenB1V1", "DeTuXaScreenB1V1", "DanTienScreenV2", "DanTienScreenB1V1"]:
        var overlay := get_node_or_null(overlay_name)
        if overlay != null:
            overlay.queue_free()

func _install_main_isometric_world() -> void:
    if map_layer == null or iso_world != null:
        return
    iso_view_container = SubViewportContainer.new()
    iso_view_container.name = "SectMainIsoViewportContainer"
    iso_view_container.position = SectMapCamera.VIEW_RECT.position
    iso_view_container.size = SectMapCamera.VIEW_RECT.size
    iso_view_container.stretch = false
    iso_view_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(iso_view_container)
    move_child(iso_view_container,map_layer.get_index())

    iso_viewport = SubViewport.new()
    iso_viewport.name = "SectMainIsoSubViewport"
    iso_viewport.size = Vector2i(1280,570)
    iso_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
    iso_viewport.gui_disable_input = true
    iso_view_container.add_child(iso_viewport)

    iso_world = SectIsometricWorldV1.new()
    iso_world.name = "SectIsoWorld192"
    iso_world.configure_map_layout_version(int(state.sect.world_layout_version))
    iso_viewport.add_child(iso_world)
    iso_world.refresh_from_state(state)
    for node in map_layer.get_children():
        if node is ModularDiscipleActor:
            continue
        if node is CanvasItem:
            (node as CanvasItem).visible = false
        if node is Control:
            _disable_legacy_hit_input(node)
    iso_world.set_legacy_transform(map_layer.scale.x,map_layer.position)

func _disable_legacy_hit_input(parent: Node) -> void:
    if parent is Control:
        (parent as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
    for child in parent.get_children():
        _disable_legacy_hit_input(child)

func _iso_actor_point(destination: StringName, building_id: StringName = &"") -> Vector2:
    if iso_world == null:
        return SectMapPresentation.position_for_destination(destination)
    var saved_origin := SectResidenceSiteV1.UNSELECTED
    if state != null and building_id != &"":
        var actual = state.buildings.get(str(building_id))
        if actual is BuildingState and actual.building_type == BuildingSystem.TYPE_RESIDENCE:
            saved_origin = SectResidenceSiteV1.origin_of(actual)
    return SectIsometricWorldV1.virtual_legacy_point(destination,building_id,saved_origin,
        int(state.sect.world_layout_version) if state != null else 0)

func _sect_actor_door_offset(disciple: DiscipleState, index: int,
        idle_slots: Dictionary, destination: StringName) -> Vector2:
    # DD-09.2: actors stop in a small queue at the outdoor interaction tile,
    # not scattered across a building interior or on the roof.
    if destination in [SectMapPresentation.DEST_COURTYARD, SectMapPresentation.DEST_GATE]:
        return _endgame_actor_offset(disciple,index,idle_slots)
    return Vector2(float(posmod(index, 5) - 2) * 6.0, 0.0)

func _sect_effective_door_destination(disciple: DiscipleState, destination: StringName) -> StringName:
    # Keep a worker staged at the same workshop door between simulation
    # minute actions. Active REST/TRAIN_BODY/HEAL/etc must follow the action,
    # never be overridden by an old resource worksite reservation.
    if disciple.current_action not in [&"EVALUATE", &"IDLE"]:
        return destination
    var id := disciple.worksite_building_id
    if id != &"" and state.buildings.has(str(id)):
        var building: BuildingState = state.buildings[str(id)]
        var worksite_dest := _sect_production_destination(building.building_type)
        if worksite_dest != &"":
            return worksite_dest
    return destination

func _sect_door_worksite_id(disciple: DiscipleState, destination: StringName) -> StringName:
    # REST uses the actual rented House. A stale workshop ID never overrides
    # the resting destination; no AStar navigation runs in sect presentation.
    if destination == SectMapPresentation.DEST_RESIDENCE and SectHallSystemV1.installed(state):
        return StringName(SectResidenceSystemV1.house_of(state,disciple.id))
    var worksite_id := disciple.worksite_building_id
    if worksite_id != &"" and state.buildings.has(str(worksite_id)):
        var site: BuildingState = state.buildings[str(worksite_id)]
        if _sect_production_destination(site.building_type) == destination:
            return worksite_id
    return &""

func _iso_two_direction_delta(delta: Vector2, old_facing: StringName) -> Vector2:
    # Source A pool has horizontal authored facing. Vertical travel preserves
    # the existing horizontal face and does not invent an up/down clip.
    var x := delta.x
    if absf(x) <= 0.01:
        x = -1.0 if old_facing == &"left" else 1.0
    return Vector2(-1.0 if x < 0.0 else 1.0,0.0)

func _cell_at_map_screen(screen_point: Vector2) -> Vector2i:
    var fractional := SectIsometricWorldV1.inverse(iso_world.screen_to_world(screen_point))
    return Vector2i(roundi(fractional.x),roundi(fractional.y))

func _try_iso_map_pick(screen_point: Vector2) -> bool:
    if iso_world == null or not SectMapCamera.is_map_screen_point(screen_point):
        return false
    if _point_over_build_mode_panel(screen_point):
        return false
    if build_mode_active:
        _select_build_mode_site(_cell_at_map_screen(screen_point))
        get_viewport().set_input_as_handled()
        return true
    if _popup_is_open() or _building_operation_is_open() or _disciple_summary_is_open():
        return false
    var picked := iso_world.pick_at_screen(screen_point)
    if picked.is_empty():
        return false
    var destination := StringName(picked.get("destination",""))
    if destination == &"":
        return false
    var building_id := StringName(picked.get("building_id",""))
    _open_building(destination,building_id)
    get_viewport().set_input_as_handled()
    return true

func _sect_production_destination(building_type: StringName) -> StringName:
    match building_type:
        BuildingSystem.TYPE_MAIN_HALL:
            return SectMapPresentation.DEST_MAIN_HALL
        BuildingSystem.TYPE_MINE:
            return SectMapPresentation.DEST_MINE
        BuildingSystem.TYPE_LINH_FOREST:
            return SectMapPresentation.DEST_LINH_FOREST
        BuildingSystem.TYPE_SPIRIT_FIELD:
            return SectMapPresentation.DEST_SPIRIT_FIELD
        BuildingSystem.TYPE_RESIDENCE:
            return SectMapPresentation.DEST_RESIDENCE
    return &""

func _workforce_occupants(building: BuildingState) -> Array[StringName]:
    if building == null:
        return []
    return BuildingSystem.new().assigned_worker_ids(state,building)

func _workforce_candidate_reason(actor: DiscipleState, building: BuildingState, current: Array[StringName]) -> String:
    if current.has(actor.id):
        return "Đang phụ trách"
    if actor.region_id != &"sect" or not actor.active_pve_encounter_id.is_empty():
        return "Đang xuất môn / PvE"
    if actor.worksite_building_id != &"":
        var old_site = state.buildings.get(str(actor.worksite_building_id))
        if not (old_site is BuildingState) or old_site.worker_group_id != actor.work_group_id:
            return "Điểm làm việc cũ không hợp lệ"
    if not actor.work_cycle_state.is_empty():
        var phase := str(actor.work_cycle_state.get("phase",actor.work_cycle_state.get("status","")))
        if phase == "travel_out":
            return "Lượt cũ: đang đi mỏ (travel_out)"
        return "Đang xử lý lượt làm việc" if phase == "" else "Đang làm: %s" % phase
    if not actor.direct_command.is_empty():
        return "Đang có lệnh chờ xử lý"
    if actor.current_action not in [&"EVALUATE",&"IDLE",&"HOLD"]:
        return "Đang: %s" % SectMapPresentation.action_label(actor.current_action)
    var buildings := BuildingSystem.new()
    if buildings.disciple_has_active_timed_recipe(state,actor.id) or buildings.disciple_has_active_spirit_plot(state,actor.id) or DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,actor):
        return "Đang có lượt sản xuất / Rèn Thân"
    return ""

func _can_cancel_queued_assignment_command(disciple: DiscipleState) -> bool:
    if disciple == null or disciple.direct_command.is_empty():
        return false
    if disciple.region_id != &"sect" or not disciple.active_pve_encounter_id.is_empty() or not disciple.work_cycle_state.is_empty():
        return false
    if disciple.current_action not in [&"EVALUATE",&"IDLE",&"HOLD"]:
        return false
    var buildings := BuildingSystem.new()
    return not buildings.disciple_has_active_timed_recipe(state,disciple.id) \
        and not buildings.disciple_has_active_spirit_plot(state,disciple.id) \
        and not DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,disciple)

func _ensure_disabled_controls_readable(root_node: Node) -> void:
    for child in root_node.get_children():
        if child is Button:
            var button := child as Button
            button.add_theme_color_override("font_disabled_color",INK)
            button.add_theme_stylebox_override("disabled",_style(Color(0.84,0.83,0.75),Color(0.46,0.44,0.37),1,8))
        _ensure_disabled_controls_readable(child)

func _disciple_source_a_portrait_texture(disciple: DiscipleState) -> Texture2D:
    if disciple == null:
        return null
    var scene_path := DiscipleSourceAVisualPool.scene_path_for_disciple(disciple)
    if scene_path.is_empty():
        return null
    if source_a_portrait_textures.has(scene_path):
        return source_a_portrait_textures[scene_path] as Texture2D
    var packed := DiscipleSourceAVisualPool.scene_for_disciple(disciple)
    if packed == null:
        return null
    var preview := packed.instantiate() as AnimatedSprite2D
    if preview == null:
        return null
    var texture: Texture2D = null
    var frames := preview.sprite_frames
    if frames != null and frames.has_animation(&"stand") and frames.get_frame_count(&"stand") > 0:
        texture = frames.get_frame_texture(&"stand",0)
    preview.free()
    if texture != null:
        source_a_portrait_textures[scene_path] = texture
    return texture

func _disciple_avatar_button(disciple: DiscipleState, edge: float) -> Button:
    var avatar := Button.new()
    avatar.text = disciple.display_name.substr(0,1)
    avatar.custom_minimum_size = Vector2(edge,edge)
    avatar.add_theme_color_override("font_color",INK)
    avatar.add_theme_stylebox_override("normal",_style(Color(0.86,0.91,0.77),JADE_DARK,1,8))
    var actor := actor_nodes.get(str(disciple.id)) as ModularDiscipleActor
    var baked_texture: Texture2D = _disciple_source_a_portrait_texture(disciple) if actor == null or not actor.production_body_active() else null
    if baked_texture != null:
        var portrait := TextureRect.new()
        portrait.name = "VerifiedSourceAPortrait"
        portrait.texture = baked_texture
        portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
        avatar.text = ""
        avatar.add_child(portrait)
        return avatar
    var look := DiscipleActorVisualCatalog.default_appearance_for_disciple(disciple)
    var garment := Color.from_string(str(look.get("outfit_tint","455472")),Color(0.27,0.33,0.45))
    var hair_tint := Color.from_string(str(look.get("hair_tint","2b2624")),Color(0.17,0.15,0.14))
    var stage := Control.new()
    stage.name = "FallbackPortrait"
    stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var chest := Panel.new()
    chest.position = Vector2(edge*0.15,edge*0.62)
    chest.size = Vector2(edge*0.70,edge*0.33)
    chest.mouse_filter = Control.MOUSE_FILTER_IGNORE
    chest.add_theme_stylebox_override("panel",_style(garment,INK,1,5))
    stage.add_child(chest)
    var face := Panel.new()
    face.position = Vector2(edge*0.29,edge*0.23)
    face.size = Vector2(edge*0.42,edge*0.43)
    face.mouse_filter = Control.MOUSE_FILTER_IGNORE
    face.add_theme_stylebox_override("panel",_style(Color(0.94,0.79,0.65),INK,1,9))
    stage.add_child(face)
    var hair := Panel.new()
    hair.position = Vector2(edge*0.24,edge*0.12)
    hair.size = Vector2(edge*0.52,edge*0.20)
    hair.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hair.add_theme_stylebox_override("panel",_style(hair_tint,INK,1,8))
    stage.add_child(hair)
    avatar.text = ""
    avatar.tooltip_text = disciple.display_name
    avatar.add_child(stage)
    return avatar

func _quick_assignment_withdraw_block_reason(disciple: DiscipleState) -> String:
    if not disciple.active_pve_encounter_id.is_empty():
        return "Đệ tử đang tham chiến; không thể rút khỏi công việc."
    var buildings := BuildingSystem.new()
    var resource_job := buildings.active_resource_timer_for_worker(state,disciple.id)
    if not resource_job.is_empty():
        var resource_name := ResourceRegistry.new().display_name(StringName(resource_job.get("resource_id","")))
        var remaining := maxi(int(resource_job.get("finish_tick",state.tick))-state.tick,0)
        return "Mẻ %s đang chạy; còn %d phút tới khi nhập Kho." % [resource_name,remaining]
    if buildings.disciple_has_active_spirit_plot(state,disciple.id):
        for raw_building in state.buildings.values():
            if not (raw_building is BuildingState) or raw_building.building_type != BuildingSystem.TYPE_SPIRIT_FIELD:
                continue
            for raw_plot in buildings.spirit_field_plots(state,raw_building):
                if raw_plot is Dictionary and str(raw_plot.get("assigned_worker_id","")) == str(disciple.id):
                    var remaining := maxi(int(raw_plot.get("finish_tick",state.tick))-state.tick,0)
                    return "Đang chăm Linh Điền; còn %d phút tới khi thu hoạch." % remaining
        return "Đệ tử đang giữ một ô Linh Điền; chỉ rút sau khi thu hoạch."
    var alchemy_job := buildings.active_alchemy_job_for_worker(state,disciple.id)
    if not alchemy_job.is_empty():
        var remaining := maxi(int(alchemy_job.get("finish_tick",state.tick))-state.tick,0)
        return "Mẻ Luyện Đan đang chạy; còn %d phút tới khi hoàn thành." % remaining
    return ""


func _withdraw_disciple_from_quick_assignment(disciple_id: StringName, to_summary: bool) -> void:
    if not state.disciples.has(disciple_id):
        return
    var disciple: DiscipleState = state.disciples[disciple_id]
    var blocked := _quick_assignment_withdraw_block_reason(disciple)
    if not blocked.is_empty():
        _open_disciple_quick_assignment(disciple_id,to_summary,blocked)
        return
    if disciple.work_group_id == &"" and disciple.worksite_building_id == &"":
        _open_disciple_quick_assignment(disciple_id,to_summary,"Đệ tử hiện không có công việc cần rút.")
        return
    if not workforce.assign_group(state,disciple_id,&""):
        _open_disciple_quick_assignment(disciple_id,to_summary,"Workforce V2 chưa thể rút đệ tử khỏi việc này.")
        return
    var message := "Đã rút đệ tử khỏi công việc. Sản phẩm đã nhập Kho được giữ nguyên."
    if runtime_session == null or runtime_session.owner == null:
        message += " Cảnh báo: phiên lưu chưa sẵn sàng."
    else:
        var persisted: Dictionary = runtime_session.save()
        if not bool(persisted.get("ok",false)):
            message += " Cảnh báo: SaveService chưa lưu được thay đổi."
    _open_disciple_quick_assignment(disciple_id,to_summary,message)


func _open_disciple_quick_assignment(disciple_id: StringName, preserve_summary_origin: bool = false, feedback_message: String = "") -> void:
    if not state.disciples.has(disciple_id):
        return
    var disciple: DiscipleState = state.disciples[disciple_id]
    var returning_to_summary := _disciple_summary_is_open() or preserve_summary_origin
    disciple_quick_assignment_return_to_summary = returning_to_summary
    selected_id = disciple_id
    _hide_disciple_summary()
    _clear_popup()
    _add_dim()
    var panel := Panel.new()
    panel.name = "DiscipleQuickAssignment"
    panel.position = Vector2(310,87)
    panel.size = Vector2(660,546)
    panel.add_theme_stylebox_override("panel",_style(PAPER_LIGHT,INK,3,16))
    popup_layer.add_child(panel)
    var heading := _label(panel,"PHÂN CÔNG · %s" % disciple.display_name,Vector2(22,12),Vector2(475,37),22)
    heading.add_theme_color_override("font_color",JADE_DARK)
    var message := "Chọn công trình đang có. Chỉ người rảnh mới được giao việc." if feedback_message == "" else feedback_message
    var description := _label(panel,message,Vector2(22,51),Vector2(604,29),13)
    description.add_theme_color_override("font_color",INK)
    var back := Button.new()
    back.name = "DiscipleQuickAssignmentBack"
    back.text = "← Hồ sơ"
    back.position = Vector2(514,12)
    back.size = Vector2(125,43)
    back.add_theme_color_override("font_color",INK)
    back.add_theme_stylebox_override("normal",_style(Color(0.88,0.82,0.67),INK,1,8))
    back.pressed.connect(Callable(self,"_return_from_disciple_quick_assignment").bind(disciple_id,returning_to_summary))
    panel.add_child(back)
    var scroll := ScrollContainer.new()
    scroll.name = "DiscipleQuickAssignmentScroll"
    scroll.position = Vector2(22,92)
    scroll.size = Vector2(614,427)
    var has_pending_command := _can_cancel_queued_assignment_command(disciple)
    var has_work_assignment := disciple.work_group_id != &"" or disciple.worksite_building_id != &""
    if has_pending_command or has_work_assignment:
        var next_control_x := 22.0
        if has_pending_command:
            var cancel_button := Button.new()
            cancel_button.name = "QuickAssignmentCancelPendingCommand"
            cancel_button.text = "Hủy lệnh chờ"
            cancel_button.position = Vector2(next_control_x,88)
            cancel_button.size = Vector2(154,42)
            cancel_button.add_theme_font_size_override("font_size",13)
            cancel_button.add_theme_stylebox_override("normal",_style(CINNABAR,PAPER_LIGHT,1,8))
            cancel_button.tooltip_text = "Chỉ hủy lệnh chưa chạy; không xóa sản phẩm, công việc đang chạy hoặc công trình."
            cancel_button.pressed.connect(Callable(self,"_cancel_quick_assignment_pending_command").bind(disciple_id,returning_to_summary))
            panel.add_child(cancel_button)
            next_control_x += 162.0
        var hint_x := next_control_x
        if has_work_assignment:
            var withdraw_reason := _quick_assignment_withdraw_block_reason(disciple)
            var withdraw_button := Button.new()
            withdraw_button.name = "QuickAssignmentWithdraw"
            withdraw_button.text = "Rút khỏi việc"
            withdraw_button.position = Vector2(next_control_x,88)
            withdraw_button.size = Vector2(160,42)
            withdraw_button.add_theme_font_size_override("font_size",13)
            withdraw_button.add_theme_stylebox_override("normal",_style(Color(0.88,0.82,0.67),INK,1,8))
            withdraw_button.disabled = not withdraw_reason.is_empty()
            withdraw_button.tooltip_text = withdraw_reason if not withdraw_reason.is_empty() else "Chu kỳ chưa hoàn tất sẽ dừng; sản phẩm đã nhập Kho được giữ nguyên."
            withdraw_button.pressed.connect(Callable(self,"_withdraw_disciple_from_quick_assignment").bind(disciple_id,returning_to_summary))
            panel.add_child(withdraw_button)
            hint_x += 168.0
        var hint_text := "Hủy lệnh chờ để chọn công việc mới." if has_pending_command else "Có thể rút người khỏi đội và xưởng."
        var current_block_reason := _quick_assignment_withdraw_block_reason(disciple) if has_work_assignment else ""
        if not current_block_reason.is_empty():
            hint_text = current_block_reason
        elif has_work_assignment:
            hint_text = "Rút sẽ hủy chu kỳ chưa hoàn tất; sản phẩm đã nhập Kho không mất."
        var hint_width := 638.0 - hint_x
        var control_hint := _label(panel,hint_text,Vector2(hint_x,92),Vector2(maxf(hint_width,170.0),40),12)
        control_hint.add_theme_color_override("font_color",INK)
        scroll.position = Vector2(22,140)
        scroll.size = Vector2(614,379)
    panel.add_child(scroll)
    var rows := VBoxContainer.new()
    rows.name = "DiscipleQuickAssignmentRows"
    rows.custom_minimum_size = Vector2(587,0)
    rows.add_theme_constant_override("separation",8)
    scroll.add_child(rows)
    var count := 0
    var definitions := [
        {"type":BuildingSystem.TYPE_MINE,"name":"MỎ KHOÁNG"},
        {"type":BuildingSystem.TYPE_LINH_FOREST,"name":"LINH LÂM"},
        {"type":BuildingSystem.TYPE_SPIRIT_FIELD,"name":"LINH ĐIỀN"}
    ]
    for item in definitions:
        var building_type := StringName(item["type"])
        var instances: Array[BuildingState] = []
        for raw_building in state.buildings.values():
            if raw_building is BuildingState and (raw_building as BuildingState).building_type == building_type:
                instances.append(raw_building)
        instances.sort_custom(func(a: BuildingState,b: BuildingState) -> bool: return str(a.id)<str(b.id))
        var group_name := Label.new()
        group_name.text = "%s · %d công trình" % [str(item["name"]),instances.size()]
        group_name.add_theme_font_size_override("font_size",16)
        group_name.add_theme_color_override("font_color",CINNABAR)
        rows.add_child(group_name)
        for building in instances:
            count += 1
            var occupants := _workforce_occupants(building)
            var reason := _workforce_candidate_reason(disciple,building,occupants)
            var already_owner := reason == "Đang phụ trách"
            var entry := HBoxContainer.new()
            entry.name = "QuickAssignRow_%s" % str(building.id)
            entry.custom_minimum_size = Vector2(582,56)
            entry.add_theme_constant_override("separation",8)
            rows.add_child(entry)
            var info := Label.new()
            info.name = "QuickAssignStatus_%s" % str(building.id)
            var busy_worker := ""
            if occupants.size() == 1 and state.disciples.has(occupants[0]):
                busy_worker = state.disciples[occupants[0]].display_name
            var occupation := "Chưa có người" if occupants.is_empty() else (busy_worker if busy_worker != "" else "%d người" % occupants.size())
            var building_label := str(item["name"])
            if instances.size() > 1:
                building_label += " %02d" % building.instance_index
            info.text = "%s · Lv%d · %s\n%s" % [building_label,building.level,occupation,("Đang phụ trách" if already_owner else "Có thể nhận việc" if reason == "" else reason)]
            info.custom_minimum_size = Vector2(448,52)
            info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            info.add_theme_font_size_override("font_size",12)
            info.add_theme_color_override("font_color",INK)
            entry.add_child(info)
            var choose := Button.new()
            choose.name = "QuickAssignTarget_%s" % str(building.id)
            choose.text = "Xem" if already_owner else "Giao việc"
            choose.custom_minimum_size = Vector2(125,46)
            choose.disabled = reason != "" and not already_owner
            choose.tooltip_text = "Mở công trình đang phụ trách" if already_owner else ("Phân công qua Workforce V2" if reason == "" else reason)
            choose.add_theme_font_size_override("font_size",13)
            choose.add_theme_stylebox_override("normal",_style(JADE_DARK,INK,1,8))
            choose.add_theme_color_override("font_color",PAPER_LIGHT)
            choose.pressed.connect(Callable(self,"_disciple_quick_assign_target").bind(disciple_id,building.id))
            entry.add_child(choose)
    if count == 0:
        var empty := Label.new()
        empty.text = "Chưa có Mỏ / Linh Lâm / Linh Điền. Không thể phân công."
        empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        rows.add_child(empty)
    panel.size.y = clampf(180.0+float(count)*83.0,420.0,546.0)
    scroll.size.y = panel.size.y-scroll.position.y-18.0
    _ensure_disabled_controls_readable(panel)

func _cancel_quick_assignment_pending_command(disciple_id: StringName, to_summary: bool) -> void:
    if not state.disciples.has(disciple_id):
        return
    var disciple: DiscipleState = state.disciples[disciple_id]
    if not _can_cancel_queued_assignment_command(disciple):
        return
    workforce.clear_command(state,disciple)
    if not disciple.direct_command.is_empty():
        return
    if runtime_session != null:
        runtime_session.save()
    _open_disciple_quick_assignment(disciple_id,to_summary,"Đã hủy lệnh chờ. Chọn công trình phù hợp để nhận việc.")

func _return_from_disciple_quick_assignment(disciple_id: StringName, to_summary: bool) -> void:
    if not state.disciples.has(disciple_id):
        _clear_popup()
        return
    _clear_popup()
    selected_id = disciple_id
    if to_summary:
        _show_disciple_summary()
    else:
        _open_disciple_deep_screen(disciple_id,disciple_profile_active_tab_name,true)

func _disciple_quick_assign_target(disciple_id: StringName, building_id: StringName) -> void:
    if not state.disciples.has(disciple_id) or not state.buildings.has(str(building_id)):
        return
    var building: BuildingState = state.buildings[str(building_id)]
    var destination := _sect_production_destination(building.building_type)
    if destination == &"":
        return
    var disciple: DiscipleState = state.disciples[disciple_id]
    var reason := _workforce_candidate_reason(disciple,building,_workforce_occupants(building))
    if reason != "" and reason != "Đang phụ trách":
        _open_disciple_quick_assignment(disciple_id,disciple_quick_assignment_return_to_summary,reason)
        return
    if reason == "Đang phụ trách":
        _open_building(destination,building_id)
        return
    var previous_group := disciple.work_group_id
    var previous_worksite := disciple.worksite_building_id
    var ok := workforce.assign_group(state,disciple_id,building.worker_group_id)
    if ok:
        ok = workforce.assign_worksite(state,disciple_id,building_id)
    if not ok:
        # Restore the original canonical assignment if the second half fails.
        # assign_group may clear a worksite whose crew no longer matches.
        if disciple.work_group_id != previous_group:
            workforce.assign_group(state,disciple_id,previous_group)
        if disciple.worksite_building_id != previous_worksite:
            workforce.assign_worksite(state,disciple_id,previous_worksite)
        _open_disciple_quick_assignment(disciple_id,disciple_quick_assignment_return_to_summary,"Workforce V2 từ chối thay đổi; phân công trước đã được khôi phục.")
        return

    var assignment_feedback := "Đã phân công tới %s. Hành động hiện tại: %s." % [
        _building_name(building_id),SectMapPresentation.action_label(disciple.current_action)
    ]
    if not disciple.active_job_id.is_empty():
        assignment_feedback += " Tác vụ đang giữ: %s." % str(disciple.active_job_id)
    elif not disciple.work_cycle_state.is_empty():
        assignment_feedback += " Chu kỳ hiện tại: %s." % str(disciple.work_cycle_state.get("phase",disciple.work_cycle_state.get("status","đang xử lý")))
    elif not disciple.direct_command.is_empty():
        assignment_feedback += " Có lệnh chờ xử lý."
    else:
        assignment_feedback += " Chưa có mã tác vụ/chu kỳ chạy; giao việc không đồng nghĩa đã thu sản phẩm."
    if runtime_session == null:
        assignment_feedback += " Phiên Save chưa sẵn sàng."
    else:
        var persisted: Dictionary = runtime_session.save()
        if bool(persisted.get("ok",false)):
            assignment_feedback += " Đã lưu phân công."
        else:
            assignment_feedback += " CẢNH BÁO: Save thất bại (%s)." % str(persisted.get("reason",persisted.get("error","unknown")))
    _refresh_all()
    # Keep the player in the same assignment flow; the drawer shows the real
    # group/worksite and does not claim production started until a job exists.
    _open_disciple_quick_assignment(disciple_id,disciple_quick_assignment_return_to_summary,assignment_feedback)

func _open_notice(title_text: String, body: String) -> void:
    _close_disciple_summary(true)
    _close_building_operation_panel(true)
    super._open_notice(title_text, body)

func _bottom_action(action: String) -> void:
    if action == "home":
        _clear_popup()
        _close_disciple_summary(true)
        _close_building_operation_panel(true)
        _reset_camera(true)
        return
    if action == "disciples":
        var ids: Array = state.disciples.keys()
        ids.sort()
        if ids.is_empty():
            return
        var target_id: StringName = selected_id if selected_id != &"" and state.disciples.has(selected_id) else StringName(ids[0])
        deep_restore_summary = false
        _open_disciple_deep_screen(target_id, "Tổng Quan")
        return
    super._bottom_action(action)

func _build_pve_quick_entry() -> void:
    var bottom := get_node_or_null("PlayerBottomBar") as Panel
    if bottom == null:
        return
    var button := Button.new()
    button.name = "PveHuntQuickEntry"
    button.text = "Săn quái / Thanh Trúc Lâm"
    button.position = Vector2(906,14)
    button.size = Vector2(292,50)
    button.add_theme_font_size_override("font_size",14)
    button.add_theme_color_override("font_color",PAPER_LIGHT)
    button.add_theme_stylebox_override("normal",_style(JADE_DARK,Color("544729"),2,10))
    button.add_theme_stylebox_override("hover",_style(JADE, GOLD,3,10))
    button.tooltip_text = "Vào Thanh Trúc Lâm: đi một mình hoặc chọn tối đa 30 đệ tử"
    button.pressed.connect(_open_pve_party_picker)
    bottom.add_child(button)

func _build_pve_party_picker() -> void:
    pve_party_picker_shade = ColorRect.new()
    pve_party_picker_shade.name = "PvePartyPickerShade"
    pve_party_picker_shade.color = Color(0.02,0.035,0.04,0.78)
    pve_party_picker_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    pve_party_picker_shade.z_index = 115
    pve_party_picker_shade.mouse_filter = Control.MOUSE_FILTER_STOP
    pve_party_picker_shade.visible = false
    add_child(pve_party_picker_shade)

    pve_party_picker_panel = Panel.new()
    pve_party_picker_panel.name = "PvePartyPicker"
    pve_party_picker_panel.position = Vector2(170,54)
    pve_party_picker_panel.size = Vector2(940,610)
    pve_party_picker_panel.z_index = 116
    pve_party_picker_panel.add_theme_stylebox_override("panel",_style(PAPER_LIGHT,INK,3,14))
    pve_party_picker_shade.add_child(pve_party_picker_panel)

    var title := Label.new()
    title.text = "CHỌN ĐỘI SĂN · THANH TRÚC LÂM"
    title.position = Vector2(24,16)
    title.size = Vector2(890,34)
    title.add_theme_font_size_override("font_size",23)
    title.add_theme_color_override("font_color",JADE_DARK)
    pve_party_picker_panel.add_child(title)

    var instructions := Label.new()
    instructions.text = "Đi săn tự do: chọn 1–30 đệ tử V2 khỏe, rảnh; mặc định mỗi người săn riêng. Boss vẫn yêu cầu đúng đội 6 người."
    instructions.position = Vector2(26,54)
    instructions.size = Vector2(884,38)
    instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    instructions.add_theme_font_size_override("font_size",13)
    instructions.add_theme_color_override("font_color",INK)
    pve_party_picker_panel.add_child(instructions)

    pve_party_picker_count = Label.new()
    pve_party_picker_count.name = "PvePartyPickerCount"
    pve_party_picker_count.position = Vector2(26,94)
    pve_party_picker_count.size = Vector2(884,26)
    pve_party_picker_count.add_theme_font_size_override("font_size",15)
    pve_party_picker_count.add_theme_color_override("font_color",JADE_DARK)
    pve_party_picker_panel.add_child(pve_party_picker_count)

    var scroll := ScrollContainer.new()
    scroll.name = "PvePartyEligibleListScroll"
    scroll.position = Vector2(24,124)
    scroll.size = Vector2(892,326)
    scroll.clip_contents = true
    pve_party_picker_panel.add_child(scroll)
    pve_party_picker_list = VBoxContainer.new()
    pve_party_picker_list.name = "PvePartyEligibleList"
    pve_party_picker_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    pve_party_picker_list.add_theme_constant_override("separation",3)
    scroll.add_child(pve_party_picker_list)

    pve_party_picker_reasons = Label.new()
    pve_party_picker_reasons.name = "PvePartyEligibilityReasons"
    pve_party_picker_reasons.position = Vector2(26,456)
    pve_party_picker_reasons.size = Vector2(884,64)
    pve_party_picker_reasons.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    pve_party_picker_reasons.add_theme_font_size_override("font_size",12)
    pve_party_picker_reasons.add_theme_color_override("font_color",INK)
    pve_party_picker_panel.add_child(pve_party_picker_reasons)

    pve_party_picker_feedback = Label.new()
    pve_party_picker_feedback.name = "PvePartyPickerFeedback"
    pve_party_picker_feedback.position = Vector2(26,522)
    pve_party_picker_feedback.size = Vector2(590,26)
    pve_party_picker_feedback.add_theme_font_size_override("font_size",13)
    pve_party_picker_feedback.add_theme_color_override("font_color",CINNABAR)
    pve_party_picker_panel.add_child(pve_party_picker_feedback)

    var cancel := Button.new()
    cancel.name = "PvePartyPickerCancel"
    cancel.text = "Đóng"
    cancel.position = Vector2(500,558)
    cancel.size = Vector2(112,38)
    cancel.add_theme_font_size_override("font_size",14)
    cancel.add_theme_stylebox_override("normal",_style(Color("d7c695"),INK,1,8))
    cancel.pressed.connect(_close_pve_party_picker)
    pve_party_picker_panel.add_child(cancel)

    pve_party_picker_boss_selector = OptionButton.new()
    pve_party_picker_boss_selector.name = "PvePartyPickerBossSelector"
    pve_party_picker_boss_selector.position = Vector2(26,558)
    pve_party_picker_boss_selector.size = Vector2(286,38)
    pve_party_picker_boss_selector.add_theme_font_size_override("font_size",11)
    _populate_v63_boss_selector()
    pve_party_picker_panel.add_child(pve_party_picker_boss_selector)

    pve_party_picker_start = Button.new()
    pve_party_picker_start.name = "PvePartyPickerStart"
    pve_party_picker_start.text = "Vào bãi săn"
    pve_party_picker_start.position = Vector2(622,558)
    pve_party_picker_start.size = Vector2(142,38)
    pve_party_picker_start.add_theme_font_size_override("font_size",13)
    pve_party_picker_start.add_theme_color_override("font_color",PAPER_LIGHT)
    pve_party_picker_start.add_theme_stylebox_override("normal",_style(JADE_DARK,PAPER_LIGHT,2,8))
    pve_party_picker_start.pressed.connect(_start_multicamp_hunt_for_picked_party)
    pve_party_picker_panel.add_child(pve_party_picker_start)
    pve_party_picker_boss_start = Button.new()
    pve_party_picker_boss_start.name = "PvePartyPickerBossStart"
    pve_party_picker_boss_start.text = "Thách Boss"
    pve_party_picker_boss_start.position = Vector2(774,558)
    pve_party_picker_boss_start.size = Vector2(142,38)
    pve_party_picker_boss_start.add_theme_font_size_override("font_size",13)
    pve_party_picker_boss_start.add_theme_color_override("font_color",PAPER_LIGHT)
    pve_party_picker_boss_start.add_theme_stylebox_override("normal",_style(CINNABAR,PAPER_LIGHT,2,8))
    pve_party_picker_boss_start.pressed.connect(_start_v63_boss_for_picked_party)
    pve_party_picker_panel.add_child(pve_party_picker_boss_start)

func _current_v63_preview_overrides() -> Dictionary:
    if runtime_session != null and runtime_session.owner != null and runtime_session.owner.scheduler != null:
        return runtime_session.owner.scheduler.v63_preview_overrides.duplicate(true)
    return v63_preview_overrides.duplicate(true)


func _populate_v63_boss_selector() -> void:
    if pve_party_picker_boss_selector == null:
        return
    pve_party_picker_boss_selector.clear()
    var loaded := V63HumanSkillCombatSystem.load_catalogue()
    if not bool(loaded.get("ok",false)):
        return
    var rows: Array[Dictionary] = []
    for boss in loaded.get("data",{}).get("bosses",[]):
        if boss is Dictionary:
            rows.append(boss.duplicate(true))
    rows.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
        return str(a.get("id","")) < str(b.get("id","")))
    for row in rows:
        var boss_id := str(row.get("id",""))
        var display := str(row.get("name_vi",row.get("display_name",boss_id)))
        pve_party_picker_boss_selector.add_item("%s · %s" % [display,boss_id])
        pve_party_picker_boss_selector.set_item_metadata(
            pve_party_picker_boss_selector.item_count-1,boss_id)


func _on_v63_preview_gate_toggled(enabled: bool) -> void:
    await _set_v63_preview_gate(enabled,true)


func _set_v63_preview_gate(enabled: bool,persist: bool) -> bool:
    if state == null:
        return false
    var previous_archive_opt_in := state.sect.v63_archive_opt_in
    var previous_combat_opt_in := state.sect.v63_skill_combat_opt_in
    state.sect.v63_archive_opt_in = enabled
    state.sect.v63_skill_combat_opt_in = enabled
    v63_preview_overrides = V63FeatureGates.persisted_preview_overrides(state)
    if runtime_session != null and runtime_session.owner != null and runtime_session.owner.scheduler != null:
        runtime_session.owner.scheduler.v63_preview_overrides = v63_preview_overrides.duplicate(true)
    if v63_combat_hud != null and b3_hunt_arena != null:
        v63_combat_hud.set_authority(state,b3_hunt_arena.battle,enabled)
    if persist:
        var saved := await _save_runtime_async_barrier()
        if not bool(saved.get("ok",false)):
            state.sect.v63_archive_opt_in = previous_archive_opt_in
            state.sect.v63_skill_combat_opt_in = previous_combat_opt_in
            v63_preview_overrides = V63FeatureGates.persisted_preview_overrides(state)
            if runtime_session != null and runtime_session.owner != null and runtime_session.owner.scheduler != null:
                runtime_session.owner.scheduler.v63_preview_overrides = v63_preview_overrides.duplicate(true)
            if v63_combat_hud != null and b3_hunt_arena != null:
                v63_combat_hud.set_authority(
                    state,b3_hunt_arena.battle,not v63_preview_overrides.is_empty())
            _set_b3_hunt_feedback("Đổi cổng V6.5 chưa lưu: %s" % str(saved.get("reason",saved.get("error","unknown"))))
            return false
    return true


func _open_v63_archive() -> void:
    if state == null or b3_hunt_panel == null or v63_archive_screen != null:
        return
    var packed := load("res://scenes/p2/p2_3_techniques.tscn") as PackedScene
    if packed == null:
        _set_b3_hunt_feedback("Không mở được Tàng Kinh Các P2.3.")
        return
    var screen := packed.instantiate() as Control
    if screen == null:
        _set_b3_hunt_feedback("Tàng Kinh Các không tạo được giao diện.")
        return
    var overrides := _current_v63_preview_overrides()
    screen.set("initial_state_override",state)
    screen.set("external_scheduler_mode",true)
    screen.set("archive_preview_overrides",overrides)
    screen.set("learning_preview_overrides",overrides)
    screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    screen.z_index = 300
    screen.mouse_filter = Control.MOUSE_FILTER_STOP
    screen.connect("close_requested",Callable(self,"_close_v63_archive"))
    b3_hunt_panel.add_child(screen)
    v63_archive_screen = screen


func _close_v63_archive() -> void:
    if v63_archive_screen != null and is_instance_valid(v63_archive_screen):
        v63_archive_screen.queue_free()
    v63_archive_screen = null
    _refresh_b3_hunt_panel()


func _start_v63_boss_for_picked_party() -> void:
    if pve_party_selected_ids.size() != 6 or pve_party_picker_boss_selector == null:
        pve_party_picker_feedback.text = "Hãy chọn đủ sáu đệ tử và một Boss."
        return
    if runtime_session == null or runtime_session.owner == null or runtime_session.owner.runtime_write_blocked \
            or not state.sect.b3_hunt.is_empty() or not state.sect.v2_pve_active_runs.is_empty():
        pve_party_picker_feedback.text = "Runtime chưa sẵn sàng hoặc đang có một trận PvE khác."
        return
    var boss_id := str(pve_party_picker_boss_selector.get_selected_metadata())
    if V63HumanSkillCombatSystem.boss_definition(boss_id).is_empty():
        pve_party_picker_feedback.text = "Danh mục Boss chưa hợp lệ: %s" % boss_id
        return
    var party := _multicamp_party_for_ids(pve_party_selected_ids)
    if party.size() != 6:
        pve_party_picker_feedback.text = "Đội vừa thay đổi trạng thái; làm mới lựa chọn trước khi thách Boss."
        _populate_pve_party_picker()
        return
    var selected_level := HuntingMapV2.selected_level(state,"thanh_truc_lam")
    var map_choice := HuntingMapV2.choose_level(state,"thanh_truc_lam",selected_level)
    if not bool(map_choice.get("ok",false)):
        pve_party_picker_feedback.text = "Bản đồ Boss chưa sẵn sàng: %s" % str(map_choice.get("reason","không đủ điều kiện"))
        return
    var gate_saved := await _set_v63_preview_gate(true,true)
    if not gate_saved:
        pve_party_picker_feedback.text = "Chưa lưu được opt-in V6.5; trận chưa bắt đầu."
        return
    var encounter_id := "pve:v63_boss:%s:%d:%d" % [
        boss_id.validate_node_name(),state.seed,state.sect.v2_pve_settlement_receipts.size()]
    var session := HuntingPveRunV2.new()
    var result := session.begin(state,"thanh_truc_lam",encounter_id,
        state.seed ^ state.tick ^ boss_id.hash(),party,boss_id,_current_v63_preview_overrides())
    if not bool(result.get("ok",false)):
        pve_party_picker_feedback.text = "Chưa thể vào trận Boss: %s" % str(result.get("reason","không đủ điều kiện"))
        return
    multicamp_encounter_id = encounter_id
    var first_id := StringName(str(party[0].get("disciple_id","")))
    _close_pve_party_picker()
    _open_v63_boss_panel(first_id,encounter_id)
    var saved := await _save_runtime_async_barrier()
    _refresh_b3_hunt_panel()
    _refresh_all()
    if not bool(saved.get("ok",false)):
        _set_b3_hunt_feedback("Boss đã chạy trong phiên; Save cần thử lại: %s" % str(saved.get("reason",saved.get("error","unknown"))))


func _open_v63_boss_panel(disciple_id: StringName,encounter_id: String) -> void:
    if b3_hunt_panel == null or state == null or not state.disciples.has(disciple_id):
        return
    active_hunt_mode = "v63_boss"
    multicamp_encounter_id = encounter_id
    b3_hunt_disciple_id = disciple_id
    selected_id = disciple_id
    _hide_disciple_summary()
    b3_hunt_panel.get_parent().visible = true
    b3_hunt_panel.visible = true
    _set_hunt_presentation_layout(false)
    _refresh_v63_boss_panel()


func _refresh_v63_boss_panel() -> void:
    if state == null:
        return
    _set_hunt_presentation_layout(false)
    var encounter := HuntingPveRunV2.active_single_encounter_id(state)
    var battle: MapBattleV2
    var running := not encounter.is_empty()
    if running:
        multicamp_encounter_id = encounter
        var restored := HuntingPveRunV2.resume_active(state,encounter,_current_v63_preview_overrides())
        if not bool(restored.get("ok",false)):
            b3_hunt_facts.visible = active_hunt_mode == "care"
            b3_hunt_facts.text = "Không thể khôi phục Boss đã lưu: %s" % str(restored.get("reason","save không hợp lệ"))
            v63_combat_hud.visible = false
            return
        var session: HuntingPveRunV2 = restored["session"]
        battle = session.battle
    else:
        var receipt: Dictionary = state.sect.v2_pve_settlement_receipts.get(multicamp_encounter_id,{})
        b3_hunt_facts.text = "Boss đã kết thúc · %s · kết quả %s · phần thưởng theo Settlement hiện có." % [
            multicamp_encounter_id,str(receipt.get("outcome","đang chờ xác nhận"))]
    b3_hunt_title.text = "V6.5 BOSS · COMBAT V2"
    b3_hunt_subtitle.visible = false
    b3_hunt_facts.visible = not running
    b3_hunt_combat_view.visible = false
    v63_combat_hud.visible = running
    if running:
        var rows := _b3_hunt_visual_rows(battle)
        b3_hunt_arena.show_authority_snapshot(battle,rows,{},false)
        v63_combat_hud.set_authority(
            state,battle,not _current_v63_preview_overrides().is_empty())
        b3_hunt_return_button.text = "Rời màn trận"
    else:
        b3_hunt_arena.show_authority_snapshot(null,{})
        b3_hunt_return_button.text = "Đóng kết quả"
    b3_hunt_auto_button.visible = false
    b3_hunt_deploy_button.visible = false
    b3_hunt_save_button.disabled = runtime_session == null or runtime_session.owner == null or runtime_session.owner.runtime_write_blocked


func _open_pve_party_picker() -> void:
    if not runtime_ready or state == null or pve_party_picker_shade == null:
        return
    var active_boss_encounter := HuntingPveRunV2.active_single_encounter_id(state)
    if not active_boss_encounter.is_empty():
        var restored_boss := HuntingPveRunV2.resume_active(state,active_boss_encounter,_current_v63_preview_overrides())
        if bool(restored_boss.get("ok",false)):
            var boss_session: HuntingPveRunV2 = restored_boss["session"]
            for actor_id in boss_session.battle.actors:
                var actor: Dictionary = boss_session.battle.actors[actor_id]
                if str(actor.get("side","")) == "disciple":
                    _open_v63_boss_panel(StringName(str(actor_id)),active_boss_encounter)
                    return
    var active_encounter := HuntingPveRunV2.active_multicamp_id(state)
    if not active_encounter.is_empty():
        var restored := _active_multicamp_session(active_encounter)
        if bool(restored.get("ok",false)):
            var active_session: HuntingPveRunV2 = restored["session"]
            var owner_id := selected_id
            if not active_session.battle.actors.has(str(owner_id)):
                owner_id = &""
                for actor_id in active_session.battle.actors:
                    var actor: Dictionary = active_session.battle.actors[actor_id]
                    if str(actor.get("side","")) == "disciple":
                        owner_id = StringName(str(actor_id))
                        break
            if owner_id != &"":
                _open_multicamp_panel(owner_id,active_encounter)
                return
    pve_party_selected_ids.clear()
    pve_party_picker_feedback.text = ""
    _populate_v63_boss_selector()
    _populate_pve_party_picker()
    if not active_encounter.is_empty():
        pve_party_picker_feedback.text = "Bãi Thanh Trúc Lâm đã lưu nhưng chưa thể mở lại: kiểm tra trạng thái Save/Load."
    elif not state.sect.b3_hunt.is_empty():
        pve_party_picker_feedback.text = "Thế giới săn B3 CARE đang hoạt động; hãy kết thúc hoặc trở về trước."
    elif not state.sect.v2_pve_active_runs.is_empty():
        pve_party_picker_feedback.text = "Đã có một trận PvE đang lưu; hãy tiếp tục trận đó trước."
    pve_party_picker_shade.visible = true
func _close_pve_party_picker() -> void:
    if pve_party_picker_shade != null:
        pve_party_picker_shade.visible = false
    pve_party_picker_join_mode = false

func _open_p0_join_picker() -> void:
    if runtime_session == null or runtime_session.owner == null or state == null:
        return
    var encounter_id := HuntingPveRunV2.active_multicamp_id(state)
    if encounter_id.is_empty():
        _set_b3_hunt_feedback("Chưa có bãi săn đang hoạt động.")
        return
    var current := _active_multicamp_session(encounter_id)
    if not bool(current.get("ok",false)) or not PveDistributedWorldV1.enabled(
            (current.get("session") as HuntingPveRunV2).camp_population):
        _set_b3_hunt_feedback("Bãi săn hiện tại không hỗ trợ thêm người.")
        return
    pve_party_picker_join_mode = true
    pve_party_selected_ids.clear()
    pve_party_picker_feedback.text = ""
    _populate_pve_party_picker()
    pve_party_picker_shade.visible = true

func _withdraw_selected_p0_hunter() -> void:
    if runtime_session == null or runtime_session.owner == null or b3_pve_world_view == null:
        return
    var selected: Array[String] = b3_pve_world_view.selected_actor_ids
    if selected.size() != 1:
        _set_b3_hunt_feedback("Chọn đúng một đệ tử trên bản đồ để rút riêng.")
        return
    var returned := PveP0CommandsV1.return_one(runtime_session.owner,str(selected[0]))
    if not bool(returned.get("ok",false)):
        _set_b3_hunt_feedback("Chưa rút được: %s" % str(returned.get("reason","unknown")))
        return
    var saved := await _save_runtime_async_barrier()
    if not bool(saved.get("ok",false)):
        _set_b3_hunt_feedback("Đã rút trong phiên; Save chưa hoàn thành: %s" % str(saved.get("reason",saved.get("error","unknown"))))
        return
    _set_b3_hunt_feedback("Đã rút riêng một người; những người khác vẫn săn.")
    _refresh_all()
    _refresh_b3_hunt_panel()

func _close_p0_hunt_map() -> void:
    if runtime_session == null or b3_hunt_panel == null:
        return
    var saved := await _save_runtime_async_barrier()
    if not bool(saved.get("ok",false)):
        _set_b3_hunt_feedback("Chưa đóng bản đồ: Save không thành công (%s)" % str(saved.get("reason",saved.get("error","unknown"))))
        return
    b3_hunt_panel.get_parent().visible = false
    active_hunt_mode = "care"
    _set_production_underlay_frozen(false)
    _refresh_all()

func _on_p0_hunt_policy_ordered(actor_ids: Array, policy: String) -> void:
    if runtime_session == null or runtime_session.owner == null:
        return
    var changed := PveP0CommandsV1.hunt_policy(
        runtime_session.owner,actor_ids,policy)
    if not bool(changed.get("ok",false)):
        _set_b3_hunt_feedback("Lệnh săn không hợp lệ: %s" % str(changed.get("reason","unknown")))
        return
    var saved := await _save_runtime_async_barrier()
    _set_b3_hunt_feedback("Đã đặt %s cho %d người." % [
        "TỰ SĂN" if policy == "auto" else "GIỮ VỊ TRÍ",actor_ids.size()]
        if bool(saved.get("ok",false))
        else "Lệnh đã gửi nhưng Save chưa thành công.")
    _refresh_b3_hunt_panel()

func _populate_pve_party_picker() -> void:
    if pve_party_picker_list == null or state == null:
        return
    for child in pve_party_picker_list.get_children():
        pve_party_picker_list.remove_child(child)
        child.free()
    pve_party_picker_checks.clear()
    var eligible: Array[Dictionary] = []
    var blocked: Dictionary = {}
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var id := StringName(raw_id)
        var disciple: DiscipleState = state.disciples[id]
        var reason := _multicamp_member_eligibility_reason(disciple)
        if reason.is_empty():
            eligible.append({"id":id,"rating":_multicamp_combat_rating(disciple)})
        else:
            blocked[reason] = int(blocked.get(reason,0))+1
    eligible.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
        var a_score := float(a["rating"])
        var b_score := float(b["rating"])
        if not is_equal_approx(a_score,b_score):
            return a_score > b_score
        return str(a["id"]) < str(b["id"]))
    var still_eligible: Array[StringName] = []
    for id in pve_party_selected_ids:
        for row in eligible:
            if StringName(row["id"]) == id:
                still_eligible.append(id)
                break
    pve_party_selected_ids = still_eligible
    for row in eligible:
        var id := StringName(row["id"])
        var disciple: DiscipleState = state.disciples[id]
        var check := CheckBox.new()
        check.name = "PvePartyMember_"+str(id).validate_node_name()
        check.text = "%s   ·   HP %.0f / %.0f" % [disciple.display_name,disciple.hp,disciple.max_hp]
        check.custom_minimum_size = Vector2(850,38)
        check.button_pressed = pve_party_selected_ids.has(id)
        check.add_theme_font_size_override("font_size",14)
        check.add_theme_color_override("font_color",INK)
        check.tooltip_text = "V2 · khỏe · rảnh · đang ở tông môn"
        check.toggled.connect(_on_pve_party_member_toggled.bind(id))
        pve_party_picker_list.add_child(check)
        pve_party_picker_checks[id] = check
    var blocked_lines: Array[String] = []
    var blocked_keys: Array = blocked.keys()
    blocked_keys.sort()
    for reason_key in blocked_keys:
        blocked_lines.append("%d: %s" % [int(blocked[reason_key]),str(reason_key)])
    var blocked_text := "Không đủ điều kiện (%d): %s" % [
        ids.size()-eligible.size()," · ".join(blocked_lines.slice(0,5))]
    if blocked_lines.size() > 5:
        blocked_text += " · và %d lý do khác" % [blocked_lines.size()-5]
    pve_party_picker_reasons.text = (
        ("Chọn 1 người rảnh để vào phiên săn đang chạy. " if pve_party_picker_join_mode
         else "Đi săn riêng 1–30 người; Boss chỉ nhận đúng 6. ")
        + "Hiện có %d đủ điều kiện. " % eligible.size()
        + "Cấm HP=0, Injury, công việc/timer/ruộng/lò/rèn thân hoặc thế giới khác.\n"
        + blocked_text)
    _update_pve_party_picker_controls(eligible.size())

func _on_pve_party_member_toggled(checked: bool,id: StringName) -> void:
    if checked:
        var maximum := 1 if pve_party_picker_join_mode else MapBattleV2.MAX_DISCIPLES
        if pve_party_selected_ids.size() >= maximum:
            var checkbox := pve_party_picker_checks.get(id) as CheckBox
            if checkbox != null:
                checkbox.set_pressed_no_signal(false)
            pve_party_picker_feedback.text = "Chọn tối đa %d người trong lượt này." % maximum
            _update_pve_party_picker_controls(pve_party_picker_checks.size())
            return
        if not pve_party_selected_ids.has(id):
            pve_party_selected_ids.append(id)
    else:
        pve_party_selected_ids.erase(id)
    pve_party_picker_feedback.text = ""
    _update_pve_party_picker_controls(pve_party_picker_checks.size())

func _update_pve_party_picker_controls(eligible_count: int) -> void:
    if pve_party_picker_count == null or state == null:
        return
    var selected_count := pve_party_selected_ids.size()
    var limit := 1 if pve_party_picker_join_mode else MapBattleV2.MAX_DISCIPLES
    pve_party_picker_count.text = "Đã chọn %d / %d  ·  đủ điều kiện %d" % [
        selected_count,limit,eligible_count]
    if selected_count == 0 and eligible_count == 0:
        pve_party_picker_feedback.text = "Chưa có đệ tử V2 khỏe và rảnh để đi săn."
    var active_world := HuntingPveRunV2.active_multicamp_id(state)
    var active_elsewhere := not state.sect.b3_hunt.is_empty()         or HuntingPveRunV2.active_single_encounter_id(state) != ""
    var new_world_ready := active_world.is_empty() and state.sect.v2_pve_active_runs.is_empty()
    var join_ready := not active_world.is_empty() and not active_elsewhere
    var can_start := selected_count > 0 and selected_count <= limit         and not active_elsewhere and (join_ready if pve_party_picker_join_mode else new_world_ready)
    if pve_party_picker_start != null:
        pve_party_picker_start.disabled = not can_start
        pve_party_picker_start.text = "Thêm vào bãi săn" if pve_party_picker_join_mode else "Vào bãi săn"
    if pve_party_picker_boss_start != null:
        pve_party_picker_boss_start.disabled = pve_party_picker_join_mode             or selected_count != 6 or not new_world_ready or active_elsewhere             or pve_party_picker_boss_selector == null             or pve_party_picker_boss_selector.item_count == 0
    if pve_party_picker_boss_selector != null:
        pve_party_picker_boss_selector.disabled = pve_party_picker_join_mode

func _start_multicamp_hunt_for_picked_party() -> void:
    if runtime_session == null or runtime_session.owner == null or state == null:
        return
    var selected: Array = []
    for id in pve_party_selected_ids:
        selected.append(str(id))
    if selected.is_empty() or selected.size() > MapBattleV2.MAX_DISCIPLES:
        pve_party_picker_feedback.text = "Chọn từ 1 tới 30 đệ tử."
        return
    if pve_party_picker_join_mode:
        if selected.size() != 1:
            pve_party_picker_feedback.text = "Mỗi lượt thêm một đệ tử."
            return
        var joined := PveP0CommandsV1.join_one(runtime_session.owner,str(selected[0]))
        if not bool(joined.get("ok",false)):
            pve_party_picker_feedback.text = "Chưa thêm được đệ tử: %s" % str(joined.get("reason","unknown"))
            return
        var persisted := await _save_runtime_async_barrier()
        if not bool(persisted.get("ok",false)):
            pve_party_picker_feedback.text = "Đã thêm trong phiên nhưng Save chưa hoàn thành: %s" % str(persisted.get("reason",persisted.get("error","unknown")))
            return
        var active_id := HuntingPveRunV2.active_multicamp_id(state)
        _close_pve_party_picker()
        _open_multicamp_panel(StringName(str(selected[0])),active_id)
        _refresh_all()
        return
    if not state.sect.b3_hunt.is_empty() or not state.sect.v2_pve_active_runs.is_empty():
        pve_party_picker_feedback.text = "Đang có một phiên săn khác; hãy mở lại phiên đó."
        return
    var encounter_id := "pve:thanh_truc_lam:c01:%d:%d:%d" % [
        state.seed,state.tick,state.sect.v2_pve_settlement_receipts.size()]
    var world_options := b3_pve_world_view.get_open_world_options()
    if not bool(world_options.get("ok",false)):
        pve_party_picker_feedback.text = "Không dựng được Source A: %s" % str(world_options.get("reason","map unavailable"))
        return
    var result := PveP0CommandsV1.deploy(runtime_session.owner,encounter_id,
        state.seed ^ state.tick ^ state.sect.v2_pve_settlement_receipts.size(),
        selected,world_options)
    if not bool(result.get("ok",false)):
        pve_party_picker_feedback.text = "Không thể vào bãi: %s" % str(result.get("reason","unknown"))
        return
    var saved := await _save_runtime_async_barrier()
    if not bool(saved.get("ok",false)):
        pve_party_picker_feedback.text = "Bãi đã khởi tạo nhưng Save chưa hoàn tất: %s" % str(saved.get("reason",saved.get("error","unknown")))
        return
    var first_id := StringName(str(selected[0]))
    _close_pve_party_picker()
    _open_multicamp_panel(first_id,encounter_id)
    _refresh_all()

func _open_disciple(disciple_id: StringName) -> void:
    if not state.disciples.has(disciple_id):
        return
    _close_building_operation_panel(true)
    selected_id = disciple_id
    opened_disciple_profile = true
    summary_feedback = ""
    _refresh_tasks()
    _clear_popup()

    var disciple: DiscipleState = state.disciples[disciple_id]
    _set_focus_target(_disciple_map_point(disciple_id), &"disciple", disciple_id, disciple.display_name, true)

    _show_disciple_summary()

func _reconcile_live_actors() -> void:
    # O2: recruitment mutates the authoritative roster after scene startup.
    # Keep one virtual location per canonical ID; only nearby idle/transiting
    # actors are represented by bounded viewport scene nodes.
    var needs_install := false
    for raw_id in state.disciples.keys():
        var key := str(raw_id)
        if not actor_virtual_positions.has(key):
            needs_install = true
            break
    if not needs_install and actor_virtual_positions.size() != state.disciples.size():
        needs_install = true
    if needs_install:
        _install_modular_live_actors()

func _sync_actor_positions() -> void:
    var performance_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
    _reconcile_live_actors()
    var ids: Array = state.disciples.keys()
    ids.sort()
    var idle_slots := _idle_staging_ordinals(ids)
    for index in range(ids.size()):
        var disciple_id := StringName(ids[index])
        var key := str(disciple_id)
        var disciple: DiscipleState = state.disciples[disciple_id]
        var had_virtual_position := actor_virtual_positions.has(key)
        var previous_virtual_position: Vector2 = actor_virtual_positions.get(key,Vector2.ZERO)
        var previous := StringName(actor_destinations.get(key, str(SectMapPresentation.DEST_COURTYARD)))
        var previous_action := StringName(actor_last_actions.get(key,str(disciple.current_action)))
        var action_changed := had_virtual_position and previous_action != disciple.current_action
        var destination := _idle_destination_for(key,index) if _is_idle_wandering_actor(disciple) \
            else SectMapPresentation.destination_for_action(disciple.current_action, previous)
        if not _is_idle_wandering_actor(disciple):
            destination = _sect_effective_door_destination(disciple,destination)
            actor_idle_wander_destinations.erase(key)
            actor_idle_wander_indices.erase(key)
            actor_idle_wander_due_msec.erase(key)
        actor_destinations[key] = str(destination)

        var worksite_id := _sect_door_worksite_id(disciple,destination)
        var actor_offset := _endgame_actor_offset(disciple,index,idle_slots) if _is_idle_wandering_actor(disciple) \
            else _sect_actor_door_offset(disciple,index,idle_slots,destination)
        var world_foot := _iso_actor_point(destination,worksite_id) + actor_offset
        var target := world_foot - DiscipleActorVisualCatalog.ACTOR_FOOT_POINT
        actor_virtual_positions[key] = target
        var actor := actor_nodes.get(key) as Control
        var cycle_phase := StringName(disciple.work_cycle_state.get("phase",""))
        if action_changed and previous != destination:
            actor_transition_deadline_msec[key] = Time.get_ticks_msec() + 4000
            if actor == null and had_virtual_position:
                actor_transition_origins[key] = previous_virtual_position
        elif actor == null and had_virtual_position and cycle_phase == &"travel_out" and previous != destination:
            actor_transition_origins[key] = previous_virtual_position
        actor_last_actions[key] = str(disciple.current_action)
        if actor == null or not is_instance_valid(actor):
            continue
        var delta := target - actor.position

        # An off-screen/unselected person still works in SimulationState.
        # Skip hidden walk VFX and per-actor tweens; snap the presentation
        # position so newly visible actors cannot drift from canonical jobs.
        var animate_actor := actor.visible and SectMapCamera.VIEW_RECT.encloses(actor.get_global_rect())
        var continuing_walk := _actor_tween_matches_target(actor,target)
        if actor is ModularDiscipleActor:
            var modular := actor as ModularDiscipleActor
            if delta.length() > 1.0 and animate_actor and not continuing_walk:
                var direction := DiscipleActorVisualCatalog.direction_for_delta(delta, modular.facing)
                if (
                    modular.rig_id == DiscipleActorVisualCatalog.RIG_FEMALE_NORMAL_V1
                    and _stage_a_live_assets_ready()
                    and direction != modular.facing
                ):
                    FemaleStageAAssetLoader.apply_public_direction(modular, direction)
                modular.play_walk_for_delta(delta)
            else:
                modular.sync_action(disciple.current_action)

        if delta.length() > 1.0:
            if animate_actor:
                _animate_actor_position(actor, target)
            else:
                _cancel_actor_position_tween(actor)
                actor.position = target
        else:
            _cancel_actor_position_tween(actor)

        if actor_status_labels.has(key):
            var status := actor_status_labels[key] as Label
            if is_instance_valid(status):
                status.text = SectMapPresentation.action_label(disciple.current_action)

    if focused_kind == &"disciple":
        _refresh_focused_disciple_point()
    _refresh_disciple_summary_content()
    _refresh_building_operation_content()
    _refresh_living_cues()
    _refresh_actor_status_label_visibility()
    _refresh_world_actor_visibility()
    if performance_logging_enabled:
        var elapsed_usec := Time.get_ticks_usec()-performance_started_usec
        performance_sync_actor_usec_total += elapsed_usec
        performance_sync_actor_usec_max = maxi(performance_sync_actor_usec_max,elapsed_usec)

func _idle_staging_ordinals(ids: Array) -> Dictionary:
    var result: Dictionary = {}
    var ordinal := 0
    for raw_id in ids:
        var id := StringName(raw_id)
        if not state.disciples.has(id):
            continue
        var disciple: DiscipleState = state.disciples[id]
        if not _is_idle_map_actor(disciple):
            continue
        result[str(id)] = ordinal
        ordinal += 1
    return result

func _is_idle_wandering_actor(disciple: DiscipleState) -> bool:
    # HOLD means the disciple stays in the sect, not frozen at a world point.
    # If no canonical job/remote activity owns them, they remain visible and
    # wander within the sect presentation just like other idle residents.
    return _is_idle_map_actor(disciple)

func _idle_destination_for(key: String, index: int) -> StringName:
    if not actor_idle_wander_destinations.has(key):
        actor_idle_wander_destinations[key] = str(SectMapPresentation.DEST_COURTYARD)
        actor_idle_wander_indices[key] = posmod(index,IDLE_PATROL_DESTINATIONS.size())
        actor_idle_wander_due_msec[key] = Time.get_ticks_msec() + 2500 + posmod(index,6)*350
    return StringName(actor_idle_wander_destinations.get(key,str(SectMapPresentation.DEST_COURTYARD)))

func _is_idle_map_actor(disciple: DiscipleState) -> bool:
    return (
        disciple != null
        and disciple.region_id == &"sect"
        and disciple.active_pve_encounter_id.is_empty()
        and disciple.worksite_building_id == &""
        and disciple.work_cycle_state.is_empty()
        and disciple.work_progress.is_empty()
        and disciple.current_action in [&"EVALUATE",&"IDLE",&"HOLD"]
    )

func _endgame_actor_offset(disciple: DiscipleState, index: int, idle_slots: Dictionary) -> Vector2:
    var key := str(disciple.id)
    if not idle_slots.has(key):
        return _actor_offset(index)
    # Idle disciples use a deterministic, spread-out staging spiral around each
    # public waypoint. This is presentation-only and stays bounded by the
    # viewport actor pool.
    var ordinal := int(idle_slots[key])
    const GOLDEN_ANGLE := 2.399963229728653
    var radius := 22.0 * sqrt(float(ordinal)+1.0)
    var angle := float(ordinal) * GOLDEN_ANGLE
    return Vector2(cos(angle),sin(angle))*radius

func _actor_anchor_offset(actor: Control) -> Vector2:
    if actor is ModularDiscipleActor:
        return DiscipleActorVisualCatalog.ACTOR_FOOT_POINT
    return Vector2(30.0, 30.0)

func _refresh_actor_status_label_visibility() -> void:
    # Routine action and destination are available through the actor's tooltip
    # and the canonical disciple profile. Never paint persistent work/status
    # tags over the sect actors, especially while a management panel is open.
    # Keep at most one brief ambient speech bubble on the unobstructed map.
    var allow_ambient := not opened_disciple_profile \
        and not _disciple_summary_is_open() and not _building_operation_is_open()
    var bubble_shown := false
    var visible_rects: Array[Rect2] = []
    var now_msec := Time.get_ticks_msec()
    var ids: Array = actor_nodes.keys()
    ids.sort()
    for raw_id in ids:
        var key := str(raw_id)
        var status := actor_status_labels.get(key) as Label
        var actor := actor_nodes.get(key) as Control
        if status == null or actor == null or not is_instance_valid(status) or not is_instance_valid(actor):
            continue
        status.visible = false
        var bubble: Dictionary = actor_ambient_bubbles.get(key,{})
        if not bubble.is_empty() and int(bubble.get("expires_msec",0)) <= now_msec:
            actor_ambient_bubbles.erase(key)
            continue
        if not allow_ambient or bubble_shown or not actor.visible or bubble.is_empty():
            continue
        var disciple_id := StringName(key)
        if not state.disciples.has(disciple_id):
            continue
        var disciple: DiscipleState = state.disciples[disciple_id]
        if _is_idle_wandering_actor(disciple):
            bubble_shown = _present_actor_status_label(status,str(bubble.get("text","")),visible_rects)

func _present_actor_status_label(status: Label, text: String, visible_rects: Array[Rect2]) -> bool:
    status.text = text
    status.visible = true
    var candidate_rect := status.get_global_rect()
    for visible_rect in visible_rects:
        if candidate_rect.intersects(visible_rect):
            status.visible = false
            return false
    visible_rects.append(candidate_rect)
    return true

func _actor_map_status_text(disciple: DiscipleState) -> String:
    var key := str(disciple.id)
    if Time.get_ticks_msec() < int(actor_transition_deadline_msec.get(key,0)):
        return "ĐẾN " + _destination_short_label(StringName(actor_destinations.get(key,"")))
    var cycle: Dictionary = disciple.work_cycle_state
    var phase := StringName(cycle.get("phase",""))
    match phase:
        &"travel_out":
            return "TỚI " + _destination_short_label(StringName(actor_destinations.get(str(disciple.id),"")))
        &"mining":
            return "ĐANG KHAI THÁC"
        &"harvesting":
            return "ĐANG THU HOẠCH"
        &"haul_back":
            return "VỀ KHO · ×%d" % maxi(int(cycle.get("carried_units",0)),0)
    return SectMapPresentation.action_label(disciple.current_action).to_upper()

func _destination_short_label(destination: StringName) -> String:
    match destination:
        SectMapPresentation.DEST_MINE: return "MỎ"
        SectMapPresentation.DEST_LINH_FOREST: return "LINH LÂM"
        SectMapPresentation.DEST_SPIRIT_FIELD: return "LINH ĐIỀN"
        SectMapPresentation.DEST_FORGE: return "LUYỆN KHÍ"
        SectMapPresentation.DEST_ALCHEMY_HALL: return "LUYỆN ĐAN"
        SectMapPresentation.DEST_CULTIVATION: return "TU LUYỆN"
        SectMapPresentation.DEST_BODY_TRAINING: return "RÈN THÂN"
        _: return "CÔNG TRÌNH"

func _advance_idle_disciple_walks() -> void:
    if state == null or map_layer == null:
        return
    var now_msec := Time.get_ticks_msec()
    var ids: Array = state.disciples.keys()
    ids.sort()
    var idle_slots := _idle_staging_ordinals(ids)
    for index in range(ids.size()):
        var disciple_id := StringName(ids[index])
        var key := str(disciple_id)
        var disciple: DiscipleState = state.disciples[disciple_id]
        if not _is_idle_wandering_actor(disciple):
            continue
        if not actor_idle_wander_destinations.has(key):
            _idle_destination_for(key,index)
        if now_msec < int(actor_idle_wander_due_msec.get(key,now_msec + 1000)):
            continue
        var actor := actor_nodes.get(key) as ModularDiscipleActor
        if actor != null and is_instance_valid(actor) and _actor_tween_matches_target(actor,Vector2(actor_virtual_positions.get(key,actor.position))):
            continue
        var waypoint_index := int(actor_idle_wander_indices.get(key,0))
        waypoint_index = posmod(waypoint_index + 1,IDLE_PATROL_DESTINATIONS.size())
        actor_idle_wander_indices[key] = waypoint_index
        var destination := StringName(IDLE_PATROL_DESTINATIONS[waypoint_index])
        actor_idle_wander_destinations[key] = str(destination)
        actor_destinations[key] = str(destination)
        var worksite_id := _sect_door_worksite_id(disciple,destination)
        var world_foot := _iso_actor_point(destination,worksite_id) \
            + _endgame_actor_offset(disciple,index,idle_slots)
        var target := world_foot - DiscipleActorVisualCatalog.ACTOR_FOOT_POINT
        var delay := 6500 + posmod(index * 431 + waypoint_index * 977,5000)
        actor_idle_wander_due_msec[key] = now_msec + delay
        actor_virtual_positions[key] = target
        if actor == null or not is_instance_valid(actor) or not actor.visible:
            continue
        var delta := target - actor.position
        if delta.length() <= 14.0:
            continue
        actor.play_walk_for_delta(delta)
        _animate_actor_position(actor,target)

func _show_next_idle_ambient_line() -> void:
    if state == null or actor_nodes.is_empty():
        npc_ambient_delay = 4.0
        return
    var keys: Array = actor_nodes.keys()
    keys.sort()
    var idle_keys: Array[String] = []
    for raw_key in keys:
        var key := str(raw_key)
        var disciple_id := StringName(key)
        if not state.disciples.has(disciple_id):
            continue
        var actor := actor_nodes.get(key) as Control
        if actor == null or not is_instance_valid(actor) or not actor.visible:
            continue
        if _is_idle_wandering_actor(state.disciples[disciple_id]):
            idle_keys.append(key)
    if idle_keys.is_empty():
        npc_ambient_delay = 4.0
        return
    var key := idle_keys[posmod(npc_ambient_cursor,idle_keys.size())]
    var line := str(IDLE_AMBIENT_LINES[posmod(npc_ambient_cursor,IDLE_AMBIENT_LINES.size())])
    npc_ambient_cursor += 1
    actor_ambient_bubbles[key] = {
        "text":line,
        "expires_msec":Time.get_ticks_msec() + 2900
    }
    npc_ambient_delay = 8.0 + float(posmod(npc_ambient_cursor,5)) * 1.25
    _refresh_actor_status_label_visibility()

func _stage_a_live_assets_ready() -> bool:
    return (
        FemaleStageAAssetLoader.assets_available(&"down")
        and FemaleStageAAssetLoader.assets_available(&"right")
        and FemaleStageAAssetLoader.assets_available(&"up")
    )

func _cancel_actor_position_tween(actor: Control) -> void:
    if actor == null or not is_instance_valid(actor):
        return
    var instance_id := actor.get_instance_id()
    var tween := actor_position_tweens.get(instance_id) as Tween
    if tween != null:
        if tween.is_running():
            tween.kill()
        actor_position_tweens.erase(instance_id)
    actor_position_tween_targets.erase(instance_id)

func _actor_tween_matches_target(actor: Control, target: Vector2) -> bool:
    if actor == null or not is_instance_valid(actor):
        return false
    var instance_id := actor.get_instance_id()
    var tween := actor_position_tweens.get(instance_id) as Tween
    if tween == null or not tween.is_running() or not actor_position_tween_targets.has(instance_id):
        return false
    return Vector2(actor_position_tween_targets[instance_id]).distance_to(target) <= 1.0

func _animate_actor_position(actor: Control, target: Vector2) -> void:
    if _actor_tween_matches_target(actor,target):
        return
    _cancel_actor_position_tween(actor)
    var instance_id := actor.get_instance_id()
    var travel_distance := actor.position.distance_to(target)
    var tween := create_tween()
    actor_position_tweens[instance_id] = tween
    actor_position_tween_targets[instance_id] = target
    # Presentation walking only. Real jobs, map targets and simulation ticks unchanged.
    tween.set_trans(Tween.TRANS_LINEAR)
    tween.set_ease(Tween.EASE_IN_OUT)
    var duration := maxf(travel_distance / 125.0,0.65)
    tween.tween_property(actor, "position", target, duration)
    tween.finished.connect(_finish_actor_position_tween.bind(actor,instance_id,tween))

func _finish_actor_position_tween(actor: Control, instance_id: int, tween: Tween) -> void:
    if actor_position_tweens.get(instance_id) != tween:
        return
    actor_position_tweens.erase(instance_id)
    actor_position_tween_targets.erase(instance_id)
    if actor == null or not is_instance_valid(actor):
        return
    var disciple_id := StringName(str(actor.name).trim_prefix("ModularDisciple_"))
    actor_transition_deadline_msec.erase(str(disciple_id))
    actor_transition_origins.erase(str(disciple_id))
    if state.disciples.has(disciple_id):
        (actor as ModularDiscipleActor).sync_action((state.disciples[disciple_id] as DiscipleState).current_action)
        _refresh_actor_status_label_visibility()

func _forget_actor_position_tween(instance_id: int, tween: Tween) -> void:
    if actor_position_tweens.get(instance_id) == tween:
        actor_position_tweens.erase(instance_id)

func _install_modular_live_actors() -> void:
    # The P3.1 base scene creates roster placeholder Controls during super._ready().
    # Replace that presentation once with the P3.2 pooled/virtual actor layer.
    for raw_id in actor_nodes.keys().duplicate():
        var key := str(raw_id)
        var old_actor := actor_nodes.get(key) as Control
        if old_actor is ModularDiscipleActor:
            continue
        else:
            actor_nodes.erase(key)
            actor_status_labels.erase(key)
            if old_actor != null and is_instance_valid(old_actor):
                if old_actor.get_parent() != null:
                    old_actor.get_parent().remove_child(old_actor)
                old_actor.free()
    modular_live_actor_ids.clear()
    if female_motion_library == null:
        return

    var ids: Array = state.disciples.keys()
    ids.sort()
    var idle_slots := _idle_staging_ordinals(ids)
    var next_positions: Dictionary = {}
    for index in range(ids.size()):
        var disciple_id := StringName(ids[index])
        var key := str(disciple_id)
        var disciple: DiscipleState = state.disciples[disciple_id]
        var destination := StringName(actor_destinations.get(key, str(_initial_destination(disciple))))
        destination = SectMapPresentation.destination_for_action(disciple.current_action,destination)
        destination = _sect_effective_door_destination(disciple,destination)
        actor_destinations[key] = str(destination)
        var worksite_id := _sect_door_worksite_id(disciple,destination)
        var world_foot := _iso_actor_point(destination,worksite_id) + _sect_actor_door_offset(disciple,index,idle_slots,destination)
        next_positions[key] = world_foot - DiscipleActorVisualCatalog.ACTOR_FOOT_POINT
        modular_live_actor_ids[key] = true
    for raw_id in actor_nodes.keys().duplicate():
        var key := str(raw_id)
        if not next_positions.has(key):
            _recycle_modular_actor(key)
    for raw_id in actor_destinations.keys().duplicate():
        var key := str(raw_id)
        if not next_positions.has(key):
            actor_destinations.erase(key)
    actor_virtual_positions = next_positions
    _refresh_actor_status_label_visibility()
    _refresh_world_actor_visibility()

func _materialize_modular_actor(key: String) -> void:
    if not state.disciples.has(StringName(key)) or not actor_virtual_positions.has(key):
        return
    var disciple: DiscipleState = state.disciples[StringName(key)]
    var actor := _take_modular_actor()
    _cancel_actor_position_tween(actor)
    actor.name = "ModularDisciple_%s" % key
    actor.reset_for_reuse()
    actor.configure(disciple)
    actor.set_animation_library(female_motion_library)
    if actor.rig_id == DiscipleActorVisualCatalog.RIG_FEMALE_NORMAL_V1 and _stage_a_live_assets_ready():
        FemaleStageAAssetLoader.apply_public_direction(actor,&"down")
    var source_a_scene := DiscipleSourceAVisualPool.scene_for_disciple(disciple)
    if source_a_scene != null and not actor.production_body_active():
        actor.set_baked_visual(source_a_scene)
    actor.sync_action(disciple.current_action)
    var target: Vector2 = actor_virtual_positions[key]
    var spawn_position := target
    var travel_phase := StringName(disciple.work_cycle_state.get("phase","")) == &"travel_out"
    var show_transition := Time.get_ticks_msec() < int(actor_transition_deadline_msec.get(key,0))
    if show_transition and actor_transition_origins.has(key):
        spawn_position = Vector2(actor_transition_origins[key])
        actor_transition_origins.erase(key)
    elif travel_phase:
        var ids: Array = state.disciples.keys()
        ids.sort()
        var actor_index := maxi(ids.find(disciple.id),0)
        var idle_slots := _idle_staging_ordinals(ids)
        spawn_position = _iso_actor_point(SectMapPresentation.DEST_COURTYARD) \
            + _endgame_actor_offset(disciple,actor_index,idle_slots) \
            - DiscipleActorVisualCatalog.ACTOR_FOOT_POINT
    actor.position = spawn_position
    map_layer.add_child(actor)
    actor_nodes[key] = actor
    actor_status_labels[key] = actor.status_label
    modular_live_actor_ids[key] = true
    var arrival_delta := target - spawn_position
    if (travel_phase or show_transition) and arrival_delta.length() > 1.0 and SectMapCamera.VIEW_RECT.encloses(actor.get_global_rect()):
        actor.play_walk_for_delta(arrival_delta)
        _animate_actor_position(actor,target)

func _take_modular_actor() -> ModularDiscipleActor:
    if not actor_pool.is_empty():
        var pooled: ModularDiscipleActor = actor_pool.pop_back()
        return pooled
    var actor := ModularDiscipleActor.new()
    actor.actor_pressed.connect(Callable(self,"_open_disciple"))
    return actor

func _recycle_modular_actor(key: String) -> void:
    var actor := actor_nodes.get(key) as ModularDiscipleActor
    actor_nodes.erase(key)
    actor_status_labels.erase(key)
    actor_ambient_bubbles.erase(key)
    if actor == null or not is_instance_valid(actor):
        return
    _cancel_actor_position_tween(actor)
    actor.visible = false
    actor.reset_for_reuse()
    if actor.get_parent() != null:
        actor.get_parent().remove_child(actor)
    if actor_pool.size() < MAX_RETAINED_ACTOR_POOL:
        actor_pool.append(actor)
    else:
        actor.free()

func _build_construction_ui() -> void:
    build_mode_button = Button.new()
    build_mode_button.name = "MapBuildModeEntry"
    build_mode_button.text = "XÂY DỰNG"
    build_mode_button.position = Vector2(20,88)
    build_mode_button.size = Vector2(176,48)
    build_mode_button.z_index = 28
    build_mode_button.add_theme_font_size_override("font_size",15)
    build_mode_button.add_theme_color_override("font_color",PAPER_LIGHT)
    build_mode_button.add_theme_stylebox_override("normal",_style(JADE_DARK,PAPER_LIGHT,2,10))
    build_mode_button.add_theme_stylebox_override("hover",_style(JADE,GOLD,2,10))
    build_mode_button.pressed.connect(_enter_build_mode)
    add_child(build_mode_button)

    build_mode_panel = Panel.new()
    build_mode_panel.name = "MapBuildModePanel"
    build_mode_panel.position = Vector2(18,144)
    build_mode_panel.size = Vector2(392,558)
    build_mode_panel.z_index = 70
    build_mode_panel.visible = false
    build_mode_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    build_mode_panel.add_theme_stylebox_override("panel",_style(PAPER_LIGHT,INK,3,14))
    add_child(build_mode_panel)

    var title := _label(build_mode_panel,"KIẾN THIẾT TÔNG MÔN",Vector2(16,12),Vector2(318,30),18)
    title.add_theme_color_override("font_color",CINNABAR.darkened(0.15))
    var close := Button.new()
    close.name = "CloseBuildMode"
    close.text = "×"
    close.position = Vector2(342,8)
    close.size = Vector2(40,40)
    close.pressed.connect(_leave_build_mode.bind(true))
    build_mode_panel.add_child(close)

    build_mode_description = _label(build_mode_panel,"",Vector2(18,52),Vector2(354,76),12)
    build_mode_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    build_mode_description.add_theme_color_override("font_color",INK)
    var catalog := _label(build_mode_panel,"ĐẶT TRÊN BẢN ĐỒ",Vector2(18,130),Vector2(354,22),11)
    catalog.add_theme_color_override("font_color",JADE_DARK)
    var build_house := Button.new()
    build_house.name = "BuildCatalogResidence"
    build_house.text = "ĐỆ TỬ XÁ  ·  CHỌN VỊ TRÍ TRÊN BẢN ĐỒ"
    build_house.position = Vector2(66,156)
    build_house.size = Vector2(306,42)
    build_house.add_theme_stylebox_override("normal",_style(JADE_DARK,PAPER_LIGHT,1,8))
    build_house.add_theme_color_override("font_color",PAPER_LIGHT)
    build_house.pressed.connect(_begin_residence_construction)
    build_mode_panel.add_child(build_house)

    # This is the only player-placeable facility backed by a canonical paid
    # map-placement transaction. Use the existing SHA-gated Source A art
    # renderer so a missing/invalid PNG falls back honestly to the approved
    # residence study artwork, never a raw or mislabeled atlas.
    var build_art := TRI_FACILITY_ART.new() as Control
    build_art.name = "BuildCatalogResidenceArt"
    build_art.position = Vector2(20,156)
    build_art.size = Vector2(42,42)
    build_art.custom_minimum_size = Vector2(42,42)
    build_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    build_art.set("facility_kind","residence")
    build_art.tooltip_text = "Đệ Tử Xá · Model Source A 510076 khi SHA hợp lệ; fallback được ghi rõ."
    build_mode_panel.add_child(build_art)

    var fixed_hint := _label(build_mode_panel,"",Vector2(18,202),Vector2(354,58),10)
    fixed_hint.text = "Đệ Tử Xá: có giao dịch xây và dời an toàn.\nCác công trình khác giữ vị trí khởi lập; chưa có lệnh xây/dời."
    fixed_hint.add_theme_color_override("font_color",Color(0.24,0.22,0.18,0.82))

    var open_hall := Button.new()
    open_hall.name = "BuildModeOpenHall"
    open_hall.text = "MỞ ĐẠI ĐIỆN · XEM ĐIỀU KIỆN MỞ LÔ"
    open_hall.position = Vector2(18,260)
    open_hall.size = Vector2(354,38)
    open_hall.add_theme_stylebox_override("normal",_style(JADE,PAPER_LIGHT,1,8))
    open_hall.add_theme_color_override("font_color",PAPER_LIGHT)
    open_hall.pressed.connect(_open_hall_from_build_mode)
    build_mode_panel.add_child(open_hall)

    var move_heading := _label(build_mode_panel,"DI DỜI NHÀ PHỤ ĐỦ ĐIỀU KIỆN",Vector2(18,302),Vector2(354,22),11)
    move_heading.add_theme_color_override("font_color",JADE_DARK)
    var move_scroll := ScrollContainer.new()
    move_scroll.name = "RelocatableResidenceList"
    move_scroll.position = Vector2(18,326)
    move_scroll.size = Vector2(354,70)
    move_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    build_mode_move_list = VBoxContainer.new()
    build_mode_move_list.name = "RelocatableResidenceItems"
    build_mode_move_list.custom_minimum_size.x = 338
    move_scroll.add_child(build_mode_move_list)
    build_mode_panel.add_child(move_scroll)

    build_mode_feedback = _label(build_mode_panel,"",Vector2(18,398),Vector2(354,44),11)
    build_mode_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    build_mode_feedback.add_theme_color_override("font_color",JADE_DARK)
    build_mode_site_label = _label(build_mode_panel,"Chọn Đệ Tử Xá hoặc một căn nhà trống, sau đó bấm lô đất trên bản đồ.",Vector2(18,444),Vector2(354,56),11)
    build_mode_site_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    build_mode_site_label.add_theme_color_override("font_color",INK)
    build_mode_confirm = Button.new()
    build_mode_confirm.name = "ConfirmMapConstruction"
    build_mode_confirm.text = "XÁC NHẬN"
    build_mode_confirm.position = Vector2(18,510)
    build_mode_confirm.size = Vector2(172,38)
    build_mode_confirm.disabled = true
    build_mode_confirm.add_theme_stylebox_override("normal",_style(CINNABAR,PAPER_LIGHT,2,8))
    build_mode_confirm.add_theme_color_override("font_color",PAPER_LIGHT)
    build_mode_confirm.pressed.connect(_confirm_build_mode_action)
    build_mode_panel.add_child(build_mode_confirm)
    var cancel := Button.new()
    cancel.name = "CancelMapConstruction"
    cancel.text = "HỦY CHỌN"
    cancel.position = Vector2(198,510)
    cancel.size = Vector2(174,38)
    cancel.pressed.connect(_clear_build_mode_selection)
    build_mode_panel.add_child(cancel)
    _refresh_build_mode_panel()

func _enter_build_mode() -> void:
    _close_disciple_summary(true)
    _close_building_operation_panel(true)
    _clear_popup()
    build_mode_active = true
    build_mode_kind = ""
    build_mode_house_id = &""
    build_mode_site = SectResidenceSiteV1.UNSELECTED
    if build_mode_feedback != null:
        build_mode_feedback.text = ""
    if build_mode_panel != null:
        build_mode_panel.visible = true
    _focus_buildable_residence_area()
    _refresh_build_mode_panel()

func _focus_buildable_residence_area() -> void:
    if state == null or iso_world == null:
        return
    var plots: Array[Vector2i] = []
    var center := Vector2.ZERO
    # Focus the legal geometry even when a real Hall/resource gate is still
    # closed, so the player can see where the next annex will go and why it
    # cannot yet be confirmed.
    for site in SectResidenceSiteV1.available_plots(state):
        plots.append(site)
        center += Vector2(site)
    if plots.is_empty():
        return
    center /= float(plots.size())
    # Keep legal lots in the unobstructed right-hand part of the map beside
    # the construction panel, at a zoom that shows the complete plot group.
    var focus_cell := center+Vector2(-5.0,5.0)
    var focus_world := SectIsometricWorldV1.LEGACY_ANCHOR \
        + SectIsometricWorldV1.project(focus_cell) \
        - SectIsometricWorldV1.project(SectIsometricWorldV1.CENTER_CELL)
    var transform := SectMapCamera.focus_transform(focus_world,0.75)
    _apply_camera(float(transform["zoom"]),transform["position"],false)

func _open_hall_from_build_mode() -> void:
    _leave_build_mode(true)
    _open_dai_dien_screen_v1()
func _leave_build_mode(clear_selection: bool = true) -> void:
    build_mode_active = false
    if build_mode_panel != null:
        build_mode_panel.visible = false
    if iso_world != null:
        iso_world.clear_placement_preview()
        if iso_viewport != null:
            iso_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
    if clear_selection:
        build_mode_kind = ""
        build_mode_house_id = &""
        build_mode_site = SectResidenceSiteV1.UNSELECTED

func _begin_residence_construction() -> void:
    build_mode_kind = "construct"
    build_mode_house_id = &""
    build_mode_site = SectResidenceSiteV1.UNSELECTED
    if build_mode_feedback != null:
        build_mode_feedback.text = ""
    if iso_world != null:
        iso_world.clear_placement_preview()
        if iso_viewport != null:
            iso_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
    _refresh_build_mode_panel()

func _begin_residence_relocation(house_id: StringName) -> void:
    build_mode_kind = "relocate"
    build_mode_house_id = house_id
    build_mode_site = SectResidenceSiteV1.UNSELECTED
    if build_mode_feedback != null:
        build_mode_feedback.text = ""
    if iso_world != null:
        iso_world.clear_placement_preview()
        if iso_viewport != null:
            iso_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
    _refresh_build_mode_panel()

func _clear_build_mode_selection() -> void:
    build_mode_kind = ""
    build_mode_house_id = &""
    build_mode_site = SectResidenceSiteV1.UNSELECTED
    if build_mode_feedback != null:
        build_mode_feedback.text = ""
    if iso_world != null:
        iso_world.clear_placement_preview()
        if iso_viewport != null:
            iso_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
    _refresh_build_mode_panel()

func _select_build_mode_site(site: Vector2i) -> void:
    if not build_mode_active or build_mode_kind.is_empty():
        build_mode_feedback.text = _wrap_build_mode_text("Chọn công trình ở danh mục trước, rồi chạm vào vị trí đặt trên bản đồ.",50)
        return
    build_mode_site = site
    var check: Dictionary
    if build_mode_kind == "construct":
        check = SectResidenceSystemV1.can_construct(state,site)
    else:
        check = SectResidenceSystemV1.can_move_house(state,build_mode_house_id,site)
    if bool(check.get("ok",false)):
        var actor_conflict := _residence_site_actor_conflict_reason(site)
        if not actor_conflict.is_empty():
            check = {"ok":false,"reason":actor_conflict}
    if iso_world != null:
        iso_world.set_placement_preview({"site":site,"ok":bool(check.get("ok",false))})
        if iso_viewport != null:
            iso_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
    _refresh_build_mode_panel(check)

func _residence_site_actor_conflict_reason(site: Vector2i) -> String:
    if state == null or actor_virtual_positions.is_empty():
        return ""
    var footprint := Rect2i(site,SectResidenceSiteV1.HOUSE_FOOTPRINT)
    var doorway := SectResidenceSiteV1.doorway(site)
    for raw_id in actor_virtual_positions.keys():
        var disciple_id := StringName(str(raw_id))
        if not state.disciples.has(disciple_id):
            continue
        var top_left: Vector2 = actor_virtual_positions[raw_id]
        var actor_foot := top_left+DiscipleActorVisualCatalog.ACTOR_FOOT_POINT
        # actor_virtual_positions use the legacy Control's local coordinate;
        # map it back through the shared PV01 project/inverse pair so the
        # canonical site footprint is compared with the actor's ground tile.
        var isometric_point := actor_foot-SectIsometricWorldV1.LEGACY_ANCHOR \
            + SectIsometricWorldV1.project(Vector2(SectIsometricWorldV1.CENTER_CELL))
        var fractional_cell := SectIsometricWorldV1.inverse(isometric_point)
        var actor_cell := Vector2i(roundi(fractional_cell.x),roundi(fractional_cell.y))
        if footprint.has_point(actor_cell) or doorway == actor_cell:
            return "house_plot_actor_occupied"
    return ""

func _refresh_build_mode_panel(last_check: Dictionary = {}) -> void:
    if build_mode_panel == null or state == null:
        return
    var houses := SectResidenceSystemV1.all_houses(state)
    var hall := SectHallSystemV1.hall(state)
    var rank_limit := SectHallSystemV1.rank_population_limit(state)
    var usable_capacity := SectResidenceSystemV1.current_limit(state)
    var free_places := maxi(0,usable_capacity-state.disciples.size())
    var hall_level := int(hall.level) if hall != null else 0
    var next_hall_gate := SectResidenceSystemV1.required_hall_level_for_instance(houses.size()+1)
    var gate_text := _construction_gate_text()
    var text := "Đệ Tử Xá %d/%d · %d giường · còn %d chỗ.\nĐại Điện Lv%d · lô kế mở ở Lv%d." % [
        houses.size(),SectResidenceSystemV1.maximum_instances(state),SectResidenceSystemV1.total_beds(state),free_places,
        hall_level,next_hall_gate
    ]
    if hall == null:
        text = "Đại Điện chưa mở hệ thống Đệ Tử Xá."
    if build_mode_description != null:
        build_mode_description.text = _wrap_build_mode_text(text,48)
    var catalog_house := build_mode_panel.find_child("BuildCatalogResidence",true,false) as Button
    if catalog_house != null:
        var construct_gate := SectResidenceSystemV1.can_construct(state)
        catalog_house.disabled = not bool(construct_gate.get("ok",false))
        catalog_house.text = "ĐẶT ĐỆ TỬ XÁ · %d/%d NHÀ" % [houses.size(),SectResidenceSystemV1.maximum_instances(state)]
        catalog_house.tooltip_text = gate_text
    if build_mode_move_list != null:
        for child in build_mode_move_list.get_children():
            build_mode_move_list.remove_child(child)
            child.queue_free()
        var display_index := 0
        for house in houses:
            if house.instance_index <= 1:
                continue
            display_index += 1
            var site := SectResidenceSiteV1.origin_of(house)
            var can_move := SectResidenceSystemV1.can_move_house(state,house.id,site)
            var move := Button.new()
            move.name = "MoveResidence_%02d" % house.instance_index
            move.text = "Đệ Tử Xá %02d · %s" % [house.instance_index,
                "trống, có thể dời" if bool(can_move.get("ok",false)) else _build_reason_text(str(can_move.get("reason","không thể dời")))]
            move.custom_minimum_size = Vector2(338,34)
            move.disabled = not bool(can_move.get("ok",false))
            move.pressed.connect(_begin_residence_relocation.bind(house.id))
            build_mode_move_list.add_child(move)
        if display_index == 0:
            var none := _label(build_mode_move_list,"Chưa có nhà phụ nào đủ điều kiện dời.",Vector2.ZERO,Vector2(338,30),10)
            none.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

    var check := last_check
    if check.is_empty() and build_mode_kind == "construct" and build_mode_site != SectResidenceSiteV1.UNSELECTED:
        check = SectResidenceSystemV1.can_construct(state,build_mode_site)
    elif check.is_empty() and build_mode_kind == "relocate" and build_mode_site != SectResidenceSiteV1.UNSELECTED:
        check = SectResidenceSystemV1.can_move_house(state,build_mode_house_id,build_mode_site)
    if build_mode_kind in ["construct","relocate"] \
            and build_mode_site != SectResidenceSiteV1.UNSELECTED \
            and bool(check.get("ok",false)):
        var actor_conflict := _residence_site_actor_conflict_reason(build_mode_site)
        if not actor_conflict.is_empty():
            check = {"ok":false,"reason":actor_conflict}
    if build_mode_site_label != null:
        if build_mode_site == SectResidenceSiteV1.UNSELECTED:
            build_mode_site_label.text = "Chọn công trình hoặc nhà trống, rồi chạm một khoảng đất trống.\nBóng nhà và lối ra sẽ cho biết vị trí hợp lệ."
        else:
            var door := SectResidenceSiteV1.doorway(build_mode_site)
            var site_status := "HỢP LỆ" if bool(check.get("ok",false)) else _build_reason_text(str(check.get("reason","site_invalid")))
            build_mode_site_label.text = _wrap_build_mode_text("Lô (%d,%d) · cửa (%d,%d): %s" % [build_mode_site.x,build_mode_site.y,door.x,door.y,site_status],45)
    if build_mode_feedback != null and build_mode_feedback.text.is_empty():
        if build_mode_kind == "construct":
            build_mode_feedback.text = _wrap_build_mode_text("Chi phí nhà kế: %s · thi công %d nhịp." % [
                _construction_cost_summary(SectResidenceSystemV1.build_cost(state)),
                SectResidenceSystemV1.construction_duration_ticks(houses.size()+1)
            ],50)
        elif build_mode_kind == "relocate":
            build_mode_feedback.text = _wrap_build_mode_text("Chỉ nhà phụ đã xây xong, đang trống và không nâng cấp mới được di dời. Phí và tài nguyên không đổi.",50)
        else:
            build_mode_feedback.text = _wrap_build_mode_text("Đặt nhà phụ mở theo cấp Đại Điện; công trình khởi lập độc bản hiện giữ nguyên vị trí.",50)
    if build_mode_confirm != null:
        build_mode_confirm.disabled = build_mode_kind.is_empty() or build_mode_site == SectResidenceSiteV1.UNSELECTED or not bool(check.get("ok",false))
        build_mode_confirm.text = "KHỞI CÔNG" if build_mode_kind == "construct" else ("DỜI NHÀ" if build_mode_kind == "relocate" else "XÁC NHẬN")

func _wrap_build_mode_text(raw_text: String, max_chars: int) -> String:
    var output := PackedStringArray()
    for paragraph in raw_text.split("\n",false):
        var line := ""
        for word in paragraph.split(" ",false):
            if not line.is_empty() and line.length()+1+word.length() > max_chars:
                output.append(line)
                line = word
            else:
                line = word if line.is_empty() else line+" "+word
        if not line.is_empty():
            output.append(line)
    return "\n".join(output)
func _construction_cost_summary(cost: Dictionary) -> String:
    var names := {BuildingSystem.MATERIAL_WOOD:"Linh Mộc",BuildingSystem.MATERIAL_ORE:"Thanh Thiết","spirit_stones":"Linh Thạch"}
    var parts := PackedStringArray()
    var keys: Array = cost.keys()
    keys.sort()
    for key in keys:
        parts.append("%s %d" % [str(names.get(str(key),str(key))),int(cost[key])])
    return " · ".join(parts)

func _build_reason_text(reason: String) -> String:
    match reason:
        "main_hall_instance_limit":
            var hall := SectHallSystemV1.hall(state)
            var current_hall_level := int(hall.level) if hall != null else 0
            var required_hall_level := SectResidenceSystemV1.required_hall_level_for_instance(
                SectResidenceSystemV1.all_houses(state).size()+1)
            return "Cần Đại Điện Lv%d để mở lô nhà kế tiếp (hiện Lv%d). Nâng cấp từ nút Đại Điện." % [required_hall_level,current_hall_level]
        "missing_material": return "Thiếu nguyên liệu: cần thêm tài nguyên trong Kho."
        "missing_spirit_stones": return "Thiếu Linh Thạch trong Kho."
        "invalid_house_plot": return "Lô không nằm trong khu xây dựng."
        "house_plot_outside_open_area": return "Lô nằm ngoài khu đất đã quy hoạch."
        "house_plot_occupied": return "Lô hoặc lối ra chồng với công trình/lối đi khác."
        "house_plot_unreachable": return "Lô chưa nối được lối đi từ cổng Tông Môn."
        "house_plot_actor_occupied": return "Đệ tử đang đứng trên lô hoặc lối ra; hãy chọn ô khác."
        "house_occupied": return "Nhà còn đệ tử được phân phòng; chuyển họ trước khi dời."
        "house_not_idle": return "Nhà đang xây hoặc nâng cấp."
        "starter_house_fixed": return "Đệ Tử Xá khởi đầu cố định."
        "residence_not_enabled": return "Đại Điện chưa mở hệ thống Đệ Tử Xá."
        "invalid_request_id": return "Thao tác hết hạn; hãy chọn lại lô."
        "residence_id_collision": return "Mã công trình đã tồn tại; không trừ tài nguyên."
        "conflicting_house_move_replay": return "Mã thao tác đã được dùng cho vị trí khác."
        "no_free_house_plot": return "Không còn lô hợp lệ trong khu đất hiện có."
        "max_level": return "Công trình đã đạt cấp tối đa."
        "missing_building": return "Không tìm thấy công trình."
        "main_hall_level_gate": return "Đại Điện chưa mở cấp nâng tiếp theo."
        "already_upgrading": return "Công trình đang nâng cấp."
        "building_not_active": return "Công trình chưa sẵn sàng."
        "insufficient_workforce": return "Thiếu thời gian lao động để hoàn tất."
        _: return reason.replace("_"," ").capitalize()

func _construction_gate_text() -> String:
    var check := SectResidenceSystemV1.can_construct(state)
    var houses := SectResidenceSystemV1.all_houses(state)
    var cost := SectResidenceSystemV1.build_cost(state)
    var warehouse := WarehouseSystem.new()
    var wood_need := int(cost.get(BuildingSystem.MATERIAL_WOOD,0))
    var ore_need := int(cost.get(BuildingSystem.MATERIAL_ORE,0))
    var stone_need := int(cost.get("spirit_stones",0))
    var wood_have := warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_WOOD))
    var ore_have := warehouse.available_quantity(state,StringName(BuildingSystem.MATERIAL_ORE))
    var stone_have := state.sect.spirit_stones
    var resource_text := "Nhà #%d · %d/%d Mộc · %d/%d Thiết · %d/%d Linh Thạch." % [
        houses.size()+1,wood_have,wood_need,ore_have,ore_need,stone_have,stone_need
    ]
    if bool(check.get("ok",false)):
        return "Đủ điều kiện · %s · thi công %d nhịp." % [
            resource_text,SectResidenceSystemV1.construction_duration_ticks(houses.size()+1)
        ]
    var reason := str(check.get("reason","construction_unavailable"))
    if reason == "main_hall_instance_limit":
        var hall := SectHallSystemV1.hall(state)
        var current_level := int(hall.level) if hall != null else 0
        var required_level := SectResidenceSystemV1.required_hall_level_for_instance(houses.size()+1)
        return "Đại Điện Lv%d/%d mới mở lô kế. %s" % [current_level,required_level,resource_text]
    if reason == "missing_material":
        var material := str(check.get("material_id","tài nguyên"))
        var names := {BuildingSystem.MATERIAL_WOOD:"Linh Mộc",BuildingSystem.MATERIAL_ORE:"Thanh Thiết"}
        return "Thiếu %s: cần %d, hiện có %d." % [
            str(names.get(material,material)),int(check.get("need",0)),int(check.get("have",0))
        ]
    if reason == "missing_spirit_stones":
        return "Thiếu Linh Thạch: cần %d, hiện có %d." % [int(check.get("need",0)),int(check.get("have",0))]
    return "%s %s" % [_build_reason_text(reason),resource_text]

func _confirm_build_mode_action() -> void:
    if build_mode_kind.is_empty() or build_mode_site == SectResidenceSiteV1.UNSELECTED:
        return
    var request_id := "map-house:%d:%d:%d:%s" % [state.tick,build_mode_site.x,build_mode_site.y,
        str(build_mode_house_id) if build_mode_kind == "relocate" else "new"]
    var result: Dictionary
    var actor_conflict := _residence_site_actor_conflict_reason(build_mode_site)
    if not actor_conflict.is_empty():
        result = {"ok":false,"reason":actor_conflict}
    elif build_mode_kind == "construct":
        result = SectResidenceSystemV1.construct(state,request_id,build_mode_site)
    else:
        result = SectResidenceSystemV1.move_house(state,request_id,build_mode_house_id,build_mode_site)
    if not bool(result.get("ok",false)):
        build_mode_feedback.text = _wrap_build_mode_text(_build_reason_text(str(result.get("reason","unknown"))),50)
        _refresh_build_mode_panel(result)
        return
    var moved_id := StringName(str(result.get("building_id",result.get("house_id",""))))
    build_mode_feedback.text = _wrap_build_mode_text("Đã khởi công Đệ Tử Xá." if build_mode_kind == "construct" else "Đã dời Đệ Tử Xá đến vị trí mới.",50)
    if iso_world != null:
        iso_world.refresh_from_state(state)
        iso_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
    _refresh_map_worksite_cues()
    var should_open_house := build_mode_kind == "construct"
    _leave_build_mode(true)
    _refresh_all()
    if should_open_house and moved_id != &"":
        _open_building(SectMapPresentation.DEST_RESIDENCE,moved_id)
func _build_building_operation_panel() -> void:
    building_operation_panel = Panel.new()
    building_operation_panel.name = "BuildingOperationPanel"
    building_operation_panel.position = Vector2(48, 78)
    building_operation_panel.size = Vector2(1184, 552)
    building_operation_panel.z_index = 60
    building_operation_panel.visible = false
    building_operation_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    building_operation_panel.add_theme_stylebox_override("panel", _style(PAPER_LIGHT, INK, 3, 14))
    add_child(building_operation_panel)

    building_operation_title = _label(building_operation_panel, "", Vector2(22, 10), Vector2(760, 38), 25)
    building_operation_title.add_theme_color_override("font_color", CINNABAR.darkened(0.18))

    var subtitle := _label(building_operation_panel, "TÔNG MÔN · ĐIỀU PHỐI NHÂN SỰ & TÀI NGUYÊN", Vector2(24, 46), Vector2(760, 20), 11)
    subtitle.add_theme_color_override("font_color", Color(0.22, 0.20, 0.16, 0.72))

    var close := Button.new()
    close.name = "CloseBuildingOperation"
    close.text = "×"
    close.position = Vector2(1120, 10)
    close.size = Vector2(48, 48)
    close.add_theme_font_size_override("font_size", 20)
    close.add_theme_stylebox_override("normal", _style(Color(0.86, 0.80, 0.66, 1.0), INK, 1, 16))
    close.pressed.connect(Callable(self, "_close_building_operation_panel").bind(true))
    building_operation_panel.add_child(close)

    building_operation_metrics = HBoxContainer.new()
    building_operation_metrics.name = "BuildingOperationMetrics"
    building_operation_metrics.position = Vector2(20, 72)
    building_operation_metrics.size = Vector2(1144, 68)
    building_operation_metrics.add_theme_constant_override("separation", 10)
    building_operation_panel.add_child(building_operation_metrics)

    var art_frame := Panel.new()
    art_frame.name = "BuildingOperationArtFrame"
    art_frame.position = Vector2(20, 150)
    art_frame.size = Vector2(250, 150)
    art_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
    art_frame.add_theme_stylebox_override("panel", _style(JADE_DARK, Color(0.11, 0.20, 0.20, 1.0), 2, 12))
    building_operation_panel.add_child(art_frame)
    var art_host := Control.new()
    art_host.name = "BuildingOperationArt"
    art_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    art_frame.add_child(art_host)

    building_operation_body = Label.new()
    building_operation_body.name = "BuildingOperationBody"
    building_operation_body.position = Vector2(286, 150)
    building_operation_body.size = Vector2(878, 150)
    building_operation_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    building_operation_body.add_theme_font_size_override("font_size", 14)
    building_operation_body.add_theme_color_override("font_color", INK)
    building_operation_panel.add_child(building_operation_body)

    # Dedicated first-screen Mine ore picker: no scrolling to reach the action.
    var ore_picker := HBoxContainer.new()
    ore_picker.name = "MineOreHero"
    ore_picker.position = Vector2(286, 218)
    ore_picker.size = Vector2(878, 78)
    ore_picker.add_theme_constant_override("separation", 12)
    ore_picker.visible = false
    building_operation_panel.add_child(ore_picker)

    var separator := HSeparator.new()
    separator.position = Vector2(20, 306)
    separator.size = Vector2(1144, 2)
    building_operation_panel.add_child(separator)

    building_operation_scroll = ScrollContainer.new()
    building_operation_scroll.name = "BuildingOperationScroll"
    building_operation_scroll.position = Vector2(20, 316)
    building_operation_scroll.size = Vector2(520, 216)
    building_operation_panel.add_child(building_operation_scroll)

    building_operation_content = VBoxContainer.new()
    building_operation_content.name = "BuildingOperationContent"
    building_operation_content.custom_minimum_size = Vector2(500, 0)
    building_operation_content.add_theme_constant_override("separation", 10)
    building_operation_scroll.add_child(building_operation_content)

    building_management_container = VBoxContainer.new()
    building_management_container.name = "BuildingManagementControls"
    building_management_container.custom_minimum_size = Vector2(500, 0)
    building_management_container.add_theme_constant_override("separation", 7)
    building_operation_content.add_child(building_management_container)

    building_operation_live_panel = Panel.new()
    building_operation_live_panel.name = "BuildingOperationLivePanel"
    building_operation_live_panel.position = Vector2(552, 316)
    building_operation_live_panel.size = Vector2(612, 216)
    building_operation_live_panel.clip_contents = true
    building_operation_live_panel.add_theme_stylebox_override("panel", _style(Color(0.93, 0.88, 0.75, 1.0), Color(0.51, 0.43, 0.28, 1.0), 1, 10))
    building_operation_panel.add_child(building_operation_live_panel)
    building_operation_live_scroll = ScrollContainer.new()
    building_operation_live_scroll.name = "BuildingOperationLiveScroll"
    building_operation_live_scroll.position = Vector2(14, 10)
    building_operation_live_scroll.size = Vector2(584, 196)
    building_operation_live_panel.add_child(building_operation_live_scroll)
    building_operation_live_content = VBoxContainer.new()
    building_operation_live_content.name = "BuildingOperationLiveContent"
    building_operation_live_content.custom_minimum_size = Vector2(564, 0)
    building_operation_live_content.mouse_filter = Control.MOUSE_FILTER_PASS
    building_operation_live_content.add_theme_constant_override("separation", 6)
    building_operation_live_scroll.add_child(building_operation_live_content)
    building_operation_scroll.size = Vector2(520, 216)

func _building_operation_is_open() -> bool:
    return building_operation_panel != null and is_instance_valid(building_operation_panel) and building_operation_panel.visible

func _show_building_operation_panel() -> void:
    if building_operation_panel == null or selected_building == &"":
        return
    building_operation_panel.visible = true
    # Hide the map's higher-z focus ring while a management screen is visible.
    if focus_marker != null:
        focus_marker.visible = false
    if camera_controls_panel != null:
        camera_controls_panel.visible = false
    if camera_hint != null:
        camera_hint.visible = false
    _refresh_building_operation_content()

func _hide_building_operation_panel() -> void:
    if building_operation_panel != null:
        building_operation_panel.visible = false
    if camera_controls_panel != null and not _disciple_summary_is_open():
        camera_controls_panel.visible = true
    if camera_hint != null and not _disciple_summary_is_open():
        camera_hint.visible = true

func _close_building_operation_panel(clear_selection: bool = true) -> void:
    _hide_building_operation_panel()
    building_management_feedback = ""
    if not clear_selection:
        return
    selected_building = &""
    if focused_kind == &"building":
        focused_kind = &""
        focused_id = &""
        focused_label = ""
        has_focus_target = false
        if focus_marker != null:
            focus_marker.visible = false
        if focus_target_button != null:
            focus_target_button.disabled = true
        _refresh_focus_readout()
        _refresh_actor_status_label_visibility()

func _refresh_building_operation_content(rebuild_management_controls: bool = true) -> void:
    if not _building_operation_is_open() or selected_building == &"":
        return
    building_operation_title.text = _building_name(selected_building)
    var left_scroll_position := building_operation_scroll.scroll_vertical
    var right_scroll_position := building_operation_live_scroll.scroll_vertical
    var workforce_filter_text := ""
    var show_workforce_candidates := false
    if building_management_container != null:
        var existing_search := building_management_container.find_child("WorkforceSearch_*", true, false) as LineEdit
        if existing_search != null:
            workforce_filter_text = existing_search.text
        var existing_candidate_toggle := building_management_container.get_node_or_null("WorkforceCandidateToggle") as Button
        if existing_candidate_toggle != null:
            show_workforce_candidates = existing_candidate_toggle.button_pressed
    var feedback := ""
    if building_management_feedback != "":
        feedback = "\n\n%s" % building_management_feedback
    var operation_text := _building_operation_text(selected_building)
    # The roster and its real commands are presented together below.
    if selected_building in [SectMapPresentation.DEST_MINE,SectMapPresentation.DEST_LINH_FOREST]:
        var roster_boundary := operation_text.find("\n\nNHÂN SỰ")
        if roster_boundary >= 0:
            operation_text = operation_text.substr(0,roster_boundary)
        var active_work_status := _active_resource_worksite_status(selected_building)
        if not active_work_status.is_empty():
            operation_text += "\n\nĐỘI & TIẾN ĐỘ\n" + active_work_status
    if selected_production_instance_id != &"" and state.buildings.has(str(selected_production_instance_id)):
        operation_text += "\n\n" + _map_worksite_operation_detail(
            state.buildings[str(selected_production_instance_id)] as BuildingState
        )
    var mine_open := selected_building == SectMapPresentation.DEST_MINE
    var material_picker_open := selected_building in [SectMapPresentation.DEST_MINE,SectMapPresentation.DEST_LINH_FOREST]
    var operation_headline := _building_operation_headline(operation_text)
    if mine_open:
        var mine_building := _selected_operation_building()
        if mine_building != null:
            var mine_system := BuildingSystem.new()
            var ore_id := mine_system.mine_selected_ore(mine_building)
            var ore_name := ResourceRegistry.new().display_name(ore_id)
            var batch_units := mine_system.mine_ore_batch_units(mine_building, ore_id)
            var available_units := _warehouse_available(ore_id)
            operation_headline = "SẢN XUẤT · MỎ Lv%d\n%s · ×%d / mẻ\nKho khả dụng: %d" % [
                mine_building.level, ore_name, batch_units, available_units
            ]
            var mine_live_status := _active_resource_worksite_status(selected_building)
            if not mine_live_status.is_empty():
                var status_lines := mine_live_status.split("\n", false)
                var primary_status := str(status_lines[0]) if not status_lines.is_empty() else ""
                var status_eta_marker := primary_status.find(" · còn khoảng ")
                if status_eta_marker >= 0:
                    primary_status = primary_status.substr(0, status_eta_marker)
                operation_headline = "SẢN XUẤT · MỎ Lv%d\n%s · ×%d / mẻ · Kho %d\n%s" % [
                    mine_building.level, ore_name, batch_units, available_units, primary_status
                ]
    elif selected_building == SectMapPresentation.DEST_LINH_FOREST:
        var forest_building := _selected_operation_building()
        if forest_building != null:
            var forest_system := BuildingSystem.new()
            var chosen := forest_system.forest_selected_material(forest_building)
            operation_headline = "SẢN XUẤT · LINH LÂM Lv%d\n%s · ×%d / mẻ · Kho %d" % [
                forest_building.level,ResourceRegistry.new().display_name(chosen),
                forest_system.forest_material_batch_units(forest_building,chosen),_warehouse_available(chosen)]
        var live_status := _active_resource_worksite_status(selected_building)
        for raw_status_line in live_status.split("\n"):
            var status_line := str(raw_status_line).strip_edges()
            if not status_line.is_empty():
                operation_headline += "\n" + status_line
                break
    building_operation_body.text = operation_headline + feedback
    building_operation_body.tooltip_text = operation_text + feedback
    building_operation_body.size.y = 66.0 if material_picker_open else 150.0
    building_operation_body.clip_text = false
    _refresh_mine_ore_hero()
    _refresh_building_operation_art()
    _refresh_building_operation_metrics()
    _refresh_building_operation_live(operation_text)
    building_operation_scroll.position = Vector2(20, 316)
    building_operation_scroll.size = Vector2(520, 216)
    building_operation_content.custom_minimum_size.x = 500
    building_operation_live_panel.visible = true
    building_operation_live_panel.position = Vector2(552, 316)
    building_operation_live_panel.size = Vector2(612, 216)
    if rebuild_management_controls:
        _rebuild_building_management_controls()
        _style_building_management_actions(building_management_container)
        var refreshed_search := building_management_container.find_child("WorkforceSearch_*", true, false) as LineEdit
        if refreshed_search != null:
            refreshed_search.text = workforce_filter_text
        var refreshed_candidate_toggle := building_management_container.get_node_or_null("WorkforceCandidateToggle") as Button
        if refreshed_candidate_toggle != null:
            refreshed_candidate_toggle.button_pressed = show_workforce_candidates
            refreshed_candidate_toggle.text = "Ẩn đệ tử chưa phân công" if show_workforce_candidates else "+ Chọn thêm đệ tử"
        _filter_building_workers(workforce_filter_text)
        building_management_last_sim_tick = state.tick
        building_management_last_refresh_frame = Engine.get_process_frames()
    building_operation_scroll.set_deferred("scroll_vertical", left_scroll_position)
    building_operation_live_scroll.set_deferred("scroll_vertical", right_scroll_position)

func _style_building_management_actions(root: Node) -> void:
    for node in root.get_children():
        if node is Button:
            var action := node as Button
            var base_color := CINNABAR if action.text.begins_with("Rút") else JADE_DARK
            action.add_theme_stylebox_override("normal", _style(base_color, GOLD, 1, 7))
            action.add_theme_stylebox_override("hover", _style(base_color.lightened(0.12), GOLD, 2, 7))
            action.add_theme_stylebox_override("pressed", _style(base_color.darkened(0.12), GOLD, 2, 7))
            action.add_theme_stylebox_override("disabled", _style(Color(0.85, 0.83, 0.76), Color(0.50, 0.46, 0.37), 1, 7))
            action.add_theme_color_override("font_color", PAPER_LIGHT)
            action.add_theme_color_override("font_hover_color", PAPER_LIGHT)
            action.add_theme_color_override("font_pressed_color", PAPER_LIGHT)
            action.add_theme_color_override("font_disabled_color", INK)
        elif node is Label:
            var caption := node as Label
            if not caption.has_theme_color_override("font_color"):
                caption.add_theme_color_override("font_color", INK)
        _style_building_management_actions(node)

func _building_operation_headline(operation_text: String) -> String:
    var result: Array[String] = []
    # Body Training's paid-minute/stone audit is line six. Keep it visible
    # rather than hiding the actual debit ledger in the tooltip.
    var max_lines := 6 if selected_building == SectMapPresentation.DEST_BODY_TRAINING else 5
    for raw_line in operation_text.split("\n"):
        var line := str(raw_line).strip_edges()
        if line.is_empty() or line == "TÌNH HÌNH VẬN HÀNH":
            continue
        result.append(line)
        if result.size() >= max_lines:
            break
    return "\n".join(result) if not result.is_empty() else "Chưa có dữ liệu vận hành."

func _selected_operation_building() -> BuildingState:
    if state == null:
        return null
    if selected_production_instance_id != &"" and state.buildings.has(str(selected_production_instance_id)):
        return state.buildings[str(selected_production_instance_id)] as BuildingState
    var building_type: StringName = &""
    match selected_building:
        SectMapPresentation.DEST_MAIN_HALL:
            building_type = BuildingSystem.TYPE_MAIN_HALL
        SectMapPresentation.DEST_RESIDENCE:
            building_type = BuildingSystem.TYPE_RESIDENCE
        SectMapPresentation.DEST_MINE:
            building_type = BuildingSystem.TYPE_MINE
        SectMapPresentation.DEST_LINH_FOREST:
            building_type = BuildingSystem.TYPE_LINH_FOREST
        SectMapPresentation.DEST_ALCHEMY_HALL:
            building_type = BuildingSystem.TYPE_ALCHEMY_HALL
        SectMapPresentation.DEST_SPIRIT_FIELD:
            building_type = BuildingSystem.TYPE_SPIRIT_FIELD
        SectMapPresentation.DEST_BODY_TRAINING:
            building_type = BuildingSystem.TYPE_BODY_TRAINING
        SectMapPresentation.DEST_GUIDANCE:
            building_type = BuildingSystem.TYPE_GUIDANCE_PLATFORM
    if building_type == &"":
        return null
    return BuildingSystem.new().primary_building(state, building_type)

func _refresh_building_operation_art() -> void:
    var frame := building_operation_panel.get_node_or_null("BuildingOperationArtFrame") as Panel
    var host := building_operation_panel.get_node_or_null("BuildingOperationArtFrame/BuildingOperationArt") as Control
    if frame == null or host == null:
        return
    var art_key := str(selected_building)
    if str(host.get_meta("art_key", "")) == art_key:
        return
    host.set_meta("art_key", art_key)
    for child in host.get_children():
        host.remove_child(child)
        child.queue_free()

    var worksite_path := ""
    var worksite_caption := ""
    match selected_building:
        SectMapPresentation.DEST_MINE:
            worksite_path = "res://art/map_d2_candidate/mine_worksite_v1.svg"
            worksite_caption = "MỎ · KHAI THÁC TÀI NGUYÊN"
        SectMapPresentation.DEST_LINH_FOREST:
            worksite_path = "res://art/map_d2_candidate/linh_forest_worksite_v1.svg"
            worksite_caption = "LINH LÂM · THU HOẠCH LINH MỘC"
        SectMapPresentation.DEST_SPIRIT_FIELD:
            worksite_path = "res://art/map_d2_candidate/spirit_field_worksite_v1.svg"
            worksite_caption = "LINH ĐIỀN · GIEO TRỒNG"
    if not worksite_path.is_empty():
        var worksite_texture := load(worksite_path) as Texture2D
        if worksite_texture != null:
            var image := TextureRect.new()
            image.name = "WorksiteIllustration"
            image.texture = worksite_texture
            image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
            image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
            image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
            image.mouse_filter = Control.MOUSE_FILTER_IGNORE
            host.add_child(image)
            var caption := Label.new()
            caption.name = "WorksiteIllustrationCaption"
            caption.text = worksite_caption
            caption.position = Vector2(10, 119)
            caption.size = Vector2(230, 23)
            caption.add_theme_font_size_override("font_size", 11)
            caption.add_theme_color_override("font_color", PAPER_LIGHT)
            caption.add_theme_color_override("font_outline_color", Color(0.03, 0.07, 0.06, 1.0))
            caption.add_theme_constant_override("outline_size", 4)
            caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
            host.add_child(caption)
            return

    var source_kind := ""
    match selected_building:
        SectMapPresentation.DEST_MAIN_HALL: source_kind = "hall"
        SectMapPresentation.DEST_RESIDENCE: source_kind = "residence"
        SectMapPresentation.DEST_GUIDANCE: source_kind = "guidance"
    if source_kind != "":
        var source_art := TRI_FACILITY_ART.new() as Control
        source_art.name = "VerifiedFacilityArt"
        source_art.set("facility_kind", source_kind)
        source_art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        host.add_child(source_art)
        return
    var kind := "profession"
    match selected_building:
        SectMapPresentation.DEST_BODY_TRAINING: kind = "person"
        SectMapPresentation.DEST_ALCHEMY_HALL: kind = "flame"
        SectMapPresentation.DEST_FORGE: kind = "ore"
        SectMapPresentation.DEST_MEDICINE: kind = "leaf"
        SectMapPresentation.DEST_CULTIVATION: kind = "root"
        SectMapPresentation.DEST_GATE: kind = "gate"
        SectMapPresentation.DEST_WAREHOUSE: kind = "resource"
        _: kind = "profession"
    var illustration := Control.new()
    illustration.name = "FacilityIconIllustration"
    illustration.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
    host.add_child(illustration)
    var icon := SECT_UI_ICON.new() as Control
    icon.name = "FacilityOperationIcon"
    icon.set("kind", kind)
    icon.set("tint", GOLD)
    icon.position = Vector2(88, 27)
    icon.size = Vector2(72, 72)
    icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
    illustration.add_child(icon)

func _refresh_building_operation_metrics() -> void:
    for child in building_operation_metrics.get_children():
        building_operation_metrics.remove_child(child)
        child.queue_free()
    var building := _selected_operation_building()
    var level_text := "—"
    var worker_text := "—"
    var cycle_text := "Chưa khởi khai"
    var cycle_tooltip := ""
    var output_text := "—"
    var output_tooltip := ""
    var icon_kind := "resource"
    var buildings := BuildingSystem.new()
    if building != null:
        level_text = "Lv%d" % building.level
        var assigned := buildings.assigned_worker_ids(state, building)
        var active := buildings.active_worker_ids(state, building)
        var slots := maxi(0, buildings.worker_slots(building))
        var waiting := maxi(0, assigned.size() - active.size())
        var definition := buildings.definition_for(building)
        var group_id := StringName(definition.get("worker_group_id", ""))
        var team_count := _disciples_in_work_group(group_id).size() if group_id != &"" else assigned.size()
        worker_text = "%d · %d · %d/%d · %d" % [
            team_count, assigned.size(), active.size(), slots, waiting
        ]
        if building.building_type == BuildingSystem.TYPE_BODY_TRAINING:
            var running := 0
            for disciple_id in assigned:
                if state.disciples.has(disciple_id) and state.disciples[disciple_id].current_action == &"TRAIN_BODY":
                    running += 1
            cycle_text = "%d đang rèn" % running
            output_text = "%d lượt" % int(building.production_state.get("paid_training_minutes", 0))
            icon_kind = "person"
        else:
            var snapshot := _map_worksite_snapshot(building)
            cycle_text = str(snapshot.get("detail", "Chưa khởi khai"))
            cycle_tooltip = cycle_text
            var eta_marker := cycle_text.find(" · còn khoảng ")
            if eta_marker >= 0:
                cycle_text = "Còn " + cycle_text.substr(eta_marker + " · còn khoảng ".length())
            if building.building_type in [BuildingSystem.TYPE_MINE, BuildingSystem.TYPE_LINH_FOREST] and not bool(snapshot.get("active", false)):
                if not assigned.is_empty():
                    cycle_text = "Chờ lượt đầu"
                    cycle_tooltip = "Đã gán nhân sự. Chưa có chu kỳ sản xuất nào đang chạy. Chi tiết: %s" % cycle_tooltip
                else:
                    cycle_text = "Chưa phân công"
            var produced := maxi(0, int(building.metrics.get("units_produced", 0)))
            if building.building_type == BuildingSystem.TYPE_MINE:
                var ore_id := buildings.mine_selected_ore(building)
                output_text = "%d %s" % [produced, ResourceRegistry.new().display_name(ore_id)]
            elif building.building_type == BuildingSystem.TYPE_LINH_FOREST:
                var forest_resource := buildings.forest_selected_material(building)
                output_text = "%d đơn vị tổng (đang chọn %s)" % [produced,ResourceRegistry.new().display_name(forest_resource)]
            else:
                output_text = "%d đơn vị" % produced
            output_tooltip = "Tổng sản lượng đã ghi nhận sau lần nhập Kho thành công theo bộ đếm BuildingSystem. Đây không phải tồn kho hiện tại; mẻ đang chạy và ETA xem ở mục Tiến độ."
            if building.building_type == BuildingSystem.TYPE_MINE:
                icon_kind = "ore"
            elif building.building_type == BuildingSystem.TYPE_LINH_FOREST:
                icon_kind = "wood"
            else:
                icon_kind = "leaf"
    var progress_caption := "TRẠNG THÁI"
    if building != null:
        match building.building_type:
            BuildingSystem.TYPE_MINE:
                progress_caption = "KHAI KHOÁNG / ETA"
            BuildingSystem.TYPE_LINH_FOREST:
                progress_caption = "THU LÂM / ETA"
            BuildingSystem.TYPE_SPIRIT_FIELD:
                progress_caption = "SINH TRƯỞNG / ETA"
            BuildingSystem.TYPE_BODY_TRAINING:
                progress_caption = "LƯỢT RÈN THÂN"
            _:
                progress_caption = "TRẠNG THÁI"
    var metric_rows: Array = [
        ["CẤP CÔNG TRÌNH", level_text, "upgrade"],
        ["ĐỘI · GÁN · LÀM/SLOT · CHỜ", worker_text, "worker"],
        [progress_caption, cycle_text, "timer"],
        ["ĐÃ SẢN XUẤT", output_text, icon_kind]
    ]
    if building != null and building.building_type in [
        BuildingSystem.TYPE_MINE, BuildingSystem.TYPE_LINH_FOREST, BuildingSystem.TYPE_SPIRIT_FIELD
    ]:
        metric_rows.append([
            "SẢN LƯỢNG / PHÚT", _worksite_rate_text(building), "resource"
        ])
    for entry in metric_rows:
        var card := SECT_UI_THEME.metric_card(str(entry[0]), str(entry[1]), str(entry[2]), GOLD)
        card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        card.custom_minimum_size = Vector2(0, 66)
        var value_label := card.find_child("MetricValue", true, false) as Label
        if value_label != null:
            var value_length := str(entry[1]).length()
            value_label.add_theme_font_size_override("font_size", 12 if value_length >= 22 else (13 if value_length >= 18 else 16))
        if str(entry[0]) == "ĐÃ SẢN XUẤT":
            card.tooltip_text = output_tooltip
        elif str(entry[0]) == "ĐỘI · GÁN · LÀM/SLOT · CHỜ":
            card.tooltip_text = "Các số lần lượt là: tổng người thuộc đội nghề · số người gắn với công trình · số người đang làm / số chỗ công trình · số người đã gán nhưng đang chờ chỗ. Nguồn: nhóm nghề và BuildingSystem."
        elif str(entry[0]) == progress_caption:
            card.tooltip_text = cycle_tooltip
        elif str(entry[0]) == "SẢN LƯỢNG / PHÚT":
            card.tooltip_text = "Mỏ/Linh Lâm: ước tính từ mẻ timer hoặc chu kỳ mang hàng đủ các pha đi tới, làm việc và về Kho, dùng tốc độ nghề/di chuyển hiện tại. Linh Điền: tổng sản lượng cơ bản của từng ô đang trồng chia thời lượng mẻ. Đây là dự kiến theo trạng thái hiện tại, không phải số đã nhập Kho."
        building_operation_metrics.add_child(card)

func _worksite_rate_text(building: BuildingState) -> String:
    if building == null or state == null:
        return "—"
    var system := BuildingSystem.new()
    var registry := ResourceRegistry.new()
    var rate_by_resource: Dictionary = {}
    if building.building_type in [BuildingSystem.TYPE_MINE, BuildingSystem.TYPE_LINH_FOREST]:
        var raw_jobs = building.production_state.get("economy_a_jobs", [])
        if raw_jobs is Array:
            for raw_job in raw_jobs:
                if not (raw_job is Dictionary):
                    continue
                var job: Dictionary = raw_job
                var started_tick := int(job.get("started_tick", state.tick))
                var finish_tick := int(job.get("finish_tick", state.tick))
                var duration_ticks := finish_tick - started_tick
                var output_quantity := maxi(0, int(job.get("output_quantity", 0)))
                var resource_id := StringName(job.get("resource_id", ""))
                if finish_tick > state.tick and duration_ticks > 0 and output_quantity > 0 and resource_id != &"":
                    rate_by_resource[resource_id] = float(rate_by_resource.get(resource_id, 0.0)) + float(output_quantity) / float(duration_ticks)
        if rate_by_resource.is_empty():
            var profession_id := StringName(system.definition_for(building).get("profession_id", ""))
            for worker_value in system.active_worker_ids(state, building):
                var worker_id := StringName(worker_value)
                if not state.disciples.has(worker_id):
                    continue
                var worker: DiscipleState = state.disciples[worker_id]
                var cycle: Dictionary = worker.work_cycle_state
                if not cycle.is_empty():
                    var cycle_building := StringName(cycle.get("building_id", ""))
                    var cycle_profession := StringName(cycle.get("profession_id", cycle.get("profession", "")))
                    if cycle_building != building.id or cycle_profession != profession_id:
                        continue
                var profile := _legacy_carry_cycle_profile(building, worker, cycle)
                var cycle_ticks := maxi(1, int(profile.get("total_ticks", 0)))
                var quantity := maxi(0, int(profile.get("output_quantity", 0)))
                var resource_id := StringName(profile.get("resource_id", ""))
                if quantity > 0 and resource_id != &"":
                    rate_by_resource[resource_id] = float(rate_by_resource.get(resource_id, 0.0)) + float(quantity) / float(cycle_ticks)
        if rate_by_resource.is_empty():
            return "Chưa có mẻ" if system.active_worker_ids(state, building).is_empty() else "Chờ lượt đầu"
        var rate_ids: Array = rate_by_resource.keys()
        rate_ids.sort()
        var rate_parts := PackedStringArray()
        for raw_id in rate_ids:
            rate_parts.append("%.2f %s" % [float(rate_by_resource[raw_id]), registry.display_name(StringName(raw_id))])
        if rate_parts.size() == 1:
            return "≈ %s/phút" % rate_parts[0]
        return "≈ %.2f đv/phút (%d loại)" % [_sum_rate_values(rate_by_resource), rate_parts.size()]
    elif building.building_type == BuildingSystem.TYPE_SPIRIT_FIELD:
        var field_rate := 0.0
        var waiting_harvest := false
        var raw_plots = building.production_state.get("plots", [])
        if raw_plots is Array:
            for raw_plot in raw_plots:
                if not (raw_plot is Dictionary):
                    continue
                var plot: Dictionary = raw_plot
                var started_tick := int(plot.get("started_tick", state.tick))
                var finish_tick := int(plot.get("finish_tick", state.tick))
                var duration_ticks := finish_tick - started_tick
                var yield_units := maxi(0, int(plot.get("routine_yield", 0)))
                if StringName(plot.get("status", "")) == BuildingSystem.PLOT_GROWING and yield_units > 0:
                    if finish_tick > state.tick and duration_ticks > 0:
                        field_rate += float(yield_units) / float(duration_ticks)
                    else:
                        waiting_harvest = true
        if field_rate > 0.0:
            return "≈ %.2f đv/phút" % field_rate
        return "Chờ nhập Kho" if waiting_harvest else "Chưa có ô trồng"
    return "—"

func _sum_rate_values(rate_by_resource: Dictionary) -> float:
    var total := 0.0
    for raw_value in rate_by_resource.values():
        total += float(raw_value)
    return total

func _legacy_carry_cycle_profile(building: BuildingState, disciple: DiscipleState, cycle: Dictionary) -> Dictionary:
    if building == null or disciple == null or state == null:
        return {}
    var system := BuildingSystem.new()
    var definition := system.definition_for(building)
    var profession_id := StringName(definition.get("profession_id", ""))
    var resource_id := StringName(cycle.get("resource_id", "")) if not cycle.is_empty() else &""
    if resource_id == &"":
        resource_id = system.mine_selected_ore(building) if building.building_type == BuildingSystem.TYPE_MINE else StringName(definition.get("resource_id", ""))
    var output_quantity := system.mine_ore_batch_units(building, resource_id) if building.building_type == BuildingSystem.TYPE_MINE else system.resource_job_batch_units(building)
    if not cycle.is_empty():
        output_quantity = maxi(output_quantity, int(cycle.get("carried_units", 0)))
    var move_speed := maxf(system._movement_speed(state, disciple), 0.5)
    var work_speed := maxf(WorkforceSystem.new()._work_speed(state, disciple, profession_id), 0.25)
    var work_distance := maxf(float(definition.get("work_distance", 8.0)), 0.0)
    var haul_distance := maxf(float(definition.get("haul_distance", 6.0)), 0.0)
    var work_duration := maxf(system.resource_job_work_duration(building), 0.1)
    var travel_ticks := ceili(work_distance / move_speed)
    var work_ticks := ceili(work_duration / work_speed)
    var haul_ticks := ceili(haul_distance / move_speed)
    var total_ticks := maxi(1, travel_ticks + work_ticks + haul_ticks)
    var remaining_ticks := total_ticks
    var progress_percent := 0.0
    var phase := StringName(cycle.get("phase", "travel_out")) if not cycle.is_empty() else &"travel_out"
    var phase_progress := maxf(0.0, float(cycle.get("progress", 0.0))) if not cycle.is_empty() else 0.0
    var work_phase := StringName(definition.get("cycle_work_phase", ""))
    if not cycle.is_empty():
        if phase == &"travel_out":
            var remaining_travel := ceili(maxf(0.0, work_distance - phase_progress) / move_speed)
            remaining_ticks = remaining_travel + work_ticks + haul_ticks
        elif phase == work_phase:
            var remaining_work := ceili(maxf(0.0, work_duration - phase_progress) / work_speed)
            remaining_ticks = remaining_work + haul_ticks
        elif phase == &"haul_back":
            var remaining_haul := ceili(maxf(0.0, haul_distance - phase_progress) / move_speed)
            remaining_ticks = remaining_haul
        remaining_ticks = clampi(remaining_ticks, 0, total_ticks)
        progress_percent = 100.0 * float(total_ticks - remaining_ticks) / float(total_ticks)
    return {
        "profession_id": profession_id,
        "resource_id": resource_id,
        "output_quantity": output_quantity,
        "phase": phase,
        "phase_progress": phase_progress,
        "remaining_ticks": remaining_ticks,
        "total_ticks": total_ticks,
        "progress": progress_percent,
        "worker_id": str(disciple.id)
    }

func _legacy_carry_cycle_rows(building: BuildingState) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    if building == null or state == null:
        return result
    var system := BuildingSystem.new()
    var profession_id := StringName(system.definition_for(building).get("profession_id", ""))
    for worker_value in system.active_worker_ids(state, building):
        var worker_id := StringName(worker_value)
        if not state.disciples.has(worker_id):
            continue
        var worker: DiscipleState = state.disciples[worker_id]
        var cycle: Dictionary = worker.work_cycle_state
        if cycle.is_empty():
            continue
        if StringName(cycle.get("building_id", "")) != building.id:
            continue
        if StringName(cycle.get("profession_id", cycle.get("profession", ""))) != profession_id:
            continue
        var profile := _legacy_carry_cycle_profile(building, worker, cycle)
        if not profile.is_empty():
            profile["worker_name"] = worker.display_name
            profile["phase_status"] = _resource_job_member_status(worker, profession_id, true, building)
            result.append(profile)
    result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
        return int(a.get("remaining_ticks", 0)) < int(b.get("remaining_ticks", 0))
    )
    return result

func _refresh_building_operation_live(operation_text: String) -> void:
    for child in building_operation_live_content.get_children():
        building_operation_live_content.remove_child(child)
        child.queue_free()
    var heading := Label.new()
    heading.text = "NHÂN SỰ & TIẾN ĐỘ" if selected_building in [
        SectMapPresentation.DEST_MINE,
        SectMapPresentation.DEST_LINH_FOREST,
        SectMapPresentation.DEST_SPIRIT_FIELD,
        SectMapPresentation.DEST_BODY_TRAINING
    ] else "CHI TIẾT VẬN HÀNH"
    heading.add_theme_font_size_override("font_size", 15)
    heading.add_theme_color_override("font_color", CINNABAR.darkened(0.18))
    building_operation_live_content.add_child(heading)
    var building := _selected_operation_building()
    if building != null and selected_building in [
        SectMapPresentation.DEST_MINE,
        SectMapPresentation.DEST_LINH_FOREST,
        SectMapPresentation.DEST_SPIRIT_FIELD
    ]:
        var snapshot := _map_worksite_snapshot(building)
        building_operation_progress = ProgressBar.new()
        building_operation_progress.name = "CanonicalWorksiteProgress"
        building_operation_progress.custom_minimum_size = Vector2(0, 16)
        building_operation_progress.max_value = 100.0
        building_operation_progress.value = float(snapshot.get("progress", 0.0)) if bool(snapshot.get("active", false)) else 0.0
        building_operation_progress.show_percentage = false
        building_operation_progress.add_theme_stylebox_override("background", _style(Color(0.76, 0.75, 0.66), Color(0.47, 0.42, 0.30), 1, 5))
        building_operation_progress.add_theme_stylebox_override("fill", _style(JADE_DARK, GOLD, 1, 5))
        building_operation_live_content.add_child(building_operation_progress)
        building_operation_progress_label = Label.new()
        building_operation_progress_label.name = "CanonicalWorksiteEta"
        building_operation_progress_label.text = "%s · %s" % [str(snapshot.get("heading", "")), str(snapshot.get("detail", "Chưa khởi khai"))]
        building_operation_progress_label.add_theme_font_size_override("font_size", 12)
        building_operation_progress_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        building_operation_progress_label.add_theme_color_override("font_color", INK)
        building_operation_live_content.add_child(building_operation_progress_label)

        if building.building_type == BuildingSystem.TYPE_MINE or building.building_type == BuildingSystem.TYPE_LINH_FOREST:
            _add_resource_timer_cards(building)
        elif building.building_type == BuildingSystem.TYPE_SPIRIT_FIELD:
            _add_spirit_field_plot_cards(building)

        var building_system := BuildingSystem.new()
        var assigned := building_system.assigned_worker_ids(state, building)
        var active_ids := building_system.active_worker_ids(state, building)
        var slots := maxi(0, building_system.worker_slots(building))
        var waiting := maxi(0, assigned.size() - active_ids.size())
        var crew_definition := building_system.definition_for(building)
        var crew_group_id := StringName(crew_definition.get("worker_group_id", ""))
        var total_group_members := _disciples_in_work_group(crew_group_id).size() if crew_group_id != &"" else assigned.size()
        var crew_summary := Label.new()
        crew_summary.name = "CanonicalCrewSummary"
        crew_summary.text = "Nhóm nghề %d · gắn công trình %d · đang làm %d/%d chỗ · chờ %d" % [total_group_members, assigned.size(), active_ids.size(), slots, waiting]
        crew_summary.add_theme_font_size_override("font_size", 12)
        crew_summary.add_theme_color_override("font_color", JADE_DARK)
        building_operation_live_content.add_child(crew_summary)
        if assigned.is_empty():
            _add_live_worker_message("Chưa phân công nhân sự cho công trình này.")
        else:
            for disciple_id in assigned:
                if not state.disciples.has(disciple_id):
                    continue
                var disciple: DiscipleState = state.disciples[disciple_id]
                var is_active := active_ids.has(disciple_id)
                var status := SectMapPresentation.action_label(disciple.current_action)
                if selected_building == SectMapPresentation.DEST_MINE:
                    status = _mining_member_status(disciple, is_active, building)
                elif selected_building == SectMapPresentation.DEST_LINH_FOREST:
                    status = _resource_job_member_status(disciple, WorkforceSystem.PROF_FORESTRY, is_active, building)
                elif selected_building == SectMapPresentation.DEST_SPIRIT_FIELD:
                    status = _field_worker_status(disciple, building)
                    if not is_active:
                        status = "Chờ chỗ hoạt động"
                _add_live_worker_card(disciple.display_name, status, disciple)
        return
    if building != null and selected_building == SectMapPresentation.DEST_BODY_TRAINING:
        var assigned_body := BuildingSystem.new().assigned_worker_ids(state, building)
        _add_live_worker_message("Rèn thân ghi EXP và trừ phí theo phút mô phỏng; hệ thống hiện không lưu ETA từng phút để hiển thị thanh tiến độ.")
        if assigned_body.is_empty():
            _add_live_worker_message("Chưa phân công đệ tử.")
        else:
            for disciple_id in assigned_body:
                if not state.disciples.has(disciple_id):
                    continue
                var disciple: DiscipleState = state.disciples[disciple_id]
                var last: Dictionary = disciple.last_decision.get("v2_body_training_result", {})
                var result_text := ""
                if bool(last.get("ok", false)) and last.has("gained"):
                    result_text = " · lượt gần nhất +%.0f EXP" % float(last["gained"])
                _add_live_worker_card(disciple.display_name, "%s%s" % [SectMapPresentation.action_label(disciple.current_action), result_text], disciple)
        return
    var detail := Label.new()
    detail.text = operation_text
    detail.custom_minimum_size = Vector2(560, 0)
    detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail.add_theme_font_size_override("font_size", 13)
    detail.add_theme_color_override("font_color", INK)
    building_operation_live_content.add_child(detail)

func _field_worker_status(disciple: DiscipleState, field: BuildingState) -> String:
    for raw_plot in BuildingSystem.new().spirit_field_plots(state, field):
        if not (raw_plot is Dictionary):
            continue
        var plot: Dictionary = raw_plot
        if StringName(plot.get("assigned_worker_id", "")) != disciple.id:
            continue
        if StringName(plot.get("status", "")) != BuildingSystem.PLOT_GROWING:
            continue
        var crop_id := StringName(plot.get("crop_id", ""))
        var crop_name := spirit_crop_registry.display_name(crop_id)
        var quantity := maxi(0, int(plot.get("routine_yield", 0)))
        var remaining := maxi(0, int(plot.get("finish_tick", state.tick)) - state.tick)
        return "Chăm luống · %s ×%d · còn %d nhịp" % [crop_name, quantity, remaining]
    return SectMapPresentation.action_label(disciple.current_action)

func _add_live_worker_message(text: String) -> void:
    var label := Label.new()
    label.text = text
    label.custom_minimum_size = Vector2(560, 0)
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", 12)
    label.add_theme_color_override("font_color", INK)
    building_operation_live_content.add_child(label)

func _add_live_worker_card(display_name: String, status: String, disciple: DiscipleState = null) -> void:
    var card := PanelContainer.new()
    card.name = "LiveWorkerCard"
    card.custom_minimum_size = Vector2(560, 48)
    card.mouse_filter = Control.MOUSE_FILTER_PASS
    card.add_theme_stylebox_override("panel", _style(Color(0.86, 0.80, 0.65, 1.0), Color(0.52, 0.43, 0.27, 1.0), 1, 7))
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 8)
    row.mouse_filter = Control.MOUSE_FILTER_PASS
    var portrait_texture := _disciple_source_a_portrait_texture(disciple) if disciple != null else null
    if portrait_texture != null:
        var portrait := TextureRect.new()
        portrait.name = "WorkerPortrait"
        portrait.texture = portrait_texture
        portrait.custom_minimum_size = Vector2(34, 34)
        portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
        portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
        row.add_child(portrait)
    else:
        var icon := SECT_UI_ICON.new() as Control
        icon.set("kind", "worker")
        icon.set("tint", JADE_DARK)
        icon.custom_minimum_size = Vector2(28, 28)
        icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
        row.add_child(icon)
    var name_label := Label.new()
    name_label.text = display_name
    name_label.custom_minimum_size = Vector2(122, 30)
    name_label.add_theme_font_size_override("font_size", 13)
    name_label.add_theme_color_override("font_color", INK)
    name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    row.add_child(name_label)
    var status_label := Label.new()
    status_label.text = status
    status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.add_theme_font_size_override("font_size", 12)
    status_label.add_theme_color_override("font_color", INK)
    status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    row.add_child(status_label)
    card.add_child(row)
    building_operation_live_content.add_child(card)

func _active_resource_worksite_status(destination: StringName) -> String:
    var profession_id: StringName
    var group_id: StringName
    var building_type: StringName
    match destination:
        SectMapPresentation.DEST_MINE:
            profession_id = WorkforceSystem.PROF_MINING
            group_id = &"mining_crew"
            building_type = BuildingSystem.TYPE_MINE
        SectMapPresentation.DEST_LINH_FOREST:
            profession_id = WorkforceSystem.PROF_FORESTRY
            group_id = &"forestry_crew"
            building_type = BuildingSystem.TYPE_LINH_FOREST
        _:
            return ""
    var building := BuildingSystem.new().primary_building(state,building_type)
    if building == null:
        return ""
    var active_ids := BuildingSystem.new().active_worker_ids(state,building)
    var lines: Array[String] = []
    for disciple_value in _disciples_in_work_group(group_id):
        var disciple: DiscipleState = disciple_value
        if not active_ids.has(disciple.id):
            continue
        var cycle := disciple.work_cycle_state
        var cycle_profession := StringName(cycle.get("profession_id",cycle.get("profession","")))
        var timer := BuildingSystem.new().active_resource_timer_for_worker(state,disciple.id)
        var timer_matches := not timer.is_empty() and StringName(timer.get("profession_id","")) == profession_id and StringName(timer.get("building_id","")) == building.id
        if not cycle.is_empty() and (cycle_profession != profession_id or StringName(cycle.get("building_id", "")) != building.id) and not timer_matches:
            continue
        if cycle.is_empty() and not timer_matches and disciple.worksite_building_id != building.id:
            continue
        var status := _mining_member_status(disciple,true,building) if profession_id == WorkforceSystem.PROF_MINING else _resource_job_member_status(disciple,profession_id,true,building)
        lines.append("• %s · %s" % [disciple.display_name,status])
    return "\n".join(lines)

func _build_worksite_upgrade_control(building: BuildingState) -> void:
    if building == null:
        return
    var system := BuildingSystem.new()
    var definition := system.definition_for(building)
    var display := _sect_production_type_name(building.building_type) if _map_worksite_is_supported(building) else _building_name(building.id)
    _add_management_section_label("NÂNG CẤP %s" % display.to_upper())
    if not bool(definition.get("upgrade_enabled", true)):
        var pending := Label.new()
        pending.name = "UpgradeUnavailable_%s" % str(building.id)
        pending.text = "%s hiện chưa có quy tắc nâng cấp trong BuildingSystem." % display
        pending.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        pending.add_theme_font_size_override("font_size", 11)
        pending.add_theme_color_override("font_color", INK)
        building_management_container.add_child(pending)
        return
    var info := Label.new()
    info.name = "UpgradeStatus_%s" % str(building.id)
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.add_theme_font_size_override("font_size", 10)
    info.add_theme_color_override("font_color", INK)
    building_management_container.add_child(info)
    var button := Button.new()
    button.name = "Upgrade_%s" % str(building.id)
    button.custom_minimum_size = Vector2(384, 36)
    button.add_theme_font_size_override("font_size", 11)
    building_management_container.add_child(button)
    if building.is_upgrading():
        info.text = "Lv%d → Lv%d · %.0f/%.0f điểm công việc · %s." % [
            building.level, building.upgrade_target_level, building.upgrade_progress,
            building.upgrade_required_work, _upgrade_eta_text(building)
        ]
        button.text = "Đang nâng cấp…"
        button.disabled = true
        return
    if building.level >= building.max_level:
        info.text = "%s đã đạt cấp tối đa Lv%d." % [display, building.level]
        button.text = "Đã tối đa"
        button.disabled = true
        return
    var cost := system.sx_v55_upgrade_cost(state,building)
    var check := system.can_start_upgrade(state, building.id)
    info.text = "Lv%d→%d · Gỗ %d/%d · Thiết %d/%d · Linh Thạch %d/%d · %.0f phút mô phỏng." % [
        building.level, building.level + 1,
        _warehouse_available(StringName(BuildingSystem.MATERIAL_WOOD)), int(cost.get(BuildingSystem.MATERIAL_WOOD, 0)),
        _warehouse_available(StringName(BuildingSystem.MATERIAL_ORE)), int(cost.get(BuildingSystem.MATERIAL_ORE, 0)),
        state.sect.spirit_stones, int(cost.get("spirit_stones", 0)),
        system.upgrade_required_work(building)
    ]
    var extra_items: PackedStringArray = []
    for raw_id in cost.keys():
        var extra_id := str(raw_id)
        if extra_id in [BuildingSystem.MATERIAL_WOOD,BuildingSystem.MATERIAL_ORE,"spirit_stones"]:
            continue
        extra_items.append("%s %d/%d" % [
            ResourceRegistry.new().display_name(StringName(extra_id)),
            _warehouse_available(StringName(extra_id)), int(cost[raw_id])
        ])
    if not extra_items.is_empty():
        info.text += "\nMốc cần thêm: " + " · ".join(extra_items)
    info.tooltip_text = "Vật liệu tiêu thụ một lần lúc bắt đầu; chờ đủ phút mô phỏng mới lên cấp."
    if building.building_type in [BuildingSystem.TYPE_MINE,BuildingSystem.TYPE_LINH_FOREST]:
        var next_building := BuildingState.from_dict(building.to_dict()) as BuildingState
        next_building.level = mini(building.level+1, building.max_level)
        info.tooltip_text += "\nThời gian pha khai thác: %.2f → %.2f phút quy đổi; timer thật làm tròn theo phút. Chỗ việc: %d → %d. Sản lượng cơ bản: ×%d → ×%d." % [
            system.resource_job_work_duration(building),
            system.resource_job_work_duration(next_building),
            system.worker_slots(building),system.worker_slots(next_building),
            system.resource_job_batch_units(building),system.resource_job_batch_units(next_building)
        ]
    elif building.building_type == BuildingSystem.TYPE_SPIRIT_FIELD:
        info.tooltip_text += "\nHệ số tốc độ: ×%.3f → ×%.3f; sản lượng và số ô tăng theo công thức/mốc, không cam kết thêm nguyên đơn vị mỗi cấp." % [
            system.spirit_field_speed_factor(building),
            system.spirit_field_speed_factor(BuildingState.from_dict({
                "id":str(building.id),"building_type":str(building.building_type),
                "level":mini(building.level+1,building.max_level)
            }))
        ]
    button.text = "Nâng cấp %s lên Lv%d" % [display, building.level + 1]
    button.disabled = not bool(check.get("ok", false))
    if button.disabled:
        button.tooltip_text = _building_upgrade_reason(check)
    button.pressed.connect(Callable(self, "_start_building_upgrade_from_ui").bind(building.id))

func _upgrade_eta_text(building: BuildingState, before_start: bool = false) -> String:
    if building == null:
        return "chưa xác định được nhịp mô phỏng"
    var system := BuildingSystem.new()
    var required := maxf(0.0, system.upgrade_required_work(building))
    var completed := maxf(0.0, building.upgrade_progress)
    var remaining_ticks := maxi(0, ceili(required - completed))
    if before_start:
        return "%d nhịp mô phỏng dự kiến, mỗi nhịp +1 điểm" % remaining_ticks
    return "còn %d nhịp mô phỏng, mỗi nhịp +1 điểm" % remaining_ticks

func _rebuild_building_management_controls() -> void:
    if building_management_container == null:
        return
    for child in building_management_container.get_children():
        building_management_container.remove_child(child)
        child.queue_free()

    if selected_building in [SectMapPresentation.DEST_MINE,SectMapPresentation.DEST_LINH_FOREST,
            SectMapPresentation.DEST_SPIRIT_FIELD,SectMapPresentation.DEST_ALCHEMY_HALL]:
        _build_v57_paid_producer_control()
    match selected_building:
        SectMapPresentation.DEST_MAIN_HALL:
            _build_main_hall_policy_controls()
        SectMapPresentation.DEST_WAREHOUSE:
            _build_economy_a_market_controls()
            _build_equipment_inventory_controls()
        SectMapPresentation.DEST_MINE:
            # Upgrades stay visible without scrolling through every disciple.
            _build_mine_upgrade_control()
            _build_work_management(WorkforceSystem.PROF_MINING, &"mining_crew", "Đội Khai Khoáng", "Khai khoáng")
        SectMapPresentation.DEST_LINH_FOREST:
            var forest := _selected_operation_building()
            if forest == null or forest.building_type != BuildingSystem.TYPE_LINH_FOREST:
                forest = BuildingSystem.new().primary_building(state, BuildingSystem.TYPE_LINH_FOREST)
            if forest != null:
                _build_worksite_upgrade_control(forest)
            _build_work_management(WorkforceSystem.PROF_FORESTRY, &"forestry_crew", "Đội Lâm Nghiệp", "Thu hoạch")
        SectMapPresentation.DEST_ALCHEMY_HALL:
            _build_alchemy_management()
        SectMapPresentation.DEST_SPIRIT_FIELD:
            _build_spirit_field_management()
        SectMapPresentation.DEST_FORGE:
            _build_work_management(WorkforceSystem.PROF_FORGING, &"forge_hall", "Luyện Khí Đường", "Luyện khí")
            _build_forge_craft_controls()
        SectMapPresentation.DEST_CULTIVATION:
            _build_direct_order_management(WorkforceSystem.COMMAND_CULTIVATE, "", "Gọi tu luyện", false)
        SectMapPresentation.DEST_BODY_TRAINING:
            _build_body_training_management()
        SectMapPresentation.DEST_RESIDENCE:
            _build_direct_order_management(WorkforceSystem.COMMAND_REST, "", "Gọi nghỉ", false)
            _build_lodging_expansion_control()
        SectMapPresentation.DEST_MEDICINE:
            _build_needs_priority_controls("ƯU TIÊN HẬU CẦN")
            _build_healing_pill_controls()
        SectMapPresentation.DEST_GUIDANCE:
            _build_guidance_recruitment_controls()
        SectMapPresentation.DEST_GATE:
            _build_direct_order_management(WorkforceSystem.COMMAND_RETURN_SECT, "", "Triệu hồi", true)
        _:
            pass

func _build_v57_paid_producer_control() -> void:
    var kind: StringName = &""
    match selected_building:
        SectMapPresentation.DEST_MINE: kind = BuildingSystem.TYPE_MINE
        SectMapPresentation.DEST_LINH_FOREST: kind = BuildingSystem.TYPE_LINH_FOREST
        SectMapPresentation.DEST_SPIRIT_FIELD: kind = BuildingSystem.TYPE_SPIRIT_FIELD
        SectMapPresentation.DEST_ALCHEMY_HALL: kind = BuildingSystem.TYPE_ALCHEMY_HALL
    if kind == &"":
        return
    var system := BuildingSystem.new()
    var check := system.preview_production_annex(state,kind)
    var button := Button.new()
    button.name = "V57BuildProducer_"+str(kind)
    var existing := 0
    for candidate in state.buildings.values():
        if candidate is BuildingState and candidate.building_type == kind:
            existing += 1
    button.text = "+ Xây thêm "+_building_name(selected_building)+" (%d đang có)" % existing
    button.custom_minimum_size = Vector2(384,36)
    button.disabled = not bool(check.get("ok",false))
    var cost: Dictionary = check.get("cost",{})
    button.tooltip_text = (
        "Trừ thật: %d Linh Mộc + %d Thanh Thiết + %d Linh Thạch. Công trình tồn tại qua Save/Load." % [
            int(cost.get("linh_moc",0)),int(cost.get("thanh_thiet",0)),int(cost.get("spirit_stones",0))
        ]
        if bool(check.get("ok",false)) else "Chưa xây được: "+str(check.get("reason",""))
    )
    button.pressed.connect(Callable(self,"_v57_build_producer_from_ui").bind(kind))
    building_management_container.add_child(button)

func _v57_build_producer_from_ui(kind: StringName) -> void:
    var request_id := "ui:v57:annex:%s:%d:%d" % [
        str(kind),state.tick,state.building_event_count+1
    ]
    var result := BuildingSystem.new().build_paid_production_annex(state,kind,request_id)
    if bool(result.get("ok",false)):
        building_management_feedback = "Đã xây công trình %s; vật liệu và Linh Thạch đã trừ thật." % str(result.get("building_id",""))
        _autosave_runtime()
        _refresh_all()
    else:
        building_management_feedback = "Không xây được: "+str(result.get("reason",""))
    _refresh_building_operation_content()

func _build_main_hall_policy_controls() -> void:
    _add_management_section_label("ĐẠI ĐIỆN · QUẢN TRỊ")
    var hall_button := Button.new()
    hall_button.name = "OpenDaiDienScreenV1"
    hall_button.text = "MỞ ĐẠI ĐIỆN · CHƯỞNG MÔN / TRƯỞNG LÃO"
    hall_button.custom_minimum_size = Vector2(384, 42)
    hall_button.pressed.connect(_open_dai_dien_screen_v1)
    building_management_container.add_child(hall_button)
    _build_economy_a_hall_controls()
    _add_management_section_label("CHÍNH SÁCH LAO ĐỘNG")
    _add_policy_button_row([
        {"label":"Cân bằng", "value":WorkforceSystem.POLICY_BALANCED},
        {"label":"Sản xuất", "value":WorkforceSystem.POLICY_PRODUCTION},
        {"label":"Tu luyện", "value":WorkforceSystem.POLICY_CULTIVATION}
    ], state.sect.work_policy, "_set_work_policy_from_building")

    _add_management_section_label("ƯU TIÊN HẬU CẦN")
    _add_policy_button_row([
        {"label":"Cân bằng", "value":NeedsSystem.PRIORITY_BALANCED},
        {"label":"Thuốc", "value":NeedsSystem.PRIORITY_MEDICINE},
        {"label":"Vật tư", "value":NeedsSystem.PRIORITY_SUPPLIES}
    ], state.sect.needs_priority, "_set_needs_priority_from_building")

    _add_management_section_label("CHÍNH SÁCH TRANG BỊ")
    _add_policy_button_row([
        {"label":"Cân bằng", "value":EquipmentSystem.POLICY_BALANCED},
        {"label":"Chiến đấu", "value":EquipmentSystem.POLICY_COMBAT},
        {"label":"Tiết kiệm", "value":EquipmentSystem.POLICY_FRUGAL}
    ], state.sect.equipment_policy, "_set_equipment_policy_from_building")

func _open_dai_dien_screen_v1() -> void:
    if state == null or get_node_or_null("DaiDienScreenV1") != null:
        return
    var screen := DaiDienScreenV1.new()
    screen.name = "DaiDienScreenV1"
    screen.attach_state(state)
    screen.state_changed.connect(_on_dai_dien_state_changed)
    screen.z_index = 120
    add_child(screen)
    screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _attach_tri_b1_screen(screen, "hall")

func _attach_tri_b1_screen(host: Control, mode: String) -> void:
    if host.has_method("_set_b1_surface_active"):
        host.call("_set_b1_surface_active",true)
    var adapter: Control = TRI_B1_LIVE_ADAPTER.new()
    adapter.call("configure", host, state, recruitment_system, mode)
    host.add_child(adapter)
    adapter.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _open_dai_dien_housing_v1() -> void:
    _open_dai_dien_screen_v1()
    var hall_view := get_node_or_null("DaiDienScreenV1") as DaiDienScreenV1
    if hall_view != null:
        hall_view._tab(5)
        var b1 = hall_view.get_node_or_null("TriFacilityB1LiveAdapterV1")
        if b1 != null:
            b1.call("show_mode", "residence")

func _start_b1_residence_build(site_id: String = "") -> void:
    var selected_site := SectResidenceSiteV1.UNSELECTED
    var parts := site_id.split(":")
    if parts.size() == 3 and parts[0] == "plot":
        selected_site = Vector2i(int(parts[1]),int(parts[2]))
        if not bool(SectResidenceSystemV1.can_construct(state,selected_site).get("ok",false)):
            selected_site = SectResidenceSiteV1.UNSELECTED
    var hall_screen := get_node_or_null("DaiDienScreenV1")
    if hall_screen != null:
        hall_screen.queue_free()
    _enter_build_mode()
    _begin_residence_construction()
    if selected_site != SectResidenceSiteV1.UNSELECTED:
        _select_build_mode_site(selected_site)

func _start_b1_residence_plan() -> void:
    var hall_screen := get_node_or_null("DaiDienScreenV1")
    if hall_screen != null:
        hall_screen.queue_free()
    _enter_build_mode()
    _begin_residence_construction()

func _on_dai_dien_state_changed() -> void:
    # _refresh_all() already refreshes the 192x192 map once; avoid double scans.
    _refresh_all()
    if selected_building == SectMapPresentation.DEST_MAIN_HALL:
        _refresh_building_management_controls_only()

# ECONOMY-A player actions are actual simulation transactions; no fake income.
func _build_economy_a_hall_controls() -> void:
    _add_management_section_label("KINH TẾ V1 · LINH THẠCH")
    if not state.sect.economy_a_enabled:
        var enable := Button.new()
        enable.name = "EconomyA_Enable"
        enable.text = "Bật kinh tế V1 cho lượt chơi này"
        enable.custom_minimum_size = Vector2(384,36)
        enable.pressed.connect(_economy_a_enable_from_ui)
        building_management_container.add_child(enable)
        return
    var policy: Dictionary = state.sect.economy_a_policy
    var summary := Label.new()
    summary.text = "Quỹ: %d · Lương/mẻ: %d · %s" % [
        state.sect.spirit_stones,int(policy.get("wage_per_batch",2)),
        ("Sản xuất 60/90/180 phút" if BuildingSystem.new().sx_v55_bulk_enabled(state)
        else "Timer gốc: %d phút" % int(policy.get("resource_duration_ticks",10)))
    ]
    summary.custom_minimum_size = Vector2(384,32)
    summary.add_theme_font_size_override("font_size",12)
    building_management_container.add_child(summary)
    var cashflow := EconomySystem.new().daily_market_cashflow(state)
    var sources := Label.new()
    sources.name = "EconomyA_RealIncome"
    sources.text = "Hôm nay: bán nguyên liệu +%d LT · mua vật tư -%d LT · trả lương -%d LT" % [
        int(cashflow.get("income",0)),int(cashflow.get("purchases",0)),int(cashflow.get("wages",0))
    ]
    sources.tooltip_text = "Số thật từ receipt của Phường Thị và lương. Không bao gồm tiêu Linh Thạch cho gieo trồng, nâng cấp, chiêu mộ/kỹ năng; quỹ thực ở trên là số dư chính xác. Tài nguyên phải sản xuất/kiếm thật rồi bán tại Kho."
    sources.custom_minimum_size = Vector2(384,42)
    sources.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    sources.add_theme_font_size_override("font_size",11)
    sources.add_theme_color_override("font_color",JADE_DARK)
    building_management_container.add_child(sources)
    # ECO-01: genuine Hall-owned rescue job, not a daily free-login claim.
    var vein := Eco01OriginVein.new()
    var vein_state := vein.snapshot(state)
    var vein_title := Label.new()
    vein_title.name = "ECO01OriginVeinStatus"
    if bool(vein_state.get("busy",false)):
        vein_title.text = "LINH MẠCH KHỞI NGUYÊN · +1.000 LT gộp\\nĐang khai thác · còn %d phút" % int(vein_state.get("remaining_ticks",0))
    elif bool(vein_state.get("ready",false)):
        vein_title.text = "LINH MẠCH KHỞI NGUYÊN · Miễn phí · 60 phút\\n+1.000 LT gộp / Tông Môn · 1 lần mỗi 1.440 phút"
    else:
        vein_title.text = "LINH MẠCH KHỞI NGUYÊN · Đã nhận\\nCòn %d phút tới lượt tiếp theo" % int(vein_state.get("remaining_ticks",0))
    vein_title.custom_minimum_size = Vector2(384,48)
    vein_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vein_title.add_theme_font_size_override("font_size",12)
    building_management_container.add_child(vein_title)
    if bool(vein_state.get("busy",false)):
        var cancel_vein := Button.new()
        cancel_vein.name = "ECO01OriginVeinCancel"
        cancel_vein.text = "Hủy khai thác · Không nhận LT"
        cancel_vein.custom_minimum_size = Vector2(384,34)
        cancel_vein.pressed.connect(Callable(self,"_eco01_cancel_from_ui").bind(
            StringName(str(vein_state.get("worker_id",""))),
            str(vein_state.get("job_id",""))))
        building_management_container.add_child(cancel_vein)
    elif bool(vein_state.get("ready",false)):
        var eligible := vein.eligible_workers(state)
        var choose := OptionButton.new()
        choose.name = "ECO01OriginVeinWorker"
        choose.custom_minimum_size = Vector2(384,34)
        var entry_index := 0
        for id in eligible:
            var actor: DiscipleState = state.disciples[id]
            choose.add_item(actor.display_name)
            choose.set_item_metadata(entry_index,str(id))
            entry_index += 1
        if eligible.is_empty():
            choose.add_item("Chưa có đệ tử rảnh tại Tông Môn")
            choose.disabled = true
        building_management_container.add_child(choose)
        var begin_vein := Button.new()
        begin_vein.name = "ECO01OriginVeinStart"
        begin_vein.text = "Khai thác Linh Mạch · Miễn phí"
        begin_vein.custom_minimum_size = Vector2(384,36)
        begin_vein.disabled = eligible.is_empty()
        begin_vein.tooltip_text = "Một đệ tử rảnh, mẻ 60 phút mô phỏng. Nhận 1.000 Linh Thạch gộp sau hoàn thành; lương được chuyển từ tiền thật. Không cần NPC, không nhân theo số đệ tử."
        begin_vein.pressed.connect(Callable(self,"_eco01_start_selected_from_ui").bind(choose))
        building_management_container.add_child(begin_vein)
    var bulk_ready := BuildingSystem.new().sx_v55_bulk_enabled(state)
    var bulk_button := Button.new()
    bulk_button.name = "SXV55_EnableBulk"
    bulk_button.text = "Sản xuất lớn: ĐÃ BẬT" if bulk_ready else "Bật sản xuất lớn · 60/90/180 phút"
    bulk_button.custom_minimum_size = Vector2(384,36)
    bulk_button.disabled = bulk_ready
    bulk_button.tooltip_text = "Áp dụng CHỈ cho mẻ mới: Mỏ 10.000/60p; Lâm 8.000/60p; Điền 2.500/60p, 2.000/90p, 1.000/180p. Chi phí nguyên liệu phổ thông Mộc/Thiết/Thanh Linh ×1.000; tiền và thuế W2/LT2/T2 chưa mở. Mẻ cũ không thay đổi."
    bulk_button.pressed.connect(_sx_v55_enable_bulk_from_ui)
    building_management_container.add_child(bulk_button)
    # Receipt-backed W2 debt. The label never fabricates a Stone balance.
    var arrears := EconomySystem.new().unpaid_work_wages(state)
    var unpaid := maxi(int(arrears.get("total",0)),0)
    var arrears_button := Button.new()
    arrears_button.name = "EconomyA_PayWageArrears"
    arrears_button.text = "Lương còn nợ: %d LT · Trả từ quỹ" % unpaid
    arrears_button.custom_minimum_size = Vector2(384,36)
    arrears_button.tooltip_text = "Chỉ chuyển Linh Thạch thật từ quỹ sang đệ tử theo chứng từ lương chưa trả. Lưu và tải lại không thể trả trùng."
    arrears_button.disabled = unpaid <= 0 or state.sect.spirit_stones <= maxi(0,int(policy.get("sect_pay_reserve",0)))
    arrears_button.pressed.connect(_economy_a_pay_arrears_from_ui)
    building_management_container.add_child(arrears_button)
    var heal_toggle := Button.new()
    heal_toggle.name = "EconomyA_AutoHP"
    heal_toggle.text = "Tự chữa HP: BẬT" if bool(policy.get("auto_hp_service",false)) else "Tự chữa HP: TẮT"
    heal_toggle.custom_minimum_size = Vector2(384,36)
    heal_toggle.pressed.connect(_economy_a_toggle_heal_from_ui)
    building_management_container.add_child(heal_toggle)
    var spending_limit := Button.new()
    spending_limit.name = "EconomyA_AutoSpendLimit"
    spending_limit.text = "Hạn mức tự chữa: %d LT/đệ tử/ngày" % int(policy.get("auto_hp_daily_stone_limit",6))
    spending_limit.custom_minimum_size = Vector2(384,36)
    spending_limit.pressed.connect(_economy_a_cycle_spend_limit_from_ui)
    building_management_container.add_child(spending_limit)

func _eco01_start_selected_from_ui(choose: OptionButton) -> void:
    if choose == null or choose.selected < 0 or choose.disabled:
        return
    var worker := StringName(str(choose.get_item_metadata(choose.selected)))
    var result := Eco01OriginVein.new().start(state,worker)
    if bool(result.get("ok",false)):
        building_management_feedback = "Linh Mạch đã nhận việc thật · hoàn thành sau 60 phút mô phỏng."
        _autosave_runtime()
    else:
        building_management_feedback = "Chưa thể khai thác Linh Mạch: " + str(result.get("reason","không hợp lệ"))
    _refresh_building_operation_content()

func _eco01_cancel_from_ui(worker_id: StringName, job_id: String) -> void:
    var result := Eco01OriginVein.new().cancel(state,worker_id,job_id)
    if bool(result.get("ok",false)):
        building_management_feedback = "Đã hủy mẻ Linh Mạch chưa hoàn thành · không sinh Linh Thạch."
        _autosave_runtime()
    else:
        building_management_feedback = "Không thể hủy Linh Mạch: " + str(result.get("reason","không hợp lệ"))
    _refresh_building_operation_content()

func _sx_v55_enable_bulk_from_ui() -> void:
    var result := BuildingSystem.new().sx_v55_enable_bulk(state)
    if bool(result.get("ok",false)):
        building_management_feedback = "Đã bật nguồn thật 60/90/180 phút cho mẻ MỚI; mẻ cũ giữ nguyên. Công thức phổ thông ×1.000."
        _autosave_runtime()
        _refresh_all()
    else:
        building_management_feedback = "Chưa thể mở SX-V55: " + str(result.get("reason","không đủ nguồn"))
    _refresh_building_operation_content()

func _economy_a_enable_from_ui() -> void:
    var result := EconomySystem.new().enable_v1(state)
    building_management_feedback = "Đã bật Kinh tế V1; các mẻ mới của đệ tử V2 dùng timer." if bool(result.get("ok",false)) else str(result.get("reason","Không thể bật kinh tế."))
    _refresh_building_operation_content()

func _economy_a_pay_arrears_from_ui() -> void:
    var request_id := "ui:w2:arrears:%d:%d" % [state.tick,state.sect.economy_a_event_count+1]
    var result := EconomySystem.new().pay_work_wage_arrears(state,request_id)
    if bool(result.get("ok",false)):
        var receipt: Dictionary = result.get("receipt",{})
        building_management_feedback = "Đã trả %d LT nợ lương từ quỹ thật." % int(receipt.get("paid",0))
        _autosave_runtime()
        _refresh_all()
    else:
        building_management_feedback = "Chưa thể trả nợ lương: " + str(result.get("reason","không đủ quỹ"))
    _refresh_building_operation_content()

func _economy_a_toggle_heal_from_ui() -> void:
    var economy := EconomySystem.new()
    var old := bool(state.sect.economy_a_policy.get("auto_hp_service",false))
    var result := economy.configure_v1(state,"auto_hp_service",not old)
    building_management_feedback = "Đã đổi chính sách chi tiêu cá nhân." if bool(result.get("ok",false)) else "Chính sách bị từ chối."
    _refresh_building_operation_content()

func _economy_a_cycle_spend_limit_from_ui() -> void:
    var choices := [0,3,6,12]
    var current := int(state.sect.economy_a_policy.get("auto_hp_daily_stone_limit",6))
    var index := choices.find(current)
    var next_value := int(choices[(index+1) % choices.size()])
    var result := EconomySystem.new().configure_v1(state,"auto_hp_daily_stone_limit",next_value)
    building_management_feedback = "Đã đổi hạn mức tự chữa." if bool(result.get("ok",false)) else "Không đổi được hạn mức."
    _refresh_building_operation_content()

func _build_economy_a_market_controls() -> void:
    if not state.sect.economy_a_enabled:
        _add_management_section_label("PHƯỜNG THỊ · CHƯA KÍCH HOẠT")
        var enable := Button.new()
        enable.name = "EconomyA_EnableFromWarehouse"
        enable.text = "Mở Phường Thị thật · Bán nguyên liệu lấy Linh Thạch"
        enable.tooltip_text = "Áp dụng cho save cũ chưa tham gia kinh tế nguyên liệu; không cấp tài nguyên miễn phí."
        enable.custom_minimum_size = Vector2(384,38)
        enable.pressed.connect(_economy_a_enable_from_ui)
        building_management_container.add_child(enable)
        return
    var economy := EconomySystem.new()
    economy.sync_market_day(state)
    _add_management_section_label("PHƯỜNG THỊ · GIAO DỊCH NGUYÊN LIỆU")
    var quota := Label.new()
    quota.name = "ECO02MarketQuota"
    quota.text = "Tông Môn %d LT · NPC nhận %d · bán tối đa %d · mua tối đa %d đơn vị hôm nay." % [
        state.sect.spirit_stones,int(state.sect.economy_a_policy.get("market_daily_units",20)),
        economy.market_remaining(state),economy.market_buy_remaining(state)
    ]
    if int(state.sect.economy_a_policy.get("market_daily_units",20)) == 0:
        quota.text = "NPC không giao dịch hôm nay · không có doanh thu bán hàng."
    quota.tooltip_text = "Chỉ giao dịch nguyên liệu thực trong Kho; nhu cầu NPC và giới hạn bán/mua tính theo ngày mô phỏng (1.440 phút). Hạn mức NPC = 0 thì không thể mua hoặc bán."
    quota.custom_minimum_size = Vector2(384,38)
    quota.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    building_management_container.add_child(quota)
    var pending_sale: Dictionary = get_meta("eco02_pending_sale",{})
    for raw_id in EconomySystem.V2_MARKET_CATALOG:
        var resource_id := StringName(raw_id)
        var price := economy.market_sell_price(resource_id)
        if price > 0:
            var quote := economy.sell_quote_v1(state,resource_id,1)
            var sellable := int(quote.get("max_quantity",0))
            var reserve_min := int(quote.get("reserve_min",0))
            var locked := bool(quote.get("locked",false))
            var stock_label := Label.new()
            stock_label.name = "ECO02Stock_%s" % raw_id
            stock_label.text = "%s · Kho %d · Dự trữ %d%s · Bán được %d · %d LT/đv" % [
                ResourceRegistry.new().display_name(resource_id),int(quote.get("stock",0)),
                reserve_min," · KHÓA" if locked else "",sellable,price
            ]
            stock_label.custom_minimum_size = Vector2(384,26)
            stock_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            stock_label.add_theme_font_size_override("font_size",11)
            building_management_container.add_child(stock_label)
            var same_pending := str(pending_sale.get("resource_id","")) == raw_id \
                and int(pending_sale.get("quantity",0)) == sellable \
                and int(pending_sale.get("unit_price",0)) == price and sellable > 0
            var row := Button.new()
            row.name = ("EconomyA_Sell_%s" if same_pending else "EconomyA_PreviewSell_%s") % raw_id
            row.text = ("Xác nhận bán" if same_pending else "Kiểm tra bán") + " %s ×%d · +%d LT" % [
                ResourceRegistry.new().display_name(resource_id),sellable,price*sellable
            ]
            row.custom_minimum_size = Vector2(384,36)
            row.disabled = sellable <= 0
            row.tooltip_text = "Bước 1 kiểm tra giá/tồn kho; bước 2 mới xác nhận trừ Kho thật và ghi biên nhận. Không bán hàng đã khóa hoặc dự trữ."
            if same_pending:
                row.pressed.connect(Callable(self,"_economy_a_sell_from_ui").bind(resource_id,sellable))
            else:
                row.pressed.connect(Callable(self,"_eco02_prepare_sell_from_ui").bind(resource_id,sellable))
            building_management_container.add_child(row)
            if same_pending:
                var cancel_sale := Button.new()
                cancel_sale.name = "ECO02CancelSell"
                cancel_sale.text = "Hủy bán · Kho và Linh Thạch không đổi"
                cancel_sale.custom_minimum_size = Vector2(384,28)
                cancel_sale.pressed.connect(_eco02_cancel_sell_from_ui)
                building_management_container.add_child(cancel_sale)
        var merchant_stock := int(state.sect.economy_a_market_stock.get(raw_id,0))
        var buy_price := economy.market_purchase_price(state,resource_id)
        var buyable := mini(merchant_stock,mini(int(state.sect.economy_a_policy.get("market_max_per_buy",5)),economy.market_buy_remaining(state)))
        buyable = mini(buyable,int(state.sect.spirit_stones / maxi(buy_price,1)))
        var buy_row := Button.new()
        buy_row.name = "EconomyA_Buy_%s" % raw_id
        buy_row.text = "Mua %s ×%d · -%d LT · Chợ còn %d" % [ResourceRegistry.new().display_name(resource_id),buyable,buy_price*buyable,merchant_stock]
        if raw_id == "tam_mach_ban":
            buy_row.tooltip_text = "Tầm Mạch Bàn dùng để mở mốc Mỏ Lv10/20/30/50/75/100; NPC 1 chiếc/ngày mô phỏng, phải trả Linh Thạch thực."
        elif raw_id == "linh_tuyen_chi_tam_manh":
            buy_row.tooltip_text = "Mua mảnh Linh Tuyền Chi Tâm thật để ghép Chi Tâm nâng cấp Linh Điền. Đủ 100 mảnh trong Linh Kho sẽ tự chuyển thành 1 Chi Tâm. Mảnh cũng rơi hiếm từ thu hoạch thật."
        buy_row.custom_minimum_size = Vector2(384,36)
        buy_row.disabled = buyable <= 0 or buy_price <= 0 or state.sect.spirit_stones < buy_price*buyable
        buy_row.pressed.connect(Callable(self,"_economy_a_buy_from_ui").bind(resource_id,buyable))
        building_management_container.add_child(buy_row)

func _build_equipment_inventory_controls() -> void:
    if not state.sect.equipment_enabled:
        return
    _add_management_section_label("TRANG BỊ · KHO TÔNG MÔN / PHƯỜNG THỊ")
    var item_ids: Array[StringName] = []
    for raw_id in state.sect.equipment_items.keys():
        var item: Dictionary = state.sect.equipment_items[str(raw_id)]
        var location := StringName(item.get("location",""))
        if location in [EquipmentSystem.LOCATION_STORAGE,EquipmentSystem.LOCATION_SHOP]:
            item_ids.append(StringName(raw_id))
    item_ids.sort()
    if item_ids.is_empty():
        var empty := Label.new()
        empty.text = "Kho trang bị hiện trống. Luyện Khí sẽ đưa thành phẩm mới vào đây."
        empty.custom_minimum_size = Vector2(384,28)
        empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        building_management_container.add_child(empty)
        return

    var picker := OptionButton.new()
    picker.name = "EquipmentInventoryItemPicker"
    picker.custom_minimum_size = Vector2(384,34)
    for item_id in item_ids:
        var item: Dictionary = state.sect.equipment_items[str(item_id)]
        var location := StringName(item.get("location",""))
        picker.add_item("%s · %s · %s" % [
            str(item.get("name",item_id)),
            equipment_system.quality_name(StringName(item.get("quality","pham"))),
            "Kho Tông Môn" if location == EquipmentSystem.LOCATION_STORAGE else "Phường Thị"
        ])
        picker.set_item_metadata(picker.item_count-1,str(item_id))
    picker.select(0)
    building_management_container.add_child(picker)

    var detail := Label.new()
    detail.name = "EquipmentInventoryItemDetail"
    detail.custom_minimum_size = Vector2(384,46)
    detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail.add_theme_font_size_override("font_size",11)
    detail.add_theme_color_override("font_color",INK)
    building_management_container.add_child(detail)

    var move := Button.new()
    move.name = "EquipmentInventoryMove"
    move.custom_minimum_size = Vector2(384,36)
    move.add_theme_font_size_override("font_size",12)
    move.add_theme_stylebox_override("normal",_style(JADE_DARK,PAPER_LIGHT,1,7))
    move.pressed.connect(Callable(self,"_move_equipment_inventory_item_from_ui").bind(picker))
    building_management_container.add_child(move)
    picker.item_selected.connect(Callable(self,"_update_equipment_inventory_selection").bind(picker,detail,move))
    _update_equipment_inventory_selection(picker.selected,picker,detail,move)


func _update_equipment_inventory_selection(index: int, picker: OptionButton, detail: Label, move: Button) -> void:
    if index < 0 or index >= picker.item_count:
        detail.text = "Chọn vật phẩm trong Kho hoặc Phường Thị."
        move.text = "Chuyển vật phẩm"
        move.disabled = true
        return
    var item_id := StringName(str(picker.get_item_metadata(index)))
    var item: Dictionary = state.sect.equipment_items.get(str(item_id),{})
    if item.is_empty():
        detail.text = "Vật phẩm không còn trong Kho."
        move.text = "Chuyển vật phẩm"
        move.disabled = true
        return
    var location := StringName(item.get("location",""))
    var price := maxi(int(item.get("price",0)),0)
    var effect := _disciple_equipment_effect_text(item).trim_prefix("Thuộc tính vật phẩm: ")
    detail.text = "%s · %s · Giá niêm yết %d Linh Thạch\n%s" % [
        str(item.get("name",item_id)),
        "Trong Kho Tông Môn" if location == EquipmentSystem.LOCATION_STORAGE else "Đang niêm yết ở Phường Thị",
        price,effect
    ]
    var writable := runtime_session != null and runtime_session.owner != null and not runtime_session.owner.runtime_write_blocked
    if location == EquipmentSystem.LOCATION_STORAGE:
        move.text = "Đưa lên Phường Thị"
        move.tooltip_text = "Niêm yết vật phẩm hiện có; không tạo item hoặc thu tiền. Người mặc từ Phường Thị phải trả giá bằng ví."
    elif location == EquipmentSystem.LOCATION_SHOP:
        move.text = "Thu hồi hàng chưa bán về Kho"
        move.tooltip_text = "Chỉ thu hồi vật phẩm chưa được mua/mặc; không hoàn tiền vì chưa có giao dịch."
    else:
        move.text = "Vật phẩm đang được sử dụng"
        move.tooltip_text = "Chỉ vật phẩm chưa mặc mới được chuyển giữa Kho và Phường Thị."
    move.disabled = not writable or location not in [EquipmentSystem.LOCATION_STORAGE,EquipmentSystem.LOCATION_SHOP]
    if not writable:
        detail.text += "\nRuntime lưu đang bận; chuyển kho tạm khóa."


func _move_equipment_inventory_item_from_ui(picker: OptionButton) -> void:
    if picker == null or not is_instance_valid(picker) or bool(picker.get_meta("equipment_move_pending",false)):
        return
    picker.set_meta("equipment_move_pending",true)
    if runtime_session == null or runtime_session.owner == null or runtime_session.owner.runtime_write_blocked:
        building_management_feedback = "Runtime lưu đang bận; vật phẩm chưa được chuyển."
        _refresh_building_operation_content()
        return
    if picker.selected < 0 or picker.selected >= picker.item_count:
        building_management_feedback = "Hãy chọn vật phẩm trong Kho hoặc Phường Thị."
        _refresh_building_operation_content()
        return
    var item_id := StringName(str(picker.get_item_metadata(picker.selected)))
    var item: Dictionary = state.sect.equipment_items.get(str(item_id),{})
    var location := StringName(item.get("location",""))
    var moved := false
    if location == EquipmentSystem.LOCATION_STORAGE:
        moved = equipment_system.move_to_shop(state,item_id)
    elif location == EquipmentSystem.LOCATION_SHOP:
        moved = equipment_system.move_to_storage(state,item_id)
    if not moved:
        building_management_feedback = "Không chuyển được vật phẩm; chỉ hàng chưa mặc mới đổi được vị trí."
        _refresh_building_operation_content()
        return
    var saved: Dictionary = runtime_session.save()
    var updated: Dictionary = state.sect.equipment_items.get(str(item_id),{})
    var new_location := StringName(updated.get("location",""))
    building_management_feedback = (
        "Đã đưa %s lên Phường Thị · giá %d Linh Thạch. Chưa phát sinh giao dịch tiền."
        % [str(updated.get("name",item_id)),int(updated.get("price",0))]
        if new_location == EquipmentSystem.LOCATION_SHOP
        else "Đã thu hồi %s chưa bán về Kho Tông Môn." % str(updated.get("name",item_id))
    )
    if not bool(saved.get("ok",false)):
        building_management_feedback += " Cảnh báo: SaveService chưa xác nhận lưu."
    _refresh_building_operation_content()


func _economy_a_buy_from_ui(resource_id: StringName, qty: int) -> void:
    var request_id := "panel-buy:%s:%d" % [str(resource_id),state.sect.economy_a_event_count+1]
    var result := EconomySystem.new().buy_from_npc_v1(state,resource_id,qty,request_id)
    var receipt: Dictionary = result.get("receipt",{})
    building_management_feedback = (
        "Đã mua %d sản phẩm; quỹ -%d Linh Thạch." % [qty,int(receipt.get("cost",0))]
        if bool(result.get("ok",false)) and not bool(result.get("already_settled",false))
        else ("Lệnh mua đã xử lý trước đó." if bool(result.get("already_settled",false)) else "Không mua được: %s" % str(result.get("reason","unknown")))
    )
    _refresh_building_operation_content()

func _eco02_prepare_sell_from_ui(resource_id: StringName, qty: int) -> void:
    var quote := EconomySystem.new().sell_quote_v1(state,resource_id,qty)
    if not bool(quote.get("ok",false)):
        building_management_feedback = "Chưa thể bán: %s" % str(quote.get("reason","invalid_sale"))
        if has_meta("eco02_pending_sale"):
            remove_meta("eco02_pending_sale")
    else:
        set_meta("eco02_pending_sale",{
            "resource_id":str(resource_id),"quantity":qty,"unit_price":int(quote.get("unit_price",0))
        })
        building_management_feedback = "Kiểm tra: Kho %d · giữ lại %d · dự bán %d × %d = %d LT. Bấm Xác nhận để hoàn tất." % [
            int(quote.get("stock",0)),int(quote.get("reserve_min",0)),
            qty,int(quote.get("unit_price",0)),int(quote.get("earned",0))
        ]
    _refresh_building_operation_content()

func _eco02_cancel_sell_from_ui() -> void:
    if has_meta("eco02_pending_sale"):
        remove_meta("eco02_pending_sale")
    building_management_feedback = "Đã hủy bán, Kho và Linh Thạch không đổi."
    _refresh_building_operation_content()

func _economy_a_sell_from_ui(resource_id: StringName, qty: int) -> void:
    var pending: Dictionary = get_meta("eco02_pending_sale",{})
    if has_meta("eco02_pending_sale"):
        remove_meta("eco02_pending_sale")
    var quote := EconomySystem.new().sell_quote_v1(state,resource_id,qty)
    if str(pending.get("resource_id","")) != str(resource_id) \
            or int(pending.get("quantity",0)) != qty \
            or int(pending.get("unit_price",-1)) != int(quote.get("unit_price",0)) \
            or not bool(quote.get("ok",false)):
        building_management_feedback = "Báo giá hết hiệu lực hoặc Kho/NPC đã thay đổi, cần kiểm tra lại."
        _refresh_building_operation_content()
        return
    var request_id := "panel:%s:%d" % [str(resource_id),state.sect.economy_a_event_count+1]
    var result := EconomySystem.new().sell_to_npc_v1(state,resource_id,qty,request_id)
    var receipt: Dictionary = result.get("receipt",{})
    building_management_feedback = (
        "Phường Thị nhận %d sản phẩm; quỹ +%d Linh Thạch." % [qty,int(receipt.get("earned",0))]
        if bool(result.get("ok",false)) and not bool(result.get("already_settled",false))
        else ("Lệnh bán đã xử lý trước đó." if bool(result.get("already_settled",false)) else "Không bán được: %s" % str(result.get("reason","unknown")))
    )
    _refresh_building_operation_content()

func _build_needs_priority_controls(title: String) -> void:
    _add_management_section_label(title)
    _add_policy_button_row([
        {"label":"Cân bằng", "value":NeedsSystem.PRIORITY_BALANCED},
        {"label":"Ưu tiên thuốc", "value":NeedsSystem.PRIORITY_MEDICINE},
        {"label":"Ưu tiên vật tư", "value":NeedsSystem.PRIORITY_SUPPLIES}
    ], state.sect.needs_priority, "_set_needs_priority_from_building")

func _build_guidance_recruitment_controls() -> void:
    _add_management_section_label("CHIÊU MỘ · HỒ SƠ TAM CĂN / TỨ TÍNH")
    var entry := Button.new()
    entry.name = "OpenDanTienScreenV2"
    entry.text = "MỞ DẪN TIÊN ĐÀI · TUYỂN ĐỆ TỬ"
    entry.custom_minimum_size = Vector2(384, 42)
    entry.add_theme_stylebox_override("normal", _style(JADE_DARK, PAPER_LIGHT, 1, 8))
    entry.pressed.connect(_open_dan_tien_screen_v2)
    building_management_container.add_child(entry)

    var queue_label := Label.new()
    queue_label.name = "DanTienQueueSummary"
    queue_label.text = "Ứng viên: %d/%d · Lệnh: %d · Đệ tử: %d/%d\nXem hồ sơ Tam Căn / Tứ Tính, Linh Căn, thiên hướng nghề và chân dung Source A phù hợp." % [
        state.recruitment_candidates.size(), RecruitmentSystem.C2_QUEUE_CAP,
        state.sect.disciple_recruitment_tokens,
        state.disciples.size(), state.sect.disciple_capacity
    ]
    queue_label.custom_minimum_size = Vector2(384, 50)
    queue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    queue_label.add_theme_font_size_override("font_size", 12)
    queue_label.add_theme_color_override("font_color", INK)
    building_management_container.add_child(queue_label)
    _build_dan_tien_upgrade_controls()

func _build_dan_tien_upgrade_controls() -> void:
    var buildings := BuildingSystem.new()
    var platform := buildings.primary_building(state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
    _add_management_section_label("CÔNG TRÌNH DẪN TIÊN")
    if platform == null:
        var missing := _label(building_management_container, "Dẫn Tiên Đài chưa có trong trạng thái hiện tại. Trò chơi chưa có lệnh dựng/đặt mới được cấp quyền.", Vector2.ZERO, Vector2(384, 48), 12)
        missing.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        return

    var overview := Label.new()
    overview.name = "DanTienFacilityOverview"
    overview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    overview.add_theme_font_size_override("font_size", 12)
    overview.add_theme_color_override("font_color", INK)
    overview.text = "Dẫn Tiên Đài · Lv%d/%d\nCông trình khởi đầu được cấp sẵn khi lập tông; hiện chưa có thao tác tự dựng hoặc đặt thêm.\nNâng cấp tăng lượt ứng viên cơ bản và vị trí người dẫn, không tăng sức chứa Đệ Tử Xá." % [platform.level, platform.max_level]
    building_management_container.add_child(overview)

    var next_level := platform.level + 1
    var status := Label.new()
    status.name = "DanTienUpgradeStatus"
    status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status.add_theme_font_size_override("font_size", 12)
    status.add_theme_color_override("font_color", INK)
    var upgrade_check := buildings.can_start_upgrade(state, platform.id)
    if platform.is_upgrading():
        var remaining := maxf(platform.upgrade_required_work - platform.upgrade_progress, 0.0)
        status.text = "Đang nâng cấp tới Lv%d · %.0f/%.0f nhịp mô phỏng (còn %.0f). Chi phí đã trừ lúc bắt đầu; tiến độ nằm trong trạng thái lưu." % [
            platform.upgrade_target_level, platform.upgrade_progress, platform.upgrade_required_work, remaining
        ]
    elif platform.level >= platform.max_level:
        status.text = "Đã đạt cấp tối đa Lv%d." % platform.max_level
    elif str(upgrade_check.get("reason", "")) == "guidance_sect_gate_pending":
        status.text = "Lv%d+ đang khóa: chưa có quy tắc Đại Điện/Tông Môn được phê duyệt. Không áp chi phí hay điều kiện tự đặt." % next_level
    else:
        var current_arrivals := buildings.guidance_base_daily_arrivals(platform)
        var next_arrivals := buildings.guidance_base_daily_arrivals_for_level(next_level)
        var current_slots := buildings.guidance_elder_slots(platform)
        var next_slots := buildings.guidance_elder_slots_for_level(next_level)
        status.text = "Cấp kế tiếp Lv%d · cơ bản %d → %d ứng viên/ngày · vị trí Tiếp Dẫn %d → %d." % [
            next_level, current_arrivals, next_arrivals, current_slots, next_slots
        ]
    building_management_container.add_child(status)

    if not platform.is_upgrading() and platform.level < platform.max_level and str(upgrade_check.get("reason", "")) != "guidance_sect_gate_pending":
        var cost := buildings.upgrade_cost(platform)
        var keys: Array = cost.keys()
        keys.sort()
        var cost_rows: Array[String] = []
        var equipment := EquipmentSystem.new()
        for raw_resource_id in keys:
            var resource_id := StringName(str(raw_resource_id))
            var needed := int(cost[raw_resource_id])
            var available := state.sect.spirit_stones if str(resource_id) == "spirit_stones" else _warehouse_available(resource_id)
            var resource_name := "Linh Thạch" if str(resource_id) == "spirit_stones" else equipment.material_name(resource_id)
            cost_rows.append("%s %d/%d" % [resource_name, available, needed])
        var cost_label := Label.new()
        cost_label.name = "DanTienUpgradeCost"
        cost_label.text = "Chi phí hiện hành: %s\nThời lượng: %.0f nhịp mô phỏng. Cấu hình chi phí/năng suất đang có trong game, chưa chốt cân bằng." % [
            " · ".join(cost_rows), buildings.upgrade_required_work(platform)
        ]
        cost_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        cost_label.add_theme_font_size_override("font_size", 11)
        cost_label.add_theme_color_override("font_color", INK)
        building_management_container.add_child(cost_label)

    var upgrade_button := Button.new()
    upgrade_button.name = "DanTienUpgradeButton"
    upgrade_button.custom_minimum_size = Vector2(384, 42)
    if platform.is_upgrading():
        upgrade_button.text = "ĐANG NÂNG CẤP → Lv%d" % platform.upgrade_target_level
    elif platform.level >= platform.max_level:
        upgrade_button.text = "ĐÃ ĐẠT CẤP TỐI ĐA"
    else:
        upgrade_button.text = "NÂNG CẤP DẪN TIÊN ĐÀI → Lv%d" % next_level
    upgrade_button.disabled = not bool(upgrade_check.get("ok", false))
    if upgrade_button.disabled:
        upgrade_button.tooltip_text = _building_upgrade_reason(upgrade_check)
    upgrade_button.add_theme_stylebox_override("normal", _style(JADE_DARK, PAPER_LIGHT, 1, 8))
    upgrade_button.pressed.connect(_start_dan_tien_upgrade_from_ui)
    building_management_container.add_child(upgrade_button)

func _open_dan_tien_screen_v2() -> void:
    if state == null:
        return
    if get_node_or_null("DanTienScreenV2") != null:
        return
    var screen := DanTienScreenV2.new()
    screen.name = "DanTienScreenV2"
    screen.z_index = 250
    screen.z_as_relative = false
    screen.attach_state(state, recruitment_system)
    screen.state_changed.connect(_on_dan_tien_screen_v2_changed)
    add_child(screen)
    screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _attach_tri_b1_screen(screen, "guidance")

func _on_dan_tien_screen_v2_changed() -> void:
    # The real runtime remains the sole roster/save authority.
    _refresh_all()
    if selected_building == SectMapPresentation.DEST_GUIDANCE:
        _refresh_building_management_controls_only()

func _candidate_recruitable(candidate: CandidateState) -> bool:
    if candidate == null:
        return false
    if state.sect.disciple_v2_birth_enabled:
        return DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile)
    return true

func _guidance_recruit_with_order() -> void:
    var result := recruitment_system.guidance_recruit_with_order(state)
    if bool(result.get("ok", false)):
        building_management_feedback = "Dẫn Tiên Đài đã tiếp nhận thêm một ứng viên."
    else:
        building_management_feedback = _recruitment_feedback(str(result.get("reason", "generation_failed")))
    _refresh_all()
    _refresh_building_management_controls_only()

func _accept_guidance_candidate(candidate_id: StringName) -> void:
    var candidate: CandidateState = state.recruitment_candidates.get(candidate_id)
    var candidate_name := candidate.display_name if candidate != null else str(candidate_id)
    var result := recruitment_system.accept_candidate(state, candidate_id)
    if bool(result.get("ok", false)):
        building_management_feedback = "Đã nhận %s vào tông môn." % candidate_name
    else:
        building_management_feedback = _recruitment_feedback(str(result.get("reason", "accept_failed")))
    # Refresh immediately so a successful authoritative roster mutation creates
    # its real map actor without waiting for a wall-clock poll.
    _refresh_all()
    _refresh_building_management_controls_only()

func _reject_guidance_candidate(candidate_id: StringName) -> void:
    var candidate: CandidateState = state.recruitment_candidates.get(candidate_id)
    var candidate_name := candidate.display_name if candidate != null else str(candidate_id)
    var result := recruitment_system.reject_candidate(state, candidate_id)
    if bool(result.get("ok", false)):
        building_management_feedback = "Đã từ chối %s." % candidate_name
    else:
        building_management_feedback = _recruitment_feedback(str(result.get("reason", "reject_failed")))
    _refresh_all()
    _refresh_building_management_controls_only()

func _recruitment_feedback(reason: String) -> String:
    match reason:
        "capacity_full":
            return "Không thể nhận thêm: Đệ Tử Xá đã đủ chỗ."
        "candidate_missing":
            return "Ứng viên này không còn trong danh sách chờ."
        "not_enough_recruitment_tokens":
            return "Không còn Chiêu Mộ Lệnh."
        "guidance_disabled", "recruitment_disabled":
            return "Dẫn Tiên hiện chưa khả dụng."
        "v2_birth_profile_incomplete":
            return "Hồ sơ V2 của ứng viên chưa hợp lệ."
        _:
            return "Thao tác tuyển mộ chưa thể thực hiện: %s." % reason

func _add_policy_button_row(options: Array, current_value: StringName, handler_name: String) -> void:
    var row := HBoxContainer.new()
    row.custom_minimum_size = Vector2(384, 36)
    row.add_theme_constant_override("separation", 5)
    building_management_container.add_child(row)

    for option_value in options:
        var option: Dictionary = option_value
        var value := StringName(option.get("value", ""))
        var button := Button.new()
        button.text = "%s%s" % [str(option.get("label", value)), " ✓" if value == current_value else ""]
        button.custom_minimum_size = Vector2(118, 34)
        button.add_theme_font_size_override("font_size", 10)
        button.pressed.connect(Callable(self, handler_name).bind(value))
        row.add_child(button)

func _build_lodging_expansion_control() -> void:
    _add_management_section_label("MỞ RỘNG CHỖ Ở")
    var row := HBoxContainer.new()
    row.custom_minimum_size = Vector2(384, 38)
    row.add_theme_constant_override("separation", 8)
    building_management_container.add_child(row)

    if SectHallSystemV1.installed(state):
        var live := Button.new()
        live.name = "OpenResidenceManagementV1"
        live.text = "QUẢN LÝ ĐỆ TỬ XÁ · NÂNG CẤP / XÂY THÊM"
        live.custom_minimum_size = Vector2(384, 43)
        live.pressed.connect(_open_dai_dien_housing_v1)
        row.add_child(live)
        return
    var info := Label.new()
    info.text = "Hiện %d chỗ · Vật tư %d" % [state.sect.lodging_capacity, state.sect.supply_stock]
    info.custom_minimum_size = Vector2(236, 34)
    info.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    info.add_theme_font_size_override("font_size", 11)
    row.add_child(info)

    var button := Button.new()
    button.name = "ExpandLodging"
    button.text = "+1 chỗ · -%d" % NeedsSystem.LODGING_EXPANSION_COST_PER_SLOT
    button.custom_minimum_size = Vector2(136, 34)
    button.add_theme_font_size_override("font_size", 10)
    button.pressed.connect(_expand_lodging_from_building)
    row.add_child(button)

func _refresh_mine_ore_hero() -> void:
    # One canonical first-screen selector for all existing Mine/Forest outputs.
    var picker := building_operation_panel.get_node_or_null("MineOreHero") as HBoxContainer
    if picker == null:
        return
    var is_mine := selected_building == SectMapPresentation.DEST_MINE
    picker.visible = is_mine or selected_building == SectMapPresentation.DEST_LINH_FOREST
    if not picker.visible:
        return
    for child in picker.get_children():
        picker.remove_child(child)
        child.queue_free()
    var bs := BuildingSystem.new()
    var site := _selected_operation_building()
    if site == null:
        return
    var current := bs.mine_selected_ore(site) if is_mine else bs.forest_selected_material(site)
    var options: Dictionary = BuildingSystem.MINE_ORE_OPTIONS if is_mine else BuildingSystem.FOREST_MATERIAL_OPTIONS
    var keys := ["thanh_thiet","ore_r01_c2","huyen_thiet","ore_r02_c2"] if is_mine else ["linh_moc","forest_r01_wood2","forest_r02_wood","forest_r02_wood2"]
    for key in keys:
        var resource := StringName(key)
        var min_level := int(options[key].get("required_level",1))
        var unlocked := site.level >= min_level
        var chosen := current == resource
        var batch := bs.mine_ore_batch_units(site,resource) if is_mine else bs.forest_material_batch_units(site,resource)
        var button := Button.new()
        button.name = "%s_%s" % ["MineOre" if is_mine else "ForestMaterial",key]
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.custom_minimum_size = Vector2(0,74)
        button.text = "%s %s\n×%d/lượt · %s" % [
            "◆" if chosen else "◇",ResourceRegistry.new().display_name(resource),batch,
            "Đã chọn" if chosen else ("Lv%d" % min_level if not unlocked else "Chọn")]
        button.tooltip_text = "Chỉ đổi đầu ra lượt mới; mẻ đang chạy vẫn giữ nguyên nguyên liệu, số lượng, ETA, receipt."
        button.disabled = not unlocked
        button.add_theme_font_size_override("font_size",12)
        button.add_theme_color_override("font_color",PAPER_LIGHT if chosen else INK)
        button.add_theme_color_override("font_disabled_color",Color(0.39,0.36,0.30))
        button.add_theme_stylebox_override("normal",_style(
            JADE_DARK if chosen else Color(0.91,0.85,0.69),
            GOLD if chosen else Color(0.55,0.45,0.28),2,9))
        if is_mine:
            button.pressed.connect(Callable(self,"_select_mine_ore_from_ui").bind(resource))
        else:
            button.pressed.connect(Callable(self,"_select_forest_material_from_ui").bind(resource))
        picker.add_child(button)

func _select_mine_ore_from_ui(ore_id: StringName) -> void:
    var bs := BuildingSystem.new()
    var site := _selected_operation_building()
    if site == null or site.building_type != BuildingSystem.TYPE_MINE:
        return
    var result := bs.select_mine_ore(state,site.id,ore_id)
    building_management_feedback = ("Đã chọn %s cho lượt mới." % ResourceRegistry.new().display_name(ore_id)) if bool(result.get("ok",false)) else ("Không thể chọn khoáng: %s" % str(result.get("reason","không hợp lệ")))
    _refresh_building_operation_content()

func _select_forest_material_from_ui(material_id: StringName) -> void:
    var bs := BuildingSystem.new()
    var site := _selected_operation_building()
    if site == null or site.building_type != BuildingSystem.TYPE_LINH_FOREST:
        return
    var result := bs.select_forest_material(state,site.id,material_id)
    building_management_feedback = ("Đã chọn %s cho lượt mới." % ResourceRegistry.new().display_name(material_id)) if bool(result.get("ok",false)) else ("Không thể chọn lâm sản: %s" % str(result.get("reason","không hợp lệ")))
    _refresh_building_operation_content()

func _build_mine_upgrade_control() -> void:
    var buildings := BuildingSystem.new()
    var mine := _selected_operation_building()
    if mine == null or mine.building_type != BuildingSystem.TYPE_MINE:
        mine = buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    _add_management_section_label("NÂNG CẤP MỎ")
    if mine == null:
        var missing := Label.new()
        missing.text = "Mỏ chưa tồn tại trong trạng thái hiện tại."
        missing.add_theme_font_size_override("font_size", 11)
        building_management_container.add_child(missing)
        return

    var row := VBoxContainer.new()
    row.custom_minimum_size = Vector2(384, 0)
    row.add_theme_constant_override("separation", 4)
    building_management_container.add_child(row)

    var info := Label.new()
    info.name = "MineUpgradeStatus"
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.add_theme_font_size_override("font_size", 10)
    row.add_child(info)

    var button := Button.new()
    button.name = "Upgrade_mine"
    button.custom_minimum_size = Vector2(384, 34)
    button.add_theme_font_size_override("font_size", 10)
    row.add_child(button)

    if mine.is_upgrading():
        info.text = "Lv%d → Lv%d · %.0f/%.0f điểm công việc · %s" % [
            mine.level, mine.upgrade_target_level,
            mine.upgrade_progress, mine.upgrade_required_work,
            _upgrade_eta_text(mine)
        ]
        button.text = "Đang nâng cấp..."
        button.disabled = true
        return

    if mine.level >= mine.max_level:
        info.text = "Mỏ đã đạt Lv%d tối đa." % mine.level
        button.text = "Đã tối đa"
        button.disabled = true
        return

    var cost := buildings.upgrade_cost(mine)
    var ore_need := int(cost.get(BuildingSystem.MATERIAL_ORE, 0))
    var wood_need := int(cost.get(BuildingSystem.MATERIAL_WOOD, 0))
    var stone_need := int(cost.get("spirit_stones", 0))
    var check := buildings.can_start_upgrade(state, mine.id)
    info.text = (
        "Lv%d → Lv%d · Thanh Thiết %d/%d · Linh Mộc %d/%d · Linh Thạch %d/%d · cần %.0f điểm công việc (%s)"
    ) % [
        mine.level, mine.level + 1,
        _warehouse_available(StringName(BuildingSystem.MATERIAL_ORE)), ore_need,
        _warehouse_available(StringName(BuildingSystem.MATERIAL_WOOD)), wood_need,
        state.sect.spirit_stones, stone_need,
        buildings.upgrade_required_work(mine), _upgrade_eta_text(mine, true)
    ]
    var extra_costs: PackedStringArray = []
    for raw_id in cost.keys():
        var extra_id := str(raw_id)
        if extra_id in [BuildingSystem.MATERIAL_WOOD,BuildingSystem.MATERIAL_ORE,"spirit_stones"]:
            continue
        extra_costs.append("%s %d/%d" % [
            ResourceRegistry.new().display_name(StringName(extra_id)),
            _warehouse_available(StringName(extra_id)),int(cost[raw_id])
        ])
    if not extra_costs.is_empty():
        info.text += "\nMốc cần thêm: " + " · ".join(extra_costs)
    button.text = "Nâng cấp Mỏ lên Lv%d" % (mine.level + 1)
    button.disabled = not bool(check.get("ok", false))
    if button.disabled:
        button.tooltip_text = _building_upgrade_reason(check)
    button.pressed.connect(Callable(self, "_start_building_upgrade_from_ui").bind(mine.id))

func _add_resource_timer_cards(building: BuildingState) -> void:
    var jobs := BuildingSystem.new().resource_timer_jobs(building)
    if jobs.is_empty():
        var legacy_rows := _legacy_carry_cycle_rows(building)
        if legacy_rows.is_empty():
            _add_live_worker_message("Chưa có mẻ timer hoặc chu kỳ mang hàng đang chạy. Chu kỳ cũ chỉ ghi sản lượng khi người làm mang hàng về Kho.")
            return
        for index in range(legacy_rows.size()):
            _add_legacy_resource_cycle_card(building, legacy_rows[index], index)
        return
    var registry := ResourceRegistry.new()
    for index in range(jobs.size()):
        var raw_job: Variant = jobs[index]
        if not (raw_job is Dictionary):
            continue
        var job: Dictionary = raw_job
        var resource_id := StringName(job.get("resource_id", ""))
        var worker_id := StringName(job.get("worker_id", ""))
        var quantity := maxi(0, int(job.get("output_quantity", 0)))
        var start_tick := int(job.get("started_tick", state.tick))
        var finish_tick := int(job.get("finish_tick", state.tick))
        var duration := maxi(1, finish_tick - start_tick)
        var elapsed := clampi(state.tick - start_tick, 0, duration)
        var progress := 100.0 * float(elapsed) / float(duration)
        var remaining := maxi(0, finish_tick - state.tick)
        var card := PanelContainer.new()
        card.name = "ResourceBatchCard_%d" % index
        card.custom_minimum_size = Vector2(0, 72)
        card.add_theme_stylebox_override("panel", _style(Color(0.91, 0.87, 0.75, 1.0), Color(0.55, 0.44, 0.27, 1.0), 1, 8))
        var column := VBoxContainer.new()
        column.add_theme_constant_override("separation", 3)
        card.add_child(column)
        var title := Label.new()
        title.text = "%s · ×%d %s" % [
            "Mẻ %d" % (index + 1),
            quantity,
            registry.display_name(resource_id) if resource_id != &"" else "nguyên liệu"
        ]
        title.add_theme_font_size_override("font_size", 12)
        title.add_theme_color_override("font_color", JADE_DARK)
        column.add_child(title)
        var progress_bar := ProgressBar.new()
        progress_bar.name = "ResourceBatchProgress_%d" % index
        progress_bar.custom_minimum_size = Vector2(0, 12)
        progress_bar.max_value = 100.0
        progress_bar.value = progress
        progress_bar.show_percentage = false
        progress_bar.add_theme_stylebox_override("background", _style(Color(0.77, 0.74, 0.66), Color(0.48, 0.40, 0.27), 1, 4))
        progress_bar.add_theme_stylebox_override("fill", _style(JADE_DARK, GOLD, 1, 4))
        column.add_child(progress_bar)
        var worker_name := "chưa rõ người phụ trách"
        if worker_id != &"" and state.disciples.has(worker_id):
            worker_name = state.disciples[worker_id].display_name
        var stock := _warehouse_available(resource_id) if resource_id != &"" else 0
        var stock_line := Label.new()
        stock_line.name = "ResourceBatchStock_%d" % index
        stock_line.text = "Kho %d · mẻ ×%d · bình quân %.2f đơn vị/phút" % [
            stock, quantity, float(quantity) / float(duration)
        ]
        stock_line.tooltip_text = "Sản lượng bình quân lý thuyết của mẻ trong %d phút mô phỏng; tài nguyên chỉ vào Kho khi mẻ hoàn tất. Loại: %s." % [
            duration,registry.display_name(resource_id)
        ]
        stock_line.add_theme_font_size_override("font_size", 10)
        stock_line.add_theme_color_override("font_color", JADE_DARK)
        column.add_child(stock_line)
        var eta := Label.new()
        var time_label := "Chờ nhập Kho" if remaining == 0 else "Còn %d phút mô phỏng" % remaining
        eta.text = time_label + (" · +%.1f EXP nghề khi nhập kho" % maxf(float(job.get("profession_xp_gain", 0.0)), 0.0))
        eta.tooltip_text = "EXP nghề thực tế đã chốt trong mẻ này; chưa cộng cho đến khi nhập kho thành công. Người phụ trách: %s" % worker_name
        eta.add_theme_font_size_override("font_size", 11)
        eta.add_theme_color_override("font_color", INK)
        column.add_child(eta)
        building_operation_live_content.add_child(card)

func _add_legacy_resource_cycle_card(building: BuildingState, cycle: Dictionary, index: int) -> void:
    var resource_id := StringName(cycle.get("resource_id", ""))
    var quantity := maxi(0, int(cycle.get("output_quantity", 0)))
    var remaining := maxi(0, int(cycle.get("remaining_ticks", 0)))
    var worker_name := str(cycle.get("worker_name", "Chưa rõ người phụ trách"))
    var resource_name := ResourceRegistry.new().display_name(resource_id) if resource_id != &"" else "nguyên liệu"
    var card := PanelContainer.new()
    card.name = "LegacyResourceCycleCard_%d" % index
    card.custom_minimum_size = Vector2(0, 82)
    card.add_theme_stylebox_override("panel", _style(Color(0.91, 0.87, 0.75, 1.0), Color(0.55, 0.44, 0.27, 1.0), 1, 8))
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 3)
    card.add_child(column)
    var heading := HBoxContainer.new()
    heading.add_theme_constant_override("separation", 6)
    var icon := SECT_UI_ICON.new()
    icon.name = "LegacyCycleResourceIcon"
    icon.kind = "ore" if building.building_type == BuildingSystem.TYPE_MINE else "wood"
    icon.custom_minimum_size = Vector2(24, 24)
    heading.add_child(icon)
    var title := Label.new()
    title.text = "%s · ×%d %s" % [worker_name, quantity, resource_name]
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title.clip_text = true
    title.add_theme_font_size_override("font_size", 12)
    title.add_theme_color_override("font_color", JADE_DARK)
    heading.add_child(title)
    column.add_child(heading)
    var progress_bar := ProgressBar.new()
    progress_bar.name = "LegacyResourceCycleProgress_%d" % index
    progress_bar.custom_minimum_size = Vector2(0, 12)
    progress_bar.max_value = 100.0
    progress_bar.value = float(cycle.get("progress", 0.0))
    progress_bar.show_percentage = false
    progress_bar.add_theme_stylebox_override("background", _style(Color(0.77, 0.74, 0.66), Color(0.48, 0.40, 0.27), 1, 4))
    progress_bar.add_theme_stylebox_override("fill", _style(JADE_DARK, GOLD, 1, 4))
    column.add_child(progress_bar)
    var detail := Label.new()
    detail.text = str(cycle.get("phase_status", "Đang làm"))
    detail.tooltip_text = "Ước tính còn lại từ pha và tiến độ thật của chu kỳ; tính theo tốc độ nghề, di chuyển và tải hàng hiện tại. Sản phẩm chỉ nhập Kho khi pha mang hàng hoàn tất."
    detail.add_theme_font_size_override("font_size", 10)
    detail.add_theme_color_override("font_color", INK)
    detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(detail)
    building_operation_live_content.add_child(card)

func _add_spirit_field_plot_cards(building: BuildingState) -> void:
    var plots: Array = BuildingSystem.new().spirit_field_plots(state, building)
    if plots.is_empty():
        _add_live_worker_message("Chưa có ô trồng được khởi tạo cho Linh Điền này.")
        return
    for index in range(plots.size()):
        var raw_plot: Variant = plots[index]
        if not (raw_plot is Dictionary):
            continue
        var plot: Dictionary = raw_plot
        var status := StringName(plot.get("status", BuildingSystem.PLOT_EMPTY))
        var crop_id := StringName(plot.get("crop_id", ""))
        var start_tick := int(plot.get("started_tick", state.tick))
        var finish_tick := int(plot.get("finish_tick", state.tick))
        var duration := maxi(1, finish_tick - start_tick)
        var elapsed := clampi(state.tick - start_tick, 0, duration)
        var growing := status == BuildingSystem.PLOT_GROWING
        var ready := growing and finish_tick <= state.tick
        var crop_name := spirit_crop_registry.display_name(crop_id) if crop_id != &"" else "Chưa gieo"
        var worker_id := StringName(plot.get("assigned_worker_id", ""))
        var worker_name := "Chưa phân công"
        if worker_id != &"" and state.disciples.has(worker_id):
            worker_name = state.disciples[worker_id].display_name
        var yield_count := maxi(0, int(plot.get("routine_yield", 0)))
        var card := PanelContainer.new()
        card.name = "SpiritPlotCard_%d" % index
        card.custom_minimum_size = Vector2(0, 92)
        card.add_theme_stylebox_override("panel", _style(Color(0.91, 0.87, 0.75, 1.0), Color(0.55, 0.44, 0.27, 1.0), 1, 8))
        var column := VBoxContainer.new()
        column.add_theme_constant_override("separation", 3)
        card.add_child(column)
        var header := HBoxContainer.new()
        header.custom_minimum_size = Vector2(0, 28)
        header.add_theme_constant_override("separation", 7)
        var crop_icon := SECT_UI_ICON.new()
        crop_icon.name = "SpiritPlotCropIcon_%d" % index
        crop_icon.kind = "leaf" if growing else "root"
        crop_icon.tint = JADE_DARK if growing else GOLD
        crop_icon.custom_minimum_size = Vector2(26, 26)
        header.add_child(crop_icon)
        var title := Label.new()
        title.text = "Ô đất %02d · %s" % [index + 1, crop_name]
        title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        title.clip_text = true
        title.tooltip_text = "Ô đất %02d · %s" % [index + 1, crop_name]
        title.add_theme_font_size_override("font_size", 12)
        title.add_theme_color_override("font_color", JADE_DARK)
        header.add_child(title)
        column.add_child(header)
        var progress_bar := ProgressBar.new()
        progress_bar.name = "SpiritPlotProgress_%d" % index
        progress_bar.custom_minimum_size = Vector2(0, 12)
        progress_bar.max_value = 100.0
        progress_bar.value = 100.0 if ready else (100.0 * float(elapsed) / float(duration) if growing else 0.0)
        progress_bar.show_percentage = false
        progress_bar.add_theme_stylebox_override("background", _style(Color(0.77, 0.74, 0.66), Color(0.48, 0.40, 0.27), 1, 4))
        progress_bar.add_theme_stylebox_override("fill", _style(JADE_DARK, GOLD, 1, 4))
        column.add_child(progress_bar)
        var remaining := maxi(0, finish_tick - state.tick) if growing else 0
        var crop_stock := _warehouse_available(crop_id) if crop_id != &"" else 0
        var yield_text := " · dự kiến ×%d (chưa tính may mắn)" % yield_count if growing else ""
        var state_text := "Chờ thu hoạch" if ready else ("Còn %d phút mô phỏng" % remaining if growing else "Sẵn sàng gieo")
        var detail := Label.new()
        detail.text = "%s · %s%s%s" % [worker_name, state_text, yield_text, " · Kho: %d" % crop_stock if crop_id != &"" else ""]
        if growing:
            if plot.has("profession_xp_gain"):
                detail.text += " · +%.2f EXP khi thu hoạch" % maxf(float(plot.get("profession_xp_gain",0.0)),0.0)
            else:
                detail.tooltip_text = "Mẻ cũ đã nhận EXP nghề ở thời điểm gieo, không cộng thêm khi thu hoạch."
        detail.tooltip_text = "EXP Linh Thực chỉ cộng sau khi thu hoạch nhập Kho thành công. Lượt này có sản lượng cơ bản ×%d / %d phút mô phỏng, bình quân %.2f đơn vị/phút trước thưởng may mắn." % [
            yield_count,duration,float(yield_count)/float(duration)
        ] if growing and plot.has("profession_xp_gain") else (
            "Mẻ save cũ đã được cộng EXP lúc gieo, không nhận lần hai." if growing else
            "Ô trống không sản xuất và không cộng EXP."
        )
        detail.add_theme_font_size_override("font_size", 10)
        detail.add_theme_color_override("font_color", INK)
        detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        column.add_child(detail)
        building_operation_live_content.add_child(card)

func _start_building_upgrade_from_ui(building_id: StringName) -> void:
    var buildings := BuildingSystem.new()
    var building = state.buildings.get(str(building_id))
    var display := _building_name(building_id)
    var result := buildings.start_upgrade(state, building_id)
    if bool(result.get("ok", false)):
        building_management_feedback = "Đã bắt đầu nâng cấp %s lên Lv%d; chi phí canonical đã trừ một lần." % [display, int(result.get("target_level", 0))]
    else:
        building_management_feedback = "Không thể nâng cấp %s: %s" % [display, _building_upgrade_reason(result)]
    _refresh_all()
    _refresh_building_management_controls_only()

func _start_dan_tien_upgrade_from_ui() -> void:
    var buildings := BuildingSystem.new()
    var platform := buildings.primary_building(state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
    if platform == null:
        building_management_feedback = "Dẫn Tiên Đài chưa có trong trạng thái hiện tại."
    else:
        var result := buildings.start_upgrade(state, platform.id)
        if bool(result.get("ok", false)):
            building_management_feedback = "Đã bắt đầu nâng cấp Dẫn Tiên Đài lên Lv%d; chi phí do BuildingSystem trừ một lần." % int(result.get("target_level", 0))
        else:
            building_management_feedback = "Không thể nâng cấp Dẫn Tiên Đài: %s" % _building_upgrade_reason(result)
    _refresh_all()
    _refresh_building_management_controls_only()

func _building_upgrade_reason(result: Dictionary) -> String:
    var reason := str(result.get("reason", ""))
    match reason:
        "already_upgrading":
            return "Đang có lượt nâng cấp."
        "missing_material":
            var missing_id := StringName(result.get("material_id", ""))
            var source_hint := ""
            if missing_id == &"tam_mach_ban":
                source_hint = " Mua Tầm Mạch Bàn bằng Linh Thạch thật tại Kho → Phường Thị (giới hạn NPC mỗi ngày)."
            elif missing_id == &"linh_tuyen_chi_tam":
                source_hint = " Thu hoạch Linh Điền hoặc mua mảnh thật tại Kho → Phường Thị; đúng 100 mảnh ghép thành 1 Chi Tâm."
            return "Thiếu %s: dùng được %d/%d.%s" % [
                EquipmentSystem.new().material_name(missing_id),
                int(result.get("have", 0)),
                int(result.get("need", 0)),source_hint
            ]
        "missing_spirit_stones":
            return "Thiếu Linh Thạch: %d/%d." % [
                int(result.get("have", 0)),
                int(result.get("need", 0))
            ]
        "max_level":
            return "Đã đạt cấp tối đa."
        "guidance_sect_gate_pending":
            return "Lv21+ đang khóa tới khi có điều kiện Đại Điện/Tông Môn được phê duyệt."
        "missing_building":
            return "Chưa có công trình nâng cấp hợp lệ."
        "upgrade_content_pending":
            return "Nội dung nâng cấp chưa được xác lập."
        "main_hall_level_gate":
            return "Đại Điện hiện chỉ cho phép công trình nâng tới Lv%d." % int(result.get("maximum", 0))
        "milestone_component_not_defined":
            return "Chưa có vật phẩm mở mốc Lv%d." % int(result.get("target_level", 0))
        "":
            return "Sẵn sàng."
        _:
            return reason

func _build_forge_craft_controls() -> void:
    _add_management_section_label("LUYỆN CHẾ TRANG BỊ")
    var recipe_ids: Array = EquipmentSystem.RECIPES.keys()
    recipe_ids.sort()
    for raw_id in recipe_ids:
        var recipe_id := StringName(raw_id)
        var data := equipment_system.recipe(recipe_id)
        if data.is_empty():
            continue

        var row := VBoxContainer.new()
        row.custom_minimum_size = Vector2(384, 0)
        row.add_theme_constant_override("separation", 3)
        building_management_container.add_child(row)

        var top := HBoxContainer.new()
        top.custom_minimum_size = Vector2(384, 36)
        top.add_theme_constant_override("separation", 6)
        row.add_child(top)

        var name := Label.new()
        name.text = str(data.get("name", recipe_id))
        name.custom_minimum_size = Vector2(244, 34)
        name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        name.add_theme_font_size_override("font_size", 11)
        top.add_child(name)

        var craft := Button.new()
        craft.name = "Craft_%s" % str(recipe_id)
        craft.text = "Luyện vào kho"
        craft.custom_minimum_size = Vector2(128, 34)
        craft.add_theme_font_size_override("font_size", 10)
        craft.disabled = not equipment_system.can_craft(state, recipe_id)
        if craft.disabled:
            craft.tooltip_text = _recipe_material_status(recipe_id)
        craft.pressed.connect(Callable(self, "_craft_from_building").bind(recipe_id))
        top.add_child(craft)

        var materials := Label.new()
        materials.text = _recipe_material_status(recipe_id)
        materials.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        materials.add_theme_font_size_override("font_size", 10)
        materials.add_theme_color_override("font_color", Color(0.24, 0.22, 0.18, 0.76))
        row.add_child(materials)

func _recipe_material_status(recipe_id: StringName) -> String:
    var data := equipment_system.recipe(recipe_id)
    if data.is_empty():
        return "Recipe không tồn tại."
    var materials: Dictionary = equipment_system.crafting_requirements(state,recipe_id)
    var ids: Array = materials.keys()
    ids.sort()
    var parts: Array[String] = []
    var missing: Array[String] = []
    for raw_id in ids:
        var material_id := StringName(raw_id)
        var need := int(materials[raw_id])
        var total := _warehouse_quantity(material_id)
        var usable := _warehouse_available(material_id)
        parts.append("%s tồn %d / dùng %d / cần %d" % [equipment_system.material_name(material_id), total, usable, need])
        if usable < need:
            missing.append(equipment_system.material_name(material_id))
    var can_craft := equipment_system.can_craft(state, recipe_id)
    var suffix := " · Đủ nguyên liệu" if can_craft else (
        " · Thiếu vật tư dùng được: %s" % ", ".join(missing) if not missing.is_empty()
        else " · Chưa thể chế tạo"
    )
    return "Nguyên liệu (tồn / dùng / cần): %s%s" % [" · ".join(parts), suffix]

func _set_work_policy_from_building(policy: StringName) -> void:
    var ok := workforce.set_work_policy(state, policy)
    building_management_feedback = "Đã đổi chính sách lao động: %s." % _work_policy_label(policy) if ok else "Không thể đổi chính sách lao động."
    _refresh_building_operation_content()

func _set_needs_priority_from_building(priority: StringName) -> void:
    var ok := needs_system.set_priority(state, priority)
    building_management_feedback = "Đã đổi ưu tiên hậu cần: %s." % _needs_priority_label(priority) if ok else "Không thể đổi ưu tiên hậu cần."
    _refresh_building_operation_content()

func _set_equipment_policy_from_building(policy: StringName) -> void:
    var ok := equipment_system.set_policy(state, policy)
    building_management_feedback = "Đã đổi chính sách trang bị: %s." % _equipment_policy_label(policy) if ok else "Không thể đổi chính sách trang bị."
    _refresh_building_operation_content()

func _expand_lodging_from_building() -> void:
    var ok := needs_system.expand_lodging(state, 1)
    if ok:
        building_management_feedback = "Đã mở rộng +1 chỗ nghỉ, tốn %d vật tư." % NeedsSystem.LODGING_EXPANSION_COST_PER_SLOT
    else:
        building_management_feedback = "Không đủ %d vật tư để mở rộng +1 chỗ." % NeedsSystem.LODGING_EXPANSION_COST_PER_SLOT
    _refresh_building_operation_content()

func _craft_from_building(recipe_id: StringName) -> void:
    var item := equipment_system.craft(state, recipe_id, false)
    if item.is_empty():
        building_management_feedback = "Không đủ nguyên liệu: %s" % _recipe_material_status(recipe_id)
    else:
        building_management_feedback = "Đã luyện chế %s · %s vào Kho Tông Môn." % [
            str(item.get("name", recipe_id)),
            equipment_system.quality_name(StringName(item.get("quality", "pham")))
        ]
    _refresh_building_operation_content()

func _filter_building_workers(query: String) -> void:
    var needle := query.strip_edges().to_lower()
    if building_management_container == null:
        return
    var candidate_toggle := building_management_container.get_node_or_null("WorkforceCandidateToggle") as Button
    var show_candidates := candidate_toggle != null and candidate_toggle.button_pressed
    for child in building_management_container.get_children():
        if not (child is HBoxContainer) or not str(child.name).begins_with("Person_"):
            continue
        var row := child as HBoxContainer
        var name_label := row.get_child(0) as Label if row.get_child_count() > 0 else null
        var matches_search := needle.is_empty() or (name_label != null and name_label.text.to_lower().contains(needle))
        var is_candidate := bool(row.get_meta("workforce_candidate", false))
        row.visible = matches_search and (show_candidates or not is_candidate)

func _toggle_workforce_candidates() -> void:
    if building_management_container == null:
        return
    var toggle := building_management_container.get_node_or_null("WorkforceCandidateToggle") as Button
    if toggle == null:
        return
    toggle.text = "Ẩn đệ tử chưa phân công" if toggle.button_pressed else "+ Chọn thêm đệ tử"
    var search := building_management_container.find_child("WorkforceSearch_*", true, false) as LineEdit
    _filter_building_workers(search.text if search != null else "")

func _build_work_management(profession_id: StringName, group_id: StringName, group_label: String, order_label: String) -> void:
    _add_management_section_label("PHÂN CÔNG")
    var active_building_ids: Array[StringName] = []
    var building_system := BuildingSystem.new()
    var active_producer: BuildingState = null
    if building_system.is_building_profession(profession_id):
        active_producer = building_system.building_for_profession(state, profession_id)
        # A map-selected paid annex is the actual worksite the player edits;
        # never show the first producer's slots for a second producer.
        var selected_site := _selected_operation_building()
        if active_producer != null and selected_site != null and selected_site.building_type == active_producer.building_type:
            active_producer = selected_site
        if active_producer != null:
            active_building_ids = building_system.active_worker_ids(state, active_producer)

    var candidate_toggle := Button.new()
    candidate_toggle.name = "WorkforceCandidateToggle"
    candidate_toggle.text = "+ Chọn thêm đệ tử"
    candidate_toggle.toggle_mode = true
    candidate_toggle.button_pressed = false
    candidate_toggle.custom_minimum_size = Vector2(0, 34)
    candidate_toggle.add_theme_font_size_override("font_size", 11)
    candidate_toggle.pressed.connect(Callable(self, "_toggle_workforce_candidates"))
    building_management_container.add_child(candidate_toggle)

    var search := LineEdit.new()
    search.name = "WorkforceSearch_%s" % str(group_id)
    search.placeholder_text = "Tìm đệ tử trong đội…"
    search.custom_minimum_size = Vector2(0, 34)
    search.add_theme_font_size_override("font_size", 12)
    search.add_theme_color_override("font_color", INK)
    search.add_theme_color_override("font_placeholder_color", Color(0.32, 0.31, 0.27, 0.8))
    search.text_changed.connect(Callable(self, "_filter_building_workers"))
    building_management_container.add_child(search)
    var crew_summary := Label.new()
    crew_summary.name = "WorkforceCapacitySummary"
    var slots := maxi(0, building_system.worker_slots(active_producer)) if active_producer != null else 0
    crew_summary.text = "Chỗ hoạt động %d/%d · tổng đội %d · chờ %d" % [
        active_building_ids.size(),
        slots,
        building_system.assigned_worker_ids(state, active_producer).size() if active_producer != null else 0,
        maxi(0, building_system.assigned_worker_ids(state, active_producer).size() - active_building_ids.size()) if active_producer != null else 0
    ]
    crew_summary.add_theme_font_size_override("font_size", 11)
    crew_summary.add_theme_color_override("font_color", JADE_DARK)
    building_management_container.add_child(crew_summary)

    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        var row := _new_management_row(disciple)
        var in_group := disciple.work_group_id == group_id
        row.set_meta("workforce_candidate", not in_group)
        row.visible = in_group
        var name_label := row.get_child(0) as Label
        var role_text := "CHƯA PHÂN ĐỘI"
        if in_group:
            if profession_id == WorkforceSystem.PROF_MINING:
                role_text = _mining_member_status(disciple, active_building_ids.has(disciple.id), active_producer)
            elif profession_id == WorkforceSystem.PROF_FORESTRY:
                role_text = _resource_job_member_status(disciple, profession_id, active_building_ids.has(disciple.id), active_producer)
            elif active_building_ids.has(disciple.id):
                role_text = "Chỗ hoạt động"
            else:
                role_text = "Chờ chỗ hoạt động"
        if name_label != null:
            name_label.text = "%s\n%s" % [disciple.display_name,role_text]
            name_label.tooltip_text += " · " + role_text
        var timed_recipe_busy := building_system.disciple_has_active_timed_recipe(state, disciple.id)

        var group_button := Button.new()
        group_button.name = "Group_%s_%s" % [str(group_id), str(disciple.id)]
        group_button.text = "Rút đội" if in_group else "Phân đội"
        group_button.custom_minimum_size = Vector2(70, 44)
        group_button.add_theme_font_size_override("font_size", 11)
        if timed_recipe_busy:
            group_button.disabled = true
            group_button.tooltip_text = "Đệ tử đang hoàn thành mẻ đã commit; không thể đổi đội."
        if in_group:
            group_button.pressed.connect(Callable(self, "_assign_building_group").bind(disciple.id, &"", "Đã rút %s khỏi %s." % [disciple.display_name, group_label]))
        else:
            group_button.pressed.connect(Callable(self, "_assign_building_group").bind(disciple.id, group_id, "Đã phân %s vào %s." % [disciple.display_name, group_label]))
        row.add_child(group_button)

        # GP-01: distinguish crew membership from an explicit, persisted Mine
        # worksite. Full crews may retain waiting members; only active slots
        # receive work orders. No fake worksite/building state is created.
        if profession_id in [WorkforceSystem.PROF_MINING, WorkforceSystem.PROF_FORESTRY] and active_producer != null:
            var site_button := Button.new()
            site_button.name = ("%sWorksite_%s" % [
                "Mine" if profession_id == WorkforceSystem.PROF_MINING else "Forest",
                str(disciple.id)
            ])
            var assigned_here := disciple.worksite_building_id == active_producer.id
            var site_label := "Mỏ" if profession_id == WorkforceSystem.PROF_MINING else "Lâm"
            site_button.text = "Bỏ điểm" if assigned_here else "Chọn " + site_label
            site_button.custom_minimum_size = Vector2(70, 44)
            site_button.add_theme_font_size_override("font_size", 11)
            site_button.disabled = not in_group or timed_recipe_busy
            site_button.tooltip_text = (
                "Giữ nhóm nghề; chỉ xóa điểm làm việc cụ thể." if assigned_here
                else "Chọn đúng %s đang mở; hết slot thì đệ tử phải chờ." % site_label
            )
            site_button.pressed.connect(Callable(self, "_assign_mine_worksite").bind(
                disciple.id, &"" if assigned_here else active_producer.id
            ))
            row.add_child(site_button)

        var order_button := Button.new()
        order_button.name = "Work_%s_%s" % [str(profession_id), str(disciple.id)]
        order_button.text = order_label
        order_button.custom_minimum_size = Vector2(76, 44)
        order_button.add_theme_font_size_override("font_size", 11)
        if building_system.is_building_profession(profession_id):
            var has_active_slot := active_building_ids.has(disciple.id)
            order_button.disabled = not has_active_slot or not building_system.work_available(state, profession_id, disciple)
            if not has_active_slot:
                order_button.tooltip_text = "Cần thuộc một chỗ hoạt động của công trình trước khi ra lệnh."
            elif order_button.disabled:
                order_button.tooltip_text = "Công trình hiện chưa thể bắt đầu lượt làm việc mới."
        order_button.pressed.connect(Callable(self, "_issue_building_order").bind(
            disciple.id,
            WorkforceSystem.COMMAND_WORK,
            str(profession_id),
            "Đã ra lệnh %s: %s." % [order_label.to_lower(), disciple.display_name]
        ))
        row.add_child(order_button)

func _build_spirit_field_management() -> void:
    var buildings := BuildingSystem.new()
    var field := _selected_operation_building()
    if field == null or field.building_type != BuildingSystem.TYPE_SPIRIT_FIELD:
        field = buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    if field == null:
        _add_management_section_label("LINH ĐIỀN CHƯA SẴN SÀNG")
        return

    # Put actual upgrade control first, not after the scrollable roster.
    _build_worksite_upgrade_control(field)
    _build_spirit_plot_crop_preferences(field)
    _add_management_section_label("CHÍNH SÁCH CÂY TRỒNG")
    var policy_row := HBoxContainer.new()
    policy_row.custom_minimum_size = Vector2(384, 36)
    policy_row.add_theme_constant_override("separation", 5)
    building_management_container.add_child(policy_row)

    var auto_button := Button.new()
    auto_button.name = "FieldPolicy_auto_demand"
    auto_button.text = "Tự động ✓" if StringName(field.production_state.get("policy_mode", "")) == BuildingSystem.FIELD_POLICY_AUTO_DEMAND else "Tự động"
    auto_button.custom_minimum_size = Vector2(94, 34)
    auto_button.add_theme_font_size_override("font_size", 10)
    auto_button.pressed.connect(Callable(self, "_set_spirit_field_policy_from_ui").bind(
        field.id, BuildingSystem.FIELD_POLICY_AUTO_DEMAND, &""
    ))
    policy_row.add_child(auto_button)

    for crop_id in spirit_crop_registry.eligible_crop_ids(field.level):
        var fixed := Button.new()
        fixed.name = "FieldPolicy_fixed_%s" % str(crop_id)
        fixed.text = "Cố định %s" % spirit_crop_registry.display_name(crop_id)
        fixed.custom_minimum_size = Vector2(132, 34)
        fixed.add_theme_font_size_override("font_size", 9)
        fixed.disabled = field.level < 10
        if fixed.disabled:
            fixed.tooltip_text = "Chính sách Cố định mở ở Linh Điền Lv10."
        fixed.pressed.connect(Callable(self, "_set_spirit_field_policy_from_ui").bind(
            field.id, BuildingSystem.FIELD_POLICY_FIXED, crop_id
        ))
        policy_row.add_child(fixed)

    var mode := StringName(field.production_state.get("policy_mode", BuildingSystem.FIELD_POLICY_AUTO_DEMAND))
    var policy_text := "Chính sách hiện tại: Tự động theo nhu cầu · áp dụng cho toàn Linh Điền, chỉ khi ô trống."
    if mode == BuildingSystem.FIELD_POLICY_FIXED:
        var crop_name := spirit_crop_registry.display_name(StringName(field.production_state.get("fixed_crop_id", "")))
        policy_text = "Chính sách hiện tại: Cố định · %s · toàn Linh Điền, chỉ khi ô trống. Các ô đang trồng không đổi cây." % crop_name
    elif mode == BuildingSystem.FIELD_POLICY_PRIORITY:
        var weights: Dictionary = field.production_state.get("priority_weights", {})
        var weight_ids: Array = weights.keys()
        weight_ids.sort()
        var weight_labels := PackedStringArray()
        for raw_crop_id in weight_ids:
            var crop_key := StringName(raw_crop_id)
            weight_labels.append("%s ×%d" % [spirit_crop_registry.display_name(crop_key), int(weights[raw_crop_id])])
        policy_text = "Chính sách hiện tại: Ưu tiên · %s · toàn Linh Điền, chỉ khi ô trống." % (" → ".join(weight_labels) if not weight_labels.is_empty() else "chưa có trọng số")
    var policy_summary := Label.new()
    policy_summary.name = "FieldPolicySummary"
    policy_summary.text = policy_text
    policy_summary.custom_minimum_size = Vector2(0, 38)
    policy_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    policy_summary.add_theme_font_size_override("font_size", 10)
    policy_summary.add_theme_color_override("font_color", JADE_DARK)
    building_management_container.add_child(policy_summary)
    var xp_note := Label.new()
    xp_note.name = "FieldProfessionXpGuide"
    xp_note.text = "EXP khi thu hoạch nhập Kho: Linh Cốc +8 · Thanh Linh Thảo +10 · Tử Vân Thảo +16 (Lv10), trước hệ số."
    xp_note.tooltip_text = "Đây là EXP Linh Thực cơ bản, không phải Tu Vi. Số EXP chốt từ lúc gieo nhưng chỉ cộng khi sản phẩm vào Linh Kho thật; hủy ô mới không nhận EXP. Ô trồng từ save cũ không được cộng lại EXP."
    xp_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    xp_note.add_theme_font_size_override("font_size", 10)
    xp_note.add_theme_color_override("font_color", JADE_DARK)
    building_management_container.add_child(xp_note)

    _add_management_section_label("PHÂN CÔNG & GIEO TRỒNG")
    var active_ids := buildings.active_worker_ids(state, field)
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        var row := _new_management_row(disciple)
        var in_group := disciple.work_group_id == &"herbalism_crew"
        var has_plot_here := buildings.disciple_has_active_spirit_plot(state, disciple.id, field)
        var has_plot := buildings.disciple_has_active_spirit_plot(state, disciple.id)
        var active_slot := active_ids.has(disciple.id)
        var status_text := (
            "Đang chăm ô trồng" if has_plot_here
            else "Đang chăm Linh Điền khác" if has_plot
            else "Sẵn sàng gieo" if active_slot
            else "Chờ chỗ hoạt động" if in_group else "Chưa phân đội"
        )
        var field_name_label := row.get_child(0) as Label
        if field_name_label != null:
            field_name_label.text = "%s\n%s" % [disciple.display_name, status_text]

        var group_button := Button.new()
        group_button.name = "FieldGroup_%s" % str(disciple.id)
        group_button.text = "Rút đội" if in_group else "Phân đội"
        group_button.custom_minimum_size = Vector2(70, 34)
        group_button.add_theme_font_size_override("font_size", 11)
        group_button.disabled = has_plot
        if has_plot:
            group_button.tooltip_text = "Ô đang trồng giữ đệ tử tới khi thu hoạch xong."
        elif in_group:
            group_button.pressed.connect(Callable(self, "_assign_building_group").bind(
                disciple.id, &"", "Đã rút %s khỏi Đội Linh Thực." % disciple.display_name
            ))
        else:
            group_button.pressed.connect(Callable(self, "_assign_building_group").bind(
                disciple.id, &"herbalism_crew", "Đã phân %s vào Đội Linh Thực." % disciple.display_name
            ))
        row.add_child(group_button)

        # Each paid Field is a real independent worksite. Group membership
        # alone defaults to the original Field; second/third Field needs an
        # explicit persisted BuildingState assignment, like Mine/Forest.
        var worksite_button := Button.new()
        worksite_button.name = "FieldWorksite_%s" % str(disciple.id)
        var assigned_here := disciple.worksite_building_id == field.id
        worksite_button.text = "Bỏ điểm" if assigned_here else "Chọn Điền"
        worksite_button.custom_minimum_size = Vector2(74,34)
        worksite_button.add_theme_font_size_override("font_size",10)
        worksite_button.disabled = not in_group or has_plot
        worksite_button.tooltip_text = (
            "Không chuyển Linh Điền khi đang chăm một ô trồng." if has_plot
            else "Xóa điểm cụ thể, giữ đội Linh Thực." if assigned_here
            else "Đặt người làm tại chính Linh Điền đang mở; không tạo thêm slot ảo."
        )
        worksite_button.pressed.connect(Callable(self,"_assign_mine_worksite").bind(
            disciple.id,&"" if assigned_here else field.id
        ))
        row.add_child(worksite_button)

        var plant_button := Button.new()
        plant_button.name = "FieldPlant_%s" % str(disciple.id)
        plant_button.text = "Gieo trồng"
        plant_button.custom_minimum_size = Vector2(82, 34)
        plant_button.add_theme_font_size_override("font_size", 10)
        var reason := _spirit_field_start_reason(disciple, field, active_ids)
        plant_button.disabled = reason != ""
        if plant_button.disabled:
            plant_button.tooltip_text = reason
        plant_button.pressed.connect(Callable(self, "_issue_building_order").bind(
            disciple.id,
            WorkforceSystem.COMMAND_WORK,
            str(WorkforceSystem.PROF_HERBALISM),
            "Đã ra lệnh gieo trồng: %s." % disciple.display_name
        ))
        row.add_child(plant_button)

func _build_spirit_plot_crop_preferences(field: BuildingState) -> void:
    _add_management_section_label("Ô RUỘNG · CHỌN CÂY RIÊNG")
    var preferences: Dictionary = field.production_state.get("plot_crop_preferences",{})
    for raw_plot in BuildingSystem.new().spirit_field_plots(state,field):
        if not (raw_plot is Dictionary):
            continue
        var plot_id := str(raw_plot.get("plot_id",""))
        var selected_crop := StringName(preferences.get(plot_id,""))
        var locked := StringName(raw_plot.get("status","")) == BuildingSystem.PLOT_GROWING
        var row := HBoxContainer.new()
        row.name = "PlotCropChoice_%s" % plot_id
        row.custom_minimum_size = Vector2(0,34)
        building_management_container.add_child(row)
        var index := int(plot_id.trim_prefix("plot_"))
        var choice := Button.new()
        choice.name = "PlotCropCycle_%s" % plot_id
        choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        choice.custom_minimum_size = Vector2(0,34)
        choice.text = "Ô %02d · %s%s" % [
            index,
            "Theo chính sách" if selected_crop == &"" else spirit_crop_registry.display_name(selected_crop),
            " · Đang trồng" if locked else " · Đổi cây"
        ]
        choice.disabled = locked
        choice.tooltip_text = "Chọn giống riêng cho ô trống này; bấm để chuyển giữa các loại cây thật đã mở khóa. Chi phí Linh Thạch chỉ bị trừ khi đệ tử gieo thành công."
        if not locked:
            choice.pressed.connect(Callable(self,"_cycle_spirit_plot_crop_from_ui").bind(field.id,plot_id))
        row.add_child(choice)

func _cycle_spirit_plot_crop_from_ui(field_id: StringName, plot_id: String) -> void:
    var buildings := BuildingSystem.new()
    var field := state.buildings.get(str(field_id)) as BuildingState
    if field == null:
        return
    var selected := StringName(field.production_state.get("plot_crop_preferences",{}).get(plot_id,""))
    var options: Array[StringName] = [&""]
    options.append_array(spirit_crop_registry.eligible_crop_ids(field.level))
    var previous := options.find(selected)
    var next_crop: StringName = options[(previous+1) % options.size()]
    var response := buildings.set_spirit_plot_crop(state,field_id,StringName(plot_id),next_crop)
    building_management_feedback = (
        "Ô %s: %s · chỉ lượt gieo mới áp dụng." % [plot_id, "Theo chính sách" if next_crop == &"" else spirit_crop_registry.display_name(next_crop)]
        if bool(response.get("ok",false)) else
        "Không đổi được giống ô %s: %s" % [plot_id,str(response.get("reason","unknown"))]
    )
    _refresh_building_operation_content()

func _set_spirit_field_policy_from_ui(field_id: StringName, mode: StringName, crop_id: StringName) -> void:
    var ok := BuildingSystem.new().set_spirit_field_policy(state, field_id, mode, crop_id)
    building_management_feedback = "Đã cập nhật chính sách Linh Điền." if ok else "Không thể đổi chính sách Linh Điền ở cấp hiện tại."
    _refresh_building_operation_content()

func _spirit_field_start_reason(disciple: DiscipleState, field: BuildingState, active_ids: Array[StringName]) -> String:
    var buildings := BuildingSystem.new()
    if disciple.region_id != &"sect":
        return "Đệ tử phải ở trong tông môn."
    if disciple.work_group_id != &"herbalism_crew":
        return "Cần phân vào Đội Linh Thực."
    if not active_ids.has(disciple.id):
        return "Không còn chỗ hoạt động tại Linh Điền."
    if buildings.disciple_has_active_spirit_plot(state, disciple.id):
        return "Đệ tử đang phụ trách một ô Linh Điền; chờ thu hoạch trước khi gieo nơi khác."

    var has_empty := false
    for raw_plot in buildings.spirit_field_plots(state, field):
        if raw_plot is Dictionary and StringName(raw_plot.get("status", "")) == BuildingSystem.PLOT_EMPTY:
            has_empty = true
            break
    if not has_empty:
        return "Không còn ô Linh Điền trống."

    var eligible := spirit_crop_registry.eligible_crop_ids(field.level)
    var affordable := false
    for crop_id in eligible:
        if state.sect.spirit_stones >= spirit_crop_registry.cost(crop_id):
            affordable = true
            break
    if not affordable:
        return "Không đủ Linh Thạch cho cây trồng hợp lệ."
    if not buildings.work_available(state, WorkforceSystem.PROF_HERBALISM, disciple):
        return "Chính sách hiện tại chưa chọn được cây có thể trồng."
    return ""

func _build_direct_order_management(kind: StringName, target: String, button_text: String, outside_only: bool) -> void:
    _add_management_section_label("LỆNH TÔNG CHỦ")
    var ids: Array = state.disciples.keys()
    ids.sort()
    var added := 0
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if outside_only and disciple.region_id == &"sect" and not SectMapPresentation.is_outside_flow(disciple.current_action):
            continue
        var row := _new_management_row(disciple)
        var order_button := Button.new()
        order_button.name = "Order_%s_%s" % [str(kind), str(disciple.id)]
        order_button.text = button_text
        order_button.custom_minimum_size = Vector2(94, 34)
        order_button.add_theme_font_size_override("font_size", 11)
        order_button.pressed.connect(Callable(self, "_issue_building_order").bind(
            disciple.id,
            kind,
            target,
            "%s: %s." % [button_text, disciple.display_name]
        ))
        row.add_child(order_button)
        added += 1

    if added == 0:
        var empty := Label.new()
        empty.text = "Không có đệ tử phù hợp để ra lệnh tại đây."
        empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        empty.add_theme_font_size_override("font_size", 12)
        building_management_container.add_child(empty)

func _add_management_section_label(text: String) -> void:
    var label := Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", 12)
    label.add_theme_color_override("font_color", CINNABAR.darkened(0.12))
    building_management_container.add_child(label)

func _new_management_row(disciple: DiscipleState) -> HBoxContainer:
    var row := HBoxContainer.new()
    row.name = "Person_%s" % str(disciple.id)
    row.custom_minimum_size = Vector2(484, 54)
    row.add_theme_constant_override("separation", 6)
    building_management_container.add_child(row)

    # Keep the name Label first: existing interaction/tests resolve it by child index.
    var name := Label.new()
    name.text = disciple.display_name
    name.tooltip_text = "%s · Thể lực %.0f · %s" % [
        disciple.display_name, disciple.stamina, SectMapPresentation.action_label(disciple.current_action)
    ]
    name.clip_text = true
    name.custom_minimum_size = Vector2(132, 52)
    name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    name.add_theme_font_size_override("font_size", 12)
    name.add_theme_color_override("font_color", INK)
    row.add_child(name)

    var portrait_texture := _disciple_source_a_portrait_texture(disciple)
    if portrait_texture != null:
        var portrait := TextureRect.new()
        portrait.name = "WorkforcePortrait"
        portrait.texture = portrait_texture
        portrait.custom_minimum_size = Vector2(34, 34)
        portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
        portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
        row.add_child(portrait)
    else:
        var worker_icon := SECT_UI_ICON.new() as Control
        worker_icon.name = "WorkforceRoleIcon"
        worker_icon.set("kind", "worker")
        worker_icon.set("tint", JADE_DARK)
        worker_icon.custom_minimum_size = Vector2(30, 30)
        worker_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
        row.add_child(worker_icon)
    var profession_id := WorkforceSystem.PROF_MINING
    match selected_building:
        SectMapPresentation.DEST_LINH_FOREST:
            profession_id = WorkforceSystem.PROF_FORESTRY
        SectMapPresentation.DEST_SPIRIT_FIELD:
            profession_id = WorkforceSystem.PROF_HERBALISM
        SectMapPresentation.DEST_ALCHEMY_HALL:
            profession_id = WorkforceSystem.PROF_ALCHEMY
        SectMapPresentation.DEST_FORGE:
            profession_id = WorkforceSystem.PROF_FORGING
    var progress_info := workforce.profession_xp_progress(state, disciple, profession_id)
    var profession_level := int(progress_info.get("level", 0))
    var expected_xp := workforce.expected_profession_xp_gain(state, disciple, profession_id)
    var crop_xp_known := false
    if profession_id == WorkforceSystem.PROF_HERBALISM:
        var field_preview := BuildingSystem.new().primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
        if field_preview != null and StringName(field_preview.production_state.get("policy_mode","")) == BuildingSystem.FIELD_POLICY_FIXED:
            var fixed_crop := StringName(field_preview.production_state.get("fixed_crop_id",""))
            if spirit_crop_registry.has(fixed_crop):
                expected_xp = workforce.expected_profession_xp_gain(
                    state, disciple, profession_id, spirit_crop_registry.base_work_xp(fixed_crop),
                    BuildingSystem.new().spirit_field_xp_factor(field_preview)
                )
                crop_xp_known = true
    var skill := Label.new()
    skill.name = "WorkforceProfessionLevel"
    skill.text = "Lv%d\n%s" % [
        profession_level,
        "EXP theo cây" if profession_id == WorkforceSystem.PROF_HERBALISM and not crop_xp_known else "≈+%.2f XP" % expected_xp
    ]
    skill.custom_minimum_size = Vector2(72, 42)
    skill.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    skill.add_theme_font_size_override("font_size", 11)
    skill.add_theme_color_override("font_color", JADE_DARK)
    var threshold := float(progress_info.get("next_threshold", -1.0))
    var progress_label := "Đã đạt cấp nghề tối đa." if threshold < 0.0 else "%.1f/%.0f EXP · còn %.1f EXP lên Lv%d" % [
        float(progress_info.get("xp", 0.0)), threshold,
        float(progress_info.get("remaining_xp", 0.0)), profession_level + 1
    ]
    skill.tooltip_text = "Cấp nghề Lv%d · %s · %s\nMỏ Lv%d · Lâm Lv%d · Điền Lv%d · Đan Lv%d" % [
        profession_level, progress_label,
        "EXP theo giống gieo (+hệ số); nhận khi thu hoạch thật" if profession_id == WorkforceSystem.PROF_HERBALISM and not crop_xp_known else "≈+%.2f EXP dự kiến, khi nhận sản phẩm vào Kho" % expected_xp,
        workforce.profession_level_for_state(state, disciple, WorkforceSystem.PROF_MINING),
        workforce.profession_level_for_state(state, disciple, WorkforceSystem.PROF_FORESTRY),
        workforce.profession_level_for_state(state, disciple, WorkforceSystem.PROF_HERBALISM),
        workforce.profession_level_for_state(state, disciple, WorkforceSystem.PROF_ALCHEMY)
    ]
    row.add_child(skill)
    return row

func _assign_building_group(disciple_id: StringName, group_id: StringName, success_text: String) -> void:
    if not state.disciples.has(disciple_id):
        return
    var ok := workforce.assign_group(state, disciple_id, group_id)
    building_management_feedback = success_text if ok else "Không thể đổi phân công lúc này."
    # Rebuild outside the pressed-button signal to keep the active UI stable.
    call_deferred("_refresh_building_operation_content")

func _assign_mine_worksite(disciple_id: StringName, building_id: StringName) -> void:
    if not state.disciples.has(disciple_id):
        return
    var ok := workforce.assign_worksite(state, disciple_id, building_id)
    building_management_feedback = (
        "Đã cập nhật điểm làm việc; slot hoạt động do công trình quyết định."
        if ok else "Không thể cập nhật điểm làm việc lúc này."
    )
    call_deferred("_refresh_building_operation_content")

func _issue_building_order(disciple_id: StringName, kind: StringName, target: String, success_text: String) -> void:
    if not state.disciples.has(disciple_id):
        return
    var disciple: DiscipleState = state.disciples[disciple_id]
    if kind == WorkforceSystem.COMMAND_CULTIVATE and DiscipleRealmProgressV2.owns_v2_progression(disciple):
        # GP-02A: the Cultivation Platform must use the same preflight as the
        # authentic V2 profile, never the legacy direct-command shortcut.
        building_management_feedback = _v2_training_ui_feedback(
            _queue_v2_training("cultivation", disciple_id), "cultivation"
        )
    else:
        var ok := workforce.issue_command(state, disciple_id, kind, target, 40)
        building_management_feedback = success_text if ok else "Không thể ra lệnh lúc này."
    call_deferred("_refresh_building_operation_content")

# Display only two actual slots, rather than offering imaginary building
# capacity or a parallel character roster. Rows are backed by persisted V2
# worksite assignments and the same runtime that performs paid minutes.
func _build_body_training_management() -> void:
    var buildings := BuildingSystem.new()
    var hall := buildings.primary_building(state,BuildingSystem.TYPE_BODY_TRAINING)
    if hall == null:
        _add_management_section_label("Chưa có Rèn Thân Đường trong save hiện tại.")
        return
    var slots := buildings.worker_slots(hall)
    var holders := buildings.active_worker_ids(state,hall)
    _add_management_section_label("VỊ TRÍ LUYỆN THỂ (%d/%d)" % [holders.size(),slots])
    for index in range(slots):
        var row := HBoxContainer.new()
        row.name = "BodyTrainingSlot_%d" % (index+1)
        row.custom_minimum_size = Vector2(384,42)
        building_management_container.add_child(row)
        var line := Label.new()
        line.custom_minimum_size = Vector2(252,36)
        line.add_theme_font_size_override("font_size",12)
        line.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        if index >= holders.size():
            line.text = "Chỗ %d: Trống" % (index+1)
            row.add_child(line)
            continue
        var disciple_id: StringName = holders[index]
        var disciple: DiscipleState = state.disciples[disciple_id]
        var phase := "Đang luyện" if disciple.current_action == &"TRAIN_BODY" else "Đã giữ chỗ"
        line.text = "Chỗ %d: %s · %s" % [index+1,disciple.display_name,phase]
        line.clip_text = true
        row.add_child(line)
        var release := Button.new()
        release.name = "BodyTrainingRelease_%s" % str(disciple_id)
        release.text = "Trả chỗ"
        release.custom_minimum_size = Vector2(112,34)
        release.pressed.connect(Callable(self,"_release_body_training_from_building").bind(disciple_id))
        row.add_child(release)

    _add_management_section_label("PHÂN CÔNG ĐỆ TỬ V2")
    var ids: Array = state.disciples.keys()
    ids.sort()
    var shown := 0
    for raw_id in ids:
        if shown >= 12:
            break
        var member: DiscipleState = state.disciples[raw_id]
        if not DiscipleRealmProgressV2.owns_v2_progression(member):
            continue
        if holders.has(member.id):
            continue
        if member.region_id != &"sect":
            continue
        var row := HBoxContainer.new()
        row.name = "BodyTrainingCandidate_%s" % str(member.id)
        row.custom_minimum_size = Vector2(384,40)
        building_management_container.add_child(row)
        var label := Label.new()
        label.text = member.display_name
        label.custom_minimum_size = Vector2(252,34)
        label.clip_text = true
        label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        label.add_theme_font_size_override("font_size",12)
        row.add_child(label)
        var start := Button.new()
        start.name = "BodyTrainingAssign_%s" % str(member.id)
        start.text = "Rèn thân"
        start.custom_minimum_size = Vector2(112,34)
        start.disabled = holders.size() >= slots or hall.status != BuildingSystem.STATUS_ACTIVE
        start.pressed.connect(Callable(self,"_start_body_training_from_building").bind(member.id))
        row.add_child(start)
        shown += 1
    if shown == 0:
        _add_management_section_label("Không có đệ tử V2 rảnh vị trí trong Tông Môn.")
    elif shown >= 12:
        _add_management_section_label("Đang hiển thị 12 đệ tử đầu; danh sách lớn sẽ bổ sung lọc/tìm kiếm.")

func _start_body_training_from_building(disciple_id: StringName) -> void:
    var result := _queue_v2_training("body",disciple_id)
    building_management_feedback = _v2_training_ui_feedback(result,"body")
    _refresh_building_operation_content()

func _release_body_training_from_building(disciple_id: StringName) -> void:
    var result := DiscipleBodyTrainingFacilityV2.release_slot(state,disciple_id)
    building_management_feedback = (
        "Đã trả vị trí Rèn Thân; không trừ hoặc hoàn phí phút đã luyện."
        if bool(result.get("ok",false))
        else _v2_training_ui_feedback(result,"body")
    )
    _refresh_building_operation_content()

func _body_training_operation_text() -> String:
    var buildings := BuildingSystem.new()
    var hall := buildings.primary_building(state,BuildingSystem.TYPE_BODY_TRAINING)
    if hall == null:
        return "Công trình chưa được khởi tạo trong runtime V2 hiện tại."
    var holders := buildings.active_worker_ids(state,hall)
    var running := 0
    var status_lines: Array[String] = []
    for disciple_id in holders:
        if not state.disciples.has(disciple_id):
            continue
        var disciple: DiscipleState = state.disciples[disciple_id]
        if disciple.current_action == &"TRAIN_BODY":
            running += 1
        var last: Dictionary = disciple.last_decision.get("v2_body_training_result",{})
        var evidence := ""
        if bool(last.get("ok",false)) and last.has("gained"):
            evidence = " · lượt gần nhất +%.0f EXP" % float(last["gained"])
        elif last.has("reason"):
            evidence = " · %s" % _v2_training_ui_feedback(last,"body")
        status_lines.append("• %s: %s%s" % [
            disciple.display_name,SectMapPresentation.action_label(disciple.current_action),evidence
        ])
    var xp_text := str(int(DiscipleBodyTrainingFacilityV2.BASE_BODY_XP_PER_MINUTE))
    if xp_text.length() > 3:
        xp_text = xp_text.insert(xp_text.length() - 3, ".")
    return (
        "RÈN THÂN ĐƯỜNG · Lv%d\n"
        + "Vị trí: %d/%d · đang luyện: %d\n"
        + "Linh Thạch Tông Môn: %d\n"
        + "Phí: %d Linh Thạch / phút mô phỏng\n"
        + "EXP nền: %s EXP/phút (+0,20%% mỗi điểm Căn Cốt)\n"
        + "Lượt đã thanh toán: %d · Linh Thạch đã tiêu: %d\n\n"
        + "ĐỆ TỬ ĐANG PHÂN CÔNG\n%s\n\n"
        + "Bấm Rèn thân chỉ xếp lệnh; phí/EXP phát sinh khi đủ một phút hợp lệ."
    ) % [
        hall.level,holders.size(),buildings.worker_slots(hall),running,
        state.sect.spirit_stones,
        DiscipleBodyTrainingFacilityV2.STONE_COST_PER_MINUTE,
        xp_text,
        int(hall.production_state.get("paid_training_minutes",0)),
        int(hall.production_state.get("spent_spirit_stones",0)),
        "• Trống" if status_lines.is_empty() else "\n".join(status_lines)
    ]

func _building_operation_text(destination: StringName) -> String:
    match destination:
        SectMapPresentation.DEST_MAIN_HALL:
            return _main_hall_operation_text()
        SectMapPresentation.DEST_MINE:
            return _mine_operation_text()
        SectMapPresentation.DEST_LINH_FOREST:
            return _linh_forest_operation_text()
        SectMapPresentation.DEST_ALCHEMY_HALL:
            return _alchemy_operation_text()
        SectMapPresentation.DEST_SPIRIT_FIELD:
            return _spirit_field_operation_text()
        SectMapPresentation.DEST_FORGE:
            return _forge_operation_text()
        SectMapPresentation.DEST_CULTIVATION:
            return _cultivation_operation_text()
        SectMapPresentation.DEST_BODY_TRAINING:
            return _body_training_operation_text()
        SectMapPresentation.DEST_RESIDENCE:
            return _residence_operation_text()
        SectMapPresentation.DEST_MEDICINE:
            return _medicine_operation_text()
        SectMapPresentation.DEST_WAREHOUSE:
            return _warehouse_operation_text()
        SectMapPresentation.DEST_GUIDANCE:
            return _guidance_operation_text()
        SectMapPresentation.DEST_GATE:
            return _gate_operation_text()
        _:
            return "Sân trung tâm. Không có dữ liệu quản lý riêng."

func _guidance_operation_text() -> String:
    var platform := BuildingSystem.new().primary_building(state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
    if platform == null:
        return "Dẫn Tiên Đài chưa tồn tại trong trạng thái hiện tại."
    var snapshot := recruitment_system.guidance_state_snapshot(state)
    return (
        "TUYỂN MỘ\n"
        + "Đệ tử: %d / %d\n"
        + "Ứng viên đang chờ: %d\n"
        + "Chiêu Mộ Lệnh: %d\n"
        + "Mục tiêu tiếp nhận hôm nay: %d · Đã tạo: %d\n\n"
        + "Nhận hoặc từ chối ứng viên trực tiếp tại đây. Mọi giới hạn sức chứa và hồ sơ V2 do RecruitmentSystem quyết định."
    ) % [
        state.disciples.size(),
        state.sect.disciple_capacity,
        state.recruitment_candidates.size(),
        state.sect.disciple_recruitment_tokens,
        int(snapshot.get("daily_arrival_target", 0)),
        int(snapshot.get("daily_arrivals_generated", 0))
    ]

func _main_hall_operation_text() -> String:
    return (
        "TỔNG QUAN\n"
        + "Đệ tử: %d / %d\n"
        + "Ngân khố: %d\n"
        + "Linh Thạch: %d\n\n"
        + "CHÍNH SÁCH HIỆN TẠI\n"
        + "Lao động: %s\n"
        + "Hậu cần: %s\n"
        + "Trang bị: %s\n\n"
        + "Chọn một hướng ưu tiên để điều chỉnh cách tông môn tự vận hành."
        + ("\n\nKINH TẾ V1: ĐANG BẬT · Lương mẻ đã thanh toán theo giao dịch thực." if state.sect.economy_a_enabled else "")
    ) % [
        state.disciples.size(), state.sect.disciple_capacity,
        state.sect.treasury, state.sect.spirit_stones,
        _work_policy_label(state.sect.work_policy),
        _needs_priority_label(state.sect.needs_priority),
        _equipment_policy_label(state.sect.equipment_policy)
    ]

func _build_alchemy_management() -> void:
    var hall := _selected_operation_building()
    if hall == null or hall.building_type != BuildingSystem.TYPE_ALCHEMY_HALL:
        hall = BuildingSystem.new().primary_building(state,BuildingSystem.TYPE_ALCHEMY_HALL)
    if hall == null:
        _add_management_section_label("LUYỆN ĐAN ĐIỆN CHƯA SẴN SÀNG")
        return
    # Backend already had paid upgrade authority; the player must actually
    # be able to reach it before the recipe and workforce scroll area.
    _build_worksite_upgrade_control(hall)
    _build_work_management(WorkforceSystem.PROF_ALCHEMY, &"alchemy_crew", "Đội Luyện Đan", "Luyện đan")
    _add_management_section_label("ĐAN PHƯƠNG · HỒI XUÂN / TỤ KHÍ")
    var enabled := bool(hall.production_state.get("recipe_enabled", true))
    var toggle := Button.new()
    toggle.name = "AlchemyRecipeToggle"
    toggle.text = "Tắt tự luyện" if enabled else "Bật tự luyện"
    toggle.custom_minimum_size = Vector2(170, 34)
    toggle.pressed.connect(Callable(self, "_set_alchemy_recipe_enabled_from_ui").bind(hall.id, not enabled))
    building_management_container.add_child(toggle)

    if not SX01PillPolicy.active(state):
        var enable_policy := Button.new()
        enable_policy.name = "SX01Enable"
        enable_policy.text = "Khai mở chính sách Đan Dược (V2)"
        enable_policy.custom_minimum_size = Vector2(350, 34)
        enable_policy.pressed.connect(_sx01_enable_from_ui)
        building_management_container.add_child(enable_policy)
        # Legacy saves keep their original standing HXD recipe until opt-in.
        return
    var policy := state.sect.sx01_pill_policy
    var plan := SX01PillPolicy.stock_plan(state, hall)
    var info := Label.new()
    info.name = "SX01PillStock"
    info.text = "Hồi Xuân: %d +%d / %d     Tụ Khí: %d +%d / %d" % [
        int(plan["held_hxd"]), int(plan["pending_hxd"]), int(policy["target_hoi_xuan_dan"]),
        int(plan["held_tqd"]), int(plan["pending_tqd"]), int(policy["target_tu_khi_dan"])
    ]
    info.custom_minimum_size = Vector2(384, 26)
    info.tooltip_text = "Mức đích chỉ áp dụng khi chọn Đan phương: THEO NHU CẦU."
    info.add_theme_font_size_override("font_size", 12)
    building_management_container.add_child(info)

    var auto_button := Button.new()
    auto_button.name = "SX01AutoProduction"
    auto_button.text = "Tự cân đối kho: BẬT" if bool(policy["auto_production"]) else "Tự cân đối kho: TẮT"
    auto_button.tooltip_text = "Chế độ cân đối chỉ tác động khi Đan phương là THEO NHU CẦU. Muốn dừng mọi mẻ mới, dùng nút Tắt tự luyện ở trên."
    auto_button.pressed.connect(Callable(self, "_sx01_configure_from_ui").bind("auto_production", not bool(policy["auto_production"])))
    building_management_container.add_child(auto_button)
    var mode := Button.new()
    mode.name = "SX01RecipeMode"
    mode.text = "Đan phương: THEO NHU CẦU" if str(policy["recipe_mode"]) == "demand" else "Đan phương: CỐ ĐỊNH"
    mode.pressed.connect(Callable(self, "_sx01_configure_from_ui").bind("recipe_mode", "fixed" if str(policy["recipe_mode"]) == "demand" else "demand"))
    building_management_container.add_child(mode)

    for pill_id in [&"hoi_xuan_dan", &"tu_khi_dan"]:
        var button := Button.new()
        button.name = "SX01Recipe_HXD" if pill_id == &"hoi_xuan_dan" else "SX01Recipe_TQD"
        button.text = "Cố định: Hồi Xuân Đan" if pill_id == &"hoi_xuan_dan" else "Cố định: Tụ Khí Đan"
        button.custom_minimum_size = Vector2(170, 32)
        button.pressed.connect(Callable(self, "_sx01_select_recipe_from_ui").bind(hall.id, pill_id))
        building_management_container.add_child(button)
    _add_management_section_label("ĐAN THEO CẢNH GIỚI · PHẨM THEO ĐAN SƯ")
    for new_recipe in MedicineCatalogueV2.authored_recipes():
        var recipe := AlchemyRecipeRegistry.new().definition(new_recipe)
        var button := Button.new()
        button.name = "SX02Recipe_%s" % str(new_recipe)
        button.text = "%s · Điện Lv%d / Nghề Lv%d" % [
            str(recipe.get("name", new_recipe)),
            int(recipe.get("required_hall_level", 1)),
            int(recipe.get("required_profession_level", 0))
        ]
        button.custom_minimum_size = Vector2(360, 32)
        button.disabled = hall.level < int(recipe.get("required_hall_level", 1))
        button.tooltip_text = MedicineResourceSourceV1.guidance_text(new_recipe) \
            + "\nPhẩm được xác định bởi Đan Sư và cấp Điện khi bắt đầu mẻ; không cấp tài nguyên miễn phí."
        button.pressed.connect(Callable(self, "_sx01_select_recipe_from_ui").bind(hall.id, new_recipe))
        building_management_container.add_child(button)
    # Mobile landscape has no hover. Show the selected recipe's actual
    # Field/instanced-map source in the management panel, not tooltip only.
    var selected_recipe := StringName(hall.production_state.get("recipe_id", "hoi_xuan_dan"))
    var route_hint := Label.new()
    route_hint.name = "AlchemySelectedRecipeSources"
    route_hint.text = MedicineResourceSourceV1.guidance_text(selected_recipe)
    route_hint.custom_minimum_size = Vector2(360, 0)
    route_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    route_hint.add_theme_font_size_override("font_size", 12)
    building_management_container.add_child(route_hint)
    if not MedicineCatalogueV2.parse_recipe(selected_recipe).is_empty():
        _add_management_section_label("PHẨM ĐAN · CHỌN Q1–Q4 CHO MẺ MỚI")
        var current_grade := int(hall.production_state.get("v57_selected_quality",0))
        for grade in range(1,5):
            var pick := Button.new()
            pick.name = "V57AlchemyQuality_Q%d" % grade
            pick.text = ("✓ " if current_grade == grade else "")+"Q%d" % grade
            pick.custom_minimum_size = Vector2(92,30)
            pick.disabled = hall.level < int(BuildingSystem.V57_QUALITY_HALL_LEVEL[grade-1])
            pick.tooltip_text = "Phẩm Q%d cần Điện Lv%d, nghề Lv%d và nguyên liệu xúc tác thật trong Kho." % [
                grade,int(BuildingSystem.V57_QUALITY_HALL_LEVEL[grade-1]),
                int(BuildingSystem.V57_QUALITY_PROF_LEVEL[grade-1])
            ]
            pick.pressed.connect(Callable(self,"_v57_alchemy_quality_from_ui").bind(hall.id,grade))
            building_management_container.add_child(pick)
    for pill_key in ["target_hoi_xuan_dan", "target_tu_khi_dan"]:
        for delta in [-6, 6]:
            var button := Button.new()
            button.name = "SX01_%s_%s" % [pill_key, "Less" if delta < 0 else "More"]
            button.text = "%s %s6 viên" % ["Hồi Xuân" if pill_key == "target_hoi_xuan_dan" else "Tụ Khí", "−" if delta < 0 else "+"]
            button.custom_minimum_size = Vector2(164, 30)
            button.pressed.connect(Callable(self, "_sx01_adjust_target_from_ui").bind(pill_key, delta))
            building_management_container.add_child(button)

func _v57_alchemy_quality_from_ui(hall_id: StringName, grade: int) -> void:
    var result := BuildingSystem.new().set_alchemy_quality(state,hall_id,grade)
    building_management_feedback = (
        "Đã chọn Q%d cho mẻ mới; mẻ đang chạy giữ nguyên sản phẩm." % grade
        if bool(result.get("ok",false)) else "Không chọn được phẩm: "+str(result.get("reason",""))
    )
    if bool(result.get("ok",false)):
        _autosave_runtime()
    _refresh_building_operation_content()

func _sx01_enable_from_ui() -> void:
    SX01PillPolicy.install_new_game(state)
    building_management_feedback = "Đã bật chính sách Tông Chủ." if SX01PillPolicy.active(state) else "Cần Kho và Tu Vi V2 hợp lệ."
    _autosave_runtime()
    _refresh_building_operation_content()

func _sx01_configure_from_ui(key: String, value: Variant) -> void:
    var result := SX01PillPolicy.configure(state, key, value)
    building_management_feedback = "Đã điều chỉnh chính sách." if bool(result.get("ok",false)) else str(result.get("reason","Không thể đổi chính sách."))
    if bool(result.get("ok",false)):
        _autosave_runtime()
    _refresh_building_operation_content()

func _sx01_adjust_target_from_ui(key: String, delta: int) -> void:
    var current := int(state.sect.sx01_pill_policy.get(key, 0))
    _sx01_configure_from_ui(key, clampi(current + delta, 0, 1000))

func _sx01_select_recipe_from_ui(hall_id: StringName, pill_id: StringName) -> void:
    var ok := BuildingSystem.new().set_alchemy_recipe(state, hall_id, pill_id)
    building_management_feedback = "Đã cố định Đan phương, các mẻ đang luyện giữ nguyên." if ok else "Không thể chọn Đan phương."
    if ok:
        _autosave_runtime()
    _refresh_building_operation_content()

func _set_alchemy_recipe_enabled_from_ui(hall_id: StringName, enabled: bool) -> void:
    var ok := BuildingSystem.new().set_alchemy_recipe_enabled(state, hall_id, enabled)
    building_management_feedback = ("Đã bật Đan Lô." if enabled else "Đã tắt mẻ mới; mẻ đang luyện vẫn hoàn thành.") if ok else "Không thể đổi chính sách Luyện Đan."
    if ok:
        _autosave_runtime()
    _refresh_building_operation_content()

# Compact, stock-driven, no new medicine clock or HUD action authority.
func _build_sx02_medicine_controls() -> void:
    if not SX01PillPolicy.active(state):
        return
    var warehouse := WarehouseSystem.new()
    var available: Array[StringName] = []
    for item_id in MedicineCatalogueV2.all_item_ids():
        var info := MedicineCatalogueV2.definition(item_id)
        # Breakthrough Pills are consumed only by the real Tu Vi gate
        # transaction, never through the generic manual XP/heal button.
        if str(info.get("pill_family","")) == MedicineCatalogueV2.FAMILY_BREAK:
            continue
        if warehouse.available_quantity(state, item_id) > 0:
            available.append(item_id)
    if available.is_empty():
        return
    _add_management_section_label("ĐAN DƯỢC CẢNH GIỚI / PHẨM · DÙNG THỦ CÔNG")
    var picker := OptionButton.new()
    picker.name = "SX02MedicinePicker"
    picker.custom_minimum_size = Vector2(384, 32)
    var selected_index := 0
    for item_id in available:
        var index := picker.item_count
        var pill_info := MedicineCatalogueV2.definition(item_id)
        picker.add_item("%s · còn %d" % [pill_info.get("name", item_id), warehouse.available_quantity(state, item_id)])
        picker.set_item_metadata(index, str(item_id))
        if item_id == sx02_selected_medicine:
            selected_index = index
    picker.select(selected_index)
    sx02_selected_medicine = StringName(picker.get_item_metadata(selected_index))
    picker.item_selected.connect(func(index: int) -> void:
        sx02_selected_medicine = StringName(picker.get_item_metadata(index))
        _refresh_building_operation_content()
    )
    building_management_container.add_child(picker)

    var selected_data := MedicineCatalogueV2.definition(sx02_selected_medicine)
    var effects := Label.new()
    effects.name = "SX02MedicinePotency"
    var pill_family := str(selected_data.get("pill_family",""))
    var effect_name := "+Tu Vi"
    if pill_family == MedicineCatalogueV2.FAMILY_HEAL:
        effect_name = "+HP"
    elif pill_family == MedicineCatalogueV2.FAMILY_BODY:
        effect_name = "+Luyện Thể"
    effects.text = "%s %d · Bão hòa %d" % [
        effect_name,int(selected_data.get("potency",0)),
        int(selected_data.get("satiety_cost",0))
    ]
    effects.custom_minimum_size = Vector2(384, 24)
    building_management_container.add_child(effects)

    var shown := 0
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.region_id != &"sect" or not DiscipleRealmProgressV2.progression_ready(disciple):
            continue
        if shown >= 8:
            break
        var row := _new_management_row(disciple)
        var use := Button.new()
        use.name = "SX02Use_%s" % str(disciple.id)
        use.text = "Dùng đan đã chọn"
        use.custom_minimum_size = Vector2(160, 30)
        use.disabled = B3PillSatietyV1.manual_use_is_activity_blocked(state, disciple, sx02_selected_medicine) or warehouse.available_quantity(state, sx02_selected_medicine) < 1
        use.tooltip_text = "B3 sẽ kiểm tra nghề đang bận, bão hòa, kho và cửa ải Tu Vi."
        use.pressed.connect(Callable(self, "_sx01_use_pill_from_ui").bind(disciple.id, sx02_selected_medicine))
        row.add_child(use)
        shown += 1

func _build_healing_pill_controls() -> void:
    _build_sx02_medicine_controls()
    _add_management_section_label("HỒI XUÂN ĐAN")
    var available := WarehouseSystem.new().available_quantity(state, NeedsSystem.HEALING_PILL_ID)
    var ids: Array = state.disciples.keys()
    ids.sort()
    var shown := 0
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.region_id != &"sect" or disciple.hp >= disciple.max_hp:
            continue
        var row := _new_management_row(disciple)
        var use := Button.new()
        use.name = "UsePill_%s" % str(disciple.id)
        use.text = "Dùng đan"
        use.custom_minimum_size = Vector2(92, 34)
        use.disabled = available <= 0
        if use.disabled:
            use.tooltip_text = "Không có Hồi Xuân Đan có thể dùng trong Kho."
        use.pressed.connect(Callable(self, "_use_healing_pill_from_ui").bind(disciple.id))
        row.add_child(use)
        shown += 1
    if shown == 0:
        _add_management_section_label("Không có đệ tử bị thương đang ở trong tông.")
    if not SX01PillPolicy.active(state):
        return
    _add_management_section_label("TỰ DÙNG · BẢO HỘ KHO")
    var policy := state.sect.sx01_pill_policy
    for pill_key in ["auto_use_hoi_xuan_dan", "auto_use_tu_khi_dan"]:
        var button := Button.new()
        button.name = "SX01Toggle_%s" % pill_key
        button.text = "%s: %s" % [
            "Tự hồi phục" if pill_key == "auto_use_hoi_xuan_dan" else "Tự bổ Tu Vi",
            "BẬT" if bool(policy.get(pill_key,false)) else "TẮT"
        ]
        button.pressed.connect(Callable(self, "_sx01_configure_from_ui").bind(pill_key, not bool(policy.get(pill_key,false))))
        building_management_container.add_child(button)
    var threshold := Button.new()
    threshold.name = "SX01HealThreshold"
    threshold.text = "Tự hồi phục dưới %d%% HP" % int(policy.get("heal_hp_percent",60))
    threshold.pressed.connect(_sx01_cycle_heal_threshold_from_ui)
    building_management_container.add_child(threshold)
    var quota := Button.new()
    quota.name = "SX01TuViQuota"
    quota.text = "Tự dùng Tụ Khí: tối đa %d viên/người/ngày" % int(policy.get("auto_tu_khi_per_day",2))
    quota.pressed.connect(_sx01_cycle_tuvi_quota_from_ui)
    building_management_container.add_child(quota)
    var medical := Button.new()
    medical.name = "SX01MedicalReserve"
    medical.text = "Dự trữ mềm Hồi Xuân: %d viên" % int(policy.get("medical_soft_reserve",2))
    medical.pressed.connect(_sx01_cycle_soft_reserve_from_ui)
    building_management_container.add_child(medical)
    _add_management_section_label("TỤ KHÍ ĐAN · DÙNG THỦ CÔNG")
    var shown_tuvi := 0
    for raw_id in state.disciples.keys():
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.region_id != &"sect" or not DiscipleRealmProgressV2.progression_ready(disciple):
            continue
        if shown_tuvi >= 12:
            break
        var row := _new_management_row(disciple)
        var use := Button.new()
        use.name = "SX01UseTuKhi_%s" % str(disciple.id)
        use.text = "Tụ Khí +10.000"
        use.disabled = WarehouseSystem.new().available_quantity(state, &"tu_khi_dan") <= 0 or B3MedicalAutoplayV1.busy(state, disciple)
        use.tooltip_text = "Kho khóa/dự trữ hoặc đệ tử đang bận." if use.disabled else "Tiêu 1 Tụ Khí Đan; B3 kiểm tra đủ bão hòa và không vượt đại cảnh."
        use.pressed.connect(Callable(self, "_sx01_use_pill_from_ui").bind(disciple.id, &"tu_khi_dan"))
        row.add_child(use)
        var priority := Button.new()
        priority.name = "SX01Priority_%s" % str(disciple.id)
        var marked: Dictionary = policy.get("priority_tuvi_ids", {})
        priority.text = "ƯU TIÊN" if bool(marked.get(str(disciple.id),false)) else "Chọn ưu tiên"
        priority.custom_minimum_size = Vector2(104, 30)
        priority.pressed.connect(Callable(self, "_sx01_toggle_priority_from_ui").bind(disciple.id))
        row.add_child(priority)
        shown_tuvi += 1

func _sx01_cycle_heal_threshold_from_ui() -> void:
    var choices := [40, 50, 60, 70, 80]
    var current := int(state.sect.sx01_pill_policy.get("heal_hp_percent", 60))
    var index := choices.find(current)
    _sx01_configure_from_ui("heal_hp_percent", choices[(index + 1) % choices.size()])

func _sx01_cycle_tuvi_quota_from_ui() -> void:
    var choices := [0, 1, 2, 3, 5]
    var current := int(state.sect.sx01_pill_policy.get("auto_tu_khi_per_day", 2))
    var index := choices.find(current)
    _sx01_configure_from_ui("auto_tu_khi_per_day", choices[(index + 1) % choices.size()])

func _sx01_cycle_soft_reserve_from_ui() -> void:
    var choices := [0, 2, 4, 6]
    var current := int(state.sect.sx01_pill_policy.get("medical_soft_reserve", 2))
    var index := choices.find(current)
    _sx01_configure_from_ui("medical_soft_reserve", choices[(index + 1) % choices.size()])

func _sx01_toggle_priority_from_ui(disciple_id: StringName) -> void:
    var flags: Dictionary = state.sect.sx01_pill_policy.get("priority_tuvi_ids", {})
    var selected := not bool(flags.get(str(disciple_id), false))
    var result := SX01PillPolicy.set_tuvi_priority(state, disciple_id, selected)
    building_management_feedback = "Đã đổi ưu tiên Tu Vi." if bool(result.get("ok",false)) else "Không thể đổi ưu tiên Tu Vi."
    if bool(result.get("ok",false)):
        _autosave_runtime()
    _refresh_building_operation_content()

func _use_healing_pill_from_ui(disciple_id: StringName) -> void:
    if not state.disciples.has(disciple_id):
        return
    var disciple: DiscipleState = state.disciples[disciple_id]
    if DiscipleRealmProgressV2.progression_ready(disciple) and runtime_session != null:
        _sx01_use_pill_from_ui(disciple_id, &"hoi_xuan_dan")
        return
    var before := disciple.hp
    var ok := needs_system.use_healing_pill(state, disciple)
    building_management_feedback = (
        "Đã dùng 1 Hồi Xuân Đan cho %s: HP %.0f → %.0f." % [disciple.display_name, before, disciple.hp]
        if ok else "Không thể dùng Hồi Xuân Đan cho mục tiêu này."
    )
    if ok:
        _autosave_runtime()
    _refresh_building_operation_content()

func _sx01_use_pill_from_ui(disciple_id: StringName, pill_id: StringName) -> void:
    if runtime_session == null or runtime_session.owner == null or not state.disciples.has(disciple_id):
        building_management_feedback = "Chưa có phiên Tu Vi V2 hợp lệ."
        _refresh_building_operation_content()
        return
    var disciple: DiscipleState = state.disciples[disciple_id]
    var sequence := B3PillSatietyV1.next_sequence(disciple)
    var medicine := MedicineCatalogueV2.definition(pill_id)
    var pill_name := "Hồi Xuân Đan" if pill_id == &"hoi_xuan_dan" else ("Tụ Khí Đan" if pill_id == &"tu_khi_dan" else str(medicine.get("name",pill_id)))
    # Use the existing durable owner boundary, not UI-side HP/EXP edits.
    var result := B3MedicalAutoplayV1.use_pill(runtime_session.owner, disciple_id, pill_id, sequence)
    building_management_feedback = (
        "Đã dùng %s cho %s (biên nhận %d)." % [pill_name,disciple.display_name,sequence]
        if bool(result.get("ok",false))
        else "Không thể dùng %s: %s" % [pill_name,str(result.get("reason","không đủ điều kiện"))]
    )
    _refresh_building_operation_content()

func _alchemy_operation_text() -> String:
    var buildings := BuildingSystem.new()
    var hall := buildings.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    if hall == null:
        return "Luyện Đan Điện chưa tồn tại."
    var registry := AlchemyRecipeRegistry.new()
    var resources := ResourceRegistry.new()
    var jobs := buildings.alchemy_jobs(state, hall)
    var current_recipe := StringName(hall.production_state.get("recipe_id", "hoi_xuan_dan"))
    var demand_mode := SX01PillPolicy.active(state) and str(state.sect.sx01_pill_policy.get("recipe_mode", "")) == "demand"
    var plan_waiting := false
    if demand_mode:
        var planned_recipe := SX01PillPolicy.planned_recipe(state,hall)
        if planned_recipe != &"":
            current_recipe = planned_recipe
        else:
            plan_waiting = true
    var recipe_data := registry.definition(current_recipe)
    var recipe_name := str(recipe_data.get("name", "Đan phương chưa khả dụng"))
    var status := "TỰ ĐỘNG · CHỜ ĐIỀU KIỆN" if plan_waiting else ("TỰ ĐỘNG" if demand_mode else "CỐ ĐỊNH")

    var ingredient_lines: Array[String] = []
    var recipe_inputs := buildings.sx_v55_common_requirements(state,registry.inputs(current_recipe))
    var ingredient_ids: Array = recipe_inputs.keys()
    ingredient_ids.sort()
    var warehouse_system := WarehouseSystem.new()
    for raw_id in ingredient_ids:
        var resource_id := StringName(raw_id)
        var need := int(recipe_inputs.get(raw_id, recipe_inputs.get(str(raw_id), 0)))
        var total := warehouse_system.quantity(state, resource_id)
        var available := warehouse_system.available_quantity(state, resource_id)
        ingredient_lines.append("• %s ×%d · Kho %s · dùng được %s" % [
            resources.display_name(resource_id), need,
            _compact_number(total), _compact_number(available)
        ])
    if ingredient_lines.is_empty():
        ingredient_lines.append("• Chưa có công thức hợp lệ.")

    var output_id := registry.output_resource_id(current_recipe)
    var output_quantity := registry.output_quantity(current_recipe)
    var output_name := resources.display_name(output_id) if output_id != &"" else "Chưa có sản phẩm"
    var output_stock := warehouse_system.quantity(state, output_id) if output_id != &"" else 0
    var output_available := warehouse_system.available_quantity(state, output_id) if output_id != &"" else 0
    var output_effect := _alchemy_product_effect_text(current_recipe, output_id)
    var is_v2_recipe := not MedicineCatalogueV2.parse_recipe(current_recipe).is_empty()
    var output_header := "SẢN PHẨM CƠ SỞ" if is_v2_recipe else "SẢN PHẨM"
    var stock_caption := "Kho phẩm cơ sở" if is_v2_recipe else "Kho sản phẩm"
    var quality_note := "Mẻ đang luyện giữ nguyên công thức đã chọn; sản phẩm chỉ nhập Kho khi hoàn thành."
    if is_v2_recipe:
        quality_note = "Phẩm của đan V2 được chốt theo Đan Sư và cấp Điện khi bắt đầu mẻ; vật phẩm thực tế hiện trong Kho."

    var lines: Array[String] = []
    for raw_job in jobs:
        var job: Dictionary = raw_job
        var worker_id := StringName(job.get("worker_id", ""))
        var name: String = state.disciples[worker_id].display_name if state.disciples.has(worker_id) else str(worker_id)
        var job_output_id := StringName(job.get("output_resource_id", output_id))
        var job_output_name := resources.display_name(job_output_id) if job_output_id != &"" else output_name
        lines.append("• %s · %s ×%d · còn %d phút" % [
            name, job_output_name, maxi(int(job.get("output_quantity", output_quantity)), 0),
            maxi(int(job.get("finish_tick", state.tick)) - state.tick, 0)
        ])

    return (
        "LUYỆN ĐAN ĐIỆN · Lv%d\n"
        + "Đan Sư: %d/%d · Mẻ đang luyện: %d\n"
        + "Đan phương: %s · %s\n"
        + "MỖI MẺ CẦN\n%s\n"
        + "%s: %s ×%d\n"
        + "%s\n"
        + "%s: %s · dùng được %s\n"
        + "%s\n\n"
        + "MẺ ĐANG LUYỆN\n%s"
    ) % [
        hall.level, buildings.active_worker_ids(state, hall).size(), buildings.worker_slots(hall),
        jobs.size(), recipe_name, status, "\n".join(ingredient_lines),
        output_header, output_name, output_quantity, output_effect, stock_caption,
        _compact_number(output_stock), _compact_number(output_available), quality_note,
        "Không có" if lines.is_empty() else "\n".join(lines)
    ]


func _alchemy_product_effect_text(recipe_id: StringName, output_id: StringName) -> String:
    if recipe_id == AlchemyRecipeRegistry.RECIPE_HOI_XUAN_DAN:
        return "Công dụng: hồi tối đa %d HP." % int(NeedsSystem.HEALING_PILL_HP)
    if recipe_id == AlchemyRecipeRegistry.RECIPE_TU_KHI_DAN:
        return "Công dụng: tăng 10.000 Tu Vi theo đan phương Tụ Khí hiện hành."
    var medicine := MedicineCatalogueV2.definition(output_id)
    if medicine.is_empty():
        return "Công dụng được ghi trên vật phẩm sau khi nhập Kho."
    var potency := maxi(int(medicine.get("potency", 0)), 0)
    var family := StringName(medicine.get("pill_family", ""))
    var quality_name := str(medicine.get("quality_name", "Hạ Phẩm"))
    var effect := "tăng %d Tu Vi" % potency
    if family == MedicineCatalogueV2.FAMILY_HEAL:
        effect = "hồi tối đa %d HP" % potency
    elif family == MedicineCatalogueV2.FAMILY_BODY:
        effect = "tăng %d EXP Luyện Thể" % potency
    elif family == MedicineCatalogueV2.FAMILY_BREAK:
        effect = "cộng %d điểm phần trăm xác suất đột phá Tu Vi" % potency
    return "Công dụng %s cơ sở: %s; phẩm thực tế do Đan Sư và cấp Điện chốt khi bắt đầu." % [quality_name, effect]


func _linh_forest_operation_text() -> String:
    var members := _disciples_in_work_group(&"forestry_crew")
    var building_system := BuildingSystem.new()
    var forest := _selected_operation_building()
    if forest == null or forest.building_type != BuildingSystem.TYPE_LINH_FOREST:
        forest = building_system.primary_building(state, BuildingSystem.TYPE_LINH_FOREST)
    var active_ids: Array[StringName] = []
    var slots := 0
    if forest != null:
        active_ids = building_system.active_worker_ids(state, forest)
        slots = building_system.worker_slots(forest)

    var lines: Array[String] = []
    for disciple_value in members:
        var disciple: DiscipleState = disciple_value
        var level := workforce.profession_level_for_state(state, disciple, WorkforceSystem.PROF_FORESTRY)
        lines.append("• %s · Lv%d · %s" % [
            disciple.display_name,
            level,
            _resource_job_member_status(disciple, WorkforceSystem.PROF_FORESTRY, active_ids.has(disciple.id),forest)
        ])
    if lines.is_empty():
        lines.append("• Chưa có thành viên Đội Lâm Nghiệp")
    var batches := 0 if forest == null else maxi(int(forest.metrics.get("production_batches",0)),0)
    var units := 0 if forest == null else maxi(int(forest.metrics.get("units_produced",0)),0)

    var selected_material := building_system.forest_selected_material(forest)
    var selected_name := ResourceRegistry.new().display_name(selected_material)
    var next_batch := 0 if forest == null else building_system.forest_material_batch_units(forest,selected_material)
    if forest != null:
        var bulk_plan := building_system.sx_v55_plan(state,forest,selected_material)
        if not bulk_plan.is_empty():
            next_batch = maxi(1,int(round(float(bulk_plan.get("yield",0)) * (
                1.0 + 0.005 * float(maxi(forest.level-1,0))))))
    return (
        "SẢN XUẤT\n"
        + "Linh Lâm Lv%d\n"
        + "%s tồn (dùng): %s\n"
        + "Mẻ kế tiếp: ×%d %s\n"
        + "Tổng nhập: %d đơn vị · %d lượt (có thể gồm nhiều loại)\n"
        + "Chỗ hoạt động: %d/%d\n"
        + "Đang làm Lâm Nghiệp: %d\n"
        + "Thành viên đội: %d\n\n"
        + "NHÂN SỰ\n%s\n\n"
        + "Lượt mới theo vật liệu đã chọn; mẻ đang chạy giữ output cũ."
    ) % [
        0 if forest == null else forest.level,
        selected_name,_warehouse_pair(selected_material),
        next_batch,selected_name,
        units,batches,active_ids.size(),slots,_count_action(&"WORK_FORESTRY"),members.size(),
        "\n".join(lines)
    ]

func _resource_job_member_status(disciple: DiscipleState, profession_id: StringName, has_active_slot: bool, building: BuildingState = null) -> String:
    var output_quantity := 0
    var output_name := "nguyên liệu"
    if building != null:
        var building_system := BuildingSystem.new()
        var definition := building_system.definition_for(building)
        var resource_id := building_system.mine_selected_ore(building) if building.building_type == BuildingSystem.TYPE_MINE else building_system.forest_selected_material(building) if building.building_type == BuildingSystem.TYPE_LINH_FOREST else StringName(definition.get("resource_id",""))
        output_quantity = building_system.mine_ore_batch_units(building,resource_id) if building.building_type == BuildingSystem.TYPE_MINE else building_system.forest_material_batch_units(building,resource_id) if building.building_type == BuildingSystem.TYPE_LINH_FOREST else building_system.resource_job_batch_units(building)
        var bulk_preview := building_system.sx_v55_plan(state,building,resource_id)
        if not bulk_preview.is_empty():
            output_quantity = maxi(1,int(round(float(bulk_preview.get("yield",0)) * (
                1.0 + 0.005 * float(maxi(building.level-1,0))))))
        output_name = ResourceRegistry.new().display_name(resource_id)
    var work_label := "lượt khai thác" if profession_id == WorkforceSystem.PROF_MINING else "lượt thu hoạch"
    var batch_text := "%s ×%d %s" % [work_label,output_quantity,output_name] if output_quantity > 0 else "chờ khởi sự"
    if state.sect.economy_a_enabled:
        var timer := BuildingSystem.new().active_resource_timer_for_worker(state,disciple.id)
        if not timer.is_empty() and StringName(timer.get("profession_id","")) == profession_id:
            var timer_resource := StringName(timer.get("resource_id", ""))
            return "Còn %d phút mô phỏng · %s ×%d %s" % [
                maxi(int(timer.get("finish_tick",state.tick))-state.tick,0),
                work_label, maxi(int(timer.get("output_quantity",output_quantity)),0),
                ResourceRegistry.new().display_name(timer_resource)
            ]
    if not has_active_slot:
        return "Chờ chỗ hoạt động"
    var cycle: Dictionary = disciple.work_cycle_state
    var cycle_profession := StringName(cycle.get("profession_id", cycle.get("profession", "")))
    if cycle_profession != profession_id:
        return "Sẵn sàng · %s" % batch_text

    var phase := StringName(cycle.get("phase", ""))
    var cycle_profile := _legacy_carry_cycle_profile(building, disciple, cycle) if building != null else {}
    var eta_suffix := " · còn khoảng %d phút mô phỏng" % int(cycle_profile.get("remaining_ticks", 0)) if not cycle_profile.is_empty() else ""
    match phase:
        &"travel_out":
            return "Đang tới %s · %s%s" % [_destination_short_label(StringName(actor_destinations.get(str(disciple.id),""))).to_lower(),batch_text,eta_suffix]
        &"mining":
            return "Đang khai thác · %s%s" % [batch_text,eta_suffix]
        &"harvesting":
            return "Đang chăm sóc Linh Điền" if profession_id == WorkforceSystem.PROF_HERBALISM else "Đang thu hoạch · %s%s" % [batch_text,eta_suffix]
        &"haul_back":
            return "Đang chở ×%d về Kho%s" % [maxi(int(cycle.get("carried_units",0)),0),eta_suffix]
        _:
            return "Chờ chu kỳ · %s%s" % [batch_text,eta_suffix]

func _mine_operation_text() -> String:
    var members := _disciples_in_work_group(&"mining_crew")
    var building_system := BuildingSystem.new()
    var mine := _selected_operation_building()
    if mine == null or mine.building_type != BuildingSystem.TYPE_MINE:
        mine = building_system.primary_building(state, BuildingSystem.TYPE_MINE)
    var active_ids: Array[StringName] = []
    var slots := 0
    if mine != null:
        active_ids = building_system.active_worker_ids(state, mine)
        slots = building_system.worker_slots(mine)

    var lines: Array[String] = []
    var waiting_count := 0
    for disciple_value in members:
        var disciple: DiscipleState = disciple_value
        var level := workforce.profession_level_for_state(state, disciple, WorkforceSystem.PROF_MINING)
        var is_active := active_ids.has(disciple.id)
        if not is_active:
            waiting_count += 1
        var location := " · điểm mặc định"
        if disciple.worksite_building_id != &"" and state.buildings.has(str(disciple.worksite_building_id)):
            var worksite: BuildingState = state.buildings[str(disciple.worksite_building_id)]
            location = " · Mỏ %02d" % maxi(worksite.instance_index,1)
        lines.append("• %s · Lv%d · %s%s" % [
            disciple.display_name, level,
            _mining_member_status(disciple, is_active,mine), location
        ])
    if lines.is_empty():
        lines.append("• Chưa có thành viên Đội Khai Khoáng")
    var batches := 0 if mine == null else maxi(int(mine.metrics.get("production_batches",0)),0)
    var units := 0 if mine == null else maxi(int(mine.metrics.get("units_produced",0)),0)

    var selected_ore := building_system.mine_selected_ore(mine)
    var selected_name := ResourceRegistry.new().display_name(selected_ore)
    var planned_batch := building_system.mine_ore_batch_units(mine, selected_ore) if mine != null else 0
    if mine != null:
        var bulk_plan := building_system.sx_v55_plan(state,mine,selected_ore)
        if not bulk_plan.is_empty():
            planned_batch = maxi(1,int(round(float(bulk_plan.get("yield",0)) * (
                1.0 + 0.005 * float(maxi(mine.level-1,0))))))
    var upgrade_text := "Ổn định"
    if mine != null and mine.is_upgrading():
        upgrade_text = "Nâng Lv%d→%d · %.0f/%.0f" % [
            mine.level, mine.upgrade_target_level,
            mine.upgrade_progress, mine.upgrade_required_work
        ]

    return (
        "SẢN XUẤT\n"
        + "Mỏ Lv%d · %s\n"
        + "Khoáng đã chọn: %s · tồn (dùng): %s\n"
        + "Thanh Thiết tồn (dùng): %s\n"
        + "Mỗi lượt khai thác dự kiến: ×%d %s\n"
        + "Tổng sản lượng Mỏ: %d đơn vị · %d lượt\n"
        + "Chỗ hoạt động: %d/%d\n"
        + "Đang chờ slot Mỏ: %d\n"
        + "Đang khai khoáng: %d\n"
        + "Thành viên đội: %d\n\n"
        + "NHÂN SỰ\n%s\n\n"
        + "Chu kỳ thật: đi tới mỏ → khai thác → vận chuyển về kho. Chỉ đệ tử có chỗ hoạt động mới nhận lệnh khai khoáng."
    ) % [
        0 if mine == null else mine.level,
        upgrade_text,
        selected_name,
        _warehouse_pair(selected_ore),
        _warehouse_pair(&"thanh_thiet"),
        planned_batch,selected_name,
        units,batches,
        active_ids.size(),
        slots,
        waiting_count,
        _count_action(&"WORK_MINING"),
        members.size(),
        "\n".join(lines)
    ]

func _mining_member_status(disciple: DiscipleState, has_active_slot: bool, mine: BuildingState = null) -> String:
    return _resource_job_member_status(disciple,WorkforceSystem.PROF_MINING,has_active_slot,mine)

func _spirit_field_operation_text() -> String:
    var buildings := BuildingSystem.new()
    var field := _selected_operation_building()
    if field == null or field.building_type != BuildingSystem.TYPE_SPIRIT_FIELD:
        field = buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    if field == null:
        return "Linh Điền chưa tồn tại trong trạng thái hiện tại."

    var plots := buildings.spirit_field_plots(state, field)
    var active_ids := buildings.active_worker_ids(state, field)
    var field_members := _disciples_in_work_group(&"herbalism_crew")
    var growing := 0
    var plot_lines: Array[String] = []
    var member_lines: Array[String] = []
    var member_plot_status: Dictionary = {}
    var plot_index := 0
    for raw_plot in plots:
        var plot: Dictionary = raw_plot
        var plot_id := str(plot.get("plot_id", "?"))
        var plot_number := plot_id.trim_prefix("plot_").to_int()
        var plot_name := "Luống %d" % (plot_number if plot_number > 0 else plot_index + 1)
        plot_index += 1
        if StringName(plot.get("status", "")) != BuildingSystem.PLOT_GROWING:
            plot_lines.append("• %s · Trống" % plot_name)
            continue
        growing += 1
        var crop_id := StringName(plot.get("crop_id", ""))
        var worker_id := StringName(plot.get("assigned_worker_id", ""))
        var worker_name := str(worker_id)
        if state.disciples.has(worker_id):
            worker_name = (state.disciples[worker_id] as DiscipleState).display_name
        var remaining := maxi(int(plot.get("finish_tick", state.tick)) - state.tick, 0)
        var crop_name := spirit_crop_registry.display_name(crop_id)
        var routine_yield := maxi(int(plot.get("routine_yield",spirit_crop_registry.base_yield(crop_id))),1)
        plot_lines.append("• %s · %s · %s · thu hoạch ×%d · còn %d phút mô phỏng · đã trả %d Linh Thạch" % [
            plot_name,
            crop_name,
            worker_name,
            routine_yield,
            remaining,
            int(plot.get("paid_spirit_stones", 0))
        ])
        if worker_id != &"":
            member_plot_status[str(worker_id)] = "Chăm sóc %s · %s ×%d · còn %d nhịp" % [plot_name,crop_name,routine_yield,remaining]

    for disciple in field_members:
        var level := workforce.profession_level_for_state(state,disciple,WorkforceSystem.PROF_HERBALISM)
        var member_status := "Chờ chỗ hoạt động" if not active_ids.has(disciple.id) else "Sẵn sàng gieo · chờ lô trống"
        if member_plot_status.has(str(disciple.id)):
            member_status = str(member_plot_status[str(disciple.id)])
        member_lines.append("• %s · Linh Thực Lv%d · %s" % [
            disciple.display_name,level,member_status
        ])
    if member_lines.is_empty():
        member_lines.append("• Chưa phân đệ tử vào Đội Linh Thực")

    var crop_lines: Array[String] = []
    for crop_id in spirit_crop_registry.eligible_crop_ids(field.level):
        var bulk_crop := buildings.sx_v55_plan(state,field,crop_id)
        crop_lines.append("• %s · phí %d LT · chu kỳ nền %d nhịp · sản lượng nền %d" % [
            spirit_crop_registry.display_name(crop_id),
            spirit_crop_registry.cost(crop_id),
            int(bulk_crop.get("cycle_ticks",spirit_crop_registry.base_cycle_ticks(crop_id))),
            int(bulk_crop.get("yield",spirit_crop_registry.base_yield(crop_id)))
        ])

    var batches := maxi(int(field.metrics.get("production_batches",0)),0)
    var units := maxi(int(field.metrics.get("units_produced",0)),0)

    return (
        "LINH ĐIỀN %02d · Lv%d\n"
        + "Chính sách: %s\n"
        + "Linh Thạch Tông Môn: %d\n"
        + "Đệ tử canh tác: %d/%d · Ô đang trồng: %d/%d\n\n"
        + "THỰC NHẬP LINH KHO: %d đơn vị · %d lượt thu hoạch\n"
        + "ĐỘI LINH THỰC\n%s\n\n"
        + "CÂY HỢP LỆ\n%s\n\n"
        + "Ô RUỘNG\n%s\n\n"
        + "KHO THU HOẠCH (tồn / dùng)\n"
        + "Linh Cốc: %s\nThanh Linh Thảo: %s\nTử Vân Thảo: %s\n\n"
        + "Lv1–9 dùng AUTO_DEMAND; Cố định/Priority mở từ Lv10 theo authority hiện có."
    ) % [
        maxi(field.instance_index,1),field.level,
        _spirit_field_policy_label(field),
        state.sect.spirit_stones,
        active_ids.size(), buildings.worker_slots(field),
        growing, plots.size(),
        units,batches,
        "\n".join(member_lines),
        "\n".join(crop_lines),
        "\n".join(plot_lines),
        _warehouse_pair(&"linh_coc", true),
        _warehouse_pair(&"thanh_linh_thao", true),
        _warehouse_pair(&"tu_van_thao", true)
    ]

func _spirit_field_policy_label(field: BuildingState) -> String:
    var mode := StringName(field.production_state.get("policy_mode", str(BuildingSystem.FIELD_POLICY_AUTO_DEMAND)))
    match mode:
        BuildingSystem.FIELD_POLICY_FIXED:
            var crop_id := StringName(field.production_state.get("fixed_crop_id", ""))
            return "Cố định · %s" % spirit_crop_registry.display_name(crop_id)
        BuildingSystem.FIELD_POLICY_PRIORITY:
            return "Ưu tiên theo trọng số"
        _:
            return "Tự động theo thiếu hụt"

func _forge_operation_text() -> String:
    var members := _disciples_in_work_group(&"forge_hall")
    var lines: Array[String] = []
    for disciple_value in members:
        var disciple: DiscipleState = disciple_value
        var level := workforce.profession_level(disciple, WorkforceSystem.PROF_FORGING)
        var progress := float(disciple.work_progress.get(str(WorkforceSystem.PROF_FORGING), 0.0))
        lines.append("• %s · Lv%d · tiến độ %.1f/5 · thể lực %.0f · %s" % [
            disciple.display_name, level, progress, disciple.stamina,
            SectMapPresentation.action_label(disciple.current_action)
        ])
    if lines.is_empty():
        lines.append("• Chưa có thành viên Luyện Khí Đường")

    var craftable := 0
    var recipe_ids: Array = EquipmentSystem.RECIPES.keys()
    recipe_ids.sort()
    for raw_id in recipe_ids:
        if equipment_system.can_craft(state, StringName(raw_id)):
            craftable += 1

    return (
        "VẬT LIỆU\n"
        + "Tồn (dùng): Thanh Thiết %s · Linh Mộc %s\n"
        + "Tinh Lang Bì %s · Yêu Đan %s\n"
        + "Điểm hỗ trợ rèn: %d\n"
        + "Công thức có thể luyện: %d / %d\n\n"
        + "NHÂN SỰ\n%s\n\n"
        + "Phân người phụ trách luyện khí và chế tạo trang bị khi đủ nguyên liệu."
    ) % [
        _warehouse_pair(&"thanh_thiet"),
        _warehouse_pair(&"linh_moc"),
        _warehouse_pair(&"tinh_lang_bi"),
        _warehouse_pair(&"yeu_dan"),
        state.sect.forge_support_points,
        craftable, recipe_ids.size(),
        "\n".join(lines)
    ]

func _cultivation_operation_text() -> String:
    var lines: Array[String] = []
    var ready_count := 0
    var v2_gate_count := 0
    var active_count := 0
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        var active := disciple.current_action in [&"CULTIVATE", &"BREAKTHROUGH"]
        if active:
            active_count += 1
        var snapshot := _disciple_snapshot(disciple)
        if bool(snapshot.get("authentic_v2", false)):
            # Only the canonical V2 progression snapshot may describe a V2
            # realm/floor/XP. Never fall back to P2, even if V2 is malformed.
            var progression: Dictionary = snapshot.get("progression", {})
            if not bool(progression.get("ready", false)):
                if active:
                    lines.append("• %s · Tu Vi V2: dữ liệu chưa sẵn sàng" % disciple.display_name)
                continue
            var tuvi: Dictionary = progression["cultivation"]
            var at_gate := bool(tuvi.get("at_major_gate", false))
            if at_gate:
                v2_gate_count += 1
            if active or at_gate:
                lines.append("• %s · %s tầng %d · %.0f/%.0f · Thể lực viễn chinh %.0f%s" % [
                    disciple.display_name,
                    str(tuvi["name"]), int(tuvi["floor"]),
                    float(tuvi["xp"]), float(tuvi["required_xp"]),
                    disciple.stamina,
                    " · CHỜ CỔNG ĐẠI CẢNH" if at_gate else ""
                ])
            continue

        # Preserve the established P2 legacy presentation and eligibility.
        var required := cultivation.required_progress(disciple)
        var progress_text := "Viên mãn" if required <= 0.0 else "%.0f/%.0f" % [disciple.cultivation_progress, required]
        var ready := cultivation.can_breakthrough(state, disciple)
        if ready:
            ready_count += 1
        if active or ready:
            lines.append("• %s · %s · %s · thể lực %.0f%s" % [
                disciple.display_name,
                cultivation.stage_name(disciple),
                progress_text,
                disciple.stamina,
                " · CÓ THỂ ĐỘT PHÁ" if ready else ""
            ])
    if lines.is_empty():
        lines.append("• Chưa có ai đang tu luyện hoặc đủ điều kiện đột phá")

    return (
        "Đang tu luyện/phá cảnh: %d\n"
        + "Đủ điều kiện đột phá: %d\n"
        + "Chờ cổng đại cảnh: %d\n\n"
        + "ĐỆ TỬ LIÊN QUAN\n%s\n\n"
        + "Tiến độ tu luyện hiển thị theo hồ sơ từng đệ tử; cổng đại cảnh có điều kiện riêng."
    ) % [active_count, ready_count, v2_gate_count, "\n".join(lines)]

func _residence_operation_text() -> String:
    var population := state.disciples.size()
    var overloaded := population > state.sect.lodging_capacity
    var recovery_pct := NeedsSystem.new().rest_recovery_multiplier(state) * 100.0
    var rest_lines := _action_disciple_lines([&"REST"])
    var houses := SectResidenceSystemV1.all_houses(state)
    var house_lines: Array[String] = []
    for house in houses:
        if house.status == BuildingSystem.STATUS_CONSTRUCTING:
            house_lines.append("• Đệ Tử Xá %02d · Đang thi công · còn %d nhịp" % [
                house.instance_index,SectResidenceSystemV1.construction_remaining_ticks(state,house)
            ])
        elif house.status == BuildingSystem.STATUS_UPGRADING:
            house_lines.append("• Đệ Tử Xá %02d · Đang nâng cấp lên Lv%d" % [
                house.instance_index,house.level+1
            ])
        else:
            house_lines.append("• Đệ Tử Xá %02d · Lv%d · %d giường" % [
                house.instance_index,house.level,SectResidenceSystemV1.beds_for_level(house.level)
            ])
    if house_lines.is_empty():
        house_lines.append("• Chưa có Đệ Tử Xá")
    return (
        "Loại công trình: Đệ Tử Xá (1) · đang có %d/%d căn\n"
        + "Sức chứa: %d / %d\n"
        + "Tình trạng: %s\n"
        + "Hệ số hồi phục hiện tại: %.0f%%\n"
        + "Vật tư: %d\n"
        + "Đang nghỉ: %d\n\n"
        + "CÔNG TRÌNH CƯ TRÚ\n%s\n\n"
        + "ĐỆ TỬ ĐANG NGHỈ\n%s\n\n"
        + "Gọi đệ tử về nghỉ hoặc mở rộng chỗ ở khi tông môn quá tải."
    ) % [
        houses.size(),SectResidenceSystemV1.maximum_instances(state),
        population, state.sect.lodging_capacity,
        "QUÁ TẢI" if overloaded else "Ổn định",
        recovery_pct, state.sect.supply_stock,
        _count_action(&"REST"),"\n".join(house_lines),
        rest_lines
    ]

func _medicine_operation_text() -> String:
    var injured: Array[String] = []
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        var ratio := disciple.hp / maxf(disciple.max_hp, 1.0)
        if ratio < 0.72:
            injured.append("• %s · HP %.0f/%.0f · %s" % [
                disciple.display_name, disciple.hp, disciple.max_hp,
                SectMapPresentation.action_label(disciple.current_action)
            ])
    if injured.is_empty():
        injured.append("• Không có đệ tử dưới ngưỡng HP 72%")

    return (
        "Thuốc hậu cần: %d / %d\n"
        + "Hồi Xuân Đan: %s\n"
        + "Vật tư: %d / %d\n"
        + "Đang trị thương: %d\n"
        + "Ưu tiên hậu cần: %s\n"
        + "Đã dùng thuốc: %d · Đã sản xuất: %d\n\n"
        + "NGƯỜI CẦN CHÚ Ý\n%s\n\n"
        + "Điều chỉnh ưu tiên hậu cần để cân bằng thuốc và vật tư theo tình hình hiện tại."
    ) % [
        state.sect.medicine_stock, NeedsSystem.MEDICINE_CAP,
        _warehouse_pair(NeedsSystem.HEALING_PILL_ID, true),
        state.sect.supply_stock, NeedsSystem.SUPPLY_CAP,
        _count_action(&"HEAL"),
        _needs_priority_label(state.sect.needs_priority),
        int(state.sect.needs_stats.get("medicine_used", 0)),
        int(state.sect.needs_stats.get("medicine_produced", 0)),
        "\n".join(injured)
    ]

func _warehouse_operation_text() -> String:
    var storage_count := 0
    var shop_count := 0
    var equipped_count := 0
    for item_value in state.sect.equipment_items.values():
        var item: Dictionary = item_value
        match StringName(item.get("location", "")):
            EquipmentSystem.LOCATION_STORAGE: storage_count += 1
            EquipmentSystem.LOCATION_SHOP: shop_count += 1
            EquipmentSystem.LOCATION_EQUIPPED: equipped_count += 1

    var stock_lines: Array[String] = []
    var stocked_types := 0
    # Read-only pending harvests: not Warehouse inventory and never available
    # for an Alchemy job until canonical crop settlement deposits them.
    var pending_harvests := _warehouse_pending_field_harvest()
    var warehouse_system := WarehouseSystem.new()
    if warehouse_display_resource_ids.is_empty():
        warehouse_display_resource_ids = _v63_hunt_resource_registry.all_resource_ids()
    for resource_id in warehouse_display_resource_ids:
        var amount := _warehouse_inventory_amount(resource_id,warehouse_system)
        var available := _warehouse_inventory_available(resource_id,warehouse_system)
        var rule := warehouse_system.rule(state,resource_id) if state.sect.p3_7_resources_enabled else {"reserve_min":0,"locked":false}
        var reserve := maxi(int(rule.get("reserve_min",0)),0)
        var locked := bool(rule.get("locked",false))
        var harvest: Dictionary = pending_harvests.get(str(resource_id),{})
        var growing_quantity := maxi(int(harvest.get("quantity",0)),0)
        if amount <= 0 and reserve == 0 and not locked and growing_quantity <= 0:
            continue
        if amount > 0:
            stocked_types += 1
        var availability_note := " · ĐANG KHÓA" if locked else (" · giữ %d" % reserve if reserve > 0 else "")
        var pending_note := ""
        if growing_quantity > 0:
            var minutes_left := maxi(0,int(harvest.get("finish_tick",state.tick))-state.tick)
            pending_note = " · đang trồng ~%s (%s)" % [
                _compact_number(growing_quantity),
                "đến hạn, chờ nhập Kho" if minutes_left == 0 else "còn %d phút mô phỏng" % minutes_left
            ]
        stock_lines.append("• %s ×%s · dùng được %s%s%s" % [
            _v63_hunt_resource_registry.display_name(resource_id),
            _compact_number(amount),_compact_number(available),availability_note,pending_note
        ])
    if stock_lines.is_empty():
        stock_lines.append("• Chưa có nguyên liệu trong Kho")
    var production_lines := _warehouse_production_lines()
    if production_lines.is_empty():
        production_lines.append("• Chưa có mẻ sản xuất nào được nhập kho")

    return (
        "TIỀN TỆ\n"
        + "Ngân khố: %d · Linh Thạch: %d\n\n"
        + "SINH HOẠT\n"
        + "Thuốc: %d · Vật tư: %d\n\n"
        + "NGUYÊN LIỆU · %d LOẠI CÓ TỒN · tồn / dùng được\n%s\n\n"
        + "SẢN LƯỢNG TÍCH LŨY ĐÃ NHẬP KHO\n%s\n\n"
        + "TRANG BỊ\n"
        + "Trong kho: %d · Đang bán: %d · Đã trang bị: %d\n\n"
        + "Linh Thạch, tiền, thuốc và vật tư là số dư tông môn. Sản lượng trên là số ghi nhận theo từng công trình kể từ khi được xây."
    ) % [
        state.sect.treasury, state.sect.spirit_stones,
        state.sect.medicine_stock, state.sect.supply_stock,
        stocked_types,"\n".join(stock_lines),
        "\n".join(production_lines),
        storage_count, shop_count, equipped_count
    ]

# GP-PLAY01/GP0: production visibility only. Never call an initializer
# here: the canonical BuildingSystem/Scheduler owns migration, planting and
# harvest. Read actual in-flight plots; do not count anticipated yield as stock.
func _warehouse_pending_field_harvest() -> Dictionary:
    var pending: Dictionary = {}
    if state == null:
        return pending
    var crops := SpiritCropRegistry.new()
    var ids: Array = state.buildings.keys()
    ids.sort()
    for raw_id in ids:
        var field: BuildingState = state.buildings[raw_id]
        if field.building_type != BuildingSystem.TYPE_SPIRIT_FIELD:
            continue
        var raw_plots = field.production_state.get("plots",[])
        if not (raw_plots is Array):
            continue
        for raw_plot in raw_plots:
            if not (raw_plot is Dictionary):
                continue
            var plot: Dictionary = raw_plot
            if StringName(plot.get("status","")) != BuildingSystem.PLOT_GROWING:
                continue
            var crop_id := StringName(plot.get("crop_id",""))
            if not crops.has(crop_id):
                continue
            var units := maxi(int(plot.get("routine_yield",0)),0)
            if units <= 0:
                continue
            var output_id := str(crops.output_resource_id(crop_id))
            var due_tick := int(plot.get("finish_tick",state.tick))
            var entry: Dictionary = pending.get(output_id,{
                "quantity":0,"finish_tick":due_tick
            })
            entry["quantity"] = int(entry.get("quantity",0))+units
            entry["finish_tick"] = mini(int(entry.get("finish_tick",due_tick)),due_tick)
            pending[output_id] = entry
    return pending

func _warehouse_inventory_amount(resource_id: StringName, warehouse_system: WarehouseSystem) -> int:
    if state.sect.p3_7_resources_enabled:
        return warehouse_system.quantity(state,resource_id)
    return maxi(int(state.sect.forge_materials.get(str(resource_id),0)),0) \
        + maxi(int(state.sect.technique_materials.get(str(resource_id),0)),0)

func _warehouse_inventory_available(resource_id: StringName, warehouse_system: WarehouseSystem) -> int:
    if state.sect.p3_7_resources_enabled:
        return warehouse_system.available_quantity(state,resource_id)
    return _warehouse_inventory_amount(resource_id,warehouse_system)

func _warehouse_production_lines() -> Array[String]:
    var result: Array[String] = []
    var building_ids: Array = state.buildings.keys()
    building_ids.sort()
    for raw_id in building_ids:
        var building: BuildingState = state.buildings[raw_id]
        var output_name := ""
        match building.building_type:
            BuildingSystem.TYPE_MINE: output_name = "đơn vị khoáng (tổng)"
            BuildingSystem.TYPE_LINH_FOREST: output_name = "đơn vị lâm sản (tổng)"
            BuildingSystem.TYPE_SPIRIT_FIELD: output_name = "nông sản gộp"
            _: continue
        var batches := maxi(int(building.metrics.get("production_batches",0)),0)
        var units := maxi(int(building.metrics.get("units_produced",0)),0)
        if batches <= 0 and units <= 0:
            continue
        var ordinal := maxi(building.instance_index,1)
        var site_name := "Mỏ" if building.building_type == BuildingSystem.TYPE_MINE else ("Linh Lâm" if building.building_type == BuildingSystem.TYPE_LINH_FOREST else "Linh Điền")
        result.append("• %s %02d · %d mẻ · %d %s" % [site_name,ordinal,batches,units,output_name])
    return result

func _gate_operation_text() -> String:
    var outside: Array[String] = []
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.region_id == &"sect" and not SectMapPresentation.is_outside_flow(disciple.current_action):
            continue
        var location := str(disciple.region_id)
        if disciple.region_id == &"sect":
            location = "Đại Môn"
        outside.append("• %s · %s · %s · HP %.0f/%.0f · TL %.0f" % [
            disciple.display_name,
            SectMapPresentation.action_label(disciple.current_action),
            location,
            disciple.hp, disciple.max_hp, disciple.stamina
        ])
    if outside.is_empty():
        outside.append("• Không có đệ tử trong luồng xuất môn")

    return (
        "Đệ tử ngoài tông: %d\n"
        + "Trong luồng săn/di chuyển/chiến đấu: %d\n"
        + "Vật tư tông môn: %d\n\n"
        + "TÌNH HÌNH XUẤT MÔN\n%s\n\n"
        + "Có thể triệu hồi đệ tử đang ở ngoài tông khi tình hình không an toàn."
    ) % [
        _count_outside(),
        _count_actions([&"HUNT", &"TRAVEL", &"COMBAT", &"LOOT", &"RETURN_SECT"]),
        state.sect.supply_stock,
        "\n".join(outside)
    ]

func _disciples_in_work_group(group_id: StringName) -> Array[DiscipleState]:
    var result: Array[DiscipleState] = []
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.work_group_id == group_id:
            result.append(disciple)
    return result

func _action_disciple_lines(actions: Array) -> String:
    var lines: Array[String] = []
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if actions.has(disciple.current_action):
            lines.append("• %s · HP %.0f/%.0f · thể lực %.0f" % [
                disciple.display_name, disciple.hp, disciple.max_hp, disciple.stamina
            ])
    return "• Không có" if lines.is_empty() else "\n".join(lines)

func _work_policy_label(policy: StringName) -> String:
    match policy:
        WorkforceSystem.POLICY_PRODUCTION: return "Ưu tiên sản xuất"
        WorkforceSystem.POLICY_CULTIVATION: return "Ưu tiên tu luyện"
        _: return "Cân bằng"

func _needs_priority_label(priority: StringName) -> String:
    match priority:
        NeedsSystem.PRIORITY_MEDICINE: return "Ưu tiên thuốc"
        NeedsSystem.PRIORITY_SUPPLIES: return "Ưu tiên vật tư"
        _: return "Cân bằng"

func _equipment_policy_label(policy: StringName) -> String:
    match policy:
        EquipmentSystem.POLICY_COMBAT: return "Chiến đấu"
        EquipmentSystem.POLICY_FRUGAL: return "Tiết kiệm"
        _: return "Cân bằng"

func _process(_delta: float) -> void:
    if performance_logging_enabled:
        _sample_frame_performance(_delta)
    var hunt_parent := b3_hunt_panel.get_parent() as CanvasItem if b3_hunt_panel != null and is_instance_valid(b3_hunt_panel) else null
    var hunt_overlay_open := hunt_parent != null and hunt_parent.visible
    _record_raw_performance_frame(_delta,"pve" if hunt_overlay_open else "production")
    _set_production_underlay_frozen(hunt_overlay_open)
    if hunt_overlay_open:
        # The shared clock accrues whole wall seconds, which can represent four
        # 250ms Combat V2 frames at once. Drain that debt one render update at a
        # time so simulation timing stays intact without a four-frame CPU burst.
        if (runtime_ready and runtime_session != null and state != null
                and not runtime_poll_pending
                and not HuntingPveRunV2.active_multicamp_id(state).is_empty()
                and state.runtime_unconsumed_wall_seconds >= MapBattleV2.STEP_SECONDS):
            await _advance_simulation()
            if not is_inside_tree():
                return
        # Keep the dimmed production map frozen under the full-screen hunt.
        # Refresh the read-only HUD even while a runtime save worker is
        # committing; only simulation advancement is gated by that worker.
        b3_hunt_refresh_elapsed += _delta
        if b3_hunt_refresh_elapsed >= B3_HUNT_REFRESH_SECONDS:
            b3_hunt_refresh_elapsed = fmod(b3_hunt_refresh_elapsed,B3_HUNT_REFRESH_SECONDS)
            var refresh_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
            _refresh_b3_hunt_panel()
            if performance_logging_enabled:
                var refresh_elapsed_usec := Time.get_ticks_usec()-refresh_started_usec
                performance_hunt_refresh_count += 1
                performance_hunt_refresh_usec_total += refresh_elapsed_usec
                performance_hunt_refresh_usec_max = maxi(performance_hunt_refresh_usec_max,refresh_elapsed_usec)
        return
    npc_motion_elapsed += _delta
    if npc_motion_elapsed >= 0.5:
        npc_motion_elapsed = 0.0
        _advance_idle_disciple_walks()
    npc_ambient_elapsed += _delta
    if npc_ambient_elapsed >= npc_ambient_delay:
        npc_ambient_elapsed = 0.0
        _show_next_idle_ambient_line()
    if iso_world != null:
        if iso_world.set_legacy_transform(map_layer.scale.x,map_layer.position):
            iso_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
            # Panning/zooming changes this transform every rendered frame.
            # Move the at-most-four cached cues cheaply, then rescan producer
            # state once after the camera movement settles.
            _refresh_map_worksite_cue_transforms()
            map_worksite_cues_dirty = true
            map_worksite_refresh_elapsed = 0.0
            # Actor culling/materialization is throttled below; do not scan a
            # large roster on every camera tween/pan frame.
    _refresh_living_cue_positions()
    actor_visibility_refresh_elapsed += _delta
    if actor_visibility_refresh_elapsed >= 0.12:
        actor_visibility_refresh_elapsed = 0.0
        _refresh_world_actor_visibility()
    if map_worksite_cues_dirty:
        var camera_moving := mouse_panning or not touch_points.is_empty()
        if camera_tween != null and camera_tween.is_running():
            camera_moving = true
        if camera_moving:
            map_worksite_refresh_elapsed = 0.0
        else:
            map_worksite_refresh_elapsed += _delta
            if map_worksite_refresh_elapsed >= MAP_WORKSITE_REFRESH_SECONDS:
                map_worksite_refresh_elapsed = 0.0
                map_worksite_cues_dirty = false
                _refresh_map_worksite_cues()
    b3_hunt_refresh_elapsed += _delta
    if b3_hunt_refresh_elapsed >= B3_HUNT_REFRESH_SECONDS:
        b3_hunt_refresh_elapsed = fmod(b3_hunt_refresh_elapsed,B3_HUNT_REFRESH_SECONDS)
        _refresh_b3_hunt_panel()

func _open_raw_frame_log() -> void:
    var path := OS.get_environment(RAW_FRAME_LOG_ENV)
    if path.is_empty():
        return
    var absolute_path := ProjectSettings.globalize_path(path)
    var output_dir := absolute_path.get_base_dir()
    if DirAccess.make_dir_recursive_absolute(output_dir) != OK and not DirAccess.dir_exists_absolute(output_dir):
        push_error("P3 raw frame logger could not create its output directory.")
        return
    raw_frame_log = FileAccess.open(path,FileAccess.WRITE)
    if raw_frame_log == null:
        push_error("P3 raw frame logger could not open its output file: %d" % FileAccess.get_open_error())
        return
    raw_frame_log.store_line("frame_index,ticks_usec,delta_ms,fps,phase,simulation_tick,wall_remainder_s,battle_time,action_count,runtime_poll_pending,save_pending,runtime_write_blocked")

func _record_raw_performance_frame(delta: float, phase: String) -> void:
    if raw_frame_log == null:
        return
    raw_frame_log_index += 1
    var battle: MapBattleV2 = b3_hunt_arena.battle if b3_hunt_arena != null else null
    var battle_time := battle.now if battle != null else -1.0
    var action_count := battle.actions if battle != null else -1
    var owner := runtime_session.owner if runtime_session != null else null
    var save_pending := owner != null and owner.saves.has_async_save_pending()
    var write_blocked := owner != null and owner.runtime_write_blocked
    raw_frame_log_buffer.append("%d,%d,%.4f,%.3f,%s,%d,%.4f,%.3f,%d,%d,%d,%d" % [
        raw_frame_log_index,Time.get_ticks_usec(),delta*1000.0,1.0/maxf(delta,0.000001),phase,
        state.tick if state != null else -1,
        state.runtime_unconsumed_wall_seconds if state != null else -1.0,
        battle_time,action_count,int(runtime_poll_pending),int(save_pending),int(write_blocked)
    ])
    if raw_frame_log_buffer.size() >= 120:
        _flush_raw_frame_log()

func _flush_raw_frame_log() -> void:
    if raw_frame_log == null or raw_frame_log_buffer.is_empty():
        return
    raw_frame_log.store_string("\n".join(raw_frame_log_buffer)+"\n")
    raw_frame_log_buffer.clear()

func _set_production_underlay_frozen(frozen: bool) -> void:
    if iso_viewport == null:
        return
    if frozen:
        if production_underlay_frozen:
            return
        production_underlay_mode_before_freeze = iso_viewport.render_target_update_mode
        iso_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
        production_underlay_frozen = true
    elif production_underlay_frozen:
        iso_viewport.render_target_update_mode = production_underlay_mode_before_freeze if production_underlay_mode_before_freeze >= 0 else SubViewport.UPDATE_ONCE
        production_underlay_frozen = false
        production_underlay_mode_before_freeze = -1

func _sample_frame_performance(delta: float) -> void:
    var safe_delta := maxf(0.0,delta)
    performance_sample_elapsed += safe_delta
    performance_sample_delta_total += safe_delta
    performance_sample_delta_max = maxf(performance_sample_delta_max,safe_delta)
    performance_sample_frame_count += 1
    if performance_sample_elapsed < PERFORMANCE_SAMPLE_SECONDS:
        return
    var visible_actor_count := 0
    for actor_value in actor_nodes.values():
        var actor := actor_value as CanvasItem
        if actor != null and actor.visible:
            visible_actor_count += 1
    var vfx_advance_metrics: Dictionary = {}
    var vfx_draw_metrics: Dictionary = {}
    if b3_pve_world_view != null and is_instance_valid(b3_pve_world_view):
        if b3_pve_world_view.world != null:
            vfx_advance_metrics = b3_pve_world_view.world.consume_vfx_advance_metrics()
        vfx_draw_metrics = b3_pve_world_view.consume_vfx_draw_metrics()
    var avg_frame_ms := performance_sample_delta_total*1000.0/maxi(1,performance_sample_frame_count)
    print("TMB_P3_2_FRAME_METRIC " + JSON.stringify({
        "fps":float(performance_sample_frame_count)/maxf(0.001,performance_sample_elapsed),
        "avg_frame_ms":avg_frame_ms,
        "worst_frame_ms":performance_sample_delta_max*1000.0,
        "hunt_refresh_count":performance_hunt_refresh_count,
        "hunt_refresh_avg_ms":float(performance_hunt_refresh_usec_total)/maxi(1,performance_hunt_refresh_count)/1000.0,
        "hunt_refresh_max_ms":float(performance_hunt_refresh_usec_max)/1000.0,
        "hunt_snapshot_restore_avg_ms":float(performance_hunt_restore_usec_total)/maxi(1,performance_hunt_refresh_count)/1000.0,
        "hunt_snapshot_restore_max_ms":float(performance_hunt_restore_usec_max)/1000.0,
        "hunt_visual_rows_avg_ms":float(performance_hunt_visual_rows_usec_total)/maxi(1,performance_hunt_refresh_count)/1000.0,
        "hunt_visual_rows_max_ms":float(performance_hunt_visual_rows_usec_max)/1000.0,
        "hunt_world_view_update_avg_ms":float(performance_hunt_view_update_usec_total)/maxi(1,performance_hunt_refresh_count)/1000.0,
        "hunt_world_view_update_max_ms":float(performance_hunt_view_update_usec_max)/1000.0,
        "hunt_hud_update_avg_ms":float(performance_hunt_hud_update_usec_total)/maxi(1,performance_hunt_refresh_count)/1000.0,
        "hunt_hud_update_max_ms":float(performance_hunt_hud_update_usec_max)/1000.0,
        "hunt_layout_apply_count":b3_hunt_layout_apply_count,
        "move_pathfinding_count":performance_move_pathfinding_count,
        "move_pathfinding_avg_ms":float(performance_move_pathfinding_usec_total)/maxi(1,performance_move_pathfinding_count)/1000.0,
        "move_pathfinding_max_ms":float(performance_move_pathfinding_usec_max)/1000.0,
        "pve_subviewport_update_mode":int(b3_pve_world_view._viewport.render_target_update_mode) if b3_pve_world_view != null and b3_pve_world_view._viewport != null else -1,
        "pve_subviewport_pixels":int(b3_pve_world_view._viewport.size.x*b3_pve_world_view._viewport.size.y) if b3_pve_world_view != null and b3_pve_world_view._viewport != null else 0,
        "pve_vfx_advance_count":int(vfx_advance_metrics.get("count",0)),
        "pve_vfx_advance_avg_ms":float(vfx_advance_metrics.get("total_usec",0))/maxi(1,int(vfx_advance_metrics.get("count",0)))/1000.0,
        "pve_vfx_advance_max_ms":float(vfx_advance_metrics.get("max_usec",0))/1000.0,
        "pve_vfx_event_rows_examined":int(vfx_advance_metrics.get("event_rows_examined",0)),
        "pve_vfx_draw_count":int(vfx_draw_metrics.get("count",0)),
        "pve_vfx_draw_avg_ms":float(vfx_draw_metrics.get("total_usec",0))/maxi(1,int(vfx_draw_metrics.get("count",0)))/1000.0,
        "pve_vfx_draw_max_ms":float(vfx_draw_metrics.get("max_usec",0))/1000.0,
        "production_actor_sync_avg_ms":float(performance_sync_actor_usec_total)/maxi(1,performance_sample_frame_count)/1000.0,
        "production_actor_sync_max_ms":float(performance_sync_actor_usec_max)/1000.0,
        "production_worksite_refresh_count":performance_map_worksite_refresh_count,
        "production_worksite_refresh_avg_ms":float(performance_map_worksite_refresh_usec_total)/maxi(1,performance_map_worksite_refresh_count)/1000.0,
        "production_worksite_refresh_max_ms":float(performance_map_worksite_refresh_usec_max)/1000.0,
        "production_iso_refresh_avg_ms":float(performance_iso_refresh_usec_total)/1000.0,
        "production_iso_refresh_max_ms":float(performance_iso_refresh_usec_max)/1000.0,
        "runtime_poll_count":performance_runtime_poll_count,
        "runtime_poll_avg_ms":float(performance_runtime_poll_usec_total)/maxi(1,performance_runtime_poll_count)/1000.0,
        "runtime_poll_max_ms":float(performance_runtime_poll_usec_max)/1000.0,
        "runtime_poll_compute_avg_ms":float(performance_runtime_update_usec_total)/maxi(1,performance_runtime_poll_count)/1000.0,
        "runtime_poll_compute_max_ms":float(performance_runtime_update_usec_max)/1000.0,
        "runtime_poll_refresh_avg_ms":float(performance_runtime_refresh_usec_total)/maxi(1,performance_runtime_poll_count)/1000.0,
        "runtime_poll_refresh_max_ms":float(performance_runtime_refresh_usec_max)/1000.0,
        "runtime_checkpoint_wait_avg_ms":float(performance_runtime_save_wait_usec_total)/maxi(1,performance_runtime_poll_count)/1000.0,
        "runtime_checkpoint_wait_max_ms":float(performance_runtime_save_wait_usec_max)/1000.0,
        "save_count":performance_save_count,
        "save_avg_ms":float(performance_save_usec_total)/maxi(1,performance_save_count)/1000.0,
        "save_max_ms":float(performance_save_usec_max)/1000.0,
        "autosave_prepare_max_ms":float(performance_autosave_prepare_usec_max)/1000.0,
        "autosave_worker_wait_max_ms":float(performance_autosave_wait_usec_max)/1000.0,
        "pve_checkpoint_count":performance_checkpoint_count,
        "pve_checkpoint_avg_ms":float(performance_checkpoint_usec_total)/maxi(1,performance_checkpoint_count)/1000.0,
        "pve_checkpoint_max_ms":float(performance_checkpoint_usec_max)/1000.0,
        "visible_production_disciple_actors":visible_actor_count,
        "total_materialized_production_actors":actor_nodes.size()
    }))
    performance_sample_elapsed = 0.0
    performance_sample_frame_count = 0
    performance_sample_delta_total = 0.0
    performance_sample_delta_max = 0.0
    performance_hunt_refresh_count = 0
    performance_hunt_refresh_usec_total = 0
    performance_hunt_refresh_usec_max = 0
    performance_hunt_restore_usec_total = 0
    performance_hunt_restore_usec_max = 0
    performance_hunt_visual_rows_usec_total = 0
    performance_hunt_visual_rows_usec_max = 0
    performance_hunt_view_update_usec_total = 0
    performance_hunt_view_update_usec_max = 0
    performance_hunt_hud_update_usec_total = 0
    performance_hunt_hud_update_usec_max = 0
    performance_move_pathfinding_count = 0
    performance_move_pathfinding_usec_total = 0
    performance_move_pathfinding_usec_max = 0
    performance_sync_actor_usec_total = 0
    performance_sync_actor_usec_max = 0
    performance_map_worksite_refresh_count = 0
    performance_map_worksite_refresh_usec_total = 0
    performance_map_worksite_refresh_usec_max = 0
    performance_iso_refresh_usec_total = 0
    performance_iso_refresh_usec_max = 0
    performance_runtime_poll_count = 0
    performance_runtime_poll_usec_total = 0
    performance_runtime_poll_usec_max = 0
    performance_runtime_update_usec_total = 0
    performance_runtime_update_usec_max = 0
    performance_runtime_refresh_usec_total = 0
    performance_runtime_refresh_usec_max = 0
    performance_runtime_save_wait_usec_total = 0
    performance_runtime_save_wait_usec_max = 0
    performance_save_count = 0
    performance_save_usec_total = 0
    performance_save_usec_max = 0
    performance_autosave_prepare_usec_total = 0
    performance_autosave_prepare_usec_max = 0
    performance_autosave_wait_usec_total = 0
    performance_autosave_wait_usec_max = 0
    performance_checkpoint_count = 0
    performance_checkpoint_usec_total = 0
    performance_checkpoint_usec_max = 0

func _advance_simulation() -> void:
    var limit_battle_frame := (
        runtime_ready and runtime_session != null and state != null
        and not HuntingPveRunV2.active_multicamp_id(state).is_empty()
    )
    if limit_battle_frame:
        runtime_session.multicamp_battle_frame_budget = 1
    if not performance_logging_enabled:
        await super._advance_simulation()
        if limit_battle_frame and runtime_session != null:
            runtime_session.multicamp_battle_frame_budget = -1
        return
    var started_usec := Time.get_ticks_usec()
    await super._advance_simulation()
    if limit_battle_frame and runtime_session != null:
        runtime_session.multicamp_battle_frame_budget = -1
    var elapsed_usec := Time.get_ticks_usec()-started_usec
    performance_runtime_poll_count += 1
    performance_runtime_poll_usec_total += elapsed_usec
    performance_runtime_poll_usec_max = maxi(performance_runtime_poll_usec_max,elapsed_usec)
    var runtime_update_usec := int(get("performance_last_runtime_update_usec"))
    performance_runtime_update_usec_total += runtime_update_usec
    performance_runtime_update_usec_max = maxi(performance_runtime_update_usec_max,runtime_update_usec)
    var runtime_refresh_usec := int(get("performance_last_runtime_refresh_usec"))
    performance_runtime_refresh_usec_total += runtime_refresh_usec
    performance_runtime_refresh_usec_max = maxi(performance_runtime_refresh_usec_max,runtime_refresh_usec)
    var runtime_save_wait_usec := int(get("performance_last_runtime_save_wait_usec"))
    performance_runtime_save_wait_usec_total += runtime_save_wait_usec
    performance_runtime_save_wait_usec_max = maxi(performance_runtime_save_wait_usec_max,runtime_save_wait_usec)
func _autosave_runtime() -> void:
    if not performance_logging_enabled:
        await super._autosave_runtime()
        return
    var started_usec := Time.get_ticks_usec()
    await super._autosave_runtime()
    _record_pve_save_duration(Time.get_ticks_usec()-started_usec)
    var autosave_prepare_usec := int(get("performance_last_autosave_prepare_usec"))
    performance_autosave_prepare_usec_total += autosave_prepare_usec
    performance_autosave_prepare_usec_max = maxi(performance_autosave_prepare_usec_max,autosave_prepare_usec)
    var autosave_wait_usec := int(get("performance_last_autosave_wait_usec"))
    performance_autosave_wait_usec_total += autosave_wait_usec
    performance_autosave_wait_usec_max = maxi(performance_autosave_wait_usec_max,autosave_wait_usec)

func _record_pve_save_duration(elapsed_usec: int) -> void:
    if not performance_logging_enabled:
        return
    performance_save_count += 1
    performance_save_usec_total += elapsed_usec
    performance_save_usec_max = maxi(performance_save_usec_max,elapsed_usec)

func _record_pve_checkpoint_duration(elapsed_usec: int) -> void:
    if not performance_logging_enabled:
        return
    performance_checkpoint_count += 1
    performance_checkpoint_usec_total += elapsed_usec
    performance_checkpoint_usec_max = maxi(performance_checkpoint_usec_max,elapsed_usec)

func _record_hunt_refresh_stage(stage: String,elapsed_usec: int) -> void:
    if not performance_logging_enabled:
        return
    match stage:
        "snapshot_restore":
            performance_hunt_restore_usec_total += elapsed_usec
            performance_hunt_restore_usec_max = maxi(performance_hunt_restore_usec_max,elapsed_usec)
        "visual_rows":
            performance_hunt_visual_rows_usec_total += elapsed_usec
            performance_hunt_visual_rows_usec_max = maxi(performance_hunt_visual_rows_usec_max,elapsed_usec)
        "world_view_update":
            performance_hunt_view_update_usec_total += elapsed_usec
            performance_hunt_view_update_usec_max = maxi(performance_hunt_view_update_usec_max,elapsed_usec)
        "hud_update":
            performance_hunt_hud_update_usec_total += elapsed_usec
            performance_hunt_hud_update_usec_max = maxi(performance_hunt_hud_update_usec_max,elapsed_usec)

func _record_pathfinding_duration(elapsed_usec: int) -> void:
    if not performance_logging_enabled:
        return
    performance_move_pathfinding_count += 1
    performance_move_pathfinding_usec_total += elapsed_usec
    performance_move_pathfinding_usec_max = maxi(performance_move_pathfinding_usec_max,elapsed_usec)

func _refresh_building_management_controls_only() -> void:
    if not _building_operation_is_open() or building_management_container == null:
        return
    var current_frame := Engine.get_process_frames()
    if building_management_last_refresh_frame == current_frame:
        return
    _rebuild_building_management_controls()
    _style_building_management_actions(building_management_container)
    building_management_last_sim_tick = state.tick
    building_management_last_refresh_frame = current_frame


func _refresh_all() -> void:
    super._refresh_all()
    if state == null:
        return
    var hunt_overlay_open := _pve_hunt_overlay_is_open()
    _set_production_underlay_frozen(hunt_overlay_open)
    if iso_world != null and not hunt_overlay_open:
        var iso_refresh_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
        iso_world.refresh_from_state(state)
        if performance_logging_enabled:
            var iso_refresh_elapsed_usec := Time.get_ticks_usec()-iso_refresh_started_usec
            performance_iso_refresh_usec_total += iso_refresh_elapsed_usec
            performance_iso_refresh_usec_max = maxi(performance_iso_refresh_usec_max,iso_refresh_elapsed_usec)
        iso_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
        _refresh_map_worksite_cues()
        map_worksite_cues_dirty = false
        map_worksite_refresh_elapsed = 0.0
    if build_mode_panel != null and build_mode_panel.visible:
        _refresh_build_mode_panel()
    if _building_operation_is_open():
        _refresh_building_operation_content(building_management_last_sim_tick != state.tick)
    _refresh_gp1_first_minutes_guide()

func _pve_hunt_overlay_is_open() -> bool:
    if b3_hunt_panel == null or not is_instance_valid(b3_hunt_panel):
        return false
    var hunt_parent := b3_hunt_panel.get_parent() as CanvasItem
    return hunt_parent != null and hunt_parent.visible

func _map_worksite_is_supported(building: BuildingState) -> bool:
    return building != null and building.building_type in [
        BuildingSystem.TYPE_MINE,BuildingSystem.TYPE_LINH_FOREST,BuildingSystem.TYPE_SPIRIT_FIELD
    ]

func _map_worksite_metrics(building: BuildingState) -> Dictionary:
    return {
        "batches":maxi(0,int(building.metrics.get("production_batches",0))),
        "units":maxi(0,int(building.metrics.get("units_produced",0)))
    }

func _seed_map_worksite_receipts() -> void:
    map_worksite_receipt_baseline.clear()
    if state == null:
        return
    for raw_building in state.buildings.values():
        if raw_building is BuildingState and _map_worksite_is_supported(raw_building):
            var building: BuildingState = raw_building
            map_worksite_receipt_baseline[str(building.id)] = _map_worksite_metrics(building)

func _map_worksite_deliveries() -> Dictionary:
    var deliveries := {}
    if state == null:
        return deliveries
    for raw_building in state.buildings.values():
        if not (raw_building is BuildingState):
            continue
        var building: BuildingState = raw_building
        if not _map_worksite_is_supported(building):
            continue
        var key := str(building.id)
        var current := _map_worksite_metrics(building)
        if map_worksite_receipt_baseline.has(key):
            var previous: Dictionary = map_worksite_receipt_baseline[key]
            # Both counters advance only after the canonical Warehouse credit.
            if int(current["batches"]) > int(previous.get("batches",0)) and int(current["units"]) > int(previous.get("units",0)):
                deliveries[key] = int(current["units"])-int(previous.get("units",0))
        map_worksite_receipt_baseline[key] = current
    return deliveries

func _sect_production_type_name(building_type: StringName) -> String:
    match building_type:
        BuildingSystem.TYPE_MINE:
            return "Mỏ"
        BuildingSystem.TYPE_LINH_FOREST:
            return "Linh Lâm"
        BuildingSystem.TYPE_SPIRIT_FIELD:
            return "Linh Điền"
    return "Công trình"

func _map_worksite_snapshot(building: BuildingState) -> Dictionary:
    if not _map_worksite_is_supported(building) or state == null:
        return {}
    var type_title := _sect_production_type_name(building.building_type)
    var result := {
        "heading":type_title,"worker":"Chưa phân công","detail":"Chưa có người",
        "received":maxi(0,int(building.metrics.get("units_produced",0))),
        "progress":0.0,"active":false,"waiting":false
    }
    var assigned := BuildingSystem.new().assigned_worker_ids(state,building)
    if not assigned.is_empty():
        var assigned_id := StringName(assigned[0])
        result["worker"] = state.disciples[assigned_id].display_name if state.disciples.has(assigned_id) else str(assigned_id)
    if building.building_type in [BuildingSystem.TYPE_MINE,BuildingSystem.TYPE_LINH_FOREST]:
        var raw_jobs = building.production_state.get("economy_a_jobs",[])
        if raw_jobs is Array:
            for job in raw_jobs:
                if not (job is Dictionary):
                    continue
                var start_tick := int(job.get("started_tick",state.tick))
                var finish_tick := int(job.get("finish_tick",state.tick))
                var total := maxi(1,finish_tick-start_tick)
                var elapsed := clampi(state.tick-start_tick,0,total)
                var output_id := StringName(job.get("resource_id",""))
                var active_worker_id := StringName(job.get("worker_id",""))
                if active_worker_id != &"":
                    result["worker"] = state.disciples[active_worker_id].display_name if state.disciples.has(active_worker_id) else str(active_worker_id)
                result["heading"] = "%s · %s" % [type_title,ResourceRegistry.new().display_name(output_id)]
                result["detail"] = "Khai thác ×%d · %s" % [maxi(0,int(job.get("output_quantity",0))),"Chờ nhập Kho" if finish_tick <= state.tick else "còn %d phút mô phỏng" % (finish_tick-state.tick)]
                result["display_detail"] = "×%s · %s" % [SectProductionWorksiteCue._map_quantity(maxi(0,int(job.get("output_quantity",0)))),"chờ kho" if finish_tick <= state.tick else "%dp" % (finish_tick-state.tick)]
                result["progress"] = 100.0*float(elapsed)/float(total)
                result["active"] = true
                result["waiting"] = finish_tick <= state.tick
                return result
        var legacy_rows := _legacy_carry_cycle_rows(building)
        if not legacy_rows.is_empty():
            var row: Dictionary = legacy_rows[0]
            var output_id := StringName(row.get("resource_id", ""))
            var quantity := maxi(0, int(row.get("output_quantity", 0)))
            var remaining := maxi(0, int(row.get("remaining_ticks", 0)))
            result["worker"] = str(row.get("worker_name", result["worker"]))
            result["heading"] = "%s · %s" % [type_title, ResourceRegistry.new().display_name(output_id)]
            result["detail"] = str(row.get("phase_status", "Đang làm"))
            result["display_detail"] = "×%s · %dp" % [SectProductionWorksiteCue._map_quantity(quantity), remaining]
            result["progress"] = float(row.get("progress", 0.0))
            result["active"] = true
            return result
        result["detail"] = "Chờ lượt khai thác tiếp" if int(result["received"]) > 0 else ("Đã giao người · chờ lượt đầu" if not assigned.is_empty() else "Chưa phân công")
        return result
    var plot_data = building.production_state.get("plots",[])
    if not (plot_data is Array):
        result["detail"] = "Chờ đồng bộ ô đất"
        return result
    if not building.production_state.has("plots"):
        result["detail"] = "Chưa đồng bộ ô đất"
        return result
    var growing := 0
    var nearest: Dictionary = {}
    for raw_plot in plot_data:
        if not (raw_plot is Dictionary):
            continue
        var plot: Dictionary = raw_plot
        if StringName(plot.get("status","")) != BuildingSystem.PLOT_GROWING:
            continue
        growing += 1
        if nearest.is_empty() or int(plot.get("finish_tick",0)) < int(nearest.get("finish_tick",0)):
            nearest = plot
    result["heading"] = "Linh Điền · %d/%d ô" % [growing,plot_data.size()]
    if nearest.is_empty():
        result["detail"] = "Chưa trồng" if not assigned.is_empty() else "Chưa phân công"
        return result
    var plot_worker_id := StringName(nearest.get("assigned_worker_id",""))
    if plot_worker_id != &"":
        result["worker"] = state.disciples[plot_worker_id].display_name if state.disciples.has(plot_worker_id) else str(plot_worker_id)
    var start_tick := int(nearest.get("started_tick",state.tick))
    var finish_tick := int(nearest.get("finish_tick",state.tick))
    var total := maxi(1,finish_tick-start_tick)
    var elapsed := clampi(state.tick-start_tick,0,total)
    var yield_count := maxi(0,int(nearest.get("routine_yield",0)))
    var harvest_name := spirit_crop_registry.display_name(StringName(nearest.get("crop_id", "")))
    result["detail"] = "%s ×%d · %s" % [harvest_name, yield_count,"Chờ nhập Linh Kho" if finish_tick <= state.tick else "còn %d phút mô phỏng" % (finish_tick-state.tick)]
    result["display_detail"] = "%s ×%s · %s" % [spirit_crop_registry.display_name(StringName(nearest.get("crop_id",""))),SectProductionWorksiteCue._map_quantity(yield_count),"chờ kho" if finish_tick <= state.tick else "%dp" % (finish_tick-state.tick)]
    result["progress"] = 100.0*float(elapsed)/float(total)
    result["active"] = true
    result["waiting"] = finish_tick <= state.tick
    return result

func _map_worksite_operation_detail(building: BuildingState) -> String:
    var snapshot := _map_worksite_snapshot(building)
    if snapshot.is_empty():
        return ""
    var percentage := int(roundf(float(snapshot.get("progress",0.0)))) if bool(snapshot.get("active",false)) else 0
    return "TIẾN ĐỘ TẠI %s\n%s\nNgười thực hiện: %s\nMẻ/ETA: %s\nTiến độ: %d%% · ĐÃ NHẬP KHO: %d" % [
        building.display_name,str(snapshot.get("heading","")),str(snapshot.get("worker","")),
        str(snapshot.get("detail","")),percentage,int(snapshot.get("received",0))
    ]

func _map_worksite_layout_for_anchor(anchor: Vector2, occupied: Array) -> Dictionary:
    var zoom := maxf(map_layer.scale.x,0.1)
    var screen := SectMapCamera.world_to_screen(anchor,map_layer.position,zoom)
    var card := SectProductionWorksiteCue.CARD_SIZE
    var bounds := SectMapCamera.VIEW_RECT.grow(-6.0)
    var left := clampf(screen.x-card.x*0.5,bounds.position.x,bounds.end.x-card.x)
    for top in [screen.y-card.y-43.0,screen.y+22.0]:
        var box := Rect2(Vector2(left,top),card)
        if not bounds.encloses(box):
            continue
        var collides := false
        for used in occupied:
            if used is Rect2 and box.grow(5.0).intersects(used):
                collides = true
                break
        if not collides:
            return {"offset":box.position-screen,"rect":box}
    return {}

func _map_worksite_panel_exclusions() -> Array:
    var blocked: Array = []
    for panel in [building_operation_panel,disciple_summary_panel,b3_hunt_panel]:
        if panel is Control and is_instance_valid(panel) and panel.visible:
            blocked.append(Rect2(panel.global_position,panel.size).grow(4.0))
    return blocked

func _refresh_map_worksite_cues() -> void:
    if state == null or map_layer == null or iso_world == null:
        return
    var performance_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
    var deliveries := _map_worksite_deliveries()
    var candidates: Array[Dictionary] = []
    var ids: Array = state.buildings.keys()
    ids.sort()
    for raw_id in ids:
        var building: BuildingState = state.buildings[raw_id]
        if not _map_worksite_is_supported(building):
            continue
        var anchor := SectIsometricWorldV1.virtual_legacy_point(building.building_type,building.id,
            SectResidenceSiteV1.UNSELECTED,int(state.sect.world_layout_version))
        var screen := SectMapCamera.world_to_screen(anchor,map_layer.position,map_layer.scale.x)
        if not SectMapCamera.VIEW_RECT.grow(95.0).has_point(screen):
            continue
        var snapshot := _map_worksite_snapshot(building)
        var priority := 0
        if building.id == selected_production_instance_id:
            priority = 4
        elif deliveries.has(str(building.id)):
            priority = 3
        elif bool(snapshot.get("active",false)):
            priority = 2
        else:
            var old_cue := map_worksite_cues.get(str(building.id)) as SectProductionWorksiteCue
            if old_cue != null and is_instance_valid(old_cue) and old_cue.receipt != null and old_cue.receipt.visible:
                priority = 3
        candidates.append({"building":building,"anchor":anchor,"snapshot":snapshot,"priority":priority})
    candidates.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
        if int(a["priority"]) != int(b["priority"]):
            return int(a["priority"]) > int(b["priority"])
        return str((a["building"] as BuildingState).id) < str((b["building"] as BuildingState).id)
    )
    var retained := {}
    var occupied: Array = _map_worksite_panel_exclusions()
    for entry in candidates:
        if retained.size() >= MAP_WORKSITE_MAX_CUES:
            break
        if int(entry["priority"]) == 0:
            continue
        var building: BuildingState = entry["building"]
        var key := str(building.id)
        var anchor := Vector2(entry["anchor"])
        var layout := _map_worksite_layout_for_anchor(anchor,occupied)
        if layout.is_empty():
            continue
        occupied.append(layout["rect"])
        map_worksite_anchors[key] = anchor
        map_worksite_screen_offsets[key] = layout["offset"]
        var cue := map_worksite_cues.get(key) as SectProductionWorksiteCue
        if cue == null or not is_instance_valid(cue):
            cue = SectProductionWorksiteCue.new()
            cue.name = "MapWorksite_%s" % key
            map_layer.add_child(cue)
            cue.z_index = 9
            map_worksite_cues[key] = cue
        var actual_zoom := maxf(map_layer.scale.x,0.1)
        cue.scale = Vector2.ONE/actual_zoom
        cue.position = anchor+Vector2(layout["offset"])/actual_zoom
        cue.display(entry["snapshot"])
        # Keep real worksite receipts/progress, but do not paint through a
        # modal management, profile or combat surface.
        cue.visible = not _building_operation_is_open() and not _disciple_summary_is_open() and not opened_disciple_profile
        if deliveries.has(key):
            cue.show_delivered(int(deliveries[key]))
        retained[key] = true
    for key in map_worksite_cues.keys():
        if retained.has(key):
            continue
        var old_cue := map_worksite_cues[key] as SectProductionWorksiteCue
        if old_cue != null and is_instance_valid(old_cue):
            old_cue.queue_free()
        map_worksite_cues.erase(key)
        map_worksite_anchors.erase(key)
        map_worksite_screen_offsets.erase(key)
    map_worksite_last_scale = maxf(map_layer.scale.x,0.1)
    if performance_logging_enabled:
        var elapsed_usec := Time.get_ticks_usec()-performance_started_usec
        performance_map_worksite_refresh_count += 1
        performance_map_worksite_refresh_usec_total += elapsed_usec
        performance_map_worksite_refresh_usec_max = maxi(performance_map_worksite_refresh_usec_max,elapsed_usec)

func _refresh_map_worksite_cue_transforms() -> void:
    if map_layer == null:
        return
    var actual_zoom := maxf(map_layer.scale.x,0.1)
    var show_cues := not _building_operation_is_open() and not _disciple_summary_is_open() and not opened_disciple_profile
    for raw_key in map_worksite_cues.keys():
        var key := str(raw_key)
        var cue := map_worksite_cues[raw_key] as SectProductionWorksiteCue
        if cue == null or not is_instance_valid(cue) or not map_worksite_anchors.has(key):
            continue
        var anchor := Vector2(map_worksite_anchors[key])
        var screen_offset := Vector2(map_worksite_screen_offsets.get(key,Vector2.ZERO))
        cue.scale = Vector2.ONE/actual_zoom
        cue.position = anchor+screen_offset/actual_zoom
        cue.visible = show_cues

func _build_living_cue_layer() -> void:
    living_cue_layer = LivingCueLayer.new()
    living_cue_layer.name = "LivingCueLayer"
    living_cue_layer.position = Vector2.ZERO
    living_cue_layer.size = SectMapCamera.WORLD_SIZE
    living_cue_layer.cue_pressed.connect(_on_living_cue_pressed)
    map_layer.add_child(living_cue_layer)

func _refresh_living_cues() -> void:
    if living_cue_layer == null or not is_instance_valid(living_cue_layer):
        return

    var candidates := living_cue_resolver.resolve_state_cues(state, cultivation, equipment_system)
    var events := living_cue_tracker.observe(state, Time.get_ticks_msec())
    candidates.append_array(events)

    var candidate_anchors := _living_cue_anchor_positions(candidates)
    var camera_center := SectMapCamera.VIEW_RECT.position + SectMapCamera.VIEW_RECT.size * 0.5
    for cue_value in candidates:
        var cue: Dictionary = cue_value
        var key := str(cue.get("stable_key", ""))
        var anchor := Vector2(candidate_anchors.get(key, Vector2.ZERO))
        var screen_point := SectMapCamera.world_to_screen(anchor, map_layer.position, map_zoom)
        cue["in_view"] = SectMapCamera.VIEW_RECT.has_point(screen_point)
        cue["distance_to_camera"] = screen_point.distance_to(camera_center)

    visible_living_cues = living_cue_resolver.select_visible(candidates, 3)
    living_cue_layer.show_cues(visible_living_cues, _living_cue_anchor_positions(visible_living_cues))

func _refresh_living_cue_positions() -> void:
    if living_cue_layer == null or not is_instance_valid(living_cue_layer) or visible_living_cues.is_empty():
        return
    living_cue_layer.refresh_positions(visible_living_cues, _living_cue_anchor_positions(visible_living_cues))

func _living_cue_anchor_positions(cues: Array[Dictionary]) -> Dictionary:
    var positions: Dictionary = {}
    for cue_value in cues:
        var cue: Dictionary = cue_value
        var key := str(cue.get("stable_key", ""))
        if key == "":
            continue

        var target_kind := StringName(cue.get("target_kind", ""))
        var target_id := StringName(cue.get("target_id", ""))
        if target_kind == LivingCueResolver.TARGET_DISCIPLE:
            var actor_key := str(target_id)
            if actor_virtual_positions.has(actor_key):
                positions[key] = _disciple_map_point(StringName(target_id))
                continue
        elif target_kind == LivingCueResolver.TARGET_BUILDING:
            positions[key] = SectMapPresentation.position_for_destination(target_id)
            continue

        positions[key] = SectMapPresentation.position_for_destination(SectMapPresentation.DEST_COURTYARD)
    return positions

func _on_living_cue_pressed(cue: Dictionary) -> void:
    var target_kind := StringName(cue.get("target_kind", ""))
    var target_id := StringName(cue.get("target_id", ""))
    if target_kind == LivingCueResolver.TARGET_DISCIPLE:
        _open_disciple(target_id)
    elif target_kind == LivingCueResolver.TARGET_BUILDING:
        _open_building(target_id)

func _build_disciple_summary_panel() -> void:
    disciple_summary_panel = Panel.new()
    disciple_summary_panel.name = "DiscipleSummaryPanel"
    disciple_summary_panel.position = Vector2(956, 80)
    disciple_summary_panel.size = Vector2(308, 596)
    disciple_summary_panel.z_index = 60
    disciple_summary_panel.visible = false
    disciple_summary_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    disciple_summary_panel.add_theme_stylebox_override("panel", _style(PAPER_LIGHT, INK, 3, 14))
    add_child(disciple_summary_panel)

    disciple_summary_initial = _label(disciple_summary_panel, "?", Vector2(16, 16), Vector2(56, 56), 32)
    disciple_summary_initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    disciple_summary_initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    disciple_summary_initial.add_theme_color_override("font_color", JADE_DARK)

    disciple_summary_name = _label(disciple_summary_panel, "", Vector2(82, 14), Vector2(172, 30), 20)
    disciple_summary_name.add_theme_color_override("font_color", INK)

    disciple_summary_meta = _label(disciple_summary_panel, "", Vector2(82, 44), Vector2(176, 34), 13)
    disciple_summary_meta.add_theme_color_override("font_color", CINNABAR.darkened(0.12))

    var close := Button.new()
    close.name = "CloseSummary"
    close.text = "×"
    close.position = Vector2(252, 10)
    close.size = Vector2(44, 44)
    close.add_theme_font_size_override("font_size", 20)
    close.add_theme_stylebox_override("normal", _style(Color(0.86, 0.80, 0.66, 1.0), INK, 1, 16))
    close.pressed.connect(Callable(self, "_close_disciple_summary").bind(true))
    disciple_summary_panel.add_child(close)

    var separator := HSeparator.new()
    separator.position = Vector2(14, 82)
    separator.size = Vector2(280, 2)
    disciple_summary_panel.add_child(separator)

    disciple_summary_body = _label(disciple_summary_panel, "", Vector2(16, 94), Vector2(276, 294), 14)
    disciple_summary_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    disciple_summary_body.add_theme_color_override("font_color", INK)

    _add_summary_order_button("Tu luyện", Vector2(16, 398), Vector2(88, 38), WorkforceSystem.COMMAND_CULTIVATE)
    _add_summary_order_button("Nghỉ", Vector2(110, 398), Vector2(82, 38), WorkforceSystem.COMMAND_REST)
    _add_summary_order_button("Về tông", Vector2(198, 398), Vector2(94, 38), WorkforceSystem.COMMAND_RETURN_SECT)
    _add_summary_order_button("Khai khoáng", Vector2(16, 442), Vector2(132, 38), WorkforceSystem.COMMAND_WORK, str(WorkforceSystem.PROF_MINING))
    _add_summary_order_button("Luyện khí", Vector2(160, 442), Vector2(132, 38), WorkforceSystem.COMMAND_WORK, str(WorkforceSystem.PROF_FORGING))
    # V2 only: a real paid Body-training command replaces the legacy forge
    # shortcut at the same location. It does not act as a free EXP button.
    var body_button := Button.new()
    body_button.name = "SummaryV2BodyTraining"
    body_button.text = "Rèn thân"
    body_button.position = Vector2(160, 442)
    body_button.size = Vector2(132, 38)
    body_button.add_theme_font_size_override("font_size", 12)
    body_button.add_theme_stylebox_override("normal", _style(Color(0.88, 0.82, 0.67, 1.0), Color(0.45, 0.37, 0.25, 1.0), 1, 7))
    body_button.pressed.connect(_issue_v2_summary_body)
    body_button.visible = false
    disciple_summary_panel.add_child(body_button)

    var detail := Button.new()
    detail.name = "OpenDiscipleDetail"
    detail.text = "Xem chi tiết"
    detail.position = Vector2(16, 494)
    detail.size = Vector2(276, 42)
    detail.add_theme_font_size_override("font_size", 14)
    detail.add_theme_stylebox_override("normal", _style(CINNABAR, PAPER_LIGHT, 2, 9))
    detail.add_theme_stylebox_override("hover", _style(CINNABAR.lightened(0.08), GOLD, 3, 9))
    detail.pressed.connect(_open_selected_disciple_detail)
    disciple_summary_panel.add_child(detail)

    var hunt := Button.new()
    hunt.name = "SummaryB3Hunt"
    hunt.text = "Đi săn"
    hunt.position = Vector2(16, 492)
    hunt.size = Vector2(276, 40)
    hunt.add_theme_font_size_override("font_size", 14)
    hunt.add_theme_stylebox_override("normal", _style(JADE_DARK, PAPER_LIGHT, 2, 9))
    hunt.add_theme_stylebox_override("hover", _style(JADE, GOLD, 3, 9))
    hunt.pressed.connect(_start_b3_hunt_for_selected)
    disciple_summary_panel.add_child(hunt)

    var camp_hunt := Button.new()
    camp_hunt.name = "SummaryCampHunt"
    camp_hunt.text = "Đi săn thế giới JX"
    camp_hunt.position = Vector2(16, 540)
    camp_hunt.size = Vector2(276, 38)
    camp_hunt.add_theme_font_size_override("font_size", 13)
    camp_hunt.add_theme_stylebox_override("normal", _style(Color("d7c695"), INK, 1, 9))
    camp_hunt.add_theme_stylebox_override("hover", _style(Color("f0dcaa"), JADE_DARK, 2, 9))
    camp_hunt.pressed.connect(_start_multicamp_hunt_for_selected)
    disciple_summary_panel.add_child(camp_hunt)
    detail.position.y = 582

func _add_summary_order_button(text: String, pos: Vector2, button_size: Vector2, kind: StringName, target: String = "") -> void:
    var button := Button.new()
    button.text = text
    if kind == WorkforceSystem.COMMAND_WORK and target == str(WorkforceSystem.PROF_FORGING):
        button.name = "SummaryLegacyForge"
    button.position = pos
    button.size = button_size
    button.add_theme_font_size_override("font_size", 12)
    button.add_theme_stylebox_override("normal", _style(Color(0.88, 0.82, 0.67, 1.0), Color(0.45, 0.37, 0.25, 1.0), 1, 7))
    button.add_theme_stylebox_override("hover", _style(Color(0.97, 0.88, 0.64, 1.0), GOLD, 2, 7))
    button.pressed.connect(Callable(self, "_issue_summary_order").bind(kind, target, text))
    disciple_summary_panel.add_child(button)

func _disciple_summary_is_open() -> bool:
    return disciple_summary_panel != null and is_instance_valid(disciple_summary_panel) and disciple_summary_panel.visible

func _show_disciple_summary() -> void:
    if disciple_summary_panel == null or selected_id == &"" or not state.disciples.has(selected_id):
        return
    disciple_summary_panel.visible = true
    if camera_controls_panel != null:
        camera_controls_panel.visible = false
    if camera_hint != null:
        camera_hint.visible = false
    _refresh_disciple_summary_content()

func _hide_disciple_summary() -> void:
    if disciple_summary_panel != null:
        disciple_summary_panel.visible = false
    if camera_controls_panel != null:
        camera_controls_panel.visible = true
    if camera_hint != null:
        camera_hint.visible = true

func _close_disciple_summary(clear_selection: bool = true) -> void:
    _hide_disciple_summary()
    summary_feedback = ""
    if not clear_selection:
        return
    selected_id = &""
    deep_restore_summary = false
    if focused_kind == &"disciple":
        focused_kind = &""
        focused_id = &""
        focused_label = ""
        has_focus_target = false
        if focus_marker != null:
            focus_marker.visible = false
        if focus_target_button != null:
            focus_target_button.disabled = true
        _refresh_focus_readout()


func _refresh_disciple_summary_content() -> void:
    if not _disciple_summary_is_open() or selected_id == &"" or not state.disciples.has(selected_id):
        return
    var disciple: DiscipleState = state.disciples[selected_id]
    var snapshot := _disciple_snapshot(disciple)
    disciple_summary_initial.text = disciple.display_name.substr(0, 1)
    disciple_summary_name.text = disciple.display_name
    if not bool(snapshot.get("ok", false)):
        disciple_summary_meta.text = "Dữ liệu chưa sẵn sàng"
        disciple_summary_body.text = "Không thể đọc hồ sơ đệ tử hiện tại."
        return

    var authentic_v2 := bool(snapshot.get("authentic_v2", false))
    var legacy_forge: Button = disciple_summary_panel.get_node_or_null("SummaryLegacyForge")
    var v2_body: Button = disciple_summary_panel.get_node_or_null("SummaryV2BodyTraining")
    var hunt_button: Button = disciple_summary_panel.get_node_or_null("SummaryB3Hunt")
    var camp_hunt_button: Button = disciple_summary_panel.get_node_or_null("SummaryCampHunt")
    if legacy_forge != null:
        legacy_forge.visible = not authentic_v2
    if v2_body != null:
        v2_body.visible = authentic_v2
    if hunt_button != null:
        hunt_button.visible = authentic_v2
        var hunt_state: Dictionary = state.sect.b3_hunt
        var member := str(hunt_state.get("member",""))
        var care_id := str(hunt_state.get("care",{}).get("disciple_id",""))
        var owner_id := member if not member.is_empty() else care_id
        var same_world_owner := hunt_state.is_empty() or owner_id.is_empty() or owner_id == str(disciple.id)
        var reopening_existing := not hunt_state.is_empty() and owner_id == str(disciple.id)
        var admission := B3HuntWorld.admission(state,disciple.id) if same_world_owner and not reopening_existing and member != str(disciple.id) else {"ok":same_world_owner}
        hunt_button.text = "Mở vòng săn" if reopening_existing else "Đi săn"
        hunt_button.disabled = not same_world_owner or not bool(admission.get("ok",false))
        hunt_button.tooltip_text = "" if not hunt_button.disabled else str(admission.get("reason","thế giới đang có đệ tử khác"))
    if camp_hunt_button != null:
        var active_camp_id := HuntingPveRunV2.active_multicamp_id(state)
        var already_in_camp := false
        if not active_camp_id.is_empty():
            var camp_snapshot: Dictionary = state.sect.v2_pve_active_runs[active_camp_id]
            var decoded := MapBattleSnapshotV2.load(camp_snapshot.get("battle",{}))
            if bool(decoded.get("ok",false)):
                var camp_battle: MapBattleV2 = decoded["battle"]
                already_in_camp = camp_battle.actors.has(str(selected_id))
        camp_hunt_button.visible = authentic_v2
        camp_hunt_button.text = "Mở bãi đang săn" if already_in_camp else ("Tham gia bãi đang săn" if not active_camp_id.is_empty() else "Đi săn tự do")
        camp_hunt_button.disabled = not already_in_camp and (not _multicamp_member_eligible(state.disciples[selected_id]) or not state.sect.b3_hunt.is_empty())
        camp_hunt_button.tooltip_text = "Săn riêng hoặc lập tổ tối đa 6; chung bản đồ 30 người. SaveService thật." if not camp_hunt_button.disabled else "Đệ tử đang bận, bị thương hoặc thế giới săn khác đang hoạt động."
    var identity: Dictionary = snapshot["identity"]
    var quality := str(identity.get("quality_name", "—"))
    if quality.is_empty():
        quality = "—"
    if bool(snapshot.get("authentic_v2", false)):
        var progression: Dictionary = snapshot["progression"]
        if bool(progression.get("ready", false)):
            var tuvi: Dictionary = progression["cultivation"]
            disciple_summary_meta.text = "%s · %s tầng %d" % [
                quality, str(tuvi["name"]), int(tuvi["floor"])
            ]
        else:
            disciple_summary_meta.text = "%s · Tiến độ chưa sẵn sàng" % quality
    else:
        disciple_summary_meta.text = "%s · %s" % [quality, cultivation.stage_name(disciple)]
    disciple_summary_body.text = _disciple_summary_text(disciple)
    if authentic_v2 and state.sect.economy_a_enabled:
        disciple_summary_meta.text += " · %d Linh Thạch cá nhân" % disciple.spirit_stones

func _build_b3_hunt_panel() -> void:
    var shade := ColorRect.new()
    shade.name = "B3MainHuntShade"
    shade.color = Color(0.03,0.06,0.07,0.78)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.z_index = 110
    shade.mouse_filter = Control.MOUSE_FILTER_STOP
    shade.visible = false
    add_child(shade)

    b3_hunt_panel = Panel.new()
    b3_hunt_panel.name = "B3MainHuntPanel"
    b3_hunt_panel.position = Vector2(64,38)
    b3_hunt_panel.size = Vector2(1152,644)
    b3_hunt_panel.z_index = 111
    b3_hunt_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    b3_hunt_panel.add_theme_stylebox_override("panel",_style(PAPER_LIGHT,INK,3,14))
    b3_hunt_panel.visible = false
    shade.add_child(b3_hunt_panel)

    b3_hunt_title = _label(b3_hunt_panel,"THẾ GIỚI SĂN QUÁI — LIỀN MẠCH",Vector2(24,14),Vector2(1100,32),22)
    b3_hunt_title.name = "B3HuntTitle"
    b3_hunt_title.add_theme_color_override("font_color",JADE_DARK)
    b3_hunt_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
    b3_hunt_subtitle = _label(b3_hunt_panel,"Rừng Source A liền mạch · click đất để đi · quái di chuyển và đánh tại chỗ · Combat V2 / clock / SaveService màn chính",Vector2(26,48),Vector2(1090,24),13)
    b3_hunt_subtitle.name = "B3HuntSubtitle"
    b3_hunt_subtitle.add_theme_color_override("font_color",INK)
    b3_hunt_subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE

    b3_hunt_arena = B3MainHuntArena.new()
    b3_hunt_arena.name = "B3MainHuntArena"
    b3_hunt_arena.position = Vector2(24,82)
    b3_hunt_arena.size = Vector2(700,484)
    b3_hunt_arena.add_theme_stylebox_override("panel",_style(JADE_DARK,INK,1,8))
    b3_hunt_panel.add_child(b3_hunt_arena)
    # The map must draw below its compact HUD while retaining the full click surface.
    b3_hunt_panel.move_child(b3_hunt_arena,0)
    b3_pve_world_view = b3_hunt_arena.sect_world
    b3_pve_world_view.move_ordered.connect(_on_open_world_move_ordered)
    b3_pve_world_view.hunt_policy_ordered.connect(_on_p0_hunt_policy_ordered)

    var facts_panel := Panel.new()
    facts_panel.name = "B3MainHuntFactsPanel"
    facts_panel.position = Vector2(746,82)
    facts_panel.size = Vector2(382,484)
    facts_panel.add_theme_stylebox_override("panel",_style(Color("eee6d2"),Color("74694f"),1,8))
    b3_hunt_panel.add_child(facts_panel)
    b3_hunt_facts_panel = facts_panel
    b3_hunt_combat_view = B3MainHuntCombatView.new()
    b3_hunt_combat_view.name = "B3PveCombatV5View"
    b3_hunt_combat_view.position = Vector2(16,12)
    b3_hunt_combat_view.size = Vector2(350,232)
    b3_hunt_combat_view.add_theme_stylebox_override("panel",_style(JADE_DARK,INK,1,6))
    b3_hunt_combat_view.visible = false
    facts_panel.add_child(b3_hunt_combat_view)
    b3_hunt_arena.combat_view = b3_hunt_combat_view
    b3_hunt_arena.presenter.name = "B3CareCombatV5Presenter"
    b3_hunt_facts = _label(facts_panel,"",Vector2(16,14),Vector2(350,452),15)
    b3_hunt_facts.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    b3_hunt_facts.add_theme_color_override("font_color",INK)
    v63_combat_hud = V63CombatHudV1.new()
    v63_combat_hud.name = "V63CombatHudV1"
    v63_combat_hud.position = Vector2(6,6)
    v63_combat_hud.size = Vector2(370,472)
    v63_combat_hud.visible = false
    v63_combat_hud.archive_requested.connect(_open_v63_archive)
    v63_combat_hud.preview_gate_toggled.connect(_on_v63_preview_gate_toggled)
    b3_hunt_panel.add_child(v63_combat_hud)
    b3_hunt_world_status = Label.new()
    b3_hunt_world_status.name = "B3MainHuntStatus"
    b3_hunt_world_status.position = Vector2(12,10)
    b3_hunt_world_status.size = Vector2(258,86)
    b3_hunt_world_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    b3_hunt_world_status.add_theme_font_size_override("font_size",11)
    b3_hunt_world_status.add_theme_color_override("font_color",Color("f3efdd"))
    b3_hunt_world_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
    b3_hunt_world_status.visible = false
    facts_panel.add_child(b3_hunt_world_status)
    b3_hunt_feedback = _label(b3_hunt_panel,"",Vector2(28,578),Vector2(510,42),13)
    b3_hunt_feedback.add_theme_color_override("font_color",CINNABAR)

    b3_hunt_save_button = Button.new()
    b3_hunt_save_button.name = "B3MainHuntSave"
    b3_hunt_save_button.text = "Lưu game"
    b3_hunt_save_button.position = Vector2(550,580)
    b3_hunt_save_button.size = Vector2(132,46)
    b3_hunt_save_button.add_theme_font_size_override("font_size",14)
    b3_hunt_save_button.add_theme_stylebox_override("normal",_style(Color("d7c695"),INK,1,8))
    b3_hunt_save_button.pressed.connect(_save_b3_main_runtime)
    b3_hunt_panel.add_child(b3_hunt_save_button)

    var summary_hunt_button: Button = disciple_summary_panel.get_node_or_null("SummaryCampHunt")
    if summary_hunt_button != null:
        summary_hunt_button.text = "Vào Thanh Trúc Lâm · thế giới liên tục"

    b3_hunt_auto_button = Button.new()
    b3_hunt_auto_button.name = "B3MainHuntAuto"
    b3_hunt_auto_button.position = Vector2(746,580)
    b3_hunt_auto_button.size = Vector2(120,46)
    b3_hunt_auto_button.add_theme_font_size_override("font_size",15)
    b3_hunt_auto_button.add_theme_color_override("font_color", PAPER_LIGHT)
    b3_hunt_auto_button.add_theme_stylebox_override("normal",_style(JADE_DARK,PAPER_LIGHT,2,8))
    b3_hunt_auto_button.pressed.connect(_toggle_b3_hunt_auto)
    b3_hunt_panel.add_child(b3_hunt_auto_button)

    b3_hunt_deploy_button = Button.new()
    b3_hunt_deploy_button.name = "B3MainHuntDeploy"
    b3_hunt_deploy_button.text = "Phái đệ tử"
    b3_hunt_deploy_button.position = Vector2(876,580)
    b3_hunt_deploy_button.size = Vector2(120,46)
    b3_hunt_deploy_button.add_theme_font_size_override("font_size",15)
    b3_hunt_deploy_button.add_theme_stylebox_override("normal",_style(Color("d7c695"),INK,1,8))
    b3_hunt_deploy_button.pressed.connect(_deploy_b3_hunt_disciple)
    b3_hunt_panel.add_child(b3_hunt_deploy_button)

    b3_hunt_return_button = Button.new()
    b3_hunt_return_button.name = "B3MainHuntReturn"
    b3_hunt_return_button.text = "Về tông môn"
    b3_hunt_return_button.position = Vector2(1006,580)
    b3_hunt_return_button.size = Vector2(122,46)
    b3_hunt_return_button.add_theme_font_size_override("font_size",14)
    b3_hunt_return_button.add_theme_stylebox_override("normal",_style(CINNABAR,PAPER_LIGHT,2,8))
    b3_hunt_return_button.pressed.connect(_return_from_b3_hunt)
    b3_hunt_panel.add_child(b3_hunt_return_button)
    p0_add_hunter_button = Button.new()
    p0_add_hunter_button.name = "PveP0AddHunter"
    p0_add_hunter_button.text = "+ Đệ tử"
    p0_add_hunter_button.pressed.connect(_open_p0_join_picker)
    p0_add_hunter_button.visible = false
    b3_hunt_panel.add_child(p0_add_hunter_button)
    p0_withdraw_hunter_button = Button.new()
    p0_withdraw_hunter_button.name = "PveP0WithdrawHunter"
    p0_withdraw_hunter_button.text = "Rút 1 người"
    p0_withdraw_hunter_button.tooltip_text = "Chọn đúng một đệ tử trên bản đồ, sau đó rút riêng"
    p0_withdraw_hunter_button.pressed.connect(_withdraw_selected_p0_hunter)
    p0_withdraw_hunter_button.visible = false
    b3_hunt_panel.add_child(p0_withdraw_hunter_button)
    p0_close_map_button = Button.new()
    p0_close_map_button.name = "PveP0CloseMap"
    p0_close_map_button.text = "Đóng bản đồ"
    p0_close_map_button.tooltip_text = "Ẩn bản đồ, không rút người và không dừng săn"
    p0_close_map_button.pressed.connect(_close_p0_hunt_map)
    p0_close_map_button.visible = false
    b3_hunt_panel.add_child(p0_close_map_button)

func _resume_saved_b3_hunt() -> void:
    var active_camp_id := HuntingPveRunV2.active_multicamp_id(state)
    if not active_camp_id.is_empty():
        var restored_camp := _active_multicamp_session(active_camp_id)
        if bool(restored_camp.get("ok",false)):
            var camp_session: HuntingPveRunV2 = restored_camp["session"]
            for actor in camp_session.battle.actors.values():
                if str(actor.get("side","")) == "disciple":
                    _open_multicamp_panel(StringName(str(actor["id"])),active_camp_id)
                    return
    var active_boss_id := HuntingPveRunV2.active_single_encounter_id(state)
    if not active_boss_id.is_empty():
        var restored_boss := HuntingPveRunV2.resume_active(state,active_boss_id,_current_v63_preview_overrides())
        if bool(restored_boss.get("ok",false)):
            var boss_session: HuntingPveRunV2 = restored_boss["session"]
            for actor_id in boss_session.battle.actors:
                var actor: Dictionary = boss_session.battle.actors[actor_id]
                if str(actor.get("side","")) == "disciple":
                    _open_v63_boss_panel(StringName(str(actor_id)),active_boss_id)
                    return
    if state.sect.b3_hunt.is_empty():
        return
    var world: Dictionary = state.sect.b3_hunt
    var id := StringName(world.get("member",""))
    if id == &"":
        id = StringName(world.get("care",{}).get("disciple_id",""))
    if id == &"":
        id = StringName(world.get("last_return",{}).get("disciple_id",""))
    if id == &"" or not state.disciples.has(id):
        return
    b3_hunt_disciple_id = id
    _open_b3_hunt_panel(id)
func _open_b3_hunt_panel(disciple_id: StringName) -> void:
    if b3_hunt_panel == null or not state.disciples.has(disciple_id):
        return
    b3_hunt_disciple_id = disciple_id
    active_hunt_mode = "care"
    selected_id = disciple_id
    _hide_disciple_summary()
    b3_hunt_panel.get_parent().visible = true
    b3_hunt_panel.visible = true
    _set_production_underlay_frozen(true)
    b3_hunt_refresh_elapsed = B3_HUNT_REFRESH_SECONDS
    _refresh_b3_hunt_panel()

func _open_multicamp_panel(disciple_id: StringName, encounter_id: String) -> void:
    if b3_hunt_panel == null or not state.disciples.has(disciple_id):
        return
    active_hunt_mode = "multicamp"
    multicamp_encounter_id = encounter_id
    b3_hunt_disciple_id = disciple_id
    selected_id = disciple_id
    _hide_disciple_summary()
    b3_hunt_panel.get_parent().visible = true
    b3_hunt_panel.visible = true
    _set_production_underlay_frozen(true)
    b3_hunt_refresh_elapsed = B3_HUNT_REFRESH_SECONDS
    _refresh_b3_hunt_panel()

func _start_b3_hunt_for_selected() -> void:
    if selected_id == &"" or not state.disciples.has(selected_id) or runtime_session == null:
        return
    var world: Dictionary = state.sect.b3_hunt
    var member := str(world.get("member",""))
    var care_id := str(world.get("care",{}).get("disciple_id",""))
    var result: Dictionary
    if not world.is_empty() and (member == str(selected_id) or (member.is_empty() and care_id == str(selected_id))):
        result = {"ok":true}
    elif not member.is_empty():
        result = {"ok":false,"reason":"b3_world_has_another_disciple"}
    else:
        result = B3HuntWorld.begin(runtime_session.owner,selected_id)
    if not bool(result.get("ok",false)):
        summary_feedback = "Chưa thể đi săn: %s" % str(result.get("reason","không đủ điều kiện"))
        _refresh_disciple_summary_content()
        return
    _open_b3_hunt_panel(selected_id)
    _refresh_all()

func _start_multicamp_hunt_for_selected() -> void:
    if selected_id == &"" or runtime_session == null or not state.disciples.has(selected_id):
        return
    var existing := HuntingPveRunV2.active_multicamp_id(state)
    if not existing.is_empty():
        var restored := _active_multicamp_session(existing)
        if not bool(restored.get("ok",false)):
            summary_feedback = "Không mở được bãi đã lưu: %s" % str(restored.get("reason","invalid save"))
            _refresh_disciple_summary_content()
            return
        var saved_session: HuntingPveRunV2 = restored["session"]
        if saved_session.battle.actors.has(str(selected_id)):
            _open_multicamp_panel(selected_id,existing)
            return
        var joined := PveP0CommandsV1.join_one(runtime_session.owner,str(selected_id))
        if not bool(joined.get("ok",false)):
            summary_feedback = "Chưa tham gia được: %s" % str(joined.get("reason","unknown"))
            _refresh_disciple_summary_content()
            return
        var persisted := await _save_runtime_async_barrier()
        if not bool(persisted.get("ok",false)):
            summary_feedback = "Đã tham gia trong phiên; Save lỗi: %s" % str(persisted.get("reason",persisted.get("error","unknown")))
            _refresh_disciple_summary_content()
            return
        _open_multicamp_panel(selected_id,existing)
        _refresh_all()
        return
    _open_pve_party_picker()
    if pve_party_picker_shade != null and pve_party_picker_shade.visible             and _multicamp_member_eligible(state.disciples[selected_id]):
        pve_party_selected_ids = [selected_id]
        _populate_pve_party_picker()

func _multicamp_party_for_selected(first_id: StringName) -> Array:
    if not state.disciples.has(first_id) or not _multicamp_member_eligible(state.disciples[first_id]):
        return []
    var candidates: Array[StringName] = [first_id]
    var ids: Array = state.disciples.keys()
    var available: Array[Dictionary] = []
    for raw_id in ids:
        var id := StringName(raw_id)
        if id == first_id:
            continue
        var disciple: DiscipleState = state.disciples[id]
        if _multicamp_member_eligible(disciple):
            available.append({"id":id,"rating":_multicamp_combat_rating(disciple)})
    available.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
        var a_score := float(a["rating"])
        var b_score := float(b["rating"])
        if not is_equal_approx(a_score,b_score):
            return a_score > b_score
        return str(a["id"]) < str(b["id"]))
    for candidate in available:
        if candidates.size() >= 6:
            break
        candidates.append(StringName(candidate["id"]))
    if candidates.size() != 6:
        return []
    return _multicamp_party_for_ids(candidates)

func _multicamp_party_for_ids(member_ids: Array) -> Array:
    var result: Array = []
    if member_ids.size() != 6:
        return result
    var candidates: Array[StringName] = []
    var seen: Dictionary = {}
    for raw_id in member_ids:
        var id := StringName(str(raw_id))
        if seen.has(id) or not state.disciples.has(id) \
                or not _multicamp_member_eligible(state.disciples[id]):
            return []
        seen[id] = true
        candidates.append(id)
    for i in range(candidates.size()):
        var id := candidates[i]
        var disciple: DiscipleState = state.disciples[id]
        var profile: Dictionary = DiscipleRealmProgressV2.current(disciple)
        var cultivation: Dictionary = profile["cultivation"]
        var body: Dictionary = profile["body"]
        var role := "frontline" if i < 2 else ("mage" if i == 2 else ("healer" if i == 3 else "ranged"))
        result.append({
            "disciple_id":str(id),"party_id":"thanh_truc_lam_c01_party",
            "role":role,"position":Vector2(8.0+float(i%3)*0.55,8.7+float(int(i/3))*0.55),
            "realm":int(cultivation["realm"]),"floor":int(cultivation["floor"]),
            "body_realm":int(body["realm"]),"body_floor":int(body["floor"])
        })
    return result

func _multicamp_combat_rating(disciple: DiscipleState) -> float:
    if disciple == null or not DiscipleRealmProgressV2.valid_profile(disciple.v2_realm_progress):
        return -INF
    var profile: Dictionary = DiscipleRealmProgressV2.current(disciple)
    var cultivation: Dictionary = profile["cultivation"]
    var body: Dictionary = profile["body"]
    var preview := DiscipleCombatLoadoutV2.build(state,disciple,
        int(cultivation["realm"]),int(cultivation["floor"]),
        int(body["realm"]),int(body["floor"]),"frontline",Vector2.ZERO,"pve_rating")
    if not bool(preview.get("ok",false)):
        return -INF
    var stats: Dictionary = preview["stats"]
    var current_hp := float(preview.get("hp",0.0))
    var learned_skill_bonus := float((preview.get("skill_factors",{}) as Dictionary).size())*20.0
    return (
        current_hp+float(stats.get("max_hp",0.0))*0.35
        +float(stats.get("attack",0.0))*3.0
        +float(stats.get("defense",0.0))*2.0+learned_skill_bonus
    )

func _multicamp_member_eligible(disciple: DiscipleState) -> bool:
    return _multicamp_member_eligibility_reason(disciple).is_empty()

func _multicamp_member_eligibility_reason(disciple: DiscipleState) -> String:
    if disciple == null:
        return "Không tìm thấy đệ tử"
    if not DiscipleRealmProgressV2.progression_ready(disciple):
        return "Hồ sơ V2 chưa sẵn sàng"
    if disciple.hp <= 0.0:
        return "Đã gục, cần hồi phục"
    if disciple.injury_level != 0:
        return "Đang bị thương"
    if not disciple.active_pve_encounter_id.is_empty():
        return "Đang ở một bãi săn khác"
    if disciple.region_id != &"sect":
        return "Chưa trở về tông môn"
    if not [&"EVALUATE",&"IDLE",&"HOLD"].has(disciple.current_action):
        return "Đang có công việc hoặc công lệnh"
    var buildings := BuildingSystem.new()
    if not disciple.work_cycle_state.is_empty() or disciple.worksite_building_id != &"" \
            or not disciple.work_progress.is_empty():
        return "Đang làm việc"
    if buildings.disciple_has_active_spirit_plot(state,disciple.id):
        return "Đang chăm Linh Điền"
    if buildings.disciple_has_active_timed_recipe(state,disciple.id):
        return "Đang chế tạo theo lệnh"
    if not buildings.active_resource_timer_for_worker(state,disciple.id).is_empty():
        return "Đang có tác vụ khai thác"
    if DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,disciple):
        return "Đang rèn thân"
    return ""

func _toggle_b3_hunt_auto() -> void:
    if active_hunt_mode == "multicamp":
        var world_id := HuntingPveRunV2.active_multicamp_id(state)
        var restored_world := _active_multicamp_session(world_id) if not world_id.is_empty() else {"ok":false}
        if not bool(restored_world.get("ok",false)) or runtime_session == null:
            _set_b3_hunt_feedback("Chưa đổi được AUTO: không mở được world đã lưu.")
            return
        var world_session: HuntingPveRunV2 = restored_world["session"]
        var world_auto := world_session.battle.set_auto_hunt(not world_session.battle.auto_hunt)
        if bool(world_auto.get("ok",false)):
            world_session._persist_live_state()
            var saved_world := await _save_runtime_async_barrier()
            _set_b3_hunt_feedback("AUTO săn liên vùng %s%s" % [
                "đã bật" if bool(world_auto["enabled"]) else "đã tắt",
                " · cần thử lưu lại" if not bool(saved_world.get("ok",false)) else ""])
        else:
            _set_b3_hunt_feedback("Không đổi được AUTO: %s" % str(world_auto.get("reason","unknown")))
        _refresh_b3_hunt_panel()
        return
    var id := _active_b3_hunt_disciple_id()
    if id == &"" or runtime_session == null:
        return
    var care: Dictionary = state.sect.b3_hunt.get("care",{})
    var enabled := not bool(care.get("auto_hunt",false))
    var result := B3MedicalAutoplayV1.configure(runtime_session.owner,id,enabled)
    if result.get("ok",false):
        _set_b3_hunt_feedback("AUTO %s" % ("đã bật" if enabled else "đã tắt"))
    else:
        _set_b3_hunt_feedback("Không đổi AUTO: %s" % str(result.get("reason","lệnh chưa sẵn sàng")))
    _refresh_b3_hunt_panel()

func _on_open_world_move_ordered(actor_ids: Array, destination: Vector2) -> void:
    if runtime_session == null:
        return
    var encounter := HuntingPveRunV2.active_multicamp_id(state)
    var restored := _active_multicamp_session(encounter) if not encounter.is_empty() else {"ok":false}
    if not bool(restored.get("ok",false)):
        _set_b3_hunt_feedback("Không ra lệnh di chuyển: world không khôi phục được.")
        return
    var session: HuntingPveRunV2 = restored["session"]
    if PveDistributedWorldV1.enabled(session.camp_population):
        var moved := PveP0CommandsV1.move(runtime_session.owner,actor_ids,destination)
        if not bool(moved.get("ok",false)):
            _set_b3_hunt_feedback("Không di chuyển được: %s" % str(moved.get("reason","unknown")))
            return
        var persisted := await _save_runtime_async_barrier()
        _set_b3_hunt_feedback("Đã ra lệnh di chuyển %d đệ tử." % actor_ids.size()
            if bool(persisted.get("ok",false))
            else "Đã ra lệnh nhưng Save chưa thành công.")
        _refresh_b3_hunt_panel()
        return
    var eligible: Array[String] = []
    for raw_id in actor_ids:
        var id := str(raw_id)
        var actor: Dictionary = session.battle.actors.get(id,{})
        if str(actor.get("side","")) == "disciple" and float(actor.get("hp",0.0)) > 0.0 and not eligible.has(id):
            eligible.append(id)
    eligible.sort()
    if eligible.is_empty():
        _set_b3_hunt_feedback("Không ra lệnh di chuyển: chưa có đệ tử sống được chọn.")
        return
    var offsets := _open_world_group_formation_offsets(eligible.size())
    var base_cell := Vector2i(floori(destination.x),floori(destination.y))
    var assigned_slots: Dictionary = {}
    for index in range(eligible.size()):
        var pathfinding_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
        var slot := _open_world_nearest_free_formation_cell(
            session.battle,base_cell+offsets[index],assigned_slots)
        if slot.x < 0:
            if performance_logging_enabled:
                _record_pathfinding_duration(Time.get_ticks_usec()-pathfinding_started_usec)
            _set_b3_hunt_feedback("Không tìm đủ ô trống để tách đội hình.")
            return
        var ordered := session.battle.order_group_move(
            [eligible[index]],Vector2(slot)+Vector2(0.5,0.5))
        if performance_logging_enabled:
            _record_pathfinding_duration(Time.get_ticks_usec()-pathfinding_started_usec)
        if not bool(ordered.get("ok",false)):
            _set_b3_hunt_feedback("Không đi tới được vị trí: %s" % str(ordered.get("reason","ô không đi được")))
            return
        assigned_slots[slot] = true
    var checkpoint_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
    var checkpoint := session._persist_live_state()
    if performance_logging_enabled:
        _record_pve_checkpoint_duration(Time.get_ticks_usec()-checkpoint_started_usec)
    var saved := await _save_runtime_async_barrier() if bool(checkpoint.get("ok",false)) else checkpoint
    _set_b3_hunt_feedback("Đã ra lệnh đội %d người tới ô địa hình; trạng thái đã lưu." % actor_ids.size() if bool(saved.get("ok",false)) else "Di chuyển đã ra lệnh; Save cần thử lại.")
    _refresh_b3_hunt_panel()

func _open_world_group_formation_offsets(count: int) -> Array[Vector2i]:
    match count:
        1:
            return [Vector2i.ZERO]
        2:
            return [Vector2i(-1,0),Vector2i(1,0)]
        3:
            return [Vector2i(-1,-1),Vector2i(1,-1),Vector2i(0,1)]
        4:
            return [Vector2i(-1,-1),Vector2i(1,-1),Vector2i(-1,1),Vector2i(1,1)]
        _:
            return [Vector2i(-3,-2),Vector2i(0,-2),Vector2i(3,-2),
                Vector2i(-3,2),Vector2i(0,2),Vector2i(3,2)]

func _open_world_nearest_free_formation_cell(battle: MapBattleV2,
        desired: Vector2i,assigned: Dictionary) -> Vector2i:
    var navigation: Dictionary = battle.world_navigation
    var width := int(navigation.get("width",0))
    var height := int(navigation.get("height",0))
    var blocked: Array = navigation.get("blocked",[])
    if width <= 0 or height <= 0 or blocked.is_empty():
        return Vector2i(-1,-1)
    for radius in range(0,8):
        for y in range(-radius,radius+1):
            for x in range(-radius,radius+1):
                if maxi(absi(x),absi(y)) != radius:
                    continue
                var candidate := desired+Vector2i(x,y)
                if candidate.x < 0 or candidate.y < 0 or candidate.x >= width or candidate.y >= height:
                    continue
                if int(blocked[candidate.y*width+candidate.x]) != 0 or assigned.has(candidate):
                    continue
                var spaced := true
                for raw_slot in assigned.keys():
                    var existing_slot: Vector2i = raw_slot
                    if candidate.distance_squared_to(existing_slot) < 6.25:
                        spaced = false
                        break
                if spaced:
                    return candidate
    return Vector2i(-1,-1)

func _save_runtime_async_barrier() -> Dictionary:
    if runtime_session == null:
        return {"ok":false,"reason":"live_runtime_unavailable"}
    while runtime_poll_pending:
        await get_tree().process_frame
    runtime_poll_pending = true
    var started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
    var result := runtime_session.save_async()
    if bool(result.get("ok",false)) and bool(result.get("pending",false)):
        result = await runtime_session.wait_for_pending_save(get_tree())
    runtime_poll_pending = false
    if performance_logging_enabled:
        _record_pve_save_duration(Time.get_ticks_usec()-started_usec)
    return result

func _save_b3_main_runtime() -> void:
    if runtime_session == null:
        return
    b3_hunt_save_button.disabled = true
    var result := await _save_runtime_async_barrier()
    if result.get("ok",false):
        _set_b3_hunt_feedback("Đã lưu qua SaveService màn chính.")
    else:
        _set_b3_hunt_feedback("Lưu chưa xong: %s" % str(result.get("reason",result.get("error","unknown"))))
    _refresh_b3_hunt_panel()

func _deploy_b3_hunt_disciple() -> void:
    var id := _active_b3_hunt_disciple_id()
    if id == &"" or runtime_session == null:
        return
    var result := B3HuntWorld.begin(runtime_session.owner,id)
    _set_b3_hunt_feedback("Đã phái đệ tử ra săn." if result.get("ok",false) else "Chưa thể phái: %s" % str(result.get("reason","không đủ điều kiện")))
    _refresh_all()
    _refresh_b3_hunt_panel()

func _return_from_b3_hunt() -> void:
    if runtime_session == null:
        return
    if active_hunt_mode == "v63_boss":
        var saved_boss := await _save_runtime_async_barrier()
        if not bool(saved_boss.get("ok",false)):
            _set_b3_hunt_feedback("Boss vẫn chạy; lưu cần thử lại: %s" % str(saved_boss.get("reason",saved_boss.get("error","unknown"))))
            return
        b3_hunt_panel.get_parent().visible = false
        active_hunt_mode = "care"
        multicamp_encounter_id = ""
        _refresh_all()
        if selected_id != &"" and state.disciples.has(selected_id):
            _show_disciple_summary()
        return
    if active_hunt_mode == "multicamp":
        var active_id := HuntingPveRunV2.active_multicamp_id(state)
        if not active_id.is_empty():
            var restored_camp := _active_multicamp_session(active_id)
            if not bool(restored_camp.get("ok",false)):
                _set_b3_hunt_feedback("Không mở được bãi đã lưu: %s" % str(restored_camp.get("reason","unknown")))
                return
            var session: HuntingPveRunV2 = restored_camp["session"]
            var retreated := session.retreat_multicamp()
            if not bool(retreated.get("ok",false)):
                _set_b3_hunt_feedback("Chưa thể rút tổ đội: %s" % str(retreated.get("reason","unknown")))
                return
            var saved := await _save_runtime_async_barrier()
            if not bool(saved.get("ok",false)):
                _set_b3_hunt_feedback("Đã rút; lưu cần thử lại: %s" % str(saved.get("reason",saved.get("error","unknown"))))
                return
        b3_hunt_panel.get_parent().visible = false
        active_hunt_mode = "care"
        multicamp_encounter_id = ""
        _refresh_all()
        if selected_id != &"" and state.disciples.has(selected_id):
            _show_disciple_summary()
        return
    var world: Dictionary = state.sect.b3_hunt
    var result := {"ok":true}
    if not world.is_empty() and not str(world.get("member","")).is_empty():
        result = B3HuntWorld.return_to_sect(runtime_session.owner)
    if not result.get("ok",false):
        _set_b3_hunt_feedback("Chưa thể về tông môn: %s" % str(result.get("reason","đang chờ save/clock")))
        return
    b3_hunt_panel.get_parent().visible = false
    _refresh_all()
    if selected_id != &"" and state.disciples.has(selected_id):
        _show_disciple_summary()

func _active_b3_hunt_disciple_id() -> StringName:
    if state == null or state.sect.b3_hunt.is_empty():
        return &""
    var world: Dictionary = state.sect.b3_hunt
    var id := StringName(world.get("member",""))
    if id == &"":
        id = StringName(world.get("care",{}).get("disciple_id",b3_hunt_disciple_id))
    if id == &"":
        id = StringName(world.get("last_return",{}).get("disciple_id",b3_hunt_disciple_id))
    return id if state.disciples.has(id) else &""

func _active_multicamp_session(encounter_id: String) -> Dictionary:
    if state == null or encounter_id.is_empty():
        return {"ok":false,"reason":"missing_active_multicamp"}
    if runtime_session != null and runtime_session.owner != null:
        var cached := runtime_session.owner.get_active_multicamp_session(encounter_id)
        if cached != null:
            return {"ok":true,"session":cached,"cached":true}
    var restored := HuntingPveRunV2.resume_active(state,encounter_id)
    if bool(restored.get("ok",false)) and runtime_session != null and runtime_session.owner != null:
        runtime_session.owner.cache_active_multicamp_session(restored["session"])
    return restored

func _refresh_multicamp_hunt_panel() -> void:
    _set_hunt_presentation_layout(true)
    var encounter := HuntingPveRunV2.active_multicamp_id(state)
    var battle: MapBattleV2
    var running_session: HuntingPveRunV2
    var receipt: Dictionary = {}
    var running := not encounter.is_empty()
    if running:
        multicamp_encounter_id = encounter
        var restore_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
        var restored := _active_multicamp_session(encounter)
        if performance_logging_enabled:
            _record_hunt_refresh_stage("snapshot_restore",Time.get_ticks_usec()-restore_started_usec)
        if not bool(restored.get("ok",false)):
            b3_hunt_facts.text = "Không thể khôi phục world PvE đã lưu: %s" % str(restored.get("reason","save không hợp lệ"))
            b3_hunt_arena.show_open_world_snapshot(null,{})
            v63_combat_hud.visible = false
            b3_hunt_auto_button.disabled = true
            b3_hunt_deploy_button.visible = false
            return
        running_session = restored["session"]
        battle = running_session.battle
    elif not multicamp_encounter_id.is_empty():
        var raw_receipt = state.sect.v2_pve_settlement_receipts.get(multicamp_encounter_id,{})
        if raw_receipt is Dictionary:
            receipt = raw_receipt
            var saved_battle = receipt.get("battle",{})
            if saved_battle is Dictionary:
                var decoded := MapBattleSnapshotV2.load(saved_battle)
                if bool(decoded.get("ok",false)):
                    battle = decoded["battle"]
    if battle == null:
        b3_hunt_facts.text = "Chọn đệ tử V2 khỏe, rảnh rồi vào một world JX liên tục. C01 là vùng xuất phát, không phải màn trận riêng."
        b3_hunt_arena.show_open_world_snapshot(null,{})
        v63_combat_hud.visible = false
        b3_hunt_auto_button.disabled = true
        b3_hunt_deploy_button.visible = false
        b3_hunt_return_button.text = "Đóng khu săn"
        return

    var envelope: Dictionary = state.sect.v2_pve_active_runs.get(encounter,{})
    var population: Dictionary = running_session.camp_population if running_session != null         else envelope.get("camp_population",{})
    var rendered_camp := running_session.camp_index if running_session != null         else int(envelope.get("camp_index",0))
    var hud_update_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
    if battle.world_mode:
        var prepare_world_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
        var map_ready := b3_pve_world_view.prepare_world()
        if performance_logging_enabled:
            _record_hunt_refresh_stage("world_view_update",Time.get_ticks_usec()-prepare_world_started_usec)
        if bool(map_ready.get("ok",false)) and str(battle.world_navigation.get("source_blob_sha","")) == str(map_ready.get("topology",{}).get("source_blob_sha","")):
            var visual_rows_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
            var visual_rows := _b3_hunt_visual_rows(battle)
            if performance_logging_enabled:
                _record_hunt_refresh_stage("visual_rows",Time.get_ticks_usec()-visual_rows_started_usec)
            var view_update_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
            b3_hunt_arena.show_open_world_snapshot(battle,population,rendered_camp,state.disciples,visual_rows)
            if performance_logging_enabled:
                _record_hunt_refresh_stage("world_view_update",Time.get_ticks_usec()-view_update_started_usec)
        else:
            b3_pve_world_view.source_error = str(map_ready.get("reason","map hash differs from the saved world"))
            b3_hunt_arena.show_open_world_snapshot(null,{})
            b3_hunt_facts.text = "Không thể nạp đúng map đã lưu: %s" % b3_pve_world_view.source_error
    else:
        var visual_rows_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
        var visual_rows := _b3_hunt_visual_rows(battle)
        if performance_logging_enabled:
            _record_hunt_refresh_stage("visual_rows",Time.get_ticks_usec()-visual_rows_started_usec)
        var view_update_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
        b3_hunt_arena.show_authority_snapshot(battle,visual_rows,population,true)
        if performance_logging_enabled:
            _record_hunt_refresh_stage("world_view_update",Time.get_ticks_usec()-view_update_started_usec)
    if battle.world_mode:
        b3_hunt_auto_button.text = "AUTO: BẬT" if battle.auto_hunt else "AUTO: TẮT"
    else:
        b3_hunt_auto_button.text = "Combat V2"
    b3_hunt_auto_button.disabled = not running or not battle.world_mode or runtime_session == null or runtime_session.owner.runtime_write_blocked
    b3_hunt_deploy_button.visible = false
    b3_hunt_return_button.text = "Về tông môn" if running else "Đóng kết quả"
    b3_hunt_save_button.disabled = runtime_session == null or runtime_session.owner.runtime_write_blocked
    var p0_running := running and PveDistributedWorldV1.enabled(population)
    p0_add_hunter_button.visible = p0_running
    p0_withdraw_hunter_button.visible = p0_running
    p0_close_map_button.visible = p0_running
    p0_withdraw_hunter_button.disabled = not p0_running         or b3_pve_world_view.selected_actor_ids.size() != 1
    b3_hunt_auto_button.visible = not p0_running

    var team_lines: Array[String] = []
    var first_disciple_id := ""
    for raw_id in battle.actors.keys():
        var actor: Dictionary = battle.actors[raw_id]
        if str(actor.get("side","")) != "disciple":
            continue
        var id := str(raw_id)
        if first_disciple_id.is_empty():
            first_disciple_id = id
        if state.disciples.has(StringName(id)):
            var disciple: DiscipleState = state.disciples[StringName(id)]
            var life := "Injury %d" % disciple.injury_level if disciple.injury_level > 0 else "khỏe"
            team_lines.append("%s · HP %.0f/%.0f · %s" % [
                disciple.display_name,float(actor.get("hp",0.0)),float(actor.get("max_hp",1.0)),life
            ])
    team_lines.sort()
    if not first_disciple_id.is_empty() and state.disciples.has(StringName(first_disciple_id)):
        b3_hunt_disciple_id = StringName(first_disciple_id)
    var total_monsters := battle._count_monster_records()
    var dead_monsters := 0
    for actor in battle.actors.values():
        if str(actor.get("side","")) == "monster" and float(actor.get("hp",1.0)) <= 0.0:
            dead_monsters += 1
    var outcome := str(receipt.get("outcome",battle.outcome))
    var camp_id := PveMultiCampPopulationV1.camp_id(int(envelope.get("camp_index",receipt.get("camp_index",0))))
    var status := "Đội tự tìm đường, đánh tại chỗ bằng Combat V2" if running else ("Tổ đội đã bị hạ" if outcome == "defeat" else "Tổ đội đã về tông môn")
    var kill_count := int(population.get("world_total_kills",receipt.get("kills",0)))
    var alive_monsters := battle._count_alive("monster")
    _set_hunt_status(battle,camp_id,total_monsters,alive_monsters,population)
    b3_hunt_facts.visible = false
    v63_combat_hud.visible = true
    v63_combat_hud.set_authority(state,battle,not _current_v63_preview_overrides().is_empty())
    var member_text := "\n".join(team_lines)
    b3_hunt_facts.text = (
        "%s · %s\n%s\n"
        + "Thế giới 192×192 · 20 khu sinh quái · C01 chỉ là vùng xuất phát\n"
        + "Đội %d đệ tử thật · %d quái tại vùng · %d đang sống · hạ %d tổng · %.1fs\n"
        + "HP / Injury\n%s\n"
        + ("Hồi sinh theo clock chung · mỗi kill thưởng Tu Vi, Luyện Thể và vật phẩm vào Kho." if PveDistributedWorldV1.enabled(population) else "Phần thưởng legacy theo receipt.")
    ) % [str(population.get("world_source_map","Source A forest world")),camp_id,status,
        team_lines.size(),total_monsters,alive_monsters,kill_count,battle.now,member_text]
    if performance_logging_enabled:
        _record_hunt_refresh_stage("hud_update",Time.get_ticks_usec()-hud_update_started_usec)

func _set_hunt_presentation_layout(use_live_map: bool) -> void:
    if b3_hunt_facts == null:
        return
    var viewport_size := get_viewport_rect().size
    if b3_hunt_layout_initialized and b3_hunt_layout_live_mode == use_live_map \
            and b3_hunt_layout_viewport_size.is_equal_approx(viewport_size):
        return
    b3_hunt_layout_initialized = true
    b3_hunt_layout_live_mode = use_live_map
    b3_hunt_layout_viewport_size = viewport_size
    b3_hunt_layout_apply_count += 1
    var shade := b3_hunt_panel.get_parent() as ColorRect
    if use_live_map:
        if shade != null:
            shade.color = Color(0.03,0.06,0.07,0.12)
        b3_hunt_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        b3_hunt_panel.offset_left = 0.0
        b3_hunt_panel.offset_top = 0.0
        b3_hunt_panel.offset_right = 0.0
        b3_hunt_panel.offset_bottom = 0.0
        b3_hunt_panel.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
        b3_hunt_arena.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        b3_hunt_arena.offset_left = 0.0
        b3_hunt_arena.offset_top = 0.0
        b3_hunt_arena.offset_right = 0.0
        b3_hunt_arena.offset_bottom = 0.0
        b3_hunt_arena.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
        b3_hunt_facts_panel.position = Vector2(16,56)
        b3_hunt_facts_panel.size = Vector2(292,104)
        b3_hunt_facts_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
        b3_hunt_facts_panel.add_theme_stylebox_override("panel",_style(Color(0.025,0.055,0.045,0.90),Color("d7c695"),1,8))
        b3_hunt_facts.position = Vector2(16,14)
        b3_hunt_facts.size = Vector2(258,78)
        b3_hunt_facts.visible = false
        if v63_combat_hud != null:
            v63_combat_hud.position = Vector2(968,58)
            v63_combat_hud.size = Vector2(296,516)
            v63_combat_hud.visible = active_hunt_mode == "multicamp"
        b3_hunt_world_status.visible = true
        b3_hunt_title.text = "THANH TRÚC LÂM · THẾ GIỚI LIỀN MẠCH"
        b3_hunt_title.position = Vector2(18,14)
        b3_hunt_title.size = Vector2(600,32)
        b3_hunt_title.add_theme_color_override("font_color",Color("f3efdd"))
        b3_hunt_subtitle.visible = false
        b3_hunt_feedback.position = Vector2(640,16)
        b3_hunt_feedback.size = Vector2(430,30)
        b3_hunt_feedback.mouse_filter = Control.MOUSE_FILTER_IGNORE
        b3_hunt_save_button.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
        b3_hunt_save_button.offset_left = 18.0
        b3_hunt_save_button.offset_top = -60.0
        b3_hunt_save_button.offset_right = 150.0
        b3_hunt_save_button.offset_bottom = -14.0
        b3_hunt_auto_button.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
        b3_hunt_auto_button.offset_left = 162.0
        b3_hunt_auto_button.offset_top = -60.0
        b3_hunt_auto_button.offset_right = 294.0
        b3_hunt_auto_button.offset_bottom = -14.0
        b3_hunt_deploy_button.visible = false
        for entry in [[p0_add_hunter_button,308.0,448.0],
                [p0_withdraw_hunter_button,460.0,608.0],
                [p0_close_map_button,620.0,768.0]]:
            var control: Button = entry[0]
            control.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
            control.offset_left = float(entry[1])
            control.offset_top = -60.0
            control.offset_right = float(entry[2])
            control.offset_bottom = -14.0
        b3_hunt_return_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
        b3_hunt_return_button.offset_left = -164.0
        b3_hunt_return_button.offset_top = -60.0
        b3_hunt_return_button.offset_right = -18.0
        b3_hunt_return_button.offset_bottom = -14.0
    else:
        if shade != null:
            shade.color = Color(0.03,0.06,0.07,0.78)
        b3_hunt_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
        b3_hunt_panel.position = Vector2(64,38)
        b3_hunt_panel.size = Vector2(1152,644)
        b3_hunt_panel.add_theme_stylebox_override("panel",_style(PAPER_LIGHT,INK,3,14))
        b3_hunt_arena.set_anchors_preset(Control.PRESET_TOP_LEFT)
        b3_hunt_arena.position = Vector2(24,82)
        b3_hunt_arena.size = Vector2(700,484)
        b3_hunt_arena.add_theme_stylebox_override("panel",_style(JADE_DARK,INK,1,8))
        b3_hunt_facts_panel.position = Vector2(746,82)
        b3_hunt_facts_panel.size = Vector2(382,484)
        b3_hunt_facts_panel.mouse_filter = Control.MOUSE_FILTER_STOP
        b3_hunt_facts_panel.add_theme_stylebox_override("panel",_style(Color("eee6d2"),Color("74694f"),1,8))
        b3_hunt_facts.position = Vector2(16,14)
        b3_hunt_facts.size = Vector2(350,452)
        b3_hunt_facts.add_theme_font_size_override("font_size",15)
        b3_hunt_facts.visible = active_hunt_mode == "care"
        if v63_combat_hud != null:
            v63_combat_hud.position = Vector2(752,88)
            v63_combat_hud.size = Vector2(370,472)
            v63_combat_hud.visible = false
        b3_hunt_world_status.visible = false
        for control in [p0_add_hunter_button,p0_withdraw_hunter_button,p0_close_map_button]:
            control.visible = false
        b3_hunt_auto_button.visible = true
        b3_hunt_title.text = "THẾ GIỚI SĂN QUÁI — LIỀN MẠCH"
        b3_hunt_title.position = Vector2(24,14)
        b3_hunt_title.size = Vector2(1100,32)
        b3_hunt_title.add_theme_color_override("font_color",JADE_DARK)
        b3_hunt_subtitle.visible = true
        b3_hunt_feedback.position = Vector2(28,578)
        b3_hunt_feedback.size = Vector2(510,42)
        b3_hunt_save_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
        b3_hunt_save_button.position = Vector2(550,580)
        b3_hunt_save_button.size = Vector2(132,46)
        b3_hunt_auto_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
        b3_hunt_auto_button.position = Vector2(746,580)
        b3_hunt_auto_button.size = Vector2(120,46)
        b3_hunt_deploy_button.visible = true
        b3_hunt_deploy_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
        b3_hunt_deploy_button.position = Vector2(876,580)
        b3_hunt_deploy_button.size = Vector2(120,46)
        b3_hunt_return_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
        b3_hunt_return_button.position = Vector2(1006,580)
        b3_hunt_return_button.size = Vector2(122,46)

func _set_hunt_status(battle: MapBattleV2, camp_id: String, total_monsters: int,
        alive_monsters: int, population: Dictionary = {}) -> void:
    if b3_hunt_world_status == null or battle == null:
        return
    var members := 0
    var total_hp := 0.0
    var maximum_hp := 0.0
    for actor in battle.actors.values():
        if str(actor.get("side","")) != "disciple":
            continue
        members += 1
        total_hp += maxf(0.0,float(actor.get("hp",0.0)))
        maximum_hp += maxf(1.0,float(actor.get("max_hp",1.0)))
    if PveDistributedWorldV1.enabled(population):
        var rewarded_kills := int(population.get("world_total_kills",0))
        b3_hunt_world_status.text = (
            "Thợ săn %d/30 · sống %d · HP %.0f/%.0f\n"
            + "%s · quái %d/%d · đã hạ %d\n"
            + "Thưởng: Tu Vi / Luyện Thể · đồ vào Kho"
        ) % [members,battle._count_alive("disciple"),total_hp,maximum_hp,
            camp_id,alive_monsters,total_monsters,rewarded_kills]
    else:
        b3_hunt_world_status.text = (
            "Đội săn %d/6 · sống %d · HP %.0f/%.0f\n"
            + "%s · quái %d/%d · %.1fs\n"
            + "Chiến lợi phẩm theo receipt"
        ) % [members,battle._count_alive("disciple"),total_hp,maximum_hp,
            camp_id,alive_monsters,total_monsters,battle.now]

func _refresh_b3_hunt_panel() -> void:
    if b3_hunt_panel == null or not b3_hunt_panel.get_parent().visible or state == null:
        return
    if active_hunt_mode == "v63_boss":
        _refresh_v63_boss_panel()
        return
    if active_hunt_mode == "multicamp":
        _refresh_multicamp_hunt_panel()
        return
    _set_hunt_presentation_layout(false)
    var world: Dictionary = state.sect.b3_hunt
    var id := _active_b3_hunt_disciple_id()
    if id == &"":
        b3_hunt_facts.text = "Chưa có đệ tử săn được lưu trong vòng này.\nChọn đệ tử V2 thật trên bản đồ để phái đi săn."
        b3_hunt_arena.show_authority_snapshot(null,{})
        b3_hunt_auto_button.disabled = true
        b3_hunt_deploy_button.disabled = true
        return
    var d: DiscipleState = state.disciples[id]
    var care: Dictionary = world.get("care",{})
    var restored := B3HuntWorld.restore(state) if not world.is_empty() else {"ok":false}
    var battle: MapBattleV2 = restored.get("battle") if restored.get("ok",false) else null
    b3_hunt_arena.show_authority_snapshot(battle,_b3_hunt_visual_rows(battle))
    var member := str(world.get("member",""))
    var status_names := {
        "HUNTING":"Đang săn","INJURY_WAIT":"Chờ Injury hồi phục",
        "PILL_RECOVERY":"Đã dùng thuốc hồi HP","REST_RECOVERY":"Đang nghỉ dưỡng",
        "OFF":"Đã tắt AUTO","READY":"Sẵn sàng","MANUAL_PAUSE":"Tạm dừng thủ công",
        "BUSY":"Đang bận","":"Chưa bật AUTO"
    }
    var auto_text := "AUTO: BẬT" if care.get("auto_hunt",false) else "AUTO: TẮT"
    b3_hunt_auto_button.text = auto_text
    b3_hunt_auto_button.disabled = world.is_empty() or not B3MedicalAutoplayV1.command_ready(runtime_session.owner)
    b3_hunt_deploy_button.visible = member.is_empty()
    var admission := B3HuntWorld.admission(state,id) if member.is_empty() else {"ok":false,"reason":"disciple_already_deployed"}
    b3_hunt_deploy_button.disabled = not bool(admission.get("ok",false)) or not B3MedicalAutoplayV1.command_ready(runtime_session.owner)
    b3_hunt_return_button.text = "Về tông môn" if not member.is_empty() else "Đóng vòng săn"
    var injury := "Khỏe mạnh"
    var injury_remaining := maxi(d.injury_recover_at_tick-state.tick,0) if d.injury_level != 0 else 0
    if d.injury_level != 0:
        injury = "Injury %d · còn %d tick" % [d.injury_level,injury_remaining]
    var progression := DiscipleRealmProgressV2.current(d) if DiscipleRealmProgressV2.progression_ready(d) else {"ok":false}
    var tuvi_text := "Chưa có dữ liệu Tu Vi"
    if progression.get("ok",false):
        var tuvi: Dictionary = progression["cultivation"]
        var required := DiscipleProgressionBalanceV2.floor_cost(int(tuvi["realm"]),int(tuvi["floor"]))
        tuvi_text = "%s tầng %d · %.0f / %.0f Tu Vi" % [
            DiscipleRealmProgressV2.realm_name("cultivation",int(tuvi["realm"])),
            int(tuvi["floor"]),float(tuvi["xp"]),float(required)
        ]
    var slot: Dictionary = world.get("slot",{})
    var kills := int(slot.get("paid_generation",0))
    var resource := B3PilotContent.RESOURCE
    var warehouse := WarehouseSystem.new()
    var stock := warehouse.quantity(state,resource)
    var available := warehouse.available_quantity(state,resource)
    var healing_pills := warehouse.quantity(state,&"hoi_xuan_dan")
    var satiety_spent := B3PillSatietyV1.spent_today(state,d)
    var battle_time := float(battle.now) if battle != null else 0.0
    var battle_status := "Chiến trường đang sẵn sàng" if battle != null else "Chiến trường chưa khởi tạo"
    var s1_status := "Không có"
    var s1_latest_event := ""
    var disciple_actor_id := str(d.id)
    if battle != null and battle.actors.has(disciple_actor_id):
        var presenter: B3CareCombatV5Presenter = b3_hunt_arena.presenter
        var disciple_actor: Dictionary = battle.actors[disciple_actor_id]
        var active_s1 := presenter.s1_combat_status_summary(disciple_actor)
        if not active_s1.is_empty():
            s1_status = active_s1
        s1_latest_event = presenter.latest_s1_status_feedback()
    if s1_latest_event.is_empty():
        s1_latest_event = "Chưa có sự kiện hiệu ứng mới"
    b3_hunt_facts.text = (
        "%s · %s\n%s\n"
        + "ĐỆ TỬ · %s\nHP: %.0f / %.0f · Injury: %s\nTu Vi: %s\n"
        + "Combat V3-S1 · %s\n%s\n"
        + "SĂN QUÁI · Hạ gục đã trả thưởng: %d · Quái %d · %.1f giây\n"
        + "KHO TÔNG MÔN · %s · Tổng: %d · Dùng được: %d\n"
        + "HỒI XUÂN ĐAN %d · Bão hòa %d / %d điểm\nCARE: %s"
    ) % [
        auto_text,str(status_names.get(str(care.get("status","")),"Chưa bật AUTO")),battle_status,
        d.display_name,d.hp,d.max_hp,injury,tuvi_text,s1_status,s1_latest_event,
        kills,int(slot.get("generation",0)),battle_time,
        ResourceRegistry.new().display_name(resource),stock,available,
        healing_pills,satiety_spent,B3PillSatietyV1.CAPACITY,
        str(care.get("status","OFF"))
    ]

func _b3_hunt_visual_rows(battle: MapBattleV2) -> Dictionary:
    var rows := {}
    if battle == null:
        return rows
    for raw_id in battle.actors.keys():
        var actor: Dictionary = battle.actors[raw_id]
        var actor_id := str(raw_id)
        var visual_key := ""
        if str(actor.get("side","")) == "disciple":
            var disciple_id := StringName(actor.get("id",actor_id))
            if not state.disciples.has(disciple_id):
                continue
            var disciple: DiscipleState = state.disciples[disciple_id]
            var sex := str(DiscipleActorVisualCatalog.visual_sex_for_disciple(disciple))
            visual_key = "disciple_female" if sex == "female" else "disciple_male"
            rows[actor_id] = {
                "display_name":disciple.display_name,
                "source_a_visual_key":visual_key
            }
        elif str(actor.get("species_id","")) == "thanh_lang":
            # Existing low-confidence monster-category Source A pilot. Keep the
            # presentation mapping, but do not treat its visual as a verified
            # Thanh Lang species match until the asset owner approves it.
            rows[actor_id] = {
                "display_name":_v63_hunt_resource_registry.display_name(StringName(actor.get("species_id",""))),
                "source_a_visual_key":"monster_1113031_1"
            }
    return rows

func _set_b3_hunt_feedback(value: String) -> void:
    if b3_hunt_feedback != null:
        b3_hunt_feedback.text = value


func _disciple_summary_text(disciple: DiscipleState) -> String:
    var snapshot := _disciple_snapshot(disciple)
    if not bool(snapshot.get("ok", false)):
        return "Không thể đọc hồ sơ đệ tử."
    if bool(snapshot.get("authentic_v2", false)):
        return _v2_disciple_summary_text(snapshot)

    var required := cultivation.required_progress(disciple)
    var cultivation_text := "Đã viên mãn" if required <= 0.0 else "%.0f / %.0f" % [disciple.cultivation_progress, required]
    var destination := StringName(actor_destinations.get(str(disciple.id), str(SectMapPresentation.DEST_COURTYARD)))
    var power := cultivation.effective_combat_power(state, disciple)

    var technique_text := "Chưa chọn"
    if disciple.active_technique_id != &"":
        technique_text = technique_system.technique_name(disciple.active_technique_id)

    var bloodline_text := "—"
    var bloodline_profile := bloodlines.profile_for(state, disciple.id)
    if not bloodline_profile.is_empty():
        if bool(bloodline_profile.get("revealed", false)):
            var bloodline_id := StringName(bloodline_profile.get("bloodline_id", "none"))
            bloodline_text = bloodlines.bloodline_name(bloodline_id)
        else:
            bloodline_text = "Chưa xác định"

    var physique_text := "—"
    var physique_profile := physiques.profile_for(state, disciple.id)
    if not physique_profile.is_empty():
        physique_text = physiques.display_physique(state, disciple.id)

    var command_text := _direct_command_label(disciple)
    var feedback := ""
    if summary_feedback != "":
        feedback = "\n%s" % summary_feedback

    return (
        "HP %.0f/%.0f  ·  Thể lực %.0f/100\n"
        + "Tu vi: %s\n"
        + "Đang làm: %s\n"
        + "Vị trí: %s\n"
        + "Nhóm việc: %s\n\n"
        + "Chiến lực: %.1f\n"
        + "Công pháp: %s\n"
        + "Huyết Mạch: %s\n"
        + "Thể Chất: %s\n\n"
        + "Lệnh Tông Chủ: %s%s"
    ) % [
        disciple.hp, disciple.max_hp, disciple.stamina,
        cultivation_text,
        SectMapPresentation.action_label(disciple.current_action),
        _building_name(destination),
        _work_group_label(disciple),
        power,
        technique_text,
        bloodline_text,
        physique_text,
        command_text,
        feedback
    ]


func _disciple_snapshot(disciple: DiscipleState) -> Dictionary:
    return DisciplePresentationSnapshotV2.build(state, disciple)

func _v2_disciple_summary_text(snapshot: Dictionary) -> String:
    var life: Dictionary = snapshot["life"]
    var progression: Dictionary = snapshot["progression"]
    var injury_text := "Thương Thế: Khỏe mạnh" if int(life.get("injury_level",0)) == 0 else ("Thương Thế: Đang hồi phục · %d phút mô phỏng" % int(life.get("injury_remaining_ticks",0)))
    if not bool(progression.get("ready", false)):
        return (
            "HP %.0f/%.0f · Thể lực viễn chinh %.0f/100\n"
            + "Tu Vi/Luyện Thể: dữ liệu chưa sẵn sàng\n"
            + "Đang làm: %s\n"
            + "%s"
        ) % [
            float(life["hp"]), float(life["max_hp"]),
            float(life["expedition_stamina"]),
            SectMapPresentation.action_label(StringName(life["current_action"])),
            injury_text
        ]

    var tuvi: Dictionary = progression["cultivation"]
    var body: Dictionary = progression["body"]
    var combat: Dictionary = snapshot["combat"]
    var atk := 0.0
    var defense := 0.0
    if bool(combat.get("ready", false)):
        var stats: Dictionary = combat["stats"]
        atk = float(stats.get("attack", 0.0))
        defense = float(stats.get("defense", 0.0))
    var innate: Dictionary = snapshot["innate"]
    var work: Dictionary = snapshot["work"]
    var destination := StringName(actor_destinations.get(
        str(snapshot["disciple_id"]), str(SectMapPresentation.DEST_COURTYARD)
    ))
    var feedback := ""
    if summary_feedback != "":
        feedback = "\n%s" % summary_feedback

    return (
        "HP %.0f/%.0f · Thể lực viễn chinh %.0f/100\n"
        + "Tu Vi: %s tầng %d · %.0f/%.0f\n"
        + "Luyện Thể: %s tầng %d · %.0f/%.0f\n"
        + "Công %.1f · Thủ %.1f\n"
        + "Đang làm: %s · %s\n"
        + "Nhóm việc: %s\n\n"
        + "Linh Căn: %s\n"
        + "Đặc Chất: %s\n"
        + "Huyết Mạch: %s · Thể Chất: %s\n"
        + "Mệnh Cách: %s\n"
        + "Lệnh Tông Chủ: %s%s\n"
        + "%s"
    ) % [
        float(life["hp"]), float(life["max_hp"]), float(life["expedition_stamina"]),
        str(tuvi["name"]), int(tuvi["floor"]), float(tuvi["xp"]), float(tuvi["required_xp"]),
        str(body["name"]), int(body["floor"]), float(body["xp"]), float(body["required_xp"]),
        atk, defense,
        SectMapPresentation.action_label(StringName(life["current_action"])),
        _building_name(destination),
        _work_group_label_id(StringName(work.get("group_id", ""))),
        _v2_root_brief(innate),
        _v2_trait_brief(innate),
        _v2_identity_brief(innate["bloodline"], "Không"),
        _v2_identity_brief(innate["physique"], "Không"),
        _v2_identity_brief(innate["destiny"], "Không"),
        _direct_command_label_data(work.get("direct_command", {})),
        feedback,
        injury_text
    ]

func _v2_root_brief(innate: Dictionary) -> String:
    var root: Dictionary = innate["spiritual_root"]
    var values: Dictionary = root.get("current_values", {})
    var ids: Array = values.keys()
    ids.sort()
    var parts: Array[String] = []
    for raw_id in ids:
        var row: Dictionary = values[raw_id]
        parts.append("%s %d" % [str(row.get("name", raw_id)), int(row.get("purity", 0))])
    var mutation: Dictionary = root.get("mutation", {})
    if str(mutation.get("status", "")) == "revealed":
        parts.append("Dị Căn %s" % str(mutation.get("name", "?")))
    return " · ".join(parts) if not parts.is_empty() else "—"

func _v2_trait_brief(innate: Dictionary) -> String:
    var rows: Array = innate["traits"].get("visible", [])
    var names: Array[String] = []
    for raw_row in rows:
        if raw_row is Dictionary:
            names.append(str(raw_row.get("name", "?")))
    return " · ".join(names) if not names.is_empty() else "—"

func _v2_identity_brief(row: Dictionary, none_text: String = "Không") -> String:
    match str(row.get("status", "none")):
        "revealed":
            return str(row.get("name", "?"))
        "unrevealed":
            return "Chưa xác định"
        _:
            return none_text

func _work_group_label_id(group_id: StringName) -> String:
    match group_id:
        &"mining_crew": return "Đội Khai Khoáng"
        &"forestry_crew": return "Đội Lâm Nghiệp"
        &"herbalism_crew": return "Đội Linh Thực"
        &"alchemy_crew": return "Đội Luyện Đan"
        &"forge_hall": return "Luyện Khí Đường"
        &"": return "Chưa phân"
        _: return str(group_id)

func _direct_command_label_data(command: Variant) -> String:
    if not (command is Dictionary) or command.is_empty():
        return "Không"
    var kind := StringName(command.get("kind", ""))
    var target := StringName(command.get("target", ""))
    match kind:
        WorkforceSystem.COMMAND_CULTIVATE: return "Tu luyện"
        WorkforceSystem.COMMAND_REST: return "Nghỉ"
        WorkforceSystem.COMMAND_RETURN_SECT: return "Về tông"
        WorkforceSystem.COMMAND_HOLD: return "Giữ tại tông"
        WorkforceSystem.COMMAND_WORK:
            if target == WorkforceSystem.PROF_MINING:
                return "Khai khoáng"
            if target == WorkforceSystem.PROF_FORGING:
                return "Luyện khí"
            if target == WorkforceSystem.PROF_HERBALISM:
                return "Linh thực"
            return "Làm nghề"
        WorkforceSystem.COMMAND_HUNT_REGION: return "Xuất môn"
        _: return str(kind)

func _work_group_label(disciple: DiscipleState) -> String:
    match disciple.work_group_id:
        &"mining_crew": return "Đội Khai Khoáng"
        &"forestry_crew": return "Đội Lâm Nghiệp"
        &"forge_hall": return "Luyện Khí Đường"
        &"herbalism_crew": return "Đội Linh Thực"
        &"": return "Chưa phân"
        _: return str(disciple.work_group_id)

func _direct_command_label(disciple: DiscipleState) -> String:
    if disciple.direct_command.is_empty():
        return "Không"
    var kind := StringName(disciple.direct_command.get("kind", ""))
    var target := StringName(disciple.direct_command.get("target", ""))
    match kind:
        WorkforceSystem.COMMAND_CULTIVATE: return "Tu luyện"
        WorkforceSystem.COMMAND_REST: return "Nghỉ"
        WorkforceSystem.COMMAND_RETURN_SECT: return "Về tông"
        WorkforceSystem.COMMAND_HOLD: return "Giữ tại tông"
        WorkforceSystem.COMMAND_WORK:
            if target == WorkforceSystem.PROF_MINING:
                return "Khai khoáng"
            if target == WorkforceSystem.PROF_FORGING:
                return "Luyện khí"
            return "Làm nghề"
        WorkforceSystem.COMMAND_HUNT_REGION: return "Xuất môn"
        _: return str(kind)

func _issue_summary_order(kind: StringName, target: String, label: String) -> void:
    if selected_id == &"" or not state.disciples.has(selected_id):
        return
    var disciple: DiscipleState = state.disciples[selected_id]
    if kind == WorkforceSystem.COMMAND_CULTIVATE and DiscipleRealmProgressV2.owns_v2_progression(disciple):
        summary_feedback = _v2_training_ui_feedback(_queue_v2_training("cultivation"),"cultivation")
        _refresh_disciple_summary_content()
        return
    var ok := workforce.issue_command(state, selected_id, kind, target, 40)
    summary_feedback = "Đã ra lệnh: %s" % label if ok else "Không thể ra lệnh lúc này."
    _refresh_disciple_summary_content()

# Player actions use the same V2 command boundary as scheduler/AI. This
# queues work but never commits XP or economic cost on button press.
func _queue_v2_training(track: String, disciple_id: StringName = &"") -> Dictionary:
    var chosen_id := selected_id if disciple_id == &"" else disciple_id
    if chosen_id == &"" or not state.disciples.has(chosen_id):
        return {"ok":false,"reason":"unknown_training_disciple"}
    var disciple: DiscipleState = state.disciples[chosen_id]
    if not DiscipleRealmProgressV2.owns_v2_progression(disciple):
        return {"ok":false,"reason":"v2_disciple_not_initialized"}
    if track == "cultivation":
        # GP-02A presentation preflight: current_action may be EVALUATE
        # between real Mine/Forest carry-cycle steps. A rejected order must
        # not cancel carried goods or consume a timed job/field reservation.
        if not disciple.work_cycle_state.is_empty():
            return {"ok":false,"reason":"busy_cultivation_work_cycle"}
        var buildings := BuildingSystem.new()
        if buildings.disciple_has_active_spirit_plot(state, disciple.id):
            return {"ok":false,"reason":"busy_spirit_plot"}
        if buildings.disciple_has_active_timed_recipe(state, disciple.id):
            return {"ok":false,"reason":"busy_timed_recipe"}
    if track == "body":
        var slot := DiscipleBodyTrainingFacilityV2.reserve_slot(state,chosen_id)
        if not bool(slot.get("ok",false)):
            return slot
    var result := DiscipleTrainingActionV2.request_training(state,chosen_id,track)
    if bool(result.get("ok",false)):
        workforce.clear_command(state,disciple)
        DiscipleTrainingPolicyV2.set_policy(
            state,chosen_id,"body_focus" if track == "body" else "cultivation_focus"
        )
    return result

func _v2_training_ui_feedback(result: Dictionary, track: String) -> String:
    if bool(result.get("ok",false)):
        if track == "body":
            return "Đã xếp Rèn Thân Đường. Mỗi phút hợp lệ tiêu 1 Linh Thạch; chưa trừ phí/cộng EXP."
        return "Đã xếp Chuyên Tu. EXP chỉ cộng khi mô phỏng chạy đủ phút."
    var reason := str(result.get("reason","unknown_training_error"))
    match reason:
        "body_training_slots_full":
            return "Rèn Thân Đường đã kín 2 chỗ."
        "insufficient_training_spirit_stones":
            return "Không đủ Linh Thạch Tông Môn để Rèn Thân."
        "body_training_facility_unavailable":
            return "Rèn Thân Đường chưa sẵn sàng."
        "body_training_slot_not_reserved":
            return "Chưa được phân vào vị trí Rèn Thân."
        "training_cannot_interrupt_active_work", "busy_cultivation_work_cycle", "busy_spirit_plot", "busy_timed_recipe":
            return "Đệ tử đang bận; không thể ngắt công việc, vận chuyển hoặc tác vụ giữ chỗ."
        "major_gate_waiting":
            return "Đã tới cổng đại cảnh; cần đột phá trước."
        "training_disciple_not_present", "training_actor_not_available":
            return "Đệ tử không đủ điều kiện hoặc không ở Tông Môn."
        "v2_disciple_not_initialized", "training_profile_not_ready":
            return "Hồ sơ V2 chưa đủ điều kiện."
        _:
            return "Chưa thể thực hiện: %s" % reason

func _issue_v2_summary_body() -> void:
    summary_feedback = _v2_training_ui_feedback(_queue_v2_training("body"),"body")
    _refresh_disciple_summary_content()

func _open_selected_disciple_detail() -> void:
    if selected_id == &"" or not state.disciples.has(selected_id):
        return
    deep_restore_summary = true
    _open_disciple_deep_screen(selected_id, "Tổng Quan")

func _open_disciple_deep_screen(disciple_id: StringName, tab_name: String = "Tổng Quan", preserve_feedback: bool = false) -> void:
    if not state.disciples.has(disciple_id):
        return
    if opened_disciple_profile and popup_layer != null:
        var prior_scroll := popup_layer.find_child("DiscipleTabContentScroll",true,false) as ScrollContainer
        if prior_scroll != null:
            var prior_key := "%s|%s" % [str(selected_id),disciple_profile_active_tab_name]
            disciple_profile_tab_scroll_positions[prior_key] = prior_scroll.scroll_vertical
    disciple_profile_active_tab_name = tab_name
    # A profile is a top-level screen. Close facility panels before adding its
    # dim layer so Warehouse/building controls cannot remain underneath it.
    _dismiss_facility_screens()
    _close_building_operation_panel(true)
    selected_id = disciple_id
    opened_disciple_profile = true
    if not preserve_feedback and tab_name != "Huyết Mạch" and tab_name != "Thể Chất":
        tab_status_text = ""
    _refresh_tasks()
    _hide_disciple_summary()
    _clear_popup()
    _add_dim()

    var panel := Panel.new()
    panel.name = "DiscipleDeepScreen"
    panel.position = Vector2(48, 82)
    panel.size = Vector2(1184, 548)
    panel.add_theme_stylebox_override("panel", _style(PAPER_LIGHT, INK, 3, 18))
    popup_layer.add_child(panel)

    var title := _label(panel, "Hồ sơ đệ tử", Vector2(20, 12), Vector2(220, 34), 23)
    title.add_theme_color_override("font_color", CINNABAR.darkened(0.18))
    var quick_assign := Button.new()
    quick_assign.name = "DeepQuickAssignment"
    quick_assign.text = "Điều phối đệ tử"
    quick_assign.position = Vector2(751,12)
    quick_assign.size = Vector2(174,44)
    quick_assign.add_theme_font_size_override("font_size",14)
    quick_assign.add_theme_color_override("font_color",PAPER_LIGHT)
    quick_assign.add_theme_stylebox_override("normal",_style(JADE_DARK,INK,1,8))
    quick_assign.pressed.connect(Callable(self,"_open_disciple_quick_assignment").bind(disciple_id))
    panel.add_child(quick_assign)

    var back := Button.new()
    back.name = "BackToMapContext"
    back.text = "← Trở lại bản đồ"
    back.position = Vector2(936, 12)
    back.size = Vector2(184, 44)
    back.add_theme_font_size_override("font_size",14)
    back.add_theme_color_override("font_color",INK)
    back.add_theme_stylebox_override("normal", _style(Color(0.88, 0.82, 0.67, 1.0), INK, 1, 8))
    back.pressed.connect(_return_to_disciple_summary)
    panel.add_child(back)

    var close := Button.new()
    close.text = "×"
    close.position = Vector2(1118, 10)
    close.size = Vector2(46, 46)
    close.add_theme_font_size_override("font_size", 22)
    close.add_theme_stylebox_override("normal", _style(Color(0.76, 0.70, 0.58, 1.0), INK, 1, 16))
    close.pressed.connect(_return_to_disciple_summary)
    panel.add_child(close)

    var roster_width := 52.0 if disciple_profile_roster_collapsed else 216.0
    var showcase_x := 18.0 + roster_width + 18.0
    var content_x := showcase_x + 318.0
    var content_width := 1184.0 - content_x - 20.0

    var roster_panel := Panel.new()
    roster_panel.name = "DeepDiscipleRosterPanel"
    roster_panel.position = Vector2(18, 58)
    roster_panel.size = Vector2(roster_width, 464)
    roster_panel.add_theme_stylebox_override("panel", _style(JADE_DARK, GOLD, 2, 10))
    panel.add_child(roster_panel)

    var roster_toggle := Button.new()
    roster_toggle.name = "DeepRosterToggle"
    roster_toggle.text = "›" if disciple_profile_roster_collapsed else "Thu gọn"
    roster_toggle.tooltip_text = "Mở rộng danh sách đệ tử" if disciple_profile_roster_collapsed else "Thu gọn danh sách đệ tử"
    roster_toggle.position = Vector2(6, 6) if disciple_profile_roster_collapsed else Vector2(8, 6)
    roster_toggle.size = Vector2(40, 40) if disciple_profile_roster_collapsed else Vector2(roster_width - 16.0, 34)
    roster_toggle.add_theme_font_size_override("font_size", 12)
    roster_toggle.add_theme_color_override("font_color", INK)
    roster_toggle.add_theme_stylebox_override("normal", _style(Color(0.93, 0.87, 0.73), Color(0.43, 0.35, 0.25), 1, 7))
    roster_toggle.pressed.connect(Callable(self, "_toggle_deep_disciple_roster").bind(tab_name))
    roster_panel.add_child(roster_toggle)

    if not disciple_profile_roster_collapsed:
        var roster_search := LineEdit.new()
        roster_search.name = "DeepRosterSearch"
        roster_search.position = Vector2(8, 46)
        roster_search.size = Vector2(roster_width - 16.0, 32)
        roster_search.placeholder_text = "Tìm đệ tử"
        roster_search.add_theme_color_override("font_color", PAPER_LIGHT)
        roster_search.add_theme_color_override("font_placeholder_color", Color(0.84, 0.78, 0.61, 0.86))
        roster_search.text = disciple_profile_search_query
        roster_search.add_theme_font_size_override("font_size", 13)
        roster_search.text_changed.connect(Callable(self, "_apply_deep_disciple_roster_filter"))
        roster_panel.add_child(roster_search)

        var sort_options := OptionButton.new()
        sort_options.name = "DeepRosterSort"
        sort_options.position = Vector2(8,82)
        sort_options.size = Vector2(roster_width - 16.0,28)
        sort_options.add_item("Tên A-Z",0)
        sort_options.add_item("Phẩm chất",1)
        sort_options.add_item("Nghề nghiệp",2)
        sort_options.add_item("Công việc",3)
        sort_options.add_item("Cảnh giới",4)
        sort_options.select(clampi(disciple_profile_sort_mode,0,4))
        sort_options.add_theme_font_size_override("font_size",12)
        sort_options.add_theme_color_override("font_color",PAPER_LIGHT)
        sort_options.item_selected.connect(Callable(self,"_on_deep_disciple_roster_sort_changed").bind(disciple_id,tab_name))
        roster_panel.add_child(sort_options)

        var roster_scroll := ScrollContainer.new()
        roster_scroll.name = "DeepDiscipleRosterScroll"
        roster_scroll.position = Vector2(8, 114)
        roster_scroll.size = Vector2(roster_width - 16.0, 338)
        roster_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
        roster_panel.add_child(roster_scroll)

        var roster := VBoxContainer.new()
        roster.name = "DeepDiscipleRoster"
        roster.custom_minimum_size = Vector2(roster_width - 34.0, 0)
        roster.add_theme_constant_override("separation", 6)
        roster_scroll.add_child(roster)

        var ids: Array = state.disciples.keys()
        var roster_sort_keys: Dictionary = {}
        var roster_snapshots: Dictionary = {}
        for raw_id in ids:
            var roster_disciple: DiscipleState = state.disciples[StringName(raw_id)]
            var roster_snapshot := _disciple_snapshot(roster_disciple)
            roster_snapshots[str(raw_id)] = roster_snapshot
            roster_sort_keys[str(raw_id)] = _deep_disciple_roster_sort_key(roster_disciple,roster_snapshot,disciple_profile_sort_mode)
        ids.sort_custom(func(a: Variant,b: Variant) -> bool:
            return str(roster_sort_keys.get(str(a),"")) < str(roster_sort_keys.get(str(b),""))
        )
        var legacy_cultivation_system := CultivationSystem.new()
        for raw_id in ids:
            var id := StringName(raw_id)
            var roster_disciple: DiscipleState = state.disciples[id]
            var roster_snapshot: Dictionary = roster_snapshots.get(str(id),{})
            var roster_identity: Dictionary = roster_snapshot.get("identity",{})
            var roster_progression: Dictionary = roster_snapshot.get("progression",{})
            var roster_cultivation: Dictionary = roster_progression.get("cultivation",{})
            var roster_realm := str(roster_cultivation.get("name",legacy_cultivation_system.stage_name(roster_disciple)))
            var roster_quality := str(roster_identity.get("quality_name","Phẩm chất chưa xác định"))
            var roster_action_status := SectMapPresentation.action_label(roster_disciple.current_action)
            var roster_work: Dictionary = roster_snapshot.get("work",{})
            var roster_worksite := str(roster_work.get("worksite_building_id",""))
            var roster_group := str(roster_work.get("group_id",""))
            var roster_status := roster_action_status
            if not roster_worksite.is_empty():
                roster_status = "Tại " + _building_name(StringName(roster_worksite))
            elif roster_group.is_empty():
                roster_status = "Rảnh · " + roster_action_status
            else:
                roster_status = _work_group_label_id(StringName(roster_group))
            var roster_status_tooltip := "%s · %s · %s" % [roster_action_status, _work_group_label_id(StringName(roster_group)), _building_name(StringName(roster_worksite)) if not roster_worksite.is_empty() else "Chưa gắn công trình"]
            var entry := Button.new()
            entry.name = "DeepRosterEntry_%d" % roster.get_child_count()
            entry.text = "%s\n%s · %s\n%s" % [roster_disciple.display_name,roster_quality,roster_realm,roster_status]
            entry.tooltip_text = "%s · %s · %s · %s" % [roster_disciple.display_name,roster_quality,roster_realm,roster_status]
            entry.custom_minimum_size = Vector2(roster_width - 36.0, 82)
            entry.add_theme_font_size_override("font_size", 10)
            entry.add_theme_color_override("font_color", PAPER_LIGHT)
            entry.add_theme_color_override("font_hover_color", Color(1.0, 0.94, 0.76, 1.0))
            entry.alignment = HORIZONTAL_ALIGNMENT_LEFT
            var roster_portrait := _disciple_source_a_portrait_texture(roster_disciple)
            if roster_portrait != null:
                # The entry remains a Button for keyboard/mouse semantics and existing contracts.
                # Preserve the canonical name on the Button for search/accessibility,
                # while omitting hidden multiline metadata that inflated its minimum width.
                entry.text = roster_disciple.display_name
                entry.add_theme_color_override("font_color", Color(0, 0, 0, 0))
                entry.add_theme_color_override("font_hover_color", Color(0, 0, 0, 0))
                var portrait_row := HBoxContainer.new()
                portrait_row.name = "VerifiedSourceARosterCard"
                portrait_row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
                portrait_row.offset_left = 8
                portrait_row.offset_top = 5
                portrait_row.offset_right = -8
                portrait_row.offset_bottom = -5
                portrait_row.add_theme_constant_override("separation", 8)
                portrait_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
                var portrait_frame := TextureRect.new()
                portrait_frame.name = "VerifiedSourceARosterPortrait"
                portrait_frame.texture = roster_portrait
                portrait_frame.custom_minimum_size = Vector2(44, 64)
                portrait_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                portrait_frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
                portrait_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
                portrait_row.add_child(portrait_frame)
                var portrait_details := VBoxContainer.new()
                portrait_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
                portrait_details.add_theme_constant_override("separation", 1)
                portrait_details.mouse_filter = Control.MOUSE_FILTER_IGNORE
                portrait_row.add_child(portrait_details)
                var portrait_name := Label.new()
                portrait_name.text = roster_disciple.display_name
                portrait_name.tooltip_text = roster_disciple.display_name
                portrait_name.custom_minimum_size.x = 0
                portrait_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
                portrait_name.clip_text = true
                portrait_name.add_theme_font_size_override("font_size", 12)
                portrait_name.add_theme_color_override("font_color", PAPER_LIGHT)
                portrait_details.add_child(portrait_name)
                var portrait_identity := Label.new()
                portrait_identity.text = "%s · %s" % [roster_quality, roster_realm]
                portrait_identity.tooltip_text = "%s · %s" % [roster_quality, roster_realm]
                portrait_identity.custom_minimum_size.x = 0
                portrait_identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
                portrait_identity.clip_text = true
                portrait_identity.add_theme_font_size_override("font_size", 9)
                portrait_identity.add_theme_color_override("font_color", GOLD)
                portrait_details.add_child(portrait_identity)
                var portrait_status := Label.new()
                portrait_status.text = roster_status
                portrait_status.tooltip_text = roster_status_tooltip
                portrait_status.custom_minimum_size.x = 0
                portrait_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
                portrait_status.clip_text = true
                portrait_status.add_theme_font_size_override("font_size", 9)
                portrait_status.add_theme_color_override("font_color", PAPER_LIGHT)
                portrait_details.add_child(portrait_status)
                entry.add_child(portrait_row)
            var is_selected := id == selected_id
            entry.add_theme_stylebox_override("normal", _style(Color(0.31, 0.42, 0.35, 1.0) if is_selected else Color(0.13, 0.22, 0.20, 1.0), GOLD if is_selected else Color(0.43, 0.50, 0.38, 1.0), 2 if is_selected else 1, 8))
            entry.pressed.connect(Callable(self, "_open_disciple_deep_screen").bind(id, tab_name))
            roster.add_child(entry)
        _apply_deep_disciple_roster_filter(disciple_profile_search_query)

    var disciple: DiscipleState = state.disciples[selected_id]

    var showcase := Panel.new()
    showcase.position = Vector2(showcase_x, 58)
    showcase.size = Vector2(300, 394)
    showcase.add_theme_stylebox_override("panel", _style(JADE_DARK, GOLD, 2, 18))
    panel.add_child(showcase)

    # Reuse verified character visuals for legacy saves without fabricating V2 XP.
    var portrait_texture := _disciple_source_a_portrait_texture(disciple)
    if portrait_texture != null:
        var portrait := TextureRect.new()
        portrait.name = "SourceAProfilePortrait"
        portrait.texture = portrait_texture
        portrait.position = Vector2(24, 12)
        portrait.size = Vector2(252, 206)
        portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
        showcase.add_child(portrait)
    else:
        var fallback_avatar := _disciple_avatar_button(disciple, 192.0)
        fallback_avatar.name = "VisualCatalogPortraitFallback"
        fallback_avatar.position = Vector2(54, 12)
        fallback_avatar.size = Vector2(192, 192)
        fallback_avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
        fallback_avatar.focus_mode = Control.FOCUS_NONE
        fallback_avatar.add_theme_stylebox_override("normal", _style(Color(0.79, 0.85, 0.75, 0.0), JADE_DARK, 0, 8))
        showcase.add_child(fallback_avatar)

    var visual_snapshot := _disciple_snapshot(disciple)
    var visual_identity: Dictionary = visual_snapshot.get("identity", {})
    var visual_progression: Dictionary = visual_snapshot.get("progression", {})
    var visual_cultivation: Dictionary = visual_progression.get("cultivation", {})
    var visual_realm := str(visual_cultivation.get("name", CultivationSystem.new().stage_name(disciple)))
    var visual_quality := str(visual_identity.get("quality_name", "Phẩm chất chưa xác định"))
    var center_name := _label(showcase, disciple.display_name, Vector2(16, 224), Vector2(268, 30), 21)
    center_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    center_name.add_theme_color_override("font_color", PAPER_LIGHT)
    var identity_line := _label(showcase, "%s · %s" % [visual_quality, visual_realm], Vector2(14, 256), Vector2(272, 24), 11)
    identity_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    identity_line.add_theme_color_override("font_color", GOLD)
    var center_status := _label(showcase, _deep_status_text(disciple), Vector2(22, 284), Vector2(256, 96), 12)
    center_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    center_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    center_status.add_theme_color_override("font_color", PAPER_LIGHT)

    var content_panel := Panel.new()
    content_panel.position = Vector2(content_x, 58)
    content_panel.size = Vector2(content_width, 394)
    content_panel.add_theme_stylebox_override("panel", _style(Color(0.93, 0.89, 0.78, 0.76), Color(0.50, 0.42, 0.30, 1.0), 1, 10))
    panel.add_child(content_panel)

    var tab_title := _label(content_panel, _disciple_profile_tab_label(tab_name), Vector2(18, 12), Vector2(minf(360.0, content_width - 36.0), 30), 20)
    tab_title.add_theme_color_override("font_color", CINNABAR.darkened(0.18))

    # Make attribute/Body requirements readable without overlapping action row.
    var details_scroll := ScrollContainer.new()
    details_scroll.name = "DiscipleTabContentScroll"
    details_scroll.position = Vector2(18, 118)
    details_scroll.size = Vector2(content_width - 36.0, 220)
    content_panel.add_child(details_scroll)
    var content: Label = null
    if tab_name == "Trang bị":
        # Equipment renders its own controls; do not allocate an orphan Label.
        # The former unparented DiscipleTabContentText leaked its font/TextLine RIDs.
        _build_disciple_equipment_manager(details_scroll,disciple)
    else:
        content = Label.new()
        content.name = "DiscipleTabContentText"
        content.text = _disciple_tab_text(tab_name, disciple)
        content.custom_minimum_size = Vector2(content_width - 56.0, 0)
        content.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        content.add_theme_font_size_override("font_size", 15)
        content.add_theme_color_override("font_color", INK)
        details_scroll.add_child(content)

    # One presentation form for every disciple. Only authoritative values vary.
    var profile_snapshot := _disciple_snapshot(disciple)
    var authentic_v2 := bool(profile_snapshot.get("authentic_v2", false))
    var is_overview_tab := tab_name == "Tổng Quan"
    var progression_snapshot: Dictionary = profile_snapshot.get("progression", {})
    var track_ready := authentic_v2 and bool(progression_snapshot.get("ready", false))
    if track_ready:
        var cultivation_snapshot: Dictionary = progression_snapshot.get("cultivation", {})
        var body_snapshot: Dictionary = progression_snapshot.get("body", {})
        _add_disciple_progress_row(content_panel, "TU VI", float(cultivation_snapshot.get("xp", 0.0)), float(cultivation_snapshot.get("required_xp", 0.0)), Vector2(302, 52), content_width - 324.0, JADE_DARK)
        _add_disciple_progress_row(content_panel, "LUYỆN THỂ", float(body_snapshot.get("xp", 0.0)), float(body_snapshot.get("required_xp", 0.0)), Vector2(302, 82), content_width - 324.0, CINNABAR)
    else:
        var legacy_cultivation := CultivationSystem.new()
        _add_disciple_progress_row(content_panel, "TU VI", disciple.cultivation_progress, legacy_cultivation.required_progress(disciple), Vector2(302, 52), content_width - 324.0, JADE_DARK)
        _add_disciple_unavailable_progress_row(content_panel, "LUYỆN THỂ", Vector2(302, 82), content_width - 324.0)
    if is_overview_tab:
        content.text = _disciple_profile_compact_text(profile_snapshot, disciple)
        if authentic_v2 and disciple.injury_level == 1:
            var remaining := maxi(0,disciple.injury_recover_at_tick-state.tick)
            var quote := PveInjuryTreatmentV1.quote(state,disciple)
            var clinic_note := "Trọng thương: còn %d phút mô phỏng. Hồi sinh đã đầy HP." % remaining
            if bool(quote.get("ok",false)):
                clinic_note += " Điều trị: %d LT / %d phút (không hồi HP)." % [
                    int(quote["cost"]),int(quote["duration_ticks"])]
            content.text += "\n"+clinic_note
        details_scroll.position = Vector2(302, 118)
        details_scroll.size = Vector2(content_width - 324.0, 220)
    if tab_name in ["Thuộc tính", "Tổng Quan"] and bool(profile_snapshot.get("ok",false)):
        var compatibility_radar: DiscipleSixDimensionRadar = null
        var compatibility_radar_ready := false
        if tab_name == "Thuộc tính":
            # Keep the six-dimension legacy node for existing presentation probes.
            compatibility_radar = DiscipleSixDimensionRadar.new()
            compatibility_radar.name = "DiscipleFoundationRadar"
            compatibility_radar.position = Vector2(18,52)
            compatibility_radar.size = Vector2(274,286)
            compatibility_radar.mouse_filter = Control.MOUSE_FILTER_IGNORE
            compatibility_radar.visible = false
            compatibility_radar_ready = compatibility_radar.apply_snapshot(profile_snapshot)
            if compatibility_radar_ready:
                content_panel.add_child(compatibility_radar)

        var radar := HS09DualFoundationRadar.new()
        radar.name = "HS09OverviewRadar" if is_overview_tab else "HS09AttributeRadar"
        radar.compact = is_overview_tab
        radar.position = Vector2(18,52)
        radar.size = Vector2(256,250) if is_overview_tab else Vector2(274,286)
        radar.mouse_filter = Control.MOUSE_FILTER_IGNORE
        var hs09_radar_ready := radar.apply_snapshot(profile_snapshot)
        var text_x := 284.0 if is_overview_tab else 302.0
        if hs09_radar_ready:
            content_panel.add_child(radar)
            details_scroll.position = Vector2(text_x,118)
            details_scroll.size = Vector2(content_width - text_x - 18.0,220)
            content.custom_minimum_size = Vector2(details_scroll.size.x - 22.0,0)
            content.add_theme_font_size_override("font_size",13 if is_overview_tab else 14)
        else:
            radar.free()
            var fallback_radar := compatibility_radar
            if fallback_radar == null:
                fallback_radar = DiscipleSixDimensionRadar.new()
                fallback_radar.name = "LegacyFoundationRadarFallback"
                fallback_radar.position = Vector2(18,52)
                fallback_radar.size = Vector2(256,250) if is_overview_tab else Vector2(274,286)
                fallback_radar.mouse_filter = Control.MOUSE_FILTER_IGNORE
                compatibility_radar_ready = fallback_radar.apply_snapshot(profile_snapshot)
            if compatibility_radar_ready:
                fallback_radar.visible = true
                if fallback_radar.get_parent() == null:
                    content_panel.add_child(fallback_radar)
                details_scroll.position = Vector2(text_x,118)
                details_scroll.size = Vector2(content_width - text_x - 18.0,220)
                content.custom_minimum_size = Vector2(details_scroll.size.x - 22.0,0)
                content.add_theme_font_size_override("font_size",13 if is_overview_tab else 14)
    # One shared profile form; never advertise legacy P2 mutation actions
    # against immutable authentic V2 Bloodline/Physique birth identity.
    match tab_name:
        "Huyết Mạch":
            if not authentic_v2:
                _add_profile_action(content_panel, "Thức tỉnh", Vector2(18, 344), "bloodline_awaken", true)
                _add_profile_action(content_panel, "Luyện huyết", Vector2(140, 344), "bloodline_refine", true)
        "Thể Chất":
            if not authentic_v2:
                _add_profile_action(content_panel, "Tôi thể", Vector2(18, 344), "physique_temper", true)
                _add_profile_action(content_panel, "Cải thể", Vector2(140, 344), "physique_transform", true)
        _:
            _add_profile_action(content_panel, "Chuyên tu", Vector2(18, 344), "v2_cultivate", track_ready)
            _add_profile_action(content_panel, "Rèn thân", Vector2(140, 344), "v2_body_train", track_ready)
    if tab_name == "Tổng Quan" and track_ready:
        if disciple.injury_level == 1:
            # The same profile for old/new recruits. Injury clinic is not an
            # HP shop, and never activates experimental PvE reward economics.
            var clinic_quote := PveInjuryTreatmentV1.quote(state,disciple)
            var remaining_ticks := maxi(0,disciple.injury_recover_at_tick-state.tick)
            var clinic_button := Button.new()
            clinic_button.name = "SectInjuryTreatmentAction"
            # Leave a real gap before the always-visible Locate button even
            # with the 216px disciple roster expanded at 1280x720.
            clinic_button.text = "Chữa trọng thương"
            clinic_button.position = Vector2(266,344)
            clinic_button.size = Vector2(148,40)
            clinic_button.add_theme_font_size_override("font_size",11)
            var affordable := bool(clinic_quote.get("ok",false)) and disciple.spirit_stones >= int(clinic_quote.get("cost",0))
            var busy_clinic := PveInjuryTreatmentV1.treatment_in_progress(state,disciple)
            clinic_button.disabled = not affordable or remaining_ticks <= PveInjuryTreatmentV1.TREATMENT_TICKS or busy_clinic
            clinic_button.tooltip_text = "Đang điều trị, còn %d phút." % remaining_ticks if busy_clinic else (
                "%d LT cá nhân · 30 phút mô phỏng · chỉ xóa trọng thương, không hồi HP." % int(clinic_quote.get("cost",0))
                if affordable else "Không đủ LT, điều trị chưa mở, hoặc sắp tự khỏi. Có thể chờ miễn phí."
            )
            clinic_button.pressed.connect(Callable(self,"_disciple_tab_action").bind("v2_injury_treatment"))
            content_panel.add_child(clinic_button)
        else:
            var tuvi_gate := CultivationGateV57.preview(state,selected_id)
            var tuvi_button := Button.new()
            tuvi_button.name = "V57TuViGateAction"
            tuvi_button.text = "Đột phá Tu Vi"
            tuvi_button.position = Vector2(266,344)
            tuvi_button.size = Vector2(170,40)
            tuvi_button.disabled = not bool(tuvi_gate.get("ok",false))
            tuvi_button.tooltip_text = "Tỷ lệ gốc 25%, thất bại mất 10% EXP tầng 10. Đột Phá Đan có thể tăng xác suất."
            tuvi_button.pressed.connect(Callable(self,"_disciple_tab_action").bind("v57_tuvi_gate"))
            content_panel.add_child(tuvi_button)
    if tab_name == "Thuộc tính":
        var gate_preview := DiscipleBodyGateTransactionV2.new().preview_gate(state,selected_id) if track_ready else {}
        var gate_button := Button.new()
        gate_button.name = "BodyGateRealCommit"
        gate_button.text = "Đột phá Luyện Thể"
        gate_button.position = Vector2(266, 344)
        gate_button.size = Vector2(175, 40)
        gate_button.add_theme_font_size_override("font_size", 12)
        gate_button.add_theme_stylebox_override("normal", _style(CINNABAR, PAPER_LIGHT, 2, 8))
        var can_buy_missing := false
        # A material purchase is meaningful only at an eligible major gate:
        # never offer paid shopping when level/EXP/content/worker gates fail.
        if state.sect.economy_a_enabled and str(gate_preview.get("reason","")) == "body_gate_material_missing":
            for component in gate_preview.get("requirements",[]):
                if component is Dictionary and int(component.get("available",0)) < int(component.get("need",0)) \
                        and not bool(component.get("locked",false)):
                    can_buy_missing = true
                    break
        var gate_can_commit := bool(gate_preview.get("can_commit",false))
        if not gate_can_commit and can_buy_missing:
            gate_button.text = "Mua vật liệu thiếu"
        gate_button.disabled = not gate_can_commit and not can_buy_missing
        gate_button.tooltip_text = "Mua nguyên liệu còn thiếu bằng Linh Thạch tại Phường Thị." if can_buy_missing and not gate_can_commit \
            else (_body_gate_reason(str(gate_preview.get("reason",""))) if track_ready else "Chưa có tiến trình Luyện Thể.")
        gate_button.pressed.connect(Callable(self, "_disciple_tab_action").bind(
            "v2_body_gate" if gate_can_commit else "v57_body_buy_missing"
        ))
        content_panel.add_child(gate_button)
    var locate_button := Button.new()
    locate_button.name = "LocateDiscipleOnMap"
    locate_button.text = "Định vị trên bản đồ"
    locate_button.position = Vector2(content_width - 174.0, 344)
    locate_button.size = Vector2(156, 40)
    locate_button.add_theme_font_size_override("font_size", 12)
    locate_button.add_theme_color_override("font_color", PAPER_LIGHT)
    locate_button.add_theme_stylebox_override("normal", _style(JADE_DARK, INK, 1, 8))
    locate_button.pressed.connect(Callable(self, "_locate_profile_disciple").bind(disciple_id))
    content_panel.add_child(locate_button)

    var tab_names: Array[String] = ["Tổng Quan", "Thuộc tính", "Công pháp", "Trang bị", "Huyết Mạch", "Thể Chất", "Quan hệ"]
    var tab_start := 18.0 + roster_width + 18.0
    var tab_step := (1184.0 - tab_start - 18.0) / float(tab_names.size())
    for index in range(tab_names.size()):
        var tab := Button.new()
        tab.name = "DeepDiscipleTab_%d" % index
        tab.text = _disciple_profile_tab_label(tab_names[index])
        tab.position = Vector2(tab_start + float(index) * tab_step, 470)
        tab.size = Vector2(tab_step - 6.0, 42)
        tab.add_theme_font_size_override("font_size", 14)
        tab.add_theme_color_override("font_color", INK)
        tab.add_theme_color_override("font_hover_color", INK)
        var active := tab_names[index] == tab_name
        tab.add_theme_stylebox_override("normal", _style(Color(0.97, 0.88, 0.64, 1.0) if active else Color(0.88, 0.82, 0.67, 1.0), GOLD if active else Color(0.45, 0.37, 0.25, 1.0), 2 if active else 1, 7))
        tab.pressed.connect(Callable(self, "_open_disciple_deep_screen").bind(selected_id, str(tab_names[index])))
        panel.add_child(tab)
    details_scroll.set_deferred("scroll_vertical",int(disciple_profile_tab_scroll_positions.get("%s|%s" % [str(disciple_id),tab_name],0)))
    _ensure_disabled_controls_readable(panel)


func _on_deep_disciple_roster_sort_changed(index: int, disciple_id: StringName, tab_name: String) -> void:
    disciple_profile_sort_mode = clampi(index,0,4)
    _open_disciple_deep_screen(disciple_id,tab_name,true)


func _deep_disciple_roster_sort_key(disciple: DiscipleState, snapshot: Dictionary, sort_mode: int) -> String:
    var identity: Dictionary = snapshot.get("identity",{})
    var work: Dictionary = snapshot.get("work",{})
    var progression: Dictionary = snapshot.get("progression",{})
    var cultivation_value: Dictionary = progression.get("cultivation",{})
    var name_key := disciple.display_name.strip_edges().to_lower()
    match sort_mode:
        1:
            return "%s|%s" % [str(identity.get("quality_name","")).to_lower(),name_key]
        2:
            var professions: Dictionary = work.get("professions",{})
            var profession_ids: Array = professions.keys()
            profession_ids.sort()
            var profession_parts: Array[String] = []
            for raw_profession_id in profession_ids:
                var profession: Dictionary = professions.get(raw_profession_id,{})
                profession_parts.append("%s:%04d" % [str(raw_profession_id),int(profession.get("level",0))])
            return "%s|%s" % [";".join(profession_parts),name_key]
        3:
            return "%s|%s|%s|%s" % [
                SectMapPresentation.action_label(disciple.current_action).to_lower(),
                str(work.get("worksite_building_id","")).to_lower(),
                str(work.get("group_id","")).to_lower(),name_key
            ]
        4:
            var realm_rank := int(cultivation_value.get("floor",disciple.cultivation_stage_index))
            return "%04d|%s" % [9999 - realm_rank,name_key]
        _:
            return name_key


func _disciple_profile_tab_label(tab_name: String) -> String:
    match tab_name:
        "Tổng Quan": return "Tổng Quan"
        "Thuộc tính": return "Thuộc Tính"
        "Công pháp": return "Công Pháp"
        "Trang bị": return "Trang Bị"
        "Huyết Mạch": return "Huyết Mạch"
        "Thể Chất": return "Thể Chất"
        "Quan hệ": return "Quan Hệ"
        _: return tab_name


func _apply_deep_disciple_roster_filter(query: String) -> void:
    disciple_profile_search_query = query
    var roster := popup_layer.find_child("DeepDiscipleRoster", true, false) as VBoxContainer
    if roster == null:
        return
    var normalized := query.strip_edges().to_lower()
    for child in roster.get_children():
        if child is Button:
            child.visible = normalized.is_empty() or str((child as Button).text).to_lower().contains(normalized)


func _toggle_deep_disciple_roster(tab_name: String) -> void:
    disciple_profile_roster_collapsed = not disciple_profile_roster_collapsed
    if selected_id != &"" and state.disciples.has(selected_id):
        _open_disciple_deep_screen(selected_id, tab_name, true)


func _deep_status_text(disciple: DiscipleState) -> String:
    var snapshot := _disciple_snapshot(disciple)
    var progression: Dictionary = snapshot.get("progression", {})
    var life: Dictionary = snapshot.get("life", {})
    var authentic := bool(snapshot.get("authentic_v2", false)) and bool(progression.get("ready", false))
    var tuvi_text := ""
    var body_text := "Chưa có dữ liệu"
    if authentic:
        var tuvi: Dictionary = progression.get("cultivation", {})
        var body: Dictionary = progression.get("body", {})
        tuvi_text = "%s tầng %d" % [str(tuvi.get("name", "")), int(tuvi.get("floor", 0))]
        body_text = "%s tầng %d" % [str(body.get("name", "")), int(body.get("floor", 0))]
    else:
        var legacy_system := CultivationSystem.new()
        tuvi_text = legacy_system.stage_name(disciple)
    var destination := StringName(actor_destinations.get(str(disciple.id), str(SectMapPresentation.DEST_COURTYARD)))
    return "Tu Vi: %s\nLuyện Thể: %s\nHP %.0f/%.0f · Thể lực %.0f/100\n%s · %s" % [
        tuvi_text, body_text,
        float(life.get("hp", disciple.hp)), float(life.get("max_hp", disciple.max_hp)),
        float(life.get("expedition_stamina", disciple.stamina)),
        SectMapPresentation.action_label(disciple.current_action),
        _building_name(destination)
    ]


func _return_to_disciple_summary() -> void:
    _clear_popup()
    opened_disciple_profile = false
    _close_building_operation_panel(true)
    if deep_restore_summary and selected_id != &"" and state.disciples.has(selected_id):
        _restore_selected_focus_marker()
        _show_disciple_summary()
        return
    _close_disciple_summary(true)

func _locate_profile_disciple(disciple_id: StringName) -> void:
    if state == null or not state.disciples.has(disciple_id):
        return
    var disciple: DiscipleState = state.disciples[disciple_id]
    var point := _disciple_map_point(disciple_id)
    _clear_popup()
    opened_disciple_profile = false
    deep_restore_summary = false
    _close_disciple_summary(true)
    _close_building_operation_panel(true)
    _set_focus_target(point, &"disciple", disciple_id, disciple.display_name, true)

func _add_disciple_unavailable_progress_row(parent: Control, label_text: String, position_value: Vector2, width: float) -> void:
    var label := Label.new()
    label.name = "DiscipleUnavailable_%s" % label_text.replace(" ", "_")
    label.text = "%s  Chưa có dữ liệu" % label_text
    label.position = position_value
    label.size = Vector2(width, 16)
    label.add_theme_font_size_override("font_size", 11)
    label.add_theme_color_override("font_color", INK)
    parent.add_child(label)
    var bar := ProgressBar.new()
    bar.name = "DiscipleProgress_%s" % label_text.replace(" ", "_")
    bar.position = Vector2(position_value.x, position_value.y + 16)
    bar.size = Vector2(width, 9)
    bar.max_value = 100.0
    bar.value = 0.0
    bar.show_percentage = false
    bar.tooltip_text = "Chưa có dữ liệu tiến độ, không phải 0 EXP."
    var fill := StyleBoxFlat.new()
    fill.bg_color = Color(0.60, 0.59, 0.55)
    fill.set_corner_radius_all(4)
    bar.add_theme_stylebox_override("fill", fill)
    parent.add_child(bar)


func _add_disciple_progress_row(parent: Control, label_text: String, xp: float, required: float, position_value: Vector2, width: float, accent: Color) -> void:
    var label := Label.new()
    label.text = ("%s  Đã viên mãn" % label_text) if required <= 0.0 else "%s  %.0f / %.0f" % [label_text, xp, required]
    label.position = position_value
    label.size = Vector2(width, 16)
    label.add_theme_font_size_override("font_size", 11)
    label.add_theme_color_override("font_color", INK)
    parent.add_child(label)
    var bar := ProgressBar.new()
    bar.name = "DiscipleProgress_%s" % label_text.replace(" ", "_")
    bar.position = Vector2(position_value.x, position_value.y + 16)
    bar.size = Vector2(width, 9)
    bar.max_value = 100.0
    bar.value = clampf(xp / required * 100.0, 0.0, 100.0) if required > 0.0 else 100.0
    bar.show_percentage = false
    var fill := StyleBoxFlat.new()
    fill.bg_color = accent
    fill.set_corner_radius_all(4)
    bar.add_theme_stylebox_override("fill", fill)
    parent.add_child(bar)

func _disciple_profile_compact_text(snapshot: Dictionary, disciple: DiscipleState) -> String:
    var life: Dictionary = snapshot.get("life", {})
    var progression: Dictionary = snapshot.get("progression", {})
    var authentic := bool(snapshot.get("authentic_v2", false)) and bool(progression.get("ready", false))
    var tuvi_text := ""
    var body_text := "Chưa có dữ liệu"
    var combat_text := "Chiến lực: %.1f · Công/Thủ chưa có dữ liệu" % disciple.combat_power
    if authentic:
        var cultivation_value: Dictionary = progression.get("cultivation", {})
        var body_value: Dictionary = progression.get("body", {})
        var combat: Dictionary = snapshot.get("combat", {})
        var stats: Dictionary = combat.get("stats", {})
        tuvi_text = "%s tầng %d" % [str(cultivation_value.get("name", "")), int(cultivation_value.get("floor", 0))]
        body_text = "%s tầng %d" % [str(body_value.get("name", "")), int(body_value.get("floor", 0))]
        combat_text = "Công %.1f · Thủ %.1f" % [float(stats.get("attack", 0.0)), float(stats.get("defense", 0.0))]
    else:
        tuvi_text = CultivationSystem.new().stage_name(disciple)
    return "HP %.0f/%.0f · Thể lực %.0f/100\n%s\nTu Vi: %s\nLuyện Thể: %s\n%s" % [
        float(life.get("hp", disciple.hp)), float(life.get("max_hp", disciple.max_hp)),
        float(life.get("expedition_stamina", disciple.stamina)),
        combat_text, tuvi_text, body_text,
        SectMapPresentation.action_label(disciple.current_action)
    ]


func _restore_selected_focus_marker() -> void:
    if selected_id == &"" or not state.disciples.has(selected_id):
        return
    var disciple: DiscipleState = state.disciples[selected_id]
    _set_focus_target(_disciple_map_point(selected_id), &"disciple", selected_id, disciple.display_name, false)

func _tab_notice(tab_name: String) -> void:
    _open_disciple_tab(tab_name)

func _open_disciple_tab(tab_name: String) -> void:
    if selected_id == &"" or not state.disciples.has(selected_id):
        return
    _open_disciple_deep_screen(selected_id, tab_name)

func _add_profile_action(parent: Control, text: String, pos: Vector2, action: String, available: bool) -> void:
    var button := Button.new()
    button.name = "ProfileAction_%s" % action
    button.text = text
    button.position = pos
    button.size = Vector2(112, 40)
    button.add_theme_font_size_override("font_size", 13)
    button.add_theme_stylebox_override("normal", _style(CINNABAR, PAPER_LIGHT, 2, 8))
    button.disabled = not available
    button.tooltip_text = "Chưa có dữ liệu/cơ chế phù hợp cho hành động này." if not available else text
    if available:
        button.pressed.connect(Callable(self, "_disciple_tab_action").bind(action))
    parent.add_child(button)


func _add_tab_action_button(parent: Control, text: String, pos: Vector2, action: String) -> void:
    var button := Button.new()
    button.text = text
    button.position = pos
    button.size = Vector2(112, 40)
    button.add_theme_font_size_override("font_size", 13)
    button.add_theme_stylebox_override("normal", _style(CINNABAR, PAPER_LIGHT, 2, 8))
    button.pressed.connect(Callable(self, "_disciple_tab_action").bind(action))
    parent.add_child(button)


func _disciple_tab_action(action: String) -> void:
    if selected_id == &"" or not state.disciples.has(selected_id):
        return
    var disciple: DiscipleState = state.disciples[selected_id]
    var snapshot := _disciple_snapshot(disciple)
    if action == "v2_injury_treatment":
        if runtime_session == null or not runtime_ready:
            tab_status_text = "Chưa thể lưu điều trị; vui lòng mở phiên chơi trước."
            _open_disciple_deep_screen(selected_id,disciple_profile_active_tab_name,true)
            return
        var request_id := "ui:injury:%s:%d:%d" % [
            str(selected_id),disciple.injury_recover_at_tick,
            state.sect.economy_a_event_count+1
        ]
        var treated := PveInjuryTreatmentV1.start(state,selected_id,request_id)
        if bool(treated.get("ok",false)):
            var receipt: Dictionary = treated.get("receipt",{})
            tab_status_text = "Đã điều trị trọng thương: %d Linh Thạch, %d phút mô phỏng. HP không đổi." % [
                int(receipt.get("cost",0)),PveInjuryTreatmentV1.TREATMENT_TICKS
            ]
            var persisted := runtime_session.save()
            if not bool(persisted.get("ok",false)):
                tab_status_text += " CẢNH BÁO: chưa lưu được; không bấm lại."
        else:
            tab_status_text = "Chưa thể điều trị: "+str(treated.get("reason","không đủ điều kiện"))
        _open_disciple_deep_screen(selected_id,disciple_profile_active_tab_name,true)
        return
    if action == "v57_tuvi_gate":
        _v57_show_tuvi_gate_choices()
        return
    if action == "v57_body_buy_missing":
        _v57_buy_first_body_material(selected_id)
        _open_disciple_deep_screen(selected_id,disciple_profile_active_tab_name,true)
        return
    if action == "v2_body_gate":
        var gate := DiscipleBodyGateTransactionV2.new()
        var checked := gate.preview_gate(state,selected_id)
        if not bool(checked.get("can_commit",false)):
            tab_status_text = _body_gate_reason(str(checked.get("reason","body_gate_denied")))
        else:
            var request_id := "ui:body-gate:%s:%d" % [str(selected_id),int(checked["source_realm"])]
            var applied := gate.commit_gate(state,selected_id,request_id)
            tab_status_text = "Đột phá Luyện Thể thành công." if bool(applied.get("ok",false)) else _body_gate_reason(str(applied.get("reason","")))
            if bool(applied.get("ok",false)) and runtime_ready and runtime_session != null:
                var persisted := runtime_session.save()
                if not bool(persisted.get("ok",false)):
                    tab_status_text += " CẢNH BÁO: chưa lưu được tiến độ."
        _open_disciple_deep_screen(selected_id,disciple_profile_active_tab_name,true)
        return
    if action == "v2_cultivate" or action == "v2_body_train":
        var track := "body" if action == "v2_body_train" else "cultivation"
        tab_status_text = _v2_training_ui_feedback(_queue_v2_training(track),track)
        # Normal tab navigation clears old feedback; this explicit action
        # refresh must retain the real backend receipt/rejection for the player.
        _open_disciple_deep_screen(selected_id,disciple_profile_active_tab_name,true)
        return
    var requested_tab := "Huyết Mạch" if action.begins_with("bloodline_") else "Thể Chất"
    if bool(snapshot.get("ok", false)) and bool(snapshot.get("authentic_v2", false)):
        tab_status_text = "Cơ chế cũ không áp dụng cho hồ sơ này."
        _open_disciple_tab(requested_tab)
        return

    var result: Dictionary = {}
    var tab_name := "Thuộc tính"
    match action:
        "bloodline_awaken":
            result = bloodlines.awaken_bloodline(state, selected_id)
            tab_name = "Huyết Mạch"
        "bloodline_refine":
            result = bloodlines.refine_bloodline(state, selected_id)
            tab_name = "Huyết Mạch"
        "physique_temper":
            result = physiques.temper_body(state, selected_id)
            tab_name = "Thể Chất"
        "physique_transform":
            result = physiques.transform_body(state, selected_id)
            tab_name = "Thể Chất"
        _:
            return
    tab_status_text = _action_result_text(result)
    _open_disciple_tab(tab_name)

func _action_result_text(result: Dictionary) -> String:
    if result.is_empty():
        return "Không có thay đổi."
    var ok := bool(result.get("ok", false))
    var reason := _player_reason_text(str(result.get("reason", "")))
    return "%s%s" % [
        "Thành công" if ok else "Chưa thể thực hiện",
        "" if reason == "" else " · %s" % reason
    ]

func _player_reason_text(reason: String) -> String:
    match reason:
        "bloodlines_disabled_or_disciple_missing", "physiques_disabled_or_disciple_missing":
            return "Không tìm thấy đệ tử."
        "profile_missing":
            return "Chưa có hồ sơ phù hợp."
        "no_special_bloodline":
            return "Không có huyết mạch đặc biệt để thức tỉnh."
        "bloodline_hidden":
            return "Huyết mạch vẫn chưa được phát hiện."
        "already_awakened":
            return "Huyết mạch đã thức tỉnh."
        "bloodline_not_awakened":
            return "Cần thức tỉnh huyết mạch trước."
        "max_purity":
            return "Độ thuần đã đạt giới hạn."
        "yao_core_missing":
            return "Không đủ Yêu Đan."
        "max_temper_level":
            return "Tôi thể đã đạt giới hạn."
        "already_special_physique":
            return "Đã có thể chất đặc biệt."
        "temper_level_too_low":
            return "Cần tôi thể thêm trước khi cải thể."
        "transformation_target_missing":
            return "Chưa có hướng cải thể phù hợp."
        "spirit_essence_missing":
            return "Không đủ Linh Tủy."
        "awakened":
            return "Huyết mạch đã thức tỉnh."
        "refined":
            return "Độ thuần huyết mạch đã tăng."
        "tempered":
            return "Tôi thể thành công."
        "transformed":
            return "Cải thể thành công."
        _:
            return ""


# F4 pure V2 read model: one selected disciple, no per-roster scans.
# Explicit selection: never silently consume Q4 while player expects a
# baseline 25% breakthrough. Popup is anchored in the existing disciple screen.
func _v57_show_tuvi_gate_choices() -> void:
    if selected_id == &"" or not state.disciples.has(selected_id):
        return
    var check := CultivationGateV57.preview(state,selected_id)
    if not bool(check.get("ok",false)):
        tab_status_text = "Chưa thể đột phá: "+str(check.get("reason",""))
        _open_disciple_deep_screen(selected_id,disciple_profile_active_tab_name,true)
        return
    var popup := PopupMenu.new()
    popup.name = "V57TuViPillChoice"
    popup.add_item("Không dùng đan — 25% + pity",0)
    var realm := int(check["realm"])
    var warehouse := WarehouseSystem.new()
    for quality in range(1,5):
        var item := MedicineCatalogueV2.item_id(MedicineCatalogueV2.FAMILY_BREAK,realm,quality)
        if item == &"" or not warehouse.can_consume(state,item,1):
            continue
        var info := MedicineCatalogueV2.definition(item)
        popup.add_item("Dùng Q%d — +%d điểm %% (Kho: %d)" % [
            quality,int(info.get("potency",0)),warehouse.available_quantity(state,item)
        ],quality)
    popup.id_pressed.connect(_v57_commit_tuvi_gate)
    popup_layer.add_child(popup)
    popup.popup_centered(Vector2i(420,280))

func _v57_commit_tuvi_gate(quality: int) -> void:
    if selected_id == &"" or not state.disciples.has(selected_id):
        return
    var d: DiscipleState = state.disciples[selected_id]
    var realm := int(d.v2_realm_progress.get("cultivation",{}).get("realm",0))
    var pill := MedicineCatalogueV2.item_id(MedicineCatalogueV2.FAMILY_BREAK,realm,quality) if quality > 0 else &""
    var event_id := "ui:v57:gate:%s:%d:%d" % [str(selected_id),realm,state.tick]
    var outcome := CultivationGateV57.attempt(state,selected_id,event_id,pill)
    if bool(outcome.get("ok",false)):
        tab_status_text = "Đột phá thành công!" if bool(outcome.get("success",false)) else "Thất bại: mất 10% EXP tầng 10."
        if pill != &"":
            tab_status_text += " Đã dùng Đột Phá Đan Q%d." % quality
        if runtime_ready and runtime_session != null:
            var saved := runtime_session.save()
            if not bool(saved.get("ok",false)):
                tab_status_text += " Chưa xác nhận lưu."
    else:
        tab_status_text = "Không thể đột phá: "+str(outcome.get("reason",""))
    _open_disciple_deep_screen(selected_id,disciple_profile_active_tab_name,true)

func _v57_buy_first_body_material(disciple_id: StringName) -> void:
    if disciple_id == &"" or not state.disciples.has(disciple_id):
        return
    var disciple: DiscipleState = state.disciples[disciple_id]
    var body: Dictionary = disciple.v2_realm_progress.get("body",{})
    var request_id := "ui:v57:body:%s:%d:%d" % [
        str(disciple_id),int(body.get("realm",0)),state.sect.economy_a_event_count+1
    ]
    var result := EconomySystem.new().buy_missing_body_gate_materials(state,disciple_id,request_id)
    if bool(result.get("ok",false)):
        var receipt: Dictionary = result.get("receipt",{})
        tab_status_text = "Đã mua %d vật liệu thiếu, trả %d LT." % [
            int(receipt.get("quantity",0)),int(receipt.get("cost",0))
        ]
        if not bool(result.get("complete",false)):
            tab_status_text += " Vẫn còn vật liệu cần kiếm hoặc mua."
        if runtime_ready and runtime_session != null:
            var saved := runtime_session.save()
            if not bool(saved.get("ok",false)):
                tab_status_text += " Chưa xác nhận lưu."
    else:
        tab_status_text = "Không mua được: "+str(result.get("reason",""))


func _body_gate_preview_text(disciple_id: StringName) -> String:
    var preview := DiscipleBodyGateTransactionV2.new().preview_gate(state,disciple_id)
    if not bool(preview.get("ok",false)):
        return "Đột phá Luyện Thể: " + _body_gate_reason(str(preview.get("reason","")))
    var lines: Array[String] = []
    lines.append("ĐỘT PHÁ LUYỆN THỂ %d → %d | EXP %.0f / %.0f" % [
        int(preview["source_realm"]),int(preview["target_realm"]),
        float(preview["xp_have"]),float(preview["xp_need"])
    ])
    var registry := ResourceRegistry.new()
    var requirements: Array = preview.get("requirements",[])
    for data in requirements:
        var material: Dictionary = data
        var note := " [KHÓA]" if bool(material["locked"]) else (
            " [DỰ TRỮ]" if int(material["available"]) < int(material["total"]) else ""
        )
        lines.append("• %s: dùng được %d/%d (kho %d)%s" % [
            registry.display_name(StringName(material["item_id"])),
            int(material["available"]),int(material["need"]),int(material["total"]),note
        ])
    lines.append("Trạng thái: " + (
        "ĐỦ ĐIỀU KIỆN — có thể đột phá" if bool(preview.get("can_commit",false))
        else _body_gate_reason(str(preview.get("reason","")))
    ))
    if int(preview["source_realm"]) <= 6:
        lines.append("Nguồn: Linh Điền / săn Thanh Trúc Lâm, Bạch Thạch Khê, Hắc Phong Cốc.")
    else:
        lines.append("Nguồn: mua bằng Linh Thạch ở Phường Thị (có hạn mức/ngày); không cấp vật phẩm miễn phí.")
    return "\n".join(lines)

func _body_gate_reason(reason: String) -> String:
    match reason:
        "": return "Sẵn sàng."
        "content_unavailable": return "Nội dung chưa mở; cần vùng và nguồn vật phẩm thật."
        "body_major_gate_not_ready": return "Cần đạt tầng 10 Luyện Thể."
        "body_gate_xp_incomplete": return "Chưa đủ EXP Luyện Thể tầng 10."
        "body_gate_material_missing": return "Thiếu nguyên liệu tại Kho Tông Môn."
        "body_gate_material_locked_or_reserved": return "Nguyên liệu đang khóa hoặc được đặt mức dự trữ."
        "body_gate_disciple_busy": return "Đệ tử đang thực hiện hoạt động khác."
        "body_gate_disciple_unavailable": return "Đệ tử phải còn sống và ở tông môn."
        "body_gate_already_committed": return "Đã đột phá cổng này; không trừ trùng."
        "body_gate_last_realm": return "Đã tới đại cảnh giới cuối."
        _: return "Không thể đột phá (" + reason + ")."

func _disciple_overview_tab_text(disciple: DiscipleState) -> String:
    var snapshot := _disciple_snapshot(disciple)
    if not bool(snapshot.get("ok",false)):
        return "Không thể đọc hồ sơ đệ tử."
    var identity: Dictionary = snapshot.get("identity",{})
    var life: Dictionary = snapshot.get("life",{})
    var work: Dictionary = snapshot.get("work",{})
    var progression: Dictionary = snapshot.get("progression",{})
    var v63: Dictionary = snapshot.get("v63",{})
    var sex_label: String = str({"male":"Nam","female":"Nữ"}.get(str(identity.get("sex_id","")),"Chưa xác định"))
    var race_label: String = str({"human":"Nhân tộc"}.get(str(identity.get("race_id","")),"Chưa xác định"))
    var lines: Array[String] = [
        "Thân phận: %s · %s · %s" % [
            sex_label,
            race_label,
            str(identity.get("quality_name",""))
        ],
        "Tuổi: %d · Tuổi thọ cơ sở/tối đa: %d/%d" % [
            int(identity.get("age",0)),
            int(identity.get("base_lifespan",0)),
            int(identity.get("max_lifespan",0))
        ],
        "HP: %.0f/%.0f · Thể lực viễn chinh: %.0f" % [
            float(life.get("hp",0.0)),
            float(life.get("max_hp",0.0)),
            float(life.get("expedition_stamina",0.0))
        ]
    ]
    if int(life.get("injury_level",0)) > 0:
        lines.append("Thương Thế: Đang hồi phục · còn %d tick mô phỏng" % int(life.get("injury_remaining_ticks",0)))
    else:
        lines.append("Thương Thế: Khỏe mạnh")
    lines.append("Hành động: %s · Nhóm việc: %s" % [
        SectMapPresentation.action_label(StringName(life.get("current_action",""))),
        _work_group_label_id(StringName(work.get("group_id","")))
    ])
    var active_job_id := str(life.get("active_job_id",""))
    lines.append("Tác vụ đang giữ: %s" % (active_job_id if not active_job_id.is_empty() else "Không có"))
    var worksite_id := str(work.get("worksite_building_id",""))
    if not worksite_id.is_empty():
        lines.append("Nơi làm việc: %s" % _building_name(StringName(worksite_id)))
    lines.append(_v2_profession_summary_text(snapshot))
    if bool(snapshot.get("authentic_v2",false)) and bool(progression.get("ready",false)):
        var cultivation: Dictionary = progression.get("cultivation",{})
        var body: Dictionary = progression.get("body",{})
        lines.append("Tu Vi: %s tầng %d · Luyện Thể: %s tầng %d" % [
            str(cultivation.get("name","")),
            int(cultivation.get("floor",0)),
            str(body.get("name","")),
            int(body.get("floor",0))
        ])
    elif not bool(snapshot.get("authentic_v2",false)):
        var legacy_cultivation := CultivationSystem.new()
        var legacy_required := legacy_cultivation.required_progress(disciple)
        var legacy_progress := "Đã viên mãn" if legacy_required <= 0.0 else "%.0f/%.0f EXP" % [disciple.cultivation_progress,legacy_required]
        lines.append("Tu Vi: %s · %s" % [legacy_cultivation.stage_name(disciple),legacy_progress])
        lines.append("Luyện Thể: Chưa có dữ liệu")
    else:
        lines.append("Tu Vi / Luyện Thể: Chưa có dữ liệu")
    var gates: Dictionary = v63.get("feature_gates",{})
    lines.append("V6.3 gate · Tàng Kinh Các %s · Học công pháp %s · Combat %s/%s" % [
        "ON" if bool(gates.get("sect_codex",false)) else "OFF",
        "ON" if bool(gates.get("technique_learning",false)) else "OFF",
        "ON" if bool(gates.get("human_skill_combat",false)) else "OFF",
        "ON" if bool(gates.get("divine_skill_combat",false)) else "OFF"
    ])
    var study: Dictionary = v63.get("study",{})
    if bool(study.get("active",false)):
        var job: Dictionary = study.get("job",{})
        lines.append("Nghiên cứu: %s · %.0f%% · còn %d tick" % [
            str(V63LearningSystem.definition(StringName(job.get("technique_id",""))).get("name",job.get("technique_id",""))),
            float(study.get("progress",0.0))*100.0,
            int(study.get("remaining_ticks",0))
        ])
    lines.append("Hồ sơ chỉ đọc · không tự cộng bonus hoặc tạo hành động.")
    return "\n".join(lines)


func _disciple_tab_text(tab_name: String, disciple: DiscipleState) -> String:
    match tab_name:
        "Tổng Quan":
            return _disciple_overview_tab_text(disciple)
        "Thuộc tính":
            return _attributes_tab_text(disciple)
        "Công pháp":
            return _technique_tab_text(disciple)
        "Trang bị":
            return _equipment_tab_text(disciple)
        "Huyết Mạch":
            return _bloodline_tab_text(disciple)
        "Thể Chất":
            return _physique_tab_text(disciple)
        "Quan hệ":
            return _relationship_tab_text(disciple)
        _:
            return "Chưa có dữ liệu."


func _attributes_tab_text(disciple: DiscipleState) -> String:
    var snapshot := _disciple_snapshot(disciple)
    if bool(snapshot.get("ok", false)) and bool(snapshot.get("authentic_v2", false)):
        var foundation_snapshot: Dictionary = snapshot.get("foundations",{})
        return (
            _v2_attributes_tab_text(snapshot)
            + "\n\n" + _v2_foundation_meaning_text(int(foundation_snapshot.get("model_version",1)))
            + "\n\n" + _v2_profession_summary_text(snapshot)
            + "\n\n" + _body_gate_preview_text(disciple.id)
        )

    var required := cultivation.required_progress(disciple)
    var progress_text := "Đã viên mãn" if required <= 0.0 else "%.0f / %.0f" % [disciple.cultivation_progress, required]
    var chance := cultivation.breakthrough_success_chance(disciple, state) * 100.0
    var power := cultivation.effective_combat_power(state, disciple)
    var path_lines := [
        "Kiếm %.1f" % float(disciple.cultivation_path_xp.get("sword", 0.0)),
        "Thể %.1f" % float(disciple.cultivation_path_xp.get("body", 0.0)),
        "Pháp %.1f" % float(disciple.cultivation_path_xp.get("spell", 0.0))
    ]
    return (
        "Tu Vi: %s · %s\nLuyện Thể: Chưa có dữ liệu\nChiến lực hiệu dụng: %.1f · Đột phá: %.1f%%\n"
        + "HP %.0f/%.0f · Thể lực %.0f/100 · Ví %d\n\n"
        + "Tư Chất %s · Căn Cốt %s · Cơ Duyên %s\nThông Tuệ %s · Mị Lực %s · Tiềm Lực %s\n\n"
        + "Tích lũy đường tu: %s\nHành động hiện tại: %s\n%s"
    ) % [
        cultivation.stage_name(disciple), progress_text, power, chance,
        disciple.hp, disciple.max_hp, disciple.stamina, disciple.wallet,
        _foundation_exact_number(disciple.aptitude), _foundation_exact_number(disciple.constitution), _foundation_exact_number(disciple.fortune),
        _foundation_exact_number(disciple.comprehension), _foundation_exact_number(disciple.charisma), _foundation_exact_number(disciple.potential),
        " · ".join(path_lines), SectMapPresentation.action_label(disciple.current_action),
        tab_status_text
    ] + "\n\n" + _v2_profession_summary_text(snapshot)


func _v2_attributes_tab_text(snapshot: Dictionary) -> String:
    var progression: Dictionary = snapshot["progression"]
    var life: Dictionary = snapshot["life"]
    var foundation_snapshot: Dictionary = snapshot["foundations"]
    var foundations: Dictionary = foundation_snapshot["current"]
    var foundation_model_version := int(foundation_snapshot.get("model_version",1))
    var foundation_text := _v2_foundation_values_text(foundation_snapshot)
    var innate: Dictionary = snapshot["innate"]
    if not bool(progression.get("ready", false)):
        return (
            "Hồ sơ tiến độ chưa sẵn sàng. Không dùng cảnh giới cũ để thay thế.\n\n"
            + "HP %.0f/%.0f · Thể lực viễn chinh %.0f/100\n"
            + "%s"
        ) % [
            float(life["hp"]), float(life["max_hp"]), float(life["expedition_stamina"]),
            foundation_text
        ]

    var tuvi: Dictionary = progression["cultivation"]
    var body: Dictionary = progression["body"]
    var combat: Dictionary = snapshot["combat"]
    var stats: Dictionary = combat.get("stats", {})
    var gate_text := "Chưa tới cổng đại cảnh"
    if bool(tuvi.get("at_major_gate", false)):
        gate_text = "Đột phá %.1f%%" % (float(tuvi.get("effective_breakthrough_chance", 0.0)) * 100.0)
    var body_gate := "Chưa tới cổng đại cảnh"
    if bool(body.get("at_major_gate", false)):
        body_gate = "Đủ EXP; cần hoàn tất yêu cầu Thối Thể"

    return (
        "Tu Vi: %s tầng %d · %.0f / %.0f · %s\n"
        + "Luyện Thể: %s tầng %d · %.0f / %.0f · %s\n"
        + "HP %.0f/%.0f · Công %.1f · Thủ %.1f · Thể lực viễn chinh %.0f/100\n\n"
        + "%s\n\n"
        + "Linh Căn: %s\n"
        + "Đặc Chất: %s\n"
        + "Huyết Mạch: %s · Thể Chất: %s · Mệnh Cách: %s\n"
        + "Hiệu ứng đặc thù bẩm sinh: Chưa khả dụng\n"
        + "Hành động hiện tại: %s\n%s"
    ) % [
        str(tuvi["name"]), int(tuvi["floor"]), float(tuvi["xp"]), float(tuvi["required_xp"]), gate_text,
        str(body["name"]), int(body["floor"]), float(body["xp"]), float(body["required_xp"]), body_gate,
        float(life["hp"]), float(life["max_hp"]),
        float(stats.get("attack", 0.0)), float(stats.get("defense", 0.0)),
        float(life["expedition_stamina"]),
        foundation_text,
        _v2_root_brief(innate), _v2_trait_brief(innate),
        _v2_identity_brief(innate["bloodline"], "Không"),
        _v2_identity_brief(innate["physique"], "Không"),
        _v2_identity_brief(innate["destiny"], "Không"),
        SectMapPresentation.action_label(StringName(life["current_action"])),
        tab_status_text
    ]


func _v2_foundation_values_text(foundation_snapshot: Dictionary) -> String:
    var current: Dictionary = foundation_snapshot.get("current",{})
    var version := int(foundation_snapshot.get("model_version",1))
    if version >= FoundationSystem.MODEL_D7:
        var labels: Dictionary = foundation_snapshot.get("labels",{})
        var birth: Dictionary = foundation_snapshot.get("birth",{})
        var delta: Dictionary = foundation_snapshot.get("delta",{})
        var format_row := func(key: String) -> String:
            var value := float(current.get(key,0.0))
            var born := float(birth.get(key,0.0))
            var change := float(delta.get(key,0.0))
            var sign := "+" if change >= 0.0 else "−"
            return "%s %s · sinh %s · Δ %s%s" % [
                str(labels.get(key,key)),_foundation_exact_number(value),
                _foundation_exact_number(born),sign,_foundation_exact_number(absf(change))
            ]
        var tam_can_rows := "\n  ".join([
            format_row.call("aptitude"),format_row.call("constitution"),format_row.call("mind_nature")
        ])
        var tu_tinh_rows := "\n  ".join([
            format_row.call("potential"),format_row.call("comprehension"),
            format_row.call("fortune"),format_row.call("charisma")
        ])
        var quality_line := ""
        if foundation_snapshot.has("quality_birth_total") and foundation_snapshot.has("quality_current_total"):
            var generator := DiscipleGeneratorV2.new()
            var birth_name := generator.quality_name(StringName(foundation_snapshot.get("quality_birth_id","common")))
            var current_name := generator.quality_name(StringName(foundation_snapshot.get("quality_current_id","common")))
            quality_line = "\nPhẩm chất · %s (Q %.2f) → %s (Q %.2f)" % [
                birth_name,float(foundation_snapshot["quality_birth_total"]),
                current_name,float(foundation_snapshot["quality_current_total"])
            ]
        return "Tam Căn / Tứ Tính · sinh / hiện tại / thay đổi\nTam Căn:\n  %s\nTứ Tính:\n  %s%s" % [tam_can_rows,tu_tinh_rows,quality_line]
    return "Nền tảng kế thừa · Tư Chất %s · Căn Cốt %s · Cơ Duyên %s\nThông Tuệ %s · Mị Lực %s · Tiềm Lực %s" % [
        _v2_foundation_score(float(current.get("aptitude",0.0)),version),
        _v2_foundation_score(float(current.get("constitution",0.0)),version),
        _v2_foundation_score(float(current.get("fortune",0.0)),version),
        _v2_foundation_score(float(current.get("comprehension",0.0)),version),
        _v2_foundation_score(float(current.get("charisma",0.0)),version),
        _v2_foundation_score(float(current.get("potential",0.0)),version)
    ]

func _foundation_exact_number(value: float) -> String:
    if is_equal_approx(value,round(value)):
        return str(int(round(value)))
    return "%.3f" % value

func _v2_foundation_meaning_text(model_version: int) -> String:
    if model_version >= FoundationSystem.MODEL_D7:
        return (
            "Tam Căn · dữ liệu hiện tại: Tư Chất +0,25% Tu Vi tự nhiên/điểm · Căn Cốt +0,20% EXP Luyện Thể/điểm.\n"
            + "Tâm Tính được tính vào tổng phẩm chất D7; hiện chưa có hiệu ứng gameplay riêng.\n"
            + "Tứ Tính · Tiềm Lực +0,05% Tu Vi RealmCore HP/Công/Thủ/điểm · Thông Tuệ +0,15% học tập/nghề hợp lệ/điểm\n"
            + "Cơ Duyên: +1 điểm kiểm tra RNG · Mị Lực: điểm xã hội/Dẫn Tiên"
        )
    return (
        "Hiệu ứng thuộc tính của hồ sơ nền tảng kế thừa (điểm hiện tại)\n"
        + "Tư Chất: +0,25% / điểm vào Tu Vi tự nhiên\n"
        + "Căn Cốt: +0,20% / điểm vào EXP Luyện Thể\n"
        + "Thông Tuệ: +0,15% / điểm vào học / EXP nghề hợp lệ\n"
        + "Tiềm Lực: +0,05% / điểm vào lõi HP, Công, Thủ\n"
        + "Cơ Duyên: kiểm tra vận may khi có sự kiện hợp lệ\n"
        + "Mị Lực: kiểm tra tương tác xã hội khi có sự kiện hợp lệ"
    )


func _v2_profession_summary_text(snapshot: Dictionary) -> String:
    var work: Dictionary = snapshot.get("work", {})
    var professions: Dictionary = work.get("professions", {})
    var names := {
        "mining":"Khai Khoáng", "forestry":"Lâm Nghiệp",
        "herbalism":"Linh Thực", "alchemy":"Luyện Đan",
        "forging":"Luyện Khí", "logistics":"Hậu Cần"
    }
    var lines: Array[String] = ["Nghề nghiệp · cấp / EXP:"]
    for profession_id in ["mining","forestry","herbalism","alchemy","forging","logistics"]:
        var row: Dictionary = professions.get(profession_id, {})
        lines.append("• %s Lv%d · EXP %.1f" % [
            str(names[profession_id]), int(row.get("level",0)), float(row.get("xp",0.0))
        ])
    var site := str(work.get("worksite_building_id",""))
    if not site.is_empty():
        lines.append("Điểm làm việc: %s" % site)
    return "\n".join(lines)


func _technique_tab_text(disciple: DiscipleState) -> String:
    var snapshot := _disciple_snapshot(disciple)
    if not bool(snapshot.get("ok", false)):
        return "Không thể đọc dữ liệu Công Pháp."
    if bool(snapshot.get("authentic_v2",false)):
        return _v63_technique_tab_text(snapshot)
    var learning: Dictionary = snapshot["learning"]
    var learned: Dictionary = learning.get("learned_techniques", {})
    var active_id := StringName(learning.get("active_technique_id", ""))
    var lines: Array[String] = []
    var ids: Array = learned.keys()
    ids.sort()
    for raw_id in ids:
        var technique_id := StringName(raw_id)
        var mastery: Dictionary = learned[raw_id]
        lines.append("• %s · Lv%d · XP %.1f%s" % [
            technique_system.technique_name(technique_id),
            int(mastery.get("level", 1)),
            float(mastery.get("xp", 0.0)),
            " · ĐANG DÙNG" if active_id == technique_id else ""
        ])
    if lines.is_empty():
        lines.append("• Chưa học công pháp")
    var note := ""
    if bool(snapshot.get("authentic_v2", false)):
        note = "\n\nCơ chế Công Pháp mới chưa khả dụng; dữ liệu đang lưu chỉ được hiển thị, không tự cộng hiệu ứng mới."
    var life: Dictionary = snapshot["life"]
    return "Công pháp đã học: %d/%d\nCống hiến: %d · Linh thạch cá nhân: %d\n\n%s%s" % [
        learned.size(), TechniqueSystem.MAX_LEARNED_TECHNIQUES,
        int(life["contribution_points"]), int(life["personal_spirit_stones"]),
        "\n".join(lines), note
    ]


func _v63_technique_tab_text(snapshot: Dictionary) -> String:
    var v63: Dictionary = snapshot.get("v63",{})
    var gates: Dictionary = v63.get("feature_gates",{})
    var known: Dictionary = v63.get("known_techniques",{})
    var archived_codices: Dictionary = v63.get("archived_codices",{})
    var loadout: Dictionary = v63.get("loadout",{})
    var lines: Array[String] = []
    for slot in ["main","aux_1","aux_2"]:
        var technique_id := str(loadout.get(slot,""))
        var slot_label := "Chủ Tu" if slot == "main" else ("Phụ Tu 1" if slot == "aux_1" else "Phụ Tu 2")
        if technique_id.is_empty():
            lines.append("• %s: Chưa trang bị" % slot_label)
            continue
        var definition_row := V63LearningSystem.definition(StringName(technique_id))
        var knowledge: Dictionary = known.get(technique_id,{})
        var mastery_xp := float(knowledge.get("mastery_xp",0.0))
        var mastery_stage := int(knowledge.get("mastery_stage",V63LearningSystem.mastery_stage_for_xp(mastery_xp)))
        lines.append("• %s: %s · Tầng tinh thông %d · XP %.0f" % [
            slot_label,
            str(definition_row.get("name",technique_id)),
            mastery_stage,
            mastery_xp
        ])
    var study: Dictionary = v63.get("study",{})
    var study_text := "Không có nghiên cứu đang chạy"
    if bool(study.get("active",false)):
        var job: Dictionary = study.get("job",{})
        var technique_id := StringName(job.get("technique_id",""))
        var study_definition := V63LearningSystem.definition(technique_id)
        study_text = "%s · %.0f%% · còn %d tick" % [
            str(study_definition.get("name",str(technique_id))),
            float(study.get("progress",0.0))*100.0,
            int(study.get("remaining_ticks",0))
        ]
    if known.is_empty():
        lines.append("• Chưa có công pháp V6.3 được lưu")
    return (
        "Bí kíp đã lưu: %d · Kỹ năng đã biết: %d\n%s\n\n"
        + "Nghiên cứu: %s\n"
        + "Gate Tàng Kinh Các: %s · Học: %s · Nhân kỹ năng: %s · Thần kỹ năng: %s\n\n"
        + "Dữ liệu và tinh thông được đọc từ hồ sơ đã lưu. Profile không tự học, trang bị hay cộng hiệu ứng."
    ) % [
        archived_codices.size(),
        known.size(),
        "\n".join(lines),
        study_text,
        "ON" if bool(gates.get("sect_codex",false)) else "OFF",
        "ON" if bool(gates.get("technique_learning",false)) else "OFF",
        "ON" if bool(gates.get("human_skill_combat",false)) else "OFF",
        "ON" if bool(gates.get("divine_skill_combat",false)) else "OFF"
    ]


func _build_disciple_equipment_manager(parent: ScrollContainer, disciple: DiscipleState) -> void:
    var manager := VBoxContainer.new()
    manager.name = "DiscipleEquipmentManager"
    manager.custom_minimum_size = Vector2(maxf(parent.size.x-18.0,560.0),0)
    manager.add_theme_constant_override("separation",5)
    parent.add_child(manager)

    var wallet := Label.new()
    wallet.name = "EquipmentWallet"
    wallet.text = "Ví cá nhân: %d · Ngân khố tông môn: %d" % [disciple.wallet,state.sect.treasury]
    wallet.add_theme_font_size_override("font_size",13)
    wallet.add_theme_color_override("font_color",INK)
    manager.add_child(wallet)

    var note := Label.new()
    note.name = "EquipmentCombatV2Note"
    note.text = "Kho Tông Môn: cấp phát miễn phí. Phường Thị: mua bằng ví cá nhân. Khóa ô để giữ trang bị đã chọn."
    note.custom_minimum_size = Vector2(manager.custom_minimum_size.x,36)
    note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    note.add_theme_font_size_override("font_size",11)
    note.add_theme_color_override("font_color",INK)
    manager.add_child(note)

    if not state.sect.equipment_enabled:
        var unavailable := Label.new()
        unavailable.text = "Trang bị chưa được mở trong trạng thái này."
        unavailable.add_theme_color_override("font_color",CINNABAR)
        manager.add_child(unavailable)
        return
    if not tab_status_text.is_empty():
        var feedback := Label.new()
        feedback.name = "EquipmentActionFeedback"
        feedback.text = tab_status_text
        feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        feedback.custom_minimum_size = Vector2(manager.custom_minimum_size.x,24)
        feedback.add_theme_font_size_override("font_size",11)
        feedback.add_theme_color_override("font_color",CINNABAR)
        manager.add_child(feedback)

    var item_ids: Array = state.sect.equipment_items.keys()
    item_ids.sort()
    for raw_slot in EquipmentSystem.VALID_SLOTS:
        var slot := StringName(raw_slot)
        var slot_key := str(slot)
        var equipped := equipment_system.equipped_item(state,disciple,slot)
        var locked := bool(disciple.locked_equipment_slots.get(slot_key,false))
        var current_name := "Chưa trang bị"
        if not equipped.is_empty():
            current_name = "%s · %s" % [
                str(equipped.get("name",equipped.get("id","?"))),
                equipment_system.quality_name(StringName(equipped.get("quality","pham")))
            ]
        var current_label := Label.new()
        current_label.name = "EquipmentCurrent_%s" % slot_key
        current_label.text = "%s: %s · %s" % [
            _equipment_slot_name(slot),current_name,"Ô khóa" if locked else "Tự động"
        ]
        current_label.custom_minimum_size = Vector2(manager.custom_minimum_size.x,20)
        current_label.add_theme_font_size_override("font_size",12)
        current_label.add_theme_color_override("font_color",INK)
        manager.add_child(current_label)

        var row := HBoxContainer.new()
        row.name = "EquipmentControls_%s" % slot_key
        row.custom_minimum_size = Vector2(manager.custom_minimum_size.x,38)
        row.add_theme_constant_override("separation",5)
        manager.add_child(row)

        var picker := OptionButton.new()
        picker.name = "EquipmentPicker_%s" % slot_key
        picker.custom_minimum_size = Vector2(250,36)
        picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        picker.add_theme_font_size_override("font_size",11)
        for raw_item_id in item_ids:
            var item_id := str(raw_item_id)
            var item: Dictionary = state.sect.equipment_items[item_id]
            if str(item.get("slot","")) != slot_key or StringName(item.get("location","")) == EquipmentSystem.LOCATION_EQUIPPED:
                continue
            var location := StringName(item.get("location",""))
            var where := "Kho" if location == EquipmentSystem.LOCATION_STORAGE else "Cửa hàng"
            var suffix := " · giá %d" % int(item.get("price",0)) if location == EquipmentSystem.LOCATION_SHOP else ""
            picker.add_item("%s · %s · %s%s" % [
                str(item.get("name",item_id)),
                equipment_system.quality_name(StringName(item.get("quality","pham"))),
                where,suffix
            ])
            picker.set_item_metadata(picker.item_count-1,item_id)
        if picker.item_count == 0:
            picker.add_item("Không có vật phẩm phù hợp")
            picker.disabled = true
            picker.set_item_metadata(0,"")
        else:
            picker.select(0)
        row.add_child(picker)

        var equip_button := Button.new()
        equip_button.name = "EquipmentEquip_%s" % slot_key
        equip_button.text = "Trang bị"
        equip_button.custom_minimum_size = Vector2(88,36)
        equip_button.add_theme_font_size_override("font_size",11)
        equip_button.add_theme_color_override("font_color",PAPER_LIGHT)
        equip_button.add_theme_stylebox_override("normal",_style(JADE_DARK,INK,1,6))
        equip_button.pressed.connect(Callable(self,"_equip_selected_disciple_item").bind(disciple.id,slot,picker))
        row.add_child(equip_button)

        var auto_button := Button.new()
        auto_button.name = "EquipmentAuto_%s" % slot_key
        auto_button.text = "Mở tự động" if locked else "Khóa ô"
        auto_button.custom_minimum_size = Vector2(86,36)
        auto_button.add_theme_font_size_override("font_size",10)
        auto_button.add_theme_color_override("font_color",INK)
        auto_button.add_theme_stylebox_override("normal",_style(Color(0.88,0.82,0.67),INK,1,6))
        auto_button.pressed.connect(Callable(self,"_toggle_disciple_equipment_slot").bind(disciple.id,slot,locked))
        row.add_child(auto_button)

        var remove_button := Button.new()
        remove_button.name = "EquipmentUnequip_%s" % slot_key
        remove_button.text = "Tháo"
        remove_button.disabled = equipped.is_empty()
        remove_button.custom_minimum_size = Vector2(58,36)
        remove_button.add_theme_font_size_override("font_size",10)
        remove_button.add_theme_color_override("font_color",INK)
        remove_button.add_theme_stylebox_override("normal",_style(Color(0.88,0.82,0.67),INK,1,6))
        remove_button.pressed.connect(Callable(self,"_unequip_disciple_item_to_storage").bind(disciple.id,slot))
        row.add_child(remove_button)

        var comparison := Label.new()
        comparison.name = "EquipmentPreview_%s" % slot_key
        comparison.custom_minimum_size = Vector2(manager.custom_minimum_size.x,46)
        comparison.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        comparison.add_theme_font_size_override("font_size",11)
        comparison.add_theme_color_override("font_color",INK)
        manager.add_child(comparison)
        if picker.item_count > 0:
            picker.item_selected.connect(Callable(self,"_update_disciple_equipment_action").bind(picker,equip_button,disciple.wallet))
            picker.item_selected.connect(Callable(self,"_update_disciple_equipment_preview").bind(picker,comparison,equipped))
            _update_disciple_equipment_action(picker.selected,picker,equip_button,disciple.wallet)
            _update_disciple_equipment_preview(picker.selected,picker,comparison,equipped)
    _ensure_disabled_controls_readable(manager)


func _update_disciple_equipment_preview(index: int, picker: OptionButton, comparison: Label, currently_equipped: Dictionary) -> void:
    var old_text := "Không có" if currently_equipped.is_empty() else _disciple_equipment_effect_text(currently_equipped).trim_prefix("Thuộc tính vật phẩm: ")
    var chosen: Dictionary = {}
    if index >= 0 and index < picker.item_count:
        chosen = state.sect.equipment_items.get(str(picker.get_item_metadata(index)), {})
    var new_text := "Chưa có vật phẩm" if chosen.is_empty() else _disciple_equipment_effect_text(chosen).trim_prefix("Thuộc tính vật phẩm: ")
    comparison.text = "Đang mặc: %s\nSẽ mặc: %s" % [old_text, new_text]
    comparison.tooltip_text = comparison.text


func _update_disciple_equipment_action(index: int, picker: OptionButton, action: Button, wallet: int) -> void:
    if index < 0 or index >= picker.item_count:
        action.disabled = true
        return
    var item_id := str(picker.get_item_metadata(index))
    var item: Dictionary = state.sect.equipment_items.get(item_id,{})
    if item.is_empty():
        action.text = "Trang bị"
        action.disabled = true
        return
    var location := StringName(item.get("location",""))
    if location == EquipmentSystem.LOCATION_SHOP:
        var price := int(item.get("price",0))
        action.text = "Mua & mặc"
        action.disabled = price <= 0 or wallet < price
        action.tooltip_text = "Mua với %d từ ví cá nhân %d; tiền chuyển vào ngân khố." % [price,wallet]
    elif location == EquipmentSystem.LOCATION_STORAGE:
        action.text = "Mặc"
        action.disabled = false
        action.tooltip_text = "Mặc vật phẩm đang ở Kho; không tiêu thêm tài nguyên."
    else:
        action.text = "Trang bị"
        action.disabled = true


func _equip_selected_disciple_item(disciple_id: StringName, slot: StringName, picker: OptionButton) -> void:
    if not state.sect.equipment_enabled or runtime_session == null or runtime_session.owner == null or runtime_session.owner.runtime_write_blocked:
        tab_status_text = "Runtime hoặc hệ trang bị chưa sẵn sàng; chưa thay đổi vật phẩm."
        _open_disciple_deep_screen(disciple_id,"Trang bị",true)
        return
    if picker.selected < 0 or picker.selected >= picker.item_count:
        tab_status_text = "Hãy chọn vật phẩm trước."
        _open_disciple_deep_screen(disciple_id,"Trang bị",true)
        return
    var item_id := StringName(str(picker.get_item_metadata(picker.selected)))
    var item: Dictionary = state.sect.equipment_items.get(str(item_id),{})
    if item.is_empty() or StringName(item.get("slot","")) != slot:
        tab_status_text = "Vật phẩm không còn khả dụng cho ô này."
        _open_disciple_deep_screen(disciple_id,"Trang bị",true)
        return
    var location := StringName(item.get("location",""))
    var changed := false
    var message := ""
    if location == EquipmentSystem.LOCATION_SHOP:
        var price := int(item.get("price",0))
        var disciple: DiscipleState = state.disciples[disciple_id]
        if disciple.wallet < price:
            message = "Ví cá nhân không đủ %d để mua vật phẩm." % price
        else:
            changed = equipment_system.purchase_and_equip(state,disciple,StringName(item_id))
            message = "Đã mua và mặc %s." % str(item.get("name",item_id)) if changed else "Giao dịch trang bị bị từ chối; không trừ tiền."
    elif location == EquipmentSystem.LOCATION_STORAGE:
        changed = equipment_system.manual_equip(state,disciple_id,StringName(item_id),true)
        message = "Đã mặc %s từ Kho và khóa ô." % str(item.get("name",item_id)) if changed else "Không thể mặc vật phẩm này."
    else:
        message = "Vật phẩm đã được đệ tử khác mặc."
    tab_status_text = message
    if changed:
        var saved: Dictionary = runtime_session.save()
        if not bool(saved.get("ok",false)):
            tab_status_text += " Cảnh báo: SaveService chưa xác nhận lưu."
    _open_disciple_deep_screen(disciple_id,"Trang bị",true)


func _toggle_disciple_equipment_slot(disciple_id: StringName, slot: StringName, locked: bool) -> void:
    if not state.sect.equipment_enabled or runtime_session == null or runtime_session.owner == null or runtime_session.owner.runtime_write_blocked:
        tab_status_text = "Runtime hoặc hệ trang bị chưa sẵn sàng; ô chưa đổi."
        _open_disciple_deep_screen(disciple_id,"Trang bị",true)
        return
    var changed := equipment_system.return_slot_to_auto(state,disciple_id,slot) if locked else equipment_system.set_slot_lock(state,disciple_id,slot,true)
    tab_status_text = "Ô đã trả về tự động." if changed and locked else ("Ô đã khóa." if changed else "Không thể đổi trạng thái ô.")
    if changed:
        var saved: Dictionary = runtime_session.save()
        if not bool(saved.get("ok",false)):
            tab_status_text += " Cảnh báo: SaveService chưa xác nhận lưu."
    _open_disciple_deep_screen(disciple_id,"Trang bị",true)


func _unequip_disciple_item_to_storage(disciple_id: StringName, slot: StringName) -> void:
    if not state.sect.equipment_enabled or runtime_session == null or runtime_session.owner == null or runtime_session.owner.runtime_write_blocked:
        tab_status_text = "Runtime hoặc hệ trang bị chưa sẵn sàng; vật phẩm chưa tháo."
        _open_disciple_deep_screen(disciple_id,"Trang bị",true)
        return
    var changed := equipment_system.unequip_to_storage(state,disciple_id,slot)
    tab_status_text = "Đã tháo vật phẩm và đưa về Kho." if changed else "Ô này hiện không có vật phẩm để tháo."
    if changed:
        var saved: Dictionary = runtime_session.save()
        if not bool(saved.get("ok",false)):
            tab_status_text += " Cảnh báo: SaveService chưa xác nhận lưu."
    _open_disciple_deep_screen(disciple_id,"Trang bị",true)


func _disciple_equipment_effect_text(item: Dictionary) -> String:
    var stats: Dictionary = item.get("stats",{})
    var lines: Array[String] = []
    var defense := float(stats.get("defense_reduction",0.0))
    if not is_zero_approx(defense):
        lines.append("Giảm sát thương %.1f%%" % (defense*100.0))
    var attack_speed := float(stats.get("basic_speed",0.0))
    if not is_zero_approx(attack_speed):
        lines.append("Tốc đánh %s%.1f%%" % ["+" if attack_speed >= 0.0 else "",attack_speed*100.0])
    var move_speed := float(stats.get("move_speed",0.0))
    if not is_zero_approx(move_speed):
        lines.append("Tốc chạy %s%.1f%%" % ["+" if move_speed >= 0.0 else "",move_speed*100.0])
    var range_bonus := float(stats.get("basic_range",0.0))
    if not is_zero_approx(range_bonus):
        lines.append("Tầm đánh %s%.2f" % ["+" if range_bonus >= 0.0 else "",range_bonus])
    var basic_ratio := float(stats.get("basic_ratio",0.0))
    if not is_zero_approx(basic_ratio):
        lines.append("Tỷ lệ đòn cơ bản %s%.1f%%" % ["+" if basic_ratio >= 0.0 else "",basic_ratio*100.0])
    var skill_effect := float(stats.get("skill_effect",0.0))
    if not is_zero_approx(skill_effect):
        lines.append("Kỹ năng khớp Đường/Hệ %s%.1f%%" % ["+" if skill_effect >= 0.0 else "",skill_effect*100.0])
    return "Thuộc tính vật phẩm: " + (" · ".join(lines) if not lines.is_empty() else "không có kênh Combat V2 tương thích.")


func _equipment_tab_text(disciple: DiscipleState) -> String:
    var snapshot := _disciple_snapshot(disciple)
    if not bool(snapshot.get("ok", false)):
        return "Không thể đọc dữ liệu Trang bị."
    var equipment: Dictionary = snapshot["equipment"]
    var by_slot: Dictionary = {}
    for raw_row in equipment.get("items", []):
        if raw_row is Dictionary:
            by_slot[str(raw_row.get("slot", ""))] = raw_row

    var lines: Array[String] = []
    for slot in EquipmentSystem.VALID_SLOTS:
        var slot_key := str(slot)
        var slot_name := _equipment_slot_name(slot)
        if not by_slot.has(slot_key):
            lines.append("• %s: Chưa trang bị" % slot_name)
            continue
        var row: Dictionary = by_slot[slot_key]
        var item: Dictionary = row.get("item", {})
        lines.append("• %s: %s · %s · %s" % [
            slot_name,
            str(item.get("name", row.get("item_id", "?"))),
            equipment_system.quality_name(StringName(item.get("quality", "pham"))),
            "Đã khóa" if bool(row.get("locked", false)) else "Tự động"
        ])
    var life: Dictionary = snapshot["life"]
    if bool(snapshot.get("authentic_v2", false)):
        return (
            "Trang bị hiện tại:\n%s\n\n"
            + "Combat V2 đọc các kênh tương thích của vật phẩm đã mặc; chỉ số chiến lực cũ không tự cộng thành ATK.\n"
            + "Ví cá nhân: %d\n%s"
        ) % ["\n".join(lines), int(life["wallet"]), tab_status_text]

    var equip_power := equipment_system.combat_power_bonus(state, disciple)
    var damage_reduction := (1.0 - equipment_system.incoming_damage_multiplier(state, disciple)) * 100.0
    return "Trang bị hiện tại:\n%s\n\nĐóng góp chiến lực: +%.1f\nGiảm sát thương từ trang bị: %.1f%%\nVí cá nhân: %d" % [
        "\n".join(lines), equip_power, damage_reduction, int(life["wallet"])
    ]


func _bloodline_tab_text(disciple: DiscipleState) -> String:
    var snapshot := _disciple_snapshot(disciple)
    if bool(snapshot.get("ok", false)) and bool(snapshot.get("authentic_v2", false)):
        var bloodline: Dictionary = snapshot["innate"]["bloodline"]
        match str(bloodline.get("status", "none")):
            "none":
                return "Huyết Mạch: Không có huyết mạch đặc biệt.\n\nHiệu ứng đặc thù: Không."
            "unrevealed":
                return "Huyết Mạch: Chưa xác định\n\nChưa đủ điều kiện để nhận biết huyết mạch của đệ tử này."
            "revealed":
                return (
                    "Huyết Mạch: %s\n"
                    + "Độ thuần hiện tại: %d%% · Lúc sinh: %d%%\n"
                    + "Trạng thái: %s\n\n"
                    + "Hiệu ứng đặc thù: Chưa khả dụng. Hồ sơ chỉ hiển thị identity đã được xác nhận."
                ) % [
                    str(bloodline.get("name", "?")),
                    int(bloodline.get("current_purity", 0)),
                    int(bloodline.get("birth_purity", 0)),
                    "Đã thức tỉnh" if bool(bloodline.get("awakened", false)) else "Chưa thức tỉnh"
                ]

    var profile := bloodlines.profile_for(state, disciple.id)
    if profile.is_empty():
        return "Chưa có hồ sơ Huyết Mạch."
    if not bool(profile.get("revealed", false)):
        return "Huyết Mạch: Chưa xác định\n\nChưa đủ điều kiện để nhận biết huyết mạch của đệ tử này."
    var id := StringName(profile.get("bloodline_id", "none"))
    var awakened := bool(profile.get("awakened", false))
    var stats := bloodlines.stat_profile(state, disciple)
    var status := "Đã thức tỉnh" if awakened else "Chưa thức tỉnh"
    return (
        "Huyết Mạch: %s\nĐộ thuần: %.1f%% · %s · Luyện huyết %d lần\n\n"
        + "Công +%.1f · Giảm sát thương %.1f%%\nTu luyện +%.1f%% · Đột phá +%.1f%% · Hồi phục +%.1f%%\n"
        + "Tiêu hao thêm khi xuất môn: %d\n\nYêu Đan trong tông: %d\n%s"
    ) % [
        bloodlines.bloodline_name(id), float(profile.get("purity", 0.0)) * 100.0, status, int(profile.get("refinement_count", 0)),
        float(stats.get("combat_power_bonus", 0.0)), float(stats.get("damage_reduction_pct", 0.0)),
        float(stats.get("cultivation_bonus_pct", 0.0)), float(stats.get("breakthrough_bonus_pct", 0.0)), float(stats.get("recovery_bonus_pct", 0.0)),
        int(stats.get("extra_departure_supply", 0)), _warehouse_quantity(&"yeu_dan", true), tab_status_text
    ]


func _physique_tab_text(disciple: DiscipleState) -> String:
    var snapshot := _disciple_snapshot(disciple)
    if bool(snapshot.get("ok", false)) and bool(snapshot.get("authentic_v2", false)):
        var physique: Dictionary = snapshot["innate"]["physique"]
        match str(physique.get("status", "none")):
            "none":
                return "Thể Chất: Không có thể chất đặc biệt.\n\nHiệu ứng đặc thù: Không."
            "unrevealed":
                return "Thể Chất: Chưa xác định\n\nThể chất đặc biệt chưa được nhận biết."
            "revealed":
                return (
                    "Thể Chất: %s\n\n"
                    + "Đây là Core Physique hiện được ghi nhận.\n"
                    + "Hiệu ứng đặc thù: Chưa khả dụng; không dùng cơ chế Tôi thể/Cải thể cũ để sửa hồ sơ này."
                ) % str(physique.get("name", "?"))

    var profile := physiques.profile_for(state, disciple.id)
    if profile.is_empty():
        return "Chưa có hồ sơ Thể Chất."
    var stats := physiques.stat_profile(state, disciple)
    var defense := (1.0 - float(stats.get("incoming_damage_multiplier", 1.0))) * 100.0
    var cultivate_pct := (float(stats.get("cultivation_multiplier", 1.0)) - 1.0) * 100.0
    var breakthrough_pct := float(stats.get("breakthrough_bonus", 0.0)) * 100.0
    var recovery_pct := (float(stats.get("recovery_multiplier", 1.0)) - 1.0) * 100.0
    return (
        "Thể Chất: %s\nTôi thể: %d/%d · Đã cải thể: %s\n\n"
        + "Công +%.1f · Giảm sát thương %.1f%%\nTu luyện %.1f%% · Đột phá %.1f%% · Hồi phục %.1f%%\n"
        + "Kiếm đạo XP x%.2f · Thể đạo XP x%.2f · Pháp đạo XP x%.2f\n\n"
        + "Yêu Đan: %d · Linh Tủy: %d\n%s"
    ) % [
        physiques.display_physique(state, disciple.id), int(profile.get("temper_level", 0)), PhysiqueSystem.MAX_TEMPER_LEVEL,
        "Có" if bool(profile.get("transformed", false)) else "Không",
        float(stats.get("attack_bonus", 0.0)), defense, cultivate_pct, breakthrough_pct, recovery_pct,
        float(stats.get("sword_xp_multiplier", 1.0)), float(stats.get("body_xp_multiplier", 1.0)), float(stats.get("spell_xp_multiplier", 1.0)),
        _warehouse_quantity(&"yeu_dan", true), _warehouse_quantity(&"linh_tuy", true), tab_status_text
    ]


func _relationship_tab_text(disciple: DiscipleState) -> String:
    var snapshot := _disciple_snapshot(disciple)
    if not bool(snapshot.get("ok", false)):
        return "Không thể đọc dữ liệu Quan hệ."
    var relation_data: Dictionary = snapshot["relationships"]
    var lines: Array[String] = []
    for raw_row in relation_data.get("rows", []):
        if not (raw_row is Dictionary):
            continue
        lines.append("• %s · Thân %.0f · Tin %.0f · Kính %.0f · Tương tác %d" % [
            str(raw_row.get("target_name", "?")),
            float(raw_row.get("affinity", 0.0)),
            float(raw_row.get("trust", 0.0)),
            float(raw_row.get("respect", 0.0)),
            int(raw_row.get("interactions", 0))
        ])
    if lines.is_empty():
        lines.append("• Chưa có quan hệ đáng kể được lưu")
    var companion := str(relation_data.get("companion_name", ""))
    if companion.is_empty():
        companion = "Chưa phân"
    return "Đồng hành ưu tiên: %s\n\n%s\n\nQuan hệ thay đổi theo những lần đồng hành, chiến đấu và sinh hoạt cùng nhau." % [
        companion, "\n".join(lines)
    ]

func _equipment_slot_name(slot: StringName) -> String:
    match slot:
        EquipmentSystem.SLOT_WEAPON: return "Vũ khí"
        EquipmentSystem.SLOT_ARMOR: return "Giáp"
        EquipmentSystem.SLOT_TALISMAN: return "Phụ kiện"
        _: return str(slot)
