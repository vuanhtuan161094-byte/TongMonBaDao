extends Node2D
const INDEX := "res://labs/combat_lab/external_vfx_library_20261127/generated/review.json"
const PER_PAGE := 8
const PAGE_SECONDS := 2.5
var entries: Array = []
var textures: Dictionary = {}
var elapsed := 0.0
var font: Font = ThemeDB.fallback_font
func _ready() -> void:
    var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(INDEX))
    if not raw is Array or raw.size() < 30:
        push_error("External source library index missing")
        get_tree().quit(1)
        return
    entries = raw
    for item: Dictionary in entries:
        var t := load(str(item["texture"])) as Texture2D
        if t == null:
            push_error("Missing atlas: "+str(item["id"]))
            get_tree().quit(2)
            return
        textures[item["id"]] = t
    print("EXTERNAL_VFX_NATIVE_LOADED=", entries.size())
func _process(delta: float) -> void:
    elapsed += delta
    if elapsed >= ceilf(float(entries.size())/PER_PAGE)*PAGE_SECONDS:
        print("EXTERNAL_VFX_NATIVE_LIBRARY_COMPLETE=",entries.size())
        get_tree().quit()
        return
    queue_redraw()
func _draw() -> void:
    draw_rect(Rect2(0,0,1280,720),Color("#151c26"))
    draw_string(font,Vector2(28,42),"TMB / EXTERNAL SOURCE LIBRARY  •  FLARE",HORIZONTAL_ALIGNMENT_LEFT,-1,28,Color("#e8dfc6"))
    draw_string(font,Vector2(28,70),"Native Godot atlas playback | source-only review, not combat or owner approval",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("#b1c1d0"))
    var page := int(elapsed/PAGE_SECONDS)
    var local := fmod(elapsed,PAGE_SECONDS)
    for slot in range(PER_PAGE):
        var index := page*PER_PAGE+slot
        if index >= entries.size():continue
        var e: Dictionary = entries[index]
        var p := Vector2(28+(slot%4)*310,96+int(slot/4)*290)
        draw_rect(Rect2(p,Vector2(292,264)),Color("#293440") if slot%2==0 else Color("#8a938d"))
        draw_rect(Rect2(p,Vector2(292,264)),Color("#aab1ad"),false,1)
        var frames: Array=e["frames"]
        var index_frame := posmod(int(local*float(e["fps"])),frames.size())
        var f: Dictionary=frames[index_frame]
        var rect: Array=f["rect"]
        var region:=Rect2(float(rect[0]),float(rect[1]),float(rect[2]),float(rect[3]))
        var size:=region.size
        var scale_factor:=minf(1.0,minf(250.0/size.x,200.0/size.y))
        size*=scale_factor
        var center:=p+Vector2(146,115)
        var t: Texture2D=textures[e["id"]]
        draw_texture_rect_region(t,Rect2(center-size*0.5,size),region)
        draw_rect(Rect2(p+Vector2(0,224),Vector2(292,40)),Color("#17202b"))
        draw_string(font,p+Vector2(10,241),str(e["id"]),HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color.WHITE)
        draw_string(font,p+Vector2(10,257),"%d frames | frame %d | %.1f fps" % [frames.size(),index_frame+1,float(e["fps"])],HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("#b5c8d2"))
