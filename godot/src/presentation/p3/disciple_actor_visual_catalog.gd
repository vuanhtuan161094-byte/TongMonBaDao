class_name DiscipleActorVisualCatalog
extends RefCounted

const SEX_MALE := &"male"
const SEX_FEMALE := &"female"

const FAMILY_SWORD := &"sword"
const FAMILY_SPELL := &"spell"
const FAMILY_BODY := &"body"
const FAMILY_IDS: Array[StringName] = [FAMILY_SWORD, FAMILY_SPELL, FAMILY_BODY]

const ARCHETYPE_IDS: Array[StringName] = [
    &"male_sword",
    &"female_sword",
    &"male_spell",
    &"female_spell",
    &"male_body",
    &"female_body"
]

const LAYER_ORDER: Array[StringName] = [
    &"shadow",
    &"weapon_back",
    &"body",
    &"outfit",
    &"hair",
    &"weapon_front",
    &"accessory",
    &"aura"
]

const LAYER_Z := {
    "shadow": 0,
    "weapon_back": 10,
    "body": 20,
    "outfit": 30,
    "hair": 40,
    "weapon_front": 50,
    "accessory": 60,
    "aura": 70
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

static func archetype_for_disciple(disciple: DiscipleState) -> StringName:
    if disciple == null:
        return &"male_sword"
    var seed := visual_seed_for_disciple(disciple)
    var sex := visual_sex_for_disciple(disciple, seed)
    var family: StringName = FAMILY_IDS[seed % FAMILY_IDS.size()]
    return StringName("%s_%s" % [str(sex), str(family)])

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

static func asset_root(archetype_id: StringName) -> String:
    var safe_id := archetype_id if ARCHETYPE_IDS.has(archetype_id) else &"male_sword"
    return "res://assets/p3/actors/%s" % str(safe_id)

static func layer_order() -> Array[StringName]:
    return LAYER_ORDER.duplicate()

static func is_valid_layer(layer_name: StringName) -> bool:
    return LAYER_ORDER.has(layer_name)

static func z_index_for_layer(layer_name: StringName) -> int:
    return int(LAYER_Z.get(str(layer_name), 0))
