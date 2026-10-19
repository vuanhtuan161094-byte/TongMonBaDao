# TÔNG MÔN BÁ ĐẠO — COMBAT V4 × JX1: DEEP REVIEW V2 / BẢN THIẾT KẾ GAMEPLAY HIỆU CHỈNH

**Ngày rà soát:** 2026-10-19. **Trạng thái:** DESIGN REVIEW V2 — CHƯA KHÓA cân bằng; KHÔNG phải phép sửa gameplay/code.
**Phạm vi nguồn:** 
- [DRIVE-N: Võ Lâm Idle](https://drive.google.com/drive/folders/1OYhASFXTBNK4ky3ln2p_m7g7qGbyYDPm): `data.js`, `stats.js`, `combat.js`, `fx.js`, `world.js`, `survival.js`, `siege.js`, `builds.js`, `README.md`, các thư mục `fx/`, `img/a/`, `img/m/`, `snd/`, `doll/`. Fan-made/browser, KHÔNG PHẢI client JX1 chính thức.
- [DRIVE-O: Giang Hồ Chi Chiến Community Offline](https://drive.google.com/drive/folders/19mdpwyTf2tzYblpfOg0CARi-JHdO70ZR): `data/vltk/faction-coverage.json`, `data/vltk-fx.json` dạng gzip+base64, `js/engine.js`, `js/native-presentation.js`, `data/vltk/native/assets/`, `data/vltk/char/`, `data/vltk/fx/`, `data/vltk/sfx/`. Community web source, KHÔNG PHẢI toàn bộ client JX1 chính thức.
- **Game authorities:** `docs/COMBAT_SKILLS_V2_SPEC.md`, `docs/COMBAT_STATS_V2_SPEC.md`, `docs/TECHNIQUE_V2_SPEC.md`, `docs/CULTIVATION_PATH_V2_SPEC.md`, `docs/DISCIPLE_MASTER_SCHEMA.md`, `docs/REALM_LADDER_V2_SPEC.md`, `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md`, `docs/DV2_02_GROUP_MAP_COMBAT_CONTRACT.md`; live `combat_stats_v2.gd`, `map_battle_v2.gd`, `disciple_combat_loadout_v2.gd`, `hunting_pve_run_v2.gd`, `team_state.gd`.
- **Liên quan:** `COMBAT_V4_JX1_10_SCHOOLS_ACTIVE_PASSIVE_SUPPORT_DEEP_DESIGN_2026-10-19.md` là **bản nháp nghiên cứu V1**. ĐỌC TÀI LIỆU NÀY TRƯỚC để không triển khai các suy diễn sai và tham số chưa duyệt của bản đó.

## 0. KẾT LUẬN KIỂM TOÁN — PHÂN BIỆT ĐÚNG/SAI/CHƯA BIẾT

**Giữ:** 30×10 Tu Vi và 30×10 Luyện Thể độc lập; CombatStats V2 16 chỉ số; 1 basic + 4 active + 6 combat-trigger/party passive cuối Nhân Giới; passive thuần stat cá nhân không chiếm 6 slot; một Chủ Đạo Kiếm/Thể/Pháp mềm; 1 Chủ Tu+2 Phụ Tu; 6 đệ tử/đội, tối đa 30 đệ tử và 40 quái/cụm; chiến đấu 0.25s tick, AoE mặc định tối đa ba mục tiêu, 90s timeout; không Mana chung, không class XP, không reroll đời người; sinh hạ Bị Hạ/Injury đúng V2; một active job; save/loot exactly once; đệ tử truyền kỳ skill độc quyền owner-bound option A.

**Cần sửa trước code:** (1) phân loại active/passive bị suy luận từ tên; (2) nhầm tác dụng gốc với cách chuyển thể; (3) cast time 0.35/0.55s không chia hết cho 0.25s cần công thức định lượng tick; (4) sáu slot combat passive phải có ICD/chống đệ quy, còn công pháp và bị động stat chỉ cộng khi thực sự active/hợp lệ; (5) Boss dễ bị dồn sáu chiêu đầu trận, thiếu telegraph/interrupt/threat/AI; (6) tăng trưởng cảnh giới không cần xếp thêm MMO cấp chiêu và phái nhân ATK; (7) source web có chuỗi missile/asset chưa đồng nghĩa hiệu ứng thật đã chạy trên Godot; (8) ma trận phái/vũ khí và công pháp phải có luật gỡ/đổi hợp lý.

**Điều chưa khóa:** ratio damage, cast, cooldown, kích thước AoE, mật độ skill học, điểm mở slot theo cảnh giới, thời gian đào tạo, hiệu lực aura, Boss resilience, chi phí truyền thừa, trang bị/vũ khí tags và nghiệm thu Android. Các số pilot của V1 không là authority. Không sửa main, PR20, Economy, Save, C4-VP01 hay đưa asset vào repo ở bước này.

## 1. CHỨNG CỨ THỰC TẾ TỪ HAI DRIVE — VÀ GIỚI HẠN

| Bộ nguồn | Dữ liệu có bằng chứng | Trạng thái / giới hạn |
|---|---|---|
| DRIVE-N `data.js` | 240 skill definitions, 11 faction entries (Hoa Sơn = 0 skill trong danh sách faction), 2.151 NPC records, 992 map records; `attr` gồm skill, missile, elemental, curse, sustain, buff, item | 240 gồm kỹ năng kỹ thuật/quái và category khác; KHÔNG đồng nghĩa 240 chiêu học được cho 10 phái |
| DRIVE-O `faction-coverage.json` | 260 roots/13 faction labels, 118 web-playable, 63 passive-excluded, 79 pending (55 support, 3 hybrid, 21 attack); sourceIncomplete 54 chồng lấn | `playable` chỉ thuộc JS web bản O; không thể áp vào Godot |
| Giao hai danh mục | 170 SkillId trùng, union 330; còn lại 70 chỉ N, 90 chỉ O; có sai khác alias/tên tiếng Việt | ID bằng nhau KHÔNG chứng minh số damage, cooldown, layout VFX giống nhau |
| DRIVE-N `fx.js` | 121 missile templates, 11 standalone templates, 176 skill FX mapping; tập **202 đường dẫn ảnh `fx/` khác nhau** | Drive `fx/` có đúng 202 WebP tương ứng **202/202 đường dẫn khớp tên** ở lần kiểm tra 19/10; chưa thay thế QA texture/rectangle |
| DRIVE-N `img/a/` | **585 WebP**, ghép đúng **117 nhóm × năm animation `at/die/hurt/run/st`** theo tên | Trước mắt đủ manifest tên để chọn quái/NPC, chưa chứng thực frame rect/anchor/animation visual |
| DRIVE-N `snd/` | **232 MP3** trong thư mục | Số file thật, khác số declaration. Cần đối chiếu từng sound event và giấy phép |
| DRIVE-N `img/m/` | 97 PNG actor/monster images | Không mặc định đủ mọi monster NPC trong 2.151 records |
| DRIVE-N `doll/man,lady` | 1.000 entry đầu đã hiện diện mỗi nhánh ở ngưỡng list scan | Danh sách **chưa hoàn tất, chưa kết luận** tổng file hoặc khả năng compose rig |
| DRIVE-O `data/vltk-fx.json` | 270 skill profile, 176 nativeSprites record, 12 effect templates, 2 projectile styles, 11 effect styles, 496 sound references | Dữ liệu packed JSON/metadata; không đồng nghĩa 270 kỹ năng đang chạy hay 496 audio files |
| DRIVE-O `native/assets/` | Lần quét mới: **176 WebP + 74 WAV** cùng thư mục | Đã tăng đáng kể so với báo cáo cũ; cần match hash/assetId → sprite sheet/file, không mặc định mỗi WAV là một skill |
| DRIVE-O `char/`, `fx/`, `sfx/` | lần quét 19/10: **132 WebP**, **49 WebP**, **31 MP3** tương ứng | Chỉ danh sách file hiện có; `char` có nhiều clip/cá thể, FX không phủ tất cả skill declarations |
| DRIVE-O `player/` | nhiều WebP, tối thiểu 400 file đọc ở lần quét có giới hạn | Tổng và completeness chưa xác minh; không coi 400 là tổng |
| Source A | Batch-01 đã báo 10 rig/31 clips/1.016 frames/28 atlases; raw Spine + processed WebP cần giữ hai bản | Source A không nằm trong hai Drive JX người dùng vừa gửi; đối chiếu rig phải lấy đúng kho Source A riêng |

**Thủ tục nguồn:** lập `variant_id` riêng (JX-IDLE-20261018 / JX-COMMUNITY-20261018 / SOURCE-A-RAW / SOURCE-A-BAKED); lưu SHA-256, alias, nguồn gốc thực và ngày đọc. Khi có bản JX tải thêm phải tạo variant mới, không ghi đè `SKILL_ID` trần. Nếu source gốc và source cộng đồng có cơ chế khác nhau, giữ cả hai kết quả cùng provenance; không tự hòa giải thành "JX chuẩn".

**Quyền:** README Võ Lâm Idle hạn chế sử dụng/phân phối thương mại và thừa nhận ảnh/nhạc thuộc chủ sở hữu. Quyền người dùng cho nghiên cứu và sử dụng trong dự án của họ không tự xác lập quyền phân phối IP bên thứ ba. Giữ `rights_status` + `usage_scope`, chặn build phát hành nếu chưa rõ.

## 2. DANH SÁCH SỬA SAI LỆCH V1 — BẢN CHẤT SKILL NGUỒN

| Source skill | Điều source thật cho biết | **Không được tự suy** | Quyết định gameplay V2 |
|---|---|---|---|
| Thiếu Lâm #318 Đạt Ma Độ Giang | N: *Công kích ngoại công*, form12, childN2 | "chắc chắn là lướt/dash 4.5" | **Giữ là đòn tấn công**; mobility là nhánh thiết kế thêm, cần dữ liệu path và phép QA |
| Đường Môn #54 Mạn Thiên Hoa Vũ | N: *Công kích nội công*, form6, childN1 | "nội tại là phi tiêu ngoại công, ba đạn" | Chuyển thể AoE/ám khí được nhưng cần rõ loại damage và số hit tác giả hóa |
| Đường Môn #58 Thiên La Địa Võng | N: *Công kích ngoại công*, có `poisondamage_v`, childN1 | "bẫy/zone chắc chắn có trong nguồn" | Gia phả gốc là đòn có độc, **bẫy là kỹ năng mới của game**, không là source fact |
| Đường Môn #249 Tiểu Lý Phi Đao | N: *Công kích nội công* dù tên phi đao | "mọi phi đao đều vật lý ngoại công" | giữ evidence; lựa chọn physical/internal hybrid cần rule authored rõ |
| Ngũ Độc #73 Vạn Độc Thực Tâm | N: *chủ động hỗ trợ công kích*, `poisontimereduce_p` | "giảm poison resistance flat mặc định" | Thiết kế hiệu ứng lên thời gian trúng độc/hiệu suất độc; giảm kháng độc là modifier khác và phải duyệt |
| Ngũ Độc #384 Bách Độc Xuyên Tâm | N: attack nội công, `poisondamage_v` | "kích nổ/tiêu hao stack từ nguồn" | Detonate là **mechanic mới tùy chọn** phải có true poison stack consumer |
| Ngũ Độc #69 Vô Hình Độc | N: vòng tròn hỗ trợ công kích, có poison attr | "bị động aura tự gây DoT liên tục" | Nếu chuyển thành aura combat passive phải thực sự chiếm slot, có radius/duration/ICD |
| Ngũ Độc #75 Ngũ Độc Kỳ Kinh | N: style3 nhưng prop text trộn thuật ngữ chủ động; O: passive-excluded | "phân loại chắc chắn chỉ nhờ style/prop" | **Giữ trạng thái classification conflict**; nội dung stat-style ưu tiên cho prototype, không auto passive trigger |
| Nga Mi #91 Phật Quang Phổ Chiếu | N: *Công kích nội công*, `colddamage_v`; O: attack/playable | "tên Phật Quang là heal" | Skill tấn công băng, không biến thành trị liệu |
| Nga Mi #93 Từ Hàng Phổ Độ | N: `lifereplenish_v`, self-oriented; O: support pending | "hồi một lần 1.35×ATK lên đồng đội như nguồn" | **HoT/regen là đặc tính nguồn**; nếu chuyển thành party heal phải author mục tiêu/tick/giới hạn |
| Nga Mi #282 Thanh Âm Phạn Xướng | N: `fasthitrecover_v`, anti-critical, giảm thời gian trạng thái xấu | "tự xóa ngay một debuff" | **Buff kháng/giảm thời gian bất lợi**, Cleanse lập thành family khác, chưa có chứng cứ |
| Thúy Yên #99 Phong Hoa Tuyết Nguyệt | N: *Công kích nội công* | "chắc chắn là song đao vật lý cận chiến" | Bảo toàn skill element/source; close-combat nếu authored riêng, không là raw data |
| Thúy Yên #100 Hộ Thể Hàn Băng | N: style2 *chủ động hỗ trợ*, phản damage | "combat passive phản kích mặc định" | **Active self buff** chiếm 1 active; muốn passive cần variant khác, không song song miễn phí |
| Thúy Yên #109 Tuyết Ảnh | N: style2 *chủ động tăng tốc*, có `attackspeed_v`, `castspeed_v`, `fastwalkrun_p` | "bị động party aura tự bật" | **Active haste**, party targeting/radius mới cần tác giả hóa |
| Thúy Yên #336 Băng Tung Vô Ảnh | N: attack ngoại công, childN5 | "dash xuyên map" | Action mobility chỉ khi validate đường đi, nếu không giữ là đòn tấn công |
| Cái Bang #129 Hóa Hiểm Vi Di | N: style3 với reflect, defense; O: passive-excluded | "mọi bị động phản đòn đều có auto trigger" | Stat/reflect source phân lớp; nếu reflect on-hit dùng slot trigger + ICD |
| Thiên Nhẫn #150 Thiên Ma Giải Thể | N: style2 active self-support nhiều kênh tấn công và tốc | "combat passive low HP đã tồn tại" | **Active self-boost**, rủi ro HP thành cost chỉ khi authors phê duyệt riêng |
| Thiên Nhẫn #136 Hỏa Liên Phần Hoa | N: style0 support attack-related reflect attr | "phản kích bị động" | Hỗ trợ chủ động có điều kiện, không thể tự trở thành passive |
| Võ Đang #157 Tọa Vọng Vô Ngã | N: self-support `manashield_p` | "dùng Mana shield y như JX" | **CONSUMER PENDING**: V2 no universal mana; có thể author shield HP/guard với cơ chế khác, gọi tên chuyển thể |
| Võ Đang #159 Thất Tinh Trận | N: vòng hỗ trợ công kích, accuracy/defense | "mọi member luôn có buff" | Có thời hạn, vùng, đúng party, strongest-only; chiếm active |
| Côn Lôn #173 Thiên Thanh Địa Trọc | N: style2 self-support resistances; O: passive-excluded | "chắc chắn bị động theo một version" | **version conflict**; muốn game chọn active thì khai báo rõ lý do, không đếm passive miễn phí |
| Côn Lôn #392 Thúc Phược Chú | N: hỗ trợ chiến đấu với `rangedamagereturn_p` âm; O pending | "khóa chân/Root vì tên Thúc Phược" | Chưa đủ bằng chứng cho Root, **đưa khỏi pilot control** trừ khi author và effect engine riêng |

**Bảo toàn tên và alias:** #45 Tích Lịch/Phích Lịch Đơn, #93 Từ Hàng Phổ D/Phổ Độ, #124 Đả Cẩu Bổng/Đả Cẩu Bổng Pháp phải có alias có provenance. Không đổi tên gốc tùy tiện để tránh không tìm ra asset. `JFX.f` chỉ là ánh xạ hiển thị, `JX.skills` là định nghĩa nguồn, O coverage là trạng thái code web bên kia; không được dùng một bảng thay cho hai bảng còn lại.

## 3. CƠ CHẾ CHIẾN ĐẤU GIỮ LUẬT V2, HỌC BẢN SẮC JX

### 3.1 Tách bốn tầng combat
1. **Character layer**: Tu Vi/Luyện Thể, Tiềm Lực, Lục Duy, Linh Căn và Dị Căn, Huyết Mạch, Thể Chất, Traits, Mệnh Cách, 1 Chủ Tu+2 Phụ Tu công pháp, 1 Chủ Đạo, vũ khí/trang bị hợp lệ. Mỗi nguồn modifier mang `source_id`, không cộng trùng một hiệu ứng.
2. **Learned/owned skill layer**: tông môn có truyền thừa, đệ tử thực học, mastery 5 bậc, gia phả Nhân/Tiên/Thần; phái JX chọn dòng chương trình học, không tự cấp bất cứ chiêu nào; võ học độc quyền truyền kỳ thuộc đúng cá nhân.
3. **Battle authority**: MapBattleV2/GameRng, 0.25s, trạng thái HP, action commit, enemy target, AoE <=3 mặc định, damage/DoT/crit/DR/Heal/Guard/Threat qua source real, same seed same results viewed/offscreen.
4. **Presentation layer**: Source A diễn viên, JX hiệu ứng/quái/binh khí và âm thanh chỉ đọc event authority; không tự gọi damage/AI/RNG hay phát 16 lần damage do animation nhiều frame.

### 3.2 Combat skill interface, versioned (DESIGN)
```yaml
game_skill_id: authored/immutable
family_id: stable across Nhan/Tien/Than successors
skill_kind: BASIC | ACTIVE_DAMAGE | ACTIVE_CONTROL | ACTIVE_SUPPORT | STATIC_SELF | TRIGGERED_PASSIVE | PARTY_PASSIVE
source_refs: [variant_id, external_skill_id, skill_name, evidence_attrs, artifact_hash, usage_rights]
generation: NHAN | TIEN | THAN
basis: TU_VI | LUYEN_THE | HYBRID
required: {realm_floor, body_realm_floor, branch_tags, masteries, technique, weapon_tag, sect_transmission}
ownership: {sect_known, disciple_learned, mastery_xp, exclusive_owner_id_or_none}
equip: {basic:0_or_1, active_slot:1_to_4, combat_passive_slot:1_to_6, effect_conflict_family}
targeting: {mode, distance, angle, area, max_targets, stable_tie_break, ally_party_only}
action: {cast_ticks, release_tick, cooldown_ticks, initial_delay_ticks, interruptible, movement_during_cast}
packets: [{packet_index, hit_when, ratio, damage_element, crit_eligible, lifesteal_eligible, target_cap}]
status: [{family, application_base_chance, effect_tier, snapshot, expiry_tick, tick_period, refresh_stack_policy, shared_target_cap, dispel_tag}]
ai: {slot_priority, minimum_effective_heal, target_state_required, risk_window, emergency_threshold}
visual_bind: {variant_id, action_anim, cast_fx, missile_fx, hit_fx, audio, 2d_anchor, frame_rect, draw_order, fallback}
qa: {facts_verified, simulator_seed_pass, visual_import_pass, mobile_pass, rights_clearance}
```
- Source JX `attr` dạng `physicsdamage_v`, `lightingdamage_v`, `lifereplenish_v`, `manashield_p`, `attackspeed_v`, `addskilldamage1` phải map theo semantic và tiêu chí kênh V2, không tạo 305 combat stats mới.
- Trường `style`, `prop` và `childN` của JX-N mang giá trị tham khảo, không định nghĩa game-side target/state một cách tự động.
- **Weapon identity**: kiếm, đao, côn, thương, chùy, quyền, ám khí và pháp khí là `weapon_tags`; Weapon V2 authority còn phải xác định trang bị/eligibility. Không gộp đao/côn vào Kiếm Tu chỉ vì phương án lịch sử C.
- **Skill family/branch**: mỗi dòng võ học có thể có active tấn công chính, utility, special/ultimate, 1 basic và passive hỗ trợ. Không yêu cầu một đệ tử học 100% catalogue; không tự cộng chỉ số môn phái.

### 3.3 Từ khóa hiệu ứng source → consumer của chúng ta

| JX source attr/behavior | Mapping dự kiến V2 | Mức sẵn sàng |
|---|---|---|
| `physicsdamage_v`, `magicdamage_v`, `firedamage_v`, `lightingdamage_v` | Direct damage packet thuộc một element và scale từ ATK/basis | Cần authored ratio; direct hit đã có |
| `poisondamage_v` | DoT có tick, snapshot, poison resistance, cap per target | Poison status consumer CHƯA có |
| `lifereplenish_v` | HoT/regen tick hữu hạn, chỉ effective heal | Healer hiện tại chỉ có generic instant pilot |
| `addskilldamage1..9` | Có thể hình thành dependency giữa hai SkillFamilyIds, buff có điều kiện | **Không** biến thành +ATK toàn cục |
| `addphysicsdamage_p`, `attackspeed_v`, `fastwalkrun_p` | Registered filtered stat source, đúng loại vũ khí/kỹ năng | Chỉ một số V2 channel implemented |
| `manashield_p`, `stealmana_p` | Not applicable trực tiếp vì không Mana chung | PENDING; có thể tác giả hóa shield/steal HP nhưng phải tách source fact |
| `stun_p`, `freezetimereduce_p`, `stuntimereduce_p` | Status, EffectHit/Resistance, shortened duration + Boss refractory | Cần control engine thật |
| `meleedamagereturn_p`, `rangedamagereturn_p` | Damage reflect event, recursion disabled & ICD | Chưa có fully authored proc consumers |
| `allres_p`, `poisonres_p`, `fireres_p` | Resistances theo element, registered contributors | Đúng V2 resistance map, kèm tier/cap |
| `skill_collideevent`, `skill_vanishedevent`, `skill_showevent` | Launch/hit/cancel/vanish presentation evidence | Event graph map mới, không giả skill hits |

## 4. PHÂN LOẠI BỊ ĐỘNG — KHÔNG BẮT NGƯỜI CHƠI TRẢ PHÍ HAI LẦN

**Loại A — Passive tự thân tĩnh:** học Dịch Cân Kinh, Thế Vân Tung hoặc thuật binh khí; chỉ đóng góp vào chỉ số cá nhân khi học, đủ điều kiện và đúng vũ khí/công pháp active. Không chiếm ô trong 6 combat passives. Nếu có 10 passive học được không có nghĩa +10 cùng một bộ family; unique/conflict/strongest-only và kênh hợp lệ có hiệu lực trước phép cộng.

**Loại B — Passive triggered combat:** phản đòn sau hit, Hộ Chủ, Hộ Thể khi dưới ngưỡng HP, gia tăng damage vào target đã phá giáp; **chiếm một trong 6 slot combat passive**, có event source, trigger eligibility, ICD, action budget, recursion=forbidden, cap per cast/encounter.

**Loại C — Party aura dạng combat passive:** chỉ có hiệu lực khi passive đang trang bị, đúng party ID, caster còn hợp lệ/còn sống, đồng đội trong phạm vi, thời hạn và source family. Khi có nhiều aura giống nhau, dùng strongest-only hoặc policy explicitly authored; tuyệt đối không 5 đội ×6 aura vô hạn.

**Loại D — Chủ động hỗ trợ có thời gian hiệu lực:** Kim Chung Tráo #42, La Hán Trận #16, Thất Tinh Trận #159, Từ Hàng #93, Tuyết Ảnh #109 thuộc danh sách cần nhìn đúng dữ liệu. **Chiếm 1 active slot** nếu được author active; buff sau cast không biến nó thành passive tự do. Không chuyển miễn phí chỉ vì thiếu slot.

**Loại E — Công Pháp passive:** chỉ 1 Chủ Tu+2 Phụ Tu active, passive công pháp thật mới cộng. Giữ knowledge/mastery của công pháp không active nhưng không giữ modifier không hợp lệ. Tránh duplicate qua technique/skill/Trait/Bloodline/Mệnh Cách cùng effect family. Không đánh đồng công pháp với kỹ năng.

**Loại F — Exclusive legendary:** tuyệt kỹ chủ động owner-bound, chiếm 1 active; nếu có triggered option được tác giả hóa riêng thì cần 1 combat passive, không tăng slot và không thể truyền cho người khác. Thử duplicate identity qua tuyển/sao lưu/hoán chuyển/đổi phái.

**Passive trigger budget rule (candidate):** mặc định một effect-key/cast, internal cooldown tính tick V2, per-target global stack cap; không tính damage 0, overheal hay phản đòn vòng lặp làm mastery. Một proc do mutation/reflect không tự kích lại chính nó; gameplay pressure giữ được mà không tạo trận 30 người × vô hạn.

## 5. MÔN PHÁI — 10 BỘ CHIẾN ĐẤU CHƠI ĐƯỢC, KHÔNG DỰA VÀO HỆ SỐ PHÁI

| Phái | Source offensive chính đã chứng thực | Source hỗ trợ/bị động quan trọng | Gameplay V2 cần đạt | Rủi ro/ghi chú |
|---|---|---|---|---|
| **Thiếu Lâm** | #10 Kim Cang Phục Ma; #11 Hoành Tảo Lục Hợp; #20 Sư Tử Hống; #318 Đạt Ma Độ Giang | #21 Dịch Cân Kinh = static resist; #15 Bất Động Minh Vương = active self; #16 La Hán Trận = support | Đỡ đòn, tấn công cận, stagger hữu hạn, bảo vệ đồng minh thực | #318 không tự cho dash; phải có Threat real trước khi gọi là tank |
| **Thiên Vương** | #40 Đoạn Hồn Thích; #41 Huyết Chiến Bát Phương; #35 Dương Quan Tam Điệp | #42 Kim Chung Tráo active self; #23/#26 weapon passive; #36 Chiến Ý static HP | Công vật lý bền, quét nhóm, phòng ngự hữu hạn | Không auto-hút máu và không auto-aggro nếu source V2 không cấp |
| **Đường Môn** | #50 Truy Tâm Tiễn; #54 Mạn Thiên Hoa Vũ; #58 Thiên La Địa Võng; #249 Tiểu Lý Phi Đao | #43 ám khí; #48 Tâm Nhãn static | Đánh xa, projectile, độc, chọn mục tiêu yếu/bị đánh dấu | #54/#249 có gốc nội công; bẫy là gia phả khác |
| **Ngũ Độc** | #63 Độc Sa Chưởng; #68 U Minh Khô Lâu; #384 Bách Độc Xuyên Tâm | #73 Vạn Độc Thực Tâm = hỗ trợ thời gian độc; #66 Dược Kinh static; #69 Vô Hình Độc = zone support pending | Poison DoT mạnh dần theo thời gian, suy yếu target, kháng độc | Detonate/stack là authored; thiếu poison status engine thì không chạy |
| **Nga Mi** | #80 Phiêu Tuyết Xuyên Vân; #91 Phật Quang Phổ Chiếu (attack) | #93 Từ Hàng = regen; #282 Thanh Âm = resistance/recovery; #86 Lưu Thủy haste; #92 Phật Tâm HP | Healer có hiệu lực, hỗ trợ sinh tồn và băng damage | Không lấy attack #91 thành heal; không tự hồi sinh |
| **Thúy Yên** | #99 Phong Hoa Tuyết Nguyệt (source nội công); #102 Phong Quyển Tàn Tuyết; #111 Bích Hải Triều Sinh; #336 Băng Tung Vô Ảnh | #100 Hộ Thể Hàn Băng = active reflect; #109 Tuyết Ảnh = active speed; #114 Băng Cốt static | Băng công nhịp nhanh, slow hợp lệ, vị trí linh hoạt | Không biến hai active hỗ trợ thành 2 passive free; không fake dash |
| **Cái Bang** | #125 Bổng Đả Ác Cẩu; #128 Kháng Long Hữu Hối; #357 Phi Long Tại Thiên; #359 Thiên Hạ Vô Cẩu | #115 Cái Bang Bổng Pháp static; #274 Giáng Long Chưởng static; #129 Hóa Hiểm Vi Di defense/reflect | Cận/viễn Hỏa, bổng quần công, áp lực Boss | #128 có childN8 nhưng hit packets phải riêng; nguồn ngoại/nội đan xen |
| **Thiên Nhẫn** | #135 Tàn Dương Như Huyết; #141 Liệt Hỏa Tình Thiên; #148 Ma Diệm Thất Sát; #362 Thiên Ngoại Lưu Tinh | #131/#132 weapon passive; #150 Thiên Ma Giải Thể active self, #136 Hỏa Liên support | Burst Hỏa có lúc mạnh/yếu, áp lực lên target Burn | Không auto dùng HP làm giá/cấp bất tử; cần theo dõi cast windows |
| **Võ Đang** | #158 Kiếm Phi Kinh Thiên; #165 Vô Ngã Vô Kiếm; #368 Nhân Kiếm Hợp Nhất | #159 Thất Tinh Trận active support, #160 Thế Vân Tung static, #166 Thái Cực Thần Công static, #157 Tọa Vọng nguồn mana | Kiếm khí nhiều nhịp, hỗ trợ nhóm, cơ động học được | Bảo toàn Lôi element trên từng skill; #157 không copy Mana shield |
| **Côn Lôn** | #169 Hô Phong Pháp; #179 Cuồng Lôi Chấn Địa; #182 Ngũ Lôi Chánh Pháp; #176 Cuồng Phong Sậu Điện | #173 Thiên Thanh Địa Trọc bản N active resist/bản O passive-excluded; #275 static; #392 support with reflect-style attr | Lôi thuật, cast interrupt hợp lệ, phòng thủ có điều kiện | #392 chưa được chứng minh là Root; không phát miễn phí Dị Linh Căn |

**3 phái khác của DRIVE-O (Hoa Sơn/Vũ Hồn/Tiêu Dao)**: vào *research/backlog*. O báo nguồn web playable lần lượt 6/20, 0/18, 3/17. DRIVE-N có entry Hoa Sơn nhưng không có skill roster gắn trong faction array; không cấp quyền kết luận đã đủ skill Hoa Sơn trong phiên bản N. Không copy class unlock levels của JX vào 30 cảnh giới.

### 5.1 Four-skill pilot build examples (NOT default all-learn)
- **Võ Đang - Kiếm trận/Ngự Kiếm:** Active 1 #158 (lôi kiếm projectile), Active2 #165 (multi-target bounded), Active3 #159 (party buff), Active4 #368 (single boss finisher); passive stat #160/#166 chỉ khi learned and applicable; các triggered passive V2 phải học/chiếm slot.
- **Ngũ Độc - Poison attrition:** Active1 #63 (poison), Active2 #68 (poison hit), Active3 #73 (thời gian độc/curse), Active4 #384 (poison skill, authored payoff OPTIONAL); #69 có thể **thay** một active bằng một vòng hỗ trợ, không có slot thứ năm.
- **Nga Mi - Y Đạo:** Active1 #93 (HoT hữu hạn vào đồng minh sau khi tác giả hóa target), Active2 #282 (giảm hiệu lực các trạng thái xấu; KHÔNG instant cleanse), Active3 #80 (băng đơn), Active4 #91 (băng AoE) hoặc #86 (buff tốc đội); muốn cứu nguy/revive phải có riêng theo V2.
- **Thiếu Lâm - Frontline:** Active1 #10 (cận địch), Active2 #11 (quét), Active3 #15 (thủ thế), Active4 #20 (stagger/interrupt) hoặc #16 (aura); muốn giữ quái bằng Threat, cần hệ thống threat cùng enemy AI không phải biểu tượng khiên.
- Hai đệ tử cùng học một phái nhưng khác basis, Linh Căn, công pháp, vũ khí, mastery, tình huống đội sẽ có build khác nhau. **Phái là curriculum, không là permanent class stat**. Đổi phái lưu tri thức/mastery; chỉ bộ hiệu ứng tương thích mới active.

## 6. ĐỘ SÂU GAMEPLAY THEO CẢNH GIỚI VÀ KHẢ NĂNG HỌC

### 6.1 Lõi sức mạnh đã có (KHÔNG sửa)
```text
G(r,f)=1.65^(r-1) × 1.03^(f-1), with independent Tu Vi, Luyện Thể
Core HP=(100×Gr + 90×Gb)×(1+0.0005×Tiềm Lực)
Core ATK=(20×Gr +  3×Gb)×(1+0.0005×Tiềm Lực)
Core DEF=(12×Gr +  7×Gb)×(1+0.0005×Tiềm Lực)
Final sources use registered flat / additive-percent / pp channels in CombatStatsV2.
```
Full same-r same-f, Tiềm Lực=100, no extras:

| Position | HP | ATK | DEF | Source label |
|---|---:|---:|---:|---|
| r1 f1 | 200 | 24 | 20 | derived, rounded |
| r5 f1 | 1,479 | 179 | 148 | derived |
| r10 f1 | 18,084 | 2,189 | 1,808 | derived |
| r10 f10 | 23,596 | 2,856 | 2,360 | derived |
| r11 f1 | 29,839 | 3,612 | 2,984 | derived |
| r20 f1 | 2,704,817 | 327,425 | 270,482 | derived |
| r20 f10 | 3,529,172 | 427,216 | 352,917 | derived |
| r30 f1 | 404,554,729 | 48,972,415 | 40,455,473 | derived |
| r30 f10 | 527,852,162 | 63,897,893 | 52,785,216 | derived |

Each track alone: +3% per floor, +65% same-floor major realm, both tracking independent. r10 f10→r11 f1 factor `1.65/1.03^9=1.26459` when both tracks switch. **Large absolute stats do not imply automatic imbalance**: if HP, ATK, DEF, monsters and skill ratio scale proportionally, encounter **relative** TTK can remain similar. Need verify `2ATK/(2ATK+DEF)`, and actual monster tier curves, not panic-nerf the locked realm G. Example mirror targets with base HP190,ATK23,DEF19 (P0, no gear): normal 1×ATK direct hits roughly `190/(23×46/(46+19))≈11.67` hits (no crit/heal/DR); common factor G cancels.

### 6.2 Cảnh giới 1–30 không đồng nghĩa mở 30 skill
- **Nhân r1–10:** mở học các cơ chế đơn/đa mục tiêu, phòng thủ, poison, heal, control, mobility, hỗ trợ đội theo authored school, basis + prerequisite. Proposal active slots mở r2,r3,r7,r9 **vẫn đang chờ duyệt**, không tự động thêm skill. Combat-passive slots trải dần, mốc chưa chốt.
- **Tiên r11–20:** successor Nhân→Tiên trong cùng `SkillFamilyId`; có interaction mới (đánh dấu, tăng hiệu quả chữa/heal thực, poison stack finite, zone/tier), thay thế bản cũ trong cùng gia phả không cùng lúc hai lần.
- **Thần r21–30:** successor Tiên→Thần có cơ chế Pháp Tắc hữu hạn (encounter-limited, priority, guaranteed-but-resistible tier), không bỏ Boss immunities, không vô địch/teleport vô hạn.
- **Mastery của mỗi skill:** Sơ Học → Nhập Môn → Tiểu Thành → Đại Thành → Viên Mãn; XP nhận từ combat hợp lệ, học tập, Diễn Võ có giới hạn; Thông Tuệ giúp tốc học nhưng không thay điều kiện cảnh giới. Nâng skill từ thế hệ này sang thế hệ khác có học/ truyền thừa, thời gian, vật tư và mastery thật.
- **Skill grade** Phàm/Huyền/Địa/Thiên/Tiên/Thần khác thế hệ Nhân/Tiên/Thần. Một kỹ năng hỗ trợ bậc thấp vẫn hữu ích ở cảnh giới cao; upgrade không chỉ đơn thuần +damage mãi.
- **Miễn phạt nuôi lại đệ tử cao cấp:** nếu tông môn đã giữ cả gia phả cũ và mới, có thể dạy successor theo luồng truyền thừa rút gọn, nhưng không tặng miễn phí mastery cá nhân, để người chơi không phải farm lại bí kíp phế bỏ từng đời.

### 6.3 Vòng học kỹ năng phải vui và dễ hiểu
1. Tuyển đệ tử với tố chất thật, chọn Chủ Đạo tự do sau Định Đạo và nhánh khi phù hợp.
2. Người chơi xem catalog theo **Môn phái → loại vũ khí → basis Tu Vi/Luyện Thể/Hybrid → pháp môn/skill**. Kỹ năng khóa có lý do cụ thể (tầng/đạo/weapon/manual/mastery/công pháp).
3. Tông môn có truyền thừa → cá nhân học tại Tàng Kinh Các hoặc nhận tự lĩnh ngộ → luyện mastery bằng job hợp lệ. Không trừ bí kíp mỗi lần dạy nếu chính transmission luật Công Pháp/Kỹ Năng cho phép chia sẻ; tài nguyên tiêu hao phải là phí tu luyện xác định, không sinh cơ chế tiền mới.
4. Đệ tử đang học/diễn võ và đồng thời đang làm Mỏ hoặc săn không thể chiếm hai Active Job nếu đó là một job scheduler; phân loại tác vụ phụ không chiếm job chỉ sau khi luật one-job cho phép.
5. Có **preset build** lưu lựa chọn slot *không sao chép quyền sở hữu kỹ năng*. Đổi preset ngoài trận, validate learned/weapon/công pháp/One Active Job; không được đổi trong trận để reset cooldown.
6. Đổi phái/Chủ Đạo giữ history/mastery/skills đã học; incompatible skill bị disable rõ lý do, không xóa; active skills cần check requirements ngay trước trận.
7. Tiến hóa hiển thị cây gia phả: Nhân → Tiên → Thần, vì sao chưa học được và nguồn vật phẩm cần; không bán skill gacha thành loại bắt buộc để đánh quái cùng cấp.

## 7. THIẾT KẾ SÁT THƯƠNG / THỜI GIAN / AI CHUẨN V2

### 7.1 Hit/DoT/Heal/cooldown
- Damage source đúng `CombatStatsV2.resolve_direct_hit`: base ATK × packet ratio × `2ATK/(2ATK+D_eff)` × crit eligible × Ngũ Hành favorable ×1.25 / unfavorable ×0.85 × elemental resistance × DR, theo **đúng code order**. Không tạo physical attack/magic attack headline stats riêng. Không thêm "Accuracy/Dodge" phổ thông từ JX nguồn.
- Crit base V2 5%, crit damage ×1.50, crit resistance tác động pp. DoT/reflect/mutation proc/fixed/heal/shield không crit theo mặc định. Lifesteal tính từ **sát thương thực trừ HP**, capped theo HP thiếu của attacker và tỉ lệ giảm hút máu target, chỉ settle một lần.
- DoT/HoT tick có source provenance, duration, snapshot, expires, cancel rules; poison/burn không vào kỹ năng chỉ như mỹ thuật. Raw JX `lifereplenish_v` mô tả hồi theo nửa giây, nhưng **không copy 0.5s ở hệ 0.25s** nếu dẫn đến gấp đôi hiệu lực; tác giả chọn tick đúng và kiểm nguyên tổng hồi trên duration.
- AoE geometry: single/arc/line/ground circle/chain/fly/zone; default 3 mục tiêu, deterministic tie by stable ID, tránh 1 cast multi missile áp ba packet trên một mục tiêu nếu không khai báo rõ.
- Control Boss: normal stun/root ngắn, elite có kháng; Boss có refractory/tier; Freeze mutation lên Boss thành Hàn Trệ theo luật khóa. Shield/Guard/reflect policy riêng; không crowd-control vô hạn.
- Ngũ Hành phản ứng: Kim khắc Mộc, Mộc khắc Thổ, Thổ khắc Thủy, Thủy khắc Hỏa, Hỏa khắc Kim; Tương Sinh personal opt-in theo skill, không cộng 1.25× lần nữa vì tên trường phái JX; Dị Linh Căn Lôi/Phong/Băng/Dương/U Minh chỉ skill sở hữu thật.
- No mandatory global mana. Nếu muốn bản sắc mana-shield JX, thiết kế shield với nguồn/cost riêng đã duyệt, **không tự đặt thanh nội lực cho toàn bộ 30×6 combat system**.

### 7.2 Cast time 0.25s tick mismatch — sửa V1 trước khi implement
- `MapBattleV2.STEP_SECONDS=0.25`; các số V1 như 0.35s, 0.55s, 0.60s chỉ **số thiết kế sơ bộ**, KHÔNG trở thành event release chính xác trong engine tick rời rạc.
- Chọn một trong hai policy trước code: **A (pilot đơn giản):** lượng tử thời gian gameplay lên tick lớn hơn gần nhất (`ceil(cast_time/0.25)`); ví dụ 0.35→0.50s, 0.55→0.75s, 0.60→0.75s. **B (nâng cao):** giữ fractional deterministic accumulator, event timestamp số nguyên sub-tick với ordering cố định, không dựa vào fps. Khuyến nghị A cho pilot mobile.
- Tooltip UI hiển thị **thời gian gameplay thực** sau tốc thi pháp/hồi chiêu, không hiển thị raw 0.35s rồi thực chạy 0.50s. Cooldown Recovery dùng `base_cd/(1+rate)`; Cast Speed dùng `base_cast/(1+rate)` theo spec. Khóa min interval để không phát nổ event ở r30.
- Một active cast tại một thời điểm; event queue chuẩn: `cast_started → cast_committed → projectile_spawned → hit_resolved → status_applied → impact_visual`. Hit authority không đợi animation WebP kết thúc. Cancel trước commit và retarget sau projectile phát phải có chính sách rõ.

### 7.3 Thứ tự AI đơn giản, chiến thuật thật
1. Nếu caster Bị Hạ/interrupt/injury-locked → không cast.
2. Check emergency support đúng slot priority đã khóa `active1→4` **theo cấu hình người chơi**, không xây AI black-box global utility; có thể đề xuất preset sắp xếp slot.
3. Một active hợp lệ khi đúng vị trí/weapon/mastery/threshold, cast/CD ready, target alive in range, không chồng action, không overheal. Heal mặc định khi HP% có tổn thất ý nghĩa; Cleanse chỉ nếu debuff có thể giải; Execute chỉ dưới ngưỡng thật; poison payoff chỉ nếu stack thật; dash chỉ nếu đường an toàn.
4. Nếu không có active hợp lệ thì dùng Basic. AI vị trí giữ cận/trung/viễn/hậu; tập trung mục tiêu theo preset đội (gần nhất, Boss, ít HP, target đã có mark), tie bằng actor ID ổn định.
5. Nên có **anti-idle rule**: nếu Boss ngoài tầm/range vì địa hình không đi được, sau timeout tái định vị hợp lệ hoặc report pathing error; không cho kỹ năng vô hình xuyên vật cản.
6. Boss telegraph chuẩn: dấu cảnh báo thật trên map, sau một window theo tick thì damage ở tọa độ resolved; có cơ hội né bằng movement AI đã xác thực, không thể auto trúng vì UI frame delay.
7. Khóa skill rotation snapshots khi bắt đầu encounter; không đổi giữa chừng, tránh exploit hồi chiêu/swap preset khi đánh offline.

## 8. TỔ ĐỘI — CẦN TÁCH VAI TRÒ, ĐỘI HÌNH VÀ GROUP AI

### 8.1 Người chơi điều khiển chiến lược, đệ tử tự thi triển
- `TeamState` hiện chỉ có `id/display_name/leader_id/member_ids`. 6 slot battle/formation là **thiết kế dữ liệu mới sau này**, không giả rằng đang chạy.
- Lập preset **2 tiền / 2 trung / 2 hậu** (chỉ là góc nhìn UI, không hard-class), build gợi ý: chống chịu, cận DPS, ranged DPS, khống chế/debuff, Y Đạo, flex support. Người chơi có thể đặt 4 DPS hoặc không healer; tradeoff sống sót phải có.
- Up to 5 teams/30 disciples one encounter. Buff same-party trừ khi authored encounter-wide; debuff/mark trên Boss dùng **shared cap across all parties**. Team leader có quyền ra lệnh mục tiêu và hiển thị nhưng KHÔNG tự cộng HP/ATK/luck.
- Threat đơn giản có decay, recent damage/heal/support, explicit taunt, Boss immunity softening, proximity; tank chỉ bảo vệ được nếu thực địch đổi target. Không tự cấp taunt theo tên Thiếu Lâm.
- Support positions: hồi máu ưu tiên ally đủ HP mất thật trong phạm vi, bảo vệ healer, không đứng chồng/cản; DPS chọn target mark ở tầm. Một healer tốt nên giúp giảm **downed, Injuries, cost**, không nhất thiết tăng %win trong thử Boss ngắn.
- Đội hình đổi trước trận; active workforce hẳn đã gán Mỏ/Lâm/Điền không thể bị kéo đi chiến đấu trái One Active Job. Có thông báo nguyên nhân rõ ràng.

### 8.2 Chọn chiến thuật đơn giản, bốn preset
| Preset | Quyết định AI khác nhau | Kẻ địch phù hợp | Tradeoff |
|---|---|---|---|
| Cân bằng | giãn đội hình, bảo vệ support, tấn công mục tiêu threat gần | quái thường + elite | sát thương không tối đa |
| Săn Boss | tập trung một Boss, giữ interrupt cho cast hiểm, heal ưu tiên đích | Boss + hộ vệ | clear mob chậm hơn |
| Farm | ưu tiên nhiều mục tiêu, AoE có cap, tránh cast dài quá mức | nhiều quái vừa | dễ bị tập trung đánh |
| Độc/khống chế | ưu tiên target đã nhiễm độc/mark, kéo dài giao tranh, giữ an toàn | elite có kháng vừa | kém nếu Boss kháng độc mạnh |

**Không nên:** cho phép player điều khiển từng đòn kiểu JX nguyên bản; đây là game quản lý tông môn Android 1280×720. Điều khiển tổ đội và thứ tự skill phải *rõ ràng và ít thao tác*; không làm người chơi quản lý 30 actor bằng 30 joystick.

### 8.3 Các trường hợp thử tác động gameplay
- Nhóm 6 DPS vs 2 tiền/2 DPS/1 control/1 healer cùng gear/realm; đo winrate, TTK, downed, remaining HP, injury/consumables, DPS true, effective heals, time CC và shield absorption.
- Boss một đòn AoE có telegraph/interrupt, chống stun miễn hạn, target ít HP; tank/threat làm giảm số người bị nhắm vào healer.
- Boss có kháng độc cao, nhóm Ngũ Độc phải còn một phương án damage có ý nghĩa; Boss kháng Hỏa không bị khóa mọi Thiên Nhẫn. Không tạo softlock nếu đội đủ cấp có gear/đòn thường hợp lệ.
- Five teams focus Boss: one poison stack cap, one armor-break cap, no six-healer self-overheal mastery; online-view vs background deterministic.
- Boss levels/species spawn từ vùng/độ khó đã được chọn, **không tự scale sau spawn theo lực chiến nhóm**.

## 9. MONSTER/PROGRESSION BALANCE: CHƠI ĐƯỢC RỒI MỚI NHÂN NỘI DUNG

- Pilot monster tiers trong live code: regular HP×1; elite HP×1.35,ATK×1.10,DEF×1.10; boss HP×2.5,ATK×1.3,DEF×1.18. Đây **chưa phải global locked PvE balance**; nhiều MonsterCatalogue species và 90s timeout, không tự thay.
- Đã có trường hợp bộ thử 16 seed: 6 người **không healer vẫn thắng Boss 16/16**, còn 3 người yếu gặp Boss thua 0/16. Đây là dấu hiệu cần phân hóa vai trò và thế trận, không là bằng chứng cần tăng mọi damage Boss +100%.
- Benchmark Nhân/tiểu cấp quái thường tham chiếu hợp đồng hiện hành **12–40s** cho trận bình thường pilot, 90s tối đa kỹ thuật. Đội mạnh có thể thắng nhanh; Boss dài hơn nhưng phải có nhịp cast/phase/đuổi/guard dễ đọc, không chỉ HP sponge.
- **Bảng cân bằng bắt buộc:** snapshot r1/r5/r10/r11/r20/r21/r30 × tầng1/tầng10, tiềm lực0/100, lệch TuVi vs Body, ít/nhiều trang bị; dps, EHP, TTK, độ lệch boss cấp, status uptime, chiến lược clear 6vs6 và 30vs40. Không tăng damage skill tự động theo cấp phái thêm một lần ngoài ATK đã nhân `G`.
- Rà soát Precision r30 (HP>5.2e8), số nguyên UI, tooltip rút gọn, save serialization and 0 HP boundaries; không dùng float màn hình làm authority để làm tròn trước hit. Test deterministic same seed/save replay and JSON stable order.
- Không đẻ **power số tổng** làm authority; nên dùng score đánh giá khó dễ có giải thích dựa trên DPS/EHP/đội hình/status, không tự cân boss.

## 10. VFX/SPRITE — CHỌN NHIỀU ASSET NHƯNG GIỮ CHIẾN TRƯỜNG ĐỌC ĐƯỢC

**Asset chain:** immutable JX source file → `source_variant_id` + sha → source `skillId/missileId` → authored `game_skill_id` → authoritative combat event → `VFXGraph` metadata → correct Godot atlas/frame clip + SFX. Không bao giờ map trực tiếp SkillId nguồn thành damage/AI branch.

- `FX.json` N: `fly/hit/end` có `n,d,w,h,ax,ay,ms,spd` giúp tái sử dụng chuẩn thời gian/gốc tọa độ. **44 effects fly 16 hướng** đã từng kiểm tra; JX-N `fx/` **202/202** filename closure verified, nhưng rect ảnh, mờ/hướng và frame QA chưa.
- `img/a/` N: **117 actor animation groups đầy đủ 5 clip** `at/run/st/hurt/die`; chọn nhiều boss/quái hợp bối cảnh, không coi 117 là 117 loài/sức chiến.
- JX-O native/assets 176 WebP + 74 WAV hiện thấy; cần đối chiếu metadata `nativeSprites` 176 và hash với file thực, xác minh clip từng SPR; `char/` 132 WebP, `fx/` 49 WebP, `sfx/`31 MP3.
- **Source A** là ưu tiên diễn viên đệ tử nhân dạng/chibi; tái dùng raw Spine + baked Godot Batch-01, metadata pivots/timing/outfits. Nếu Source A chỉ có idle/walk thì attack phải dùng clip thật hoặc một fallback action đã nói rõ, không giả animation khai thác. Quái JX và VFX JX có thể ghép vào.
- 2D actor orientation có thể dùng 2 hướng/mirror đúng chỉ dẫn owner cho pilot, còn projectile mũi kiếm giữ 16 hướng nếu asset hỗ trợ. Không flip hiệu ứng có chữ/symbol bị đảo, không đổi direction của clip 16 hướng sang 2 vô lý.
- **VFX ordering**: pre-cast dưới/ngoài nhân vật tùy style; projectile theo world y-sort; impact ở vị trí target; status trên actor, UI HP/name trên overlay riêng. Đảm bảo cast/launch/impact không che telegraph và HP.
- **Performance**: Android ngang 1280×720, màn mục tiêu 30FPS+ thực tế sau QA; pool FX, budget mỗi quality tier, texture lazy load theo zone/skill equipped, sfx polyphony limit, đừng load cả 202 FX+176 native+117 full actor rigs khi mở trận. Texture memory = atlas pixel width×height×format, **không** lấy kích thước WebP trên Drive làm RAM GPU.
- **Fallback**: thiếu asset hiển thị visual trung tính có metadata provenance PENDING, nhưng damage vẫn chạy đúng; không mượn FX chiêu không cùng chuỗi làm "JX authentic".
- **Rights gate**: file do user cung cấp ≠ tự có quyền phát hành artwork người thứ ba; áp dụng quyền phát hành riêng cho mỗi variant trước bundle ra ngoài.

## 11. GAMEPLAY UX — ÍT BẤM NHƯNG ĐỦ CHIỀU SÂU

- **Tàng Kinh Các:** tabs kỹ năng học được, bản chưa học, gia phả và truyền thừa; lọc 10 phái/basis/weapon/element. Tooltip giải thích 4 thông tin đầu: làm gì, khi nào dùng, cần gì, học/cường hóa mất bao lâu/tài nguyên nào. Có dấu `Chưa có hiệu ứng triển khai` trong dev, không show kỹ năng chết ở production.
- **Hồ sơ đệ tử:** breakdown HP/ATK/DEF thành `Tu Vi + Luyện Thể + Tiềm Lực + Công Pháp + Trang Bị + (Trait/Bloodline/Root/Fate)`, tránh người chơi không thấy đột phá có tác động gì. Button xem `Tại sao không dùng chiêu này?`.
- **Bảng võ học:** 1 ô basic + 4 ô active + 6 ô triggered passive, dynamic unlocked; static self passives được liệt kê riêng không phải 6 ô chiến đấu; Công Pháp 1+2 panel riêng.
- **Bảng đội:** 6 thẻ có vai trò/trường phái/chiêu chính/tầm đánh; prebattle preset / đổi/ gỡ nhanh; đánh Boss preview cơ hội sống dự kiến + yếu điểm (không tự chỉnh quái); lúc đánh hiển thị Boss telegraph và vài chỉ số quan trọng, không che map.
- **Kết trận:** damage thực, DOT thực, heal hiệu dụng, shield absorbed, damage tank prevented, successful control, vị trí Bị Hạ/Injury, vật phẩm/kho nhận exactly once; tránh 5 đội spam 30 pop-up mỗi tick.
- **Hoạt ảnh:** clip cast hợp lệ và SFX nhẹ, game có thể đọc rõ ngay trên Android 1280×720; ưu tiên mục tiêu chơi hiểu tình huống trước độ nhiều VFX.

## 12. QA/SAFETY MATRIX TRƯỚC KHI BẬT CONTENT

| Gate | Pass khi nào | Không được fake |
|---|---|---|
| G0 Source proof | Mỗi `game_skill_id` có source refs, source kind (FACT/INFERENCE/AUTHORED), version, hash, rights | Không coi display name là hiệu ứng thật |
| G1 Stats & realm | r1/r5/r10/r11/r20/r21/r30, floor1/10, body imbalance, potential/equipment correct | Không tự thay G=1.65/1.03 |
| G2 Skill legality | truyền thừa, học, basis, pháp môn/weapon, Chủ Đạo, slot max, family successor, exclusive owner | Không tự học chiêu từ faction name |
| G3 Direct event | cast/packet/target deterministic, no duplicate multi-projectile, AOE cap3, crit/DR/lifesteal exact | Không gây damage theo frame VFX |
| G4 Persistent effects | status/stack/refresh/snapshot/expiry/cleanse tier/CC boss, heal effective and guard absorption | Không có poison icon rỗng |
| G5 Passive event | passive static non-slot, triggered consumes slot, ICD, anti-recursion, party-scope strongest-only | Không cộng double Công Pháp + passive |
| G6 Formation | 6/party, 30/cụm, leader no aura free, threat/target priority, tank/heal tactical benchmark 30–100 seeds | Không lấy một trận win làm balance |
| G7 Replay/offline | same seed same result watched/offscreen, save/reload mid-cast/proc stable, reservation One Active Job, reward and injury exactly once | Không gọi QA pass chỉ từ đọc code |
| G8 Asset | binary physically present, metadata/sha/rect/frame/direction/anchor/sound matches, authorized rights | Không lấy manifest thay sprite |
| G9 Runtime | isolated TEMP clone/save, Godot 4.7.2 Windows render/log, Android midrange 1280×720 FPS/memory/UX, owner check | Không báo PASS khi runner không có |
| G10 Backward compatibility | P2/P3.7, G1/PR20, Economy, Save và các nội dung đã khóa không bị sửa | Không merge/CI/FULL ngoài phạm vi |

## 13. KẾ HOẠCH LÀM TIẾP ĐÚNG THỨ TỰ (ĐỀ XUẤT, CHƯA CODE)

**D0** — Review bản này, chốt taxonomy/passive, chân lý source JX1 và cơ chế không Mana; giữ tỷ lệ skill ratio/cooldown là pilot.

**D1** — Chuẩn hóa *toàn bộ source* từ 2 Drive vào phiên bản manifest: union330 SkillIds, bổ sung raw source classification, link theo weapon/basis/element/dependency/sound, xác minh sprite SHA/rect và theo dõi thêm các bản JX mới tải.

**D2** — Khóa 4 school pilot thành SPEC chạy được (Thiếu Lâm guard/threat, Võ Đang missile, Ngũ Độc poison, Nga Mi HoT); mỗi school chọn 1–2 true effects trước, không triển khai hàng loạt 40 skill. Soạn bảng `cooldown/ticks/ratio/status/AI` cặp trận cùng cảnh giới.

**D3** — Formations/team and Boss behavior design với tiêu chuẩn balance có bằng chứng; sơ đồ 6 người/5 đội, 10 school late-game diversity, procurement & teaching loop.

**GATE APPROVAL** — owner quyết rõ mốc mở slot, phạm vi nhóm phái, nguyên tắc weapon, thời gian đào tạo, damage policy pilot và mức dùng asset theo rights.

**I0–I4 sau phép code riêng** — effect-consumers thật → source-art VFX pilot → 6v5/30v40 and persistence → 10 trường phái → 3 expansion schools + high tier successors.

**Hiện tại:** no code edits. C4-VP01 runtime vẫn PENDING nếu không có runner. Source A, JX Drive data, economy, PR20 và main không bị thay đổi.

## 14. CHỐT CÁC TRẠNG THÁI

- **SOURCE FACT:** tên/ID, `attr` source, `prop` source, JFX layout/những file Drive đã liệt kê.
- **GAME AUTHORITY LOCKED:** CombatStats V2, Combat Skills V2 loadout/ownership/cast/Ngũ Hành/đội hình limit; 30×10 hai trục; One Active Job; Skill exclusive A.
- **NEW DESIGN CANDIDATE:** chuyển thể trường phái, số ratio/cast/CD, các cơ chế trap/poison detonate/Threat/positioning, 4 preset party, mốc mở slot.
- **NOT IMPLEMENTED:** toàn bộ JX school content kits, true Poison+HoT+Threat+Guard learned, aura skills, complete 4-slot AI, full party formation, Godot FX closure/acceptance.
- **RUNTIME PENDING:** C4-VP01 Windows/Android visual and FPS, Source A vs JX pixel/anchor consistency, mobile benchmarks.

**END OF DEEP REVIEW V2.**
