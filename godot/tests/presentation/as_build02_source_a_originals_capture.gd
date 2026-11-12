extends SceneTree
## AS-BUILD-02 — authentic Source A art gallery, rendered by Godot X11/Mesa.
## This is a source inspection sheet, not a replacement sprite or fake game screenshot.
const CONFIG := "res://data/presentation/as_build02_source_a_contract.json"
const SOURCE := preload("res://src/presentation/p3/sect_map25_source_art.gd")
const ORDER := ["main_hall","residence","warehouse","forge","guidance"]
const VIEW := Vector2i(1280,720)

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if DisplayServer.get_name() == "headless":
        push_error("AS_BUILD02 source reference captures require a real Xvfb display")
        quit(1)
        return
    var output_args := OS.get_cmdline_user_args()
    if output_args.is_empty():
        push_error("AS_BUILD02 missing output folder")
        quit(1)
        return
    var dir := output_args[0]
    if DirAccess.make_dir_recursive_absolute(dir) != OK:
        push_error("AS_BUILD02 cannot create evidence directory")
        quit(1)
        return
    DisplayServer.window_set_size(VIEW)
    var cfg_file := FileAccess.open(CONFIG,FileAccess.READ)
    assert(cfg_file != null,"Source A master contract missing")
    var cfg = JSON.parse_string(cfg_file.get_as_text())
    assert(cfg is Dictionary and int(cfg.get("schema_version",0)) == 2)
    var source := SOURCE.new()
    assert(source.manifest_valid,"Existing source A SHA registry unavailable")
    var sheet := Control.new()
    sheet.name = "SourceAOriginalsGallery"
    sheet.position = Vector2.ZERO
    sheet.size = Vector2(VIEW)
    root.add_child(sheet)
    var bg := ColorRect.new()
    bg.color = Color(0.075,0.11,0.12)
    bg.size = sheet.size
    sheet.add_child(bg)
    _label(sheet,"SOURCE A / GỐC ĐANG DÙNG TRONG GODOT 4.7.2",Vector2(28,15),Color(0.92,0.85,0.68),22)
    _label(sheet,"Năm ảnh 1 góc đã xác minh SHA256 · Góc B: CHƯA CÓ · Không dùng ảnh cung điện vàng",Vector2(30,51),Color(0.71,0.83,0.78),14)
    var roles: Dictionary = cfg["roles"]
    for i in range(ORDER.size()):
        var id := ORDER[i]
        var row: Dictionary = roles[id]
        assert(row.has("direction_b") and row["direction_b"] == null,"Unexpected unverified direction B")
        var image := source.texture_for(str(row["original"]))
        assert(image != null,"Source A image SHA/import failure: "+id)
        var real_size := Vector2(row["size"][0],row["size"][1])
        assert(real_size.distance_to(SectIsometricWorldV1.HOUSE_SIZES[id]) < 0.1,
            "Source A current in-world target footprint drift: "+id)
        var col := i%3
        var line := i/3
        var origin := Vector2(20+col*420,95+line*296)
        var backing := ColorRect.new()
        backing.position = origin
        backing.size = Vector2(396,270)
        backing.color = Color(0.105,0.165,0.17)
        sheet.add_child(backing)
        var trim := Panel.new()
        trim.position = origin+Vector2(3,3)
        trim.size = Vector2(390,265)
        sheet.add_child(trim)
        var pic := TextureRect.new()
        pic.name = "Verified_" + id
        pic.texture = image
        pic.position = origin+Vector2(65,43)
        pic.size = real_size*1.03
        pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        sheet.add_child(pic)
        _label(sheet,id.to_upper()+" · "+str(row["model_id"]),origin+Vector2(13,9),
            Color(0.98,0.82,0.5),15)
        _label(sheet,"Một góc thật | Xem tại "+str(roundi(real_size.x))+"×"+str(roundi(real_size.y))+" px",
            origin+Vector2(13,239),Color(0.83,0.89,0.82),12)
    for i in range(6):
        await process_frame
    await RenderingServer.frame_post_draw
    var screenshot := root.get_texture().get_image()
    assert(screenshot != null and screenshot.get_size() == VIEW,"Unexpected GPU evidence size")
    var target := dir.path_join("source_a_five_verified_originals_1280x720.png")
    assert(screenshot.save_png(target) == OK,"Unable to write source image comparison")
    print("AS_BUILD02_SOURCE_A_FIDELITY PASS originals=5 directions=1 unmatched=0 capture=",target)
    sheet.queue_free()
    for i in range(4):
        await process_frame
    quit(0)

func _label(parent: Control,value: String,pos: Vector2,color: Color,font_size: int) -> void:
    var l := Label.new()
    l.text = value
    l.position = pos
    l.size = Vector2(400,25)
    l.add_theme_font_size_override("font_size",font_size)
    l.add_theme_color_override("font_color",color)
    parent.add_child(l)
