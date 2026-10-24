# TÔNG MÔN BÁ ĐẠO — CODEX PACKET A
## COMBAT V3-S1 — GODOT 4.7.2 FOCUSED QA, BUG FIX, REGRESSION & GITHUB HANDOFF

**Ủy quyền của owner, ngày 24/10/2026:** Chỉ kiểm thử và sửa những lỗi liên quan trực tiếp đến Combat V3-S1 trên một **nhánh sửa lỗi riêng**; phải dùng Godot official 4.7.2; lưu log, bằng chứng, báo cáo lên GitHub; **không merge, không sửa UI/UX, không chạy FULL/CI, không tự chuyển sang S2**. Không hỏi owner làm bước trung gian nếu Codex tự thực hiện được.

### 0. GitHub checkpoint và quyền sở hữu

- Repo: `vuanhtuan161094-byte/TongMonBaDao`, Godot **4.7.2.stable.official.ed1daf0bf**.
- PR S1 cần QA: **#29** — `https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/29`.
- **PR #29 HEAD đã xác minh khi viết packet:** `9522812e91b7ca5bc0cc108eb92e000e930fe850`.
- PR #29 base: PR #27 branch `integration/master-v3-combat-d7-uiux-20261024`, base SHA `deeae081bcfbe1413d4cf60a29db7e58150888b5`.
- PR #24 / #25 / #26 / #27 / #29 đều phải giữ nguyên trạng thái draft, không merge.
- Không chỉnh worktree Codex recovery cũ, không xóa log/untracked của nhánh khác, không dùng user profile Administrator; lưu clone/output cách ly trên ổ E nếu máy có ổ đó.
- **Đầu tiên đọc trên đúng SHA**: `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, `docs/handoffs/TMB_COMBAT_V3_S1_IMPLEMENTATION_CHECKPOINT_2026-10-24.md`, bốn file combat/test trong diff PR #29.
- Phải **fetch và xác minh lại HEAD PR29 hiện tại** trước khi tạo nhánh. Nếu không bằng SHA trên, ghi rõ khác biệt, đọc diff và dùng HEAD đã xác minh, không ghi đè commit người khác.

### 1. Cách tạo worktree & ranh giới CODE

Làm việc trên **worktree mới / nhánh mới** từ HEAD PR29 đã xác minh, gợi ý:
`fix/combat-v3-s1-official-qa-20261024`.
Không sửa trực tiếp PR29 hoặc PR27; không force-push/rebase/merge. Sau khi sửa, tạo **PR DRAFT xếp trên PR29** để owner review, không đưa thay đổi vào main.

**Allowlist CODE mặc định (chỉ khi liên quan lỗi S1):**
- `godot/src/simulation/combat/map_battle_v2.gd`
- `godot/src/simulation/combat/map_battle_snapshot_v2.gd`
- `godot/src/simulation/combat/disciple_combat_loadout_v2.gd`
- `godot/tests/simulation/combat_v3_s1_effects_test.gd`
- Thêm test mới trong `godot/tests/simulation/` để kiểm chứng S1, với nội dung và lý do rõ.
- `godot/src/simulation/combat/combat_skill_system.gd` **chỉ nếu** fix S1 bắt buộc và phải báo rõ diff/hợp đồng thay đổi.

**Disallowlist:** tất cả `godot/src/presentation/`, scenes/assets/Source A, UI/UX, `FoundationSystem`, D7 migration, `DiscipleState`, `SimulationState`, `SaveService`, Warehouse, CARE reward ownership, medicine/HP×100, Boss, S2 dash/fire_combo, balance tuning, workflows/CI.

Nếu lỗi nằm thực sự ngoài allowlist: **đừng lén sửa file đó**. Tạo mục `BLOCKED / OUT-OF-SCOPE` với file/dòng/stack và đề xuất packet riêng. Không sửa test chỉ để bỏ assert, xóa failure hoặc đổi PASS marker.

### 2. P0 — Đo hiện trạng trước khi sửa

1. `git status --short` sạch ở worktree mới, `git rev-parse HEAD`, `git diff --stat <PR29_BASE>...HEAD`, chụp manifest/hashes của các file thay đổi.
2. Tìm đúng Godot official binary. Chạy `--version` và xác nhận **4.7.2.stable.official.ed1daf0bf**. Nếu không đúng phiên bản, không tuyên bố official PASS.
3. Kiểm tra `godot/project.godot` và **sự tồn tại thực tế** của từng `godot/tests/simulation/xxx.gd` trước khi chạy. Trong lệnh, dùng `--path <absolute_path_to_godot_project>` và `--script res://tests/simulation/<real_file>.gd`, không đoán sai đường dẫn `res://tests/`.
4. Chạy import/parse headless bằng executable/command đúng phiên bản trước test, tránh việc chưa import class_name/resources. Dùng isolated user-data profile ở thư mục do Codex sở hữu (ưu tiên E:), không chạy thử trên save cá nhân. Lưu command, cwd, user-data location, thời gian, engine version, stdout/stderr, exit code.
5. Chạy **test S1 mới ở HEAD chưa sửa** để bắt lỗi nguyên bản trước, kể cả lỗi parse/fixture/logic. Ghi **RED BASELINE**, không che/cắt dòng lỗi.

**Ví dụ lệnh (điền đường dẫn thật và theo chuẩn runner của repo):**
```powershell
$Engine = 'E:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' # THAY bằng executable tìm được
$Project = (Resolve-Path '.\godot').Path
& $Engine --version
Test-Path (Join-Path $Project 'tests\simulation\combat_v3_s1_effects_test.gd')
& $Engine --headless --path $Project --editor --quit 2>&1
$importExit = $LASTEXITCODE
& $Engine --headless --path $Project --script 'res://tests/simulation/combat_v3_s1_effects_test.gd' 2>&1
$testExit = $LASTEXITCODE
```
Lệnh chỉ minh họa. Codex phải dùng đúng executable/cwd thực tế, và ghi log/exit **riêng từng lệnh**. Không cần chạy tất cả test trong một cửa sổ khiến mã lỗi bị ghi đè.

### 3. P1 — Focused tests thực sự tồn tại trong repo (đã xác minh)

Chạy từng file theo cùng runner, isolated data, capture stdout, stderr, elapsed, exit code, PASS marker và parser/script errors:

**S1 trực tiếp:**
`tests/simulation/combat_v3_s1_effects_test.gd`

**Combat V2, loadout và snapshot:**
`tests/simulation/dv2_02_group_map_battle_test.gd`
`tests/simulation/dv2_02_battle_snapshot_test.gd`
`tests/simulation/dv2_02_combat_stats_test.gd`
`tests/simulation/dv2_02_monster_context_test.gd`
`tests/simulation/dv2_02_five_level_pve_test.gd`
`tests/simulation/p2_5_combat_skill_test.gd`
`tests/simulation/p2_6_equipment_combat_effects_test.gd`

**CARE, persistent loot, auto/injury and recovery:**
`tests/simulation/b3_ph0_continuous_kernel_test.gd`
`tests/simulation/b3_care_pills_autohunt_test.gd`
`tests/simulation/b3_fasttrack_hunt_test.gd`
`tests/simulation/gp_02c1_injury_settlement_test.gd`
`tests/presentation/b3_main_hunt_integration_test.gd`

**D7 adjacent guard (chỉ test, không sửa model):**
`tests/simulation/d7_foundation_v3_migration_test.gd`

Tổng **14 test files** (bao gồm S1). Mọi lần FAIL phải được lưu; sau sửa chạy lại **tất cả**. Nếu một test phụ thuộc external data hoặc có historical red đã biết, so sánh exact SHA PR29 baseline, phân loại và ghi nguyên nhân; không đánh dấu PASS giả. Nếu focused fail do môi trường, ưu tiên xử lý runner/path/profiles trước khi kết luận gameplay.

### 4. P2 — Những lỗi/rủi ro S1 bắt buộc chủ động kiểm tra và sửa

**A. Nhịp đánh thật (determinism and cadence):**
- Với đòn thường kiếm cơ bản 1.10s, tăng attack_speed +0%, +20%, +50%, +100%: số lần đánh trong một cửa sổ dài phải **không giảm** theo speed; +100% nên lớn hơn +50% tại cùng điều kiện nếu chưa đụng hard ceiling. Check tick .25, không lặp vô hạn, không đánh nhiều lần trong một step nếu hợp đồng chưa cho phép.
- Do code S1 sửa lịch `next_basic`, kiểm tra hiệu ứng khi *di chuyển rồi mới vào tầm*, bị cast chiếm thời gian, sau save/load, khi tích lũy deadline, và khi tốc đánh quá cao/âm. Không tạo backlog hàng chục đòn ngay một step.
- So sánh fixture cùng seed trước/sau sửa; thay đổi nhịp của S1 là intentional, nhưng không được làm double-damage/kill/reward.

**B. Cast/skill/cooldown and ownership:**
- Thanh Phong Trảm, Ngự Kiếm Thuật đúng tỷ lệ ATK, khoảng cách, projectile delay, unlock. `cast_speed` và `cooldown_recovery` tăng phải làm thời gian thực tương ứng; không âm/0 và không cast-spam.
- Ranh giới cast-start vs release: mục tiêu chết/mất hợp lệ, caster down, cast pending khi save. No duplicate `skill_hit` / damage. Không giả là đã triển khai dash hay fire_combo.
- Thử các trường hợp 2 learned skills cùng hồi; tránh chọn kỹ năng kém vô hạn gây cản đòn thường nếu regression nghiêm trọng; nếu cần thiết kế lại AI ngoài phạm vi, ghi nợ S2, không âm thầm sửa balance.

**C. Trạng thái thật trên mục tiêu (S1):**
- `hoa_cau`: burn DoT đúng hệ số, tick khoảng 1 combat second, tự hết hạn, không tick sau khi mục tiêu chết, không thưởng trùng kill; ảnh hưởng DEF/kháng lửa đúng canonical damage pipeline. **Cần quyết định test rõ**: burn có phải biến mất khi người cast bị hạ? pilot hiện có, nếu hành vi có hại phải ghi vấn đề thiết kế, không thay đổi vô căn cứ.
- `chan_son_quyen` + `han_suong_an`: weaken chỉ làm giảm damage OUTGOING của mục tiêu đúng thời hạn, không giảm healing hoặc damage khác trừ khi định nghĩa rõ; không stack vô hạn; khi hai nguồn giao nhau phải đúng strongest/replace behavior.
- `kim_cuong_ho_the`, `bat_dong_than`: buff bản thân, HP trigger <75%, không spam trước khi buff cũ hết; không cộng phòng thủ hai lần ngoài quy tắc mạnh hơn giữa guard học và guard vai trò; trong trận thực frontline generic guard có thể được ưu tiên trước học skill: kiểm tra live use, không chỉ fixture role ranged.
- Test đầy đủ events `skill_cast`, `skill_hit`, `hit`, `status_applied`, `status_tick`, expiration, downed, snapshot.

**D. Snapshot/security/save:**
- Lưu/tải các trạng thái: chưa học hiệu ứng, đang cast, đang burn/weaken, đang self-guard, hết hạn và quái đã chết. Test old snapshot v1/v2/v3 có bytes từ baseline fixture, tuyệt đối không tự reroll old save hoặc reward. `MapBattleSnapshotV2` validate provenance, nonnegative/finite timers, target IDs, stack counts; không vô tình từ chối mọi old snapshot hợp lệ.
- **Rủi ro số 1:** old snapshot có thể load nhưng S1 đổi nhịp đánh khiến tiếp diễn khác source gốc. Codex phải ghi rõ compatibility policy và test/fix nếu feasible trong allowlist; không tự chuyển HP/injury hoặc làm free heal khi load.
- Burn kill trong CARE phải tạo **một** canonical receipt cho mỗi generation, không thêm kill event trùng khi load/retry; nếu không thể hoàn tất trong allowlist, giữ PENDING/BLOCKED và tuyệt đối không merge.
- Kiểm tra `MapBattleSnapshotV2.save(live)==MapBattleSnapshotV2.save(restored)` sau deterministic continuation và khi có hiệu ứng thực sự đang active.
- Test corrupted status payload bị từ chối fail-closed; long encounter history không tăng vô hạn snapshot size.

**E. Cạnh tương thích chưa cân bằng:**
- Không triển khai x100 player/monster/medicine/economy trong packet này.
- Không làm Boss live hoặc UI skill V5; chỉ kiểm toán backend S1 và các regression liên quan.
- Không thêm công pháp/sát thương ngầm, không đổi percent ATK hoặc grade D7 để chữa test đỏ.

### 5. Quy trình sửa đến khi có kết luận

`RUN RED → classify → smallest authorized patch → rerun failing test → rerun FULL 14-file FOCUSED MATRIX → inspect diff → final code SHA → rerun exactly at final SHA`.

Sau mỗi sửa, lưu một dòng theo cấu trúc:
`test_name | status_at_baseline | failure_category | observed_error | root_cause_file:line | patch_sha | status_after | log_path`.

Nếu không thể PASS tất cả test vì blocker ngoài phạm vi, **không tự mở rộng allowlist**: ghi rõ `BLOCKED`, traceback và hành động phải được owner duyệt. Không bỏ FAIL khỏi bảng.

**Gate để báo FOCUSED_PASS**: 14/14 test (hoặc mọi kiểm thử tương đương phù hợp sau review) cùng exact SHA, official 4.7.2, exit0 + PASS marker cụ thể + không parse/script error; test S1 mới hoạt động thực, old snapshots và CARE reward không regression. Một báo cáo kết quả được kiểm toán được. Không dùng lại 20/20 PASS của PR27 cho commit S1.

### 6. Bằng chứng và output lưu trực tiếp lên GitHub

Trên **nhánh fix riêng**, tạo tối thiểu:

1. `docs/handoffs/TMB_COMBAT_V3_S1_OFFICIAL_QA_REPORT_2026-10-24.md` — root causes/fix, initial vs final, QA scope và verdict, Godot exact version, SHA, limitations.
2. `docs/handoffs/TMB_COMBAT_V3_S1_CHATGPT_SUMMARY_PACKET_2026-10-24.md` — dạng báo cáo ngắn chuyển ChatGPT, gồm links/paths trực tiếp, tuyệt đối không viết `PASS` nếu chưa chứng minh.
3. `docs/handoffs/TMB_COMBAT_V3_S1_NEXT_CODEX_TASK_2026-10-24.md` — prompt cho S2 hoặc packet sửa blocker thực tế, chỉ làm sau khi S1 đã rõ status.
4. `outputs/COMBAT_V3_S1_OFFICIAL_QA_20261024/focused_results.csv` — 14 dòng với testcase path, exact command, run exit code, marker, log path, assertion/parse counts, elapsed.
5. `outputs/COMBAT_V3_S1_OFFICIAL_QA_20261024/sha_manifest.tsv` — hashes cho code, tests, report, logs; changed-file inventory.
6. **Log thật**: commit mỗi focused test stdout/stderr ngắn có chứng cứ trực tiếp vào `outputs/.../logs/` khi dung lượng hợp lý. Log dài/binary giữ ở E: dưới outputs, tạo ZIP + SHA256 và đưa link artifact đính kèm PR nếu tool hỗ trợ. Không được thay log bằng bản do AI tự viết; không đưa cache Godot/nội dung cá nhân/secret lên GitHub.
7. Nếu có thể, video/screenshot gameplay **không bắt buộc** trong packet backend này; UI chat xử lý visual, không làm giả render.

Cần tạo **PR DRAFT xếp trên PR29** sau khi sửa, ghi rõ review commit/test SHA. Không merge, không self-approve owner, không xóa branch cũ, không sửa PR29 nếu chưa được phân công writer. Nếu PR base/head mới lệch, kiểm lại merge-base và file overlap trước PR.

### 7. Câu trả lời cuối cùng Codex phải trả

Bắt buộc trình bày:
- Branch, base SHA, final code/test SHA, draft PR URL, trạng thái mergeable (chỉ mang ý nghĩa kỹ thuật).
- Số test thực chạy PASS/FAIL/BLOCKED, Godot version, đường dẫn log GitHub, trạng thái sau rerun clean profile; phân biệt runner vs gameplay failure.
- Tên file đổi, 3 link Markdown bàn giao.
- `IMPLEMENTED / TESTED / FOCUSED_PASS / PENDING_OWNER / BLOCKED` cho từng khu vực.
- **Không tuyên bố "đã hoàn tất" chỉ vì đã viết xong code hoặc test file.**
- Đề xuất bước S2 kế tiếp nhưng **KHÔNG tự triển khai** S2.

**Hãy tự thực hiện toàn bộ việc có thể làm trên máy; chỉ yêu cầu tôi khi cần quyền thực sự không thể có hoặc quyết định thay đổi luật chơi.**
