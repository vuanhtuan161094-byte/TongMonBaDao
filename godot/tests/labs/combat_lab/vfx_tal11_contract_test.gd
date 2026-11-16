extends SceneTree
const LAB=preload("res://labs/combat_lab/talisman11/phong_gioi_truy_dau.gd")
var failures:=0
func check(ok:bool,label:String)->void:
    if not ok:
        failures+=1
        push_error("VFX_TAL11_FAIL "+label)
func _initialize()->void:
    call_deferred("_run")
func _run()->void:
    check(LAB.SKILL_ID=="tmb.skill.talisman.phong_an_phu.active_01.human","canonical PAF01 ID")
    check(LAB.ELEMENT=="wind" and LAB.EFFECT=="mark" and LAB.SHAPE=="single_target","wind single target mark")
    check(LAB.TARGET_LIMIT==1 and LAB.HIT_COUNT==1,"exactly one mark application, one target")
    check(LAB.DECLARED_RANGE==8.5 and LAB.DECLARED_RADIUS==0.0,"range no AoE")
    check(LAB.DECLARED_CAST_TIME==.5 and LAB.DECLARED_COOLDOWN==9.4,"canonical cast and cooldown")
    check(LAB.DECLARED_DURATION==6.0 and LAB.DECLARED_PROJECTILE_SPEED==0.0,"six second mark not a cast or projectile")
    check(LAB.DECLARED_DAMAGE_RATIO==.72,"read-only damage ratio is not applied in LAB")
    check(LAB.CHARGE.get_size()==Vector2(1280,960),"12 charge painted poses")
    check(LAB.STREAM.get_size()==Vector2(2048,1024),"16 cosmetic wind material poses")
    check(LAB.CONTACT.get_size()==Vector2(1024,768),"12 small one-mark contact poses")
    check(LAB.MARK.get_size()==Vector2(1024,1280),"20 animated 風 mark poses")
    check(LAB.MONSTER.has_animation("walk") and LAB.MONSTER.get_frame_count("walk")>=8,"genuine animated WALK target")
    check(LAB.charge_gain(.29)>.65 and LAB.charge_gain(.75)==0.0,"charge finite and cast short")
    check(LAB.stream_gain(.42)==0.0 and LAB.stream_gain(.82)>.8 and LAB.stream_gain(1.23)==0.0,"cosmetic view-only wind trace")
    check(LAB.contact_gain(1.05)==0.0 and LAB.contact_gain(1.26)>.6 and LAB.contact_gain(1.66)==0.0,"one bounded arrival")
    check(LAB.mark_active(1.15) and LAB.mark_active(7.14) and not LAB.mark_active(7.15),"precise six demo status seconds")
    check(LAB.mark_gain(1.0)==0.0 and LAB.mark_gain(2.1)>.99 and LAB.mark_gain(6.9)>.99 and LAB.mark_gain(7.51)==0.0,"stable lingering wind mark and fade")
    check(LAB.phase(.33)=="charge" and LAB.phase(.84)=="visual_wind_transfer","phase progression")
    check(LAB.phase(1.33)=="mark_receipt_light" and LAB.phase(4.25)=="six_second_mark_sustain","status not extended cast")
    check(LAB.target_foot(0,.32).distance_to(LAB.target_foot(0,1.22))>20.0,"moving contact nonzero")
    check(LAB.target_foot(0,1.20).distance_to(LAB.target_foot(0,4.6))>16.0,"moving marked enemy in sustain")
    for t in [.32,1.22,3.0,5.2,7.0]:
        check(LAB.target_contact(0,t).distance_to(LAB.target_foot(0,t)+Vector2(0,-89))<.001,"contact follows actor "+str(t))
        check(LAB.mark_icon(0,t).distance_to(LAB.target_foot(0,t)+Vector2(0,-164+3*sin(t*2.1)))<.001,"mark follows moving actor "+str(t))
    check(LAB.target_foot(1,1.2)==Vector2.INF,"cannot silently tag second enemy")
    var ins:=LAB.new()
    root.add_child(ins)
    await process_frame
    check(ins._light!=null,"soft native light generated")
    var code:=FileAccess.get_file_as_string("res://labs/combat_lab/talisman11/phong_gioi_truy_dau.gd")
    for banned in ["SaveService.","CombatV2.","apply_damage","apply_mark","set_hitpoints","status_registry","spawn_projectile","damage_tick"]:
        check(not code.contains(banned),"no real damage/status writes "+banned)
    print("VFX_TAL11_FOCUSED_RESULT="+("PASS" if failures==0 else "FAIL")+" failures="+str(failures)+" moving_1_target=true mark_6s=true projectile_0=true no_damage=true")
    ins.queue_free()
    quit(0 if failures==0 else 1)
