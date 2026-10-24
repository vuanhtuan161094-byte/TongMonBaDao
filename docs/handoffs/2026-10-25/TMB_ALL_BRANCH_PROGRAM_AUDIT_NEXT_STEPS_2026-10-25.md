# TÔNG MÔN BÁ ĐẠO — TOÀN REPO BRANCH AUDIT & NEXT EXECUTION ROADMAP
Audit date: 2026-10-25 (Asia/Bangkok). READ-ONLY GitHub inspection; document commit only. No code, merge, CI, Full regression, deletion, rebase or force-push.
Repository: vuanhtuan161094-byte/TongMonBaDao
Source of raw machine-readable inventory: docs/handoffs/2026-10-25/TMB_ALL_GITHUB_BRANCHES_INVENTORY_2026-10-25.csv
**Scope:** 131 branches in inventory-time snapshot (including this audit branch, created while auditing, and concurrent newly published design branch). 31 GitHub PR records: **27 OPEN/DRAFT, 4 CLOSED** of which **2 MERGED and 2 CLOSED WITHOUT MERGE**.
**Not a claim that every branch has been manually line-by-line reviewed:** All branch names, head SHAs and PR links/statuses were enumerated from GitHub APIs. Representative live integration/code ancestry, critical source files, canonical design docs and recent design tracks were inspected. Per-branch source-diff verification for all 131 would require dedicated follow-on code archaeology before deletion/merging.

## A. Executive assessment — critical finding

1. **main is NOT the latest integrated game.** \`main@29b5fba448b0178cb520a4ada44b375b4b934e31\`; newest combined playable/QA candidate is **draft PR #31 HEAD \`9eb4fd55733bb49bbb069240b8e332d37d22aced\`** on \`integration/pr28-combat-v3-s1-playable-qa-20261024\`. GitHub comparison \`main...PR31\`: **ahead 53 / behind 0**. This is an ancestry statement, NOT merge/release approval.
2. Code actually tested for PR31 = \`4b02a0c61a2771d9d4638129d96b68ad292270dc\`, tree \`352700b65d3cd0ef7039df22a1153d81b2fd7b82\`. Separate evidence/doc HEAD = \`9eb4fd55...\`; do not interchange their testing claims.
3. PR31 contains the selected Combat V3-S1 feature/fix deltas from PR29/30 on top of PR28, without Git-ancestry merging those sibling PRs. **Do NOT separately merge PR29 and PR30 later as if absent;** first inspect net tree/delta to avoid double application.
4. Many older Economia/Disciple/UI/G1/JX/C4 code branches diverge from PR31, some by hundreds of commits (different early histories). **Never bulk-merge or cherry-pick by phase number**. Their unique code/assets MAY still have value; preserve while evaluating specific missing pieces against PR31/current art manifest, one selective import at a time after authorization.
5. **The owner explicitly PAUSED further gameplay/Combat/UI coding after PR31 to redesign the SECT MAP.** No requested cutover, merge, cleanup or new renderer exists yet. The map checkpoint document was placed at \`docs/map-redesign-checkpoint-20261024\`. Highest immediate priority = evidence-grounded map audit and three design options, not a new S2/gear/Boss code fork.
6. The various **Thanh Trúc Lâm 20 camps / 200–400 monster / 30-disciple** maps on docs branches concern **HUNTING WORLD**. The requested redesign concerns the **SECT MAIN MAP** (\`SectIsometricWorldV1\`), not the same world/grid or rendering contract. Keep separate.
7. \`docs/mainline-governance-content-foundations-20261023\` has a one-main proposal, but explicitly says it is **proposed and not effective replacement for AGENTS.md/main**. Its eventual target of a single integrated main aligns with reducing fragmentation, but **requires owner merge approval** and release gates.

## B. Full branch inventory grouping

Snapshot includes **131 exact branch records**; complete per-branch (name, SHA, category, current PR association, base, triage) in CSV above. Group categories below do not by themselves prove code ancestry or content quality.

| Category | Count | Recommendation |
| --- | ---: | --- |
| docs/* independent research/checkpoint | **77** | PRESERVE. 75 pre-existing design/research branches + this audit branch + an additional Forge cost-gate design branch. Different docs can contradict; only owner-approved selected decisions advance to canonical docs, never auto-CODE. |
| C4/JX/legacy combat experiments | **16** | KEEP as reference/asset archaeology; superseded as active combat authority by V2+S1 PR31. Do not import JX logic/renderers wholesale. |
| Misc/experiments (Source A library, V2 integration, Unity, demo, tools) | **8** | KEEP tagged as historical/provenance; potential Source A conversion assets, but no bulk code merge. |
| integration/* | **7** | PR24–27–31 parent chain plus legacy integration branches; verify ancestry, do not collapse by PR number. |
| economy & mine old code | **6** | Design/reference and possible selectively recoverable changes, NOT the actual PR31 baseline. |
| UI/Map/G1 branches | **6** | Compare verified assets and code to PR31 MAP25 32 SHA-gated files before reusing; no direct old UI merge. |
| disciple legacy V2 | **5** | Current D7/CARE/OneActiveJob already tested PR31, old forks require dedicated provenance audit. |
| feature/fix | **3** | PR29 feature and PR30 fix are incorporated by value into PR31; Character Studio separate experimental scope. |
| Lay-01 design | **2** | Design-only construction/Hall/land expansion; NOT proof SectLayoutState V2 has all functionality in PR31. |
| main | **1** | Remains sole official trunk, but behind the verified draft integration candidate. |
| **Total** | **131** | No branches deleted or merged in this audit. |

Two HEAD aliases observed in original enumeration: \`uiux-finalization-v1-20261023\` equals PR25 SHA \`710137c0...\`; \`docs/x1-r01-r03...\` and \`docs/x2-r04-r10...\` share one SHA. \`docs/ascension-r11-r21-vertical-slice-source-proof-20261025\` initially pointed at main but advanced during this audit to \`70fab4c...\`, adding a **DOCS-ONLY** design file. Newly observed independent \`docs/forge-lv30-75-r20-predivine-source-cost-softlock-20261024\` is also a one-file **DOCS-ONLY** proposal. These prove parallel sessions can push while this audit runs; re-fetch HEAD before later decisions. All draft/design statuses remain distinct from implemented gameplay.

### Old PRs

Current active stacked QA/game line:
- #24 B3 CARE base on main; #25 real CARE hunt P3.2 atop #24; #26 MAP25/G1/V5 recovered atop #25; #27 D7 atop #26; **#28 verified UI Source A atop #27**; **#31 integrated Combat V3-S1 atop #28**.
- **Sibling branch:** #29 Combat S1 atop #27; #30 fixes atop #29. Their code was selectively replayed/validated in #31. PR29/30 staying open is for traceability, not additional unshipped Combat authority.
- **All #24–#31 remain OPEN/DRAFT/UNMERGED.** PR31 is clean and mergeable against its current PR28 base, but no full manual Android or release gate completed.

Older open drafts **#2–#14 except #15**, plus **#16–#21**, total **19 legacy OPEN DRAFTS**:
- Economy #6–#9; Disciple #10, #14, #16, #17; Economy/layout #12, #13; G1/MAP25 #18–#20; JX pilot #11; documents/experiments #2–#5 and #21.
- Do not treat "OPEN" as work actively assigned or "PENDING QA" as forever blocked. Review whether the unique code/asset/docs remain needed **after** map/visual approval and main cutover, then archive/supersede in batch with explicit owner permission. NO auto-delete now.
- Closed #1 and #23 are MERGED; #15 and #22 closed but NOT MERGED. Do not reopen closed PRs by default.

## C. Current canonical live-game checkpoint

PR31 tested source is integrated at exact SHA \`4b02a0c61a2771d9d4638129d96b68ad292270dc\`:
- Godot \`4.7.2.stable.official.ed1daf0bf\` **28/28 focused tests PASS**, Combat S1 edge **56/56 checks** PASS, with O9 real production included. Isolated test userdata.
- **19 real P3.2 1280x720 screenshots** (automated harness, not human acceptance); Mine mine_001 actual Thanh Thiết 37→39 +2 after travel/mining/haul; V2 candidate male/female + Source A actors, Hỏa Cầu burn, Hàn Sương Ấn weaken, Kim Cương Hộ Thể guard factor 0.62 active 11s/expired 14s.
- CARE real Thanh Lang kill, exactly one \`tinh_lang_bi\` canonical warehouse reward, paid generation 1, receipt COMMITTED, respawn SAME world, return to sect, same-version SaveService reload no duplicate.
- PR31 report: \`docs/handoffs/2026-10-24/TMB_PR28_S1_END_TO_END_INTEGRATION_REPORT_2026-10-24.md\`; issue matrix and evidence \`docs/handoffs/2026-10-24/evidence/packet-b/sha4b02/\`.
- Verified worker Source A + MAP25 **32 SHA-gated environment assets**; 3 known PV01 visual house examples Main Hall / Warehouse / Forge. No approved complete Mỏ/Linh Lâm/Linh Điền Source A building packs.
- Portable **Godot project ZIP**, 48,206,898 bytes, SHA-256 \`8f912d8c3ede8051f6d238e6aee677d6c64f8ea243368e5460bc99b975bd7ce9\`; exists as local Windows \`E:\` artifact in worker report, **not attached to GitHub**. Engine/export templates not included; not a standalone .exe.
- **PENDING:** human Windows mouse/playtest; prolonged FPS/RAM profiling on real 8GB environment; Android pinch/touch/device; owner visual acceptance; FULL/CI and main cutover. Prior GitHub Actions push runs on PR31 ancestor \`35db75...\` reported failures; logs insufficient for root cause and they DO NOT certify Godot code failures. Do not call CI green, and do not claim absolutely zero Actions runs.

## D. Source of truth and branch dependency, precise

\`\`\`text
main @29b5fba4
   └── PR24 CARE @4d08984
        └── PR25 CARE/P3.2 @710137c
             └── PR26 MAP25/Source A recovery @53ff0b2
                  └── PR27 D7 @deeae081
                       └── PR28 Source A/UI @e9190f4
                            └── PR31 integrated S1/CARE/UI @9eb4fd5 (tested code @4b02a0c)
                       └── PR29 S1 @9522812
                            └── PR30 S1 official fixes @f86ab7e
                      (PR29+PR30 reviewed net code carried into PR31)
\`\`\`

**Watch-outs:**
- GitHub "mergeable clean" for PR31 relative to PR28 does not mean entire chain is release-ready; all bases must remain consistent, all locked authority regressed, manual visual must be accepted.
- Need an approved, controlled cutover plan to move chain into **main**. A possible ordered path follows PR24→25→26→27→28→31; avoid separate later merges for #29/#30 if their exact code is present in #31. This is a PLAN, not merger authorization.
- GitHub old branch heads are not authoritative gameplay versions. Saved docs on independent branches are research until owner selects and reconciles them with current integrated code/AGENTS.md.
- Owner's current save policy: **NO forced migration from older experimental dev saves, YES same-build save/load and exactly-once canonical reward.** Do not delete SaveService or current migration tests just to meet policy.

## E. High-impact conflict and debt register

| ID | Risk or potential conflict | Proof/status | Required future action |
| --- | --- | --- | --- |
| R1 | main vs PR31 branch divergence | main 53 commits behind PR31, no newer main commits | Pin PR31 tree; owner-approved sequential review/cutover AFTER map UI acceptance; no blind bulk merge |
| R2 | 129+ branches and 27 OPEN drafts create multiple apparent sources of truth | GitHub list and PR status | This inventory + authority/owner decision index + archive/supersede proposal only AFTER content diff, never auto-delete |
| R3 | PR29/30 separately merged after PR31 would duplicate S1 deltas | PR31 code net diff includes three combat source files + S1 tests | Select only one controlled net merge path; label PR29/30 source/QA provenance |
| R4 | Old JX/C4 and old G1/MAP25 production demos have forked histories | GitHub compare diverged; e.g. early G1/Map and Economy branches | Do not wholesale cherry-pick; selectively recover verified source assets with hash/provenance |
| R5 | Current map owner visual approval still PENDING | P3.2 automated evidence 19 frames and owner redesign request | **Immediate focus SECT MAP REDESIGN** with A/B/C layout/asset/UX/perf design before CODE |
| R6 | Source A art shortage for buildings/terrain/water/path | P3 asset/map registry and PR28 report, 32 verified MAP25 subset | Asset-gap taxonomy and Source A art sourcing/production proposal; no guessed master assets |
| R7 | Product map vs hunting world geography can be confused | \`SectIsometricWorldV1\` vs docs 20-camp hunting-world design; no shared map assumption | Split two map charters; main task sect map; hunting-world designs PARKED |
| R8 | Content research docs differ from implementation | 77 docs branches, e.g. Forge 10-slot V2 versus current P2 pilot 3-slot; Boss coop/Elite and XP per kill often proposed only | Cross-system owner decision index, compare item IDs/tiers/loot, future single CODE vertical slice, don't claim shipped |
| R9 | GH Actions push workflows auto-fail noise | GitHub run statuses, unknown logs | Track CI_UNKNOWN separate from official local PASS; workflow edit requires owner permission |
| R10 | Windows portable != release-ready | No exe export template and no human / Android / long perf | Windows manual and touch/equipment compatibility before release sign-off |

## F. Immediate NEXT WORK — ONE LARGE DESIGN JOB, NOT MANY CODE FORKS

### MAP-D0: "SECT MAIN MAP V2 architecture and visual redesign" — highest priority NOW

**Inputs**: PR31 exact code SHA 4b02a0c + branch-head evidence 9eb4fd5; docs/map-redesign-checkpoint-20261024; \`docs/P3_ART_BIBLE.md\`, \`docs/P3_ASSET_MAP_ENVIRONMENT.md\`, \`docs/P3_UX_MAIN_MAP.md\`, Source A/MAP25 asset registry and 19 P3.2 actual screenshots.

**Current code facts** (NOT new decisions): \`godot/src/presentation/p3/sect_isometric_world_v1.gd\` currently defines **192×192 grid**, **16×16 chunk**, **48×48 starter Rect(72,72,48,48)**, iso projection HALF_W25/HALF_H13, 1280×720 presentation with SubViewport camera and UI outside camera; \`SectIsoMapModelV1\` handles AStarGrid2D navigation; visual positions have anchors for Main Hall, Forge, Warehouse, Mine, Forest, Field, residence/other buildings. Current X/Y/asset coverage is NOT assumed final.
**Design principles**: Chinese xianxia Source A hand-painted; living sect/miniaturized actor; readable building silhouette, actual roads and workstations, meaningful terrain/water/vegetation, one free pan/zoom camera, Android landscape 1280×720. Retain one simulation owner and an independent real CARE hunting world; don't conflate.
**Deliverable in one long Codex docs-only assignment**:
1. Audit each of 19 actual GUI frames plus Godot map world/render/UI source. Mark specific baseline problems per PNG and state.
2. Recover/verify actual available asset IDs, mappings, hashes; separate map base/path/river/trees/buildings/props/actor; gap ledger RESTORE/REUSE/MISSING/PROPOSE_NEW/REJECT.
3. Produce three distinct **SECT MAP** candidates: **A conservative art/composition revamp** (keep 192/chunk/starter), **B functional center zoning/re-layout** (keep gameplay but redesign starter 48), **C living-sect districts and progressive expansion** (one world with camera/chunk/LOD strategy). Show clear top-down/isometric 1280×720 concept sketches/mockups and actor/road/building navigation, respecting real asset budget; use static concepts ONLY as design, never runtime proof.
4. Compare A/B/C on Source A fidelity, missing assets, readability at phone scale, map navigation/interaction, producer placement, extensibility for up to 30 Mine/30 Forest/40 Field when separately approved, GPU/perf/8GB risk, implementation scope and compatibility with existing P3.2/CARE/D7/Source A.
5. Provide one recommended OPTION and justification, dependency files, collision/hit-target/camera rules, all map data/footprint implications, and an implementation+regression allowlist. No renderer rewrite unless separately approved.
6. Commit docs, diagrams/matrices to a **new docs-only branch descended from PR31 or its map-checkpoint branch**; do not modify PR31 code or create a new competing gameplay main. Request ONE owner design selection, not dozens of micro-approvals.
7. Keep full 28/28 scoped PR31 QA, O9, 56 S1 edges, MAP25 SHA 32, real state/warehouse/save, presentation status views as fixed regression baselines for future map implementation.

### MAP-D1: after owner chooses map concept — CODE ONLY WITH NEW AUTHORIZATION

Design → exact-scoped code branch from latest verified PR31 tree. One writer on P3.2, \`sect_isometric_world_v1.gd\`, camera, map navigation and allowed art files. No changes to Combat/CARE/Save/Warehouse/cultivation, no unverified original Source A assets. Add map focused QA, 1280×720 captures, mouse drag/building selection, 8GB long session and asset hashes; repeat existing PR31 integration tests on final SHA. Windows human+Android physical/owner visual remain true acceptance gates, not made PASS by screenshots.

### MAIN-CUTOVER: AFTER map prototype visual is owner approved and regressions are green

Make a separate, explicit "one-main" merge gate with tested tree/hash and dependency plan. Review PR24→25→26→27→28→31, check old PR18–20 content recovered or intentionally superseded, resolve PR29/30 duplicate branch disposition, then ask owner for specific merge authorization. Do NOT retarget/merge now.

### FUTURE BACKEND/CONTENT: AFTER mainline is stable

Read the docs-only research streams as proposals; reconcile overlapping identifiers:
- Direct kill Tu Vi V2, 30×10 realm/body path, stable numeric D7.
- B3 normal/Elite/Boss vs sect-wide multi-team Boss policy and exactly-once.
- Twenty-camp Thanh Trúc Lâm HUNTING WORLD / per-map difficulty / RTS movement (distinct from SECT MAP).
- 10-slot equipment V2, 12 quality grades, 24 sets, Forge one authoritative transaction, 30 equipment tiers, material/loot rarity and economic anti-softlock.
- Combat S2 dash/fire_combo and longer-term x100 balance design.
Favor one economically closed vertical slice rather than coding catalog encyclopedias. Nothing on these docs-only branches automatically changes runtime.

## G. What NOT to do now

- Do not start from main to 'rebuild the game from zero'.
- Do not mass-merge all historical Economy/Disciple/C4/JX branches, auto-close/delete 27 PRs, or automatically merge PR31. Preserve evidence.
- Do not confuse 20-camp **hunting-world** designs with the \`192×192\` **sect map**.
- Do not label 28/28 PASS as FULL/CI, Owner Visual, actual Windows human play, Android touch, or large-roster/perf pass.
- Do not rewrite Combat V2/CARE, D7, jobs, Warehouse, Save or the Source A renderer to beautify the map.
- Do not treat independent docs branch as canonical without AGENTS.md/owner approval.
- Do not invent a sandbox ZIP link for the Windows local E: build; that project ZIP is not stored in GitHub.

## H. Copy-ready next user instruction

"TÔNG MÔN BÁ ĐẠO — Tôi chọn MAP-D0. Trên GitHub đọc \`docs/full-branch-audit-nextsteps-20261025\` file \`TMB_ALL_BRANCH_PROGRAM_AUDIT_NEXT_STEPS_2026-10-25.md\`, cùng \`docs/map-redesign-checkpoint-20261024\` và bản PR31. Làm **MỘT PACKET DÀI DOCS ONLY**: kiểm toán 19 screenshot thật, source SectIsometricWorldV1/Camera/MAP25, provenance 32 assets, quy hoạch chức năng 192×192/starter48 và giới hạn ART; thiết kế 3 phương án A/B/C map TÔNG MÔN (không phải map săn 20 bãi), có sơ đồ tỉ lệ/camera/đường/công trình/actor/UI 1280×720, dự toán asset và hiệu năng, ma trận so sánh, phương án đề xuất, code impact/allowlist và acceptance matrix. Commit docs/design trên nhánh mới từ PR31; không code, không merge/chỉnh PR24-31/asset/Combat/Save. Chỉ hỏi owner một quyết định cuối là chọn A/B/C; không chia thành hàng chục packet." 

## I. Audit constraints / data provenance

- Branch and PR counts are time-sensitive. Concurrent work updated docs/ascension and introduced docs/forge-lv30-75 while this audit was running. CSV captures names and HEAD at its snapshot time; recheck future branch heads before integrating.
- Comparison of old code forks with PR31 hit GitHub compare per-file cap (300 files) and includes diverged roots. Compare results are ancestry proof only, NOT a complete missing-feature audit. Do not equate legacy != PR31 with legacy contents fully recovered or unneeded.
- GitHub Branch API per-page inventory includes branches without PRs; no action taken on branch deletion or PR status.
- User explicitly prefers frozen PR31 and sect-map design focus. Any future code/merge needs its own explicit authorization.
