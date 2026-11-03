extends SceneTree

const GALLERY = preload("res://scenes/uiux/tri_facility_gallery_b1.tscn")
const SCREEN_NAMES := ["hall", "residence", "guidance"]
const FILE_NAMES := ["b1_dai_dien.png", "b1_de_tu_xa.png", "b1_dan_tien_dai.png"]

func _init() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		push_error("Pass an absolute output directory after --.")
		quit(2)
		return
	var output_dir := args[0]
	DirAccess.make_dir_recursive_absolute(output_dir)
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var gallery := GALLERY.instantiate() as Control
	root.add_child(gallery)
	await process_frame
	await process_frame
	for index in range(SCREEN_NAMES.size()):
		gallery.call("_show_screen", SCREEN_NAMES[index])
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		if image == null or image.is_empty():
			push_error("Godot viewport image is empty.")
			quit(1)
			return
		if image.get_size() != Vector2i(1280, 720):
			push_error("Expected 1280x720 capture, got %s." % image.get_size())
			quit(1)
			return
		var path := output_dir.path_join(FILE_NAMES[index])
		var error := image.save_png(path)
		if error != OK:
			push_error("Could not save screenshot: %s (%s)" % [path, error])
			quit(1)
			return
		print("SCREENSHOT_OK %s %s" % [path, image.get_size()])
	quit(0)
