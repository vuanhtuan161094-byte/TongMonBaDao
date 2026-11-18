extends SceneTree
## F B/D/E pilot focused contract: no actor mutation, no external VFX proof claims.
const POLICY = preload("res://labs/combat_lab/vfx_shared_f_pilot/vfx_presentation_policy.gd")
const LAYER = preload("res://labs/combat_lab/vfx_shared_f_pilot/vfx_sprite_layer.gd")
var failures := 0
func ck(valid: bool, label: String) -> void:
    if not valid:
        failures += 1
        push_error("VFX_F_PILOT_FAIL " + label)
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var actor := {
        "status_effects":{
            "v63_poison":[
                {"owner_id":"a","source_skill_id":"one","expires_at":7.0},
                {"owner_id":"b","source_skill_id":"two","expires_at":12.0},
                {"owner_id":"c","source_skill_id":"old","expires_at":4.0}
            ],
            "burn":{"until":8.0},
            "weaken":{"until":9.0},
            "slow":{"until":4.0}
        },
        "v63_marks":{
            "a":{"skill_id":"fist","until":10.0},
            "b":{"skill_id":"talisman","until":13.0},
            "old":{"skill_id":"legacy","until":1.0}
        },
        "v63_blood_marks":{"a/fist":14.0},
        "learned_guard_until":11.0,
        "v63_capacity_shield_until":14.0,
        "v63_capacity_shield_remaining":15.0
    }
    var before := var_to_str(actor)
    var rows: Array[Dictionary] = POLICY.status_rows(actor,5.0)
    ck(var_to_str(actor) == before,"must not mutate Combat V2 snapshot")
    var by_family := {}
    for row in rows:
        by_family[row["family"]] = row
    ck(rows.size() == 5,"poison/burn/weaken/mark/guard, no slow or blood duplicate")
    ck(int(by_family["poison"]["stack_count"]) == 2,"two unexpired poison stacks")
    ck(by_family["poison"]["sources"].size() == 2,"two poison owners preserved")
    ck(is_equal_approx(float(by_family["poison"]["next_expiry"]),7.0),"next poison expiry")
    ck(is_equal_approx(float(by_family["poison"]["last_expiry"]),12.0),"last poison expiry")
    ck(int(by_family["mark"]["stack_count"]) == 2,"two real owners of mark")
    ck(by_family["mark"]["sources"].size() == 2,"marks retain source skill")
    ck(int(by_family["guard"]["stack_count"]) == 2,"guard and capacity co-exist without invented status")
    ck(not by_family.has("slow") and not by_family.has("v63_blood_marks"),"no ghost icon")
    var mini_result: Dictionary = POLICY.compact_rows(rows)
    ck(mini_result["debuffs"].size() == 2 and mini_result["debuff_overflow"] == 2,"max 2 + overflow")
    ck(mini_result["buffs"].size() == 1 and mini_result["buff_overflow"] == 0,"one buff family")
    var expanded: Dictionary = POLICY.compact_rows(rows,true)
    ck(expanded["debuff_overflow"] == 0,"selected actor expands status")
    var cues: Array[Dictionary] = [{"id":"warning","kind":"telegraph"}]
    for i in range(8):
        cues.append({"id":"hero"+str(i),"kind":"hero"})
    for i in range(11):
        cues.append({"id":"ambient"+str(i),"kind":"ambient"})
    cues.append({"id":"vital_hit","kind":"essential_hit"})
    cues.append({"id":"offscreen","kind":"hero","offscreen":true})
    var planned := POLICY.select_visuals(cues,"balanced")
    var ids: Array[String] = []
    for cue in planned["draw"]:
        ids.append(str(cue["id"]))
    ck(ids.has("warning"),"never cull essential telegraph")
    ck(ids.has("vital_hit"),"never cull confirmed important hit")
    ck(not ids.has("offscreen"),"offscreen cosmetic culled")
    ck(int(planned["counts"]["hero"]) <= 3 and int(planned["counts"]["ambient"]) <= 6,"balanced caps")
    ck(cues.size() == 22,"test fixture events untouched")
    var image := Image.create(64,32,false,Image.FORMAT_RGBA8)
    image.fill(Color(0.0,0.0,0.0,0.0))
    image.fill_rect(Rect2i(0,0,32,32),Color(0.2,0.8,0.8,1.0))
    image.fill_rect(Rect2i(32,0,32,32),Color(1.0,0.7,0.2,1.0))
    var atlas := ImageTexture.create_from_image(image)
    var layer = LAYER.new()
    root.add_child(layer)
    var configured: bool = layer.configure(atlas,[Rect2(0,0,32,32),Rect2(32,0,32,32)],"projectile",1.0)
    ck(configured,"separate original RGBA atlas can be injected")
    layer.set_anchors(Vector2(100,100),Vector2(300,200))
    layer.seek(0.5)
    ck(layer.rendered_frame == 1,"atlas selects independently authored pose")
    ck(layer.visual_anchor().distance_to(Vector2(200,150)) < 0.01,"target-tracking interpolation")
    layer.set_anchors(Vector2(100,100),Vector2(380,230))
    ck(layer.visual_anchor().distance_to(Vector2(240,165)) < 0.01,"moving recipient updates anchor")
    layer.seek(1.0)
    ck(layer.rendered_frame == -1,"sprite fully expires")
    ck(not layer.configure(atlas,[],"guard",2.0),"reject empty atlas")
    layer.queue_free()
    print("VFX_F_POLICY_TEST_RESULT=" + ("PASS" if failures == 0 else "FAIL") + " failures=" + str(failures) + " owner_art=PENDING pve=HOLD physical_qa=PENDING")
    quit(0 if failures == 0 else 1)
