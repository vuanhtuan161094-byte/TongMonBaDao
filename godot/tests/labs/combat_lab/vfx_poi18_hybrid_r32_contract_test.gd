extends SceneTree
## POI18 exact immortal tier contract, authentic target movement, no gameplay writes.
const LAB=preload("res://labs/combat_lab/poison18_phu_cot_co_tien_a/r32/poi18_hybrid_r32.gd")
var fails:=0
func _initialize() -> void: call_deferred("_test")
func check(ok: bool, reason: String) -> void:
    if not ok:
        fails+=1
        push_error("POI18_HYBRID_R32_FAIL "+reason)
func _test() -> void:
    check(LAB.SKILL_ID=="tmb.skill.poison.co_doc.active_01.immortal.a","correct lineage")
    check(LAB.EFFECT=="mark" and LAB.ELEMENT=="wood" and LAB.SHAPE=="single_target","one target mark")
    check(LAB.TARGET_LIMIT==1 and absf(LAB.DECLARED_RANGE-7.8)<.0001,"no invented AoE/range")
    check(absf(LAB.DECLARED_CAST-.43)<.0001 and absf(LAB.DECLARED_COOLDOWN-9.6)<.0001,"cast/cooldown")
    check(absf(LAB.DECLARED_DURATION-6.5)<.0001 and absf(LAB.DECLARED_PROJECTILE_SPEED-8.96)<.0001,"duration/speed")
    check(absf((LAB.MARK_END-LAB.CONTACT_AT)-6.5)<.0001,"mark persists exactly 6.5 seconds in LAB")
    check(LAB.visual_phase(.2)=="charging_gu_egg","charge before .43s")
    check(LAB.visual_phase(.98)=="gu_homing_lab_visual","real flight has time")
    check(LAB.visual_phase(1.46)=="linked_heart_burst","local target contact")
    check(LAB.visual_phase(4.3)=="single_target_mark","mark visually remains")
    check(LAB.visual_phase(8.25)=="clear","mark expires")
    check(LAB.mark_gain(.98)==0 and LAB.mark_gain(1.48)>.5,"no mark before contact")
    check(LAB.mark_gain(4)>.99 and LAB.mark_gain(7.6)>.99,"mark held")
    check(LAB.mark_gain(8.3)==0.0,"no perpetual mark")
    check(LAB.flight_fraction(.54)==0.0 and LAB.flight_fraction(.96)>.05 and LAB.flight_fraction(.96)<1 and LAB.flight_fraction(1.39)==1,"no teleport visual")
    check(LAB.target_foot(.31).distance_to(LAB.target_foot(1.45))>10.0,"target independently WALKING")
    check(LAB.projectile_pos(.89).distance_to(LAB.projectile_pos(.68))>45.0,"gu moves across actual scene")
    check(LAB.projectile_pos(LAB.CONTACT_AT).distance_to(LAB.target_foot(LAB.CONTACT_AT)+Vector2(-13,-70))<.1,"contact follows moving target")
    check(LAB.target_foot(1.45).distance_to(LAB.decoy_foot(1.45))>120,"unaffected second enemy present")
    check(not LAB.has_gameplay_receipt(1.45) and not LAB.has_gameplay_receipt(4.5),"no forged Combat V2 hits/status")
    check(LAB.MONSTER_FRAMES.has_animation("walk"),"moving actual monster frames")
    check(LAB.R32_HEAD_LOCAL==Vector2(80,-8),"R3.1 original gu head local anchor")
    check(LAB.head_offset(Vector2(230,180)).distance_to(Vector2(57.5,-5.625))<.01,"tip-aligned 1x gu-flight pivot")
    check(LAB.R32_ENTRY_SECONDS>0.1 and LAB.R32_ENTRY_SECONDS<.2,"short LAB-only contact bridge")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/poison18_phu_cot_co_tien_a/r32/poi18_hybrid_r32.gd")
    for forbidden in ["SaveService.","CombatV2.","apply_damage","apply_poison","apply_status","set_health","teleport_actor","spawn_projectile"]:
        check(not src.contains(forbidden),"VFX must not claim live gameplay "+forbidden)
    var bytes:=0
    for pair in [
        ["gather",8,Vector2(1024,512)],
        ["gu",16,Vector2(1280,1024)],
        ["burst",12,Vector2(1280,960)],
        ["seal",12,Vector2(1024,768)]
    ]:
        var file: String=LAB.R32_ATLAS if String(pair[0])=="gu" else LAB.ASSET_ROOT+"poi18_"+pair[0]+"_"+("%02d"%pair[1])+".png"
        check(ResourceLoader.exists(file),"RGBA atlas exists "+file)
        if not ResourceLoader.exists(file): continue
        var tex:=load(file) as Texture2D
        check(tex!=null,"import success "+file)
        if tex==null: continue
        check(tex.get_size()==pair[2],"atlas geometry "+file)
        check(tex.get_image().detect_alpha()!=Image.ALPHA_NONE,"true RGBA "+file)
        bytes+=tex.get_width()*tex.get_height()*4
    check(bytes<24*1024*1024,"raw texture cap <24MiB")
    if fails==0:
        var lab:=LAB.new()
        root.add_child(lab)
        await process_frame
        check(lab.gather_frames.size()==8 and lab.gu_frames.size()==16 and lab.burst_frames.size()==12 and lab.seal_frames.size()==12,"48 actual poses")
        lab.queue_free()
    print("POI18_HYBRID_R32_RAW_RGBA_BYTES=",bytes)
    print("POI18_HYBRID_R32_RESULT=",("PASS" if fails==0 else "FAIL")," failures=",fails)
    quit(0 if fails==0 else 1)
