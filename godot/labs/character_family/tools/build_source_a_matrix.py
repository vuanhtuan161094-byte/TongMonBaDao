#!/usr/bin/env python3
"""Build a deterministic, non-authoritative matrix for the Source A actor packages in this checkout."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
ACTOR_ROOT = ROOT / "godot" / "assets" / "actors"
OUTPUT = ROOT / "godot" / "labs" / "character_family" / "source_a_asset_matrix.json"

CLASSIFICATION = {
    "1113028_1": ("SOURCE_RIG_IDENTITY_UNKNOWN", "Do not assign player identity or school from the ID alone."),
    "body_1110201": ("BODY_RIG_ROLE_UNKNOWN", "Body package; role and identity are unverified."),
    "body_1120402": ("BODY_RIG_ROLE_UNKNOWN", "Body package; role and identity are unverified."),
    "v5_sa_female_1113028_1": ("FEMALE_VISUAL_CANDIDATE", "Source A visual package; not the locked Nữ Độc Tu identity."),
    "v5_sa_male_body_1110201": ("MALE_VISUAL_CANDIDATE", "Source A visual package; exact character identity is unverified."),
    "v5_sa_monster_1113031_1": ("MONSTER", "Monster package; not a disciple/player character."),
    "v5_sa_boss_410041_1": ("BOSS_SLOT_CANDIDATE", "Boss-slot candidate; no Boss name or identity is asserted."),
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    rows = []
    for package_id in sorted(CLASSIFICATION):
        folder = ACTOR_ROOT / package_id
        manifest = folder / "asset.json"
        if not manifest.is_file():
            raise SystemExit(f"missing actor manifest: {manifest.relative_to(ROOT)}")
        data = json.loads(manifest.read_text(encoding="utf-8"))
        classification, note = CLASSIFICATION[package_id]
        clips = []
        for clip in data.get("clips", []):
            frames = int(clip.get("frames", 0))
            stored = int(clip.get("stored_frames", 0))
            clips.append({
                "name": clip.get("name", ""),
                "frames": frames,
                "stored_frames": stored,
                "duration_seconds": clip.get("duration_seconds"),
                "loop": clip.get("loop"),
                "frame_count_status": "MATCH" if frames == stored else "MISMATCH",
                "visual_acceptance": "NOT_ESTABLISHED_BY_MANIFEST"
            })
        rows.append({
            "asset_id": package_id,
            "asset_json": (manifest.relative_to(ROOT)).as_posix(),
            "asset_json_sha256": sha256(manifest),
            "source_fingerprint": data.get("fingerprint", ""),
            "classification": classification,
            "classification_note": note,
            "canvas": data.get("canvas"),
            "foot_anchor": data.get("foot_anchor"),
            "fps": data.get("fps"),
            "stored_frames": data.get("stored_frames"),
            "atlas_pages": data.get("atlas_pages", []),
            "file_sha256": data.get("file_sha256", {}),
            "clips": clips,
            "runtime_identity": "NOT_ASSERTED",
            "owner_visual_acceptance": "NOT_ASSERTED"
        })
    payload = {
        "schema_version": 1,
        "purpose": "Read-only inventory of actor packages already in this project; not a character identity or visual approval authority.",
        "generated_from_head": "2d05b619e82c0010c58254107448be35303b0917",
        "classification_policy": "Preserve unknown roles as unknown. Monster and Boss labels come only from explicit package IDs.",
        "source_a_actor_packages": rows
    }
    OUTPUT.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"SOURCE_A_MATRIX_PASS packages={len(rows)} output={OUTPUT.relative_to(ROOT).as_posix()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
