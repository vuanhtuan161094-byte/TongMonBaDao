# P1.6 — Sect Life, Needs & Resource Pressure

Date: 2026-09-30
Status: IMPLEMENTED / AWAITING RUNTIME GATE

## Goal

Make sect population and logistics create real management pressure. P1.6 must not add decorative bars: medicine, supplies and lodging must change autonomous decisions or simulation outcomes.

## Scope

### 1. Medicine

- Sect medicine is a bounded shared stock.
- Paid sect healing still uses the locked P0 money transfer.
- P1.6 additionally requires one medicine unit for a successful HEAL.
- If medicine is empty, an injured disciple falls back to REST instead of HEAL.
- Medicine consumption never changes total money.

### 2. Expedition supplies

- Sect supplies are a bounded shared stock.
- A departure from the sect consumes one supply if available.
- Supplied travel costs less stamina than unsupplied travel.
- Empty/low supplies reduce HUNT utility.
- Empty/low supplies penalize dangerous-region utility more than safe-region utility, so shortage can change destination choice.

### 3. Lodging capacity

- Lodging capacity is separate from maximum disciple capacity.
- Population above lodging capacity reduces REST recovery for every disciple.
- Recovery penalty is bounded and deterministic.
- The player can spend supplies to add lodging slots.
- Therefore supplies have a real allocation tradeoff: expeditions versus long-term capacity.

### 4. Logistics role integration

- P1.5 `logistics` is now an actual sect-support role.
- Every fixed logistics interval, assigned logistics disciples replenish medicine/supplies.
- Production is bounded by stock caps.
- The system scans role assignments only on the fixed interval, not every relationship or every possible pair.

### 5. Player priority

The player chooses one logistics priority:

- `balanced`: moderate medicine + supplies;
- `medicine`: more medicine, fewer supplies;
- `supplies`: more supplies, less medicine.

Priority must measurably change output.

## Initial P1.6 state

- Medicine: 18 / 60.
- Supplies: 24 / 90.
- Lodging: 6 slots.
- Priority: balanced.
- Lâm An is assigned logistics in P1.6 only.
- Earlier factories are unchanged.

## Scale contract

- No population x population needs table.
- Needs are sect-level shared state.
- Per-disciple persistent P1.6 state is limited to a temporary departure-supply marker in existing metrics.
- Logistics production runs once per 30 ticks and scans only role assignments.
- Lodging pressure is O(1) from population count and capacity.
- Region resource pressure is O(1) per candidate region.

## Required behavioral consequences

P1.6 is not complete unless all are measurable:

1. Empty medicine changes an injured decision from HEAL to REST.
2. Medicine-backed healing consumes medicine while preserving money conservation.
3. Zero supplies can change a controlled region decision from dangerous to safe.
4. Unsupplied travel costs more stamina.
5. Medicine/supply priorities create different logistics output.
6. Population above lodging capacity reduces REST recovery.
7. Spending supplies on lodging removes/reduces that recovery penalty.
8. Save/load preserves all P1.6 state.
9. Same-seed continuation remains deterministic.
10. P0–P1.5 regressions remain green.

## Exclusions

P1.6 does not add:

- hunger/thirst bars per person;
- morale;
- salaries;
- building construction trees;
- production chains;
- crafting;
- combat-team V2;
- cultivation realms/techniques;
- romance/factions/betrayal;
- premium currency or production art.

Those systems should only be opened when they have concrete gameplay consequences and can reuse the bounded P1.6 resource-pressure foundation.
