class_name FemaleStageAAssetLoader
extends RefCounted

const ROOT := "res://assets/p3/character_creator/parts/female_normal_v1"

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

static func required_down_paths() -> Array[String]:
    var result: Array[String] = []
    for entry in DOWN_COMPONENTS:
        result.append(str(entry["path"]))
    return result

static func missing_down_paths() -> Array[String]:
    var result: Array[String] = []
    for path in required_down_paths():
        if not ResourceLoader.exists(path):
            result.append(path)
    return result

static func down_assets_available() -> bool:
    return missing_down_paths().is_empty()

static func apply_down(actor: ModularDiscipleActor) -> Dictionary:
    var result := {
        "applied": 0,
        "missing": [],
        "invalid": []
    }
    if actor == null:
        result["invalid"].append("actor")
        return result

    for layer_name in [&"hair_back", &"body", &"outfit", &"face", &"hair_front", &"head_accessory"]:
        actor.clear_layer_components(layer_name)

    for entry in DOWN_COMPONENTS:
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

    actor.facing = DiscipleActorVisualCatalog.DIR_DOWN
    return result
