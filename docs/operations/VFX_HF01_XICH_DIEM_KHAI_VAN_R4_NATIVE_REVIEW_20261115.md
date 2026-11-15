# HF01 Xích Diệm Khai Văn — R4 native Godot review (2026-11-15)

**Branch/PR:** `integration/pve-p0-playable-ui-20261103`, PR #72 Draft. One isolated Combat Lab; no merge, new branch, rig, Codex or live PvE.

**Exact production evidence SHA:** `eb63387abd8e7871d695717b0f5aafddc26ef5ef`  
**Official 4.7.2 run:** https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43690915417  
**Artifact:** `14153000222`, `vfx-tal06-eb63387abd8e7871d695717b0f5aafddc26ef5ef`.  
**Checks:** R4 repaint + RGB/alpha uniqueness 12/12/8 PASS; pinned original source six hashes PASS; Godot 4.7.2 Compatibility import/parse/focused PASS; native movie render PASS; FFprobe 1280x720, 60/1 fixed encoded FPS, 198 frames; MP4, GIF and 14 timecode captures. Engine fixed-FPS output is not physical-device FPS proof.

**Skill authority:** `tmb.skill.talisman.hoa_phu.active_01.human`; single-target damage/fire cap1, cast .5, cooldown 9.4, range 8.5, declared projectile speed 8.5. LAB moves a *previously selected* real monster walk sprite; no new target acquisition, actual HP change, burn/DoT, AoE, SaveService or Combat V2 mutation.

**R4 art corrections from true 1x frame audit:**
- Initial R4 at `6c38415d` technical PASS but artistically self-rejected: comet as thin orange arrow at 1.38, fire contact at feet 1.49.
- `33a5d94b` compressed ground scorch under the moving foot; `24529518` moved single contact to lower torso.
- `86f8c069` gave flying sprite coherent volumetric plume and an alpha-painted burst; `eb63387a` changed seal to progressive fire-like ink and decreased circular white contact hotspot.
- Final native frames 0.43/1.38/1.49/1.62 inspected. Target contact now visibly follows the moving actor and flare is local, but **visual quality remains below the owner-approved Loi Phu benchmark**; source still has a weak paper silhouette and somewhat dusty flame. **Do NOT mark OWNER_VISUAL_APPROVED from tech PASS.**

**Assets/provenance:** original `tools/vfx/hf01_r4_remake.py` and only original TMB SHA-pinned R3 pigment source. Three new `tal06_r4_*.webp` assets are reproducibly baked before Godot import in workflow, not committed to the repo. Artifact ZIP includes their actual produced bytes and hashes. No Source A/JX commercial sprites or image-poster screenshot pixels.

**Status:** `GODOT_FOCUSED_PASS`, `NATIVE_MP4_PASS`, `OWNER_VISUAL_PENDING`, `PVE_INTEGRATION_HOLD`, `PHYSICAL_WINDOWS_ANDROID_PENDING`, `V63_OFF`.
