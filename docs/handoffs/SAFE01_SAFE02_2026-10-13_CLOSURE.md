# SAFE-01 + SAFE-02 — Data integrity closure (2026-10-13)

## Scope / evidence

Owner authorized both packets while Windows PC unavailable. Godot 4.7.2 backend only; **no gameplay/balance/rules/visual asset changes**. SAFE-01 was implemented, tested and then SAFE-02 was implemented and tested sequentially.

- Canonical code: `godot/src/simulation/save/save_service.gd`, `godot/src/simulation/core/live_game_runtime_v2.gd`, `godot/src/simulation/resource/warehouse_system.gd`.
- New tests: `godot/tests/simulation/safe_01_save_recovery_test.gd`, `godot/tests/simulation/safe_02_warehouse_migration_test.gd`.
- Gate: `.github/workflows/safe-data-integrity.yml`; **latest complete SUCCESS [run #38324783574](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38324783574)** at code HEAD `a19feeb45506c74e0d606452536697dcb00d270f`.
- All steps passed: official Godot 4.7.2 import/parse, SAFE-01 recovery, SAFE-02 fail-closed migration, P0 save roundtrip, P3.7 warehouse regression, DV2 live-runtime save/offline, O9 M2 multi-producer save/reload, and **full P3.7 cumulative regression**.
- Historical failed SAFE runs #38324487307 and #38324633945 and P3.7 runs #38324487206 / #38324633767 were caused by two new-test GDScript parse issues, subsequently fixed; latest full CI is successful. Do not hide those past failures or confuse with gameplay regressions.

## SAFE-01 CLOSED — crash-resilient file publish/recovery

- Preserve SaveService V2 JSON/float64 wire format and canonical simulation.
- Write `.tmp`, flush and validate by actual save loader before installing; rotate valid primary to `.bak`, rename staged file to primary in same directory.
- Load prefers valid primary, otherwise tries `.bak`; interrupted state where only backup remains can recover.
- Bad primary with good backup can be repaired without overwriting only good backup; bad primary with no backup **fails closed** on save and is not silently reset.
- LiveGameRuntimeV2 treats backup-only storage as an existing save when deciding whether to start new.
- **Limit:** Same-directory rename with backup is a pragmatic resilience improvement, not proof of power-loss durability on all Android filesystems; real-device crash/kill/low-storage tests remain PENDING USER.

## SAFE-02 CLOSED — legacy warehouse migration all-or-nothing

- `WarehouseSystem.ensure_migrated` builds a private copy from both legacy buckets, validates resource IDs/negative amounts and MAX_SAFE_STACK before any mutation; commits merged stocks and clears source buckets **only on complete success**.
- Idempotent repeated migration; no second resource authority; no resource ID/value/balance changes.
- `WarehouseSystem.initialize` now reports success/failure. `SaveService.load_from_path` rejects a failed migration, preserving old on-disk save for recovery or diagnosis.
- Tests cover normal merge + idempotency, unknown ID, negative stack, overflow, exact stack boundary, and disk load of an invalid legacy save without overwrite.

## Source reference and locked neighbors

Reviewed `ZQZS-Source-Knowledge/analysis/SystemResearch/HOME_BUILDING_DEEP_DIVE.md`: reference separates authoritative building/instance state and local layout preview. Applied the **principle of single authoritative persistent state only**; did not port Unity's socket code or build new storage framework.

ENV-02A 192×192 isolated map lab remains **Windows/Android PENDING USER**; FE-02 / ENV-02B-E **NOT OPENED**, DV2-03 **PAUSED NOT CLOSED**, and eight historical S3 visual approvals unchanged. TIME-01/PERF-01/TX-01 remain future design candidates only, not authorized.

## Next

No PC required to continue other documentation/reviews. When available, Android real-device save interruption, pause/resume, backup restore and storage-full behavior must be tested. Do not conflate Linux official CI PASS with Android PASS.
