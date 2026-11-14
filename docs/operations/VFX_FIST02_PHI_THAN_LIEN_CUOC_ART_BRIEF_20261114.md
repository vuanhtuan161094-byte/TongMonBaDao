# FIST02 — Phi Thân Liên Cước | Art-first V1 (14/11/2026)

**Status:** CODE_LAB_READY; technical & visual approval not inferred from committing. PR #72 Draft; Godot 4.7.2 GL Compatibility; no rig, Codex, merge, new branch, live PvE or gameplay edits.

## G0 — Exact canonical declaration
- `tmb.skill.fist.ba_quyen.active_02.human` (Human Bá Quyền): effect=`guard`, element=`fire`, shape=`single_target`, cap=1, cast=0.45 s, range=5.5, cooldown=8, projectile_speed=0, power=0.35, duration=4 s.
- **This is guard, not a multi-hit damage effect.** The catalogue's damage_ratio metadata is not permission to synthesize a hit; no damage, fake DoT, HP changes, shield strength formula change, or AoE.
- LAB guard is shown on the caster as a **visual sample**. Actual recipient and timing will only derive from a separately verified Combat V2 cast/guard event if live integration is later authorized.

## G1–G3 — Art direction and assets
- A pair of rapid broken-arc heel trails, individually posed, condensing into a **crossed kinetic pressure guard**, with a few earth dust motes. Amber, ivory-gold and warm umber, no flame projectile or talisman paper/runes.
- This is a new first-party deterministic raster atlas generator based on the *production method* learned from Tal01, not any of its art: `tools/vfx/generate_fist02_guard_atlas.py`.
- Three transparent RGBA sprite sheets, generated before Godot import: 12 heel-sweep poses 4×3×320px =1280×960; 8 crossing-guard poses 4×2×320px =1280×640; 8 footfall-dust poses 4×2×320px =1280×640. Each pose has independently varied path geometry, brush highlights and motes; no external licensed pixels and no rig.
- The existing Nu Doc Tu idle sprite and valley SVG backdrop are only scale/composition **stand-ins**. A full frame-by-frame Fist actor kick is NOT claimed.

## G4 — Animation chronology (visual-only lab)
| Local preview | Visual behavior |
|---|---|
| 0–0.19 s | first kinetic heel sweep / dust |
| 0.19–0.45 s | second sweep; whole sprite advances as a *placeholder* |
| 0.45–4.45 s | one guard cue on one recipient, 4.0-second contract duration |
| 4.45–4.94 s | guard dissipates, no new damage cue |
| 4.94–5.32 s | full clear / preview loop reset |

The 0.45 s mockup is no authority to add gameplay guard; no real Combat V2 hit/status writes. No persistent damage projectile. Additional light glow is subordinate to the raster hero sheet. No mock impacts at the dummy opponent.

## G5–G7 — Evidence
- Isolated scene: `res://labs/combat_lab/fist02/phi_than_lien_cuoc.tscn`.
- Focused contract: `res://tests/labs/combat_lab/vfx_fist02_contract_test.gd`.
- Native workflow: `.github/workflows/vfx-fist-02-phi-than-lien-cuoc.yml`: Godot 4.7.2 pinned executable, strict import/parse and contract, genuine 1280×720 video of 318 fixed-clock frames, GIF, 12 checkpoints, raw generated atlases and hashes.
- Required manual review: cast 0.09/0.17/0.29/0.41, guard 0.51/0.81/1.25/2.15/3.33/4.30, fade 4.61/5.07. At 1× verify the guarding actor stays visible and the VFX remains distinct from FIST01.
- **Owner R10 decision:** Khai Sơn Trọng Quyền R10 'tạm tạm': provisional acceptance to move to the next skill, not ideal art approval or live PvE permission. FIST02 must pass technical and real-image QA separately.
- `OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD / V63_OFF / PHYSICAL_WINDOWS_ANDROID_PENDING`.
