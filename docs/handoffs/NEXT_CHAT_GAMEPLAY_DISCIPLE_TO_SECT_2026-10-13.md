# TÔNG MÔN BÁ ĐẠO — NEXT CHAT GAMEPLAY HANDOFF: ĐỆ TỬ → CÔNG TRÌNH → TÔNG MÔN

**Ngày bàn giao:** 2026-10-13. **Loại:** tài liệu điều phối, READ-ONLY. **Không cấp quyền code.**
**Repository game:** vuanhtuan161094-byte/TongMonBaDao, main; **baseline trước bàn giao:** 426b20f0e047e7e9c3ab28195564077318b9e192.
**Source benchmark:** vuanhtuan161094-byte/ZQZS-Source-Knowledge, main 83cbc4ecbd83eb518a6d6f2b3894377d9d99254d.
**Engine:** Godot 4.7.2. **Target:** Android LANDSCAPE 1280×720; Windows chỉ để test/dev.
**Lệnh người dùng:** chuyển chat, hoàn thiện gameplay theo tuyến đệ tử → công trình → hoạt động tông môn; học cách game 《最强祖师》 / Ta Là Tông Sư tổ chức loop, đơn giản, đúng kiến trúc, không lặp việc.

## A. Quy tắc đọc và sự thật

Bắt đầu tại: AGENTS.md → docs/GAME_SYSTEM_ARCHITECTURE.md → CURRENT_CHECKPOINT.md (các mục mới nhất ở ĐẦU) → NEXT_CHAT_HANDOFF.md → tài liệu này → docs/DISCIPLE_V2_CHARACTER_IMPLEMENTATION_PLAN.md → docs/DISCIPLE_V2_DESIGN_LEDGER.md → docs/DV2_03F_BODY_GATE_MATERIAL_TRANSACTION_FINAL_REVIEW.md (đặc biệt phần cập nhật A/B và §S) → docs/P3_7_BUILDING_TREE_SPEC.md → docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md → docs/P3_6_SECT_MASTER_GAMEPLAY_LOOP_SPEC.md → docs/design/SECT_BUILDING_LAND_EXPANSION_DESIGN_V1.md → code/tests live main. Khi tài liệu lịch sử trái trạng thái mới nhất, ghi khác biệt và ưu tiên checkpoint/source thực, không suy từ title.

Luật làm việc: từng packet nhỏ, xác định source-of-truth, không có gameplay authority giả / save thứ hai; không thay EXP, realm, tỉ lệ, chi phí hay quyền sở hữu đã khóa. Mỗi packet được chủ dự án **duyệt CODE rõ ràng** trước khi sửa. Focused Godot 4.7.2 CI → cumulative gate khi đóng; nếu chỉ code/static PASS thì không gọi Android/Windows PASS. GitHub là authority; Source ZQZS chỉ là reference/client evidence, không tự bê Unity/Lua/socket/native hay số liệu balance. Ưu tiên kết quả gameplay chơi được, tránh tạo framework và lặp catalog/assets. Sau mỗi packet cập nhật checkpoint + handoff.

## B. Trạng thái verified tại handoff

| Mảng | Có gì thật/đã kiểm chứng | Điều KHÔNG được phóng đại |
|---|---|---|
| P0–P3.7 game systems | Có P3.7 BuildingSystem/Workforce/Warehouse/production, live scheduler, recruitment/DiscipleState, combat/PvE, UI P3.1–P3.6A, 89 simulation source và 97 test source tại main (đếm file, không phải 97 gate PASS) | Chưa đồng nghĩa gameplay V2 toàn diện hoặc APK playable cuối |
| SAFE-01/SAFE-02 | CLOSED, same-SHA Godot Linux 4.7.2 SAFE workflow 38324783574 SUCCESS: staged save + .bak fallback; fail-closed legacy warehouse migration; P0/P3.7/DV2/O9 M2/full cumulative PASS | Android kill/power-loss/storage-full chưa test |
| DV2-03/F | **PAUSED NOT CLOSED** theo quyết định người dùng. F0–F7 phạm vi A/B đã được code/test trước khi tạm dừng; 29 công thức/19 ID và transaction được bảo vệ, một số cổng A/B có earned source + UI + CI. Xem body gate final review §S và main code để xác nhận từng test, không dựa vào tài liệu roadmap cũ | C–H/3 Ấn thiếu route kiếm có thể chơi; không công bố 29/29 playable; chưa tự mở DV2-04 |
| M2 production | O7 Linh Lâm, O8 Luyện Đan, O9 tích hợp cùng Mỏ/Linh Điền; official Linux CI trên các commit đã ghi SUCCESS, save/reload anti-duplicate có test | Không phải tất cả nghề/tòa nhà trong spec đã có consumer runtime |
| P3.4 management | Windows REAL PASS của panel/lệnh hiện có theo spec | Hình ảnh cuối/Source A production chưa xong |
| P3.6A slice | Windows runtime gate PASS theo log chủ dự án, **visual product review PENDING** | Main scene vẫn có mục tiêu nâng từ debug/graybox thành cảnh thật |
| ENV-01 v4 | Đã có Windows Godot 4.7.2 structure/import và screenshot bản đồ ba tòa nhà thật PASS | Manual select/pan/zoom/full Android PENDING |
| ENV-02A | isolated 192×192, starter 48×48 tại (72,72), chunk 16×16, 3 Source A buildings; code mirror labs/env02a, static CI 38320233759 SUCCESS | Godot Windows import/runtime/scene/AStar/culling/screenshot chưa chạy; bản GitHub code-only THIẾU 35 PNG cần matching owner ZIP |
| Xây dựng/mở đất | DESIGN APPROVED ONLY tại docs/design/SECT_BUILDING_LAND_EXPANSION_DESIGN_V1.md; một future SectLayoutState bên trong SimulationState; reuse TransferMapModel projection; dời nhà/lát đường miễn phí V1 | ADR-0003 fixed layout còn hiệu lực; LAY-01–04, FE-02, ENV-02B–E NOT OPEN; xây mới/mở đất chưa khóa giá |
| Art | Source A 13 candidate manifest: 10 VERIFIED mapping / 3 INFERRED; 3 preview sprite lab; S3 **tám art đã duyệt cũ không được thay**; female_normal_v1 rig/motion phải bảo toàn | 13 candidate không phải 13 BuildingState; các concept ba hướng down/right/up chưa là 42 PNG modular game-ready. Spine song song chưa nghiệm thu production |

## C. Gameplay completion objective: 1 người → 1 hành động → 1 kết quả thật

Ưu tiên nhất: **Một đệ tử tuyển từ Dẫn Tiên** có birth/seed/đặc tính hợp lệ, trạng thái lưu/tải không reroll; người chơi đọc hiểu phẩm chất/thông số thực; giao cho công trình thực; đệ tử đi/chọn việc (visual khi production art sẵn) → công việc qua SimulationScheduler → tài nguyên hoặc EXP/nghề/progression thực thay đổi → Warehouse nhận; người chơi dùng sản phẩm vào upgrade/craft/đan hoặc phục vụ tông môn, có thể nghỉ/tu luyện/săn → giao dịch chính xác qua save/reload. Bất cứ nút UI, animation, notification phải derive từ canonical state, không giả.

Làm theo thứ tự **READ-ONLY gap audit → nhỏ nhất runnable slice → chỉ code khi duyệt**:
1. **Đệ tử/birth:** Dẫn Tiên candidate→DiscipleState; lục duy, thuộc tính bẩm sinh/latent/reveal, tuổi/thọ, linh căn/đặc chất/mệnh cách/huyết mạch/thể chất; check V2 authority vs P2 legacy, effect consumers, save. Đừng triển khai 101 trait chỉ để đầy danh sách.
2. **Tu luyện/Luyện Thể:** 30 cảnh giới×10 tầng mỗi track, đúng EXP, luật đột phá, material A/B earned vs C–H locked, Tu Vi passive khi làm việc theo luật mới, Body EXP chỉ từ hoạt động hợp lệ, auto policy. DV2-03 PAUSED: audit và đề xuất ranh giới resumable, **hỏi chủ dự án mở lại riêng**, không tự sửa.
3. **Hành động thực:** một scheduler, AI/goals/needs, CULTIVATE/TRAIN_BODY/WORK/REST/HUNT/HEAL; bảo đảm không trừ/gain hai lần, offline same outcome, action và worksite đồng nhất; UI điều hành/roster bám state thật.
4. **Nghề→công trình:** mapping profession→worker group→building instance→job/slot→timer→resource/equipment/medicine; bắt đầu Mine, Linh Forest, Spirit Field, Alchemy/Forge, lodging/health/guidance rồi mới mở breadth. Reuse P3.7 + O1–O9, chưa code toàn bộ tree dài hạn.
5. **Kinh tế/điều hành:** Warehouse canonical reserve/lock, exactly-once spending/producers, upgrades Lv1–100, primary/multi-instance consumer audit, hunting loot/sell/craft, nhân sự/quản lý. Khi chọn construction costs/land unlock cần phê duyệt riêng; không invent giá.
6. **Map/giao diện:** FE-02 đợi riêng; ENV-02A Windows pending, không tạo MapModel thứ hai; location→building ID có thật; Android landscape map-first, touch pan/zoom, panel P3.3/P3.4, 8–12 NPC visible khi cần; actor visual-only route không tự hoàn tất job.
7. **Hiệu năng/release:** test 100/500/1000/3000 đệ tử, cost tick/save/AI/relationship/memory/culling, realtime/offline catch-up dài; Android crash/recovery và vòng chơi 5–10 phút. Benchmark P0 6 disciples không chứng minh 3000.

## D. Debt ledger — KHÔNG ĐƯỢC QUÊN

**D01 DV2-03 paused:** chưa đóng; A/B limited gameplay đã test, C–H/3 Ấn thiếu nguồn thật, cả 29 gate chưa playable; chưa mở DV2-04. Trước tiếp tục phải đọc source + body-review §S, xác định A/B exact coverage và xin quyền resume.
**D02 Các effect V2 thật:** trait/destiny/root/bloodline/physique/derived stats, old combat power/legacy UI, consumer work/cultivation/combat, UI reveal/snapshot, save. Có nhiều DESIGN LOCKED ≠ runtime V2 PASS.
**D03 Passive Tu Vi/work migration:** luật đã khóa theo 2026-10-09 có điểm còn phải chuyển từ generic work-Tu-Vi cũ; tránh award song song và đổi EXP âm thầm.
**D04 Cơ chế giao diện đệ tử:** màn chọn đệ tử, roster, hiệu ứng thật, lệnh hành động; UX map-first Windows/Android cuối PENDING; art female_normal_v1 cần artwork mới ba hướng down/right/up và gate rig/42 PNG, concept không thay PNG.
**D05 Building catalog:** mapping từng công trình trong P3.7 tree → có backend/consumer? instance thật? asset Verified/Infer/Missing? khu chức năng 192×192? unique vs multi? ưu tiên tối thiểu gameplay; phải audit thay vì khẳng định mỗi công trình spec đã code.
**D06 Construction/land:** DESIGN APPROVED, CODE NOT AUTHORIZED; ADR-0003 fixed-layout còn hiệu lực, LAY-01–04/FE-02/ENV-02B–E NOT OPEN. Một future SectLayoutState, link real BuildingState, migration/save, free move/roads, giá build/unlock TBD.
**D07 ENV-02A Windows:** dùng exact full ZIP TongMonBaDao_ENV02A_192World_Lab.zip đã bàn giao, không chạy code-only checkout thiếu PNG; RUN_ENV02A_WINDOWS.cmd, ENV02A_TEST_RESULTS logs và hai ảnh camera center/outer, test 20×13; Android touch/perf PENDING.
**D08 Art Source A/S3:** 13 candidate ≠ 13 accepted visuals; 8 S3 approved contracts protected, exact art gaps/anchor; Spine converter Codex parallel, chưa thay bằng sample ngoài rig. Git LFS transport/push-pull chưa nghiệm thu; không push binary tuỳ tiện.
**D09 SAFE mobile:** SAFE-01/02 CI CLOSED nhưng real Android kill/low storage/backup/resume PENDING.
**D10 Scale/offline:** 1000–3000 disciples throughput/RAM/save/AI/scheduler chưa benchmark; backlog unbounded offline/time-window RISK; đừng tự đổi 60s/tick hoặc offline policy.
**D11 Production UI product quality:** P3.6A runtime PASS nhưng visual/gamefeel chưa user-approved; FE-02 integration chưa mở; game còn graybox so với ENV Source A.
**D12 Other gameplay systems:** combat/hunting/world map 30×10 clusters, equipment 10 slots, Phù/Pháp Bảo/sets, high-tier recipes/loot, sect autonomous economy, profession service & relationship: design authority tồn tại nhưng nhiều runtime nguồn/content bị defer. Không triển khai ngang chỉ để đủ ô UI.
**D13 Historical technical debt:** SOURCE Knowledge native IsCanPlace/FindPath unknown; không suy rằng algorithm source đã copy. Source art rights owner-declared confirmed; không cần hỏi lại, nhưng project frozen legacy registry rights field không được tự sửa. Keep Windows QA pending and Godot 4.7.2 exact version.
**D14 Checkpoint history:** checkpoint và các spec có đoạn cũ tự nhận 'ACTIVE' hoặc 'NOT CODED'; đọc section mới nhất / live code/tests / CI, lập bảng conflict rồi cập nhật doc sau khi duyệt, không xoá bừa lịch sử.

## E. Đề nghị CHÍNH XÁC cho chat mới (BƯỚC 1, READ-ONLY)

- Fetch live both repos and HEAD. Read authority sources in §A plus state/scheduler/recruitment/DiscipleV2, Warehouse/BuildingSystem, PvE, P3.2/P3.3 UI, tests; inspect code F0–F7 on main. **Không hỏi upload tệp đã có trên GitHub**.
- Produce **Gameplay Gap Matrix** mỗi hàng: cơ chế → code owner → test/CI evidence → actual player interaction → missing dependency → trạng thái VERIFIED/PARTIAL/DESIGN-ONLY/UNKNOWN → severity → smallest next packet.
- Organize along **Disciple → Action → Job/Profession → Building → Warehouse/Transaction → Output → UI/map**, choose **ONE** minimal first end-to-end playable slice. Distinguish "must resume DV2-03" vs independent design/review without violating pause.
- Provide an ordered roadmap with PASS gates, affected allowlist, regression scope; do not code now; **chờ người dùng duyệt rõ một packet**. In proposals note tasks which can be done via GitHub CI without user's PC vs Android/Windows PENDING USER.
- Finish with ready-to-tap complete Vietnamese prompts: (1) recommended READ-ONLY/current gap inspection, (2) authorize exactly scoped code packet AFTER review, (3) Windows QA later. Never treat suggestion/button itself as authorization.

## F. Proven CI references

- SAFE-01/02 Godot 4.7.2 Linux full P3.7 cumulative: https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38324783574 — SUCCESS.
- DV2 workflow historical (A/B authority gate): https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38193051740 — SUCCESS on then-current SHA, not Android.
- O9 M2 production rehearsal: https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38193051636 — SUCCESS.
- ENV-02A isolated code-only audit: https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38320233759 — SUCCESS STATIC, not Windows/runtime.
- FE-01B1 exporter: https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38214043053 — SUCCESS relevant scoped.

**END — Không có code được mở bằng tài liệu bàn giao này.**