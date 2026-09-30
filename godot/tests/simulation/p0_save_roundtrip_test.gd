extends SceneTree

const SAVE_PATH := "user://tong_mon_p0_roundtrip.json"
const MALFORMED_SAVE_PATH := "user://tong_mon_p0_malformed.json"
const INVALID_VERSION_SAVE_PATH := "user://tong_mon_p0_invalid_version.json"
const ROUNDTRIP_FLOAT_TOLERANCE := 1.0e-12

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var state := P0Factory.create_state(24680)
	var scheduler := SimulationScheduler.new(state)
	scheduler.run_ticks(1000)

	var before_snapshot := state.to_dict()
	# Canonical in-memory state uses the same normalization path as a loaded save.
	# JSON can shift a float by the final representable bit while preserving the
	# same printed decimal value, so float fields are compared with a very tight
	# relative tolerance. Discrete state and RNG fields remain exact.
	var control := SimulationState.from_dict(before_snapshot)
	var canonical_snapshot := control.to_dict()

	var service := SaveService.new()
	var error := service.save_to_path(state, SAVE_PATH)
	if error != OK:
		_fail("Save failed with error %d." % error)
		return

	var loaded := service.load_from_path(SAVE_PATH)
	if loaded == null:
		_fail("Load returned null.")
		return

	var loaded_snapshot := loaded.to_dict()
	var roundtrip_mismatch := _first_mismatch(canonical_snapshot, loaded_snapshot, "state")
	if roundtrip_mismatch != "":
		_fail("Full-state mismatch after save/load round trip: %s" % roundtrip_mismatch)
		return

	if not _test_invalid_payload_rejection(service):
		_cleanup()
		quit(1)
		return

	var resumed := SimulationScheduler.new(loaded)
	var control_scheduler := SimulationScheduler.new(control)
	resumed.run_ticks(2000)
	control_scheduler.run_ticks(2000)

	var errors := loaded.validate_invariants()
	if not errors.is_empty():
		_fail("Loaded simulation violated invariants: %s" % " | ".join(errors))
		return

	var resumed_snapshot := loaded.to_dict()
	var control_snapshot := control.to_dict()
	var continuation_mismatch := _first_mismatch(control_snapshot, resumed_snapshot, "state")
	if continuation_mismatch != "":
		_fail("Resumed simulation diverged from the same-state control: %s" % continuation_mismatch)
		return

	print("P0 SAVE ROUNDTRIP TEST PASS")
	print("tick=", loaded.tick, " money=", loaded.total_money(), " disciples=", loaded.disciples.size())
	_cleanup()
	quit(0)

func _test_invalid_payload_rejection(service: SaveService) -> bool:
	if not _write_raw(MALFORMED_SAVE_PATH, "{\"save_version\":1}"):
		push_error("Could not create malformed-save fixture.")
		return false
	if service.load_from_path(MALFORMED_SAVE_PATH) != null:
		push_error("Malformed current-version save must be rejected instead of creating a default state.")
		return false

	if not _write_raw(INVALID_VERSION_SAVE_PATH, "{\"save_version\":-1}"):
		push_error("Could not create invalid-version save fixture.")
		return false
	if service.load_from_path(INVALID_VERSION_SAVE_PATH) != null:
		push_error("Negative save version must be rejected.")
		return false

	return true

func _write_raw(path: String, raw: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(raw)
	file.close()
	return true

func _first_mismatch(expected: Variant, actual: Variant, path: String) -> String:
	if expected is Dictionary and actual is Dictionary:
		var expected_dict: Dictionary = expected
		var actual_dict: Dictionary = actual
		for key in expected_dict.keys():
			if not actual_dict.has(key):
				return "%s.%s missing from loaded state" % [path, str(key)]
			var child_path := "%s.%s" % [path, str(key)]
			var mismatch := _first_mismatch(expected_dict[key], actual_dict[key], child_path)
			if mismatch != "":
				return mismatch
		for key in actual_dict.keys():
			if not expected_dict.has(key):
				return "%s.%s exists only in loaded state" % [path, str(key)]
		return ""

	if expected is Array and actual is Array:
		var expected_array: Array = expected
		var actual_array: Array = actual
		if expected_array.size() != actual_array.size():
			return "%s size expected=%d actual=%d" % [path, expected_array.size(), actual_array.size()]
		for index in range(expected_array.size()):
			var mismatch := _first_mismatch(expected_array[index], actual_array[index], "%s[%d]" % [path, index])
			if mismatch != "":
				return mismatch
		return ""

	if expected is float and actual is float:
		var expected_float := float(expected)
		var actual_float := float(actual)
		var delta := absf(expected_float - actual_float)
		var scale := maxf(1.0, maxf(absf(expected_float), absf(actual_float)))
		if delta <= ROUNDTRIP_FLOAT_TOLERANCE * scale:
			return ""
		return "%s float mismatch expected=%.17f actual=%.17f delta=%.17g" % [
			path,
			expected_float,
			actual_float,
			delta
		]

	if expected != actual or typeof(expected) != typeof(actual):
		return "%s expected(type=%s value=%s) actual(type=%s value=%s)" % [
			path,
			type_string(typeof(expected)),
			str(expected),
			type_string(typeof(actual)),
			str(actual)
		]

	return ""

func _fail(message: String) -> void:
	push_error(message)
	_cleanup()
	quit(1)

func _cleanup() -> void:
	for path in [SAVE_PATH, MALFORMED_SAVE_PATH, INVALID_VERSION_SAVE_PATH]:
		var absolute := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(absolute)
