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
- **Every gameplay system must state clearly what it changes in actual play: stats, probabilities, costs, timings, AI priorities, resources, access, risk, output, or concrete rules. Flavor-only mechanics do not count.**
- **Do not avoid overlapping effects just to make systems look different.** Spiritual Root, Bloodline, Physique, Traits, Techniques, Equipment, Destiny, buildings, professions and other systems may all affect the same output such as Công, Thủ, HP, tốc tu, đột phá, hồi phục, sản lượng or cost when that overlap is logical.
- Systems remain distinct through **source, acquisition, progression, constraints, tradeoffs, timing and signature rules**, not by forcing each system to own a unique stat.
- A rare/valuable mechanic must provide a meaningful advantage before optional flavor, comedy or drawback is considered. Do not let a gimmick replace the mechanic's core value.
- Tests for new systems should verify at least one real consequence path, and important/rare systems should generally verify multiple consequence axes where appropriate.
- Never call a phase PASS without its real cumulative Godot gate.
- Never weaken exact persistence/determinism tests just to make a gate pass.
- New phases must be opt-in when changing locked behavior.
- Hidden identity is generated once and persisted. Reveal never rerolls it.

## Runtime baseline

Real Windows + Godot 4.7.2 evidence confirms **P0 through P2.10 PASS**.

P2.9 and P2.10 are now LOCKED runtime-green baselines. Do not reopen P0-P2.10 without new regression evidence.

Active phase:

**P2.11 — Huyết Mạch + Thức Tỉnh + Độ Thuần**

Status: **IMPLEMENTED / AWAITING REAL GODOT 4.7.2 CUMULATIVE GATE**.

Authoritative launcher:

- `Sync-P2-11.cmd`

It reruns P0-P2.10 before the P2.11 diagnostic/contracts/scene smoke.

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

## Locked systems through P2.10

### P2.7 workforce

Keep sect rank, profession talent, profession XP, work group and combat/adventure role separate.

Authority order:

1. survival emergency;
2. direct Sect Master command;
3. schedule;
4. personal/group work priority;
5. normal autonomy.

Real loops:

- Mining -> Thanh Thiết;
- Forging -> support consumed by P2.6 craft.

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

Spiritual-root purity and root element count are separate axes.

### P2.9 traits

Visible positive/negative traits have real cultivation/work/combat consequences.

Latent traits are generated before reveal and reveal only from lived history. Empty visible list is a valid initialized result.

### P2.10 root refinement

Consumes real `Linh Tủy`.

Ordinary refinement:

- increases purity;
- preserves element list;
- has diminishing returns;
- receives Tiềm Lực contribution;
- changes real cultivation/breakthrough/matching-technique consequences.

Fewer elements specialize harder; more elements give broader compatibility.

Latent root mutation is pre-generated and reveal never rerolls it.

## Active P2.11 bloodline contract

Read:

- `docs/P2_11_BLOODLINE_SPEC.md`
- `docs/XIANXIA_FLAVOR_CANON.md`
- `CURRENT_CHECKPOINT.md`

Feature gate:

- `SectState.bloodlines_enabled`.

Profiles live in:

- `SectState.bloodline_profiles[character_id]`.

Schema:

- initialized;
- bloodline_id;
- purity;
- revealed;
- awakened;
- refinement_count.

Candidate -> disciple preserves the same profile because the id is unchanged. Rejected candidates remove orphan profiles.

Current bloodlines:

- Chân Long Huyết — Công + Thủ + tốc tu + đột phá + hồi phục nền;
- Phượng Hoàng Huyết — Công + Thủ nhẹ + tốc tu + đột phá nhẹ + hồi phục rất cao;
- Bạch Hổ Huyết — Công cao nhất + tốc tu nhỏ;
- Huyền Vũ Huyết — Thủ cao nhất + Công nền + tốc tu + hồi phục;
- Thao Thiết Tàn Huyết — Công + Thủ + tốc tu + hồi phục cao, extra real Supply cost on departure is only a tradeoff/flavor mechanic;
- no special bloodline is a valid common result.

Reveal uses pre-existing identity and life-history thresholds. Reveal must never awaken automatically.

Awakening:

- requires a revealed special bloodline;
- consumes one real P2.3 `Yêu Đan`;
- activates gameplay effects.

Post-awakening refinement:

- consumes one Yêu Đan;
- raises purity with diminishing returns;
- Tiềm Lực contributes;
- routine cap is 0.95;
- 100% is reserved for later major fate/inheritance mechanics.

## Xianxia humor/flavor contract

The game may be funny in a cultivation-story way, but it is not a meme game.

Allowed examples:

- khẩu nghiệp / gây chuyện;
- falsely believing oneself to be Thiên Mệnh Chi Tử;
- alchemy/forge explosions;
- fake/odd manuals and misunderstood opportunities;
- gluttony/greed/gossip;
- badly timed breakthroughs;
- excellent gear on a wildly unsuitable disciple.

Humor must come from real simulation causes and consequences.

P2.11 concrete example:

- awakened Thao Thiết Tàn Huyết consumes one extra real Supply when departing if stock exists, while already having meaningful combat/defense/cultivation/recovery advantages.

Do not spam joke text and do not use modern Internet memes as the main world voice.

## Current verification chain

Use:

- `tools/godot/Verify-P2-11.ps1`
- `Sync-P2-11.cmd`

It must prove cumulative P0-P2.10 regressions first, then P2.11 persistence, deterministic generation, no reroll, reveal, awakening resource cost, real combat/defense/cultivation/recovery/supply consequences, refinement, recruitment lifecycle and scene smoke.

Never claim P2.11 PASS without final real Godot 4.7.2 output.

## After P2.11 runtime green

Preferred order:

1. P2.12 Physique;
2. first visible living-sect map/building/disciple movement slice;
3. injury/medical;
4. loyalty + stipend/reward;
5. sect rank/authority expansion;
6. master-disciple/teaching;
7. Destiny/awakening;
8. active lifespan/aging/death/inheritance after pacing is proven.

Do not keep stacking backend identity systems forever before returning to visible gameplay.
