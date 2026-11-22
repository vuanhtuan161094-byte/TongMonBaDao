# FIST14 R11 — Owner-approved GIF → isolated Godot review LAB

## Owner approval boundary

The user approved **the FIST14 R11 GIF on 2026-11-21**, not a Godot/native/Android capture, not PvE integration and not a new character style. The byte-identical original approved **16-frame GIF** is preserved at `source/FIST14_R11_ORIGINAL_OWNER_GIF.gif` (SHA-256 `49ca2af9db90803a071fe629481be476cd15539b9a033eb3df3cfd6eb29b12dc`). All alpha sprites are *derived* from that exact source, via `tools/vfx/build_fist14_r11_alpha_source.py`; no animation source was recreated.

## One Godot scene to run

`res://labs/combat_lab/fist14/r11_owner_review/fist14_r11_owner_review.tscn`

Open the scene **inside the canonical Tông Môn Bá Đạo Godot project**, preferably Godot **4.7.2** according to the project contract, canvas 1280×720. This is not a new standalone game. The scene is intentionally isolated from PvE, SaveService and Combat V2. No rigging.

Dependencies are **referenced read-only from the actual repository** and are not included in this package:

- `res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png` — **TEMPORARY on-screen scale stand-in, NOT a Quyền Tu actor** (the existing FIST14 LAB already uses this image). The canonical Quyền Tu character must later be selected by the character pipeline / owner.
- `res://assets/actors/v5_sa_monster_1113031_1/animations.tres` — real Godot monster WALK animation; do not replace with fake art or a single static monster.

Controls when running directly: **Space** replay, **P** pause, **B** light/dark backgrounds. Web review callable API supports replay, phase seek, speed, monster movement, FX visibility and size 1×/2×. Do **not** register this scene in `docs/operations/vfx_web_catalog_v1.json` before real Godot + browser pixel QA and owner native art check.

## Canonical skill contract (no game changes)

`SKILL_ID=tmb.skill.fist.huyet_quyen.active_04.human`, `effect=mark`, `element=nether`, `target_limit=1`, `cast=.45s`, `mark=6s`, `projectile_speed=0`. The visible short-range thrust and one three-stroke meridian mark are **synthetic LAB display only**. The mark is a *technical supplemental cue* not part of the approved R11 GIF; confirm that element later. No fake damage, hit counts, bleed, homing projectile or combat receipts.

## QA and hard stops

**Completed in source-only environment:** exact source SHA check, 16 distinct RGBA frames, transparent corners, 1× dark/light source contact sheet, Python source static tests. The new extracted-alpha result was not itself separately approved by the owner yet. **Cannot claim** Godot 4.7.2 parse/render, moving monster pixel proof, Chromium, mobile, exact-SHA Actions CI, correct Quyền Tu actor animation, or PvE; these require GitHub/engine access and actual QA.

Source may look less saturated on light maps after alpha extraction: **inspect native at 1×** before promoting. Never overwrite original approved R11 GIF or preexisting FIST14 R2–R6 source. **PR #72 Draft, no merge.**

## Files

- `source/FIST14_R11_ORIGINAL_OWNER_GIF.gif` — immutable original approval evidence.
- `assets/fist14_r11_rgba_atlas_4x4.png` — 4×4, 16 cels each 309×309.
- `source/provenance.json` — hashes, provenance and independent QA statuses.
- `review/fist14_r11_alpha_1x_dark_light.png` — source-only sample, **not screenshot of Godot**.
- `fist14_r11_owner_review.gd/tscn` — real Godot scene and controller.
- `tools/vfx/build_fist14_r11_alpha_source.py`, `tools/qa/test_fist14_r11_owner_source.py` — reproducible asset export and data QA from repository root.

## 21/11 Native QA-ready addendum (no claim of actual native pass)

- Canonical 16-pose source, original GIF SHA and RGBA atlas remain immutable.
- Added `docs/operations/vfx_packets/FIST14_R11_V4_PREFLIGHT.json` and the focused Godot contract test `godot/tests/labs/combat_lab/vfx_fist14_r11_owner_native_contract_test.gd`.
- Updated only LAB target movement amplitude (15→32 px) to expose moving-target follow; no gameplay effect changed.
- Reused `.github/workflows/vfx-shared-skill.yml` rather than introducing duplicate CI. After these files land on PR #72, dispatch this workflow with packet path `docs/operations/vfx_packets/FIST14_R11_V4_PREFLIGHT.json`, mode `g35`, duration `0` (or `full` 8 seconds for mark).
- The current local container has **no Godot executable and no repository actor/monster binaries**, therefore *native footage, browser pixel QA, actual Quyền Tu actor, CI SHA and deployment are still PENDING*. Do NOT upload to the `/vfx/` catalogue before proof.
- No code, art or status was pushed to GitHub from this preparation session.

## 22/11 GitHub Actions trigger (pending repository commit)

This source package includes `.github/workflows/vfx-fist14-r11-native-review.yml` as a **thin trigger only**. On a PR #72 branch push touching its FIST14 R11 paths (or where manual `workflow_dispatch` is supported), it delegates to the repository's existing, unmodified `vfx-shared-skill.yml`, passing the V4 packet and running G3.5 native. The shared runner owns Godot install, tests, movie, three phase snapshots and artifact upload. **No second Godot build pipeline is introduced.** GitHub's `workflow_dispatch` requires the workflow to exist on the default branch, so auto-trigger on PR #72 push is the primary method here; do not merge for convenience. Owner has not approved native, physical Android or PvE.

## GitHub source encoding / CI bake (22/11/2026)

The owner-approved GIF is stored on the feature branch as ASCII `source/FIST14_R11_ORIGINAL_OWNER_GIF.gif.b64` because the ChatGPT connector's repository Contents tool accepts only UTF-8, not arbitrary binary. This is a byte-exact reversible encoding (SHA-256 verified before baking), not a new drawing. `python3 tools/vfx/build_fist14_r11_alpha_source.py` restores the original GIF and generates all PNG files for scene and V4 packet, before Godot import in the existing shared GitHub Actions runner. The original GIF is NEVER changed in-place. The decoded GIF and PNGs produced in CI are not themselves committed; they are reproducible from the Git-tracked source encoding. Native Godot and Chromium remain unverified until CI completes.
