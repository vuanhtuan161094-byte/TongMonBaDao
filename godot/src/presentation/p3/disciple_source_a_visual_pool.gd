class_name DiscipleSourceAVisualPool
extends RefCounted

# Source A Batch-01 scenes with copied binaries verified against each
# asset.json file_sha256. Sex is based on inspected stand/walk artwork.
const VERIFIED_ACTORS := [
    {"asset_id":"1113028_1","sex":"female","scene":"res://assets/actors/1113028_1/actor.tscn"},
    {"asset_id":"body_1110201","sex":"male","scene":"res://assets/actors/body_1110201/actor.tscn"},
    {"asset_id":"body_1120402","sex":"male","scene":"res://assets/actors/body_1120402/actor.tscn"}
]

static func scene_path_for_disciple(disciple: DiscipleState) -> String:
    if disciple == null:
        return ""
    var sex := str(DiscipleActorVisualCatalog.visual_sex_for_disciple(disciple))
    var available: Array[String] = []
    for actor in VERIFIED_ACTORS:
        if str(actor.get("sex","")) == sex:
            available.append(str(actor["scene"]))
    if available.is_empty():
        # Existing modular actor/fallback remains; never display female as male.
        return ""
    available.sort()
    var seed := DiscipleActorVisualCatalog.visual_seed_for_disciple(disciple)
    return available[absi(seed)%available.size()]

static func scene_for_disciple(disciple: DiscipleState) -> PackedScene:
    var path := scene_path_for_disciple(disciple)
    if path.is_empty() or not ResourceLoader.exists(path,"PackedScene"):
        return null
    return ResourceLoader.load(path,"PackedScene") as PackedScene
