extends SceneTree

# Source-referenced visual behavior from public SourceInit-JX1:
# KNpc::PaintInfo 12 / selected 14px, PaintLife thin 38x3,
# PaintBlood decimal INTEGER 16px and 27-frame upward float.
# Do not import external artwork/C++ or change V2 combat mechanics.
func _init() -> void:
    call_deferred("_run")

func _check(value: bool, message: String) -> bool:
    if not value:
        push_error("C4 JX1 SOURCE HUD: "+message)
        quit(1)
    return value

func _run() -> void:
    var r: Dictionary = CombatStatsV2.derive(2,1,2,1,0.0)
    if not _check(bool(r.get("ok",false)),"missing Combat V2 stats"):
        return
    var user := {"id":"c4_disciple_00","party_id":"jx","role":"frontline",
        "stats":r["stats"],"hp":float(r["stats"]["max_hp"]),
        "position":Vector2(6.0,9.0),"pilot_skill_loadout":["jx_shaolin_15"]}
    var enemy: Dictionary = MonsterCatalogueV2.create_actor(
        "thanh_lang",1,1,"c4_monster_00")
    enemy["id"] = "c4_monster_00"
    enemy["position"] = Vector2(9.0,9.0)
    var battle := MapBattleV2.new(991721)
    if not _check(bool(battle.setup("jx1_source_hud",[user],[enemy]).get("ok",false)),
            "real battle fixture failed"):
        return
    var source: Dictionary = battle.actors.duplicate(true)
    var original_rng: int = battle.rng.snapshot_seed_state()
    var original_events: Array = battle.events.duplicate(true)
    var original_now: float = battle.now
    var view := MapBattleWorldLayerV2.new()
    view.enable_source_vl_art = true
    view.enable_jx1_hud = true
    get_root().add_child(view)
    view.attach_session(battle)
    if not _check(view.jx1_display_name(battle.actors["c4_disciple_00"]) == "Thiếu Lâm 1",
            "JX1 player school label not derived from actual pilot loadout"):
        return
    if not _check(view.jx1_display_name(battle.actors["c4_monster_00"]) == "Thanh Lang",
            "monster species name not preserved in JX1 overhead text"):
        return
    if not _check(view._combat_amount(4.6) == "5"
            and view._combat_amount(5.1) == "5"
            and view._combat_amount(19.0) == "19"
            and view._combat_amount(0.6) == "1",
            "JX1 integer damage formatting regressed to decimals"):
        return
    view._ingest_combat_feedback({"type":"hit","target":"c4_monster_00",
        "damage":41.6,"critical":true},100)
    if not _check(view._combat_text.size() == 1
            and str(view._combat_text[0]["label"]) == "CRIT 42!",
            "critical popup differs from settled integer display"):
        return
    view._ingest_combat_feedback({"type":"skill_hit","caster":"c4_disciple_00",
        "target":"c4_monster_00"},101)
    view._ingest_combat_feedback({"type":"pilot_impact","caster":"c4_disciple_00",
        "target":"c4_monster_00","effective_damage":999.0},102)
    if not _check(view._combat_text.size() == 1,
            "skill_hit or pilot_impact fabricated duplicate number"):
        return
    if not _check(is_equal_approx(view.spectator_zoom(),1.0)
            and is_equal_approx(view.JX1_FLOAT_TIME,0.62)
            and view._combat_text.size() <= view.MAX_VISIBLE_COMBAT_TEXT,
            "JX1 normal projection, lifespan, or bounded popup contract broken"):
        return
    view._frame_clock += view.JX1_FLOAT_TIME+0.01
    view._process(0.0)
    if not _check(view._combat_text.is_empty(),
            "JX1 short damage popup did not expire"):
        return
    if not _check(battle.actors == source and battle.events == original_events
            and battle.now == original_now
            and battle.rng.snapshot_seed_state() == original_rng,
            "JX1 HUD changed HP, event journal, time or RNG"):
        return
    view.queue_free()
    print("C4 JX1 SOURCE HUD REFERENCE: PASS")
    quit(0)
