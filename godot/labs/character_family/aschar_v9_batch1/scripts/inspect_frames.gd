extends SceneTree
func _initialize() -> void:
    var groups := {
      "walk_front": ["AS48_walk_front_f00_left_contact.png", "AS48_walk_front_f01_passing.png", "AS48_walk_front_f02_right_contact.png", "AS48_walk_front_f03_passing.png"],
      "attack_front": ["AS48_attack_front_f00_windup.png", "AS48_attack_front_f01_guard_rise.png", "AS48_attack_front_f02_release.png", "AS48_attack_front_f03_recovery.png"]
    }
    for group_name in groups:
        for file_name in groups[group_name]:
            var path := ProjectSettings.globalize_path("res://assets/frames/AS48/%s/%s" % [group_name,file_name])
            var im := Image.load_from_file(path)
            if im == null:
                print("LOAD_FAIL ",path)
                quit(2)
                return
            print(group_name," ",file_name," size=",im.get_size()," used=",im.get_used_rect()," format=",im.get_format())
    quit(0)
