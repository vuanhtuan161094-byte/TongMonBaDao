# VFX-POI-03 | Phụ Cốt Cổ — bone-anchoring spirit gu
2026-11-14 | PR #72 Draft | owner ART review pending | real PvE HOLD

## Skill truth
Exact Human ID: tmb.skill.poison.co_doc.active_01.human. School=poison; branch=co_doc; slot=active; effect=mark; shape=single_target; target_limit=1; range=7.5; cast_time=0.45; cooldown=10; declared mark duration=6 seconds. SOURCE VALUES READ ONLY. Never turn animation into extra damage/DoT/slow/summon; Combat V2/V63 own all effects/ownership/lifecycles. Isolated LAB has one demonstration dummy and never applies mark to gameplay.

## References and art source
- Benchmark: the owner-approved four-pose Xà Ảnh Quấn Mạch POI-02 Godot scene. Preserve its style quality but DO NOT reuse/recolor the serpent. New gu needs its own identity.
- Source VL sword 150: study layered sprite material and movement only; this is not a gu sprite.
- JX1 Wudu #63 13x56ms impact frames from fx_manifest.json are private LAB poison contact accent, not the bug body. Rights for external redistribution remain unverified.
- ORIGINAL SVG sprite 512x512 in assets/fu_cot_gu_master.svg: winged gu beetle with mandibles, eyes, segmented shell, six legs and painted jade/violet highlights. No rig.
- ORIGINAL separate 512x512 bone gu seal sprite in assets/fu_cot_bone_seal.svg. Core graphic is a mark, not an implied gameplay status effect.

## Six phase visual storyboard
1. 0.00-0.45 charge: insect silhouette takes shape above caster hand, subtle jade energy.
2. 0.45-0.60 release: winged beetle rotates toward a single dummy, distinct from poison snake.
3. 0.60-1.15 first flight: short sprite ghost trail, arcing motion, main insect stays distinct.
4. 1.15-1.55 approach: actual beetle silhouette grows slightly before hitting target.
5. 1.55-2.60 contact: original bone seal sprite appears on target torso, JX Wudu impact on contact only.
6. 2.60-3.12 release: mark art fades into motes, then 3.12-3.60 idle. Real declared mark duration 6s is NOT the same as this artistic preview length.

Scene: res://labs/combat_lab/poison03/fu_cot_co.tscn. Test: res://tests/labs/combat_lab/vfx_poi03_contract_test.gd. Workflow: .github/workflows/vfx-poi-03-fu-cot-co.yml.
Godot 4.7.2 GL Compatibility 1280x720, fixed export 216 frames / 3.60s. Inspect 8+ phase PNGs, real video and no sprite clipping/ghost target, remove glow if it obscures shape. OWNER_VISUAL_PENDING until the actual movie is reviewed. PVE_INTEGRATION_HOLD; never edit combat, HP, targets, SaveService, economy or V6.3. No Codex, no rig, no mass-production.
## Executed Godot native R1 → R3 art iteration — 2026-11-14

R1 code SHA `d98886161b8e68b6b973c81be2f3ac8890c21885`, [official run #43550311572](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43550311572): engine import/parse/focused PASS, genuine native movie. Actual observed frame at 0.38s had beetle sprite overlapping caster face; contact at 1.70s placed gu bone seal across the target's face. **R1 ART REJECTED** despite technical PASS.

R2 code SHA `a8749b7d86727271fc8a07b1a652028bfb2b52d5`, [official run #43550777107](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43550777107): focused PASS and native movie. Moved gu release to caster's hand side and lowered contact mark to target torso. R2 still had a **large opaque circular seal** hiding much of the victim's chest/body: ART REWORK REQUIRED.

R3 code SHA `7585287a584fdbc5525a8b45028cfab8d8b14869`, [official run #43551047833](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43551047833) **SUCCESS**: Godot `4.7.2.stable.official.ed1daf0bf` GL Compatibility on Linux Xvfb/Mesa, strict import, script parse, `VFX_POI03_FOCUSED_RESULT=PASS failures=0`; *actual* Godot movie **1280×720, 216 frames, 3.60sec** at fixed encoded 60fps. This is NOT physical Windows or Android measured FPS. Artifact `vfx-poi03-7585287a584fdbc5525a8b45028cfab8d8b14869` GitHub artifact ID `14096840241`; 14 same-clock native PNG phase captures, filmstrip, movie, SHA256SUMS and import/parse/test logs.

**Observed R3 frames**: 0.38s charge stage sprite clear of caster's face; 1.20s independent gu wings, segmented shell, legs and visible head in flight; 1.43s near target, sprite remains distinct; 1.70/1.95/2.19s smaller translucent bone-mark sprite centered on torso rather than face, target remains readable; 2.49s mark holds, then 2.73–3.04s dissolves. No fake Combat V2 hit, extra proc or persistent gameplay mark.

**Art assessment (independent of QA PASS)**: silhouette ~4/5; main texture/lighting ~3.5/5; motion ~3.2/5 (single sprite with short echoes, not a fully authored wing-beat flipbook); contact ~3.6/5; clean fade ~4/5. R3 is a **genuine playable standalone Godot VFX LAB review candidate**, but **NOT yet owner-approved/Source-VL-parity artwork**. Next art revision if owner requests: multi-frame wing animation with stronger chitin movement/impact and test at map clutter. Do not preemptively change approved Xà Ảnh art.

**Current release gates**: `GODOT_FOCUSED_PASS / OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD`. All other 2,195 skills unaffected, 12 school catalogues still disabled, V6.3 OFF. JX1 commercial contact art remains rights-unverified for redistribution. No rig, Codex, new branch/merge, combat/HP/target/SaveService/economy edits.
