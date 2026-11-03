extends SceneTree
## AN-02.1 genuine GUI framebuffer capture, NOT a generated mockup.
## Uses a separate lab scene, never the canonical New Game or SaveService.
const LAB := preload("res://scenes/labs/an02_animation_lab.tscn")
const CAPTURES := "res://outputs/an02_lab/captures"

func _init() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error("AN02_GUI_CAPTURE_FAIL: " + reason)
    quit(1)

func _run() -> void:
    if DisplayServer.get_name() == "headless":
        _fail("GUI rendering required; --headless is not capture evidence")
        return
    var lab := LAB.instantiate()
    root.add_child(lab)
    await process_frame
    if root.size != Vector2i(1280,720):
        _fail("expected 1280x720, observed " + str(root.size))
        return
    var timestamp := Time.get_datetime_string_from_system().replace(":","-")
    var folder := CAPTURES + "/" + timestamp
    if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder)) != OK:
        _fail("could not create capture folder")
        return
    var samples: Array[Dictionary] = [
        {"name":"01_male_source_attack_e","actor":1,"action":3,"direction":0,"shadow":false},
        {"name":"02_shadow_attack_e","actor":0,"action":3,"direction":0,"shadow":true},
        {"name":"03_shadow_attack_w","actor":0,"action":3,"direction":4,"shadow":true},
        {"name":"04_female_idle","actor":2,"action":0,"direction":0,"shadow":false},
        {"name":"05_wolf_walk","actor":3,"action":1,"direction":4,"shadow":false}
    ]
    for sample in samples:
        lab.configure_preview(int(sample["actor"]),int(sample["action"]),
            int(sample["direction"]),bool(sample["shadow"]))
        lab.set_preview_elapsed_for_qa(0.3)
        var proof: Dictionary = lab.sample_evidence()
        if not bool(proof.get("frame_loaded",false)) \
                or float(proof.get("preview_foot_error_px",INF)) > 0.1:
            _fail("missing authentic sprite or anchor drift for " + str(sample["name"]))
            return
        for i in range(5):
            await process_frame
        var image := root.get_texture().get_image()
        if image == null or image.is_empty() \
                or image.get_width() != 1280 or image.get_height() != 720:
            _fail("actual GUI framebuffer missing/incorrect dimensions")
            return
        var save_to := folder + "/" + str(sample["name"]) + ".png"
        if image.save_png(save_to) != OK:
            _fail("could not save actual GUI framebuffer: " + save_to)
            return
        print("AN02_GUI_CAPTURE_IMAGE " + ProjectSettings.globalize_path(save_to))
    print("AN02_GUI_CAPTURE PASS | actual Godot GUI screenshots=5")
    lab.queue_free()
    quit(0)
