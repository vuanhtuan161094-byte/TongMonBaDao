#!/usr/bin/env python3
"""Validate and publish one shared VFX Factory native batch capture.

The Godot runner creates real fixture events and the raw screen movie. This
tool validates those receipts, normalizes one H.264 review video, samples the
actual timeline into a contact sheet, and updates only that school's Factory
registry/Web Review rows. It never promotes art or enables gameplay.
"""
from __future__ import annotations

import argparse
import hashlib
import io
import json
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

W, H, FPS = 1280, 720, 20
TECH_PASS = "NATIVE_TECH_PASS_GODOT_4.7.2_1280x720_20FPS_H264_FULL_DECODE"


def run(args: list[str], *, capture: bool = False) -> str:
    result = subprocess.run(args, check=True, text=capture, stdout=subprocess.PIPE if capture else None)
    return result.stdout if capture else ""


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def safe(root: Path, relative: str) -> Path:
    path = (root / relative).resolve()
    if root not in path.parents:
        raise SystemExit(f"PATH_OUTSIDE_GODOT_PROJECT {relative}")
    return path


def probe(video: Path) -> dict:
    return json.loads(run(["ffprobe", "-v", "error", "-show_streams", "-show_format", "-of", "json", str(video)], capture=True))


def sample_time(row: dict, entry: dict) -> list[dict]:
    start = float(row.get("video_start_seconds", 0.0))
    duration = max(0.1, float(row.get("video_duration_seconds", 0.1)))
    end = start + duration
    effect = str(entry.get("effect", ""))
    samples: list[dict] = []

    def add(label: str, at: float, basis: str, receipt: str = "") -> None:
        at = min(max(at, start + 0.025), end - 0.025)
        if any(item["phase"] == label for item in samples):
            return
        item = {"phase": label, "time_seconds": round(at, 3), "basis": basis,
                "frame_index": round(at * FPS)}
        if receipt:
            item["receipt_type"] = receipt
        samples.append(item)

    release = float(row.get("release_frame_seconds", -1.0))
    contact = float(row.get("contact_frame_seconds", -1.0))
    add("charge", start + min(0.08, duration * 0.18), "REAL_MAPBATTLE_SKILL_CAST")
    if release >= start:
        add("release", release + 0.025, "REAL_MAPBATTLE_SKILL_RELEASE", "skill_release")
    if effect in {"guard", "heal", "cleanse", "mark", "buff", "debuff"}:
        status_rows = [event for event in row.get("event_trace", [])
                       if event.get("event_type") == "status_applied" and event.get("accepted")]
        if status_rows:
            status = status_rows[0]
            status_at = float(status.get("capture_frame_seconds", start))
            state_duration = max(0.0, float(status.get("event_state_duration_seconds", 0.0)))
            add("state_start", status_at + 0.10, "REAL_MAPBATTLE_STATUS_APPLIED", "status_applied")
            if state_duration > 0.5:
                add("state_sustain", status_at + state_duration * 0.5,
                    "REAL_MAPBATTLE_STATUS_DURATION", "status_applied")
                add("state_end", status_at + state_duration - 0.10,
                    "REAL_MAPBATTLE_STATUS_EXPIRY", "status_applied")
        elif contact >= start:
            add("contact", contact, "REAL_MAPBATTLE_CONTACT_RECEIPT")
    elif contact >= start:
        add("contact", contact, "REAL_MAPBATTLE_CONTACT_RECEIPT")
    add("fade", end - min(0.09, duration * 0.06), "POST_RECEIPT_FADE_WINDOW")
    return samples


def grab_frame(video: Path, at: float) -> Image.Image:
    raw = subprocess.run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-ss", f"{at:.3f}",
                          "-i", str(video), "-frames:v", "1", "-f", "image2pipe", "-vcodec", "png", "-"],
                         check=True, stdout=subprocess.PIPE).stdout
    if not raw:
        raise SystemExit(f"CONTACT_SHEET_FRAME_MISSING at={at:.3f}")
    return Image.open(io.BytesIO(raw)).convert("RGB")


def contact_sheet(index: dict, video: Path, output: Path) -> None:
    columns, tile_w, tile_h, label_h = 5, 250, 141, 27
    samples: list[tuple[str, str, float]] = []
    for row in index["skills"]:
        name = str(row.get("name_vi", row.get("skill_id", "Skill")))
        for item in row.get("phase_samples", []):
            samples.append((name, str(item["phase"]), float(item["time_seconds"])))
    rows = (len(samples) + columns - 1) // columns
    sheet = Image.new("RGB", (columns * tile_w, rows * (tile_h + label_h)), (18, 21, 29))
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    for i, (name, phase, at) in enumerate(samples):
        frame = grab_frame(video, at)
        frame.thumbnail((tile_w - 4, tile_h), Image.Resampling.LANCZOS)
        x, y = (i % columns) * tile_w, (i // columns) * (tile_h + label_h)
        sheet.paste(frame, (x + (tile_w - frame.width) // 2, y + label_h))
        draw.text((x + 4, y + 6), f"{name} · {phase} · {at:.2f}s", fill=(240, 240, 245), font=font)
    sheet.save(output, optimize=True)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", type=Path, default=Path("godot"), help="Canonical Godot project root")
    parser.add_argument("--school", required=True)
    parser.add_argument("--batch-dir", required=True, help="Directory relative to Godot root")
    parser.add_argument("--raw-index", type=Path, required=True)
    parser.add_argument("--raw-movie", type=Path, required=True)
    args = parser.parse_args()
    root = args.repo.resolve()
    repo = root.parent
    school = args.school.strip().lower()
    batch_dir = args.batch_dir.strip("/")
    batch = safe(root, batch_dir)
    config_path = batch / "batch_config.json"
    manifest_path = batch / "manifest.json"
    registry_path = root / "labs/combat_lab/vfx_factory/registry.json"
    web_path = repo / "docs/operations/vfx_web_catalog_v1.json"
    config = json.loads(config_path.read_text(encoding="utf-8"))
    index = json.loads(args.raw_index.resolve().read_text(encoding="utf-8"))
    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    web = json.loads(web_path.read_text(encoding="utf-8"))
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    rows = index.get("skills", [])
    batch_info = registry.get("native_batches", {}).get(school, {})
    expected = int(batch_info.get("expected_count", 0))
    if index.get("schema") != "tmb.vfx_factory_native_batch_capture.v1" or index.get("school") != school:
        raise SystemExit("NATIVE_INDEX_SCHEMA_OR_SCHOOL_MISMATCH")
    if len(rows) != expected or expected != int(config.get("expected_count", 0)):
        raise SystemExit(f"NATIVE_BATCH_COUNT_MISMATCH index={len(rows)} registry={expected} config={config.get('expected_count')}")
    by_id = {entry["skill_id"]: entry for entry in registry.get("entries", [])
             if entry.get("school") == school and entry.get("native_batch") == school}
    if set(row.get("skill_id") for row in rows) != set(by_id):
        raise SystemExit("NATIVE_BATCH_SKILL_SET_MISMATCH")
    for row in rows:
        if row.get("fixture") != "REAL_MAPBATTLE_VFX_TEST_FIXTURE" \
                or row.get("synthetic_events", 1) != 0 \
                or row.get("event_count", 0) != row.get("accepted_event_count", -1) \
                or row.get("receipt_feed") != "REAL_MAPBATTLE_RECEIPT_ACCEPTED":
            raise SystemExit(f"NATIVE_BATCH_RECEIPT_AUDIT_FAILED {row.get('skill_id')}")
        if any(not event.get("accepted", False) for event in row.get("event_trace", [])):
            raise SystemExit(f"NATIVE_BATCH_HAS_REJECTED_EVENT {row.get('skill_id')}")
        if any(receipt.get("bound_to_candidate_visual", True) for receipt in row.get("fixture_setup_receipts", [])):
            raise SystemExit(f"NATIVE_SETUP_RECEIPT_BOUND_AS_CANDIDATE {row.get('skill_id')}")

    native_rel = f"{batch_dir}/review/native"
    native_dir = safe(root, native_rel)
    native_dir.mkdir(parents=True, exist_ok=True)
    prefix = f"{school}_batch1"
    movie = native_dir / f"{prefix}_native_1280x720.mp4"
    sheet = native_dir / f"{prefix}_contact_sheet_1280x720.png"
    index_path = native_dir / f"{prefix}_capture_index.json"
    run(["ffmpeg", "-hide_banner", "-loglevel", "warning", "-y", "-i", str(args.raw_movie.resolve()),
         "-an", "-vf", f"fps={FPS},scale={W}:{H}:flags=lanczos,format=yuv420p",
         "-c:v", "libx264", "-preset", "fast", "-crf", "19", "-pix_fmt", "yuv420p",
         "-movflags", "+faststart", str(movie)])
    stream_data = probe(movie)
    streams = [stream for stream in stream_data.get("streams", []) if stream.get("codec_type") == "video"]
    if not streams:
        raise SystemExit("NATIVE_VIDEO_NO_VIDEO_STREAM")
    stream = streams[0]
    if (stream.get("codec_name"), int(stream.get("width", 0)), int(stream.get("height", 0)), stream.get("pix_fmt")) != ("h264", W, H, "yuv420p"):
        raise SystemExit(f"NATIVE_VIDEO_FORMAT_INVALID {stream}")
    run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-i", str(movie), "-f", "null", "-"])
    index["technical_status"] = TECH_PASS
    accepted = sum(int(row.get("accepted_event_count", 0)) for row in rows)
    setup = sum(len(row.get("fixture_setup_receipts", [])) for row in rows)
    index["receipt_summary"] = {"candidate_events": accepted, "accepted_candidate_events": accepted,
                                "fixture_setup_receipts": setup, "synthetic_candidate_events": 0,
                                "setup_events_separate_from_candidate_events": True}
    index["movie"] = {"path": f"res://{native_rel}/{movie.name}", "codec": "h264", "viewport_px": [W, H],
                      "fps": FPS, "duration_seconds": float(stream_data.get("format", {}).get("duration", 0.0)),
                      "full_decode": "PASS", "sha256": digest(movie)}
    for row in rows:
        entry = by_id[row["skill_id"]]
        row["name_vi"] = entry.get("name_vi", row.get("name_vi", ""))
        row["phase_samples"] = sample_time(row, entry)
    contact_sheet(index, movie, sheet)
    index["contact_sheet"] = {"path": f"res://{native_rel}/{sheet.name}", "sha256": digest(sheet),
                              "columns": 5, "phase_samples": "RECEIPT_TIMED_REAL_MAPBATTLE_ONLY"}
    index["owner_approval"] = "PENDING"
    index["pve"] = "HOLD"
    index_path.write_text(json.dumps(index, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    event_types: set[str] = set()
    for row in rows:
        entry = by_id[row["skill_id"]]
        count = int(row.get("accepted_event_count", 0))
        for event in row.get("event_types", []):
            event_types.add(str(event))
        entry["native_status"] = TECH_PASS
        entry["native_ready"] = False
        entry["native_event_count"] = count
        entry["native_accepted_event_count"] = count
        entry["native_synthetic_event_count"] = 0
        entry["native_index"] = f"res://{native_rel}/{index_path.name}"
        entry["native_contact_sheet"] = f"res://{native_rel}/{sheet.name}"
        entry["native_video"] = f"res://{native_rel}/{movie.name}"
        entry["native_event_status"] = f"REAL_MAPBATTLE_V2_FIXTURE; ACCEPTED={count}; SYNTHETIC=0; EVENTS={','.join(row.get('event_types', []))}"
        entry["review_note"] = entry.get("review_note", "").split(" Native 1280x720/20 FPS H.264 capture passed")[0]
        entry["review_note"] += (f" Native 1280×720/20 FPS H.264 capture passed full decode; {count} real candidate event(s) accepted, "
                                 "with zero synthetic events. Receipt-timed phase samples and contact sheet are linked; "
                                 "owner visual review remains pending; PvE HOLD.")
        paths = entry.setdefault("source_paths", [])
        for path in (f"{native_rel}/{index_path.name}", f"{native_rel}/{sheet.name}", f"{native_rel}/{movie.name}"):
            if path not in paths:
                paths.append(path)
        for skill_row in manifest.get("skills", []):
            if skill_row.get("skill_id") == row["skill_id"]:
                skill_row["native_status"] = TECH_PASS
                skill_row["accepted_events"] = count
                skill_row["source_paths"] = sorted(set(skill_row.get("source_paths", [])) | set(paths[-3:]))

    receipt_status = (f"REAL_MAPBATTLE_V2_FIXTURE_CAPTURE; SKILLS={len(rows)}; ACCEPTED_EVENTS={accepted}; "
                      f"SETUP_RECEIPTS={setup}_SEPARATE; SYNTHETIC=0; EVENTS={','.join(sorted(event_types))}")
    batch_info.update({"expected_count": len(rows), "technical_status": TECH_PASS,
                       "last_capture_index": f"res://{native_rel}/{index_path.name}",
                       "video": f"res://{native_rel}/{movie.name}",
                       "contact_sheet": f"res://{native_rel}/{sheet.name}",
                       "receipt_status": receipt_status,
                       "visual_review_status": "RECEIPT_TIMED_CHARGE_RELEASE_CONTACT_AND_STATUS_PHASE_SAMPLES_CAPTURED; ART_SELF_REVIEW_PENDING",
                       "owner_approval": "PENDING", "pve": "HOLD"})
    batch_id = str(config.get("batch", ""))
    registry.setdefault("batch_status", {}).setdefault(batch_id, {})["native_import_capture"] = (
        f"{TECH_PASS}; SKILLS={len(rows)}; ACCEPTED_EVENTS={accepted}; SETUP_RECEIPTS={setup}_SEPARATE; "
        "SYNTHETIC=0; OWNER=PENDING; PVE=HOLD")
    registry_path.write_text(json.dumps(registry, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    ids = set(by_id)
    paths = [f"{native_rel}/{index_path.name}", f"{native_rel}/{sheet.name}", f"{native_rel}/{movie.name}"]
    for row in web.get("entries", []):
        if row.get("id") not in ids:
            continue
        source_paths = row.setdefault("source_paths", [])
        for path in paths:
            if path not in source_paths:
                source_paths.append(path)
        row["review_note"] = str(row.get("review_note", "")).split(" Native candidate-event capture:")[0]
        row["review_note"] += (f" Native candidate-event capture: {len(rows)} skills / {accepted} accepted MapBattle events / "
                               f"{setup} separate fixture setup receipts / zero synthetic events; full H.264 decode PASS. "
                               "Owner visual review pending; PvE HOLD.")
    web_path.write_text(json.dumps(web, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    manifest["status"] = "CANDIDATE; NATIVE_TECH_PASS; OWNER_PENDING; PVE_HOLD"
    manifest["native_capture"] = {"technical_status": TECH_PASS, "skills": len(rows),
                                  "accepted_candidate_events": accepted, "fixture_setup_receipts": setup,
                                  "synthetic_candidate_events": 0, "video": f"review/native/{movie.name}",
                                  "video_sha256": digest(movie), "contact_sheet": f"review/native/{sheet.name}",
                                  "contact_sheet_sha256": digest(sheet), "index": f"review/native/{index_path.name}",
                                  "owner_approval": "PENDING", "pve": "HOLD"}
    manifest["visual_review_status"] = "NATIVE_PHASE_SAMPLES_CAPTURED; ART_SELF_REVIEW_PENDING"
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"VFX_FACTORY_NATIVE_PASS school={school} skills={len(rows)} accepted={accepted} setup={setup} synthetic=0 "
          f"duration={stream_data.get('format', {}).get('duration')} video={movie} sheet={sheet}")


if __name__ == "__main__":
    main()
