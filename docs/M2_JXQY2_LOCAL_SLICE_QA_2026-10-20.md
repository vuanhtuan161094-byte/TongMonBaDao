# Bàn giao M2 + lát cắt JXQY2 — 20/10/2026

Nhánh: `work/playfirst-demo-max-v3-20261020`. Commit code: `8db9b9e358aceb9711ca7966e623fb011ae5195e`, từ HEAD đã đối chiếu `98f9bc79392af2354a7dbf07130fa9dbc9d7fd28`. 22 file code/metadata được ghi bằng GitHub connector; Git blob SHA của từng file khớp bản local đã QA.

## Chơi ngay trên máy này

Mở `Chay-JXQY2-DEMO.cmd` trong thư mục outputs. Script gọi entry JXQY2 riêng, kiểm tra Godot 4.7.2 và kiểm đủ 44 hash nguồn trước khi chơi. Cache nguồn: `E:\codex\work\jxqy2_slice\source`. Đây là cache local, không nằm trong commit hoặc pack phát hành.

Cách chạy từ checkout cùng nhánh:

~~~powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/qa/Run-TMB-JXQY2-Slice-Windows.ps1 -SourceRoot "E:\codex\work\jxqy2_slice\source" -GodotBin "E:\Godot_v4.7.2-stable_win64_console.exe" -SandboxRoot "E:\codex\work\godot_isolated"
~~~

Profile kế thừa DEMO MAX: Tu Vi/Luyện Thể 30.10/30.10, 6 thợ săn, 6 người làm việc, trang bị và sản xuất từ API hiện có. Mặc định chọn một đệ tử đã sở hữu Thanh Thiết Kiếm để xem rõ hoạt ảnh/VFX. Đệ tử này được khởi tạo P2 stage 9 trong profile sandbox, chuẩn hóa bằng CultivationSystem rồi học Ngự Kiếm Thuật qua CombatSkillSystem; không thay điều kiện học hoặc công thức. Những đệ tử còn lại vẫn có trong UI.

Save riêng: `user://demo_sandbox/jxqy2_playable_demo_v1.json`; policy riêng: `user://demo_sandbox/jxqy2_auto_skill_policy_v1.json`. Nếu save đã tồn tại, entry tiếp tục save đó. Launcher M1 giữ nguyên.

## Chức năng thực sự dùng được

- Đệ tử tự chọn mục tiêu, tìm đường tránh collision nguồn, di chuyển, đánh thường và dùng các skill sát thương đã học/được đặt trong policy. Bật/tắt, ưu tiên, điều kiện HP, tầm, tier và cụm mục tiêu đi qua dispatch thật. Tối đa 4 ô chủ động; luật 1 Thường Kỹ và hệ bị động hiện có được giữ nguyên.
- Trận mới dùng controller cấu hình không được nhận heal/guard/AOE miễn phí từ role. Các consumer chưa có logic thật không được đưa vào auto bar. Trận legacy/checkpoint cũ vẫn giữ hành vi cũ.
- Vùng JXQY2 dùng toàn bộ map 50×100, 3 lớp và 16 MPC tile có nguồn. Camera kéo trong ranh giới map; follow một nhân vật chỉ khi chủ động chọn. Không forced-end sau 90 giây; có respawn và lệnh về tông môn.
- Snapshot giữ lưới điều hướng cùng RNG, HP, cast và template respawn. Luật sát thương, cooldown, tốc độ, nguyên tố, phần thưởng và Warehouse vẫn do Combat V2 tính.
- Đã sửa mất policy trên đường UI → HuntingPveRunV2; cue chết tồn tại sau respawn; lệch nửa ô của nền; khôi phục ba loadout JX của M1 bị mất trong M2 trước đó.

Map gốc có 5.000 ô, 525 ô chặn theo mask nguồn `0xC0`, 26 ô trap. Dữ liệu trap được giữ nhưng chưa chạy script trap/exit của JXQY2. Tìm đường là lưới bốn hướng của adapter V2, không tuyên bố là thuật toán JXQY gốc. Vị trí xuất hiện là formation V2 cộng offset (7,40), đưa về ô đi được; MAP không chứa spawn NPC để chứng minh spawn gốc.

## Asset và skill có bằng chứng

Nguồn asset: `Upwinded/jxqy2-assets@8ffc1ecd1b50742ac619bf74684f70b9850c2af3` — JXQY2 offline. Manifest runtime: `godot/data/combat/jxqy2_slice_v1.json`. Bảng kiểm từng path/kích thước/blob/frame/FPS/anchor: `docs/M2_JXQY2_ASSET_AUDIT_2026-10-20.json`.

| Thành phần | Bằng chứng và trạng thái |
|---|---|
| Nam Cung Phi Vân | `save/rpg0/player.ini` → `ini/npcres/z-南宫飞云.ini`; đủ đứng, đi, đánh, thi triển acMagic, trúng đòn, chết; 8 hướng. Visual chỉ gắn với actor có weapon path `sword` từ trang bị thật; vũ khí chưa có binding không được mượn skin này. |
| Sói xám | `npc-n02-灰狼.ini` và 5 clip nguồn; dùng làm skin quái thường V2 trong lát cắt. |
| Actor Boss | `npc-b39-剑客掌门1.ini` và 5 clip nguồn. Boss là tier của encounter V2; chưa chứng minh NPC này là Boss trong game JXQY2 gốc. Danh tính/loài V2 và skin nguồn là hai dữ liệu khác nhau. |
| Ngự Kiếm Thuật | Skill V2 thực, consumer `direct_damage`, mapping nội dung nguồn `天意剑诀`. Không dùng các giá trị damage/mana/level/cooldown của JXQY2. |
| Thi triển | Clip `z01-南宫飞云-sat.mpc` từ mục `[magic]`, 128 frame/8 hướng, 30 ms/frame. Đây là acMagic chung của actor nguồn; INI skill không khai báo actionfile riêng. File `image=天意剑诀.mpc` một frame là hình UI và không được vẽ thành VFX chiến đấu. |
| Projectile | `magic-南宫飞云攻击.mpc`, 112 frame/16 hướng, 40 ms/frame; liên kết trực tiếp từ INI kỹ năng. |
| Impact | `explod-大型红色爆炸a.mpc`, 16 frame, 46 ms/frame; chỉ xuất hiện sau biên nhận sát thương learned_skill dương từ V2. |

FPS, thứ tự frame và anchor được đọc từ file gốc; animation chạy ở khoảng frame nguồn, có giữ/loop khung hình khi cần khớp thời điểm V2. VFX bám vị trí đang hiển thị của actor. Không dùng hiệu ứng của skill không có liên kết nguồn. `source_school` và điều kiện `required_weapon` để học chưa có bằng chứng; để null, không áp hình phạt khác phái hoặc luật học mới.

## QA focused trên Windows / Godot 4.7.2

| Kiểm tra cuối | Kết quả |
|---|---|
| jxqy2_source_slice_v1_test | PASS — 44 hash, toàn map/lớp/frame, collision, 16 clip, vũ khí, policy qua dispatch, không tự cấp phép role spell, 111 giây liên tục, snapshot tái lập, camera vượt arena cũ |
| m2_auto_combat_continuous_world_test | PASS |
| dv2_02_battle_snapshot_test | PASS |
| dv2_02_group_map_battle_test | PASS — mẫu cân bằng legacy giữ kết quả |
| c4_be01_real_hunting_ui_smoke_test | PASS |
| pd01_demo_max_playable_test | PASS — 3 cue JX, reward qua API trở về/claim, save mặc định ABSENT trước và sau |
| Entry chơi JXQY2 | PASS smoke — JXQY2_DEMO_READY, 44 nguồn, save riêng, exit 0 |
| Godot GUI 1280×720 | PASS kỹ thuật — 5 ảnh thật: roaming/cast/projectile/impact/camera_free; tự chọn mục tiêu, basic hit và impact dương đã xảy ra |

Test M1 được cập nhật theo yêu cầu vùng liên tục: dọn wave vẫn phải active, sau đó gọi return_to_base và claim thật; giữ các assertion reward/JX/ownership/save. Các lần QA trung gian từng bắt lỗi, đã sửa và chạy lại; bảng trên chỉ ghi lần cuối.

Engine: `4.7.2.stable.official.ed1daf0bf`; GPU GUI Intel Iris Plus / OpenGL Compatibility. Godot có cảnh báo không đọc được root certificate store của Windows; các test không dùng mạng và đều có marker PASS. Không chạy FULL, CI hoặc merge.

## Phần còn thiếu và điều kiện phân phối

Nghiệm thu hình ảnh của người dùng: **PENDING**. Ảnh là viewport Godot thật, không phải nghiệm thu toàn bộ 8/16 hướng trên mọi thiết bị. Tán cây nguồn có giảm alpha khi che actor; cần tiếp tục đánh giá độ dễ đọc và hiệu năng. Android/ZIP game độc lập: **PENDING**.

Danh tính Boss gốc, trường phái/điều kiện vũ khí để học, sound/shadow và thực thi trap nguồn: chưa hoàn tất; không gọi lát cắt này là toàn bộ JXQY2/JX1 đã tích hợp.

Tree nguồn 8.223 path không có LICENSE/COPYING; README chỉ có tên repository, chưa xác lập điều khoản phân phối asset. `JXQY-all-in-one@6ff516bc1439e2b622a2e0ee4e1433cd98f8ec61` có GPL-3.0 cho code; điều này không chứng minh quyền phân phối riêng kho game asset. Chỉ dùng engine đó để kiểm chứng cấu trúc/ý nghĩa dữ liệu; bộ đọc/adapter được viết độc lập. Binary ngoài giữ local, không commit hoặc đưa vào pack phát hành. Quyền owner đối với JX1 đã cung cấp vẫn là authority riêng, không bị mở lại.
