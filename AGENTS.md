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
- P2.3 spirit-stone/material economy stays separate from P0 money.
- Every runtime mutation must preserve invariants.
- New mechanics need measurable gameplay consequences; labels alone do not count.
- Never call a phase PASS without its real cumulative Godot gate.
- Never weaken exact persistence/determinism tests just to make a gate pass.
- New phases must be opt-in when changing locked behavior.
- Hidden identity is generated once and persisted. Reveal/transformation never rerolls it.

## Global mechanic-consequence rule

**Do not fear overlap.** Different systems may all modify Công, Thủ, HP, cultivation speed, breakthrough, recovery, production, XP, risk, movement, cooldowns or other concrete outputs when logically justified.

Systems are differentiated by source, acquisition, progression, cost, conditions, tradeoffs and signature rules — not by forcing each system to own a unique stat.

A rare/valuable feature must first provide meaningful player value. Humor, flavor and drawbacks are secondary layers and cannot replace its main benefit.

Every new-system gate must test the actual consequence, not just a field or UI label.

## Runtime baseline

Real Windows + Godot 4.7.2 evidence confirms **P0 through P2.11 PASS**.

P0-P2.11 are locked runtime-green baselines. Do not reopen them without new regression evidence.

Active phase:

**P2.12 — Thể Chất + Tôi Thể + Cải Thể**

Status: **IMPLEMENTED / AWAITING REAL GODOT 4.7.2 CUMULATIVE GATE**.

Authoritative launcher:

- `Sync-P2-12.cmd`

It reruns P0-P2.11 before the P2.12 diagnostic/contracts/scene smoke.

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
3. awakening/realization/transformation;
4. acquired world assets;
5. living state;
6. organization/social state.

Do not collapse Spiritual Root, Bloodline, Physique, Destiny, traits/quirks and personality into one system.

Innate does not mean permanently frozen. Rare transformation/refinement/awakening may alter foundation, while ordinary training changes learned progression.

## Locked character foundation through P2.11

### P2.8 procedural identity

Six permanent dimensions:

- aptitude — Tư Chất;
- constitution — Căn Cốt;
- fortune — Cơ Duyên;
- comprehension — Thông Tuệ;
- charisma — Mị Lực;
- potential — Tiềm Lực.

Promotable quality:

- Phàm Thường
- Xuất Chúng
- Thiên Kiêu
- Tuyệt Luân
- Nghịch Thiên

Ordinary / Chiêu Hiền / Nhân Duyên share one deterministic generator.

### P2.9 traits

Positive/negative/latent traits must have real cultivation/work/combat consequences. Empty visible traits is a valid initialized result.

### P2.10 roots

Purity and element count are independent. Refinement consumes real Linh Tủy, preserves elements, changes real cultivation/breakthrough/technique effects and can reveal a pre-generated mutation.

### P2.11 bloodline

Special awakened bloodlines have real core stats before gimmicks:

- Chân Long: Công + Thủ + Tu + Đột phá + Hồi;
- Phượng Hoàng: Công + Thủ + Tu + Đột phá nhẹ + Hồi rất cao;
- Bạch Hổ: Công cao nhất + Tu nhỏ;
- Huyền Vũ: Thủ cao nhất + Công + Tu + Hồi;
- Thao Thiết: Công + Thủ + Tu + Hồi; extra Supply is only a tradeoff;
- none remains valid/common.

Awakening/refinement consumes real Yêu Đan. Higher purity strengthens real effects.

## Active P2.12 Physique contract

Read:

- `docs/P2_12_PHYSIQUE_SPEC.md`
- `CURRENT_CHECKPOINT.md`

Feature gate:

- `SectState.physiques_enabled`.

Profiles live in:

- `SectState.physique_profiles[character_id]`.

Schema:

- initialized;
- physique_id;
- initial_physique_id;
- temper_level;
- transformed;
- latent_transformation.

Candidate -> disciple preserves exact profile. Reject removes orphan profile.

Current physiques:

- Phàm Thể — temperable, has deterministic future transformation route;
- Kiếm Cốt — Công/Tu/Đột phá + Sword XP, slight recovery drawback;
- Kim Cương Bá Thể — high Công/Thủ/Hồi + Body XP, slower cultivation drawback;
- Hàn Âm Thể — strong with Water root, real mismatch penalty without it;
- Hỏa Linh Thể — strong Công/Tu/Đột phá/Spell XP with Fire root;
- Vô Cấu Đạo Thể — rare all-rounder.

Tempering:

- consumes 1 real Yêu Đan;
- max vertical-slice level 5;
- must improve real effects.

Transformation:

- only from Phàm Thể;
- requires temper >= 3;
- consumes 2 real Linh Tủy;
- uses pre-generated latent target;
- never rerolls;
- preserves temper level.

Real hooks:

- CultivationSystem -> Công/Tu/Đột phá;
- CombatSystem -> Thủ;
- NeedsSystem -> Hồi/penalty;
- CultivationPathSystem -> Sword/Body/Spell XP affinity.

**Bloodline + Physique overlap must stack.** Do not introduce exclusivity because two systems modify the same stat.

## Xianxia humor/flavor contract

The game may be funny in a cultivation-story way, but it is not a meme game.

Examples: khẩu nghiệp, fake Thiên Mệnh Chi Tử confidence, furnace explosions, odd manuals, gluttony, greed, gossip, badly timed breakthroughs and mismatched equipment.

Humor must come from real simulation causes/consequences. Do not spam joke text.

## Current verification chain

Use:

- `tools/godot/Verify-P2-12.ps1`
- `Sync-P2-12.cmd`

It must prove cumulative P0-P2.11 regressions first, then P2.12 persistence, deterministic profiles, real advantages/drawbacks, elemental synergy, tempering/transformation resource costs, Bloodline+Physique stacking, recruitment lifecycle and scene smoke.

Never claim P2.12 PASS without final real Godot 4.7.2 output.

## After P2.12 runtime green

Pause backend identity expansion and build the first **visible living sect** slice:

- compact sect map;
- real buildings/destinations;
- disciples physically move between work/rest/cultivation/sect gate;
- state/action visible on the map;
- simulation remains authoritative.

Then continue injury/medical, loyalty/stipend, rank/authority, master-disciple, Destiny, and eventually active lifespan/death/inheritance after pacing is proven.
