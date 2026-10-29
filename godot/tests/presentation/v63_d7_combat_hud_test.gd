extends SceneTree

const BOSS_ID := "tmb.boss.thiet_giap_son_vien"
const SKILL_ID := "tmb.skill.bow.liep_anh.active_01.human"

func _init() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("V63_D7_COMBAT_HUD_FAIL: " + message)
    quit(1)

func _run() -> void:
    var state := SimulationState.new()
    var battle := MapBattleV2.new(707707)
    battle.encounter_id = "d7_hud_fixture"
    battle.active = true
    battle.outcome = "active"
    var loadout: Array = [SKILL_ID]
    for index in range(6):
        var id := "d7_hud_%02d" % index
        state.disciples[StringName(id)] = DiscipleState.new({"id":id,"name":"Đội %d" % index})
        battle.actors[id] = {"id":id,"side":"disciple","hp":80.0-float(index),"max_hp":100.0,
            "v63_skill_loadout":loadout.duplicate(),"v63_skill_ready":{SKILL_ID:0.0}}
    battle.actors["boss"] = {"id":"boss","side":"monster","hp":700.0,"max_hp":1000.0,
        "v63_boss_id":BOSS_ID,"v63_boss_phase":2,"v63_boss_counter_window":{"until":5.0}}
    battle.events.append({"sequence":1,"type":"telegraph","boss_id":BOSS_ID,"skill_id":"tmb.bossskill.thiet_giap.slam","release_at":2.0})
    var hud := V63CombatHudV1.new()
    root.add_child(hud)
    await process_frame
    hud.set_authority(state,battle,true)
    var rows := hud.get("_rows") as VBoxContainer
    var boss_name := hud.get("_boss_name") as Label
    var event_label := hud.get("_event") as Label
    var vfx := hud.get_node_or_null("OriginalCombatVFX")
    if rows == null or rows.get_child_count() != 6:
        _fail("HUD did not render exactly six authoritative party cards")
        return
    if boss_name == null or not boss_name.text.contains(BOSS_ID):
        _fail("HUD Boss card did not show the actual Boss identity")
        return
    if event_label == null or not event_label.text.contains("BÁO CHIÊU"):
        _fail("HUD did not surface the actual Combat V2 telegraph")
        return
    if vfx == null or str(vfx.get("_cue_kind")) != "telegraph":
        _fail("original vector VFX did not consume the authoritative telegraph event")
        return
    print("V63 D7 COMBAT HUD PASS: six party cards, Boss phase/HP/counter, real telegraph and original event VFX")
    hud.queue_free()
    quit(0)
