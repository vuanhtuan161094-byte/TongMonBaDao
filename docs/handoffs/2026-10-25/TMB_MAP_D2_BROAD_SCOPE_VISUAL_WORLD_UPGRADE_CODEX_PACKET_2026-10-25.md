# TÔNG MÔN BÁ ĐẠO — MAP-D2 / REAL VISUAL WORLD UPGRADE (BROAD SYSTEM SCOPE)
Date: 2026-10-25 · Owner-startable single long Codex job, not a new release or automatic merge.
Repository: `vuanhtuan161094-byte/TongMonBaDao` · official Godot 4.7.2 · Android 1280×720 landscape · Windows proof.
**Correction:** MAP-D1B was artificially constrained to ONE production script. It passed focused tests but only moved a few buildings/roads/trees. This packet MUST NOT repeat that failure. **Authorize the whole map-presentation/art pipeline as a work domain**, with specific canonical gameplay boundaries. Allow necessary multi-file refactors and test tools. Judge the result by **actual high-quality playable visual improvement**, not number of changed lines, files, commits or easy green test markers.

## 0. What "DONE" means

Create a noticeably better, cohesive, alive, distinctly Chinese-xianxia **Source A style sect main map** running in the real P3.2 game, not another rectangle/road rearrangement on green checkerboard. It must look different in real screenshots, communicate useful zones *without persistent floating labels*, read on a phone, use authentic building and terrain sprites where legitimately recoverable, and preserve real Mine/Forest/Field/Combat/CARE/Save/OneActiveJob functionality.

**Do not claim MAP-D2 VISUAL PASS solely on 29/29 focused tests, moving grid anchors, laying a stone road, changing green tints, renaming crystal prop to Mine, or writing >20k characters of reports.** The visual sign-off is still owner's. Provide before/after **real game** PNGs so the owner can inspect a genuine change. If source art cannot be recovered and no sufficiently good safe provisional art can be produced, stop making the game uglier: submit an art gap/visual BLOCKED report and authentic asset catalog, not fake visual completion.

Do not optimize for "more code." Optimize for a real coherent playable game map using as much legitimate source material as possible. Avoid unsupported "work overnight" time estimates; run until the scoped work is genuinely done or bounded blocker/limits prevent it. One user authorization; autonomously carry out internal phases without micro-approval.

## 1. Exact known baseline, ancestry and status

- PR #31, integration gameplay, HEAD at publication: `9eb4fd55733bb49bbb069240b8e332d37d22aced`, tested code `4b02a0c61a2771d9d4638129d96b68ad292270dc`. 28/28 focused and 56 Combat S1 edge checks, 19 real GUI frames.
- PR #32, OPTION B map prototype, HEAD at publication: `c6bde70f6e98f482c91cd6d2c386e58437877209`, branch `feature/map-d1b-functional-hub-playable-20261025`, base PR31, OPEN/DRAFT/UNMERGED. 29/29 focused tests PASS claimed in evidence and official Godot 4.7.2 logs; 56 Combat S1 edge checks; 32 Source A MAP25 SHA-gated accepted; 60 sec Windows samples mean FPS 59.74, but frame-time p95 64.54ms, working set peak 738.75 MiB; manual/Android/owner approval PENDING.
- Main `29b5fba448b0178cb520a4ada44b375b4b934e31` lacks the integration chain. Do NOT start from main or rebuild from zero.
- MAP-D0 branch `docs/map-d0-sect-main-redesign-20261025` @ `25cb7a0f59a93ddcccc8a5d6acf1dd8e2290874f` contains A/B/C schematic and asset evidence.
- MAP-D2 packet docs branch `docs/map-d2-visual-rebuild-broad-scope-20261025` is based on PR32 with one new Markdown. This DOCUMENT is a proposal; runtime/art CODE permission is only granted when the owner sends the Section 12 launch prompt.

**Always refresh PR31/32/branch refs live before checkout.** If SHA changed, compare net code/test/assets and record diff. Don't force-reset anyone's remote branch or worktree.

Read, in order:
1. `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`.
2. `docs/P3_PRESENTATION_MASTER.md`, `docs/P3_ART_BIBLE.md`, `docs/P3_ASSET_MAP_ENVIRONMENT.md`, `docs/P3_ASSET_BUILDINGS.md`, `docs/P3_SOURCE_RECOVERY_MANIFEST.md`, `docs/P3_ASSET_REGISTRY.json`.
3. PR32 implementation report `docs/handoffs/2026-10-25/TMB_MAP_D1B_OPTION_B_IMPLEMENTATION_REPORT_2026-10-25.md`, before/after `outputs/map_d1b/before/final_sha_baseline.png`, `outputs/map_d1b/after/final_sha_candidate.png`, 29-test matrix and source_a_asset_matrix.
4. MAP-D0 report, 3 SVGs, MAP-D1B District C/LOD plan.
5. Repo/labs/older branches and approved owned Source A/JX asset staging as SOURCE MATERIAL ONLY, never alternate gameplay authority.

## 2. Explicit owner CODE/ART scope — broad by responsibility, not one arbitrary file

When the owner submits Section 12, **CODE scope = the entire SECT MAP PRESENTATION + ART RECOVERY/CONVERSION + relevant UI INTEGRATION domain**. This overrides D1B's one-file allowlist for MAP-D2 only. One Codex writer/one isolated integration worktree.

Allowed to edit/create multiple files when required (record exact changed paths + rationale afterwards):
- `godot/src/presentation/p3/**`: world layer, isometric world, art adapter, draw order, camera adapter, map model's **read-only view navigation**, Source A presentation mapping, worksite cue **display**, selection/pick overlay, map labels/LOD.
- `godot/src/presentation/p3_1_landscape_sect.gd`, `godot/src/presentation/p3_2_landscape_sect.gd`, and relevant **P3.2-only UI/presentation view scripts** as necessary to improve map readability, pan/zoom, actor/building overlays, small-screen hit zones and reduce obstructive UI. Existing canonical command handlers must not be changed in business semantics.
- `godot/scenes/p3/**` for presentation scene composition and viewports, while preserving one P3.2 runtime instance and combat/CARE hookup.
- NEW **map-specific** runtime textures/atlases/fonts/scene assets under `godot/assets/p3/**` and clearly named `godot/art/map_d2_candidate/**` if compliant with repo source policy; add manifest/registry entries for new candidates with lineage and SHA. **NEVER overwrite pre-existing Source A/MAP25 art**.
- `godot/data/presentation/**` for new view-only map/layout/art metadata, without rewriting existing `map25_source_a_verified.json` or lying about historical provenance.
- `godot/tests/presentation/**`, relevant affected integration tests, and new bounded capture/asset-audit/conversion tooling under `tools/**` or `labs/**`.
- `docs/**`, `outputs/map_d2/**` for catalogs, migration/diff matrices, art provenance, test logs, screenshots, perf and playable packaging metadata.

**A path in a new subfolder with the same responsibility is allowed without another owner micro-approval.** If edits touch disallowed gameplay-owner domains below, STOP that subtask, report it, continue independent map/art tasks.

**Hard forbidden gameplay-owner domains (unless separately authorized in a NEW CODE packet):**
`godot/src/simulation/**`, Combat V2 and V3-S1 authority, CARE hunting encounter/loot/receipts, workforce assignment/production formulas and scheduler ticks, D7/DiscipleState identity and current_action, WarehouseSystem, SaveService/persistence schema, injury/cultivation/equipment, monster AI/spawn/damage, gameplay map difficulty and world progression. No x100 balance. No duplicate simulated job clock or new visual-only warehouse economy. `.github/workflows` and branch protection are also forbidden.

Design renderer policy: **do not rewrite the whole renderer merely to create work volume.** However refactor/add actual visual layers, tile/terrain compositing, depth occlusion, verified animated sprite adapters and chunk/LOD code if real visual/performance evidence warrants. Retain Godot 4.7.2 and Source A style, one canonical Camera2D/viewport transform, unchanged input-to-world identities; no wholesale JX/Unity engine swap.

## 3. Asset provenance / legacy approved building art — stop using art shortage as an excuse to make blank tiles

Source audit nuance:
- PR32 verifies exactly **32** MAP25 art PNGs (4 terrain/6 roads/19 vegetation-props/3 buildings). Only **Main Hall 510052, Warehouse 510102, Forge 520081** have runtime verified Source A building sprites, and PR32 uses 30 of the 32 in default map.
- Historical visual reference `docs/P3_ASSET_BUILDINGS.md` records **eight approved building identities/visuals**. Much older source recovery manifest labels source class **S3** (historically approved but exact bytes not retained in its Oct03 snapshot). This document predates the three PV01 runtime imports; **check actual fresh bytes/manifest per asset** and don't copy the Oct03 "all missing" claim uncritically.
- `source_art/README.md` says editable masters once planned in source_art but source may live in approved EXTERNAL Source A local archives/Drive/GitHub asset repos/worktrees/exports. Read, do not mutate source; enumerate rights/locator/file type/SHA, decode to inspect if a tool exists.
- Source A rig/Spine conversion already has proofs in older branches/worktrees; do not re-convert all actors unless map actually needs it.
- Historical `environment.path_grid128` had an old approved pack; search exact artifact before redrawing.
- Important: a static crystal/bush sprite isn't a real mine/woodcutter/farm building or action animation.

**Long asset-first task:** inspect every accessible approved Source A directory/ZIP/Pak/sprite atlas/vector/motion/building master that may contain isometric environments, building family, terrain, roads, courtyard, ground textures, fences, stairs, Gate, residential, training, Mine, forest worksite, field, water/bridge, wall, props. Prioritize reusable approved art over synthetic replacements. Use search by real SHA/type/visual source, contact sheets and dimension/alpha/angle analysis. Record ABSENT, UNREADABLE, NOT CONNECTED, CANDIDATE UNVERIFIED and VERIFIED. Do not silently skip source folders just because they are not already in PR32.

If approved exact source is found, create non-destructive reproducible optimized runtime import path, proper scaling/pivot/alpha, SHA source-export linkage, compare camera family, and integrate on isolated branch only after official Godot asset QA.

For **S4 unproduced decorative components** (ground, water, path blending, cliff edge) that have no approved exact art, the owner launch prompt authorizes **new ORIGINAL CANDIDATE art for the isolated visual prototype** that follows P3 Art Bible, with documented provenance, no third-party unauthorized copying, and explicit "provisional/not owner-approved" status. Provide the internal art production plan first in a committed document in this same batch and proceed under the one owner authorization. Do not mass-create random placeholder shapes. If available tools cannot produce convincing hand-painted raster/tiles, do NOT relabel programmatic rough geometry as production art.

For historically approved **S3 building family with missing exact source**, keep original identity and style reference; make clear that any newly produced architectural illustration is **provisional substitute for review, NOT recovered approved art**. Do not overwrite the approved identity, canonical registry or existing three verified sprites; present side-by-side and require owner final visual sign-off before treating any substitute as approved. Creating such a standalone provisional review candidate is allowed by owner's Section12 instruction, but promotion to canonical runtime production/asset master remains PENDING owner approval. If impossible to make a candidate matching style, mark ART_BLOCKED and proceed on terrain/composition.

No commercial external raw art distribution or licensing assumptions. Handle files only from owner-approved/authorized source; never send private owned assets elsewhere or commit oversized unknown-license packs.

## 4. PHASE V0 — Understand why current screenshot still looks like prototype

Quantify from actual PR32 before/after 1280×720:
- Proportion of visually empty/repetitive flat green ground and route patchiness; screenshot annotate locations.
- Main Hall relative focal hierarchy, roof perspective/shadow match, court size, camera crop, ground plane fidelity.
- Three real buildings versus many diamond name-only markers; most worksite identity not visible without labels.
- Chibi actor placement relative to doors, shadow/ground contact, occlusion/roof sorting and overlapping UI.
- Stone paths with jagged joints, abrupt ends, no shoulders/terrain transitions; landscape not feeling lived-in.
- Selected building hitbox vs rendered sprite, worksite mini-panels/ETA and input feel.

Develop a technical-to-visual root cause table: asset missing, renderer draw order/tiling, landscape spacing, color hierarchy, UI clip/camera, performance. Do not "fix" issues by resizing every label or inserting large full-screen background that breaks picking.

**Visual acceptance goal:** not "nine AStar preview routes". A viewer at 1280×720 must be able to distinguish meaningful core, cultivation, production and living areas and understand this is a vibrant functioning Chinese xianxia sect. When verified art is missing, clearly show candidate ART_GAP rather than claim finished production. The map should look more coherent and richly composed than PR32, not simply busier with trees.

## 5. PHASE V1 — Source A and environment asset recovery/conversion

Make a complete inventories and contact sheets of accessible owned Source A, source_a_env02a, approved building refs, old MAP25/G1 and previous recovered assets. Cross-check against current root file fingerprints to avoid wasting work or converting duplicates. Determine candidate priorities:
1. Hall frontage, Gate/courtyard/paths/edge, direct visual continuity.
2. REAL recognizable Mine/Forest/Field worksite family.
3. Residential, cultivation and medicine landmarks.
4. Ground variety, stone/dirt roads, water stream/bridge, cliffs/threshold, meaningful props.
5. Ambient non-fake VFX and existing actor walking/carry animations with real clips; don't invent an active mining/cutting/planting animation.

Produce human-readable catalog with thumbnail/contact sheet, source SHA, original format, pivot/alpha metadata, blend/scale, likely role, import feasibility and approval confidence. If local/Drive content inaccessible, document which source location needs a connected tool, then maximize remaining tasks instead of halting.

## 6. PHASE V2 — Real map composition and presentation architecture, not coordinate-only

On NEW isolated branch from **current PR32 exact HEAD**, produce a robust Option B enhanced sect map. Layout must support a future 192×192 connected world with starter 48×48 but can reposition anchors and change VIEW presentation layers/camera controls/layout/terrain rendering **if necessary and regressions remain**. Do not add construction/unlock/Save gameplay.

What should visibly improve:
- Coherent art-directed ground plane; transparent/transition base textures, stone court not checkerboard, usable paths with smooth joins/caps, distinct yet coherent zones.
- Main Hall identity and meaningful entrance/courtyard. Real building art when recovered, with true ground contact.
- Actual Mine/Forest/Field stations or **distinct clearly labeled provisional asset candidate** (owner review required), not generic diamonds if a stronger candidate is available.
- Architectural residential/cultivation spots anchored consistently; no fantasy palace reimagination or uniform tiled roofs for all buildings.
- Woods/pond/rock edge that look grounded, not blocking selection; better depth (background/terrain/road/buildings/actor/roof/VFX), occlusion clarity.
- Layout readable at 0.75x and 1.0x, camera free pan/zoom with focus, actor silhouettes readable, selected hit targets >= common touch area, HUD not obscuring main world.
- Optimization for 8GB developer Windows and mobile budget: chunk culling/cache, sprite count, texture dedup, redraw and no per-frame whole-map scans.

Use new map art adapter/data contracts as needed. **No user-visible invented production mechanics.** Worksite timing/progress/assigned worker/quantity must be actual canonical state. Visual workers may only walk/use clip if authenticated actor state and verified animation permit; otherwise truthful static worksite progress overlay.

Don't force uniform global geometry to preserve a bad old image. If a renderer micro-architecture must change to solve visual quality and remains presentation-only, do it, justify with before/after and camera/picking tests. Don't touch Combat logic or create a second owner.

## 7. PHASE V3 — Interactivity, real production cues and regression

Test no hidden regression:
- Select Hall/Forge/Warehouse and all real Mine/Forest/Field instances at default and zoom 0.75/1.35/1.80, at multiple pan positions; screen projection and pick target return canonical instance ID, no fake building state.
- Real P3.2 panel, worksite progress/ETA, one operator/job, Warehouse exactly-once Mine settlement.
- Actor display occlusion (behind roofs/trees), camera movement, layout restore, subviewport/HUD layering; no snapping actor position or moving a disciple's actual game coordinate to fit decor.
- CARE hunt, Combat S1 statuses and return to sect unaffected; do not force map content into Thanh Trúc Lâm.
- Save reload same-version, no modifications to state except legitimate approved actions.
- 32 MAP25 original art RAW sha unchanged/accepted; any new art under NEW manifest with source classification, no replacement of verified filenames.

Risk regression test matrix: 29/29 PR32 focused + 56 S1 edge checks + new art/map/pick/source manifest tests on **same final code tree**. If broad UI/presentation refactor touches more, add relevant tests. Godot official 4.7.2 clean import/parse. Environment warnings distinct from game failures. All initial reds kept; no masking assertions to PASS.

## 8. PHASE V4 — REAL before/after visual QA that matters

Same save/simulation state/camera/zoom baseline PR31/PR32 vs new MAP-D2:
- 1280×720 overall map (zoom default), Hall court, entry, living, training, production, Mine/Forest/Field selected with canonical state, near/medium/far zoom, panorama/pan bounds, in-play actors with correct Source A rig, worksite production result and Warehouse, hunt return.
- **12+ actual distinct runtime visual frames IF they add value**; no duplicative screenshots of nearly identical views to pad output.
- Annotated screenshots locating visual flaws; report what was changed materially (e.g. which art sprites recovered, terrain transition, gate legibility, actor occlusion), not just "AStar paths=9" or "+145 lines".
- Short real GUI video or frame sequence may be captured if supported, not mandatory; never synthetic video passed as real.
- Every screenshot manifest: exact SHA/tree, Godot binary/version, viewport, camera and save identity, referenced asset hashes, screenshot raw hash. No generated image mockups misrepresented as runtime proof.
- **Design review is separate from QA green**. A visually bad map with all focused tests PASS = `TECHNICAL_PASS_VISUAL_REVIEW_PENDING`, not "map complete". Evaluate readability, material harmony, compositional quality, map occupation/emptiness, new art completeness.

## 9. PHASE V5 — Measured performance and Windows playable

Repeat appropriate Windows benchmark with current/PR32 comparison on the SAME hardware and methodology (Godot official 4.7.2, 1280×720, renderer, warmup, 60s sample minimum if stable). Collect FPS mean/p05/min, frame-time p95/p99, working set and startup peak, chunk count and draw calls; note sample size, background processes if relevant. PR32's p95 64.54ms frame spikes must not disappear from documentation; investigate if new art worsens. One Godot process at a time; pause if machine resource instability. Do not need 1000–3000 actor benchmark as a requirement to design first map.

Create new portable Windows *visual MAP-D2* build or project+launcher from FINAL new branch, fresh isolated user save, smoke test actual P3.2 GUI. If standalone export templates absent, label portable project, do not call it standalone EXE. ZIP might be too large for Git; record exact local delivery location/hash, no invented upload URL. Preserve PR31 and PR32 builds.

## 10. PHASE V6 — One DRAFT PR delivery and owner decision, not a series of micro-packets

New CODE branch recommendation: `feature/map-d2-sourcea-visual-world-20261025`, from **latest verified PR32** (unless it changed incompatibly). One designated writer, no parallel edits to scene/map/asset registry.
Open one NEW DRAFT PR stacked on PR32 branch, not main, and keep PR24–32 open/untouched. Commit source/test/verified art appropriate to repo size + small runtime PNG evidence/docs. Do not push huge raw licensed bundles/LFS without proper approval; raw Source A owned files remain in original approved storage.

Required:
1. Before/after authentic P3.2 screenshot gallery and a compact visual change scorecard with OWNER_REVIEW_REQUIRED.
2. Verified Source A complete asset catalog and source-to-export manifest with SHA; candidate vs existing approval statuses clearly tagged.
3. Architecture/diff report listing exact paths and why multi-file changes were necessary, with cost/performance notes.
4. Official Godot all scoped results, fail list, SHA/tree/commands/logs.
5. Native input+UI/camera/picking/producer regression, Save/CARE/Combat untouched.
6. Packaging/checksum/run instructions and if inaccessible, direct delivery limitation.
7. Bounded backlog separating still missing art, Android/manual QA, District C/progression/scale, gameplay feature omissions and future merges.

**No merge. No promotion of new candidate building art to historically approved. No changing original Source A asset bytes or provenance.** Owner will judge screenshots/gameplay and decide final acceptance later.

## 11. Anti-pattern checklist — never repeat MAP-D1B's constrained outcome

- NEVER arbitrarily stop at ONE .gd file because a previous packet had a one-file allowlist. MAP-D2 authorizes all relevant map presentation/asset integration paths.
- NEVER call artistic work finished solely because 29 focused checks passed, one road graph was rerouted, a blue/green color tint changed, or a 130MiB ZIP exists.
- NEVER code only a docs-only asset plan when actual verified owned source bytes are available.
- NEVER use unauthorized asset material, mislabel generated art as Source A, copy S3 approved building visual without recovered bytes, or pretend a pixel-drawn diamond is a real building sprite.
- NEVER rewrite canonical gameplay to make a demonstration more lively.
- NEVER reset/clean existing local worktree, discard PR31/32, delete original raw art, create another gameplay clock or rename Source A originals.
- NEVER mark Windows manual/physical Android/FULL CI/owner visual as PASS without evidence.
- If visual quality is blocked on truly inaccessible artistic sources, deliver full asset recovery catalog, demonstrable best feasible art pipeline and accurate limitations, not unjustified "COMPLETE".

## 12. Owner launch prompt — PASTE THIS INTO CODEX TO AUTHORIZE MAP-D2

TÔNG MÔN BÁ ĐẠO — TÔI CẤP PHÉP MAP-D2 VISUAL WORLD UPGRADE TRÊN NHÁNH RIÊNG. KHÔNG CÒN GIỚI HẠN CHỈ ĐƯỢC SỬA 1 FILE.

Repo: `vuanhtuan161094-byte/TongMonBaDao`. Đọc toàn bộ packet:
`docs/map-d2-visual-rebuild-broad-scope-20261025/docs/handoffs/2026-10-25/TMB_MAP_D2_BROAD_SCOPE_VISUAL_WORLD_UPGRADE_CODEX_PACKET_2026-10-25.md`
và các tài liệu/source được dẫn chiếu. Bản gốc kỹ thuật: PR #32 MAP-D1B trên PR #31 CARE/Combat/Source A; kiểm tra HEAD mới nhất.

Tôi cho phép Codex **triển khai trọn MAP-D2 trên một nhánh/worktree riêng, sửa MỌI file cần thiết thuộc hệ thống MAP PRESENTATION, các scene P3.2, UI overlay liên quan map, camera/picking adapters, source art ingestion/renderer, các asset mới và tools/tests/manifest để đạt kết quả THẨM MỸ THẬT**. Không giới hạn tùy tiện số dòng code hoặc file; mỗi thay đổi phải có lý do và regression. Có thể refactor presentation renderer/layers khi có bằng chứng, nhưng không đổi engine/gameplay hay tạo camera/simulation mới. Đây là một quyền CODE cụ thể cho hệ map, không phải quyền viết lại toàn game.

**Kết quả phải là map tông môn tiên hiệp Source A đẹp và sống động hơn rõ rệt**, không phải chỉ đổi vị trí 3 nhà/lát thêm vài đoạn đường. Kiểm toán sâu toàn bộ Source A của tôi có quyền truy cập trong repo, local staging, GitHub và nguồn Drive thật sự được kết nối; tìm building/terrain/road/water/ambient/actor clips hợp lệ, chống chuyển đổi trùng, lập catalog SHA và contact sheet, tích hợp asset approved đã xác minh. Cho phép sản xuất **asset environment S4 gốc mới** để dựng bản PROTOTYPE trong style Art Bible; mọi đồ họa mới phải có nguồn/provenance và là candidate chưa được owner duyệt. Nếu cần vẽ thay thế công trình đã duyệt nhưng thất lạc S3, chỉ tạo candidate riêng để tôi xem; không tự gọi đó là file Source A đã khôi phục, không thay 3 sprite PV01 đã verified.

Tự triển khai kiến trúc cảnh quan, nền đất/đường transition, trục vào→sân→Đại Điện, ba khu, công trình có identity, layer occlusion, lựa chọn producer và camera/HUD, bám gameplay thật; xử lý nguyên nhân map xấu không chỉ đưa thêm marker. Giữ style Source A. **Không sửa gameplay authority**: simulation, Combat V2/V3, CARE, OneActiveJob, sản lượng, Warehouse, SaveService, D7, injury, economy và thanh toán; không tự merge hoặc đụng PR31/32 gốc/main.

Chạy Godot official 4.7.2 trên source mới: 29/29 focused PR32 + Combat S1 56 checks + các art/camera/picking/layout tests mới, một SHA cuối; kiểm tra real Mine/Forest/Field và Warehouse/Save/CARE, chụp đủ ảnh P3.2 thật 1280×720 trước/sau để **tôi nhìn ra thay đổi chất lượng**. Đo FPS/RAM và frame spike trên Windows; tạo portable playable từ phiên bản MỚI nếu có thể. Không FULL/CI chủ động; không giả QA hoặc Visual PASS.

Làm liền một gói lớn từ asset forensic → chuyển đổi → code map/UI/layer → chạy thử → sửa lỗi → ảnh/báo cáo → Draft PR, không hỏi duyệt từng file/từng commit. Nếu thiếu exact art không thể tiếp cận thì tiếp tục phần khác và ghi ART_BLOCKED chính xác, không fake sprites để báo hoàn tất. Tôi sẽ duyệt Visual sau; Codex không tự công nhận thiết kế cuối. Đưa liên kết PR mới, SHA cuối, ảnh trước/sau và asset catalogs. Không merge, không xóa PR cũ.
