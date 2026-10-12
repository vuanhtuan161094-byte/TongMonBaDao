extends SceneTree

func _initialize() -> void:
	var names := ["SpineSprite", "SpineSkeletonFileResource", "SpineAtlasResource", "SpineAnimationState"]
	var found := false
	for name in names:
		var present := ClassDB.class_exists(name)
		found = found or present
		print("SPINE_RUNTIME_CLASS ", name, "=", present)
	print("SPINE_RUNTIME_AVAILABLE=", found)
	quit(0 if found else 4)