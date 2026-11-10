extends RefCounted

# Original Godot GPU sparkle accent, isolated to opt-in V4 cinematic Lab.
# Not an effect source: never emits damage, an extra hit or a status.
# Event-driven + one-shot auto cleanup. Strict MAX_ACTIVE prevents
# uncontrolled GPU allocations with 4v8 or future 30v40 battles.
const MAX_ACTIVE := 10
const LOW_END_PARTICLES := 5
const FEATURE_ENABLED := "TMB_POISON_V4_CINEMATIC"
static var _glow_texture: Texture2D

static func _tex() -> Texture2D:
    if _glow_texture != null:
        return _glow_texture
    var im := Image.create(16, 16, false, Image.FORMAT_RGBA8)
    for y in range(16):
        for x in range(16):
            var distance := Vector2(float(x) - 7.5, float(y) - 7.5).length() / 7.5
            var alpha := pow(maxf(0.0, 1.0 - distance), 2.1)
            im.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
    _glow_texture = ImageTexture.create_from_image(im)
    return _glow_texture

static func active_count(parent: Node) -> int:
    var count := 0
    for child in parent.get_children():
        if child is GPUParticles2D and str(child.name).begins_with("V4SpellSpark"):
            count += 1
    return count

static func spawn(parent: Node, screen_at: Vector2, color: Color,
        critical: bool = false) -> bool:
    if OS.get_environment(FEATURE_ENABLED) != "1":
        return false
    if active_count(parent) >= MAX_ACTIVE:
        return false
    var node := GPUParticles2D.new()
    node.name = "V4SpellSpark"
    node.emitting = false
    node.one_shot = true
    node.amount = 9 if critical else LOW_END_PARTICLES
    node.lifetime = 0.32
    node.explosiveness = 0.92
    node.randomness = 0.28
    node.local_coords = false
    node.fixed_fps = 30
    node.texture = _tex()
    var process := ParticleProcessMaterial.new()
    process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
    process.direction = Vector3(0.0, -1.0, 0.0)
    process.spread = 165.0
    process.gravity = Vector3.ZERO
    process.initial_velocity_min = 23.0
    process.initial_velocity_max = 53.0 if critical else 39.0
    process.damping_min = 12.0
    process.damping_max = 26.0
    process.scale_min = 0.34
    process.scale_max = 0.68 if critical else 0.55
    process.color = color
    node.process_material = process
    var material := CanvasItemMaterial.new()
    material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
    node.material = material
    parent.add_child(node)
    node.position = screen_at
    node.finished.connect(func(): node.queue_free())
    node.restart()
    return true
