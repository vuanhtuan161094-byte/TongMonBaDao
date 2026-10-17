extends SceneTree

# Pure geometry and blocked construction preview only; NOT authorized land
# unlocking, Hall building or real construction.
func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var plan := SectLandRegionPreviewV2.preview()
    var geometry := SectLandRegionPreviewV2.geometry_report()
    if not bool(geometry.get("ok",false)) or int(geometry.get("covered_cells",0)) != 36864:
        push_error("LAY-V2 proposed 13-region geometry has overlap or holes")
        quit(1)
        return
    if bool(plan.get("ok",true)) or not bool(plan.get("preview_only",false)) or int(plan.get("region_count",0)) != 13:
        push_error("LAY-V2 preview illegally claims an active build/land authority")
        quit(1)
        return
    if int(plan.get("starter_cells",0)) != 2304 or int(plan.get("chunk_cells",0)) != 16:
        push_error("LAY-V2 preview changed approved 48x48 starter or chunk-16")
        quit(1)
        return
    var starter_count := 0
    for region in SectLandRegionPreviewV2.proposed_regions():
        if str(region.get("id","")) == "starter":
            starter_count += 1
            if SectLandRegionPreviewV2.region_rect(region) != Rect2i(72,72,48,48):
                push_error("LAY-V2 region shifted canonical starter proposal")
                quit(1)
                return
    if starter_count != 1:
        push_error("LAY-V2 starter proposal duplicated")
        quit(1)
        return
    print("LAY-V2 GEOMETRY DESIGN PREVIEW ONLY: PASS")
    quit(0)
