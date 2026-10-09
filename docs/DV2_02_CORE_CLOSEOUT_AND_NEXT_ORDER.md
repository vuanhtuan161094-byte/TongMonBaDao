# DV2-02 — CHỐT PHẦN LÕI VÀ THỨ TỰ PHÁT TRIỂN TIẾP

Ngày: 09/10/2026. **Quyết định người chơi: tiếp tục đúng 4 bước, không mở thêm bản đồ, quái hoặc bộ trang bị mang tính trang trí.**

## Thứ tự bắt buộc

1. **Hoàn thiện phần lõi DV2-02 trước**: bộ tính 16 chỉ số, 10 kháng hệ, nguồn buff hợp lệ, một chiến trường nhiều đệ tử/multiple monster, phát đòn và sát thương đúng, phát lại tất định, save/reload giữa trận, lưu danh tính + độ khó + hoàn tất/chống thưởng hai lần. Không mở thêm map/species.
2. **Tu Vi + Luyện Thể V2**: triển khai HAI tiến độ thật, mỗi đường 30 đại cảnh ×10 tầng, HP/Công/Thủ và bảng chỉ số tính lại từ cùng state. Tu Vi lên tầng nhỏ tự động; đột phá đại cảnh có cổng. Luyện Thể có EXP và điều kiện riêng, không ăn gian Tu Vi. Đọc `REALM_LADDER_V2_SPEC.md`, `BODY_CULTIVATION_V2_SPEC.md`, `CULTIVATION_BREAKTHROUGH_V2_SPEC.md`; giữ luật 15s commit P0 và quyền sở hữu state thống nhất. Không tự tạo thêm chỉ số/chiến lực nguồn thứ hai.
3. **Nguồn buff V2 đầy đủ**: 10 vị trí trang bị / 12 phẩm / set đồ đã khóa ở design, học kỹ năng Nhân–Tiên–Thần, Linh Căn, Đặc Chất, Huyết Mạch, Thể Chất và Mệnh Cách. Từng nguồn cần channel, source_id, thời điểm kích hoạt và owner thật. Chỉ hiệu ứng thực mới vào combat/production; hiện có adapter P2 tạm để kiểm thử, không được gọi đã hoàn thiện trang bị V2.
4. **Quay lại PvE bản đồ sản phẩm**: chọn 5 cấp/bản đồ (tất cả có thể gặp Tinh Anh/Boss với xác suất khác nhau), thực sự nối ngoài-map cảnh 2D vào scheduler, sinh quái và điều hướng tránh vật cản, AI của từng loài, boss nhiều giai đoạn, chiến thuật đội hình, rút lui, vật phẩm, thời lượng đi săn, cân bằng 16+ thuộc tính, lịch sử và test với đủ nguồn buff. **Không** khóa cân bằng quái bằng nhân vật P2 yếu/hay buff giả.

## DV2-02: đã có code lõi và kiểm thử riêng

- `CombatStatsV2`: 16 chỉ số chiến đấu + 10 kháng hệ, chỉ số gốc từ 30×10 của Tu Vi/Luyện Thể và Tiềm Lực, cộng hiệu ứng có định danh; không quy đổi `combat_power` cũ thành ATK.
- `MapBattleV2`: nhiều đệ tử/quái cùng một trận, một AI/tick simulation, vị trí, hồi chiêu, niệm chiêu, hành vi và hiệu ứng kỹ năng có sẵn; cả khi camera không nhìn, kết quả vẫn giống.
- `CombatContextEffectsV2`: sát thương Boss/Elite/chủng tộc, liên kích đánh thường không tự đệ quy. Chỉ số chưa được owner chuyên dụng kích hoạt thì không fake buff.
- `HuntingMapV2`: năm lựa chọn cho mỗi map, quái thường/Tinh Anh/Boss, tiêu chuẩn tài nguyên và replay-safe reward P3.7 kho.
- `HuntingPveRunV2`: chạy một chuyến săn thật ở chế độ opt-in từ state hiện hành, chỉ nhận **tường minh** hai tiến độ V2 do DV2-03 chưa lưu thật.
- `MapBattleSnapshotV2`: checkpoint chiến đấu lossless, mỗi actor HP/vị trí/stat/cooldown, các cast đang pending, RNG 64-bit, sự kiện. **Không** lưu JSON number float/64-bit trực tiếp gây khác sát thương/ngẫu nhiên: dùng `var_to_bytes` của Godot 4.7.2, base64 trong JSON và schema version, restore bằng `bytes_to_var` (không giải mã object).
- `SectState.v2_pve_active_runs`: trạng thái đang săn gắn encounter ID; cập nhật khi trận đánh tiến triển, giữ lại trong save/load, có thể resume thông qua `HuntingPveRunV2.resume_active`, chặn trùng encounter, giải phóng khi thắng và nhận thưởng thực. Còn cần nối vào **lifecycle savegame/scheduler của bản đồ ngoài** ở bước 4; chưa được tự nhận là live outside map.
- Hệ HP V2 và tiến độ Tu Vi/Luyện Thể chưa được ghi đè bừa vào Legacy P2. **HP V2 của người chưa chuyển schema chỉ sống ở encounter snapshot**; migrate/sync HP chuẩn là nhiệm vụ cùng thời điểm DV2-03.

## Kiểm thử và điều kiện gọi đóng

- `godot/tests/simulation/dv2_02_combat_stats_test.gd` — 16 chỉ số, combat damage, hút máu.
- `dv2_02_monster_context_test.gd`, `dv2_02_group_map_battle_test.gd` — quần công nhiều đơn vị, boss/skill/range/AoE/event.
- `dv2_02_battle_snapshot_test.gd` — JSON round trip lossless và restart giữa trận cho cùng **event journal/cast/RNG/HP**; chặn save hỏng/giả kết quả.
- `dv2_02_five_level_pve_test.gd` — 5 lựa chọn/map, sources trang bị & learned damage skills có sẵn, **SectState checkpoint + resume**, thưởng đúng 1 lần.
- `dv2_02_five_tier_balance_test.gd` (xem workflow đúng đường test thật nếu tên thay đổi) — PILOT group balance; không gọi các tỷ lệ thắng đã được người chơi duyệt.
- `.github/workflows/dv2-02-combat-stats.yml` (Godot 4.7.2 focused).
- `.github/workflows/p3-7a1-building-backend.yml` (P3.7 full cumulative) cần **PASS ở commit code cuối** trước khi gọi lõi DV2-02 BACKEND LOCKED.

**Ranh giới PASS:** sau focused + cumulative PASS, có thể khóa **nền tảng tính chỉ số và mô phỏng group combat V2**, rồi mở DV2-03. Nhưng **không đồng nghĩa** PvE sản phẩm/Boss AI V2 đã chơi trên outside region map, các passive Innate/Equipment V2 đã nối, hoặc 30×10 Tu Vi/Luyện Thể thật đã cài; đó là các bước 2–4 ở trên. Giữ tên, bằng chứng và checkpoint rõ để không nhầm trạng thái.
