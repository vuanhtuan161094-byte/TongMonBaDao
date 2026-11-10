# TMB Poison V4 — GitHub/Godot pilot evidence and hard acceptance gates
Date: 2026-11-10. PR: #72 Draft. Branch: \`integration/pve-p0-playable-ui-20261103\`.

## Owner contract

- Preserve **approved Nữ Độc Tu** four-view MASTER SHA-256 \`435f8969c3d89468ddbdec837a44365b212b58e01082728c3f21f2b08249c118\`.
- Walk is already owner-accepted: do NOT regenerate or replace it while revising Cast/Attack/Hit/Death.
- Four reviewed new action GIFs are **tentatively accepted for the production process**, not final in-game release acceptance.
- Only presentation/editor QA changed. No gameplay, V6.3 damage/heal authority, SaveService, economy, producer, boss balance, production scene, feature flags, branch creation, or merge. V3 remains default.
- No paid third-party service (including Runway).

## V4 source diff

| Commit | File/scope |
|---|---|
| \`ff0b4b1982a4c2ec35ae3f9a14360b2de8bf29e4\` | \`combat_lab_poison_v4_layers.gd\`: new original event-driven layered render-only VFX. Độc Châm = needle fans/impact; Cổ Độc = serpentine gu line/mark; Dược Độc = jade lotus/heal/cleanse. Deterministic bounded particles and independent halo/highlight layers. |
| \`cfe8cddc74049d2bef0b3b1c108913270aaef7ae\` | Existing \`combat_lab_vfx_v2.gd\` gains a V4 Lab-only switch: \`TMB_POISON_V4_PREVIEW=1\`. Existing V3 textures/renderer remain unchanged and default. |
| \`96f967973222a3630a8bb39d232376b21c7261fd\` | Scoped branch-ID/V6.3 catalog/zoom contract test; does not declare visual PASS. |
| \`fa3617e63cc8b778920cb8415c234d3bcfc89357\` | Dedicated official Godot Movie Maker capture with real V6.3 events, four zoom settings, no synthetic combat outcomes. |
| \`5d3a2f1f81bc9d926aeb09e94d4fda4292d39640\` | First strictly successful six-video workflow at exact SHA. |

## Official 4.7.2 evidence — first six-video run

- Workflow: https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42746410374
- Artifact ID: \`13731805565\`, \`poison-v4-godot-5d3a2f1f81bc9d926aeb09e94d4fda4292d39640\`, ZIP digest \`f968dfb0f845285a646a7b9fc45b3ef75799cf312e7b4e58fca2704682a8fc13\`.
- **Strict import and \`--check-only\` and renderer contract: PASS**, Godot 4.7.2 stable official, 0 engine \`SCRIPT ERROR\` in strict logs. \`POISON_V4_RENDER_TEST_RESULT=PASS failures=0\`.
- Six genuine Godot 1280×720, 24 FPS movies, **194 frames each**, ~8.083 seconds. Zooms: Độc Châm 1x/2x/4x/6x; Cổ Độc 2x; Dược Độc 2x. Source \`MapBattleV2\` and V6.3 events, not image-generated footage.
- Event observations at each checked zoom: Độc Châm \`skill_cast=1, skill_release=1, v63_skill_hit=1, status_ticks=4\` (63 total); Cổ Độc \`1,1,1,5\` (65 total); Dược Độc **active_01.human is DAMAGE**, \`1,1,1,0\` ticks (45 total). **Do not count it as a HEAL proof**.
- \`skill_hit=0\` in these event-count summaries because the canonical resolved impact is surfaced as \`v63_skill_hit\` (1); never rewrite or fake a \`skill_hit\` receipt.

## New healing gate

A separate **Dược Độc active_02.human HEAL** QA case was added to \`poison_v4_video_capture.gd\`, with one wounded disciple in an *isolated in-memory Lab fixture only*, no generated heal, save write or production state. The test must observe a real committed V6.3 \`heal\` event before PASS. A new 7-video Actions run is queued/running; **no healing PASS claim until it finishes**.

## Alpha atlas pilot, separate chat download — not a repo runtime asset

- Approved previous Walk and Idle atlas bytes are preserved verbatim with their SHA values.
- The four user-reviewed action sheets had RGB white matte. A conservative local Python extraction produces 4×8 fixed-grid 320×384 RGBA alpha actor frame candidates (Cast/Attack/Hit/Death), aligned to \`(160,351)\`.
- Local static QA: all 4 sheets have alpha 0–255, 8 distinct cells per direction, 0 clipped cells, 0 foot-pivot drift. This does NOT certify style/limb seam/FX removal.
- Candidate ZIP: \`TMB_Poison_V4_Nu_Doc_Tu_Alpha_Review_20261110.zip\`, SHA-256 \`708bdfcab74d2842355061a4553be22fc207c6703cab13063efcb7b7ac047979\`. Download is provided in ChatGPT. **Its binary atlases have not been committed to GitHub**. No review of official Godot V4 *actor* atlas import.
- Potential duplicate visual aura: green glows on generated Cast/Attack frames are partially baked in. Do not combine those directly with new separate VFX and claim clean final layering without a mask/art redo.

## Evidence scope / visual limitations

- **VFX technical run: PASS on first video SHA.**
- **Visual aesthetic review: PARTIAL.** Zoom 1x the effects/character are small; zoom 6x the native Combat Lab framing crops actors/effect peaks. Zoom 2x is the best comparative reference. Win10/Android FPS/RAM and mouse interaction not tested in Linux Mesa llvmpipe run.
- **Exact cast/release/impact/DoT frame alignment:** event counts verified; per-frame correspondence is NOT yet independently instrumented/approved. Do not claim it from 194 frames alone.
- **3-tier skill coverage:** this packet covers three representative HUMAN active_01 skills. Divine remains feature-gated; 26 earlier Divine poison rules remain design pending, not silently shipped.
- **New V4 actor + V4 VFX in one actual Godot scene:** **PENDING**. The recorded Lab is currently using legacy \`nu_doc_tu_grok_01\` atlas. Preview source package in chat is not automatically imported.
- **Approval:** owner has not approved final skill-level VFX or actual 1x–6x final QA.

## Final condition before moving production

Require an exactly sourced real V4 actor atlas in a separate QA lab, remove any residual baked VFX overlap, verify four directional action clips at 1x/2x/4x/6x and event-time overlays, rerun strict official Godot tests and human visual review. Keep V3 available as rollback. Do not merge #72.
