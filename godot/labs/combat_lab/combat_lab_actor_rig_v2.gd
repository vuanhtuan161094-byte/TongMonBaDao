class_name CombatLabActorRigV2
extends RefCounted

# LAB_ONLY original procedural paper-doll. No third-party/copyrighted sprites.
# Coordinates are local to the FEET (0,0); no animation frame is faked by
# replaying a static picture. Every joint/weapon is transformed each frame.
# This is a functional animation rig, NOT an accepted production master sprite.
const SCHOOLS := ["bow", "fist", "poison"]

static func valid_pose(pose: String) -> bool:
    return pose in ["idle", "walk", "attack", "cast", "hit", "death"]

static func _palette(school: String, monster: bool, boss: bool) -> Dictionary:
    if boss:
        return {"coat": Color("5d223b"), "light": Color("df6d74"), "shadow": Color("2d152b"),
            "hair": Color("e5dbe4"), "skin": Color("ba91a1"), "metal": Color("f2c16e"),
            "glow": Color("ff4668")}
    if monster:
        return {"coat": Color("485a48"), "light": Color("9bc18f"), "shadow": Color("253c39"),
            "hair": Color("293832"), "skin": Color("aab99a"), "metal": Color("d9a86e"),
            "glow": Color("d0eaa1")}
    match school:
        "bow":
            return {"coat": Color("343955"), "light": Color("d8b16f"), "shadow": Color("22243d"),
                "hair": Color("2d253d"), "skin": Color("f3c9b6"), "metal": Color("e8cc83"),
                "glow": Color("e7bb62")}
        "fist":
            return {"coat": Color("59403d"), "light": Color("dc9672"), "shadow": Color("2f2d38"),
                "hair": Color("3a2925"), "skin": Color("eeb79a"), "metal": Color("dbb56d"),
                "glow": Color("ffc366")}
        "poison":
            return {"coat": Color("463356"), "light": Color("b56cc6"), "shadow": Color("241c35"),
                "hair": Color("251b3b"), "skin": Color("edc0cb"), "metal": Color("d0abde"),
                "glow": Color("80e4bc")}
    return _palette("bow", false, false)

static func _p(root: Vector2, x: float, y: float, scale: float, facing: float, lean: float) -> Vector2:
    return root + Vector2(x * facing, y).rotated(lean) * scale

static func _poly(canvas: CanvasItem, root: Vector2, points: Array, color: Color,
        scale: float, facing: float, lean: float) -> void:
    var shape := PackedVector2Array()
    for raw in points:
        var pos: Vector2 = raw
        shape.append(_p(root, pos.x, pos.y, scale, facing, lean))
    canvas.draw_colored_polygon(shape, color)

static func _bone(canvas: CanvasItem, root: Vector2, a: Vector2, b: Vector2,
        scale: float, facing: float, lean: float, width: float, color: Color) -> void:
    var pa := _p(root, a.x, a.y, scale, facing, lean)
    var pb := _p(root, b.x, b.y, scale, facing, lean)
    canvas.draw_line(pa, pb, color.darkened(0.45), (width + 1.5) * scale, true)
    canvas.draw_line(pa, pb, color, width * scale, true)
    canvas.draw_circle(pb, width * scale * 0.42, color)

static func render(canvas: CanvasItem, actor: Dictionary, root: Vector2, school: String,
        pose: String, seconds: float, scale: float, facing: float = 1.0) -> void:
    var monster := str(actor.get("side", "")) == "monster"
    var boss := str(actor.get("tier", "")) == "boss"
    var colors := _palette(school, monster, boss)
    var state := pose if valid_pose(pose) else "idle"
    if float(actor.get("hp", 0.0)) <= 0.0:
        state = "death"
    var walk := sin(seconds * 13.0 + float(abs(hash(str(actor.get("id", "")))) % 7)) if state == "walk" else 0.0
    var breathing := sin(seconds * 2.8 + float(abs(hash(str(actor.get("id", "")))) % 11)) * 0.85
    var attack := sin(seconds * 19.0) if state == "attack" else 0.0
    var cast := sin(seconds * 9.0) if state == "cast" else 0.0
    var lean := 0.0
    if state == "walk": lean = 0.055 * walk
    if state == "attack": lean = 0.19 + 0.13 * attack
    if state == "cast": lean = -0.11 + cast * 0.035
    if state == "hit": lean = -0.25
    if state == "death": lean = -1.08
    var body_origin := root + Vector2(0, breathing * scale)
    if state == "death": body_origin += Vector2(0, 5 * scale)

    # Stable ground contact; the actor's world position is always at the feet.
    canvas.draw_circle(root + Vector2(0, -1), 12.0 * scale, Color(0.015, 0.012, 0.03, 0.26))
    if state != "death":
        var boots := colors.shadow
        # Split legs rotate out of phase in Walk rather than a single bob.
        _bone(canvas, body_origin, Vector2(-4, -15), Vector2(-6 - walk * 4.0, -1), scale, facing, lean, 4.6, boots)
        _bone(canvas, body_origin, Vector2(4, -15), Vector2(6 + walk * 4.0, -1), scale, facing, lean, 4.6, boots)
    else:
        _bone(canvas, body_origin, Vector2(-4, -15), Vector2(-8, -3), scale, facing, lean, 4.5, colors.shadow)
        _bone(canvas, body_origin, Vector2(4, -15), Vector2(9, -3), scale, facing, lean, 4.5, colors.shadow)

    # Dark cape, asymmetric armored robe and hem are independent draw shapes.
    _poly(canvas, body_origin, [
        Vector2(-10, -29), Vector2(9, -29), Vector2(16, -13),
        Vector2(12 + walk * 2.5, -3), Vector2(-15 - walk * 2.5, -3)
    ], colors.shadow, scale, facing, lean)
    _poly(canvas, body_origin, [
        Vector2(-7, -29), Vector2(8, -29), Vector2(9, -17),
        Vector2(13, -10), Vector2(-12, -10), Vector2(-9, -18)
    ], colors.coat, scale, facing, lean)
    _poly(canvas, body_origin, [
        Vector2(-4, -24), Vector2(5, -24), Vector2(8, -12), Vector2(-7, -12)
    ], colors.light.darkened(0.25), scale, facing, lean)

    var back_hand := Vector2(-17, -17)
    var front_hand := Vector2(17, -17)
    if state == "walk":
        back_hand += Vector2(-walk * 4.5, walk * 2.0)
        front_hand += Vector2(walk * 4.5, -walk * 2.0)
    elif state == "attack":
        back_hand = Vector2(-17, -21)
        front_hand = Vector2(22 + attack * 3.0, -23 - attack * 5.0)
    elif state == "cast":
        back_hand = Vector2(-18, -28 + cast * 2.0)
        front_hand = Vector2(21, -29 - cast * 2.0)
    elif state == "hit":
        back_hand = Vector2(-17, -13)
        front_hand = Vector2(22, -11)
    elif state == "death":
        back_hand = Vector2(-17, -11)
        front_hand = Vector2(18, -10)

    _bone(canvas, body_origin, Vector2(-7, -27), back_hand, scale, facing, lean, 4.8, colors.coat)
    _bone(canvas, body_origin, Vector2(8, -27), front_hand, scale, facing, lean, 5.0, colors.light)
    var shoulder := _p(body_origin, 8, -27, scale, facing, lean)
    canvas.draw_circle(shoulder, 4.1 * scale, colors.metal)
    var far_shoulder := _p(body_origin, -7, -27, scale, facing, lean)
    canvas.draw_circle(far_shoulder, 3.3 * scale, colors.metal.darkened(0.22))

    # Oversized expressive chibi head with separate back hair, face, crest and eyes.
    var face := _p(body_origin, 0, -42, scale, facing, lean)
    canvas.draw_circle(face + Vector2(-2 * facing * scale, 1.5 * scale), 13.0 * scale, colors.hair)
    canvas.draw_circle(face, 11.8 * scale, colors.skin)
    canvas.draw_circle(face + Vector2(2.2 * facing * scale, -5.0 * scale), 11.4 * scale, colors.hair)
    _poly(canvas, body_origin, [
        Vector2(-12, -46), Vector2(-7, -56), Vector2(-2, -54),
        Vector2(2, -58), Vector2(10, -48), Vector2(8, -43),
        Vector2(-3, -47), Vector2(-11, -40)
    ], colors.hair, scale, facing, lean)
    var left_eye := _p(body_origin, -4.4, -40, scale, facing, lean)
    var right_eye := _p(body_origin, 4.0, -40, scale, facing, lean)
    canvas.draw_circle(left_eye, 1.1 * scale, colors.glow)
    canvas.draw_circle(right_eye, 1.1 * scale, colors.glow)
    var jewel := _p(body_origin, 0, -51, scale, facing, lean)
    canvas.draw_circle(jewel, 2.5 * scale, colors.metal)
    canvas.draw_circle(jewel, 1.35 * scale, colors.glow)

    if school == "bow" and not monster:
        # A trailing ponytail makes Walk/Attack motion recognizable.
        var tail := _p(body_origin, -12 - walk * 3.5, -45 + walk * 3.0, scale, facing, lean)
        canvas.draw_line(_p(body_origin, -9, -47, scale, facing, lean), tail, colors.hair, 5.0 * scale, true)
        canvas.draw_circle(tail, 4.0 * scale, colors.hair)
    if school == "poison" and not monster:
        # Raised side ornaments and twin trailing hair locks.
        canvas.draw_circle(_p(body_origin, -11, -49, scale, facing, lean), 3.3 * scale, colors.light)
        canvas.draw_circle(_p(body_origin, 11, -49, scale, facing, lean), 3.3 * scale, colors.light)
        _bone(canvas, body_origin, Vector2(-11, -43), Vector2(-14 + walk, -18), scale, facing, lean, 3.1, colors.hair)
        _bone(canvas, body_origin, Vector2(11, -43), Vector2(13 - walk, -17), scale, facing, lean, 3.1, colors.hair)
    if school == "fist" and not monster:
        # Large wrist guards distinguish gauntlet attacks.
        canvas.draw_circle(_p(body_origin, back_hand.x, back_hand.y, scale, facing, lean), 5.0 * scale, colors.metal.darkened(0.15))
        canvas.draw_circle(_p(body_origin, front_hand.x, front_hand.y, scale, facing, lean), 5.7 * scale, colors.glow.darkened(0.22))

    if boss:
        # Horns/crown preserve boss silhouette from a distance.
        _poly(canvas, body_origin, [
            Vector2(-12, -50), Vector2(-15, -68), Vector2(-4, -56)
        ], colors.metal, scale, facing, lean)
        _poly(canvas, body_origin, [
            Vector2(5, -56), Vector2(15, -70), Vector2(13, -49)
        ], colors.metal, scale, facing, lean)

    # Equipable weapon attachment: no baked weapon in the character body.
    if not monster and state in ["attack", "cast"]:
        draw_weapon(canvas, _p(body_origin, front_hand.x, front_hand.y, scale, facing, lean), school,
            state, seconds, scale, facing, colors)
    if state == "cast":
        var focus := _p(body_origin, front_hand.x + 4, front_hand.y - 2, scale, facing, lean)
        canvas.draw_arc(focus, (6 + sin(seconds * 12.0) * 1.0) * scale,
            0, TAU, 24, colors.glow, 2.0 * scale, true)

static func draw_weapon(canvas: CanvasItem, hand: Vector2, school: String, pose: String,
        seconds: float, scale: float, facing: float, colors: Dictionary) -> void:
    # This function is intentionally separate from the paper-doll renderer.
    var tip := hand + Vector2(14 * facing, -11) * scale
    var metal: Color = colors.metal
    match school:
        "bow":
            var bow_center := hand + Vector2(8 * facing, -2) * scale
            canvas.draw_arc(bow_center, 13.0 * scale, -1.1, 1.1, 28, metal, 2.8 * scale, true)
            canvas.draw_line(bow_center + Vector2(5 * facing, -12) * scale,
                bow_center + Vector2(5 * facing, 12) * scale, Color("ddd7e8"), 1.2 * scale, true)
            if pose == "attack":
                canvas.draw_line(hand, tip + Vector2(9 * facing, 0), colors.glow, 2.0 * scale, true)
        "poison":
            canvas.draw_line(hand, tip, metal, 2.4 * scale, true)
            canvas.draw_circle(tip, 4.2 * scale, colors.glow)
            for i in range(3):
                var p := tip + Vector2(sin(seconds * 9.0 + i * 2.0) * 6.0,
                    -5.0 - float(i) * 4.5) * scale
                canvas.draw_circle(p, maxf(1.0, 2.2 - float(i) * 0.4) * scale, colors.glow)
        "fist":
            canvas.draw_circle(hand, 7.5 * scale, colors.glow)
            canvas.draw_arc(hand, 9.0 * scale, 0, TAU, 18, metal, 2.0 * scale, true)
