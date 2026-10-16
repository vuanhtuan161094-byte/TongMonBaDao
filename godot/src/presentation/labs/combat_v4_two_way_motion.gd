class_name CombatV4TwoWayMotion
extends RefCounted
## Isolated two-direction bone motions. Existing Stage A cutouts provide appearance.
## Only authored RIGHT animation, LEFT mirrors the same rig; NO up/down art needed.
const ATTACK_SECONDS := 0.36
const HIT_SECONDS := 0.28

static func build() -> AnimationLibrary:
    var library := FemaleNormalV1MotionLibrary.build()
    library.add_animation(&"attack_right", _attack())
    library.add_animation(&"hit_right", _hit())
    return library

static func _attack() -> Animation:
    var a := Animation.new()
    a.length = ATTACK_SECONDS
    a.loop_mode = Animation.LOOP_NONE
    _track(a, "RigRoot/Skeleton2D/Root/Pelvis/Torso/ArmR:rotation", [
        [0.0, -0.12], [0.09, -0.85], [0.18, 0.70], [0.29, 0.15], [ATTACK_SECONDS, 0.0]
    ])
    _track(a, "RigRoot/Skeleton2D/Root/Pelvis/Torso/ArmL:rotation", [
        [0.0, 0.02], [0.1, 0.25], [0.18, -0.16], [ATTACK_SECONDS, 0.0]
    ])
    _track(a, "RigRoot/Skeleton2D/Root/Pelvis/Torso:rotation", [
        [0.0, 0.0], [0.10, -0.10], [0.18, 0.17], [ATTACK_SECONDS, 0.0]
    ])
    _track(a, "RigRoot/Skeleton2D/Root/Pelvis/LegL:rotation", [
        [0.0, 0.0], [0.12, -0.09], [ATTACK_SECONDS, 0.0]
    ])
    _track(a, "RigRoot/Skeleton2D/Root/Pelvis/LegR:rotation", [
        [0.0, 0.0], [0.12, 0.09], [ATTACK_SECONDS, 0.0]
    ])
    return a

static func _hit() -> Animation:
    var a := Animation.new()
    a.length = HIT_SECONDS
    a.loop_mode = Animation.LOOP_NONE
    _track(a, "RigRoot/Skeleton2D/Root/Pelvis/Torso:rotation", [
        [0.0, 0.0], [0.08, -0.16], [0.17, -0.07], [HIT_SECONDS, 0.0]
    ])
    _track(a, "RigRoot/Skeleton2D/Root/Pelvis/Torso/ArmR:rotation", [
        [0.0, 0.0], [0.08, -0.22], [HIT_SECONDS, 0.0]
    ])
    _track(a, "RigRoot/Skeleton2D/Root/Pelvis/Torso/ArmL:rotation", [
        [0.0, 0.0], [0.08, 0.27], [HIT_SECONDS, 0.0]
    ])
    return a

static func _track(a: Animation, target: String, samples: Array) -> void:
    var index := a.add_track(Animation.TYPE_VALUE)
    a.track_set_path(index, NodePath(target))
    a.track_set_interpolation_type(index, Animation.INTERPOLATION_LINEAR)
    for sample in samples:
        a.track_insert_key(index, float(sample[0]), float(sample[1]))
