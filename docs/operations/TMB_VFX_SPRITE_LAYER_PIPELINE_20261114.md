# TMB SPRITE + FLIPBOOK + VFX LAYER PIPELINE — 2026-11-14

## Owner decision / applicability
New cross-school **art production method**, approved as a direction after Talisman TAL01 R5. Applicable to all school LABs; **not** universal artwork. Read `AGENTS.md`, `docs/operations/TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md`, `docs/operations/TMB_VFX_SPRITE_FIRST_QUALITY_RULES_20261114.md`, the canonical skill record and the matching school's owner-approved reference. SOP V3's **one genuine master at a time** remains in force. No rig, Codex, commercial JX/Source VL asset copying, new branch, merge or enabling V6.3/PvE.

## Why R1–R3 failed and R5 improved
A thin parchment rectangle with a few glowing code lines lacks material hierarchy and reads as notebook paper. R5 used a distinct original 12-pose **painted talisman** sprite (frayed silhouette, luminous ink, gilt edge), a separate white-violet lightning conductor with head/body/tail contrast, and an independently authored impact burst texture. Real Godot 1280×720 reviews exposed the difference. R5 is the **owner-preferred sprite-based direction**, **not** a blanket artistic PASS for all effects and certainly not a reusable sprite to recolor.

## Actual workflow, gate by gate
1. **Read reality**: one exact skill ID, tier and branch; effect, shape, target cap, cast/cooldown/range/projectile speed/duration and real Combat V2 event/receipt boundaries. Never create extra hit/mark/DoT/guard/heal/summon by decorative VFX.
2. **Draw hero asset**: an original painted prop, creature, spell form, qi blade or stamp that can stand alone; choose a coherent silhouette, subtle material noise, foreground edge, internal texture, bright focal core and secondary color. Record origin and rights. If no physical prop fits a skill, use a fully painted luminous form.
3. **Create true motion frames**: 8–16 expressive 2D poses/flipbook keyframes for development; different contour, brush strokes, deformation, light reveal or silhouette. Preserve transparent alpha/pivot and document atlas dimensions/coordinates/frame order. Single SVG rotated/recolored is not a flipbook. Frame-count is a production guide, not a gameplay parameter.
4. **Separate effect layers**: a) hero, b) magic seal/ground atmosphere when justified, c) concentrated emission/beam, d) sparse secondary filaments, e) contact burst gated by real hit, f) fading mist/motes. Treat each layer's timing, blend and occlusion independently; avoid permanent additive whiteout. Godot Control/Sprite2D/CPUParticles2D/shader are tools, not replacements for weak art.
5. **Orchestrate spatial anchors**: ground seals belong **below feet and behind the actor** (elliptical perspective); hand seals float at the correct palm; impact beneath feet or on the body as appropriate; glowing source must connect to the traveling head. No accidental overlay over face. Avoid multiple equally bright concentric rings.
6. **Respect 2D batching**: independently authored raster atlases PNG/WebP with clean transparent pixels; mipmap/filter as useful; fewer texture changes and short-lived particles, local bounds, no global flash, LOD for 6v8 and 30 vs 40. GL Compatibility required. Performance numbers remain PENDING unless physically measured.
7. **Native render loop**: genuine Godot 4.7.2 GL Compatibility scene, 1280×720 MP4+GIF, 8–14 phase stills on actual scene, strict import/parse/contract exact-SHA. Check full-motion and pixel-scale silhouette on dark and bright map; iterate on obvious defects. Fixed encoded FPS does NOT certify physical framerate.
8. **Separate gates**: CODE_LAB_READY, GODOT_TECH_PASS, ART_SELF_REVIEW, OWNER_VISUAL_PENDING/APPROVED, PVE_INTEGRATION_HOLD. Do not publish a QA PASS as art approval; only the owner can approve visual art.

## VFX layering decision table
| Mechanic | Hero | Underfoot array | Contact | Forbidden |
|---|---|---|---|---|
| Single-target lightning | illuminated talisman + one main white-violet current | restrained short **caster-only** charge | confirmed one-target impact | fake chain/AoE/status |
| Line damage | long brushed current/ribbon | caster seal at cast if useful | hits only along declared line/target cap | expanding circular AoE |
| Mark/stamp | rune/seal icon | optional caster scribe shadow | visible stamp on real target when mark receipt exists | damage-looking explosions/ticks |
| Ultimate line lightning | monumental forged seal + one primary bolt, rare branches | larger short-lived ritual base | only declared maximum targets | generic multi-hit storm |
| Passive/innate | event-local proc glint | none by default | only when real receipt arrives | fake cast animation |

## Portable source/evidence packet
Place the skill's `*.gd`, `*.tscn`, original transparent master/atlas, provenance, focused test, Action workflow, and QA images under distinct school names. Suggested structure:
`godot/labs/combat_lab/<school><NN>/assets/` + `README.md`; `godot/tests/labs/combat_lab/vfx_<school><NN>_contract_test.gd`; `.github/workflows/vfx-<school>-<NN>.yml`.
Use `docs/templates/VFX_SKILL_ART_FIRST_TEMPLATE.md`. Never alter another school's paths from one production chat.

## Audit/known limitations
The owner specifically prefers the **technique** of R5: original sprite master plus atlas/flipbook and separately timed effects. R5 displayed a small stand-in caster, plain terrain and an insufficient caster ground seal; TAL01 R6 adds original ritual ground art according to this guide. The new support seal is **supplementary**, not permission to mass-produce geometry-only skill VFX. All original copyrighted concept references are used only for *visual study* and must not be shipped as extracted pixels.
