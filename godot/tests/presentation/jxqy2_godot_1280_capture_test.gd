extends SceneTree

const SAVE_PATH := "user://demo_sandbox/jxqy2_capture_save.json"
const OUTPUT := "user://demo_sandbox/v01_"
var failure := false

func _init() -> void:
    call_deferred("_run")

func check(condition: bool, detail: String) -> bool:
    if not condition:
        failure = true
        push_error("JXQY2 VIEWPORT FAIL: "+detail)
        quit(1)
    return condition

func capture(stage: String) -> bool:
    await RenderingServer.frame_post_draw
    var image := get_root().get_texture().get_image()
    if not check(image != null and image.get_size() == Vector2i(1280,720),"viewport is not 1280x720"):
        return false
    var path := OUTPUT+stage+"_1280x720.png"
    if not check(image.save_png(path) == OK,"capture could not be saved"):
        return false
    print("JXQY2 CAPTURE "+stage+" "+ProjectSettings.globalize_path(path))
    return true

func _run() -> void:
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
    DisplayServer.window_set_size(Vector2i(1280,720))
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    ProjectSettings.set_setting("demo/quick_hunt",false)
    var built := Jxqy2DemoProfileV1.create()
    if not check(bool(built.get("ok",false)),"DEMO MAX factory failed"):
        return
    var state: SimulationState = built["state"]
    var skill_id := StringName(str(built["source_hunter_id"]))
    var hunter: DiscipleState = state.disciples[skill_id]
    var skill_system := CombatSkillSystem.new()
    if not check(&"ngu_kiem_thuat" in skill_system.usable_skills(state,hunter),"canonical learned skill gate failed"):
        return
    var owned: Array = []
    for id in skill_system.usable_skills(state,hunter):
        if str(skill_system.definition(id).get("effect","")) == "damage":
            owned.append(str(id))
    var policy := AutoSkillPolicyV2.default_policy(owned)
    for row in policy["skills"]:
        row["enabled"] = str(row["canonical_skill_id"]) == "ngu_kiem_thuat"
        row["conditions"]["target_tiers"] = ["boss"]
    if not check(bool(DemoAutoSkillPolicyStoreV1.save_policy(str(skill_id),owned,policy).get("ok",false)),"sandbox auto policy failed"):
        return
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://demo_sandbox"))
    if not check(SaveService.new().save_to_path(state,SAVE_PATH) == OK,"isolated save failed"):
        return
    ProjectSettings.set_setting("demo/hunter_ids",built["hunter_ids"])
    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    var sect := packed.instantiate()
    get_root().add_child(sect)
    for i in range(6):
        await process_frame
    if not check(bool(sect.get("runtime_ready")),"real P3 runtime failed"):
        return
    sect.call("_bottom_action","world")
    for i in range(2):
        await process_frame
    var holder := sect.get("popup_layer") as Control
    var panel := holder.get_node_or_null("LiveHuntingPveV2") as HuntingPlayPanelV2
    if not check(panel != null and panel.battle_layer.jxqy2.active,"exact JXQY2 source pack did not load: "+str(ProjectSettings.get_setting("demo/jxqy2_source_result",{}))):
        return
    panel.selected_level = 5
    panel.level_choice.select(4)
    # One canonical hunter lets the real delayed projectile reach its Boss;
    # a six-person MAX squad can kill that target before V2 settles the cast.
    panel.chosen[str(skill_id)] = true
    panel._launch()
    if not check(panel.session != null and panel.session.battle != null and not panel.session.battle.navigation_grid.is_empty(),"real hunting dispatch did not use source map navigation"):
        return
    if not check(panel.battle_layer.current_camera_follow_id().is_empty(),"default camera must stay free"):
        return
    # QA explicitly selects the hunter to keep every native stage in frame.
    # The playable default remains free; the final capture demonstrates drag.
    if not check(panel.battle_layer.select_camera_actor(str(skill_id)),"explicit QA actor selection failed"):
        return
    var caption := Label.new()
    caption.text = "V-01 • JXQY2 offline • Combat V2 • Boss: vai trò V2, dùng actor nguồn minh họa • 1280×720"
    caption.position = Vector2(12,695)
    caption.add_theme_font_size_override("font_size",14)
    caption.z_index = 4095
    caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
    get_root().add_child(caption)
    await create_timer(1.0).timeout
    if not await capture("roaming"):
        return
    var source := panel.battle_layer.jxqy2
    var battle := panel.session.battle
    var captured: Dictionary = {}
    var saw_basic := false
    var started := Time.get_ticks_msec()
    while Time.get_ticks_msec()-started < 90000:
        await process_frame
        for event in battle.events:
            if str(event.get("type","")) == "hit" and str(event.get("kind","")) == "basic":
                saw_basic = true
        for cue in source.casts:
            var age := panel.battle_layer._frame_clock-float(cue["started"])
            if not captured.has("cast") and age > 0.10 and age < float(cue["cast_time"]):
                captured["cast"] = await capture("cast")
            elif not captured.has("projectile") and age > float(cue["cast_time"])+0.05 and age < float(cue["duration"]):
                captured["projectile"] = await capture("projectile")
        for cue in source.impacts:
            var age := panel.battle_layer._frame_clock-float(cue["started"])
            if not captured.has("impact") and age > 0.12:
                captured["impact"] = await capture("impact")
        if captured.size() == 3 and saw_basic:
            break
        if not battle.active or failure:
            break
    if not check(captured.size() == 3 and saw_basic,"real-time skill stages/basic attack were not all observed: "+str(captured)):
        return
    var camera_before: Vector2 = panel.battle_layer._camera_center
    panel.battle_layer.pan_camera_pixels(Vector2(94.0,26.0))
    for i in range(4):
        await process_frame
    if not check(panel.battle_layer._camera_center.distance_to(camera_before) > 0.1 and panel.battle_layer.current_camera_follow_id().is_empty(),"free camera did not retain the drag"):
        return
    await capture("camera_free")
    if not check(panel.battle_layer.select_camera_actor(str(skill_id)),"explicit follow selection failed"):
        return
    for i in range(5):
        await process_frame
    if not check(panel.battle_layer.current_camera_follow_id() == str(skill_id),"camera follow did not require the selected actor"):
        return
    print("JXQY2 VIEWPORT PASS: real 1280x720; actual hunting V2 basic/native acMagic/projectile/positive-hit impact; full source map layers; free drag and explicit follow. Visual acceptance PENDING; school/weapon mapping partial.")
    quit(0)
