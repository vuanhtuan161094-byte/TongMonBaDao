# Packet B — PR28 + Combat V3-S1 end-to-end integration

**Status:** focused code and automated P3.2 GUI acceptance PASS on `4b02a0c61a2771d9d4638129d96b68ad292270dc`. Human Windows, Android, sustained performance, and Owner Visual acceptance remain PENDING. The new integration PR must remain draft; no merge, FULL, or CI run was performed.

## Branch and ancestry

- Repository: `vuanhtuan161094-byte/TongMonBaDao`.
- Branch: `integration/pr28-combat-v3-s1-playable-qa-20261024`.
- PR28 base: `e9190f490ebea82d2badf7f3fc44b34dd24bd425`.
- Integration checkpoint: `35db75aed9e39924194a9996ab8e584f2f7b9e1e`, tree `3c59574d914f57276ca5a1dba5a0802838d02a5d`.
- Final code/test SHA: `4b02a0c61a2771d9d4638129d96b68ad292270dc`, tree `352700b65d3cd0ef7039df22a1153d81b2fd7b82`; parent is `35db75a…`.
- The follow-up code commit only strengthens the P3.2 capture harness: it recruits a real V2 candidate, uses canonical cultivation/rest/breakthrough actions in the isolated acceptance state to reach existing skill eligibility, then captures live S1 statuses. It does not change runtime/gameplay authority.
- PR #28/#29/#30 remain OPEN / DRAFT / UNMERGED and their branches were not edited. The new draft PR is stacked on `ui/pr27-runtime-readability-20261024`.

## Scope and runtime authority

P3.2 continues to use its existing `runtime_session`, `SimulationState`, `SimulationRuntimeOwnerV2`, B3HuntWorld, B3MedicalAutoplayV1, Combat V2, canonical Warehouse, and SaveService. Combat V3-S1 statuses and combat remain authoritative in the existing `MapBattleV2` state and clock. The Source A V5 presenter reads real state/events for visuals and HUD; it creates no second clock, combat authority, damage, status, reward, Warehouse, or save system.

The integration changes nine code/test files from the PR28 base:

1. `godot/src/presentation/p3/b3_care_combat_v5_presenter.gd` — read-only live burn/weaken/learned-guard, action, and damage feedback.
2. `godot/src/presentation/p3_2_landscape_sect.gd` — connect the presenter to the existing P3.2 CARE view.
3. `godot/src/simulation/combat/disciple_combat_loadout_v2.gd` — QA-cleared PR30 S1 loadout validation.
4. `godot/src/simulation/combat/map_battle_snapshot_v2.gd` — QA-cleared PR30 snapshot validation.
5. `godot/src/simulation/combat/map_battle_v2.gd` — QA-cleared PR29/PR30 S1 status and cadence logic.
6. `godot/tests/presentation/tmb_master_v3_current_capture.gd` — real P3.2 workflow capture; the follow-up adds canonical cultivation setup and live Weaken/guard frames, with no fabricated combat event or reward.
7. `godot/tests/presentation/pr28_s1_combat_status_presenter_test.gd` — focused presenter contract.
8. `godot/tests/simulation/combat_v3_s1_effects_test.gd` — focused S1 effects contract.
9. `godot/tests/simulation/combat_v3_s1_edge_contract_test.gd` — S1 edge contract, including 56 checks.

No CARE, economy, scheduler, Warehouse, SaveService, Injury120, Source A art, or other locked gameplay subsystem was changed. No S2, Boss behavior, or ×100 rebalance was added.

## Godot 4.7.2 focused verification

Official engine: Godot `4.7.2.stable.official.ed1daf0bf`; console executable SHA-256 `ab1824f85bfd8e0e4128182c000c4003a3e042245b2967848d089b2a04b22424`.

- Exact focused matrix after the final code SHA: **28/28 PASS**, all process exits 0, each on separate userdata. O9 production rehearsal is included and PASS.
- `combat_v3_s1_edge_contract_test.gd`: **56 checks PASS**.
- No parse or assertion failures were recorded. Windows output includes `Failed to read the root certificate store`; it is an environment diagnostic and did not affect results.
- Raw logs, per-test CSV, and the reproducible runner are under [`evidence/packet-b/sha4b02`](evidence/packet-b/sha4b02/).
- GitHub Actions was not run. FULL/CI was not run.

## Real P3.2 gameplay capture

The exact-SHA GUI capture opened `res://scenes/p3/p3_2_landscape_sect.tscn` at 1280×720 in Godot 4.7.2 using the Intel Iris Plus OpenGL compatibility renderer. The driver emitted **19 captured runtime frames** and a source-SHA/state manifest. All frames are in [`screenshots/`](evidence/packet-b/sha4b02/screenshots/); the Godot log is [`p3_2_packet_b_capture_sha4b02.log`](evidence/packet-b/sha4b02/logs/p3_2_packet_b_capture_sha4b02.log).

| Live state | Recorded result |
|---|---|
| Source A sect map, camera pan/zoom, Mine, Linh Lâm, Linh Điền, and Warehouse | P3.2 captures `00`–`05` at 1280×720. |
| Real production settlement | `mine_001`, worker `trieu_linh_nhi`, phases `travel_out → mining → haul_back`; canonical `thanh_thiet` stock 37 → 39 (+2). Capture `08`. |
| Real V2 profiles | Canonical ordinary recruits `candidate_73025` male and `candidate_73021` female. Captures `06` and `07`. |
| Combat V5 presentation of CARE | Real hunter `candidate_73025`, same P3.2 runtime, AUTO on; world `b3:vs1:bach_thach_khe:31012026:60`. Capture `09`. |
| Damage and S1 burn | Live Hỏa Cầu cast/hit applied burn to the actual Thanh Lang; HUD displayed `BỎNG`. Captures `10`–`12`. |
| S1 Weaken | The real candidate was cultivated by canonical `CultivationSystem.cultivate`, `NeedsSystem.apply_rest`, and successful `attempt_breakthrough` in the isolated acceptance setup (185 cultivation actions, 63 rests, 3 successful breakthroughs; stage 0 → 3). It then learned and cast Hàn Sương Ấn in the CARE battle; `weaken` was active and shown at battle time 5.0s. Capture `13`. |
| Learned guard and expiry | The same real disciple cast Kim Cương Hộ Thể; authoritative guard factor `0.62`, expiry at 13.75s, live HUD showed active at 11.0s and expired at 14.0s. Captures `13b` and `13c`. |
| Loot, respawn, return | Actual Thanh Lang kill committed one canonical `tinh_lang_bi`; same world respawned the monster independently; P3.2 returned to the sect without resetting paid generation. Captures `14`–`16`. |
| Save/Load and exactly-once | SaveService reload matched world ID, paid generation 1, receipt `COMMITTED`, one return, canonical Warehouse stock 1. No duplicate reward. Exact expected/actual values are in the manifest. |

The cultivation setup belongs only to the isolated automated capture fixture. It uses the existing gameplay rules and canonical APIs; it does not add eligibility, statuses, time, or rewards by directly setting fields.

## Source A provenance and measured runtime

No asset pack was recopied or overwritten. The existing 32 environment PNGs and V5 actor files/atlases are hash-listed in [`source_manifest.json`](evidence/packet-b/sha4b02/source_manifest.json). Runtime visual mapping is V2 male `candidate_73025` → Source A actor `v5_sa_male_body_1110201`; V2 female `candidate_73021` → `v5_sa_female_1113028_1`; Thanh Lang → `v5_sa_monster_1113031_1`. Existing stand/walk/attack1/hit/dead clips are used where supplied; no Boss was spawned. Boss-slot art remains catalog-only.

The short screenshot harness observed Engine FPS 1–24 and static engine memory 62.7–73.7 MiB. These are capture-time samples, not a sustained benchmark. Total Windows RAM query was denied; sustained performance and manual responsiveness remain PENDING.

## Windows portable candidate

Godot export templates are absent, so a standalone exported `.exe` could not be produced. A portable Godot project plus one-click launcher is available locally at [`TMB_Playable_Windows_PacketB_4b02.zip`](../../../artifacts/packet_b/windows_candidate/TMB_Playable_Windows_PacketB_4b02.zip): 48,206,898 bytes; SHA-256 `8f912d8c3ede8051f6d238e6aee677d6c64f8ea243368e5460bc99b975bd7ce9`. It includes the updated source tree's capture driver, Godot imported cache and the launcher/README; it does not include the engine binary. The isolated 1280×720 package launch exited 0. Engine logs showed only the Windows certificate-store diagnostic and a non-fatal shader-cache warning; gameplay capture and focused tests are unaffected. The launcher isolates saves under `userdata/` and requires no Administrator permission.

This is automated GUI evidence, not a human mouse session. Human Windows mouse acceptance, Android touch/device acceptance, sustained performance, and Owner Visual approval remain PENDING.

## Acceptance matrix and remaining work

- Integrated code and focused tests: **PASS** at `4b02a0c…`.
- Real P3.2 Mine → V2 disciple → CARE Combat V2 presented by V5 → S1 burn/Weaken/guard → paid loot → same-world respawn → return → SaveService round trip: **PASS** in the automated exact-SHA capture.
- Human Windows playtest, Android device/touch, sustained performance, Owner Visual: **PENDING**.
- Standalone exported Windows executable: unavailable because export templates are absent; portable Godot project package is provided and smoke-launched.
- PR state: new integration PR remains draft; no merge. PR #28/#29/#30 remain untouched. No FULL/CI.

A separate headless-editor import scan completed its filesystem scan with exit 0 and no script parse failures, but Godot logged an editor-only settings save error (Can't save resource to empty path) for that isolated editor profile. It is retained in the evidence and is not counted as a clean Editor-settings smoke; the regular packaged game launch exited 0.
