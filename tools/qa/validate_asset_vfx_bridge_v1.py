#!/usr/bin/env python3
"""Offline, source-only Character↔VFX binding preflight. No gameplay/Godot changes."""
import argparse
import json
from pathlib import Path

DIRECTIONS = ("front", "right", "back", "left")
EVENT_TYPES = {"skill_cast", "hit", "v63_skill_hit", "status_applied", "status_removed", "downed"}
SOURCE_SLOTS = {"foot", "hand_r", "hand_l", "weapon_grip", "weapon_tip", "chest", "head", "body_center", "ground"}
TARGET_SLOTS = {"foot", "chest", "head", "body_center", "ground"}


def _point(value):
    return isinstance(value, list) and len(value) == 2 and all(type(n) in (int, float) and abs(n) < 100000 for n in value)


def validate(actor, vfx):
    errors = []
    if actor.get("schema") != "tmb.character_anchors.v1" or actor.get("source_kind") != "CHARACTER_ONLY":
        errors.append("actor_schema_or_source_kind")
    if vfx.get("schema") != "tmb.vfx_bindings.v1" or vfx.get("source_kind") != "VFX_ONLY":
        errors.append("vfx_schema_or_source_kind")
    if actor.get("source_status") not in ("SYNTHETIC_FIXTURE", "CANDIDATE", "OWNER_APPROVED"):
        errors.append("actor_status")
    if vfx.get("source_status") not in ("SYNTHETIC_FIXTURE", "SOURCE_PENDING", "G3_SOURCE_FAIL", "G3_SOURCE_SELF_PASS", "OWNER_APPROVED"):
        errors.append("vfx_status")
    if any(k in actor for k in ("vfx_asset", "vfx_key", "skill_id", "shader", "damage", "status_effect")):
        errors.append("actor_embeds_vfx_or_gameplay")
    if any(k in vfx for k in ("actor_asset", "actor_path", "actor_id", "animation_frames", "skeleton", "damage", "status_effect")):
        errors.append("vfx_embeds_actor_or_gameplay")
    if not _point(actor.get("canvas_px")) or not _point(actor.get("foot_px")):
        errors.append("invalid_actor_canvas_or_foot")
    if not isinstance(actor.get("asset_id"), str) or not actor["asset_id"]:
        errors.append("actor_asset_id")
    if not isinstance(vfx.get("skill_id"), str) or not vfx["skill_id"].startswith("tmb.skill."):
        errors.append("skill_id")
    clips = actor.get("clips", {})
    if not isinstance(clips, dict):
        errors.append("clips_not_object")
        clips = {}
    bindings = vfx.get("bindings", [])
    if not isinstance(bindings, list) or not bindings:
        errors.append("bindings_missing")
        bindings = []
    seen = set()
    for i, binding in enumerate(bindings):
        if not isinstance(binding, dict):
            errors.append(f"binding_{i}_not_object")
            continue
        event = binding.get("event_type")
        phase = binding.get("visual_phase")
        clip = binding.get("actor_clip")
        source = binding.get("caster_slot")
        target = binding.get("target_slot")
        if event not in EVENT_TYPES or not isinstance(phase, str) or not phase:
            errors.append(f"binding_{i}_event_or_phase")
        if not isinstance(clip, str) or not clip or source not in SOURCE_SLOTS or target not in TARGET_SLOTS:
            errors.append(f"binding_{i}_slot_or_clip")
            continue
        if (event, phase) in seen:
            errors.append(f"binding_{i}_duplicate_event_phase")
        seen.add((event, phase))
        direction_map = clips.get(clip, {})
        for direction in DIRECTIONS:
            frames = direction_map.get(direction, []) if isinstance(direction_map, dict) else []
            if not isinstance(frames, list) or not frames:
                errors.append(f"binding_{i}_missing_{clip}_{direction}")
                continue
            frame_ids = set()
            for frame in frames:
                if not isinstance(frame, dict) or type(frame.get("frame")) is not int or frame["frame"] < 0:
                    errors.append(f"binding_{i}_{direction}_invalid_frame")
                    continue
                if frame["frame"] in frame_ids:
                    errors.append(f"binding_{i}_{direction}_duplicate_frame")
                frame_ids.add(frame["frame"])
                anchors = frame.get("anchors", {})
                if not isinstance(anchors, dict) or not _point(anchors.get(source)):
                    errors.append(f"binding_{i}_{direction}_missing_{source}_at_{frame['frame']}")
    # Fixture anchors are intentionally NOT evidence of real painted or rigless clips.
    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("actor_json", type=Path)
    parser.add_argument("vfx_json", type=Path)
    args = parser.parse_args()
    try:
        actor = json.loads(args.actor_json.read_text(encoding="utf-8"))
        vfx = json.loads(args.vfx_json.read_text(encoding="utf-8"))
        errors = validate(actor, vfx)
    except (ValueError, OSError, TypeError, AttributeError) as exc:
        print("VISUAL_BRIDGE_V1_FAIL", str(exc))
        return 1
    if errors:
        print("VISUAL_BRIDGE_V1_FAIL", ",".join(errors))
        return 1
    print("VISUAL_BRIDGE_V1_CONTRACT_PASS (synthetic/data-only; NO art/Godot/PvE approval)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
