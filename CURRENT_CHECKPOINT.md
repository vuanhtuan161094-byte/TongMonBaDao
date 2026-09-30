# CURRENT CHECKPOINT

Date: 2026-09-30

## Project state

- Step 13 Technical Architecture & Development Roadmap: LOCKED.
- Step 14 P0 Prototype Specification: LOCKED.
- Step 15 Repository Bootstrap + P0 Foundation: LOCKED / PASS.
- Step 16 P1.1 Goal + Personality: LOCKED / PASS.
- Step 17 P1.2 Population + Recruitment + Player Choice: LOCKED / PASS.
- Step 18 P1.3 Relationships + Behavioral Impact: IMPLEMENTED / AWAITING RUNTIME GATE.

Locked baseline before P1.3: `353431b7a8979b79ed904c9e4100fb86e1d1a236`.

## Architecture locks

- Engine: Godot 4.7.2 / GDScript.
- Godot owns simulation/gameplay authority.
- No parallel JavaScript gameplay authority.
- Simulation is presentation-independent.
- Randomness must come from seeded simulation RNG.
- Save schema remains versioned and backward-compatible with missing optional P1 fields.
- Economy mutations must preserve total money unless an explicit source/sink is declared.
- Runtime invariants are mandatory.
- P0, P1.1, and P1.2 remain mandatory regression baselines.
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

## Active P1.3 — Relationships + Behavioral Impact

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

P1.3 verification contract:

1. Full locked P0/P1.1/P1.2 gates must PASS first.
2. Same seed must create the same sparse relationship graph.
3. Graph must remain sparse rather than materializing every possible directed pair.
4. Affinity, trust and respect must each have measurable behavioral weight.
5. The same relationship event must be able to produce different response magnitude because of personality.
6. A -> B mutation must not implicitly mutate B -> A.
7. Relationship strength must be able to change a region decision in a controlled probe.
8. Player companion assignment must measurably change a region decision in a controlled probe, and clearing it must restore the unassigned behavior.
9. New P1.2 recruits must enter the relationship network.
10. Relationship state and companion assignment must survive save/load.
11. Same-seed simulation and continuation after save/load must remain deterministic.
12. Invariants and economy conservation must remain green.
13. The P1.3 interaction scene must launch successfully in Godot 4.7.2.

Authoritative command: `Sync-P1-3.cmd`.

Expected successful end markers:

- `P0 FOUNDATION GATE: PASS`
- `P1.1 GOAL + PERSONALITY GATE: PASS`
- `P1.2 RECRUITMENT + PLAYER CHOICE GATE: PASS`
- `P1.3 RELATIONSHIP + BEHAVIOR IMPACT TEST PASS`
- `P1.3 RELATIONSHIP + BEHAVIOR IMPACT GATE: PASS`
- `P1.3 GATE: PASS`

## P1.3 exclusions

Do not open these systems until P1.3 is locked:

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
- P1.3 Relationships + Behavioral Impact: IMPLEMENTED / AWAITING RUNTIME GATE.

Next closure condition: run `Sync-P1-3.cmd` on the local Windows/Godot 4.7.2 environment. Do not mark P1.3 PASS until all prior regressions, the P1.3 behavior-impact contracts, save/load continuation, invariants and the P1.3 interaction-scene smoke test pass in a real runtime.
