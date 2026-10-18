extends Control

# Manual VISUAL PILOT. Launch res://scenes/p3/combat_v4_pilot.tscn in Godot 4.7.2.
# Real MapBattleV2 simulation and skill-hit authority, seeded fixture party only.
# No recruitment, inventory, loot, scheduler, save, injury or PR20 mutations.
const SEED := 41726
var battle: MapBattleV2
var layer: MapBattleWorldLayerV2
var summary_label: Label
var help_label: Label
var is_paused: bool = false
var elapsed_buffer: float = 0.0

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var background := ColorRect.new()
    background.color = Color(0.055,0.085,0.079,1.0)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(background)
    layer = MapBattleWorldLayerV2.new()
    layer.enable_source_vl_art = true
    layer.draw_pilot_ground = true
    add_child(layer)
    var title_label := Label.new()
    title_label.text = "THANH TRUC LAM   /   COMBAT V4 VISUAL PILOT"
    title_label.position = Vector2(90.0,9.0)
    title_label.size = Vector2(800.0,26.0)
    title_label.add_theme_font_size_override("font_size",19)
    title_label.add_theme_color_override("font_color",Color(0.95,0.89,0.68))
    add_child(title_label)
    summary_label = Label.new()
    summary_label.position = Vector2(90.0,657.0)
    summary_label.size = Vector2(1000.0,25.0)
    summary_label.add_theme_font_size_override("font_size",17)
    summary_label.add_theme_color_override("font_color",Color(0.92,0.96,0.88))
    add_child(summary_label)
    help_label = Label.new()
    help_label.text = "TECH PILOT: 6 vs 5 / REAL V2 damage, AI, cooldown, AoE and boss telegraph / No save or rewards / Wolf used as provisional boss art"
    help_label.position = Vector2(90.0,685.0)
    help_label.size = Vector2(1100.0,28.0)
    help_label.add_theme_font_size_override("font_size",12)
    help_label.add_theme_color_override("font_color",Color(0.70,0.76,0.71))
    add_child(help_label)
    var replay := Button.new()
    replay.text = "CHƠI LẠI"
    replay.position = Vector2(1065.0,8.0)
    replay.size = Vector2(124.0,38.0)
    replay.pressed.connect(_begin_battle)
    add_child(replay)
    _begin_battle()

func _begin_battle() -> void:
    battle = MapBattleV2.new(SEED)
    var party: Array = []
    var roles := ["frontline","ranged","mage","healer","ranged","frontline"]
    for i in range(6):
        var model: Dictionary = CombatStatsV2.derive(2,1,2,1,0.0)
        if not bool(model.get("ok",false)):
            push_error("Combat V4 pilot: invalid V2 stats")
            return
        var stats: Dictionary = model["stats"]
        var hp: float = float(stats["max_hp"]) * (0.52 if i == 0 else 1.0)
        var actor := {
            "id":"pilot_disciple_%02d" % i, "party_id":"pilot_party",
            "stats":stats, "resistances":model.get("resistances",{}),
            "role":roles[i], "position":Vector2(6.0+float(i%3)*1.2,8.0+float(i/3)*1.4),
            "hp":hp,
            # This test loadout is a fixture and does NOT grant real disciples new knowledge.
            "skill_loadout":["ngu_kiem_thuat","thanh_phong_tram"] if i in [1,4] else []
        }
        party.append(actor)
    var monsters: Array = []
    var ids := ["thanh_lang","thanh_lang","hac_lang","thanh_lang","hac_lang_vuong"]
    for i in range(ids.size()):
        var creature: Dictionary = MonsterCatalogueV2.create_actor(ids[i],1,1,"pilot_monster_%02d" % i)
        if not bool(creature.get("ok",false)):
            push_error("Combat V4 pilot: invalid monster " + ids[i])
            return
        creature["id"] = "pilot_monster_%02d" % i
        creature["position"] = Vector2(23.0+float(i%3)*1.1,8.0+float(i/3)*1.45)
        monsters.append(creature)
    var started: Dictionary = battle.setup("combat_v4_sourcevl_pilot",party,monsters)
    if not bool(started.get("ok",false)):
        push_error("Combat V4 pilot start failed: " + str(started))
        return
    elapsed_buffer = 0.0
    is_paused = false
    layer.attach_session(battle)
    _update_summary()

func _process(delta: float) -> void:
    if battle == null or not battle.active or is_paused:
        return
    elapsed_buffer = minf(0.5,elapsed_buffer+delta)
    while elapsed_buffer >= MapBattleV2.STEP_SECONDS and battle.active:
        elapsed_buffer -= MapBattleV2.STEP_SECONDS
        battle.step(true)
        layer.refresh_from_authority()
    _update_summary()

func _update_summary() -> void:
    if battle == null:
        return
    var snap: Dictionary = battle.summary()
    summary_label.text = "TRẬN: %s    THỜI GIAN: %.1fs    ĐỆ TỬ CÒN: %d/6    QUÁI CÒN: %d/5    ĐÒN: %d" % [
        str(snap.get("outcome","")),battle.now,
        int(snap.get("alive_disciples",0)),int(snap.get("alive_monsters",0)),int(snap.get("actions",0))
    ]
