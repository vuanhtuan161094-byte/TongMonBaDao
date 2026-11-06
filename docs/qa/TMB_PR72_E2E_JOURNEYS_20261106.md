# TMB PR #72 — E2E Journeys (2026-11-06)

All 10 journeys are copied from the workbook. Partial headless subflows remain IN_PROGRESS, not complete.

- Workbook SHA-256: 304d4dc2bff846824762f2cb62df10cb9c0b18dcfc3f4729e8d1f33998574c1d.
- Current code evidence SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb; P3.2/density subset SHA: 374f2d47d887c828218e3a296b6c8370aff070e7.
- Physical Windows and Android are separate gates.

## J01 — New Game 10–20 phút

- Route: New Game → camera/map → Đại Điện/Đài/Xá → tuyển 1 → hồ sơ
- Acceptance oracle: Không fixture/cấp không; người chơi biết làm gì, actions hoạt động
- Priority: P0
- Current status: IN_PROGRESS
- Evidence SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb
- Coverage/limitation: Headless R3 confirms New Game/build/recruit state; 10–20 minute player GUI journey/onboarding not accepted.
- Evidence: PR72_MASTER_QA_20261106/logs/r3/r3_create.stdout.log

## J02 — SX 30–60 phút

- Route: Có worker → Mỏ/Linh Lâm → timer → Kho → xây/nâng hợp lệ → Save/cold Reload
- Acceptance oracle: Sản lượng chỉ settle sau hoàn thành, job không trùng, giá/chi phí thật
- Priority: P0
- Current status: IN_PROGRESS
- Evidence SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb
- Coverage/limitation: Mine/Forest/Warehouse/cold reload have focused tests; no 30–60 minute continuous physical playthrough.
- Evidence: PR72_MASTER_QA_20261106/logs/production/p3_o7_linh_forest_test.stdout.log

## J03 — Linh Điền–Đan

- Route: Làm plot → trồng → thu → Warehouse → recipe r1/r2 → uống
- Acceptance oracle: Nhận/craft/consume mỗi lần đúng 1 receipt; gate r2 đúng Hall/Alchemy
- Priority: P0
- Current status: IN_PROGRESS
- Evidence SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb
- Coverage/limitation: Field planting/harvest and Warehouse are tested separately; full r1/r2 Alchemy/use chain not proven in this save.
- Evidence: PR72_MASTER_QA_20261106/logs/production/p3_o4_spirit_field_loop_test.stdout.log

## J04 — PvE 1–30 hunter

- Route: Chọn 1 → AUTO/HOLD → loot → rút; thêm hunter tới 30 → Boss 6
- Acceptance oracle: 20 zones/40 mobs/200 registry, world liên tục, HP0/loot/injury chính xác
- Priority: P0
- Current status: IN_PROGRESS
- Evidence SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb
- Coverage/limitation: R3 covers solo HP0/rewards; 30 hunters/20 zones/40 live mobs/200 respawns/Boss gate not rerun in this subset.
- Evidence: PR72_MASTER_QA_20261106/logs/r3/r3_create.stdout.log

## J05 — Kỹ năng thật

- Route: Farm sách từ nguồn authored → học → equip → cast → PvE → Save
- Acceptance oracle: Chỉ PASS sau khi release gates và manual acquisition thực sự có
- Priority: P1
- Current status: BLOCKED_SOURCE
- Evidence SHA: Not run
- Coverage/limitation: Authored manual/drop source is absent; V6.3 stays default OFF.
- Evidence: GAP-03

## J06 — Tăng trưởng stage Nhân

- Route: Từ New Game tự tiến lên các mốc đã nguồn hóa
- Acceptance oracle: Không mắc kẹt do Tầm Mạch Bàn/đan thiếu nguồn mà vẫn bị gọi hoàn thiện
- Priority: P1
- Current status: BLOCKED_SOURCE
- Evidence SHA: Not run
- Coverage/limitation: Stage material sources and approved pacing remain incomplete.
- Evidence: GAP-06; GAP-07; GAP-13

## J07 — 100+ dân số và map

- Route: Tăng population hợp lệ → GUI roster/camera → 16 actor render → SX/PvE
- Acceptance oracle: Virtualization không làm mất job/save/actor, không trùng lựa chọn
- Priority: P1
- Current status: IN_PROGRESS
- Evidence SHA: 374f2d47d887c828218e3a296b6c8370aff070e7
- Coverage/limitation: Density test checks virtual positions/bounded actors, not a real 100+ roster with SX/PvE continuity.
- Evidence: PR72_MASTER_QA_20261106/logs/focused/endgame_map_density_test.stdout.log

## J08 — Save/migration/chống nhân đôi

- Route: Cùng một save: xây đang dở + timer + PvE + pill → Exit → cold Reload → hành động tiếp
- Acceptance oracle: Không mất state, không nhân tài nguyên, kiểm snapshot delta
- Priority: P0
- Current status: IN_PROGRESS
- Evidence SHA: 5ef179b81dfef6f2d72a38d866e94fc828e179eb
- Coverage/limitation: One isolated save passed across processes; simultaneous under-construction timer + PvE + pill state not covered as one save.
- Evidence: PR72_MASTER_QA_20261106/logs/r3/r3_continue.stdout.log

## J09 — Windows owner mouse

- Route: Mở offline bằng CHOI-GAME, click/drag/zoom/build/assign/PvE/Save
- Acceptance oracle: Đủ bằng chứng thao tác thật, screenshot và exit code engine nếu truy xuất được
- Priority: P0
- Current status: CHUA_NGHIEM_THU
- Evidence SHA: Not run
- Coverage/limitation: Physical owner-session mouse, three clean CHOI starts and native screenshot remain pending.
- Evidence: Physical Windows GUI pending

## J10 — Android người dùng

- Route: Export chạy 1280×720 landscape tap/drag/pinch, chơi một vòng ngắn
- Acceptance oracle: Không bị cắt UI, input đúng và RAM/ảnh hợp lý
- Priority: P2
- Current status: CHUA_NGHIEM_THU
- Evidence SHA: Not run
- Coverage/limitation: No physical Android/touch device run.
- Evidence: Android pending

## Summary

- Complete E2E PASS: 0/10.
- IN_PROGRESS: J01, J02, J03, J04, J07, J08.
- BLOCKED_SOURCE: J05, J06.
- CHUA_NGHIEM_THU: J09, J10.
- Headless R3 evidence is meaningful but does not close physical GUI, full scale PvE, complete alchemy, Android, or comprehensive same-save acceptance.
