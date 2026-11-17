extends Node2D
var frame_count:=0
var big:AnimatedSprite2D
var small:AnimatedSprite2D
func _ready()->void:
    var sf:SpriteFrames=load("res://assets/spriteframes/AS49_V9_candidate.tres")
    big=AnimatedSprite2D.new();big.sprite_frames=sf;big.animation="Walk_Front";big.position=Vector2(450,520);big.scale=Vector2(.56,.56);big.play();add_child(big)
    small=AnimatedSprite2D.new();small.sprite_frames=sf;small.animation="Walk_Front";small.position=Vector2(960,569);small.scale=Vector2(.17,.17);small.play();add_child(small)
    queue_redraw()
func _draw()->void:
    draw_rect(Rect2(Vector2.ZERO,Vector2(1280,720)),Color("211a20"),true);draw_rect(Rect2(36,32,1208,656),Color("30242b"),true);draw_rect(Rect2(36,32,1208,5),Color("c9a96a"),true)
    draw_line(Vector2(72,111),Vector2(1208,111),Color("7c6268"),1.0);draw_line(Vector2(130,638),Vector2(690,638),Color("9c695e"),2.0);draw_line(Vector2(780,605),Vector2(1138,605),Color("9c695e"),2.0)
    draw_string(ThemeDB.fallback_font,Vector2(72,80),"AS-CHAR-49  |  KIẾM TU NỮ",HORIZONTAL_ALIGNMENT_LEFT,-1,26,Color("f2e7c9"))
    draw_string(ThemeDB.fallback_font,Vector2(72,151),"WALK_FRONT  ·  WHOLE-BODY CEL  ·  NO RIG",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("e6a8b2"))
    draw_string(ThemeDB.fallback_font,Vector2(130,190),"ZOOM REVIEW",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("d2b87c"));draw_string(ThemeDB.fallback_font,Vector2(815,190),"MAP SCALE  ≈ 73 PX",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("d2b87c"))
    draw_string(ThemeDB.fallback_font,Vector2(760,248),"4 UNIQUE WALK POSES",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("f2e7c9"));draw_string(ThemeDB.fallback_font,Vector2(760,282),"left contact → pass → right contact → pass",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("cec0b4"));draw_string(ThemeDB.fallback_font,Vector2(760,315),"CANDIDATE · WEAPON OVERLAY PENDING",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("e3a991"));draw_string(ThemeDB.fallback_font,Vector2(72,665),"400×440 registered frame · foot baseline y=430 · owner art pending",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("cec0b4"))
func _process(_delta:float)->void:
    frame_count+=1
    if frame_count==45:call_deferred("_capture","AS49_WALK_FRONT_NATIVE_1280x720.png")
func _capture(n:String)->void:
    await RenderingServer.frame_post_draw
    var im=get_viewport().get_texture().get_image();var e=im.save_png(ProjectSettings.globalize_path("res://captures/"+n));print("NATIVE_VIEWPORT_CAPTURE=",n," size=",im.get_size()," error=",e)
