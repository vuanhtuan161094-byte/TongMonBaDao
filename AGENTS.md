# AGENTS.md — Tông Môn Tycoon AI Development Contract

## Authority order

1. current user instruction;
2. `CURRENT_CHECKPOINT.md`;
3. live code + tests;
4. active phase spec under `docs/`;
5. older discussion only for historical context.

## Non-negotiable rules

- Godot/GDScript is the simulation authority.
- Do not introduce a parallel JavaScript gameplay engine.
- Static content definitions and runtime state stay separated.
- Simulation code must not depend on presentation/UI nodes.
- Randomness must flow through deterministic seeded streams.
- Economy transactions must conserve P0 money unless a source/sink is explicitly declared.
- P2.3 spirit-stone sources/sinks must remain explicit and separate from P0 money conservation.
- Every runtime state mutation must preserve invariants.
- Prefer small composition-oriented systems over giant manager scripts.
- Do not call a change PASS without the active verification gate.
- New mechanics must have measurable gameplay/simulation impact; decorative labels alone do not count.

## Runtime baseline

Real Godot 4.7.2 cumulative runtime evidence confirms **P0 through P2.6 PASS**.

P2.6 is LOCKED. Do not weaken or bypass its contracts.

P2.7 is **IMPLEMENTED / AWAITING RUNTIME GATE**. Do not call it PASS until the cumulative Godot 4.7.2 gate reaches and passes it.

## Required loop

read checkpoint -> narrow scope -> patch -> static review -> headless import/parse -> simulation tests -> runtime smoke -> checkpoint

## Cumulative verification chain

- P0: `tools/godot/Verify-P0.ps1`
- P1.1: `tools/godot/Verify-P1-1.ps1`
- P1.2: `tools/godot/Verify-P1-2.ps1`
- P1.3: `tools/godot/Verify-P1-3.ps1`
- P1.4: `tools/godot/Verify-P1-4.ps1`
- P1.5: `tools/godot/Verify-P1-5.ps1`
- P1.6: `tools/godot/Verify-P1-6.ps1`
- P2.1: `tools/godot/Verify-P2-1.ps1`
- P2.2: `tools/godot/Verify-P2-2.ps1`
- P2.3: `tools/godot/Verify-P2-3.ps1`
- P2.4: `tools/godot/Verify-P2-4.ps1`
- P2.5: `tools/godot/Verify-P2-5.ps1`
- P2.6: `tools/godot/Verify-P2-6.ps1`
- P2.7: `tools/godot/Verify-P2-7.ps1`

Latest authoritative launcher: `Sync-P2-7.cmd`.

## Core character philosophy

The player is the Sect Master, not an invisible city-builder cursor.

The player sets infrastructure, recruitment, assignments, policies, investment and strategic direction, and can intervene directly when appropriate. Disciples remain autonomous people inside the sect rather than puppets.

Do not introduce a fixed character class system. Sword/Body/Spell identity is emergent from cultivation/path history and compatible systems.

A disciple can be valuable through combat, cultivation, crafting, production, logistics, social/administrative duties and later teaching/lineage systems.

## Reference-game hierarchy

Primary operating rhythm: **Evil Hunter Tycoon**.

Use it for autonomous characters, sect economy, hunt -> material -> production -> consumption loops, and temporary direct one-character commands from the Sect Master.

Use other references only for their strongest domain:

- `最强祖师`: multidimensional disciple value, quality progression, traits/quirks, production specialization, loyalty/injury/reference UI;
- `The Lost Village`: work assignment, group priorities and work/cultivation/recovery scheduling;
- `Amazing Cultivation Simulator`: work priorities and later mentor/inner-disciple opportunity-cost ideas;
- `鬼谷八荒`: sect rank, elders/halls and delegated task authority;
- `Sect Master / 宗门经理人`: expedition -> warehouse -> production -> disciple build economy loop;
- `修仙家族模拟器`: later bulk assignment rules, stipend/loyalty and lineage ideas;
- RimWorld/ONI: scalable priorities/templates for large autonomous rosters.

Read:

- `docs/GAMEPLAY_REFERENCE_SYNTHESIS.md`
- `docs/DISCIPLE_SYSTEM_DEEP_RESEARCH.md`
- `docs/DISCIPLE_SYSTEM_LATEST_SOURCE_ADDENDUM_2026-10-01.md`
- `docs/DISCIPLE_GENERATION_CANON.md`
- `docs/P2_7_DISCIPLE_LIFE_WORKFORCE_SPEC.md`

`docs/DISCIPLE_GENERATION_CANON.md` is the canonical rule for future procedural disciple generation and supersedes older discussion that rejected quality/gacha outright.

## Canonical procedural-disciple rules

Normal future disciples are **procedurally generated deterministic individuals**, not hand-authored one by one.

Recruitment sources may include:

- ordinary recruitment;
- Chiêu Hiền / gacha;
- Nhân Duyên / Cơ Duyên events;
- recommendation;
- story/world events.

All sources use one deterministic generator with different source distributions/rules.

Every generated disciple conceptually separates:

1. innate foundation;
2. learned progression;
3. awakening/realization;
4. acquired items/knowledge;
5. living state;
6. organization/social state.

### Phẩm chất is mandatory

Disciple quality is a fast-reading summary of permanent foundation/potential and **can be promoted**.

Working tiers:

- Phàm Thường;
- Xuất Chúng;
- Thiên Kiêu;
- Tuyệt Luân;
- Nghịch Thiên.

Quality must not include temporary equipment, rank, current realm, temporary buffs or current profession level.

Quality is allowed as a roster/gacha summary but must **not become the only AI/player value score**. A lower-quality disciple may be more valuable for a specific profession/build because of roots, bloodline, physique, destiny, profession talent, personality or history.

### Innate vs learned must stay separate

Examples:

- profession talent = innate/trait;
- profession XP/level = learned by doing;
- spiritual root/bloodline/physique = primarily innate but may be refined/awakened through rare transformations;
- cultivation realm/technique mastery/path XP = learned progression;
- equipment/artifacts/manuals = acquired from the world;
- loyalty/injury/stamina/mood = living state.

Do not let ordinary repetitive training silently reroll innate identity.

### Hidden information

Latent bloodline/physique/destiny/traits may be generated at creation and revealed later. Reveal must not reroll the hidden state.

### Bloodline / Physique / Destiny

These are separate concepts:

- bloodline = lineage/inherited source + purity/awakening;
- physique = body configuration, innate or transformed;
- destiny = rare rule-changing identity/milestone system;
- spiritual root = elemental cultivation compatibility;
- traits/quirks = smaller positive/negative consequences;
- personality = behavioral decision bias.

Do not merge them into one `traits` list semantically even if storage composition is shared internally.

## P2.6 locked contract — Forge + Equipment Tycoon

Required loop:

`hunt -> forge materials -> sect forge -> storage/shop -> autonomous purchase or player allocation -> stronger disciple -> harder hunt`

Locked behavior:

- autonomous equipment is default;
- player may manually equip;
- player may lock/unlock equipment slots;
- internal purchase conserves total money;
- item quality/identity is deterministic;
- nested equipment state survives exact save/load;
- equipment changes real region choice and combat consequences;
- compatibility changes actual effectiveness, not legality.

P2.7 hooks into P2.6 only when `workforce_enabled == true`. P2.6 behavior must remain unchanged when workforce is off.

## Active P2.7 contract — Disciple Life + Workforce + Sect Assignment

P2.7 must keep these concepts separate:

1. `sect_rank` — status/authority schema;
2. `profession_xp` + workforce specialization;
3. `work_group_id` — production group/department;
4. P1.5 combat/adventure team and role.

Do not overload one `role` field.

### Workforce authority order

1. survival emergency;
2. direct Sect Master command;
3. deterministic schedule phase;
4. personal/group work priority;
5. existing GoalSystem/DecisionSystem autonomy.

Direct commands must complete/expire and return the disciple to autonomy.

### P2.7 vertical slice

Only two professions have active gameplay:

- **Mining** -> real Thanh Thiết into P2.6 forge storage, mining XP, higher-level yield;
- **Forging** -> real forge-support points, forging XP, next P2.6 craft gets +5% stat multiplier when support is consumed.

Other profession IDs may exist as schema but do not count as completed systems.

### Schedule

A deterministic 20-tick schedule reserves time for:

- work;
- cultivation;
- recovery.

Policies: balanced / production_push / cultivation_focus.

Assigned work must not permanently suppress cultivation/recovery.

### Recruitment

Current P2.7 candidates gain deterministic comprehension and up to two profession traits. This is an interim subset of the future generator, not the final disciple-generation model.

### Persistence

P2.7 workforce state must survive exact SaveService v2 round-trip and deterministic continuation. `p2_7_persistence_diagnostic.gd` is the first-difference diagnostic.

### P2.7 anti-patterns

- fixed profession classes;
- one hard-coded DecisionSystem branch per future profession;
- work forever with no cultivation/recovery;
- candidate value only by combat power or only by quality;
- repetitive one-by-one mandatory micromanagement;
- decorative aptitude/trait labels without consequences;
- AI replacing an active direct Sect Master command;
- expanding the full future disciple generator before the workforce gate is green.
