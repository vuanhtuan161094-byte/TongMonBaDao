extends SceneTree
const LAB=preload("res://labs/combat_lab/fist15/huyet_hai_quyen_vuc.gd")
var fail:=0
func check(ok:bool,what:String)->void:
    if not ok:
        fail+=1
        push_error("FIST15_R1_FAIL "+what)
func _initialize()->void:call_deferred("_run")
func _run()->void:
    check(LAB.SKILL_ID=="tmb.skill.fist.huyet_quyen.ultimate.human","id")
    check(LAB.EFFECT=="consume_poison" and LAB.ELEMENT=="nether","effect")
    check(LAB.SHAPE=="circle" and LAB.TARGET_LIMIT==3,"circle 3 targets")
    check(is_equal_approx(LAB.RADIUS,3) and is_equal_approx(LAB.RANGE,5),"radius/range")
    check(is_equal_approx(LAB.CAST_TIME,1.15) and is_equal_approx(LAB.COOLDOWN,34),"cast cooldown")
    check(is_equal_approx(LAB.PROJECTILE_SPEED,8) and is_zero_approx(LAB.DURATION),"projectile speed and no status duration")
    check(not LAB.HIT_COUNT_DECLARED,"no fabricated 3 hits")
    check(LAB.phase_at(.7)=="concentrate_white_core" and LAB.phase_at(1.05)=="blood_sea_unfurls","charge phases")
    check(LAB.phase_at(1.30)=="vertical_spirit_fists" and LAB.phase_at(1.65)=="three_target_impacts","travel contact")
    check(LAB.phase_at(2.20)=="blood_sea_dissolve" and LAB.phase_at(2.60)=="finished","no persistent status")
    check(LAB.contact_at(0,1.50).distance_to(LAB.contact_at(2,1.50))>190,"3 spatially independent foes")
    check(LAB.foe_at(0,.40).distance_to(LAB.foe_at(0,1.50))>12,"moving foe")
    check(LAB.foe_at(3,1.55)==Vector2(-9999,-9999),"cap exactly 3")
    check(LAB.drop_at(1,1.26).y<LAB.contact_at(1,1.26).y-30,"true vertical descent above foe")
    check(LAB.hit_visibility(1,LAB.arrival_at(1)+.09)>.3,"local hit after arrival")
    check(LAB.hit_visibility(1,2.9)==0 and LAB.field_opacity(2.9)==0,"all visuals gone")
    check(LAB.CHARGE.get_size()==Vector2(1280,960),"10 charge atlas")
    check(LAB.SEA.get_size()==Vector2(1280,960),"12 wave atlas")
    check(LAB.FALL.get_size()==Vector2(1280,1600),"17 vertical fist atlas")
    check(LAB.HIT.get_size()==Vector2(1280,640),"8 contact atlas")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/fist15/huyet_hai_quyen_vuc.gd")
    for bad in ["SaveService.","CombatV2.","apply_damage","apply_status","poison_stacks +","_apply_poison","_consume_poison"]:
        check(not src.contains(bad),"read-only "+bad)
    var node=LAB.new()
    root.add_child(node)
    await process_frame
    node.queue_free()
    print("VFX_FIST15_R1_FOCUSED_RESULT="+("PASS" if fail==0 else "FAIL")+" failures="+str(fail))
    quit(0 if fail==0 else 1)
