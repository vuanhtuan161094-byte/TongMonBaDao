extends Node2D
# VFX18.1 ART LAB — an intermediate presentation layer between the back
# and front halves of the decorative qi orbit. No combat/data ownership.
const RIG = preload("res://labs/combat_lab/combat_lab_actor_rig_v2.gd")
const CASTER := Vector2(620.0, 378.0)

func _draw() -> void:
    var arena := get_parent()
    if arena == null:
        return
    var clock: float = float(arena.get("elapsed"))
    RIG.render(self,
        {"id":"vfx18_orbit_caster", "side":"disciple", "hp":100.0},
        CASTER, "fist", "cast", clock, 2.1, 1.0, 0.18)
