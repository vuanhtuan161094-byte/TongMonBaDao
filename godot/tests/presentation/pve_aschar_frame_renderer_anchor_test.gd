extends SceneTree

const ASCHAR := preload("res://src/presentation/p3/pve_aschar_frame_renderer_v1.gd")
const BRIDGE := preload("res://src/presentation/p3/sect_aschar_candidate_bridge_v1.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scale := ASCHAR.game_view_scale(1.0)
	if not is_equal_approx(scale, 0.22):
		_fail("1x scale did not resolve to the shared PvE world scale")
		return
	if not is_equal_approx(ASCHAR.game_view_scale(1.5), 0.33):
		_fail("spectator zoom was not applied to the shared actor scale")
		return
	var foot := Vector2(420.0, 500.0)
	var body_count := 0
	for school in BRIDGE.SCHOOL_IDS:
		var manifest := ASCHAR._manifest(BRIDGE.actor_id(str(school), "male"))
		if manifest.is_empty():
			_fail("candidate AS-CHAR manifest is missing for " + str(school))
			return
		var body := ASCHAR.resolve_preview_anchor(str(school), "male", "idle", Vector2.RIGHT,
			0.0, foot, scale, "body_center")
		if not bool(body.get("ok", false)) or not (body.get("position", null) is Vector2):
			_fail("metadata-backed body anchor did not resolve for " + str(school) + ": " + str(body))
			return
		var resolved_foot := ASCHAR.resolve_preview_anchor(str(school), "male", "idle", Vector2.RIGHT,
			0.0, foot, scale, "foot")
		if not bool(resolved_foot.get("ok", false)) or resolved_foot.get("position") != foot:
			_fail("foot anchor did not preserve the world foot pivot for " + str(school))
			return
		body_count += 1

	var dao_override := {
		"asset_id": "curved_dao",
		"anchor_slot": "main_hand",
		"asset_scale": 0.68,
		"align_tip_to_direction": Vector2.RIGHT,
		"restore_hand_slots": ["main_hand"]
	}
	var anchors := ASCHAR.resolve_preview_anchors("blade", "male", "attack", Vector2.RIGHT,
		0.14, foot, scale, 0.28, dao_override)
	var grip: Dictionary = anchors.get("weapon_grip", {})
	var tip: Dictionary = anchors.get("weapon_tip", {})
	if not bool(anchors.get("ok", false)) or not bool(grip.get("ok", false)) or not bool(tip.get("ok", false)):
		_fail("candidate curved-DAO grip/tip did not resolve from existing socket and weapon metadata: " + str(anchors))
		return
	if str(tip.get("asset_id", "")) != "curved_dao" or str(grip.get("asset_id", "")) != "curved_dao":
		_fail("resolved weapon anchors lost their candidate asset identity")
		return
	if float(tip["tip_position"].x) <= float(grip["grip_position"].x):
		_fail("aligned candidate DAO tip does not point toward the target")
		return
	if not is_equal_approx(float(tip.get("weapon_scale", 0.0)), 0.68):
		_fail("preview weapon scale override did not resolve through the renderer")
		return
	if not anchors.has("main_hand") or not anchors.has("off_hand") or not anchors.has("hand_r") or not anchors.has("hand_l"):
		_fail("selected actor socket entries are missing from the plural resolver")
		return
	var no_props := ASCHAR.resolve_preview_anchors("bow", "male", "attack", Vector2.RIGHT,
		0.14, foot, scale, 0.28, {"suppress_attachments":true})
	if not bool(no_props.get("attachments_suppressed",false)) or no_props.has("weapon_tip"):
		_fail("unverified bow attachments were not cleanly suppressed")
		return

	print("ASCHAR_RENDERER_ANCHOR_PASS schools=%d game_scale=0.22 actor_metadata=12/12 weapon=curved_dao tip_right=true suppress=PASS" % body_count)
	quit(0)

func _fail(reason: String) -> void:
	printerr("ASCHAR_RENDERER_ANCHOR_FAIL " + reason)
	quit(1)
