# TÔNG MÔN BÁ ĐẠO — Combat Base ×100 · Tiềm Lực chỉ Tu Vi · Lục Duy/Thất Duy và Luyện Tâm

**Ngày:** 2026-10-23  
**Nhãn:** Owner-directed numeric redesign + static arithmetic / source audit. **DOCS-ONLY — KHÔNG CODE, không sửa PR #24/#25 hay nhánh recovery, không merge, không CI/FULL, chưa có Godot runtime PASS mới.**  
**Base:** `main@29b5fba448b0178cb520a4ada44b375b4b934e31`. Trạng thái Code là của main tại thời điểm đọc; CARE PR #24/#25 là draft, không suy diễn đã merge.  
**Đối chiếu:** `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md` (authority precedence), `docs/DISCIPLE_MASTER_SCHEMA.md`, `docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`, `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`, `docs/BODY_CULTIVATION_V2_SPEC.md`, `docs/COMBAT_STATS_V2_SPEC.md`, `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md`; mã `CombatStatsV2`, `FoundationSystem`, `DiscipleGeneratorOpenPoints`, `DiscipleRealmProgressV2`, `MonsterCatalogueV2`, `MapBattleV2`, `DiscipleState`. Kiểm toán ban đầu: `docs/audits/TMB_COMBAT_BASE_V2_STAT_BALANCE_AUDIT_2026-10-23.md` tại nhánh `docs/combat-base-v2-audit-20261023`.

## 0. Ledger SOURCE / OWNER / PROPOSED

- **OWNER NEW DIRECTION**: nâng thang bộ cơ sở Tu Vi **100/20/12 → 10,000/2,000/1,200** (HP/ATK/DEF) và tách **Tiềm Lực chỉ thuộc Tu Vi**, không buff Body Core. Các luật cũ trái chiều phải đánh dấu SUPERSEDED ở gói code *được duyệt sau*, không sửa lén.
- **INTERPRETATION — TO CONFIRM AGAINST PLAYABLE BEFORE CODE**: Người dùng mô tả “HP và ATK x100; 10000 2000 và 1200 ban đầu”. Vì cả ba số đúng 100 lần 100/20/12, tài liệu hiểu đó là **RealmCore** chứ không mặc định tổng HP nhân vật là 10,000. Để giữ tương quan hai track, BodyCore 90/3/7 → **9,000/300/700**. Vậy nhân vật Tu Vi 1.1 + Body 1.1, Potential0: **HP19,000 / ATK2,300 / DEF1,900**. Nếu yêu cầu là *tổng* HP10k/ATK2k/DEF1.2k thì phải lập một gói tỷ lệ Core khác; hai phương án KHÔNG tương đương.
- **RECOMMENDED precise reading** “Tiềm Lực chỉ Tu Vi”: Tiềm Lực +0.05%/điểm (hệ số hiện có) nhân **chỉ RealmCore-derived HP/ATK/DEF**; không nhân BodyCore, trang bị flat, hay EXP tự nhiên/cố định. EXP tự nhiên Tu Vi đã thuộc **Tư Chất**, nên không cho Tiềm Lực double-source vào XP. Hệ số +0.05%/điểm được giữ cho đến khi owner đổi; **đã có chỉ đạo đổi đối tượng, chưa có CODE/migration**.
- **SOURCE six foundations** remain Tư Chất, Căn Cốt, Cơ Duyên, Thông Tuệ, Mị Lực, Tiềm Lực. Căn Cốt **đã** chỉ buff EXP Luyện Thể +0.20%/điểm; không buff BodyCore HP/DEF trực tiếp. “Thêm Luyện Tâm/Thất Duy” hiện là **OPEN DESIGN**, không phải lệnh tự code trục thứ bảy.
- **No other locks here**: old approved (G=1.65^{r-1}1.03^{f-1}), DEF mitigation K=2×ATK, 16 combat stats, 30×10 two tracks, one source/one sim minute, one warehouse/time/save remain unchanged by docs alone.

## 1. HP 10,000 có đủ không? — phải xét tỷ lệ và action budget

```text
G(r,f) = 1.65^(r-1) × 1.03^(f-1)
RealmCore = {HP:10000, ATK:2000, DEF:1200} × G(cultivation)
BodyCore  = {HP: 9000, ATK: 300, DEF: 700} × G(body)
PotentialFactor = 1 + 0.0005×P
Core_new = RealmCore×PotentialFactor + BodyCore
Final = (Core_new + valid independent flat bonuses) × (1+valid channel percent_add) [clamps as in code]
```

**Không nhầm thang số với cân bằng:** Nếu tăng ×100 cho toàn bộ HP+ATK+DEF của cả đệ tử/quái, giữ hệ số damage/attack speed, thời gian hạ quái và số đòn cần đánh **không đổi**. Baseline 190HP/23ATK/19DEF mới thành 19,000HP/2,300ATK/1,900DEF; mirror hit ≈1,627.69 so với cũ ≈16.28, khoảng 12 đòn để chết cả hai bên trong phép tính 1v1 không crit/skill. Nếu lấy **tổng** HP10k, ATK2k DEF1.2k mà không giữ tỷ lệ nguồn cũ, đó là **thiết kế TTK mới** (mirror basic ~1,538.46, khoảng 7 hits), không thể gọi là ×100 tương đương.

| Both tracks at r.f, potential0 | HP mới | ATK mới | DEF mới |
|---|---:|---:|---:|
| 1.1 | 19,000 | 2,300 | 1,900 |
| 2.1 | 31,350 | 3,795 | 3,135 |
| 5.1 | 140,828 | 17,048 | 14,083 |
| 10.1 | 1,722,301 | 208,489 | 172,230 |
| 30.10 | ~50,271,634,462 | ~6,085,513,645 | ~5,027,163,446 |

**Damage/mitigation proportions** stay the same if all relevant direct actors/target stat sources were correctly rescaled. If player only ×100 but monster remains old, monsters die almost instantly and damage received is negligible; if HP/ATK are ×100 but DEF not rescaled, mitigation shifts as well. `MonsterCatalogueV2` uses base `190/23/19` × species × tier × G; every source-dependent conversion and historical save handling must be audited, NOT blindly find/replace numbers.

**Fixed healing and item flats DO NOT auto-scale as part of the core formula:** Current Hồi Xuân Dan +55HP is 55/190≈28.95% old bare starting HP, but 55/19,000≈0.2895% after ×100. To keep same relative value, the *candidate* is **+5,500HP**; this is **PROPOSED, not approved**. At injured HP1, old full recovery ~4 doses (189/55); new with unscaled +55 requires ~346 doses (18,999/55), with +5,500 remains 4. CARE +55 and satiety10 are previously approved, so **must be separately re-approved**, not silently edited. Equipment +3ATK pilot would fall from ~13% of 23 to ~0.13% of 2,300 unless item template flats are also rescaled or redesigned. Same review for healing skills, shields, fixed DoT/reflect, HP1 injury (do not replace HP1 by HP100 during migration), HP percent rescale, reward/cost balance, integer-safe displays and save/recovery. Fixed +10,000 Tu Vi **EXP** is separate and MUST NOT ×100 because Combat HP changes.

At max dual track 30.10 HP ~50.27 billion; floats/serialization/UI compact notation and numeric guard must be verified on target Android. This does not prove balance of high-rank gear/boss/skills.

## 2. Tiềm Lực: exact old vs new

**SOURCE current** in `CombatStatsV2.derive`:
`(RealmCore + BodyCore) × (1 + 0.0005×P)`. P100 = +5% total; P1,000 = ×1.50 total; P2,500 = ×2.25 total; P10,000=×6 total. No cap/DR curve authorized.

**OWNER target interpretation**:
`RealmCore × (1 + 0.0005×P) + BodyCore`. P100 still +5% **Realm portion**, NOT +5% final sheet. At 1.1 (all scaled ×100):

| P | HP final | ATK final | DEF final | vs P0 HP/ATK/DEF |
|---:|---:|---:|---:|---|
| 0 | 19,000 | 2,300 | 1,900 | baseline |
| 100 | 19,500 | 2,400 | 1,960 | +2.63% / +4.35% / +3.16% |
| 500 | 21,500 | 2,800 | 2,200 | +13.16% / +21.74% / +15.79% |
| 1,000 | 24,000 | 3,300 | 2,500 | +26.32% / +43.48% / +31.58% |
| 2,500 | 31,500 | 4,800 | 3,400 | +65.79% / +108.70% / +78.95% |
| 10,000 | 69,000 | 12,300 | 7,900 | +263.16% / +434.78% / +315.79% |

This is an **unbounded linear open-point system** by previous owner choice. No new hard cap assumed. It may produce extremely wide PvE performance differences from high-potential disciples; test across P=0/100/500/1000/2500/10000 before assigning item/skill power budgets. The older 5%/100 rule remains the local Realm multiplier, not entire sheet gain. Tư Chất, not Tiềm Lực, controls **natural Tu Vi EXP**.

**Important:** If “chỉ Tu Vi” intended ONLY XP gain, not RealmCore HP/ATK/DEF, that would be a different request and collide with Tư Chất. Current recommendation assigns Tiềm Lực as Tu Vi **growth quality/stat power** only, avoiding duplicate XP channel.

## 3. Exact six Foundations source audit and separation

`FoundationSystem` already implements:
- **Tư Chất** `aptitude`: natural Tu Vi XP `1+0.0025×A` (100→+25%; 2,500→×7.25); fixed Tu Vi pills unchanged.
- **Căn Cốt** `constitution`: validated natural Body XP `1+0.0020×C` (100→+20%; 2,500→×6); BodyCore growth itself is controlled by gained Body realm/floor; fixed Body XP unchanged. Thus connection to Luyện Thể **ALREADY EXISTS**. Suggest maintain **exclusive Body progression source**, not add an untested passive direct HP/DEF boost in the same request.
- **Thông Tuệ** `comprehension`: learning/mastery/profession XP `1+0.0015×I` (100→+15%; 2,500→×4.75), not all skill outgoing damage.
- **Tiềm Lực** `potential`: current affects Realm+Body Core, owner now restricts to RealmCore only. P100→+5% RealmCore (not XP).
- **Cơ Duyên** `fortune`: `RNG(0..9999)+fortune-difficulty` for meaningful events, not blanket loot chance.
- **Mị Lực** `charisma`: social & Dẫn Tiên recruitment, not global combat or passive loyalty.

**Recommended causal separation:** Tư Chất = Tu Vi EXP speed; Tiềm Lực = Tu Vi-derived combat stat quality; Căn Cốt = Body EXP speed; acquired Body realm = Body combat stat magnitude; Thông Tuệ = learned skill/occupation progression; Cơ Duyên = events; Mị Lực = social. None of six should accidentally scale a second channel (fixed XP rewards, item flats, HP, work yield). If owner later wants Căn Cốt to directly buff BodyCore, that is NEW coefficient requiring an explicit alternative budget test, not implied by “ứng với Luyện Thể”. For comparison only, P100 at proposed +0.05%/pt BodyCore would add HP450/ATK15/DEF35 at 1.1 while additionally giving +20% Body XP; it can double-compound long-run Body power, so NOT recommended without simulation.

**Current birth/generation and quality are six-column hardcoded**: `FoundationSystem.DIMENSIONS`, `total_values()`, quality thresholds 360/600/1000/1800, candidate/disciple birth snapshots and save schema; `DiscipleGeneratorOpenPoints._distribute_total` uses exactly six buckets and envelope min floor(total/12), max floor(total/2). UI six-axis radar, recruitment weights/quality, migration, deterministic RNG, tests all presume six. Changing to 7 during master recovery creates overlapping source writers and long-term save impacts.

## 4. Luyện Tâm vs Thất Duy: avoid conflating a training track with an innate dimension

**CHOICE M1 — RECOMMENDED NOW:** KEEP canonical **Lục Duy** and design **Luyện Tâm** as a separate progression/state mechanism, just as Tu Vi & Luyện Thể are progress tracks rather than birth-point axes. A separate acquired `tam_canh` or `dao_tam_progress` can support credible consumers: mental-affliction resistance (only mental-effect tags, not global immunities), breakthrough stability for a genuinely authored heart-demon encounter, adverse-state recovery, discipline/meditation utility. If no live consumer, keep as DESIGN-ONLY and **no free combat stat**. No new mandatory third 30×10 grind or hard progression gate is presumed. Test differentiability from `Thông Tuệ` (learning speed), `Căn Cốt` (body training) and the existing Effect Resistance channel before code.

**CHOICE M2 — OPTIONAL Thất Duy:** Add seventh innate/permanent attribute called **Tâm Tính / Đạo Tâm tư chất**, whose owner controls natural `Luyện Tâm` progress or mental stability only; Luyện Tâm itself is the learned track, **not** the name of an innate ability. Requires source/consumer and independent payout/test. Consider one prototype effect: learning/meditation efficiency *only where mental training action is real*, no blanket Effect Resistance or unconditional stat buff. No coefficient locked. Seven dimensions would trigger versioned expansion:
1. foundation model version, `CandidateState/DiscipleState` persistence, generator, migration;
2. deterministic new-birth distribution and old six-stat historical snapshot preservation;
3. quality formula and thresholds, Dẫn Tiên odds semantics; existing total thresholds apply only to six, not blindly seven;
4. new seventh UI radar, labels and gameplay breakdowns, save/replay/QA;
5. source-to-consumer tests to avoid duplicate `Thông Tuệ` or artificial 7th-stat inflation.

A proportional **illustration**, if wanting similar points PER DIMENSION, is new total ≈ old×7/6 and thresholds ~420/700/1167/2100 in place of 360/600/1000/1800; **NOT an approved replacement**. If total unchanged, each new dimension's expected value falls 6/7 (~14.3%) and existing effects slow. If old existing disciples receive a random extra dimension and raw seven-sum determines quality, they may upgrade for free; if assigned 0, new and old progression become incomparable. Need versioned, source-backed migration with tests, not hot-patch a list.

**CHOICE M3 — explicit third 30×10 mental realm:** NOT RECOMMENDED until there are enough unique progression consumers, mental encounter content, resources, UI and AI, because it triples long-run mandatory ladders and duplicates realm/body gate burden.

## 5. Preimplementation integration gates (coordinate with recovery owner, not now)

**G0 snapshot**: pinned latest merged main and recovered code, `AGENTS.md`, old and current source branches; record source maps for single writer.
**G1 formal owner selection**: confirm exact x100 interpretation (RealmCore vs final displayed sheet), exact Target Potential law; decide M1/M2 and mental consumers. These are not grounds to overwrite code now.
**G2 dependent audit**: `CombatStatsV2.REALM_BASE/BODY_BASE`, `MonsterCatalogueV2`, cloned base in content/skill/AI, player HP sync & old saves/Injury1, medical/pill +55, fixed gear stats, lifesteal actual HP, skill healing/shields, combat preview/loot, UI large numbers; distinguish unchanged relative mechanics from affected absolute numbers.
**G3 mathematical + Godot regression AFTER owner CODE authorization**: all 300 levels independent Body/Realm; P=0/100/500/1000/2500/10000; +1/−1 realm, normal/elite/Boss; TTK, damage taken, healer throughput, role/build fairness, no overflow; compare 1/3/6 actor fights; direct scaling ×100 roundtrip for ordinary monster; save/old-save rollback.
**G4 owner balance gates**: desired fights per region, survival time, potion burden, skill & gear percentage-budget calibrations are OPEN. Retain unchanged canonical V2 battle authority, no new boss loot owner, no duplicate clock/save.
**G5 user visual acceptance**: display original six stats/legacy correctly; seven-axis UI only if M2 is explicitly chosen. No Source A, recovery, PR #24/#25 edits in this branch.

## 6. Suggested next step

**Keep this branch as a DESIGN discussion** until a clearly bounded CODE packet is allowed after recovery. Numeric base ×100 and potential TuVi-only are current user's direction; mind system and seventh-stat admission remain candidates. Do not equate a README recommendation with gameplay authorization; do not declare economy, boss and 16 dependent channels balanced without fixtures.
