class_name FemaleNormalV1MotionLibrary
extends RefCounted

const IDLE_LENGTH := 1.60
const WALK_LENGTH := 0.80
const AUTHORED_DIRECTIONS: Array[StringName] = [&"down", &"right", &"up"]

static func build() -> AnimationLibrary:
    var library := AnimationLibrary.new()
    for direction in AUTHORED_DIRECTIONS:
        library.add_animation(DiscipleActorVisualCatalog.animation_name(&"idle", direction), _build_idle(direction))
        library.add_animation(DiscipleActorVisualCatalog.animation_name(&"walk", direction), _build_walk(direction))
    return library

static func required_animation_names() -> Array[StringName]:
    var result: Array[StringName] = []
    for direction in AUTHORED_DIRECTIONS:
        result.append(DiscipleActorVisualCatalog.animation_name(&"idle", direction))
        result.append(DiscipleActorVisualCatalog.animation_name(&"walk", direction))
    return result

static func _build_idle(direction: StringName) -> Animation:
    var animation := Animation.new()
    animation.length = IDLE_LENGTH
    animation.loop_mode = Animation.LOOP_LINEAR

    var half := IDLE_LENGTH * 0.5
    var pelvis_rest := DiscipleActorVisualCatalog.bone_rest_position(&"pelvis")
    var head_rest := DiscipleActorVisualCatalog.bone_rest_position(&"head")

    var breath := 0.75 if direction != &"right" else 0.55
    var torso_sway := 0.012 if direction == &"down" else 0.009

    _add_track(animation, _bone_property_path(&"pelvis", "position"), [
        [0.0, pelvis_rest],
        [half, pelvis_rest + Vector2(0.0, -breath)],
        [IDLE_LENGTH, pelvis_rest]
    ])
    _add_track(animation, _bone_property_path(&"head", "position"), [
        [0.0, head_rest],
        [half, head_rest + Vector2(0.0, -0.35)],
        [IDLE_LENGTH, head_rest]
    ])
    _add_track(animation, _bone_property_path(&"torso", "rotation"), [
        [0.0, -torso_sway],
        [half, torso_sway],
        [IDLE_LENGTH, -torso_sway]
    ])
    _add_track(animation, _bone_property_path(&"arm_l", "rotation"), [
        [0.0, 0.010],
        [half, -0.010],
        [IDLE_LENGTH, 0.010]
    ])
    _add_track(animation, _bone_property_path(&"arm_r", "rotation"), [
        [0.0, -0.010],
        [half, 0.010],
        [IDLE_LENGTH, -0.010]
    ])
    return animation

static func _build_walk(direction: StringName) -> Animation:
    var animation := Animation.new()
    animation.length = WALK_LENGTH
    animation.loop_mode = Animation.LOOP_LINEAR

    var quarter := WALK_LENGTH * 0.25
    var half := WALK_LENGTH * 0.5
    var three_quarter := WALK_LENGTH * 0.75
    var pelvis_rest := DiscipleActorVisualCatalog.bone_rest_position(&"pelvis")
    var head_rest := DiscipleActorVisualCatalog.bone_rest_position(&"head")

    var leg_swing := 0.10 if direction != &"right" else 0.085
    var arm_swing := 0.075 if direction != &"right" else 0.060
    var torso_sway := 0.018 if direction == &"down" else 0.013

    _add_track(animation, _bone_property_path(&"pelvis", "position"), [
        [0.0, pelvis_rest],
        [quarter, pelvis_rest + Vector2(0.0, -1.15)],
        [half, pelvis_rest],
        [three_quarter, pelvis_rest + Vector2(0.0, -1.15)],
        [WALK_LENGTH, pelvis_rest]
    ])
    _add_track(animation, _bone_property_path(&"head", "position"), [
        [0.0, head_rest],
        [quarter, head_rest + Vector2(0.0, -0.40)],
        [half, head_rest],
        [three_quarter, head_rest + Vector2(0.0, -0.40)],
        [WALK_LENGTH, head_rest]
    ])
    _add_track(animation, _bone_property_path(&"torso", "rotation"), [
        [0.0, -torso_sway],
        [half, torso_sway],
        [WALK_LENGTH, -torso_sway]
    ])
    _add_track(animation, _bone_property_path(&"leg_l", "rotation"), [
        [0.0, leg_swing],
        [half, -leg_swing],
        [WALK_LENGTH, leg_swing]
    ])
    _add_track(animation, _bone_property_path(&"leg_r", "rotation"), [
        [0.0, -leg_swing],
        [half, leg_swing],
        [WALK_LENGTH, -leg_swing]
    ])
    _add_track(animation, _bone_property_path(&"arm_l", "rotation"), [
        [0.0, -arm_swing],
        [half, arm_swing],
        [WALK_LENGTH, -arm_swing]
    ])
    _add_track(animation, _bone_property_path(&"arm_r", "rotation"), [
        [0.0, arm_swing],
        [half, -arm_swing],
        [WALK_LENGTH, arm_swing]
    ])
    return animation

static func _add_track(animation: Animation, path: NodePath, keys: Array) -> void:
    var track := animation.add_track(Animation.TYPE_VALUE)
    animation.track_set_path(track, path)
    animation.track_set_interpolation_type(track, Animation.INTERPOLATION_LINEAR)
    for key in keys:
        animation.track_insert_key(track, float(key[0]), key[1])

static func _bone_property_path(bone_id: StringName, property_name: String) -> NodePath:
    return NodePath("%s:%s" % [_bone_node_path(bone_id), property_name])

static func _bone_node_path(bone_id: StringName) -> String:
    match bone_id:
        &"root":
            return "RigRoot/Skeleton2D/Root"
        &"pelvis":
            return "RigRoot/Skeleton2D/Root/Pelvis"
        &"torso":
            return "RigRoot/Skeleton2D/Root/Pelvis/Torso"
        &"head":
            return "RigRoot/Skeleton2D/Root/Pelvis/Torso/Head"
        &"arm_l":
            return "RigRoot/Skeleton2D/Root/Pelvis/Torso/ArmL"
        &"arm_r":
            return "RigRoot/Skeleton2D/Root/Pelvis/Torso/ArmR"
        &"hand_weapon":
            return "RigRoot/Skeleton2D/Root/Pelvis/Torso/ArmR/HandWeapon"
        &"leg_l":
            return "RigRoot/Skeleton2D/Root/Pelvis/LegL"
        &"leg_r":
            return "RigRoot/Skeleton2D/Root/Pelvis/LegR"
        _:
            return "RigRoot/Skeleton2D/Root"
