# P3.7 — CÂY CÔNG TRÌNH TÔNG MÔN V1

Status: CANONICAL DESIGN AUTHORITY  
Date: 2026-10-05  
Parent authority: `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`

Mục tiêu của file này là khóa bộ xương công trình dài hạn cho Tông Môn Bá Đạo.

Không được biến nội dung dưới đây thành số UI giả. P3.4 vẫn đúng: presentation chỉ được hiển thị level, queue, capacity, production, upgrade khi simulation/runtime đã có authority thật tương ứng.

---

# 1. Triết lý cây công trình

Game hướng tới:
- 1.000–3.000 đệ tử;
- khoảng 70% đệ tử hoạt động ngoài tông/săn quái;
- khoảng 30% làm hậu phương;
- người chơi quản theo chính sách, đội, đường khẩu và công trình;
- không micro từng worker.

Công trình chia thành 7 hệ:

1. **Quản trị** — Đại Điện, Kho, Đệ Tử Xá.
2. **Tài nguyên** — Linh Điền, Mỏ Linh Khoáng, Linh Lâm.
3. **Tu luyện/hồi phục** — Tu Luyện Đài, Mật Thất, Y Quán.
4. **Chế tạo** — Luyện Đan, Luyện Khí, Phù Lục, Trận Pháp.
5. **Săn quái/hậu cần** — Săn Yêu Điện, Hậu Cần Điện, Cổng Tông Môn.
6. **Linh thú/huấn luyện** — Ngự Thú Viện, Diễn Võ Trường, Tàng Kinh Các.
7. **Kinh tế/đời sống** — Phường Thị, Tửu Phường, Linh Trù Phòng, Hoa Phường, Hồng Trần Phường, Đấu Giá Các.

Không mở toàn bộ từ đầu.

---

# 2. Luật cấp công trình

## 2.1 Mỗi instance Lv.1–100

Mỗi công trình bình thường có:
- Lv.1–100;
- cấp thường tăng chỉ số;
- mốc lớn mở cơ chế;
- Lv.100 là trạng thái hoàn thiện của instance đó.

Không dùng Mỏ Lv.8.000.

Quy mô dài hạn tăng bằng:
- nhiều instance hơn;
- nhiều đất hơn;
- nhiều worker hơn;
- nhiều tuyến sản xuất;
- nhiều đội săn;
- Tông Môn lớn hơn.

---

## 2.2 Mốc cơ chế mặc định

Các mốc chuẩn:

- Lv.1 — chức năng nền;
- Lv.10 — tự động hóa cấp 1;
- Lv.20 — mở nhánh/chức năng thứ hai;
- Lv.30 — tăng khả năng xử lý tài nguyên cao;
- Lv.50 — cơ chế chuyên sâu;
- Lv.75 — cơ chế hiếm/cao cấp;
- Lv.100 — hoàn thiện, nhận bonus Mastery của instance.

Một số công trình đặc biệt có thể đổi mốc nhưng phải giữ logic tương đương.

---

# 3. Luật số lượng công trình

## 3.1 Công trình độc nhất

Các công trình sau mặc định chỉ có một trung tâm chính:
- Đại Điện;
- Cổng Tông Môn;
- Săn Yêu Điện;
- Tàng Kinh Các;
- Đấu Giá Các.

Có thể mở chi nhánh/chức năng phụ sau này nhưng không spam nhiều bản sao giống nhau.

## 3.2 Công trình sản xuất/dịch vụ

Có thể có nhiều instance:
- Linh Điền;
- Mỏ;
- Linh Lâm;
- Kho;
- Đệ Tử Xá;
- Mật Thất;
- Y Quán;
- Luyện Đan;
- Luyện Khí;
- Phù Lục;
- Ngự Thú;
- Hậu Cần;
- Tửu Phường;
- v.v.

### Quy tắc mở thêm instance

Ví dụ một họ công trình có trần ban đầu 10 instance.

Khi:
- toàn bộ 10 instance đã Lv.100;
- Tông Môn đủ điều kiện đất/quản trị;

thì mở instance thứ 11.

Khi 11 instance cùng đạt điều kiện hoàn thiện:
- mở instance thứ 12.

Cơ chế này có thể tiếp tục.

Không bắt buộc mọi họ công trình đều bắt đầu ở 10; con số ban đầu là dữ liệu cân bằng.

---

# 4. Luật worker slot

## 4.1 Công trình khai thác

Mặc định:
- Lv.1: 2 worker;
- mỗi 5 level: +1 worker;
- Lv.100: khoảng 22 worker/instance.

Đây là default, từng loại có thể chỉnh.

## 4.2 Công trình chế tạo

Mặc định:
- Lv.1: 2 worker;
- mỗi 10 level: +1 worker;
- Lv.100: khoảng 12 worker.

Một worker nghề cao có thể có giá trị hơn nhiều worker nghề thấp.

## 4.3 Công trình dịch vụ

Dùng capacity riêng:
- giường bệnh;
- phòng Mật Thất;
- chỗ nghỉ;
- số đội được điều phối;
- lượng khách;
- throughput.

---

# 5. Luật nguyên liệu xây dựng chung

## 5.1 Ba đầu vào thường xuyên

Mọi upgrade thông thường chủ yếu dùng:

### Linh Mộc
Nhóm vật liệu:
- gỗ;
- linh mộc;
- rễ/cốt thực vật;
- vật liệu hữu cơ xây dựng.

### Khoáng Liệu
Nhóm:
- đá;
- quặng;
- kim loại;
- vật liệu chịu lực;
- vật liệu yêu thú tương thích nếu recipe cho phép.

### Linh Thạch
Dùng cho:
- nhân công;
- kích hoạt linh năng;
- trận pháp;
- chi phí kinh tế.

---

# 6. Tài nguyên xây dựng theo loại + số lượng

Mỗi nguyên liệu có:
- resource ID;
- family/tag;
- realm/tier;
- số lượng.

Upgrade không dùng Phẩm Lực.

Ví dụ:
- Linh Mộc x120;
- Thanh Thiết x80;
- Linh Thạch x500.

Level/công trình cao hơn có thể yêu cầu resource ID cấp cao hơn.

Warehouse rules vẫn có thể:
- khóa item quý;
- đặt reserve;
- cấm auto-consume một resource;
- chọn resource hợp lệ theo family khi recipe cho phép.

Không quy đổi nhiều loại vật liệu thành một hidden power pool.

---

# 7. Đường cong chi phí upgrade V1

Để tránh viết 100 recipe riêng cho mỗi building, mỗi họ công trình có 3 hệ số nền:

- BaseWood;
- BaseOre;
- BaseStone.

Upgrade từ Lv.L -> Lv.L+1 dùng hệ số tăng:

**F(L) = 1 + 0.15 × L + 0.01 × L²**

Chi phí:
- Linh Mộc quantity = ceil(BaseWood × F(L));
- Khoáng quantity = ceil(BaseOre × F(L));
- Linh Thạch = ceil(BaseStone × F(L)).

Milestone upgrade:
- dùng chi phí thường × 2;
- cộng 1 vật liệu/chìa khóa chuyên dụng.

Đây là công thức khởi đầu để cân bằng, chưa phải con số kinh tế cuối cùng.

---

# 8. Vật liệu milestone

Level thường:
- chỉ Mộc + Khoáng + Linh Thạch.

Mốc lớn:
- thêm 1 vật liệu/chìa khóa mang chủ đề của building.

Ví dụ:
- Linh Điền -> Linh Tuyền Chi Tâm / Linh Thổ;
- Mỏ -> Tầm Mạch Bàn / Trấn Mạch Trụ;
- Mật Thất -> Trận Tâm / Linh Ngọc;
- Luyện Đan -> Địa Hỏa Tâm / Đan Lô Tâm;
- Luyện Khí -> Lô Tâm / Thiên Hỏa;
- Ngự Thú -> Thú Hạch / Ngự Thú Ấn;
- Săn Yêu -> boss token / bản đồ vùng / trinh sát vật phẩm.

Mục tiêu:
- PvE cung cấp chìa khóa phát triển hậu phương;
- không tạo thêm 100 loại currency thường trực.

---

# 9. Năng lực xử lý theo tier/content

Công trình sản xuất/chế tạo không dùng Ngưỡng Xử Lý Phẩm Lực.

Khả năng xử lý được biểu diễn bằng:
- building level;
- profession level;
- recipe/crop unlock;
- explicit realm/tier requirement;
- tool/formation/buff khi content yêu cầu.

Nếu content khó hơn capability hiện tại, hệ có thể:
- tăng thời gian;
- giảm success;
- tăng cost;
- hoặc chưa mở recipe/crop.

Không dùng một continuous PL threshold.

---

# 10. ĐẠI ĐIỆN

Loại: độc nhất / quản trị.

## Chức năng
- trung tâm Tông Môn;
- policy;
- giới hạn đệ tử;
- giới hạn đất;
- giới hạn nhóm/đội;
- quy mô tổ chức;
- uy danh;
- mở chức năng quản trị.

## Đầu vào
Không sản xuất hàng hóa.

Upgrade:
- Linh Mộc;
- Khoáng Liệu;
- Linh Thạch;
- milestone: Ấn Tông Chủ / Trận Tâm quản trị / vật liệu danh vọng tương ứng.

## Nghề
Có thể sử dụng:
- Quản Sự;
- Chấp Sự;
- về sau là nghề quản trị.

Không bắt buộc ở phase đầu.

## Tăng cấp thường
- dung lượng quản trị;
- số policy;
- tốc độ xử lý yêu cầu;
- giới hạn số đội/đường khẩu;
- uy danh nội bộ.

## Milestone

### Lv.1
- policy cơ bản;
- tuyển/giữ đệ tử;
- workforce cơ bản.

### Lv.10
- mở policy lương/bổng lộc;
- policy phân chia chiến lợi phẩm;
- phân tầng Ngoại Môn/Nội Môn cơ bản.

### Lv.20
- mở policy tự phân trang bị;
- priority giữa sản xuất / tu luyện / săn quái.

### Lv.30
- mở các Đường/Viện quy mô lớn;
- cho phép quản lý hàng trăm đệ tử theo nhóm.

### Lv.50
- mở quy chế Chân Truyền/Trưởng Lão;
- policy discount Mật Thất/dịch vụ theo thân phận.

### Lv.75
- mở quản lý phân khu/lãnh địa;
- chuẩn bị chi nhánh/phân tông.

### Lv.100
- Đại Điện hoàn thiện;
- bonus quản trị toàn tông;
- mở yêu cầu nâng tầm Tông Môn/lãnh địa thay vì tăng Lv.101.

## Liên kết PvE
- giới hạn số đội săn;
- loot split;
- policy rút lui;
- ưu tiên trang bị.

---

# 11. KHO TÔNG MÔN

Loại: nhiều instance / hạ tầng.

## Chức năng
- chứa nguyên liệu;
- chiến lợi phẩm;
- trang bị chưa cấp phát;
- hàng bán;
- hàng reserve.

## Input/output
Input:
- mọi hàng hợp lệ.

Output:
- production;
- construction;
- market;
- hunter supply;
- disciple allocation.

## Nghề
- Kho Vận;
- Định Giá hỗ trợ.

## Cấp thường
- tốc độ nhập/xuất;
- tốc độ phân loại;
- số rule reserve;
- tốc độ auto-routing/hậu cần.

**Không có giới hạn sức chứa kho thường.** Commodity stack có thể tăng đến quy mô rất lớn.

## Milestone

Lv.1:
- lưu trữ tài nguyên không giới hạn dung lượng số học thông thường;
- thao tác kho cơ bản.

Lv.10:
- auto sort theo nhóm.

Lv.20:
- reserve threshold theo tài nguyên.

Lv.30:
- khóa auto-consume vật phẩm quý.

Lv.50:
- tự cấp nguyên liệu cho production/hậu cần.

Lv.75:
- overflow tự chuyển Phường Thị theo policy.

Lv.100:
- mạng kho liên kết;
- nhiều kho hoạt động như một logic inventory đối với UI;
- routing/hậu cần tự động cấp cao.

## Specialty
- Không Gian Thạch;
- Trữ Vật Trận Tâm.

## PvE
- nhận trực tiếp vật liệu/item hunting reward theo main Sect Warehouse authority.

---

# 12. ĐỆ TỬ XÁ

## Chức năng
- chỗ ở;
- hồi thể lực;
- hồi trạng thái nhẹ;
- ảnh hưởng tâm trạng/ổn định;
- capacity dân số thực.

## Nghề
- không cần worker chính;
- có thể có Quản Sự/Phục Vụ sau này.

## Cấp thường
- giường;
- tốc độ hồi stamina;
- comfort;
- khả năng tự phân phòng.

## Milestone

Lv.1:
- nghỉ cơ bản.

Lv.10:
- auto bed assignment.

Lv.20:
- phòng Nội Môn / comfort cao hơn.

Lv.30:
- hồi Thương Thế nhẹ khi nghỉ lâu.

Lv.50:
- phòng riêng cho nhóm ưu tiên;
- buff tâm trạng.

Lv.75:
- khu tĩnh dưỡng cao cấp.

Lv.100:
- giảm downtime toàn bộ cư dân của instance.

## Specialty
- An Thần Mộc;
- Tĩnh Tâm Ngọc.

---

# 13. LINH ĐIỀN

Loại: sản xuất / nhiều instance.

## Chức năng
- Linh Thảo;
- Linh Cốc;
- Linh Hoa;
- cây nguyên liệu khác.

## Đầu vào
- hạt giống/cây giống;
- thời gian;
- worker;
- tùy crop có phụ liệu.

Không yêu cầu người chơi bấm tưới/thu hoạch.

## Đầu ra
- thực vật có Phẩm Lực;
- hạt giống;
- dị biến;
- sản phẩm hiếm.

## Nghề
- Linh Thực.

## Cấp thường
- sản lượng;
- worker slot;
- tốc độ tăng trưởng;
- Ngưỡng Xử Lý PL;
- tỷ lệ mở/thu được giống hoặc nguyên liệu thuộc cảnh giới phẩm cao hơn.

## Milestone

Lv.1:
- trồng cây phổ thông;
- 2 worker.

Lv.10:
- tưới tự động;
- giảm thao tác;
- mở crop policy.

Lv.20:
- luân canh/tối ưu đất;
- tăng seed recovery.

Lv.30:
- cây có PL cao hơn ít bị penalty;
- mở Linh Hoa/nhóm cây chuyên dụng.

Lv.50:
- biến dị giống;
- có xác suất thu giống đặc biệt.

Lv.75:
- Linh Tuyền nội bộ;
- tăng tỷ lệ sản phẩm hiếm.

Lv.100:
- Linh Điền Đại Thành;
- bonus Phẩm Lực đầu ra;
- tăng EXP Linh Thực cho worker.

## Specialty
- Linh Tuyền Chi Tâm;
- Linh Thổ Tinh Hoa;
- Mộc Hệ Trận Tâm.

## PvE
PvE mang về:
- hạt giống hiếm;
- linh thổ;
- dịch yêu thú làm phân;
- kỳ hoa/dị thảo.

---

# 14. MỎ LINH KHOÁNG

## Chức năng
- quặng;
- đá;
- kim loại;
- mảnh Linh Thạch;
- khoáng hiếm.

## Nghề
- Khai Khoáng.

## Cấp thường
- sản lượng;
- độ sâu;
- worker;
- tỷ lệ khoáng hiếm;
- Ngưỡng Xử Lý PL;
- khả năng tiếp cận loại khoáng thuộc cảnh giới phẩm cao hơn.

## Milestone

Lv.1:
- khai thác tầng nông.

Lv.10:
- sàng lọc tự động;
- giảm phế liệu.

Lv.20:
- thăm dò mạch;
- chọn ưu tiên loại khoáng.

Lv.30:
- xuống tầng sâu;
- mở rare-vein event.

Lv.50:
- Trận Pháp Tầm Mạch;
- tăng phát hiện khoáng hiếm.

Lv.75:
- mạch Linh Thạch;
- xác suất đặc biệt.

Lv.100:
- Mỏ Đại Thành;
- bonus rare find + EXP nghề.

## Specialty
- Tầm Mạch Bàn;
- Trấn Mạch Trụ;
- Địa Mạch Tinh.

## PvE
PvE có thể mang:
- bản đồ khoáng mạch;
- quặng hiếm;
- boss mineral core.

---

# 15. LINH LÂM

## Chức năng
- Linh Mộc;
- nhựa;
- quả;
- nấm;
- thực vật phụ;
- habitat cho linh thú.

## Nghề
- Lâm Nghiệp;
- Thu Thập.

## Cấp thường
- tốc độ tái sinh;
- sản lượng;
- worker;
- tỷ lệ cổ mộc;
- tier gỗ có thể khai thác.

## Milestone

Lv.1:
- gỗ và thu thập cơ bản.

Lv.10:
- tái trồng tự động.

Lv.20:
- phân khu loại cây.

Lv.30:
- mở cổ mộc/non-standard resource.

Lv.50:
- hệ sinh thái Linh Thú;
- synergy với Ngự Thú Viện.

Lv.75:
- rare spirit-tree event.

Lv.100:
- Thánh Lâm;
- bonus sản lượng Linh Mộc + EXP nghề.

## Specialty
- Mộc Tâm;
- Cổ Thụ Chi Tâm;
- Sinh Mệnh Linh Dịch.

---

# 16. TU LUYỆN ĐÀI

Loại: dịch vụ chung.

## Vai trò
- nơi tu luyện tập trung miễn phí/được Tông Môn tài trợ;
- thấp hơn Mật Thất về hiệu quả tối đa;
- scale cho số đông.

## Input
- linh khí Tông Môn;
- có thể dùng Linh Thạch Tông Môn nếu policy bật chế độ tăng cường.

## Output
- Tu Vi;
- cảm ngộ;
- group cultivation events.

## Nghề
- Giảng Đạo có thể tăng hiệu suất.

## Cấp thường
- số chỗ;
- multiplier tu luyện;
- Ngưỡng Linh Khí;
- comprehension chance.

## Milestone

Lv.1:
- tu luyện tập trung.

Lv.10:
- tự xếp chỗ theo priority.

Lv.20:
- giảng đạo/instructor bonus.

Lv.30:
- cộng hưởng nhóm cùng công pháp.

Lv.50:
- Tụ Linh Trận tích hợp.

Lv.75:
- chance Cảm Ngộ Tập Thể.

Lv.100:
- buff Tu Vi toàn bộ người dùng + tăng EXP Giảng Đạo.

## Specialty
- Tụ Linh Trận Tâm;
- Ngộ Đạo Thạch.

---

# 17. MẬT THẤT

Loại: dịch vụ cá nhân trả phí.

## Vai trò
Đệ tử dùng **Linh Thạch cá nhân** để thuê và tăng mạnh tốc độ tu luyện.

## Input
- Linh Thạch cá nhân;
- linh khí;
- capacity phòng.

## Output
- Tu Vi cá nhân;
- doanh thu Tông Môn.

## AI
Đệ tử tự quyết dựa trên:
- tiền;
- tính cách;
- mục tiêu;
- policy;
- discount thân phận.

## Cấp thường
- số phòng;
- multiplier tu luyện;
- hiệu suất Linh Thạch;
- comfort;
- mức PL/cảnh giới phục vụ hiệu quả.

## Milestone

Lv.1:
- phòng thường.

Lv.10:
- đặt giá/discount tự động.

Lv.20:
- phòng nhiều mức giá.

Lv.30:
- phòng chuyên công pháp/thuộc tính.

Lv.50:
- Trận Tụ Linh cao cấp.

Lv.75:
- phòng Ngộ Đạo;
- chance cảm ngộ nhỏ.

Lv.100:
- tiểu động phủ;
- hiệu suất tiền/Tu Vi rất cao.

## Specialty
- Trận Tâm;
- Linh Ngọc;
- Không Gian Thạch ở mốc cao.

---

# 18. Y QUÁN

## Vai trò
- hồi Thương Thế;
- chữa trạng thái;
- hồi stamina;
- tự động triage hunter trở về.

## Input
- thuốc;
- đan;
- vật tư y tế;
- worker.

## Output
- giảm Thương Thế;
- giảm downtime;
- cứu đội săn quay vòng nhanh.

## Nghề
- Y Thuật.

## Cấp thường
- giường;
- tốc độ hồi;
- hiệu quả thuốc;
- worker;
- emergency capacity.

## Milestone

Lv.1:
- trị thương cơ bản.

Lv.10:
- auto triage.

Lv.20:
- policy mức thuốc được phép tiêu.

Lv.30:
- xử lý trọng thương.

Lv.50:
- chữa debuff/độc/phản phệ.

Lv.75:
- emergency stabilization khi đội về trong tình trạng cực xấu.

Lv.100:
- Đại Y Viện;
- giảm đáng kể thời gian nghỉ toàn Tông.

## Specialty
- Sinh Cơ Ngọc;
- Y Đạo Linh Tâm;
- rare monster organ/material.

---

# 19. LUYỆN ĐAN ĐIỆN

## Input
- Linh Thảo;
- Yêu Đan;
- monster materials;
- phụ liệu;
- Linh Thạch/nhiên liệu khi recipe yêu cầu.

## Output
- đan Tu Vi;
- đan hồi phục;
- đan phá cảnh;
- buff hunting;
- thuốc nghề.

## Nghề
- Luyện Đan.

## Cấp thường
- batch size;
- speed;
- success;
- output quantity;
- worker;
- recipe/tier capability.

## Milestone

Lv.1:
- đan cơ bản.

Lv.10:
- queue tự động theo reserve.

Lv.20:
- multi-material recipe.

Lv.30:
- xử lý Yêu Đan.

Lv.50:
- phẩm chất/đặc tính phụ.

Lv.75:
- rare pill outcome;
- giảm hao hụt.

Lv.100:
- Đan Đạo Đại Thành;
- bonus chance đan cực phẩm + EXP nghề.

## Specialty
- Địa Hỏa Tâm;
- Đan Lô Tâm;
- Thiên Hỏa.

## PvE
PvE là nguồn Yêu Đan, hỏa chủng, dược liệu hiếm và recipe.

---

# 20. LUYỆN KHÍ ĐIỆN

## Input
- Khoáng;
- Linh Mộc;
- monster materials;
- existing gear để repair/reforge;
- Linh Thạch.

## Output
- vũ khí;
- giáp;
- công cụ nghề;
- túi/thiết bị hậu cần;
- trang bị đặc biệt.

## Nghề
- Luyện Khí.

## Cấp thường
- speed;
- success;
- durability;
- PL output;
- worker;
- repair throughput.

## Milestone

Lv.1:
- craft/repair cơ bản.

Lv.10:
- auto repair policy cho hunter.

Lv.20:
- tinh luyện vật liệu.

Lv.30:
- monster-material forging.

Lv.50:
- reforge/đặc tính phụ.

Lv.75:
- set/special effect chance.

Lv.100:
- Khí Đạo Đại Thành;
- rare affix chance + EXP nghề.

## Specialty
- Lô Tâm;
- Hỏa Chủng;
- Thiên Ngoại Khoáng.

---

# 21. SĂN YÊU ĐIỆN

Loại: độc nhất / command hub của PvE.

## Vai trò
- lập đội;
- chọn vùng;
- chọn target;
- risk posture;
- retreat threshold;
- loot split;
- auto redeploy;
- hunting reports.

## Nghề
- Săn Yêu;
- Thám Hiểm;
- đội trưởng/captain traits.

## Cấp thường
- số đội đồng thời;
- chất lượng trinh sát;
- auto assignment;
- report detail;
- rare-target detection.

## Milestone

Lv.1:
- đội 5 người;
- săn vùng cơ bản.

Lv.10:
- auto re-dispatch nếu đội khỏe/đủ supply.

Lv.20:
- target priority;
- farm vật liệu cụ thể.

Lv.30:
- scouting;
- hiển thị ước lượng rủi ro tốt hơn.

Lv.50:
- elite hunt;
- chain hunt.

Lv.75:
- boss contract;
- rare spawn intelligence.

Lv.100:
- Đại Săn Yêu Điện;
- điều phối quy mô lớn;
- bonus coordination cho tất cả đội.

## Specialty
- Yêu Vương Lệnh;
- Thú Vực Đồ;
- boss trophy.

---

# 22. HẬU CẦN ĐIỆN

## Vai trò
Biến kho Tông Môn thành loadout thực tế cho đội săn.

## Input
- đan;
- thuốc;
- thức ăn;
- phù;
- spare equipment;
- túi chứa.

## Output
- hunting supply packs;
- repair kits;
- carrying capacity;
- auto restock.

## Nghề
- Hậu Cần;
- Kho Vận.

## Cấp thường
- số đội phục vụ;
- tốc độ chuẩn bị;
- carry bonus;
- giảm lãng phí supply.

## Milestone

Lv.1:
- supply cơ bản.

Lv.10:
- auto loadout theo vùng.

Lv.20:
- reserve emergency medicine.

Lv.30:
- bag optimization.

Lv.50:
- route-specific supply profiles.

Lv.75:
- remote cache / tiếp tế tiền tuyến.

Lv.100:
- mạng hậu cần hoàn chỉnh;
- giảm downtime đội săn.

## Specialty
- Trữ Vật Hạch;
- Hư Không Túi;
- Vận Chuyển Trận Tâm.

---

# 23. CỔNG TÔNG MÔN

Loại: độc nhất / luồng ra vào.

## Vai trò
- departure/return;
- bảo vệ;
- traffic;
- world access;
- về sau truyền tống.

## Nghề
- Hộ Pháp;
- Guard duty.

## Cấp thường
- throughput;
- security;
- travel prep;
- return processing.

## Milestone

Lv.1:
- ra/vào cơ bản.

Lv.10:
- auto departure queue.

Lv.20:
- kiểm tra supply trước khi đi.

Lv.30:
- bảo hộ khi returning wounded.

Lv.50:
- Truyền Tống Trận cự ly gần.

Lv.75:
- network travel.

Lv.100:
- Đại Giới Môn;
- giảm mạnh travel overhead.

## Specialty
- Không Gian Thạch;
- Truyền Tống Trận Tâm.

---

# 24. PHƯỜNG THỊ

## Vai trò
- bán hàng thừa;
- khách ngoài Tông;
- đệ tử mua hàng/dịch vụ;
- giá thị trường;
- tạo Linh Thạch mới từ thương nhân ngoài.

## Nghề
- Thương Mậu;
- Định Giá.

## Input
- goods từ kho;
- hàng craft;
- loot.

## Output
- Linh Thạch;
- hàng nhập;
- market intelligence.

## Cấp thường
- traffic;
- số loại hàng;
- spread;
- giá bán;
- merchant quality;
- transaction throughput.

## Milestone

Lv.1:
- bán hàng cơ bản.

Lv.10:
- auto-sell vượt reserve.

Lv.20:
- buy order.

Lv.30:
- thương nhân cao cấp.

Lv.50:
- hợp đồng số lượng lớn.

Lv.75:
- rare merchant.

Lv.100:
- Đại Phường Thị;
- mở điều kiện Đấu Giá Các.

## Specialty
- Tụ Bảo Ngọc;
- Thương Hội Lệnh.

---

# 25. PHÙ LỤC ĐIỆN

## Vai trò
Tạo consumable PvE/utility.

## Output
- damage talisman;
- shield talisman;
- escape talisman;
- healing support;
- mining/farming utility talisman về sau.

## Nghề
- Phù Lục.

## Milestone

Lv.1:
- phù cơ bản.

Lv.10:
- auto craft reserve.

Lv.20:
- team loadout policy.

Lv.30:
- multi-effect.

Lv.50:
- high-PL talisman.

Lv.75:
- rare inscription.

Lv.100:
- Phù Đạo Đại Thành.

## Specialty
- Phù Cốt;
- Linh Mực Tinh Hoa;
- Lôi/Hỏa/etc core.

---

# 26. TRẬN PHÁP ĐIỆN

## Vai trò
- nghiên cứu/duy trì trận;
- global sect formations;
- expedition formation;
- tăng hiệu suất building.

## Nghề
- Khắc Trận / Trận Pháp.

## Milestone

Lv.1:
- trận cơ bản.

Lv.10:
- Tụ Linh/Phòng Hộ module.

Lv.20:
- formation buff cho production.

Lv.30:
- hunting formation preset.

Lv.50:
- đại trận Tông Môn.

Lv.75:
- multi-building resonance.

Lv.100:
- Trận Đạo Đại Thành;
- formation overhead giảm mạnh.

## Specialty
- Trận Tâm;
- Linh Ngọc;
- boss crystal.

---

# 27. NGỰ THÚ VIỆN

## Vai trò
- nuôi/tame linh thú;
- thú chiến;
- mount;
- thú vận tải;
- pet support.

## Input
- thức ăn;
- monster materials;
- thú non/trứng;
- Yêu Đan.

## Nghề
- Thuần Thú;
- Nuôi Dưỡng;
- Thú Y.

## Milestone

Lv.1:
- nuôi thú thường.

Lv.10:
- auto feeding.

Lv.20:
- thú vận tải tăng sức chở supplies/logistics cho đội khi ở ngoài tông môn.

Lv.30:
- thú chiến.

Lv.50:
- breeding/trait inheritance.

Lv.75:
- rare evolution.

Lv.100:
- Vạn Thú Viện;
- global beast growth bonus.

## Specialty
- Ngự Thú Ấn;
- Thú Vương Hạch;
- rare blood essence.

---

# 28. DIỄN VÕ TRƯỜNG

## Vai trò
- luyện combat không cần ra ngoài;
- tăng mastery;
- team synergy;
- thử đội hình.

## Input
- thời gian;
- stamina;
- có thể tốn repair nhẹ.

## Output
- mastery;
- synergy;
- một phần Tu Vi;
- không có loot.

## Nghề
Không phải nghề hậu cần; liên quan combat mastery.

## Milestone

Lv.1:
- đấu tập.

Lv.10:
- auto spar.

Lv.20:
- team drills.

Lv.30:
- counter training.

Lv.50:
- simulated elite enemies.

Lv.75:
- formation combat.

Lv.100:
- Đại Diễn Võ;
- training efficiency bonus toàn Tông.

---

# 29. TÀNG KINH CÁC

Loại: độc nhất.

## Vai trò
- lưu công pháp;
- truyền thừa;
- học/kế thừa skill;
- nghiên cứu/giảng đạo.

## Input
- manuals;
- technique fragments;
- contribution;
- thời gian.

## Output
- skill access;
- mastery growth;
- teaching.

## Nghề
- Giảng Đạo;
- Nghiên Cứu về sau.

## Milestone

Lv.1:
- lưu/học công pháp.

Lv.10:
- recommendation AI.

Lv.20:
- auto learning theo role/policy.

Lv.30:
- instructor system.

Lv.50:
- repair incomplete manual.

Lv.75:
- combine/derive insight.

Lv.100:
- Tàng Kinh Đại Thành;
- global technique learning bonus.

## Specialty
- Ngộ Đạo Thạch;
- Truyền Thừa Ngọc.

---

# 30. TỬU PHƯỜNG

## Vai trò
- Linh Cốc/Linh Quả -> Linh Tửu;
- đệ tử tự tiêu tiền;
- mood/stress;
- một số rượu tăng Tu Vi/buff.

## Nghề
- Nấu Rượu.

## Milestone
Lv.1 basic brewing.
Lv.10 auto stock.
Lv.20 spirit wine.
Lv.30 aged wine.
Lv.50 special buffs.
Lv.75 rare recipe.
Lv.100 Wine Grandmaster facility bonus.

## PvE
monster fruit, rare water, beast blood may unlock special brews.

---

# 31. LINH TRÙ PHÒNG

## Vai trò
- Linh Cốc + thịt quái + nguyên liệu -> món ăn;
- stamina;
- recovery;
- expedition buff.

## Nghề
- Nấu Ăn.

## Milestone
Lv.1 meal.
Lv.10 auto meal policy.
Lv.20 hunter ration.
Lv.30 feast buff.
Lv.50 medicinal cuisine.
Lv.75 rare monster cuisine.
Lv.100 global food efficiency bonus.

---

# 32. HOA PHƯỜNG

## Vai trò
- Linh Hoa -> quà/hương/trang trí;
- disciple spending;
- relationship gameplay;
- mood.

## Nghề
- Linh Thực/Thủ Công tùy recipe.

## Milestone
Lv.1 flowers.
Lv.10 auto stock.
Lv.20 gift crafting.
Lv.30 relationship preferences.
Lv.50 premium incense.
Lv.75 rare social items.
Lv.100 relationship-service bonus.

---

# 33. HỒNG TRẦN PHƯỜNG

## Vai trò
Dịch vụ giải trí cao cấp, không mô tả tình dục.

AI sử dụng theo:
- tính cách;
- mood;
- wealth;
- policy.

## Output
- giảm stress;
- tăng mood;
- tiêu Linh Thạch cá nhân;
- có thể tạo thói quen/trait dài hạn.

## Mốc
Tập trung vào:
- capacity;
- service quality;
- luxury tiers;
- AI behavior.

Không phải gameplay bắt buộc.

---

# 34. ĐẤU GIÁ CÁC

Loại: độc nhất / late economy.

## Vai trò
- mua/bán item giá trị cao;
- NPC bidders;
- disciple personal bidding;
- sect bidding;
- rare rotating supply.

## Input/output
- Linh Thạch;
- rare items;
- treasures;
- manuals.

## Milestone
Lv.1 local auction.
Lv.10 better buyers.
Lv.20 remote bidders.
Lv.30 rare catalog.
Lv.50 region-wide.
Lv.75 cross-region.
Lv.100 top-tier auction network.

## Specialty
- Thương Hội Lệnh;
- Không Gian/Truyền Tin artifact.

---

# 35. CHÍ BẢO TÔNG MÔN

Không cần active slot nhỏ.

Tất cả Chí Bảo sở hữu có thể đóng góp hiệu ứng.

UI tổng hợp:
- Tu Vi;
- ATK;
- DEF;
- HP;
- EXP nghề;
- sản lượng;
- loot;
- market;
- healing;
- travel.

Chí Bảo trùng:
- tăng Cộng Minh;
- dùng fragment để nuôi;
- không trở thành đồ rác vô dụng.

Có thể thêm **Chí Bảo Các** sau này nếu cần chức năng:
- giám định;
- cộng minh;
- bảo dưỡng;
nhưng không dùng để giới hạn số Chí Bảo active.

---

# 36. CÂY PHỤ THUỘC CỐT LÕI

## Giai đoạn gốc
Đại Điện
-> Kho
-> Đệ Tử Xá
-> Linh Điền
-> Mỏ
-> Tu Luyện Đài
-> Cổng Tông Môn

## Hậu phương săn quái
Mỏ + Linh Điền
-> Y Quán
-> Luyện Đan
-> Luyện Khí
-> Hậu Cần
-> Săn Yêu Điện

## Kinh tế
Kho + sản lượng dư
-> Phường Thị
-> Tửu Phường / Linh Trù / Hoa Phường
-> Đấu Giá Các

## Cao cấp
Linh Lâm + săn quái
-> Phù Lục
-> Trận Pháp
-> Ngự Thú

## Tu luyện cao cấp
Tu Luyện Đài + Linh Thạch
-> Mật Thất
-> Tàng Kinh Các
-> Diễn Võ

Không hard-lock tuyệt đối theo thứ tự này; đây là dependency logic để UX dễ hiểu.

---

# 37. QUAN HỆ 70% SĂN / 30% HẬU PHƯƠNG

30% ở nhà phải phục vụ trực tiếp 70% bên ngoài.

### Hậu phương tạo
- thuốc;
- đan;
- food;
- equipment;
- repair;
- phù;
- formation;
- thú vận tải;
- sức chở supplies/logistics cho đội ngoài tông môn;
- healing;
- cultivation;
- market income.

### Hunter mang về
- Linh Thạch;
- Yêu Đan;
- monster parts;
- rare herbs;
- rare ore;
- item;
- manuals;
- specialty milestone components;
- treasure fragments.

Nếu một building không liên kết được với ít nhất một trong hai vòng trên, phải xem lại có cần tồn tại không.

---

# 37A. RÈN THÂN ĐƯỜNG — LOCK 10/10/2026

Đây là **công trình riêng**, không dùng slot của Tu Luyện Đài và không phải Diễn Võ Trường. Chức năng giai đoạn đầu:

- Lv1: **2 slot** luyện thể chuyên dụng.
- Một lượt huấn luyện hợp lệ: **1 phút mô phỏng**, tiêu hao **1 Linh Thạch Tông Môn**, trước khi cấp **1.500 EXP Luyện Thể nền**.
- Người tập phải là đệ tử V2 thực, có phân công/slot hợp lệ, đang ở Tông Môn, còn sống và có chi phí đủ. Khấu trừ kinh tế trước, EXP sau, một nguồn Body EXP/người/phút.
- Không tiêu hao Thể Lực Viễn Chinh, không thay đổi đường Tu Vi thụ động.
- Max Lv100 theo khung công trình; **chưa duyệt** hệ số slot sau Lv1, nâng cấp, cấp độ cường độ cao hoặc chi phí vật liệu nên tất cả hiệu ứng nâng cấp vẫn bị khóa.

Công trình là consumer cho nguồn `body_training` đã khóa trong `docs/BODY_CULTIVATION_V2_SPEC.md`. **Không tạo kho mới.**

---

# 38. CÁC QUYẾT ĐỊNH KHÔNG ĐƯỢC PHÁ

1. Không material Lv.1–Lv.5 ladder cứng.
2. Không hard realm-lock công việc nếu lore không bắt buộc.
3. Không full personal inventory cho hàng nghìn đệ tử.
4. Không thu hoạch thủ công bắt buộc.
5. Không bấm production từng batch đối với hàng routine; policy/auto là hướng mặc định.
6. Không mỗi Lv building lại mở thêm một currency mới.
7. Level thường tăng số; milestone mới mở cơ chế.
8. PvE phải là nguồn quan trọng của specialty material và rare content.
9. Hậu phương phải giúp hunter quay vòng nhanh/mạnh hơn.
10. Worker phải đồng thời tăng nghề + nhận Tu Vi thụ động + có giá trị kinh tế.
11. Tông Chủ quản luật, ưu tiên và ngoại lệ; AI xử lý routine.
12. Map vẫn là màn chính; UI công trình chỉ là cửa sổ điều hành, không biến game thành spreadsheet.

---

# 39. CROSS-SYSTEM AUTHORITY

This building-tree spec defines building mechanics only.

Use:
- `docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md` for resource identity, realm/tier, quantity, warehouse reserve/lock and stack semantics;
- `docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md` for travel/work/construction/cooldown timing;
- `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md` for hunting/loadout/reward progression;
- `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md` for the parent economy relationship.

Implementation order and runtime status do not belong in this file.
Read `CURRENT_CHECKPOINT.md` for what is actually implemented and which single phase is active.
