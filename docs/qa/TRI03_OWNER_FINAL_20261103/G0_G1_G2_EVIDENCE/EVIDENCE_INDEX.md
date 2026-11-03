# TRI-03 — G0 → G1 → G2 evidence (2026-11-03)

**PR #67 remains Draft and unmerged.** Code commit: [36532c39f294e1eb56d73d8ce0c0eb7cb68c5567](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/36532c39f294e1eb56d73d8ce0c0eb7cb68c5567), parent live HEAD `c136600f5579871d476e0feca2d78ea3c74e6b1f`. The exact code tree SHA is `bfc1f92da8d79aab3963c8b7e6a6502c348cfdd2`.

## Acceptance status

| Gate | Result | Evidence and remaining limit |
|---|---|---|
| G0 Save/Reload | **Focused regression PASS; full exact-SHA suite PENDING** | Async SaveService, P0 roundtrip, DD07 recovery and a two-process reload passed on the Windows source overlay. The prior owner checkpoint’s 14/14 is historical, not claimed for this new SHA. |
| G1 New Game/build/recruit | **Automated windowed flow PASS** | Real 1280×720 Godot UI flow paid for a second Residence, blocked an occupied plot, recruited a real candidate, showed HS-09/profile, assigned, saved, and reloaded in a separate Godot process. UI input was harness-injected, not physical mouse. |
| G2 visual/UI | **Windowed capture and focused contract PASS; owner acceptance PENDING** | Three live facility screens and the New Game flow captured at 1280×720. Source A buildings are unchanged and hash-checked. Generated UI icon art is labeled separately and awaits owner approval. |
| Physical play / Android | **PENDING** | Windows UI bridge did not expose the running Godot window; Android device/touch was not tested. |

The Godot checks exercised the current local Windows source overlay at local Git HEAD `27ed01cd8f377994e5e50bac9ede84e78e8895bd`. Its 49 runtime-manifest blobs were independently compared with the code commit tree: **49/49 match**. This is file-level exact-source evidence, not a clean checkout/run of Git HEAD `36532c39f294e1eb56d73d8ce0c0eb7cb68c5567`. The local worktree still contains unrelated dirty/generated QA files and was not reset or cleaned.

The normal Windows launcher verified the overlay, imported the project using official Godot `4.7.2.stable.official.ed1daf0bf`, and opened a responsive window (PID 13624, title `Tong Mon Ba Dao (DEBUG)`). The game process remains open for the owner. The owner save/default profile was not accessed; New Game Save/Reload used the isolated QA profile recorded in `SOURCE_MANIFEST.json`.

## Changes in this checkpoint

- New Game can build a freely selected second Residence using canonical material and currency costs; occupied-actor plots are rejected. The accepted test cost was 40 Linh Mộc, 30 Thanh Thiết, 500 Linh Thạch, 60 ticks.
- Candidate flow uses real candidate data, shows a recruit profile and six canonical stat axes (not a seventh Tâm Tính axis), accepts the disciple, assigns the worksite and survives process-independent reload without duplicate construction receipt.
- Hall, Residence and Dẫn Tiên B1 screens share pictorial UI icon treatment; 16 icons come from an **original generated atlas**, not Source A. Provenance and SHA-256 are included.
- Updated status copy in P3.2 build UI; hidden legacy host surface stays hidden while B1 is active.
- Source A building models 510052 / 510076 / 510111 were not modified; their original SHA-256 values are listed below and in the source manifest.

## Before / after — 1280×720 Godot renders

| Screen | Before | After |
|---|---|---|
| Đại Điện | [PNG](screenshots/before/hall.png) | [PNG](screenshots/after/hall.png) |
| Đệ Tử Xá | [PNG](screenshots/before/residence.png) | [PNG](screenshots/after/residence.png) |
| Dẫn Tiên Đài | [PNG](screenshots/before/guidance.png) | [PNG](screenshots/after/guidance.png) |

## New Game flow frames

- [P3.2 map](screenshots/gameplay/00_new_game_map.png)
- [Build catalog](screenshots/gameplay/01_build_catalog.png)
- [Occupied-actor plot rejected](screenshots/gameplay/02_occupied_plot_rejected.png)
- [Paid second Residence construction](screenshots/gameplay/03_paid_second_residence.png)
- [Real recruited HS-09 profile](screenshots/gameplay/04_recruited_hs09_profile.png)
- [Assigned disciple ready](screenshots/gameplay/05_assignment_ready.png)

## Test and raw-log artifacts

- [Test matrix with exit codes](TEST_MATRIX.csv)
- [Filtered raw Godot log excerpts](RAW_LOGS_FILTERED.txt)
- [Source manifest, file pins and asset SHA-256](SOURCE_MANIFEST.json)

No SaveService authority, Combat V2, PvE, economy rules, or Source A master art were changed. Known non-blocking issue: Windows Godot stderr reports `Failed to read the root certificate store` even though import/tests/launcher pass; certificate validation was not disabled. The initial DD092 invocation used a stale test path (exit 1); the corrected test path then exited 0 with the expected PASS marker. The icon alpha test also emits Godot’s test-only `Image.load` export warning.

## Still required before calling owner acceptance complete

1. Run the full G0 14-case suite and focused matrix from a clean checkout at code commit `36532c39f294e1eb56d73d8ce0c0eb7cb68c5567`.
2. Let the owner use the visible game with physical mouse input for construction, facility navigation and Save/Reload; the app UI bridge could not target the current Godot window.
3. Obtain owner visual/art approval for generated icons; test Android landscape/touch separately.
4. Re-check Save/Reload and no duplicate receipt from that clean checkout; do not use the owner’s default save for QA.
