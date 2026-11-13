# Professional VFX QA — technical PASS is NOT art acceptance

## Pre-code gate
- Re-read latest owner decisions and actual input screenshot/reference. Separate light sword qi from literal metal sword. Decide visual family, output phases, targets, ground/actor layers, and source/rights.
- Write mini art brief and 8-frame storyboard before code, with one or two distinct prototype strategies. No unbounded generation of 9 identical sword shapes.

## Technical evidence
- Exact live Git SHA, changed paths/scene ID, Godot 4.7.2 GL Compatibility version, 1280×720, official headless strict import/parse, focused and impacted regressions. Never claim FULL clean PASS when CI uses checkout-only parse shim, and disclose source unrelated failures.
- Actual 1280×720 MP4 from Godot: fixed encoded 60FPS is **not** measured GPU FPS / physical Android performance. Review ≥8 timestamps covering charge, formation, release, early/late flight, near-contact, confirmed hit, dissolve.
- Same-camera synchronized 1× baseline and new candidate frame strips + side-by-side MP4. Cropped closeups are optional supporting material, not primary proof.
- No effect-generated false hit, HP, target, DoT, cleanse, heal, summon, reward or save mutation. Visual impact only after real event. Check repeated snapshots do not double fire.
- Test 1 caster/1 victim, 3 target positions, 6v8, and eventually 30 disciples / 40 monsters before mass enable. Include dark/bright background and actual Source A-esque actor rig, not only gray debug scene.

## Human art rubric (self-score 0..5, never substitutes owner approval)
1. 1× silhouette: recognizable without label/zoom; correct family.
2. Real luminous material: continuous soft light falloff and strong narrow core, not static polygons.
3. Choreography: intention, anticipation, acceleration, leading tip/tail lag, honest arrival.
4. Composition: asymmetric sizes, contrast/readable hero, no 12 equally strong objects.
5. Contact: visually clear short peak on authorized target, no sword penetrating monster chest.
6. Fade: natural energy breakup/disperse; no static stripe or UI ellipse stuck on map.
7. Skill uniqueness: visually distinguishes element and skill type, not just hue reskin.
8. Performance/readability: LOD and native 1× crowd readability demonstrated and measured when requested.

Self-review goal **each of 1–6 ≥4/5** before recommending owner review, with explicit defects and timestamp otherwise. This is an internal heuristic only; the OWNER decides artwork. If a core criterion fails, redesign source silhouette/gradient/motion instead of simply increasing glow. Do not call art approved from CI success.

## Status labels
`SOURCE_VERIFIED` | `RIGHTS_UNVERIFIED` | `ART_BRIEF_READY` | `CODE_LAB_READY` | `GODOT_FOCUSED_PASS` | `FRAMES_REVIEWED` | `ART_REWORK_REQUIRED` | `OWNER_VISUAL_PENDING` | `OWNER_VISUAL_APPROVED` | `PVE_INTEGRATION_HOLD` | `PHYSICAL_WINDOWS_ANDROID_PENDING`.

Do not bundle them into one generic DONE or PASS.
