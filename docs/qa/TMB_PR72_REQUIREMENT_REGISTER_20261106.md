# TMB PR #72 — Requirement Register (2026-11-06)

Register trích nguyên văn từ workbook owner; current status được bổ sung riêng, không ghi đè nội dung nguồn.

- Repo/PR: vuanhtuan161094-byte/TongMonBaDao, PR #72 Draft; branch integration/pve-p0-playable-ui-20261103.
- Workbook SHA-256: 304d4dc2bff846824762f2cb62df10cb9c0b18dcfc3f4729e8d1f33998574c1d. Prompt SHA-256: 287e735b25e91e669c7e47f9499461e8ca546ad281e42a607ecb7d2982a412bb.
- Workbook baseline SHA: fa872eaa07b2abc27240ecd754de13fd4774a8cc.
- PR documentation HEAD before this update: 857ce164442a3a845d554b6ab1315abf92c85281. Runtime code/test SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb. P3.2/density/P3.4B/O3 runtime tests: 374f2d47d887c828218e3a296b6c8370aff070e7; production runtime files unchanged through 5ef179b81dfef6f2d72a38d866e94fc828e179eb.
- Counts: 35 requirements, 158 cases across 18 systems, 10 E2E journeys, 15 gaps.
- TESTED_GUI means harness-driven real Godot viewport capture; it does not mean physical mouse input or owner visual acceptance.

## 18-system coverage target

| System | Cases | P0 | P1 | P2 |
|---|---:|---:|---:|---:|
| 01. Khởi chạy & New Game | 6 | 6 | 0 | 0 |
| 02. Bản đồ & điều khiển | 9 | 9 | 0 | 0 |
| 03. Actor & đời sống tông môn | 9 | 9 | 0 | 0 |
| 04. Đại Điện & bậc Tông | 7 | 7 | 0 | 0 |
| 05. Đệ Tử Xá & xây dựng | 8 | 8 | 0 | 0 |
| 06. Dẫn Tiên Đài & tuyển đệ tử | 8 | 8 | 0 | 0 |
| 07. Hồ sơ và tăng trưởng đệ tử | 10 | 0 | 10 | 0 |
| 08. Nhân sự, lệnh và One Active Job | 9 | 9 | 0 | 0 |
| 09. Mỏ & Linh Lâm | 9 | 9 | 0 | 0 |
| 10. Linh Điền, dược liệu & Kho | 10 | 10 | 0 | 0 |
| 11. Luyện Đan & thuốc | 9 | 9 | 0 | 0 |
| 12. Kinh tế, thương nhân & tiêu thụ | 7 | 0 | 7 | 0 |
| 13. Trang bị, Luyện Khí, bộ đồ | 7 | 0 | 7 | 0 |
| 14. PvE thế giới liên tục | 12 | 12 | 0 | 0 |
| 15. Kỹ năng & Tàng Kinh | 10 | 10 | 0 | 0 |
| 16. Animation, VFX, âm thanh | 9 | 0 | 9 | 0 |
| 17. UI/UX toàn màn | 10 | 10 | 0 | 0 |
| 18. Save, tương thích & Android | 9 | 9 | 0 | 0 |

## Requirements

### REQ-01 — Một game một PR

- Owner request: Một game một PR
- Locked content: Chỉ PR #72, 1 branch, không merge main trước R5
- Workbook classification: LOCKED
- Acceptance/remaining work: Sổ kiểm tra đường code và branch
- Source reference: AGENTS.md
- Current status: CODED
- Current decision/evidence: One existing PR/branch is used; no second gameplay branch or main merge.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); PR #72 / branch compare

### REQ-02 — Mở game trên E

- Owner request: Mở game trên E
- Locked content: 1 offline package, 3 launcher starts, Godot 4.7.2 official
- Workbook classification: ĐÃ BÁO QA LOCAL
- Acceptance/remaining work: Cần ghi riêng engine OS exit
- Source reference: CHOI-GAME.cmd
- Current status: CODED
- Current decision/evidence: Launcher/source verifier exist and launcher safety is 25/25; three current-SHA offline starts are not established here.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); PR72_MASTER_QA_20261106/logs/production/launcher_safety.stdout.log

### REQ-03 — Chơi được New Game

- Owner request: Chơi được New Game
- Locked content: No fixture → xây → tuyển → SX → PvE → Save/Reload
- Workbook classification: CHƯA NGHIỆM THU
- Acceptance/remaining work: Ưu tiên P0 trước cân bằng/endgame
- Source reference: one_game_r3_continuous_save_test.gd
- Current status: TESTED_HEADLESS
- Current decision/evidence: R3 isolated save: New Game, paid Residence, recruit, Mine, PvE receipts, Save and two cold continuations with no duplicate check.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); PR72_MASTER_QA_20261106/logs/r3/

### REQ-04 — 3 công trình lõi

- Owner request: 3 công trình lõi
- Locked content: Đại Điện/Đệ Tử Xá/Dẫn Tiên Đài có action state thật
- Workbook classification: CÓ CODE
- Acceptance/remaining work: GUI 1280x720 và Save phải nghiệm thu
- Source reference: tri_facility_b1_live_integration_test.gd
- Current status: CODED
- Current decision/evidence: Facility panels/callbacks exist; B1 contract/live tests were not rerun on current source SHA.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); tri_facility_b1_live_integration_test.gd

### REQ-05 — Dàn công trình đẹp

- Owner request: Dàn công trình đẹp
- Locked content: Bản đồ đẹp, không đặt nhà tự do từ phút đầu nếu không có gate
- Workbook classification: CẦN ĐỐI CHIẾU
- Acceptance/remaining work: Tách layout mặc định và xây Xá đủ tài nguyên
- Source reference: p3_2_landscape_sect.gd
- Current status: DESIGN_HOLD
- Current decision/evidence: Layout/build gate reconciliation remains; no placement authority or balance invented.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); TMB_PR72_FUNCTION_PARITY_MATRIX_20261104.md

### REQ-06 — Di chuyển đến cửa

- Owner request: Di chuyển đến cửa
- Locked content: Actor đi tới cửa; ẩn khi đã vào làm, trở lại đúng state
- Workbook classification: CÓ CODE + LOCAL PATCH
- Acceptance/remaining work: Không cần chạy vào nội thất
- Source reference: p3_2_landscape_sect.gd
- Current status: TESTED_HEADLESS
- Current decision/evidence: P3.2 map/live test at 374f2d4; runtime files unchanged through 5ef/857.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); PR72_MASTER_QA_20261106/logs/focused/p3_2_live_modular_map_test.stdout.log

### REQ-07 — Actor 16 hiển thị

- Owner request: Actor 16 hiển thị
- Locked content: Virtualized, max 16 render, người ngoài viewport vẫn có simulation
- Workbook classification: CHƯA PUSH LOCAL
- Acceptance/remaining work: Bắt buộc Godot QA lại sau commit
- Source reference: p3_2_landscape_sect.gd
- Current status: TESTED_HEADLESS
- Current decision/evidence: Density test checks bounded actor pool and virtual positions, not a real 100+ roster GUI.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); PR72_MASTER_QA_20261106/logs/focused/endgame_map_density_test.stdout.log

### REQ-08 — Lời thoại lúc rảnh

- Owner request: Lời thoại lúc rảnh
- Locked content: Bong bóng ngắn tự biến mất, không đè labels
- Workbook classification: CHƯA PUSH LOCAL
- Acceptance/remaining work: Kiểm timeout và hiển thị
- Source reference: p3/p3_5_living_cue_map_integration_test.gd
- Current status: TESTED_HEADLESS
- Current decision/evidence: Density test checks timed ambient bubbles; a real renderer frame shows one.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); PR72_MASTER_QA_20261106/logs/focused/endgame_map_density_test.stdout.log

### REQ-09 — Không toàn chữ

- Owner request: Không toàn chữ
- Locked content: Icon, portrait, progress bar, color/typography đọc được
- Workbook classification: CHƯA NGHIỆM THU
- Acceptance/remaining work: Visual acceptance từng màn
- Source reference: docs/GAME_SYSTEM_ARCHITECTURE.md
- Current status: TESTED_GUI
- Current decision/evidence: Ten real Godot viewport renders at 1280x720 inspected via harness; physical mouse and owner visual acceptance remain pending.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); PR72_MASTER_QA_20261106/SCREENSHOT_SHA256.csv

### REQ-10 — Nghề/nhân sự

- Owner request: Nghề/nhân sự
- Locked content: Người rảnh, trình độ nghề, không tự lấy worker đang bận
- Workbook classification: CÓ CODE
- Acceptance/remaining work: Cần so UI/action với scheduler
- Source reference: workforce_system.gd
- Current status: TESTED_HEADLESS
- Current decision/evidence: P3.4B assignment and O7 workforce/forest tests pass; this does not close all scheduler policies.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); PR72_MASTER_QA_20261106/logs/focused/p3_4b_building_people_management_test.stdout.log

### REQ-11 — One Active Job

- Owner request: One Active Job
- Locked content: Không hai job cùng lúc; cancel progress theo luật
- Workbook classification: CÓ CODE/QA CŨ
- Acceptance/remaining work: Regression chính thức final SHA
- Source reference: gp_02b1_v2_occupation_guard_test.gd
- Current status: CODED
- Current decision/evidence: Canonical One Active Job authority exists; broad cumulative regression was not in this current subset.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); gp_02b1_v2_occupation_guard_test.gd

### REQ-12 — Mỏ/Linh Lâm/Linh Điền

- Owner request: Mỏ/Linh Lâm/Linh Điền
- Locked content: Nguồn→timer→kho→consumer có thật
- Workbook classification: CÓ CODE/QA CŨ
- Acceptance/remaining work: Bản local thêm UI; thiếu upgrade Lâm
- Source reference: building_system.gd
- Current status: TESTED_HEADLESS
- Current decision/evidence: O3 Mine, O4 Field, O7 Forest and R3 production/save evidence pass on recorded SHAs.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); PR72_MASTER_QA_20261106/logs/production/

### REQ-13 — Linh Lâm nâng cấp

- Owner request: Linh Lâm nâng cấp
- Locked content: Cần progression từ Lv1 đến endgame
- Workbook classification: CODE GAP
- Acceptance/remaining work: Current upgrade_enabled=false
- Source reference: building_system.gd
- Current status: MISSING
- Current decision/evidence: Linh Lam upgrade_enabled=false; progression/cost contract absent.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); GAP-05

### REQ-14 — Mỏ milestone

- Owner request: Mỏ milestone
- Locked content: Tầm Mạch Bàn Lv10; các mốc 20/30/50/75/100
- Workbook classification: CONTENT GAP
- Acceptance/remaining work: Cần nguồn vật phẩm thật
- Source reference: building_system.gd
- Current status: BLOCKED_SOURCE
- Current decision/evidence: Mine Lv10+ milestone item/source chain incomplete; no fake items added.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); GAP-06

### REQ-15 — Điền 100 mảnh

- Owner request: Điền 100 mảnh
- Locked content: 100 mảnh = 1 Linh Tuyền Chi Tâm; upgrade milestone
- Workbook classification: CÓ CODE
- Acceptance/remaining work: Test harvest seeded/no duplicate
- Source reference: building_system.gd
- Current status: CODED
- Current decision/evidence: Field fragment/Heart rule is in source; O4 did not cover the full seeded 100-fragment oracle.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); QA-083 remains open

### REQ-16 — Kho canonical

- Owner request: Kho canonical
- Locked content: Một kho; available≠pending; settlement exactly once
- Workbook classification: CÓ CODE
- Acceptance/remaining work: Không tạo nguồn ảo
- Source reference: p3_7b1_warehouse_test.gd
- Current status: TESTED_HEADLESS
- Current decision/evidence: O1 Warehouse assertions cover total/usable/reserved/locked values and a real consumer craft.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); PR72_MASTER_QA_20261106/logs/production/p3_o1_canonical_warehouse_ui_test.stdout.log

### REQ-17 — BAL-04A

- Owner request: BAL-04A
- Locked content: Hồi Xuân AUTO >=2% maxHP; graded Tu Vi pill=0.1% realm total XP×phẩm
- Workbook classification: CÓ CODE/QA CŨ
- Acceptance/remaining work: Tái kiểm final SHA
- Source reference: sx03_bal04a_legacy_save_medicine_test.gd
- Current status: CODED
- Current decision/evidence: BAL-04A implementation exists; exact current-SHA medicine policy regression was not in this subset.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); sx03_bal04a_legacy_save_medicine_test.gd

### REQ-18 — Bão hòa đan

- Owner request: Bão hòa đan
- Locked content: 1,000,000/đệ tử/ngày
- Workbook classification: CÓ CODE/QA CŨ
- Acceptance/remaining work: Không reset trong cùng ngày khi load
- Source reference: b3_pill_satiety_test.gd
- Current status: CODED
- Current decision/evidence: B3 saturation source exists; exact current-source regression not in this subset.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); b3_pill_satiety_test.gd

### REQ-19 — Đan r3-r30

- Owner request: Đan r3-r30
- Locked content: Nguồn→công thức→Lv/Gate→tiêu thụ hoàn chỉnh
- Workbook classification: CONTENT GAP
- Acceptance/remaining work: Không tự tạo drop/recipe
- Source reference: alchemy_recipe_registry.gd
- Current status: DESIGN_HOLD
- Current decision/evidence: Only authored r1/r2 recipe chain exists; r3-r30 sources/recipes absent.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); GAP-07

### REQ-20 — Trang bị 10 ô

- Owner request: Trang bị 10 ô
- Locked content: Bỏ 3 slot cũ; 10 slot mới; 24 set 2/3/4
- Workbook classification: SOURCE GAP
- Acceptance/remaining work: Current EquipmentSystem 3 slot, 5 recipe
- Source reference: equipment_system.gd
- Current status: MISSING
- Current decision/evidence: Current EquipmentSystem remains 3 slots/5 recipes, short of 10 slots/24 sets.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); GAP-04

### REQ-21 — Kỹ năng Nhân/Tiên/Thần

- Owner request: Kỹ năng Nhân/Tiên/Thần
- Locked content: Học/equip/cast 1 basic+4 active+1 ultimate+1 mobility+5 passive
- Workbook classification: SOURCE GAP
- Acceptance/remaining work: Default V6.3 OFF, archive manuals chưa có nguồn
- Source reference: v63_feature_gates.gd
- Current status: DESIGN_HOLD
- Current decision/evidence: V6.3 default OFF; authored manual/drop source is empty.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); GAP-03

### REQ-22 — Cung 183

- Owner request: Cung 183
- Locked content: 183/183 bản đồ skill ID đủ semantic oracle
- Workbook classification: QA CŨ/CHƯA GUI
- Acceptance/remaining work: 18 suites, exhaustive Bow qua QA Nov5
- Source reference: v63_cung_full_combat_matrix_test.gd
- Current status: CODED
- Current decision/evidence: Cung catalogue/tests exist; historical exhaustive run is not current-SHA PASS.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); v63_cung_full_combat_matrix_test.gd

### REQ-23 — Quyền & Độc

- Owner request: Quyền & Độc
- Locked content: Kiểm mọi skill ID, status/ICD/DoT/AI
- Workbook classification: QA CHƯA ĐỦ
- Acceptance/remaining work: Không coi smoke là exhaustive
- Source reference: tmb_quyen_183_combat_handoff_test.gd
- Current status: MISSING
- Current decision/evidence: Quyền/Độc per-ID semantic oracle not exhaustive.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); GAP-08

### REQ-24 — PvE 30/20/40/200

- Owner request: PvE 30/20/40/200
- Locked content: 30 hunter, 20 zone, 40 live mob, 200 spawn; team≤6 optional
- Workbook classification: CÓ CODE/QA CŨ
- Acceptance/remaining work: Boss gate đúng 6, Injury120
- Source reference: pve_p0_30_independent_hunters_test.gd
- Current status: TESTED_HEADLESS
- Current decision/evidence: R3 solo PvE reached real HP0/reward receipts; it did not re-prove 30/20/40/200 or Boss gate.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); PR72_MASTER_QA_20261106/logs/r3/r3_create.stdout.log

### REQ-25 — Kiếm/Thể/Pháp

- Owner request: Kiếm/Thể/Pháp
- Locked content: Core paths khác skill families Cung/Quyền/Độc
- Workbook classification: DESIGN LOCKED
- Acceptance/remaining work: Không tạo class thứ tư sai
- Source reference: docs/DISCIPLE_MASTER_SCHEMA.md
- Current status: DESIGN_HOLD
- Current decision/evidence: Kiếm/Thể/Pháp remain canonical; no fourth path added; full progression acceptance is open.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); docs/DISCIPLE_MASTER_SCHEMA.md

### REQ-26 — D7 Tam3/Tứ4

- Owner request: D7 Tam3/Tứ4
- Locked content: Tam Căn 3 + Tứ Tính 4 không tự tăng buff Tâm Tính
- Workbook classification: CÓ CODE/QA CŨ
- Acceptance/remaining work: Radar đọc được và đúng 7
- Source reference: sect_g1_disciple_radar_test.gd
- Current status: CODED
- Current decision/evidence: Tam Căn 3/Tứ Tính 4 presentation exists; exact current-source D7 runtime rerun remains open.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); sect_g1_disciple_radar_test.gd

### REQ-27 — 300+300 tầng

- Owner request: 300+300 tầng
- Locked content: Tu Vi 30×10, Luyện Thể 30×10 track riêng
- Workbook classification: DESIGN LOCKED
- Acceptance/remaining work: Kiểm runtime floor/gate
- Source reference: disciple_realm_progress_v2.gd
- Current status: CODED
- Current decision/evidence: 30x10 Tu Vi and 30x10 Luyện Thể authorities exist; full ladder run not recorded here.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); disciple_realm_progress_v2.gd

### REQ-28 — 27 bậc Tông

- Owner request: 27 bậc Tông
- Locked content: Theo tiến trình 3/12/24 tháng dự kiến
- Workbook classification: THIẾT KẾ CHƯA ĐỦ
- Acceptance/remaining work: Không tự ra tỷ lệ hay gift
- Source reference: TMB_NUMERIC_SYSTEMS_MASTER_V1_20261105.md
- Current status: DESIGN_HOLD
- Current decision/evidence: 27-rank schedule/reward ratios incomplete; no new numeric gates or gifts.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); TMB_NUMERIC_SYSTEMS_MASTER_V1_20261105.md

### REQ-29 — Giới hạn đệ tử

- Owner request: Giới hạn đệ tử
- Locked content: Nhân ≥90, Tiên 200, Thần 400–500 theo yêu cầu owner
- Workbook classification: CẦN ĐỐI CHIẾU
- Acceptance/remaining work: Không áp cap cũ 30/30/40
- Source reference: TMB_NUMERIC_SYSTEMS_MASTER_V1_20261105.md
- Current status: DESIGN_HOLD
- Current decision/evidence: Population thresholds require owner reconciliation; no historical cap was applied.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); TMB_NUMERIC_SYSTEMS_MASTER_V1_20261105.md

### REQ-30 — Visual chibi Source A

- Owner request: Visual chibi Source A
- Locked content: Dark fantasy Xianxia, nhân vật thực/portrait, icon rõ
- Workbook classification: CHƯA NGHIỆM THU
- Acceptance/remaining work: Lab #71/#74 không tự port
- Source reference: p3/discipline_source_a_visual_pool.gd
- Current status: TESTED_GUI
- Current decision/evidence: Source A environment/buildings/actors render in Godot 1280x720 frames; owner visual acceptance pending.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); PR72_MASTER_QA_20261106/screenshots/01_main_map_source_a.png

### REQ-31 — Animation C2 MASTER

- Owner request: Animation C2 MASTER
- Locked content: Zoom 1–6x, không giảm MASTER, vũ khí rời
- Workbook classification: ART QA PENDING
- Acceptance/remaining work: Seam/alpha/memory pending
- Source reference: TMB_C2_NATIVE_PR72_IMPORT_GATE_20261105.md
- Current status: DESIGN_HOLD
- Current decision/evidence: C2 MASTER animation/art acceptance pending; labs were not integrated.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); GAP-12

### REQ-32 — Không PvP/telemetry

- Owner request: Không PvP/telemetry
- Locked content: Không mở PvP, không thêm giám sát hiệu năng mới
- Workbook classification: LOCKED
- Acceptance/remaining work: Chỉ sửa để playable
- Source reference: AGENTS.md
- Current status: CODED
- Current decision/evidence: No PvP or new telemetry was added in this PR evidence batch.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); Scope review

### REQ-33 — Save bảo toàn

- Owner request: Save bảo toàn
- Locked content: Không chạm save người chơi; receipt stable qua 3 process
- Workbook classification: CÓ QA CŨ
- Acceptance/remaining work: Đúng profile QA
- Source reference: save_service.gd
- Current status: TESTED_HEADLESS
- Current decision/evidence: R3 uses isolated QA profile across processes; no player/default save was accessed.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); PR72_MASTER_QA_20261106/logs/r3/

### REQ-34 — Không nguồn giả

- Owner request: Không nguồn giả
- Locked content: Nguồn→consumer theo stage, không bù quà/test-only payout
- Workbook classification: LOCKED
- Acceptance/remaining work: Kế hoạch endgame cần owner quyết định
- Source reference: TMB_NUMERIC_SYSTEMS_MASTER_V1_20261105.md
- Current status: CODED
- Current decision/evidence: No resource/drop/recipe was fabricated; R3 uses paid canonical construction and receipts.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); R3 logs

### REQ-35 — Không bỏ yêu cầu cũ

- Owner request: Không bỏ yêu cầu cũ
- Locked content: Mọi yêu cầu có ID, owner decision, SHA, bằng chứng và trạng thái
- Workbook classification: CHƯA TỔ CHỨC
- Acceptance/remaining work: Đây là QA master cần Codex đặt ở repo
- Source reference: AGENTS.md
- Current status: CODED
- Current decision/evidence: Register/matrix/E2E files and all 15 gaps are preserved from source workbook.
- Evidence/source SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb (code review baseline); TMB_PR72_REQUIREMENT_REGISTER_20261106.md

## GAP_BLOCKER — all 15 retained

Source finding/status preserved beside current disposition; no gap is removed because a related test passed.

### GAP-01 — Bản QA chỉnh sửa chưa push

- Priority: P0
- Source finding: Đệ tử 16 actor, lời thoại, bảng SX chỉ nằm local
- Closure condition: Cần bảo toàn diff, xét code/test, commit cùng PR #72 rồi chạy exact SHA
- Workbook status: LOCAL_UNCOMMITTED
- Current disposition: RESOLVED_ON_PR72 — actor rendering/dialogue/production-panel patch is ancestor c96ffb380f272199ef0bcde230c4576baaaf1951; P3.2/density/P3.4B/O3 passed on runtime SHA 374f2d4; no later runtime-file delta through 5ef.

### GAP-02 — E2E GUI chưa nghiệm thu

- Priority: P0
- Source finding: Harness viewport ≠ chuột vật lý; 19-step chưa có evidence xuyên suốt
- Closure condition: Dùng Godot input harness + manual owner session tách trạng thái
- Workbook status: PENDING
- Current disposition: PENDING — viewport harness is not owner-session physical mouse; no native GUI pass.

### GAP-03 — Nguồn bí kíp trống

- Priority: P0
- Source finding: V6.3 gate default OFF; archive drop_profiles rỗng
- Closure condition: Đề xuất nguồn hợp lệ, phải được duyệt trước khi bật release
- Workbook status: CODE_GAP
- Current disposition: BLOCKED_SOURCE — V6.3 stays default OFF; authorized manual/drop source absent.

### GAP-04 — Trang bị vẫn 3 slot

- Priority: P0
- Source finding: EquipmentSystem chỉ weapon/armor/talisman
- Closure condition: Thiết kế migration 10 slot/24 bộ, chưa tự ý thay save
- Workbook status: CODE_GAP
- Current disposition: SOURCE_GAP — EquipmentSystem has 3 slots/5 recipes; 10 slots/24 sets need approved data/migration.

### GAP-05 — Linh Lâm upgrade off

- Priority: P1
- Source finding: Trong DEFINITIONS upgrade_enabled=false
- Closure condition: Khóa progression và QA nguồn→cost trước khi bật
- Workbook status: CODE_GAP
- Current disposition: SOURCE_GAP — Linh Lam upgrade remains disabled; progression/cost contract absent.

### GAP-06 — Mỏ các mốc thiếu vật phẩm

- Priority: P0
- Source finding: Milestone Lv20+ chưa có components; Lv10 cần Tầm Mạch Bàn
- Closure condition: Lập acquisition nguồn thật và chặn đúng trong UI
- Workbook status: CONTENT_GAP
- Current disposition: BLOCKED_SOURCE — Tầm Mạch Bàn and higher Mine milestone source chain incomplete.

### GAP-07 — Đan r3-r30 chưa craft

- Priority: P1
- Source finding: Chỉ 4 graded recipe authored r1/r2
- Closure condition: Dừng claim hoàn thiện 30 tầng, thiết kế stage sourcing
- Workbook status: CONTENT_GAP
- Current disposition: BLOCKED_SOURCE — r3-r30 recipes/material sources absent; do not invent.

### GAP-08 — Quyền/Độc chưa exhaustive

- Priority: P1
- Source finding: Cung 183 exhaustive; hai nhánh còn lại mẫu
- Closure condition: Bổ sung per-ID oracle toàn bộ V63 catalogue
- Workbook status: QA_GAP
- Current disposition: QA_GAP — Cung history exists; Quyền/Độc per-ID semantic oracle is not exhaustive.

### GAP-09 — Trạng thái QA không theo HEAD

- Priority: P0
- Source finding: Rất nhiều PASS ở baseline khác final SHA
- Closure condition: Bắt buộc test matrix theo commit cuối và đúng package
- Workbook status: QA_GAP
- Current disposition: IN_PROGRESS — named exact-source evidence exists; not all 158 cases executed on final PR SHA.

### GAP-10 — UI hiện nhiều chữ

- Priority: P1
- Source finding: Những màn lớn vẫn dùng labels/scroll và icon đơn giản
- Closure condition: Ưu tiên game-like UI với state thật, screenshot inspect
- Workbook status: VISUAL_GAP
- Current disposition: VISUAL_GAP — 10 Godot renders captured/reviewed via harness; physical interaction/owner visual acceptance pending.

### GAP-11 — Android chưa chạy thật

- Priority: P2
- Source finding: Cần input touch/độ phân giải/RAM trên thiết bị
- Closure condition: Đặt release gate riêng, không gọi PASS từ Windows
- Workbook status: PENDING
- Current disposition: ANDROID_PENDING — no physical Android run.

### GAP-12 — C2 animation lab chưa nghiệm thu

- Priority: P1
- Source finding: Seam/alpha/atlas memory; video→sprites thiếu acceptance
- Closure condition: Không đưa lab vào runtime trước Godot QA
- Workbook status: ART_HOLD
- Current disposition: ART_HOLD — C2/lab assets remain separate and unaccepted.

### GAP-13 — 27 bậc/cap đệ tử

- Priority: P1
- Source finding: Source chưa có bảng stage hoàn thiện được duyệt
- Closure condition: Đối chiếu 27 bậc và nhân 90/tiên200/thần400-500
- Workbook status: DESIGN_HOLD
- Current disposition: DESIGN_HOLD — 27-rank pacing/population numeric decision incomplete.

### GAP-14 — Nhân sự chuyển nhà/đi làm

- Priority: P1
- Source finding: Local patch mới phải verify door/collision/state
- Closure condition: Tạo test transitions, offscreen & Save
- Workbook status: LOCAL_UNCOMMITTED
- Current disposition: IN_PROGRESS — code patch pushed; density/assignment tests pass; full door/offscreen/Save transition not closed.

### GAP-15 — Cũ mới bị quên

- Priority: P1
- Source finding: PR parity vẫn có DESIGN_HOLD và chức năng không port
- Closure condition: Lập requirement registry và change-impact mandatory
- Workbook status: QA_PROCESS_GAP
- Current disposition: PARTIAL — register/matrix/E2E artifacts exist; per-case execution/impact updates remain ongoing.

## Artifacts

- [158-case acceptance matrix](TMB_PR72_FEATURE_ACCEPTANCE_MATRIX_20261106.csv)
- [10 E2E journeys](TMB_PR72_E2E_JOURNEYS_20261106.md)
- [Execution subset and evidence](PR72_MASTER_QA_20261106/EVIDENCE_INDEX.md)
