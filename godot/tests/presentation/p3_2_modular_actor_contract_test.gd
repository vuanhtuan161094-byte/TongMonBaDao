extends SceneTree

var actor: ModularDiscipleActor

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _verify_rig_contract():
        return
    if not _verify_canvas_contract():
        return
    if not _verify_layer_contract():
        return
    if not _verify_deterministic_appearance():
        return
    if not _verify_action_clip_mapping():
        return
    if not _verify_direction_and_mirror_mapping():
        return
    if not _verify_shared_rig_actor_is_read_only():
        return

    print("P3.2 CHARACTER CREATOR SHARED RIG CONTRACT TEST PASS")
    if actor != null:
        actor.queue_free()
        await process_frame
    quit(0)

func _verify_rig_contract() -> bool:
    var expected_rigs: Array[StringName] = [&"female_normal_v1", &"male_normal_v1"]
    if DiscipleActorVisualCatalog.RIG_IDS != expected_rigs:
        return _fail("Character Creator V1 rig IDs changed from the locked contract.")

    var expected_bones: Array[StringName] = [
        &"root", &"pelvis", &"torso", &"head", &"arm_l", &"arm_r", &"hand_weapon", &"leg_l", &"leg_r"
    ]
    if DiscipleActorVisualCatalog.BONE_IDS != expected_bones:
        return _fail("Character Creator V1 bone IDs changed from the locked coarse-rig contract.")
    if DiscipleActorVisualCatalog.bone_parent(&"head") != &"torso":
        return _fail("Head bone must remain parented to torso.")
    if DiscipleActorVisualCatalog.bone_parent(&"hand_weapon") != &"arm_r":
        return _fail("Weapon hand socket must remain parented to right arm in V1.")
    return true

func _verify_canvas_contract() -> bool:
    if DiscipleActorVisualCatalog.SOURCE_FRAME_SIZE != Vector2(128.0, 128.0):
        return _fail("Map actor source canvas must remain 128x128.")
    if DiscipleActorVisualCatalog.SOURCE_FOOT_POINT != Vector2(64.0, 104.0):
        return _fail("Map actor source foot anchor changed from (64,104).")
    if not is_equal_approx(DiscipleActorVisualCatalog.MAP_DISPLAY_SCALE, 0.68):
        return _fail("Map actor display scale must remain 0.68 until the real visual proof changes it explicitly.")
    return true

func _verify_layer_contract() -> bool:
    var expected_layers: Array[StringName] = [
        &"shadow",
        &"aura",
        &"hair_back",
        &"weapon_back",
        &"body",
        &"outfit",
        &"face",
        &"hair_front",
        &"head_accessory",
        &"weapon_front",
        &"accessory"
    ]
    if DiscipleActorVisualCatalog.layer_order() != expected_layers:
        return _fail("Character Creator render-layer order changed from the production contract.")
    if DiscipleActorVisualCatalog.z_index_for_layer(&"weapon_back") >= DiscipleActorVisualCatalog.z_index_for_layer(&"body"):
        return _fail("weapon_back must render behind body.")
    if DiscipleActorVisualCatalog.z_index_for_layer(&"weapon_front") <= DiscipleActorVisualCatalog.z_index_for_layer(&"hair_front"):
        return _fail("weapon_front must remain a front render pass.")
    return true

func _verify_deterministic_appearance() -> bool:
    var disciple := DiscipleState.new({"id":"visual_test", "name":"Visual Test"})
    disciple.profile_seed = 7
    disciple.sex_id = &"female"

    var first := DiscipleActorVisualCatalog.default_appearance_for_disciple(disciple)
    var second := DiscipleActorVisualCatalog.default_appearance_for_disciple(disciple)
    if first != second:
        return _fail("Default appearance must be deterministic from persisted identity.")
    if str(first.get("rig_id", "")) != "female_normal_v1":
        return _fail("Female identity must resolve to female_normal_v1 in V1.")

    var normalized := DiscipleActorVisualCatalog.normalize_appearance_profile({
        "rig_id": "not_a_real_rig",
        "hair_tint": "not-a-color",
        "outfit_id": "outfit_02",
        "bogus_ui_state": "must_not_survive"
    }, disciple)
    if str(normalized.get("rig_id", "")) != "female_normal_v1":
        return _fail("Invalid rig override did not fall back to canonical identity.")
    if str(normalized.get("outfit_id", "")) != "outfit_02":
        return _fail("Valid cosmetic override was not retained by the appearance normalizer.")
    if normalized.has("bogus_ui_state"):
        return _fail("Appearance normalizer leaked unknown UI state into the canonical profile.")
    if str(normalized.get("hair_tint", "")) == "not-a-color":
        return _fail("Invalid tint did not fall back safely.")
    return true

func _verify_action_clip_mapping() -> bool:
    if DiscipleActorVisualCatalog.action_clip(&"WORK_MINING") != &"mining":
        return _fail("WORK_MINING must map to mining animation.")
    if DiscipleActorVisualCatalog.action_clip(&"WORK_FORGING") != &"forging":
        return _fail("WORK_FORGING must map to forging animation.")
    if DiscipleActorVisualCatalog.action_clip(&"CULTIVATE") != &"cultivate":
        return _fail("CULTIVATE must map to cultivate animation.")
    if DiscipleActorVisualCatalog.action_clip(&"REST") != &"rest":
        return _fail("REST must map to rest animation.")
    if DiscipleActorVisualCatalog.action_clip(&"UNKNOWN_ACTION") != &"idle":
        return _fail("Unknown actions must fail safe to idle presentation.")
    return true

func _verify_direction_and_mirror_mapping() -> bool:
    if DiscipleActorVisualCatalog.direction_for_delta(Vector2(20.0, 1.0)) != &"right":
        return _fail("Positive horizontal movement must face right.")
    if DiscipleActorVisualCatalog.direction_for_delta(Vector2(-20.0, 1.0)) != &"left":
        return _fail("Negative horizontal movement must face left.")
    if DiscipleActorVisualCatalog.direction_for_delta(Vector2(1.0, -20.0)) != &"up":
        return _fail("Negative vertical movement must face up.")
    if DiscipleActorVisualCatalog.direction_for_delta(Vector2(1.0, 20.0)) != &"down":
        return _fail("Positive vertical movement must face down.")
    if DiscipleActorVisualCatalog.playback_direction(&"left", true) != &"right":
        return _fail("Mirror-safe left must reuse right shared motion.")
    if DiscipleActorVisualCatalog.playback_direction(&"left", false) != &"left":
        return _fail("Authored-left mode must preserve left animation.")
    return true

func _verify_shared_rig_actor_is_read_only() -> bool:
    var disciple := DiscipleState.new({"id":"actor_state_test", "name":"Actor State Test"})
    disciple.profile_seed = 11
    disciple.sex_id = &"female"
    disciple.current_action = &"REST"
    var before_action := disciple.current_action
    var before_seed := disciple.profile_seed
    var before_sex := disciple.sex_id

    actor = ModularDiscipleActor.new()
    root.add_child(actor)
    actor.configure(disciple)
    actor.sync_action(&"WORK_MINING")
    actor.set_facing_from_delta(Vector2(-10.0, 0.0))

    if actor.current_clip != &"mining" or actor.facing != &"left":
        return _fail("Shared rig actor did not update presentation state.")
    if actor.current_animation_name() != &"mining_left":
        return _fail("Public animation contract must preserve left facing.")
    if actor.current_playback_animation_name() != &"mining_right" or not actor.uses_mirrored_left():
        return _fail("Mirror-safe left playback did not resolve through right motion.")
    if disciple.current_action != before_action or disciple.profile_seed != before_seed or disciple.sex_id != before_sex:
        return _fail("Character presentation mutated DiscipleState; presentation must stay read-only.")
    if actor.bone_names().size() != 9:
        return _fail("Shared rig actor did not build the canonical nine-bone scaffold.")
    if actor.layer_names().size() != 11:
        return _fail("Shared rig actor did not expose the canonical eleven render layers.")
    if actor.skeleton == null or actor.animation_player == null:
        return _fail("Shared rig actor must contain Skeleton2D and AnimationPlayer.")
    if _count_nodes_of_type(actor, "AnimatedSprite2D") != 0:
        return _fail("Shared rig actor must not return to timeline-per-layer AnimatedSprite2D architecture.")
    if actor.production_body_active():
        return _fail("Actor without production textures should remain in safe placeholder mode.")
    return true

func _count_nodes_of_type(node: Node, type_name: String) -> int:
    var count := 0
    if node.get_class() == type_name:
        count += 1
    for child in node.get_children():
        count += _count_nodes_of_type(child, type_name)
    return count

func _fail(message: String) -> bool:
    push_error(message)
    if actor != null:
        actor.queue_free()
    quit(1)
    return false
