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
    var source_glow: Sprite2D = lab.get("_fx_glow")
    _check(source_glow != null and source_glow.texture == fx.texture,"GLOW_MUST_FOLLOW_R1E_SOURCE")
    if source_glow != null:
        var additive: CanvasItemMaterial = source_glow.material as CanvasItemMaterial
        _check(additive != null and additive.blend_mode == CanvasItemMaterial.BLEND_MODE_ADD,"GLOW_NOT_ADDITIVE")
    _check(bool(lab.get("_version_v2")),"V2_NOT_DEFAULT")
    var atlas: Texture2D = lab.get("_v2_vfx_texture")
    _check(atlas != null and atlas.get_size()==Vector2(2048,3072),"V2_ATLAS_NOT_2048x3072")
    for phase in ["charge","projectile","contact"]:
        lab.review_seek_phase(phase)
        await process_frame
        _check(bool(lab.get("_paused")),"PHASE_NOT_HELD_"+phase)
        _check(int(lab.get("_frame"))>=0 and int(lab.get("_frame"))<=23,"FRAME_BAD_"+phase)
        lab.review_set_fx(false)
        _check(not fx.visible,"VFX_TOGGLE_FAIL_"+phase)
        _check(not source_glow.visible,"GLOW_TOGGLE_FAIL_"+phase)
        lab.review_set_fx(true)
        _check(fx.visible,"VFX_RESTORE_FAIL_"+phase)
        _check(source_glow.visible,"GLOW_RESTORE_FAIL_"+phase)
        _check(fx.position.distance_to(source_glow.position)<0.01,"GLOW_DETACHED_"+phase)
    # Art-direction regression: R1E must travel as a blade-attached gyre,
    # not teleport from a hard-coded mid-map point to the monsters.
    lab.review_set_paused(true)
    lab.set("_time",0.36)
    lab.call("_set_frame",9)
    lab.call("_update_positions")
    var start_gyre: Vector2 = fx.position
    lab.set("_time",0.54)
    lab.call("_set_frame",13)
    lab.call("_update_positions")
    var later_gyre: Vector2 = fx.position
    _check(later_gyre.x > start_gyre.x + 35.0,"GYRE_NOT_ADVANCING_WITH_SWORD")
    lab.set("_time",0.70)
    lab.call("_set_frame",17)
    lab.call("_update_positions")
    var pre_contact: Vector2 = fx.position
    lab.set("_time",0.72)
    lab.call("_set_frame",18)
    lab.call("_update_positions")
    var contact_pos: Vector2 = fx.position
    _check(pre_contact.distance_to(contact_pos)<110.0,"CONTACT_TELEPORTS")
    _check(fx.visible,"VFX_HIDDEN_DURING_CONTACT")
    for mob in mobs:
        _check(mob.modulate != Color.WHITE,"CONTACT_REACTION_NOT_VISIBLE")
    lab.review_set_map_zoom(true)
    _check(actors.scale.x > 0.25,"ZOOM_MISLABELLED_VFX_ONLY")
    lab.review_set_map_zoom(false)
    _check(absf(actors.scale.x-0.17)<0.01,"ZOOM_NOT_RESTORED")
    print("R1E_CONTINUOUS_BLADE_TIP_TO_CONTACT=PASS movement/impact/zoom SOURCE_ART_UNCHANGED")
    lab.review_set_version("r1e")
    _check(not bool(lab.get("_version_v2")),"LEGACY_TOGGLE_FAILED")
    _check(lab.get("_fx_cell").atlas.get_size()==Vector2(2048,1536),"LEGACY_ATLAS_BAD")
    lab.review_seek_phase("contact")
    _check(int(lab.get("_frame"))==9,"LEGACY_CONTACT_FRAME_BAD")
    lab.review_set_version("v2")
    _check(bool(lab.get("_version_v2")),"V2_RESTORE_FAILED")
    _check(lab.get("_fx_cell").atlas.get_size()==Vector2(2048,3072),"V2_ATLAS_RESTORE_FAILED")
    print("R1E_V2_GODOT_REVIEW=PASS frames=24 fps=25 compare_legacy=true no_pve=true")
    lab.review_replay()
    lab.review_set_paused(false)
    await process_frame
    _check(int(lab.get("_frame"))==0,"REPLAY_NOT_RESET")
    print("R1E_GODOT_472_FOCUSED_RESULT="+("PASS" if failures.is_empty() else "FAIL")+" failures="+str(failures.size())+" source=AI_VFX_ONLY real_as48=true monsters=3 no_hp=true no_rig=true PvE=HOLD")
    quit(0 if failures.is_empty() else 1)