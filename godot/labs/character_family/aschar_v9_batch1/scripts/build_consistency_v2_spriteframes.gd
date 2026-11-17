extends SceneTree

func _initialize() -> void:
	for identity in ["AS48", "AS49"]:
		var sprite_frames := SpriteFrames.new()
		sprite_frames.clear_all()
		for clip in ["walk_front", "attack_front"]:
			var texture_path := "res://assets/atlases/%s_%s_consistency_v2_atlas.png" % [identity, clip]
			var texture: Texture2D = load(texture_path)
			if texture == null:
				push_error("ATLAS_IMPORT_MISSING=" + texture_path)
				quit(2)
				return
			var animation_name := "Walk_Front" if clip == "walk_front" else "Attack_Front"
			sprite_frames.add_animation(animation_name)
			sprite_frames.set_animation_speed(animation_name, 8.0 if clip == "walk_front" else 7.0)
			sprite_frames.set_animation_loop(animation_name, clip == "walk_front")
			for i in range(4):
				var frame := AtlasTexture.new()
				frame.atlas = texture
				frame.region = Rect2(i * 400, 0, 400, 440)
				sprite_frames.add_frame(animation_name, frame)
		var target := "res://assets/spriteframes/%s_V9_consistency_v2.tres" % identity
		var error := ResourceSaver.save(sprite_frames, target)
		if error != OK:
			push_error("SPRITEFRAMES_SAVE_FAIL=" + target + " error=" + str(error))
			quit(3)
			return
	print("ASCHAR_V9_CONSISTENCY_SPRITEFRAMES=PASS identities=2 clips=4 frames=16 fps=walk8_attack7 source=corrected_atlases")
	quit(0)
