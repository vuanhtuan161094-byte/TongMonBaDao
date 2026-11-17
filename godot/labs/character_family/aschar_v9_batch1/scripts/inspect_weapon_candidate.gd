extends SceneTree
func _initialize() -> void:
    var path := ProjectSettings.globalize_path("res://assets/weapons/AS48_KIEMTU_JIAN_CANDIDATE.png")
    var image := Image.load_from_file(path)
    if image == null:
        print("WEAPON_IMAGE=FAIL load")
        quit(2)
        return
    var min_x := image.get_width()
    var min_y := image.get_height()
    var max_x := -1
    var max_y := -1
    var opaque := 0
    for y in range(image.get_height()):
        for x in range(image.get_width()):
            if image.get_pixel(x, y).a > 0.05:
                opaque += 1
                min_x = mini(min_x, x)
                min_y = mini(min_y, y)
                max_x = maxi(max_x, x)
                max_y = maxi(max_y, y)
    print("WEAPON_IMAGE=PASS size=%dx%d bbox=%d,%d,%d,%d opaque=%d alpha=%d" % [image.get_width(), image.get_height(), min_x, min_y, max_x, max_y, opaque, image.detect_alpha()])
    quit(0)
