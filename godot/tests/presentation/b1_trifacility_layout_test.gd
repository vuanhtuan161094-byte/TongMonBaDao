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
		# The gallery reserves a 52px tab bar; content height is 668px at 1280x720.
		# Compare against the actual host rather than demanding a 680px child.
		var host := gallery.get("_screen_host") as Control
		if screen == null or host == null or screen.size.x < 1200.0 \
				or screen.size.distance_to(host.size) > 2.0 or host.size.y < gallery.size.y - 60.0:
			_fail("%s must fill the usable 1280x720 gallery content area." % screen_name)
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
				var action_rect: Rect2 = action.get_global_rect()
				if not action.is_visible_in_tree() or not visible_rect.encloses(action_rect) \
						or action_rect.size.x < 48.0 or action_rect.size.y < 40.0:
					_fail("Residence action is clipped or too small: %s" % action.name)
					return
	var notice: Label = gallery.get("_notice")
	if notice == null or not notice.text.contains("PREVIEW") or not notice.text.contains("DỮ LIỆU MẪU"):
		_fail("Preview must disclose fixture data in the visible footer.")
		return
	quit(0)
