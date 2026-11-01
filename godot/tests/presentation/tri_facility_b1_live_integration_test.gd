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
    var bed_grid := b1_house.find_child("ResidenceRooms",true,false)
    if not _require(bed_grid != null and b1_house.find_child("ResidenceSites",true,false) != null
            and _find_button(b1_house,"BuildSelectedSite") != null
            and b1_house.get_node_or_null("OpenCanonicalFacilityManagement") != null,
            "B1 House not bound to real plots, beds and canonical detail"):
        return
    var house_detail := _find_button(b1_house,"OpenCanonicalFacilityManagement")
    house_detail.pressed.emit()
    await process_frame
    if not _require(old_housing.active_tab == 5,
            "House full-management fallback must preserve room assignment"):
        return
    root.remove_child(old_housing)
    old_housing.queue_free()
    await process_frame

    var old_guidance := DanTienScreenV2.new()
    old_guidance.attach_state(state,recruitment)
    root.add_child(old_guidance)
    var b1_guidance := _new_host_adapter(old_guidance,state,recruitment,"guidance")
    await process_frame
    if not _require(old_guidance.find_child("CandidateDecisionActions",true,false) != null
            and _find_button(b1_guidance,"AcceptCandidate") != null
            and _find_button(b1_guidance,"RecruitCandidate") != null,
            "B1 guidance must preserve RC CandidateDecisionActions and order control"):
        return
    var before := state.disciples.size()
    var accept := _find_button(b1_guidance,"AcceptCandidate")
    if not _require(accept != null and not accept.disabled,
            "B1 accept must use real C2 eligibility"):
        return
    accept.pressed.emit()
    await process_frame
    if not _require(state.disciples.size() == before+1,
            "B1 accept intent did not mutate the one canonical roster"):
        return
    var restored: SimulationState = SimulationState.from_dict(state.to_dict())
    if not _require(restored != null and restored.disciples.size() == state.disciples.size()
            and SectHallSystemV1.validate(restored).is_empty(),
            "B1 live recruitment state must survive canonical state serialization"):
        return
    root.remove_child(old_guidance)
    old_guidance.queue_free()
    print("TRI_B1_LIVE_PASS hall=1 residence=1 guidance=1 real_recruit=1 roundtrip=1")
    quit(0)
