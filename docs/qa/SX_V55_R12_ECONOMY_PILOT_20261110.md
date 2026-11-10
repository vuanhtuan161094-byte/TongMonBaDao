# SX-V55 R1/R2 earned-work economy — direct PR #72 implementation and funded-source HOLD

## Important correction: W2 floor, not extra wages — current authoritative accounting

The original V5.5-D `08_SoCaiT2W2` defines W2 as `max(0, wage_floor - LT2_gross)` paid by Sect if funded, **not an extra per-job payment**. The earlier pilot's `34 × 2,000 = 68,000` daily wage entry below was an implementation/accounting error, preserved solely as dated development history. It was corrected in source commit `3eb5de3c`. For the now-verified 60/90m bulk jobs, **W2 topup=0**. r1 Sect gross tax 1,008,000/day; after current 34 Stone seed cost and best-case 160 Stone NPC sales, pre-upgrade Sect result is **1,008,126/day** (not 940,126), and r2 is **2,016,126/day** (not 1,880,126). Latest source-backed expense accounting is in [SX_V55_R12_CASH_MATERIAL_BALANCE_20261110.md](SX_V55_R12_CASH_MATERIAL_BALANCE_20261110.md); original 04_NangCap342 applies **×1000** on new upgrade Stone pricing only under internal pilot. Existing gameplay is unchanged. Neither prior simulation nor this update permits public LT2/W2/T2 activation.


Date: 2026-11-10. Branch `integration/pve-p0-playable-ui-20261103`; Draft PR #72, no merge. Official runtime Godot 4.7.2. **This pilot is implemented behind a persisted default-OFF internal flag, and not player-live**. All live older Economy-A, legacy Save and existing bulk-production opt-in stay unchanged.

## Verified r1/r2 focused success / separate Combat cumulative blocker

- **[SX #42785575442](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42785575442)** at exact SHA `c9312ce4371c05d1d6ffdc8e31d6f5d05377c623` **completed/FAILURE only at the final P3.7 cumulative**, while **ALL** new R1/R2 work-income / corrupt-snapshot / cold Save and 1/7/30-day economic-overfunding tests **completed/SUCCESS**, as did all other SX-specific focused steps. [#42785618931](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42785618931) at `95c026d26b00f2610c25ff7a860480dde3b240b9` has the same scoped PASS/overall FAIL split.
- **Actual cumulative failure log**: `SCRIPT ERROR: Parse Error: Could not resolve script "res://labs/combat_lab/combat_lab_arena.gd"` within `combat_lab_focused_test.gd`/CombatLab. This occurred in pre-existing/concurrent Combat/VFX code, not the R1/R2 source money ledger, which had already passed on these exact runs. **Do not label FULL or entire game PASS, do not mask, skip or alter Combat tests to clear the dashboard.** Combat owner must resolve separately.
- [SX #42786362866](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42786362866) on `ce78e5a4afefbdcf6406857091a0242178194668` adds an anti-forgery guard: exact canonical bulk `plan_id`, producer/site and snapshot `minutes == finish_tick-started_tick` before Warehouse output. **New r1/r2 focused test step SUCCESS**, full P3.7 still requires exact final outcome.
- [SX #42786438587](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42786438587) on `2e9b0e7e621157c6794ffc215769cb674c092f7d` additionally rejects a coherently tampered gross/tax/net/minute snapshot. Its **new focused r1/r2 and 1/7/30-day financial pressure steps have completed/SUCCESS**; exact whole-workflow conclusion must be checked.

## Source / governance

Original V5.5-D 30 exact realm source: `godot/data/economy/v55d_30_realm_reference.json`, `status=APPROVED_DESIGN_ONLY_NOT_LIVE`, `runtime_activation=false`. Only stages r1 and r2 are represented in this guarded runtime pilot; r3–r30 have no verified source pack. Historical PR #8 supplied the five real producer plans already merged into **one** existing `BuildingSystem`. No duplicate wallet, tax ledger, scheduler, warehouse or SaveService is created. Original stage values are:

| Realm | LT2 earned gross per legitimate production minute | W2 completed job minimum | T2 modeling rule |
|---|---:|---:|---|
| r1 Phàm Nhân | 1,000 Stones/min | 2,000 Stones/job | 70% Mine; 30% Forest; 40% Field |
| r2 Luyện Khí | 2,000 Stones/min | 4,000 Stones/job | 70% Mine; 30% Forest; 40% Field |
| r3–r30 | exact source rows exist | exact source rows exist | **NO RUNTIME ACTIVATION / MATERIAL SOURCE HOLD** |

**No player-enabled economy toggle**. `SectState.economy_a_policy["sx_v55_r12_economy"]` is persisted but defaults false. `EconomySystem.configure_v1` denies enabling it; only explicit isolated Godot test fixtures set the flag. Bulk production remains an independent owner opt-in with default false. No blank/legacy job may retroactively earn LT2.

## Actual work/warehouse/receipt algorithm (r1/r2 test gate)

`EconomySystem.sx_v55_r12_work_snapshot` pins the authenticated V2 cultivation realm, genuine opt-in producer plan, production facility type, validated time window, gross/minute, T2 rate and W2 floor **at new job START**; an empty snapshot means old work remains under historical Economy-A. The same existing `BuildingSystem` stores this snapshot alongside the Mine/Forest timed job or Field growing plot. Field normalization preserves it across cold Save/Load. At completion the **actual Warehouse deposit** is required. `sx_v55_r12_can_settle` guards exact workbook rate arithmetic, tax, wage, max-wallet headroom, duplicate income/wage receipt and plan/site identity **before material delivery**. After genuine delivery, `sx_v55_r12_settle` commits to canonical `state.sect.spirit_stones`, `worker.spirit_stones` and **existing** `economy_a_receipts`:

- New *earned-work external source*: gross = frozen scheduled valid-minute envelope × original LT2 for that realm. Gross is recognized only upon a real produced batch; no login/free-idle grant.
- Tax is a worker-to-Sect allocation of the same gross, not separately generated money.
- W2 is a Sect-to-worker transfer. It creates an existing-kind `wage` receipt with `due` and `paid`, so original arrears settlement remains canonical; a lack of funds creates genuine debt without money invention.
- Conservation: `delta(Sect Stone + worker Stone) = gross` for a completed work batch, excluding separately debited seed costs. Repeating a processing tick or same-time cold Save must not duplicate output, cash or XP. An altered saved snapshot is rejected **before** Warehouse delivery.
- Existing jobs without snapshots use the original `settle_work_wage` wage=2 Stone, unchanged; no old job mutation.

### QA gates

- Prior **production compatibility/full P3.7 PASS**: [SX #42783779016](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42783779016), exact gameplay SHA `6b556723e7da4c90c331803d8e1510803774a57b`, all steps SUCCESS, including offline 60/90/180, B3 CARE, canonical Save and P3.7 cumulative. This run **did not execute the NEW R12 test**.
- `godot/tests/simulation/sx_v55_r12_real_labor_tax_wage_save_test.gd`: real recruited V2 worker, Mine r1 / Forest r2 / Field r2, tampered receipt fail-closed, at-start snapshot, Warehouse + money conservation, genuine wage/tax receipts and cold Save replay. First new-test run [#42784751595](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42784751595) caught **a QA fixture stale Forest handle** on reload (Godot runtime `Out of bounds get index '0'`, test line 151). This did **not** establish a runtime income exploit. Fixed in `c9312ce4371c05d1d6ffdc8e31d6f5d05377c623`, with fail-fast check `95c026d26b00f2610c25ff7a860480dde3b240b9`. Preserve failed run as evidence; do not call it PASS.
- On corrected SHA `c9312ce4371c05d1d6ffdc8e31d6f5d05377c623`, [SX #42785575442](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42785575442) has **both newly added focused test steps SUCCESS**, including `sx_v55_r12_funding_pressure_30d_test.gd` on exact original source values. *Full cumulative workflow verdict must be separately checked and recorded before claiming whole-run PASS*.
- `godot/tests/simulation/sx_v55_r12_funding_pressure_30d_test.gd` is read-only 1/7/30-day scenario; it verifies source rates, the existing six-worker scenario, tax and wages without modifying state, Warehouse, receipts or any actual wallet.

## Economic risk — HOLD activation even if official technical tests PASS

The original workbook models 6 production workers ×360 active minutes per day, with 2 Mine +2 Forest +2 Field (one grain/one herb) and early real bulk yield; assumes no work interruption or secondary consumer labor. In the QA-only r1/r2 source scenario: 34 actual producer jobs/day; seed cost=34 Stones/day; optimistic NPC sale ceiling=160 Stones/day.

| Scenario | Gross earned-work payout/day | T2 tax entering Sect/day | W2 wage transfer/day | Sect treasury surplus/day before upgrades/other spending |
|---|---:|---:|---:|---:|
| r1 | 2,160,000 | 1,008,000 | 68,000 | **940,126** |
| r2 | 4,320,000 | 2,016,000 | 136,000 | **1,880,126** |

The 30-day upper-bound Sect surplus is 28,203,780 Stones at r1 or 56,403,780 at r2 **before upgrades, Alchemy worker allocation and all other real sinks**. This is a significant **overfunding / inflation risk** relative to today's provisional upgrade/service prices; passing arithmetic and Save tests **does not** mean a playable economy is balanced. Do not copy 30-stage workbook income into live code or set the pilot policy true for players until actual resource sinks, 30d+ progression and economic constraints are validated. A bona fide work-minute attendance/pause cross-check under active PvE is a further validation gate before player-live revenue.

## Source/recipe dependency gates

Verified early real bulk sources: `thanh_thiet` (Mine), `linh_moc` (Forest), `linh_coc`, `thanh_linh_thao`, `tu_van_thao` (Field Lv10 for latter); five additional historical r1/r2 Mine/Forest material selectors have actual timed source routes but are **not** automatically included in the five bulk plans. Only 8 early graded medicine recipes are authored. Other 111 graded recipe identifiers and 619/630 proposed material identities have no verified fully authored production/loot acquisition route; **r3+ remains closed**. Do not create source IDs, drops, material-sale payouts or imaginary NPC demand based solely on spreadsheet rows.

**Physical device QA:** actual Windows 10 E: 1280×720 Godot/Intel `ig11icd64.dll`, elapsed offline 60/90/180 minute resume and Android landscape all **PENDING USER**. No branch/merge; no SaveService code change.
