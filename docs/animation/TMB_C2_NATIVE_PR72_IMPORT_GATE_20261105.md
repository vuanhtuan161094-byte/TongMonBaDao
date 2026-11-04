# C2 NATIVE ANIMATION — PR #72 presentation-only import gate (2026-11-05)

**Status: PREPARED / STATIC-QA ONLY / NOT INTEGRATED / NOT VISUAL-ACCEPTED.**

Repository: `vuanhtuan161094-byte/TongMonBaDao`. Active gameplay RC branch: `integration/pve-p0-playable-ui-20261103` (PR #72, Draft). Godot `4.7.2.stable.official`, landscape 1280x720. This is an isolated asset/presentation experiment, **not** a new gameplay RC or main-scene change.

## Source of truth and immutable inputs

User-supplied ChatGPT assets must first be transferred to the authorized workspace and verified; **they do not automatically exist on GitHub or E:**. Do not substitute the older Source A or AN03/AN04 labs for these videos.

| Actor | Source name | SHA-256 | Original video | Frames used by candidate atlas |
|---|---|---|---|---|
| Nữ Cung | `1000021569.mp4` | `d8fee09fb86dbbf4c04a054782af1c5a4fbd5a6142bca250dd2105072d828d16` | 448x672, 24 fps, 145 frames | Idle #0-35, Bow-pose #56-91 |
| Nữ Pháp | `1000021558.mp4` | Verify `manifest_native.json` upon actual transfer | 480x640, 24 fps, 145 frames | Idle #0-35, Cast-pose #72-107 |

Owner-provided `TMB_Animation_Native_C2.zip` has 2 immutable `source/*.mp4`, 16 original-resolution RGBA PNG atlas pages and `manifest_native.json`. Each selected clip is 36 *consecutive* frames at 24 fps. Frame cell is **448x672** or **480x640**; atlas pages are 3x3 cells (1344x2016 or 1440x1920). Never use 75x75 art as source. Keep MASTER byte-identical and hash-gated. Zoom only controls on-screen transform.

## Isolated pilot implementation contract

- Place user-provided C2 input, after SHA validation, under an **isolated** art-test directory; candidate target `godot/art_pilots/c2_native/`. Do not import it into production actor registry, PvE, Source A renderer, project main scene or user saves.
- `AnimatedSprite2D + SpriteFrames + AtlasTexture.region`; load **only the selected action** to avoid holding both full clips simultaneously. Bottom-center pivot, face/feet readable at 1280x720.
- On-screen character height: 75px at normal zoom, 450px at camera zoom 6x. Native height is still 640/672px. Test 1x, 2x, 4x, 6x in official engine; no atlas downsample.
- Split green-screen matte from legitimate green mage VFX; preserve owner masters and export corrected derivatives with hashes. Do **not** silently erase mage green magic.
- 24 fps for the selected 36-frame sequence. Do not fabricate Walk/Hit/Death/8-directions from the same footage or call `bow_pose` a proven combat Attack.

## Static inspection and technical findings (actual run, local container)

- Original `tools/verify_native.py`: **332 PASS** native atlas/source shape/hash/alpha checks.
- Extended `qa/run_static_qa.py`: **194 checks PASS**, no structural failures; eight 1280x720 **PIL-simulated previews** at 1/2/4/6x (these are NOT Godot GUI screenshots).
- Both candidate Idle loop seams fail preliminary visual-continuity threshold: final→first RGBA difference / median adjacent difference = **8.84x Archer**, **8.47x Mage**. **HOLD FOR LOOP REWORK.**
- Cung has visible residual bright green matte behind hair/body. Pháp has green magical VFX embedded in actor sprite. **HOLD FOR CHROMA/VFX SEPARATION AND OWNER REVIEW.**
- 16 pages collectively occupy **167.06 MiB uncompressed RGBA** if loaded together (not measured GPU VRAM). Per active 4-page clip: ~41.36 MiB Cung, ~42.20 MiB Pháp, excluding driver, mipmaps and other allocations. Loading only one action reduces simultaneous texture pressure but **Android draw timing, texture memory, stutter and real FPS are UNKNOWN**.
- Input zoom/rendering is preserved in a standalone preview script; no modifications were made to real gameplay. Viewer script and generated QA previews are in the separately delivered pilot package.

## Mandatory acceptance gates before production presentation binding

| Gate | Required proof | Status |
|---|---|---|
| P0 source integrity | SHA, RGBA frame dimensions, original 24 fps, atlas region, alpha presence | **STATIC PASS only** |
| P1 isolated Godot 4.7.2 import | Official binary version, import exit 0, GDScript parse, mouse/keyboard viewer, 1280x720 captures at zoom 1x/2x/4x/6x per actor | **NOT RUN / PENDING ENGINE** |
| P2 sprite production quality | Idle no snapping; genuine selected action; green matte clean; independent mage VFX; bottom-center pivot and no unintended feet sliding | **HOLD: verified visual defects** |
| P3 performance | Official Godot runtime measurements, load/switch churn, Android device checks, render accuracy on camera pan/zoom | **NOT RUN / ANDROID PENDING USER** |
| P4 game actor binding | Explicit separate owner approval, unique allowed presentation paths, exact current RC HEAD, rollback plan, Godot focused and affected regressions | **NOT AUTHORIZED YET** |
| P5 user visual acceptance | Owner chooses approved final actor and motion | **PENDING USER** |

## Strict non-interference

Do **not** modify `SimulationState`, `SectState`, `DiscipleState`, `SaveService`, combat/PvE, injury, loot, production, balance, authority clocks or source-asset selection in the running RC. No save migration, no branch split, no merge. Release-train PR #72 R2→R5 and Windows Intel GLES3 blocker remain independent; static C2 QA cannot unblock them. Do not rewrite `CURRENT_CHECKPOINT.md` while the release owner is actively updating it.

This file is the **preparation receipt**, not evidence of actual game integration or official Godot PASS.
