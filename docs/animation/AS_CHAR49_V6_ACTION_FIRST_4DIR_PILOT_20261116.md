# AS-CHAR-49 V6 — Nữ Kiếm Tu action-first four-view technical evidence (2026-11-16)

## Status: HONEST PARTIAL, NOT COMPLETE

- **7/24 real exported technical animation candidates**, **0/24 production owner-approved**, **17/24 missing**.
- Full self-contained ZIP: **`/TMB-Character-Art/AS_CHAR49_V6_ACTION_FIRST_7_CLIPS_CANDIDATE_20261116.zip`** in personal ChatGPT Library, **NOT in GitHub**.
- ZIP SHA256 **`28cac48a6c6c8bc2c6972ba9e897ff8d8d5a690024c96babe8b8a0077b44900a`**, 117 entries, ZIP CRC clean, ~23.5 MB.
- Source: novel **transparent 4×4 Idle sprite GRID** (four directions in separate rows, four real independently illustrated Idle cels per row), **not** a branded poster/contact sheet, and preserved original R4 Right animated frames. The grid is a newly generated candidate, NOT the owner-locked APNG. The owner Library APNG remains materialization-blocked.
- Art identity: long dark indigo-purple hair, white/cyan flower, blue-and-silver layered robes, blue-silver sword baked in each frame. Identity conformity of mixed-source actions is **not fully proven**.

## Exact 24-slot coverage — DO NOT INFLATE

| Action | Front | Right | Back | Left |
|:--|:--|:--|:--|:--|
| Idle | 4 candidate frames | 4 candidate frames | 4 candidate frames | 4 candidate frames |
| Walk | MISSING | 8 candidate frames (R4) | MISSING | MISSING |
| Attack | MISSING | 8 candidate frames (R4) | MISSING | MISSING |
| Cast | MISSING | 8 candidate frames (R4) | MISSING | MISSING |
| Hit | MISSING | MISSING | MISSING | MISSING |
| Death | MISSING | MISSING | MISSING | MISSING |

Total **40 independently stored 512×512 RGBA frame PNGs**; 7 lossless 4-column atlases; 7 GIF previews (with corrected 1-bit transparent palette), 7 full-alpha APNG previews; 24-slot manifest with 17 absences; verified original sprite-grid and preserved R4 frames. No fake/empty clip in SpriteFrames; Godot standalone project contains only seven real animation resources and marks absent states **MISSING**.

## QA

- `tools/verify_assets.py`: **PASS 40 PNG frames + 14 GIF/APNG alpha/frame-count verifications = 54 checks**. Checks PNG 512×512, nonempty alpha, no bounding-box crop, exact frame SHA, all atlas cells pixel-for-pixel, ZIP checksum, and minimum distinct frames.
- Standalone project at `godot_lab/`: Godot 4.7.2 compatible intended `SpriteFrames` and 1280×720 isolated preview scene; **NO Godot 4.7.2 executable was run** in this environment, so engine QA is **NOT_RUN**, native screenshot/video **NOT_AVAILABLE**. The video inside ZIP is clearly labeled **OFFLINE_NOT_GODOT**.
- `OPEN_PREVIEW.html`: local browser viewer with 6 action controls, 4-direction viewer, 24-state missing/present matrix. Does not require user to draw or install art software; open from extracted ZIP.
- Frame SHA check and source-grid per-cell transparency **do not equal art approval**. QA remains **OWNER_VISUAL_PENDING**. Production actors, male source and all gameplay systems remain unchanged.
- Rejected generated images claiming a 24-clip asset set are **promotional posters**, not genuine sources. They were deliberately not used. Previous wrong side-view or identity-morphing animation attempts were also excluded.

## Governance & next production gate

- PR #72 Draft, existing branch `integration/pve-p0-playable-ui-20261103`; HEAD verified before documentation writing **`2bef634f1477abc28e2401005dafe573ddd4b5c5`** (may advance concurrently).
- No rig, Codex, branch creation, merge, Combat V2, SaveService, PvE, V6.3 changes or production actor wiring.
- Follow current owner action-first decision: **finish one entire action with four real authored directions before moving to another**. Idle is now a candidate 4-direction vertical slice; it is not approved. The remaining Walk/Attack/Cast and Hit/Death cannot be declared done until valid source cels and Godot motion QA exist. Do not manufacture placeholders simply to reach 24/24.
