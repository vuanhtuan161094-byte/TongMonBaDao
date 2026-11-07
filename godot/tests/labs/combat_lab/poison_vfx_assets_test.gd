extends SceneTree

const VfxV2 := preload("res://labs/combat_lab/combat_lab_vfx_v2.gd")
const MANIFEST_PATH := "res://labs/combat_lab/assets/poison_vfx/poison_vfx_manifest.json"

var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures += 1
        push_error("POISON_VFX_ASSET_FAIL " + message)

func _sha256(path: String) -> String:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return ""
    var context := HashingContext.new()
    if context.start(HashingContext.HASH_SHA256) != OK:
        file.close()
        return ""
    while not file.eof_reached():
        context.update(file.get_buffer(65536))
    file.close()
    return context.finish().hex_encode()

func _run() -> void:
    var manifest_file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
    _check(manifest_file != null, "manifest exists")
    if manifest_file == null:
        quit(1)
        return
    var manifest: Variant = JSON.parse_string(manifest_file.get_as_text())
    manifest_file.close()
    _check(manifest is Dictionary and int(manifest.get("schema_version", 0)) == 1,
        "manifest schema version 1 parses")
    if not manifest is Dictionary:
        quit(1)
        return
    var assets: Array = manifest.get("assets", [])
    _check(assets.size() == 4, "four original Poison texture masters listed")
    for row in assets:
        if not row is Dictionary:
            _check(false, "asset row is an object")
            continue
        var path := str(row.get("path", ""))
        var texture := ResourceLoader.load(path) as Texture2D
        _check(texture != null and texture.get_width() > 0 and texture.get_height() > 0,
            "texture imports and loads: " + path)
        _check(_sha256(path) == str(row.get("sha256", "")).to_lower(),
            "texture SHA matches manifest: " + path)
    var atlases: Array = manifest.get("preserved_source_actor_atlases", [])
    _check(atlases.size() == 6, "all six Nữ Độc Tu atlases fingerprinted")
    for row in atlases:
        if row is Dictionary:
            var path := str(row.get("path", ""))
            _check(_sha256(path) == str(row.get("sha256", "")).to_lower(),
                "source atlas unchanged: " + path)
        else:
            _check(false, "atlas fingerprint row is an object")
    _check(VfxV2.poison_branch("tmb.skill.poison.doc_cham.active_03.human") == "doc_cham"
        and VfxV2.poison_branch("tmb.skill.poison.co_doc.active_03.human") == "co_doc"
        and VfxV2.poison_branch("tmb.skill.poison.duoc_doc.active_03.human") == "duoc_doc",
        "canonical skill IDs map to the three visual branch families")
    print("POISON_VFX_ASSET_RESULT=" + ("PASS" if failures == 0 else "FAIL") + " failures=" + str(failures))
    quit(0 if failures == 0 else 1)
