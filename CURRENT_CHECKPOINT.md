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

Authoritative latest runtime evidence supplied by the user on 2026-10-01 ended with:

`P2.8 GATE: PASS`

Do not reopen P0-P2.8 without new regression evidence.

## Implemented but not runtime-confirmed yet

### P2.9 — Đặc Chất + Khuyết Điểm + Ẩn/Thức tỉnh

Status: **IMPLEMENTED / AWAITING CUMULATIVE GODOT GATE**.

Main behavior:

- deterministic visible traits and latent traits;
- empty visible trait list is a valid locked result, never a reroll trigger;
- cultivation traits have real cultivation consequences;
- workforce traits have real work/learning consequences;
- combat traits feed real effective combat power;
- hidden traits are generated before reveal and reveal only after deterministic life-history thresholds;
- candidate acceptance preserves the profile; rejection deletes orphan profile state;
- exact persistence/determinism contracts exist.

Read `docs/P2_9_TRAITS_REVEAL_SPEC.md`.

### P2.10 — Linh Căn Tinh Luyện + Biến Dị

Status: **IMPLEMENTED / AWAITING CUMULATIVE GODOT GATE**.

P2.10 is feature-gated through:

- `SectState.spiritual_root_refinement_enabled`.

When false, P2.9 and earlier retain their original root/cultivation behavior and serialized shape.

Player-facing loop:

`Săn -> Linh Tủy -> chọn nâng Công pháp hoặc tinh luyện Linh căn -> độ tinh thuần tăng -> tu luyện/đột phá/công pháp phù hợp mạnh hơn`.

P2.10 intentionally reuses the existing P2.3 `linh_tuy` material rather than creating a disconnected new currency.

### Purity and element count remain independent

Ordinary refinement:

- increases `spiritual_root_purity`;
- does NOT automatically remove/add/replace root elements;
- may cross the existing compatibility quality thresholds;
- uses diminishing returns near high purity;
- Tiềm Lực contributes to foundation-refinement efficiency.

Compatibility bridge:

- `< 0.48` -> Tạp linh căn;
- `0.48 .. < 0.65` -> Phàm linh căn;
- `0.65 .. < 0.82` -> Địa linh căn;
- `>= 0.82` -> Thiên linh căn.

The bridge keeps locked P2.2/P2.3 consequences usable. P2.10 itself also uses continuous purity for cultivation and breakthrough consequences.

### Specialization vs flexibility

Current P2.10 rule:

- fewer root elements -> stronger specialization on one matching element;
- more root elements -> broader compatibility;
- multi-root is not automatically bad;
- purity remains independent from element count.

### Root mutation

A latent mutation is generated deterministically and stored before reveal. It is never rolled at reveal time.

Vertical-slice mutation IDs:

- Canh Kim Dị Căn;
- Thanh Mộc Dị Căn;
- Hàn Thủy Dị Căn;
- Xích Viêm Dị Căn;
- Hậu Thổ Dị Căn.

Current reveal gate:

- at least 3 refinements;
- purity >= 0.72;
- character already has a latent mutation.

A revealed mutation has real consequences to cultivation/breakthrough and matching-element root effectiveness.

Recruitment source affects latent-mutation distribution only. It never changes the character schema or rerolls identity.

### P2.10 main files

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

## P2.10 cumulative gate intent

`Verify-P2-10.ps1` first runs the entire P0 -> P2.9 chain, then P2.10.

P2.10 must prove:

1. P2.9 stays refinement-disabled.
2. same seed gives exact latent root profiles.
3. refinement consumes exactly one real Linh Tủy.
4. purity rises.
5. ordinary refinement preserves the element list.
6. threshold crossing updates root-quality compatibility.
7. threshold crossing changes a real P2.3 matching-technique consequence.
8. higher purity improves real cultivation gain.
9. higher purity improves breakthrough chance on a non-ceiling stage.
10. specialization/flexibility tradeoff is measurable.
11. latent mutation has no revealed benefit before reveal.
12. reveal never rerolls latent mutation.
13. revealed mutation has measurable consequence.
14. candidate acceptance preserves profile; rejection removes it.
15. exact save/load equality passes.
16. deterministic continuation passes.
17. P0-P2.9 cumulative regressions remain green.
18. P2.10 interaction scene smoke passes.

## Canonical disciple direction

Disciples remain procedural individuals, not hand-authored one by one.

Keep semantic systems separate:

- six permanent foundation dimensions;
- promotable Phẩm chất;
- Spiritual Root;
- Bloodline;
- Physique;
- Destiny;
- traits/quirks;
- personality;
- learned cultivation/profession/combat history;
- equipment/artifacts;
- health/loyalty/lifespan/social/organization state.

Hidden identity is generated once and persisted. Reveal never rerolls it.

## Planned order after P2.10 cumulative green

1. Bloodline;
2. Physique;
3. then stop adding backend identity layers briefly and build the first visible living-sect map/building/disciple movement slice;
4. injury/medical;
5. loyalty + stipend/reward;
6. sect rank/authority expansion;
7. master-disciple/teaching;
8. Destiny/awakening;
9. active aging/lifespan/death/inheritance after pacing is proven.

Do not activate all layers at once.

## Next authoritative local command

When a Windows machine is available, run only:

```bat
cd /d "E:\0.2. TongMonBaDao"
git pull origin main
Sync-P2-10.cmd
```

This command runs P0 -> P2.9 first, then P2.10. The user does not need to run P2.9 separately.

Never call P2.9 or P2.10 PASS until the corresponding real Godot output is provided.
