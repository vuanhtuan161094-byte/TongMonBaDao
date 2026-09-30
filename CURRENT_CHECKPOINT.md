# CURRENT CHECKPOINT

Date: 2026-09-30

## Project state

- Step 13 Technical Architecture & Development Roadmap: LOCKED.
- Step 14 P0 Prototype Specification: LOCKED.
- Step 15 Repository Bootstrap + P0 Foundation: LOCKED / PASS.
- Step 16 P1.1 Goal + Personality: LOCKED / PASS.
- Step 17 P1.2 Population + Recruitment + Player Choice: LOCKED / PASS.
- Step 18 P1.3 Relationships + Behavioral Impact: LOCKED / PASS.
- Step 19 P1.4 Consequential Memory: IMPLEMENTED / AWAITING RUNTIME GATE.
- Step 20 P1.5 Organization + Teams + Leadership + Roles: IMPLEMENTED / AWAITING RUNTIME GATE.
- Step 21 P1.6 Sect Life + Needs + Resource Pressure: IMPLEMENTED / AWAITING RUNTIME GATE.

Locked baseline before P1.4: `bbdca12b3f1efd14d31982810859d22f51990ff4`.
P1.4 implementation checkpoint before P1.5: `b1fc434c6e05cac451b60ab11c4c855476e00842`.
P1.5 implementation checkpoint before P1.6: `541b67ccc9f847b4c9c44d43ea82317b5668c20e`.

## Architecture locks

- Engine: Godot 4.7.2 / GDScript.
- Godot owns simulation/gameplay authority.
- Seeded deterministic simulation remains mandatory.
- Save/load, invariants and economy conservation remain mandatory.
- P0, P1.1, P1.2 and P1.3 are locked regression baselines.
- P1.4, P1.5 and P1.6 may be implemented while the user is away from the Windows machine, but none may be marked PASS without real Godot runtime evidence.
- New systems remain opt-in so earlier behavior paths stay available.
- No mechanic is complete if it adds only narrative, title, bar or resource state without measurable simulation/player-decision consequence.

## Locked P0–P1.3

P0, P1.1, P1.2 and P1.3 are PASS / LOCKED with recorded local Godot `4.7.2.stable.official.ed1daf0bf` evidence.

Latest locked P1.3 evidence:

- `P1.3 RELATIONSHIP + BEHAVIOR IMPACT TEST PASS`;
- seed 717171;
- 2,000 total test ticks;
- 18 sparse directed relationships;
- 1,948 relationship events;
- affinity/trust/respect behavior impact PASS;
- personality-shaped relationship response PASS;
- player companion assignment impact PASS;
- save/load, deterministic continuation, invariants, money conservation and scene smoke PASS.

## Pending P1.4 — Consequential Memory

Implemented, not runtime-verified.

Key contracts:

- meaningful bounded memories only;
- repeated memories consolidate;
- maximum 24 memories per disciple;
- personality shapes memory importance;
- memories change later region/social behavior;
- player-created shared experience can outlive a cleared companion order;
- save/load + deterministic continuation;
- dedicated P1.4 interaction screen.

Pending command: `Sync-P1-4.cmd`.

## Pending P1.5 — Organization + Teams + Leadership + Roles

Implemented, not runtime-verified.

Key contracts:

- deterministic small teams;
- one disciple belongs to at most one team;
- team size cap 6;
- direct disciple -> team lookup;
- player can move members and appoint leaders;
- trust/respect shape leadership influence;
- memory can reinforce or oppose formal authority;
- hunter/logistics/guard roles change real utility;
- new recruits can be assigned to teams/roles;
- save/load + deterministic continuation;
- dedicated P1.5 interaction screen.

Pending command: `Sync-P1-5.cmd`.

## Active P1.6 — Sect Life + Needs + Resource Pressure

P1.6 makes population and logistics create a real management problem instead of decorative resource bars.

### Shared sect resources

P1.6 keeps three bounded management axes:

- medicine stock;
- expedition supply stock;
- lodging capacity.

The P1.6 feature flag and resource state live inside `SectState`, preserving compatibility with earlier optional SimulationState fields and old save payloads.

Initial P1.6 state:

- medicine 18 / 60;
- supplies 24 / 90;
- lodging 6;
- logistics priority `balanced`;
- Lâm An receives the logistics role in `P16Factory` only.

Older factories remain unchanged.

### Medicine consequence

- P0 money transfer for healing remains authoritative.
- P1.6 additionally requires one sect medicine unit.
- Medicine stock 0 makes an injured disciple choose REST instead of HEAL.
- Successful P1.6 HEAL consumes exactly one medicine.
- Medicine never changes money conservation.

### Supply consequence

- Leaving the sect for a hunt consumes one supply when available.
- Supplied travel costs 7 stamina; unsupplied travel costs 13.
- Empty supplies reduce HUNT utility.
- Empty supplies apply a danger-scaled region penalty strong enough to change a controlled destination from Hắc Phong Cốc to Thanh Trúc Lâm.
- Low supplies apply a smaller pressure penalty.

### Lodging consequence

- Lodging is separate from maximum disciple capacity.
- If population exceeds lodging, REST recovery is multiplied by `lodging / population`, bounded to a minimum of 45%.
- Player may spend supplies to add lodging slots.
- Cost: 8 supplies per slot.
- This creates a direct allocation tradeoff between expedition readiness and long-term population support.

### Logistics role integration

- P1.5 logistics becomes a real sect-support role.
- Production occurs once every 30 ticks, not every disciple decision.
- Only role assignments are scanned.
- Output is capped by resource storage caps.

Player logistics priorities:

- `balanced`: +1 medicine and +2 supplies per logistics worker / cycle;
- `medicine`: +3 medicine and +1 supply;
- `supplies`: +1 medicine and +4 supplies.

Changing priority must measurably change output.

### Scale contract

- needs are sect-level, not N x N;
- no global relationship or memory scan for upkeep;
- resource pressure is O(1) per region decision;
- lodging pressure is O(1);
- logistics scans assigned roles only once per 30 ticks;
- temporary supplied/unsupplied departure state reuses disciple metrics and is cleared after travel.

### P1.6 verification contract

1. Full P0/P1.1/P1.2/P1.3/P1.4/P1.5 gates must PASS first.
2. Same-seed P1.6 state and continuation must remain deterministic.
3. Empty medicine must change injured behavior from HEAL to REST.
4. Medicine-backed healing must consume medicine and preserve total money.
5. Zero supplies must be able to change a controlled dangerous-region choice to the safe region.
6. Unsupplied travel must cost more stamina than supplied travel.
7. Medicine/supply logistics priorities must produce measurably different output.
8. Population above lodging capacity must reduce REST recovery.
9. Spending supplies on lodging must remove/reduce that recovery penalty.
10. Resource bounds and needs statistics must satisfy P1.6 invariants.
11. Save/load must preserve needs flag, stocks, lodging, priority, event count and statistics.
12. P1.6 interaction scene must launch in Godot 4.7.2.
13. All earlier money/invariant contracts remain green.

Authoritative command: `Sync-P1-6.cmd`.

`Sync-P1-6.cmd` intentionally chains P1.4 and P1.5 before P1.6. One future local run therefore verifies every currently unverified phase.

Expected successful end markers include:

- `P0 FOUNDATION GATE: PASS`
- `P1.1 GOAL + PERSONALITY GATE: PASS`
- `P1.2 RECRUITMENT + PLAYER CHOICE GATE: PASS`
- `P1.3 RELATIONSHIP + BEHAVIOR IMPACT GATE: PASS`
- `P1.4 MEMORY + CONSEQUENCE GATE: PASS`
- `P1.5 ORGANIZATION + PLAYER MANAGEMENT GATE: PASS`
- `P1.6 SECT NEEDS + RESOURCE CONSEQUENCE TEST PASS`
- `P1.6 SECT NEEDS + RESOURCE CONSEQUENCE GATE: PASS`
- `P1.6 GATE: PASS`

## P1.6 exclusions

P1.6 does not add hunger/thirst bars per disciple, morale, salaries, building trees, crafting/production chains, combat-team V2, cultivation realms/techniques, factions/betrayal, bosses, premium currency or production art.

## Completion status

- P0: PASS / LOCKED.
- P1.1: PASS / LOCKED.
- P1.2: PASS / LOCKED.
- P1.3: PASS / LOCKED.
- P1.4: IMPLEMENTED / AWAITING RUNTIME GATE.
- P1.5: IMPLEMENTED / AWAITING RUNTIME GATE.
- P1.6: IMPLEMENTED / AWAITING RUNTIME GATE.

Runtime verification for P1.4–P1.6 is intentionally deferred until the user returns to the Windows/Godot 4.7.2 machine. Do not mark any of them PASS before a real `Sync-P1-6.cmd` run completes successfully.
