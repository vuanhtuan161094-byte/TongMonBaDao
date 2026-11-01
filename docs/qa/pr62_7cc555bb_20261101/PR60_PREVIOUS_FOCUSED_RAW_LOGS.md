# PR #60 focused raw logs — previous exact-SHA run

Exact SHA: 074ca829d2d35a559c445edba17c5e1f9d1dc937. These are the earlier headless import/smoke/focused runs, not GUI evidence. Local absolute paths and account name were redacted; no save data is included.

## pr60_074ca829_import.stdout.log

Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

[   0% ] [90m[1mfirst_scan_filesystem[22m | Started Project initialization (5 steps)[39m[0m
[   0% ] [90m[1mfirst_scan_filesystem[22m | Scanning file structure...[39m[0m
[  16% ] [90m[1mfirst_scan_filesystem[22m | Loading global class names...[39m[0m
[  33% ] [90m[1mfirst_scan_filesystem[22m | Verifying GDExtensions...[39m[0m
[  50% ] [90m[1mfirst_scan_filesystem[22m | Creating autoload scripts...[39m[0m
[  66% ] [90m[1mfirst_scan_filesystem[22m | Initializing plugins...[39m[0m
[  83% ] [90m[1mfirst_scan_filesystem[22m | Starting file scan...[39m[0m
[92m[ DONE ][39m [1mfirst_scan_filesystem[22m
[0m
[   0% ] [90m[1mloading_editor_layout[22m | Started Loading editor (5 steps)[39m[0m
[   0% ] [90m[1mloading_editor_layout[22m | Loading editor layout...[39m[0m
[  16% ] [90m[1mloading_editor_layout[22m | Loading docks...[39m[0m
[92m[ DONE ][39m [1mloading_editor_layout[22m
[0m

----- END LOG -----

## pr60_074ca829_import.stderr.log

(empty; original file was 0 bytes)

----- END LOG -----

## pr60_074ca829_c2_smoke.stdout.log

Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

DAN_TIEN_C2_SMOKE_PASS new_game_birth=1 bounded_queue=100_days paid_debit=0 ui=1

----- END LOG -----

## pr60_074ca829_c2_smoke.stderr.log

(empty; original file was 0 bytes)

----- END LOG -----

## pr60_074ca829_dv2_01_birth_distribution_test.stderr.log

(empty; original file was 0 bytes)

----- END LOG -----

## pr60_074ca829_dv2_01_birth_distribution_test.stdout.log

Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

DV2-01B 100K FULL INNATE BIRTH DISTRIBUTION TEST PASS
roots=[6879, 18066, 30016, 28080, 16959] traits=[59903, 32200, 7897] latent=7986 blood=1969 physique=2994 fate=491 mutation=210 awakened=8

----- END LOG -----

## pr60_074ca829_dv2_01_birth_envelope_test.stderr.log

(empty; original file was 0 bytes)

----- END LOG -----

## pr60_074ca829_dv2_01_birth_envelope_test.stdout.log

Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

DV2-01B OPT-IN FULL INNATE BIRTH TEST PASS

----- END LOG -----

## pr60_074ca829_gp_02c1_injury_settlement_test.stderr.log

ERROR: GP-02C1: incompatible saved PvE: legacy_participant_occupation_conflict detail=
   at: push_error (core/variant/variant_utility.cpp:1023)
   GDScript backtrace (most recent call first):
       [0] from_dict (res://src/simulation/state/simulation_state.gd:440)
       [1] _legacy_terminal_and_fail_closed (res://tests/simulation/gp_02c1_injury_settlement_test.gd:239)
       [2] _run (res://tests/simulation/gp_02c1_injury_settlement_test.gd:86)

----- END LOG -----

## pr60_074ca829_gp_02c1_injury_settlement_test.stdout.log

Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

GP-02C1 SETUP PASS
GP-02C1 T01 PASS
GP-02C1 BEGIN PASS
GP-02C1 HP_OWNER PASS
GP-02C1 T13 PASS
GP-02C1 T07 PASS
GP-02C1 HP_ISOLATION PASS
GP-02C1 T02 PASS
GP-02C1 T03 PASS
GP-02C1 T05 PASS
GP-02C1 T06 PASS
GP-02C1 RELEASE PASS
GP-02C1 SETUP_RETREAT PASS
GP-02C1 RETREAT_BEGIN PASS
GP-02C1 T04 PASS
GP-02C1 SAVE_SETUP PASS
GP-02C1 DEFEAT_BEGIN PASS
GP-02C1 T09 PASS
GP-02C1 NO_LOOT PASS
GP-02C1 SAVE PASS
GP-02C1 RECEIPT_SAVE PASS
GP-02C1 RECEIPT_LOAD PASS
GP-02C1 T23 PASS
GP-02C1 LEGACY_SETUP PASS
GP-02C1 T22 PASS
GP-02C1 LEGACY_ACTIVE_SETUP PASS
GP-02C1 LEGACY_ACTIVE_BEGIN PASS
GP-02C1 LEGACY_ACTIVE_SAVE PASS
GP-02C1 LEGACY_ACTIVE_LOAD PASS
GP-02C1 LEGACY_ACTIVE_OWNER PASS
GP-02C1 LEGACY_ACTIVE_OWNER PASS
GP-02C1 LEGACY_ACTIVE_GUARD PASS
GP-02C1 LEGACY_ACTIVE_RESUME PASS
GP-02C1 LEGACY_ACTIVE_FINISH PASS
GP-02C1 LEGACY_TERM_SETUP PASS
GP-02C1 LEGACY_TERM_BEGIN PASS
GP-02C1 LEGACY_TERM_SAVE PASS
GP-02C1 LEGACY_TERM_LOAD PASS
GP-02C1 LEGACY_TERM_SETTLE PASS
GP-02C1 LEGACY_TERM_119 PASS
GP-02C1 LEGACY_TERM_120 PASS
GP-02C1 LEGACY_CONFLICT_SETUP PASS
GP-02C1 LEGACY_CONFLICT_BEGIN PASS
GP-02C1 LEGACY_FAIL_CLOSED PASS
GP-02C1 LEGACY_WIN_MAP PASS
GP-02C1 LEGACY_WIN_BEGIN PASS
GP-02C1 LEGACY_WIN_REAL PASS
GP-02C1 LEGACY_WIN_SAVE PASS
GP-02C1 LEGACY_WIN_RECEIPT PASS
GP-02C1 LEGACY_WIN_RESUME PASS
GP-02C1 LEGACY_WIN_EXACTLY_ONCE PASS
GP-02C1 T15_SETUP PASS
GP-02C1 T15_BUILD PASS
GP-02C1 T15_ASSIGN PASS
GP-02C1 T15_PLANT PASS
GP-02C1 T15 PASS
GP-02C1 T15_TIMER PASS
GP-02C1 T15_PLANT PASS
GP-02C1 T15 PASS
GP-02C1 T15_TIMER PASS
GP-02C1 T15_HERBS PASS
GP-02C1 T15_HALL PASS
GP-02C1 T15_RECIPE PASS
GP-02C1 T15_ALCHEMY PASS
GP-02C1 WORK_SETUP PASS
GP-02C1 MINE_ASSIGN PASS
GP-02C1 WORK_START PASS
GP-02C1 T14 PASS
GP-02C1 BODY_RESERVE PASS
GP-02C1 T16 PASS
GP-02C1 BODY_RELEASE PASS
GP-02C1 WORK_PVE_BEGIN PASS
GP-02C1 T17 PASS
GP-02C1 WORK_DEFEAT PASS
GP-02C1 T18 PASS
GP-02C1 T18_WORK PASS
GP-02C1 T19 PASS
GP-02C1 T20 PASS
GP-02C1 OFFLINE_SETUP PASS
GP-02C1 OFFLINE_DEFEAT PASS
GP-02C1 OFFLINE_SAVE PASS
GP-02C1 T21 PASS
GP-02C1 OFFLINE_REPEAT PASS
GP-02C1 REAL_MAP PASS
GP-02C1 REAL_BEGIN PASS
GP-02C1 T12 PASS
GP-02C1 T12B PASS
GP-02C1 REAL_WIN PASS
GP-02C1 T08 PASS
GP-02C1 REAL_RELOAD PASS
GP-02C1 WIN_RESUME PASS
GP-02C1 T08B PASS
GP-02C1 T10 PASS
GP-02C1 T11 PASS
GP-02C1 T01-T23 FOCUSED TERMINAL/RECOVERY/COMPATIBILITY PASS

----- END LOG -----

## pr60_074ca829_hs09_disciple_profile_test.stderr.log

(empty; original file was 0 bytes)

----- END LOG -----

## pr60_074ca829_hs09_disciple_profile_test.stdout.log

Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

HS09 DISCIPLE PROFILE / DUAL RADAR / FEATURE-GATE READ MODEL PASS

----- END LOG -----

## pr60_074ca829_p0_save_roundtrip_test.stderr.log

ERROR: SaveService: malformed save payload for version 4.
   at: push_error (core/variant/variant_utility.cpp:1023)
   GDScript backtrace (most recent call first):
       [0] _load_exact (res://src/simulation/save/save_service.gd:243)
       [1] load_from_path (res://src/simulation/save/save_service.gd:192)
       [2] _test_invalid_payload_rejection (res://tests/simulation/p0_save_roundtrip_test.gd:72)
       [3] _run (res://tests/simulation/p0_save_roundtrip_test.gd:41)
ERROR: SaveService: invalid negative save version -1.
   at: push_error (core/variant/variant_utility.cpp:1023)
   GDScript backtrace (most recent call first):
       [0] _load_exact (res://src/simulation/save/save_service.gd:215)
       [1] load_from_path (res://src/simulation/save/save_service.gd:192)
       [2] _test_invalid_payload_rejection (res://tests/simulation/p0_save_roundtrip_test.gd:79)
       [3] _run (res://tests/simulation/p0_save_roundtrip_test.gd:41)

----- END LOG -----

## pr60_074ca829_p0_save_roundtrip_test.stdout.log

Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

P0 SAVE ROUNDTRIP TEST PASS
tick=3000 money=1630 disciples=6

----- END LOG -----

## pr60_074ca829_p1_2_recruitment_test.stderr.log

(empty; original file was 0 bytes)

----- END LOG -----

## pr60_074ca829_p1_2_recruitment_test.stdout.log

Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

P1.2 RECRUITMENT + PLAYER CHOICE TEST PASS
seed=616161 ticks=1200 disciples=8 capacity=8 accepted=2 rejected=1

----- END LOG -----

## pr60_074ca829_p2_7_workforce_test.stderr.log

(empty; original file was 0 bytes)

----- END LOG -----

## pr60_074ca829_p2_7_workforce_test.stdout.log

Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

P2.7 DISCIPLE LIFE + WORKFORCE TEST PASS

----- END LOG -----

## pr60_074ca829_p3_7c1_foundation_guidance_test.stderr.log

(empty; original file was 0 bytes)

----- END LOG -----

## pr60_074ca829_p3_7c1_foundation_guidance_test.stdout.log

Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

P3.7C1 FOUNDATION + DAN TIEN RECRUITMENT TEST PASS

----- END LOG -----

## pr60_074ca829_save_service_async_roundtrip_test.stderr.log

(empty; original file was 0 bytes)

----- END LOG -----

## pr60_074ca829_save_service_async_roundtrip_test.stdout.log

Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

SAVE SERVICE ASYNC ROUNDTRIP PASS checks=10 snapshot_isolated=true joins_before_sync=true prior_backup_valid=true

----- END LOG -----

