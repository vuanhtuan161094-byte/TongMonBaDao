#!/usr/bin/env python3
"""First-party RGBA frame source for the Tinh Ban damage-semantic rework.

This preserves the original Formation Batch 1 atlas and emits an isolated R2
candidate: 4 charge, 4 release, 4 contact and 4 fade poses. No game events,
combat logic, actor art, fonts or commercial source pixels are generated here.
"""
from __future__ import annotations

from pathlib import Path
import hashlib
import math
import random

from PIL import Image, ImageChops, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "godot/labs/combat_lab/formation01/factory_batch1_20261125/source/rework_tinh_ban_r2"
SIDE = 256
SCALE = 3
FRAMES_PER_PHASE = 4
PHASES = ("charge", "release", "contact", "fade")
JADE = (72, 226, 187)
PALE = (226, 255, 222)
GOLD = (255, 211, 115)
EMBER = (255, 135, 86)


def p(x: float, y: float) -> tuple[int, int]:
    return round(x * SCALE), round(y * SCALE)


def bezier(a, b, c, d, n: int = 48):
    result = []
    for i in range(n + 1):
        t = i / n
        u = 1.0 - t
        result.append((
            u**3 * a[0] + 3 * u**2 * t * b[0] + 3 * u * t**2 * c[0] + t**3 * d[0],
            u**3 * a[1] + 3 * u**2 * t * b[1] + 3 * u * t**2 * c[1] + t**3 * d[1],
        ))
    return result


def line(draw: ImageDraw.ImageDraw, pts, color, width: float = 1.0):
    if len(pts) > 1:
        draw.line([p(x, y) for x, y in pts], fill=(*color[:3], int(color[3])),
                  width=max(1, round(width * SCALE)), joint="curve")


def glow(dst: Image.Image, src: Image.Image, radius: float, opacity: float):
    haze = src.filter(ImageFilter.GaussianBlur(radius * SCALE))
    haze.putalpha(haze.getchannel("A").point(lambda a: round(a * opacity)))
    dst.alpha_composite(haze)
    dst.alpha_composite(src)


def diamond(cx: float, cy: float, rx: float, ry: float, spin: float = 0.0):
    pts = []
    for i in range(4):
        a = spin + math.pi * 0.5 * i
        pts.append((cx + math.cos(a) * rx, cy + math.sin(a) * ry))
    return pts


def shard(draw: ImageDraw.ImageDraw, cx: float, cy: float, angle: float,
          length: float, width: float, color, opacity: int, q: float):
    tip = (cx + math.cos(angle) * length, cy + math.sin(angle) * length)
    nx, ny = -math.sin(angle), math.cos(angle)
    tail = (cx - math.cos(angle) * length * (0.22 + 0.12 * q),
            cy - math.sin(angle) * length * (0.22 + 0.12 * q))
    poly = [tip, (cx + nx * width, cy + ny * width), tail,
            (cx - nx * width * 0.7, cy - ny * width * 0.7)]
    draw.polygon([p(x, y) for x, y in poly], fill=(*color, opacity))
    line(draw, [tip, (cx + nx * width, cy + ny * width), tail], (*PALE, opacity), 0.8)


def frame(phase: str, index: int) -> Image.Image:
    q = index / (FRAMES_PER_PHASE - 1)
    seed = 9821 + PHASES.index(phase) * 101 + index
    rng = random.Random(seed)
    out = Image.new("RGBA", (SIDE * SCALE, SIDE * SCALE), (0, 0, 0, 0))
    under = Image.new("RGBA", out.size, (0, 0, 0, 0))
    marks = Image.new("RGBA", out.size, (0, 0, 0, 0))
    du = ImageDraw.Draw(under, "RGBA")
    d = ImageDraw.Draw(marks, "RGBA")
    cx = 128.0 + 2.8 * math.sin(index * 1.1 + PHASES.index(phase))
    cy = 131.0 + 2.1 * math.cos(index * 0.9)

    if phase == "charge":
        # Seven separate star-nodes and interrupted meridian strokes gather
        # toward a small central seal; no circular shield silhouette.
        shrink = 1.0 - 0.37 * q
        nodes = []
        for k in range(7):
            a = -math.pi / 2 + k * math.tau / 7
            radius = (47 + 4 * math.sin(k * 2.2)) * shrink
            nodes.append((cx + math.cos(a) * radius, cy + math.sin(a) * radius * .78))
        for k, node in enumerate(nodes):
            prev = nodes[(k - 1) % len(nodes)]
            nxt = nodes[(k + 1) % len(nodes)]
            reach = 0.22 + 0.20 * q
            a = (node[0] + (cx - node[0]) * reach, node[1] + (cy - node[1]) * reach)
            b = (nxt[0] + (cx - nxt[0]) * reach, nxt[1] + (cy - nxt[1]) * reach)
            line(du, bezier(a, (a[0] + 12, a[1] - 13), (b[0] - 10, b[1] + 9), b), (*JADE, 92), 4.3)
            line(d, [a, b], (*GOLD, 116), 0.85)
            r = 3.2 + 1.8 * q + 0.9 * math.sin(k + index)
            x, y = node
            d.polygon([p(*v) for v in diamond(x, y, r * .8, r * 1.5, k * .21)],
                      fill=(*GOLD, 180))
            line(d, bezier((x - 5, y + 1), (x - 2, y - 5), (x + 3, y + 4), (x + 6, y - 2), 18),
                 (*PALE, 170), 0.75)
        if q > .25:
            rr = 4.0 + 6.0 * q
            core = diamond(cx, cy, rr, rr * .60, .15 + q * .5)
            d.polygon([p(*v) for v in core], fill=(*GOLD, round(105 + 90 * q)))
            line(d, core + [core[0]], (*PALE, 224), 1.05)
        for k in range(4):
            a = -2.5 + k * 1.61 + .14 * math.sin(index + k)
            end = (cx + math.cos(a) * (59 - q * 9), cy + math.sin(a) * (49 - q * 7))
            start = (cx + math.cos(a + 1.1) * 74, cy + math.sin(a + 1.1) * 61)
            line(du, bezier(start, (start[0] - 18, start[1] - 20),
                            (end[0] + 17, end[1] + 9), end), (*JADE, 78), 3.2)
            line(d, bezier(start, (start[0] - 10, start[1] - 13),
                           (end[0] + 8, end[1] + 5), end), (*PALE, 139), .78)

    elif phase == "release":
        # An asymmetric seven-point constellation opens into a crossed blade
        # lattice. The incomplete side braces keep it reading as an attack.
        spread = .70 + .32 * q
        nodes = []
        for k in range(7):
            a = -math.pi / 2 + k * math.tau / 7
            radius = (51 + 5 * math.sin(k * 1.9)) * spread
            nodes.append((cx + math.cos(a) * radius, cy + math.sin(a) * radius * .75))
        for k in range(7):
            a = nodes[k]
            b = nodes[(k + 2) % 7]
            bend = 18 * math.sin(k * 2.1 + q * 2.5)
            curve = bezier(a, (a[0] + bend, a[1] - 24),
                           (b[0] - bend * .55, b[1] + 19), b, 56)
            line(du, curve, (*JADE, 115), 7.0 if k % 3 == 0 else 4.0)
            line(d, curve, (*PALE, 168 if k % 2 == 0 else 112), 1.1)
        for k, node in enumerate(nodes):
            a = -math.pi / 2 + k * math.tau / 7 + .12 * math.sin(q * 4 + k)
            shard(d, node[0], node[1], a, 8 + 6 * q, 2.1, GOLD, 188, q)
        for k in range(3):
            a = -1.9 + k * 2.1 + .12 * math.sin(q * 3 + k)
            start = (cx + math.cos(a) * 9, cy + math.sin(a) * 7)
            end = (cx + math.cos(a + .8) * 88, cy + math.sin(a + .8) * 58)
            trail = bezier(start, (cx + math.cos(a - .45) * 45, cy + math.sin(a - .45) * 34),
                           (end[0] - 16, end[1] + 19), end)
            line(du, trail, (*GOLD, 87), 6.2)
            line(d, trail, (*PALE, 184), 1.0)
        knot = diamond(cx, cy, 10 + q * 7, 15 + q * 4, q * .68)
        d.polygon([p(*v) for v in knot], fill=(*JADE, 198))
        line(d, knot + [knot[0]], (*PALE, 240), 1.4)

    elif phase == "contact":
        # A compact, sharp impact: three unequal converging cuts split the
        # lattice, with outward shards and short cracks instead of a bubble.
        burst = .72 + .32 * q
        for k in range(9):
            a = -math.pi / 2 + k * math.tau / 9 + .11 * math.sin(k * 2.3)
            length = (28 + 24 * ((k * 5) % 9) / 8) * burst
            width = (2.8 + 1.4 * (k % 3)) * (1.0 - .10 * q)
            shard(d, cx + math.cos(a) * 4, cy + math.sin(a) * 3,
                  a + .14 * math.sin(k), length, width, GOLD if k % 3 else EMBER,
                  round((218 - 63 * q) * (1.0 if k % 2 else .80)), q)
        for k in range(5):
            a = -2.1 + k * .91 + .09 * math.sin(index + k)
            inner = (cx + math.cos(a) * 11, cy + math.sin(a) * 9)
            mid = (cx + math.cos(a + .25) * 34, cy + math.sin(a + .25) * 28)
            tip = (cx + math.cos(a + .15) * (51 + 8 * q), cy + math.sin(a + .15) * (43 + 8 * q))
            crack = bezier(inner, (mid[0] - 7, mid[1] + 4),
                           (tip[0] - 7, tip[1] - 3), tip)
            line(du, crack, (*EMBER, 100), 7.5)
            line(d, crack, (*PALE, 220), 1.35)
            branch = (tip[0] - 11 * math.sin(a), tip[1] + 10 * math.cos(a))
            line(d, [mid, branch, tip], (*GOLD, 205), 1.1)
        # Broken perspective marks describe the hit footprint without enclosing it.
        for k in range(4):
            a = -2.7 + k * 1.59 + q * .16
            r0, r1 = 62 + 4 * (k % 2), 78 + 5 * (k % 3)
            start = (cx + math.cos(a) * r0, cy + math.sin(a) * r0 * .68)
            end = (cx + math.cos(a + .32) * r1, cy + math.sin(a + .32) * r1 * .68)
            line(d, bezier(start, (start[0] + 3, start[1] - 7),
                           (end[0] - 5, end[1] + 6), end, 22), (*JADE, 128), 1.0)
        for k in range(11):
            a = k * math.tau / 11 + q * .4
            r = 26 + 12 * ((k * 7) % 11) / 10
            x, y = cx + math.cos(a) * r, cy + math.sin(a) * r * .72
            rr = 1.1 + (k % 3) * .35
            d.polygon([p(*v) for v in diamond(x, y, rr, rr * 1.8, a)],
                      fill=(*GOLD, round(145 * (1 - .24 * q))))

    else:  # fade
        # Each flare tears into independent paper-light fragments; no persistent seal.
        fade = 1.0 - .75 * q
        for k in range(13):
            a = -2.8 + k * .49 + .13 * math.sin(k * 1.7)
            drift = 9 + 25 * q + (k % 4) * 3
            x = cx + math.cos(a) * drift
            y = cy + math.sin(a) * drift * .72 - 5 * q
            length = 7 + 8 * (1 - q) + (k % 3) * 2
            shard(d, x, y, a + .30 * math.sin(k + q), length, 1.3 + (k % 2) * .6,
                  JADE if k % 3 else GOLD, round((175 - 60 * q) * fade), q)
        for k in range(7):
            a = -2.9 + k * .88 + q * .18
            r0, r1 = 15 + 12 * q, 37 + 29 * q
            start = (cx + math.cos(a) * r0, cy + math.sin(a) * r0)
            end = (cx + math.cos(a + .28) * r1, cy + math.sin(a + .28) * r1)
            trail = bezier(start, (start[0] + 12, start[1] - 9),
                           (end[0] - 11, end[1] + 9), end, 24)
            line(du, trail, (*JADE, round(58 * fade)), 4.0)
            line(d, trail, (*PALE, round(170 * fade)), .8)
        for _ in range(15):
            a = rng.random() * math.tau
            r = rng.uniform(22, 83) * (.56 + .44 * q)
            x, y = cx + math.cos(a) * r, cy + math.sin(a) * r * .76
            rr = rng.uniform(.55, 1.35)
            d.ellipse((p(x - rr, y - rr)[0], p(x - rr, y - rr)[1],
                       p(x + rr, y + rr)[0], p(x + rr, y + rr)[1]),
                      fill=(*PALE, round(rng.uniform(48, 153) * fade)))

    glow(out, under, 9.0 if phase != "contact" else 12.0, .25 if phase != "contact" else .28)
    glow(out, marks, 3.0, .18)
    # A restrained jade-black pigment edge survives pale terrain at 1x.
    alpha = out.getchannel("A")
    rim = ImageChops.subtract(alpha.filter(ImageFilter.MaxFilter(5)), alpha)
    rim = rim.point(lambda a: round(a * .52))
    edge = Image.new("RGBA", out.size, (20, 88, 73, 0))
    edge.putalpha(rim)
    out.alpha_composite(edge)
    return out.resize((SIDE, SIDE), Image.Resampling.LANCZOS)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    frames = [frame(phase, i) for phase in PHASES for i in range(FRAMES_PER_PHASE)]
    atlas = Image.new("RGBA", (SIDE * 4, SIDE * 4), (0, 0, 0, 0))
    for i, image in enumerate(frames):
        atlas.alpha_composite(image, ((i % 4) * SIDE, (i // 4) * SIDE))
    atlas_path = OUT / "tinh_ban_ho_tam_r2_16pose_rgba.png"
    atlas.save(atlas_path, optimize=True)

    sheets = []
    for theme, color in (("dark", (34, 42, 43)), ("light", (237, 232, 218))):
        sheet = Image.new("RGB", (SIDE * 4, (SIDE + 30) * 4), color)
        draw = ImageDraw.Draw(sheet)
        for row, phase_name in enumerate(PHASES):
            draw.text((8, row * (SIDE + 30) + 8), phase_name.upper() + " / 4 SOURCE POSES / 1X",
                      fill=(240, 235, 220) if theme == "dark" else (42, 47, 43))
            for col in range(FRAMES_PER_PHASE):
                i = row * FRAMES_PER_PHASE + col
                image = frames[i]
                background = Image.new("RGBA", image.size, (*color, 255))
                background.alpha_composite(image)
                sheet.paste(background.convert("RGB"), (col * SIDE, row * (SIDE + 30) + 30))
        sheet_path = OUT / f"tinh_ban_ho_tam_r2_contact_sheet_1x_{theme}.png"
        sheet.save(sheet_path, optimize=True)
        sheets.append(sheet_path)

    digest = hashlib.sha256(atlas_path.read_bytes()).hexdigest()
    alpha = atlas.getchannel("A")
    assert alpha.getextrema()[0] == 0 and alpha.getextrema()[1] == 255
    assert all(image.getchannel("A").getbbox() for image in frames)
    print("FORMATION_TINH_BAN_R2_SOURCE_PASS")
    print(f"ATLAS={atlas_path.relative_to(ROOT)} size={atlas.size} mode={atlas.mode} poses={len(frames)} sha256={digest}")
    print("CONTACT_SHEETS=" + ",".join(str(path.relative_to(ROOT)) for path in sheets))
    print(f"alpha_extrema={alpha.getextrema()}")
    print("PROVENANCE=FIRST_PARTY_PIL_CODE_PAINTED_NO_EXTERNAL_PIXELS owner=OWNER_PENDING tech=NATIVE_PENDING pve=HOLD")


if __name__ == "__main__":
    main()
