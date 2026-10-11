# DV2-03F — Hồ sơ chốt thiết kế nguyên liệu & giao dịch 29 cổng Thối Thể

**Ngày rà soát:** 11/10/2026  
**Đối chiếu mã:** `main@55e4be5d1dbe267956791cb3db1a923708a5cbad`  
**Trạng thái mới nhất (11/10/2026, phương án A):** **F0 focused/full PASS; F1 MANIFEST + 15 ID ĐÃ CÓ CODE, FOCUSED PASS** (xem §Q; cumulative riêng cần xác minh live). F01–F12 vẫn chỉ duyệt về nguyên tắc, phạm vi tinh giản §O. Giữ 29 công thức, EXP và ba Ấn; **CHƯA DESIGN LOCKED**, **F2–F7 CHƯA CHO PHÉP CODE**. F1 chưa tạo rơi đồ/nguồn cao giới/giao dịch cổng; content thiếu tiếp tục fail-closed. Tài liệu này là phương án chốt cuối, không phải luật được triển khai.  
**Phạm vi:** chỉ Luyện Thể major gates `body.realm=1..29, floor=10`; không thay đổi Tu Vi, EXP, tần suất 60 giây/1 phút mô phỏng, tốc độ EXP, Căn Cốt, Rèn Thân Đường, vật liệu trang bị hay phép bổ trợ.

## A. Luật đã khóa, không cần biểu quyết lại

- Hai đường độc lập: 30 cảnh giới × 10 tầng, Nhân 1–10 / Tiên 11–20 / Thần 21–30; tên/order theo `docs/REALM_LADDER_V2_SPEC.md`.
- Cổng Luyện Thể tầng 10 dùng giá EXP `DiscipleProgressionBalanceV2.floor_cost(realm,10)`, cùng bảng 300 tầng. Yêu cầu EXP đủ cộng xác minh **toàn bộ** nguyên liệu/Ấn được duyệt ⇒ thành công **100%**. Không RNG, pity, thất bại mất EXP, generic trừ HP/thể lực, yêu cầu Tu Vi phải ngang Luyện Thể.
- Khi thành công, nhân vật chuyển `body: {realm:r+1,floor:1,xp:0}` bằng `DiscipleRealmProgressV2.commit_canonical_body_gate`, áp dụng `sync_live_hp` theo tỷ lệ HP hiện có; Tu Vi và tài sản cá nhân không đổi. EXP chờ ở gate không tự tạo Tích Tu.
- Kho duy nhất cho nguyên liệu stackable là `WarehouseSystem` / `SectState.warehouse_resources`, quyền `locked` và `reserve_min` bắt buộc tôn trọng; không đọc/trừ `forge_materials` hoặc `technique_materials` cũ.
- Rèn Thân Đường Lv1 2 slot, 1 Linh Thạch/phút hợp lệ, 1.500 EXP Luyện Thể nền/phút, +0,20% mỗi Căn Cốt: **KHÔNG thay đổi**. Không tự thêm phụ phí Linh Thạch vào thao tác đột phá.

## B. Đối chiếu khả thi với runtime thực (không nhầm đã có và sẽ làm)

| Đầu vào | Runtime hiện tại | Rủi ro và cách giải quyết **đề xuất** |
|---|---|---|
| `thanh_linh_thao` — Thanh Linh Thảo | Đã đăng ký; Linh Điền Lv1, 12 tick/chu kỳ, 3 cây cơ sở/thu hoạch, 4 Linh Thạch/gieo | Nguồn A chính có thể triển khai trên tuyến sản xuất hiện có |
| `tinh_lang_bi` — Tinh Lang Bì | Đã đăng ký; Bạch Thạch Khê/Hắc Phong Cốc, cơ chế thưởng PvE thực trả vật liệu khi thắng và chống claim trùng | Nguồn A phụ đã có tuyến săn; không đảm bảo chiến thắng/nhận nguyên liệu trước khi triển khai năng lực phù hợp |
| `tu_van_thao` — Tử Vân Thảo | Đã đăng ký; Linh Điền **Lv30** mới trồng, 24 tick/chu kỳ, 3 cây cơ sở, 14 Linh Thạch/gieo | **RỦI RO CỔ CHAI CỔNG 4**. Bắt buộc có tuyến đảm bảo thứ hai từ **ủy thác nguyên liệu Nhân Giới** khả dụng trước cổng 4; không bắt người chơi phải đạt Linh Điền Lv30 |
| `linh_tuy` — Linh Tủy | Đã đăng ký; rơi hiếm ở Thanh Trúc Lâm (thông số hiếm theo cấp bản đồ: 0% L1, 3% L2, 8% L3, 16% L4, 26% L5); chưa có hợp đồng cấp hàng bảo đảm | **RỦI RO CỔNG 4–6**. Thêm ủy thác/săn tích lũy đảm bảo, không phụ thuộc duy nhất vào RNG |
| Nhóm C–H | Chưa có 12 resource IDs tương ứng, crop/mine/drop/map cao giới; 3 bản đồ PvE hiện tại đều Nhân Giới thấp | **KHÔNG THỂ PHÁT HÀNH 29 CỔNG** trước khi có cả material registry + route phát sinh có chứng cứ + UI thấy được nguồn kiếm |
| `an_nhan_gioi`, `an_tien_gioi`, `an_than_gioi` | Chưa có item IDs, nguồn thưởng, ledger đổi thưởng | Bắt buộc là **vật phẩm tiêu hao stackable, kiếm lặp lại** cho nhiều đệ tử; không dùng cờ thành tựu chỉ thưởng đúng một lần cho cả tài khoản |
| Giao dịch cổng | `commit_canonical_body_gate(disciple, requirements_verified, event_id)` có EXP check, chống event replay trong lịch sử và HP sync, **chưa có quyền quyết định/trừ kho**; `WarehouseSystem.consume_requirements()` atomic trong phạm vi một dictionary kho nhưng **không gộp với mutation nhân vật** | Cần service giao dịch duy nhất + rollback + claim ledger persisted; tuyệt đối không cho UI truyền `requirements_verified=true` như quyền miễn phí |

Nguồn mới trong cột đề xuất là **CONTENT CẦN TRIỂN KHAI**, không được hiển thị như hiện có. Mọi vật liệu yêu cầu ở cổng `r → r+1` phải có ít nhất một nguồn hiệu lực ở vùng/hoạt động mà đệ tử tại `r` hoặc tổ đội tông môn đang sở hữu thực sự tiếp cận được; không tạo vòng khóa bởi cảnh giới `r+1` hoặc Tu Vi.

## C. ID rõ ràng, giữ 8 nhóm = 16 vật liệu và đúng 3 Ấn

| Nhóm, cổng | Vật liệu chính `main_id` | Vật liệu phụ `aux_id` | Nguồn định hướng |
|---|---|---|---|
| A, 1–3 | `thanh_linh_thao` **đã có** | `tinh_lang_bi` **đã có** | Linh Điền Nhân / săn yêu Nhân |
| B, 4–6 | `tu_van_thao` **đã có** | `linh_tuy` **đã có** | Linh Điền Lv30 **hoặc** ủy thác sớm / săn tích lũy hoặc rơi hiếm |
| C, 7–10 | `huyet_linh_sam` **MỚI** | `huyet_thu_tinh_huyet` **MỚI** | Dược liệu/hái thuốc Nhân cao / yêu thú Nhân cao |
| D, 11–14 | `kim_cot_thao` **MỚI** | `linh_thu_cot_ngoc` **MỚI** | Trồng/hái cấp Tiên thấp / tinh anh Tiên thấp |
| E, 15–17 | `tien_tuy_lien` **MỚI** | `tien_thu_chan_cot` **MỚI** | Dược liệu Tiên giữa / Tiên thú |
| F, 18–20 | `bat_hoai_tuy_dich` **MỚI** | `dai_la_kim_cot` **MỚI** | Dược liệu/tài nguyên Tiên cao / tinh anh/boss |
| G, 21–25 | `than_mach_tinh` **MỚI** | `than_thu_cot` **MỚI** | Khai khoáng Thần thấp/giữa / Thần thú |
| H, 26–29 | `hon_don_tuy_hoa` **MỚI** | `bat_diet_than_cot` **MỚI** | Thần/Hỗn Độn cao / tinh anh/boss Thần cao |

Ba vật phẩm bắt buộc **MỚI** tại đúng ba cổng:
- Gate 10 (`linh_than→kim_than`): `an_nhan_gioi × 1`.
- Gate 20 (`de_than→than_khu`): `an_tien_gioi × 1`.
- Gate 29 (`hon_don_than_the→sang_the_than_the`): `an_than_gioi × 1`.

**Kiểm kê:** 16 vật liệu = 4 ID đang có + **12 ID mới**; cộng **3 ID Ấn mới** ⇒ **15 tài nguyên mới** cần registry + source + tests. Đặt `realm_grade`, `realm_rank`, `family`, `tags`, `market_value` rõ ràng, **không dùng Phẩm Lực chung**. Không đồng nhất các nhóm A–H thành một tiền tệ hoặc đổi bừa khác loại.

## D. Manifest duy nhất: 29 công thức ĐÃ DUYỆT VỀ NGUYÊN TẮC

Mỗi dòng dùng *main × qty / aux × qty*, dấu `-` nghĩa là không có Ấn. Chỉ khi duyệt cuối mới chuyển các dòng thành content data.

| source realm → next | Đường cảnh giới | Nhóm | main_qty | aux_qty | seal |
|---|---|:---:|---:|---:|---|
| 1→2 | Phàm Thân → Luyện Bì | A | 12 | 4 | - |
| 2→3 | Luyện Bì → Luyện Nhục | A | 18 | 5 | - |
| 3→4 | Luyện Nhục → Dịch Cân | A | 24 | 6 | - |
| 4→5 | Dịch Cân → Đoán Cốt | B | 12 | 1 | - |
| 5→6 | Đoán Cốt → Thông Mạch | B | 16 | 2 | - |
| 6→7 | Thông Mạch → Tôi Tạng | B | 24 | 3 | - |
| 7→8 | Tôi Tạng → Luyện Huyết | C | 12 | 3 | - |
| 8→9 | Luyện Huyết → Khai Khiếu | C | 16 | 4 | - |
| 9→10 | Khai Khiếu → Linh Thân | C | 22 | 6 | - |
| 10→11 | Linh Thân → Kim Thân | C | 32 | 8 | `an_nhan_gioi × 1` |
| 11→12 | Kim Thân → Pháp Thân | D | 12 | 3 | - |
| 12→13 | Pháp Thân → Huyền Thân | D | 16 | 4 | - |
| 13→14 | Huyền Thân → Thánh Khu | D | 20 | 5 | - |
| 14→15 | Thánh Khu → Tiên Khu | D | 24 | 6 | - |
| 15→16 | Tiên Khu → Chân Thân | E | 12 | 3 | - |
| 16→17 | Chân Thân → Bất Hoại | E | 16 | 4 | - |
| 17→18 | Bất Hoại → Thái Ất Kim Thân | E | 22 | 6 | - |
| 18→19 | Thái Ất Kim Thân → Đại La Kim Thân | F | 14 | 4 | - |
| 19→20 | Đại La Kim Thân → Đế Thân | F | 20 | 6 | - |
| 20→21 | Đế Thân → Thần Khu | F | 30 | 9 | `an_tien_gioi × 1` |
| 21→22 | Thần Khu → Thần Cốt | G | 12 | 3 | - |
| 22→23 | Thần Cốt → Thần Mạch | G | 16 | 4 | - |
| 23→24 | Thần Mạch → Thần Tạng | G | 20 | 5 | - |
| 24→25 | Thần Tạng → Thần Tủy | G | 24 | 6 | - |
| 25→26 | Thần Tủy → Thần Khiếu | G | 30 | 8 | - |
| 26→27 | Thần Khiếu → Thần Thể | H | 12 | 3 | - |
| 27→28 | Thần Thể → Bất Diệt Thần Thể | H | 18 | 5 | - |
| 28→29 | Bất Diệt Thần Thể → Hỗn Độn Thần Thể | H | 24 | 7 | - |
| 29→30 | Hỗn Độn Thần Thể → Sáng Thế Thần Thể | H | 32 | 10 | `an_than_gioi × 1` |

**Tổng kiểm tra manifest cho một đệ tử đi hết 29 cổng:** **562 đơn vị nguyên liệu chính, 143 đơn vị nguyên liệu phụ, 3 Ấn**, phân bổ theo nhóm A 54/15; B 52/6; C 82/21; D 72/18; E 50/13; F 64/19; G 102/26; H 86/25. Đây là tổng vật phẩm nhiều loại, **không** phải tổng một loại tiền có thể thay thế nhau.

## E. Nguồn kiếm ĐA TUYẾN + BẢO ĐẢM: hợp đồng bắt buộc trước khi phát hành

**E1 — Mỗi ID có ít nhất hai nguồn.** Mỗi vật liệu chính: (a) sản xuất/hái/khoáng sản của đội hậu phương, (b) ủy thác vật liệu đúng cấp hoặc tuyến săn tài nguyên. Mỗi vật liệu phụ: (a) săn đúng bậc và có drop thưởng, (b) ủy thác/điểm đóng góp sự kiện săn **đủ mốc nhận chắc chắn đúng vật phẩm**, không cần drop một boss duy nhất. Nguồn (b) phải nhận được bằng hoạt động lặp lại có receipt và không đòi r+r khác khóa. Nhóm B có ủy thác sớm cho Tử Vân Thảo và Linh Tủy ngay trước cổng 4.

**E1.1 — Mốc mở nguồn theo cảnh giới Luyện Thể** (thiết kế đề xuất, không dựa vào Tu Vi):

| Nhóm | Cổng cần | Mốc nguồn mở chậm nhất | Nội dung tối thiểu phải triển khai |
|---|---|---|---|
| A | 1–3 | Ngay Phàm Thân 1 | Linh Điền Thanh Linh Thảo; bản đồ có Tinh Lang Bì |
| B | 4–6 | Trước Dịch Cân tầng 10 | Ủy thác Nhân Giới trả Tử Vân Thảo dù chưa có Linh Điền Lv30, săn tích lũy trả Linh Tủy |
| C | 7–10 | Trước Tôi Tạng tầng 10 | Thu hái Huyết Linh Sâm, săn Huyết Thú Tinh Huyết tại vùng Nhân cao |
| D | 11–14 | Trước Kim Thân tầng 10 | Vùng Tiên thấp, cây Kim Cốt Thảo và Linh Thú Cốt Ngọc |
| E | 15–17 | Trước Tiên Khu tầng 10 | Vùng Tiên giữa, Tiên Tủy Liên và Tiên Thú Chân Cốt |
| F | 18–20 | Trước Thái Ất Kim Thân tầng 10 | Vùng Tiên cao, Bất Hoại Tủy Dịch và Đại La Kim Cốt |
| G | 21–25 | Trước Thần Khu tầng 10 | Vùng Thần thấp/giữa, Thần Mạch Tinh và Thần Thú Cốt |
| H | 26–29 | Trước Thần Khiếu tầng 10 | Vùng Thần cao/Hỗn Độn, Hỗn Độn Tủy Hoa và Bất Diệt Thần Cốt |

Nguồn không tự mở ở cổng nếu chưa tạo được vật liệu khi đang ở **cảnh giới nguồn**. Có thể nhận vật liệu do đệ tử khác trong tông môn kiếm, miễn hoạt động đó thực hiện thành công và kho sở hữu. Một Đệ Tử có Luyện Thể cao, Tu Vi thấp không bị chặn bởi so sánh hai tiến độ.

**E2 — Bảo đảm KHÔNG phải tặng miễn phí theo đồng hồ.** Không `add` vật liệu vì người chơi chờ ngoài màn hình. Chỉ tăng kho sau thành tựu **thực đã hoàn thành**: thu hoạch thật, chu kỳ khai khoáng thật, lần săn thắng/claim thành công, hoặc ủy thác hoàn thành/đổi bằng một khoản giao dịch thật. Mỗi receipt nguồn có `source_id + event_id` duy nhất chống farm lại qua reload; progress nguồn riêng, không tạo Phẩm Lực/trung gian có thể thay mọi resource. Hợp đồng này là **new feature content**, chưa được code.

**E3 — Mốc thử để cân bằng, CHƯA KHÓA SỐ:** ưu tiên đạt **1 nguyên liệu chính / khoảng 10–12 phút sản xuất đủ điều kiện**, **1 nguyên liệu phụ / tối đa 4 lần săn/ủy thác hợp lệ có thành công**, áp dụng theo band và lực lượng tông môn. Ví dụ cổng 10 dùng 32 main → khoảng **5,3–6,4 giờ lao động đủ điều kiện** theo 1 luồng; 8 aux → tối đa 32 hoạt động săn hợp lệ theo tuyến bảo đảm. Đây **không phải** dự báo thời gian thật của game khi chưa mô phỏng lịch làm việc/map combat, và không thay số yield crop đã có. Phải test thu nhập thực từ production/quest trước khi triển khai mức này.

**E4 — Ba Ấn bắt buộc, kiếm lặp lại:** mỗi Ấn có hai đường tương đương: 
1. hoàn thành chiến dịch/boss phù hợp ở band **hiện tại** (chiến thắng + receipt; không tạo khóa sát thương dựa riêng trên Tu Vi), hoặc
2. hoàn tất chuỗi ủy thác/tích lũy chiến công từ tổ đội rồi đổi lấy **đúng 1 Ấn**. Mốc gợi ý thử: tối đa khoảng **8 lần săn hợp lệ** cho 1 Ấn; phải bổ sung hệ nhiệm vụ/công lao và xác nhận thời gian thực trước khi quyết định số. Có thể sản xuất lại vô hạn số Ấn nếu chiến dịch được thực hiện lại, để không khóa đội hình 1.000–3.000 đệ tử vào reward một lần duy nhất.

**E5 — Gating nguồn:** xác minh `source_realm<=gate_source_realm`, vùng/hoạt động mở bằng combat viability/tổ đội/hạ tầng chứ không bắt Tu Vi và Luyện Thể bằng nhau; không đặt cùng vật liệu ở nguồn chỉ mở sau khi đã dùng chính vật liệu đó để vượt gate. Toàn bộ nguồn C–H chỉ được bật cùng content khu vực/địa điểm tương ứng; cổng không được yêu cầu ID chưa có đường kiếm.

**E6 — Nguồn thuộc tông môn, phân bổ tự động:** săn/thu hoạch thật phát vào **Kho Tông Môn**, không phát item vào túi cá nhân lâu dài. Giữ nguyên `locked/reserve_min`; hệ AI muốn tự đột phá chỉ dùng **available quantity**, không được ăn vật liệu do chưởng môn khóa. Bản quản lý có lọc theo thiếu loại nguyên liệu, số đệ tử đủ EXP và số bộ đủ nguyên liệu; khuyến cáo dự trữ theo số đệ tử đang chờ. Không giới hạn sức chứa kho.

**Hàng rào phát hành:** Nếu 1 trong 29 cổng chưa có **resource definition + source production/loot + deterministic acquisition path + tests**, cổng đó phải báo `content_unavailable`, không gọi gate commit bằng `true` và không tự thay nguyên liệu khác.

## E7. Kiểm tra nhu cầu vật liệu theo dữ liệu live

- A: 54 Thanh Linh Thảo qua ba cổng đầu, tương ứng 18 lần thu hoạch cơ sở (3 cây/lần) và 216 phút mô phỏng với một ô trồng liên tục (12 tick/chu kỳ), cần 72 Linh Thạch gieo trồng. 15 Tinh Lang Bì có thể lấy từ khoảng 8 lượt săn thắng ở Bạch Thạch Khê/Hắc Phong Cốc cấp 1 theo thưởng 2 cái/lượt; thời gian thực tế phụ thuộc sức mạnh.
- B: 52 Tử Vân Thảo tương ứng 18 lần thu hoạch, 432 phút mô phỏng, 252 Linh Thạch gieo, **nhưng Linh Điền phải đạt Lv30**. Đây là lý do tuyến ủy thác sớm là điều kiện phát hành bắt buộc. 6 Linh Tủy từ roll hiếm 26% cấp 5 có kỳ vọng khoảng 23 trận thắng; ở cấp 2 tỷ lệ 3% tương đương khoảng 200 trận trung bình. Không dùng kỳ vọng RNG làm bảo đảm.
- Tổng cho một đệ tử đi hết 29 cổng: 562 vật liệu chính, 143 vật liệu phụ và 3 Ấn, thuộc nhiều ID khác nhau. Với 1.000 đệ tử, nhu cầu dài hạn là 562.000 / 143.000 / 3.000; với 3.000 đệ tử là 1.686.000 / 429.000 / 9.000. Đây là nhu cầu tích lũy nhiều năm/cảnh giới, không phải yêu cầu cấp phát đồng thời.
- Tài nguyên nên tích lũy song song trong giai đoạn luyện EXP. Không biến mốc cung 2–8 giờ đủ điều kiện (chưa cân bằng thật) thành thời gian chờ thêm sau khi đệ tử đủ EXP.

## F. Service và schema đề xuất, chỉ thiết kế — chưa code

**Chủ sở hữu mới cần tạo sau phê duyệt:** `DiscipleBodyGateContentV2` (immutable 29-entry manifest, tham chiếu 19 resource IDs trong registry, trong đó 15 IDs mới), `DiscipleBodyGateTransactionV2` (sole mutation owner), `BodyGateAcquisitionV2` hoặc rõ từng source-owner để tạo receipt thực. Không cho UI hoặc third-party caller tự truyền `requirements_verified=true` đến low-level adapter. Giữ `DiscipleRealmProgressV2` là chủ diễn tiến/HP chính tắc, `WarehouseSystem` là chủ kho.

**Manifest item (logic format):**
```text
{
  source_realm: 10,
  target_realm: 11,
  main_id: "huyet_linh_sam",
  main_qty: 32,
  aux_id: "huyet_thu_tinh_huyet",
  aux_qty: 8,
  seal_id: "an_nhan_gioi",
  seal_qty: 1,
  required_body_floor: 10,
  economy_version: "dv2-03f-v1"
}
```
Runtime khẳng định `source_realm` chính là giá trị từ hồ sơ đệ tử. Không cho caller tùy chọn công thức/rate/nguồn gốc. Contract validate đúng 29 rows, continuous 1..29, target=source+1, positive integer quantities, sealed only gate 10/20/29, IDs distinct/registered, source present, EXP từ `DiscipleProgressionBalanceV2`, body deterministic từ `DiscipleBreakthroughBalanceV2`.

**Preview API (pure, không mutate):** `preview_gate(state,disciple_id)` trả `source_realm`, `xp_have/xp_need`, named requirements `qty_need / qty_total / qty_available`, `locked/reserve_min`, `seal`, `content_active`, `can_commit`, and named block reason (`major_gate_not_ready`, `gate_xp_incomplete`, `material_missing`, `material_locked_or_reserved`, `acquisition_source_unavailable`, `body_gate_content_unapproved`). Ngay khi UI hiển thị không trừ vật liệu hay EXP.

**Commit API (sole mutation authority):** `commit_gate(state,disciple_id,request_id)` lấy authoritative target từ actor/manifest; **request_id** là khóa chống nhấn lại, không phải quyền quyết định. Resource costs luôn đi từ manifest bất biến; không nhận `requirements_verified` hay lượng chi phí từ UI; no RNG.

## G. Giao dịch **ALL-OR-NOTHING** trong mô phỏng và save/load

**G1. Tiền điều kiện bắt buộc (không mutate):**
1. `state` hợp lệ, quyền V2/warehouse enabled, actor thuộc state, V2 identity/progression chuẩn, dữ liệu HP/runtime hợp lệ theo schema **không thêm ngưỡng HP mới**, `body.realm` 1..29, `body.floor=10`.
2. `xp >= floor_cost(realm,10)` chính xác theo canonical curve.
3. Manifest đã duyệt đúng `economy_version`; 19 resource IDs tồn tại (mới/đã có), tất cả nguồn của dòng đã bật; chỉ Ấn đúng gate 10/20/29.
4. Kho đủ **available**, sau khi áp dụng `locked` và `reserve_min`; không `ignore_rules=true`, không âm/tràn số lượng; kiểm tra đủ tất cả nguyên liệu + Ấn **trước lần trừ đầu tiên**.
5. Khóa định danh logic `disciple_id + source_realm` chưa có success receipt; `request_id` chưa bị dùng cho giao dịch khác; `body.breakthrough_history` và ledger không mâu thuẫn. Dùng thứ tự đệ tử/event canonical để không giành vật liệu thiếu theo iteration order ngẫu nhiên.

**G2. Commit trong một scheduler event đồng bộ, không `await` hoặc UI callback xen ngang:**
1. Ghi ảnh chụp tối thiểu: `disciple.v2_realm_progress.body`, `hp/max_hp`, `sect.warehouse_resources` đối với ID liên quan, `sect.warehouse_event_count`, ledger receipt/event counter.
2. Gọi canonical `DiscipleRealmProgressV2.commit_canonical_body_gate(disciple,true,event_id)` **chỉ từ service sau khi toàn bộ tiền điều kiện đã được xác minh**; mã tự đối chiếu EXP, hồ sơ, HP sync.
3. Nếu canonical commit lỗi → **không trừ kho**, giữ nguyên mọi trạng thái.
4. Nếu canonical thành công, gọi `WarehouseSystem.consume_requirements(state,authoritative_requirements,false)` để trừ **cả gói** sau khi đối chiếu lại; nếu kho lỗi/đổi → phục hồi toàn bộ snapshot actor/HP/kho/event counter, return `transaction_rolled_back`.
5. Chốt một receipt bất biến trong `SectState.body_gate_claims` (tên trường chỉ là proposal) chứa `disciple_id,source_realm,target_realm,event_id,manifest_version,resource_delta,body_before/after,committed_tick`. Receipt cùng actor + kho là **một phần của cùng SimulationState**, đi qua save/load hiện có; không tách ra tệp lưu riêng. Gắn `breakthrough_history` event_id tương ứng.
6. Chỉ sau commit thành công mới phát UI/vfx/notification (và cập nhật hiệu ứng chỉ số đã có). Không tạo thêm EXP, thưởng HP, Linh Thạch hay giảm thể lực.

**G3. Lặp lệnh / save/load:** Nhận `request_id` cũ phải khớp cùng actor/cổng và receipt đã persist: trả `already_committed` cùng receipt, **0 vật liệu trừ thêm**, **0 tiến cảnh giới thêm**. Nếu event_id đã có trong lịch sử nhưng kho/ledger không khớp ⇒ lỗi dữ liệu fail-closed, không lấy đồ thêm. Sau restore, một lần nhấn lại/gọi offline trùng không tạo thêm chi phí hay reward. `source_realm` tăng sau thành công, nên gate success của cùng realm không được commit hai lần.

**G4. Biên giới bền vững trên đĩa:** `SaveService.save_to_path` hiện ghi trực tiếp tệp đích (`FileAccess.WRITE`). Tính nhất quán của mutation trong bộ nhớ **không tự bảo đảm** file không bị cắt nếu crash/mất điện khi lưu. Để hứa *disk crash safety*, bước implement phải thêm kiểm thử ghi file tạm + flush/fsync khi API hỗ trợ + replace/rename an toàn trên Windows/Linux + recovery, hoặc explicitly scope save durability khác; **không được tuyên bố chống crash tuyệt đối chỉ từ test serialization JSON**.

**G5. Đua tranh/người dùng bấm nhanh:** Simulation/state mutation single-authority/single-thread trong một tick; nhiều disciple cùng dùng Ấn cuối cùng được phục vụ theo thứ tự ổn định, người sau nhận `material_missing` và giữ nguyên EXP. Nếu tương lai có worker/background dispatch, bắt buộc serialize command hoặc dùng reservation lock. Tất cả nguồn vật liệu/phần thưởng khác nhau phải qua warehouse owner.

## H. UI/AI và nghiệm thu cần có khi được phép code

- Giao diện cổng trong hồ sơ `Luyện Thể`: `Đủ EXP: x/y`, **Loại × cần / hiện có / khả dụng**, `Đang khóa/dự trữ`, tên/đường kiếm cho mỗi loại, tên Ấn và nguồn, nút `Thối Thể` chỉ khả dụng khi preflight thực cho phép.
- Bấm một lần: hiển thị giao dịch chờ? **Không** tạo pending ảo; xử lý đồng bộ theo state, receipt idempotent; báo thiếu vật phẩm hoặc thành công, theo nguyên nhân thực. Khi thành công chuyển đại cảnh/tầng, giữ thông tin lịch sử cá nhân và HP ratio.
- Chính sách AI tự đột phá nếu có: chỉ thực hiện khi được bật và có cùng quyền preflight, tôn trọng nguyên liệu khóa/các phân bổ khác; tắt mặc định nếu chưa được duyệt. Không tiêu hàng tông môn chỉ vì một flag UI hoặc timer.
- Khi nhóm C–H chưa đủ nguồn, UI hiện `Chưa mở nội dung`; tuyệt đối không hiện nút xanh dùng placeholder để qua gate.

### Required regression suite (chỉ là yêu cầu để triển khai)

1. **29/29 manifest rows:** đúng ID, số lượng, source/target, tổng A–H, đúng 3 Ấn.
2. **Pure preview:** preview liên tục không đổi state/warehouse/progress/save dirty/event counters.
3. **Happy path:** đầy đủ đúng số → giảm đúng mọi ID, tăng đúng realm+1/floor1, XP gate reset 0, Tu Vi giữ nguyên, tỷ lệ HP giữ nguyên, một receipt.
4. **All fail states:** thiếu từng 1 item, locked, reserve, thiếu Ấn, thiếu EXP 1 điểm, thiếu content/source, malformed actor, bad realm, no warehouse, unauthorized request, maximum realm30 → **không đổi bất cứ tài nguyên/EXP/HP nào**.
5. **Atomicity fault injection:** lỗi HP sync/canonical commit/warehouse commit ⇒ rollback nguyên vẹn state (kể cả audit counter), không có partial spend.
6. **Idempotence:** double-click same request, retry different request at same realm, simultaneous two disciples against one last Ấn, replay load; only one valid spend.
7. **Save/offline:** persisted receipt + warehouse + body; restore yields exactly-once across process restart; test incomplete save writer/recovery for disk safety separately.
8. **Acquisition actual source:** A/B hiện có và ủy thác bảo đảm, C–H newly-authored full routes, boss path và alternate Ấn, reward idempotence, access before gate, no invalid resource injection.
9. **1.000–3.000 roster:** preview read-efficient, không scan toàn bộ đệ tử để mở một gate, batch AI ổn định, ít nhất hai đệ tử tranh nguồn cùng tick.
10. **Godot official focused + P0→P3.7 full cumulative**, Godot Windows real/visual **PENDING USER**, không tự gọi PASS.

## I. Quyết định cuối cần chốt trước khi lập trình

**Mặc định khuyến nghị cho bản đầu:** giữ đúng 29 công thức ở bảng D; nhóm B có ủy thác sớm cho cả Tử Vân Thảo/Linh Tủy; nhóm C–H phát hành cùng nội dung vùng/nguồn; 3 Ấn là stackable và kiếm lặp lại qua chiến dịch **hoặc** ủy thác; tự động dùng vật liệu của AI **tắt**, cần người chơi cho phép; sink vật liệu không kèm thêm Linh Thạch cổng. Các tốc độ nguồn E3/E4 là **mục tiêu kiểm thử cần duyệt sau khi đo**, không phải công thức đã khóa.

Nếu người chơi đồng ý bản hồ sơ này: cập nhật trạng thái `DESIGN LOCKED` **sau chấp thuận rõ ràng**, rồi mới code từng lát: (1) manifest/registry/test; (2) acquisition guarantee A/B + C–H source contracts/map content theo vùng; (3) gate transaction rollback + ledger + persistence; (4) UI/AI/real Godot focused+full; (5) Windows visual acceptance. Không tự tạo vật phẩm/nguồn loot giả để thử nghiệm production.


## J. Tham khảo source ZQZS trực tiếp — nghiên cứu client, KHÔNG là luật Tông Môn Bá Đạo (11/10/2026)

**Kho đọc:** `vuanhtuan161094-byte/ZQZS-Source-Knowledge@a9a638b6049756038ae199fae90e47e2d02829a4`. Đây là code Lua client/config text và IL2CPP metadata, không phải quyền truy cập server. Hai bản APK/AndroidData cùng hash cho `uidisciplemodel_lianti`, `uidiscipleliantiwin` và `config.disciplelianticonfig`; bản `uidisciplemodel_cuiti` và `config.discipleqizhencuiticonfig` **khác** giữa biến thể, chưa chứng minh loader đang ưu tiên bản nào. **VERIFIED chỉ trong client được đọc**, server commit/roll/source drop vẫn UNKNOWN. Tuyệt đối không chuyển mã, numeric config, vật phẩm thương mại hay asset sang Godot.

**Bằng chứng đã đọc (đường dẫn dưới `sources/AndroidData/`):**
- `binary/gui.windows.disciple.uidisciplemodel_lianti_TextAsset_-3605558273660236947.bin.lua`, **dòng 73–87**: `canDiscipleLTAutoUpX` coi EXP đạt ngưỡng và không có `consume` là auto cấp nhỏ. **Dòng 98–146**: khi có `consume`, hiển thị/kiểm tra cổng, gồm ràng buộc `jingjie` theo Tu Vi. **Dòng 174–189**: `getDiscipleLTBrokeCost` đọc `consume` và chọn vật liệu theo **Linh Căn đặc thù nhân vật**; **dòng 149–171** dò vật liệu thiếu và khả năng hợp thành.
- `data/config.disciplelianticonfig_TextAsset_-5066420141919399574.bin.lua` có 151 bản ghi (phân tích trước) và **14 dòng `consume=`** trong bản sao nghiên cứu; các cổng là mốc chọn lọc, khác thang 29 cổng của ta. Cấu hình định hướng theo nhân vật này là **pattern phân giải recipe**, không phải số lượng/công thức được phép copy.
- `binary/gui.windows.disciple.uidiscipleliantiwin_TextAsset_5379721948997599315.bin.lua`, **dòng 911–950**: panel so số lượng có/cần, chuyển nút vật liệu đủ sang tips hoặc thiếu sang gain; **dòng 1243–1279**: preflight rồi gọi controller, UI phản hồi theo thay đổi net state.
- `binary/gui.windows.disciple.uidisciplecontroller_TextAsset_-5296837087602791939.bin.lua`, **dòng 108–124**: quét danh sách các đệ tử đủ điều kiện auto tăng cấp nhỏ; **dòng 299–306** gửi lệnh Luyện Thể một người hoặc danh sách; **dòng 1259–1280** nhận server response cấp/EXP rồi mới cập nhật client. Không chứng minh server atomic hay cơ chế chống replay.
- `binary/gamesys.gainsystem.gaincontrol_TextAsset_-8606478595354109705.bin.lua`, **dòng 354–401**: panel nguồn kiếm dựa `itemsConfig.produce`. Các target nguồn kiếm thuộc config, nhưng không phải chứng cứ đảm bảo xác suất/có thể kiếm vô hạn.
- `binary/gui.windows.disciple.uidisciplemodel_cuiti_TextAsset_-4772247432498440986.bin.lua`, **dòng 86–143** ở AndroidData: Thối Thể phụ trợ có EXP và nhóm vật liệu theo nghề; **dòng 250–271** tổng hợp nguyên liệu tiêu qua các cấp phục vụ reset/preview. `binary/gui.windows.disciple.uidisciplecontroller_cuiti_TextAsset_-5553148281651440240.bin.lua`, **dòng 31–60** gửi nâng qua `2_88` và nhận cập nhật `qzctlv/qzctexp`; `binary/gui.windows.disciple.uidisciplecuitiwin_TextAsset_-4017427498703974329.bin.lua` **dòng 199–289** hiển thị chi phí, giới hạn theo Luyện Thể, thiếu nguyên liệu thì mở panel nguồn; đây là **hệ Thối Thể bổ trợ riêng**, không được đồng nhất 1:1 với 29 Body major gates của ta.

**Áp dụng độc lập cho DV2-03F sau khi người dùng chốt cuối:**
1. Giữ manifest **8 nhóm/29 recipe/3 Ấn cố định như đã duyệt về nguyên tắc**, chỉ dùng source để học mô hình **EXP tự lên tầng nhỏ → major gate có điều kiện**, material preview và `gain route` cho từng ID.
2. UI thiếu vật liệu bấm được sẽ hiển thị **đúng nơi kiếm đã triển khai**, rõ đường chắc chắn/đường may rủi, số hiện có/khả dụng/dự trữ; hợp thành/ủy thác **chỉ bật sau khi có consumer thật**, tuyệt đối không làm nút trang trí.
3. Từ pattern auto-list để thiết kế batch AI preflight cho 1.000–3.000 đệ tử, **nhưng mặc định AUTO BODY GATE OFF và không được bỏ qua kho khóa**, mỗi actor là giao dịch atomic idempotent riêng.
4. **KHÔNG học khóa `Tu Vi >= JingJie` của bản nguồn**; luật của ta đã chốt hai tiến độ độc lập. Không học số liệu gốc, không bắt nguồn rare-only, không coi network response của source là bằng chứng atomicity.
5. Không thêm hệ `cuiti` thứ hai / linh căn pha trộn để tự ý sửa manifest 29 cổng. Có thể dùng nhóm hành vi preview/material recovery làm inspiration UX về sau, không đụng balance.


## K. Bước 1 — kiểm chứng bổ sung ZQZS và khả thi nguồn (11/10/2026, RESEARCH ONLY)

**Live refs đã đọc:** game `main@be799f553e03a7afab1edfea95d44de0b896c4a0`, source ZQZS `main@a9a638b6049756038ae199fae90e47e2d02829a4`. GitHub compare `3c7e9a76..be799f55`: 16 commits chỉ thay `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md` và 2 tài liệu DV2-03, không có source/test gameplay đổi. Workflow [focused #38093450321](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38093450321) và [cumulative #38093450298](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38093450298) trực tiếp trả `completed/success`, gameplay/test SHA `3c7e9a7691f549097dd0a67ed50ead8b7be18a4c`. **Không có kiểm thử Windows hay Godot mới trong lượt nghiên cứu này.**

**Bằng chứng mới ở source ZQZS** (mặc định `sources/AndroidData/binary/`, client VERIFIED, server UNKNOWN):

- `gamesys.hechenglianhuasystem.hechenglianhuamodel_TextAsset_-7285679468693537301.bin.lua`: `getIsCan` dòng 153–196 đối chiếu vật liệu và gọi `gainControl` khi thiếu; `getMaxLianHuaCount` dòng 352–384 kiểm tra số lượng có thể hợp thành; `getItemIdToHCConfigId` dòng 386+ nối item với công thức. `gamesys.hechenglianhuasystem.hechenglianhuacontroller_TextAsset_292681191518947904.bin.lua` dòng 56–66/105–109 gửi yêu cầu hợp thành đơn hoặc theo lô lên server. **Chứng minh có UX/command hợp thành, KHÔNG chứng minh công thức Luyện Thể nào luôn hợp thành được, chắc chắn thành công hoặc server trừ kho nguyên tử.**
- `gamesys.catentrustsystem.catentrustcontroller_TextAsset_777409892241267993.bin.lua` dòng 68–85/105–139 có yêu cầu ủy thác theo danh sách và response cập nhật. **Chứng minh tồn tại giao diện/command ủy thác; KHÔNG chứng minh ủy thác cấp đúng một nguyên liệu Body gate hoặc nguồn farm bảo đảm.**
- `gamesys.mysterysystem.mysteryshop.mysteryshopcontroller_TextAsset_3248466917533303608.bin.lua` dòng 164–173/182–203 kiểm tra có thể mua, gửi lệnh và cập nhật hàng hóa trên response. **Chứng minh shop thực ở tầng client; không chứng minh Ấn hay nguyên liệu Luyện Thể có bán hoặc mua được lặp vô hạn.**
- `gamesys.bagsystem.bagmodel_TextAsset_1470927556504317747.bin.lua` dòng 71–80/183–274/524+ có khởi tạo, cập nhật và đọc số lượng item phía client; không có bằng chứng server idempotency/body+bag atomic từ đó.
- Đối chiếu hai biến thể thực tế: `uidisciplemodel_lianti` và `config.disciplelianticonfig` cùng Git blob hash APK/AndroidData, nhưng `uidisciplecontroller` và `uidisciplemodel_cuiti` khác hash. Chưa xác định loader chọn bản nào; không suy ra body gate server từ phiên bản client.

**Đối chiếu DV2-03F hiện tại** (main gameplay VERIFIED): `spirit_crop_registry.gd` khóa Tử Vân Thảo ở Linh Điền Lv30; `hunting_map_v2.gd` đặt Linh Tủy theo xác suất rare từ 0%–26% tùy độ khó; `warehouse_system.gd` có bảo vệ `locked/reserve_min` và tiêu gói trong kho; `disciple_realm_progress_v2.gd` chỉ chấp nhận `requirements_verified: bool` từ bên ngoài, chưa sở hữu recipe + debit; `save_service.gd` ghi trực tiếp bằng `FileAccess.WRITE`, chưa có disk crash-safety. **Không ghi sai thành 29 cổng đã vận hành.**

**Đánh giá vận hành:** 29 recipe gồm 562 main + 143 aux + 3 Ấn mỗi đệ tử; tương ứng 1.000–3.000 đệ tử là 562.000–1.686.000 main, 143.000–429.000 aux, 3.000–9.000 Ấn tích lũy cả chặng dài. Mốc thí điểm 8 hoạt động/1 Ấn nếu áp đồng nhất sẽ hàm ý 24.000–72.000 hoạt động đủ điều kiện cho các Ấn toàn roster; đây là **số lượt logic để stress-test thông lượng**, không phải nhịp chơi thật đã đo. Tránh auto-farm đơn vị một cách vô nghĩa; ưu tiên chiến dịch/ủy thác theo lô có output hữu hạn, receipt theo sự kiện, queue ưu tiên cho nhóm đệ tử và preflight riêng từng actor.

**Khuyến nghị bước kế:** giữ nguyên 8 nhóm/29 công thức/3 Ấn ở trạng thái `PRINCIPLE APPROVED / FINAL REVIEW PENDING`. Trước khi duyệt code cần chứng minh tuyến sớm B, ngưỡng cung C–H theo mỗi vùng, cấp phát Ấn lặp lại, và hợp đồng transaction all-or-nothing + receipt + save durability. Mọi nguồn mới nêu trên là **đề xuất**, tuyệt đối không tô thành runtime thực hay `DESIGN LOCKED`.


## L. DV2-03F / BƯỚC 2 — Nguồn bảo đảm A–H, 3 Ấn và tải kinh tế 1.000–3.000 đệ tử (11/10/2026)

> **RESEARCH + PILOT ONLY — NOT DESIGN LOCKED, NOT CODE.** Live checked: game main `28612009172d9605bf0564e317cfe2e6729903ca`; latest gameplay/test `3c7e9a7691f549097dd0a67ed50ead8b7be18a4c`; `3c7e9a76..28612009` has only doc changes. All formulas D, Tu Vi, Body EXP, Căn Cốt, 2 training slots, current production mechanics remain unchanged. The suggested throughput parameters below need the user's final approval and real Godot simulation; they are not existing content.

### L1. Current actual production and acquisition code checked

1. `godot/src/simulation/core/simulation_runtime_clock_v2.gd`, lines 5–10/74–90: **60 real seconds = one simulation minute/tick**. `simulation_scheduler.gd`, lines 30–48: one tick processes buildings first, then disciples in sorted ID order; `HuntingPveRunV2` is still an opt-in V2 engagement path, not migrated to the legacy general scheduler.
2. `godot/src/simulation/building/spirit_crop_registry.gd`, lines 8–50: Thanh Linh Thảo Lv1, 12 ticks/3 yield/4 stones per plant, stock_target=40; Tử Vân Thảo Lv30, 24 ticks/3 yield/14 stones per plant, stock_target=20. `building_system.gd`, lines 74–92/208–221: **Lv1 field has four plots and four work slots**, +1/5 levels; lines 540–598 start one paid plot with reserved worker; lines 725–775 settle harvest and deposit to main warehouse; lines 908–949 choose crop from fixed/priority/static-stock policy. Crop cycle changes through field level, worker speed, affinity and rare factors, so base numbers are **not** measured player throughput.
3. `godot/src/simulation/combat/hunting_map_v2.gd`, lines 9–37: three low Nhân regions only; Bạch Thạch Khê and Hắc Phong Cốc each give `tinh_lang_bi` as normal loot if actual valid victory reward is claimed. Thanh Trúc Lâm has `linh_tuy` as rare item; chance by difficulty 0%, 3%, 8%, 16%, 26%. Lines 122–170: `preview_reward` is pure, `claim_reward` requires true finished victory, checks registered materials and `v2_pve_reward_claims[encounter_id]`. No other current deterministic Linh Tủy payout proven.
4. `godot/src/simulation/resource/warehouse_system.gd`, lines 38–45/87–116: `available_quantity` obeys lock/reserve; `consume_requirements` checks the entire package before changing warehouse. This is **not yet a joint Body+Warehouse transaction**. `godot/src/simulation/technique/technique_system.gd`, lines 245–255: selling actual manuals returns Sect Spirit Stones; `initialize` sets 500 initial stones in fresh compatible states. This does **not establish** a sustained money-per-day rate. `linh_tuy` is also used in technique/material consumers; cannot allocate all stock blindly to Body.
5. `godot/src/simulation/workforce/workforce_system.gd`, lines 248–350: priority, direct commands and work/cultivate schedule; 20-tick shift cycling and active farming only when physically assigned; `building_system.gd` lines 459–475 process plots even when UI is closed. Default fixed crop `stock_target` is not a genuine 1,000–3,000 disciple gate-demand forecast.
6. `godot/src/simulation/cultivation/disciple_progression_balance_v2.gd`, lines 18–35: canonical Body EXP rates/ref values already fixed; **don't tune them**. For context, the first 10-million-EXP realm alone takes about 6,667 valid minutes at base 1,500 EXP/min for one continuously occupied paid training slot (without Căn Cốt). Two slots are specialization, **not** a throughput source for all 3,000 disciples simultaneously.

### L2. Exact audited 29-row ledger, aggregates, and demand

No change to 29 manifest rows in section D. `main/aux` item counts per single disciple progressing through the group's gates:

| Group | Gates | Main ID | Aux ID | 1 disciple main/aux | 1,000 main/aux | 3,000 main/aux |
|---|---|---|---|---:|---:|---:|
| A | 1–3 | thanh_linh_thao | tinh_lang_bi | 54/15 | 54,000/15,000 | 162,000/45,000 |
| B | 4–6 | tu_van_thao | linh_tuy | 52/6 | 52,000/6,000 | 156,000/18,000 |
| C | 7–10 | huyet_linh_sam | huyet_thu_tinh_huyet | 82/21 | 82,000/21,000 | 246,000/63,000 |
| D | 11–14 | kim_cot_thao | linh_thu_cot_ngoc | 72/18 | 72,000/18,000 | 216,000/54,000 |
| E | 15–17 | tien_tuy_lien | tien_thu_chan_cot | 50/13 | 50,000/13,000 | 150,000/39,000 |
| F | 18–20 | bat_hoai_tuy_dich | dai_la_kim_cot | 64/19 | 64,000/19,000 | 192,000/57,000 |
| G | 21–25 | than_mach_tinh | than_thu_cot | 102/26 | 102,000/26,000 | 306,000/78,000 |
| H | 26–29 | hon_don_tuy_hoa | bat_diet_than_cot | 86/25 | 86,000/25,000 | 258,000/75,000 |
| **Total** | **29** | | | **562/143** | **562,000/143,000** | **1,686,000/429,000** |

Plus `an_nhan_gioi` for gate10, `an_tien_gioi` for gate20, `an_than_gioi` for gate29: **3/1 disciple; 3,000/1k; 9,000/3k**. This is **long-run cumulative demand** assuming every disciple traverses every gate, not an early-game simultaneous inventory objective.

### L3. Concrete **proposed** acquisition contract, by group

**Same underlying two-source requirement per ID**: (a) profession/plot/extraction or appropriate monster win as the flavorful principal path; (b) a repeatable, typed and real-work **ủy thác / campaign point** fallback. Main and auxiliary routes must produce the named registered ID; no universal item-to-any-material currency. A successful source action deposits to the **one canonical Sect Warehouse** and has immutable `source_id+event_id` replay protection. Time elapsed with no eligible job/worker/victory can never mint loot. A route must be accessible by a team *at or below* the required source Body realm, with no equality requirement against Tu Vi.

| Group | Must unlock no later than | Main principal route, alternate guaranteed route | Aux principal route, alternate guaranteed route |
|---|---|---|---|
| A | From Phàm Thân 1 | **Existing:** Lv1 Thanh Linh Thảo field. **Proposed:** early active herb-gathering commission, deterministic named payout after completed worker cycles | **Existing:** true-victory Bạch Thạch Khê/Hắc Phong Cốc normal Tinh Lang Bì. **Proposed:** repeatable low-Nhân hunting commission for named pelt |
| B | Before Dịch Cân floor10, preferably beginning of r3/r4 | **Existing but late:** Lv30 Tử Vân Thảo field. **Required new early:** Nhân herb-delivery commission guaranteeing Tử Vân Thảo, no Lv30 farm, no target Body r5, no dependence on `linh_tuy` as input | **Existing RNG:** Thanh Trúc Lâm difficulty 2–5 Linh Tủy. **Required new:** four qualifying wins/field patrol completions at an accessible lower-Nhân site guarantee a named Linh Tủy, boss/drop RNG irrelevant |
| C | Before Tôi Tạng floor10 (r7 gate) | **New:** high-Nhân Huyết Linh Sâm herb/foraging field; repeatable proper-band gathering commission | **New:** high-Nhân blood-beast victories, rare elite bonus; deterministic high-Nhân hunt/commission completed-credit reward for Huyết Thú Tinh Huyết |
| D | Before Kim Thân floor10 (r11 gate) | **New:** low-Tiên Kim Cốt Thảo planting/foraging; independent low-Tiên supply commission | **New:** low-Tiên spirit-beast/elite loot + proper-band repeatable guaranteed material contract for Linh Thú Cốt Ngọc |
| E | Before Tiên Khu floor10 (r15 gate) | **New:** mid-Tiên Tiên Tủy Liên habitat/pond gather; mid-Tiên repeatable supply expedition | **New:** mid-Tiên beast/boss loot + guaranteed campaign material progress for Tiên Thú Chân Cốt |
| F | Before Thái Ất Kim Thân floor10 (r18 gate) | **New:** high-Tiên Bất Hoại Tủy Dịch gathering resource; typed high-Tiên repeatable extraction commission | **New:** high-Tiên elite/boss Đại La Kim Cốt loot + repeatable named hunt-credit route (boss victory is a bonus, not sole gate) |
| G | Before Thần Khu floor10 (r21 gate) | **New:** low/mid-Thần mining/extraction node producing Thần Mạch Tinh; assigned extraction commission | **New:** Thần thú/elite Thần Thú Cốt loot + same-band guaranteed hunting campaign |
| H | Before Thần Khiếu floor10 (r26 gate) | **New:** high-Thần/Hỗn Độn special-zone Hỗn Độn Tủy Hoa gathering; repeatable valid anomaly-extraction expedition, not one-off relic | **New:** high-Thần elite/boss Bất Diệt Thần Cốt loot + deterministic proper-band campaign/salvage route accessible at Body r26–29 |

A–B are **existing technical foundation plus newly proposed acquisition content**; C–H have **no registered live consumer/source/regions**. Labels like “low Tiên” and “high Thần” are **content bands to author**, not existing playable region names. No hidden need for `body.r+1` to farm material required for r→r+1. An advanced teammate may do the actual work; acquired item remains Sect-owned. Lower-band source missions stay replayable when the sect advances.

**Pilot numerical baseline — needs user approval, not an authorized drop table:**
- Fallback main material source: one actually assigned **eligible team/producer** completes a 30-simulation-minute mission and returns **3 units of its specifically selected ID** (10 eligible team-minutes/unit). Mission reserves actual workers/teams, requires real prerequisites and completion, may have explicit non-gating common resource costs if later tested. **For B, proposed early Tử Vân Thảo 12 requires four such deliveries = 120 eligible team-minutes**. Entire B 52 needs 18 deliveries = 540 team-minutes if using only fallback. Never treat a timer without active workers as resource production.
- Fallback aux material: guaranteed **1 specifically targeted aux item within ≤4 completed, winning, appropriate-band encounters**; event-bound progress belongs to the selected region/material, not a universal redeemable stack, no credit for defeat/abandon/reload/reused ID. Random elite/boss/rare items can be bonus. Whether a direct lucky drop resets the 4-win progress must be explicitly settled during final tuning to avoid double rewards; the conservative scale model below assumes only guaranteed payouts and no lucky drops.
- For A, **do not replace actual field throughput** with slow pilot fallback: at Lv1 four full plots produce **up to 4×3/12 = 1 herb/minute** before startup/schedule limitations, farming boosts or losses. One plot alone produces only 0.25/min. 54 base herbs take 18 harvests (216 minutes one plot) and at least 72 stones; four plots need 5 full 12-minute cycles (~60 minutes for 54+ output if fully staffed/replanted). All 1,000 full A would require 54k items, about 37.5 ideal 24h days through one always-full Lv1 field; 3,000 about 112.5 days. This is **not measured throughput**.
- Stop or suspend a commission with **no payout/no duplicate** when worker assignment, map eligibility or requisite costs disappear; committed partial progress is saved if allowed by the future mission state machine. Never silently grant a free item when the commission is canceled.

### L4. Three Seals — repeatable, non-account-unique, current-band

| Seal / gate | Principal challenge, replayable | Non-RNG fallback, replayable | Anti-deadlock |
|---|---|---|---|
| `an_nhan_gioi`, gate10 (Linh Thân→Kim Thân) | **Proposed:** true win of late-Nhân body campaign/boss, payout exactly one consumed seal per qualifying claimed clear | After **at most 8 successful late-Nhân campaign engagements** under a named commission, claim one seal (pilot threshold) | All required engagements playable with Body r10 or a qualified team at that point; never require entry into Tiên/r11 |
| `an_tien_gioi`, gate20 (Đế Thân→Thần Khu) | **Proposed:** true win of late-Tiên repeatable boss campaign | ≤8 successful late-Tiên qualifying engagements for a guaranteed redeemable one-seal reward | No Thần/r21 prerequisite |
| `an_than_gioi`, gate29 (Hỗn Độn Thần Thể→Sáng Thế Thần Thể) | **Proposed:** true win of current late-Thần/Hỗn Độn repeatable boss campaign | ≤8 successful qualifying late-Thần/Hỗn Độn campaigns for a guaranteed one-seal reward | No r30/Sáng Thế prerequisite |

Every Seal remains a stackable item deposited to warehouse, quantity 1 **consumed per disciple** at exactly its special gate. Repeating a boss/campaign generates a new claim only for a **genuinely new** victory. First-clear achievements can be cosmetic/extra rewards, but **cannot be the only source**. A boss should not demand higher Body or Tu Vi levels as a hidden admission condition; battle success still depends on real stats/tactics. The same fight must not be counted twice in both seal paths by duplicate claims; if overlapping credits are allowed, rewards still use explicit distinct receipt IDs.

### L5. Aggregate load and stress test for roster scale

A full journey using **only conservative hunt fallback** would take **143×4 = 572 qualifying successful encounters per disciple** for aux items, plus **3×8 = 24 qualifying successes** if Seal progress is disjoint: at most **596 qualifying victories/one fully advanced disciple**. For 1,000 this is **596,000** logical victories; 3,000 **1,788,000**. These are extreme **all-fallback cumulative upper planning budgets**, not measured PvE battles, not a required playtime and not a drop expectation. Lucky loot, boss-clears, parallel sources and permitted overlapping objectives lower the work.

Scenario with deliberately **hypothetical** assumptions, not live balance: 70% of roster assigned hunting, 6 per party, 8 active hours/party/day, one encounter attempt each 20 minutes, 80% victory rate, one qualifying credit per claimed group victory (not one credit per each of six members). Then ~117/350 hunting parties for 1k/3k, and **~2,246/~6,720 qualifying successful team victories per day**. The all-fallback 596k/1.788m work implies roughly **265–266 active days** of that entire activity at hypothetical saturation. If win rate, participation or time availability fall, actual workload is worse. Because the game isn't yet running continuous 1,000–3,000 party V2 hunting, **do not claim this as playable actual runtime**.

Separate main-production fallback scenario with **3 named units per 30 eligible team-minutes**, **8 productive hours per producer/day** -> **48 main units per producer/day**. For every disciple eventually clearing all groups:

| Roster / target horizon | Avg main required/day | Producers simultaneously needed if ALL main from fallback | Share of 30% rear-base workforce |
|---|---:|---:|---:|
| 1,000 / 90 days | 6,245 | 131 | 131 producer teams, staffing TBD |
| 1,000 / 180 days | 3,123 | 66 | 66 teams, other rear jobs still required |
| 3,000 / 90 days | 18,734 | 391 | 391 teams, likely overwhelming if each needs 2 workers |
| 3,000 / 180 days | 9,367 | 196 | 196 teams; if 2 workers/team uses 392/900 nominal rear workers |

These cases assume **full roster eventually completes all 29 gates within horizon** and equal average production across the horizon, which is physically misleading if large proportions cannot earn high-tier EXP/region access yet. Use actual cohorts/gate distribution and multiple crop/mine supply routes before deciding tuning. The field A route already differs from the 3/30 pilot; never silently overwrite field yield/speed.

**Additional money bottleneck:** an always-active Lv1 field full with 4 plots consumes approximately 4×4 stones per 12-minute base cycle = **1.33 Sect Spirit Stones/minute or ~1,920/day**. Two continuously paid Rèn Thân slots consume up to **2 additional Sect stones/minute or 2,880/day**. These are simultaneous theoretical baseline drains, not current play results. Initial Sect stones=500 is not a renewable-rate proof. Source missions using paid costs must never create a no-stones-no-materials deadlock.

### L6. Demand-driven warehouse policy and low-micro workflow (proposed)

- **No new item currency:** material IDs remain exactly 16 + 3 Seals; local campaign progress is nontradable event/contract state, not a fungible Phẩm Lực.
- **Separate counts:** per resource `total`, `locked`, `reserve_min`, `available`, `committed-to-queued-gates`, `shortfall` displayed without changing `WarehouseSystem` semantics. Reservation by `reserve_min` belongs to player and is respected.
- **Demand indexed by cohort:** per current gate (29 buckets) count ready-XP eligible disciples + near-ready; multiply their exact manifest quantities, add explicit user-priority requests. On arrival/completion/material claim/warehouse policy update, recompute affected buckets or incrementally maintain counters. Initial/restore rebuild can be O(roster × constant); opening one disciple panel must not scan all 3,000.
- **Policy defaults:** player-facing `MANUAL` gate expenditure, `AUTO_GATE_OFF` for first release, batch preview only. Future auto mode is opt-in, respects reserves/locked, stable priority by explicit queue then ID; each actor must execute independent persisted idempotent gate transaction. One command cannot bulk-pass everyone by a raw counter shortcut.
- **Anti-idle control:** player picks policy `target 10/50/100 ready disciples` or `maintain next band stock`; mission/field policy uses deficit and priority rather than static crop `stock_target=40/20`. A dynamic target can be `manual reserve + sum of approved near-term cohort requirements + buffer` (buffer is tuning, not yet authorized). Do not retroactively mutate old Spirit Field rules just by adding UI; author and test actual consumer if approved.
- **Source transaction:** `claim_key=source_kind:region_or_worksite:event_id:resource_id`, validated against actual completed work/encounter, with named resource payout and durable source receipt in the same `SimulationState`. Prevent duplicated source claims even when offline/save-load retries or multiple teams submit same event; never award pre-claim UI preview. For ledger size, store compact immutable IDs/counters and test 1k–3k simulated rosters for memory/save-size/time.
- **Proof of no cycle:** for each of 29 gates require (1) registered ID, (2) at least one real repeatable claim source, (3) source unlock no later than source realm's gate, (4) reachable team without next realm or Tu Vi equality, (5) nonzero safe economic funding path, (6) fixed-success or bounded-success output of *exact* ID, (7) source simulation test + SaveService receipt round-trip. Fail `content_unavailable` otherwise.

### L7. Proposed measurements before final balance approval

1. Baseline Lv1 field single plot / four plots, `AUTO_DEMAND` vs `FIXED`, real assigned people and 60/600/1,440 ticks; measure exact herb/min, stones/min and idle minutes; verify `stock_target` doesn't starve gate inputs.
2. Named B early guarantee: with **Lv1 field**, Body `r4,f10`, independent Tu Vi below r4, enough Body EXP, no B items in warehouse, generate 12 Tử Vân Thảo + 1 Linh Tủy through actual eligible commission/encounter, then gate preview must be completable without Lv30 field or rare luck. No RNG success/failure in Body gate.
3. C–H each: start at `r,` with `r+1` unavailable, prove all required ID/Seal obtainable through a real completed contract, region, worker/team and claimed output; no zero-probability low difficulty, no first-clear-only Seal.
4. Stress: 1k and 3k persistent characters competing for same 19 item IDs; 2 simultaneous gate purchases with only enough stock for 1 must resolve deterministically, respect `locked/reserve_min`, never negative and never double consume; 1k+ queue previews event-driven rather than O(roster) per click.
5. Separate tests for source receipt replay/save/load, warehouse lock priority, stone starvation/restart, long offline catchup, and durability on abrupt save interruption. **No Windows visual PASS** inferred until user tests on Windows.

**Recommendation now:** keep section D **UNCHANGED**. Preserve **PRINCIPLE APPROVED / FINAL REVIEW PENDING**. Prioritize the B deterministic route, named proper-band C–H fallback, three repeatable Seals, and scalable event/worker economics. Do not implement a source as cosmetic UI, random-only rare, one-time reward or data table without a true actor/team/action/claim. All numeric production/fallback/horizon examples in section L are **PILOT**, not a newly approved item economy.


## M. BƯỚC 3 — Final source/gate/EXP/economy audit + approval decisions (11/10/2026)

> **FINAL REVIEW REPORT — NOT DESIGN LOCKED; NO CODE OR GAMEPLAY CHANGES.** Checked live game `main@f5fd0b6502ee2afb35180435de66efa869f0f4fe` and section-D rows parsed programmatically against `DiscipleProgressionBalanceV2.REALM_TOTAL_XP`. Source gameplay/test commit remains `3c7e9a7691f549097dd0a67ed50ead8b7be18a4c`. This section does **NOT** override existing locked EXP, Body/Realm rules, 29 principle-approved quantities, V2 XP rewards or balance.

### M1. Exact ledger audit — ALL 29 gates and real availability

The parser verified source realms 1..29, target=source+1, quantities **562 main + 143 aux**, and Seals **only gates 10/20/29**. Each gate's source-ID pair is fixed by section C. The output below shows exact per-realm total Body EXP in **million**, not only floor-10 EXP; Body breakthrough requires completed 10-floor total, with progress held at gate f10. Paid reference days assume **1,500 Body EXP per valid continuous simulation minute, Căn Cốt=0 and no buffs, no idle, 24h/day**, and are not projected user playtime or authored expedition throughput.

| Gate r→r+1 | Group | Main/Aux qty | Seal | EXP for realm (million) | Pure Rèn Thân 24h days | Actual source/gate state |
|---:|:---:|---:|:---:|---:|---:|---|
| 1→2 | A | 12/4 | — | 10,00 | 4,63 | Có 2 đầu vào từ ruộng/săn; **chưa có cổng** |
| 2→3 | A | 18/5 | — | 12,70 | 5,88 | Có 2 đầu vào từ ruộng/săn; **chưa có cổng** |
| 3→4 | A | 24/6 | — | 16,20 | 7,50 | Có 2 đầu vào từ ruộng/săn; **chưa có cổng** |
| 4→5 | B | 12/1 | — | 20,50 | 9,49 | Ruộng Lv30/RNG Linh Tủy; **thiếu bảo đảm** |
| 5→6 | B | 16/2 | — | 26,00 | 12,04 | Ruộng Lv30/RNG Linh Tủy; **thiếu bảo đảm** |
| 6→7 | B | 24/3 | — | 33,00 | 15,28 | Ruộng Lv30/RNG Linh Tủy; **thiếu bảo đảm** |
| 7→8 | C | 12/3 | — | 42,00 | 19,44 | Chưa có 2 ID + 2 nguồn  |
| 8→9 | C | 16/4 | — | 53,30 | 24,68 | Chưa có 2 ID + 2 nguồn  |
| 9→10 | C | 22/6 | — | 67,70 | 31,34 | Chưa có 2 ID + 2 nguồn  |
| 10→11 | C | 32/8 | **Ấn** | 86,00 | 39,81 | Chưa có 2 ID + 2 nguồn + Ấn |
| 11→12 | D | 12/3 | — | 109,20 | 50,56 | Chưa có 2 ID + 2 nguồn  |
| 12→13 | D | 16/4 | — | 138,70 | 64,21 | Chưa có 2 ID + 2 nguồn  |
| 13→14 | D | 20/5 | — | 176,00 | 81,48 | Chưa có 2 ID + 2 nguồn  |
| 14→15 | D | 24/6 | — | 223,70 | 103,56 | Chưa có 2 ID + 2 nguồn  |
| 15→16 | E | 12/3 | — | 284,00 | 131,48 | Chưa có 2 ID + 2 nguồn  |
| 16→17 | E | 16/4 | — | 360,70 | 166,99 | Chưa có 2 ID + 2 nguồn  |
| 17→18 | E | 22/6 | — | 458,00 | 212,04 | Chưa có 2 ID + 2 nguồn  |
| 18→19 | F | 14/4 | — | 581,70 | 269,31 | Chưa có 2 ID + 2 nguồn  |
| 19→20 | F | 20/6 | — | 738,70 | 341,99 | Chưa có 2 ID + 2 nguồn  |
| 20→21 | F | 30/9 | **Ấn** | 938,20 | 434,35 | Chưa có 2 ID + 2 nguồn + Ấn |
| 21→22 | G | 12/3 | — | 1.191,50 | 551,62 | Chưa có 2 ID + 2 nguồn  |
| 22→23 | G | 16/4 | — | 1.513,20 | 700,56 | Chưa có 2 ID + 2 nguồn  |
| 23→24 | G | 20/5 | — | 1.921,70 | 889,68 | Chưa có 2 ID + 2 nguồn  |
| 24→25 | G | 24/6 | — | 2.440,50 | 1.129,86 | Chưa có 2 ID + 2 nguồn  |
| 25→26 | G | 30/8 | — | 3.099,50 | 1.434,95 | Chưa có 2 ID + 2 nguồn  |
| 26→27 | H | 12/3 | — | 3.936,30 | 1.822,36 | Chưa có 2 ID + 2 nguồn  |
| 27→28 | H | 18/5 | — | 4.999,20 | 2.314,44 | Chưa có 2 ID + 2 nguồn  |
| 28→29 | H | 24/7 | — | 6.349,00 | 2.939,35 | Chưa có 2 ID + 2 nguồn  |
| 29→30 | H | 32/10 | **Ấn** | 8.063,20 | 3.732,96 | Chưa có 2 ID + 2 nguồn + Ấn |

Interpretation:
- **29/29 recipes are internally coherent** and satisfy monotonic gate identifiers. This is **NOT** 29/29 content sources live, NOT 29/29 implemented transactions, NOT a successful Godot test.
- A: registered Thanh Linh Thảo and Tinh Lang Bì with feasible physical source mechanisms, assuming enough field staffing/stones and genuine PvE victories; no body gate transaction or second guaranteed route implemented.
- B: both items registered, but Tử Vân Thảo field **requires Lv30** and Linh Tủy remains unbounded RNG; no accessible guarantee yet. Neither field Lv30 nor RNG may be required to pass gate4.
- C–H: **all 12 named group IDs missing**, corresponding target regions/contract rewards absent. Gates 7–29 impossible as authored today. Gates 10/20/29 additionally demand three missing Seal IDs. Missing data must fail `content_unavailable` and must not be bypassed by `requirements_verified=true`.
- Stage coverage: A opens at r1; B guaranteed route must open no later than r4 **before floor10** (prefer earlier so farming overlaps EXP); C by r7 before f10; D by r11; E by r15; F by r18; G by r21; H by r26. Every material/Seal for gate r must be earnable by an eligible current-realm party, independent of `cultivation.realm==body.realm` and never exclusively by r+1 content.
- **Three Seal terminal checks:** gate10 source is late Nhân (r10) **NOT r11 Tiên**, gate20 source late Tiên (r20) **NOT r21 Thần**, gate29 source late Thần/Hỗn Độn at r29 **NOT r30 Sáng Thế**. Every Seal is **consumable 1/actor**, must be earned repeatedly by actual mission/boss wins (one-time first-clear is not a supply).

### M2. Exact XP-vs-material-vs-money accounting

Canonical `DiscipleProgressionBalanceV2.REALM_TOTAL_XP` begins 10,000,000/r1, ends 10,240,200,000/r30; the 29 Body gates each require completing **r1..r29**, summing exactly **37,890,400,000 Body EXP for one disciple** from r1 f1 until r30 f1 (not r30 f10). Canonical Body source reference rate values: 250 production, 750 expedition, 1,500 paid Rèn Thân EXP per real simulation minute; `grant_xp` applies `1+0.002×Căn Cốt+explicit_valid_body_xp_source_percent_add` to **natural** gains, while fixed EXP is unchanged. The table below ignores all natural bonuses as a **transparent zero-bonus reference**, not a claim that Căn Cốt is zero in real disciples.

| Group | EXP needed (million) | Paid days continuous per actor | Approx stones if exclusively paid Rèn Thân (1/min) | 750/min expedition reference days (NOT proven live automated income) |
|---|---:|---:|---:|---:|
| A | 38,90 | 18,01 | 25.933 | 36,02 |
| B | 79,50 | 36,81 | 53.000 | 73,61 |
| C | 249,00 | 115,28 | 166.000 | 230,56 |
| D | 647,60 | 299,81 | 431.733 | 599,63 |
| E | 1.102,70 | 510,51 | 735.133 | 1.021,02 |
| F | 2.258,60 | 1.045,65 | 1.505.733 | 2.091,30 |
| G | 10.166,40 | 4.706,67 | 6.777.600 | 9.413,33 |
| H | 23.347,70 | 10.809,12 | 15.565.133 | 21.618,24 |
| **29 gates total** | **37.890,40** | **17.541,85** | **~25.260.267** | **35.083,70** |

**Red-line pacing:** pure Rèn Thân for a single actor r1→r30 requires **~17,542 days = ~48.06 continuous years** at base 1,500/minute with no constitution bonus, non-Rèn sources or other gameplay progression. **This cannot be passed off as a balanced 30-realm playthrough** without real high-level stacking/active-source benchmark evidence. Keep EXP locked: the next release must report real Body income for representative early/mid/high V2 actors and explain the gap, not silently alter realm XP or fabricate expeditions. At the physical **2-slot Lv1 Rèn Thân** capacity, 1,000 disciples finishing just r1 if that were their ONLY XP activity would consume ~6.67 million paid minutes/sect stones and ~6.34 calendar years of aggregate two-slot 24/7 uptime. Hence P3.7 production and validated expedition XP pathways and multiple activities are mandatory to claim meaningful 1k–3k progression; **the currently tested 750 expedition adapter is not a proven continuous V2 scheduler income stream**.

### M3. Real field Lv30 lock and stone source circularity

1. `BuildingSystem.MILESTONE_COMPONENTS` requires **one `linh_tuyen_chi_tam` at target Lv10, two at Lv20 and three at Lv30**, totaling **six hearts**; `convert_linh_tuyen_fragments` converts 100 `linh_tuyen_chi_tam_manh` into each heart.
2. `BuildingSystem.upgrade_cost` from field Lv1→Lv30, separately summed over all target levels and milestone ×2 factor, requires exactly **1,238 Linh Mộc + 625 Thanh Thiết + 3,687 Sect Linh Thạch + six hearts**; total authored `upgrade_required_work` across this path **1,268 work units** (not claimed actual calendar minutes).
3. `BuildingSystem.linh_tuyen_fragment_drop`: **5% base chance of one fragment per completed plot** times rare factor. Six hearts require 600 fragments, i.e. **12,000 completed harvests in expectation at rare factor exactly 1** with no other fragment sources. Since RNG can arbitrarily miss, this is **never a guaranteed unlock horizon**. Do not create a B supply that depends on clearing these upgrades.
4. Lv1 field with four actually occupied plots growing `thanh_linh_thao`: base 3 harvest/plot, 12-minute cycle, 4-stone seed; best steady reference after startup is **1 herb/min, 1⅓ Sect stone/min**. One paid Rèn Thân user takes ~6,667 minutes and ~6,667 Sect stones to reach first gate at constitution=0, whereas producing the gate's **12 herbs** with four plots takes one basic 12-minute cycle and 16 stones plus successful A hunting. **Resource production isn't necessarily limiting for two paid trainees; stone and XP are.** The `AUTO_DEMAND` planting policy does not guarantee all four plots target the herb, so this is an idealized full-staffing upper bound.
5. Lv30 single field with ten plots: at worker_speed=1, affinity=1, field speed=1.145, time multiplier=0.90, yield multiplier 1.145×1.10, **Tu Vân Thảo** routine output 4/plot/19 minutes, 14 Sect stones/plot/plant. Fully staffed fixed-policy reference: **40 Tử Vân Thảo/19 minutes (~3,032/day), and 140 stones/19 minutes (~10,611 stones/day)** just for this field. This is **post-upgrade theoretical capacity**; it doesn't establish accessible supply before gate4, and 10 workers could be away/resting.
6. Two Rèn slots concurrently paid full-time: **2×1,440=2,880 stones/day**. Together with full Lv1 four-plot field: **~4,800 stones/day** needed; together with full Lv30 Tử Vân field: **~13,491 stones/day**. Fresh compatible TechniqueSystem initializes **500 Sect stones**, so under full Lv1-field+2-trainer theoretical burn with zero revenue, 500 stones fund only ~150 simulation minutes before exhaustion (not actual starting-state run; other buildings/consumers also spend).
7. `EconomySystem` P0 treasury/wallet is **not** `SectState.spirit_stones`. `TechniqueSystem.sell_manual` can produce actual Sect stones by selling **owned** manuals, but currently there is **no verified minimum repeatable Sect-stone income per day** to pay the modeled sinks for 1k–3k scale. PVE V2 `HuntingMapV2.preview_reward` awards registered materials, not Sect stones; `ResourceRegistry.market_value` is metadata, not a demonstrated Sect-stone sale operation. Do not call the economy viable until a tested truthful player activity (contract/sale/reward) funds a sustainable positive income loop, respecting stocks and no-cost impossibility.

**Exact conservative resource-only baseline costs per 1 actor:** full A group demands 54 Thanh Linh Thảo = **18 Lv1 harvests and 72 Sect stones for sowing**, ignoring other systems; at two pure paid Body slots this is minuscule next to paid training. Full B 52 Tử Vân Thảo costs **18 base Lv30 harvests and 252 stones** only if planted with *base* yield 3, no boosted output; actual boosted Lv30 yield=4 may reduce number of harvests to 13 and sowing to 182 stones for 52. This field is an additional non-guaranteed mid-term route, not an entry gate dependency.

### M4. Source-side load model — 1k / 3k and cohort contention

**Never treat "full roster 562/143/3 cumulative" as if all actors cross the same gate on one day.** Required per material per day: sum over actual gate-ready cohorts `incoming_gate_count[g/day] * manifest[g].qty`; subtract available warehouse after player reserves and forecast actual eligible-worker/yield/win output. Update counters event-driven; do not scan all 3k actors for every UI paint. Other systems share `linh_tuy` and crops.

**Fallback pilot rates, NOT APPROVED numbers:** 3 named main items / 30 active **producer-team** minutes; 1 named aux per ≤4 qualified, successfully claimed winning engagements; 1 Seal per ≤8 qualifying named campaign wins (separate progress where no overlap authorized). For a complete journey with only fallbacks: `562/3≈188` producer missions (ceiling per group/recipe actually higher due nonfungible types), `143×4=572` qualifying aux wins, `3×8=24` Seal wins, **up to 596 qualifying engagements per actor**, or **596k/1.788m** for 1k/3k. This is **worst-case scheduling scenario without lucky drops, not true minimal production**, since a lucky drop or boss victory can reduce the workload; does not claim an implemented 70% hunter workflow.

| Example cohort for **3,000 total actors** | Exact package stock demand | Pilot workload | Feasibility note |
|---|---|---|---|
| 1% roster (30 actors) cross gate1/day | 360 Thanh Linh Thảo + 120 Tinh Lang Bì | 120 field harvests (4 stones each) + at least 60 winning A hunts if actual 2-hide reward each | ~480 stones/day planting; one perfect Lv1 field could supply 360 of its ideal max 1,440 herbs/day, but only if assigned and locked to that crop |
| 1% roster (30 actors) cross gate4/day | 360 Tử Vân Thảo + 30 Linh Tủy | 120 main-delivery missions = 3,600 active producer-team minutes + ≤120 qualified wins for aux fallback | ~8 eight-hour producer teams at full duty, no field Lv30 dependency; cost/availability of commissions **must** be tested |
| 1% roster (30 actors) cross gate10/day | 960 Huyết Linh Sâm + 240 Tinh Huyết + 30 Nhân Ấn | 320 main missions = 9,600 active producer-team minutes; ≤960 qualifying aux wins + ≤240 disjoint seal wins | ~20 eight-hour producer teams + **1,200 qualifying winning engagements/day** allocated to C; needs enough capable late-Nhân teams |
| 10% roster (300 actors) cross gate10/day | 9,600 C main + 2,400 C aux + 300 Nhân Ấn | 3,200 producer missions and ≤12,000 qualifying wins/day | Exceeds the **6,720 wins/day** of the illustrative *whole-sect* 350-team scenario below. Requires longer horizon/other routes/direct drops/not-yet-measured higher throughput |

As an intentionally hypothetical stress envelope only, 70% of 3k = 2,100 hunter actors, six per team → 350 parties, 8 active hours/day, 20 minutes/attempt, 80% victories → **350×24×0.8=6,720 winning team encounters/day** if *all* parties are available and capable of the same source. Real valid tier distribution, team travel, injuries, downtime, stamina, defeat, versioned rewards, mission access, performance and save processing can all lower throughput. **One party victory produces one claim for its party**, not an automatic six independent Seal/item claims. Need live telemetry and world-scheduler integration before treating this as economy balance.

### M5. Source access proof obligations, each category

A (1–3): field with true plot/worker payment and non-RNG true claimed Bạch Thạch/Hắc Phong pelt; second independently guaranteed supply route for BOTH IDs still missing. **No Body gate consumer yet.**
B (4–6): early proper-band named Tử Vân Thảo ủy thác at r3/r4, accessible without Linh Điền Lv30/Hearts and without paying the very missing Tử Vân Thảo as input; Linh Tủy on Thanh Trúc Lâm difficulties L2–5 random but L1 rare=0%, add guaranteed named claim via enough real wins. No zero-success route and no self-consuming commission input.
C (7–10): high-Nhân real region, herb producer and named commission plus beast winner and guaranteed aux commission. Gate10 Nhân Seal must be repeatably earned in r10; no first-clear-only claim, no post-Tiên unlock.
D (11–14): low-Tiên region, Kim Cốt Thảo and Linh Thú Cốt Ngọc each two actual earned routes by r11 floor10.
E (15–17): mid-Tiên region, Tiên Tủy Liên and Tiên Thú Chân Cốt two repeatable claimed routes by r15.
F (18–20): high-Tiên region, Bất Hoại Tủy Dịch and Đại La Kim Cốt two routes by r18. Gate20 Tiên Seal reachable before r21/Thần.
G (21–25): low/mid-Thần mine/region for Thần Mạch Tinh and Thần Thú Cốt, two routes by r21; mining result must deposit registered proper ID, not dummy Thanh Thiết.
H (26–29): high-Thần/Hỗn Độn region for Hỗn Độn Tủy Hoa and Bất Diệt Thần Cốt, two routes by r26. Gate29 Thần Seal available before r30/Sáng Thế.
Every route has a specific `source_id + completed_event_id`, persisted progress and safe claim, no passive time-generated reward, no same-actor two Body natural XP grants in one minute, and no use of next-realm eligibility, higher Tu Vi forced equality or material self-reference.

### M6. Bảng đề xuất ban đầu trước khi duyệt nguyên tắc — xem quyết định mới nhất ở mục N

| ID | Question requiring explicit user approval | Recommended answer (NOT YET LOCKED) |
|---|---|---|
| F01 | Are **all 29 exact main/aux quantities, 8 material groups and 3 extra Seal consumptions** still accepted? | **Yes**, unchanged 562/143/3 per complete actor. Do not add a stone fee at Body gates |
| F02 | What is the core acquisition guarantee? | **Two genuine routes per ID**, one deterministic active-activity fallback, no universal Phẩm Lực/currency, source available before gate, no Tu Vi-body equality |
| F03 | How to resolve early group B deadlock? | **Early named Tử Vân Thảo commission** accessible before r4f10 with no Lv30 requirement; **Linh Tủy guaranteed after bounded completed wins** at accessible Nhân sites |
| F04 | What content belongs in C–H and the three Seals? | All **12 new group IDs + 3 new repeatable Seal IDs**, proper-band real regions/source contracts; no first-clear-only required item |
| F05 | What numbers are authorized to implement initially? | If approved, start **configurable test profile** (3 main/30 active producer-team min; 1 aux/≤4 valid wins; 1 Seal/≤8 valid wins). Keep **PILOT / BALANCE PENDING**, allow adjustment only after measured tests and further user approval |
| F06 | Must each Ấn be obtained both by boss and by guaranteed campaign, with 1 consumed each time? | Yes, boss win direct claimed Ấn **or** cumulative valid same-band wins; repeatable, exactly-once source rewards, separate campaign receipts |
| F07 | How will the **Sect Spirit Stones recurring supply** fund fixed paid training and farming? | Require at least one **real, repeatable, idempotent Sect-stone** reward/sale contract before calling sustained economy viable; test 4,800/day Lv1 field+two slots and 13,491/day Lv30 field+two slots against earnings. No artificial timer income, no conversion from P0 treasury |
| F08 | How should 1k–3k actors be managed? | Named campaign/production assignments by work group, tier cohort gate-demand inventory, batch preview, warehouse `locked/reserve_min`, no per-disciple micromanagement; **AUTO_BODY_GATE off by default** |
| F09 | Who owns gate/item mutation and save receipts? | Single authoritative Body gate transaction, full preflight, warehouse + actor + HP + receipt all-or-nothing, serialized claims, idempotent retry, disk-crash durability separately verified; source reward receipts equally replay-safe |
| F10 | Do we claim all high realms economically playable immediately? | **No.** Preserve EXP and all preexisting combat/region locks, run real low/mid/high pacing benchmarks and explicitly document 48-year unbuffed ceiling; do not fake high-tier content or boost locked XP |
| F11 | How to release if parts C–H aren't built? | Gate/route fails `content_unavailable`; do not claim 29 playable. Stage within **active DV2-03** with proper content production/tests, no next phase until closure |
| F12 | What evidence must pass before marking complete? | 29 row manifest invariant; all proper-band sources claimed with receipt; stone no-deadlock and sustained funding; 1k/3k time/save throughput; rollback/double-click; Godot official focused+full at changed SHA; Windows visual **PENDING USER** |

**Recommended approval wording:** “Duyệt hợp đồng F01–F04 và F06–F12 về nguyên tắc; F05 cho phép chỉ tiêu PILOT nhưng chưa chốt tốc độ cung; giữ nguyên EXP và mọi khóa trước; chỉ sau khi tôi chấp thuận viết ‘CHO PHÉP CODE DV2-03F’ mới chuyển sang triển khai.” Distinguish *approval of research* from *authority to implement*. This section intentionally keeps previous status `PRINCIPLE APPROVED / FINAL REVIEW PENDING`.

### M7. Hard GO/NO-GO at code/release boundary

**NO-GO before user consent:** No game/asset/resource code changes, no edit to canonical EXP and 29 recipe quantities, no `DESIGN LOCKED` header.
**NO-GO before playable 29/29 release:** Missing source at any gate, RNG-only required rare, Seal first-clear-only or inaccessible by source realm, circular input, missing Sect-stone recovery, unproven 1k/3k scaling, missing true 750 expedition linkage but pretending it exists, ambiguous warehouse+Body mutation, or replayable claim.
**Research evidence only:** prior Linux focused/FULL PASS pertains **E3.1 commit 3c7e9a76**, not this Phase-3 economic model or newly authored gates. This turn ran no Godot/Windows tests, only static source auditing and arithmetic.


## N. HỢP ĐỒNG TRIỂN KHAI CUỐI — F01–F12 PRINCIPLE APPROVED, AWAIT SEPARATE CODE AUTHORIZATION (11/10/2026)

> **Decision and precedence:** User expressly **approved F01–F12 IN PRINCIPLE on 11/10/2026**, confirmed all 29 recipe quantities and existing EXP must remain unchanged; **F05 = PILOT ONLY, no final supply-rate lock; F07 and F10 require REAL VERIFICATION**. User expressly **DID NOT AUTHORIZE CODING** and did not mark DV2-03F `DESIGN LOCKED`. This section supersedes M6's *historical pending-review* decision labels, not its evidence or arithmetic. Work must remain documentation-only until a **new, explicit user command** authorizes coding. The user may later authorize individual implementation slices rather than the entire pipeline. **Current phase remains DV2-03 ACTIVE**.

### N1. Non-negotiable implementation invariants (code must preserve; not a new numerical balance)

- Single gameplay authority: Godot V2 `SimulationState`/`SectState`, `DiscipleRealmProgressV2`, `WarehouseSystem`; UI only reads/previews/issues commands, not direct material/EXP mutation.
- Existing 30×10 separate Tu Vi/Body realm lists, exact 300-floor XP table and rate/reference sources, 60 real seconds per simulation minute, no Body RNG or HP/stamina failure penalties, no requirement Tu Vi==Body or automatic joint advancement. No changes to Căn Cốt `+0.20% natural Body EXP per point`, first `Rèn Thân Đường` 2 slots or paid 1 Sect Spirit Stone/valid minute + base 1,500 Body EXP/minute.
- Exact 29 manifest rows section D: source realm 1–29 inclusive, 8 groups A–H, 16 typed materials (4 presently registered +12 new), 3 distinct stackable Seal IDs (all new), Seal quantity 1 only at gates 10/20/29. Full journey 562 main+143 aux+3 seals. A Body gate at source `r:f10` needs completed canonical floor10 XP plus its exact manifest, then succeeds 100%, becomes `r+1:f1, xp=0` with existing HP-ratio rescale; Tu Vi unchanged. **Do not add Body gate Sect-stone surcharge.**
- One canonical Sect Warehouse, safe available quantity always respects `locked` and `reserve_min`; canonical deterministic ordered command resolution, no universal Phẩm Lực, no personal large loot bags or alternate warehouse; sources award actual registered resource IDs for actual completed work/wins with distinct replay-safe receipts.
- Each of **19** gate items must have two genuine accessible paths and at least one repeatable deterministic **earned** path. Each source opens strictly no later than the gate's source Body tier; high-level access may use viable sect teammate/team but cannot depend on `body=r+1`, an obligatory equal Tu Vi, RNG-only mandatory loot or a first-clear-only account reward.
- Existing P3.7/earlier systems, equipment roadmap and all other designed but unimplemented features remain separate; DV2-03F may implement only dependencies necessary for its correct material/quest/Body-gate/stone flow. One active implementation phase at a time. No unapproved named map or gameplay mechanism promoted from reference Unity/ZQZS.
- Approval means **architecture and invariants** are accepted, not numeric tuning proven. Numeric changes beyond the pilot profile, new recurring Sect Stone reward magnitudes, or a new EXP bonus/economy law **require a separate user balancing decision** even after generic code authorization.

### N2. Authority and proposed owners/contracts (no class created yet)

| Component | Planned sole responsibility | Must NOT do |
|---|---|---|
| `DiscipleBodyGateContentV2` (new) | Immutable validated 29-row manifest, lookup by actual saved Body realm and version, 19 resource IDs/checks | Mutate actor/warehouse; fabricate missing source |
| `BodyGateAcquisitionV2` / delegated true source owners (new) | Real plot/commission/claimed win/campaign **named** payouts; source eligibility, claimed event, progress + idempotent source receipt | Create items from UI preview, idle real time, unearned rewards or display fake amounts |
| `DiscipleBodyGateTransactionV2` (new) | Pure preview; single-authority `commit_gate(state, disciple_id, request_id)`; authoritative preflight, HP + actor + bundle debit + saved receipt, all-or-nothing/rollback | Accept UI-supplied `requirements_verified`, caller-computed costs, bypass warehouse reserves or invent XP |
| Existing `DiscipleRealmProgressV2` | Canonical XP/floor/Body-realm commit and HP rescale | Debit warehouse or select recipe |
| Existing `WarehouseSystem` | Typed material quantities, available/locked/reserve, atomic bundle consume/add | Change Body progression or infer source eligibility |
| Existing `WorkforceSystem`, `BuildingSystem`, `HuntingPveRunV2`, `SimulationScheduler` | Real occupation, paid production, actual battles/rewards and one simulation-minute schedule; extensions **only where proved needed** | Fake V2 expedition 750/min source or multiple EXP grants per actor/tick |
| `SectState` + `SaveService` (versioned schema extension if authorized) | Persist source progress/receipt, gate receipts, no-double-claim state and recovery; preserve legacy saves | Treat in-memory rollback as power-loss crash-safe disk persistence |
| UI/sect-management consumer | Display pure preview and real source links, player assignment/cohort priority/explicit command; default auto gate OFF | Direct debit, hidden auto-gate or impossible route shown as available |

Idempotency: one source/event/item payout exactly once; a gate receipt keyed by actor+source realm and a typed request-id mapping. Exact retry returns `already_committed` without new deduction/advancement; reused request_id for another actor/gate rejects. For 1k–3k roster, a replay-safe **compact persisted receipt strategy** must be tested for save size and offline replay; an unbounded per-tick UI ledger is not acceptable. Compaction must not let old claims be replayed.

### N3. Ordered future implementation work packets — **NONE AUTHORIZED YET**

**Single parent phase DV2-03F; one work packet at a time.** `DONE` requires evidence at the changed gameplay SHA, not source inspection.

| Order | Packet | Planned code scope once separately allowed | Focused exit/GO proof |
|---:|---|---|---|
| 0 | **F0 — Baseline/evidence harness** | Establish fresh official Godot 4.7.2 baseline and reproducible non-production profiling for actual income/costs/Body EXP, action ownership, active maps, save/load. Add only test/telemetry hooks explicitly within separately approved coding scope. | Reproduce prior E3.1 focused/full on same source or record exceptions. Verify 60s/min, 2 paid slots, existing farm/mine/encounter, Sect stone provenance, real expedition 750 owner **if one exists**; missing sources marked `UNIMPLEMENTED`. No live balance declaration. |
| 1 | **F1 — Manifest+typed IDs+schema** | Exact 29 validated entries, register 12 missing group materials and 3 Seal IDs with family/realm grade/rank/tags; versioned receipt/progress schema and migrations, no source payout or public enabled gate. | 29/29 exact quantities/IDs, 562/143/3, distinct Seals 10/20/29, old-save roundtrip, malformed content fails closed. **No player claim of usable gate yet.** |
| 2 | **F2 — Gate transaction safety** | Pure preview and owner-only commit with full snapshot/rollback, request-id+actor+realm idempotence, warehouse `available` and complete package debit, actor HP/floor state and persisted receipt, explicit content-availability fail closed. | Double-click, two disciples competing for final material/Seal, actor invalid, -1 item, locked/reserve, HP sync fail, fault-injected warehouse fail, save/reload/replay: **zero partial spend**; old V2 Tu Vi/EXP unaffected. Test fixtures may isolate service, but fixture items are **not live acquisition**. |
| 3 | **F3 — Real A/B material routes + early economic bootstrapping** | Wire existing A planting/actual valid pelt wins; add *second real* named repeatable paths as necessary. Prioritize B proper-band Tử Vân Thảo commission and bounded-win Linh Tủy, independent of field Lv30/Hearts; true source receipt and mission worker reservation. Add/verify one legitimate repeatable **Sect-stone income route** only after separate economy numeric approval. | Body r4:f10 / low Tu Vi / field Lv1 / zero B stock: real earned A/B requirements through jobs/wins/claims, no RNG deadlock; no circular spent input; receipts survive reload; zero-stone recovery path and revenue/cost measurements. If legitimate income insufficient, **F07 BLOCKED**, require user decision, not a fake grant. |
| 4 | **F4 — Real C–H regional production/hunting and all Seals** | By cohort band C (r7+), D (r11+), E (r15+), F (r18+), G (r21+), H (r26+), implement actual appropriate-level region/worker/profession and two real routes for *each* of 12 named resources. Add repeatable named Ấn Nhân/Tiên/Thần boss campaign + guaranteed proper-band victory-progress alternatives; 1 consumed at gates 10/20/29. Split inside F4 by actual tier without opening another parent phase. | **All 19 IDs** have two valid earned sources; proper-band unlock before every applicable Body gate; 29/29 route accessibility; each Seal repeatable and cannot be claimed by first-clear duplication; winners counted as party claims once, not ×team-member reward. No placeholder map, drop, reward or boss. |
| 5 | **F5 — Demand planning and management UI/AI** | Sect Warehouse demand computed by real current-gate cohorts, user priority/reserve, named source shortage, reliable batch preview. Connect existing P3.2 Body panel to pure preview and actual player command; manage producer/hunting teams with minimal micro. | No simulated positive UI values, no unrestricted `requirements_verified` caller, 1,000–3,000 roster mixed-stage demand, deterministic sorted priority, no O(roster) expensive scan on **every** per-actor UI refresh. `AUTO_BODY_GATE` defaults OFF; if a later optional auto policy is implemented, opt-in only. |
| 6 | **F6 — F05/F07/F10 real measurements and unresolved balancing approvals** | Reproducible multi-seed/real-state sim for 1k/3k, genuine exp+stones+resource supply and backlogs; evaluate user-approved **PILOT** profile against actual, record failed coverage. **No silent EXP modification or pilot promotion.** | F05 measured against reachable work and wins; F07 credible positive sustained income under realistic operating mixes, no bootstrap deadlock; F10 low/mid/high Body-realms with locked EXP measured and gap recorded. If blocked, request **separate user balance decision**, do not mark `ECONOMY PASS`. |
| 7 | **F7 — Integration/closure** | Regression for full 29-gate loop from real sources, workload/save/replay safety and Godot scene/UI; existing P0→P3.7 cumulative workflow. Controlled Windows UI verification requested **only when genuinely needed**. | Official Godot 4.7.2 focused PASS, same-SHA cumulative PASS; 1k/3k memory, time, source-claim ledger/save and offline catch-up acceptable with measured results; Windows actual/visual **PENDING USER** until user runs it. Only then update `CURRENT_CHECKPOINT.md` and consider DV2-03 closure. |

**Dependencies and order**: F0 before any economic conclusion. F1 before F2 and new named resources. F2 can use isolated in-memory test fixtures but **cannot permit live Body advancement until real source content exists**. F3 is prerequisite for claiming gate4 playable; F4 is prerequisite for claiming all 29 gates playable. F07 bootstrap evidence starts F3, and full 24h/long-run load proof re-runs F6. F10 initial low/high rate proof starts F0, full replayed cohort evidence gates F6/closure. Avoid rewriting locked P3.7 modules when a single authoritative adapter suffices.

### N4. **F05 stays PILOT, not a balance contract**

Separate **draft test configuration** (off in public gameplay until authorized and proven):
- Main fallback: *up to* 3 units of one named item per 30 **actually active, eligible producer-team minutes** after a committed mission. Not a guaranteed live yield for every mine/crop and never passive.
- Aux fallback: one named item after **≤4 actual successful and uniquely claimed** qualified region wins, without requiring a lucky roll for that item.
- Seal fallback: one consumed Seal after **≤8 actual successful and uniquely claimed** qualified campaign wins at its source realm, optionally earned directly via true repeatable boss clear.
- Preserve existing Lv1 crop yields, costs, 60s simulation-minute, Linh Thạch expense, maps and XP. The pilot profile does **not** overwrite existing crop cycle/yield, map win rate or RNG drop probability.
- For exact rate locks, show completion/progress, average/percentile throughput, active team staffing, natural resource income, other system competition, and 1k/3k load; then obtain **new user approval** for each finalized payout/cap/cost. Failure can prompt economy proposal, not unauthorized numerical changes.

### N5. **F07 mandatory REAL Sect-stone economics proof**

Measure **Sect** `spirit_stones` inflow and outflow using actual committed event receipts—not P0 `treasury`/`wallet`, not `ResourceRegistry.market_value` as if already a sale. Inflow categories must name true owner and qualifying player activity. Costs must include real Rèn Thân slots, actual crop plantings, building upgrade, possible future commission costs, and competing systems; no new gate surcharge.

Minimum reproducible stress cases:
1. **Empty/no-stone bootstrap**: no paid crops/trainer works, but there must be an actual playable, repeatable, non-self-consuming route that can lawfully restore Sect stone income. Without that proof `F07=FAIL/BLOCKED`; do not mint by clock.
2. **Lv1 example**: 4 full Thanh Linh Thảo plots + 2 paid Body trainees, theoretical no-bonus burn **~4,800 Sect stones/24 real hours** if constantly active. Compare with **earned** real throughput, worker availability, net stock, completion and stall time over ≥24h simulation after any finite starting stock is exhausted. Not a promise that 4,800 is the target for every roster.
3. **Lv30 example**: ten eligible Tử Vân Thảo plots at factor=1 worker speed/affinity and 2 paid trainees can burn **~13,491/day** steady theoretical base; field Lv30 itself requires six Linh Tuyền Hearts and field-upgrade costs. Prove route independent of required Body gate4, and monitor actual throughput. Do not assume 12,000 harvests at 5% = guaranteed cap.
4. **1k and 3k mixed roster**: record earned stone/day, spent stone/day split by owner, backlog days, unserved gate-ready count, active workers, loss/defeat downtime, seed variance, recovery when stock hits zero, season/offline replay, and conservative confidence bounds. **GO criterion**: demonstrable closed-loop real route and sustainable operation for the *selected realistic workload*, not one manually injected balance; net inflow minus consumption nonnegative on sustained representative windows, or an explicit quantified bounded recovery regime accepted by user.

If F07 fails, document which real economy source is missing, design a compatible earned income mechanism within DV2-03F dependency, get separate approval of its numeric payouts, then implement/test. Do not silently create Sect Stone time stipend, convert treasury, or reduce existing Body/crop fees.

### N6. **F10 mandatory REAL Body EXP pacing proof**

- No changes to `DiscipleProgressionBalanceV2` 300-floor costs, `BASE_TUVI_PER_MINUTE`, existing Body source reference rates/1-tick rule, modifiers or fixed EXP; preserve `unapplied_overflow` and gate cap.
- Benchmark **r1/r4/r7/r10/r11/r15/r20/r21/r26/r29**, representative Căn Cốt/valid source profiles, unbuffed baseline + actual unlocked effects, natural Body EXP for verified **mining active-phase** (250), **paid facility** (1,500), **real V2 expedition** (750 *only after consumer linkage proven*), mixed recovery/offline. No invented passive training or invented bonus.
- Baseline mathematics already established: sum of realm totals r1..r29 = **37,890,400,000 XP**, ~**17,541.85 continuous 24h days / 48.06 years** at 1,500 XP/minute and no bonus for **one actor**. At exactly two always-paid physical slots, a 1k cohort clearing **only r1** from this source would take about **6.34 calendar years at 24/7 full slot use**, demonstrating that treating those slots as the sole universal progression lane is wrong.
- Report actual time to next Body gate, realm-group throughput per week/month, slot contention, eligible expedition minutes, activity scheduling, effect of constitutional growth, and 1k/3k active cohorts. Do not substitute raw type-contract reference 750 for a verified end-to-end schedule. If evidence does not support intended 30-realm pacing, mark **F10=BLOCKED/UNVERIFIED** and request separate user decision regarding *additional legitimately owned active sources/activities* before making a high-realm viability claim. Never silently retune locked EXP.
- F10 evidence can distinguish “technical gate correctness” from “whole-game rate accepted”; all-29 gate tests using seeded test fixtures are technical integrity tests, **not economic or real-time playability proof**.

### N7. No-deadlock, transaction, scale, saving and release gates

- **Gate reachability property for every r=1..29**: let `M_r` be all named recipe IDs (+Seal if applicable). For every `m∈M_r`, at least one validated source with true completion/claim remains available at Body `≤r` (or via accessible genuine teammate) without requiring `r+1`, Tu Vi equality, `m` itself as source prerequisite, RNG-only success, a one-time account reward, or impossible initial Sect Stone funding. If any is false, return `content_unavailable`, do not advance.
- **Transaction property**: `preview_gate` is 100% pure. `commit_gate` checks full floor-10 EXP, all three named item quantities (2 regular+optional Seal), `available` after reserve/lock, claimant progression and request/receipt replay. In one synchronous simulation transaction, advance Body+HP, consume complete warehouse bundle, write one immutable persisted receipt. If any step fails, **all** state/HP/warehouse/event counters/ledger revert. Two actors requesting the final shared Seal resolve deterministically, only one can win.
- **Persisted acquisition**: source claims, per-source progress, actual warehouse mutations and gate receipts survive save/load and bounded offline catch-up. Existing `SaveService.save_to_path` writes target path directly; in-memory rollback is not evidence for interrupted-write/crash durability. Crash-safe save strategy and recovery need actual platform-specific tests or an explicit failed gate, never overclaim.
- **Performance evidence**: 1k/3k actual `SimulationState` actors, mixed cohort source bands, 350-party hypothetical stress not assumed production reality, harvests/commissions/PvE claims, source-progress storage, UI index, repeated claims and 24h+ catch-up. Capture CPU/time/memory/save-size and failure rate at same build; avoid O(3k) scan at each individual panel draw. No invented fixed performance budget is locked before measuring target hardware.
- **No unconditional auto**: player command is explicit; batch preview allowed; future auto major gate OFF by default. Do not allow a simple `auto_breakthrough` flag to spend Sect resources bypassing transactional preflight.
- **Godot gates**: parse changed GDScript; focused DV2-03F manifest/source/transaction/scale tests, previous DV2-03E3.1 focused suite, full P0→P3.7 cumulative on official Godot 4.7.2 at same gameplay SHA. Windows native/visual is **PENDING USER** unless user actually runs. A GitHub doc commit is never a gameplay PASS.
- **No false completion**: during incremental implementation, sources/Seals not yet authored remain disabled/unavailable. Shipping only A/B as a separately labeled vertical slice does **not** mean DV2-03F 29/29 complete; project remains DV2-03 ACTIVE until phase closeout evidence. Never add another implementation phase concurrently.

### N8. Separate permission gate — exact next action

Current explicit authorization state:
- `F01..F12.PRINCIPLE_APPROVED = true`;
- `F05.NUMBERS_DESIGN_LOCKED = false`;
- `F07.EVIDENCE_VERIFIED = false`, `F10.EVIDENCE_VERIFIED = false`;
- `DV2_03F.DESIGN_LOCKED = false`;
- `DV2_03F.CODE_AUTHORIZED = false`.

The user may later say **“CHO PHÉP CODE DV2-03F, BẮT ĐẦU F0/F1”** or specify another explicit packet. Only then may that specified coding scope begin. Approval of F01–F12 in this conversation by itself **DOES NOT** trigger work, Codex, Godot test runs or implementation, and does not grant advance authority for F05 final tuning. If F07/F10 empirical results require change of already locked economics or EXP, pause and ask for a separate decision.

**GitHub handoff:** retain this detailed contract here; link from `NEXT_CHAT_HANDOFF.md`. Do not create another parallel “final” manifest or rename these files; section D remains the **single source of 29 recipe quantities**.


## O. PHƯƠNG ÁN A — QUAY VỀ ROADMAP ĐỆ TỬ V2, RÚT GỌN PHẠM VI DV2-03F (11/10/2026, LATEST USER DECISION)

> **ƯU TIÊN HIỆN HÀNH — SUPERSEDES OUT-OF-SCOPE REQUIREMENTS IN E, L, M, N.** Người dùng chọn **phương án A** sau khi duyệt F01–F12 về nguyên tắc: tập trung hoàn thiện đệ tử V2 có thể chơi thật; **giữ tuyệt đối 29 công thức/8 nhóm/3 Ấn và bảng EXP, không sửa Tu Vi/Body luật đã khóa**; **săn quái, boss, khám phá/vùng tài nguyên là tuyến cung chính**, có **chống kẹt thực**; ủy thác và kinh tế cao giới phải **tinh giản/hoãn**; nội dung chưa có **không kích hoạt**. Chỉ cập nhật tài liệu. **CHƯA CODE, CHƯA DESIGN LOCKED, không có lệnh khởi động F0–F7**. Bảng công thức duy nhất vẫn là **mục D**. Mục N là hồ sơ phương án đầy đủ trước khi rút gọn, giữ để truy vết; **mục O là thứ tự/ranh giới có hiệu lực mới nhất** khi hai bản khác nhau.

### O1. Kết luận rà soát kế hoạch, tránh đi xa phạm vi

- Roadmap gốc `docs/DISCIPLE_V2_CHARACTER_IMPLEMENTATION_PLAN.md`: DV2-03 hai đường tăng trưởng và cổng; DV2-04 Linh Căn, DV2-05 Trait/Mệnh, DV2-06 Huyết Mạch/Thể Chất, DV2-07 Công Pháp/Chủ Đạo/Kỹ năng, DV2-08 vòng hoạt động trọn vẹn, DV2-09 UI, DV2-10 test 1k–3k. **Không được nén DV2-04..DV2-10 thành các dependency bắt buộc đóng DV2-03F**.
- P3.7 canonical `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md` §§3,5,6,27 đã định hướng **săn quái là tuyến thưởng chủ đạo**; reward có thể gồm Linh Thạch, Tu Vi và vật liệu trong tương lai, nhưng **không được coi như reward hiện đã code**.
- Code live `HuntingMapV2` mới có **Thanh Trúc Lâm/Bạch Thạch Khê/Hắc Phong Cốc**, reward win-claim của `tinh_lang_bi` đã có, `linh_tuy` ở Thanh Trúc là rare roll (L1=0%). `tu_van_thao` chỉ có crop Linh Điền Lv30; hiện chưa có drop sớm. 12 ID C–H và 3 Ấn **chưa được đăng ký / chưa có tuyến thực**. `HuntingPveRunV2` là một session claim, chưa chứng minh scheduler săn tự động ở scale 1k–3k. No false playable claims.
- 29 recipe costs, EXP/rate/60s per tick, all-or-nothing gate transaction, persisted replay guard, warehouse reservation/locks, independent Tu Vi/Body **vẫn thuộc DV2-03F tối thiểu và phải chính xác**. Không thêm “Phẩm Lực” hoặc vật liệu thay thế chung.
- **Không chốt được tốc độ 30 cảnh giới khi các event, kỳ ngộ, pháp bảo, công pháp, đan dược và cao cấp map chưa thiết kế**. Con số ~48 năm ở 1.500 EXP/phút unbuffed chỉ là baseline diagnostic, **không là thời gian chơi chuẩn hoặc yêu cầu retune EXP**. Khung cân bằng **khoảng rộng** và điểm mở rộng hợp pháp, không một quota 1000 năm/hoặc target cứng.

### O2. Hợp đồng nguồn cung *săn quái làm chính*, thiết kế tối thiểu

1. **Một cơ chế `earned_source -> item_id -> quantity -> warehouse` có version + vùng/bậc + event claim ID**, dùng lại nơi đã có: quái thường/tinh anh/boss, phần thưởng vùng khám phá/điểm tài nguyên có hoạt động hoàn thành thực. Đăng ký nguồn theo ID và vùng, không viết một engine/ủy thác mới cho từng nguyên liệu. Reward chỉ phát khi actual victorious/completed event, một claim/encounter, lưu chống lặp/khôi phục save. “Monster drop herb” được phép theo gameplay; không ép mọi cây phải trồng được.
2. **A/B vertical slice là ngưỡng chơi thật đầu tiên**: A tận dụng Thanh Linh Thảo từ Linh Điền hoặc thưởng hoạt động, Tinh Lang Bì qua win-claim hiện hành. B thêm một **nguồn thực mở sớm cho chính `tu_van_thao`** và đường `linh_tuy` có bảo đảm; không đòi Linh Điền Lv30, Linh Tuyền Chi Tâm, Tu Vi ngang Luyện Thể hoặc gate4 đã vượt. Có thể tái sử dụng các vùng Nhân hiện hành **nếu** thử nghiệm cân bằng/viability và quyền truy cập đủ; **không tạo map đã tồn tại bằng lời**.
3. **Chống kẹt không phải kinh tế ủy thác khổng lồ**: nguyên liệu bắt buộc có đường lấy chắc chắn **sau một số hữu hạn hoạt động thắng/hoàn thành hợp lệ**, ví dụ tích lũy claim đúng vùng/cấp để phát thẳng **chính vật liệu cần**, hoặc một phần thưởng hoàn thành nhiệm vụ thật; số trận/lần nhận, mức rơi và cohort share là **OPEN**. Đồng thời direct random drops vẫn tồn tại để tạo bất ngờ. Có thể tích hợp bộ đếm vào **cùng tuyến săn**, không bắt buộc hai engine/phái đoàn độc lập cho cả 19 ID.
4. **C–H cùng ba Ấn:** công thức và typed IDs vẫn giữ; thiết kế metadata/source slot không đồng nghĩa đã có quái/boss/vùng. Chỉ mở reward + cổng khi có vùng, quái hoặc nguồn tài nguyên thực với phần thưởng và chống kẹt phù hợp **trước cổng yêu cầu**. Nhân Ấn cần nguồn ở Nhân r10, Tiên Ấn ở Tiên r20, Thần Ấn ở Thần r29; không dựa vào cảnh giới sau, không độc quyền first-clear, Ấn tiêu hao 1/lần. Chưa có nội dung ⇒ hiển thị `content_unavailable`, không vượt cổng, không thưởng giả. Content high-tier sẽ được lấp dần **khi roadmap mở map/gameplay tương ứng**, không là điều kiện để hoàn thành slice A/B.
5. **Chỉ số tỷ lệ rơi, thời gian, bảo đảm và nguồn EXP/sự kiện mở rộng vẫn chưa LOCK**. F05 lịch sử (3 chính/30 team-min, 1 phụ/≤4 win, 1 Ấn/≤8 win) chỉ là dữ liệu stress-test nếu còn cần, **không bắt buộc cài hoặc áp dụng trong live**. Chọn tỉ lệ riêng từng quái/vùng/cấp ở đúng đợt làm nội dung, thử hành trình hợp lệ và kiểm toán phát thưởng. Các event/pháp bảo/đan sau này gắn qua named modifier/typed source; không viết module sự kiện/pháp bảo trong F.

### O3. Phân loại F01–F12 sau lựa chọn A (không thay manifest)

| Mã | Hiệu lực sau chốt A |
|---|---|
| F01 | **GIỮ** đúng section-D 29 recipes, 8 nhóm, 3 Ấn, 562/143/3; không phụ phí |
| F02 | **CHỈNH CÁCH THỰC HIỆN**: săn/vùng/Boss ưu tiên; direct drop + 1 chống kẹt qua hoạt động thực, **không ép 2 subsystem/ủy thác độc lập per ID** |
| F03 | **GIỮ ƯU TIÊN SỚM**: `tu_van_thao` + `linh_tuy` có nguồn sớm, không cần field Lv30; không mặc định dựng ủy thác riêng |
| F04 | **GIỮ DANH TÍNH** 12 ID C–H + 3 Ấn; **HOÃN NỘI DUNG vùng/boss cấp cao chưa có** thay vì xây hết trong F |
| F05 | **PILOT-ONLY / DEFER tuning**: 3/30, 4/8 không thành live law; tiếp tục để mở tỷ lệ rơi |
| F06 | **GIỮ NGUYÊN 3 Ấn, kiếm lặp lại**: boss hoặc chiến công vùng đúng giới, nguồn cần trước gate, nhưng phase-map sau mới mở high-tier |
| F07 | **THU HẸP verification**: đo hiện trạng Linh Thạch và chống thiếu ở loop A/B; không buộc thiết kế hoàn thiện dòng tiền 3k/cao giới ngay trong F. Không giả định P3.7 loot-stones đã live |
| F08 | **PHÂN KỲ**: batch request/preview và tránh O(roster) mỗi paint trong F; automation hunting 3k, policy phức tạp thuộc DV2-08/10; auto dùng vật liệu vẫn OFF |
| F09 | **GIỮ CỨNG**: transaction all-or-nothing, một kho, idempotency, saved receipts, rollback |
| F10 | **THU HẸP verification**: xác minh nguồn EXP/cost **đang hoạt động** và tính mở rộng; không yêu cầu kết luận cân bằng r1→r30 hay thêm bonus chưa có. **Không đổi EXP đã khóa** |
| F11 | **GIỮ CỨNG**: gate thiếu nội dung = `content_unavailable`; không claim 29/29 playable trước content |
| F12 | **PHÂN KỲ**: focused+full DV2-03F và basic scale/save; thử 1k–3k gameplay toàn bản, 30 cảnh giới và visual acceptance thuộc DV2-10/map phases, không nói F slice = full product complete |

### O4. Thứ tự **rút gọn** F0–F7 — chỉ PLAN, không lệnh code

| Gói (vẫn thuộc DV2-03) | Thực hiện **khi được cho phép code riêng** | Kiểm tra bắt buộc tại gói |
|---|---|---|
| **F0 — xác nhận nền** | So live owner/time/EXP, 3 map/reward, warehouse, tiết kiệm stone, vùng mở, save/reload; ghi nguồn nào ACTIVE/BLOCKED | Evidence ở source SHA mới, không nhận reward giả; nhận diện F07/F10 đang thiếu consumer nào |
| **F1 — 29 manifest + 19 typed IDs** | Khai báo 29 công thức khóa, 12 C–H IDs, 3 Ấn IDs, version/schema; **không kích hoạt** high-tier | 29/29 exact, old saves an toàn, 562+143+3, high-tier fail-closed |
| **F2 — gate transaction/receipt** | Preview pure, trừ gói trong warehouse và tăng Body 100% đúng canonical, rollback/idempotent/restart/recovery | 29 fixture gates transactional test (không giả là playable), dual-actor shared last item, reserve/locked, no double payment |
| **F3 — nguồn rơi A/B + chống kẹt nhỏ** | Gắn typed payouts vào **win-claim** hiện có; thêm A/B nguồn tài nguyên/kết quả săn hợp lệ; chống kẹt B bằng giới hạn hoàn thành thực; không dựng quest economy lớn | Một đệ tử có thể kiếm thật và qua các cổng A/B đã bật; low Tu Vi; no field Lv30; PvE defeated/no-claim/replay an toàn |
| **F4 — nối giao diện tối thiểu** | P3.2 Body gate preview, “thiếu loại nào, kiếm đâu”, actual Thối Thể command, hiển thị `content_unavailable` cho C–H/3 Ấn chưa live | Không nút giả, không auto-gate, vẫn tôn trọng `reserve_min/locked` |
| **F5 — smoke số liệu nhỏ, chống nghẽn** | Tỉ lệ rơi và số win bảo đảm A/B dạng PILOT, bằng chứng Linh Thạch thật trong loop đang live, EXP current-source, save/load và đội cơ bản | Không RNG-only gate4, không nguồn kiếm vòng khóa; F07 low-tier record, F10 current-source verified, chưa tuyên bố full balance |
| **F6 — focused/full tích hợp** | Godot 4.7.2 focused same-code-SHA, full P0→P3.7, một real disciple cultivate→work→hunt/claim→Body gate→fight/save→reload | PASS từng test với run link; không khẳng định DV2-08/09/10 đã DONE |
| **F7 — đóng phạm vi hẹp, bàn giao** | Ghi rõ phần A/B live vs C–H/3 Ấn **DESIGN/UNAVAILABLE** và các nguồn/kinh tế/events còn thiếu; đề xuất chuyển đúng roadmap | Chỉ đóng lát **DV2-03F A/B** khi test đủ. Đóng toàn bộ DV2-03 vẫn theo `AGENTS.md`/roadmap; không đóng toàn phase nếu known required content còn chặn |

**Lưu ý nghiệm thu:** F1/F2 có thể kiểm tra đủ 29 công thức/giao dịch qua fixture; đó là **technical coverage**, KHÔNG chứng minh người chơi kiếm được nguyên liệu C–H. Nếu DV2-03 yêu cầu đóng 29/29 gate thực trước DV2-04 theo hợp đồng cha, thì giữ DV2-03 ACTIVE và cần user quyết định có **chấp nhận bàn giao F slice fail-closed** để đi tiếp hay không; không tự tuyên bố “CLOSED” để vượt quy tắc một active phase.

### O5. Khoảng cân bằng và event/EXP mở rộng — chỉ giữ chỗ cho sau

- **Ngay bây giờ**: khóa structure/manifest/transaction/valid source, đo A/B ở dải rộng về thời gian, tỷ lệ thắng, drop variance, thiếu item, stone inflow/outflow. Không chốt daily budget cho 3,000 nhân vật cao giới.
- **Khi nội dung ra đời**: event/kỳ ngộ/bí cảnh/pháp bảo/đan có thể thưởng named items/EXP hoặc typed modifiers qua chủ sở hữu + provenance, điều kiện thật, cap/stacks rõ, cùng receipt chống replay. Không tự thay EXP bảng 300 tầng, cộng EXP hai lần trong một tick hoặc phát thưởng từ UI.
- **Không có hệ số event được chốt**: các tỉ trọng thường/hiếm/cực hiếm/kỳ ngộ trước đó chỉ là ý tưởng brainstorm, không biến thành nội dung production hoặc ID. “Cảnh cuối sau 1,000 năm” là ví dụ về vùng cân bằng, KHÔNG cam kết gameplay.
- Nhịp tiến cảnh giới cao và tiêu thụ Linh Thạch 1k/3k sẽ **được đo lại khi những hệ thống thực sự có consumer**; ghi rõ `UNVERIFIED`, không gắn `FAIL` chỉ vì chưa thiết kế tất cả event, và không gắn `PASS` vì chỉ có phép chia EXP nền.

### O6. Quyền triển khai và điều kiện xác nhận

- **User-approved latest direction = A, docs only**; F01–F12 principle approval giữ hiệu lực **trong phạm vi đã tinh giản như O3**; section N's high-tier full-source expansion and full-realm F07/F10 closure requirement **không còn là điều kiện code DV2-03F A/B**.
- `DV2_03F.DESIGN_LOCKED=false`, `DV2_03F.CODE_AUTHORIZED=false`, `F05.NUMERIC_RATES_LOCKED=false`.
- Không tạo class, scene, resource, mock loot, CI workflow, test code mới hoặc run Godot trong lượt chỉnh tài liệu này.
- Chỉ bắt đầu gói F0/F1 hay gói riêng khác sau lệnh code **mới, rõ phạm vi** của người dùng; sau đó luôn xem lại live main, so thay đổi và kiểm chứng focused/cumulative đúng ở gameplay SHA.


## P. DV2-03F / F0 — ACTUAL RUNTIME, BODY EXP AND HUNT LOOT BASELINE EVIDENCE (11/10/2026)

> **AUTHORIZATION:** User explicitly authorized **CODE F0 ONLY** on 11/10/2026 at 09:38 ICT, for baseline inspection/EXP+loot evidence/appropriate F0 tests. This supersedes the prior §O6 **no-code** statement **only for F0**. **F1–F7 are NOT authorized; `DESIGN LOCKED=false`**; 29 recipe rows (section D), 3 Seals, canonical EXP, all earlier Body/Realm rules and live production/loot semantics are untouched. This report records actual F0 verification, not new material availability.

### P1. Exact changed source/test boundary

- Starting branch `main@33f71abcc9404fe888d25a8c5355409a423ad128` (Option A documentation; latest gameplay/test had been E3.1 `3c7e9a7691f549097dd0a67ed50ead8b7be18a4c`).
- **ONE F0-only new test**: `godot/tests/simulation/dv2_03_f0_source_baseline_test.gd` committed at `677bf152f1bdea9a6fbe5f6bf3abd99046b721b0`. It observes real production consumers, actual cleared hunt, warehouse claims, paid Sect-stone spend, no double claim. Test seed is deterministic; it **does not grant fake gameplay money/resources to pass**.
- **Two CI wiring edits, no gameplay rules**: `.github/workflows/dv2-03-realm-body-progress.yml` and `.github/workflows/p3-7a1-building-backend.yml`, the latter re-runs existing FAST + FULL cumulative on audit changes. Live main with both CI files at `cd52d4b97b673dc116606e0fb6b413aec16119b1`.
- No modifications to `godot/src/`, EXP tables, recipe manifest, resource registry, new item IDs, loot production functions, UI, assets or any F1–F7 owner. **No F1 registry, no F2 Body gate transaction, no F3 acquisition changes**.

### P2. Evidence: focused official Godot 4.7.2 PASS on F0 test SHA

**Run [DV2-03 focused #38105919954](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38105919954)**; execution commit `3c48bf7f763acf8b2d6cc6e52b25b81356b72de1` (new F0 test + focused workflow), **completed/success** on official Godot 4.7.2 Linux. The focused job explicitly reports **DV2-03F F0 source baseline: PASS**. Each older DV2-03 focused step in this run completed successfully, including existing active mining Body EXP, the existing paid two-slot Rèn Thân consumer, 30×10/29-gate progression, timing/save and P3.2 UI tests. A passing old 29-gate *math* test does not mean F1/F2 gate-material transaction exists.

Actual `DV2-03F F0 SOURCE BASELINE:` log record (source: job `114371313453`):

| Measured assertion | Actual result / provenance |
|---|---|
| All Realm XP r1..r29 required | **37,890,400,000 EXP**, unchanged `DiscipleProgressionBalanceV2.REALM_TOTAL_XP` |
| Canonical Tu Vi natural source | **1,000/min** baseline; Chuyên Tu `×2` existing functional flow and focused test (a cost/rate authority, not event-balanced completion time) |
| Body production reference | **250 EXP/min**, real mining-active-phase producer already has separate PASS test; inactive travel/haul yields no Body XP |
| Body expedition reference | **750 EXP/min in type contract only**, no evidence of a continuous live V2 scheduler awarding active expedition Body XP; **UNVERIFIED**, no invented grant |
| Body paid Rèn Thân reference | **1,500 EXP/min**, two active physical slots; F0 selected test disciple natural factor gave **1,557 EXP in one committed eligible minute** and charged **exactly 1 Sect Spirit Stone** |
| Duplicate paid same-minute call | Rejected; did not charge again |
| P3.7 V2 region content currently authored | **3 Nhân regions**: Thanh Trúc Lâm, Bạch Thạch Khê, Hắc Phong Cốc, 5 grades per region |
| Early `tu_van_thao` region reward route | **0 actual region entries** (F3 required, not F0) |
| Existing `linh_tuy` guaranteed route | **None verified**; Thanh Trúc Lâm uses RNG rare roll. Level 1 chance = 0; L2–L5 chances = 0.03/0.08/0.16/0.26 per qualifying spawned encounter preview, **not a bounded-success fallback** |
| Earned `HuntingMapV2` actual F0 Lv1 fight | Actual six-combatant win (seed 901), `{"linh_moc":3,"thanh_thiet":1}` deposited in canonical warehouse |
| Hunt rewards Sect Spirit Stones | **0** in tested genuine reward and the currently implemented `preview_reward/claim_reward` material-only pipeline. This is **not** proof that future P3.7 planned hunting stone reward is implemented |
| Claim replay + save | Unfinished fight denied, preview did not mint, single win claimed exactly once, repeated claim denied, persisted claim after SectState JSON roundtrip |

The QA F0 test does **not** pretend the authenticated expedition scheduler exists; it asserts missing active-context evidence fails. The printed `missing_guaranteed_linh_tuy=true` and `full_hunting_scheduler_verified=false` are truthful F0 classification flags, not CI failures.

### P3. Source ownership audit and F07/F10 boundaries

- `HuntingPveRunV2` is a real **explicit session** (assemble saved disciples, many-vs-many battle, claim after victory), with run snapshots/save. Its file documents it is **not installed in the legacy autonomous scheduler**; a completed manual/explicit hunt **is not proof of hundreds of autonomous parties hunting continuously**.
- `HuntingMapV2.preview_reward` shows fixed registered material yields and a level-based rare roll; `claim_reward` never calls `sect.spirit_stones +=`. `ResourceRegistry` has 4 already-existing recipe material IDs only (A+B), not the 12 C–H or 3 Seals; no source is activated by F0.
- `TechniqueSystem.initialize` can seed initial Sect stones **500** in its own enabled setup; `TechniqueSystem.sell_manual` adds stones only by consuming actually owned manuals, and `learn_technique` moves actual disciple personal stones into Sect stones after the real learn eligibility/payment. **Neither establishes a recurring autonomous Sect stone funding lower bound for the F07 sustained farm+Rèn Thân loop**. Current crop planting and paid Rèn each spend Sect stones. F0 only verifies current spend path and item-only hunt income; future F5 A/B income viability remains **UNVERIFIED**.
- Existing `DiscipleTuViFlowV2` grants one minute source with anti-double-grant at saved `last_passive_tuvi_tick`. Body production-mining and paid training source owners are concrete; expedition `750` is merely a validated typed source without a demonstrated end-to-end autonomous schedule. F10 whole-realm pacing **UNVERIFIED**, not a reason to revise locked EXP.
- **A/B prerequisites unresolved** for F3: `tu_van_thao` crop needs Lv30 Spirit Field but Body gate4 demands it; rare-only `linh_tuy` drop has no bounded-win guarantee. F0 deliberately does not add new drops, missions, species, area, Ấn or stone income.

### P4. Cumulative, phase and permissions

- [P3.7 FAST+FULL cumulative #38105926374](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38105926374) at code/test/config SHA **`cd52d4b97b673dc116606e0fb6b413aec16119b1`** is now **COMPLETED/SUCCESS**. Both official Godot 4.7.2 Linux steps **FAST and FULL completed/success**. This is genuine F0 regression evidence, **not** a Windows run and **not** DV2-03F gameplay/content closure. The **up-to-date PC task checklist is in `CURRENT_CHECKPOINT.md`**, and Windows remains **PENDING USER** (user currently has no access to PC).
- **User Windows Godot 4.7.2 and visual acceptance remain PENDING**; F0 is a headless runtime audit, not a visible interface acceptance.
- **F0 focused test implementation/report only**: recorded. F0 can be called `FOCUSED PASS` under the run above, but **NOT DV2-03F or DV2-03 CLOSED, not full 29 material gate playable**.
- **NEXT authorized action remains NONE**: await an explicit user instruction before F1 (manifest, registry, schema) or additional F0 implementation. If the next user asks for F1, re-fetch main, inspect source/CI and respect the newest F0 audit and §O slim roadmap. No automatic extension to F2–F7.


## Q. F1 — STATIC 29 BODY GATE MANIFEST + 15 TYPED RESOURCE IDS (11/10/2026, USER-AUTHORIZED CODE)

> **LATEST IMPLEMENTATION EVIDENCE.** User explicitly authorized only **F1**: exact 29 immutable Body-gate recipe identities/quantities and 12 C–H resources + 3 Seals; preserve EXP and all already-locked mechanics; no loot routes/real high-tier content/F2 transaction/F3–F7. **DESIGN LOCKED remains false**. This section supersedes earlier historical statements asserting "15 new IDs absent" or "F1 code not authorized", but does **not** supersede §D's approved quantitative source.

### Q1. Actual code (F1 only, NO gameplay acquisition/transaction)

- `godot/src/simulation/cultivation/disciple_body_gate_content_v2.gd`: new `DiscipleBodyGateContentV2` class, `VERSION=1`, 29 read-only `recipe(source_realm)` rows from §D, group→explicit ID mapping, exactly three seal identities (realm 10/20/29), pure `all_recipes()`, 19 `material_ids()`, defensive fresh returns, strict `validate_manifest(raw)` and `validate_registry()`. ALL 29 entries return `content_available=false` and `reason=content_unavailable` as F1 **metadata**, not a game-facing gate decision. There is NO authorized `requirements_verified` transaction; F2 must authenticate real access/warehouse/receipts independently.
- `godot/src/simulation/resource/resource_registry.gd`: unchanged 12 old registry definitions, especially the 4 A/B recipe inputs `thanh_linh_thao`, `tinh_lang_bi`, `tu_van_thao`, `linh_tuy`; appended precisely 12 C–H IDs and 3 consumable Seal IDs:
  - C: `huyet_linh_sam`, `huyet_thu_tinh_huyet`;
  - D: `kim_cot_thao`, `linh_thu_cot_ngoc`;
  - E: `tien_tuy_lien`, `tien_thu_chan_cot`;
  - F: `bat_hoai_tuy_dich`, `dai_la_kim_cot`;
  - G: `than_mach_tinh`, `than_thu_cot`;
  - H: `hon_don_tuy_hoa`, `bat_diet_than_cot`;
  - Seals: `an_nhan_gioi` (gate 10), `an_tien_gioi` (gate 20), `an_than_gioi` (gate 29).
  - All 15 include explicit `name/family/realm_grade/realm_rank/market_value/tags`. Rank design metadata: C 7 / D 11 / E 15 / F 18 / G 21 / H 26; seals 10/20/29; grade `nhan/tien/than`. **`market_value=0` is a conservative not-priced marker**, NOT approved auction/sale value or reward yield. Re-evaluate only when a real trading/content consumer is authorized. No global Phẩm Lực.
- **NO** `godot/src/simulation/combat/hunting_map_v2.gd`, `hunting_pve_run_v2.gd`, `disciple_realm_progress_v2.gd`, `disciple_progression_balance_v2.gd`, `SectState`, `WarehouseSystem`, gameplay UI, existing drop rate or existing source EXP changes. No new `source_id`/loot/pity/boss/zone; no extra wallet, implicit claim, gate debit or realm upgrade. No F2 persisted receipts, F3 guaranteed item acquisition, F4 UI, or F5 balancing changes.

### Q2. Exact manifest and test proof

- `godot/tests/simulation/dv2_03_f1_body_gate_manifest_test.gd`: exact independent 29-row quantities, group and ID pairing, totals **562 main / 143 auxiliary / 3 consumed seals**, eight distinct groups, 19 unique item IDs, 15 new IDs. Seals ONLY at source Body realms 10, 20, 29; no seal at other 26 gates. Out-of-range lookup empty.
- Negative input checks: omitted row, altered resource identity, floating-point quantity, unexpected `requirements_verified` field, changed version, and wrong raw manifest shape fail validation. Read-only API does not expose a shared mutable recipe. Every gate returns unavailable.
- Existing P3.7 save JSON round-trip preserves old warehouse/claim state and **does not create** new resources. QA may put a new registered resource and seal into canonical Sect Warehouse and round-trip them, demonstrating storage compatibility, **not live acquisition**. Existing three Nhân region rewards are inspected to confirm none of the new C–H/Seals was added to any real region drop.
- [Official Godot 4.7.2 DV2-03 focused #38117236823](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38117236823) on gameplay/test+CI source `1e0cf39f9122796c4c64a71d52f76b263d525051`: **COMPLETED/SUCCESS**. The actual step prints **`DV2-03F F1 MANIFEST AND TYPED RESOURCE REGISTRY: PASS; gates=29,main=562,aux=143,seals=3,item_ids=19,new_ids=15`**. Existing focused DV2-03 tests in that same workflow also passed.
- P3.7 FAST+FULL cumulative: [#38117245351](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38117245351) on source `dec66e794a08a7ef70d9d43869441639b3a7fe06`. Check GitHub live completed status before marking FULL PASS. A historical interim P3.7 run [#38117169945](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38117169945) at **`9cd2d27`** failed because the brand-new F1 file initially had a GDScript continuation parse error at line 119. Fixed in **`5c9e9997`**; later official focused/parse is PASS. Do not confuse that superseded failed SHA with current F1 code quality.

### Q3. Status and PC checklist authority

**F1 implementation + focused CI PASS, cumulative status requires live check.** The new metadata exists in code and is registered, but **29/29 acquisition/gate readiness is still BLOCKED**: no legal Body warehouse transaction F2, no new earned drops from F3 and no C–H/Seal source content. The `content_unavailable` field is not a reason to claim a material route exists. Player's **Windows PC currently unavailable**: Windows native UI and user visual acceptance remain **PENDING USER**, not PASS. See `CURRENT_CHECKPOINT.md` checklist. Next phase implementation **F2 requires another explicit permission**; do not auto-implement it or begin F3–F7.

