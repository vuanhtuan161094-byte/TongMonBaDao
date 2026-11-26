extends SceneTree
# Exact imported atlas inventory contract; actual combat remains independently
# exercised by the authoritative PvE and combat-matrix workflows.
func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/presentation/pve_factory_r2.json"))
    if not (raw is Dictionary) or raw.get("schema","") != "tmb.pve.factory_r2.v1":
        _fail("missing factory data")
        return
    var entries: Dictionary = raw.get("bindings",{})
    if entries.size() != 58:
        _fail("unexpected binding count")
        return
    var checked: Dictionary = {}
    for id in entries:
        var entry: Dictionary = entries[id]
        var definition := V63HumanSkillCombatSystem.skill_definition(str(id))
        if definition.is_empty() or str(definition.get("effect","")) != str(entry["effect"]) or str(definition.get("shape","")) != str(entry["shape"]) or int(definition.get("target_limit",0)) != int(entry["limit"]):
            _fail("canonical effect/shape/limit mismatch "+str(id))
            return
        if entry.get("receipts",{}).is_empty():
            _fail("no receipt binding "+str(id))
            return
        for row in entry.get("phases",{}).values():
            for frame in row.get("frames",[]):
                var path := str(frame.get("path",""))
                if not checked.has(path):
                    var texture := ResourceLoader.load(path,"Texture2D",ResourceLoader.CACHE_MODE_IGNORE) as Texture2D
                    if texture == null:
                        _fail("texture import missing "+path)
                        return
                    checked[path] = texture.get_size()
                var size: Vector2 = checked[path]
                var bounds: Array = frame.get("region",[])
                if bounds.size() == 4 and not Rect2(Vector2.ZERO,size).encloses(Rect2(float(bounds[0]),float(bounds[1]),float(bounds[2]),float(bounds[3]))):
                    _fail("atlas region out of bounds "+path)
                    return
    print("PVE_FACTORY_R2_SOURCE_CONTRACT_PASS skills=",entries.size()," unique_textures=",checked.size())
    quit(0)

func _fail(detail: String) -> void:
    push_error("PVE_FACTORY_R2_SOURCE_CONTRACT_FAIL "+detail)
    quit(1)
