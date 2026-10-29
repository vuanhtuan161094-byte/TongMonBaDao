# V6.3 D2 — Sect Archive and exactly-once codex rewards

## Result

Implemented D2 on `feature/v63-v64-full-combat-20261029`. Final tested source commit: `d45ab195c53c00f0f29732124dd7678fd42cb351`; D1 base: `6e4012d7a9e3a7efa56df349a176f9491d550742`. Stable `main` remains `c0c1382f119599497b52d8ee8abd9e830a883f1e`; PR #52 remains Draft and unmerged.

Godot `4.7.2.stable.official.ed1daf0bf` headless editor import passed (exit 0). All 10 focused and affected regression scripts passed (each exit 0). Source parity against the final commit passed for all 12 D2 code/test paths, ignoring Windows line-ending conversion only.

## D2 code and test paths

- `godot/data/combat/v63_archive_catalog.json`
- `godot/src/presentation/p2_3_techniques.gd`
- `godot/src/simulation/archive/v63_sect_archive_system.gd`
- `godot/src/simulation/combat/hunting_map_v2.gd`
- `godot/src/simulation/combat/hunting_pve_run_v2.gd`
- `godot/src/simulation/combat/pve_multi_camp_population_v1.gd`
- `godot/src/simulation/resource/resource_registry.gd`
- `godot/src/simulation/state/sect_state.gd`
- `godot/src/simulation/state/simulation_state.gd`
- `godot/tests/presentation/v63_d2_sect_archive_ui_test.gd`
- `godot/tests/simulation/v63_d2_codex_drop_receipts_test.gd`
- `godot/tests/simulation/v63_d2_sect_archive_test.gd`

The only additional paths updated for D2 status/evidence were `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, and this report. No other D2 code/test path was changed.

## D2 behavior

- The data-driven catalogue covers all 105 skill families: 96 archivable manuals and 9 innate families without purchasable manuals. It registers 96 manuals plus four tier fragment resources through the existing `ResourceRegistry`.
- The first complete manual is consumed once into permanent Sect transmission. All current and future disciples can use that archive entry; it is not consumed per disciple. Duplicate manuals can add one research point with an idempotent request receipt.
- Candidate fragment restoration consumes the catalogue's provisional fragment count and creates one complete manual with a persisted idempotency receipt. It honors the canonical Warehouse's lock/reserve rules. Candidate costs remain unapproved balance data.
- Optional PvE victory and per-kill codex payouts are validated against registered archive resources and settle through the existing single Sect Warehouse. Receipts reject changed-payload retries. Open-world kills stay pending until settlement and receipt acknowledgement complete; the legacy HP0 duplicate-rejection contract remains the default.
- The existing techniques screen now exposes the archive using real simulation/Warehouse state. No mock inventory or second Warehouse was added.
- D2 state fields are additive in `SectState`; legacy saves default dormant. No `SaveService` or schema migration was changed.

## Release and scope limits

`sect_codex` remains OFF by default and each save's `v63_archive_opt_in` defaults false. Tests enable the feature only through explicit preview overrides. The catalogue has no live drop profiles; no production drop rates were invented. Restore costs are candidate values. Timed research/One Active Job, SaveService migration, live skill combat, assets, and main/PR merges were not part of D2.

## Official validation

The sequential matrix is in `E:\TongMonBaDaoWorkspace\03_QA_Logs\v63_d2_validation` and is copied to the user outputs folder. Import log SHA-256: `f1d9d468d9502ca1f617c2774b33612c3d2b476bc6381b9ca301d89e23203d31`. Test matrix SHA-256: `8c63b213f6e9ae521a0daa4c59acac69d27f25ceaf00a0194487bcc0b15e31b2`. The `SHA256SUMS.txt` manifest hashes every copied log and matrix.

| Script | Result |
| --- | --- |
| `v63_d1_content_registry_test.gd` | PASS |
| `v63_d2_sect_archive_test.gd` | PASS — catalogue coverage, 128 disciples, archive/research/restoration receipts, lock policy and save round-trip |
| `v63_d2_codex_drop_receipts_test.gd` | PASS — victory/per-kill settlement, retries, pending-kill recovery, changed payload, gating, atomic failure and save/load |
| `v63_d2_sect_archive_ui_test.gd` | PASS — existing techniques screen reads and archives a real Warehouse manual |
| `p3_7b1_warehouse_test.gd` | PASS |
| `safe_02_warehouse_migration_test.gd` | PASS |
| `pve_multi_camp_population_v1_test.gd` | PASS |
| `pve_multicamp_combat_hp0_bridge_test.gd` | PASS |
| `pve_save_return_reload_exactly_once_test.gd` | PASS |
| `p2_3_technique_test.gd` | PASS |

This is headless engine evidence only. It does not claim GUI, Android, FPS, or physical-device acceptance. D3 must receive its own exact path approval before implementation.

