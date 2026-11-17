extends SceneTree
## POI19 exact immortal tier contract, authentic target movement, no gameplay writes.
const LAB=preload("res://labs/combat_lab/poison19_phu_cot_co_tien_b/r3/phu_cot_co_tien_b.gd")
const LIGHT=preload("res://labs/combat_lab/poison19_phu_cot_co_tien_b/r3/flow_light.gd")
var fails:=0
func _initialize() -> void: call_deferred("_test")
func check(ok: bool, reason: String) -> void:
    if not ok:
        fails+=1
        push_error("POI19_NATIVE_FLOW_R3_FAIL "+reason)
func _test() -> void:
    check(LAB.SKILL_ID=="tmb.skill.poison.co_doc.active_01.immortal.b","correct lineage")
    check(LAB.EFFECT=="mark" and LAB.ELEMENT=="wood" and LAB.SHAPE=="single_target","one target mark")
    check(LAB.TARGET_LIMIT==1 and absf(LAB.DECLARED_RANGE-7.8)<.0001,"no invented AoE/range")
    check(absf(LAB.DECLARED_CAST-.43)<.0001 and absf(LAB.DECLARED_COOLDOWN-9.6)<.0001,"cast/cooldown")
    check(absf(LAB.DECLARED_DURATION-6.5)<.0001 and absf(LAB.DECLARED_PROJECTILE_SPEED-8.96)<.0001,"duration/speed")
    check(absf((LAB.MARK_END-LAB.CONTACT_AT)-6.5)<.0001,"mark persists exactly 6.5 seconds in LAB")
    check(LAB.visual_phase(.2)=="charging_jade_seed","charge before .43s")
    check(LAB.visual_phase(.98)=="jade_seed_flight_lab","real flight has time")
    check(LAB.visual_phase(1.46)=="jade_orchid_folding_contact","local target contact")
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
    check(absf(LAB.mark_anchor_at(2.30).y - LAB.target_foot(2.30).y + 167)<.1,"orchid mark is above selected target head")
    check(LAB.mark_anchor_at(2.30).distance_to(LAB.mark_anchor_at(5.10))>5.0,"orchid mark follows WALK target instead of static UI")
    check(not LAB.has_gameplay_receipt(1.45) and not LAB.has_gameplay_receipt(4.5),"no forged Combat V2 hits/status")
    check(LAB.MONSTER_FRAMES.has_animation("walk"),"moving actual monster frames")
    check(LAB.SKILL_ID.ends_with(".immortal.b"),"Tiên B lineage not Liên Tâm A")
    check(LIGHT.mark_visible(2.30) and LIGHT.mark_visible(7.91) and not LIGHT.mark_visible(8.20),"6.5 second LAB mark, full cleanup")
    check(not LIGHT.affects_decoy(1.48) and not LIGHT.affects_decoy(4.70),"energy trails never target secondary WALK actor")
    for tt in [.55,.68,.85,.98,1.15,1.34]:
        check(LIGHT.flight_at(tt).distance_to(LAB.projectile_pos(tt)) < .01,"native light strands must follow projectile exact LAB curve")
        check(LIGHT.target_at(tt).distance_to(LAB.target_foot(tt)) < .01,"native light must track moving primary target only")
    check(LAB.mark_gain(2.3)>.99 and LAB.mark_gain(5.1)>.99,"sustain 6.5s without recasting")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/poison19_phu_cot_co_tien_b/r3/phu_cot_co_tien_b.gd")
    var flow_src:=FileAccess.get_file_as_string("res://labs/combat_lab/poison19_phu_cot_co_tien_b/r3/flow_light.gd")
    check(flow_src.contains("draw_line(") and flow_src.contains("BLEND_MODE_ADD"),"Godot native draw_line temporal flow and additive material source, not static sprite-only")
    for forbidden in ["SaveService.","CombatV2.","apply_damage","apply_poison","apply_status","set_health","teleport_actor","spawn_projectile"]:
        check(not src.contains(forbidden) and not flow_src.contains(forbidden),"VFX must not claim live gameplay "+forbidden)
    var bytes:=0
    for pair in [
        ["gather",12,Vector2(1280,960)],
        ["seed",16,Vector2(1536,1024)],
        ["fold",16,Vector2(1536,1536)],
        ["mark",12,Vector2(1280,960)],
        ["ground",12,Vector2(1536,768)],
        ["veil",12,Vector2(1536,960)]
    ]:
        var file: String=LAB.ASSET_ROOT+"poi19_"+pair[0]+"_"+("%02d"%pair[1])+".png"
        check(ResourceLoader.exists(file),"RGBA atlas exists "+file)
        if not ResourceLoader.exists(file): continue
        var tex:=load(file) as Texture2D
        check(tex!=null,"import success "+file)
        if tex==null: continue
        check(tex.get_size()==pair[2],"atlas geometry "+file)
        check(tex.get_image().detect_alpha()!=Image.ALPHA_NONE,"true RGBA "+file)
        bytes+=tex.get_width()*tex.get_height()*4
    check(bytes<48*1024*1024,"raw texture cap <24MiB")
    if fails==0:
        var lab:=LAB.new()
        root.add_child(lab)
        await process_frame
        check(lab.gather_frames.size()==12 and lab.seed_frames.size()==16 and lab.fold_frames.size()==16 and lab.mark_frames.size()==12 and lab.ground_frames.size()==12 and lab.veil_frames.size()==12,"80 source poses in 6 immutable R2 atlases")
        check(lab.energy_flow!=null,"Godot real-time draw child created")
        if lab.energy_flow!=null:
            check(lab.energy_flow.material is CanvasItemMaterial,"dedicated additive light material")
            if lab.energy_flow.material is CanvasItemMaterial:
                check((lab.energy_flow.material as CanvasItemMaterial).blend_mode==CanvasItemMaterial.BLEND_MODE_ADD,"Godot additive only for light, not underlying actor")
            lab.energy_flow.set_visual_state(.98,LAB.target_foot(.98),LAB.mark_anchor_at(.98),LAB.projectile_pos(.98),0.0)
            check(absf(lab.energy_flow.visual_time-.98)<.001,"real-time energy clock updates from native lab")
        lab.queue_free()
    print("POI19_NATIVE_FLOW_R3_RAW_RGBA_BYTES=",bytes)
    print("POI19_NATIVE_FLOW_R3_RESULT=",("PASS" if fails==0 else "FAIL")," failures=",fails)
    quit(0 if fails==0 else 1)
