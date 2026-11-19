extends SceneTree
## Source-contract QA for the actual PvE AS-CHAR renderer. No generated rigs.
## Run: godot --headless --path godot --script res://tests/presentation/aschar_pve_renderer_test.gd
const BRIDGE = preload("res://src/presentation/p3/sect_aschar_candidate_bridge_v1.gd")
const RENDERER = preload("res://src/presentation/p3/pve_aschar_frame_renderer_v1.gd")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var checked := 0
    var directional := 0
    var incomplete_sockets := 0
    var sexes := ["male","female"]
    for school in BRIDGE.SCHOOL_IDS:
        for sex in sexes:
            var id := BRIDGE.actor_id(school,sex)
            var path := str(BRIDGE.SOURCE_PATHS.get(id,""))
            if id < 48 or id > 71 or not ResourceLoader.exists(path,"SpriteFrames"):
                _fail("missing source %s %s" % [school,sex])
                return
            var manifest := RENDERER._manifest(id)
            if manifest.is_empty() or not FileAccess.file_exists(
                    BRIDGE.SOCKET_ROOT+"/AS%d_weapon_sockets_v9_3_candidate.json" % id):
                _fail("missing manifest AS%d" % id)
                return
            var clips: Dictionary = {}
            for raw in manifest.get("body_frames",[]):
                if raw is Dictionary:
                    clips[str(raw.get("clip",""))] = true
            for direction in ["front","right","back","left"]:
                var prefix := "idle_"+direction
                if clips.has(prefix):
                    directional += 1
                else:
                    incomplete_sockets += 1
            if not clips.has("idle_front"):
                _fail("front identity missing AS%d" % id)
                return
            checked += 1
    # Actual frame resolution + fallback, not only file presence.
    var frames := RENDERER._sprite_frames(48)
    if frames == null:
        _fail("real AS48 SpriteFrames failed to load")
        return
    for action in ["idle","run","attack","cast","hit","die"]:
        for face in [Vector2.DOWN,Vector2.UP,Vector2.LEFT,Vector2.RIGHT]:
            var clip := RENDERER.resolve_clip(frames,action,face)
            if clip.is_empty() or frames.get_frame_count(StringName(clip)) <= 0:
                _fail("unresolved animation %s %s" % [action,str(face)])
                return
    print("ASCHAR PVE SOURCE PASS: %d/24 identities; %d/96 direction socket clips; %d fallback direction socket rows; 6 actions x 4 faces AS48" % [checked,directional,incomplete_sockets])
    quit(0)

func _fail(reason: String) -> void:
    push_error("ASCHAR PVE SOURCE FAIL "+reason)
    quit(1)
