# VFX19 Thiên Lôi — original lightning Combat Lab (no Codex)
Authoritative art brief: `docs/operations/VFX19_THIEN_LOI_ART_BRIEF_20261113.md`.
Owner explicitly rejected prior VFX18 sword as ugly. This is a new sét-family study, **NOT a repainted sword**; derives quality lessons (not copy-paste art) from previously liked V9 serpent's light layering and dynamic spines.

## Independent Godot scene
`thien_loi_arena.tscn` 1280×720, GL Compatibility, actual existing 2D character/monster rig and muted original terrain, exactly 3 permitted test targets, fourth monster never hit. Key 1: A sky lightning bolt from clouds; Key 2: B ground-chain from caster; SPACE replay; P pause. Or env `TMB_VFX19_MODE=sky|chain`.

`thien_loi_vfx.gd` light renderer only:
- A/B lightning constructed with hierarchical midpoint-displacement (17 deterministic jagged points per strike, multiple independent time-varying beats). There are no prepainted arrows, polygon sword bodies, or static equal-spaced zigzag ladders.
- Layer signature V9: very thin white-hot spine, cyan/blue intermediate radiance, very diffuse blue-violet edge. Bounded main forks <=6, tiny forks cap and contact crackle <=7. Different intensities for MAIN vs relay bolts, no uniform copied rays.
- Charged caster's hand and cloud cues; progressive descending head; independent small ground discharge and quick no-linger fade. The effects layer alone has additive V9 original light shader; physical actor remains normally blended.
- `thien_loi_arena.gd` and `thien_loi_overlay.gd` contain only original laboratory demonstration clock, no V6.3 skill authority, no gameplay targeting/damage/HP/DoT/SaveService, no PvE integration.

### Mandatory visual QA
Focused exact SHA strict Godot 4.7.2 + true GUI render native 1280×720 A/B MP4, sample at least 10 distinct timestamps. Inspect genuine frame and fix any geometric "ladder" or flat drawn-cloud aesthetics, weak impact, target misalignment, clutter; technical PASS is not art approval. Windows and Android physical QA: PENDING USER. `OWNER_VISUAL_PENDING`, `PVE_INTEGRATION_HOLD`.

No commercial JX/Source A art reused. No new branch, no merge; work in PR #72 only.
