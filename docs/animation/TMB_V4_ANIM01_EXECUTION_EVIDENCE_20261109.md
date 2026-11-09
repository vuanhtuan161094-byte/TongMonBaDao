# TMB V4-ANIM-01 — Actual execution and blocked art gate (2026-11-09)

## Authoritative source and scope

- **PR:** #72, same branch `integration/pve-p0-playable-ui-20261103`, Draft; no new branch or merge.
- **Owner-approved Nữ Độc Tu identity SHA256:** `435f8969c3d89468ddbdec837a44365b212b58e01082728c3f21f2b08249c118`, four-view 1448×1086 source. Later unrelated purple-robed AI images are **REJECTED**, not a replacement.
- **Allowed changes here:** isolated QA source/workflow and documentation only. V3 assets, canonical combat/V6.3, gameplay/SaveService untouched.

## Production attempts — factual failure

1. Previously delivered 176 and 240-frame rasters had near-static Walk or mechanical warp seams; earlier QA had already marked such output FAIL_VISUAL. Do not ship.
2. Attempted new 8-frame front/side Walk from owner view assets. On actual non-Godot preview, **side** leg movement could be distinguished, while **front** remained insufficient and hand/robe seams were visible. Artist quality not accepted.
3. New focused QA was authored in `tools/art/v4_anim01_walk_motion_gate.py`. The candidate's quantified source SHA / front/side alpha-phase gates are:
   - `front`: **FAIL**, opposing-leg lower silhouette delta **0.048** (<0.10 requirement); head y drift 0 px, foot bottom drift 1 px, median foot x range 3 px. Readable front step is absent.
   - `side`: **TECHNICAL_PASS_ONLY**, opposing-leg delta **0.211**, foot bottom drift 0 px, foot x range 13 px. **This is not art approval** (rig seams and style consistency remain unresolved).
   - Overall: **REJECT_FOR_GAME**, no production atlas replace/commit.
4. One subsequent image-generation animation experiment produced wrong white/purple clothing and was REJECTED for owner identity mismatch. It must not be used as authentic Nữ Độc Tu V4.
5. `tools/art/tests/test_v4_anim01_walk_motion_gate.py` supplies static (negative) and truly articulated synthetic (positive) motion fixtures. `.github/workflows/tmb-v4-anim01-walk-gate.yml` validates the checker itself, not actual actor acceptance.

## Current acceptance matrix

| Gate | Status |
| --- | --- |
| Owner female MASTER identity | LOCKED / SHA verified on source |
| Independent authored hand/leg parts, including occluded geometry | NOT DONE to accepted quality |
| Side Walk, actual pixel motion | TECHNICAL_PASS_ONLY / ART_REJECTED |
| Front Walk, readable step | FAIL |
| No hitches/warp/joint seams | FAIL / needs actual redesign |
| 4 directions × 6 animation clips | NOT PRODUCED to approval |
| Exact-SHA Godot 4.7.2 official GUI MP4 | **NOT RUN** for rejected candidate |
| PR #72 runtime integration | NOT DONE intentionally |
| Owner visual acceptance | PENDING |

## Next authorized technical work

Only use the approved original MASTER. Create *actual* distinct lower-leg and arm key poses from separately authored pixel/2D layers (inpaint/repaint occluded joints; not a single whole-image warp). Validate front and side simultaneously with `v4_anim01_walk_motion_gate.py`, then inspect the loop at 60–75px at 1280×720. Only after visual acceptance is plausible, commit the approved asset binaries and run official Godot 4.7.2 import/GUI capture. Source to video availability must be confirmed; current ChatGPT-native image generation does **not** reliably hold the exact owner MASTER as an animated subject, and an unconnected third-party image-to-video route is not assumed.

**Do not describe PASS of the QA test workflow as PASS of the asset. Do not show rejected animation as the final pack.**
