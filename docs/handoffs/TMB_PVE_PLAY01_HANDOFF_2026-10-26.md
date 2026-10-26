# TÔNG MÔN BÁ ĐẠO — PVE-PLAY-01 — BÀN GIAO SANG CHAT MỚI

**Ngày chốt:** 2026-10-26 (GMT+7).  
**Mục đích:** Một checkpoint tài liệu đọc từ GitHub để chat mới/Codex tiếp quản mà không phải lục lịch sử hội thoại.  
**TRẠNG THÁI:** Đã có bản P3.2 + PvE Source A chạy được theo bằng chứng QA Codex, **người dùng đã mở game và phản hồi khó tìm lối săn, vẫn giật**. KHÔNG tuyên bố `PLAYABLE_PASS`.  
**Ưu tiên hiện hành:** **PVE-PLAY-01.1 — LỐI VÀO SĂN QUÁI DỄ THẤY + GIẢM KHỰNG KHI CHƠI THẬT + NGHIỆM THU CHUỘT/SAVE/RETURN**.

## 1. Repository / commit authority

- Repository: [vuanhtuan161094-byte/TongMonBaDao](https://github.com/vuanhtuan161094-byte/TongMonBaDao), Godot **4.7.2**, mục tiêu Android landscape 1280×720 nhưng hiện QA chủ yếu Windows 1280×720.
- **Codex Windows PvE branch:** `feature/pve-jx-continuous-world-20261026`; SHA GitHub đã xác minh khi bàn giao: **`b91d60a66fd5afc94be8ce1b6b16fad81d3b3f6a`**. Codex báo local HEAD = remote HEAD, tracked clean tại checkpoint. **Không suy ra máy vẫn clean về sau**: đọc `git status` thực tế trước mọi tích hợp.
- **Integration branch riêng của ChatGPT:** `integration/pve-play01-audit-gates-20261026`, HEAD **`94db3b5c2ee9b22567781cb10e4a753b8a78bece`**, xuất phát từ b91d60a. Có **13 commit / 12 đường dẫn thay đổi**, **chưa chạy Godot 4.7.2** với chính SHA này. Chưa merge.
- **`main` ở thời điểm chốt:** `29b5fba448b0178cb520a4ada44b375b4b934e31` — **KHÔNG merge/reset/force push main**.
- Nhánh tài liệu này xuất phát từ b91d60a, chỉ lưu handoff, **không chứa bản vá tích hợp 94db**.
- **Điểm điều phối:** [GitHub Issue #37](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37). Feedback người dùng thật đã lưu [comment #6421062443](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37#issuecomment-6421062443); bản rà soát/tích hợp [comment #6419464467](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37#issuecomment-6419464467); kết quả Codex [comment #6418071970](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37#issuecomment-6418071970).

## 2. Gameplay / phạm vi LOCKED

- Game quản lý tông môn dùng hình **Source A / Tông Sư Tiên Môn**; tận dụng VFX nguyên bản JX/JXQY, đặc biệt **JX Ngự Kiếm Thuật #158** cho `skill_cast → projectile → positive_hit → impact`. Người dùng đã chốt phong cách Source A, **không vẽ lại renderer/map hoặc chuyển pixel art**.
- **Combat V2 vẫn là authority**: damage/HP, tick/cooldown, active job, Injury **0/1, hồi 120 tick**, SaveService, canonical warehouse/reward, exactly-once; visual events **không** được tạo sát thương, thưởng hay thời gian giả.
- PvE mục tiêu hiện tại: **P3.2 sản xuất → Thanh Trúc Lâm Source A 192×192, 20 vùng / 16×16 chunks → đội 6 đệ tử V2 thật vs 10 quái thật → click ra lệnh di chuyển, chiến đấu liên tục, VFX JX #158 → lưu game/return**. Không mở thêm U01, Forge, 400 quái, nhiều skill, UI/asset overhaul trước Playable 0.1.
- `LOOT_PENDING` là phạm vi cố ý chưa triển khai; không tự tạo drop/reward để che lỗi.

## 3. Những gì Codex đã code / đo được (phân biệt evidence)

**Checkpoint b91d60a theo báo cáo Codex + Issue #37:**
- `Run-PVE-Play.cmd` mở **main game P3.2** (KHÔNG phải `Run-PVE-JX-World.cmd` JXQY2 snow pilot cũ) với **save QA riêng, roster 130**.
- PvE map dùng Source A, camera/minimap, 6v10, Combat V2, JX #158 cast/hit/impact; cache navigation/topology/minimap theo source SHA/map identity. Log: 83 lượt gọi `prepare_world`, chỉ 1 lần build topology, 0 lần build lại minimap.
- Khu sản xuất chỉ materialize tối đa actor đang chọn; không chọn ai thì 0 actor render, nhưng simulation và các công việc vẫn chạy.
- **Godot 4.7.2 chính xác SHA b91d60a**: Codex báo `pve_multicamp_p3_2_live_integration_test.gd` **PASS, exit 0** và `pve_open_world_save_identity_contract_test.gd` **PASS, exit 0**, identity có 9 checks. Các test culling/JX adapter/topology có bằng chứng PASS **trên commit cha c5ee92e**, không tự chuyển kết quả sang 94db.
- Codex đo **59.29 FPS trung bình** từ **221 cửa sổ đo 3 giây** của P3.2; **16.87 ms/frame trung bình**, RAM báo **~589 MiB**, có **frame spike 149.7 ms**. PvE GUI không dùng MovieWriter (trên commit cha) báo **60.10 FPS trong 10 giây**, JX cast=1, positive hit=1, impact=1. Kết quả **2.17 FPS** trước đó xuất phát từ MovieWriter, không được so trực tiếp.
- **Chưa có** p95/p99/1%-low trong trial PvE 30–60s; chưa có nghiệm thu chuột thật, Save/Return qua GUI hoàn chỉnh; Computer Use đã timeout. GUI/VISUAL/PLAYABLE vẫn **PENDING / user báo STUTTER**.
- Video/ảnh QA trước đó đã được Codex ghi vào ổ E và có GitHub notes, nhưng đường dẫn `E:\...` trong báo cáo là **đường local, không phải URL tải cho điện thoại**. Không tuyên bố đã trực tiếp xem/chạy video mới khi chưa có file được tải lên.

## 4. Hướng dẫn người dùng ĐI TỪ SẢN XUẤT VÀO SĂN (đọc từ source thật)

**Đường vào hiện có (source b91d60a):**
1. Mở `Run-PVE-Play.cmd` từ worktree Codex `E:\codex\2026-10-26\TMB_PVE_JX_CONTINUOUS_WORKTREE_20261026\` (đường dựa trên checkpoint được người dùng/Codex cung cấp).
2. Màn P3.2 **sản xuất** → menu dưới cùng **`Đệ Tử`** (trong `p3_1_landscape_sect.gd::_bottom_action("disciples")`, tự chọn đệ tử đầu tiên).
3. Chọn đệ tử **V2 thật, khỏe, rảnh, trong tông, không bị thương và không có One Active Job**. Tại hồ sơ đệ tử, chọn **`Săn tổ đội · 10 quái`** (button `SummaryCampHunt` gọi `_start_multicamp_hunt_for_selected`).
4. Nếu đang có đội đó trong world, nút là **`Mở bãi đang săn`**. Trong PvE click đất để ra lệnh di chuyển; dưới panel có **`Lưu game`** và **`Về tông môn`**.
5. Nếu nút bị vô hiệu hóa: có thể đang làm việc/luyện thể/đang thương/đang ở ngoài tông/đã có một B3 CARE hay PvE team khác. Chọn một đệ tử rảnh, không tự cancel job hay bỏ qua điều kiện.

**UX defect đã xác nhận bằng source:** menu **`Thế Giới`** trong thanh dưới hiện gọi `_open_building(DEST_GATE)`, **không mở Thanh Trúc Lâm**. Đường săn bị chôn trong hồ sơ đệ tử; production còn render 0 diễn viên nếu chưa chọn ai → khó thấy cách vào PvE. Cần làm **nút `Săn quái / Thanh Trúc Lâm` hiển thị trực tiếp trên tông môn hoặc từ `Thế Giới`**, vẫn giữ cách vào cũ và dùng hợp đồng eligibility V2; nếu không đủ điều kiện thì hiện lý do và danh sách đệ tử có thể chọn.

**Hạn chế hình ảnh còn tồn tại:** source `_build_b3_hunt_panel` đã kiểm tra ở b91d60a vẫn đặt map **700×484** bên cạnh panel thông tin **382×484** trong overlay **1152×644**. Báo cáo mô tả “near full screen” áp dụng cho **vỏ overlay**, chưa chứng minh *bản đồ chiến đấu* chiếm gần toàn màn hình; đánh giá bố cục qua screenshot thật, không tự làm lại renderer.

## 5. Bốn gói sửa độc lập và quyết định tích hợp

| Gói | Exact SHA | Xử lý trên Codex b91d60a |
|---|---|---|
| PERF-01.1 | `2b455682208c12d51d5f682f99694565887e0cfc` | Codex đã có cache topology/minimap, cache Source A atlas, culling/VFX mới. **KHÔNG cherry-pick renderer/atlas cũ**. |
| SAME-CLOCK-01 | `7038e8788df0b0c1c2412e72bd1fba3f320f1140` | GUI harness b91 vẫn gọi `visual_session.advance(true)` ngoài owner clock. **Nhánh tích hợp 94db đã port logic** sang `runtime.poll()`, có assertions same timestamp/save parity. Chưa chạy Godot trên 94db. |
| SAVE-01 | `c90ab907436fc4d92ca51c345c5eef728834008c` | Codex **đã tự đưa vào b91**, gồm source SHA/map identity và regression test. **KHÔNG nhập lại**. |
| PERF-02 | `8c0582be3b4e008bb843495904c0a63db3eb23ca` | Nhánh 94db có bản sao QA-only runner `Run-PVE-FPS-QA.cmd`, probe JSONL p50/p95, launcher riêng, focused stats test. **Chưa chạy**; không thay `Run-PVE-Play.cmd`. |

**Bổ sung chỉ trên nhánh tích hợp `94db3b5c`**:
- Sửa lỗi adapter JX: `_suffix_prefix_overlap()` cũ luôn trả >=0 khi hai event ring khác nhau, khiến old cast/hit của cùng encounter có thể phát lại khi Save/Restore. Trả -1 khi **hai ring không rỗng mà không có overlap thật**; regression test `pve_jx_sword_vfx_adapter_test.gd` mở rộng.
- Sửa Source A death clip `die` bị reset thời điểm bắt đầu mỗi lần HUD snapshot và trạng thái actor bị kéo từ encounter trước; test `pve_sourcea_death_snapshot_contract_test.gd`.
- **Không chạy Godot trên SHA 94db**; đây là bản chuẩn bị tích hợp, không phải gameplay release và không được merge `main` vô điều kiện.

**Chi tiết diff nhánh tích hợp:** https://github.com/vuanhtuan161094-byte/TongMonBaDao/compare/b91d60a66fd5afc94be8ce1b6b16fad81d3b3f6a...94db3b5c2ee9b22567781cb10e4a753b8a78bece

## 6. Đánh giá hiệu năng đúng cách (feedback thực tế > FPS trung bình)

**Người dùng ngày 26/10:** “T không biết từ sản xuất vào săn bắt kiểu gì. Với game còn giật lắm.” Chưa có bản ghi video màn hình thực 10–15 giây do người dùng gửi trong chat.

- **149.7ms/frame** tạo ra giật cảm nhận được ngay cả khi average ~60 FPS. Không lấy avg FPS hay FPS MovieWriter làm điều kiện nghiệm thu.
- QA chuẩn: **15–20 giây sản xuất + 30–60 giây PvE đang đánh/di chuyển/zoom + Save/Return và 10 giây sản xuất**, GUI interactive 1280×720, **không MovieWriter**; đo p50/p95/**p99**, 1%-low, max frame, số frame >33.3/50/100ms, root cause spike theo thời điểm, process/render/cache/memory. So sánh performance logging bật/tắt để loại overhead.
- Target mục tiêu: ổn định ~30 FPS trở lên, p95 quanh hoặc dưới 33.3ms khi chơi thực; không tự tuyên bố đạt.
- Trong Godot kiểm tra profiler chỗ `_refresh_b3_hunt_panel`, `_process`, SubViewport, static draw queue/chunk culling, shader upload/stalls, combat VFX, atlas, capture/record overhead. Không giảm chất lượng Source A hay vô hiệu Combat V2 theo phỏng đoán.
- Tool `Run-PVE-FPS-QA.cmd` từ 94db chỉ để bổ sung dữ liệu, **chưa được QA**; nếu launcher chưa chạy, ưu tiên dùng công cụ đo hiệu năng đã có ở Codex và sửa probe riêng.

## 7. Test gates cần chạy trên Windows Codex **sau khi đảm bảo trạng thái worktree**

1. `git status --porcelain=v1 -uall`, đọc HEAD, giữ nguyên file dirty/untracked, backup khi cần; không reset/clean/force-push.
2. Review nhánh tích hợp `94db` so với **current local HEAD**, chỉ port missing hunks (không tự merge toàn bộ). Confirm Save-01 đã có.
3. Official Godot **4.7.2**, focused tests (exact integrated SHA):  
   `res://tests/presentation/pve_multicamp_p3_2_live_integration_test.gd`,  
   `res://tests/presentation/pve_jx_sword_vfx_adapter_test.gd`,  
   `res://tests/presentation/pve_sourcea_death_snapshot_contract_test.gd`,  
   `res://tests/presentation/pve_perf_probe_contract_test.gd`,  
   `res://tests/simulation/pve_open_world_save_identity_contract_test.gd`,  
   `res://tests/simulation/dv2_03_runtime_clock_test.gd`, `dv2_03_live_runtime_integration_test.gd` và các suites Save nếu liên quan.
4. Vào **P3.2 game thật** bằng chuột: thấy lối `Săn quái` rõ ràng → chọn 6 V2 hợp lệ → C01 Source A 10 quái → click di chuyển/đánh, JX #158 cast → positive hit → impact → Save/Return/Reload và kiểm tra không nhân đôi reward.
5. Lưu ảnh/video **GUI thật** (không giả gameplay bằng MovieWriter), log Godot, frame-time p95/p99, RAM, exact SHA; nếu vẫn khựng hoặc không thể click vào PvE, ghi **PLAYABLE_BLOCKED**.

## 8. Quy tắc phối hợp người dùng / Codex / chat mới

- Người dùng ưu tiên **assistant trực tiếp code/review GitHub** khi hợp lý; không lặp quá nhiều báo cáo/thiết kế/prompt nếu công việc có thể code.
- Tuy nhiên **khi máy mở và Codex đang chạy**, phải giữ nguyên local Codex worktree; GitHub read/branch độc lập, chờ checkpoint trước tích hợp. Không merge `main`, không xóa asset, không remake renderer.
- Báo trung thực `SOURCE_REVIEWED`, `COMMITTED`, `GODOT_QA_PENDING`, `GUI_PENDING`, `PLAYABLE_BLOCKED`; **không báo PASS nếu chưa có log runtime đúng SHA**.
- Sau **mọi báo cáo**, **luôn đưa options A/B/C** rõ ràng, có **1 khuyến nghị ưu tiên**, để user chọn dễ dàng (ưu tiên A: lối vào săn + stutter; B: phân tích video/log; C: kiểm tra sâu Combat/VFX nếu A đã đạt).
- User có thể gửi **1 ảnh màn hình sản xuất** và **video quay màn hình thật 10–15s khi giật**. Không bắt user tự tìm log nếu Codex có thể thu tự động.
- Nếu xem file/thư mục ổ E từ GitHub/Cloud, **không giả định có quyền đọc đường dẫn Windows local**. Chỉ nói đã xem khi tool truy cập được đúng dữ liệu.

## 9. Chỉ đạo đầu tiên của chat mới

**Tiếp quản từ file này + Issue #37, kiểm tra HEAD mới nhất trước tiên.** Chốt hai blockers người dùng: **(1) không tìm được nút vào săn trực tiếp; (2) vẫn khựng dù average 59 FPS**. Chỉ báo “đã hoàn tất” khi có bằng chứng GUI thật ở exact SHA. Nếu có thể, chủ động sửa UX entry nhỏ trên nhánh GitHub tách biệt (không ảnh hưởng local), bổ sung test, rồi phối hợp Codex. Không mở scope sang Forge, đồ rơi, gameplay V3 hoặc tái tạo Source A.
