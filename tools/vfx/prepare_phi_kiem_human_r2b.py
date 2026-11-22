#!/usr/bin/env python3
"""Recover and assess an ImageGen-original Human Sword R2B candidate (Art-First G3).

SOURCE-ONLY. No Godot, no release gate, no artist or owner approval.
The original isolated eight-pose source is recovered from the preserved R2
Library ZIP; this helper re-composites, recolors and inspects its original poses.
It never manufactures a new cast/target/hit/actor or invokes any PvE content.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from io import BytesIO
from zipfile import ZipFile

import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

R2_ZIP_SHA256 = "0b0ece797ff2219882a077ec9ab81cd03688e6ce03d810db8559939028e358b8"
R2_ORIGINAL_MASTER_SHA256 = "2ba61b613d9351379069bf1b3faac630d98db323e74128006e76fa7975d70ce0"
R2B_ATLAS_SHA256 = "fe7ff0cf27c8f75ee601d5899683fe28ccfc01de3c2b8244cf66bfe9fc010732"
PHASES = ("charge", "growth", "release", "flight_A", "flight_B", "single_contact", "fragment", "fade")


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def produce(source_zip: Path, output: Path) -> None:
    raw = source_zip.read_bytes()
    if sha256(raw) != R2_ZIP_SHA256:
        raise ValueError("R2_SOURCE_ARCHIVE_SHA_MISMATCH (do not substitute a similar asset)")
    with ZipFile(BytesIO(raw)) as z:
        master = z.read("original_master_imagegen_1774x887.png")
        if sha256(master) != R2_ORIGINAL_MASTER_SHA256:
            raise ValueError("R2_ORIGINAL_MASTER_SHA_MISMATCH")
        originals = [
            Image.open(BytesIO(z.read(
                f"source_candidate/phi_kiem_human_r2_illustrated_pose_{i:02}.png"
            ))).convert("RGBA") for i in range(1, 9)
        ]

    output.mkdir(parents=True, exist_ok=True)
    (output / "source_master_imagegen_1774x887.png").write_bytes(master)
    images: list[Image.Image] = []
    pose_hashes: list[str] = []

    for i, pose in enumerate(originals):
        # All poses come from eight DIFFERENT source cells, not transform-copied
        # from a single icon. Cleaning never implies aesthetic approval.
        if i in (3, 4):
            pose = pose.resize((560, 345), Image.Resampling.LANCZOS)
            working = Image.new("RGBA", (640, 512))
            working.alpha_composite(pose, (40, 82))
        else:
            working = pose.resize((640, 512), Image.Resampling.LANCZOS)

        pixels = np.array(working, dtype=np.float32)
        alpha = pixels[:, :, 3] / 255.0
        luminance = (pixels[:, :, :3] * np.array(
            [0.2126, 0.7152, 0.0722], dtype=np.float32
        )).sum(axis=2) / 255.0
        hot = np.clip((luminance - 0.62) / 0.34, 0, 1) ** 2.3
        blue = np.stack((30 + 215 * hot, 89 + 166 * hot, 178 + 77 * hot), axis=2)
        texture = np.clip(pixels[:, :, :3] / 255, 0, 1)
        rgb = 0.74 * blue + 0.26 * (texture * 255.0)
        refined_alpha = np.clip(alpha ** 0.73 * 255, 0, 255)
        refined_alpha[refined_alpha < 5] = 0
        illustrated = Image.fromarray(
            np.dstack((rgb, refined_alpha)).astype("uint8"), "RGBA"
        )
        # The small shadow underlayer is a COMPOSITING AID, not hero source art.
        shadow = illustrated.getchannel("A").filter(
            ImageFilter.GaussianBlur(radius=4.2)
        ).point(lambda v: int(v * 0.35))
        energy = Image.new("RGBA", illustrated.size, (12, 27, 89, 0))
        energy.putalpha(shadow)
        energy.alpha_composite(illustrated)
        cel = Image.new("RGBA", (512, 512))
        cel.alpha_composite(
            energy.resize((444, 346), Image.Resampling.LANCZOS), (34, 83)
        )
        data_path = output / f"phi_kiem_r2b_pose_{i + 1:02}.png"
        cel.save(data_path, optimize=True)
        images.append(cel)
        pose_hashes.append(sha256(data_path.read_bytes()))

    atlas = Image.new("RGBA", (2048, 1024))
    for i, pose in enumerate(images):
        atlas.alpha_composite(pose, (i % 4 * 512, i // 4 * 512))
    atlas_path = output / "phi_kiem_human_r2b_atlas_rgba.png"
    atlas.save(atlas_path, optimize=True)
    if len(set(pose_hashes)) != 8:
        raise ValueError("DUPLICATED_POSE_BYTES")
    if not all(i.getchannel("A").getextrema()[0] == 0 and
               i.getchannel("A").getextrema()[1] > 0 for i in images):
        raise ValueError("INVALID_POSE_ALPHA")

    board = Image.new("RGB", (1320, 980), (20, 27, 43))
    draw = ImageDraw.Draw(board)
    font = ImageFont.load_default()
    draw.text((28, 10), "SOURCE ONLY / R2B / NOT GODOT / NOT ART APPROVAL",
              fill="white", font=font)
    for row, bg in enumerate(((23, 30, 49), (207, 204, 191))):
        for i, cel in enumerate(images):
            x, y = 20 + i % 4 * 325, 50 + row * 450 + i // 4 * 208
            panel = Image.new("RGBA", (305, 180), bg + (255,))
            panel.alpha_composite(
                cel.resize((210, 180), Image.Resampling.LANCZOS), (47, 0)
            )
            board.paste(panel.convert("RGB"), (x, y))
            draw.text((x + 8, y + 181), f"{i + 1:02} {PHASES[i]}",
                      font=font, fill="white")
    board.save(output / "r2b_1x_dark_bright_source_preflight.png")

    evidence = {
        "source_zip_sha256": sha256(raw),
        "original_master_sha256": sha256(master),
        "pose_count": len(images),
        "all_pose_alpha_valid": True,
        "all_pose_hash_unique": True,
        "pose_sha256": pose_hashes,
        "atlas_sha256": sha256(atlas_path.read_bytes()),
        "expected_previous_r2b_atlas_sha256": R2B_ATLAS_SHA256,
        "byte_exact_reproduction": sha256(atlas_path.read_bytes()) == R2B_ATLAS_SHA256,
        "art_self_status": "G3_ART_REWORK_REQUIRED",
        "godot_native": "NOT_EXECUTED",
        "owner_approval": "PENDING",
        "pve": "HOLD",
    }
    (output / "r2b_preflight.json").write_text(
        json.dumps(evidence, indent=2) + "\n", encoding="utf-8"
    )
    print("SWORD_R2B_SOURCE_ONLY_REPAINT_COMPLETED")
    print(json.dumps(evidence, indent=2))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--r2-source-zip", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()
    produce(args.r2_source_zip, args.output_dir)


if __name__ == "__main__":
    main()
