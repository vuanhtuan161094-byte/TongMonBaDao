# SX-V55-R12 — actual-source cash/material balance and denomination reconciliation

**Date:** 2026-11-10. **PR:** #72, branch `integration/pve-p0-playable-ui-20261103`, Draft/unmerged. **Status:** r1/r2 technical corrections in QA-locked pilot; **player activation HOLD**. Godot 4.7.2 exact-SHA evidence below. No source r3+, new money registry, new Warehouse, scheduler, or SaveService.

## Authoritative sources and conflict resolution

1. Original `TMB_V5_5D_KIEM_TOAN_SAN_XUAT_EXP_KINH_TE_30_CANH_GIOI.xlsx`, `01_Khoa30CG`: r1 LT2 1,000 Stone/valid work-minute, W2 *minimum* 2,000/job; r2 LT2 2,000 and W2 floor 4,000. The user locked all 30 rows as **design**; `godot/data/economy/v55d_30_realm_reference.json` continues `runtime_activation=false`.
2. Original `08_SoCaiT2W2`: **W2 is a TOPUP shortfall**, `max(0, W2_floor - actual LT2 gross)`, paid from Sect Treasury only if funded. It is NOT added for every completed 60/90/180-minute job. `total_taxable = gross_LT2 + topup_paid + real RB1`; **RB1 has no verified source in this pilot**, therefore 0. T2 BASE rates from `07_KichBan720` apply only to stage 1–2 internal test: Mine 70%, Forest 30%, Field 40%; no public rate selector yet.
3. Original `04_NangCap342`: monetary upgrade price is `upgrade_cost()["spirit_stones"] × 1,000` for NEW jobs. It is **not** authorized to retroactively charge a saved in-flight upgrade. Separate earlier user-approved PR #8 common material consumption uses `linh_moc/thanh_thiet/thanh_linh_thao ×1,000`; this differs from workbook material-unit presentation. Both agreed commitments are kept distinct; no further scaling of rare items, Linh Cốc or Tử Vân Thảo.
4. Original `06_MoPhong720` (day 1 r1): seed spend about **240,000 Stone/day** in its assumed active production cadence. Current live `SpiritCropRegistry` has grain 3, herb 4, Tử Vân 14 Stone/plot. Under the *specific* 6-worker 2+2+2, 6 grain +4 herb jobs/day modeled here, **current actual seed debit is 34/day**. These are **not** equivalent producer/crop schedules or authored source-price tables. Do **not** multiply real seeds by an arbitrary factor to force equality; original V5.4 seed-source CSV / V5.3 crop model and job cadence must be reconciled first.

## Implemented code (all player OFF)

- `EconomySystem.sx_v55_r12_can_settle` computes `W2_topup_due=max(floor-gross,0)`; `topup_paid=min(due,max(0,SectTreasury-reserve))`; `T2_tax=floor((gross+topup_paid)*site_rate/100)`. Worker change = `gross+topup_paid-tax`; Sect change = `tax-topup_paid`. Thus `Δ(Sect+worker)=gross` exactly; only **genuinely funded topup** enters taxable gross and wage `due/paid` receipts. All long jobs with LT2 greater than W2 floor create **zero topup debt**, not fictitious wages. Existing arrears service remains in the same Economy-A receipts and can pay real shortfall later.
- `BuildingSystem.sx_v55_upgrade_cost` now applies original cash denomination ×1,000 **only while internal r1/r2 economy is enabled**. Actual debit is still via `can_start_upgrade`/ `start_upgrade` and the existing Warehouse; simulated cost previews never grant stock. Production opt-in alone **does not** activate this or any new LT2.
- Anti-replay and tamper guards remain: freeze real `production_plan_id`, site, valid duration at job start; only completed authentic Mine/Forest/Field Warehouse delivery can claim cash/XP; no old-job retroactive LT2, no r3/r30 new resources.
- Independent QA `sx_v55_r12_real_labor_tax_wage_save_test.gd` verifies **real Mine r1 and Forest/Field r2** LT2, zero additional W2 for long jobs, unit-tested 1-minute W2 funding preview, forged receipt rejection, **real funded Mine Lv1→Lv2 debit** and cold Save once-only. `sx_v55_r12_funding_pressure_30d_test.gd` models source-backed 1/7/30-day resource/Stone capacities and exactly sourced first upgrade wave.

## Four *source-grounded* founding upgrades

| Building Lv1 → Lv2 | New pilot Stone (04_NangCap342) | Ore units, bulk consumer | Wood units, bulk consumer |
|---|---:|---:|---:|
| Đại Điện | 580,000 | 24,000 | 29,000 |
| Linh Điền | 21,000 | 4,000 | 7,000 |
| Mỏ | 24,000 | 7,000 | 5,000 |
| Linh Lâm | 24,000 | 7,000 | 5,000 |
| **One upgrade wave** | **649,000** | **42,000** | **46,000** |

With exactly 2 Mine + 2 Forest × 360 **effective** work minutes/day and bulk r1 routes: **120,000 ore + 96,000 wood/day** theoretical, before interruption, planting, crafting and real scheduling. There are enough produced material units for this one upgrade wave; subsequent waves are **not** assumed affordable or sourced.

## Money stress scenario — W2 is a floor, not double pay

Six workers ×360 **valid** producer minutes/day, 2 Mine +2 Forest +2 Field, 34 producer jobs. Optimistic NPC sell ceiling = 20 actual ore/day ×8 Stone =160/day. Seed debit uses **current actual** 6 grain ×3 +4 herb ×4=34 Stone/day, not the V5.5-D 240k illustrative seed scenario.

| Value/day | r1 Phàm Nhân | r2 Luyện Khí |
|---|---:|---:|
| LT2 from valid work (external earned source) | 2,160,000 | 4,320,000 |
| T2 allocated to Sect | 1,008,000 | 2,016,000 |
| **W2 topup actually due for 60/90m batches** | **0** | **0** |
| Field seeds (current 10 plots) | 34 | 34 |
| Maximum actual NPC sale receipts (not guaranteed) | 160 | 160 |
| Sect surplus before any upgrade (optimistic) | **1,008,126** | **2,016,126** |
| Sect after **one** four-building upgrade wave, day 1 | **359,126** | **1,367,126** |
| Optimistic Sect after 30d, assuming **only** one upgrade wave | **29,594,780** | **59,834,780** |

**Critical:** These are **upper-bound scenarios**, not 30 days of executed game; no forging/alchemy worker time, rare catalyst, extra upgrades, PvE downtime, supply bottleneck or actual active-time proving included. Positive gross and even original ×1,000 upgrade pricing do NOT justify opening the faucet. Source workbook first-day seed assumption and current gameplay differ drastically. A real 0%-tax/no-market scenario still requires cash to plant and can softlock.

## QA

- Existing whole [SX #42786438587](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42786438587) completed SUCCESS at `2e9b0e7e621157c6794ffc215769cb674c092f7d` before this W2/cost correction.
- `3eb5de3c55171c3d61fc904c748ef1ac53d3e4d3`: corrected W2 floor. `abae69978a21aff77ec557ca531b474775b529c1`: original monetary denomination for NEW internal pilot upgrades. `d57dd84767cd2ef7a62ba87b221da5a481826071`: actual Mine upgrade debit and cold Save test. `74a99628820e0d9a1d86936c1b8636742a27c401`: source-backed initial-cost/1/7/30d stress audit. Source test `P37Factory` omits a Main Hall, unlike real LiveRuntime; `7bdffcd5a74a9a79a53ea6dfc5b2931359cde40b` corrected fixture using `ensure_main_hall`, with **no user money/item grant**.
- Initial [run #42805974594](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42805974594) FAILED **new stress-test fixture** (`source-backed four founding facilities missing or not Lv1`), prior R12 and offline tests PASS. Do not hide this historical failure. Corrected exact-SHA [#42806303901](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42806303901) has R12 labor/Save and new source money/material scenario both focused SUCCESS at first review; check **whole** run conclusion before calling cumulative PASS.
- Windows 10 E:/Intel/1280×720 actual GUI, wall-clock 60–180min offline, and Android device are **PENDING USER**.

## Next gate before player activation

Reconcile the *genuine* V5.4-B1 seed prices and crop execution cadence; verify active work-minute accounting under PvE interruptions; run earned-source source/sink scenarios with Alchemy/Forge, repeated upgrades, real staff scheduling, zero-tax, no-NPC, 1/7/30d Save and 30-disciple roster. Then expose configurable T2 0–100% and only activate the explicitly funded policy. **Do not invent r3 materials, NPC buyers or future coins.**
