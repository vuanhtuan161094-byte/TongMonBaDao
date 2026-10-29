extends SceneTree

const SAVE_PATH := "res://outputs/save_service_async_qa_20261028/save.json"

var checks := 0

func _init() -> void:
	call_deferred("_run")

func _check(valid: bool, message: String) -> bool:
	if not valid:
		push_error("SAVE SERVICE ASYNC TEST FAIL: "+message)
		_cleanup()
		quit(1)
		return false
	checks += 1
	return true

func _run() -> void:
	_cleanup()
	var output_dir := ProjectSettings.globalize_path(SAVE_PATH.get_base_dir())
	if not _check(DirAccess.make_dir_recursive_absolute(output_dir) == OK
			or DirAccess.dir_exists_absolute(output_dir),"could not create isolated save directory"):
		return
	var state := P0Factory.create_state(9281028)
	var service := SaveService.new()
	var baseline_tick := state.tick
	if not _check(service.save_to_path(state,SAVE_PATH) == OK,"initial synchronous SaveService write failed"):
		return
	state.tick = baseline_tick+1
	var async_tick := state.tick
	if not _check(service.start_save_to_path_async(state,SAVE_PATH) == OK
			and service.has_async_save_pending(),"could not start the async SaveService barrier"):
		return
	# A later live mutation must not leak into the immutable snapshot already queued.
	state.tick = async_tick+1
	var completed: Dictionary = await service.wait_for_async_save(self)
	if not _check(bool(completed.get("ok",false)) and not bool(completed.get("pending",true)),
		"async SaveService worker did not finish successfully: %s" % str(completed)):
		return
	var async_loaded := service.load_from_path(SAVE_PATH)
	if not _check(async_loaded != null and async_loaded.tick == async_tick,
		"async save did not preserve its submission-time state snapshot"):
		return
	var backup_loaded := service.load_from_path(SAVE_PATH+".bak")
	if not _check(backup_loaded != null and backup_loaded.tick == baseline_tick,
		"async commit did not retain the prior valid save as recovery backup"):
		return
	state.tick = async_tick+2
	var pending_tick := state.tick
	if not _check(service.start_save_to_path_async(state,SAVE_PATH) == OK,
		"second async SaveService barrier did not start"):
		return
	state.tick = pending_tick+1
	var synchronous_error := service.save_to_path(state,SAVE_PATH)
	if not _check(synchronous_error == OK and not service.has_async_save_pending(),
		"synchronous SaveService write did not join the pending atomic commit"):
		return
	var final_loaded := service.load_from_path(SAVE_PATH)
	if not _check(final_loaded != null and final_loaded.tick == state.tick,
		"synchronous follow-up save lost the latest state"):
		return
	var final_backup := service.load_from_path(SAVE_PATH+".bak")
	if not _check(final_backup != null and final_backup.tick == pending_tick,
		"follow-up commit did not retain the last async save in the backup"):
		return
	print("SAVE SERVICE ASYNC ROUNDTRIP PASS checks=%d snapshot_isolated=true joins_before_sync=true prior_backup_valid=true" % checks)
	_cleanup()
	quit(0)

func _cleanup() -> void:
	for path in [SAVE_PATH,SAVE_PATH+".tmp",SAVE_PATH+".bak"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
