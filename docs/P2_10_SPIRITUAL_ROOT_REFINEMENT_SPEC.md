# P2.10 — Linh Căn Tinh Luyện + Biến Dị

Date: 2026-10-01

Status: IMPLEMENTED / AWAITING REAL GODOT 4.7.2 CUMULATIVE GATE.

P2.8 is runtime-confirmed PASS. P2.9 and P2.10 are not PASS until the Windows Godot gate reaches the final P2.10 PASS line.

## Player-facing goal

Linh căn is no longer only a birth label. It becomes a long-term investment axis without turning ordinary training into free innate-stat inflation.

The Sect Master may spend real sect resources to refine a disciple's spiritual root. Refinement:

- raises spiritual-root purity;
- keeps the existing element list unchanged during ordinary refinement;
- may cross a purity threshold and promote the existing P2.2 compatibility quality bucket;
- improves real cultivation and breakthrough performance while P2.10 is enabled;
- improves matching technique consequence through the existing P2.3 compatibility bridge when a quality threshold is crossed;
- can awaken a pre-generated rare mutation after enough refinement and purity.

## Real resource loop

P2.10 consumes the existing P2.3 material:

- `linh_tuy` — Linh Tủy.

This material already comes from the hunt/technique-material loop. P2.10 does not invent a disconnected new currency.

The player therefore gets a real allocation choice:

`Linh Tủy -> nâng công pháp` versus `Linh Tủy -> tinh luyện linh căn`.

P210Factory seeds a small amount only for the vertical-slice interaction/test environment. Production balance remains future tuning work.

## Purity and number of elements remain separate

P2.8 already separated:

- spiritual-root purity;
- spiritual-root element list.

P2.10 preserves that separation.

Ordinary refinement must NEVER automatically reduce or replace the element list.

Design tradeoff:

- fewer elements = stronger specialization on a matching element;
- more elements = broader compatibility/flexibility;
- multi-root is not automatically bad;
- purity remains an independent axis.

## Purity promotion bridge

Working bridge remains:

- `< 0.48` -> Tạp linh căn;
- `0.48 .. < 0.65` -> Phàm linh căn;
- `0.65 .. < 0.82` -> Địa linh căn;
- `>= 0.82` -> Thiên linh căn.

This bridge exists for compatibility with the locked P2.2/P2.3 systems. P2.10 uses continuous purity for its own cultivation/breakthrough effects while preserving the old buckets for legacy consequence code.

## Refinement gain

One refinement consumes one Linh Tủy.

Gain depends on:

- current purity — diminishing returns at high purity;
- Tiềm Lực — higher potential makes rare foundation transformation more efficient.

Purity is capped below 1.00 in this slice (`0.98`). Reaching absolute perfection is intentionally reserved for later rare content rather than routine material spam.

## Latent root mutation

Mutation is generated deterministically from stored identity, not rolled when revealed.

The profile stores:

- initialized flag;
- refinement count;
- latent mutation id;
- revealed mutation id.

Possible vertical-slice mutations:

- Canh Kim Dị Căn;
- Thanh Mộc Dị Căn;
- Hàn Thủy Dị Căn;
- Xích Viêm Dị Căn;
- Hậu Thổ Dị Căn.

A mutation, when present, is tied to one of the character's existing root elements.

Recruitment source modifies the chance of having a latent mutation:

- ordinary recruitment: lower chance;
- Chiêu Hiền: higher chance;
- Nhân Duyên: highest chance in this slice.

The exact percentages are implementation tuning, not a permanent economy promise.

## Reveal rule

Current vertical-slice reveal gate:

- at least 3 refinements;
- purity at least 0.72;
- character must already have a latent mutation.

Reveal copies the pre-generated latent mutation into the revealed state. It never rerolls.

A revealed mutation has real consequence:

- extra cultivation efficiency;
- extra breakthrough support;
- extra matching-element root effectiveness through the P2.10 root-effect API.

## Recruitment lifecycle

New P2.10 candidates receive a deterministic root-refinement profile when generated.

Candidate -> disciple acceptance:

- keeps the exact same profile;
- does not reroll mutation identity.

Candidate rejection:

- removes its root profile to avoid orphan state.

## Feature gate

Authority flag:

- `SectState.spiritual_root_refinement_enabled`.

When false:

- P2.9 and earlier use their original spiritual-root/cultivation formulas;
- P2.10 profile state is absent from serialized output;
- cumulative regressions must remain behavior-compatible.

## Main files

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

## Gate must prove

1. P2.9 remains refinement-disabled.
2. Same seed creates the same latent root profiles.
3. Refinement consumes exactly one real Linh Tủy.
4. Refinement raises purity.
5. Ordinary refinement does not change element count/list.
6. Crossing purity thresholds updates the legacy quality bridge.
7. That bridge changes a real matching P2.3 technique consequence.
8. Higher purity improves real cultivation gain.
9. Higher purity improves real breakthrough chance away from the 99% ceiling.
10. Single-root specialization is stronger on one matching element while multi-root remains flexible.
11. Latent mutation does nothing before reveal.
12. Reveal never changes/rerolls the latent mutation id.
13. Revealed mutation has measurable gameplay consequence.
14. Acceptance preserves root profile; rejection removes it.
15. Exact save/load state equality passes.
16. Deterministic continuation passes.
17. Full P0-P2.9 cumulative regression remains green.
18. P2.10 interaction scene launches headless.

## Explicitly deferred

P2.10 does NOT yet add:

- new elemental families such as Lôi/Băng as full technique ecosystems;
- element replacement/removal surgery;
- root-destruction failure states;
- special refinement pills/alchemy recipes;
- bloodline;
- physique;
- active aging/death.

Those should be layered only after the cumulative P2.10 gate is green.
