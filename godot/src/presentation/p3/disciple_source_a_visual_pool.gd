class_name DiscipleSourceAVisualPool
extends RefCounted

# Only verified and imported Source A PackedScenes. Batch-01 converted rig
# outputs remaining on E: are NOT automatically available to GitHub/Android.
# Extend by actual manifest/hash-gated import, not invented asset IDs.
const VERIFIED_ACTORS := [
    {"asset_id":"1113028_1","sex":"female","scene":"res://assets/actors/1113028_1/actor.tscn"}
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
