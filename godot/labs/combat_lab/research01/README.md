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

## Exact-SHA implementation closure — 13/11/2026

**Status:** `CODE_DONE / GODOT_4.7.2_ISOLATED_FOCUSED_PASS / 3x_VIDEO_RENDERED / ART_OWNER_PENDING / LIVE_PVE_HOLD`.

- LAB source SHA `2442e94890c300faa67376321ec1b9be811c8eb5`; workflow fix HEAD `d6d81cb8a123de47e4fefec46b790f7e25524758`; [focused Godot run #43371282663](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43371282663) **SUCCESS** (private artifact `vfx-research01-d6d81cb8a123de47e4fefec46b790f7e25524758`).
- The focused `research01_contract_test.gd` prints `VFX_RESEARCH01_FOCUSED_RESULT=PASS failures=0`. Strict import+parse, 3 full-sized 1280×720 movies, all with recorded 168 frames at 60fps, generated from actual Compatibility renderer. `--fixed-fps`/movie timestamp is **NOT physical performance**.
- A/B full-scene images and movie at t≈1.67s inspected (CI rendered, not generated concept art): A gained larger crescent silhouettes and a readable shared 3-target AoE; B gained a deliberate long diagonal sword strike. Neither is visually approved as a definitive art replacement: A lacks richness/character relative to original V14.2, B is clean but austere. **Owner must decide** using side-by-side movie; don't claim A/B outrank V14.2.
- Independent pinned source inspection and demo run with **Godot 4.7.2 Compatibility**: REEBOO import and real `slash_arc` rendering PASS; GDQuest demo-selector scene PASS; PSCactux `juice` scene PASS; Burst targeted `MultiParticleExample1` scene starts/render exit 0. IMPORTANT Burst import log reports its **stale default main scene path missing**, and the selected movie sample may contain no visible burst. Therefore these are limited scene/probe passes, not blanket compatibility or shader/particle feature certification. Source version/license table above documents provenance.
- All visual output is internal: no external code, sprite, texture or plugin copied to gameplay; V14.2 intact; no gameplay state or Save changes; no branch/merge. `gl_compatibility` and synthetic actor rigs are not Windows/Android physical UI evidence.
- Runner used an **explicit ephemeral non-committed summon annotation** to unblock unrelated `v63_summon_skill_combat_system.gd` parse failure; full clean repo/official V63 CI may still FAIL. This is isolated LAB evidence only. Physical Windows and Android remain **PENDING USER**.
- llvmpipe CI movie logging, from final test (not actual Android FPS): V14 GPU 12.11 ms/frame; A GPU 11.67 ms/frame; B GPU 10.03 ms/frame. These times include their respective whole LAB scene on software Mesa, and must not be extrapolated to a real mobile device.

### Visual gate for follow-up
If owner chooses A/B, next authorized packet should **polish one visual silhouette** (not combine all effects), include a 1× game view and a 2× crop from the same frame, test effect layering over monster rig, then ask owner visual approval before any live skill integration. Do not proceed automatically.
