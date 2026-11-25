extends SceneTree
## Focused 1280x720 Godot capture of the real candidate actor + MapBattleV2 LAB.

const SCENE_PATH := "res://labs/combat_lab/spear01/van_long_diem_thuy/r1/van_long_diem_thuy_preview.tscn"
const OUTPUT_PATH := "res://labs/combat_lab/spear01/van_long_diem_thuy/r1/evidence/van_long_diem_thuy_two_receipts_1280x720.png"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("SPEAR_LONG_THRUST_NATIVE_CAPTURE started")
	root.size = Vector2i(1280,720)
	var packed := load(SCENE_PATH) as PackedScene
	if packed == null:
		_fail("preview PackedScene did not load")
		return
	var preview := packed.instantiate() as Control
	if preview == null:
		_fail("preview Control did not instantiate")
		return
	root.add_child(preview)
	for _frame in range(60):
		await process_frame
	print("SPEAR_LONG_THRUST_NATIVE_CAPTURE frames_done")
	if str(preview.get("run_state")) != "CONFIRMED_TWO_TARGET_RELEASE":
		_fail("live preview did not reach two confirmed receipts: " + str(preview.get("run_error")))
		return
	var receipts: Array = preview.get("receipts")
	if receipts.size() != 2:
		_fail("preview recorded %d line receipts, expected exactly two" % receipts.size())
		return
	var battle: MapBattleV2 = preview.get("battle")
	if battle == null or battle.actors.is_empty():
		_fail("preview has no actual MapBattleV2 actors")
		return
	if not bool(preview.get("aschar_draw_success")):
		_fail("candidate AS54 actor renderer returned false")
		return
	var source_draws: Dictionary = preview.get("source_draw_success_by_actor")
	for target_id in ["spear_lab_target_01","spear_lab_target_02","spear_lab_outside"]:
		if not bool(source_draws.get(target_id,false)):
			_fail("Source A placeholder actor renderer returned false for " + target_id)
			return
	var viewport := root.get_viewport()
	if DisplayServer.get_name() == "headless":
		print("SPEAR_LONG_THRUST_NATIVE_CAPTURE BLOCKED display_driver=headless_dummy framebuffer_readback=unavailable; runtime scene and target receipts passed")
		quit(2)
		return
	var viewport_texture: Texture2D = viewport.get_texture() if viewport != null else null
	if viewport_texture == null:
		print("SPEAR_LONG_THRUST_NATIVE_CAPTURE BLOCKED display_driver=%s framebuffer_readback=unavailable; runtime scene and target receipts passed" % DisplayServer.get_name())
		quit(2)
		return
	await RenderingServer.frame_post_draw
	var image := viewport_texture.get_image()
	if image == null or image.get_size() != Vector2i(1280,720):
		_fail("native viewport capture is not 1280x720")
		return
	var output := ProjectSettings.globalize_path(OUTPUT_PATH)
	if image.save_png(output) != OK:
		_fail("could not save native capture")
		return
	print("SPEAR_LONG_THRUST_NATIVE_CAPTURE PASS size=1280x720 line_receipts=2 target_limit=2 runtime=MapBattleV2 actor_art=AS54_CANDIDATE enemy_runtime=MonsterCatalogueV2 pvE=OFF path=" + OUTPUT_PATH)
	quit(0)

func _fail(message: String) -> void:
	push_error("SPEAR_LONG_THRUST_NATIVE_CAPTURE FAIL " + message)
	quit(1)
