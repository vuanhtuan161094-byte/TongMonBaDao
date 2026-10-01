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

Latest authoritative user runtime line:

`P2.8 GATE: PASS`

Do not reopen P0-P2.8 without new regression evidence.

## Implemented / awaiting runtime

- **P2.9 — Traits + Hidden Reveal**: IMPLEMENTED / NOT PASS YET.
- **P2.10 — Spiritual Root Refinement + Mutation**: IMPLEMENTED / NOT PASS YET.

The user currently has no computer available, so P2.9 was not run before P2.10 implementation continued. P2.10 is isolated behind its own feature gate and verifier.

Never claim P2.9 or P2.10 PASS until real Godot 4.7.2 output is supplied.

## Read first

1. `AGENTS.md`
2. `CURRENT_CHECKPOINT.md`
3. `docs/DISCIPLE_GENERATION_CANON.md`
4. `docs/DISCIPLE_LIFESPAN_CANON.md`
5. `docs/P2_9_TRAITS_REVEAL_SPEC.md`
6. `docs/P2_10_SPIRITUAL_ROOT_REFINEMENT_SPEC.md`
7. this file

## Core product identity

Primary operating rhythm: **Evil Hunter Tycoon**, with much deeper individual disciples.

The player is Tông Chủ. Disciples autonomously live, cultivate, work, hunt, recover, spend and form relationships. The player manages infrastructure, policy, production, recruitment, assignments, investment and temporary direct intervention.

Large rosters must not require mandatory one-by-one micromanagement.

## Locked P2.8 disciple identity

Every V2 candidate is one deterministic procedural individual.

Core identity includes:

- source/profile seed;
- race/sex/origin;
- six permanent dimensions;
- promotable quality;
- personality/biases;
- spiritual-root purity + independent element list;
- profession talent subset;
- latent identity seed;
- age/base/max lifespan schema;
- starting cultivation state;
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

Recruitment sources share one generator:

- ordinary;
- Chiêu Hiền / gacha;
- Nhân Duyên / fate.

Candidate -> disciple keeps the same identity and id.

## P2.9 summary

Feature gate:

- `SectState.disciple_traits_enabled`.

Profiles:

- `SectState.disciple_trait_profiles[character_id]`.

Schema:

- initialized;
- visible;
- latent;
- revealed.

Visible slice with real consequences:

- Kinh Mạch Ổn Định / Kinh Mạch Yếu -> cultivation;
- Cần Mẫn / Cẩu Thả -> workforce;
- Gan Dạ / Nhát Chiến -> effective combat power.

Latent slice:

- Bản Năng Chiến Đấu -> combat-history reveal;
- Nhãn Lực Luyện Khí -> work-history reveal;
- Ngộ Tĩnh -> cultivation-history reveal.

Reveal never rerolls latent identity.

Important main files:

- `godot/src/simulation/traits/trait_system.gd`
- `godot/src/simulation/core/p2_9_factory.gd`
- `godot/tests/simulation/p2_9_traits_test.gd`
- `tools/godot/Verify-P2-9.ps1`

## P2.10 summary

Feature gate:

- `SectState.spiritual_root_refinement_enabled`.

Profiles:

- `SectState.spiritual_root_profiles[character_id]`.

Schema:

- initialized;
- refinement_count;
- latent_mutation;
- revealed_mutation.

### Real resource loop

P2.10 consumes the existing P2.3 material:

- `linh_tuy` — Linh Tủy.

No new disconnected currency.

Player choice:

`Linh Tủy -> upgrade technique` OR `Linh Tủy -> refine spiritual root`.

### Refinement

Ordinary refinement:

- consumes exactly one Linh Tủy;
- raises purity;
- receives a Tiềm Lực contribution;
- has diminishing returns;
- does not change the element list;
- caps routine purity at 0.98.

Purity compatibility thresholds:

- `<0.48` Mixed;
- `0.48..<0.65` Ordinary;
- `0.65..<0.82` Earth;
- `>=0.82` Heaven.

Crossing the bridge feeds existing P2.2/P2.3 consequence code.

Continuous P2.10 purity also changes real cultivation gain and breakthrough chance.

### Specialization vs flexibility

- fewer root elements -> stronger matching-element specialization;
- more root elements -> wider compatibility;
- multi-root is not inherently bad;
- purity stays independent from element count.

### Latent mutation

Vertical-slice mutations:

- Canh Kim Dị Căn;
- Thanh Mộc Dị Căn;
- Hàn Thủy Dị Căn;
- Xích Viêm Dị Căn;
- Hậu Thổ Dị Căn.

Mutation is chosen deterministically before reveal from existing root elements.

Current reveal condition:

- refinement count >= 3;
- purity >= 0.72;
- latent mutation is not `none`.

Reveal copies the stored latent mutation; no reroll.

A revealed mutation has measurable cultivation/breakthrough and matching-element consequences.

### Recruitment lifecycle

New P2.10 candidates receive root profiles when generated.

Acceptance preserves profile. Rejection deletes the orphan root profile.

### Main P2.10 files

- `docs/P2_10_SPIRITUAL_ROOT_REFINEMENT_SPEC.md`
- `godot/src/simulation/cultivation/root_refinement_system.gd`
- `godot/src/simulation/cultivation/spiritual_root_system.gd`
- `godot/src/simulation/cultivation/cultivation_system.gd`
- `godot/src/simulation/core/p2_10_factory.gd`
- `godot/src/simulation/recruitment/recruitment_system.gd`
- `godot/src/simulation/state/sect_state.gd`
- `godot/tests/simulation/p2_10_persistence_diagnostic.gd`
- `godot/tests/simulation/p2_10_root_refinement_test.gd`
- `godot/src/presentation/p2_10_root_refinement.gd`
- `godot/scenes/p2/p2_10_root_refinement.tscn`
- `tools/godot/Verify-P2-10.ps1`
- `Verify-P2-10.cmd`
- `Sync-P2-10.cmd`

## Current local command

When the user has a Windows machine again, run only:

```bat
cd /d "E:\0.2. TongMonBaDao"
git pull origin main
Sync-P2-10.cmd
```

This automatically runs the entire P0 -> P2.9 chain before P2.10.

If it fails, fix the first real parser error / first P2.9 or P2.10 diagnostic/assertion. Ignore later dependency-cascade errors until the first root error is fixed.

## After cumulative P2.10 green

Planned order:

1. Bloodline;
2. Physique;
3. first visible living-sect map/building/disciple movement slice;
4. injury/medical;
5. loyalty + stipend/reward;
6. sect rank/authority expansion;
7. master-disciple/teaching;
8. Destiny/awakening;
9. active lifespan/aging/death/inheritance after pacing is proven.

Do not keep adding backend identity systems indefinitely before returning to visible gameplay.
