extends Control
## B1 view-model/callback bridge: one visible facility surface delegates all mutations to canonical UI/actions.
## The host stays hidden while this adapter is open and supplies state, portraits and callback authority only.

const HALL_B1 = preload("res://src/presentation/uiux/dai_dien_screen_b1_v1.gd")
const HOUSE_B1 = preload("res://src/presentation/uiux/de_tu_xa_screen_b1_v1.gd")
const GUIDANCE_B1 = preload("res://src/presentation/uiux/dan_tien_screen_b1_v1.gd")
const UI = preload("res://src/presentation/uiux/sect_ui_theme_v1.gd")

# Presentation-only labels for canonical IDs. Unknown IDs remain visible as
# readable raw values; never mutate the simulation state or candidate identity.
const UI_ORIGIN_NAMES := {
    "commoner":"Bình dân", "merchant_family":"Thương gia",
    "martial_family":"Võ gia", "wanderer":"Lãng khách",
    "mountain_village":"Sơn thôn", "minor_clan":"Tiểu thế gia"
}
const UI_RACE_NAMES := {"human":"Nhân tộc"}
const UI_SOURCE_NAMES := {
    "ordinary":"Tiếp dẫn thường", "gacha":"Chiêu Mộ Lệnh", "fate":"Cơ Duyên"
}
const UI_ROOT_NAMES := {
    "mixed":"Tạp Linh Căn", "ordinary":"Phàm Linh Căn",
    "earth":"Địa Linh Căn", "heaven":"Thiên Linh Căn"
}
const UI_PROFESSION_NAMES := {
    "forge_talent":"Thiên phú Luyện Khí", "miner_instinct":"Trực giác khai mỏ",
    "diligent":"Cần mẫn", "lazy":"Lười biếng"
}


var _host: Control
var _state: SimulationState
var _recruitment: RecruitmentSystem
var _mode := "hall"
var _selected_site_id := ""
var _feedback := ""
var _active_view: Control
var _office_picker_role := ""
var _last_recruited_disciple_id := ""
var _vis_revealed_once: Dictionary = {}

func configure(host: Control, state: SimulationState, recruitment: RecruitmentSystem, mode: String) -> void:
    _host = host
    _state = state
    _recruitment = recruitment
    _mode = mode

func _ready() -> void:
    name = "TriFacilityB1LiveAdapterV1"
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    _render()

func show_mode(mode: String) -> void:
    _mode = mode
    _render()

func _render() -> void:
    if _host == null or _state == null or not is_inside_tree():
        return
    for child in get_children():
        remove_child(child)
        child.queue_free()
    _active_view = null
    var view: Control
    match _mode:
        "hall":
            view = HALL_B1.new()
            view.connect("office_selection_requested", Callable(self, "_open_office"))
            view.connect("promotion_requested", Callable(self, "_promote_hall"))
            view.connect("hall_upgrade_requested", Callable(self, "_upgrade_hall"))
            view.connect("office_dismissal_requested", Callable(self, "_dismiss_office"))
            view.connect("closed", Callable(self, "_close_host"))
        "residence":
            view = HOUSE_B1.new()
            view.connect("site_selection_requested", Callable(self, "_select_site"))
            view.connect("residence_build_requested", Callable(self, "_build_house"))
            view.connect("residence_upgrade_requested", Callable(self, "_upgrade_house"))
            view.connect("room_management_requested", Callable(self, "_open_map_residence_plan"))
            view.connect("room_assignment_requested", Callable(self, "_assign_room"))
            view.connect("closed", Callable(self, "_close_host"))
        "guidance":
            view = GUIDANCE_B1.new()
            view.connect("candidate_page_requested", Callable(self, "_page_candidate"))
            view.connect("candidate_search_requested", Callable(self, "_search_candidate"))
            view.connect("accept_candidate_requested", Callable(self, "_accept_candidate"))
            view.connect("reject_candidate_requested", Callable(self, "_reject_candidate"))
            view.connect("guidance_main_requested", Callable(self, "_assign_guidance_main"))
            view.connect("guidance_assistants_requested", Callable(self, "_assign_guidance_assistants"))
            view.connect("residence_capacity_requested", Callable(self, "_open_residence_capacity"))
            view.connect("recruited_profile_requested", Callable(self, "_open_recruited_profile"))
            view.connect("recruited_assignment_requested", Callable(self, "_open_recruited_assignment"))
            view.connect("recruited_world_requested", Callable(self, "_open_recruited_world"))
            view.connect("recruitment_order_requested", Callable(self, "_recruit_order"))
            view.connect("closed", Callable(self, "_close_host"))
        _:
            return
    view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(view)
    _active_view = view
    var model: Dictionary = {}
    match _mode:
        "hall":
            model = _hall_model()
        "residence":
            model = _house_model()
        "guidance":
            model = _guidance_model()
    view.call("bind_view_model", model)
    if _mode == "hall" and not _office_picker_role.is_empty():
        add_child(_build_office_picker())

func _hall_model() -> Dictionary:
    var hall: BuildingState = SectHallSystemV1.hall(_state)
    if hall == null:
        return {}
    var offices: Array[Dictionary] = []
    for role_id in SectHallSystemV1.OFFICES:
        var holder_id := SectHallSystemV1.holder_id(_state, role_id)
        var name_value := "Chưa bổ nhiệm"
        var mastery_value := "Ghế đang trống"
        if not holder_id.is_empty() and _state.disciples.has(StringName(holder_id)):
            var actor: DiscipleState = _state.disciples[StringName(holder_id)]
            name_value = actor.display_name
            if _host != null and _host.has_method("_source_a_portrait"):
                var portrait_control: Variant = _host.call("_source_a_portrait",actor)
                if portrait_control is Control:
                    var portrait_texture := _source_a_texture_from_control(portrait_control as Control,"HallSourceAPortrait")
                    if portrait_texture != null:
                        offices.append({
                            "id":role_id, "role_label":SectHallSystemV1.label(role_id),
                            "disciple_name":name_value,
                            "office_rank":"Tinh Thông Lv%d/10" % int(SectHallSystemV1.mastery(_state,role_id,holder_id).get("level",1)),
                            "portrait":portrait_texture, "can_dismiss":true
                        })
                    portrait_control.free()
            var record: Dictionary = SectHallSystemV1.mastery(_state, role_id, holder_id)
            mastery_value = "Tinh Thông Lv%d/10" % int(record.get("level", 1))
        var has_office_row := false
        for office_row in offices:
            if str(office_row.get("id","")) == role_id:
                has_office_row = true
                break
        if not has_office_row:
            offices.append({
                "id":role_id, "role_label":SectHallSystemV1.label(role_id),
                "disciple_name":name_value, "office_rank":mastery_value,
                "can_dismiss":not holder_id.is_empty()
            })
    var rank_check: Dictionary = SectHallSystemV1.promotion_requirements(_state)
    var rank := SectHallSystemV1.rank_index(_state)
    var blockers: Array = rank_check.get("blockers", [])
    var blocker_names := {
        "hall_level":"Cấp Đại Điện", "disciple_roster":"Số đệ tử",
        "disciple_realm":"Cảnh giới đệ tử", "real_production":"Sản xuất thực tế",
        "prestige":"Uy danh", "spirit_stones":"Linh Thạch"
    }
    var equipment := EquipmentSystem.new()
    var readable_blockers := PackedStringArray()
    for raw_blocker in blockers:
        var blocker := str(raw_blocker)
        readable_blockers.append(str(blocker_names.get(blocker, equipment.material_name(StringName(blocker)))))
    var requirement := "Đã đạt tối đa" if rank >= 27 else "Bậc %d → %d · %s" % [
        rank, rank + 1, str(rank_check.get("next_name", ""))
    ]
    if not readable_blockers.is_empty():
        requirement += " · Thiếu: " + ", ".join(readable_blockers)
    elif rank < 27:
        requirement += " · Đủ điều kiện"
    var costs: Array[Dictionary] = []
    var raw_cost: Dictionary = BuildingSystem.new().upgrade_cost(hall)
    var keys: Array = raw_cost.keys()
    keys.sort()
    for raw_key in keys:
        var key := str(raw_key)
        var material_name := "Linh Thạch" if key == "spirit_stones" else equipment.material_name(StringName(key))
        costs.append({
            "name":material_name, "amount":str(int(raw_cost[raw_key])),
            "icon":"gold" if key == "spirit_stones" else ("leaf" if key == str(BuildingSystem.MATERIAL_WOOD) else "resource")
        })
    var upgrade: Dictionary = BuildingSystem.new().can_start_upgrade(_state, hall.id)
    return {
        "building_level":hall.level, "rank_step":rank,
        "rank_progress":float(rank) / 27.0,
        "rank_requirement":requirement,
        "can_promote":bool(rank_check.get("ok", false)),
        "can_upgrade":bool(upgrade.get("ok", false)),
        "upgrade_costs":costs, "offices":offices, "feedback":_feedback
    }

func _house_model() -> Dictionary:
    var houses: Array = SectResidenceSystemV1.all_houses(_state)
    var sites: Array[Dictionary] = []
    var assignments: Dictionary = _state.sect.hall_governance.get("residence_assignments", {})
    var selected_house: BuildingState = null
    var buildings := BuildingSystem.new()
    var bed_slots: Array[Dictionary] = []
    var house_options: Array[Dictionary] = []
    var room_house_options: Array[Dictionary] = []
    var assigned_resident_ids: Dictionary = {}
    var house_display_number := 0
    for house in houses:
        if not (house is BuildingState):
            continue
        house_display_number += 1
        if selected_house == null:
            selected_house = house
        var residents: Array[String] = []
        for raw_disciple_id in assignments:
            if str(assignments[raw_disciple_id]) == str(house.id):
                var disciple_id := StringName(str(raw_disciple_id))
                if _state.disciples.has(disciple_id):
                    residents.append(str(disciple_id))
        residents.sort()
        for resident_id in residents:
            assigned_resident_ids[resident_id] = true
        var capacity := 0 if house.status == BuildingSystem.STATUS_CONSTRUCTING else SectResidenceSystemV1.beds_for_level(house.level)
        var upgrade_check: Dictionary = buildings.can_start_upgrade(_state, house.id)
        sites.append({
            "id":str(house.id), "name":"Đệ Tử Xá %02d" % house_display_number,
            "status":"Đang xây" if house.status == BuildingSystem.STATUS_CONSTRUCTING else "Lv%d" % house.level,
            "resident_summary":"%d/%d giường" % [residents.size(), capacity],
            "built":true, "can_build":false, "can_upgrade":bool(upgrade_check.get("ok", false))
        })
        var house_option_state := "Lv%d" % house.level
        if house.status == BuildingSystem.STATUS_CONSTRUCTING:
            house_option_state = "Đang xây · còn %d nhịp" % SectResidenceSystemV1.construction_remaining_ticks(_state,house)
        elif house.status == BuildingSystem.STATUS_UPGRADING:
            house_option_state = "Đang nâng · Lv%d→%d" % [house.level,house.upgrade_target_level]
        house_options.append({
            "id":str(house.id), "name":"Đệ Tử Xá %02d · %s" % [house_display_number,house_option_state],
            "ready":house.status in [BuildingSystem.STATUS_ACTIVE,BuildingSystem.STATUS_UPGRADING]
        })
        if house.status in [BuildingSystem.STATUS_ACTIVE,BuildingSystem.STATUS_UPGRADING]:
            room_house_options.append({
                "id":str(house.id), "name":"Đệ Tử Xá %02d · %d/%d giường" % [house_display_number,residents.size(),SectResidenceSystemV1.beds_for_level(house.level)],
                "occupied":residents.size(), "capacity":SectResidenceSystemV1.beds_for_level(house.level)
            })
        for bed_index in range(capacity):
            var disciple_id := StringName(residents[bed_index]) if bed_index < residents.size() else &""
            var occupied := disciple_id != &""
            var display := str(_state.disciples[disciple_id].display_name) if occupied else "Trống"
            bed_slots.append({
                "id":"%s:%d" % [str(house.id), bed_index + 1],
                "occupied":occupied, "disciple_short_name":display
            })
    var all_sites: Array[String] = []
    for site in sites:
        all_sites.append(str(site.get("id", "")))
    if _selected_site_id.is_empty() or not all_sites.has(_selected_site_id):
        _selected_site_id = str(sites[0].get("id", "")) if not sites.is_empty() else ""
    for house in houses:
        if str(house.id) == _selected_site_id:
            selected_house = house
            break
    var raw_build_cost: Dictionary = SectResidenceSystemV1.build_cost(_state)
    var equipment := EquipmentSystem.new()
    var build_costs: Array[Dictionary] = []
    var cost_keys: Array = raw_build_cost.keys()
    cost_keys.sort()
    for raw_key in cost_keys:
        var key := str(raw_key)
        var material_name := "Linh Thạch" if key == "spirit_stones" else equipment.material_name(StringName(key))
        build_costs.append({
            "name":material_name, "amount":str(int(raw_build_cost[raw_key])),
            "icon":"gold" if key == "spirit_stones" else ("leaf" if key == str(BuildingSystem.MATERIAL_WOOD) else "resource")
        })
    var disciple_ids: Array = _state.disciples.keys()
    disciple_ids.sort()
    var room_disciple_options: Array[Dictionary] = []
    var default_disciple_id := ""
    for raw_id in disciple_ids:
        var disciple: DiscipleState = _state.disciples[StringName(str(raw_id))]
        var assigned_to := str(assignments.get(str(raw_id),""))
        if default_disciple_id.is_empty() and assigned_to.is_empty():
            default_disciple_id = str(raw_id)
        room_disciple_options.append({
            "id":str(raw_id), "name":disciple.display_name,
            "house_id":assigned_to
        })
    if default_disciple_id.is_empty() and not disciple_ids.is_empty():
        default_disciple_id = str(disciple_ids[0])
    var selected_room_house_id := str(room_house_options[0].get("id","")) if not room_house_options.is_empty() else ""
    var current_house_id := str(assignments.get(default_disciple_id,""))
    if not current_house_id.is_empty():
        selected_room_house_id = current_house_id
    var can_assign_room := false
    var selected_room_name := ""
    var selected_room_occupied := 0
    var selected_room_capacity := 0
    for house_option in room_house_options:
        if str(house_option.get("id","")) == selected_room_house_id:
            selected_room_name = str(house_option.get("name",""))
            selected_room_occupied = int(house_option.get("occupied",0))
            selected_room_capacity = int(house_option.get("capacity",0))
            can_assign_room = selected_room_occupied < selected_room_capacity or current_house_id == selected_room_house_id
            break
    var valid_plot := SectResidenceSiteV1.UNSELECTED
    var build_gate: Dictionary = {"ok":false,"reason":"no_free_house_plot"}
    for point in SectResidenceSiteV1.available_plots(_state):
        var candidate_plot: Dictionary = SectResidenceSystemV1.can_construct(_state,point)
        if bool(candidate_plot.get("ok",false)):
            valid_plot = point
            build_gate = candidate_plot
            break
        if build_gate.get("reason","") == "no_free_house_plot":
            build_gate = candidate_plot
    var hall := SectHallSystemV1.hall(_state)
    var next_hall_level := houses.size() * 10 + 1
    var next_house_upgrade := buildings.can_start_upgrade(_state,selected_house.id) if selected_house != null else {"ok":false,"reason":"missing_building"}
    var next_house_upgrade_cost := buildings.upgrade_cost(selected_house) if selected_house != null else {}
    var upgrade_costs: Array[Dictionary] = []
    var upgrade_keys: Array = next_house_upgrade_cost.keys()
    upgrade_keys.sort()
    for raw_key in upgrade_keys:
        var key := str(raw_key)
        upgrade_costs.append({
            "name":"Linh Thạch" if key == "spirit_stones" else equipment.material_name(StringName(key)),
            "amount":str(int(next_house_upgrade_cost[raw_key])),
            "icon":"gold" if key == "spirit_stones" else ("leaf" if key == str(BuildingSystem.MATERIAL_WOOD) else "resource")
        })
    return {
        "building_level":selected_house.level if selected_house != null else 1,
        "room_count_label":"%d căn · %d giường" % [houses.size(), SectResidenceSystemV1.total_beds(_state)],
        "residence_type_summary":"1 loại công trình · tối đa %d căn; mỗi căn nâng cấp riêng." % SectResidenceSystemV1.maximum_instances(_state),
        "room_assignment_summary":"%d đệ tử đã xếp giường · %d chưa xếp phòng" % [
            assigned_resident_ids.size(),maxi(_state.disciples.size()-assigned_resident_ids.size(),0)
        ],
        "selected_residence_id":_selected_site_id,
        "bed_slots":bed_slots, "sites":sites, "house_options":house_options,
        "room_disciple_options":room_disciple_options, "room_house_options":room_house_options,
        "room_assignment_disciple_id":default_disciple_id, "room_assignment_house_id":selected_room_house_id,
        "room_assignment_status":"%s đang ở %s." % [
            str(_state.disciples[StringName(default_disciple_id)].display_name) if not default_disciple_id.is_empty() else "Chưa có đệ tử",
            selected_room_name if not current_house_id.is_empty() else "chưa có phòng"
        ],
        "can_assign_room":can_assign_room,
        "can_build_next":valid_plot != SectResidenceSiteV1.UNSELECTED,
        "build_gate_reason":str(build_gate.get("reason","")),
        "next_house_number":houses.size()+1, "next_house_hall_level":next_hall_level,
        "hall_level":hall.level if hall != null else 0,
        "next_house_costs":build_costs,
        "construction_ticks":SectResidenceSystemV1.construction_duration_ticks(houses.size()+1),
        "can_upgrade_selected":bool(next_house_upgrade.get("ok",false)),
        "upgrade_gate_reason":str(next_house_upgrade.get("reason","")),
        "upgrade_costs":upgrade_costs,
        "build_costs":build_costs,
        "feedback":_feedback
    }

func _guidance_model() -> Dictionary:
    var ids: Array = _state.recruitment_candidates.keys()
    ids.sort()
    var rows: Array[Dictionary] = []
    var quality_names: Dictionary = DiscipleGeneratorV2.QUALITY_NAMES
    var can_roster_accept := _recruitment.can_accept_more(_state)
    for raw_id in ids:
        var candidate: CandidateState = _state.recruitment_candidates.get(StringName(str(raw_id)))
        if candidate == null:
            continue
        var valid_birth := not _state.sect.disciple_v2_birth_enabled or DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile)
        var quality := str(quality_names.get(str(candidate.disciple_quality), str(candidate.disciple_quality)))
        var preview_texture: Texture2D = null
        var portrait_verified := false
        if _host != null and _host.has_method("_source_a_preview"):
            var preview_value: Variant = _host.call("_source_a_preview",candidate)
            if preview_value is Control:
                var preview_control := preview_value as Control
                preview_texture = _source_a_texture_from_control(preview_control,"CandidateSourceAPortrait")
                var preview_disciple: DiscipleState = candidate.to_disciple()
                var approved_scene_path := DiscipleSourceAVisualPool.scene_path_for_disciple(preview_disciple)
                portrait_verified = preview_texture != null and not approved_scene_path.is_empty()
                preview_control.free()
        var source := _ui_name(str(candidate.recruitment_source), UI_SOURCE_NAMES) if not str(candidate.recruitment_source).is_empty() else "Nguồn chưa xác định"
        var profession := _ui_profession_traits(candidate.profession_traits)
        var base_disciple: DiscipleState = candidate.to_disciple()
        var role_fit := _best_role_fit(base_disciple)
        rows.append({
            "id":str(candidate.id), "name":candidate.display_name,
            "quality":quality,
            "realm":"Phàm Nhân · Phàm Thân tầng 1",
            "origin":_ui_name(str(candidate.origin_id), UI_ORIGIN_NAMES) if not str(candidate.origin_id).is_empty() else "Xuất thân chưa ghi",
            "personality":"%s · %s · %d tuổi / thọ %d" % [_ui_name(str(candidate.race_id), UI_RACE_NAMES) if not str(candidate.race_id).is_empty() else "Chưa rõ chủng tộc", "Nữ" if str(candidate.sex_id) == "female" else "Nam",candidate.age,candidate.max_lifespan],
            "status":"%s · Hồ sơ sinh %s" % [source, "hợp lệ" if valid_birth else "chưa hợp lệ"],
            "foundation_model_version":candidate.foundation_model_version,
            "tam_values":[candidate.aptitude, candidate.constitution, candidate.mind_nature],
            "tu_values":[candidate.potential, candidate.comprehension, candidate.fortune, candidate.charisma],
            "tam_summary":"Tư Chất %.0f · Căn Cốt %.0f · Tâm Tính %.0f" % [candidate.aptitude,candidate.constitution,candidate.mind_nature],
            "tu_summary":"Tiềm Lực %.0f · Thông Tuệ %.0f · Cơ Duyên %.0f · Mị Lực %.0f" % [candidate.potential,candidate.comprehension,candidate.fortune,candidate.charisma],
            "tam_note":"Tâm Tính được tính trong tổng phẩm chất D7; hiện chưa có hiệu ứng gameplay riêng." if candidate.foundation_model_version >= FoundationSystem.MODEL_D7 else "",
            "root_values":_candidate_root_values(candidate),
            "special_identity":_candidate_disclosed_identity(candidate),
            "role_fit":role_fit,
            "portrait":preview_texture,
            "portrait_verified":portrait_verified,
            "metrics":[
                {"label":"PHẨM","value":quality,"icon":"rank"},
                {"label":"TUỔI","value":str(candidate.age),"icon":"person"},
				{"label":"LINH CĂN","value":_ui_name(str(candidate.spiritual_root_quality), UI_ROOT_NAMES),"icon":"root"},
				{"label":"NGHỀ","value":profession,"icon":"profession"}
            ],
            "can_accept":can_roster_accept and valid_birth and available_if_guidance_enabled(),
            "accept_reason":"" if can_roster_accept and valid_birth else ("Chỗ ở đã đủ; hãy mở rộng Đệ Tử Xá." if not can_roster_accept else "Hồ sơ sinh chưa hợp lệ; không thể nhận."),
            "can_reject":true, "source_art_approved":portrait_verified
        })
    var platform: BuildingState = BuildingSystem.new().primary_building(_state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
    var available := _state.p1_recruitment_enabled and _state.sect.disciple_generation_v2_enabled \
        and _state.sect.guidance_recruitment_enabled and _state.p3_7_buildings_enabled and platform != null
    var token_count: int = _state.sect.disciple_recruitment_tokens
    var capacity := SectResidenceSystemV1.current_limit(_state) if SectHallSystemV1.installed(_state) else _state.sect.disciple_capacity
    var beds := SectResidenceSystemV1.total_beds(_state) if SectHallSystemV1.installed(_state) else capacity
    var population_free := maxi(0,capacity-_state.disciples.size())
    var housing_free := maxi(0,beds-_state.disciples.size())
    var houses := SectResidenceSystemV1.all_houses(_state) if SectHallSystemV1.installed(_state) else []
    var starter: BuildingState = houses[0] if not houses.is_empty() else null
    var upgrade_check: Dictionary = BuildingSystem.new().can_start_upgrade(_state,starter.id) if starter != null else {"ok":false,"reason":"missing_building"}
    var upgrade_cost: Dictionary = BuildingSystem.new().upgrade_cost(starter) if starter != null else {}
    var buildings := BuildingSystem.new()
    var platform_data: Dictionary = platform.production_state if platform != null else {}
    var main_guide := str(platform_data.get("main_guide_id",""))
    var assistants: Array = platform_data.get("assistant_guide_ids",[])
    var guide_options: Array[Dictionary] = []
    var disciple_ids: Array = _state.disciples.keys()
    disciple_ids.sort()
    for raw_disciple_id in disciple_ids:
        var disciple_id := StringName(str(raw_disciple_id))
        var disciple: DiscipleState = _state.disciples[disciple_id]
        var eligible := _recruitment.guidance_guide_eligible(_state,disciple_id)
        guide_options.append({"id":str(disciple_id),"name":disciple.display_name,"eligible":eligible})
    var guide_slots: int = buildings.guidance_elder_slots(platform) if platform != null else 0
    var recruited := _recruited_disciple_model()
    var reveal_id := str(recruited.get("id", ""))
    var reveal_once := not reveal_id.is_empty() and not _vis_revealed_once.has(reveal_id)
    if reveal_once:
        _vis_revealed_once[reveal_id] = true
    return {
        "candidates":rows,
        "selected_candidate_id":str(_host.get("selected_candidate_id")),
        "can_accept":can_roster_accept,
        "accept_gate":"Còn %d chỗ theo giới hạn Tông Môn; %d/%d giường đang dùng." % [population_free,_state.disciples.size(),beds],
        "capacity_full":population_free <= 0 or housing_free <= 0,
        "capacity_text":"Đệ Tử %d/%d · Giường %d/%d · Còn nhận %d" % [_state.disciples.size(),capacity,_state.disciples.size(),beds,mini(population_free,housing_free)],
        "capacity_upgrade_available":bool(upgrade_check.get("ok",false)),
        "capacity_upgrade_costs":_cost_rows(upgrade_cost),
        "guidance_enabled":available,
        "can_reject":not rows.is_empty(),
        "can_use_order":available and token_count > 0 and ids.size() < RecruitmentSystem.C2_QUEUE_CAP,
        "recruitment_tokens":token_count,
        "candidate_count":ids.size(),
        "guidance_main_id":main_guide,
        "guidance_assistant_ids":assistants.duplicate(),
        "guidance_options":guide_options,
        "guidance_slots":guide_slots,
        "guidance_max_assistants":maxi(guide_slots-1,0),
        "can_assign_guidance":available,
        "capacity_upgrade_reason":str(upgrade_check.get("reason","")),
        "recruited_disciple":recruited,
        "vis_reveal_once":reveal_once,
        "feedback":_feedback
    }

func available_if_guidance_enabled() -> bool:
    return _state.p1_recruitment_enabled and _state.sect.disciple_generation_v2_enabled \
        and _state.sect.guidance_recruitment_enabled and _state.p3_7_buildings_enabled

func _source_a_texture_from_control(node: Node, texture_node_name: String) -> Texture2D:
    if node is TextureRect and node.name == texture_node_name:
        return (node as TextureRect).texture
    for child in node.get_children():
        var texture := _source_a_texture_from_control(child,texture_node_name)
        if texture != null:
            return texture
    return null

func _candidate_root_values(candidate: CandidateState) -> String:
    var layers: Dictionary = candidate.v2_birth_profile.get("layers",{})
    var root: Dictionary = layers.get("spiritual_root",{})
    var values: Dictionary = root.get("current_values",{})
    if values.is_empty():
        return "Linh Căn: " + _ui_name(str(candidate.spiritual_root_quality),UI_ROOT_NAMES)
    var labels := {"metal":"Kim","wood":"Mộc","water":"Thủy","fire":"Hỏa","earth":"Thổ"}
    var keys: Array = values.keys()
    keys.sort()
    var parts := PackedStringArray()
    for key in keys:
        parts.append("%s %d" % [str(labels.get(str(key),"Ngũ Hành")),int(values[key])])
    return "Linh Căn · " + " / ".join(parts)

func _candidate_disclosed_identity(candidate: CandidateState) -> String:
    var layers: Dictionary = candidate.v2_birth_profile.get("layers",{})
    var titles := {"root_mutation":"Dị Linh Căn","bloodline":"Huyết Mạch","physique":"Thể Chất","destiny":"Mệnh Cách"}
    var disclosed := PackedStringArray()
    for key in titles:
        var layer: Dictionary = layers.get(key,{})
        if bool(layer.get("revealed",false)):
            disclosed.append(str(titles[key]))
    return "Đã khai mở: " + " · ".join(disclosed) if not disclosed.is_empty() else "Các tầng ẩn chưa được khai mở"

func _best_role_fit(disciple: DiscipleState) -> String:
    if disciple == null:
        return "Chưa đủ dữ liệu"
    var best_role := ""
    var best_score := -1.0
    for role_id in SectHallSystemV1.OFFICES:
        var score := SectHallSystemV1.affinity_score(disciple,str(role_id))
        if score > best_score:
            best_score = score
            best_role = str(role_id)
    return "Tương hợp cao nhất theo chỉ số gốc: %s · %.1f" % [SectHallSystemV1.label(best_role),best_score]

func _recruited_disciple_model() -> Dictionary:
    if _last_recruited_disciple_id.is_empty():
        return {}
    var disciple: DiscipleState = _state.disciples.get(StringName(_last_recruited_disciple_id))
    if disciple == null:
        return {}
    var texture: Texture2D = null
    var world := _host.get_parent() if _host != null else null
    if world != null and world.has_method("_disciple_source_a_portrait_texture"):
        var preview: Variant = world.call("_disciple_source_a_portrait_texture",disciple)
        if preview is Texture2D:
            texture = preview as Texture2D
    return {
        "id":str(disciple.id), "name":disciple.display_name,
        "quality":str(DiscipleGeneratorV2.QUALITY_NAMES.get(str(disciple.disciple_quality),str(disciple.disciple_quality))),
        "sex":"Nữ" if str(disciple.sex_id) == "female" else "Nam",
        "age":disciple.age,
        "root":_ui_name(str(disciple.spiritual_root_quality),UI_ROOT_NAMES),
        "profession":_ui_profession_traits(disciple.profession_traits),
        "stats":"Tư %.0f · Cốt %.0f · Duyên %.0f · Tuệ %.0f · Mị %.0f · Tiềm %.0f" % [disciple.aptitude,disciple.constitution,disciple.fortune,disciple.comprehension,disciple.charisma,disciple.potential],
        "portrait":texture
    }

func _cost_rows(cost: Dictionary) -> Array[Dictionary]:
    var equipment := EquipmentSystem.new()
    var result: Array[Dictionary] = []
    var keys: Array = cost.keys()
    keys.sort()
    for raw_key in keys:
        var key := str(raw_key)
        result.append({
            "name":"Linh Thạch" if key == "spirit_stones" else equipment.material_name(StringName(key)),
            "amount":str(int(cost[raw_key])),
            "icon":"gold" if key == "spirit_stones" else ("leaf" if key == str(BuildingSystem.MATERIAL_WOOD) else "resource")
        })
    return result

func _ui_name(raw: String, catalog: Dictionary) -> String:
    if raw.is_empty():
        return "Chưa ghi"
    return str(catalog.get(raw, "Chưa có tên hiển thị"))

func _ui_profession_traits(traits: Array) -> String:
    if traits.is_empty():
        return "Chưa xác định"
    var names: PackedStringArray = []
    for trait_id in traits:
        names.append(str(UI_PROFESSION_NAMES.get(str(trait_id),"Thiên phú khác")))
    return " · ".join(names)

func _host_feedback() -> String:
    if _host == null:
        return ""
    var value: Variant = _host.get("feedback")
    return "" if value == null else str(value)

func _close_host() -> void:
    if _mode == "guidance":
        _host.call("_close_screen")
    else:
        _host.call("_close")

func _open_office(role_id: String) -> void:
    if not SectHallSystemV1.OFFICES.has(role_id):
        return
    _office_picker_role = role_id
    _render()

func _build_office_picker() -> Control:
    var shade := ColorRect.new()
    shade.name = "HallAppointmentPickerShade"
    shade.color = Color(0.015,0.035,0.04,0.82)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.mouse_filter = Control.MOUSE_FILTER_STOP
    var panel := PanelContainer.new()
    panel.name = "HallAppointmentPicker"
    panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    panel.offset_left = -300
    panel.offset_right = 300
    panel.offset_top = -270
    panel.offset_bottom = 270
    var style := StyleBoxFlat.new()
    style.bg_color = UI.SURFACE
    style.border_color = UI.GOLD
    style.set_border_width_all(2)
    style.set_corner_radius_all(12)
    style.content_margin_left = 16
    style.content_margin_right = 16
    style.content_margin_top = 14
    style.content_margin_bottom = 14
    panel.add_theme_stylebox_override("panel",style)
    shade.add_child(panel)
    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation",8)
    panel.add_child(content)
    var header := HBoxContainer.new()
    var title := UI.label("BỔ NHIỆM · %s" % SectHallSystemV1.label(_office_picker_role),18,UI.PAPER,true)
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)
    var close := UI.button("ĐÓNG",false,UI.GOLD)
    close.pressed.connect(_close_office_picker)
    header.add_child(close)
    content.add_child(header)
    content.add_child(UI.label("Chỉ đệ tử khỏe, đang rảnh và chưa giữ chức khác được bổ nhiệm.",12,UI.MUTED,false))
    var list := VBoxContainer.new()
    list.name = "HallAppointmentCandidates"
    list.add_theme_constant_override("separation",6)
    var ids: Array = _state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple_id := StringName(str(raw_id))
        var disciple: DiscipleState = _state.disciples[disciple_id]
        var check: Dictionary = SectHallSystemV1.can_appoint(_state,_office_picker_role,disciple_id)
        var row := HBoxContainer.new()
        row.add_theme_constant_override("separation",8)
        var name_label := UI.label(disciple.display_name,14,UI.TEXT,true)
        name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(name_label)
        var state_label := UI.label("Đủ điều kiện" if bool(check.get("ok",false)) else _office_blocker_text(str(check.get("reason",""))),11,UI.JADE if bool(check.get("ok",false)) else UI.MUTED,false)
        state_label.custom_minimum_size.x = 150
        row.add_child(state_label)
        var appoint := UI.button("BỔ NHIỆM",false,UI.JADE)
        appoint.disabled = not bool(check.get("ok",false))
        appoint.pressed.connect(_appoint_office.bind(_office_picker_role,disciple_id))
        row.add_child(appoint)
        list.add_child(row)
    if ids.is_empty():
        list.add_child(UI.label("Chưa có đệ tử để bổ nhiệm.",13,UI.MUTED,false))
    var scroll := ScrollContainer.new()
    scroll.name = "HallAppointmentCandidateScroll"
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.add_child(list)
    content.add_child(scroll)
    return shade

func _office_blocker_text(reason: String) -> String:
    match reason:
        "office_requires_hall_level": return "Cần nâng Đại Điện"
        "disciple_injured": return "Đệ tử đang bị thương"
        "already_owns_other_office": return "Đang giữ chức khác"
        "guide_busy_or_injured": return "Đang bận / bị thương"
        "disciple_missing": return "Không tìm thấy đệ tử"
        _: return "Chưa đủ điều kiện"

func _close_office_picker() -> void:
    _office_picker_role = ""
    _render()

func _appoint_office(role_id: String, disciple_id: StringName) -> void:
    var result: Dictionary = SectHallSystemV1.appoint(_state,role_id,disciple_id)
    _feedback = "Đã bổ nhiệm %s làm %s." % [_state.disciples[disciple_id].display_name,SectHallSystemV1.label(role_id)] if bool(result.get("ok",false)) else "Chưa thể bổ nhiệm: %s." % _office_blocker_text(str(result.get("reason","")))
    _office_picker_role = ""
    if bool(result.get("ok",false)):
        _host.emit_signal("state_changed")
        _host.call("_refresh")
    _render()

func _promote_hall() -> void:
    _host.call("_promote_sect")
    _feedback = _host_feedback()
    _render()

func _upgrade_hall() -> void:
    var hall: BuildingState = SectHallSystemV1.hall(_state)
    if hall == null:
        return
    var request_id := "hall-upgrade:%s:%d" % [str(hall.id),hall.level+1]
    _host.call("_start_upgrade",request_id)
    _feedback = _host_feedback()
    _render()

func _select_site(site_id: String) -> void:
    _selected_site_id = site_id
    _render()

func _build_house(site_id: String) -> void:
    var map_owner := _host.get_parent() if _host != null else null
    if map_owner != null and map_owner.has_method("_start_b1_residence_build"):
        map_owner.call("_start_b1_residence_build",site_id)
    else:
        _feedback = "Mở Đệ Tử Xá trong P3.2 để đặt nhà trực tiếp lên địa hình."
        _render()

func _open_map_residence_plan() -> void:
    var map_owner := _host.get_parent() if _host != null else null
    if map_owner != null and map_owner.has_method("_start_b1_residence_plan"):
        map_owner.call("_start_b1_residence_plan")
    else:
        _feedback = "Quy hoạch địa hình chỉ mở từ bản đồ tông môn P3.2."
        _render()

func _assign_room(disciple_id: String, house_id: String) -> void:
    var result: Dictionary = SectResidenceSystemV1.assign_room(_state,StringName(disciple_id),StringName(house_id))
    _feedback = "Đã phân phòng cho %s." % str(_state.disciples[StringName(disciple_id)].display_name) if bool(result.get("ok",false)) else "Chưa thể phân phòng: %s." % str(result.get("reason","unknown")).replace("_"," ")
    if bool(result.get("ok",false)):
        _host.emit_signal("state_changed")
        _host.call("_refresh")
    _render()

func _upgrade_house(residence_id: String) -> void:
    if not _state.buildings.has(residence_id):
        return
    var house: BuildingState = _state.buildings[residence_id]
    var request_id := "residence-upgrade:%s:%d" % [str(house.id),house.level+1]
    _host.call("_upgrade_house",house.id,request_id)
    _feedback = _host_feedback()
    _render()

func _dismiss_office(role_id: String) -> void:
    var result: Dictionary = SectHallSystemV1.dismiss(_state, role_id)
    _feedback = "Đã miễn nhiệm: %s." % SectHallSystemV1.label(role_id) if bool(result.get("ok", false)) else "Chưa thể miễn nhiệm: %s." % str(result.get("reason", "unknown"))
    if bool(result.get("ok", false)):
        _host.emit_signal("state_changed")
        _host.call("_refresh")
    _render()

func _sync_guidance_selection_from_view() -> void:
    if _mode != "guidance" or _active_view == null or not _active_view.has_method("_candidate_id"):
        return
    var candidate_id := str(_active_view.call("_candidate_id"))
    if not candidate_id.is_empty() and _state.recruitment_candidates.has(StringName(candidate_id)):
        _host.set("selected_candidate_id", StringName(candidate_id))

func _page_candidate(_direction: int) -> void:
    _sync_guidance_selection_from_view()

func _search_candidate(_query: String) -> void:
    # Search filters the B1 view-model locally; only the selected canonical ID
    # flows back to the existing C2 selection authority.
    _sync_guidance_selection_from_view()

func _accept_candidate(candidate_id: String) -> void:
    var key := StringName(candidate_id)
    if not _state.recruitment_candidates.has(key):
        return
    var candidate: CandidateState = _state.recruitment_candidates[key]
    var candidate_name := candidate.display_name
    _host.set("selected_candidate_id", key)
    var result: Dictionary = _recruitment.accept_candidate(_state,key)
    if bool(result.get("ok",false)):
        _last_recruited_disciple_id = str(result.get("disciple_id",""))
        _feedback = "Đã thu nạp %s vào hàng ngũ Tông Môn." % candidate_name
        _host.set("selected_candidate_id",&"")
        _host.set("pending_reject_id",&"")
        _host.set("feedback",_feedback)
        _host.emit_signal("state_changed")
        _host.call("_refresh_all")
    else:
        var reason := str(result.get("reason","unknown"))
        _feedback = "Không thể nhận %s: %s." % [candidate_name,_recruitment_failure_text(reason)]
        _host.set("feedback",_feedback)
    _render()

func _reject_candidate(candidate_id: String) -> void:
    var key := StringName(candidate_id)
    if not _state.recruitment_candidates.has(key):
        return
    var result: Dictionary = _recruitment.reject_candidate(_state,key)
    if bool(result.get("ok",false)):
        _feedback = "Đã từ chối ứng viên; không tiêu Chiêu Mộ Lệnh."
        _host.set("selected_candidate_id",&"")
        _host.set("pending_reject_id",&"")
        _host.set("feedback",_feedback)
        _host.emit_signal("state_changed")
        _host.call("_refresh_all")
    else:
        _feedback = "Không thể từ chối hồ sơ: %s." % _recruitment_failure_text(str(result.get("reason","unknown")))
    _render()

func _recruitment_failure_text(reason: String) -> String:
    match reason:
        "capacity_full": return "Đệ Tử Xá đã hết chỗ; mở rộng sức chứa trước khi nhận."
        "v2_birth_profile_incomplete": return "hồ sơ sinh V2 chưa đủ; ứng viên vẫn được giữ nguyên."
        "candidate_missing": return "hồ sơ đã thay đổi; hãy chọn lại."
        "duplicate_disciple_id": return "mã đệ tử đã tồn tại; không tạo bản sao."
        "recruitment_disabled": return "Dẫn Tiên Đài đang bị khóa."
        _: return "điều kiện tuyển dụng chưa đạt."

func _assign_guidance_main(disciple_id: String) -> void:
    var result: Dictionary = _recruitment.assign_guidance_main(_state,StringName(disciple_id))
    _feedback = "Đã bổ nhiệm Tiếp Dẫn Trưởng Lão." if bool(result.get("ok",false)) else "Chưa thể bổ nhiệm: %s." % _recruitment_failure_text(str(result.get("reason","unknown")))
    if bool(result.get("ok",false)):
        _host.emit_signal("state_changed")
        _host.call("_refresh_all")
    _render()

func _assign_guidance_assistants(disciple_ids: Array) -> void:
    var result: Dictionary = _recruitment.set_guidance_assistants(_state,disciple_ids)
    _feedback = "Đã cập nhật Tiếp Dẫn phụ." if bool(result.get("ok",false)) else "Chưa thể cập nhật Tiếp Dẫn phụ: %s." % _recruitment_failure_text(str(result.get("reason","unknown")))
    if bool(result.get("ok",false)):
        _host.emit_signal("state_changed")
        _host.call("_refresh_all")
    _render()

func _open_residence_capacity() -> void:
    var map_owner := _host.get_parent() if _host != null else null
    if map_owner != null and map_owner.has_method("_open_dai_dien_housing_v1"):
        _close_host()
        map_owner.call_deferred("_open_dai_dien_housing_v1")
    else:
        _feedback = "Mở rộng chỗ ở từ bản đồ P3.2."
        _render()

func _open_recruited_profile(disciple_id: String) -> void:
    _open_recruited_world_action("_open_disciple_deep_screen",disciple_id)

func _open_recruited_world(disciple_id: String) -> void:
    _open_recruited_world_action("_open_disciple",disciple_id)

func _open_recruited_assignment(disciple_id: String) -> void:
    _open_recruited_world_action("_open_disciple_quick_assignment",disciple_id)

func _open_recruited_world_action(method: String, disciple_id: String) -> void:
    var map_owner := _host.get_parent() if _host != null else null
    if map_owner != null and map_owner.has_method(method):
        _close_host()
        if method == "_open_disciple_deep_screen":
            map_owner.call_deferred(method,StringName(disciple_id),"Tổng Quan")
        else:
            map_owner.call_deferred(method,StringName(disciple_id))
    else:
        _feedback = "Mở danh sách đệ tử trên bản đồ P3.2 để tiếp tục."
        _render()

func _recruit_order() -> void:
    # C2 paid order creates a new queue entry; it does not accept the selected candidate.
    _host.call("_spend_order")
    _feedback = _host_feedback()
    _render()
