# Archived Issue #56 body — 2026-11-04

> Verbatim capture before the release-train issue was shortened. This includes October RC legacy instructions, historical GitHub references, and R0–R5 plan provenance. **Not the current task authority.** See [Issue #56 live](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56) and [PR #72](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72). Original issue last updated `2026-11-04T07:08:56Z`.

---

<!-- RELEASE_TRAIN_20261104 -->
# RELEASE TRAIN → MAIN | CHUỖI HỢP NHẤT MỘT GAME

**Owner decision (2026-11-04):** Chấm dứt nhiều nhánh chức năng phân tán; đích đến là **một `main` có thể chạy/chơi và một launcher thật**. **PR #72 là tuyến phát hành duy nhất để tiếp tục sửa**, không tạo thêm một nhánh tích hợp/song song nếu không gặp trở ngại kỹ thuật bắt buộc. Tất cả chức năng production phải được kiểm kê và không được mất; **không cherry-pick/merge mù các bản thử nghiệm**. Giữ issue #56 làm bảng điều phối duy nhất, không tạo issue/nhánh mới cho từng cổng.

**Checkpoint đã xác minh:** [PR #72](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72) Draft @ `e888c010d6cfb09a97ce48af19d1a2f42a401240`; [PR #67](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/67) Draft @ `f2ae694af791a27deec4e1de7ae7c122914be635`; `main` @ `c0c1382f119599497b52d8ee8abd9e830a883f1e`. PR #72 **đã chứa lịch sử commit** của PR #67 và các PR #52, #57, #58, #60, #62, #63, #65; KHÔNG merge lại từng nhánh. `main` có 1 commit `AGENTS.md` chưa có trong PR #72: bảo toàn. Checkpoint cần refresh HEAD trước mỗi ghi/merge.

**Hiện trạng thật:** Godot 4.7.2 import + 14 focused tests: 15/15 exit 0 ở code SHA `e92ef09fc2c9b2ccb870910577b295881ccc6527` (PR72 HEAD `e888...` chỉ bổ sung bằng chứng). Test 30 hunter/20 zone/40 active mobs/200 spawn slots PASS, solo HP0→10 receipt→XP + materials, generation2 kill thứ 11, cold reload PASS. **KHÔNG phải Windows GUI/PLAYABLE PASS**: launcher chạy lần 1, lần 2 signal 11 trong `ig11icd64.dll` (GLES3); PID 2188 Windows từ chối truy cập; chuột thật và same-save end-to-end còn PENDING. Không chẩn đoán đây là lỗi Godot hay code khi chưa có bằng chứng.

## Chuỗi công việc bắt buộc theo thứ tự

- [ ] **R0 — ĐÓNG BĂNG CÁC NHÁNH, BẢO TOÀN E:** dừng mọi writer/song song vào các shared paths `p3_2_landscape_sect.gd`, SaveService, MapBattle, RuntimeClock, production. Kiểm kê toàn bộ PR/branch còn mở (không chỉ PR gần đây), xác minh SHA, tạo bảng `COMMIT_IN_PR72 | FUNCTION_INCLUDED_BUT_DIVERGED | MISSING_REAL_FUNCTION | EXPERIMENTAL | SUPERSEDED`. Sao lưu **đầy đủ 196 thay đổi local + untracked + manifest + save người chơi** tại E: vào thư mục bảo toàn riêng; ghi hash & status. Không `git reset --hard`, `git clean -fd`, ép checkout, ghi đè local, sửa save thật. Dùng worktree riêng nếu cần đối chiếu; không tạo bản game phát hành thứ hai.
  - **Gate:** báo backup path+SHA, danh sách tất cả PR/nhánh và owner file dùng chung. Không mất bất kỳ thay đổi nào.
- [ ] **R1 — HỢP NHẤT CÁC CHỨC NĂNG CÒN THIẾU VÀO PR #72:** dùng một source candidate PR #72 làm trục; đưa thay đổi `main/AGENTS.md` không mất ngữ nghĩa. Đọc diff chuyên sâu và chỉ forward-port phần production chưa có từ [#61](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/61) (SX JSON/Save), [#64](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/64) (Đại Điện/Đệ Tử Xá), [#66](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/66) (B1 UI) và mọi PR còn lại; không ghi đè bản canonical mới hơn bằng bản cũ. Dành riêng quyết định cho #55 tool VFX và #68/#69/#71/#74 animation labs: chỉ đưa vào production nếu Owner Visual PASS + QA, hoặc lưu lab/tool bất hoạt kèm ghi nhận rõ tại `main` sau khi kiểm thử, không thay sprite đang chơi. Không quên SX-01/SX-02 và test O8. Mọi PR được xử lý phải có kết luận và evidence (nằm trong bản tích hợp, cần port, chỉ lab, hoặc superseded).
  - **Gate:** một bản mã nguồn `#72` chứa đủ các chức năng đã được chấp thuận; lập ma trận `PR → file/chức năng → bằng chứng xuất hiện trong main candidate`. Tuyệt đối không đơn thuần tuyên bố “tất cả merged” vì commit ancestor.
- [ ] **R2 — KHẮC PHỤC LAUNCHER + WINDOWS GUI:** kiểm tra PID 2188/Windows process permission, crash log `ig11icd64.dll`, Intel graphics driver và renderer (GLES3/Compatibility) bằng thử nghiệm cô lập, không đụng tiến trình được Windows bảo vệ; nếu cần reboot/quyền máy thì ghi BLOCKED rõ. Phục hồi `CHOI-GAME.cmd` với preflight/fingerprint hợp lệ tại đúng source SHA, không disable guard. **Ba clean starts** qua launcher + thoát sạch (không còn zombie/permission block), chạy GUI thật 1280×720.
  - **Gate:** ít nhất 3 lần mở/đóng launcher không crash; mouse capture evidence thật; phải phân biệt driver vs code.
- [ ] **R3 — GAMEPLAY VÒNG ĐỜI TRÊN MỘT SAVE:** New Game → Residence xây bằng tài nguyên thật → tuyển đệ tử thật → phân công Mỏ → vật phẩm vào Warehouse → 1 thợ săn vào PvE → thêm/rút từng người → AUTO/HOLD/click map → quái HP0 thật → Tu Vi + Luyện Thể + vật phẩm vào Kho → respawn generation2 → Save → exit Godot → launcher → cold Reload → tiếp tục sản xuất/săn; không nhân reward/receipt, không mất roster/công trình/timer; Injury120 và One Active Job giữ. Chạy kiểm tra tải 30 thợ săn / 20 vùng / ≤40 quái đang hoạt động / 200 vị trí, không yêu cầu người chơi có đủ 30 ngay New Game.
  - **Gate:** log/GUI screenshots + before/after authority receipts/stock/progression trên cùng save QA; không lấy các test trên nhiều save rời làm bằng chứng vòng đời.
- [ ] **R4 — HỒI QUY VÀ TRẢI NGHIỆM:** Godot **4.7.2.stable.official** import/parse + focused suite + regression G0/G1/G2, production SX/warehouse/crafting/medicine, V6.3 Boss, SaveService exactly-once, Injury; CI full repo hoặc phân loại từng lỗi nonrelated. GUI chuột thật: map, roster, Hall, Residence, Guidance, PvE, Save/Reload; chụp ảnh **game thực** 1280×720 và xử lý chữ/icon/layout xấu rõ ràng. Android/touch bắt buộc kiểm tra nếu có thiết bị/runner phù hợp; nếu không có phải nêu giới hạn phát hành Android, không giả PASS.
  - **Gate:** PASS cho mọi test bắt buộc trên *cùng exact source SHA* sau patch cuối; không thay assertion để đạt xanh.
- [ ] **R5 — MERGE DUY NHẤT VÀO `main`:** chỉ khi R0–R4 có bằng chứng; kiểm tra ancestry, merge conflict, bảo toàn commit riêng `AGENTS.md` trên `main`; phê duyệt PR #72 nhắm `main` (hoặc tạo PR đích `main` **từ cùng source candidate** nếu GitHub không cho đổi base), sau đó merge có khóa expected HEAD SHA; không merge nhầm từng PR cũ. Chạy lại Godot build/tests trên `main` SHA sau merge. Tạo release tag bất biến và checkpoint `CURRENT_CHECKPOINT.md`, dẫn launcher E về `main` SHA đã nghiệm thu và kiểm tra lại. Chỉ sau đó đóng PR Draft đã tích hợp/superseded với lý do và giữ các branch lưu trữ đủ thời gian; không delete dữ liệu trước bằng chứng backup.
  - **Gate:** `main` có một bản phát hành chạy được, SHA test khớp, release tag và launcher game chính xác; PR #72 merged, các PR khác được phân loại/đóng hoặc giữ lab có lý do.

## Những điều bắt buộc không thay đổi

- **One Game / One Save Authority / One Runtime Scheduler:** không tách RC song song hoặc nhân EXP/loot; không đổi 27 bậc, giới hạn đệ tử, kỹ năng hay cân bằng ngoài phạm vi QA đã duyệt.
- **Cấm blanket merge all branches** vì có nhánh cũ và animation lab chưa Visual PASS. “Hợp nhất toàn bộ” nghĩa là **không bỏ sót chức năng production**, không có nhiều runtime game và không còn PR chức năng mồ côi; prototype phải được phân loại công khai.
- **Một người ghi shared code**. Không để Codex A/B hoặc ChatGPT đồng thời sửa cùng file P3.2.
- Nếu gate FAIL, sửa ngay trên cùng tuyến PR #72; ghi nguyên nhân và SHA mới, chạy QA lại; không phát triển tính năng mới hay mở nhánh khác.
- Báo cáo ngắn theo thứ tự: `Gate | SOURCE SHA | Windows E backup | files changed | Godot version | tests count PASS/FAIL | real GUI | logs/screens | blocker | NEXT`.

**Release definition:** `main` + `CHOI-GAME.cmd` mở được game một cách ổn định; vòng New Game → tuyển → sản xuất → săn/loot → Save/Exit/Reload chạy trong **một save**; không mất những chức năng còn giá trị từ các branch và không còn những PR liên quan “chờ merge” mơ hồ. **Không merge `main` trước R5.**

---
## Lịch sử điều phối trước 04/11/2026 (giữ nguyên để tra cứu)

> **CURRENT HANDOFF — 31/10/2026:** ONE GAME `integration/one-game-v65-20261030` HEAD [`095ff2f90df8260dd123c06964d20c4f9b571d32`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/095ff2f90df8260dd123c06964d20c4f9b571d32): D2–D8 integrated in code; separate fresh New Game launcher added (**stub/contract smoke only**). Female Stage A pack 42 PNG restored in isolated QA, **Godot import/player GUI still PENDING** due to an existing Godot PID and stale dirty E: checkout. Loot/EXP not implemented per source inspection. **APPROVED disciple-profile HS-09** is at design branch `design/disciple-profile-hs09-20261031` HEAD `69f1aac` and is **NOT** in ONE GAME Godot runtime. Next design-to-code handoff: [HS-09 inclusion packet](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56#issuecomment-6539039315), with current gameplay QA priority. Keep main/PR #52/owner E: data unchanged; E: consolidation AFTER stable ONE GAME.

---



# TÔNG MÔN BÁ ĐẠO — ONE GAME / INTEGRATION HUB

> **Mục đích:** Một điểm vào GitHub duy nhất để nối các luồng Codex vào **một bản game thực sự chơi được**. Đây là **chỉ mục điều phối**, KHÔNG phải một backlog thay thế, một bản game mới, hay giấy phép merge. **Không cần tạo GitHub Project / Control Tower riêng ở giai đoạn này.**
>
> **Snapshot khởi tạo:** 30/10/2026. **Mọi SHA phía dưới chỉ là mốc tham chiếu, phải fetch lại ref khi làm việc.** Trạng thái/test chính xác nằm tại issue/PR nguồn cùng log của source SHA đã chạy, không ở đoạn tóm tắt này.

## 1. Các luồng phát triển đang kết nối

| Vai trò | Nguồn hiện hành | Điều kiện bàn giao |
| --- | --- | --- |
| **Stable (không sửa gameplay)** | [`main`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/tree/main) — mốc ghi nhận `c0c1382f` | Bản chính thức hiện hành; **không tự merge các feature** |
| **Codex PvE / sản xuất / UI** | [PR #52](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/52), [Issue #37](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37); nhánh `integration/pve-unified-rc-20261027` | Chơi từ New Game → tuyển → giao việc → sản xuất/tu luyện → đội 6 → PvE → Save/Reload; xử lý P0/P1 thực tế |
| **Codex Skills / Boss** | [Issue #54](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/54); nhánh `feature/v63-v64-full-combat-20261029` | V6.5 D4–D8 đã có code và QA headless; **chưa nằm trong PR #52/main**, gate OFF mặc định, còn GUI 9 nhánh/9 Boss và endgame Body 7–30 |
| **Asset/VFX độc lập** | [PR #55](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/55) (tooling), [PR #53](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/53) (handoff docs), [Issue #43](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/43) | Pack + SHA + license/provenance + Godot import + playback + mapping cast/release/hit; **tool PASS ≠ gameplay integrated** |
| **QA liên quan** | [Issue #41](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/41) save/exactly-once; [Issue #42](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/42) movement/camera | Bảo toàn test, không xóa bài test vì khó PASS |

**Không lấy một bảng trạng thái tĩnh để phủ nhận các cập nhật mới ở PR/Issue nguồn.** Nếu nguồn mới có commit, đọc lại đúng HEAD và evidence trước khi quyết định.

## 2. Lộ trình phát hành duy nhất — theo thứ tự

- [ ] **R0 — Playable core:** RC #52 có trải nghiệm 1280×720 từ save mới. LOD hiển thị đệ tử ngoài trời, worker trong nhà ẩn nhưng truy cập được panel, tìm/điều động roster, sản xuất thật, UI không chặn tiến trình. Người dùng kiểm tra chuột thật; ghi rõ PENDING nếu chỉ có injected input.
- [ ] **R1 — Hoàn thiện vòng farm:** 6 đệ tử chiến đấu liên tục → từng quái HP0 → receipt chính thống → EXP đệ tử trực tiếp + loot vào Warehouse + Tinh Nguyên hiếm theo quy tắc được duyệt → respawn/zone hop → Save/Return/Reload/offline exactly-once. **Hiện RC báo `LOOT_PENDING`**, không giả tạo vật phẩm.
- [ ] **R2 — Ghép V6.5 vào bản chơi chung:** review từng file chồng lấn, áp dụng thay đổi theo thứ tự/ownership, học bí kíp → Tàng Kinh Các → equip → kỹ năng thật trong PvE; duy trì gate OFF trên legacy cho đến khi nghiệm thu. **Không blind-merge feature sang RC hoặc main.**
- [ ] **R3 — Gameplay/Visual 9 nhánh + 9 Boss:** đúng Source A và VFX được duyệt, HUD không chồng chữ, cast/impact/telegraph, per-boss reward/counterplay, capture thực tế đủ các trường hợp.
- [ ] **R4 — Endgame + device:** Body realms 7–30 cần content gate đã duyệt; loop nâng cấp/forge/production có chi phí thật; Android APK, cảm ứng, FPS/RAM, nghiệm thu trên máy mục tiêu.
- [ ] **Release:** chỉ sau khi owner duyệt một exact integrated SHA, QA + GUI và quyết định merge/tag.

**Đây là milestone phụ thuộc nhau, không tạo Issue mới cho mỗi mục nếu PR/Issue nguồn đã sở hữu công việc.**

## 3. Luật phối hợp 3 Codex — một người viết mỗi vùng dùng chung

- **PvE owner:** PR #52, sở hữu P3.2 / World / shared SaveService, RuntimeClock, Scheduler, HuntingPveRun, MapBattle khi đang hoàn thiện RC.
- **Skill owner:** nhánh V6.5, ưu tiên `v63_*`, skill catalogs, archive/learning, skill QA. Nếu cần sửa shared runtime, ghi trước file cụ thể và đưa sang hàng đợi integration; không tự ghi đè phiên bản RC.
- **Asset owner:** Asset Studio và tooling/manifest, chỉ bàn giao gói verified; không sửa gameplay/combat math/save để nối asset.
- **Integration owner:** giữ trách nhiệm đối chiếu file dùng chung (`p3_2_landscape_sect.gd`, `map_battle_v2.gd`, `hunting_pve_run_v2.gd`, `simulation_runtime_clock_v2.gd`, `simulation_runtime_owner_v2.gd`, `save_service.gd`, `simulation_scheduler.gd`, state/warehouse/buildings), chọn patch, chạy đúng Godot 4.7.2 trên SHA kết hợp; không có hai writer cùng lúc. **Không nhất thiết phải chạy Codex thứ tư.**
- **Máy Windows 8 GB:** song song đọc/viết source ở worktree riêng; chỉ một Godot/asset conversion nặng một lúc; không phá save gốc, không force reset/clean.

## 4. Chuẩn bàn giao tối thiểu — một checkpoint có bằng chứng

Mỗi worker cập nhật **PR/Issue hiện có**, không viết status-only docs liên tục. Báo cáo ngắn:

```text
LANE: PvE | Skills | Assets | Integration
BRANCH / SOURCE SHA: ...
CHANGED PATHS: ...
PLAYER-VISIBLE RESULT: ...
GODOT 4.7.2: NOT RUN | focused xx/xx | GUI | Android
EVIDENCE: log/hash/screenshot/PR URL ...
COMPATIBILITY: Save/One Active Job/Injury120/Warehouse/gate OFF ...
INTEGRATION STATUS: NOT READY | READY FOR REVIEW | INTEGRATED (exact SHA)
BLOCKER / NEXT REAL GAMEPLAY ACTION: ...
```

**Mốc kiểm chứng:** DESIGN ≠ CODE ≠ HEADLESS TESTED ≠ GUI SCRIPTED ≠ HUMAN INPUT ≠ ANDROID ≠ MERGED. Một bản test PASS ở commit cũ không xác thực SHA mới. Không lấy 120 simulated ticks làm 120 giây thao tác thực.

## 5. Quyết định về Graphify

- **Không cài Graphify tự động** vào Windows hoặc repo lúc này. Bản Graphify upstream chưa có parser GDScript/scene đầy đủ; [issue upstream](https://github.com/Graphify-Labs/graphify/issues/2152).
- [Fork graphify-godot](https://github.com/hidalgob/graphify-godot) hỗ trợ `.gd`, `.tscn`, `.tres`, nhưng là fork dựa trên upstream cũ, chưa được test trên TMB. **Graphify là công cụ tìm quan hệ code, không phải nguồn trạng thái hoặc công cụ merge.**
- **Chỉ pilot khi thực sự cần truy vết phụ thuộc:** isolated Python env ở E:, read-only trên ~30–50 file Godot + scene, exclude `.godot/`, assets lớn, save và output; đo RAM peak, kiểm chứng edge `preload/extends/scene` bằng đọc code thực, so với grep có sẵn. Nếu không có cải thiện rõ rệt, **không tích hợp**. Không chạy `graphify install` viết đè `AGENTS.md`.
- Dùng **`tmb-project-director`** và **`tmb-godot-evidence`** đã có; không tạo thêm một agent framework.

## 6. Ranh giới và hướng dẫn

- **Chỉ mục này không cấp quyền** sửa gameplay, thay balance, merge, đẩy nhánh, xóa file, sửa saves hoặc triển khai asset chưa có provenance.
- **Không triển khai Control Tower/Project nặng lúc này.** Nếu quy mô sau này khiến một index issue không đủ, mới tạo GitHub Project lọc từ chính các Issue/PR hiện có; không duplicate trạng thái.
- Không được tự suy diễn kết quả đã hợp nhất từ các branch riêng. Một game: một runtime/save authority, một tuyến phát hành.
- Link nguồn kỹ thuật: [AGENTS.md](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/main/AGENTS.md) · [TMB Project Director skill](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/main/.agents/skills/tmb-project-director/SKILL.md) · [Game architecture](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/main/docs/GAME_SYSTEM_ARCHITECTURE.md).

**Definition of done cho issue này:** Có một integrated release candidate mà người chơi kiểm tra được toàn bộ chuỗi New Game → sản xuất/tu luyện → bí kíp/skill → PvE/loot/Boss → Save/Reload, với evidence đúng source SHA. Chỉ khi đó chuyển trạng thái hub thành hoàn thành.
