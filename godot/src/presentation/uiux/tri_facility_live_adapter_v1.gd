extends Control
## B1 view-model/callback bridge: delegates all mutations to existing canonical UI/actions.
## The original full management screen remains underneath and is always accessible.

const HALL_B1 = preload("res://src/presentation/uiux/dai_dien_screen_b1_v1.gd")
const HOUSE_B1 = preload("res://src/presentation/uiux/de_tu_xa_screen_b1_v1.gd")
const GUIDANCE_B1 = preload("res://src/presentation/uiux/dan_tien_screen_b1_v1.gd")

var _host: Control
var _state: SimulationState
var _recruitment: RecruitmentSystem
var _mode := "hall"
var _selected_site_id := ""

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
    var view: Control
    match _mode:
        "hall":
            view = HALL_B1.new()
            view.office_selection_requested.connect(_open_office)
            view.promotion_requested.connect(_promote_hall)
            view.hall_upgrade_requested.connect(_upgrade_hall)
            view.closed.connect(_close_host)
        "residence":
            view = HOUSE_B1.new()
            view.site_selection_requested.connect(_select_site)
            view.residence_build_requested.connect(_build_house)
            view.residence_upgrade_requested.connect(_upgrade_house)
            view.closed.connect(_close_host)
        "guidance":
            view = GUIDANCE_B1.new()
            view.candidate_page_requested.connect(_page_candidate)
            view.accept_candidate_requested.connect(_accept_candidate)
            view.reject_candidate_requested.connect(_reject_candidate)
            view.lead_in_requested.connect(_open_full_details)
            view.recruit_candidate_requested.connect(_recruit_order)
            view.closed.connect(_close_host)
        _:
            return
    view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(view)
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
    detail.custom_minimum_size = Vector2(190, 42)
    detail.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
    detail.offset_left = -225
    detail.offset_right = -24
    detail.offset_top = -58
    detail.offset_bottom = -16
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
        var mastery_value := "Chưa có"
        if not holder_id.is_empty() and _state.disciples.has(StringName(holder_id)):
            var actor: DiscipleState = _state.disciples[StringName(holder_id)]
            name_value = actor.display_name
            var record: Dictionary = SectHallSystemV1.mastery(_state, role_id, holder_id)
            mastery_value = "Tinh Thông Lv%d" % int(record.get("level", 1))
        offices.append({"id":role_id, "disciple_name":name_value, "office_rank":mastery_value})
    var promotion: Dictionary = SectHallSystemV1.promotion_requirements(_state)
    var blockers: Array = promotion.get("blockers", [])
    var requirement := "Đã đạt Thần 9/9." if SectHallSystemV1.rank_index(_state) >= 27 else (
        "Có thể thăng bậc." if bool(promotion.get("ok", false)) else "Chưa đủ: " + ", ".join(PackedStringArray(blockers)))
    var cost: Dictionary = BuildingSystem.new().upgrade_cost(hall)
    var costs: Array[Dictionary] = [
        {"name":"Linh Mộc", "amount":str(int(cost.get(BuildingSystem.MATERIAL_WOOD, 0))), "icon":"leaf"},
        {"name":"Thanh Thiết", "amount":str(int(cost.get(BuildingSystem.MATERIAL_ORE, 0))), "icon":"resource"},
        {"name":"Linh Thạch", "amount":str(int(cost.get("spirit_stones", 0))), "icon":"gold"}
    ]
    var upgrade: Dictionary = BuildingSystem.new().can_start_upgrade(_state, hall.id)
    return {
        "building_level":hall.level,
        "rank_step":SectHallSystemV1.rank_index(_state),
        "rank_progress":float(SectHallSystemV1.rank_index(_state)) / 27.0,
        "rank_requirement":requirement,
        "can_promote":bool(promotion.get("ok", false)),
        "can_upgrade":bool(upgrade.get("ok", false)),
        "upgrade_costs":costs,
        "offices":offices
    }

func _house_model() -> Dictionary:
    var houses: Array = SectResidenceSystemV1.all_houses(_state)
    var sites: Array[Dictionary] = []
    var selected_house: BuildingState = null
    var assignments: Dictionary = _state.sect.hall_governance.get("residence_assignments", {})
    var buildings := BuildingSystem.new()
    for house in houses:
        if not (house is BuildingState):
            continue
        if selected_house == null:
            selected_house = house
        var used := 0
        for assigned_house in assignments.values():
            if str(assigned_house) == str(house.id):
                used += 1
        var capacity := 0 if house.status == BuildingSystem.STATUS_CONSTRUCTING else SectResidenceSystemV1.beds_for_level(house.level)
        var check: Dictionary = buildings.can_start_upgrade(_state, house.id)
        sites.append({
            "id":str(house.id), "name":"Đệ Tử Xá %s" % str(house.id),
            "status":"Đang xây" if house.status == BuildingSystem.STATUS_CONSTRUCTING else "Lv%d" % house.level,
            "resident_summary":"%d/%d giường" % [used, capacity],
            "built":true, "can_build":false, "can_upgrade":bool(check.get("ok", false))
        })
    var plots: Array[Vector2i] = SectResidenceSiteV1.available_plots(_state)
    for point in plots:
        var site_id := "plot:%d:%d" % [point.x, point.y]
        var check: Dictionary = SectResidenceSystemV1.can_construct(_state, point)
        sites.append({
            "id":site_id,"name":"Lô (%d,%d)" % [point.x, point.y],
            "status":"Chưa xây · cửa ngoài trời", "resident_summary":"",
            "built":false,"can_build":bool(check.get("ok", false)),"can_upgrade":false
        })
    if _selected_site_id.is_empty() and not sites.is_empty():
        _selected_site_id = str(sites[0].get("id", ""))
    for house in houses:
        if str(house.id) == _selected_site_id:
            selected_house = house
            break
    var bed_slots: Array[Dictionary] = []
    if selected_house != null and selected_house.status != BuildingSystem.STATUS_CONSTRUCTING:
        var residents: Array[String] = []
        for disciple_id in assignments:
            if str(assignments[disciple_id]) == str(selected_house.id):
                residents.append(str(disciple_id))
        residents.sort()
        var count := SectResidenceSystemV1.beds_for_level(selected_house.level)
        for index in range(count):
            var id := residents[index] if index < residents.size() else ""
            var occupant := not id.is_empty() and _state.disciples.has(StringName(id))
            var display := _state.disciples[StringName(id)].display_name if occupant else "Trống"
            bed_slots.append({"id":"%s:%d" % [str(selected_house.id),index+1],
                "occupied":occupant,"disciple_short_name":display})
    return {
        "building_level":selected_house.level if selected_house != null else 1,
        "room_count_label":"%d nhà" % houses.size(),
        "selected_residence_id":_selected_site_id,
        "bed_slots":bed_slots,
        "sites":sites
    }

func _guidance_model() -> Dictionary:
    var ids: Array = _state.recruitment_candidates.keys()
    ids.sort()
    var candidate_id := StringName(str(_host.get("selected_candidate_id")))
    if candidate_id == &"" or not _state.recruitment_candidates.has(candidate_id):
        candidate_id = StringName(str(ids[0])) if not ids.is_empty() else &""
    if candidate_id != &"" and str(_host.get("selected_candidate_id")) != str(candidate_id):
        _host.set("selected_candidate_id", candidate_id)
    var candidate_data: Dictionary = {}
    var can_accept := false
    if candidate_id != &"":
        var candidate: CandidateState = _state.recruitment_candidates[candidate_id]
        var recruitable := bool(_host.call("_recruitable", candidate))
        can_accept = recruitable and _recruitment.can_accept_more(_state)
        candidate_data = {
            "id":str(candidate_id), "name":candidate.display_name,
            "realm":"Phàm Nhân", "origin":str(candidate.disciple_quality),
            "personality":"", "status":"Chờ quyết định",
            "source_art_approved":false,
            "tam_values":[candidate.aptitude,candidate.constitution,candidate.mind_nature],
            "tu_values":[candidate.potential,candidate.comprehension,candidate.fortune,candidate.charisma]
        }
    var tokens := _state.sect.disciple_recruitment_tokens
    return {
        "candidate":candidate_data,
        "can_accept":can_accept,
        "can_reject":candidate_id != &"",
        "can_lead_in":true,
        "can_recruit":tokens > 0 and ids.size() < RecruitmentSystem.C2_QUEUE_CAP,
        "metrics":[
            {"label":"ỨNG VIÊN","value":str(ids.size()),"icon":"person"},
            {"label":"CHIÊU MỘ LỆNH","value":str(tokens),"icon":"guide"},
            {"label":"ĐỆ TỬ","value":"%d/%d" % [_state.disciples.size(),_state.sect.disciple_capacity],"icon":"hall"}
        ]
    }

func _open_full_details() -> void:
    if _host == null:
        return
    if _mode == "residence":
        _host.call("_tab", 5)
    elif _mode == "hall":
        _host.call("_tab", 0)
    queue_free()

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
    _render()

func _upgrade_hall() -> void:
    var hall: BuildingState = SectHallSystemV1.hall(_state)
    if hall == null:
        return
    var request_id := "hall-upgrade:%s:%d" % [str(hall.id),hall.level+1]
    _host.call("_start_upgrade",request_id)
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
    _host.set("feedback","Đã khởi công Đệ Tử Xá." if bool(result.get("ok",false)) else "Không xây được: %s" % str(result.get("reason","unknown")))
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
    _render()

func _page_candidate(direction: int) -> void:
    var ids: Array = _state.recruitment_candidates.keys()
    ids.sort()
    if ids.is_empty():
        return
    var selected_id := _host.get("selected_candidate_id")
    var current := ids.find(selected_id)
    var next_index := clampi(current+direction,0,ids.size()-1)
    _host.call("_select_candidate",StringName(str(ids[next_index])))
    _render()

func _accept_candidate(candidate_id: String) -> void:
    if str(_host.get("selected_candidate_id")) != candidate_id:
        return
    _host.call("_accept_selected")
    _render()

func _reject_candidate(candidate_id: String) -> void:
    if str(_host.get("selected_candidate_id")) != candidate_id:
        return
    # B1 already confirmed twice; canonical C2 still executes the actual mutation.
    _host.set("pending_reject_id",StringName(candidate_id))
    _host.call("_reject_selected")
    _render()

func _recruit_order(_candidate_id: String) -> void:
    # C2 paid order creates a NEW candidate; its intent is not a candidate acceptance.
    _host.call("_spend_order")
    _render()
