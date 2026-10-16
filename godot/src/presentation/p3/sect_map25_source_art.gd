class_name SectMap25SourceArt
extends RefCounted

# Source A is an *optional* runtime art source. Whitelisted exact SHA256
# from the existing ENV02A baseline; no asset is accepted on filename alone.
# In the GitHub code-only checkout all PNGs are absent => fallback, never load
# a made-up image. Does not alter gameplay, save state or asset rights.
const INDEX := "res://data/presentation/map25_source_a_verified.json"

var index: Dictionary = {}
var textures: Dictionary = {}
var accepted: Array[String] = []
var missing: Array[String] = []
var rejected: Array[String] = []
var manifest_valid := false

func _init() -> void:
    if not FileAccess.file_exists(INDEX):
        return
    var file := FileAccess.open(INDEX,FileAccess.READ)
    if file == null:
        return
    var parsed = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary) or int(parsed.get("schema_version",0)) != 1:
        return
    var sources = parsed.get("files",{})
    if not (sources is Dictionary):
        return
    index = sources
    manifest_valid = true

func texture_for(relative: String) -> Texture2D:
    if textures.has(relative):
        return textures[relative]
    if not manifest_valid or not index.has(relative):
        return null
    var spec: Dictionary = index[relative]
    var path := str(spec.get("path",""))
    var wanted := str(spec.get("sha256","")).to_lower()
    # Refuse path traversal, remote URLs and unexpected resource roots.
    if not path.begins_with("res://art/source_a_env02a/") or ".." in path or path != "res://art/source_a_env02a/"+relative or wanted.length() != 64:
        if relative not in rejected:
            rejected.append(relative)
        return null
    if not FileAccess.file_exists(path):
        if relative not in missing:
            missing.append(relative)
        return null
    if FileAccess.get_sha256(path).to_lower() != wanted:
        if relative not in rejected:
            rejected.append(relative)
        return null
    var image := Image.load_from_file(path)
    if image == null or image.is_empty():
        if relative not in rejected:
            rejected.append(relative)
        return null
    var texture := ImageTexture.create_from_image(image)
    if texture == null or texture.get_width() <= 0 or texture.get_height() <= 0:
        if relative not in rejected:
            rejected.append(relative)
        return null
    textures[relative] = texture
    if relative not in accepted:
        accepted.append(relative)
    return texture

func status() -> Dictionary:
    return {
        "manifest_valid":manifest_valid,
        "accepted":accepted.duplicate(),
        "missing":missing.duplicate(),
        "rejected":rejected.duplicate(),
        "accepted_count":accepted.size(),
        "missing_count":missing.size(),
        "rejected_count":rejected.size(),
        "art_complete":manifest_valid and accepted.size() == index.size()
    }
