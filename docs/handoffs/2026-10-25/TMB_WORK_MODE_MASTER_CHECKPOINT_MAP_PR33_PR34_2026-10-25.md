# TÔNG MÔN BÁ ĐẠO — MASTER WORK MODE HANDOFF / 2026-10-25
## Freeze status, identify exact refs, then stabilize and integrate TWO maps

**Prepared:** 2026-10-25 (Asia/Bangkok). **Purpose:** Single authoritative operational checkpoint for an upcoming **ChatGPT Work** task, without relying on long chat context. This file is a **status snapshot + explicit suggested next packet**, not proof of QA and not an authorization to merge or destroy code. The owner is currently without usable access to a Windows PC/Codex. GitHub must be used directly when possible.

**Repository:** [vuanhtuan161094-byte/TongMonBaDao](https://github.com/vuanhtuan161094-byte/TongMonBaDao)
**Game:** original Godot **4.7.2**, Android landscape **1280×720**, Windows development/acceptance, graphics policy **Source A chibi/xianxia**. Combat V2 is authoritative; V3-S1 learned skill effects must follow actual Combat V2 runtime, not a second engine. Sect economy, One Active Job, Warehouse, injury, D7, and same-version SaveService exactly-once are protected.

### Read this before acting

1. **Do not restart from main.** PR31 is the last integrated gameplay baseline with recorded Godot PASS; PR32 is tested Option B sect-map prototype. PR33 and PR34 are newer but *NOT official Godot validated*.
2. **Do not conflate worlds:** PR33 map tông môn/sect uses **192×192**, CHUNK16, STARTER48; PR34 real CARE battle display uses authoritative **36×20** local arena. Its separate **256×192** Thanh Trúc Lâm with C01–C20 is a **design-only visual scene**, **NOT** a 300-live-monster RTS world.
3. **Keep source art honest:** 32 MAP25 original Source A PNGs SHA-gated; 3 newly-authored MAP-D2 SVG worksite vignettes are **unapproved original prototypes**, never recovered or historically approved Source A sprites. Old art conversion and JX pilots are not automatic gameplay authority.
4. The preceding map code was edited directly via GitHub due to unavailable Codex/local PC. **Static code changes and remote commits are not Godot tests.** Remote GitHub Actions auto-failures with missing logs are **CI_UNKNOWN**, not established compiler/test failures.
5. Git branches/PRs are concurrently editable. **Refresh exact HEADs before any new work.** Do not assume this document's SHA remains HEAD.
6. **Owner instruction now:** transition progress management from conversation to **Work mode**, with this file as explicit starting point; provide code commits, QA evidence and concise status instead of back-and-forth planning. This instruction does NOT independently approve merging, branch deletion, gameplay authority rewrite or unverified asset promotion.

---

## 1. Exact GitHub snapshot (refreshed 2026-10-25)

| Purpose | PR | Branch HEAD at snapshot | Parent/base | Status |
| --- | --- | --- | --- | --- |
| Official repository trunk | — | \`main@29b5fba448b0178cb520a4ada44b375b4b934e31\` | — | Behind the integrated game; DO NOT develop this workflow directly from main |
| Integrated CARE + D7 + Combat V3-S1 + P3.2 playback | [#31](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/31) | \`integration/pr28-combat-v3-s1-playable-qa-20261024@9eb4fd55733bb49bbb069240b8e332d37d22aced\` | #28 | DRAFT / OPEN / NOT MERGED; code-tested \`4b02a0c61a2771d9d4638129d96b68ad292270dc\`; Godot 4.7.2 official **28/28 focused PASS**, **56/56 V3-S1 checks PASS** on **that tested code tree only** |
| Option B Sect main map (functional hub) | [#32](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/32) | \`feature/map-d1b-functional-hub-playable-20261025@c6bde70f6e98f482c91cd6d2c386e58437877209\` | #31 | DRAFT / OPEN; evidence reports **29/29 focused PASS**, incl. V3-S1 56 edge checks; visual owner signoff remains PENDING |
| Map tông môn D2 candidate illustrations + optimization | [#33](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/33) | \`feature/map-d2-direct-chatgpt-visual-upgrade-20261025@7a551ca4f8f9b15f3069652c5f557e0fbc29833e\` | #32 | DRAFT / OPEN / **GODOT 4.7.2 NOT RUN ON THESE COMMITS**; ART CANDIDATE/OWNER PENDING |
| Map săn CARE visual forest + future 20-camp preview | [#34](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/34) | \`feature/pve-map-presentation-upgrade-20261025@dae86efd37a61e2e82c64ea00608fc062c4b423c\` | #31 | DRAFT / OPEN / **GODOT 4.7.2 NOT RUN ON THESE COMMITS**; 20-camp scene is NOT runtime combat-world implementation |

PR31 and PR32 are **different tested SHAs/trees**. Passing screenshots/CSV must never be copied forward as PR33/PR34 or future integrated-branch PASS.

**Branch relationship:**
\`\`\`text
main -> PR24 -> PR25 -> PR26 -> PR27 -> PR28 -> PR31  [last integrated gameplay baseline]
                                                 |
                                                 +-> PR32  [Option B sect map, tested]
                                                 |     |
                                                 |     +-> PR33  [D2 sect visuals/performance; UNVERIFIED]
                                                 |
                                                 +-> PR34  [CARE forest + 20-camp preview; UNVERIFIED]
\`\`\`
PR29 and PR30 Combat S1 branches were carried into PR31 by selected code net integration; never blindly merge them as additional features. Old standalone C4/JX/Economy/G1 design/code branches are evidence/recovery references, not active gameplay authority.

---

## 2. Verified functionality to PRESERVE (not redo)

**PR31 verified integrated gameplay** at exact code SHA \`4b02a0c61a2771d9d4638129d96b68ad292270dc\`:
- Godot 4.7.2 official 28/28 scoped focused PASS, 56/56 S1 edge checks; this is NOT full/CI/device QA.
- Real Sect P3.2 Source A/map: Mine/Linh Lâm/Linh Điền live canonical BuildingState, actor display, D7 and UI; worksite production \`mine_001\` credited \`thanh_thiet\` 37→39 (+2), via travel_out→mining→haul_back.
- CARE hunt REAL MapBattleV2 and real reward: Thanh Lang kill \`tinh_lang_bi ×1\`, canonical warehouse receipt, exactly-once save/load, respawn same world; real learned \`hoa_cau\` BỎNG, \`han_suong_an\` SUY YẾU and \`kim_cuong_ho_the\` guard.
- 19 authenticated 1280×720 screenshots in PR31 evidence. 09–15 are hunting battle, NOT sect map; do not apply sect-map visual conclusions to them.
- Source A verified MAP25 **32 PNG** manifest with original-byte SHA gate: **4 terrain, 6 roads, 19 props/vegetation, 3 buildings** (Main Hall 510052, Warehouse 510102, Forge 520081).
- PR32 Option B layout: entry/courtyard/Main Hall hierarchy and three function districts, 9 preview routes and camera/pan/zoom; reports 29/29 focused PASS at PR32 SHA. Changes are spatial/layout first, not full missing-building-art recovery.

Known remaining PRE-RELEASE gates: human Windows visual and playtest, physical Android tap/pinch/perf, frame-time sustained/8GB Windows measurement on each changed build, owner visual approval, FULL official CI/integration and eventual approved main cutover. PR32 60-sec observed FPS near 59.74 mean, frame-time p95 about 64.54 ms and working set peak roughly 738.75MiB; cannot claim future perf improvements until SAME-methodology measurements.

---

## 3. PR33 exact code changes / quality risks

**Actual committed code and files** (see [active-index report](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/feature/map-d2-direct-chatgpt-visual-upgrade-20261025/docs/handoffs/2026-10-25/TMB_ACTIVE_BRANCH_INDEX_SAFE_CLEANUP_AND_PERFORMANCE_2026-10-25.md)):
- \`godot/src/presentation/p3/sect_isometric_world_v1.gd\`: camera/chunk map still **192×192,16,48**; optional three site SVG textures, landscape layer draw and softened roads. Added **cached terrain/road rows per chunk**, **one producer-bucket pass** for \`refresh_from_state\`, and **shared AStarGrid2D navigation** for nine startup visual routes, with incremental weight scale 0.7 for newly added road cells. Source A 32 original images not mutated.
- \`godot/src/presentation/p3/sect_map_d2_landscape.gd\`: subdued district palette, stationary visual-only pond/reeds/flowers/stones. Candidate graphics, NOT collision/water/production gameplay.
- \`godot/art/map_d2_candidate/{mine_worksite_v1,linh_forest_worksite_v1,spirit_field_worksite_v1}.svg\` + README: three original static candidate vignettes; **not authentic Source A** and not working animations.
- \`godot/src/presentation/p3/sect_map25_source_art.gd\`: comment correction only; SHA guard logic remains unchanged.
- \`godot/tests/presentation/sect_map_d2_visual_contract_test.gd\`: new focused scene test checking source art status, candidate import, visual state identity, cached terrain/road counts and no SimulationState mutation. **Committed, NOT RUN**.
- Source A runtime adapter view status loads ~30 manifest entries, whereas full MAP25 integrity gate checks all 32; do not confuse these counts.

**Specific WORK audit priorities before testing or integrating:**
1. Godot parser / type inference / RefCounted drawing helper and \`draw_polyline\` / \`draw_texture_rect\` signature and rendering source; validate actual import of SVG \`Texture2D\`.
2. Verify shared navigation equivalence against independent \`SectIsoMapModelV1._navigation()\`: all nine routes identical/semantically valid and no blocked cells or silent path changes. A source code change based on performance intuition is NOT a tested optimization.
3. Confirm cache retains all SOURCE ART tiles, and cache is invalidated or rebuilt whenever its **view-only** road/texture input legitimately changes. In current scene both are seeded at startup. Memory cost must be measured versus frame-time saving.
4. Confirm producer bucket ordering/IDs/positions, selection at different zooms and same-version SaveService no-change. Check multiple instances from each producer class.
5. New SVG appearance at actual game scale; do not promote as approved art without OWNER screenshot decision.
6. Re-run old D1B projection/camera/road/canonical producer tests; do not delete assertions to make new tests PASS.

**Never optimize** by removing source provenance checks, reducing Combat cap or skipping payment/Save integrity. GitHub auto workflows on earlier branch pushes failed with empty/no useful steps and BlobNotFound/404 logs; cause UNKNOWN unless independently proven.

---

## 4. PR34 exact code changes / quality risks

- \`godot/src/presentation/p3/b3_care_hunt_landscape_v2.gd\`: small decorative patches, grass and brush aligned to presentation projection in existing **36×20** CARE arena.
- \`godot/src/presentation/p3/b3_care_combat_v5_presenter.gd\`: selectively draws scenic patches in \`_draw_source_a_forest_floor()\` when already enabled; adds four already-verified Source A trees near stage edges. No change to MapBattleV2, CARE authority or Loot.
- \`godot/src/presentation/p3/pve_world_topology_preview_v1.gd\` and \`godot/scenes/p3/pve_world_topology_preview_v1.tscn\`: **standalone** 1280×720 Control scene visualizing a proposed 256×192 Thanh Trúc Lâm design, 5×4=20 camps C01–C20, 300 normal monsters **as design-only numbers**, river x≈148 with 3 bridges, **30** graph edges. Drag/zoom/camp select, independent from main game. C08→C09 has no bridge. Does **not** run AI, combat, spawn, actual mini-map, loot, one world registry or save.
- \`godot/tests/presentation/{b3_pve_hunt_landscape_contract_test,pve_world_topology_preview_contract_test}.gd\`: newly committed **NOT RUN**; checks no-authority-mutation/projection and 20-camp graph/bridge integrity.
- Recent cleanup removed only unused \`BRIDGE_ROWS\`, \`drag_start\` plus its assignment. The actual \`design_edges\` and \`drag_sum\` remain.

**Specific WORK audit priorities:** script parse, class constants/types, correct overlay order and camera projection at pan/zoom, scene standalone rendering 1280×720, real MapBattleV2 never mutated, graph 30 edges and three bridges. Verify PNG Source A still referenced by real existing paths. Preview must clearly say design-only, never present 300 monsters as live gameplay. Careful: a large 200–400 monster open world requires new authority/registry/spawn-slot and save architecture; NOT authorized by this maintenance packet.

---

## 5. Repository cleanup and access policy

Prior repo-wide enumeration recorded 130+ branches, including dozens of DOCS-only proposals and 27 older Draft PRs. A few have diverged histories, so **bulk cherry-pick/merge is unsafe**. At the last read, \`main\` remained behind integrated gameplay. Do not mark design-only streams as implementation.

One \`main\` repo tree snapshot for PR31 contained ~997 entries; one historical \`outputs/MASTER_RECOVERY_INTEGRATION_20261023/screenshots/f5715ad/master_recovery_p3_2_1280x720.avi\` is ~6.9MB plus numerous small QA logs. Deleting these from HEAD would not remove their Git history and **would not improve run FPS**. They retain actual QA source provenance. The repo has \`godot/.gitignore\` ignoring \`.godot/\`, \`*.tmp\`, \`*.gd.uid\` and reports; do not blanket-ignore art or source evidence.

### Already safely cleaned

- Removed an unused constant \`BRIDGE_ROWS\` and unused mouse-drag state \`drag_start\` and its assignment on PR34.
- Fixed outdated comment in Source A adapter referring to all PNGs missing in older checkout.
- Kept compatibility \`JX_PRIVATE_BACKDROP\` and older exploratory branches, clips, code, logs, asset manifests, save tests, since no full reference-graph+Godot proof exists for deleting them.

### Cleanup rules for Work

- Build a reference graph before proposing *any* file/class/asset removal. Include dynamic loading, \`class_name\`, scene \`.tscn\`, manifest and history references.
- Allowed after explicit owner authorization: remove clearly unreferenced **view-only** branch-local helper variables and test fixtures, with targeted tests. No mass deletion of branches, old evidence or source art by default.
- Keep compact [branch status table] and current commit tree, avoid repeated cross-branch reads for the same live files. Generate a CSV of genuine dead-code candidates, not an unverified "safe to delete" list.
- If repo size should be reduced later, archive hashed evidence to user-authorized Release/Drive and verify its availability **before** deleting from current tree; preserve exact historical SHAs.
- Absolutely no history rewrite or force-push.

---

## 6. NEXT WORK in **one** Work task — short, high-value execution plan

**Suggested identifier:** \`WORK-MAP-QA-INT-01\`.
**Priority:** **Stabilization > integrated evidence > cosmetic expansion > PvE backend design**.

### Stage W0 — Fetch and lock exact refs (required)
- Read this document, \`AGENTS.md\`, \`docs/GAME_SYSTEM_ARCHITECTURE.md\`, \`CURRENT_CHECKPOINT.md\`, \`NEXT_CHAT_HANDOFF.md\`, PR31/32 evidence, both PR33 and PR34 code and tests.
- Refetch current PR31/32/33/34 HEADs and check \`main\` / active worktree. Preserve uncommitted owner changes and branch handles.
- Establish which work runtime is available. If Godot official 4.7.2 exists, use it; otherwise do not misrepresent static checks as game tests. Do not install arbitrary unverified binaries.

### Stage W1 — Static audit and safe isolated corrections
- Review new PR33/PR34 classes, Godot signatures/types, SVG import, road/cache correctness, UI camera and 20-camp graph logic. Fix **substantiated** bugs only on NEW work branches or isolated worktree(s), not overwriting the original PR heads.
- If edits to different branches are needed, a single writer owns their final integration. Preserve baseline references as rollback.
- Reuse/call existing test scripts; add a focused regression only when it materially proves the change. Do NOT weaken tests, fake GUI frames, invent visuals or modify canonical Combat/CARE/Save/Production.

### Stage W2 — Create ONE isolated integration branch, but never main
- Base on verified PR32/PR33 ancestry (latest clean PR33 commit) and cherry-pick **only the net PR34 PvE presentation/test/scene additions** with exact patch comparison. Since PR34 branches from PR31, blindly merging whole histories can duplicate changes or alter PR32; use file-wise guarded compare/patch.
- Suggested name \`integration/map-d2-sect-pve-qa-20261025\` (check for collision first). Keep PR31/32/33/34 untouched and DRAFT. Can create one additional Draft PR stacked on PR33 (if appropriate); no merge of any source PR or retargeting.
- Verify all expected new scripts/resources from both maps load in the integrated project. Record file-level SHA and merged tree. Separate sect map runtime, existing CARE local battle, and proposed 20-camp standalone preview.

### Stage W3 — QA on final exact code SHA/tree
- Official **Godot 4.7.2** import/parse of project; run two new PR34 focused scripts, PR33 D2 visual contract, baseline PR32 29-path scoped suite, V3-S1 56 edge checks and associated CARE/Save/O9/camera/Source A gates.
- If one Godot binary isn't available, STOP claiming runtime PASS; deliver exact scripts/commands, static review outcomes, missing environment and next actionable runtime gate. No false test numbers.
- Actual P3.2 screenshots 1280×720: default sect map, Hall, Mine/Forest/Field panel; CARE hunting with actors/HP/status; standalone topology preview 20 camps and 3 bridges; before/after SHA/source manifest.
- Measure FPS/frame-time p95/p99 and RAM/working set by *repeatable methodology*, compare to PR32 only if same hardware/profile. Avoid concurrent Godot jobs on Windows 8GB.
- Test input: desktop mouse drag/zoom/click; Android physical touch remains PENDING until actual device available.

### Stage W4 — Deliver concise status + safe archive candidates
- Commit exact changes on new integration branch only; produce one concise Markdown \`TMB_WORK_MAP_QA_INTEGRATION_RESULT_<DATE>.md\` with SHA/table PASS/FAIL/BLOCKED, real log paths, screenshot hashes, art provenance, exact extra file changes and open blockers.
- Draft PR (if code changes) with **DRAFT / QA status honest / not owner-approved**, no merging or cleanup of old branches.
- Keep external owner review as one final decision: approve or reject real sect/PvE visuals, then authorize later main cutover separately.
- File cleanup may include **unreferenced new branch-local scaffolding** only after proof, not historic art/screenshots/logs.

### Future work not automatically authorized
- 20-camp world authority: 200–400 **live** monsters, ≤30 disciples, real FarmArea/RTS orders/path/aggro/respawn/loot journal, Boss coop and save migration. See \`docs/ttl-20-camps-map-topology-five-difficulties-design-20261024\`; existing Combat V2 arena is only 36×20 and max40 active monsters per *battle*, not a true 300-monster open world. This is an independent major gameplay CODE packet that needs owner scope decision and tests.
- Original approved building art recovery and replacement of provisional SVG, further environment work: asset source/hashes and owner visual approval required.
- One-main trunk consolidation/old PR closure: after full cutover gate and explicit owner authorization.
- New tests or artifacts must not silently widen gameplay authority.

---

## 7. Status board for Work

- [x] PR31 gameplay integration baseline recorded (28/28 focused and 56/56 S1 on tested SHA).
- [x] PR32 Sect Option B recorded (29/29 focused claimed in PR evidence; owner visual pending).
- [x] PR33 code for map visuals, optional 3 worksite SVGs, chunk overlay cache/producer bucket/AStar reuse committed.
- [x] PR34 PvE battle scenery and 20-camp standalone design preview committed.
- [x] PR34 removed unused \`BRIDGE_ROWS\` and \`drag_start\`.
- [x] Repo references and opt-in preservation rules documented.
- [ ] PR33 official Godot import/parse/focused QA at new exact SHA.
- [ ] PR34 official Godot import/parse/focused QA at new exact SHA.
- [ ] Combined PR33+PR34 integrated worktree and official Godot focused regression.
- [ ] 1280×720 **real** combined before/after screenshot capture and owner visual acceptance.
- [ ] Measured frame time/RAM and actual Windows/Android interaction checks.
- [ ] Clear archive/supersede candidates with proof; no mass deletion.
- [ ] Release/main cutover plan and explicit merge permission.
- [ ] Future 20-camp 300-live-monster gameplay world (NOT in these PRs).

### Blockers / exact status vocabulary

\`CODE_COMMITTED\`: GitHub file exists at named ref, not inherently playable.  
\`STATIC_REVIEWED\`: source or schema inspected, not Godot parser proof.  
\`GODOT_QA_PASS\`: only after exact official engine invocation, stdout marker, exit and logs on exact SHA.  
\`CI_UNKNOWN\`: Actions remote failure without usable cause/provenance.  
\`ART_CANDIDATE_UNAPPROVED\`: original substitute/vignette, not Source A approved.  
\`OWNER_VISUAL_PENDING\`, \`WINDOWS_MANUAL_PENDING\`, \`ANDROID_PENDING\`, \`NOT_RELEASE\`: remain until direct evidence.

---

## 8. Ready-to-paste single Work assignment

**TÔNG MÔN BÁ ĐẠO — WORK-MAP-QA-INT-01**

Hãy nhận dự án GitHub \`vuanhtuan161094-byte/TongMonBaDao\`. Đầu tiên đọc TOÀN BỘ tài liệu checkpoint tại nhánh \`docs/work-mode-handoff-map-qa-integration-20261025\`, đường dẫn \`docs/handoffs/2026-10-25/TMB_WORK_MODE_MASTER_CHECKPOINT_MAP_PR33_PR34_2026-10-25.md\` và \`AGENTS.md\`. Tôi không thể mở PC/Codex hiện tại, nên **tự làm trực tiếp qua GitHub và runtime/cloud computer được cấp quyền**.

Làm một gói END-TO-END theo Stage W0–W4: kiểm toán PR33/PR34, sửa lỗi static thực có, tích hợp hai map trên nhánh QA RIÊNG từ PR33 (không chạm gốc), chuẩn bị và chạy Godot official 4.7.2 nếu môi trường thực có, kiểm thử source art, camera, các test mới, full scoped PR32 và Combat S1, capture scene P3.2/CARE/PvE topology thật 1280×720; đo FPS/RAM nếu khả thi. Chỉ báo PASS với stdout/exit/log và exact SHA, tuyệt đối không lấy test PR32 làm test mới. Nếu thiếu Godot, hoàn tất mọi phần kiểm toán/cấu hình/tích hợp độc lập và ghi BLOCKED chính xác, không giả PASS.

Có thể xóa biến/helper branch-local **chứng minh được không còn dùng**, nhưng KHÔNG xóa hàng loạt nhánh/PR, Source A 32 PNG, raw asset, bằng chứng, test, gameplay/save hoặc viết lại lịch sử. Không làm thêm World PvE 300 live monsters, Boss, loot backend, migration hay main cutover trong gói này.

Kết quả bàn giao phải là **một Draft PR mới hoặc branch tích hợp mới + một Markdown báo cáo status**, gồm bảng DONE/PENDING/FAIL, tất cả thay đổi thực tế, chính xác commit/tree và bằng chứng, phần owner cần quyết định tiếp. Không chia thành hàng chục câu hỏi; tự xử lý trong quyền được cấp, không merge bất kỳ PR nào lên main.

**End of frozen handoff.**
