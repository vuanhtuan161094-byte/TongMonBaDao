# TÔNG MÔN BÁ ĐẠO — VFX ART-FIRST / ONE SKILL AT A TIME — SOP V3
Áp dụng 14/11/2026 | PR #72 Draft | Godot 4.7.2 GL Compatibility | video 1280×720

## Quyết định chủ dự án, thứ tự hiệu lực cao nhất
Chủ dự án **bác bỏ mỹ thuật của VFX-BATCH-01 R1–R4** vì nhiều hiệu ứng xấu/ẩu và yêu cầu quay lại **mỗi lần hoàn thiện một skill thật đẹp, đạt mới chuyển sang skill kế tiếp**. Quyết định này **thay thế** batch-artwork override trước đó trong TMB_VFX_SOURCE_VL_PRODUCTION_STANDARD_20261114.md.

Không cho phép tạo hàng trăm skill bằng một hình SVG lớn đổi màu; cũng không thay hình concept cho kết quả Godot, không đánh dấu kỹ thuật PASS là mỹ thuật PASS. **Một skill đang làm tại một thời điểm**, sử dụng bộ sprite gốc và kỹ thuật hiệu ứng phù hợp chính kỹ năng đó. Không rig.

**Giữ lại** VFX-BATCH-01 chỉ để tra cứu 2.196 ID, 420 families và demo kỹ thuật; 201 cast-family preview trong đó là **ART REJECTED AS FINAL / PROTOTYPE ONLY**, không dùng làm chuẩn nghệ thuật hay bản phát hành. **Khóa giữ nguyên** ba LAB Human Độc Tu đã được chủ dự án duyệt: Phụ Cốt Cổ, Xà Ảnh Quấn Mạch, Cổ Vụ Mê Tung. Xà Ảnh có nợ polish pha tụ lực, không đụng phần bay/quấn đã duyệt.

## Phạm vi và định nghĩa hoàn thành
- 12 hệ phái × 17 CAST_MASTER = **204 nhóm VFX thi triển**. Đã có **3/204** Human LAB visuals owner-approved, **201/204** chưa được chấp nhận mỹ thuật.
- 216 nhóm passive/innate/event-only không được vẽ cast animation giả: chỉ dựng hiệu ứng xuất hiện khi có real gameplay event/receipt đã được kiểm tra.
- 2.196 skill IDs được mapping theo family, không phải 2.196 MP4 độc lập. Biến thể Tiên/Thần cần đánh giá từng nhánh theo mô tả thật; không tự áp dụng approval Human lên toàn tier.
- **CATALOGUE_MAPPED ≠ CODE_LAB_READY ≠ GODOT_FOCUSED_PASS ≠ ART_QA_PASS ≠ OWNER_VISUAL_APPROVED ≠ PVE_INTEGRATED ≠ RELEASE_READY.**

## Quy trình bắt buộc: G0–G7 cho từng skill trước khi chuyển skill kế

| Cổng | Việc bắt buộc | Điều kiện nghiệm thu |
|---|---|---|
| G0 — Source | Kiểm tra HEAD PR #72, catalogue/ledger, đúng skill ID, nhánh, effect, shape, target cap, range, cooldown và Combat V2 event authority; chốt caster/target anchor | Không tự đặt sát thương, target, DoT/mark, heal/summon/hit |
| G1 — Học reference | Phân tích frame chuyển động thật của JX, Source VL, V9 và 3 skill owner-approved; phân biệt silhouette, light hierarchy, nhịp, alpha, occlusion, rights | Mô tả quan sát có nguồn; art thương mại cần tự dựng hoặc có giấy phép |
| G2 — Storyboard | Thiết kế 5–6 pha tụ khí, xuất chiêu, bay/duy trì, tiếp xúc/vùng/ấn, tan; 8–12 keyframes, silhouette/nhịp, phân lớp sau-nhân vật-trước | Có nét riêng, xem được ở tỉ lệ gameplay thực 1× |
| G3 — Sprite master | Vẽ art nguyên gốc, atlas/flipbook alpha PNG, nhiều pose thực chất: đầu/cánh/chân, kiếm khí, phù văn, sương, hoa v.v. tùy kỹ năng. Shader/particle chỉ giúp light/motion | Không tạo một hình vector tĩnh phóng to/đổi màu; tuyệt đối NO RIG |
| G4 — Godot scene | LAB Godot 4.7.2 Compatibility thật, view-only; animation mượt, đúng vật liệu, event timing và occlusion, nhiều lớp độc lập | Có scene/script/assets chạy được, giữ V6.3/PvE OFF |
| G5 — Motion review | Xuất genuine MP4 1280×720 và GIF/ZIP fallback, 8+ ảnh mốc. Xem cả motion và 1× trên nền tối/sáng; tìm lỗi đường bay, quấn, head-tail, mặt, va chạm và fade | Tự sửa/render lại cùng skill đến khi không còn lỗi mỹ thuật dễ thấy |
| G6 — Rubric mỹ thuật | 8 tiêu chí: silhouette, chất liệu/ánh sáng, chuyển động, bố cục, contact, fade, nét riêng, đọc rõ/performance. Các tiêu chí nghệ thuật 1–7 tự chấm **mỗi mục ≥4/5** trước khi gửi | Không qua nếu có silhouette SVG phẳng, glow vòng, fake hit hoặc che mục tiêu |
| G7 — QA và chủ duyệt | Godot strict import/parse/contract exact-SHA run, movie thật, logs, hashes, 8+ phase frames, bản tóm tắt lỗi đã sửa. Owner xem actual animation và duyệt | Nếu owner chưa duyệt: OWNER_VISUAL_PENDING; chê: ART_REWORK_REQUIRED quay lại G2–G6; **không chuyển skill kế** |

**G8 — riêng sau khi được ủy quyền:** diễn giải tier A/B/Divine, nối real Combat V2 receipts, stress 1v1 → 3 mục tiêu → 6v8 → 30 đệ tử/40 quái, Windows/Android vật lý và pháp lý. Chủ duyệt LAB KHÔNG cho phép bật PvE/V6.3.

## Gói thành phẩm mỗi kỹ năng
- Packet nguồn: đúng ID, bản sắc kỹ năng, tên/tier, effect/shape/cap, reference + quyền sử dụng, storyboard.
- Sprite/atlas gốc có alpha chuẩn, đủ hoạt ảnh, anchor và layering, scene/script Godot riêng; không rig.
- Video MP4 Godot thật 1280×720, GIF xem nhanh, ZIP, 8–12 phase PNG, tên SHA/run và báo cáo tác phẩm; không giao riêng ảnh concept.
- Art rubric, những lỗi đã sửa theo timecode; ghi **owner gate** và **PVE gate** tách biệt.

## STOP RULES chống tái diễn VFX-BATCH-01
1. Một mẫu SVG phóng to, đổi màu, xoay, không có frame motion riêng = **không đạt**.
2. Giống biểu tượng UI hơn skill võ lâm, đầu/đuôi không đúng, mờ yếu hoặc neon quá đà = **làm lại**, không thêm glow che lỗi.
3. Nhân vật/mục tiêu bị che, ấn/sương đè đầu, tia xuyên người sai diễn xuất = **làm lại**.
4. Không có genuine Godot full-motion movie hoặc chỉ có 4-up thumbnail = **không gửi duyệt**.
5. Runtime 60FPS movie cố định không phải chứng cứ hiệu suất thật trên Android/Windows.
6. Reference JX/VL chưa có quyền phát hành = **R&D ONLY**, asset TMB mới phải độc lập.
7. Không thay Combat V2/HP/target/SaveService/economy/AI, không tự bật V6.3, không nhánh mới/merge, không Codex, không rig.

## Dự báo công sức có điều kiện — KHÔNG phải cam kết thời điểm hoàn thành
Mẫu số chính: **201 cast masters Human cần art approval**. Giả định sau mỗi master là một kỹ năng thật đẹp, có video và được chủ duyệt. Năng suất 3–4 sản phẩm đạt chuẩn mỗi tuần là kịch bản dự toán **chưa được chứng minh** qua chuỗi dài; 3 pilot Độc Tu không đủ để ngoại suy sang 12 hệ.

| Kịch bản | Tốc độ PASS chủ duyệt | Thời gian 201 master | Dự phòng 12–24 tuần cho tier, event QA và tích hợp | Tổng công sức theo lịch làm việc đều |
|---|---:|---:|---:|---:|
| Tối ưu | 5 master/tuần | ~40 tuần | +12–24 tuần | **~12–15 tháng** |
| Cơ sở | 3–4 master/tuần | ~50–67 tuần | +12–24 tuần | **~14–21 tháng** |
| Chậm, ưu tiên mỹ thuật khó | 2 master/tuần | ~101 tuần | +12–24 tuần | **~26–29 tháng** |

**Không tính máy tự làm 24/7**. Số tháng chỉ có nghĩa khi có các buổi sản xuất được duy trì đủ đều, chủ duyệt theo nhịp, tái sử dụng pipeline thực sự tiết kiệm thời gian, và số passive event riêng không tăng mạnh. Công việc theo các phiên chat rời rạc có thể lâu hơn. Cần cập nhật dự báo sau **10 kỹ năng master mới được duyệt**, đo thời gian thực, số vòng sửa và test, thay vì lấy pilot làm số liệu chắc chắn.

## Kỹ năng bắt đầu lại
**Tán Cổ Diễn Nhiễm** — ID tmb.skill.poison.co_doc.active_04.human, nhánh Cổ Độc, poison / circle / target limit 3 theo catalogue; phải thiết kế *khác* Cổ Vụ Mê Tung về hình thể/choreography. Xong G0–G7 rồi mới làm skill kế tiếp, sau đó hoàn tất Độc Tu trước khi chuyển hệ phái.

## Source of truth và phạm vi
PR #72 Draft, integration/pve-p0-playable-ui-20261103. SOP này supersedes batch-style priority; TMB_VFX_SOURCE_VL_PRODUCTION_STANDARD_20261114.md, TMB_VFX_SCHOOL_BY_SCHOOL_MASTERPLAN_20261113.md và QA_AND_EVIDENCE vẫn là chuẩn kỹ thuật/tài liệu bổ sung không mâu thuẫn. Chỉ sửa art LAB/tài liệu, không động live gameplay.
