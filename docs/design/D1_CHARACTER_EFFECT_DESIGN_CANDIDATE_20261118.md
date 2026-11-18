# D1 — THIẾT KẾ NHÂN VẬT: TÂM TÍNH, TÂM CẢNH VÀ 101 ĐẶC TÍNH

Ngày: 18/11/2026. Gói **D1 DESIGN CANDIDATE**. Tài liệu không khẳng định mã gameplay đã có, không sửa spec gốc hoặc sinh vật phẩm/hiệu ứng mới.

**Mốc thiết kế đã duyệt giữ nguyên:**
- Tam Căn/Tứ Tính 7 chỉ số; Tư Chất +0,25% EXP Tu Vi tự nhiên mỗi điểm; Căn Cốt +0,20% EXP Luyện Thể mỗi điểm; Thông Tuệ +0,15% kinh nghiệm lĩnh hội; Tiềm Lực +0,05% hệ số tiềm năng.
- 101 Đặc Chất V2 là một danh mục gốc, không có grade chung. Hệ 9 Trait cũ là adapter tách biệt, không được tự đưa vào 101 V2.
- Effect phải tác động lên **kết quả hành động có thật**, không chỉnh điểm Lục Duy lưu vĩnh viễn, không cộng kết quả hai lần và không tạo vật phẩm/buff miễn phí.
- 41 trường hợp có kênh thiết kế, 12 chờ consumer, 48 đề xuất mới chưa khóa. Tỷ lệ sinh thuộc authority riêng.

## 1. Tâm Tính — bản thiết kế có thể chốt, không tạo hệ XP thứ ba

**Vấn đề:** Tâm Tính hiện tăng tổng điểm phẩm chất nhân vật nhưng không có chức năng game độc lập. Không để người chơi đầu tư điểm vô nghĩa.

**Đề xuất D1-A (chưa được owner duyệt):**
1. Tâm Tính biểu thị định lực và ổn định tinh thần. Nó **không trực tiếp tăng EXP Tu Vi, EXP Luyện Thể, công/thủ/HP hay cơ hội đột phá**.
2. Khi kỹ năng có \`status_tag=mental\` hợp lệ gây hiệu ứng xấu: tăng **Kháng Hiệu Ứng riêng cho mental** bằng \`min(15, 0.02 × TamTinh)\` **điểm phần trăm**. Ví dụ 100 Tâm Tính → +2 điểm %, 500 → +10 điểm %. Giới hạn tổng xác suất cuối theo luật combat chung; không mở kháng mới cho các hệ kỹ năng không có tag.
3. Nếu hiệu ứng mental đã trúng và có thời lượng: rút ngắn thời gian chịu hiệu ứng theo \`min(20%, 0.025% × TamTinh)\`; ví dụ 100 điểm → 2,5% thời gian. Không áp cho stun/slow/dot không mang tag mental. Hạn chế này chỉ có tác dụng nếu combat đã có authority xử lý duration và source.
4. Khi không có combat mental consumer, **không tạo buff ảo**. UI ghi “hiệu ứng có thiết kế — đang chờ kỹ năng mental”. Không tăng hệ số TU VI/s để che thiếu.

**Tại sao:** Không chồng chức năng của Tư Chất/Căn Cốt/Thông Tuệ; vẫn hữu ích với builds kháng khống chế; dễ kiểm số học theo source event; không đụng tỷ lệ đột phá 25% + đan. Đây là **cặp hệ số ứng viên để duyệt**, không phải cân bằng được duyệt.

## 2. Tâm Cảnh — không bắt buộc thêm ngay

**Đề xuất D1-B (OPTIONAL, chưa được duyệt):**
- Sáu mốc **Phàm Tâm → Tĩnh Tâm → Định Tâm → Minh Tâm → Kiên Tâm → Đạo Tâm**; mỗi mốc mở hành vi tu tâm có điều kiện, không tạo 30×10 tầng.
- Tâm Tính là tiềm năng, Tâm Cảnh là thành tựu, Tâm Trạng là trạng thái tạm.
- Không tự động nhận Tâm Cảnh EXP/s, không cộng XP chỉ từ idle. Nguồn tăng: hoàn thành Tu Tâm Đường, vượt sự kiện tinh thần hợp lệ hoặc sử dụng vật phẩm tu tâm có nguồn thật.
- Chưa có nguồn Tu Tâm Đường/event thì **Tâm Cảnh dừng ở DESIGN CANDIDATE**, không in trên profile như hệ đã mở.
- Chỉ khóa mốc khi số liệu về thời gian, linh thạch, điều kiện trải nghiệm, hiệu lực chống hiệu ứng và cấp công trình được duyệt ở D2/D3.

**Quyết định khuyên chọn trong D1:** chốt tác dụng Tâm Tính D1-A trước; Tâm Cảnh D1-B để lại là phần mở rộng, không chặn 101 Trait.

## 3. Các luật thiết kế bắt buộc cho 101 đặc tính

1. **H / B / S:** hữu ích/bất lợi/song diện. Song diện phải có cùng một action pipeline hợp lệ cho **cả lợi ích và cái giá**; không được chỉ mở một vế.
2. **Học/lĩnh ngộ:** chỉ cộng EXP học *công pháp, mastery skill* với \`learn_completed\` được ghi; không tác động Tu Vi cố định từ đan và không nhân đôi XP.
3. **Tu Vi:** chỉ tác động \`natural_cultivation_gain\` và đúng điều kiện, không nhân đôi thưởng từ đan.
4. **Lao động:** phân biệt \`work_speed\` (giảm thời gian), \`profession_xp\` (tăng XP nghề), \`quality_check\` (một lần tại hoàn thành). Không biến work_speed thành nhân đôi sản lượng.
5. **Combat:** chỉ tác động stat/effect đã định nghĩa trong \`COMBAT_STATS_V2_SPEC.md\`; xác nhận người thi triển, mục tiêu, skill tag, thời gian, stack/source và cooldown.
6. **Hồi phục/hỗ trợ:** phân biệt heal done/received, shield done/received, injury recovery; phải có source heal/injury thực.
7. **Lối sống/quan hệ/viễn chinh:** chỉ bật khi scheduler/food/social/loot provenance có event thật; nếu thiếu không dùng random timer để giả mô phỏng.
8. **Xung đột:** bộ sinh không cho trait conflict đồng thời, hình thức hậu thiên phải xử lý conflict/removal theo luật V2 gốc.
9. **Migrate hệ cũ:** các ID tương tự như *Cẩu Thả* có hệ số ngược dấu thì ưu tiên thiết kế V2 sau chuyển đổi có giám sát, không chạy đồng thời modifier legacy và V2.
10. **Tính rõ ràng:** description cho game dùng một câu về tác động, một câu về điều kiện và một trạng thái \`Đã có dữ liệu / Đã có hiệu ứng V2 / Chờ consumer\`.

## 4. Ma trận thiết kế từng ID (đối chiếu toàn bộ 101)

Các con số trong cột “ý tưởng” là **giá trị đề xuất của spec gốc**, chưa được phê duyệt thành balance cuối. Cột consumer là đường cần thiết kế/viết mã về sau, không khẳng định đã chạy.

| # | Đặc chất | Mức thiết kế | Tác dụng theo tài liệu | Nơi cần có consumer | Trạng thái triển khai |
|---:|---|---|---|---|---|
| 1 | Ham Học | CÓ KÊNH | Tăng 10% kinh nghiệm học công pháp và thành thạo kỹ năng hợp lệ | XP học Công Pháp/Kỹ Năng, focus subject và learning event | Chưa có consumer V2 được chứng minh |
| 2 | Nhất Tâm | CÓ KÊNH | Tăng 15% EXP thành thạo khi chỉ học một môn; đổi môn sẽ xóa tích lũy tập trung | XP học Công Pháp/Kỹ Năng, focus subject và learning event | Chưa có consumer V2 được chứng minh |
| 3 | Trí Nhớ Sâu | THIẾU PHỤ THUỘC | Tăng 8% EXP thành thạo; cơ chế giảm quên chưa được phép dùng khi chưa có hệ quên kỹ năng | XP học Công Pháp/Kỹ Năng, focus subject và learning event | Chưa có consumer V2 được chứng minh |
| 4 | Suy Diễn | CÓ KÊNH | Tăng 15% EXP thành thạo công pháp; giảm 8% tốc độ công việc thường | XP học Công Pháp/Kỹ Năng, focus subject và learning event | Chưa có consumer V2 được chứng minh |
| 5 | Học Nhanh Làm Ẩu | CÓ KÊNH | Tăng 15% EXP nghề; tăng 500 điểm độ khó khi kiểm tra chất lượng/đồ hiếm | XP học Công Pháp/Kỹ Năng, focus subject và learning event | Chưa có consumer V2 được chứng minh |
| 6 | Chậm Mà Chắc | THIẾU PHỤ THUỘC | Giảm 8% EXP học; lợi ích ở mốc thành thạo chưa được thiết kế xong | XP học Công Pháp/Kỹ Năng, focus subject và learning event | Chưa có consumer V2 được chứng minh |
| 7 | Tạp Niệm | CÓ KÊNH | Giảm 10% EXP thành thạo công pháp/kỹ năng | XP học Công Pháp/Kỹ Năng, focus subject và learning event | Chưa có consumer V2 được chứng minh |
| 8 | Khó Tiếp Thu | CÓ KÊNH | Giảm 12% EXP học công pháp/kỹ năng | XP học Công Pháp/Kỹ Năng, focus subject và learning event | Chưa có consumer V2 được chứng minh |
| 9 | Kinh Mạch Ổn Định | CÓ KÊNH | Tăng 10% Tu Vi tự nhiên | Cultivation gain + Breakthrough V2 | Mâu thuẫn legacy: V2 Kinh Mạch Ổn Định dự kiến +10%; lệch 2 điểm % |
| 10 | Kinh Mạch Mong Manh | CÓ KÊNH | Giảm 10% Tu Vi tự nhiên | Cultivation gain + Breakthrough V2 | Mâu thuẫn legacy: Gần ý nghĩa Kinh Mạch Mong Manh V2 (−10%) nhưng khác ID |
| 11 | Ngộ Tĩnh | CÓ KÊNH | Tăng 8% Tu Vi tự nhiên và 10% EXP thành thạo công pháp/kỹ năng | Cultivation gain + Breakthrough V2 | Mâu thuẫn legacy: V2 thiết kế +8% Tu Vi và +10% EXP thành thạo |
| 12 | Tâm Tĩnh Như Thủy | THIẾU PHỤ THUỘC | Tăng 8% Tu Vi nếu không có thương tích nặng hoặc rối loạn tinh thần | Cultivation gain + Breakthrough V2 | Chưa có consumer V2 được chứng minh |
| 13 | Nóng Vội Cầu Thành | THIẾU PHỤ THUỘC | Tăng 12% Tu Vi; bất lợi khi đột phá chưa được hoàn thiện | Cultivation gain + Breakthrough V2 | Chưa có consumer V2 được chứng minh |
| 14 | Cần Mẫn | CÓ KÊNH | Tăng 10% tốc độ làm việc chung | Work duration/XP/quality/material, context work | Mâu thuẫn legacy: V2 dự kiến +10% cố định, bỏ cấp đặc tính thường |
| 15 | Cuồng Công | THIẾU PHỤ THUỘC | Tăng 15% tốc độ làm việc; chưa chốt bất lợi/tiêu hao phù hợp | Work duration/XP/quality/material, context work | Chưa có consumer V2 được chứng minh |
| 16 | Lười Nhác | CÓ KÊNH | Giảm 12% tốc độ làm việc chung | Work duration/XP/quality/material, context work | Chưa có consumer V2 được chứng minh |
| 17 | Cẩu Thả | CÓ KÊNH | Tăng 10% tốc độ làm việc nhưng tăng 800 điểm độ khó khi kiểm tra chất lượng/đồ hiếm | Work duration/XP/quality/material, context work | Mâu thuẫn legacy: V2 thiết kế +10% tốc độ kèm bất lợi chất lượng; khác dấu! |
| 18 | Tỉ Mỉ | CÓ KÊNH | Giảm 5% tốc độ làm việc nhưng giảm 600 điểm độ khó khi kiểm tra chất lượng/đồ hiếm | Work duration/XP/quality/material, context work | Chưa có consumer V2 được chứng minh |
| 19 | Tiết Liệu | THIẾU PHỤ THUỘC | Tiết kiệm vật liệu; chưa có công thức làm tròn và lượng tiết kiệm được duyệt | Work duration/XP/quality/material, context work | Chưa có consumer V2 được chứng minh |
| 20 | Phung Phí | THIẾU PHỤ THUỘC | Tăng 8% EXP nghề; tác hại hao vật liệu chưa có công thức được duyệt | Work duration/XP/quality/material, context work | Chưa có consumer V2 được chứng minh |
| 21 | Đa Nhiệm | THIẾU PHỤ THUỘC | Tăng 8% tốc độ làm việc ở nghề có nhiều công đoạn hợp lệ | Work duration/XP/quality/material, context work | Chưa có consumer V2 được chứng minh |
| 22 | Quen Tay | CÓ KÊNH | Tăng 10% EXP của nghề đang ở cấp cao nhất | Work duration/XP/quality/material, context work | Chưa có consumer V2 được chứng minh |
| 23 | Đổi Nghề Khó | CÓ KÊNH | Giảm 15% EXP khi làm nghề có cấp thấp hơn nghề cao nhất của bản thân | Work duration/XP/quality/material, context work | Chưa có consumer V2 được chứng minh |
| 24 | Bản Năng Chiến Đấu | CÓ KÊNH | Tăng 5 điểm phần trăm tỷ lệ chí mạng; tăng 10% EXP thành thạo kỹ năng chiến đấu | Combat Stats V2 + context combat/kill/sinh mệnh | Mâu thuẫn legacy: V2 thiết kế +5 điểm % chí mạng và +10% EXP thành thạo |
| 25 | Linh Giác Sắc Bén | CÓ KÊNH | Tăng 10 điểm phần trăm tỷ lệ gây hiệu ứng | Combat Stats V2 + context combat/kill/sinh mệnh | Chưa có consumer V2 được chứng minh |
| 26 | Tâm Thần Kiên Cố | CÓ KÊNH | Tăng 10 điểm phần trăm kháng hiệu ứng | Combat Stats V2 + context combat/kill/sinh mệnh | Chưa có consumer V2 được chứng minh |
| 27 | Phá Giáp Cảm | CÓ KÊNH | Tăng 5% xuyên phòng ngự | Combat Stats V2 + context combat/kill/sinh mệnh | Chưa có consumer V2 được chứng minh |
| 28 | Hấp Tấp | CÓ KÊNH | Tăng 10% tốc độ tung chiêu, giảm 10 điểm phần trăm tỷ lệ gây hiệu ứng | Combat Stats V2 + context combat/kill/sinh mệnh | Chưa có consumer V2 được chứng minh |
| 29 | Huyết Chiến | CÓ KÊNH | Tăng 12% sát thương, giảm 20% khả năng nhận hồi máu | Combat Stats V2 + context combat/kill/sinh mệnh | Chưa có consumer V2 được chứng minh |
| 30 | Bất Khuất | CÓ KÊNH | Khi HP dưới 30%: giảm 10% sát thương nhận vào | Combat Stats V2 + context combat/kill/sinh mệnh | Chưa có consumer V2 được chứng minh |
| 31 | Tâm Thần Bất Ổn | CÓ KÊNH | Giảm 10 điểm phần trăm kháng hiệu ứng | Combat Stats V2 + context combat/kill/sinh mệnh | Chưa có consumer V2 được chứng minh |
| 32 | Trì Trọng | CÓ KÊNH | Giảm 10% tốc độ di chuyển; tăng 10 điểm phần trăm kháng hiệu ứng và giảm 5% sát thương nhận vào | Combat Stats V2 + context combat/kill/sinh mệnh | Chưa có consumer V2 được chứng minh |
| 33 | Thân Pháp Nhẹ Nhàng | CÓ KÊNH | Tăng 10% tốc độ di chuyển | Combat Stats V2 + context combat/kill/sinh mệnh | Chưa có consumer V2 được chứng minh |
| 34 | Phản Ứng Nhanh | CÓ KÊNH | Tăng 8% tốc độ đánh và 5% tốc độ tung chiêu | Combat Stats V2 + context combat/kill/sinh mệnh | Chưa có consumer V2 được chứng minh |
| 35 | Lão Luyện | CÓ KÊNH | Tăng 8 điểm phần trăm kháng chí mạng | Combat Stats V2 + context combat/kill/sinh mệnh | Chưa có consumer V2 được chứng minh |
| 36 | Liều Mạng | CÓ KÊNH | Tăng 10% sát thương gây ra nhưng nhận thêm 8% sát thương | Combat Stats V2 + context combat/kill/sinh mệnh | Chưa có consumer V2 được chứng minh |
| 37 | Thừa Thắng Truy Kích | CÓ KÊNH | Sau khi tự kết liễu địch: tăng 8% tốc độ di chuyển và đánh trong 5 giây; không cộng dồn | Combat Stats V2 + context combat/kill/sinh mệnh | Chưa có consumer V2 được chứng minh |
| 38 | Ổn Trận | CÓ KÊNH | Khi HP từ 70%: tăng 8 điểm phần trăm kháng hiệu ứng | Combat Stats V2 + context combat/kill/sinh mệnh | Chưa có consumer V2 được chứng minh |
| 39 | Dược Tâm | CÓ KÊNH | Tăng 15% hiệu quả trị liệu thực hiện | Healing/Shield/Injury treatment V2 | Chưa có consumer V2 được chứng minh |
| 40 | Hộ Tâm | CÓ KÊNH | Tăng 15% hiệu quả tạo khiên | Healing/Shield/Injury treatment V2 | Chưa có consumer V2 được chứng minh |
| 41 | Hồi Nguyên | THIẾU PHỤ THUỘC | Tăng 15% hồi máu nhận vào; tăng 10% tốc độ hồi phục chấn thương | Healing/Shield/Injury treatment V2 | Chưa có consumer V2 được chứng minh |
| 42 | Khí Huyết Khó Hợp | CÓ KÊNH | Giảm 15% hồi máu nhận vào | Healing/Shield/Injury treatment V2 | Chưa có consumer V2 được chứng minh |
| 43 | Dược Lý Thông Thạo | THIẾU PHỤ THUỘC | Tăng 10% hiệu quả trị liệu và 10% EXP nghề y/dược khi nghề đó có thực | Healing/Shield/Injury treatment V2 | Chưa có consumer V2 được chứng minh |
| 44 | Thương Binh Kinh Nghiệm | THIẾU PHỤ THUỘC | Tăng 15% hồi phục chấn thương; ưu tiên chữa trị đồng đội bị thương hơn | Healing/Shield/Injury treatment V2 | Chưa có consumer V2 được chứng minh |
| 45 | Cứng Đầu | THIẾU PHỤ THUỘC | Khi đang bị thương: giảm 8% sát thương nhận; giảm 15% hồi máu nhận vào | Healing/Shield/Injury treatment V2 | Chưa có consumer V2 được chứng minh |
| 46 | Hộ Trì Bản Năng | CÓ KÊNH | Tăng 12% hiệu quả khiên tạo cho người khác, không áp dụng khiên bản thân | Healing/Shield/Injury treatment V2 | Chưa có consumer V2 được chứng minh |
| 47 | Kiếm Cảm | CÓ KÊNH | Tăng 12% EXP tu luyện Kiếm đạo và 8% hiệu quả kỹ năng hệ Kiếm | Skill/Path tags and mastery | Chưa có consumer V2 được chứng minh |
| 48 | Thể Ngộ | CÓ KÊNH | Tăng 12% EXP Thể đạo và 8% hiệu quả kỹ năng hệ Thể | Skill/Path tags and mastery | Chưa có consumer V2 được chứng minh |
| 49 | Pháp Cảm | CÓ KÊNH | Tăng 12% EXP Pháp đạo và 8% hiệu quả kỹ năng hệ Pháp | Skill/Path tags and mastery | Chưa có consumer V2 được chứng minh |
| 50 | Kiếm Tâm Ổn Định | CÓ KÊNH | Khi HP từ 50%: tăng 8% hiệu quả kỹ năng Kiếm | Skill/Path tags and mastery | Chưa có consumer V2 được chứng minh |
| 51 | Cận Chiến Lão Thành | CÓ KÊNH | Tăng 8% hiệu quả kỹ năng hệ Thể và 5 điểm phần trăm kháng chí mạng | Skill/Path tags and mastery | Chưa có consumer V2 được chứng minh |
| 52 | Pháp Ý Liên Miên | CÓ KÊNH | Tăng 8% hiệu quả kỹ năng Pháp và 8% tốc độ tung chiêu | Skill/Path tags and mastery | Chưa có consumer V2 được chứng minh |
| 53 | Tạp Tu | CÓ KÊNH | Tăng 8% EXP học của hai đạo thấp nhất; giảm 5% hiệu quả kỹ năng của đạo cao nhất | Skill/Path tags and mastery | Chưa có consumer V2 được chứng minh |
| 54 | Tham Ăn | Ý TƯỞNG CHƯA KHÓA | Tiêu thụ thêm 20% khẩu phần; +10% hiệu quả hồi phục từ bữa ăn | Food, meal/recovery | Chưa có consumer V2 được chứng minh |
| 55 | Kén Ăn | Ý TƯỞNG CHƯA KHÓA | -10% hồi phục từ món thường; +15% từ món cao cấp | Food grades, meal/recovery | Chưa có consumer V2 được chứng minh |
| 56 | Cú Đêm | Ý TƯỞNG CHƯA KHÓA | +12% tốc độ công việc ca đêm, -8% ca ngày | Time-of-day and work schedule | Chưa có consumer V2 được chứng minh |
| 57 | Ngủ Nướng | Ý TƯỞNG CHƯA KHÓA | Vào ca đầu ngày muộn 30 phút; hồi phục lúc nghỉ +8% | Work schedule and rest | Chưa có consumer V2 được chứng minh |
| 58 | Mê Sạch Sẽ | Ý TƯỞNG CHƯA KHÓA | Nơi sạch +10% tốc độ làm việc, nơi bẩn -10% | Building cleanliness | Chưa có consumer V2 được chứng minh |
| 59 | Bày Bừa | Ý TƯỞNG CHƯA KHÓA | +8% tốc độ làm việc; tăng nguy cơ sự cố bảo trì có nguồn sự kiện thật | Maintenance events | Chưa có consumer V2 được chứng minh |
| 60 | Trộm Ăn Vặt | Ý TƯỞNG CHƯA KHÓA | Tiêu hao thêm khẩu phần nhỏ qua sự kiện tiêu thụ có nhật ký | Food inventory/events | Chưa có consumer V2 được chứng minh |
| 61 | Mê Ngủ Trưa | Ý TƯỞNG CHƯA KHÓA | Tự ưu tiên nghỉ giữa ca; giảm thời gian công việc nhưng hồi phục tốt hơn | Rest and work schedule | Chưa có consumer V2 được chứng minh |
| 62 | Mắt Nhìn Quặng | Ý TƯỞNG CHƯA KHÓA | -400 độ khó cho kiểm tra khoáng hiếm hợp lệ | Mine rare-check | Chưa có consumer V2 được chứng minh |
| 63 | Khứu Giác Linh Thảo | Ý TƯỞNG CHƯA KHÓA | -400 độ khó cho kiểm tra linh thảo hiếm hợp lệ | Spirit Field rare-check | Chưa có consumer V2 được chứng minh |
| 64 | Thích Thử Nghiệm | Ý TƯỞNG CHƯA KHÓA | +12% EXP nghề khi thử công thức mới; giảm độ ổn định thử công thức | Crafting trial/quality | Chưa có consumer V2 được chứng minh |
| 65 | Đếm Từng Đồng | Ý TƯỞNG CHƯA KHÓA | Giao dịch giá tốt hơn 3%, thời gian giao dịch +10% | Trade economy and timer | Chưa có consumer V2 được chứng minh |
| 66 | Vừa Làm Vừa Hát | Ý TƯỞNG CHƯA KHÓA | +6% tốc độ bản thân; đồng nghiệp trong phạm vi hợp lệ có thể -3% | Co-worker proximity / work | Chưa có consumer V2 được chứng minh |
| 67 | Đổi Việc Như Thay Áo | Ý TƯỞNG CHƯA KHÓA | +12% XP ca đầu nghề mới; -8% XP học chuyên sâu | Profession history/milestones | Chưa có consumer V2 được chứng minh |
| 68 | Hay Quên Dụng Cụ | Ý TƯỞNG CHƯA KHÓA | Chậm khởi động một số ca do chuẩn bị dụng cụ; chỉ khi có sự kiện hợp lệ | Job setup event | Chưa có consumer V2 được chứng minh |
| 69 | Học Qua Thực Hành | Ý TƯỞNG CHƯA KHÓA | Sau sản phẩm chất lượng cao +10% XP nghề cho lần sản xuất | Crafting quality event | Chưa có consumer V2 được chứng minh |
| 70 | Ngộ Đạo Lúc Quét Sân | Ý TƯỞNG CHƯA KHÓA | Hoàn thành ca công việc phù hợp -> +5% Tu Vi tự nhiên ở lần tu luyện tiếp theo trong ngày | Work complete -> cultivation event | Chưa có consumer V2 được chứng minh |
| 71 | Bế Quan Quên Ngày | Ý TƯỞNG CHƯA KHÓA | Bế quan liên tục nhận +8% Tu Vi tự nhiên; có xu hướng chậm rời lịch bế quan | Retreat schedule | Chưa có consumer V2 được chứng minh |
| 72 | Học Vẹt | Ý TƯỞNG CHƯA KHÓA | +12% XP học công pháp mới, -8% hiệu quả kỹ năng trước Nhập Môn | Technique/skill mastery | Chưa có consumer V2 được chứng minh |
| 73 | Trí Nhớ Cá Vàng | Ý TƯỞNG CHƯA KHÓA | Buổi học đầu sau khi đổi chủ đề -15% XP mastery; không xóa tiến độ đã đạt | Learning subject switch | Chưa có consumer V2 được chứng minh |
| 74 | Mê Sưu Tầm Công Pháp | Ý TƯỞNG CHƯA KHÓA | +10% XP với công pháp chưa học; phạt đổi chủ đề thường xuyên | Technique library, session history | Chưa có consumer V2 được chứng minh |
| 75 | Nửa Đêm Tỉnh Ngộ | Ý TƯỞNG CHƯA KHÓA | +10% EXP học/thành thạo cho buổi lĩnh ngộ đêm đầu tiên | Time-of-day learning | Chưa có consumer V2 được chứng minh |
| 76 | Sợ Đột Phá | Ý TƯỞNG CHƯA KHÓA | Sau thất bại đột phá hợp lệ, 2 buổi tu sau -10% Tu Vi tự nhiên; không đổi tỷ lệ đột phá | Breakthrough outcome + temporary condition | Chưa có consumer V2 được chứng minh |
| 77 | Nghe Giảng Là Buồn Ngủ | Ý TƯỞNG CHƯA KHÓA | -10% XP khi học qua truyền giảng; +5% Tu Vi tự nhiên khi tự tu | Teaching vs independent cultivation | Chưa có consumer V2 được chứng minh |
| 78 | Nhát Nhưng Chạy Nhanh | Ý TƯỞNG CHƯA KHÓA | sinh mệnh <50%: +20% Movement, -10% sát thương đánh thường | sinh mệnh contextual combat | Chưa có consumer V2 được chứng minh |
| 79 | Thù Dai | Ý TƯỞNG CHƯA KHÓA | Bị địch gây sát thương: +10% sát thương lên đúng địch đó 6s, không cộng dồn | Damage-source attribution | Chưa có consumer V2 được chứng minh |
| 80 | Đánh Hội Đồng | Ý TƯỞNG CHƯA KHÓA | +10% sát thương lên địch đang bị đồng đội tấn công; đơn độc -8% | Team target attribution | Chưa có consumer V2 được chứng minh |
| 81 | Chuyên Đánh Lén | Ý TƯỞNG CHƯA KHÓA | +15% đòn đầu lên địch chưa nhắm mình; bị tập trung tấn công -8% | Aggro/first strike | Chưa có consumer V2 được chứng minh |
| 82 | Hò Hét Xung Phong | Ý TƯỞNG CHƯA KHÓA | Mở trận +3 điểm % Effect Resistance cho đồng đội gần trong 5s; đòn đầu của bản thân chậm 0.4s | Combat opening / allied proximity | Chưa có consumer V2 được chứng minh |
| 83 | Giả Chết Tài Tình | Ý TƯỞNG CHƯA KHÓA | Một lần mỗi trận khi sinh mệnh <15%: giảm ưu tiên bị nhắm trong khoảng ngắn; không hủy sát thương chí mạng đã giải quyết | Threat targeting, once/encounter | Chưa có consumer V2 được chứng minh |
| 84 | Tay Nhanh Hơn Não | Ý TƯỞNG CHƯA KHÓA | +15% Basic tốc độ đánh; +10% hồi chiêu của kỹ năng chủ động | Separate combat speed/hồi chiêu | Chưa có consumer V2 được chứng minh |
| 85 | Vấp Nhưng Không Ngã | Ý TƯỞNG CHƯA KHÓA | Lần đầu chịu slow hợp lệ mỗi trận: rút ngắn 20% thời hạn | Status source/duration | Chưa có consumer V2 được chứng minh |
| 86 | Lắm Chuyện | Ý TƯỞNG CHƯA KHÓA | Truyền thông tin đã biết nhanh hơn; tin xấu có thể gây mất thiện cảm từ tương tác thật | Social info/history | Chưa có consumer V2 được chứng minh |
| 87 | Hay Mách Lẻo | Ý TƯỞNG CHƯA KHÓA | Báo cáo vi phạm có thật nhanh hơn; người bị báo có thể giảm thiện cảm | Violations/social relations | Chưa có consumer V2 được chứng minh |
| 88 | Biết Tuốt | Ý TƯỞNG CHƯA KHÓA | Chủ động hướng dẫn; lời khuyên đúng tạo XP, sai làm mất thời gian | Advice/teaching validation | Chưa có consumer V2 được chứng minh |
| 89 | Hay Gây Sự | Ý TƯỞNG CHƯA KHÓA | Ưu tiên đề nghị tỉ thí; thêm luyện tập nhưng tăng cơ hội mâu thuẫn | Duel/social event | Chưa có consumer V2 được chứng minh |
| 90 | Thích Khoe | Ý TƯỞNG CHƯA KHÓA | Thành tựu thật có thể tạo cổ vũ hoặc ganh đua giữa nhân chứng | Witnessed achievements/social | Chưa có consumer V2 được chứng minh |
| 91 | Tốt Bụng Quá Đà | Ý TƯỞNG CHƯA KHÓA | Ưu tiên giúp đồng môn bị thương, chậm công việc của mình | Rescue AI/work displacement | Chưa có consumer V2 được chứng minh |
| 92 | Mê Làm Sư Huynh | Ý TƯỞNG CHƯA KHÓA | Khi dạy đệ tử ít kinh nghiệm: người học nhận thêm XP; người dạy mất thời gian cá nhân | Teaching/discipleship | Chưa có consumer V2 được chứng minh |
| 93 | Cãi Chày Cãi Cối | Ý TƯỞNG CHƯA KHÓA | Kéo dài xử lý bất đồng bằng sự kiện tranh luận thật | Conflict resolution | Chưa có consumer V2 được chứng minh |
| 94 | Lạc Đường Có Duyên | Ý TƯỞNG CHƯA KHÓA | +10% thời gian hoặc thể lực viễn chinh đi đường; -300 độ khó cho lần khám phá kỳ ngộ hợp lệ đầu tiên | Expedition travel/event | Chưa có consumer V2 được chứng minh |
| 95 | Nhặt Gì Cũng Mang | Ý TƯỞNG CHƯA KHÓA | Tăng cơ hội phần thưởng thường có nguồn hợp lệ; +10% tiêu hao thể lực vận chuyển ngoài map | Loot source + thể lực viễn chinh | Chưa có consumer V2 được chứng minh |
| 96 | Đụng Gì Cũng Mở | Ý TƯỞNG CHƯA KHÓA | Tăng cơ hội tương tác vật thể chưa rõ; rủi ro sự kiện bất lợi qua bảng có thật | Exploration interaction/event | Chưa có consumer V2 được chứng minh |
| 97 | Thính Tai | Ý TƯỞNG CHƯA KHÓA | Giảm độ khó kiểm tra phát hiện phục kích/bẫy | Detection event | Chưa có consumer V2 được chứng minh |
| 98 | Xem Bản Đồ Ngược | Ý TƯỞNG CHƯA KHÓA | Đường lần đầu có chi phí di chuyển cao; học thuộc đường giảm hoặc xóa phạt | Route familiarity | Chưa có consumer V2 được chứng minh |
| 99 | Đi Đâu Cũng Đánh Dấu | Ý TƯỞNG CHƯA KHÓA | Trên đường đã khám phá giảm 10% thể lực viễn chinh cost | Explored-route tracking | Chưa có consumer V2 được chứng minh |
| 100 | Sợ Ma | Ý TƯỞNG CHƯA KHÓA | Gặp địch có tag u linh/hồn ma: -8% sát thương gây ra | Monster tags | Chưa có consumer V2 được chứng minh |
| 101 | Lì Đòn Khi Lạc Rừng | Ý TƯỞNG CHƯA KHÓA | Môi trường rừng khắc nghiệt: -8% thành phần tiêu hao thể lực viễn chinh do môi trường | Map environment stamina component | Chưa có consumer V2 được chứng minh |

## 5. Quy tắc chốt 41 + 12 + 48, không làm 101 lần theo kiểu mỗi trait một hệ thống

**41 có kênh:** duyệt kênh và giá trị đã có, gắn từng ID vào 6 bộ xử lý dùng chung (học, Tu Vi, lao động, combat, hồi phục, đạo lộ). Không thêm một script engine cho mỗi trait.

**12 thiếu phụ thuộc:** không đánh dấu “design complete” nếu chỉ biết lợi ích. Phải làm rõ cả cái giá, điều kiện/nguồn sự kiện, trạng thái khi event vắng mặt, và fallback fail-closed. Ví dụ *Trí Nhớ Sâu* không được áp hiệu ứng giảm quên khi chưa có hệ quên; *Cuồng Công* không tự trừ Expedition Stamina trong tông môn; *Cẩu Thả* không được giữ hai cơ chế trái dấu.

**48 mới đề xuất:** chia theo 6 nhóm \`ăn uống/sinh hoạt, kinh tế, học/tu, chiến đấu, quan hệ, viễn chinh\`. Giữ nguyên con số bản nháp để so sánh, nhưng chỉ duyệt khi đã có *trigger + effect math + consequence/downside + consumer + event source + cap + anti-double-apply*. Nếu nhóm nghề/sự kiện chưa có consumer, hoàn tất mô tả nhưng giữ trạng thái \`DESIGN_GATED\` thay vì bịa chức năng.

## 6. Những điều thật sự còn phải quyết định

- **Tâm Tính:** có chốt D1-A kháng mental theo +0,02 điểm %/điểm và giảm thời lượng +0,025%/điểm không? Có cần tách Tâm Cảnh thành giai đoạn độc lập?
- **12 Trait gated:** chọn luật downside/trigger chính thức theo hệ consumer tương ứng, cấm kích hoạt một nửa.
- **48 Trait concept:** đóng hệ số sau so sánh độ hiếm, cân bằng buff theo level, thời gian tác dụng, loại enemy và độ khó real action.
- **Nhân vật event:** chọn cụ thể social/food/schedule/exploration authority trước khi phát hành trait thuộc các nhóm đó.

## 7. Trạng thái thiết kế của gói

**Đã biên soạn:** 101/101 dòng, đặc tính–tác dụng–consumer; kiến trúc dùng chung; dự thảo Tâm Tính và Tâm Cảnh; phát hiện xung đột hệ cũ.

**Chưa gọi DESIGN LOCKED:** hệ số Tâm Tính, 12 dependency và 48 concept chưa được phê duyệt toàn bộ. Không sửa \`TRAITS_V2_SPEC.md\` để tự gán phê duyệt của người dùng.

Nguồn: \`docs/DISCIPLE_V2_EFFECT_SOURCE_MATRIX.md\`, \`docs/DISCIPLE_V2_STAT_CAUSAL_CONTRACT.md\`, \`docs/TRAITS_V2_SPEC.md\`, \`wiki/data/trait_effect_audit.json\`.


## 8. RÀ SOÁT D1-R2 — 16 CHỈ SỐ CHIẾN ĐẤU V2 VÀ ĐỀ XUẤT ĐIỀU CHỈNH (18/11/2026)

**Phát hiện và sửa cách hiểu:**
- **Đã thiết kế khóa:** 16 chỉ số chiến đấu chính + 10 kháng hệ, gồm cả Hút Máu/Giảm Hút Máu đã được owner duyệt 09/10/2026. Không phải một nhóm chỉ số còn cần phát minh.
- **Đã có bộ tính:** \`godot/src/simulation/combat/combat_stats_v2.gd\` có \`derive()\` và resolver cho crit, DEF/xuyên phòng, status, hút máu, 10 kháng hệ. Test \`godot/tests/simulation/dv2_02_combat_stats_test.gd\` và bằng chứng Godot tập trung trong \`COMBAT_STATS_V2_SPEC.md\`. Không tự suy ra combat PvE chính đã dùng đầy đủ; \`combat_system.gd\` vẫn có các luồng đọc \`combat_power\` cũ.
- **Chưa đồng bộ đầy đủ:** 101 Trait V2, Mệnh Cách, Thể Chất, Huyết Mạch, Linh Căn, đồ V2 và các nguồn có điều kiện chưa được chứng minh cấp modifier chính xác tới từng hành động đang diễn ra.

### 8.1 Quyết định giữ nguyên — không mở lại cân bằng

| Nội dung | Quyết định vốn đã khóa |
|---|---|
| HP / Công / Thủ | 300 tầng Realm và Body, growth 1.65/đại cảnh, 1.03/tiểu cảnh, core 100/20/12 + 90/3/7, Tiềm Lực 0.05%/điểm |
| 16 Combat Stats | HP, Attack, Defense, Move, BasicSpeed, CastSpeed, Cooldown, CritChance, CritDamage, CritResistance, Penetration, EffectHit, EffectResistance, DamageReduction, Lifesteal, LifestealReduction |
| Crit | 5% xác suất gốc; hệ số sát thương 1,50× gốc; Kháng Bạo trừ **điểm phần trăm** tỷ lệ crit, không giảm damage của đòn crit |
| Sát thương trực tiếp | DEF có hiệu lực sau buff/debuff và xuyên phòng; K=2×ATK, hệ số K/(K+DEF); giảm sát thương/kháng hệ nhân trên phần còn lại |
| Tốc độ | thời gian cơ bản ÷ (1 + bonus tỷ lệ) cho đánh thường/thi pháp/hồi chiêu |
| Hút Máu | hồi dựa trên HP thật mục tiêu mất, trừ kháng hút máu theo điểm %, không hút overkill |
| 10 kháng hệ | cộng các nguồn độc lập bằng phép nhân phần sát thương còn lại, không cộng thẳng |
| Không tạo mới | generic Accuracy/Dodge, physical/magical duplicated ATK/DEF, Mana bar phổ quát, Damage Reduction riêng của Crit, CombatPower dùng làm damage V2 |

**Chỉ số bối cảnh** (vs Boss, chủng tộc, liên kích, hồi máu thực hiện/nhận, shield, DoT) không được lén tăng số lượng 16 headline. Chúng chỉ xuất hiện ở breakdown khi có consumer và điều kiện đúng.

### 8.2 Cần điều chỉnh bản đề xuất Tâm Tính trước khi chốt

**Phương án D1-A đã ghi ở §1:** Tâm Tính cho +kháng riêng nhóm \`mental\` và rút ngắn thời lượng trúng mental. Phương án này có **hai điểm yếu**: kỹ năng có tag mental chưa được chứng minh đủ consumer đang chạy, và hai hiệu ứng cùng giảm rủi ro hiệu ứng tinh thần có thể trở thành nhân lợi ích hai lần.

**Đề xuất mới D1-A2, khuyến nghị cân nhắc (CHƯA PHÊ DUYỆT):**
- Không thêm một combat stat. Dùng kênh \`effect_resistance\` đã có.
- Đóng góp tĩnh từ Tâm Tính: \`bonus_effect_resistance_pp = min(0.08, 0.0001 × max(0,TamTinh))\`. 100 điểm → **+1 điểm phần trăm**, 500 → **+5 điểm phần trăm**, từ 800 điểm → tối đa **+8 điểm phần trăm**.
- Ở V2 áp đúng một nguồn toàn cục \`foundation_mind_nature\` vào \`effect_resistance\`, \`mode=percentage_points\` (nếu phép tính/consumer đã đủ điều kiện). Các Trait như *Tâm Thần Kiên Cố* +10 điểm % có source ID riêng và dùng luật cộng điểm %, không nhập lại chỉ số Tâm Tính vào dữ liệu gốc.
- **Bỏ phần giảm thời lượng** của D1-A nếu chọn A2, tránh nhân lợi ích thứ hai và đỡ cần thêm duration-consumer chưa sẵn sàng.
- Không tăng Tu Vi/s, Luyện Thể, học, Crit Chance, damage hoặc xác suất đột phá chỉ từ Tâm Tính.

**Vì sao đề xuất A2:** có vai trò ngay với kiểm tra status chung, đọc số đơn giản, tránh thêm hệ Tâm Cảnh trước khi thiết kế đầy đủ. **Cần phê duyệt/balance riêng**, nhất là giao thoa với Tâm Thần Kiên Cố +10pp và trạng thái miễn nhiễm của Boss. §1 D1-A vẫn là phương án cũ để đối chiếu; nếu phê duyệt A2, sửa authority gốc bằng quyết định riêng, không bật song song A và A2.

### 8.3 Cần điều chỉnh 101 Trait — không phải phát minh thêm chỉ số

1. 41 Trait đã có kênh: phân nhóm theo **sáu resolver dùng chung** cho học/mastery, Tu Vi, công việc, chiến đấu, hồi phục, đạo lộ. Không thêm 41 công thức trùng stat authority.
2. 12 Trait phụ thuộc: mỗi Trait hai mặt phải viết đủ lợi và hại, điều kiện, event, expiry, hiệu ứng khi thiếu consumer; không bật nửa có lợi trước.
3. 48 Trait chỉ là proposal: ghi \`design_state=OPEN\` dù danh mục tên đã chốt. Tập trung đối chiếu các hệ **food/sleep/social/time-of-day/loot** trước khi chốt hệ số, không tự làm 48 hiệu ứng cho consumer chưa tồn tại.
4. Các Trait đặc biệt như *Bản Năng Chiến Đấu* (+5pp Crit), *Tâm Thần Kiên Cố* (+10pp Effect Resistance), *Phá Giáp Cảm* (+5pp Xuyên Phòng theo kênh đã định nghĩa) phải dùng registry 16 chỉ số và kiểm tra case có/không có source.
5. Giải quyết trùng và mâu thuẫn 9 Trait legacy trước khi kết luận có buff thật. *Cẩu Thả* cũ âm work speed, V2 vừa dương work speed vừa giảm chất lượng — cần consumer \`quality_check\` mới được bật phiên bản V2.
6. Không lấy chất lượng nhân vật (Phàm Thường/Thiên Kiêu...) làm hệ số nhân Công/Thủ/HP. Phẩm chất là nhãn từ Lục Duy, còn kỹ năng/vũ khí/đạo lộ tạo hiệu quả từ đúng source.

### 8.4 Giao diện D1 cần rõ ràng

Trang “Đệ tử & đặc tính” trong **Tàng Kinh Các duy nhất** phải cho thấy: 7 chỉ số gốc → 16 Combat Stats → 10 kháng hệ → bộ thuộc tính bối cảnh → 101 đặc tính có/thiếu hiệu ứng. Hệ số crit luôn biểu diễn **1,50×**, khác với tỷ lệ crit **5%**. Điều kiện chí mạng và kháng chí mạng giải thích bằng ví dụ 40% − 15 điểm % = 25%.

**Mức chứng cứ:** thiết kế 16 chỉ số **ĐÃ KHÓA**; bộ tính **ĐÃ CÓ MÃ và từng PASS focused Godot**; **combat live PvE chưa đồng bộ đầy đủ**; 101 Trait V2 **chưa thể gọi runtime hoàn thành**. Không được gom bốn tầng vào trạng thái “Đã code hết”.

### 8.5 Các quyết định chờ owner ở lần D1 tiếp theo

- **Ưu tiên A2 hay A:** Tâm Tính cho +0,01 điểm % Kháng Hiệu Ứng/điểm (tối đa +8pp), **hoặc** kháng mental +0,02 điểm %/điểm kèm rút ngắn thời lượng theo thiết kế cũ. Khuyến nghị **A2** vì dùng được stat V2 đã có và tránh double dip.
- **Giữ Tâm Cảnh ở bản mở rộng**: không thêm tầng tu luyện khi các consumer tinh thần vẫn chưa hoàn thiện.
- **Chốt luật 12 Trait phụ thuộc**, không thêm 101 stat mới.
- **48 Trait concept** chỉ khóa số sau khi cơ chế sinh hoạt/nghề/chiến đấu/xã hội/viễn chinh có event authority.
- **Kiểm thống nhất mô tả ở Wiki**: baseline 5% crit, 1,50× Crit Damage, 16 headline+10 keyed resistance; ghi rõ trạng thái runtime.

Không có mã gameplay mới trong gói D1-R2; không thay đổi các luật người dùng đã khóa.
