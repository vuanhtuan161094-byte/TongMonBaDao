extends SceneTree
## End-to-end in-engine B1 host wiring. No sample/gallery fixture state.
const LIVE_B1 = preload("res://src/presentation/uiux/tri_facility_live_adapter_v1.gd")

func _initialize() -> void:
    call_deferred("_run")

func _require(value: bool, reason: String) -> bool:
    if value:
        return true
    push_error("TRI_B1_LIVE_FAIL: " + reason)
    quit(1)
    return false

func _find_button(node: Node, button_name: String) -> Button:
    if node is Button and node.name == button_name:
        return node as Button
    for child in node.get_children():
        var found := _find_button(child, button_name)
        if found != null:
            return found
    return null

func _new_host_adapter(host: Control, state: SimulationState,
        recruitment: RecruitmentSystem, mode: String) -> Control:
    var adapter: Control = LIVE_B1.new()
    adapter.call("configure", host, state, recruitment, mode)
    host.add_child(adapter)
    adapter.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    return adapter

func _run() -> void:
    var state: SimulationState = P37Factory.create_state(20261102)
    state.sect.disciple_v2_birth_enabled = true
    if not _require(bool(SectHallSystemV1.ensure_live(state).get("ok",false)),
            "canonical Hall install"):
        return
    var recruitment := RecruitmentSystem.new()
    var old_hall := DaiDienScreenV1.new()
    old_hall.attach_state(state)
    root.add_child(old_hall)
    var b1_hall := _new_host_adapter(old_hall,state,recruitment,"hall")
    await process_frame
    if not _require(b1_hall.get_node_or_null("OpenCanonicalFacilityManagement") != null
            and b1_hall.find_child("RankSteps",true,false) != null
            and b1_hall.find_child("HallOffices",true,false) != null,
            "B1 Hall not bound to real Hall state"):
        return
    var appointment_candidate: StringName = &""
    var disciple_ids: Array = state.disciples.keys()
    disciple_ids.sort()
    for raw_disciple_id in disciple_ids:
        var possible_id := StringName(str(raw_disciple_id))
        if bool(SectHallSystemV1.can_appoint(state, SectHallSystemV1.OFFICE_MASTER, possible_id).get("ok", false)):
            appointment_candidate = possible_id
            break
    if not _require(appointment_candidate != &"", "canonical office dismissal fixture must have an eligible disciple"):
        return
    if not _require(bool(SectHallSystemV1.appoint(state, SectHallSystemV1.OFFICE_MASTER, appointment_candidate).get("ok", false)),
            "canonical appointment fixture"):
        return
    b1_hall.call("_render")
    await process_frame
    var dismiss := _find_button(b1_hall, "DismissOffice")
    if not _require(dismiss != null and not dismiss.disabled, "B1 dismissal control must reflect the canonical holder"):
        return
    dismiss.pressed.emit()
    await process_frame
    if not _require(SectHallSystemV1.holder_id(state, SectHallSystemV1.OFFICE_MASTER).is_empty(),
            "B1 dismissal must call canonical SectHallSystemV1"):
        return
    var choose := _find_button(b1_hall,"ChooseOffice")
    if not _require(choose != null,"Hall B1 office action absent"):
        return
    choose.pressed.emit()
    await process_frame
    if not _require(old_hall.active_tab == 1,
            "Hall office action must open canonical real appointment screen"):
        return
    root.remove_child(old_hall)
    old_hall.queue_free()
    await process_frame

    var old_housing := DaiDienScreenV1.new()
    old_housing.attach_state(state)
    root.add_child(old_housing)
    old_housing._tab(5)
    var b1_house := _new_host_adapter(old_housing,state,recruitment,"residence")
    await process_frame
    var bed_grid := b1_house.find_child("ResidenceBedSlots",true,false)
    if not _require(bed_grid != null and b1_house.find_child("ResidenceSites",true,false) != null
            and _find_button(b1_house,"BuildSelectedSite") != null
            and b1_house.get_node_or_null("OpenCanonicalFacilityManagement") != null,
            "B1 House not bound to real plots, beds and canonical detail"):
        return
    var room_management := _find_button(b1_house,"ManageResidenceRooms")
    if not _require(room_management != null, "B1 room assignment route missing"):
        return
    room_management.pressed.emit()
    await process_frame
    if not _require(old_housing.active_tab == 5,
            "B1 room-management route must open the canonical assignment screen"):
        return
    root.remove_child(old_housing)
    old_housing.queue_free()
    await process_frame

    var old_guidance := DanTienScreenV2.new()
    old_guidance.attach_state(state,recruitment)
    root.add_child(old_guidance)
    recruitment.ensure_candidate_pool(state, 3)
    var b1_guidance := _new_host_adapter(old_guidance,state,recruitment,"guidance")
    await process_frame
    if not _require(old_guidance.find_child("CandidateDecisionActions",true,false) != null
            and b1_guidance.find_child("CandidateSearch",true,false) is LineEdit
            and _find_button(b1_guidance,"AcceptCandidate") != null
            and _find_button(b1_guidance,"UseRecruitmentOrder") != null,
            "B1 guidance must preserve RC CandidateDecisionActions, candidate search and canonical order control"):
        return
    var candidate_ids: Array = state.recruitment_candidates.keys()
    candidate_ids.sort()
    if not _require(candidate_ids.size() >= 2, "canonical candidate pool fixture must contain searchable choices"):
        return
    var searched_candidate: CandidateState = state.recruitment_candidates[StringName(str(candidate_ids[1]))]
    var search := b1_guidance.find_child("CandidateSearch",true,false) as LineEdit
    search.text = searched_candidate.display_name
    search.text_submitted.emit(search.text)
    await process_frame
    if not _require(str(old_guidance.get("selected_candidate_id")) == str(searched_candidate.id),
            "candidate search selection must flow back to canonical C2 candidate ID"):
        return
    var before := state.disciples.size()
    var accept := _find_button(b1_guidance,"AcceptCandidate")
    if not _require(accept != null and not accept.disabled,
            "B1 accept must use real C2 eligibility"):
        return
    accept.pressed.emit()
    await process_frame
    accept = _find_button(b1_guidance,"AcceptCandidate")
    if not _require(accept != null and accept.text.contains("XÁC NHẬN"),
            "B1 accept must require the visible second confirmation"):
        return
    accept.pressed.emit()
    await process_frame
    if not _require(state.disciples.size() == before+1,
            "B1 accept intent did not mutate the one canonical roster"):
        return
    var reject_ids: Array = state.recruitment_candidates.keys()
    reject_ids.sort()
    if not _require(not reject_ids.is_empty(), "candidate queue must retain a separate rejection choice"):
        return
    var rejected_id := StringName(str(reject_ids[0]))
    var rejected_candidate: CandidateState = state.recruitment_candidates[rejected_id]
    search = b1_guidance.find_child("CandidateSearch",true,false) as LineEdit
    search.text = rejected_candidate.display_name
    search.text_submitted.emit(search.text)
    await process_frame
    var reject := _find_button(b1_guidance,"RejectCandidate")
    if not _require(reject != null and not reject.disabled, "B1 rejection must be enabled for the searched candidate"):
        return
    reject.pressed.emit()
    await process_frame
    reject = _find_button(b1_guidance,"RejectCandidate")
    if not _require(reject != null and reject.text.contains("XÁC NHẬN"),
            "B1 rejection must require visible confirmation"):
        return
    reject.pressed.emit()
    await process_frame
    if not _require(not state.recruitment_candidates.has(rejected_id),
            "confirmed B1 rejection must remove the candidate through canonical C2"):
        return
    var save_path := OS.get_user_data_dir().path_join("tri_b1_adapter_roundtrip_%d.json" % OS.get_process_id())
    if not _require(SaveService.new().save_to_path(state, save_path) == OK,
            "SaveService must persist the canonical state after B1 actions"):
        return
    var restored: SimulationState = SaveService.new().load_from_path(save_path)
    if not _require(restored != null and restored.disciples.size() == state.disciples.size()
            and _sorted_ids(restored.recruitment_candidates) == _sorted_ids(state.recruitment_candidates)
            and SectHallSystemV1.validate(restored).is_empty(),
            "SaveService reload must retain B1 recruitment, queue and Hall state"):
        return
    DirAccess.remove_absolute(save_path)
    root.remove_child(old_guidance)
    old_guidance.queue_free()
    print("TRI_B1_LIVE_PASS hall=1 residence=1 guidance=1 real_recruit=1 save_service_roundtrip=1")
    quit(0)

func _sorted_ids(values: Dictionary) -> Array[String]:
    var ids: Array[String] = []
    for key in values.keys():
        ids.append(str(key))
    ids.sort()
    return ids
