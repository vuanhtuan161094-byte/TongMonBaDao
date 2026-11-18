#!/usr/bin/env python3
"""Cheap Art-First V4 G3 review of REAL sprite sources, never a Godot proof.

No new artwork is synthesized. This contact sheet shows each supplied alpha
master at an explicit on-screen silhouette width against light/dark backgrounds.
It neither scores art nor authorizes G3/G3.5; a human decides source quality.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

DARK = (25, 32, 44, 255)
LIGHT = (214, 203, 185, 255)


def inspect(path: Path) -> tuple[Image.Image, dict]:
    if not path.is_file():
        raise ValueError(f"missing original source: {path}")
    raw = path.read_bytes()
    with Image.open(path) as f:
        if f.format not in ("PNG", "WEBP"):
            raise ValueError(f"expected PNG or WebP original: {path}")
        im = f.convert("RGBA")
    alpha = im.getchannel("A")
    lo, hi = alpha.getextrema()
    if lo != 0 or hi == 0:
        raise ValueError(f"not meaningful transparent RGBA: {path}")
    # Ignore almost invisible bloom pixels when estimating motif size.
    visible = alpha.point(lambda v: 255 if v >= 24 else 0)
    bounds = visible.getbbox() or alpha.getbbox()
    if bounds is None:
        raise ValueError(f"empty source: {path}")
    return im, {
        "source": str(path),
        "sha256": hashlib.sha256(raw).hexdigest(),
        "source_px": [im.width, im.height],
        "visible_alpha_bbox": list(bounds),
        "alpha_range": [lo, hi],
    }


def produce(sources: list[Path], on_screen_width: int, out: Path, manifest: Path) -> None:
    if not 24 <= on_screen_width <= 300:
        raise ValueError("--motif-width must be 24..300 screen pixels")
    checked = [inspect(p) for p in sources]
    cell_w, cell_h = 380, 285
    sheet = Image.new("RGB", (cell_w * 2, cell_h * len(checked) + 42), (18, 21, 28))
    d = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    d.text((12, 10), "G3 SOURCE SCALE REVIEW -- NOT GODOT / NOT ART APPROVAL",
           fill="white", font=font)
    entries = []
    for n, (source, meta) in enumerate(checked):
        l, t, r, b = meta["visible_alpha_bbox"]
        factor = on_screen_width / max(1, r - l)
        target_w = max(1, round(source.width * factor))
        target_h = max(1, round(source.height * factor))
        if target_w > cell_w - 20 or target_h > cell_h - 45:
            raise ValueError(f"{sources[n].name} exceeds preview; reduce --motif-width")
        preview = source.resize((target_w, target_h), Image.Resampling.LANCZOS)
        for col, bg in enumerate((DARK, LIGHT)):
            x, y = col * cell_w, 42 + n * cell_h
            panel = Image.new("RGBA", (cell_w, cell_h), bg)
            px = (cell_w - target_w) // 2
            py = 22 + (cell_h - 32 - target_h) // 2
            panel.alpha_composite(preview, (px, py))
            label = f"{sources[n].name} / {'dark' if col == 0 else 'light'} / motif {on_screen_width}px"
            ImageDraw.Draw(panel).text((8, 8), label[:58],
                fill="white" if col == 0 else "black", font=font)
            sheet.paste(panel.convert("RGB"), (x, y))
        entries.append({**meta, "display_factor": factor,
                        "preview_image_px": [target_w, target_h]})
    out.parent.mkdir(parents=True, exist_ok=True)
    manifest.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out, format="PNG", optimize=True)
    payload = {
        "type": "G3_SOURCE_ONLY_NO_GODOT_NO_ART_APPROVAL",
        "motif_width_px_at_intended_1x": on_screen_width,
        "warning": "Preview scale MUST match intended Godot scale. Human reviews art/motion.",
        "sources": entries,
    }
    manifest.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n",
                        encoding="utf-8")
    print(f"G3_SOURCE_PREVIEW_CREATED {out} sources={len(entries)} ART=MANUAL_PENDING")


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--source", action="append", type=Path, required=True,
                   help="Original transparent PNG/WebP; repeat per pose")
    p.add_argument("--motif-width", type=int, required=True,
                   help="Readable motif width at intended 1x game size")
    p.add_argument("--out", type=Path, required=True,
                   help="Source-only dark/light contact sheet PNG")
    p.add_argument("--manifest", type=Path,
                   help="Source/provenance JSON; default beside output")
    args = p.parse_args()
    produce(args.source, args.motif_width,
            args.out, args.manifest or args.out.with_suffix(".json"))


if __name__ == "__main__":
    main()
