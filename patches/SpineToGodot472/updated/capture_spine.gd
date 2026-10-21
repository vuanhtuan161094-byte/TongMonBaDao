extends SceneTree
## This file runs only in an EXISTING GODOT 4.5 BUILD WITH SPINE 3.8.
## It does not attempt to parse Spine binary nor simulate a skeleton.
## All inputs live in a temporary copy of the existing working project.

var job: Dictionary = {}
var viewport: SubViewport
var actor: Node2D
var capture_error := ""

func _initialize() -> void:
	call_deferred("_start")

func fail(reason: String) -> void:
	push_error("S2G_BLOCKED: " + reason)
	print("S2G_BLOCKED: ", reason)
	quit(2)

func has_prop(obj: Object, key: String) -> bool:
	for item in obj.get_property_list():
		if str(item.get("name", "")) == key:
			return true
	return false

func object_has_method(obj: Object, key: String) -> bool:
	for item in obj.get_method_list():
		if str(item.get("name", "")) == key:
			return true
	return false

func set_if_present(obj: Object, names: Array, val: Variant) -> bool:
	for key in names:
		if has_prop(obj, str(key)):
			obj.set(str(key), val)
			return true
	return false

func find_spine(node: Node) -> Node:
	if node.is_class("SpineSprite") or node.get_class() == "SpineSprite":
		return node
	for child in node.get_children():
		var result = find_spine(child)
		if result != null:
			return result
	return null

func _bind_new_sources(sp: Node) -> bool:
	for cls in ["SpineSkeletonFileResource", "SpineAtlasResource", "SpineSkeletonDataResource"]:
		if not ClassDB.class_exists(cls):
			return false
	var skeleton_resource = ClassDB.instantiate("SpineSkeletonFileResource")
	var atlas_resource = ClassDB.instantiate("SpineAtlasResource")
	if skeleton_resource == null or atlas_resource == null:
		return false
	if skeleton_resource.call("load_from_file", str(job["skel"])) != OK:
		print("S2G_HINT: skeleton load failed")
		return false
	if atlas_resource.call("load_from_atlas_file", str(job["atlas"])) != OK:
		print("S2G_HINT: atlas load failed")
		return false
	var data = ClassDB.instantiate("SpineSkeletonDataResource")
	if data == null:
		return false
	if not set_if_present(data, ["atlas_res", "atlas_resource"], atlas_resource):
		print("S2G_HINT: Cannot bind atlas to SpineSkeletonDataResource")
		return false
	if not set_if_present(data, ["skeleton_file_res", "skeleton_file_resource"], skeleton_resource):
		print("S2G_HINT: Cannot bind skel to SpineSkeletonDataResource")
		return false
	if not set_if_present(sp, ["skeleton_data_res", "skeleton_data_resource"], data):
		print("S2G_HINT: Cannot bind data to SpineSprite")
		return false
	return true

func _apply_source_skin(sp: Node) -> bool:
	var skeleton = sp.call("get_skeleton")
	if skeleton == null:
		return false
	var data = sp.get("skeleton_data_res")
	if data == null:
		return false
	var all_skins: Array = data.call("get_skins")
	var requested: Array = job.get("skins", [])
	if not requested.is_empty():
		var by_name: Dictionary = {}
		for skin in all_skins:
			by_name[str(skin.call("get_name"))] = skin
		var selected: Array = []
		for requested_name in requested:
			var skin_name := str(requested_name)
			if not by_name.has(skin_name):
				print("S2G_HINT: requested skin not found: ", skin_name)
				return false
			selected.append(by_name[skin_name])
		if selected.size() == 1:
			skeleton.call("set_skin", selected[0])
		else:
			var combined = sp.call("new_skin", "s2g_requested_combination")
			for skin in selected:
				combined.call("add_skin", skin)
			skeleton.call("set_skin", combined)
		skeleton.call("set_to_setup_pose")
		print("S2G_SKIN_SELECTED ", JSON.stringify(requested))
		return true
	var body: Object = null
	var extras: Array = []
	for skin in all_skins:
		var n := str(skin.call("get_name"))
		var lower := n.to_lower()
		if lower.begins_with("body_"):
			body = skin
		elif lower.begins_with("face_") or lower.begins_with("head_"):
			extras.append(skin)
	if body != null and not extras.is_empty():
		var combined = sp.call("new_skin", "s2g_body_face_head")
		combined.call("add_skin", body)
		for skin in extras:
			combined.call("add_skin", skin)
		skeleton.call("set_skin", combined)
		print("S2G_SKIN: combined body + ", extras.size(), " face/head")
		var default_selection: Array = [str(body.call("get_name"))]
		for skin in extras:
			default_selection.append(str(skin.call("get_name")))
		print("S2G_SKIN_SELECTED ", JSON.stringify(default_selection))
	elif body != null:
		skeleton.call("set_skin_by_name", str(body.call("get_name")))
		print("S2G_SKIN: ", body.call("get_name"))
		print("S2G_SKIN_SELECTED ", JSON.stringify([str(body.call("get_name"))]))
	else:
		print("S2G_SKIN: default")
		print("S2G_SKIN_SELECTED [\"default\"]")
	skeleton.call("set_to_setup_pose")
	return true

func _prepare_actor() -> Node2D:
	if not ClassDB.class_exists("SpineSprite"):
		capture_error = "SpineSprite class absent in Godot 4.5 native runtime; use the existing working trial executable"
		return null
	var template_path = str(job.get("template_scene", ""))
	var sp: Node = null
	var root_node: Node2D
	if template_path != "":
		var packed = ResourceLoader.load(template_path)
		if not (packed is PackedScene):
			capture_error = "Template scene not available: " + template_path
			return null
		var instance = packed.instantiate()
		if not (instance is Node2D):
			capture_error = "Template scene root must be Node2D"
			instance.free()
			return null
		root_node = instance
		sp = find_spine(root_node)
		if sp == null:
			capture_error = "Template scene has no SpineSprite"
			root_node.free()
			return null
	else:
		root_node = Node2D.new()
		sp = ClassDB.instantiate("SpineSprite")
		if sp == null:
			capture_error = "Cannot instantiate SpineSprite"
			root_node.free()
			return null
		root_node.add_child(sp)
	# NEVER allow the template's old rig to be captured as if it were the user input.
	# Rebinding both input resources is a required safety gate.
	if not _bind_new_sources(sp):
		capture_error = "Could not rebind BOTH new Spine .skel and .atlas; refusing template fallback"
		root_node.free()
		return null
	return root_node

func _set_clip(sp: Node, clip_name: String) -> bool:
	if not object_has_method(sp, "get_animation_state"):
		print("S2G_HINT: SpineSprite has no get_animation_state method")
		return false
	var state: Object = sp.call("get_animation_state")
	if state == null or not object_has_method(state, "set_animation"):
		return false
	var specs: Dictionary = {}
	for m in state.get_method_list():
		if str(m.get("name")) == "set_animation":
			specs = m
			break
	var specs_args: Array = specs.get("args", [])
	if specs_args.size() < 3:
		return false
	var v: Array
	# Spine-Godot commonly uses (animation:String, loop:bool, track:int)
	# Some variants expose (track:int, animation:String, loop:bool).
	if int(specs_args[0].get("type", TYPE_NIL)) == TYPE_INT:
		v = [0, clip_name, true]
	else:
		v = [clip_name, true, 0]
	if object_has_method(state, "clear_tracks"):
		state.call("clear_tracks")
	state.callv("set_animation", v)
	print("S2G_SELECTED_CLIP ", clip_name)
	return true

func _start() -> void:
	var file = FileAccess.open("res://__s2g_job.json", FileAccess.READ)
	if file == null:
		fail("Missing conversion job JSON")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		fail("Invalid job JSON")
		return
	job = parsed
	viewport = SubViewport.new()
	viewport.name = "S2G_Transparent_Capture"
	viewport.size = Vector2i(int(job["canvas_width"]), int(job["canvas_height"]))
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	actor = _prepare_actor()
	if actor == null:
		fail(capture_error)
		return
	viewport.add_child(actor)
	actor.position = Vector2(float(job["foot_x"]), float(job["foot_y"]))
	# Native runtime must be allowed to initialize AFTER entering the scene tree.
	await process_frame
	await process_frame
	var sp = find_spine(actor)
	if sp == null:
		fail("Cannot find SpineSprite after insertion")
		return
	if not _apply_source_skin(sp):
		fail("Cannot apply source skin")
		return
	var clips: Array = job["clips"]
	for clip in clips:
		var name: String = str(clip["name"])
		if not _set_clip(sp, name):
			fail("Cannot set Spine clip: " + name)
			return
		var path = str(job["output"]).path_join(name)
		DirAccess.make_dir_recursive_absolute(path)
		for i in range(int(clip["frames"])):
			# Sample at the middle of each output frame. This avoids missing t=0
			# and wrapping the final frame of a looping source clip to its start.
			# Host runs at fps*4: first sample after 2 ticks, then every 4.
			var ticks: int = 2 if i == 0 else 4
			for _step in range(ticks):
				await process_frame
			await RenderingServer.frame_post_draw
			var image: Image = viewport.get_texture().get_image()
			if image == null or image.is_empty():
				fail("SubViewport returned empty image; native capture not supported")
				return
			if image.get_format() != Image.FORMAT_RGBA8:
				image.convert(Image.FORMAT_RGBA8)
			var target: String = path.path_join("%04d.png" % i)
			if image.save_png(target) != OK:
				fail("Unable to save frame: " + target)
				return
		print("S2G_CLIP_CAPTURED ", name, " frames=", clip["frames"])
	print("S2G_CAPTURE_PASS")
	quit(0)

