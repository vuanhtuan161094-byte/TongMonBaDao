# TÔNG MÔN BÁ ĐẠO — MAP-D1 B OVERNIGHT ONE-SHOT
## Isolated implementation + real Godot QA + map visual comparison + asset gap forensics + playable handoff

**Date:** 2026-10-25, Asia/Bangkok  
**Status:** INSTRUCTION PROPOSAL. **Actual CODE permission is granted by the owner only when they deliberately submit the launch prompt in Section 16 to Codex.** This Markdown publication itself does not alter gameplay or approve a merger.  
**One long task** with internal safety checkpoints, NOT many small approval requests.  
**Chosen prototype direction:** **OPTION B** from MAP-D0, functional entry → courtyard → Main Hall axis with three sect districts, while **owner visual/design approval remains PENDING**. This is a reversible experimental candidate, not a final art/layout lock.

## 0. Why this is the right next task

Tông Môn Bá Đạo has an actual, integrated Godot 4.7.2 playable candidate at PR #31 (28/28 focused tests, 56/56 S1 edge checks, 19 real runtime screenshots). The sect map, not the simulation backbone, is the current owner priority. MAP-D0 audited current map geometry, assets, screenshot problems and compared options A/B/C. It recommended **B** because composition, hierarchy and map readability can improve without building a second renderer or changing gameplay. The main visual limitation is that 32 verified Source A PNGs include **only three verified buildings**, so workers/building sites must NOT be visually misrepresented.

Complete everything that can safely be completed without additional owner involvement **on an isolated implementation branch**; do not consume time preparing another short plan or returning to ask for micro-step permission. If a hard out-of-scope blocker arises, continue every independent permissible task, preserve failure evidence and report an exact blocker.

## 1. Baseline, branches, SHA and source authority

GitHub: \`vuanhtuan161094-byte/TongMonBaDao\`
Engine: official \`Godot 4.7.2.stable.official.ed1daf0bf\`
Target: Android landscape 1280×720; Windows 1280×720 for proof.

- PR #31 head \`9eb4fd55733bb49bbb069240b8e332d37d22aced\` at time of packet; GitHub branch \`integration/pr28-combat-v3-s1-playable-qa-20261024\`, OPEN/DRAFT/UNMERGED. Exact tested CODE SHA \`4b02a0c61a2771d9d4638129d96b68ad292270dc\`, tested TREE \`352700b65d3cd0ef7039df22a1153d81b2fd7b82\`; HEAD afterward includes docs/QA evidence.
- PR #31 focused suite: 28/28 PASS including O9, V3-S1 56/56 edge checks; real P3.2 Mine/Forest/Field/D7/CARE/Combat + loot/save; 19 screenshots at 1280×720 under \`docs/handoffs/2026-10-24/evidence/packet-b/sha4b02/\`. These are BASELINE EVIDENCE, not tests that have run on this future branch.
- MAP-D0 design branch \`docs/map-d0-sect-main-redesign-20261025\` at commit \`25cb7a0f59a93ddcccc8a5d6acf1dd8e2290874f\`, derived from PR31 HEAD with **six docs/SVG files, no code**.
- Important MAP-D0 docs:
  - \`docs/handoffs/2026-10-25/TMB_MAP_D0_SECT_MAIN_REDESIGN_REPORT_2026-10-25.md\`
  - \`docs/handoffs/2026-10-25/TMB_MAP_D0_ASSET_AND_EVIDENCE_MATRIX_2026-10-25.md\`
  - \`docs/handoffs/2026-10-25/TMB_MAP_D1_PROPOSED_IMPLEMENTATION_PACKET_2026-10-25.md\`
  - \`docs/handoffs/2026-10-25/evidence/map-d0/option-b-functional-hub.svg\`
- Cross-cutting guidance: \`AGENTS.md\`, \`docs/GAME_SYSTEM_ARCHITECTURE.md\`, \`docs/P3_ART_BIBLE.md\`, \`docs/P3_ASSET_MAP_ENVIRONMENT.md\`, \`docs/P3_UX_MAIN_MAP.md\`, \`docs/P3_ASSET_REGISTRY.json\`, \`docs/P3_2_ASSET_MANIFEST.md\`, \`docs/handoffs/2026-10-24/TMB_PR28_S1_END_TO_END_ISSUE_MATRIX_2026-10-24.md\`.
- Repository-wide branch audit on \`docs/full-branch-audit-nextsteps-20261025\` is context only; **do not merge 100+ old experiment branches**.
- This handoff docs branch \`docs/map-d1-b-overnight-one-shot-20261025\` is NOT a code-writing branch.

**Refresh each PR and branch HEAD before checkout.** Ensure PR31 code tree still matches baseline and MAP-D0 is ancestor/reference. If any source branch changed, compare precise impact and choose a new isolated feature branch from the latest verified exact tree; do not blindly apply stale scripts or modify source branches.

## 2. Authorized after the owner submits the launch prompt

**Owner is authorizing an isolated OPTION B prototype CODE implementation** in a new worktree/branch and its necessary **focused** QA + screenshots + documents. Not authorizing merge into main, replacing PR31, deleting a branch, broad source editing, a new renderer, a new economy, a new asset pack, reworking game simulation, or changing protected gameplay contracts.

Proposed new CODE branch:
\`feature/map-d1b-functional-hub-playable-20261025\`, base **PR #31 HEAD** (not main, not the docs-only MAP-D0 branch). If branch exists, inspect owner, SHA and working tree first; use a distinctive suffix only if collision/untrusted. Absolutely no force push.

Allowed gameplay-source file:
- \`godot/src/presentation/p3/sect_isometric_world_v1.gd\`: **presentation only** static layout seeds, anchor coordinates, existing layout/route drawing, deterministic decoration, use existing verified MAP25 terrain/path textures, safe culling/placement changes. No new state, simulation or camera authority.

Allowed QA source files:
- \`godot/tests/presentation/sect_iso_main_integration_test.gd\`: update hard-coded visual coordinate expectations only if needed; preserve/strengthen original invariant tests, never delete/circumvent test requirements.
- NEW \`godot/tests/presentation/sect_map_d1b_layout_contract_test.gd\`.
- NEW \`godot/tests/presentation/tmb_map_d1b_real_capture.gd\` for actual P3.2 visual proof. A script that directly draws a fabricated game scene is NOT real capture.
- An additional clearly named \`godot/tests/presentation/sect_map_d1b_camera_pick_test.gd\` is allowed if it avoids bloating other test files.

Allowed evidence/docs:
- \`docs/handoffs/2026-10-25/\` for report, issue matrix, map contracts, screenshots/manifest, read-only asset-gap/provenance report and performance notes.
- \`outputs/map_d1b/\` for compact machine-readable logs and test results **if** paths conform to existing AGENTS/repo limits; otherwise put large transient files in isolated local \`artifacts/map_d1b/\` and commit only lightweight evidence. Preserve SHA and real paths.

**Not allowed:** modifications to \`p3_2_landscape_sect.gd\`, \`sect_map_camera.gd\`, \`sect_map25_source_art.gd\`, \`sect_iso_map_model_v1.gd\`, \`sect_production_worksite_cue.gd\`, any simulation/CARE/Combat/D7/Workspace/SaveService/Warehouse/economy/building authority, scene \`.tscn\`/asset registry, Source A original textures, MAP25 hash manifest, workflow YAML, source art library. If critical problem cannot be repaired within the explicit allowlist, record BLOCKED and exact needed path/justification; DO NOT silently expand scope.

Worktree/Godot safety:
- Use an isolated TEMP test save/userdata, do not run as Windows Administrator.
- Do not reset/clean unrelated Codex worktrees, logs, imports, ZIPs or \`E:\` originals. User Windows computer may have 8GB RAM and historical BSOD under heavy concurrency: **only ONE Godot process at a time**, avoid full suite, cap capture duration and stop if memory/OS instability is observed. Use separate test userdata as existing QA does.
- Preserve PR31 and all PR24–31 as OPEN/DRAFT/UNMERGED. Do not alter their heads.
- Do not intentionally launch FULL/CI; GitHub may auto-trigger Actions on push. Record those runs distinctly as CI_UNKNOWN unless logs show exact cause.

## 3. Baseline code facts / the tricky coupling

Source \`SectIsometricWorldV1\` currently has:
- \`GRID=Vector2i(192,192)\`, \`CHUNK=16\`, \`STARTER=Rect2i(72,72,48,48)\`.
- \`HALF_W=25.0\`, \`HALF_H=13.0\`, iso projected cell 50×26.
- \`VIEW_SIZE=(1280,570)\`, \`MAP_SCREEN_OFFSET=(0,72)\`, a Camera2D inside SubViewport; HUD outside camera.
- \`CENTER_CELL=(90,92)\`, \`SPAWN_CELL=(82,84)\`, \`ROADS_JUNCTION=(91,91)\`, \`TYPE_ANCHORS\` for Hall, Warehouse, Forge, Mine, Linh Lâm, Linh Điền, residence, cultivation etc.
- \`_seed_env02a_geometry\` uses \`SectIsoMapModelV1\` with AStarGrid2D paths only for actual three PV01 landmarks; preview_roads are **presentation**, not disciple gameplay nav.
- \`_load_verified_source_art\` loads only SHA-verified MAP25 textures; currently 32 accepted, 0 missing/rejected. Existing map uses stone_courtyard sparse overlay; other 3 verified stone terrain variants are loaded but not meaningfully used in \`_draw\`.
- \`refresh_from_state\`/ \`_row\` map real BuildingState IDs to visual rows. \`pick_at_screen\` selects real row via ellipse. This must still open real canonical building management panel.
- \`set_legacy_transform\` synchronizes world Camera2D to the existing Control map zoom/pan, a critical cross-layer invariant.
- \`_draw\` uses cached chunk meshes, roads/ground and depth-ordered buildings+decoration. Rewriting renderer, changing Camera2D or adding TileMapLayer is disallowed.
- \`sect_iso_main_integration_test.gd\` checks one Source A landmark per true PV01, unique managed producer instance IDs, clickable Mine, camera sync and non-mutation of SimulationState. Do not weaken these rules.

**Clarify MAP-D1 proposed packet's apparent contradiction:** "anchors unchanged" means **same destination keys, BuildingState IDs, authority and gameplay ownership**. OPTION B necessarily changes some **visual coordinate values** in \`TYPE_ANCHORS\`, \`ROADS_JUNCTION\` and decor positions. Such presentation-position changes are explicitly allowed if source identity/picking/routing and QA remain correct. Do **not** change canonical building definition origin/save schema.

## 4. G0 — Forensic preflight + annotated baseline before touching code

1. Fetch all refs; compare PR31 head and code-tested tree, MAP-D0 D1 file and 6-doc diff; inspect AGENTS.md, map scripts/tests in full, asset manifest, PR31 evidence manifest.
2. Record Git clean status, exact origin SHA/tree, Godot engine SHA/version, working directory, Windows limitations. Any uncommitted unrelated work = preserve/copy to isolated location, do not overwrite.
3. Read 19 screenshots; distinguish 00–08/16/17/18 sect map vs 09–15 hunting world. Derive **same camera/world coordinate and same state** baseline images for later before/after.
4. Re-run a **small baseline focused smoke** (map, asset gate, O9 at most, unless current repo makes one unavailable). This is an environment readiness gate, not a request to redo full PR31 QA before editing.
5. Build a mapping table: destination key → original visual grid anchor → origin/footprint for three PV01 real images → current screen coordinate at zoom1 → real BuildingState ID lookup → pickability. Record all constants and draw sorting assumptions.
6. Check only REAL verified assets with SHA. Count and categorize 4 terrain/6 roads/19 props/3 buildings. Confirm 570183 unused before making any decision to use it.
7. If official 4.7.2 unavailable locally, don't pretend QA passed; you MAY still produce code + static checks + docs but label runtime BLOCKED. Do not download/run untrusted binary.

## 5. G1 — Option B full visual composition and exact grid layout

Design and implement a connected, compact **entry/courtyard/main hall visual axis** in starter Rect 72,72,48,48. Organize three functional districts in the same continuous world:
- **Hall/Courtyard core:** Main Hall \`510052\` as focal point, ample visible courtyard, approach from existing spawn/entry corridor. The "Gate" may be a reserved point **without claiming verified Gate art**.
- **Production:** Forge \`520081\` and Warehouse \`510102\` as a recognizable cluster with practical road network; Mỏ, Linh Lâm and Linh Điền remain ACTUAL producer markers with canonical IDs/worksite progress, not relabeled crystals/trees as full verified buildings.
- **Life/Cultivation:** arrange authentic destination markers for residence, cultivation, medicine/other existing UI destinations where available; label \`ART_GAP\` in documentation, not a faked graphical building in live map. Use actual verified trees/stone to provide boundaries and meaning.
- **Outskirts/reserve:** preserve free space to later expand district C within 192×192 (no unlock/save/rebuild code now).

Respect **fixed** 192×192/chunk16/starter48/projection/one camera. B should be visibly different from A: the default zoom shows intentional Hall + court + connected economic cluster, readable spaces and clustered zones. Avoid massive empty green region and severe zoom1.35 crop for focal buildings. User still must be able to pan/zoom freely, not auto-follow one disciple.

Before coding final positions, compute screen/world projected footprints, on-screen safe bounds at default zoom and edge HUD zones. Prefer ID-keyed deterministic layout table over scattered arithmetic, but keep footprint logic inside existing file. Do not alter producer building IDs, clock, worker destination authority or SaveService. Where actual P3.2 landmark actor movement depends on visual anchors, validate transform and interaction against scene instead of assuming.

## 6. G2 — Road/terrain/detail work with only existing assets

Within \`sect_isometric_world_v1.gd\` only, make a realistic, attractive and economical Source A **presentation** improvement:
1. Connect spawn/entry point→main courtyard→Main Hall doorway using real \`SectIsoMapModelV1\` routing, then hub→Forge, Warehouse and route vicinity of genuine Mine/Forest/Field sites. Add a clear "spine + branches" composition; no road through the three placed PV01 footprints, no dead-end inaccessible waypoint.
2. The \`_seed_env02a_geometry\` currently validates Hall/Warehouse/Forge only. Retain this validation; add additional **visual route endpoints** for producers only if physically reachable, without inserting fake producer buildings into \`lab_geometry\`. Explicitly distinguish route reachable cell from a simulated worker path.
3. Use verified 4 terrain textures conservatively to differentiate stone courtyard, walkway fringe and reserve; keep actual performance reasonable and labels legible. Do not tile giant new ground images or invent unverified grass/water/mountain tiles. Keep existing cached chunk meshes and overlays where possible.
4. Recluster verified vegetation/props to shape districts, leaving roof and tap target unobstructed. Reuse \`570183\` ONLY if exact MAP25 verified entry matches and it truly fits visually; its absence from prior DECOR_LAYOUT is not a license to invent its identity. Avoid props over path, footprint or live worker cues.
5. Ensure stable depth sorting, texture extents, transparency, screen edge crop, and fixed overlays. No fake work animations, excavation, crops, buildings, Boss, camera transitions or World-MAP.
6. Keep \`refresh_from_state\` idempotent, \`queue_redraw\` only where needed. Do not produce a per-frame O(192×192) CPU loop, repeated texture loads per frame, or new 2D world authority.
7. Save gameplay state **before and after rendering/picking/panning**; exactly identical unless test itself executes legitimate simulation actions.

## 7. G3 — Static/dynamic geometry + selection tests; FAIL-CLOSED

Add the **new focused contract** \`sect_map_d1b_layout_contract_test.gd\` with clear PASS/FAIL marker, includes:
- Fixed GRID=192×192 / CHUNK=16 / STARTER 48×48 / projection HALF_W/HALF_H / camera safe viewport=1280×570.
- All visual key destination IDs remain unique/stable, no synthetic BuildingState/duplicated managed instance IDs; actual Mine/Forest/Field counts match SimulationState.
- Distinct source art landmarks Main Hall 510052, Warehouse 510102, Forge 520081 each shown once; their real PV01 footprints do not overlap; each source image still SHA-gated.
- Main Hall visually in starter and within default readable viewport; Forge/Warehouse readable and selectable, key managed Mine accessible on default or via verified pan/focus.
- Corridor/waypoints for spawn→courtyard→Hall and branches to Warehouse/Forge and reachable approach cells for producer sites; no paths through occupied landmark cells, all inside starter as appropriate.
- AStar preview traversability and building selected hit tests at 0.75/1.0/1.35/1.80 zoom and representative pan positions; screen point must belong to map viewport for selection, not HUD. Do not assert every site must appear in default 1280x570 frame simultaneously if this would crush scene scale.
- Save/state invariant: same snapshot before and after redraw, camera pan, zoom, selection and opening panels (excluding intentional user action).
- Layout deterministic across two scene loads and camera movement; no flashing/sprite duplicate and no missing verified textures.
- Error messages identify destination, actual cell, expected route/hit target and offending camera transform, not just "FAIL".

Keep original \`sect_iso_main_integration_test\` and camera/Source A tests; if a historical test hardcodes old visual coordinates, update precisely for new *presentation-only* coordinates and preserve its data identity assertions. Don't delete a failing assertion to get green.

## 8. G4 — Real P3.2 runtime proof + screenshot gallery

Author bounded \`tmb_map_d1b_real_capture.gd\` that INSTANCES THE ACTUAL \`res://scenes/p3/p3_2_landscape_sect.tscn\`, not a static SVG. Capture:
1. Same-state A/PR31 default baseline vs B default (same zoom, viewport and stable random seed); source originals untouched.
2. Default starter whole scene with buildings, roads, terrain and worker; 1280×720.
3. Close focus on Hall/courtyard; producer cluster; life/cultivation markers; vegetation depth and roof.
4. Zoom 0.75, 1.0, 1.35 and 1.80; 4 pan-boundary frames; saved camera positions + transform.
5. Click/tap actual \`mine_001\`, \`linh_forest_001\`, \`spirit_field_001\` with selected instance id and actual source-backed panel; verify production worker/ETA labels remained canonical.
6. Actual Mine settlement state after worker's mine→haul→warehouse cycle, not visually fabricated worker action. Show one batch credited Warehouse, logged generation and non-duplication.
7. Same scene real D7 male/female profiles and combat-return-to-sect if feasible within isolated QA runtime, or explicitly use the existing PR31 19-frame regression for non-map sections AND label them baseline, not new MAP-D1 screenshots.
8. Show a before/after contact sheet with equivalent state/camera frames, scene capture manifest incl. git SHA/tree, renderer, viewport, screenshot hash, actor/BuildingState IDs, selection ID, map pan/zoom, visible chunks and source asset manifest. Use screenshot IDs, do not replace baseline evidence.
9. No Photoshop-style fake gameplay, hard-coded fake inventory/camera screenshot, no map screenshot derived from static SVG mislabeled as runtime.

**Visual acceptance test:** compare image side by side for hierarchy, roof overlap, text contrast/occlusion, empty ground, clear roads, production site visibility and true asset provenance. Make an honest issue matrix even if Option B still looks incomplete because art is missing.

## 9. G5 — Regression on EXACT final combined tree

Run all **affected presentation-focused tests first**:
- \`sect_iso_main_integration_test.gd\`
- \`sect_iso_projection_contract_test.gd\`
- \`p3_2_map_camera_test.gd\`
- \`sect_map25_verified_art_gate_test.gd\`
- \`sect_g1_disciple_radar_test.gd\`
- \`tmb_pr27_ui_readability_test.gd\`
- \`pr28_s1_combat_status_presenter_test.gd\`
- \`p3_o9_m2_production_rehearsal_test.gd\`
- New layout contract and capture harness acceptance
- Include worksite/CARE/Save focused scripts as relevant to changed map logic.

Then run exact **PR31 28-test focused suite** from \`docs/handoffs/2026-10-24/evidence/packet-b/sha4b02/focused_results.csv\` in addition to new map tests, and re-run S1 edge 56 checks. Deduplicate paths. Re-run entire deduplicated scoped suite on **final code SHA** after last accepted patch. Capture Godot version, command, UTC/local timestamp, isolated userdata, run exit, PASS marker, script/parse/assert messages, result CSV and log hashes. A final HEAD differing only in docs/evidence can cite tested SHA/tree; a new code change invalidates results until rerun.

If Windows certificate store warnings recur, classify as environment diagnostic and preserve literal warning; if script assertions fail, do NOT suppress or recategorize as benign. If GitHub Actions pushes auto-run, record status without claiming CI PASS or treating unknown remote FAIL as proven gameplay failure.

**HARD gate:** 28/28 existing focused (or precise equivalent after documented file de-duplication) PASS on integrated B final code, edge 56/56 checks PASS, new B layout/selection/genuine-source screenshots evidence PASS. If failed, fix within allowlist and repeat; else \`MAP_D1B_BLOCKED\`, not "done".

## 10. G6 — Performance profiling that fits an 8GB Windows development PC

Do NOT claim a 3-frame screenshot FPS counter is a benchmark. Capture:
- Godot official 4.7.2 renderer/GPU/driver, Windows OS, viewport size, process memory (clearly labeled metric: working set/private bytes/engine static memory), mean/min/percentile frame time where measurable.
- Camera stationary default, continuous pan path, zoom extremes, selected-building + production panel, vegetation and dense HUD in bounded runs. Use e.g. 60-120s per representative scene only if system stable and load is reasonable, one Godot process.
- Active chunk counts and cached chunk mesh counts over time, stale/culling assertion, redraw count and asset counts where available.
- Compare to PR31 baseline only if EXACT same test methodology/hardware/data; if baseline is only screenshots FPS1-24, label NOT_COMPARABLE.
- If memory/profile APIs unavailable, do not invent FPS/RAM. Record diagnostic or PARTIAL; continue map QA.
- Android 1280×720 real touch, prolonged human mouse, owner visual acceptance remain PENDING unless genuinely performed. No auto-claim of real device PASS.

## 11. G7 — Asset archaeology / missing-art ledger (read-only extra work)

The 32 MAP25 PNGs: **4 terrain, 6 roads, 19 props, 3 building**. Build a concrete ledger:
- File relative path, group, SHA, byte count, dimensions, actual usage by layout B, preview/viewport appearance, role confidence, whether palette/texture/tint useful.
- Distinguish BUILDING (Main Hall 510052 / Warehouse 510102 / Forge 520081) vs decoration crystal/bush/tree and actual worker site IDs. Never rename prop 570073 into "Mine Building".
- Missing Gate, residence, cultivation site, Mine/Forest/Field authentic building, water/bridge, path variants, agricultural textures. Mark RESTORE_FROM_VERIFIED_SOURCE / SOURCE_CANDIDATE_NEEDS_REVIEW / CREATE_NEW_PROPOSAL / MISSING / REJECTED, with exact dependency fingerprints if evidence exists.
- Search only permitted local/repo asset manifests and any legitimately accessible owned Source A staging. Do not use private Drive links unless connected through an authorized tool; do not copy raw unknown-provenance packs or exfiltrate non-project materials.
- If suitable packs exist in repo/workspace, generate docs-only contact sheet/catalog with actual SHA/clip manifest and dependency info, **DO NOT integrate** unverified pack into MAP-D1B running game. This research may extend to Source A/Spine library, without modifying it.
- Produce a future ART-D2 batch plan ordered by visual payoff and effort (Gate/road, Mine, Field, Forest, residence, cultivation, background), with import/QA criteria. This does **not** authorize new original art production/import.

## 12. G8 — Build packaging, README, UX walkthrough

Once technical map QA passes:
- Attempt a **new** portable Windows Godot project+launcher candidate with B map from final SHA (not reuse old PR31 ZIP as if it contained B). Isolate saves, preserve original PR31 ZIP. Verify launch and smoke exit 0 with actual Godot.
- If export templates are accessible, optionally export a standalone Windows game and smoke-check (no global install/admin); if templates absent, clearly label PROJECT+LAUNCHER only.
- Avoid committing enormous ZIP or raw art to Git unless existing artifact channel approved; record real local location, byte count, SHA-256 and how owner gets it. A local \`E:\` path is not a browser download URL.
- Write concise Vietnamese HOW_TO_PLAY/ACCEPT_B for owner: map camera drag + zoom, visit Hall, click Mine, see production, return from hunt, screenshots to compare. Include known visual/UX gaps.
- Add a 1-page A vs B technical difference and screenshot index. Never present this prototype as owner-visual-approved.

## 13. G9 — GitHub delivery, evidence provenance, cleanup policy

One new code branch \`feature/map-d1b-functional-hub-playable-20261025\`, base exact PR31 updated HEAD. Push commits only to new branch. Open **one Draft PR stacked on PR31 branch** \`integration/pr28-combat-v3-s1-playable-qa-20261024\`; never main and never old #28/#29/#30. If an intended same-branch PR exists, update safely rather than duplicate.

Required deliverables:
1. \`TMB_MAP_D1B_IMPLEMENTATION_REPORT_2026-10-25.md\`: baseline SHA/tested SHA/tree, layout coordinates before/after, source code diff & path allowlist, exact collision/route/pick policy, known gaps.
2. \`TMB_MAP_D1B_QA_RESULTS_2026-10-25.csv\`: full focused matrix + new tests, exact Godot engine/exit/marker/log SHA; don't hide any failed first attempt.
3. \`TMB_MAP_D1B_BEFORE_AFTER_VISUAL_REVIEW_2026-10-25.md\`: true source screenshots, SHA manifest, A vs B comparison, photos/crops where feasible, readable owner acceptance criteria.
4. \`TMB_MAP_D1B_SOURCE_A_ASSET_GAP_AND_RECOVERY_PLAN_2026-10-25.md\`: verified asset paths, hashes, clip/no-clip, missing building/terrain priorities, zero unverified runtime copies.
5. \`TMB_MAP_D1B_PERFORMANCE_PROFILE_2026-10-25.md\`: measured methodology, limitations, 8GB device, chunk/texture/data caches.
6. \`TMB_MAP_D1B_ISSUE_MATRIX_2026-10-25.md\`: P0/P1/P2 exact blockers, impact/proof and owner-PENDING.
7. \`TMB_MAP_D1B_NEXT_HANDOFF_2026-10-25.md\`: next safe changes after owner visual check, possible Option C scale design and mainline cutover dependency; **do not auto-code C or cutover**.
8. \`docs/handoffs/2026-10-25/evidence/map-d1b/<exact_short_sha>/\` for bounded real PNG screenshots, capture manifest, focused CSV, and small useful logs. Large generated caches and portable ZIP stay local.

GitHub PR body must clearly say **DRAFT, NOT MERGED, NO OWNER VISUAL, NOT RELEASE**, list specific commits and evidence links. Preserve all baseline screenshots, PR31 logs and older worktrees. Do not auto-delete old branches, reset old profiles, close PRs, adjust GitHub workflows or claim CI green.

## 14. Extended optional work if main deliverable is complete (does NOT broaden code scope)

If all above gates pass and meaningful capacity remains, do more **READ-ONLY / DOCS** work instead of stopping immediately:
- Create a more exact future 192×192 district expansion map **C design** as downstream of B, distinguish visual LOD from live buildings and 1k–3k roster population; no implementation.
- Source A preservation plan for missing Gate, 30 Mine / 30 Forest / 40 Field layout scaling; reserve future zones but don't instantiate new buildings.
- Develop route and click probability/coverage stress fixtures on current new B code WITHOUT changing locked simulation/runtime. Camera reachable screen fraction across zoom levels, high-actor visibility and occlusion static analysis.
- Prepare one future "MAP-D2 art-first" program with realistic asset count, QA gate and source provenance, one responsible writer per file. No downloading Internet asset substitutes.
- Compare future human accessibility on Windows vs Android landscape; precise requested touch tests/UX screenshot evidence only, no claim of physical PASS.
- Summarize exact changes of Option B vs A and why chosen, and what is blocked by unavailable art before claiming a beautiful final map.

## 15. Definitive gates, escalation and guardrails

Statuses must be: \`D1B_CODE_IN_PROGRESS\`, \`D1B_FOCUSED_PASS\`, \`D1B_SCREENSHOT_PASS\`, \`D1B_ART_GAP_PENDING\`, \`D1B_OWNER_VISUAL_PENDING\`, \`D1B_RUNTIME_BLOCKED\`, \`D1B_PERF_UNVERIFIED\`, \`D1B_NOT_RELEASE\`.
**Do NOT** pronounce FULL PASS or Android/manual PASS from scripts.

Expected success:
- A visibly improved **one-map** sect Option B prototype from PR31 source, 192×192/chunk16/starter48 still intact.
- Correct actual Hall/Forge/Warehouse art, accessible producer sites and canonical workers/Kho unchanged, road topology clear, no duplicated simulations.
- Official Godot 4.7.2 import/play + PR31 full 28 scoped focused + 56 S1 edges + added map tests pass on final exact code tree, before/after real 1280×720 frames and hashes.
- Bounded performance observations, asset provenance and gap plan, new Draft PR/owner gallery, portable candidate if reproducible.

If scope-locked failure cannot be fixed, preserve partial code and all logs on isolated new branch, mark \`BLOCKED\` with file/line/contract, continue independent read-only asset/visual/design tasks, and leave a detailed one-shot handoff. Do NOT weaken a test, bypass integrity, edit disallowed files, invent Source A assets, or ask user for minor implementation choices.

Do not run unbounded retry loops. Prioritize G0–G5 code and QA, then G6–G9 evidence/delivery, then optional docs. Commit logical checkpoints for safety but **do not pause for permission at every commit**. The owner needs only ONE review when the full candidate is ready.

## 16. PASTE INTO CODEX — code authorization occurs only when owner deliberately sends this

TÔNG MÔN BÁ ĐẠO — TÔI CẤP PHÉP LÀM MAP-D1B, MỘT GÓI CODEX DÀI END-TO-END.

Trên GitHub \`vuanhtuan161094-byte/TongMonBaDao\`, đọc toàn bộ:
\`docs/map-d1-b-overnight-one-shot-20261025/docs/handoffs/2026-10-25/TMB_MAP_D1_B_OVERNIGHT_END_TO_END_CODEX_PACKET_2026-10-25.md\`,
MAP-D0 report, asset matrix và D1 proposed packet trên nhánh \`docs/map-d0-sect-main-redesign-20261025\`, AGENTS.md, và PR31/evidence. Tôi chọn **B làm phương án PROTOTYPE** để có bản chạy thật, chưa phê duyệt cuối về hình ảnh.

Thực hiện trọn một lần, tự xử lý các nhiệm vụ G0–G9. Tạo worktree và feature branch RIÊNG từ HEAD PR31; giữ nguyên PR31/PR24–30/main. **Tôi cho phép sửa code presentation trong file \`sect_isometric_world_v1.gd\`, cập nhật/viết focused tests và harness capture trong allowlist nêu ở packet, commit lên nhánh mới và mở một Draft PR đặt base là PR31.** Giữ nguyên tất cả simulation/CARE/Combat/D7/OneActiveJob/Warehouse/Save, Source A master/32 SHA-gated assets, scene/controller/map camera/renderer hiện hữu và gameplay săn Thanh Trúc Lâm.

Triển khai bố cục B trục cổng/dự trữ→sân→Đại Điện, ba khu, đường thật có AStar preview, sắp xếp lại art đã verified, xử lý nền xanh lặp lại bằng terrain MAP25 có thật, đảm bảo các công trình site thật vẫn bấm được. Không giả công trình, không import asset thiếu/chưa xác minh, không code Boss/S2/map săn, không thêm camera/clock/save authority khác.

Chạy Godot official 4.7.2 trên bản kết hợp cuối: toàn bộ 28 focused tests PR31, 56 S1 edge checks, các map tests mới và capture P3.2 thật 1280×720. Có ảnh BEFORE/AFTER cùng camera/state, địa hình/đường/3 khu, pick các worksite, mẻ Mỏ đã trả Kho, kiểm tra map pan/zoom/culling, số liệu FPS/RAM có phương pháp và hash nguồn/ảnh. Tự sửa lỗi trong allowlist rồi rerun. Một máy chỉ chạy một Godot process; không FULL/CI có chủ đích hoặc giả PASS.

Tiếp tục kiểm kê sâu asset Source A đã có và thiếu, tính kế hoạch bổ sung Gate/Mỏ/Linh Lâm/Linh Điền/địa hình, nghiên cứu future District C ở mức DOCS ONLY sau khi đã xong bản B. Nếu công cụ có thể, đóng gói project Windows portable riêng, ghi SHA và smoke result.

Bàn giao **một Draft PR mới** + báo cáo đầy đủ, bảng QA, ma trận issue, gallery ảnh thật, manifest, asset gap, FPS/RAM ghi đúng giới hạn và hướng dẫn người chơi. Không chia nhỏ thành nhiều packet cần owner phê duyệt; chỉ dừng nếu blocker vượt quyền code, nhưng phải hoàn tất các việc độc lập còn làm được. Không merge, không retarget PR cũ, không đụng main, không thay đổi gameplay ngoài phạm vi map.

Tôi muốn nhận được một map B prototype chạy được và evidence thật, không chỉ một file kế hoạch. Owner Visual/Windows human/Android vẫn PENDING cho đến khi được duyệt và chạy thật.
