extends SceneTree
const LAB=preload("res://labs/combat_lab/talisman15/thai_huyen_phong_gioi_phu.gd")
var fails:=0
func ck(cond:bool,label:String)->void:
    if not cond:
        fails+=1
        push_error("PAF05_FAILED: "+label)
func _initialize()->void:call_deferred("_run")
func _run()->void:
    ck(LAB.SKILL_ID=="tmb.skill.talisman.phong_an_phu.ultimate.human","correct ultimate family id")
    ck(LAB.EFFECT=="mark" and LAB.ELEMENT=="wind" and LAB.SHAPE=="circle","effect and shape")
    ck(LAB.TARGET_LIMIT==3 and LAB.HIT_COUNT==1 and LAB.DECLARED_RADIUS==2.1,"circle radius2.1 cap3 once")
    ck(LAB.DECLARED_CAST_TIME==.9 and LAB.DECLARED_COOLDOWN==23.,"cast and cooldown")
    ck(LAB.DECLARED_RANGE==9. and LAB.DECLARED_DURATION==7.,"range and status duration")
    ck(LAB.DECLARED_PROJECTILE_SPEED==0. and LAB.DECLARED_DAMAGE_RATIO==.56 and LAB.DECLARED_POWER==1.22,"catalogue parameters no visual damage")
    ck(LAB.CHARGE.get_size()==Vector2(1280,960),"charge atlas 12")
    ck(LAB.WARD.get_size()==Vector2(2048,2048),"field atlas 16")
    ck(LAB.HERO.get_size()==Vector2(1920,2400),"hero atlas 20")
    ck(LAB.CONTACT.get_size()==Vector2(1024,768),"contact atlas 12")
    ck(LAB.RESIDUE.get_size()==Vector2(1024,512),"residue atlas 8")
    ck(LAB.BADGE.get_size()==Vector2(512,256),"badge atlas 8")
    ck(LAB.MONSTER.has_animation("walk") and LAB.MONSTER.get_frame_count("walk")>=5,"real walk source")
    for k in range(3):
        ck(LAB.within_circle(k,1.53),"three legal targets "+str(k))
        ck(LAB.target_foot(k,.33).distance_to(LAB.target_foot(k,1.49))>8.,"target moves "+str(k))
        ck(LAB.target_contact(k,1.34).distance_to(LAB.target_foot(k,1.34)+Vector2(0,-85))<.001,"follow real moving target "+str(k))
        ck(LAB.simulated_mark_active(k,1.4) and LAB.simulated_mark_active(k,7.1),"mark status independent "+str(k))
        ck(not LAB.simulated_mark_active(k,8.35),"7s expiry "+str(k))
    ck(LAB.target_foot(3,1.4)==Vector2.INF and not LAB.simulated_mark_active(3,1.4),"strict target cap 3")
    ck(LAB.charge_gain(.4)>.4 and LAB.charge_gain(1.2)==0.,"cast does not run seven seconds")
    ck(LAB.hero_gain(1.1)>.4 and LAB.hero_gain(2.55)==0.,"short visual")
    ck(LAB.contact_gain(1.49)>.3 and LAB.contact_gain(1.9)==0.,"one mark receipt contact")
    ck(LAB.visual_phase(.4)=="charge" and LAB.visual_phase(1.1)=="wind_seal_forming" and LAB.visual_phase(1.5)=="circle_mark_contact","event phases")
    var s:=FileAccess.get_file_as_string("res://labs/combat_lab/talisman15/thai_huyen_phong_gioi_phu.gd")
    for blocked in ["SaveService.","CombatV2.","apply_damage", "mark_apply", "set_status", "add_debuff", "spawn_projectile"]:
        ck(not s.contains(blocked),"no unauthorized gameplay "+blocked)
    var actor:=LAB.new()
    root.add_child(actor)
    await process_frame
    ck(actor._light!=null,"rendering light exists")
    actor.queue_free()
    print("VFX_PAF05_FOCUSED_RESULT="+("PASS" if fails==0 else "FAIL")+" failures="+str(fails)+" moving_monsters=3 cap3 circle2_1=true mark7s_separate=true no_gameplay_writes=true")
    quit(0 if fails==0 else 1)
