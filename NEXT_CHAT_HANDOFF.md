# NEXT CHAT HANDOFF — Tông Môn Bá Đạo

Date: 2026-10-01

Always inspect live `main` before editing.

## Runtime status

Real Windows + Godot 4.7.2 cumulative gate is green through **P2.11**.

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
- P2.7 Disciple Life + Workforce
- P2.8 Disciple Generation V2 + Phẩm chất + Recruitment Sources
- P2.9 Traits + Hidden Reveal
- P2.10 Spiritual Root Refinement + Mutation
- P2.11 Bloodline + Awakening + Purity

Latest authoritative user runtime evidence ended with:

- `P2.11 PERSISTENCE DIAGNOSTIC PASS: immediate canonical state identical`
- `P2.11 BLOODLINE + AWAKENING TEST PASS`
- `P2.11 BLOODLINE + AWAKENING GATE: PASS`
- `P2.11 GATE: PASS`

Do not reopen P0-P2.11 without new regression evidence.

## Active phase

**P2.12 — Thể Chất + Tôi Thể + Cải Thể**

Status: **IMPLEMENTED / AWAITING REAL GODOT 4.7.2 CUMULATIVE GATE**.

Never call it PASS before a successful `Sync-P2-12.cmd` run.

## Read first

1. `AGENTS.md`
2. `CURRENT_CHECKPOINT.md`
3. `docs/P2_12_PHYSIQUE_SPEC.md`
4. `docs/P2_11_BLOODLINE_SPEC.md`
5. `docs/XIANXIA_FLAVOR_CANON.md`
6. this file

## Global design rule from the user

Every system must have a clear real mechanism. **Do not fear stat overlap.** Linh căn, Huyết Mạch, Thể Chất, Đặc Chất, Công pháp, Trang bị, Thiên Mệnh, buildings and positions may all affect Công/Thủ/HP/Tu/Đột phá/etc when logically justified.

Systems differ by acquisition, progression, cost, conditions, tradeoffs and signature rules — not by forbidding overlap.

Flavor/humor drawbacks are secondary. A rare system must first be genuinely useful.

## Core product direction

Primary operating rhythm is Evil Hunter Tycoon-like, but individual disciples are much deeper.

The player is Tông Chủ. Disciples autonomously live, cultivate, work, hunt, recover, consume and form relationships. The player controls recruitment, infrastructure, policy, production, assignment, investment and temporary direct intervention.

Normal disciples are deterministic procedural individuals. Hidden/latent identity is generated once and persisted. Reveal/transformation never rerolls it.

## P2.12 implementation

### Main files

- `docs/P2_12_PHYSIQUE_SPEC.md`
- `godot/src/simulation/physique/physique_system.gd`
- `godot/src/simulation/core/p2_12_factory.gd`
- `godot/src/simulation/state/sect_state.gd`
- `godot/src/simulation/recruitment/recruitment_system.gd`
- `godot/src/simulation/cultivation/cultivation_system.gd`
- `godot/src/simulation/cultivation/cultivation_path_system.gd`
- `godot/src/simulation/combat/combat_system.gd`
- `godot/src/simulation/needs/needs_system.gd`
- `godot/tests/simulation/p2_12_persistence_diagnostic.gd`
- `godot/tests/simulation/p2_12_physique_test.gd`
- `godot/src/presentation/p2_12_physique.gd`
- `godot/scenes/p2/p2_12_physique.tscn`
- `tools/godot/Verify-P2-12.ps1`
- `Verify-P2-12.cmd`
- `Sync-P2-12.cmd`

### Feature gate/storage

- `SectState.physiques_enabled`
- `SectState.physique_profiles[character_id]`

Profile:

- initialized
- physique_id
- initial_physique_id
- temper_level
- transformed
- latent_transformation

Candidate -> disciple preserves profile. Rejected candidates remove profile.

### Current physiques

- Phàm Thể — small gains from tempering and deterministic future transformation route.
- Kiếm Cốt — Công/Tu/Đột phá + Sword XP, slight recovery drawback.
- Kim Cương Bá Thể — strong Công/Thủ/Hồi + Body XP, real slower cultivation drawback.
- Hàn Âm Thể — strong Water-root synergy; real cultivation/recovery mismatch penalty without Water root.
- Hỏa Linh Thể — strong Fire-root Công/Tu/Đột phá/Spell XP synergy.
- Vô Cấu Đạo Thể — rare all-rounder.

### Tempering/transformation

- `temper_body()` consumes 1 real Yêu Đan, max level 5, and strengthens real effects.
- Phàm Thể at temper >= 3 can `transform_body()` using 2 real Linh Tủy.
- transformation target is pre-generated in `latent_transformation` and never rerolls.
- temper level survives transformation.

### Real consequence hooks

- CultivationSystem: Physique Công/Tu/Đột phá.
- CombatSystem: Physique Thủ.
- NeedsSystem: Physique Hồi/penalty.
- CultivationPathSystem: Physique Sword/Body/Spell XP affinity.

### Required overlap

Bloodline + Physique effects stack. P2.12 test explicitly proves combined Công/Tu exceeds either source alone.

## P2.12 gate intent

Cumulative verifier must prove:

- P2.11 remains physique-disabled;
- same seed -> exact same physique profiles;
- Phàm Thể is stable and has pre-generated transformation target;
- every special physique has real value and direct Công/Thủ;
- tempering consumes exactly 1 Yêu Đan and changes real stats;
- transformation consumes exactly 2 Linh Tủy and uses the old latent target;
- Kiếm Cốt path advantage + recovery drawback;
- Kim Cương Bá Thể defense + slow-cultivation drawback;
- Hàn Âm/Thủy and Hỏa Linh/Hỏa synergies are real;
- Bloodline + Physique overlap stacks;
- recruitment profile lifecycle is correct;
- exact save/load + deterministic continuation;
- P0-P2.11 regressions stay green;
- scene smoke passes.

## Next local command

```bat
cd /d "E:\0.2. TongMonBaDao"
git pull origin main
Sync-P2-12.cmd
```

If it fails, use the first real parser/diagnostic/assertion failure rather than later dependency cascades.

## After P2.12 runtime green

Stop adding backend identity layers temporarily. Build the first **visible living sect** slice:

- compact sect map;
- real buildings/destinations;
- disciples walk between work/rest/cultivation/sect gate;
- their current state/action is visible;
- simulation remains authoritative.

Then continue injury/medical, loyalty/stipend, sect rank/authority, master-disciple, Destiny and later active lifespan/death/inheritance.
