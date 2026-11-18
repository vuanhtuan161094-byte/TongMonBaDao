#!/usr/bin/env python3
"""Pack original FIST14 R5 RGBA poses into separate Godot atlas layers.

Source artwork is retained byte-for-byte. This tool only places each master on
a transparent common-size cell; it does not draw, recolor, rotate, duplicate,
or warp poses.
"""
from __future__ import annotations

import hashlib
import json
import math
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / "godot/labs/combat_lab/fist14/r5"
SOURCE = BASE / "source"
ASSETS = BASE / "assets"
CELL = (2048, 1024)

LAYERS = {
    "f14_r5_attack_pose_atlas.png": {
        "columns": 2,
        "roles": [
            ("charge_coil", "f14_r5_charge_coil.png", (1130, 570)),
            ("release_lunge", "f14_r5_release_lunge.png", (1470, 590)),
            ("peak_strike", "f14_r5_peak_strike.png", (1470, 500)),
        ],
    },
    "f14_r5_contact_recoil_atlas.png": {
        "columns": 2,
        "roles": [
            ("contact_impact", "f14_r5_contact_impact.png", (1460, 470)),
            ("recoil", "f14_r5_recoil.png", (1210, 530)),
        ],
    },
    "f14_r5_meridian_mark_atlas.png": {
        "columns": 1,
        "roles": [("meridian_mark", "f14_r5_meridian_mark.png", (885, 450))],
    },
}


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def main() -> int:
    ASSETS.mkdir(parents=True, exist_ok=True)
    manifest: dict[str, object] = {
        "revision": "FIST14_R5",
        "cell_px": list(CELL),
        "source_art_unchanged": True,
        "pose_generation": "independent RGBA image generations; no reused R2/R3/R4 sprite",
        "atlases": [],
    }
    for filename, spec in LAYERS.items():
        roles = spec["roles"]
        columns = int(spec["columns"])
        rows = math.ceil(len(roles) / columns)
        atlas = Image.new("RGBA", (CELL[0] * columns, CELL[1] * rows), (0, 0, 0, 0))
        frames: list[dict[str, object]] = []
        for index, (role, source_name, focus) in enumerate(roles):
            path = SOURCE / source_name
            raw = path.read_bytes()
            with Image.open(path) as opened:
                image = opened.convert("RGBA")
            if image.width > CELL[0] or image.height > CELL[1]:
                raise ValueError(f"{source_name} exceeds {CELL[0]}x{CELL[1]} source cell")
            if image.getchannel("A").getextrema()[0] != 0:
                raise ValueError(f"{source_name} has no fully transparent pixels")
            if image.getchannel("A").getbbox() is None:
                raise ValueError(f"{source_name} is fully transparent")
            cell_x = (index % columns) * CELL[0]
            cell_y = (index // columns) * CELL[1]
            local_x = (CELL[0] - image.width) // 2
            local_y = (CELL[1] - image.height) // 2
            atlas.alpha_composite(image, (cell_x + local_x, cell_y + local_y))
            frames.append({
                "index": index,
                "role": role,
                "source": f"godot/labs/combat_lab/fist14/r5/source/{source_name}",
                "source_sha256": sha(raw),
                "source_px": list(image.size),
                "source_alpha_bbox": list(image.getchannel("A").getbbox()),
                "cell_offset_px": [local_x, local_y],
                "focal_point_source_px": list(focus),
                "focal_point_cell_px": [local_x + focus[0], local_y + focus[1]],
            })
        output = ASSETS / filename
        atlas.save(output, format="PNG", optimize=True)
        manifest["atlases"].append({
            "path": f"godot/labs/combat_lab/fist14/r5/assets/{filename}",
            "width": atlas.width,
            "height": atlas.height,
            "cell_width": CELL[0],
            "cell_height": CELL[1],
            "columns": columns,
            "frames": len(roles),
            "sha256": sha(output.read_bytes()),
            "poses": frames,
        })
    (ASSETS / "atlas_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    for item in manifest["atlases"]:
        print(f"FIST14_R5_ATLAS={item['path']} size={item['width']}x{item['height']} "
              f"frames={item['frames']} sha256={item['sha256']}")
    print("FIST14_R5_SOURCE_PACK_PASS originals_unchanged=true no_pose_synthesis=true")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
