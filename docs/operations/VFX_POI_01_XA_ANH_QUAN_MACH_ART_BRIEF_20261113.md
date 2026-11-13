# VFX-POI-01 — Xà Ảnh Quấn Mạch / Cổ Độc
Date: 2026-11-13. Owner APPROVED Cửu Thiên Lôi Kiếp R4 light-language as material standard, NOT this new skill. PR #72 Draft, existing branch only.

## Verified gameplay truth / isolation
Skill tmb.skill.poison.co_doc.active_02.human: Human, poison, SINGLE TARGET, limit 1, catalog range 7.5. VFX is view-only and does not query real battle state or update HP, poison, target, status, cooldown, Combat V2, SaveService, V6.3 or PvE. Only ONE fixed visual target in independent LAB.
No rig. Stage uses a single unchanged frame of the owner-approved repository idle character sprite. No new animation clips. No external/proprietary JX or Source A assets.

## Five-stage art choreography
- Charge 0.12–0.83s: restrained caster jade motes and core.
- Flight 0.83–1.63s: ONE flowing snake with tapering tail, green-jade body, nearly white hot spine, lavender aerial feather; nine distinct wavering poses.
- Wrap 1.53–2.22s: ONE serpent spirals around the target body. Twelve evolving silhouette poses, paired eye highlights, one localized light bloom.
- Squeeze 2.22–2.85s: modest contraction, no fake DoT tick.
- Dissolve 2.85–3.48s: continuous fading serpent with seven sparse pollen motes, no persistent decal.

Materials: original whole-path Gaussian distance-field masks baked into ImageTexture once at startup, two additive Sprite2D maximum; no Line2D corner wedges or assumed Forward+/HDR bloom. Performance: preload creates 21 small masks and needs profiling on target Android. Character remains a static 2D stage reference, not a skeletal rig.

## Required exact-SHA QA
Official Godot 4.7.2 Compatibility strict import, parse, focused contract and genuine --write-movie 1280x720. Ten timestamps 0.30/0.76/0.98/1.22/1.54/1.75/2.07/2.42/2.91/3.24, plus filmstrip. Review 8+ phases visually, repair hard light edges, weak head silhouette, clipping, target alignment and fade. Engine/source tests and movie are NOT PASS until actual runner confirms. Fixed 60 encoded FPS is not physical hardware FPS. Current gate OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD / V6.3 OFF / Windows-Android PENDING_USER.

## Exact-SHA Godot QA and artistic revisions — 2026-11-13

Owner approved Cửu Thiên Lôi Kiếp R4 light MATERIAL, not this serpent skill. Current Xà Ảnh Quấn Mạch art gate is OWNER_VISUAL_PENDING; independent lab only, PvE HOLD.

Native engine test SHA: 2dbfafcf051c1d9ece33c17667af86d62894b88d.
Official run: https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43472577846
Artifact: vfx-poi01-xa-anh-2dbfafcf051c1d9ece33c17667af86d62894b88d (ID 14060279695).
Godot 4.7.2.stable.official.ed1daf0bf, SHA256 pinned; GL Compatibility via Mesa llvmpipe virtual Linux renderer. Strict import PASS; script parse PASS; focused test VFX_POI01_FOCUSED_RESULT=PASS failures=0. Genuine Godot --write-movie at 1280x720, 255 frames at encoded 60 fps, duration 4.25 seconds. 10 checkpoint images 0.30/0.76/0.98/1.22/1.54/1.75/2.07/2.42/2.91/3.24 and 20-frame filmstrip saved in workflow artifact. Fixed-fps recording is NOT physical measured FPS.

| Iteration | Tested source SHA prefix | Workflow run | Technical result | Artist self-review |
|---|---|---|---|---|
| R1 | e90bdac8 | 43469584195 | PASS | REJECTED: noodle and heavy neon ring |
| R2 | 3fa62a54 | 43470478563 | PASS | REJECTED: over-bright body contact |
| R3 | 833e0469 | 43471258343 | PASS | Improved contrast; wrap remains ring-like |
| R4 | 86c34c17 | 43472078248 | PASS | Open coil; head overly circular |
| R5 | 2dbfafcf | 43472577846 | PASS | Long cobra head, pointed muzzle, smaller eyes; candidate for owner review |

Actual native Godot frames and same-clock R2/R3 and R4/R5 videos were inspected before retaining R5. Subjective R5 score /5: silhouette 3.5; soft luminous material 4; motion 4; composition 4; contact 3.5; fade 4. Some residual stylized luminous-ribbon shape and static actor sample mean this is NOT yet a production-integrated asset nor owner-approved finished art.

Strict scope boundary: exactly 5 new isolated VFX laboratory/document/test/workflow paths versus original head 025a52a1, and iterative modifications confined to VFX lab script/test. No damage, hit, HP, real target selection, DoT/status, Combat V2, V6.3 gate, SaveService, PvE, economy, or AI modifications. No rig. No unlicensed external art.
Windows and Android physical QA, crowded combat performance and live event-driven PvE presentation remain PENDING/HOLD. Unrelated v63-quyen-doc-matrix CI failure is not proof that this focused VFX test failed; no FULL game QA was claimed.

## OWNER VISUAL REJECTION — 2026-11-13 (supersedes R5 self-scoring)

Owner explicitly rejects the visual appearance of VFX-POI-01 R1-R5 as extremely poor. **R5 is ART_REWORK_REQUIRED / OWNER_VISUAL_REJECTED**, regardless of focused Godot PASS. This is not a release candidate, not a style source, and MUST NOT be reused as a template, color-only recolor, auto-enabled PvE effect, or mass-propagated to other skills. The earlier self-rating and 'candidate for owner review' are superseded.

Root-cause correction from owner: stop guessing geometric snakes and piling Gaussian glow. Study *actual reference frame sequences and motion* before implementation. Prefer original frame/flipbook/sprite-backed 2D silhouette, separated from softer light and contact particles; a luminous head alone does not make an animal silhouette.

Verified reference assets already in PR #72, with provenance caveat:
- `docs/operations/vfx_reference/TMB_VFX_Lab_4Skills_ORIGINAL.html`: owner-provided **U Minh Độc Xà** has dedicated `drawSnake` and `vfxSnake` routines (28 sample points, traveling head/tail, separate impact timing); this is a historical visual reference, not proof of commercial-quality artwork.
- `godot/labs/combat_lab/combat_lab_vfx_v8_jian_serpent.gd` and `godot/labs/combat_lab/assets/poison_vfx/co_doc_gu_serpent.png`: earlier distinct cobra sprite, body/head/eyes/fangs; inspect actual mask and texture quality at 1x before choosing.
- `godot/assets/combat_v4/jx1_skill_fx/fx_manifest.json`: verified Wudu #63 *impact* 13 frames × 56 ms, but Wudu #63 is poison palm, **NOT** the exact 'Xà Ảnh Quấn Mạch' skill. Wudang #158 has 10 precast,17 cast,8 impact frames; those are distinct rhythm references, not snake art.
- `godot/assets/combat_v4/source_vl/vfx_manifest.json`: sword cast 36 frames × 30ms and hit 21 frames × 30ms, reference for event sequencing not a poison serpent.
- `docs/operations/VFX18_JX_SOURCEA_LIGHT_LANGUAGE_RESEARCH_20261113.md`: Unity Source A animation data is metadata/partial extraction, **NOT** confirmed finished runnable VFX. External JX/Kiếm Thế/VL raw sprites have rights **UNVERIFIED**; inspection/analysis only, do not redistribute them as original game content.

**New quality gate before ANY remake:** identify a specific reference video/frame sequence for *a serpent* (not just generic green combat), compile keyed timestamps at consistent scale, then create a NEW independent sprite-based/Godot prototype with side-by-side source/prototype video, one fixed target, and sample at native 1280×720. Do not alter R5 to hide this rejection with another glow parameter. No Godot R6, no art approval, no PvE integration is claimed by this rejection record. All combat/save/economy rules remain locked.
