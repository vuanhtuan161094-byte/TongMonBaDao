class_name CombatV4JX1Atlas
extends RefCounted
## PRIVATE visual lab source. Do NOT commit JX1 binary sprite art into a public game repo.
## Original published metadata: hudy9x/jx1-idle-web src/data/monsters-zones.js
## Source monster: Soi xam / ani009, 5 clips and 8 original direction rows.
## Combat V4 intentionally renders ONE selected horizontal row with native mirror.
const ROOT := "res://assets/labs/combat_v4/jx1_private/"
const DEFAULT_ROW := 2 # PROVISIONAL; visual verification must choose an actual side-profile row.

const CLIPS := {
    "st": {"n": 6, "d": 8, "w": 49, "h": 43, "ax": 25, "ay": 41, "ms": 143, "git_sha": "3aca6b579168c9ceb6da354889e175e00925d1a0"},
    "run": {"n": 8, "d": 8, "w": 53, "h": 46, "ax": 26, "ay": 43, "ms": 71, "git_sha": "0c74340c05da71fbe1a0f20d0e4377a073831c19"},
    "at": {"n": 7, "d": 8, "w": 73, "h": 55, "ax": 37, "ay": 53, "ms": 62, "git_sha": "9674810628b7a428a14b7816be997823fdc0fd51"},
    "hurt": {"n": 3, "d": 8, "w": 72, "h": 46, "ax": 36, "ay": 42, "ms": 83, "git_sha": "06701d1dee3ff4f0ce6e8ccb0522350e5590a400"},
    "die": {"n": 5, "d": 8, "w": 73, "h": 50, "ax": 37, "ay": 41, "ms": 100, "git_sha": "f6385e9008fda30f2a53a28adfc551b80da2bcf0"
}

static func path_for(clip: String) -> String:
    return ROOT + "ani009_" + clip + ".webp"

static func _git_blob_sha1(bytes: PackedByteArray) -> String:
    var hash := HashingContext.new()
    if hash.start(HashingContext.HASH_SHA1) != OK:
        return ""
    hash.update(("blob " + str(bytes.size())).to_utf8_buffer())
    hash.update(PackedByteArray([0]))
    hash.update(bytes)
    return hash.finish().hex_encode()

static func load_verified() -> Dictionary:
    # All five assets must match the original Git blob bytes and shape; no partial fake "ready".
    var loaded: Dictionary = {}
    for key in CLIPS:
        var meta: Dictionary = CLIPS[key]
        var path := path_for(key)
        if not FileAccess.file_exists(path) or not ResourceLoader.exists(path):
            return {}
        var raw := FileAccess.get_file_as_bytes(path)
        if raw.size() < 16 or _git_blob_sha1(raw) != str(meta["git_sha"]):
            push_warning("CMB-V4 JX1 source SHA invalid: " + path)
            return {}
        var tex: Texture2D = load(path) as Texture2D
        if tex == null or tex.get_width() != int(meta["w"]) * int(meta["n"]) or tex.get_height() != int(meta["h"]) * int(meta["d"]):
            push_warning("CMB-V4 JX1 sprite dimensions invalid: " + path)
            return {}
        loaded[key] = tex
    return loaded

static func clip_for_state(state: String) -> String:
    match state:
        "walk", "run":
            return "run"
        "attack":
            return "at"
        "hit":
            return "hurt"
        "downed":
            return "die"
        _:
            return "st"

static func setup_sprite(sprite: Sprite2D, textures: Dictionary, clip: String, row: int, seconds: float, ended: bool) -> void:
    if sprite == null or not textures.has(clip) or not CLIPS.has(clip):
        return
    var spec: Dictionary = CLIPS[clip]
    sprite.texture = textures[clip]
    sprite.hframes = int(spec["n"])
    sprite.vframes = int(spec["d"])
    var n := int(spec["n"])
    var index := n - 1 if ended else int(floor(seconds * 1000.0 / float(spec["ms"]))) % n
    sprite.frame_coords = Vector2i(index, clampi(row, 0, int(spec["d"]) - 1))
    # Per-clip frame registration from the original game's renderer.
    # Sprite2D centered: move image so source anchor (ax,ay) lands on actor world position.
    sprite.offset = Vector2(float(spec["w"]) * 0.5 - float(spec["ax"]),
        float(spec["h"]) * 0.5 - float(spec["ay"]))
