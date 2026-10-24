# TMB PR #27 — UI PASS-1 Audit and Code Handoff (2026-10-24)

> **CẬP NHẬT OWNER 2026-10-24:** Giới hạn “không chạm Source A/renderer” trong handoff UI PASS1 bên dưới chỉ mô tả scope của batch đã code. Owner đã cho phép Codex tích hợp **asset worker được kiểm chứng** vào presentation PR #28 bằng packet docs/handoffs/TMB_PR28_UI_SOURCEA_WORKER_ASSET_INTEGRATION_PACKET_2026-10-24.md. Packet mới thay thế **prompt thực thi** và **scope asset** của file này; phần QA lịch sử và O9 vẫn giữ nguyên. Không cho phép viết lại renderer hoặc sửa gameplay.


## Exact authority
- Repo: vuanhtuan161094-byte/TongMonBaDao; official engine target Godot 4.7.2; primary Android landscape 1280 x 720.
- GitHub PR #27 was confirmed OPEN/DRAFT at head deeae081bcfbe1413d4cf60a29db7e58150888b5, stacked on PR #26 base 53ff0b223f4e77ccfbe5c77d2203496ac0cc37a9.
- The UI-only branch is ui/pr27-runtime-readability-20261024; initial code/test HEAD before this document: d778e4382348a0f89734f2c67459951294da3d48.
- The PR #24/#25/#26/#27 branches were not merged or rebased. Combat V3, x100 numbers, D7 odds, CARE, SaveService, Warehouse, economy and Source A asset authority were not edited.

## PR #27 read-only audit
- Inspected AGENTS.md, CURRENT_CHECKPOINT.md, NEXT_CHAT_HANDOFF.md, the three mandatory docs/handoffs/ reports, TMB_NEXT_CODEX_TASK, original P3.2 runtime scripts, Godot project-scoped UI playtest skill, D7 migration test, FoundationSystem and SaveService.
- PR #27 prior source-test commit 80ed0270d2b7370f8feff1ce829f167146f3f341 produced a reported D7 139-check PASS and 20/20 focused PASS on clean isolated userdata. These are HISTORICAL test reports, not reruns on the new branch.
- The existing D7 save-migration test creates an old non-CARE wire v2 from a canonical recruited V2 disciple, verifies old six-stat birth provenance and newly derived mind_nature, recomputed max HP and preserved 61% live HP ratio, and rejects incomplete birth provenance. SaveService also has CARE wire version acceptance and fail-closed guards. Compatibility of arbitrary actual user save backups has NOT been newly demonstrated.
- Existing initial O9 production rehearsal FAILED: fresh roster could not allocate Mine, Forest and Field workers; the initial suite was 19/20. Re-run on clean isolated userdata 20/20 PASS, but root cause for the initial variance remains UNKNOWN. Preserve both logs and never overwrite FAIL evidence.
- Prior Combat V2 diagnostic fixture ran 1,240 battles; it is not balance acceptance. No actual CARE Boss/AoE source event was verified.

## Four owner-supplied image sets
- Reviewed real-derived current / annotated / static mockup / actual-after four-panel sheets for MAP, PRODUCTION, PROFILE and COMBAT. Prior actual-after frames are from code 80ed027, NOT from this new UI branch. No standalone mockup or generated image was installed as game UI.
- MAP: too many overlapping world cards obscure genuine Source A environment, top resource metrics on one long line and small controls. Pass-1 limits visible active/selected/settled-receipt cards, preserves camera authority, separates real top counters into two lines and enlarges camera targets.
- PRODUCTION: Mine and Linh Lam repeat a large personnel paragraph before the real action roster, forcing long scrolling. Pass-1 removes only duplicate text, keeps canonical real roster and actions, introduces assigned/group/unassigned presentation labels, clarifies progress/ETA versus canonical settled Warehouse amount. Linh Dien remains dense and needs actual-device visual review.
- PROFILE: D7 seven-axis data already exists. Pass-1 improves font sizes, profile/tab/roster contrast, close/back targets and radar labels without changing dimension values.
- COMBAT: actions/facts crowded and AUTO text contrast weak. Pass-1 groups ONLY existing CARE/Combat V2/warehouse data and improves fonts/contrast. Central actor, damage and VFX overlap NOT YET fixed; do not modify renderer or invent gameplay events.

## Changed code allowlist
1. godot/src/presentation/p3_2_landscape_sect.gd — worksite badges, production layout, worker text, authentic CARE facts, profile UI and touch sizing.
2. godot/src/presentation/p3_1_landscape_sect.gd — readable two-line live resource HUD.
3. godot/src/presentation/p3/sect_production_worksite_cue.gd — fonts only.
4. godot/src/presentation/p3/disciple_six_dimension_radar.gd — seven-axis label legibility only.
5. godot/tests/presentation/tmb_pr27_ui_readability_test.gd — isolated real P3.2 Mine/worker/D7/CARE UI test, created but NOT run.
6. This Markdown is handoff documentation. No simulation/test contract/gameplay authority file has been modified.

## QA and evidence ledger
| Gate | Status |
| --- | --- |
| Baseline PR27 D7 139 checks | HISTORICAL PASS in supplied ZIP |
| Baseline PR27 focused 20/20 fresh profile | HISTORICAL PASS in supplied ZIP |
| Baseline PR27 O9 initial 19/20 | HISTORICAL FAIL, retained in supplied ZIP |
| New UI branch source file allowlist | GitHub compare ONLY (static) |
| New isolated P3.2 readability test | CREATED, NOT EXECUTED |
| Godot 4.7.2 parse/import, updated focused suite | PENDING; executable/private checkout unavailable here |
| New 1280x720 before/after engine screenshot | BASELINE AVAILABLE, NEW AFTER PENDING |
| Real Windows mouse/pan/zoom/save/load | PENDING USER |
| Android landscape touch/rotation | PENDING USER |
| Actual Injury120 frame, live Boss/AoE UI | PENDING / no live Boss source event |
| Owner visual acceptance | PENDING OWNER |

No new PASS/FAIL runtime logs or engine screenshots have been invented. No FULL/CI was run.

## Codex next task — ready-to-send Vietnamese prompt

> TÔNG MÔN BÁ ĐẠO — PR27 UI PASS1 QA. Trên GitHub repo vuanhtuan161094-byte/TongMonBaDao, fetch nhánh ui/pr27-runtime-readability-20261024, so sánh base chính xác deeae081bcfbe1413d4cf60a29db7e58150888b5, không merge/rebase PR #24/#25/#26/#27. Đọc AGENTS.md, CURRENT_CHECKPOINT.md, NEXT_CHAT_HANDOFF.md, ba handoff bắt buộc của PR #27 và báo cáo này. Dùng Godot official 4.7.2 và userdata TEMP sạch, import/parse scene P3.2, chạy tmb_pr27_ui_readability_test và focused regression map camera, production/O9, profile D7/radar, CARE presenter/main hunt, D7 migration và SaveService legacy. Chụp ảnh trực tiếp trong Godot 1280x720 trước/sau theo cùng góc camera với screenshot thật trong ZIP cho map, Mỏ, Linh Lâm, Linh Điền, hồ sơ 7 trục, CARE hit/skill/COMMITTED loot. Giữ log O9 FAIL cũ và rerun PASS riêng, truy nguyên khác biệt nếu tái xuất hiện. Nếu bị parse/runtime FAIL, chỉ được sửa presentation/test nằm trong nhánh UI và phải chạy lại test. Bàn giao log, ảnh thực tế, manifest, SHA, diff file, issue matrix, trạng thái PASS/FAIL/PENDING minh bạch. Không sửa gameplay Combat V2/V3, cân bằng x100, thuốc, D7 rate, CARE ownership, Warehouse, SaveService, Source A/renderer; không tạo Boss giả. Không FULL/CI, không merge. Windows manual/Android/Owner Visual tiếp tục PENDING khi chưa có bằng chứng.

## Ownership
- This UI chat/branch: only the four presentation files above, scoped presentation tests, evidence and handoffs.
- Separate Combat V3 chat: design of HP/ATK/DEF/skill timing/Boss numbers, no integration until a separately approved numeric packet.
- Acceptance remains blocked on exact SHA Godot runtime screenshot and focused regression, followed by owner visual and physical platform review.