# TÔNG MÔN BÁ ĐẠO — 5 PROMPT CODEX PHỐI HỢP GIAI ĐOẠN TIẾP THEO

**Ngày 2026-10-22.** Status: **instructions to independent Codex workers**, not automatic authorization to merge or rewrite locked gameplay.  
**Repo:** `vuanhtuan161094-byte/TongMonBaDao` (read AGENTS.md + current HEAD at task start).  
**Design authority on this branch:**
- `docs/design/B3_V2_LIVING_SECT_CONTINUOUS_HUNT_ARCHITECTURE_2026-10-22.md`
- `docs/design/B3_V2_PERSISTENT_PVE_WORLD_RUNTIME_CONTRACT_2026-10-22.md`
- `docs/design/B3_V2_TEAM_AI_TARGETING_AGGRO_RECOVERY_CONTRACT_2026-10-22.md`
- `docs/handoffs/2026-10-22/TMB_FOUR_REVIEW_PACKETS_TRIAGE_AND_INTEGRATION_PLAN_2026-10-22.md`

## Quy tắc chung cho tất cả worker

1. Windows laptop **8 GB RAM** từng BSOD; **không chạy nhiều Godot/Spine converter cùng lúc**. Source A one-worker, 1–4 rig/batch khi RAM/CPU gate đạt; ưu tiên test focused, không FULL/CI trừ khi được duyệt riêng. Khi resource thiếu, chuyển sang audit/docs nhẹ, không kill tiến trình khác. Không dùng profile Administrator, dữ liệu làm việc ở **E:\TongMonBaDaoWorkspace\** nếu có.
2. Map, Character Studio, Source A và V5.1 là **4 luồng độc lập**. Một file chỉ một writer. B3 chỉ thiết kế packet tích hợp lúc này, **không sửa Combat/Scheduler/Save/Workforce/Map/Studio**. Không merge, không push lên main, không xóa/reset/stash dirty files của worker khác.
3. Đọc `AGENTS.md` và xác minh HEAD/worktree/manifest mới; không giả định `main` hay địa chỉ local không đổi. Không ghi `CURRENT_CHECKPOINT.md` / `NEXT_CHAT_HANDOFF.md` chung khi các worktree khác đang dirty; dùng handoff có tên riêng.
4. Phân biệt static audit, Godot focused test và owner visual acceptance. PASS đòi evidence có SHA/log tương ứng. Không tự gọi owner PASS hoặc sản phẩm production từ sandbox. Output cần mô tả phần đã làm, file thay đổi, diff/hash, pass/fail/blocker, next step.
5. **Gameplay khóa:** Combat V2 rules, continuous in-place Evil Hunter (không 90s/wave/battle reset), One Active Job, Injury 0/1/120 scheduler ticks, một kho Sect-owned, save/offline exactly once, đội <=6, không thay đổi khuôn mặt/rig giả, Android landscape 1280×720.
6. Nếu task cần quyền CODE ngoài phạm vi, ghi `BLOCKED_NEEDS_OWNER_CODE_AUTHORIZATION` cùng packet allowlist, KHÔNG tự mở rộng.

---

## PROMPT 01 — B3: lập packet tích hợp B2.4 → Persistent PvE World (CHÍNH, READ-ONLY/DESIGN)

**Dán riêng vào Codex ở worktree nghiên cứu mới, tránh worktree B2.3/B2.4 và V5.1.**

> TÔNG MÔN BÁ ĐẠO — B3 INTEGRATION PACKET REVIEW, DESIGN ONLY
>
> Đọc `AGENTS.md`, remote GitHub HEAD thực tế và 4 tài liệu B3 V2 trên nhánh `docs/b3-v2-architecture-redesign-20261022`, nhất là `TMB_FOUR_REVIEW_PACKETS_TRIAGE_AND_INTEGRATION_PLAN_2026-10-22.md`. Đọc ZIP local `TMB_B2_4_HUNT_LOOP_REVIEW.zip` tại E: nếu tồn tại; nếu không, dùng bản ZIP đã được user bàn giao. Chỉ phân tích source_snapshot, diffs, log, manifest và tests; không import ZIP đè lên source, không sửa worktree dirty.
>
> Xác nhận patch B2.3/B2.4 hiện có: `continuous_mode`, per-instance spawn/remove, death IDs, receipt ledger, snapshot V2 read-V1; phân biệt phần CODE đã có với phần sandbox. Không viết lại Combat V2, không tạo battle 90s, không nối battle/reset, không tính loot bằng UI events capped, không dùng 100% `linh_moc` synthetic vào production.
>
> Lập **MỘT integration design/code-authorization packet** cho bước nhỏ nhất đưa B2.4 đến PvE thực: 1 canonical V2 disciple (hoặc đội thật hợp lệ), 1 real monster source, 1 world lưu lâu >90s không reset, slot respawn độc lập, true per-kill immutable receipt, canonical Warehouse + SaveService transaction và test save/reload chống nhân đôi. Ghi module reuse-vs-gap, exact parent SHA, exact allowlist/disallowlist, new migrations v1/v2, RNG/clock/ledger authority, compatibility với legacy encounters, 8–12 focused tests với tiêu chí PASS, cách rollback, owner integration writer. Nếu source loot thật chưa có, tách gate content và không bịa loot table/tỷ lệ.
>
> Lập ma trận xung đột file với V5.1/Character Studio/Map, đặc biệt `project.godot` plugin union, `MapBattleSnapshotV2` v1/v2, 3 regression signatures (One Active Job/Hunting UI/GP-02C1) khác SHA. Không chạy CI/FULL/Godot nặng. Chỉ làm tài liệu trên **docs-only branch riêng** có commit hoặc tạo packet ở đường dẫn handoff rõ ràng; không CODE/merge/push main. Bàn giao link docs SHA và danh sách quyết định owner cần ký để cấp quyền CODE bước tiếp.

---

## PROMPT 02 — SOURCE A: chuyển đổi tối ưu + chọn asset đúng loại (PHỤ, SINGLE WORKER)

> TÔNG MÔN BÁ ĐẠO — SOURCE A CURATED READY BATCH + LIGHT QA
>
> Làm việc CHỈ trong `E:\TongMonBaDaoWorkspace\03_AssetLibrary\SourceA\`. Đọc checkpoint `reports/overnight_20261022/CHECKPOINT_2026-10-22.md`, report, DB/catalog và fingerprint converter `54b0575661a2384e13595eefb3d327e2bc7b29d417329a29814ac481b25839b1`. Không chạy lại 36 current PASS hoặc 9 historical như PASS current. Hiện trạng: 36 current PASS, 1 crop FAIL `2123019_10` ở 768; skin 12 lựa chọn chỉ 1536 FULL PASS. Còn 5.273 READY chưa thử do resource, 914 PARSE_REVIEW là *phân loại*, KHÔNG phải 914 file đã chứng minh hỏng.
>
> Ưu tiên catalog dạng **GAME-USEFUL**: đệ tử nam/nữ, quái thường, Elite/Boss có các clip thật `stand/walk/attack/hit/dead`; phân biệt `CONVERTED_PASS`, `ANIMATION_SET_COMPLETE`, `STUDIO_COMPATIBLE`, `VISUAL_QA_VERIFIED`, không coi mọi converted rig là actor combat usable. Xuất catalog CSV+MD với rig ID, loại actor nếu có evidence, list clip/missing, source path/hash, atlas resolution/pivot/foot marker, output manifest/QA fingerprint, proposed link Studio/V5. Không tự gán quái làm đệ tử hoặc Boss canon khi thiếu metadata.
>
> Nếu resource gate xanh ổn định, chỉ **1 worker, batch 1–4 READY mới**, `--qa-mode fast`, checksum/parser/manifest minimal, resume/skip cùng fingerprint, lưu checkpoint sau mỗi batch. FULL/Godot sample 1 rig đại diện chỉ khi converter thay đổi hoặc mẫu/canvas có rủi ro; không chụp hàng nghìn ảnh. Nếu resource dưới gate, CHỈ catalog/triage metadata; không ép chạy làm Windows hết RAM, không kill process. Giữ shutdown nếu còn lịch tác vụ, không tự đặt hẹn mới.
>
> Với 914 PARSE_REVIEW, chỉ chọn 5–10 mẫu chia nhóm lỗi lặp, ghi parser version/offset/signature, phương án sửa chung ở báo cáo. **Không sửa parser toàn kho hoặc chạy batch REVIEW** khi chưa có bằng chứng và scope. Không ghi đè raw Source A, không động Map/Studio/V5/Combat. Output một report + catalog usable + tổng số current PASS/FAIL/SKIP/READY chưa thử + một ZIP/checkpoint duy nhất (nếu cần), hash và đường dẫn E:. Không push/merge.

---

## PROMPT 03 — CHARACTER STUDIO V2: xác minh rig nữ và clip, FIX SCOPED

> TÔNG MÔN BÁ ĐẠO — CHARACTER STUDIO V2 SHA PROVENANCE AND CLIP COMPATIBILITY
>
> Sử dụng **worktree riêng** của `feature/dev-character-studio-v2`, local commit báo cáo `18bf8929e0d20464783ce318a79018b080fab0c3`; kiểm tra HEAD/status thực tế trước thay đổi, không tự reset hoặc add file dirty ngoài phạm vi. Đọc ZIP `TMB_CHARACTER_STUDIO_V2_REVIEW.zip` / Source A manifest được owner cấp quyền và handoff. Mục tiêu hẹp: tìm nguyên nhân rig nữ `1113028_1` có `actor.tscn` và `animations.tres` khác SHA V5, trong khi `asset.json` và atlas khớp. So sánh byte/hash theo version, import artifacts và recipe chuyển đổi để phân biệt stale manifest, generated scene khác revision hoặc corrupt pack. **Không sửa hash trong manifest cho khớp giả; không mark VERIFIED khi chưa giải quyết provenance.**
>
> Xác minh 7 rig (6 VERIFIED/1 UNVERIFIED) và 42 rig-clip combinations (22 VERIFIED, 2 UNVERIFIED, 18 MISSING) từ gói ban đầu. Ghi rõ clip thực có/thiếu, nữ `attack1/hit/dead` combat đã verify **không** đồng nghĩa base `stand/walk` composite verified. Xác định bộ tối thiểu nam/nữ sử dụng được cho gameplay; kiểm tra có evidence layerable outfit hay không, tuyệt đối không tự nhận có source layer.
>
> Chỉ được sửa **trong plugin/manifest/test thuộc scope Studio** sau khi xác minh chính xác nguồn và có bằng chứng tái lập. Không sửa converter Source A, V5, Combat, `SaveService`, birth-profile hoặc `project.godot` shared nếu đang có writer khác. Nếu lỗi nằm phía V5/Source A, lập issue/handoff thay vì sửa chéo. Chạy focused Godot 4.7.2 ở lượt riêng khi Source A không chạy nặng; trình bày before/after hash, cảnh/clip thực chạy, QA, 1280×720 evidence khi thích hợp; không mark owner PASS. Commit scoped trên local feature branch; **không push/merge**. Ngoài phạm vi `tools/godot/Verify-P3-6A-Playable-Slice.ps1` phải giữ nguyên.

---

## PROMPT 04 — V5.1: cải thiện khả năng nhìn trên ảnh (SCOPED VISUAL, KHÔNG ĐỤNG GAMEPLAY)

> TÔNG MÔN BÁ ĐẠO — V5.1 VISUAL USABILITY REFINEMENT / IMAGE QA
>
> Trên worktree `feature/v5-1-sourcea-visual-finalization`, báo cáo HEAD `ae3f397cef654cd3ff1936261b018476a132e7db`, xác nhận HEAD/status/diff và đọc ZIP `TMB_V5_1_VISUAL_FINAL_REVIEW.zip`; giữ nguyên dirty source và sidecar không thuộc phạm vi, tuyệt đối không hard reset. Chủ sở hữu visual vẫn PENDING.
>
> Chỉ xử lý lỗi **hình ảnh** đang thấy trong ảnh bằng phạm vi file UI/presentation do nhánh V5.1 sở hữu: (1) cụm 6 đệ tử chồng sprite khiến tên/HP nhòe; ưu tiên nhãn HP/name đúng chân/actor, độ ưu tiên nhãn được chọn, xử lý overlap UI (không đẩy vị trí chiến đấu giả); (2) Boss telegraph che silhouette, cải thiện draw order/alpha rõ nguy hiểm mà nhìn rõ nhân vật, giữ nguyên telegraph gameplay authority; (3) bớt lặp họa tiết đá sáng nếu sửa được ở presentation riêng, không thay nền chuẩn Source A; (4) kiểm tra reset camera bằng input thật và một capture animation có FPS cao hơn GIF 2fps. Không thay luật damage/V2, spawn/loot, AI/Save, collision hoặc rig/Source A.
>
> Trước sửa tạo inventory files + conflict matrix với Map workstream. Nếu file cần sửa có owner Map/Studio hoặc chưa rõ writer, **dừng phần file đó, ghi blocker**, không tự mở rộng scope. Sau thay đổi, focused QA Godot 4.7.2, capture trước/sau cùng camera ở 1280×720, cảnh nhiều đệ tử, Boss telegraph, pan/zoom/reset/follow, log/event thật, p95/frame metric. Không gọi 3 regression `One Active Job`, `Hunting UI`, `GP-02C1 T15_PLANT` PASS chỉ vì B2.4 dùng SHA khác; ghi riêng baseline fail.
>
> Xuất one review ZIP/report với before/after PNG, clip/video hoặc GIF FPS thực, hash/changed files và owner-visual checklist. Giữ OWNER VISUAL PENDING cho đến khi người chơi duyệt. Chỉ commit scoped khi evidence đầy đủ và owner scope không xung đột; **không push/merge**, không claim performance Android từ Windows capture.

---

## PROMPT 05 — MAP: kiểm kê luồng hiện hành, CHỈ READ-ONLY

> TÔNG MÔN BÁ ĐẠO — MAP WORKSTREAM HANDOFF, READ-ONLY STATUS
>
> Tôi đang có riêng luồng Map, B3 backend, Character Studio và Source A. Hãy tìm đúng worktree/branch Map đang thực hiện theo trạng thái hiện tại, đọc AGENTS.md và Git status/HEAD, current handoff, ảnh test/asset manifest thực có; **không sửa bất cứ file nào** và không chạy game/CI nặng trên máy 8GB. Phân biệt `192×192` sect management isometric map với **PvE farm map phẳng không địa hình cản/pathfinding**. Không tự redesign map đã làm.
>
> Bàn giao một report ngắn: công việc Map đã hoàn thành/chưa hoàn thành, scene/feature cụ thể, snapshot thực tế và QA, mỗi nút pan/zoom/selection/actor foot XY, spawn anchor metadata B3 cần (chỉ contract design), xung đột file với V5.1/Character Studio, cần owner visual signoff nào, bước nhỏ kế tiếp của Map. Không gọi Map PASS nếu chưa có evidence. Không cherry-pick/commit/push/merge, không chạm B3 gameplay/Source A/Studio.

---

## Thứ tự vận hành và điểm dừng

- **Chạy Prompt 01 trước** (read-only B3 integration packet); có thể chạy Prompt 05 song song vì read-only. Trên laptop 8GB, Prompt 02 (converter), Prompt 03 (Godot Editor), Prompt 04 (V5 Godot capture) **chạy lần lượt**, không đồng thời.
- **Prompt 02 tiếp theo** cho Source A; khi có verified pack catalog thì **Prompt 03** dùng thông tin để fix nữ; **Prompt 04** visual refined khi biết không trùng file Map. Prompt 05 kết xuất status map.
- **B3 CODE** chỉ sau khi owner duyệt packet chi tiết Prompt 01, một integration writer, phạm vi file, nguồn content thật, migration, kế hoạch official focused tests. Không tạo đợt 90 giây mới.
- Gửi lại 5 handoff report/ZIP và hash; review tập trung vào **một first real-world continuous hunting proof** trước khi mở rộng 30×10 content.
