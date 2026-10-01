# NEXT CHAT HANDOFF — Tông Môn Bá Đạo

Date: 2026-10-01

Always inspect live `main` before editing.

## Runtime status

Real Windows + Godot 4.7.2 cumulative gate is green through **P2.10**.

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

Authoritative latest user runtime evidence on 2026-10-01 ended with:

- `P2.9 TRAITS + HIDDEN REVEAL GATE: PASS`
- `P2.10 PERSISTENCE DIAGNOSTIC PASS: immediate canonical state identical`
- `P2.10 SPIRITUAL ROOT REFINEMENT + MUTATION TEST PASS`
- `P2.10 SPIRITUAL ROOT REFINEMENT + MUTATION GATE: PASS`
- `P2.10 GATE: PASS`

Do not reopen P0-P2.10 without new regression evidence.

## Active phase

**P2.11 — Huyết Mạch + Thức Tỉnh + Độ Thuần**

Status: **IMPLEMENTED / AWAITING REAL GODOT 4.7.2 CUMULATIVE GATE**.

Never call it PASS before a successful `Sync-P2-11.cmd` run.

## Read first

1. `AGENTS.md`
2. `CURRENT_CHECKPOINT.md`
3. `docs/P2_11_BLOODLINE_SPEC.md`
4. `docs/XIANXIA_FLAVOR_CANON.md`
5. `docs/DISCIPLE_GENERATION_CANON.md`
6. `docs/P2_10_SPIRITUAL_ROOT_REFINEMENT_SPEC.md`
7. this file

## Core product direction

Primary operating rhythm is Evil Hunter Tycoon-like, but individual disciples are much deeper.

The player is Tông Chủ. Disciples autonomously live, cultivate, work, hunt, recover, consume and form relationships. The player controls recruitment, infrastructure, policy, production, assignment, investment and temporary direct intervention.

Normal disciples are deterministic procedural individuals. Hidden identity is generated once and persisted. Reveal never rerolls it.

Keep Spiritual Root, Bloodline, Physique, Destiny, traits/quirks and personality separate.

## Locked P2.8-P2.10 rules

P2.8:

- six permanent foundation dimensions;
- promotable quality;
- ordinary/gacha/fate share one generator;
- age/base/max lifespan schema;
- root purity and root element count are separate.

P2.9:

- visible positive/negative traits have real consequences;
- latent traits reveal from lived history;
- empty visible list is a valid locked result.

P2.10:

- root refinement consumes real `Linh Tủy`;
- purity increases with diminishing returns;
- ordinary refinement preserves element list;
- fewer elements specialize harder, more elements give flexibility;
- latent root mutation is generated before reveal and cannot reroll.

## P2.11 implementation

### Main files

- `docs/P2_11_BLOODLINE_SPEC.md`
- `docs/XIANXIA_FLAVOR_CANON.md`
- `godot/src/simulation/bloodline/bloodline_system.gd`
- `godot/src/simulation/core/p2_11_factory.gd`
- `godot/src/simulation/state/sect_state.gd`
- `godot/src/simulation/recruitment/recruitment_system.gd`
- `godot/src/simulation/cultivation/cultivation_system.gd`
- `godot/src/simulation/combat/combat_system.gd`
- `godot/src/simulation/needs/needs_system.gd`
- `godot/src/simulation/core/simulation_scheduler.gd`
- `godot/tests/simulation/p2_11_persistence_diagnostic.gd`
- `godot/tests/simulation/p2_11_bloodline_test.gd`
- `godot/src/presentation/p2_11_bloodline.gd`
- `godot/scenes/p2/p2_11_bloodline.tscn`
- `tools/godot/Verify-P2-11.ps1`
- `Verify-P2-11.cmd`
- `Sync-P2-11.cmd`

### Feature gate and storage

- `SectState.bloodlines_enabled`
- `SectState.bloodline_profiles[character_id]`

Profile:

- initialized
- bloodline_id
- purity
- revealed
- awakened
- refinement_count

Candidate -> disciple keeps same id/profile. Rejected candidates remove orphan profile.

### Bloodlines

- Chân Long Huyết — combat + breakthrough.
- Phượng Hoàng Huyết — rest recovery.
- Bạch Hổ Huyết — strong combat.
- Huyền Vũ Huyết — incoming damage reduction.
- Thao Thiết Tàn Huyết — strong recovery but one extra real Supply cost when departing if stock exists.
- no special bloodline is valid/common.

Special bloodline identity and purity exist before reveal. Recruitment source changes distribution only.

### Reveal thresholds

- Chân Long: 3 combats.
- Phượng Hoàng: 1 defeat + 1 rest.
- Bạch Hổ: 3 wins.
- Huyền Vũ: 2 retreats.
- Thao Thiết: 3 rests.

Some profiles may already be detected at recruitment depending on deterministic seed/source.

### Awakening and refinement

Awakening requires revealed special bloodline and consumes one existing P2.3 `Yêu Đan`.

Effects are inactive before awakening.

Post-awakening refinement consumes Yêu Đan, raises purity with Tiềm Lực + diminishing returns, routine cap 0.95.

## Xianxia humor/flavor

The user explicitly wants familiar funny cultivation-story situations.

Read `docs/XIANXIA_FLAVOR_CANON.md`.

Allowed examples include khẩu nghiệp, fake self-declared Thiên Mệnh Chi Tử, furnace explosions, odd/fake manuals, misunderstood fate items, gluttony/greed/gossip and badly timed breakthroughs.

Humor must come from real simulation consequences and must not turn the game into a meme game.

P2.11 first real humorous mechanic: awakened Thao Thiết Tàn Huyết eats one extra departure Supply but recovers faster.

## P2.11 gate intent

Cumulative verifier must prove:

- P2.10 remains bloodline-disabled;
- same seed -> same profiles;
- no-special-bloodline is stable and never rerolls;
- reveal preserves id/purity and does not auto-awaken;
- dormant bloodline has no effect;
- awakening consumes exactly one Yêu Đan;
- Chân Long/Bạch Hổ affect combat;
- Chân Long affects breakthrough;
- Huyền Vũ reduces real incoming damage multiplier;
- Phượng Hoàng improves real rest recovery;
- Thao Thiết improves recovery and consumes one extra real Supply;
- refinement increases purity with diminishing returns;
- candidate acceptance preserves profile and rejection removes it;
- exact save/load + deterministic continuation;
- P0-P2.10 regressions stay green;
- P2.11 scene smoke passes.

## Next local command

```bat
cd /d "E:\0.2. TongMonBaDao"
git pull origin main
Sync-P2-11.cmd
```

If it fails, use the first real parser/diagnostic/assertion failure rather than later dependency cascades.

## After P2.11 runtime green

1. P2.12 Physique;
2. then stop stacking identity systems temporarily and build the first visible living-sect map/building/disciple-movement slice;
3. injury/medical;
4. loyalty + stipend/reward;
5. sect rank/authority;
6. master-disciple;
7. Destiny;
8. active aging/lifespan/death/inheritance later.
