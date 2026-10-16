class_name SectLandRegionPreviewV2
extends RefCounted

# DESIGN-ONLY read model. 192×192 cells and 13 disjoint proposed regions.
# This script NEVER opens land, debits materials, stores layout in a save,
# claims an actual Hall level, or authorizes game building construction.
const WORLD_CELLS := 192
const CHUNK_CELLS := 16
const STARTER_ID := "starter"
const REGIONS := [
    {"id":"starter","x":72,"y":72,"w":48,"h":48},
    {"id":"north_01","x":72,"y":40,"w":48,"h":32},
    {"id":"east_01","x":120,"y":72,"w":32,"h":48},
    {"id":"south_01","x":72,"y":120,"w":48,"h":32},
    {"id":"west_01","x":40,"y":72,"w":32,"h":48},
    {"id":"north_02","x":72,"y":0,"w":48,"h":40},
    {"id":"south_02","x":72,"y":152,"w":48,"h":40},
    {"id":"east_02","x":152,"y":72,"w":40,"h":48},
    {"id":"west_02","x":0,"y":72,"w":40,"h":48},
    {"id":"northeast","x":120,"y":0,"w":72,"h":72},
    {"id":"southeast","x":120,"y":120,"w":72,"h":72},
    {"id":"southwest","x":0,"y":120,"w":72,"h":72},
    {"id":"northwest","x":0,"y":0,"w":72,"h":72}
]

static func proposed_regions() -> Array[Dictionary]:
    var rows: Array[Dictionary] = []
    for region in REGIONS:
        rows.append((region as Dictionary).duplicate(true))
    return rows

static func region_rect(region: Dictionary) -> Rect2i:
    return Rect2i(int(region.get("x",-1)),int(region.get("y",-1)),
        int(region.get("w",0)),int(region.get("h",0)))

static func preview() -> Dictionary:
    # This deterministic geometry does not imply that blocked terrain or all
    # 100 production buildings physically fit inside legal footprints.
    return {
        "ok":false, "preview_only":true,
        "reason":"env02a_layout_adr_cost_and_hall_pending",
        "world_cells":WORLD_CELLS,
        "chunk_cells":CHUNK_CELLS,
        "starter_cells":48*48,
        "region_count":REGIONS.size(),
        "regions":proposed_regions()
    }

static func geometry_report() -> Dictionary:
    var visited: Dictionary = {}
    var ids: Dictionary = {}
    var duplicate_ids := 0
    var out_of_bounds := 0
    var overlap := 0
    for region in REGIONS:
        var id := str(region["id"])
        if ids.has(id):
            duplicate_ids += 1
        ids[id] = true
        var rect := region_rect(region)
        for y in range(rect.position.y,rect.end.y):
            for x in range(rect.position.x,rect.end.x):
                if x < 0 or y < 0 or x >= WORLD_CELLS or y >= WORLD_CELLS:
                    out_of_bounds += 1
                    continue
                var key := "%d,%d" % [x,y]
                if visited.has(key):
                    overlap += 1
                else:
                    visited[key] = id
    return {
        "ok":duplicate_ids == 0 and out_of_bounds == 0
            and overlap == 0 and visited.size() == WORLD_CELLS*WORLD_CELLS,
        "covered_cells":visited.size(),
        "total_cells":WORLD_CELLS*WORLD_CELLS,
        "overlaps":overlap,
        "out_of_bounds":out_of_bounds,
        "duplicate_ids":duplicate_ids
    }
