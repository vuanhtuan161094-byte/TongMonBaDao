extends SceneTree
## AN-03 actual 1280x720 GUI framebuffer captures, NOT AI mockups.
const LAB := preload("res://scenes/labs/an03_modular_rig_lab.tscn")
const DEST := "res://outputs/an03_lab/captures"

func _init() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error("AN03_GUI_CAPTURE_FAIL: " + reason)
    quit(1)

func _run() -> void:
    if DisplayServer.get_name() == "headless":
        _fail("real GUI required")
        return
    var lab = LAB.instantiate()
    root.add_child(lab)
    await process_frame
    if root.size != Vector2i(1280,720):
        _fail("expected 1280x720, got " + str(root.size))
        return
    var folder := DEST + "/" + Time.get_datetime_string_from_system().replace(":","-")
    if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder)) != OK:
        _fail("cannot create isolated capture folder")
        return
    var poses: Array[Dictionary] = [
        {"id":"01_idle_unarmed","clip":"idle","weapon":false,"t":0.45},
        {"id":"02_walk_unarmed","clip":"walk","weapon":false,"t":0.24},
        {"id":"03_attack_unarmed","clip":"attack","weapon":false,"t":0.35},
        {"id":"04_attack_sword_socket","clip":"attack","weapon":true,"t":0.35}
    ]
    for pose in poses:
        lab.configure_for_capture(str(pose["clip"]),bool(pose["weapon"]),float(pose["t"]))
        for _i in range(5):
            await process_frame
        var image := root.get_texture().get_image()
        if image == null or image.get_width() != 1280 or image.get_height() != 720:
            _fail("invalid Godot framebuffer")
            return
        var file := folder + "/" + str(pose["id"]) + ".png"
        if image.save_png(file) != OK:
            _fail("could not save PNG: " + file)
            return
        print("AN03_GUI_IMAGE: " + ProjectSettings.globalize_path(file))
    print("AN03_GUI_CAPTURE PASS | screenshots=4 | GUIDE MODEL only, no owner Shadow mesh")
    lab.queue_free()
    quit(0)
