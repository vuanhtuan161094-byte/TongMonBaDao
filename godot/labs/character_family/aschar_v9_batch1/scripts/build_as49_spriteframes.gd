extends SceneTree
func _initialize() -> void:
    var walk_tex: Texture2D=load("res://assets/atlases/AS49_walk_front_atlas.png")
    var attack_tex: Texture2D=load("res://assets/atlases/AS49_attack_front_atlas.png")
    if walk_tex==null or attack_tex==null: push_error("AS49_ATLAS_LOAD_FAIL");quit(2);return
    var sf:=SpriteFrames.new();sf.clear_all()
    sf.add_animation("Walk_Front");sf.set_animation_speed("Walk_Front",8.0);sf.set_animation_loop("Walk_Front",true)
    for i in range(4):
        var walk_frame:=AtlasTexture.new();walk_frame.atlas=walk_tex;walk_frame.region=Rect2(i*400,0,400,440);sf.add_frame("Walk_Front",walk_frame)
    sf.add_animation("Attack_Front");sf.set_animation_speed("Attack_Front",7.0);sf.set_animation_loop("Attack_Front",false)
    for i in range(4):
        var attack_frame:=AtlasTexture.new();attack_frame.atlas=attack_tex;attack_frame.region=Rect2(i*400,0,400,440);sf.add_frame("Attack_Front",attack_frame)
    var e=ResourceSaver.save(sf,"res://assets/spriteframes/AS49_V9_candidate.tres")
    if e!=OK:push_error("AS49_SPRITEFRAMES_SAVE_FAIL="+str(e));quit(3);return
    print("AS49_SPRITEFRAMES_BUILD=PASS clips=2 frames=8 source_frames=8")
    quit(0)
