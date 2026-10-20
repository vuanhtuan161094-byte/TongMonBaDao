extends SceneTree

func _init() -> void:
    var user_dir := OS.get_user_data_dir().replace("\\", "/").trim_suffix("/")
    var sandbox := ProjectSettings.globalize_path("user://demo_sandbox").replace("\\", "/").trim_suffix("/")
    var expected := user_dir + "/demo_sandbox"
    if sandbox.to_lower() != expected.to_lower():
        push_error("ResetDemo path guard rejected target: " + sandbox)
        quit(2)
        return
    print("RESET_DEMO_USER_DATA_DIR=" + user_dir)
    if not DirAccess.dir_exists_absolute(sandbox):
        print("RESET_DEMO_RESULT=EMPTY")
        quit(0)
        return
    var error := _remove_tree(sandbox)
    if error != OK:
        push_error("ResetDemo failed inside isolated sandbox: " + error_string(error))
        quit(1)
        return
    print("RESET_DEMO_RESULT=PASS target=" + sandbox)
    quit(0)

func _remove_tree(path: String) -> Error:
    var directory := DirAccess.open(path)
    if directory == null:
        return DirAccess.get_open_error()
    for file_name in directory.get_files():
        var file_path := path + "/" + file_name
        var remove_error := DirAccess.remove_absolute(file_path)
        if remove_error != OK:
            return remove_error
    for child_name in directory.get_directories():
        var child_path := path + "/" + child_name
        var nested_error := _remove_tree(child_path)
        if nested_error != OK:
            return nested_error
        var remove_directory_error := DirAccess.remove_absolute(child_path)
        if remove_directory_error != OK:
            return remove_directory_error
    return DirAccess.remove_absolute(path)
