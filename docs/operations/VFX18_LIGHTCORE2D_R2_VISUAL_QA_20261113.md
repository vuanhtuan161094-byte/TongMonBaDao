# VFX18 LightCore2D R2 — real-Godot captured visual review and QA gate
Date: 2026-11-13 | PR #72 | Branch: `integration/pve-p0-playable-ui-20261103`

## Owner brief / skill authority
The user does NOT want to remember skill names; all TMB VFX tasks automatically route to [`tmb-vfx-art-director`](../../.agents/skills/tmb-vfx-art-director/SKILL.md) via `AGENTS.md` and private [TMB Project Copilot plugin v0.2.0](https://chatgpt.com/plugins/plugins_6ada2fab2ee08191a3c5ab82d945fbdb). Goal: implement native light-formed kiếm khí and a dynamic orbit array like the owner's own classic Võ Lâm reference without painted blades or copied game FX; keep actual PvE blocked until visual approval.

Read the preceding [JX, Source VL and Source A reference research](VFX18_JX_SOURCEA_LIGHT_LANGUAGE_RESEARCH_20261113.md). Reference analysis is **not** proof that JX uses only procedural code: legacy JX uses images and blending, while this original Godot implementation uses analytic light. Distinguish SOURCE_VERIFIED vs ORIGINAL_PROPOSAL.

## Code and implemented artifacts
- **R0 initial** [`19408d4d58`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/19408d4d58cdb29d1805cb623c203a8841536a19): `godot/labs/combat_lab/research03/light_core_2d.gdshader`, `light_contact_2d.gdshader`, isolated LAB arena/scene, focused deterministic visual test. First one projectile; then decorative sixteen-streak orbit with two different tangential directions and projected depths. No JX/Source A skill textures copied.
- **Workflow** [`e2539cb4b2`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/e2539cb4b24cde2d80402806a9429a8c105e019e): isolated Godot 4.7.2 exact-SHA QA and 3 genuine movies 1280×720.
- **R1 artist revision** [`6c7eddb6db`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/6c7eddb6db14ede8d894ba55e9ca4568888f421e): footage showed distracting flat isometric diamond ground and disconnected/static orbit lines. Replaced ground with subtle original gravel; added movement-history-curved beam tail and orbit wakes. R1 parse FAIL from a GDScript `*` at end of line, corrected [`460e4192a7`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/460e4192a7c12f4575cd8671e1c415d08245ad32).
- **R2 exact trajectory alignment** [`4ed4c60b35`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/4ed4c60b352b267171f8b96b52909f4f87b05a65): watched R1 frame, observed single sword's light core separated spatially from trail. Corrected shader display carrier to original in-memory 4×4 solid-white `Sprite2D` with centered transform, NOT a painted sword image. Contract asserts the shader UV hot-tip is aligned with actual Bézier route (<= 0.65 px). Strict GDScript typed test `prog` inference error corrected [`1caa2499a4`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/1caa2499a49da0e51cd82efba5d54061bcea8d97).
- No release stage; this is an **original mock-only art and simulation-free LAB**. Only **one** mock allowed target triggers a short fake sample contact; orbit cannot spawn combat hits. An explicit combat event adapter is required for any live future implementation.

## Official QA — verified current code exact SHA
- **Focused PASS** official [Godot 4.7.2 action run #43395591214](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43395591214) on SHA `1caa2499a49da0e51cd82efba5d54061bcea8d97`: `VFX18_LIGHTCORE_FOCUSED_RESULT=PASS failures=0`, strict import/GDScript parse, actual GUI Godot movie render of baseline, single light sword and orbit array.
- Archive `vfx18-lightcore-1caa2499a49da0e51cd82efba5d54061bcea8d97` in run, artifact id `14022597435`. Content: 3× original 1280×720 MP4, each 204 frames, fixed 60/1 encoded FPS, ten original frame samples per scene, filmstrips, compare PNGs, SHA256 manifest, raw import/parse/focused and render logs.
- **No physical performance inference:** Offline fixed-frame MP4 != actual Windows/Android FPS or hardware QA. 6v8 and 30 disciples/40 monsters GPU/CPU stress tests NOT DONE. The isolated workflow still applies an **ephemeral/UNCOMMITTED unrelated summon parse shim**; this does not make the clean full repository PASS. The separate historical `v63-quyen-doc-matrix` workflow still FAILS.
- Repo output still in single PR #72 Draft; no new branch/merge, no Source A/JX VFX asset import, no change to SaveService, Combat V2/V6.3 gameplay, damage/HP, target selection, active skill flag, mob or PvE renderer.

## Actual 1x visual frame review
Captured real Godot screenshots in artifact at t=0.36/0.72/0.95/1.20/1.55/1.85/2.23/2.43/2.76/3.00 seconds plus full-timeline sheet. Reference R0 was run #43393224687. R1 source pass was run #43394433036.

- **Single luminous sword qi** R2 at t=1.55: sharp tapered white-cyan core is not a physical steel blade; the pale cobalt tail now joins the leading light axis, corrected from R1 (there was a ~1-sprite-offset detached arc). At t=2.43 mock pre-contact, separate oblique white contact slash appears, no solid sword crossing monster. At t=3.00 no lingering phantom projectile.
- **Orbit** at t=1.55 and 2.43: 16 different-size tapered light needles follow two opposite rotating ellipses; low-alpha azure circular atmosphere and curved motion-history streaks; bright center actor remains readable. It now matches key *principles* of owner's reference better than previous flat polygon/physical sword R17. But some streak placement and under-actor rendering still need real scene QA.
- **Background/actors**: generic 2D stylized combat rig and self-drawn fine gravel, NOT an authentic 2.5D Source A real map / finalized character. Thus final scene-style quality cannot be claimed.
- **R2 art rubric (provisional author review, not owner):** silhouette 4/5; luminous material 4/5; choreography **3/5** (charge subtle); composition 4/5 (orbit center readable); contact **3/5** (one small hit slash); fade 4/5; school uniqueness 4/5; crowd performance **NOT MEASURED**. Because two core categories <4, keep `ART_REWORK_REQUIRED / OWNER_VISUAL_PENDING`; no auto-enabling PvE.

## Next safe actions / gate
A. Owner chooses whether to pursue the **orbit reference** as preferred first polished motif (A.2: stronger circular energy and clearer orbit hierarchy, softer light).
B. Improve single sword-qi **charge & real contact** in isolated LAB only, keep one mock target; test 1x motion with real-world arena without passing owner gate implicitly.
C. Hold and review another batch of references from JX / Source VL / Source A **read-only**. Source rights remain unverified; don't ship commercial pixels.

Statuses: `SOURCE_RESEARCH_DONE` / `CODE_LAB_READY` / `GODOT_FOCUSED_PASS` / `ACTUAL_MOVIE_FRAMES_REVIEWED` / `ART_REWORK_REQUIRED` / `OWNER_VISUAL_PENDING` / `PVE_INTEGRATION_HOLD` / `WINDOWS_ANDROID_PHYSICAL_PENDING`.
