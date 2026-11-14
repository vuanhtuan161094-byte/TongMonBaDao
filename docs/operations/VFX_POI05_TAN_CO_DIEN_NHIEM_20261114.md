# VFX POI-05 — Tán Cổ Diễn Nhiễm | ART-FIRST individual skill
2026-11-14 | PR #72 Draft | Owner visual pending | Source VL-grade original VFX study

## Exact canonical mechanic (verified from v63_human_combat_catalog.json)
- ID: tmb.skill.poison.co_doc.active_04.human, family tmb.skill.poison.co_doc.active_04, school Độc Tu, Cổ Độc branch, active, Human.
- effect=poison; shape=circle; radius=2.5; target_limit=3; range=7; cast_time=0.55; cooldown=12; projectile_speed=8; duration=7; poison_stacks=1. Candidate balance fields never altered.
- This movie is visually illustrative, NOT real poison, 3 actual hits, spreading real statuses, Combat V2 integration, or actual gameplay duration. No unauthorized handling of damage/HP/SaveService/economy/AI/V6.3.

## Differentiation from earlier approved skills
- Phụ Cốt Cổ is one beetle attaching an occult mark; Xà Ảnh uses one physical luminous serpent; Cổ Vụ Mê Tung has sustained painted fog around a circle. **Tán Cổ** uses a materially drawn jade/chitin chrysalis that physically bursts, releasing several separate small parasitic gu sprites, connecting three dummy targets through thin winding infection filaments and a compact bone spore-mark. No smoke-field art recycled and no giant static vector icon as the whole effect.
- New ORIGINAL alpha artwork (no third-party JX frames): 12 independently posed transparent 512px SVG material frames of a six-petal chitin gu cocoon, 4 original 256px beetle-wing poses, one separate occult talon infestation mark. Each imported as Godot textures, with sprite flipbooks and independent motion.
- Core style: cold jade-pale yellow highlights, black-violet chitin shadows, plum insets and restrained per-frame white-hot core. Strong readable body at 1×, modest glow accents, visible caster and targets throughout. *No skeletal rig*.

## Choreography and QA checkpoints
Phase 1 (0.00-0.55): a chitin egg closes/gathers in caster palm. Keep caster face clear.
Phase 2 (0.55-1.28): cocoon flies in shallow arc with reduced sprite-trail echoes. NO actual hit.
Phase 3 (1.28-1.82): original chrysalis sequence frames 3–11 burst open at target zone; 4 beetle-wing art poses create actual frame animation. Three preview targets appear as a geometric illustration, not 3 forced hits.
Phase 4 (1.82-2.86): small beetles spread along three asymmetrical curves, compact chitin marks on chest and open petals linger. Background infection filaments appear behind real dummy actors.
Phase 5 (2.86-3.64): all visuals fade, leaving no game status. 3.64–4.10 idle.
- Native checkpoints requested: 0.20,0.44,0.62,0.94,1.12,1.29,1.42,1.61,1.84,2.10,2.38,2.74,3.02,3.48 seconds. Evaluate video motion at 1280×720, inspect at 1× with targets readable; compare actual Cổ Vụ and Source VL cadence without copying source art.
- Godot 4.7.2 GL Compatibility, pinned sha binary, native --write-movie fixed 246 frames / 4.10 secs, MP4 faststart + animated GIF + QA evidence ZIP. `60 FPS` encoded is NOT real GPU/Android performance. Strict import, parse, focused test at exact tested commit.

## State and next
- Files: godot/labs/combat_lab/poison05/tan_co_dien_nhiem.gd + .tscn; assets/cocoon_00..11.svg, assets/spore_scarab_0..3.svg, assets/spore_infection_mark.svg.
- QA: godot/tests/labs/combat_lab/vfx_poi05_contract_test.gd, .github/workflows/vfx-poi-05-tan-co-dien-nhiem.yml.
- `GODOT_FOCUSED_PASS` only after official run; `ART_REWORK_REQUIRED` if actual visual below approved pilots; `OWNER_VISUAL_PENDING` until user approves; `PVE_INTEGRATION_HOLD` throughout.
- Automatically carry this status into docs/handoffs/VFX_CURRENT_ART_FIRST_NEXT_CHAT_20261114.md and NEXT_CHAT_HANDOFF.md for future chats. SOP V3 must remain highest art rule; no switching to batch SVG, no Codex or rig, no merge.
