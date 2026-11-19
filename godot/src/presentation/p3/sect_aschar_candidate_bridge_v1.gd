class_name SectASCharCandidateBridgeV1
extends RefCounted
## Reuse existing AS48..AS71 candidate SpriteFrames. Real 24 sex+school
## identities, no regenerated art, skeleton animation, extra game or source
## overwrite. An unassigned disciple keeps the regular starter artwork.
const SCHOOL_IDS := [
    "sword","blade","dual_blade","spear","bow","fist","palm",
    "poison","talisman","curse","formation","summon"
]
const SCHOOL_NAMES := {
    "sword":"Kiếm Tu","blade":"Đao Tu","dual_blade":"Song Đao",
    "spear":"Thương Tu","bow":"Cung Tu","fist":"Quyền Tu",
    "palm":"Chưởng Tu","poison":"Độc Tu","talisman":"Phù Tu",
    "curse":"Chú Tu","formation":"Trận Tu","summon":"Triệu Hồi"
}
const ASSET_IDS := {
    "sword":[48,49],"blade":[50,51],"dual_blade":[52,53],
    "spear":[54,55],"bow":[56,57],"fist":[58,59],
    "palm":[60,61],"poison":[62,63],"talisman":[64,65],
    "curse":[66,67],"formation":[68,69],"summon":[70,71]
}
const SOURCE_PATHS := {
    48:"res://assets/p3/baked_candidates/aschar48/AS48_V9_4DIR_CLIPS_CANDIDATE.tres",
    49:"res://assets/p3/baked_candidates/aschar49/AS49_V9_4DIR_CLIPS_CANDIDATE.tres",
    50:"res://assets/p3/baked_candidates/aschar50_candidate/AS50_FRONT_CLIPS_CANDIDATE.tres",
    51:"res://assets/p3/baked_candidates/aschar51_candidate/AS51_FRONT_CLIPS_CANDIDATE.tres",
    52:"res://assets/p3/baked_candidates/aschar52_candidate/AS52_SONGDAO_CLIPS_CANDIDATE.tres",
    53:"res://assets/p3/baked_candidates/aschar53_candidate/AS53_SONGDAO_CLIPS_CANDIDATE.tres",
    54:"res://assets/p3/baked_candidates/aschar54_candidate/AS54_SPEAR_DOWNED_SAFE_SCALE_CANDIDATE.tres",
    55:"res://assets/p3/baked_candidates/aschar55_candidate/AS55_SPEAR_DOWNED_SAFE_SCALE_CANDIDATE.tres",
    56:"res://assets/p3/baked_candidates/aschar56_candidate/AS56_BOW_CLIPS_CANDIDATE.tres",
    57:"res://assets/p3/baked_candidates/aschar57_candidate/AS57_BOW_CLIPS_CANDIDATE.tres",
    58:"res://assets/p3/baked_candidates/aschar58_candidate/AS58_FIST_CLIPS_CANDIDATE.tres",
    59:"res://assets/p3/baked_candidates/aschar59_candidate/AS59_FIST_CLIPS_CANDIDATE.tres",
    60:"res://assets/p3/baked_candidates/aschar60_candidate/AS60_PALM_CLIPS_CANDIDATE.tres",
    61:"res://assets/p3/baked_candidates/aschar61_candidate/AS61_PALM_CLIPS_CANDIDATE.tres",
    62:"res://assets/p3/baked_candidates/aschar62_candidate/AS62_POISON_CLIPS_CANDIDATE.tres",
    63:"res://assets/p3/baked_candidates/aschar63_candidate/AS63_POISON_CLIPS_CANDIDATE.tres",
    64:"res://assets/p3/baked_candidates/aschar64_candidate/AS64_TALISMAN_CLIPS_CANDIDATE.tres",
    65:"res://assets/p3/baked_candidates/aschar65_candidate/AS65_TALISMAN_CLIPS_BACK_REPAIRED_CANDIDATE.tres",
    66:"res://assets/p3/baked_candidates/aschar66_candidate/AS66_CURSE_CLIPS_CANDIDATE.tres",
    67:"res://assets/p3/baked_candidates/aschar67_candidate/AS67_CURSE_CLIPS_CANDIDATE.tres",
    68:"res://assets/p3/baked_candidates/aschar68_candidate/AS68_FORMATION_CLIPS_CANDIDATE.tres",
    69:"res://assets/p3/baked_candidates/aschar69_candidate/AS69_FORMATION_CLIPS_CANDIDATE.tres",
    70:"res://assets/p3/baked_candidates/aschar70_candidate/AS70_SUMMONING_CLIPS_CANDIDATE.tres",
    71:"res://assets/p3/baked_candidates/aschar71_candidate/AS71_SUMMONING_CLIPS_CANDIDATE.tres"
}
const SOCKET_ROOT := "res://assets/p3/baked_candidates/weapon_library_v1/candidate/actor_sockets"
const SPRITE_SCRIPT := preload("res://src/presentation/p3/sect_aschar_candidate_sprite_v1.gd")
static var _scene_cache: Dictionary = {}

static func school_for_branch(branch_id: String) -> String:
    if branch_id.is_empty():
        return ""
    for school in SCHOOL_IDS:
        if branch_id.begins_with("tmb.path."+school+"."):
            return school
    return ""

static func school_for_disciple(disciple: DiscipleState) -> String:
    return school_for_branch(str(disciple.v63_combat_branch_id)) if disciple != null else ""

static func actor_id(school: String,sex: String) -> int:
    if not ASSET_IDS.has(school):
        return -1
    var pair: Array = ASSET_IDS[school]
    return int(pair[1]) if sex == "female" else int(pair[0])

static func scene_for_disciple(disciple: DiscipleState) -> PackedScene:
    var school := school_for_disciple(disciple)
    if school.is_empty():
        return null
    var sex := str(DiscipleActorVisualCatalog.visual_sex_for_disciple(disciple))
    return scene_for(school,sex)

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
    var path := str(SOURCE_PATHS.get(actor_id(school,sex),""))
    if path.is_empty() or not ResourceLoader.exists(path,"SpriteFrames"):
        return null
    var source := ResourceLoader.load(path,"SpriteFrames") as SpriteFrames
    if source == null or not source.has_animation(&"idle_front"):
        return null
    return source.get_frame_texture(&"idle_front",0)

static func branches_for(school: String) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    if not SCHOOL_IDS.has(school):
        return result
    for row in V63HumanSkillCombatSystem.branch_definitions().values():
        if not (row is Dictionary) or str(row.get("school","")) != school:
            continue
        var branch: Dictionary = row
        var canonical_id := str(branch.get("path_id",""))
        if canonical_id.is_empty():
            canonical_id = "tmb.path."+school+"."+str(branch.get("id",""))
        if canonical_id.begins_with("tmb.path."+school+"."):
            result.append({"id":canonical_id,"name":str(branch.get("name",canonical_id))})
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
        if str(branch["id"]) == branch_id:
            disciple.v63_combat_branch_id = StringName(branch_id)
            return {"ok":true,"school":school,"branch":branch_id,"name":str(branch["name"])}
    return {"ok":false,"reason":"unknown_branch"}
