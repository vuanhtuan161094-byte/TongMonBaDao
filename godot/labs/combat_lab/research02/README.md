# VFX RESEARCH 02 — Flowing Sword Qi / V17 (LAB ONLY)
Owner goal: reuse the good-looking energy-motion *principle* of Combat Lab V9 light-serpent and the recognizable blade shape from V14.2; stop adding washed-out overlapping additive shaders.

- Source: original `flowing_sword_fx.gd`, no external GitHub assets/code copied. REEBOO, GDQuest, PSCactux and BurstParticles2D technique/license research is preserved under `../research01/README.md`.
- The rigid sword uses the existing original `combat_lab_v14_sword_fx.gd::_qi_blade` with hilt, guard, bevel, seal and sharp tip; it remains recognizable, NOT a bent snake.
- The tail uses cubic flight path samples plus three offset sine/spine ribbons, a *living/flowing* energy trace anchored to the same trajectory as the flying sword. Blue/teal glow constrained; no global `blend_add`, no `TIME`, no large shock disk or white impact bloom.
- Contact: per-target diagonal slit + 4 directional micro-sparks on the third wave only, short fade; the fourth fake demo monster is excluded. Exactly 3 fixed demo targets and 3 waves. LOD 9/6/3 visual passes still preserve all waves.
- Separate scene `research02_arena.tscn` extends the previously approved-for-QA `research01_arena.gd` actors/background/timing, adding only VFX variant C. Key Space replays, P pauses. Baseline/A/B are untouched.
- Data ownership: the renderer receives explicitly provided positions, NEVER infers targets, alters damage, HP, combat clocks, SaveService, or PvE. This is a LAB-only art candidate requiring OWNER visual approval.

## Evidence
To be updated after exact SHA Godot 4.7.2 Compatibility focused tests, video capture at 1280×720, movie frame review, and callback checks. Windows/Android physical QA stays PENDING USER. Never claim 60fps offline movie encoding is real mobile FPS.
