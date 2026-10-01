# AGENTS.md — Tông Môn Bá Đạo AI Development Contract

## Authority order

1. current user instruction;
2. `CURRENT_CHECKPOINT.md`;
3. live code + tests;
4. active phase spec under `docs/`;
5. older discussion only for historical context.

## Non-negotiable engineering rules

- Godot/GDScript is the simulation authority.
- Do not introduce a parallel gameplay engine.
- Static definitions and runtime state remain separated.
- Simulation code must not depend on presentation/UI nodes.
- Randomness must flow through deterministic seeded streams.
- Existing P0 money conservation must remain intact unless a source/sink is explicitly declared.
- P2.3 spirit-stone economy stays separate from P0 money.
- Every runtime mutation must preserve invariants.
- New mechanics need measurable simulation/gameplay consequences; labels alone do not count.
- Never call a phase PASS without its real cumulative Godot gate.
- Do not weaken exact persistence/determinism tests to make a gate pass.

## Runtime baseline

Real Windows + Godot 4.7.2 evidence confirms **P0 through P2.7 PASS**.

P2.7 is LOCKED. Do not reopen it without new regression evidence.

Active phase:

**P2.8 — Disciple Generation V2 + Phẩm chất + Recruitment Sources**

Status: **IMPLEMENTED / AWAITING REAL GODOT 4.7.2 RUNTIME GATE**.

Authoritative root launcher:

- `Sync-P2-8.cmd`

Historical phase verifiers remain under `tools/godot` and are called cumulatively.

## Required loop

read checkpoint -> narrow scope -> patch -> static review -> headless parse -> simulation tests -> scene smoke -> checkpoint

## Core game identity

The player is the **Tông Chủ**, not an invisible city-builder cursor.

The player controls infrastructure, recruitment, policies, investment, assignments and strategic intervention. Disciples are autonomous people who live, work, cultivate, hunt, recover, consume, form relationships and create stories.

Primary operating rhythm: **Evil Hunter Tycoon**.

Reference specialization:

- `最强祖师` -> multidimensional disciple identity, promotable quality, traits/quirks, production value, loyalty/injury/profile ideas;
- `The Lost Village` -> work assignment, groups and schedule;
- `Amazing Cultivation Simulator` -> work priorities and later mentor/inner-disciple opportunity cost;
- `鬼谷八荒` -> sect rank, elders/halls and delegation;
- `Sect Master / 宗门经理人` -> expedition -> warehouse -> production -> disciple growth loop;
- `修仙家族模拟器` -> later bulk rules, stipends/loyalty and lineage;
- RimWorld/ONI -> scalable roster priorities/templates.

Routine one-by-one micromanagement must remain optional at scale.

## Canonical disciple philosophy

Normal disciples are deterministic procedural individuals, not hand-authored one by one.

A disciple conceptually separates:

1. innate foundation;
2. learned progression;
3. awakening/realization;
4. acquired world assets;
5. living state;
6. organization/social state.

Do not collapse Spiritual Root, Bloodline, Physique, Destiny, traits/quirks and personality into one semantic system.

### Innate does not mean forever frozen

Ordinary training changes learned progression. Rare transformation/refinement/awakening may alter innate foundation.

Hidden identity is generated once and persisted. Future reveal must never reroll it.

## P2.7 locked contract

P2.7 keeps separate:

- `sect_rank` — status/authority schema;
- `profession_xp` — learned profession mastery;
- profession talent/traits — innate aptitude;
- `work_group_id` — production group;
- P1.5 combat/adventure team + role.

Workforce authority order:

1. survival emergency;
2. direct Sect Master command;
3. deterministic schedule;
4. personal/group work priority;
5. normal Goal/Decision autonomy.

Active real profession loops:

- Mining -> real Thanh Thiết into P2.6 forge storage;
- Forging -> real forge-support point consumed by a P2.6 craft.

Do not convert profession into fixed character class.

## P2.8 active contract

Read:

- `docs/DISCIPLE_GENERATION_CANON.md`
- `docs/DISCIPLE_LIFESPAN_CANON.md`
- `docs/P1_P2_6_CANON_AUDIT.md`
- `docs/P2_8_DISCIPLE_GENERATION_V2_SPEC.md`
- `CURRENT_CHECKPOINT.md`

### Feature gate

P2.8 is opt-in through:

- `SectState.disciple_generation_v2_enabled`.

When false, legacy P1.2/P2.2/P2.7 behavior and serialized shape must remain unchanged.

### One generator for all recruitment sources

Active P2.8 source types:

- ordinary recruitment;
- Chiêu Hiền / gacha;
- Nhân Duyên / fate encounter.

All use `DiscipleGeneratorV2`.

Source changes distribution/guarantees only; it must not change the character schema.

Chiêu Hiền consumes:

- `disciple_recruitment_tokens`.

Do not reuse P2.3 technique gacha resources.

### Six permanent foundation dimensions

Canonical internal range: `0.0..1.0`; UI may display `0..100`.

- `aptitude` — Tư Chất;
- `constitution` — Căn Cốt;
- `fortune` — Cơ Duyên;
- `comprehension` — Thông Tuệ;
- `charisma` — Mị Lực;
- `potential` — Tiềm Lực.

P2.7 `comprehension` is reused. Do not add a duplicate Thông Tuệ field.

Current real consequences:

- Tư Chất -> cultivation gain when P2.8 is enabled;
- Thông Tuệ -> existing P2.7 work learning/productivity.

Do not invent fake consequences for the other dimensions yet.

### Phẩm chất

Mandatory and promotable tiers:

1. Phàm Thường;
2. Xuất Chúng;
3. Thiên Kiêu;
4. Tuyệt Luân;
5. Nghịch Thiên.

Quality derives only from permanent foundation.

It must not directly include:

- current realm;
- combat power;
- equipment;
- sect rank;
- profession XP;
- temporary buffs/resources.

Quality is a fast summary, not a universal value score. A lower-quality disciple can be the better specialist.

### Spiritual Root V2 bridge

Keep separate:

- `spiritual_root_purity`;
- `spiritual_root_elements`.

Element count must not be rigidly derived from root quality/purity.

For compatibility, P2.8 purity maps into existing P2.2 quality buckets so the locked P2.2/P2.3 consequence code remains usable.

### Age/lifespan schema

P2.8 stores:

- `age`;
- `base_lifespan`;
- `max_lifespan`.

Active death/aging is deferred.

Future canonical lifespan rules:

- major realm breakthrough is the primary lifespan increase;
- longevity pills/treasures/inheritances may add lifespan;
- repeated use of the same cheap longevity pill must have diminishing/limited effect;
- forbidden techniques/injury/curses may later reduce lifespan.

### Candidate acceptance identity lock

Candidate -> disciple must preserve generated identity exactly.

P2.7 must not see an intentionally empty V2 trait list and reroll extra traits.

### Combat power order

P2.8 generates foundation first.

Intrinsic combat power is derived from foundation. Realm contribution remains in P2.1 `cultivation_combat_bonus`; do not double-count realm power.

## P2.8 gate

Must prove:

1. P2.7 remains V2-disabled and legacy recruitment unchanged;
2. same seed/source/index -> identical complete profile;
3. all three sources use one schema;
4. six dimensions persist exactly;
5. quality ignores temporary/current progression;
6. permanent foundation can promote quality;
7. lower quality can outperform higher quality for a specific profession;
8. root purity and element count are independent;
9. combat power is derived after foundation and uses P2.1 realm bonus separately;
10. Tư Chất changes real cultivation gain;
11. gacha consumes exactly one recruitment token;
12. fate recruitment creates a complete profile;
13. acceptance preserves identity exactly;
14. exact save/load + deterministic continuation pass;
15. P0-P2.7 regression chain remains green;
16. P2.8 scene smoke passes.

## Deferred until P2.8 runtime green

- full traits/quirks and hidden reveal events;
- root refinement/mutation;
- Bloodline;
- Physique;
- injury/medical;
- loyalty + stipend/reward;
- expanded sect rank/authority;
- master-disciple/teaching;
- Destiny/awakening;
- active aging/death/inheritance.
