# KIẾN TRÚC GỐC ĐỆ TỬ V2 — MỘT CON NGƯỜI, MỘT VÒNG ĐỜI, MỘT NGUỒN SỰ THẬT

Ngày: 2026-10-09

**Trạng thái: PHẦN NỀN TẢNG ĐÃ KHÓA theo các spec hiện hành; các lựa chọn kỹ thuật/nội dung chưa được chốt ghi riêng là ĐỀ XUẤT — CHỜ DUYỆT. CHƯA TRIỂN KHAI CODE V2.**

Nguồn thẩm quyền:
- `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`;
- `docs/DISCIPLE_MASTER_SCHEMA.md` — hợp đồng bẩm sinh và vòng đời;
- `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md` — lớp trạng thái và thuộc tính;
- `docs/DISCIPLE_V2_CHARACTER_IMPLEMENTATION_PLAN.md` — thứ tự triển khai;
- `docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md` — Lục Duy và Dẫn Tiên đang hoạt động;
- các spec V2 chuyên ngành đã khóa.

Tài liệu này KHÔNG ghi đè công thức và tỷ lệ của spec chuyên ngành. Nếu có mâu thuẫn, quyết định người dùng mới nhất / quy tắc thẩm quyền trong `AGENTS.md` được ưu tiên.

## 1. Mục tiêu gốc và phạm vi

Một đệ tử là **một thực thể xuyên suốt** từ ứng viên → tuyển dụng → lao động/tu luyện/chiến đấu → phát triển → biến cố → hậu quả/lịch sử → hành động tiếp theo. Không ghép nhiều nhân vật từ nhiều lượt random; không lấy nhãn Phẩm Chất, Chiến Lực hoặc ngoại hình làm nguồn sự thật thay cho hồ sơ.

Các phần đã có và phải tái sử dụng: mô phỏng thời gian và RNG; Dẫn Tiên Đài + Lục Duy P3.7C1; `CandidateState`, `DiscipleState`, `SimulationState`, `SectState`; bộ lịch/lệnh làm việc; hệ khu vực/công trình/kho; đường lưu/tải; quyết định/AI; combat cũ để tương thích.

**Không thuộc đợt khóa gốc:** tác giả hóa 101 Đặc Chất và trọng số cụ thể; trọng số từng Mệnh Cách; toàn bộ chiến đấu V2, vũ khí, phụ thuộc Kiếm Cốt; công thức HP/ATK/DEF tăng theo 300 tầng; các chu kỳ xã hội/Ngự Thiện Phòng; nghề mới. Những phần này không được tự điền bằng buff Chiến Lực giả.

## 2. Bảy lớp của một nhân vật (KẾ THỪA THIẾT KẾ ĐÃ KHÓA)

| Lớp | Dữ liệu | Đặc tính/thẩm quyền |
|---|---|---|
| 1. Danh tính và bẩm sinh | ID, seed, nguồn tuyển, thứ tự sinh, tên gốc, giới tính/chủng tộc/xuất thân, birth snapshots Lục Duy; identity/purity/số hệ/đặc điểm ẩn | Sinh đúng một lần; giữ seed/provenance; rename không đổi ID; hidden identity tồn tại trước reveal |
| 2. Phát triển và biến đổi lâu dài | Lục Duy hiện tại, Linh Căn hiện tại, Dị Căn, Huyết Mạch/Thể Chất/Mệnh Cách/Trait hiện có, Tu Vi/Luyện Thể | Tách giá trị sinh và giá trị hiện tại; chỉ hệ chuyên ngành được sửa; không hard-cap nuôi đệ tử |
| 3. Kiến thức và kỹ năng tích lũy | Công Pháp đã học/mastery/loadout, Kiếm/Thể/Pháp + Đạo Lịch, kỹ năng chiến đấu, nghề và XP | Tiến trình học riêng với bẩm sinh; không reset khi đổi nhóm, đổi Chủ Đạo hoặc chuyển công pháp trừ quy tắc đã khóa |
| 4. Trạng thái hiện sống | HP hiện tại, Thể Lực Viễn Chinh, vị trí, hành động, chấn thương/tâm trạng/trung thành khi có authority, hiệu ứng thời hạn | Biến đổi theo thời gian/hành động; không sửa birth/current permanent Lục Duy để thể hiện thương tích |
| 5. Tổ chức, điều khiển | Chức vụ, nhóm lao động, đội/tổ chiến đấu, công việc, chính sách tông môn, lệnh trực tiếp | Tông môn/người chơi ra chính sách/lệnh; AI hợp lệ quyết định thực hiện; không thuộc Trait birth |
| 6. Lịch sử đời người | Sự kiện tuyển dụng, đột phá, trận đánh, thành tựu, reveal, thay đổi hậu thiên, quan hệ | Ghi lịch sử có nguồn/thời điểm, đủ để đánh giá Mệnh/Trait được mở về sau; không quay lại quá khứ giả |
| 7. Đầu ra tính toán | Phẩm Chất, HP tối đa, Công/Thủ, tốc độ, hiệu quả nghề, kỹ năng, các đánh giá phù hợp | **Derived, không roll birth độc lập, không lưu thành một nguồn chỉ số song song**; phải truy nguyên được từng nguồn |

Ranh giới bắt buộc: Personality khác Trait; thiên phú nghề khác XP nghề; Luyện Thể khác Thể Chất; Thể Lực V2 chỉ tiêu thụ khi viễn chinh ngoài bản đồ; Công Pháp khác kỹ năng; Phẩm Chất Đệ tử chỉ suy ra từ Lục Duy hiện tại.

## 3. Một người — một nơi sở hữu dữ liệu (QUY TẮC ĐÃ KHÓA; BỐ TRÍ CODE LÀ ĐỀ XUẤT)

| Dữ liệu | Chủ sở hữu logic | Vị trí code hiện có / hướng triển khai |
|---|---|---|
| World seed, tick, RNG state, danh sách đệ tử/ứng viên | `SimulationState` và simulation scheduler | Duy trì; không tạo world/tick V2 thứ hai |
| Identity và trạng thái cá nhân đang sống | Một hồ sơ theo character ID, hiện là `CandidateState` → `DiscipleState` | **Đề xuất:** các nhánh hồ sơ V2 versioned được lưu/clone cùng nhân vật; ứng viên chuyển thành đệ tử mà không khởi tạo lại |
| Danh tính bẩm sinh và birth snapshot của từng chuyên ngành | Chủ sở hữu V2 của chuyên ngành, truy cập qua một identity/profile canonical của đúng ID | Không tồn tại hai bản Truth khác nhau ở `DiscipleState` và các dictionary legacy `SectState` |
| Chính sách, tài nguyên, công trình, warehouse | Authority tông môn hiện hành | Giữ `SectState`/`BuildingState`/warehouse canonical; nhân vật không tạo kho phụ |
| Quan hệ giữa người và người, đội/tổ, sự kiện toàn tông | `SimulationState`/subsystem quan hệ/tổ chức | Trỏ về ID ổn định; không duplicate hồ sơ đệ tử đầy đủ vào quan hệ |
| Nội dung tĩnh | Registry / definitions chuyên ngành | Chỉ lưu ID + trạng thái/phát triển/provenance vào save, không lưu lại toàn bộ thông số hiệu ứng như truth |
| Modifier đầu ra/UI | Một pipeline tính toán V2 | Có breakdown; không lưu `combat_power` legacy như sức mạnh chính thức V2 |

**Đề xuất cấu trúc lưu (chưa khóa chi tiết field/path):** một versioned character profile chứa `identity`, `birth`, `permanent`, `learned`, `living`, `organization`, `significant_history`; chuyên ngành được định danh và có marker `initialized`. Có thể biểu diễn bằng các typed subprofiles thay vì một Dictionary khổng lồ. Tiêu chí bắt buộc là **một owner cho mỗi field**, không phải tên class/file cụ thể.

## 4. Sinh → ứng viên → đệ tử (KẾ THỪA ĐÃ KHÓA)

`world seed + recruitment source + generation index` → một nhân vật duy nhất. Tạo từ Dẫn Tiên, Chiêu Mộ Lệnh hoặc nguồn tuyển đã định nghĩa. Giữ toàn bộ tỷ lệ Phẩm Chất, giới hạn ngày, cơ chế Main Guide và assistant của P3.7C1.

Quy trình:
1. Cấp danh tính, `profile_seed`, generation index, nguồn tuyển; lấy tên, giới tính, chủng tộc/xuất thân.
2. Sinh bộ **Lục Duy P3.7C1** đúng authority hiện có; chụp snapshot; suy ra Phẩm Chất (không random Phẩm Chất độc lập như nguồn sức mạnh).
3. Sinh personality 6 kiểu và risk/spend/survival bias đã có; không tự thêm chỉ số tính cách mới.
4. Sinh Linh Căn / Dị Linh Căn, thiên phú nghề, Trait hiện/ẩn, Huyết Mạch, Thể Chất, Mệnh Cách theo các bảng canonical **chỉ khi danh mục đủ điều kiện và trọng số chi tiết đã được duyệt**.
5. Ảnh hưởng bẩm sinh đặc biệt (nếu đã có spec `birth_override` hoàn chỉnh) phải giải quyết **trước khi chốt birth snapshot**; không được override nửa vời hoặc tạo quà giả.
6. Sinh tuổi, thọ mệnh gốc và cảnh giới/tiến độ khởi đầu theo nguồn authority hợp lệ; DV2-01 tạm dùng compatible starting realm hiện hành, không tự nghĩ tỷ lệ phân bố 300 tầng.
7. Lưu toàn bộ hồ sơ của ứng viên trước khi hiển thị. Accept chuyển nguyên hồ sơ và trạng thái ẩn; reject chỉ loại ứng viên và dữ liệu thuộc về ứng viên đó.
8. Tiết lộ/phát hiện/kích hoạt **không quay lại danh tính**; `initialized: true` + `none` là hợp lệ, khác `not_initialized`.

**RNG ràng buộc:** các nguồn random được phân vùng tên ổn định theo (world seed, source, index, domain); thêm lượt quay Trait hay Bloodline không thay đổi Lục Duy/quality/Dẫn Tiên đã chốt. Phần thuật toán hash/seed và encoding chính xác là vấn đề triển khai cần test, không tạo nhiều RNG thời gian thực tùy tiện.

**Chốt từ người dùng 2026-10-09:** Trait mục tiêu 101 identity (53 cũ + 48 mới) là catalogue thiết kế; số lượng hiện/ẩn và nature rate đã khóa; trọng số từng ID đang chờ bảng chi tiết. Mệnh Cách 0,50% congenital được giữ; eligible IDs và per-ID birth weights chờ duyệt. Kiếm Cốt không thuộc initial eligible physique pool cho đến khi hợp đồng vũ khí và effect thật hoàn chỉnh; special Physique total vẫn 3%, weights eligible còn lại chuẩn hóa từ bảng đã duyệt. Không được dùng ID ghi nhận khi sinh để âm thầm kích hoạt mechanic chưa có consumer.

## 5. Gốc vận hành: một vòng hành động hợp lệ (RANH GIỚI ĐÃ KHÓA, EVENT CONTRACT ĐỀ XUẤT)

```text
SimulationState (seed / tick / policy / world / warehouse)
      -> command + nhu cầu + trạng thái + goal + bối cảnh
      -> Decision/Workforce/AI CHỌN action hợp lệ
      -> kiểm tra điều kiện / đích / khu vực / tài nguyên / đang bận
      -> Action START nếu hợp lệ (lưu trạng thái tiến trình nếu kéo dài)
      -> đọc một lần các modifier chuyên ngành trên đúng channel/context
      -> Action RESOLVE từ simulation authority: tiêu hao và trao thưởng thật
      -> xuất typed result/event có actor/source/context/tick
      -> update XP, tiến trình, kho, HP, significant history/reveal hợp lệ
      -> cache-derived invalidation -> UI chỉ đọc -> hành động tiếp
```

Các lệnh người chơi dùng `WorkforceSystem.issue_command`/điều phối đang có hoặc API tương thích; không làm UI tự thay đổi HP/XP/loot. Ưu tiên **giữ action scheduler hiện tại** (`SimulationScheduler.step`, `next_action`, `perform_work`, combat/cultivation) và gắn hợp đồng chung tại ranh giới thay vì viết simulation vòng lặp thứ hai.

**Đề xuất event/outcome contract để duyệt trước khi code:**
- `action_id / action_instance_id` (bền vững trong quá trình thực hiện),
- `actor_id`, `kind`, `source_id` / `target_id` hoặc đối tượng công trình/map,
- `start_tick`, `resolve_tick`, `context/tags`,
- `outcome: success/failure/cancelled` kèm `result` tài nguyên/XP/HP/damage,
- `applied_source_ids` cho giải thích và tránh cộng hiệu ứng hai lần,
- `significant_event_key` khi có giá trị lịch sử dài hạn.

Các mốc `started`, `progressed`, `completed`, `cancelled` phải được phân biệt khi thật sự cần; **chỉ kết quả cuối hợp lệ mới trao thưởng**, không nhấp UI để nhận hai lần. Thời gian có thể nhiều tick. Sự kiện thường chỉ dùng lúc xử lý; **không lưu toàn bộ log hành động của 3.000 người mãi mãi**. Lịch sử quan trọng và tiến độ điều kiện cần lưu có chọn lọc.

Lệnh của người chơi, chính sách tông môn, điều kiện an toàn, hành động hiện tại và AI phải có **một thứ tự ưu tiên xác định**; lịch `schedule_phase` hiện có và hành vi command hiện có là nền tảng, không âm thầm thay đổi luật cũ. Thứ tự ưu tiên cuối của V2 là mục trình người dùng duyệt (xem M-02).

## 6. Hệ tính hiệu ứng thống nhất (THIẾT KẾ ĐÃ KHÓA)

Mỗi hiệu ứng có `source_id`, `channel`, `mode`, `value`, `context/filter`, `enabled`, `provenance`. Loại `flat`, cộng % trên gốc, điểm phần trăm, nhân đặc biệt và thay đổi luật phải theo stat framework và Combat Stats V2.

`RealmBodyCore -> Tiềm Lực -> phần cộng cố định (ví dụ trang bị) -> các % cùng channel cộng trên base -> bối cảnh -> luật đặc biệt -> kết quả`.

Không có `combat_power` universal V2, không có Mana/Kiếm Ý universal, không cộng Thể Lực Viễn Chinh cho sản xuất trong tông môn. Sự kiện tạo modifier tạm phải có nguồn, thời hạn, trạng thái và điều kiện thu hồi; không tự cấp buff không có consumer.

**Kiểm chứng từ code tại thời điểm rà:** `SimulationScheduler` hiện có hành động/lệnh/chiến đấu/tu luyện; `WorkforceSystem.perform_work` và `CultivationSystem.cultivate` còn trừ `disciple.stamina`; `CombatSystem` còn dùng `effective_combat_power`; `SectState` còn các profile P2 rời. Đây là **tồn đọng phải sửa trong phase thích hợp**, không phải bằng chứng V2 đã chạy.

## 7. Nhật ký đời người, tương tác, khả năng mở rộng

- Phân biệt `action outcome` thông thường với `significant history` được giữ lâu dài. Lịch sử ghi ID nội dung ổn định, người tham gia, thời điểm, định danh trận/sự kiện để chống farm và hỗ trợ Mệnh Cách được nhận muộn.
- Mỗi Trait/Destiny/Root/Bloodline/Physique đọc event và field có chủ sở hữu, không tự lặp toàn bộ 3.000 người mỗi tick.
- Reveal đọc hồ sơ ẩn đã sinh và lịch sử hợp lệ; không leak `latent` qua UI, điều kiện mua, mời, sai khác thông báo hoặc phản ứng AI chưa được cho phép.
- Cấm recursion vô hạn: trigger budget, source attribution, cooldown nội bộ, một proc có thể kiểm tra một lần trên cast/action identity và không tự kích hoạt chuỗi vô hạn.
- Quan hệ/tâm trạng/đời sống sâu và món ăn chỉ mở khi có subsystem thật; không dùng text sự kiện để giả lập mutation.

## 8. Lưu/tải, phiên bản và reset giai đoạn thiết kế

- Trạng thái hiện hành: `SaveService.CURRENT_VERSION = 2`; `DiscipleState` và `CandidateState` có danh sách field `to_dict/from_dict` rõ ràng; `SectState` có dictionary P2 riêng.
- Thiết kế V2 phải có phiên bản hồ sơ, per-layer initialized marker, immutable snapshots, không tự gán `none` khi thiếu field mà phân biệt chưa sinh/không có.
- Không ép `SaveService` tăng số phiên bản nếu chỉ thêm một profile nội bộ có version riêng, nhưng việc đổi wire format phải đi qua một migration được kiểm thử (quyết định chi tiết ở phase code).
- Người dùng **cho phép reset nhân vật/save thử nghiệm chủ động** trong giai đoạn thiết kế; không tự xóa kho dữ liệu hoặc hạ chuẩn regression P0–P3.7C1. Hướng xử lý compatibility old-save cụ thể phải báo trước và duyệt khi phase đụng tới migration.
- Không sinh nhân vật mới bằng cách load thiếu field; không double-award action sau restart.

## 9. Bài thử gốc (TIÊU CHÍ CHẤP NHẬN, CHƯA CHẠY)

1. Cùng seed, source, generation index sinh đúng cùng người gồm tất cả dữ liệu hiện/ẩn. Sự bổ sung nội dung sang domain khác không thay foundation/Dẫn Tiên C1.
2. Ứng viên → đệ tử → save/load → reveal không đổi identity, birth snapshot và `none` hợp lệ.
3. Hai người cùng điều kiện khác một nguồn modifier thật phải cho kết quả đúng nơi cần, không làm sai fixed reward.
4. Một hành động hoàn tất chỉ thanh toán XP/kho/HP một lần, kể cả save/restart/cancel/đổi lệnh.
5. Thể Lực Viễn Chinh không bị trừ bởi công việc trong tông môn; Tu Vi/Luyện Thể độc lập.
6. Những field chưa có consumer được đánh dấu chưa kích hoạt; không có buff/UI giả.
7. 1.000–3.000 đệ tử: trạng thái/nhật ký không tăng vô hạn theo mỗi tick; derived channels chỉ tính khi cần.
8. Godot 4.7.2 focused + cumulative regression phải có bằng chứng thật, không tự gọi PASS sau đọc code.

## 10. Quyết định mới CẦN NGƯỜI DÙNG DUYỆT trước khi code

| Mã | Còn mở | Phương án kiến nghị (CHƯA KHÓA) | Rủi ro nếu không duyệt |
|---|---|---|---|
| **M-01** | Mô hình lưu V2 cụ thể | Một hồ sơ canonical trên mỗi ID, phân vùng rõ `identity/birth/permanent/learned/living/organization/history`, từng chuyên ngành có `initialized`/version riêng; phần dict P2 chỉ làm adapter | Nhân vật tồn tại hai bản truth; load/reveal mất dữ liệu |
| **M-02** | Thứ tự ưu tiên lệnh với sinh tồn/đang làm | Ràng buộc an toàn/bất khả thi trước, hoàn tất hành động không thể ngắt nếu đã bắt đầu, rồi đến lệnh hợp lệ của người chơi, chính sách/tổ chức, mục tiêu và tính cách/AI; có quy tắc hủy/hoãn rõ ràng | Lệnh người chơi bị bỏ qua hoặc cắt ca làm mất tài nguyên |
| **M-03** | Lưu sự kiện cho 3.000 đệ tử | Event result typed theo hành động; chỉ lưu significant-history và bộ đếm/điều kiện còn sống; log chi tiết dùng vòng đệm giới hạn nếu cần debug/UI | Save tăng vô hạn hoặc điều kiện Mệnh Cách hậu thiên không thể xét |
| **M-04** | Sinh Trait/Mệnh Cách khi pool per-ID chưa đủ luật | Giữ schema/seed/initialized và tỷ lệ nhóm đã khóa, **chưa chọn tên ID từ danh sách chưa duyệt**; trước code generator V2 phải khóa eligible pools/birth weights, hoặc phê duyệt từng pool tối thiểu có cơ chế thật | Tự chọn trọng số làm thay đổi xác suất; sinh content không có cơ chế |
| **M-05** | Reset dữ liệu thử nghiệm và tương thích | Cho phép reset các world/nhân vật test được chỉ rõ; vẫn giữ lối load/compat để chạy gate baseline khi sửa, không tự xóa file của người dùng | Phá dữ liệu/test và không xác định được regression |
| **M-06 — ĐÃ CÓ LUẬT V2** | Khi Max HP vĩnh viễn thay đổi | **Giữ nguyên tỷ lệ HP hiện tại**, trừ hiệu ứng explicit healing/damage; luật đã khóa tại `docs/COMBAT_STATS_V2_SPEC.md` | Khi code phải bảo đảm không hồi đầy miễn phí, test theo nhiều nguồn |

Không giải quyết M-04 bằng một bảng ngẫu nhiên chung tự chế; việc sinh bẩm sinh hoàn chỉnh phải chờ pool hợp lệ, dù bộ khung nhân vật có thể được triển khai và kiểm thử trước.

## 11. Thứ tự gốc → nhánh tiếp theo

**Đã có/đã khóa:** time/world authority P0; P3.7C1 Dẫn Tiên + open-point Lục Duy; phân lớp canonical theo Master Schema/Stat Framework.

**Trước code DV2-01:** duyệt M-01..M-05; giữ nguồn P3.7C1. M-06 chốt trước DV2-02.

**DV2-01:** hồ sơ canonical, candidate→disciple, seed domain, birth snapshots, versioned persistence và test no-reroll.

**DV2-02 + hành động:** pipeline derived, action result/event và tối thiểu một vòng hành động thật; sau đó chuyển 30×10 tiến trình, root, Trait, fate, bloodline, physique và skill theo dependency, không ngược lại.

**Định nghĩa hoàn thành:** không phải 'đã có 101 tên Trait', mà là cùng một con người được sinh, hành động, tạo kết quả, thay đổi thực sự, lưu/tải ổn định và được UI mô tả trung thực.

## 12. Quyết định V2 2026-10-09 — gốc chỉ số, 3 xung đột và triển khai từ dưới lên

User đã quyết định giải quyết **cả 3 mâu thuẫn theo V2** (quyết định thiết kế, không chứng nhận runtime migration):

1. Stamina/Thể Lực = **Thể Lực Viễn Chinh 100 cơ sở/ngày, only outside-map**; không trừ trong sản xuất, luyện thể, tu luyện hoặc đi lại trong tông môn. Không dùng Thể Lực V2 để chặn Workforce 
2. Trait V2 **không grade 1..5**, không `combat_power_flat`; riêng **Thiên phú nghề** giữ hệ Grade 1..5 độc lập và tăng XP nghề theo P3.7
3. Combat V2 sử dụng bộ Combat Stats thật, không lấy `combat_power` legacy làm biến sát thương

**Thiết kế chỉ số gốc và hợp đồng tính toán:** `docs/DISCIPLE_V2_STAT_CAUSAL_CONTRACT.md`.

**Ma trận ánh xạ tất cả 101 Trait, 24 Mệnh cá nhân, 10 Root, 5 Bloodline, 15 Physique:** `docs/DISCIPLE_V2_EFFECT_SOURCE_MATRIX.md`.

**Thứ tự đã được người dùng duyệt:** (1) kiểm kê base/derived/outcomes → (2) thiết kế/hợp đồng combat-production → (3) ánh xạ hiệu ứng và dependency → (4) bắt đầu **một phase gameplay có gate** sau khi các điều kiện tiên quyết của phase được chốt. Hợp đồng không tự tạo công thức ATK/DEF/HP, phẩm chất sản phẩm, trọng số Trait/Fate chưa duyệt. `CURRENT_CHECKPOINT.md` vẫn là nguồn duy nhất quyết định phase có PASS hay chưa.
