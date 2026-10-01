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
- Existing P0 money conservation remains intact unless a source/sink is explicit.
- P2.3 spirit-stone economy stays separate from P0 money.
- Every runtime mutation must preserve invariants.
- New mechanics need measurable gameplay consequences; labels alone do not count.
- Never call a phase PASS without its real cumulative Godot gate.
- Never weaken exact persistence/determinism tests just to make a gate pass.
- New phases must be opt-in when changing locked behavior.
- Hidden identity is generated once and persisted. Reveal never rerolls it.

## Runtime baseline

Real Windows + Godot 4.7.2 evidence confirms **P0 through P2.8 PASS**.

P2.8 is LOCKED. Do not reopen P0-P2.8 without new regression evidence.

Not yet runtime-confirmed:

- P2.9 Traits + Hidden Reveal: IMPLEMENTED / AWAITING GATE.
- P2.10 Spiritual Root Refinement + Mutation: IMPLEMENTED / AWAITING GATE.

Authoritative current launcher:

- `Sync-P2-10.cmd`

It runs the cumulative P0 -> P2.9 chain before P2.10. Do not require the user to run P2.9 separately.

## Required loop

read checkpoint -> narrow scope -> patch -> static review -> headless parse -> simulation tests -> scene smoke -> checkpoint

## Core game identity

The player is the **Tông Chủ**.

The player controls infrastructure, recruitment, policy, investment, assignments and strategic intervention. Disciples are autonomous people who live, work, cultivate, hunt, recover, consume, form relationships and create stories.

Primary operating rhythm: **Evil Hunter Tycoon**, with much deeper individual disciples.

Routine one-by-one micromanagement must remain optional at scale.

## Canonical disciple philosophy

Normal disciples are deterministic procedural individuals, not hand-authored one by one.

Keep separate:

1. innate foundation;
2. learned progression;
3. awakening/realization;
4. acquired world assets;
5. living state;
6. organization/social state.

Do not collapse Spiritual Root, Bloodline, Physique, Destiny, traits/quirks and personality into one system.

Innate does not mean permanently frozen. Rare transformation/refinement/awakening may alter innate foundation, while ordinary training changes learned progression.

## Locked P2.7 workforce contract

Keep separate:

- sect rank/status;
- innate profession talent;
- learned profession XP;
- work group;
- combat/adventure team + role.

Authority order:

1. survival emergency;
2. direct Sect Master command;
3. schedule;
4. personal/group work priority;
5. normal autonomy.

Real loops:

- Mining -> real Thanh Thiết;
- Forging -> real support point consumed by P2.6 craft.

## Locked P2.8 identity contract

Read:

- `docs/DISCIPLE_GENERATION_CANON.md`
- `docs/DISCIPLE_LIFESPAN_CANON.md`
- `docs/P2_8_DISCIPLE_GENERATION_V2_SPEC.md`

### Six permanent dimensions

- aptitude — Tư Chất;
- constitution — Căn Cốt;
- fortune — Cơ Duyên;
- comprehension — Thông Tuệ;
- charisma — Mị Lực;
- potential — Tiềm Lực.

`comprehension` reuses P2.7. Do not create another Thông Tuệ field.

### Phẩm chất

Mandatory promotable tiers:

- Phàm Thường
- Xuất Chúng
- Thiên Kiêu
- Tuyệt Luân
- Nghịch Thiên

Quality derives from permanent foundation only. It is a fast summary, not the only value score.

### Recruitment

Ordinary / Chiêu Hiền / Nhân Duyên all use one deterministic `DiscipleGeneratorV2` schema.

### Spiritual Root V2

Keep separate:

- `spiritual_root_purity`;
- `spiritual_root_elements`.

Element count is independent from purity.

### Lifespan schema

P2.8 stores age/base/max lifespan. Active aging/death remains deferred.

Future canon: major-realm breakthrough is the primary lifespan increase; longevity pills/treasures can help; one cheap pill cannot create infinite life.

## P2.9 implemented contract — traits and hidden reveal

Read `docs/P2_9_TRAITS_REVEAL_SPEC.md`.

Feature gate:

- `SectState.disciple_traits_enabled`.

Profiles live in:

- `SectState.disciple_trait_profiles[character_id]`.

Schema:

- initialized;
- visible;
- latent;
- revealed.

Empty visible is a valid initialized profile and must never trigger a reroll.

Current real consequences:

- Kinh Mạch Ổn Định / Kinh Mạch Yếu -> cultivation;
- Cần Mẫn / Cẩu Thả -> workforce;
- Gan Dạ / Nhát Chiến -> effective combat power;
- Bản Năng Chiến Đấu / Nhãn Lực Luyện Khí / Ngộ Tĩnh -> latent, history-triggered reveal with real consequences.

Acceptance preserves profile; rejection removes orphan state.

P2.9 is NOT runtime PASS yet.

## P2.10 implemented contract — spiritual-root refinement

Read:

- `docs/P2_10_SPIRITUAL_ROOT_REFINEMENT_SPEC.md`
- `CURRENT_CHECKPOINT.md`

Feature gate:

- `SectState.spiritual_root_refinement_enabled`.

Storage:

- `SectState.spiritual_root_profiles[character_id]`.

Profile schema:

- initialized;
- refinement_count;
- latent_mutation;
- revealed_mutation.

### Real resource loop

P2.10 consumes the existing P2.3 `linh_tuy` material.

Do not add a disconnected root-refinement currency.

Player tradeoff:

`Linh Tủy -> upgrade technique` versus `Linh Tủy -> refine spiritual root`.

### Refinement rule

Ordinary refinement:

- increases purity;
- consumes exactly one Linh Tủy;
- uses diminishing returns;
- receives a Tiềm Lực contribution;
- does not alter the root element list;
- caps routine purity below absolute perfection.

Compatibility thresholds:

- `<0.48` Mixed;
- `0.48..<0.65` Ordinary;
- `0.65..<0.82` Earth;
- `>=0.82` Heaven.

The bridge keeps locked P2.2/P2.3 consequences usable.

### Specialization/flexibility

- fewer elements -> stronger specialization on one matching element;
- more elements -> broader compatibility;
- multi-root is not automatically bad;
- purity remains independent from element count.

### Latent mutation

Current vertical-slice mutations:

- Canh Kim Dị Căn;
- Thanh Mộc Dị Căn;
- Hàn Thủy Dị Căn;
- Xích Viêm Dị Căn;
- Hậu Thổ Dị Căn.

Mutation is generated before reveal from deterministic identity.

Reveal currently requires:

- at least 3 refinements;
- purity >= 0.72;
- pre-existing latent mutation.

Reveal never rerolls latent identity and has measurable cultivation/breakthrough/matching-element consequences.

Acceptance preserves root profile; rejection removes it.

P2.10 is NOT runtime PASS yet.

## Current verification chain

Use:

- `tools/godot/Verify-P2-10.ps1`
- `Sync-P2-10.cmd`

It must run P0 -> P2.9 first, then:

1. P2.10 persistence diagnostic;
2. root refinement/mutation consequence contracts;
3. P2.10 scene smoke.

Never claim P2.9 or P2.10 PASS without real Godot 4.7.2 output.

## After cumulative P2.10 green

Preferred order:

1. Bloodline;
2. Physique;
3. first visible living-sect map/building/disciple movement slice;
4. injury/medical;
5. loyalty + stipend/reward;
6. sect rank/authority expansion;
7. master-disciple/teaching;
8. Destiny/awakening;
9. active lifespan/aging/death/inheritance after pacing is proven.

Do not build every backend identity layer before returning to visible gameplay.
