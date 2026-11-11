class_name Eco05CapacityAuditV1
extends RefCounted

# ECO-05 is a READ-ONLY r1→r2 capacity/funding audit. It cannot add a site,
# credit currency, override tax, unlock LT2/W2/T2 or raise recruitment limits.
const TARGET_MINE := 10
const TARGET_FOREST := 10
const TARGET_FIELD := 10
const TARGET_TOTAL := 30

var buildings := BuildingSystem.new()
var warehouse := WarehouseSystem.new()
var economy := EconomySystem.new()

func _producer_count(state: SimulationState, kind: StringName) -> Dictionary:
    var count := 0
    var capacity := 0
    var staffed := 0
    var paid := 0
    for raw in state.buildings.values():
        if not (raw is BuildingState):
            continue
        var site: BuildingState = raw
        if site.building_type != kind or site.status != BuildingSystem.STATUS_ACTIVE:
            continue
        # The primary site was created by the canonical New Game. Annexes
        # must carry the real transaction proof on their persisted BuildingState.
        if site.instance_index > 1:
            var receipt: Dictionary = site.production_state.get("v57_paid_cost",{})
            var request := str(site.production_state.get("v57_build_request_id",""))
            if request.is_empty() or receipt.is_empty() or receipt != buildings.production_annex_cost(kind,site.instance_index):
                continue
            paid += 1
        count += 1
        capacity += buildings.worker_slots(site)
        staffed += buildings.active_worker_ids(state,site).size()
    return {"sites":count,"paid_annexes":paid,"slots":capacity,"assigned_active":staffed}

func inspect(state: SimulationState) -> Dictionary:
    if state == null or not state.p3_7_buildings_enabled:
        return {"ok":false,"reason":"canonical_buildings_missing"}
    var mine := _producer_count(state,BuildingSystem.TYPE_MINE)
    var forest := _producer_count(state,BuildingSystem.TYPE_LINH_FOREST)
    var field := _producer_count(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    var max_rank_roster := int(SectHallSystemV1.RANK_LIMITS[SectHallSystemV1.RANK_LIMITS.size()-1])
    var hall := SectHallSystemV1.hall(state)
    var hall_level := hall.level if hall != null else 0
    var capacity := int(mine["slots"])+int(forest["slots"])+int(field["slots"])
    var needs := {
        "mine":maxi(0,TARGET_MINE-int(mine["slots"])),
        "linh_forest":maxi(0,TARGET_FOREST-int(forest["slots"])),
        "spirit_field":maxi(0,TARGET_FIELD-int(field["slots"]))
    }
    return {"ok":true,"roster":state.disciples.size(),
        "rank_roster_ceiling":max_rank_roster,
        "hall_level":hall_level,"mine":mine,"linh_forest":forest,
        "spirit_field":field,"producer_slots":capacity,
        "staffed_now":int(mine["assigned_active"])+int(forest["assigned_active"])+int(field["assigned_active"]),
        "target_slots":{"mine":TARGET_MINE,"linh_forest":TARGET_FOREST,"spirit_field":TARGET_FIELD},
        "target_total":TARGET_TOTAL,"slot_shortfall":needs,
        "paid_capacity_30":int(mine["slots"]) >= TARGET_MINE and int(forest["slots"]) >= TARGET_FOREST and int(field["slots"]) >= TARGET_FIELD,
        # At Lv1 each Mine/Forest has 2 slots, Field 4. Five Mine and
        # Forest instances need Hall Lv8 for the existing 1+floor(level/2)
        # paid annex cap. This is NOT a free building or a finance quote.
        "unupgraded_hall_floor_for_30":8,
        "player_r12_enabled":economy.sx_v55_r12_enabled(state)}

func upgrade_wave_quote(state: SimulationState) -> Dictionary:
    if state == null or not economy.sx_v55_r12_enabled(state):
        return {"ok":false,"reason":"r12_pilot_held"}
    var totals := {"spirit_stones":0,"linh_moc":0,"thanh_thiet":0}
    var work: Dictionary = {}
    var per_site: Dictionary = {}
    for kind in [BuildingSystem.TYPE_MAIN_HALL,BuildingSystem.TYPE_SPIRIT_FIELD,
            BuildingSystem.TYPE_MINE,BuildingSystem.TYPE_LINH_FOREST]:
        var site := buildings.primary_building(state,kind)
        if site == null or site.level != 1 or site.status != BuildingSystem.STATUS_ACTIVE:
            return {"ok":false,"reason":"wave_requires_four_active_lv1_sites","site":str(kind)}
        var price := buildings.sx_v55_upgrade_cost(state,site)
        if price.is_empty():
            return {"ok":false,"reason":"upgrade_cost_missing","site":str(kind)}
        per_site[str(kind)] = price.duplicate(true)
        work[str(kind)] = buildings.upgrade_required_work(site)
        for raw_id in totals.keys():
            totals[raw_id] = int(totals[raw_id])+int(price.get(raw_id,0))
    var available := {
        "spirit_stones":state.sect.spirit_stones,
        "linh_moc":warehouse.available_quantity(state,&"linh_moc"),
        "thanh_thiet":warehouse.available_quantity(state,&"thanh_thiet")
    }
    var gaps: Dictionary = {}
    var affordable := true
    for raw_id in totals.keys():
        gaps[raw_id] = maxi(0,int(totals[raw_id])-int(available[raw_id]))
        if int(gaps[raw_id]) > 0:
            affordable = false
    return {"ok":true,"r12_qa_only":true,"cost":totals,
        "available":available,"gap":gaps,"affordable_now":affordable,
        "per_site":per_site,"upgrade_work_per_site":work}
