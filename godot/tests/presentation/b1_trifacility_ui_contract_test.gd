extends SceneTree

const HALL = preload("res://src/presentation/uiux/dai_dien_screen_b1_v1.gd")
const RESIDENCE = preload("res://src/presentation/uiux/de_tu_xa_screen_b1_v1.gd")
const GUIDANCE = preload("res://src/presentation/uiux/dan_tien_screen_b1_v1.gd")

func _init() -> void:
	call_deferred("_run")

func _fail(message: String) -> void:
	push_error("B1 UI contract: " + message)
	quit(1)

func _find_button(node: Node, target_name: String) -> Button:
	if node is Button and node.name == target_name:
		return node as Button
	for child in node.get_children():
		var found := _find_button(child, target_name)
		if found != null:
			return found
	return null

func _run() -> void:
	if HALL.ROLE_LABELS != SectHallSystemV1.LABELS:
		_fail("Hall labels must match SectHallSystemV1 exactly.")
		return
	var hall := HALL.new()
	root.add_child(hall)
	hall.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hall.bind_view_model({
		"building_level": 6, "rank_step": 14, "rank_progress": 0.4,
		"rank_requirement": "Điều kiện được cung cấp", "can_promote": true, "can_upgrade": true,
		"upgrade_costs": [{"name": "Linh Thạch", "amount": "20", "icon": "gold"}],
		"offices": [{"id": "master", "disciple_name": "Thanh Vân", "office_rank": "Tinh Thông Lv2/10", "can_dismiss": true}]
	})
	await process_frame
	var office_cards := 0
	for node in hall.find_children("Office_*", "", true, false):
		office_cards += 1
	if office_cards != 7:
		_fail("Hall must present exactly the seven supplied office positions.")
		return
	var steps: GridContainer = hall.find_child("RankSteps", true, false) as GridContainer
	if steps == null or steps.get_child_count() != 27:
		_fail("Hall must show 27 supplied rank progress segments.")
		return
	var selected_roles: Array[String] = []
	hall.office_selection_requested.connect(func(role_id: String): selected_roles.append(role_id))
	var choose_office := _find_button(hall, "ChooseOffice")
	if choose_office == null:
		_fail("Hall office selection button missing.")
		return
	choose_office.pressed.emit()
	if selected_roles.size() != 1 or selected_roles[0] != "master":
		_fail("Office click must emit the source role ID.")
		return
	var promoted: Array[bool] = []
	hall.promotion_requested.connect(func(): promoted.append(true))
	var promote_button := _find_button(hall, "PromoteRank")
	if promote_button == null or promote_button.disabled:
		_fail("Hall promotion must use supplied eligibility.")
		return
	promote_button.pressed.emit()
	if promoted.size() != 1 or hall.find_child("UpgradeHall", true, false) == null:
		_fail("Hall action intents or upgrade control missing.")
		return
	var dismissed_roles: Array[String] = []
	hall.office_dismissal_requested.connect(func(role_id: String): dismissed_roles.append(role_id))
	var dismiss_office := _find_button(hall, "DismissOffice")
	if dismiss_office == null or dismiss_office.disabled:
		_fail("Hall dismissal control must follow authoritative can_dismiss state.")
		return
	dismiss_office.pressed.emit()
	if dismissed_roles != ["master"]:
		_fail("Hall dismissal must emit the canonical role ID.")
		return
	hall.queue_free()

	var residence := RESIDENCE.new()
	var all_beds: Array[Dictionary] = []
	for index in range(20):
		all_beds.append({"id": "bed_%02d" % index, "occupied": index < 6, "disciple_short_name": "Đệ tử %02d" % (index + 1) if index < 6 else "Trống"})
	var all_sites: Array[Dictionary] = [
		{"id": "north", "name": "Đã xây", "built": true, "can_upgrade": true, "can_build": false},
		{"id": "east", "name": "Đất trống", "built": false, "can_build": true, "can_upgrade": false}
	]
	for index in range(10):
		all_sites.append({"id": "annex_%02d" % index, "name": "Lô %02d" % index, "built": false, "can_build": false, "can_upgrade": false})
	root.add_child(residence)
	residence.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	residence.bind_view_model({
		"building_level": 3, "room_count_label": "2 phòng", "selected_residence_id": "north",
		"bed_slots": all_beds,
		"sites": all_sites
	})
	await process_frame
	var bed_grid := residence.find_child("ResidenceBedSlots", true, false) as GridContainer
	var site_grid := residence.find_child("ResidenceSiteCards", true, false) as GridContainer
	if bed_grid == null or bed_grid.get_child_count() != 20 or residence.find_child("ResidenceBedScroll", true, false) == null:
		_fail("Residence must keep every bed visible in its scroll list.")
		return
	if site_grid == null or site_grid.get_child_count() != 12 or residence.find_child("ResidenceSiteScroll", true, false) == null:
		_fail("Residence must keep every supplied construction lot in its scroll list.")
		return
	var selected_sites: Array[String] = []
	residence.site_selection_requested.connect(func(site_id: String): selected_sites.append(site_id))
	var site_button := _find_button(residence, "SelectSite")
	if site_button == null:
		_fail("Residence site selector missing.")
		return
	site_button.pressed.emit()
	if selected_sites.size() != 1 or selected_sites[0] != "north":
		_fail("Site selector must emit supplied site ID.")
		return
	var room_management: Array[bool] = []
	residence.room_management_requested.connect(func(): room_management.append(true))
	var manage_rooms := _find_button(residence, "ManageResidenceRooms")
	if manage_rooms == null:
		_fail("Residence room management route is missing.")
		return
	manage_rooms.pressed.emit()
	if room_management != [true]:
		_fail("Residence room management must route to its canonical screen.")
		return
	var upgrade_ids: Array[String] = []
	residence.residence_upgrade_requested.connect(func(id: String): upgrade_ids.append(id))
	var upgrade_button := _find_button(residence, "UpgradeResidence")
	if upgrade_button == null or upgrade_button.disabled:
		_fail("Residence upgrade must use supplied eligibility.")
		return
	upgrade_button.pressed.emit()
	if upgrade_ids.size() != 1 or upgrade_ids[0] != "north":
		_fail("Residence upgrade intent must emit selected residence ID.")
		return
	var built_sites: Array[String] = []
	residence.residence_build_requested.connect(func(site_id: String): built_sites.append(site_id))
	var build_button := _find_button(residence, "BuildSelectedSite")
	if build_button == null or not build_button.disabled:
		_fail("Residence must disable build when the supplied site is not eligible.")
		return
	residence.bind_view_model({
		"building_level": 3, "room_count_label": "2 phòng", "selected_residence_id": "east",
		"bed_slots": [],
		"sites": all_sites
	})
	await process_frame
	build_button = _find_button(residence, "BuildSelectedSite")
	if build_button == null or build_button.disabled:
		_fail("Residence build button must enable from supplied eligibility.")
		return
	build_button.pressed.emit()
	if built_sites.size() != 1 or built_sites[0] != "east":
		_fail("Build intent must only emit selected residence ID.")
		return
	residence.queue_free()

	var guidance := GUIDANCE.new()
	root.add_child(guidance)
	guidance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	guidance.bind_view_model({
		"candidates": [
			{"id": "cand-1", "name": "Ứng viên", "tam_values": [30, 50, 60], "tu_values": [10, 20, 30, 40], "can_accept": true, "can_reject": true},
			{"id": "cand-2", "name": "Liễu Vân", "tam_values": [40, 50, 60], "tu_values": [11, 21, 31, 41], "can_accept": false, "can_reject": true},
			{"id": "cand-3", "name": "Tô Minh", "tam_values": [50, 60, 70], "tu_values": [12, 22, 32, 42], "can_accept": true, "can_reject": true}
		],
		"can_accept": true, "can_reject": true, "can_use_order": true, "recruitment_tokens": 2
	})
	await process_frame
	var candidate_ids: Array[String] = []
	guidance.accept_candidate_requested.connect(func(id: String): candidate_ids.append(id))
	var accept_button := _find_button(guidance, "AcceptCandidate")
	if accept_button == null:
		_fail("Guidance accept control missing.")
		return
	accept_button.pressed.emit()
	if not candidate_ids.is_empty():
		_fail("Accept must require a second confirm tap.")
		return
	await process_frame
	accept_button = _find_button(guidance, "AcceptCandidate")
	if accept_button == null or accept_button.text != "XÁC NHẬN NHẬN ĐỆ TỬ":
		_fail("Accept confirmation state is not visible after the first tap.")
		return
	accept_button.pressed.emit()
	if candidate_ids != ["cand-1"]:
		_fail("Confirmed accept must emit only the candidate key.")
		return
	var search_queries: Array[String] = []
	guidance.candidate_search_requested.connect(func(query: String): search_queries.append(query))
	var search := guidance.find_child("CandidateSearch", true, false) as LineEdit
	if search == null:
		_fail("Candidate search field missing.")
		return
	search.text = "Liễu"
	var search_button := _find_button(guidance, "ApplyCandidateSearch")
	if search_button == null:
		_fail("Candidate search action missing.")
		return
	search_button.pressed.emit()
	if search_queries != ["Liễu"] or str(guidance.call("_candidate_id")) != "cand-2":
		_fail("Candidate search must filter the actual supplied candidate pool.")
		return
	search = guidance.find_child("CandidateSearch", true, false) as LineEdit
	search.text = ""
	_find_button(guidance, "ApplyCandidateSearch").pressed.emit()
	await process_frame
	var guide_routes: Array[bool] = []
	guidance.guide_management_requested.connect(func(): guide_routes.append(true))
	var manage_guides := _find_button(guidance, "ManageGuides")
	if manage_guides == null:
		_fail("Main/assistant guide management route missing.")
		return
	manage_guides.pressed.emit()
	var order_requests: Array[bool] = []
	guidance.recruitment_order_requested.connect(func(): order_requests.append(true))
	var order_button := _find_button(guidance, "UseRecruitmentOrder")
	if order_button == null or order_button.disabled:
		_fail("Chiêu Mộ Lệnh button must follow supplied authority eligibility.")
		return
	order_button.pressed.emit()
	if guide_routes != [true] or order_requests != [true]:
		_fail("Guide management and Chiêu Mộ Lệnh must emit real action intents.")
		return
	var page_directions: Array[int] = []
	guidance.candidate_page_requested.connect(func(direction: int): page_directions.append(direction))
	var previous_button := _find_button(guidance, "PreviousCandidate")
	var next_button := _find_button(guidance, "NextCandidate")
	if previous_button == null or next_button == null:
		_fail("Candidate paging controls missing.")
		return
	previous_button.pressed.emit()
	next_button.pressed.emit()
	if page_directions != [-1, 1]:
		_fail("Candidate paging must use the filtered pool.")
		return
	var rejects: Array[String] = []
	guidance.reject_candidate_requested.connect(func(id: String): rejects.append(id))
	var reject_button := _find_button(guidance, "RejectCandidate")
	if reject_button == null:
		_fail("Guidance reject control missing.")
		return
	reject_button.pressed.emit()
	if not rejects.is_empty():
		_fail("Reject must require two deliberate taps.")
		return
	await process_frame
	reject_button = _find_button(guidance, "RejectCandidate")
	if reject_button == null or reject_button.text != "XÁC NHẬN TỪ CHỐI":
		_fail("Reject confirmation state must be visible after the first tap.")
		return
	reject_button.pressed.emit()
	if rejects.size() != 1 or rejects[0] != "cand-1":
		_fail("Confirmed reject emits one candidate intent.")
		return
	var radar := guidance.find_child("FoundationRadar", true, false)
	if radar == null or not radar.has_method("set_values"):
		_fail("Guidance must include a replaceable D7-compatible radar control.")
		return
	var source_files := [
		"res://src/presentation/uiux/dai_dien_screen_b1_v1.gd",
		"res://src/presentation/uiux/de_tu_xa_screen_b1_v1.gd",
		"res://src/presentation/uiux/dan_tien_screen_b1_v1.gd"
	]
	for source_path in source_files:
		var source := FileAccess.get_file_as_string(source_path)
		if source.contains("SimulationState") or source.contains("SaveService") or source.contains("WarehouseSystem"):
			_fail("Presentation screens must not own simulation, save or warehouse authority.")
			return
	print("TRI01_B1_UI_CONTRACT_PASS")
	quit(0)
