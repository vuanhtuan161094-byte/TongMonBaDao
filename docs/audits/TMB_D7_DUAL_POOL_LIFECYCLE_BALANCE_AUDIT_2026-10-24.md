# TÔNG MÔN BÁ ĐẠO — D7 TWO POOLS: LIFECYCLE BALANCE AND DESIGN CORRECTIONS

**Audit date:** 2026-10-24 (Asia/Bangkok). **Authority:** `main@29b5fba448b0178cb520a4ada44b375b4b934e31` as observed on this review; Codex recovery PR24/25 remain unmerged draft, not a code authority here.  
**Status:** READ-ONLY SOURCE AUDIT + reproducible INDEPENDENT PYTHON numerical simulations; DOCS ONLY, not official Godot QA. **Do not code, CI/FULL, change recovery, Source A, save, runtime, or merge.**

## 0. Decisions and corrections

**OWNER DIRECTION:** **Tam Căn (Tư Chất, Căn Cốt, Tâm Tính)** and **Tứ Tính (Tiềm Lực, Thông Tuệ, Cơ Duyên, Mị Lực)** must have **independent birth point budgets**, not share seven-way points. Owner also directed new Tu Vi HP/ATK/DEF RealmCore = **10,000/2,000/1,200** and **Tiềm Lực affects Tu Vi Core ONLY**. KEEP Combat V2, two independent 30×10 realm and body ladders, Injury0/1/120, canonical scheduler, save/warehouse, One Active Job.

**PROPOSED-SELECTED (unmerged):** single original source-quality grade roll; independent group totals conditional on grade, group-only internal point allocation. **NOT YET LOCKED:** Căn Cốt +0.025% BodyCore/pt, Luyện Tâm effects/gates; no runner or owner playable sign-off.

**NEW CORRECTIONS from THIS AUDIT (recommend supersede earlier draft details):**
1. **QUALITY PERMANENT GROWTH**: prior `Q_current=(6/7)*sum7_current` makes **1 permanent point only 6/7=0.857142857 quality point**. Current `FoundationSystem.add_permanent_points` grants quality 1:1. This is a silent **+16.6667%** required earned permanent points for the same increase. Fix via birth-anchored score in §3.
2. **LEGACY MIGRATION**: previous `mind_current=mean(six current)` retroactively creates extra earned Tâm Tính from unrelated historical growth and breaks the new 1:1 baseline. Preserve old five/six stat values and set **mind_birth=mean(old six BIRTH); mind_current=mind_birth** (no imaginary mind XP), with inherited compatible quality derivation in §3. For old saves whose birth history is missing, STOP/explicit migration policy, never silently guess.
3. **INTRA-GRADE RARITY**: two uniform independent budgets produce a strongly middle-weighted final quality score: upper decile in four finite grades ≈**2%**, old single-uniform ≈**10%**. This is an intentional balance change if retained; do not claim original full Q distribution is preserved just because five macro grade rates remain unchanged. Compare Beta alternatives in §4; DO NOT silently reweight without owner decision.
4. **NGHỊCH THIÊN LONG TAIL**: share the *depth event only* under source 12% repeat, then roll independent group budgets within the selected rare block. Two independent rare-depth rolls nearly erase extreme-high tail.
5. **GUIDANCE ACCESSIBILITY**: full quality-cap Trưởng lão needs 2,500 Mị Lực, extremely unlikely naturally with this birth sampler; a real later permanent-point growth source/route must be audited instead of assuming the capped 5% table is easy to access.
6. **×100 SCALE**: fixed rest recovery +5 HP also needs crosswalk; old pill +55 and legacy +55 HP heal are NOT the only absolute heal sources.

**Important precedence:** this docs-only audit supersedes the earlier proposed point-growth scoring and legacy mind-current assignment in `docs/tmb-d7-dual-pool-deep-audit-20261023` and `docs/tmb-d7-final-crosssystem-impact-gate-20261023`. It does not change runtime code nor negate existing owner locks.

## 1. Actual source examined

- `godot/src/simulation/foundation/foundation_system.gd`: exactly six dimensions; `add_permanent_points` accepts float amounts and recomputes grade from **current sum** (no floor); `birth_total`, candidate and disciple validators, migration and deterministic point sources.
- `godot/src/simulation/recruitment/disciple_generator_open_points.gd`: single six-axis total, birth envelope, source-grade distributions, long-tail 12% Nghịch-Thiên continuation.
- `godot/src/simulation/recruitment/recruitment_system.gd`: Dẫn Tiên 65/25/8/1.8/0.2%, guide interpolation to 35/25/20/15/5% at Mị Lực2500 subject to enhanced daily quota; source-specific fate/gacha rules, one order/receipt authority.
- `godot/src/simulation/state/{candidate_state,disciple_state}.gd`, `save/save_service.gd` (save version 2), `godot/src/presentation/disciple_presentation_snapshot_v2.gd`: born/current six-field schema and reader/writer; migration requires versioning and replay guard.
- `godot/src/simulation/cultivation/{disciple_realm_progress_v2,disciple_progression_balance_v2,disciple_breakthrough_balance_v2,disciple_body_training_facility_v2}.gd`: 300 floor prices per track, natural XP versus fixed, body paid 1 Stone/min, 1500 BodyXP/min baseline, 29 Tu Vi probabilistic gates with +5pp same-gate failure pity; deterministic Body gates.
- `godot/src/simulation/{needs/needs_system,economy/economy_system}.gd`: Hồi Xuân +55, legacy paid heal +55, rest +5 HP plus separate stamina; medication/recovery transactions.
- `godot/src/simulation/combat/{combat_stats_v2,monster_catalogue_v2,map_battle_v2,disciple_combat_loadout_v2}.gd`: current CombatV2 math, 16 headline stats, HP ratio, monster base 190/23/19; some learned skill consumers still not using cast_speed/cooldown_recovery.
- `godot/src/simulation/recruitment/disciple_birth_roll_v2.gd`: other birth identities have separate deterministic domain seeds. Do not perturb them when adding group RNG.
- `godot/src/simulation/workforce/workforce_system.gd` and `traits/trait_system.gd`: profession XP source vs work speed vs trait cultivation modifier distinct; V2 does not reinterpret `combat_power_flat` as CombatStatsV2 ATK.

## 2. Independent group budgets, no coupling within grade

Grade remains one SOURCE-owned draw, 5 mutually exclusive grades, not separate probability roll for Tam and Tu. Numeric ranges from proposal:

| Grade | SOURCE ordinary chance | B3 Tam Căn | B4 Tứ Tính |
|---|---:|---:|---:|
| Phàm Thường | 65% | 60–179 | 80–239 |
| Xuất Chúng | 25% | 180–299 | 240–399 |
| Thiên Kiêu | 8% | 300–499 | 400–666 |
| Tuyệt Luân | 1.8% | 500–899 | 667–1199 |
| Nghịch Thiên | 0.2% | >=900 (long-tail) | >=1200 (long-tail) |

Let **B3** and **B4** use distinct RNG subdomains and no cross-budget transfer, conditional on the shared already-rolled grade. `Q_birth=(6/7)*(B3+B4)` is sufficient to fall inside the grade's threshold band (strict comparison with floating values; no rounding). The internal group-only allocation uses each dimension about 0.5×..3× its **own group's mean**, with exact integer sums, not seven-way min/max.

Retain the original SOURCE_FATE 70% Cơ Duyên-highest preference **within Tứ Tính** only to avoid stealing Tam points. This is a new path-specific effect interpretation and needs explicit QA.

**Shared grade does not imply true marginal independence across all recruits**: high grade boosts both budgets. The intended independence is conditional on that grade and on the shared rare tail stratum for Nghịch Thiên.

## 3. FIXED PRE-LOCK RULE: Quality from birth-normalized score PLUS 1:1 earned points

**Problematic previous design (SUPERSEDED):**
```text
Q_now = (6/7) * sum(seven current stats)
delta_quality_per_earned_point = 6/7
```
If player formerly needed +60 legitimate permanent foundation points to gain 60 quality, the previous D7 formula would yield only 51.4286 quality, needing +70 total earned points (16.667% more).

**RECOMMEND new canonical D7 scoring:**
```text
S_birth = sum(7 birth attributes)
S_current = sum(7 current attributes)
Q_birth = (6/7)*S_birth                 // for NEW D7 newborns only
Q_now = Q_birth + (S_current - S_birth) // every legitimately added permanent point gives +1 Q
quality = old P3.7 thresholds(Q_now), using full floating precision
```
For a genuine **V2 legacy save with 6 stats**:
```text
S6_birth = sum(six immutable birth attributes)
S6_current = sum(six current attributes)
mind_birth = S6_birth/6
mind_current = mind_birth          // NO retroactive fictional mind training
S7_birth = S6_birth + mind_birth
S7_current = S6_current + mind_current
Q_birth_compat = S6_birth          // EXACT raw old birth quality score
Q_current = Q_birth_compat+(S7_current-S7_birth) = S6_current
```
Hence every old grade remains the same at migration; permanent six-stat growth by 1 still grants exactly +1 quality, and new Tâm Tính growth by 1 also gives +1. No preexisting six-stat foundation point removed or rerolled. **Use the original source old-score for exact migration baseline; do not round the new virtual attribute.** Test floating thresholds 359.999/360, 599.999/600, 999.999/1000, 1799.999/1800, including old saves with meaningful postbirth gained points. Independent Python calculations for these exact cases preserved old quality result. Small non-associative float errors around exact threshold need real Godot tests; enforce one consistent summation order or persist versioned compatible quality baseline.

**Quality is still dynamic and earned; no new second independent 'rarity grade' created for either wallet.** Store versioned `foundation_birth_values`, `birth_quality_score` (or derive with validated provenance), `current values`; rederive quality from authoritative current values. Never reward a real player stat gain on save migration and never mint points each reload.

**Migration fail-closed conditions:** missing born snapshots; inconsistent previous grade; active combat snapshot with stale HP-scaled schema; previous model normalized floats mistakenly interpreted as open points; candidate pending accept or SAVE VERSION not recognized. No optimistic auto repair during offline replay.

## 4. Compare group-total distribution shapes; no covert reroll

**Continuous analytical-model approximation**: independent B3 and B4 fractions in [0,1] with normalized quality `z=(3*x+4*y)/7`, RNG NumPy `default_rng(20261023)`, 1,000,000 independent (x,y) pairs per tested shape. This compares shapes only; actual discrete group bounds/allocations require official Godot verification.

| Two independent conditional pool fractions | P(Q in grade bottom 10%) | P(Q in grade top 10%) | Comments |
|---|---:|---:|---|
| Uniform(0,1), current draft | 2.05% | 2.05% | tight middle, rare upper-grade progress start |
| Beta(0.5,0.5) both | 6.82% | 6.81% | more extreme personal fortunes/deficits; noticeably changes joint high-high |
| Beta(0.35,0.35) both | 9.92% | 9.88% | nearly restores edge 10%, but multimodal/uniform old Q still **not exactly preserved** |
| Old SOURCE Q uniform in grade | ~10.0% | ~10.0% | source benchmark, NOT a two-wallet independent roll |

**Verdict for now**: retain **Uniform pools as the existing numeric pilot only**, with explicit warning the top-decile-born rates change ~10%→~2%. The Beta alternatives are calibrated **A/B fixtures for later review**, not covert owner-approved production changes. If the desired owner experience is equally many newborns near grade boundary, choose Beta(0.35) only after showing its U-shaped marginal and higher high-high pairs to owner. Source grade % remains unchanged with any legal within-grade option.

## 5. Guide Mị Lực attainability: quantified bottleneck

**Synthetic not official engine**: Python `random.Random(20261024)`, n=70,000 forced births per each grade, two independent uniform group budgets and feasible group-local point split; shared-depth rare Nghịch-T tail. Mị Lực is index3 of Tứ Tính. Below are estimates of being born with Mị Lực above thresholds, *not odds of raising it later*.

| Forced birth grade | P(Mị Lực≥625 at birth) | P(Mị Lực≥2500 at birth) |
|---|---:|---:|
| Phàm Thường | 0% | 0% |
| Xuất Chúng | 0% | 0% |
| Thiên Kiêu | 0% | 0% |
| Tuyệt Luân | ~1.113% | 0% |
| Nghịch Thiên | ~20.250% | ~0.181% |

Weighted across ordinary SOURCE grade distribution, random natural recruit:
- `P(Mị Lực≥625) ≈ 0.0605%`, **about 1 in 1,650**;
- `P(Mị Lực≥2500) ≈ 0.000362%`, **about 1 in 276,000**.
These are Monte Carlo estimates with rare-tail statistical uncertainty, **not exact source probabilities or current engine outcomes**. The 2,500 threshold for reaching the Dẫn Tiên 5% boosted Nghịch table was previously designed with an open-point permanent Mị Lực growth avenue; ensure there are **ACTUALLY EARNABLE**, affordable, **single-receipt** point sources. `FoundationSystem.add_permanent_points` is an API, not sufficient proof that a repeatable, economically bounded acquisition path already exists. Do not nerf the existing 2,500 source target or grant free Mị Lực without a separate owner decision.

The intermediate guide milestones at 625/1250/1875/2500 should be displayed as progression targets; avoid displaying the max 5% as routinely accessible to fresh sects.

## 6. Numeric combat crosscheck with *newborn* actual cohorts

**Synthetic**: Python `random.Random(2026102401)`, n=25,000 per each finite grade (100,000 generated), two independent group budgets and the current candidate P/Constitution law. All disciples Tu Vi 1.1 and Body 1.1, no equipment/skills/buffs; ordinary source monster **Thanh Lang R1.1** with ×100 all three core stats. Use actual CombatStatsV2 direct-attack formula:
```text
Player HP = 19000 + 5*Potential + 2.25*Constitution
Player ATK = 2300 + 1*Potential + 0.075*Constitution
Player DEF = 1900 + 0.6*Potential + 0.175*Constitution
Wolf HP17100 ATK2024 DEF1368
OutgoingDamage = ATK*2*ATK/(2*ATK+1368)
IncomingDamage = 2024*4048/(4048+DEF)
```
These three linear closed forms are valid **only at both R1.1 and zero gear**, assuming proposed Constitution extra BodyCore effect and user-directed Potential RealmCore-only. No crit, skill, movement or heal.

| Grade conditional | Median ATK | ATK P90 | Median hits to defeat Thanh Lang | Median naked hits Wolf needs to down player |
|---|---:|---:|---:|---:|
| Phàm Thường | ~2,335 | ~2,380 | 10 | 15 |
| Xuất Chúng | ~2,370 | ~2,455 | 10 | 15 |
| Thiên Kiêu | ~2,417 | ~2,558 | 10 | 15 |
| Tuyệt Luân | ~2,506 | ~2,748 | 9 | 16 |

**Insight**: cohort birth-stat advantage at early rank moves ordinary wolf kills by ~0..2 basic hits median over four finite grades; **that is not proof of DPS balance or combat role parity**. The real high-point benefit lies in later EXP speed, unlocked realm, skill mastery, meaningful event/social and long-horizon combat core scaling.

Sensitivity at R1.1: P100 adds +500HP/+100ATK/+60DEF, C100 adds +225HP/+7.5ATK/+17.5DEF **plus** +20% natural BodyXP (SOURCE). Rèn Thân Đường source=1500 Body XP per active paid sim minute, 1 Stone/min; for 10M BodyXP target C0 about6667 active paid minutes vs C100 about5556, **~1,111 paid minutes and Stones saved** ignoring interruptions/other sources/gates. This is a substantial SECOND power/economic benefit; defer approving new C direct BodyCore +2.5% per100 until real Body progression fixtures and owner check.

## 7. Fixed-value HP migration complete checklist

The scaling target is still **Tu Vi RealmCore 10,000HP / 2,000ATK / 1,200DEF**, **BodyCore 9,000/300/700**, naked P0,C0 whole 1.1 character **19,000HP / 2,300ATK / 1,900DEF**. Full 30.10 core HP ≈50.27 BILLION; numeric and Android UI gates required.

A coherent ×100 migration must cover, at minimum:

| Old source, observed from repo / active draft | Current absolute HP | Candidate ×100 equivalent | Status |
|---|---:|---:|---|
| NeedsSystem HEALING_PILL_HP (Hồi Xuân) | +55 | +5500 | future owner reauthorization required |
| EconomySystem heal() paid heal | +55 | +5500 | future owner reauthorization required |
| NeedsSystem apply_rest() | +5 per authentic rest | +500 | future owner reauthorization required |
| CARE injury/knockdown terminal | **HP1** (special sentinel) | **STAY HP1** | owner locked, do not blindly ×100 |
| Other personal heal/service/skill shields/gear flats | **source-specific** | audit each source / possibly ×100 or percent based | not automatically multiplied |
| Fixed Tụ Khí +10,000 Tu Vi XP | +10,000 Tu Vi | **UNCHANGED** | unrelated XP economy |
| Daily pill shared satiety | 1,000,000/disciple/day | **UNCHANGED** | unrelated to HP unit |

**Do not alter actual HP healing/packets during an ongoing saved PvE encounter**; versioned recovery must commit a complete transaction exactly once. Ordinary living HP preserves old fraction where allowed, while injury HP1 and 120-tick recovery remain exceptional. Mouse/Android screen should show percentage-of-max heal and current/expected absolute value, avoid visual rounding to 0%.

## 8. Additional source impact checklist and gates

- SOURCE five grades and Dẫn Tiên quota remain exactly source-owned, while within-grade totals and specialist tails change: test quality near thresholds, reliable high-high archetypes, 1k–3k recruits and recruitment escalation.
- SOURCE birth V2 uses separate RNG domain seeds for root/trait/bloodline/physique/destiny: new independent group pools must have **versioned own domains** and not shift old identities or earned lifetime events. SOURCE_FATE 70%-fortune-preference must be reapplied **only in Tứ Tính**, requiring a scoped new-path decision.
- SOURCE state and save are **six fields** and `SaveService.CURRENT_VERSION=2`; need version 3 or other explicitly versioned compatible migration for both candidates and disciples, snapshots/birth_quality_score, old discrete gate failures, mutable permanent points, offline and absent-event receipts. New Q rule must be exactly-once, not increment birth grade on each reload.
- SOURCE Tu Vi gate has 29 authored success chances and +5 percentage-point pity after each same-gate failure; body gates deterministic. Newly proposed mental tier +1pp must have a *real unique gate context* and new source owner, otherwise no implementation. New Tâm Trạng cannot compete with needs/rest states; no generic mental-lock penalty and no passive second active job.
- SOURCE CombatV2 has 16 primary channels and 10 keyed elemental resistances; cast-speed/cooldown recovery consumer parity is open. Do not add raw `combat_power` to ATK. The R1.1 cohort math above does not assert Godot PASS.
- SOURCE production, profession output, exploitation: **Thông Tuệ** controls profession learning where typed P3.7 source exists, not unlimited work-cycle yield; **Cơ Duyên** belongs to meaningful event check, not per-hit/per-tick drop; **Mị Lực** social/guide, not one arbitrary universal buff.
- SOURCE UI `DisciplePresentationSnapshotV2.FOUNDATION_KEYS` hardcodes six; display real two sections Tam3/Tu4 plus grade score, innate/current deltas, rates and causal stat breakdown; no Source A renderer rewrite.
- Numerical reference and stochastic tests here are **Python model only**. Mandatory future **Godot 4.7.2 focused gates**: true by-source generated rarity, seed replay and old RNG compatibility, distinct dual-wallet uniform sampler, source-preserving Q for fractional current and legacy-growth saves, 29 breakthrough chance gates and Body deterministic, absolute HP+/−100 scaling and realistic TTK, medicine/return from injury, old save offline exactly-once, 1280×720 screen/Android acceptance.
- The full system code must wait for Codex recovery to establish ONE writer to `FoundationSystem`, `CandidateState`, `DiscipleState`, `CombatStatsV2`, `SaveService`; no merge under this docs-only audit.

## 9. Priority decisions after this audit

**READY FOR DESIGN LOCK if owner agrees:**
1. **Two numeric budgets per birth** (B3, B4 independent conditional on one grade), source rarity unchanged, 3+4 foundation names.
2. **NEW birth-anchored quality growth formula** §3, which preserves **+1 grade-score per earned stat point** and old six-stat saves without false mental growth; label raw source old/current properly.
3. **Shared 12% Nghịch depth event**, independent two allocations within that stratum.
4. Baseline uniform within-grade, **documented** ~2% upper decile; Beta alternatives are options, not silently implemented.
5. Combat scale×100, Tu Vi-only potential as owner's direction; **do not** approve direct C BodyCore or mental +pp as balanced without fixtures.

**NOT CLAIMED:** Live 7-attribute implementation; combat/grade balance PASS; repeatable high-Mị-Lực training sources; CARE medicinal scaling passed; Codex recovery merged.

**Verdict:** Continue V3 on an isolated docs branch, correct quality lifecycle before any code migration, and resist authorizing changes to the currently integrating runtime.