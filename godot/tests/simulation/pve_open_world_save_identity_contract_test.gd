extends SceneTree

# PVE-SAVE-01: fail-closed Source A/JX world identity when resuming a saved
# encounter. The test never creates loot, touches production saves or advances
# Combat V2 time. Godot 4.7.2 runtime is required for execution.
var checks := 0

func _init() -> void:
	call_deferred("_run")

func _check(valid: bool, reason: String) -> bool:
	if not valid:
		push_error("PVE SAVE WORLD IDENTITY FAIL: "+reason)
		quit(1)
		return false
	checks += 1
	return true

func _run() -> void:
	var navigation: Dictionary = SectIsometricWorldV1.pve_navigation_grid()
	if not _check(not navigation.is_empty()
			and str(navigation.get("source_blob_sha","")).length() == 40
			and str(navigation.get("source_map","")) == "sect_isometric_source_a_pve_v1",
			"the reviewed Source A map has no pinned navigation identity"):
		return
	var battle := MapBattleV2.new(20261026)
	battle.world_mode = true
	battle.world_bounds = Rect2(Vector2.ZERO,Vector2(
		float(navigation["width"]),float(navigation["height"])))
	battle.world_navigation = navigation.duplicate(true)
	if not _check(battle._validate_world_navigation().is_empty(),
			"real Source A navigation cannot pass Combat V2 preflight"):
		return
	var registry := {
		"world_source_sha":str(navigation["source_blob_sha"]),
		"world_source_map":str(navigation["source_map"])
	}
	if not _check(HuntingPveRunV2.saved_world_identity_matches(battle,registry),
			"matching spawn registry and Combat V2 navigation were rejected"):
		return
	var changed_sha := registry.duplicate(true)
	# A different, well-formed 40-character SHA must not be mistaken for this
	# encounter's map merely because the stored identity has the right length.
	changed_sha["world_source_sha"] = "0123456789abcdef0123456789abcdef01234567"
	if str(changed_sha["world_source_sha"]) == str(registry["world_source_sha"]):
		changed_sha["world_source_sha"] = "fedcba9876543210fedcba9876543210fedcba98"
	if not _check(not HuntingPveRunV2.saved_world_identity_matches(
			battle,changed_sha),
			"a different saved camp-map SHA with valid length was accepted"):
		return
	var changed_map := registry.duplicate(true)
	changed_map["world_source_map"] = "JXQY2:other_map"
	if not _check(not HuntingPveRunV2.saved_world_identity_matches(
			battle,changed_map),
			"saved spawn-registry map label disagreed with Combat V2 navigation"):
		return
	var missing_identity := registry.duplicate(true)
	missing_identity.erase("world_source_map")
	if not _check(not HuntingPveRunV2.saved_world_identity_matches(
			battle,missing_identity),
			"missing saved map label was silently interpreted as verified"):
		return
	var invalid_world := MapBattleV2.new(20261026)
	invalid_world.world_mode = false
	invalid_world.world_navigation = navigation.duplicate(true)
	if not _check(not HuntingPveRunV2.saved_world_identity_matches(
			invalid_world,registry),
			"finite/non-world Combat V2 incorrectly accepted open-world save"):
		return
	var changed_navigation := MapBattleV2.new(20261026)
	changed_navigation.world_mode = true
	changed_navigation.world_navigation = navigation.duplicate(true)
	changed_navigation.world_navigation["source_blob_sha"] = "fedcba9876543210fedcba9876543210fedcba98"
	if not _check(not HuntingPveRunV2.saved_world_identity_matches(
			changed_navigation,registry),
			"changed Combat V2 navigation was accepted against old saved slots"):
		return
	if not _check(battle.now == 0.0 and battle.actors.is_empty()
			and registry["world_source_sha"] == navigation["source_blob_sha"],
			"read-only identity check mutated Combat V2 or source registry"):
		return
	print("PVE-SAVE-01 WORLD IDENTITY CONTRACT PASS checks=%d" % checks)
	quit(0)
