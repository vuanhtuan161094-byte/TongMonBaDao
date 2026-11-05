extends SceneTree

const GALLERY = preload("res://scenes/uiux/tri_facility_gallery_b1.tscn")

func _init() -> void:
	call_deferred("_run")

func _fail(message: String) -> void:
	push_error("B1 UI layout: " + message)
	quit(1)

func _run() -> void:
	var packed := GALLERY
	var gallery := packed.instantiate() as Control
	root.add_child(gallery)
	gallery.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await process_frame
	await process_frame
	for screen_name in ["hall", "residence", "guidance"]:
		gallery.call("_show_screen", screen_name)
		await process_frame
		await process_frame
		var screen: Control = gallery.get("_active_screen")
		if screen == null or screen.size.x < 1200.0 or screen.size.y < 680.0:
			_fail("%s must occupy the 1280x720 preview viewport." % screen_name)
			return
		if not screen.is_visible_in_tree():
			_fail("%s did not render as the active screen." % screen_name)
			return
		# Regression for the 720p overflow reported in the real Residence screenshot.
		# These primary actions must remain fully visible, not merely present in the tree.
		if screen_name == "residence":
			var footer := screen.find_child("ResidenceStickyActions", true, false) as Control
			var manage := screen.find_child("ManageResidenceRooms", true, false) as Button
			var assign := screen.find_child("AssignResidenceRoom", true, false) as Button
			if footer == null or manage == null or assign == null:
				_fail("Residence primary-action footer or buttons are missing.")
				return
			var visible_rect := screen.get_global_rect()
			for action in [manage, assign]:
				var action_rect := action.get_global_rect()
				if not action.is_visible_in_tree() or not visible_rect.encloses(action_rect) \
						or action_rect.size.x < 48.0 or action_rect.size.y < 40.0:
					_fail("Residence action is clipped or too small: %s" % action.name)
					return
	var notice: Label = gallery.get("_notice")
	if notice == null or not notice.text.contains("PREVIEW") or not notice.text.contains("DỮ LIỆU MẪU"):
		_fail("Preview must disclose fixture data in the visible footer.")
		return
	quit(0)
