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
