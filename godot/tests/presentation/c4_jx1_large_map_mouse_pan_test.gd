extends SceneTree

# Official Windows focused G1/C4 viewport input contract. Instantiates the
# REAL G1 192x192 map in user:// isolation; no player save is opened.
func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, why: String) -> bool:
    if not ok:
        push_error("C4-JX1 FREE CAMERA: "+why)
        quit(1)
    return ok

func _run() -> void:
    ProjectSettings.set_setting("runtime/live_save_path",
        "user://c4_jx1_pan_%d.json" % Time.get_ticks_usec())
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if not _check(scene != null,"G1 production scene missing"):
        return
    var sect := scene.instantiate()
    get_root().add_child(sect)
    if not _check(bool(sect.get("runtime_ready")),"real G1 runtime unavailable"):
        return
    var original: Vector2 = (sect.get("map_layer") as Control).position
    # Real GUI dispatch, NOT _unhandled_input that default Control swallows.
    var press := InputEventMouseButton.new()
    press.button_index = MOUSE_BUTTON_LEFT
    press.position = Vector2(635,385)
    press.pressed = true
    sect.call("_on_map_gui_input",press)
    var drag := InputEventMouseMotion.new()
    drag.position = Vector2(745,400)
    drag.relative = Vector2(110,15)
    drag.button_mask = MOUSE_BUTTON_MASK_LEFT
    sect.call("_on_map_gui_input",drag)
    var traveled: Vector2 = (sect.get("map_layer") as Control).position
    if not _check(traveled.distance_to(original)>70.0,
        "left-drag mouse did not pan the 192x192 world map"):
        return
    var release := InputEventMouseButton.new()
    release.button_index = MOUSE_BUTTON_LEFT
    release.position = drag.position
    release.pressed = false
    sect.call("_on_map_gui_input",release)
    # A full-size original world has many screens of scrolling room.
    var from_map := SectMapCamera.pan_position(Vector2.ZERO,Vector2(-2300,-1100),1.0)
    if not _check(from_map.distance_to(Vector2.ZERO)>1900.0,
        "camera still clamps to the obsolete 1280x720 stage"):
        return
    var before_popup := (sect.get("map_layer") as Control).position
    sect.call("_open_notice","Camera gate","Read-only test")
    sect.call("_on_map_gui_input",press)
    sect.call("_on_map_gui_input",drag)
    if not _check((sect.get("map_layer") as Control).position == before_popup,
        "modal UI allows click-through camera movement"):
        return
    sect.queue_free()
    print("C4-JX1 LARGE MAP MOUSE DRAG / FREE CAMERA / MODAL GUARD: PASS")
    quit(0)
