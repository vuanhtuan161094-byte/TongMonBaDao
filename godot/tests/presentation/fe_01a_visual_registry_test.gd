extends SceneTree

# A test of presentation metadata only; no binary textures or simulation involved.
func _init() -> void:
    call_deferred("_run")


func _fail(reason: String) -> void:
    push_error("FE-01A: " + reason)
    quit(1)


func _run() -> void:
    var registry := VisualAssetRegistry.load_default()
    if not registry.is_valid() or registry.candidate_count() != 13:
        _fail("Expected 13 valid candidates: " + str(registry.errors()))
        return
    var source: Variant = JSON.parse_string(FileAccess.get_file_as_string(
        VisualAssetRegistry.DEFAULT_MANIFEST_PATH
    ))
    if not (source is Dictionary):
        _fail("Cannot parse source manifest")
        return
    var baseline: Dictionary = source
    var analog_count := 0
    var legacy_count := 0
    var destinations: Dictionary = {}
    for entry in baseline["candidates"]:
        var item: Dictionary = entry
        var dest := str(item["destination_id"])
        if destinations.has(dest):
            _fail("Duplicate destination")
            return
        destinations[dest] = true
        var resolved: Dictionary = registry.resolve_destination(dest)
        if str(resolved.get("status", "")) != "FALLBACK_ONLY":
            _fail("Never render candidate binary before FE-01B")
            return
        if str(resolved.get("resource_path", "X")) != "":
            _fail("Unapproved runtime path leaked")
            return
        if str(item["evidence_status"]) == "INFERRED_VISUAL_ANALOG":
            analog_count += 1
        if not str(item["legacy_visual_asset_id"]).is_empty():
            legacy_count += 1
        var copied: Dictionary = registry.for_destination(dest)
        if copied != item:
            _fail("Candidate lookup must preserve all metadata")
            return
    if analog_count != 3 or legacy_count != 8:
        _fail("10 VERIFIED + 3 visual analogs + 8 original S3 IDs required")
        return
    if registry.candidates_for_source_model(520031).size() != 2:
        _fail("Alchemy and Medicine must intentionally share model 520031")
        return
    var body: Dictionary = registry.for_destination("ren_than_duong")
    var gate: Dictionary = registry.for_destination("gate")
    if str(body.get("shared_texture_group", "")) != "texture_cuizhi" \
            or str(gate.get("shared_texture_group", "")) != "texture_cuizhi":
        _fail("Body-training and gate shared texture must be explicit")
        return
    var snapshot: Dictionary = registry.for_destination("main_hall")
    snapshot["source_dependencies"][0]["sha256"] = "tampered"
    snapshot["destination_id"] = "tampered"
    if str(registry.for_destination("main_hall")["destination_id"]) != "main_hall" \
            or str(registry.for_destination("main_hall")["source_dependencies"][0]["sha256"]) == "tampered":
        _fail("Snapshots must be deep copies")
        return
    if str(registry.resolve_destination("not_real")["status"]) != "UNMAPPED":
        _fail("Unknown destinations should fail closed")
        return

    var duplicate: Dictionary = baseline.duplicate(true)
    duplicate["candidates"][1]["candidate_id"] = duplicate["candidates"][0]["candidate_id"]
    if VisualAssetRegistry.from_dictionary(duplicate).is_valid():
        _fail("Duplicate candidate accepted")
        return
    var collision: Dictionary = baseline.duplicate(true)
    collision["candidates"][1]["destination_id"] = collision["candidates"][0]["destination_id"]
    if VisualAssetRegistry.from_dictionary(collision).is_valid():
        _fail("Duplicate destination accepted")
        return
    var injected: Dictionary = baseline.duplicate(true)
    injected["candidates"][0]["runtime_resource_path"] = "res://assets/unapproved.png"
    if VisualAssetRegistry.from_dictionary(injected).is_valid():
        _fail("Unapproved runtime path accepted")
        return
    var promoted: Dictionary = baseline.duplicate(true)
    promoted["candidates"][0]["visual_status"] = "approved"
    if VisualAssetRegistry.from_dictionary(promoted).is_valid():
        _fail("Silent approval promotion accepted")
        return
    var unknown_rights: Dictionary = baseline.duplicate(true)
    unknown_rights["candidates"][0]["release_rights"] = "GRANTED"
    if VisualAssetRegistry.from_dictionary(unknown_rights).is_valid():
        _fail("Unverified release rights treated as granted")
        return
    var wrong_analogs: Dictionary = baseline.duplicate(true)
    wrong_analogs["candidates"][0]["evidence_status"] = "INFERRED_VISUAL_ANALOG"
    if VisualAssetRegistry.from_dictionary(wrong_analogs).is_valid():
        _fail("Misclassified analog count accepted")
        return
    var bypass_binary: Dictionary = baseline.duplicate(true)
    bypass_binary["binary_transport"] = "LFS_ENABLED"
    if VisualAssetRegistry.from_dictionary(bypass_binary).is_valid():
        _fail("Unapproved binary transport accepted")
        return

    print("FE-01A VISUAL REGISTRY TEST PASS: 13 candidates, 3 analogs, 8 S3 aliases, shared sources, defensive copies, fail closed")
    quit(0)
