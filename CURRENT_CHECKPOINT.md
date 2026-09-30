# CURRENT CHECKPOINT

Date: 2026-09-30

## Project state

- P0 Foundation: LOCKED / PASS.
- P1.1 Goal + Personality: LOCKED / PASS.
- P1.2 Recruitment + Player Choice: LOCKED / PASS.
- P1.3 Relationships + Behavioral Impact: LOCKED / PASS.
- P1.4 Consequential Memory: IMPLEMENTED / AWAITING RUNTIME GATE.
- P1.5 Organization + Teams + Leadership + Roles: IMPLEMENTED / AWAITING RUNTIME GATE.
- P1.6 Sect Life + Needs + Resource Pressure: IMPLEMENTED / AWAITING RUNTIME GATE.
- P2.1 Cultivation + Realms + Breakthrough: IMPLEMENTED / AWAITING RUNTIME GATE.
- P2.2 Spiritual Root Quality + Long-Term Growth: IMPLEMENTED / AWAITING RUNTIME GATE.
- P2.3 Technique Economy + Library + Mastery: IMPLEMENTED / AWAITING RUNTIME GATE.
- P2.4 Cultivation Paths / Character Dao Direction: IMPLEMENTED / AWAITING RUNTIME GATE.
- P2.5 Combat Skills / Real-time Auto Combat: IMPLEMENTED / AWAITING RUNTIME GATE.

Locked baseline before the unverified stack: `bbdca12b3f1efd14d31982810859d22f51990ff4` (P1.3 lock).

Implementation checkpoints before later phases:

- before P1.5: `b1fc434c6e05cac451b60ab11c4c855476e00842`;
- before P1.6: `541b67ccc9f847b4c9c44d43ea82317b5668c20e`;
- before P2.1: `a4fe78a8f94d774f9351aaf3b02fd78ad1aaee08`;
- before P2.2: `cc9be52e72b1e787962edaab44319b680805f3b3`;
- before P2.3: `705a7ff2ac2f6cdc2432edc118e7cb0ff337b79d`;
- before P2.4: `c3c3cc7f6a3054d8e7ecdf616e630eed9310c6c1`;
- before P2.5: `7b32f0176b8ed5ba946d26d0423023f8b965efba`.

## Architecture locks

- Engine: Godot 4.7.2 / GDScript.
- Godot owns gameplay/simulation authority.
- Deterministic seeded simulation remains mandatory.
- Save/load, invariants and P0 money conservation remain mandatory.
- New phase mechanics stay opt-in so earlier factories remain behavior-compatible.
- P0–P1.3 are locked regression baselines.
- P1.4–P2.5 are not PASS until real local Godot 4.7.2 gate evidence exists.
- Mechanics must change decisions/outcomes; decorative systems do not count as completion.

## Carried-forward progression stack

- P2.1: cultivation -> breakthrough -> realm -> combat/HP consequences.
- P2.2: root quality changes cultivation and breakthrough; elemental roots later shape technique/skill efficiency.
- P2.3: sect-owned technique economy, Tàng Kinh Các, manuals, learning/mastery/upgrades, one active cultivation technique, path/element/role metadata.
- P2.4: no fixed class. Kiếm/Thể/Pháp identity is derived from actual accumulated path XP. Path depth changes combat/defense/cultivation and strengthens matching effects.

## Active P2.5 — Combat Skills / Real-time Auto Combat

### User-approved combat direction

Combat must look and behave like actors fighting on the map, not two numbers exchanging damage and not a turn/round battle.

P2.5 therefore uses a deterministic internal real-time timeline while keeping the simulation lightweight:

- 0.25 s simulation quantum;
- bounded encounter duration;
- distance between disciple and monster;
- approach / keep-distance movement;
- melee versus ranged basic attacks;
- independent combat skills;
- cast time + cooldown;
- projectile travel time;
- guard / burn / weaken effects;
- autonomous skill selection;
- bounded combat event trace for future animation/presentation.

No frame-perfect weapon collision, animation hitbox authority, ragdoll, per-pixel projectile physics, detailed terrain projectile collision or manual action-game dodging.

### Technique, realm and skill are separate

This was explicitly corrected during design review.

- Cultivation technique is NOT a fixed combat-skill kit.
- A technique does NOT automatically grant five moves by technique level.
- Realm gates whether a combat skill can be learned/used.
- Combat skills are separately learned actions.
- Cross-path learning is allowed; compatibility changes effectiveness rather than legality.
- P2.5 deliberately does not lock the final long-term number of equipped skill slots.

### Initial skill vertical slice

The first library is only enough to prove the architecture and combat differences; it is not a total-game skill count.

Sword:

- Thanh Phong Trảm;
- Truy Phong Bộ;
- Ngự Kiếm Thuật.

Body:

- Chấn Sơn Quyền;
- Kim Cương Hộ Thể;
- Bất Động Thân.

Spell:

- Hỏa Cầu;
- Hàn Sương Ấn;
- Liệt Diễm.

Each skill has its own path, element, minimum realm stage, range, cast time, cooldown and real effect.

### Combat identity

The active cultivation technique can shape default combat spacing without deciding which skills are known:

- Kiếm: fast, close-to-mid range;
- Thể: shortest range, heavy/contact behavior;
- Pháp: keeps distance and uses ranged basics.

Skill effectiveness can be modified by:

- spiritual-root elemental affinity;
- P2.4 accumulated expertise in the skill path;
- small active-technique path/element resonance.

There is no global Kiếm-thế / Chiến-ý / combat-mana bar in P2.5. Such resources may exist later only for specific builds where they add meaningful gameplay.

### Compatibility

- `P24Factory` remains `combat_skills_enabled == false` and still executes the original 20-exchange legacy resolver unchanged.
- `P25Factory` creates P2.4 first, then enables the new combat-skill system.
- learned combat skills serialize only when present;
- P2.5 sect state serializes only when enabled/events exist;
- transient in-combat distance/cooldowns/projectiles/statuses are not saved mid-encounter.

### Verification contract

The P2.5 test/gate checks:

1. P2.4 still enters the legacy resolver and has no P2.5 trace/state leakage.
2. Realm requirements gate learning while path does not hard-lock learning.
3. Kiếm/Thể/Pháp have measurably different spacing/basic styles.
4. Root affinity and P2.4 path depth change skill effectiveness.
5. Projectile impact occurs after launch rather than instantly.
6. Hỏa Cầu burn creates delayed real damage.
7. Guard and weaken create real combat modifiers.
8. Liệt Diễm is stronger against a burning target.
9. Combat traces remain bounded.
10. Learned skills + sect P2.5 state survive save/load.
11. Same-seed simulation and post-load continuation remain deterministic.
12. All prior invariants remain green.
13. P2.5 interaction scene launches on Godot 4.7.2.

Authoritative command: `Sync-P2-5.cmd`.

## Explicit P2.5 exclusions

Do not expand this phase into:

- master/disciple;
- equipment/artifacts;
- pets/formations;
- full combat-team V2;
- multi-monster encounters;
- real AOE before multi-target combat exists;
- bosses/factions/PvP/secret realms;
- frame-perfect hitboxes or action-game physics;
- a universal combat resource;
- final skill-slot/loadout rules;
- separate combat-skill level/material economy.

## Completion status

P2.5 code, spec, scene, tests and chained verifier are implemented on `main`, but no real Godot runtime command has been executed in this chat environment.

Therefore P2.5 status is strictly:

`IMPLEMENTED / AWAITING RUNTIME GATE`

Do not mark P1.4–P2.5 PASS before a real successful `Sync-P2-5.cmd` run on the Windows/Godot 4.7.2 machine.
