# TÔNG MÔN BÁ ĐẠO — KIỂM TOÁN THỰC TẾ JX SKILL / MISSILE / EFFECT / ANIMATION
**Ngày 24/10/2026 · DOCS ONLY · không code, không sửa PR29/Codex/UI/Source A, không merge.**
**Baseline:** TMB main 29b5fba448b0178cb520a4ada44b375b4b934e31; PR29 S1 SHA 9522812e91b7ca5bc0cc108eb92e000e930fe850 (draft, Godot official focused QA PENDING). Luật owner DEV: thay gameplay/code thì tạo world/đệ tử test mới; Save/load đúng **trong cùng bản** và loot exactly-once vẫn bắt buộc.

## 0. Khái niệm chứng cứ
- **E1 ĐÃ ĐỌC FILE**: nội dung cụ thể được mở và đối chiếu.
- **E2 DỮ LIỆU BIÊN TẬP/PHÁI SINH**: có metadata từ nguồn võ công nhưng đã chọn lọc/đổi công thức bởi game web; không được gọi là các hệ số nguyên bản JX.
- **E3 LIÊN KẾT CÓ DẤU VẾT**: đường dẫn/ID tồn tại nhưng chưa kiểm chứng bằng parser, mã thực thi hoặc trace client.
- **E0 CHƯA KIỂM CHỨNG**: không phỏng đoán số damage %, hit count, xác suất proc, cast frame và AI.
- **PHÂN BIỆT GAME**: repo Upwinded/jxqy2-assets là JXQY2 (Jianxia Qingyuan II) assets/INI, KHÔNG tự coi là hệ thống Võ Lâm Truyền Kỳ II Online. Source web Võ Lâm Idle / Giang Hồ Sinh Tồn trên Drive cũng KHÔNG phải client/server JX1 Online nguyên bản.

## 1. Thực tế những gì đã đọc

### 1.1 Google Drive của owner — Source VL
- Root folder: https://drive.google.com/drive/folders/19mdpwyTf2tzYblpfOg0CARi-JHdO70ZR
- Catalog thực: https://drive.google.com/file/d/1fXuZZAa4brAJ5OgTtDq2S6VMXPsLMk1D/view (Source VL/js/vltk-books.js, ~596 KB; sinh ra từ reference SkillId VLTK); E1 nội dung file, E2 với danh nghĩa raw JX1.
- Web rules: https://drive.google.com/file/d/1slFnLRn1F6KI2jW7rpUNuvflvI_Ljt6m/view (Source VL/js/data.js); E1.
- Engine web: https://drive.google.com/file/d/1OblApG13GpgVhGh1pkCvpjdliFVypSk4/view (Source VL/js/engine.js); E1.
- Skill preview: https://drive.google.com/file/d/1KFj_yY4N6kMODDZPQFxG4onRKxN-wxe5/view (Source VL/js/vo-hoc.js); E1.
- Skill visual map: https://drive.google.com/file/d/1TBOCRX4EYlmJWAGb9bKKHGCbvE3GlEsy/view (Source VL/js/skill-visuals.js); E1.
- Native VFX map: https://drive.google.com/file/d/1xAXh6daKUlMxQyGbwPM3eQXSaNwh6pIC/view (Source VL/js/vfx.js); E1.
- Projectile geometry: https://drive.google.com/file/d/1hqDReQ55-sdIOO_1ah8NbLjVEvR4vA7Z/view (Source VL/js/projectile-motion.js); E1, nhưng cách giải nghĩa enum ở đây chưa đối chiếu client JX nguyên bản.
- Báo cáo derivative QA: https://drive.google.com/file/d/1ACIt96SwzijJgSFvi-kmv90-AWtL21NH/view — chỉ là QA bản web, không phải TMB Godot hoặc JX client nguyên bản.
- Các thư mục https://drive.google.com/drive/folders/1bC-FWuEjH1i-vheffWurdeZKwEIjBhQn và https://drive.google.com/drive/folders/1OYhASFXTBNK4ky3ln2p_m7g7qGbyYDPm gồm ảnh UI và dự án Võ Lâm Idle; README xác nhận fan-made unofficial. Bản fan combat là tài liệu học cấu trúc, không dùng để xác nhận công thức chính thức.

### 1.2 GitHub source/asset JXQY2
- Repo: https://github.com/Upwinded/jxqy2-assets
- Có 50 file/entry trong thư mục ini/magic (bao gồm vssver.scc, không phải tất cả là skill), 54 entry trong mpc/magic, 131 entry âm thanh trong sound; mpc/character trả về 1000 entry đầu của GitHub API, chưa phải thống kê toàn bộ.
- Đã đọc trực tiếp các INI: player-magic-天意剑诀.ini, player-magic-烈火情天.ini và file phụ player-magic-烈火情天攻击.ini, player-magic-依风剑法.ini, player-magic-定身法.ini, player-magic-金刚不坏神功.ini, player-magic-漫天花雨手法.ini, player-magic-霹雳烈焰手法.ini, player-magic-寒霜掌.ini, player-magic-大梦心法.ini, magic-孔雀翎.ini.
- Đã đọc nhân vật: https://github.com/Upwinded/jxqy2-assets/blob/main/ini/npcres/npc-a01-南宫飞云.ini
- Repo https://github.com/Upwinded/JXQY-all-in-one có source engine/resource parser (src/Game, src/Resource), nhưng chưa xác định được mã combat authoritative đang tiêu thụ các INI; không khẳng định có skill engine nguyên bản chạy được.

### 1.3 KHÔNG có bằng chứng đầy đủ ở lượt này
- Không mở được original JX1 MMO raw bảng skills/missiles nguyên bản tương ứng 270 bản ghi (catalog JS là kết quả biên tập).
- Chưa tìm thấy original client/server bảng skill JX2 **Online** hay **Kiếm Thế Online** trong các thư mục đã đọc.
- Trước đó một kiểm toán JX web MOD từng đếm 21.511 file client và 315 file server ở máy local; bộ đó KHÔNG được mount/đọc lại ở lượt này. Không được dùng số đếm trước để nhận là đã mở các bảng của nó.
- Không chạy bất kỳ binary/client/server gốc, không giải mã tất cả MPC/ASF/SRP, chưa có chính xác damage, cast frame, hitbox/LOS/proc RNG hoặc snapshot parity.

## 2. Kết quả thống kê thật từ vltk-books.js
Đã phân tích mảng JSON VLTK_CATALOG:
| Thuộc tính catalog | Giá trị đã xác minh |
|---|---:|
| Tổng bản ghi | **270** |
| Mã vltk.skillId duy nhất | **270** |
| Type active | **203** |
| Type noi (nội/hỗ trợ) | **64** |
| Type than (thân pháp) | **3** |
| Có vltk.missileId nguyên | **185** |
| MissileId khác nhau | **153** |
| Có vltk.chain từ 2 SkillId trở lên | **31** |
| Có attrs không rỗng | **268** |
| Đánh dấu enabled / playable trong catalogue lớn | **121** |
| Qua bộ lọc BOOKS chạy sinh tồn | **75** |
| Chuỗi dài nhất trong catalog đã biên tập | **2 SkillId** |

**Cảnh báo:** 270 được catalog hóa ≠ 270 kỹ năng chiến đấu gốc đã xác minh đầy đủ; 121 enabled ≠ 75 chiêu nằm trong bản chơi sinh tồn. "chain" là liên kết ID của bảng do code web chuẩn bị, không tự chứng minh liên chiêu tự động trong bản client nguyên bản.

### Một số ID cụ thể đã đọc
| Catalog ID | Tên | SkillId | MissileId | Chain | Một số attrs ghi trong nguồn dẫn xuất |
|---|---|---:|---:|---|---|
| hoasonkiem | Kiếm Tông Tổng Quyết | 1349 | null | 1349 | addphysicsdamage_p, attackspeed_v, lifemax_yan_p |
| lahan | Thiếu Lâm quyền pháp | 8 | null | 8 | attackratingenhance_p, deadlystrikeenhance_p |
| toanchan | Nhân Kiếm Hợp Nhất | 368 | 175 | 368 | physicsenhance_p, stealmana_p, skill_attackradius, skill_collideevent |
| batquai | Bá Vương Tạm Kim | 1060 | 350 | 1060→1088 | ignoredefense_p, skill_misslenum_v, seriesdamage_p |
| duonggia | Truy Tinh Trục Nguyệt | 323 | 139 | 323→327 | addskilldamage1/2, deadlystrike_p |
| mieugia | Phá Thiên Trảm | 322 | 138 | 322→326 | addskilldamage1/2/3, seriesdamage_p |
| huyetdao | Huyết Đao Độc Sát | 65 | 31 | 65 | poisondamage_v, physicsenhance_p |

Cột SkillId/MissileId là E2 có provenance nguồn VLTK, **chưa cross-check hàng raw table**; không coi số trong bảng là toàn bộ chứng cứ bản gốc JX.

### Cái gì là công thức WEB, không phải nguyên bản JX1?
- data.js ghi rõ "Every number here is a first balancing hypothesis"; skill trường dmg, cast, speed, count, caps là bản web cân bằng/diễn giải, chưa phải bảng damage gốc.
- data.js lọc BOOKS theo tier/reqLevel và **viết lại cooldown** theo min/max và tỉ lệ 0,55; do vậy sourceCooldown và cooldown chơi sinh tồn không thể gộp làm một con số nguyên bản.
- perVictim() tính per-target cap trong bản web, hữu ích để học cách hạn chế multi-hit; không được coi là luật Kiếm Thế hay JX1.
- projectile-motion.js có MisslesForm: 0 ngang, 1 tuần tự, 2 quạt, 3 vòng tròn, 6 điểm mục tiêu, 7 quanh caster; MslsGenerate 0/1 cùng lúc, 2 tuần tự, 3 ngẫu nhiên, 4 jitter, 5 giữa ra ngoài, gap theo 18 ticks/s. Tất cả là **diễn giải được comment là source-inspired**, chưa xác minh frame-perfect với client nguyên bản.
- vo-hoc.js dẫn b.id→skillVisual(id).sourceData.fullLevel.nodes→node.missiles→hiệu ứng/âm thanh/ảnh; vfx.js giữ source cast/precast/impact atlas. Đây là đường data-flow được xác minh **trong web fan game**; manifest ảnh đầy đủ và tất cả sprite frames chưa được giải mã tại đây.

## 3. GitHub JXQY2: đúng trường dữ liệu nguồn, tránh đoán ratio

| INI skill đã đọc | Key init ghi nhận | Ví dụ level1 / level10 | Những gì CHƯA chứng minh |
|---|---|---|---|
| Thiên Ý Kiếm Quyết (天意剑诀) | movekind=8, speed=10, waitframe=4, lifeframe=40, flyingimage=magic-南宫飞云攻击.mpc, vanishimage=explod-大型红色爆炸a.mpc | effect=562 / 3000, mana32 / 302, levelupexp có từng level | effect không được tự coi 562% ATK hoặc một hit |
| Liệt Hỏa Tình Thiên (烈火情天) | attackfile trỏ player-magic-烈火情天攻击.ini; hình .asf, movekind thay đổi qua cấp | effect=270 / 3500, mana10 /500 | subfile không tự chứng minh số hit/mục tiêu |
| Ỷ Phong Kiếm Pháp (依风剑法) | movekind=4, region=3, flyingimage kiếm nhỏ, nổ tím trắng | effect=480 / 5000 | region=3 không xác minh AoE radius |
| Bách Bộ Định Thân (定身法) | specialkind=1, visual/sound riêng | effect=10 / 100, nhưng **level9 effect=190** | không kết luận tỉ lệ khống chế; dữ liệu level9 không đơn điệu |
| Kim Cương Bất Hoại (金刚不坏神功) | specialkind=3, lifeframe=300, flyingimage quả cầu | effect=436 / 10130, mana200 / 50; chuỗi không đều | không thể tự suy ra lượng shield/DR |
| Mạn Thiên Hoa Vũ (漫天花雨手法) | specialkind=2, đạn/vụ nổ riêng | effect=870 /1800 | hình nhiều phi tiêu ≠ nhiều hit xác thực |
| Phích Lịch Liệt Diễm (霹雳烈焰手法) | flyingimage, vanishimage vụ nổ | effect=1070 /1920 | không khẳng định đốt/stun |
| Đại Mộng Tâm Pháp (大梦心法) | movekind=10, lifeframe=400, flyingimage khí tường | effect=700 /1500 | chưa có cap mục tiêu hay điều kiện AoE |
| Hàn Sương Chưởng (寒霜掌) | movekind=2, flyingimage băng, sound riêng | effect=562 /1000 | tên Hàn không tự đồng nghĩa freeze |

**Ví dụ file thực:**
- https://github.com/Upwinded/jxqy2-assets/blob/main/ini/magic/player-magic-天意剑诀.ini
- https://github.com/Upwinded/jxqy2-assets/blob/main/ini/magic/player-magic-烈火情天.ini
- https://github.com/Upwinded/jxqy2-assets/blob/main/ini/magic/player-magic-烈火情天攻击.ini
- https://github.com/Upwinded/jxqy2-assets/blob/main/ini/magic/player-magic-定身法.ini
- https://github.com/Upwinded/jxqy2-assets/blob/main/ini/magic/player-magic-金刚不坏神功.ini
- https://github.com/Upwinded/jxqy2-assets/blob/main/ini/magic/player-magic-依风剑法.ini

### Sơ đồ key trong INI (không phải toàn bộ original engine)
- [init]: name, intro, movekind, specialkind, speed, region, alphablend, image/icon, waitframe/lifeframe, flyingimage/flyingsound, vanishimage/vanishsound, actionfile/attackfile.
- [level1]…[level10]: effect, manacost, optional thewcost, levelupexp, sometimes movekind/speed changes per level.
- Đây **là 10 cấp của INI JXQY2**, TMB đã khóa **5 bậc lĩnh ngộ**; không sao chép XP curve hoặc effect numbers qua TMB.
- Các key effect, speed, movekind, specialkind không có phần giải nghĩa authoritative đủ để map trực tiếp sang damage, chance, trajectory hoặc hitbox. **E0**.

## 4. Nối animation trực tiếp — đã có link nào?
1. Thiên Ý Kiếm Quyết file [init] có image=天意剑诀.mpc và icon=天意剑诀s.mpc. Cả hai basename đó hiện diện trong directory mpc/magic đã liệt kê. Phần flyingimage=magic-南宫飞云攻击.mpc, vanishimage=explod-大型红色爆炸a.mpc và 2 WAV là **ref trong INI**; chưa kiểm toàn bộ byte referenced assets.
2. Nam Cung Phi Vân: ini/npcres/npc-a01-南宫飞云.ini ghi [stand] ...-st.mpc, [walk] ...-wlk.mpc, [attack] ...-at.mpc, [magic] ...-sat.mpc, [run] ...-run.mpc, [hurt] ...-bat.mpc, [death] ...-die.mpc và các *.shd. Có **phân biệt rõ cast animation với ordinary attack** trong file actor config.
3. Liệt Hỏa Tình Thiên có attackfile liên kết tới **subfile tồn tại**, ví dụ skill chính vs định nghĩa đòn con: cấu trúc tách file đã kiểm chứng. Nhưng chưa xác minh trigger/subcast thật với executable, nên không khẳng định "gọi thêm một hit".
4. Directory mpc/magic có 54 entry bao gồm icons và skill art, không đồng nghĩa 54 chiêu; sound có 131 entry nhưng chưa xác minh audio runtime; mpc/character trả 1000 entry đầu, không gọi là toàn kho.

**Kết nối dữ liệu đưa về TMB sau này:** actor_action (idle/walk/attack/magic/hit/die) + skill id + cast_start/release + missile definition/source VFX + impact definition + audio cue + collision receipt. Giữ Source A chibi art là presentation canon, không thay actor JX gốc vào UI. Cần source asset manifest riêng với direction/pivot/frame khi người chủ duyệt asset packet. Hiện **KHÔNG CODE**, không import JX assets.

## 5. Kiểm toán prereq/status/proc: có gì và thiếu gì?

| Trường cần tìm | Đã có bằng chứng | Thiếu để xác nhận bản gốc |
|---|---|---|
| Skill ID & tên | 270 references trong VLTK_CATALOG (E2); JXQY2 tên/file INI (E1) | raw VLTK1 Skills table, JX2 Online/Kiếm Thế skill IDs |
| Missile ID | 185 references, 153 unique trong VLTK_CATALOG | raw missile definition rows, exact source bytes/units/collision |
| Damage | browser dmg + caps (E1 DERIVATIVE); JXQY2 effect theo 10 level (E1) | authoritative ATK% formula, defense/multipliers, crit, resist |
| Learn prerequisites | browser reqLevel/tier/weapon/pending state; JXQY2 levelup EXP | original class/quest/skill prerequisite tables & eligibility algorithm |
| Buff/debuff/status | attrs như poisondamage_v, skill_eventskilllevel, ignoredefense_p; JXQY2 specialkind | status duration, hit rate/resist, stack, ICD, source attribution |
| Proc/skill child | 31 chain links, fullLevel nodes/missiles, one attackfile child | actual event trigger condition, recursion limit, hit count per target |
| Animation/sound | JXQY2 ini/actor filenames; fan visual graph | frame sampling, pivots/dirs, verified missing refs and real timeline |
| Complete JX2 Online/Kiếm Thế | chưa có | cần original source/verified public tables |
| Runtime behavior | không chạy | actual emulator/client trace (chỉ nếu cấp phép sau) |

**E1 anomaly guard:** Bách Bộ Định Thân có level9 effect=190 rồi level10 effect=100. Không tự sửa typo, không đoán tác dụng; phải coi đó là giá trị nguồn trước khi reverse-engineer enum/effect mapping.

## 6. So sánh với Combat V3 — nguồn thật của TMB

**TMB CombatSkillSystem.SKILLS PR29** mới có 9 khai báo: Kiếm [Thanh Phong Trảm 1.35, Truy Phong Bộ 0.75 dash, Ngự Kiếm Thuật 1.70], Thể [Chấn Sơn Quyền 1.45 weaken, Kim Cương Hộ Thể guard, Bất Động Thân guard], Pháp [Hỏa Cầu 1.15+burn, Hàn Sương Ấn .90+weaken, Liệt Diễm 1.45×1.35 khi mục tiêu đang Burn]. Bảy effect consumer ở PR29 (sáu? hai damage gốc+5 effect mới) chưa official QA; Dash/FireCombo còn deferred.

| Thành phần | Source JX đã thấy | TMB runtime / V2 plan | Kiến nghị |
|---|---|---|---|
| Catalog | trăm bản ghi và SkillId/MissileId/reference child | 9 prototype, catalog V2 rộng hơn ở dạng spec | registry data-driven skill/family/content IDs |
| Upgrade | 10 level giá/XP JXQY2 | TMB V2 **5 bậc** Sơ Học→Viên Mãn + Nhân/Tiên/Thần family | giữ 5 bậc và authored milestone effect, không copy JX10 |
| Prereq | browser level/weapon/tier | TMB P2 còn cultivation_stage_index cũ | V2 true TuVi/Body30×10 + Sect manual/Dao/tech requirement |
| Hình học | form quạt/vòng/line, đa đạn/đòn | MapBattleV2 default AoE 3 generic, chưa typed multi projectile | per-skill shape, origin, max_targets, child source IDs |
| Damage/hit | browser per-victim budget; ini effect unknown | CombatStatsV2 direct authorized hit | per hit index, no damage triple-apply, don't blindly copy JX percentages |
| Status | poison/ignore defense/event attrs | S1 Burn/Weaken/Guard, source-owned only initial | typed status stack/ICD/tier/resist and deterministic snapshot |
| Animation | separated cast/magic/attack/flight/impact | Source A assets/UI separate from gameplay | skillVisual manifest routed by resolved event; no renderer rewrite |
| Mật tịch/tech | 10-level per-skill in JXQY2; reference inner skills | TMB 1 Chủ Tu +2 Phụ Tu; 1 basic+4 active+6 combat passives | manuals strengthen explicit skill families, never autogrant all moves |
| Mana | JXQY2 manacost/thewcost | TMB V2 **không có universal Mana** | do not import mana engine |
| Save | derivative browser has own checkpoint | TMB CARE exact once + DEV reset builds | within-build cast/proc/status/reward save exact-once |

## 7. Kết luận thiết kế có căn cứ
- TMB **nên học cấu trúc**: 1) định nghĩa kỹ năng tách data và visuals, 2) skill con và nhiều projectile có nguồn và thứ tự rõ, 3) trạng thái/bị động/khống chế có điều kiện, 4) đường học công pháp/mật tịch và yêu cầu riêng, 5) level skills khác với người/cảnh giới.
- TMB **không nên sao nguyên**: 10 level và mana/thewcost JXQY2, class lvl90/120/150, damage browser fan game, kỹ năng game Kiếm Thế Online không có raw table, hay áp JX actor/renderer lên Source A.
- **Nguồn audit hiện tại:** thành công mức catalogue/metadata/asset linkage một phần, **không phải đã giải mã toàn bộ combat nguyên bản JX1/JX2 Online/Kiếm Thế**.

## 8. Bước có thể làm tiếp (không tự CODE)

### G1 — FULL ORIGINAL JX SOURCE INVENTORY (read-only, nếu owner chọn)
Khi Codex trên PC truy cập được source JX client21.511/server315 thật, cho phép tìm (chỉ là *candidate filenames*) Skills.txt, Skill.txt, Missiles.txt, magic tables, animation INI, client Lua/engine parser, PAK metadata, vũ khí/môn phái prerequisite. Ghi path, SHA-256, encoding, row counts, source IDs; map skill→child→missile→impact→sound→actor; báo missing file và xác nhận resolver enum/effect units từ source thực. Không chạy binary/server, không public nguyên kho source copyrighted, không ghi đè Source A. Nếu bản JX2 Online/Kiếm Thế không có trên máy, đánh UNKNOWN chứ không giả.

### G2 — TMB DEFINITION DESIGN
Chọn 12 representative **mechanisms** thay vì cố định 12 skills: single, multi-hit, projectile fan, piercing line, area circle, short DoT, weaken/armor break, shield, heal/cleanse, dash, actual combo, bounded on-hit proc. Design typed packet+max_targets+cast_id/hit_index+source status/ICD and V2 4-slot AI, then author 3 distinct Path starter builds. Chưa có CODE permission.

### G3 — COMBAT S2 INTEGRATION
Chỉ sau Codex S1 focused QA và owner cấp packet: implement dash/fire_combo + data-driven frame of per-skill action/child hit with MapBattle owner, no new combat engine, no UI/PR29 overlap. Focused tests and save/loot exactly once; no fake runtime pass.

**Kết luận cuối:** E1 = JXQY2 INI/actor assets + web derivative catalog and engine; E2 = source-derived 270 VLTK SkillId refs; E0 = full raw JX1/JX2 Online/Kiếm Thế resolver/formula & original runtime. Không sửa Gameplay hay bất kỳ PR nào.
