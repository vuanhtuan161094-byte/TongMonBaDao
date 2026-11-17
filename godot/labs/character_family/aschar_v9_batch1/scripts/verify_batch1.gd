extends SceneTree
func _initialize()->void:
    var sets={"AS48_V9_candidate.tres":{"Walk_Front":4,"Attack_Front":4},"AS49_V9_candidate.tres":{"Walk_Front":4,"Attack_Front":4}}
    for resource_name in sets:
        var sf:SpriteFrames=load("res://assets/spriteframes/"+resource_name)
        if sf==null:fail("SPRITEFRAMES_LOAD="+resource_name);return
        for clip in sets[resource_name]:
            if not sf.has_animation(clip):fail("MISSING_CLIP="+clip);return
            if sf.get_frame_count(clip)!=sets[resource_name][clip]:fail("BAD_COUNT="+clip);return
            var regions={}
            for i in range(sf.get_frame_count(clip)):
                var tex:Texture2D=sf.get_frame_texture(clip,i)
                if tex==null or tex.get_size()!=Vector2(400,440):fail("BAD_FRAME_SIZE="+clip+":"+str(i));return
                if tex is AtlasTexture:
                    var r:Rect2=(tex as AtlasTexture).region
                    if r!=Rect2(i*400,0,400,440):fail("BAD_ATLAS_REGION="+clip+":"+str(i));return
                    regions[str(r)]=true
            if regions.size()!=sets[resource_name][clip]:fail("DUPLICATE_REGION="+clip);return
    var sources=[
      "res://assets/frames/AS48/walk_front/AS48_walk_front_f00_left_contact.png","res://assets/frames/AS48/walk_front/AS48_walk_front_f01_passing.png","res://assets/frames/AS48/walk_front/AS48_walk_front_f02_right_contact.png","res://assets/frames/AS48/walk_front/AS48_walk_front_f03_passing.png",
      "res://assets/frames/AS48/attack_front/AS48_attack_front_f00_windup.png","res://assets/frames/AS48/attack_front/AS48_attack_front_f01_guard_rise.png","res://assets/frames/AS48/attack_front/AS48_attack_front_f02_release.png","res://assets/frames/AS48/attack_front/AS48_attack_front_f03_recovery.png",
      "res://assets/frames/AS49/walk_front/AS49_walk_front_f00_left_contact.png","res://assets/frames/AS49/walk_front/AS49_walk_front_f01_passing.png","res://assets/frames/AS49/walk_front/AS49_walk_front_f02_right_contact.png","res://assets/frames/AS49/walk_front/AS49_walk_front_f03_passing.png",
      "res://assets/frames/AS49/attack_front/AS49_attack_front_f00_windup.png","res://assets/frames/AS49/attack_front/AS49_attack_front_f01_draw.png","res://assets/frames/AS49/attack_front/AS49_attack_front_f02_release.png","res://assets/frames/AS49/attack_front/AS49_attack_front_f03_recovery.png"]
    for path in sources:
        var im:=Image.load_from_file(ProjectSettings.globalize_path(path))
        if im==null or im.get_used_rect().size==Vector2i.ZERO:fail("SOURCE_ALPHA_EMPTY="+path);return
        var corners=[Vector2i.ZERO,Vector2i(im.get_width()-1,0),Vector2i(0,im.get_height()-1),im.get_size()-Vector2i.ONE]
        for pos in corners:
            if im.get_pixelv(pos).a>0.05:fail("ALPHA_MATTE_CORNER="+path+":"+str(pos));return
    var cap_paths=["captures/AS48_WALK_FRONT_NATIVE_1280x720.png","captures/AS48_ATTACK_FRONT_NATIVE_1280x720.png","captures/AS48_WALK_FRONT_RETURN_NATIVE_1280x720.png","captures/AS49_WALK_FRONT_NATIVE_1280x720.png","captures/AS49_ATTACK_FRONT_WINDUP_NATIVE_1280x720.png","captures/AS49_ATTACK_FRONT_DRAW_NATIVE_1280x720.png","captures/AS49_ATTACK_FRONT_RELEASE_NATIVE_1280x720.png","captures/AS49_ATTACK_FRONT_RECOVERY_NATIVE_1280x720.png"]
    for cap in cap_paths:
        var im:=Image.load_from_file(ProjectSettings.globalize_path("res://"+cap))
        if im==null or im.get_size()!=Vector2i(1280,720):fail("NATIVE_CAPTURE_SIZE="+cap);return
    var coverage:=FileAccess.get_file_as_string("res://meta/ASCHAR_V9_COVERAGE_576.csv").strip_edges().split("\n")
    if coverage.size()!=577:fail("COVERAGE_ROW_COUNT="+str(coverage.size()-1));return
    var female_attack:="\"Kiếm Tu\",\"Nữ\",\"Front\",\"Attack\",\"MASTER_CANDIDATE_IN_REVIEW_PROJECT\",\"TECHNICAL_PASS_BODY_ONLY\""
    var female_attack_found:=false
    for row in coverage:
        if row.contains(female_attack):female_attack_found=true
    if not female_attack_found:fail("AS49_ATTACK_COVERAGE_MISSING");return
    print("ASCHAR_V9_BATCH1_VERIFY=PASS clips=4 source_cels=16 spriteframes_resources=2 transparencies=16 coverage_rows=576 native_captures=8 1280x720 rig=none weapon_overlay=separate_pending")
    quit(0)
func fail(s:String)->void:
    push_error("ASCHAR_V9_BATCH1_VERIFY=FAIL "+s);quit(2)
