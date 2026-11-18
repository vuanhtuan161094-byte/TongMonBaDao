> **OWNER FINAL LOCK · 19/11/2026 — BẮT BUỘC TẤT CẢ CHAT VFX/12 MÔN PHÁI.** Đây vẫn là SOP duy nhất (**Art-First Production System V4** + V4.3), không lập quy trình cạnh tranh. Xem [AGENTS.md](../../AGENTS.md) và [cross-school §12](TMB_VFX_CROSS_SCHOOL_LESSONS_AND_EFFICIENT_WORKFLOW_20261118.md#12-owner-final-vfx-lock--19112026-all-vfx-chats): G0–G2 chốt motif; **G3 illustrated master RGBA + pose biến đổi thực, duyệt source ở 1× trước scene/CI, G3 FAIL = STOP**; G3.5 native Godot 1280×720 3 khung trên target WALK; G3.6–G3.7 tương phản/ngữ nghĩa; G4–G7 motion/QA; owner duyệt revision riêng, G8/PvE HOLD. **Mẫu được duyệt:** [POI15 Hóa Độc Tán R1B Godot native](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43999563772), exact SHA `1b408112`, học chất liệu và nhịp *không sao chép hình tượng*. Không Codex Cloud, rig, GIF mặc định hay merge.

> **ADDENDUM G3.7 (17/11/2026) — SEMANTIC SILHOUETTE / NGỮ NGHĨA CHIÊU THỨC, BẮT BUỘC SAU G3.6.**
>
> Lý do: POI16 R1E đã đủ sáng và rõ nhưng owner xác nhận hình thù "quá mức vô nghĩa", không biết nhìn thấy chiêu gì. **Màu đẹp, RGB alpha, glow, source provenance, Godot/G3.6 PASS KHÔNG THAY THẾ tính nhận diện.**
>
> **Trước khi sản xuất sprite:** chốt *một hình tượng skill dễ đọc* (nguồn, ấn/chủ thể, hình biến đổi, đích nhận, dấu kết quả). Viết rõ **"người chơi sẽ nhìn thấy gì → hiểu cơ chế nào"** mà không dựa vào text/UI. Không vẽ 5 vòng tròn/vệt quang ngẫu nhiên hoặc icon cứng dán lên nhân vật; phải kết hợp **semantic silhouette có hình** với **vật liệu linh lực thuần màu RGBA mềm**.
>
> **G3.7 kiểm thử trên video Godot 1280×720 1×:**
> (i) che tên skill và HUD rồi tự xem tại 1× có đoán đúng *loại chiêu* (heal/poison/cleanse/guard/attack) không;
> (ii) nhìn rõ *nguồn → hành trình → mục tiêu → kết quả*, với hướng/đích bám theo nhân vật/quái DI CHUYỂN;
> (iii) riêng AoE/truyền hiệu ứng: số nhánh/nút ấn phải đúng target_limit, không tạo cảm giác đánh nhầm đồng đội/nhầm quái;
> (iv) hình tượng phải khác nhau giữa các skill kể cả khi cùng màu hệ phái; không tái dùng một đám sáng rỗng hoặc vòng HUD cho mọi kỹ năng;
> (v) **không phóng quá to** rồi nhận đẹp: tự xem hình thực ở kích thước game, cùng bối cảnh tối/sáng, overlay nhân vật và 6v8 khi có QA được ủy quyền.
>
> Chứng cứ: khung native charge/peak/contact, ảnh/phân cảnh góc nhìn 1× không có tên skill, bảng motif→ý nghĩa, source attribution, số mục tiêu và target trajectory. Bài test CI có thể bảo vệ *cấu trúc hình tượng* và ba nhánh theo anchor thật, nhưng **KHÔNG tự động nhận PASS chủ quan**. Owner quyết định \`OWNER_SEMANTIC_ART_APPROVED\`; nếu bị đánh giá "vô nghĩa", \`ART_REWORK_REQUIRED\` dù V4+G3.6 PASS.
>
> **Ví dụ POI16 R2**: ba lá linh dược → ba luồng truyền sinh khí khớp vị trí ba đồng đội → ba ấn dược nhỏ biến mất; không thêm HP receipt thực, không giữ buff, không dùng GIF/rig.

> **ADDENDUM 17/11/2026 — VFX G3.6: KHẢ NĂNG NHÌN THẤY Ở 1× BẮT BUỘC.**
> Bài học **POI16 R1B**: Godot import/parse/contract/source RGBA đều PASS nhưng chủ dự án gần như **không nhìn thấy hiệu ứng**. Audit atlas alpha khác 0 ghi nhận *median* charge **8/255**, bloom **20/255**, blessing **9/255**; ảnh Godot 1280×720 tụ lực chỉ khoảng **79 pixel xanh sáng** theo bộ lọc ROI, không đạt khả năng đọc ở 1×. Đây là lỗi production-level, không thể lấy CI PASS để bào chữa.
>
> **Quy trình bắt buộc mới G0→G3.5→G3.6→G4–G8** (sau khi dựng scene có ảnh native thật):
> 1. **Material separation:** source phải thể hiện rõ *HOT CORE* ngọc trắng (~alpha cao), *COLORED ENERGY BODY* jade/cyan/kim vừa đậm, *SOFT HALO* mới thật trong; alpha thấp liên tục trên tất cả pixel làm toàn chiêu biến mất. Giữ RGBA gốc/alpha0 ở nền, không biến thành sticker/SVG/geometric UI hoặc hình vuông đục; thêm/mix ADD chỉ tại lõi nhỏ, tránh cháy trắng.
> 2. **G3.5 sớm, trước full movie:** chụp ba ảnh native 1280×720 t=charge/peak/contact trên nhân vật/quái đang di chuyển; xem **1×** (không chỉ zoom), cùng ảnh tham chiếu owner-approved. Kích thước nhân vật, mặt, target, contact và hướng năng lượng phải nhìn thấy ngay; nếu 1× không thấy: **STOP ART REWORK** trước khi quay hàng trăm frame.
> 3. **G3.6 độ nổi đo trên ảnh thực:** bắt buộc có *screen-space native brightness/contrast* probe cho các vùng charge/peak/contact/fade so với idle/expired; loại metric ngưỡng và ROI phải được xác định theo màu, bố cục và map **của chính skill** (không áp một ngưỡng xanh cho 12 môn phái). Ghi số vùng ảnh đủ sáng, độ tương phản và alpha; **fail kỹ thuật** nếu gần như vô hình. Ví dụ POI16: \`tools/qa/check_poi16_native_visibility.py\`. Đây là *minimum visibility check*, không tự chấm mỹ thuật PASS.
> 4. **MOTION/FPS & crowd test:** kiểm tra nén PNG, crossfade alpha nhân trọng số hai frame, render layer trước/sau nhân vật, vật liệu ADD cục bộ; đo đọc rõ ở tỉ lệ 1× khi có **3 mục tiêu di chuyển**, không che mặt và không làm lóe quá mức trong cảnh nhiều đệ tử. Màn sáng và màn tối phải được nghiệm thu thủ công qua native Godot trước khi phát hành; stress 6v8/30 đệ tử+40 quái và Android vật lý vẫn PENDING nếu chưa làm.
> 5. **Cổng art tách biệt:** Technical PASS + visibility PASS = ứng viên **owner review**, **không đồng nghĩa đẹp**. Owner chê “mờ, không thấy gì” → \`ART_REWORK_REQUIRED\`, không qua skill kế, không merge/PvE. Giữ source và video phiên bản cũ theo exact SHA. Không GIF, không rig.
>
> G3.6 phải được thêm vào cả skill ledger/handoff và CI của các skill mới. Bản R1B POI16 không qua G3.6; R1C cần qua Godot và cho chủ dự án duyệt lại.

> **CURRENT VFX PROCESS RULE (16/11/2026):** mandatory Production System V4 addendum at the end of this SOP. Every VFX school/chat must apply explicit timeline contract, motion-derived sprite frames, early 3-frame native Godot preflight, moving-target hit review, separate art/technical/owner gates, durable asset source. This augments existing G0–G8; read before using older estimates or fixed 8–12-frame examples.

# TÔNG MÔN BÁ ĐẠO — VFX ART-FIRST / ONE SKILL AT A TIME — SOP V3
## Hiệu chỉnh dự báo sau phản hồi ngày 14/11: không mặc định 14–21 tháng

Người dùng ghi nhận **3 kỹ năng được duyệt trong một buổi sáng** (cùng hệ Độc Tu). Đây là tốc độ quan sát được trên một buổi, nhưng **chưa phải năng suất bền vững toàn 12 hệ**. Dự toán chính phải tính theo **buổi sản xuất có sản phẩm owner-approved**, không quy đổi cứng sang lịch nếu không có lịch làm việc.

- Còn 201 Human cast-family masters chưa được duyệt. Nếu giữ 3 master/buổi thì khoảng **67 buổi làm việc**. Nếu đạt 2/buổi: **101 buổi**. Nếu 1/buổi: **201 buổi**. Chưa tính tier, passive/event VFX thật, tích hợp PvE và QA thiết bị.
- Ví dụ giả định làm đều **5 buổi/tuần**, cơ sở phần master sẽ là khoảng **13–40 tuần (3–9 tháng)** khi hiệu suất nằm trong 1–3 kỹ năng được duyệt/buổi. Thực tế nhiều môn phái đặc thù khó hơn Cổ Độc; cần đo lại sau 10 master tiếp theo.
- Vì thế bảng 12–29 tháng phía dưới là **kịch bản nhân lực chậm theo tuần của bản dự báo cũ, không phải mục tiêu chính**. Kế hoạch thực thi ưu tiên kết quả/phiên, điểm QA và chất lượng; tuyệt đối không tăng nhịp bằng cách đổi màu hàng loạt.


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
| G5 — Motion review | Xuất genuine MP4 1280×720 cùng PNG/ZIP kiểm tra, 8+ ảnh mốc. Xem cả motion và 1× trên nền tối/sáng; tìm lỗi đường bay, quấn, head-tail, mặt, va chạm và fade | Tự sửa/render lại cùng skill đến khi không còn lỗi mỹ thuật dễ thấy |
| G6 — Rubric mỹ thuật | 8 tiêu chí: silhouette, chất liệu/ánh sáng, chuyển động, bố cục, contact, fade, nét riêng, đọc rõ/performance. Các tiêu chí nghệ thuật 1–7 tự chấm **mỗi mục ≥4/5** trước khi gửi | Không qua nếu có silhouette SVG phẳng, glow vòng, fake hit hoặc che mục tiêu |
| G7 — QA và chủ duyệt | Godot strict import/parse/contract exact-SHA run, movie thật, logs, hashes, 8+ phase frames, bản tóm tắt lỗi đã sửa. Owner xem actual animation và duyệt | Nếu owner chưa duyệt: OWNER_VISUAL_PENDING; chê: ART_REWORK_REQUIRED quay lại G2–G6; **không chuyển skill kế** |

**G8 — riêng sau khi được ủy quyền:** diễn giải tier A/B/Divine, nối real Combat V2 receipts, stress 1v1 → 3 mục tiêu → 6v8 → 30 đệ tử/40 quái, Windows/Android vật lý và pháp lý. Chủ duyệt LAB KHÔNG cho phép bật PvE/V6.3.

## Gói thành phẩm mỗi kỹ năng
- Packet nguồn: đúng ID, bản sắc kỹ năng, tên/tier, effect/shape/cap, reference + quyền sử dụng, storyboard.
- Sprite/atlas gốc có alpha chuẩn, đủ hoạt ảnh, anchor và layering, scene/script Godot riêng; không rig.
- Video MP4 Godot thật 1280×720, GIF xem nhanh, ZIP, 8–12 phase PNG, tên SHA/run và báo cáo tác phẩm; không giao riêng ảnh concept.
- Art rubric, những lỗi đã sửa theo timecode; ghi **owner gate** và **PVE gate** tách biệt.

## ADDENDUM 16/11/2026 — G3.5 CONCEPT → GODOT VISUAL FIDELITY GATE (MANDATORY)

Trigger: Owner-provided Hỏa Phù visual benchmark vs actual HF02 R4. Read the [root-cause audit](TMB_HF02_ART_FIDELITY_FAILURE_AUDIT_20261116.md). A superb ImageGen concept/poster may look nothing like the runnable VFX if its main incandescent artwork is replaced by tiny cutout fragments, procedural tubes and normal-alpha translucent drawings. **Do not present a concept poster claiming Godot/FPS as proof of native render.**

**Mandatory STOP before G4:**
1. Retain a **full-size, independently owned high-resolution transparent hero master** for the main moving energy shape. An 80×65 concept fragment enlarged/duplicated to cover the battlefield is **insufficient** as the primary hero art.
2. Present a **source-art frame contact sheet** (8–12 genuinely changing painted poses), explicitly identify core/colored fire/ambient bloom/contact/embers and actor occlusion. Unique byte hashes alone are not evidence of real artistic motion.
3. Match the owner's **high-saturation emissive energy**: small ivory-white hottest focal point, vivid yellow→orange→red body, clear dark gaps, independent carefully restrained ADD light and MIX opaque material. Do not flatten vivid fire into dark translucent orange or enlarge uniform radial halos.
4. Produce an early **3-frame genuine Godot 1× proof** (charge / maximum skill / moving-actor contact). Visually compare with owner reference in equivalent crop/framing before 198-frame movie/CI. If shape looks like seven candles, wireframe, UI geometric rays or hidden targets: **reject primary art, return to G2/G3**. Raising scale, passing alpha or adding glow is not a fix.
5. Keep source exact name/ID/shape/cap; promotional art may contain fictional skills. HF02 canon: Liên Diệm Phần Giới, FIRE circle, cap3, projectile_speed0. Never copy extra flying hits from a poster.
6. Technical build/alpha/exact-SHA PASS remains independent from visual PASS and explicit owner approval. If the owner explicitly changes to another skill before approval, retain the previous skill as **ART_REWORK_REQUIRED**, not as accepted/final.

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

---

## ADDENDUM 16/11/2026 — VFX PRODUCTION SYSTEM V4 (CURRENT BINDING OPERATING RULE)

**Authority and rollout.** This section amends the existing SOP V3 and its G3.5 gate; it is not a competing process document. Read it together with AGENTS.md, the repo-scoped tmb-vfx-art-director skill, the school catalogue, the painted-asset gate, and the shared sprite-layer pipeline. All VFX school chats MUST apply it before new art, iteration, reviews, or handoff. Older 8–12-frame examples and phase lengths are examples, NOT universal quotas. Preserve previously owner-approved assets and frozen gameplay contracts. No rig, no Codex by default, no new branch/merge, no Combat V2, SaveService, AI, economy, PvE or V6.3 changes by this SOP.

### A. Audit diagnosis, traceable findings and remedies

| Root cause / evidence | Why it fails | Mandatory correction / gate |
| --- | --- | --- |
| Attractive concept poster is presented as production quality; HF02 audit identifies 80×65 source fragment and procedural seven-plume hero | concept fidelity is lost before engine rendering | compare original transparent full-size HERO sprite with reference at native display size before committing to animation (G3); keep licensed first-party source/provenance |
| Byte-unique atlas poses created by noise/rotation or uniform distortion | distinct hashes do not establish readable actual motion | key-pose silhouette contact sheet, growth/shape/head-tail/energy progression, loop/temporal review; hashes are integrity-only |
| Generic circles/glow and under-saturated composite | dull/blown out light, lost volume and school identity | distinct opaque MIX material, localized restrained ADD core, feathered atmospheric light, protected negative spaces; inspect on dark AND bright terrain |
| Native painted pixels positioned off palm/target (TAL02 R5→R6) | physically disconnected VFX despite excellent atlas | measure occupied-alpha bounds and screen-space hand/weapon/ground/contact anchors at native 1× |
| Timing in LAB authored independently of catalogue events (e.g. HF02 declared cast 0.62s, demo contact 1.37s) | convincing showcase may be late or misleading in real combat | timing contract sheet and event-aligned hit/receipt; never label a synthetic hit as runtime-confirmed |
| Self-review based only on 3 stills, encoded fps or automated atlas integrity | no proof of fluid motion, actor visibility, target following, or device performance | G3.5 three genuine Godot preflight frames to STOP early; later full video checked >=12 meaningful times plus continuous motion review and multi-target test |
| 14-day GitHub Actions artifacts are treated as stable output | source and approved revision become unavailable | commit or durable asset storage for source/master/release atlases; immutable manifest SHA and evidence URI; artifact expiry is never the only archive |
| Art approved verbally while ledger remains PENDING; code-green interpreted as art-green | bad revisions propagate or correct versions get overwritten | separate ART_SELF_QA, OWNER_VISUAL, TECH_QA, LIVE/PHYSICAL gates; update ledger only on explicit owner decision; do not overwrite approved source |
| Uniform fixed 8–12 frame quota and monolithic full movies for every iteration | under-animated long FX, bloated short FX, costly redo cycles | timeline-derived pose budget, cheap preflight STOP before full movie, increment revision on meaningful visual changes only |

Evidence: TMB_HF02_ART_FIDELITY_FAILURE_AUDIT_20261116.md, TMB_VFX_PAINTED_SOURCE_TO_GODOT_ASSET_GATE_20261114.md, TMB_VFX_SPRITE_LAYER_PIPELINE_20261114.md, sample LABs talisman02/talisman07/fist07/poison10. Findings are code/document audit, NOT an assertion that all rendered videos were re-watched.

### B. Mandatory VFX time contract — three independent clocks, no gameplay invention

Every skill MUST write a timeline matrix with canonical data and distinct laboratory assumptions:

- **Combat-authority clock:** skill cast_time, cooldown, projectile_speed, shape, cap, effect, duration, and actual runtime receipts (cast/start, cast/release, hit/guard/mark, expire). These fields have priority; candidate catalogue values remain gated and cannot be silently balanced from VFX.
- **Visual clip clock:** initial local VFX time, charge, anticipation, release, travel/formation, impact, sustain/status, residual light and cleanup. These are presentation choices attached to events; never apply damage, change hit counts, create a status or delay the actual combat command.
- **Showcase/video clock:** optional pre-roll, replay gap, slow inspection or demo target paths. These are QA-only; NEVER infer production cast timing from movie length or looping scene.

Timeline contract table required for each skill: event | source field/receipt | canonical or simulated | local time | visual start/end | anchor | target follow policy | confidence/owner approval. If the exact runtime receipt moment is unknown, write UNKNOWN/RUNTIME_MAPPING_PENDING and keep view-only. A zero projectile_speed field means no invented gameplay projectile; cosmetic unfolding must not imply additional damage hits. Travel distance / projectile speed must be checked in world units with the real integration coordinate mapping, never guessed from screen pixels.

**Timing audit examples (NOT established gameplay defects):**
- HF02 Liên Diệm Phần Giới: cast_time 0.62s, projectile_speed 0, LAB DEMO_HIT_AT 1.37s, FADE_END 2.62s, LOOP_SECONDS 3.30s. The +0.75s between cast boundary and simulated hit needs explicit reason and event-alignment review; do not treat demo hit as Combat V2 hit.
- TAL02 Thiên Lôi Dẫn Nét: cast_time 0.62s, projectile_speed 0, LAB clip roughly 3.13s including fade/replay. Align line/contact to actual event, not the finished MP4 duration.
- FIST07 Kim Cang Hộ Thể: cast 0.45s, canonical guard duration 4.0s; LAB protection 0.45–4.45s with .40s farewell fade. **4s persistent readable guard is not a 4s cast animation**; separate local block flashes from guard life.
- POI10 Độc Khí Phệ Tâm: cast 0.65s, projectile_speed 8, status duration 6s; LAB first hit at 1.47s, mark and 8.55s showcase loop. Until the world-distance and runtime event mapping are verified, its simulated travel and hit intervals are NOT validated gameplay timings.

**Indicative visual rhythm, never universal mechanical limits:** for common immediate damage, prioritize readable charge matching cast, contact accent near the confirmed hit event, quick peak (~0.06–0.20s) and short residual (~0.20–0.60s); extra cinematic tail should not block the next action. Ultimates may need a larger authored sequence and must be tested for readability in crowded combat. Persistent guard, mark, healing-over-time and summon cues follow their real status/actor lifecycle; they need not consume a full set of animated hero frames for each second. Choose actual timing from skill contract and visual review, NOT from these indicative ranges. If visuals occlude moving actors or overlap the next cast, shorten/recompose residual light rather than changing combat cooldown.

### C. Frame and art budgets derived from motion

Do not force every skill to 8–12 total frames. Define **key poses** (art-authored silhouette changes), in-betweens / timing holds, atlas/display FPS and layer loops independently. A static spell icon rotating/scaling with per-frame noise does NOT qualify as original frame-by-frame motion. Use a storyboard of roughly 5–6 action beats where applicable; 8–12 key poses is a useful initial drafting aid, NOT a pass/fail count. Short one-shot impacts might use 6–12 genuinely distinct pose frames; longer living light/animal/flame transformations often need 12–24+ where needed; long status cues can loop a small clean atlas and sustain without endlessly baking frames. These are initial production heuristics, not measured requirements or guarantees.

For every atlas report displayed duration, pose count, frame cadence, repeated/held frames, pivot/alpha, and why motion reads at **actual 1× gameplay size**. Assess motion continuity across adjacent frames, not SHA uniqueness alone. Maintain visual identity of each school, original first-party sprite source and independent effects (charge hero, principal energy, actor contact, grounding, ambient fade). Shader/particles remain optional aids; organic circular light bursts are allowed where skill-specific, but generic HUD-like mathematical rings are rejected.

### D. Mandatory progressive gates / STOP economy

1. **G0 Contract & ownership**: live PR HEAD, exact skill ID, catalogue values, visual-only scope, one-writer path, previous approved/rejected owner feedback; timing matrix with UNKNOWN fields.
2. **G1 Reference deconstruction**: 2–3 observed screenshots/actual frames for material, shape, motion, timing and target response; JX/Source VL external art is research-only, not copied into commercial assets. State observed vs inferred.
3. **G2 Motion direction**: distinct original silhouette, palette, focal core/body/falloff/negative space, 5–6 beats where relevant, storyboard and hand/weapon/target anchor + follow policy. Review 1× storyboard before baking.
4. **G3 Hero master**: independent authored high-resolution transparent first-party sprite(s), real key-pose changes, separated MIX body / local ADD / low bloom / impact / residue, original-source provenance and stable storage. NO RIG.
5. **G3.5 Visual preflight (hard STOP)**: bake tiny provisional Godot LAB before full render; capture real Godot 1280×720 at charge, main energy peak, and contact on a **moving target**. Compare same framing/native 1× against source art/reference; verify hot core, silhouette, anchor and occlusion. Flag MANUAL_ART_REVIEW_REQUIRED; automation may generate proof but cannot automatically certify beauty. Fail => return to G2/G3, not scale/halo patching.
6. **G4 Motion timeline & collision**: event-indexed visual player; stationary target, left/right moving target, multi-target mixed directions. Source/target anchor follow policy must account for moving enemies; no post-release tracking if skill is intentionally a fixed ground zone. Simulated effects CLEARLY labelled demo, never damage receipts.
7. **G5 Native full-motion review**: only after G3.5 art preflight passes by a documented self-review; export genuine Godot 4.7.2 Compatibility 1280×720 MP4 + ZIP/logs proof (GIF only on specific owner request), contact sheet >=12 phase/motion checkpoints (or documented fewer for a genuinely shorter clip) including immediately BEFORE/AT/AFTER hit. Watch continuous motion, not just stills; test dark/bright terrain and 1×, inspect target faces and layer order.
8. **G6 Art decision**: score silhouette, original material, color/light hierarchy, movement continuity, timing, moving-contact accuracy, occlusion/readability, fade, school identity each ≥4/5 as self-gate. Failing any critical category => ART_REWORK_REQUIRED. These are human assessments and cannot honestly be CI asserted.
9. **G7 Exact-SHA technical QA & handoff**: Godot strict import/parse/focused contract, alpha/atlas/integrity, no unauthorized gameplay changes, run ID, source SHA, emitted movie and 12-frame evidence, manifest with clip/receipt mapping and owner status. Technical QA may pass while art fails. Preserve full assets durably, not just a 14-day CI artifact.
10. **G8 Separate release authorization**: only explicitly approved skill art and separately authorized event integration/performance/device verification. Fixed 60fps movie is not measured Android/Windows FPS; unchanged V6.3/PvE gate.

**Efficiency rules:** self-review the 3-frame gate and silhouette before a costly full render; do not make release build for art known to be poor; repair one failed phase without repainting owner-approved content. Iterate on one skill until approval or explicit owner pivot; an explicit pivot does not transform prior rejected art into approved art.

### E. Throughput, production times and quality tracking

**Do not promise a fixed number of skills per day or estimate a wall-clock delivery time from a single pilot.** Three owner-accepted Human Poison skills in one morning is a one-session observation, not a validated per-skill SLA. The ~201 Human masters and separate passive/event cues, tiers, live integration and real device QA must not be conflated with 2,196 unique catalogue IDs. Estimate after 10 **new** owner-approved masters, stratified by simpler strike, long projectile, living creature and ultimate.

Record per skill: first-source SHA, source-art creation effort, storyboard/key pose count, G3.5 attempts, full render attempts, visual defect categories, artist iteration count, actual number of owner-approved masters per session, rejected/approved state and exact evidence. Record real elapsed effort only when observable; never invent timings. Optimize approved quality/rework cycles, not artifact counts or generated atlas numbers. Parallel independent school writers are allowed on disjoint files, but central SOP/AGENTS edits have one owner.

### F. Required handoff / school-chat compliance

Every VFX chat MUST independently read the live current **AGENTS.md → this SOP → .agents/skills/tmb-vfx-art-director/SKILL.md → TMB_VFX_SPRITE_LAYER_PIPELINE_20261114.md → school playbook → actual catalogue/ledger**, not copy a stale prior-chat summary. At the start of its work report checked HEAD and exact skill identity; at handoff report G0–G8 result, timing contract, self-score, visual preflight status, actual Godot evidence (or explicitly NOT EXECUTED), exact QA SHA, durable art source path, owner decision and PvE/device hold. For active work on distinct schools, record school-owned write paths; never make contradictory simultaneous global SOP writes. Update owner-approval ledger only from explicit owner statements and keep tier approvals independent. Changes to this central SOP do not themselves create a green CI result, apply to currently running sessions automatically, or publish assets.


### G5/V4.1 — POI11 R9 lesson: efficient QA clip versus persistent-state clock (OWNER ORDER 2026-11-16)

**Never equate an exported video frame with an authored sprite key pose.** POI11 R9 used 38 atlas poses in 4 sheets, but 660 encoded video frames were just 11.0 s of a fixed-60-FPS movie. Its primary action finished by roughly t=3.08 s; the rest showcased a separate small eight-second simulated poisoned badge and replay. Exporting the whole movie at every art revision wastes Actions minutes, review attention, storage, and iteration effort. **This is a test-workflow optimization, not a request to lower in-game FPS or degrade motion quality.**

**Default revised QA sequence (use motion-derived timings, never a hard 4 s cap):**

1. **G0 timing split:** declare the canonical cast/hit/status clocks, authored VFX charge/peak/contact/fade times, and the independent QA demo loop. UNKNOWN runtime hit receipt stays `RUNTIME_MAPPING_PENDING` and may not be guessed. Distinguish status from the attack artwork.
2. **G3.5 STOP:** after original full-size transparent source and authored poses, generate a short **true Godot 1280×720** capture that *includes* the three native proof frames at **charge / maximum energy / contact on an actually moving monster**, with a real movement/anchor focused test. Match 1× master silhouette and check alpha/background-square boundaries, white-hot core, pure color, occlusion, hand/target anchors and frame continuity. A numeric source-alpha test does not certify beautiful art.
3. **Attack-clip QA:** only after documented human G3.5 self-approval, export native Godot full-motion **from charge to attack fade** (for POI11 R9 approximately 3.08 s, so ~3.3–4.0 s incl. a small tail, ~198–240 video frames at fixed 60). **Never enforce these numbers on a longer or shorter skill.** Include ≥12 meaningful checkpoints when warranted, immediately before/at/after contact, full-speed continuous viewing, moving monster(s), bright/dark backdrop, alpha rectangular-matte and peak-frame contour checks. An accepted attack must not have sprite-sheet cropping, a visible rectangular/card boundary or face-obscuring impact.
4. **Persistent effects as independent test:** a poison, guard, summon, mark, heal-over-time or other long-lived **status** is NOT the active casting motion. Validate state icon/guard/etc. at start/mid/end and expiry using **2–4 exact-timestamp native screenshots or a focused duration/expiry test**, instead of rendering the entire sustained 8 s every single art revision. The LAB may mock state for visuals only; real Combat V2 state must drive it once integration has separate authorization. No fake damage, application receipt or arbitrary refresh rules.
5. **Combined long video only as needed:** produce 660-frame/11 s (or other full-cycle clip) specifically for *owner full-cycle review, duration bug reproduction, final regression, or release evidence*; do not make it the default every iteration. Continuous motion review is still mandatory for the moving attack, and any important state transition must be visually reviewed.
6. **G7 evidence & budget:** log separately `authored_pose_count`, `atlas_raw_rgba_bytes`, `attack_video_seconds`, `recording_fps`, `encoded_video_frames`, `status_probe_times`, `G3.5 native proof times`, exact SHA/run/artifact, self art vs owner gate, and regression decisions. Add a small comparison of Action runtime/artifact size when available; never invent wall-clock efficiency or FPS. Preserve image masters/atlas generator and approved revisions beyond artifact expiry. Test Android/Windows physical FPS and mixed 6v8/30x40 load before claiming performance suitability; compression, resource residency and layering need actual measurements.

**POI11 R9 acceptance precedent:** Human artistic `OWNER_VISUAL_APPROVED_R9` on 2026-11-16 and frozen art source [owner decision record](vfx_packets/POI11_R9_OWNER_APPROVAL_20261116.md). This *does not* waive G3.5, full motion, owner review, exact-SHA technical evidence or device/PvE HOLD on the next skill. SOP still forbids rigging, mass recolors, unlicensed sources, Codex-by-default, branch/merge and gameplay edits.


### G4/V4.1 SIMPLE DIRECTION POLICY — owner clarification 2026-11-16

**The game is intentionally not strict about four distinct painted skill angles.** For projectile VFX the mandatory visual requirement is simply: **fire toward the actual intended target, from an acceptable caster origin**, whether the actor currently faces Front/Right/Back/Left. Use a single original RIGHT-facing projectile atlas plus a 2D screen-space direction vector `(target_position - launch_position).angle()`; rotate only the flight sprite and its trail around their own pivot, and keep the impact anchored to the moving target. A 4-direction vector test (left/right/up/down) is sufficient for the reusable projectile orientation math; a special 4-angle video/pose inventory is **not** mandatory for all skills. Preserve face visibility, near-body alpha, and the previously accepted art. Some unique asymmetrical hand gestures might later justify direction-specific art, but they are optional polish, not a release-wide blocker.

**Scope & truthful gates:** this relaxation does NOT authorize arbitrary attacks being launched backwards, invented homing/real Combat V2 target receipts, fixed world-unit travel time inferred from movie pixels, rigging, or live integration. Screen-space LAB arrow tests are separate from actual PvE target mapping; Godot 1280×720 G3.5 native charge/peak/contact, exact-SHA technical checks and owner art review remain mandatory. This simple orientation rule supersedes earlier suggestions to demand four separate complete sets of skill sprites or 4-direction staged screenshot QA for every POIxx skill.


## V4.3 — NO GIF, DIRECT REAL GODOT VFX (LATEST OWNER OVERRIDE 16/11/2026)

The owner REVOKED the GIF-first workflow after testing it. **Never require or auto-create a GIF** for new/refined game skills, whether as a concept, eight-frame storyboard, output preview or video fallback. Earlier V4.2 and V4.2.1 are HISTORICAL/DEPRECATED and must not be used as production gates. No GIF is needed unless the owner explicitly requests one in a later separate instruction.

Workflow: G0 canonical skill contract and 3 clocks → G1 licensed references and original luminous VFX identity → G2/G3 independently painted **true transparent RGBA source masters**, distinct sprite poses and layered atlases (MIX colored body / small restrained ADD hot core and bloom) → G3.5 **actual Godot 4.7.2** native 1280×720 charge, peak and moving-target contact images + manual 1× aesthetic STOP → G4 path-to-target test incl. four cardinal vectors, moving contact and bright/dark backgrounds → G5 **short native Godot MP4** of whole active skill (length follows action, never a mandated 660 frames) + phase PNGs → G6/G7 visual owner decision and exact-SHA technical proof → G8 only separately authorized gameplay/physical QA.

**Poison normal attack tiers:** owner wants Human, Immortal and Divine visually evolving clearly, not recolors; sharp straight dart, vivid translucent saturated jade/light, minimal wobble, layered core and restrained single-target contact; higher tiers add independently authored silhouette layers, contact richness and distinct textures without additional gameplay targets or invented poison DoT. Source and technical PASS remain distinct from owner aesthetic approval. Preserve POI11 R9 approved art, Combat V2, SaveService, PvE/V6.3 OFF, no skeletal rig or branch/merge.


### V4.3.1 Art direction — translucent energy, not icon-like sprite (OWNER 2026-11-17)

The VFX production format remains source-preserved transparent RGBA sprite atlases, **but their appearance should read as living translucent light**, not hard 2D stickers/pictograms. POI13 R1's stylized leaf wings were **owner rejected**; R2 tests softened saturated RGB-at-partial-alpha jade/teal energy, floating particles and a small ivory medicinal core. Compose a wider low-opacity field **behind** the existing character sprite, the original actor in the middle, and narrower softly glowing light **in front**; ensure the scene and character remain visible through energy. This two-pass drawing is an art technique, NOT evidence of real healing gameplay or a rig. Avoid obvious rigid leaf/shield icons, cloned static posters, hard alpha cutouts, gray/opaque smoke, generic rings or excessive snake motion. RGB color should remain clean even when alpha is low. Check real 1x Godot 1280x720 on moving actor and both dark/bright backgrounds, not just source art PNG. **No GIF**; native short MP4 and charge/peak/contact screenshots only. Art owner gate always separate from green CI.
