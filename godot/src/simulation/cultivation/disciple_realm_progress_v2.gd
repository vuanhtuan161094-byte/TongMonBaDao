class_name DiscipleRealmProgressV2
extends RefCounted

# DV2-03 foundation: TWO real independent 30x10 tracks, persisted in each
# disciple. P2 cultivation_stage_index is NEVER converted into V2 secretly.
# No invented 300-floor XP price table or major-breakthrough chance.
const VERSION := 1
const TRACKS := ["cultivation","body"]
const MAX_REALM := 30
const MAX_FLOOR := 10

static func initialize(
    disciple: DiscipleState,
    cultivation_realm: int = 1, cultivation_floor: int = 1,
    body_realm: int = 1, body_floor: int = 1
) -> Dictionary:
    if disciple == null or not bool(disciple.v2_birth_profile.get("initialized",false)):
        return {"ok":false,"reason":"no_confirmed_v2_birth_identity"}
    if not disciple.v2_realm_progress.is_empty():
        return {"ok":false,"reason":"v2_progress_already_initialized"}
    if not valid_coordinates(cultivation_realm,cultivation_floor) or not valid_coordinates(body_realm,body_floor):
        return {"ok":false,"reason":"invalid_starting_realm"}
    disciple.v2_realm_progress = {
        "version":VERSION,"initialized":true,
        "cultivation":_track(cultivation_realm,cultivation_floor),
        "body":_track(body_realm,body_floor)
    }
    return {"ok":true,"profile":disciple.v2_realm_progress.duplicate(true)}

static func _track(realm: int, floor_index: int) -> Dictionary:
    return {"realm":realm,"floor":floor_index,"xp":0.0,
        "gate_failures":0,"lifetime_failures":0}

static func valid_coordinates(realm: int, floor_index: int) -> bool:
    return realm >= 1 and realm <= MAX_REALM and floor_index >= 1 and floor_index <= MAX_FLOOR

static func valid_profile(profile: Dictionary) -> bool:
    if int(profile.get("version",0)) != VERSION or not bool(profile.get("initialized",false)):
        return false
    for channel in TRACKS:
        var row = profile.get(channel,{})
        if not (row is Dictionary):
            return false
        if not valid_coordinates(int(row.get("realm",0)),int(row.get("floor",0))):
            return false
        var xp := float(row.get("xp",-1.0))
        if is_nan(xp) or is_inf(xp) or xp < 0.0:
            return false
        if int(row.get("gate_failures",-1)) < 0 or int(row.get("lifetime_failures",-1)) < 0:
            return false
    return true

static func global_floor(realm: int, floor_index: int) -> int:
    if not valid_coordinates(realm,floor_index):
        return 0
    return (realm-1)*10+floor_index

static func current(disciple: DiscipleState) -> Dictionary:
    if disciple == null or not valid_profile(disciple.v2_realm_progress):
        return {"ok":false,"reason":"v2_realm_profile_not_ready"}
    var p: Dictionary = disciple.v2_realm_progress
    return {
        "ok":true,
        "cultivation":p["cultivation"].duplicate(true),
        "body":p["body"].duplicate(true),
        "cultivation_global_floor":global_floor(int(p["cultivation"]["realm"]),int(p["cultivation"]["floor"])),
        "body_global_floor":global_floor(int(p["body"]["realm"]),int(p["body"]["floor"]))
    }

static func derive_stats(disciple: DiscipleState, sources: Array = []) -> Dictionary:
    var profile := current(disciple)
    if not bool(profile.get("ok",false)):
        return profile
    var cultivation: Dictionary = profile["cultivation"]
    var body: Dictionary = profile["body"]
    return CombatStatsV2.derive(
        int(cultivation["realm"]),int(cultivation["floor"]),
        int(body["realm"]),int(body["floor"]),
        disciple.potential,sources
    )

# Apply real source EXP only when the caller owns an approved XP requirement
# table for ALL ten floors of this specific realm. Absence is BLOCKED, not
# guessed from HP/ATK/cultivation_stage_index.
#
# "natural" obeys the user-locked aptitude/constitution bonus; "fixed" bypasses
# all such bonuses. This adapter does NOT authorize material costs/EXP rates.
# At floor 10, progression never crosses the major-realm gate automatically.
# Surplus is explicitly returned as unapplied XP until an authored bank/trait
# consumer exists; it is NOT silently stored as generic Tich Tu.
static func grant_xp(
    disciple: DiscipleState, track: String, base_amount: float,
    gain_type: String, floor_costs: Dictionary
) -> Dictionary:
    if disciple == null or not valid_profile(disciple.v2_realm_progress):
        return {"ok":false,"reason":"v2_realm_profile_not_ready"}
    if not TRACKS.has(track) or not ["natural","fixed"].has(gain_type):
        return {"ok":false,"reason":"invalid_track_or_gain_type"}
    if is_nan(base_amount) or is_inf(base_amount) or base_amount < 0.0:
        return {"ok":false,"reason":"invalid_xp_amount"}
    var old: Dictionary = disciple.v2_realm_progress[track]
    var realm := int(old["realm"])
    var floor_index := int(old["floor"])
    var costs: Dictionary = {}
    for f in range(floor_index,MAX_FLOOR+1):
        var key := "%d:%d" % [realm,f]
        if not floor_costs.has(key):
            return {"ok":false,"reason":"xp_cost_content_not_authorized"}
        var value := float(floor_costs[key])
        if is_nan(value) or is_inf(value) or value <= 0.0:
            return {"ok":false,"reason":"invalid_xp_cost"}
        costs[f] = value
    var natural_factor := 1.0
    if gain_type == "natural":
        var relevant := disciple.aptitude if track == "cultivation" else disciple.constitution
        if is_nan(relevant) or is_inf(relevant) or relevant < 0.0:
            return {"ok":false,"reason":"invalid_foundation_attribute"}
        natural_factor += (0.0025 if track == "cultivation" else 0.0020)*relevant
    var gained := base_amount*natural_factor
    if is_nan(gained) or is_inf(gained):
        return {"ok":false,"reason":"nonfinite_xp_gain"}
    var xp := float(old["xp"])+gained
    var floors_earned := 0
    while floor_index < MAX_FLOOR and xp >= float(costs[floor_index]):
        xp -= float(costs[floor_index])
        floor_index += 1
        floors_earned += 1
    # A full 10th floor must still clear its major gate through the proper
    # breakthrough consumer. No automatic cross-realm advancement.
    var extra := maxf(0.0,xp-float(costs[floor_index]))
    xp = minf(xp,float(costs[floor_index]))
    var next: Dictionary = old.duplicate(true)
    next["floor"] = floor_index
    next["xp"] = xp
    disciple.v2_realm_progress[track] = next
    return {
        "ok":true,"track":track,"gained":gained,"floors_earned":floors_earned,
        "realm":realm,"floor":floor_index,"xp":xp,
        "at_major_gate":floor_index == MAX_FLOOR and xp >= float(costs[MAX_FLOOR]),
        "unapplied_overflow":extra
    }
