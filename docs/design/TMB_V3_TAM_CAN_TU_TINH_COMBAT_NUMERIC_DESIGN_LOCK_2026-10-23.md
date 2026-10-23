# TÔNG MÔN BÁ ĐẠO — TAM CĂN · TỨ TÍNH / COMBAT V3 NUMERIC DESIGN

**23/10/2026 · DESIGN SELECTED & NUMERIC DEFAULTS FROZEN FOR REVIEW (NOT CODE LOCK) · DOCS ONLY**  
**Owner new directions**: Tu Vi base HP/ATK/DEF 10,000 / 2,000 / 1,200 (×100); Tiềm Lực must ONLY affect Tu Vi. This file chooses a coherent **3+4 = 7 foundation design**, including candidate exact numbers; new coefficients not separately approved by owner are **PROPOSED-SELECTED**, not falsely OWNER-LOCKED or live.  
**Safety**: Branch rooted in main at 29b5fba448b0178cb520a4ada44b375b4b934e31. No gameplay code, no test/CI/FULL, no PR#24/PR#25/recovery, no Source A, no merge. Codex remains integration owner. Do not alter live Save/DiscipleState until a later explicitly authorized versioned CODE packet, real tests and owner acceptance.

## 0. Evidence and inspirations (do not copy games' numbers)

- **SOURCE TMB**: AGENTS.md; docs/GAME_SYSTEM_ARCHITECTURE.md; docs/DISCIPLE_MASTER_SCHEMA.md; docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md; docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md; docs/BODY_CULTIVATION_V2_SPEC.md; docs/DISCIPLE_V2_STAT_CAUSAL_CONTRACT.md; docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md; docs/COMBAT_STATS_V2_SPEC.md; code CombatStatsV2, FoundationSystem, DiscipleGeneratorOpenPoints, DiscipleRealmProgressV2, DiscipleBreakthroughBalanceV2, MonsterCatalogueV2, MapBattleV2, B3 CARE PR24 draft. Prior docs audit: docs/combat-base-v2-audit-20261023 and docs/combat-base-luc-duy-mind-redesign-20261023.
- **REFERENCE** 最强祖师 (The Strongest Sect): six named dimensions; player guide notes Potential primary direct combat driver, others often undervalued. https://www.taptap.cn/moment/518641440847299228 and https://www.taptap.cn/moment/601377068508252716 . **Lesson**: avoid reducing all disciple value to one number.
- **REFERENCE** Amazing Cultivation Simulator: 5 base attributes plus derived Potential; mental state affects cultivation and breakthrough; three cultivation-method identities. https://amazing-cultivation-simulator.fandom.com/wiki/Five_Attributes , https://amazing-cultivation-simulator.fandom.com/wiki/Mental_State and https://amazing-cultivation-simulator.fandom.com/wiki/Shendao_Cultivation . **Lesson**: mental condition and mental advancement are distinct from static birth attributes; avoid another mandatory 300-floor grind.
- **REFERENCE** Tale of Immortal: Luck/Insight affect different outcomes, with Insight serving comprehension; https://tale-of-immortal.fandom.com/wiki/Stats . **Lesson**: meaningful event luck not flat universal drop multipliers.
- **REFERENCE** RimWorld: mood, mental break and learning traits separate; https://rimworldwiki.com/wiki/Mood and https://rimworldwiki.com/wiki/Traits . **Lesson**: deep mental system but not excessive micromanagement or unavoidable punitive spirals.
- **REFERENCE** Kenshi: strength/toughness/skills and learn-by-doing separated; https://kenshi.fandom.com/wiki/Statistics . **Lesson**: specialized training can matter without another universal character level.
References are comparative observations, **not** gameplay authority nor evidence our proposed coefficients are balanced.

## 1. Structural decision: TAM CĂN + TỨ TÍNH (seven underlying attributes)

**DESIGN CHOICE D7 (selected)** rather than existing bare “Lục Duy” panel; no new “Ngũ Căn” stat creep.

| Group | User display / code ID | One PRIMARY authority | Base gain or effect / 100 points | Separately from |
|---|---|---|---|---|
| **Tam Căn** | **Tư Chất** / aptitude | Natural Tu Vi XP | **+25% XP / 100** (SOURCE unchanged: 0.25% per point) | fixed XP medicine, Tu Vi Core power |
| Tam Căn | **Căn Cốt** / constitution | Body path speed AND limited Body Core affinity | **+20% natural Body XP; +2.5% Body Core / 100** (new Core modifier PROPOSED-SELECTED 0.025%/pt) | Tu Vi Core, fixed Body XP |
| Tam Căn | **Tâm Tính** / mind_nature NEW | Mind cultivation progress, mental-state recovery and mental-only resilience | **+20% active Luyện Tâm gain/recovery / 100**; resistance formula below | generalized study speed, ordinary status/crit |
| **Tứ Tính** | **Tiềm Lực** / potential | **Tu Vi Core quality ONLY** | **+5% Tu Vi Core / 100** (SOURCE coefficient 0.05%/point, NEW owner-directed scope) | Body Core and all XP |
| Tứ Tính | **Thông Tuệ** / comprehension | Study/profession XP and learned mastery | **+15% learning XP /100** (SOURCE unchanged) | Mental resilience, direct skill damage |
| Tứ Tính | **Cơ Duyên** / fortune | Real events with one meaningful LuckScore check | **+100 points** in RNG0..9999 score, **not +X% drops** (SOURCE unchanged) | passive per-kill/production lottery |
| Tứ Tính | **Mị Lực** / charisma | Social interactions and Dẫn Tiên | **+100 points** in SocialScore and existing explicit recruitment curves (SOURCE unchanged) | ATK/HP, automatic morale or guaranteed follower |

- Only **Tâm Tính** is a new foundation ID. **Luyện Tâm is an acquired activity/state/progression, NOT the birth stat itself.**
- No hidden generic base stat gain from disciple rarity label, and no natural fixed XP/reward multiplication.
- Persistent birth/current points continue to be open-ended; no newly invented numerical hard cap on the points themselves. End effect of mental-only resistance is *bounded* by a disclosed consumer-specific formula, not a hidden cap on Tâm Tính.
- **Trade-off**: Căn Cốt already multiplies Body EXP; adding its small direct Body Core gain is intentional, **new** and requires benchmark before final deployment. 0.025%/pt is half the Tiềm Lực's realm-facing 0.05%/pt, with different stat contributions. If Body becomes overdominant after genuine 1000-point simulation, adjust *this new direct Body coefficient only*, not retroactively erase its current EXP authority.
- **Reject D8 (Tam Căn + Ngũ Tính)** for V3: would require an eighth permanent mental/body power stat (e.g. Thể Phách/Thần Thức), double-source Body or Mind and increase birth, quality, save and UI complexity; no independently proven consumer.
- **Reject raw “Tam Tu 30×10 each”** for this version: Tu Vi & Luyện Thể stay 30×10 separate; Luyện Tâm uses limited **5 Tâm Cảnh milestones** and a 0..100 current Tâm Trạng, not 300 new floors.

## 2. Combat Base ×100 — precise ownership and formulas

**OWNER direction interpreted from 10,000/2,000/1,200 as TU VI REALM COMPONENT** (the previous values were 100/20/12). If owner later explicitly means the *complete final sheet*, revisit the source split before CODE. For now retain the previously approved Realm:Body role proportions and multiply all six component baselines and same-rank monster baselines ×100.

| Component for both at 1.1 | HP | ATK | DEF | Authority |
|---|---:|---:|---:|---|
| Realm Core (Tu Vi) | **10,000** | **2,000** | **1,200** | **OWNER direction ×100** |
| Body Core (Luyện Thể) | **9,000** | **300** | **700** | **DERIVED equivalent ×100** |
| Final core, P=C=0 | **19,000** | **2,300** | **1,900** | **DERIVED** |

~~~text
G(r,f) = 1.65^(r-1) * 1.03^(f-1), unchanged 30 realms × 10 floors for each independent track
RealmHP/ATK/DEF = [10000,2000,1200] * G(cultivation_realm,cultivation_floor)
BodyHP/ATK/DEF  = [9000,300,700] * G(body_realm,body_floor)
FactorP = 1 + 0.0005 * max(Potential,0)
FactorC = 1 + 0.00025 * max(Constitution,0)   [PROPOSED SELECTED]
Core = RealmCore * FactorP + BodyCore * FactorC
FinalPrimary = max(channel_floor, (Core + unrelated_active_flat) * (1+same_channel_percent_add))
OrdinaryDEF_Factor = 2*attacker_ATK/(2*attacker_ATK + target_effective_DEF)
DirectDamage = attacker_ATK * authored_skill_ratio * eligible_crit * OrdinaryDEF_Factor *
               elemental_matchup * remaining_elemental_resistance * remaining_damage_reduction
~~~

**Potential 100→5% Realm Core is NOT 5% of final** because Body is independent. At both 1.1:

| P/C points | HP | ATK | DEF | SOURCE vs PROPOSED |
|---|---:|---:|---:|---|
| 0 / 0 | 19,000 | 2,300 | 1,900 | derived |
| 100 / 0 | 19,500 | 2,400 | 1,960 | user new Potential scope |
| 0 / 100 | 19,225 | 2,307.5 | 1,917.5 | new Body direct bonus proposal |
| **100 / 100** | **19,725** | **2,407.5** | **1,977.5** | combined DESIGN V3 |
| 1,000 / 1,000 | 26,250 | 3,375 | 2,675 | combined DESIGN V3 |
| 2,500 / 2,500 | 37,125 | 4,987.5 | 3,837.5 | combined DESIGN V3 |

**Scale examples for P=C=0, both tracks equal:** 1.1 HP19k/ATK2.3k/DEF1.9k; 2.1 31.35k/3.795k/3.135k; 5.1 140.83k/17.05k/14.08k; 10.1 1.7223m/.20849m/.17223m; 30.10 ≈ 50.2716 billion HP / 6.0855 billion ATK / 5.0272 billion DEF. This is a numeric/UI/save precision challenge, NOT proof of endgame balance.

**Why 10k Tu Vi HP is neither ‘too low’ nor ‘enough’ by itself**: with both 1.1 and no traits, 19,000 HP, 2,300 ATK, 1,900 DEF, equal-stat ordinary hit ≈1,627.69, so ~12 basic hits. Against source Thanh Lang tier1 ×100 (17,100 HP, 2,024 ATK, 1,368 DEF): player deals ≈1,772.79 /hit (~10 hits to kill), monster deals ≈1,377.46 /hit (~14 hits to down player). Movement, 5% crit, real attack intervals, skill and healing change battle time. By contrast a **total** 10,000 HP, 2,000 ATK, 1,200 DEF mirror takes only ~7 hits. Scale is a choice of battle pacing, not visual aesthetics.

**Monster scaling compatibility**: MonsterCatalogueV2 currently derives 190/23/19 × G × species × tier; to preserve relative TTK on next authorized code change, new source candidate is **19,000/2,300/1,900**. Historical boss documents used ×4 HP/×1.6 ATK/×1.35 DEF while current main code uses ×2.50/×1.30/×1.18: use current runtime and separate Boss balance fixture, not stale document.

**Do not automatically ×100:** Tu Vi XP, Body XP, Stone, pill satiety, material yield, kill receipts, mental points, coefficients, dimension values. **Dependent fixed HP combat effects must be re-priced in a separate locked migration**: Hồi Xuân +55 old ⇒ **candidate +5,500 HP** to preserve ~28.95% initial no-stat HP at 1.1; keep pill satiety 10 and its recipe/time until independent economy gate. Existing +55 on 19k is only **0.2895%**. All fixed healing, shields, equipment ATK/DEF flats, personal HP services (+10 HP current) and injury HP=1 need explicit per-source handling; do not overwrite +55 or HP1 under current owner contract before CODE authorization. Old save HP must be ratio-preserved, with no refill or double application.

## 3. ALL TEN dependent-stat and combat invariants unchanged

There are sixteen headline CombatStatsV2 channels: max_hp, attack, defense; move_speed, attack_speed, cast_speed, cooldown_recovery; crit_chance, crit_damage, crit_resistance; defense_penetration; effect_hit, effect_resistance; damage_reduction; lifesteal, lifesteal_reduction. 10 keyed elemental resistances distinct from those 16. Starting no-source values: Crit chance **5%**, crit damage **1.50×**, others 0pp/0% except move multiplier 1; baseline action speed is profile-specific. Contextual boss/elite/race, followup, heal/shield and skill effect channels remain separate and require real consumer.

No generic hit/dodge RNG, no automatic mental HP/ATK/DEF multiplier, no free death or injuries, no "Combat Rating" authority. Defense K=2ATK; no flat penetration and no additive-DR-to-invincibility. Crit resistance subtracts pp; lifesteal uses actual post-mitigation HP lost, defender reduces lifesteal by pp.

**Source-debt flags** (read-only): MapBattleV2 consumes attack_speed but learned skill cast time and cooldown are not currently scaled by cast_speed and cooldown_recovery; step=0.25s quantizes interval; static source checks cannot prove 30-realm balance. Test these separately, do NOT change them in a birth-system packet.

## 4. Luyện Tâm numerical V1 — small, meaningful, not a third mandatory 300-floor track

**Chosen structure**: a current **Tâm Trạng / Định Lực** 0..100 plus cumulative personal **Tâm Nguyên** milestones for 5 **Tâm Cảnh**. Tâm Tính is the permanent seventh foundation affecting recovery/training. Mental condition is not identical to Mood, loyalty, Cơ Duyên, skill EXP, or ordinary effect resistance.

### 4.1 Mental-state constants (PROPOSED-SELECTED, dormant until consumer)

- Current Mind Stability **0–100**, first generated **70** for every fresh prototype; historical saves get 70 with no backward penalty. Values are integers for UI, internal may preserve fractions.
- States: **0–24 Loạn Tâm**, **25–49 Dao Động**, **50–74 Bình Ổn**, **75–89 Tĩnh Tâm**, **90–100 Kiên Định**. These bands inform AI/conditional mental events, not a background arbitrary ATK/HP debuff.
- **Rest in authentic sect**, verified availability, once per canonical simulation minute: **+0.10 stability/min**; only when the disciple is actually resting (no "idle forever" fallback if competing job).
- **Assigned Tĩnh Tâm** (One Active Job) when truly authorized: **+0.50 stability/min × (1+0.002×Tâm Tính)**, capped at 100; progress/refund exactly once per minute, never also grant dedicated Body training. At 100 Tâm Tính: +0.60/min.
- Signed meaningful events, exactly once by event ID: **first injury transition 0→1: −10 stability**; **one genuine failed Tu Vi major-gate attempt: −12**; **one genuine encounter retreat: −5**; **one successful major Tu Vi breakthrough: +5**. These are **not** active in current Injury/save or events until explicitly authorized. No penalties every combat hit, every offline tick, or for Mood changing.
- Mind resilience against explicitly tagged **mental-type statuses ONLY**:
  \`mind_resist_pp = 0.10 * T/(T+400) + 0.01 * min(TamCanhTier,4)\`, then in the *mental-tag status application* chance subtract as a separate bounded source (not ordinary global effect_resistance). At T=100, tier0 gives **2 percentage points**; T=500 gives **5.56pp**; T=2500 **8.62pp**; +up to 4pp from tier 4. No passive defense against ordinary fire/poison/freeze/physical damage; boss immunity logic still has priority.
- **High mental state advantage:** at stability ≥90 and only on an eligible Tu Vi major-gate event: **+1 percentage point** chance (no penalty at low stability). No effect on Body's deterministic gates. This is a named source added after existing base and pity logic; clamp final chance at 100%. At 100% default gate chance, it does not exceed certainty. No background self-activation before a genuine gate consumer.
- No forced losing control/rebellion/HP death; zero mental state means reduced preparedness for explicitly authored mental encounters, not a deadlock.

### 4.2 Five Tâm Cảnh milestones (PROPOSED-SELECTED)

| tier | display name | cumulative Tâm Nguyên threshold | mental-tag resistance bonus | Tu Vi major-gate bonus if eligible |
|---:|---|---:|---:|---:|
| 0 | Phàm Tâm | 0 | +0pp | +0pp |
| 1 | Tĩnh Tâm | 100 | +1pp | +1pp |
| 2 | Định Tâm | 300 | +2pp | +2pp |
| 3 | Minh Tâm | 700 | +3pp | +3pp |
| 4 | Đạo Tâm | 1,500 | +4pp | +4pp |

- Exact initial Tâm Nguyên=0; no additional character combat level, no mandatory 30×10 Mind ladder.
- **Real Tĩnh Tâm job** (when implemented) grants **2 Tâm Nguyên per 10 verified active simulation minutes**, scaled by **1+0.002×Tâm Tính**, fractional progress accumulated deterministically. At 100 Tâm Tính: 2.4 /10min; first threshold 100 takes ~416.7 active sim minutes if only meditating. At T0 tier4 requires 7,500 active sim minutes (~125 sim hours), without other legitimate sources.
- Exactly-once independent milestones: first successful breakthrough of *each source realm* **+20 Tâm Nguyên**; first valid Boss defeat for each authored (boss species, realm, zone) identity **+10 Tâm Nguyên** per eligible participant (not on every kill). Never backfill unverified old events or allow save-reload farm; no bonus for kill/XP preview. Any other content must name an actual event or consumer; no general per-tick mental XP.
- Milestones may be accumulated from Tĩnh Tâm or real life events, not compulsory for Tu Vi/Body progression; adding +0..4pp to breakthrough helps but does not alter the locked base chance table and pity +5pp/failure. A character with no Luyện Tâm remains playable.
- Cost of Tĩnh Tâm: **0 Spirit Stones/minute** for starter ordinary quiet meditation, but exclusive One Active Job opportunity cost; any advanced building/consumable acceleration is a **separate economic packet**. Meditation may coexist with established passive Tu Vi only where that independent approved Tu Vi source legitimately applies; never mint two active jobs.

This is a constrained pilot content contract, NOT permission to add a mental subsystem across all 30 realms until exact consumers and UI exist.

## 5. Birth quality and save compatibility: preserve grade/odds deterministically

**Critical**: existing P3.7C1 birth generation, FoundationSystem.total_values, six-dimensional quality, DiscipleState/CandidateState, migration, radar, saved foundation_birth_values, tests all assume SIX. Changing a label without a schema would corrupt authority.

### Option chosen: normalised seven-attribute quality score, not blindly SUM7

Existing grade **Q** thresholds stay: <360 Phàm Thường, 360–599 Xuất Chúng, 600–999 Thiên Kiêu, 1000–1799 Tuyệt Luân, ≥1800 Nghịch Thiên. **Dẫn Tiên odds preserved** at SOURCE 65/25/8/1.8/0.2% ordinary; verified Main Guide boost caps remain 35/25/20/15/5% for five grades. No duplicate extra 7th-stat gacha.

~~~text
S7 = aptitude + constitution + mind_nature + potential + comprehension + fortune + charisma
Q_normalized = round(S7 * 6 / 7)
quality = current P3.7C1 bucket(Q_normalized)
~~~

**New V3 recruits:**
1. Use existing source grade odds to select grade.
2. Draw **Q_target** from **the EXISTING six-score distribution of that grade**, including the long-tail Nghịch Thiên.
3. Set **S7_target = round(Q_target × 7/6)**.
4. Distribute S7_target to **7 integer permanent stats**, each initially within **floor(S7_target/14)** and **floor(3×S7_target/7)**, ~0.5–3× a seven-axis mean, using an independently versioned deterministic birth RNG. Sum exactly S7_target; ensure no negative/remainder errors.
5. \`round(S7_target × 6/7) == Q_target\` for integer Q_target by elementary rounding, preserving source grade **exactly**. No free 16.7% growth in normalised quality from adding a seventh stat.

**Existing SIX-stat save migration (version3):**
- Never reroll any of the six permanent stats, immutable birth snapshots, Trait/Root/Fate or character IDs.
- **mind_birth = round(sum(previous six BIRTH stats)/6)** and **mind_current = round(sum(previous six CURRENT stats)/6)**; mark source \`migration_v3_compat\`, not a reward or intentional user training action.
- For integral S6, identity \`round((S6+round(S6/6))*6/7) = S6\` holds, so quality after migration remains **exactly** the previous P3.7C1 grade; arithmetic verified independently for S6=120..99,999. Do not promise Rng compatibility until Godot regression at precise SHA.
- Keep versioned old save forward reader, reject unknown versions and orphaned old schema, retain birth history and per-field provenance. V3 transition must preserve actual current HP ratio and exact Injury(0/1/120), not free heal.
- If old six were historical legacy normalized 0..1, first apply existing approved migration to open points ONCE then mind migration; never treat normalized values as open points or give stat gains twice.

**UI**: use two sections, Tam Căn (3 compact rows) and Tứ Tính (4 rows), not one illegible radar; show exact bonus next to each attribute, current/birth values, source breakdown, and one small Tâm Trạng bar only when mental consumer is enabled. Android landscape 1280×720 readable taps; no new full-screen tab required.

## 6. Numeric interactions and economy regressions BEFORE any code lock

**Critical fixed-value scaling**: To preserve effect of early healing in the ×100 combat scale, **Hồi Xuân +55 HP ⇒ proposed +5,500 HP**, not a silent modification to the current CARE accepted +55. Same pill satiety10, shared 1,000,000/day/disciple and authentic alchemy recipe; adjust +55 only in a separately authorized future balance packet. Tụ Khí fixed +10,000 Tu Vi stays unchanged, fixed Body XP unchanged. Personal Stone-for-HP service (+10 currently) and enemy damage must be revisited. For 19k HP, +55 is only 0.2895% of bar vs candidate +5500 = 28.95%; going from HP1 to max needs ~346 vs 4 doses. This is why partial ×100 migration is unplayable.

**Benchmark envelopes are target hypotheses, not measured passes**:
- Equal-rank naked normal monster: 8–14 basic hit equivalents with real skill movement and crit observation; paper first rank hits currently ~8–12 across common species.
- Same-rank normal 1v1: roughly 10–25 sec typical fighting; Elite small team 20–50 sec; Boss 6-person team **30–75 sec**, keeping current group MapBattle timeout 90 sec unless separate change approved.
- +1 and -1 realm, mismatched TuVi/Body, P/C/Mind 0/100/500/1000/2500/10000; role DPS/healer/tank/support and 1/3/6/2-team; damage, TTK, effective survivability, missed turns, skill cooldown, retreat/injury, healing economy.
- 10+ step count assertions and 1000+ deterministic seeded randomized births in official Godot when authorized; preserve reproducibility and no duplicate RNG consumption.
- **Do NOT call balanced until** actual 1/3/6 encounters demonstrate profiles and survival across P/C extremes; monster stat source, max HP, fixed medicine, collision/time and owner approval aligned.

## 7. Scoped follow-on packets (NOT authorized code)

**D7-00** docs design review and arithmetic only (THIS FILE).  
**D7-01** versioned FoundationSystem/Generator/Candidate/DiscipleState/save migration + deterministic seven-stat tests on a branch after recovery owner releases those overlapping files. No Source A, no combat mutation in same packet.  
**D7-02** ×100 Realm/Body/Monster/HP/medical/absolute-effects with stat provenance and old-save migration, explicit source-of-truth and fixed-effect list; focused gates first.  
**D7-03** Căn Cốt BodyCore + TuVi-only Potential integration, 300-floor independent tracks, mismatched floors, bonus priority, 16 stat channels; regression.  
**D7-04** opt-in mental current-state + milestone 5 ranks, event dedup and real action ownership; QA and screen acceptance; no additional generic stamina bar.  
**D7-05** full battle balance validation and targets, after 1/3/6/Boss + PvE receipt passes and deliberate owner approval.

**Acceptance**: V3 is a **selected design recommendation with exact frozen candidate numbers, not code, QA or user ratification of every newly proposed coefficient**. Existing Combat V2 combat authority, single scheduler, canonical Warehouse, one active job, injury and 30+30 progression remain intact until authorized packets are integrated.

## 8. Final project design decision

**Choose TAM CĂN + TỨ TÍNH = 7, not six ungrouped axes, nor 3+5 = 8.** Keep TuVi quality from Potential only, Body progression from Constitution with a cautiously budgeted direct Body affinity, training and stability from Mind Nature, one learning/comprehension channel, and event/social sources independent. Retain x100 combat unit design across actors plus explicit fixed-magnitude migration. Maintain the ability to *play without mind training*. Full lock to code occurs only after numeric owner review + fixture regression and recovery gate, not because a Markdown file exists.
