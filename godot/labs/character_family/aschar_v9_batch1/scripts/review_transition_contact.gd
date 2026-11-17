extends Node2D
const PATHS := [
    "res://assets/frames/AS48/attack_front_consistency_v2/attack_front_01.png",
    "res://assets/frames/AS48/attack_front_consistency_v2/attack_front_transition_01_5_registered_candidate.png",
    "res://assets/frames/AS48/attack_front_consistency_v2/attack_front_02.png"
]
const LABELS := ["KEY 01 · GUARD RISE", "NEW CANDIDATE · REFERENCED", "KEY 02 · RELEASE"]
var textures: Array[Texture2D] = []
func _ready() -> void:
    for path in PATHS:
        var image := Image.load_from_file(ProjectSettings.globalize_path(path))
        if image == null or image.get_size() != Vector2i(400, 440) or image.detect_alpha() != Image.ALPHA_BLEND:
            push_error("TRANSITION_CONTACT_SOURCE_FAIL=" + path)
            get_tree().quit(3)
            return
        textures.append(ImageTexture.create_from_image(image))
    queue_redraw()
    call_deferred("capture")
func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("17232e"), true)
    draw_string(ThemeDB.fallback_font, Vector2(44, 50), "AS48 ATTACK · MASTER + NEIGHBORING KEYPOSE TRANSITION CHECK", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("edf5fb"))
    draw_string(ThemeDB.fallback_font, Vector2(44, 78), "Full-body RGBA · same 400×440 cell · feet aligned at y=429 · candidate not inserted in SpriteFrames", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("b8cbd7"))
    var xs := [230.0, 640.0, 1050.0]
    var scale := 0.62
    var baseline := 514.0
    draw_line(Vector2(75, baseline), Vector2(1205, baseline), Color("c7b278"), 1.5)
    for i in range(textures.size()):
        var origin := Vector2(xs[i] - 200.0 * scale, baseline - 430.0 * scale)
        draw_set_transform(origin, 0.0, Vector2(scale, scale))
        draw_texture(textures[i], Vector2.ZERO)
        draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
        draw_string(ThemeDB.fallback_font, Vector2(xs[i] - 180.0, 570), LABELS[i], HORIZONTAL_ALIGNMENT_CENTER, 360, 16, Color("ffffff"))
    draw_string(ThemeDB.fallback_font, Vector2(44, 640), "Generation route: frozen AS48 master + adjacent key poses 01 & 02; no frame interpolation, no weapon or VFX baked in.", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("f4d47a"))
    draw_string(ThemeDB.fallback_font, Vector2(44, 675), "Visual continuity, pose quality and owner art approval remain pending manual review.", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("b8cbd7"))
func capture() -> void:
    await get_tree().process_frame
    await RenderingServer.frame_post_draw
    var image := get_viewport().get_texture().get_image()
    var path := ProjectSettings.globalize_path("res://captures/AS48_ATTACK_TRANSITION_CONTACT_NATIVE_1280x720.png")
    var error := image.save_png(path)
    print("TRANSITION_CONTACT_CAPTURE=%s size=%s" % ["PASS" if error == OK else "FAIL", image.get_size()])
    get_tree().quit(0 if error == OK else 2)
