# TÔNG MÔN BÁ ĐẠO — CODEX MASTER EXECUTION PLAN

## PLAY-FIRST DEMO MAX TOÀN BỘ HỆ ĐÃ TRIỂN KHAI + COMBAT V2 REALTIME + JX1 COMBAT + UNIFIED ASSET FORGE

**Ngày:** 2026-10-20  
**Loại:** KẾ HOẠCH THỰC THI / CODING PACKETS / TÀI LIỆU BÀN GIAO CHO CODEX  
**Trạng thái:** DESIGN/READ-ONLY PLAN; **chưa triển khai runtime theo file này, chưa có QA PASS mới**  
**Repo:** `vuanhtuan161094-byte/TongMonBaDao`  
**Engine/đích:** Godot **4.7.2**, Android landscape **1280×720**, Windows preview 1280×720.  
**Tại thời điểm lập:** `main` = `461caca1171462e0da092f21108c5c1733157ad9` (KHÔNG phải build chơi tích hợp); nhánh hiện có đủ chuỗi G1+C4+camera+đính chính tài liệu: `c4-jx1-camera-world-source-audit-20261020`, HEAD đã kiểm **`b83b92f3832c28520d620de8b11aeb7a557dcce4`**. Khi Codex bắt đầu: FETCH LẠI HEAD, không được giả định SHA vẫn mới nhất; dùng nhánh tích hợp mới nhất chứa G1 PR#20 + C4, KHÔNG fork `main` cũ đơn lẻ. Cần đọc `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, `docs/TMB_DAO_MASTER_AUDIT_NEXT_CHAT_2026-10-20.md`, `docs/C4_G1_MAP25_COMBAT_INTEGRATION_QA_DEBTS_2026-10-19.md` và blueprint Asset Forge đã được người dùng cung cấp.  
**Ưu tiên người chơi:** **nhấn một lần, vào game thật, nhìn thấy đệ tử max cấp tung JX1 skill thật, map lớn kéo tự do, AI đánh liên tục**. Test mode nhiều chức năng nhưng **không xâm nhập gameplay production và save thật**.

## ĐÍNH CHÍNH V3 — AUTHORITY & PLAYABLE FIRST (20/10/2026)

Tài liệu này là **bản plan V3 đã rà soát**, thay thế prompt ở §9 của bản v2; không phải bằng chứng gameplay đã chạy. Nội dung từ file Markdown do owner gửi là nền tảng, các thay đổi V3 được ghi rõ ở đây. Đừng coi một checklist thiết kế là đã CODE/PASS.

**Priority order:** P0 **Play-Now sandbox + JX visual slice** → P0 **auto-skill cấu hình được + roaming liên tục có save đúng** → P1 **JX real-source skill/VFX library mở rộng + Asset Forge tối thiểu** → P1 **UX Android/QA focused** → P2 **land/economy/endgame và nợ còn lại**. Không chuyển P2 thành blocker của P0.

**Định nghĩa 1-click:** chạy launcher từ một bản clone/protected workspace, không auto fresh-clone/import/test/FULL mỗi lần. Test DEMO và chế độ chơi thường tách state/save. Trước Play, chứng minh trên chính runtime đường dẫn tuyệt đối `OS.get_user_data_dir()` là sandbox; không coi biến `GODOT_USER_DATA_DIR` là Godot API được bảo đảm nếu chưa kiểm chứng. Đo SHA/checksum file save thật trước/sau. Chỉ sử dụng tên slot khác trong cùng `user://` là chưa đủ bằng chứng cách ly toàn diện nếu SaveService có file global. Verify official Godot user paths and launch subprocess environment empirically.

**Nhân sự demo:** một **đội săn 6 đệ tử MAX 30.10/30.10**, cộng **nhóm lao động DEMO riêng** (mục tiêu thêm 6 người, tối thiểu đủ ba nghề Mine/Forest/Field) nếu state/capacity canonical hỗ trợ. Không dùng cùng một đệ tử đồng thời đi săn và làm công trình: One Active Job. Dùng một bảng DEMO HUB có các liên kết thật và trạng thái thật.

**Skill max:** max hóa việc **học và mastery** của những skill có consumer V2 hợp lệ trong sandbox; **equipped** theo slot 1 basic + tối đa 4 active + tối đa 6 passive từng nhân vật. Hai khái niệm hoàn toàn khác nhau. Số lượng skill hoàn thiện thực tế phải đọc code, không mặc định 14/14. Năm skill pilot JX1 không đồng nghĩa năm bộ VFX cast/fly/hit đầy đủ.

**Định nghĩa asset source-backed:** `2.jpg` trong owner Drive Võ Lâm Idle là ảnh zone có nguồn, nhưng **FAN_DERIVATIVE**, không được gọi native/original JX1 map. Không có collision/tile thật từ JPEG. Cho phép nền này làm visual bridge khi binary gốc chưa đọc được, ghi rõ nhãn/source trong report, trong khi tiếp tục port map/skill/VFX có ID thật. Không bịa kỹ năng hay frame missing và không mạo nhận tất cả ba VFX là ba skill hoàn chỉnh.

**D08:** chọn một map + actor + normal + Boss + 3 cue FX là **chiến lược vertical-slice đề xuất**, không phải quyết định gameplay owner đã khóa. Các D01/D02/D03/D07 đã được owner khóa; D05/D18 là trách nhiệm điều tra kỹ thuật; D14/D15/D16/D19/D21/D23/D24 không được tự chế luật.

**Nợ C03:** 7 skill P2 non-damage deferred vẫn là debt thật, nhưng không phải trọng tâm của bản demo JX. Chỉ giải quyết khi cần adapter hoặc regression. Gameplay mới không được giả có skill nếu consumer chưa hoạt động.

**Continuous world:** PD-04 bắt đầu bằng một zone, sử dụng Combat V2 làm hit/crit/damage/RNG authority; có lifecycle versioned cho wave/monster kill/respawn và settlement. `finish()/claim()` cũ, RNG snapshots, `MAX_EVENTS`, pending missiles và participant reservations phải được xét. Không xóa thẳng `MAX_SECONDS`, không tín dụng Warehouse từng frame. Mặc định loot/wave được chốt theo một settlement/receipt có ID duy nhất; phương án claim tại return/hunt stop cần chứng minh tương thích save, không tự thêm economy faucet.

**Scope và quyền CODE:** owner cấp phép Codex thông qua prompt thực thi đi kèm cho PD-00, PD-01, PD-02, PD-03 (subset), PD-04 (giữ toàn bộ Combat V2 formulas), PD-06–08 theo từng packet. Không tự đổi CombatStatsV2 numerical formulas, Accuracy/Evasion draft, loot balance, production rates, Injury, slot counts, save format production hoặc nền tảng economy. Những đổi mới schema về world session chỉ áp dụng demo schema versioned và có backward tests; cần thay shared canonical save contract thì ghi blocker để owner duyệt packet riêng. Mỗi packet chỉ một writer, cập nhật SHA và chạy focused đúng code đã đổi.

**Bốn mốc nghiệm thu thực tế:**
- **M1:** One-click DEMO thật + một squad MAX + người lao động riêng + JX source-backed combat visual, ít nhất 3 cue FX đã xác minh; Windows scene launch thật.
- **M2:** Skill setup lưu/khôi phục, auto AI dùng đúng skill, một zone liên tục không 90s forced stop, camera drag/follow/zoom, save/resume versioned đúng receipt.
- **M3:** JX source map/sprite/skill atlas tăng dần, catalog Forge subset chứng minh hash/ID, các skill được chia `USABLE/PARTIAL/MISSING`.
- **M4:** UX G1+Combat dễ chơi, stress 30v40 chạy riêng, Windows focused QA, Android build/physical test báo trạng thái trung thực.

**Giao hàng:** trong từng mốc ưu tiên launcher dùng ngay (hay recipe reproducible nếu môi trường không tạo binary), hướng dẫn `CACH_CHOITHU.md`, head SHA, screenshot Godot thật nếu có, skill/asset truth table, PASS/FAIL/PENDING chính xác. **Không yêu cầu owner tự sửa code hay duyệt từng bước đã nằm trong packet.**

---

## 0A. REVIEW CORRECTION — ƯU TIÊN PLAY-NOW (20/10/2026)

Bản review này sửa bốn nguy cơ làm Codex đi lệch mục tiêu:

1. **DEMO MAX không chỉ max nhân vật.** Trong sandbox phải mở/max **mọi hệ đã thực sự triển khai và an toàn để test**: Tu Vi/Luyện Thể, skill/mastery đã có consumer, equipment hợp lệ, tài nguyên test trong Warehouse canonical, các công trình/production instance đã có authority, recruitment, workforce, hunting và UI liên quan. Hệ chưa có implementation thật phải hiện `NOT_IMPLEMENTED`, không dựng giả.
2. **JX1 combat phải có ngay ở checkpoint đầu tiên.** Không chờ hoàn thiện Asset Forge mới cho người chơi nhìn thấy JX1. Checkpoint đầu phải có tối thiểu một map source-backed, actor/quái/Boss JX1 hoặc owner-authorized JX combat sprites đã xác minh, HP bars, và ít nhất 3 VFX/event stage có provenance thật. Không được giao lại nền phẳng/Source A combat rồi hẹn PD-03.
3. **Ưu tiên skill JX1 thật, không ưu tiên trả nợ legacy P2.** Combat V2 giữ engine/formula; content skill ưu tiên lấy identity/animation/projectile/VFX/functional intent từ JX1 rồi map sang consumer V2. Bảy P2 non-damage deferred chỉ giữ để backward compatibility/regression; không được chiếm critical path nếu không phục vụ demo JX1.
4. **Asset Forge P0 chỉ ingest JX1 + Source A + tools hiện có.** JX2/JXQY2/Phong Thần là nguồn tham khảo/tool fallback, không được biến thành nghiên cứu blocker trước khi có playable demo.

**Nguyên tắc demo:** tối đa hóa *khả năng thử nghiệm*, không tối đa hóa cheat trong production. Mọi grant/max đều nằm trong sandbox save cách ly và đi qua state canonical nơi có thể.

---

## 0. BỐN QUYẾT ĐỊNH CHỐT — ĐỪNG DIỄN GIẢI LỆCH

1. **D01 — Combat V2 giữ luật.** `CombatStatsV2`/`MapBattleV2`/hệ kỹ năng V2 chịu trách nhiệm damage, HP, phòng ngự, crit, kháng hệ, hit/evade theo phiên bản đã được owner cho phép và RNG. **Không sao chép công thức combat JX1.** JX1 là **nguồn content combat chính** cho skill identity/functional intent, animation, projectile, VFX, actor/quái/Boss, map và cảm giác đánh JX; **Combat V2 vẫn quyết định công thức số học, stat, damage, crit, RNG và tương tác hệ**. Ví dụ skill JX1 là độc/heal/AoE/buff thì giữ đúng bản chất đó khi map sang consumer V2, nhưng hệ số và resolve theo V2. Một skill JX1 phải có consumer V2 thật; không chỉ phát FX minh họa.
2. **D02 — Realtime continuous map.** Các đệ tử săn/đánh quái liên tục trên bản đồ lớn, camera pan/zoom độc lập; hết 90 giây **không** tự kết thúc săn. Thay rào `ARENA=36×20`, `MAX_SECONDS=90` ở tầng world/encounter bằng kiến trúc roaming phiên bản hóa; **không đổi các phép tính sát thương V2**.
3. **D03 — Auto combat.** Người chơi setup các skill đệ tử; AI tự chọn target, di chuyển tới tầm, đánh thường, dùng skill đúng điều kiện/thứ tự ưu tiên/cooldown; lựa chọn đội/tùy chỉnh ngoài trận. Không bắt người chơi điều khiển trực tiếp từng đệ tử. Tối đa **6 đệ tử/đội**, **30/nhóm** như luật hiện có.
4. **D07 — Ngũ Hành/Spiritual Roots Combat V2** là authority. Tương thích định danh JX1 bằng metadata/adapters, không thay V2 bằng công thức Ngũ Hành JX.

**Phân vai asset:** Source A cho tông môn/G1/MAP25/đệ tử tại tông môn; **JX1 cho toàn bộ combat** (môi trường, model/sprite nhân vật combat, quái/Boss, projectile, cast/impact/AoE/VFX/SFX). Quyền dùng hai nguồn người dùng cung cấp **đã chốt, không hỏi lại**. Phải phân biệt file JX1 thật với JX1M Unity, JXQY2, JX2 và fan-made Võ Lâm Idle. Những gì chỉ đến từ fan game phải ghi `FAN_DERIVATIVE`, không gọi là original JX1.

**Bất biến:** 30 cảnh giới × 10 tầng **riêng biệt** Tu Vi và Luyện Thể; Injury 0/1 hồi 120 simulation-minute ticks; One Active Job; 1 worker/Mỏ–Linh Lâm–Linh Điền; một Warehouse/scheduler/save/offline; Sect-owned equipment; exactly-once loot/production; không xóa/migrate real save ngầm; không tự thêm trị số mới; Lv100 production/economy không đổi trong gói combat. Combat V2 mature loadout: **1 Thường Kỹ + tối đa 4 Chủ Động + tối đa 6 Bị Động**, tiến hóa Nhân–Tiên–Thần; chưa đủ consumer thì phải ghi PENDING, không lén coi có thật.

**Khác biệt quan trọng:** `max tất cả kỹ năng để test` nghĩa là có thể **mở toàn bộ skill ĐÃ THỰC THI & dữ liệu sở hữu hợp lệ** trong sandbox; vẫn tuân thủ slot và tính tương thích. Không lấp đầy thanh kỹ năng bằng skill chưa có implementation rồi báo playable. Giữ toàn bộ thư viện khám phá được ở codex catalog, phân nhóm `USABLE`, `VISUAL_ONLY`, `METADATA_ONLY`, `MISSING`.

---

## 1. BASELINE ĐÃ XÁC MINH — NỢ THỰC TẾ, KHÔNG TỰ GỌI PASS

### 1.1 Code/bối cảnh

- `godot/project.godot`: scene chính `res://scenes/p3/p3_2_landscape_sect.tscn`; landscape 1280×720, GL Compatibility.
- `godot/src/simulation/combat/map_battle_v2.gd`: `STEP_SECONDS=0.25`, `MAX_SECONDS=90.0`, `ARENA=(0,0,36,20)`, `MAX_DISCIPLES=30`, `MAX_MONSTERS=40`, `MAX_TARGETS_AOE=3`, tối đa 2.400 sự kiện; deterministic battle, không phải continuous roaming world.
- `godot/src/simulation/combat/hunting_pve_run_v2.gd`: session validate V2 profile, reserve participant, persist active PvE, settle then claim via Warehouse; current flow phụ thuộc encounter hữu hạn. Đổi world loop có rủi ro rất cao với reward/save/active-job.
- `godot/src/simulation/combat/disciple_combat_loadout_v2.gd`: build stats từ V2 realm/body, gear và P2 learned skill; **2 kỹ năng damage operational**, **7 non-damage P2 skill deferred**; nếu pilot loadout JX khác rỗng thì hiện không được kết hợp active bar learned. Không giả rằng toàn bộ skill đã code.
- `godot/src/simulation/combat/jx_pilot_skills_v1.gd`: đúng **5** skill pilot: `jx_shaolin_15`, `jx_wudang_158`, `jx_wudang_159`, `jx_wudu_63`, `jx_emei_93`; `jx_pilot_runtime_v1.gd` đã có các hiệu ứng V2 cụ thể và thời điểm cast/impact riêng. Không tự cấp skill cho nhân vật chỉ từ môn phái.
- `godot/data/presentation/c4_jx1_pres00_five_skill_asset_manifest.json`: mới có WebP imported được pin hash ở **7** file skill; #15 precast và #93 cast chưa tìm được binary, #159 chưa có clip cast/hit bound. `godot/assets/combat_v4/jx1_skill_fx/fx_manifest.json` mới map các cue #158 impact/#63 impact/#93 precast.
- `godot/assets/combat_v4/source_vl/` có atlas actor/boss và sword VFX; `MapBattleWorldLayerV2` + `HuntingPlayPanelV2` đã có nhánh camera tự do / chọn-follow, **chưa có Godot Windows PASS trên HEAD sau correction**.
- `godot/assets/actors/1113028_1`, `body_1120402`, `body_1110201` là mẫu Source A trong tông môn; ENV02A có 32 ảnh. Không biến chúng thành combat JX1 theo mặc định.
- `tools/assets/restore_map25_env02a_art.py`, `tools/fe01b1/export_verified_pack.py`, `godot/src/presentation/p3/combat_v4_effect_atlas.gd`, `combat_v4_sprite_atlas.gd` tồn tại. **Không tạo converter trùng.** Chưa có một Asset Forge toàn cục production được chứng minh.
- Bản gốc JX1 cần xác thực từ `phucnb/JXLinux-8.1.11` (`client/settings/skills.txt`, `missles.txt`, Lua và PAK/map); owner Drive/Võ Lâm Idle có **17 JPEG zone** với một ảnh `2.jpg` 3584×3584 SHA256 `cf1bc9d64d3399c7130a535dd4d1e6da83d48fe5c0fdf7aa48aaadd679322e07`. **Ảnh JPG KHÔNG chứa collision/tile/spawn gốc**; dùng tạm ảnh nguồn có provenance `FAN_DERIVATIVE` để chơi preview nếu map binary gốc chưa giải được, không gọi tile map JX1 bản gốc.
- Dự án thử nghiệm Source A Batch01: 10 rig/31 clip/1.016 frame (theo handoff), không đồng nghĩa toàn library asset đã chuyển đổi.

### 1.2 Chứng cứ QA đúng SHA

- `C4_G1_INTEGRATED_QA_LOGS.zip` tại `770f8f3`: **13/17** focused PASS; fail workforce notification, GDScript MAX30v40 type, V2 roster chọn không launch, Injury T15.
- `C4_G1_UX_FIX_QA_LOGS.zip` tại `0fb2b82`: **5/6** targeted PASS; Injury fixture `another_direct_command` FAIL, sau đó test fixture sửa nhưng chưa nghiệm thu lại bằng runtime.
- `C4_G1_FOREST_CAMERA_QA_LOGS.zip` tại `073e2d9`: **PLAY ONLY, 0/6 focused**; clone 7.6s, import 38.12s; 244.51s là **thời gian cửa sổ trò chơi mở**, không phải startup.
- `main` không chứa toàn bộ chuỗi G1+C4 mới; user đã bác UX combat nền phẳng, camera bị bó, thiếu đất thực. Các bản vá camera/ảnh trên nhánh audit mới **có code nhưng official Godot 4.7.2, hình ảnh nghiệm thu/Android chưa PASS**.
- Q01–Q17 là **4 automated groups + 6 manual/device groups + 7 backlog groups**, KHÔNG phải 17 test đều đỏ. `CURRENT_CHECKPOINT.md` và `NEXT_CHAT_HANDOFF.md` là nguồn bằng chứng mới nhất; không suy đoán PASS theo số test khai báo.

### 1.3 Tất cả debt cần quản trị trong kế hoạch (không bỏ sót)

| Mã      | Mô tả                                                                    | Packet sở hữu / outcome                             |
| ------- | ------------------------------------------------------------------------ | --------------------------------------------------- |
| U01     | Người chơi mới không có V2 recruit đủ điều kiện đi săn                   | PD-01 DEMO hợp lệ + đường chơi thường giải thích rõ |
| U02     | Không có Play-only launcher một nhấn, cold import đắt                    | PD-00 cache/launcher, tách Play/Test, đo cold/warm  |
| U03     | Chữ trắng nền sáng, panel quá nhiều, chữ nhàn rỗi rối                    | PD-06 giao diện/contrast/action info                |
| U04     | Chọn roster vs thật sự dispatch dễ nhầm                                  | PD-01/PD-06 status 3 bước, không fake               |
| C01     | Combat còn 36×20/90s                                                     | PD-04 vùng roaming, snapshot versioning             |
| C02     | Auto-skill player-configurable chưa end-to-end                           | PD-02 ưu tiên/cast/target với điều kiện             |
| C03     | 7 P2 non-damage skill deferred                                           | P2 compatibility debt; PD-02 only if needed        |
| C04     | Accuracy/Evasion tính toán và kỹ năng né còn design-only                 | PD-05 packet phụ, không sửa ngầm V2                 |
| C05     | Movement stat đã derive nhưng path AI/chạy map cần đồng bộ               | PD-04/PD-05                                         |
| C06     | JX asset skill + renderer chưa đầy đủ, một số clip missing               | PD-03 Asset Forge/manifest/cue map                  |
| C07     | Chưa xác minh native original JX1 map + PAK/SPR decode/collision         | PD-03/PD-04, phân loại theo nguồn/định dạng         |
| C08     | Boss warning/reaction có design nhưng skill né chưa thật                 | PD-05, không dịch chuyển giả                        |
| C09     | 30×40 stress với 30.10 cả hai nhánh chỉ là fixture, chưa có demo UI      | PD-01 DEMO + PD-07 stress                           |
| P01     | Hệ sản xuất Mine/Forest/Field + timer/receipts UI cần nhìn được          | PD-06 bảo trì/readability                           |
| P02     | Source A icon sheet/idle glyph chưa chứng minh                           | PD-03/PD-06, không fake icon Source A               |
| P03     | Land/Hall paid building transaction/movement chưa production             | BL-01 ngoài combat critical path                    |
| P04     | Tăng trưởng Lục Duy vĩnh viễn, slot 10 gear, 1k–3k auto worker chưa trọn | BL-02, BL-03, chưa fake                             |
| P05     | Lv100 faucet/sink, trang bị/crafting/late-game chưa đủ                   | BL-04 balance sau PLAYABLE                          |
| Q01–Q04 | Automated legacy debts (Injury, P3, O6, P3.7)                            | only affected focused, phân biệt baseline           |
| Q05–Q10 | Win GUI, Android, map FPS, save fault, large population                  | PD-07/manual hardware/release gate                  |
| Q11–Q17 | DV2-03 PAUSED + Phase backlog/land/scale                                 | BL-01…BL-06, **không** đổi nhãn PASS                |

---

## 2. MỤC TIÊU SẢN PHẨM VÀ HAI CHẾ ĐỘ

### 2.1 DEMO MAX — bắt buộc ưu tiên #1

Ngay khi vào test build, cung cấp **`CHƠI NGAY — DEMO MAX`** (nút 48+ px landscape), kế bên **`CHƠI TỪ ĐẦU`** và **`TIẾP TỤC SAVE DEMO`**. DEMO phải được chứng minh là game state thật qua API canonical, không phải ảnh hoặc mock battle.

- Một lần nhấn tạo **sandbox save riêng**: `demo_max_v1`, có dấu `sandbox_demo=true`, seed cố định + unique save slot; không dùng chung `user://` production path và không ghi vào current live saves. Demo reset chỉ thao tác trong sandbox; build release không cho unlock cheat/demo (hoặc đưa qua riêng tester build/profile flag).
- **6 đệ tử V2 chiến đấu** hợp lệ, **Tu Vi realm 30 floor 10, Luyện Thể realm 30 floor 10**, HP được tính từ `CombatStatsV2.derive`/valid profile canonical, các chỉ số nguồn hợp lệ; team mặc định 6 vị trí rõ ràng. Nút `THÊM 24 ĐỆ TỬ DEMO` để thử 5 đội × 6, chỉ khi renderer/profiler chịu được; không tạo 3.000 actor mặc định.
- Sở hữu thư viện tất cả kỹ năng **đã có logic/định nghĩa thực**; nếu hệ mastery hỗ trợ giá trị max và yêu cầu học hợp lệ, tối đa hóa tại riêng sandbox. **Không claim 14/14 usable**: hiện pilot 5 + P2 2 damage operational, 7 P2 deferred; mở menu thể hiện `Usable / Đang phát triển` trung thực. Bố trí tối đa **1 basic, 4 active, 6 passive**/đệ tử theo những loại hiện khả dụng. 5 pilot skills có thể chia trên 6 thành viên; không nhét cả 5 vào 4 active của một người. `Set kỹ năng Auto` chỉ lưu **loadout/priority** thông qua canonical model; không tự gán từ phái.
- Nếu người dùng muốn nhìn ngay nhiều skill, demo chia role: cận chiến/tank, kiếm pháp, Ngũ Độc, hồi máu, AoE, hỗ trợ, **chỉ khi skill tương ứng tồn tại thật**. Các slot chưa có consumer hiển thị `Chưa khả dụng`, không bắn vòng sáng fake. Cấp/thuộc tính monster tương ứng để demo max vẫn có thời gian ra chiêu; có preset `Dễ xem chiêu`, `Cân bằng`, `Boss`, `30v40 Stress`, không chỉnh damage/cooldown Combat V2 bí mật.
- `BỘ THỬ`: nút hồi HP (chỉ sandbox), đổi đội, chọn skill, reset vị trí, bắt đầu/dừng săn demo, chọn 1 quái/elite/Boss hợp lệ; **không làm x2/x4 simulation trong checkpoint đầu** để tránh đụng scheduler/save; công tắc HUD: hit logs, FPS, collision grid và actor labels.
- Starter demo cung cấp tài nguyên/trang bị/equipment hợp lệ **qua factory riêng có nguồn sự kiện TEST_GRANT**; chỉ nhập vào Warehouse canonical của **demo state**, không tạo Warehouse thứ hai; mọi grant có log và tag `TEST_ONLY`, rõ với người chơi. Tuyệt đối không dùng quà test để sửa production reward/economy.
- **DEMO MAX TÔNG MÔN:** tạo các đệ tử làm nghề DEMO riêng (mục tiêu 6, ít nhất 3 worker nếu capacity hợp lệ) để đệ tử đi săn không phải vừa chiến đấu vừa làm việc theo One Active Job; mở sẵn những hệ production/backend đã có authority thật để người chơi bấm thử ngay: Dẫn Tiên/recruitment, Warehouse, Workforce, Mỏ/Linh Lâm/Linh Điền, các timer/receipt và building level/instance **chỉ trong phạm vi code đã thực sự hỗ trợ**. Với hệ có level canonical, tạo preset sandbox ở mức cao/max hợp lệ để nhìn được scaling; hệ chưa có transaction chuẩn (ví dụ land/Hall/build/move còn thiếu) phải để `NOT_IMPLEMENTED`, không fake nút thành công.
- Có **DEMO HUB** hoặc panel tester nhỏ dẫn thẳng tới: `TÔNG MÔN`, `TUYỂN ĐỆ TỬ`, `KHO`, `PHÂN CÔNG`, `SĂN NGAY`, `SKILL SETUP`, `BOSS`, `STRESS`. Mục tiêu là người chơi không phải tự dựng save rồi mới test được tính năng.
- Sau 1 lần click: phải nhìn **map combat source-backed**, 6 actor đi/chạy, ít nhất vài quái + 1 Boss, thanh HP, skill cast/impact VFX thật, skill heal/buff nếu implemented; màn hình không che kín camera, có nút thoát về tông môn, tạm dừng và save sandbox.
- **Minimum JX combat slice bắt buộc ngay Checkpoint 1:** không giao nền phẳng hoặc Source A combat. Dùng asset JX1/owner-authorized đã xác minh hiện có trước; nếu map binary gốc chưa giải được thì dùng `2.jpg`/zone source-backed được gắn provenance đúng làm background tạm, nhưng actor/quái/VFX phải ưu tiên JX combat asset thật đã tìm thấy. Missing asset phải hiện debug `ASSET_INCOMPLETE`, không vẽ giả.
- Vẫn kiểm tra được tiến trình bình thường **Realm1/Floor1**: nút `CHƠI TỪ ĐẦU` dùng recruitment V2 thật; không sửa P2 founders thành V2 bằng default fallback.

**Cảnh báo thiết kế TEST:** Max 30.10 có thể giết quái cấp thấp 1 hit; muốn nhìn skill thì dùng monster cấp tương ứng hoặc sandbox NPC target bất tử **CHỈ CHO DEMO**, không áp dụng vào production. Tách rõ `max skill mastery` (tiến trình) khỏi `max slot` (4 active) và `max damage` (đầu ra tính từ V2).

### 2.2 GAMEPLAY THẬT — không test-cheat

Vẫn có Dẫn Tiên tuyển V2 → chọn đội → vào map săn đúng region/level → AI chiến đấu tự động → trận/đợt/khu vực hoàn thành thật → nguyên liệu nhận Warehouse exactly once → về tông môn/làm nghề; rollback/save/offline giữ nguyên. Không thay fake fixture vào canonical state và không tự sinh 30.10 trong save bình thường.

---

## 3. KẾ HOẠCH THEO GÓI TRIỂN KHAI (CODING PACKETS)

**Quy tắc vận hành:** mỗi packet có owner một nhóm file, nhánh và checkpoint riêng. Có thể CODE theo packet vì user gửi toàn bộ instruction này cho Codex; trong từng packet, **không đổi cơ chế/cân bằng ngoài phạm vi**. Cần bổ sung allowlist đường dẫn chính xác sau khi Codex đọc tree (các tên `test_*`, `*_sandbox_*` bên dưới là **đề xuất tên file mới**, chưa xác nhận đã tồn tại). Mỗi commit ghi SHA và focused PASS/PENDING. Đừng mở 7 packet song song trên file cùng subsystem.

### PD-00 — SAFE BRANCH + 1-CLICK PLAY: Làm ngay

**Mục tiêu:** Windows chạy một cửa sổ game, không tải/test đi test lại trước khi chơi.

1. `git fetch --all`, xác minh `AGENTS`/đúng HEAD của G1+MAP25+Combat V4+camera; lập `BASELINE_SHA.txt` trong logs (không sửa main). Khởi tạo **1 nhánh integration code** từ HEAD verified; source branches chỉ để tham chiếu, không merge blindly các stacked PR chưa test.
2. Tạo `Run-TMB-Demo-Windows.cmd` + `.ps1` nhỏ trong `tools/qa/` hoặc root theo quy ước; `-Play` mặc định; `-Focused` tách rời; `-ResetDemo` riêng có confirm và chỉ xóa sandbox path. Chọn exact Godot 4.7.2, validate version, môi trường `GODOT_USER_DATA_DIR`/`APPDATA` / isolated profile; lần đầu import, lần sau **reuse persistent cache** keyed repo SHA + manifest hash; không fresh clone mỗi lần. `-Focused` chạy sub-process riêng, không tự chạy trước mỗi Play. Bật GUI 1280×720 đúng scene.
3. Chỉ đo tối thiểu **cold import** và **warm launch** để chứng minh launcher không bắt người chơi chờ lại vô ích; không biến PD-00 thành dự án benchmark. FPS/performance chi tiết sang PD-07.
4. Play fallback rõ khi thiếu asset (`MISSING_ASSET_SOURCE` + path/hash), không tự vẽ asset JX fake. Report ngắn gồm exact SHA, Godot version, save root và asset blocker nếu có.

**Paths dự kiến:** `tools/qa/Run-TMB-Demo-Windows.ps1`, `Run-TMB-Demo-Windows.cmd`, launcher test smoke; KHÔNG sửa backend.  
**PASS:** người dùng nhấn 1 file, 1 cửa sổ chạy, không chạy FULL/CI, không làm thay đổi save/branch hiện có; lần hai không phải import tất cả lại nếu hash không đổi. Artifact: ZIP launcher+README không chứa source trả lại bừa bãi.

### PD-01 — DEMO MAX PROGRESSION + ONE-CLICK HUNT: Làm ngay sau PD-00

1. Thêm feature gate build/dev `TEST_DEMO_ENABLED`; chỉ bật khi profile sandbox và debug/test packaging, không có lệnh cheat cho production save.
2. Dựa trên `P37Factory`, `DiscipleGeneratorOpenPoints`, `RecruitmentSystem`, `DiscipleRealmProgressV2`, `DiscipleCombatLoadoutV2`: tạo `SandboxDemoFactory` (đề xuất) sinh **đúng 6 đệ tử được sở hữu** có valid canonical V2 progress `30.10 / 30.10`; cấp gear owned by Sect, HP ratio, elemental roots/lục duy theo schema hợp lệ; không đụng live `SimulationState` ngoài sandbox. Đồng thời seed/max **mọi hệ implemented cần để bấm thử ngay** trong sandbox: Warehouse resources TEST_ONLY, các production instance/building state đã có authority, recruitment/workforce/hunting flags hợp lệ.
3. Test feature harness cho 5 đội/30, 40 monsters được mở riêng bằng UI performance menu. `Demo skill catalogue` phải phân biệt `JX_USABLE / V2_BACKCOMPAT / VISUAL_ONLY / METADATA_ONLY / MISSING`. Một nút `TRANG BỊ BỘ KỸ NĂNG DEMO` set loadout hợp lệ theo slot hiện có; preset nhóm có tank + sword/ranged + poison + healer + AoE/support **bằng skill JX1 đã có consumer V2 thật**. Không ưu tiên nhét legacy P2 chỉ để tăng số lượng.
4. **Checkpoint 1 phải có JX combat nhìn thấy ngay:** reuse asset JX đã pin trong `godot/assets/combat_v4/*` + manifest hiện có, stage map source-backed, actor/quái/Boss/VFX thật đã xác minh. Nếu map binary gốc chưa giải xong, cho phép background source-backed provenance đúng làm bridge; tuyệt đối không quay lại nền procedural/Source A combat. Button `SĂN NGAY` chọn region/level hợp lệ, spawn/tick real combat, không fake battle.
5. Tránh thay đổi default project main scene có thể làm test P3 cũ fail: có màn chọn/overlay debug ở G1 thật hoặc test build startup param `--demo`, vẫn cho chơi normally.
6. Save sandbox riêng, quay lại game thử nhanh, reload skill, scene, HP, boss, equipment đúng; không trùng reward/active job và không thu hồi resource 2 lần; `Reset DEMO` deterministic seeded reproduction.

**Paths ownership:** files `godot/src/presentation/` demo UI, `godot/src/simulation/` test-only sandbox factory/test harness; `godot/src/simulation/combat/hunting_pve_run_v2.gd` chỉ nếu integration bug có chứng cứ và riêng allowlist. Không sửa `save_service.gd` trừ khi chỉ sandbox path namespace mà có focused save test, không migrate production.  
**Focused:** new `demo_max_factory_test.gd`, `demo_first_click_to_hunt_test.gd`, `demo_save_isolation_test.gd`, existing `c4_be01_max_hunting_stress_test.gd`, `c4_be01_real_hunting_ui_smoke_test.gd`, GP02B1 One Active Job.  
**PASS:** khởi tạo max thật 30.10/30.10; 6 actor chọn hợp lệ, `SĂN NGAY` đưa vào chiến đấu; các skill thực equip/triggger; exit/relaunch khôi phục; real save hashes untouched; 30v40 fixture giữ riêng, không ép auto-run.

### PD-02 — AUTO-SKILL COMBAT V2: Làm ngay sau DEMO

1. Giữ V2 numeric/determinism. Xây `AutoSkillPolicyV2` nhỏ có priority list, toggle skill, target selector và condition (`target_in_range`, `enemies_in_aoe`, `ally_hp_below`, `self_hp_below`, `buff_missing`, `cooldown_ready`, `target_alive`) bằng dữ liệu có nguồn; tuyệt đối không chạy học/passive/skill chưa unlock, không cast khi actor bị lock hoặc target invalid. Fallback đánh thường.
2. Mỗi disciple có 1 basic + max 4 active + max 6 combat-passive; catalogue includes `implemented`, `skill_family`, `source_jx_id`, `visual_id`, `effect_consumer`, `cast_event` và cooldown; **không đồng nhất JX1 `SkillId` với canonical `combat_skill_id`**.
3. Quy ước target determinism: ưu tiên healer chọn ally HP hợp lệ, damage chọn nearest/higher threat theo policy, các hòa điểm tie-break ổn định bằng ID; role auto-attack. Boss warning+dash/dodge SKILL chỉ nếu V2 có consumer true; AI không teleport khỏi AoE.
4. 5 existing JX pilot consumers là seed, **không phải đích cuối**. Ưu tiên mở rộng một bộ skill JX1 source-verified có vai trò khác nhau (direct, projectile, AoE, poison/DoT, heal/HoT, buff/defense/control nếu V2 có luật tương ứng), map functional intent sang consumer V2 và bind VFX thật. 7 P2 non-damage deferred chỉ xử lý khi cần backward compatibility hoặc khi trùng đúng behavior cần cho JX adapter; nếu không giữ `V2_BACKCOMPAT_PENDING`, không để debt cũ chiếm critical path. Reconcile legacy P2 vs JX content bằng adapter/version design, không phá snapshot.
5. Cấu hình skill được lưu trong **demo save trước** và nghiệm thu reload. Production save migration chỉ mở packet riêng khi schema đã khóa; không sửa universal serialization vì phục vụ demo.

**Owned paths (đề xuất):** `godot/src/simulation/combat/{combat_skill_system,disciple_combat_loadout_v2,jx_pilot_runtime_v1}.gd` và module auto-policy mới; frontend loadout panel, test focused. Không đổi `CombatStatsV2.resolve_direct_hit`/RNG trong PD-02.  
**PASS:** từng actor auto cast only equipped skill, đúng cooldown/cast lock/AI condition, healer không spam overheal, không cast unmatched source, repeat deterministic same-seed snapshot, no extra reward/HP duplicate.

### PD-03 — UNIFIED ASSET FORGE tối thiểu + JX1 content pack: song song READ-ONLY inventory, CODE sau PD-01

**Không xây Qt app mới / không chuyển toàn bộ client.** Mục tiêu một catalog search/preview/verify/publish với adapter được tái sử dụng.

1. **P0 inventory chỉ gồm:** Source A hiện dùng, owner Drive/JX1, JX1 data/source đã xác minh (`phucnb/JXLinux-8.1.11` cho Skills/Missles/Lua/PAK/map evidence), và các converter/atlas sẵn có trong repo. `tuanminhnc/jx1m` chỉ dùng khi cần PNG/TPSHEET compatible; `JXQY-all-in-one`, `jxqy2-assets`, JX2 và Phong Thần chuyển xuống **REFERENCE/TOOL FALLBACK**, không inventory sâu trước playable demo. Owner-provided JX1/Source A = APPROVED theo xác nhận; nguồn ngoài giữ provenance riêng.
2. Dùng immutable raw vault (đề xuất `E:\TongMonBaDao_AssetVault` khi có E: và dung lượng phù hợp), catalog JSON/SQLite `asset_id, SHA256, source_id, source_variant, license_provenance, version, format, animation_frames, dirs, fps, pivot, atlas, sprite_id, SkillId, MissleId, status, godot_path, current_use`. Reuse `tools/assets`, `tools/fe01b1` exporters, C4 atlases, Source A manifests. Không bổ sung runtime dynamic network.
3. Đọc `client/settings/skills.txt`, `client/settings/missles.txt`, các Lua liên quan; tạo bảng evidence `skill_id -> missile_id -> cast/precast/fly/hit/AoE -> animation -> atlas frame -> status -> mapped Combat V2 consumer`. Pin exact SHA; không đoán ID hay hiểu nhầm missles spelling.
4. **JX1 map thật:** tìm binary tile `*.map`, index blocks/terrain/objects/collision/npcs/spawn; `jx1m` chỉ để tận dụng PNG/TPSHEET nếu license/provenance đúng; `JXQY-all-in-one` dùng làm **reference cho adapter** MPC/ASF/MAP **khi format khớp**, không mang code GPL vào game mà không kiểm tra nghĩa vụ. Dùng `2.jpg` chỉ làm bản render tham khảo `FAN_DERIVATIVE`: background view thật, **không suy diễn blocked cells/spawns từ pixel**. Nếu chưa có binary collision, ghi rõ `COLLISION_MANUAL_PILOT` và tách khỏi proven original JX dataset.
5. Import 1 map (người chơi kéo được), 1 actor đệ tử, một quái thường, một elite, một boss và **ít nhất ba stage VFX có ID được chứng minh**; ví dụ hiện đã xác minh #158 impact, #63 impact, #93 precast, nhưng cần đủ cue cast/fly/hit của skill để gọi `SKILL_COMPLETE`. Thiếu clip thì cho skill tiếp tục dùng mechanics V2, hiển thị `ASSET_INCOMPLETE` trên debug, không thay ảnh giả.
6. Forge commands tối thiểu: `inventory`, `verify`, `search`, `preview`, `build`, `publish --approved-only`; tạo cache theo hash, manifest image rect/direction/anchor; subset export Godot, thumbnails local. Batch sample nhỏ, không chạy EXE lạ, không unpack full JX/Unity nặng khi máy owner BSOD.

**Owned paths:** `tools/asset_forge/*` (mới sau inventory), `godot/data/presentation/*manifest*.json`, `godot/assets/combat_v4/*` subset đã approved, `docs/asset_forge/*`; C4 atlas adapter **reuse**, không rewrite renderer.  
**PASS:** asset Godot import đúng scale/direction/anchor; SHA source==manifest; preview đúng frame, no missing texture, no false source; pack build deterministic; editor import idempotent; 1280x720 nhìn rõ.

### PD-04 — LARGE REALTIME ROAMING WORLD / CAMERA / ENCOUNTER lifecycle: sau PD-01, dựa trên PD-03 map

1. Làm **one-zone roaming vertical slice trước**, không thiết kế MMO streaming tổng quát ngay: `WorldCombatSessionV2`/adapter versioned dùng một map lớn source-backed, tọa độ world, walkable/collision tối thiểu có bằng chứng, camera tự do; actor/quái tiếp tục hoạt động khi camera đi chỗ khác. Sau khi slice chạy mới trừu tượng hóa `RoamingMapV2`/chunk streaming. Camera **không** ảnh hưởng RNG/damage. Không sửa số liệu damage, 30×10, AoE cap 3 khi chưa có phê duyệt.
2. Giữ `MapBattleV2` core stat/damage/rng/HP/skill event semantics; thiết kế nguồn event `BattleV2 action -> commit -> projectile position/release -> hit result -> visual event`, authoritative hit time rõ ràng, tránh 1 effect gây damage hai lần. Một monster khi chết có respawn theo authored region config/valid spawn điểm; không tự sinh tài nguyên hay loot giữa chừng. Không kết thúc săn bắt buộc ở 90s, `DỪNG SĂN / TRỞ VỀ` phát lệnh canonical để release reservation/settle legitimately.
3. Gỡ `ARENA.has_point` và `MAX_SECONDS` từ **world-only placement/lifetime**, không xóa các guard bảo vệ encounter test legacy; implement `map_bounds`, `walkable`, `spawn_points`, target chase/leash/path avoidance, clustering fallback có giới hạn; bám scene/screen projection chuẩn. Có thể giữ legacy `MapBattleV2` cho QA/backward saved runs và adapter world bản mới.
4. Camera đầy đủ: mouse L-drag hoặc middle-drag được quyết định bởi interactive hit rules (không nuốt click roster), zoom wheel +/- và touch pan/pinch, camera tự do sau khởi động; explicit click actor mới follow, drag giải follow; không bám nhân vật default; không cắt đen ngoài vùng map; minimap/map bounds và follow status đủ nhìn. Không đổi camera sect map 192x192 / 16x16 chunks trừ sửa chính xác bug.
5. Save/offline: version world snapshot, RNG continuation, loaded region/actor coords, loaded skill cooldowns/pending missiles/buffs, active participant reservations, rollback settlement receipt, exactly-once resources. Tests simulate close/reopen at cast-commit/projectile-in-flight/downed/death/reward, compare with uninterrupted deterministic run; offline catchup bounded và idempotent. No emergency direct write to `SaveService` without own migration gate.
6. Duy trì realtime `STEP=0.25` V2 (simulation) nếu phù hợp; renderer interpolate 60fps independent (không gắn damage vào `_process` FPS). Khi time progression cần cập nhật, phải viết packet versioning, không âm thầm thay loop.

**Paths:** adapter/module world mới, `MapBattleV2`, `HuntingPveRunV2`, `MapBattleSnapshotV2`, `HuntingMapV2`, `HuntingPlayPanelV2`, `MapBattleWorldLayerV2`, test scoped; shared `SimulationState`/SaveService modifications cần ownership riêng và migrations.  
**PASS:** đi qua ít nhất 3 khung màn hình cùng một zone, quái tiếp tục đánh/sinh lại theo dữ liệu vùng, không bị 90s forced stop, camera thật pan/follow, offscreen status consistent, battle save/resume deterministic, Warehouse đúng một receipt.

### PD-05 — COMBAT V2 QUALITY (CHỈ KHI GATE/OWNER ĐÃ CHO PHÉP)

1. Accuracy/Evasion design `docs/C4_ACCURACY_EVASION_MOVEMENT_SKILL_REACTION_DESIGN_2026-10-19.md`: chủ trương đã có nhưng **công thức cụ thể còn draft**. Không tự kích hoạt `accuracy/evasion` vào production trên cơ sở chỉ có plan. Đề xuất numeric/seed migration; owner phê duyệt trước khi đổi hit formula.
2. Tốc chạy derive thực sự áp vào roaming/battle; Boss telegraph đúng radius/release time. Skill né: chỉ nếu học/equip và cooldown/geometry hợp lệ; không auto teleport/100% dodge.
3. Monster AI/aggro/leash/group healer threat và champion/Boss skill là nội dung thật, phải có source/authoring phù hợp; không tự thay hệ crit, ngũ hành, lifesteal, max target count.
4. Màn debug tách `MISS` chính xác hit-roll, `DODGE` bởi skill, `OUT_OF_AOE` bởi vị trí; event receipts thực, không tự vẽ label sai.

**PASS:** numeric tests pinned, no RNG unexpected without versioning, snapshots/old saves migrated hoặc adapter backward; bất đồng balance → HOLD không CODE.

### PD-06 — G1 + C4 UX HUMAN-PLAYABLE

- G1 Source A map/actors/Mỏ–Rừng–Ruộng có worker đúng instance, ETA/%/predicted vs credited Warehouse, panel readable (chữ sẫm nền kem), HUD/tooltip không chen map, không lẫn selected với dispatched.
- Combat HUD 1280×720: left team roster 6 visible (filter 30), skill setup, minimap, HP/cooldown, boss telegraph, floating hit text đúng event, optional short logs, buttons đủ to cho ngón tay; camera không bị panel nuốt drag; ít VFX che nhân vật, cull distant effects; chỉ thấy screen thật là biết làm gì.
- Source A icon sheet thật mới thay `◇`; thiếu chứng cứ thì dùng nhãn debug neutral, không gọi original.
- Hướng dẫn 3 bước không cần đọc docs: `CHƠI DEMO MAX` → `PHÁI ĐỘI` → `QUAN SÁT COMBAT / ĐỔI SKILL`.
- Ảnh minh chứng từ Godot thực (1 production, 1 setup skill, 1 boss hit, 1 camera dragged); user nghiệm thu visual sau focused smoke. Không lấy mockup làm QA screenshot.

### PD-07 — ACCEPTANCE, PERFORMANCE, QA FOCUSED (không QA quan liêu)

**Tầng kiểm thử:** (1) static parse và compile touched neighbors, (2) focused per packet, (3) **1** play-through 1280×720 ở HEAD mới, (4) Android physical chỉ khi có build; không FULL/CI/merge tự động.

**Mandatory minimum (mỗi packet chỉ chạy test liên quan):**

| Nhóm         | Kiểm thử bắt buộc                                                              | Dấu hiệu PASS                                                          |
| ------------ | ------------------------------------------------------------------------------ | ---------------------------------------------------------------------- |
| Launch       | Godot4.7.2 version+real scene smoke, 2x warm launcher                          | 1 window, 1 state, no unrelated headless tests on Play                 |
| Demo         | factory/recruit 30.10, six valid combatants, real supported skill categories, 30v40 optional fixture | real V2 profile+skill eligibility, max 4 active, proper split          |
| AI           | ready skill condition/cooldown, target selection, poison/heal/buff consumers   | V2 events match actual visuals, no spam                                |
| Map & camera | multi-screen pan, bounds, zoom, follow selected-only, GUI drag                 | user drag works; no fake locked follow                                 |
| Effects      | VFX manifest path/hash/frames/anchor + 3 event playback stages                 | actual asset IDs, no placeholder mislabeled                            |
| Save         | close mid-cast/missile/restart, pending reward/claim ×2                        | same seed replay and no duplicate Warehouse                            |
| Injury/job   | GP02C1 T15, global One Active Job, saved PvE reservation                       | no work-and-hunt double booking; old T15 fixture retest                |
| UI           | G1 workforce tests, 1280×720 capture and owner review                          | progress credited only after scheduler, text readable                  |
| Stress       | 6v8 normal, 6vBoss, 30v40 once, map 192²/16 chunks                             | report FPS frame time memory and crash status; not invent thresholds   |
| Android      | package arm64+touch pan, FPS/battery startup physical when available           | `PENDING USER DEVICE` until evidence; no Windows claim as Android PASS |

**Output each checkpoint:** `run_sha`, `branch`, `godot_version`, exact paths tests ran, pass/fail/exceptions, screenshots/video real, save temp dir, assets SHA, blocked, next packet. A test code that exists is NOT PASS. Do not suppress failing tests/turn off economy. Respect existing separate 17-entry QA debt taxonomy.

### PD-08 — PACKAGING / RELEASE-TEST HANDOFF

- One README `CACH_CHOITHU.md`: Windows `Run-TMB-Demo-Windows.cmd`, optional `-Focused`, ResetDemo; the main game launch path and save path clearly identified. ZIP for owner with launcher and minimal validated asset pack or a verified download recipe, exact sha and checksums; avoid 50MB video attachments for every diff; screenshot PNGs/short H.264 optional.
- Export Android apk if SDK installed and resource pack approved; separate status `APK_BUILT`, `ANDROID_DEVICE_PENDING` until actual device QA. No build on unstable BSOD machine if not necessary; no full client repack.
- Runtime flags: release never turns sandbox cheats on by default; owner test package can default to DEMO MAX and allow `CHƠI TỪ ĐẦU`.
- Delivery priority: **first usable one-click desktop DEMO**, then more source assets/roaming, then Android. Do not postpone playable artifact behind perfect catalog or full 24-question review.

---

## 4. SƠ ĐỒ KIẾN TRÚC MỤC TIÊU

```
Owner clicks DEMO / NORMAL -> isolated DEMO state or real production state
                  |                               |
          Canonical DiscipleState           Canonical SimulationState
            30x10+30x10 / gear                scheduler/One Active Job
                  |                          Warehouse/Save/Offline
                  +------------+------------------+
                               |
                      V2 Combat Authority
             CombatStatsV2 / V2 damage / V2 Elements
             Skill ownership/mastery/slots + JX content adapter
             deterministic step, RNG, receipts
                               |
           AutoSkillPolicyV2 [AI SELECT/MOVE/CAST]
                               |
      WorldCombatSessionV2 [WORLD COORD/AGGRO/RESPAWN]
                               |
          authoritative events with stable event ID
    action start -> cast commit -> projectile -> hit -> effect
                               |
          JX1 Combat Presentation [NO NUMERIC RNG]
    real JX1 map / actor / monster / Boss / skill atlases / sound
    chunk cull / z-order / camera free/follow / interpolated frames
                               |
       One-click playable landscape 1280x720 HUD + mini-map

Side: Unified Forge immutable RAW -> verified converters -> catalog
-> approved manifests/atlas -> Godot packs (Source A sect; JX1 combat)
```

**Critical engineering note:** hiện `HuntingPveRunV2` lưu `MapBattleV2` encounter, nên thay bounded encounter bằng roaming **không phải chỉ xóa `MAX_SECONDS`**. Phải thiết kế lưu world/run state có version và receipt, nếu không reward duplication / participant lock/ RNG sẽ sai. Phần này ưu tiên sau PD-01 demo dùng V2 encounter hiện hành.

---

## 5. MAP 24 QUYẾT ĐỊNH D01–D24 VÀ QUYỀN CHỐT

| ID  | Kết luận trong bản này                                                            | Owner / gói                        |
| --- | --------------------------------------------------------------------------------- | ---------------------------------- |
| D01 | **LOCK: Combat V2 numeric; JX1 skill content/animation/VFX/map, NOT JX1 formula** | PD-02/03/04                        |
| D02 | **LOCK: continuous realtime roaming map; no 90s forced stop**                     | PD-04                              |
| D03 | **LOCK: auto AI casts only configured/legally learned skill**                     | PD-02                              |
| D04 | Original JX version, Skills/Missles/Lua ID mapping                                | TECH PD-03                         |
| D05 | Binary maps/tile/collision provenance                                             | TECH PD-03/04                      |
| D06 | Free camera/follow UX Windows+touch physical                                      | QA PD-07                           |
| D07 | **LOCK: V2 elemental, roots, counter; JX visual adapter**                         | PD-02                              |
| D08 | **P0 DELIVERY STRATEGY: 1 map+actor+normal+boss+3 source-verified FX cues first**, then scale                    | PD-03/04                           |
| D09 | Stable disciple ID->stats->sprite->save                                           | TECH PD-01/04                      |
| D10 | G1 readability/icon acceptance                                                    | OWNER UX after PD-06               |
| D11 | V2 skill 1+4+6 + mastery, 3 waves; implementation coverage unknown                | PD-02; OWNER only if changing lock |
| D12 | Injury **0/1/120 locked**, define world retreat/defeat without cheat              | PD-04                              |
| D13 | Production Lv100 ×10,000 pilot remains; re-balance later                          | BL-04                              |
| D14 | Hall/land/build/move/cost canonical transaction open                              | BL-01 OWNER later                  |
| D15 | Permanent Lục Duy growth sources not fully designed                               | BL-02 OWNER later                  |
| D16 | Sect-scale AI policies/1k–3k not closed                                           | BL-03 OWNER later                  |
| D17 | Source A original icons                                                           | TECH PD-03/06                      |
| D18 | Cast/fly/hit/AoE FX and mapping                                                   | TECH PD-03                         |
| D19 | Region grades/difficulty/respawn balance remain authoring                         | PD-04; OWNER later for grades      |
| D20 | cold/warm/FPS/Android/1k–3k                                                       | TECH QA PD-07                      |
| D21 | Endgame high-level PvE rivalry content                                            | BL-05 OWNER later                  |
| D22 | Save migration, RNG/offline/receipt replay                                        | TECH critical PD-04                |
| D23 | Audio/VFX settings presets, quality levels                                        | PD-06; OWNER after demo            |
| D24 | Inspiration-only systems from other games                                         | BL-06 OWNER later                  |

**Không hỏi owner lại** về source rights/engine/orientation/30×10/One Active Job/Warehouse/Injury/Source A sect/JX1 art/V2 combat/auto combat/free camera. Only escalate when a change would *alter existing mechanics or locked numeric balance* (Accuracy/Evasion formula, loot structure, skill slot count, permanent stat growth). Điều kiện thiếu file asset là technical blocker: report hash/path, không bắt owner trả lời 24 câu.

---

## 6. BACKLOG SAU KHI BẢN DEMO CHẠY ĐƯỢC (KHÔNG CHẶN PLAY-NOW)

**BL-01 Buildings/Land/Hall:** canonical Hall Lv1-100, land purchase/expand, build paid transaction, instance caps preview 30 Mine/30 Forest/40 Field; layout/move pathing + timed construction; migration/save and preview only until accepted.

**BL-02 Disciple depth:** real permanent six-foundation increase sources, potential cap rules, breakthrough 30x10 both, root/bloodline/physique/stat effect consumers, 3-wave learned/mastery skill ecosystem; do not fake real progress by DEMO max.

**BL-03 Large sect automation:** workforce policy, one job per disciple, auto farming/forest/mine, autonomous hunters party distribution, injury recovery, merchant/personal economy, 100/500/1k/3k capacity; render subset/chunk, simulation profiling.

**BL-04 Economy full loop:** inherited production plan Thanh Thiết 10000/60m, Linh Mộc 8000/60m, Linh Cốc 2500/60m, Thanh Linh Thảo 2000/90m, Tử Vân Thảo 1000/180m, Huyền Thiết 10/120m; Lv100 common yield ×10.000; faucets/sinks/crafting/consumption and market finite-budget, no uncontrolled boosts to save.

**BL-05 Endgame:** region progression, elite/Boss mechanics and viable scaling, gear forge/upgrade, rewards exactly once, difficulty and meaningful high-realm content, strategic sect management.

**BL-06 Quality:** Source A icon visuals, audio presets, accessibility, Android performance/release builds, design-only inspirations not yet approved, technical clean-up/DV2-03 PAUSED issues.

**Không coi backlog = blocker của playable demo**, nhưng ghi owner decision vs technical and truthful status.

---

## 7. RỦI RO & QUY TẮC CHỐNG LÀM LẠI

1. **Wrong baseline:** repo `main` cũ vẫn là 15/10; Codex checkout đúng **G1+C4 integrated + camera**. Pin HEAD sau fetch và report PR stack.
2. **Fake JX map:** composited 2.jpg của fan game là source-backed IMAGE, **không phải original MAP tiles**, không suy ra collision. Chỉ dùng tạm có nhãn; map gốc làm source-first sau.
3. **Pseudo-skill:** frame JX1 hiển thị không đủ để gọi V2 gameplay complete; phải bind consumer/real event, `skill_id+source_id+effect_stage`, show missing explicitly.
4. **Data poisoning:** cheat/max chỉ trong demo isolated. Không sửa `CombatStatsV2` production hoặc save chính để max profile; factory validate, audit log, reversible.
5. **Save migration:** roaming/world/pending missiles and log cap cannot simply delete 90s or reset active run; requires new version semantics. Rollback preserved old snapshots.
6. **Large scene performance:** 30v40 stress is optional; full 1k–3k render never default. frame time metrics rather than guess. Prefer caching atlas rects, pooling effect nodes, nearby active simulation, chunks.
7. **Build/QA overhead:** user wants results, not bureaucratic QA: 2–4 focused per changed packet, one real play; no FULL/CI/merge; release QA debts named separately.
8. **Rights:** owner-supplied JX1/Source A approved. External JX1M/JXQY2/Phong Thần separate provenance/redistribution; no raw third-party mass-upload by default.
9. **V2 hard rules:** maintain heal, poison, attack/cast/cooldown, element, crit, 30×10, Injury, one job, warehouse, non-deletion. Any mechanics extension needs focused owner decision, not implied from visual asset.
10. **Audio/animation pipeline:** imported directional sprites keep provenance and valid frame/anchor; two facing horizontal directions + mirroring may be pragmatic (per owner visual pilot); no claiming up/down unique frames if absent.

---

## 8. CHECKPOINT REPORT TEMPLATE FOR EVERY CODEX PACKET

```
PACKET: PD-XX
SOURCE_MAIN_SHA: ...
SOURCE_INTEGRATION_SHA: ...
BRANCH/HEAD: ...
OWNER AUTHORITY: Combat V2 formulas, JX1 presentation, auto-squad
SCOPE FILES: ...
IMPLEMENTED: exact list ...
NOT IMPLEMENTED: exact list ...
ASSETS: source/hash/license/version/ids ...
GODOT 4.7.2: [VERSION CONFIRMED / NOT AVAILABLE]
FOCUSED TESTS: <each command + SHA + PASS/FAIL/PENDING>
WINDOWS USER PLAY: [PASS / FAIL / PENDING OWNER]
ANDROID REAL DEVICE: [PASS / FAIL / PENDING USER]
DEMO MAX: [playable? route, scene, 6-member profile, 30.10 tracks, usable skills count]
SAVE ISOLATION: [evidence hashes/paths]
BUGS BLOCKING NEXT PLAY: ...
ROLLBACK: safe branch/base commit ...
NEXT SINGLE CODING PACKET: ...
```

---

## 9. PROMPT CHUẨN DUY NHẤT — TÁCH FILE ĐỂ KHÔNG NHẦM PHIÊN BẢN

**Gửi Codex nguyên văn file:** `docs/CODEX_PROMPT_PLAYABLE_DEMO_V3_2026-10-20.md`. File prompt V3 đã xử lý phạm vi CODE và phân kỳ bàn giao; **không sử dụng prompt V2 cũ**. Cả hai file phải cùng một HEAD GitHub. Nếu môi trường chat chỉ cho dán text, dán nội dung file prompt V3, không dán toàn bộ plan 400+ dòng vào đầu chat và hy vọng Codex tự suy ra điểm ưu tiên.

### Thứ tự ưu tiên kết quả thực tế

**Checkpoint 1 (M1):** One-click DEMO MAX toàn bộ hệ implemented + 6 V2 max hunters + demo workforce riêng + **JX source-backed combat nhìn thấy ngay** (map visual provenance, quái/Boss, VFX cue thật) + actual hunt  
**Checkpoint 2 (M2):** Auto-skill setup + continuous one-zone roaming không bị 90s forced stop + save/resume và camera  
**Checkpoint 3 (M3):** Mở rộng skill JX1 source-verified thành consumer V2 playable + Asset Forge subset catalog/pack  
**Checkpoint 4 (M4):** UX polished + stress + Android package evidence (không nhận là Android PASS nếu chưa có device)  
**Checkpoint 5:** Backlog advanced economy/land/Lục Duy/automation/late game.

*Đây là kế hoạch đề xuất, không phải bằng chứng runtime. Việc Codex nhận prompt là ủy quyền thực thi cho các packet đã xác định, không cho phép thay toán Combat V2 hoặc làm sai save.*