extends SceneTree
## Captures the real 1280x720 Godot GUI scene. Missing-model state is evidence, not a mock character.
const LAB := preload("res://scenes/labs/shadow_3d_animation_lab.tscn")

func _init() -> void:
	call_deferred("_run")

func _fail(reason: String) -> void:
	push_error("SHADOW_3D_GUI_CAPTURE_FAIL: " + reason)
	quit(1)

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("GUI rendering is required; headless output is not screenshot evidence")
		return
	var lab := LAB.instantiate()
	root.add_child(lab)
	await process_frame
	if root.size != Vector2i(1280, 720):
		_fail("expected 1280x720, got %s" % str(root.size))
		return
	var evidence: Dictionary = lab.qa_snapshot()
	if evidence.get("status", "") != "BLOCKED_BY_TRIPO_ASSET" or evidence.get("model_loaded", true):
		_fail("expected honest missing-model state, got %s" % str(evidence))
		return
	for index in range(4):
		await process_frame
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_width() != 1280 or image.get_height() != 720:
		_fail("could not read the actual 1280x720 framebuffer")
		return
	var folder := "res://outputs/issue70/shadow_3d_lab"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var path := folder.path_join("shadow_3d_lab_blocked_by_tripo_asset.png")
	if image.save_png(path) != OK:
		_fail("could not save actual Godot GUI screenshot")
		return
	print("SHADOW_3D_GUI_CAPTURE_IMAGE " + ProjectSettings.globalize_path(path))
	print("SHADOW_3D_GUI_CAPTURE PASS | actual Godot GUI 1280x720 | status=BLOCKED_BY_TRIPO_ASSET")
	quit(0)

