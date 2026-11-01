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
	var hall := HALL.new()
	root.add_child(hall)
	hall.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hall.bind_view_model({
		"building_level": 6, "rank_step": 14, "rank_progress": 0.4,
		"rank_requirement": "Điều kiện được cung cấp", "can_promote": true, "can_upgrade": true,
		"upgrade_costs": [{"name": "Linh Thạch", "amount": "20", "icon": "gold"}],
		"offices": [{"id": "master", "disciple_name": "Thanh Vân", "office_rank": "Cảnh giới"}]
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
	hall.queue_free()

	var residence := RESIDENCE.new()
	root.add_child(residence)
	residence.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	residence.bind_view_model({
		"building_level": 3, "room_count_label": "2 phòng", "selected_residence_id": "north",
		"bed_slots": [{"id": "bed_a", "occupied": true, "disciple_short_name": "A"}],
		"sites": [
			{"id": "north", "name": "Đã xây", "built": true, "can_upgrade": true, "can_build": false},
			{"id": "east", "name": "Đất trống", "built": false, "can_build": true, "can_upgrade": false}
		]
	})
	await process_frame
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
		"sites": [
			{"id": "north", "name": "Đã xây", "built": true, "can_upgrade": true, "can_build": false},
			{"id": "east", "name": "Đất trống", "built": false, "can_build": true, "can_upgrade": false}
		]
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
		"candidate": {"id": "cand-1", "name": "Ứng viên", "tam_values": [30, 50, 60], "tu_values": [10, 20, 30, 40]},
		"can_accept": true, "can_reject": true, "can_lead_in": true, "can_recruit": true
	})
	await process_frame
	var candidate_ids: Array[String] = []
	guidance.accept_candidate_requested.connect(func(id: String): candidate_ids.append(id))
	var accept_button := _find_button(guidance, "AcceptCandidate")
	if accept_button == null:
		_fail("Guidance accept control missing.")
		return
	accept_button.pressed.emit()
	if candidate_ids.size() != 1 or candidate_ids[0] != "cand-1":
		_fail("Accept emits candidate key only.")
		return
	var lead_ids: Array[String] = []
	guidance.lead_in_requested.connect(func(id: String): lead_ids.append(id))
	var lead_button := _find_button(guidance, "LeadInCandidate")
	if lead_button == null or lead_button.disabled:
		_fail("Lead-in eligibility must come from the view model.")
		return
	lead_button.pressed.emit()
	var recruit_ids: Array[String] = []
	guidance.recruit_candidate_requested.connect(func(id: String): recruit_ids.append(id))
	var recruit_button := _find_button(guidance, "RecruitCandidate")
	if recruit_button == null or recruit_button.disabled:
		_fail("Recruit eligibility must come from the view model.")
		return
	recruit_button.pressed.emit()
	var page_directions: Array[int] = []
	guidance.candidate_page_requested.connect(func(direction: int): page_directions.append(direction))
	var previous_button := _find_button(guidance, "PreviousCandidate")
	var next_button := _find_button(guidance, "NextCandidate")
	if previous_button == null or next_button == null:
		_fail("Candidate paging controls missing.")
		return
	previous_button.pressed.emit()
	next_button.pressed.emit()
	if lead_ids != ["cand-1"] or recruit_ids != ["cand-1"] or page_directions != [-1, 1]:
		_fail("Lead-in, recruitment and candidate paging must emit only intent data.")
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
	quit(0)
