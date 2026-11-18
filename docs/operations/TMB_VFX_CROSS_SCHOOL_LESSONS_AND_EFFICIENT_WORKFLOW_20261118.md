# TÔNG MÔN BÁ ĐẠO — TỔNG HỢP VFX LIÊN MÔN PHÁI & QUY TRÌNH SẢN XUẤT HIỆU QUẢ

**Phiên bản:** CROSS-SCHOOL-VFX-LESSONS-V1 — 18/11/2026 (UTC+7)  
**Phạm vi bằng chứng:** Quyền Tu (FIST01–FIST15), Độc Tu (các mốc POI01–POI20), Phong Ấn Phù (PAF01–PAF08 qua báo cáo chủ dự án cung cấp và các hồ sơ PAF trong repo), các mẫu kỹ thuật Hỏa/Lôi Phù và nghiên cứu Võ Đang/Võ Lâm.  
**Repo/nhánh:** [Tông Môn Bá Đạo](https://github.com/vuanhtuan161094-byte/TongMonBaDao) — [Draft PR #72](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72) — `integration/pve-p0-playable-ui-20261103`.  
**Tính chất:** Báo cáo tổng hợp, bộ quy tắc thực hành và checklist vận hành. **KHÔNG thay thế SOP V3 + Production System V4 đang có hiệu lực**, không tự phê duyệt bất kỳ skill, source, buff/debuff proposal hoặc tích hợp PvE nào.

## 0. NGUYÊN TẮC ĐIỀU HÀNH — MỘT CÂU

**Tái sử dụng HỆ THỐNG (renderer, tracking, timeline, QA); sáng tác riêng HÌNH TƯỢNG (hero sprite, chuyển động có nghĩa, contact). Sửa hình tượng trước khi chạy QA nặng.**

Bốn kết luận:
1. **VFX chạy được chưa chắc đẹp.** Atlas hợp lệ, 60 FPS của file MP4, GitHub Actions SUCCESS và ROI có pixel không chứng minh mỹ thuật.
2. **Một VFX đẹp phải có nghĩa trong game.** Người chơi ở tỷ lệ 1× phải thấy được nguồn → hành trình → tác động → kết quả, và phân biệt loại chiêu mà không dựa vào tên.
3. **Nguồn RGBA và key pose thật quyết định chất lượng.** Shader, glow, spline và màu chỉ bổ trợ; không chữa được một bàn quyền phẳng, lá phù giống thẻ UI hoặc con rắn thiếu hình.
4. **Làm ít bước thừa nhưng KHÔNG bỏ STOP gate.** G3.5/G3.6/G3.7 trước movie dài, G4/G5 chỉ chạy sâu khi ứng viên mỹ thuật đã đủ tốt, G7 chứng minh kỹ thuật exact-SHA, chủ dự án duyệt riêng.

## 1. PHẠM VI VÀ CÁCH ĐẾM KHÔNG NHẦM

| Tuyến | Phạm vi thực tế của tài liệu nguồn | Diễn giải đúng |
|---|---|---|
| Quyền Tu | 15 mốc FIST01–FIST15 Human, FIST03 là tên LAB/alias của canonical ultimate | Có nhiều bản native TECH PASS; chỉ những revision có quyết định chủ dự án cụ thể mới được gọi chấp nhận tạm/được duyệt |
| Độc Tu | 20 **mốc sản xuất** POI01–POI20, có mốc nghiên cứu lại cùng skill và có cả biến thể Tiên | Không phải 20 skill canonical mới, càng không phải 20 bản owner final |
| Phong Ấn Phù | 8 bản thử PAF01–PAF08; 5 active/ultimate, 3 nội tại theo bàn giao do chủ dự án cung cấp | PAF05/PAF06 hiện chấp nhận tạm; tài liệu bàn giao nói 0 đã nghiệm thu PvE; không suy chủ duyệt từ PASS kỹ thuật |
| Các tuyến còn lại | HF02 R6, TAL02 R6, TAL03 R4 và nghiên cứu JX/Võ Đang là **bài học kỹ thuật/mỹ thuật** | Không có ở đây một cuộc kiểm kê đầy đủ 12 môn phái; không tự tính là finished |

**Đơn vị thống kê bắt buộc tách:** `catalogue_skill_id` / `cast_master_family` / `visual_candidate_revision` / `native_tech_proof` / `owner_visual_decision` / `PVE_integrated`. Baseline thiết kế repo từng nêu 2.196 skill ID, 420 family, 204 Human cast masters và 216 nhóm passive/event; đây **không phải 2.196 VFX đã làm** hay trạng thái nghiệm thu mới nhất. Không cộng các mốc POI/FIST/PAF như thể tất cả là skill unique và đã chốt.

**Các xung đột phải đối soát, tuyệt đối không âm thầm hợp nhất:**
- `FIST09` Trấn Sơn Hộ Đồng: chat chủ dự án nói đã chốt một skill, nhưng hồ sơ R3 từng art-rejected, sau đó có R4–R6; **chưa xác minh revision/asset SHA nào tương ứng lần chốt**. Tạm gắn `OWNER_DECISION_RECONCILIATION_REQUIRED`.
- `POI06 R11`: bản native ghi chủ chấp nhận preview nhưng ledger còn pending; đối soát decision + exact revision rồi mới sửa ledger.
- `POI12`: việc chấp nhận hướng bay đơn giản không tương đương duyệt hình tượng kỹ năng.
- `POI17` và các bản tạm: lời “tạm được” không phải final.
- `PAF01`: gió/ấn có phần chấp nhận tạm, giấy phù chưa đẹp. Không nâng toàn R6 thành approved chỉ vì một phase được giữ.
- `PAF04`: R8 mới đến G3, chưa có native Godot proof; không tính TECH PASS.
- `FIST10 R4`: chỉ style reference GIF từng được thích; **không** là bản VFX Godot đã duyệt.

**Nguồn PAF:** phần mô tả 8 bản và đánh giá chung dựa trên báo cáo Phong Ấn Phù mà chủ dự án cung cấp trực tiếp; không giả định file ZIP bàn giao đã được commit. Các hồ sơ kỹ thuật PAF trong GitHub chỉ xác nhận đúng phạm vi mỗi hồ sơ riêng.

## 2. POSTMORTEM — LỖI ĐÃ LẶP, CĂN NGUYÊN, LUẬT PHÒNG NGỪA

| Lỗi lặp | Ví dụ | Nguyên nhân thực | Quy tắc bắt buộc |
|---|---|---|---|
| Trông như **ảnh dán / poster cắt** | FIST12 R6; POI19; PAF01 giấy phù | Dùng artboard, crop nhỏ hoặc alpha key rồi gọi là hero source | **Không dùng poster crop làm master.** Hero nguồn isolated true-RGBA, đúng chất liệu, pose độc lập; sửa matte ngay tại nguồn |
| Hình tượng **không có nghĩa** | POI16 R1, FIST14 R2 trông như trảo, FIST15 R2 trông như chữ V | Có chuyển động/glow nhưng không có silhouette diễn đạt effect | Chốt một câu mô tả hình tượng tại G2; kiểm **che HUD/tên chiêu** tại G3.7; fail thì vẽ lại hero |
| **Quá mờ** ở tỉ lệ game | POI16 R1B, status mờ FIST14 | Mọi lớp đều alpha thấp, core/body không đủ lực, tỷ lệ 1× quá nhỏ | G3.6 đo ROI/độ tương phản trên native 1280×720; vật liệu MIX đọc được, ADD lõi nhỏ; không “nâng ngưỡng” để cho PASS |
| **Neon phẳng / icon HUD** | vòng tròn ngẫu nhiên, hình quyền như bao tay, ba lá phù như card | Dùng hình học tĩnh làm chủ thể và quay/scale | Master có chất liệu/khối/vết sáng, key pose thay đổi hình thật; vòng buff chỉ là cấu trúc chuyển động, cần motif riêng |
| **Quỹ đạo sai nghĩa** | thử JX Võ Đang bay ngang trong khi skill kiểu giáng xuống | Một spline template áp cho mọi loại chiêu | Căn đường đi theo contract/đạo diễn: phóng, giáng, nổ tại chỗ, bao quanh, đi theo mục tiêu... Không suy ra projectile thật từ đường bay LAB |
| **Chuyển động oằn/ngắt** | luồng sáng/snake trails, pseudo-punch | Rung toàn khung, sin warp, lặp pose, translate actor idle | Pose có nguyên nhân và vận tốc hợp lý; nối tiếp keyframe; không rig, không fake hit/kick bằng dịch actor |
| **Va chạm thiếu lực** | quyền không có điểm chạm; POI19 hoa phủ không contact | Contact không tách khỏi body, nhiều flare đều nhau | Peak ngắn, lõi nóng nhỏ đúng điểm target, xung lực theo trục, fade nhanh; không thêm damage/hitstop vào Combat V2 |
| **Che mặt, che kỹ năng khác** | POI03, TAL03, FIST12 R9, vòng/mark PAF | Không thử quái WALK và compositing sau/trước actor | Căn pivot/anchor theo nhân vật, HP-safe area; BACK/FRONT riêng, moving target/decoy kiểm sớm |
| **Dấu status quá nhiều** | buff/debuff 36 nhánh | Nhầm skill-cast VFX với persistent gameplay status | Skill impact riêng; icon tồn tại theo canonical status family, chỉ khi runtime xác nhận; đọc `status` proposal trước khi triển khai |
| **QA dài dù art chưa đẹp** | POI18 R2C, FIST14/15 TECH PASS nhưng art FAIL | Quay hàng trăm frame/test đầy đủ trước khi xem 1× | Bắt buộc G3.5 hard STOP, G3.6/G3.7; fail thì quay về tranh, không chạy movie đầy đủ |
| **Đếm sai tiến độ** | 510 video frames được hiểu là 510 sprite; PASS CI bị gọi owner PASS | Không tách pose/video/3 clocks/trạng thái duyệt | Ledger phải có các trường tách biệt và bằng chứng chính xác theo revision |
| **Quyền nguồn thương mại** | JX/Võ Lâm/Source VL tham chiếu | Sẵn file nghiên cứu không đồng nghĩa được phép phát hành | Học cấu trúc pha/ánh sáng, không nhúng pixel/atlas/audio chưa có phép sử dụng |

## 3. ART BIBLE CHUNG — ĐẸP NHƯ VFX VÕ LÂM NHƯNG CÓ BẢN SẮC RIÊNG

### 3.1. Năm thành phần một VFX có chất lượng
1. **Hero silhouette có nghĩa:** người chơi nhận được “rắn”, “bàn quyền”, “linh phù”, “kiếm khí”, “ấn phong”, “vòng hộ thân” hoặc “tia sét” ở 1×; không phải hình chữ V, tia song song hay vòng HUD vô danh.
2. **Hot core:** vùng trắng/ngà gần trắng, sáng mạnh nhưng diện tích nhỏ, xuất hiện có nhịp tại tụ lực và contact; không đốt trắng toàn màn hình.
3. **Colored energy body:** vật liệu chính có sắc độ và hình khối, màu theo hệ/skill; opacity đủ để nhìn thấy ở game, không phải bề mặt đỏ/tím đục.
4. **Soft halo/trail:** lớp sáng ngoài mềm, trong, bất đối xứng, hướng chuyển động rõ; dùng ADD có kiểm soát; không rung sin giả sống.
5. **Contact + residue:** va chạm cục bộ mạnh, phản ứng thoát năng lượng và tan; nếu có hiệu lực dài, xử lý sustain/status **riêng**, không giữ một vụ nổ trong nhiều giây.

### 3.2. Ngôn ngữ trường phái — khác về hình, không chỉ màu
- **Quyền Tu:** trọng lực và hướng đánh rõ, quyền nén/giáng/hộ thể/hoàn lực khác nhau. Bá Quyền thiên nặng và chấn; Kim Cang thiên bảo vệ/phản lực; Huyết Quyền là ruby chảy có hướng, không thành lửa/trảo.
- **Độc Tu:** sinh vật hoặc vật chất độc có hình nhận diện (xà, cổ, kim, độc quang, lá dược); poison chỉ có status dai dẳng khi runtime có poison. Tránh sinh vật cứng như que, dấu/hoa phẳng dán màn.
- **Phong Ấn Phù:** giấy phù có **vật liệu phù thật** (mép giấy, mực/phù văn, vệt linh lực), ấn và luồng gió liên hệ nhân quả; buff có vòng quay quanh thân nhưng phải có motif/cue phân biệt skill. Tránh ba “lá bài” treo quanh người.
- **Hỏa/Lôi/Kiếm:** Hỏa có thân cháy bão hòa và lõi nóng; Lôi phân nhánh/giáng có điểm đánh; kiếm khí là năng lượng thuôn chuyển động, không tự biến thành kiếm thép. Học bảng sáng/cadence từ JX, không chép sprite thương mại.
- **Tier Human → Immortal → Divine:** có thể tái sử dụng kiến trúc, nhưng silhouette, nhịp biến hình, contact và tầng sáng cần tăng chất; **không chỉ đổi màu/phóng to**. Không suy Human owner approval thành tier approval.

### 3.3. Chuẩn kỹ thuật hình ảnh/di chuyển
- Nguồn: first-party isolated true RGBA, master đủ lớn cho envelope hiện hình ở 1×; source+generator/atlas+pivot+provenance lưu bền vững. Một ảnh poster đẹp **không** phải sprite layer.
- Animation: frame-by-frame **không rig**; số pose theo lượng biến đổi hình học/thời gian, **không dùng quota 8/12 frame cố định**, không lấy số video frame 60fps làm số sprite pose.
- Compositing mặc định: ground/ambient BACK MIX → hero/body BACK MIX → actor → local foreground contact MIX + hot ADD nhỏ → residue → status overlay riêng. Chiêu cụ thể có thể thay thứ tự có chủ đích, nhưng phải QA không che mặt.
- Timing: phân biệt **(A) gameplay cast/projectile/status/event receipt**, **(B) VFX charge/release/flight/contact/fade**, **(C) QA film/preroll/loop**. Ghi `RUNTIME_MAPPING_PENDING` nếu receipt thật chưa rõ. Không tạo heal/damage/hit/mark/summon bằng trình diễn.
- Chuyển động: anchor theo caster/target thực; chuyển hướng theo nghĩa kỹ năng; theo quái di chuyển ở LAB không được bịa mechanic homing. Có decoy không bị đánh/truyền sai; 1 mục tiêu hay cap3 đúng catalogue.
- Kiểm 1× native trên ít nhất nền sáng/tối và actor đang WALK; focus luôn giữ thấy mặt, thân, HP-safe area, contact và dấu cuối.
- Accessibility: hạn chế nhấp nháy toàn màn; có cấu trúc hình để nhận biết không chỉ bằng màu; về sau cho phép giảm độ sáng/số lượng hiệu ứng khi đông quái (G8).

## 4. DÂY CHUYỀN V4 HIỆU QUẢ — GỘP CÔNG VIỆC, KHÔNG THÊM SOP MỚI

Đây là **bản đồ thao tác nhanh** của cổng G0–G8 trong [SOP chính](TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md); khi có mâu thuẫn, SOP chính/AGENTS.md và quyết định mới nhất của chủ dự án có ưu tiên cao hơn.

| Nhịp công việc | Cổng chính thức | Làm gì một lần cho đúng | Đầu ra ít nhưng đủ | Quy tắc STOP |
|---|---|---|---|---|
| **A. Chốt đúng chiêu** | G0–G2 | Đọc LIVE HEAD, catalogue, ledger; 3 clocks; 1 câu hình tượng; phác 3–5 phase và target/cap; kiểm quyền nguồn | 1 skill contract/packet, 1 semantic storyboard + provenance | Sai effect/target hoặc motif vô nghĩa: **không vẽ hàng loạt** |
| **B. Master → ba ảnh Godot** | G3, G3.5 | Hero master RGBA + key pose thật, dựng mini LAB; xuất **3 native PNG charge/peak/contact trên quái WALK** | Source/atlas manifest + 3 PNG 1280×720 | 1× xấu, sticker, không nhận diện, sai vị trí, che mặt: **đổi tranh/pose** ngay |
| **C. Đọc rõ/nghĩa rõ** | G3.6, G3.7 | Đo visibility ROI theo skill; ẩn HUD/tên; nhìn contact, phase sustain/fade và khả năng phân biệt với skill tương tự | Bảng visibility + rubric mỹ thuật **mỗi mục trọng yếu ≥4/5 để đưa owner xem** | Tech visibility PASS nhưng art/semantic FAIL vẫn **không** đi tới full movie |
| **D. Chuyển động & event** | G4–G5 | Reuse shared native harness; test stationary/moving/decoy/targets đúng cap, anchor, expiry; xuất **movie native ngắn trọn attack→fade**, ≥12 timecodes ý nghĩa khi thích hợp | 1 MP4 thật + focused logs; status dài dùng ảnh mốc/expiry test riêng | Clip giả/offline, hit sai, quỹ đạo sai, nhìn ngắt: sửa **cùng skill** |
| **E. Chốt chứng cứ/duyệt** | G6–G7 | Tự chấm art, chạy validator packet→assets→evidence & CI focused exact-SHA; đối soát người duyệt và revision | 1 V4 packet/manifest, SHA, run URL, owner decision hoặc PENDING | Không có bằng chứng => `NOT_EXECUTED`; CI xanh **không tự duyệt mỹ thuật** |
| **F. Vào game thật** | G8 riêng | Chỉ khi chủ dự án ủy quyền: receipt-bound runtime, target/perf/crowd/Android/Windows real | Release gate có FPS/visual evidence và approval riêng | Thiếu lệnh hoặc QA vật lý => `PVE_HOLD`, không merge, V6.3 OFF |

**Bước rút ngắn quan trọng:** Không cần tạo phim dài gồm 5–8 giây “mark đứng im” ở mỗi vòng sửa art. Quay **clip ngắn qua attack→fade**, kiểm dấu duy trì và hết hạn bằng frame mốc/test deterministic; full combined movie chỉ khi animation sustain thực sự thay đổi, khi cần owner review/regression hoặc khi release gate yêu cầu. Đây là cách tối ưu V4.1, **không** loại bỏ G5. Không làm GIF mặc định; chỉ xuất nếu chủ dự án yêu cầu.

**Đối với passive luôn bật:** Không bịa cast/hit. Kiểm loop liên tục, bật/tắt, thay actor, chịu tải nhiều passive và trạng thái kết thúc/cắt lifecycle. G3.5 dùng các mốc phù hợp cho passive và ghi charge/contact N/A lý do rõ, không giả screenshot.

## 5. TỐI ƯU QA / TÀI NGUYÊN — GIẢM VIỆC THỪA, KHÔNG GIẢM CHẤT LƯỢNG

**Mô hình “một bộ máy, nhiều packet”:** Reuse renderer LAB, capture harness, native 1280×720 setup, tính contrast, screenshot/timecode, validator V4, quy ước naming/log/hash. Mỗi skill chỉ mang **contract JSON, art source + keyframes/atlas, scene config, focused assertions khác biệt**; không copy nguyên một engine/tests/CI trùng lặp cho từng chiêu. Thay đổi shared harness phải kiểm ảnh hưởng kỹ năng đã duyệt, một writer trên file dùng chung.

| Loại thay đổi | Kiểm nhanh trước | Kiểm đầy đủ phải có khi nghiệm thu |
|---|---|---|
| **Skill mới / thay hero / đổi semantics** | G0–G3.7 native STOP, moving-contact 3 frame | G4–G7 exact-SHA/full motion; owner art riêng |
| **Chỉnh cục bộ alpha/pivot/contact trên bản còn pending** | So sánh ảnh native 1× trước/sau + focused movement | Chạy lại các gate bị ảnh hưởng, V4 evidence cho revision được đưa owner xem |
| **Bản owner đã chốt/provisional, không sửa** | Kiểm ledger/nguồn lưu và quyết định | **Không sản xuất lại, không rerun movie/CI vô nghĩa**; regression chỉ khi dependency/shared renderer đổi |
| **Tối ưu renderer dùng chung hoặc gắn PvE** | Regression các representative skills/tier + effect semantics | G8 đúng phạm vi, crowd/perf, device + receipt authority riêng |

**Quy định tiết kiệm nỗ lực:**
1. Không chạy nhiều vòng CI nặng trước khi 3 ảnh preflight nhìn **thực sự đẹp**. CI không thay năng lực mỹ thuật.
2. Chỉ lưu **một nguồn dữ liệu quyết định** có link bằng chứng; không tạo 3–5 bản báo cáo lặp cho một chỉnh sửa nhỏ. Handoff nên là record trong ledger + link artefact.
3. Không nhân bản shader, status icon, camera capture, alpha validator hoặc screenshot script theo trường phái; dùng shared library với contract và test của mỗi school.
4. Không dùng thumbnail/phim offline làm bằng chứng native. Godot không chạy thì ghi `NOT_EXECUTED` và dừng gate.
5. CI check: hash/geometry/provenance/import/scene/moving-target/negative contract/manifest; **người** check silhouette, vật liệu, nhịp, độ “sang”, khả năng nhận diện. Một công việc chỉ có **một owner QA**.
6. Source gốc, generator, V4 packet, thông tin SHA phải nằm trong repo; Actions artifact có thể hết hạn, không phải kho nguồn duy nhất.
7. Trước khi sửa, tra approved phase và chỉ mở phần **được giao sửa**. Nếu không đạt, giữ bản cũ và backlogged debt; tuyệt đối không tự hạ các bản đã duyệt.

**Chỉ số vận hành nên đo sau mỗi nhóm skill:** (i) owner approved/provisional per review session (không tính TECH PASS), (ii) số vòng sửa tại G3.5 trước G5, (iii) số lỗi semantic/visibility lọt tới final movie, (iv) số asset dùng chung được tái sử dụng an toàn, (v) công suất vật lý G8 **khi đã đo**. Không đặt KPI số video/frame/Actions run.

## 6. QUY TẮC BUFF / DEBUFF VÀ KHẢ NĂNG NHẬN DIỆN 36 NHÁNH

**Trạng thái: ĐỀ XUẤT CHƯA ĐƯỢC CHỦ DỰ ÁN PHÊ DUYỆT / CHƯA TRIỂN KHAI.** Nguồn: [Status VFX 36 branches V1 proposal](../design/TMB_COMBAT_STATUS_VFX_36_BRANCHES_STANDARD_V1_PROPOSAL_20261117.md). Không chỉnh Combat V2 hoặc tạo `StatusPresentationNormalizer` khi chưa có phép.

- **Lớp A — cast/impact/cue riêng skill:** tỏa ra từ tay, vật dẫn, target, đường chạm, kết quả trong thời gian ngắn; bản sắc mỗi chiêu tồn tại ở đây.
- **Lớp B — persistent status presentation dùng chung theo trạng thái THẬT:** poison, burn, slow, weaken, mark, guard, HoT/recovery **chỉ khi dữ liệu gameplay thực tồn tại**. Cùng status family dùng cùng nền icon; có thể có subtype khi nguồn canonical yêu cầu.
- **Buff dài hạn:** vòng sáng quanh thân có chiều sâu và nhận diện riêng lúc ứng dụng, nhưng không để 6–8 vòng/đại phù che cả actor liên tục. Chuyển sang trạng thái yên/small readout khi sustain.
- **Debuff dài hạn:** mark nhỏ vùng vai/HP-safe, không che mặt; không biến mỗi skill thành một biểu tượng treo 6s. Cùng status family gộp hiển thị theo nguồn thật, không gộp timer/owner để làm sai gameplay.
- **Gợi ý UI đông quái chưa chốt:** mỗi actor thường tối đa 2 icon debuff chính + `+N`, buff hàng riêng; chi tiết mở khi chọn mục tiêu/Boss. 24px là kích thước đề xuất cần QA, **không là thông số đã duyệt**.
- **Sự kiện không bằng trạng thái:** `status_applied` kích cue chứ không tự tạo thời hạn/stack; `damage`, `cleanse`, `consume_poison`, `mobility`, `passive`, `summon` không tự có icon persistent. Với multi-owner, giữ stack/source/next_expiry/last_expiry chính xác từ state.

**Ưu tiên ra quyết định:** trước khi giao đội art vẽ cả bộ status icon, chủ dự án cần duyệt vocabulary/UX và state mapping. Đừng dựng 36 bộ icon hoặc vòng quay trường phái bằng placeholder.

## 7. MA TRẬN TRẠNG THÁI CHUẨN — KHÔNG ĐỂ “TẠM ĐƯỢC” THÀNH FINAL

Mỗi **revision** có các trường độc lập:

| Trường | Giá trị gợi ý | Ai/điều gì chứng minh |
|---|---|---|
| `source_ready` | YES / NO | Art master thật, quyền nguồn, alpha, key pose, source path/SHA |
| `technical_gate` | TECH_PASS / TECH_FAIL / NOT_EXECUTED | Godot native, V4 stages, run + exact SHA |
| `art_self_gate` | SELF_PASS / SELF_FAIL / NOT_REVIEWED | 1× G3.5/G3.6/G3.7, chấm các tiêu chí |
| `owner_visual` | APPROVED / PROVISIONAL / REJECTED / PENDING / CONFLICT_RECONCILE | **Lời chấp nhận của chủ dự án gắn exact revision/phase** |
| `approved_phases` | explicit list / none | Chỉ khóa đúng phase/motif đã được duyệt |
| `polish_debt` | short precise notes | Việc còn thiếu, không tự overwrite art |
| `pve_gate` | HOLD / APPROVED_FOR_INTEGRATION / INTEGRATED_VERIFIED | Quyết định G8 và runtime evidence |
| `device_gate` | PENDING / VERIFIED | FPS/ảnh/hoạt động trên thiết bị vật lý |
| `proof` | source SHA, packet, run URL, movie/3 PNG | Đường dẫn bền vững, phân biệt QA synthetic vs runtime |

Không thay ledger cũ bằng nhãn phẳng `PASS`. Nếu hai nguồn mâu thuẫn, **giữ cả hai link, đánh CONFLICT và đối soát**; quyết định mới nhất, đúng revision, có thẩm quyền owner mới quyết định art. Khi owner nói “tạm chốt, làm chiêu kế”, khóa revision ở `PROVISIONAL` và chuyển tiếp được theo chỉ thị, không bắt họ duyệt đi duyệt lại. **Không tự nâng PROVISIONAL thành APPROVED.**

## 8. THỨ TỰ XỬ LÝ SAU BÁO CÁO

| Ưu tiên | Hạng mục | Điều kiện xong |
|---|---|---|
| **P0 — Đồng bộ sự thật** | Đối soát FIST09 version owner chốt; POI06 preview vs ledger; POI12/17 mức “tạm”; PAF01/02 phase-specific; không cộng POI01+POI02 như unique | Decision log có revision, nguồn owner, trạng thái tách art/tech |
| **P0 — Chuẩn triển khai** | Dùng ngay file này làm checklist đọc nhanh, **SOP V4 làm thẩm quyền**; chuẩn hóa 3 clocks + G3.5/G3.6/G3.7 cho các chat VFX | Không có các đường QA song song hoặc kiểm trùng kết quả |
| **P1 — Chất lượng mỹ thuật còn nợ** | FIST14 (3 trảo→quyền truy), FIST15 (V/sọc→quyền giáng/huyết hải), PAF01 lá phù, PAF05 charge, PAF04 cần Godot, POI19/20 vật liệu/đầu xà | Chỉ triển khai đúng skill được chọn; ưu tiên art source, giữ phiên bản/phase đã duyệt |
| **P1 — Chuẩn buff/debuff** | Chủ duyệt taxonomy icon/state + cue, rồi mới làm shared renderer read-only | Không giả buff/mark; verified Combat V2 mapping |
| **P2 — Đóng kỹ thuật/pipeline** | School-specific V4 packet dùng shared validator, 3 PNG + clip native; giảm duplicate files và test chạy thừa | Cùng quality gates, fewer redundant builds, evidence exact SHA |
| **P3 — PvE/release** | Thực hiện G8 sau quyết định chủ dự án: real receipt, dark/bright, 6v8 và 30 đệ tử/40 quái, Windows/Android thật | Chỉ khi đạt thẩm quyền/performance; PR #72 vẫn Draft và không merge trước |

## 9. CHECKLIST MỘT TRANG CHO CHAT/AGENT SẢN XUẤT SKILL KẾ TIẾP

**Đầu vào (trước khi tạo ảnh):**
- [ ] PR #72 HEAD mới nhất, `AGENTS.md`, SOP V4, art-director skill, sprite-layer pipeline, trường phái playbook/ledger đã đọc.
- [ ] Có canonical skill ID/effect/shape/cap/cast/duration; các unknown ghi `RUNTIME_MAPPING_PENDING`; lập 3 clocks.
- [ ] Viết một câu về hình tượng khác các skill còn lại; xác định cue/anchor/phase/status; kiểm quyền reference.

**Mỹ thuật (STOP trước clip dài):**
- [ ] Source isolated RGBA **gốc**, pose thực khác nhau, alpha mịn, hero rõ ở native 1×, giữ nguồn bền vững.
- [ ] 3 ảnh **Godot 4.7.2 native 1280×720** ở charge/peak/contact với quái **đang di chuyển** (hoặc mốc thay thế có giải thích nếu passive).
- [ ] G3.6 không mờ, G3.7 che HUD vẫn hiểu chiêu, không sticker, không che mặt, effect đúng số mục tiêu; tự chấm ≥4/5 các tiêu chí art trọng yếu.

**Kỹ thuật/duyệt:**
- [ ] G4 target/anchor/decoy/expiry đúng; G5 clip thật attack→fade, sustained-state test riêng và ≥12 meaningful checkpoints khi phù hợp.
- [ ] V4 packet→assets→evidence, focused test, exact-SHA CI; nếu không chạy, ghi `NOT_EXECUTED`.
- [ ] Chủ dự án quyết định riêng art theo **revision**; ghi cả các phase được giữ và nợ polish, KHÔNG đổi bản đã duyệt.
- [ ] PVE/thiết bị còn HOLD nếu chưa có lệnh G8 và kết quả vật lý. Không rig, không GIF mặc định, không Codex, không branch mới, không merge, không sửa gameplay ngoài phạm vi.

## 10. NGUỒN CỐT LÕI — GIỮ LIÊN KẾT, KHÔNG COPY THÊM BÁO CÁO TRÙNG

**Thẩm quyền:** [AGENTS.md](../../AGENTS.md) · [Art-First SOP V3 + V4](TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md) · [Sprite-layer pipeline](TMB_VFX_SPRITE_LAYER_PIPELINE_20261114.md) · [V4 validator / packet](vfx_packets/README.md) · [Art Director](../../.agents/skills/tmb-vfx-art-director/SKILL.md) · [Status proposal](../design/TMB_COMBAT_STATUS_VFX_36_BRANCHES_STANDARD_V1_PROPOSAL_20261117.md).

**Nguồn các tuyến:** [Quyền Tu full report](VFX_FIST_SCHOOL_CONSOLIDATED_HANDOFF_20261118.md) · [FIST status CSV](vfx_school_ledgers/FIST_HUMAN_REVIEW_SNAPSHOT_20261118.csv) · [Độc Tu full report](TMB_VFX_AREA_PRODUCTION_REPORT_AND_HANDOFF_20261118.md) · [POI JSON](TMB_VFX_AREA_HANDOFF_INDEX_20261118.json) · [PAF01 R6](vfx_packets/PAF01_R6_ILLUSTRATED_WIND_SEAL_20261116.md) · [PAF05 R5E](vfx_packets/PAF05_R5E_OWNER_PROVISIONAL_CHARGE_DEBT_20261117.md) · [FIST12 R6 failure postmortem](FIST12_R6_PROCESS_FAILURE_POSTMORTEM_20261117.md) · [JX research](JX_VLTK_VFX_IN_GAME_PREVIEW_R1_20261117.md).

**Giới hạn xác minh:** Tài liệu này tổng hợp các báo cáo và nguồn GitHub đã đọc, không tự xem lại từng native MP4 cho mọi skill hoặc tự xác nhận từng lời duyệt trong toàn bộ lịch sử; các mâu thuẫn được để nguyên cờ đối soát. Đây là *hướng dẫn triển khai phương pháp và checklist*, **không phải chứng nhận đã hoàn thành kỹ năng**.

---

**BẤT BIẾN:** Draft PR #72, **không merge**, **không thay gameplay/Combat V2/SaveService/AI/economy**, **không bật V6.3/PvE**, **không rig**, **không GIF trừ khi được yêu cầu rõ**, **không sao chép tài sản JX/Võ Lâm chưa có phép phát hành**, **không sửa lén art/phase được chủ dự án chấp nhận**.

## 11. 19/11/2026 — Bổ sung thực hành từ GitHub (KHÔNG thêm SOP mới)

**Mục tiêu:** thực thi đúng Art-First V4 với chi phí thấp; học **kỹ thuật phụ trợ** từ repo open source, **không lấy particle/shader code làm hình tượng chiêu thức chính**. Nghiên cứu README, mã nguồn và LICENSE công khai của 7 repo; đây là đánh giá tương thích định hướng, **chưa cài add-on nào vào game**. Trên dự án vẫn khóa Godot 4.7.2, PR #72 Draft, PvE/Combat V2 HOLD; không dùng Codex Cloud.

### Nguồn đáng tham khảo và mức độ áp dụng

| Repository / phiên bản tham khảo | Có thể học/tái sử dụng | Giới hạn và giấy phép |
|---|---|---|
| [Godot official 2D Particles](https://github.com/godotengine/godot-demo-projects/tree/b761b4cd5718a7118f2c95eb55f181d0a5f004f1/2d/particles) | `GPUParticles2D` + `ParticleProcessMaterial`, birth/death, velocity/damping, lớp phụ | MIT. Demo Godot, kiểm Compatibility/Mobile thực tế; chỉ lớp tia/bụi/ánh sáng, KHÔNG thay master tranh |
| [GDQuest Visual Effects](https://github.com/gdquest-demos/godot-visual-effects/tree/647a8f1bcecd0b8634f2abe045abb8433b3b3149) | Explosion, laser, ghost trail, tổ chức effect theo thư mục độc lập | **Code MIT, art CC BY-NC-SA 4.0**. Không nhập sprite/texture art cho game dự kiến thương mại. Demo cũ có thể không tương thích Godot 4.7.2, học mô hình, không copy plugin không kiểm tra |
| [GDQuest Godot 4 VFX Assets](https://github.com/gdquest-demos/godot-4-VFX-assets/tree/f6034a88877f6ea144ae487694cc8fde82d4da7f) | Node/shader/material tổ chức VFX | Tách **code MIT** và **art CC BY-NC-SA 4.0**; reference-only với asset |
| [REEBOO Stylized 2D VFX Lite](https://github.com/REEBO0/godot-stylized-2d-vfx-lite/tree/0fb078c21e463fe16e93ee25dbb8ca970196e2d3) | Hit spark, slash, mini explosion, auto-free, **`impact` signal** | MIT; Godot 4.4+ (README), thử Godot 4.7.2/Compatibility. Chỉ mượn kỹ thuật nổ điểm chạm, không thay central painted motif |
| [REEBOO Sprite Juice Kit Lite](https://github.com/reeboolabs/sprite-juice-kit-lite/tree/d5ef9a0b4260d9fba505549339d924ff8cd70c3c) | White hit flash, camera trauma, hit-stop ngắn | MIT; **hit-stop phải gắn receipt thực** và QA gameplay/Android riêng. VFX LAB chỉ được xem mô phỏng, không sửa `Engine.time_scale` gameplay |
| [Godot Effects Lab 4.7](https://github.com/PSCactux/godot-effects-lab/tree/6af3c856ad8745a655121d11d55a60a03201a145) | One-scene-per-effect, 2D hit/flash, GPU particles, shader, công cụ capture thật / headless smoke | MIT; 4.7+ gần phiên bản dự án, repo nhỏ/tham khảo. Source có code-drawn effects; **không coi hình học procedural là master art** |
| [GODOT-VFX-LIBRARY](https://github.com/haowg/GODOT-VFX-LIBRARY/tree/6e8fc84ef426f82f747cd540823e1d5e1fdc563a) | Tham khảo kiến trúc thư viện 35+ particles, 17+ shaders và manager | MIT; 4.5+ (README); không import nguyên add-on và singleton nặng khi existing LAB/shared renderer đã có giải pháp |

**Bản quyền:** Luôn xem LICENSE **từng loại file**, giữ copyright/attribution khi thực sự sao chép mã MIT. Không copy sprite Võ Lâm/Kiếm Thế, art GDQuest CC BY-NC-SA hoặc asset thương mại chưa có phép. Chỉ nghiên cứu kỹ thuật và tạo nguồn tranh nguyên gốc cho từng skill.

### Cải tiến thực thi nhỏ, không tăng số gate

1. **G0–G2:** contract đúng, đối chiếu clip *cùng loại chuyển động* (quyền dùng quyền, không suy timing từ Kiếm Tu). Đầu ra 1 câu semantic motif + 5–6 phase (hoặc theo loại skill), 1 source-rights note. Không poster, không slideshow.
2. **G3 nhanh và cứng:** tạo trước **master RGBA tranh nguồn + pose biến đổi thật**; dùng **`tools/vfx/prepare_g3_source_review.py`** tạo contact sheet **SOURCE ONLY** tối/sáng ở **đúng bề rộng motif dự tính ở 1×** và SHA của nguồn. Nhìn trực tiếp silhouette/chất liệu/morphology/alpha. **Bị ART_SELF_FAIL → dừng ngay**, sửa chỉ source; không scene, Actions hoặc video. Script không chấm điểm đẹp và không thay native Godot G3.5.
3. **G3.5 đúng lúc:** chỉ khi art preflight tự đánh giá phù hợp mới dựng LAB tối thiểu. Tái dùng shared renderer+packet+runner hiện tại, **3 khung native** charge/peak/contact, so tối/sáng với một phiên bản owner đã thích. Nếu xấu → sửa G2/G3, không shader-bù.
4. **G3.6/G3.7/G4–G7:** chỉnh alpha/độ rõ, semantic không tên skill, actor thực sự ra quyền (sprite **frame-by-frame, không rig**), va chạm khớp 1 target/receipt, rồi G5 video **ngắn attack→fade**; sustain/expiry dài dùng mốc tĩnh hoặc test, trừ khi motion thực sự cần dài. Chỉ một full-video round khi source+native 3 khung đã ổn.
5. **Tái sử dụng 2 tầng:** **(A) art riêng theo skill:** master, phase keyposes, viền năng lượng, dấu riêng. **(B) shared engineering:** Atlas pack, layered body MIX + small ADD, particles, impact spark, event/camera feedback **chỉ khi đã được ủy quyền**, renderer, QA. Không sao chép một khối sáng rồi chỉ đổi màu cho 36 nhánh.

**Chặn lãng phí CI tại nguồn:** Đã bỏ các path `fist14/r6_luminous/**` khỏi **push-trigger** của `.github/workflows/vfx-shared-skill.yml`. Điều này chỉ ngăn workflow chung tự quay native cho **R6 đang ART_SELF_FAIL** sau mỗi sửa tranh; **`workflow_dispatch` với packet FIST14_R6 vẫn hoạt động** khi kiểm tranh đã đủ tốt, và bộ runner/tính năng capture không thay đổi. Thay đổi shared runner vẫn có CI theo path hiện hữu. Không tự động nâng owner art status.

**Ví dụ lệnh source-only** (thay tên file, `--motif-width` bằng kích thước thật định dùng trong scene):

```bash
python3 tools/vfx/prepare_g3_source_review.py \
  --source godot/labs/combat_lab/fist14/<revision>/source/charge.png \
  --source godot/labs/combat_lab/fist14/<revision>/source/peak.png \
  --source godot/labs/combat_lab/fist14/<revision>/source/contact.png \
  --motif-width 155 --out /tmp/fist14_g3_source_review.png
```

**Ý nghĩa file:** Contact sheet là bản so nguồn *trước Godot*, không được ghi `G3.5_NATIVE_PASS`; cần nhìn kích thước motif trước khi cam kết 1× thực. File PNG/JSON và asset master là hai thứ khác nhau. Master art bản được chọn phải được commit độc lập và lưu provenance bền vững, không để GitHub Actions artifact là nguồn duy nhất.

**Đầu ra nghiệm thu hợp lệ:** `SOURCE_ART_G3_SELF_PASS/FAIL`, `G3.5_NATIVE_TECH_PASS/FAIL`, `G3.6/G3.7`, `OWNER_VISUAL_APPROVED/PENDING/REWORK`, `PVE_HOLD`. Các trạng thái **không suy ra nhau**. Năng lực mỹ thuật không tự tăng do thêm thư viện. Không thêm batch QA vô ích và không tự động mở G8.

## 12. OWNER FINAL VFX LOCK — 19/11/2026 (ALL VFX CHATS)

**ĐÃ CHỐT** trên PR #72: mọi chat Quyền Tu/Độc Tu/Phù Tu và VFX các môn phái khác dùng chung **Art-First Production System V4**. Không thay SOP bằng quy trình khác, không Codex Cloud, không rig/GIF mặc định, không sửa gameplay/Combat V2/SaveService, không merge.

**Năm nhịp, giữ đầy đủ gate chính thức:**
1. **G0–G2:** kiểm HEAD và chủ sở hữu file; skill ID/effect/shape/target/cast/3 clocks; nghiên cứu chuyển động *cùng loại kỹ năng* và quyền sử dụng; một hình tượng riêng có storyboard thật.
2. **G3 — HARD STOP:** minh họa **master RGBA nguyên gốc** và nhiều pose biến hình/ánh sáng thực chất, lưu source+provenance trên GitHub. Tạo bản xem source-only trên nền sáng/tối, kích cỡ motif dự kiến 1× bằng `tools/vfx/prepare_g3_source_review.py`. Không bắt phải lập trình scene để biết tranh xấu. Nếu không rõ, giống icon, poster crop, khối Bézier/neon hoặc alpha mờ → `G3_ART_SOURCE_FAIL`, sửa nguồn **trước** QA. Code/shader chỉ tạo lớp phụ, không thay hero art.
3. **G3.5–G3.7:** từ nguồn đã có chất lượng mới dựng mini LAB Godot 4.7.2, xuất 3 khung **native** 1280×720 (charge/peak/contact) trên địch đang di chuyển; so nền sáng/tối và xem ẩn HUD có hiểu đúng chiêu, không che mặt, thấy nguồn→tiếp xúc→hồi lực; thất bại quay G2/G3.
4. **G4–G7:** animation frame-by-frame **không rig**, lớp MIX chủ thể/ADD ánh sáng mềm, reuse Godot renderer & QA shared; chỉ quay MP4 đủ diễn biến attack→fade **khi đã qua art source + 1×**, status dài test lifecycle riêng; kỹ thuật exact-SHA và chủ duyệt nghệ thuật **tách nhau**. Không quay full movie lặp đi lặp lại để cứu source FAIL.
5. **Owner → G8:** duyệt theo **đúng revision và các phase**, không phá bản approved/provisional; PvE/device/Combat V2 receipt chỉ khi owner cấp phép riêng. Toàn bộ các chat khác phải áp dụng khóa này trước khi sửa và cập nhật school handoff theo đúng trạng thái.

**Benchmark owner-approved:** **POI15 Hóa Độc Tán R1B**, phản hồi “ok đẹp t thích. tiếp tục skill tiếp theo” (17/11/2026), exact SHA `1b40811248fcaca9b33a5e4cbc35e8b03e2ca9b5`, [native Godot 7,5s Actions #43999563772](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43999563772), [artifact #14292200693](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43999563772/artifacts/14292200693), [owner decision](VFX_POI15_HOA_DOC_TAN_R1_20261117.md). Dùng làm chuẩn nhịp, độ trong, màu ánh sáng và kiểm mark/fade, **không sao chép mô-típ Độc Tu**. Bảo quản art R1B bất biến; artifact Actions hết hạn được tái xuất từ nguồn bền vững.

**Nguồn học GitHub ở §11** hỗ trợ hit spark/trail/particle/QA; GDQuest art CC BY-NC-SA không phù hợp nhập vào game thương mại. Không đưa nguyên thư viện vào repo chỉ để làm một hiệu ứng; ưu tiên thư viện kỹ thuật dùng chung. Một người chỉnh shared files, các trường phái chỉnh đường dẫn sở hữu. Không thêm SOP hoặc biểu mẫu lớn. **Đây là quyết định quy trình, không phải kết quả art-pass của FIST14 R6.**

