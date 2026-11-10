# PR72 V5.5/V5.6 production and economic reconciliation — 2026-11-10

**Branch:** `integration/pve-p0-playable-ui-20261103`. **Authority:** one BuildingSystem, WorkforceSystem, WarehouseSystem, EconomySystem and canonical SaveService. No main merge/secondary authority. Owner-approved designs are compared with actual source, but are **not** all declared live.

## Source audit / confirmed deficits

| Contract | Owner-locked V5.5/V5.6 target | Exact baseline runtime source (2026-11-10) | Disposition |
|---|---|---|---|
| Mine Thanh Thiết | 10,000 per 60 simulation min | Lv1 2 units/timer, default Economy-A 10 ticks | NOT BALANCED |
| Forest Linh Mộc | 8,000 per 60 min | Lv1 2 units/timer, default Economy-A 10 ticks | NOT BALANCED |
| Field Linh Cốc | 2,500 per 60 min | 5/10 ticks basic per plot, startup cost 3 Stones | NOT BALANCED |
| Field Thanh Linh Thảo | 2,000 per 90 min | 3/12 ticks basic per plot, startup cost 4 Stones | NOT BALANCED |
| Field Tử Vân Thảo | 1,000 per 180 min | 3/24 ticks, Field >=Lv10, startup cost 14 Stones | NOT BALANCED |
| Slots/assignments | 1 disciple per Field plot; V5.5-D 6-person simulation uses 2 Mine + 2 Field + 2 Forest | Mine/Forest 2 starting worker slots, Field 4 plots/slots, +1/5 levels. Code reserves one plot per worker | SLOT RULE CODED; NO CLAIM ALL SIX AUTO-ASSIGNED |
| Profession EXP | Pay after genuine output to Warehouse | Mine/Forest base 10/job (learning factor), Field 8/10/16 times modifiers | CODED; regressions before final HEAD |
| Facility upgrades | Real costs, timers, major milestones | All three player-paid upgrades implemented, Forest cost is still Mine provisional | CODED/PILOT |
| Sources | 630 V5.6-G material slots, 270 design profiles | 11 matching IDs in runtime, only registered 4+4 Mine/Forest selections; 619 unregistered design slots | DESIGN_HOLD; NO FAKE MATERIAL |
| Alchemy | earned resource -> Warehouse -> recipe -> consumer | 8 early authored graded recipes, 111 IDs not craftable until real sourced materials and progression | LOW REALMS CODED; 111 HOLD |
| LT2/W2/T2 | 30 stages, W2 floor >=2x LT2/job; debt on insufficient Sect funds, separate taxation | Economy-A wage pilot 2 per job, separate market daily quota 20 units (<30 disciples), or up to 240 (>=30), no approved full tax/cashflow | ECONOMY GAP; NO RAISE WITHOUT FUNDING |
| Offline/Save | 60/90/180 min and no double settlement | Official Windows runner used injected time; true wall-clock physical PC not yet accepted | SIMULATED PASS prior SHA; PHYSICAL PENDING |

## Economic contradiction — why not blindly scale rewards / wages

At Lv1 with two active workers in each producer and a nominal 10-minute timer, **theoretical** Mine/Forest upper-rate is 2 units * 2 workers * 6 batches/hour = 24 units/hour each, before nonwork factors, worker availability, rounding, reserves, or auto policy. The locked target would require approximate scale ratios 416.7x Mine and 333.3x Forest. Field yield/period also differs by tens of times from the approved 60/90/180-minute target. These are *ratio estimates*, not observed game yields.

The current NPC sale cap under 30 disciples is 20 units/day (and up to 240 units/day at 30+). At the best currently sellable reference 34 Stones/unit, the optimistic ceiling is 680/8,160 Stones/day; low-rank items sell for less. V5.5-D W2 begins at 2,000 Stones/job and extends to 17,842,000 Stones/job at tier 30. LT2 range 1,000→8,921,000 Stones/minute was approved as design, **not sustainable in this runtime**. Existing 500 initial Stones are a one-time grant, not repeatable income. The Stage-30 model needs real revenue sources, sinks, staged unlocks, and explicit source IDs before activating production numbers or W2/T2.

Do not conflate design source profiles (270) with actual Mine/Forest/Field instances or manufacture late-realm loot, materials, upgrades, cultivation milestones, or trade prices.

## Direct CODE packet: receipt-based unpaid wages

- **EconomySystem:** `unpaid_work_wages` reads original persisted wage receipts and later payment receipts. `pay_work_wage_arrears` transfers *only* existing Sect Stones to an existing worker, respects reserve/personal balance, supports partial repayment and stable request-ID replay, and persists through existing Economy-A receipt map. Original wage receipts/ticks remain unchanged; cashflow counts repayments at actual transaction tick.
- **Main Hall UI:** a real `EconomyA_PayWageArrears` button shows unpaid value and allows real payment, disabled without a payable balance; save uses the existing canonical runtime.
- **QA:** `godot/tests/simulation/sx_w2_wage_arrears_save_test.gd` tests two historical unpaid wage receipts, real Warehouse sale income, zero-funds guard, partial repayment, cold Save/replay, day cashflow, and receipt invariants. The QA fixture only prepares an unpaid historical ledger; no game loot/Stone creation changes. Linked to existing `economy-a-playable.yml` official Godot 4.7.2.

**Scope exclusions:** no production quantity/timer reset, no tax formula, no new materials, no 30-tier fantasy balance, no SaveService/SectState schema change, no new branch/merge.

## Required gates

1. Official Godot 4.7.2 parser/import; strict W2 test + original Economy-A tests; report exact SHA.
2. Cumulative O9/O8/O7/O4/GP01/SAFE Source→Warehouse→Alchemy→Consumer→Save regression, with any independent failure accurately labelled.
3. Before changing actual rates, make one source-gated, income-funded V5.5 staged table per building + worker and model 60/90/180 min, 1/7/30 days, 30 tiers, population 6/30/90/200/400. Verify nonnegative stock/treasury, affordable W2, tax sinks and late-tier material provenance.
4. Windows 10 true 1280×720 mouse/FPS/RAM and 60/90/180 minute physical elapsed; Intel `ig11icd64.dll`, Android touch/landscape remain PENDING USER.

**QA evidence note:** Source inspection proves code presence only. Never mark actual Godot PASS until run with strict exit=0 and matching SHA.