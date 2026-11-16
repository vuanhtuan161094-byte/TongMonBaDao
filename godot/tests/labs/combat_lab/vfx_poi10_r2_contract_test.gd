extends SceneTree
const LAB=preload("res://labs/combat_lab/poison10/r2_remake/doc_khi_phe_tam_r2.gd")
const BADGE=preload("res://labs/combat_lab/shared_poison_status/poison_status_badge.gd")
var failures:=0
func _initialize()->void: call_deferred("_run")
func check(ok:bool,reason:String)->void:
    if not ok:
        failures+=1
        push_error("VFX_POI10_R2_FAIL "+reason)
func _run()->void:
    check(LAB.SKILL_ID=="tmb.skill.poison.doc_cham.active_04.human","canonical skill id")
    check(LAB.EFFECT=="poison" and LAB.ELEMENT=="nether" and LAB.SHAPE=="circle","canonical element/effect/shape")
    check(LAB.TARGET_LIMIT==3 and LAB.DECLARED_RADIUS==2.6 and LAB.DECLARED_RANGE==7.0,"target radius range")
    check(LAB.DECLARED_CAST==0.65 and LAB.DECLARED_COOLDOWN==12.0,"cast cooldown")
    check(LAB.DECLARED_PROJECTILE_SPEED==8.0 and LAB.DECLARED_DURATION==6.0,"speed duration")
    check(LAB.DECLARED_POISON_STACKS==1 and LAB.DECLARED_DAMAGE_RATIO==0.9,"one stack/damage ratio from catalogue")
    check(LAB.phase_at(.33)=="seed_charge" and LAB.phase_at(.85)=="one_cosmetic_bud_flight","phase initial")
    check(LAB.phase_at(1.40)=="poison_lotus_peak" and LAB.phase_at(1.66)=="local_contacts","phase bloom/contact")
    check(LAB.phase_at(5.0)=="shared_status_badges" and LAB.phase_at(8.3)=="idle","badge hold vs idle")
    check(LAB.demo_flight_at(LAB.CAST_END).distance_to(LAB.PALM)<.05,"flight start anchor")
    check(LAB.demo_flight_at(LAB.BLOOM_START).distance_to(LAB.AREA_CENTER)<.05,"flight area center")
    check(LAB.MONSTER_FRAMES.has_animation("walk") and LAB.MONSTER_FRAMES.get_frame_count("walk")>=8,"real moving monster walk")
    check(BADGE.should_show(1,6.0) and BADGE.should_show(2,5.0),"same icon for any poisoned target regardless of stacks")
    check(not BADGE.should_show(0,6.0) and not BADGE.should_show(1,0.0),"badge only for genuine active poison")
    var t0:=1.51
    for i in range(LAB.TARGET_LIMIT):
        var h:=LAB.mock_contact_time(i)
        check(LAB.monster_foot(i,.33).distance_to(LAB.monster_foot(i,1.65))>8.0,"moving monster "+str(i))
        check(LAB.monster_chest(i,h).distance_to(LAB.monster_foot(i,h)+Vector2(-5,-79))<.05,"contact tether "+str(i))
        check(LAB.poison_badge_anchor(i,h).distance_to(LAB.monster_foot(i,h)+Vector2(-5,-127))<.05,"badge follows moving head "+str(i))
        check(LAB.demo_status_remaining(i,h-.01)==0.0 and LAB.demo_status_remaining(i,h+1)>4.9,"mock badge starts at one visual contact only "+str(i))
        check(LAB.demo_status_remaining(i,h+6.01)==0.0,"badge ends after declared six seconds "+str(i))
    var source:=FileAccess.get_file_as_string("res://labs/combat_lab/poison10/r2_remake/doc_khi_phe_tam_r2.gd")
    var shared:=FileAccess.get_file_as_string("res://labs/combat_lab/shared_poison_status/poison_status_badge.gd")
    for forbidden in ["SaveService.","CombatV2.","MapBattleV2.","apply_damage","apply_status","V63FeatureGates.","summon_actor"]:
        check(not source.contains(forbidden) and not shared.contains(forbidden),"view-only UI no gameplay status writes "+forbidden)
    var spec=[
        [LAB.CHARGE_PATH,Vector2(768,576),Vector2i(192,192),10],
        [LAB.BLOOM_PATH,Vector2(1536,768),Vector2i(384,256),12],
        [LAB.CONTACT_PATH,Vector2(768,320),Vector2i(192,160),8],
        [BADGE.ICON_PATH,Vector2(64,64),Vector2i(64,64),1]
    ]
    var raw:=0
    for row in spec:
        var path:String=row[0]
        check(ResourceLoader.exists(path),"atlas present "+path)
        if not ResourceLoader.exists(path):continue
        var tex:=load(path) as Texture2D
        check(tex!=null,"native Texture2D "+path)
        if tex==null:continue
        check(tex.get_size()==row[1],"real atlas geometry "+path)
        raw+=int(tex.get_width()*tex.get_height()*4)
        var img:Image=tex.get_image()
        check(img.detect_alpha()!=Image.ALPHA_NONE,"RGBA alpha "+path)
        var cell:Vector2i=row[2]
        for i in range(row[3]):
            var x:int=(i%4)*cell.x
            var y:int=(i/4)*cell.y
            check(img.get_pixel(x,y).a==0 and img.get_pixel(x+cell.x-1,y+cell.y-1).a==0,"alpha border "+path+" "+str(i))
    check(raw<8*1024*1024,"less than 8MiB RGBA8 primary VFX + shared icon")
    if failures==0:
        var actor:=LAB.new()
        root.add_child(actor)
        await process_frame
        check(actor.charge_frames.size()==10 and actor.bloom_frames.size()==12 and actor.contact_frames.size()==8,"30 moving source-painted frames, not 6s marker")
        actor.queue_free()
    print("VFX_POI10_R2_TEXTURE_BYTES=",raw)
    print("VFX_POI10_R2_RESULT=",("PASS" if failures==0 else "FAIL")," failures=",failures)
    quit(0 if failures==0 else 1)