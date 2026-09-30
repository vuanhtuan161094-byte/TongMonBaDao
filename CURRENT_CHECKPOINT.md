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

Locked baseline before P1.4: `bbdca12b3f1efd14d31982810859d22f51990ff4`.
P1.4 implementation checkpoint before P1.5: `b1fc434c6e05cac451b60ab11c4c855476e00842`.

## Architecture locks

- Engine: Godot 4.7.2 / GDScript.
- Godot owns simulation/gameplay authority.
- Seeded deterministic simulation remains mandatory.
- Save/load, invariants and economy conservation remain mandatory.
- P0, P1.1, P1.2 and P1.3 are locked regression baselines.
- P1.4 and P1.5 may be implemented while the user is away from the Windows machine, but neither may be marked PASS without real Godot runtime evidence.
- New P1 systems remain opt-in so earlier behavior paths stay available.
- No mechanic is complete if it adds only narrative, title or display state without measurable simulation/player-decision consequence.

## Locked P0–P1.3

P0, P1.1, P1.2 and P1.3 are PASS / LOCKED with previously recorded local Godot 4.7.2 evidence.

Latest locked P1.3 evidence:

- `P1.3 RELATIONSHIP + BEHAVIOR IMPACT TEST PASS`;
- seed 717171;
- 2,000 total test ticks;
- 18 sparse directed relationships;
- 1,948 relationship events;
- affinity/trust/respect behavioral impact PASS;
- personality-shaped relationship response PASS;
- player companion assignment impact PASS;
- save/load, deterministic continuation, invariants, money conservation and scene smoke PASS.

## Pending P1.4 — Consequential Memory

P1.4 is implemented but has not yet been run on the user's local Godot machine.

Implemented design:

- bounded meaningful memories only;
- personal victory/retreat/defeat and shared/witnessed outcomes;
- repeated identical memories consolidate;
- maximum 24 memories per disciple;
- personality shapes memory importance;
- place memories change later region choice;
- social memories change later behavior around remembered people;
- player-linked shared experience can outlive a cleared companion order;
- memory is event-driven and bounded, not a global per-tick scan;
- save/load + deterministic continuation contract;
- dedicated P1.4 memory interaction screen.

Authoritative pending command: `Sync-P1-4.cmd`.

Expected P1.4 end markers include:

- `P1.4 MEMORY + CONSEQUENCE TEST PASS`
- `P1.4 MEMORY + CONSEQUENCE GATE: PASS`
- `P1.4 GATE: PASS`

## Active P1.5 — Organization + Teams + Leadership + Roles

P1.5 turns the sect into a player-shaped organization while disciples remain autonomous.

Implemented design:

### Teams

- `P15Factory` enables P1.4 plus organization; older factories remain unchanged.
- Initial P1.5 state creates two deterministic small teams.
- A disciple belongs to at most one team.
- `disciple_team_ids` provides direct O(1) lookup; decisions do not scan the full sect.
- Team size is capped at 6.
- Player may move a disciple between teams.

### Leadership

- Each non-empty team may have one leader who must also be a team member.
- A leader's current/target region adds organizational utility to members considering that region.
- Leadership influence is shaped by the member's trust + respect toward the leader.
- High trust/respect strengthens following; very low trust/respect can make leadership influence negative.
- Existing P1.4 memories remain independent modifiers, so bad history with a leader can counter positive formal authority.
- Player may replace the leader.

### Consequential roles

Only three roles exist in this slice:

- `hunter`: raises HUNT utility and favors dangerous/profitable regions;
- `logistics`: lowers HUNT priority, raises BUY/SELL/REST utility and favors safer regions;
- `guard`: favors safer regions and adds bounded support to teammates when present/targeting the same region.

Roles are explicit player assignments and are not cosmetic labels.

### Player agency

The player can:

- move a disciple to another team;
- appoint a team leader;
- assign hunter/logistics/guard;
- clear a role.

These orders change utility and organizational influence while the disciple still chooses actions through the existing autonomous AI.

### Integration with earlier systems

- P1.1 personality/goals remain active.
- P1.2 recruits can be assigned into teams and roles.
- P1.3 trust/respect changes leadership strength.
- P1.4 memory can reinforce or oppose leadership.
- P0 money conservation remains unchanged.

### Scale contract

- direct disciple -> team lookup;
- maximum 6 members per team;
- leadership reads one leader relation;
- guard support scans only the bounded local team;
- no N x N organization matrix;
- no full-population organization scan per decision.

P1.5 verification contract:

1. Full P0/P1.1/P1.2/P1.3/P1.4 gates must PASS first.
2. Same seed must create the same teams/leaders.
3. One-disciple/one-team and team-size cap invariants must hold.
4. Changing team leader must measurably change a controlled member's region decision.
5. Trust/respect must measurably change leadership influence.
6. Strong negative memory about a leader must be able to counter positive leadership influence.
7. Logistics must be able to change a controlled decision from HUNT to BUY.
8. Hunter must measurably increase hunting utility.
9. Guard must provide measurable bounded teammate support.
10. Moving a member between teams must measurably change organizational behavior.
11. A recruited P1.2 disciple must be assignable to a team and role.
12. Team/leader/role/lookup/change-count state must survive save/load.
13. Continuation after save/load must remain deterministic.
14. Invariants and economy conservation must remain green.
15. P1.5 interaction scene must launch successfully in Godot 4.7.2.

Authoritative command: `Sync-P1-5.cmd`.

`Sync-P1-5.cmd` intentionally chains the pending P1.4 gate before P1.5. Therefore one future local run can verify both unverified phases.

Expected successful end markers include:

- `P0 FOUNDATION GATE: PASS`
- `P1.1 GOAL + PERSONALITY GATE: PASS`
- `P1.2 RECRUITMENT + PLAYER CHOICE GATE: PASS`
- `P1.3 RELATIONSHIP + BEHAVIOR IMPACT GATE: PASS`
- `P1.4 MEMORY + CONSEQUENCE GATE: PASS`
- `P1.5 ORGANIZATION + PLAYER MANAGEMENT TEST PASS`
- `P1.5 ORGANIZATION + PLAYER MANAGEMENT GATE: PASS`
- `P1.5 GATE: PASS`

## P1.5 exclusions

P1.5 does not add sect upkeep/needs, buildings, morale, salaries, mentor/disciple hierarchy, romance, factions, betrayal/leaving, internal combat, cultivation realms/techniques, bosses, premium currency or production art.

## Completion status

- P0: PASS / LOCKED.
- P1.1: PASS / LOCKED.
- P1.2: PASS / LOCKED.
- P1.3: PASS / LOCKED.
- P1.4: IMPLEMENTED / AWAITING RUNTIME GATE.
- P1.5: IMPLEMENTED / AWAITING RUNTIME GATE.

Runtime verification for P1.4 and P1.5 is intentionally deferred until the user returns to the Windows/Godot 4.7.2 machine. Do not mark either phase PASS before a real `Sync-P1-5.cmd` run completes successfully.
