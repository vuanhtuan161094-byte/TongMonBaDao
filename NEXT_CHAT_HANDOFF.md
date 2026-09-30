# NEXT CHAT HANDOFF — Tông Môn Bá Đạo

Date: 2026-09-30
P2.5 implementation started from main head: `7b32f0176b8ed5ba946d26d0423023f8b965efba`

Always inspect live `main` before editing because documentation/static-review commits may be ahead of the first P2.5 implementation commit.

## Read first

Before changing code, read:

1. `AGENTS.md`
2. `CURRENT_CHECKPOINT.md`
3. this file
4. `docs/P2_5_SPEC.md`
5. live P2.5 code/tests

## Runtime status

PASS / LOCKED with real Godot 4.7.2 evidence:

- P0 Foundation
- P1.1 Goal + Personality
- P1.2 Recruitment
- P1.3 Relationships

IMPLEMENTED / AWAITING RUNTIME GATE:

- P1.4 Memory
- P1.5 Organization
- P1.6 Sect Needs
- P2.1 Cultivation + Realms + Breakthrough
- P2.2 Spiritual Root Quality
- P2.3 Technique Economy + Tàng Kinh Các + Mastery
- P2.4 Cultivation Paths / Character Dao Direction
- P2.5 Combat Skills / Real-time Auto Combat

Never call P1.4–P2.5 PASS until the real Godot gate succeeds. Current authoritative local command is `Sync-P2-5.cmd`.

## Core game philosophy

The player does not puppet every disciple. The player controls the sect, opportunities, investment and strategic direction; disciples act autonomously from state, personality, history, realm, techniques and learned combat skills.

The game should borrow useful operating ideas from games such as Evil Hunter Tycoon while remaining a cultivation management game rather than becoming a manual action RPG.

Every mechanic must have measurable simulation/player-decision consequences. No decorative bars, labels or lore-only progression.

## Current progression stack

- P2.1: cultivation -> breakthrough -> realm -> combat power + HP consequences.
- P2.2: root quality affects cultivation/breakthrough; elemental affinity later modifies compatible systems without hard-locking them.
- P2.3: sect-owned cultivation-technique economy. Max 3 learned techniques, 1 active. Technique has path/element/role and passive cultivation/combat consequences.
- P2.4: no fixed class. Sword/Body/Spell path identity emerges from actual accumulated usage history and has real consequences.
- P2.5: combat skills are a separate system from cultivation techniques. Realm gates skill capability. Auto combat now has time, distance, movement, melee/ranged basics, cast times, cooldowns, projectile travel and small real statuses.

## Critical design corrections made during P2.5 review

Do NOT revert these without an explicit user decision:

1. Combat is not a round/turn system.
2. Do not implement combat as two static actors exchanging floating damage numbers.
3. Combat is autonomous real-time simulation on the map; presentation will later animate authoritative simulation events.
4. A cultivation technique is NOT a fixed five-skill kit.
5. Technique level must NOT automatically unlock five attached combat moves.
6. Combat skills are independently learned.
7. Realm/cultivation stage gates whether a skill is learnable/usable.
8. Cross-path skills are allowed; affinity/resonance changes effectiveness, not legality.
9. Do not force a universal Kiếm-thế, Chiến-ý or combat-mana resource on every build.
10. Do not lock a final skill-slot count in P2.5.

## P2.5 implementation shape

### New system

`godot/src/simulation/combat/combat_skill_system.gd`

Initial vertical-slice skills:

- Sword: Thanh Phong Trảm, Truy Phong Bộ, Ngự Kiếm Thuật.
- Body: Chấn Sơn Quyền, Kim Cương Hộ Thể, Bất Động Thân.
- Spell: Hỏa Cầu, Hàn Sương Ấn, Liệt Diễm.

This is not the game's final skill count.

### New combat resolver

`CombatSystem.resolve_encounter()` branches only when `state.sect.combat_skills_enabled`.

- flag off: original P2.4 legacy resolver stays intact;
- flag on: deterministic 0.25-second internal timeline;
- scalar combat distance, not full action-game physics;
- autonomous approach / spell kiting;
- cast + cooldown;
- projectiles have travel time;
- guard/burn/weaken are real temporary effects;
- bounded event trace returned for future presentation.

### Persistence

Persistent:

- P2.5 sect enabled flag + event counter;
- each disciple's independently learned combat skills.

Not persistent mid-encounter:

- distance;
- cooldowns;
- current cast;
- in-flight projectiles;
- temporary guard/burn/weaken.

Encounters still resolve synchronously in one simulation action, so mid-combat save is intentionally out of scope.

## P2.5 verification assets

- spec: `docs/P2_5_SPEC.md`
- factory: `godot/src/simulation/core/p2_5_factory.gd`
- test: `godot/tests/simulation/p2_5_combat_skill_test.gd`
- scene: `godot/scenes/p2/p2_5_combat_skills.tscn`
- scene script: `godot/src/presentation/p2_5_combat_skills.gd`
- verifier: `tools/godot/Verify-P2-5.ps1`
- launcher: `Verify-P2-5.cmd`
- sync+gate: `Sync-P2-5.cmd`

`Verify-P2-5.ps1` chains the entire P2.4 verifier first.

## Scope boundary

P2.5 deliberately does NOT include:

- frame-perfect weapon collisions or animation-authoritative hitboxes;
- ragdoll;
- per-pixel projectile physics;
- detailed terrain projectile collision;
- manual dodge action gameplay;
- multi-monster combat;
- real AOE before multiple targets exist;
- equipment/artifacts;
- pets/formations;
- bosses/factions/PvP/secret realms;
- full combat-team V2;
- final combat skill loadout/slot rules;
- a separate combat-skill upgrade-material economy.

## Master / Disciple remains deferred

Do NOT automatically implement Master/Disciple next.

It was deliberately deferred until combat skills, combat history and other transmissible systems exist strongly enough to make teaching meaningful rather than just a training-percentage modifier.

## Next phase

No phase after P2.5 has been locked yet. First obtain the real `Sync-P2-5.cmd` output, fix any runtime/compiler/test failures, and only then choose the next system with the user.
