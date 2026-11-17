extends SceneTree
## Exact-SHA internal A/B QA. Existing JX1/Source VL atlas bytes and metadata
## are reused without importing commercial source into new gameplay systems.
const SCENE=preload("res://labs/combat_lab/jx_reference_preview/r1/jx_reference_preview.gd")
const FX_LAYER=preload("res://labs/combat_lab/jx_reference_preview/r1/jx_effect_layer.gd")
const ATLAS=preload("res://src/presentation/p3/combat_v4_effect_atlas.gd")
var failures:=0
func check(ok: bool,msg: String)->void:
    if not ok:
        failures+=1
        push_error("JX_VLTK_COMPARE_FAIL "+msg)
func _initialize()->void:
    call_deferred("_run")
func _run()->void:
    var atlas:=ATLAS.new()
    var expected={
        "jx_wudang_158_precast":[10,.50],
        "jx_wudang_158_cast":[17,.85],
        "jx_wudang_158_impact":[8,.32],
        "jx_wudu_63_impact":[13,.728],
        "sword_cast":[36,1.08],
        "sword_hit":[21,.63]
    }
    check(atlas.effects.size()>=6,"two original existing manifests loaded")
    for id in expected:
        check(atlas.effects.has(id),"missing already-imported source "+id)
        if not atlas.effects.has(id):
            continue
        var meta: Dictionary=atlas.effects[id]
        check(int(meta.get("frames",0))==int(expected[id][0]),"authored frame count "+id)
        check(absf(atlas.duration(id)-float(expected[id][1]))<.001,"original frame_ms clip duration "+id)
        check(not atlas.frame_region(id,.08).is_empty(),"original cropped WebP frame exists "+id)
        check(atlas.frame_region(id,atlas.duration(id)+.03).is_empty(),"source clip really expires "+id)
    check(not atlas.effects.has("jx_wudu_63_precast"),"do not fabricate nonexistent Ngũ Độc precast")
    check(SCENE.TOTAL_SECONDS==12.0 and SCENE.STYLE_COUNT==4,"four side-by-side style slots 3 secs each")
    check(SCENE.target_foot(.2).distance_to(SCENE.target_foot(1.75))>20.0,"selected target WALK movement")
    check(SCENE.target_foot(1.2).distance_to(SCENE.decoy_foot(1.2))>120.0,"independent untouched moving decoy")
    var source:=FileAccess.get_file_as_string("res://labs/combat_lab/jx_reference_preview/r1/jx_reference_preview.gd")
    var fx_source:=FileAccess.get_file_as_string("res://labs/combat_lab/jx_reference_preview/r1/jx_effect_layer.gd")
    for banned in ["apply_damage(","apply_status(","apply_poison(","SaveService.","CombatV2.","MapBattleV2.","health =","hp ="]:
        check(not source.contains(banned) and not fx_source.contains(banned),"preview must not mutate authoritative gameplay "+banned)
    check(fx_source.contains("atlas.draw_effect(self") and fx_source.contains("jx_wudu_63_impact") and fx_source.contains("sword_hit"),"original asset frames drawn by Godot")
    var lab:=SCENE.new()
    root.add_child(lab)
    await process_frame
    check(lab.jx_layer!=null and lab.r3_layer!=null,"JX1 + POI19 R3 actually instantiated inside Godot")
    if lab.jx_layer!=null:
        check(lab.jx_layer.material is CanvasItemMaterial,"source effects have isolated 2D blend layer")
        for mode in range(3):
            lab.jx_layer.update_cue(mode,1.48,SCENE.target_foot(1.48))
            check(lab.jx_layer.current_style==mode,"switchable real in-project scene style "+str(mode))
    lab.manual_style=3
    lab.clock=.98
    lab._sync(true)
    check(lab.r3_layer.visible,"POI19 R3 baseline can be rendered on same battle stage")
    check(lab.r3_layer.energy_flow!=null,"baseline remains real native Godot, not screenshot")
    lab.queue_free()
    print("JX_VLTK_COMPARE_RESULT=",("PASS" if failures==0 else "FAIL")," failures=",failures)
    quit(0 if failures==0 else 1)
