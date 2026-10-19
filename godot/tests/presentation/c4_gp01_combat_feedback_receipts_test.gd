extends SceneTree

# C4-GP01: numeric combat feedback observes final authoritative HP receipts,
# never computes damage or changes V2 accuracy, dodge, RNG, HP or cooldown.
func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, reason: String) -> bool:
    if not ok:
        push_error("C4 GP01 COMBAT FEEDBACK: "+reason)
        quit(1)
    return ok

func _run() -> void:
    var base: Dictionary = CombatStatsV2.derive(2,1,2,1,0.0)
    if not _check(bool(base.get("ok",false)),"stats fixture"):
        return
    var stats: Dictionary = base["stats"].duplicate(true)
    stats["crit_chance"] = 1.0 # Test-only deterministic crit: not game balance.
    var member := {"id":"a_gp01_member","party_id":"gp01",
        "role":"frontline","position":Vector2(6.0,9.0),"stats":stats,
        "hp":float(stats["max_hp"])}
    var wolf: Dictionary = MonsterCatalogueV2.create_actor("thanh_lang",1,1,"z_gp01_wolf")
    if not _check(bool(wolf.get("ok",false)),"wolf fixture"):
        return
    wolf["id"] = "z_gp01_wolf"
    wolf["position"] = Vector2(7.0,9.0)
    var battle := MapBattleV2.new(411901)
    if not _check(bool(battle.setup("gp01_receipts",[member],[wolf]).get("ok",false)),
            "battle setup failed"):
        return
    var layer := MapBattleWorldLayerV2.new()
    layer.enable_source_vl_art = true
    get_root().add_child(layer)
    layer.attach_session(battle)
    battle.step(true)
    var hit_count := 0
    var crit_count := 0
    for event_value in battle.events:
        var e: Dictionary = event_value
        if str(e.get("type","")) == "hit" and float(e.get("damage",0.0)) > 0.0:
            hit_count += 1
            if bool(e.get("critical",false)):
                crit_count += 1
    if not _check(hit_count > 0 and crit_count > 0,
            "genuine MapBattleV2 crit hit not produced"):
        return
    # ALL source-backed hits are integer glyphs, including sub-10 amounts.
    if not _check(layer._combat_amount(9.625) == "10" and
            layer._combat_amount(1.25) == "1" and
            layer._combat_amount(125.4) == "125",
            "classic JX damage feedback must never display decimals"):
        return
    var canonical_wolf: Dictionary = battle.actors["z_gp01_wolf"]
    if not _check(layer.combat_actor_label(canonical_wolf) == "Thanh Lang",
            "monster HUD did not use canonical species name"):
        return
    if not _check(layer.combat_actor_label({
            "side":"disciple","name":"Đệ tử thử","id":"fixture"
        }) == "Đệ tử thử",
            "source-provided actor name ignored"):
        return
    layer.enable_spectator_framing = true
    layer.spectator_zoom_ceiling = 1.0
    if not _check(is_equal_approx(float(layer.spectator_camera_goal()["zoom"]),1.0),
            "classic overview zoom still magnifies overlapping actors"):
        return
    # Combat V2 snapshots deliberately omit input realm information. The
    # presentation adapter reads only the original source values; it must
    # not estimate a realm from monster HP/ATK.
    if not _check(layer.combat_actor_rank_label(battle.actors["z_gp01_wolf"]) == "",
            "renderer invented a level from monster strength"):
        return
    layer.set_actor_view_metadata({
        "a_gp01_member":{"realm_index":2,"floor_index":1,
            "body_realm_index":3,"body_floor_index":3},
        "z_gp01_wolf":{"realm_index":2,"floor_index":1},
        "unknown_id":{"realm_index":30,"floor_index":10}
    })
    if not _check(layer.combat_actor_rank_label(battle.actors["z_gp01_wolf"]) ==
            "Luyện Khí · Tầng 1" and
            layer.combat_actor_rank_label(battle.actors["a_gp01_member"]) ==
            "Luyện Khí · Tầng 1" and
            layer.combat_actor_body_label(battle.actors["a_gp01_member"]) ==
            "Dịch Cân · Tầng 3",
            "rank UI failed to read exact 30x10 canonical realms"):
        return
    if not _check(not layer._actor_view_metadata.has("unknown_id"),
            "ghost actor rank metadata not rejected"):
        return
    var before_bad: Dictionary = layer._actor_view_metadata.duplicate(true)
    layer.set_actor_view_metadata({"z_gp01_wolf":{"realm_index":0,"floor_index":11}})
    if not _check(layer.combat_actor_rank_label(battle.actors["z_gp01_wolf"]) == "" and
            layer._actor_view_metadata.is_empty(),
            "invalid monster level shown instead of blank"):
        return
    layer.set_actor_view_metadata(before_bad)
    # Evidence-backed JX UI strip: present in the isolated import and with
    # readable texture dimensions. Missing asset should fail focused QA.
    if not _check(MapBattleWorldLayerV2.JX_HP_STRIP != null and
            MapBattleWorldLayerV2.JX_HP_STRIP.get_width() == 106 and
            MapBattleWorldLayerV2.JX_HP_STRIP.get_height() == 11,
            "missing or incorrect owner JX HP strip"):
        return
    var original_actors: Dictionary = battle.actors.duplicate(true)
    var original_rng: int = battle.rng.snapshot_seed_state()
    var original_now: float = battle.now
    var original_events: Array = battle.events.duplicate(true)
    layer.refresh_from_authority()
    var popup_hits := 0
    var popup_crits := 0
    for value in layer._combat_text:
        var popup: Dictionary = value
        if str(popup.get("category","")) in ["crit","damage"]:
            popup_hits += 1
        if str(popup.get("category","")) == "crit":
            popup_crits += 1
    if not _check(popup_hits == hit_count and popup_crits == crit_count,
            "committed V2 hit/crit receipts not exactly one popup each"):
        return
    var first_size := layer._combat_text.size()
    layer.refresh_from_authority()
    if not _check(layer._combat_text.size() == first_size,
            "refresh twice replayed already consumed HP events"):
        return
    if not _check(battle.actors == original_actors and
            battle.rng.snapshot_seed_state() == original_rng and
            battle.events == original_events and battle.now == original_now,
            "rendering combat feedback mutated V2 HP, RNG, events or time"):
        return

    # The legacy JX pilot impact/skill_hit announce releases and may follow
    # a hit. These events never produce a *second* numeric damage popup.
    var before := layer._combat_text.size()
    battle._event("pilot_impact",{"caster":"a_gp01_member",
        "target":"z_gp01_wolf","effective_damage":9999.0})
    battle._event("skill_hit",{"caster":"a_gp01_member","target":"z_gp01_wolf"})
    layer.refresh_from_authority()
    if not _check(layer._combat_text.size() == before,
            "pilot impact or skill-hit duplicated canonical HP popup"):
        return

    # Receipt display accepts exact healing, leech and poison; zero amounts
    # never show. Synthetic events here test the view contract only.
    battle._event("heal",{"target":"a_gp01_member","amount":31.0})
    battle._event("pilot_hot_tick",{"target":"a_gp01_member","amount":12.0})
    battle._event("pilot_poison_tick",{"target":"z_gp01_wolf","damage":8.0})
    battle._event("pilot_poison_tick",{"target":"z_gp01_wolf","damage":0.0})
    battle._event("hit",{"attacker":"a_gp01_member","target":"z_gp01_wolf",
        "damage":5.0,"critical":false,"lifesteal":3.0,"kind":"basic"})
    layer.refresh_from_authority()
    var counts := {"heal":0,"poison":0,"lifesteal":0,"damage":0}
    for value in layer._combat_text:
        var popup: Dictionary = value
        var kind := str(popup.get("category",""))
        if counts.has(kind):
            counts[kind] = int(counts[kind])+1
        var glyph := str(popup.get("label",""))
        if not _check(not glyph.contains("."),
                "numeric combat label unexpectedly contains a decimal"):
            return
        if kind == "heal" and not _check(float(popup["amount"]) > 0.0,
                "fake zero healing popup"):
            return
    if not _check(int(counts["heal"]) == 2 and
            int(counts["poison"]) == 1 and
            int(counts["lifesteal"]) == 1 and
            int(counts["damage"]) == hit_count-crit_count+1,
            "not matching real event-specific numeric categories"):
        return
    if not _check(layer._combat_text.size() <= MapBattleWorldLayerV2.MAX_VISIBLE_COMBAT_TEXT,
            "numerical render overdraw cap not enforced"):
        return

    # GP02: HUD priority is independent of the source actor draw order.
    # The HP stays near the true feet even when a name/status starts atop it.
    var hud_input: Array[Dictionary] = [
        {"kind":"name","rect":Rect2(Vector2(220.0,165.0),Vector2(84.0,15.0))},
        {"kind":"status","rect":Rect2(Vector2(225.0,164.0),Vector2(48.0,19.0))},
        {"kind":"hp","rect":Rect2(Vector2(232.0,171.0),Vector2(48.0,6.0))}
    ]
    var original_hud: Array[Dictionary] = hud_input.duplicate(true)
    var hud_output: Array[Dictionary] = layer.layout_hp_overlays(hud_input)
    if not _check(hud_output.size() == 3 and
            hud_output[2]["rect"] == hud_input[2]["rect"],
            "HP must take priority over coincident name/status labels"):
        return
    if not _check(hud_input == original_hud and
            layer.layout_hp_overlays(hud_input) == hud_output,
            "HUD placement changed input or is not deterministic"):
        return
    for i in range(hud_output.size()):
        var first: Rect2 = hud_output[i]["rect"]
        if not _check(layer.stage_rect.grow(-4.0).encloses(first),
                "HUD escaped its stage after priority sorting"):
            return
        for j in range(i):
            if not _check(not first.grow(3.0).intersects(
                    (hud_output[j]["rect"] as Rect2).grow(3.0)),
                    "HP/name/status overlap despite available free space"):
                return

    # A receipt remembers its observed impact foot. Later actor movement and
    # renderer interpolation cannot drag a flying damage number with the wolf.
    var burst := MapBattleWorldLayerV2.new()
    burst.enable_source_vl_art = true
    burst.attach_session(battle)
    burst._enqueue_combat_text("z_gp01_wolf",3.25,"damage",92001)
    if not _check(burst._combat_text.size() == 1 and
            str(burst._combat_text[0]["label"]) == "3",
            "integer small damage not ingested"):
        return
    var frozen: Vector2 = burst._combat_text[0]["world_origin"]
    burst._view_prev["z_gp01_wolf"] = Vector2(25.0,13.0)
    burst._view_next["z_gp01_wolf"] = Vector2(28.0,14.0)
    if not _check(burst._combat_text[0]["world_origin"] == frozen and
            burst.point_on_map(frozen) == burst.point_on_map(
                burst._combat_text[0]["world_origin"]),
            "moving actor displaced an existing event popup"):
        return

    # When all 28 popups are real crits, basic hits do not throw away crit
    # context. A new healing receipt may displace only the oldest protected
    # popup. The V2 events themselves remain unchanged.
    burst._combat_text.clear()
    for n in range(MapBattleWorldLayerV2.MAX_VISIBLE_COMBAT_TEXT):
        burst._enqueue_combat_text("z_gp01_wolf",1.0,"crit",100000+n)
    burst._enqueue_combat_text("z_gp01_wolf",2.0,"damage",200000)
    var protected_count := 0
    for item_value in burst._combat_text:
        if str(item_value.get("category","")) == "crit":
            protected_count += 1
    if not _check(protected_count == MapBattleWorldLayerV2.MAX_VISIBLE_COMBAT_TEXT,
            "ordinary damage evicted a protected critical receipt"):
        return
    burst._enqueue_combat_text("a_gp01_member",2.0,"heal",200001)
    var protected_heals := 0
    for item_value in burst._combat_text:
        if str(item_value.get("category","")) == "heal":
            protected_heals += 1
    if not _check(burst._combat_text.size() == MapBattleWorldLayerV2.MAX_VISIBLE_COMBAT_TEXT and
            protected_heals == 1,
            "new healing must remain visible without exceeding popup cap"):
        return
    burst._combat_text.clear()

    var subject: Dictionary = (battle.actors["z_gp01_wolf"] as Dictionary).duplicate(true)
    subject["pilot_effects"] = [
        {"kind":"poison","ticks_left":3},
        {"kind":"poison","ticks_left":1},
        {"kind":"hot","ticks_left":2}]
    subject["pilot_guard_until"] = battle.now+1.0
    subject["pilot_def_until"] = battle.now+1.0
    var statuses: Array[String] = layer.active_combat_status_tags(subject)
    if not _check(statuses == ["DOC2","HOI","THU","TRAN"],
            "active statuses do not reflect real stacks, HoT and guard/def timers"):
        return
    subject["pilot_effects"] = []
    subject["pilot_guard_until"] = battle.now
    subject["pilot_def_until"] = battle.now
    if not _check(layer.active_combat_status_tags(subject).is_empty(),
            "expired status did not disappear from authority view"):
        return
    layer._frame_clock += layer.COMBAT_TEXT_SECONDS+0.1
    layer._process(0.0)
    if not _check(layer._combat_text.is_empty(),
            "numeric popups did not expire without a new battle tick"):
        return
    layer.queue_free()
    print("C4 GP01 COMBAT FEEDBACK RECEIPTS: PASS")
    quit(0)
