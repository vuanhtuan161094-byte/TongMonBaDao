extends Node3D
## AN-03 technical rig prototype. NOT the owner's illustrated Shadow 3D model.
## One common humanoid skeleton; separate skin attachments and swappable weapon.
## No Combat V2, PvE, VFX authority, SaveService or source-art claim.
const MOTIONS := ["idle", "walk", "attack"]
const PERIODS := {"idle":1.8, "walk":0.9, "attack":1.1}
const BONE_LAYOUT := [
    {"name":"hips","parent":"","offset":Vector3(0,1.12,0)},
    {"name":"spine","parent":"hips","offset":Vector3(0,0.43,0)},
    {"name":"head","parent":"spine","offset":Vector3(0,0.46,0)},
    {"name":"hair_tail","parent":"head","offset":Vector3(0,0.27,-0.16)},
    {"name":"upper_arm_L","parent":"spine","offset":Vector3(-0.38,0.24,0)},
    {"name":"forearm_L","parent":"upper_arm_L","offset":Vector3(0,-0.42,0)},
    {"name":"hand_L","parent":"forearm_L","offset":Vector3(0,-0.33,0)},
    {"name":"upper_arm_R","parent":"spine","offset":Vector3(0.38,0.24,0)},
    {"name":"forearm_R","parent":"upper_arm_R","offset":Vector3(0,-0.42,0)},
    {"name":"hand_R","parent":"forearm_R","offset":Vector3(0,-0.33,0)},
    {"name":"thigh_L","parent":"hips","offset":Vector3(-0.22,-0.08,0)},
    {"name":"shin_L","parent":"thigh_L","offset":Vector3(0,-0.52,0)},
    {"name":"foot_L","parent":"shin_L","offset":Vector3(0,-0.45,0.08)},
    {"name":"thigh_R","parent":"hips","offset":Vector3(0.22,-0.08,0)},
    {"name":"shin_R","parent":"thigh_R","offset":Vector3(0,-0.52,0)},
    {"name":"foot_R","parent":"shin_R","offset":Vector3(0,-0.45,0.08)},
    {"name":"coat_L","parent":"hips","offset":Vector3(-0.22,-0.08,-0.20)},
    {"name":"coat_R","parent":"hips","offset":Vector3(0.22,-0.08,-0.20)}
]

var _skeleton: Skeleton3D
var _bone_index: Dictionary = {}
var _socket_nodes: Dictionary = {}
var _weapon_root: Node3D
var _equipped := false
var _motion := "idle"
var _elapsed := 0.0
var _playing := true
var _speed := 1.0

func _ready() -> void:
    _build_rig()
    _create_guide_skin()
    _create_weapon()
    equip_weapon("none")
    seek(0.0)
    set_process(true)

func _build_rig() -> void:
    _skeleton = Skeleton3D.new()
    _skeleton.name = "SharedHumanoidSkeleton3D"
    add_child(_skeleton)
    for row in BONE_LAYOUT:
        var bone_name := str(row["name"])
        _bone_index[bone_name] = _skeleton.add_bone(bone_name)
    for row in BONE_LAYOUT:
        var name := str(row["name"])
        var index := int(_bone_index[name])
        var parent_name := str(row["parent"])
        if not parent_name.is_empty():
            _skeleton.set_bone_parent(index,int(_bone_index[parent_name]))
        _skeleton.set_bone_rest(index,Transform3D(Basis.IDENTITY,row["offset"]))
    for row in BONE_LAYOUT:
        var name := str(row["name"])
        var socket := BoneAttachment3D.new()
        socket.name = "Attach_" + name
        _skeleton.add_child(socket)
        socket.bone_name = name
        _socket_nodes[name] = socket

func _material(color: Color, glow: bool = false) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.55
    if glow:
        material.emission_enabled = true
        material.emission = color
        material.emission_energy_multiplier = 1.7
    return material

func _box(parent: Node3D, name: String, size: Vector3, offset: Vector3,
        material: Material) -> MeshInstance3D:
    var mesh := BoxMesh.new()
    mesh.size = size
    var instance := MeshInstance3D.new()
    instance.name = name
    instance.mesh = mesh
    instance.material_override = material
    instance.position = offset
    parent.add_child(instance)
    return instance

func _capsule(parent: Node3D, name: String, radius: float, height: float,
        offset: Vector3, material: Material) -> MeshInstance3D:
    var mesh := CapsuleMesh.new()
    mesh.radius = radius
    mesh.height = maxf(height, radius*2.0)
    var instance := MeshInstance3D.new()
    instance.name = name
    instance.mesh = mesh
    instance.material_override = material
    instance.position = offset
    parent.add_child(instance)
    return instance

func _sphere(parent: Node3D, name: String, radius: float, offset: Vector3,
        material: Material) -> MeshInstance3D:
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius*2.0
    var instance := MeshInstance3D.new()
    instance.name = name
    instance.mesh = mesh
    instance.material_override = material
    instance.position = offset
    parent.add_child(instance)
    return instance

func _create_guide_skin() -> void:
    # This is a procedural topology/rig guide, not the copyrighted/owner concept.
    # All pieces are separate skinnable slots. Real mesh must be supplied later.
    var dark := _material(Color(0.055,0.038,0.105))
    var purple := _material(Color(0.28,0.12,0.47))
    var gold := _material(Color(0.73,0.55,0.25))
    var glow := _material(Color(0.71,0.29,1.0),true)
    _box(_socket_nodes["hips"],"RobeWaist",Vector3(0.63,0.24,0.38),Vector3(0,-0.09,0),purple)
    _box(_socket_nodes["spine"],"ChestArmor",Vector3(0.7,0.69,0.41),Vector3(0,0.02,0),dark)
    _box(_socket_nodes["spine"],"GoldChestMark",Vector3(0.26,0.28,0.045),Vector3(0,0.03,0.23),gold)
    _sphere(_socket_nodes["head"],"MaskedFace",0.28,Vector3(0,0.11,0.04),dark)
    _sphere(_socket_nodes["head"],"EyeL",0.07,Vector3(-0.11,0.13,0.285),glow)
    _sphere(_socket_nodes["head"],"EyeR",0.07,Vector3(0.11,0.13,0.285),glow)
    _capsule(_socket_nodes["hair_tail"],"Ponytail",0.115,0.62,Vector3(0,-0.3,-0.06),purple)
    for side in ["L","R"]:
        _capsule(_socket_nodes["upper_arm_"+side],"Sleeve_"+side,0.17,0.43,
            Vector3(0,-0.22,0),purple)
        _capsule(_socket_nodes["forearm_"+side],"Forearm_"+side,0.11,0.32,
            Vector3(0,-0.16,0),dark)
        _sphere(_socket_nodes["hand_"+side],"Hand_"+side,0.115,
            Vector3(0,-0.04,0),dark)
        _capsule(_socket_nodes["thigh_"+side],"Thigh_"+side,0.16,0.53,
            Vector3(0,-0.27,0),purple)
        _capsule(_socket_nodes["shin_"+side],"Shin_"+side,0.125,0.47,
            Vector3(0,-0.24,0),dark)
        _box(_socket_nodes["foot_"+side],"Boot_"+side,Vector3(0.25,0.14,0.39),
            Vector3(0,-0.05,0.13),gold)
        _box(_socket_nodes["coat_"+side],"CoatTail_"+side,Vector3(0.31,0.8,0.10),
            Vector3(0,-0.40,-0.02),purple)

func _create_weapon() -> void:
    # Physically detached from the skin; attached by a single named hand socket.
    _weapon_root = Node3D.new()
    _weapon_root.name = "WeaponSocket_R"
    _socket_nodes["hand_R"].add_child(_weapon_root)
    var grip := _material(Color(0.17,0.10,0.21))
    var gold := _material(Color(0.72,0.49,0.23))
    var blade := _material(Color(0.65,0.27,1.0),true)
    _box(_weapon_root,"Grip",Vector3(0.09,0.30,0.09),Vector3(0,-0.12,0),grip)
    _box(_weapon_root,"Crossguard",Vector3(0.34,0.075,0.12),Vector3(0,-0.28,0),gold)
    _box(_weapon_root,"Blade",Vector3(0.10,0.95,0.065),Vector3(0,-0.80,0),blade)

func equip_weapon(weapon_id: String) -> bool:
    if weapon_id not in ["none","practice_sword"]:
        return false
    _equipped = weapon_id == "practice_sword"
    if _weapon_root != null:
        _weapon_root.visible = _equipped
    return true

func has_weapon() -> bool:
    return _equipped

func select_motion(name: String) -> bool:
    if name not in MOTIONS:
        return false
    _motion = name
    seek(0.0)
    return true

func play() -> void:
    _playing = true

func pause() -> void:
    _playing = false

func is_playing() -> bool:
    return _playing

func set_playback_speed(value: float) -> void:
    _speed = clampf(value,0.25,2.0)

func seek(time_seconds: float) -> void:
    _elapsed = maxf(0.0,time_seconds)
    _apply_pose()

func _process(delta: float) -> void:
    if not _playing:
        return
    _elapsed += delta * _speed
    _apply_pose()

func _axis(name: String, axis: Vector3, angle: float) -> void:
    _skeleton.set_bone_pose_rotation(int(_bone_index[name]),Quaternion(axis,angle))

func _apply_pose() -> void:
    if _skeleton == null:
        return
    for index in range(_skeleton.get_bone_count()):
        _skeleton.set_bone_pose_rotation(index,Quaternion.IDENTITY)
        _skeleton.set_bone_pose_position(index,Vector3.ZERO)
    if _motion == "idle":
        var phase := fposmod(_elapsed,PERIODS["idle"]) / PERIODS["idle"] * TAU
        var breathe := sin(phase)
        _skeleton.set_bone_pose_position(int(_bone_index["hips"]),
            Vector3(0,0.018*breathe,0))
        _axis("spine",Vector3.FORWARD,0.022*breathe)
        _axis("head",Vector3.FORWARD,-0.025*breathe)
        _axis("upper_arm_L",Vector3.FORWARD,0.045*breathe)
        _axis("upper_arm_R",Vector3.FORWARD,-0.045*breathe)
        _axis("hair_tail",Vector3.RIGHT,0.085*sin(phase-0.9))
        _axis("coat_L",Vector3.RIGHT,0.06*sin(phase-0.4))
        _axis("coat_R",Vector3.RIGHT,0.06*sin(phase-1.0))
    elif _motion == "walk":
        var phase := fposmod(_elapsed,PERIODS["walk"]) / PERIODS["walk"] * TAU
        var step := sin(phase)
        _skeleton.set_bone_pose_position(int(_bone_index["hips"]),
            Vector3(0,0.048*absf(sin(phase)),0))
        _axis("thigh_L",Vector3.RIGHT,0.50*step)
        _axis("thigh_R",Vector3.RIGHT,-0.50*step)
        _axis("shin_L",Vector3.RIGHT,-0.43*maxf(0.0,-step))
        _axis("shin_R",Vector3.RIGHT,-0.43*maxf(0.0,step))
        _axis("upper_arm_L",Vector3.RIGHT,-0.32*step)
        _axis("upper_arm_R",Vector3.RIGHT,0.32*step)
        _axis("spine",Vector3.FORWARD,0.055*sin(phase))
        _axis("hair_tail",Vector3.RIGHT,0.16*sin(phase-0.7))
        _axis("coat_L",Vector3.RIGHT,0.17*sin(phase-0.45))
        _axis("coat_R",Vector3.RIGHT,-0.17*sin(phase+0.30))
    else:
        # True continuous same-rig windup -> strike -> follow -> recovery.
        # Purely visual. It does not issue a combat hit event.
        var p := clampf(_elapsed / PERIODS["attack"],0.0,1.0)
        var swing := 0.0
        if p < 0.23:
            swing = lerpf(0.0,-1.05,p/0.23)
        elif p < 0.43:
            swing = lerpf(-1.05,1.35,(p-0.23)/0.20)
        elif p < 0.65:
            swing = lerpf(1.35,0.48,(p-0.43)/0.22)
        else:
            swing = lerpf(0.48,0.0,(p-0.65)/0.35)
        _axis("upper_arm_R",Vector3.FORWARD,swing)
        _axis("forearm_R",Vector3.FORWARD,0.4*absf(swing))
        _axis("spine",Vector3.UP,-0.48*swing)
        _axis("head",Vector3.FORWARD,-0.10*swing)
        _axis("thigh_R",Vector3.RIGHT,-0.24*absf(swing))
        _axis("thigh_L",Vector3.RIGHT,0.18*absf(swing))
        _axis("upper_arm_L",Vector3.FORWARD,0.35*swing)
        _axis("hair_tail",Vector3.RIGHT,0.38*swing)
        _axis("coat_L",Vector3.RIGHT,-0.26*swing)
        _axis("coat_R",Vector3.RIGHT,0.30*swing)

func get_bone_node() -> Skeleton3D:
    return _skeleton

func bone_pose(name: String) -> Quaternion:
    return _skeleton.get_bone_pose_rotation(int(_bone_index[name]))

func get_lab_evidence() -> Dictionary:
    return {
        "source_kind":"PROCEDURAL_RIG_GUIDE_NOT_OWNER_SHADOW_MESH",
        "authored_model_ready":false,
        "actual_3d_character_mesh_present":false,
        "bone_count":_skeleton.get_bone_count(),
        "skeleton_reusable":true,
        "right_hand_socket":_weapon_root != null
            and _weapon_root.get_parent() is BoneAttachment3D,
        "weapon_equipped":_equipped,
        "weapon_is_independent":true,
        "action":_motion,
        "seconds":_elapsed,
        "duration":PERIODS[_motion],
        "frames_baked":0,
        "eight_way_authored":false,
        "simulation_events":0
    }
