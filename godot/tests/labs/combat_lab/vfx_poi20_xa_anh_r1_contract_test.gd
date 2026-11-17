extends SceneTree
## POI20 independent single-target poison VFX contract, not gameplay application.
const LAB=preload("res://labs/combat_lab/poison20_xa_anh_quan_mach_tien_a/r1/xa_anh_quan_mach.gd")
const LIGHT=preload("res://labs/combat_lab/poison20_xa_anh_quan_mach_tien_a/r1/flow_light.gd")
var failures:int=0
func check(ok:bool,message:String)->void:
    if not ok:
        failures+=1
        push_error("POI20_R1_FAIL "+message)
func _initialize()->void:
    call_deferred("_run")
func _run()->void:
    check(LAB.SKILL_ID=="tmb.skill.poison.co_doc.active_02.immortal.a","canon POI20 Tiên A")
    check(LAB.EFFECT=="poison" and LAB.ELEMENT=="wood" and LAB.SHAPE=="single_target","poison wood one enemy")
    check(LAB.TARGET_LIMIT==1 and LAB.POISON_STACKS==2,"one enemy, declared two poison stacks")
    check(absf(LAB.DECLARED_CAST-.43)<.001 and absf(LAB.DECLARED_COOLDOWN-8.64)<.001,"cast/cooldown")
    check(absf(LAB.DECLARED_DURATION-8.5)<.001 and absf(LAB.DECLARED_PROJECTILE_SPEED-8.96)<.001,"duration/speed")
    check(absf(LAB.DECLARED_RANGE-7.8)<.001,"canonical range")
    check(absf(LAB.MARK_END-LAB.CONTACT_AT-8.5)<.001,"8.5s LAB status")
    check(LAB.phase_at(.21)=="charge" and LAB.phase_at(.98)=="serpent_flight","charge/flight")
    check(LAB.phase_at(1.48)=="serpent_coils_one_target","serpent coils on moving target")
    check(LAB.phase_at(5.10)=="single_target_double_venom_veins","two status veins")
    check(LAB.phase_at(10.23)=="clear","status expires cleanly")
    check(LAB.mark_gain(.98)==0.0 and LAB.mark_gain(5.1)>.99,"no early mark, mark persists")
    check(LAB.mark_gain(10.3)==0.0 and LAB.mark_gain(10.01)>0.0,"no permanent mark")
    check(LAB.target_foot(.31).distance_to(LAB.target_foot(1.45))>10.0,"moving WALK target")
    check(LAB.target_foot(1.45).distance_to(LAB.decoy_foot(1.45))>120.0,"unmarked second WALK target")
    check(LAB.projectile_pos(.9).distance_to(LAB.projectile_pos(.7))>30.0,"continuous moving snake flight")
    check(LAB.projectile_pos(LAB.CONTACT_AT).distance_to(LAB.target_foot(LAB.CONTACT_AT)+Vector2(-12,-79))<.01,"selected target contact")
    check(LAB.mark_anchor_at(5.1).distance_to(LAB.target_foot(5.1)+Vector2(0,-167))<.01,"status follows enemy")
    check(not LAB.has_gameplay_receipt(2.1) and not LAB.affects_decoy(2.1),"VFX never writes poison")
    for t in [.55,.68,.85,.98,1.16,1.35]:
        check(LIGHT.flight_at(t).distance_to(LAB.projectile_pos(t))<.01,"Godot live light tracks projectile")
        check(LIGHT.target_at(t).distance_to(LAB.target_foot(t))<.01,"Godot energy tracks moving monster")
    check(LIGHT.is_visual_marked(5.1) and not LIGHT.is_visual_marked(10.22),"light status fade")
    check(not LIGHT.affects_decoy(1.5) and not LIGHT.affects_decoy(6.5),"no emission on decoy")
    check(LAB.MONSTER_FRAMES.has_animation("walk"),"real moving monster frames")
    var scene_src:String=FileAccess.get_file_as_string("res://labs/combat_lab/poison20_xa_anh_quan_mach_tien_a/r1/xa_anh_quan_mach.gd")
    var light_src:String=FileAccess.get_file_as_string("res://labs/combat_lab/poison20_xa_anh_quan_mach_tien_a/r1/flow_light.gd")
    check(light_src.contains("draw_polyline_colors(") and light_src.contains("BLEND_MODE_ADD"),
        "real native Godot continuous energy child, not image-only")
    for banned in ["SaveService.","CombatV2.","apply_damage","apply_poison","apply_status","set_health","teleport_actor","spawn_projectile"]:
        check(not scene_src.contains(banned) and not light_src.contains(banned),"no game state writes "+banned)
    var bytes:int=0
    for entry in [
        ["gather",8,Vector2(1024,512)],
        ["flight",16,Vector2(1536,1024)],
        ["coil_back",12,Vector2(1280,960)],
        ["coil_front",12,Vector2(1280,960)],
        ["mark",12,Vector2(1024,768)]
    ]:
        var path:String=LAB.ASSET_ROOT+"poi20_"+String(entry[0])+"_"+("%02d"%int(entry[1]))+".png"
        check(ResourceLoader.exists(path),"missing RGBA "+path)
        if not ResourceLoader.exists(path):continue
        var tex:=load(path) as Texture2D
        check(tex!=null,"Godot imported atlas "+path)
        if tex==null:continue
        check(tex.get_size()==entry[2],"size "+path)
        check(tex.get_image().detect_alpha()!=Image.ALPHA_NONE,"true alpha "+path)
        bytes+=tex.get_width()*tex.get_height()*4
    check(bytes<40*1024*1024,"reasonable raw atlas memory for candidate")
    if failures==0:
        var lab:=LAB.new()
        root.add_child(lab)
        await process_frame
        check(lab.gather_frames.size()==8 and lab.flight_frames.size()==16 and lab.coil_back_frames.size()==12 and lab.coil_front_frames.size()==12 and lab.mark_frames.size()==12,"60 source poses")
        check(lab.energy_flow!=null,"native Godot energy instantiated")
        if lab.energy_flow!=null:
            check(lab.energy_flow.material is CanvasItemMaterial,"separate Godot emission material")
            if lab.energy_flow.material is CanvasItemMaterial:
                check((lab.energy_flow.material as CanvasItemMaterial).blend_mode==CanvasItemMaterial.BLEND_MODE_ADD,"ADD only on energy")
            lab.energy_flow.set_state(.98,LAB.target_foot(.98),LAB.projectile_pos(.98),LAB.mark_anchor_at(.98),0.0)
            check(absf(lab.energy_flow.visual_time-.98)<.001,"clock follows Godot scene")
        lab.queue_free()
    print("POI20_R1_RGBA_RAW_BYTES=",bytes)
    print("POI20_XA_ANH_R1_RESULT=",("PASS" if failures==0 else "FAIL")," failures=",failures)
    quit(0 if failures==0 else 1)
