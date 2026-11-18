#!/usr/bin/env python3
"""Bake the isolated FIST14 simple pilot from its immutable first-party master."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import hashlib

ROOT = Path(__file__).resolve().parent
ORIGINAL = ROOT.parent / "r3/source/fist14_original_rgba_1774x887.png"
EXPECTED = "e0006ceb6208cb7cb037d2909f2ca9d27e10f63b7d71871f53b6b55f4903b7b5"
OUT = ROOT / "assets"

def main() -> None:
    raw = ORIGINAL.read_bytes()
    digest = hashlib.sha256(raw).hexdigest()
    if digest != EXPECTED:
        raise SystemExit(f"FIST14_SIMPLE_SOURCE_SHA_FAIL {digest}")
    src = Image.open(ORIGINAL).convert("RGBA")

    # Frame the single existing clenched fist. The polygon trims the old
    # poster-like surrounding wash while retaining the wrist and knuckles.
    box = (1080, 250, 1535, 785)
    fist = src.crop(box)
    mask = Image.new("L", fist.size, 0)
    points = [(37,205),(68,150),(121,92),(194,55),(276,50),(350,78),
              (402,132),(429,203),(430,294),(404,365),(360,415),
              (304,446),(249,444),(194,420),(136,405),(91,369),
              (54,322),(35,265)]
    ImageDraw.Draw(mask).polygon(points, fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(3.0))
    fist.putalpha(Image.eval(mask, lambda a: (a * 255) // 255))

    # One attached, restrained red edge falloff from the fist silhouette.
    glow = Image.new("RGBA", fist.size, (190, 16, 34, 0))
    glow.putalpha(fist.getchannel("A").filter(ImageFilter.GaussianBlur(17)).point(lambda a: a * 44 // 255))

    # Reuse the source's own white-hot front flash, masked into a local contact.
    flash = src.crop((1370, 365, 1735, 705))
    flash_mask = Image.new("L", flash.size, 0)
    ImageDraw.Draw(flash_mask).ellipse((63, 21, 325, 316), fill=255)
    flash_mask = flash_mask.filter(ImageFilter.GaussianBlur(5.0))
    flash.putalpha(Image.eval(flash_mask, lambda a: (a * 220) // 255))

    OUT.mkdir(parents=True, exist_ok=True)
    for name, image in (("fist14_closed_fist.png", fist),
                        ("fist14_edge_glow.png", glow),
                        ("fist14_local_contact.png", flash)):
        image.save(OUT / name, optimize=True)
    print("FIST14_SIMPLE_ASSETS_PASS original_sha256=" + digest)

if __name__ == "__main__":
    main()
