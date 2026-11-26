class_name SectASCharCandidateBridgeV1
extends RefCounted
## Reuse existing AS48..AS71 candidate SpriteFrames. Real 24 sex+school
## identities, no regenerated art, skeleton animation, extra game or source
## overwrite. Unassigned disciples use a deterministic starter from these authored assets.
const VISUAL_IDENTITY = preload("res://src/presentation/p3/aschar_visual_identity_v1.gd")
const SCHOOL_IDS = VISUAL_IDENTITY.SCHOOL_IDS
const SCHOOL_NAMES = VISUAL_IDENTITY.SCHOOL_NAMES
const ASSET_IDS = VISUAL_IDENTITY.ASSET_IDS
const SOURCE_PATHS = VISUAL_IDENTITY.SOURCE_PATHS
const SOCKET_ROOT = VISUAL_IDENTITY.SOCKET_ROOT
const SPRITE_SCRIPT := preload("res://src/presentation/p3/sect_aschar_candidate_sprite_v1.gd")
static var _scene_cache: Dictionary = {}
static var _portrait_cache: Dictionary = {}
static var _branch_school_cache: Dictionary = {}

static func school_for_branch(branch_id: String) -> String:
    if branch_id.is_empty():
        return ""
    # Combat V6.3 stores the catalogue's bare branch ID (e.g. ngu_kiem),
    # not its presentation-only path_id (tmb.path.sword.ngu_kiem).
    # Cache the authoritative crosswalk; this is only a visual lookup.
    if _branch_school_cache.is_empty():
        var definitions := V63HumanSkillCombatSystem.branch_definitions()
        for key in definitions.keys():
            var row: Dictionary = definitions.get(key,{})
            if row.is_empty():
                continue
            var school := str(row.get("school",""))
            if SCHOOL_IDS.has(school):
                _branch_school_cache[str(key)] = school
                var full_id := str(row.get("path_id",""))
                if not full_id.is_empty():
                    _branch_school_cache[full_id] = school
    return str(_branch_school_cache.get(branch_id,""))

static func school_for_disciple(disciple: DiscipleState) -> String:
    return school_for_branch(str(disciple.v63_combat_branch_id)) if disciple != null else ""

static func actor_id(school: String,sex: String) -> int:
    return VISUAL_IDENTITY.actor_id(school,sex)

# Before first branch selection, reuse one of the 12 authored AS-CHAR looks
# from the disciple's immutable birth seed. No random reroll on UI redraw,
# Save/Reload or PvE; this is a visual-only selection, NOT a school assignment.
static func starter_school_for_disciple(disciple: DiscipleState) -> String:
    if disciple == null:
        return ""
    var seed := DiscipleActorVisualCatalog.visual_seed_for_disciple(disciple)
    return str(SCHOOL_IDS[absi(seed) % SCHOOL_IDS.size()])

static func visual_school_for_disciple(disciple: DiscipleState) -> String:
    var chosen := school_for_disciple(disciple)
    return chosen if not chosen.is_empty() else starter_school_for_disciple(disciple)

static func actor_id_for_disciple(disciple: DiscipleState) -> int:
    if disciple == null:
        return -1
    return actor_id(visual_school_for_disciple(disciple),
        str(DiscipleActorVisualCatalog.visual_sex_for_disciple(disciple)))

static func scene_for_disciple(disciple: DiscipleState) -> PackedScene:
    if disciple == null:
        return null
    return scene_for(visual_school_for_disciple(disciple),
        str(DiscipleActorVisualCatalog.visual_sex_for_disciple(disciple)))

static func preview_texture_for_disciple(disciple: DiscipleState) -> Texture2D:
    if disciple == null:
        return null
    return preview_texture(visual_school_for_disciple(disciple),
        str(DiscipleActorVisualCatalog.visual_sex_for_disciple(disciple)))

static func _make_frames(source: SpriteFrames) -> SpriteFrames:
    var frames := source.duplicate(true) as SpriteFrames
    if frames == null or not frames.has_animation(&"idle_front"):
        return null
    for key in [&"stand",&"walk"]:
        if frames.has_animation(key):
            continue
        var source_key: StringName = &"idle_front"
        if key == &"walk" and frames.has_animation(&"walk_front"):
            source_key = &"walk_front"
        frames.add_animation(key)
        frames.set_animation_loop(key,true)
        frames.set_animation_speed(key,6.0)
        for i in range(frames.get_frame_count(source_key)):
            frames.add_frame(key,frames.get_frame_texture(source_key,i),
                frames.get_frame_duration(source_key,i))
    return frames

static func scene_for(school: String,sex: String) -> PackedScene:
    var id := actor_id(school,sex)
    if id < 0:
        return null
    if _scene_cache.has(id):
        return _scene_cache[id]
    var source_path := str(SOURCE_PATHS.get(id,""))
    if source_path.is_empty() or not ResourceLoader.exists(source_path,"SpriteFrames"):
        return null
    var source := ResourceLoader.load(source_path,"SpriteFrames") as SpriteFrames
    if source == null:
        return null
    var frames := _make_frames(source)
    if frames == null:
        return null
    var sprite := SPRITE_SCRIPT.new() as AnimatedSprite2D
    sprite.name = "ASCHAR%02d_Candidate" % id
    sprite.sprite_frames = frames
    sprite.set("socket_manifest_path",SOCKET_ROOT+"/AS%d_weapon_sockets_v9_3_candidate.json" % id)
    sprite.set_meta("visible_height_px",338.0)
    sprite.set_meta("pilot_only",true)
    var scene := PackedScene.new()
    var ok := scene.pack(sprite)
    sprite.free()
    if ok != OK:
        return null
    _scene_cache[id] = scene
    return scene

static func preview_texture(school: String,sex: String) -> Texture2D:
    var id := actor_id(school,sex)
    if id < 0:
        return null
    if _portrait_cache.has(id):
        return _portrait_cache[id]
    # The school chooser needs ONE representative cel, not 96 full-resolution
    # frames and separate weapons. Resolve the real first idle frame directly
    # from the same ASCHAR socket JSON used by the in-game actor.
    var manifest_path := SOCKET_ROOT+"/AS%d_weapon_sockets_v9_3_candidate.json" % id
    if not FileAccess.file_exists(manifest_path):
        return null
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
    if not (parsed is Dictionary):
        return null
    for raw in parsed.get("body_frames",[]):
        if not (raw is Dictionary):
            continue
        if str(raw.get("clip","")) != "idle_front" or int(raw.get("frame",-1)) != 0:
            continue
        var path := str(raw.get("path",""))
        if not ResourceLoader.exists(path,"Texture2D"):
            return null
        var tex := ResourceLoader.load(path,"Texture2D") as Texture2D
        if tex != null:
            _portrait_cache[id] = tex
        return tex
    return null

static func branches_for(school: String) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    if not SCHOOL_IDS.has(school):
        return result
    var definitions := V63HumanSkillCombatSystem.branch_definitions()
    for key in definitions.keys():
        var branch: Dictionary = definitions.get(key,{})
        if str(branch.get("school","")) != school:
            continue
        var canonical_id := str(key)
        if canonical_id.is_empty():
            continue
        result.append({
            "id":canonical_id,
            "name":str(branch.get("name",canonical_id)),
            "path_id":str(branch.get("path_id",""))
        })
    result.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
        return str(a["id"]) < str(b["id"]))
    return result

static func assign_branch(state: SimulationState,disciple: DiscipleState,branch_id: String) -> Dictionary:
    if state == null or disciple == null or not state.disciples.has(disciple.id):
        return {"ok":false,"reason":"unknown_disciple"}
    if not disciple.active_pve_encounter_id.is_empty() or disciple.region_id != &"sect":
        return {"ok":false,"reason":"disciple_not_at_sect"}
    if disciple.v63_combat_branch_id != &"":
        return {"ok":false,"reason":"branch_already_chosen"}
    if not disciple.v63_learned_skill_nodes.is_empty() or not disciple.v63_equipped_skill_ids.is_empty():
        return {"ok":false,"reason":"existing_skill_history"}
    var school := school_for_branch(branch_id)
    if school.is_empty():
        return {"ok":false,"reason":"unknown_school"}
    for branch in branches_for(school):
        if str(branch["id"]) == branch_id and V63HumanSkillCombatSystem.branch_definitions().has(branch_id):
            disciple.v63_combat_branch_id = StringName(branch_id)
            return {"ok":true,"school":school,"branch":branch_id,"name":str(branch["name"])}
    return {"ok":false,"reason":"unknown_branch"}
