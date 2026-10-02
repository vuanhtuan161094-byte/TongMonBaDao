extends SceneTree

var actor: ModularDiscipleActor

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _verify_visual_catalog_contract():
        return
    if not _verify_deterministic_family_selection():
        return
    if not _verify_action_clip_mapping():
        return
    if not _verify_direction_mapping():
        return
    if not _verify_actor_does_not_mutate_disciple():
        return

    print("P3.2 MODULAR ACTOR CONTRACT TEST PASS")
    if actor != null:
        actor.queue_free()
        await process_frame
    quit(0)

func _verify_visual_catalog_contract() -> bool:
    if DiscipleActorVisualCatalog.ARCHETYPE_IDS.size() != 6:
        return _fail("Modular actor must expose exactly six initial visual families.")
    var expected_layers: Array[StringName] = [
        &"shadow", &"weapon_back", &"body", &"outfit", &"hair", &"weapon_front", &"accessory", &"aura"
    ]
    if DiscipleActorVisualCatalog.layer_order() != expected_layers:
        return _fail("Modular actor layer order changed from the production contract.")
    return true

func _verify_deterministic_family_selection() -> bool:
    var disciple := DiscipleState.new({"id":"visual_test", "name":"Visual Test"})
    disciple.profile_seed = 7
    disciple.sex_id = &"female"
    var first := DiscipleActorVisualCatalog.archetype_for_disciple(disciple)
    var second := DiscipleActorVisualCatalog.archetype_for_disciple(disciple)
    if first != &"female_spell" or second != first:
        return _fail("Visual family selection is not deterministic from persisted identity.")
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

func _verify_direction_mapping() -> bool:
    if DiscipleActorVisualCatalog.direction_for_delta(Vector2(20.0, 1.0)) != &"right":
        return _fail("Positive horizontal movement must face right.")
    if DiscipleActorVisualCatalog.direction_for_delta(Vector2(-20.0, 1.0)) != &"left":
        return _fail("Negative horizontal movement must face left.")
    if DiscipleActorVisualCatalog.direction_for_delta(Vector2(1.0, -20.0)) != &"up":
        return _fail("Negative vertical movement must face up.")
    if DiscipleActorVisualCatalog.direction_for_delta(Vector2(1.0, 20.0)) != &"down":
        return _fail("Positive vertical movement must face down.")
    return true

func _verify_actor_does_not_mutate_disciple() -> bool:
    var disciple := DiscipleState.new({"id":"actor_state_test", "name":"Actor State Test"})
    disciple.profile_seed = 11
    disciple.sex_id = &"male"
    disciple.current_action = &"REST"
    var before_action := disciple.current_action
    var before_seed := disciple.profile_seed
    var before_sex := disciple.sex_id

    actor = ModularDiscipleActor.new()
    root.add_child(actor)
    actor.configure(disciple)
    actor.sync_action(&"WORK_MINING")
    actor.set_facing_from_delta(Vector2(10.0, 0.0))

    if actor.current_clip != &"mining" or actor.facing != &"right":
        return _fail("Modular actor did not update its presentation state.")
    if disciple.current_action != before_action or disciple.profile_seed != before_seed or disciple.sex_id != before_sex:
        return _fail("Modular actor mutated DiscipleState; presentation must stay read-only.")
    if actor.layer_names().size() != 8:
        return _fail("Modular actor did not build the canonical eight visual layers.")
    if actor.production_body_active():
        return _fail("Actor without SpriteFrames should stay in safe placeholder mode.")
    return true

func _fail(message: String) -> bool:
    push_error(message)
    if actor != null:
        actor.queue_free()
    quit(1)
    return false
