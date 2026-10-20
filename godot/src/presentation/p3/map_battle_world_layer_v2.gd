class_name MapBattleWorldLayerV2
extends Node2D

# DV2-02D region-map VIEW ADAPTER. NEVER advances battle simulation.
# Draws actor coordinates/HP/boss warning zones from MapBattleV2 snapshot.
# Minimal visual fallback only; production sprites/art and map tiles are later assets.
const DISCIPLE_FILL := Color(0.24,0.62,0.47,1.0)
const ENEMY_FILL := Color(0.68,0.28,0.23,1.0)
const ELITE_FILL := Color(0.75,0.45,0.16,1.0)
const BOSS_FILL := Color(0.58,0.23,0.46,1.0)
const BORDER := Color(0.13,0.15,0.12,0.88)
const HP_BG := Color(0.16,0.20,0.18,0.86)
const HP_GOOD := Color(0.36,0.83,0.45,1.0)
const HP_ENEMY := Color(0.91,0.39,0.35,1.0)
const WARNING := Color(0.92,0.28,0.20,0.32)
const GRID_SIZE := Vector2(36.0,20.0)
# Owner-supplied Võ Lâm Idle HP strip; keep raw PNG and provenance in repo.
const JX_HP_STRIP: Texture2D = preload("res://assets/combat_v4/jx1_ui/bar_hp.png")
# Verified and already imported Source A environment art (not borrowed JX binary).
const FOREST_A: Texture2D = preload("res://art/source_a_env02a/env01_assets/vegetation/570036.png")
const FOREST_B: Texture2D = preload("res://art/source_a_env02a/env01_assets/vegetation/570041.png")
const FOREST_C: Texture2D = preload("res://art/source_a_env02a/env01_assets/vegetation/570073.png")
# Private JX1-inspired source supplied by owner from Drive jx-idle-main/img/z.
# Owner-authorized JX map JPEG is staged from Drive in the isolated TEMP
# clone; the runtime load path is an import choice, not a rights restriction.
const JX_PRIVATE_BACKDROP := "res://art/jx1_private/img/z/2.jpg"

var battle: MapBattleV2
var stage_rect := Rect2(Vector2(90.0,50.0),Vector2(1100.0,600.0))
var displayed_at: float = 0.0

# Opt-in source-backed V4 view for isolated pilot; normal map retains original circles.
var enable_source_vl_art: bool = false
var draw_pilot_ground: bool = false
var _source_atlas := CombatV4SpriteAtlas.new()
var _jx_private_ground: Texture2D
var _jx_private_ground_checked := false
var _frame_clock: float = 0.0
var _event_cursor: int = 0
var _facing: Dictionary = {}
var _positions: Dictionary = {}
# PRES-01 view-only position samples: an explicit 250ms render delay.
# Every endpoint is a REAL authoritative position; never extrapolate movement.
var _view_prev: Dictionary = {}
var _view_next: Dictionary = {}
var _view_elapsed: float = MapBattleV2.STEP_SECONDS
var _last_move: Dictionary = {}
var _action_cues: Dictionary = {}
var _impact_cues: Dictionary = {}
var _effect_atlas := CombatV4EffectAtlas.new()
var _effect_cues: Array[Dictionary] = []
var _status_feedback: Dictionary = {} # only actual event feedback, not status authority
# PRES-01 visual-only adaptive framing, opt-in for the 6v5 JX pilot.
# Does NOT move any fighter or affect V2 world coordinates / hit selection.
var enable_spectator_framing: bool = false
var _camera_center := GRID_SIZE*0.5
var _camera_zoom: float = 1.0
# Camera is presentation-only. Default FREE overview stays where the player
# panned. Following a single actor requires an explicit click/tap.
var _camera_follow_id: String = ""
var _camera_free: bool = true

# The battle pilot can opt for JX1-like original-size overview without
# changing world positions or the generic zoomable spectator test view.
var spectator_zoom_ceiling: float = 2.10
# Hunting screen may offer a user-facing visual zoom multiplier; classic C4
# pilot remains 1.0 so its historical deterministic camera test is unchanged.
var spectator_zoom_multiplier: float = 1.0
const MIN_VIEW_ZOOM := 0.70
const MAX_VIEW_ZOOM := 2.25
# Cosmetic-only overdraw budget: dropping FX never drops damage/cast events.
const MAX_VISIBLE_SOURCE_FX := 12
# GP01 is strictly presentational: the authority emits final damage/crit/heal
# receipts. Never calculate hits or derive a dodge outcome from animations.
const MAX_VISIBLE_COMBAT_TEXT := 28
const COMBAT_TEXT_SECONDS := 0.80
var enable_combat_text: bool = true
var combat_text_detail: String = "standard" # minimal | standard | detailed
var _combat_text: Array[Dictionary] = []
# View-owned metadata does not enter MapBattleV2 actor/RNG/event snapshots.
# Required for monster realm data stripped by MapBattleV2.setup.
var _actor_view_metadata: Dictionary = {}

# Format ONLY an already-settled amount. No damage computation occurs here.
func _combat_amount(amount: float) -> String:
    # Classic JX-style floating values are integer-only, including small hits.
    # The receipt's original float stays untouched in _combat_text["amount"].
    return str(int(roundf(amount)))

func _enqueue_combat_text(actor_id: String, amount: float, category: String,
        event_id: int) -> void:
    if not enable_source_vl_art or not enable_combat_text or battle == null:
        return
    if amount <= 0.0 or is_nan(amount) or is_inf(amount) or not battle.actors.has(actor_id):
        return
    if combat_text_detail == "minimal" and category not in ["crit","heal"]:
        return
    var label := _combat_amount(amount)
    if category == "crit":
        label = "CRIT " + label + "!"
    elif category == "heal":
        label = "+" + label
    elif category == "poison":
        label = "DOC " + label
    elif category == "lifesteal":
        label = "+" + label
    # The global V2 event index is a stable receipt; pilot_impact / skill_hit
    # are *not* separate damage events, so one damage commit has one popup.
    for item in _combat_text:
        if int(item.get("event_id",-1)) == event_id and str(item.get("category","")) == category:
            return
    if _combat_text.size() >= MAX_VISIBLE_COMBAT_TEXT:
        # Ordinary numbers cannot evict an entire screen of genuine
        # critical/healing receipts. The cap only limits DRAW feedback.
        var discard := -1
        for i in range(_combat_text.size()):
            if str(_combat_text[i].get("category","")) not in ["crit","heal","lifesteal"]:
                discard = i
                break
        if discard < 0:
            if category not in ["crit","heal","lifesteal"]:
                return
            discard = 0 # all important: retire the oldest one
        _combat_text.remove_at(discard)
    # Sample visible feet once at receipt ingestion: a moving actor does not
    # carry already-rendered damage numbers across the map. The logical
    # coordinate is reprojected if the presentation camera pans later.
    var receipt_foot: Vector2 = visual_position(
        actor_id,battle.actors[actor_id]["position"])
    _combat_text.append({
        "actor_id":actor_id, "amount":amount, "category":category,
        "label":label, "event_id":event_id,"started":_frame_clock,
        "world_origin":receipt_foot
    })

func _ingest_combat_feedback(event: Dictionary, event_id: int) -> void:
    var kind := str(event.get("type",""))
    if kind == "hit":
        var target := str(event.get("target",""))
        var damage := float(event.get("damage",0.0))
        _enqueue_combat_text(target,damage,
            "crit" if bool(event.get("critical",false)) else "damage",event_id)
        var leech := float(event.get("lifesteal",0.0))
        if leech > 0.0:
            _enqueue_combat_text(str(event.get("attacker","")),leech,"lifesteal",event_id)
    elif kind in ["heal","pilot_hot_tick"]:
        _enqueue_combat_text(str(event.get("target","")),
            float(event.get("amount",0.0)),"heal",event_id)
    elif kind == "pilot_poison_tick":
        _enqueue_combat_text(str(event.get("target","")),
            float(event.get("damage",0.0)),"poison",event_id)

# Read real V2 status ownership at the current simulation timestamp.
# Labels disappear when the authoritative effect ends, even if rendering lags.
func active_combat_status_tags(actor: Dictionary) -> Array[String]:
    var tags: Array[String] = []
    var poison_count := 0
    var has_hot := false
    for entry in actor.get("pilot_effects",[]):
        var effect: Dictionary = entry
        if int(effect.get("ticks_left",0)) <= 0:
            continue
        if str(effect.get("kind","")) == "poison":
            poison_count += 1
        elif str(effect.get("kind","")) == "hot":
            has_hot = true
    if poison_count > 0:
        tags.append("DOC" + (str(poison_count) if poison_count > 1 else ""))
    if has_hot:
        tags.append("HOI")
    if battle != null:
        if battle.now < float(actor.get("pilot_guard_until",-1.0)) or battle.now < float(actor.get("guard_until",-1.0)):
            tags.append("THU")
        if battle.now < float(actor.get("pilot_def_until",-1.0)):
            tags.append("TRAN")
    return tags

func _combat_feedback_color(category: String) -> Color:
    match category:
        "crit":
            return Color(1.0,0.75,0.26,1.0)
        "heal","lifesteal":
            return Color(0.48,0.99,0.64,1.0)
        "poison":
            return Color(0.83,0.58,1.0,1.0)
        _:
            return Color(1.0,0.43,0.30,1.0)

func _queue_source_fx(kind: String, position: Vector2, actor_id: String = "") -> void:
    if _effect_cues.size() >= MAX_VISIBLE_SOURCE_FX:
        if kind == "sword_cast":
            return # prioritize resolved contacts over redundant cast overlays
        var discard := 0
        for i in range(_effect_cues.size()):
            if str(_effect_cues[i].get("kind","")) == "sword_cast":
                discard = i
                break
        _effect_cues.remove_at(discard)
    _effect_cues.append({"kind":kind,"at":position,"actor_id":actor_id,"started":_frame_clock})

func _process(delta: float) -> void:
    if enable_source_vl_art and battle != null and is_visible_in_tree():
        # Visual time follows elapsed frame time; never slow down VFX on sub-20-FPS devices.
        _frame_clock += maxf(0.0, delta)
        _view_elapsed = minf(MapBattleV2.STEP_SECONDS, _view_elapsed + maxf(0.0, delta))
        if enable_spectator_framing:
            _update_spectator_camera(delta)
        for id in _status_feedback.keys():
            if _frame_clock > float(_status_feedback[id].get("until", 0.0)):
                _status_feedback.erase(id)
        for i in range(_effect_cues.size()-1,-1,-1):
            var cue: Dictionary = _effect_cues[i]
            if _frame_clock-float(cue["started"]) > _effect_atlas.duration(str(cue["kind"])):
                _effect_cues.remove_at(i)
        for i in range(_combat_text.size()-1,-1,-1):
            if _frame_clock-float(_combat_text[i]["started"]) > COMBAT_TEXT_SECONDS:
                _combat_text.remove_at(i)
        queue_redraw()

func _ingest_authority_events() -> void:
    if battle == null or not enable_source_vl_art:
        return
    # MapBattleV2 emits skill_hit BEFORE actual _deal_direct settlement.
    # Only a matching subsequent positive learned_skill hit may produce hit VFX.
    var announced_hits: Dictionary = {}
    for index in range(_event_cursor, battle.events.size()):
        var event: Dictionary = battle.events[index]
        var kind := str(event.get("type", ""))
        # Receipt values are final HP deltas from simulation, not FX amounts.
        _ingest_combat_feedback(event,index)
        var actor_id := str(event.get("actor_id", ""))
        if kind == "move" and battle.actors.has(actor_id):
            var current: Vector2 = event.get("position", Vector2.ZERO)
            var previous: Vector2 = _positions.get(actor_id, current)
            var direction := current - previous
            if direction.length_squared() > 0.0001:
                _facing[actor_id] = direction.normalized()
            _positions[actor_id] = current
            _last_move[actor_id] = _frame_clock
        elif kind in ["hit", "skill_hit"]:
            var source := str(event.get("attacker", event.get("caster", "")))
            var target := str(event.get("target", ""))
            var contact_key := source + "|" + target
            if kind == "skill_hit" and str(event.get("skill_id","")) == "ngu_kiem_thuat":
                announced_hits[contact_key] = true
            elif kind == "hit" and str(event.get("kind","")) == "learned_skill":
                if bool(announced_hits.get(contact_key,false)) and float(event.get("damage",0.0)) > 0.0:
                    if battle.actors.has(target):
                        _queue_source_fx("sword_hit",point_on_map(battle.actors[target]["position"]),target)
                announced_hits.erase(contact_key)
            # skill_hit is an authoritative RELEASE notification, not a new attack.
            # Its following learned_skill hit is settlement only: no second swing.
            # Genuine basic attacks have no earlier wind-up event, so cue them here.
            var damage_kind := str(event.get("kind",""))
            if should_start_attack_on_hit(kind, damage_kind) and battle.actors.has(source):
                var existing: Dictionary = _action_cues.get(source,{})
                if (existing.is_empty()
                        or str(existing.get("action","")) != "attack"
                        or not is_equal_approx(float(existing.get("started",-1.0)),_frame_clock)):
                    _action_cues[source] = {"action":"attack", "started":_frame_clock, "until":_frame_clock+0.45}
                if battle.actors.has(target):
                    var direction := (battle.actors[target]["position"] as Vector2) - (battle.actors[source]["position"] as Vector2)
                    if direction.length_squared() > 0.001:
                        _facing[source] = direction.normalized()
            if kind == "hit" and battle.actors.has(target):
                _impact_cues[target] = _frame_clock
                if float(battle.actors[target].get("hp",0.0)) > 0.0:
                    _action_cues[target] = {"action":"hit","started":_frame_clock,"until":_frame_clock+0.24}
        elif kind == "pilot_cast":
            # VFX is cued solely from an actual configured pilot cast.
            # #93 HoT source precast is verified; #15/#159 visuals remain
            # unmapped, never borrow another skill's animation.
            var source_id := str(event.get("caster",""))
            var target_id := str(event.get("target",""))
            if battle.actors.has(source_id):
                if str(event.get("pilot_id","")) == "jx_emei_93":
                    _queue_source_fx("jx_emei_93_precast",
                        point_on_map(battle.actors[source_id]["position"]),source_id)
                _action_cues[source_id] = {"action":"attack","started":_frame_clock,
                    "until":_frame_clock+0.45}
                if battle.actors.has(target_id):
                    var aim := (battle.actors[target_id]["position"] as Vector2) - (battle.actors[source_id]["position"] as Vector2)
                    if aim.length_squared() > 0.001:
                        _facing[source_id] = aim.normalized()
        elif kind in ["pilot_poison_applied", "pilot_hot_applied", "pilot_guard", "pilot_party_defense"]:
            # Short response to events that ACTUALLY occurred. No source FX is invented.
            var recipient := str(event.get("target", event.get("caster", "")))
            if battle.actors.has(recipient):
                _status_feedback[recipient] = {"kind":kind, "until":_frame_clock+0.85}
        elif kind == "pilot_impact":
            var victim := str(event.get("target",""))
            if float(event.get("effective_damage",0.0)) > 0.0 and battle.actors.has(victim):
                var source_kind: String = str({
                    "jx_wudang_158":"jx_wudang_158_impact",
                    "jx_wudu_63":"jx_wudu_63_impact"
                }.get(str(event.get("pilot_id","")),""))
                if not str(source_kind).is_empty():
                    _queue_source_fx(str(source_kind),
                        point_on_map(battle.actors[victim]["position"]),victim)
                _impact_cues[victim] = _frame_clock
                if float(battle.actors[victim].get("hp",0.0)) > 0.0:
                    _action_cues[victim] = {"action":"hit","started":_frame_clock,
                        "until":_frame_clock+0.24}
            # Impact belongs to the receiver; it MUST NOT restart the caster's
            # attack clip after the authoritative cast has already launched.
        elif kind == "telegraph":
            # Real boss/elite wind-up: animate when the red AoE zone appears,
            # NOT when an area_slam hit resolves after the warning.
            var caster_id := str(event.get("caster",""))
            if battle.actors.has(caster_id):
                _action_cues[caster_id] = {"action":"attack","started":_frame_clock,
                    "until":_frame_clock+clampf(
                        float(event.get("release_at",battle.now+0.45))-battle.now,
                        0.15,1.2)}
                var caster_at: Vector2 = battle.actors[caster_id]["position"]
                var center: Vector2 = event.get("center",caster_at)
                var aim := center-caster_at
                if aim.length_squared() > 0.001:
                    _facing[caster_id] = aim.normalized()
        elif kind == "skill_cast":
            var caster_id := str(event.get("actor_id", ""))
            if battle.actors.has(caster_id):
                if str(event.get("skill_id","")) == "ngu_kiem_thuat":
                    _queue_source_fx("sword_cast",point_on_map(battle.actors[caster_id]["position"]),caster_id)
                _action_cues[caster_id] = {"action":"attack","started":_frame_clock,
                    "until":_frame_clock+clampf(float(event.get("release_at",battle.now+0.45))-battle.now,0.15,1.0)}
        elif kind in ["heal","guard","cast"]:
            var caster_id := str(event.get("caster",event.get("actor_id","")))
            if battle.actors.has(caster_id):
                _action_cues[caster_id] = {"action":"attack","started":_frame_clock,"until":_frame_clock+0.35}
        elif kind == "downed" and battle.actors.has(actor_id):
            _action_cues[actor_id] = {"action":"die","started":_frame_clock,"until":INF}
    _event_cursor = battle.events.size()

# Only actual basic damage settlements start a swing without a separate cast event.
# Pilot and learned-skill impacts never restart the caster's already-started clip.
func should_start_attack_on_hit(event_type: String, damage_kind: String) -> bool:
    return event_type == "hit" and damage_kind in ["basic","basic_followup"]

func _actor_clip(actor_id: String, alive: bool) -> Dictionary:
    var cue: Dictionary = _action_cues.get(actor_id,{})
    if not alive:
        return {"name":"die","age":maxf(0.0,_frame_clock-float(cue.get("started",_frame_clock)))}
    if not cue.is_empty() and _frame_clock <= float(cue.get("until",-1.0)):
        return {"name":str(cue["action"]),"age":maxf(0.0,_frame_clock-float(cue.get("started",_frame_clock)))}
    if _frame_clock-float(_last_move.get(actor_id,-99.0)) <= MapBattleV2.STEP_SECONDS+0.001:
        return {"name":"run","age":_frame_clock}
    return {"name":"idle","age":_frame_clock}


func attach_session(session: MapBattleV2) -> void:
    battle = session
    _actor_view_metadata.clear()
    displayed_at = 0.0
    _frame_clock = 0.0
    _event_cursor = session.events.size() if session != null else 0
    _positions.clear()
    _view_prev.clear()
    _view_next.clear()
    _view_elapsed = MapBattleV2.STEP_SECONDS
    _status_feedback.clear()
    _facing.clear()
    _last_move.clear()
    _action_cues.clear()
    _impact_cues.clear()
    _effect_cues.clear()
    _combat_text.clear()
    _load_private_jx_ground()
    _camera_center = GRID_SIZE*0.5
    _camera_zoom = 1.0
    _camera_follow_id = ""
    _camera_free = true
    if session != null:
        for id in session.actors:
            _positions[str(id)] = session.actors[id]["position"]
            _view_prev[str(id)] = session.actors[id]["position"]
            _view_next[str(id)] = session.actors[id]["position"]
            _facing[str(id)] = Vector2.RIGHT if str(session.actors[id].get("side","")) == "disciple" else Vector2.LEFT
        # Begin at the actual battle encounter centroid, but do not
        # re-center on every movement / AI tick. A player drag persists.
        var goal: Dictionary = spectator_camera_goal()
        _camera_center = goal["center"]
    queue_redraw()

func refresh_from_authority() -> void:
    if battle != null:
        if enable_source_vl_art and battle.now != displayed_at:
            # A tick lands after the previous frame render; sample the last
            # visible position, then target only the new V2 snapshot endpoint.
            var sampled: Dictionary = {}
            for id in battle.actors:
                var key := str(id)
                var authoritative: Vector2 = battle.actors[id]["position"]
                sampled[key] = visual_position(key, authoritative)
            for id in battle.actors:
                var key := str(id)
                _view_prev[key] = sampled[key]
                _view_next[key] = battle.actors[id]["position"]
            _view_elapsed = 0.0
        displayed_at = battle.now
        _ingest_authority_events()
    queue_redraw()

# Public deterministic probe for focused view-only tests.
func visual_position(actor_id: String, authoritative: Vector2) -> Vector2:
    if not enable_source_vl_art:
        return authoritative
    var start: Vector2 = _view_prev.get(actor_id, authoritative)
    var finish: Vector2 = _view_next.get(actor_id, authoritative)
    var alpha := clampf(_view_elapsed/MapBattleV2.STEP_SECONDS, 0.0, 1.0)
    return start.lerp(finish, alpha)

# Frame the real living-actor bounds, not a cosmetic formation.
# Allow generous margins for original Source VL art/attack frames/AoE.
func spectator_camera_goal() -> Dictionary:
    if battle == null or not enable_spectator_framing:
        return {"center":GRID_SIZE*0.5,"zoom":1.0}
    var low := Vector2(INF,INF)
    var high := Vector2(-INF,-INF)
    var count := 0
    for id in battle.actors:
        var actor: Dictionary = battle.actors[id]
        if float(actor.get("hp",0.0)) <= 0.0:
            continue
        var at: Vector2 = visual_position(str(id),actor["position"])
        low = Vector2(minf(low.x,at.x),minf(low.y,at.y))
        high = Vector2(maxf(high.x,at.x),maxf(high.y,at.y))
        count += 1
    if count == 0:
        return {"center":_camera_center,"zoom":_camera_zoom}
    var width_pixels := (high.x-low.x)*stage_rect.size.x/GRID_SIZE.x
    var height_pixels := (high.y-low.y)*stage_rect.size.y/GRID_SIZE.y
    var width_zoom := stage_rect.size.x/maxf(width_pixels+230.0,1.0)
    var height_zoom := stage_rect.size.y/maxf(height_pixels+200.0,1.0)
    return {
        "center":(low+high)*0.5,
        "zoom":clampf(
            clampf(minf(width_zoom,height_zoom),1.0,maxf(1.0,spectator_zoom_ceiling))
            * spectator_zoom_multiplier,MIN_VIEW_ZOOM,MAX_VIEW_ZOOM)
    }

func _update_spectator_camera(delta: float) -> void:
    var goal: Dictionary = spectator_camera_goal()
    var blend := clampf(1.0-exp(-2.8*maxf(delta,0.0)),0.0,1.0)
    if not _camera_follow_id.is_empty() and battle != null and battle.actors.has(_camera_follow_id):
        var target: Dictionary = battle.actors[_camera_follow_id]
        _camera_center = _camera_center.lerp(
            visual_position(_camera_follow_id,target["position"]),blend)
    # No default actor tracking. Camera remains freely panned otherwise.
    _camera_zoom = lerpf(_camera_zoom,float(goal["zoom"]),blend)

# Explicit focus can be toggled by clicking the same actor. Pan cancels focus.
func select_camera_actor(actor_id: String) -> bool:
    if battle == null or not battle.actors.has(actor_id):
        return false
    if _camera_follow_id == actor_id:
        _camera_follow_id = ""
        _camera_free = true
        return true
    _camera_follow_id = actor_id
    _camera_free = false
    return true

func clear_camera_follow() -> void:
    _camera_follow_id = ""
    _camera_free = true

func pan_camera_pixels(screen_delta: Vector2) -> void:
    if stage_rect.size.x <= 0.0 or stage_rect.size.y <= 0.0:
        return
    clear_camera_follow()
    var zoom := maxf(spectator_zoom(),0.01)
    var logical_delta := Vector2(
        screen_delta.x * GRID_SIZE.x / stage_rect.size.x,
        screen_delta.y * GRID_SIZE.y / stage_rect.size.y
    ) / zoom
    # A finite world clamp prevents dragging forever outside the encounter,
    # but the viewport is NOT pinned to any disciple.
    _camera_center = (_camera_center - logical_delta).clamp(
        Vector2.ZERO,GRID_SIZE)
    queue_redraw()

func current_camera_follow_id() -> String:
    return _camera_follow_id

func spectator_zoom() -> float:
    return _camera_zoom if enable_spectator_framing and enable_source_vl_art else 1.0

func point_on_map(logical_position: Vector2) -> Vector2:
    var raw := stage_rect.position + Vector2(
        clampf(logical_position.x/GRID_SIZE.x,0.0,1.0)*stage_rect.size.x,
        clampf(logical_position.y/GRID_SIZE.y,0.0,1.0)*stage_rect.size.y
    )
    if not enable_spectator_framing or not enable_source_vl_art:
        return raw
    var camera_origin := stage_rect.position + Vector2(
        _camera_center.x/GRID_SIZE.x*stage_rect.size.x,
        _camera_center.y/GRID_SIZE.y*stage_rect.size.y
    )
    return stage_rect.get_center()+(raw-camera_origin)*_camera_zoom

func logical_from_map(map_position: Vector2) -> Vector2:
    if stage_rect.size.x <= 0.0 or stage_rect.size.y <= 0.0:
        return Vector2.ZERO
    var raw := map_position
    if enable_spectator_framing and enable_source_vl_art:
        var camera_origin := stage_rect.position + Vector2(
            _camera_center.x/GRID_SIZE.x*stage_rect.size.x,
            _camera_center.y/GRID_SIZE.y*stage_rect.size.y
        )
        raw = camera_origin+(map_position-stage_rect.get_center())/maxf(0.01,_camera_zoom)
    var relative := (raw-stage_rect.position)/stage_rect.size
    return Vector2(
        clampf(relative.x*GRID_SIZE.x,0.0,GRID_SIZE.x),
        clampf(relative.y*GRID_SIZE.y,0.0,GRID_SIZE.y)
    )

func actor_at_map_point(map_position: Vector2, max_distance: float = 17.0) -> String:
    if battle == null:
        return ""
    var best := ""
    var nearest := pow(max_distance*spectator_zoom(),2.0)
    var ids: Array = battle.actors.keys()
    ids.sort()
    for id in ids:
        var actor: Dictionary = battle.actors[id]
        if float(actor.get("hp",0.0)) <= 0.0:
            continue
        var at := point_on_map(visual_position(str(id),actor["position"]))
        var dist := at.distance_squared_to(map_position)
        if dist < nearest:
            nearest = dist
            best = str(id)
    return best

# Only cast packets with the actual delayed AoE geometry produce red zones.
# Learned single-target casts contain target_id/skill_id but NO center/radius.
# Kept pure so the focused test checks the SAME data consumed by _draw().
func aoe_warning_geometry() -> Array[Dictionary]:
    var zones: Array[Dictionary] = []
    if battle == null:
        return zones
    for cast_value in battle.pending_casts:
        if not (cast_value is Dictionary):
            continue
        var cast: Dictionary = cast_value
        if cast.has("skill_id") or cast.has("target_id"):
            continue
        if not (cast.has("center") and cast.has("radius") and cast.has("caster") and
                cast.has("ready") and cast.has("maximum")):
            continue
        if not (cast["center"] is Vector2) or not (cast["radius"] is float or cast["radius"] is int):
            continue
        if not (cast["ready"] is float or cast["ready"] is int) or not (cast["maximum"] is int):
            continue
        var center: Vector2 = cast["center"]
        var radius := float(cast["radius"])
        var ready_at := float(cast["ready"])
        if is_nan(center.x) or is_inf(center.x) or is_nan(center.y) or is_inf(center.y):
            continue
        if center.x < 0.0 or center.x > GRID_SIZE.x or center.y < 0.0 or center.y > GRID_SIZE.y:
            continue
        if is_nan(radius) or is_inf(radius) or radius <= 0.0:
            continue
        if is_nan(ready_at) or is_inf(ready_at) or ready_at < battle.now:
            continue
        if int(cast["maximum"]) < 1 or int(cast["maximum"]) > MapBattleV2.MAX_TARGETS_AOE:
            continue
        var caster_id := str(cast["caster"])
        var caster: Dictionary = battle.actors.get(caster_id,{})
        if caster_id.is_empty() or caster.is_empty() or float(caster.get("hp",0.0)) <= 0.0:
            continue
        zones.append({"center":center,"radius":radius})
    return zones

# Source VL wolf sheets can specify an anchor BELOW the cropped texture
# (e.g. idle 53px high, source anchor y=67). Draw-time art alignment is
# independent of authoritative MapBattleV2 feet/hit coordinates.
func source_art_foot(art_key: String, action: String, facing: Vector2,
        age: float, art_scale: float, logical_foot: Vector2) -> Vector2:
    if art_key.is_empty() or not enable_source_vl_art:
        return logical_foot
    var frame: Dictionary = _source_atlas.frame_region(art_key,action,facing,age)
    if frame.is_empty():
        return logical_foot
    var anchor: Vector2 = frame["anchor"]
    var crop: Rect2 = frame["source"]
    var extra := maxf(0.0,anchor.y-crop.size.y)
    return logical_foot+Vector2(0.0,extra*art_scale*float(frame["scale"]))

# The bar must clear the DRAWN sprite's top edge, not a fixed guess.
# Render correction for below-crop anchors must also affect this UI offset.
func _hp_bar_y(art_key: String, action: String, facing: Vector2,
        age: float, art_scale: float, radius: float) -> float:
    var fallback := -radius-10.0
    if art_key.is_empty() or not enable_source_vl_art:
        return fallback
    var frame: Dictionary = _source_atlas.frame_region(art_key,action,facing,age)
    if frame.is_empty():
        return fallback
    var ratio := art_scale * float(frame["scale"])
    var crop: Rect2 = frame["source"]
    var sprite_top := -minf(float((frame["anchor"] as Vector2).y),
        crop.size.y)*ratio
    return minf(fallback,sprite_top-10.0)

# Moving a UI health bar is permitted; moving a character away from its
# authoritative path is NOT. Layout remains deterministic for a given frame.
func layout_hp_overlays(overlays: Array[Dictionary]) -> Array[Dictionary]:
    # Shared collision pass for HP, identity tags and status feedback.
    # Keep every overlay inside the 1280x720 pilot's stage; otherwise a
    # clustered group at the top edge can push HP completely off-screen.
    var placed: Array[Dictionary] = []
    var answer: Array[Dictionary] = []
    answer.resize(overlays.size())
    var order: Array[Dictionary] = []
    for i in range(overlays.size()):
        var kind := str(overlays[i].get("kind","hp"))
        # HP is a gameplay-essential meter. Names precede short status tags.
        var priority := 0 if kind == "hp" else (
            1 if kind == "name" else (2 if kind == "rank" else 3))
        order.append({"index":i,"priority":priority})
    order.sort_custom(func(a,b):
        if int(a["priority"]) != int(b["priority"]):
            return int(a["priority"]) < int(b["priority"])
        return int(a["index"]) < int(b["index"])
    )
    var bounds := stage_rect.grow(-4.0)
    for record in order:
        var index := int(record["index"])
        var entry: Dictionary = overlays[index].duplicate()
        var initial: Rect2 = entry["rect"]
        var candidate := initial
        candidate.position.x = clampf(initial.position.x,bounds.position.x,
            bounds.end.x-initial.size.x)
        var step := initial.size.y+6.0
        for attempt in range(64):
            var lane := int(ceil(float(attempt)*0.5))
            var direction := -1.0 if attempt%2 == 1 else 1.0
            candidate.position.y = clampf(initial.position.y+float(lane)*step*direction,
                bounds.position.y,bounds.end.y-initial.size.y)
            var collided := false
            for other in placed:
                if candidate.grow(3.0).intersects((other["rect"] as Rect2).grow(3.0)):
                    collided = true
                    break
            if not collided:
                break
        entry["rect"] = candidate
        placed.append(entry)
        # Preserve caller/painter order while using priority for placement.
        answer[index] = entry
    return answer

func _school_tag(actor: Dictionary) -> String:
    var loadout: Array = actor.get("pilot_loadout",[])
    if loadout.has("jx_shaolin_15"):
        return "TL"
    if loadout.has("jx_wudang_159") or loadout.has("jx_wudang_158"):
        return "VD"
    if loadout.has("jx_wudu_63"):
        return "ND"
    if loadout.has("jx_emei_93"):
        return "NM"
    var role := str(actor.get("role",""))
    return {"frontline":"CAN","ranged":"XA","healer":"HOI","mage":"PHAP"}.get(role,"DT")

# Attach provenance-rich display rows from the original encounter source,
# never from combat damage/stats or guessed monster HP. This bridge is not saved.
func set_actor_view_metadata(rows: Dictionary) -> void:
    _actor_view_metadata.clear()
    if battle == null:
        return
    for id in rows:
        var key := str(id)
        if not battle.actors.has(key) or not (rows[id] is Dictionary):
            continue
        var raw: Dictionary = rows[id]
        var entry: Dictionary = {}
        var realm := int(raw.get("realm_index",0))
        var floor_index := int(raw.get("floor_index",0))
        if DiscipleRealmProgressV2.valid_coordinates(realm,floor_index):
            entry["realm_index"] = realm
            entry["floor_index"] = floor_index
        var body_realm := int(raw.get("body_realm_index",0))
        var body_floor := int(raw.get("body_floor_index",0))
        if DiscipleRealmProgressV2.valid_coordinates(body_realm,body_floor):
            entry["body_realm_index"] = body_realm
            entry["body_floor_index"] = body_floor
        var authored := str(raw.get("display_name","")).strip_edges()
        if not authored.is_empty():
            entry["display_name"] = authored.substr(0,32)
        if not entry.is_empty():
            _actor_view_metadata[key] = entry

# Real recruit's V2 progression can be observed without cloning or writing it.
# No level is fabricated when a fixture/snapshot lacks its source metadata.
func _actor_realm_metadata(actor: Dictionary) -> Dictionary:
    var id := str(actor.get("id",""))
    var row: Dictionary = _actor_view_metadata.get(id,{})
    if row.has("realm_index") and row.has("floor_index"):
        return row
    var linked: Variant = actor.get("linked_disciple",null)
    if linked is DiscipleState and DiscipleRealmProgressV2.progression_ready(linked):
        var progress: Dictionary = linked.v2_realm_progress
        var cultivation: Dictionary = progress.get("cultivation",{})
        var body: Dictionary = progress.get("body",{})
        return {
            "realm_index":int(cultivation.get("realm",0)),
            "floor_index":int(cultivation.get("floor",0)),
            "body_realm_index":int(body.get("realm",0)),
            "body_floor_index":int(body.get("floor",0))
        }
    return {}

func combat_actor_rank_label(actor: Dictionary) -> String:
    var row := _actor_realm_metadata(actor)
    var realm := int(row.get("realm_index",0))
    var floor_index := int(row.get("floor_index",0))
    if not DiscipleRealmProgressV2.valid_coordinates(realm,floor_index):
        return ""
    var name := DiscipleRealmProgressV2.realm_name("cultivation",realm)
    var prefix := ""
    if str(actor.get("side","")) == "monster":
        match str(actor.get("tier","normal")):
            "boss":
                prefix = "BOSS · "
            "elite":
                prefix = "TINH ANH · "
    return prefix+name+" · Tầng "+str(floor_index)

func combat_actor_body_label(actor: Dictionary) -> String:
    var row := _actor_realm_metadata(actor)
    var realm := int(row.get("body_realm_index",0))
    var floor_index := int(row.get("body_floor_index",0))
    if not DiscipleRealmProgressV2.valid_coordinates(realm,floor_index):
        return ""
    return DiscipleRealmProgressV2.realm_name("body",realm)+" · Tầng "+str(floor_index)

# A visible label must originate in the actor or canonical monster catalogue.
# Never invent disciple names from render positions or overlay state.
func combat_actor_label(actor: Dictionary) -> String:
    var source: Dictionary = _actor_view_metadata.get(str(actor.get("id","")),{})
    var authored := str(source.get("display_name",
        actor.get("display_name",actor.get("name","")))).strip_edges()
    if authored.is_empty():
        var linked: Variant = actor.get("linked_disciple",null)
        if linked is DiscipleState:
            authored = str(linked.display_name).strip_edges()
    if not authored.is_empty():
        return authored
    if str(actor.get("side","")) == "monster":
        var species_id := str(actor.get("species_id",""))
        if MonsterCatalogueV2.SPECIES.has(species_id):
            return str(MonsterCatalogueV2.SPECIES[species_id]["name"])
        return "Quái"
    return _actor_badge(actor)

# Stable per-actor badge ID; does not assign gameplay identity/role.
func _actor_badge(actor: Dictionary) -> String:
    var tag := _school_tag(actor)
    var actor_id := str(actor.get("id",""))
    var digits := actor_id.substr(maxi(0,actor_id.length()-2),2)
    if digits.is_valid_int():
        return tag + str(int(digits)+1)
    return tag

func _school_color(tag: String) -> Color:
    return {
        "TL":Color(0.96,0.68,0.32), "VD":Color(0.45,0.75,0.98),
        "ND":Color(0.72,0.60,0.98), "NM":Color(0.53,0.91,0.66),
        "CAN":Color(0.94,0.67,0.42), "XA":Color(0.49,0.83,0.88),
        "HOI":Color(0.47,0.91,0.66), "PHAP":Color(0.68,0.70,0.98)
    }.get(tag,Color(0.82,0.86,0.80))

# Attach source FX to the visible character position, not one simulation tick
# ahead of the interpolated sprite. No change to gameplay hit coordinates.
func source_fx_screen_position(cue: Dictionary) -> Vector2:
    var fallback: Vector2 = cue.get("at",Vector2.ZERO)
    var actor_id := str(cue.get("actor_id",""))
    if battle == null or actor_id.is_empty() or not battle.actors.has(actor_id):
        return fallback
    var real_position: Vector2 = battle.actors[actor_id]["position"]
    return point_on_map(visual_position(actor_id,real_position))

# Presentation-only lâm địa backdrop; no map collision, actor position,
# RNG, targeting or authoritative movement changed. Render first so the
# verified Source A trees and earth can never obscure HP, cues or attacks.
# Prefer authentic owner-held zone art to invented/Source A terrain
# whenever its private binary is installed. This stays view-only, outside RNG.
func _load_private_jx_ground() -> void:
    if _jx_private_ground_checked:
        return
    _jx_private_ground_checked = true
    if not FileAccess.file_exists(JX_PRIVATE_BACKDROP):
        return
    var original := Image.new()
    var status := original.load(JX_PRIVATE_BACKDROP)
    if status != OK:
        push_warning("C4 PRIVATE JX zone background could not be decoded")
        return
    if original.get_width() < 512 or original.get_height() < 512:
        push_warning("C4 PRIVATE JX zone background is implausibly small")
        return
    _jx_private_ground = ImageTexture.create_from_image(original)

func _draw_private_jx_zone() -> void:
    if _jx_private_ground == null:
        return
    var whole: Vector2 = _jx_private_ground.get_size()
    var zoom := clampf(spectator_zoom(),0.70,2.25)
    # Each stage covers a portion of the larger native JX zone; panning
    # moves the backdrop and actors through the same camera coordinate.
    var visible_x := minf(whole.x,whole.x*0.50/zoom)
    var visible_y := minf(whole.y,visible_x*stage_rect.size.y/stage_rect.size.x)
    var source_units_per_x := whole.x*0.50/GRID_SIZE.x
    var source_units_per_y := (whole.y*0.50)*(stage_rect.size.y/stage_rect.size.x)/GRID_SIZE.y
    var centered := whole*0.5 + Vector2(
        (_camera_center.x-GRID_SIZE.x*0.5)*source_units_per_x,
        (_camera_center.y-GRID_SIZE.y*0.5)*source_units_per_y
    )
    var start := Vector2(
        clampf(centered.x-visible_x*0.5,0.0,whole.x-visible_x),
        clampf(centered.y-visible_y*0.5,0.0,whole.y-visible_y)
    )
    draw_texture_rect_region(_jx_private_ground,stage_rect,
        Rect2(start,Vector2(visible_x,visible_y)))

func _draw_source_a_forest_floor() -> void:
    _load_private_jx_ground()
    if _jx_private_ground != null:
        _draw_private_jx_zone()
        return
    var r := stage_rect
    var left := r.position.x
    var top := r.position.y
    var w := r.size.x
    var h := r.size.y
    draw_rect(r,Color(0.23,0.39,0.27,1.0))
    # Multi-tone grass/forest bands cover the ENTIRE 864x547 arena rather
    # than leave an empty dark tactical test rectangle.
    draw_colored_polygon(PackedVector2Array([
        Vector2(left,top),Vector2(left+w,top),Vector2(left+w,top+h*0.30),
        Vector2(left+w*0.65,top+h*0.36),Vector2(left+w*0.21,top+h*0.28),
        Vector2(left,top+h*0.42)
    ]),Color(0.13,0.27,0.20,1.0))
    draw_colored_polygon(PackedVector2Array([
        Vector2(left,top+h*0.79),Vector2(left+w*0.32,top+h*0.69),
        Vector2(left+w*0.79,top+h*0.87),Vector2(left+w,top+h*0.72),
        Vector2(left+w,top+h),Vector2(left,top+h)
    ]),Color(0.28,0.44,0.29,1.0))
    # Narrow earthen track through Thanh Trúc Lâm; purely scenic.
    draw_colored_polygon(PackedVector2Array([
        Vector2(left,top+h*0.56),Vector2(left+w*0.30,top+h*0.43),
        Vector2(left+w*0.68,top+h*0.58),Vector2(left+w,top+h*0.47),
        Vector2(left+w,top+h*0.62),Vector2(left+w*0.68,top+h*0.73),
        Vector2(left+w*0.30,top+h*0.57),Vector2(left,top+h*0.70)
    ]),Color(0.48,0.43,0.31,0.74))
    # Fixed decorative tufts and pebbles; never consume GameRng or TIME.
    for index in range(35):
        var unit_x := fposmod(float(index*71+19),991.0)/991.0
        var unit_y := fposmod(float(index*37+11),593.0)/593.0
        var at := Vector2(left+unit_x*w,top+unit_y*h)
        draw_circle(at,1.4 if index%3!=0 else 2.4,
            Color(0.77,0.81,0.59,0.36) if index%4==0 else Color(0.13,0.26,0.15,0.48))
        if index%3==0:
            draw_line(at,at+Vector2(3.0,-6.0),Color(0.52,0.68,0.37,0.46),1.0)
    # Sparse, original Source A sprite sheets at the margins. No edge props
    # at the combat center; battlefield actors always paint over these.
    var source_trees := [FOREST_A,FOREST_B,FOREST_C]
    var placements := [
        Vector2(0.01,0.02),Vector2(0.22,0.01),Vector2(0.74,0.01),Vector2(0.91,0.04),
        Vector2(0.01,0.67),Vector2(0.10,0.84),Vector2(0.85,0.83),Vector2(0.96,0.70)
    ]
    for index in range(placements.size()):
        var source: Texture2D = source_trees[index%source_trees.size()]
        var pos: Vector2 = placements[index]
        var width := 76.0 if index%3!=0 else 97.0
        var native_size := source.get_size()
        if native_size.x <= 0.0 or native_size.y <= 0.0:
            continue
        var height := minf(145.0,width*native_size.y/native_size.x)
        draw_texture_rect(source,Rect2(Vector2(
            left+pos.x*w-width*0.5,top+pos.y*h-height*0.1
        ),Vector2(width,height)),false,Color(0.93,0.96,0.88,0.91))

func _draw() -> void:
    if battle == null:
        return
    if draw_pilot_ground:
        _draw_source_a_forest_floor()
    # Telegraphs are projected onto the SAME world-space positions as actors.
    # Drawing them never changes target hit checks performed in MapBattleV2.
    var scale_x := stage_rect.size.x/GRID_SIZE.x
    var scale_y := stage_rect.size.y/GRID_SIZE.y
    for zone in aoe_warning_geometry():
        var center := point_on_map(zone["center"])
        var radius := Vector2(float(zone["radius"])*scale_x,float(zone["radius"])*scale_y)*spectator_zoom()
        # Slight top-down perspective: warning ellipse is a gameplay cue only.
        draw_set_transform(center,0.0,radius)
        draw_circle(Vector2.ZERO,1.0,WARNING)
        draw_arc(Vector2.ZERO,1.0,0.0,TAU,40,Color(0.94,0.36,0.26,0.74),0.08)
        draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
    # Art cues are observations of real V2 casts/hits; draw BELOW actor silhouettes and HP.
    if enable_source_vl_art:
        for cue in _effect_cues:
            var source_kind := str(cue["kind"])
            var ratio := 0.42 if source_kind in [
                "sword_cast","jx_wudang_158_impact","jx_wudu_63_impact"
            ] else 0.66
            _effect_atlas.draw_effect(self,source_kind,source_fx_screen_position(cue),
                _frame_clock-float(cue["started"]),ratio)
    var ui_overlays: Array[Dictionary] = []
    var ids: Array = battle.actors.keys()
    # Isometric depth: far-away feet draw first; stable ID tie prevents flicker.
    # Presentation sort only, NEVER affects MapBattleV2 action/target order.
    if enable_source_vl_art:
        ids.sort_custom(func(a,b):
            var at_a: Vector2 = visual_position(str(a), battle.actors[a]["position"])
            var at_b: Vector2 = visual_position(str(b), battle.actors[b]["position"])
            # Exact lexicographic ordering is transitive, unlike epsilon ties.
            if at_a.y != at_b.y:
                return at_a.y < at_b.y
            if at_a.x != at_b.x:
                return at_a.x < at_b.x
            return str(a) < str(b)
        )
    else:
        ids.sort()
    for id in ids:
        var actor: Dictionary = battle.actors[id]
        var at := point_on_map(visual_position(str(id),actor["position"]))
        var side := str(actor.get("side",""))
        var alive := float(actor["hp"]) > 0.0
        var tier := str(actor.get("tier","normal"))
        var fill := DISCIPLE_FILL if side == "disciple" else (
            BOSS_FILL if tier == "boss" else (ELITE_FILL if tier == "elite" else ENEMY_FILL)
        )
        if not alive:
            fill = Color(0.42,0.42,0.41,0.36)
        var radius := 10.0 if tier == "boss" else (7.5 if tier == "elite" else 6.0)
        var art_key := ""
        if side == "disciple":
            art_key = "hero"
        elif str(actor.get("species_id","")) in ["thanh_lang","hac_lang","hac_lang_vuong"]:
            art_key = "wolf"
        var art_used := false
        var hp_y := -radius-10.0
        if enable_source_vl_art and not art_key.is_empty():
            var clip := _actor_clip(str(id),alive)
            var art_scale := (1.52 if tier == "boss" else (1.12 if art_key == "wolf" else 0.92))*spectator_zoom()
            draw_circle(at+Vector2(0.0,3.0),maxf(8.0,radius*1.25)*spectator_zoom(),
                Color(0.02,0.05,0.04,0.43))
            var art_foot := source_art_foot(art_key,str(clip["name"]),
                _facing.get(str(id),Vector2.RIGHT),float(clip["age"]),art_scale,at)
            art_used = _source_atlas.draw_actor(self,art_key,str(clip["name"]),art_foot,
                _facing.get(str(id),Vector2.RIGHT),float(clip["age"]),art_scale)
            if art_used:
                hp_y = _hp_bar_y(art_key,str(clip["name"]),_facing.get(str(id),Vector2.RIGHT),
                    float(clip["age"]),art_scale,radius)
        if not art_used:
            draw_circle(at+Vector2(0.0,2.0),(radius+2.0)*spectator_zoom(),BORDER)
            draw_circle(at,radius*spectator_zoom(),fill)
        if tier == "boss" and alive:
            draw_arc(at,maxf(15.0,radius+3.0)*spectator_zoom(),
                0.0,TAU,24,Color(0.94,0.73,0.39,0.85),1.5)
        if enable_source_vl_art and alive:
            # Classic JX nameplate reads above the HP meter; live monster
            # names come from MonsterCatalogueV2, not a cosmetic alias.
            var actor_name := combat_actor_label(actor)
            var name_width := clampf(float(actor_name.length())*7.0+12.0,54.0,138.0)
            var name_tint := _school_color(_school_tag(actor)) if side == "disciple" else (
                Color(1.0,0.77,0.37) if tier == "boss" else Color(1.0,0.85,0.72))
            ui_overlays.append({
                "kind":"name",
                "rect":Rect2(at+Vector2(-name_width*0.5,hp_y-24.0),
                    Vector2(name_width,14.0)),
                "text":actor_name,"fill":name_tint
            })
            var rank := combat_actor_rank_label(actor)
            if not rank.is_empty():
                var rank_width := clampf(float(rank.length())*6.0+12.0,72.0,194.0)
                ui_overlays.append({
                    "kind":"rank",
                    "rect":Rect2(at+Vector2(-rank_width*0.5,hp_y-41.0),
                        Vector2(rank_width,14.0)),
                    "text":rank,"fill":Color(0.86,0.88,0.76)
                })
            # Statuses derive from currently active effects/guards, never a
            # guessed VFX duration. Keep no more than two tags visible in 6v5.
            var tags := active_combat_status_tags(actor)
            for status_index in range(mini(tags.size(),2)):
                ui_overlays.append({
                    "kind":"status","rect":Rect2(
                        at+Vector2(-24.0+float(status_index)*51.0,40.0),
                        Vector2(48.0,19.0)),
                    "text":tags[status_index],"fill":Color(0.95,0.94,0.70)
                })

        var health := clampf(float(actor["hp"])/maxf(1.0,float(actor["max_hp"])),0.0,1.0)
        var bar_width := 60.0 if tier == "boss" else (48.0 if art_used else 22.0)
        var bar_height := 7.0 if tier == "boss" else (6.0 if art_used else 4.0)
        var bar := Rect2(at+Vector2(-bar_width*0.5,hp_y),Vector2(bar_width,bar_height))
        if enable_source_vl_art and alive:
            # Bars are drawn after ALL sprites, preventing near-actor occlusion.
            ui_overlays.append({"kind":"hp","rect":bar,"ratio":health,
                "monster":side == "monster",
                "fill":HP_GOOD if side == "disciple" else HP_ENEMY})
        else:
            draw_rect(bar,HP_BG)
            draw_rect(Rect2(bar.position,Vector2(bar.size.x*health,bar.size.y)),
                HP_GOOD if side == "disciple" else HP_ENEMY)
        if enable_source_vl_art and _impact_cues.has(str(id)):
            var passed := _frame_clock-float(_impact_cues[str(id)])
            if passed >= 0.0 and passed < 0.30:
                draw_arc(at,13.0+passed*35.0,0.0,TAU,24,
                    Color(1.0,0.80,0.40,0.88*(1.0-passed/0.30)),2.0)

    if enable_source_vl_art:
        # Combat numbers sit above sprites but BELOW HP/name HUD.
        # Display never changes HP. Event-ID lanes use no gameplay RNG.
        if enable_combat_text:
            for popup in _combat_text:
                var age := _frame_clock-float(popup["started"])
                if age < 0.0 or age > COMBAT_TEXT_SECONDS:
                    continue
                var actor_id := str(popup["actor_id"])
                if not battle.actors.has(actor_id):
                    continue
                var target: Dictionary = battle.actors[actor_id]
                var origin: Vector2 = popup.get("world_origin",
                    visual_position(actor_id,target["position"]))
                var point := point_on_map(origin)
                var lane := int(popup["event_id"]) % 4
                var position := point+Vector2(
                    float(lane-2)*15.0,-44.0-age*38.0)
                var category := str(popup["category"])
                var text_value := str(popup["label"])
                var size := 16 if category == "crit" else 13
                var width := maxf(52.0,float(text_value.length())*float(size)*0.67+10.0)
                position.x = clampf(position.x-width*0.5,
                    stage_rect.position.x,stage_rect.end.x-width)
                position.y = clampf(position.y,
                    stage_rect.position.y+2.0,stage_rect.end.y-25.0)
                var fade := clampf((COMBAT_TEXT_SECONDS-age)/0.25,0.0,1.0)
                var bounds := Rect2(position,Vector2(width,float(size)+9.0))
                # JX1-inspired colored glyph + dark stroke, no opaque
                # rectangle hiding the source sprite or the battlefield.
                var tint := _combat_feedback_color(category)
                tint.a = fade
                var text_at := position+Vector2(4.0,float(size)+2.0)
                draw_string_outline(ThemeDB.fallback_font,text_at,text_value,
                    HORIZONTAL_ALIGNMENT_CENTER,width-8.0,size,2,
                    Color(0.015,0.015,0.012,0.95*fade))
                draw_string(ThemeDB.fallback_font,text_at,text_value,
                    HORIZONTAL_ALIGNMENT_CENTER,width-8.0,size,tint)

        # LAST pass: front-row sprites and FX cannot hide role/HP labels.
        # Moving UI boxes is permitted; sprite feet / battle target positions stay exact.
        for overlay_value in layout_hp_overlays(ui_overlays):
            var overlay: Dictionary = overlay_value
            var bounds: Rect2 = overlay["rect"]
            var kind := str(overlay.get("kind","hp"))
            if kind == "hp":
                draw_rect(bounds,HP_BG)
                var hp_ratio := clampf(float(overlay["ratio"]),0.0,1.0)
                if hp_ratio > 0.0 and bool(overlay.get("monster",false)) and JX_HP_STRIP != null:
                    # Source strip pixels, cropped by real authoritative HP.
                    draw_texture_rect_region(JX_HP_STRIP,
                        Rect2(bounds.position,Vector2(bounds.size.x*hp_ratio,bounds.size.y)),
                        Rect2(Vector2.ZERO,Vector2(float(JX_HP_STRIP.get_width())*hp_ratio,
                            float(JX_HP_STRIP.get_height()))))
                else:
                    draw_rect(Rect2(bounds.position,
                        Vector2(bounds.size.x*hp_ratio,bounds.size.y)),
                        overlay["fill"])
            else:
                if kind != "name" and kind != "rank":
                    draw_rect(bounds,Color(0.035,0.065,0.07,0.94))
                var text_size := 11 if kind in ["name","rank"] else 12
                var baseline := bounds.position+Vector2(2.0,
                    12.0 if kind in ["name","rank"] else 14.5)
                draw_string_outline(ThemeDB.fallback_font,baseline,
                    str(overlay["text"]),HORIZONTAL_ALIGNMENT_CENTER,
                    bounds.size.x-4.0,text_size,2,Color(0.025,0.035,0.025,0.96))
                draw_string(ThemeDB.fallback_font,baseline,
                    str(overlay["text"]),HORIZONTAL_ALIGNMENT_CENTER,
                    bounds.size.x-4.0,text_size,overlay["fill"])

