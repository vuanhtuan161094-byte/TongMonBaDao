class_name DiscipleRealmProgressV2
extends RefCounted

# DV2-03 foundation: TWO real independent 30x10 tracks, persisted in each
# disciple. P2 cultivation_stage_index is NEVER converted into V2 secretly.
# No invented 300-floor XP price table or major-breakthrough chance.
const VERSION := 1
const TRACKS := ["cultivation","body"]
const MAX_REALM := 30
const MAX_FLOOR := 10
const CULTIVATION_REALM_NAMES := [
    "Phàm Nhân","Luyện Khí","Trúc Cơ","Tử Phủ","Kim Đan","Nguyên Anh",
    "Hóa Thần","Luyện Hư","Hợp Thể","Đại Thừa","Nhân Tiên","Địa Tiên",
    "Thiên Tiên","Chân Tiên","Huyền Tiên","Kim Tiên","Thái Ất Kim Tiên",
    "Đại La Kim Tiên","Tiên Vương","Tiên Đế","Thần Nhân","Chân Thần",
    "Thiên Thần","Thần Quân","Thần Vương","Thần Hoàng","Thần Đế",
    "Thần Tôn","Hỗn Độn Thần","Sáng Thế Chủ"
]
const BODY_REALM_NAMES := [
    "Phàm Thân","Luyện Bì","Luyện Nhục","Dịch Cân","Đoán Cốt",
    "Thông Mạch","Tôi Tạng","Luyện Huyết","Khai Khiếu","Linh Thân",
    "Kim Thân","Pháp Thân","Huyền Thân","Thánh Khu","Tiên Khu",
    "Chân Thân","Bất Hoại","Thái Ất Kim Thân","Đại La Kim Thân",
    "Đế Thân","Thần Khu","Thần Cốt","Thần Mạch","Thần Tạng",
    "Thần Tủy","Thần Khiếu","Thần Thể","Bất Diệt Thần Thể",
    "Hỗn Độn Thần Thể","Sáng Thế Thần Thể"
]

static func initialize(
    disciple: DiscipleState,
    cultivation_realm: int = 1, cultivation_floor: int = 1,
    body_realm: int = 1, body_floor: int = 1
) -> Dictionary:
    if disciple == null or not DiscipleBirthProfileV2.valid_complete_birth(disciple.v2_birth_profile):
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
        "gate_failures":0,"lifetime_failures":0,
        "auto_breakthrough":false,"breakthrough_history":[],
        "last_training_event_id":""}

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
        if int(row.get("gate_failures",0)) > int(row.get("lifetime_failures",0)):
            return false
        if not (row.get("auto_breakthrough",false) is bool) or not (row.get("breakthrough_history",[]) is Array):
            return false
    return true

# JSON.parse_string converts integral nested fields to floats. Normalize
# only the schema's integer fields (same as DV2-01 birth normalization);
# preserve exact progress floats and immutable audit labels.
static func normalize_profile(input: Variant) -> Dictionary:
    if not (input is Dictionary) or input.is_empty():
        return {}
    var normalized: Dictionary = input.duplicate(true)
    normalized["version"] = int(normalized.get("version",0))
    for track in TRACKS:
        var row = normalized.get(track,{})
        if not (row is Dictionary):
            return {}
        for key in ["realm","floor","gate_failures","lifetime_failures"]:
            row[key] = int(row.get(key,0))
        row["auto_breakthrough"] = bool(row.get("auto_breakthrough",false))
        row["last_training_event_id"] = str(row.get("last_training_event_id",""))
        var raw_history = row.get("breakthrough_history",[])
        if not (raw_history is Array):
            return {}
        for event in raw_history:
            if not (event is Dictionary):
                return {}
            event["realm"] = int(event.get("realm",0))
            # This is only a display/audit field; the active stream is
            # GameRng and must remain independent from history serialization.
            if event.has("roll"):
                event["roll"] = str(event["roll"])
            if event.has("chance"):
                event["chance"] = str(event["chance"])
        row["breakthrough_history"] = raw_history
        normalized[track] = row
    if not valid_profile(normalized):
        return {}
    return normalized

# Read-only labels from the locked 30+30 realm list, not alternative
# progression or a new realm; tier 10->11/20->21 event content remains
# separate from the ladder.
static func realm_name(track: String, realm: int) -> String:
    if not TRACKS.has(track) or realm < 1 or realm > MAX_REALM:
        return ""
    var names: Array = CULTIVATION_REALM_NAMES if track == "cultivation" else BODY_REALM_NAMES
    return str(names[realm-1])

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
        "body_global_floor":global_floor(int(p["body"]["realm"]),int(p["body"]["floor"])),
        "cultivation_name":realm_name("cultivation",int(p["cultivation"]["realm"])),
        "body_name":realm_name("body",int(p["body"]["realm"]))
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
    gain_type: String, floor_costs: Dictionary, sources: Array = []
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
    # Sources must carry a real owner+channel. Enabling Trait/Physique
    # identity alone cannot silently grant XP without an explicit consumer.
    var source_bonus := 0.0
    var source_ids: Dictionary = {}
    var ordered: Array = sources.duplicate(true)
    for entry in ordered:
        if not (entry is Dictionary):
            return {"ok":false,"reason":"invalid_xp_source"}
    ordered.sort_custom(func(a,b): return str(a.get("source_id","")) < str(b.get("source_id","")))
    for raw in ordered:
        if not (raw is Dictionary):
            return {"ok":false,"reason":"invalid_xp_source"}
        var source: Dictionary = raw
        var source_id := str(source.get("source_id",""))
        if source_id.is_empty() or source_ids.has(source_id) or source.has("scope") or source.has("condition") or source.has("filter"):
            return {"ok":false,"reason":"ambiguous_xp_source"}
        source_ids[source_id] = true
        var expected_channel := "cultivation_xp_gain" if track == "cultivation" else "body_xp_gain"
        if str(source.get("channel","")) != expected_channel or str(source.get("mode","")) != "percent_add":
            return {"ok":false,"reason":"unsupported_xp_source_channel"}
        var value := float(source.get("value",NAN))
        if is_nan(value) or is_inf(value):
            return {"ok":false,"reason":"nonfinite_xp_source"}
        if bool(source.get("enabled",true)):
            source_bonus += value
    var natural_factor := 1.0
    if gain_type == "natural":
        var relevant := disciple.aptitude if track == "cultivation" else disciple.constitution
        if is_nan(relevant) or is_inf(relevant) or relevant < 0.0:
            return {"ok":false,"reason":"invalid_foundation_attribute"}
        natural_factor += (0.0025 if track == "cultivation" else 0.0020)*relevant + source_bonus
    var gained := base_amount*maxf(0.0,natural_factor)
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
        "ok":true,"track":track,"gained":gained,
        "natural_factor":maxf(0.0,natural_factor),
        "floors_earned":floors_earned,
        "realm":realm,"floor":floor_index,"xp":xp,
        "at_major_gate":floor_index == MAX_FLOOR and xp >= float(costs[MAX_FLOOR]),
        "unapplied_overflow":extra
    }


# A user policy flag, persisted independently for cultivation and body.
# Never auto-roll during grant_xp, preview, UI or offscreen paint.
static func set_auto_breakthrough(disciple: DiscipleState, track: String, enabled: bool) -> Dictionary:
    if disciple == null or not valid_profile(disciple.v2_realm_progress) or not TRACKS.has(track):
        return {"ok":false,"reason":"invalid_track_or_progress"}
    disciple.v2_realm_progress[track]["auto_breakthrough"] = enabled
    return {"ok":true,"track":track,"enabled":enabled}

# Tu Vi major breakthrough (floor 10 -> next realm floor 1) obeys locked rules.
# The owner must provide an AUTHORIZED gate cost and authored BASE chance for
# this realm. There is deliberately NO fabricated universal 30-realm table.
# Consumable modifiers, protection, special Fate/Physique and material charges
# are not silently approximated; caller must satisfy those conditions upstream.
static func attempt_cultivation_breakthrough(
    disciple: DiscipleState, rng: GameRng,
    gate_required_xp: float, base_chance: float,
    requirements_verified: bool, event_id: String
) -> Dictionary:
    if disciple == null or rng == null or not valid_profile(disciple.v2_realm_progress):
        return {"ok":false,"reason":"v2_realm_profile_not_ready"}
    if event_id.is_empty() or not requirements_verified:
        return {"ok":false,"reason":"gate_requirements_not_verified"}
    if is_nan(gate_required_xp) or is_inf(gate_required_xp) or gate_required_xp <= 0.0:
        return {"ok":false,"reason":"unapproved_gate_cost"}
    if is_nan(base_chance) or is_inf(base_chance) or base_chance < 0.0 or base_chance > 1.0:
        return {"ok":false,"reason":"unapproved_breakthrough_chance"}
    var p: Dictionary = disciple.v2_realm_progress["cultivation"]
    var realm := int(p["realm"])
    if int(p["floor"]) != MAX_FLOOR or realm >= MAX_REALM:
        return {"ok":false,"reason":"major_gate_not_available"}
    if float(p["xp"])+0.0000001 < gate_required_xp:
        return {"ok":false,"reason":"gate_xp_incomplete"}
    for event in p.get("breakthrough_history",[]):
        if str(event.get("event_id","")) == event_id:
            return {"ok":false,"reason":"breakthrough_event_replayed"}
    var prior_failures := int(p["gate_failures"])
    var chance := clampf(base_chance+0.05*float(prior_failures),0.0,1.0)
    var roll := rng.randf()
    var success := roll < chance
    var next_state: Dictionary = p.duplicate(true)
    var history: Array = next_state.get("breakthrough_history",[]).duplicate(true)
    history.append({"event_id":event_id,"realm":realm,"success":success,
        # JSON binary floating-point roundtrips may change last bits; these
        # audit fields are labels, not an RNG authority. Keep exact text.
        "roll":str(roll),"chance":str(chance)})
    next_state["breakthrough_history"] = history
    if success:
        next_state["realm"] = realm+1
        next_state["floor"] = 1
        next_state["xp"] = 0.0
        next_state["gate_failures"] = 0
    else:
        next_state["xp"] = maxf(0.0,float(p["xp"])-0.10*gate_required_xp)
        next_state["gate_failures"] = prior_failures+1
        next_state["lifetime_failures"] = int(p["lifetime_failures"])+1
    disciple.v2_realm_progress["cultivation"] = next_state
    return {"ok":true,"success":success,"track":"cultivation",
        "chance":chance,"roll":roll,"event_id":event_id,
        "realm":int(next_state["realm"]),"floor":int(next_state["floor"]),
        "xp":float(next_state["xp"]),
        "same_gate_failures":int(next_state["gate_failures"]),
        "lifetime_failures":int(next_state["lifetime_failures"])}

# Luyện Thể major gates are INDEPENDENT: its material requirements / chances
# are not yet user-locked. Only a pre-authorized gate outcome may be committed,
# never a guessed RNG roll or a Tu Vi breakthrough chance copied to Body.
static func commit_authorized_body_gate(
    disciple: DiscipleState, gate_required_xp: float,
    requirements_verified: bool, event_id: String
) -> Dictionary:
    if disciple == null or not valid_profile(disciple.v2_realm_progress):
        return {"ok":false,"reason":"v2_realm_profile_not_ready"}
    if event_id.is_empty() or not requirements_verified or is_nan(gate_required_xp) or is_inf(gate_required_xp) or gate_required_xp <= 0.0:
        return {"ok":false,"reason":"body_gate_content_not_authorized"}
    var p: Dictionary = disciple.v2_realm_progress["body"]
    if int(p["floor"]) != MAX_FLOOR or int(p["realm"]) >= MAX_REALM:
        return {"ok":false,"reason":"body_major_gate_not_available"}
    if float(p["xp"])+0.0000001 < gate_required_xp:
        return {"ok":false,"reason":"body_gate_xp_incomplete"}
    for event in p.get("breakthrough_history",[]):
        if str(event.get("event_id","")) == event_id:
            return {"ok":false,"reason":"body_gate_event_replayed"}
    var updated: Dictionary = p.duplicate(true)
    updated["breakthrough_history"].append({"event_id":event_id,
        "realm":int(p["realm"]),"success":true,"kind":"authorized_body_gate"})
    updated["realm"] = int(p["realm"])+1
    updated["floor"] = 1
    updated["xp"] = 0.0
    updated["gate_failures"] = 0
    disciple.v2_realm_progress["body"] = updated
    return {"ok":true,"track":"body","event_id":event_id,
        "realm":updated["realm"],"floor":1}
