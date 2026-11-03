extends SceneTree
## AN-03 isolated official Godot 4.7.2 runtime contract.
## Distinguish a REAL 3D skeleton movement prototype from missing owner GLB.
const ACTOR := preload("res://src/presentation/labs/an03_modular_character.gd")
const LAB := preload("res://scenes/labs/an03_modular_rig_lab.tscn")
var checks := 0

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, why: String) -> bool:
    if ok:
        checks += 1
        return true
    push_error("AN03_MODULAR_RIG_FAIL: " + why)
    quit(1)
    return false

func _run() -> void:
    var actor := ACTOR.new()
    root.add_child(actor)
    await process_frame
    var starting: Dictionary = actor.get_lab_evidence()
    if not _check(starting.get("bone_count",0) == 18,"18 required shared rig bones"):
        return
    if not _check(bool(starting.get("right_hand_socket",false)),
            "right-hand BoneAttachment3D socket missing"):
        return
    if not _check(not bool(starting.get("weapon_equipped",true)),
            "character must start unarmed"):
        return
    if not _check(bool(starting.get("weapon_is_independent",false)),
            "sword must not be baked into the body geometry"):
        return
    if not _check(not bool(starting.get("actual_3d_character_mesh_present",true)),
            "procedure guide must NOT masquerade as the owner's Tripo 3D asset"):
        return
    if not _check(not bool(starting.get("eight_way_authored",true)),
            "no authored eight-direction sprite assets"):
        return
    actor.pause()
    actor.select_motion("idle")
    actor.seek(0.0)
    var idle0: Quaternion = actor.bone_pose("upper_arm_R")
    actor.seek(0.48)
    var idle1: Quaternion = actor.bone_pose("upper_arm_R")
    if not _check(idle0.angle_to(idle1) > 0.02,
            "Idle must move bone poses, not repeat identical images"):
        return
    actor.select_motion("walk")
    actor.seek(0.0)
    var walk0: Quaternion = actor.bone_pose("thigh_R")
    actor.seek(0.23)
    var walk1: Quaternion = actor.bone_pose("thigh_R")
    if not _check(walk0.angle_to(walk1) > 0.3,
            "Walk must move legs through an actual skeletal gait"):
        return
    actor.select_motion("attack")
    actor.seek(0.22)
    var attack_windup: Quaternion = actor.bone_pose("upper_arm_R")
    actor.seek(0.46)
    var attack_strike: Quaternion = actor.bone_pose("upper_arm_R")
    actor.seek(1.1)
    var attack_recover: Quaternion = actor.bone_pose("upper_arm_R")
    if not _check(attack_windup.angle_to(attack_strike) > 1.0,
            "Attack must have distinct windup and strike poses"):
        return
    if not _check(attack_recover.angle_to(Quaternion.IDENTITY) < 0.02,
            "Attack must return to neutral recovery"):
        return
    if not _check(actor.equip_weapon("practice_sword") and actor.has_weapon(),
            "weapon attachment toggle must equip a distinct mesh"):
        return
    if not _check(actor.equip_weapon("none") and not actor.has_weapon(),
            "weapon must be removable without changing the body rig"):
        return
    if not _check(not actor.equip_weapon("unknown_sword") and not actor.has_weapon(),
            "invalid equipment must be rejected without side effects"):
        return
    if not _check(not actor.select_motion("fake_damage") and
            actor.get_lab_evidence().get("simulation_events",-1) == 0,
            "lab motion may not invent combat simulation events"):
        return
    actor.queue_free()
    await process_frame
    var lab := LAB.instantiate()
    root.add_child(lab)
    await process_frame
    if not _check(lab is Node3D and lab.get_sample_actor() is Node3D,
            "separate AN-03 lab scene must instantiate"):
        return
    lab.configure_for_capture("walk",true,0.23)
    var evidence: Dictionary = lab.sample_evidence()
    if not _check(evidence.get("action","") == "walk"
            and bool(evidence.get("weapon_equipped",false)),
            "animation lab controls did not affect real rig and socket"):
        return
    print("AN03_MODULAR_RIG_FOCUSED PASS | checks=%d | actual 18-bone guide, owner GLB pending" % checks)
    lab.queue_free()
    quit(0)
