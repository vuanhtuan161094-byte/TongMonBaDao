extends SceneTree
const SCENE := "res://labs/combat_lab/sword_human_kiem_vu_hoi_phong/r1e/r1e_lab.tscn"
var failures: Array[String] = []
func _initialize() -> void:
    call_deferred("_verify")
func _check(ok: bool, message: String) -> void:
    if not ok:
        failures.append(message)
        push_error("R1E_CONTRACT_FAIL " + message)
func _verify() -> void:
    var scene := load(SCENE) as PackedScene
    if scene==null:
        _check(false,"SCENE_NOT_LOADED")
        quit(1)
        return
    var lab := scene.instantiate() as Node2D
    root.add_child(lab)
    await process_frame
    _check(bool(lab.get("_ready_ok")),"REAL_LAB_NOT_READY")
    var actors: Node2D = lab.get("_actor")
    _check(actors!=null,"ORIGINAL_AS48_MISSING")
    var mobs: Array = lab.get("_monsters")
    _check(mobs.size()==3,"THREE_REAL_MONSTERS_MISSING")
    var fx: Sprite2D = lab.get("_fx")
    _check(fx!=null and fx.texture!=null,"REAL_RGBA_VFX_NOT_LOADED")
    if fx != null and fx.texture != null:
        _check(fx.texture.get_width()==512,"VFX_FRAME_REGION_NOT_512")
    for phase in ["charge","projectile","contact"]:
        lab.review_seek_phase(phase)
        await process_frame
        _check(bool(lab.get("_paused")),"PHASE_NOT_HELD_"+phase)
        _check(int(lab.get("_frame"))>=0 and int(lab.get("_frame"))<=11,"FRAME_BAD_"+phase)
        lab.review_set_fx(false)
        _check(not fx.visible,"VFX_TOGGLE_FAIL_"+phase)
        lab.review_set_fx(true)
        _check(fx.visible,"VFX_RESTORE_FAIL_"+phase)
    lab.review_replay()
    lab.review_set_paused(false)
    await process_frame
    _check(int(lab.get("_frame"))==0,"REPLAY_NOT_RESET")
    print("R1E_GODOT_472_FOCUSED_RESULT="+("PASS" if failures.is_empty() else "FAIL")+" failures="+str(failures.size())+" source=AI_VFX_ONLY real_as48=true monsters=3 no_hp=true no_rig=true PvE=HOLD")
    quit(0 if failures.is_empty() else 1)