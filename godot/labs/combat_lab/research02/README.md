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

## Exact-SHA QA closure (2026-11-13)
- **CODE**: renderer, separate scene, focused tests commit [cead27f7](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/cead27f70af45d76535f65033ed66c88003d3902).
- **CI workflow**: [c8359879](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/c8359879ae257e0adf7280632f7913af098d6ffc).
- **ISOLATED GODOT 4.7.2 FOCUSED PASS**: [run #43382287589](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43382287589) SUCCESS at SHA `c8359879ae257e0adf7280632f7913af098d6ffc`. Logged `VFX_RESEARCH02_FOCUSED_RESULT=PASS failures=0`. Official Godot `4.7.2.stable.official.ed1daf0bf` with GL Compatibility in virtual Xvfb.
- **Visual evidence**: CI artifact `research02-flowing-sword-c8359879ae257e0adf7280632f7913af098d6ffc`, ID `14017271962`, contains 4 original full-resolution 1280×720 videos (V14.2, RESEARCH01 A/B, RESEARCH02 C), 3 time samples per mode, filmstrips, four-way images and import/parse/focused log. All 168 frames encoded at fixed 60 fps; **not physical measured FPS**.
- **Human visual review** at 1280×720 real captured frames t=1.30, 1.67 and 1.98: Flowing Sword Qi has a noticeably more readable proper rigid sword than A/B and the tail appears genuinely curved/attached to the same flight path. Caveat: some overlapping simultaneous swords still crowd the target sprites; improvement over V14.2 is **not proven** without OWNER review. No automatic art acceptance.
- **No integration**: V14.2 renderer intact; RESEARCH01 intact. Original content, no copied external third-party files. No combat/HP/target selection/SaveService touched.
- **Known limitation:** isolated CI applies a one-line, **uncommitted** prior summon parse shim in the disposable checkout. This is NOT a clean full-repo Godot PASS; V63 matrix failed on separate workflow. Physical Windows/Android PENDING USER; PvE integration HOLD; OWNER_VISUAL_PENDING.
