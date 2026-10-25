class_name SectEndgameVisualBudgetV1
extends RefCounted

# Presentation-only budget. ALL canonical DiscipleState and BuildingState
# instances stay in SimulationState; this class decides ONLY what is drawn.
# Never use visual subset to drive AI, production, injury, loot, or Save.
const OVERVIEW_ZOOM := 0.96
const COMPACT_SITE_ZOOM := 1.24
const OVERVIEW_ACTOR_CAP := 24
const NORMAL_ACTOR_CAP := 40
const FOCUS_ACTOR_CAP := 72

static func site_level(zoom: float) -> int:
    # 0: no text / compact silhouette, 1: compact worksite,
    # 2: original candidate / approved real art.
    if zoom <= OVERVIEW_ZOOM:
        return 0
    if zoom < COMPACT_SITE_ZOOM:
        return 1
    return 2

static func actor_cap(zoom: float) -> int:
    if zoom <= OVERVIEW_ZOOM:
        return OVERVIEW_ACTOR_CAP
    if zoom < COMPACT_SITE_ZOOM:
        return NORMAL_ACTOR_CAP
    return FOCUS_ACTOR_CAP

static func pick_radius(zoom: float, managed: bool) -> Vector2:
    if not managed or zoom >= COMPACT_SITE_ZOOM:
        return Vector2(78.0,78.0)
    return Vector2(37.0,39.0) if zoom <= OVERVIEW_ZOOM else Vector2(48.0,50.0)

# Candidate rows: id:String, center_distance:float, focused:bool.
# Sort by focus, then proximity to viewport center, then stable ID. This
# avoids actor render flicker due to Dictionary iteration or scene reload.
static func choose_visible_actors(candidates: Array[Dictionary], zoom: float, focused_id: String = "") -> Dictionary:
    var ordered := candidates.duplicate(true)
    ordered.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
        var a_focus := str(a.get("id","")) == focused_id and not focused_id.is_empty()
        var b_focus := str(b.get("id","")) == focused_id and not focused_id.is_empty()
        if a_focus != b_focus:
            return a_focus
        var da := float(a.get("center_distance",INF))
        var db := float(b.get("center_distance",INF))
        if not is_equal_approx(da,db):
            return da < db
        return str(a.get("id","")) < str(b.get("id",""))
    )
    var chosen: Dictionary = {}
    for i in range(mini(ordered.size(),actor_cap(zoom))):
        var id := str(ordered[i].get("id",""))
        if not id.is_empty():
            chosen[id] = true
    return chosen
