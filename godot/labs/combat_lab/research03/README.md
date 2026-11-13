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

### R2 alignment correction (observed in actual 1280×720 Godot frame)
- Original R1 screenshot at 1.55s exposed a **detached curved tail**: the 2D `ColorRect` local positioning/rotation did not visually align its luminous shader tip with the cubic flight path drawn by CanvasItem.
- Replaced the shader UV carrier with an original in-memory all-white **4×4 texture** on centered `Sprite2D` (pure shader light, no painted image). Sprite tip is now calculated explicitly in centered Node2D coordinates, leaving all game mechanics unchanged.
- Added focused contract assertion `carrier.to_global(local_tip).distance_to(STUDY.flight_head(progress)) < 0.65 px`; must pass on real Godot exact-SHA QA before art presentation.

## VFX18.1 art-directed pass (2026-11-13; see separate art brief)
- Five curved and time-moving gathering filaments replace flat parallel charge lines; single energy only, one approved mock victim.
- Flight trail no longer has constant-width/constant-opacity strokes. Its sampled segments have a tapered, soft falloff; hot tip remains anchored by prior R2 pixel contract.
- Small five-ray incisional hit splinters plus tightened original local contact shader replace weak contact; no new combat/hit/target owner.
- Orbit changes from entirely front-layer sprites to actual two-depth-stage presentation: a standalone node `orbit_actor_overlay.gd` is between back and front orbit streaks. No fake AOE; 16 decorative light streaks remain.
- Focused test now verifies front and back visual strata, caster overlay, no impact from orbit mode, previous tip-to-route 0.65-pixel contract.
- Review only after Godot 4.7.2 exact SHA fresh full-motion movie; `OWNER_VISUAL_PENDING / PVE_HOLD`.

### VFX18.1 R1 manual frame fix
At 0.36s in the first real video (focused success 72537344), most charge filaments were still hidden within the rig; single-qi flight at t=1.55 and hit at 2.43 were inspected and retained. R1 moves three light filaments outward to the right of the hand and two left, strengthens narrow hot white convergence, and labels the LAB image as VFX18.1. Added charge-source geometry contract; exact Godot rerender required.

## VFX18.2 R0 original light art iteration
Art script was committed first: `docs/operations/VFX18_2_ART_STORYBOARD_20261113.md`. **Studio LAB only**, never enable or copy JX/Source A proprietary pixels.
- Rewrote `light_contact_2d.gdshader` as a rapidly advancing white-hot diagonal incision with continuous Gaussian blue falloff, followed by a time-separated weaker counter-shear. Replaces tiny short mark; still centered on exact single approved mock contact (not monster center). Small six directional splinters, no circular screen bloom, no new gameplay event.
- Reworked charging streams as five moving pulses along genuinely cubic energy paths, layered white core / cyan sheath / faint cobalt corona; energy converges at caster rather than drawing permanently bright straight strokes.
- Added `light_orbit_aurora.gdshader`: a restrained original *angle-gated* irregular elliptical underglow with two animated phase lobes, no source sprite. Rendered on an in-memory 4×4 white carrier behind the actor; only in orbit study mode, never single.
- Added `curl` to shader to give existing orbit qi blades delicate active tip deformation while preserving the original single-qi static-rigid attack axis; plus 8 low-contrast moving historical wakelets. Still precisely 16 original decorative streaks, both back and front modes.
- Focused QA checks three original shaders, one mock contact, 16 capped main strands, aurora only in orbit and behind actor, existing exact shader tip/path subpixel contract.
- **Art gate:** do not call this owner accepted before looking at real native Godot 1280×720 movie across all charge/flight/contact/fade/array phases and comparing to VFX18.1.
