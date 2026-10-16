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
const CC0_WOLF_RUN_PATH := "res://assets/labs/combat_v4/cc0_wolf/wolf_run.png"
const STAGE_A_ROOT := "res://assets/p3/character_creator/parts/female_normal_v1/"
const SOURCE_TERRAIN := "res://assets/labs/combat_v4/terrain/stone_courtyard.png"
const SOURCE_ROAD := "res://assets/labs/combat_v4/roads/stone_branch.png"
const SOURCE_VEGETATION := "res://assets/labs/combat_v4/vegetation/570185.png"
const ORIGINAL_ART_FILES := {
    "wolf_idle": "res://assets/labs/combat_v4/original/thanh_lang_idle_concept_256.png",
    "wolf_walk": "res://assets/labs/combat_v4/original/thanh_lang_walk_concept_256.png",
    "wolf_run": "res://assets/labs/combat_v4/original/thanh_lang_run_concept_256.png",
    "wolf_attack": "res://assets/labs/combat_v4/original/thanh_lang_attack_concept_256.png",
    "wolf_hit": "res://assets/labs/combat_v4/original/thanh_lang_hit_concept_256.png",
    "wolf_downed": "res://assets/labs/combat_v4/original/thanh_lang_downed_concept_256.png",
    "boss_idle": "res://assets/labs/combat_v4/original/hac_lang_vuong_idle_concept_512.png",
    "human_idle": "res://assets/labs/combat_v4/original/01_idle_concept_512.png",
    "human_walk": "res://assets/labs/combat_v4/original/02_walk_concept_512.png",
    "human_attack": "res://assets/labs/combat_v4/original/04_attack_concept_512.png",
    "human_hit": "res://assets/labs/combat_v4/original/06_hit_concept_512.png",
    "human_downed": "res://assets/labs/combat_v4/original/07_downed_concept_512.png"
}
const ORIGINAL_ART_HASHES := {
    "wolf_idle": "66512ed97090af2f059c47aa7ac4b079396cf6b720432c5dcdde19ecf12499c2",
    "wolf_walk": "1c2e084b6182d6d899a664973d85f93e52bf54becb4c59029ad3238e028087e4",
    "wolf_run": "c965f466e1665e9f9ade6cacbf8c337c772a853db9677d8295a54b23bc61b161",
    "wolf_attack": "578a8732de8baf169066da26885f8f83ee1482120f4e04d583389014a4d9e63d",
    "wolf_hit": "341eb66656149fc36b6507300a37687d21425d9108bdb4ff0fd1fe6aefd620f6",
    "wolf_downed": "14e383b9b185c66ef0590a44323bad370f32e702b006c8799bb835f0e01490e1",
    "boss_idle": "b515de27e2e71a7f506294236f6b835bfb44777b33d3611b01c324c3f7c429bc",
    "human_idle": "32d94d5b1c02f5aac1dd7c9c0e803d454a83db52f287de48c2b1da2db7dbff61",
    "human_walk": "7738899b232c502134aa30ecf203790d89f1ca202cf9df63ebb2e8151f67e8a5",
    "human_attack": "86eedc20d95d5b4611b0f10b43255937a3d1c33acdb7ad6f302859b2a3ffc043",
    "human_hit": "cc67ee5cffb4ba0d60c4669e2b338e9f4c9fee48d83b52870208097e3e06c261",
    "human_downed": "82c7aede9d9e3f7797d1ad01045b7583189680aab47b5b71f2a1b15d4fc95241"
}
const SOURCE_HASHES := {
    "res://assets/labs/combat_v4/terrain/stone_courtyard.png": "c157965bd15f2747a55b602d4320dc34ad70c9129f79cc17eb8b4b139897468a",
    "res://assets/labs/combat_v4/roads/stone_branch.png": "1894d9047c73a6d9c80c8455b1a09209e49acb6eafed2922eb23446f190ab819",
    "res://assets/labs/combat_v4/vegetation/570185.png": "89fba324db3e3c6d850ed36ee2a3b0aea2021fa6a3d0712c569cae220fbe9655"
}

var battle: MapBattleV2
var disciple_visual: ModularDiscipleActor
var human_concept_sprite: Sprite2D
var stage_art_loaded := false
var last_disciple_position := Vector2(-999.0, -999.0)
var last_facing: StringName = &"right"
var fx: Array[Dictionary] = []
var source_textures: Dictionary = {}
var source_loaded: Array[String] = []
var jx_wolf_clips: Dictionary = {}
var jx_wolf_loaded := false
var jx_direction_row := CombatV4JX1Atlas.DEFAULT_ROW
var jx_current_clips: Dictionary = {}
var cc0_wolf_sheet: Texture2D
var cc0_wolf_loaded := false
var original_textures: Dictionary = {}
var monster_nodes: Dictionary = {}
var monster_previous_positions: Dictionary = {}
var monster_facing: Dictionary = {}
var monster_reactions: Dictionary = {}
var visual_clock := 0.0
var disciple_reaction_pose := ""
var disciple_reaction_until := 0.0

static func world_point(logical: Vector2) -> Vector2:
    return MAP_RECT.position + Vector2(
        logical.x / MapBattleV2.ARENA.size.x * MAP_RECT.size.x,
        logical.y / MapBattleV2.ARENA.size.y * MAP_RECT.size.y
    )

func _ready() -> void:
    # No asset is silently substituted for an APPROVED Source A image.
    for key in [SOURCE_TERRAIN, SOURCE_ROAD, SOURCE_VEGETATION]:
        if ResourceLoader.exists(key) and FileAccess.get_sha256(key).to_lower() == str(SOURCE_HASHES[key]):
            var texture := load(key) as Texture2D
            if texture != null:
                source_textures[key] = texture
                source_loaded.append(key)
    # Third-party original VLTK/JX1 art, locally staged only (not shipped in GitHub).
    # Requires exact original source bytes, not a guessed Wolf/King sprite.
    jx_wolf_clips = CombatV4JX1Atlas.load_verified()
    jx_wolf_loaded = jx_wolf_clips.size() == CombatV4JX1Atlas.CLIPS.size()
    # CC0 source: https://opengameart.org/content/pixel-wolf (alizard).
    # One side-profile sprite sheet, five 66x66 frames in a single 330x66 PNG.
    if ResourceLoader.exists(CC0_WOLF_RUN_PATH):
        var candidate: Texture2D = load(CC0_WOLF_RUN_PATH) as Texture2D
        if candidate != null and candidate.get_width() == 330 and candidate.get_height() == 66:
            cc0_wolf_sheet = candidate
            cc0_wolf_loaded = true
        else:
            push_warning("CMB-V4 CC0 Wolf ignored: atlas must be exactly 330x66.")
    # Generated, original concept art: not Source A. Import ONLY exact-checksum test images.
    for art_key in ORIGINAL_ART_FILES:
        var art_path: String = ORIGINAL_ART_FILES[art_key]
        if ResourceLoader.exists(art_path) and FileAccess.get_sha256(art_path).to_lower() == str(ORIGINAL_ART_HASHES[art_key]):
            var art_texture := load(art_path) as Texture2D
            if art_texture != null:
                original_textures[art_key] = art_texture
    queue_redraw()

func bind_battle(authority: MapBattleV2) -> void:
    battle = authority
    if disciple_visual != null:
        disciple_visual.queue_free()
    if human_concept_sprite != null:
        human_concept_sprite.queue_free()
        human_concept_sprite = null
    for n in monster_nodes.values():
        if is_instance_valid(n):
            (n as Sprite2D).queue_free()
    monster_nodes.clear()
    monster_previous_positions.clear()
    monster_facing.clear()
    monster_reactions.clear()
    jx_current_clips.clear()
    visual_clock = 0.0
    disciple_reaction_pose = ""
    disciple_reaction_until = 0.0
    disciple_visual = ModularDiscipleActor.new()
    disciple_visual.name = "StageA_Female_Proof"
    add_child(disciple_visual)
    disciple_visual.set_animation_library(CombatV4TwoWayMotion.build())
    var installed := FemaleStageAAssetLoader.apply_public_direction(disciple_visual, &"right")
    stage_art_loaded = int(installed.get("applied", 0)) == 14
    disciple_visual.set_status_text("")
    if not stage_art_loaded and original_textures.has("human_idle"):
        # Optional original-art illustration is an explicit pose PROOF, not a rig.
        disciple_visual.visible = false
        human_concept_sprite = Sprite2D.new()
        human_concept_sprite.name = "Original_Hero_Pose_Proof"
        human_concept_sprite.texture = original_textures["human_idle"]
        human_concept_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
        add_child(human_concept_sprite)
    last_disciple_position = Vector2(-999.0, -999.0)
    last_facing = CombatV4TwoWayFacing.RIGHT
    # The concept wolf/boss images are one SIDE profile, never Up/Down renders.
    var ids: Array = battle.actors.keys()
    ids.sort()
    for raw_id in ids:
        var actor: Dictionary = battle.actors[raw_id]
        if str(actor.get("side", "")) != "monster":
            continue
        var is_boss := str(actor.get("tier", "")) == "boss"
        var key := "boss_idle" if is_boss else "wolf_idle"
        if not original_textures.has(key) and not (not is_boss and (jx_wolf_loaded or cc0_wolf_loaded)):
            continue
        var sprite := Sprite2D.new()
        sprite.name = "Proof_" + str(raw_id)
        if not is_boss and jx_wolf_loaded:
            CombatV4JX1Atlas.setup_sprite(sprite, jx_wolf_clips, "st", jx_direction_row, 0.0, false)
        elif not is_boss and cc0_wolf_loaded:
            sprite.texture = cc0_wolf_sheet
            sprite.hframes = 5
            sprite.vframes = 1
            sprite.frame = 0
        else:
            sprite.texture = original_textures[key]
        sprite.centered = true
        sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
        add_child(sprite)
        monster_nodes[raw_id] = sprite
        monster_facing[raw_id] = CombatV4TwoWayFacing.LEFT
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
            var direction := CombatV4TwoWayFacing.for_motion(delta, last_facing)
            if direction != last_facing:
                FemaleStageAAssetLoader.apply_public_direction(disciple_visual, direction)
                last_facing = direction
            disciple_visual.play_walk_for_delta(CombatV4TwoWayFacing.directional_motion(direction))
        else:
            disciple_visual.current_clip = DiscipleActorVisualCatalog.CLIP_IDLE
            disciple_visual.set_facing_from_delta(Vector2.ZERO)
        if visual_clock < disciple_reaction_until:
            disciple_visual.current_clip = StringName(disciple_reaction_pose)
            disciple_visual.set_facing_from_delta(Vector2.ZERO)
        if human_concept_sprite != null:
            var visual_clip := "human_idle"
            if float(actor.get("hp", 0.0)) <= 0.0:
                visual_clip = "human_downed"
            elif visual_clock < disciple_reaction_until:
                visual_clip = "human_" + disciple_reaction_pose
            elif moving:
                visual_clip = "human_walk"
            if original_textures.has(visual_clip):
                human_concept_sprite.texture = original_textures[visual_clip]
            human_concept_sprite.flip_h = CombatV4TwoWayFacing.flip_h(last_facing)
            human_concept_sprite.scale = Vector2.ONE * 0.17
            human_concept_sprite.position = position_on_map - Vector2(0, 224.0 * 0.17)
            human_concept_sprite.z_index = disciple_visual.z_index
        last_disciple_position = logical
        disciple_visual.modulate.a = 0.36 if float(actor.get("hp", 0.0)) <= 0.0 else 1.0
        break
    _sync_monster_art()
    queue_redraw()

func _sync_monster_art() -> void:
    for raw_id in monster_nodes:
        if not battle.actors.has(raw_id):
            continue
        var actor: Dictionary = battle.actors[raw_id]
        var sprite: Sprite2D = monster_nodes[raw_id]
        var is_boss := str(actor.get("tier", "")) == "boss"
        var at := world_point(actor.get("position", Vector2.ZERO))
        var logical: Vector2 = actor.get("position", Vector2.ZERO)
        var previous: Vector2 = monster_previous_positions.get(raw_id, logical)
        var delta := logical - previous
        var moving := delta.length_squared() > 0.000001
        var facing: StringName = CombatV4TwoWayFacing.for_motion(delta, monster_facing.get(raw_id, CombatV4TwoWayFacing.LEFT))
        monster_facing[raw_id] = facing
        monster_previous_positions[raw_id] = logical
        # Source concept wolves face LEFT. Flip for RIGHT; vertical retains facing.
        sprite.flip_h = CombatV4TwoWayFacing.flip_h(facing, true)
        var using_jx: bool = not is_boss and jx_wolf_loaded
        var using_cc0: bool = not is_boss and not using_jx and cc0_wolf_loaded
        var base_scale := 1.45 if using_jx else (1.28 if using_cc0 else (0.42 if is_boss else 0.34))
        sprite.scale = Vector2.ONE * base_scale
        sprite.position = at if using_jx else at - Vector2(0, (30.0 if using_cc0 else (189.0 if is_boss else 90.0)) * base_scale)
        sprite.z_index = clampi(roundi(at.y), 0, 1000)
        sprite.modulate.a = 0.4 if float(actor.get("hp", 0.0)) <= 0.0 else 1.0
        var clip := "idle"
        if float(actor.get("hp", 0.0)) <= 0.0:
            clip = "downed"
        elif monster_reactions.has(raw_id) and visual_clock < float(monster_reactions[raw_id]["until"]):
            clip = str(monster_reactions[raw_id]["pose"])
        elif moving:
            clip = "walk"
        var desired := "boss_idle" if is_boss else "wolf_" + clip
        if using_jx:
            jx_current_clips[raw_id] = CombatV4JX1Atlas.clip_for_state(clip)
            CombatV4JX1Atlas.setup_sprite(sprite, jx_wolf_clips, jx_current_clips[raw_id],
                jx_direction_row, visual_clock, clip == "downed")
        elif using_cc0:
            sprite.frame = int(floor(visual_clock * 8.0)) % 5 if moving and clip != "downed" else 0
        elif original_textures.has(desired):
            sprite.texture = original_textures[desired]
        elif not is_boss and original_textures.has("wolf_idle"):
            sprite.texture = original_textures["wolf_idle"]

func consume_events(new_events: Array) -> void:
    # Emission is purely decorative. Backend damage has already happened.
    for raw in new_events:
        if not (raw is Dictionary):
            continue
        var event: Dictionary = raw
        match str(event.get("type", "")):
            "hit":
                var attacker_id := str(event.get("attacker", ""))
                if attacker_id == "pilot_female":
                    disciple_reaction_pose = "attack"
                    disciple_reaction_until = visual_clock + CombatV4TwoWayMotion.ATTACK_SECONDS
                if monster_nodes.has(attacker_id):
                    monster_reactions[attacker_id] = {"pose": "attack", "until": visual_clock + (0.44 if jx_wolf_loaded else 0.24)}
                var target_id := str(event.get("target", ""))
                var target: Dictionary = battle.actors.get(target_id, {})
                if not target.is_empty():
                    fx.append({"at": world_point(target["position"]), "ttl": 0.28, "kind": "hit"})
                if target_id == "pilot_female":
                    disciple_reaction_pose = "hit"
                    disciple_reaction_until = visual_clock + CombatV4TwoWayMotion.HIT_SECONDS
                if monster_nodes.has(target_id):
                    monster_reactions[target_id] = {"pose": "hit", "until": visual_clock + 0.23}
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
    visual_clock += maxf(0.0, delta)
    # Advance animation frames cosmetically WITHOUT stepping battle.
    if jx_wolf_loaded:
        for monster_id in jx_current_clips:
            if not monster_nodes.has(monster_id) or not battle.actors.has(monster_id):
                continue
            var current_sprite: Sprite2D = monster_nodes[monster_id]
            var current_clip: String = jx_current_clips[monster_id]
            CombatV4JX1Atlas.setup_sprite(current_sprite, jx_wolf_clips, current_clip,
                jx_direction_row, visual_clock, current_clip == "die")
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
        if not monster_nodes.has(raw_id):
            draw_set_transform(at, 0.0, Vector2(width, width * 0.76))
            draw_circle(Vector2.ZERO, 1.0, shade)
            draw_set_transform(Vector2.ZERO)
            draw_arc(at, width + 4, 0, TAU, 30, GOLD if boss else INK, 1.5)
        _draw_label(
            ("JX1 SÓI XÁM · 5 CLIPS" if not boss and jx_wolf_loaded else
            ("THANH LANG · CC0 RUN 5F" if not boss and cc0_wolf_loaded else
            ("BOSS · ORIGINAL POSE PROOF" if boss else "THANH LANG · ORIGINAL POSE PROOF")))
            if monster_nodes.has(raw_id) else
            ("BOSS · ART MISSING" if boss else "THANH LANG · ART MISSING"),
            at + Vector2(-90 if boss else -70, -110 if boss else -62), 11, INK
        )
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
        _draw_label(
            "ORIGINAL FEMALE POSE PROOF · STAGE A PACK ABSENT" if human_concept_sprite != null
            else "STAGE A PACK NOT INSTALLED · FALLBACK ONLY",
            Vector2(370, 590), 13, INK
        )
    if source_loaded.is_empty():
        _draw_label("ENV ART NOT STAGED · PROCEDURAL GROUND", Vector2(375, 610), 12, INK)

func _draw_label(value: String, at: Vector2, font_size: int, color: Color) -> void:
    draw_string(ThemeDB.fallback_font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
