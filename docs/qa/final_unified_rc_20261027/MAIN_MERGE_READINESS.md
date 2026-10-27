# Mainline readiness — audit ngày 2026-10-27

## Branch topology và phạm vi audit

- `main`: `29b5fba448b0178cb520a4ada44b375b4b934e31`.
- RC: `integration/pve-unified-rc-20261027` tại `0d3952dd11f85bebbde60176deafc4f19afc8a6f`.
- Compare GitHub: RC ahead **142**, behind **0**, merge-base bằng HEAD main.
- PR #52 vẫn Draft/Open và còn base `feature/pve-jx-continuous-world-20261026`. Không tạo/merge PR vào main khi GUI/FPS chưa đạt.
- Full path scan main→RC trước commit docs cuối chia 8 compare ranges, kiểm tra **742 unique paths**; commit `0d3952dd` chỉ thay 3 file docs đã nằm trong tập path, không thêm code/asset path. Các nhóm scan chồng lấn, không cộng thành tổng độc lập.

## Feature matrix

| FEATURE | MAIN | RC @ 0d3952dd | AUTHORITY | TEST EVIDENCE | DISPOSITION | RISK |
|---|---|---|---|---|---|---|
| Game loop / runtime clock | Bản stable trước nhánh PvE mới | Shared clock integration đã hiện diện | Một simulation clock | runtime clock + live runtime ×2 PASS | KEEP | P3.2 headless chậm; FPS GUI chưa biết |
| Production Source A / map | Renderer sản xuất hiện hữu | Bảo toàn renderer `SectIsometricWorldV1`, map 192×192 | Source A production renderer | pointer 2172, death snapshot, live-map selection PASS | KEEP | Screenshot GUI exact SHA pending |
| Virtual disciples | State/actor policy canonical | Selected-only actor trong viewport | Simulation state là truth; actor chỉ là presentation | live-map test actor_nodes=1, selected bounds in viewport | KEEP | Input thật chưa thử |
| Jobs / One Active Job | Canonical contract | Không đổi authority | One Active Job + scheduler | live runtime + P3.2 save/load checks | KEEP | Work continuity chưa đo bằng GUI |
| Movement / formation | PvE movement chưa có bản hợp nhất này | C17 same-cell recovery và 6 slot riêng/cùng connected region | Simulation/pathfinding/collision | C17 14 checks; formation 10 checks | KEEP | Physical click/path chưa nghiệm thu |
| Combat V2 | Authority sản xuất | Dùng làm damage/HP/death authority; visual adapter không thay kết quả | Combat V2 | HP0 bridge; CARE presenter; JX adapter | KEEP | Tốc độ/diễn hoạt GUI pending |
| 20-camp world | Không có RC world hợp nhất | 20 camps; bounded integration dùng 10 quái live | PvE zone/state services | 20-camp contract; autonomous C01→C02; 6v10 integration | KEEP BOUNDED | 200–400 quái live chưa được nghiệm thu |
| Respawn / zone transfer | Stable không có feature PvE continuous này | C01→C02, respawn, state persistence | PvE world service | autonomous zone progression PASS | KEEP | Encounter không đạt Injury120 |
| Injury120 | Contract giữ nguyên | Online/offline settlement, retreat/defeat/recovery | Injury120 contract | GP-02C1 T119/T120 PASS | KEEP | P3.2 thực tế chưa chạm ngưỡng |
| Save/Load | SaveService canonical | Validation/recovery/migration bảo vệ save; D7 lỗi thuộc fixture | SaveService | D7 A/B, recovery, exactly-once, VFX resume PASS | KEEP | GUI Save/Return pending |
| Warehouse / economy / loot | Warehouse canonical | Không tạo reward khi unpaid/loot pending | Warehouse receipts; no invented loot | negative receipt/no-loot tests PASS | KEEP AUTHORITY; DEFER NEW ECONOMY | Economy V2 branch chưa được duyệt |
| JX #158 VFX | Không có adapter PvE mới trong stable | Cosmetic cast→projectile→impact gắn kết quả Combat V2 | VFX adapter; combat outcome từ Combat V2 | focused VFX Save/Resume PASS; asset static audit | KEEP COSMETIC | Unity prefab/pivot/skill mapping vẫn chưa xác minh; GUI chưa xem |
| Camera / minimap / HUD | Source A UI stable | Camera, selected-only map, minimap data path | Source A UI/camera | camera + live-map + disciple UI headless PASS | KEEP | Camera/minimap chuột thật PENDING |
| Female Stage A | Chưa có đủ PNG trong checkout stable ban đầu | SHA-gated install-only; 42 PNG QA checkout, không commit PNG | Installer + asset manifest | installer SHA, import, down/directions tests PASS | KEEP INSTALLER; NO MASTER ASSET COMMIT | Full in-game GUI integration pending |
| Test / launcher / QA docs | Existing release files | RC launchers, 22-test harness, refreshed canonical checkpoint | Exact-SHA evidence process | all 22 + Stage A supplemental | KEEP | Main still points to prior stable |
| Android | No device result in this audit | No Android run | Android build/release gate | None | DEFER | APK/device/landscape QA absent |
| Combat V3 / Economy V2 / Cultivation / Forge / Boss / Gear research | Other branches/design work | Not pulled into RC by this gate | Existing owner-approved contracts | No exact-RC end-to-end acceptance here | DEFER | Must not import design docs as shipped feature |

## C3 decision

**MAIN_MERGE_BLOCKED_BY_GUI_AND_FPS.** Headless regression passes, but exact-SHA GUI mouse/camera/minimap/Save-Return, authentic capture and logger OFF/ON phase metrics remain pending. Wait for owner acceptance; main remains unchanged.
