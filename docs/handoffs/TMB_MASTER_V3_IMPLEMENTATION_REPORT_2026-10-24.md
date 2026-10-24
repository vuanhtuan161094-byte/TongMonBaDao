# TÔNG MÔN BÁ ĐẠO — MASTER V3 IMPLEMENTATION REPORT

Ngày nghiệm thu: 2026-10-24
Repository: vuanhtuan161094-byte/TongMonBaDao
Nhánh cách ly: integration/master-v3-combat-d7-uiux-20261024
Base bắt buộc: PR #26 head 53ff0b223f4e77ccfbe5c77d2203496ac0cc37a9
Code/test commit: 80ed0270d2b7370f8feff1ce829f167146f3f341
GitHub draft PR commit: 2890a4904a9fcfa106a34d88c1f169381cbd9a5
Engine: Godot 4.7.2.stable.official.ed1daf0bf, Windows x86_64
Độ phân giải ảnh GUI: 1280×720

## Tóm tắt trạng thái

Đã chạy prompt hợp nhất từ tài liệu theo yêu cầu người dùng. Code D7, SaveService migration, focused regression, Combat V2 fixture và P3.2 capture có bằng chứng ở SHA code bên trên. Đây không phải FULL/CI PASS, Owner Visual PASS hay nghiệm thu thiết bị thật.

PR #24/#25/#26 không bị sửa hoặc merge. FULL/CI không chạy. Nhánh mới dựa chính xác trên PR #26 head. PR #27 draft: https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/27; GitHub head 2890a4904a9fcfa106a34d88c1f169381cbd9a5. Remote commit tree khớp với local handoff tree.

## Bảng trạng thái

| Workstream | Baseline SHA | Code SHA | Test/evidence | Screenshot | Status | Blocker |
|---|---|---|---|---|---|---|
| P0: P3.2/CARE/SaveService | 53ff0b2 | 80ed027 | Focused suite 20/20 PASS trong userdata sạch; capture P3.2 PASS, receipt + reload đúng | 12 ảnh actual | FOCUSED_PASS | Capture scripted, không phải thao tác chuột; Injury=0 trong frame |
| P1: Combat V2 trace | 53ff0b2 | 80ed027 | 62 nhóm × 20 seed = 1.240 trận, 176.682 event | CSV + ledger | IMPLEMENTED | Fixture synthetic, không phải balance approval; Boss B3 chưa nối live |
| P2: D7/migration | 53ff0b2 | 80ed027 | D7 test PASS 139 checks; deterministic, pool, provenance, save wire, HP | D7 7-axis profile | FOCUSED_PASS | Tâm Tính chưa có consumer; owner review còn chờ |
| P3: x100 combat/potion/item rebalance | 53ff0b2 | — | Không đổi các hằng số HP, damage, potion hoặc economy | Mockup không phải gameplay | PENDING_OWNER | Chưa được duyệt bảng giá trị cuối |
| P4: D7 profile UI | 53ff0b2 | 80ed027 | 7 trục và giá trị current/birth/delta có test | Current→annotated→mockup→actual | FOCUSED_PASS | Còn dày chữ/scrollbar; owner visual chưa duyệt |
| P4: map/worksite/combat HUD | 53ff0b2 | — | Mockup chưa được chuyển thành UI runtime | 4-up + 12 before/after | MOCKUP_ONLY | Chọn phạm vi UI tiếp theo sau owner review |
| Windows manual/Android/Owner visual | 53ff0b2 | — | Chưa có người thao tác hoặc thiết bị thật | Engine capture không thay manual QA | PENDING_OWNER | Nghiệm thu thủ công |

## P0 — Bằng chứng thực tế

Baseline screenshot: commit 53ff0b223f4e77ccfbe5c77d2203496ac0cc37a9. Actual after: commit 80ed0270d2b7370f8feff1ce829f167146f3f341. Cả hai dùng scene res://scenes/p3/p3_2_landscape_sect.tscn, Godot official 4.7.2, OpenGL Compatibility trên Intel Iris Plus, 1280×720, seed 31012026.

Capture sau code có 12 ảnh. Trong cảnh săn, AUTO bật; V2 candidate candidate_73021 được tạo và nhận qua generator/recruitment canonical trong state capture cô lập; CARE B3 world id được giữ. Log ghi hit và skill_hit ở battle 4 giây, kill/loot receipt COMMITTED ở 12 giây. Sau loot: HP=123.38/192.3, Injury=0, paid_generation=1, Kho Tinh Lang Bi=1. SaveService reload xác nhận paid_generation=1 và Warehouse stock=1. Cùng-world redeploy, Injury và exactly-once retry được kiểm qua gameplay tests, không suy ra chỉ từ frame capture.

Capture không tạo ra Injury120: state injury trong capture combat/return là 0. Injury settlement test PASS trong focused suite. Vì vậy yêu cầu ảnh UI đang hiện Injury120 vẫn PENDING_OWNER.

Log: outputs/TMB_MASTER_V3_20261024/03_actual_after_godot/commit_80ed027/godot_capture.log
Manifest: outputs/TMB_MASTER_V3_20261024/03_actual_after_godot/commit_80ed027/capture_state_manifest.json

## P1 — Combat V2 trace study

Fixture chạy trên code commit 80ed027 bằng Godot official 4.7.2. Kết quả: 62 nhóm, 1.240 trận, 20 seed mỗi nhóm, 176.682 action events. Tổng là 600 thắng và 640 thua; tỷ lệ gộp không dùng làm balance target.

Ví dụ equal_progress Tu Vi 1 / Body 1:

| Đội | Mục tiêu | Thắng | Median thời gian trận thắng | Skill cast/hit | Heal events |
|---:|---|---:|---:|---:|---:|
| 1 | Normal | 0/20 | — | 20/20 | 0 |
| 1 | Elite | 0/20 | — | 20/20 | 0 |
| 1 | Boss fixture | 0/20 | — | 20/20 | 0 |
| 3 | Normal | 20/20 | 16.5s | 0/0 | 79 |
| 3 | Elite | 0/20 | — | 0/0 | 60 |
| 3 | Boss fixture | 0/20 | — | 69/69 | 89 |
| 6 | Normal | 20/20 | 9.25s | 20/20 | 40 |
| 6 | Elite | 20/20 | 20.0s | 72/64 | 87 |
| 6 | Boss fixture | 20/20 | 16.5s | 20/20 | 80 |

Trong nhóm 1v1 normal trên 20 seed, mean basic interval=1.75s, mean critical rate=6.2%, mean 2s burst=59.305, không heal/AoE. Nhóm 6v6 elite có 72 skill cast/64 hit, 87 heal event và AoE target. Đây là output fixture, không phải balance mục tiêu. CSV ghi TTK/DPS/burst/basic interval/skill/crit/heal/guard/AoE/telegraph; event ledger giữ timestamp và target.

Giới hạn: đội và đối thủ là fixture chẩn đoán từ Combat V2, không bao phủ trang bị, mọi build kỹ năng hoặc Boss CARE live. B3 pilot hiện không phát Boss event thật để nối Boss-slot/AoE presentation. Không dùng fixture để duyệt economy hoặc chỉnh hồi đan.

Log/CSV: outputs/TMB_MASTER_V3_20261024/04_combat_fixtures/commit_80ed027/.

## P2 — D7 model và SaveService

D7 model chia Tam Căn 3 stat: Tư Chất, Căn Cốt, Tâm Tính; Tứ Tính 4 stat: Tiềm Lực, Thông Tuệ, Cơ Duyên, Mị Lực. Q_birth = 6/7 × tổng 7 birth value; Q_current = Q_birth + tổng(current−birth). Hai ngân sách được sinh/phân phối độc lập, giữ tổng từng nhóm. Source odds không đổi. Heaven-defying tăng depth bằng biến cố chung 12%.

P3.7 factory/recruitment candidate sinh provenance D7 model 3. Migration model 2 giữ nguyên sáu stat cũ và ánh xạ birth mind_nature bằng trung bình sáu birth stat; thiếu birth provenance thì fail-closed. SaveService schema mới 3; CARE wire mới version 4 và vẫn đọc CARE wire 3. Live HP đồng bộ khi authority maxHP thay đổi; cùng maxHP không gây drift 1 ULP.

D7 potential chỉ áp dụng cho RealmCore stat khi caller bật scope D7; Body không nhân theo potential. Tâm Tính chưa có consumer gameplay và UI ghi Luyện Tâm chưa mở. Không thêm hunt EXP hay luật CARE mới.

D7 focused test: D7 FOUNDATION V3 MIGRATION/GENERATION/POTENTIAL SCOPE PASS, checks=139. Log: outputs/TMB_MASTER_V3_20261024/05_focused_tests/final_rerun_exact_commit_80ed027/d7_foundation_v3_migration_test.log.

## P3 — Giá trị chưa được điều chỉnh

Không áp dụng multiplier ×100 cho HP, damage, hồi đan, vật phẩm hoặc economy. Không đổi CARE pill values, Đan Bão Hòa, loot table hay Injury120. P3 đang chờ owner duyệt bảng số cuối. Mockup không phải số gameplay.

## P4 — Tình trạng UI

Profile V2 thật đã dùng D7 7 trục, group Tam Căn/Tứ Tính và current/birth/delta; không hiển thị radar sáu trục cho D7. Profile test xác nhận Tâm Tính có giá trị thật. Các ảnh sau code vẫn cho thấy profile còn nhiều chữ/scrollbar; cần owner review.

Mockup map/worksite/combat HUD vẫn là ảnh tĩnh. Actual after cho thấy floating worksite cards còn chồng map, production panel còn dài, combat facts dày và actor/numeric cue chen vùng giữa. Chưa triển khai mockup map/production/combat vào runtime. Xem UI issue matrix; không gọi UI/UX final.

Capture P3.2 có Source A female 1113028_1 và monster 1113031_1 trong CARE/Combat V2 world, qua V5 presentation có sẵn trên PR26. Dùng một V2 recruit tạo qua canonical recruitment trong test state, không tạo sáu đệ tử giả. Boss-slot không được giả làm Boss live vì CARE B3 chưa có Boss event mapping.

## Focused regression trên SHA code

Lần chạy đầu trên userdata từng được dùng trước đó: 19/20. p3_o9_m2_production_rehearsal_test dừng trước production vì roster fresh không cấp được worker. Không sửa code/test sau lần này. Rerun với userdata hoàn toàn mới: 20/20 PASS, exit 0, marker PASS, zero script/parse error. O9 isolated rerun trên userdata mới cũng PASS. Nguyên nhân sai khác đầu tiên chưa xác định; giữ lại cả hai log.

Godot executable: E:/Godot_v4.7.2-stable_win64_console.exe
Focused summary 20/20: outputs/TMB_MASTER_V3_20261024/05_focused_tests/final_rerun_exact_commit_80ed027/focused_summary.csv
Lần đầu 19/20: outputs/TMB_MASTER_V3_20261024/05_focused_tests/final_rerun_d7_final/
Rerun sạch 20/20: outputs/TMB_MASTER_V3_20261024/05_focused_tests/final_rerun_exact_commit_80ed027/

Bộ 20 test: d7_foundation_v3_migration_test, b3_main_hunt_integration_test, b3_fasttrack_hunt_test, b3_care_pills_autohunt_test, b3_pill_satiety_test, b3_ph0_continuous_kernel_test, dv2_02_battle_snapshot_test, dv2_02_group_map_battle_test, dv2_02_five_level_pve_test, gp_02c1_injury_settlement_test, dv2_03_p3_v2_disciple_profile_test, gp_02a_v2_cultivation_panel_test, p3_2_map_camera_test, p3_1_landscape_shell_test, sect_iso_projection_contract_test, sect_map25_verified_art_gate_test, sect_iso_main_integration_test, sect_g1_disciple_radar_test, b3_care_combat_v5_presenter_test, p3_o9_m2_production_rehearsal_test.

## Code files trong checkpoint 80ed027

- godot/src/presentation/disciple_presentation_snapshot_v2.gd
- godot/src/presentation/p3/disciple_six_dimension_radar.gd
- godot/src/presentation/p3_1_landscape_sect.gd
- godot/src/presentation/p3_2_landscape_sect.gd
- godot/src/simulation/bloodline/bloodline_system.gd
- godot/src/simulation/combat/combat_stats_v2.gd
- godot/src/simulation/combat/disciple_combat_loadout_v2.gd
- godot/src/simulation/core/p3_7_factory.gd
- godot/src/simulation/cultivation/disciple_realm_progress_v2.gd
- godot/src/simulation/cultivation/root_refinement_system.gd
- godot/src/simulation/foundation/foundation_system.gd
- godot/src/simulation/recruitment/disciple_generator_open_points.gd
- godot/src/simulation/recruitment/disciple_generator_v2.gd
- godot/src/simulation/save/save_service.gd
- godot/src/simulation/state/candidate_state.gd
- godot/src/simulation/state/disciple_state.gd
- godot/tests/presentation/dv2_03_p3_v2_disciple_profile_test.gd
- godot/tests/presentation/sect_g1_disciple_radar_test.gd
- godot/tests/presentation/tmb_master_v3_current_capture.gd
- godot/tests/simulation/b3_pill_satiety_test.gd
- godot/tests/simulation/d7_foundation_v3_migration_test.gd
- godot/tests/simulation/p3_7c1_foundation_guidance_test.gd
- godot/tests/simulation/tmb_master_v3_combat_trace_fixture.gd

Source A/MAP25 art, CARE combat/economy logic, B3 scheduler, and SaveService ownership were not replaced. Presentation reads existing state.

## Handoff paths

- 12 before/after pairs: outputs/TMB_MASTER_V3_20261024/08_before_after_comparisons/.
- Current→annotated→mockup→actual sheets: outputs/TMB_MASTER_V3_20261024/08_before_after_comparisons/current_annotated_mockup_actual/.
- Current/annotated/mockups: outputs/TMB_MASTER_V3_20261024/00_current_capture/, 01_annotated_issues/, 02_mockups_from_real_captures/.
- Actual after images/log: outputs/TMB_MASTER_V3_20261024/03_actual_after_godot/commit_80ed027/.
- Focused test and combat fixture evidence: outputs/TMB_MASTER_V3_20261024/04_combat_fixtures/ and 05_focused_tests/.
- Representative isolated CARE save: outputs/TMB_MASTER_V3_20261024/07_handoff/save_example/b3_fasttrack_test_main.json.
- Final ZIP: outputs/TMB_MASTER_V3_20261024/07_handoff/TMB_MASTER_V3_CODEX_HANDOFF_20261024.zip.

## Chưa nghiệm thu

- Owner visual review profile/map/worksite/combat: PENDING_OWNER.
- Windows physical mouse/manual play: PENDING_OWNER.
- Android export/touch/rotation/device layout: PENDING_OWNER.
- Actual P3.2 Injury120 screenshot: chưa chụp; gameplay injury test PASS.
- Boss event mapping và live Boss/AoE frame: NOT_STARTED; CARE pilot không có source event.
- P3 ×100 balance numbers và potion/item values: PENDING_OWNER.
- FULL/CI: không chạy theo hướng dẫn.
- PR #24/#25/#26: giữ nguyên, không merge.

