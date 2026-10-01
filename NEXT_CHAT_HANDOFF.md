# NEXT CHAT HANDOFF — Tông Môn Bá Đạo

Date: 2026-10-01

Always inspect live `main` before editing.

## Runtime status

Real Windows + Godot 4.7.2 cumulative gate is green through **P2.7**.

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

Authoritative P2.7 user runtime log on 2026-10-01 ended with:

`P2.7 GATE: PASS`

Do not reopen P0-P2.7 without new regression evidence.

## Active phase

**P2.8 — Disciple Generation V2 + Phẩm chất + Recruitment Sources**

Status: **IMPLEMENTED / AWAITING REAL GODOT 4.7.2 RUNTIME GATE**.

Never call it PASS before the user provides a successful `Sync-P2-8.cmd` run.

## Read first

1. `AGENTS.md`
2. `CURRENT_CHECKPOINT.md`
3. `docs/DISCIPLE_GENERATION_CANON.md`
4. `docs/DISCIPLE_LIFESPAN_CANON.md`
5. `docs/P1_P2_6_CANON_AUDIT.md`
6. `docs/P2_8_DISCIPLE_GENERATION_V2_SPEC.md`
7. this file

## Core game identity

Primary rhythm is **Evil Hunter Tycoon**, but individual disciples are deeper.

The player is Tông Chủ. Disciples autonomously live, cultivate, work, hunt, recover, spend and build relationships. The player controls infrastructure, policy, assignment, investment and direct intervention when needed.

Do not turn large rosters into mandatory one-by-one micromanagement.

Reference responsibilities:

- `最强祖师` — disciple depth, promotable quality, production value, traits, loyalty/injury/profile ideas;
- `The Lost Village` — work/group/schedule;
- `Amazing Cultivation Simulator` — priority/schedule and later mentor opportunity cost;
- `鬼谷八荒` — rank/halls/delegation;
- `Sect Master / 宗门经理人` — expedition -> warehouse -> production loop;
- `修仙家族模拟器` — bulk rules, stipends/loyalty, lineage;
- RimWorld/ONI — scalable roster management.

## P2.7 locked workforce authority

Keep separate:

- sect rank;
- profession mastery;
- innate profession talent;
- work group;
- combat/adventure team and role.

Current real work loops:

- Mining -> real Thanh Thiết;
- Forging -> real support point consumed by P2.6 craft.

Authority order:

1. emergency;
2. direct Tông Chủ command;
3. schedule;
4. work/group priorities;
5. normal AI autonomy.

## P2.8 implementation

### Main files

- `godot/src/simulation/recruitment/disciple_generator_v2.gd`
- `godot/src/simulation/core/p2_8_factory.gd`
- `godot/src/simulation/state/candidate_state.gd`
- `godot/src/simulation/state/disciple_state.gd`
- `godot/src/simulation/state/sect_state.gd`
- `godot/src/simulation/recruitment/recruitment_system.gd`
- `godot/src/simulation/cultivation/cultivation_system.gd`
- `godot/tests/simulation/p2_8_persistence_diagnostic.gd`
- `godot/tests/simulation/p2_8_disciple_generation_test.gd`
- `godot/src/presentation/p2_8_disciple_generation.gd`
- `godot/scenes/p2/p2_8_disciple_generation.tscn`
- `tools/godot/Verify-P2-8.ps1`
- `Verify-P2-8.cmd`
- `Sync-P2-8.cmd`

### Feature gate

`SectState.disciple_generation_v2_enabled`

When false, legacy P1.2/P2.2/P2.7 behavior and serialized shape must remain unchanged.

### Generator order

1. source + profile seed;
2. identity basics;
3. six permanent foundation dimensions;
4. derived quality;
5. personality/biases;
6. root purity + element list as separate axes;
7. profession traits;
8. latent future identity seed;
9. age/lifespan schema;
10. starting realm/progress;
11. derived intrinsic combat power.

### Six dimensions

Internal `0..1`, UI can show `0..100`:

- aptitude — Tư Chất;
- constitution — Căn Cốt;
- fortune — Cơ Duyên;
- comprehension — Thông Tuệ;
- charisma — Mị Lực;
- potential — Tiềm Lực.

`comprehension` reuses P2.7 field.

Active consequences now:

- aptitude -> real cultivation gain;
- comprehension -> existing workforce learning/productivity.

Do not invent fake consequences for the rest yet.

### Quality

Tiers:

- Phàm Thường
- Xuất Chúng
- Thiên Kiêu
- Tuyệt Luân
- Nghịch Thiên

Quality derives only from six permanent dimensions.

It can be promoted when permanent foundation grows.

It must ignore current realm, gear, combat power, sect rank, profession XP and temporary buffs.

A lower-quality specialist can be more useful than a higher-quality generalist in a specific role.

### Roots

V2 separates:

- `spiritual_root_purity`
- `spiritual_root_elements`

Element count is independent from purity/quality.

Purity maps into legacy P2.2 quality buckets only for compatibility with locked P2.2/P2.3 consequence code.

### Recruitment sources

All use one generator:

- ordinary;
- gacha / Chiêu Hiền;
- fate / Nhân Duyên.

Chiêu Hiền consumes `disciple_recruitment_tokens`, separate from P2.3 technique resources.

### Acceptance identity lock

Candidate -> disciple must preserve all generated identity.

Important fix already made: P2.7 workforce does **not** reroll traits when a V2 disciple legitimately generated with an empty trait list.

### Age/lifespan

P2.8 stores age/base lifespan/max lifespan only.

Active aging/death is deferred.

Future canon remains: major-realm breakthrough increases lifespan; longevity pills/treasures may add lifespan; repeated same cheap pill cannot grant infinite life.

## P2.8 runtime gate intent

Verifier must prove:

- P2.7 legacy gate stays unchanged;
- same seed/source/index is exact;
- three recruitment sources share schema;
- six dimensions persist;
- quality promotion and exclusions are correct;
- specific specialist value can beat quality;
- root purity/count independence;
- combat power derived after foundation;
- Tư Chất affects cultivation;
- gacha resource consumption;
- acceptance identity preservation;
- exact save/load + deterministic continuation;
- full P0-P2.7 regression;
- scene smoke.

## Root launcher convention

Only current root pair should remain:

- `Sync-P2-8.cmd`
- `Verify-P2-8.cmd`

Historical phase scripts remain under `tools/godot`.

## Next command for user

```bat
cd /d "E:\0.2. TongMonBaDao"
git pull origin main
Sync-P2-8.cmd
```

If it fails, use the **first real SCRIPT ERROR / first failing P2.8 assertion**. Later compile failures are usually dependency cascades.

## After P2.8 runtime green

Next likely order:

1. traits/quirks + hidden reveal framework;
2. spiritual-root refinement/mutation;
3. Bloodline + Physique foundation;
4. injury/medical;
5. loyalty + stipend/reward;
6. expanded sect rank/authority;
7. master-disciple/teaching;
8. Destiny/awakening;
9. active aging/death/inheritance.

Do not build the whole stack before P2.8 is runtime-green.
