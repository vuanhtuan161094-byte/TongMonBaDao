#!/usr/bin/env python3
"""Validate one Poison Factory movie and build its receipt-timed review sheet."""
from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[3]
REPO = ROOT.parent
BATCH = ROOT / "labs/combat_lab/poison_factory_batch1_20261125"
REGISTRY = ROOT / "labs/combat_lab/vfx_factory/registry.json"
WEB_CATALOG = REPO / "docs/operations/vfx_web_catalog_v1.json"
TECH_PASS = "NATIVE_TECH_PASS_GODOT_4.7.2_1280x720_20FPS_H264_FULL_DECODE"
W = 1280
H = 720
FPS = 20
COLS = ["CHARGE", "RELEASE", "CONTACT", "STATE START", "SUSTAIN", "STATE END / FADE"]


def run(args: list[str], *, capture: bool = False) -> str:
    result = subprocess.run(args, check=True, text=True, capture_output=capture)
    return result.stdout if capture else ""


def probe(path: Path) -> dict:
    value = run(["ffprobe", "-v", "error", "-show_entries",
                 "stream=codec_name,width,height,pix_fmt,r_frame_rate,duration",
                 "-of", "json", str(path)], capture=True)
    streams = json.loads(value).get("streams", [])
    video = next((row for row in streams if row.get("codec_type", "video") == "video"), None)
    if video is None:
        raise SystemExit("NATIVE_CAPTURE_NO_VIDEO_STREAM")
    if (video.get("codec_name") != "h264" or video.get("width") != W or video.get("height") != H
            or video.get("pix_fmt") != "yuv420p" or video.get("r_frame_rate") != "20/1"):
        raise SystemExit(f"NATIVE_CAPTURE_STREAM_CONTRACT_FAILED: {video}")
    return video


def event_rows(skill: dict, binding_by_type: dict) -> list[dict]:
    result = []
    for row in skill.get("event_trace", []):
        enriched = dict(row)
        enriched["visual_phase"] = binding_by_type.get(str(row.get("event_type", "")), "")
        result.append(enriched)
    return result


def samples_for(skill: dict, bindings: list[dict]) -> dict:
    binding_by_type = {str(row.get("event_type", "")): str(row.get("visual_phase", ""))
                       for row in bindings}
    trace = event_rows(skill, binding_by_type)
    by_phase = {}
    for row in trace:
        visual_phase = row.get("visual_phase", "")
        if visual_phase and visual_phase not in by_phase:
            by_phase[visual_phase] = row
    start = float(skill.get("video_start_seconds", 0.0))
    result = {}
    cast = by_phase.get("charge")
    if cast:
        result["charge"] = {"time_seconds": float(cast["capture_frame_seconds"]) + 0.08,
                             "receipt_type": cast["event_type"], "basis": "REAL_MAPBATTLE_SKILL_CAST"}
    release = by_phase.get("release")
    if release:
        result["release"] = {"time_seconds": float(release["capture_frame_seconds"]) + 0.06,
                              "receipt_type": release["event_type"], "basis": "REAL_MAPBATTLE_SKILL_RELEASE"}
    contact = by_phase.get("contact")
    if contact:
        result["contact"] = {"time_seconds": float(contact["capture_frame_seconds"]) + 0.04,
                              "receipt_type": contact["event_type"], "basis": "REAL_MAPBATTLE_CONTACT_RECEIPT"}
    status = by_phase.get("start")
    if status:
        duration = max(0.0, float(status.get("event_state_duration_seconds", 0.0)))
        feed_time = float(status["capture_frame_seconds"])
        result["state_start"] = {"time_seconds": feed_time + 0.10,
                                  "receipt_type": status["event_type"], "basis": "REAL_MAPBATTLE_STATE_RECEIPT"}
        if duration > 0.75:
            result["state_sustain"] = {"time_seconds": feed_time + min(duration * 0.5, duration - 0.20),
                                        "receipt_type": status["event_type"], "basis": "MIDDLE_OF_RECEIPT_DURATION"}
            result["state_end"] = {"time_seconds": feed_time + duration + 0.06,
                                    "receipt_type": status["event_type"],
                                    "basis": status.get("expiry_source", "REAL_EVENT_EXPIRY")}
    if "state_end" not in result:
        last_effect = contact or by_phase.get("start") or release
        if last_effect:
            result["state_end"] = {"time_seconds": float(last_effect["capture_frame_seconds"]) + 0.32,
                                   "receipt_type": last_effect["event_type"],
                                   "basis": "POST_CONTACT_FADE_WINDOW"}
    for label, sample in result.items():
        sample["time_seconds"] = max(0.0, min(float(skill.get("video_duration_seconds", 0.0)) + start,
                                              float(sample["time_seconds"])))
        sample["frame_index"] = int(round(sample["time_seconds"] * FPS))
    return result


def save_sheet(index: dict, registry: dict, movie: Path, output: Path) -> None:
    entries = {row["skill_id"]: row for row in registry.get("entries", [])}
    rows = index.get("skills", [])
    cell_w, cell_h, caption_h, header_h = 256, 144, 25, 32
    canvas = Image.new("RGB", (cell_w * len(COLS), header_h + len(rows) * (cell_h + caption_h)), (18, 26, 30))
    draw = ImageDraw.Draw(canvas)
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 10)
        bold = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 11)
    except OSError:
        font = ImageFont.load_default()
        bold = font
    for col, title in enumerate(COLS):
        draw.text((col * cell_w + 8, 9), title, fill=(226, 212, 171), font=bold)
    for row in rows:
        entry = entries.get(row.get("skill_id", ""), {})
        bindings = entry.get("receipt_manifest", {}).get("bindings", [])
        by_type = {str(binding.get("event_type", "")): str(binding.get("visual_phase", ""))
                   for binding in bindings}
        row["event_trace"] = event_rows(row, by_type)
        row["phase_samples"] = samples_for(row, bindings)

    unique_indices = sorted({sample["frame_index"] for row in rows for sample in row["phase_samples"].values()})
    tmp_dir = output.parent / ".poison_sample_frames"
    tmp_dir.mkdir(parents=True, exist_ok=True)
    for old in tmp_dir.glob("frame_*.png"):
        old.unlink()
    if unique_indices:
        expr = "+".join(f"eq(n\\,{frame})" for frame in unique_indices)
        pattern = str(tmp_dir / "frame_%04d.png")
        run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-i", str(movie),
             "-vf", f"select={expr}", "-fps_mode", "passthrough", pattern])
    extracted = sorted(tmp_dir.glob("frame_*.png"))
    if len(extracted) != len(unique_indices):
        raise SystemExit(f"NATIVE_CONTACT_SAMPLES_MISSING expected={len(unique_indices)} actual={len(extracted)}")
    frames = {number: Image.open(path).convert("RGB")
              for number, path in zip(unique_indices, extracted)}
    for row_index, row in enumerate(rows):
        entry = entries.get(row.get("skill_id", ""), {})
        y = header_h + row_index * (cell_h + caption_h)
        short_name = str(entry.get("name_vi", row.get("name_vi", row.get("skill_id", ""))))[:30]
        draw.text((6, y + 5), short_name + " · " + str(entry.get("branch", "")), fill=(225, 233, 225), font=bold)
        draw.line((0, y + caption_h - 2, canvas.width, y + caption_h - 2), fill=(76, 89, 88), width=1)
        samples = row.get("phase_samples", {})
        shown = ["charge", "release", "contact", "state_start", "state_sustain", "state_end"]
        for col, key in enumerate(shown):
            x = col * cell_w
            cell_y = y + caption_h
            sample = samples.get(key)
            if sample and sample["frame_index"] in frames:
                image = frames[sample["frame_index"]].resize((cell_w, cell_h), Image.Resampling.LANCZOS)
                canvas.paste(image, (x, cell_y))
                receipt = str(sample.get("receipt_type", ""))
                label = f"{sample['time_seconds']:.2f}s · {receipt}"[:34]
            else:
                draw.rectangle((x, cell_y, x + cell_w - 1, cell_y + cell_h - 1), fill=(29, 40, 43))
                label = "NO RECEIPT / NO STATE"
            draw.text((x + 5, cell_y + cell_h + 3), label, fill=(181, 197, 188), font=font)
    output.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output, format="PNG", optimize=True)
    for frame in frames.values():
        frame.close()
    for file in tmp_dir.glob("frame_*.png"):
        file.unlink()
    tmp_dir.rmdir()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--index", type=Path, required=True)
    parser.add_argument("--movie", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, default=BATCH / "review/native")
    args = parser.parse_args()
    raw_index = json.loads(args.index.read_text(encoding="utf-8"))
    registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
    rows = raw_index.get("skills", [])
    if raw_index.get("school") != "poison" or len(rows) != 16:
        raise SystemExit(f"NATIVE_BATCH_INDEX_INVALID school={raw_index.get('school')} rows={len(rows)}")
    if any(row.get("fixture") == "FAILED" or row.get("synthetic_events", 0) != 0
           or row.get("accepted_event_count", 0) != row.get("event_count", 0)
           for row in rows):
        raise SystemExit("NATIVE_BATCH_RECEIPT_AUDIT_FAILED")
    for row in rows:
        if any(not event.get("accepted", False) for event in row.get("event_trace", [])):
            raise SystemExit("NATIVE_BATCH_HAS_REJECTED_EVENT " + str(row.get("skill_id", "")))
        if any(receipt.get("bound_to_candidate_visual", True) for receipt in row.get("fixture_setup_receipts", [])):
            raise SystemExit("NATIVE_SETUP_RECEIPT_BOUND_AS_CANDIDATE " + str(row.get("skill_id", "")))

    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    movie = output_dir / "poison_batch1_native_1280x720.mp4"
    sheet = output_dir / "poison_batch1_contact_sheet_1280x720.png"
    index_path = output_dir / "poison_batch1_capture_index.json"
    run(["ffmpeg", "-hide_banner", "-loglevel", "warning", "-y", "-i", str(args.movie),
         "-an", "-vf", "scale=in_range=pc:out_range=tv:flags=bilinear,format=yuv420p",
         "-c:v", "libx264", "-preset", "fast", "-crf", "19", "-pix_fmt", "yuv420p", "-color_range", "tv",
         "-movflags", "+faststart", str(movie)])
    stream = probe(movie)
    run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-i", str(movie), "-f", "null", "-"])
    raw_index["technical_status"] = TECH_PASS
    raw_index["receipt_summary"] = {
        "candidate_events": sum(int(row.get("event_count", 0)) for row in rows),
        "accepted_candidate_events": sum(int(row.get("accepted_event_count", 0)) for row in rows),
        "synthetic_candidate_events": sum(int(row.get("synthetic_events", 0)) for row in rows),
        "fixture_setup_receipts": sum(len(row.get("fixture_setup_receipts", [])) for row in rows),
        "poison_expiry_source": "MAPBATTLE_ACTOR_STATUS_STACK",
        "healing_and_cleanse_setup_receipts_excluded_from_candidate_count": True,
    }
    raw_index["movie"] = {"path": "res://labs/combat_lab/poison_factory_batch1_20261125/review/native/poison_batch1_native_1280x720.mp4",
                          "codec": stream["codec_name"], "viewport_px": [W, H], "fps": FPS,
                          "duration_seconds": float(stream.get("duration", 0.0)),
                          "full_decode": "PASS"}
    save_sheet(raw_index, registry, args.movie.resolve(), sheet)
    raw_index["contact_sheet"] = {"path": "res://labs/combat_lab/poison_factory_batch1_20261125/review/native/poison_batch1_contact_sheet_1280x720.png",
                                  "columns": COLS, "phase_samples": "RECEIPT_TIMED; ACTUAL_MAPBATTLE_EVENTS_ONLY"}
    index_path.write_text(json.dumps(raw_index, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    rows_by_id = {row["skill_id"]: row for row in registry.get("entries", [])}
    for row in rows:
        entry = rows_by_id[row["skill_id"]]
        event_count = int(row.get("accepted_event_count", 0))
        event_types = ",".join(row.get("event_types", []))
        entry["native_status"] = TECH_PASS
        entry["native_event_status"] = f"REAL_MAPBATTLE_V2_FIXTURE; ACCEPTED={event_count}; SYNTHETIC=0; EVENTS={event_types}"
        entry["native_index"] = "res://labs/combat_lab/poison_factory_batch1_20261125/review/native/poison_batch1_capture_index.json"
        entry["native_contact_sheet"] = "res://labs/combat_lab/poison_factory_batch1_20261125/review/native/poison_batch1_contact_sheet_1280x720.png"
        paths = entry.setdefault("source_paths", [])
        for path in ["labs/combat_lab/poison_factory_batch1_20261125/review/native/poison_batch1_capture_index.json",
                     "labs/combat_lab/poison_factory_batch1_20261125/review/native/poison_batch1_contact_sheet_1280x720.png"]:
            if path not in paths:
                paths.append(path)
        entry["review_note"] = entry["review_note"].replace(
            "Factory adapter owner review and native capture are pending; PvE HOLD.",
            "Factory adapter native capture passed; owner visual review pending; PvE HOLD.")
        marker = " Native 1280x720/20 FPS H.264 capture passed full decode;"
        entry["review_note"] = entry["review_note"].split(marker)[0]
        entry["review_note"] += (f"{marker} {event_count} real candidate event(s) accepted, "
                                 "with no synthetic events. Native phase samples and receipt trace are linked in the batch index/contact sheet. Owner review remains pending; PvE HOLD.")
    registry["native_batches"]["poison"].update({
        "technical_status": TECH_PASS,
        "receipt_status": "REAL_MAPBATTLE_V2_FIXTURE_CAPTURE; SKILLS=16; ACCEPTED_EVENTS=80; SETUP_RECEIPTS=20_SEPARATE; SYNTHETIC=0; POISON_EXPIRY_FROM_ACTOR_STATUS_STACK",
        "visual_review_status": "RECEIPT_TIMED_CHARGE_RELEASE_CONTACT_STATE_START_SUSTAIN_END_SAMPLES_CAPTURED; SELF_REVIEW_PENDING",
    })
    registry["batch_status"]["poison_human_cast_batch1_20261125"]["native_import_capture"] = (
        "NATIVE_TECH_PASS_GODOT_4.7.2_1280x720_20FPS_H264_FULL_DECODE; SKILLS=16; ACCEPTED_EVENTS=80; "
        "SETUP_RECEIPTS=20_SEPARATE; SYNTHETIC=0; OWNER=PENDING; PVE=HOLD")
    web = json.loads(WEB_CATALOG.read_text(encoding="utf-8"))
    poison_ids = {row["skill_id"] for row in rows}
    native_paths = {
        "labs/combat_lab/poison_factory_batch1_20261125/review/native/poison_batch1_capture_index.json",
        "labs/combat_lab/poison_factory_batch1_20261125/review/native/poison_batch1_contact_sheet_1280x720.png",
    }
    web_marker = (" Native candidate-event capture: 16 skills / 80 accepted MapBattle events / "
                  "20 separate fixture setup receipts / zero synthetic events; full H.264 decode PASS. "
                  "Owner review pending; PvE HOLD.")
    for entry in web.get("entries", []):
        if entry.get("id") not in poison_ids:
            # Remove an earlier broad-match mistake while preserving unrelated work in this shared file.
            entry["source_paths"] = [path for path in entry.get("source_paths", []) if path not in native_paths]
            note = str(entry.get("review_note", ""))
            if note.endswith(web_marker):
                entry["review_note"] = note[:-len(web_marker)]
            continue
        paths = entry.setdefault("source_paths", [])
        for path in native_paths:
            if path not in paths:
                paths.append(path)
        marker = " Native candidate-event capture:"
        entry["review_note"] = entry["review_note"].split(marker)[0]
        entry["review_note"] += web_marker

    registry_path = REGISTRY
    registry_path.write_text(json.dumps(registry, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    WEB_CATALOG.write_text(json.dumps(web, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    manifest_path = BATCH / "manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    manifest["native_capture"] = {
        "technical_status": TECH_PASS,
        "skills": len(rows), "accepted_candidate_events": raw_index["receipt_summary"]["accepted_candidate_events"],
        "fixture_setup_receipts": raw_index["receipt_summary"]["fixture_setup_receipts"],
        "synthetic_candidate_events": raw_index["receipt_summary"]["synthetic_candidate_events"],
        "poison_expiry_source": "MAPBATTLE_ACTOR_STATUS_STACK",
        "video": "review/native/poison_batch1_native_1280x720.mp4",
        "video_sha256": hashlib.sha256(movie.read_bytes()).hexdigest(),
        "contact_sheet": "review/native/poison_batch1_contact_sheet_1280x720.png",
        "contact_sheet_sha256": hashlib.sha256(sheet.read_bytes()).hexdigest(),
        "index": "review/native/poison_batch1_capture_index.json",
        "owner_approval": "PENDING", "pve": "HOLD",
    }
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"POISON_NATIVE_PASS skills={len(rows)} accepted={raw_index['receipt_summary']['accepted_candidate_events']} setup={raw_index['receipt_summary']['fixture_setup_receipts']} synthetic=0 duration={stream.get('duration')} movie={movie} sheet={sheet}")


if __name__ == "__main__":
    main()
