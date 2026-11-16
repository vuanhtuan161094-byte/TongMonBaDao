extends Node2D
## AS-CHAR-49 V10 × approved Poison/Talisman VFX — isolated visual/playable QA.
## Does not create real combat receipts, HP changes, status writes, SaveService or PvE integration.
## Does not modify approved source artwork or puppet/rig any character.
const BASE := "res://labs/combat_lab/as_char49_vfx_playtest/"
const HERO_RESOURCE := BASE + "FemaleSwordV10.tres"
const MONSTER_RESOURCE := "res://assets/actors/v5_sa_monster_1113031_1/animations.tres"
const SKILLS := [
    "ĐỘC  Xà Ảnh Quấn Mạch   POI02",
    "ĐỘC  Phụ Cốt Cổ          POI03",
    "ĐỘC  Cổ Vụ Mê Tung      POI04",
    "PHÙ  Thiên Lôi Dẫn Nét  TAL02",
    "PHÙ  Lôi Văn Truy Ấn    TAL03",
    "PHÙ  Liên Diệm Phần Giới HF02 R6",
    "PHÙ  Hỏa Tâm Ngưng Phù  HF03 R2",
]
const ART := [
    ["res://labs/combat_lab/poison02/assets/serpent-flight-atlas.webp", "res://labs/combat_lab/poison02/assets/serpent-bind-back-4pose.webp", "res://labs/combat_lab/poison02/assets/serpent-bind-front-4pose.webp"],
    ["res://labs/combat_lab/poison03/assets/fu_cot_gu_master.svg", "res://labs/combat_lab/poison03/assets/fu_cot_bone_seal.svg"],
    ["res://labs/combat_lab/poison04/assets/co_vu_painted_cloud.svg", "res://labs/combat_lab/poison04/assets/co_vu_smoke_tendril.svg", "res://labs/combat_lab/poison04/assets/co_vu_gu_moth.svg"],
    ["res://labs/combat_lab/talisman02/assets/tal02_thunder_flipbook.webp", "res://labs/combat_lab/talisman02/assets/tal02_fracture_impact.webp"],
    ["res://labs/combat_lab/talisman03/assets/tal03_mark_flipbook.webp"],
    [BASE + "approved_art/tal07_r5_lotus_atlas.webp", BASE + "approved_art/tal07_r6_charge_atlas.webp", BASE + "approved_art/tal07_r6_flying_atlas.webp", BASE + "approved_art/tal07_r5_contact_atlas.webp", BASE + "approved_art/tal07_ground_flipbook.webp"],
    [BASE + "approved_art/tal08_r1_charge.webp", BASE + "approved_art/tal08_r1_projectile.webp", BASE + "approved_art/tal08_r1_contact.webp"],
]
const TIMINGS := [
    [0.83, 1.63, 2.85, 3.48],
    [0.60, 1.55, 2.60, 3.12],
    [0.79, 1.35, 3.20, 4.05],
    [0.62, 1.39, 1.76, 2.72],
    [0.50, 0.88, 6.88, 7.14],
    [0.52, 1.37, 1.72, 2.62],
    [0.52, 1.30, 1.81, 2.36],
]
const ARENA := Rect2(66.0, 255.0, 1145.0, 400.0)
const HERO_SPEED := 220.0
const DIRS := ["Front", "Right", "Back", "Left"]

var hero: AnimatedSprite2D
var mobs: Array[Dictionary] = []
var fx_layers: Array[Node2D] = []
var textures: Array = []
var errors: Array[String] = []
var hud: Label
var info: Label
var current_skill := 0
var target_idx := 0
var facing := "Right"
var elapsed := 0.0
var paused := false
var monster_movement := true
var show_fx := true
var actions: Array[Dictionary] = []
var main_ready := false
var active_motion := ""
var active_motion_until := 0.0
var emitted := 0
var collision_count := 0
var last_event := "LAB_BOOT"

func _ready() -> void:
    RenderingServer.set_default_clear_color(Color("0c1421"))
    var frames: SpriteFrames = load(HERO_RESOURCE) as SpriteFrames
    if frames == null:
        push_error("QA49_MISSING_CHARACTER_V10_RESOURCE " + HERO_RESOURCE)
        return
    hero = AnimatedSprite2D.new()
    hero.name = "FemaleSwordV10"
    hero.sprite_frames = frames
    hero.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    hero.position = Vector2(255, 515)
    hero.offset = Vector2(0, -170)
    hero.scale = Vector2.ONE * 0.44
    hero.z_index = 5
    add_child(hero)
    _set_hero_animation("Idle_Right", true)
    var monster_frames := load(MONSTER_RESOURCE) as SpriteFrames
    if monster_frames == null or not monster_frames.has_animation("walk"):
        errors.append("THIẾU QUÁI THẬT: " + MONSTER_RESOURCE)
        push_error("QA49_MISSING_REAL_MONSTER_ASSET")
    else:
        for i in range(3):
            var mob := AnimatedSprite2D.new()
            mob.name = "MovingMonster_%d" % i
            mob.sprite_frames = monster_frames
            mob.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
            mob.position = Vector2(790 + i * 140, 430 + (i % 2) * 95)
            mob.offset = Vector2(0, -135)
            mob.scale = Vector2.ONE * 0.43
            mob.z_index = 5
            add_child(mob)
            mob.play("walk")
            mobs.append({"node": mob, "id": i, "speed": 60.0 + float(i) * 25.0, "phase": 1.4 * float(i), "flash_until": -1.0})
    for pack in ART:
        var group: Array = []
        for path in pack:
            var asset := load(path) as Texture2D
            if asset == null:
                errors.append("VFX ASSET MISSING: " + path)
            group.append(asset)
        textures.append(group)
    var layer_script: Script = load(BASE + "fx_layer.gd") as Script
    for front in [false, true]:
        var layer := Node2D.new()
        layer.set_script(layer_script)
        layer.set("stage", self)
        layer.set("front", front)
        layer.z_index = 7 if front else 3
        layer.name = "VFXFront" if front else "VFXBack"
        add_child(layer)
        fx_layers.append(layer)
    var canvas := CanvasLayer.new()
    canvas.layer = 30
    add_child(canvas)
    hud = Label.new()
    hud.position = Vector2(24, 14)
    hud.add_theme_font_size_override("font_size", 19)
    hud.add_theme_color_override("font_color", Color("e8edfa"))
    canvas.add_child(hud)
    info = Label.new()
    info.position = Vector2(24, 685)
    info.add_theme_font_size_override("font_size", 17)
    canvas.add_child(info)
    main_ready = true
    _hud()
    set_process(true)
    print("QA49_VFX_MOVING_LAB_READY | REAL_CHARACTER_V10=true | real_monsters=", mobs.size(), " | skills=7 | visual_only=true | engine_native_boot=true")
    if errors.size() > 0:
        print("QA49_ASSET_GAPS_COUNT=", errors.size())

func _unhandled_input(ev: InputEvent) -> void:
    if not main_ready: return
    if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
        var where := get_global_mouse_position()
        var best := 1.0e10
        for i in range(mobs.size()):
            var d := where.distance_squared_to(_mob_pos(i))
            if d < best:
                target_idx = i
                best = d
        _hud()
    if not ev is InputEventKey or not ev.pressed or ev.echo: return
    if ev.keycode >= KEY_1 and ev.keycode <= KEY_7:
        current_skill = int(ev.keycode) - int(KEY_1)
        _cast(current_skill)
    elif ev.keycode == KEY_TAB:
        if mobs.size() > 0: target_idx = (target_idx + 1) % mobs.size()
    elif ev.keycode == KEY_SPACE:
        active_motion = "Attack"
        active_motion_until = elapsed + 0.48
        _set_hero_animation("Attack_" + facing, true)
        last_event = "SWORD_SWING_DEMO (NO HP RECEIPT)"
    elif ev.keycode == KEY_H:
        hud.visible = not hud.visible
    elif ev.keycode == KEY_V:
        show_fx = not show_fx
    elif ev.keycode == KEY_M:
        monster_movement = not monster_movement
    elif ev.keycode == KEY_P:
        paused = not paused
    elif ev.keycode == KEY_R:
        hero.position = Vector2(255, 515)
        actions.clear()
        emitted = 0
        elapsed = 0.0
    _hud()

func _cast(skill: int) -> void:
    if mobs.is_empty():
        last_event = "BLOCKED_NO_REAL_MONSTER"
        return
    var ok := true
    for tex in textures[skill]:
        if tex == null: ok = false
    if not ok:
        last_event = "ASSET_MISSING (NO FAKE APPROVED VFX): " + SKILLS[skill]
        _hud()
        return
    var locked: Array[int] = []
    locked.append(target_idx)
    # Only circle/cap3 (POI04/HF02) and line/cap3 (TAL02) lock 3 monsters.
    if skill in [2, 3, 5]:
        for i in range(mobs.size()):
            if i != target_idx and locked.size() < 3: locked.append(i)
    var position := _mob_pos(target_idx)
    actions.append({"skill": skill, "t0": elapsed, "locked": locked, "frozen_aoe": position, "start_hero": hero.position, "event_reported": false})
    active_motion = "Cast"
    active_motion_until = elapsed + 0.62
    _set_hero_animation("Cast_" + facing, true)
    emitted += 1
    last_event = "CAST_DEMO " + SKILLS[skill] + " LOCK=" + str(locked)
    print("QA49_CAST_DEMO skill=", skill, " locked_ids=", locked, " moving_target=true visual_only=true")
    _hud()

func _process(delta: float) -> void:
    if not main_ready or paused: return
    var dt := minf(delta, 0.05)
    elapsed += dt
    var direction := Vector2.ZERO
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): direction.x -= 1.0
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): direction.x += 1.0
    if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): direction.y -= 1.0
    if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): direction.y += 1.0
    if direction.length_squared() > 0.1:
        direction = direction.normalized()
        if absf(direction.x) > absf(direction.y): facing = "Right" if direction.x > 0 else "Left"
        else: facing = "Front" if direction.y > 0 else "Back"
        hero.position += direction * HERO_SPEED * dt
        hero.position.x = clampf(hero.position.x, ARENA.position.x + 25, ARENA.end.x - 25)
        hero.position.y = clampf(hero.position.y, ARENA.position.y + 85, ARENA.end.y - 18)
    if elapsed >= active_motion_until:
        active_motion = ""
    if active_motion != "":
        _set_hero_animation(active_motion + "_" + facing)
    else:
        _set_hero_animation(("Walk_" if direction.length_squared() > 0.1 else "Idle_") + facing)
    if monster_movement:
        for i in range(mobs.size()):
            var spr: AnimatedSprite2D = mobs[i]["node"]
            var v: Vector2
            var speed: float = mobs[i]["speed"]
            if i == 0:
                v = (hero.position - spr.position).normalized()
            else:
                var f: float = elapsed * (0.71 + i * 0.11) + mobs[i]["phase"]
                v = Vector2(cos(f), sin(f * 0.84) * 0.63).normalized()
            spr.position += v * speed * dt
            if spr.position.x < 620 or spr.position.x > 1150: spr.position.x = clampf(spr.position.x, 620, 1150)
            if spr.position.y < 349 or spr.position.y > 637: spr.position.y = clampf(spr.position.y, 349, 637)
    for i in range(mobs.size()):
        var body: AnimatedSprite2D = mobs[i]["node"]
        body.modulate = Color("ffd7b2") if elapsed < float(mobs[i]["flash_until"]) else Color.WHITE
    for j in range(actions.size() - 1, -1, -1):
        var a: Dictionary = actions[j]
        var t: float = elapsed - float(a["t0"])
        var kind: int = a["skill"]
        if t > float(TIMINGS[kind][3]) + 0.1:
            actions.remove_at(j)
            continue
        if not a["event_reported"] and t >= float(TIMINGS[kind][1]):
            # Event log deliberately reports visual proximity, not gameplay damage.
            var contacts: Array[int] = []
            for mi in a["locked"]:
                var eligible := true
                if kind == 5:
                    eligible = _mob_pos(mi).distance_to(a["frozen_aoe"]) <= 175.0
                elif kind == 3:
                    eligible = _distance_to_cast_line(mi, a) <= 92.0
                if eligible:
                    contacts.append(mi)
                    mobs[mi]["flash_until"] = elapsed + 0.16
            a["event_reported"] = true
            collision_count += contacts.size()
            last_event = "VISUAL_CONTACT_ONLY skill=" + str(kind + 1) + " IDs=" + str(contacts)
            print("QA49_VISUAL_CONTACT_ONLY skill=", kind, " ids=", contacts, " moving_monsters=true no_hp_changes=true")
    for fx in fx_layers: fx.queue_redraw()
    queue_redraw()
    _hud()

func _distance_to_cast_line(i: int, a: Dictionary) -> float:
    var start: Vector2 = a["start_hero"] + Vector2(35, -72)
    var stop: Vector2 = _mob_pos(a["locked"][0]) + Vector2(0, -65)
    var dir: Vector2 = stop - start
    var q: float = clampf((_mob_pos(i) - start).dot(dir) / maxf(dir.length_squared(), 1.0), 0.0, 1.0)
    return (_mob_pos(i) - start.lerp(stop, q)).length()

func _set_hero_animation(which: String, restart := false) -> void:
    if not hero.sprite_frames.has_animation(which): return
    if restart or hero.animation != which:
        hero.play(which)

func _mob_pos(i: int) -> Vector2:
    if i < 0 or i >= mobs.size(): return Vector2(900, 500)
    var node: AnimatedSprite2D = mobs[i]["node"]
    return node.position

func _hud() -> void:
    if hud == null: return
    var err := "ALL ART PATHS PRESENT" if errors.size() == 0 else "ART PATH GAPS: %d (click skill to see blocked)" % errors.size()
    hud.text = "AS-CHAR-49 V10 × ĐỘC/PHÙ APPROVED ART | MOVING LAB | NO GAMEPLAY HP\n" \
        + "WASD / MŨI TÊN: đi; 1–7: VFX; SPACE: Attack; CLICK/TAB: chọn quái; M: AI; V: VFX; P: pause; R: reset\n" \
        + "Kỹ năng: %s | target=%d | cast=%d | visual contacts=%d | monsters=%d | %s" % [SKILLS[current_skill], target_idx + 1, emitted, collision_count, mobs.size(), err]
    if info != null:
        info.text = "%s | VFX art approved ONLY in original source; moving mix is NOT owner/native QA approved | Death_Left MISSING" % last_event

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color("121a29"))
    draw_rect(Rect2(60, 250, 1160, 410), Color("283a38"), true)
    for i in range(14):
        var y := 263.0 + float(i) * 28.5
        draw_line(Vector2(73, y), Vector2(1205, y + 9), Color("c0d6b2", 0.052), 1.0)
    for i in range(13):
        var x := 90.0 + float(i) * 87.0
        draw_line(Vector2(x, 263), Vector2(x + 36, 655), Color("c8dcbb", 0.041), 1.0)
    for i in range(3):
        if i < mobs.size():
            var at := _mob_pos(i)
            draw_arc(at + Vector2(0, 8), 46.0 if i == target_idx else 37.0, 0, TAU, 42, Color("ffce79", .92) if i == target_idx else Color("93c1a4", .25), 1.6)
    draw_rect(Rect2(0, 0, 1280, 127), Color("0f1420"), true)
    draw_rect(Rect2(0, 670, 1280, 50), Color("0c111a"), true)

func draw_fx_layer(layer: Node2D, is_front: bool) -> void:
    if not show_fx: return
    for a in actions:
        _draw_one_fx(layer, is_front, a)

func _tex(index: int, sub: int) -> Texture2D:
    if index < 0 or index >= textures.size() or sub >= textures[index].size(): return null
    return textures[index][sub]

func _show_rect(layer: Node2D, tex: Texture2D, center: Vector2, size: Vector2, alpha := 1.0, tint := Color.WHITE) -> void:
    if tex == null or alpha <= 0.002: return
    var c := tint
    c.a *= alpha
    layer.draw_texture_rect(tex, Rect2(center - size * 0.5, size), false, c)

func _show_atlas(layer: Node2D, tex: Texture2D, cols: int, rows: int, frame: int, center: Vector2, size: Vector2, alpha := 1.0, tint := Color.WHITE) -> void:
    if tex == null or alpha <= .002: return
    var cell := tex.get_size() / Vector2(cols, rows)
    var src := Rect2(Vector2(float(frame % cols) * cell.x, float(int(frame / cols)) * cell.y), cell)
    var c := tint
    c.a *= alpha
    layer.draw_texture_rect_region(tex, Rect2(center - size * .5, size), src, c)

func _fade(t: float, start: float, end: float) -> float:
    return 1.0 - smoothstep(start, end, t)

func _travel(t: float, launch: float, contact: float) -> float:
    return smoothstep(launch, contact, t)

func _draw_one_fx(layer: Node2D, front: bool, a: Dictionary) -> void:
    var kind: int = a["skill"]
    var t: float = elapsed - float(a["t0"])
    var target: Vector2 = _mob_pos(a["locked"][0])
    var start := hero.position + Vector2(46, -86)
    var contact := target + Vector2(0, -73)
    var launch: float = TIMINGS[kind][0]
    var hit_at: float = TIMINGS[kind][1]
    var sustain: float = TIMINGS[kind][2]
    var fade_end: float = TIMINGS[kind][3]
    var charge := smoothstep(0.06, 0.23, t) * _fade(t, launch * .78, launch + .10)
    var proj := _travel(t, launch, hit_at)
    var flight := smoothstep(0.0, .13, proj) * (1.0 - smoothstep(.88, 1.0, proj)) if t >= launch and t < hit_at else 0.0
    var impact := smoothstep(hit_at, hit_at + .065, t) * _fade(t, hit_at + .18, minf(hit_at + .65, sustain))
    if kind == 0:  # POI02 approved R4 source: painted six-pose snake + authored front/back coil.
        if not front and t >= launch and t < hit_at:
            var p := start.lerp(contact, proj) + Vector2(0, -86.0 * sin(PI * proj))
            _show_atlas(layer, _tex(0,0), 3,2,clampi(int(proj * 5.99),0,5),p,Vector2(282,102),flight)
        if t >= hit_at and t < fade_end:
            var gain := smoothstep(hit_at, hit_at + .14, t) * _fade(t, sustain, fade_end)
            var frame := clampi(int(maxf(t-hit_at,0.0) * 4.5),0,3)
            _show_atlas(layer, _tex(0,2 if front else 1),2,2,frame,target+Vector2(0,-91),Vector2(210,182),gain)
    elif kind == 1:  # POI03 approved original SVG gu and seal; lock one moving target.
        if not front and t < hit_at:
            _show_rect(layer, _tex(1,0),start if t < launch else start.lerp(contact,proj)+Vector2(0,-70*sin(PI*proj)),Vector2(126,126),charge if t < launch else flight)
        if front and t >= hit_at and t < fade_end:
            var m := smoothstep(hit_at,hit_at+.17,t) * _fade(t,sustain,fade_end)
            _show_rect(layer,_tex(1,1),contact,Vector2(91,91),m*.79)
    elif kind == 2:  # POI04 circle poison fog follows demo locked group center; cap3.
        var center := Vector2.ZERO
        for id in a["locked"]: center += _mob_pos(id)
        center /= float(maxi(1,a["locked"].size()))
        if not front:
            if t < hit_at:
                _show_rect(layer,_tex(2,2),start if t<launch else start.lerp(center+Vector2(0,-38),proj),Vector2(90,88),charge if t<launch else flight)
            if t >= hit_at and t < fade_end:
                var mist := smoothstep(hit_at,sustain-.7,t) * _fade(t,sustain,fade_end)
                for i in range(4):
                    var phase := t * (0.75 + float(i)*0.1) + float(i)*1.5
                    var at := center+Vector2((i-1.5)*115+19*sin(phase),-60+23*cos(phase))
                    _show_rect(layer,_tex(2,0),at,Vector2(260,175),mist * .63)
        elif t >= hit_at and t < fade_end:
            var gain := smoothstep(hit_at,sustain-.7,t) * _fade(t,sustain,fade_end)
            for id in a["locked"]:
                _show_rect(layer,_tex(2,1),_mob_pos(id)+Vector2(0,-84),Vector2(75,126),gain*.32)
    elif kind == 3:  # TAL02 painted line; sweep follows current locked monster position.
        if not front and t >= launch and t < sustain:
            var reach := clampf(_travel(t,launch,hit_at),0.0,1.0)
            var stop: Vector2 = contact
            var delta := stop - start
            # Native art is 1024x256; local stroke progresses from left to right.
            var turn := delta.angle()
            var width := maxf(delta.length(),140.0)
            layer.draw_set_transform(start, turn, Vector2(width/943.0, .81))
            var idx := clampi(int(reach * 9.99),0,9)
            var tex := _tex(3,0)
            if tex != null:
                var cell := tex.get_size() / Vector2(4,3)
                layer.draw_texture_rect_region(tex,Rect2(0,-108,943,216),Rect2((idx%4)*cell.x,int(idx/4)*cell.y,cell.x,cell.y), Color(1,1,1,.91 * _fade(t,hit_at+.13,sustain)))
            layer.draw_set_transform(Vector2.ZERO)
        if front and t>=hit_at and t<fade_end:
            for id in a["locked"]:
                if _distance_to_cast_line(id,a)<92.0:
                    _show_rect(layer,_tex(3,1),_mob_pos(id)+Vector2(0,-72),Vector2(158,140),impact * .72)
    elif kind == 4:  # TAL03 original gilt mark atlas stays on locked WALK monster for 6s.
        if front and t>=hit_at and t<fade_end:
            var hold := smoothstep(hit_at,hit_at+.15,t) * _fade(t,sustain,fade_end)
            var frame := clampi(int(maxf(t-hit_at,0)*16),0,7) if t<1.36 else 5+int(t*2.5)%3
            var size := Vector2.ONE * lerpf(100.0,80.0,smoothstep(hit_at,1.29,t))
            _show_atlas(layer,_tex(4,0),4,2,frame,contact+Vector2(0,8),size,hold*.88)
    elif kind == 5:  # HF02 R6: approved lotus at fixed preselected AREA, not a homing AOE.
        var zone: Vector2 = a["frozen_aoe"]
        if not front:
            if t < launch + .21:
                _show_atlas(layer,_tex(5,1),4,3,clampi(int(clampf(t/.62,0,1)*11.9),0,11),start,Vector2(148,148),charge)
            if t>=launch and t < hit_at:
                for i in range(4):
                    var phase := clampf((t-launch-float(i)*.042)/maxf(hit_at-launch-.2,0.1),0,1)
                    if phase <= 0 or phase >= 1: continue
                    var p := start.lerp(zone+Vector2((i-2)*37,-45),phase)+Vector2(0,-86*sin(PI*phase))
                    _show_atlas(layer,_tex(5,2),4,3,clampi(int(phase*11.9),0,11),p,Vector2(115,77),.76)
            if t>=.79 and t < fade_end:
                var b := smoothstep(.79,1.09,t) * _fade(t,1.74,fade_end)
                _show_atlas(layer,_tex(5,0),4,3,clampi(int(clampf((t-.79)/1.39,0,1)*11.99),0,11),zone+Vector2(0,-138),Vector2(510,460),b)
                _show_atlas(layer,_tex(5,4),4,2,clampi(int(clampf((t-.64)/1.63,0,1)*7.99),0,7),zone+Vector2(0,-15),Vector2(480,151),b*.42)
        else:
            for id in a["locked"]:
                if _mob_pos(id).distance_to(zone)<=175.0 and t>=hit_at and t<sustain:
                    _show_atlas(layer,_tex(5,3),4,2,clampi(int(clampf((t-hit_at)/.52,0,1)*7.99),0,7),_mob_pos(id)+Vector2(0,-73),Vector2(146,143),impact*.94)
    elif kind == 6:  # HF03 R2: one original projectile sprite, follows same locked moving monster.
        if not front:
            if t < launch+.1:
                _show_atlas(layer,_tex(6,0),4,3,clampi(int(clampf(t/.50,0,1)*11.99),0,11),start,Vector2(220,220),charge)
            if t>=launch and t < hit_at:
                var pos := start.lerp(contact,proj)+Vector2(0,-110*sin(PI*proj))
                var ahead := start.lerp(contact,clampf(proj+.025,0,1))
                var angle := (ahead-pos).angle()
                layer.draw_set_transform(pos,angle,Vector2.ONE)
                _show_atlas(layer,_tex(6,1),4,4,clampi(int(proj*15.99),0,15),Vector2.ZERO,Vector2(188,118),flight)
                layer.draw_set_transform(Vector2.ZERO)
            if t >= hit_at and t < fade_end:
                _show_atlas(layer,_tex(6,2),4,3,clampi(int(clampf((t-hit_at)/.48,0,1)*9.99),0,9),contact,Vector2(228,195),impact)
        elif t>=hit_at and t < sustain:
            layer.draw_circle(contact,10.0,Color("ffec9b",impact*.68))