# ĐỆ TỬ V2 — MA TRẬN NGUỒN HIỆU ỨNG → CONSUMER

Ngày: 2026-10-09

**Trạng thái: DESIGN/AUDIT MAPPING, CHƯA TRIỂN KHAI CODE.** Không tự đồng nhất `channel has been specified` với `consumer đã được hiện thực trong runtime`. Mọi hiệu ứng active phải có test tác động lên một hành động cụ thể. Căn cứ: `docs/DISCIPLE_V2_STAT_CAUSAL_CONTRACT.md` và các spec V2 chuyên ngành.

Bảng này bao trùm **53 Đặc Chất gốc + 48 đề xuất mới = 101 danh tính Đặc Chất**, 24 Mệnh Cách, 5 Huyết Mạch, 15 Thể Chất, 5 Linh Căn cơ bản + 5 Dị Linh Căn. Con số 101 là **danh mục thiết kế được duyệt về hướng**, không có nghĩa 101 ID đã đủ balance/trọng số hoặc đã được bật.

`CHANNEL SPECIFIED` = đường chỉ số đã được nêu trong spec nhưng V2 runtime chưa hoàn tất.
`DEPENDENCY GATED` = thiếu owner/trigger/nhược điểm thực sự và KHÔNG được kích hoạt.
`DESIGN CONCEPT` = đề xuất nội dung/hệ số chưa khóa, chỉ có thể lưu identity khi hợp lệ theo luật sinh.
Trọng số xuất hiện riêng theo ID, nội dung mệnh sinh và tương tác xung đột **chưa được phê duyệt**.

## A. Toàn bộ 53 Đặc Chất đã có trong Chapter 17

| Đặc Chất | Nhóm | Nature trong draft | Tác động/kênh | Consumer cần có | Readiness |
|---|---|---|---|---|---|
| Ham Học | Học/Lĩnh ngộ | Hữu Ích | +10% all valid learning/mastery XP | XP học Công Pháp/Kỹ Năng, focus subject và learning event | Channel specified; V2 execution NOT YET |
| Nhất Tâm | Học/Lĩnh ngộ | Hữu Ích | +15% technique/skill mastery XP while learning one selected subject at a time; switching subject clears the temporary focus buildup | XP học Công Pháp/Kỹ Năng, focus subject và learning event | Channel specified; V2 execution NOT YET |
| Trí Nhớ Sâu | Học/Lĩnh ngộ | Hữu Ích | +8% mastery XP; decay half-effect NOT VALID until mastery-decay system exists | XP học Công Pháp/Kỹ Năng, focus subject và learning event | DEPENDENCY GATED |
| Suy Diễn | Học/Lĩnh ngộ | Song Diện | +15% technique mastery XP; -8% Work Speed while assigned to ordinary production | XP học Công Pháp/Kỹ Năng, focus subject và learning event | Channel specified; V2 execution NOT YET |
| Học Nhanh Làm Ẩu | Học/Lĩnh ngộ | Song Diện | +15% profession XP; +500 Difficulty on explicit work quality/rare checks | XP học Công Pháp/Kỹ Năng, focus subject và learning event | Channel specified; V2 execution NOT YET |
| Chậm Mà Chắc | Học/Lĩnh ngộ | Song Diện, consumer-gated | -8% learning XP; payoff waits for a real mastery-milestone authority | XP học Công Pháp/Kỹ Năng, focus subject và learning event | DEPENDENCY GATED (partial allowed only when independent + full cost) |
| Tạp Niệm | Học/Lĩnh ngộ | Bất Lợi | -10% technique/skill mastery XP | XP học Công Pháp/Kỹ Năng, focus subject và learning event | Channel specified; V2 execution NOT YET |
| Khó Tiếp Thu | Học/Lĩnh ngộ | Bất Lợi | -12% all valid learning/mastery XP | XP học Công Pháp/Kỹ Năng, focus subject và learning event | Channel specified; V2 execution NOT YET |
| Kinh Mạch Ổn Định | Tu Vi | Hữu Ích | +10% natural/base cultivation gain | Cultivation gain + Breakthrough V2 | Channel specified; V2 execution NOT YET |
| Kinh Mạch Mong Manh | Tu Vi | Bất Lợi | -10% natural/base cultivation gain | Cultivation gain + Breakthrough V2 | Channel specified; V2 execution NOT YET |
| Ngộ Tĩnh | Tu Vi | Hữu Ích, latent-eligible | +8% cultivation gain; +10% technique/skill mastery XP | Cultivation gain + Breakthrough V2 | Channel specified; V2 execution NOT YET |
| Tâm Tĩnh Như Thủy | Tu Vi | Hữu Ích | +8% cultivation gain while not carrying a serious Injury or explicit disturbed-mind state | Cultivation gain + Breakthrough V2 | DEPENDENCY GATED (partial allowed only when independent + full cost) |
| Nóng Vội Cầu Thành | Tu Vi | Song Diện, consumer-gated | +12% cultivation gain; downside waits for Breakthrough V2 | Cultivation gain + Breakthrough V2 | DEPENDENCY GATED (partial allowed only when independent + full cost) |
| Cần Mẫn | Lao động | Hữu Ích | +10% generic Work Speed | Work duration/XP/quality/material, context work | Channel specified; V2 execution NOT YET |
| Cuồng Công | Lao động | Song Diện | +15% Work Speed; old +20% in-sect Stamina tax INVALID V2; revised drawback requires separately approved work-rest subsystem | Work duration/XP/quality/material, context work | BLOCKED until real two-sided cost |
| Lười Nhác | Lao động | Bất Lợi | -12% generic Work Speed | Work duration/XP/quality/material, context work | Channel specified; V2 execution NOT YET |
| Cẩu Thả | Lao động | Song Diện | +10% Work Speed; +800 Difficulty on explicit work rare/quality Luck checks | Work duration/XP/quality/material, context work | Channel specified; V2 execution NOT YET |
| Tỉ Mỉ | Lao động | Song Diện | -5% Work Speed; -600 Difficulty on explicit work rare/quality Luck checks | Work duration/XP/quality/material, context work | Channel specified; V2 execution NOT YET |
| Tiết Liệu | Lao động | Hữu Ích, consumer-gated | material-efficiency effect waits for Crafting V2 integer/rounding authority | Work duration/XP/quality/material, context work | DEPENDENCY GATED (partial allowed only when independent + full cost) |
| Phung Phí | Lao động | Song Diện, consumer-gated | +8% profession XP; material-consumption penalty waits for Crafting V2 | Work duration/XP/quality/material, context work | DEPENDENCY GATED (partial allowed only when independent + full cost) |
| Đa Nhiệm | Lao động | Hữu Ích / contextual, consumer-gated | +8% Work Speed only in professions explicitly tagged multi-step by future profession content | Work duration/XP/quality/material, context work | DEPENDENCY GATED (partial allowed only when independent + full cost) |
| Quen Tay | Lao động | Hữu Ích | +10% profession XP for the disciple's currently highest profession | Work duration/XP/quality/material, context work | Channel specified; V2 execution NOT YET |
| Đổi Nghề Khó | Lao động | Bất Lợi | -15% profession XP in professions below the disciple's highest profession level | Work duration/XP/quality/material, context work | Channel specified; V2 execution NOT YET |
| Bản Năng Chiến Đấu | Chiến đấu | Hữu Ích, latent-eligible | +5 percentage points Crit Chance; +10% combat-skill mastery XP | Combat Stats V2 + context combat/kill/HP | Channel specified; V2 execution NOT YET |
| Linh Giác Sắc Bén | Chiến đấu | Hữu Ích | +10 percentage points Effect Hit | Combat Stats V2 + context combat/kill/HP | Channel specified; V2 execution NOT YET |
| Tâm Thần Kiên Cố | Chiến đấu | Hữu Ích | +10 percentage points Effect Resistance | Combat Stats V2 + context combat/kill/HP | Channel specified; V2 execution NOT YET |
| Phá Giáp Cảm | Chiến đấu | Hữu Ích | +5% Defense Penetration | Combat Stats V2 + context combat/kill/HP | Channel specified; V2 execution NOT YET |
| Hấp Tấp | Chiến đấu | Song Diện | +10% Cast Speed; -10 percentage points Effect Hit | Combat Stats V2 + context combat/kill/HP | Channel specified; V2 execution NOT YET |
| Huyết Chiến | Chiến đấu | Song Diện | +12% All Damage; -20% Healing Received | Combat Stats V2 + context combat/kill/HP | Channel specified; V2 execution NOT YET |
| Bất Khuất | Chiến đấu | Hữu Ích / conditional | while current HP <30%: +10% Damage Reduction | Combat Stats V2 + context combat/kill/HP | Channel specified; V2 execution NOT YET |
| Tâm Thần Bất Ổn | Chiến đấu | Bất Lợi | -10 percentage points Effect Resistance | Combat Stats V2 + context combat/kill/HP | Channel specified; V2 execution NOT YET |
| Trì Trọng | Chiến đấu | Song Diện | -10% Movement Speed; +10 pp Effect Resistance; +5% Damage Reduction | Combat Stats V2 + context combat/kill/HP | Channel specified; V2 execution NOT YET |
| Thân Pháp Nhẹ Nhàng | Chiến đấu | Hữu Ích | +10% Movement Speed | Combat Stats V2 + context combat/kill/HP | Channel specified; V2 execution NOT YET |
| Phản Ứng Nhanh | Chiến đấu | Hữu Ích | +8% Attack Speed and +5% Cast Speed | Combat Stats V2 + context combat/kill/HP | Channel specified; V2 execution NOT YET |
| Lão Luyện | Chiến đấu | Hữu Ích | +8 pp Crit Resistance | Combat Stats V2 + context combat/kill/HP | Channel specified; V2 execution NOT YET |
| Liều Mạng | Chiến đấu | Song Diện | +10% All Damage; +8% incoming damage | Combat Stats V2 + context combat/kill/HP | Channel specified; V2 execution NOT YET |
| Thừa Thắng Truy Kích | Chiến đấu | Hữu Ích / conditional | after personally defeating an enemy, +8% Movement Speed and +8% Attack Speed for 5s; cannot stack, only refresh | Combat Stats V2 + context combat/kill/HP | Channel specified; V2 execution NOT YET |
| Ổn Trận | Chiến đấu | Hữu Ích / contextual | when current HP >=70%, +8 pp Effect Resistance | Combat Stats V2 + context combat/kill/HP | Channel specified; V2 execution NOT YET |
| Dược Tâm | Trị liệu | Hữu Ích | +15% Healing Done | Healing/Shield/Injury treatment V2 | Channel specified; V2 execution NOT YET |
| Hộ Tâm | Trị liệu | Hữu Ích | +15% Shield Effect | Healing/Shield/Injury treatment V2 | Channel specified; V2 execution NOT YET |
| Hồi Nguyên | Trị liệu | Hữu Ích | +15% Healing Received; +10% Injury Recovery | Healing/Shield/Injury treatment V2 | DEPENDENCY GATED (partial allowed only when independent + full cost) |
| Khí Huyết Khó Hợp | Trị liệu | Bất Lợi | -15% Healing Received | Healing/Shield/Injury treatment V2 | Channel specified; V2 execution NOT YET |
| Dược Lý Thông Thạo | Trị liệu | Hữu Ích | +10% Healing Done; +10% medicine/healing profession XP when that profession authority exists | Healing/Shield/Injury treatment V2 | DEPENDENCY GATED (partial allowed only when independent + full cost) |
| Thương Binh Kinh Nghiệm | Trị liệu | Hữu Ích | +15% Injury Recovery; treatment AI values wounded allies more strongly | Healing/Shield/Injury treatment V2 | DEPENDENCY GATED (partial allowed only when independent + full cost) |
| Cứng Đầu | Trị liệu | Song Diện | +8% Damage Reduction while injured; -15% Healing Received | Healing/Shield/Injury treatment V2 | DEPENDENCY GATED (partial allowed only when independent + full cost) |
| Hộ Trì Bản Năng | Trị liệu | Hữu Ích / conditional | +12% Shield Effect when shielding another target; no bonus to self-shield | Healing/Shield/Injury treatment V2 | Channel specified; V2 execution NOT YET |
| Kiếm Cảm | Chủ Đạo | Hữu Ích, latent-eligible | +12% Sword path/mastery XP; +8% Sword-tagged skill effect | Skill/Path tags and mastery | Channel specified; V2 execution NOT YET |
| Thể Ngộ | Chủ Đạo | Hữu Ích, latent-eligible | +12% Body path/mastery XP; +8% Body-tagged skill effect | Skill/Path tags and mastery | Channel specified; V2 execution NOT YET |
| Pháp Cảm | Chủ Đạo | Hữu Ích, latent-eligible | +12% Spell path/mastery XP; +8% Spell-tagged skill effect | Skill/Path tags and mastery | Channel specified; V2 execution NOT YET |
| Kiếm Tâm Ổn Định | Chủ Đạo | Hữu Ích | +8% Sword skill effect while current HP >=50% | Skill/Path tags and mastery | Channel specified; V2 execution NOT YET |
| Cận Chiến Lão Thành | Chủ Đạo | Hữu Ích | +8% Body skill effect; +5 pp Crit Resistance | Skill/Path tags and mastery | Channel specified; V2 execution NOT YET |
| Pháp Ý Liên Miên | Chủ Đạo | Hữu Ích | +8% Spell skill effect; +8% Cast Speed | Skill/Path tags and mastery | Channel specified; V2 execution NOT YET |
| Tạp Tu | Chủ Đạo | Song Diện | +8% learning XP to the disciple's two lowest path depths; -5% skill effect for the currently highest path | Skill/Path tags and mastery | Channel specified; V2 execution NOT YET |

**Audit:** Đặc Chất `Cuồng Công` bị chặn vì nhược điểm tiêu hao Thể Lực khi làm việc trong tông môn trái với V2. Phải chốt và triển khai nhược điểm work/rest khác trước khi enable. Đặc Chất `Chậm Mà Chắc`, `Nóng Vội Cầu Thành`, `Phung Phí` v.v. không được bật một nửa lợi thế nếu cái giá đi kèm chưa có owner.

## B. 48 Đặc Chất được chấp thuận mở rộng về danh mục — chưa khóa hệ số/cơ chế

| Đặc Chất | Nhóm | Nature | Đường ảnh hưởng dự kiến (provisional) | Hệ thống cần có | Readiness |
|---|---|---|---|---|---|
| Tham Ăn | Sinh hoạt / ăn uống | S | Tiêu thụ thêm 20% khẩu phần; +10% hiệu quả hồi phục từ bữa ăn | Food, meal/recovery | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Kén Ăn | Sinh hoạt / ăn uống | S | -10% hồi phục từ món thường; +15% từ món cao cấp | Food grades, meal/recovery | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Cú Đêm | Sinh hoạt / ăn uống | S | +12% tốc độ công việc ca đêm, -8% ca ngày | Time-of-day and work schedule | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Ngủ Nướng | Sinh hoạt / ăn uống | S | Vào ca đầu ngày muộn 30 phút; hồi phục lúc nghỉ +8% | Work schedule and rest | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Mê Sạch Sẽ | Sinh hoạt / ăn uống | S | Nơi sạch +10% Work Speed, nơi bẩn -10% | Building cleanliness | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Bày Bừa | Sinh hoạt / ăn uống | S | +8% Work Speed; tăng nguy cơ sự cố bảo trì có nguồn sự kiện thật | Maintenance events | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Trộm Ăn Vặt | Sinh hoạt / ăn uống | B | Tiêu hao thêm khẩu phần nhỏ qua sự kiện tiêu thụ có nhật ký | Food inventory/events | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Mê Ngủ Trưa | Sinh hoạt / ăn uống | S | Tự ưu tiên nghỉ giữa ca; giảm thời gian công việc nhưng hồi phục tốt hơn | Rest and work schedule | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Mắt Nhìn Quặng | Nghề / kinh tế | H | -400 Difficulty cho kiểm tra khoáng hiếm hợp lệ | Mine rare-check | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Khứu Giác Linh Thảo | Nghề / kinh tế | H | -400 Difficulty cho kiểm tra linh thảo hiếm hợp lệ | Spirit Field rare-check | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Thích Thử Nghiệm | Nghề / kinh tế | S | +12% profession XP khi thử công thức mới; giảm độ ổn định thử công thức | Crafting trial/quality | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Đếm Từng Đồng | Nghề / kinh tế | S | Giao dịch giá tốt hơn 3%, thời gian giao dịch +10% | Trade economy and timer | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Vừa Làm Vừa Hát | Nghề / kinh tế | S | +6% tốc độ bản thân; đồng nghiệp trong phạm vi hợp lệ có thể -3% | Co-worker proximity / work | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Đổi Việc Như Thay Áo | Nghề / kinh tế | S | +12% XP ca đầu nghề mới; -8% XP học chuyên sâu | Profession history/milestones | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Hay Quên Dụng Cụ | Nghề / kinh tế | B | Chậm khởi động một số ca do chuẩn bị dụng cụ; chỉ khi có sự kiện hợp lệ | Job setup event | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Học Qua Thực Hành | Nghề / kinh tế | H | Sau sản phẩm chất lượng cao +10% XP nghề cho lần sản xuất | Crafting quality event | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Ngộ Đạo Lúc Quét Sân | Tu luyện / học | H | Hoàn thành ca công việc phù hợp -> +5% Tu Vi tự nhiên ở lần tu luyện tiếp theo trong ngày | Work complete -> cultivation event | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Bế Quan Quên Ngày | Tu luyện / học | S | Bế quan liên tục nhận +8% Tu Vi tự nhiên; có xu hướng chậm rời lịch bế quan | Retreat schedule | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Học Vẹt | Tu luyện / học | S | +12% XP học công pháp mới, -8% Skill Effect trước Nhập Môn | Technique/skill mastery | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Trí Nhớ Cá Vàng | Tu luyện / học | B | Buổi học đầu sau khi đổi chủ đề -15% XP mastery; không xóa tiến độ đã đạt | Learning subject switch | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Mê Sưu Tầm Công Pháp | Tu luyện / học | S | +10% XP với công pháp chưa học; phạt đổi chủ đề thường xuyên | Technique library, session history | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Nửa Đêm Tỉnh Ngộ | Tu luyện / học | H | +10% learning/mastery XP cho buổi lĩnh ngộ đêm đầu tiên | Time-of-day learning | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Sợ Đột Phá | Tu luyện / học | B | Sau thất bại đột phá hợp lệ, 2 buổi tu sau -10% Tu Vi tự nhiên; không đổi tỷ lệ đột phá | Breakthrough outcome + temporary condition | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Nghe Giảng Là Buồn Ngủ | Tu luyện / học | S | -10% XP khi học qua truyền giảng; +5% Tu Vi tự nhiên khi tự tu | Teaching vs independent cultivation | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Nhát Nhưng Chạy Nhanh | Chiến đấu / hành vi | S | HP <50%: +20% Movement, -10% sát thương đánh thường | HP contextual combat | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Thù Dai | Chiến đấu / hành vi | H | Bị địch gây sát thương: +10% sát thương lên đúng địch đó 6s, không cộng dồn | Damage-source attribution | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Đánh Hội Đồng | Chiến đấu / hành vi | S | +10% sát thương lên địch đang bị đồng đội tấn công; đơn độc -8% | Team target attribution | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Chuyên Đánh Lén | Chiến đấu / hành vi | S | +15% đòn đầu lên địch chưa nhắm mình; bị tập trung tấn công -8% | Aggro/first strike | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Hò Hét Xung Phong | Chiến đấu / hành vi | S | Mở trận +3 điểm % Effect Resistance cho đồng đội gần trong 5s; đòn đầu của bản thân chậm 0.4s | Combat opening / allied proximity | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Giả Chết Tài Tình | Chiến đấu / hành vi | H | Một lần mỗi trận khi HP <15%: giảm ưu tiên bị nhắm trong khoảng ngắn; không hủy sát thương chí mạng đã giải quyết | Threat targeting, once/encounter | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Tay Nhanh Hơn Não | Chiến đấu / hành vi | S | +15% Basic Attack Speed; +10% cooldown của kỹ năng chủ động | Separate combat speed/cooldown | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Vấp Nhưng Không Ngã | Chiến đấu / hành vi | H | Lần đầu chịu slow hợp lệ mỗi trận: rút ngắn 20% thời hạn | Status source/duration | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Lắm Chuyện | Quan hệ / đời sống tông môn | S | Truyền thông tin đã biết nhanh hơn; tin xấu có thể gây mất thiện cảm từ tương tác thật | Social info/history | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Hay Mách Lẻo | Quan hệ / đời sống tông môn | S | Báo cáo vi phạm có thật nhanh hơn; người bị báo có thể giảm thiện cảm | Violations/social relations | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Biết Tuốt | Quan hệ / đời sống tông môn | S | Chủ động hướng dẫn; lời khuyên đúng tạo XP, sai làm mất thời gian | Advice/teaching validation | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Hay Gây Sự | Quan hệ / đời sống tông môn | S | Ưu tiên đề nghị tỉ thí; thêm luyện tập nhưng tăng cơ hội mâu thuẫn | Duel/social event | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Thích Khoe | Quan hệ / đời sống tông môn | S | Thành tựu thật có thể tạo cổ vũ hoặc ganh đua giữa nhân chứng | Witnessed achievements/social | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Tốt Bụng Quá Đà | Quan hệ / đời sống tông môn | S | Ưu tiên giúp đồng môn bị thương, chậm công việc của mình | Rescue AI/work displacement | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Mê Làm Sư Huynh | Quan hệ / đời sống tông môn | S | Khi dạy đệ tử ít kinh nghiệm: người học nhận thêm XP; người dạy mất thời gian cá nhân | Teaching/discipleship | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Cãi Chày Cãi Cối | Quan hệ / đời sống tông môn | B | Kéo dài xử lý bất đồng bằng sự kiện tranh luận thật | Conflict resolution | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Lạc Đường Có Duyên | Viễn chinh / cơ duyên | S | +10% thời gian hoặc expedition stamina đi đường; -300 Difficulty cho lần khám phá kỳ ngộ hợp lệ đầu tiên | Expedition travel/event | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Nhặt Gì Cũng Mang | Viễn chinh / cơ duyên | S | Tăng cơ hội phần thưởng thường có nguồn hợp lệ; +10% tiêu hao thể lực vận chuyển ngoài map | Loot source + expedition stamina | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Đụng Gì Cũng Mở | Viễn chinh / cơ duyên | S | Tăng cơ hội tương tác vật thể chưa rõ; rủi ro sự kiện bất lợi qua bảng có thật | Exploration interaction/event | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Thính Tai | Viễn chinh / cơ duyên | H | Giảm Difficulty kiểm tra phát hiện phục kích/bẫy | Detection event | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Xem Bản Đồ Ngược | Viễn chinh / cơ duyên | B | Đường lần đầu có chi phí di chuyển cao; học thuộc đường giảm hoặc xóa phạt | Route familiarity | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Đi Đâu Cũng Đánh Dấu | Viễn chinh / cơ duyên | H | Trên đường đã khám phá giảm 10% expedition stamina cost | Explored-route tracking | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Sợ Ma | Viễn chinh / cơ duyên | B | Gặp địch có tag u linh/hồn ma: -8% sát thương gây ra | Monster tags | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |
| Lì Đòn Khi Lạc Rừng | Viễn chinh / cơ duyên | H | Môi trường rừng khắc nghiệt: -8% thành phần tiêu hao expedition stamina do môi trường | Map environment stamina component | DESIGN CONCEPT / consumer-gated; numeric tuning NOT LOCKED |

**Không trộn Personality/Trait:** tính cách vẫn là thiên hướng AI. Đặc Chất xã hội như `Lắm Chuyện` chỉ active khi có event thực, target thật và ảnh hưởng thực. Hệ ăn uống, lịch nghỉ, social, quái tính, map exploration chưa thể gán buff giả vào work/combat.

## C. 24 Mệnh Cách cá nhân (không tính tổ hợp Mệnh Cục là 1 Mệnh)

| Mệnh Cách | Kênh / luật | Consumer / owner | Điều kiện |
|---|---|---|---|
| Đại Khí Vãn Thành | cultivation_gain −15%; milestone count × RealmBodyCore growth | Realm/Body growth and major-breakthrough history | GATED |
| Hồng Trần Luyện Tâm | breakthrough failure history -> qualifying cultivation/breakthrough rules | Breakthrough V2 / Tâm Kiếp | GATED |
| Phá Quân | All Damage; Defense Penetration; enemy stronger tier; elite/boss kill cooldown alteration | Combat tier/context and kill attribution | COMBAT V2 |
| Thất Sát | personal kill stacks -> All Damage, Attack/Cast Speed | Combat kill attribution, summons exclusion | COMBAT V2 |
| Tham Lang | unique boss/elite first-kill permanent HP and All Damage marks | Unique-boss provenance + stat source | COMBAT+HISTORY |
| Thiên Sát Cô Tinh | solo combat conditional power/survival | Party/solo & combat encounter | COMBAT V2 |
| Gặp Dữ Hóa Lành | lethal interception and calamity survival | Canonical lethal event + significant history | GATED |
| Thiên Quyến Hồng Phúc | meaningful Luck tiers, Đại Cơ Duyên rules | LuckScore + authored event tables | EVENT GATED |
| Thôn Thiên | boss/unique defeat growth | Boss tag, unique history, permanent modifiers | COMBAT+HISTORY |
| Vạn Pháp Quy Nhất | Kiếm/Thể/Pháp participation + skill rotation modifiers | Path history, skill family/tag runtime | SKILL V2 |
| Kiếm Tiên Chuyển Thế | Sword mastery XP, tagged Skill Effect, forced crit on qualifying cast, fixed congenital Sword-path history | Sword style/skill cast/valid birth override | BIRTH PACKAGE GATED |
| Dược Vương Tại Thế | Healing Done/Received; rescue target and ally-save support cooldown | Healer attribution, skill cooldown, cleanse | COMBAT V2 |
| Tài Tinh Nhập Mệnh | LuckScore +1500 in quality task; once/day double eligible rare stackable quantity | Work rare-quality check + canonical output commit | CRAFT QUALITY GATED |
| Bách Kiếp Bất Diệt | unique calamity survival -> permanent HP and Damage Reduction marks | Major calamity tagged event and history | EVENT GATED |
| Thiên Đố Anh Tài | cultivation, learning and profession XP bonuses vs max-lifespan penalty | Age/lifespan + death/Ma-Hồn; full downside | GATED BOTH SIDES |
| Túc Tuệ Chuyển Thế | retain learned mastery/history under rebirth | Ma/Hồn/rebirth loss/retention | FUTURE ONLY |
| Đoạt Mệnh | personally defeat fate-bearing NPC -> bound fragments -> authored Cải Mệnh | Hostile NPC identity, fragments, unique attribution | GATED |
| Hậu Tích Bạc Phát | bank eligible natural cultivation overflow at major gate and apply after success | Breakthrough V2 overflow contract | GATED |
| Nhất Niệm Sinh Vạn Pháp | once/encounter skill echo cast at 60% effect; no recursion | Skill cast source, cooldown, allowed tags | SKILL V2 |
| Tụ Bảo Mệnh | first eligible rare stackable loot per expedition doubles | Expedition + loot reward owner | EXPLORATION GATED |
| Bách Nghệ Quy Tông | unique profession level ≥100 -> XP and work speed permanent marks | Profession levels + unique milestone history | PROFESSION + EVENT |
| Tử Vi Đế Mệnh | team-leader other members Skill Effect/DR and self All Damage/HP | Canonical party leader/encounter roster | TEAM GATED |
| Thiên Cơ Khả Khuy | reveal Difficulty/reward tags; reroute once/expedition | Exploration scenario/route event | EXPLORATION GATED |
| Thiên Công Khai Vật | refund eligible common materials once/day after completed highest-tier crafting | Recipe tags, real spent materials, refund commit | CRAFT GATED |

**Mệnh Cục:** `Sát Phá Lang`, `Phúc Họa Tương Y`, `Vạn Kiếp Hậu Phát`, `Y Kiếm Song Tuyệt`, `Độc Bộ Thiên Hạ`, `Vạn Pháp Nhất Niệm`, `Bách Nghệ Sinh Tài`, `Thôn Thiên Đoạt Mệnh`, `Hậu Tích Thành Khí` là **tổ hợp được tính từ Mệnh Cách đã sở hữu**, không phải nguồn Birth Fate slot độc lập. Tác dụng không được tự cộng trùng những Mệnh thành phần; phải có combo owner/mode riêng khi V2 triển khai.

**Birth fate gate:** xác suất có Mệnh Cách 0,50% được khóa, nhưng `birth_weight` từng ID và các `birth_override` (đặc biệt Kiếm Tiên Chuyển Thế) chưa được chốt đủ để sinh V2 chính thức. Không tự chia đồng đều pool.

## D. Linh Căn và Dị Linh Căn

| Nguồn | Kênh tác động | Consumer |
|---|---|---|
| Kim | Defense Penetration + matching cultivation/mastery/Skill Effect/resistance | Combat Stats, matching root/tagged skills |
| Mộc | Max HP + matching cultivation/mastery/Skill Effect/resistance | Combat Stats, HP-ratio rescale |
| Thủy | Basic Attack Speed + Cast Speed + matching buffs | Combat realtime timing |
| Hỏa | All Damage + matching buffs | Combat outgoing damage |
| Thổ | Defense + matching buffs | Combat mitigation |
| Lôi | Crit Chance, Crit Damage, Thiên Lôi proc | Combat cast attribution, mutation proc |
| Phong | Movement/Cast speed, Phong Thế special cooldown | Combat cast/cooldown pipeline |
| Băng | Effect Hit, Control Duration, Hàn Ấn | Status tagging + stack/trigger |
| Dương | All Damage, DoT Potency, Dương Bạo | DoT and crit/proc safety |
| U Minh | Effect Resistance/DR, Minh Mệnh lethal rules | Incoming + lethal queue |

Mỗi căn base còn có matching-root `cultivation_gain`, `mastery_xp`, `skill_effect`, `elemental_resistance[element]`, theo `P × coefficient × Resonance`. Không tạo generic work buff từ Linh Căn. Một công thức/loài cây ghi rõ tương hợp mới áp dụng conditional Work Speed ×1.05 theo P3.7.

## E. Năm Huyết Mạch bẩm sinh

| Huyết Mạch | Kênh / luật | Consumer |
|---|---|---|
| Chân Long Huyết | ATK/DEF/HP; cultivation; breakthrough; Long Uy; Nghịch Lân | Stat core; breakthrough; HP threshold; encounter trigger |
| Phượng Hoàng Huyết | HP, Healing Done/Received, cultivation, HP/expedition recovery; overheal shield; Niết Bàn | Healing/shield; expedition restoration only where legal; lethal queue |
| Bạch Hổ Huyết | ATK, Crit, Crit Damage, Penetration; Sát Khí; Bạch Hổ Sát | Stats; qualifying kill; critical hit/cast source |
| Huyền Vũ Huyết | DEF/HP/DR/Effect Resistance; Huyền Giáp; control cleanse | Incoming hit threshold; shield; status taxonomy |
| Thao Thiết Tàn Huyết | ATK/HP/healing/expedition stamina; +1 departing Supply; personal-kill sustain | Supply inventory, expedition stamina, qualifying kill, healing cap |

**Gate:** riêng recovery Stamina của Phượng Hoàng/Thao Thiết đọc **Thể Lực Viễn Chinh** chỉ tại các điểm phục hồi/viễn chinh hợp lệ do `BODY_CULTIVATION_V2_SPEC` sở hữu. Không biến hồi Thể Lực thành tăng tốc sản xuất trong tông môn. Niết Bàn cần một lethal queue chung; không tự dựng một death engine bí mật.

## F. Mười lăm Thể Chất cơ bản

| Thể Chất | Kênh / luật | Consumer / readiness |
|---|---|---|
| Kiếm Cốt | No authored effect; weapon sword dependency | BLOCKED: must NOT be in initial birth pool |
| Kim Cương Bá Thể | Body HP/DEF; expedition consumption; anti-chip multiplier | Combat incoming + expedition map |
| Hàn Âm Thể | Water/Ice Skill Effect, Element Resistance, control duration, cold surcharge | Combat element/status + map environment |
| Hỏa Linh Thể | Fire/Yang Skill Effect, resistance, DoT potency, heat surcharge | Combat DoT + map environment |
| Sinh Cơ Linh Thể | Max HP, Healing Received below HP threshold, injury recovery | Combat heal; Injury future gated |
| Trường Sinh Thể | Max HP/DR; lifespan; injury recovery | Combat; Lifespan/Injury gated |
| Tu La Chiến Thể | HP bands -> Direct Damage and Basic Attack Speed | Combat own HP condition |
| Huyết Sát Chi Thể | target-low-HP crit/crit damage; personal kill HP restoration | Combat target HP, kill attribution |
| Ngũ Hành Đạo Thể | base-element Skill Effect/resistance; adjusts counter BONUS portion | Five-element matchup + skill tags |
| Vạn Độc Linh Thể | DoT potency, eligible Effect Hit, incoming DoT reduction | DoT/status damage source |
| Huyền Nguyệt Linh Thể | Effect Hit/Resistance, Control Duration | Control/debuff owner |
| Đấu Chiến Chi Thể | Basic Damage/Speed, filtered Penetration, Crit Resistance | Basic attack pipeline |
| Không Linh Hư Thể | Movement/Cast Speed, travel-component expedition discount | Movement, cast and map-stamina cost tags |
| Vạn Pháp Đạo Thể | Skill Effect, Cast Speed, Cooldown Recovery | Skills and timing |
| Vô Cấu Đạo Thể | All element resistance, Effect Resistance, common-material conversion discount, environment surcharge | Combat + authored body-transformation recipes + map environment |

**Kiếm Cốt exception:** 12% reserved special-type weight, user approved temporary exclusion from initial eligible pool; do not allow generation or activation until weapon requirement and an actual measurable effect are approved. Keep special Physique occurrence 3% for ordinary birth and proportionally normalize weights among **eligible** special types (assuming their own actual effects/consumer requirements are met), not force incomplete bodies into birth.

## G. Quy trình kiểm tra từng định nghĩa trước khi enable

1. Có `source_id`, nature/identity, clear birth vs acquired origin, readiness và conflict group không?
2. Target `channel` / trigger / content tag đã có thẩm quyền không? Không duplicate six foundations/quality/work-power.
3. Có xác định event khi action START/COMPLETE/CAST/HIT/KILL hoặc context work/realm/breakthrough; có data thật?
4. Có thực sự tính được output khác nhau trước/sau, cả lợi và hại của dạng song diện?
5. Thực thi deterministic, save/load no reroll, no double-pay, cooldown/trigger budget, 1,000–3,000 roster?
6. UI chỉ hiển thị đã lộ và thực sự active; không leak danh tính ẩn hoặc trình bày 'hiệu ứng vận hành' khi consumer vắng.
7. Với các pool sinh: có **đầy đủ ID hợp lệ, per-ID `commonality_weight`/`birth_weight`, conflicts, đã được user duyệt** không? Nếu không, khóa luồng quay tên; không dùng equal-weight mặc định.

## H. Triển khai sau ma trận

- **Bước 1:** duyệt `docs/DISCIPLE_V2_STAT_CAUSAL_CONTRACT.md` và giải quyết các phép tính còn thiếu.
- **Bước 2:** hoàn thiện code-owned Combat Stats, Work result channels, action/event owner theo phase có gate (không đồng thời làm tất cả hệ).
- **Bước 3:** test mỗi source trên một action thật; migrate Trait grade legacy ra khỏi V2; giữ profession talent grade.
- **Bước 4:** sinh/lưu toàn bộ approved innate identity trong **một** hồ sơ; hidden IDs không reveal/reroll, content chưa kích hoạt không buff; áp dụng pool birth **chỉ khi người dùng khóa bảng weight chi tiết**.

**Không có thay đổi gameplay code hoặc Godot 4.7.2 gate trong lần audit này.**
