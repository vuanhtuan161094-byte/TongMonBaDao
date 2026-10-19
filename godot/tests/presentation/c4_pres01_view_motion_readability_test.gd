extends SceneTree

# PRES-01 ONLY: view interpolation, role identification, HUD layout and V2 isolation.
# Run: godot --headless --path godot -s res://tests/presentation/c4_pres01_view_motion_readability_test.gd
func _init() -> void:
    call_deferred("_run")

func _check(condition: bool, label: String) -> bool:
    if not condition:
        push_error("C4 PRES-01: " + label)
        quit(1)
        return false
    return true

func _run() -> void:
    var model: Dictionary = CombatStatsV2.derive(2,1,2,1,0.0)
    if not _check(bool(model.get("ok",false)),"V2 fixture invalid"):
        return
    var member := {"id":"c4_member","party_id":"c4",
        "role":"frontline","position":Vector2(6.0,9.0),
        "stats":model["stats"],"hp":float(model["stats"]["max_hp"]),
        "pilot_skill_loadout":["jx_shaolin_15"]}
    var wolf: Dictionary = MonsterCatalogueV2.create_actor("thanh_lang",1,1,"c4_wolf")
    if not _check(bool(wolf.get("ok",false)),"V2 wolf unavailable"):
        return
    wolf["id"] = "c4_wolf"
    wolf["position"] = Vector2(15.0,9.0)
    var battle := MapBattleV2.new(41726)
    if not _check(bool(battle.setup("pres01_observation",[member],[wolf]).get("ok",false)),
            "V2 setup rejected"):
        return
    var layer := MapBattleWorldLayerV2.new()
    layer.enable_source_vl_art = true
    layer.draw_pilot_ground = true
    get_root().add_child(layer)
    layer.attach_session(battle)
    var original_position: Vector2 = battle.actors["c4_member"]["position"]
    if not _check(layer.visual_position("c4_member",original_position) == original_position,
            "initial displayed endpoint differs from authority"):
        return
    if not _check(layer._school_tag(battle.actors["c4_member"]) == "TL",
            "actual equipped pilot ID not reflected in role marker"):
        return
    if not _check(layer._actor_badge(battle.actors["c4_member"]) == "TL",
            "un-numbered fixture must preserve meaningful school badge"):
        return
    if not _check(layer._actor_badge({"id":"c4_disciple_00","pilot_loadout":["jx_shaolin_15"]}) == "TL1" and
            layer._actor_badge({"id":"c4_disciple_01","pilot_loadout":["jx_shaolin_15"]}) == "TL2",
            "same school must retain stable distinct pilot member identifiers"):
        return
    # Learned/pilot skill events have their own casting cues. Settled
    # skill_hit + hit must not replay that caster animation at impact time.
    if not _check(layer.should_start_attack_on_hit("hit","basic") and
            layer.should_start_attack_on_hit("hit","basic_followup") and
            not layer.should_start_attack_on_hit("hit","area_slam") and
            not layer.should_start_attack_on_hit("skill_hit","") and
            not layer.should_start_attack_on_hit("hit","learned_skill") and
            not layer.should_start_attack_on_hit("hit","pilot_projectile"),
            "impact stage incorrectly starts a new learned or pilot cast"):
        return
    var advanced := false
    for i in range(12):
        if not battle.active:
            break
        battle.step(true)
        var next_pos: Vector2 = battle.actors["c4_member"]["position"]
        if next_pos != original_position:
            advanced = true
            layer.refresh_from_authority()
            if not _check(layer.visual_position("c4_member",next_pos).is_equal_approx(original_position),
                    "new sim tick must not teleport the rendered actor"):
                return
            var snapshot_now := battle.now
            var snapshot_rng := battle.rng.snapshot_seed_state()
            var snapshot_actor: Dictionary = battle.actors.duplicate(true)
            var snapshot_events: Array = battle.events.duplicate(true)
            layer._view_elapsed = MapBattleV2.STEP_SECONDS*0.5
            var middle := layer.visual_position("c4_member",next_pos)
            if not _check(middle.is_equal_approx(original_position.lerp(next_pos,0.5)),
                    "250ms position interpolation mid-point is wrong"):
                return
            # FX bound to a live actor must follow the same delayed visible
            # position; unbound FX retains its explicit immutable screen point.
            var cue := {"at":Vector2(99.0,111.0),"actor_id":"c4_member"}
            var fx_at := layer.source_fx_screen_position(cue)
            if not _check(fx_at.is_equal_approx(layer.point_on_map(middle)),
                    "contact FX detached from displayed interpolated body"):
                return
            var unbound_fx := layer.source_fx_screen_position(
                {"at":Vector2(99.0,111.0),"actor_id":"nonexistent"})
            if not _check(unbound_fx == Vector2(99.0,111.0),
                    "unbound FX unexpectedly received fabricated position"):
                return
            layer._view_elapsed = MapBattleV2.STEP_SECONDS*5.0
            if not _check(layer.visual_position("c4_member",next_pos).is_equal_approx(next_pos),
                    "view interpolator overshot authoritative endpoint"):
                return
            layer.refresh_from_authority()
            if not _check(battle.now == snapshot_now and
                    battle.rng.snapshot_seed_state() == snapshot_rng and
                    battle.actors == snapshot_actor and battle.events == snapshot_events,
                    "view touched battle event/HP/position/RNG/time authority"):
                return
            break
        layer.refresh_from_authority()
        original_position = next_pos
    if not _check(advanced,"V2 character did not move for interpolation fixture"):
        return
    var bar1: Rect2 = Rect2(Vector2(300,150),Vector2(52,6))
    var bar2: Rect2 = Rect2(Vector2(308,152),Vector2(52,6))
    var placed := layer.layout_hp_overlays([
        {"rect":bar1,"fill":Color.GREEN,"ratio":0.5},
        {"rect":bar2,"fill":Color.RED,"ratio":0.7}
    ])
    if not _check(placed.size() == 2 and
            not (placed[0]["rect"] as Rect2).grow(3.0).intersects(
                (placed[1]["rect"] as Rect2).grow(3.0)),
            "two overlapping health bars remained unreadable"):
        return
    if not _check((placed[0]["rect"] as Rect2) == bar1,
            "bar layout must never mutate original entry"):
        return
    # Identical actor coordinates must not push real role/HP UI above the
    # stage or make later actors' badges cover earlier actors' badges.
    var crowded: Array[Dictionary] = []
    for n in range(11):
        crowded.append({"kind":"badge",
            "rect":Rect2(Vector2(190.0,56.0),Vector2(42.0,15.0)),
            "text":"TL"+str(n),"fill":Color.YELLOW})
    var spaced := layer.layout_hp_overlays(crowded)
    if not _check(spaced.size() == crowded.size(),
            "crowded stage label layout silently lost a genuine actor"):
        return
    var safe_stage := layer.stage_rect.grow(-4.0)
    for i in range(spaced.size()):
        var rect: Rect2 = spaced[i]["rect"]
        if not _check(safe_stage.encloses(rect),
                "crowded HUD box escaped the 1280x720 arena bounds"):
            return
        for j in range(i):
            if not _check(not rect.grow(3.0).intersects((spaced[j]["rect"] as Rect2).grow(3.0)),
                    "crowded HUD boxes overlap after decluttering"):
                return
    # Two separate display interactions do not step 0.25s simulation.
    var now_before := battle.now
    var actors_before: Dictionary = battle.actors.duplicate(true)
    var events_before: Array = battle.events.duplicate(true)
    var rng_before := battle.rng.snapshot_seed_state()
    layer._process(0.1)
    layer.queue_redraw()
    await process_frame
    await process_frame
    if not _check(battle.now == now_before and battle.actors == actors_before and
            battle.events == events_before and battle.rng.snapshot_seed_state() == rng_before,
            "view frame changed authoritative simulation"):
        return
    # Genuine V2 learned skill cast -> release -> hit is one on-screen
    # caster swing, not two (or three) independent action starts.
    var caster: Dictionary = member.duplicate(true)
    caster["id"] = "c4_cast_hero"
    caster.erase("pilot_skill_loadout")
    caster["skill_loadout"] = ["ngu_kiem_thuat"]
    caster["position"] = Vector2(6.0,9.0)
    var cast_wolf: Dictionary = wolf.duplicate(true)
    cast_wolf["id"] = "c4_cast_wolf"
    cast_wolf["position"] = Vector2(8.0,9.0)
    var release_battle := MapBattleV2.new(41726)
    if not _check(bool(release_battle.setup("pres01_learned_event",
            [caster],[cast_wolf]).get("ok",false)),
            "genuine learned-skill V2 fixture cannot initialize"):
        return
    var release_view := MapBattleWorldLayerV2.new()
    release_view.enable_source_vl_art = true
    get_root().add_child(release_view)
    release_view.attach_session(release_battle)
    if not _check(release_battle._try_learned_damage_skill(
            release_battle.actors["c4_cast_hero"],
            release_battle.actors["c4_cast_wolf"]),
            "genuine learned cast could not enter wind-up"):
        return
    release_view.refresh_from_authority()
    var original_cue: Dictionary = release_view._action_cues.get("c4_cast_hero",{})
    if not _check(not original_cue.is_empty()
            and str(original_cue.get("action","")) == "attack",
            "genuine skill_cast failed to animate caster"):
        return
    var action_started := float(original_cue["started"])
    release_view._frame_clock += 0.17
    release_battle.now = float(release_battle.pending_casts[0]["ready"])
    release_battle._release_casts()
    release_view.refresh_from_authority()
    var resolved_cue: Dictionary = release_view._action_cues.get("c4_cast_hero",{})
    if not _check(is_equal_approx(float(resolved_cue.get("started",-1.0)),
            action_started),
            "skill_hit/hit restarted the caster animation after settlement"):
        return
    var hit_fx_count := 0
    for source_cue in release_view._effect_cues:
        if str(source_cue.get("kind","")) == "sword_hit":
            hit_fx_count += 1
    if not _check(hit_fx_count == 1,
            "positive learned settlement must produce one real-source impact FX"):
        return
    release_view.queue_free()
    # Authentic monster telegraph starts the attack animation BEFORE release,
    # and area_slam settlements cannot start a second post-impact animation.
    var boss_foe := MonsterCatalogueV2.create_actor("hac_lang_vuong",1,1,
        "c4_aoe_boss")
    if not _check(bool(boss_foe.get("ok",false)),"real boss fixture missing"):
        return
    boss_foe["id"] = "c4_aoe_boss"
    boss_foe["position"] = Vector2(10.0,9.0)
    var defender: Dictionary = member.duplicate(true)
    defender["id"] = "c4_aoe_defender"
    defender["position"] = Vector2(9.0,9.0)
    var area_battle := MapBattleV2.new(41111)
    if not _check(bool(area_battle.setup("pres01_boss_telegraph",
            [defender],[boss_foe]).get("ok",false)),
            "boss telegraph V2 fixture cannot initialize"):
        return
    var area_view := MapBattleWorldLayerV2.new()
    area_view.enable_source_vl_art = true
    get_root().add_child(area_view)
    area_view.attach_session(area_battle)
    area_battle._begin_telegraphed_aoe(
        area_battle.actors["c4_aoe_boss"],area_battle.actors["c4_aoe_defender"])
    area_view.refresh_from_authority()
    var boss_cue: Dictionary = area_view._action_cues.get("c4_aoe_boss",{})
    if not _check(str(boss_cue.get("action","")) == "attack" and
            area_view.aoe_warning_geometry().size() == 1,
            "actual boss AoE telegraph failed to animate the caster"):
        return
    var boss_start := float(boss_cue.get("started",-1.0))
    area_view._frame_clock += 0.21
    area_battle.now = float(area_battle.pending_casts[0]["ready"])
    area_battle._release_casts()
    area_view.refresh_from_authority()
    var boss_resolved: Dictionary = area_view._action_cues.get("c4_aoe_boss",{})
    if not _check(is_equal_approx(float(boss_resolved.get("started",-1.0)),
            boss_start),
            "settled area_slam restarted boss attack after real AoE release"):
        return
    area_view.queue_free()
    # Verify the actual C4 6v5 scene launches with the intended configuration,
    # not just a synthetic mini battle or a headless process that exits zero.
    var pilot_scene := load("res://scenes/p3/combat_v4_jx_pilot.tscn") as PackedScene
    if not _check(pilot_scene != null,"C4 6v5 pilot scene cannot be loaded"):
        return
    var pilot := pilot_scene.instantiate()
    if not _check(pilot != null,"C4 6v5 pilot scene cannot be instantiated"):
        return
    get_root().add_child(pilot)
    # PackedScene.instantiate() is statically Node, so read typed script
    # properties through Object.get() rather than unresolved Node members.
    var pilot_battle := pilot.get("battle") as MapBattleV2
    var pilot_layer := pilot.get("layer") as MapBattleWorldLayerV2
    if not _check(pilot_battle != null and pilot_layer != null,
            "C4 pilot _ready failed to build a real V2 battle + view"):
        return
    if not _check(pilot_layer.enable_spectator_framing,
            "real JX 6v5 pilot must enable its view-only fight camera"):
        return
    # The framing camera derives its goal from *real* V2 fighter positions;
    # it must not mutate any authority or invent physical spacing.
    var camera_authority: Dictionary = pilot_battle.actors.duplicate(true)
    var camera_events: Array = pilot_battle.events.duplicate(true)
    var camera_rng: int = pilot_battle.rng.snapshot_seed_state()
    var camera_now: float = pilot_battle.now
    var goal: Dictionary = pilot_layer.spectator_camera_goal()
    # The owner opted for unzoomed 1.0x JX-style overview in
    # combat_v4_jx_pilot.gd. The former zoom>1 assertion was inherited
    # from an earlier experimental magnified camera and is obsolete.
    # Verify actual living actor midpoint and the currently authored cap,
    # rather than silently changing the user's 1x presentation setting.
    var low := Vector2(INF,INF)
    var high := Vector2(-INF,-INF)
    for live_actor in pilot_battle.actors.values():
        if float(live_actor.get("hp",0.0)) <= 0.0:
            continue
        var at: Vector2 = live_actor["position"]
        low = Vector2(minf(low.x,at.x),minf(low.y,at.y))
        high = Vector2(maxf(high.x,at.x),maxf(high.y,at.y))
    var correct_center := (low+high)*0.5
    if not _check(is_equal_approx(float(goal["zoom"]),1.0)
            and (goal["center"] as Vector2).distance_to(correct_center)<0.001,
            "pilot 1x camera goal deviated from authentic 6v5 actor bounds"):
        return
    for _frame_no in range(100):
        pilot_layer._process(1.0/60.0)
    if not _check(is_equal_approx(pilot_layer.spectator_zoom(),1.0),
            "1x owner pilot unexpectedly zoomed/magnified actors"):
        return
    for live_actor in pilot_battle.actors.values():
        var position: Vector2 = live_actor["position"]
        var screen: Vector2 = pilot_layer.point_on_map(position)
        if not _check(pilot_layer.logical_from_map(screen).distance_to(position) < 0.001,
                "pilot camera broke forward/inverse world coordinate projection"):
            return
    if not _check(pilot_battle.now == camera_now and
            pilot_battle.actors == camera_authority and
            pilot_battle.events == camera_events and
            pilot_battle.rng.snapshot_seed_state() == camera_rng,
            "presentation camera mutated Combat V2 authority"):
        return
    var counted_disciples := 0
    var counted_monsters := 0
    for actor_value in pilot_battle.actors.values():
        var actor: Dictionary = actor_value
        if str(actor.get("side","")) == "disciple":
            counted_disciples += 1
        elif str(actor.get("side","")) == "monster":
            counted_monsters += 1
    if not _check(counted_disciples == 6 and counted_monsters == 5 and
            pilot_layer.enable_source_vl_art and pilot_layer.draw_pilot_ground and
            pilot_layer._view_next.size() == 11,
            "C4 scene is not the real 6-disciple / 5-monster PRES-01 pilot"):
        return
    pilot.queue_free()
    layer.queue_free()
    print("C4 PRES-01 VIEW MOTION READABILITY: PASS")
    quit(0)
