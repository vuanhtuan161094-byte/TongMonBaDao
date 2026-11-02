extends SceneTree

# Accept only exact SHA-256 Source A images documented in ENV02A baseline.
# Asset binary is optional; absent/staged-wrong asset must not crash the map.
func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var art := SectMap25SourceArt.new()
    if not art.manifest_valid:
        _fail("manifest not parseable")
        return
    if art.index.size() != 34:
        _fail("expected 34 unique curated PNG keys including TRI-02 Source A building intake")
        return
    var raw := FileAccess.open(SectMap25SourceArt.INDEX,FileAccess.READ)
    if raw == null:
        _fail("manifest cannot be opened")
        return
    var parsed = JSON.parse_string(raw.get_as_text())
    var specs: Dictionary = parsed.get("files",{})
    var required: Dictionary = {
        "pv01_assets/main_hall/510052.png": {"sha256":"b6bf88c35e3edc33aba822124296af15a5c8491a05c28f6b5d7b342d20d5325c","size":Vector2i(1104,740)},
        "pv01_assets/residence/510076.png": {"sha256":"f8e05d7376fc5ddc7b25f56673b6d5f444b10fd759da06a5929ec4f38a68d320","size":Vector2i(536,416)},
        "pv01_assets/guidance/510111.png": {"sha256":"90b7c595f3b77788c99924ef2eb7ba4b8ede794ccffda1c6808263ba3c711762","size":Vector2i(532,592)}
    }
    for relative in required:
        var required_spec: Dictionary = required[relative]
        var entry: Dictionary = specs.get(relative,{})
        if str(entry.get("sha256","")) != str(required_spec["sha256"]):
            _fail("TRI-02 source SHA mismatch for %s" % relative)
            return
        var path := str(entry.get("path",""))
        if not FileAccess.file_exists(path):
            _fail("TRI-02 Source A PNG missing from the project: %s" % relative)
            return
        var image := Image.load_from_file(ProjectSettings.globalize_path(path))
        if image == null or image.is_empty() or image.get_size() != required_spec["size"] or not image.has_alpha():
            _fail("TRI-02 Source A image dimensions/alpha mismatch: %s" % relative)
            return
        var has_clear := false
        var has_opaque := false
        var has_semitransparent := false
        for y in range(image.get_height()):
            for x in range(image.get_width()):
                var alpha: float = image.get_pixel(x,y).a
                has_clear = has_clear or alpha <= 0.001
                has_opaque = has_opaque or alpha >= 0.999
                has_semitransparent = has_semitransparent or (alpha > 0.001 and alpha < 0.999)
        if not has_clear or not has_opaque or not has_semitransparent:
            _fail("TRI-02 source must retain transparent, opaque and anti-aliased edges: %s" % relative)
            return
    for relative in specs.keys():
        var entry: Dictionary = specs[relative]
        var path := str(entry.get("path",""))
        var expected := str(entry.get("sha256",""))
        if not path.begins_with("res://art/source_a_env02a/") or expected.length() != 64:
            _fail("unexpected untrusted art path or hash")
            return
        var tex := art.texture_for(str(relative))
        if FileAccess.file_exists(path):
            if FileAccess.get_sha256(path).to_lower() == expected:
                if tex == null or tex.get_width() <= 0:
                    _fail("verified PNG failed to load")
                    return
            elif tex != null:
                _fail("unverified/mismatched byte art was accepted")
                return
        elif tex != null:
            _fail("missing PNG was not kept as fallback")
            return
    if art.texture_for("../unsafe.png") != null:
        _fail("unwhitelisted asset accepted")
        return
    var status := art.status()
    if int(status.get("accepted_count",-1))+int(status.get("missing_count",-1))+int(status.get("rejected_count",-1)) != 34:
        _fail("asset audit counts do not add up to 34")
        return
    print("MAP25 SOURCE A SHA-GATED ART CONTRACT PASS assets=34 accepted=",status["accepted_count"]," missing=",status["missing_count"]," rejected=",status["rejected_count"])
    quit(0)

func _fail(message: String) -> void:
    push_error("MAP25 SOURCE ART CONTRACT FAIL: "+message)
    quit(1)
