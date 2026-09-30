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

Locked baseline before P1.4: `bbdca12b3f1efd14d31982810859d22f51990ff4`.

## Architecture locks

- Engine: Godot 4.7.2 / GDScript.
- Godot owns simulation/gameplay authority.
- Seeded deterministic simulation remains mandatory.
- Save/load, invariants and economy conservation remain mandatory.
- P0, P1.1, P1.2 and P1.3 are mandatory regression baselines.
- New P1 systems remain opt-in so earlier locked paths stay behavior-stable.
- No mechanic is complete if it only adds narrative/state without measurable gameplay or simulation consequence.

## Locked P0

P0 autonomous simulation/economy/save-load baseline is PASS / LOCKED.

Latest locked evidence includes:

- `P0 FOUNDATION GATE: PASS`;
- seed 515151 reproducibility at 5,000 ticks;
- 8 x 12,000 benchmark = 96,000 ticks;
- total money 1,630;
- runtime smoke PASS.

## Locked P1.1 — Goal + Personality

P1.1 is PASS / LOCKED.

Locked evidence includes:

- `P1.1 GOAL + PERSONALITY TEST PASS`;
- seed 515151;
- 2,500 total test ticks;
- 6 personalities;
- 3 initial goals;
- goal-shaped behavior, save/load and deterministic continuation PASS.

## Locked P1.2 — Population + Recruitment + Player Choice

P1.2 is PASS / LOCKED.

Locked evidence includes:

- `P1.2 RECRUITMENT + PLAYER CHOICE TEST PASS`;
- seed 616161;
- 1,200 continuation ticks;
- ending population 8 / capacity 8;
- accepted 2, rejected 1;
- deterministic candidate generation, player accept/reject divergence, capacity blocking, money conservation, save/load and scene smoke PASS.

## Locked P1.3 — Relationships + Behavioral Impact

P1.3 is PASS / LOCKED.

Locked runtime evidence on Godot `4.7.2.stable.official.ed1daf0bf`:

- `P1.3 RELATIONSHIP + BEHAVIOR IMPACT TEST PASS`;
- `P1.3 RELATIONSHIP + BEHAVIOR IMPACT GATE: PASS`;
- `P1.3 GATE: PASS`;
- seed 717171;
- 2,000 total test ticks;
- 6 disciples;
- 18 sparse directed relationships;
- 1,948 relationship events;
- 1 active companion assignment in final test state;
- affinity, trust and respect each have measurable behavior impact;
- personality changes relationship response;
- relationships change region choice;
- player companion assignment changes region choice and clearing it removes the immediate order effect;
- recruit integration, save/load, deterministic continuation, invariants, economy conservation and scene smoke PASS.

## Active P1.4 — Consequential Memory

P1.4 adds bounded long-term memory only where memory changes later behavior.

Implemented design:

- `P14Factory` enables locked P1.1 + P1.2 + P1.3 plus memory while older factories remain unchanged.
- Meaningful memory events are personal victory, personal retreat, personal defeat, shared victory, witnessed retreat and witnessed defeat.
- Every memory type has a measurable consequence through place utility or social/place utility.
- Repeated identical experiences consolidate into one stronger memory instead of creating unlimited rows.
- Each disciple stores at most 24 memories.
- Memory importance is personality-shaped: survival-oriented disciples retain negative experience more strongly; risk-oriented disciples retain victory experience more strongly.
- Memory effect weakens with age but retains a long-term floor.
- Personal place memories directly modify later region choice.
- Social memories modify region choice when the remembered person is present or targeting that region.
- Shared experience created while the player has assigned companions receives extra importance.
- Clearing the companion assignment removes the immediate P1.3 order but does not erase the P1.4 experience, allowing player decisions to have lasting consequences.
- Combat creates/corroborates memories only on meaningful outcomes, not every tick.
- A decision reads only the acting disciple's bounded memory list; there is no global all-memory scan.
- Memory feature flag, memory records and memory event counter serialize through save/load.
- A dedicated P1.4 memory screen displays stored memories and their current region-score effects.

P1.4 scale contract:

- maximum 24 memories per disciple;
- repeated memory signatures consolidate;
- no full population x population memory table;
- no global memory scan each tick;
- meaningful-event creation only.

P1.4 verification contract:

1. Full locked P0/P1.1/P1.2/P1.3 gates must PASS first.
2. Same seed must form the same memories.
3. Positive and negative place memories must measurably change region behavior.
4. Personality must measurably change memory importance.
5. Repeated experience must consolidate rather than duplicate indefinitely.
6. The 24-memory cap must hold.
7. A player-linked shared experience must be able to influence later behavior after the companion order is cleared.
8. Memory state must survive save/load.
9. Continuation after save/load must remain deterministic.
10. Invariants and economy conservation must remain green.
11. The P1.4 memory scene must launch successfully in Godot 4.7.2.

Authoritative command: `Sync-P1-4.cmd`.

Expected successful end markers:

- `P0 FOUNDATION GATE: PASS`
- `P1.1 GOAL + PERSONALITY GATE: PASS`
- `P1.2 RECRUITMENT + PLAYER CHOICE GATE: PASS`
- `P1.3 RELATIONSHIP + BEHAVIOR IMPACT GATE: PASS`
- `P1.4 MEMORY + CONSEQUENCE TEST PASS`
- `P1.4 MEMORY + CONSEQUENCE GATE: PASS`
- `P1.4 GATE: PASS`

## P1.4 exclusions

P1.4 does not add romance, marriage, mentor/disciple hierarchy, sworn siblings, factions, betrayal/leaving, internal combat, cultivation realms/techniques, bosses, premium currency or production art.

## Completion status

- P0: PASS / LOCKED.
- P1.1: PASS / LOCKED.
- P1.2: PASS / LOCKED.
- P1.3: PASS / LOCKED.
- P1.4: IMPLEMENTED / AWAITING RUNTIME GATE.

Runtime verification is intentionally deferred until the user is back at the Windows/Godot 4.7.2 machine. Do not mark P1.4 PASS before a real `Sync-P1-4.cmd` run completes successfully.
