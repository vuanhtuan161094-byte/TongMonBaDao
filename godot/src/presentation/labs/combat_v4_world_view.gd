extends Node2D
## CMB-V4-VP01 isolated READ-ONLY battle presentation.
## This node never calls MapBattleV2.step(), alters actors, or awards loot.
## Source A stage assets are optional external inputs; monster art is UNKNOWN.
const MAP_RECT := Rect2(Vector2(98.0, 84.0), Vector2(1084.0, 534.0))
const SCENE_GREEN := Color("#628c74")
const SOIL := Color("#a3a786")
const INK := Color("#263c35")
const ENEMY := Color("#936454")
const GOLD := Color("#d9bc78")
const STAGE_A_ROOT := "res://assets/p3/character_creator/parts/female_normal_v1/"
const SOURCE_TERRAIN := "res://assets/labs/combat_v4/terrain/stone_courtyard.png"
const SOURCE_ROAD := "res://assets/labs/combat_v4/roads/stone_branch.png"
const SOURCE_VEGETATION := "res://assets/labs/combat_v4/vegetation/570185.png"

var battle: MapBattleV2
var disciple_visual: ModularDiscipleActor
var stage_art_loaded := false
var last_disciple_position := Vector2(-999.0, -999.0)
var last_facing: StringName = &"right"
var fx: Array[Dictionary] = []
var source_textures: Dictionary = {}
var source_loaded: Array[String] = []

static func world_point(logical: Vector2) -> Vector2:
    return MAP_RECT.position + Vector2(
        logical.x / MapBattleV2.ARENA.size.x * MAP_RECT.size.x,
        logical.y / MapBattleV2.ARENA.size.y * MAP_RECT.size.y
    )

func _ready() -> void:
    # No asset is silently substituted for an APPROVED Source A image.
    for key in [SOURCE_TERRAIN, SOURCE_ROAD, SOURCE_VEGETATION]:
        if ResourceLoader.exists(key):
            var texture := load(key) as Texture2D
            if texture != null:
                source_textures[key] = texture
                source_loaded.append(key)
    queue_redraw()

func bind_battle(authority: MapBattleV2) -> void:
    battle = authority
    if disciple_visual != null:
        disciple_visual.queue_free()
    disciple_visual = ModularDiscipleActor.new()
    disciple_visual.name = "StageA_Female_Proof"
    add_child(disciple_visual)
    disciple_visual.set_animation_library(FemaleNormalV1MotionLibrary.build())
    var installed := FemaleStageAAssetLoader.apply_public_direction(disciple_visual, &"right")
    stage_art_loaded = int(installed.get("applied", 0)) == 14
    disciple_visual.set_status_text("")
    last_disciple_position = Vector2(-999.0, -999.0)
    sync_visuals()
    queue_redraw()

func sync_visuals() -> void:
    if battle == null or disciple_visual == null:
        return
    var disciple_ids: Array = battle.actors.keys()
    disciple_ids.sort()
    for raw_id in disciple_ids:
        var actor: Dictionary = battle.actors[raw_id]
        if str(actor.get("side", "")) != "disciple":
            continue
        var logical: Vector2 = actor.get("position", Vector2.ZERO)
        var position_on_map := world_point(logical)
        disciple_visual.position = position_on_map - DiscipleActorVisualCatalog.ACTOR_FOOT_POINT
        disciple_visual.z_index = clampi(roundi(position_on_map.y), 0, 1000)
        var moving := last_disciple_position.x > -900.0 and logical.distance_to(last_disciple_position) > 0.0001
        if moving:
            var delta := logical - last_disciple_position
            var direction := DiscipleActorVisualCatalog.direction_for_delta(delta, last_facing)
            if direction != last_facing:
                FemaleStageAAssetLoader.apply_public_direction(disciple_visual, direction)
                last_facing = direction
            disciple_visual.play_walk_for_delta(delta)
        else:
            disciple_visual.current_clip = DiscipleActorVisualCatalog.CLIP_IDLE
            disciple_visual.set_facing_from_delta(Vector2.ZERO)
        last_disciple_position = logical
        disciple_visual.modulate.a = 0.36 if float(actor.get("hp", 0.0)) <= 0.0 else 1.0
        break
    queue_redraw()

func consume_events(new_events: Array) -> void:
    # Emission is purely decorative. Backend damage has already happened.
    for raw in new_events:
        if not (raw is Dictionary):
            continue
        var event: Dictionary = raw
        match str(event.get("type", "")):
            "hit":
                var target_id := str(event.get("target", ""))
                var target: Dictionary = battle.actors.get(target_id, {})
                if not target.is_empty():
                    fx.append({"at": world_point(target["position"]), "ttl": 0.28, "kind": "hit"})
            "area_release":
                if event.has("center"):
                    fx.append({"at": world_point(event["center"]), "ttl": 0.38, "kind": "burst"})
            "heal":
                var healed: Dictionary = battle.actors.get(str(event.get("target", "")), {})
                if not healed.is_empty():
                    fx.append({"at": world_point(healed["position"]), "ttl": 0.5, "kind": "heal"})
    if fx.size() > 16:
        fx = fx.slice(fx.size() - 16)
    queue_redraw()

func advance_cosmetics(delta: float) -> void:
    for i in range(fx.size() - 1, -1, -1):
        fx[i]["ttl"] = float(fx[i]["ttl"]) - delta
        if float(fx[i]["ttl"]) <= 0.0:
            fx.remove_at(i)
    if not fx.is_empty():
        queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(-900.0, -700.0, 3200.0, 2300.0), Color("#d1d6b2"))
    draw_rect(MAP_RECT, Color("#a4b99d"))
    # Bounded visual landscape only. These props do NOT create collision or navigation.
    for i in range(44):
        var x := 105.0 + float(posmod(i * 167, 1050))
        var y := 94.0 + float(posmod(i * 83 + 47, 515))
        var p := Vector2(x, y)
        var tint := SCENE_GREEN.lightened(0.08) if i % 3 == 0 else SCENE_GREEN
        draw_circle(p, float(8 + i % 7), tint.darkened(0.08) if i % 5 == 0 else tint)
        draw_circle(p + Vector2(4, -3), float(4 + i % 4), Color("#8faf8e"))
    # Unobtrusive path behind actors. Image used only if exact verified PNG was staged.
    var path := PackedVector2Array([
        Vector2(111, 412), Vector2(320, 365), Vector2(510, 400),
        Vector2(725, 320), Vector2(940, 345), Vector2(1170, 280)
    ])
    draw_polyline(path, Color("#c7baa0"), 48.0, true)
    draw_polyline(path, Color("#dfd4ad"), 37.0, true)
    if source_textures.has(SOURCE_TERRAIN):
        draw_texture_rect(source_textures[SOURCE_TERRAIN], Rect2(125, 116, 135, 75), false, Color(1, 1, 1, 0.48))
    if source_textures.has(SOURCE_ROAD):
        draw_texture_rect(source_textures[SOURCE_ROAD], Rect2(655, 322, 106, 54), false, Color(1, 1, 1, 0.56))
    if source_textures.has(SOURCE_VEGETATION):
        draw_texture_rect(source_textures[SOURCE_VEGETATION], Rect2(108, 115, 110, 140), false, Color(1, 1, 1, 0.86))
    # Monster visuals deliberately say PLACEHOLDER: no forged Source A identity.
    if battle == null:
        return
    var ids: Array = battle.actors.keys()
    ids.sort()
    for raw_id in ids:
        var a: Dictionary = battle.actors[raw_id]
        if str(a.get("side", "")) != "monster":
            continue
        var at := world_point(a.get("position", Vector2.ZERO))
        var boss := str(a.get("tier", "")) == "boss"
        var alive := float(a.get("hp", 0.0)) > 0.0
        var width := 24.0 if boss else 15.0
        var shade := Color("#65495b") if boss else ENEMY
        if not alive:
            shade = Color("#919c93")
        draw_set_transform(at, 0.0, Vector2(width, width * 0.76))
        draw_circle(Vector2.ZERO, 1.0, shade)
        draw_set_transform(Vector2.ZERO)
        draw_arc(at, width + 4, 0, TAU, 30, GOLD if boss else INK, 1.5)
        _draw_label("BOSS · ART MISSING" if boss else "THANH LANG · ART MISSING",
            at + Vector2(-61 if boss else -65, -width - 19), 12, INK)
        if boss or alive and float(a.get("hp", 0.0)) < float(a.get("max_hp", 1.0)) * 0.45:
            var hp_ratio := clampf(float(a.get("hp", 0.0)) / maxf(1.0, float(a.get("max_hp", 0.0))), 0, 1)
            draw_rect(Rect2(at + Vector2(-25, -width - 8), Vector2(50, 4)), Color("#4b4d3d"))
            draw_rect(Rect2(at + Vector2(-25, -width - 8), Vector2(50.0 * hp_ratio, 4)), Color("#bf6256"))
    # Only actual AoE casts have center/radius; learned skill casts do not.
    for pending in battle.pending_casts:
        if not (pending is Dictionary) or not pending.has("center") or not pending.has("radius"):
            continue
        var center := world_point(pending["center"])
        var radius := float(pending["radius"])
        var scaled := Vector2(radius * MAP_RECT.size.x / 36.0, radius * MAP_RECT.size.y / 20.0)
        draw_set_transform(center, 0.0, scaled)
        draw_circle(Vector2.ZERO, 1, Color(0.82, 0.28, 0.24, 0.09))
        draw_arc(Vector2.ZERO, 1.0, 0, TAU, 48, Color(0.78, 0.23, 0.22, 0.81), 0.022)
        draw_set_transform(Vector2.ZERO)
    for e in fx:
        var at: Vector2 = e["at"]
        var ttl := float(e["ttl"])
        var kind := str(e["kind"])
        draw_arc(at, 19.0 + (0.5 - ttl) * 17.0, -1.9, 1.4, 28,
            Color("#68a995") if kind == "heal" else Color("#e2ba72"), 2.2)
    if not stage_art_loaded:
        _draw_label("STAGE A PACK NOT INSTALLED · FALLBACK ONLY", Vector2(370, 590), 16, INK)
    if source_loaded.is_empty():
        _draw_label("ENV ART NOT STAGED · PROCEDURAL GROUND", Vector2(375, 610), 12, INK)

func _draw_label(value: String, at: Vector2, font_size: int, color: Color) -> void:
    draw_string(ThemeDB.fallback_font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
