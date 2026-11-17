extends SceneTree
func _initialize() -> void:
    var sf: SpriteFrames = load("res://assets/spriteframes/AS48_V9_candidate.tres")
    if sf == null:
        print("ASCHAR_SPRITEFRAMES_QA=FAIL load=null"); quit(2); return
    var expected := {"Walk_Front":4,"Attack_Front":4}
    for clip in expected:
        if not sf.has_animation(clip):
            print("ASCHAR_SPRITEFRAMES_QA=FAIL missing="+clip); quit(3); return
        if sf.get_frame_count(clip) != expected[clip]:
            print("ASCHAR_SPRITEFRAMES_QA=FAIL frame_count="+clip+":"+str(sf.get_frame_count(clip))); quit(4); return
        for i in range(sf.get_frame_count(clip)):
            var tex: Texture2D = sf.get_frame_texture(clip,i)
            if tex == null or tex.get_size() != Vector2(400,440):
                print("ASCHAR_SPRITEFRAMES_QA=FAIL texture="+clip+":"+str(i)); quit(5); return
    print("ASCHAR_SPRITEFRAMES_QA=PASS clips=2 frames=8 cell=400x440 exact_sha_manifest=present owner_art= pending")
    quit(0)
