extends SceneTree
## AN-02 official Godot 4.7.2 focused smoke. Separate source actor
## playback + truthful direction/fallback + Shadow-only presentation.
const SCENE := preload("res://scenes/labs/an02_animation_lab.tscn")
var checks := 0

func _init() -> void:
    call_deferred("_run")

func _check(condition: bool, message: String) -> bool:
    if condition:
        checks += 1
        return true
    push_error("AN02_ANIMATION_LAB_FAIL: " + message)
    quit(1)
    return false

func _run() -> void:
    var lab := SCENE.instantiate()
    root.add_child(lab)
    await process_frame
    if not _check(lab != null and lab is Control, "standalone lab scene did not instantiate"):
        return
    if not _check(lab.get_node_or_null("ActualSourceAFrame") is Sprite2D,
            "real SpriteFrames output node missing"):
        return
    # Indices: shadow 0, male 1, female 2, wolf 3, Boss 4.
    # Actions: idle 0, walk 1, run 2, attack 3, hit 4, die 5, cast 6.
    for actor_index in range(5):
        for action_index in [0, 1, 3, 4, 5]:
            lab.configure_preview(actor_index, action_index, 0, actor_index == 0)
            var data: Dictionary = lab.sample_evidence()
            if not _check(bool(data.get("frame_loaded",false)),
                    "authentic frame missing: actor %d action %d" % [actor_index,action_index]):
                return
            var clip: Dictionary = data.get("source_clip",{})
            if not _check(int(clip.get("frames",0)) > 0
                    and float(clip.get("duration",0.0)) > 0.0,
                    "invalid source clip duration/frame count"):
                return
            if not _check(bool(data.get("presentation_only",false)),
                    "lab must remain view-only"):
                return
            if not _check(bool(data.get("anchor_within_texture",false))
                    and float(data.get("preview_foot_error_px",INF)) <= 0.1,
                    "Source A source anchor/preview foot drift: actor %d action %d" % [actor_index,action_index]):
                return
            var dimensions: Vector2 = data.get("source_texture_size",Vector2.ZERO)
            if not _check(dimensions.x > 0.0 and dimensions.y > 0.0,
                    "invalid actual atlas subtexture size"):
                return
    lab.configure_preview(2,6,0,false)
    var cast: Dictionary = lab.sample_evidence()
    if not _check(bool(cast.get("source_clip",{}).get("fallback",false))
            and str(cast.get("source_clip",{}).get("clip","")) == "attack1",
            "cast must report honest female attack1 fallback"):
        return
    lab.configure_preview(0,3,0,true)
    var shadow: Dictionary = lab.sample_evidence()
    if not _check(bool(shadow.get("shadow_prototype",false))
            and str(shadow.get("actor_key","")) == "disciple_male",
            "Shadow actor must preserve source male identity"):
        return
    var source_sprite := lab.get_node("ActualSourceAFrame") as Sprite2D
    if not _check(source_sprite.texture != null and source_sprite.material is ShaderMaterial,
            "Shadow shader must apply on a real Source A frame"):
        return
    for direction_index in range(8):
        lab.configure_preview(0,3,direction_index,true)
        var facing: Dictionary = lab.sample_evidence()
        if not _check(bool(facing.get("frame_loaded",false))
                and not bool(facing.get("authored_eight_way",true))
                and str(facing.get("direction_fidelity","")) == "FACING_ONLY_MIRRORED",
                "eight-direction control must not fabricate authored source art"):
            return
        if not _check(bool(facing.get("anchor_within_texture",false))
                and float(facing.get("preview_foot_error_px",INF)) <= 0.1,
                "flip/anchor drift at requested direction %d" % direction_index):
            return
        # Source A's original physical facing is LEFT. Only horizontal mirror
        # is available in this lab, even when the selector names 8 directions.
        var expected_flip := direction_index in [0,1,2,6,7]
        if not _check(bool(facing.get("source_mirrored",not expected_flip)) == expected_flip,
                "mirrored source facing disagreement at %d" % direction_index):
            return
    # Actual adapter fallback: Boss has "run" but no native "walk".
    lab.configure_preview(4,1,0,false)
    var boss_walk: Dictionary = lab.sample_evidence()
    if not _check(bool(boss_walk.get("source_clip",{}).get("fallback",false))
            and str(boss_walk.get("source_clip",{}).get("clip","")) == "run",
            "Boss walk must visibly report the run fallback"):
        return
    # SpriteFrames stores 21 frames for the 30-logical-frame Boss dead
    # animation. Its per-frame duration must remain 1 sec, not 21/30 sec.
    lab.configure_preview(4,5,0,false)
    var boss_dead: Dictionary = lab.sample_evidence()
    if not _check(int(boss_dead.get("source_clip",{}).get("frames",0)) == 21
            and absf(float(boss_dead.get("source_clip",{}).get("duration",0.0)) - 1.0) < 0.01,
            "Boss death logical duration must be 1 sec for 21 stored frames"):
        return
    lab.set_preview_elapsed_for_qa(100.0)
    var boss_dead_end: Dictionary = lab.sample_evidence()
    if not _check(int(boss_dead_end.get("frame_index",-1)) == 20,
            "nonlooping Boss dead must hold its final frame"):
        return
    # Authentic male attack1 is 29 non-looping frames.
    lab.configure_preview(1,3,0,false)
    lab.set_preview_elapsed_for_qa(100.0)
    var male_attack_end: Dictionary = lab.sample_evidence()
    if not _check(int(male_attack_end.get("frame_index",-1)) == 28,
            "nonlooping male attack must hold frame 28 of 29"):
        return
    # Stand is a looping clip, so advancing by >1 full cycle does not freeze.
    lab.configure_preview(1,0,0,false)
    lab.set_preview_elapsed_for_qa(0.0)
    var idle_first: Dictionary = lab.sample_evidence()
    lab.set_preview_elapsed_for_qa(0.31)
    var idle_later: Dictionary = lab.sample_evidence()
    if not _check(int(idle_first.get("frame_index",-1)) != int(idle_later.get("frame_index",-1)),
            "looping stand clip did not advance frames"):
        return
    lab.configure_preview(1,3,0,false)
    if not _check(source_sprite.material == null,
            "normal Source A preview must not retain Shadow material"):
        return
    print("AN02_ANIMATION_LAB_FOCUSED PASS | checks=%d | source=real Source A | no game state" % checks)
    lab.queue_free()
    quit(0)
