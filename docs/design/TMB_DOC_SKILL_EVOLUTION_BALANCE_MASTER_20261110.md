
# TMB ĐỘC TU — BẢNG TIẾN HÓA VÀ CÂN BẰNG CƠ CHẾ 183 ID / 35 DÒNG — DESIGN CANDIDATE V1

**Nguồn snapshot** PR #72 @ `f0afc58bebd41d058f5dbaf713be1b7c29cc01bc`; ngày thiết kế 2026-11-10. **CHƯA DUYỆT; KHÔNG ÁP DỤNG TRONG GODOT.** Data source các catalogue 3 giới đều `enabled:false`. Chỉ commit tài liệu/đề xuất trên nhánh PR72; không thay gameplay, SaveService, chế độ PvE đang chạy, không merge.

## 1. Cấu trúc bắt buộc

- 35 dòng gốc: 2 kỹ năng chung + 3 nhánh × 11. 183 ID = 35 Nhân + 68 Tiên + 80 Thần/hiếm (12 node hiếm gồm 6 ultimate và 6 passive). Không được tự tuyên bố 183 chiêu độc lập.
- Mỗi dòng bảo toàn `family_id`; mỗi node kế thừa `parent` từ V6.3 registry, với fallback `parent_skill_id` từ Divine catalogue. Tuyệt kỹ hiếm và bị động hiếm **thay thế** dạng Thần cùng dòng, không cộng ô.
- Nhân unlock nền, Tiên A/B lựa chọn chiến lược, Thần tiếp tục A/B. Mỗi đệ tử trang bị tối đa bốn active, một ultimate, năm combat passive, một basic và một mobility theo code V63 hiện tại; innate derive theo nhánh.
- Tên UI phải nhất quán: tên gốc + thế hệ + lineage; 183/183 tên ứng viên duy nhất, nhưng cấm đổi ID lưu trong Save. Tên/nút mới không tự chứng minh cơ chế hiện thực.
- **6 nút bị động hiếm đang thiếu trong V63 content registry**: `tmb.skill.poison.doc_cham.passive_05.rare_passive.a`, `tmb.skill.poison.doc_cham.passive_05.rare_passive.b`, `tmb.skill.poison.co_doc.passive_05.rare_passive.a`, `tmb.skill.poison.co_doc.passive_05.rare_passive.b`, `tmb.skill.poison.duoc_doc.passive_05.rare_passive.a`, `tmb.skill.poison.duoc_doc.passive_05.rare_passive.b`. Đưa vào mapping dữ liệu trước code, không xóa khỏi Divine catalogue.

## 2. Cân bằng cơ chế và ràng buộc số — CHƯA KHÓA

**Công thức đề xuất.** `D_direct=ATK_effective × proposed_ratio × mitigation_and_context`; crit/DEF/resistance theo `CombatStatsV2`. Độc gây direct **cộng** status ticks: `D_tick=ATK_at_apply × power × poison_modifier × stack_fair_factor × mitigation`; DoT tick đúng 1 lần/giây, không tăng số tick bởi tốc đánh; tấn công tác động từ các thông số trận thật, không bịa damage/VFX.

- Độc: `owner_cap=5` tầng/mục tiêu; `target_cap=30` tầng tất cả nguồn; giới hạn hiện hành `MAX_TARGETS=3` mục tiêu mỗi cast; radius candidate ≤3 ô. DoT duration ứng viên 6–10 giây. Bắt buộc tách phần damage trực tiếp khỏi phần DoT trong tooltip và bài test.
- Tiêu hao độc: `S` là số tầng **cùng người sở hữu** trên mục tiêu (≤5); `R` là tổng sát thương DoT **chưa xảy ra**, quy đổi về ATK ratio trong phần thời gian còn lại. `bonus_ratio=min(0.60,0.08×S + 0.40×R)`. Áp dụng đúng một lần sau khi loại bỏ các stack cùng chủ; **không lấy stack của đồng minh**, không nhân hưởng nhiều lần qua event. Đây là công thức mới cần code và QA; **runtime hiện vẫn là +0,05 ratio/own-stack, cap +0,75, sau đó xóa cả stack**.
- Đánh dấu: cá nhân theo caster/target; mục tiêu chỉ hưởng một dấu cùng caster; hệ số ứng viên 1,08–1,15, duration tối đa 7 giây; không tạo global damage multiplier không giới hạn.
- Dược Độc: phục hồi theo % **maxHP của đồng minh** và tình trạng đã mất HP, không áp dụng lên Injury/thương cơ. Để không vô hiệu Đan HP/PvE cash sink, **ngân sách hồi kỹ năng cho mỗi mục tiêu trong cửa sổ 10 phút**: `min(12% MaxHP,35% lượng HP bị mất do damage đã xác nhận trong cửa sổ)`; tính theo HP hồi **thực**, không reset bằng cold reload. Đây là đặc tả cơ chế mới còn chờ QA và nghiệm thu UX; không có nghĩa code hiện đang có budget này.
- Thanh tẩy: phải giới hạn theo **tổng** hiệu ứng tiêu cực được xóa mỗi cast (Nhân 1; Tiên/Thần 2), xác nhận quyền xóa riêng mỗi trạng thái. Runtime hiện có logic xóa độc và `burn/weaken` riêng; cần chống xóa nhiều hơn hợp đồng.
- Không có stun hard CC diện rộng mặc định; Boss chống lạm dụng stack/DoT, elite giảm downtime; AoE tuyệt đối không vô tình đánh toàn bộ 40 quái active. Không tăng giả drop, kill receipt hay Tu Vi thưởng.
- Tốc độ/cooldown gốc Nhân→Tiên→Thần được tiến hóa vừa phải (ratio base ×1,18/1,34; CD ×0,96/0,92 trước tùy biến A/B), **không gấp 10 lần**, phần lớn sức mạnh tổng đến từ realm và trang bị. Đột phá + rare chỉ là nâng cấp độc quyền theo đường cũ.
- Passive mỗi vị trí một channel cụ thể (crit/ATK speed/CD recovery/poison/heal/guard/outgoing/cast speed); không nhân 5 passives cùng `poison_factor=0,05` làm bùng sức mạnh.

## 3. Ma trận tiến hóa 35 dòng (bảng tổng; đầy đủ 183 dòng ở CSV/JSON)

**Tham số trong bảng là đề xuất, không phải code.** `ratio` là hệ số ATK direct; riêng `heal` `power` là tỷ lệ MaxHP; `cleanse` `power` là số nhóm debuff; `mark` `power` là hệ số sát thương khi có mark. Bị động dùng `passive_modifiers`.

| Dòng / kỹ năng Nhân | Vai trò gốc | Nhân: hệ số / CD / mục tiêu | Tiên A | Tiên B | Thần A/B |
|---|---|---|---|---|---|
| Độc Châm Thường Thức | Đánh thường | 1,00× ATK / 1,60s / 1 | Tiên +18% hệ số nền | Cùng bản gốc Tiên | Thần +34% so với Nhân, chưa tính chỉ số cảnh giới |
| Yểm Ảnh Bộ | Thân pháp giữ tầm | CD 10,00s / né 1s | Tiên giảm CD | Cùng thân pháp | Thần giảm CD, giữ đường đi hợp lệ |
| Xuyên Cốt Độc Châm | Xuyên châm đơn mục tiêu | damage, 1.45×, CD 9s, 1 mục tiêu | damage, 1.71×, CD 8.64s, 1 mục tiêu | damage, 1.92×, CD 8.64s, 1 mục tiêu | A: damage, 1.94×, CD 8.28s, 1 mục tiêu; B: damage, 2.18×, CD 8.28s, 1 mục tiêu |
| Phệ Mạch Độc Thích | Tích độc đơn mục tiêu | poison, 1.10×, CD 9s, 1 mục tiêu, DoT 0.025/tick × 8s × 1 tầng | poison, 1.30×, CD 8.64s, 1 mục tiêu, DoT 0.0324/tick × 8.5s × 2 tầng | poison, 1.42×, CD 8.64s, 1 mục tiêu, DoT 0.026/tick × 8.5s × 1 tầng | A: poison, 1.47×, CD 8.28s, 1 mục tiêu, DoT 0.0369/tick × 9s × 2 tầng; B: poison, 1.61×, CD 8.28s, 1 mục tiêu, DoT 0.0295/tick × 9s × 1 tầng |
| Bách Độc Tán Châm | Mưa châm rải độc 3 mục tiêu | poison, 0.95×, CD 11s, 3 mục tiêu, DoT 0.018/tick × 6s × 1 tầng | poison, 1.12×, CD 10.56s, 3 mục tiêu, DoT 0.024/tick × 6.5s × 1 tầng | damage, 1.29×, CD 10.56s, 3 mục tiêu | A: poison, 1.27×, CD 10.12s, 3 mục tiêu, DoT 0.0273/tick × 7s × 1 tầng; B: damage, 1.46×, CD 10.12s, 3 mục tiêu |
| Độc Khí Phệ Tâm | Vùng khói độc tồn lưu | poison, 0.90×, CD 12s, 3 mục tiêu, DoT 0.024/tick × 6s × 1 tầng | poison, 1.06×, CD 11.52s, 3 mục tiêu, DoT 0.0283/tick × 7.5s × 1 tầng | consume_poison, 1.17×, CD 11.52s, 3 mục tiêu | A: poison, 1.21×, CD 11.04s, 3 mục tiêu, DoT 0.0322/tick × 8s × 1 tầng; B: consume_poison, 1.33×, CD 11.04s, 3 mục tiêu |
| Vạn Độc Xuyên Tâm | Đại trận châm độc 3 mục tiêu | poison, 1.80×, CD 36s, 3 mục tiêu, DoT 0.025/tick × 8s × 2 tầng | poison, 2.12×, CD 34.56s, 3 mục tiêu, DoT 0.0324/tick × 8.5s × 2 tầng | consume_poison, 2.34×, CD 34.56s, 3 mục tiêu | A: poison, 2.41×, CD 33.12s, 3 mục tiêu, DoT 0.0369/tick × 9s × 2 tầng; B: consume_poison, 2.65×, CD 33.12s, 3 mục tiêu |
| Thấu Mạch Độc Công | Uy lực DoT | poison_factor=0.05 | poison_factor=0.0735 | poison_factor=0.07 | A: poison_factor=0.0945; B: poison_factor=0.09 |
| Bách Châm Tinh Thông | Xác suất chí mạng | crit_bonus=0.02 | crit_bonus=0.028 | crit_bonus=0.0297 | A: crit_bonus=0.036; B: crit_bonus=0.0382 |
| Tẩm Độc Châm | Tốc độ đánh thường | attack_speed_factor=0.02 | attack_speed_factor=0.028 | attack_speed_factor=0.028 | A: attack_speed_factor=0.036; B: attack_speed_factor=0.036 |
| Thấu Độc | Phục hồi hồi chiêu | cooldown_recovery_factor=0.02 | cooldown_recovery_factor=0.028 | cooldown_recovery_factor=0.028 | A: cooldown_recovery_factor=0.036; B: cooldown_recovery_factor=0.036 |
| Hóa Độc Nhất Kích | Sát thương trực tiếp | outgoing_factor=0.025 | outgoing_factor=0.035 | outgoing_factor=0.0385 | A: outgoing_factor=0.045; B: outgoing_factor=0.0495 |
| Bách Độc Nhập Cốt | Chân ý châm độc | poison_factor=0.025; crit_bonus=0.01 | poison_factor=0.0368; crit_bonus=0.014 | poison_factor=0.035; crit_bonus=0.0148 | A: poison_factor=0.0473; crit_bonus=0.018; B: poison_factor=0.045; crit_bonus=0.0191 |
| Phụ Cốt Cổ | Cổ ấn đánh dấu cá nhân | mark, 1.00×, CD 10s, 1 mục tiêu | mark, 1.18×, CD 9.6s, 1 mục tiêu | mark, 1.18×, CD 9.6s, 1 mục tiêu | A: mark, 1.34×, CD 9.2s, 1 mục tiêu; B: mark, 1.34×, CD 9.2s, 1 mục tiêu |
| Xà Ảnh Quấn Mạch | Xà độc mục tiêu đơn | poison, 1.05×, CD 9s, 1 mục tiêu, DoT 0.022/tick × 8s × 1 tầng | poison, 1.24×, CD 8.64s, 1 mục tiêu, DoT 0.026/tick × 8.5s × 2 tầng | poison, 1.36×, CD 8.64s, 1 mục tiêu, DoT 0.0221/tick × 8.5s × 1 tầng | A: poison, 1.41×, CD 8.28s, 1 mục tiêu, DoT 0.0295/tick × 9s × 2 tầng; B: poison, 1.55×, CD 8.28s, 1 mục tiêu, DoT 0.0251/tick × 9s × 1 tầng |
| Cổ Vụ Mê Tung | Sương cổ độc vùng | poison, 0.85×, CD 12s, 3 mục tiêu, DoT 0.019/tick × 7s × 1 tầng | poison, 1.00×, CD 11.52s, 3 mục tiêu, DoT 0.0247/tick × 7.5s × 1 tầng | mark, 1.00×, CD 11.52s, 3 mục tiêu | A: poison, 1.14×, CD 11.04s, 3 mục tiêu, DoT 0.028/tick × 8s × 1 tầng; B: mark, 1.14×, CD 11.04s, 3 mục tiêu |
| Tán Cổ Diễn Nhiễm | Lan cổ độc vùng có giới hạn | poison, 0.95×, CD 12s, 3 mục tiêu, DoT 0.018/tick × 7s × 1 tầng | poison, 1.12×, CD 11.52s, 3 mục tiêu, DoT 0.0212/tick × 7.5s × 1 tầng | consume_poison, 1.23×, CD 11.52s, 3 mục tiêu | A: poison, 1.27×, CD 11.04s, 3 mục tiêu, DoT 0.0241/tick × 8s × 1 tầng; B: consume_poison, 1.40×, CD 11.04s, 3 mục tiêu |
| Vạn Cổ Phệ Giới | Đại vùng cổ trùng | poison, 1.60×, CD 38s, 3 mục tiêu, DoT 0.026/tick × 8s × 2 tầng | poison, 1.89×, CD 36.48s, 3 mục tiêu, DoT 0.0337/tick × 8.5s × 2 tầng | consume_poison, 2.08×, CD 36.48s, 3 mục tiêu | A: poison, 2.14×, CD 34.96s, 3 mục tiêu, DoT 0.0383/tick × 9s × 2 tầng; B: consume_poison, 2.36×, CD 34.96s, 3 mục tiêu |
| Ngự Cổ Thành Thạo | Độc tính cổ trùng | poison_factor=0.04 | poison_factor=0.0588 | poison_factor=0.056 | A: poison_factor=0.0756; B: poison_factor=0.072 |
| Cổ Vụ Hộ Mạch | Giảm sát thương nhận | guard_factor=0.98 | guard_factor=0.972 | guard_factor=0.972 | A: guard_factor=0.964; B: guard_factor=0.964 |
| Bách Túc Khai Vân | Chí mạng cổ thuật | crit_bonus=0.015 | crit_bonus=0.021 | crit_bonus=0.0223 | A: crit_bonus=0.027; B: crit_bonus=0.0286 |
| Cổ Vụ Trấn Tức | Phục hồi hồi chiêu cổ thuật | cooldown_recovery_factor=0.015 | cooldown_recovery_factor=0.021 | cooldown_recovery_factor=0.021 | A: cooldown_recovery_factor=0.027; B: cooldown_recovery_factor=0.027 |
| Cổ Nhận Tỉnh Táo | Sát thương cổ thuật | outgoing_factor=0.02 | outgoing_factor=0.028 | outgoing_factor=0.0308 | A: outgoing_factor=0.036; B: outgoing_factor=0.0396 |
| Cổ Ấn Liên Tâm | Ngự cổ bản mệnh | poison_factor=0.02; outgoing_factor=0.01 | poison_factor=0.0294; outgoing_factor=0.014 | poison_factor=0.028; outgoing_factor=0.0154 | A: poison_factor=0.0378; outgoing_factor=0.018; B: poison_factor=0.036; outgoing_factor=0.0198 |
| Tẩy Mạch Linh Dược | Dược châu đánh mục tiêu đơn | damage, 1.35×, CD 8s, 1 mục tiêu | damage, 1.59×, CD 7.68s, 1 mục tiêu | poison, 1.59×, CD 7.68s, 1 mục tiêu, DoT 0.0212/tick × 6s × 1 tầng | A: damage, 1.81×, CD 7.36s, 1 mục tiêu; B: poison, 1.81×, CD 7.36s, 1 mục tiêu, DoT 0.0241/tick × 7s × 1 tầng |
| Giải Độc Hộ Tâm | Hồi HP có ngân sách PvE | heal, 0.00×, CD 18s, 1 mục tiêu | heal, 0.00×, CD 17.28s, 1 mục tiêu | heal, 0.00×, CD 17.28s, 1 mục tiêu | A: heal, 0.00×, CD 16.56s, 1 mục tiêu; B: heal, 0.00×, CD 16.56s, 1 mục tiêu |
| Nghịch Độc Phản Chế | Giải trạng thái bất lợi có giới hạn | cleanse, 0.00×, CD 18s, 1 mục tiêu | cleanse, 0.00×, CD 17.28s, 1 mục tiêu | cleanse, 0.00×, CD 17.28s, 1 mục tiêu | A: cleanse, 0.00×, CD 16.56s, 1 mục tiêu; B: cleanse, 0.00×, CD 16.56s, 1 mục tiêu |
| Hóa Độc Tán | Bột dược phản độc đối thủ | poison, 0.86×, CD 13s, 3 mục tiêu, DoT 0.015/tick × 6s × 1 tầng | poison, 1.01×, CD 12.48s, 3 mục tiêu, DoT 0.0142/tick × 7.5s × 1 tầng | poison, 1.01×, CD 12.48s, 3 mục tiêu, DoT 0.0209/tick × 6.5s × 2 tầng | A: poison, 1.15×, CD 11.96s, 3 mục tiêu, DoT 0.0161/tick × 8s × 1 tầng; B: poison, 1.15×, CD 11.96s, 3 mục tiêu, DoT 0.0237/tick × 7s × 2 tầng |
| Vạn Linh Giải Ách | Đại trị liệu đồng đội có ngân sách | heal, 0.00×, CD 46s, 3 mục tiêu | heal, 0.00×, CD 44.16s, 3 mục tiêu | consume_poison, 1.53×, CD 44.16s, 3 mục tiêu | A: heal, 0.00×, CD 42.32s, 3 mục tiêu; B: consume_poison, 1.74×, CD 42.32s, 3 mục tiêu |
| Dược Mạch Vững Bền | Hiệu suất trị liệu | heal_factor=0.035 | heal_factor=0.0524 | heal_factor=0.049 | A: heal_factor=0.0674; B: heal_factor=0.063 |
| Thanh Độc Hộ Thân | Giảm sát thương nhận | guard_factor=0.98 | guard_factor=0.972 | guard_factor=0.972 | A: guard_factor=0.964; B: guard_factor=0.964 |
| Tẩy Tủy | Phục hồi hồi chiêu dược thuật | cooldown_recovery_factor=0.015 | cooldown_recovery_factor=0.021 | cooldown_recovery_factor=0.021 | A: cooldown_recovery_factor=0.027; B: cooldown_recovery_factor=0.027 |
| Dược Mạch Hồi Lưu | Tốc độ thi triển | cast_speed_factor=0.015 | cast_speed_factor=0.021 | cast_speed_factor=0.021 | A: cast_speed_factor=0.027; B: cast_speed_factor=0.027 |
| Sinh Cơ Khiên | Sát thương tự vệ | outgoing_factor=0.02 | outgoing_factor=0.028 | outgoing_factor=0.0308 | A: outgoing_factor=0.036; B: outgoing_factor=0.0396 |
| Độc Dược Đồng Nguyên | Thiên phú dược độc | heal_factor=0.025; cooldown_recovery_factor=0.01 | heal_factor=0.0375; cooldown_recovery_factor=0.014 | heal_factor=0.035; cooldown_recovery_factor=0.014 | A: heal_factor=0.0481; cooldown_recovery_factor=0.018; B: heal_factor=0.045; cooldown_recovery_factor=0.018 |

## 4. Đối soát paper proxy 21 profile (KHÔNG PHẢI DPS THẬT)

Đây là **chỉ số cơ hội tấn công chuẩn hóa theo ATK/giây**: basic/actual-CD + Σ[(direct + 65% of unopposed DoT potential + assumed consume opportunity)/CD] × outgoing_modifier; mục tiêu 1 và 3. **Không mô phỏng Godot**, chưa tính cast lock/travel/AI/crit/DEF/resist/dồn tầng giữa nhiều caster; chưa tính lợi ích marks trong damage, và chưa tính giá trị trị liệu. Với Hiếm, 4 active + basic + passive/innate **kế thừa từ Thần**, chỉ thay tuyệt kỹ và passive05 hiếm.

| Nhánh — thế hệ | A (1 mục tiêu / 3 mục tiêu) | B (1 mục tiêu / 3 mục tiêu) |
|---|---:|---:|
| doc_cham — Nhân | 1.187 / 1.668 | — |
| doc_cham — Tiên | 1.507 / 2.118 | 1.548 / 2.214 |
| doc_cham — Thần | 1.817 / 2.557 | 1.856 / 2.645 |
| doc_cham — Thần hiếm | 1.863 / 2.650 | 1.903 / 2.737 |
| co_doc — Nhân | 1.102 / 1.544 | — |
| co_doc — Tiên | 1.394 / 1.954 | 1.405 / 1.992 |
| co_doc — Thần | 1.682 / 2.361 | 1.688 / 2.383 |
| co_doc — Thần hiếm | 1.723 / 2.441 | 1.728 / 2.462 |
| duoc_doc — Nhân | 0.882 / 1.026 | — |
| duoc_doc — Tiên | 1.090 / 1.269 | 1.155 / 1.435 |
| duoc_doc — Thần | 1.306 / 1.520 | 1.387 / 1.723 |
| duoc_doc — Thần hiếm | 1.326 / 1.544 | 1.417 / 1.775 |

Mục tiêu nghiệm thu theo nhân vật đồng cảnh, cùng ATK/DEF:
- Boss một mục tiêu: Độc Châm = 100% offense; Cổ Độc 85–105%; Dược Độc 65–85% cộng thêm đóng góp heal/cleanse; A/B trong một nhánh phải có tradeoff cụ thể, không ưu thế mọi tình huống.
- Quái vùng, nhóm 3 mục tiêu thực sự gần nhau: Cổ Độc 90–110% Độc Châm; Dược Độc 55–85% Độc Châm, **đổi lại** hiệu quả chống hao HP.
- Tiên/Thần cùng bộ đồ, cùng ATK chuẩn hóa có thể tăng khoảng 15–40% qua tính năng, còn tổng sức mạnh do base stat tu luyện dẫn dắt. Boss 6 người không được bị đơn độc heal vô hạn.
- **Không gọi các ngưỡng này PASS** nếu chưa chạy exact-SHA Godot 4.7.2 + PvE thật và 6/12/18 kills/h.

## 5. Công thức kinh tế PvE r1/r2 phải bảo vệ

Nguồn `docs/design/PVE_BAL01_ECONOMY_COMBAT_MASTER_20261110.md`: Tu Vi thụ động 1.000/phút kể cả đi săn; EXP kill nhận thêm. Scenario nguồn dùng 12 kills/h, r1 mất 216 HP/h, r2 mất 288 HP/h; **đây là giả định cân bằng, không phải kết quả gameplay GUI**.

| Kịch bản r1/r2 12 kills/h | r1 | r2 |
|---|---:|---:|
| Tu Vi thụ động/h | 60.000 | 60.000 |
| HP mất/h (giả định) | 216 | 288 |
| Trần hồi Dược trong 1h nếu damage rải đều, 35% | 75,6 | 100,8 |
| HP vẫn phải được bù từ Đan/dịch vụ/cách khác | 140,4 | 187,2 |
| Trần caster AoE / độc | 3 mục tiêu/cast | 3 mục tiêu/cast |

**Chi phí:** Không trừ linh thạch hai lần nếu viên Đan đã tiêu từ Kho; phí dịch vụ HP tại Tông Môn là chuyển tiền, không tự đốt vào hư không; thương cơ/Injury là cơ chế riêng, không được chữa miễn phí bằng kỹ năng hồi HP. Một đệ tử chỉ có một active job, không vừa làm mỏ vừa săn. Giết quái nhận biên bản thưởng đúng một lần theo thế hệ respawn.

## 6. VFX architecture: không vẽ lại 183 sprite

- 17 action/mobility hình thái Nhân gốc, 18 passive+innate chỉ icon/proc khi cần. Tiên/Thần dùng cùng `family_id` và vật liệu/master gốc, thêm lớp A/B, cấp tu luyện; hoàn toàn không cần 183 file VFX độc lập.
- VFX từ `skill_cast`, `skill_release`, `v63_skill_hit`, `status_tick`, heal/cleanse/mark/consume **đã commit trong battle**, không vẽ fake AoE damage.
- Rendering 1280×720, 1× và 4v8, giới hạn particles/cues, không làm liên tục reset hit animation bằng mọi DoT tick. Boss có telegraph đủ rõ, 3 target cap đúng sự thật.
- Không kết luận PASS cho Test Lab chỉ vì có key VFX hoặc art brief.

## 7. QA/triển khai cổng sau khi owner phê duyệt — KHÔNG CODE TRONG PACKET NÀY

1. Cổng D0: 183/183 IDs, 35 families, 100% parent hợp lệ, gắn 6 rare passive thiếu; không đổi ID trong Save; kiểm tra trùng tên = 0 trong tên UI.
2. D1: so sánh loại, damage/DoT direct, CD/AI, 5 tầng độc theo owner, 30 tầng tổng, 3 target và đúng tiền/nguyên liệu tiêu hao; unit tests deterministic cho 183 IDs + 21 profile.
3. D2: học/tiến hóa cần predecessor hoặc mapping tương thích nhân vật cũ, archive/manual auth đúng, một nhánh A/B trang bị, cold Save/Reload không mất mastery/không unlock trùng.
4. D3: PVE solo/3/6/30 hunter, 1/3 target/Elite/Boss, 6/12/18 kill/h, theo dõi effective DPS, HPS, HP/pill/linh thạch, DoT kill receipt, Injury và 1.000EXP/phút thụ động.
5. D4: VFX/HUD 4v8 1280×720, tính FPS/RAM Windows Android, clip đủ hình thái A/B, Tiên/Thần không che mục tiêu. Chỉ mở runtime với exact SHA và PASS thật.

**Status cuối packet:** 183 ứng viên đầy đủ ở catalogue design-only, 35 dòng nguồn, không sửa runtime/Save hoặc merge. Các giá trị vẫn CANDIDATE cho đến khi owner khóa và Godot QA.

## 8. Phân biệt số gameplay và bộ trường tương thích kiểm tra dữ liệu

Các kỹ năng hỗ trợ / thân pháp / bị động có `ratio=0` trong **mô hình sát thương** vì không tự gây damage. Tuy nhiên, bộ kiểm tra `V63HumanSkillCombatSystem.validate_catalogue` hiện bắt `damage_ratio>0`, `cooldown>0`, `range>0`, `target_limit≥1` với tất cả loại slot. Vì vậy bảng dữ liệu bổ sung `runtime_compat_damage_ratio`, `runtime_compat_cooldown_sec`, `runtime_compat_range_cells`, `runtime_compat_target_limit`. Với kỹ năng không gây damage, `runtime_compat_damage_ratio=0.05` chỉ là **placeholder schema**, tuyệt đối không tính như một hit. Đây là chỉ dẫn cho lần code về sau; không import trực tiếp candidate JSON vào Godot.

Một đổi tên có chủ đích: `Sinh Cơ Tán` (ID hiện tại `duoc_doc.active_04`) thành `Hóa Độc Tán` trong thiết kế tương lai vì chức năng đề xuất là tấn công bằng bột phản độc, khác hoàn toàn `Nghịch Độc Phản Chế` vốn phụ trách thanh tẩy. ID vẫn giữ nguyên để Save còn dùng được.

**QA máy đọc trên dữ liệu ứng viên:** 183 unique ID, 35 unique families, 183 tên hiển thị riêng, tất cả hậu duệ có `parent`, giới hạn runtime-compatible được thỏa mãn (với các trường tương thích), 36 thay đổi effect so với source hiện hành phải được review riêng. Đây không phải Godot QA.

## 9. Chi tiết 7 luật Thần — giải quyết 26 DESIGN_PENDING ở mức thiết kế

Có 80 node Thần: 2 successor_action và 6 nhóm khác ×13 node. Hai nhóm single_spread_poison (13) và removed_debuff_counter (13) hiện vẫn cần triển khai code riêng. Công thức và giới hạn dưới đây thuộc **DESIGN_CANDIDATE**, không có nghĩa runtime đã áp dụng.

| Rule ID | Số ID | Điều kiện kích hoạt | Cơ chế đề xuất, có trần | ICD |
|---|---:|---|---|---:|
| successor_action | 2 | derived basic/mobility generation; no additional cast | previous family successor replaces old; Divine stage I/II/III direct ratio ×1.00/1.12/1.24; no extra hit | 0s |
| owned_poison_maintain | 13 | real poison cast while own stacks already at five | refresh lifetime of ONE oldest own stack to min(10s, skill.duration), not create sixth; ≤1 refresh/cast; no extra damage event | 0s |
| owned_poison_consume | 13 | real consume_poison cast on owned stacks only | S≤5; R=sum(remaining own DoT tick ratios); extra ATK ratio min(.60,.08*S+.40*R); erase only same-owner stacks; 1 settlement/cast/target | 0s |
| single_spread_poison | 13 | one committed Divine poison application to a primary enemy | ≤1 secondary hostile at radius≤2.5; 1 spread stack at 65% source tick ratio, remaining life≤5s, no new direct hit/chain, caster-target cap5/total cap30; source attribution exact | 6s |
| marked_target_punish | 13 | first real non-DoT damage by owner on own valid mark | consume 1 own mark; +0.12 ATK direct after verified hit, no crit/lifesteal/proc; caster-target ICD8s; no duplicate mark multiplier | 8s |
| cleanse_heal_fatal_save | 13 | cleanse event with genuine removed_debuff_count≥1, plus separate rare passive protect | extra heal ≤3% target MaxHP subject shared rolling10m budget, target ICD12s; rare passive self-lethal-save HP=1 once90s when truly equipped, no Injury removal | 12s |
| removed_debuff_counter | 13 | verified cleanse removed≥1 real debuff then next owner offensive cast within 5s | one primary hostile +0.08 ATK direct, caster ICD12s; zero extra DoT stacks, no crit/lifesteal/proc; never triggers from empty cleanse/reload duplication | 12s |

**Hệ số Thần giai:** ở mốc cảnh giới 21/25/29, code release_cast dùng ×1,00/1,12/1,24 cho **direct ratio**; tuyệt đối không nhân tần suất DoT tick và không cộng thêm tick. Paper proxy ở mục 4 là Thần giai I, chưa tính II/III.

**Oracle:** 2 tầng độc cùng chủ, còn 4 tick ×0,03 ATK/tầng: R=0,24; bonus=min(0,60;0,08×2+0,40×0,24)=0,256 ATK. 5 tầng, còn 8 tick ×0,03: R=1,20; bonus=min(0,60;0,40+0,48)=0,60 ATK. Nếu caster A có 3 tầng và B có 2 tầng trên một Boss, A kích nổ chỉ xóa 3 tầng của A. Nếu mục tiêu phụ ở cách tâm 2,4 ô, tối đa một tầng lan; ở 2,6 ô không được lan. Thanh tẩy xóa 0 trạng thái thì phản công phải 0. Cửa sổ 10 phút r1 có 36 HP sát thương thực, MaxHP=190: hồi kỹ năng tối đa min(22,8;12,6)=12,6 HP.

Để triển khai đúng cần event authority cho sát thương gần đây, last-trigger/ICD theo caster–target, gói status spread không tạo hit giả, trạng thái counter và cold Save/Reload. Không dùng tài liệu ứng viên làm dữ liệu runtime khi chưa duyệt.
