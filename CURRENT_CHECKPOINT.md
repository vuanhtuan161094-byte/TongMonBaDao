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

Authoritative P2.7 runtime evidence on 2026-10-01:

- P2.7 persistence diagnostic PASS;
- P2.7 disciple life + workforce contract test PASS;
- P2.7 workforce scene smoke PASS;
- final `P2.7 GATE: PASS`.

Do not reopen P0-P2.7 without new regression evidence.

## Active phase

**P2.8 — Disciple Generation V2 + Phẩm chất + Recruitment Sources**

Status: **IMPLEMENTED / AWAITING REAL GODOT 4.7.2 RUNTIME GATE**.

Do not call P2.8 PASS until `Sync-P2-8.cmd` reaches the final P2.8 gate successfully on the Windows machine.

## Core product direction

Primary operating rhythm remains **Evil Hunter Tycoon**:

- disciples autonomously live, cultivate, work, hunt, recover and consume;
- the player is the Sect Master and controls infrastructure, policy, production, assignment and strategic intervention;
- direct control is temporary/intentional, not mandatory routine micromanagement;
- the sect economy loops through expedition/work -> warehouse -> production -> disciple growth -> harder content.

Reference responsibilities:

- `最强祖师` -> multidimensional disciple identity, promotable quality, traits/quirks, production specialties, loyalty/injury/profile framing;
- `The Lost Village` -> work assignment, groups and work/cultivation/recovery schedule;
- `Amazing Cultivation Simulator` -> priority/schedule and later mentor/inner-disciple opportunity cost;
- `鬼谷八荒` -> sect rank, elders/halls and delegated authority;
- `Sect Master / 宗门经理人` -> expedition -> warehouse -> production -> build loop;
- `修仙家族模拟器` -> later bulk assignment, stipend/loyalty, lineage;
- RimWorld/ONI -> scalable roster priority/template management.

## Canonical disciple model

Normal disciples are deterministic procedural individuals, not hand-authored one by one.

Recruitment sources may include:

- ordinary recruitment;
- Chiêu Hiền / disciple gacha;
- Nhân Duyên / Cơ Duyên encounter;
- recommendation;
- world/story event.

All sources must use one identity generator. Source changes distribution/rules, not the character schema.

### Identity layers remain separate

1. innate foundation;
2. learned progression;
3. awakening/realization;
4. acquired world assets;
5. living state;
6. organization/social state.

Spiritual Root, Bloodline, Physique, Destiny, traits/quirks and personality are different semantic systems and must not be collapsed into one score/list.

## P2.8 implemented vertical slice

### Feature gate

P2.8 is opt-in through:

- `SectState.disciple_generation_v2_enabled`.

When false:

- legacy P1.2 recruitment behavior remains unchanged;
- legacy P2.2 spiritual-root behavior remains unchanged;
- P0-P2.7 serialized state does not gain P2.8-only keys;
- cumulative regression must stay green.

### Deterministic generator

Authority:

- `godot/src/simulation/recruitment/disciple_generator_v2.gd`.

Generation order:

1. profile seed + recruitment source;
2. name/race/sex/origin;
3. six permanent foundation dimensions;
4. derived disciple quality;
5. personality/biases;
6. spiritual-root purity + elements as separate axes;
7. profession talent/quirk subset;
8. latent future-identity seed;
9. age + base/max lifespan schema;
10. starting cultivation stage/progress;
11. derived intrinsic combat power.

A hidden/latent state is generated once. Future reveal must read stored state and never reroll it.

### Six permanent dimensions

Canonical internal values use `0.0..1.0`; UI may display `0..100`.

- `aptitude` — Tư Chất;
- `constitution` — Căn Cốt;
- `fortune` — Cơ Duyên;
- `comprehension` — Thông Tuệ (reuses P2.7 field; no duplicate stat);
- `charisma` — Mị Lực;
- `potential` — Tiềm Lực.

Active consequences in P2.8:

- Tư Chất changes real cultivation gain only while V2 is enabled;
- Thông Tuệ continues to affect P2.7 workforce learning/productivity;
- other dimensions are stored foundation until a real later mechanic exists.

Do not add fake modifiers only to make every stat look active.

### Phẩm chất

Working tiers:

1. Phàm Thường;
2. Xuất Chúng;
3. Thiên Kiêu;
4. Tuyệt Luân;
5. Nghịch Thiên.

Quality derives only from the six permanent foundation dimensions.

It does NOT directly count:

- current realm;
- combat power;
- equipment;
- sect rank;
- profession XP;
- temporary buffs/resources.

Quality is promotable by permanent-foundation growth through a recompute API.

Quality is not a universal value score: a lower-quality disciple can still be the better smith/miner/build because of profession talent, root compatibility and history.

### Spiritual Root V2 bridge

P2.8 separates:

- `spiritual_root_purity`;
- `spiritual_root_elements`.

Element count is no longer derived from purity/quality in V2.

For backward compatibility, purity is mapped into the existing P2.2 quality buckets so P2.2/P2.3 consequences continue to work without rewriting the locked systems.

Required runtime proof includes:

- same disciple quality can occur with different root-element counts;
- multi-element roots can still have good purity.

### Age/lifespan schema

P2.8 persists:

- `age`;
- `base_lifespan`;
- `max_lifespan`.

Death/aging ticks are NOT active yet.

Canonical future rule remains:

- major-realm breakthrough is the primary way to increase lifespan;
- longevity pills/treasures/inheritances may increase lifespan;
- severe forbidden techniques/injury/curses may later reduce lifespan;
- lifespan cannot be made infinite by endlessly spamming one cheap pill type.

### Recruitment sources active in P2.8

Three sources use the same generator:

- Ordinary Recruitment;
- Chiêu Hiền / gacha;
- Nhân Duyên / fate encounter.

Chiêu Hiền consumes the explicit sect resource:

- `disciple_recruitment_tokens`.

This resource is separate from P2.3 technique gacha/spirit stones.

### Candidate -> disciple identity lock

Acceptance must preserve generated identity exactly:

- profile seed/source;
- six dimensions;
- quality;
- root purity/elements;
- profession traits;
- age/lifespan;
- latent identity seed;
- starting realm/progress;
- intrinsic combat power.

P2.7 must not fill an empty V2 trait list after acceptance. Empty is a valid generated result.

### Combat-power order

P2.8 no longer treats combat power as the first random identity field.

Intrinsic power is derived from permanent foundation. Realm contribution remains in the existing P2.1 `cultivation_combat_bonus`, preventing realm power from being double-counted.

## P2.8 verification assets

- `godot/src/simulation/recruitment/disciple_generator_v2.gd`
- `godot/src/simulation/core/p2_8_factory.gd`
- `godot/tests/simulation/p2_8_persistence_diagnostic.gd`
- `godot/tests/simulation/p2_8_disciple_generation_test.gd`
- `godot/src/presentation/p2_8_disciple_generation.gd`
- `godot/scenes/p2/p2_8_disciple_generation.tscn`
- `tools/godot/Verify-P2-8.ps1`
- `Verify-P2-8.cmd`
- `Sync-P2-8.cmd`

Root launcher convention is restored: only the current P2.8 Sync/Verify pair should remain at repository root; historical verifiers remain under `tools/godot`.

## P2.8 gate must prove

1. P2.7 remains V2-disabled and legacy recruitment is unchanged.
2. Same seed/source/index produces exact same profile.
3. Three recruitment sources use the same schema.
4. Six foundation dimensions are valid/persistent.
5. Quality ignores temporary/current progression fields.
6. Permanent foundation can promote quality.
7. Lower quality can beat higher quality for a specific profession suitability.
8. Root purity and element count are independent.
9. Current combat power is derived after foundation and connected to P2.1 realm bonus.
10. Tư Chất changes real cultivation gain.
11. Chiêu Hiền consumes exactly one recruitment token.
12. Nhân Duyên creates a full procedural candidate.
13. Candidate acceptance preserves identity exactly.
14. Exact save/load + deterministic continuation pass.
15. P0-P2.7 cumulative regressions remain green.
16. P2.8 interaction scene launches headless.

## Explicitly deferred after P2.8

Do not expand these before P2.8 runtime is green:

1. full traits/quirks + reveal framework;
2. spiritual-root refinement/rare mutation;
3. bloodline;
4. physique;
5. injury/medical;
6. loyalty + stipend/reward;
7. sect rank/authority expansion;
8. master-disciple/teaching;
9. Destiny/awakening;
10. active aging/death/inheritance.

## Next authoritative local command

```bat
cd /d "E:\0.2. TongMonBaDao"
git pull origin main
Sync-P2-8.cmd
```

If it fails, fix the first failing gate only and rerun the same command. Never weaken persistence/determinism contracts to make the gate green.
