extends SceneTree

# Focused source-VL atlas + V2 visual isolation gate. Run after Godot --headless --import.
func _init() -> void:
    call_deferred("_run")

func _assert(ok: bool, reason: String) -> bool:
    if not ok:
        push_error("C4-VP01: " + reason)
        quit(1)
        return false
    return true

func _run() -> void:
    var atlas := CombatV4SpriteAtlas.new()
    if not _assert(atlas.has_actor("hero") and atlas.has_actor("wolf"),"real Source VL atlas metadata missing"):
        return
    for archetype in ["hero","wolf"]:
        for action in ["idle","run","attack","hit","die"]:
            for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
                var sprite: Dictionary = atlas.frame_region(archetype,action,direction,0.1)
                if not _assert(not sprite.is_empty(),"missing/out-of-bounds texture: "+archetype+" "+action):
                    return
                if not _assert(sprite["texture"] is Texture2D and (sprite["source"] as Rect2).size.x > 0.0,
                    "invalid loaded texture region"):
                    return
    var vfx := CombatV4EffectAtlas.new()
    for effect in ["sword_cast","sword_hit"]:
        if not _assert(vfx.duration(effect) > 0.0,"VFX source duration missing: "+effect):
            return
        var sample: Dictionary = vfx.frame_region(effect,0.035)
        if not _assert(not sample.is_empty() and sample["texture"] is Texture2D,
            "original VFX atlas failed frame bounds: "+effect):
            return
    var hero: Dictionary = CombatStatsV2.derive(2,1,2,1,0.0)
    if not _assert(bool(hero.get("ok",false)),"V2 stat fixture failed"):
        return
    var member := {
        "id":"p01","party_id":"team_a","role":"ranged",
        "stats":hero["stats"],"position":Vector2(8.0,10.0),
        "hp":float(hero["stats"]["max_hp"]),"skill_loadout":["ngu_kiem_thuat"]
    }
    var wolf: Dictionary = MonsterCatalogueV2.create_actor("thanh_lang",1,1,"w01")
    if not _assert(bool(wolf.get("ok",false)),"V2 wolf fixture missing"):
        return
    wolf["id"] = "w01"
    wolf["position"] = Vector2(12.0,10.0)
    var battle := MapBattleV2.new(8171)
    if not _assert(bool(battle.setup("combat_v4_visual_test",[member],[wolf]).get("ok",false)),
        "real V2 setup rejected"):
        return
    var view := MapBattleWorldLayerV2.new()
    view.enable_source_vl_art = true
    view.draw_pilot_ground = true
    get_root().add_child(view)
    view.attach_session(battle)
    var before_now := battle.now
    var before_rng: int = battle.rng.snapshot_seed_state()
    view.refresh_from_authority()
    if not _assert(battle.now == before_now and battle.rng.snapshot_seed_state() == before_rng,
        "renderer advanced combat time or RNG"):
        return
    for i in range(8):
        if not battle.active:
            break
        battle.step(true)
        view.refresh_from_authority()
    if not _assert(view._event_cursor == battle.events.size(),"renderer failed to consume typed events"):
        return
    var seen_real_cast := false
    var seen_real_hit := false
    for row in battle.events:
        if str(row.get("type","")) == "skill_cast" and str(row.get("skill_id","")) == "ngu_kiem_thuat":
            seen_real_cast = true
        if str(row.get("type","")) == "skill_hit" and str(row.get("skill_id","")) == "ngu_kiem_thuat":
            seen_real_hit = true
    if not _assert(seen_real_cast and seen_real_hit,"V2 did not deliver true authored skill cast and hit"):
        return
    var cursor := view._event_cursor
    var post_tick := battle.now
    var post_rng: int = battle.rng.snapshot_seed_state()
    view.refresh_from_authority()
    if not _assert(view._event_cursor == cursor and battle.now == post_tick and
            battle.rng.snapshot_seed_state() == post_rng,"renderer duplicated events or mutated authority"):
        return
    view.queue_free()
    print("C4-VP01 SOURCE VL REAL ATLAS + MAPBATTLE V2 VISUAL TEST: PASS")
    quit(0)
