# AS-CHAR-43 — Kiếm Tu high-res Walk integration: resume without losing artwork (2026-11-14)

## Read first
1. `AGENTS.md` (new work **NO RIG**, no merge, one PR #72).
2. `docs/animation/TMB_KIEM_TU_SOURCEA_HIRES_ZOOM_LOCK_20261114.md`.
3. `docs/animation/AS_CHAR43_KIEM_TU_WALK_GAME_PILOT_20261114.md`.
4. Current Issue #77 and latest PR #72 HEAD.
5. The actual ZIP from personal ChatGPT Library: `/TMB-Character-Art/AS_CHAR43_KIEM_TU_IN_GAME_WALK_R1_20261114.zip`, SHA-256 `b420d8e79ef9a560e571464ff1f56ab7c29d6e2f157cab186381dbda50fccde9`. **It is not committed to GitHub.** Fetch the real bytes from Library, do not infer a sandbox path. The owner uploaded GIF input `Kiếm sĩ tóc bạc bước đi pixel art(1).gif` SHA-256 `15b78700836f3d519fbe916ae819f20c9d07d3821b6c8917bb84df99f950b6ac` is included only through corrected extracted asset and manifest in the ZIP.

## What has actually been built
- Real 9-frame RIGHT walk from the uploaded 508×337 GIF (each frame 120 ms); extracted matte from GIF's *opaque checkerboard* into 512×384 RGBA images; 1536×1152 transparent atlas. Source figure about 328px visible, designed 75px at map zoom 1×; 150/225 at zoom 2×/3×.
- Four owner-liked independent STAND view PNGs (front, right, back, left), from previously preserved AS-CHAR42 high-res owner master. Other-direction walks ARE NOT authored.
- Independent modular red-black source sword, cyan color demo (not an approved item), and no-weapon choice. Technical hand socket motion for Walk-right, **minor hand/grip art defect remains pending**.
- Godot `AnimatedSprite2D` + child `AnimatedSprite2D WeaponBehind`, no rigs, no bones; Walk-right timeline and weapon texture synchronized; 1280×720 in-project visual preview `res://labs/character_family/as_char43_kiem_tu_game_preview/preview.tscn`. Preview keys D/E/1-3/F.
- On PR #72 commit `1d8dfeac50b8e184645b7667cf287f0834ef179a`: scene-path selection guarded by **male with existing Sword branch ID** plus installed PackedScene; other male/female disciples keep original Source A/fallback. Existing `ModularDiscipleActor` respects per-direction stand fallback and pilot high-res metadata scale. V6.3 stays OFF.
- Local Python visual/source/alpha/swap tests **8/8 PASS**, ZIP CRC PASS. Offline MP4 available; **NO OFFICIAL GODOT 4.7.2 GUI QA**, no physical Android, no final actor art release pass.
- Installer in ZIP: double-click `INSTALL_AND_PREVIEW_E.cmd` after unzipping. It copies only to `E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao\godot\...` with existing correct branch and refuses conflicting file overwrites; never cleans, checks out, resets, merges or touches saves. Does NOT synchronize GitHub source automatically; live PR #72 view adapter must be present on E for branch-based selection.

## Current gate
**CODE_IN_PR72 / BINARY_IN_LIBRARY / OWNER_LOCAL_E_NOT_INSTALLED / QA_ENGINE_PENDING / RIGHT_WALK_RENDER_QA_PENDING / HAND_ART_PENDING / 3_DIRECTIONS_WALK_MISSING / ATTACK_MISSING.** Do not represent this as all 4-direction Walk or production release.

## Next
On actual owner E system, check git branch/HEAD/dirty, copy opt-in pack, run official Godot 4.7.2 import and preview GUI at 1280×720 zoom 1×/2×/3×; check dark-background alpha, planted feet, hand socket, sword occlusion. Capture real GIF/video/screenshot and correct hand defect in approved art, no primitive pixel drawing and no rig. Only after that produce genuine other-direction Walk and Attack. Do NOT ask owner to learn LibreSprite or reupload locked identity art.