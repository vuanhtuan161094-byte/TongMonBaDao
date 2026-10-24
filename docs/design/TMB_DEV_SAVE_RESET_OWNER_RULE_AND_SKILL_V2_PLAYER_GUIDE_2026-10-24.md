# TÔNG MÔN BÁ ĐẠO — LUẬT RESET DEV SAVE VÀ HƯỚNG DẪN HỆ KỸ NĂNG V2
Ngày 2026-10-24 · Owner override & explanatory contract · Docs-only, NO CODE, NO MERGE, NO UI/PR29 edits.

## A. Quyết định owner — RESET SAVE DEV MỖI ĐỢT ĐỔI GAMEPLAY

Chủ dự án xác nhận: “xóa hết đệ tử save cũ. đây là luật. game ở trạng thái phát triển. mỗi lần sửa đổi j thì tạo lại từ đầu cả. k phải save gì.”

**USER-LOCKED POLICY:** trong quá trình phát triển, mỗi bản sửa gameplay/logic hoặc bản test tích hợp mới được kiểm tra bằng world/đệ tử/dữ liệu DEV sinh mới; không cần duy trì tương thích nhân vật/save P2 cũ sang V2, không code hệ migration root legacy riêng. Các docs migration I1 đã viết trước là nghiên cứu lịch sử và đã bị quyết định này SUPERSEDE ở phạm vi dữ liệu chơi thử; không dùng làm blocker. Thay đổi văn bản thuần túy không cần xóa world.

**IMPORTANT DISTINCTION:** save/load và offline **trong cùng bản chạy** phải đúng, loot/kho/injury/XP/kill exactly-once, actor mid-cast restore nếu có, deterministic recruit và one active job vẫn là authority. “Không migrate save cũ” KHÔNG nghĩa xóa SaveService hoặc không test save.

**Destructive scope guard:** hiện chỉ chốt LUẬT, CHƯA chạy xóa file trên máy người dùng. Khi owner cho phép launcher/test reset, chỉ được xóa đúng thư mục user-data riêng biệt của Tông Môn Bá Đạo trong môi trường DEV sau khi kiểm tra path/preview; không đụng source/asset/Git/PR recovery, files khác hay bản phát hành sau này. Không tự chạy lệnh xóa rộng.

Current source anchors: main 29b5fba448b0178cb520a4ada44b375b4b934e31; PR27 D7 deeae081bcfbe1413d4cf60a29db7e58150888b5; PR29 S1 9522812e91b7ca5bc0cc108eb92e000e930fe850 (CODE, official Godot QA PENDING).

## B. Một đệ tử có hai phần: BIẾT SKILL và TRANG BỊ SKILL

Danh sách các kỹ năng đã học thuộc đệ tử; loadout chỉ gồm một số chiêu được trang bị. Học công pháp không tự nhận đầy đủ kỹ năng; công pháp và kỹ năng có quan hệ độc lập, cộng hưởng theo tag, hoặc tiên quyết có khai báo riêng.

### 1. Các Ô trang bị — quyết định đã khóa
| Loại | Tối đa ở giai đoạn trưởng thành | Ý nghĩa |
|---|---:|---|
| Thường Kỹ | 1 | Đòn đánh cơ bản, tự động giữa các chiêu |
| Chủ Động | 4 | Chiêu đánh, AoE, buff/debuff, hồi, hộ thể, lao tới... dùng theo điều kiện và cooldown |
| Bị Động Chiến Đấu | 6 | Trigger, phản đòn, proc, buff nhóm/aura, có cooldown nội bộ khi cần |
| Nội tại tĩnh | Không chiếm 6 ô trên | Modifier chỉ số tự thân, không có event/trigger/party scope |

11 slot mở dần trong Nhân Giới (cảnh giới1–10), KHÔNG sẵn ở lúc tuyển. Cảnh giới/tầng mở từng ô chưa chốt. Không được trang bị hơn4 active dù sở hữu nhiều sách.

### 2. Nhóm TÁC DỤNG — đây là thuộc tính của skill, không phải bộ slot riêng

1. Đánh đơn: kiếm, quyền, phi kiếm/pháp thuật projectile, penetration, execute.
2. Đánh diện rộng: hình quạt, thẳng hàng, vòng tròn, dây chuyền, vùng duy trì; mỗi skill có max_targets, radius/range/shape, target order riêng.
3. Trạng thái gây hại: đốt/DoT, yếu hóa, phá giáp, giảm tốc, khống chế/hàn ấn, giảm hồi phục.
4. Bảo vệ và hỗ trợ: tăng ATK/DEF, buff team, hộ thể, shield, heal, cleanse, dispel, cứu nguy.
5. Cơ động và phản ứng: Truy Phong Bộ lao tới, phản đòn, phản chấn, né/tránh vùng nếu sau này có consumer.
6. Kỹ năng kết hợp: Hỏa Cầu trực tiếp+đốt, Chấn Sơn Quyền trực tiếp+suy yếu, Liệt Diễm payoff khi còn đốt; combo Tương Sinh chỉ khi skill khai báo.
Một skill có thể thuộc nhiều tác dụng cùng lúc. Không tặng AoE cho một skill hiện chỉ khai báo mục tiêu đơn.

### 3. Hướng Kiếm / Thể / Pháp, mỗi hướng ba nhánh thiết kế
| Hướng | Nhánh | Ví dụ khả năng |
|---|---|---|
| Kiếm | Ngự Kiếm / Sát Kiếm / Hộ Kiếm | phi kiếm tầm xa, boss burst, counter/bảo vệ |
| Thể | Bá Thể / Kim Cương / Huyết Thể | quyền mạnh/đánh vùng, đỡ đòn+threat, liều mạng hồi phục |
| Pháp | Ngũ Hành / Y Đạo / Huyền Pháp | hỏa/thủy/tương sinh, hồi máu+giải hiệu ứng, khống chế/giải buff |

Ngũ hành không phải nghề: Kiếm hệ Hỏa vẫn là Kiếm, Pháp hệ Kim vẫn là Pháp. Định Đạo là danh tính hướng và điều kiện theo từng kỹ năng; không có quy tắc cấm mọi kỹ năng khác hành trên tất cả đệ tử.

### 4. Phẩm chất vs Thành Thạo vs Thế Hệ — KHÁC NHAU
- Phẩm cấp ứng viên: **Phàm, Huyền, Địa, Thiên, Tiên, Thần**, phản ánh độ hiếm/chiều sâu skill; không cố định Phàm=Luyện Khí.
- Lĩnh ngộ cá nhân, **5 bậc**: **Sơ Học → Nhập Môn → Tiểu Thành → Đại Thành → Viên Mãn**. EXP từ hành động có đóng góp thật hoặc Diễn Võ hợp lệ, không spam thi triển; Thông Tuệ và linh căn phù hợp cộng tốc học. Không có quy tắc chung “mỗi cấp +5%”.
- **Ba thế hệ Nhân 1–10 → Tiên 11–20 → Thần 21–30**: skill cùng họ có hậu duệ/tên mới, có thể mở AoE/nhiều đòn/khống chế cao cấp, độc quyền nhánh; khác với thăng hạng phẩm chất.
- Kỹ năng có cơ sở tăng trưởng Tu Vi, Luyện Thể hoặc Hybrid riêng theo definition; 30×10 là điều kiện học/tăng bậc, không tự tặng skill. Các chỉ số theo 16 kênh CombatStats, không thêm resource Mana chung.

### 5. Một lần chiến đấu tự động diễn ra thế nào?
AI của V2 đã khóa dùng **4 ô chủ động theo thứ tự**: xét ô1 hợp lệ (đủ học/đã trang bị, tầm, mục tiêu, CD, điều kiện riêng) thì thi triển; không thì xét ô2→3→4; không có skill hợp lệ thì thường kỹ/di chuyển. Skill cooldown/cast/projectile tách biệt; một hành động chủ động tại một thời điểm; save/combat status theo MapBattleV2 duy nhất. Không tạo AI toàn cục tự xếp lại slot nếu owner chưa duyệt.

Ví dụ mature Fire Mage có thể dùng:
- basic: Linh Khí Đạn (nội dung V2, chưa code vào P2 live).
- slot1: Hộ Mệnh Thuật (hợp lệ khi đồng đội bị đe dọa, nội dung V2 chưa live).
- slot2: Hỏa Cầu (đặt hiệu ứng Burn có giá trị, condition chưa hoàn thiện).
- slot3: Liệt Diễm (hệ số bonus khi Burn còn ở thời điểm trúng, S2 chưa code).
- slot4: Hàn Sương Ấn (làm suy yếu nếu mục tiêu chưa có hiệu ứng tốt hơn, S1 code QA pending).
- passive trigger: Pháp Thuẫn Tự Hộ (catalogue chưa live) và các passive khác chỉ khi học hợp lệ.
Đây là loadout ở giai đoạn đủ ô, KHÔNG phải đệ tử Phàm tầng1 tự có đầy đủ.

### 6. Học kỹ năng ở đâu?
Hạ quái thường/Tinh Anh/Boss, khám phá Bí Cảnh, nhận manual hoặc mảnh, Tàng Kinh Các truyền thừa một lần; đệ tử tự lĩnh ngộ theo điều kiện hoặc học từ truyền thừa hợp lệ; kiểm tra TuVi/Body/Đạo/Công Pháp/nguồn/cost/time, rồi lưu học và XP riêng người. Học skill rồi có thể trang bị/đổi ngoài combat. Không dùng kill để tặng TuVi XP giả.

## C. Đã có gì trong CODE — đúng 9 kỹ năng mẫu P2, KHÔNG phải toàn bộ catalogue

| Hướng | Skill authored | Hệ số damage xATK | Đường chạy trên PR29 |
|---|---|---:|---|
| Kiếm | Thanh Phong Trảm | 1.35 | damage live |
| Kiếm | Truy Phong Bộ | 0.75 + dash | S2 deferred |
| Kiếm | Ngự Kiếm Thuật | 1.70 | damage live |
| Thể | Chấn Sơn Quyền | 1.45 + weaken | S1 code QA pending |
| Thể | Kim Cương Hộ Thể | 0 + guard | S1 code QA pending |
| Thể | Bất Động Thân | 0 + guard | S1 code QA pending |
| Pháp | Hỏa Cầu | 1.15 + Burn | S1 code QA pending |
| Pháp | Hàn Sương Ấn | 0.90 + weaken | S1 code QA pending |
| Pháp | Liệt Diễm | 1.45; 1.35 combo bonus | S2 deferred |

Legacy generic role Healer/Guard/Mage AoE is **not** equivalent to all learned skills being active. P2 learned skills are learned true/false, NO individual skill mastery XP/5-bậc yet. P2 can_learn references old cultivation_stage_index, NOT V2 30x10. The V2 full four-active/six-passive loadout is DESIGN LOCKED, NOT IMPLEMENTED in MapBattle.

**Mismatch to resolve later by owner:** Combat Skills V2 long-form refers to evolved Liệt Diễm as “Hỏa AoE/payoff”, while P2 pilot ID uses single-target combo without AoE max target. S2 should not silently turn the existing 1-target P2 skill into AoE; can author a separate AoE successor in future or specifically approve pilot change.

**Scale proposed by canonical content plan, NOT code:** per hướng ~12–15 long-running skill families, ~40–60 active skill definitions plus ~20–30 passive definitions across Nhân/Tiên/Thần; many branches/versions, one disciple equips 4 active only. These are content-budget TARGETS, not number already owned by game or final numeric lock.

## D. Đề xuất tiến trình, không cần lặp kiểm toán vô hạn

1. Codex QA S1 PR29 riêng, không đụng UI.
2. Ghi owner reset rule vào future dev runner: new isolated DEV data per changed build; **CODE permission required** before launcher/file deletion. No legacy-save migration packet.
3. S2 after S1 PASS: Truy Phong Bộ, Liệt Diễm and canonical four-slot priority skeleton, plus minimal true learn/unlock.
4. Chọn một **vertical slice** mỗi hướng: 1 basic, 2 active, 1 trigger passive dùng được; thêm loot/manual và mastery real XP sau đó. Cần thấy đệ tử thực sự khác nhau trước khi làm đủ hàng trăm definitions.
5. Cân bằng mạnh sau một vòng chơi thật normal→elite→boss; chỉ focused tests sau mỗi effect packet, giữ đúng Save/CARE within build.

Owner options: (A) xem một đệ tử xuyên suốt 3 thế hệ; (B) thiết kế cấu trúc danh mục chiêu theo 9 nhánh, 4 ô active & 6 passive; (C) chuẩn bị dev reset launcher packet và gameplay skill schema, chỉ docs trừ khi duyệt CODE.
