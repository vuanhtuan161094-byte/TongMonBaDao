# PVE-P0 Respawn + Exact-once Tu Vi/Luyen The + Cold Save/Reload

Date: 2026-11-03. Status: **CODED; OFFICIAL GODOT 4.7.2 QA NOT YET EXECUTED**.
Source base: `feature/pve-p0-free-hunt-30-20261103` @ `b41e9bdd90f5cd1ab74009587ea7fe6e65b082b2`.
Isolated implementation: `feature/pve-p0-respawn-receipt-20261103`.
Live `main` observed at start: `c0c1382f119599497b52d8ee8abd9e830a883f1e`.

## Rule: "XP" is not a new inventory currency

P0 uses the existing `DiscipleRealmProgressV2.grant_xp` authority for both `cultivation` (**Tu Vi progress**) and `body` (**Luyen The progress**). "EXP/loot" in earlier reports was shorthand, not a proposal to create a new EXP wallet or external XP bonus. Pilot rewards (75/25 natural XP, 40% eligible same-party share, common-species item rolls) remain **NOT owner-locked balance**. Item drops go into the canonical `WarehouseSystem`, never a second loot bag. No PvP, no equipment/currency invention.

## This code packet

1. `pve_per_kill_reward_v1.gd`: only the *exact* pending `MapBattleV2` HP=0 journal record can trigger a **new** payout; a paid receipt can be replayed read-only without duplicating inventory or cultivation. A stale generation cannot be rewarded after a later generation was paid. Owner, species and generation must match the original receipt.
2. `pve_multi_camp_population_v1.gd`: on `COOLDOWN -> READY`, advance one and only one generation and clear per-life acknowledgement metadata. Preserve the bounded per-slot historic paid receipt in `p0_kill_rewards`. No extra monsters created on the transition.
3. `pve_distributed_world_v1.gd`: cold restore fails closed for malformed receipts, future generations, wrong life IDs and `COOLDOWN` without a matching paid receipt. This does **not** mutate the inventory on load.
4. `pve_p0_natural_solo_reward_test.gd`: extends the real New Game B1 V2 recruit + 10 actual Combat V2 HP=0 events and first cold load to exercise a real 30-second offscreen cooldown, reactivation of generation 2 in the same world/slot, second official HP=0, exactly one additional reward, forged event refusal, prior-life replay refusal, current-life replay idempotency, a corrupt receipt being rejected by restore and **another separate-process-boundary cold reload**. Expected `world_total_kills=11`, bounded ledger size remains 10.

## Run and QA assertions

Run with official **Godot 4.7.2** (not a substitute engine):

```bash
godot --headless --path godot --import
godot --headless --path godot --check-only --script res://tests/simulation/pve_p0_natural_solo_reward_test.gd
godot --headless --path godot -s res://tests/simulation/pve_p0_natural_solo_reward_test.gd
godot --headless --path godot -s res://tests/simulation/pve_p0_30_independent_hunters_test.gd
```

Expected **only after observed process exit 0**:

- `PVE_P0_NATURAL_SAVE_RELOAD_PASS`
- `PVE_P0_RESPAWN_GEN2_PASS`
- `PVE_P0_RESPAWN_COLD_RELOAD_PASS`
- `PVE_P0_NATURAL_SOLO_PASS`

Additional regression gates before integration: P3.7 resource warehouse, Injury120, V63 Codex drops, multi-party sharing, character join/return, legitimate idle/occupied job constraints and old save migration. Manual Windows and Android controls remain independently unverified. The 200 registered spawn slots are **not** 200 simultaneous monster actors.

## Explicit boundaries / evidence policy

No changes to `main`, PR #67, P3.2 UI, core save schema, HUD, recruitment rules, original HP/Injury120, economy/balance or player saves. This is an isolated code/test patch, NOT a shipped/fully-playable UI feature. No local Godot executable was available in this tool environment to run a parser/import or headless simulation. Do not claim PASS, exact-once runtime proof or a finalized economy balance until official focused and affected cumulative gates actually run with exit codes and logs. Do not merge the entire branch mechanically.
