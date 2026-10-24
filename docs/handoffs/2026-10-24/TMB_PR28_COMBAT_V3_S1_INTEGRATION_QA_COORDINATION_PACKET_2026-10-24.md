# TÔNG MÔN BÁ ĐẠO — PR28 x COMBAT V3-S1 INTEGRATION QA COORDINATION
Date: 2026-10-24 (Asia/Bangkok)
STATUS: **COORDINATION/DESIGN ONLY**; not an integration build, not a QA pass.
Owner instruction: Option A. Keep PR28 stable; review isolated S1 QA branch; document dev-save policy; analyze Actions; prepare integration QA branch packet, **execute only after S1 focused gates PASS**.

## 0. Source of authority & exact snapshot

Read before CODE: AGENTS.md, docs/GAME_SYSTEM_ARCHITECTURE.md, CURRENT_CHECKPOINT.md, NEXT_CHAT_HANDOFF.md, active PR reports, and this coordination packet.

Repo: vuanhtuan161094-byte/TongMonBaDao
Engine: official Godot 4.7.2.stable.official.ed1daf0bf
Baseline display target: P3.2 real scene, 1280x720 Android landscape
Canonical authority: SimulationState/CARE/Combat V2, Warehouse, SaveService, injury, scheduler, D7; Source A visual primary.
No full-game rebalance x100, Boss CARE event, S2 dash/fire_combo, or gameplay rearchitecture in this task.

| Workstream | Repo SHA as checked 2026-10-24 04:32+ UTC | Gate |
| --- | --- | --- |
| PR24 B3 CARE | 4d08984f044bfa29a98070c8d68ee5a155256d3a | DRAFT, unmerged |
| PR25 CARE P3.2 main | 710137c0e3976e685613a86692e5eb128b8d3c62 | DRAFT, unmerged |
| PR26 map/Source A recovery | 53ff0b223f4e77ccfbe5c77d2203496ac0cc37a9 | DRAFT, unmerged |
| PR27 D7 foundation base | deeae081bcfbe1413d4cf60a29db7e58150888b5 | DRAFT, unmerged |
| PR28 UI & existing verified Source A | e9190f490ebea82d2badf7f3fc44b34dd24bd425 | DRAFT, 21/21 focused reported PASS at code SHA 47b7042; stable checkpoint |
| PR29 V3-S1 | 9522812e91b7ca5bc0cc108eb92e000e930fe850 | DRAFT; QA PENDING |
| S1 QA repair branch | e51dabc57ce20c294d03a0e9d64ed3ccd1397b3c | 2 commits ahead of PR29 when last compared; QA not yet proven |

Current branch owners:
- UI/asset writer: ui/pr27-runtime-readability-20261024. DO NOT push new code into it through this coordination packet.
- Combat writer: fix/combat-v3-s1-official-qa-20261024. DO NOT touch files while Codex is working.
- Coordination docs writer: docs/pr28-pr29-coordination-20261024. ONLY add documentation under docs/handoffs/2026-10-24.
- **Future integration writer:** one designated Codex worktree on a new branch, after gate; never multiple overlapping writers.

## 1. Fact-finding / conflict matrix

PR28 changed UI presentation only (P3.2, P3.1, Source A view presenter, radar/production cues) plus tests/docs/evidence.
PR29 changed these code files (relative to PR27):
- godot/src/simulation/combat/map_battle_v2.gd
- godot/src/simulation/combat/map_battle_snapshot_v2.gd
- godot/src/simulation/combat/disciple_combat_loadout_v2.gd
- godot/tests/simulation/combat_v3_s1_effects_test.gd (new)
- docs/handoffs/TMB_COMBAT_V3_S1_IMPLEMENTATION_CHECKPOINT_2026-10-24.md

S1 QA fix branch also changes map_battle_v2, map_battle_snapshot_v2, the S1 test and adds combat_v3_s1_edge_contract_test. At check time **no filename overlap between PR28 code presentation files and PR29/fix simulation files**; this is *not* proof their runtime contracts are compatible.

PR28 and PR29 DIVERGE at common merge base PR27 deeae081; PR28 is 19 commits on UI branch and PR29 5 commits on Combat branch at their observed heads. NEVER say one is already stacked on the other.

**Specific behavioral integration risk:** The PR28 B3CareCombatV5Presenter consumes CARE/Combat V2 snapshot and known pilot visual event types. V3-S1 introduces status_applied, status_tick, actor.status_effects with burn/weaken/guard, plus altered fractional basic-attack deadlines. Visual tags/floating damage may not completely explain these new effects; absence of UI tags is a VISUAL GAP, not evidence simulation didn't apply status. Do not modify V3 events to fake visual. Open a separate UI visual-mapping packet only when S1 status/event schema is stable.

**Critical:** PR28 21/21 + 12 real frames verify PR28 exact source, not V3-S1 combined branch. PR29 checkpoint still says focused QA pending and the isolated fix worktree currently has newer unvalidated code. Don't inherit PASS labels.

## 2. Owner's updated dev-save policy (supersedes old migration effort)

REQUIRED SOURCE: docs/handoffs/2026-10-24/TMB_DEV_SAVE_COMPATIBILITY_POLICY_2026-10-24.md

- No mandatory save/snapshot migration between experimental development builds. A new prototype build can require a new profile/restart. Do NOT invest in exact historical in-flight battle trace continuity.
- YES: same-build save/load, deterministic replay while active battle status exists, exactly-once canonical Warehouse/CARE loot, injury and One Active Job, fail-closed corrupt inputs.
- Do not remove current SaveService, delete user saves, weaken existing tests, or rerun old save migrations indefinitely. PR27 D7 migration tests already in mainline branch remain intact; if existing fixture fails, report original result with policy label and owner decision, do not call it PASS.
- Future public release save policy remains UNDECIDED and out of scope.

## 3. Strict gate GATE-S1 — BEFORE integration branch exists

No future integration CODE branch, cherry-pick, or PR should be created until every criterion below is documented for a *specific final S1 fix HEAD*.

1. PR29 base/heads and fix branch latest HEAD fetched and compared; no unexpected files/code outside S1 allowlist.
2. Official Godot 4.7.2 used on isolated userdata, code imported/parsed, exact command+SHA recorded. S1 new focused test plus edge contract test PASS.
3. Run the existing **14-file S1 adjacent focused matrix** in docs/handoffs/TMB_CODEX_PR29_COMBAT_V3_S1_OFFICIAL_GODOT_QA_REPAIR_PROMPT_2026-10-24.md (on docs/combat-v3-s1-pr29-godot-qa-repair-packet-20261024), plus any S1 edge tests. Capture full output, exit 0, matching PASS marker when test defines one, zero parse/assert errors at final HEAD.
4. Verify attack cadence +0/+20/+50/+100, cast speed and cooldown recovery, burn tick/kill exactly-once, weaken outgoing-only, strongest guard, no infinite stacking/tick, S1 snapshot/reload/replay, canonical CARE paid_generation/loot, Injury120, no duplicate reward on re-entry.
5. QA must be on the **final repaired S1 HEAD**, not merely older PR29 head. Before first integration operation compare all changed filenames and latest S1 report.
6. If any test red: stop and classify (S1 code, environment, legacy-dev-policy exception, historical independent red); do not silently drop it to say 14/14 PASS. A policy-exempt old migration failure is not a PASS. Either get owner waiver/decision or keep S1 gate BLOCKED.
7. Current GitHub Actions auto failures remain independently CI_UNKNOWN until source log established; see TMB_GITHUB_ACTIONS_AUTO_TRIGGER_AUDIT_2026-10-24.md. Do NOT use remote CI failure with no logs as proof a deterministic local S1 test failed; equally don't claim CI green from local tests.

OUTPUT required to unlock future work: S1 official QA report in its isolated branch, exact final SHA, per-test result table, dependency file matrix, remaining defects, statement "GATE-S1 PASS (official focused)" backed by evidence. **Until that happens: STOP after docs coordination.**

## 4. Future integration procedure — GATE-INT0 (PLAN ONLY, NOT AUTHORIZED FOR EXECUTION YET)

When S1 gate is genuinely PASS and owner authorizes CODE for this integration packet, the integration owner should:

1. Refresh PR28 HEAD and S1 fix HEAD at operation time, never reuse this stale snapshot as a checkout reference. Verify UI base branch still matches expected PR27 ancestry and that both PR28 and S1 branch contain no surprise files.
2. Create a NEW isolated repo clone/worktree + clean TEMP save profile (do not touch recovery/worker worktrees). Prefer no admin elevation and E: workspace if on the owner's machine; account for 8GB RAM.
3. **Create future branch from PR28 final code HEAD**, proposed name: integration/pr28-combat-v3-s1-qa-20261024. Base exactly PR28 HEAD (not PR27/main/docs branch).
4. Replay ONLY the reviewed S1 net combat code/test commits from PR29 + S1 fixes, in chronological order, via selective cherry-pick or equivalent reviewable patch. Avoid unreviewed changes, unrelated docs, visual binaries, and test downgrades. This is **not** a merge of PR28/PR29, and does not modify either source branch.
5. Record tree hash/commit chain of source and target. Compare PR28 base vs integrated target to ensure only explicitly expected V3-S1 simulation/test changes (plus eventual integration-specific tests/docs) are present. No duplicates in MapBattleV2, registry, or reward authority.
6. On first integration run check P3.2 actually starts, loads Source A, hires real V2 disciple, enters CARE Thanh Lang world, displays actual learned V3 effects if display adapter already handles them, uses same Warehouse and SaveService.
7. **Do not implement missing status UI or repair S1 inside the integration task without separately naming scoped owner/allowlist.** Mark as BLOCKED_VISUAL_CONTRACT or notify current UI owner for an authorized visual follow-up. Avoid two writers on P3.2 or on MapBattleV2.
8. This is a TEMP integration QA review branch only; do not merge source PRs, do not retarget their bases, do not run FULL/CI, do not close source PRs.

## 5. Future integration QA matrix — GATE-INT1

Run actual Godot 4.7.2 official focused tests **on one exact final integration SHA** in isolated user data.

**PR28's 21 actual focused scripts** (read exact contract from docs/handoffs/2026-10-24/evidence/PR28/logs/focused_summary_9f7e1042.csv):
1 d7_foundation_v3_migration_test
2 b3_main_hunt_integration_test
3 b3_fasttrack_hunt_test
4 b3_care_pills_autohunt_test
5 b3_pill_satiety_test
6 b3_ph0_continuous_kernel_test
7 dv2_02_battle_snapshot_test
8 dv2_02_group_map_battle_test
9 dv2_02_five_level_pve_test
10 gp_02c1_injury_settlement_test
11 dv2_03_p3_v2_disciple_profile_test
12 gp_02a_v2_cultivation_panel_test
13 p3_2_map_camera_test
14 p3_1_landscape_shell_test
15 sect_iso_projection_contract_test
16 sect_map25_verified_art_gate_test
17 sect_iso_main_integration_test
18 sect_g1_disciple_radar_test
19 b3_care_combat_v5_presenter_test
20 p3_o9_m2_production_rehearsal_test
21 tmb_pr27_ui_readability_test

**S1 14-file focused adjacent matrix**:
- combat_v3_s1_effects_test
- dv2_02_group_map_battle_test
- dv2_02_battle_snapshot_test
- dv2_02_combat_stats_test
- dv2_02_monster_context_test
- dv2_02_five_level_pve_test
- p2_5_combat_skill_test
- p2_6_equipment_combat_effects_test
- b3_ph0_continuous_kernel_test
- b3_care_pills_autohunt_test
- b3_fasttrack_hunt_test
- gp_02c1_injury_settlement_test
- b3_main_hunt_integration_test
- d7_foundation_v3_migration_test

NOTE: The 14 overlap some PR28 tests; deduplicate scripts by canonical file path, but preserve origin/report labels for both matrices. Include **combat_v3_s1_edge_contract_test** and any additional S1 repair tests. Do not skip Mỏ/O9 just because this is Combat. If any new test is missing on integration, report missing not PASS. Tests may be prioritized by impact (first S1 and CARE, then UI/map/production), but final integrated gate means full *deduplicated* scoped set.

**Separate visual proof** at 1280x720 from REAL P3.2:
- sect main, free pan+zoom and restored camera; Mine/Forest/Field real job labels, canonical Warehouse; D7 male/female profile with true data.
- CARE normal attack + learned skill + actual status/event tags if supported; status under cast/tick, burn kill exactly-once and no double damage popup.
- real loot receipt COMMITTED / paid_generation changes exactly once, Warehouse 1 after save/reload and return. Separate one settled-Mine GUI frame remains pending from PR28 baseline.
- S1 extra status visual events not handled: list exact event/actor fields and render gap, no fabricated icons. Boss-slot remains visual only; no synthetic Boss event.
- preserve old PR28 before/after and S1 QA logs; new integration screenshots must carry NEW SHA and may not be relabelled as PR28 old after.

**Quality**: FPS/memory and alpha on Windows 8GB target, panel clipping/overlap, touch sizes, Source A sprite IDs, foot anchors, no double HP/damage; physical Windows manual, Android and owner visual remain PENDING unless newly proved.

## 6. Required future GitHub outputs and triage

Proposed paths in the future integration QA branch:
- docs/handoffs/2026-10-24/TMB_PR28_S1_INTEGRATION_QA_REPORT_2026-10-24.md
- docs/handoffs/2026-10-24/TMB_PR28_S1_INTEGRATION_ISSUE_MATRIX_2026-10-24.md
- docs/handoffs/2026-10-24/evidence/PR28_S1/ [only bounded actual captures and text manifests, avoid huge tracked archives]
- isolated local outputs for verbose logs + GitHub SHA-indexed links where allowed.

Document: PR28 HEAD, S1 FIX HEAD, integration HEAD, code-only diff and file ownership, Godot version/commands, each test result (exit/marker), paid receipt IDs, snapshot replay, camera, source asset SHA, CI_UNKNOWN independent triage, all PENDING limitations.

STATUS labels: S1_QA_PASS, INTEGRATION_NOT_STARTED, INT_TEST_FAIL, INT_FOCUSED_PASS, VISUAL_REVIEW_PENDING, CI_UNKNOWN, OWNER_PENDING, ANDROID_PENDING, blocked. No "ALL PASS" until conditions really met.

## 7. What this coordination task WILL and WILL NOT do

DONE in docs scope:
- Recorded latest current HEADs and no-overlap analysis.
- Locked dev-save policy in separate MD.
- Recorded Actions fanout & unclassified failures in separate MD.
- Wrote this executable future integration packet, test matrix and ownership.
- Did NOT change PR28 or PR29 code, workflow, current branch HEADs, SaveService, or main.

NOT DONE:
- S1 engine tests and repair; still owned by isolated Codex.
- Creation of future integration branch or PR; explicitly gated.
- First combined game run, new screenshots, full CI or merge.
- UI burn/weaken adapter and building asset replenishment (separate owner/asset issue).

## 8. Copy-ready SHORT future Codex prompt (use ONLY after GATE-S1 PASS)

TÔNG MÔN BÁ ĐẠO — BẮT ĐẦU INTEGRATION QA PR28 + COMBAT V3-S1. Trước hết đọc toàn bộ docs/handoffs/2026-10-24/TMB_PR28_COMBAT_V3_S1_INTEGRATION_QA_COORDINATION_PACKET_2026-10-24.md trên docs/pr28-pr29-coordination-20261024. Kiểm tra Gate S1 chính thức đã PASS ở exact HEAD nhánh fix, nếu chưa PASS thì DỪNG và chỉ báo blocker, không tạo nhánh. Nếu đã PASS, fetch lại HEAD PR28 và final S1, tạo worktree/nhánh isolated integration/pr28-combat-v3-s1-qa-20261024 TỪ PR28, đưa vào chỉ các delta Combat S1 đã được nghiệm thu, không merge/rebase PR nguồn và không sửa gameplay thêm. Chạy official Godot 4.7.2 toàn bộ focused matrix dedupe PR28(21)+S1(14)+edge ở same integrated SHA, kiểm tra Source A P3.2/CARE status/burn kill exactly-once/Kho/save-load cùng version, chụp GUI 1280×720 thật, ghi diff/SHA/issue matrix/report GitHub. Không chạy FULL/CI có chủ đích, không sửa workflows, không merge PR #24–#29, không đổi HP×100/Boss/S2, giữ Windows manual/Android/Owner Visual PENDING. Chỉ có quyền QA/integration tập hợp approved source, thiếu status mapping thì ghi UI GAP, không tự sửa file ngoài allowlist.
