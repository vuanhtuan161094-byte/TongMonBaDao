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
- Step 22 P2.1 Cultivation + Realms + Breakthrough: IMPLEMENTED / AWAITING RUNTIME GATE.
- Step 23 P2.2 Spiritual Root Quality + Long-Term Growth: IMPLEMENTED / AWAITING RUNTIME GATE.

Locked baseline before the unverified stack: `bbdca12b3f1efd14d31982810859d22f51990ff4` (P1.3 lock).

Implementation checkpoints:

- before P1.5: `b1fc434c6e05cac451b60ab11c4c855476e00842`;
- before P1.6: `541b67ccc9f847b4c9c44d43ea82317b5668c20e`;
- before P2.1: `a4fe78a8f94d774f9351aaf3b02fd78ad1aaee08`;
- before P2.2: `cc9be52e72b1e787962edaab44319b680805f3b3`.

## Architecture locks

- Engine: Godot 4.7.2 / GDScript.
- Godot owns simulation/gameplay authority.
- Seeded deterministic simulation remains mandatory.
- Save/load, invariants and economy conservation remain mandatory.
- P0, P1.1, P1.2 and P1.3 are locked regression baselines.
- P1.4–P2.2 may be implemented while the user is away from the Windows machine, but none may be marked PASS without real local Godot runtime evidence.
- New systems remain opt-in so earlier behavior paths stay available.
- No mechanic is complete if it only adds narrative, title, rarity label, bar or state without measurable gameplay/simulation consequence.

## Locked P0–P1.3

P0, P1.1, P1.2 and P1.3 are PASS / LOCKED with recorded local Godot `4.7.2.stable.official.ed1daf0bf` evidence.

Latest P1.3 evidence:

- `P1.3 RELATIONSHIP + BEHAVIOR IMPACT TEST PASS`;
- seed 717171;
- 2,000 ticks;
- 18 sparse directed relationships;
- 1,948 relationship events;
- relationship values and player companion assignment measurably changed behavior;
- save/load, deterministic continuation, invariants, money conservation and scene smoke PASS.

## Pending P1.4 — Consequential Memory

Implemented, not runtime-verified.

Key consequences:

- bounded memories, maximum 24 per disciple;
- repeated experiences consolidate;
- place/social memories change later decisions;
- personality shapes memory strength;
- player-created experience can outlive a cleared direct order.

## Pending P1.5 — Organization

Implemented, not runtime-verified.

Key consequences:

- bounded teams and direct disciple -> team lookup;
- player can move members, appoint leaders and assign roles;
- trust/respect + memory shape leadership influence;
- hunter/logistics/guard roles change real behavior.

## Pending P1.6 — Sect Needs

Implemented, not runtime-verified.

Key consequences:

- medicine controls healing availability;
- expedition supplies affect destination preference and travel stamina cost;
- lodging pressure reduces rest recovery;
- logistics priority changes medicine/supply production;
- player can spend supplies to expand lodging.

## Pending P2.1 — Cultivation + Realms + Breakthrough

Implemented, not runtime-verified.

Key consequences:

- autonomous CULTIVATE and BREAKTHROUGH actions;
- Luyện Khí 1–9, Trúc Cơ and Kim Đan stages;
- cultivation progress from deliberate cultivation and smaller combat-victory gains;
- player cultivation directive: balanced / cultivate / field;
- breakthrough success/failure has measurable consequences;
- realm increases max HP and effective combat power;
- effective realm power changes region choice and combat outcome;
- `combat_power` remains base power so older paths stay stable.

## Active P2.2 — Spiritual Root Quality + Long-Term Growth

P2.2 explains long-term growth differences between disciples without adding decorative elemental labels.

### Root qualities

Four qualities exist:

- `mixed` — Tạp linh căn: 0.75x cultivation, -8 percentage points breakthrough;
- `ordinary` — Phàm linh căn: 1.00x cultivation, no breakthrough modifier;
- `earth` — Địa linh căn: 1.20x cultivation, +5 percentage points breakthrough;
- `heaven` — Thiên linh căn: 1.45x cultivation, +10 percentage points breakthrough.

Generation weights are 45 / 38 / 14 / 3 respectively.

### No hard realm cap

Root quality never forbids a realm.

Tạp linh căn may still reach Trúc Cơ/Kim Đan and later realms. Its disadvantage is slower cultivation and worse breakthrough probability, not an artificial maximum realm.

### Deterministic generation

Root generation uses a separate seed derived from simulation seed + stable id + candidate generation index.

It does not consume RecruitmentSystem's legacy RNG stream.

Therefore enabling P2.2 must not change candidate name, base combat power, personality biases or generation order.

`P22Factory` creates the complete P2.1 state first, then enables root quality and assigns deterministic roots to current disciples/candidates.

Future candidates also receive roots through the separate root generator.

### Cultivation consequence

When roots are enabled:

`actual cultivation gain = P2.1 gain × root multiplier`

For one base CULTIVATE action:

- Tạp = 6;
- Phàm = 8;
- Địa = 9.6;
- Thiên = 11.6.

The same multiplier applies to other cultivation-progress sources, including combat-victory progress.

P2.1 behavior remains unchanged when roots are disabled.

### Breakthrough consequence

Root modifier is added to the P2.1 stage/condition success probability before final clamping.

Root quality does not bypass threshold, HP, stamina or cooldown requirements and does not change P2.1 failure consequences.

### Recruitment consequence

The P2.2 recruitment screen exposes:

- current combat power;
- root quality;
- cultivation multiplier;
- breakthrough modifier.

The player chooses between current usefulness and long-term potential. P2.2 intentionally does not collapse this into a single generated score.

Accepted candidates preserve their root and immediately use it in the real cultivation system.

### Scale contract

- one root-quality value per disciple/candidate;
- O(1) multiplier/chance lookup;
- no N x N structure;
- no population scan during cultivation or breakthrough;
- root generation only occurs when a disciple/candidate needs a root.

### P2.2 verification contract

1. Full P0 through P2.1 gate chain must PASS first.
2. P21Factory must remain root-disabled and keep base +8 cultivation.
3. Same seed must generate identical disciple/candidate roots.
4. Tạp must yield exactly 6 from one base-8 cultivation action.
5. Thiên must yield exactly 11.6 from the same action.
6. Equal-current-power disciples with different roots must diverge in long-term cultivation growth.
7. Root quality must measurably change breakthrough probability.
8. Tạp root must have no hard realm cap and must reach Trúc Cơ under controlled successes.
9. Root generation must not alter legacy candidate fields/RNG results.
10. Future P2.2 candidates must receive deterministic roots.
11. Accepted candidates must preserve root quality and receive its real growth effect.
12. Save/load must preserve root flag/counter and all disciple/candidate roots.
13. Same-seed continuation after save/load must remain deterministic.
14. Money, needs, cultivation and root invariants must remain green.
15. P2.2 recruitment/root scene must launch on Godot 4.7.2.

Authoritative command: `Sync-P2-2.cmd`.

Expected successful final markers include:

- `P1.4 MEMORY + CONSEQUENCE GATE: PASS`
- `P1.5 ORGANIZATION + PLAYER MANAGEMENT GATE: PASS`
- `P1.6 SECT NEEDS + RESOURCE CONSEQUENCE GATE: PASS`
- `P2.1 CULTIVATION + BREAKTHROUGH CONSEQUENCE GATE: PASS`
- `P2.2 SPIRITUAL ROOT + GROWTH CONSEQUENCE TEST PASS`
- `P2.2 SPIRITUAL ROOT + GROWTH CONSEQUENCE GATE: PASS`
- `P2.2 GATE: PASS`

## P2.2 exclusions

P2.2 does not add elemental roots, cultivation techniques, skills, pills/elixirs, special physiques, hard realm caps, master/disciple hierarchy, tribulations, secret realms, bosses/factions, equipment scaling or combat-team V2.

## Completion status

- P0: PASS / LOCKED.
- P1.1: PASS / LOCKED.
- P1.2: PASS / LOCKED.
- P1.3: PASS / LOCKED.
- P1.4: IMPLEMENTED / AWAITING RUNTIME GATE.
- P1.5: IMPLEMENTED / AWAITING RUNTIME GATE.
- P1.6: IMPLEMENTED / AWAITING RUNTIME GATE.
- P2.1: IMPLEMENTED / AWAITING RUNTIME GATE.
- P2.2: IMPLEMENTED / AWAITING RUNTIME GATE.

Runtime verification for P1.4–P2.2 is intentionally deferred until the user returns to the Windows/Godot 4.7.2 machine. Do not mark any pending phase PASS before a real `Sync-P2-2.cmd` run completes successfully.
