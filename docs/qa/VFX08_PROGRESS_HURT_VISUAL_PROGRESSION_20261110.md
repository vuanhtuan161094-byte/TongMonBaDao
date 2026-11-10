# VFX-08 — Hurt, mastery, attack/cast speed, future beams & JX-style readability

PR #72 · existing branch only · 2026-11-10 · **experimental V4 Combat Lab**, V3/gameplay default unchanged.

## Source-backed audit (549 canonical V6.3 skill rows)

| Generation | Total skill rows | Poison rows | Gameplay projectile-count growth authored in catalogue? | VFX scope |
|---|---:|---:|---|---|
| Nhân | 105 | 35 | **NO** (no `projectile_count`, `shot_count`, `level_modifiers`) | 17 Human Poison basic/mobility/active/ultimate detailed art briefs |
| Tiên | 204 | 68 | **NO** | Motif art for all Immortal skills **NOT YET approved** |
| Thần | 240 | 80 | **NO** | Motif art for Divine skills **NOT YET approved**; catalogue has `divine_stage_multipliers` affecting approved battle behavior |
| **Total** | **549** | **183** | **NO** | Only scoped Human Poison V4 experimental |

**Mastery authority:** `V63HumanSkillCombatSystem.record_cast_mastery()` grants **+1 mastery_xp for one meaningful committed cast**, one level per 100 XP, cap **12 Human / 3 Immortal+Divine**. This is NOT currently a `+1 beam` gameplay rule. Status, hit count, cast target cap and radius stay solely in canonical V6.3.

**Real speed authority:** `effective_attack_stats` reads approved passive/innate/stat buffs; `CombatStatsV2.effective_interval` changes basic-hit cadence using `attack_speed`, while `_begin_cast()` computes wind-up from `cast_time / (1+cast_speed)`, cooldown from `cooldown / (1+cooldown_recovery)`, and flight from world distance / original projectile_speed. No independent clip-length or duplicate damage shot.

**Existing visual faults found:** existing `hit` event forced target `hit` animation for EVERY damage, including dots; Poison atlas contains source Hit ~2.4s and Attack ~2.6s; Cast pose previously held through **wind-up + projectile flight**, not just wind-up. Those policies visibly lock scenes with 4v8 or more.

## Implemented VFX-08 API and rules

- `combat_lab_arena.gd`: normal damage/poison tick keep locomotion/cast state; only committed `status_applied` with `stun|freeze|knockback|knock_up|stagger` allows 300ms hurt. Death still gets its own clip. Attack pose is shortened to 105–540ms based on current effective attack/cast haste. The Poison cast pose is limited to the actual authored wind-up, **not** projectile flight.
- `combat_lab_vfx_progression.gd`: keyed by approved skill and actual learned `DiscipleState.v63_learned_skill_nodes[skill_id].level`; fallback level1 when absent. Human AoE needle silhouettes use **5 at Lv1 / 6 at Lv6 / 8 at Lv12** cosmetic strands. The authoritative projectile count stays **1** without a catalogue field; the 3-target radius-3 limit stays intact. Single-target skill remains 1 main projectile regardless of decorative sparkles. Immortal/Divine mastery is clamped to 3 pending owner approval of their art.
- Crowded 4v8/30v40 display degrades optional decorations at 14+ simultaneous visible cues; 28+ reduces detail further (max 5 fan strands) while **never** removing hit/status receipts or the true skill area boundary.
- `combat_lab_v4_spell_spark.gd`: original self-authored tiny procedural RGBA radial sprite, additive `CanvasItemMaterial` on **bounded GPUParticles2D**. One-shot bursts ONLY on committed positive poison `hit` or `heal` (never DoT/cast/fictional impact), max 10 concurrent emitters, 5–9 particles/emitter (at most 90 allocated particles in this narrow preview path), auto-free when finished. Enabled only in `TMB_POISON_V4_CINEMATIC=1`, never ordinary V3 production.
- `poison_v4_growth_reaction_test.gd`: in-memory real Lab battle and synthetic presentation event fixtures verify zero hurt for hit/tick, short CC response and haste cast/windup, mastery decorative scaling, and source AoE/target cap unchanged.
- `poison_v4_video_capture.gd` + workflow: record genuine **novice** and QA-only **Mastery XII + haste** versions of the same 4v8 skill in Godot Movie Maker, 1280×720 24fps. QA master creates only in-memory DiscipleState and modifies cast/attack speed of actors in temporary battle; explicitly no Save writes. It is NOT a player-facing progression unlock.

## External visual research and legal limits

- Classic Kiếm Thế combat examples: https://kiemthe.vnggames.com/su-kien/ban-cap-nhat-thang-01-503/tieu-dao-coc-truyen-ky.html — visual reference only; do not copy game sprites/atlases.
- Riot VFX guidance: https://www.riotgames.com/en/artedu/visual-effects and https://www.leagueoflegends.com/en-us/news/dev/clarity-in-league/ — communicate danger/hitbox, prioritize CC/ultimate vs small attacks, avoid unbounded flashes in group combat.
- Godot GPUParticles2D: https://docs.godotengine.org/en/stable/classes/class_gpuparticles2d.html — count/one-shot/fixed FPS/interpolation; never claim `amount_ratio` alone eliminates GPU cost.
- REEBOO 2D VFX Lite, **MIT**, https://godotengine.org/asset-library/asset/5564 — suitable hit-spark structure; VFX 2D Free, **CC BY 4.0 with required credit**, https://godotengine.org/asset-library/asset/5496 . **Neither third-party addon was copied or installed**: own minimal GPU spark is license-clean. Consider external packs only after actual Godot import/performance/style review and ownership approval.

## Future mechanic contract (DESIGN ONLY, not implemented)

If gameplay eventually awards +1 projectile or more targets at higher skill level, add an approved, explicit field in real skill definition / effective skill resolver (e.g. `projectile_count_by_level`) and emit committed per-shot/per-hit IDs. The VFX consumer must read only that effective **authoritative** count from combat events, use a small capped per-shot trail, and render **no new hit** merely because there is more decoration. Never use `target_limit` as `projectile_count`. Approval is required before changing balance or Save schema.

## Outstanding gates

- Official Godot 4.7.2 exact-SHA build, updated legacy no-hurt test, focused+549-skill cumulative, 12 videos including Mastery XII comparison and captured still frames; **PASS only after logs and actual videos**.
- Real Windows and Android FPS/RAM/Hurt stress, 4v8, 30v40, 480-disciple simulation remain **PENDING measurable device runs**. Do not confuse fixed animation cadence with proven FPS gains.
- Only 1 authored 3/4-right plus mirrored-left Poison female atlas is verified; owner-approved **final four-direction character source still missing**; never call this final.
- Aesthetics at 1× not owner-approved: **PARTIAL** until side-by-side videos match the chosen mockups.
