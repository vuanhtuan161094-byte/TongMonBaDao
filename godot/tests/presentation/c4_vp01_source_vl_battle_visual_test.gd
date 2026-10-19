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
    # Exercise every real 8-direction actor frame at its actual animation age.
    # Do NOT silently test only one tile in a multi-row WebP atlas.
    for archetype in ["hero","wolf"]:
        var sheet: Dictionary = atlas.sheets[archetype]
        var direction_count := int(sheet["directions"])
        if not _assert(direction_count == 8,"source VL expected all 8 authored views"):
            return
        for action in ["idle","run","attack","hit","die"]:
            var clip: Dictionary = sheet["actions"][action]
            var frame_count := int(clip["frames"])
            var fps := CombatV4SpriteAtlas.DEFAULT_FPS
            var cycle_value = clip.get("duration",null)
            if cycle_value is float or cycle_value is int:
                if float(cycle_value) > 0.0:
                    fps = float(frame_count)/float(cycle_value)
            for dir_index in range(direction_count):
                var facing := Vector2.RIGHT.rotated(TAU * float(dir_index) / float(direction_count))
                for frame in range(frame_count):
                    var age := (float(frame)+0.10)/fps
                    var sprite: Dictionary = atlas.frame_region(archetype,action,facing,age)
                    if not _assert(not sprite.is_empty(),
                            "missing source frame: "+archetype+" "+action+" "+str(dir_index)+"/"+str(frame)):
                        return
                    if not _assert(sprite["texture"] is Texture2D and
                            (sprite["source"] as Rect2).size.x > 0.0,
                            "invalid source atlas region"):
                        return
    var vfx := CombatV4EffectAtlas.new()
    for effect in ["sword_cast","sword_hit"]:
        if not _assert(vfx.duration(effect) > 0.0,"VFX source duration missing: "+effect):
            return
        var definition: Dictionary = vfx.effects[effect]
        var frame_count := int(definition["frames"])
        var interval := float(definition["frame_ms"])*0.001
        for frame in range(frame_count):
            var offset := frame * 6
            var rects: Array = definition["rects"]
            # A 1x1 final source sentinel denotes an empty frame, not a bug.
            var source_has_pixels := int(rects[offset+2]) > 1 and int(rects[offset+3]) > 1
            var sample: Dictionary = vfx.frame_region(effect,(float(frame)+0.10)*interval)
            if source_has_pixels:
                if not _assert(not sample.is_empty() and sample["texture"] is Texture2D,
                    "source FX atlas bounds: "+effect+" frame "+str(frame)):
                    return
            elif not _assert(sample.is_empty(),"sentinel FX frame should not be rendered"):
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
    # Source VL wolf foot anchors can sit BELOW cropped image bounds.
    # Check the true rendered atlas top, using its render-only foot correction.
    # This is NOT an actor position or collision offset.
    for probe in [
        {"key":"hero","scale":0.92,"radius":6.0,"bar_height":6.0},
        {"key":"wolf","scale":1.52,"radius":10.0,"bar_height":7.0}
    ]:
        var sprite_frame: Dictionary = atlas.frame_region(str(probe["key"]),"idle",Vector2.RIGHT,0.0)
        var ratio: float = float(probe["scale"])*float(sprite_frame["scale"])
        var anchor: Vector2 = sprite_frame["anchor"]
        var crop: Rect2 = sprite_frame["source"]
        var baseline := Vector2(500.0,300.0)
        var drawn_foot := view.source_art_foot(str(probe["key"]),"idle",
            Vector2.RIGHT,0.0,float(probe["scale"]),baseline)
        var top := drawn_foot.y-anchor.y*ratio-baseline.y
        var y := view._hp_bar_y(str(probe["key"]),"idle",Vector2.RIGHT,0.0,
            float(probe["scale"]),float(probe["radius"]))
        if not _assert(y+float(probe["bar_height"]) < top,
                "HP bar overlaps the actual adjusted source sprite top: "+str(probe["key"])):
            return
        var expected_drop := maxf(0.0,anchor.y-crop.size.y)*ratio
        if not _assert(is_equal_approx(drawn_foot.y-baseline.y,expected_drop),
                "source image moved by an ungrounded foot anchor offset: "+str(probe["key"])):
            return
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
    var post_actors: Dictionary = battle.actors.duplicate(true)
    var post_casts: Array = battle.pending_casts.duplicate(true)
    var post_events: Array = battle.events.duplicate(true)
    var post_actions: int = battle.actions
    var post_outcome: String = battle.outcome
    var actual_cast_fx := 0
    var actual_hit_fx := 0
    for cue_value in view._effect_cues:
        var cue: Dictionary = cue_value
        if str(cue.get("kind","")) == "sword_cast":
            actual_cast_fx += 1
        elif str(cue.get("kind","")) == "sword_hit":
            actual_hit_fx += 1
    if not _assert(actual_cast_fx == 1 and actual_hit_fx == 1,
            "typed V2 skill cast/hit did not produce exactly one mapped VFX cue each"):
        return
    view.refresh_from_authority()
    if not _assert(view._event_cursor == cursor and view._effect_cues.size() == actual_cast_fx+actual_hit_fx,
            "refresh replayed source FX cues"):
        return
    # Trigger genuine _draw/_process in SceneTree, not only a no-op queue_redraw.
    view.queue_redraw()
    await process_frame
    await process_frame
    if not _assert(battle.now == post_tick and battle.rng.snapshot_seed_state() == post_rng and
            battle.actors == post_actors and battle.pending_casts == post_casts and
            battle.events == post_events and battle.actions == post_actions and
            battle.outcome == post_outcome,
            "draw/animation mutated HP, positions, casts, events, RNG or result"):
        return
    # 100ms real frame must advance 100ms in the cosmetic clock even on slow devices.
    var previous_frame_clock := view._frame_clock
    view._process(0.10)
    if not _assert(is_equal_approx(view._frame_clock-previous_frame_clock,0.10),
            "visual frame clock clamps real elapsed time and slows animation"):
        return
    # Combat can be stopped mid-action: action and run cues must expire independently
    # of frozen battle.now. No gameplay ticks are issued in this visual-only check.
    view._action_cues["p01"] = {
        "action":"attack","started":view._frame_clock,"until":view._frame_clock+0.05
    }
    view._frame_clock += 0.30
    if not _assert(str(view._actor_clip("p01",true).get("name","")) != "attack",
            "frozen combat time stranded actor in attack pose"):
        return
    view._action_cues.erase("p01")
    view._last_move["p01"] = view._frame_clock
    view._frame_clock += 0.40
    if not _assert(str(view._actor_clip("p01",true).get("name","")) != "run",
            "frozen combat time stranded actor in running pose"):
        return
    if not _assert(battle.now == post_tick and battle.rng.snapshot_seed_state() == post_rng and
            battle.actors == post_actors and battle.pending_casts == post_casts and
            battle.events == post_events and battle.actions == post_actions and
            battle.outcome == post_outcome,
            "visual cue expiry changed real combat state"):
        return
    # 30 simultaneous view-only cast cues cannot allocate unbounded sprites.
    view._effect_cues.clear()
    for i in range(30):
        view._queue_source_fx("sword_cast",Vector2(100.0+float(i),200.0))
    if not _assert(view._effect_cues.size() == MapBattleWorldLayerV2.MAX_VISIBLE_SOURCE_FX,
            "overdraw budget failed to cap parallel cosmetic casts"):
        return
    view._queue_source_fx("sword_hit",Vector2(440.0,300.0))
    var has_hit := false
    for fx_value in view._effect_cues:
        if str(fx_value.get("kind","")) == "sword_hit":
            has_hit = true
    if not _assert(has_hit and view._effect_cues.size() == MapBattleWorldLayerV2.MAX_VISIBLE_SOURCE_FX,
            "real settled hit FX lost priority under visual-only budget"):
        return
    if not _assert(battle.now == post_tick and battle.rng.snapshot_seed_state() == post_rng and
            battle.actors == post_actors and battle.pending_casts == post_casts and
            battle.events == post_events and battle.actions == post_actions and
            battle.outcome == post_outcome,
            "FX budget modified combat authority"):
        return
    view.queue_free()
    print("C4-VP01 SOURCE VL REAL ATLAS + MAPBATTLE V2 VISUAL TEST: PASS")
    quit(0)
