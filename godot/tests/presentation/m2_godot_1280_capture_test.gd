extends SceneTree

# Run with the Godot GUI executable (not --headless). The PNG is captured
# from the real 1280x720 project viewport into the isolated user:// sandbox.
const CAPTURE_PATH := "user://demo_sandbox/m2_combat_1280x720.png"
const SAVE_PATH := "user://demo_sandbox/m2_capture_save.json"
const WIDTH := 1280
const HEIGHT := 720

func _init() -> void:
	call_deferred("_run")

func _check(ok: bool, detail: String) -> bool:
	if not ok:
		push_error("M2 GODOT VIEWPORT CAPTURE: " + detail)
		quit(1)
		return false
	return true

func _run() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(WIDTH, HEIGHT))
	ProjectSettings.set_setting("runtime/live_save_path", SAVE_PATH)
	ProjectSettings.set_setting("demo/quick_hunt", false)
	var built := DemoSandboxFactoryV1.create_max_state(DemoSandboxFactoryV1.SEED)
	if not _check(bool(built.get("ok", false)), "canonical DEMO MAX state could not be created"):
		return
	# The canonical DEMO MAX factory learns only what its existing P2 stage
	# allows. For this focused visual proof, advance one sandbox hunter through
	# the same legal stage gate and call the real learn_skill API.
	var state: SimulationState = built["state"]
	var skill_demo_id := StringName(str(built["hunter_ids"][1]))
	var skill_demo_hunter: DiscipleState = state.disciples[skill_demo_id]
	skill_demo_hunter.cultivation_stage_index = 9
	var skill_system := CombatSkillSystem.new()
	if not _check(skill_system.learn_skill(state, skill_demo_hunter, &"ngu_kiem_thuat") and
		&"ngu_kiem_thuat" in skill_system.usable_skills(state, skill_demo_hunter),
		"existing P2 stage gate did not permit the focused learned-skill visual fixture"):
		return
	var owned_damage_skills := ["ngu_kiem_thuat", "thanh_phong_tram"]
	var capture_policy := AutoSkillPolicyV2.default_policy(owned_damage_skills)
	for policy_row in capture_policy["skills"]:
		if str(policy_row["canonical_skill_id"]) == "ngu_kiem_thuat":
			policy_row["enabled"] = true
			policy_row["conditions"]["target_tiers"] = ["boss"]
		elif str(policy_row["canonical_skill_id"]) == "thanh_phong_tram":
			policy_row["enabled"] = false
	var saved_policy := DemoAutoSkillPolicyStoreV1.save_policy(
		str(skill_demo_id), owned_damage_skills, capture_policy)
	if not _check(bool(saved_policy.get("ok", false)), "isolated combat screenshot policy could not be saved"):
		return
	var loaded_policy := DemoAutoSkillPolicyStoreV1.load_policy(str(skill_demo_id), owned_damage_skills)
	if not _check(loaded_policy.get("skills", [])[0].get("conditions", {}).get("target_tiers", []) == ["boss"],
		"JSON round-trip did not preserve the configured Boss-only skill target condition"):
		return
	var directory_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://demo_sandbox"))
	if not _check(directory_error == OK or directory_error == ERR_ALREADY_EXISTS, "isolated demo folder could not be created"):
		return
	if not _check(SaveService.new().save_to_path(built["state"], SAVE_PATH) == OK, "isolated DEMO MAX save failed"):
		return
	ProjectSettings.set_setting("demo/hunter_ids", built["hunter_ids"])
	var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
	if not _check(packed != null, "P3.2 scene could not be loaded"):
		return
	var sect := packed.instantiate()
	get_root().add_child(sect)
	for _frame in range(6):
		await process_frame
	if not _check(bool(sect.get("runtime_ready")), "P3.2 live runtime did not start"):
		return
	sect.call("_bottom_action", "world")
	for _frame in range(2):
		await process_frame
	var holder := sect.get("popup_layer") as Control
	var panel := holder.get_node_or_null("LiveHuntingPveV2") as HuntingPlayPanelV2 if holder != null else null
	if not _check(panel != null, "real hunting panel did not open"):
		return
	panel.selected_level = 5
	panel.level_choice.select(4)
	for raw_id in built["hunter_ids"]:
		panel.chosen[str(raw_id)] = true
	panel._launch()
	if not _check(panel.session != null and panel.session.battle != null and panel.session.battle.continuous_world,
		"DEMO MAX did not enter a live continuous Combat V2 hunt"):
		return
	panel.set_process(false)
	var battle: MapBattleV2 = panel.session.battle
	var saw_skill_cast := false
	var saw_basic_hit := false
	for tick in range(100):
		if not battle.active:
			break
		var advanced := panel.session.advance(true)
		if not _check(bool(advanced.get("ok", false)), "live Combat V2 step failed"):
			return
		panel.battle_layer.refresh_from_authority()
		for event in battle.events:
			if str(event.get("type", "")) == "skill_cast" and str(event.get("skill_id", "")) == "ngu_kiem_thuat":
				saw_skill_cast = true
			if str(event.get("type", "")) == "hit" and str(event.get("kind", "")) == "basic":
				saw_basic_hit = true
		for _frame in range(2):
			await process_frame
		var saw_cast_fx := false
		for cue in panel.battle_layer._effect_cues:
			if str(cue.get("kind", "")) == "sword_cast":
				saw_cast_fx = true
		if saw_skill_cast and saw_basic_hit and saw_cast_fx:
			break
	if not _check(saw_skill_cast and saw_basic_hit,
		"actual learned skill cast and basic attack were not both present in combat events"):
		return
	var rendered_cast_fx := false
	for cue in panel.battle_layer._effect_cues:
		if str(cue.get("kind", "")) == "sword_cast":
			rendered_cast_fx = true
	if not _check(rendered_cast_fx, "actual Ngu Kiem Thuat skill cast did not create its mapped source cue"):
		return
	var camera_before: Vector2 = panel.battle_layer._camera_center
	panel.battle_layer.pan_camera_pixels(Vector2(94.0, 26.0))
	if not _check(panel.battle_layer._camera_center.distance_to(camera_before) > 0.1 and
		panel.battle_layer.current_camera_follow_id().is_empty(), "free camera drag did not move the view independently"):
		return
	for _frame in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	var image := get_root().get_texture().get_image()
	if not _check(image != null and image.get_size() == Vector2i(WIDTH, HEIGHT),
		"actual Godot viewport is not exactly 1280x720: " + str(image.get_size() if image != null else Vector2i.ZERO)):
		return
	if not _check(image.save_png(CAPTURE_PATH) == OK, "real viewport PNG could not be saved into the isolated demo sandbox"):
		return
	print("M2 GODOT VIEWPORT CAPTURE: PASS path=" + CAPTURE_PATH + " size=1280x720" +
		" waves=" + str(battle.world_waves_completed) + " camera=free" +
		" skill=ngu_kiem_thuat cast_vfx=PASS basic=PASS")
	quit(0)
