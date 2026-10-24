# TÔNG MÔN BÁ ĐẠO — PACKET B / END-TO-END PLAYABLE INTEGRATION
Date: 2026-10-24 | Godot 4.7.2 | Target: Android landscape 1280x720, Windows test build.
Scope: INTEGRATE UI PR28 + Combat V3-S1 PR29/PR30 + finish integration-critical presentation and QA in ONE Codex assignment. No intermediate owner approvals for ordinary scoped fixes. Make the actual combined playable P3.2 scene work before reporting success.

## 0. Owner instruction and outcome

This is intentionally a **LONG, COMPLETE IMPLEMENTATION TASK**, not a micro-task or another design-only handoff. Execute G0-G8 end-to-end, performing autonomous scoped repairs and regressions until an exact-SHA real P3.2 integrated gameplay run and report exist. Do not hand back merely "the branch was created", "diff clean", "tests written", "mockup prepared", or "need another prompt" if the task can be completed under this allowlist. Only escalate a hard blocker genuinely outside authorized paths, unavailable tools/dependencies, or a new gameplay rule requiring owner choice; continue independent work and produce partial verified deliverables if a blocker arises.

**Objective:** A single integrated game version in which (i) P3.2/MAP25 Source A visuals, production/workforce, Warehouse, D7 and map camera are preserved from PR28, (ii) Combat V3-S1 uses the fixed real battle/snapshot/loadout authority proven on PR30, (iii) player can select a real V2 disciple, enter CARE hunting, see real attack/skill/status and paid Thanh Lang loot, return/reload without duplication, (iv) status visuals/readability are synchronized to actual combat events, and (v) reviewable test evidence/screenshots and optionally a playable Windows package are attached to an isolated new GitHub draft PR. A simulated gameplay screenshot or fake worker action is unacceptable.

**No** full CI/FULL intentionally, no merge of any source PR, no rewriting renderer, no changing original Source A files/atlas provenance, no new Boss implementation, no skill S2 dash/fire_combo, no x100 HP/attack/medicine/economy rebalance, no equipment revamp or new public-release save migration. Do NOT switch to JX1/JXQY renderer.

## 1. Exact known GitHub input SHAs — ALWAYS refresh first

Repo: vuanhtuan161094-byte/TongMonBaDao.
PR27 common ancestor: deeae081bcfbe1413d4cf60a29db7e58150888b5
PR28 UI/Source A: ui/pr27-runtime-readability-20261024 @ e9190f490ebea82d2badf7f3fc44b34dd24bd425 (PR28 DRAFT, 21/21 focused reported PASS on code 47b704270ae165504aeef526963e8d03f87bc579; 12/12 real 1280x720 GUI captures).
PR29 Combat V3-S1: feature/combat-v3-s1-runtime-effects-20261024 @ 9522812e91b7ca5bc0cc108eb92e000e930fe850 (PR29 DRAFT).
PR30 S1 fixes and official QA: fix/combat-v3-s1-official-qa-20261024 @ f86ab7e7d42d6d275314368554489514f7edb98f (PR30 DRAFT; code/test tree at e51dabc57ce20c294d03a0e9d64ed3ccd1397b3c equals Godot-tested source tree 6859fde16ed71a2596d3a5a52539622136d866e0; local tested SHA 4fe466d8efc192aa93738811041de795baadb22a).
Repo agent contract: AGENTS.md; docs/GAME_SYSTEM_ARCHITECTURE.md; CURRENT_CHECKPOINT.md; NEXT_CHAT_HANDOFF.md.
Prior coordination and QA contracts:
- docs/handoffs/2026-10-24/TMB_PR28_COMBAT_V3_S1_INTEGRATION_QA_COORDINATION_PACKET_2026-10-24.md (this docs branch).
- docs/handoffs/2026-10-24/TMB_DEV_SAVE_COMPATIBILITY_POLICY_2026-10-24.md (this docs branch).
- docs/handoffs/2026-10-24/TMB_GITHUB_ACTIONS_AUTO_TRIGGER_AUDIT_2026-10-24.md (this docs branch).
- PR28 docs/handoffs/2026-10-24/TMB_PR28_UI_ASSET_INTEGRATION_REPORT_2026-10-24.md; issue matrix, worker asset catalog and evidence manifest.
- PR30 docs/handoffs/TMB_COMBAT_V3_S1_OFFICIAL_QA_REPORT_2026-10-24.md; focused_results.csv, edge_results.csv, complete logs/sha_manifest.
- .agents/skills/tmb-asset-gate/SKILL.md, Source A manifest/camera/adapter only when relevant.

**Gate already reported:** S1 PR30 official Godot 4.7.2 14/14 focused PASS and 56/56 edge PASS; regression evidence at code tree 6859fde1. Confirm the code tree in GitHub matches the report, and check new commits/branches. Note recorded isolated-Windows warning "Failed to read the root certificate store" without masking it. PR28 reported 21/21 PASS is at a DIFFERENT code base. This packet requires a new same-SHA integrated run, not recycled results.

## 2. Authorized implementation scope and ownership

Create a CLEAN, ISOLATED worktree/clone from the freshly checked PR28 exact HEAD, not main/PR27. Proposed GitHub branch: integration/pr28-combat-v3-s1-playable-qa-20261024 (rename only if it already exists; never force update). Use an independent 8GB-friendly workspace, temp user data on E: if available; do not touch Codex recovery, old Source A worker staging, personal save, imported asset cache, logs or user's Windows Administrator profile.

One designated implementation writer owns this integration branch. PR28, PR29, PR30 remain unchanged/open/draft/unmerged. No merge, squash-merge or rebase onto their branches; acceptable to replay reviewed exact S1 CODE DELTA into new branch by sequential selective cherry-pick (if appropriate) or controlled patch. PR30 includes extensive docs/log evidence; do not blindly copy 100+ evidence files as gameplay assets. Track source commit mapping and resulting integrated commits.

Authorized code paths, only as necessary:
A) **Approved S1 net delta** relative to PR27:
- godot/src/simulation/combat/map_battle_v2.gd
- godot/src/simulation/combat/map_battle_snapshot_v2.gd
- godot/src/simulation/combat/disciple_combat_loadout_v2.gd
- godot/tests/simulation/combat_v3_s1_effects_test.gd
- godot/tests/simulation/combat_v3_s1_edge_contract_test.gd
Do not change their already QA-approved rules just to solve presentation issues; if a genuine S1 code regression emerges, make the smallest isolated patch with a matching red/green test and report why.

B) **Integration-specific read-only presentation and focused tests**, where required:
- godot/src/presentation/p3/b3_care_combat_v5_presenter.gd
- godot/src/presentation/p3_2_landscape_sect.gd
- godot/src/presentation/p3_1_landscape_sect.gd
- godot/src/presentation/p3/disciple_six_dimension_radar.gd
- godot/src/presentation/p3/sect_production_worksite_cue.gd
- godot/tests/presentation/ (new clearly named PR28-S1 tests; existing tests may be amended only with explained contract preservation)
- output scripts under godot/tests/presentation/ for actual integration screenshot capture, bounded and clean.
Potential presentation-only extension outside these files: document specific path and necessity; do not silently expand into runtime simulation/save/asset pipelines.

C) GitHub reports, screenshots and small manifest/log evidence under docs/handoffs/2026-10-24/ and bounded outputs/.... No workflow YAML or GH repo settings modifications.

**Disallowed without separately documented owner permission:** save_service.gd, Warehouse, scheduler, SimulationState, DiscipleState/D7 generation, economy/building/workforce production authority, CARE B3HuntWorld/receipt owner, Injury120, new combat balance/skills/systems, resource registry, .github/workflows, source_art original files, MAP25 SHA whitelist, Source A original textures/Spine, Boss live or S2. Do not broaden implementation simply to make a test green. If blocked by true out-of-scope code defect, record exact file/line and FAIL/BLOCKED; do not rewrite its test to pass.

## 3. Gameplay rules to retain while integrating

- Combat V2/MapBattleV2 remains canonical simulation and CARE hunt authority; V3-S1 is a scoped extension, **not a parallel new combat backend**.
- S1 skills: Hỏa Cầu burn, Hàn Sương Ấn / Chấn Sơn Quyền weaken, Kim Cương Hộ Thể / Bất Động Thân learned guard, plus currently live Thanh Phong Trảm and Ngự Kiếm Thuật. Tests must assert cast, status timing, speed deadlines, cooldown and strongest guard. Truy Phong Bộ dash and Liệt Diễm fire_combo remain DEFERRED.
- Keep existing **pilot rule: burn expires if the caster dies** in this batch. This is a temporary no-change assumption for integration, NOT an irreversible final owner balance decision. Record PENDING_DESIGN for future decision, but do not stop current execution to re-ask.
- Boss-slot 410041_1 is only a visual candidate; do not fake CARE Boss event. Thanh Lang is canonical species mapping.
- Existing worker 4 packs (Boss-slot, female 1113028_1, male 1110201, Thanh Lang 1113031_1) are already verified/present in PR28. Reuse; no duplicate source import. Female combat pack has no verified stand/walk; do not invent missing clips or directions. Current MAP25 32 hash-gated assets remain unchanged.
- No verified full binary Source A building packs for Mine/Forest/Field. Do not install inferred candidates, create fake harvesting/chopping clips or alter production timings.
- Worker progress panel must display canonical work phase, actual ETA, quantity predicted/settled and real assigned disciples; never advance scheduler from a view redraw.
- Owner dev save rule: NO MANDATORY migration of historical dev saves across experimental builds; YES required same-version save/load, CARE exactly-once paid receipt, Warehouse state, mid-fight status snapshot/replay, fail-closed corrupt state, injury/occupation preservation. Never delete user saves or downgrade existing safety tests.

## 4. G0 — Read, audit and bootstrap the integration branch

1) Fetch GitHub branch status for PRs 27,28,29,30 and all code owners. Verify PR30 is based on PR29 and PR28/PR29 share PR27 ancestry. Assert expected code files do not directly overlap between PR28 and PR30. If HEAD changed, recompute ancestry and file diff; do not blindly reset somebody else's branch.
2) Ensure PR30 code tree is same as focused tested tree 6859fde1 (or discover later certified final tree). Compare GitHub source/report commit SHA and test evidence. Treat published evidence/doc commits as additional branch commits, not a different tested source if code tree identical.
3) Checkout PR28 into isolated worktree, restore/preserve verified assets and required import files exactly. Record git status (clean), parent SHA, commit tree, asset hashes, env version, Windows build info. Preserve PR28 remote branch and do not modify it.
4) Apply S1 net changes from PR29 + PR30 with provenance. Verify that final combined net delta touches only the approved simulation/test files and that PR28 presentation source is not rolled back. If merge conflict arises, resolve within allowed paths, with a three-way diff report; never silently keep wrong side. A mergeable PR30->PR29 flag is not certification of PR28+S1 runtime.
5) Commit integrated code with meaningful one- or two-commit checkpoints, not a series of unreviewed micro branches. Do not mark PASS yet.

## 5. G1 — Actual Godot import/parse and integration behavior

On official Godot 4.7.2.stable.official.ed1daf0bf, run source import/parse with isolated APPDATA/LOCALAPPDATA/TEMP, verify assets loaded. Capture executable SHA, Godot version, exact command, stdout/stderr/exit, warnings separately. Root certificate store diagnostic is ENV_DIAGNOSTIC if no related test failure, not zero-errors-all.

From real P3.2 (res://scenes/p3/p3_2_landscape_sect.tscn), verify:
- MAP25 Source A ground/buildings/characters, free pan and zoom, select disciple, male/female visual rig identity, D7 profile fields, true status.
- Real production Mine, Linh Lâm, Linh Điền work phases, worker assignment/One Active Job guard, progress, ETA, Warehouse credit and save/reload.
- Launch canonical B3/CARE hunting with real V2 disciple and Thanh Lang, AUTO basic attack, skill cast/learned status, hit/guard, downed/return, real committed loot, canonical Warehouse one unit, paid_generation one, save/load/restart unchanged, re-entry with no duplicated paid rewards.
- No fabricated seeded UI state falsely passed as live, no second battle clock, no fake kill/reward/injury.

If S1 event schema is incompatible with UI, write a dedicated real-state reproduction test first; then fix only view adapter/allowed presentation paths to read the canonical snapshot. Do not patch combat authority for visual cosmetics.

## 6. G2 — Finish integration-critical visuals, not a renderer rewrite

This is part of the SAME packet, not another user approval stage.
- Map S1 **status_applied**, **status_tick**, active status_effects and learned_guard_until to concise readable live UI indicators for burn, weaken, guard. Use real events + canonical current combat snapshot; show true remaining duration if present, never invent duration, cause, direction, action or buff.
- Burn DoT must be distinguishable from direct hit and avoid repeated misleading 'paid loot' popups; learned guard should only show when actually active, and expire/clear according to state. Check that status text/indicators are legible at 1280x720 and do not obscure actor/HP/camera.
- Presenter must remain read-only and must not increment simulation, apply combat damage, award loot or create duplicate actors.
- Retain PR28 mobile landscape layout, camera, panel sizing, legibility and hit targets. Fix scoped overlap/clipping defects found during runtime, such as dense receipt labels (only presentation).
- Validate Source A male/female/Thanh Lang correctly mapped. One-facing clips should not be pretended as full 8-way animation; missing female stand/walk remain honest, use existing safe fallback if needed.
- Keep production worksite phase visible with collapsed roster (PR28 O3 fix), asset manifest/G1/32 MAP25 unchanged.
- No unauthorized art import/building packs and no game-wide reskin.

## 7. G3 — Full IN-SCOPE integrated focused regression on a single exact final code SHA

Use the exact PR28 21-script matrix recorded in docs/handoffs/2026-10-24/evidence/PR28/logs/focused_summary_9f7e1042.csv PLUS the PR30 14-script matrix in outputs/COMBAT_V3_S1_OFFICIAL_QA_20261024/focused_results.csv PLUS combat_v3_s1_edge_contract_test.gd, plus any new presentation integration tests.

Deduplicate identical test paths; expected 27 DISTINCT baseline scripts (21+14-9 overlaps+1 edge), verify by constructing the unique path set from actual CSVs; if counts disagree, print exact diffs rather than adjusting claims. The final matrix includes:
- D7 foundation/migration/real V2 profile and radar.
- Real P3.2 main hunt + CARE continuous kernel/auto pills/Injury120/B3 fasttrack, burn kill paid receipt and B3 return + reload.
- MapBattle snapshots, monster context, five tier map, attack speed/cast/weaken/guard effects, equipment combat effect regressions.
- Canonical mine/forest/field and O9 M2 producer rehearsal, map camera and 32 Source A art SHA gate, G1 visual.
- UI readability and Source A V5 view adapter / new S1 live-status presentation contract.

For EACH test: official binary version, project path, source tree SHA, isolated userdata, stdout/stderr/exit, PASS marker (if declared), parse/assertion diagnostics, result and historical RED when applicable. If an integration repair modifies a file, re-run the *whole* deduplicated in-scope suite on FINAL integrated code SHA (not stale PR28 or PR30 evidence). Keep baseline and fixed logs.

Do not run project-wide FULL/CI intentionally; GitHub Actions may auto-trigger on push. Report auto CI results as independent signals and do not claim "CI not triggered" without checking. If automated jobs fail without logs, label CI_UNKNOWN not CODE_FAIL, and provide run links; don't change workflows under this packet.

Blocking requirements: source parse success, every required in-scope focused test PASS on one final SHA, no duplicate loot, current-version save/replay valid, visual status mapping based on genuine S1 events; if any remain red, mark INTEGRATION_BLOCKED instead of claiming overall PASS.

## 8. G4 — New REAL screenshot evidence and visual acceptance

Capture 1280x720 actual P3.2 scene from the combined source SHA (not static mockups), ideally at least these distinct frames:
01 sect overview; 02 map pan/zoom; 03 Mine active phase and worker; 04 Mine AFTER ONE SETTLED BATCH showing paid quantity in Warehouse (previous PR28 gap); 05 Linh Lâm/field; 06 canonical Warehouse before/after; 07 real male V2+Source A profile (prior missing capture); 08 real female D7 profile; 09 CARE Thanh Lang battle startup; 10 real learned skill cast; 11 actual burn applied/tick; 12 weaken + learned guard active/expiry; 13 hit/damage; 14 canonical earned loot with receipt ID and generation; 15 return-to-sect and same-version SaveService reload. Additional layout crops/contact sheet optional.

Every screenshot must have capture manifest containing engine, exact source SHA/tree, scene, viewport, timestamp, actor ID, world ID, event IDs/types, tick/battle_seconds, paid_generation, receipt IDs, Warehouse inventory and save-load comparison when relevant. Do not manipulate screenshots to fabricate events or fake person/monster provenance.

Specific unmet PR28 duties: Mine paid-settlement GUI frame + male profile. If custom extended capture harness fails, keep FAIL logs and do not call settlement GUI PASS even if gameplay test proves production; repair within permitted presentation/test harness scope and rerun. Existing O9 historical 19/20 fail vs clean 20/20 and PR28 current PASS must remain separate.

Inspect crowding, alpha/pivot, HP label readability, FPS/memory on 8GB-friendly device, camera/pinch expectations, touch targets. A scripted GUI run is **not** human Windows manual play; no physical Android/pass until actually performed. Owner visual approval remains pending unless owner explicitly approves screenshots.

## 9. G5 — Deliver a playable candidate rather than just reports

After integrated focused PASS and successful real P3.2 capture:
- Produce a clearly versioned lightweight **Windows playable candidate** in isolated output folder, if the existing Windows Godot export tools/templates are available and reproducible. Do not install system-wide components or damage user's machine. The Windows build must launch directly into the current P3.2 scene and use a fresh test save; smoke-test executable startup+basic click/hunt/return as far as accessible.
- If export templates unavailable, provide a portable Godot-project demo ZIP plus a one-click Windows launcher using the already installed official engine, with exact prerequisites documented. Do NOT mark this equivalent to standalone exported exe.
- If no safe reproducible package is possible, report PACKAGING_BLOCKED with precise missing dependency and retain tested integrated source/screenshots; never invent downloadable binaries.
- Place output ZIP, file list, hashes and minimal one-step launch instructions at a real accessible worktree path. For GitHub delivery, use existing approved artifact channel/PR link if connector/tool actually supports it; avoid committing enormous build binaries to Git history or making a fake attachment URL. GitHub handoff Markdown must say where the real file is accessible to owner, or explicitly that GitHub only contains code/evidence.
- No Android APK export requirement or physical Android PASS; Android remains explicit next acceptance gate.

## 10. G6 — GitHub delivery, draft PR and exact handoff

Push only the new integration branch. Create a **DRAFT PR stacked on PR28 head** (base ui/pr27-runtime-readability-20261024). This is a REVIEW candidate, not release or merge. PR #24-30 remain OPEN/DRAFT/UNMERGED. Do not create duplicate PR when an intended integration PR already exists; refresh and update safely instead. No force push.

Required new docs on integration branch:
- docs/handoffs/2026-10-24/TMB_PR28_S1_END_TO_END_INTEGRATION_REPORT_2026-10-24.md
- docs/handoffs/2026-10-24/TMB_PR28_S1_END_TO_END_ISSUE_MATRIX_2026-10-24.md
- docs/handoffs/2026-10-24/TMB_PR28_S1_NEXT_HANDOFF_2026-10-24.md
- machine-readable exact-SHA deduplicated focused_results.csv + source_manifest.json + display/receipt capture manifest; small actual PNGs/contact sheets and bounded logs (avoid dumping huge transient cache/binary assets).

Report minimum:
1) PR28/29/30 exact source heads and merge base; resulting integration code SHA & tree.
2) Audit of file changes/provenance and no ownership changes.
3) Godot 4.7.2 official import/play/test data; 27+ new focused test results with exact commands, exit codes/markers and ALL retained failures.
4) Real Source A asset identities, missing Mỏ/Linh Lâm/Linh Điền packs, MAP25 accepted 32.
5) Combat V3 burn/weaken/learned guard/cadence behavior; confirm pilot caster-down burn clear untouched.
6) Real CARE committed receipt, paid_generation and SaveService same-version replay, expected/actual.
7) GUI evidence and quality issues; manual Windows, Android/touch, owner approval all PENDING unless proven.
8) Packaging output SHA and launch instructions (or precise PACKAGING_BLOCKED).
9) Unrelated GitHub Actions auto-failures with run URLs and CI_UNKNOWN classification.
10) Remaining P0/P1/P2 backlog with owner approval gates. No misleading "FULL PASS".

## 11. Definition of DONE — not just one passing test

**INTEGRATION_FOCUSED_PASS:** Combined new branch real P3.2 scene launches at 1280x720, S1 backend learned burn/weaken/guard works, UI safely reads real S1 statuses, canonical Mine/Forest/Field, Warehouse/CARE paid loot/save same build unaffected; full deduplicated focused suite + edge + new UI tests PASS at FINAL exact SHA, actual screenshots & manifests complete and GitHub draft PR/report available.

**REVIEW_PENDING:** Even with integrated PASS, Windows human manual test, physical Android/touch, owner Visual approval, missing full building art, Boss event mapping, S2, x100 tuning and full CI remain outstanding. Never call this final release.

**BLOCKED:** If a disallowed authority code path must change, or Godot/regression can't prove integrity, mark explicit failed gate, retain branch and evidence, report exact blocker and minimal separate authorization request. Do not stop at the first easily fixable scoped failure, and do not ask the user to perform work Codex can perform.

This is ONE long task with internal stages and one final handoff; commit checkpoints only for safety, not as requests for user to approve each internal step.

## 12. Short launch command for the owner to paste into Codex

TÔNG MÔN BÁ ĐẠO — EXECUTE PACKET B END-TO-END. Open GitHub repo vuanhtuan161094-byte/TongMonBaDao; read docs/pr28-pr29-coordination-20261024 / docs/handoffs/2026-10-24/TMB_PACKET_B_LONG_END_TO_END_PLAYABLE_INTEGRATION_CODEX_2026-10-24.md entirely (and its linked policy, QA and evidence docs). I authorize one complete batch: create isolated integration branch from current PR28, integrate QA-passed PR29+PR30 S1 code, fix integration-related read-only S1 status display and UI issues within the packet allowlist, run official Godot 4.7.2 complete deduplicated focused matrix and real P3.2 GUI captures, close missing Mine-settled/male-profile evidence, prove CARE/loot/SaveService exactly-once, prepare Windows runnable candidate if feasible, push GitHub draft PR and all reports. DO NOT split into many approval steps, do not stop after merely creating a branch; only ask for hard out-of-scope blockers. Preserve original PR28/29/30 and all assets/worktrees; no FULL/CI intentionally, no merge, no Boss/S2/x100, no legacy-dev-save migration. Report final code/test SHA, proof, PR link, visual evidence and outstanding debts.
