# VFX18.2 R1 — Godot 4.7.2 exact-SHA art and QA closure (2026-11-13)

## Request and authority
User: "làm tiếp đẹp đi"; then corrected the assistant: "m có quyền nhé." Directly implemented through GitHub, **without Codex**, using `.agents/skills/tmb-vfx-art-director/SKILL.md` as the art-production contract. Only PR #72, Draft, branch `integration/pve-p0-playable-ui-20261103`; no merge/new branch. This is a **LAB-only art candidate** and never a gameplay feature without owner's separate approval.

## Source, provenance and storyboard
- Prior research: `docs/operations/VFX18_JX_SOURCEA_LIGHT_LANGUAGE_RESEARCH_20261113.md` distinguishes JX1, Source VL and Source A. Their commercial asset pixels are NOT shipped. New source is original GDScript/CanvasItem procedural shader with a plain-white 4×4 internally generated UV carrier (no painted sword).
- R18.2 **pre-code** storyboard: `docs/operations/VFX18_2_ART_STORYBOARD_20261113.md`; committed at SHA `d14189a7ba613e19cb313858c433a1d4d795c37a`.
- One qi energy projectile and one explicit mock contact, not a steel sword and not 4 real hits. Orbit contains exactly 16 bounded nonuniform decorative light streaks, zero hits. Real Combat V2 target/HP/damage/DoT/cooldown/SaveService untouched.

## Changes
Code authored at `fe916d09e6dfe38118566d4234c9f131c525ff55`:
- `godot/labs/combat_lab/research03/research03_arena.gd`: five moving gradually pulsing curved charge strands, thin shader-only air-blade, longer localized six-fragment light impact, minor irregular asymmetric orbit phase and eight faint wakelets, one soft orbit atmosphere with correct back/foreground actor ordering.
- `godot/labs/combat_lab/research03/light_contact_2d.gdshader`: incisional **traveling Gaussian white/cyan cut** with weaker delayed counter-shear and fast fade. Light, not filled opaque blade or giant circular explosion.
- `godot/labs/combat_lab/research03/light_core_2d.gdshader`: a bounded `curl` for slightly fluid **orbit** light tips, while preserving rigid single sword-qi blade axis.
- NEW `godot/labs/combat_lab/research03/light_orbit_aurora.gdshader`: original procedural soft atmospheric underglow, no texture or game source clip.
- `godot/tests/labs/combat_lab/research03_contract_test.gd` additionally verifies new shader loads, atmosphere never in single, correct layer behind actor, and still exactly 16 orbit primary carriers; old tip/path alignment and one-authorized-mock-contact contracts retained.
- `.github/workflows/vfx18-lightcore-lab.yml` now watches shader changes too.

## Actual frame inspection and R1 artist correction
First source SHA `fe916d09e6dfe38118566d4234c9f131c525ff55` passed technical [Godot run #43403570719](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43403570719); **real orbit frame at 1.55s revealed harsh wedge-like polar sector gaps in the blue fog**, visually unacceptable. Do not treat code PASS as art acceptance.

Fixed in **final code SHA** `95d63e18a6ec6014b42b935edc179404a248d7e9`:
- Replaced hard angular cutoff with **continuous Gaussian falloff and gentle angular breathing**, substantially reduced maximum atmosphere alpha, and lightly varied angles within each of the two orbit bands to avoid 8 perfectly even clock-hand spokes.
- Independently re-rendered the entire Godot movie, reviewed t=0.36 (charge), 1.55 (in-flight and orbit), 2.43 (one mock impact), 3.0 (dissolve), plus all ten native samples + filmstrips.

### Visual observations on FINAL R1 genuine 1280×720 capture
| phase | R18.1 (previous) | R18.2 R1 (current) | artist gate |
| --- | --- | --- | --- |
| charge, 0.36s | mostly straight crossing strands | gently curved moving converging streams, richer but still visually small | 3.5/5 |
| flight, 1.55s | recognizable white/cyan core | same correct original feathered qi blade, with tiny deliberate variation | 4/5 |
| contact, 2.43s | short white cut too small for blade | **longer sharp diagonal incision + offset secondary shear**, fewer diffuse circles, 6 minor energy splinters | 4/5 |
| orbit, 1.55s | sixteen very evenly spaced straight strokes | slightly curved nonuniform hot streaks, soft subtle blue airfield and eight fine temporal wakelets | 4/5 |
| fade, 3.00s | disappears | all energy clears; no lingering ring or fake persistent status | 4/5 |

Specific limitation: the actors and gravel terrain are still simple Combat Lab prototypes, not approved game production assets; the orbit remains visibly 16 separate strokes and could be made smoother still. No 6v8/30v40 native hardware performance evidence yet. Owner's photo remains an **art reference**, not proof JX used particular shaders.

## QA exact SHA (FINAL)
- [Godot 4.7.2 Action #43404146899](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43404146899) at source SHA `95d63e18a6ec6014b42b935edc179404a248d7e9`: **SUCCESS**, strict GL Compatibility import, GDScript parse, focused contract `VFX18_LIGHTCORE_FOCUSED_RESULT=PASS failures=0`, four script/movie passes, 3×204-frame actual 1280×720 MP4 at fixed encoded 60/1fps.
- Evidence artifact ID `14026506970`: `vfx18-lightcore-95d63e18a6ec6014b42b935edc179404a248d7e9`; contains `baseline.mp4`, `single.mp4`, `orbit.mp4`, frame samples at 0.36/0.72/0.95/1.20/1.55/1.85/2.23/2.43/2.76/3.00 seconds, filmstrip and all original logs/hashes. Actual video frame encoding at fixed 60fps ≠ actual Android GPU FPS.
- This **isolated** Action applies a historical disposable/uncommitted upstream V63 summon parse shim in CI. Unrelated `v63-quyen-doc-matrix` workflow remains **FAIL**. Never claim full-repo clean PASS.
- Windows/Android physical and measured multi-actor stress test `PENDING USER`.

## STATUS
`SOURCE_RESEARCH_VERIFIED` • `CODE_LAB_READY` • `GODOT_FOCUSED_PASS` • `FRAMES_REVIEWED` • `ART_OWNER_VISUAL_PENDING` • `PVE_INTEGRATION_HOLD` • `PHYSICAL_WINDOWS_ANDROID_PENDING`.

## Next independent art options (owner visual gate must precede live PvE)
1. Polish LightCore qi against actual **full production actor/map background**, keeping art-only LAB.
2. Revisit JX/Source VL original source animation timing before inventing new motif; don't copy licensed pixels.
3. If owner approves this style, propose separate new event-bound VFX integration authority; do NOT auto-enable.
