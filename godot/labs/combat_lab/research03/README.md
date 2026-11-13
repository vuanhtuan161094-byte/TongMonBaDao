# VFX18 LightCore2D — GODOT LAB visual-candidate (research03)

This packet implements the owner's request to *automatically apply*
[.agents/skills/tmb-vfx-art-director/SKILL.md](../../../../../.agents/skills/tmb-vfx-art-director/SKILL.md)
following the independent research
[docs/operations/VFX18_JX_SOURCEA_LIGHT_LANGUAGE_RESEARCH_20261113.md](../../../../../docs/operations/VFX18_JX_SOURCEA_LIGHT_LANGUAGE_RESEARCH_20261113.md).

## Art brief (five stages, prepared before code)
Source: owner-supplied 2.5D blue-white swirling qi image, current TMB V9 dynamic-light serpent/lightning, JX1 Wudang #158 triple stage, Source VL \`lighter\` compositing. Original light maths only; zero third-party skill images or code reused. In all mock previews: actual Combat V2/V6.3 hit/HP/target is NOT modified.

- **Charge** (normalized 0–0.255): three short strands gather near caster hand, white pinpoint at intended origin, not a blocking circle.
- **Release** (0.255): sharpen core, accelerate naturally, directional stroke visible at native 1×.
- **Travel** (0.255–0.744): ONE energy-blade from analytic Gaussian taper and white hot line; cool-blue wide soft falloff; 2 soft, moving rear ribbons. Curved Bézier route. Gradually vanishes before monster silhouette; no metal sword, hilt, faceted polygon, fixed coil.
- **Contact** (0.744–0.824): one short directional slash, localized white/cyan peak, with strict pre-contact tip at victim + (-40,-34). NO false DoT/HP changes. Scene events are mock, never claim actual game hits.
- **Dissolve** (0.824 onward): no blade, no persistent giant flash.
- **Orbit mode** (1–2 complete rings of animation): 16 intentionally uneven decorative LIGHT streaks, opposite angular speeds at projected ellipse radii 190×120 and 239×150, transparent center and weak fragmented ground atmosphere. **NOT an AOE or 16 real attacks.** Unlabeled static view must resemble a circulation field, not 16 metal swords.

## Original implementation files
\`light_core_2d.gdshader\`: non-texture light blade, Gaussian hot core, soft blue/cyan sheath, flowing rear ribbons.
\`light_contact_2d.gdshader\`: short oblique incisional spark, not giant disk.
\`research03_arena.gd\`, \`research03_arena.tscn\`: separate 1280×720 LAB; modes key 1 one beam / key 2 orbit; SPACE replay and P pause. R1 replaces the distracting diamond-shaped Source A courtyard test image with original fine low-contrast gravel; uses existing actor rig. No source-game sword/FX texture imported.
\`godot/tests/labs/combat_lab/research03_contract_test.gd\`: local mock animation, 16-shard cap, no contact except one approved mock target, precontact stop, 2 shader resource checks.

## Mandatory QA gates
1. Official Godot 4.7.2 GL Compatibility strict import & parse & focused exact-SHA contract, capture logs.
2. Real native 1280×720 60fps *encoded* (not device FPS) movie for SINGLE and ORBIT and old V14.2 baseline; sample 8+ phases, no hidden offscreen sprite.
3. Inspect screenshots/filmstrip; contrast with owner's reference at 1×; where hard edges/blank orb/occlusion/weak contact appear, modify original art before owner review. Keep self-score and timestamp findings.
4. Distinguish focused PASS vs clean full-repo PASS: isolated workflow historically applies uncommitted upstream summon parse shim; other workflows may remain red.
5. Freeze explicit status OWNER_VISUAL_PENDING and PVE_INTEGRATION_HOLD. Windows/Android physical PENDING USER. A source rights issue is never resolved by generating an apparently similar sprite.

## R1 artist iteration after first genuine Godot movie review
- First video at code SHA `19408d4d58` / workflow `e2539cb4b2` returned Godot strict+focused **SUCCESS** (run #43393224687). **Not owner art approval**.
- Examined actual full 1280×720 frames and both timeline sheets. The single sword-qi shader is light (no steel) and the orbit is truly animated, but the giant grey diamond courtyard background dominates, the single qi lacks fluid path-wake, and 16 orbit needles still read too separately as line segments. An ART_REWORK_REQUIRED note, even with technical PASS.
- R1 modifies only original LAB scene `research03_arena.gd`: remove the giant courtyard texture; add static textured gravel; draw a softly feathered, history-sampled curved flight tail and moving orbit-history ribbons beneath the actor and analytic core/halo shader. Same approved mock target only; no new contact/damage. Re-test exact SHA, inspect real artifacts again.
