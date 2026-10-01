# Tông Môn Bá Đạo — Gameplay Reference Synthesis

Date: 2026-10-01

## Mục đích

Tài liệu này khóa hướng tham khảo gameplay sau khi P2.6 đã runtime PASS. Đây không phải danh sách cơ chế để sao chép nguyên xi. Mỗi game được dùng như một nguồn tham khảo cho một vấn đề cụ thể, sau đó chuẩn hóa theo triết lý của Tông Môn Bá Đạo.

## Trục chính: Evil Hunter Tycoon

Tông Môn Bá Đạo lấy **nhịp vận hành** của Evil Hunter Tycoon làm khung chính:

- nhân vật tự di chuyển, tự chiến đấu và tự giải quyết nhu cầu cơ bản;
- người chơi điều hành cơ sở, sản xuất, hàng hóa, trang bị, nhiệm vụ và khu vực hoạt động;
- vật liệu do nhân vật mang về quay lại nuôi hệ sản xuất của căn cứ;
- nhân vật có tiền/tài sản cá nhân và chi tiêu tại cơ sở do người chơi vận hành;
- người chơi có thể gọi một nhân vật cụ thể và ra lệnh trực tiếp khi cần;
- phần lớn thời gian người chơi quản lý bằng chính sách và chuẩn bị trước, không điều khiển từng bước chân.

Nguồn chính:
- https://evilhunter.zendesk.com/hc/en-us/articles/360039882831-Hunter
- https://evilhunter.zendesk.com/hc/en-us/articles/360039886271-Building-Information
- https://evilhunter.zendesk.com/hc/en-us/articles/360039885551-Conversing-with-a-hunter
- https://evilhunter.zendesk.com/hc/en-us/articles/360039886511-Equipment-Production-and-Sale
- https://evilhunter.zendesk.com/hc/en-us/articles/360039483232-Dungeon-Raid

### Điều giữ lại

1. **Autonomous-first**: nhân vật tự vận hành là mặc định.
2. **Chief/Sect Master override**: người chơi luôn có thể can thiệp vào một nhân vật cụ thể.
3. **Town/Sect economy loop**: săn -> vật liệu/tiền -> sản xuất/dịch vụ -> nhân vật tiêu dùng -> căn cứ mạnh hơn -> săn khó hơn.
4. **Needs drive movement**: bị thương, mệt, thiếu nhu yếu phẩm phải tạo hành vi quay về và sử dụng công trình.
5. **Build preparation matters**: đội hình, trang bị, kỹ năng và tài nguyên chuẩn bị trước phải quyết định khả năng vượt nội dung.

### Điều không sao chép

- Không dùng class cứng kiểu Berserker/Ranger/...; game giữ hướng Kiếm/Thể/Pháp từ lịch sử tu hành.
- Không bắt người chơi click từng đệ tử để mua mọi món, học mọi kỹ năng hoặc làm mọi hành động lặp lại.
- Không để hệ thống quản lý số lượng lớn phụ thuộc micromanagement 1-by-1.

## 最强祖师 — Đệ tử là tài sản đa chiều, không phải chỉ số chiến đấu

Điểm mạnh cần lấy:

- đệ tử khác nhau bởi nhiều trục: thuộc tính nền, linh căn, đặc tính/thiên phú/quái癖, thiên mệnh và năng lực chuyên môn;
- chiến đấu và sản xuất là hai giá trị khác nhau;
- đệ tử chiến lực thấp vẫn có thể là nhân sự sản xuất rất có giá trị;
- chuyên môn sản xuất có cấp/kinh nghiệm, càng làm càng giỏi;
- trí tuệ/đặc tính phù hợp làm thay đổi tốc độ học nghề hoặc hiệu quả sản xuất;
- các công việc như trồng trọt, khai khoáng, luyện khí, luyện đan, thương nghiệp cần người phù hợp chứ không chỉ "ai rảnh thì làm".

Nguồn chính:
- https://www.taptap.cn/moment/460461188975690006
- https://www.taptap.cn/moment/518641440847299228
- https://www.taptap.cn/moment/492413644118691459
- https://www.taptap.cn/moment/601377068508252716

### Chuẩn hóa cho game mình

Không tạo "đệ tử chiến đấu" và "đệ tử sản xuất" như hai class cố định. Mỗi đệ tử có thể có:

- năng lực chiến đấu;
- năng lực tu hành;
- năng lực sản xuất;
- năng lực quản trị/xã hội;
- đặc tính khiến một số việc dễ hoặc khó hơn.

Giá trị của một đệ tử phải phụ thuộc vào **việc tông môn đang cần gì**.

## The Lost Village — Phân việc, chức danh nhóm, lịch sống

Điểm mạnh cần lấy:

- đệ tử được phân nhiệm vụ dựa trên tính cách/tài năng;
- có cơ chế giao việc qua trung tâm quản lý;
- có thể gom người vào một chức danh rồi đặt ưu tiên công việc cho chức danh đó;
- đời sống gồm làm việc, nghỉ, tu luyện, phục hồi tinh thần/thể lực;
- công trình và khoảng cách trong tông môn tác động đến luồng di chuyển.

Nguồn chính:
- https://store.steampowered.com/app/1963040/The_Lost_Village/
- https://www.3dmgame.com/gl/3934957.html
- https://www.3dmgame.com/gl/3935515_6.html
- https://steamcommunity.com/app/1963040/discussions/0/4299320351875805997/?l=schinese

### Bài học phải tránh

Phản hồi người chơi chỉ ra các vấn đề quan trọng:

- thiếu ưu tiên công việc làm quản lý đông người khó;
- gán một việc cố định có thể khiến nhân vật không còn thời gian tu luyện/nghỉ;
- thiếu tag/lọc nhanh khiến roster lớn trở thành gánh nặng;
- cần kiểm soát số vị trí làm việc, không để AI dồn toàn bộ người vào một công trình.

### Chuẩn hóa cho game mình

Mọi phân công phải là **ưu tiên**, không phải xiềng xích. Đệ tử vẫn được phép:

1. xử lý nguy cấp;
2. nghỉ/chữa trị;
3. tu luyện theo lịch/chính sách;
4. thực hiện nhiệm vụ ưu tiên;
5. tự chọn việc phụ hợp lý khi không có việc chính.

## 鬼谷八荒 — Cơ cấu quyền lực và phân quyền tông môn

Điểm mạnh cần lấy:

- cấp bậc: ngoại môn -> nội môn -> chân truyền -> trưởng lão -> đại trưởng lão -> tông chủ;
- quyền hạn tăng theo chức vị;
- trưởng lão trở lên có thể phân nhiệm vụ;
- đại trưởng lão/tông chủ có quyền điều phối người và tài nguyên lớn hơn;
- hệ nhiệm vụ tông môn chia theo hướng phát triển như tuyển người, tuần tra, ngoại vụ, xây dựng, học tập;
- tông chủ ra quyết định chiến lược, không trực tiếp làm mọi việc.

Nguồn chính:
- https://steamcommunity.com/app/1468810/discussions/0/3118172724621705341/?l=schinese
- https://www.gamersky.com/handbook/202112/1443058.shtml
- https://www.gamersky.com/handbook/202201/1454193_4.shtml

### Chuẩn hóa cho game mình

Phải tách 3 khái niệm:

1. **Địa vị tông môn**: ngoại môn, nội môn, chân truyền, chấp sự, trưởng lão, đường chủ...
2. **Chuyên môn/công việc**: luyện khí, luyện đan, trồng trọt, khai khoáng, y thuật, thương nghiệp...
3. **Vai trò chiến đấu**: đội trưởng, tiên phong, hộ vệ, hỗ trợ... hoặc các vai trò tactical khác.

Một người có thể đồng thời là:

`Nội môn + Luyện Khí Sư + thành viên đội săn`

hoặc:

`Trưởng lão + Đường chủ Dược Đường + không tham gia đội săn thường xuyên`.

Không được lưu ba thứ này trong cùng một biến role.

## Sect Master / 宗门经理人 — Expedition và kinh tế tuần hoàn

Steam mô tả game này rất gần định hướng Tông Môn Bá Đạo:

- người chơi là người quản lý tông môn, không trực tiếp cầm kiếm;
- đệ tử được phái vào khu vực thám hiểm, tự khám phá và tự chiến đấu;
- phần thưởng về kho, sau đó đi vào crafting, nghiên cứu và build đệ tử;
- đệ tử có linh thạch cá nhân và tiêu tiền tại cơ sở của tông môn;
- trang bị, công pháp, đội hình được chuẩn bị trước; combat tự động;
- kho là nút nối expedition -> production -> disciple development -> battle.

Nguồn:
- https://store.steampowered.com/app/5222440/__Sect_Master/

### Chuẩn hóa cho game mình

Đây là vòng dài hạn cần giữ:

`Đệ tử đi săn/thám hiểm -> mang tài nguyên và thu nhập về -> kho tông môn -> sản xuất/công trình -> đệ tử tiêu dùng hoặc được cấp -> mạnh hơn/chuyên môn cao hơn -> mở khu vực khó hơn -> tài nguyên cao cấp hơn`.

P2.6 đã chứng minh một phần vòng này với forge/equipment. P2.7 phải nối **con người và công việc** vào cùng vòng kinh tế.

## Luật thiết kế hợp nhất

### 1. Autonomous-first, command-second

Đệ tử tự sống. Tông Chủ không cần ra lệnh từng bước, nhưng luôn có quyền ra lệnh tạm thời.

### 2. Không class cứng

Không có "thợ rèn vĩnh viễn" hoặc "đệ tử sản xuất vĩnh viễn". Có thiên hướng, kinh nghiệm và nhiệm vụ hiện tại.

### 3. Công việc là hành vi thật

Một nghề chỉ được coi là có thật nếu nó thay đổi ít nhất một trong:

- tài nguyên;
- thời gian;
- chất lượng sản phẩm;
- chi phí;
- quyết định AI;
- khả năng chiến đấu/tu luyện;
- tiến triển tông môn.

### 4. Hệ thống phải scale

Với 6 đệ tử có thể điều khiển từng người. Với 60-100 đệ tử phải quản được bằng:

- ưu tiên nhóm;
- chức danh/đường;
- chính sách;
- lọc/tag;
- cảnh báo ngoại lệ;
- lệnh trực tiếp chỉ khi cần.

### 5. Không để công việc giết chết tu luyện

Mọi schedule phải dành chỗ cho nhu cầu sinh tồn, nghỉ và tu hành. Tông Chủ có thể ép tăng ca/bế quan/làm việc, nhưng đó phải là quyết định có hậu quả chứ không phải hành vi mặc định.

### 6. Đệ tử yếu chiến đấu vẫn phải có lý do để giữ

Một người có thể yếu khi săn quái nhưng là:

- luyện khí sư giỏi nhất;
- đan sư chính;
- người quản kho tốt;
- người có mị lực tuyển dụng tốt;
- người có cơ duyên đi ngoại vụ tốt;
- trưởng lão có năng lực lãnh đạo tốt.

### 7. Tông Chủ là nhân vật có quyền lực, không phải con trỏ chuột vô hình

Tông Chủ có thể:

- ban chức;
- phân đường;
- đặt ưu tiên;
- điều động;
- cấp/thu hồi vật phẩm;
- triệu hồi một đệ tử;
- ra lệnh tạm thời;
- về sau truyền công, thu đồ đệ, xử lý kỷ luật, chọn người kế nhiệm.

## Hướng sản phẩm sau P2.6

P2.7 không nên là "thêm vài nghề". P2.7 phải là nền **Disciple Life + Workforce + Sect Assignment** để các module sau như Luyện Đan, Dược Viên, Luyện Khí Sư, Kho, Chợ, Trưởng lão, Đường chủ và Sư đồ đều dựa vào cùng một authority model.
