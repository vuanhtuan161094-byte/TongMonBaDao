extends SceneTree

const ResolverScript = preload("res://labs/character_family/as_char38/as_char38_family_resolver.gd")
const PreviewScene = preload("res://labs/character_family/as_char38/as_char38_preview.tscn")
const FemaleFrames: SpriteFrames = preload("res://labs/character_family/as_char38/assets/novice_female.spriteframes.tres")
const MaleFrames: SpriteFrames = preload("res://labs/character_family/as_char38/assets/novice_male.spriteframes.tres")
var _failures := 0
var _checks := 0


func _initialize() -> void:
	call_deferred("_run_checks")


func _run_checks() -> void:
	var resolver = ResolverScript.new()
	var registry: Dictionary = resolver.load_registry()
	_check(registry.size() > 0, "registry loads")
	_check(registry.get("group_count", 0) == 38, "38 design groups exist")
	var groups: Array = registry.get("groups", [])
	_check(groups.size() == 38, "38 registry rows exist")

	var novice_female: Dictionary = resolver.resolve_identity({
		"disciple_id": "godot.smoke.female",
		"sex_id": "female",
		"profile_seed": 321
	}, registry)
	_check(novice_female.get("render_group_id") == "tmb.as_char38.novice.female", "female novice resolves")

	var novice_male: Dictionary = resolver.resolve_identity({
		"disciple_id": "godot.smoke.male",
		"sex_id": "male"
	}, registry)
	_check(novice_male.get("render_group_id") == "tmb.as_char38.novice.male", "male novice resolves")

	var poison: Dictionary = resolver.resolve_identity({
		"disciple_id": "godot.smoke.poison",
		"sex_id": "female",
		"v63_combat_branch_id": "tmb.path.poison.doc_cham"
	}, registry)
	_check(poison.get("selected_group_id") == "tmb.as_char38.branch.poison.doc_cham", "known branch maps exactly")
	_check(poison.get("render_group_id") == "tmb.as_char38.novice.female", "pending branch uses truthful novice fallback")
	_check(poison.get("status") == "ART_PENDING_FALLBACK_NOVICE", "pending status remains visible")

	var unknown: Dictionary = resolver.resolve_identity({
		"disciple_id": "godot.smoke.unknown",
		"sex_id": "male",
		"v63_combat_branch_id": "tmb.path.unknown.fake"
	}, registry)
	_check(unknown.get("status") == "UNKNOWN_BRANCH_FALLBACK_NOVICE", "unknown branch is not reassigned")
	_check(unknown.get("selected_group_id", "") == "", "unknown branch has no selected design group")

	var same_seed: Dictionary = resolver.resolve_identity({
		"disciple_id": "godot.smoke.female",
		"sex_id": "female",
		"profile_seed": 321
	}, registry)
	_check(same_seed.get("appearance_seed") == novice_female.get("appearance_seed"), "appearance seed is stable")
	_check(novice_female.get("simulation_mutated") == false, "resolver is read only")
	_check_static_direction_frames(FemaleFrames, "female")
	_check_static_direction_frames(MaleFrames, "male")

	var preview: Control = PreviewScene.instantiate()
	get_root().add_child(preview)
	await process_frame
	var checker := preview.find_child("TransparencyCheckerboard", true, false) as TextureRect
	var preview_sprite := preview.find_child("StaticPoseCandidate", true, false) as AnimatedSprite2D
	_check(checker != null, "preview has an alpha checkerboard")
	_check(preview.find_child("FootBaseline", true, false) is ColorRect, "preview shows the registered foot baseline")
	_check(preview.find_child("FootPivotMarker", true, false) is ColorRect, "preview shows the atlas foot pivot")
	_check(preview_sprite != null, "preview instantiates AnimatedSprite2D")
	if preview_sprite:
		_check(not preview_sprite.is_playing(), "one-frame idle remains a static pose")
		preview.call("_set_detail_zoom", 6.0)
		await process_frame
		_check(is_equal_approx(preview_sprite.scale.x, 6.0), "preview exposes the requested six-times detail view")
		if checker:
			var stage := checker.get_parent() as Control
			_check(preview_sprite.position.y - 70.0 * 6.0 >= 0.0, "six-times detail view keeps the visible body inside the stage")
			_check(preview_sprite.position.y <= stage.size.y - 10.0, "foot baseline stays inside the stage")
	preview.queue_free()

	print("AS_CHAR38_GODOT_CHECKS=%d failures=%d" % [_checks, _failures])
	quit(1 if _failures > 0 else 0)


func _check_static_direction_frames(frames: SpriteFrames, family: String) -> void:
	for direction in ["front", "right", "back", "left"]:
		var animation := "idle_" + direction
		_check(frames.has_animation(animation), "%s %s frame exists" % [family, direction])
		if frames.has_animation(animation):
			_check(frames.get_frame_count(animation) == 1, "%s %s remains one authored static frame" % [family, direction])
	for clip in ["walk", "cast", "attack", "hit", "death"]:
		_check(not frames.has_animation(clip), "%s %s is not fabricated" % [family, clip])


func _check(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		return
	_failures += 1
	push_error("AS_CHAR38_FAIL: " + label)
