class_name MapBattleV2
extends RefCounted

# DV2-02D: deterministic, event-driven, group-versus-group map battle.
# Local world coordinates (0..36, 0..20), never pixel/screen coordinates.
# The scene renders actor positions/events; camera/visibility is NOT simulation input.
# This is a V2-only encounter; legacy P3.7 CombatSystem routing is untouched.
const STEP_SECONDS := 0.25
const MAX_SECONDS := 90.0
const MAX_EVENTS := 2400
const ARENA := Rect2(Vector2.ZERO,Vector2(36.0,20.0))
const MAX_DISCIPLES := 30
const P0_LOCAL_HUNT_RADIUS := 18.0
const MAX_MONSTERS := 40
const MAX_SUMMON_ACTORS := 6
const MAX_TARGETS_AOE := 3
# Backpressure rather than dropping durable HP0 records when PH1 has not ACKed.
const MAX_PENDING_KILLS := 256
const MAX_EXTERNAL_DAMAGE_IDS := 4096
const MAX_CONTINUOUS_BATCH_STEPS := 20000
const MAX_REMEMBERED_SPAWN_SLOTS := 1024
const MAX_WORLD_PATH_CACHE_ENTRIES := 128
const WORLD_MOVE_FORMATION_MIN_GAP_CELLS := 3.5
# Ordinary attack ranges by battlefield role (world grid cells). Explicit
# basic_range supplied by canonical roster overrides these fallbacks unchanged.
# Skill range comes independently from the V6.3 catalogue.
const ROLE_DEFAULT_BASIC_RANGE := {"frontline":1.8, "mage":6.0, "healer":6.0, "ranged":9.0}

static func default_basic_range_for_role(role: String) -> float:
    return float(ROLE_DEFAULT_BASIC_RANGE.get(role, 1.8))

var rng: GameRng
var now: float = 0.0
var encounter_id: String = ""
var actors: Dictionary = {}
var pending_casts: Array = []
var events: Array = []
var active: bool = false
var outcome: String = "uninitialized"
var actions: int = 0
var downed_disciples: int = 0
var continuous_mode: bool = false
var world_mode: bool = false
var world_bounds: Rect2 = ARENA
var world_navigation: Dictionary = {}
var auto_hunt: bool = true
var _pending_world_options: Dictionary = {}
var _external_hit_ids: Dictionary = {}
# Authoritative, explicitly acknowledged domain events; NEVER derived from events.
# PH2 must persist a canonical receipt in the SAME save barrier before ACK.
var _pending_kill_events: Array = []
# A slot's generation never regresses even after a corpse actor is removed.
var _last_spawn_generation: Dictionary = {}
var performance_logging_enabled := false
var performance_world_path_count := 0
var performance_world_path_usec_total := 0
var performance_world_path_usec_max := 0
var performance_step_count := 0
var performance_step_usec_total := 0
var performance_step_usec_max := 0
var performance_world_path_cache_hit_count := 0
var _world_path_cache: Dictionary = {}
var _world_path_cache_fifo: Array[String] = []

func _init(seed_value: int = 515151) -> void:
    rng = GameRng.new(seed_value)
    performance_logging_enabled = OS.get_environment("TMB_PVE_PERF_LOG") == "1"

func setup(id: String, party: Array, monsters: Array, keep_encounter_open: bool = false) -> Dictionary:
    if active or id.is_empty() or (party.is_empty() and not keep_encounter_open) or party.size() > MAX_DISCIPLES:
        return {"ok":false,"reason":"invalid_encounter_or_party"}
    if (monsters.is_empty() and not keep_encounter_open) or monsters.size() > MAX_MONSTERS:
        return {"ok":false,"reason":"invalid_monster_group"}
    actors.clear()
    events.clear()
    pending_casts.clear()
    now = 0.0
    encounter_id = id
    actions = 0
    downed_disciples = 0
    continuous_mode = keep_encounter_open
    world_mode = false
    world_bounds = ARENA
    world_navigation.clear()
    _world_path_cache.clear()
    _world_path_cache_fifo.clear()
    performance_world_path_cache_hit_count = 0
    auto_hunt = true
    if keep_encounter_open and not _pending_world_options.is_empty():
        var requested_bounds = _pending_world_options.get("bounds",Rect2())
        var requested_navigation = _pending_world_options.get("navigation",{})
        if not (requested_bounds is Rect2) or not (requested_bounds as Rect2).has_area() or not (requested_navigation is Dictionary):
            return {"ok":false,"reason":"invalid_open_world_navigation_options"}
        world_bounds = requested_bounds
        world_navigation = requested_navigation.duplicate(true)
        world_mode = true
        var nav_error := _validate_world_navigation()
        if not nav_error.is_empty():
            world_mode = false
            world_bounds = ARENA
            world_navigation.clear()
            return {"ok":false,"reason":nav_error}
    _external_hit_ids.clear()
    _pending_kill_events.clear()
    _last_spawn_generation.clear()
    var entries: Array = []
    var party_sizes: Dictionary = {}
    for raw in party:
        if not (raw is Dictionary):
            return {"ok":false,"reason":"invalid_party_entry"}
        var row: Dictionary = raw
        var actor_id := str(row.get("id",""))
        var party_id := str(row.get("party_id","party_0"))
        party_sizes[party_id] = int(party_sizes.get(party_id,0))+1
        if party_id.is_empty() or int(party_sizes[party_id]) > 6:
            return {"ok":false,"reason":"max_six_disciples_per_party"}
        var stats: Dictionary = row.get("stats",{})
        var pos: Vector2 = row.get("position",Vector2(-1.0,-1.0))
        var role := str(row.get("role","frontline"))
        if actor_id.is_empty() or stats.is_empty() or not _position_allowed(pos) or not ["frontline","ranged","mage","healer"].has(role):
            return {"ok":false,"reason":"invalid_party_actor"}
        var hp := float(row.get("hp",float(stats.get("max_hp",0.0))))
        var max_hp := float(stats.get("max_hp",0.0))
        if hp <= 0.0 or max_hp <= 0.0 or hp > max_hp or float(stats.get("attack",0.0)) <= 0.0:
            return {"ok":false,"reason":"invalid_party_hp_or_attack"}
        entries.append({
            "id":actor_id,"side":"disciple","party_id":party_id,"role":role,"tier":"disciple",
            "race_id":"nhan_toc","position":pos,"stats":stats.duplicate(true),
            "hp":hp,"max_hp":max_hp,"resistances":row.get("resistances",{}).duplicate(true),
            "primary_element":str(row.get("primary_element","neutral")),
            "range":float(row.get("basic_range",default_basic_range_for_role(role))),
            "move_speed":float(row.get("move_speed",2.35 if role == "frontline" else 2.05)),
            "basic_ratio":float(row.get("basic_ratio",1.0)),
            "basic_interval":float(row.get("basic_interval",1.6)),
            "skill_loadout":row.get("skill_loadout",[]).duplicate(true),
            "skill_factors":row.get("skill_factors",{}).duplicate(true),
            "skill_ready":{},
            "context_sources":row.get("context_sources",[]).duplicate(true),
            "next_basic":0.0,"next_skill":0.0,"guard_until":-1.0,
            "learned_guard_until":-1.0,"learned_guard_factor":1.0,"status_effects":{},
            "linked_disciple":row.get("disciple",null),
            "hunt_policy":str(row.get("hunt_policy","auto")),
            "hunt_after_move":str(row.get("hunt_policy","auto")),
            "hunt_radius":float(row.get("hunt_radius",0.0))
        })
        var v63_disciple_actor: Dictionary = entries[entries.size()-1]
        for field in ["v63_skill_loadout","v63_skill_ready","v63_combat_enabled","v63_sword_combat_enabled","v63_blade_combat_enabled","v63_spear_combat_enabled","v63_dual_blade_combat_enabled","v63_palm_combat_enabled","v63_talisman_combat_enabled","v63_curse_combat_enabled","v63_formation_combat_enabled","v63_passive_ids","v63_combat_branch_id","v63_combat_lineage","v63_innate_skill_id","v63_basic_skill_id","basic_element","v63_divine_stage","v63_combat_generation","v63_blood_mode","v63_base_max_hp","v63_shield_received_factor","v63_spiritual_root_enabled","v63_root_global_all_damage_bonus"]:
            if row.has(field):
                v63_disciple_actor[field] = row[field].duplicate(true) if row[field] is Array or row[field] is Dictionary else row[field]
    for raw in monsters:
        if not (raw is Dictionary):
            return {"ok":false,"reason":"invalid_monster_entry"}
        var row: Dictionary = raw
        var actor_id := str(row.get("id",row.get("encounter_id","")))
        var stats: Dictionary = row.get("stats",{})
        var position: Vector2 = row.get("position",Vector2(-1.0,-1.0))
        var tier := str(row.get("tier",""))
        if actor_id.is_empty() or not _position_allowed(position) or not ["normal","elite","boss"].has(tier):
            return {"ok":false,"reason":"invalid_monster_actor"}
        if stats.is_empty() or float(stats.get("max_hp",0.0)) <= 0.0 or float(stats.get("attack",0.0)) <= 0.0:
            return {"ok":false,"reason":"invalid_monster_stats"}
        if keep_encounter_open:
            var slot := str(row.get("spawn_slot_id", ""))
            var generation := int(row.get("slot_generation", 0))
            if slot.is_empty() or generation <= 0 or _last_spawn_generation.has(slot):
                return {"ok":false,"reason":"invalid_initial_spawn_slot_or_generation"}
            if _last_spawn_generation.size() >= MAX_REMEMBERED_SPAWN_SLOTS:
                return {"ok":false,"reason":"spawn_slot_history_full"}
            _last_spawn_generation[slot] = generation
        entries.append({
            "id":actor_id,"side":"monster","party_id":"","role":"monster","tier":tier,
            "species_id":str(row.get("species_id","")),
            "race_id":str(row.get("race_id","")),
            "position":position,"stats":stats.duplicate(true),
            "hp":float(row.get("hp",stats["max_hp"])),
            "max_hp":float(stats["max_hp"]),
            "resistances":row.get("resistances",{}).duplicate(true),
            "primary_element":str(row.get("primary_element",row.get("element","neutral"))),
            "range":1.65 if tier == "boss" else 1.50,
            "move_speed":1.9 if tier == "boss" else 2.2,
            "next_basic":0.0,"next_skill":3.5 if tier == "boss" else 4.0,"guard_until":-1.0,
            "linked_disciple":null,"context_sources":[]
        })
        var v63_monster_actor: Dictionary = entries[entries.size()-1]
        for field in ["v63_boss_id","v63_custom_boss_ai","v63_combat_enabled","v63_boss_phase","v63_skill_ready","v63_boss_counter_window","v63_boss_break_gauge","v63_boss_stagger_until","v63_combat_lineage"]:
            if row.has(field):
                v63_monster_actor[field] = row[field].duplicate(true) if row[field] is Array or row[field] is Dictionary else row[field]
        if keep_encounter_open:
            entries[entries.size() - 1]["spawn_slot_id"] = str(row.get("spawn_slot_id", ""))
            entries[entries.size() - 1]["slot_generation"] = int(row.get("slot_generation", 0))
    entries.sort_custom(func(a,b): return str(a["id"]) < str(b["id"]))
    for actor in entries:
        var actor_id := str(actor["id"])
        if actors.has(actor_id) or float(actor["hp"]) <= 0.0 or float(actor["hp"]) > float(actor["max_hp"]):
            actors.clear()
            return {"ok":false,"reason":"duplicate_actor_or_invalid_monster_hp"}
        actors[actor_id] = actor
    active = true
    outcome = "fighting"
    _event("battle_start",{"encounter_id":id,"disciples":party.size(),"monsters":monsters.size()})
    if world_mode:
        auto_hunt = true
        for actor_value in actors.values():
            var world_actor: Dictionary = actor_value
            world_actor["home_position"] = world_actor["position"]
            if str(world_actor["side"]) == "monster":
                world_actor["patrol_phase"] = int(hash(str(world_actor.get("spawn_slot_id",""))) % 4)
            elif str(world_actor["side"]) == "disciple":
                world_actor["home_position"] = world_actor["position"]
    return {"ok":true,"encounter_id":id}

func setup_open_world(id: String, party: Array, monsters: Array, options: Dictionary) -> Dictionary:
    if not options.has("bounds") or not options.has("navigation"):
        return {"ok":false,"reason":"open_world_requires_real_navigation_grid"}
    _pending_world_options = options.duplicate(true)
    var ready := setup(id,party,monsters,true)
    _pending_world_options.clear()
    if not bool(ready.get("ok",false)):
        return ready
    return {"ok":true,"encounter_id":id,"world_bounds":world_bounds,
        "navigation_source_sha":str(world_navigation.get("source_blob_sha",""))}

func _validate_world_navigation() -> String:
    var width := int(world_navigation.get("width",0))
    var height := int(world_navigation.get("height",0))
    var blocked = world_navigation.get("blocked",null)
    if width < 2 or height < 2 or width > 1024 or height > 1024:
        return "invalid_open_world_navigation_size"
    if not (blocked is Array or blocked is PackedByteArray) or blocked.size() != width*height:
        return "invalid_open_world_blocked_grid"
    if not is_equal_approx(world_bounds.position.x,0.0) or not is_equal_approx(world_bounds.position.y,0.0) or not is_equal_approx(world_bounds.size.x,float(width)) or not is_equal_approx(world_bounds.size.y,float(height)):
        return "open_world_bounds_do_not_match_grid"
    if str(world_navigation.get("source_blob_sha","")).length() != 40:
        return "open_world_source_map_identity_missing"
    return ""

func is_world_position_allowed(position: Vector2) -> bool:
    return _position_allowed(position)

func _position_allowed(position: Vector2) -> bool:
    if not position.is_finite() or not world_bounds.has_point(position):
        return false
    if not world_mode or world_navigation.is_empty():
        return true
    var width := int(world_navigation["width"])
    var height := int(world_navigation["height"])
    var cell := Vector2i(floori(position.x),floori(position.y))
    if cell.x < 0 or cell.y < 0 or cell.x >= width or cell.y >= height:
        return false
    var blocked = world_navigation["blocked"]
    return int(blocked[cell.y*width+cell.x]) == 0

func order_group_move(actor_ids: Array, destination: Vector2,
        arrive_policy: String = "keep") -> Dictionary:
    if not ["keep","auto","hold"].has(arrive_policy):
        return {"ok":false,"reason":"invalid_arrival_hunt_policy"}
    if not world_mode or not active:
        return {"ok":false,"reason":"open_world_move_unavailable"}
    var ordered: Array[String] = []
    for raw_id in actor_ids:
        var id := str(raw_id)
        if actors.has(id) and str(actors[id].get("side","")) == "disciple" and float(actors[id].get("hp",0.0)) > 0.0 and not ordered.has(id):
            ordered.append(id)
    ordered.sort()
    if ordered.is_empty():
        return {"ok":false,"reason":"no_living_selected_disciple"}

    # Share one deterministic flood-fill result per connected walkable region.
    # This keeps snapped formation points reachable without repeating A* for
    # every candidate cell in the grid.
    var reachable_regions: Array[Dictionary] = []
    var actor_regions: Array[Dictionary] = []
    if not world_navigation.is_empty():
        for id in ordered:
            var actor: Dictionary = actors[id]
            var start_position: Vector2 = actor["position"]
            if not _position_allowed(start_position):
                return {"ok":false,"reason":"move_actor_not_on_walkable_world_cell","actor_id":id}
            var start_cell := Vector2i(floori(start_position.x),floori(start_position.y))
            var region: Dictionary = {}
            for known_region in reachable_regions:
                if known_region.has(start_cell):
                    region = known_region
                    break
            if region.is_empty():
                region = _world_reachable_cells(start_position)
                if region.is_empty():
                    return {"ok":false,"reason":"move_actor_has_no_reachable_world_cells","actor_id":id}
                reachable_regions.append(region)
            actor_regions.append(region)

    var base_origin := Vector2i(floori(destination.x),floori(destination.y))
    var base_cell := _nearest_walkable_unreserved_cell(base_origin,{},actor_regions)
    if base_cell.x < 0:
        return {"ok":false,"reason":"move_target_is_not_reachable"}
    var offsets := [Vector2i(0,0),Vector2i(1,0),Vector2i(0,1),Vector2i(-1,0),Vector2i(0,-1),Vector2i(1,1)]
    var reserved: Dictionary = {}
    var destinations: Array[Vector2] = []
    # Plan every destination before changing actor state. Formation offsets can
    # snap to the same walkable tile near rocks, streams or world bounds.
    for index in range(ordered.size()):
        var desired: Vector2i = base_cell+offsets[index%offsets.size()]
        var walkable := _nearest_walkable_unreserved_cell(
            desired,reserved,actor_regions,WORLD_MOVE_FORMATION_MIN_GAP_CELLS)
        if walkable.x < 0:
            return {"ok":false,"reason":"move_formation_has_insufficient_walkable_cells"}
        reserved[walkable] = true
        destinations.append(Vector2(walkable)+Vector2(0.5,0.5))
    for index in range(ordered.size()):
        var actor: Dictionary = actors[ordered[index]]
        actor["move_order_position"] = destinations[index]
        actor["move_order_active"] = true
        # "keep" preserves each actor's own policy in mixed solo/team orders.
        actor["hunt_after_move"] = str(actor.get("hunt_policy","auto")) \
            if arrive_policy == "keep" else arrive_policy
        _event("move_order",{"actor_id":ordered[index],"position":actor["move_order_position"]})
    return {"ok":true,"actor_ids":ordered,"destination":Vector2(base_cell)+Vector2(0.5,0.5)}
func set_disciple_hunt_policy(actor_ids: Array, policy: String) -> Dictionary:
    # Independent actor policy; no party membership is required. Validate
    # ALL requested actors before mutating any command, including on reload.
    if not world_mode or not active or not ["auto","hold"].has(policy):
        return {"ok":false,"reason":"invalid_individual_hunt_policy"}
    var ordered: Array[String] = []
    for raw_id in actor_ids:
        var id := str(raw_id)
        var actor: Dictionary = actors.get(id,{})
        if id.is_empty() or ordered.has(id) or actor.is_empty() \
                or str(actor.get("side","")) != "disciple" or float(actor.get("hp",0.0)) <= 0.0:
            return {"ok":false,"reason":"invalid_individual_hunt_member"}
        ordered.append(id)
    if ordered.is_empty():
        return {"ok":false,"reason":"no_selected_hunters"}
    ordered.sort()
    for id in ordered:
        var actor: Dictionary = actors[id]
        actor["hunt_policy"] = policy
        actor["hunt_after_move"] = policy
        actor["move_order_active"] = false
        actor["home_position"] = actor["position"]
        _event("individual_hunt_policy",{"actor_id":id,"policy":policy})
    return {"ok":true,"actor_ids":ordered,"policy":policy}

func set_auto_hunt(enabled: bool) -> Dictionary:
    if not world_mode or not active:
        return {"ok":false,"reason":"open_world_auto_unavailable"}
    auto_hunt = enabled
    _event("auto_hunt_changed",{"enabled":auto_hunt})
    return {"ok":true,"enabled":auto_hunt}

# Deterministic nearest-free formation slot. Uses the same ring priority as
# _nearest_walkable_cell, but skips reserved cells. Search includes the far
# edge because an offset may begin just outside the valid grid.
func _nearest_walkable_unreserved_cell(
        origin: Vector2i, reserved: Dictionary,
        reachable_regions: Array[Dictionary] = [],
        minimum_separation: float = 0.0) -> Vector2i:
    if not world_mode or world_navigation.is_empty():
        var fallback := _nearest_walkable_cell(origin)
        return fallback if fallback.x >= 0 and not reserved.has(fallback) else Vector2i(-1,-1)
    var width := int(world_navigation["width"])
    var height := int(world_navigation["height"])
    var blocked = world_navigation["blocked"]
    for radius in range(maxi(width,height)+1):
        for y in range(origin.y-radius,origin.y+radius+1):
            for x in range(origin.x-radius,origin.x+radius+1):
                if absi(x-origin.x) != radius and absi(y-origin.y) != radius:
                    continue
                if x < 0 or y < 0 or x >= width or y >= height:
                    continue
                var cell := Vector2i(x,y)
                if reserved.has(cell) or int(blocked[y*width+x]) != 0:
                    continue
                var separated := true
                if minimum_separation > 0.0:
                    for used_cell in reserved:
                        if Vector2(cell).distance_to(Vector2(used_cell)) < minimum_separation:
                            separated = false
                            break
                if not separated:
                    continue
                var reachable_from_every_actor := true
                for region in reachable_regions:
                    if not region.has(cell):
                        reachable_from_every_actor = false
                        break
                if reachable_from_every_actor:
                    return cell
    return Vector2i(-1,-1)
func _nearest_walkable_cell(origin: Vector2i) -> Vector2i:
    if not world_mode or world_navigation.is_empty():
        return origin if world_bounds.has_point(Vector2(origin)+Vector2(0.5,0.5)) else Vector2i(-1,-1)
    var width := int(world_navigation["width"])
    var height := int(world_navigation["height"])
    var blocked = world_navigation["blocked"]
    var maximum_radius := maxi(width,height)
    for radius in range(maximum_radius):
        for y in range(origin.y-radius,origin.y+radius+1):
            for x in range(origin.x-radius,origin.x+radius+1):
                if absi(x-origin.x) != radius and absi(y-origin.y) != radius:
                    continue
                if x < 0 or y < 0 or x >= width or y >= height:
                    continue
                if int(blocked[y*width+x]) == 0:
                    return Vector2i(x,y)
    return Vector2i(-1,-1)

func _world_path(start_position: Vector2, goal_position: Vector2) -> Array[Vector2i]:
    var started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
    var cache_key := ""
    if world_mode and not world_navigation.is_empty():
        var width := int(world_navigation.get("width",0))
        var height := int(world_navigation.get("height",0))
        cache_key = "%s:%d:%d:%d:%d:%d:%d" % [
            str(world_navigation.get("source_blob_sha","")),width,height,
            floori(start_position.x),floori(start_position.y),
            floori(goal_position.x),floori(goal_position.y)]
    var path: Array[Vector2i]
    if not cache_key.is_empty() and _world_path_cache.has(cache_key):
        path = (_world_path_cache[cache_key] as Array[Vector2i]).duplicate()
        performance_world_path_cache_hit_count += 1
    else:
        path = _world_path_impl(start_position,goal_position)
        if not cache_key.is_empty():
            if _world_path_cache.size() >= MAX_WORLD_PATH_CACHE_ENTRIES:
                var oldest: String = str(_world_path_cache_fifo.pop_front())
                _world_path_cache.erase(oldest)
            _world_path_cache[cache_key] = path.duplicate()
            _world_path_cache_fifo.append(cache_key)
    if performance_logging_enabled:
        var elapsed_usec := Time.get_ticks_usec()-started_usec
        performance_world_path_count += 1
        performance_world_path_usec_total += elapsed_usec
        performance_world_path_usec_max = maxi(performance_world_path_usec_max,elapsed_usec)
    return path

func _world_path_impl(start_position: Vector2, goal_position: Vector2) -> Array[Vector2i]:
    var start := _nearest_walkable_cell(Vector2i(floori(start_position.x),floori(start_position.y)))
    var goal := _nearest_walkable_cell(Vector2i(floori(goal_position.x),floori(goal_position.y)))
    var path: Array[Vector2i] = []
    if start.x < 0 or goal.x < 0:
        return path
    if start == goal:
        return path
    var width := int(world_navigation["width"])
    var height := int(world_navigation["height"])
    var cell_count := width*height
    var blocked = world_navigation["blocked"]
    var start_key := start.y*width+start.x
    var goal_key := goal.y*width+goal.x
    # Preserve the original N,W,E,S BFS order and exact shortest-path choice,
    # but replace per-cell Dictionary hashing/allocation with compact arrays.
    var previous := PackedInt32Array()
    previous.resize(cell_count)
    previous.fill(-2)
    var queue := PackedInt32Array()
    queue.resize(cell_count)
    var head := 0
    var tail := 1
    queue[0] = start_key
    previous[start_key] = -1
    var found := false
    while head < tail and not found:
        var key := queue[head]
        head += 1
        var next_key := key-width
        if key >= width and int(blocked[next_key]) == 0 and previous[next_key] == -2:
            previous[next_key] = key
            queue[tail] = next_key
            tail += 1
            found = next_key == goal_key
        if found:
            break
        var x := key%width
        if x > 0:
            next_key = key-1
            if int(blocked[next_key]) == 0 and previous[next_key] == -2:
                previous[next_key] = key
                queue[tail] = next_key
                tail += 1
                found = next_key == goal_key
        if found:
            break
        if x+1 < width:
            next_key = key+1
            if int(blocked[next_key]) == 0 and previous[next_key] == -2:
                previous[next_key] = key
                queue[tail] = next_key
                tail += 1
                found = next_key == goal_key
        if found:
            break
        next_key = key+width
        if key+width < cell_count and int(blocked[next_key]) == 0 and previous[next_key] == -2:
            previous[next_key] = key
            queue[tail] = next_key
            tail += 1
            found = next_key == goal_key
    if not found:
        return path
    var cursor := goal_key
    while cursor >= 0:
        path.push_front(Vector2i(cursor%width,int(cursor/width)))
        cursor = int(previous[cursor])
    return path
func _world_reachable_cells(start_position: Vector2) -> Dictionary:
    var reachable: Dictionary = {}
    if not world_mode or world_navigation.is_empty():
        return reachable
    if not _position_allowed(start_position):
        return reachable
    var width := int(world_navigation["width"])
    var height := int(world_navigation["height"])
    var blocked = world_navigation["blocked"]
    var start := Vector2i(floori(start_position.x),floori(start_position.y))
    var queue: Array[Vector2i] = [start]
    var head := 0
    reachable[start] = true
    var neighbors := [Vector2i(0,-1),Vector2i(-1,0),Vector2i(1,0),Vector2i(0,1)]
    while head < queue.size():
        var cell: Vector2i = queue[head]
        head += 1
        for offset in neighbors:
            var next: Vector2i = cell+offset
            if next.x < 0 or next.y < 0 or next.x >= width or next.y >= height:
                continue
            if int(blocked[next.y*width+next.x]) != 0 or reachable.has(next):
                continue
            reachable[next] = true
            queue.append(next)
    return reachable
func _world_route_distance(start_position: Vector2, path: Array[Vector2i]) -> float:
    if path.is_empty():
        return INF
    var distance := 0.0
    var previous := start_position
    for index in range(1,path.size()):
        var waypoint := Vector2(path[index])+Vector2(0.5,0.5)
        distance += previous.distance_to(waypoint)
        previous = waypoint
    return distance

func _move_world_actor(actor: Dictionary, destination: Vector2, speed: float, stop_distance: float = 0.0) -> bool:
    var position: Vector2 = actor["position"]
    # A* works on grid cells, while orders target cell centres. Finish the
    # remaining sub-cell movement when an actor and its goal share a valid cell.
    var current_cell := Vector2i(floori(position.x),floori(position.y))
    var goal_cell := Vector2i(floori(destination.x),floori(destination.y))
    if world_mode and current_cell == goal_cell:
        if not _position_allowed(position) or not _position_allowed(destination):
            return false
        if position.distance_to(destination) <= stop_distance+0.08:
            return false
        var local_step := minf(maxf(speed,0.0)*STEP_SECONDS,position.distance_to(destination))
        if local_step <= 0.0001:
            return false
        var local_position := position.move_toward(destination,local_step)
        if not _position_allowed(local_position):
            return false
        actor["position"] = local_position
        _event("move",{"actor_id":str(actor["id"]),"position":local_position,"world_path":true})
        return true
    var path := _world_path(position,destination)
    if path.is_empty():
        return false
    var remaining := _world_route_distance(position,path)
    if remaining <= stop_distance+0.08:
        return false
    var waypoint := Vector2(path[1])+Vector2(0.5,0.5) if path.size() > 1 else destination
    var delta := minf(maxf(speed,0.0)*STEP_SECONDS,position.distance_to(waypoint))
    if delta <= 0.0001:
        return false
    var moved := position.move_toward(waypoint,delta)
    if _position_allowed(moved):
        actor["position"] = moved
        _event("move",{"actor_id":str(actor["id"]),"position":moved,"world_path":true})
        return true
    return false

func _effective_move_speed(actor: Dictionary) -> float:
    var speed := maxf(0.0,float(actor.get("move_speed",2.0)))
    var slow: Dictionary = actor.get("status_effects",{}).get("slow",{})
    if not slow.is_empty() and now < float(slow.get("until",-1.0)):
        speed *= clampf(float(slow.get("movement_factor",1.0)),0.5,1.0)
    return speed

func step(viewed_map: bool = false) -> Dictionary:
    # viewed_map deliberately not consulted; same deterministic simulation.
    if not active:
        return {"ok":false,"reason":"encounter_not_active","outcome":outcome}
    # Up to MAX_MONSTERS can die in one step. Never silently lose a kill
    # because the presentation ring fills or consumers are not caught up.
    if continuous_mode and _pending_kill_events.size() + MAX_MONSTERS > MAX_PENDING_KILLS:
        return {"ok":false,"reason":"kill_journal_backpressure","pending":_pending_kill_events.size()}
    var performance_started_usec := Time.get_ticks_usec() if performance_logging_enabled else 0
    now += STEP_SECONDS
    _process_status_effects()
    V63HumanSkillCombatSystem.process_status_effects(self)
    _release_casts()
    var actor_ids: Array = actors.keys()
    actor_ids.sort()
    for id_value in actor_ids:
        var id := str(id_value)
        var actor: Dictionary = actors[id]
        if float(actor["hp"]) <= 0.0 or bool(actor.get("is_v63_summon",false)):
            continue
        if _count_alive("disciple") == 0 or (_count_alive("monster") == 0 and not continuous_mode):
            break
        # Pending cast commits an action and blocks another action by that actor.
        if _actor_casting(id):
            continue
        if world_mode and str(actor["side"]) == "disciple" and bool(actor.get("move_order_active",false)):
            var ordered_position: Vector2 = actor.get("move_order_position",actor["position"])
            if (actor["position"] as Vector2).distance_to(ordered_position) <= 0.45:
                actor["move_order_active"] = false
                actor["home_position"] = actor["position"]
                actor["hunt_policy"] = str(actor.get("hunt_after_move","auto"))
            else:
                _move_world_actor(actor,ordered_position,_effective_move_speed(actor))
                continue
        var holding := world_mode and str(actor["side"]) == "disciple" \
                and str(actor.get("hunt_policy","auto")) == "hold"
        var target: Dictionary = _nearest_enemy_in_range(actor,float(actor.get("range",1.5))) \
                if holding else _nearest_enemy(actor)
        if world_mode and str(actor["side"]) == "monster" and not target.is_empty():
            var aggro_range := float(actor.get("aggro_range",8.0))
            if (actor["position"] as Vector2).distance_to(target["position"]) > aggro_range:
                target = {}
        elif world_mode and str(actor["side"]) == "disciple" and not auto_hunt:
            target = _nearest_enemy_in_range(actor,float(actor.get("range",1.5)))
        if target.is_empty():
            if world_mode and str(actor["side"]) == "monster":
                _patrol_world_actor(actor)
            continue
        if str(actor["role"]) == "healer" and now >= float(actor["next_skill"]):
            if _heal_ally(actor):
                continue
        if str(actor["role"]) == "frontline" and now >= float(actor["next_skill"]):
            if _try_learned_skill(actor,target,true):
                continue
            if _guard_frontline(actor):
                continue
        if now >= float(actor["next_skill"]) and _try_learned_skill(actor,target):
            continue
        var distance := (actor["position"] as Vector2).distance_to(target["position"])
        var basic_attack_range := float(actor["range"])
        var attack_range := V63HumanSkillCombatSystem.preferred_offensive_range(actor)
        # No advancing into basic-attack range while an equipped ranged spell
        # already covers the target. Cast cooldown never causes a melee rush.
        if not world_mode and distance <= attack_range and distance > basic_attack_range:
            continue
        if world_mode:
            var path := _world_path(actor["position"],target["position"])
            var route_distance := 0.0 if floori((actor["position"] as Vector2).x) == floori((target["position"] as Vector2).x) and floori((actor["position"] as Vector2).y) == floori((target["position"] as Vector2).y) else _world_route_distance(actor["position"],path)
            if route_distance > attack_range+0.08:
                if holding:
                    continue
                _move_world_actor(actor,target["position"],_effective_move_speed(actor),attack_range)
                continue
            distance = route_distance
            if distance <= attack_range and distance > basic_attack_range:
                continue
        if distance > attack_range:
            if holding:
                continue
            var delta := minf(_effective_move_speed(actor)*STEP_SECONDS,maxf(0.0,distance-attack_range+0.02))
            if delta > 0.0:
                if world_mode:
                    _move_world_actor(actor,target["position"],_effective_move_speed(actor),attack_range)
                else:
                    var direction := ((target["position"] as Vector2)-(actor["position"] as Vector2)).normalized()
                    actor["position"] = _keep_inside((actor["position"] as Vector2)+direction*delta)
                    _event("move",{"actor_id":id,"position":actor["position"]})
            continue
        if now >= float(actor["next_skill"]):
            if (str(actor["tier"]) == "elite" or str(actor["tier"]) == "boss") and not bool(actor.get("v63_custom_boss_ai",false)):
                _begin_telegraphed_aoe(actor,target)
                continue
            if str(actor["role"]) == "mage" and _enemies_near(target,3.0)>=2:
                _cast_mage_aoe(actor,target)
                continue
        if now >= float(actor["next_basic"]):
            var action_stats: Dictionary = V63HumanSkillCombatSystem.effective_attack_stats(actor,actor.get("stats",{}))
            var interval := CombatStatsV2.effective_interval(
                1.65 if str(actor["side"]) == "monster" else float(actor.get("basic_interval",1.6)),
                float(action_stats.get("attack_speed",0.0))
            )
            if interval <= 0.0:
                # A -100% or worse attack-speed modifier disables basic hits;
                # keep checking at the simulation tick without creating debt.
                actor["next_basic"] = now+STEP_SECONDS
                continue
            _deal_direct(actor,target,float(actor.get("basic_ratio",1.0)),"basic",true,V63HumanSkillCombatSystem.basic_element(actor))
            # Carry fractional deadlines across grid checks without multi-hit catch-up.
            actor["next_basic"] = maxf(now+STEP_SECONDS,float(actor["next_basic"])+maxf(STEP_SECONDS,interval))
    if _count_alive("monster") == 0 and not continuous_mode:
        outcome = "win"
        active = false
    elif _count_alive("disciple") == 0 and not continuous_mode:
        outcome = "defeat"
        active = false
    elif now >= MAX_SECONDS and not continuous_mode:
        outcome = "timeout_retreat"
        active = false
    if not active:
        _event("battle_end",{"outcome":outcome,"elapsed":now,"downed_disciples":downed_disciples})
    if performance_logging_enabled:
        var elapsed_usec := Time.get_ticks_usec()-performance_started_usec
        performance_step_count += 1
        performance_step_usec_total += elapsed_usec
        performance_step_usec_max = maxi(performance_step_usec_max,elapsed_usec)
    return {"ok":true,"outcome":outcome,"time":now,"alive_disciples":_count_alive("disciple"),"alive_monsters":_count_alive("monster")}

func run(max_steps: int = 400, viewed_map: bool = false) -> Dictionary:
    var requested := maxi(max_steps, 0)
    var limit := MAX_CONTINUOUS_BATCH_STEPS if continuous_mode else int(ceil(MAX_SECONDS/STEP_SECONDS))+1
    for _step in range(mini(requested, limit)):
        if not active:
            break
        var result := step(viewed_map)
        if not bool(result.get("ok", false)):
            break
    return summary()

func summary() -> Dictionary:
    var remaining_hp := 0.0
    var remaining_max_hp := 0.0
    var positions: Dictionary = {}
    var ids: Array = actors.keys()
    ids.sort()
    for id in ids:
        var actor: Dictionary = actors[id]
        positions[str(id)] = actor["position"]
        if str(actor["side"]) == "disciple":
            remaining_hp += float(actor["hp"])
            remaining_max_hp += float(actor["max_hp"])
    return {
        "outcome":outcome,"time":now,"actions":actions,
        "alive_disciples":_count_alive("disciple"),"alive_monsters":_count_alive("monster"),
        "downed_disciples":downed_disciples,
        "disciple_remaining_hp_ratio":remaining_hp/maxf(remaining_max_hp,1.0),
        "positions":positions,"events":events.duplicate(true)
    }

func add_continuous_monster(row: Dictionary) -> Dictionary:
    if not continuous_mode or not active:
        return {"ok":false,"reason":"continuous_encounter_not_active"}
    if _count_monster_records() >= MAX_MONSTERS:
        return {"ok":false,"reason":"monster_cap_reached"}
    var actor_id := str(row.get("id", row.get("encounter_id", "")))
    var stats: Dictionary = row.get("stats", {})
    var position: Vector2 = row.get("position", Vector2(-1.0, -1.0))
    var tier := str(row.get("tier", ""))
    var race_id := str(row.get("race_id", ""))
    if actor_id.is_empty() or actors.has(actor_id) or not _position_allowed(position):
        return {"ok":false,"reason":"invalid_continuous_monster_identity_or_position"}
    var slot_id := str(row.get("spawn_slot_id", ""))
    var generation := int(row.get("slot_generation", 0))
    if slot_id.is_empty() or generation <= 0:
        return {"ok":false,"reason":"missing_spawn_slot_generation"}
    if generation <= int(_last_spawn_generation.get(slot_id, 0)):
        return {"ok":false,"reason":"stale_spawn_generation"}
    if not _last_spawn_generation.has(slot_id) and _last_spawn_generation.size() >= MAX_REMEMBERED_SPAWN_SLOTS:
        return {"ok":false,"reason":"spawn_slot_history_full"}
    if not ["normal", "elite", "boss"].has(tier) or stats.is_empty():
        return {"ok":false,"reason":"invalid_continuous_monster_tier_or_stats"}
    if float(stats.get("max_hp", 0.0)) <= 0.0 or float(stats.get("attack", 0.0)) <= 0.0:
        return {"ok":false,"reason":"invalid_continuous_monster_stats"}
    if not CombatContextEffectsV2.TIERS.has(tier) or not CombatContextEffectsV2.RACES.has(race_id):
        return {"ok":false,"reason":"invalid_continuous_monster_catalogue_identity"}
    var actor := {
        "id":actor_id,"side":"monster","party_id":"","role":"monster","tier":tier,
        "species_id":str(row.get("species_id", "")),"race_id":race_id,
        "position":position,"stats":stats.duplicate(true),"hp":float(row.get("hp", stats["max_hp"])),
        "max_hp":float(stats["max_hp"]),"resistances":row.get("resistances", {}).duplicate(true),
        "primary_element":str(row.get("primary_element",row.get("element","neutral"))),
        "range":1.65 if tier == "boss" else 1.50,"move_speed":1.9 if tier == "boss" else 2.2,
        "next_basic":now,"next_skill":now + (3.5 if tier == "boss" else 4.0),
        "guard_until":-1.0,"spawn_slot_id":str(row.get("spawn_slot_id", "")),
        "slot_generation":int(row.get("slot_generation", 0)),"linked_disciple":null,
        "context_sources":[],"home_position":row.get("home_position",position),
        "patrol_phase":int(row.get("patrol_phase",hash(slot_id)%4)),"aggro_range":float(row.get("aggro_range",8.0))
    }
    if float(actor["hp"]) <= 0.0 or float(actor["hp"]) > float(actor["max_hp"]):
        return {"ok":false,"reason":"invalid_continuous_monster_hp"}
    actors[actor_id] = actor
    _last_spawn_generation[slot_id] = generation
    _event("monster_spawned", {"actor_id":actor_id,"spawn_slot_id":actor["spawn_slot_id"],
        "slot_generation":actor["slot_generation"],"species_id":actor["species_id"]})
    return {"ok":true,"actor_id":actor_id,"active_monsters":_count_alive("monster")}

func add_world_disciple(row: Dictionary) -> Dictionary:
    # Late joining is one explicit human actor, not a second encounter or
    # a spawned fixture. The owner must first validate the canonical recruit.
    if not world_mode or not continuous_mode or not active:
        return {"ok":false,"reason":"p0_join_requires_live_world"}
    var actor_id := str(row.get("id",""))
    var party_id := str(row.get("party_id",""))
    var role := str(row.get("role",""))
    var pos = row.get("position",null)
    var stats = row.get("stats",{})
    if actor_id.is_empty() or actors.has(actor_id) or party_id.is_empty() \
            or not ["frontline","ranged","mage","healer"].has(role) \
            or not (pos is Vector2) or not is_world_position_allowed(pos) \
            or not (stats is Dictionary) or stats.is_empty():
        return {"ok":false,"reason":"p0_invalid_join_identity_or_position"}
    var existing_people := 0
    var existing_party := 0
    for actor_value in actors.values():
        var prior: Dictionary = actor_value
        if str(prior.get("side","")) != "disciple":
            continue
        existing_people += 1
        if str(prior.get("party_id","")) == party_id:
            existing_party += 1
    if existing_people >= MAX_DISCIPLES:
        return {"ok":false,"reason":"p0_world_hunter_cap"}
    if existing_party >= 6:
        return {"ok":false,"reason":"p0_voluntary_party_full"}
    var max_hp := float(stats.get("max_hp",0.0))
    var hp := float(row.get("hp",max_hp))
    if not is_finite(hp) or not is_finite(max_hp) or max_hp <= 0.0 \
            or hp <= 0.0 or hp > max_hp \
            or float(stats.get("attack",0.0)) <= 0.0:
        return {"ok":false,"reason":"p0_invalid_join_combat_stats"}
    var added: Dictionary = {
        "id":actor_id,"side":"disciple","party_id":party_id,
        "role":role,"tier":"disciple","race_id":"nhan_toc",
        "position":pos,"home_position":pos,
        "stats":stats.duplicate(true),"hp":hp,"max_hp":max_hp,
        "resistances":row.get("resistances",{}).duplicate(true),
        "primary_element":str(row.get("primary_element","neutral")),
        "range":float(row.get("basic_range",default_basic_range_for_role(role))),
        "move_speed":float(row.get("move_speed",2.35 if role == "frontline" else 2.05)),
        "basic_ratio":float(row.get("basic_ratio",1.0)),
        "basic_interval":float(row.get("basic_interval",1.6)),
        "skill_loadout":row.get("skill_loadout",[]).duplicate(true),
        "skill_factors":row.get("skill_factors",{}).duplicate(true),
        "skill_ready":{},
        "context_sources":row.get("context_sources",[]).duplicate(true),
        "next_basic":now,"next_skill":now,
        "guard_until":-1.0,"learned_guard_until":-1.0,
        "learned_guard_factor":1.0,"status_effects":{},
        "linked_disciple":null,
        "hunt_policy":"auto","hunt_after_move":"auto",
        "hunt_radius":P0_LOCAL_HUNT_RADIUS
    }
    # Preserve the exact optional V6.3 loadout attached by the canonical
    # human-skill author, never re-roll it on joining an ongoing world.
    for field in ["v63_skill_loadout","v63_skill_ready","v63_combat_enabled",
            "v63_talisman_combat_enabled","v63_curse_combat_enabled","v63_formation_combat_enabled","v63_passive_ids","v63_combat_branch_id","v63_combat_lineage",
            "v63_innate_skill_id","v63_basic_skill_id","basic_element",
            "v63_divine_stage","v63_combat_generation","v63_blood_mode",
            "v63_base_max_hp","v63_shield_received_factor",
            "v63_spiritual_root_enabled","v63_root_global_all_damage_bonus"]:
        if row.has(field):
            added[field] = row[field].duplicate(true) \
                if row[field] is Array or row[field] is Dictionary else row[field]
    actors[actor_id] = added
    _event("disciple_joined_world",{
        "actor_id":actor_id,"party_id":party_id,"position":pos})
    return {"ok":true,"actor_id":actor_id,"participants":existing_people+1}

func withdraw_world_disciple(actor_id: String) -> Dictionary:
    # Preserve all outstanding combat authority: a dying monster's pending
    # journal could still credit this killer, while orphaned casts/DoT would
    # invalidate the saved battle on cold reload. Refuse until it settles.
    if not world_mode or not continuous_mode or not active \
            or not actors.has(actor_id):
        return {"ok":false,"reason":"p0_no_active_world_participant"}
    var actor: Dictionary = actors[actor_id]
    if str(actor.get("side","")) != "disciple":
        return {"ok":false,"reason":"p0_withdraw_only_disciple"}
    var others_alive := 0
    for other_id in actors.keys():
        var other: Dictionary = actors[other_id]
        if str(other.get("side","")) == "disciple" \
                and str(other_id) != actor_id and float(other.get("hp",0.0)) > 0.0:
            others_alive += 1
    if others_alive == 0:
        return {"ok":false,"reason":"p0_last_hunter_use_return_to_sect"}
    if not _pending_kill_events.is_empty():
        return {"ok":false,"reason":"p0_pending_kill_must_settle_before_withdraw"}
    for cast_value in pending_casts:
        var cast: Dictionary = cast_value
        if str(cast.get("caster","")) == actor_id \
                or str(cast.get("target_id","")) == actor_id:
            return {"ok":false,"reason":"p0_member_has_pending_cast"}
    for target_value in actors.values():
        var target: Dictionary = target_value
        var statuses: Dictionary = target.get("status_effects",{})
        for key in statuses.keys():
            if str(key) == "v63_poison":
                for value in statuses[key]:
                    if str(value.get("owner_id","")) == actor_id:
                        return {"ok":false,"reason":"p0_member_poison_still_active"}
            elif statuses[key] is Dictionary \
                    and str(statuses[key].get("caster","")) == actor_id:
                return {"ok":false,"reason":"p0_member_status_still_active"}
    actors.erase(actor_id)
    _event("disciple_withdrew_world",{
        "actor_id":actor_id,"remaining_alive":others_alive})
    return {"ok":true,"actor_id":actor_id,"remaining_alive":others_alive}

func suspend_world_monster(actor_id: String) -> Dictionary:
    # Remove the live AI actor WITHOUT destroying its slot generation.
    # The owner stores the full actor snapshot in a dormant zone ledger.
    if not world_mode or not continuous_mode or not active or not actors.has(actor_id):
        return {"ok":false,"reason":"p0_suspend_requires_active_world_monster"}
    var actor: Dictionary = actors[actor_id]
    if str(actor.get("side","")) != "monster":
        return {"ok":false,"reason":"p0_suspend_not_monster"}
    for event in _pending_kill_events:
        if str(event.get("monster_instance_id","")) == actor_id:
            return {"ok":false,"reason":"p0_suspend_pending_kill"}
    actors.erase(actor_id)
    var safe_casts: Array = []
    for cast in pending_casts:
        if str(cast.get("caster","")) == actor_id or str(cast.get("target_id","")) == actor_id:
            continue
        safe_casts.append(cast)
    pending_casts = safe_casts
    return {"ok":true,"slot_id":str(actor.get("spawn_slot_id",""))}

func reactivate_world_monster(row: Dictionary) -> Dictionary:
    # Rehydrate a genuinely existing slot/life (not a new spawn and NOT loot).
    var id := str(row.get("id",""))
    var slot := str(row.get("spawn_slot_id",""))
    var generation := int(row.get("slot_generation",0))
    var at = row.get("position",null)
    var stats = row.get("stats",{})
    if not world_mode or not continuous_mode or not active or id.is_empty() or slot.is_empty() \
            or actors.has(id) or _count_monster_records() >= MAX_MONSTERS \
            or str(row.get("side","")) != "monster" or generation <= 0 \
            or generation != int(_last_spawn_generation.get(slot,0)) \
            or not (at is Vector2) or not _position_allowed(at) \
            or not (stats is Dictionary) or float(stats.get("max_hp",0.0)) <= 0.0 \
            or float(row.get("hp",0.0)) <= 0.0 \
            or float(row.get("hp",0.0)) > float(row.get("max_hp",0.0)):
        return {"ok":false,"reason":"p0_invalid_dormant_life"}
    for other in actors.values():
        if str(other.get("side","")) == "monster" \
                and str(other.get("spawn_slot_id","")) == slot:
            return {"ok":false,"reason":"p0_duplicate_active_spawn_slot"}
    var restored: Dictionary = row.duplicate(true)
    restored["linked_disciple"] = null
    actors[id] = restored
    _event("monster_reactivated",{"actor_id":id,"spawn_slot_id":slot,"generation":generation})
    return {"ok":true,"actor_id":id}

func remove_downed_monster(actor_id: String) -> bool:
    if not continuous_mode or not actors.has(actor_id):
        return false
    var actor: Dictionary = actors[actor_id]
    if str(actor.get("side", "")) != "monster" or float(actor.get("hp", 1.0)) > 0.0:
        return false
    actors.erase(actor_id)
    var remaining: Array = []
    for cast in pending_casts:
        if str(cast.get("caster", "")) == actor_id or str(cast.get("target_id", "")) == actor_id:
            continue
        remaining.append(cast)
    pending_casts = remaining
    return true

func apply_continuous_damage_tick(
    attacker_id: String, target_id: String, tick_id: String, ratio: float, element: String = ""
) -> Dictionary:
    if not continuous_mode or not active or tick_id.is_empty() or ratio < 0.0:
        return {"ok":false,"reason":"invalid_continuous_damage_tick"}
    if _external_hit_ids.has(tick_id):
        return {"ok":false,"reason":"duplicate_damage_tick"}
    if _external_hit_ids.size() >= MAX_EXTERNAL_DAMAGE_IDS:
        return {"ok":false,"reason":"damage_tick_ledger_full"}
    if _pending_kill_events.size() + MAX_MONSTERS > MAX_PENDING_KILLS:
        return {"ok":false,"reason":"kill_journal_backpressure"}
    if not actors.has(attacker_id) or not actors.has(target_id):
        return {"ok":false,"reason":"unknown_damage_tick_actor"}
    var attacker: Dictionary = actors[attacker_id]
    var target: Dictionary = actors[target_id]
    if str(attacker.get("side", "")) == str(target.get("side", "")):
        return {"ok":false,"reason":"friendly_damage_tick"}
    var before := float(target["hp"])
    var damage := _deal_direct(attacker, target, ratio, "dot", false, element, false)
    if damage <= 0.0:
        return {"ok":false,"reason":"damage_tick_not_applied"}
    _external_hit_ids[tick_id] = true
    _event("damage_tick", {"tick_id":tick_id,"attacker":attacker_id,"target":target_id,
        "damage":damage,"source":"dot"})
    return {"ok":true,"tick_id":tick_id,"damage":damage,"hp_before":before,"hp_after":float(target["hp"])}

func _nearest_enemy(actor: Dictionary) -> Dictionary:
    var best: Dictionary = {}
    var best_distance := INF
    var ids: Array = actors.keys()
    ids.sort()
    for id in ids:
        var other: Dictionary = actors[id]
        if str(other["side"]) == str(actor["side"]) or float(other["hp"]) <= 0.0:
            continue
        var distance := (actor["position"] as Vector2).distance_squared_to(other["position"])
        # Independent local hunters do not cross the entire 192x192 world
        # simply because another zone has the nearest living monster.
        if world_mode and str(actor.get("side","")) == "disciple":
            var radius := float(actor.get("hunt_radius",0.0))
            if radius > 0.0 and distance > radius*radius:
                continue
        if distance+0.00001 < best_distance:
            best = other
            best_distance = distance
    return best

func _nearest_enemy_in_range(actor: Dictionary, max_range: float) -> Dictionary:
    var target := _nearest_enemy(actor)
    if target.is_empty() or (actor["position"] as Vector2).distance_to(target["position"]) > maxf(max_range,0.0):
        return {}
    return target

func _patrol_world_actor(actor: Dictionary) -> void:
    var home: Vector2 = actor.get("home_position",actor["position"])
    var directions := [Vector2(2.0,0.0),Vector2(0.0,2.0),Vector2(-2.0,0.0),Vector2(0.0,-2.0)]
    var phase := posmod(int(floor(now/4.0))+int(actor.get("patrol_phase",0)),directions.size())
    var destination: Vector2 = home+directions[phase]
    var snap := _nearest_walkable_cell(Vector2i(floori(destination.x),floori(destination.y)))
    if snap.x < 0:
        return
    destination = Vector2(snap)+Vector2(0.5,0.5)
    if (actor["position"] as Vector2).distance_to(destination) > 0.55:
        _move_world_actor(actor,destination,float(actor.get("move_speed",2.0)))

func _heal_ally(actor: Dictionary) -> bool:
    var candidates: Array = []
    for ally in actors.values():
        if str(ally["side"]) != str(actor["side"]) or float(ally["hp"]) <= 0.0:
            continue
        # Ordinary party healing is not an encounter-wide buff.
        if str(ally["party_id"]) != str(actor["party_id"]):
            continue
        if float(ally["hp"])/maxf(1.0,float(ally["max_hp"])) >= 0.65:
            continue
        if (ally["position"] as Vector2).distance_to(actor["position"]) > 6.0:
            continue
        candidates.append(ally)
    if candidates.is_empty():
        return false
    candidates.sort_custom(func(a,b):
        var ar := float(a["hp"])/float(a["max_hp"])
        var br := float(b["hp"])/float(b["max_hp"])
        return str(a["id"]) < str(b["id"]) if absf(ar-br)<0.000001 else ar<br
    )
    var target: Dictionary = candidates[0]
    var healed := minf(float(target["max_hp"])-float(target["hp"]),float(actor["stats"]["attack"])*1.80)
    target["hp"] = minf(float(target["max_hp"]),float(target["hp"])+healed)
    _sync_linked_hp(target)
    actor["next_skill"] = now+5.0
    _event("heal",{"caster":actor["id"],"target":target["id"],"amount":healed})
    actions += 1
    return true

func _guard_frontline(actor: Dictionary) -> bool:
    var ratio := float(actor["hp"])/maxf(1.0,float(actor["max_hp"]))
    if ratio >= 0.75 or now < float(actor.get("learned_guard_until",-1.0)):
        return false
    actor["guard_until"] = now+4.0
    actor["next_skill"] = now+9.0
    _event("guard",{"actor_id":actor["id"],"until":float(actor["guard_until"])})
    actions += 1
    return true

func _deal_direct(attacker: Dictionary, target: Dictionary, ratio: float, kind: String, eligible_lifesteal: bool, damage_element: String = "", can_crit: bool = true, source_skill_id: String = "", cast_event_context: Dictionary = {}) -> float:
    if float(attacker["hp"]) <= 0.0 or float(target["hp"]) <= 0.0:
        return 0.0
    if kind not in ["dot","v63_poison"] and now < float(target.get("v63_evasion_until",-1.0)) and str(attacker.get("side","")) != str(target.get("side","")):
        _event("evade",{"attacker":str(attacker.get("id","")),"target":str(target.get("id","")),"kind":kind,"until":float(target.get("v63_evasion_until",-1.0))})
        return 0.0
    attacker["v63_combat_clock"] = now
    var target_hp_before := float(target["hp"])
    var a_stats: Dictionary = V63HumanSkillCombatSystem.effective_attack_stats(attacker,attacker["stats"])
    var t_stats: Dictionary = V63HumanSkillCombatSystem.effective_defense_stats(target,target["stats"])
    var unguarded_t_stats: Dictionary = t_stats.duplicate(true)
    var original_ratio := ratio
    var context: Dictionary = {"ok":true,"outgoing_damage_factor":1.0,
        "basic_followup_chance":0.0,"basic_followup_ratio":0.0}
    if str(attacker["side"]) == "disciple" and str(target["side"]) == "monster":
        context = CombatContextEffectsV2.resolve_context(
            attacker.get("context_sources",[]),target,
            "basic" if kind == "basic" else "skill"
        )
        if not bool(context.get("ok",false)):
            return 0.0
        ratio *= float(context["outgoing_damage_factor"])
    var resolved_skill_id := source_skill_id
    if resolved_skill_id.is_empty() and kind == "basic":
        resolved_skill_id = str(attacker.get("v63_basic_skill_id",""))
    ratio *= V63HumanSkillCombatSystem.marked_damage_factor(attacker,target,now,resolved_skill_id)
    var guard_factor := 1.0
    if now < float(target.get("guard_until",-1.0)):
        guard_factor = 0.65
    if now < float(target.get("learned_guard_until",-1.0)):
        guard_factor = minf(guard_factor,float(target.get("learned_guard_factor",1.0)))
    if guard_factor < 1.0:
        t_stats = t_stats.duplicate(true)
        var previous_reduction := clampf(float(t_stats.get("damage_reduction",0.0)),0.0,1.0)
        t_stats["damage_reduction"] = 1.0-(1.0-previous_reduction)*guard_factor
    var weaken: Dictionary = attacker.get("status_effects",{}).get("weaken",{})
    if not weaken.is_empty() and now < float(weaken.get("until",-1.0)):
        ratio *= float(weaken.get("factor",1.0))
    if bool(attacker.get("v63_spiritual_root_enabled",false)):
        ratio *= 1.0 + clampf(float(attacker.get("v63_root_global_all_damage_bonus",0.0)),0.0,0.2)
    var crit := false
    if can_crit and kind != "basic_followup":
        crit = rng.chance(CombatStatsV2.effective_crit_chance(a_stats,t_stats))
    var matchup_factor := 1.0
    if bool(attacker.get("v63_spiritual_root_enabled",false)):
        matchup_factor = V63SpiritualRootEvaluator.elemental_matchup_factor(
            damage_element,str(target.get("primary_element","neutral")))
    var hit := CombatStatsV2.resolve_direct_hit(
        a_stats,t_stats,target["resistances"],ratio,crit,damage_element,matchup_factor,can_crit
    )
    if not bool(hit.get("ok",false)):
        return 0.0
    var shield_remaining := maxf(0.0,float(target.get("v63_capacity_shield_remaining",0.0)))
    var shield_absorbed := 0.0
    var shield_skill_id := str(target.get("v63_capacity_shield_skill_id",""))
    if shield_remaining > 0.0 and now >= float(target.get("v63_capacity_shield_until",-1.0)):
        target["v63_capacity_shield_remaining"] = 0.0
        shield_remaining = 0.0
    if shield_remaining > 0.0:
        shield_absorbed = minf(shield_remaining,maxf(0.0,float(hit.get("damage",0.0))))
        if shield_absorbed > 0.0:
            hit["damage"] = maxf(0.0,float(hit.get("damage",0.0))-shield_absorbed)
            target["v63_capacity_shield_remaining"] = maxf(0.0,shield_remaining-shield_absorbed)
    var sword_reflect_ratio := V63SwordSkillCombatSystem.guard_reflection_ratio(target,now) if guard_factor < 1.0 else 0.0
    var blade_reflect_profile := V63BladeSkillCombatSystem.guard_reflection_profile(target,now) if guard_factor < 1.0 else {"ratio":0.0,"skill_id":""}
    var blade_reflect_ratio := float(blade_reflect_profile.get("ratio",0.0))
    var sword_absorbed_damage := 0.0
    var blade_absorbed_damage := 0.0
    if (sword_reflect_ratio > 0.0 or blade_reflect_ratio > 0.0) and kind not in ["dot","v63_poison","basic_followup","v63_sword_absorbed_reflect","v63_blade_absorbed_reflect"]:
        var unguarded_hit := CombatStatsV2.resolve_direct_hit(
            a_stats,unguarded_t_stats,target["resistances"],ratio,crit,damage_element,matchup_factor,can_crit
        )
        if bool(unguarded_hit.get("ok",false)):
            var absorbed_damage := maxf(0.0,
                minf(target_hp_before,float(unguarded_hit.get("damage",0.0))) -
                minf(target_hp_before,float(hit.get("damage",0.0))))
            if sword_reflect_ratio > 0.0:
                sword_absorbed_damage = absorbed_damage
            if blade_reflect_ratio > 0.0:
                blade_absorbed_damage = absorbed_damage
    var settlement := CombatStatsV2.settle_damage_and_lifesteal(
        hit,a_stats,t_stats,float(attacker["hp"]),float(attacker["max_hp"]),
        float(target["hp"]),eligible_lifesteal
    )
    if not bool(settlement.get("ok",false)):
        return 0.0
    var actual_damage := float(settlement["actual_damage"])
    target["hp"] = float(settlement["target_hp_after"])
    if shield_absorbed > 0.0:
        var shield_event := "v63_palm_guard_absorbed" if shield_skill_id.begins_with("tmb.skill.palm.") else "v63_spear_shield_absorbed"
        _event(shield_event,{"caster":str(attacker.get("id","")),"target":str(target.get("id","")),"skill_id":shield_skill_id,"absorbed_damage":shield_absorbed,"remaining_capacity":float(target.get("v63_capacity_shield_remaining",0.0))})
    # Poison Dược healing budget may spend only verified damage committed by this battle.
    # Receipts are carried by the existing actor snapshot, never inferred from missing HP.
    V63PoisonEvolutionV1.record_damage_taken(target, actual_damage, now)
    if (float(target.hp) <= 0.0 and bool(target.get("v63_combat_enabled", false)) and
        V63DivineSkillCombatSystem.prevent_lethal(self, target)):
        target["hp"] = 1.0
    attacker["hp"] = float(settlement["attacker_hp_after"])
    V63HumanSkillCombatSystem.observe_boss_damage(self,target,target_hp_before,attacker,damage_element,kind)
    _sync_linked_hp(attacker)
    _sync_linked_hp(target)
    actions += 1
    var hit_event := {"attacker":attacker["id"],"target":target["id"],"damage":actual_damage,
        "kind":kind,"critical":crit,"lifesteal":settlement["lifesteal_heal"],
        "attacker_position":attacker.get("position",Vector2.ZERO),"target_position":target.get("position",Vector2.ZERO)}
    hit_event.merge(cast_event_context,true)
    if cast_event_context.has("cast_id"):
        hit_event["caster"] = str(attacker.get("id",""))
        hit_event["target_id"] = str(target.get("id",""))
        hit_event["caster_position"] = attacker.get("position",Vector2.ZERO)
    _event("hit",hit_event)
    if actual_damage > 0.0 and resolved_skill_id.begins_with("tmb.skill.blade."):
        var target_marks: Dictionary = target.get("v63_marks",{})
        var owned_mark: Dictionary = target_marks.get(str(attacker.get("id","")),{})
        if str(owned_mark.get("school","")) == "blade":
            V63HumanSkillCombatSystem._consume_mark(self,attacker,target,resolved_skill_id)
    if bool(target.get("v63_combat_enabled", false)):
        V63DivineSkillCombatSystem.reflect_committed(self, target, attacker, actual_damage, kind)
    if sword_absorbed_damage > 0.0:
        V63SwordSkillCombatSystem.reflect_absorbed(self,target,attacker,sword_absorbed_damage,damage_element)
    if blade_absorbed_damage > 0.0:
        V63BladeSkillCombatSystem.reflect_absorbed(self,target,attacker,blade_absorbed_damage,damage_element)
    if float(target["hp"]) <= 0.0:
        if continuous_mode and str(target["side"]) == "monster":
            _record_monster_kill(attacker, target, kind, actual_damage)
        var downed_row := {"actor_id":target["id"],"side":target["side"]}
        if continuous_mode:
            downed_row["death_id"] = "%s:%s" % [encounter_id,str(target["id"])]
        _event("downed",downed_row)
        if str(target["side"]) == "disciple" and not bool(target.get("is_v63_summon",false)):
            downed_disciples += 1
    # Only one nonrecursive bonus hit from a true ordinary basic attack.
    # It cannot lifesteal, crit by default, or proc any further followup.
    if (kind == "basic" and float(target["hp"]) > 0.0 and
        CombatContextEffectsV2.roll_basic_followup(rng,context,"basic",float(target["hp"]))):
        _deal_direct(attacker,target,
            original_ratio*float(context["basic_followup_ratio"]),
            "basic_followup",false,damage_element)
    return actual_damage

# S1 activates learned damage, burn, weaken and self-guard skills.
# Dash and fire_combo require separate action semantics and remain deferred.
func _try_learned_skill(actor: Dictionary, target: Dictionary, guard_only: bool = false) -> bool:
    if V63HumanSkillCombatSystem.handles_actor(actor):
        if V63HumanSkillCombatSystem.try_cast(self,actor,target,guard_only):
            return true
        if bool(actor.get("v63_custom_boss_ai",false)):
            return false
    var skills: Array = actor.get("skill_loadout",[])
    var ready: Dictionary = actor.get("skill_ready",{})
    for raw_id in skills:
        var skill_id := str(raw_id)
        var data: Dictionary = CombatSkillSystem.SKILLS.get(skill_id,{})
        var effect := str(data.get("effect",""))
        if not ["damage","burn","weaken","guard"].has(effect):
            continue
        if guard_only and (effect != "guard" or not bool(data.get("self_target",false))):
            continue
        if now < float(ready.get(skill_id,0.0)):
            continue
        var self_cast := effect == "guard" and bool(data.get("self_target",false))
        if self_cast:
            if float(actor["hp"])/maxf(1.0,float(actor["max_hp"])) >= 0.75:
                continue
            if now < float(actor.get("learned_guard_until",-1.0)):
                continue
        elif (actor["position"] as Vector2).distance_to(target["position"]) > float(data.get("range",0.0)):
            continue
        var caster_id := str(actor["id"])
        var caster_stats: Dictionary = actor.get("stats",{})
        var cast_rate := maxf(0.1,1.0+float(caster_stats.get("cast_speed",0.0)))
        var cooldown_rate := maxf(0.1,1.0+float(caster_stats.get("cooldown_recovery",0.0)))
        var cast_seconds := maxf(STEP_SECONDS,float(data.get("cast_time",STEP_SECONDS))/cast_rate)
        var distance := 0.0 if self_cast else (actor["position"] as Vector2).distance_to(target["position"])
        var projectile_speed := float(data.get("projectile_speed",0.0))
        var travel := distance/projectile_speed if projectile_speed > 0.0 else 0.0
        var ready_at := now+cast_seconds+travel
        var multiplier := float(actor.get("skill_factors",{}).get(skill_id,1.0))
        pending_casts.append({
            "caster":caster_id,"target_id":caster_id if self_cast else str(target["id"]),
            "skill_id":skill_id,"ready":ready_at,
            "ratio":float(data.get("damage_ratio",0.0))*multiplier,
            "element":str(data.get("element",""))
        })
        ready[skill_id] = now+maxf(STEP_SECONDS,float(data.get("cooldown",0.0))/cooldown_rate)
        actor["skill_ready"] = ready
        _event("skill_cast",{"actor_id":caster_id,"target":caster_id if self_cast else target["id"],
            "skill_id":skill_id,"release_at":ready_at})
        actions += 1
        return true
    return false

# S1 statuses live on the authoritative actor, not the presentation event ring.
func _apply_skill_status(caster: Dictionary, target: Dictionary, skill_id: String, definition: Dictionary) -> void:
    var effect := str(definition.get("effect",""))
    if not ["burn","weaken"].has(effect):
        return
    var statuses: Dictionary = target.get("status_effects",{})
    var duration := maxf(0.0,float(definition.get("burn_duration" if effect == "burn" else "weaken_duration",0.0)))
    var row := {"caster":str(caster["id"]),"skill_id":skill_id,"until":now+duration}
    if effect == "burn":
        row["ratio"] = maxf(0.0,float(definition.get("burn_ratio",0.0)))
        row["next_tick"] = now+1.0
    else:
        row["factor"] = clampf(float(definition.get("weaken_multiplier",1.0)),0.01,1.0)
    # Only one strongest effect of each family, never an unlimited stack.
    var existing: Dictionary = statuses.get(effect,{})
    if existing.is_empty() or (effect == "burn" and float(row.get("ratio",0.0)) >= float(existing.get("ratio",0.0))) or (effect == "weaken" and float(row.get("factor",1.0)) <= float(existing.get("factor",1.0))):
        statuses[effect] = row
        target["status_effects"] = statuses
        _event("status_applied",{"caster":caster["id"],"target":target["id"],"status":effect,"skill_id":skill_id,"until":row["until"]})

func _process_status_effects() -> void:
    var actor_ids: Array = actors.keys()
    actor_ids.sort()
    for raw_id in actor_ids:
        var target: Dictionary = actors[raw_id]
        if float(target["hp"]) <= 0.0:
            continue
        var statuses: Dictionary = target.get("status_effects",{})
        if statuses.has("burn"):
            var burn: Dictionary = statuses["burn"]
            var caster: Dictionary = actors.get(str(burn.get("caster","")),{})
            if caster.is_empty() or float(caster.get("hp",0.0)) <= 0.0:
                statuses.erase("burn")
            else:
                var due := float(burn.get("next_tick",INF))
                var until := float(burn.get("until",-1.0))
                if due <= now+0.000001 and due <= until+0.000001:
                    _deal_direct(caster,target,float(burn.get("ratio",0.0)),"dot",false,"fire",false)
                    _event("status_tick",{"caster":caster["id"],"target":target["id"],"status":"burn"})
                    burn["next_tick"] = due+1.0
                if now >= until or float(target["hp"]) <= 0.0:
                    statuses.erase("burn")
        if statuses.has("weaken") and now >= float(statuses["weaken"].get("until",-1.0)):
            statuses.erase("weaken")
        if statuses.has("slow") and now >= float(statuses["slow"].get("until",-1.0)):
            statuses.erase("slow")
        target["status_effects"] = statuses

func _cast_mage_aoe(actor: Dictionary, target: Dictionary) -> void:
    actor["next_skill"] = now+7.0
    var selected := _area_targets(str(actor["side"]),target["position"],3.0,MAX_TARGETS_AOE)
    _event("cast",{"actor_id":actor["id"],"skill":"area_burst","target_count":selected.size()})
    for enemy in selected:
        _deal_direct(actor,enemy,0.90,"area_burst",false)

func _begin_telegraphed_aoe(actor: Dictionary, target: Dictionary) -> void:
    var tier := str(actor["tier"])
    var center: Vector2 = target["position"]
    var radius := 2.8 if tier == "boss" else 2.2
    var cast_time := 1.0 if tier == "boss" else 0.75
    pending_casts.append({
        "caster":str(actor["id"]),"center":center,"radius":radius,
        "ready":now+cast_time,"ratio":1.1 if tier == "boss" else 0.85,
        "maximum":MAX_TARGETS_AOE
    })
    actor["next_skill"] = now+(7.5 if tier == "boss" else 8.0)
    _event("telegraph",{"caster":actor["id"],"center":center,"radius":radius,
        "release_at":now+cast_time,"skill":"area_slam"})

func _release_casts() -> void:
    var actor_ids: Array = actors.keys()
    actor_ids.sort()
    for raw_id in actor_ids:
        var actor: Dictionary = actors[raw_id]
        var v63_cast = actor.get("v63_pending_cast",{})
        if v63_cast is Dictionary and not v63_cast.is_empty() and now+0.000001 >= float(v63_cast.get("ready",INF)):
            actor.erase("v63_pending_cast")
            var v63_skill_id := str(v63_cast.get("v63_skill_id", ""))
            var v63_definition := V63HumanSkillCombatSystem.skill_definition(v63_skill_id)
            var v63_generation := str(v63_definition.get("generation", v63_definition.get("tier", actor.get("v63_combat_generation", "human"))))
            var cast_id := str(v63_cast.get("mastery_event_id",""))
            var release_target: Dictionary = actors.get(str(v63_cast.get("target_id","")),{})
            var release_event := {"caster":str(actor.get("id", "")),"target":str(v63_cast.get("target_id", "")),"target_id":str(v63_cast.get("target_id", "")),"skill_id":v63_skill_id,
                "generation":v63_generation,"lineage":str(v63_definition.get("lineage", actor.get("v63_combat_lineage", ""))),
                "release_at":now,"caster_hp_before":float(actor.get("hp", 0.0)),
                "shape":str(v63_cast.get("shape",v63_definition.get("shape","single_target"))),
                "caster_position":actor.get("position",Vector2.ZERO),"target_position":release_target.get("position",v63_cast.get("target_position_at_cast",Vector2.ZERO)),
                "caster_position_at_cast":v63_cast.get("caster_position_at_cast",Vector2.ZERO),
                "target_position_at_cast":v63_cast.get("target_position_at_cast",Vector2.ZERO)}
            if not cast_id.is_empty():
                release_event["cast_id"] = cast_id
                release_event["event_id"] = cast_id+"/skill_release"
            _event("skill_release",release_event)
            V63HumanSkillCombatSystem.release_cast(self,v63_cast,actor)
    var remaining: Array = []
    for cast_value in pending_casts:
        var cast: Dictionary = cast_value
        if now+0.000001 < float(cast["ready"]):
            remaining.append(cast)
            continue
        var caster: Dictionary = actors.get(str(cast["caster"]),{})
        if caster.is_empty() or float(caster["hp"]) <= 0.0:
            continue
        if cast.has("v63_skill_id"):
            V63HumanSkillCombatSystem.release_cast(self,cast,caster)
            continue
        if cast.has("skill_id"):
            var targeted: Dictionary = actors.get(str(cast["target_id"]),{})
            var skill_id := str(cast["skill_id"])
            var definition: Dictionary = CombatSkillSystem.SKILLS.get(skill_id,{})
            var effect := str(definition.get("effect",""))
            if not targeted.is_empty() and float(targeted["hp"]) > 0.0:
                _event("skill_hit",{"caster":caster["id"],"target":targeted["id"],"skill_id":skill_id})
                if effect == "guard" and caster["id"] == targeted["id"]:
                    targeted["learned_guard_factor"] = clampf(float(definition.get("guard_multiplier",1.0)),0.01,1.0)
                    targeted["learned_guard_until"] = now+maxf(0.0,float(definition.get("guard_duration",0.0)))
                    _event("status_applied",{"caster":caster["id"],"target":targeted["id"],
                        "status":"guard","skill_id":skill_id,"until":targeted["learned_guard_until"]})
                elif effect in ["damage","burn","weaken"]:
                    _deal_direct(caster,targeted,float(cast["ratio"]),"learned_skill",true,
                        str(cast.get("element","")))
                    if float(targeted["hp"]) > 0.0 and effect in ["burn","weaken"]:
                        _apply_skill_status(caster,targeted,skill_id,definition)
            continue
        var selected := _area_targets(str(caster["side"]),cast["center"],float(cast["radius"]),int(cast["maximum"]))
        _event("area_release",{"caster":caster["id"],"target_count":selected.size(),"center":cast["center"]})
        for target in selected:
            _deal_direct(caster,target,float(cast["ratio"]),"area_slam",false)
    pending_casts = remaining

func _area_targets(caster_side: String, center: Vector2, radius: float, limit: int) -> Array:
    var candidates: Array = []
    for actor in actors.values():
        if str(actor["side"]) != caster_side and float(actor["hp"]) > 0.0:
            var ds: float = (actor["position"] as Vector2).distance_squared_to(center)
            if ds <= radius*radius:
                candidates.append({"actor":actor,"distance":ds})
    candidates.sort_custom(func(a,b):
        var delta := float(a["distance"])-float(b["distance"])
        return str(a["actor"]["id"]) < str(b["actor"]["id"]) if absf(delta) < 0.000001 else delta < 0.0
    )
    var selected: Array = []
    for i in range(mini(candidates.size(),limit)):
        selected.append(candidates[i]["actor"])
    return selected

func _enemies_near(center: Dictionary, radius: float) -> int:
    var count := 0
    for actor in actors.values():
        if str(actor["side"]) == "monster" and float(actor["hp"]) > 0.0:
            if (actor["position"] as Vector2).distance_to(center["position"]) <= radius:
                count += 1
    return count

func _actor_casting(actor_id: String) -> bool:
    var actor: Dictionary = actors.get(actor_id,{})
    var actor_cast = actor.get("v63_pending_cast",{})
    if actor_cast is Dictionary and not actor_cast.is_empty():
        return true
    for cast in pending_casts:
        if str(cast["caster"]) == actor_id:
            return true
    return false

# Pending domain events are a separate data channel from the capped VFX ring.
# Copy-on-read: consumers cannot mutate the kernel's pending journal.
func pending_kill_events() -> Array:
    return _pending_kill_events.duplicate(true)

func acknowledge_kill_event(kill_id: String) -> bool:
    if not continuous_mode or kill_id.is_empty():
        return false
    for i in range(_pending_kill_events.size()):
        if str(_pending_kill_events[i].get("kill_id", "")) == kill_id:
            _pending_kill_events.remove_at(i)
            return true
    return false

func _record_monster_kill(attacker: Dictionary, target: Dictionary, kind: String, damage: float) -> void:
    if bool(target.get("v63_summon_no_reward", false)):
        return
    var slot := str(target.get("spawn_slot_id", ""))
    var generation := int(target.get("slot_generation", 0))
    # setup() and add_continuous_monster() validate these identities.
    var kill_id := "%s:slot:%s:g%d" % [encounter_id, slot, generation]
    _pending_kill_events.append({
        "kill_id":kill_id,"world_id":encounter_id,
        "monster_instance_id":str(target["id"]),
        "spawn_slot_id":slot,"slot_generation":generation,
        "species_id":str(target.get("species_id", "")),
        "killer_actor_id":str(attacker["id"]),
        "damage_kind":kind,"actual_damage":damage,"at_seconds":now
    })

func _count_monster_records() -> int:
    var count := 0
    for actor in actors.values():
        if str(actor.get("side", "")) == "monster":
            count += 1
    return count

func _count_alive(side: String) -> int:
    var count := 0
    for actor in actors.values():
        if str(actor["side"]) == side and float(actor["hp"]) > 0.0:
            if side == "disciple" and bool(actor.get("is_v63_summon",false)):
                continue
            count += 1
    return count

func _sync_linked_hp(actor: Dictionary) -> void:
    var linked = actor.get("linked_disciple",null)
    if linked is DiscipleState:
        linked.hp = float(actor["hp"])

func _keep_inside(position: Vector2) -> Vector2:
    return Vector2(
        clampf(position.x,world_bounds.position.x,world_bounds.end.x-0.001),
        clampf(position.y,world_bounds.position.y,world_bounds.end.y-0.001)
    )

func _event(kind: String, payload: Dictionary) -> void:
    if world_mode and events.size() >= MAX_EVENTS:
        events.pop_front()
    if events.size() >= MAX_EVENTS:
        return
    var row := {"type":kind,"time":now,"encounter_id":encounter_id}
    row.merge(payload)
    events.append(row)

func add_v63_boss_summons(boss: Dictionary, requested: int) -> int:
    var parent := str(boss.get("id", ""))
    if not active or not actors.has(parent) or float(boss.get("hp", 0.0)) <= 0.0:
        return 0
    var alive := 0
    var ordinal := int(boss.get("v63_summon_ordinal", 0))
    for actor in actors.values():
        if str(actor.get("v63_summon_parent", "")) == parent and float(actor.get("hp", 0.0)) > 0.0:
            alive += 1
    var added := 0
    for index in range(mini(clampi(requested, 0, 4), 4 - alive)):
        if _count_monster_records() >= MAX_MONSTERS or _last_spawn_generation.size() >= MAX_REMEMBERED_SPAWN_SLOTS:
            break
        ordinal += 1
        var summon: Dictionary = boss.duplicate(true)
        for key in summon.keys():
            if str(key).begins_with("v63_"):
                summon.erase(key)
        var summon_id := parent + "/summon/" + str(ordinal)
        summon["id"] = summon_id
        summon["tier"] = "normal"
        summon["stats"] = boss.stats.duplicate(true)
        summon.stats["max_hp"] = maxf(1.0, float(boss.max_hp) * 0.03)
        summon.stats["attack"] = maxf(1.0, float(boss.stats.attack) * 0.3)
        summon.stats["defense"] = maxf(0.0, float(boss.stats.defense) * 0.2)
        summon["max_hp"] = float(summon.stats.max_hp)
        summon["hp"] = float(summon.max_hp)
        summon["position"] = _keep_inside((boss.position as Vector2) + Vector2(0.5 * (index + 1), 0.5))
        if not _position_allowed(summon.position):
            continue
        summon["status_effects"] = {}
        summon["next_basic"] = now + STEP_SECONDS
        summon["next_skill"] = now + 4.0
        summon["spawn_slot_id"] = summon_id
        summon["slot_generation"] = 1
        summon["v63_summon_parent"] = parent
        summon["v63_summon_no_reward"] = true
        actors[summon_id] = summon
        _last_spawn_generation[summon_id] = 1
        _event("boss_summon", {"boss_id":str(boss.get("v63_boss_id", "")),"actor_id":summon_id,"parent":parent,"no_loot":true})
        added += 1
    boss["v63_summon_ordinal"] = ordinal
    return added
