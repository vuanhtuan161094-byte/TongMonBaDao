# TÔNG MÔN BÁ ĐẠO — VFX 12 MÔN PHÁI · KHÓA SẢN XUẤT LIÊN MÔN V5.0 (19/11/2026)

**QUYẾT ĐỊNH CỦA CHỦ DỰ ÁN, áp dụng ngay cho MỌI chat VFX**. Không tạo SOP mới cạnh tranh: đây là *khóa thực thi + kế hoạch sản xuất hàng loạt* của **Art-First Production System V4** vốn đã chốt tại `TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md`, `AGENTS.md`, Art Director Skill, Sprite Layer, và Cross-School §12. Các quy định V4 vẫn đầy đủ, chỉ rút thao tác thừa.

**Repo:** `vuanhtuan161094-byte/TongMonBaDao` · **Draft PR #72** · branch `integration/pve-p0-playable-ui-20261103` · **Godot 4.7.2** · native proof **1280×720** (video mã hóa 60fps không đồng nghĩa Android FPS). **Không Codex Cloud**, không rig, không GIF mặc định, không merge, không tự triển khai PvE, không sửa Combat V2/SaveService/economy/AI, V6.3 OFF. One writer mỗi thư mục chuyên trách; luôn kiểm HEAD trước ghi. Luôn giữ nguyên approved/provisional version và phase.

## A. Hai benchmark CHỦ DỰ ÁN CHỌN NGÀY 19/11 (cộng các benchmark cũ)

1. **POI06 — Vạn Cổ Phệ Giới Human R11**: **CHUẨN CHÍNH** về thân linh lực, hình tượng cổ giới, phân lớp alpha, chuyển động mượt/không dán và điểm kết. [Native Actions #43605803380](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43605803380) · [artifact #14118243054](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43605803380/artifacts/14118243054) · exact tested SHA `dcc28af536778ec8a7274aa21b9c3474dbe15e6a` · 5.55s. Owner previously accepted R11 preview; today explicitly identifies POI06 as the VFX the owner was looking for. **Preference/approved preview ≠ a newly invented final native PvE approval**. Freeze R11 actual source and recorded scope.
2. **POI19 — Phụ Cốt Cổ Tiên B R3**: **CHUẨN PHỤ** về lớp **light trail động real-time trong Godot**, ruby/violet-jade layered soft bloom, smooth tether/contact/mark decay, not source art copying. [Native Actions #44105241617](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44105241617) · [artifact #14339270095](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44105241617/artifacts/14339270095) · exact tested SHA `4a316afc28243f632e0c61b07ccb984dab2c310b` · 8.5s. Owner 19/11 says **“poi 19 cũng ok”** = **positive/provisional quality reference**, NOT retroactive `OWNER_FINAL_APPROVED`; existing G6 art debt (main hero/flower and impact) remains. Freeze R3 source while reusing only techniques.
3. **POI15 — Hóa Độc Tán Human R1B** remains explicit **OWNER_VISUAL_APPROVED**: “ok đẹp t thích. tiếp tục skill tiếp theo” (17/11). [Native Actions #43999563772](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43999563772), SHA `1b40811248fcaca9b33a5e4cbc35e8b03e2ca9b5`, 7.5s. Good status-mark persistence/readability on 3 selected targets.
4. **HF02 — Hỏa Phù R6**, owner rated **10/10** (see `docs/operations/vfx_packets/HF02_R6_OWNER_APPROVAL_20261116.md`), separate Fire Talisman material and cast→travel→impact benchmark. Other existing accepted/provisional assets remain locked exactly per each school ledger; POI02/03/04/07/09/11/15, FIST12 R10C, PAF05 R5E etc require phase-specific historical checks, **not blanket approval**.

**Benchmarks teach workmanship, NOT interchangeable pixels or school identity.** NO import of JX/VLTK/Kiếm Thế commercial pixels; use documented footage only to study real force/timing/color. MIT library code from Godot/REEBOO/Effects Lab may support particles, impact and QA *after* license review; GDQuest textures/art are CC BY-NC-SA and must not be imported into commercial game.

## B. Chất lượng mỹ thuật — các cài đặt đã chốt, không được bỏ

- VFX có hình tượng **năng lượng ánh sáng sống** (kiểu Võ Lâm/Kiếm Thế), **không phải vật thể đặc/phẳng**. Layer semantic: **near-white compact HOT CORE** + **COLORED TRANSLUCENT ENERGY BODY** theo hệ + **SOFT restrained HALO** alpha mịn; lớp chủ thể MIX/alpha, ADD chỉ quang phụ. VFX đều có ánh sáng nhưng **không cùng một silhouette**, không sao chép đổi tint cho 36 nhánh.
- Art nguồn **first-party original high-quality isolated RGBA master**, key poses frame-by-frame **thực sự thay hình**, phi poster, không ngụy tạo bằng crop/trượt/phóng một bitmap, Bézier neon hình học hay một vòng tròn/vài vệt sóng. Luôn lưu master+attribution/provenance+sprite poses/atlas+pivots ở GitHub; Actions artifact hết hạn chỉ là QA.
- Semantics **nguồn (caster/weapon) → chủ thể/đường lực → mục tiêu → contact/recoil → status/result** nhìn hiểu tại **1×**, không UI text. Caster phải thực sự cho thấy hành động; sprite actor đã duyệt không được tự đổi; frame-by-frame animation **không rig**. Mỗi skill đúng `effect/shape/target_limit` canonical. Không tự suy damage/DoT/projectile/homing/stack và không đồng nhất LAB demo với Combat V2 receipt.
- Source G3 **HARD STOP**: kiểm RGBA master/phase contact-sheet sáng/tối *trước lập trình Godot*, với `tools/vfx/prepare_g3_source_review.py` và actor scale. Nếu fail thì sửa nguồn, không CI/movie. G3 self-pass mới G3.5 native 3 frames (charge/peak/contact, target WALK và decoy khi cần) rồi G3.6 visibility, G3.7 semantic unlabeled. Full G4–G7 một video **ngắn diễn tiến attack→fade**, sustain dài/expiry test mốc riêng. **CI TECH PASS không chứng nhận đẹp**, owner approval độc lập, G8/Android/Windows vật lý riêng.
- Buff có thể là quỹ đạo/vòng sáng ôm thân xoay **nếu cơ chế là buff/guard** và có dấu nhận diện; không vẽ vòng cho mọi skill. Debuff/status vocabulary cho 36 nhánh còn là **proposal chưa toàn bộ owner-approved**, không tự gắn icon/timer/stack thiếu event. Đọc proposal và canonical gameplay mỗi lần.
- Game dùng 12 môn phái/36 nhánh, **2,196 skill IDs / 420 family** (204 Human cast master & 216 passive/innate/event). Không giả 2,196 phim độc lập, không vẽ cast cho passive/event thiếu trigger; unlock Human không tự approve Tiên/Thần. Mỗi tier đổi hình tượng khi mechanics cần, không chỉ phóng to/đổi màu.
- **Không ép Shadow Pixel-Chibi như style cuối cùng**: giữ các bản thiết kế nhân vật, phối màu đã được owner duyệt; VFX phải hòa vào actual actor/map. Phong cách một môn phái khác về vật liệu/hình, không lấy preset neon chung.

## C. Cách sản xuất nhiều kỹ năng nhanh MÀ KHÔNG phá Art-First

**Song song G0–G2, tuần tự G3 theo từng writer/skill, sau đó pipeline kỹ thuật có thể song song nếu không chung file.** Một wave nhỏ tối đa **1 candidate / mỗi môn phái** đủ cho pilot; KHÔNG tạo 12 thứ chưa qua Art-G3 rồi đồng loạt CI. G3 phản hồi theo **nguồn thật**; nếu fail, writer sửa tranh và không block các chat trường phái khác. Các kỹ năng đã approved hoặc provisional được khóa, bỏ qua vòng redraw.

- **Wave 0 — Baselines/readiness:** xác thực live HEAD, ledger/contract mọi trường phái; freeze approved POI06/15 + POI19 positive baseline; bắt lỗi G3 FIST14 R6; phân quyền school-owned directories; so native POI06/19/15 ở 1×, chỉ học chất liệu/nhịp. **Không mở G8.**
- **Wave 1 — Một ứng viên Human mỗi môn** từ bảng D là **pre-production queue**, không có nghĩa những skill đó đã sẵn sàng gắn runtime. Nhóm nào đang có revision tiến triển thì **tiếp tục revision hợp lệ ở school handoff thay vì sáng tác lại**. G0 contract check bắt buộc trước G2; không giao 12 native video khi G3 chưa đạt.
- **Wave 2 — Mở rộng từng trường phái:** sau khi 1 mẫu Human của nhánh đã đạt, reuse layer/tooling trong **cùng branch visual family** mà không copy body/hình tượng. Mở rộng 3 nhánh × actives/ultimates, passive/event chỉ theo real receipts. Không dùng mẫu Human chốt để tự approve tier Tiên/Thần.
- **Wave 3 — Tích hợp chỉ khi owner ra lệnh:** battle receipt, PvE/economy không tự đổi; Windows/Android physical QA trước release; PR vẫn Draft.

**Trạng thái duy nhất được dùng theo skill/revision:** `CATALOGUE_ONLY`, `G0_G2_PREP`, `G3_SOURCE_FAIL`, `G3_SOURCE_SELF_PASS`, `G35_NATIVE_TECH_PASS`, `G36_VISIBLE`, `G37_SEMANTIC_SELF_PASS`, `G5_MOTION_TECH_PASS`, `OWNER_VISUAL_APPROVED | OWNER_PROVISIONAL | OWNER_REWORK | OWNER_PENDING`, `PVE_HOLD`. Tránh ghi `PASS` chung chung. Chỉ tạo source/video khi thực sự có bằng chứng exact SHA.

## D. Wave 1 — hàng chờ 12 hệ dựa trên ledger 183 nguồn/hệ (đã đối chiếu 19/11)

| Môn / key | Candidate khởi động (canonical Human ID; không tự đổi effect) | Effect / hình tượng xuất phát; điều kiện trước G3 |
|---|---|---|
| Độc Tu / `poison` | **Không vẽ lại POI06 R11**. POI19 R3 cũng freeze. Ưu tiên **đối soát các bản có art debt**, POI20 chưa owner approval | POI06/19/15 = benchmarks, không phải 3 skill mới. Theo ledger 01 và handoff POISON chọn cụ thể candidate sau khi bảo vệ approved |
| Phù Tu / `talisman` | `tmb.skill.talisman.hoa_phu.active_01.human` — **Xích Diệm Khai Văn** | damage / single_target1; đối soát HF02/PAF05 school handoff, ưu tiên sửa phase tồn đọng đã giao trước |
| Kiếm Tu / `sword` | `tmb.skill.sword.ngu_kiem.active_01.human` — **Phi Kiếm Truy Ảnh** | damage / single_target1; nguồn kiếm khí và actor 4 hướng riêng, không giả kiếm thật bằng shader |
| Cung Tu / `bow` | `tmb.skill.bow.liep_anh.active_01.human` — **Xuyên Tâm Tiễn** | damage / single_target1; mũi tên có thân/đầu/quỹ đạo, tránh một thanh neon |
| Quyền Tu / `fist` | **FIST14 – Liệp Huyết Truy Đả** `tmb.skill.fist.huyet_quyen.active_04.human` | **G3_SOURCE_FAIL R6**; phải tạo master quyền kình ánh sáng thực rồi mới tiếp scene, tuyệt đối không đổi vật đỏ/Bézier như R5/R6 |
| Đao Tu / `blade` | `tmb.skill.blade.cuong_dao.active_01.human` — **Phá Vây Khai Sơn** | damage / single_target1; trảm khí nặng/dày, không sao chép nét Kiếm Tu |
| Song Đao / `dual_blade` | `tmb.skill.dual_blade.anh_nhan.active_02.human` — **Song Nhận Đoạt Ảnh** | damage / single_target1; hai lưỡi/đôi nhịp VFX nhưng **không tự thêm hit** |
| Thương Tu / `spear` | `tmb.skill.spear.long_thuong.active_01.human` — **Vân Long Điểm Thủy** | damage / line target limit2; long thương xuyên một trục, không sửa target2 thành AoE |
| Chưởng Tu / `palm` | `tmb.skill.palm.han_ngoc_chuong.active_01.human` — **Hàn Ngọc Chấn Mạch** | damage / single_target1; áp lực chưởng lạnh có mặt sóng, không dùng quyền kình nắm đấm |
| Chú Tu / `curse` | `tmb.skill.curse.phe_linh_chu.active_01.human` — **Tán Linh Chỉ Nguyền** | mark / single_target1, catalogue key **text_pending**: bắt buộc xác minh effect/anchor/receipt trước vẽ phù ấn, không đồng nhất Phù Tu |
| Trận Tu / `formation` | `tmb.skill.formation.sat_phat_tran.active_01.human` — **Liệt Địa Sát Văn** | formation_zone / circle limit3; vùng/trục địa trận, không dựng AoE damage giả hay vòng UI đồng tâm |
| Triệu Hồi / `summon` | `tmb.skill.summon.kiem_linh.active_01.human` — **Kiếm Linh Thỉnh Kiếm** | summon / single_target1: **cần actor/asset triệu hồi hợp lệ, không tạo unit ảo**; nếu nguồn actor thiếu đánh `SUMMON_SOURCE_BLOCKED`, nghiên cứu trước |

**Bảng trên là queue tiền sản xuất, KHÔNG báo cáo các candidate mới đã có asset/motion.** Đối soát từng candidate với chính catalogue/school ledger live mới nhất. Nếu tên/slot/effect đã thay đổi hoặc revision đã được owner duyệt thì **skip, không overwrite**.

## E. Bàn giao cho chat mới (one writer) — đường dẫn nhất định phải đọc

1. `AGENTS.md`; `docs/operations/TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md`; `.agents/skills/tmb-vfx-art-director/SKILL.md`; `docs/operations/TMB_VFX_SPRITE_LAYER_PIPELINE_20261114.md`.
2. `docs/operations/TMB_VFX_CROSS_SCHOOL_LESSONS_AND_EFFICIENT_WORKFLOW_20261118.md` §11–12; `docs/operations/TMB_VFX_MULTI_CHAT_COORDINATION_AND_RECOVERY_20261118.md`; **this lock**.
3. `docs/operations/TMB_VFX_SCHOOL_BY_SCHOOL_MASTERPLAN_20261113.md`; `docs/operations/vfx_school_ledgers/01_poison_183.csv` through `12_summon_183.csv`; school-specific handoff `docs/handoffs/VFX_*_CURRENT.md` when present. Confirm source catalogue and event/3 clocks, DO NOT blindly use CSV as complete gameplay contract.
4. **POI06** `docs/operations/VFX_POI06_R11_GODOT_NATIVE_ACCEPTANCE_20261114.md`, **POI19** `docs/operations/VFX_POI19_PHU_COT_CO_TIENB_R3_20261117.md`, **POI15** `docs/operations/VFX_POI15_HOA_DOC_TAN_R1_20261117.md`, **FIST14 fail** `docs/operations/TMB_FIST14_R6_ART_FAILURE_ROOT_CAUSE_20261118.md`.

**Đầu ra từ một chat chuyên trách**: source master(s) + phase poses/vfx manifest/provenance thật; cheap source preflight; nếu tự art qua G3 thì native Godot 3 khung; clip liên tục khi native 1× đẹp; school handoff ghi exact SHA/run/art/owner gate; GH repo lưu source. Chat điều phối chỉ giao ownership, duy trì batch queue và bảo vệ điều kiện STOP.
