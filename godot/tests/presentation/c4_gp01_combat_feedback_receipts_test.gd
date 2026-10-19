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
