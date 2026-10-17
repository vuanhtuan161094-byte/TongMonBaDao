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
    if art.index.size() != 32:
        _fail("expected exactly 32 unique curated PNG keys from ENV02A")
        return
    var raw := FileAccess.open(SectMap25SourceArt.INDEX,FileAccess.READ)
    if raw == null:
        _fail("manifest cannot be opened")
        return
    var parsed = JSON.parse_string(raw.get_as_text())
    var specs: Dictionary = parsed.get("files",{})
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
    if int(status.get("accepted_count",-1))+int(status.get("missing_count",-1))+int(status.get("rejected_count",-1)) != 32:
        _fail("asset audit counts do not add up")
        return
    print("MAP25 SOURCE A SHA-GATED ART CONTRACT PASS accepted=",status["accepted_count"]," missing=",status["missing_count"]," rejected=",status["rejected_count"])
    quit(0)

func _fail(message: String) -> void:
    push_error("MAP25 SOURCE ART CONTRACT FAIL: "+message)
    quit(1)
