# CURRENT CHECKPOINT

Date: 2026-09-30

## Project state

- Step 13 Technical Architecture & Development Roadmap: LOCKED.
- Step 14 P0 Prototype Specification: LOCKED.
- Step 15 Repository Bootstrap + P0 Foundation: LOCKED / PASS.
- Step 16 P1.1 Goal + Personality: LOCKED / PASS.
- Step 17 P1.2 Population + Recruitment + Player Choice: LOCKED / PASS.
- Step 18 P1.3 Relationships + Behavioral Impact: LOCKED / PASS.

Locked baseline before P1.3: `353431b7a8979b79ed904c9e4100fb86e1d1a236`.
P1.3 implementation checkpoint before runtime lock: `b1cea0d0a3d1d80a598623ab209c97357bfff6ba`.

## Architecture locks

- Engine: Godot 4.7.2 / GDScript.
- Godot owns simulation/gameplay authority.
- No parallel JavaScript gameplay authority.
- Simulation is presentation-independent.
- Randomness must come from seeded simulation RNG.
- Save schema remains versioned and backward-compatible with missing optional P1 fields.
- Economy mutations must preserve total money unless an explicit source/sink is declared.
- Runtime invariants are mandatory.
- P0, P1.1, P1.2, and P1.3 remain mandatory regression baselines for later work.
- New P1 systems are opt-in so earlier locked paths remain behavior-stable.
- No new mechanic is accepted as complete if it only creates narrative/state with no measurable simulation or player-decision consequence.

## Locked P0 baseline

P0 provides the autonomous hunt/combat/loot/return/sell/buy/heal/rest loop, 6 fixed disciples, 3 regions, economy conservation, seeded RNG, save/load, deterministic continuation, invariants, benchmark and runtime smoke.

Authoritative P0 gate: `tools/godot/Verify-P0.ps1`.

Latest locked runtime evidence on Godot `4.7.2.stable.official.ed1daf0bf`:

- `P0 FOUNDATION GATE: PASS`;
- same-seed reproducibility: seed 515151 / 5,000 ticks;
- benchmark: 8 x 12,000 = 96,000 ticks;
- total money: 1,630;
- treasury range: 201..215;
- combats: 57,347;
- wins: 38,661;
- retreats: 18,032;
- defeats: 654;
- sales: 20,163;
- heals: 23,682;
- rests: 84,325;
- buys: 6,795;
- runtime smoke: PASS.

## Locked P1.1 — Goal + Personality

P1.1 adds stable personality metadata, deterministic active goals, goal-shaped action/region utility, save/load persistence and deterministic continuation while preserving the P0 path.

Authoritative gate: `tools/godot/Verify-P1-1.ps1`.

Locked runtime evidence:

- `P1.1 GOAL + PERSONALITY TEST PASS`;
- `P1.1 GOAL + PERSONALITY GATE: PASS`;
- seed: 515151;
- total test ticks: 2,500;
- personalities represented: 6;
- initial goals represented: 3;
- measurable goal-shaped behavior: PASS;
- save/load and deterministic continuation: PASS.

## Locked P1.2 — Population + Recruitment + Player Choice

P1.2 adds deterministic recruitment candidates, sect capacity, explicit player accept/reject decisions, new-recruit integration into P1.1, save/load persistence, deterministic continuation and a minimal recruitment interaction screen.

Authoritative gate: `tools/godot/Verify-P1-2.ps1`.

Locked runtime evidence:

- `P1.2 RECRUITMENT + PLAYER CHOICE TEST PASS`;
- `P1.2 RECRUITMENT + PLAYER CHOICE GATE: PASS`;
- `P1.2 GATE: PASS`;
- seed: 616161;
- deterministic continuation ticks: 1,200;
- ending disciples: 8 / capacity 8;
- accepted: 2;
- rejected: 1;
- candidate determinism, capacity blocking, money conservation, save/load and interaction-scene smoke: PASS;
- P0 and P1.1 regressions remained green in the same run.

## Locked P1.3 — Relationships + Behavioral Impact

P1.3 introduces a sparse directed social graph. A relationship A -> B is independent from B -> A.

Implemented design:

- Each meaningful relationship stores three values from 0..100 with neutral 50: affinity, trust, respect.
- Missing relationships are neutral and consume no relation record.
- Initial network is sparse: each disciple starts with only a small number of meaningful contacts rather than N x N edges.
- Relationship response is personality-shaped: survival bias affects trust response and risk bias affects positive respect response.
- Relationship events update the three values and record interaction count, last event and event tick.
- When related disciples are in the same hunting region, combat outcomes can update their relationship state.
- Relationship values have direct behavior impact through region utility.
- Region social utility reads only the acting disciple's outgoing sparse edges; it does not scan every possible pair in the sect.
- Positive relationships can pull a disciple toward a region occupied/targeted by known contacts; negative relationships can reduce that region's score.
- Player agency is explicit through companion assignment. Assigning a companion adds a stronger social weight to the selected person's region without directly rewriting the disciple's feelings/personality.
- Clearing the companion assignment removes that extra player influence.
- Affinity/trust/respect all contribute to the behavioral score at 30% / 45% / 25% respectively.
- P1.2 recruits are inserted into the sparse relationship network when P1.3 is enabled.
- Relationship graph, companion assignments, event counters and feature flag serialize through save/load.
- `P13Factory` enables P1.1 + P1.2 + P1.3 while older factories remain unchanged.
- A dedicated P1.3 screen exposes relationship values and lets the player assign/clear a companion while showing social region scores.

P1.3 scale rule:

- no mandatory full 120 x 119 graph;
- no global relationship scan per simulation tick;
- decisions inspect only the acting disciple's existing relationship edges;
- combat relationship updates inspect only that disciple's existing contacts and cap affected local contacts per outcome.

Authoritative gate: `tools/godot/Verify-P1-3.ps1`.

## Runtime verification evidence — P1.3 — 2026-09-30

Environment:

- Godot `4.7.2.stable.official.ed1daf0bf`.
- Local authoritative gate: `Sync-P1-3.cmd` → full P0 gate → locked P1.1 gate → locked P1.2 gate → P1.3 relationship/behavior-impact contracts → P1.3 interaction-scene smoke.

Result:

- `P0 FOUNDATION GATE: PASS`;
- `P1.1 GOAL + PERSONALITY TEST PASS`;
- `P1.1 GOAL + PERSONALITY GATE: PASS`;
- `P1.2 RECRUITMENT + PLAYER CHOICE TEST PASS`;
- `P1.2 RECRUITMENT + PLAYER CHOICE GATE: PASS`;
- `P1.3 RELATIONSHIP + BEHAVIOR IMPACT TEST PASS`;
- `P1.3 RELATIONSHIP + BEHAVIOR IMPACT GATE: PASS`;
- `P1.3 GATE: PASS`.

Recorded P1.3 evidence:

- seed: 717171;
- deterministic continuation ticks: 2,000;
- ending disciples: 6;
- sparse relationship records: 18;
- relationship events processed: 1,948;
- active companion assignments in final test state: 1;
- same-seed sparse relationship graph: PASS;
- directed A -> B independence: PASS;
- affinity behavioral weight: PASS;
- trust behavioral weight: PASS;
- respect behavioral weight: PASS;
- personality-shaped relationship response: PASS;
- relationship strength changing region choice: PASS;
- player companion assignment changing region choice: PASS;
- clearing player companion influence restoring unassigned behavior: PASS;
- P1.2 recruit integration into relationship network: PASS;
- relationship + companion save/load persistence: PASS;
- deterministic continuation after save/load: PASS;
- invariants and economy conservation: PASS;
- P1.3 relationship interaction scene smoke: PASS;
- P0, P1.1 and P1.2 regressions remained green in the same run.

## P1.3 exclusions retained

P1.3 does not open:

- long-term memory;
- romance/marriage;
- mentor/disciple hierarchy;
- sworn siblings;
- factions;
- betrayal/leaving mechanics;
- internal combat;
- cultivation realms/techniques;
- bosses, premium currency, production art.

## Completion status

- P0: PASS / LOCKED.
- P1.1 Goal + Personality: PASS / LOCKED.
- P1.2 Population + Recruitment + Player Choice: PASS / LOCKED.
- P1.3 Relationships + Behavioral Impact: PASS / LOCKED.

Next step: open P1.4 only against the locked P0 + P1.1 + P1.2 + P1.3 baseline. The next slice may introduce memory, but only if remembered events have measurable consequences on later decisions/relationships and preserve deterministic simulation, save/load, economy invariants and all prior gates.
