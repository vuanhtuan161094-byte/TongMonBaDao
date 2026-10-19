extends "res://src/presentation/p3/combat_v4_pilot.gd"

# Pure view selection; never issues actions or modifies combat targeting.
var _selected_actor_id: String = ""

# Manual 1280x720 EP01 visual fixture; overrides only the demo line-up.
# No edits to canonical disciples, learned skills, player save or rewards.
func _ready() -> void:
    super._ready()
    # Camera frames the actual moving 6v5 world feet; V2 positions stay fixed.
    layer.enable_spectator_framing = true
    # Classic JX1 overview: original stage scale (1x), still follows real
    # living actor bounds. Do not use magnification to conceal collisions.
    layer.spectator_zoom_ceiling = 1.0
    for child in get_children():
        if child is Label and str(child.text).begins_with("THANH TRUC LAM"):
            child.text = "THANH TRUC LAM  /  C4 JX1 BỐN PHÁI — PILOT"
    summary_label.size = Vector2(1150.0,26.0)
    summary_label.add_theme_font_size_override("font_size",14)
    help_label.text = "CHẠM NHÂN VẬT/QUÁI ĐỂ XEM TU VI, LUYỆN THỂ VÀ HP | JX PILOT / COMBAT V2"

func _begin_battle() -> void:
    _selected_actor_id = ""
    battle = MapBattleV2.new(41726)
    var team: Array = []
    # Read-only nameplate/rank metadata belongs to the pilot view, NOT V2.
    var view_metadata: Dictionary = {}
    var roles := ["frontline","mage","mage","healer","ranged","frontline"]
    var kits := [
        ["jx_shaolin_15"],
        ["jx_wudang_159","jx_wudang_158"],
        ["jx_wudu_63"],
        ["jx_emei_93"],
        [],
        []
    ]
    var root_sets := [
        {"metal":80,"wood":45,"water":70,"earth":60},
        {"metal":50,"earth":86,"water":62},
        {"wood":90,"water":42},
        {"water":95,"wood":35},
        {"fire":75,"metal":40},
        {"earth":68,"metal":80}
    ]
    for i in range(6):
        var model: Dictionary = CombatStatsV2.derive(2,1,2,1,0.0)
        if not bool(model.get("ok",false)):
            push_error("C4 JX visual: invalid stat model")
            return
        var stats: Dictionary = model["stats"]
        var row := {
            "id":"c4_disciple_%02d" % i,
            "party_id":"c4_party",
            "stats":stats,
            "resistances":model.get("resistances",{}),
            "role":roles[i],
            "position":Vector2(6.0+float(i%3)*1.2,8.0+float(i/3)*1.35),
            "hp":float(stats["max_hp"])*(0.52 if i==0 else 1.0),
            "pilot_skill_loadout":kits[i],
            "spiritual_root_values":root_sets[i]
        }
        team.append(row)
        # Exact fixture realm coordinates used by CombatStatsV2.derive.
        view_metadata[str(row["id"])] = {
            "realm_index":2,"floor_index":1,
            "body_realm_index":2,"body_floor_index":1
        }
    var foes: Array = []
    var species := ["thanh_lang","thanh_lang","hac_lang","thanh_lang","hac_lang_vuong"]
    for i in range(species.size()):
        var mob := MonsterCatalogueV2.create_actor(species[i],2,1,"c4_monster_%02d" % i)
        if not bool(mob.get("ok",false)):
            push_error("C4 JX visual: invalid monster: "+str(mob))
            return
        mob["id"] = "c4_monster_%02d" % i
        mob["position"] = Vector2(23.0+float(i%3)*1.1,8.0+float(i/3)*1.4)
        foes.append(mob)
        view_metadata[str(mob["id"])] = {
            "realm_index":int(mob["realm_index"]),
            "floor_index":int(mob["floor_index"])
        }
    var start := battle.setup("c4_jx_four_schools_visual",team,foes)
    if not bool(start.get("ok",false)):
        push_error("C4 JX visual battle setup failed: "+str(start))
        return
    elapsed_buffer = 0.0
    is_paused = false
    layer.attach_session(battle)
    layer.set_actor_view_metadata(view_metadata)
    _update_summary()

func _unhandled_input(event: InputEvent) -> void:
    if layer == null or battle == null:
        return
    var position := Vector2.ZERO
    if event is InputEventScreenTouch:
        if not event.pressed:
            return
        position = event.position
    elif event is InputEventMouseButton:
        if not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
            return
        position = event.position
    else:
        return
    var picked := layer.actor_at_map_point(position,48.0)
    if not picked.is_empty():
        _selected_actor_id = picked
        _refresh_selected_info()

func _refresh_selected_info() -> void:
    if _selected_actor_id.is_empty() or battle == null or help_label == null:
        return
    if not battle.actors.has(_selected_actor_id):
        _selected_actor_id = ""
        return
    var actor: Dictionary = battle.actors[_selected_actor_id]
    var realm := layer.combat_actor_rank_label(actor)
    var body := layer.combat_actor_body_label(actor)
    help_label.text = "%s | Tu Vi: %s | Luyện Thể: %s | HP: %d/%d" % [
        layer.combat_actor_label(actor),realm if not realm.is_empty() else "chưa có dữ liệu",
        body if not body.is_empty() else "chưa có dữ liệu",
        int(roundf(float(actor.get("hp",0.0)))),
        int(roundf(float(actor.get("max_hp",0.0))))
    ]

func _update_summary() -> void:
    if battle == null:
        return
    var data := battle.summary()
    var stats := {"pilot_cast":0,"pilot_impact":0,"pilot_poison_tick":0,"pilot_hot_tick":0}
    for ev in battle.events:
        var key := str(ev.get("type",""))
        if stats.has(key):
            stats[key] = int(stats[key])+1
    summary_label.text = "C4: %s  %.1fs  ĐỆ TỬ %d/6  QUÁI %d/5  CAST %d  HIT %d  ĐỘC %d  HỒI %d" % [
        str(data["outcome"]).to_upper(),float(data["time"]),
        int(data["alive_disciples"]),int(data["alive_monsters"]),
        int(stats["pilot_cast"]),int(stats["pilot_impact"]),
        int(stats["pilot_poison_tick"]),int(stats["pilot_hot_tick"])
    ]
    _refresh_selected_info()
