# TÔNG MÔN BÁ ĐẠO — HÀNH TRÌNH LÂM THANH: TUYỂN → NHÂN → TIÊN → THẦN
## Một Pháp tu Hỏa/Thủy/Mộc; học, trang bị, nâng lĩnh ngộ 5 bậc, thay Công Pháp, tiến hóa skill

**Ngày:** 2026-10-24
**Trạng thái:** DESIGN CASE STUDY ONLY / không code / không sửa PR29 hay UI / không merge. Số, ngưỡng và tên skill được dán nhãn.
**Source baseline:** main SHA 29b5fba448b0178cb520a4ada44b375b4b934e31; PR27 D7 deeae081bcfbe1413d4cf60a29db7e58150888b5; PR29 S1 9522812e91b7ca5bc0cc108eb92e000e930fe850 draft QA PENDING.
**Authority:** docs/GAME_SYSTEM_ARCHITECTURE.md, docs/COMBAT_SKILLS_V2_SPEC.md, docs/TECHNIQUE_V2_SPEC.md, docs/CULTIVATION_PATH_V2_SPEC.md, docs/SPIRITUAL_ROOT_V2_SPEC.md, docs/REALM_LADDER_V2_SPEC.md, docs/BODY_CULTIVATION_V2_SPEC.md, docs/DISCIPLE_MASTER_SCHEMA.md and owner D7 & reset decisions.

### Trạng thái thông tin — ĐỌC TRƯỚC KHI TRIỂN KHAI
- **[KHÓA V2]** = canonical thiết kế, chưa đồng nghĩa runtime PASS.
- **[SOURCE P2]** = đã khai báo trong code prototype, không đồng nghĩa gameplay V2 đầy đủ.
- **[ĐỀ XUẤT MINH HỌA]** = lựa chọn nội dung để hình dung Lâm Thanh; chưa được owner khóa, có thể thay mà không ảnh hưởng canonical.
- **[CODE CHƯA QA]** = có commit S1 PR29, Godot focused chưa chứng minh.
- **[CHƯA TRIỂN KHAI]** = phải code thật về sau, không được gọi là phần game hiện đã có.

# 0. Luật DEV SAVE và phạm vi minh họa
**[OWNER-LOCK]** Trong phát triển: khi thay bản gameplay/code, world/roster/dev save chơi thử được tạo lại, không cần chuyển dữ liệu đệ tử P2 cũ sang V2; I1 P2 save-migration tương thích nhân vật không còn là blocker. Không chạy xóa thư mục/user data trong phiên thiết kế này. **Trong cùng bản build vẫn phải đảm bảo Save/Load, offline, Warehouse, Injury 0/1/120, One Active Job, combat snapshot và reward exactly-once.** Khi đã phát hành thực tế, chính sách save sẽ phải được quyết định riêng.

# 1. Căn tính nhân vật — sự khác biệt giữa CÓ VÀ DÙNG
**Lâm Thanh**, ví dụ tưởng tượng nhất quán với hợp đồng thông số, KHÔNG phải nhân vật đã roll trong Godot.

| Thành phần | Lúc tuyển | Trạng thái thiết kế |
|---|---|---|
| Tu Vi/Luyện Thể | Phàm Nhân realm1 tầng1 / Phàm Thân realm1 tầng1 | [KHÓA V2] khởi đầu chuẩn |
| Tam Căn | Tư Chất126, Căn Cốt105, Tâm Tính96 | [ĐỀ XUẤT MINH HỌA], hợp lệ theo dải D7 |
| Tứ Tính | Tiềm Lực150, Thông Tuệ120, Cơ Duyên95, Mị Lực65 | [ĐỀ XUẤT MINH HỌA] |
| Linh căn birth | Hỏa78, Thủy46, Mộc34; thiếu Kim/Thổ; 0 perfected | [ĐỀ XUẤT MINH HỌA], tuân V2 purity1–100 |
| Thời điểm sinh | Chưa Định Đạo, chưa có công pháp/kỹ năng tự cấp; không có 4 active | [KHÓA V2] không sinh là đã thông thạo |
| Tư chất kỹ năng | Tu Vi thiên hướng Pháp/Hỏa; Thông Tuệ bonus học, Fire root bonus effect/mastery | [KHÓA V2] các bonus hợp lệ khi consumer triển khai |
| Đạo Lịch | chưa có; ghi lịch sử tu luyện sau các hoạt động thực | [KHÓA V2] không cộng miễn phí %ATK |

Các giá trị sau là kết quả nguồn tách biệt: Tư Chất126 +31.5% EXP Tu Vi tự nhiên; Căn Cốt105 +21% EXP Body tự nhiên; Tiềm Lực150 +7.5% RealmCore HP/ATK/DEF; Thông Tuệ120 có **định hướng +18% mastery XP** khi consumer V2 được cài; Hỏa78 matching skill +23.4%, matching skill-mastery +11.7%, Hỏa toàn-sát-thương +7.8%; Thủy46 speed+cast +3.68%, Mộc34 maxHP +4.08% **theo RootV2 spec**, không phải hiện trạng PR29. Không có "kỹ năng tự học" do có linh căn.

## 1.1 Bốn khái niệm riêng biệt
1. **Sở hữu bí tịch cấp tông môn**: truyền thừa đã vào Tàng Kinh Các; một lần lưu trữ cho phép nhiều người hợp lệ học, không tốn một cuốn mỗi người.
2. **Cá nhân biết skill/công pháp**: bản ghi learned riêng, có mastery XP riêng; biết không có nghĩa đang trang bị.
3. **Trang bị/đang dùng**: tối đa **1 Thường Kỹ + 4 Chủ Động + 6 Bị Động Chiến Đấu** khi trưởng thành; công pháp **1 Chủ Tu +2 Phụ Tu**. Không nhận toàn bộ ô khi mới tuyển.
4. **Cảnh giới/Chủ Đạo/Linh Căn**: yêu cầu và cách tính hiệu quả, **không phải skill slot, không phải free learn**.

# 2. HÀNH TRÌNH NHÂN GIỚI (Tu Vi realms 1–10)
Đây là chuỗi minh họa tiến trình **KHÔNG KHÓA ngưỡng mở ô**. V2 chỉ khóa rằng đầy đủ ô được mở dần vào cuối Nhân Giới. Các realm tên sử dụng thứ tự đúng từ DiscipleRealmProgressV2.

| Mốc Tu Vi thực | Tiếp nhận/nuôi dưỡng | Công Pháp đang kích hoạt | Kỹ năng biết/trang bị (ví dụ) |
|---|---|---|---|
| **R1 Phàm Nhân tầng1** | Tuyển Lâm Thanh; 3 căn; không Định Đạo; bắt đầu tu luyện/việc phù hợp | Chưa có | Không tự học Hỏa Cầu. Đánh thường tạm từ hệ combat pilot chỉ khi có luật starter riêng. |
| **R2 Luyện Khí** | Sect thu và lưu một công pháp Hỏa phổ thông; được dạy và Định Đạo **Pháp Tu** qua điều kiện thực | **Chủ Tu:** Xích Hỏa Dẫn Khí Quyết [TÊN ĐỀ XUẤT]. Không có Phụ Tu tự phát | **Thường Kỹ:** Linh Khí Đạn [ĐÃ CÓ TÊN TRONG V2 CATALOGUE, CHƯA RUNTIME]; **Chủ Động 1:** Hỏa Cầu [P2 CODE]. Ví dụ chỉ mở 1 ô active. |
| **R3 Trúc Cơ** | Học từ Kỹ Phổ/Y Đạo hợp lệ và đào tạo; nhận thêm 1 ô active, 1 combat passive khi điều kiện mở | Xích Hỏa Dẫn Khí Quyết Chủ Tu | **Active2:** Hồi Xuân Thuật [V2 CATALOGUE, NOT CODE]; **Passive1:** Pháp Thuẫn Tự Hộ [V2 CATALOGUE]. |
| **R4 Tử Phủ** | Học một phép Thủy sau khi có bí tịch, nếu phép không khóa branch; mở ô3 theo bộ luật *minh họa* | **Phụ Tu1:** Thủy Hành Ngưng Thần Pháp [TÊN ĐỀ XUẤT] | **Active3:** Hàn Sương Ấn [P2]. Biết được skill Hỏa/Thủy không bắt buộc có đủ hai hệ, nhưng sở hữu đúng căn sẽ hỗ trợ hiệu quả. |
| **R6 Nguyên Anh** | Săn Elite, nhận mảnh/hoàn thành công pháp dưỡng nguyên; mở một passive theo content | **Phụ Tu2:** Thanh Mộc Dưỡng Nguyên Kinh [TÊN ĐỀ XUẤT] | **Passive2:** Ngũ Hành Tương Sinh [V2 CATALOGUE], khi có authored element-chain và trigger hợp lệ. |
| **R8 Luyện Hư** | Qua boss/skill manual hợp lệ học Liệt Diễm; mở active4 [CHỈ MỐC GỢI Ý], không quy đổi trực tiếp legacy P2 min_stage9 | 1 Chủ Tu +2 Phụ Tu như trên | **Active4:** Liệt Diễm [P2 CODE definition; chưa có S2 consumer]; đủ 4 active trong ví dụ. |
| **R10 Đại Thừa** | Hoàn thiện các ô chiến đấu đến CAP Nhân Giới; hoàn thành các mốc mastery phù hợp, chuẩn bị hậu duệ Tiên; không auto tặng skill | Ba công pháp có thể luyện mastery riêng; inactive learned giữ kiến thức | **1 basic+4 active + tới6 passive slot mở**, nhưng nếu chưa tìm đủ bí tịch thì các ô vẫn trống; xem bảng passive sau. |

**Lưu ý khởi đầu bắt buộc được thiết kế thêm:** tân tuyển phải có một **Thường Kỹ tối thiểu để đánh quái hợp lệ** trước khi học phép từ Tàng Kinh Các. V2 cho phép starter Thường Kỹ phân theo style/path; nguồn cấp/chuyển Thường Kỹ từ generic P2 vào V2 cần packet nội dung, không được mặc định "tự học 11 skill khi sinh".

## 2.1 Hỏa Cầu: ví dụ 5 bậc lĩnh ngộ KHÔNG giống tiến hóa
**Khóa V2:** mỗi skill có 5 mức **Sơ Học → Nhập Môn → Tiểu Thành → Đại Thành → Viên Mãn**; XP liên tục và có ngưỡng realm/Body/điều kiện kỹ thuật. Không có một công thức global +5% damage/milestone.

| Bậc của Hỏa Cầu | Người chơi thực sự làm | Thành quả *đề xuất minh họa*; chưa có hệ số khóa |
|---|---|---|
| 1. Sơ Học | Học cuốn kỹ năng thật; mặc định skill gốc đã định nghĩa | P2 Hỏa Cầu **1.15 ATK**, tầm7.5, cast0.65s, cooldown3.8s, burn0.16 ATK/tick trong3.2s [SOURCE P2; S1 CODE QA PENDING]. |
| 2. Nhập Môn | Tích XP từ sát thương thật / DoT thật, Diễn Võ hợp lệ; trả điều kiện tiến bậc nếu được yêu cầu | Tăng hiệu suất một thành phần skill do tác giả quy định (ví dụ tỷ lệ damage), **chưa chốt %**. |
| 3. Tiểu Thành | Vẫn chiến đấu có mục tiêu/thực hành có nguồn | Có thể tăng hiệu suất đốt hoặc cải thiện một thuộc tính root-scalable; không mặc định thêm mục tiêu. |
| 4. Đại Thành | Yêu cầu kỹ thuật/cảnh giới cao hơn theo nội dung | Có thể mở một điều kiện phối hợp mới hoặc tăng magnitude; chưa chốt ngưỡng/cost. |
| 5. Viên Mãn | Có XP và gate hợp lệ | Đạt kỹ năng Nhân Giới thành thạo; có thể đáp ứng **một điều kiện** học hậu duệ Tiên nếu skill family yêu cầu. Không tự hóa thành Tiên Kỹ. |

**Ví dụ thử nghiệm XP minh họa, KHÔNG phải thông số gameplay đã khóa:** các mốc tích lũy 0/100/300/700/1500 valid mastery XP để hiểu thanh tiến độ. Giả sử Lâm Thanh được 500XP và đủ điều kiện bậc3: đang Tiểu Thành, tiến độ200/400 tới Đại Thành; nếu thiếu realm gate thì XP được lưu nhưng không tự vượt. Các con số này chỉ để hướng dẫn UI/bảng nội dung sau; không lập hardcoded mastery curve từ đây.

**EXP bậc không phải Tu Vi:** kỹ năng chỉ nhận khi hiệu quả có giá trị (đánh quái có ý nghĩa, hồi máu thật, shield hấp thụ thật, buff hỗ trợ thật). Không tặng Tu Vi XP giả mỗi kill, không cày mastery bằng spam Hỏa Cầu lên quái bất tử hoặc overheal. Thông Tuệ120 +18% và Hỏa78 matching mastery +11.7% có thể cùng vào **kênh XP cộng tuyến tính** thành x1.297, không tự nhân thành x1.31806. Consumer học này chưa code.

## 2.2 Bộ skill Lâm Thanh cuối Nhân Giới — 1/4/6
Bộ gợi ý theo hướng **Ngũ Hành Pháp tu, có hỗ trợ Y Đạo nếu điều kiện học cho phép**. Việc học chéo nhánh là có thể theo content requirement, KHÔNG mặc định tự do học mọi chiêu.

**Thường Kỹ (1 ô):** Linh Khí Đạn — neutral ranged [catalogue, chưa code].

**Chủ Động (4 ô, auto theo thứ tự 1→4 [KHÓA V2]):**
1. **Hồi Xuân Thuật** — heal đồng đội thật sự thấp HP; không overheal [catalogue, chưa code]; nếu không đủ điều kiện học Y Đạo, thay bằng **Linh Bạo Thuật** (AoE [catalogue]) và chuyển thành build sát thương thuần.
2. **Hỏa Cầu** — đánh đơn + Burn; per-skill condition đề xuất chỉ refresh khi Burn gần hết hoặc không có, không cast-spam.
3. **Liệt Diễm** — damage khi có Burn được x1.35 bonus tại **impact**; nếu thiếu Burn, nguồn P2 vẫn có damage cơ bản, việc AI chỉ dùng combo khi Burn có là **điều kiện được đề xuất**, chưa khóa; hiện S2 chưa code.
4. **Hàn Sương Ấn** — gây suy yếu đúng bối cảnh [S1 CODE QA PENDING]; có thể đổi ở khu săn cần buff tổ đội sang **Linh Quang Gia Trì** (catalogue, chưa code).

**Các kỹ năng BIẾT nhưng không trang bị:** Linh Bạo Thuật, Linh Quang Gia Trì hoặc các bí tịch khác thật sự đã học (không được dùng trong combat cho đến khi trang bị vào loadout). Thứ tự là do người chơi/policy chọn **ngoài trận**, không phải AI dùng tất cả.

**Bị Động (6 ô giới hạn trưởng thành):**
| Ô | Ví dụ trang bị | Loại | Nguồn và điều kiện |
|---|---|---|---|
| P1 | Pháp Thuẫn Tự Hộ | trigger | [V2 catalog] chỉ kích hoạt nếu HP thực sự thấp và skill learned; anti-spam ICD |
| P2 | Ngũ Hành Tương Sinh | trigger | [V2 catalog] personal authored elemental chain, **không** nhân sát thương miễn phí mỗi lần đổi hành |
| P3 | Diệu Thủ Hồi Xuân | trigger | [V2 catalog] chỉ có giá trị khi có hồi máu hiệu quả; build Pháp thuần thiếu Heal không kích hoạt |
| P4 | Linh Quang Dư Âm | trigger | [V2 catalog] cần một nguồn party buff hợp lệ; nếu không đang trang bị hoặc có team buff source thì để trống/chọn khác |
| P5 | Y Tâm Đồng Hành | trigger | [V2 catalog] yêu cầu tình huống cứu đồng đội và điều kiện học; không tự xuất hiện khi có heal |
| P6 | (trống ở Nhân Giới) → **Hỏa Chủng Dư Uy** | trigger [TÊN MỚI ĐỀ XUẤT] | Chỉ học/trang bị sau content bổ sung; ví dụ một proc bổ trợ Burn có ICD và chống recursion, **chưa có ratio** |

**Quan trọng:** có sáu Ô không có nghĩa phải có đủ sáu passive ngay; build chưa sở hữu nguồn buff/hồi thì nên để ô trống, không giả một proc đang hoạt động. Nội tại tĩnh **Pháp Mạch Thông Suốt, Tĩnh Tâm Thủ Nhất, Ngũ Hành Tương Hợp** là những *ứng viên V2* ở kênh tự thân, không chiếm slot nếu đúng chỉ cộng stat self-only.

# 3. Hành trình TIÊN GIỚI (R11–R20): hậu duệ thật, không phải +17 cấp
**Khóa V2:** hậu duệ là skill/technique có identity/tên riêng, có thể nối family/nhánh; predecessor/mastery lịch sử giữ lại; trang bị một successor độc quyền per family nếu thay thế, không cộng effect Nhân+Tiên.

| Mốc | Quyết định người chơi | Bộ skill/technique tác động | Nhãn |
|---|---|---|---|
| **R11 Nhân Tiên** | Có quyền săn khu Tiên sau khi đủ thực lực; lấy skill manual Tiên family | 4 ô active và6 ô passive **không tự tăng** lên5/8; Nhân skill vẫn hữu dụng | [KHÓA V2] |
| **R13 Thiên Tiên** | Hoàn thành thư tịch, công pháp Hỏa lên Đại Thành (nếu yêu cầu), Đạo Lịch hợp lệ | Học **Xích Diễm Liên Châu** [TÊN HẬU DUỆ ĐỀ XUẤT] thay Hỏa Cầu ở active2, tác dụng có thể bắn nhiều đạn/target cap authored | [ĐỀ XUẤT] |
| **R15 Huyền Tiên** | Đổi Chủ Tu ngoài chiến đấu | Xích Hỏa Dẫn Khí Quyết (đã học, mastery vẫn lưu) → **Cửu Diệu Hỏa Tâm Kinh** [HẬU DUỆ CÔNG PHÁP ĐỀ XUẤT]. Không cho cả hai cùng tính main-effect trong conflict group | [ĐỀ XUẤT] |
| **R18 Đại La Kim Tiên** | Mở chiêu Tiên family khác sau skill/mastery/loot hợp lệ | Liệt Diễm → **Cửu Diễm Thiên Hỏa** [TÊN HẬU DUỆ ĐỀ XUẤT]; nếu thuộc exclusive same family, chỉ 1 bản trang bị; có thể mở kỹ thuật vùng với max_targets hữu hạn | [ĐỀ XUẤT] |
| **R20 Tiên Đế** | Hoàn tất các bậc mastery Tiên theo người học; lựa chọn build DPS hoặc support | Có thể giữ Hồi Xuân/Thủy cho utility; không phải slot nào cũng tiến hóa để lên Tiên | [KHÓA V2 + ĐỀ XUẤT] |

**Chuyển Công Pháp cần hiểu:** Lâm Thanh BIẾT cả Xích Hỏa Dẫn Khí Quyết và Cửu Diệu Hỏa Tâm Kinh, nhưng chỉ một được bật ở ô Chủ Tu. Công pháp không tự dạy Xích Diễm Liên Châu; cần kỹ năng/truyền thừa riêng trừ nội dung có explicit relationship. Phụ Tu Thủy/Mộc được giữ nếu còn hợp lệ, hiệu ứng không duplicate theo uniqueness tag.

**Tình huống lựa chọn:** Nếu Boss kháng Hỏa cao, Lâm Thanh có thể đổi active slot2/3 sang phép Thủy hoặc hồi máu được học trước khi vào trận. Hỏa100 linh căn vẫn tồn tại; không mất learned mastery khi đổi build, nhưng hiệu quả skill vẫn dựa theo tag thật. Không tự tặng "Hỏa khắc tất cả" hoặc sửa HP Boss động.

# 4. Hành trình THẦN GIỚI (R21–R30): thay luật có giới hạn
**Khóa V2:** Thần skill có thể bổ sung luật cao hơn một cách **hữu hạn, đọc được, chống proc vô tận**. Không phải tất cả skill từ Nhân cần phiên bản Thần ngay khi chạm R21.

| Mốc | Đường phát triển minh họa | Giới hạn an toàn |
|---|---|---|
| **R21 Thần Nhân** | Tiếp cận Bí Cảnh/skill fragments Thần có điều kiện; vẫn dùng kỹ năng Tiên nếu chưa đủ truyền thừa | Không miễn phí sở hữu khi lên cảnh giới |
| **R24 Thần Quân** | Dòng Hỏa Cầu: Xích Diễm Liên Châu → **Thái Sơ Diễm Tinh** [TÊN THẦN HẬU DUỆ ĐỀ XUẤT] | Có thể tạo một đợt lửa có target cap/ICD, **không đánh toàn map**, không lan vô hạn |
| **R26 Thần Hoàng** | Chủ Tu Cửu Diệu Hỏa Tâm Kinh → **Thái Sơ Diễm Pháp** [TÊN ĐỀ XUẤT]; Tiên công pháp cũ học được nhưng không chạy cùng nguồn active | Không cộng chồng 3 đời technique passive |
| **R28 Bất Diệt Thần Thể (Body track)** | Đây là **Body realm28**, không phải Tu Vi R28; nếu Lâm Thanh đạt, mở hybrid/guard theo content riêng | Không ép mọi Pháp tu phải có Body R28, không nhầm hai track |
| **R30 Sáng Thế Chủ** | Lâm Thanh có 1+4+6 loadout trưởng thành, các họ chủ lực có thể là hậu duệ Thần theo điều kiện | Thần skill không bỏ qua mọi kháng, không hồi sinh vô hạn, không reset CD đệ tử vô hạn |

**Ví dụ bốn ô active cuối game (minh họa, không tác giả hóa số):**
1. **Thanh Mộc Hồi Thiên** (Tiên hậu duệ Hồi Xuân, [TÊN ĐỀ XUẤT]); chưa bắt buộc tiến hóa đến Thần.
2. **Thái Sơ Diễm Tinh** (Thần hậu duệ Hỏa Cầu).
3. **Đại Nhật Thần Viêm** (Thần hậu duệ nhánh Liệt Diễm, [TÊN ĐỀ XUẤT]).
4. **Hàn Sương Ấn** hoặc bản Thủy cao hơn nếu thực sự học được; một chiêu Nhân có giá trị utility vẫn có thể giữ ở Thần.
**Bị động:** tối đa 6 đã mở trong Nhân, nội dung có thể thay P1–P5 bằng hậu duệ tiến hóa khi học được; P6 Hỏa Chủng Dư Uy là [ỨNG VIÊN MỚI], không tự tồn tại nếu chưa có truyền thừa. Không thêm ô thứ7–8 vì lên Thần.

## 4.1 Một skill xưa → ba thế hệ: timeline dễ hiểu
| Họ | Nhân (1–10) | Tiên (11–20) | Thần (21–30) | Ý nghĩa |
|---|---|---|---|---|
| Hỏa Cầu | Hỏa Cầu [SOURCE P2] | Xích Diễm Liên Châu [NEW NAME] | Thái Sơ Diễm Tinh [NEW NAME] | đơn DoT → đa đạn/nguồn vùng hợp lệ → hữu hạn áp lực vùng/quy tắc Hỏa |
| Liệt Diễm | Liệt Diễm [SOURCE P2] | Cửu Diễm Thiên Hỏa [NEW NAME] | Đại Nhật Thần Viêm [NEW NAME] | payoff Burn đơn→ mở AoE được định nghĩa → tương tác Hỏa có giới hạn |
| Hồi Xuân | Hồi Xuân Thuật [V2 catalog only] | Thanh Mộc Hồi Thiên [NEW NAME] | Sinh Cơ Bất Tuyệt [NEW NAME] | hồi một người → cứu được nhiều người trong cap → cứu nguy có ICD (không revive vô hạn) |
| Công pháp Hỏa | Xích Hỏa Dẫn Khí Quyết [NEW] | Cửu Diệu Hỏa Tâm Kinh [NEW] | Thái Sơ Diễm Pháp [NEW] | thay *Chủ Tu* duy nhất theo family; lưu lịch sử |

Các tên hậu duệ/công pháp ở bảng này **chỉ là nội dung tác giả đề xuất, chưa được owner phê chuẩn, không tồn tại trong code**. Đừng nhầm với tài liệu V2 đã khóa tên/thông số một số skill Nhân.

# 5. Đệ tử học Công Pháp và Kỹ Năng kiểu gì? Hai hồ sơ độc lập

**Nhận sách:** quái normal/elite/boss/Bí Cảnh/shop/event có source thật → Warehouse receipt duy nhất, ghép mảnh/nấu/chế tạo nếu đúng recipe → bản kỹ năng và công pháp lưu truyền thừa tại Tàng Kinh Các. Đệ tử học thì trả Contribution/Spirit Stone/time/requirements theo source; một Sect copy dạy được nhiều người. Người tự ngộ có thể Khắc Lục cho tông môn.

**Sổ Lâm Thanh phải có:**
- **Learned techniques:** id, family_id, five mastery stage+XP, source/teaching, predecessor history; **active 1 main +2 supports**.
- **Learned skills:** id, family_id, five mastery stage+XP, learned/eligibility, provenance; **1 basic+4 active+6 passive combat**.
- **V2 Tu Vi/Body:** independent coordinates; **Chủ Đạo active** Pháp/Ngũ Hành plus Đạo Lịch; actual root born/current; D7 7-point birth/current.
- **Combat snapshot:** actor_id, active casts+cooldowns/status/target/proc ledger. In build save/load exact once; new DEV build gets fresh world instead of P2 backwards migration.

**Character action constraints:** chỉ học/phát triển qua time/jobs hợp lệ, không simultaneous hunt+train in One Active Job; không tạo mastery XP từ đòn hụt, heal đầy máu, shield chẳng hấp thụ. Skill không có "cấp lớp nhân vật" chung. Cấp của công pháp khác bậc học skill khác độ hiếm bí tịch.

# 6. Source audit: điều gì ĐÃ CÓ, điều gì chưa
| Nội dung | Nguồn thật | Tình trạng |
|---|---|---|
| 30 Tu Vi ×10 +30 Luyện Thể×10 | DiscipleRealmProgressV2 | V2 progression foundation code hiện có |
| D7 Tam Căn/Tứ Tính | PR27 | Code & QA được báo trên PR27, không phải skill XP5 |
| 9 skill P2 3 Kiếm/3 Thể/3 Pháp | CombatSkillSystem.SKILLS | 9 khai báo; 2 learned direct hoạt động; 5 status S1 code pending QA; 2 dash/combo deferred |
| skill learned bool, no skill level | DiscipleState.learned_combat_skills | Có cấu trúc cũ, chưa có XP/milestones V2 |
| 1+4+6 skill loadout + 1+2 technique | canonical V2 specs | DESIGN LOCKED, **chưa code hoàn chỉnh** |
| Công Pháp Chủ/Phụ, Tàng Kinh Các, mastery | Technique V2 spec | DESIGN LOCKED, **chưa code V2** |
| linh căn riêng P1..100, R0–5, matching | Spiritual Root V2 spec | DESIGN LOCKED, **chưa code V2** |
| Tiên/Thần skill successor lineage | Combat Skills V2 spec | DESIGN LOCKED, **chưa code** |
| Tên bốn phép mới/6 passive role, xp thresholds, slot realm examples | case study này | [PROPOSED], không tạo gameplay runtime |

# 7. Thiết kế tiếp theo — ít kiểm toán lặp, tăng code có thể chơi
**Bước nhỏ 1 (chỉ docs hiện tại):** chốt một bộ đề xuất skill Pháp tông tập trung 1 basic + 4 active + 6 passive, với điều kiện học/sử dụng/milestones/lineage, và các ô chưa có nội dung chính thức để owner quyết định.

**Bước nhỏ 2 (sau Codex S1 QA PASS và owner CODE packet):** Combat S2 dash+fire combo, V2 AI slot priority; không xây hàng trăm skill chưa có engine typed consumer. DEV new world/dev roster on code changes; trong mỗi code SHA save/load integrity vẫn bắt buộc.

**Bước nhỏ 3:** 3-path playable slice mỗi hướng 1 basic + 2 active + 1 useful passive; thật sự có bí tịch, học, dùng skill. Sau đó thêm archive, 5 mastery, 1 main+2 supports, root per-element; từng gói targeted QA + one complete source receipt. Không làm microbalance toàn bộ Boss ×100 trước content.

**S1 QA pending:** không tự merge PR29, không sửa UI/Source A/godot runtime từ tài liệu này. Không claim simulation logs/godot PASS.

# 8. Owner options (future)
**A:** duyệt skeleton bộ Pháp tu Lâm Thanh, yêu cầu tác giả hóa catalogue 1 basic/4 active/6 passive (tên, nguồn sách, effect/gate/CD/max target, mastery milestones) với ngưỡng số minh họa tách khỏi canonical.
**B:** trình bày cùng hành trình cho Kiếm Tu và Thể Tu so sánh chiến đấu/nâng cấp, dùng lại 1+4+6.
**C:** chuẩn bị S2/S3 CODE packets + DEV fresh-world gate cho Codex sau khi S1 QA chứng minh, không tự code hoặc đụng UI.
