# CURRENT CHECKPOINT

Date: 2026-10-01

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 cumulative evidence confirms **P0 through P2.10 PASS**.

Locked chain:

- P0 Foundation: LOCKED / PASS.
- P1.1 Goal + Personality: LOCKED / PASS.
- P1.2 Recruitment + Player Choice: LOCKED / PASS.
- P1.3 Relationships + Behavioral Impact: LOCKED / PASS.
- P1.4 Consequential Memory: PASS.
- P1.5 Organization + Teams + Leadership + Combat Roles: PASS.
- P1.6 Sect Life + Needs + Resource Pressure: PASS.
- P2.1 Cultivation + Realms + Breakthrough: PASS.
- P2.2 Spiritual Roots: PASS.
- P2.3 Technique Economy + Library + Mastery: PASS.
- P2.4 Cultivation Paths: PASS.
- P2.5 Realtime Combat + Independent Skills: PASS.
- P2.6 Forge + Equipment Tycoon: LOCKED / PASS.
- P2.7 Disciple Life + Workforce + Sect Assignment: LOCKED / PASS.
- P2.8 Disciple Generation V2 + Phẩm chất + Recruitment Sources: LOCKED / PASS.
- P2.9 Traits + Quirks + Hidden Reveal: LOCKED / PASS.
- P2.10 Spiritual Root Refinement + Mutation: LOCKED / PASS.

Authoritative user runtime evidence on 2026-10-01 included:

- `P2.9 TRAITS + HIDDEN REVEAL GATE: PASS`
- `P2.10 PERSISTENCE DIAGNOSTIC PASS: immediate canonical state identical`
- `P2.10 SPIRITUAL ROOT REFINEMENT + MUTATION TEST PASS`
- `P2.10 SPIRITUAL ROOT REFINEMENT + MUTATION GATE: PASS`
- final `P2.10 GATE: PASS`

Do not reopen P0-P2.10 without new regression evidence.

## Active phase

**P2.11 — Huyết Mạch + Thức Tỉnh + Độ Thuần**

Status: **IMPLEMENTED / AWAITING REAL GODOT 4.7.2 CUMULATIVE GATE**.

Never call P2.11 PASS until `Sync-P2-11.cmd` reaches the final gate on the Windows machine.

Read:

- `docs/P2_11_BLOODLINE_SPEC.md`
- `docs/XIANXIA_FLAVOR_CANON.md`
- `docs/DISCIPLE_GENERATION_CANON.md`
- `docs/P2_10_SPIRITUAL_ROOT_REFINEMENT_SPEC.md`

## Core game identity

The player is the **Tông Chủ**. Disciples are autonomous people, not puppets.

Primary operating rhythm remains Evil Hunter Tycoon-like:

`hunt/work -> warehouse -> production/investment -> disciple growth -> harder content`

Character depth is much greater: procedural identity, quality, roots, traits, bloodline, later physique/destiny, profession mastery, relationships, health, loyalty, age/lifespan and organization state.

Routine one-by-one micromanagement must remain optional at scale.

## Canonical disciple rules already locked

### P2.8 identity

Six permanent foundation dimensions:

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

Recruitment sources share one deterministic generator:

- ordinary;
- Chiêu Hiền / gacha;
- Nhân Duyên / fate.

Hidden identity is generated once and persisted. Reveal never rerolls it.

### P2.9 traits

Visible positive/negative traits have real cultivation/work/combat consequences.

Latent traits are generated before reveal and reveal only after lived-history thresholds.

Empty visible list is a valid initialized result and never a reroll trigger.

### P2.10 roots

Spiritual-root purity and element count are independent.

Ordinary refinement:

- consumes real `Linh Tủy`;
- increases purity;
- preserves element list;
- has diminishing returns;
- can cross compatibility quality buckets;
- changes real cultivation, breakthrough and matching-technique consequences.

Fewer elements specialize harder; more elements give broader compatibility.

Latent root mutation is generated before reveal and cannot reroll at reveal time.

## P2.11 implemented contract

Feature gate:

- `SectState.bloodlines_enabled`.

Storage authority:

- `SectState.bloodline_profiles[character_id]`.

Profile schema:

- `initialized`;
- `bloodline_id`;
- `purity`;
- `revealed`;
- `awakened`;
- `refinement_count`.

Candidate and accepted disciple keep the same character id, so profile identity is preserved. Rejected candidates remove orphan bloodline state.

### Bloodline core-stat rule — canonical

A special awakened bloodline must be innately strong before its special gimmick/tradeoff is considered.

Every special bloodline in the current slice must have:

1. at least one direct **Công or Thủ** advantage;
2. at least two real beneficial axes among Công / Thủ / Tu luyện / Đột phá / Hồi phục;
3. bonuses that scale upward with bloodline purity;
4. signature mechanics layered on top rather than replacing real stats.

Do not reduce a bloodline to flavor such as “eats more”, “rests faster”, or a single novelty modifier.

### Bloodlines in the vertical slice

- `true_dragon` — **Chân Long Huyết**: Công + Thủ + tốc tu + đột phá + hồi phục nền. Generalist high-grade lineage.
- `phoenix` — **Phượng Hoàng Huyết**: Công + Thủ nhẹ + tốc tu + đột phá nhẹ + hồi phục rất cao. Not merely a healing passive.
- `white_tiger` — **Bạch Hổ Huyết**: Công cao nhất + tốc tu nhỏ. Pure slaughter/offense identity.
- `black_tortoise` — **Huyền Vũ Huyết**: Thủ cao nhất + Công nền + tốc tu + hồi phục. Not merely one damage-reduction passive.
- `taotie_remnant` — **Thao Thiết Tàn Huyết**: Công + Thủ + tốc tu + hồi phục cao; consumes one extra real Supply on departure as a tradeoff/humor mechanic.
- `none` is a valid and common result.

Current runtime formulas live in `BloodlineSystem`; `stat_profile()` exposes player-facing values for UI/tests.

### Reveal

Bloodline identity/purity exists before reveal.

Current lived-history reveal thresholds:

- Chân Long: 3 combats;
- Phượng Hoàng: at least 1 defeat + 1 rest;
- Bạch Hổ: 3 wins;
- Huyền Vũ: 2 retreats;
- Thao Thiết: 3 rests.

Some special bloodlines may already be detected at recruitment depending on deterministic source/seed distribution.

### Awakening and refinement

Awakening requires:

- special bloodline;
- revealed profile;
- one real `Yêu Đan` from the existing P2.3 material economy.

Effects activate only after awakening.

Post-awakening bloodline refinement:

- consumes one Yêu Đan per attempt;
- increases purity;
- uses Tiềm Lực;
- has diminishing returns;
- current normal cap 0.95;
- absolute 100% remains reserved for later major fate/inheritance mechanics;
- higher purity must strengthen real core stats, not only the displayed purity number.

### Current real consequence hooks

- `CultivationSystem.effective_combat_power()` reads bloodline Công.
- `CombatSystem` incoming-damage calculation reads bloodline Thủ.
- `CultivationSystem.add_progress()` reads bloodline cultivation multiplier.
- `CultivationSystem.breakthrough_success_chance()` reads bloodline breakthrough bonus.
- `NeedsSystem.apply_rest()` reads bloodline recovery multiplier.
- `NeedsSystem.prepare_departure()` applies Thao Thiết extra Supply tradeoff.

## Xianxia flavor/humor canon

Read `docs/XIANXIA_FLAVOR_CANON.md`.

The game may include familiar cultivation-story humor such as:

- khẩu nghiệp / thích gây chuyện;
- tự nhận mình là Thiên Mệnh Chi Tử without actually having Destiny;
- luyện đan/luyện khí nổ lò;
- nhặt nhầm bí kíp / hiểu nhầm cơ duyên;
- tham ăn / tham tài / hóng chuyện;
- đột phá sai thời điểm;
- đồ cực phẩm vào tay người dùng không hợp.

Humor must come from real simulation causes/consequences, not standalone meme text.

P2.11 first concrete humorous mechanic:

- awakened Thao Thiết Tàn Huyết consumes an extra real Supply on departure, but it already has meaningful Công/Thủ/Tu luyện/Hồi phục advantages. The appetite is a tradeoff, not the bloodline's whole identity.

## P2.11 verification assets

- `godot/src/simulation/bloodline/bloodline_system.gd`
- `godot/src/simulation/core/p2_11_factory.gd`
- `godot/tests/simulation/p2_11_persistence_diagnostic.gd`
- `godot/tests/simulation/p2_11_bloodline_test.gd`
- `godot/src/presentation/p2_11_bloodline.gd`
- `godot/scenes/p2/p2_11_bloodline.tscn`
- `tools/godot/Verify-P2-11.ps1`
- `Verify-P2-11.cmd`
- `Sync-P2-11.cmd`

P2.11 verifier reruns P0-P2.10 first and must prove persistence, deterministic profiles, no reroll, reveal, awakening resource cost, core stat advantages, combat/breakthrough/defense/cultivation/recovery/supply consequences, refinement, recruitment lifecycle and scene smoke.

## Next authoritative local command

```bat
cd /d "E:\0.2. TongMonBaDao"
git pull origin main
Sync-P2-11.cmd
```

If it fails, fix the first real parser/diagnostic/assertion failure only, then rerun the same command.

## Planned order after P2.11 runtime green

1. P2.12 Physique — bẩm sinh/cải tạo, advantages + drawbacks;
2. then pause backend identity expansion and build the first **visible living sect** slice: map + buildings + disciples moving to real work/rest/cultivation destinations;
3. injury/medical;
4. loyalty + stipend/reward;
5. sect rank/authority expansion;
6. master-disciple/teaching;
7. Destiny/awakening;
8. active age/lifespan/death/inheritance after pacing is proven.

Do not activate all layers at once.
