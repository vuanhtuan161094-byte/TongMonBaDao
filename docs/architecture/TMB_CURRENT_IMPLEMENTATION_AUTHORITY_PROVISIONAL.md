# TMB current implementation authority — provisional integration branch

**Status: PROVISIONAL.** This document describes the recovery integration branch only. It does not replace main's canonical authority or the owner's final visual approval.

- Branch: `integration/master-recovery-playable-v1-20261023`
- Base: PR #25 head `710137c0e3976e685613a86692e5eb128b8d3c62`
- Integration commits: `087c58b70b9c4bec3847d8acc546d8b761d984fc`, then `f5715ad0d90ee38516b54f316b9dd6f1544c3723`
- Godot: `4.7.2.stable.official.ed1daf0bf`

## Runtime authority

| Concern | Authority on this branch | Presentation boundary |
| --- | --- | --- |
| Disciple, world, combat, HP, Injury, time, AUTO, loot receipt | Existing P3.2 `runtime_session`, `SimulationState`, `SimulationRuntimeOwnerV2`, `B3HuntWorld`, `B3MedicalAutoplayV1`, and Combat V2 | P3.2 reads live values and sends the existing commands. |
| Items and hunting rewards | Existing canonical `WarehouseSystem` and CARE exactly-once receipt | The hunt facts panel displays canonical stock/available values. |
| Persistence and reload | Existing main-screen SaveService/runtime | The presentation adapter has no independent save or reward store. |
| Sect map and production | Existing simulation buildings, work assignments, receipts and Warehouse | `SectIsometricWorldV1` and `SectProductionWorksiteCue` render the existing IDs and facts. `SectIsoMapModelV1` creates visual preview geometry only. |
| Combat V5 | No gameplay authority | `B3CareCombatV5Presenter` renders the `MapBattleV2` snapshot restored from CARE. It must never advance time, choose targets, resolve damage, settle drops or write saves. |

Combat V2/CARE remains authoritative for all outcomes. The V5 adapter is bound from the actual P3.2 hunt panel to `B3HuntWorld.restore(state)`; it does not create a second battle runtime. The V5-focused test compares snapshots before and after presentation refresh and verifies no changes to the saved hunt, tick or canonical Warehouse.

## Verified Source A presentation

- The MAP25 source registry is `godot/data/presentation/map25_source_a_verified.json`; it is explicitly `RUNTIME_SHA_GATED_OPTIONAL`, with `source_binary_in_repo: false` and internal-project-only art status.
- There are 32 verified MAP25/ENV02A PNGs under `godot/art/source_a_env02a/`: roads, terrain, vegetation, main hall, forge and Warehouse. The art-gate focused test reports 32/32 accepted.
- G1 modules restored selectively: `SectIsometricWorldV1`, `SectIsoMapModelV1`, `SectMap25SourceArt`, `SectProductionWorksiteCue`, `DiscipleSixDimensionRadar`, and `DiscipleSourceAVisualPool`.
- `SectMapCamera.VIEW_RECT` restores the exact full-width G1 viewport `(0,72) 1280x570`; the P3.2 test now locks this contract.
- Disciple/profile and production panels read V2 snapshot/state values. Visual geometry is not a second map or production authority.

## Verified Combat V5 presentation

The V5 source manifest is `godot/assets/combat_v5_source_a/visual_manifest.json`. The current verified actor keys are:

| V5 key | Verified art identity | Current CARE use |
| --- | --- | --- |
| `disciple_female` | Source A female `1113028_1` | Active for the authentic V2 female disciple shown in GUI capture. |
| `disciple_male` | Source A male body `1110201` | Manifest/atlas is present; the final GUI capture does not exercise this route. |
| `monster_1113031_1` | Source A animal `1113031_1`, mapped from CARE's canonical B3 Thanh Lang | Active in the hunt capture. |
| `boss_slot_410041_1` | Verified Boss-slot Source A art | Asset and clip frames are verified; no CARE B3 Boss event maps to it yet. |

The atlas maps V5 `stand`, `run`, `attack1`, `hit`, and `dead` clips to presentation `idle`, `walk`, `attack`, `hit`, and `die` routes. Actual imported atlas regions for the active disciple/monster routes and Boss-slot asset are checked by `b3_care_combat_v5_presenter_test.gd`. A normal B3 pilot does not create a Boss or AoE event; Boss/AoE gameplay presentation remains pending an authoritative CARE event.

## Boundaries and pending acceptance

- Source A/map/actor art passes import/hash-gate checks but remains subject to owner visual approval and the asset manifest's project-use boundary.
- The current P3.2 pilot demonstrates one selected authentic V2 disciple versus the existing B3 monster. No six-disciple test roster is spawned.
- GUI Movie Maker evidence is scripted in-engine capture, not manual mouse/touch acceptance.
- Windows manual interaction, Android device/touch, final owner visual acceptance, and FULL/CI remain pending/not run.
- PR #24 and PR #25 remain separate draft PRs and are not modified or merged by this branch.

See `docs/handoffs/2026-10-24/TMB_MASTER_RECOVERY_REGRESSION_CHECKLIST_2026-10-24.md` and `outputs/MASTER_RECOVERY_INTEGRATION_20261023/MASTER_RECOVERY_EVIDENCE_REPORT.md` for exact logs, source inventory, screen comparison, and outstanding gates.
