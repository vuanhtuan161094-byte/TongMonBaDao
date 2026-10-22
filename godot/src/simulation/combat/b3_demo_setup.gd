class_name B3DemoSetup
extends RefCounted

# Dedicated new-demo bootstrap: real recruitment/learning/crafting APIs and
# actual starting Warehouse debits. Never used to upgrade an existing live save.
static func prepare(runtime: LiveGameRuntimeV2) -> Dictionary:
    var state := runtime.state()
    for d in state.disciples.values():
        if DiscipleRealmProgressV2.progression_ready(d):
            return {"ok":true,"disciple_id":d.id}
    var workforce := WorkforceSystem.new()
    for id in state.disciples.keys():
        workforce.issue_command(state,StringName(id),WorkforceSystem.COMMAND_HOLD,"",1000000)
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,99441)
    if candidate == null:
        return {"ok":false,"reason":"b3_demo_recruit_unavailable"}
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    if not accepted["ok"]:
        return accepted
    var disciple: DiscipleState = state.disciples[candidate.id]
    disciple.current_action = &"HOLD"
    CombatSkillSystem.new().learn_skill(state,disciple,&"thanh_phong_tram")
    var equipment := EquipmentSystem.new()
    var item := equipment.craft(state,&"thanh_thiet_kiem",false)
    if item.is_empty() or not equipment.manual_equip(state,disciple.id,StringName(item["id"])):
        return {"ok":false,"reason":"b3_demo_craft_failed"}
    var saved := runtime.save(state.runtime_last_wall_unix)
    if not saved["ok"]:
        return saved
    return {"ok":true,"disciple_id":disciple.id,"crafted_item":item["id"]}
