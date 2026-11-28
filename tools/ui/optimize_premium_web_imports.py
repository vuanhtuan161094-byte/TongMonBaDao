#!/usr/bin/env python3
"""Web-only texture import policy; never edit or remove source artwork.

Godot's Lossy texture import uses WebP storage. Restrict to 12 opaque
facility backgrounds and leave every animation, VFX and HUD texture intact.
Run after initial import and before a second import in the ephemeral CI checkout.
"""
from pathlib import Path
import re
import sys

project = Path(sys.argv[1])
root = project / "art/uiux/premium"
scenes = sorted(root.glob("*_scene.webp"))
if len(scenes) != 12:
    raise SystemExit(f"expected 12 Premium scenes, got {len(scenes)}")
for source in scenes:
    meta = Path(str(source) + ".import")
    if not meta.is_file():
        raise SystemExit(f"missing generated import metadata: {meta}")
    text = meta.read_text(encoding="utf-8")
    if 'importer="texture"' not in text:
        raise SystemExit(f"not a texture import: {meta}")
    text, n = re.subn(r"(?m)^compress/mode=.*$", "compress/mode=1", text)
    text, q = re.subn(r"(?m)^compress/lossy_quality=.*$", "compress/lossy_quality=0.92", text)
    if n != 1 or q != 1:
        raise SystemExit(f"unexpected texture importer fields: {meta}")
    meta.write_text(text, encoding="utf-8")
    print(f"{source.name}: lossy storage, quality=0.92, source={source.stat().st_size} bytes")
print("All character frames, atlases, alpha UI textures and VFX kept unchanged.")
