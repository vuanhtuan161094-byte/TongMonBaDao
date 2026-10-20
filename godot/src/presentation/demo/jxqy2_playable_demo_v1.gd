extends SceneTree

const SAVE_PATH := "user://demo_sandbox/jxqy2_playable_demo_v1.json"

func _init() -> void:
    call_deferred("_start")

func _start() -> void:
    var source_root := OS.get_environment("TMB_JXQY2_ASSET_ROOT").strip_edges()
    if source_root.is_empty():
        push_error("JXQY2_DEMO_PENDING: thiếu TMB_JXQY2_ASSET_ROOT đã đối chiếu manifest")
        quit(2)
        return
    var verified := Jxqy2SourceSliceV1.new().load_sources(source_root)
    if not bool(verified.get("ok",false)):
        push_error("JXQY2_DEMO_PENDING: "+str(verified.get("reason","ASSET_INCOMPLETE")))
        quit(2)
        return
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    var source_hunter := str(DemoSandboxFactoryV1.hunter_ids()[0])
    if not FileAccess.file_exists(SAVE_PATH):
        var built := Jxqy2DemoProfileV1.create()
        if not bool(built.get("ok",false)):
            push_error("JXQY2_DEMO_FAIL: "+str(built))
            quit(1)
            return
        var state: SimulationState = built["state"]
        source_hunter = str(built["source_hunter_id"])
        var configured := Jxqy2DemoProfileV1.policy(state,state.disciples[StringName(source_hunter)])
        var saved_policy := DemoAutoSkillPolicyStoreV1.save_policy(source_hunter,configured["owned"],configured["policy"])
        if not bool(saved_policy.get("ok",false)) or SaveService.new().save_to_path(state,SAVE_PATH) != OK:
            push_error("JXQY2_DEMO_FAIL: không lưu được sandbox riêng")
            quit(1)
            return
    ProjectSettings.set_setting("demo/hunter_ids",[source_hunter])
    ProjectSettings.set_setting("demo/jx_loadouts",{})
    ProjectSettings.set_setting("demo/quick_hunt",true)
    print("JXQY2_DEMO_READY sources=44 save="+SAVE_PATH+" source_hunter="+source_hunter+" existing_save_preserved=true")
    if change_scene_to_file("res://scenes/p3/p3_2_landscape_sect.tscn") != OK:
        quit(1)
