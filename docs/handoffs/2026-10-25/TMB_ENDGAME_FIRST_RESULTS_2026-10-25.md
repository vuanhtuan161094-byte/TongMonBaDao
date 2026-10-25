# TÔNG MÔN BÁ ĐẠO — ENDGAME-FIRST kết quả kiểm chứng (phần đã hoàn thành)

Ngày: 2026-10-25  
Repository: `vuanhtuan161094-byte/TongMonBaDao`  
Branch: `integration/endgame-maps-assets-playable-20261025`  
Baseline: PR #33 head `7a551ca4f8f9b15f3069652c5f557e0fbc29833`; đã áp dụng chọn lọc NET presentation của PR #34, không merge nhánh và không thay các PR cũ.  
Code commit: `14f0927c3161efc0b2afc1e8c411bd9d34dd4281` (tree `1047d56be12f09a7471a415df03838cf07ff31a6`).  
Issue #37 vẫn OPEN. PR #24–#35 vẫn DRAFT/OPEN, không merge.

## Kết quả nhanh

Đã tạo fixture QA xác định từ constructor/state/building/warehouse/scheduler/SaveService canonical và chạy trên scene P3.2 thật. Fixture có 30 Mỏ Lv19, 30 Linh Lâm Lv1, 40 Linh Điền Lv100, 1 Đan Điện Lv1, 1 Đan Tiên Đài Lv100, 1 Rèn Thân Đường Lv1; đây là toàn bộ building families có state canonical hiện được code hỗ trợ. Đội 130 đệ tử V2 được seed tường minh, 100 người nhận việc ở 100 producer. Không tạo building marker giả hoặc state economy riêng.

Generator chạy 120 tick, hoàn tất 404 mẻ và nhập 1.497 đơn vị vào canonical Kho; invariants rỗng và Save/Load giữ 103 building, 130 disciple, tick 120, công việc cùng số lượng. Kho ở mốc seed: `linh_moc=364`, `thanh_linh_thao=175`, `thanh_thiet=548`. Seed SHA-256: `ba1b98d16a6ca26e08915981ca273769f9f23ff15a72f21b5bdd522d8cbb36e1`.

## G0–G8 status

| Giai đoạn | Trạng thái | Bằng chứng / giới hạn |
|---|---|---|
| G0 nguồn/worktree | PASS có giới hạn | Worktree mới trên E, base đúng PR33; Godot `4.7.2.stable.official.ed1daf0bf`; worktree PR cũ giữ nguyên. Không xóa/chuyển master asset hoặc save người dùng. |
| G1 PR33 + PR34 NET | PASS | Dùng PR33 làm ancestry, áp dụng các commit NET PvE presentation từ PR34; test preview xác nhận chỉ đọc. PR #31–#35 vẫn open/draft. |
| G2 inventory/asset | PARTIAL | Catalog `sa-lib-01` có 6.578 dòng, 6.567 fingerprint nguồn duy nhất, 263 QA_PASS / 1.083 PARTIAL / 5.232 BLOCKED; 262 output folder hiện có khớp toàn bộ 5.550 SHA rows. MAP25: 32/32 SHA đúng (4 terrain, 6 road, 19 vegetation/props, 3 building). Không chuyển đổi asset. 6.578 record chưa map role; 1 QA_PASS record thiếu output folder. Chưa xác minh/integrate rig/action clips, pivot/FPS/hướng, Mỏ/Linh Lâm/Linh Điền, cổng, cư xá, nước/cầu. Ba SVG worksite trong PR33 vẫn là prototype chưa duyệt, không phải Source A. |
| G3 sect endgame | PARTIAL, có thể mở chơi | Seed P3.2 canonical ở trên; thật sự chạy production/ETA/settlement và Kho. Bản đồ phân bố vùng producer trên world lớn, có pan/zoom và select ba producer; ảnh/video render từ `p3_2_landscape_sect.tscn`, save/reload scene xác nhận cùng counts/Kho. Đội 130 là QA seed, không chứng minh tiến trình tự nhiên từ đầu game. Màn overview dày, nhiều sprite chồng; không gọi Owner Visual PASS. |
| G4 PvE 20 bãi | BLOCKED / CHƯA TRIỂN KHAI | PR34 20-camp scene vẫn là design viewer. `B3HuntWorld` hiện chỉ có 1 spawn slot + 1 disciple; `HuntingPveRunV2` là encounter riêng, chưa nối scheduler/world/camp. Chưa có 200–400 mob sống đồng thời, 30 hunter trong world, nav/respawn nhiều bãi, Boss/Elite world event hay loot receipt theo từng quái. Không dùng viewer làm chứng cứ gameplay. |
| G5 regression/perf | PASS phần focused; PERF PARTIAL | Godot 4.7.2 sau code commit: PR32 baseline 29/29 PASS, gồm O9; `combat_v3_s1_edge_contract` 56 checks PASS. Thêm 4 contract endgame/D2/PvE-preview: 4/4 PASS. Không chạy FULL/CI. Movie capture 281 frames; engine FPS sample trong Movie Maker mean 31.32/min 2/max 40 bị chi phối encoding, không đại diện gameplay bình thường. CPU render 3.04 ms/frame, GPU render 0.82 ms/frame, encoding 12.70 ms/frame. Game process RAM: 8 mẫu/8 giây mean/min/max 645.8 MiB; không có Android/VRAM benchmark. |
| G6 Forge R1 | BLOCKED | Không có canonical Forge recipe/order/transaction đủ để rèn và equip R1 qua Warehouse trong P3.7; P2 legacy không được dùng làm authority thay thế. Không tự đặt cost/chance. |
| G7 tối ưu/dedup | PARTIAL | Giữ tối ưu cache AStar/terrain/road đã có trên PR33; không xóa/di chuyển asset gốc. Chưa có benchmark trước/sau cùng máy nên không tuyên bố tăng hiệu năng. |
| G8 handoff | PARTIAL | Có fixture, launcher, manifest, logs, ảnh và AVI; không merge. PR draft sẽ dựa trên nhánh PR33. |

## Gameplay/evidence P3.2

- Official runtime log: `outputs/endgame_qa_20261025/logs/endgame_gameplay_capture.log`.
- Evidence JSON: `godot/outputs/endgame_qa_20261025/gameplay/endgame_gameplay_evidence.json`.
- Captured selections: `mine_021`, `linh_forest_021`, `spirit_field_035`; camera pan/zoom true; panel visible on all three; save/reload true; fresh P3.2 scene reopened; 25 work cycles remained active; invariants rỗng.
- 1280×720 stills: `00_endgame_full_map.png`, `01_endgame_camera_pan_zoom.png`, `mine_021_selected.png`, `linh_forest_021_selected.png`, `spirit_field_035_selected.png`, `05_fresh_p3_2_save_reload.png` under `godot/outputs/endgame_qa_20261025/gameplay/`.
- AVI: `outputs/endgame_qa_20261025/gameplay/endgame_full_sect_1280x720.avi`, SHA-256 `aa308ae33e63d4e0e58a8917e5e970637f5061fa5d190595cf27adbb54e52976`.
- `Run-Endgame-QA.cmd` opens official Godot 4.7.2 at 1280×720 and seeds an isolated mutable save once. Current play save is `godot/outputs/endgame_qa_20261025/userdata/endgame_playable_save.json`; it is deliberately not committed because it changes while playing. At last check it had reached tick 143; SHA `2da93287890ace53b3a4bdac5c6fbe80de5adcdd7d8884b0723896d33fea9b3f` (mutable, not a fixed fixture).

Desktop Movie Maker capture used `Input.parse_input_event` through production P3.2 handlers. This proves engine rendering, map picking and Save/Load signals, not a physical mouse session. A direct desktop-window capture timed out on both permitted capture attempts. Therefore Windows manual input/usability remains PENDING USER; the launcher is openable from E and does not require Administrator. There is no exported standalone EXE because export templates were not installed/used.

## Logs and inventory

- Focused 29: `outputs/endgame_qa_20261025/logs/focused_29_final_20261025_232709_423/focused_results.csv` and per-test logs.
- Added 4: `outputs/endgame_qa_20261025/logs/endgame_map_additional/focused_results.csv` and per-test logs.
- Endgame generator report/save: `godot/qa/endgame_qa_report.json`, `godot/qa/endgame_qa_save.json`.
- Source A inventory: `outputs/endgame_qa_20261025/assets/asset_inventory_summary.json`, `sourcea_library_asset_inventory.csv`, `sourcea_library_current_sha256.csv`, `map25_verified_sourcea_current_sha256.csv`.
- The tracked `godot/tests/presentation/tmb_master_v3_current_capture.gd` was recovered from the verified official text copy, because its base blob was binary garbage (original SHA-256 `15e3b9ce48e3a321dd0f3e13fe4c28be1ba2c7363bd74c02454f4c1b89d9f0b8`; recovered file SHA-256 `f044033a659db90df0c865176fd0a9964be3000bc8bfb8695b323d70092aea64`). It is a capture harness repair, not gameplay authority.

## Rollback / next work

All changes are on the new branch. A draft PR has not yet been created. Revert only after preserving its commit/QA evidence; never delete PR #24–#35 or original source data. No main merge.

Next authorized continuation within Issue #37: build a persistent multi-camp world over the shared clock/SaveService, with per-monster idempotent loot receipts drawn from existing authored content; first add small 1-camp restart/save slice, then scale toward 20 camps without calling preview code gameplay. Keep Combat V2/S1 math, Injury120, One Active Job, canonical Warehouse/SaveService. Forge follows only if canonical recipe/transaction becomes available. Manual Windows/Android/Owner Visual remain PENDING USER.
