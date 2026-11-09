extends SceneTree

# V5.7 synthetic SIZE/PERFORMANCE test only; no claim that these 6000 wage
# receipts came from completed work. Never run this fixture in player saves.
const SAVE_PATH := "user://v57_save_480_receipts.json"
const PEOPLE := 480
const RECEIPTS := 6000

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup()
    var state := P37Factory.create_state(570480)
    var actor_index := 0
    while state.disciples.size() < PEOPLE:
        var id := StringName("v57_size_%04d" % actor_index)
        state.disciples[id] = DiscipleState.new({"id":str(id),"name":str(id)})
        actor_index += 1
    state.sect.disciple_capacity = PEOPLE
    state.sect.lodging_capacity = PEOPLE
    if state.disciples.size() != PEOPLE:
        _fail("wrong QA population")
        return
    # Real receipt envelope without issuing any player-facing job or currency.
    for i in range(RECEIPTS):
        state.sect.economy_a_receipts["wage:v57:size:%06d" % i] = {
            "kind":"wage","job_id":"v57:size:%06d" % i,
            "worker_id":"v57_size_%04d" % (i % actor_index),
            "paid":0,"due":2,"tick":state.tick
        }
    var save := SaveService.new()
    var began := Time.get_ticks_usec()
    var saved := save.save_to_path(state,SAVE_PATH)
    var write_ms := float(Time.get_ticks_usec()-began)/1000.0
    if saved != OK:
        _fail("480+6000 save failed")
        return
    var file := FileAccess.open(SAVE_PATH,FileAccess.READ)
    if file == null:
        _fail("cannot inspect saved file")
        return
    var size_bytes := file.get_length()
    file.close()
    began = Time.get_ticks_usec()
    var loaded := save.load_from_path(SAVE_PATH)
    var load_ms := float(Time.get_ticks_usec()-began)/1000.0
    if loaded == null or loaded.disciples.size() != PEOPLE             or loaded.sect.economy_a_receipts.size() != RECEIPTS:
        _fail("480-person/6000-receipt cold reload mismatch")
        return
    print("V57 SAVE 480/6000 BENCH "+JSON.stringify({
        "people":PEOPLE,"receipts":RECEIPTS,"save_bytes":size_bytes,
        "save_ms":write_ms,"load_ms":load_ms
    }))
    _cleanup()
    quit(0)

func _fail(message: String) -> void:
    push_error("V57 SAVE BENCH FAIL: "+message)
    _cleanup()
    quit(1)

func _cleanup() -> void:
    for suffix in ["",".tmp",".bak"]:
        var path: String = SAVE_PATH + str(suffix)
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
