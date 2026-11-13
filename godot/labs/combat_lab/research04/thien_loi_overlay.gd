extends Node2D
# Light-only additive overlay. Characters are rendered on the parent canvas
# with their normal materials; NEVER blend-add the physical rig itself.
const THUNDER = preload("res://labs/combat_lab/research04/thien_loi_vfx.gd")
const LIGHT_SHADER = preload("res://labs/combat_lab/combat_lab_v9_energy_light.gdshader")

func _ready() -> void:
    var mat := ShaderMaterial.new()
    mat.shader = LIGHT_SHADER
    mat.set_shader_parameter("light_gain", 1.19)
    material = mat
    set_process(false)

func _draw() -> void:
    var arena: Node = get_parent()
    if arena == null:
        return
    var clock := fposmod(float(arena.get("elapsed")),
        THUNDER.LOOP_SECONDS) / THUNDER.LOOP_SECONDS
    # Class constant is not reflected as a property via Object.get().
    var caster := Vector2(298.0, 464.0)
    var victims: Array = arena.get("approved_hits")
    var mode: int = int(arena.get("thunder_mode"))
    THUNDER.render(self, caster, victims, clock, mode, 2)
