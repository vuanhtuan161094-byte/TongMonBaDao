extends SceneTree

# Source-provenanced C4 JX1 clips are presentation-only. This test requires
# actual Godot 4.7.2 import (WebP decoding and atlas frame-region cropping).
func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> bool:
    if not ok:
        push_error("C4 JX1 RANK FX SOURCE: "+message)
        quit(1)
    return ok

func _run() -> void:
    var atlas := CombatV4EffectAtlas.new()
    var refs := {
        "jx_wudang_158_impact":{"frames":8,"ms":40,"image_width":1006},
        "jx_wudu_63_impact":{"frames":13,"ms":56,"image_width":588},
        "jx_emei_93_precast":{"frames":5,"ms":60,"image_width":456}
    }
    for kind in refs:
        var spec: Dictionary = refs[kind]
        var duration: float = atlas.duration(kind)
        if not _check(absf(duration-float(spec["frames"])*float(spec["ms"])*0.001) < 0.00001,
                "wrong source-frame clock for "+kind):
            return
        var first: Dictionary = atlas.frame_region(kind,0.0)
        var last: Dictionary = atlas.frame_region(
            kind,(float(spec["frames"])-0.5)*float(spec["ms"])*0.001)
        if not _check(not first.is_empty() and not last.is_empty() and
                (first["texture"] as Texture2D).get_width() == int(spec["image_width"]),
                "imported JX source sheet missing or invalid atlas rect: "+kind):
            return
        if not _check(atlas.frame_region(kind,duration).is_empty() and
                atlas.frame_region(kind,-0.5).is_empty(),
                "finite JX animation continued beyond original frames: "+kind):
            return
    if not _check(atlas.frame_region("jx_shaolin_15_impact",0.0).is_empty() and
            atlas.frame_region("jx_wudang_159_impact",0.0).is_empty(),
            "unsourced #15/#159 FX must not be substituted"):
        return

    var template: Dictionary = CombatStatsV2.derive(2,1,2,1,0.0)
    if not _check(bool(template.get("ok",false)),"model fixture"):
        return
    var hero := {"id":"disc","party_id":"team","role":"mage",
        "position":Vector2(6.0,9.0),
        "hp":float(template["stats"]["max_hp"]),"stats":template["stats"]}
    var wolf: Dictionary = MonsterCatalogueV2.create_actor("thanh_lang",2,1,"monster")
    if not _check(bool(wolf.get("ok",false)),"monster fixture"):
        return
    wolf["id"] = "wolf"
    wolf["position"] = Vector2(8.0,9.0)
    var battle := MapBattleV2.new(15193)
    if not _check(bool(battle.setup("jx_fx_receipt_test",[hero],[wolf]).get("ok",false)),
            "battle setup"):
        return
    var layer := MapBattleWorldLayerV2.new()
    layer.enable_source_vl_art = true
    get_root().add_child(layer)
    layer.attach_session(battle)
    var original_actors: Dictionary = battle.actors.duplicate(true)
    var original_rng := battle.rng.snapshot_seed_state()
    var original_now := battle.now
    # Source event handlers only, without letting the renderer calculate
    # a hit or apply healing/poison.
    battle._event("pilot_cast",{"caster":"disc","target":"wolf",
        "pilot_id":"jx_emei_93","release_at":0.5})
    layer.refresh_from_authority()
    if not _check(layer._effect_cues.size() == 1 and
            str(layer._effect_cues[0]["kind"]) == "jx_emei_93_precast",
            "authentic #93 cast not mapped"):
        return
    battle._event("pilot_impact",{"caster":"disc","target":"wolf",
        "pilot_id":"jx_wudang_158","effective_damage":5.0})
    layer.refresh_from_authority()
    if not _check(layer._effect_cues.size() == 2 and
            str(layer._effect_cues[1]["kind"]) == "jx_wudang_158_impact",
            "authentic #158 impact not mapped"):
        return
    battle._event("pilot_impact",{"caster":"disc","target":"wolf",
        "pilot_id":"jx_wudu_63","effective_damage":2.0})
    battle._event("pilot_impact",{"caster":"disc","target":"wolf",
        "pilot_id":"jx_wudu_63","effective_damage":0.0})
    layer.refresh_from_authority()
    if not _check(layer._effect_cues.size() == 3 and
            str(layer._effect_cues[2]["kind"]) == "jx_wudu_63_impact",
            "#63 positive impact missing or zero-damage false impact rendered"):
        return
    layer.refresh_from_authority()
    if not _check(layer._effect_cues.size() == 3,
            "repeated refresh duplicated JX FX"):
        return
    if not _check(battle.actors == original_actors and
            battle.rng.snapshot_seed_state() == original_rng and
            battle.now == original_now,
            "JX presentation changed HP/positions/RNG/timing"):
        return
    layer.queue_free()
    print("C4 JX1 RANK FX SOURCE: PASS")
    quit(0)
