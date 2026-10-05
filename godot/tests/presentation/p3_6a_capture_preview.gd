extends SceneTree

const OUTPUT_PATH := "res://reports/p3_6a_preview.png"

func _init() -> void:
    call_deferred("_capture")

func _capture() -> void:
    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed == null:
        push_error("P3.6A preview capture could not load main scene.")
        quit(1)
        return

    var ui := packed.instantiate() as Control
    if ui == null:
        push_error("P3.6A preview capture could not instantiate main scene.")
        quit(1)
        return

    root.add_child(ui)

    # Give the live scene enough frames to build UI, actors and initial cues.
    for _i in range(12):
        await process_frame

    var reports_dir := ProjectSettings.globalize_path("res://reports")
    DirAccess.make_dir_recursive_absolute(reports_dir)

    var viewport := root.get_viewport()
    if viewport == null:
        push_error("P3.6A preview capture has no viewport.")
        quit(1)
        return

    var image := viewport.get_texture().get_image()
    if image == null or image.is_empty():
        push_error("P3.6A preview capture produced an empty image.")
        quit(1)
        return

    if image.get_width() != 1280 or image.get_height() != 720:
        image.resize(1280, 720, Image.INTERPOLATE_LANCZOS)

    var err := image.save_png(OUTPUT_PATH)
    if err != OK:
        push_error("P3.6A preview PNG save failed: %s" % error_string(err))
        quit(1)
        return

    print("P3.6A PREVIEW CAPTURE PASS")
    print("preview_path=%s" % OUTPUT_PATH)
    ui.queue_free()
    await process_frame
    quit(0)
