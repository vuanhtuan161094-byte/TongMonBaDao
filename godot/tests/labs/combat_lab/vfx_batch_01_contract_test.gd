extends SceneTree
const LAB = preload("res://labs/vfx_batch/tmb_vfx_batch_preview.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_test")

func _check(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error("VFX_BATCH_FAIL " + message)

func _test() -> void:
    var preview := LAB.new()
    root.add_child(preview)
    await process_frame
    _check(preview.manifest.get("schema") == "tmb.vfx.batch.v1", "manifest schema")
    _check(preview._error == "", "no loader errors")
    _check(preview.skill_by_id.size() == 2196, "2196 unique IDs")
    _check(preview.family_by_id.size() == 420, "420 family IDs")
    _check(preview.TEX.size() == 17, "17 original or prior-approved material textures")
    var cast := 0
    var event_only := 0
    var approved := 0
    var draft := 0
    for f in preview.manifest.get("masters", []):
        _check(f is Dictionary, "each family is dictionary")
        if not f is Dictionary: continue
        _check(str(f.get("id", "")).length() > 10, "valid canonical family ID")
        _check(preview.TEX.has(LAB.asset_key(f)), "material key for " + str(f.get("id", "")))
        if f.get("kind") == "CAST_MASTER":
            cast += 1
            _check(LAB.visual_kind(f) != "", "visual routing per family")
            if f.get("status") == "OWNER_APPROVED_LAB_LOCKED":
                approved += 1
                _check(str(f.get("school")) == "poison", "owner approval only poison pilots")
                _check(ResourceLoader.exists(str(f.get("scene",""))), "owner approved scene still available")
            else:
                draft += 1
                _check(f.get("status") == "BATCH_PREVIEW_UNREVIEWED", "draft not owner approved")
        else:
            event_only += 1
            _check(f.get("status") == "EVENT_ONLY_NO_CAST", "no dummy cast for passive/innate")
            _check(str(f.get("scene","")) == "", "no fabricated passive scene")
    _check(cast == 204, "204 cast family previews")
    _check(event_only == 216, "216 passive/event families suppressed")
    _check(approved == 3 and draft == 201, "3 locked original, 201 preview pending")
    var per_school: Dictionary = {}
    var seen: Dictionary = {}
    for entry in preview.manifest.get("skills", []):
        _check(entry is Array and entry.size() == 9, "fixed 9-column row")
        if not entry is Array or entry.size() != 9: continue
        var id := str(entry[0])
        _check(not seen.has(id), "no repeated id "+id)
        seen[id] = true
        _check(preview.family_by_id.has(str(entry[1])), "skill family exists "+id)
        var f: Dictionary = preview.family_by_id.get(str(entry[1]),{})
        _check(str(entry[3]) == str(f.get("school","")), "school mapped "+id)
        _check(str(entry[5]) == str(f.get("kind","")), "cast/event policy mapped "+id)
        var school := str(entry[3])
        per_school[school] = int(per_school.get(school,0))+1
    _check(per_school.size() == 12, "12 school inventory")
    for school in per_school.keys():
        _check(per_school[school] == 183, "each school 183 variants "+school)
    _check(preview.get_family("tmb.skill.poison.co_doc.active_02").get("status") == "OWNER_APPROVED_LAB_LOCKED", "preserve approved serpent")
    _check(preview.get_skill("tmb.skill.poison.co_doc.active_03.human").size() == 9, "approved Co Vu skill mapping")
    _check(preview.playlist.size() == 14, "14 new poison preview masters, 3 approved held")
    preview.mode = "schools"
    preview._build_playlist()
    _check(preview.playlist.size() == 24, "24 cross-school preview samples")
    preview.mode = "all"
    preview._build_playlist()
    _check(preview.playlist.size() == 201, "201 unreviewed cast families selectable")
    _check(LAB.phase_at(0.30) == "charge" and LAB.phase_at(1.1) == "flight" and LAB.phase_at(2.4) == "contact" and LAB.phase_at(3.5) == "fade", "four art-only phases")
    _check(LAB.travel_at(0.2) == 0.0 and LAB.travel_at(LAB.PREVIEW_CONTACT) == 1.0, "flight travel bounded")
    var source := FileAccess.get_file_as_string("res://labs/vfx_batch/tmb_vfx_batch_preview.gd")
    for forbidden in ["SaveService.save", "CombatV2.", "apply_damage", "apply_status", "V63FeatureGates.", "MapBattleV2."]:
        _check(not source.contains(forbidden), "preview has no combat authority "+forbidden)
    print("VFX_BATCH_FOCUSED_RESULT=" + ("PASS" if failures == 0 else "FAIL") + " failures=" + str(failures) + " cast="+str(cast)+" event="+str(event_only)+" skill_ids="+str(seen.size()))
    preview.queue_free()
    quit(0 if failures == 0 else 1)
