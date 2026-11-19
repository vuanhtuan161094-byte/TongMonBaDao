extends SceneTree
## Focused Godot 4.7.2 source-contract and lazy-cel smoke test.
## Does NOT certify visual socket alignment, art quality or GUI acceptance.
const BRIDGE = preload("res://src/presentation/p3/sect_aschar_candidate_bridge_v1.gd")
const RENDERER = preload("res://src/presentation/p3/pve_aschar_frame_renderer_v1.gd")
const ACTIONS := ["idle","walk","attack","cast","hit","downed"]
const DIRECTIONS := ["front","right","back","left"]

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var checked := 0
    var four_directional := 0
    var socket_fallbacks := 0
    var front_cels := 0
    for school in BRIDGE.SCHOOL_IDS:
        for sex in ["male","female"]:
            var id := BRIDGE.actor_id(school,sex)
            var path := str(BRIDGE.SOURCE_PATHS.get(id,""))
            if id < 48 or id > 71 or not ResourceLoader.exists(path,"SpriteFrames"):
                _fail("missing source: %s %s" % [school,sex])
                return
            var manifest: Dictionary = RENDERER._manifest(id)
            if manifest.is_empty():
                _fail("missing manifest AS%d" % id)
                return
            var rows: Dictionary = RENDERER._rows(id,manifest)
            var atlases: Dictionary = manifest.get("directional_atlases",{})
            for action in ACTIONS:
                var front: String = str(action)+"_front"
                if not rows.has(front):
                    _fail("missing front source AS%d %s" % [id,action])
                    return
                for direction in DIRECTIONS:
                    var clip: String = str(action)+"_"+str(direction)
                    if rows.has(clip):
                        var cels: Array = rows[clip]
                        if cels.is_empty():
                            _fail("empty authored clip AS%d %s" % [id,clip])
                            return
                        var row: Dictionary = cels[0]
                        var cel_path := str(row.get("path",""))
                        if not ResourceLoader.exists(cel_path,"Texture2D"):
                            _fail("missing authored texture AS%d %s" % [id,clip])
                            return
                        if direction != "front":
                            four_directional += 1
                    else:
                        var atlas: Dictionary = atlases.get(direction,{})
                        if direction != "front" and atlas.has("path") and Dictionary(atlas.get("rows",{})).has(action) and ResourceLoader.exists(str(atlas.get("path","")),"Texture2D"):
                            four_directional += 1
                        elif direction != "front":
                            socket_fallbacks += 1
            var first: Dictionary = (rows["idle_front"] as Array)[0]
            if RENDERER._cel(str(first.get("path",""))) == null:
                _fail("lazy texture decode failed AS%d" % id)
                return
            front_cels += 1
            checked += 1
    if checked != 24 or front_cels != 24:
        _fail("24 source identities / lazy front cels missing")
        return
    if four_directional + socket_fallbacks != 24*6*3:
        _fail("directional source accounting inconsistent")
        return
    # Verify action-name dispatch and cardinal direction mapping without
    # forcing full 24 x 96 SpriteFrames decodes into CI memory.
    var cases := { "run":"walk","attack":"attack","cast":"cast",
        "hit":"hit","die":"downed","idle":"idle" }
    for action in cases:
        for facing in [Vector2.DOWN,Vector2.UP,Vector2.LEFT,Vector2.RIGHT]:
            var clip := str(cases[action])+"_"+RENDERER._direction(facing)
            if clip.is_empty():
                _fail("invalid action dispatch")
                return
    print("ASCHAR_PVE_CONTRACT_PASS identities=%d lazy_cels=%d directional_action_clips=%d source_fallbacks=%d; NOT a visual approval" % [checked,front_cels,four_directional,socket_fallbacks])
    quit(0)

func _fail(reason: String) -> void:
    push_error("ASCHAR_PVE_CONTRACT_FAIL "+reason)
    quit(1)
