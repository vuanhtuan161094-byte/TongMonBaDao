#!/usr/bin/env python3
"""Non-destructive receipt for the exact owner-approved AS-CHAR-38 male art source.

This tool CANNOT establish that an arbitrary image is the same image the owner saw.
It verifies original bytes and records an immutable intake receipt for human comparison.
No game, animation, VFX or approved master is changed by this utility.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path
from shutil import copyfileobj

from PIL import Image, UnidentifiedImageError

PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"
REJECTED_OR_WRONG_REFERENCE_SHA256 = {
    # Nữ Độc Tu V4 is STYLE REFERENCE ONLY; never call this a male master.
    "435f8969c3d89468ddbdec837a44365b212b58e01082728c3f21f2b08249c118",
    # Rejected/undecided older neutral male turnaround already on PR #72.
    "840d0f22e60f3f909eb730b47d22af1d977eaabccb80ae0396db2754fe738240",
}


def checksum(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def inspect_png(path: Path) -> dict:
    with path.open("rb") as stream:
        if stream.read(8) != PNG_SIGNATURE:
            raise ValueError("SOURCE_NOT_PNG_BYTES")
    try:
        with Image.open(path) as img:
            if img.format != "PNG":
                raise ValueError("SOURCE_IMAGE_FORMAT_NOT_PNG")
            img.load()
            width, height = img.size
            if min(width, height) < 64 or max(width, height) > 8192:
                raise ValueError("UNEXPECTED_IMAGE_DIMENSIONS")
            has_alpha = "A" in img.getbands() or "transparency" in img.info
            alpha_extrema = img.convert("RGBA").getchannel("A").getextrema()
            return {
                "width": width,
                "height": height,
                "mode": img.mode,
                "alpha_channel_or_transparency_present": bool(has_alpha),
                "alpha_min_max": list(alpha_extrema),
                "fully_opaque": alpha_extrema == (255, 255),
            }
    except (UnidentifiedImageError, OSError) as exc:
        raise ValueError("INVALID_PNG_PAYLOAD") from exc


def intake(source: Path, destination: Path, original_context: str, expected_sha256: str | None) -> dict:
    if not source.is_file():
        raise FileNotFoundError(f"SOURCE_MISSING: {source}")
    if not original_context.strip():
        raise ValueError("SOURCE_CONTEXT_REQUIRED (e.g., conversation-generated final approved front image)")
    sha = checksum(source)
    if expected_sha256 and sha != expected_sha256.lower():
        raise ValueError(f"SHA256_MISMATCH: expected={expected_sha256}, actual={sha}")
    if sha in REJECTED_OR_WRONG_REFERENCE_SHA256:
        raise ValueError("WRONG_MASTER: female V4 style anchor or known rejected neutral male candidate")
    details = inspect_png(source)
    destination.mkdir(parents=True, exist_ok=True)
    filename = f"male_poison_owner_front_{sha[:16]}.png"
    target = destination / filename
    if target.exists():
        if checksum(target) != sha:
            raise ValueError(f"NONDESTRUCTIVE_REFUSAL: existing target differs: {target}")
    else:
        with source.open("rb") as src, target.open("xb") as dst:
            copyfileobj(src, dst)
    if checksum(target) != sha:
        raise IOError("COPY_VERIFICATION_FAILED")
    result = {
        "packet": "AS-CHAR-38",
        "source_identity": "male_poison_cultivator_front_owner_visual_decision_2026-11-12",
        "source_original_filename": source.name,
        "source_context_reported": original_context,
        "sha256": sha,
        "size_bytes": target.stat().st_size,
        "image": details,
        "receipt_time_utc": datetime.now(timezone.utc).isoformat(),
        "preserved_file": filename,
        "art_identity_status": "VISUAL_MATCH_TO_OWNER_APPROVED_IMAGE_PENDING",
        "source_integrity_status": "VERIFIED_COPY_SHA256",
        "four_directions": "PENDING_AUTHENTIC_FRONT_SOURCE_REVIEW",
        "production_import": "NOT_AUTHORIZED_BY_INTAKE",
        "review_required": [
            "Compare source visually 1:1 with the FINAL owner-approved image in the previous chat, NOT old G1 candidates",
            "Confirm full-body complete and pixel-art detailing at 60-75px native size",
            "If opaque or matte background, separate alpha without changing immutable original bytes",
            "Approve source identity before generating front/right/back/left artwork",
        ],
    }
    receipt = destination / f"male_poison_owner_front_{sha[:16]}.json"
    if receipt.exists():
        previous = json.loads(receipt.read_text(encoding="utf-8"))
        if previous.get("sha256") != sha:
            raise ValueError("NONDESTRUCTIVE_REFUSAL: prior receipt differs")
        return previous
    receipt.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", required=True, type=Path, help="exact original source PNG; never an earlier candidate")
    parser.add_argument("--destination", required=True, type=Path, help="new immutable source receipt folder")
    parser.add_argument("--original-context", required=True, help="reported art origin / transfer method, not proof of approval")
    parser.add_argument("--expected-sha256", default=None, help="required if original SHA256 was previously recorded")
    args = parser.parse_args()
    result = intake(args.source, args.destination, args.original_context, args.expected_sha256)
    print(json.dumps(result, indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
