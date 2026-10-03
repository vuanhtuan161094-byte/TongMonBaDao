class_name FemaleStageAAssetLoader
extends RefCounted

const ROOT := "res://assets/p3/character_creator/parts/female_normal_v1"
const AUTHORED_DIRECTIONS := [&"down", &"right", &"up"]
const LAYERS_TO_CLEAR := [&"hair_back", &"body", &"outfit", &"face", &"hair_front", &"head_accessory"]

const DOWN_COMPONENTS := [
    {"path": ROOT + "/hair/hair_01/hair_01_down_back.png", "layer": &"hair_back", "component": &"back", "bone": &"head"},
    {"path": ROOT + "/body/body_01/body_01_down_head.png", "layer": &"body", "component": &"head", "bone": &"head"},
    {"path": ROOT + "/body/body_01/body_01_down_torso.png", "layer": &"body", "component": &"torso", "bone": &"torso"},
    {"path": ROOT + "/body/body_01/body_01_down_arm_l.png", "layer": &"body", "component": &"arm_l", "bone": &"arm_l"},
    {"path": ROOT + "/body/body_01/body_01_down_arm_r.png", "layer": &"body", "component": &"arm_r", "bone": &"arm_r"},
    {"path": ROOT + "/body/body_01/body_01_down_leg_l.png", "layer": &"body", "component": &"leg_l", "bone": &"leg_l"},
    {"path": ROOT + "/body/body_01/body_01_down_leg_r.png", "layer": &"body", "component": &"leg_r", "bone": &"leg_r"},
    {"path": ROOT + "/outfit/outfit_01/outfit_01_down_torso.png", "layer": &"outfit", "component": &"torso", "bone": &"torso"},
    {"path": ROOT + "/outfit/outfit_01/outfit_01_down_arm_l.png", "layer": &"outfit", "component": &"arm_l", "bone": &"arm_l"},
    {"path": ROOT + "/outfit/outfit_01/outfit_01_down_arm_r.png", "layer": &"outfit", "component": &"arm_r", "bone": &"arm_r"},
    {"path": ROOT + "/outfit/outfit_01/outfit_01_down_skirt.png", "layer": &"outfit", "component": &"skirt", "bone": &"torso"},
    {"path": ROOT + "/face/face_01/face_01_down.png", "layer": &"face", "component": &"main", "bone": &"head"},
    {"path": ROOT + "/hair/hair_01/hair_01_down_front.png", "layer": &"hair_front", "component": &"front", "bone": &"head"},
    {"path": ROOT + "/head_accessory/horn_01/horn_01_down.png", "layer": &"head_accessory", "component": &"horn", "bone": &"head"}
]

const RIGHT_COMPONENTS := [
    {"path": ROOT + "/hair/hair_01/hair_01_right_back.png", "layer": &"hair_back", "component": &"back", "bone": &"head"},
    {"path": ROOT + "/body/body_01/body_01_right_head.png", "layer": &"body", "component": &"head", "bone": &"head"},
    {"path": ROOT + "/body/body_01/body_01_right_torso.png", "layer": &"body", "component": &"torso", "bone": &"torso"},
    {"path": ROOT + "/body/body_01/body_01_right_arm_l.png", "layer": &"body", "component": &"arm_l", "bone": &"arm_l"},
    {"path": ROOT + "/body/body_01/body_01_right_arm_r.png", "layer": &"body", "component": &"arm_r", "bone": &"arm_r"},
    {"path": ROOT + "/body/body_01/body_01_right_leg_l.png", "layer": &"body", "component": &"leg_l", "bone": &"leg_l"},
    {"path": ROOT + "/body/body_01/body_01_right_leg_r.png", "layer": &"body", "component": &"leg_r", "bone": &"leg_r"},
    {"path": ROOT + "/outfit/outfit_01/outfit_01_right_torso.png", "layer": &"outfit", "component": &"torso", "bone": &"torso"},
    {"path": ROOT + "/outfit/outfit_01/outfit_01_right_arm_l.png", "layer": &"outfit", "component": &"arm_l", "bone": &"arm_l"},
    {"path": ROOT + "/outfit/outfit_01/outfit_01_right_arm_r.png", "layer": &"outfit", "component": &"arm_r", "bone": &"arm_r"},
    {"path": ROOT + "/outfit/outfit_01/outfit_01_right_skirt.png", "layer": &"outfit", "component": &"skirt", "bone": &"torso"},
    {"path": ROOT + "/face/face_01/face_01_right.png", "layer": &"face", "component": &"main", "bone": &"head"},
    {"path": ROOT + "/hair/hair_01/hair_01_right_front.png", "layer": &"hair_front", "component": &"front", "bone": &"head"},
    {"path": ROOT + "/head_accessory/horn_01/horn_01_right.png", "layer": &"head_accessory", "component": &"horn", "bone": &"head"}
]

const UP_COMPONENTS := [
    {"path": ROOT + "/hair/hair_01/hair_01_up_back.png", "layer": &"hair_back", "component": &"back", "bone": &"head"},
    {"path": ROOT + "/body/body_01/body_01_up_head.png", "layer": &"body", "component": &"head", "bone": &"head"},
    {"path": ROOT + "/body/body_01/body_01_up_torso.png", "layer": &"body", "component": &"torso", "bone": &"torso"},
    {"path": ROOT + "/body/body_01/body_01_up_arm_l.png", "layer": &"body", "component": &"arm_l", "bone": &"arm_l"},
    {"path": ROOT + "/body/body_01/body_01_up_arm_r.png", "layer": &"body", "component": &"arm_r", "bone": &"arm_r"},
    {"path": ROOT + "/body/body_01/body_01_up_leg_l.png", "layer": &"body", "component": &"leg_l", "bone": &"leg_l"},
    {"path": ROOT + "/body/body_01/body_01_up_leg_r.png", "layer": &"body", "component": &"leg_r", "bone": &"leg_r"},
    {"path": ROOT + "/outfit/outfit_01/outfit_01_up_torso.png", "layer": &"outfit", "component": &"torso", "bone": &"torso"},
    {"path": ROOT + "/outfit/outfit_01/outfit_01_up_arm_l.png", "layer": &"outfit", "component": &"arm_l", "bone": &"arm_l"},
    {"path": ROOT + "/outfit/outfit_01/outfit_01_up_arm_r.png", "layer": &"outfit", "component": &"arm_r", "bone": &"arm_r"},
    {"path": ROOT + "/outfit/outfit_01/outfit_01_up_skirt.png", "layer": &"outfit", "component": &"skirt", "bone": &"torso"},
    {"path": ROOT + "/face/face_01/face_01_up.png", "layer": &"face", "component": &"main", "bone": &"head"},
    {"path": ROOT + "/hair/hair_01/hair_01_up_front.png", "layer": &"hair_front", "component": &"front", "bone": &"head"},
    {"path": ROOT + "/head_accessory/horn_01/horn_01_up.png", "layer": &"head_accessory", "component": &"horn", "bone": &"head"}
]

static func components_for_direction(direction: StringName) -> Array:
    match direction:
        &"down":
            return DOWN_COMPONENTS
        &"right":
            return RIGHT_COMPONENTS
        &"up":
            return UP_COMPONENTS
        _:
            return []

static func required_paths(direction: StringName) -> Array[String]:
    var result: Array[String] = []
    for entry in components_for_direction(direction):
        result.append(str(entry["path"]))
    return result

static func missing_paths(direction: StringName) -> Array[String]:
    var result: Array[String] = []
    for path in required_paths(direction):
        if not ResourceLoader.exists(path):
            result.append(path)
    return result

static func assets_available(direction: StringName) -> bool:
    return AUTHORED_DIRECTIONS.has(direction) and missing_paths(direction).is_empty()

static func required_down_paths() -> Array[String]:
    return required_paths(&"down")

static func missing_down_paths() -> Array[String]:
    return missing_paths(&"down")

static func down_assets_available() -> bool:
    return assets_available(&"down")

static func apply_down(actor: ModularDiscipleActor) -> Dictionary:
    return apply_direction(actor, &"down")

static func apply_right(actor: ModularDiscipleActor) -> Dictionary:
    return apply_direction(actor, &"right")

static func apply_up(actor: ModularDiscipleActor) -> Dictionary:
    return apply_direction(actor, &"up")

static func apply_direction(actor: ModularDiscipleActor, direction: StringName) -> Dictionary:
    var result := {
        "applied": 0,
        "missing": [],
        "invalid": []
    }
    if actor == null:
        result["invalid"].append("actor")
        return result
    if not AUTHORED_DIRECTIONS.has(direction):
        result["invalid"].append("direction:%s" % str(direction))
        return result

    for layer_name in LAYERS_TO_CLEAR:
        actor.clear_layer_components(layer_name)

    var components := components_for_direction(direction)
    for entry in components:
        var path := str(entry["path"])
        if not ResourceLoader.exists(path):
            result["missing"].append(path)
            continue
        var texture := load(path) as Texture2D
        if texture == null or texture.get_width() != 128 or texture.get_height() != 128:
            result["invalid"].append(path)
            continue
        var ok := actor.set_component_texture(
            StringName(entry["layer"]),
            StringName(entry["component"]),
            StringName(entry["bone"]),
            texture
        )
        if ok:
            result["applied"] = int(result["applied"]) + 1
        else:
            result["invalid"].append(path)

    actor.facing = direction
    return result
