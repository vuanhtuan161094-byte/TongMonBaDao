# P3.6 — SECT MASTER GAMEPLAY LOOP / VÒNG LẶP QUẢN LÝ TÔNG CHỦ

Date: 2026-10-04  
Status: DESIGN LOCKED / PRODUCT-LOOP AUTHORITY  
Runtime note: this is a cross-phase gameplay/UX contract, not evidence that P3.4/P3.5 runtime is green.

## 0. Mục tiêu

P3.6 trả lời một câu duy nhất:

> Người chơi mở Tông Môn Bá Đạo và chơi 5–10 phút thì **thực sự làm gì**, quyết định gì, quan sát gì, và vì sao muốn tiếp tục?

Core identity đã khóa:

- người chơi là **Tông Chủ**;
- người chơi điều hành hạ tầng, chính sách, phân công, đầu tư và can thiệp chiến lược;
- đệ tử là người tự sống, tự làm, tự tu luyện, tự săn, tự nghỉ, tự hồi phục và tạo ra diễn biến;
- routine micromanagement từng người phải là **tùy chọn**, không phải nghĩa vụ.

P3.6 không thêm một hệ gameplay song song. Nó quy định cách các hệ đã có và các panel P3.3/P3.4/P3.5 ghép thành một game loop dễ hiểu.

---

# 1. Một câu mô tả vòng chơi

`NHÌN -> HIỂU -> CHỌN 1–3 VIỆC ĐÁNG CAN THIỆP -> RA CHÍNH SÁCH/PHÂN CÔNG/LỆNH -> NHÌN HẬU QUẢ DIỄN RA TRÊN MAP -> ĐẦU TƯ/GROWTH -> ĐỂ TÔNG MÔN TỰ CHẠY`.

Không phải:

`mở menu A -> collect -> mở menu B -> collect -> mở menu C -> collect -> repeat`.

Không phải:

`tap từng đệ tử mỗi 10 giây để giữ chúng làm đúng việc`.

---

# 2. Ba tầng quyền lực của Tông Chủ

Đây là trục quan trọng nhất của gameplay quản lý.

## Tầng 1 — Chính sách toàn tông

Tác động rộng, ít phải đổi.

Authority hiện có:

### Workforce policy

`WorkforceSystem.set_work_policy()`

- Cân bằng;
- Ưu tiên sản xuất;
- Ưu tiên tu luyện.

### Needs priority

`NeedsSystem.set_priority()`

- Cân bằng;
- Ưu tiên thuốc;
- Ưu tiên vật tư.

### Equipment policy

`EquipmentSystem.set_policy()`

- Cân bằng;
- Chiến đấu;
- Tiết kiệm.

**Vai trò trong loop:** quyết định “tông môn hiện ưu tiên hướng nào”.

Người chơi không nên phải đổi policy liên tục. Một lựa chọn policy tốt phải có thể để simulation chạy nhiều nhịp.

---

## Tầng 2 — Phân công dài hạn

Authority hiện có:

- work group;
- work preference;
- combat/adventure team;
- combat role;
- về sau sect rank/chức vụ.

Ví dụ hiện tại:

- Đội Khai Khoáng;
- Luyện Khí Đường;
- Hunter/Guard/Logistics trong organization layer.

**Vai trò trong loop:** thiết kế cấu trúc con người của tông môn.

Đây là quyết định “ai thường xuyên phụ trách việc gì”, khác hoàn toàn lệnh trực tiếp.

Người chơi chỉ chỉnh khi:

- tuyển người mới;
- thiếu nhân lực một mảng;
- một người phát triển nghề khác;
- chiến lược toàn tông đổi;
- có vấn đề vận hành.

Không phải mỗi action cycle đều phân lại.

---

## Tầng 3 — Lệnh Tông Chủ trực tiếp

Authority hiện có:

`WorkforceSystem.issue_command()`.

Ví dụ:

- Tu luyện;
- Nghỉ;
- Khai khoáng;
- Luyện khí;
- Về tông;
- săn vùng cụ thể khi world-flow dùng tới.

Đây là **can thiệp ngắn hạn**, có TTL.

Quan trọng:

- direct command không được presentation tự biến thành `current_action`;
- simulation quyết định execution;
- survival rule vẫn đứng trên direct order;
- HP quá thấp / stamina quá thấp có thể khiến đệ tử không làm theo ngay.

**Vai trò trong loop:** xử lý ngoại lệ hoặc cơ hội đáng chú ý.

Lệnh trực tiếp không phải cách điều khiển mặc định của cả tông môn.

---

# 3. Thứ tự authority khi người chơi can thiệp

Canonical mental model:

`SINH TỒN -> LỆNH TRỰC TIẾP -> LỊCH/CHÍNH SÁCH -> PHÂN NHÓM/ƯU TIÊN -> AI TỰ CHỌN`.

Diễn giải cho người chơi:

- Tông Chủ có quyền ra lệnh;
- nhưng người bị thương nặng/kiệt sức vẫn biết tự bảo toàn;
- khi không có lệnh gấp, đệ tử sống theo vai trò, chính sách, tính cách, goal và hoàn cảnh.

Đây là khác biệt giữa game quản lý người sống và game RTS puppet-control.

---

# 4. Vòng chơi 5–10 phút canonical

Thời gian dưới đây là UX target, không phải timer bắt buộc.

## 0:00–0:20 — Nhìn toàn cục

Người chơi vừa vào map.

Trong vài giây phải đọc được:

- tài nguyên chính ở top bar;
- 0–3 cue quan trọng P3.5;
- actor đang di chuyển/làm việc;
- công trình nào đang có vấn đề;
- task/chapter dài hạn bên trái nếu đang có.

Không tự mở popup.

Không ép nhận thưởng.

Không hiện 5 modal đăng nhập.

### Câu hỏi người chơi cần trả lời được

- Có ai sắp chết/gặp nguy không?
- Có bottleneck rõ ràng không?
- Có cơ hội đáng xử lý không?

Nếu không có gì đáng xử lý, đó **không phải lỗi**. Người chơi được quyền quan sát tông môn tự vận hành.

---

## 0:20–2:00 — Xử lý ngoại lệ thật sự

Ưu tiên từ P3.5:

1. S0 critical;
2. S1 actionable;
3. sau đó mới S2.

Ví dụ:

- đệ tử ngoài tông nguy hiểm -> xem người đó -> triệu hồi;
- có người bị thương + hết thuốc -> mở Dược Phòng;
- quá tải chỗ ở -> mở Đệ Tử Xá;
- người đủ đột phá -> xem hồ sơ, cân nhắc;
- Mine/Forge thiếu người -> phân người nếu chiến lược cần.

### Target

Một session bình thường chỉ nên có khoảng **0–3 can thiệp bắt buộc đáng kể**.

Nếu cứ mỗi phút sinh 6 việc bắt buộc, loop đã thất bại.

---

## 2:00–4:00 — Quyết định chiến lược nhỏ

Người chơi chủ động chọn một hướng, không chỉ chữa cháy.

Ví dụ dựa trên hệ hiện có:

### Muốn tăng sản xuất

- Main Hall -> policy Ưu tiên sản xuất;
- phân thêm người vào Khai Khoáng/Luyện Khí;
- để simulation tự chạy.

### Muốn đẩy cảnh giới

- policy Ưu tiên tu luyện;
- chọn 1–2 đệ tử quan trọng để direct cultivate nếu cần;
- theo dõi người gần đầy progress.

### Muốn chuẩn bị chiến đấu

- equipment policy thiên chiến đấu;
- craft trang bị nếu có vật liệu;
- xem team/role/world ở phase tương ứng.

### Muốn ổn định hậu cần

- đổi needs priority;
- mở rộng chỗ nghỉ nếu quá tải;
- bổ sung cấu trúc nhân sự.

Đây là phần tạo cảm giác “mình đang xây một tông môn theo ý mình”.

---

## 4:00–7:00 — Đầu tư / phát triển

Không bắt buộc session nào cũng có investment action.

Các đầu tư hiện có hoặc đã có authority:

- craft trang bị;
- mở rộng lodging;
- tuyển đệ tử nếu có candidate/token/capacity;
- lựa chọn/điều chỉnh người phù hợp với công việc;
- xem một đệ tử có cơ hội phát triển đáng chú ý;
- dùng các action thật của Huyết Mạch/Thể Chất khi tài nguyên đủ.

### Nguyên tắc

Investment phải:

- tiêu tài nguyên thật;
- thay đổi capability/state thật;
- tạo tradeoff.

Không có nút “Nâng cấp” chung chỉ để tăng level UI nếu backend chưa có mechanic.

---

## 7:00–10:00 — Quan sát hậu quả

Sau quyết định, game phải cho người chơi **nhìn thấy hệ thống trả lời**.

Ví dụ:

- người vừa phân Mine bắt đầu có xu hướng đi Mine;
- direct command được AI nhận khi đủ điều kiện;
- Thanh Thiết tăng khi work cycle thật hoàn thành;
- forge support tăng khi Luyện Khí hoàn thành;
- người mệt tự về nghỉ;
- người bị thương đi heal/rest theo decision;
- actor đổi destination theo action;
- cue hết khi vấn đề thật được giải quyết;
- event cue xuất hiện khi thành quả thật xảy ra.

Đây là phần payoff.

Nếu bấm policy nhưng người chơi không thể quan sát được hậu quả nào trên map/state, UX coi như chưa hoàn thành.

---

# 5. Loop không có điểm kết thúc cưỡng bức

P3.6 không tạo “Daily Checklist” bắt người chơi hoàn thành đủ 8 mục.

Sau 5–10 phút người chơi có thể:

- thoát;
- tiếp tục ngắm;
- đào sâu một đệ tử;
- chỉnh cơ cấu;
- đi world flow;
- tuyển người;
- craft;
- theo dõi breakthrough.

Game loop phải co giãn từ session ngắn tới session dài.

---

# 6. Bốn loại quyết định của người chơi

## A. Phản ứng

“Có vấn đề gì cần cứu ngay?”

Nguồn:

- P3.5 critical/actionable cues.

Ví dụ:

- nguy hiểm ngoài tông;
- bị thương;
- hết thuốc khi có người cần;
- overcrowding.

Tần suất phải thấp.

---

## B. Điều hành

“Ta muốn bộ máy chạy theo hướng nào?”

Nguồn:

- policy;
- work groups;
- assignments.

Đây phải là phần chiếm nhiều giá trị quản lý nhất.

---

## C. Đầu tư

“Ta bỏ tài nguyên vào đâu để mạnh hơn?”

Nguồn hiện có:

- equipment craft;
- lodging;
- Bloodline/Physique actions;
- recruitment;
- technique/resources.

Không cần session nào cũng có.

---

## D. Khám phá con người

“Đệ tử này đang trở thành người thế nào?”

Nguồn:

- P3.3 6-tab deep screen;
- nghề;
- cảnh giới;
- công pháp;
- trang bị;
- Huyết Mạch;
- Thể Chất;
- quan hệ;
- về sau memory/destiny/life events.

Đây là phần tạo attachment/story, nhưng không được ép mở hồ sơ mọi người thường xuyên.

---

# 7. Attention budget — chống biến game thành công việc

Canonical UX target ở một thời điểm:

- tối đa 3 world cues;
- tối đa 1 panel operational đang mở;
- 1 selected target;
- task rail chỉ giữ objective dài hạn/onboarding;
- không có thêm alert feed thứ hai.

## Một session bình thường

Mục tiêu:

- 0–3 vấn đề cần xử lý;
- 1–3 quyết định chiến lược;
- 0–2 đầu tư lớn;
- tùy chọn 0–2 lần deep-inspect disciple.

Đây là target cảm giác, không phải hard cap runtime.

Nếu QA phải click 20–30 thao tác lặp lại chỉ để giữ trạng thái bình thường, design phải được xem lại.

---

# 8. “Không làm gì” cũng phải là trạng thái hợp lệ

Nếu tông môn:

- đủ thuốc;
- đủ chỗ nghỉ;
- workforce cân bằng;
- không ai nguy hiểm;
- không có critical opportunity;

thì người chơi không cần tạo việc giả.

Map được phép yên.

Đệ tử vẫn:

- tự làm;
- tự tu;
- tự săn;
- tự hồi phục;
- tự đưa ra decision;
- phát triển relationship/memory theo hệ hiện có.

Game không được sinh cảnh báo vô nghĩa chỉ để buộc thao tác.

---

# 9. Long-term pressure không được đến từ chore

Động lực dài hạn nên đến từ:

- muốn tông môn mạnh hơn;
- muốn đệ tử tiến cảnh;
- muốn đội hình tốt hơn;
- muốn economy ổn định hơn;
- muốn craft tốt hơn;
- muốn tuyển người thú vị hơn;
- muốn khám phá identity/story của đệ tử;
- muốn tiếp cận khu vực/nguy cơ/lợi ích cao hơn.

Không đến từ:

- thanh stamina của “Tông Chủ” bắt chờ;
- daily chores bắt collect;
- 20 red-dot menu;
- mandatory click-every-building;
- claim-all spam.

---

# 10. Map là dashboard sống, không phải dashboard số liệu

Map phải là nơi người chơi **thấy consequence** trước khi thấy spreadsheet.

Ví dụ:

### Sản xuất

Không chỉ:

`Thanh Thiết 14 -> 15`.

Mà còn:

- thấy người đi Khu Khai Khoáng;
- action label/cue;
- completion cue;
- rồi top resource thay đổi.

### Nghỉ

Không chỉ stamina number tăng.

Mà còn:

- actor đi Đệ Tử Xá;
- cue Mệt biến mất khi state hồi;
- panel cập nhật.

### Trở về

Không chỉ `region_id = sect`.

Mà còn:

- actor về Đại Môn;
- danger cue biến mất;
- trạng thái cập nhật.

Presentation không được mutate để tạo các kết quả này; chỉ visualize simulation result.

---

# 11. Task rail — vai trò canonical

Left task rail **không** trở thành bản sao P3.5 alert list.

Nó dành cho:

- onboarding;
- chapter objective;
- milestone dài hạn;
- progression goal có authority thật khi hệ objective tồn tại.

P3.5 cue = “đang xảy ra bây giờ”.

Task rail = “mục tiêu lớn người chơi đang theo đuổi”.

Hai hệ không duplicate nhau.

Current P3.1 demo checklist vẫn chỉ là presentation proof. Không được coi demo task text hiện tại là final quest system.

---

# 12. Recruitment nằm ở đâu trong loop

Recruitment là **growth opportunity**, không phải việc phải check mỗi phút.

Authority hiện có:

- candidate pool;
- recruitment capacity;
- ordinary/gacha/fate source;
- accept/reject;
- recruitment token.

P3.6 target:

- có candidate/opportunity -> entry nhỏ/secondary cue;
- người chơi mở khi muốn mở rộng nhân sự;
- accepted disciple đi vào chính workforce/organization/life loop;
- sau tuyển nên có một quyết định cấu trúc:
  - để tự do;
  - phân nhóm;
  - chọn role/team nếu phù hợp.

Không tuyển chỉ để tăng collection count.

Một người mới phải trở thành **một tác nhân mới trong hệ thống sống**.

---

# 13. World / săn nằm ở đâu trong loop

Current simulation cho disciple tự chọn vùng dựa trên:

- profit;
- danger;
- combat power;
- risk bias;
- goal;
- relationship;
- memory;
- organization;
- needs;
- cultivation/equipment power.

Do đó P3.6 không biến World thành màn bắt người chơi route từng chuyến săn.

Canonical:

- mặc định: AI tự chọn;
- Tông Chủ có thể can thiệp bằng world strategy/direct region order ở flow World;
- gate/main-map cue báo khi có người gặp nguy;
- return-sect là intervention nhanh;
- deep world planning là optional strategic layer.

Người chơi không cần duyệt từng chuyến đi mới cho simulation chạy.

---

# 14. Đệ tử đặc biệt / “main character syndrome”

Không khóa game vào một hero duy nhất.

Người chơi có thể thích một đệ tử và can thiệp nhiều hơn, nhưng core loop phải hoạt động khi tông môn có nhiều người.

P3.3 deep screen tạo attachment.

P3.4/P3.5 giữ management scale.

P3.6 acceptance cần kiểm cả hai:

- chơi kiểu “quan tâm một đệ tử cưng” vẫn vui;
- chơi kiểu “quản lý cả tông môn” không buộc mở từng profile.

---

# 15. Trạng thái bình thường vs ngoại lệ

## Bình thường — AI tự xử lý

Ví dụ:

- schedule work/cultivate/recovery;
- heal/rest decision;
- hunt;
- return;
- sell;
- buy;
- equipment auto-upgrade nếu hệ cho phép;
- routine cultivation.

Không alert người chơi chỉ vì một routine action đang diễn ra.

## Ngoại lệ — đáng đưa lên attention

Ví dụ:

- danger threshold;
- resource bottleneck ảnh hưởng thực tế;
- capacity pressure;
- breakthrough opportunity;
- workforce structure trống;
- event thành quả quan trọng.

Đây là nguồn P3.5 cue.

---

# 16. Reward feedback

P3.6 không thêm reward currency mới.

Feedback reward dựa trên thay đổi thật:

- resource tăng;
- item mới;
- realm tăng;
- profession level/progress;
- production completion;
- resource bottleneck được giải;
- người nguy hiểm về an toàn;
- capacity tăng;
- candidate tốt được tuyển;
- hệ thống chạy ổn hơn sau policy/assignment.

Visual/audio polish về sau phải làm nổi các thay đổi này, không che chúng sau menu.

---

# 17. Thất bại / ma sát

Không phải mọi lệnh đều được thực hiện ngay.

Ví dụ authority hiện tại:

- HP ratio < 0.72 hoặc stamina < 42 có thể chặn workforce direct action;
- thiếu material chặn craft;
- thiếu supply chặn lodging expansion;
- capacity chặn accept candidate;
- medicine 0 làm heal path thay đổi;
- survival/AI có quyền đổi hành vi.

UI phải giải thích **vì sao chưa làm được**, không để người chơi tưởng nút hỏng.

P3.6 yêu cầu mọi action fail có reason ngắn và state-based.

---

# 18. Không tạo “độ bận giả”

Cấm dùng các pattern dưới đây để kéo session length:

- cooldown UI không có gameplay reason;
- collect button cho resource đã nằm trong state;
- claim-completed-work;
- manual pickup từng Thanh Thiết;
- confirm modal cho routine order;
- opening animation không skip;
- ép vào deep screen để ra quick order;
- quest chỉ yêu cầu click UI không có consequence.

Nếu action không tạo decision, nên tự động hóa hoặc bỏ.

---

# 19. Input-efficiency target

Routine operation:

### Biết một đệ tử đang làm gì

`tap actor` — 1 tap.

### Gọi đệ tử nghỉ/tu/work

`tap actor -> quick order` — 2 taps.

### Xử lý building shortage

`tap cue -> building panel -> action` — khoảng 2–3 taps.

### Xem sâu một đệ tử

`tap actor -> Xem chi tiết` — 2 taps.

### Đổi policy toàn tông

`tap Đại Điện -> policy` — khoảng 2 taps.

Nếu routine action cần qua 4–6 màn thì UX sai.

---

# 20. P3.4 + P3.5 phải phục vụ P3.6 như thế nào

## P3.4

Trả lời:

- “Tông môn đang vận hành thế nào?”
- “Ta có thể điều người/tài nguyên ở đâu?”

## P3.5

Trả lời:

- “Bây giờ cái gì đáng để ta chú ý?”

## P3.6

Quy định:

- “Ta chú ý bao nhiêu là vừa?”
- “Khi nào cần can thiệp?”
- “Khi nào nên để AI sống?”
- “Sau can thiệp, hậu quả phải thấy thế nào?”

Nếu P3.4/P3.5 khiến người chơi bận hơn mà không có quyết định thú vị hơn, chúng đã đi ngược P3.6.

---

# 21. Session examples

## Ví dụ A — Tông môn ổn

Mở game:

- không critical cue;
- một người đang Mine;
- hai người đang tu;
- một người đang nghỉ;
- resources bình thường.

Người chơi:

1. nhìn map;
2. mở Đại Điện;
3. chuyển policy sang ưu tiên tu luyện;
4. xem một disciple gần đầy cảnh giới;
5. đóng panel;
6. nhìn họ tự vận hành.

Session 3–5 phút vẫn hợp lệ.

Không cần game tạo việc giả.

---

## Ví dụ B — Có sự cố

Mở game:

- gate hiện `1 người gặp nguy`;
- Dược Phòng báo `Hết thuốc`;
- một disciple có `Bị thương`.

Người chơi:

1. tap danger -> triệu hồi;
2. tap Dược Phòng -> đổi ưu tiên thuốc;
3. xem Đệ Tử Xá có quá tải không;
4. nếu ổn, để simulation tiếp tục.

Chỉ 2–4 quyết định, nhưng có ý nghĩa.

---

## Ví dụ C — Muốn đẩy sản xuất

Người chơi chủ động:

1. Đại Điện -> Ưu tiên sản xuất;
2. Mine panel -> thêm một người vào mining crew;
3. Forge panel -> kiểm material/recipe;
4. craft khi đủ;
5. quan sát work completion + resource change.

Không cần direct-command từng worker liên tục.

---

## Ví dụ D — Đệ tử cưng sắp đột phá

1. cue `Có thể đột phá`;
2. tap -> disciple summary;
3. xem HP/stamina/cảnh giới;
4. Xem chi tiết nếu muốn kiểm công pháp/trang bị/Huyết Mạch/Thể Chất;
5. quyết định can thiệp hoặc để AI xử lý theo hệ hiện hành.

Đây là moment cá nhân nằm bên trong một management game, không thay thế management loop.

---

# 22. QA / acceptance metrics

P3.6 không có một unit test duy nhất; nó là product acceptance contract.

Sau P3.4/P3.5, playtest thực tế phải trả lời:

1. Trong 10 giây đầu có biết tông môn đang ổn hay có vấn đề không?
2. Không mở menu có thấy actor đang tự sống không?
3. Một vấn đề quan trọng có thể đi từ cue -> action trong <=3 taps không?
4. Có thể chơi 5 phút mà không mở deep disciple screen không?
5. Có thể chơi kiểu chăm một disciple cụ thể không?
6. Sau một policy/assignment/order có thấy consequence trên map không?
7. Nếu không thao tác 1–2 phút, game có tiếp tục vận hành hợp lý không?
8. Có bị spam >3 attention cue không?
9. Có action nào bắt người chơi click nhưng không tạo decision/consequence không?
10. Có phải mở mọi building để “collect” không? Nếu có -> fail.
11. Có phải command từng disciple để tông môn hoạt động không? Nếu có -> fail.
12. Survival override có được UI giải thích khi lệnh chưa thực hiện không?
13. Routine management có chủ yếu <=2–3 taps không?
14. Map còn là màn hình chính hay người chơi sống trong menu?
15. Sau 5–10 phút người chơi có cảm giác “ta vừa điều hành một tông môn” thay vì “ta vừa dọn notification” không?

---

# 23. Implementation consequence

P3.6 là authority để đánh giá các phase sau.

Không implement một “P3.6 system” riêng chỉ để đánh dấu phase.

Sau khi Windows gates hiện tại green:

1. implement + runtime-lock P3.4;
2. implement + runtime-lock P3.5;
3. chạy một **P3.6 gameplay-loop playtest pass** trên real map;
4. chỉ thêm mechanic mới nếu playtest cho thấy loop thiếu quyết định hoặc payoff thật.

Potential next functional work after that phải được chọn từ bottleneck quan sát được, không tự động mở thêm feature chỉ vì số phase tăng.

---

# 24. Những gì P3.6 KHÔNG khóa

Chưa khóa ở phase này:

- daily/weekly quest system;
- offline progression/reward;
- building upgrade tree;
- formal calendar/day cycle;
- world-map command UX chi tiết;
- recruitment screen UX chi tiết;
- sect rank administration UI;
- Destiny;
- injury/mood/loyalty future systems;
- social story bubbles.

Những hệ đó chỉ nên thêm nếu phục vụ core loop và có gameplay consequence thật.

---

# 25. Definition of success

Tông Môn Bá Đạo đạt P3.6 direction khi:

> Người chơi có cảm giác mình đặt hướng đi, phân người, đầu tư, xử lý ngoại lệ và quan sát hậu quả; còn đệ tử vẫn là những con người tự sống trong hệ thống.

Tông Chủ **có ảnh hưởng lớn nhưng không phải điều khiển từng bước chân**.

Đó là core loop phải bảo vệ khi mở rộng game về sau.
