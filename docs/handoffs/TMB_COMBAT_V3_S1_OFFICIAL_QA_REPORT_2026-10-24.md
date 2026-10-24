# Tông Môn Bá Đạo — Combat V3-S1 Official QA Report

**Ngày:** 2026-10-24 (Asia/Saigon)  
**Repo:** `vuanhtuan161094-byte/TongMonBaDao`  
**Phạm vi:** Packet A — Godot 4.7.2 focused QA, S1 bug fix and regression for PR #29.

## Kết luận

**FOCUSED_PASS — 14/14 regression tests và 56/56 S1 edge checks đã chạy thành công** trên source commit `4fe466d8efc192aa93738811041de795baadb22a`, dùng Godot `4.7.2.stable.official.ed1daf0bf`. Import/parse headless cũng exit 0. Không có parse, script hay assertion failure trong lần final.

Có hai lỗi S1 được tái hiện trên HEAD ban đầu và đã sửa: frontline generic guard chặn learned guard; snapshot chấp nhận caster không tồn tại và cast deadline vô hạn. Bổ sung kiểm tra timer/action/cooldown, quyền cast và burn tick quá hạn. Burn kill qua CARE/B3 được kiểm chứng tạo đúng một canonical reward và không trả thêm sau khi đọc lại receipt đã commit.

Không có thay đổi UI/UX, Source A, D7, economy/medicine, HP×100, Combat×100, CARE reward ownership, `combat_skill_system.gd` hoặc PR #29. Không chạy FULL/CI, không triển khai S2, không merge.

## Git checkpoint

| Hạng mục | Giá trị |
|---|---|
| PR #29 | [PR #29 (parent)](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/29) |
| PR #29 HEAD / branch làm base | `9522812e91b7ca5bc0cc108eb92e000e930fe850` / `feature/combat-v3-s1-runtime-effects-20261024` |
| Base branch của PR #29 | `integration/master-v3-combat-d7-uiux-20261024` @ `deeae081bcfbe1413d4cf60a29db7e58150888b5` |
| Nhánh sửa lỗi | `fix/combat-v3-s1-official-qa-20261024` |
| Tested local commit | `4fe466d8efc192aa93738811041de795baadb22a` |
| Tested/published code tree | `6859fde16ed71a2596d3a5a52539622136d866e0` |
| GitHub code/test commit | `e51dabc57ce20c294d03a0e9d64ed3ccd1397b3c` — cùng tree với tested local commit 
| Evidence/report commit | cb68ec7e167320a73894392d0860f053f3f48489 |
| Source file allowlist | `map_battle_v2.gd`, `map_battle_snapshot_v2.gd`, `combat_v3_s1_effects_test.gd`, `combat_v3_s1_edge_contract_test.gd` |

PR #29 hiện vẫn là draft/open và chưa bị sửa. Nhánh này được tạo từ đúng PR #29 HEAD. PR review xếp tầng đã tạo: [draft PR #30](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/30), base là PR #29 HEAD; GitHub xác nhận `mergeable=true`, `mergeable_state=clean`. Không có thao tác merge hoặc force-push.

## Engine và cách chạy

- Godot console binary: `E:\codex\TMB_Playable_V1_Windows\engine\Godot_v4.7.2-stable_win64_console.exe`
- Phiên bản xác nhận bằng `--version`: `4.7.2.stable.official.ed1daf0bf`.
- SHA-256 binary: `C8F0A6BC45A19B33541501E57F6F7CD972AB18453743266339D495CBBE846643`.
- Import cuối: `--headless --path <absolute godot project> --editor --quit`, exit 0, 10.6 giây, source `4fe466d…`.
- Mỗi test chạy riêng với `--headless --path <absolute godot project> --script res://tests/...`, stdout/stderr/meta riêng, profile `APPDATA`, `LOCALAPPDATA`, `TEMP` riêng dưới `outputs/COMBAT_V3_S1_OFFICIAL_QA_20261024/userdata/`.

Godot ghi một dòng môi trường `ERROR: Failed to read the root certificate store.` vào stderr do Windows CA store khi dùng profile cô lập. Import và tất cả test đều exit 0; log không có parse/script/assertion failure, và marker bắt buộc xuất hiện. Runner giữ nguyên bộ đếm `runtime_error_lines=1` để không che dòng chẩn đoán này. Đây là chẩn đoán certificate store của môi trường, không phải lỗi gameplay/test.

## RED baseline trước sửa

HEAD `9522812e91b7ca5bc0cc108eb92e000e930fe850` được kiểm tra trước khi sửa. Ma trận 14 test gốc đều PASS, nhưng fixture S1 hiện có chưa mô phỏng frontline/snapshot corruption. Probe edge bổ sung chạy tại cùng HEAD cho **5 assertion FAIL**:

| Failure ban đầu | Root cause trên source HEAD 952 | Fix |
|---|---|---|
| Learned guard frontline không được kích hoạt; generic guard xuất hiện chồng và guard học có thể bị thử lại không đúng nhịp (3 assertions) | `map_battle_v2.gd`: role guard được thử trước `_try_learned_skill`; `_guard_frontline` không xem `learned_guard_until` | Ưu tiên learned self-guard khi frontline đủ điều kiện; chỉ fallback generic guard; không mở generic guard khi learned buff còn hiệu lực |
| Snapshot nhận burn gán cho caster `ghost` | `map_battle_snapshot_v2.gd`: chỉ kiểm tra hai chuỗi caster/skill không rỗng, chưa resolve actor, side, skill effect hay loadout | Kiểm tra caster tồn tại, khác side, skill effect đúng status và skill có trong loadout caster |
| Snapshot nhận cast `ready=INF` | `map_battle_snapshot_v2.gd`: chỉ kiểm tra caster có mặt và `ready < now` | Ép kiểu số, finite/range deadline, actor/target ownership, skill provenance, ratio hữu hạn; giới hạn số pending casts |

Kết quả baseline 14 test và edge probe gồm stdout/stderr/meta được lưu trong `outputs/.../logs/baseline/`; source của probe pre-fix được lưu tại `outputs/.../baseline_edge_contract_probe_source.gd`. Xem thêm [baseline edge result](../../outputs/COMBAT_V3_S1_OFFICIAL_QA_20261024/baseline_edge_results.csv).

## Các sửa đổi

### `godot/src/simulation/combat/map_battle_v2.gd`

- Frontline thử learned self-guard trước role generic guard.
- Role guard không ghi đè/thêm mitigation khi learned guard đang hoạt động.
- Effective attack interval không dương (attack speed −100% trở xuống) không tạo hit; deadline kiểm tra lại theo tick 0.25 giây, không tạo catch-up debt.

### `godot/src/simulation/combat/map_battle_snapshot_v2.gd`

- Kiểm tra loadout và `skill_ready`: kiểu dữ liệu, skill đã biết, không trùng, giới hạn số mục, cooldown finite và có hạn.
- Kiểm tra `next_basic`, `next_skill`, generic guard, learned guard, burn expiry/tick; chặn burn tick quá hạn trên mục tiêu còn sống để tránh tick dồn từng simulation step.
- Kiểm tra status caster, side, skill effect và skill ownership; timer hữu hạn, giới hạn stack/status.
- Kiểm tra pending cast count, caster/target/side, self-target guard, skill loadout, ratio và deadline hữu hạn/có hạn.
- Không đổi snapshot envelope/version; bổ sung default cho actor timer cũ bị thiếu, trong giới hạn timer hợp lệ.

### Tests

- Mở rộng `combat_v3_s1_effects_test.gd`: attack speed 0/+20/+50/+100, âm và cực cao; tối đa một basic hit/tick; movement, pending cast, cast/cooldown, save/load, Thanh Phong Trảm, Ngự Kiếm Thuật, burn damage/tick/fire resistance/expiry, target/caster down, weaken và guard.
- Thêm `combat_v3_s1_edge_contract_test.gd`: frontline guard live; provenance/timer/cast corruption; snapshot v1/v2/v3 layouts; one-step kill receipt/replay; B3 CARE burn → canonical warehouse reward → committed receipt → restart/replay without duplicate reward.

## Final regression

**14/14 PASS trên source SHA `4fe466d8efc192aa93738811041de795baadb22a`.** Mỗi dòng có exact command, exit code, marker, parse/assertion/runtime diagnostic counts, elapsed và log prefix trong [focused_results.csv](../../outputs/COMBAT_V3_S1_OFFICIAL_QA_20261024/focused_results.csv). `baseline_results.csv` ghi cùng 14 test trên HEAD 952.

**S1 extended edge contract: 56/56 checks PASS**, exit 0, marker `COMBAT_V3_S1_EDGE_CONTRACT_PASS checks=56`. Kiểm thử CARE-specific khởi tạo world/đệ tử thật, học Hỏa Cầu qua CombatSkillSystem, tạo burn kill, chạy `B3HuntWorld.settle_kills`/save barrier và restart. Kết quả: generation watermark 1, receipt COMMITTED, warehouse tăng đúng 1; reload/replay giữ nguyên quantity.

Final logs:

- `outputs/COMBAT_V3_S1_OFFICIAL_QA_20261024/logs/final/` — import + 14 test stdout/stderr/meta.
- `outputs/COMBAT_V3_S1_OFFICIAL_QA_20261024/logs/final/combat_v3_s1_edge_contract_test.*` — edge contract stdout/stderr/meta.
- `outputs/COMBAT_V3_S1_OFFICIAL_QA_20261024/logs/baseline/` — initial 14 + RED edge probe.

## Snapshot compatibility và các giới hạn còn lại

- V1 finite payload được tạo bằng baseline-compatible serializer và load lại; v3 continuous payload được save/load; v2 fixture được hạ từ baseline v3 payload và bỏ trường PH0-only. Kiểu snapshot, default field cũ, mục tiêu và timer được kiểm tra.
- Repo không có binary golden fixture lịch sử v2. Vì vậy test v2 là payload compatibility fixture tái tạo theo schema cũ, chưa phải byte-for-byte save file từ build cũ. Cần một archive v2 thật nếu owner cần đảm bảo binary golden compatibility.
- Chọn nghĩa burn khi caster bị hạ là pilot hiện hữu: burn được xóa trước tick tiếp theo. Đã kiểm tra hành vi này, nhưng đây là **PENDING_OWNER** nếu luật mong muốn là DoT tiếp tục sau khi caster chết. Không tự đổi luật trong Packet A.
- Không có physical Windows/Android gameplay/UI QA. UI/visual không nằm trong Packet A. Dash/fire_combo, Boss/UI skill, x100 và S2 vẫn ngoài phạm vi.

## Status theo yêu cầu handoff

| Khu vực | Trạng thái |
|---|---|
| S1 attack cadence, cast, burn/weaken/guard | **IMPLEMENTED / TESTED** |
| Snapshot/cast/status timer và provenance | **IMPLEMENTED / TESTED** |
| 14 focused regressions, official Godot 4.7.2 | **FOCUSED_PASS** |
| CARE burn reward exactly-once | **TESTED** |
| Burn còn tồn tại sau caster death | **PENDING_OWNER** — hiện giữ pilot clear-on-death |
| Binary golden v2 fixture | **PENDING_OWNER** — fixture lịch sử không có trong repo |
| UI/Android/visual, FULL/CI, S2/x100 | **OUT OF SCOPE / NOT RUN** |
| Lỗi trong phạm vi S1 còn chặn | **NONE OBSERVED** |

**Không merge.** Chỉ tiếp tục Packet B/S2 khi owner cấp quyền và quyết định rõ hai mục `PENDING_OWNER` có cần thay đổi hành vi không.



