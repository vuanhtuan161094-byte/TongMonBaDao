# TÔNG MÔN BÁ ĐẠO — PR26 → D7/COMBAT V3/UI: RECOVERY REVIEW (2026-10-24)

**Status:** independent source and supplied-ZIP review. **DOCS ONLY; no new Godot tests, no runtime edits, no merge.** Current main at inspection `29b5fba448b0178cb520a4ada44b375b4b934e31`; PR #26 draft branch `integration/master-recovery-playable-v1-20261023` HEAD `53ff0b223f4e77ccfbe5c77d2203496ac0cc37a9`, code/test `f5715ad0d90ee38516b54f316b9dd6f1544c3723`, stacked on PR25 HEAD `710137c0e3976e685613a86692e5eb128b8d3c62`. Do not touch drafts #24/#25/#26 or Source A worktrees. User-provided `MASTER_RECOVERY_INTEGRATION_20261023.zip` (1455 entries) reviewed with snapshots and logs.

## 1. Verified checkpoint

- PR26 restores original Source A MAP25 art G1 production worksite cues and V2 six-stat profile, plus Source A Combat V5 **read-only** CARE snapshot presenter; no second battle/world/timer/save owner; authentic female Mạc Linh & Thanh Lang. Boss Source A slot exists but **real B3 pilot has no Boss event**. Do not fake one.
- ZIP `logs/final_sha_f5715ad/focused_suite_summary.tsv`: **19/19 focused tests PASS** at exact code SHA, official Godot4.7.2; old run evidence, not tests performed today. `final_sha_recheck_corrected` also contains 18 FAIL from errors including `Can't load script: res://tests/b3_main_hunt_integration_test.gd` (`File not found`), i.e. runner/project-resource path errors. Correct invocation and rerun, do not call these gameplay regressions or conceal them.
- CARE B3 log shows canonical committed loot, down/HP1/Injury1, recovery tick120, same disciple redeployed and second committed receipt. GUI screenshot at tick0 is scripted capture, NOT damage/loot in-motion proof. Manual Windows, Android touch, male actor, A/B/C historic reference A, real Boss and owner visual remain PENDING.

## 2. Real snapshot UX defects to fix

- Actual P3.2 top HUD and modal buttons have 11-13px low-contrast text; roster disabled-looking labels, dense redundant detail.
- World popup worksite cues overlap characters and building art; right operation panel is a long scrolling text wall. Replace with real worker/job/percent/ETA/yield/committed receipt hierarchy, retain canonical Warehouse, never fake production animations.
- V2 profile uses a six-axis radar; new D7 should display **Tam Căn three rows and Tứ Tính four rows**, birth/current/delta, point-effect explanation, Tu Vi/Body progression, and (only when authored) Mind. Battle screenshot shows a mostly empty floor and text wall with AUTO, HP and zero receipts; no skill/target/cast telemetry for players.
- V5 presenter has read-only already settled event feedback; don't render damage/skill/cooldowns without confirmed state/receipt. Free pan until user explicitly follows an actor, no camera forced lock.
- UI target 1280×720 Source A: ≥15px primary text, ≥44px tap controls, cards instead of dense walls, meaningful real empty states, accessible contrast; snapshot comparison original/mock/actual and real owner approval.

## 3. Critical gameplay balance findings

**Existing source** `CombatStatsV2`: Realm100/20/12, Body90/3/7, Potential currently multiplies combined core. User wants Realm **10,000/2,000/1,200** and Potential **Tu Vi Core only**; Body 9,000/300/700 is ratio-preserving proposed, **total 19,000/2,300/1,900 at rank1.1 is NOT a balanced HP sign-off**. Source Wolf scaled by x100 has HP17,100/ATK2,024/DEF1,368.
**Damage example** (not battle simulation): player basic vs Wolf ≈1772.79, sword skill Thanh Phong Trảm 1.35×≈2393.26, Wolf basic vs player≈1377.46. Combat V2 real learned skill consumers currently restrict to effect==damage, despite 9 P2 skill definitions; `_try_learned_damage_skill` uses authored cast/cooldown directly and does **not consume derived cast_speed or cooldown_recovery**, with 0.25s step and skill-over-basic priority. Cannot derive fight balance from number of basic hits.
MapBattle also owns: party healer when ally below65% uses 1.8×ATK effective heal with 5s recast, frontline guard below75%, mage area burst, elite/Boss telegraphed AoE. Balance across skill burst, crit, DoT, healing, mitigation, speed and group pressure; don't double-multiply ATK-proportional heal in x100 migration.
**Source medical** Hồi Xuân +55, ordinary rest +5, legacy heal +55; unit-only candidates +5,500 / +500 / +5,500, not automatically valid endgame medicine budget. Keep special HP1/downed and Injury120. Scale player/monster/fixed equipment/medicine/shield/save atomically, not one file.

## 4. D7 owner direction vs open numeric coefficients

Tam Căn = Tư Chất/Căn Cốt/Tâm Tính; Tứ Tính = Tiềm Lực/Thông Tuệ/Cơ Duyên/Mị Lực. **Two separate born budgets after one source quality grade**. Proposed bands Tam 60–179, 180–299, 300–499, 500–899, >=900; Tứ 80–239, 240–399, 400–666, 667–1199, >=1200 (shared 12% Nghịch rarity depth, independently allocated wallet amounts). No point exchange between groups. Preserve source odds and guide quota; user accepts guide charisma2500 being hard and rejects compensating it by nerfing rarity.

Keep source per-point Tư Chất +0.25% natural Tu Vi XP, Căn Cốt +0.20% eligible BodyXP, Thông Tuệ +0.15% learning XP, Cơ Duyên +1 authored luck score, Mị Lực +1 social score; owner-directed Potential +0.05% **Tu Vi Core only**/pt. Additional +0.025% BodyCore/pt for Căn Cốt and mental progression/resist coefficients are **NOT YET VALIDATED** and should not be silently implemented.

**LIFECYCLE quality correction:** `Q_birth=(6/7)*sum(seven birth values); Q_current=Q_birth+Σ(current−birth)`; +1 legitimate permanent point = +1 quality, no rounding before thresholds 360/600/1000/1800. Six-stat old save: keep six birth/current; initialize mind_birth=mean(six_birth) and mind_current=mind_birth, baseline raw old sum6_birth so old quality/current exactly preserved. No reroll or free mental points. One source/versioned migration; no active encounter mid-migration.

## 5. Mandatory staged integration gates before claiming completion

1. **Code scope gate**: PR26 HEAD/AGENTS authority, conflict inventory, one-writer branch. PR26/24/25 remain draft, no direct merges/reset.
2. **Combat-vs-skill fixture FIRST**: Godot4.7.2 seeded real event traces R1/2/5/10/20/30, mixed Body rank, 1/3/6, normal/elite/Boss isolated fixture, all eligible learned skills and skills that are deferred, action/attack-rate scheduler, guard/heal/DoT/AoE, crit/penetration/element; record TTK P10/P50/P90, max burst2s, down%, heal vs overheal, timeout% and logs. Owner signs HP target AFTER data, no speculative balance PASS.
3. **D7 versioned state/save and point/quality migration**: independent birth wallet RNG, old recruiter/source odds, quality+1 growth, full tests (especially fractional thresholds), candidate→disciple and prior saved active fights.
4. **Combat/medicine atomic x100**: verified complete source crosswalk and HP ratio preserving migration; keep HP1/Injury120, don't change XP/currency/satiety by ×100. Regression all affected V2 and CARE systems.
5. **Actual UI/UX**: edit real Source A P3.2 screens, no fake Boss/skill; focused screenshots full 1280×720, Android touch, owner acceptance; tests not screenshots alone.
6. **Handoff**: `docs/handoffs/TMB_POST_D7_UIV5_IMPLEMENTATION_REPORT_2026-10-24.md`, `docs/handoffs/TMB_CHATGPT_SUMMARY_PACKET_2026-10-24.md`, `docs/handoffs/TMB_NEXT_CODEX_TASK_2026-10-24.md`, exact SHA/branch/PR, per-test exit logs, seeded combat CSV, changed file manifest and annotated screenshots. No FULL/CI or merge unless owner authorizes.

**DIL/mockup art warning:** If a concept image displays an invented Accuracy/Dodge stat, battle skill unlock, hero HP, fixed stat maximum or Boss scene, **it is not gameplay authority**. Source + accepted owner decision + event receipts control gameplay.
