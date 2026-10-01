# CURRENT CHECKPOINT

Date: 2026-10-01

## Runtime-confirmed state

Real Windows + Godot 4.7.2 cumulative evidence confirms:

- P0 Foundation: LOCKED / PASS.
- P1.1 Goal + Personality: LOCKED / PASS.
- P1.2 Recruitment + Player Choice: LOCKED / PASS.
- P1.3 Relationships + Behavioral Impact: LOCKED / PASS.
- P1.4 Consequential Memory: PASS.
- P1.5 Organization + Teams + Leadership + Roles: PASS.
- P1.6 Sect Life + Needs + Resource Pressure: PASS.
- P2.1 Cultivation + Realms + Breakthrough: PASS.
- P2.2 Spiritual Root Quality + Long-Term Growth: PASS.
- P2.3 Technique Economy + Library + Mastery: PASS.
- P2.4 Cultivation Paths / Character Dao Direction: PASS.
- P2.5 Combat Skills / Real-time Auto Combat: PASS.
- P2.6 Forge + Equipment Tycoon: LOCKED / PASS.

Latest cumulative P2.6 evidence:

- P2.5 realtime combat + independent skills: PASS.
- P2.6 persistence diagnostic: PASS.
- P2.6 forge + autonomous/manual equipment contracts: PASS.
- P2.6 equipment combat-stat consequences: PASS.
- P2.6 interaction scene smoke: PASS.
- Final `P2.6 FORGE + EQUIPMENT TYCOON GATE: PASS`.

## Persistence fixes carried forward

- SaveService v2 losslessly stores float64 values through exact byte encoding.
- P2.1 decision snapshot integer fields are canonicalized after load.
- P2.6 nested equipment instances are canonicalized after load: integer price, float stats, stable string identity/location/owner fields.
- P2.6 immediate canonical save/load equality passes.

## Architecture locks

- Godot 4.7.2 / GDScript is gameplay authority.
- Deterministic seeded simulation is mandatory.
- Save/load exactness, invariants and explicit economy sources/sinks remain mandatory.
- No fixed character class. Sword/Body/Spell identity comes from actual cultivation/path history and compatible systems.
- Player is the sect master: manages the sect and may intervene directly, while disciples remain autonomous by default.
- New mechanics must have measurable simulation/player-decision consequences.

## Progression stack locked through P2.6

- P2.1: cultivation -> breakthrough -> realm -> combat/HP.
- P2.2: spiritual roots -> growth/compatibility.
- P2.3: technique economy + library + mastery.
- P2.4: emergent Sword/Body/Spell path identity.
- P2.5: independent combat skills + deterministic realtime auto combat.
- P2.6: hunt materials -> forge -> equipment storage/shop -> autonomous purchase or player allocation -> harder hunting/combat.

## P2.6 locked behavior

Player/AI authority:

- autonomous equipment is default;
- disciples evaluate gear from build compatibility, personality and price;
- player can manually equip;
- player can lock a slot against AI replacement;
- unlock returns the slot to autonomous management;
- manual allocation is not a purchase.

Economy:

`disciple wallet - price -> sect treasury + price`

Internal equipment purchases conserve total simulation money.

Real consequences:

- combat wins can generate forge materials;
- forged items are deterministic instances;
- equipment power changes autonomous region choice and real combat power;
- armor changes real incoming damage;
- speed/range/basic-ratio change real attack behavior;
- skill-effect stats modify real combat skills;
- compatibility changes actual effectiveness, not only UI scoring.

## Post-P2.6 gameplay reference lock

Primary gameplay rhythm stays closest to **Evil Hunter Tycoon**:

- characters move/live/fight autonomously;
- player manages sect infrastructure, resources, production, assignments and preparation;
- player can call one disciple and issue a direct temporary order;
- hunt/expedition rewards feed production and disciple growth;
- disciple personal economy and sect economy interact.

Other reference responsibilities are explicitly separated:

- **最强祖师** -> personality/traits + multidimensional disciple value + production specialization;
- **The Lost Village** -> work assignment, group/position preference, life/work/cultivation scheduling;
- **鬼谷八荒** -> sect rank, delegation, elders/hall authority, task departments;
- **Sect Master / 宗门经理人** -> autonomous expedition -> warehouse -> production -> disciple build -> harder expedition economy loop.

Research synthesis is stored in:

- `docs/GAMEPLAY_REFERENCE_SYNTHESIS.md`

## Required architecture correction before/inside P2.7

The current P1.5 `role_assignments` semantic (`hunter / logistics / guard`) must not be expanded to also mean sect rank or profession.

Three concepts must be separate:

1. **Sect rank / authority** — outer, inner, core, deacon, elder, hall master...
2. **Profession / work specialization** — forging, alchemy, herbalism, mining, logistics...
3. **Combat/adventure role** — existing team role behavior or future tactical role.

A disciple may simultaneously be:

`Inner disciple + Forging specialist + Hunt-team member`.

Do not build P2.7 on one overloaded `role` field.

## P2.7 design candidate

Working title:

**P2.7 — Disciple Life + Workforce + Sect Assignment**

Design spec:

- `docs/P2_7_DISCIPLE_LIFE_WORKFORCE_SPEC.md`

Core target:

`personal aptitude + profession XP + work priorities + schedule + group assignment + direct Sect Master command + autonomous fallback`.

The first implementation should stay narrow and prove only a few real loops instead of adding many decorative professions.

Recommended vertical slice:

- Mining -> produces real Thanh Thiết into the P2.6 forge store;
- Forging work -> creates a real deterministic production consequence for P2.6;
- profession XP -> repeated work makes a disciple measurably better;
- work schedule -> cannot permanently suppress cultivation/recovery;
- direct Sect Master command -> temporarily overrides autonomy, then returns control;
- group work defaults -> scale beyond six disciples;
- personal override -> beats group default.

## Current-code audit relevant to P2.7

### Keep

- `GoalSystem` survival/personality goals as a personal-goal layer.
- `DecisionSystem` as the top-level action arbitrator.
- P1.5 combat teams and leadership.
- P1.6 needs/recovery pressure.
- P2.1-P2.6 cultivation/build/equipment consequences.

### Refactor/extend

- Recruitment currently differentiates candidates mostly by combat power + three personality biases; add non-combat aptitude/traits so low-combat disciples can still be valuable.
- Organization roles currently conflate generic activity roles; separate combat role from sect rank and workforce group.
- Decision logic must not gain one hard-coded branch per future profession; add a workforce/task authority layer.
- Direct player orders should be represented as persistent deterministic command state with completion/timeout, not one-off UI hacks.

## Deferred beyond initial P2.7

- full elder/hall-master AI delegation;
- master-disciple relationships;
- marriage/dual cultivation;
- lifespan/death/succession;
- sect politics;
- salaries/stipends;
- many production professions;
- full spatial building/pathfinding workforce simulation;
- enhancement +N and advanced equipment reroll systems.
