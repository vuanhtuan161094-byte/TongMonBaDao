# VFX-RESEARCH-01 — Independent Godot Combat Lab
**PR:** #72, `integration/pve-p0-playable-ui-20261103`; **Godot:** 4.7.2, Compatibility; **source:** newly authored GDScript, references reviewed separately.

## Visual contracts
- `research01_arena.tscn` previews **three equal-size 1280×720 shots** on the same background, caster, four monster rigs, and three authorized LAB-only visual targets. Fourth monster never gets a visual hit. Toggle **1/2/3** (V14.2 baseline / A crescent / B afterimage), **SPACE** replay, **P** pause.
- **A:** original sampled tapering crescents inspired by REEBOO's head/tail speed and contour, 3 close-spaced attack waves. One visible dominant slash per target, reduced opacity, no extra giant AOE disc.
- **B:** original short-ghost projectile and a single diagonal cut inspired by GDQuest ghost trails and PSCactux contact cadence, short 5-spark scatter based on BurstParticles2D design principle. No particle plugin imported.
- **No external images, textures, shaders or code imported.** No Additive flood. V14.2 source remains unchanged. Art is **CODE** and requires OWNER review, not CI auto-approval.
- Godot movie: `TMB_VFX_RESEARCH_MODE=baseline|crescent|afterimage`. Movie frame count 168 at fixed 60 FPS, native 1280x720. Vary only mode.
- `research01_contract_test.gd` verifies authored script loads, exactly 3 mock targets / 4 actors, 3 visual attack windows, mode switch, and bounded impact. This is **NOT** gameplay or performance acceptance.
- One VFX-only GitHub Action publishes three full-size MP4s + impact screenshots + filmstrips + comparison sheet, exact source SHA, isolated parse log and external source/demo check logs.
- Known upstream `v63_summon_skill_combat_system.gd` type parse blocker: CI may use one explicit temporary uncommitted shim in disposable checkout, never claims **full clean repo PASS**.

## Source research and licence checks at pinned commits

| Source | Pinned HEAD | License read | Compatibility position | What is used |
|---|---|---|---|---|
| [REEBOO Stylized 2D VFX Lite](https://github.com/REEBO0/godot-stylized-2d-vfx-lite) | `0fb078c` | MIT | Godot >=4.4, publisher claims Compatibility support. Verify 4.7.2 CI probe | `slash_arc.tscn` / `fx2d_slash.gdshader`: tapered crescent, speed profile, hot thin edge |
| [GDQuest Visual Effects](https://github.com/gdquest-demos/godot-visual-effects) | `647a8f1` | Scripts/shaders MIT; image art CC BY-NC-SA 4.0 | Godot 4.3 config with legacy viewport stretch; not assumed directly portable | Ghost trail/afterimages only, no art imported |
| [PSCactux Godot Effects Lab](https://github.com/PSCactux/godot-effects-lab) | `6af3c85` | MIT | Godot 4.7 default Forward+; Compatibility trial required | Short impact and limited spark duration; no external scene copied |
| [BurstParticles2D](https://github.com/uzkbwza/BurstParticles2D) | `f0fa6e0` | MIT (`LICENSE.md`) | Godot 4.3 source; own README warns CPU/RenderingServer one-shot can cost more than engine particles | only deterministic burst timing, no addon imported |

### Exclusion
Do **not** merge, replace live VFX, adjust HP/skill/target selector/SaveService, add an economy system, create branches, or call movie-output 60 FPS measured device FPS. Windows mouse and physical Android remain **PENDING USER**. No automatic visual acceptance.

### Goal for acceptance
Owner inspects raw videos at game size, compares **silhouette**, stroke direction, warm/cold hierarchy, occlusion of monster art, recognizability at 1×, and contact afterglow. Only a visually approved variant can move to a separately authorized PvE integration packet.

### Owner-size visual review correction — RESEARCH01.1
- First imported real 1280×720 Godot videos at SHA `c9a7dfed` compiled and rendered, but **A/B silhouette was too small** compared to V14 baseline. Visual assessment: NOT APPROVED, not "better" simply because less busy. Correction: A has one large AoE crescent per wave; B has one readable diagonal master-stroke and larger travelling trail. Both remain visually constrained with 3 legal mock targets; no new hits.
- External repo probe used stdin consuming characters in the fourth loop and Burst example path was wrong. Use FD3 for pinned source list; corrected Burst example to `res://addons/BurstParticles2D/BurstParticles2D-demo/MultiParticleExample1.tscn`.
- First workflow failed late because Godot import normalized preexisting tracked output files; focused contract, videos and REEBOO/GDQuest/PSC preview were generated. Final verifier now compares tracked changes **after** import to tracked changes **after** reference probes, while asserting the disposable summon shim. None of these generated checkout changes are committed.
