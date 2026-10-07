# P2.10 — LEGACY SPIRITUAL ROOT REFINEMENT RUNTIME

Date: 2026-10-07

Status: **LEGACY RUNTIME / REGRESSION COMPATIBILITY ONLY — SUPERSEDED FOR ALL NEW DESIGN**

Canonical Spiritual Root authority is now:

`docs/SPIRITUAL_ROOT_V2_SPEC.md`

This file is retained only because locked P2 regression tests and old-save/runtime migration still reference the P2.10 implementation.

## Do not use P2.10 as new gameplay authority

The following P2.10 concepts are obsolete for new V2 characters and must not be reused in new design/code:

- one global spiritual-root purity;
- Tạp/Phàm/Địa/Thiên root-quality buckets as final authority;
- root quality deciding element count;
- diminishing refinement gain;
- purity cap below 100%;
- Tiềm Lực modifying ordinary root-refinement gain;
- generic root breakthrough bonus;
- old source-biased mutation probabilities;
- Canh Kim / Thanh Mộc / Hàn Thủy / Xích Viêm / Hậu Thổ mutation set;
- reveal from refinement-count + global-purity threshold;
- old single-root specialization multiplier.

All of those are superseded by Spiritual Root V2.

## Why the legacy runtime still exists

Do **not** delete the P2.10 runtime files until Spiritual Root V2 implementation performs a tested migration.

They are currently needed for:
- locked P0–P2 regression behavior;
- historical save compatibility;
- migration source data;
- existing P2 scenes/tests.

Keeping these files does **not** make them design authority.

## Migration target

When Spiritual Root V2 implementation is explicitly started, the active phase must:

1. add canonical per-element root values and immutable birth values;
2. generate the locked V2 1–5 root distribution and per-root purity;
3. migrate old global purity/quality deterministically;
4. replace ordinary legacy refinement with deterministic +1 V2 refinement;
5. migrate old latent/revealed mutation identity where possible;
6. remove old mutation generation/reveal rules from V2 runtime;
7. preserve save/load determinism;
8. keep earlier locked regressions green or provide an explicit compatibility boundary;
9. only then remove dead legacy fields/code paths that no longer have migration/regression consumers.

## Legacy runtime files

Compatibility implementation currently remains in:

- `godot/src/simulation/cultivation/spiritual_root_system.gd`;
- `godot/src/simulation/cultivation/root_refinement_system.gd`;
- `godot/src/presentation/p2_2_spiritual_roots.gd`;
- `godot/src/presentation/p2_10_root_refinement.gd`;
- `godot/tests/simulation/p2_2_spiritual_roots_test.gd`;
- `godot/tests/simulation/p2_10_root_refinement_test.gd`.

These are **legacy compatibility surfaces**, not Spiritual Root V2 authority.
