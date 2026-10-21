@tool
class_name TmbCharacterSandboxPreview
extends RefCounted

const GearSystem = preload("res://src/simulation/equipment/equipment_system.gd")

static func build(preset: Dictionary, catalog: TmbSourceACatalog) -> Dictionary:
	var errors := TmbCharacterPresetSchema.validate(preset, catalog)
	if not errors.is_empty():
		return {"ok": false, "errors": errors}

	# This state and disciple exist only for this synchronous preview call. They
	# are never attached to a runtime, save service, scene, or production system.
	var state := SimulationState.new()
	var attributes: Dictionary = preset.get("attributes", {})
	var disciple := DiscipleState.new({
		"id": "tmb_character_studio_preview",
		"name": str(preset.get("name", "")),
		"sex_id": str(preset.get("sex", "")),
		"aptitude": float(attributes.get("aptitude", 0.0)),
		"constitution": float(attributes.get("constitution", 0.0)),
		"fortune": float(attributes.get("fortune", 0.0)),
		"comprehension": float(attributes.get("comprehension", 0.0)),
		"charisma": float(attributes.get("charisma", 0.0)),
		"potential": float(attributes.get("potential", 0.0)),
		"foundation_model_version": 2,
		"cultivation_stage_index": int(preset.get("skill_stage_index", 0))
	})
	state.disciples[disciple.id] = disciple
	state.sect.combat_skills_enabled = true
	state.sect.equipment_enabled = true

	for skill_id in preset.get("owned_skill_ids", []):
		disciple.learned_combat_skills[str(skill_id)] = true
	for item in preset.get("equipment_set", []):
		var recipe: Dictionary = GearSystem.RECIPES.get(str(item.get("recipe_id", "")), {})
		if recipe.is_empty():
			continue
		var slot := str(item.get("slot", ""))
		var synthetic_preview_item_id := "studio_preview_%s" % slot
		state.sect.equipment_items[synthetic_preview_item_id] = {
			"id": synthetic_preview_item_id,
			"recipe_id": str(item.get("recipe_id", "")),
			"slot": slot,
			"path": str(recipe.get("path", "")),
			"element": str(recipe.get("element", "")),
			"location": str(GearSystem.LOCATION_EQUIPPED),
			"owner_id": str(disciple.id),
			"stats": _copy_stats(recipe)
		}
		disciple.equipped_items[slot] = synthetic_preview_item_id

	var snapshot := DisciplePresentationSnapshotV2.build(state, disciple)
	var progression: Dictionary = preset.get("progression", {})
	var cultivation: Dictionary = progression.get("cultivation", {})
	var body: Dictionary = progression.get("body", {})
	var combat := DiscipleCombatLoadoutV2.build(
		state,
		disciple,
		int(cultivation.get("realm", 1)),
		int(cultivation.get("floor", 1)),
		int(body.get("realm", 1)),
		int(body.get("floor", 1)),
		str(preset.get("role", "frontline")),
		Vector2.ZERO,
		"dev_character_studio_preview"
	)
	var authentic_birth := DiscipleBirthProfileV2.valid_complete_birth(disciple.v2_birth_profile)
	var v2_progress_ready := DiscipleRealmProgressV2.progression_ready(disciple)
	return {
		"ok": bool(combat.get("ok", false)),
		"errors": [] if bool(combat.get("ok", false)) else [str(combat.get("reason", "combat_preview_failed"))],
		"snapshot": snapshot,
		"combat": combat,
		"cultivation_name": DiscipleRealmProgressV2.realm_name("cultivation", int(cultivation.get("realm", 1))),
		"body_name": DiscipleRealmProgressV2.realm_name("body", int(body.get("realm", 1))),
		"v2_birth_ready": authentic_birth,
		"v2_progress_ready": v2_progress_ready,
		"root_and_talents_status": "runtime" if authentic_birth else "DESIGN-ONLY",
		"accuracy_status": "DESIGN-ONLY",
		"evasion_status": "DESIGN-ONLY"
	}

static func _copy_stats(recipe: Dictionary) -> Dictionary:
	var stats: Variant = recipe.get("stats", {})
	return stats.duplicate(true) if stats is Dictionary else {}
