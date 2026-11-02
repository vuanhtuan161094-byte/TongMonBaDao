extends Control
## B1 view-model/callback bridge: delegates all mutations to existing canonical UI/actions.
## The original full management screen remains underneath and is always accessible.

const HALL_B1 = preload("res://src/presentation/uiux/dai_dien_screen_b1_v1.gd")
const HOUSE_B1 = preload("res://src/presentation/uiux/de_tu_xa_screen_b1_v1.gd")
const GUIDANCE_B1 = preload("res://src/presentation/uiux/dan_tien_screen_b1_v1.gd")

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
            view.connect("room_management_requested", Callable(self, "_open_full_details"))
            view.connect("closed", Callable(self, "_close_host"))
        "guidance":
            view = GUIDANCE_B1.new()
            view.connect("candidate_page_requested", Callable(self, "_page_candidate"))
            view.connect("candidate_search_requested", Callable(self, "_search_candidate"))
            view.connect("accept_candidate_requested", Callable(self, "_accept_candidate"))
            view.connect("reject_candidate_requested", Callable(self, "_reject_candidate"))
            view.connect("guide_management_requested", Callable(self, "_open_full_details"))
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
    var detail := Button.new()
    detail.name = "OpenCanonicalFacilityManagement"
    detail.text = "QUẢN LÝ ĐẦY ĐỦ"
    detail.custom_minimum_size = Vector2(190, 48)
    detail.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
    detail.offset_left = -334
    detail.offset_right = -132
    detail.offset_top = 18
    detail.offset_bottom = 60
    detail.z_index = 2
    detail.pressed.connect(_open_full_details)
    add_child(detail)

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
            var record: Dictionary = SectHallSystemV1.mastery(_state, role_id, holder_id)
            mastery_value = "Tinh Thông Lv%d/10" % int(record.get("level", 1))
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
        var capacity := 0 if house.status == BuildingSystem.STATUS_CONSTRUCTING else SectResidenceSystemV1.beds_for_level(house.level)
        var upgrade_check: Dictionary = buildings.can_start_upgrade(_state, house.id)
        sites.append({
            "id":str(house.id), "name":"Đệ Tử Xá %02d" % house_display_number,
            "status":"Đang xây" if house.status == BuildingSystem.STATUS_CONSTRUCTING else "Lv%d" % house.level,
            "resident_summary":"%d/%d giường" % [residents.size(), capacity],
            "built":true, "can_build":false, "can_upgrade":bool(upgrade_check.get("ok", false))
        })
        for bed_index in range(capacity):
            var disciple_id := StringName(residents[bed_index]) if bed_index < residents.size() else &""
            var occupied := disciple_id != &""
            var display := str(_state.disciples[disciple_id].display_name) if occupied else "Trống"
            bed_slots.append({
                "id":"%s:%d" % [str(house.id), bed_index + 1],
                "occupied":occupied, "disciple_short_name":display
            })
    for point in SectResidenceSiteV1.available_plots(_state):
        var site_id := "plot:%d:%d" % [point.x, point.y]
        var check: Dictionary = SectResidenceSystemV1.can_construct(_state, point)
        sites.append({
            "id":site_id, "name":"Lô (%d,%d)" % [point.x, point.y],
            "status":"Chưa xây · cửa ngoài trời", "resident_summary":"",
            "built":false, "can_build":bool(check.get("ok", false)), "can_upgrade":false
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
    return {
        "building_level":selected_house.level if selected_house != null else 1,
        "room_count_label":"%d nhà · %d giường" % [houses.size(), SectResidenceSystemV1.total_beds(_state)],
        "selected_residence_id":_selected_site_id,
        "bed_slots":bed_slots, "sites":sites, "build_costs":build_costs,
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
        rows.append({
            "id":str(candidate.id), "name":candidate.display_name,
            "realm":"Phàm Nhân · Phàm Thân tầng 1",
            "origin":_ui_name(str(candidate.origin_id), UI_ORIGIN_NAMES) if not str(candidate.origin_id).is_empty() else "Chưa ghi xuất thân",
            "personality":"%s · %s" % [_ui_name(str(candidate.race_id), UI_RACE_NAMES) if not str(candidate.race_id).is_empty() else "Ứng viên", "Nữ" if str(candidate.sex_id) == "female" else "Nam"],
            "status":"%s · Hồ sơ V2 %s" % [_ui_name(str(candidate.recruitment_source), UI_SOURCE_NAMES), "hợp lệ" if valid_birth else "chưa hợp lệ"],
            "tam_values":[candidate.aptitude, candidate.constitution, candidate.mind_nature],
            "tu_values":[candidate.potential, candidate.comprehension, candidate.fortune, candidate.charisma],
            "metrics":[
                {"label":"PHẨM","value":quality,"icon":"rank"},
                {"label":"TUỔI","value":str(candidate.age),"icon":"person"},
                {"label":"LINH CĂN","value":_ui_name(str(candidate.spiritual_root_quality), UI_ROOT_NAMES),"icon":"leaf"},
                {"label":"NGHỀ","value":_ui_profession_traits(candidate.profession_traits),"icon":"guide"}
            ],
            "can_accept":can_roster_accept and valid_birth,
            "can_reject":true, "source_art_approved":false
        })
    var platform: BuildingState = BuildingSystem.new().primary_building(_state, BuildingSystem.TYPE_GUIDANCE_PLATFORM)
    var available := _state.p1_recruitment_enabled and _state.sect.disciple_generation_v2_enabled \
        and _state.sect.guidance_recruitment_enabled and _state.p3_7_buildings_enabled and platform != null
    var token_count: int = _state.sect.disciple_recruitment_tokens
    return {
        "candidates":rows,
        "selected_candidate_id":str(_host.get("selected_candidate_id")),
        "can_accept":can_roster_accept,
        "can_reject":not rows.is_empty(),
        "can_use_order":available and token_count > 0 and ids.size() < RecruitmentSystem.C2_QUEUE_CAP,
        "recruitment_tokens":token_count,
        "feedback":_feedback
    }

func _ui_name(raw: String, catalog: Dictionary) -> String:
    return str(catalog.get(raw, raw.replace("_", " ")))

func _ui_profession_traits(traits: Array) -> String:
    if traits.is_empty():
        return "Chưa xác định"
    var names: PackedStringArray = []
    for trait_id in traits:
        names.append(_ui_name(str(trait_id), UI_PROFESSION_NAMES))
    return " · ".join(names)

func _open_full_details() -> void:
    if _host == null:
        return
    if _mode == "residence":
        _host.call("_tab", 5)
    elif _mode == "hall":
        _host.call("_tab", 0)
    queue_free()

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
    _host.call("_select_office", role_id)
    _host.call("_tab", 1)
    queue_free()

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
    var coordinates := site_id.split(":")
    if coordinates.size() != 3 or coordinates[0] != "plot":
        return
    var plot := Vector2i(int(coordinates[1]),int(coordinates[2]))
    var count := SectResidenceSystemV1.all_houses(_state).size() + 1
    var result: Dictionary = SectResidenceSystemV1.construct(_state,"residence:%d" % count,plot)
    _feedback = "Đã khởi công Đệ Tử Xá." if bool(result.get("ok",false)) else "Không xây được: %s" % str(result.get("reason","unknown"))
    _host.set("feedback", _feedback)
    if bool(result.get("ok",false)):
        _selected_site_id = str(result.get("building_id",""))
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
    _host.set("selected_candidate_id", key)
    _host.call("_accept_selected")
    _render()

func _reject_candidate(candidate_id: String) -> void:
    var key := StringName(candidate_id)
    if not _state.recruitment_candidates.has(key):
        return
    # B1 already confirmed twice; canonical C2 still executes the actual mutation.
    _host.set("selected_candidate_id", key)
    _host.set("pending_reject_id", key)
    _host.call("_reject_selected")
    _render()

func _recruit_order() -> void:
    # C2 paid order creates a new queue entry; it does not accept the selected candidate.
    _host.call("_spend_order")
    _feedback = _host_feedback()
    _render()
