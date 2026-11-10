# SX-V55-ECO — Exact 30-realm source reconciliation (10 Nov 2026)

**Scope:** PR #72 one gameplay branch, Godot 4.7.2, *design-vs-runtime audit*. This report changes **zero** live production/wage/tax parameters. It references the original `TMB_V5_5D_KIEM_TOAN_SAN_XUAT_EXP_KINH_TE_30_CANH_GIOI.xlsx`, tab `01_Khoa30CG` (30/30 source rows extracted from the Project file index); it does **not** reverse-engineer missing V5.4 raw CSV materials. Canonical machine-readable rows: `godot/data/economy/v55d_30_realm_reference.json` (DESIGN_ONLY, `runtime_activation=false`).

## What actually exists in the game

- Legitimate Mine/Forest source IDs: 4 Mine selections and 4 Forest selections in `BuildingSystem`, including five V5.5-D-preserved IDs; initially Lv1 for basic and Lv10 for upper sources. Original V5.6-G 630 materials include only **11** registered reference IDs; 619 are not source-backed in Godot. The 507 proposed/generated IDs are **not** original V5.4 CSV provenance. Do not create those resources from their names.
- The real Spirit Field has 3 crops (`linh_coc`, `thanh_linh_thao`, `tu_van_thao`) with Lv1/Lv10 gates. Output settles into one canonical Warehouse. 8 low-rank graded recipes are authored; 111 recipe identities remain design hold. Never describe those 111 as craftable.
- Current Economy-A defaults to 2 Stones per genuine wage job, 10-minute Mine/Forest base timer, an actual market sale cap of 20 units/day for a small roster (240 at exactly 30 workers). The most valuable currently sellable item has unit price 34 Stones, hence **680** Stones/day small-roster / **8,160** at exactly 30 disciples are *best-case trading ceilings*, not guaranteed income. Existing plant, upgrade, skill and service sinks further reduce budget.
- Original V5.5-D `00_TongQuan` assumes initial 0 Stones and 40 wood/ore, whereas current gameplay has the historical one-time 500-Stone starter grant in TechniqueSystem. That grant is not sustainable daily revenue. Original V5.5-D `04_NangCap342` prices are scaled by ×1000; gameplay uses current pilot prices. Do not port design-only prices in isolation.

## 60/90/180 minute producer mismatch (one unmodified baseline worker; theoretical only)

| Source | Window | Approved design units | Current basic units/cycle | Current basic cycle | Current unmodified whole-cycle output | Status |
|---|---:|---:|---:|---:|---:|---|
| Mỏ Thanh Thiết | 60 min | 10,000 | 2 | 10 min | 12 | HOLD: ~833× rate difference |
| Linh Lâm Linh Mộc | 60 min | 8,000 | 2 | 10 min | 12 | HOLD: ~667× rate difference |
| Linh Điền Linh Cốc | 60 min | 2,500 | 5 | 10 min | 30 | HOLD: ~83× rate difference |
| Linh Điền Thanh Linh Thảo | 90 min | 2,000 | 3 | 12 min | 21 | HOLD: ~95× rate difference |
| Linh Điền Tử Vân Thảo | 180 min | 1,000 | 3 | 24 min | 21 | HOLD: ~48× rate difference |

These output estimates ignore work speed, active-job interruptions, multi-worker capacity, stock demand and per-field bonuses. Actual throughput is driven by validated job start/finish and Warehouse settlement, not these idealized outputs. **No live rate is changed by this report.**

## Exact LT2/W2 stage ledger and unfunded market comparison

Original V5.5-D `01_Khoa30CG` source rows are below. The **T2 column is a design scenario only**, not a new tax in the game. It assumes the spreadsheet's six-worker allocation (2 Field, 2 Mine, 2 Forest), 360 valid work-minutes per worker/day, and 40% / 70% / 30% site tax rates (its `07_KichBan720` BASE example). Under this *hypothetical* scenario each site's gross daily work value is 720×LT2, total gross 2160×LT2, and theoretical tax 1008×LT2. Seed/upgrade costs, commodity sinks, labor attendance, high-rank sources and actual NPC inventory are **excluded**, so these are accounting projections, not playable income or net profit.

| Realm | Level minimum | LT2/min design | W2/job floor | EXP/h Mine design | EXP/h Forest design | Gross/day 6 workers (design) | T2/day scenario (design) | Runtime material route |
|---:|---:|---:|---:|---:|---:|---:|---:|---|
| 1 Phàm Nhân | 1 | 1,000 | 2,000 | 49 | 49 | 2,160,000 | 1,008,000 | early sources exist; rate not active |
| 2 Luyện Khí | 10 | 2,000 | 4,000 | 49.09 | 49.1 | 4,320,000 | 2,016,000 | early sources exist; rate not active |
| 3 Trúc Cơ | 13 | 3,000 | 6,000 | 52.2 | 52.2 | 6,480,000 | 3,024,000 | HOLD: r3+ source IDs absent |
| 4 Tử Phủ | 16 | 4,000 | 8,000 | 58.65 | 58.65 | 8,640,000 | 4,032,000 | HOLD: r3+ source IDs absent |
| 5 Kim Đan | 19 | 5,000 | 10,000 | 62.78 | 62.8 | 10,800,000 | 5,040,000 | HOLD: r3+ source IDs absent |
| 6 Nguyên Anh | 22 | 7,000 | 14,000 | 66.7 | 66.69 | 15,120,000 | 7,056,000 | HOLD: r3+ source IDs absent |
| 7 Hóa Thần | 25 | 9,000 | 18,000 | 71.45 | 71.45 | 19,440,000 | 9,072,000 | HOLD: r3+ source IDs absent |
| 8 Luyện Hư | 28 | 12,000 | 24,000 | 75.8 | 75.79 | 25,920,000 | 12,096,000 | HOLD: r3+ source IDs absent |
| 9 Hợp Thể | 31 | 16,000 | 32,000 | 87.82 | 87.79 | 34,560,000 | 16,128,000 | HOLD: r3+ source IDs absent |
| 10 Đại Thừa | 34 | 22,000 | 44,000 | 93.47 | 93.47 | 47,520,000 | 22,176,000 | HOLD: r3+ source IDs absent |
| 11 Nhân Tiên | 38 | 30,000 | 60,000 | 97.29 | 97.29 | 64,800,000 | 30,240,000 | HOLD: r3+ source IDs absent |
| 12 Địa Tiên | 41 | 40,000 | 80,000 | 102.55 | 102.56 | 86,400,000 | 40,320,000 | HOLD: r3+ source IDs absent |
| 13 Thiên Tiên | 44 | 54,000 | 108,000 | 107.81 | 107.81 | 116,640,000 | 54,432,000 | HOLD: r3+ source IDs absent |
| 14 Chân Tiên | 47 | 73,000 | 146,000 | 110.87 | 110.87 | 157,680,000 | 73,584,000 | HOLD: r3+ source IDs absent |
| 15 Huyền Tiên | 50 | 99,000 | 198,000 | 115.5 | 115.52 | 213,840,000 | 99,792,000 | HOLD: r3+ source IDs absent |
| 16 Kim Tiên | 54 | 134,000 | 268,000 | 122.12 | 122.12 | 289,440,000 | 135,072,000 | HOLD: r3+ source IDs absent |
| 17 Thái Ất Kim Tiên | 57 | 181,000 | 362,000 | 124.59 | 124.56 | 390,960,000 | 182,448,000 | HOLD: r3+ source IDs absent |
| 18 Đại La Kim Tiên | 60 | 244,000 | 488,000 | 130.96 | 130.97 | 527,040,000 | 245,952,000 | HOLD: r3+ source IDs absent |
| 19 Tiên Vương | 63 | 329,000 | 658,000 | 135.32 | 135.32 | 710,640,000 | 331,632,000 | HOLD: r3+ source IDs absent |
| 20 Tiên Đế | 66 | 444,000 | 888,000 | 139.25 | 139.24 | 959,040,000 | 447,552,000 | HOLD: r3+ source IDs absent |
| 21 Thần Nhân | 70 | 599,000 | 1,198,000 | 145.44 | 145.45 | 1,293,840,000 | 603,792,000 | HOLD: r3+ source IDs absent |
| 22 Chân Thần | 73 | 809,000 | 1,618,000 | 151.64 | 151.64 | 1,747,440,000 | 815,472,000 | HOLD: r3+ source IDs absent |
| 23 Thiên Thần | 76 | 1,092,000 | 2,184,000 | 187.1 | 187.11 | 2,358,720,000 | 1,100,736,000 | HOLD: r3+ source IDs absent |
| 24 Thần Quân | 79 | 1,474,000 | 2,948,000 | 194.45 | 194.45 | 3,183,840,000 | 1,485,792,000 | HOLD: r3+ source IDs absent |
| 25 Thần Vương | 82 | 1,990,000 | 3,980,000 | 198 | 198 | 4,298,400,000 | 2,005,920,000 | HOLD: r3+ source IDs absent |
| 26 Thần Hoàng | 86 | 2,686,000 | 5,372,000 | 209.14 | 209.15 | 5,801,760,000 | 2,707,488,000 | HOLD: r3+ source IDs absent |
| 27 Thần Đế | 89 | 3,626,000 | 7,252,000 | 216.5 | 216.5 | 7,832,160,000 | 3,655,008,000 | HOLD: r3+ source IDs absent |
| 28 Thần Tôn | 92 | 4,895,000 | 9,790,000 | 227.9 | 227.9 | 10,573,200,000 | 4,934,160,000 | HOLD: r3+ source IDs absent |
| 29 Hỗn Độn Thần | 95 | 6,608,000 | 13,216,000 | 235.37 | 235.36 | 14,273,280,000 | 6,660,864,000 | HOLD: r3+ source IDs absent |
| 30 Sáng Thế Chủ | 100 | 8,921,000 | 17,842,000 | 302.84 | 302.83 | 19,269,360,000 | 8,992,368,000 | HOLD: r3+ source IDs absent |

## Explicit blocker for W2/LT2/T2 activation

At Realm 1, a **single** W2 minimum wage is 2,000 Stones. A hypothetical six completed jobs imply at least 12,000 Stones in W2 floor, while current *best-case* material sale alone is only 680 Stones/day with a small roster, or 8,160 at exactly 30 disciples, before other sinks. An approved LT2 source must be tied to real, persisted valid work, with a genuine monetary faucet/claim that obeys conservation and Save/retry; simply crediting the wallet or raising merchant prices from unapproved design `market_value` is not acceptable. T2 tax percentages must be configurable/verified per worksite and can only assess realized gross. Until then, **LT2=DESIGN_HOLD; W2 stage wages=DESIGN_HOLD; T2=DESIGN_HOLD**, while the already implemented receipt-backed W2 **arrears plumbing** remains live.

Progression at Realm 3–30 also lacks genuine materials and worksite/source profile implementations; a design row cannot be used as an earned-source proof. The existing `wage_arrears_payment` path remains a real Sect→disciple transfer; it is not an income generator.

## Regression and evidence

- Official Godot 4.7.2 [SX 30-Realm source gate #42761936541](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42761936541): **WHOLE SUCCESS** on SHA `4eecd3961df0936db70f03772346adc38581afaa`. Import + strict GDScript parse, 30-stage source/test, `sx07_source_provenance_test.gd`, and `sx_w2_wage_arrears_save_test.gd` all completed successfully.
- Existing official P3.7 backend [#42757205292](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42757205292): SUCCESS on `7937f20c`. Existing O1/O3/O4/O5/O7/O8/O9 and GP01 at that SHA also SUCCESS. Economy-A long-run [#42757583660](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42757583660) was CANCELLED after several focused passes, not FULL PASS; older [#42757109807](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42757109807) SUCCESS at older SHA.
- **PENDING USER**: native Windows 10 Intel `ig11icd64.dll` risk, real 1280×720 mouse/FPS/RAM, true elapsed 60/90/180-minute offline recovery, Android device. No merge, no SaveService/gameplay source changes for this audit.


## Historical source reconciliation: original PR #8 Economy-V2 bulk authority

The original [PR #8](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/8) at SHA `b424d9dad96ec880037691d8163c0258c5667dc7` has a **real authored** `godot/src/simulation/building/production_plan_registry.gd` with exactly five plans: Mine Thanh Thiết 10,000/60, Forest Linh Mộc 8,000/60, Field Linh Cốc 2,500/60, Field Thanh Linh Thảo 2,000/90, and Field Tử Vân Thảo 1,000/180. The first four require building Lv1, while its **historical** Tử Vân plan requires Field Lv30 and cultivation/body tiers 3/4. PR #72's **current** field crop authority unlocks Tử Vân at Lv10. Those sources are in conflict; the active branch and later approved BAL-04A Lv10 gate win until the owner explicitly chooses another rule. **Do not import Lv30 gate from the unmerged PR.**

The historical registry also has `COMMON_CONSUMER_SCALE=1000` for `linh_moc`, `thanh_thiet`, `thanh_linh_thao`; `linh_coc` and `tu_van_thao` are *not* in that historical scaling set. Porting **only** bulk yield without corresponding actual Warehouse debits, pill/gear/seed consumer and NPC economy reconciliation would create a severe stock/progression imbalance. Similarly importing an arbitrary ×1000 cost without the funded bulk producer would softlock new players. PR #8 is **open/unmerged**, and its `ProductionPlanRegistry` is NOT present in PR #72's canonical live runtime. No parallel production authority was copied.

The actionable historical source has therefore been **identified**, but bulk migration is `DESIGN_HOLD` until a single-authority integration contract can explicitly pin 5 outputs + 5 durations + consumer debits and per-resource eligibility, assert old in-flight jobs remain unchanged, and demonstrate Stage-1/2 affordability and Save exact-once. The 30-realm V5.5-D source sheet is preserved as **reference data only**, and it does not manufacture missing r3+ sources.

## Final focused SHA evidence

- [SX V55 ECO #42761936541](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42761936541) on `4eecd396`: WHOLE SUCCESS with official Godot import, 30-realm source model, provenance + W2 real-Stock/Save regression.
- [SX V55 ECO #42762524763](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42762524763) on `a10f1a5c5f1be9ca4693a54d2a51b88b7397535f`: WHOLE SUCCESS with the additional five preserved-ID nontradeable/Lv3 HOLD checks and **strict real Hall button UI** plus canonical Save. Godot strict parser and runtime exit 0 for all steps.
- The source model's `PASS` means it correctly **detects five major output-rate mismatches** and correctly protects unverified IDs; it does **not** mean the locked 10k/8k/2.5k target or W2/LT2/T2 have been activated.


## SX-V55 implementation addendum — 2026-11-10, direct PR #72 / no merge

**Status: CODED + OFFICIAL GODOT 4.7.2 FOCUSED PASS; FULL cumulative/physical PENDING.** Earlier paragraphs accurately describe the previous source-only state; this addendum supersedes them for the **newly authorized** early bulk packet. Live source code changes were committed in `60117fd8` → `a912bc23` → `ac677793` → `af3db4f6` → `6523bc4b` → `53fdeb47`. No extra BuildingSystem, Warehouse, scheduler, state schema or SaveService has been introduced.

**Actual opt-in owner control**: Existing `SectState.economy_a_policy["sx_v55_bulk_production"]` is false by default (including old saves). Existing Hall UI `SXV55_EnableBulk` is a single player action, and its payload survives canonical Save. It creates neither currency nor resources, and already-running carry, timed work, field plots, alchemy jobs and previous goods retain frozen recipe/output/finish data. `B3MedicalAutoplayV1.validate` now accepts either original Tụ Khí 2-herb pending snapshots or exactly 2,000 paid herbs when the persisted bulk mode is on; 1,999 and other invalid snapshots remain hard rejected. Legacy B3 CARE strict receipts remain unchanged.

**Exactly five genuine producer targets activated for future jobs** in the existing `BuildingSystem`: Mine `thanh_thiet` 10,000 / 60 source ticks, Forest `linh_moc` 8,000 / 60, Field `linh_coc` 2,500 / 60, Field `thanh_linh_thao` 2,000 / 90, Field `tu_van_thao` 1,000 / 180 at its existing Field Lv10 paid milestone. Real work-speed and existing facility modifiers may change actual effective elapsed ticks/quantities. New-job EXP is targeted at approximately 49 EXP per active hour before profession multipliers and is awarded only after actual Warehouse deposit, not at job start. Nonbasic 5 original V5.5-D mineral/forest IDs retain old quantity and unlocks until independently authored; r3+ stays closed.

**Every new paid consumer reads the same state-gated input formula**: common `linh_moc`, `thanh_thiet`, `thanh_linh_thao` input amounts ×1,000 for new Alchemy legacy/graded (including Q catalysts but without scaling rare catalysts), Forge recipes and facility upgrades. `linh_coc`, `tu_van_thao`, rare beasts/Body, premium building milestones, Stone costs unchanged. Existing frozen Alchemy job input receipts are not rebilled. Current Alchemy and Forge UI, worksite yield/cycle previews and upgrade cost UI were updated to show *actual* new-mode authoritative costs, avoiding misleading legacy 2-unit/3-herb labels. No new 111 high-realm recipe identities or 507 proposed placeholder sources activated.

**Actual focused source→Warehouse→consumer QA:** `godot/tests/simulation/sx_v55_bulk_real_chain_save_test.gd` creates a genuine V2 recruit, starts Mine/Forest/three Field crop jobs, advances the canonical BuildingSystem timer, deposits actual 10,000/8,000/2,500/2,000/1,000 base units (crop lucky multiplier may increase), debits real Wood/Ore/Stones once for a Mine upgrade, pays for a legitimate 2,000-herb Tụ Khí Alchemy job, deposits the actual pill, uses it for 10,000 Tu Vi and 25/1,000,000 shared satiety, and checks idle/cold Save/replay/negative altered input. Its old carry and plot snapshots are preserved across switching and cold reload. **QA-only** Lv10 Field setting isolates the Tử Vân gate; live players must still earn and pay Lv10 upgrades.

**Exact-source monetary model:** `sx_v55_eco_faucet_sink_30d_test.gd` uses real code values (not fictitious production receipts) for a declared **theoretical** 6-worker schedule of 360 active sim min each/day: Mine x2 = 120,000 Ore/day; Forest x2 = 96,000 Wood/day; 1 grain = 15,000/day; 1 herb = 8,000/day. Two Hồi Xuân plus one Tụ Khí per day could consume exactly 8,000 herbs + 1 grain, **but require a separately allocated Alchemist or rescheduling**. Exact current NPC sale ceiling for 6 disciples is 20 × Thanh Thiết 8 = 160 LT/day, wages pilot 34 jobs × 2 = 68, seed spending (6 grain ×3 +4 herb ×4)=34; theoretical surplus +58/day before upgrades, alchemist, incomplete work, sources or other sinks. Initial 500 LT contributes once. Day1/7/30 maximum ending Treasury: 558/906/2,240 LT. Locked W2 r1 at 2,000 LT/job would require 68,000 LT/day, leaving **67,874 LT/day** funding deficit at the theoretical merchant cap. No r3–r30 LT2, W2 or T2 currency is minted or activated; tax percentages are still DESIGN_ONLY. Market sell prices and volume limits remain previous pilot; this is acknowledged, NOT a complete 30-tier economy.

**Focused Godot evidence:** [SX #42766477817](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42766477817) WHOLE SUCCESS at `355e26e5` for five source chain, real pill consumer, legacy/corrupted B3, Hall UI and Save. [SX #42767689261](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42767689261) WHOLE SUCCESS at `191229b0` for added 1/7/30-day economic model. **[SX #42767862613](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42767862613) WHOLE SUCCESS at `a965dadff641a1131ee984300f337cc56d3e8bd6`** for strict parser, five plans, actual paid Mine upgrade/cold Save, income-cost simulation, source provenance, real Hall UI, intentional-invalid B3 test exit0, W2 arrears/Save. Earlier failed runs [#42765223560](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42765223560), [#42765406190](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42765406190), [#42765676089](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42765676089) and [#42766075645](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42766075645) are retained as historical *fixed* QA failures, never called PASS. The source/model + UI acceptance gate at latest commit and **cumulative regression status must be checked by exact SHA**, not inferred.

**Still PENDING**: final pass of long-running P3.7/Economy-A/GP/compatibility Actions on later scene changes; actual owner Windows 10/Intel `ig11icd64.dll`, 1280×720 mouse and FPS/RAM, 60/90/180 minutes real elapsed offline, physical Android landscape; source provenance for V5.4 late realms. No branch created, no main merge, no fake resources/Stone, no SaveService code changes.



### Post-integration balance correction — 2026-11-10

- Verified that the legacy AUTO_DEMAND stock target is a **consumer-demand** target, not a producer-batch size. With new bulk yields, multiplying **all** crop stock targets by ×1,000 would overplant expensive `linh_coc` and `tu_van_thao`, whose actual recipes/needs remain unscaled. Fixed at `ad6724f151f5568b252ed89c372793313c71641a`: target `thanh_linh_thao` is 40→40,000 when the player opts in (matching actual ×1,000 herb requirement), while `linh_coc` remains 60 and `tu_van_thao` remains 20. The normal one active plot/one worker and pending output counting still apply. Added exact source assertion at `e6bef45dfcabc42d7bde4aefcb8defe2d2405e3c`.
- The user-facing 1280×720 Hall UI automated acceptance now clicks the actual bulk toggle once, verifies no automatic opt-in, checks authentic 10,000 Mine/8,000 Forest and 2,500/2,000 crops preview, Forge scaling and Alchemy scaled ingredient labels on the true scene. This was added at `0500e9a4cd37f3b2e31a95f0c9baf011410315b4`.
- Historical GP01 and GP02B1 cumulative failures on UI SHA `53fdeb47` were traced in their workflow logs to the original **Godot parser error in the QA-only 1/7/30-day script** (untyped loop day count), not a reported Mine/occupation contract assertion failure. Fixed the typed day count in `191229b0d3089ad25bc88fef33fd605546aa2742` with subsequent [#42767689261](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42767689261) whole SUCCESS. Do not rewrite them as pass on the old SHA.
- To establish the final integrated result, `.github/workflows/sx-v55-eco-source-gate.yml` now runs the repository's **entire P3.7 full cumulative regression** after all SX bulk, source, income, Hall UI, B3 and wage/Save tests, per commit `32319696b7c9c78b39cc291e1c6ec06f23ab69b5`. Await current exact-SHA CI verdict; owner PC 1280×720 Windows 10 Intel + Android remain PENDING USER.

