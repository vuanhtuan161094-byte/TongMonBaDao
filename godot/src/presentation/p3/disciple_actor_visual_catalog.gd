class_name DiscipleActorVisualCatalog
extends RefCounted

const SEX_MALE := &"male"
const SEX_FEMALE := &"female"

const RIG_FEMALE_NORMAL_V1 := &"female_normal_v1"
const RIG_MALE_NORMAL_V1 := &"male_normal_v1"
const RIG_IDS: Array[StringName] = [RIG_FEMALE_NORMAL_V1, RIG_MALE_NORMAL_V1]

const SOURCE_FRAME_SIZE := Vector2(128.0, 128.0)
const SOURCE_FOOT_POINT := Vector2(64.0, 104.0)
const MAP_DISPLAY_SCALE := 0.68
const ACTOR_BOX_SIZE := Vector2(88.0, 92.0)
const ACTOR_FOOT_POINT := Vector2(44.0, 72.0)

const BONE_ROOT := &"root"
const BONE_PELVIS := &"pelvis"
const BONE_TORSO := &"torso"
const BONE_HEAD := &"head"
const BONE_ARM_L := &"arm_l"
const BONE_ARM_R := &"arm_r"
const BONE_HAND_WEAPON := &"hand_weapon"
const BONE_LEG_L := &"leg_l"
const BONE_LEG_R := &"leg_r"

const BONE_IDS: Array[StringName] = [
    BONE_ROOT,
    BONE_PELVIS,
    BONE_TORSO,
    BONE_HEAD,
    BONE_ARM_L,
    BONE_ARM_R,
    BONE_HAND_WEAPON,
    BONE_LEG_L,
    BONE_LEG_R
]

const BONE_PARENTS := {
    "root": "",
    "pelvis": "root",
    "torso": "pelvis",
    "head": "torso",
    "arm_l": "torso",
    "arm_r": "torso",
    "hand_weapon": "arm_r",
    "leg_l": "pelvis",
    "leg_r": "pelvis"
}

# Coarse V1 rest pose in source-canvas pixels, relative to each parent bone.
# Exact art pivots can be tuned after the real vertical-slice proof without changing bone IDs.
const BONE_REST_POSITIONS := {
    "root": Vector2(0.0, 0.0),
    "pelvis": Vector2(0.0, -31.0),
    "torso": Vector2(0.0, -20.0),
    "head": Vector2(0.0, -24.0),
    "arm_l": Vector2(-13.0, -13.0),
    "arm_r": Vector2(13.0, -13.0),
    "hand_weapon": Vector2(13.0, 15.0),
    "leg_l": Vector2(-8.0, 18.0),
    "leg_r": Vector2(8.0, 18.0)
}

const LAYER_ORDER: Array[StringName] = [
    &"shadow",
    &"aura",
    &"hair_back",
    &"weapon_back",
    &"body",
    &"outfit",
    &"face",
    &"hair_front",
    &"head_accessory",
    &"weapon_front",
    &"accessory"
]

const LAYER_Z := {
    "shadow": -100,
    "aura": -80,
    "hair_back": -30,
    "weapon_back": -20,
    "body": 0,
    "outfit": 10,
    "face": 20,
    "hair_front": 30,
    "head_accessory": 40,
    "weapon_front": 50,
    "accessory": 60
}

const LAYER_DEFAULT_BONE := {
    "shadow": "root",
    "aura": "root",
    "hair_back": "head",
    "weapon_back": "hand_weapon",
    "body": "torso",
    "outfit": "torso",
    "face": "head",
    "hair_front": "head",
    "head_accessory": "head",
    "weapon_front": "hand_weapon",
    "accessory": "torso"
}

const DIR_DOWN := &"down"
const DIR_RIGHT := &"right"
const DIR_UP := &"up"
const DIR_LEFT := &"left"
const DIRECTIONS: Array[StringName] = [DIR_DOWN, DIR_RIGHT, DIR_UP, DIR_LEFT]

const CLIP_IDLE := &"idle"
const CLIP_WALK := &"walk"
const CLIP_CULTIVATE := &"cultivate"
const CLIP_WORK := &"work"
const CLIP_MINING := &"mining"
const CLIP_FORGING := &"forging"
const CLIP_REST := &"rest"
const CLIP_HEAL := &"heal"
const CLIP_COMBAT_READY := &"combat_ready"
const CLIP_LEAVE := &"leave"

const ACTION_CLIPS := {
    "EVALUATE": CLIP_IDLE,
    "IDLE": CLIP_IDLE,
    "HOLD": CLIP_IDLE,
    "CULTIVATE": CLIP_CULTIVATE,
    "BREAKTHROUGH": CLIP_CULTIVATE,
    "WORK_MINING": CLIP_MINING,
    "WORK_FORGING": CLIP_FORGING,
    "SELL": CLIP_WORK,
    "BUY": CLIP_WORK,
    "REST": CLIP_REST,
    "HEAL": CLIP_HEAL,
    "COMBAT": CLIP_COMBAT_READY,
    "HUNT": CLIP_LEAVE,
    "TRAVEL": CLIP_LEAVE,
    "LOOT": CLIP_LEAVE,
    "RETURN_SECT": CLIP_LEAVE
}

const APPEARANCE_VERSION := 1
const HAIR_TINTS := ["2b2624", "5b3a2e", "b89a63"]
const OUTFIT_TINTS := ["45675f", "7a3f37", "455472"]

static func rig_for_disciple(disciple: DiscipleState) -> StringName:
    var seed := visual_seed_for_disciple(disciple)
    var sex := visual_sex_for_disciple(disciple, seed)
    return RIG_FEMALE_NORMAL_V1 if sex == SEX_FEMALE else RIG_MALE_NORMAL_V1

static func visual_seed_for_disciple(disciple: DiscipleState) -> int:
    if disciple != null and disciple.profile_seed > 0:
        return disciple.profile_seed
    if disciple == null:
        return 0
    return abs(hash(str(disciple.id)))

static func visual_sex_for_disciple(disciple: DiscipleState, seed: int = -1) -> StringName:
    if disciple != null and disciple.sex_id in [SEX_MALE, SEX_FEMALE]:
        return disciple.sex_id
    var resolved_seed := seed
    if resolved_seed < 0:
        resolved_seed = visual_seed_for_disciple(disciple)
    return SEX_MALE if resolved_seed % 2 == 0 else SEX_FEMALE

static func default_appearance_for_disciple(disciple: DiscipleState) -> Dictionary:
    var seed := visual_seed_for_disciple(disciple)
    var rig_id := rig_for_disciple(disciple)
    var female := rig_id == RIG_FEMALE_NORMAL_V1
    return {
        "version": APPEARANCE_VERSION,
        "rig_id": str(rig_id),
        "body_id": "body_01",
        "face_id": "face_%02d" % (_variant_index(seed, 17, 2) + 1) if female else "face_01",
        "hair_id": "hair_%02d" % (_variant_index(seed, 31, 3) + 1) if female else "hair_01",
        "hair_tint": str(HAIR_TINTS[_variant_index(seed, 43, HAIR_TINTS.size())]),
        "outfit_id": "outfit_%02d" % (_variant_index(seed, 59, 2) + 1) if female else "outfit_01",
        "outfit_tint": str(OUTFIT_TINTS[_variant_index(seed, 71, OUTFIT_TINTS.size())]),
        "head_accessory_id": "horn_01" if female and _variant_index(seed, 83, 3) == 0 else "",
        "weapon_id": "weapon_%02d" % (_variant_index(seed, 97, 2) + 1) if female else "weapon_01",
        "accessory_id": "",
        "aura_id": ""
    }

static func normalize_appearance_profile(raw_profile: Variant, disciple: DiscipleState = null) -> Dictionary:
    var normalized := default_appearance_for_disciple(disciple)
    if not (raw_profile is Dictionary):
        return normalized
    var raw: Dictionary = raw_profile

    var requested_rig := StringName(raw.get("rig_id", normalized["rig_id"]))
    if RIG_IDS.has(requested_rig):
        normalized["rig_id"] = str(requested_rig)

    for key in ["body_id", "face_id", "hair_id", "outfit_id", "head_accessory_id", "weapon_id", "accessory_id", "aura_id"]:
        if raw.has(key):
            normalized[key] = str(raw[key]).strip_edges()

    normalized["hair_tint"] = _normalize_hex_color(str(raw.get("hair_tint", normalized["hair_tint"])), str(normalized["hair_tint"]))
    normalized["outfit_tint"] = _normalize_hex_color(str(raw.get("outfit_tint", normalized["outfit_tint"])), str(normalized["outfit_tint"]))
    normalized["version"] = APPEARANCE_VERSION
    return normalized

static func action_clip(action: StringName) -> StringName:
    return StringName(ACTION_CLIPS.get(str(action), CLIP_IDLE))

static func direction_for_delta(delta: Vector2, fallback: StringName = DIR_DOWN) -> StringName:
    if delta.length_squared() <= 0.0001:
        return fallback if DIRECTIONS.has(fallback) else DIR_DOWN
    if absf(delta.x) >= absf(delta.y):
        return DIR_RIGHT if delta.x >= 0.0 else DIR_LEFT
    return DIR_DOWN if delta.y >= 0.0 else DIR_UP

static func animation_name(clip: StringName, direction: StringName) -> StringName:
    var safe_clip := clip if clip != &"" else CLIP_IDLE
    var safe_direction := direction if DIRECTIONS.has(direction) else DIR_DOWN
    return StringName("%s_%s" % [str(safe_clip), str(safe_direction)])

static func playback_direction(direction: StringName, mirror_left: bool = true) -> StringName:
    if direction == DIR_LEFT and mirror_left:
        return DIR_RIGHT
    return direction if DIRECTIONS.has(direction) else DIR_DOWN

static func should_mirror(direction: StringName, mirror_left: bool = true) -> bool:
    return mirror_left and direction == DIR_LEFT

static func rig_asset_root(rig_id: StringName) -> String:
    var safe_id := rig_id if RIG_IDS.has(rig_id) else RIG_FEMALE_NORMAL_V1
    return "res://assets/p3/character_creator/rigs/%s" % str(safe_id)

static func parts_asset_root(rig_id: StringName) -> String:
    var safe_id := rig_id if RIG_IDS.has(rig_id) else RIG_FEMALE_NORMAL_V1
    return "res://assets/p3/character_creator/parts/%s" % str(safe_id)

static func layer_order() -> Array[StringName]:
    return LAYER_ORDER.duplicate()

static func is_valid_layer(layer_name: StringName) -> bool:
    return LAYER_ORDER.has(layer_name)

static func z_index_for_layer(layer_name: StringName) -> int:
    return int(LAYER_Z.get(str(layer_name), 0))

static func default_bone_for_layer(layer_name: StringName) -> StringName:
    return StringName(LAYER_DEFAULT_BONE.get(str(layer_name), "root"))

static func bone_parent(bone_id: StringName) -> StringName:
    return StringName(BONE_PARENTS.get(str(bone_id), ""))

static func bone_rest_position(bone_id: StringName) -> Vector2:
    return BONE_REST_POSITIONS.get(str(bone_id), Vector2.ZERO)

static func _variant_index(seed: int, salt: int, count: int) -> int:
    if count <= 1:
        return 0
    var safe_seed := absi(seed)
    var mixed := (safe_seed * 1103515245 + salt * 12345 + 2147483647) % 2147483647
    return int(mixed % count)

static func _normalize_hex_color(value: String, fallback: String) -> String:
    var text := value.strip_edges().trim_prefix("#").to_lower()
    if text.length() != 6:
        return fallback
    for character in text:
        if not str(character) in "0123456789abcdef":
            return fallback
    return text
