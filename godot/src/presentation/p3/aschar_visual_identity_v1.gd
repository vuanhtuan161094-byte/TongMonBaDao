class_name AscharVisualIdentityV1
extends RefCounted
## Shared immutable AS-CHAR source identity. No gameplay, state or skill dependency.
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

static func actor_id(school: String,sex: String) -> int:
    if not ASSET_IDS.has(school):
        return -1
    var pair: Array = ASSET_IDS[school]
    return int(pair[1]) if sex == "female" else int(pair[0])
