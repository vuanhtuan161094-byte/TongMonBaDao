# BÁO CÁO BÀN GIAO VFX — TÔNG MÔN BÁ ĐẠO
## Tổng hợp tiến độ, kinh nghiệm và quy tắc sản xuất | 18/11/2026

**Chủ đề:** phần VFX Độc Tu POI01–POI20 và bài học phối hợp với Quyền Tu / Phù Tu / Hỏa Phù / JX1.  
**Repository:** [Tông Môn Bá Đạo](https://github.com/vuanhtuan161094-byte/TongMonBaDao) · nhánh integration/pve-p0-playable-ui-20261103 · [Draft PR #72](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72).  
**Baseline kiểm chứng:** HEAD **0960c07f985c9f1a172d1975a6ecb02b26580b74**, trước commit báo cáo.  
**Mục đích:** tài liệu gốc để chat khác tổng hợp tiến độ VFX toàn dự án. **ĐÂY LÀ BÁO CÁO, KHÔNG PHẢI BẰNG CHỨNG ART/PvE MỚI**. Tài liệu này không sinh sprite, không chạy lại Godot, không thay đổi quyền nghiệm thu và không bật kỹ năng.

> **QUY TẮC ĐỌC:** POI01–POI20 là **20 mốc sản xuất/thử nghiệm**, không đồng nghĩa 20 kỹ năng đã duyệt, không đồng nghĩa 20 cast-master độc lập: **POI01/POI02 đều thử Xà Ảnh Human**, POI03/18/19 thuộc cùng họ Phụ Cốt khác tầng/nhánh, POI20 thuộc nhánh Tiên A của Xà Ảnh. Cần đối chiếu **canonical skill ID**, không cộng POI tag thành tiến độ 2.196 kỹ năng.

## 1. KẾT LUẬN ĐIỀU HÀNH

1. **Đã hình thành dây chuyền có thể kiểm toán:** catalogue và 3 đồng hồ → ý tưởng hình tượng → nguồn RGBA có provenance → atlas pose khác nhau → scene Godot 4.7.2 → G3.5 native 1280×720 với quái WALK → G3.6 độ nổi 1× → G3.7 đọc nghĩa chiêu → G4/G5 movie/QA exact-SHA → G6 chủ dự án duyệt → G8 tích hợp runtime riêng. Nguồn chuẩn: [AGENTS](../../AGENTS.md), [SOP V3 + V4](TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md), [Sprite Layer Pipeline](TMB_VFX_SPRITE_LAYER_PIPELINE_20261114.md), [V4 Packet README](vfx_packets/README.md).
2. **Bằng chứng mới nhất thuộc POI20 R1C:** 60 pose RGBA / 5 atlas + luồng sáng ADD vẽ liên tục trong Godot, [Actions #44135139429](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44135139429), exact source SHA **26f759a629adac63bffe07fa33f24ea967bab537**, movie **639 frame / 10,65 giây / 1280×720**; kỹ thuật PASS, **mỹ thuật chờ chủ dự án duyệt**, PvE HOLD. [Báo cáo POI20](VFX_POI20_XA_ANH_R1_20261117.md).
3. **POI19 R3** chứng minh ưu điểm của ánh sáng **gradient trail tính trực tiếp trên mỗi frame trong Godot**, giữ 80 pose/6 atlas RGBA: [Actions #44105241617](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44105241617), SHA **4a316afc28243f632e0c61b07ccb984dab2c310b**, movie **510 frame/8,5 giây**; vẫn nợ tinh xảo hoa/ấn và impact, chưa ART FINAL. [Báo cáo POI19 R3](VFX_POI19_PHU_COT_CO_TIENB_R3_20261117.md).
4. **Không lấy CI xanh để tuyên bố đẹp.** Đã có nhiều lần native/test PASS nhưng chủ dự án chê xấu (POI18 R1B; POI19 trước R3; POI20 R1 vòng tròn; FIST12 R5). Cần quyết định mỹ thuật theo video 1×.
5. **Không coi thử nghiệm JX/Võ Lâm là asset gốc đã được cấp phép.** Trong repo có atlas Võ Đang #158, Ngũ Độc #63 và Source VL; đã chạy A/B Godot để học ánh sáng, cách đặt chiêu và màu. Quyền phát hành lại tài nguyên thương mại **CHƯA XÁC MINH**, nên nội bộ/reference-only, không đưa vào PvE/release.

## 2. PHẠM VI VÀ QUY TẮC ĐẾM TIẾN ĐỘ

- Theo [SOP Art-First](TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md): **12 trường phái × 17 CAST_MASTER = 204 family thi triển**; có các family passive/innate/event-only cần visual event riêng, **không tự tạo cast giả**. Toàn bộ 2.196 skill IDs / 420 family / 36 nhánh là **mapping/catalogue**, không phải 2.196 clip Godot đã hoàn thành.
- [Ledger Độc Tu 183 ID](vfx_school_ledgers/01_poison_183.csv) tại baseline có 183 dòng, thuộc **một** phái trong 12. Dữ liệu owner_gate: **6** OWNER_VISUAL_APPROVED, **1** OWNER_VISUAL_APPROVED_R1B, **5** OWNER_PROVISIONAL_ACCEPTED_NOT_FINAL, **1** OWNER_PROVISIONAL_ACCEPTED_R2C_G5_HOLD, **2** OWNER_PROVISIONAL_CONTINUE, **1** OWNER_PROVISIONAL_ACCEPTED_R2D_POLISH_BACKLOG, **1** OWNER_VISUAL_PENDING_R1_G37_SEMANTIC, **166** OWNER_VISUAL_PENDING. Đây là **đếm ID/tầng**, gồm nhiều ID còn NOT_ART_APPROVED; không phải đếm master chất lượng cuối cùng.
- Phân tầng trạng thái bắt buộc: CATALOGUE_MAPPED ≠ CODE_LAB_READY ≠ GODOT_FOCUSED_TECH_PASS ≠ G3.6_VISIBILITY_PASS ≠ G3.7_SEMANTIC_ART_PASS ≠ OWNER_VISUAL_APPROVED ≠ PVE_INTEGRATED ≠ RELEASE_READY.
- Quyết định nghiệm thu được gắn **skill ID + nhánh/tier + asset revision + exact source SHA**. Duyệt Human **không tự kéo sang Tiên/Thần**. “Tạm được / tiếp skill” = **chấp nhận tạm để chuyển việc**, không tương đương final art hay cho phép merge.

## 3. KIỂM KÊ POI01–POI20 (ĐỐI CHIẾU HỒ SƠ)

| Mốc | Đối tượng / phiên bản quan trọng | Chứng cứ và tình trạng có căn cứ | Kết luận mỹ thuật / việc còn lại |
|---|---|---|---|
| POI01 | Xà Ảnh Quấn Mạch Human, R1–R5 | Godot native có nhiều phiên; R1–R4 từng bị tác giả tự đánh giá lỗi noodle, neon ring, che mặt. [Brief](VFX_POI_01_XA_ANH_QUAN_MACH_ART_BRIEF_20261113.md) | R5 ứng viên; lịch sử nghiên cứu, **không tính riêng một skill thứ hai** với POI02 |
| POI02 | Xà Ảnh Quấn Mạch Human, clean-sheet | Sprite hình tượng rắn rõ hơn, native Godot; [Hồ sơ](VFX_POI02_CLEAN_SHEET_SOURCE_VL_ART_BRIEF_20261113.md) | Ledger Human = OWNER_VISUAL_APPROVED, **pha tụ lực vẫn nợ polish** |
| POI03 | Phụ Cốt Cổ Human | R1 che mặt caster, R2 seal to che ngực, R3 sửa vị trí; [Hồ sơ](VFX_POI03_FU_COT_CO_ART_BRIEF_20261114.md) | Ledger Human = OWNER_VISUAL_APPROVED; không tự duyệt Tiên A/B |
| POI04 | Cổ Vụ Mê Tung Human | R2 sương quá thấp/yếu, R3 tăng cột khói; [Hồ sơ](VFX_POI04_CO_VU_ME_TUNG_ART_BRIEF_20261114.md) | Ledger Human = OWNER_VISUAL_APPROVED |
| POI05 | Tán Cổ Diễn Nhiễm Human | Nhiều lần R1–R10: sao/hoa, bọ, râu dài, che mặt; R10 kỹ thuật có bằng chứng nhưng đẹp vẫn là vấn đề; [hồ sơ](VFX_POI05_R6_TU_TIEN_REMAKE_ART_BRIEF_20261114.md) | Ledger hiện GODOT_LAB_PASS_ART_PENDING, OWNER_VISUAL_PENDING; tài liệu bàn giao cũ có ghi “tạm dùng” nhưng **không nâng trạng thái khi ledger chưa xác nhận** |
| POI06 | Vạn Cổ Phệ Giới Human R11 | 48-frame atlas, native Godot; [R11 native](VFX_POI06_R11_GODOT_NATIVE_ACCEPTANCE_20261114.md) ghi **chủ dự án chấp nhận R11 preview**, native recheck PASS | **MÂU THUẪN HỒ SƠ:** ledger còn GODOT_LAB_PASS_ART_PENDING / OWNER_VISUAL_PENDING. Cần chủ dự án/chủ sổ đối chiếu và đồng bộ đúng mức **preview approved**, không tự suy thành PvE/Final |
| POI07 | Xuyên Cốt Độc Châm Human R7 | Sprite mũi độc riêng, native Godot; [Hồ sơ](VFX_POI07_R7_PAINTED_REMAKE_20261115.md) | Ledger OWNER_VISUAL_APPROVED_R7, giữ nguyên |
| POI08 | Phệ Mạch Độc Thích Human R4 | Đầu độc thích phân biệt đầu rắn, native Godot; [Hồ sơ](VFX_POI08_R4_PAINTED_REMAKE_20261115.md) | OWNER_PROVISIONAL_CONTINUE, còn backlog polish |
| POI09 | Bách Độc Tán Châm Human R1 | 3 mũi kim tách rõ, bản đầu trùng góc; [Hồ sơ](VFX_POI09_BACH_DOC_TAN_CHAM_R1_20261115.md) | Ledger OWNER_VISUAL_APPROVED_R1 |
| POI10 | Độc Khí Phệ Tâm Human R2 | Chuyển từ bề mặt alpha đục sang dạng sóng/độc quang, dùng **badge nhiễm độc chung**; [Hồ sơ](VFX_POI10_R2_REMAKE_20261116.md) | OWNER_PROVISIONAL_CONTINUE, không coi demo badge là runtime status |
| POI11 | Vạn Độc Xuyên Tâm Human R9 | Nhiều target/độc quang, bản R7 native review kỹ; [R7 evidence](VFX_POI11_R7_NATIVE_REVIEW_20261116.md) | Ledger OWNER_VISUAL_APPROVED_R9; khóa art đã duyệt |
| POI12 | Tẩy Mạch Linh Dược Human R2 | **Canonical là DAMAGE một mục tiêu**, dù tên giống heal; có kiểm thử hướng projectile, art R2 còn yếu; [Hồ sơ](VFX_POI12_TAY_MACH_LINH_DUOC_R1.md) | Ledger OWNER_VISUAL_PENDING, art self **REWORK_REQUIRED**; tài liệu có nhắc owner cho phép “tiếp” về hướng bắn, **không** phải final duyệt |
| POI13 | Giải Độc Hộ Tâm Human R2 | Soft jade energy sau/trước đồng đội, bớt “lá dán”; [Hồ sơ](VFX_POI13_SOFT_ENERGY_R2_20261117.md) | OWNER_PROVISIONAL_ACCEPTED_NOT_FINAL, giữ source R2 |
| POI14 | Nghịch Độc Phản Chế Human R1B | Đường thanh lọc cyan-trắng + tạp chất tím được kéo ra; [Hồ sơ](VFX_POI14_NGHICH_DOC_PHAN_CHE_R1_20261117.md) | OWNER_PROVISIONAL_ACCEPTED_NOT_FINAL |
| POI15 | Hóa Độc Tán Human R1B | Độc AoE 3 mục tiêu, mark chung rõ hơn, duy trì/tan; [Hồ sơ](VFX_POI15_HOA_DOC_TAN_R1_20261117.md) | **OWNER_VISUAL_APPROVED_R1B** sau lời “đẹp, tôi thích”, khóa bản này |
| POI16 | Vạn Linh Giải Ách Human R2D | 3 lá dược, 3 đường truyền, 3 ấn; R1 quá mờ/vô nghĩa, sửa G3.6/G3.7; [Hồ sơ](VFX_POI16_SEMANTIC_R2_20261117.md) | OWNER_PROVISIONAL_ACCEPTED_R2D, backlog polish |
| POI17 | Yểm Ảnh Bộ Human R1 | 40 pose/4 atlas; bóng dư, vệt thân pháp, dấu bước; Godot [run #44043401378](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44043401378); [Hồ sơ](VFX_POI17_YEM_ANH_BO_R1_20261117.md) | Technical PASS; ledger OWNER_VISUAL_PENDING_R1_G37_SEMANTIC, user từng chấp nhận tạm ở chat; **chưa art final** |
| POI18 | Phụ Cốt Cổ · Tiên A R2C | R1B bị chê quá xấu/ghê, R2C chỉ mini movie 108 frame, native G3.5 tech PASS nhưng **self ART FAIL**, G5 chưa thực hiện; [Hồ sơ](VFX_POI18_PHU_COT_CO_TIENA_R2_20261117.md) | Ledger ghi OWNER_PROVISIONAL_ACCEPTED_R2C_G5_HOLD; **đây không phải full-G5/art final** |
| POI19 | Phụ Cốt Cổ · Tiên B R3 | 80 pose/6 atlas + Godot ADD per-frame; [run #44105241617](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44105241617), 510 frame/8,5s | Technical/G3.6 PASS, vẫn còn nét hoa phẳng và contact đơn giản; OWNER_VISUAL_PENDING |
| POI20 | Xà Ảnh Quấn Mạch · Tiên A R1C | 60 pose/5 atlas + two S-shaped serpents; [run #44135139429](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44135139429), 639 frame/10,65s | Technical/G3.6 PASS; cần chi tiết đầu xà, vật liệu tốt hơn; OWNER_VISUAL_PENDING |

**Ghi chú kiểm toán POI06:** riêng [POI06 R11 acceptance](VFX_POI06_R11_GODOT_NATIVE_ACCEPTANCE_20261114.md) ghi chủ dự án đã duyệt *preview* R11, còn dòng Cổ Độc ultimate trong [ledger](vfx_school_ledgers/01_poison_183.csv) ghi owner pending. Không tự diễn giải một trường thành sự kiện mới. Chat tổng hợp phải nêu cả hai và yêu cầu người quản lý ledger xác minh. Các quyết định “tạm” cũng không được tự nâng final.

## 4. BẰNG CHỨNG CHÍNH XÁC CỦA 4 MỐC GẦN NHẤT

| Mốc | Exact tested SHA / CI | Dữ liệu thật | Cổng còn mở |
|---|---|---|---|
| POI17 R1 | [#44043401378](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44043401378), SHA e58733f2bd2c63c03c063e416a6fa3b0724a3670 | 40 pose, 4 atlas, 108 frame/1,8s Godot, G3.6 PASS | Chủ duyệt semantic/ART; PvE, Android |
| POI18 R2C | [#44055755958](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44055755958), SHA 2313593cebf5aa9cff4f1cf03b1dfc7654620115 | 108 frame/1,8s **preflight only**; G3.5 TECH PASS, ART SELF FAIL | Full movie 6,5s mark G5 **NOT_EXECUTED**; mỹ thuật |
| POI19 R3 | [#44105241617](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44105241617), SHA 4a316afc28243f632e0c61b07ccb984dab2c310b | 80 pose/6 atlas, 510 frame/8,5s, t2.30/t5.10 mark sáng; G3.6 +499/+1274/+1666 | Nhận diện hoa, detail contact, owner art, runtime |
| POI20 R1C | [#44135139429](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44135139429), SHA 26f759a629adac63bffe07fa33f24ea967bab537 | 60 pose/5 atlas, 639 frame/10,65s, 8,5s demo sustain; G3.6 +304/+1578/+2993 | Đầu xà/vật liệu, owner art, runtime |

**Phân biệt nguồn SHA:** exact-SHA CI dùng commit nguồn được runner test; commit lưu atlas, ghi tài liệu hoặc report **sau** đó không có nghĩa toàn bộ game đã được test lại tại HEAD mới. Kiểm thử 60 FPS mã hóa trong MP4 **không phải** FPS vật lý Windows/Android.

## 5. BÀI HỌC NGOÀI ĐỘC TU (CÓ HỒ SƠ GỐC)

- **JX/Võ Lâm kỹ thuật ánh sáng**: [A/B JX1 source in Godot](JX_VLTK_VFX_IN_GAME_PREVIEW_R1_20261117.md). JX1 Võ Đang #158 10 frame precast, 17 cast, 8 impact; Ngũ Độc #63 chỉ 13 impact; Source VL kiếm có cast/hit riêng. [Run A/B #44113006743](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44113006743) tạo video thật 12s/720 frame, clip chia bốn đoạn. **Không chứng minh đường bay ngang là nguyên bản**: trial đầu đặt từ tay→mục tiêu là nội suy của LAB; sau owner phản hồi đã thử bố trí kiểu **giáng từ trên xuống**. Học **ngôn ngữ chiếu sáng**, KHÔNG copy pixel/asset thương mại vào skill gốc.
- **Màu Võ Đang #158:** lõi kiếm **trắng bạc gần trung tính**, phần thân trắng lạnh/lavender nhạt, halo **tím xám trong, mỏng**, tương phản trên nền tối. Tím than chủ yếu thuộc **background**, không phải bắt buộc làm toàn bộ sprite tím đặc. [Nghiên cứu màu trong báo cáo A/B](JX_VLTK_VFX_IN_GAME_PREVIEW_R1_20261117.md).
- **Hỏa Phù HF02 R6:** [owner 10/10](vfx_packets/HF02_R6_OWNER_APPROVAL_20261116.md), [preflight #43796504460](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43796504460), [movie #43796504489](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43796504489): ví dụ tốt **phù → tụ lực → bay → nổ**, có art-source và native evidence. Không lạm dụng sắc vàng/đỏ cho skill khác.
- **Phong Ấn Phù PAF01:** [R6 review](vfx_packets/PAF01_R6_ILLUSTRATED_WIND_SEAL_20261116.md). Luồng gió/ấn 風 bám quái ổn nhưng giấy phù bằng concept crop nhỏ quá dễ mờ và thiếu chất liệu; **vật thể nhận diện nhỏ cũng phải có master mỹ thuật đủ sắc nét**. [PAF05 R5E](vfx_packets/PAF05_R5E_OWNER_PROVISIONAL_CHARGE_DEBT_20261117.md) được chấp nhận tạm **nhưng tụ lực còn xấu**, phải giữ backlog.
- **Quyền Tu FIST12:** [postmortem R6](FIST12_R6_PROCESS_FAILURE_POSTMORTEM_20261117.md) làm rõ **crop poster/threshold alpha/offline MP4 không phải sprite và bằng chứng Godot**; dù kiểm tra alpha>0 cũng có thể chỉ 7 pixel hữu ích. [FIST12 R10C](VFX_FIST12_R10C_OWNER_PROVISIONAL_LOCK_AND_FIST14_START_20261117.md) chỉ CHẤP NHẬN TẠM, vẫn có quyền khí trông giống lửa. [FIST15 R2](VFX_FIST15_R2_WUDANG_LIGHT_REAL_NATIVE_QA_20261117.md) thử hình tượng quyền lực giáng từ trên, kiểm thử native chính thức nhưng phải tự phân biệt kỹ thuật và mỹ thuật.
- **Buff/hộ thể:** dùng **vòng sáng có chuyển động quanh thân** khi skill thật là guard/buff; không áp kiểu vòng trận cố định cho mọi skill. Không được kết luận “buff” khi catalogue là damage/poison.

## 6. CÁC NGUYÊN NHÂN THẤT BẠI ĐÃ LẶP LẠI

| Lỗi | Dấu hiệu đã xuất hiện | Chốt quy tắc sửa |
|---|---|---|
| **Sticker / poster / crop** | POI19 đầu nhìn như hoa dán; FIST12 R6 poster crop | Nguồn RGBA **tách lớp**, pose đổi hình thực, composite MIX trước/sau actor; hot glow ADD riêng và vẽ trong Godot |
| **Chiêu không có nghĩa** | POI16 R1 nhìn như vệt/vòng vô nghĩa; POI20 R1 vòng tròn | G3.7 cần silhouette “nguồn → hành trình → tác động → dấu kết quả” đọc được **không cần tên chiêu** |
| **Cả skill quá mờ** | POI16 R1B; POI19 bản duy trì quá nhỏ | G3.6 ảnh Godot thật 1× với ROI/chromatic brightness so idle, tách hot core/body/halo; không hạ ngưỡng để nhận PASS |
| **Tất cả là màu đặc** | Tím/đỏ neon đục, khối che mặt quái | Độ sáng theo tầng **core nhỏ sáng → body màu hệ phái → halo mỏng → rìa alpha0**; chỉ ADD lớp glow |
| **Sai quỹ đạo** | JX Võ Đang A/B đầu bị đặt bay ngang; kỹ năng giáng cần từ trên | Dựng quỹ đạo theo **canonical semantics**, không dùng một đường thẳng chung cho mọi cast |
| **Che nhân vật** | POI03 seal, POI16 stamp, POI19 cánh, các vòng POI20 | Tách BACK/FRONT, đặt mark trên đầu hoặc ngực, không che mặt; kiểm thử quái WALK + decoy |
| **Nhầm số mục tiêu và hiệu lực** | AoE 3 target dễ thành 4 dấu; poison mark giả | Lấy target_limit/shape từ catalogue; sự kiện LAB chỉ là **visual simulation**, không thật sự tạo DoT/HP/status |
| **Quay full khi art preflight chưa đạt** | POI18 R2C self FAIL dù tech PASS | G3.5 **HARD STOP**; art không đẹp thì sửa nguồn rồi mới quay G5, không thay bằng video offline |
| **Đếm video frames thành sprite** | 510/639 video frames không phải 510/639 pose | Ghi riêng pose/atlas, movie frames, thời gian, artifact, checksum, exact-SHA |
| **Bỏ qua quyền source** | JX/Võ Lâm đã có WebP trong repo | Internal comparison; **chưa chứng minh giấy phép public**; nguyên bản mới của game phải độc lập |

## 7. QUY TRÌNH THỐNG NHẤT CHO MỌI CHAT VFX — G0 → G8

**G0 — Canonical/HEAD.** Lấy PR #72 HEAD LIVE trước khi sửa; đọc AGENTS, skill Art Director, SOP, playbook trường phái, đúng catalogue và ledger. Đọc effect/element/shape/radius/range/target_limit/cast/duration/speed và các trường **không có**. Lập **ba đồng hồ**: combat-authority, clip VFX local, demo video. “Không biết receipt” => RUNTIME_MAPPING_PENDING.

**G1 — Reference + quyền nguồn.** Xem nguồn Võ Lâm/Kiếm Thế để học chất liệu, màu, nhịp, quỹ đạo; nêu phần quan sát và phần tự nội suy. Commercial assets chưa rõ phép phát hành => **KHÔNG copy/cắt vào sprite gốc**.

**G2 — Semantics/storyboard.** Một mô tả ngắn mà người chơi xem không HUD hiểu “skill làm gì”: ví dụ thân pháp = bóng dư/dấu chân, độc single-target = nguồn độc→mục tiêu→khóa→badge chung, buff = vòng hộ thể bám thân, giáng = từ cao xuống. Có charge/peak/contact/sustain/fade hoặc N/A hợp lý theo loại skill; passive/innate không tự tạo cast giả.

**G3 — Art First.** Master **isolated original RGBA đủ độ phân giải**, frame-by-frame có pose thật và source/prompt/code họa sĩ/bản quyền rõ. Master thân xà/phù/quyền phải tự có hình tượng đẹp; không dùng ảnh hoàn chỉnh kèm UI rồi xóa nền/crop coi là nguồn chuẩn. Không rig. Tách source: background ambience, body/hero, contact, status, fade. Ghi số atlas, cell px, trục/pivot/anchor, channel alpha.

**G3.5 — STOP thị giác sớm.** Render **thật trong Godot 4.7.2 GL Compatibility 1280×720** ba ảnh charge/peak/contact trên quái chuyển động ở 1×. Xem độ sắc nét/màu/vật thể, không che mặt, motion có hướng, đúng scope. **ART FAIL ⇒ dừng** và sửa chính skill, không gọi poster hay video offline là G3.5.

**G3.6 — Visibility kỹ thuật.** ROI màu/độ sáng riêng theo chiêu; so idle và expired trên native PNG. Kiểm tra nhỏ 1×; ảnh 1280×720 và chênh sáng PASS là **ngưỡng nhìn thấy tối thiểu**, không tự động đẹp.

**G3.7 — Nghĩa chiêu và phân lớp.** Che HUD/tên kỹ năng, xem người chơi có phân biệt heal/poison/attack/guard/mobility không; nguồn→đích/điểm chạm nhận rõ; quái/đồng đội không liên quan không nhận FX. Phân lớp: ambient/ground MIX → hero MIX + hot-core ADD cục bộ → actor WALK → foreground contact MIX/ADD nhỏ → status/fade. Tránh ring vô nghĩa và hard overlay.

**G4 — Motion + quyền game.** Native Godot test strict import/parse, focused test moving selected target, independent decoy, count/shape, target anchor/hit-distance, expiry, failure/negative cases. Không cho VFX sửa Combat V2/HP/SaveService/economy/AI. Không khẳng định projectile_speed world→pixel khi chưa có mapping.

**G5 — Movie đủ chu kỳ.** Sau G3.5 đạt mỹ thuật nội bộ mới quay full native movie, **>=12 checkpoint có ý nghĩa** kể cả onset, mid, contact, sustain, expire. MP4/PNG/art-source+SHA stored. 60 FPS mã hóa không chứng minh Android physical FPS. GIF chỉ khi owner yêu cầu riêng.

**G6 — Người duyệt.** Owner chốt riêng **REJECTED / PROVISIONAL_ACCEPTED (nợ polish) / VISUAL_APPROVED** tại **exact asset revision**. Không tự nâng chủ đề “tạm được” thành final. G3.7 semantic fail vẫn art fail dù CI xanh. Art đã duyệt phải khóa, không tự viết đè.

**G7 — Evidence/ledger.** School-specific V4 packet: validator packet→assets→evidence, sha256 đầu ra, actual native scene boot marker, focused result và exact-SHA GitHub Actions link; ledger updated theo owner decision đã có, ghi tồn tại nợ. Không sửa tên skill hoặc nâng tier từ cảm nhận.

**G8 — Runtime/thiết bị riêng.** Chỉ tích hợp PvE khi có ủy quyền, thực sự nối VFX với event receipt/status Combat V2. Kiểm thử 6v8, 30 đệ tử/40 quái, nền tối/sáng, Windows/Android vật lý, load/perf. **Đến hiện tại: PVE_HOLD / V63_OFF / PR72 DRAFT UNMERGED**, không tự tuyên bố release-ready.

## 8. STYLE GUIDE VFX ĐỀ XUẤT (CẦN THỐNG NHẤT TOÀN DỰ ÁN)

1. **Tính “sang” là phân bậc luminance/chroma, không phải nhiều màu:** hot core trắng ngà/ánh sáng gần trắng **diện tích nhỏ**, body có màu nguyên tố thuần, halo màu gần cùng họ **mỏng/bán trong suốt**, fade sạch. Được rút từ [JX1 Võ Đang](JX_VLTK_VFX_IN_GAME_PREVIEW_R1_20261117.md), không sao chép pixel.
2. **Màu nhận diện theo skill/nhánh**, không chuẩn hóa mọi hệ thành trắng tím. Màu nóng cho Hỏa, ngọc xanh cho độc/mộc khi phù hợp, tím-trắng cho lôi theo hồ sơ riêng, trắng bạc cho kiếm; cần đặc thù từng chiêu. Không tái dùng 5 vòng sáng đổi màu hàng loạt.
3. **Có đại motif dễ hiểu**: con rắn linh lực, phù giấy linh, cánh thuốc, mũi độc, quyền khí, cột sét, phong ấn... Nhưng motif phải nhẹ như ánh sáng, không biến thành sticker/animal gore hoặc icon UI.
4. **Tạo cảm giác “sống” bằng temporal flow**: sprite source có biến đổi thực + Godot theo frame/cubic spline/gradient trail; không dùng rung ngoằn ngoèo ngẫu nhiên. Luồng từ caster, rơi từ trên, va đập, bao quanh hay buff gắn actor phải **khác theo canonical skill**.
5. **Contact là điểm nhấn cục bộ ngắn** với ánh sáng thuần/độ đọc cao, không che người; sustain càng dài càng ít lóa, gắn correct target; fade sạch không phantom.
6. **Chuẩn trạng thái dùng chung khi cùng hiệu ứng**, tránh 36 nhánh tạo icon trùng nghĩa: POI10 đã tạo nền tảng [shared poison badge](VFX_POI10_R2_REMAKE_20261116.md); màu/motif skill riêng ở contact, nhưng badge cuối có thể cùng ngôn ngữ cho **poison đã được Combat V2 xác nhận**. Không tự đồng nhất tick/duration/stack giữa skill.
7. **Phân loại chất lượng theo nguồn thật**: code-painted sprite = first-party kỹ thuật hợp lệ nhưng không tự 4/5; concept poster đẹp ≠ alpha sprite; video offline ≠ Godot; CI PASS ≠ owner PASS.

## 9. BACKLOG CẦN CHỈNH VÀ QUYẾT ĐỊNH PHỐI HỢP

| Ưu tiên | Việc | Cách xử lý/owner |
|---|---|---|
| P0 | **Đồng bộ POI06 R11**: doc nói owner preview accepted; ledger nói pending | Kiểm chứng theo quyết định gốc và exact-SHA trước khi sửa ledger; không âm thầm nâng hạng |
| P0 | Không nhầm “20 POI” với “20 skill approved” | Kế toán family/skill ID, revision và 3 loại approval riêng |
| P1 | POI18 R2C còn G3.5 self-fail; thiếu G5 full clip dù ledger provisional | Giữ R2C không sửa nếu owner đã chọn tạm; ghi rõ nợ khi bàn giao |
| P1 | POI19 R3 và POI20 R1C đã Tech PASS nhưng art chi tiết hoa/đầu xà/impact 3/5 | Chỉ polish nếu owner yêu cầu; không tự ghi art final |
| P1 | POI12 R2 nguồn/đầu chiêu yếu; cần xác minh ledger so với owner cho phép hướng bắn đơn giản | Ưu tiên source master, không dựng nhiều pose 4 hướng khi một projectile xoay đúng đã đủ |
| P1 | PAF01 lá phù và PAF05 tụ lực; FIST12 quyền khí còn giống lửa | Giữ nợ và khóa những pha đã được duyệt; không phá version cũ |
| P1 | Chuẩn trạng thái debuff/buff/hoạt ảnh được chia sẻ toàn 12 trường phái | Thiết kế taxonomy, dùng status event thật, không giả receipt |
| P2 | Test sáng/tối, overlay crowd 6v8/30x40, Android/Windows vật lý | Cổng performance G8 riêng, chưa có |
| P2 | Rà soát giấy phép JX1/VL nếu định dùng trong release | Chỉ R&D nội bộ cho đến khi có giấy phép rõ |

## 10. HƯỚNG DẪN CHO CHAT TỔNG HỢP

**Ưu tiên nguồn theo thứ tự:**
1. Quyết định owner rõ ràng (nếu có hồ sơ exact revision), SOP hiện hành, catalogue canonical.
2. [Ledger Độc Tu 183](vfx_school_ledgers/01_poison_183.csv) và ledger của 11 hệ phái còn lại tại [docs/operations/vfx_school_ledgers](vfx_school_ledgers/); giữ nguyên khác biệt/độ trễ giữa hồ sơ và ledger.
3. Báo cáo skill chi tiết [POI11](VFX_POI11_R7_NATIVE_REVIEW_20261116.md), [POI15](VFX_POI15_HOA_DOC_TAN_R1_20261117.md), [POI17](VFX_POI17_YEM_ANH_BO_R1_20261117.md), [POI18](VFX_POI18_PHU_COT_CO_TIENA_R2_20261117.md), [POI19](VFX_POI19_PHU_COT_CO_TIENB_R3_20261117.md), [POI20](VFX_POI20_XA_ANH_R1_20261117.md), và các file POI01–POI16 trong mục 3.
4. Bằng chứng native workflow/asset artifact theo từng **exact SHA**, không lấy SHA commit docs sau này thay SHA đã test.
5. Tham khảo chéo [JX/Võ Lâm A/B](JX_VLTK_VFX_IN_GAME_PREVIEW_R1_20261117.md), [FIST12 postmortem](FIST12_R6_PROCESS_FAILURE_POSTMORTEM_20261117.md), [HF02 duyệt 10/10](vfx_packets/HF02_R6_OWNER_APPROVAL_20261116.md).

**Đầu ra mà chat tổng hợp nên có:** bảng 12 phái theo các trường `skill_id/family/tier/revision/source_sha/godot_run/technical_status/art_status/owner_decision/pve_status/perf_status/backlog`, một tiêu chuẩn chung G0–G8, danh mục source art được khóa, danh mục bất đồng hồ sơ cần xác minh, danh mục kỹ năng đang sản xuất. Không thêm “đã hoàn thành” nếu thiếu owner và PvE evidence.

---

### Quyết định trạng thái cuối báo cáo (as-of baseline 0960c07f)

- **ĐÃ TRIỂN KHAI:** source và Godot LAB cho nhiều kỹ năng Độc Tu, đặc biệt POI17–POI20.
- **BẰNG CHỨNG MẠNH:** POI19 R3 & POI20 R1C có movie full + V4/G3.6 exact-SHA.
- **CHƯA ĐƯỢC CHỨNG MINH:** mọi VFX đã đẹp cuối, mọi target/status chạy thật trong PvE, Android 60 FPS vật lý, 36 nhánh đồng bộ art.
- **GIỮ NGUYÊN:** PR #72 Draft, không merge; V6.3 OFF, gameplay authority và SaveService không đổi, không rig.
- **HÀNH ĐỘNG KẾ:** chat tổng hợp dùng báo cáo này + các ledger/packet khác, không ép user sao chép nội dung hội thoại; các bất đồng ledger cần được ghi nhận thay vì tự “sửa cho khớp”.

*Báo cáo soạn bằng cách đọc trực tiếp các file được dẫn và sổ kỹ năng tại GitHub HEAD nêu trên. Không chạy lại Godot cho commit báo cáo; mọi claim PASS chỉ áp dụng các workflow exact-SHA đã trích dẫn.*
