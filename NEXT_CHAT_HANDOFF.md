# NEXT CHAT HANDOFF — Tông Môn Bá Đạo

Date: 2026-10-01

Always inspect live `main` before editing.

## Runtime status

Real Windows + Godot 4.7.2 cumulative gate is green through P2.6:

- P0-P1.6: PASS
- P2.1 Cultivation: PASS
- P2.2 Spiritual Roots: PASS
- P2.3 Technique Economy: PASS
- P2.4 Cultivation Paths: PASS
- P2.5 Realtime Combat + Independent Skills: PASS
- P2.6 Forge + Equipment Tycoon: LOCKED / PASS

P2.7 is now **IMPLEMENTED / AWAITING RUNTIME GATE**.

Do not call P2.7 PASS until the real local cumulative gate succeeds.

## Read first

1. `AGENTS.md`
2. `CURRENT_CHECKPOINT.md`
3. `docs/GAMEPLAY_REFERENCE_SYNTHESIS.md`
4. `docs/DISCIPLE_SYSTEM_DEEP_RESEARCH.md`
5. `docs/DISCIPLE_SYSTEM_LATEST_SOURCE_ADDENDUM_2026-10-01.md`
6. `docs/DISCIPLE_GENERATION_CANON.md`
7. `docs/P2_7_DISCIPLE_LIFE_WORKFORCE_SPEC.md`
8. this file

`docs/DISCIPLE_GENERATION_CANON.md` is the authoritative source for future random/procedural disciple identity. It supersedes older discussion that rejected disciple quality or gacha outright.

## Core game identity

Primary operating rhythm: **Evil Hunter Tycoon**.

The player is the Sect Master. Disciples should autonomously live, cultivate, work, hunt, recover, buy/use equipment and form stories. The player manages infrastructure, policy, production, assignments and preparation and may directly command a specific disciple when needed.

Routine micromanagement must remain optional.

Reference responsibilities:

- `最强祖师` -> multidimensional disciple identity, quality progression, traits/quirks, production professions, loyalty/injury and profile framing;
- `The Lost Village` -> work priorities, groups and work/cultivation/recovery schedule;
- `Amazing Cultivation Simulator` -> work priorities, schedule and later mentor/inner-disciple opportunity cost;
- `鬼谷八荒` -> later sect rank/delegation/hall authority;
- `Sect Master / 宗门经理人` -> expedition -> warehouse -> production -> disciple growth loop;
- `修仙家族模拟器` -> later rule-based bulk assignment, stipend/loyalty and lineage ideas;
- RimWorld/ONI -> scalable priority/template management.

## Canonical future disciple generation

Normal disciples are not hand-authored one by one. They are deterministic procedural individuals generated from a seeded pipeline.

Recruitment source can be:

- ordinary recruitment;
- Chiêu Hiền / gacha;
- Nhân Duyên / Cơ Duyên encounter;
- recommendation;
- world/story event.

One generator handles all sources; source/context changes distributions, guarantees and starting background.

### Generation layers

A generated disciple separates:

1. **Innate foundation** — race, sex, six base dimensions, spiritual roots, latent/visible bloodline, latent/visible physique, core personality, innate traits, possible destiny;
2. **Learned progression** — realm, body cultivation, technique mastery, Sword/Body/Spell path XP, combat skills, profession XP;
3. **Awakening/realization** — hidden bloodline/physique/destiny reveal, rare mutations, comprehension breakthroughs, Dao/intent later;
4. **Acquired world assets** — equipment, artifacts, manuals, pills, inheritances, treasures;
5. **Living state** — HP/stamina/injury/loyalty/mood/location/current work/direct order;
6. **Organization/social state** — sect rank, work group, combat team/role, relationships, later master-disciple.

### Six base dimensions

Canonical meaning:

- Tư Chất -> normal cultivation efficiency;
- Căn Cốt -> body cultivation/physical potential;
- Cơ Duyên -> event/opportunity fortune;
- Thông Tuệ -> learning/profession/understanding speed;
- Mị Lực -> social/recruitment/diplomacy effects later;
- Tiềm Lực -> long-term permanent growth ceiling.

P2.7 `comprehension` is currently the operational subset corresponding to Thông Tuệ.

### Disciple quality is mandatory and promotable

Working tiers:

- Phàm Thường;
- Xuất Chúng;
- Thiên Kiêu;
- Tuyệt Luân;
- Nghịch Thiên.

Quality summarizes permanent foundation/potential for quick roster/gacha reading and can be promoted through permanent foundation growth.

Quality does NOT directly include equipment, temporary buffs, current sect rank, current realm or profession XP.

Quality must never be the only value judgment. A lower-quality disciple can be uniquely valuable because of bloodline, physique, destiny, spiritual roots, profession talent, personality or history.

### Bloodline / Physique / Spiritual Root / Destiny / Trait are separate

- Bloodline = inherited lineage + purity/awakening;
- Physique = body configuration, innate or transformed;
- Spiritual Root = elemental cultivation compatibility/purity;
- Destiny = rare rule-changing identity/awakening progression;
- traits/quirks = smaller positive/negative consequences;
- personality = AI behavioral tendencies.

Do not collapse these into one semantic list.

### Innate does not mean permanently frozen

- ordinary training increases learned systems;
- innate systems change only through rare transformation/refinement/awakening;
- hidden systems are generated at creation and reveal later without rerolling;
- quality can rise when permanent foundation crosses a new threshold.

### Profession rule

Profession talent and profession mastery are different:

- talent = innate/trait;
- profession XP/level = learned by actually working.

A natural-born forging genius may still start at forging level 0.

## P2.7 architecture implemented

P2.7 adds a separate workforce authority layer. Do not merge it into P1.5 `role_assignments`.

Distinct concepts:

1. `sect_rank` — sect status schema;
2. `profession_xp` / workforce specialization;
3. `work_group_id` / production group;
4. P1.5 combat/adventure team and role.

A disciple can be `Outer + Forging specialist + Forge Hall worker + Hunt-team member` simultaneously.

## P2.7 runtime state

Per disciple:

- comprehension;
- profession XP;
- profession traits;
- personal work priorities;
- work group;
- work progress;
- direct Sect Master command;
- sect-rank schema.

Sect:

- workforce feature flag;
- work policy;
- work groups;
- forge support points;
- workforce event count.

Persistence is canonicalized in `DiscipleState` and `SectState` and uses SaveService v2 lossless floats.

## P2.7 authority order

Current runtime arbitration:

1. survival emergency;
2. direct Sect Master command;
3. schedule phase;
4. personal/group work priority;
5. existing GoalSystem/DecisionSystem autonomy.

Mandatory event duty is deferred.

## P2.7 schedule

Deterministic 20-tick cycle with work/cultivation/recovery phases.

Policies:

- balanced;
- production_push;
- cultivation_focus.

This deliberately prevents an assigned worker from working forever and never cultivating/recovering.

## P2.7 direct commands

Persistent deterministic commands:

- WORK_PROFESSION;
- CULTIVATE;
- HUNT_REGION;
- RETURN_SECT;
- REST;
- HOLD_AT_SECT.

Commands have issued/expiry ticks and target. Completed/expired commands return the disciple to autonomy.

## P2.7 real profession loops

Only two professions have active gameplay in the vertical slice.

### Mining

- produces real Thanh Thiết into P2.6 `forge_materials`;
- raises mining XP;
- profession level/comprehension/traits change work speed;
- experienced miner can produce more yield than novice.

### Forging

- raises forging XP;
- produces `forge_support_points`;
- when workforce is enabled, `EquipmentSystem.craft()` consumes one point for +5% stat multiplier on the next real P2.6 craft;
- P2.6 behavior is unchanged while workforce is disabled.

## Recruitment update

P2.7 candidates currently receive deterministic:

- comprehension;
- 0-2 profession traits.

This is only an interim subset of the future procedural generator described in `docs/DISCIPLE_GENERATION_CANON.md`.

## Files

- `godot/src/simulation/workforce/workforce_system.gd`
- `godot/src/simulation/core/p2_7_factory.gd`
- `godot/src/simulation/state/disciple_state.gd`
- `godot/src/simulation/state/candidate_state.gd`
- `godot/src/simulation/state/sect_state.gd`
- `godot/src/simulation/recruitment/recruitment_system.gd`
- `godot/src/simulation/core/simulation_scheduler.gd`
- `godot/src/simulation/equipment/equipment_system.gd`
- `godot/tests/simulation/p2_7_persistence_diagnostic.gd`
- `godot/tests/simulation/p2_7_workforce_test.gd`
- `godot/src/presentation/p2_7_workforce.gd`
- `godot/scenes/p2/p2_7_workforce.tscn`
- `tools/godot/Verify-P2-7.ps1`
- `Verify-P2-7.cmd`
- `Sync-P2-7.cmd`

## P2.7 gate intent

The gate must prove:

- P2.6 stays workforce-disabled;
- same seed gives same workforce profiles;
- mining produces real Thanh Thiết;
- work raises profession XP;
- experienced miner outperforms novice;
- schedule contains work/cultivation/recovery;
- direct Tông Chủ command overrides then releases control;
- forging support changes a real P2.6 craft;
- recruitment has deterministic non-combat aptitude;
- exact save/load and continuation remain deterministic;
- prior gates and invariants remain green;
- P2.7 scene smoke passes.

## Authoritative next command

```bat
cd /d "E:\0.2. TongMonBaDao"
git pull origin main
Sync-P2-7.cmd
```

If it fails, fix the first failing gate and rerun the same cumulative command. Do not weaken exact tests.

## Root launcher note

The new P2.7 root launchers exist. An attempted GitHub deletion of the old P2.6 root launcher pair was blocked by the tool safety layer, so do not assume the old pair is absent until verified/cleaned safely. The P2.7 pair is the authoritative pair going forward.

## After P2.7 runtime green

Next architecture priority is no longer "add random jobs". It is:

1. procedural disciple generator v2;
2. six base dimensions + promotable disciple quality;
3. multiple recruitment sources including ordinary recruitment + gacha + fate encounters;
4. traits/quirks + hidden reveal framework;
5. spiritual-root refinement on P2.2;
6. bloodline + physique;
7. injury/medical;
8. loyalty/stipend/rewards;
9. sect rank/authority;
10. master-disciple/teaching;
11. rare destiny/awakening systems;
12. lifespan/death/inheritance only after pacing is proven.
