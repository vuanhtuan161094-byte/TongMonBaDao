> **2026-10-19 OWNER OVERRIDE — SUPERSEDES THIS DOCUMENT'S OLD NO-ACCURACY/DODGE ASSUMPTION.** The owner now requires **Chính Xác, Né Tránh, Tỷ Lệ Trúng, real movement speed build and learned/equipped dodge skills**; consult `docs/C4_ACCURACY_EVASION_MOVEMENT_SKILL_REACTION_DESIGN_2026-10-19.md` as the newer authority. Do not infer AI universal/guaranteed dodge. GP01 currently presentation only; stats/RNG/simulation migration requires a scoped separate CODE packet. Historical design paragraphs below are retained for traceability but their no-accuracy/dodge clauses are superseded.

# TÔNG MÔN BÁ ĐẠO — Combat V4 gameplay, AI né AoE, quái/Boss, DMG/crit và ba trận chuẩn
Ngày: 2026-10-19. Trạng thái: DESIGN REVIEWED FROM SOURCE / NOT GAMEPLAY CODE / NOT NUMERICALLY LOCKED.
Repo: vuanhtuan161094-byte/TongMonBaDao. Design branch: design/combat-v4-gameplay-ai-hud-3encounters-20261019.
Baseline combat presentation inspected: d160f97982f627460ab17661bdbfc572fe7c51b4.
Primary main reference inspected: 461caca1171462e0da092f21108c5c1733157ad9.

## 0. Quyết định, giới hạn và nguồn bằng chứng

**Gameplay đích:** quản lý tông môn theo hướng autonomous-first. Tông Chủ thiết lập đệ tử/đội, trang bị và tối đa 4 active slots/kỹ năng có sở hữu thật, chọn khu săn, rủi ro, ưu tiên mục tiêu và chính sách rút lui; nhân vật tự giao chiến trong một encounter MapBattleV2 dùng time-step 0,25 giây. Không turn-based, không MOBA điều khiển né tay. Đội tối đa 6, tối đa 30 đệ tử/cụm; đội săn mặc định dài hạn là 5. Có quái thường/tinh anh/Boss; chiến lợi phẩm thông qua HuntingMapV2/HuntingPveRunV2 và kho canonical, KHÔNG sinh loot trong visual pilot.

**Luật không được phá:** 16 Combat Stats V2 + 10 kháng nguyên tố, không generic Accuracy/Dodge, không random miss thông thường, không generic Block/Reflect/Threat cho nhân vật; crit chance mặc định 5%, crit damage 1,50×, target crit resistance trừ điểm phần trăm; AoE max targets và stable selection; one committed active cast; deterministic same seed on/offscreen; Injury hiện hành 0/1/120 tick không được thay bằng mô hình 0–100 trong một packet combat; One Active Job, warehouse, economy/save không được sửa.

**Bằng chứng repo:** docs/COMBAT_SKILLS_V2_SPEC.md §11–18, 27–31; docs/COMBAT_STATS_V2_SPEC.md §2.3, §12.1, §5; docs/DV2_02_GROUP_MAP_COMBAT_CONTRACT.md; docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md; docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md; docs/GAMEPLAY_REFERENCE_SYNTHESIS.md. Code: godot/src/simulation/combat/{map_battle_v2.gd,combat_stats_v2.gd,monster_catalogue_v2.gd,jx_pilot_skills_v1.gd,jx_pilot_runtime_v1.gd,hunting_map_v2.gd,hunting_pve_run_v2.gd}; presentation/p3/{map_battle_world_layer_v2.gd,combat_v4_jx_pilot.gd}. v5 official Windows Godot 4.7.2 6/6 focused PASS chỉ trên SHA 33a3118cf..., v6 camera d160f... CHƯA CÓ runtime PASS; owner UX PENDING.

**Nguồn tham khảo đọc trực tiếp từ Drive, chỉ nghiên cứu:** Võ Lâm Idle fan-made README.md tại https://drive.google.com/file/d/13SAlFG5AYXpa-bnvrFvfHQXodWt3n3Ou/view (tự đánh/xoay chiêu/tự thuốc/trang bị/ngũ hành); Giang Hồ Chi Chiến fan-made: js/boss.js (thinkBoss, chooseTarget, aggro/leash, windup/recovery), boss-data.js (kit/tiers), projectile-motion.js (vật phóng), combat-assist.js (lead aim), auto-play.js (auto potion). Folder https://drive.google.com/drive/folders/19mdpwyTf2tzYblpfOg0CARi-JHdO70ZR. Đây KHÔNG phải chứng minh engine của JX1 chính thức, không sao chép nguyên code, hệ số hay asset chưa xác minh chain quyền. So sánh ngoài: https://volamm.vnggames.com/tin-tuc/huong-dan/huong-dan-cach-phat-trien-nhan-vat-thieu-lam.html (kháng, phản đòn, các nhánh võ học); https://evilhunter.zendesk.com/hc/en-us/articles/360039882831-Hunter (autonomous hunter, CRIT/evasion của **game tham khảo**, không nhập chỉ số); https://game.xiaomi.com/viewpoint/1557564488_1700832689913_13 (最强祖师 auto theo lượt, vị trí/đội hình; ta học chiến lược, KHÔNG chuyển game mình sang turn-based). Không có bằng chứng trực tiếp về chính xác toàn bộ hoạt ảnh/sát thương của JX1 gốc; muốn faithful skill-by-skill phải verify resource graph/SPR/PAK nguồn và quyền sử dụng.

## 1. Kiểm toán thực trạng — game đang có gì, thiếu gì?

| Hệ thống | Code đã xác minh | Giới hạn quan trọng |
|---|---|---|
| Encounter | MapBattleV2 0,25s, một nhiều-vs-nhiều, order stable ID, timeout 90s, outcome thắng/thua/rút lui, no damage khi 0 HP | Test fixture không phải vòng săn live |
| Target & movement | Mỗi actor chọn địch còn sống **gần nhất**; tiến thẳng đến khi vừa tầm, move_speed tùy role | Không giữ đội hình, tránh người/địa hình, ưu tiên tanker, retreat local, địch hành xử như một quần thể |
| Quái | MonsterCatalogueV2 lưu species/tier/element/behavior_id như pack_hunter, aggressive, armored_brute, boss_phase_authoring_pending | Trong MapBattleV2.setup không duy trì behavior_id vào actor: nhãn chưa điều khiển AI |
| Elite/Boss | Tier khác stats, elite/boss dùng delayed area_slam max 3, warning elite 0,75s bán kính 2,2; Boss 1,0s bán kính 2,8 | Không nhiều phase/counter-play; không AI tránh AoE; một số mục tiêu trong vòng đỏ vẫn không trúng do cap 3 |
| Kỹ năng JX pilot | Shaolin guard; Wudang party defense/projectile; Wudu poison; Emei HoT; exact 5 IDs; skill cast, projectile travel, poison tick | 6v5 pilot fixture có 2 đệ tử không có source JX skill; đồ/võ học chưa phải roster thật; VFX chỉ một phần |
| Crit / damage | CombatStatsV2 5% Crit cơ bản ×1,50, Crit Resistance; MapBattleV2._deal_direct emit hit damage, critical, lifesteal | UI không hiển thị số damage/crit; không có generic miss là có chủ đích |
| Healing/status | heal, pilot_hot_tick, pilot_poison_tick, pilot_guard, pilot_party_defense đều có event thực | UI feedback mới là tag ngắn, chưa rõ giá trị và thời điểm |
| Visual | 1280x720, actor source WebP, bar, AoE warning, source sword FX, interpolation | Tất cả người dùng cùng một hero giả lập; Boss wolf phóng cỡ; HUD lộn xộn khi crowd; camera v6 chưa chứng minh UX |
| Hunting | HuntingMapV2 3 vùng ×5 cấp; HuntingPveRunV2 có reservation, replay/save/settlement/claim | Visual pilot không nối HuntingPveRunV2, không trả real loot, policy AI chưa hoàn thiện |

**Nút nghẽn thật:** không phải zoom đơn thuần. AI thiếu chiến thuật vị trí + quái không có behavior consumer, nên các tác nhân tụ lại; một camera phóng đại không làm đội hình thông minh hoặc làm quái khác nhau.

## 2. Game design pillar và gameplay vòng dài

Chọn đội 5 (tối đa 6) → gán vai trò/skill được học, trang bị, consumable được phép → chọn bản đồ, độ khó 1–5, loại con mồi, rủi ro, ngưỡng rút lui → đội di chuyển/săn tự động → encounter thật, chiến đấu có bài bản và luật sống sót → thắng: EXP/loot/tiền/contribution theo authority, vào kho Sect trực tiếp; thua/rút lui: thương thế, hồi phục, tạm ngưng → nhân vật/hậu phương phát triển → đẩy khu vực khó hơn.

Không ép Tông Chủ spam micro né skill; mặc định chỉ cần xem báo cáo/nhận biết sai ở khâu chuẩn bị. Điều khiển ưu tiên nhóm, có thể override 1 cá nhân nhưng không sửa gameplay từ renderer.

### Đội hình nên tạo khác biệt

- Cận chiến/Thể Tu: giữ phạm vi bảo vệ, ưu tiên che chắn/guard, giữ vị trí trước tuyến; **không có aggro vô hình**. Khả năng đỡ đòn phải dựa trên vị trí + kỹ năng Threat có thật nếu sau này được author.
- Trung/viễn/Pháp Tu: giữ khoảng cách mục tiêu theo profile, tránh va chạm, không tự động kite vô hạn; nếu bị ép góc vẫn có thể trúng.
- Hỗ trợ/Y Đạo: ưu tiên hồi ally thiếu HP thật, giữ phía sau/đủ tầm, không tự hồi sinh người bị hạ.
- Ai thiếu hành động hợp lệ dùng basic; không tự invent skill hay mana.

## 3. AI né AoE: quyết định đề xuất là NÉ VÙNG, không thêm Dodge %

**Độ phức tạp:** vừa phải nếu giới hạn state machine [NORMAL, REACT_TELEGRAPH, EVADE_STEP, REASSESS, RETURN_ROLE] với timer/điều kiện deterministic; không A* phức tạp cho pilot arena trống, không phán đoán di chuyển trong tương lai qua thông tin ẩn.

**Sự công bằng:**
1. Chỉ phản ứng khi real telegraph đã commit và được ghi vào authority; AI không đọc RNG/boss's next skill. Human viewer offscreen và AI nhận *cùng* thông tin.
2. Không iframe/teleport, không automatic miss, không chỉ cộng +dodge% ở damage resolver. Tránh được nếu vị trí của *hình tròn actor logic* tại release ở ngoài vùng đủ an toàn.
3. Respect locked cast, movement rate, body occupancy, distance profile, map bounds, status control; bị choáng/trói hay hành động committed sẽ phản ứng muộn/không chạy được. Không hủy skill đang committed nếu chưa có luật interrupt/penalty được author.
4. Boss có wind-up rõ và cooldown; cảnh báo không đổi tâm bất ngờ. AoE damage vẫn chọn tối đa 3 mục tiêu tại release theo vị trí thật, không auto-hit mục tiêu đã chạy ra ngoài.
5. AI có thể bị đánh bại hợp lệ: tốc độ chậm, khoảng cách xa, nhiều zone chồng, vị trí xấu, kỹ năng đang cast, lựa chọn chính sách giữ tuyến. Không cho mọi đội 100% né.
6. Khả năng né không phụ thuộc FPS, pan/zoom, scene visibility, screen size, thiết bị, save/resume hay việc người chơi quan sát.

### Tính toán vật lý — khóa yêu cầu fairness trước khi code

Current Boss radius = 2,8 đơn vị world; cast warning = 1,00 giây; default frontline move_speed ≈2,35 và hỗ trợ ≈2,05 world units/s. Từ đúng tâm, ngay cả phản ứng **0 giây**, chạy thẳng 1 giây được tối đa 2,35/2,05 < 2,8 ⇒ Không thể thoát vòng. AI “né trượt” không phải bug AI.

Với delay phát hiện 0,25s, clearance 0,10 ô, tính sơ bộ:
- Frontline: 0,25+(2,8+0,10)/2,35=1,485s ⇒ lượng tử 0,25s cần khoảng **1,50–1,75s**.
- Hỗ trợ: 0,25+(2,8+0,10)/2,05=1,665s ⇒ khoảng **1,75s**.
- Elite radius 2,2: 0,25+(2,2+0,10)/2,05=1,372s ⇒ khoảng **1,50s**.

**Pilot candidate (chưa LOCK):** Boss warning 1,75s (7 tick), Elite 1,50s (6 tick), AI reaction khoảng 0,25s (1 tick) khi không cast; mỗi actor tối đa 1 evasive move decision/tick, no teleport. Actual fairness phụ thuộc collision radius, dash/status, ranh giới map, tốc độ và khoảng cách từ tâm; thông số được điều chỉnh bằng seeded benchmark. Khi attack windup kéo dài hơn, Boss cần recovery/cooldown/targeting đổi để tránh thành quá yếu. Không sửa code V2 theo số đề xuất cho đến packet riêng có authorization.

**Algorithm đơn giản:** trong mỗi tick, lấy real zones active; nếu actor đang có nguy cơ ở cuối thời gian warning, tạo 8 hướng ứng viên (4 chính+4 chéo) theo nearest safe edge, cộng margin, clamp arena; loại vật cản/đè người/chướng ngại; ưu tiên đường ngắn nhất vẫn giữ phạm vi role/đội khi tương đương; deterministic tie by direction index rồi actor ID. Di chuyển từng bước min(move_speed*0,25, need). Nếu không có lối thoát thì guard/bracing nếu có skill hợp lệ, không giả “MISS”. Nếu nhiều vùng, chọn điểm an toàn đối với các vùng có thể thoát với thời gian còn lại. Reassess mỗi tick, tránh rung hướng bằng hướng đã commit và epsilon.

**Rủi ro/role:** THẬN TRỌNG (support/ranged cố né sớm), CÂN BẰNG (đa số né nếu không đang committed), GIỮ TUYẾN (frontline có thể guard/không tách khỏi đồng đội nếu risk chấp nhận). Đây là policy thật cho người chơi đặt trước, KHÔNG thêm random “độ thông minh” hoặc random dodge.

### Fair play phía quái

Quái thường không cần né AoE như người nếu không có content tương ứng. Công bằng = luật được giải thích và phản ứng có counter-play, không bắt hai phe phải có cùng chiến lược. Nếu elite/Boss có né/reposition phải là behavior được author có cooldown/điều kiện thấy được, không hack tránh mọi skill của người chơi. Tông Chủ cần đọc ở màn báo cáo: “trúng vì đang niệm chiêu”, “ra khỏi vùng kịp”, “không còn đường thoát”, không in “NÉ” khi chỉ không nằm trong 3 mục tiêu cap.

## 4. Enemy AI: consume real behavior_id, không chỉ đổi tên quái

Dữ liệu species existing: Trúc Thử skittish, Thanh Lang pack_hunter, Hắc Lang aggressive, Nham Giáp Thú armored_brute (Elite vùng Thanh Trúc Lâm), U Hồn debuff_caster, Huyết Lang Đầu Đàn pack_leader, Hắc Lang Vương boss_phase_authoring_pending.

**Behavior Adapter V1 (new, authorized separately)**:
- Preserve behavior_id from real MonsterCatalogueV2 into battle actor; validate exact known IDs; fallback nearest-basic only for legacy entries. Never silently force a new skill on species with no authored kit.
- Trúc Thử (skittish): prefers maintaining survival distance when weak; small deterministic disengage, not endless kite.
- Thanh Lang (pack_hunter): when nearby ally pack exists, focus target chosen via stable group pack memory; prefers isolated vulnerable disciple if within chase budget, else nearest. No teleport.
- Hắc Lang (aggressive): advances earlier / less likely disengage, prioritizes accessible wounded enemy (health threshold + positional exposure), no omniscient target.
- Nham Giáp Thú (armored_brute): slower, high DEF, readable windup area at reachable range, has punishable recovery; does not instantly home to healer.
- Huyết Lang Đầu Đàn (pack_leader): can coordinate real wolf allies through explicit time-bounded leader event; if implementation delayed keep tag metadata-only and mark not implemented.
- U Hồn (debuff_caster): future real debuff via same skill primitives; NO debuff pretend before its consumer exists.
- Hắc Lang Vương: genuine Boss phases described below, data-driven via the same MapBattleV2 cast/projectile/status primitive, not a second damage engine.

Target selection policy: nearest valid living enemy baseline, stable deterministic tie by ID; optional visible behavior-specific priority with distance cap, hysteresis and cooldown. Never read player power to scale monsters dynamically; difficulty is set at spawn. Add body-space occupancy only under separate simulation packet: no client-side cosmetic shoving.

## 5. Hắc Lang Vương boss encounter: đọc được, counter-play được

**Phase plan proposed (not implemented):**
- Phase 1: 100–70% HP — normal bites and one clearly shown delayed circular AoE. Teach player warning/counterplay.
- Phase 2: 70–35% HP — “Lang Tru” calls *already planned* escort pack behavior (or an event with real spawn limits), may use a frontal sector instead of circle. At most one special chain per cooldown; telegraph for each.
- Phase 3: <=35% HP — faster but more committal charge/large AoE with clear recovery and higher threat; no invisible unavoidable one-shot.
- Threshold transition occurs once; events have unique boss phase ID, no repeat on reload. HP threshold check on authoritative HP and step only.
- No shield/stun/taunt/immunity claiming without actual existing consumers. If any feature lacks backend, omit from first Boss V1 instead of putting a fake icon.
- Keep Boss + escorts fitting encounter's real 5/7 spawned mob capacity; no clandestine extra 41st actor, no spawn after battle terminal. Outside-range leash rules only if outside-region ecology is activated (not pretend in arena).
- Future legit counter-builds: crit resistance, elemental resistance, protection, group composition; do not import JX1 official bosses' stats by guessing.

## 6. Dmg/Crit/Heal/status interface: BẮT BUỘC, event-driven

**Existing math to preserve:** Crit Chance effective = clamp(attacker.crit_chance - target.crit_resistance, 0..1). Base at unmodified stats: chance 5% (0.05); Crit Damage multiplier 1.50 (not additive 150%). Defense, element resist and Damage Reduction apply separately. Direct ordinary attacks never randomly MISS. Followup proc is single nonrecursive, no crit/lifesteal by default. Poison DoT has no crit by default.

**Canonical feedback event mapping:**
- MapBattleV2 hit {attacker,target,damage,kind,critical,lifesteal}: exact real damage popup at target anchor. Crit uses actual critical bool and numerical final damage; lifesteal actual heal appears at attacker only if >0. Do not re-compute formula in renderer.
- pilot_impact {effective_damage,...}: impact animation only; **NO second popup** if a matching hit has been emitted by _deal_direct. Canonical dedup key needs encounter_id+event index or stable impact/cast ID; dedup only visual and never drop original journal.
- skill_hit: cast release notification, no damage popup. area_release: shape ends, no damage popup. pilot_cast/pilot_commit: cast status visuals, not damage.
- heal {target,amount}, pilot_hot_tick {target,amount}: green +amount from actual event >0 only. pilot_poison_tick {target,damage}: DoT-style, not random crit; show icon/colored damage when >0. pilot_poison_applied: status label/icon, not damage.
- guard, pilot_guard, pilot_party_defense: status icon & duration when producer exposes it. Absorb/block number only if a real resulting event exists, never fabricate.
- “TRÁNH VÙNG” only on a new authoritative evade_success event earned by physical actor position at release, with classification clear that actor genuinely left danger; otherwise no “MISS”, no “DODGE” fabricated. Damage capped to 3 actual targets: do not show “NÉ” to extra fourth character merely untouched by cap.
- "Bị Hạ", "Rút lui", "Thắng" from actual outcome/downed events.
- Distinguish color/shape: ordinary small white/cream; critical enlarged gold plus subtle (!) and pulse; taken damage orange-red; heal green; poison purple; warning red translucent under feet; boss cast title over Boss. Accessibility: not color alone; include icon/typography.
- Layout: per-actor anchored position from authoritative+interpolated camera projection; floating up and fading for 0.55–0.85s, no blur; avoid HP/name occlusion via UI overlay lane; fixed max visible popups e.g. 20–32 (PILOT performance candidate) prioritizing Boss damage/crit/downed/player; can coalesce same-target hits over 0.12–0.20s purely visually if preserves crit, hit count and logs. No gameplay RNG in cosmetic offsets; deterministic hash ID for offsets.
- Toggle 3 display tiers in player settings: TỐI GIẢN [boss/crit/HP/death], CHUẨN [direct+heal+effects], CHI TIẾT [per hit and status]; Android landscape 1280x720 finger-friendly, never 100 overlapping labels. Hover-only is forbidden; tap actor opens source/stat+status report.
- Real SFX: separate impact for crit and skill events only when rights+asset verified. Cosmetic audio cap per frame/mix, duck heavy spam; VFX source mapping no inappropriate reuse of sword for poison or heal.
- Numeric examples such as 1.248 or 2.876 are mockups only, NEVER treated as battle output.

## 7. Three canonical Thanh Trúc Lâm encounter acceptance fixtures

Each uses real MonsterCatalogueV2 species, one MapBattleV2 seed-fixture and real DiscipleCombatLoadoutV2 stats where available; fixture roster explicit, NOT masquerading as normal RNG probabilities. For actual gameplay level/count/boss chance see HuntingMapV2.LEVELS and REGION_CONTENT. Keep player selected level + spawn fixed *before* battle; per-action deterministic. Bench multiple power ratios without modifying spawn after seeing outcome.

### E1 — Ngoại Vi, quái thường, chuẩn chiến đấu 5v3

- Starting policy: level 1, 5 disciples (1 frontline/guard, 2 dmg ranged or sword, 1 healer/support, 1 free flex), Trúc Thử ×2 + Thanh Lang ×1 (explicit regression fixture).
- Trúc Thử basic retreat impulse when low HP, Thanh Lang tries pack_target only when eligible packmate exists (here solo wolf uses nearest).
- Teach: 1 frontline intercept + ranged attack + healer heals missing HP, crit numbers and first capture of target, real downed if outmatched.
- Win: all 3 dead, actual logged HP; defeat/time-out honest. No hidden mob generation, no fake item print.
- Acceptance: enemy acquisition, basic range, 3-vs-5, no spawn overlap at time0, travel animation alignment, crit seeded trace, healer not resurrecting downed, reward once via HuntingPveRun V2 when connected.
- Comparison: with healer/no healer and different initial position, tracked survival/time; no forced predetermined win ratio.

### E2 — Hung Địa, tinh anh, chuẩn 5v5

- Difficulty level 3, includes mandatory elite; team 5, foe Nham Giáp Thú ×1, Thanh Lang ×2, Hắc Lang ×1, Trúc Thử ×1 (explicit source-aligned fixture). Original LV3 normal count 5, min elite 1.
- Elite uses clear windup radius 2.2, pilot candidate warning 1.50s for a deliberate avoidable attack. Armored opponent supports meaningful armor penetration/element counter, no artificial +Dodge.
- Wolf duo tests pack focus; Black Wolf tests aggressive accessible target.
- AI side: ranged maintains distance without infinite kite; healer path avoids warning if possible; frontline may guard to protect zone, cannot teleport.
- Acceptance: actual hit order/cooldown/AoE <=3, 0.25s stepping, coverage/prediction vs true release, critical resistance calculation unchanged, no HUD fabricated NÉ.
- Benchmark both equal-power and under/overpower; compare effective time to kill, damage taken, retreat/downed, elite dodge success when physically feasible.

### E3 — Hắc Lang Vương boss + guards, 6v5

- Hero six-person maximum pilot: 2 durable front, 2 DPS, 1 healer, 1 flexible build. Monster group Boss Hắc Lang Vương ×1 + one Elite Nham Giáp Thú ×1 + 3 normal wolves (2 Thanh Lang, 1 Hắc Lang); **SCRIPTED BOSS test fixture at level 3**. Natural LV3 Boss probability remains current 8%, do not change it or promise every encounter has a Boss; LV5 guaranteed boss exists separately and spawns 7 mobs.
- Phase 1: actual warning/body targeting. Phase 2 and 3 separately gated; don't fake phase announcement before producer.
- Boss warning candidate 1.75s, three-hit cap preserved. AI must choose dodge/guard by real policy, cast constraints, actual move_speed. Packmate focus and healer-threat make formation matter. Boss can survive at least one skill cycle at benchmark gear level; no scripted immortal Boss.
- Acceptance: first phase has true pre-release tell, ≥1 documented feasible escape case and ≥1 unavoidable (committed/slowed/boxed) case; movement never teleports; at release target positions only; cap <=3, no friendly fire, no ghost damage after Boss dies.
- Bench balanced/over/under-power, with/without healer, tank missing, keep-line versus safe, seeded replay & offscreen equality. Compare different team compositions, NOT just win rate.

## 8. Benchmarks: đo để cân, không đoán trúng

**Smoke** per fixture: 100 deterministic encounter seeds × ≥4 party configurations [balanced, no-healer, no-frontline, same-spec/underpowered]; + 100 tests with 20–25% stronger/weaker effective stats, exact seeds in fixture records, **no random using render**. Record outcome, elapsed/TTK, downed, residual HP, received damage, player healing, direct vs DoT/crit share, avg crit count, distance moved, potential vs successful dodge, cast interrupted/committed, Boss phase count, damage distribution across 6 actors, friendly fire, threat selection, FPS/memory physical distinct.

**Provisional guardrails, not acceptance win-rate locks:** balanced E1 should outperform underpowered E1; E2 must demand better protection than E1 at a comparable stat budget; E3 must show counter-play without requiring perfect 100% avoidance; no-healer and no-tank teams should change survival/speed/risk materially but should not be artificially forced to lose; all scripted tests have deterministic reproducibility.

**Hard gates**:
1. Exact same {seed, initialized party, world, config} yields identical outcome/HP/event order for camera on/off, viewed_map on/off, 30/60 FPS, save/reload mid-cast, scene hidden/visible.
2. Fixed timestep 0.25; no actor passes through walls/other bodies after an authorized occupancy contract, no invalid arena position; movement cost ≤move_speed*0.25/tick, except explicitly-authored dash.
3. Escape only if physical position outside radius at actual release and actor alive; no RNG dodge/miss. Impossible-center 1.0s vs radius 2.8 test must correctly fail, not falsely PASS.
4. On zero HP, no action/new cast/revive; only true revive may resurrect in future; receipt exactly once.
5. Crit rate seeded statistical sample consistent with effective chance (within pre-registered tolerance); crit multiplier from authoritative stats, no duplicate damage events; no text generated by fake attacks.
6. Every HP delta attributable to a legitimate event, attack geometry, real target and cooldown; never VFX-induced.
7. Same outcome/reward for player observing vs not observing; no camera effect on AI/policy/spawns.
8. One encounter max 6/party, 30 disciples/cluster, 40 monsters, max 3 AoE victims; 1280x720 density gates at 6v5 and 30v≥5.
9. Preview item/material quantity cannot claim rewards; only win/authorized claim exactly once into canonical warehouse, injury 0/1/120 preserved.

## 9. Implementation roadmap — separate code packets, no cross-write accident

| Packet | Authorized by THIS DESIGN? | Scope/owner | Acceptance |
|---|---|---|---|
| C4-GP00 | DESIGN ONLY, completed here | Inspect source and proposed rules, fixtures, contracts; do not modify runtime | This MD; traceability/limitations |
| C4-GP01 | Requires SPECIFIC owner CODE instruction | Battle event/HUD adapter only: damage, crit, HoT, poison, statuses, outcome, noise budget, event dedup, proper camera anchor; no new game math | Focused 6v5 numeric event-vs-screen, perf, no double popup; Godot official |
| C4-GP02 | Requires SPECIFIC owner CODE instruction | MapBattleV2 tactical placement/dodge + monster behavior data plumbing, event schema + test; no SaveService/Economy | E1/E2 movement/collision/AoE guaranteed invariants, 100 seeds, replay |
| C4-GP03 | Requires SPECIFIC owner CODE instruction | Boss V1 phase/cooldown/telegraph/dodge interplay using same combat primitives | E3 deterministic phases and fair reactive tests; compare old baseline |
| C4-GP04 | Requires SPECIFIC owner CODE instruction | Actual HuntingPveRunV2 party/policy/UI loop, rewards/injury/warehouse, persistence (requires integration writer) | Real recruit → hunt → rewards/return, rollback, exactly-once |
| C4-GP05 | Separate verified rights + CODE packet | Native source-matched five skill VFX/projectiles/SFX, wolf/boss identity; Android performance | Rights/hash and 1280x720 official Godot/physical mobile FPS |
| C4-GP06 | Later accepted authoring, not implicit | More skills/monsters, raid coordination, multiple parties/30-actor UX | Full balance matrix, owner visual sign-off |

**Suggested order:** GP01 feedback (quickest visible result without gameplay mutation), GP02 behavior/dodge (most important tactical correctness), GP03 Boss, GP04 economy/live map integration, GP05 source FX after verified identity. Do NOT attempt all gameplay subsystems in one unbounded commit.

**Pre-code governance:** AGENTS.md §3 explicitly requires user packet authorization naming behavior, latest main SHA, allowed paths, exclusions, rollback and focused/cumulative tests. Broad desire “hoàn thiện toàn bộ” approves the target direction but does not waive that gate. This file is design only. Use independent branch for CODE based on verified base, not mutate PRES01 branch or main. Do not run CI/FULL/merge without matching gate/permission. Never relabel old Windows 6/6 PASS as acceptance on a new SHA.

## 10. Decisions to retain and open design questions

**Retain:** live auto battle; no ordinary miss/dodge stat; crit visible from existing authority; boss warning must be physically escapable for appropriate roles; no VFX invented from wrong JX skill; no post-release animation replay; recorded source rights unresolved; Android landscape.

**Choose after GP02 prototype evidence, not by assertion:** warning 1.50/1.75s candidates, exact collision radius, role movement priority and cooldown, risk profiles' thresholds, boss phase list, popup cap, numeric outcome benchmarks. Require at least one seed-based counter-example before claiming any boss unavoidable or trivial.

**Owner review gate:** owner must experience visually authentic 6v5 encounter, understand *why* an individual was hit/dodged/downed, see crit and HP clearly, and feel preparation/policy mattered. Static MD and Godot focused PASS alone are not visual/gameplay acceptance.
