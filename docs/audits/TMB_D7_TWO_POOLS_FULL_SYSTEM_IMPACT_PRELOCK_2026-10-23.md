# TÔNG MÔN BÁ ĐẠO — D7 TWO-POOLS CROSS-SYSTEM IMPACT AUDIT / PRE-LOCK GATE

**Date:** 2026-10-23 · **Baseline verified:** `main@29b5fba448b0178cb520a4ada44b375b4b934e31`.  
**Scope:** read-only main + draft CARE integration source review; independent numeric calculation and clean-room synthetic Python simulation. **NO Godot runtime test, no code, no Source A, no PR #24/#25/recovery edits, no FULL/CI, no merge.**  
**Interpretation:** user newly selects **Tam Căn and Tứ Tính to own separate point budgets**. Only this structural owner direction is locked. Specific candidate numeric algorithms/effects below are tagged **PROPOSED-SELECTED**, not yet authoritatively coded or signed off by owner. Earlier one-seven-budget docs are **SUPERSEDED FOR BIRTH DISTRIBUTION**, while their Combat V2 math authority is not superseded automatically.

## 0. Verdict after deep review

**APPROVE THE TWO-BUDGET ARCHITECTURE FOR DESIGN; DO NOT AUTHORIZE CODE YET.** Review surfaced real coupling hazards that previous D7 design docs understated:
1. Existing six-axis score, candidate/disciple schema, birth snapshots, presentation and persistent migration are all six-field authoritative.
2. New **round(...)** on continuous quality score can falsely promote fractional-point old characters at threshold. Fix by retaining the **UNROUNDED REAL score**.
3. Two independent uniform group budgets keep the FIVE **grade odds**, but change the **within-grade score distribution**: nearly **10% → ~2%** of members in the top 10% score band. That is a real birth/progression rebalance, not an unchanged feature.
4. Two independent Nghịch-Thiên long-tail depth rolls shorten the extreme rare tail. Fix by **one shared rare tail-depth event for the grade**, then **independent group allocations within that tail block**, not one shared points pool.
5. ×100 only for HP/ATK/DEF without synchronized monster, fixed healer, potion, gear flats, services, UI and old-save scaling breaks fight and economy; CARE heals +55 and certain legacy heals +10 remain contracts until separately authorized.
6. Căn Cốt already improves EXP and reduces paid Body training time and cost. Giving it BodyCore +2.5%/100 additionally is **double-benefit** and needs targeted game benchmark; do not call balanced.
7. Mental state and breakthrough bonuses are **not** just a new seventh field: need one owner and no overlapping Mood, needs, Injury, deterministic body-gate or TuVi pity rules.
8. Additional high Tư Chất + high Tiềm Lực combinations rise across two budgets; attribute-specific synergy and guide-charisma tails change despite identical grade odds.

**Exact statuses:** two-pool separation = OWNER DIRECTION; ranges = PROPOSED-SELECTED; Combat +100 scale, potential TuVi-only = OWNER DIRECTION; added mind progression, Căn Cốt BodyCore direct bonus, new quality distribution, mental gate buffs = PROPOSED, require user review; none coded, tested or merged.

## 1. Canonical source files audited

`AGENTS.md`; `CURRENT_CHECKPOINT.md`; `NEXT_CHAT_HANDOFF.md`; `docs/DISCIPLE_MASTER_SCHEMA.md`; `docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`; `docs/DISCIPLE_V2_STAT_CAUSAL_CONTRACT.md`; `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md`; `docs/COMBAT_STATS_V2_SPEC.md`; `docs/BODY_CULTIVATION_V2_SPEC.md`; `docs/REALM_LADDER_V2_SPEC.md`; `docs/SPIRITUAL_ROOT_V2_SPEC.md`; `docs/design/TMB_V3_TAM_CAN_TU_TINH_TWO_INDEPENDENT_POOLS_AUDIT_2026-10-23.md` on docs branch; source `FoundationSystem`, `DiscipleGeneratorOpenPoints`, `DiscipleGeneratorV2`, `RecruitmentSystem`, `CandidateState`, `DiscipleState`, `SaveService`, `DisciplePresentationSnapshotV2`, `DiscipleRealmProgressV2`, `DiscipleProgressionBalanceV2`, `DiscipleBreakthroughBalanceV2`, `DiscipleBodyTrainingFacilityV2`, `DiscipleBodyXpSourceV2`, `DiscipleTuViFlowV2`, `CombatStatsV2`, `MonsterCatalogueV2`, `MapBattleV2`, `HuntingPveRunV2`, `NeedsSystem`, `EconomySystem`, `AlchemyRecipeRegistry`, `WorkforceSystem`, `TraitSystem`, `SpiritualRootSystem`, `DiscipleCombatLoadoutV2`; PR24 draft hunting source checked by ref `integration/b3-care-main-20261022`.

SOURCE limitations: verified source code and numeric arithmetic, not Godot compile/run, not physical Windows/Android, not human UI acceptance. Source material at main is not automatically equivalent to Codex's current recovery working tree.

## 2. Cross-system impact matrix — cause, severity and disposition

| System | Impact of two budgets / 7 axes / ×100 HP | Severity before code | Required resolution |
|---|---|---|---|
| Birth roll & P3.7C1 quality | `_roll_total_for_quality` + `_distribute_total` currently own ONE six-stat pool | **P0** | Versioned generator v3 with grade-first, **two named birth pools**, quality raw score and actual source-specific odds |
| Quality score and promotion | `FoundationSystem.total_values`, `quality_for_total`, `add_permanent_points` use six; old float current points possible | **P0** | new `Q_raw=(sum3+sum4)*6/7` **without rounding**, quality recalc on legitimate permanent growth only |
| Source odds + Dẫn Tiên | ordinary, gacha fallback, fate, main guide Mị Lực, quota and one recruitment receipt | **P0** | retain grade draw probabilities, daily snapshot/quota + main/assistant semantics, no second grade dice, no reroll on accept |
| Deterministic seed / Root, Trait, Fate, Bloodline, Physique | Adding seven-way draws to the same RNG stream could change unrelated birth identities | **P0** | separate versioned RNG domains for pool 3/4; preserve source and birth identity substreams and old saves |
| Candidate/Disciple serialization | six stored floats, `foundation_birth_values`, `to_dict/from_dict`, `CandidateState.to_disciple` | **P0** | versioned seventh field, immutable birth/current snapshots and candidate-to-disciple exact transfer |
| Save / offline recovery | `SaveService.CURRENT_VERSION=2`; old schemas, backups, deferred encounter runs | **P0** | explicit new save/model versions; atomic idempotent migration, rollback and unchanged receipts; never reinterpret mid-flight encounter blobs |
| Combat Core & monster | 100/20/12 Realm → 10k/2k/1.2k; Body90/3/7 → 9k/300/700; current monsters anchor 190/23/19 | **P0** | migrate actor+monster together or not at all; preserve Combat V2 formula; Potential restricted to Realm; Constitution direct only if independently approved |
| HP healing & CARE | `NeedsSystem` +55 pill, `EconomySystem` +55 legacy heal, personal-service +10 HP pilot, PR24 downed HP1/Injury120 | **P0** | per-source fixed heal audit; proposed +5500 per previously +55, +1000 per +10 **only if maintaining percentage equivalence**; preserve HP1/Injury, old save HP ratio and transaction amounts |
| Potions, item flat, shields, skills | Absolute values may be 100× too weak after new HP/ATK | **P0** | catalogue each fixed HP/ATK/DEF/healing/shield/DoT; preserve TuVi/Body fixed XP, satiety, economy currencies and item counts |
| Tu Vi / 30×10 | Tư Chất affects natural XP, Potential should NOT also increase natural XP | **P1** | unchanged 1000 TuVi/min base, unchanged fixed +10k pill, 300 floor prices; separate RealmCore from progression |
| Body / Rèn Thân | Căn Cốt SOURCE +20% natural Body XP per100; proposed +2.5% BodyCore per100 | **P1 HIGH** | treat speed+BodyCore as two benefits; no free BodyXP from ordinary kill; keep one source/min, paid training and Body gates |
| Breakthrough & Tâm Tính | canonical 29 TuVi chances and +5 percentage-point failure pity, Body gates deterministic | **P1 HIGH** | no mental odds adjustment before real event owner; if added, named capped +pp only in TuVi major gate, after pity, never in Body gate |
| Mood / Needs / social | new Mind Stability 0..100 may duplicate existing living needs, Mood and social attributes | **P1 HIGH** | distinct condition schema only if verified effect family; no generic morale punishment or Mị Lực/Thông Tuệ overlap |
| Fate recruitment | existing SOURCE_FATE 70% chance Cơ Duyên becomes **highest of old six** | **P1** | new directional rule, **within Tứ Tính only**; no stealing Tam Căn points; preserve path-specific 50/28/14/6/2 quality odds |
| Gear, skills, 16 stat channels | Attack/defense scales, direct damage, Crit, DR, Lifesteal; cast/cooldown missing consumer coverage in MapBattle | **P1 HIGH** | explicit source provenance; no double crit/hit rules; finish stat consumer audit in a separate packet; ensure fixed and percent-source scaling |
| Dẫn Tiên high Mị Lực guide & role | quality caps unchanged, but new marginal guide Mị Lực and high-tier guide supply changes | **P1** | compare achieved 500/2500 guide thresholds, actual cohort distributions and enhanced-quota usage; no silent 5% forever |
| Profession, production, work assignment | Thông Tuệ learning XP and Căn Cốt body source still typed, One Active Job | **P1** | preserve profession XP vs work speed vs actual yield separation, no double active mind training |
| UI / player explanation | `DisciplePresentationSnapshotV2.FOUNDATION_KEYS` hardcodes six; compact Android UI | **P1** | split compact Tam3/Tu4, birth/current, two budget receipts, Core breakdown, no fake 7th radar |
| Source A/JX assets, map visuals | no necessary renderer/art dependency on seven-value arithmetic | **P2** | do **NOT** touch asset or maps; only HUD labels after relevant simulation change |
| Scaling 1k–3k | new two RNG domains, seven floats/character, 30.10 stats ~50.27B HP before potentials | **P2** | lazy derived stats, int64/floating safety, UI large-number compact formatting and snapshots; no per-tick 3k stat full-sheet recalc |

**Important:** Some combat items are not yet present as actual V2 consumers; their fixed-value changes are a **catalogue/audit requirement**, not a claim every new weapon is already implemented.

## 3. Corrections to D7-2P numbers and assumptions

### 3.1 Two budgets are separate; initial quality is one source-owned roll

Quality SOURCE ordinary **65/25/8/1.8/0.2%**; Dẫn Tiên guide2500 boosted **35/25/20/15/5%** until enhanced quota. Fallback SOURCE_GACHA **42/30/18/8/2%** when Guidance off; SOURCE_FATE **50/28/14/6/2%**. Unchanged.

New two-pool proposed grade intervals remain:
| Grade | Original six-score band | Tam Căn B3 (3 axes) | Tứ Tính B4 (4 axes) |
|---|---|---|---|
| Phàm Thường | 120–359 | 60–179 | 80–239 |
| Xuất Chúng | 360–599 | 180–299 | 240–399 |
| Thiên Kiêu | 600–999 | 300–499 | 400–666 |
| Tuyệt Luân | 1000–1799 | 500–899 | 667–1199 |
| Nghịch Thiên | ≥1800, genuine long tail | ≥900, no hard cap | ≥1200, no hard cap |

Grade-first then **independent U_int pool totals conditional on grade** for ordinary four finite bands. Each pool's own 3/4-value internal split constrained to approx 0.5×–3× its group mean; deterministic subdomain seeds, no cross-pool transfer or compensation. This is precisely two point wallets, NOT one shared seven-stat wallet.

### 3.2 Critical arithmetic correction — fractional permanent attributes

**DO NOT** use proposed `Q_normalized=round(6*(S3+S4)/7)` as runtime authority; old `FoundationSystem` quality uses **floating totals**. Rounding can promote old `Q_old=359.6` to 360, against SOURCE threshold 360.

Use instead:
```text
S3 = current_aptitude + current_constitution + current_mind_nature
S4 = current_potential + current_comprehension + current_fortune + current_charisma
Q_raw = 6.0*(S3+S4)/7.0     # NO round and no integer conversion
quality_id = old_thresholds(Q_raw)
```
**Migration** old saves with six present stats: `mind_birth = sum(old_six_birth)/6.0`, `mind_current = sum(old_six_current)/6.0`, retain floats and preserve six original values. Then `Q_raw ≈ old_six_sum` up to safe floating arithmetic. Need boundary tests for 359.999, 360.0, 599.999, 600.0, 999.999, 1000.0, 1799.999 and 1800.0; no false promotion/demotion. Do not reroll old Trait/Root/Fate or force an old disciple into new B3/B4 birth envelopes: existing migration profiles are **grandfathered**.

### 3.3 New two-pool birth changes WITHIN-GRADE score shape (measured)

Clean-room independent Python simulations, 50,000 old six-pool births and 50,000 new two-pool births PER finite grade. Values below are % of newborns whose equivalent Q lands in the **upper 10% of that grade's score range**.

| Grade | SOURCE-like old 6-way Q uniform | New 2 independent uniform pool totals | Effect |
|---|---:|---:|---|
| Phàm Thường | ~9.91% | **1.89%** | upper-tail less common |
| Xuất Chúng | ~10.04% | **2.02%** | upper-tail less common |
| Thiên Kiêu | ~9.90% | **2.02%** | upper-tail less common |
| Tuyệt Luân | ~10.11% | **2.06%** | upper-tail less common |

This happens because the sum of two independent uniforms concentrates toward its midpoint. **Grade odds remain the same**, but growth to the next grade may take longer for many recruits. It is not accurate to claim this change has NO effect on postbirth quality/rarity experience.

**Recommended design disposition:** deliberately accept the more concentrated interior for the first **dual-pool content pilot**, because the primary request is independent strong/weak group builds; do NOT present it as preserving original within-grade Q distribution. Monitor rates of born-near-top, permanent-quality promotions and effective training times. **No automatic XP multiplier/threshold nerf or hidden pity** is authorized to offset it. If owner prioritizes full within-grade Q parity, that becomes a different **coupled** two-pool sampler; do not silently compromise true pool independence.

### 3.4 Correct the very rare Nghịch Thiên tail while keeping distinct wallets

Old source Nghịch-Thiên Q long tail: start 1800 with width1200, with 12% probability advance to the next block and double its width, repeat. The earlier two-pool doc proposed rolling that *tail depth twice independently*. That unnecessarily suppresses truly extreme elites.

**Refined recommended rare-law:** roll **one tail BLOCK (depth and range) shared by the grade**, with exactly the existing 12%-continue rule; THEN roll **one Q3 and a distinct Q4 independently within the selected block**. Convert `B3=ceil(Q3/2)`, `B4=ceil(2*Q4/3)`; both budgets separate, no point transfer. This preserves the shared **rarity depth/event** (not points), while allowing large Tam/Tu differences inside the rare stratum.

Synthetic comparison **120,000 forced Nghịch-Thiên each scheme**, fixed seed: probability normalized Q≥30,000 was ~0.013% old vs ~0.012% corrected shared-depth sampler. Earlier independent-depth variant gave ~0.0008% in same experiment. These are exploratory estimates with very small tail counts, NOT precise population constants; focus on preserving the explicit 12% depth law, not overstating far-tail Monte Carlo precision. Validate tail by exact event-depth distribution and seeded fixtures, not only P90.

### 3.5 Joint talents and Balance (does NOT change base grade odds)

Two-wallet freedom can make high Tu Vi EXP (Tư Chất) + high Tu Vi Core strength (Tiềm Lực) coexist more often than the old single-wallet contract. A clean-room crosscheck on four finite grades (50k per grade) found P(Tư Chất≥200 AND Tiềm Lực≥200) approximately:
- old single-six: Thiên Kiêu **1.456%**, Tuyệt Luân **14.522%**;
- new dual-pool: Thiên Kiêu **2.916%**, Tuyệt Luân **24.44%**.
Weighted over ordinary grade odds, plus long-tailed Nghịch candidates, earlier new-pool estimate is about **0.835% of ordinary recruits**. This is an important **increase in double-specialist frequency**, which may change farm/survival and player preference. It should not be "corrected" by inventing an undocumented negative correlation between Tam and Tu totals.

Căn Cốt paid-body economics: SOURCE `DiscipleProgressionBalanceV2` R01 total10,000,000 Body EXP, dedicated training source1,500/min, `DiscipleBodyTrainingFacilityV2` cost **1 Spirit Stone/min**. At C0, raw training minimum ~**6,667 active sim min / 6,667 Stones**; at C100, BodyEXP×1.20 -> ~**5,556 active min / 5,556 Stones**, saving ~**1,111 sim min and Stones** per equivalent 10-million-EXP objective. This ignores slot occupancy, floor gates, actual activity interruptions, other sources, preexisting surplus and buffs; not a real calendar-time promise. Proposed +0.025%/point BodyCore would then be an additional benefit. **PENDING owner numeric decision:** keep +2.5% BodyCore/100 only if per-realm paid-resource and PvE tests prove it not a dominant body build; otherwise first fallback is **0 direct BodyCore bonus**, keep SOURCE +20% natural BodyEXP/100.

### 3.6 ×100 HP, ATK, DEF migration is independent and must be atomic

User-directed new Tu Vi Realm base **10,000 / 2,000 / 1,200**, corresponding Body base **9,000 / 300 / 700** (ratio-preserving interpretation), total unclothed R1.1/R1.1 P0,C0 = **19,000 HP, 2,300 ATK, 1,900 DEF**. Realm only affected by P×0.0005, Body only by proposed C×0.00025. G unchanged = `1.65^(r-1)*1.03^(f-1)`. Existing current code is still 100/20/12 + 90/3/7, and Potential multiplies both pieces, so moving to V3 is **not a label rename**. 
- All monster Core anchors, true skill/direct damage formula, healing/shields/DoT/reflect, gear fixed bonuses, player HP sync, revive rules and AI healing thresholds must migrate coherently.
- Current SOURCE Hồi Xuân pill +55 and legacy economy heal +55 (some personal service +10 HP). Proposed +5,500 for +55 / +1,000 for +10 ONLY to retain percentage equivalence under ×100. No silent code change without a separate owner-approved CARE reconciliation.
- PR24 CARE commits downed to **HP1 + Injury1 with 120-tick recovery**. Do NOT naively ×100 HP1; do not rescale downed/actively injured snapshots to free HP while migrating. For regular living HP use verified old HP fraction. Active encounter settlement and partial crash recovery must use one version-specific schema; stop/restore rather than convert half an encounter midflight.
- 30.10 both tracks with P/C0 gives Core HP about **50.27 billion**, ATK ~6.086 billion, DEF ~5.027 billion: display as compact formats, avoid int32 assumptions in UI/serialization, retain numeric finite guards.
- No ×100 for TuVi EXP, Body EXP, stone wages, item counts, skill cooldowns, RNG percentages or satiety. Keep pill daily cap 1,000,000/disciple, One Active Job, canonical Warehouse & scheduler, exactly once.

## 4. Additional cross-system safeguards

**Birth / recruitment:** never re-roll seven stats on candidate acceptance; update `CandidateState.to_disciple` and pending candidate migration. Distinct RNG subdomains must preserve Root, Bloodline, Physique, Fate, Trait, profession talent and stable profile seed history. Conditional Dẫn Tiên boost quality curve and Nghịch quota unchanged; **Mị Lực guide supply distributions change**, so measure role occupancy and probability of 625,1250,2500 main guide charisma under real recruitment. The fate source's old 70% `fortune-highest` 6-way swap cannot stay literal without cross-pool transfer; **propose 70% Cơ Duyên is largest within Tứ Tính only**, explicitly a source-rule migration; not generic loot bonus.

**XP / gate:** 30 TuVi realms×10 + 30 Body realms×10 remain independent; new Tâm Tính does not mint free EXP. Tư Chất SOURCE +0.25% natural TuVi/point, Căn Cốt SOURCE +0.20% natural BodyEXP/point, fixed TuVi medicine +10,000 unchanged; one natural Body source/min validated. TuVi 29 major gates have SOURCE chance table and +5pp same-gate failure pity; Body gates deterministic. Proposed Mind tier +1pp and high stability +1pp need separate real event owner and official fixtures; no indirect Body chance changes.

**Mental/Luyện Tâm:** adding a new 0..100 stability gauge alongside Mood/Needs does **not** establish another autonomous work action or generic negative state. Mental statuses must have explicit tags, status consumers and receipts; Tĩnh Tâm may only become One Active Job after a separate scheduler/content packet. No compulsory third 30×10 track, no save-load infinitely repeatable mental XP on bosses/breakthroughs. First check whether existing social mood/trait/debuff systems already own equivalent state; avoid duplication. Mark all mental-birth & progression values PROPOSED until these owners exist.

**Combat:** preserve existing 16 registered CombatStatsV2 channels and 10 elemental resistances. Current MapBattle basic attacks consume attack-speed with discrete 0.25s step; learned cast/cooldown consumer integration still requires audit. Baseline crit 5% ×1.50 and no ordinary general hit/miss. Never copy some MMO's Dodge/Accuracy into Combat V2 by implication. Separate boss direct damage context and actual support/tank participation from stat-score inflation.

**Production/economy/gear:** Thông Tuệ increases profession learning, **not** work output per cycle; Cơ Duyên is one meaningful event roll, not per-tick mining bonus; Mị Lực doesn't directly set loyalty. The V2 discipline of fixed-value versus natural EXP remains. Fixed equipment ATK/DEF and health-restoration costs must be reviewed when scale increases; real inventory, resources, salary, forge, loot receipts remain unchanged until explicitly modeled.

**Performance & visuals:** one canonical stat-source provenance sheet, cached/lazy 1000–3000 characters; no duplicate derived stat copy under UI. `DisciplePresentationSnapshotV2` hardcodes six keys and labels: a full reader/writer plus UI seven-field migration is required, not just seven texts or a radar overlay. Keep Android landscape 1280×720 readability and no Source A image/renderer work in this design packet.

## 5. Required hard gates BEFORE approving CODE/COMPLETE BALANCE

G0 **Authority gate:** verify current merged main and Codex recovery release; no overlapping writers on DiscipleState, SaveService, SimulationState or combat.  
G1 **Quality gate:** source probabilities by source and Dẫn Tiên + quota unchanged, every new two-pool birth in the authored grade, old six-save exact **fractional** quality preservation, no duplicate candidate or seed shift.  
G2 **Distribution gate:** 50k–250k deterministic births per SOURCE via Godot 4.7.2, conditional B3/B4 score correlation near zero within each finite grade, top-of-grade tail shape documented, long-tail depth law verified, valid high-high / high-low pair frequency.  
G3 **Causal gate:** Tư Chất XP only / Căn Cốt Body XP and optionally BodyCore / Tiềm Lực RealmCore only / Thông Tuệ profession / Cơ Duyên event / Mị Lực social; fixed XP unchanged and permanent increases rederive quality exactly once.  
G4 **Combat/economy gate:** scaled monsters and HP/ATK/DEF; +55/+10 healing fixed packets upgraded only after user approval; 1v1/3v3/6vBoss TTK, Injury HP1 recovery, Body cost/resource vs CC0/100/500/2500, role builds, Boss contribution, same level ±1.  
G5 **Save/rollback gate:** versioned schema, old save backups, exactly-once offline/reload, live PvE save at recovery boundary, no partial stat multiplier, no mental event replay.  
G6 **Owner visual gate:** seven values visible, two distinct groups, before/after birth attributes, truthful HP/progress and provenance, physical Android touch and Windows owner acceptance.

## 6. Decision ledger after audit

**NOW DESIGN-SELECTED**: Tam Căn and Tứ Tính as **two true separate birth point budgets**; 3+4 dimensions; one source-owned rarity roll; keep 5 original odds and qualitative percent distribution; normalize current seven-score on original six-stat thresholds with **no rounding**; preserve cross-system authority and no eighth stat.

**NUMERIC CANDIDATES RECOMMENDED FOR OWNER REVIEW**: pool ranges 60–179/80–239, 180–299/240–399, 300–499/400–666, 500–899/667–1199, rare ≥900/≥1200 plus **shared 12% rarity depth**; Căn Cốt direct +2.5% BodyCore/100 remains **conditional** on PvE/Stone economics; mind recovery/mental gate percentages remain separately **NOT SIGNED-OFF**. This supersedes older independent **rare-depth** math and rounded Q math. No implicit extra drop odds.

**UNCHANGED OWNER DIRECTION**: TuVi RealmCore base10000/2000/1200; Potential only RealmCore; Combat V2 result authority; 30+30 progression, Injury0/1/120, One Active Job, Warehouse/scheduler/save, future content must use real sources.

**BLOCK CODE / FULL GAME BALANCE PASS** until G0–G5 produce authentic official Godot and rollback evidence after Codex master recovery; a Markdown audit is not code permission or an observed gameplay PASS.

The objective of this packet is to **lock what we can safely lock about the two-budget design**, identify numeric differences honestly, and prevent accidentally overwriting other existing game mechanisms.