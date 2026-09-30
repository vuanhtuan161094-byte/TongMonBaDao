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

Locked baseline before the unverified stack: `bbdca12b3f1efd14d31982810859d22f51990ff4` (P1.3 lock).
P1.4 implementation checkpoint before P1.5: `b1fc434c6e05cac451b60ab11c4c855476e00842`.
P1.5 implementation checkpoint before P1.6: `541b67ccc9f847b4c9c44d43ea82317b5668c20e`.
P1.6 implementation checkpoint before P2.1: `a4fe78a8f94d774f9351aaf3b02fd78ad1aaee08`.

## Architecture locks

- Engine: Godot 4.7.2 / GDScript.
- Godot owns simulation/gameplay authority.
- Seeded deterministic simulation remains mandatory.
- Save/load, invariants and economy conservation remain mandatory.
- P0, P1.1, P1.2 and P1.3 are locked regression baselines.
- P1.4–P2.1 may be implemented while the user is away from the Windows machine, but none may be marked PASS without real Godot runtime evidence.
- New systems remain opt-in so earlier behavior paths stay available.
- No mechanic is complete if it only adds narrative, title, realm name, bar or resource state without measurable consequence.

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

- bounded memories only, maximum 24 per disciple;
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

## Active P2.1 — Cultivation + Realms + Breakthrough

P2.1 adds the first cultivation progression loop. It is invalid unless progression changes later behavior and combat.

### Cultivation progression

Each disciple now stores:

- cultivation stage index;
- cultivation progress;
- realm combat bonus;
- realm HP bonus;
- player directive (`balanced`, `cultivate`, `field`);
- breakthrough failure count;
- retry tick;
- latest breakthrough outcome.

The old `combat_power` value remains base/intrinsic power. Realm power is additive only when P2.1 is enabled, preserving old factories.

### Realms in P2.1

- Luyện Khí tầng 1–9;
- Trúc Cơ sơ/trung/hậu/viên mãn;
- Kim Đan sơ/trung/hậu/viên mãn.

The realm table is data-driven and can later be extended upward without replacing the progression model.

### Cultivation sources

Sect cultivation:

- +8 cultivation per `CULTIVATE` action;
- costs 12 stamina;
- progress stops at the current breakthrough threshold.

Combat victory:

- +2 cultivation;
- field experience therefore contributes slowly but does not replace deliberate cultivation.

### Player agency

The player chooses a directive, not a realm:

- `balanced`;
- `cultivate` — raises cultivation utility and reduces hunting preference;
- `field` — raises hunting utility and lowers cultivation preference.

Personality remains consequential: cautious/survival-oriented disciples value cultivation more than reckless disciples under otherwise similar conditions.

### Breakthrough conditions

A breakthrough requires:

- threshold reached;
- not at P2.1 maximum stage;
- retry cooldown completed;
- HP >= 75%;
- stamina >= 65.

Success chance is stage-dependent with a small condition bonus.

Success:

- advances exactly one stage;
- consumes current threshold progress;
- updates realm combat bonus;
- updates max HP bonus;
- consumes stamina;
- creates a short cooldown.

Failure:

- stage is unchanged;
- loses 20% of the required cultivation amount;
- loses 18% max HP;
- consumes 40 stamina;
- blocks another attempt for 90 ticks;
- increments failure state.

### Direct behavioral consequence

When P2.1 is enabled:

`effective combat power = base combat_power + realm combat bonus`

Effective power is used by:

- combat damage;
- region under-power penalty.

Therefore realm progression can directly change both combat outcome and which region an autonomous disciple considers viable/profitable.

P2.1 adds two autonomous actions:

- `CULTIVATE`;
- `BREAKTHROUGH`.

### Scale contract

- O(1) stage lookup per disciple;
- no cultivation relationship graph;
- no population-wide realm scan;
- one directive stored on each disciple;
- no change to the sparse relationship/memory scale rules.

### P2.1 verification contract

1. Full P0 through P1.6 gate chain must PASS first.
2. Same-seed P2.1 state and continuation must remain deterministic.
3. `cultivate` directive must change a controlled action to CULTIVATE.
4. `field` directive must change the same controlled action back to HUNT.
5. Personality must measurably change cultivation utility.
6. CULTIVATE must add progress and consume stamina.
7. Combat victory must add a smaller cultivation gain.
8. Controlled breakthrough success must advance one stage and increase realm power/HP.
9. Controlled failure must preserve stage and cause cultivation/HP/stamina loss + cooldown.
10. Realm power must change a controlled region decision.
11. Realm power must change a controlled combat outcome.
12. Save/load must preserve all cultivation state and directives.
13. Deterministic continuation, money conservation and all prior invariants must remain green.
14. P2.1 interaction scene must launch on Godot 4.7.2.

Authoritative command: `Sync-P2-1.cmd`.

This command intentionally chains every earlier gate, including the still-unverified P1.4/P1.5/P1.6 stack.

Expected successful final markers include:

- `P1.4 MEMORY + CONSEQUENCE GATE: PASS`
- `P1.5 ORGANIZATION + PLAYER MANAGEMENT GATE: PASS`
- `P1.6 SECT NEEDS + RESOURCE CONSEQUENCE GATE: PASS`
- `P2.1 CULTIVATION + BREAKTHROUGH CONSEQUENCE TEST PASS`
- `P2.1 CULTIVATION + BREAKTHROUGH CONSEQUENCE GATE: PASS`
- `P2.1 GATE: PASS`

## P2.1 exclusions

P2.1 does not add spiritual roots, aptitude ratings, cultivation techniques, pills/elixirs, tribulations, master/disciple hierarchy, realm skills, equipment scaling, secret realms, bosses/factions or combat-team V2.

## Completion status

- P0: PASS / LOCKED.
- P1.1: PASS / LOCKED.
- P1.2: PASS / LOCKED.
- P1.3: PASS / LOCKED.
- P1.4: IMPLEMENTED / AWAITING RUNTIME GATE.
- P1.5: IMPLEMENTED / AWAITING RUNTIME GATE.
- P1.6: IMPLEMENTED / AWAITING RUNTIME GATE.
- P2.1: IMPLEMENTED / AWAITING RUNTIME GATE.

Runtime verification for P1.4–P2.1 is intentionally deferred until the user returns to the Windows/Godot 4.7.2 machine. Do not mark any pending phase PASS before a real `Sync-P2-1.cmd` run completes successfully.
