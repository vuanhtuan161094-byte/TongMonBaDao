# G1 — SOURCE A: MINING / FORESTRY / FIELD ACTION CLIPS (ART-ONLY PACKET)

**CURRENT OWNER DECISION 2026-10-18:** Superseded as a required-art work item. Work-action clips for mining/chopping/planting are **NOT REQUIRED for G1**. Keep this document as an archival proof packet only; do not execute steps below unless a new explicit owner decision authorizes art. Production timeline/status is the acceptance target. See [G1 acceptance plan](G1_ACCEPTANCE_MINIMAL_PLAN_2026-10-17.md).


**Status:** REQUIRED ART / NOT YET AVAILABLE. Does not authorize changing gameplay, source rights, converter logic or importing invented character sprites. Target: Godot 4.7.2, Android landscape 1280x720. Owner visual G1 acceptance still PENDING.

## Evidence from verified PR #20 assets (2026-10-17)

| Actor | Existing scene | Manifest clips actually present | Missing required work art |
|---|---|---|---|
| Female `1113028_1` | `res://assets/actors/1113028_1/actor.tscn` | `stand` 48 frames, `walk` 24 frames | mining/chopping/planting |
| Male `body_1120402` | `res://assets/actors/body_1120402/actor.tscn` | `stand` 48 frames, `walk` 24 frames | mining/chopping/planting |
| Male `body_1110201` | `res://assets/actors/body_1110201/actor.tscn` | `stand` 48 frames, `walk` 24 frames | mining/chopping/planting |

Clip lists are from each **committed** `asset.json` and matching `animations.tres`. No `mining`, `chop`, `plant`, `dig` or `attack` clips were found in these three imports. These are **not** evidence that the licensed raw Source A package lacks action animations; the raw art/Spine sources on owner Windows E: must be audited separately.

## Minimal authorized next art work (separate owner approval / Codex with E: runner)

1. Inspect the original *licensed* Source A `spine/` or corresponding original animations for these **three actor IDs first**. Use existing `E:\TongMonBaDaoWorkspace\04_Tools\SpineToGodot472` and converted Batch-01 `E:\TongMonBaDaoWorkspace\05_DauRa\Assets_Godot472` before writing new tools. No full archive-wide re-conversion.
2. Seek authentic **tool swing / mining**, **woodcutting**, **planting** source clips only if present, for **two visual directions (left/right via safe Godot flip)**; player explicitly does not require new up/down sheets. Prove start/contact/recovery motion and stable foot position; do not derive a `mining` clip by relabelling idle/walk.
3. If source animations exist: pilot **one actor/one clip** first, bake PNG/WebP atlas with same verified pipeline, compare RGBA frames with actual Spine runtime, manifest SHA256 for every imported file, test `AnimatedSprite2D` stand/walk/action, then expand to remaining actor(s) only when viable. Retain previous approved scenes and immutable provenance.
4. If source animations do **not** exist: report IDs and exact missing clip names; keep the current UI's canonical map work label and timer bar. New authored sprite animation requires separate art authorization and user acceptance; never claim it is Source A.
5. Interface rule: action clip may play only when its `SpriteFrames.has_animation(clip)` returns true. Work completion and inventory remain driven **only** by canonical `BuildingSystem`, `SimulationScheduler` and `WarehouseSystem`; character swing/frame/time may not change work rate, yield or One Active Job.

**Acceptance:** visually readable at zoom 1 at 1280x720; actor planted at foot anchor while working; no fake carry-cycle, no mandatory animations for collecting output; focused Godot 4.7.2 import, scene/action playback & 1 native screenshot; owner visually approves. No CI/FULL, no merge, no gameplay/save/economy changes. **Current work feedback is presentation-only**: visual cue + progress card + ledger confirms production even without new art.
