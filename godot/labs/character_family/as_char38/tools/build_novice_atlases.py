#!/usr/bin/env python3
"""Build the AS-CHAR-38 novice static-idle directional atlases from approved source masters.

This tool never synthesizes motion. It crops four authored turnaround views, removes red
edge contamination only on the alpha boundary, registers them to a shared foot pivot,
and emits one real PNG frame per direction plus Godot SpriteFrames resources.
Requires Pillow 11.x or compatible; no external executable or network access is used.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

DIRECTIONS = ("front", "right", "back", "left")
SOURCE_ORDER = {"front": 0, "right": 3, "back": 2, "left": 1}
CELL = 128
PIVOT = (64, 104)
VISIBLE_HEIGHT = 70
STYLE_ANCHOR_SHA256 = "435f8969c3d89468ddbdec837a44365b212b58e01082728c3f21f2b08249c118"
FAMILIES = (
    ("novice_female", "female"),
    ("novice_male", "male"),
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def red_dominant(pixel: tuple[int, int, int, int]) -> bool:
    r, g, b, a = pixel
    return a > 0 and r >= 95 and r - g >= 26 and r - b >= 26


def clean_red_contour(image: Image.Image) -> tuple[Image.Image, int]:
    """Decontaminate red generated fringe only in the outer alpha ring."""
    image = image.convert("RGBA")
    alpha = image.getchannel("A")
    solid = alpha.point(lambda value: 255 if value >= 128 else 0)
    interior = solid.filter(ImageFilter.MinFilter(3))
    boundary = ImageChops.subtract(solid, interior).load()
    source = image.copy()
    src = source.load()
    w, h = image.size
    replacements: list[tuple[int, int, tuple[int, int, int, int]]] = []
    for y in range(h):
        for x in range(w):
            pixel = src[x, y]
            if not boundary[x, y] or not red_dominant(pixel):
                continue
            replacement = None
            for radius in (1, 2, 3):
                candidates = []
                for dy in range(-radius, radius + 1):
                    ny = y + dy
                    if not 0 <= ny < h:
                        continue
                    for dx in range(-radius, radius + 1):
                        nx = x + dx
                        if not 0 <= nx < w or dx * dx + dy * dy > radius * radius:
                            continue
                        sample = src[nx, ny]
                        if sample[3] >= 160 and not red_dominant(sample):
                            candidates.append((dx * dx + dy * dy, sample))
                if candidates:
                    replacement = min(candidates, key=lambda item: item[0])[1]
                    break
            if replacement:
                replacements.append((x, y, (replacement[0], replacement[1], replacement[2], pixel[3])))
            else:
                replacements.append((x, y, (pixel[0], pixel[1], pixel[2], 0)))
    output = image.load()
    for x, y, pixel in replacements:
        output[x, y] = pixel
    return image, len(replacements)


def find_four_views(image: Image.Image) -> list[tuple[int, int]]:
    alpha = image.getchannel("A")
    hits = []
    for x in range(image.width):
        count = sum(1 for y in range(image.height) if alpha.getpixel((x, y)) >= 16)
        if count > 2:
            hits.append(x)
    runs: list[list[int]] = []
    for x in hits:
        if not runs or x - runs[-1][-1] > 20:
            runs.append([x])
        else:
            runs[-1].append(x)
    ranges = [(run[0], run[-1] + 1) for run in runs if run[-1] - run[0] >= 100]
    if len(ranges) != 4:
        raise ValueError(f"expected four separate authored views; found {ranges}")
    return ranges


def alpha_bbox(image: Image.Image, threshold: int = 16) -> tuple[int, int, int, int] | None:
    return image.getchannel("A").point(lambda value: 255 if value >= threshold else 0).getbbox()


def register_view(source: Image.Image, x_range: tuple[int, int]) -> tuple[Image.Image, dict, int]:
    crop = source.crop((x_range[0], 0, x_range[1], source.height)).convert("RGBA")
    crop, changed = clean_red_contour(crop)
    bbox = alpha_bbox(crop)
    if bbox is None:
        raise ValueError(f"empty source view {x_range}")
    art = crop.crop(bbox)
    scale = VISIBLE_HEIGHT / art.height
    new_width = max(1, round(art.width * scale))
    resized = art.resize((new_width, VISIBLE_HEIGHT), Image.Resampling.LANCZOS)

    support_y = max(0, art.height - round(art.height * 0.12))
    support_x = []
    alpha = art.getchannel("A")
    for y in range(support_y, art.height):
        for x in range(art.width):
            if alpha.getpixel((x, y)) >= 32:
                support_x.append(x)
    foot_center = (min(support_x) + max(support_x)) / 2 if support_x else art.width / 2
    left = round(PIVOT[0] - foot_center * scale)
    top = PIVOT[1] - VISIBLE_HEIGHT
    cell = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
    cell.alpha_composite(resized, (left, top))
    return cell, {
        "source_bbox": list(bbox),
        "source_x_range": list(x_range),
        "registered_rect": [left, top, new_width, VISIBLE_HEIGHT],
        "pivot": list(PIVOT),
        "mirror": False,
    }, changed


def spriteframes_text(family: str) -> str:
    sections = [
        '[gd_resource type="SpriteFrames" load_steps=6 format=3]',
        f'[ext_resource type="Texture2D" path="res://labs/character_family/as_char38/assets/{family}_idle_4dir.png" id="1_atlas"]',
    ]
    for index, direction in enumerate(DIRECTIONS):
        sections.append(
            f'[sub_resource type="AtlasTexture" id="AtlasTexture_{direction}"]\n'
            f'atlas = ExtResource("1_atlas")\n'
            f'region = Rect2({index * CELL}, 0, {CELL}, {CELL})'
        )
    animations = []
    for direction in DIRECTIONS:
        animations.append(
            '{"frames": [{"duration": 1.0, "texture": SubResource("AtlasTexture_%s")}], '
            '"loop": true, "name": &"idle_%s", "speed": 1.0}' % (direction, direction)
        )
    sections.append("[resource]\nanimations = [\n" + ",\n".join(animations) + "\n]")
    return "\n\n".join(sections) + "\n"


def centered_v4_reference(path: Path) -> list[Image.Image]:
    source = Image.open(path).convert("RGBA")
    frames = []
    for index in range(4):
        frame = source.crop((0, index * 384, 320, (index + 1) * 384))
        bbox = alpha_bbox(frame)
        if bbox is None:
            raise ValueError(f"V4 style reference frame {index} is empty")
        art = frame.crop(bbox)
        scale = VISIBLE_HEIGHT / art.height
        resized = art.resize((max(1, round(art.width * scale)), VISIBLE_HEIGHT), Image.Resampling.LANCZOS)
        cell = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
        cell.alpha_composite(resized, (round((CELL - resized.width) / 2), PIVOT[1] - VISIBLE_HEIGHT))
        frames.append(cell)
    return frames


def make_contact_sheets(output_dir: Path, atlases: dict[str, Path], v4_path: Path) -> None:
    dark = (25, 27, 32, 255)
    gold = (226, 202, 143, 255)
    sheet = Image.new("RGBA", (1280, 720), dark)
    draw = ImageDraw.Draw(sheet)
    try:
        title_font = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 20)
    except OSError:
        title_font = ImageFont.load_default()
    columns = [
        ("NOVICE NAM", Image.open(atlases["novice_male"]).convert("RGBA")),
        ("NOVICE NU", Image.open(atlases["novice_female"]).convert("RGBA")),
        ("NU DOC TU V4 · STYLE ANCHOR ONLY", Image.new("RGBA", (CELL * 4, CELL), (0, 0, 0, 0))),
    ]
    v4_frames = centered_v4_reference(v4_path)
    for index, frame in enumerate(v4_frames):
        columns[2][1].alpha_composite(frame, (index * CELL, 0))
    x_positions = (55, 440, 825)
    for (label, atlas), x in zip(columns, x_positions):
        draw.rounded_rectangle((x, 72, x + 350, 654), radius=12, fill=(35, 38, 45, 255), outline=(112, 94, 61, 255), width=2)
        draw.text((x + 18, 92), label, font=title_font, fill=gold)
        visual = atlas.crop((0, 0, CELL, CELL)).resize((384, 384), Image.Resampling.NEAREST)
        sheet.alpha_composite(visual, (x + 18, 145))
        draw.text((x + 18, 532), "NATIVE GAME SIZE · 70px BODY", font=ImageFont.load_default(), fill=(200, 204, 210, 255))
        sheet.alpha_composite(atlas.crop((0, 0, CELL, CELL)), (x + 130, 552))
    sheet.convert("RGB").save(output_dir / "g1_style_comparison.png", quality=95)

    directions = Image.new("RGBA", (1280, 720), dark)
    ddraw = ImageDraw.Draw(directions)
    ddraw.text((24, 14), "AS-CHAR-38 · HAI MẪU TÂN THỦ · 4 HƯỚNG · STATIC IDLE", font=title_font, fill=gold)
    labels = ("FRONT / DOWN", "RIGHT", "BACK / UP", "LEFT")
    for row, family in enumerate(("novice_male", "novice_female")):
        atlas = Image.open(atlases[family]).convert("RGBA")
        y = 55 + row * 325
        ddraw.text((24, y), "NOVICE NAM" if row == 0 else "NOVICE NU", font=title_font, fill=gold)
        for col, label in enumerate(labels):
            x = 30 + col * 310
            ddraw.text((x, y + 30), label, font=ImageFont.load_default(), fill=(200, 204, 210, 255))
            cell = atlas.crop((col * CELL, 0, (col + 1) * CELL, CELL)).resize((256, 256), Image.Resampling.NEAREST)
            directions.alpha_composite(cell, (x + 18, y + 48))
    ddraw.text((24, 696), "Each direction is one static pose; Walk/Cast/Attack/Hit/Death remain ART_PENDING.", font=ImageFont.load_default(), fill=(220, 170, 132, 255))
    directions.convert("RGB").save(output_dir / "g1_directional_coverage.png", quality=95)


def build(root: Path) -> dict:
    asset_root = root / "godot/labs/character_family/as_char38/assets"
    asset_root.mkdir(parents=True, exist_ok=True)
    family_records = []
    atlas_paths: dict[str, Path] = {}
    for family, sex in FAMILIES:
        source_path = asset_root / family / "master_turnaround.png"
        if not source_path.is_file():
            raise FileNotFoundError(f"required authored source missing: {source_path}")
        source = Image.open(source_path).convert("RGBA")
        ranges = find_four_views(source)
        atlas = Image.new("RGBA", (CELL * 4, CELL), (0, 0, 0, 0))
        frame_records = {}
        cleaned = 0
        for output_index, direction in enumerate(DIRECTIONS):
            source_index = SOURCE_ORDER[direction]
            cell, frame_record, changed = register_view(source, ranges[source_index])
            atlas.alpha_composite(cell, (output_index * CELL, 0))
            frame_records[direction] = frame_record
            cleaned += changed
        atlas_path = asset_root / f"{family}_idle_4dir.png"
        atlas.save(atlas_path, optimize=True)
        atlas_paths[family] = atlas_path
        (asset_root / f"{family}.spriteframes.tres").write_text(spriteframes_text(family), encoding="utf-8")
        family_records.append({
            "family_id": family,
            "gender_id": sex,
            "status": "STATIC_IDLE_CANDIDATE",
            "source_path": source_path.relative_to(root).as_posix(),
            "source_sha256": sha256(source_path),
            "atlas_path": atlas_path.relative_to(root).as_posix(),
            "atlas_sha256": sha256(atlas_path),
            "spriteframes_path": (asset_root / f"{family}.spriteframes.tres").relative_to(root).as_posix(),
            "atlas_dimensions": [CELL * 4, CELL],
            "cell_size": [CELL, CELL],
            "visible_body_height_px": VISIBLE_HEIGHT,
            "pivot": list(PIVOT),
            "direction_order": list(DIRECTIONS),
            "frames_per_direction": 1,
            "idle_pose_status": "STATIC_POSE_CANDIDATE",
            "directions": frame_records,
            "edge_cleanup": {"red_dominant_boundary_pixels_replaced": cleaned, "method": "alpha boundary ring only"},
            "motion_clips": {
                "walk": "ART_PENDING",
                "cast": "ART_PENDING",
                "attack": "ART_PENDING",
                "hit": "ART_PENDING",
                "death": "ART_PENDING"
            },
            "layers": "NOT_PROVIDED",
            "visual_approval": "PENDING_OWNER_REVIEW",
            "production_import": "NONE"
        })
    v4_path = root / "godot/labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png"
    if not v4_path.is_file():
        raise FileNotFoundError(f"required style reference missing: {v4_path}")
    manifest = {
        "schema_version": 1,
        "packet": "AS-CHAR-38 G1 novice static directional atlas",
        "created_from_head": "bc3d2ccd3798b40914497f7772bbd5b980c4cfe1",
        "style_anchor": {
            "asset_id": "nu_doc_tu_locked_master",
            "sha256": STYLE_ANCHOR_SHA256,
            "use": "visual quality and proportions reference only; V4 identity/art is not copied"
        },
        "export_contract": {
            "canvas": [CELL, CELL],
            "pivot": list(PIVOT),
            "visible_body_height_px": VISIBLE_HEIGHT,
            "direction_order": list(DIRECTIONS),
            "mirror_used": False,
            "texture_filter": "nearest"
        },
        "provenance": {
            "generator": "ChatGPT ImageGen V2; transparent turnaround master retained byte-for-byte",
            "external_art_used": False,
            "motion_authoring": "NONE"
        },
        "families": family_records
    }
    manifest_path = asset_root / "g1_asset_manifest.json"
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    make_contact_sheets(root / "godot/labs/character_family/as_char38", atlas_paths, v4_path)
    return manifest


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[5])
    args = parser.parse_args()
    manifest = build(args.root.resolve())
    for family in manifest["families"]:
        print(f"{family['family_id']} source={family['source_sha256']} atlas={family['atlas_sha256']}")
    print(f"family_count={len(manifest['families'])} status=STATIC_IDLE_CANDIDATE")
    print("motion_status=ART_PENDING; no motion was generated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())


