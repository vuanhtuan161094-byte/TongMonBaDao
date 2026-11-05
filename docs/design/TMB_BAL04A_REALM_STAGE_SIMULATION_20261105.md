# BAL-04A — KẾT QUẢ MÔ PHỎNG 30 CẢNH THUỐC TU VI

**Nguồn:** đọc trực tiếp `DiscipleProgressionBalanceV2.REALM_TOTAL_XP` tại cùng PR #72. **Loại bằng chứng:** tính toán độc lập bằng JavaScript từ số liệu source, không phải Godot QA hoặc dự báo tốc độ chơi thật. **Quyết định Owner 05/11/2026: A.**

## Bảng đối chiếu tính hữu ích

- Thuốc **cũ**: `round(10,000 × 1.65^(r-1))` (đang giữ chỉ để xác thực receipt phiên bản 1).
- Thuốc **mới q1**: `round(REALM_TOTAL_XP[r] × 0.001)` (áp dụng trong gameplay).
- Thuốc **mới q4**: `round(REALM_TOTAL_XP[r] × 0.002)` (hệ số phẩm x2).
- XP tầng đầu: 7% tổng XP cảnh, làm tròn theo hiện hành của Godot.
- Các phẩm q2 ×1.25, q3 ×1.55; không có phẩm chất “roll” ngẫu nhiên mới.
- 30 cảnh là **metadata SKU**, hiện tại chỉ có 4 công thức graded r1/r2; không tạo giả nguồn r3+.

| Cảnh | Tổng EXP cảnh | EXP tầng đầu | Thuốc cũ q1 | Thuốc mới q1 | Thuốc mới q4 | q1 / EXP tầng đầu |
|---:|---:|---:|---:|---:|---:|---:|
| 1 | 10,000,000 | 700,000 | 10,000 | 10,000 | 20,000 | 1.43% |
| 2 | 12,700,000 | 889,000 | 16,500 | 12,700 | 25,400 | 1.43% |
| 3 | 16,200,000 | 1,134,000 | 27,225 | 16,200 | 32,400 | 1.43% |
| 4 | 20,500,000 | 1,435,000 | 44,921 | 20,500 | 41,000 | 1.43% |
| 5 | 26,000,000 | 1,820,000 | 74,120 | 26,000 | 52,000 | 1.43% |
| 6 | 33,000,000 | 2,310,000 | 122,298 | 33,000 | 66,000 | 1.43% |
| 7 | 42,000,000 | 2,940,000 | 201,792 | 42,000 | 84,000 | 1.43% |
| 8 | 53,300,000 | 3,731,000 | 332,957 | 53,300 | 106,600 | 1.43% |
| 9 | 67,700,000 | 4,739,000 | 549,378 | 67,700 | 135,400 | 1.43% |
| 10 | 86,000,000 | 6,020,000 | 906,474 | 86,000 | 172,000 | 1.43% |
| 11 | 109,200,000 | 7,644,000 | 1,495,683 | 109,200 | 218,400 | 1.43% |
| 12 | 138,700,000 | 9,709,000 | 2,467,876 | 138,700 | 277,400 | 1.43% |
| 13 | 176,000,000 | 12,320,000 | 4,071,996 | 176,000 | 352,000 | 1.43% |
| 14 | 223,700,000 | 15,659,000 | 6,718,793 | 223,700 | 447,400 | 1.43% |
| 15 | 284,000,000 | 19,880,000 | 11,086,009 | 284,000 | 568,000 | 1.43% |
| 16 | 360,700,000 | 25,249,000 | 18,291,915 | 360,700 | 721,400 | 1.43% |
| 17 | 458,000,000 | 32,060,000 | 30,181,659 | 458,000 | 916,000 | 1.43% |
| 18 | 581,700,000 | 40,719,000 | 49,799,737 | 581,700 | 1,163,400 | 1.43% |
| 19 | 738,700,000 | 51,709,000 | 82,169,567 | 738,700 | 1,477,400 | 1.43% |
| 20 | 938,200,000 | 65,674,000 | 135,579,785 | 938,200 | 1,876,400 | 1.43% |
| 21 | 1,191,500,000 | 83,405,000 | 223,706,645 | 1,191,500 | 2,383,000 | 1.43% |
| 22 | 1,513,200,000 | 105,924,000 | 369,115,964 | 1,513,200 | 3,026,400 | 1.43% |
| 23 | 1,921,700,000 | 134,519,000 | 609,041,341 | 1,921,700 | 3,843,400 | 1.43% |
| 24 | 2,440,500,000 | 170,835,000 | 1,004,918,212 | 2,440,500 | 4,881,000 | 1.43% |
| 25 | 3,099,500,000 | 216,965,000 | 1,658,115,050 | 3,099,500 | 6,199,000 | 1.43% |
| 26 | 3,936,300,000 | 275,541,000 | 2,735,889,832 | 3,936,300 | 7,872,600 | 1.43% |
| 27 | 4,999,200,000 | 349,944,000 | 4,514,218,223 | 4,999,200 | 9,998,400 | 1.43% |
| 28 | 6,349,000,000 | 444,430,000 | 7,448,460,067 | 6,349,000 | 12,698,000 | 1.43% |
| 29 | 8,063,200,000 | 564,424,000 | 12,289,959,111 | 8,063,200 | 16,126,400 | 1.43% |
| 30 | 10,240,200,000 | 716,814,000 | 20,278,432,534 | 10,240,200 | 20,480,400 | 1.43% |

Kiểm tra toán học: `30/30` cảnh q1 và q4 **nhỏ hơn** EXP tầng đầu. Thuốc luôn có tác dụng nhưng không được phép vượt một tầng chỉ vì có hệ số tăng nhanh; khi dùng vẫn chịu giới hạn tầng, chặn gate và tiêu thụ B3 như trước. Đây **không** phải xác nhận Godot đã chạy.

## Giai đoạn Linh Điền → Tử Vân Thảo → thuốc cảnh giới 2

| Mốc | Chi phí milestone đang có | Nguồn nhận | Ý nghĩa |
|---|---|---|---|
| Lv9 → Lv10 | 1 Linh Tuyền Chi Tâm = 100 mảnh | 5% mảnh/lượt thu hoạch cơ sở, tương đương kỳ vọng ~2.000 lượt để có 100 mảnh | Mở Tử Vân, không cấp sẵn |
| Lv19 → Lv20 | 2 Chi Tâm = 200 mảnh | nguồn cơ sở như trên | phát triển công suất/sản lượng |
| Lv29 → Lv30 | 3 Chi Tâm = 300 mảnh | nguồn cơ sở như trên | mốc nâng cấp cao hơn, không còn là điều kiện mở Tử Vân |

**Thận trọng:** số lượt trên là kỳ vọng thống kê độc lập mỗi lần thu hoạch với xác suất không đổi; không phải thời gian tối thiểu hay kết quả bảo đảm. Bonus Cơ Duyên, nhiều luống, tốc độ nghề, khoản cần khi nâng cấp và các nguồn hợp lệ khác có thể thay đổi. `AUTO_DEMAND` của SX01 hiện ưu tiên hai thuốc legacy; sản xuất thuốc r2 vẫn cần chọn recipe và policy phù hợp, chưa được coi là auto-demand full tier.

## Kiểm toán tiến độ 27 bậc và 3 giới

Chỉ làm phép đối chứng rất hạn chế: `base 1,000 EXP/phút × CULTIVATE_MULTIPLIER 2 = 2,000 EXP/phút`, **tu luyện 24h không nghỉ**, không tính nguồn tu luyện thụ động, PvE, đan, bonus, vật phẩm, đột phá, nghỉ, chi phí hay thời điểm phát triển công trình.

| Đến cuối cảnh | Tổng EXP | Ngày lý thuyết nguồn đơn 2,000/phút | Mục tiêu lịch Owner |
|---:|---:|---:|---:|
| 10 | 367,400,000 | 127.6 | ~90 ngày |
| 20 | 4,376,300,000 | 1519.5 | ~365 ngày |
| 30 | 48,130,600,000 | 16712.0 | ~730 ngày |

**Đây là lời cảnh báo cân bằng**: thuốc đã được điều chỉnh theo EXP từng cảnh, nhưng toàn bộ vòng tăng Tu Vi trong Nhân/Tiên/Thần vẫn phải có nguồn hiệu quả hợp pháp và mô phỏng một vòng New Game thật trước khi chốt mốc 3/12/24 tháng. Không tự cấp bonus ảo để vượt mục tiêu.

## Bảo toàn lịch sử

- `MedicineCatalogueV2.VERSION` tăng từ 1 → 2 chỉ dành cho **receipt đan phân cảnh giới mới**.
- Các receipt phiên bản 1 vẫn so với công thức lịch sử ×1.65 và giữ nguyên `medicine_potency`, `tuvi`, `sequence`; không đụng ID item, Warehouse, tên thuốc hoặc global SaveService version.
- Thuốc legacy `hoi_xuan_dan` vẫn 55 HP; auto SX01/CARE chỉ dùng nếu **thực hồi ≥2% maxHP**; dùng thủ công không đổi.
- Thuốc có `realm_rank` vượt cảnh Tu Vi của nhân vật bị từ chối ở B3 trước khi trừ tài nguyên (là cùng gate như chọn thuốc tự động).
- Linh Điền Lv10 cần **Chi Tâm thật**; giảm yêu cầu trồng Tử Vân Lv30→Lv10 không thay tỉ lệ rơi hoặc giá cây.
- Chưa chạy Godot trong môi trường phiên này. Các test cập nhật/chờ chạy: `sx02_medicine_catalogue_test.gd`, `sx01_pill_policy_test.gd`, `sx03_source_consumer_stage_contract_test.gd`, `sx03_bal04a_legacy_save_medicine_test.gd`, và các regression B3, O8, SaveService.
