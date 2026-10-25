# TÔNG MÔN BÁ ĐẠO — SỔ NỢ QA CHUNG

Cập nhật đối chiếu: 25/10/2026. Giữ nguyên ID nợ; bỏ các lệnh NEXT/ACTIVE ngày 13–15/10 đã hết hiệu lực. Trạng thái nhánh và evidence mới ở [CURRENT_CHECKPOINT](../CURRENT_CHECKPOINT.md); đây vẫn là sổ nợ, không phải một implementation packet mới.

## 1. Nguyên tắc nghiệm thu

Một kết quả chỉ chứng minh contract trên đúng SHA/tree, engine và môi trường được ghi. Headless/CI, automated GUI, thao tác người thật, Android, owner visual và fault injection là các loại bằng chứng riêng. Không xoá test, sửa balance hoặc biến nợ chưa kiểm thành PASS.

Economy-A #1 đã merge; skills #23 đã merge. PR31 có 28/28 focused, PR32 có 29/29 focused theo raw CSV đã đối chiếu; các kết quả đó không chứng minh PR33/34 hoặc CODE-CLEAN/R0. Root checkpoint chứa đường dẫn immutable.

## 2. Nợ còn cần theo dõi

| ID | Nội dung / trạng thái được giữ |
| --- | --- |
| Q01 | GP-02C1 simulation: đã có Windows automated PASS trong Economy-A 18/18 và focused PASS trong PR31/32; không còn là “chưa từng chạy Windows”. Bản sửa mới phải có evidence riêng. |
| Q02 | GP-02C1 presentation: Windows automated trong Economy-A 18/18; không thay cho nghiệm thu người thật của Q05. |
| Q03 | O6 assertion `available_quantity(thanh_thiet)==4` giữ nguyên. Failure cũ tại `a327ab59` là lịch sử; có standalone Linux PASS sau đó và Windows Economy-A PASS tại `95bf06e`. Nguyên nhân failure cũ chưa xác lập; không coi là lỗi hiện hành nếu không tái hiện. |
| Q04 | P3.7 FULL Windows đã PASS tại `95bf06e`; chưa có FULL mới cho toàn bộ stack hiện hành. PR31/32 focused không được gọi FULL. |
| Q05 | Manual Windows Injury/return/work/recovery và nghiệm thu hình ảnh: còn mở. Automated captures không đóng nợ này. |
| Q06 | Android thật: landscape/touch, săn/quay về, save/offline/restart; còn mở. |
| Q07 | Tải 100/500/1000/3000 đệ tử trên phần cứng mục tiêu: chưa nghiệm thu; cần tiêu chí và số đo. Benchmark map PR32 không đại diện cho tải này. |
| Q08 | ENV-02A legacy 35-PNG pack/scene: bằng chứng lịch sử riêng. Map hiện hành đã dùng bộ 32 PNG SHA-gated ở PR31/32; không đợi lại pack 35 ảnh như prerequisite chung. Android/map/asset gap hiện hành vẫn mở. |
| Q09 | Upload/capture của P3.6A cũ: nợ artifact lịch sử. PR31/32 đã có screenshot runtime mới; failure upload cũ không phải lỗi gameplay mới, không cần chạy lại mặc định. |
| Q10 | SAFE real-device kill/low-storage/backup/recovery: physical QA còn mở dù có simulation fault/retry tests. |
| Q11 | DV2-03 administrative PAUSED NOT CLOSED được giữ; không kết luận mọi Body gate/progression sau đó chưa triển khai. Rà contract cụ thể tại nhánh mục tiêu trước khi resume; không mở DV2-04 từ sổ nợ. |
| Q12 / ACTION-GUARD-01 | One Active Job: đã có guards và các scoped regression; kiểm toán toàn bộ ingress/cancel/offline/recovery chưa có closure tổng thể. Không tạo occupation authority song song. |
| Q13 | Economy-A timed output/payroll đã triển khai. Tuỳ chọn thời lượng Mỏ 1/2/4/8 giờ chưa tự trở thành balance đã khoá; giữ backlog design và exactly-once/carry-drain regression. |
| Q14 | Kinh tế tổng thể nguồn/tiêu/craft/upgrade/PvE/anti-inflation: có pilot và nhiều nhánh nghiên cứu, chưa có acceptance tổng thể. |
| Q15 / CHAR-AUDIT-01/01B | D7/character consumers đã có implementation trong integration candidate; audit coverage tất cả lục duy/root/bloodline/physique/trait/combat/work vẫn chưa có closure tổng thể. Master schema là thiết kế, không là log tiến độ. |
| Q16 | Map/land/building: #32 đã code zoning, #33 có candidate art; không chứng minh đã có player construction, mở đất, giá xây, 30/30/40 producers hoặc full SectLayoutState gameplay. |
| Q17 | Source A/mobile final art, animation thật, touch và owner visual: còn mở. SVG candidate #33 không đóng asset gap Source A. |
| CHAR-ISO-00 | Đề xuất isolation lịch sử; không có closure riêng trong đợt dọn. Không dùng nó để thay runtime hiện hành hoặc tự cấp phép code. |

GP-01/02A/02B1 đã CLOSED theo evidence lịch sử. GP-02C1 overall QA vẫn OPEN. Các exclusion “không được sửa ... trong Economy-A” chỉ thuộc packet đó, không phủ định các uỷ quyền rõ ràng được owner đưa sau này.

## 3. Phát hiện GUI ngày 15/10 cần tránh thất lạc

Bản video/sync ngày 15/10 xác nhận ba lỗi ở baseline cũ: GUI-DEFECT-01 chữ tên đệ tử tương phản thấp; GUI-DEFECT-02 hàng action rộng hơn panel và bị cắt; GUI-DEFECT-03 body quản lý quá cao, đẩy nút xuống dưới.

Sau đó đã có #28/readability và các bản map mới, nhưng đợt này **chưa đối chiếu từng ID lỗi với acceptance cụ thể trên final tree**. Giữ là historical findings cần đối chiếu khi kiểm đúng luồng; không tuyên bố đã sửa toàn bộ, cũng không gọi chúng là lỗi chắc chắn còn tồn tại.

Evidence cũ: ZIP `20261015_144302.zip` SHA256 `a1aca095366dc701c0e6408491c157d54b66983a420a05eb77bf9f791c42fb3c`; video SHA256 `31a7c44370e290935d379df5d2df7c2f5eee86b5ecf7c377f170813cf579ef18`. File từng do owner cung cấp, không tự có binary trên GitHub. GUI QA lúc đó PARTIAL/NOT ACCEPTED; 18/18 automated là evidence khác.

## 4. Nợ mới được đưa vào cùng sổ

- MAP-D2 #33: import/parse SVG, focused, real captures, đo hiệu năng; chưa có official Godot evidence.
- PvE #34: kiểm presentation và topology riêng; chưa có world 300 quái thật.
- CODE-R0: scan nguồn tĩnh đã làm; git grep và 21 Godot tests chưa thực thi. Metadata runner_id=0/steps=[] chứng minh chưa được cấp runner; nguyên nhân hạn chế chính xác UNKNOWN.
- Integration/main cutover: chưa có combined final tree/QA cho các nhánh mới. Không merge từ sổ nợ này.

## 5. Công cụ và truy vết

`tools/qa/RUN-QA-DEBTS-WINDOWS.cmd` vẫn là launcher QA lịch sử cho các gate mà nó gọi; không coi nó bao phủ D2/PvE/R0 mới. Chọn runner và target SHA theo CURRENT_CHECKPOINT/NEXT_CHAT_HANDOFF, không tự chạy toàn bộ gate cũ vì tên chúng còn trong danh mục.

Bản đầy đủ trước khi rút gọn, gồm các run/SHA và bảng Q gốc: [sổ nợ tại 29b5fba448b0178cb520a4ada44b375b4b934e31](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/29b5fba448b0178cb520a4ada44b375b4b934e31/docs/QA_DEBT_MASTER_AND_BACKEND_REDESIGN_HANDOFF_2026-10-13.md). Lịch sử được giữ trong Git; không tạo thêm tracker hay sao chép archive trùng.
