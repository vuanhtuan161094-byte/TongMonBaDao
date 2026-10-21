# TÔNG MÔN BÁ ĐẠO — TẠM DỪNG & TIẾP TỤC (21/10/2026)

> **QUYẾT ĐỊNH OWNER — ƯU TIÊN HIỆN HÀNH.**
> Người dùng đang không có máy tính; không yêu cầu họ thực hiện thao tác trên Codex hay Windows lúc này.
> **Làm cả 4 luồng về dài hạn, nhưng KHÔNG chạy 4 tác vụ nặng đồng thời. Ưu tiên 1 việc chính + 1 việc phụ; 2 việc còn lại giữ thành quả, chưa mở rộng.**
> Đây là văn bản **handoff/điều phối**, không phải cấp phép merge, không tự thay đổi authority gameplay, và không tuyên bố CODE đã được thực thi.
>
> Ngày ghi nhận: **2026-10-21**. Nhánh tài liệu: `docs/tmb-status-20261021-v5-sa-lib`. `main` được xác minh gần nhất ở `461caca1171462e0da092f21108c5c1733157ad9` (kiểm tra lại HEAD khi quay lại).

## 1. Bốn luồng và lựa chọn cuối cùng

| Thứ tự | Luồng | Quyết định hiện hành | Phạm vi chính | Điều kiện chạy |
|---|---|---|---|---|
| **P0 / CODE chính** | **B2.2 + B2.3 Spawn & Loot Runtime** | **ƯU TIÊN SỐ 1** | Editor hoàn chỉnh; quái hồi sinh độc lập; sự kiện kill; per-kill loot; ledger receipt; Warehouse; save/load sandbox; focused regression | Một chủ code cho các file combat/hunting/state/save; cô lập nhánh; không đụng V5 |
| **P1 / phụ** | **SA-LIB-01 Source A Spine Library** | **LÀM KHI MÁY RẢNH** | Chuyển Spine→Godot theo từng batch nhỏ; giữ catalog, hash, QA, cache/resume, pack dùng chung | 1 converter/Godot process nặng tại một thời điểm, đủ RAM/disk; không song song với B2.3 Godot test |
| **P2 / hold** | **Combat V5.1 Source A** | **GIỮ NGUYÊN KẾT QUẢ** | Scene/presentation, camera, animation Source A; chờ owner visual review và tích hợp B2.3 | Không tự tiếp tục polish vô hạn; không merge khi chưa nghiệm thu/QA |
| **P3 / hold** | **Character Studio V2** | **GIỮ KẾT QUẢ / CHỜ PACK** | Preview nhân vật, clip/skins, asset resolver, preset | Chỉ mở rộng khi SA-LIB đã xuất approved pack đủ dùng; không chuyển Spine riêng trong Studio |

**Khóa phạm vi:** Khi trở lại, bắt đầu từ **B2.3**. Source A chạy nhẹ và có checkpoint khi điều kiện phần cứng cho phép. Không khởi động lại từ đầu V5.1 hoặc Character Studio. Nếu người dùng đưa ZIP mới, cập nhật trạng thái theo đúng bằng chứng SHA mới trước khi thay đổi thứ tự.

### Vì sao B2.3 đứng đầu?

Mục tiêu không phải có thêm 10.000 animation; mục tiêu là **vòng chơi thật**: phân đội săn → gặp quái → chiến đấu Combat V2 → quái chết và hồi sinh độc lập → mỗi kill xét đồ một lần → nhập kho Tông Môn → chế tạo/nâng cấp → tăng sức mạnh → săn vùng khó hơn. Chỉ khi đó mới đo được cảm giác chơi và cân bằng B3.

## 2. Tiến độ tại thời điểm tạm dừng — PHÂN BIỆT ĐÃ LÀM / CHƯA XÁC MINH

### 2.1 B2 Spawn & Loot (nhiệm vụ chính)

- B2 EditorPlugin MVP có review ZIP cũ `TMB_B2_SPAWN_LOOT_STUDIO_REVIEW.zip`; có dock, schema/catalog, flat-map preview, drop simulator, validator và focused test Godot 4.7.2 PASS ở MVP.
- Tác vụ kế tiếp lớn **B2.2 + B2.3** đã được giao prompt riêng: `TMB_TASK_B2_2_3_SPAWN_LOOT_2026-10-21.md` (tệp handoff trong cuộc trao đổi, không giả định đã merge lên GitHub). **Chưa nhận ZIP mới chứng minh hoàn thành runtime** trong checkpoint này.
- Phạm vi CODE đã hướng dẫn: hoàn thiện editor thao tác trực quan, phát triển opt-in sandbox `SpawnDirector`, `PerKillLootResolver`, `KillReceiptLedger`, snapshot + migration; kiểm tra duplicate kill, DoT/projectile, deterministic RNG, safe ledger/warehouse/retry, viewed/unviewed equivalence, 40 quái/encounter. Các tên module chỉ là đề xuất; quyền sở hữu state authority V2 vẫn phải được tôn trọng.
- **Tỷ lệ rơi/recipe B3 chưa khóa**, chỉ được dùng fixture thử nghiệm có nhãn SANDBOX, không tự đưa lên production.

### 2.2 Source A Spine Library (nhiệm vụ phụ)

- Review ZIP: `TMB_SOURCEA_SPINE_LIBRARY_REVIEW_20261021.zip`; SHA-256 `080c1bc2479f77614a941a096056f75161bf248a2c4ce6af98b0f61d6050b979`.
- **Đã index 6.578 rig / 20.507 file;** 5.328 source READY; 1.250 REVIEW; có 11 duplicate aliases. Không thấy file nguồn MISSING. **Đây là số SOURCE**, không phải 5.328 đầu ra Godot đã convert.
- 10 rig Batch-01 có **QA PASS lịch sử**; **0 output đã QA theo fingerprint converter hiện tại** tại thời điểm bàn giao. Chưa chuyển hết kho.
- CLI/catalog/schema/cache/resume/sample packs đã có. GitHub tooling branch `sa-lib-01-sourcea-spine-library-20261021` @ `87d6b60123c85930e9eb571949f4aafbb8f8ac7d`; chưa PR/merge.
- Batch từng bị chặn khi chỉ có **1.359 MiB RAM rảnh, 5 Godot processes**, cần ít nhất **2.200 MiB RAM** theo gate hiện hành. Không yêu cầu dùng máy lúc này.
- Khi quay lại: lưu việc của các editor, kiểm tra tiến trình, chạy `Run-SourceA-Library.cmd status`; nếu safe gate PASS thì QA/fingerprint 5–10 rig trước, sau đó resumable batches; không kill process mù, không hạ safety threshold, không chạy 82,5 giờ không kiểm soát.
- 66 catalog metadata chunks đang cục bộ, **CHƯA upload lên GitHub**. Không tự upload lại hoặc lách giới hạn; cần ủy quyền riêng cụ thể cho điểm đến.

### 2.3 Combat V5.1 (giữ kết quả)

- Review ZIP `TMB_V5_1_VISUAL_FINAL_REVIEW.zip`; SHA-256 `9c57d930492343388594e0543aadd588793223b61ded285b506852219e5c7294`.
- Camera pan/zoom/follow/deselect/reset-signal; nền Source A nhẹ hơn, bóng chân, actor Y-sort, nameplates/selection improvements; captured 1280×720; focused pilot test PASS. V5.1 vẫn **local dirty** trên `feature/v5-1-sourcea-visual-finalization`, dựa trên V5 HEAD `ae3f397cef654cd3ff1936261b018476a132e7db`. Không được coi là commit đã ở remote.
- 3 baseline tests One Active Job / hunting UI / GP-02C1 T15_PLANT **FAIL trên cả base và V5, cùng signature**. Không tự coi đã sửa hay quy lỗi cho V5.1. Cần packet riêng nếu muốn sửa.
- **Owner visual PENDING**. Người dùng chấp nhận nhân vật che nhau tự nhiên một phần nếu có **bóng chân và vị trí chân thật riêng**, không cần đội hình giãn cứng hoặc offset sprite giả. Manual reset click và hiệu năng Android vẫn PENDING.
- Giữ presentation, không tiếp tục sửa animation/camera vô tận trước khi B2.3 có game loop thật.

### 2.4 Character Studio V2 (giữ kết quả)

- MVP cũ có ZIP `TMB_CHARACTER_STUDIO_REVIEW.zip`, focused test PASS. Nhánh Character Studio V2 đã được giao prompt riêng `TMB_TASK_CHARACTER_STUDIO_V2_2026-10-21.md`, **chưa có ZIP mới xác nhận V2 hoàn tất** trong checkpoint này.
- Không làm converter Source A thứ hai; sau khi SA-LIB có pack Godot QA PASS mới, Character Studio chỉ cần resolver/preview từ catalog được publish.
- Không chỉnh DiscipleState/save/hidden identity hoặc thay character authority V2.

### 2.5 B3 kinh tế săn đồ và trang bị (thiết kế)

- Hướng thiết kế tạm làm việc: **kết hợp** farm/chế tạo liên tục kiểu Evil Hunter Tycoon với rare boss/gear chase của Võ Lâm.
- 10 ô trang bị, 12 phẩm chất, 24 đồ bộ nằm trong spec có cấu trúc; code production hiện tại chỉ là pilot hạn chế. **Không tuyên bố toàn bộ B3 đã implement.**
- Sản lượng/giờ, rare rates, enhancement cap, recipe costs, Boss guarantee đều **cần playtest và quyết định owner**; không trộn với giá trị canonic khi chưa được duyệt.
- B3 vertical slice 3 vùng chỉ làm sau khi B2.3 per-kill ledger có bằng chứng kỹ thuật đầy đủ.

## 3. Lịch phân bổ công việc sau khi trở lại máy

1. **Không mở nhiều tác vụ nặng cùng lúc:** CODE/diff B2.3 có thể xử lý trong worktree riêng; khi cần Godot focused QA/GUITest, tạm dừng converter.
2. **Đọc ZIP mới nhất của B2.3:** kiểm tra trạng thái thực tế; nếu đã làm xong, chuyển từ implement sang kiểm toán+tích hợp; đừng giao lại code một cách mù.
3. **B2.3:** khóa per-kill contract/snapshot/warehouse exactly-once và chạy focused QA trong TEMP/save riêng; hoàn thiện runnable sandbox farm. Không chạm presentation V5 khi còn owner visual pending.
4. **SA-LIB:** trên giờ máy rảnh, chạy status, QA 5–10 mẫu current fingerprint và tiếp tục batch có giới hạn, xuất delta report.
5. **V5.1 & Character Studio:** giữ các ZIP và worktrees nguyên vẹn; chỉ chạm khi cần thực sự để nối gameplay và approved asset packs.
6. **Tích hợp:** một integration owner, diff/backup tracked+untracked; review `project.godot`, shared docs `CURRENT_CHECKPOINT.md` / `NEXT_CHAT_HANDOFF.md`, asset manifests và Combat V2 state/save; **không auto-merge**.

**Thiết bị:** Windows 8GB RAM/ổ E:; tránh song song converter + editor Godot, không chạy hard-stop làm mất save hoặc thay raw Source A.

## 4. Bất biến dự án — bắt buộc nhắc Codex

- Godot 4.7.2; Android landscape 1280×720; Source A visual authority; Combat V2 simulation truth.
- One Active Job; Injury 0/1/120 simulation ticks; Tu Vi 30×10 + Luyện Thể 30×10; nhóm 6 đệ tử; 30 đệ tử/40 quái trong giới hạn battle đang dùng.
- Canonical Warehouse không có giới hạn gameplay thông thường; vật phẩm unique giữ instance riêng; mỗi kill/reward phải idempotent, kết toán không nhân đôi qua save/load.
- Camera/animation/skin không quyết định damage, hit, attack speed, RNG hoặc loot.
- Source A raw giữ bất biến; catalog/index **không đồng nghĩa đã converted/QA PASS**.
- QA tập trung phần thay đổi, không CI/FULL mỗi lần; không gọi FAIL baseline là PASS; khi closure/integration có cross-subsystem change phải chạy gates thực sự.
- Không push/merge vào `main`, không upload catalog metadata nhạy phạm vi chưa được cho phép, không thực hiện tự động khi user đang không có máy tính.
- Mỗi Codex deliver ZIP chứa README, SHA, changed+untracked files, complete diff, docs, focused test logs, GUI screenshots nếu liên quan, SHA256SUMS và remaining debts.

## 5. Chỉ dẫn khởi động lại — PROMPT CHO CHATGPT (không cần user nhớ kỹ)

> **TÔNG MÔN BÁ ĐẠO — TIẾP QUẢN THEO CHECKPOINT NGÀY 21/10/2026.**
> Đọc `AGENTS.md` và `docs/handoffs/2026-10-21/TMB_PAUSE_RESUME_PRIORITY_B23_2026-10-21.md` trên nhánh `docs/tmb-status-20261021-v5-sa-lib`, cùng Master Program Checkpoint/SA-LIB Recovery/V5.1 Acceptance/Integration Roadmap trong cùng thư mục. Không hỏi tôi lặp lại tiến độ. Ưu tiên **B2.3 Spawn & Loot là CODE chính**, **Source A Spine Library là phụ khi máy đủ điều kiện**, giữ Combat V5.1 và Character Studio V2 chờ tích hợp. Trước khi giao Codex, kiểm tra các ZIP mới và SHA/worktree hiện tại, xác định công việc thật còn thiếu. Không sửa code/merge khi chưa có packet tương ứng. Đưa prompt Codex hoàn chỉnh và thứ tự QA tối thiểu; duy trì tài liệu checkpoint GitHub.

## 6. PROMPT CODEX — TÁC VỤ CHÍNH B2.3 (chỉ gửi khi user trở lại Codex)

> TÔNG MÔN BÁ ĐẠO — B2.3 PRIORITY CONTINUATION. Đọc AGENTS.md, B2 Studio handoff và `docs/handoffs/2026-10-21/TMB_PAUSE_RESUME_PRIORITY_B23_2026-10-21.md` từ nhánh docs, đối chiếu Git HEAD và dirty worktrees. Tiếp tục từ kết quả thực tế mới nhất (không xóa/sáng tạo lại editor đã có). Ưu tiên opt-in runnable sandbox: individual monster respawn, deterministic per-kill loot, exactly-once receipt+warehouse, save/load migration, viewed/unviewed combat parity, focused regression. Không đổi Combat V2 damage/RNG/skills, không sửa V5 presentation hoặc Character Studio, không tự chốt B3 drop balance. Một writer cho từng authority combat/state/save. Không merge/CI/FULL; xuất `TMB_B2_3_RUNTIME_NEXT_REVIEW.zip` đủ patch, test, logs, screenshots và checkpoint Markdown.

## 7. PROMPT CODEX — TÁC VỤ PHỤ SA-LIB (chỉ gửi khi user trở lại máy)

> TÔNG MÔN BÁ ĐẠO — SA-LIB-01 SAFE RESUME. Đọc `docs/handoffs/2026-10-21/TMB_SA_LIB_01_RECOVERY_PLAN_2026-10-21.md` và checkpoint mới nhất. Không làm lại catalog/converter. Kiểm tra RAM, disk, Godot processes, save của Editor. Nếu đủ điều kiện (giữ nguyên 2.200 MiB RAM threshold), refresh current-fingerprint QA cho một số rig ưu tiên và thử 5–10 rig, xác minh playback Godot/skin on-demand, rồi chuyển theo resumable batches khi máy rảnh. Không tự kill 5 Godot processes hoặc bỏ guard, không upload catalog 66 chunk nếu chưa có phép, không sửa gameplay. Giao ZIP delta report/log/asset evidence/SHA và cập nhật checkpoint.

## 8. Tài liệu liên quan

- `docs/handoffs/2026-10-21/TMB_MASTER_PROGRAM_CHECKPOINT_2026-10-21.md`
- `docs/handoffs/2026-10-21/TMB_SA_LIB_01_RECOVERY_PLAN_2026-10-21.md`
- `docs/handoffs/2026-10-21/TMB_V5_1_VISUAL_ACCEPTANCE_2026-10-21.md`
- `docs/handoffs/2026-10-21/TMB_CROSS_STREAM_INTEGRATION_ROADMAP_2026-10-21.md`

**Nguồn chính:** ZIP review user đã gửi trong cuộc trao đổi và mốc GitHub/QA nêu trong các tài liệu trên. Khi trở lại phải kiểm tra commit/ZIP mới nhất; các giá trị ở đây chỉ đúng tới ngày ghi nhận.
