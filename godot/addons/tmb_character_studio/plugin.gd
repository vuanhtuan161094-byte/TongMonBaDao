@tool
extends EditorPlugin

const StudioDock = preload("res://addons/tmb_character_studio/ui/character_studio_dock.gd")

var _dock: Control

func _enter_tree() -> void:
	_dock = StudioDock.new()
	_dock.name = "Dev Character Studio"
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, _dock)

func _exit_tree() -> void:
	if _dock != null:
		remove_control_from_docks(_dock)
		_dock.queue_free()
		_dock = null
