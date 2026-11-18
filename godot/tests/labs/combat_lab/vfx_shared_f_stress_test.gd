extends SceneTree
## Deterministic 6v8 and 30+40 POLICY stress (CPU snapshot only, not GPU FPS).
const POLICY=preload("res://labs/combat_lab/vfx_shared_f_pilot/vfx_presentation_policy.gd")
var failed:=0
func check(ok: bool, msg: String) -> void:
    if not ok:
        failed+=1
        push_error("VFX_F_STRESS_FAIL "+msg)
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var start := Time.get_ticks_usec()
    var actors: Array[Dictionary] = []
    for i in range(70):
        var actor := {
            "status_effects":{
                "v63_poison":[
                    {"owner_id":"casterA","source_skill_id":"poison","expires_at":9.0},
                    {"owner_id":"casterB","source_skill_id":"poison","expires_at":13.0}
                ],
                "burn":{"until":8.0},"weaken":{"until":11.0}
            },
            "v63_marks":{"ownerX":{"skill_id":"mark","until":10.0}},
            "learned_guard_until":12.0
        }
        actors.append(actor)
    var status_count := 0
    for actor in actors:
        var rows: Array[Dictionary] = POLICY.status_rows(actor,5.0)
        var compact: Dictionary = POLICY.compact_rows(rows)
        check(rows.size()==5,"5 active families per actor, no duplicates")
        check(compact["debuffs"].size()==2 and compact["debuff_overflow"]==2,"compact 2+2")
        status_count+=rows.size()
    var cues: Array[Dictionary]=[]
    for i in range(70):
        cues.append({"id":"hero_%03d"%i,"kind":"hero","selected":i==0})
        cues.append({"id":"impact_%03d"%i,"kind":"impact"})
        cues.append({"id":"ambient_%03d"%i,"kind":"ambient"})
    for i in range(8):
        cues.append({"id":"telegraph_%03d"%i,"kind":"telegraph","boss":true})
    for profile in ["lite","balanced","full"]:
        var result: Dictionary = POLICY.select_visuals(cues,profile)
        var limit: Dictionary = POLICY.PROFILES[profile]
        var c: Dictionary = result["counts"]
        check(int(c["hero"])<=int(limit["hero"]),"hero budget "+profile)
        check(int(c["impact"])<=int(limit["impact"]),"impact budget "+profile)
        check(int(c["ambient"])<=int(limit["ambient"]),"ambient budget "+profile)
        var warnings:=0
        for row in result["draw"]:
            if str(row.get("kind",""))=="telegraph": warnings+=1
        check(warnings==8,"all 8 telegraphs preserved "+profile)
    var elapsed_ms := float(Time.get_ticks_usec()-start)/1000.0
    check(actors.size()==70 and cues.size()==218 and status_count==350,"stress fixtures intact")
    print("VFX_F_STRESS_RESULT="+("PASS" if failed==0 else "FAIL")+" failures="+str(failed)+
        " actors=70 cues=218 visual_budget_only=true policy_cpu_ms="+str(elapsed_ms)+
        " NOT_GPU_FPS=true ANDROID_PHYSICAL=PENDING")
    quit(0 if failed==0 else 1)
