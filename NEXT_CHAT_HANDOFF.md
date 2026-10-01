# NEXT CHAT HANDOFF — Tông Môn Bá Đạo

Date: 2026-10-01

Always inspect live `main` before editing.

## Runtime status

Real Windows + Godot 4.7.2 cumulative gate is green through **P2.8**.

Locked PASS chain:

- P0 Foundation
- P1.1 Goal + Personality
- P1.2 Recruitment + Player Choice
- P1.3 Relationships
- P1.4 Consequential Memory
- P1.5 Organization + Combat Roles
- P1.6 Needs + Resource Pressure
- P2.1 Cultivation
- P2.2 Spiritual Roots
- P2.3 Technique Economy
- P2.4 Cultivation Paths
- P2.5 Realtime Combat + Independent Skills
- P2.6 Forge + Equipment Tycoon
- P2.7 Disciple Life + Workforce + Sect Assignment
- P2.8 Disciple Generation V2 + Phẩm chất + Recruitment Sources

Authoritative user runtime evidence on 2026-10-01 ended with:

`P2.8 GATE: PASS`

Do not reopen P0-P2.8 without new regression evidence.

## Active phase

**P2.9 — Đặc Chất + Khuyết Điểm + Ẩn/Thức tỉnh**

Status: **IMPLEMENTED / AWAITING REAL GODOT 4.7.2 RUNTIME GATE**.

Never call it PASS before the user provides a successful `Sync-P2-9.cmd` run.

## Read first

1. `AGENTS.md`
2. `CURRENT_CHECKPOINT.md`
3. `docs/DISCIPLE_GENERATION_CANON.md`
4. `docs/DISCIPLE_LIFESPAN_CANON.md`
5. `docs/P1_P2_6_CANON_AUDIT.md`
6. `docs/P2_8_DISCIPLE_GENERATION_V2_SPEC.md`
7. `docs/P2_9_TRAITS_REVEAL_SPEC.md`
8. this file

## Core game identity

Primary operating rhythm is **Evil Hunter Tycoon** but individual disciples are much deeper.

The player is Tông Chủ. Disciples autonomously live, cultivate, work, hunt, recover, spend and form relationships. The player manages infrastructure, policy, production, assignment, recruitment, investment and direct intervention when needed.

Large rosters must not require mandatory one-by-one micromanagement.

## Locked disciple-generation canon from P2.8

Normal disciples are deterministic procedural individuals.

One V2 identity contains:

- seeded profile/source;
- race/sex/origin;
- six permanent dimensions;
- promotable quality;
- personality/biases;
- spiritual-root purity + independent element list;
- profession talent subset;
- latent future identity seed;
- age/base/max lifespan schema;
- starting cultivation stage/progress;
- intrinsic combat power derived after identity.

Six dimensions:

- aptitude — Tư Chất;
- constitution — Căn Cốt;
- fortune — Cơ Duyên;
- comprehension — Thông Tuệ;
- charisma — Mị Lực;
- potential — Tiềm Lực.

Quality tiers:

- Phàm Thường
- Xuất Chúng
- Thiên Kiêu
- Tuyệt Luân
- Nghịch Thiên

Quality derives from permanent foundation only. It ignores current realm, gear, combat power, sect rank, profession XP and temporary buffs.

Recruitment sources share one generator:

- ordinary;
- Chiêu Hiền / gacha;
- Nhân Duyên / fate.

Candidate -> disciple acceptance must preserve identity exactly.

## P2.9 architecture

### Main files

- `godot/src/simulation/traits/trait_system.gd`
- `godot/src/simulation/core/p2_9_factory.gd`
- `godot/src/simulation/state/sect_state.gd`
- `godot/src/simulation/recruitment/recruitment_system.gd`
- `godot/src/simulation/cultivation/cultivation_system.gd`
- `godot/src/simulation/workforce/workforce_system.gd`
- `godot/src/simulation/core/simulation_scheduler.gd`
- `godot/tests/simulation/p2_9_persistence_diagnostic.gd`
- `godot/tests/simulation/p2_9_traits_test.gd`
- `godot/src/presentation/p2_9_traits.gd`
- `godot/scenes/p2/p2_9_traits.tscn`
- `tools/godot/Verify-P2-9.ps1`
- `Verify-P2-9.cmd`
- `Sync-P2-9.cmd`

### Feature gate

`SectState.disciple_traits_enabled`

When false, P0-P2.8 behavior/save shape remains unchanged.

### Trait storage

Profiles are stored in `SectState.disciple_trait_profiles` keyed by character id.

Profile schema:

- `initialized`
- `visible`
- `latent`
- `revealed`

Candidate and accepted disciple keep the same id, therefore acceptance preserves profile identity without rerolling.

An empty visible list is a valid initialized result.

### Visible traits with real consequences

Positive:

- `steady_meridians` — Kinh Mạch Ổn Định: cultivation bonus;
- `diligent_worker` — Cần Mẫn: work speed + profession learning bonus;
- `fearless` — Gan Dạ: combat-power bonus.

Negative:

- `fragile_meridians` — Kinh Mạch Yếu: cultivation penalty;
- `careless_worker` — Cẩu Thả: work-speed penalty;
- `timid` — Nhát Chiến: combat-power penalty.

### Latent traits

Pre-generated latent IDs:

- `battle_instinct` — reveal at 3 combats, then combat bonus;
- `craftsman_eye` — reveal at 2 work completions, then work/learning bonus;
- `meditative_insight` — reveal at 3 cultivation sessions, then cultivation bonus.

Reveal never changes the latent list. It only adds an already-existing latent ID to `revealed`.

### Runtime consequences

- `CultivationSystem.add_progress()` reads cultivation traits.
- `CultivationSystem.effective_combat_power()` reads combat traits; P2.5 real combat therefore receives the effect.
- `WorkforceSystem.perform_work()` uses work speed/learning trait multipliers.
- `SimulationScheduler` checks reveal conditions after activity ticks.
- `RecruitmentSystem` initializes new V2 candidate profiles, preserves them on acceptance and removes rejected-candidate profiles.

## P2.9 gate intent

Must prove:

- P2.8 stays traits-disabled;
- same seed -> same profile;
- empty visible profile does not reroll;
- positive/negative cultivation traits change real gain;
- positive/negative work traits change real work consequence;
- positive/negative combat traits change effective power;
- hidden traits do nothing before reveal;
- reveal requires deterministic activity history;
- latent identity does not change on reveal;
- candidate acceptance preserves profile;
- rejection removes orphan profile;
- exact persistence + deterministic continuation;
- cumulative P0-P2.8 regression;
- P2.9 scene smoke.

## Next command for user

```bat
cd /d "E:\0.2. TongMonBaDao"
git pull origin main
Sync-P2-9.cmd
```

If it fails, fix the first real parser error / first P2.9 diagnostic or assertion. Do not react to later dependency-cascade compile errors first.

## After P2.9 runtime green

Next dependency order:

1. spiritual-root refinement / rare mutation;
2. Bloodline;
3. Physique;
4. injury/medical;
5. loyalty + stipend/reward;
6. sect rank/authority expansion;
7. master-disciple/teaching;
8. Destiny/awakening;
9. active lifespan/aging/death/inheritance after pacing is proven.
