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