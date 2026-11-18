# C — Art Bible VFX: chất lượng nguồn, ánh sáng và nhận diện — V1

**Dự án:** Tông Môn Bá Đạo · 18/11/2026 · Draft PR #72. **Vị trí:** phụ lục **không thay thế** [Art-First SOP V3 + Production System V4](TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md). Áp dụng cho **skill mới/rework được giao**; mọi bản đã được chủ dự án chọn/duyệt phải giữ nguyên.

## 1. Ngôn ngữ hình học và chất liệu
**Một hình tượng + một hướng chuyển động + một điểm chạm + một kết quả.** Ở Godot native 1280×720 1×, che tên skill mà vẫn nhận ra: quyền/kiếm khí/rắn/kim/giấy phù/ấn phong, sát thương/bảo hộ/cleanse/độc hay thân pháp. Hình phải có đường bao rõ, không phải 5 vòng tròn không nghĩa.

- **MIX body:** main hero RGBA mềm, màu thuần có độ nổi, tạo hình thật, không crop poster thành master; tạo key poses **khác hình thật** (không chỉ scale/rotate/tint một ảnh).
- **HOT core:** ivory-white gần trắng, diện tích nhỏ, rực ở điểm nén và contact; không “cháy” cả silhouette.
- **Soft HALO/trail:** đường ngoài alpha nhẹ, xu hướng theo vận tốc, biến thiên hợp lý, không rung sin toàn image, không khói đỏ/tím đặc.
- **Phase:** tụ lực → release/flight/giáng/bao quanh tùy skill → impact → fade; chỉ sustain/loop nếu real state hoặc passive contract; 3 clocks tách biệt.
- **Contact:** ngắn, rõ nơi va chạm; có quỹ đạo phản lực nhưng không bịa hitstop, heal, damage, projectile hay status vào Combat V2.
- **Source:** lưu master RGBA first-party, atlas/pivot/alpha, generator/code art source nếu có và quyền nguồn. JX/VLTK học phối màu/nhịp chứ không sử dụng asset thương mại chưa phép.
- **Lớp:** ground + back pigment MIX → actor → front local material MIX + ADD lõi nhỏ → cleanup/status; không che mặt và HP-safe.
- **Tier:** Human/Immortal/Divine giữ family language nhưng thay hình tượng, nhịp, contact có chủ đích; không batch recolor.

## 2. Quy tắc riêng theo family
| Family | Silhouette chủ đạo | Vật liệu | Tránh |
|---|---|---|---|
| Bá Quyền | quyền kình nén, đá/chấn hướng rõ | vàng đất/gạch, hot core nhỏ | quyền như icon bao tay, lửa giả |
| Kim Cang | hộ thể/vòm/đẩy lực có chiều sâu | vàng ngà, chắn trong suốt | chuông đặc che nhân vật 4s |
| Huyết Quyền | quyền rõ năm ngón, huyết quang chảy có hướng | ruby sáng trong, lõi ngà hồng | ba trảo, chữ V, các sọc bằng nhau |
| Độc Tu | xà/kim/cổ/độc vụ có hình riêng | ngọc xanh, tím độc khi phù hợp | đầu xà thiếu nét, hoa sticker, quái gore |
| Phong Ấn Phù | giấy/mực linh có texture, ấn và dấu gió có nghĩa | ngọc–kim, tách lớp | ba “lá bài” phẳng, vòng buff vô danh |
| Hỏa/Lôi/Kiếm | vật liệu cháy, sét giáng, kiếm khí thuôn (không chuôi thép) | màu thuần với phân cấp core/body/halo | nổ liên tục, neon tối đục, vector line chủ đạo |

## 3. Bộ GATE rút gọn nhưng không giảm chuẩn
| Gate | Chứng cứ đủ | STOP khi |
|---|---|---|
| G0–G2 | exact skill ID, effect/target cap, 3 clocks, motif 1 câu, quyền reference | Sai cơ chế/nhân bản motif |
| G3 | first-party RGBA master + independent pose source, correct alpha/pivot | poster crop, matte vuông, fake actor rig |
| **G3.5** | 3 ảnh **Godot thật** charge/peak/moving-contact tại 1280×720 1×; so ngang owner reference cùng scale | xấu/sticker/che mặt/không có nguồn→đích |
| **G3.6** | ROI/contrast/alpha native so idle; riêng sustain test enable/disable | source có alpha mà game gần như vô hình |
| **G3.7** | che HUD/name, đoán được loại chiêu + hình, đánh giá 7–8 tiêu chí ≥4/5 mỗi mục **tự-gate** | hiểu sai quyền thành trảo hoặc V, vòng HUD vô nghĩa |
| G4–G5 | moving target, decoy, cap, anchor; native MP4 **đến hết attack/fade**, ≥12 checkpoints ý nghĩa khi phù hợp; status dài test mốc riêng | clip offline giả native, duplicate damage |
| G6–G7 | focused tests + V4 validator packet/assets/evidence SHA; review owner revision/phase riêng | chỉ CI PASS mà ghi OWNER_APPROVED |
| G8 | lệnh owner tích hợp live, physical device, perf/6v8/crowd | thiếu phép, chưa đo Android |

**Tối ưu thời gian:** Không render dài hoặc 3–5 video giống nhau trước G3.5. Khi sửa một phase, so native frames timecodes của phase đó trước; tập G5 đầy đủ khi ứng viên art đã tốt. Không GIF mặc định; không rig. Giữ tất cả owner-accepted phases.

## 4. Quy tắc self-art và báo cáo
Self-score có các trục `silhouette`, `material/light`, `motion`, `contact`, `fade`, `identity`, `1x readability`, `occlusion` (1–5). Tất cả phải ≥4 trước khi gửi owner; tự chấm không là chủ duyệt. Ghi `SOURCE_READY | TECH_PASS | ART_SELF_PASS | OWNER_APPROVED/PROVISIONAL/PENDING/REJECTED | PVE_HOLD` theo exact revision, SHA và phase giữ lại.

**Anti-pattern đã có bằng chứng:** FIST12 R6 poster crop, FIST14 trảo thay quyền, FIST15 chữ V, POI16 quá mờ/vô nghĩa, PAF01 giấy phù sticker, PAF06 vòng buff thiếu identity, HF02 source hero quá nhỏ. Cần sửa nguyên nhân hình tượng/nguồn, **không** tăng glow hoặc số frame để giả chữa.

## 5. Regression gallery (reference, không tự copy asset)
- Owner-approved: POI02 Xà Ảnh Quấn Mạch Human, POI03 Phụ Cốt Cổ Human, POI04 Cổ Vụ Mê Tung Human, POI07 R7, POI09 R1, POI11 R9, POI15 R1B; HF02 R6 theo [owner approval](vfx_packets/HF02_R6_OWNER_APPROVAL_20261116.md). Mỗi visual phải trỏ vào nguồn revision cụ thể, không lấy approval làm phép sửa lại.
- Owner provisional: FIST12 R10C, FIST13 R7, PAF05 R5E, PAF06 R5; art debts riêng. FIST09 revision cần đối soát, FIST10 R4 reference-only.
- [Độc Tu source audit](TMB_VFX_AREA_PRODUCTION_REPORT_AND_HANDOFF_20261118.md), [Quyền Tu source audit](VFX_FIST_SCHOOL_CONSOLIDATED_HANDOFF_20261118.md), [PAF lab packet](vfx_packets/PAF05_R5E_OWNER_PROVISIONAL_CHARGE_DEBT_20261117.md), [Cross-school review](TMB_VFX_CROSS_SCHOOL_LESSONS_AND_EFFICIENT_WORKFLOW_20261118.md).

**Chưa có benchmark GPU/Android vật lý cho các ngân sách dự kiến.** Bất kỳ con số LOD/alpha/particle sau này đều phải được đo trên Godot scene thật trước khi coi là chính thức.
