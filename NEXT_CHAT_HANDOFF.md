# NEXT CHAT / CODEX HANDOFF — RELEASE TRAIN PR #72 → MAIN (2026-11-04)

## CURRENT SX-07B HANDOFF — 2026-11-09

- Repo: `vuanhtuan161094-byte/TongMonBaDao`, branch `integration/pve-p0-playable-ui-20261103`, PR #72 DRAFT. Baseline `c80457834fc7eeb5534441cdfab9fae0fddded56`; source code SHA `cc389cee15a57c44e4c03f223a954f1d503f6f95`; no branch, main merge, Save/schema change or VFX/equipment/technique edits.
- **Implemented, not Godot-accepted:** registered five previously preserved V5.5-D material IDs; Mine + Forest per-building output selection, real canonical timed/carry job payment/XP/warehouse and frozen-save behavior; source read-model and validators updated; focused transaction test + workflow trigger.
- **Blocked intentionally:** GUI source picker not in authorized file allowlist; do not enable V5.6-G substitutions of Xích Đồng/Thanh Trúc/Thanh Trúc Mộc into existing pills until selectable through legitimate player command. Old eight pilot recipes remain. 111/119 recipes still DESIGN_HOLD.
- **Counts:** 11/630 current runtime overlap (previous six plus five), 619 missing (112 preserved V5.5-D, 507 proposed/unrecovered), 270/270 G profiles not instantiated. Do not claim restored V5.4 source originals. See `docs/qa/SX07B_PRESERVED_MATERIALS_SOURCE_GATE_20261109.md`.
- **Required tests exact HEAD:** import official 4.7.2; `sx07b_preserved_source_job_test.gd`, `sx07_source_provenance_test.gd`, `sx02_medicine_catalogue_test.gd`; affected `production_exp_upgrade_contract_20261107_test.gd`, `p3_o7_linh_forest_test.gd`, `v57_paid_producers_body_market_test.gd`, `sx02_medicine_runtime_test.gd`, SaveService cold reload. At writing: no official runtime test output, **QA PENDING**.
- Next work options (user approval): SX-07C wire existing mine/forest selection UI and activate only source-proven G BOM; official focused QA and repair; or source provenance recovery from primary V5.4. All Windows mouse/Android physical acceptance = **PENDING USER**.


## ACTIVE OWNER DIRECTIVE — SX-07 CONTINUATION (2026-11-09)

**Latest approved scope supersedes older R2-start priority for the active authoring packet; R2–R5 release requirements remain open.** Code baseline `c05b1aac9ffe186ebefe56395dfa4ec6abfe6556`. See `CURRENT_CHECKPOINT.md` SX-07 section for precise status and files.

- DONE as CODE, **NOT RUNTIME PASS**: fix premature empty recipe definitions, add Mine/Forest/paid NPC provenance, fail-closed source gate for graded jobs, early realm-1 Body BOM alignment, read-only price/quantity oracle, updated 476/8 historic test and new 8/111/32-QA focused source test.
- DESIGN GAP: 624/630 proposed materials not in runtime registry; 270/270 V5.6-G source profiles are NOT live job sites; 111 recipe definitions still blocked, and 507 proposed new names lack recovered V5.4 source. Eight out-of-630 Body materials exist in runtime but their design BOM origin must be reconciled.
- NEXT PERMITTED WORK ONLY AFTER OWNER CHOICE: (A) SX-07B trace original IDs and implement validated source slices into real work jobs/PvE loot with deterministic Save receipts, or (B) SX-08 audit LT2/T2/W2 without enabling fictional sources, or (C) focused Godot 4.7.2 QA for current code. No gear, techniques, separate gameplay branch or merge.
- PRECISE TESTS: `godot --headless --path godot --import`, then `--script res://tests/simulation/sx07_source_provenance_test.gd`, `sx02_medicine_catalogue_test.gd`, `v57_sx_contract_guard_test.gd`, `sx02_medicine_runtime_test.gd`; affected Building/Field/Save regression and 1280×720 GUI remain pending. Never mark PASS unless official execution has exit 0 and exact SHA.
- Windows E: original backups, saves and launcher remain untouched. Windows GUI / Android = **PENDING USER**.


## MASTER BACKLOG INTAKE — 2026-11-06

The owner prompt/workbook are now available and hash-identified in [input status](docs/qa/PR72_MASTER_QA_20261106/INPUTS_STATUS.md). The full [requirement register](docs/qa/TMB_PR72_REQUIREMENT_REGISTER_20261106.md), [158-case matrix](docs/qa/TMB_PR72_FEATURE_ACCEPTANCE_MATRIX_20261106.csv), and [10 E2E journeys](docs/qa/TMB_PR72_E2E_JOURNEYS_20261106.md) retain 35 requirements, 158 cases in 18 systems, 10 journeys, and 15 source gaps. Matrix source fidelity check: all 158 rows × 11 original columns matched the workbook (0 mismatches); five execution fields are additional.

- PR #72 branch: `integration/pve-p0-playable-ui-20261103`; live HEAD at intake `857ce164442a3a845d554b6ab1315abf92c85281` (Draft; no merge/new branch).
- Runtime/test evidence SHA `5ef179b81dfef6f2d72a38d866e94fc828e179eb`; focused P3.2/density/P3.4B/O3 source SHA `374f2d47d887c828218e3a296b6c8370aff070e7`; production runtime files are unchanged across that later test/manifest-only delta.
- Matrix annotations: 11 `PASS_HEADLESS`, 2 `PASS_GUI_HARNESS`, 9 `IN_PROGRESS`, 136 `CHUA_NGHIEM_THU`. E2E: six `IN_PROGRESS`, two `BLOCKED_SOURCE`, two `CHUA_NGHIEM_THU`; complete E2E PASS 0/10.
- Gate A (P0 playable) is **not accepted**: the three-process isolated R3 headless save journey has logs, but native owner-session GUI/physical mouse is pending and this is not the full continuous player journey. Gate B is partial: logged focused regression evidence exists, but not the complete 158-case regression. Gate C source/design gaps stay open; Gate D viewport harness frames are not physical acceptance; Gate E full cumulative regression is not complete.
- No production/runtime code or player save changed in the master-register update. The existing running Godot PID 16616 was left untouched.

Continue from the unmet cases in the register; do not repeat passing tests unless their code/input changed, and do not relabel harness evidence as physical GUI PASS.

**Không tiếp tục trên PR #52, #67, `one-game-v65` hoặc các SHA tháng 10.** Các hướng dẫn cũ được bảo tồn trong [bản archive](docs/archive/checkpoints/NEXT_CHAT_HANDOFF_LEGACY_PRE_RELEASE_TRAIN_20261104.md), **không còn hiệu lực để thực thi**. Đọc [Issue #56 — live R0–R5](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56), [PR #72](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72) và [canonical release register](docs/operations/TMB_ONE_GAME_RELEASE_TRAIN_CANONICAL_20261104.md).

## Mục tiêu

One game, one authority, one final `main`, one working launcher. **Không tạo PR/branch gameplay song song.** Chỉ PR #72 là source candidate; hiện là Draft, chưa merge. PR #67 là ancestor/base của #72; không merge lặp. 43 PR cũ đã đóng hành chính, không xóa code/branch; còn 18 PR tại checkpoint 2026-11-04.

## Bắt đầu công việc (thứ tự bắt buộc)

1. **R0 ĐÃ PASS:** 196 source working items và 94 save được sao lưu + hash xác minh trong `E:\\TongMonBaDaoWorkspace\\90_Archive\\TMB_R0_BACKUP_20261104_145049`; manifest `EA753053E1DFBFD490E725C7FDD86B26FF565EA4BB10920805AA74571EDEF509`. Giữ nguyên backup, không reset/clean/overwrite.
2. **R0 ĐÃ PASS — 14 PR đã phân loại** trên ma trận mới (PORT/SUPERSEDED/DESIGN_HOLD); không lặp kiểm toán chỉ vì PR cũ còn open. Old details: Classify each `PORT_TO_72 | FUNCTIONALLY_SUPERSEDED | ARCHIVE_ONLY`. Old economy/workforce #2/#6/#7/#8/#9/#10/#12/#14/#16/#17/#18/#19/#20 and #66 B1 UI remain open for behavior parity/decision. Combat/PvE #29/#30/#46/#47, SX JSON #61 and Hall #64 were closed administratively after source/test review; #46 clock/save diagnostic test remains QA debt. Archived references #13/#53/#55 and unique QA/tests #34/#44/#45/#48/#50/#59 remain available at R1/R4. See `docs/operations/TMB_PR72_FUNCTION_PARITY_MATRIX_20261104.md`. Animation labs #71/#74 remain experimental until Owner Visual + QA; #68/#69 PRs are closed, branches retained.
3. **R1 ĐÃ PASS trong phạm vi canonical:** code/test SHA `b56b6fe8fa29ae663994a65098a56b60c3b42513`; Godot 4.7.2 import + 19 tests = 20/20 exit 0. D7 đã hiển thị Tam Căn(3)+Tứ Tính(4). Luật Economy bulk/cap/FoundationGrowth cũ chưa duyệt vẫn DESIGN_HOLD, không đưa vào release tự động.
4. **R2 — START NOW:** follow [Owner continuous R2→R5 task](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72#issuecomment-6627064335), investigate `ig11icd64.dll`, process overlap and real `CHOI-GAME.cmd` → `Start-TRI03Game.ps1` lifecycle. `godot/project.godot` **already uses `gl_compatibility`**, switching to the same renderer is not a fix. Verify three sequential clean opens/GUI/exits and fingerprint without bypass.
5. **R3 — one QA save full journey:** New Game → Housing → real recruit → Mine → Warehouse → solo + join/withdraw PvE → kill receipts/real Tu Vi+Luyện Thể+loot → Save/Exit → independent cold Reload → continue, no duplicate.
6. **R4 — release QA:** Godot 4.7.2 official regression + actual 1280×720 Windows GUI mouse/screens; do not call headless injected input human/physical acceptance.
7. **R5 — final merge** only after required gates PASS: preserve `main`'s divergent `AGENTS.md`, retarget PR #72 to `main` safely, merge once, test exact post-merge SHA, tag release, finalize Windows launcher. Close remaining obsolete PRs with detailed reasons but do not delete branches without separate decision.

## What is known at exact evidence SHA

- PR #72 prior code SHA `e92ef09fc2c9b2ccb870910577b295881ccc6527`, evidence commit `e888c010d6cfb09a97ce48af19d1a2f42a401240`; later documentation commits exist, **fetch live HEAD**.
- Import + 14 focused Godot suites 15/15 exit 0; simulated PvE 20 camps/30 hunters/40 active monsters/200 slots PASS; natural solo 10 kills/10 receipts, XP+materials, generation2, cold reload PASS.
- **Windows GUI NOT ACCEPTED:** second launcher run crash `signal 11` in Intel `ig11icd64.dll` at GLES3 init; PID blocked; real mouse, one-save full loop and Android PENDING. `main` remains unchanged.
- **Do not stop between R2/R3/R4/R5 for routine approval.** Codex R0/R1 has a verified Windows E backup and patched game UI; those earlier doc-only statements are superseded. Do not claim Windows PLAYABLE/Android/main merge without actual evidence.

## Reporting contract

After each gate: `Gate / branch / code SHA / changed paths / Windows E backup manifest / Godot build / tests PASS-FAIL / GUI actual vs injected / screenshots/logs / blocker / next action`; report in [Issue #56](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56) and PR #72. **Do not substitute another checklist or open new status-only PRs.**
