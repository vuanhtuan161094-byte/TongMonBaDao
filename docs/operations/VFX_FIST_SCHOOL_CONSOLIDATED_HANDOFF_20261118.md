# BÁO CÁO BÀN GIAO VFX QUYỀN TU — TÔNG MÔN BÁ ĐẠO
**Bản:** FIST-SCHOOL-CONSOLIDATED-V1 · **Ngày chốt:** 18/11/2026 (UTC+7) · **Đơn vị bàn giao:** nhóm triển khai VFX Quyền Tu trong ChatGPT  
**Repo:** [vuanhtuan161094-byte/TongMonBaDao](https://github.com/vuanhtuan161094-byte/TongMonBaDao) · **Draft PR:** [#72](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72) · **Nhánh làm việc:** \`integration/pve-p0-playable-ui-20261103\`  
**Mục đích:** Chuyển thẳng vào GitHub để một chat khác tổng hợp **các môn phái**. Báo cáo này tập trung **Quyền Tu**; viện dẫn Phù/Độc/Võ Đang chỉ làm **phương pháp tham khảo**, không nhận công trạng/chốt nghiệm thu hộ các nhóm đó.

> **Đọc trước khi thống kê:** Có ba tầng hoàn toàn riêng biệt: (1) có scene/source, (2) Godot kỹ thuật PASS, (3) **chủ dự án duyệt mỹ thuật**. Không suy ngược (3) từ (2). Bản "tạm chốt" không đồng nghĩa final art hoặc đã vào PvE. Các nhận xét nghệ thuật trong tài liệu là **tự đánh giá** trừ khi ghi rõ quyết định người dùng. Báo cáo này chỉ tổng hợp tài liệu; **không thêm kỹ năng, sửa atlas/gameplay hoặc đổi trạng thái runtime**.

## 1. KẾT LUẬN ĐIỀU HÀNH (dùng cho chat tổng hợp)

- **FIST12 Đoạn Mạch Liên Quyền R10C:** chủ dự án **chọn/chốt tạm** để chuyển skill, giữ nguyên; Godot 4.7.2 kỹ thuật và G3.6 đã PASS. Bản R9 trước đó bị **loại về mỹ thuật**. Còn nợ quyền ảnh hơi giống hỏa khí, chưa có animation đấm actor frame-by-frame.
- **FIST13 Huyết Khí Hồi Lưu R7:** chủ dự án nhận xét **“tàm tạm”**, **giữ tạm**, không nên sửa lén; Godot kỹ thuật PASS. Vật liệu đỏ ruby và phản lưu còn cần làm giàu.
- **FIST14 Liệp Huyết Truy Đả R2:** có source/LAB, Godot QA và G3.6 **PASS**; **tự chấm mỹ thuật FAIL** vì còn giống ba vuốt/phẳng, không rõ là một quyền truy kích. **Không có duyệt owner**.
- **FIST15 Huyết Hải Quyền Vực R2:** có source/LAB, Godot QA và G3.6 **PASS**; **tự chấm G3.7 FAIL**: quyền giáng còn như chữ V/vệt sáng, vùng huyết hải chưa có chất liệu đủ tốt. **Không có duyệt owner**.
- Một số mốc lịch sử quan trọng: **FIST03 Thần Quyền V3** được chủ dự án “ok chốt” ở **mức hình tượng LAB** nhưng **không phải ID skill riêng** (dùng hợp đồng ultimate Bá Quyền làm demo); **FIST07 R6**, **FIST08 R1** được giữ **tạm**; **FIST10 R4** chỉ là **chuẩn phong cách GIF** được thích, **không được nhận là atlas Godot đã duyệt**.
- **FIST09 Trấn Sơn Hộ Đồng:** có phát biểu chốt từ owner ở hội thoại, nhưng lịch sử repo từng **reject R3**, đã chuyển R4/R5/R6; **chưa đối chiếu xong phiên bản nguồn R6 nào ứng với lần chốt**. Vì thế ghi **OWNER_DECISION_RECONCILIATION_REQUIRED**, không tự gắn nhãn “R3 final”, không hạ kết luận chủ dự án chỉ vì một tài liệu tự review cũ.
- **Quy ước debuff chung 36 nhánh hiện là đề xuất, chưa triển khai**. Không được tuyên bố đã có StatusPresentationNormalizer/atlas icon runtime. Không tạo 36 dấu ấn tồn tại lâu theo từng skill.

**Phạm vi luật đã giữ:** Godot 4.7.2 GL Compatibility, canvas QA 1280×720; frame-by-frame RGBA; **không rig, không GIF mặc định, không Codex, không tạo nhánh mới, không merge, không tự thay Combat V2, SaveService, AI, economy, PvE hoặc bật V6.3**.

## 2. KIỂM KÊ 15 CAST VFX NHÂN GIỚI — QUYỀN TU

**Phạm vi thống kê:** 3 nhánh × (4 active + 1 ultimate) = **15 canonical Human casts**. Ngoài ra 2 shared cast masters Human theo hệ đếm tổng = 17 Human casts/school. Con số 183 ID/school và 2.196 ID/12 schools là **số ID catalogue**, **không phải** số VFX được sản xuất. File ledger lịch sử \`docs/operations/vfx_school_ledgers/05_fist_183.csv\` hiện có nhãn \`NOT_ART_APPROVED\` chung; **không lấy nhãn legacy này để xóa các quyết định tạm duyệt có ngày gần hơn**. Danh sách snapshot để máy đọc: [FIST_HUMAN_REVIEW_SNAPSHOT_20261118.csv](../operations/vfx_school_ledgers/FIST_HUMAN_REVIEW_SNAPSHOT_20261118.csv).

| Mốc | Skill / nhánh | Phiên bản có bằng chứng / bản giữ | Kỹ thuật Godot | Quyết định mỹ thuật / chặn |
|---|---|---|---|---|
| **FIST01** | Khai Sơn Trọng Quyền · Bá Quyền | R9 QA; R10 được gọi “tạm tạm” trong bàn giao FIST02 | R9 PASS; R10 cần tra chứng cứ riêng | **Tạm dùng**, không final, không PvE |
| **FIST02** | Phi Thân Liên Cước · Bá Quyền | R4 source/scene, R1–R3 bị owner bác | R4 native QA PASS | **R4 owner pending**, không giả động tác đá |
| **FIST03** | Thần Quyền · *tên concept*, ref Sơn Hà Chấn Thiên ultimate Bá Quyền | V3 source \`d631b1f2...\` | PASS | **Owner accept visual LAB V3**; **không có skill ID “Thần Quyền” riêng** |
| **FIST04** | Lôi Đình Chấn Quyền · Bá Quyền | V3 native QA | PASS | **Art polish pending**, source crop đã feather, contact còn nông |
| **FIST05** | Địa Mạch Liên Chấn · Bá Quyền | V10 native QA | PASS | **Owner pending**, lỗi đá rơi/tàn dư đã sửa một phần |
| **FIST06** | Trấn Địa Quyền · Kim Cang | R3 native QA | PASS | **Art self-rework**, nắm đấm còn dạng icon |
| **FIST07** | Kim Cang Hộ Thể · Kim Cang | R6 **giữ tạm** | R5 QA có PASS; R6 nguồn/đánh giá theo hồ sơ FIST08 | **Owner provisional**, nợ phản lực chặn và dấu bảo vệ 4s |
| **FIST08** | Phản Chấn Quyền · Kim Cang | **R1 owner-selected**; R2 bác bỏ | R1 PASS | **Owner provisional**, **không thay R1 bằng R2** |
| **FIST09** | Trấn Sơn Hộ Đồng · Kim Cang | R3 native archive, R4/R5/R6 rework tiếp | R3/R4/R5 có CI PASS | **Phiên bản owner chốt cần đối soát**; tuyệt đối không gọi R3 art-approved |
| **FIST10** | Bất Động Kim Chung · Kim Cang | **R4 visual reference** | **R4 GIF không phải Godot proof** | **Owner liked style only**; runtime visual pending |
| **FIST11** | Huyết Liệt Quyền · Huyết Quyền | R1/R2 xây nguồn fist, R1 native proof | R1 PASS, R2 cần đối chiếu riêng | **Không có owner final**, còn cần xem art |
| **FIST12** | Đoạn Mạch Liên Quyền · Huyết Quyền | **R10C giữ tạm**; R9 rejected | **R10C V4/G3.5/G3.6 PASS** | **Owner provisional**, hero source còn dẫn xuất |
| **FIST13** | Huyết Khí Hồi Lưu · Huyết Quyền | **R7 giữ tạm** | **R7 PASS** | **Owner provisional**, mỹ thuật chưa hoàn thiện |
| **FIST14** | Liệp Huyết Truy Đả · Huyết Quyền | **R2 review only** | **R2 V4/G3.6 PASS** | **G3.7 art self-FAIL**, chưa có owner pass |
| **FIST15** | Huyết Hải Quyền Vực · Huyết Quyền | **R2 review only** | **R2 V4/G3.6 PASS** | **G3.7 art self-FAIL**, chưa có owner pass |

**Chú thích kiểm đếm:** FIST03 là **alias LAB** của canonical Human Bá Quyền ultimate, không được cộng thêm một skill thứ 16. Các bản chỉ có reference GIF/ảnh **không** được tính đã có native gameplay animation. Các cấp Immortal/Divine và passive/event VFX **chưa thể suy ra hoàn tất** từ Human.

## 3. CÁC MỐC KỸ THUẬT CÓ THỂ TRUY VẾT

| Skill | Chính xác mã nguồn làm bằng chứng | Actions thực / phân biệt phiên bản | Nội dung đã chứng minh |
|---|---|---|---|
| FIST03 V3 | \`d631b1f2fcc3d92f08029bb9333e5e03bcad1987\` | [#43617223374](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43617223374) | true Godot LAB, 40 pose, 1280×720; owner LAB visual accept |
| FIST04 V3 | \`e882d8cfaf597b6f9b2fde4eb787d83aa2eaba9b\` | [#43621961923](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43621961923) | Godot+frames pass, chưa art final |
| FIST05 V10 | \`851fe7127ad5424dbf35af441ccd0e5f25d222c3\` | [#43691361904](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43691361904) | đá rơi/đọng tàn dư, native movie |
| FIST06 R3 | \`47de774d72fdf4755fe9347becd79cfd990fdcd7\` | [#43712827253](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43712827253) | native technical, self art <4/5 |
| FIST07 R5 | \`0c32073f72010b0fa3c933123613d8b64e81e5b2\` | [#43799366518](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43799366518) | kỹ thuật qua, R6 owner provisional ở hồ sơ sau |
| FIST08 R1 | \`4fea05b537ec8a46f79605365da0df9f088103bf\` | [#43810074259](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43810074259) | **giữ R1**, R2 owner reject |
| FIST09 R3 archive | \`a3d2c7747278152383d3b030e6c33b1dbd169af4\` | [#43823508990](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43823508990) | kỹ thuật R3 PASS; **art R3 bị reject**; không lấy CI làm owner chốt |
| FIST11 R1 | \`92b07ee8767c218030efee7aff10bec791c4ff4b\` | [#43905801051](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43905801051) | kỹ thuật PASS, visual self-fail, R2 sửa nguồn |
| FIST12 R10C | \`e178095b43a9b1f21b77544a821622f0cc9d706a\` | [#44107346724](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44107346724) | 48 pose, 4 atlas, native **7,6s**, G3.6 PASS; **owner chốt tạm** |
| FIST13 R7 | \`21023942b1796b3fd5829accd55b3d2f916f7472\` | [#44065143591](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44065143591) | 28 pose, 7,55s native, focused PASS; **owner tạm tạm** |
| FIST14 R2 | \`1fc4ad2811fa0fcaa572b89e0b34c676d46fa416\` | [#44112832093](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44112832093) | 36 pose code-art, 7,43s native, status G3.6 PASS; **art FAIL** |
| FIST15 R2 | \`e0da2aff0938ad8d5b9a5a44d8cd5ef02caa1c3c\` | [#44130928835](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44130928835) | 47 pose code-art, 3,35s native, 3 foe, G3.6 PASS; **art FAIL** |

**Đường dẫn gốc cho bằng chứng:**  
[FIST12 R10C native review](VFX_FIST12_R10C_NATIVE_ART_REVIEW_20261117.md) · [FIST12 owner lock](VFX_FIST12_R10C_OWNER_PROVISIONAL_LOCK_AND_FIST14_START_20261117.md) · [FIST12/FIST13 owner & reference](VFX_FIST12_FIST13_OWNER_DECISION_AND_MELEE_REFERENCE_20261117.md) · [FIST14 R2](VFX_FIST14_R2_NATIVE_SELF_REVIEW_20261117.md) · [FIST15 R2](VFX_FIST15_R2_WUDANG_LIGHT_REAL_NATIVE_QA_20261117.md) · [FIST08 R1 decision](vfx_packets/FIST08_OWNER_SELECTED_R1_20261116.md) · [FIST10 R4 reference-only](VFX_FIST10_R4_APPROVED_VISUAL_LOCK_20261116.md).

**Giới hạn dẫn chứng:** Artifact CI có thời hạn lưu trữ; **đừng dùng URL artifact hết hạn làm nguồn duy nhất**. Generator, master nguồn, V4 packet, scene và hồ sơ QA phải còn trong Git. Nếu không có full video/ảnh trong repo, trích đúng run và SHA, **không khẳng định owner đã xem/duyệt một bản khác**. Workflow \`v63-quyen-doc-matrix\` có run đỏ riêng trên các commit VFX; điều đó **không đồng nghĩa** pipeline VFX focused đỏ, nhưng cũng **không thể tuyên bố toàn bộ CI của PR xanh**.

## 4. BÀI HỌC ĐÚNG/SAI TỪ CÁC LẦN LÀM LẠI

### 4.1. Những kiểu bị loại, có nguyên nhân cụ thể
1. **Poster/screenshot thành asset:** FIST12 R6 từng mắc lỗi cắt từ artboard/poster, alpha threshold theo nền, ráp clip giả nguồn sprite; bị loại dứt khoát. Một PNG có alpha không chứng minh nguồn tranh có thể dùng. [Postmortem](FIST12_R6_PROCESS_FAILURE_POSTMORTEM_20261117.md).
2. **Code-art phẳng & biểu tượng giao diện:** FIST01 R9, FIST06 R3, FIST14 R1/R2 dù Godot PASS vẫn giống bao tay phẳng, ba vuốt đỏ hoặc icon. **Code render được** không có nghĩa mỹ thuật premium.
3. **Các tia sáng giống hệt nhau:** FIST15 R1 có 5 sọc hồng đều và vòng huyết hải viền cứng. R2 đã gộp thành lõi sáng lớn + dòng sáng phụ bất đối xứng và khí mỏng, nhưng còn giống chữ V, **chưa đạt G3.7**.
4. **Hình tượng không khớp tên và effect:** FIST14 Liệp Huyết Truy Đả là kỹ năng **Quyền**, không nên cố định motif “ba trảo”. FIST02 có tên “Phi Thân Liên Cước” nhưng gameplay **guard** và chưa có caster kick animation: không được kéo idle sprite làm giả đá.
5. **Ánh sáng mờ vô hình ở 1×:** frame atlas có pixel/unique SHA vẫn có thể gần như biến mất sau layer alpha; cần đo ROI trên **native 1280×720 charge/peak/contact**, không dựa vào nguồn lớn hoặc zoom ảnh.
6. **Matte cắt thẳng:** FIST03/FIST04/FIST09 từng lộ cạnh chữ nhật; phải sửa **content alpha/matte tại nguồn**, không chỉ thêm blur/glow trên sprite đã cắt.
7. **Dấu ấn che mặt hoặc thiếu đọc:** FIST12 R9 mark che đầu quái; R10C hạ xuống vai/ngực. FIST14 R1 status 3,6s gần như vô hình, R2 phải tăng rõ; **G3.6 cần kiểm mốc sustain, không chỉ contact**.
8. **Phản ứng cận chiến không “có lực”:** hit spark trắng nóng ngắn + biến dạng theo hướng + local impact + phản lực có kiểm soát, không phải 3 lần nhấp lại cùng sprite/màu. Không bịa hitstop/knockback vào Combat V2.
9. **Dùng lại nguồn tranh cũ cho hero:** FIST12 R10C lấy riêng nguồn R9 + FIST03 để bù silhouette, vẫn không thể gọi “tranh hero hoàn toàn mới”; FIST11 cũng là derivative. **Đổi màu không tạo identity cho 36 nhánh.**
10. **Gộp ba đồng hồ:** cast, VFX playback và thời lượng phim QA khác nhau. FIST15 phim 3,35s **không** có nghĩa skill cast 3,35s; mark 6s không phải 6s đọc cast.

### 4.2. Công thức mỹ thuật được rút ra (không phải một preset màu áp mọi nhánh)

**Tầng 1 — Hot Core:** gần trắng/trắng ngà, nhỏ, nơi tập trung năng lượng; peak **tức thời** khi chạm đích.  
**Tầng 2 — Colored Body:** màu môn phái/hệ (Bá Quyền đá vàng-gạch, Kim Cang vàng thổ, Huyết Quyền đỏ thẫm/ruby), có hình học **có nghĩa**: quyền, núi, hộ thuẫn, chấn xung, nội lực theo phương.  
**Tầng 3 — Soft Halo/Trail:** sáng yếu, trong, đuôi biến thiên, không đều/không bịt mặt/không tràn cả màn hình.  
**Trục chuyển động:** tụ khí tại tay/điểm tạo → tăng tốc/đổi hướng hợp lý → **một điểm chạm đích**/đúng cap → thoát năng lượng và tan; nếu tồn tại trạng thái dài, tách lớp riêng.  
**Vật liệu:** texture/pigment cần mềm và thuần màu; hạn chế vòng neon, đồng tâm đều, các thanh song song, mảng đỏ đục, giả 3D boss, UI icon làm chủ thể.

**Học từ Võ Đang/Võ Lâm/Kiếm Thế:** nghiên cứu thật tại [JX Source A light language](VFX18_JX_SOURCEA_LIGHT_LANGUAGE_RESEARCH_20261113.md), [Godot JX/Source VL A-B](JX_VLTK_VFX_IN_GAME_PREVIEW_R1_20261117.md). Áp dụng: \`precast → cast/flight → impact\` là ba phase riêng, gần trắng ở lõi, tím lam mềm ở halo, điểm chạm dứt khoát. **Không nhập trái phép atlas/audio/frame thương mại**: source đã có trong repo được phép **so sánh nội bộ** theo hồ sơ hiện tại nhưng **không được mặc định có quyền phát hành**. FIST15 R1/R2 dùng **47 pose source VFX mới của dự án**; đối chiếu 10/17/8 pose #158 là tham khảo cách chia phase, **không phải chứng cứ quy định cast-clock game Võ Lâm**.

### 4.3. Ba nhánh Quyền phải có ba ngôn ngữ khác nhau
- **Bá Quyền:** dồn nén nặng; vàng đất/nâu gạch, chấn đất/đá bụi, đường xung lực hướng rõ; không tạo fire DoT nếu catalogue không có.
- **Kim Cang:** phòng ngự/hoàn lực; vòm hộ thuẫn nhẹ, đường viền vàng trắng trong, blocked-hit flare ngắn **trên người nhận guard**; không giả trả sát thương hoặc che người bằng chuông kín 4s.
- **Huyết Quyền:** huyết khí ruby có lõi sáng trắng hồng, chuyển động “chảy có hướng” chứ không sóng lặp; **mark nhỏ sau chiêu**, không tô cloud đỏ 6s; tuyệt kỹ \`consume_poison\` như FIST15 **không được vẽ icon poison hay mark kéo dài** khi duration=0.

## 5. QUY TRÌNH HỢP NHẤT ĐỀ XUẤT — DÙNG SOP V4 ĐÃ TỒN TẠI

**Không tạo SOP mới xung đột.** Tài liệu gốc hiệu lực: [AGENTS.md](../../AGENTS.md), [Art-First G0–G8 + G3.5/G3.6/G3.7](TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md), [Sprite Layer Pipeline](TMB_VFX_SPRITE_LAYER_PIPELINE_20261114.md), [FIST school playbook](TMB_VFX_FIST_SCHOOL_PLAYBOOK_20261114.md), [V4 validator README](vfx_packets/README.md), [.agents art-director](../../.agents/skills/tmb-vfx-art-director/SKILL.md).

| Gate | Đầu vào / thao tác thực | Bằng chứng yêu cầu | STOP nếu |
|---|---|---|---|
| **G0** Contract | Đọc ID catalogue mới nhất, effect, shape, cap, cast, duration, projectile, event receipts | Bảng **3 clocks** + ghi \`RUNTIME_MAPPING_PENDING\` nếu chưa gắn live | tự gán nhiều hit, heal, projectile hoặc status |
| **G1** Reference/legal | Tham khảo chủ yếu style Võ Lâm/Võ Đang, riêng từng môn | provenance + quyền sử dụng | lấy pixel/clip JX không rõ giấy phép làm asset |
| **G2** Semantic storyboard | Viết 1 câu “người chơi thấy gì → hiểu skill nào”; phác **từng pose/pivot**, ba phase rõ | các mốc khác nhau thật, image meaning | hình ảnh vô nghĩa/giống 3 skill khác |
| **G3** Original Art | Làm master **trong suốt RGBA**, độc lập, pose khác nhau, lưu SHA/generator | source thật, atlas, alpha, pivot, budget | poster crop, flat icon/nhân vật rig, source quên lưu |
| **G3.5** Native STOP | Dựng Godot 4.7.2 ở 1280×720, **charge/peak/contact** với quái WALK | 3 PNG thật, 1× đủ rõ | mặt bị che, hình sai, không có source→target |
| **G3.6** Visibility | Đo screen-space ROI + kiểm mốc cuối/mark sustain | số pixel và ngưỡng theo skill; bright/dark QA | có sprite mà nhìn không thấy |
| **G3.7** Semantic Art | Ẩn HUD/tên chiêu rồi kiểm nhận diện, chuyển động, phụ lớp sáng | chấm **silhouette/material/motion/contact/fade/uniqueness/readability** ≥4/5 mỗi mục tiêu tự-gate để **được đưa owner xem** | nhận sai quyền thành trảo/sword/V chữ; UI vòng giả |
| **G4–G5** Timeline/full movie | Test một/nhiều mục tiêu thật theo cap; contact vs duration rõ | native MP4 ≥12 timecodes, moving-target, GDScript focused test | GIF/montage/poster thay phim engine |
| **G6–G7** Review & exact SHA | Test V4, kiểm soát source and immutable art; owner quyết định | GitHub Actions run ID+exact SHA+manifest, **TECH/ART/OWNER** tách biệt | CI PASS bị gọi owner PASS |
| **G8** Release | Chỉ khi có lệnh owner riêng cho live integration | receipt-bound VFX, dark/bright crowd, Android physical QA | tự đẩy LAB vào PvE, sửa Combat V2/SaveService, merge |

**Quy tắc giao một skill:** \`canonical_id → source master SHA + provenance → atlas pose/frame count → scene/test → G3.5 PNG → G3.6 actual pixel → G3.7 self-score → native full movie+timecodes → run+exact SHA → OWNER_ACCEPT/PROVISIONAL/REJECT → BACKLOG → PvE/device HOLD\`. Hợp đồng \`hit_count\` không khai báo nghĩa là **NULL, không suy diễn**. Đồ họa cast, visual sustain và status gameplay có đồng hồ độc lập. FPS 60 của Godot offline movie **không phải benchmark Android 60 FPS**.

## 6. QUY ƯỚC BUFF/DEBUFF CHUNG CHO 36 NHÁNH — HIỆN CHƯA ĐƯỢC DUYỆT

**Nguồn:** [TMB_COMBAT_STATUS_VFX_36_BRANCHES_STANDARD_V1_PROPOSAL_20261117.md](../design/TMB_COMBAT_STATUS_VFX_36_BRANCHES_STANDARD_V1_PROPOSAL_20261117.md). Chỉ là **proposed design**, không phải chức năng hoàn tất.

- **Hai lớp:** (A) VFX kỹ năng ngắn, có bản sắc riêng lúc áp dụng/va chạm; (B) persistent status marker **dùng chung theo canonical status family**, không theo 36 nhánh hay tên skill. Một \`mark\` của FIST12/FIST13/FIST14 không cần ba kiểu vòng đỏ duy trì 6s.
- **Nhóm sơ bộ:** POISON stack, BURN, SLOW, WEAKEN, MARK, GUARD, HOT/RECOVERY (chỉ nếu runtime thật có status). Những nhãn catalogue như \`damage\`, \`consume_poison\`, \`cleanse\`, \`summon\`, \`formation_zone\` **không tự tạo một buff/debuff persistent icon**.
- **State authority:** \`status_effects\`, \`v63_poison\`, \`v63_marks\`, timer guard/shield theo Combat V2; event \`status_applied\` chỉ trigger cue, **không tạo bản sao status**. Giữ từng owner/caster/skill và từng expire riêng kể cả khi UI gộp thành “MARK ×N”.
- **Đề xuất tránh rối:** actor thường 2 icon debuff chính + \`+N\`, buff tách hàng; target đang chọn/Boss có chi tiết; countdown chỉ dùng **next expiry** hoặc **last expiry** được ghi nhãn, không tự gộp thành 6s giả. Status nằm vai/HP-safe area, không dán trực diện lên mặt.
- **Không làm trước khi chốt:** icon stun, freeze, bleed, silence hay bind nếu runtime canonical chưa có; không thay dữ liệu gameplay để đạt thẩm mỹ. \`StatusPresentationNormalizer\` + shared icon atlas + 6v8 test là **công việc sau khi owner duyệt quy ước**. Hiện repo có badge Poison lab / text tags nhưng không có UI chuẩn 36 nhánh đã được triển khai.

## 7. DANH SÁCH NỢ, THỨ TỰ ƯU TIÊN

| Ưu tiên | Việc | Điều kiện hoàn thành / không lấn phạm vi |
|---|---|---|
| **P0** | Đóng gói **bằng chứng owner accepted/provisional** đúng bản của FIST09, FIST01 và FIST07; đối soát ledger \`NOT_ART_APPROVED\` vs hồ sơ mới | Chỉ cập nhật ghi chép/decision log, không thay nghệ thuật theo suy đoán; không gọi R3 FIST09 final |
| **P1** | **FIST14 R3** loại motif trảo, vẽ quyền kình truy kích có bàn quyền rõ và chất liệu sáng hữu cơ **master mới** | G3.5/G3.6/G3.7 1× ≥4/5 trước khi xin owner; giữ R2 self-fail trong lịch sử |
| **P1** | **FIST15 R3** master RGBA gốc có **quyền trắng nóng** không V/sọc song song, huyết hải mềm; test 3 mục tiêu | Godot native thật trên sáng/tối, 1×, không nhầm \`consume_poison\` thành mark, cùng 3-clock chính xác |
| **P1** | Thiết kế/status vocabulary V1 để owner duyệt; không ấn theo mỗi skill | Phân loại canonical status, giữ stack/source/expiry; không mutate Combat V2 |
| **P2** | Chỉnh riêng FIST12 (quyền bớt hỏa khí, hand source riêng), FIST13 (nét phản lưu), FIST07 (blocked hit), FIST08 R1 | **Chỉ sau lệnh chủ dự án**; hiện các bản giữ tạm phải bất biến |
| **P2** | FIST10 R4 style reference chuyển thành alpha masters/animation thật | Không cắt GIF có background; native Godot 4.7.2 + owner review độc lập |
| **P3** | 1× bright map, nhiều quái 6v8, crowd stress 30 đệ tử/40 quái, đo hiệu năng Android thật | Chỉ ghi PASS nếu đã đo; không biến offline 60fps thành benchmark |

## 8. CHỈ DẪN CHO CHAT TỔNG HỢP 12 MÔN PHÁI

1. **Đọc file này và snapshot CSV kèm theo**, **không yêu cầu chủ dự án sao chép nội dung chat**. Mở theo link cố định của nhánh hoặc tìm trong PR #72.
2. Khi cộng số môn phái, **phân biệt** \`CATALOGUE_ID\` vs \`HUMAN_CAST_MASTER\` vs \`DEDICATED_LAB\` vs \`ENGINE_TECH_PASS\` vs \`OWNER_FINAL\`. Thần Quyền FIST03 **không cộng extra canonical skill**; 36 nhánh không đồng nghĩa 36 status icons.
3. Những nhãn \`OWNER_PROVISIONAL\`, \`STYLE_REFERENCE_ONLY\`, \`ART_SELF_FAIL\`, \`ART_PENDING\`, \`OWNER_DECISION_RECONCILIATION_REQUIRED\` **không được tự chuyển thành “approved”**.
4. Chỉ chuẩn hóa **phương pháp** (light-core/body/halo, G3.5–G3.7, V4 exact SHA, event/mark separation), **không ép** 12 school vào cùng màu/tỷ lệ/hình vòng tròn.
5. Nếu khác tài liệu cũ/ledger thì ghi **conflict với nguồn gốc, ngày và phiên bản**, không tự ghi đè lịch sử. Bản số liệu 16/11 ở \`VFX_PRODUCTION_STATUS_SNAPSHOT_20261116.md\` là snapshot lịch sử; không dùng làm tổng mới khi FIST11–15 đã có LAB sau đó.
6. Tài liệu này là **báo cáo và bảng snapshot**, không là tự động duyệt hoặc cho phép merge. **PR #72 Draft, PvE/Combat V2 giữ nguyên; physical-device QA chưa đủ**.

### Tệp liên quan
- **Chính:** \`docs/operations/VFX_FIST_SCHOOL_CONSOLIDATED_HANDOFF_20261118.md\` (bản này).
- **Dữ liệu:** \`docs/operations/vfx_school_ledgers/FIST_HUMAN_REVIEW_SNAPSHOT_20261118.csv\`.
- **Bản một trang:** \`docs/handoffs/VFX_FIST_FOR_CROSS_SCHOOL_CONSOLIDATION_20261118.md\`.
- Quy trình/standards/mỹ thuật, chặn bản lỗi, JX reference, các biên bản R10C/R7/R2 đã gắn link ngay tại các mục tương ứng.

**Trạng thái phát hành của chính báo cáo:** \`REPO_HANDOFF_PUBLISHED\` sau khi commit GitHub thực tế được xác minh; **không thay đổi tiêu chí owner và bất kỳ release gate nào**.
