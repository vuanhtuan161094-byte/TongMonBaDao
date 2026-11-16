# POISON BASIC HUMAN R2 — Genuine transparent RGB+alpha source, GIF-motion reference ONLY

## Canonical lock
Skill `tmb.skill.poison.basic.human` / **Độc Châm Thường Thức**, Human basic, `damage` element `metal`, single_target cap1, range6, cast0, cooldown1.6, projectile_speed12, damage_ratio1, duration0, poison_stacks0. No inferred hit_count or poison DoT. V6.3 remains OFF. Actor/monster/HP authority untouched.

## Owner art correction
Owner rejected old direct GIF cutout (bad transparency, muddy pigment); **the GIF is only 8-frame motion inspiration**, never a pixel source. Repainted independent FIRST-PARTY code-painted floating-point RGBA:
- Source generator `tools/vfx/generate_poison_basic_human_v2.py` and 9 retained genuine RGBA transparent key master PNGs under `godot/labs/combat_lab/poison_basic_human_v2/assets/master/`.
- Atlas `assets/atlas/`: charge 6x 192², flight 8x 288×160, contact 8x 256² = **22 separately authored true alpha poses**. The original vivid cyan-jade/purple RGB stays full-spectrum even in low-opacity pixels, no black poster matte or GIF indexed transparency. Core small pale-white and semitransparent separated pigment ribbons.
- Animated 1× use: one short charge swirl from palm, one needle with 4 curved wispy tails pointing toward moving locked demo enemy, one *local* burst on the enemy and fade; NO poison status. One RIGHT source atlas rotated to `(target-launch).angle()` for any direction (not four separate VFX sheets).
- Independent GIF/storyboard preview is neither a native Godot screenshot nor imported actor. Pre-existing approved Poison character fixture remains unchanged.

## Three clock distinction
The authoritative Combat basic attack `cast_time=0`, `cooldown=1.6s`, projectile speed12 world units; **no real Combat V2 receipt mapping has been authorized**. LAB-only animation: cosmetic anticipation `0–.15s`, projectile `.15–.68s`, visual contact/fade `.68–.99s`; demo loop `1.28s`. The short prefire is visual garnish, NOT a reinterpretation of zero cast or damage settlement. All target contact in LAB is mock, not real HP event.

## G3.5 V4.2.1 mandatory acceptance
Godot 4.7.2 GL Compatibility exact-SHA native 1280×720, charge t=.08, peak t=.42, contact t=.78 on moving WALK monster, source–native match and alpha integrity; 4-cardinal aim vector test; strict import/parse/focused plus source provenance and SHA; whole short demo ~1.22s. No owner art PASS before actual human review of native media. Invalid if dull/muddy/hard square or if generated GIF caster appears in game.

**INITIAL GATES:** `G3.5_NATIVE_PENDING` / `TECH_QA_PENDING` / `ART_SELF_REVIEW_PENDING` / `OWNER_VISUAL_PENDING` / `PVE_INTEGRATION_HOLD` / `PHYSICAL_QA_PENDING`. No rig/Codex/new branch/merge/gameplay changes.

## R2 V4.2.1 actual Godot G3.5 technical QA and human visual handoff (16/11/2026)

- **Exact native source:** `cc2cd098a3ffa00ad0428ea55a06ee0d98f6d20b`, [Actions #43854861982](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43854861982) **SUCCESS**, artifact #14220776753; Godot **4.7.2 Compatibility**, strict import / parse / focused `VFX_POISON_BASIC_R2_RESULT=PASS failures=0`, packet/assets/evidence technical `PASS`. Movie **1280×720, fixed 60 encoded FPS, 73 frames, 1.216667s**. GIF/extracted image still is NOT the input texture; sprite source came from `tools/vfx/generate_poison_basic_human_v2.py`.
- **Traceable original artwork:** Source Python code, 9 true RGBA transparent painted pose masters and 3 separate original RGBA flipbook atlases committed under `godot/labs/combat_lab/poison_basic_human_v2/assets/`. **6 charge + 8 dart flight + 8 impact = 22 authored key poses, 4,751,360 raw RGBA8 bytes**. Nine master PNGs plus full source algorithm are durable and independent of expiring Actions artifacts. V4 source manifests and SHA256 native media proof are in artifact.
- **Three native evidence frames:** charge t=.08s, flight peak t=.42s, moving-monster local chest contact t=.78s; 16 timestamps over full native clip checked: .05/.10/.16/.25/.34/.42/.50/.61/.67/.73/.79/.88/.98/1.06/1.15/1.20. One projectile to one visibly WALK-animation monster and correct left/right/up/down vector unit tests. No artificial Combat V2 HP/status receipts.
- **Human self-art review, NOT owner approval:** original jade/teal-purple luminance stays translucent on dark and bright background; independent soft pigment and hot pale central highlight, no black rectangular backdrop, old GIF character absent. At native scale reads as a compact basic projectile (deliberately less spectacular than an ultimate). The charge appears slightly to the caster's right rather than perfectly attaching to the hand; tip/impact can be visually polished if owner requests. This is a candidate **for owner review**, not a self-asserted final art PASS of all disciplines.
- **Current gates:** `V4_G3.5_GODOT_TECH_PASS`, `RGBA_ORIGINAL_ASSETS_COMMITTED`, `ART_CANDIDATE_OWNER_REVIEW`, `OWNER_VISUAL_PENDING`, `RUNTIME_MAPPING_PENDING`, `PVE_INTEGRATION_HOLD`, `V6.3_OFF`, `PHYSICAL_QA_PENDING`.
- Debugged QA: stock V4 validator originally required `0 < catalogue cast_time`, which was impossible for this instant basic. Corrected strict zero-cast branch requiring an explicit `cosmetic` versus `cast` warning, without changing any gameplay timing. The last contact frame was initially fully transparent and got an independently visible faint final key pose; explicit Godot 4.7.2 `Vector2` inference in four-way tests was fixed. Only the final exact-SHA Actions success above is technical acceptance.
