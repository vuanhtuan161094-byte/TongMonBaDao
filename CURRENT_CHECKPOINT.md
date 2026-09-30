# CURRENT CHECKPOINT

Date: 2026-09-30

## Project state

- Step 13 Technical Architecture & Development Roadmap: LOCKED.
- Step 14 P0 Prototype Specification: LOCKED.
- Step 15 Repository Bootstrap + P0 Foundation: LOCKED / PASS.
- Step 16 P1.1 Goal + Personality: LOCKED / PASS.
- Step 17 P1.2 Population + Recruitment + Player Choice: IMPLEMENTED / AWAITING RUNTIME GATE.

Locked baseline before P1.2: `52812fbecb94a787cb9678c3ff999024478f026a`.

## Architecture locks

- Engine: Godot 4.7.2 / GDScript.
- Godot owns simulation/gameplay authority.
- No parallel JavaScript gameplay authority.
- Simulation is presentation-independent.
- Randomness must come from seeded simulation RNG.
- Save schema remains versioned and backward-compatible with missing optional P1 fields.
- Economy mutations must preserve total money unless an explicit source/sink is declared.
- Runtime invariants are mandatory.
- P0 remains the mandatory regression baseline for all P1 work.
- P1.1 Goal + Personality remains a mandatory regression baseline for later P1 work.
- New P1 features are opt-in so earlier locked behavior paths remain available.

## Locked P0 baseline

P0 includes:

- 6 fixed disciple behavior profiles;
- 3 regions;
- 3 monster species;
- 4 loot resources;
- autonomous hunt/combat/loot/return/sell/buy/heal/rest loop;
- sect treasury + disciple wallets;
- bounded market pricing;
- save/load;
- debug inspector.

Authoritative P0 gate: `tools/godot/Verify-P0.ps1`.

P0 runtime evidence on Godot `4.7.2.stable.official.ed1daf0bf`:

- full 9-stage gate: PASS;
- 20,000-tick invariant scenario: PASS;
- save/load + deterministic continuation: PASS;
- same-seed reproducibility: PASS at seed 515151 / 5,000 ticks;
- multi-seed benchmark: 8 × 12,000 = 96,000 ticks;
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
- runtime smoke: PASS;
- final markers: `P0 FOUNDATION GATE: PASS` and `P0 GATE: PASS`.

## Locked P1.1 — Goal + Personality

P1.1 adds:

- stable personality metadata for every disciple;
- existing `risk_bias`, `spend_bias`, and `survival_bias` remain the behavior vector;
- deterministic active goals;
- goal values: `RECOVER`, `WEALTH`, `GLORY`, `SECURITY`, `PREPARE`, `GROWTH`;
- goal modifiers feed the existing utility/region-decision system;
- hard safety floors remain authoritative;
- personality + goal state persists through save/load;
- P0 behavior remains available through `P0Factory`;
- P1.1 behavior is enabled through `P1Factory`.

Authoritative P1.1 gate: `tools/godot/Verify-P1-1.ps1`.

P1.1 runtime evidence on Godot `4.7.2.stable.official.ed1daf0bf`:

- P0 regression gate: PASS;
- P1.1 Goal + Personality contract: PASS;
- seed: 515151;
- total test ticks after continuation: 2,500;
- personalities represented: 6;
- initial goals represented: 3;
- same-seed deterministic behavior: PASS;
- measurable goal-shaped region choice: PASS;
- save/load personality + goal persistence: PASS;
- deterministic continuation after save/load: PASS;
- simulation invariants: PASS;
- final markers: `P1.1 GOAL + PERSONALITY GATE: PASS` and `P1.1 GATE: PASS`.

## Active P1.2 — Population + Recruitment + Player Choice

P1.2 is intentionally narrow. It introduces the first direct player influence over individual characters without turning disciples into puppets.

Implemented design:

- `P12Factory` enables P1.1 plus recruitment while leaving P0/P1.1 factories unchanged.
- Initial P1.2 population remains 6 disciples.
- Initial sect capacity is 8 disciples.
- Initial recruitment pool contains 3 candidates.
- Candidate generation is deterministic from simulation seed + generation index.
- Each candidate has a stable id, name, combat power, personality id, risk/spend/survival biases, and generation index.
- Candidate state is separate from disciple runtime state until the player accepts the candidate.
- Player decision API is explicit: accept or reject.
- Accepting converts the candidate into a normal `DiscipleState` and immediately feeds the disciple into P1.1 goal formation.
- New recruits start with 0 personal money so recruitment does not mint currency or violate P0 economy conservation.
- Recruitment is blocked when sect population reaches capacity.
- Rejected candidates are removed from the waiting pool.
- Recruitment statistics track accepted/rejected counts.
- Candidate pool, generation index, statistics, capacity, and feature flag persist through save/load.
- A dedicated P1.2 interaction scene allows the player to press `Nhận` or `Từ chối` on real candidates.
- The original P0 main scene is not replaced.

P1.2 files of interest:

- `docs/P1_2_SPEC.md`;
- `godot/src/simulation/state/candidate_state.gd`;
- `godot/src/simulation/recruitment/recruitment_system.gd`;
- `godot/src/simulation/core/p1_2_factory.gd`;
- `godot/tests/simulation/p1_2_recruitment_test.gd`;
- `godot/src/presentation/p1_2_recruitment.gd`;
- `godot/scenes/p1/p1_2_recruitment.tscn`;
- `tools/godot/Verify-P1-2.ps1`;
- `Verify-P1-2.cmd`;
- `Sync-P1-2.cmd`.

P1.2 verification contract:

1. Full P0 gate must PASS.
2. Locked P1.1 gate must PASS.
3. Same seed must generate the same candidates.
4. Same player decisions must generate the same resulting recruitment state.
5. Accept vs reject must create measurably different population outcomes.
6. Sect capacity must block excess acceptance.
7. Recruitment must preserve total-money invariants.
8. Accepted recruits must carry personality + active-goal behavior into the normal simulation.
9. Recruitment state must survive save/load.
10. Simulation continuation after save/load must remain deterministic.
11. The P1.2 interaction scene must launch successfully in Godot 4.7.2.

Authoritative command: `Sync-P1-2.cmd`.

Expected successful end markers:

- `P0 FOUNDATION GATE: PASS`
- `P1.1 GOAL + PERSONALITY GATE: PASS`
- `P1.2 RECRUITMENT + PLAYER CHOICE TEST PASS`
- `P1.2 RECRUITMENT + PLAYER CHOICE GATE: PASS`
- `P1.2 GATE: PASS`

## P1.2 exclusions

Do not open these systems until P1.2 is locked:

- relationships;
- memory;
- mentor/disciple hierarchy;
- cultivation realms and techniques;
- complex leaving/death mechanics;
- recruitment reputation/cost systems;
- bosses, premium currency, production art.

## Completion status

- P0: PASS / LOCKED.
- P1.1 Goal + Personality: PASS / LOCKED.
- P1.2 Population + Recruitment + Player Choice: implementation present, runtime proof required before lock.

Next closure condition: run `Sync-P1-2.cmd` on the local Windows/Godot 4.7.2 environment. If every P0/P1.1 regression and P1.2 contract/scene smoke test passes, record the exact runtime evidence and mark Step 17 `LOCKED / PASS`.
