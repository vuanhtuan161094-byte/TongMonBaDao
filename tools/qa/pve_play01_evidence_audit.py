#!/usr/bin/env python3
"""Read-only PVE-PLAY-01 GUI performance evidence audit (standard library only).

Never labels a game PLAYABLE_PASS: profiler, physical mouse interaction,
Save/Reload, and video evidence cannot be established from FPS logs alone.
"""
import argparse
import json
import math
from pathlib import Path

REQUIRED_SEGMENTS = (("production", 15.0), ("pve", 30.0), ("save_return", 10.0))


def percentile(values, pct):
    if not values:
        return None
    ordered = sorted(values)
    position = (len(ordered) - 1) * pct
    lo = math.floor(position)
    hi = math.ceil(position)
    return round(ordered[lo] + (ordered[hi] - ordered[lo]) * (position - lo), 3)


def audit(path):
    windows, raw_frames, reported_spikes, errors = [], [], [], []
    for line_no, line in enumerate(Path(path).read_text(encoding="utf-8-sig").splitlines(), 1):
        if not line.strip():
            continue
        try:
            item = json.loads(line)
            if not isinstance(item, dict):
                raise ValueError("not an object")
            kind = item.get("kind")
            if kind == "sample":
                phase = str(item.get("phase", "unknown"))
                # Schema 2 emits elapsed_s; legacy schema 1 emits seconds.
                duration = float(item.get("elapsed_s", item.get("seconds", 0)))
                if not math.isfinite(duration) or duration < 0:
                    raise ValueError("invalid seconds")
                windows.append({"line": line_no, "phase": phase, "seconds": duration,
                                "max_ms": number(item.get("frame_ms_max")),
                                "p95_ms": number(item.get("frame_ms_p95")),
                                "p99_ms": number(item.get("frame_ms_p99")),
                                "one_pct_low_fps": number(item.get("fps_1pct_low")),
                                "process_ms": number(item.get("process_ms"))})
                if "frame_ms_samples" in item:
                    for frame in item["frame_ms_samples"]:
                        raw_frames.append((phase, positive_frame(frame)))
                # Schema 2 exposes its top actual frame rows, not every frame.
                # They are valid point observations but cannot reconstruct global p99.
                for spike in item.get("top_spikes", []):
                    if not isinstance(spike, dict):
                        raise ValueError("invalid top_spikes entry")
                    reported_spikes.append({
                        "line": line_no, "phase": phase,
                        "frame_ms": positive_frame(spike.get("frame_ms")),
                        "elapsed_s": number(spike.get("elapsed_s")),
                        "process_ms": number(spike.get("godot_process_ms")),
                        "physics_ms": number(spike.get("godot_physics_ms")),
                    })
            elif kind == "frame":
                raw_frames.append((str(item.get("phase", "unknown")), positive_frame(item.get("frame_ms"))))
        except (ValueError, TypeError, json.JSONDecodeError) as exc:
            errors.append(f"line {line_no}: {exc}")

    segments = []
    pve_seen = False
    for window in windows:
        raw_phase = window["phase"]
        if raw_phase in ("pve", "pve_active", "pve_save"):
            pve_seen = True
        # Legacy sect windows become return-phase after the first PvE window.
        phase = ("save_return" if pve_seen else "production") if raw_phase == "sect" else raw_phase
        if phase == "pve_active":
            phase = "pve"
        if segments and segments[-1]["phase"] == phase:
            segments[-1]["seconds"] += window["seconds"]
            segments[-1]["windows"] += 1
        else:
            segments.append({"phase": phase, "seconds": window["seconds"], "windows": 1})
    cursor = 0
    coverage = []
    for phase, minimum in REQUIRED_SEGMENTS:
        while cursor < len(segments) and segments[cursor]["phase"] != phase:
            cursor += 1
        good = cursor < len(segments) and segments[cursor]["seconds"] >= minimum
        coverage.append({"phase": phase, "minimum_seconds": minimum, "estimated_met": good,
                         "observed_seconds": round(segments[cursor]["seconds"], 2) if cursor < len(segments) else 0})
        cursor += 1

    per_phase = {}
    for phase in sorted(set(w["phase"] for w in windows)):
        part = [w for w in windows if w["phase"] == phase]
        vals = lambda key: [w[key] for w in part if w[key] is not None]
        per_phase[phase] = {"windows": len(part), "approx_seconds": round(sum(w["seconds"] for w in part), 2),
                            "worst_window_p95_ms": max(vals("p95_ms"), default=None),
                            "worst_window_p99_ms": max(vals("p99_ms"), default=None),
                            "worst_window_max_ms": max(vals("max_ms"), default=None),
                            "window_1pct_low_available": len(vals("one_pct_low_fps")) == len(part)}
    raw = {}
    for phase in sorted(set(p for p, _ in raw_frames)):
        ms = [f for p, f in raw_frames if p == phase]
        count = max(1, math.ceil(len(ms) * 0.01))
        slowest = sorted(ms, reverse=True)[:count]
        raw[phase] = {"frames": len(ms), "p50_ms": percentile(ms, 0.50), "p95_ms": percentile(ms, 0.95),
                      "p99_ms": percentile(ms, 0.99),
                      "one_pct_low_fps": round(1000.0 / (sum(slowest) / count), 2),
                      "max_ms": max(ms), "over_33ms": sum(x > 33.3 for x in ms),
                      "over_50ms": sum(x > 50 for x in ms), "over_100ms": sum(x > 100 for x in ms)}

    top = sorted((w for w in windows if w["max_ms"] is not None),
                 key=lambda w: w["max_ms"], reverse=True)[:5]
    top_frame_spikes = sorted(reported_spikes,
                              key=lambda x: x["frame_ms"], reverse=True)[:5]
    flags = []
    if errors:
        flags.append("INVALID_JSONL_OR_VALUES")
    if not windows:
        flags.append("NO_GUI_SAMPLE_WINDOWS")
    if not all(c["estimated_met"] for c in coverage):
        flags.append("MISSING_REQUIRED_PHASE_COVERAGE_APPROX")
    if not raw:
        flags.append("NO_RAW_FRAMES_GLOBAL_P99_1PCT_LOW_UNPROVABLE")
    if windows and any(w["p99_ms"] is None or w["one_pct_low_fps"] is None for w in windows):
        flags.append("WINDOW_P99_OR_1PCT_LOW_MISSING")
    if any(w["max_ms"] is not None and w["max_ms"] > 100 for w in windows) or any(
            x["frame_ms"] > 100 for x in reported_spikes):
        flags.append("SEVERE_SPIKE_OVER_100MS")
    if any(x["p95_ms"] > 33.3 or x["over_100ms"] for x in raw.values()):
        flags.append("RAW_FRAME_PERFORMANCE_OUT_OF_TARGET")
    flags.append("PHYSICAL_MOUSE_PROFILER_SAVE_RELOAD_AND_VIDEO_NOT_VERIFIED_BY_LOG")
    return {"status": "PLAYABLE_UNVERIFIED", "source_file": str(path),
            "phase_windows_are_approximations": True,
            "global_percentiles_require_raw_frame_samples": True,
            "coverage": coverage, "segments": segments, "by_phase_windows": per_phase,
            "by_phase_raw_frames": raw,
            "top_window_spikes": [{"line": w["line"], "phase": w["phase"],
                                    "max_ms": w["max_ms"], "process_ms": w["process_ms"]} for w in top],
            "top_actual_frame_spikes": top_frame_spikes,
            "flags": flags, "parse_errors": errors}


def number(value):
    if value is None:
        return None
    n = float(value)
    if not math.isfinite(n) or n < 0:
        raise ValueError("invalid metric")
    return n


def positive_frame(value):
    n = number(value)
    if n is None or n <= 0:
        raise ValueError("invalid frame_ms")
    return n


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("jsonl", type=Path)
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()
    report = audit(args.jsonl)
    rendered = json.dumps(report, ensure_ascii=False, indent=2)
    print(rendered)
    if args.out:
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(rendered + "\n", encoding="utf-8")
    return 2 if "INVALID_JSONL_OR_VALUES" in report["flags"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
