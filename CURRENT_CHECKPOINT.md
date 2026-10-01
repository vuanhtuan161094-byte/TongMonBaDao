# CURRENT CHECKPOINT

Date: 2026-10-01

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 cumulative evidence confirms:

- P0 Foundation: LOCKED / PASS.
- P1.1 Goal + Personality: LOCKED / PASS.
- P1.2 Recruitment + Player Choice: LOCKED / PASS.
- P1.3 Relationships + Behavioral Impact: LOCKED / PASS.
- P1.4 Consequential Memory: PASS.
- P1.5 Organization + Teams + Leadership + Combat Roles: PASS.
- P1.6 Sect Life + Needs + Resource Pressure: PASS.
- P2.1 Cultivation + Realms + Breakthrough: PASS.
- P2.2 Spiritual Root Quality + Long-Term Growth: PASS.
- P2.3 Technique Economy + Library + Mastery: PASS.
- P2.4 Cultivation Paths / Character Dao Direction: PASS.
- P2.5 Combat Skills / Real-time Auto Combat: PASS.
- P2.6 Forge + Equipment Tycoon: LOCKED / PASS.
- P2.7 Disciple Life + Workforce + Sect Assignment: LOCKED / PASS.
- P2.8 Disciple Generation V2 + Phẩm chất + Recruitment Sources: LOCKED / PASS.

Authoritative P2.8 runtime evidence on 2026-10-01:

- P2.8 persistence diagnostic PASS;
- P2.8 Disciple Generation V2 contract test PASS;
- P2.8 disciple identity scene smoke PASS;
- final `P2.8 GATE: PASS`.

Do not reopen P0-P2.8 without new regression evidence.

## Active phase

**P2.9 — Đặc Chất + Khuyết Điểm + Ẩn/Thức tỉnh**

Status: **IMPLEMENTED / AWAITING REAL GODOT 4.7.2 RUNTIME GATE**.

Do not call P2.9 PASS until `Sync-P2-9.cmd` reaches the final P2.9 gate successfully on the Windows machine.

## Core product direction

Primary operating rhythm remains **Evil Hunter Tycoon**:

- disciples autonomously live, cultivate, work, hunt, recover and consume;
- the player is the Sect Master and controls infrastructure, policy, production, assignment and strategic intervention;
- direct control is temporary/intentional, not mandatory routine micromanagement;
- the sect economy loops through expedition/work -> warehouse -> production -> disciple growth -> harder content.

Character depth is primarily informed by cultivation-management games such as `最强祖师`, while keeping the operating readability and autonomy of Evil Hunter Tycoon.

## Canonical disciple model

Ordinary disciples are deterministic procedural individuals, not hand-authored one by one.

Identity layers remain separate:

1. innate foundation;
2. learned progression;
3. awakening/realization;
4. acquired world assets;
5. living state;
6. organization/social state.

Do not collapse Spiritual Root, Bloodline, Physique, Destiny, traits/quirks and personality into one semantic system.

Hidden identity is generated once and persisted. Reveal never rerolls it.

## P2.8 locked identity contract

### Six foundation dimensions

Internal range: `0.0..1.0`; UI may show `0..100`.

- `aptitude` — Tư Chất;
- `constitution` — Căn Cốt;
- `fortune` — Cơ Duyên;
- `comprehension` — Thông Tuệ;
- `charisma` — Mị Lực;
- `potential` — Tiềm Lực.

Tư Chất has a real cultivation consequence. Thông Tuệ continues to affect P2.7 workforce learning/productivity.

### Phẩm chất

Promotable tiers:

1. Phàm Thường;
2. Xuất Chúng;
3. Thiên Kiêu;
4. Tuyệt Luân;
5. Nghịch Thiên.

Quality derives from permanent foundation only and does not directly count realm, equipment, sect rank, profession XP, combat power or temporary buffs.

### Recruitment sources

All use one deterministic generator:

- ordinary recruitment;
- Chiêu Hiền / gacha;
- Nhân Duyên / fate encounter.

Chiêu Hiền consumes `disciple_recruitment_tokens`, separate from P2.3 technique-gacha resources.

### Spiritual Root V2 bridge

P2.8 separates:

- spiritual-root purity;
- spiritual-root element list/count.

Element count is not derived rigidly from purity. Legacy P2.2 quality buckets remain as a compatibility bridge for existing cultivation/technique consequences.

### Age/lifespan schema

P2.8 persists:

- age;
- base lifespan;
- max lifespan.

Active aging/death is deferred. Future canon remains: major-realm breakthroughs are the main lifespan extension; pills/treasures can add lifespan; cheap repeated longevity pills cannot create infinite life.

## P2.9 implemented vertical slice

Read:

- `docs/P2_9_TRAITS_REVEAL_SPEC.md`
- `docs/DISCIPLE_GENERATION_CANON.md`
- `docs/DISCIPLE_LIFESPAN_CANON.md`

### Feature gate

`SectState.disciple_traits_enabled`.

When false:

- P0-P2.8 behavior remains unchanged;
- P2.8 save shape does not gain trait-profile keys;
- no trait modifier/reveal runs.

### Storage authority

Trait profiles live in:

- `SectState.disciple_trait_profiles` keyed by character id.

Candidate and accepted disciple keep the same id, so acceptance preserves the exact profile without copying/re-rolling.

Each profile stores:

- `initialized`;
- `visible`;
- `latent`;
- `revealed`.

An empty visible list is a valid initialized result and must never trigger a reroll.

### Visible trait slice

Positive:

- `steady_meridians` — Kinh Mạch Ổn Định: real cultivation gain bonus;
- `diligent_worker` — Cần Mẫn: real work speed/learning bonus;
- `fearless` — Gan Dạ: real combat-power bonus.

Negative:

- `fragile_meridians` — Kinh Mạch Yếu: real cultivation penalty;
- `careless_worker` — Cẩu Thả: real work-speed penalty;
- `timid` — Nhát Chiến: real combat-power penalty.

### Latent/reveal slice

Latent IDs are generated and persisted before reveal:

- `battle_instinct` — reveal after `combats >= 3`, then real combat bonus;
- `craftsman_eye` — reveal after `work_completions >= 2`, then work speed/learning bonus;
- `meditative_insight` — reveal after `cultivation_sessions >= 3`, then cultivation bonus.

Reveal only adds the pre-existing latent ID to `revealed`; it never changes the latent list.

### Runtime hooks

- `CultivationSystem.add_progress()` applies active cultivation traits.
- `CultivationSystem.effective_combat_power()` applies active combat traits, so P2.5 real combat receives the consequence.
- `WorkforceSystem.perform_work()` receives active work/learning trait multipliers.
- `SimulationScheduler` evaluates reveal thresholds after disciple activity ticks.
- `RecruitmentSystem` initializes future V2 candidates, preserves profiles on acceptance, and deletes rejected-candidate orphan profiles.

## P2.9 verification assets

- `godot/src/simulation/traits/trait_system.gd`
- `godot/src/simulation/core/p2_9_factory.gd`
- `godot/tests/simulation/p2_9_persistence_diagnostic.gd`
- `godot/tests/simulation/p2_9_traits_test.gd`
- `godot/src/presentation/p2_9_traits.gd`
- `godot/scenes/p2/p2_9_traits.tscn`
- `tools/godot/Verify-P2-9.ps1`
- `Verify-P2-9.cmd`
- `Sync-P2-9.cmd`

## P2.9 gate must prove

1. P2.8 remains trait-disabled and behavior-identical.
2. Same seed produces the same trait profile.
3. Empty visible trait list remains initialized and does not reroll.
4. Positive/negative cultivation traits measurably change real cultivation gain.
5. Positive/negative workforce traits measurably change real work speed/learning.
6. Positive/negative combat traits measurably change real effective combat power.
7. Hidden traits have no effect before reveal.
8. Reveal requires deterministic history thresholds.
9. Reveal does not change latent identity.
10. Candidate -> disciple acceptance preserves the same profile.
11. Candidate rejection removes its profile.
12. Exact save/load and deterministic continuation pass.
13. P0-P2.8 cumulative regressions remain green.
14. P2.9 scene smoke passes.

## After P2.9 runtime green

Planned dependency order:

1. spiritual-root refinement / rare mutation;
2. Bloodline;
3. Physique;
4. injury/medical;
5. loyalty + stipend/reward;
6. sect rank/authority expansion;
7. master-disciple/teaching;
8. Destiny/awakening;
9. active lifespan/aging/death/inheritance after pacing is proven.

Do not activate all of these at once.

## Next authoritative local command

```bat
cd /d "E:\0.2. TongMonBaDao"
git pull origin main
Sync-P2-9.cmd
```

If it fails, fix the first failing parse/test/diagnostic only and rerun the same cumulative command. Never weaken persistence/determinism contracts to make a gate green.
