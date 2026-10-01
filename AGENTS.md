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
- Never weaken exact persistence/determinism tests just to make a gate pass.
- New phases must be opt-in when changing locked behavior.

## Runtime baseline

Real Windows + Godot 4.7.2 evidence confirms **P0 through P2.8 PASS**.

P2.8 is LOCKED. Do not reopen P0-P2.8 without new regression evidence.

Active phase:

**P2.9 — Đặc Chất + Khuyết Điểm + Ẩn/Thức tỉnh**

Status: **IMPLEMENTED / AWAITING REAL GODOT 4.7.2 RUNTIME GATE**.

Authoritative root launcher:

- `Sync-P2-9.cmd`

Historical phase verifiers remain under `tools/godot` and are called cumulatively.

## Required loop

read checkpoint -> narrow scope -> patch -> static review -> headless parse -> simulation tests -> scene smoke -> checkpoint

## Core game identity

The player is the **Tông Chủ**, not an invisible city-builder cursor.

The player controls infrastructure, recruitment, policy, investment, assignments and strategic intervention. Disciples are autonomous people who live, work, cultivate, hunt, recover, consume, form relationships and create stories.

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

Innate does not mean permanently frozen. Rare transformation/refinement/awakening may alter innate foundation, while ordinary training changes learned progression.

Hidden identity is generated once and persisted. Reveal never rerolls it.

## Locked P2.7 workforce contract

Keep separate:

- `sect_rank` — authority/status;
- profession talent — innate aptitude;
- `profession_xp` — learned mastery;
- `work_group_id` — production group;
- P1.5 combat/adventure team + role.

Authority order:

1. survival emergency;
2. direct Sect Master command;
3. schedule;
4. personal/group work priority;
5. normal Goal/Decision autonomy.

Real vertical-slice loops:

- Mining -> Thanh Thiết into P2.6 storage;
- Forging -> forge-support point consumed by a P2.6 craft.

## Locked P2.8 identity contract

Read:

- `docs/DISCIPLE_GENERATION_CANON.md`
- `docs/DISCIPLE_LIFESPAN_CANON.md`
- `docs/P2_8_DISCIPLE_GENERATION_V2_SPEC.md`

### Generator

All ordinary/gacha/fate candidates use `DiscipleGeneratorV2`.

Source types:

- ordinary;
- gacha / Chiêu Hiền;
- fate / Nhân Duyên.

Source changes distribution only, not schema.

### Six permanent dimensions

Internal range `0..1`:

- aptitude — Tư Chất;
- constitution — Căn Cốt;
- fortune — Cơ Duyên;
- comprehension — Thông Tuệ;
- charisma — Mị Lực;
- potential — Tiềm Lực.

`comprehension` reuses P2.7. Do not create another Thông Tuệ field.

Current real consequences:

- Tư Chất -> cultivation gain;
- Thông Tuệ -> workforce learning/productivity.

### Phẩm chất

Mandatory promotable tiers:

- Phàm Thường
- Xuất Chúng
- Thiên Kiêu
- Tuyệt Luân
- Nghịch Thiên

Quality derives from permanent foundation only.

It must not directly count current realm, combat power, gear, sect rank, profession XP or temporary buffs.

Quality is a fast summary, not the only value score.

### Spiritual Root bridge

Keep separate:

- `spiritual_root_purity`;
- `spiritual_root_elements`.

Element count is independent from purity. P2.2 quality buckets remain only as compatibility consequence buckets.

### Age/lifespan schema

P2.8 stores age/base/max lifespan but does not run active aging/death.

Future lifespan canon:

- major-realm breakthrough is the primary lifespan increase;
- longevity pills/treasures/inheritances can add lifespan;
- repeating one cheap pill cannot grant infinite life;
- injury/curses/forbidden techniques may later reduce lifespan.

### Acceptance

Candidate -> disciple preserves generated identity exactly and keeps the same character id.

## Active P2.9 contract

Read:

- `docs/P2_9_TRAITS_REVEAL_SPEC.md`
- `CURRENT_CHECKPOINT.md`

### Feature gate

`SectState.disciple_traits_enabled`.

When false, P0-P2.8 behavior and serialized shape must remain unchanged.

### Trait profile authority

Profiles live in:

- `SectState.disciple_trait_profiles[character_id]`.

Schema:

- `initialized`;
- `visible`;
- `latent`;
- `revealed`.

Empty visible list is a valid initialized profile. Never treat empty as “not generated”.

Candidate and accepted disciple keep the same id, so acceptance must preserve the exact profile.

Rejected candidates must not leave orphan profiles.

### Visible trait slice

Positive:

- `steady_meridians` — cultivation gain bonus;
- `diligent_worker` — work speed / learning bonus;
- `fearless` — combat-power bonus.

Negative:

- `fragile_meridians` — cultivation penalty;
- `careless_worker` — work-speed penalty;
- `timid` — combat-power penalty.

Traits are not decorative. Every active trait in this slice has a measurable simulation consequence.

### Latent/reveal slice

- `battle_instinct` — reveal after 3 combats;
- `craftsman_eye` — reveal after 2 work completions;
- `meditative_insight` — reveal after 3 cultivation sessions.

Latent IDs are generated and persisted before reveal.

Reveal only moves semantic visibility by adding an existing latent ID to `revealed`; it must never reroll or replace `latent`.

### Runtime hooks

- cultivation traits: `CultivationSystem.add_progress()`;
- combat traits: `CultivationSystem.effective_combat_power()`;
- workforce traits: `WorkforceSystem.perform_work()` path via work-speed/learning multipliers;
- reveal checks: `SimulationScheduler` after activity ticks;
- recruitment lifecycle: `RecruitmentSystem`.

### P2.9 anti-patterns

- roll hidden trait at reveal time;
- reroll because visible list is empty;
- duplicate profession talent and general trait semantics without reason;
- trait labels with no real consequence;
- trait effects active while feature gate is off;
- making Phẩm chất absorb all trait meaning;
- turning every trait into a raw combat stat.

## Verification chain

Current active verifier:

- `tools/godot/Verify-P2-9.ps1`

It re-runs P0-P2.8 first, then:

1. P2.9 persistence diagnostic;
2. trait/reveal consequence contracts;
3. P2.9 scene smoke.

Do not claim PASS without final `P2.9 GATE: PASS` from real Godot 4.7.2.

## After P2.9 runtime green

Preferred dependency order:

1. spiritual-root refinement / rare mutation;
2. Bloodline;
3. Physique;
4. injury/medical;
5. loyalty + stipend/reward;
6. sect rank/authority expansion;
7. master-disciple/teaching;
8. Destiny/awakening;
9. active lifespan/aging/death/inheritance after pacing is proven.
