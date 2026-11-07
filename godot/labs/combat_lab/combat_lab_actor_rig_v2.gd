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
        pose: String, seconds: float, scale: float, facing: float = 1.0,
        pose_elapsed: float = 0.0) -> void:
    var monster := str(actor.get("side", "")) == "monster"
    var boss := str(actor.get("tier", "")) == "boss"
    var colors := _palette(school, monster, boss)
    var state := pose if valid_pose(pose) else "idle"
    if float(actor.get("hp", 0.0)) <= 0.0:
        state = "death"
    var actor_seed := absi(hash(str(actor.get("id", "")))) % 11
    var walk := sin(seconds * 13.0 + float(actor_seed % 7)) if state == "walk" else 0.0
    var breathing := sin(seconds * 2.8 + float(actor_seed)) * 0.85
    # Attack is a single authored anticipation -> strike -> recovery motion,
    # never a free-running sine wave that randomly resets on each event.
    var attack_phase := clampf(pose_elapsed / 0.42, 0.0, 1.0)
    var attack := smoothstep(0.12, 0.43, attack_phase) * (1.0 - smoothstep(0.72, 1.0, attack_phase))
    var cast := sin(seconds * 6.5) if state == "cast" else 0.0
    var lean := 0.0
    if state == "walk":
        lean = 0.06 * walk
    elif state == "attack":
        match school:
            "bow": lean = -0.04 + 0.10 * attack
            "fist": lean = -0.17 + 0.37 * attack
            "poison": lean = -0.14 + 0.24 * attack
    elif state == "cast":
        lean = -0.10 + cast * 0.025
    elif state == "hit":
        lean = -0.25
    elif state == "death":
        lean = -1.08
    var body_origin := root + Vector2(0, breathing * scale)
    if state == "death": body_origin += Vector2(0, 5 * scale)

    # Stable ground contact; the actor's world position is always at the feet.
    canvas.draw_circle(root + Vector2(0, -1), 12.0 * scale, Color(0.015, 0.012, 0.03, 0.26))
    if state != "death":
        var boots: Color = colors.shadow
        # Split legs rotate out of phase in Walk rather than a single bob.
        var stance := attack * 6.0 if state == "attack" and school == "fist" else 0.0
        _bone(canvas, body_origin, Vector2(-4, -15), Vector2(-6 - walk * 4.0 - stance * 0.3, -1),
            scale, facing, lean, 4.6, boots)
        _bone(canvas, body_origin, Vector2(4, -15), Vector2(6 + walk * 4.0 + stance, -1),
            scale, facing, lean, 4.6, boots)
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
    # Distinct ornamental lapels, waist cord and fluttering coat panels.
    var hem_sway := sin(seconds * 6.0) * 2.0 + attack * 4.0
    _poly(canvas, body_origin, [
        Vector2(-8, -20), Vector2(-2, -15), Vector2(-6, -4),
        Vector2(-13 - hem_sway, -3)
    ], colors.light.darkened(0.12), scale, facing, lean)
    _poly(canvas, body_origin, [
        Vector2(5, -19), Vector2(9, -16), Vector2(14 + hem_sway, -3),
        Vector2(5, -6)
    ], colors.coat.lightened(0.16), scale, facing, lean)
    canvas.draw_line(_p(body_origin, -8, -19, scale, facing, lean),
        _p(body_origin, 7, -19, scale, facing, lean), colors.metal, 1.3 * scale, true)
    canvas.draw_circle(_p(body_origin, 0, -19, scale, facing, lean),
        2.2 * scale, colors.glow)
    if school == "poison" and not monster:
        # Laboratory-only poison master silhouette: ceremonial scarf, paired
        # medicine vials and a nether talisman; not baked to the weapon.
        _poly(canvas, body_origin, [
            Vector2(-7, -29), Vector2(8, -29), Vector2(11, -24),
            Vector2(2, -22), Vector2(-10, -24)
        ], Color("72518b"), scale, facing, lean)
        _poly(canvas, body_origin, [
            Vector2(-8, -23), Vector2(-13, -18),
            Vector2(-13 - sin(seconds * 4.0) * 2.0, -3),
            Vector2(-7, -10)
        ], Color("9c72b5"), scale, facing, lean)
        for vial in range(3):
            var vial_x := -7.0 + float(vial) * 7.0
            var vial_center := _p(body_origin, vial_x, -15.0, scale, facing, lean)
            canvas.draw_rect(Rect2(vial_center + Vector2(-1.6, -2.2) * scale,
                Vector2(3.2, 5.0) * scale), Color("73dec0"), true)
            canvas.draw_circle(vial_center + Vector2(0, 1.1 * scale),
                1.1 * scale, Color("d4fbbd"))
        var talisman := _p(body_origin, 0, -25, scale, facing, lean)
        _diamond_talisman(canvas, talisman, 4.2 * scale,
            Color("c4b0e5"), Color("8ef4bb"))

    var back_hand := Vector2(-17, -17)
    var front_hand := Vector2(17, -17)
    if state == "walk":
        back_hand += Vector2(-walk * 4.5, walk * 2.0)
        front_hand += Vector2(walk * 4.5, -walk * 2.0)
    elif state == "attack":
        # The three schools have visibly different combat silhouettes.
        # Bow holds the bow arm while the string hand moves forward on release.
        # Fist plants a foot and extends a heavy straight punch.
        # Poison whips a needle from behind the shoulder.
        match school:
            "bow":
                back_hand = Vector2(-2.0 + attack * 13.0, -30.0 + attack * 1.5)
                front_hand = Vector2(23.0, -31.0)
            "fist":
                back_hand = Vector2(-21.0 + attack * 3.0, -23.0)
                front_hand = Vector2(8.0 + attack * 31.0, -21.0 - attack * 6.0)
            "poison":
                back_hand = Vector2(-18.0, -31.0)
                front_hand = Vector2(8.0 + attack * 27.0, -36.0 + attack * 9.0)
    elif state == "cast":
        match school:
            "bow":
                back_hand = Vector2(-1.0 + cast * 0.8, -29.0)
                front_hand = Vector2(24.0, -31.0 + cast * 0.8)
            "fist":
                back_hand = Vector2(-18.0, -24.0 + cast)
                front_hand = Vector2(9.0 + cast * 1.0, -34.0)
            "poison":
                back_hand = Vector2(-11.0 + cast, -30.0)
                front_hand = Vector2(13.0, -40.0 + cast * 1.5)
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
    # Eyelids, eyebrow angle and cheek sheen change with impact/effort.
    var eye_narrow := 1.5 if state in ["attack", "hit"] else 0.0
    canvas.draw_line(left_eye + Vector2(-2 * scale, (-2 + eye_narrow) * scale),
        left_eye + Vector2(2 * scale, (-2 - eye_narrow) * scale), colors.hair, 1.1 * scale, true)
    canvas.draw_line(right_eye + Vector2(-2 * scale, (-2 - eye_narrow) * scale),
        right_eye + Vector2(2 * scale, (-2 + eye_narrow) * scale), colors.hair, 1.1 * scale, true)
    canvas.draw_circle(_p(body_origin, 7.0, -35.0, scale, facing, lean),
        1.1 * scale, colors.skin.lightened(0.28))
    var jewel := _p(body_origin, 0, -51, scale, facing, lean)
    canvas.draw_circle(jewel, 2.5 * scale, colors.metal)
    canvas.draw_circle(jewel, 1.35 * scale, colors.glow)

    if school == "bow" and not monster:
        # A trailing ponytail makes Walk/Attack motion recognizable.
        var tail := _p(body_origin, -12 - walk * 3.5, -45 + walk * 3.0, scale, facing, lean)
        canvas.draw_line(_p(body_origin, -9, -47, scale, facing, lean), tail, colors.hair, 5.0 * scale, true)
        canvas.draw_circle(tail, 4.0 * scale, colors.hair)
    if school == "poison" and not monster:
        # Twin locks sway differently during casting and a needle release.
        var poison_sway := sin(seconds * 4.2) * 1.8 + (attack * 5.0 if state == "attack" else 0.0)
        canvas.draw_circle(_p(body_origin, -11, -49, scale, facing, lean), 3.3 * scale, colors.light)
        canvas.draw_circle(_p(body_origin, 11, -49, scale, facing, lean), 3.3 * scale, colors.light)
        _bone(canvas, body_origin, Vector2(-11, -43), Vector2(-14 - poison_sway, -18),
            scale, facing, lean, 3.1, colors.hair)
        _bone(canvas, body_origin, Vector2(11, -43), Vector2(13 - poison_sway * 0.5, -17),
            scale, facing, lean, 3.1, colors.hair)
        if state == "cast":
            # Three orbiting poison beads are bound to the casting hand.
            var casting_hand := _p(body_origin, front_hand.x, front_hand.y, scale, facing, lean)
            for i in range(3):
                var ang := TAU * float(i) / 3.0 + seconds * 3.5
                var orb := casting_hand + Vector2.from_angle(ang) * 8.0 * scale
                canvas.draw_circle(orb, 2.2 * scale, colors.glow)
                canvas.draw_circle(orb, 0.9 * scale, Color("dcffca"))
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
            state, seconds, scale, facing, colors,
            _p(body_origin, back_hand.x, back_hand.y, scale, facing, lean), attack)
    if state == "cast":
        var focus := _p(body_origin, front_hand.x + 4, front_hand.y - 2, scale, facing, lean)
        canvas.draw_arc(focus, (6 + sin(seconds * 12.0) * 1.0) * scale,
            0, TAU, 24, colors.glow, 2.0 * scale, true)

static func _diamond_talisman(canvas: CanvasItem, center: Vector2, size_px: float,
        outline: Color, core: Color) -> void:
    canvas.draw_colored_polygon(PackedVector2Array([
        center + Vector2(0, -size_px),
        center + Vector2(size_px * 0.62, 0),
        center + Vector2(0, size_px),
        center + Vector2(-size_px * 0.62, 0)
    ]), outline)
    canvas.draw_circle(center, size_px * 0.34, core)

static func draw_weapon(canvas: CanvasItem, hand: Vector2, school: String, pose: String,
        seconds: float, scale: float, facing: float, colors: Dictionary,
        other_hand: Vector2, attack_amount: float) -> void:
    # This function is intentionally separate from the paper-doll renderer.
    var tip := hand + Vector2(14 * facing, -11) * scale
    var metal: Color = colors.metal
    match school:
        "bow":
            # Bow limbs, curved grip and two moving string halves. During Cast
            # the draw hand visibly pulls back; Attack releases it forward.
            var bow_center := hand + Vector2(7.0 * facing, -2.0) * scale
            var upper := bow_center + Vector2(3.0 * facing, -17.0) * scale
            var lower := bow_center + Vector2(3.0 * facing, 17.0) * scale
            var string_hand := other_hand if pose == "cast" else other_hand.lerp(bow_center, attack_amount)
            canvas.draw_arc(bow_center, 17.0 * scale, -1.05, 1.05, 28, metal, 3.0 * scale, true)
            canvas.draw_line(upper, string_hand, Color("ded4df"), 1.5 * scale, true)
            canvas.draw_line(string_hand, lower, Color("ded4df"), 1.5 * scale, true)
            canvas.draw_circle(bow_center, 3.0 * scale, colors.glow)
            if pose == "cast" or attack_amount < 0.75:
                var arrow_tip := bow_center + Vector2(18.0 * facing, -1.0) * scale
                canvas.draw_line(string_hand, arrow_tip, Color("f4dda0"), 2.1 * scale, true)
                canvas.draw_colored_polygon(PackedVector2Array([
                    arrow_tip + Vector2(5.0 * facing, 0.0) * scale,
                    arrow_tip + Vector2(-2.0 * facing, -2.4) * scale,
                    arrow_tip + Vector2(-2.0 * facing, 2.4) * scale
                ]), colors.glow)
        "poison":
            # Thin detachable needle plus a small sigil with three orbiting
            # droplets; no poison damage is generated by presentation.
            canvas.draw_line(hand, tip, metal, 2.4 * scale, true)
            canvas.draw_circle(tip, 4.2 * scale, colors.glow)
            for i in range(3):
                var p := tip + Vector2(sin(seconds * 9.0 + i * 2.0) * 6.0,
                    -5.0 - float(i) * 4.5) * scale
                canvas.draw_circle(p, maxf(1.0, 2.2 - float(i) * 0.4) * scale, colors.glow)
            if pose == "attack":
                canvas.draw_line(hand, hand + Vector2(-13.0 * facing, 3.0) * scale,
                    Color("8ce9b7", 0.65), maxf(1.0, attack_amount * 3.0) * scale, true)
        "fist":
            # Wrist/knuckle highlight follows the striking hand, while the
            # other hand remains tucked in a defensive guard.
            canvas.draw_circle(hand, 7.5 * scale, colors.glow)
            canvas.draw_arc(hand, 9.0 * scale, 0, TAU, 18, metal, 2.0 * scale, true)
            canvas.draw_circle(other_hand, 5.0 * scale, metal.darkened(0.15))
            if pose == "attack":
                for i in range(3):
                    var trail_y := (float(i) - 1.0) * 4.0
                    canvas.draw_line(hand + Vector2(-15.0 * facing, trail_y) * scale,
                        hand + Vector2(-4.0 * facing, trail_y) * scale,
                        colors.glow, maxf(0.8, attack_amount * 2.0) * scale, true)
