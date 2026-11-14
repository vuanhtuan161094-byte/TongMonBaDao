extends RefCounted
## VIS-10 independently generated B-view *DRAFT* sprites (2026-11-14).
## Cut from the author's new art sheet; they are NOT flipped Source A PNGs.
## Their visual identity/angle still requires owner sign-off against live A.
## No runtime selection until SectIsometricWorldV1 receives an EXPLICIT
## transient editor preview request; game default stays approved A.
const ROOT := "res://art/tmb_rotation_b_candidates_v1/"
const B_PATHS := {
    "main_hall": ROOT+"hall_B_draft.png",
    "mine": ROOT+"mine_B_draft.png",
    "residence": ROOT+"residence_B_draft.png",
    "warehouse": ROOT+"warehouse_B_draft.png",
    "forge": ROOT+"forge_B_draft.png",
    "guidance": ROOT+"guidance_B_draft.png"
}
const TARGET_SIZES := {
    "main_hall": Vector2i(300,201),
    "mine": Vector2i(166,121),
    "residence": Vector2i(174,135),
    "warehouse": Vector2i(162,138),
    "forge": Vector2i(205,164),
    "guidance": Vector2i(182,203)
}
static func texture_for(kind: StringName) -> Texture2D:
    var key := "main_hall" if str(kind) == "hall" else str(kind)
    if not B_PATHS.has(key):
        return null
    var path: String = B_PATHS[key]
    if not ResourceLoader.exists(path,"Texture2D"):
        return null
    var texture := ResourceLoader.load(path) as Texture2D
    if texture == null or texture.get_size() != Vector2(TARGET_SIZES[key]):
        return null
    return texture
