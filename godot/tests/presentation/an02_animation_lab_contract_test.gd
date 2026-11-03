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
    lab.configure_preview(1,3,0,false)
    if not _check(source_sprite.material == null,
            "normal Source A preview must not retain Shadow material"):
        return
    print("AN02_ANIMATION_LAB_FOCUSED PASS | checks=%d | source=real Source A | no game state" % checks)
    lab.queue_free()
    quit(0)
