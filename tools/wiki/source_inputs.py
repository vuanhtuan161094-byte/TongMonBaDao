"""Verified path-scoped source helpers for Wiki V2 projections."""
from __future__ import annotations

import re
import subprocess
from pathlib import Path

V2_FIXED_SOURCE_PATHS = (
    "godot/src/simulation/combat/v63_feature_gates.gd",
    "godot/data/combat/v63_content_registry.json",
    "godot/data/presentation/v63_combat_vfx_manifest.json",
    "godot/data/presentation/v63_skill_presentation_manifest_v1.json",
    "docs/animation/TMB_DISCIPLE_ANIMATION_COVERAGE_20261111.md",
    "docs/animation/AS_CHAR49_V10_23OF24_CANDIDATE_20261116.md",
    "docs/animation/AS_CHAR49_V8_OWNER_APPROVED_ATTACK_4DIR_EXPORT_20261116.md",
    "docs/animation/AS_CHAR49_V9_CAST_HIT_FOUR_DIRECTION_EXPORT_20261116.md",
    "docs/animation/TMB_DISCIPLE_MASTER_BATCH_ORDER_20261117.md",
    "docs/animation/TMB_DISCIPLE_WEAPON_LANGUAGE_GUIDE_20261117.md",
    "docs/animation/TMB_DISCIPLE_SCHOOL_IDENTITY_BIBLE_20261117.md",
    "docs/handoffs/AS_CHAR49_V9_DEATH_SOURCE_NEXT_CHAT_HANDOFF_20261116.md",
    "docs/handoffs/VFX_CURRENT_ART_FIRST_NEXT_CHAT_20261114.md",
    "docs/operations/VFX_FIST12_R10C_NATIVE_ART_REVIEW_20261117.md",
    "docs/operations/VFX_FIST12_R10C_OWNER_PROVISIONAL_LOCK_AND_FIST14_START_20261117.md",
    "docs/operations/VFX_POI20_XA_ANH_R1_20261117.md",
)

def latest_commit(root: Path, paths: tuple[str, ...] | list[str]) -> str:
    available = sorted({path for path in paths if path and (root / path).exists()})
    if not available:
        return "UNKNOWN"
    try:
        value = subprocess.check_output(
            ["git", "log", "-1", "--format=%H", "--", *available],
            cwd=root, text=True, stderr=subprocess.DEVNULL
        ).strip()
        return value.lower() if re.fullmatch(r"[0-9a-fA-F]{40}", value) else "UNKNOWN"
    except (OSError, subprocess.CalledProcessError):
        return "UNKNOWN"
