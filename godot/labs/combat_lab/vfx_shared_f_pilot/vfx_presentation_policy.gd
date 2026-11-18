extends RefCounted
## F pilot: purely read-only snapshot normalizer and visual-cap scheduler.
## It never mutates Combat V2, actors, status timers or skill effects.
const PRIORITY := {"burn":95,"poison":90,"slow":75,"weaken":65,"mark":60,"guard":80}
const PROFILES := {
    "full": {"hero":4,"impact":12,"ambient":10},
    "balanced": {"hero":3,"impact":8,"ambient":6},
    "lite": {"hero":1,"impact":4,"ambient":2}
}

static func _add(rows: Dictionary, family: String, is_buff: bool, expires_at: float, source: String, stacks: int = 1) -> void:
    var row: Dictionary = rows.get(family, {
        "family":family, "is_buff":is_buff, "priority":int(PRIORITY.get(family,50)),
        "stack_count":0, "sources":[], "next_expiry":expires_at, "last_expiry":expires_at
    })
    var sources: Array = row["sources"]
    sources.append({"id":source,"expires_at":expires_at,"stacks":stacks})
    row["sources"] = sources
    row["stack_count"] = int(row["stack_count"]) + stacks
    row["next_expiry"] = minf(float(row["next_expiry"]),expires_at)
    row["last_expiry"] = maxf(float(row["last_expiry"]),expires_at)
    rows[family] = row

static func status_rows(actor: Dictionary, now_seconds: float) -> Array[Dictionary]:
    ## Active status only; no transient event creates a persistent icon.
    var found: Dictionary = {}
    var statuses: Dictionary = actor.get("status_effects",{})
    var poison: Array = statuses.get("v63_poison",[])
    for entry in poison:
        if not (entry is Dictionary):
            continue
        var expiry := float(entry.get("expires_at",-1.0))
        if expiry > now_seconds:
            _add(found,"poison",false,expiry,
                str(entry.get("owner_id","")) + "/" + str(entry.get("source_skill_id","")),1)
    for family in ["burn","slow","weaken"]:
        var state: Dictionary = statuses.get(family,{})
        if float(state.get("until",-1.0)) > now_seconds:
            _add(found,family,false,float(state["until"]),family,1)
    var marks: Dictionary = actor.get("v63_marks",{})
    for owner in marks.keys():
        var mark: Dictionary = marks[owner]
        var expiry := float(mark.get("until",-1.0))
        if expiry > now_seconds:
            _add(found,"mark",false,expiry,
                str(owner) + "/" + str(mark.get("skill_id","")),1)
    ## Internal v63_blood_marks intentionally NOT a second status badge.
    for field in ["guard_until","learned_guard_until"]:
        var expiry := float(actor.get(field,-1.0))
        if expiry > now_seconds:
            _add(found,"guard",true,expiry,field,1)
    var capacity_expiry := float(actor.get("v63_capacity_shield_until",-1.0))
    if capacity_expiry > now_seconds and float(actor.get("v63_capacity_shield_remaining",0.0)) > 0.0:
        _add(found,"guard",true,capacity_expiry,"capacity_shield",1)
    var result: Array[Dictionary] = []
    for row in found.values():
        result.append(row)
    result.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
        if int(a["priority"]) != int(b["priority"]):
            return int(a["priority"]) > int(b["priority"])
        return str(a["family"]) < str(b["family"])
    )
    return result

static func compact_rows(rows: Array[Dictionary], selected: bool = false, boss: bool = false) -> Dictionary:
    var buffs: Array[Dictionary] = []
    var debuffs: Array[Dictionary] = []
    for row in rows:
        if bool(row.get("is_buff",false)):
            buffs.append(row)
        else:
            debuffs.append(row)
    var cap := 6 if (selected or boss) else 2
    return {
        "buffs":buffs.slice(0,mini(buffs.size(),cap)),
        "debuffs":debuffs.slice(0,mini(debuffs.size(),cap)),
        "buff_overflow":maxi(0,buffs.size()-cap),
        "debuff_overflow":maxi(0,debuffs.size()-cap)
    }

static func _cue_priority(cue: Dictionary) -> int:
    var kind := str(cue.get("kind","ambient"))
    var base_priority := 0
    match kind:
        "telegraph": base_priority = 1000
        "essential_hit": base_priority = 850
        "hero": base_priority = 500
        "impact": base_priority = 350
        _: base_priority = 50
    if bool(cue.get("selected",false)): base_priority += 75
    if bool(cue.get("boss",false)): base_priority += 50
    return base_priority

static func select_visuals(cues: Array[Dictionary], profile: String = "balanced") -> Dictionary:
    ## Presentation-only: dropping a cosmetic cue MUST NOT drop a Combat event.
    var limits: Dictionary = PROFILES.get(profile,PROFILES["balanced"])
    var ordered: Array = cues.duplicate(true)
    ordered.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
        var ap := _cue_priority(a)
        var bp := _cue_priority(b)
        if ap != bp: return ap > bp
        return str(a.get("id","")) < str(b.get("id",""))
    )
    var drawn: Array[Dictionary] = []
    var suppressed: Array[String] = []
    var used := {"hero":0,"impact":0,"ambient":0}
    for cue in ordered:
        var id := str(cue.get("id",""))
        var kind := str(cue.get("kind","ambient"))
        if bool(cue.get("offscreen",false)) and kind != "telegraph":
            suppressed.append(id)
            continue
        var row: Dictionary = cue.duplicate(true)
        if kind == "telegraph":
            row["quality"] = "essential"
            drawn.append(row)
            continue
        var lane := "ambient"
        if kind == "hero": lane = "hero"
        elif kind in ["impact","essential_hit"]: lane = "impact"
        if int(used[lane]) >= int(limits[lane]):
            if kind == "essential_hit":
                row["quality"] = "lite"
                drawn.append(row)
            else:
                suppressed.append(id)
            continue
        used[lane] = int(used[lane]) + 1
        row["quality"] = "full" if profile == "full" else ("lite" if profile == "lite" else "balanced")
        drawn.append(row)
    return {"draw":drawn,"suppressed":suppressed,"counts":used,"profile":profile}
