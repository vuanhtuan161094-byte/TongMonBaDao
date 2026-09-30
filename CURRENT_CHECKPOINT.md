# CURRENT CHECKPOINT

Date: 2026-09-30

## Project state

- Step 13 Technical Architecture & Development Roadmap: LOCKED.
- Step 14 P0 Prototype Specification: LOCKED.
- Step 15 P0 Foundation: LOCKED / PASS.
- Step 16 P1.1 Goal + Personality: LOCKED / PASS.
- Step 17 P1.2 Recruitment + Player Choice: LOCKED / PASS.
- Step 18 P1.3 Relationships + Behavioral Impact: LOCKED / PASS.
- Step 19 P1.4 Consequential Memory: IMPLEMENTED / AWAITING RUNTIME GATE.
- Step 20 P1.5 Organization + Teams + Leadership + Roles: IMPLEMENTED / AWAITING RUNTIME GATE.
- Step 21 P1.6 Sect Life + Needs + Resource Pressure: IMPLEMENTED / AWAITING RUNTIME GATE.
- Step 22 P2.1 Cultivation + Realms + Breakthrough: IMPLEMENTED / AWAITING RUNTIME GATE.
- Step 23 P2.2 Spiritual Root Quality + Long-Term Growth: IMPLEMENTED / AWAITING RUNTIME GATE.
- Step 24 P2.3 Technique Economy + Library + Mastery: IMPLEMENTED / AWAITING RUNTIME GATE.
- Step 25 P2.4 Cultivation Paths / Character Dao Direction: IMPLEMENTED / AWAITING RUNTIME GATE.

Locked baseline before the unverified stack: `bbdca12b3f1efd14d31982810859d22f51990ff4` (P1.3 lock).

Implementation checkpoints before later phases:

- before P1.5: `b1fc434c6e05cac451b60ab11c4c855476e00842`;
- before P1.6: `541b67ccc9f847b4c9c44d43ea82317b5668c20e`;
- before P2.1: `a4fe78a8f94d774f9351aaf3b02fd78ad1aaee08`;
- before P2.2: `cc9be52e72b1e787962edaab44319b680805f3b3`;
- before P2.3: `705a7ff2ac2f6cdc2432edc118e7cb0ff337b79d`;
- before P2.4: `c3c3cc7f6a3054d8e7ecdf616e630eed9310c6c1`.

## Architecture locks

- Engine: Godot 4.7.2 / GDScript.
- Godot owns gameplay/simulation authority.
- Deterministic seeded simulation remains mandatory.
- Save/load, invariants and P0 money conservation remain mandatory.
- P0–P1.3 are locked regression baselines.
- P1.4–P2.4 may be implemented while the user is away from the Windows machine, but none may be marked PASS without real local Godot runtime evidence.
- New systems remain opt-in so earlier factory paths stay behavior-compatible.
- A mechanic is not complete if it adds only story/title/rarity/element/class/progress without measurable simulation or player-decision consequence.

## Locked P0–P1.3

P0, P1.1, P1.2 and P1.3 are PASS / LOCKED with recorded local Godot `4.7.2.stable.official.ed1daf0bf` evidence.

## Pending P1.4–P2.3

Implemented, not runtime-verified. Their existing contracts remain mandatory and are chained into the active verifier.

Carried-forward systems:

- P1.4 bounded consequential memory;
- P1.5 teams/leadership/roles;
- P1.6 medicine/supplies/lodging pressure;
- P2.1 cultivation/realms/breakthrough;
- P2.2 root quality and long-term growth;
- P2.3 Tàng Kinh Các, spirit-stone gacha/farming, fragments, technique learning/mastery/upgrades, path/element/role tags and real technique effects.

## Active P2.4 — Cultivation Paths / Character Dao Direction

P2.4 converts P2.3 technique `path` tags into accumulated personal history. It does not assign a fixed class.

### Path state

Each disciple stores XP for exactly three initial paths:

- `sword` — Kiếm;
- `body` — Thể;
- `spell` — Pháp.

No permanent class/path field exists. Display identity is derived from accumulated XP.

### How paths grow

The active technique determines which path receives XP:

- successful CULTIVATE action: +10;
- combat win: +4;
- combat retreat/defeat: +1.

Switching active technique changes future path growth but does not erase old history.

### Derived identity

- total XP <100: `Chưa định hình`;
- dominant path >=65%: `<Path> tu`;
- otherwise if the second path >=25%: `<Path A>–<Path B> song tu`;
- otherwise dominant path with mixed history.

Examples:

- 700 Kiếm / 300 Pháp -> Kiếm tu;
- 600 Kiếm / 400 Pháp -> Kiếm–Pháp song tu.

### Real consequences

Full P2.4 depth is reached at 1,200 XP per path and clamps after that for current effects.

Shared expertise:

- matching accumulated path improves the active same-path technique's real effect strength by up to 20%.

Kiếm:

- up to +4 effective combat power;
- up to +18 HUNT utility.

Thể:

- up to 12% intrinsic incoming-damage reduction;
- up to +5 HUNT utility;
- up to +5 REST utility.

Pháp:

- up to +12% cultivation gain;
- up to +18 CULTIVATE utility.

These effects feed existing combat, region power checks, cultivation and autonomous action selection. P2.4 therefore changes decisions/outcomes rather than only displaying a path title.

### Compatibility

- `P23Factory` remains path-disabled;
- `P24Factory` creates P2.3 first, then enables path tracking;
- path progression uses no new RNG;
- P0/P1/P2.1/P2.2/P2.3 behavior remains available when the P2.4 flag is off;
- P2.3 still allows max 3 learned techniques and only 1 active technique, so P2.4 cannot stack multiple technique paths simultaneously.

### P2.4 verification contract

1. Full P0 through P2.3 gate chain must PASS first.
2. P23Factory must remain path-disabled and unaffected.
3. Cultivation/combat with a Sword technique must add Sword XP only.
4. Switching to a Spell technique must add Spell XP while retaining prior Sword XP.
5. 70/30 history must derive primary identity; 60/40 must derive mixed identity.
6. Same technique + same current stats must perform better with deep matching path history.
7. Deep Sword must increase effective combat power.
8. Deep Body must reduce incoming damage.
9. Deep Spell must increase cultivation gain.
10. Path depth must measurably change autonomous action utility.
11. Save/load must preserve path XP and P2.4 sect state.
12. Same-seed simulation and post-load continuation must remain deterministic.
13. All earlier invariants and P0 money conservation must remain green.
14. P2.4 interaction scene must launch on Godot 4.7.2.

Authoritative command: `Sync-P2-4.cmd`.

Expected final markers include:

- `P2.3 TECHNIQUE ECONOMY + MASTERY CONSEQUENCE GATE: PASS`
- `P2.4 CULTIVATION PATH + IDENTITY CONSEQUENCE TEST PASS`
- `P2.4 CULTIVATION PATH + IDENTITY CONSEQUENCE GATE: PASS`
- `P2.4 GATE: PASS`

## P2.4 exclusions

P2.4 does not add master/disciple hierarchy, master teaching, combat skills/moves, equipment, special physiques, pills, tribulations, secret realms, bosses/factions, new profession paths, Dao-event trees or combat-team V2.

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
- P2.3: IMPLEMENTED / AWAITING RUNTIME GATE.
- P2.4: IMPLEMENTED / AWAITING RUNTIME GATE.

Runtime verification for P1.4–P2.4 is intentionally deferred until the user returns to the Windows/Godot 4.7.2 machine. Do not mark any pending phase PASS before a real `Sync-P2-4.cmd` run completes successfully.
