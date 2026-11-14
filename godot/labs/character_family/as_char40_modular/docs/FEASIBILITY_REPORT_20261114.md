# AS-CHAR-40 — TÍNH KHẢ THI MODULAR DISCIPLE V1.1

**Quyết định:** KỸ THUẬT KHẢ THI, NÊN GIỮ PHƯƠNG ÁN. **MỸ THUẬT + CHUYỂN ĐỘNG THẬT: CHƯA CHỨNG MINH.**

Ngày đánh giá: 2026-11-14. Phạm vi: chỉ công cụ sản xuất pixel-art theo lớp, không đụng gameplay/SaveService, không rig.

## Bằng chứng vừa thực hiện

- Chạy lại 14 bài test V1: PASS.
- Phát triển thư viện **weapon-pose cels** dùng lại theo `weapon_pose` + `hand_r_grip`, không phải bộ ảnh toàn canvas cho từng item ở mọi frame. 4 bài test mới: PASS. Tổng **18/18 PASS**.
- Xuất thử 2 biến thể trang phục `cobalt`/`golden`, mỗi biến thể **24 clip (6 trạng thái × 4 hướng) và 96 frame thử**, dùng 2 kiếm `jian_blue`/`jian_gold`; chỉ **4 PNG nguồn của tư thế kiếm** (2 kiếm × 2 tư thế). Kết quả xuất mỗi biến thể: 5 SpriteFrames, 48 GIF, 96 atlas PNG vũ khí (gồm 48 front + 48 back), 24 atlas body. Thời gian đo lần này: **0,715 s** và **0,596 s**. Dung lượng gói mỗi biến thể khoảng **0,498 MB** với ảnh hình học đơn giản, KHÔNG đại diện kích thước art thật.
- Đối chiếu SHA đầu ra: **0 sai khác**. Khóa pixel `body` thay khi đổi outfit, trong khi tất cả PNG vũ khí giữ nguyên; đổi kiếm không làm biến đổi body. Socket tay và giới hạn 128×128 được test, frame thiếu/sai alpha/family không khớp bị từ chối.
- Đã viết script `godot/as_char40_headless_qa.gd` để chạy với Godot 4.7.2 sau khi copy nguồn vào lab. **Chưa chạy Godot trong môi trường này** vì không có executable; không được đánh dấu ENGINE_PASS.

## Ưu điểm và điểm nghẽn thực tế

1. **Body suit + mặt/tóc + outfit + weapon là cấu trúc khả thi** khi xuất frame-by-frame, tạo avatar nhiều biến thể cùng nhịp chuyển động và nguồn tỷ lệ chung. Nhưng `body_base` đẹp, layer che khuất và đặc biệt các frame chuyển động vẫn phải thật sự được vẽ.
2. **Vũ khí rất nên modular.** Thêm một thanh kiếm cùng nhóm chỉ cần thiết kế một số sprite góc/tư thế chuẩn, sau đó dùng socket đặt đúng vị trí từng frame. Các góc khó phải vẽ thủ công để không gãy pixel; không xoay tùy tiện gây răng cưa. Prototype đã kiểm chứng hai tư thế/kiếm. Cần mở rộng pose bank có kiểm duyệt (thường tối thiểu các góc xuất hiện trong clip); không ấn định 8 hay 12 trước khi xem chuyển động.
3. **Trang phục không phải thay một texture là xong.** Cần lớp áo/tà áo/tay áo theo từng pose và hướng; nếu có 96 frame chuyển động thật thì một outfit hoàn toàn khác silhouette có thể cần tới 96 layer pose xuất riêng. Điều này vẫn giảm công sửa chuyển động và khóa tỷ lệ nhưng KHÔNG giảm toàn bộ công vẽ trang phục. Thay màu/ornament nhỏ dễ hơn thay kiểu áo hoàn toàn.
4. **Mặt ở game size 60–75 px có ít pixel:** nên dùng 2–3 face template có mắt/lông mày; tạo layer mặt riêng, không nên dùng base trống mặt như ảnh game cuối.
5. Không rig và không render 10 layer live trên mỗi nhân vật: composer xử lý body + outfit offline, runtime tối đa body + weapon back + weapon front, VFX ngoài. Đổi kiếm cùng family dùng một bộ chuyển động body. Đao/thương/cung khác dáng cầm có thể cần attack pose family riêng.

## Ghi nhận FAIL / còn thiếu

- Chưa có master pixel thật được owner duyệt, chưa có Walk/Attack đẹp đúng nhân vật. **ART_BLOCKED**.
- 24 clip fixture chỉ là hình màu đơn giản *cố tình* có 4 frame khác pixel, **không phải 24 animation người thật**. Bài test chỉ phát hiện frame giống 100%, không xác minh bước chân thực, chuôi kiếm bám tay, tính liên tục của nếp áo, khuôn mặt hay chất lượng mỹ thuật. Nếu gọi đây là animation PASS là sai.
- Chưa chạy official Godot 4.7.2 import/GUI; chưa đo 30 actor trên Android hay Windows; không thể kết luận FPS từ 0,6 s thời gian export.
- Tài liệu `TMB_DISCIPLE_UNIFIED_ART_BIBLE.md` có đoạn cũ nói rig nhưng chủ dự án đã cấm hoàn toàn rig; tuân theo chỉ đạo mới: frame-by-frame không Skeleton2D/Bone2D.

## Cổng tiếp tục bắt buộc

- Giữ bộ công cụ xuất và thư viện socket, bảo vệ 12 bảng màu môn phái đã duyệt.
- Vẽ một **base male + nữ** bodysuit có nhận diện Shadow Pixel-Chibi tốt ở 1×, scale native 128×128, foot (64,104). Chỉ front của male trước; visual review riêng, chưa phát sinh 12×.
- Vẽ 1 **Walk front** đúng bước trái → passing → bước phải → passing, mỗi frame layer outfit ăn khớp với chân/tay, thêm 2 sword pose library. Xem GIF thật ở native 1× và zoom 6×; owner visual PASS mới dựng hướng khác.
- Codex có thể nhận việc source preflight, export, socket transform, manifest, Godot exact-SHA QA. **Không cho Codex vẽ nhân vật hình học thô và báo mỹ thuật PASS.**

**Không có sản phẩm hình pixel/clip nhân vật mới được khẳng định đạt chuẩn trong đánh giá này.**