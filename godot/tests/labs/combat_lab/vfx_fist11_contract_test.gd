extends SceneTree
const LAB=preload("res://labs/combat_lab/fist11/huyet_liet_quyen.gd")
var fails:=0
func check(ok: bool,note: String) -> void:
    if not ok:
        fails+=1
        push_error("VFX_FIST11_FAIL "+note)
func _initialize() -> void:call_deferred("_run")
func _run() -> void:
    check(LAB.SKILL_ID=="tmb.skill.fist.huyet_quyen.active_01.human","canonical ID")
    check(LAB.ART_REVISION=="R1_ORIGINAL_CRIMSON_CURRENT","revision")
    check(LAB.EFFECT=="damage" and LAB.ELEMENT=="nether","contract effect element")
    check(LAB.SHAPE=="single_target" and LAB.TARGET_LIMIT==1,"target limit")
    check(is_equal_approx(LAB.CAST_TIME,.45) and is_equal_approx(LAB.COOLDOWN,8.0),"cast/cooldown")
    check(is_equal_approx(LAB.PROJECTILE_SPEED,8.0) and is_equal_approx(LAB.DECLARED_RANGE,2.8),"speed/range")
    check(is_zero_approx(LAB.DECLARED_DURATION) and is_zero_approx(LAB.DECLARED_RADIUS),"no duration/AOE")
    check(LAB.phase_at(.25)=="charge" and LAB.phase_at(.59)=="flight","charge flight")
    check(LAB.phase_at(.84)=="contact_and_fade" and LAB.phase_at(1.5)=="idle","contact fade")
    check(LAB.charge_alpha(.25)>.15 and LAB.charge_alpha(.58)==0.0,"charge end")
    check(LAB.flight_at(.45)==0.0 and LAB.flight_at(.80)==1.0,"flight progress")
    check(LAB.impact_alpha(.84)>.15 and LAB.impact_alpha(1.37)==0.0,"one short contact")
    check(LAB.contact_at(0,.84).distance_to(LAB.contact_at(0,.25))>12.0,"contact follows moving enemy")
    check(LAB.caster_at(.84).distance_to(LAB.caster_at(.25))>5.0,"caster moving independently")
    check(LAB.target_at(1,.84)==Vector2(-10000,-10000),"no second recipient")
    check(LAB.CHARGE.get_size()==Vector2(1024,512),"8 charge frames")
    check(LAB.FLIGHT.get_size()==Vector2(1280,960),"12 flight frames")
    check(LAB.CONTACT.get_size()==Vector2(1024,512),"8 contact frames")
    check(LAB.ATLAS_RAW_RGBA_BYTES==9109504,"8.69MiB raw budget")
    var src:=FileAccess.get_file_as_string("res://labs/combat_lab/fist11/huyet_liet_quyen.gd")
    for forbidden in ["SaveService.","CombatV2.","apply_damage","apply_status","MapBattleV2.","_set_health","summon_actor"]:
        check(not src.contains(forbidden),"read-only lab "+forbidden)
    var instance:=LAB.new()
    root.add_child(instance)
    await process_frame
    check(instance.elapsed>=0.0,"ready clock")
    instance.queue_free()
    print("VFX_FIST11_FOCUSED_RESULT="+("PASS" if fails==0 else "FAIL")+" failures="+str(fails))
    quit(0 if fails==0 else 1)