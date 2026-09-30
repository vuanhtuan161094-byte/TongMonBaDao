# P0 Telemetry Contract

## Purpose

P0 telemetry is for simulation validation and balance, not product analytics.

## Mandatory aggregate metrics

- total money and sect treasury range;
- combats, wins, retreats, defeats;
- sales, heals, rests, buys;
- per-disciple danger/safe region visits;
- ending wallet, HP and stamina;
- deterministic replay for fixed seed.

## Interpretation

### Economy

Internal transfers must conserve total money. Sect treasury must not cross the operating reserve during normal market purchases.

### Behavior diversity

The aggressive profile must show materially greater danger exposure than the cautious profile over multiple fixed seeds. Later profiles should also diverge in spending, recovery, and profitability once those utility branches deepen.

### Stability

A long run is invalid if any invariant fails, an agent references a missing region, money drifts, or a core activity disappears entirely.

## P0 benchmark suite

- `p0_invariant_test.gd` — 20,000 ticks, single fixed seed.
- `p0_save_roundtrip_test.gd` — save/load + resumed simulation.
- `p0_reproducibility_test.gd` — same seed must produce identical snapshot.
- `p0_benchmark_test.gd` — 8 fixed seeds × 12,000 ticks with aggregate report.

The multi-seed benchmark writes `godot/reports/p0_benchmark.json`. The reports directory is intentionally ignored by Git.

P0 is not allowed to be declared green from source inspection alone. These scripts must run under Godot 4.7.2.
