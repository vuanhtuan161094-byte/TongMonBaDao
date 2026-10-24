# TÔNG MÔN BÁ ĐẠO — THANH TRÚC LÂM: 20 BÃI QUÁI, ĐƯỜNG ĐI, FARM LIÊN TỤC & 5 MỨC KHÓ
## Quy hoạch logic khu săn mở 30 đệ tử / 200–400 quái, thiết kế riêng hệ Tinh Anh/Boss, AI, minimap, loot, phụ thuộc

**Ngày:** 2026-10-24
**Trạng thái:** **DESIGN ONLY**. KHÔNG code; KHÔNG chuẩn bị packet Codex SK-A/B; KHÔNG sửa PR #29, UI, Source A, workflow hoặc merge.
**Quyết định mới nhất của owner:** **Thanh Trúc Lâm là MỘT bản đồ lớn có khoảng 20 bãi quái; một bãi khoảng 10–20 con; có tối đa 30 đệ tử đi lại và farm trên cùng bản đồ, điều khiển tương tự RTS/Đế Chế, có minimap, đệ tử đến nơi tự đánh; nhiều đệ tử có thể cùng bãi.** Không phải “Thanh Trúc Lâm là một trong 12 bãi” hay “tổng map chỉ 40 quái”. 20 bãi là ví dụ thiết kế cho Thanh Trúc Lâm, không khóa 20 bãi cho mọi bản đồ.
**Authority:** owner > docs/GAME_SYSTEM_ARCHITECTURE.md > subsystem specs > current code. Main SHA ở lúc lập nghiên cứu: 29b5fba448b0178cb520a4ada44b375b4b934e31. PR29 S1 OPEN/DRAFT HEAD 9522812e91b7ca5bc0cc108eb92e000e930fe850, QA chính thức vẫn PENDING ở thời điểm kiểm tra.
**Kiểm tra mã thật:** godot/src/simulation/combat/hunting_map_v2.gd, map_battle_v2.gd, hunting_pve_run_v2.gd, docs/COMBAT_SKILLS_V2_SPEC.md, docs/CULTIVATION_PATH_V2_SPEC.md, godot/src/presentation/p3/{map_battle_world_layer_v2,sect_map_camera}.gd, labs/env02a/scripts/env02_world.gd; đọc đề xuất trước tại nhánh docs/huntworld-20-camps-200-400-mobs-rts-review-20261024.

### Phân loại rõ mức độ
- **[CODE VERIFIED]**: sự tồn tại/công thức trong GitHub đã đọc; không tự khẳng định Godot tests PASS.
- **[V2 LOCKED]**: Combat V2, 1 Active Job, Injury 0/1/120, warehouse/Save/canonical receipt exactly-once, Chủ Đạo mềm, 1 thường+4 chủ động+6 bị động, Source A visual.
- **[OWNER DESIGN INTENT]**: 20 bãi trong một map như ví dụ, 10–20 con/bãi, 30 đệ tử/map, RTS mouse input/minimap/auto-farm.
- **[PROPOSED MAP CONTENT]**: map extent, coordinates, paths/bridges, camp labels, exact 300 allocation, aggro radii, respawn rule and boss schedule; NOT approved by owner.
- **[UNRESOLVED]**: khó per-map hay per-bãi, respawn economy and exact drop chance, portal/collision geometry, Boss event cadence, phone performance.

## 1. Ba tầng dữ liệu — Map ≠ Camp ≠ Encounter
\`\`\`text
TÔNG MÔN / WORLD
  ├─ thanh_truc_lam (một map instance săn quái liên tục)
  │   ├─ C01…C20 (20 camp/spawn areas, không phải 20 map scenes riêng)
  │   ├─ giao thông đi bộ/chướng ngại/điểm qua suối, vùng tuần tra và boss
  │   ├─ cùng một sổ world actors: 30 disciples + 200–400 monsters
  │   ├─ cùng HP/status/casts và một kill journal, no copied Boss
  │   └─ minimap/camera đọc tọa độ của world instance
  ├─ bach_thach_khe (map thứ hai, số camp chưa quyết định)
  └─ hac_phong_coc  (map thứ ba, số camp chưa quyết định)

Camp Cxx: vùng nội dung + spawn_slot đăng ký + anchor + aggro + patrol/leash
Monster instance: actor_id + origin camp + spawn_slot + generation + HP/status
Disciple: một HUNT job + FarmArea/MOVE/FOCUS/RETREAT command đang hiệu lực
\`\`\`
Một con quái đang đi qua ranh giới hai camp vẫn là một actor duy nhất. “Camp sở hữu slot xuất hiện”, không phải “camp sở hữu một bản combat private”. Phần thưởng do death receipt và Warehouse/CARE canonical xử lý; camera không sở hữu dữ liệu nào.

### Những giới hạn trong code hiện tại
- [CODE VERIFIED] \`HuntingMapV2.REGION_CONTENT["thanh_truc_lam"]\`: realm 1/tầng1 nguồn ban đầu; quái thường \`truc_thu:0.65\`, \`thanh_lang:0.30\`, \`hac_lang:0.05\`; Tinh Anh \`nham_giap_thu\`, Boss \`hac_lang_vuong\`; tài nguyên hiện ghi \`linh_moc:3\`, \`thanh_thiet:1\`, \`thanh_linh_thao:1\`; vật liệu hiếm \`linh_tuy\`. Đây là dữ liệu vùng của **encounter pilot**. Đừng biến \`resources\` này thành thưởng *mỗi con chết*.
- [CODE VERIFIED] \`MapBattleV2\`: một trận cục bộ 36×20 đơn vị, tối đa 30 disciple và 40 monsters, một party ≤6, STEP_SECONDS=0.25, MAX_SECONDS=90 cho finite battle, generic AoE cap3. 40 **không phải** cap world mới.
- [CODE VERIFIED] \`HuntingMapV2.LEVELS.count=3/4/5/6/7\` là số quái **mỗi lần sinh trận**, không phải số bãi hoặc số quái ở Thanh Trúc Lâm.
- [CODE VERIFIED] \`HuntingPveRunV2\` thắng trận để nhận thưởng: không tương thích trực tiếp farm hàng giờ nhận vật phẩm theo từng quái, cần sau này thiết kế continuous single-death settlement riêng.
- [CODE VERIFIED] ENV02A \`WORLD_GRID=192×192\`, \`CHUNK_CELLS=16\` thuộc **preview map tông môn**; không có căn cứ mặc định map săn bằng192×192 hoặc phải dùng cùng pixel-to-cell. \`SectMapCamera\` là camera presentation 1280×720 và viewport, không phải minimap/farm commands.

## 2. Bản đồ logic đề xuất — geometry mẫu, KHÔNG phải world đã code

**[PROPOSED]** Không gian thiết kế 256×192 **nav/grid cells**; chỉ dùng để biểu đạt tọa độ cắm bãi và tuyến đi trước khi có tileset/terrain thực. Origin (0,0) góc Tây Bắc, +X sang Đông, +Y xuống Nam; thửa bãi nằm trong vòng r~10–14 cell, các bãi cách nhau ngang48/dọc40 cell để không trộn spawn, nhưng corridor có thể giao nhau. Chỉ số tile/độ cao/địa hình có thể đổi sau khi thử ảnh Source A và Android. Chunk16 là ứng viên index, không tự đồng nghĩa ENV02A16.

### Sơ đồ 20 camp: 5 cột × 4 hàng (bảng topology, không phải tường hình vuông)
\`\`\`text
                    TÂY / LỐI VÀO         RỪNG TRÚC        BỜ TÂY SUỐI    BỜ ĐÔNG SUỐI     ĐƯỜNG SÓI ĐÔNG
  BẮC        C01 ───────── C02 ───────── C03 ====CẦU BẮC==== C04 ───────── C05
               │             │             │                    │              │
  TRUNG BẮC C06 ───────── C07 ───────── C08  ~~ SUỐI ~~  C09 ───────── C10
               │             │             │                    │              │
  TRUNG NAM C11 ───────── C12 ───────── C13 ====CẦU GIỮA=== C14 ───────── C15 ─── LÃNH ĐỊA BOSS*
               │             │             │                    │              │
  NAM        C16 ───────── C17 ───────── C18 ====CẦU NAM==== C19 ───────── C20

 CỔNG/ĐIỂM TẬP KẾT: (12,96), nối C11 và C06 bằng tuyến vào.
 *Boss arena = vùng mở trong cùng map, không phải scene/HP pool thứ hai.
\`\`\`
- Các đường C01–C02… theo hàng và C01–C06–C11–C16… theo cột là **đường/quan hệ điều hướng**, không khẳng định mọi đoạn thẳng là lối đi trống; có đường vòng, lùm trúc và đá.
- Suối giả định dọc x≈148. C08→C09 là **cạnh bị chặn**, phải đi qua cầu Bắc (C03–C04), Giữa (C13–C14) hoặc Nam (C18–C19). Tổng **31 cạnh grid tiềm năng −1 cạnh băng suối thiếu cầu =30 cạnh đi lại** (16 ngang +15 dọc −1), trước khi chi tiết hóa chiều rộng đường. Thêm cổng nối C11/C06 và nhánh Boss; đường graph vẫn liên thông.
- [PROPOSED] Chỗ hẹp/cầu có chiều rộng cho ít nhất nhiều đệ tử đi qua không chiếm cùng điểm, nên thử tránh va chạm với đội 6 người; không để path lock khi 30 người được lệnh tập trung Boss.
- Vùng Bắc bạt trúc/sườn đất nhẹ; vùng Tây lối an toàn; Trung suối ẩm; Đông đường sói và gò đá; Nam rừng già/đá; địa hình là **định hướng art/nav**, KHÔNG tự tăng tỉ lệ drop/kháng hệ Mộc/Thủy. Elevation/LOS chỉ thành gameplay khi được duyệt.

### Tọa độ + quái sống dự kiến từng bãi
**Cột vị trí chuẩn x:** [28, 76, 124, 172, 220]. **Hàng y:** [24, 64, 104, 144]. **N** là quái thường sống lúc trạng thái full/cooldown hoàn tất, không phải cap toàn map vĩnh viễn. Các tên bãi chỉ là PLACEHOLDER (không thêm lore canon).

| Camp | Center cell | Tên tạm / cấu trúc | N | Trúc Thử | Thanh Lang | Hắc Lang | Anchor / route |
|---|---|---|---:|---:|---:|---:|---|
| C01 | (28,24) | Cửa Rừng Trúc — lối thoáng | 10 | 7 | 3 | 0 | từ C06/C02 |
| C02 | (76,24) | Trúc Non — đường phẳng | 11 | 7 | 3 | 1 | C01/C03/C07 |
| C03 | (124,24) | Bờ Cầu Bắc — ngã ba | 12 | 9 | 3 | 0 | C02/C08/cầu Bắc |
| C04 | (172,24) | Bờ Đông Bắc — ven đá | 13 | 8 | 5 | 0 | C03/cầu Bắc/C05/C09 |
| C05 | (220,24) | Đồi Sói Non — đường cao | 14 | 9 | 4 | 1 | C04/C10 |
| C06 | (28,64) | Rặng Trúc Tây — lối từ cổng | 15 | 11 | 4 | 0 | C01/C07/C11 |
| C07 | (76,64) | Lòng Rừng — bụi trúc | 16 | 10 | 4 | 2 | C06/C08/C02/C12 |
| C08 | (124,64) | Mép Suối Tây — cụt bên suối | 17 | 11 | 5 | 1 | C03/C07/C13; **không nối trực tiếp C09** |
| C09 | (172,64) | Lạch Đá Đông — đường hẹp | 18 | 11 | 5 | 2 | C04/C10/C14 |
| C10 | (220,64) | Đường Hắc Lang — tuyến nguy hiểm | 19 | 12 | 5 | 2 | C05/C09/C15 |
| C11 | (28,104) | Lối Trung Tây — gần cổng | 20 | 13 | 6 | 1 | cổng/C06/C12/C16 |
| C12 | (76,104) | Trúc Già — vùng tán che | 19 | 12 | 5 | 2 | C07/C11/C13/C17 |
| C13 | (124,104) | Cầu Giữa — điểm tụ đội | 18 | 11 | 5 | 2 | C08/C12/C14/C18 |
| C14 | (172,104) | Bờ Đông Giữa — ngã rẽ | 17 | 11 | 5 | 1 | C09/C13/C15/C19 |
| C15 | (220,104) | Ngả Boss — cảnh báo | 16 | 10 | 6 | 0 | C10/C14/C20/Boss approach |
| C16 | (28,144) | Mộc Cổ Tây Nam — lối thấp | 15 | 11 | 4 | 0 | C11/C17 |
| C17 | (76,144) | Thảm Trúc Nam — rừng già | 14 | 9 | 5 | 0 | C12/C16/C18 |
| C18 | (124,144) | Cầu Nam — giao thông | 13 | 8 | 5 | 0 | C13/C17/C19 |
| C19 | (172,144) | Đá Trúc Nam Đông — ven đá | 12 | 8 | 4 | 0 | C14/C18/C20 |
| C20 | (220,144) | Đồi Canh Lang — cửa phía Đông | 11 | 7 | 4 | 0 | C15/C19 |
| **TOTAL** | **20 camps** | **300 quái thường ở mức full** | **300** | **195** | **90** | **15** | **65% / 30% / 5%**, khớp đúng trọng số nguồn ở quy mô thiết kế này |

**Cảnh báo số học:** Đây là một cách chia NGUYÊN số hợp lệ để minh họa pool trọng số 0,65/0,30/0,05, **không có nghĩa mỗi camp bị khóa những số loài đó**. Runtime sau này nên chọn loài theo source-weighted RNG có seed/provenance, bảo toàn xác suất dài hạn; không buộc mỗi map sinh ra đúng 195/90/15 trong một roll random. Nội dung có Tinh Anh/Boss sẽ thay slot hoặc cộng sự kiện theo policy được phê duyệt, thay đổi số normal thực tế. Số N=10..20 tính tổng chính xác 300; điều kiện 200 có thể đặt 10 trên mọi camp, điều kiện 400 là20 trên mọi camp.
**Bãi nào nguy hiểm không quyết định chỉ bằng N:** vị trí, loài, đường về, mật độ aggro, kỹ năng Elite và bầy sói mới quyết định; không bịa ra stat multipliers cho bãi C10 từ tên gọi.

## 3. Đường kết nối, pathfinding và camera
- [PROPOSED] §RoadGraph(map_id,waypoint_id,from,to,walk_cost,clearance,blocked_by,bridge_id)§; authored camp center -> safe rally anchor -> 1–3 external waypoints -> walkable nav graph. Navmesh/grid and road graph serve different levels; world coordinate conversion from Source A is required before CODE.
- Commander selects disciple(s), issues §MOVE§, §ATTACK_MOVE§, §FARM_AREA(camp_id)§, §FOCUS_TARGET§, §HOLD§, §RETREAT§. A right click on an ordinary monster means focus, on a camp means assign farm, and on empty ground means move if in current tool mode. Mouse drag for camera must not steal right-click order; Android tap/drag has separate policy.
- Squad6 formation: path through bridge(s), local separation/arrival queue, then fan out to valid camp points; not all six teleport onto one cell. Camp assignment can contain multiple independent disciples and/or a party; combat buffs obey actual radius/party conditions, not magical whole-map effect.
- Click minimap defaults CAMERA PAN only. Special assign mode lets player dispatch to Cxx, highlights current selected disciple/team, assigned camp, path preview, Boss location when discovered, HP warnings. Plot 20 camp anchors, visible/known mob clusters, up to30 allied dots, current camera rectangle and safe routes. Fog/reveal not presumed solved.
- World render chunk culling and minimap downsampling affect ONLY visuals. Cross-chunk actor, missile and aggro stay one identity.

## 4. Quái mỗi bãi: spawn, patrol, aggro, pack, leash — parameterized and safe

### 4.1 Static CampDef
\`\`\`yaml
map_id: thanh_truc_lam
camp_id: ttl_c07
center: [76,64]           # nav cells, DRAFT
nav_region_ref: C07        # not a sealed fight
footprint_radius_cells: 12 # candidate, not LOCKED
base_spawn_slot_count: 16 # per-table, varies by camp
spawn_species_weights: {truc_thu: 0.65, thanh_lang: 0.30, hac_lang: 0.05} # SOURCE
patrol_waypoints: authored_world_nav_positions # future
aggro_profile_id: ttl_common # policy source, not a new global stat rule
leash_profile_id: ttl_local
difficulty_context: map_selected_level
elite_event_source: regional_event_scheduler
boss_spawn_source: map_unique_event
safe_rally_point: authored nav cell
respawn_profile_id: ttl_slot_regen_pending
\`\`\`
Static definition does NOT store current HP, proc chance, loot balance, position of monster that wandered out, or duplicate wallet. Those belong to persistent world runtime / Combat V2 and CARE.

### 4.2 Per-monster FSM
\`SLOT_AVAILABLE -> SPAWNED_IDLE -> PATROL -> ALERT/AGGRO -> CHASE -> ATTACK/CAST -> RETURN_LEASH -> PATROL\`; if HP0 \`DEAD_SETTLEMENT_PENDING -> RESPAWN_WAIT -> SLOT_AVAILABLE(new_generation)\`.
- Original camp ID remains stable while alive actor crosses into another camp. Aggro target chosen from nearby legal disciples; if no valid target, patrol/rest, do not global nearest across entire world.
- At most one active instance per spawn slot/generation; retry idempotent. Same monster cannot be paid again because camera switched or another disciple got last hit.
- §AggroRadius§ determines detection; §ChaseLeashRadius§ max distance from home anchor/area for normal mob before returning; §AssistPackLimit§ constrains how many linked mobs join a pull. All need content-dependent override for elites/bosses.
- Illustrative **TEST PROPOSAL ONLY:** small neutral Trúc Thử aggro 4 cells; wolves 6; normal chase limit12, leash boundary16 from camp center; normal assist pack2–3. **No gameplay numerical lock** and units cannot be assumed to work before real map dimensions, range and nav/visual conversion are tested. A mob can notice a close combat event but does not aggro the entire 20-mob camp at once by default.
- No invisible teleport/resetHP when reaching leash border. [OPEN] whether returning mob gradually heals or preserves HP; if it heals, no healing loop exploitable for mastery/loot credit. Leash crossing across bridge and stuck path has deterministic timeout/recovery policy, not a forced domain kill.
- Projectile/AoE target query uses real WorldCombat source in nearby spatial buckets; skill-defined target cap, not all nearby alive 20 by default. An ally healer cannot heal across 20 camps when its skill range is local.

### 4.3 Spawn/respawn and conservation
Per slot: §{map_instance_id,camp_id,slot_id,spawn_generation,current_actor_id|null,next_spawn_tick,pending_kill_receipt_id|null}§.
For kill K at tick t: settle damage/HP0 exactly once → emit \`kill_id=map_instance:camp:slot:generation\` → authoritative reward item decision source/seed with canonical Warehouse/CARE receipt → mark slot waiting until \`next_spawn_tick=t+respawn_ticks\` (numeric design OPEN) → new generation only after state barrier and gate; if stock/backpressure blocked, preserve pending transaction, **never reroll reward**. Offline catch-up uses same logical scheduled sequence, not fake per-hour kill payouts.
- **No free rewards** for a slot that is scheduled to spawn; no arbitrary EXP per idle tick, no multiple kill from DoT+projectile crossing.
- Respawn duration is **NOT locked** by existing \`HuntingMapV2\` (which has no persistent camp slots). [OPEN] define one time range by mob group, tune to real DPS and 30-disciple distribution; values cannot be asserted from previous encounter code.
- §LiveCount§ vs §SlotCapacity§ vs §RespawnPending§ vs §EliteBossLive§ shown distinctly in debug/minimap. If 300 is designed spawn capacity and many were killed within same refill window, real live actors can be 271, not magically maintained exactly at300 with zero delay.

## 5. Elite and Boss: one living world, shared targeting/loot, no explosion

### 5.1 Facts in current source
- Thanh Trúc Lâm base elite \`nham_giap_thu\`, Boss \`hac_lang_vuong\`. FIVE levels use per-encounter \`elite_chance\`, \`boss_chance\`, \`min_elites\` when \`HuntingMapV2.spawn()\` creates a 3–7 monster encounter. Boss replaces slot0 when chosen; elite occupies slots1/3; L1/L2 Boss cancels optional Elite.
- **These percentages are per ENCOUNTER, rolled one time.** Do not reinterpret “8% Boss” as per monster kill, per 0.25 second step, per camp or per respawn, else 20 camps will mint dozens of Boss encounters or flood inventory.

### 5.2 Candidate design for a continuous world (NOT locked)
- **Normal:** 20 camp slot generators as above.
- **Elite roaming event:** a bounded \`EliteWaveEvent\` selects an eligible camp/sector and **replaces a designated normal slot** with Nham Giáp Thú **or** uses explicit dedicated event slot and updates true live count. Enforce per-map alive quota and spawn cooldown/dedup. [OPEN] number concurrently alive, event chance, cooldown, power; can't just lift per-encounter values.
- **Boss:** one \`BossSpawnEvent\` per map instance and event generation with a reachable approach near the C10/C15 east path (illustrative \`boss_anchor=(238,86)\`), only one current \`hac_lang_vuong\` actor, one HP bar and one kill identity. Players can recall up to30 disciples across camps into the same open fight if game permits; map does NOT create Boss copy for each party/camp. Boss alert in minimap if discovered/announced.
- **Participation:** actual DPS/tank/heal/support evidence, no last-hit ownership, single Sect pool and personal TuVi events according to B3 owner choices; 60/40 ratio is **NOT locked**; no per-camp private prize counter.
- **Control:** boss explicit CC refractory, DoT, guard, area telegraph and target caps with authored curves; 30 casters cannot freeze forever just because each owns a passive. No Boss drop until HP0 actual and unique receipt committed.
- **No invented event schedule:** source has no 20-camp global Boss scheduler. Need owner approval for event frequency, reset conditions, boss gate visibility and whether event slot is additive/replacement. A guaranteed L5 Boss encounter doesn't mean “one Boss alive in every bãi”.

## 6. FIVE EXISTING DIFFICULTY LEVELS — exact code baseline, mapping decisions separately

Current \`HuntingMapV2.LEVELS\` (PILOT NUMBERS; **not newly locked**):
| Level | Source name | HP multiplier | ATK multiplier | DEF multiplier | Reward factor per victory | Rare chance per victorious encounter | Encounter mob count | Optional elite roll | Boss roll per encounter | min_elites |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | Ngoại Vi | 0.75 | 0.82 | 0.88 | 1.00 | 0.00 | 3 | 0.06 | 0.01 | 0 |
| 2 | Thâm Nhập | 1.00 | 1.00 | 1.00 | 1.35 | 0.03 | 4 | 0.14 | 0.03 | 0 |
| 3 | Hung Địa | 1.40 | 1.18 | 1.12 | 1.80 | 0.08 | 5 | 0.30 | 0.08 | 1 |
| 4 | Hiểm Địa | 1.95 | 1.40 | 1.27 | 2.50 | 0.16 | 6 | 0.65 | 0.16 | 1 |
| 5 | Tuyệt Địa | 2.70 | 1.65 | 1.45 | 3.50 | 0.26 | 7 | 0.00 | 1.00 | 2 |

### 6.1 Critical interpretation of actual code
- \`choose_level(state,region_id,level)\` persists **one selected level per region ID** in \`state.sect.v2_pve_selected_levels[region_id]\`; not 20 separate camp levels. \`valid_choice()\` checks \`REGION_CONTENT\` and five \`LEVELS\`.
- \`spawn()\` rolls Boss once, starts \`elite_count=min_elites\`, maybe +1 elite on its separate chance; L1/L2 with Boss forces elites0. For L3–L5 the required elite monsters occupy source slot positions1 and3. L5 \`elite_chance=0\` but \`min_elites=2\`, so L5 **does have 2 guaranteed Elites and 1 guaranteed Boss in the 7-mob encounter**. \`overview()\` reports elite encounter presence=1 when \`min_elites>0\`. Don't call L5 elite probability0.
- \`rare\` rolls per **victorious encounter**, and \`preview_reward\` applies a scalar to existing resource quantities per victoriously **completed battle**. \`LINH_TUY_GUARANTEE_WINS=4\` is an old per-victory 4-event guarantee in Thanh Trúc Lâm, not 1 Ling Tuy per fourth monster kill.
- These values are **PILOT**, not immutable balance for 300 simultaneous mobs. Only copied here for review; **ZERO rebalancing and ZERO runtime edits** authorized.

### 6.2 Recommended WORLD-mode choice: selected level PER MAP + 20 camps with topology-specific danger
**[PROPOSAL, consistent with current per-region selection]** Owner chooses difficulty at the entry/safe interface for **Thanh Trúc Lâm instance**, with one value 1..5 applying monster HP/ATK/DEF scaling throughout its 20 camps. Camps differ naturally by species weighted selections/aggro/elite hotspots/terrain/route distance; do **not** assign secret independently selected L1..L5 per camp.
- This retains the intuitive idea “Ngoại Vi version of Thanh Trúc Lâm”, “Tuyệt Địa version of Thanh Trúc Lâm” without spinning up five different copies *inside one map*. Entering/switching map difficulty while 30 disciples are mid-cast is **not permitted without a safe transition specification**: candidate rule return/reassemble at Sect or map exit, finalize pending deaths/receipts, then change map selected grade. Whether this should be a separate world instance or a reset of same map is [OPEN].
- Only **stat multipliers** could be candidates for direct port to world monsters, provided MonsterCatalogue base stat sources match and double scaling is guarded. Existing \`count=3..7\` cannot determine spawn-camp sizes. The **reward factor and rare chance are encounter-specific** and require a new B3 per-kill/item source contract (no duplication). Existing elite/Boss probabilities need a new event frequency/budget policy, **not direct multiplication by 20 camps**.
- **If the owner instead wants “each camp has its own 5 difficulties”**, that is an explicit newer design override to \`selected_level(region_id)\`, with extra persistence/UI and economy implications, not assumed from this plan.
- Regional level chosen by player is distinct from **authored camp threat** (wolf density/terrain). Some camp may be dangerous even in Ngoại Vi, but base monsters still use the global selected-level factors.

### 6.3 Level-specific WORLD event sketch — proposal to review, NO numbers
- L1/L2: rare Boss event should be visible but not gated out forever; actual spawn-once event probability/frequency UNKNOWN, preserve “not impossible” philosophy from source. L1/L2 Boss/Elite overlap policy needs explicit proposal if zero double spikes desired.
- L3/L4: Elite guaranteed at least one in *old encounter*. World-mode **candidate** guarantee at least one during a validated eligible map event/episode, not one per camp or tick; extra optional Elite is bounded by alive cap.
- L5: Boss is guaranteed in a **qualifying authored Boss cycle**, with 2 guaranteed Elites **per qualifying encounter/event group**, not 20 Boss every time mobs refill. [OPEN] how and when those cycles start/renew and how rewards are priced across prolonged fights.
- Stages above only illustrate semantic mapping; ***no automatic equivalence with old probabilities exists*** without defining the denominator for continuous time/kill count.

## 7. Thirty disciples, twenty camps — multiple farm at same camp
**[PROPOSED test distribution]** Camps C01…C10 receive **two** disciples each =20; C11…C20 receive **one** each =10; 30 total. In a true Sect there may be teams of six for boss/escort, but individual assignment supports spreading out. A 6-person team is a formation/party grouping, **not six NPCs welded onto one shared movement coordinate**. Parties may be split into distinct camps if the policy permits, though their buffs/heals only work in real proximity.

A rough team roster example (not additional units): P1 D01–D06 assigned 2/camp to C01–C03, P2 D07–D12 assigned C04–C06, P3 D13–D18 C07–C09, P4 D19–D24 C10×2 and C11–C14×1, P5 D25–D30 C15–C20×1. Team grouping and camp assignment are two independent dimensions.
- Same camp with two disciples: separate target selection with optional focus/assist policy; both can strike **one** mob with one HP and one reward, meaningful support can heal allied eligible nearby actor; if both hit different mobs, no invented loss of loot.
- Owner can rally some/all 30 to regional Boss via orders. Prior farm jobs must be updated idempotently; shared Boss HP and each contribution ledger remains one. After Boss die, policy may return original camp orders if explicitly saved; otherwise order changes remain until owner acts.
- A lone disciple should not “auto-aggro all 20” just because they belong to same camp. Aggro radius and pack cap plus escape thresholds are separate parameters. Farm area selection includes safety policy if character much weaker than chosen camp.
- If same player issues simultaneous commands to 30, validator returns per-actor accepted/refused reasons, e.g. Injury1, one active job production conflict, disconnected path. No fictional teleport or auto farm when prohibited.
- Camp contains **persistent 10–20 spawn slots**; may temporarily have fewer live due to respawn. Assignment is stable, so disciple waits/roams within area rather than wandering cross-map hunting unassigned spawns.

## 8. World sim + rendering performance contract for 300 live monsters
- **Owner scale**: 30 active disciples, 200–400 live mobs *within one map*; 600 is a separate stress test only. Sect long-term 1000–3000 mostly elsewhere; do not spawn them all in one map.
- **World authority:** one current world actor register and stable spawn generation; one canonical Combat V2 damage/resistance/HP and status path; position and nav across all20 camps; one global Boss actor and kill receipt. Independent local MapBattleV2 mini-arenas risk cross-boundary duplicated HP; simply raising MAX_MONSTERS from40 to400 won't solve it.
- **Spatial index** nav/aggro/area targeting queries only neighboring buckets; no full scan all230–430 actors for each living actor every 0.25 s. A naive worst-case whole registry comparison grows as N²; actual performance unknown until measured.
- **AI tiers**: engaged actors/casts/status due at exact canonical sim steps; idle monster patrol is scheduled at lower cadence only if gameplay parity preserved, independent of camera visibility; spawn due queue and cooldown queue persisted.
- **Pathfinding**: camp routes/waypoint graph cached; request path upon command/real obstruction/target change; locally smooth motion, deterministic tie-break; don't path 30×every camera frame. Narrow bridge behavior with large squad requires anti-stuck test.
- **Renderer** Source A sprites/atlas and VFX for visible subset; minimap clusters aggregate icon for offscreen mobs, not individual 400 animated nodes. **No gameplay LOD** that substitutes fake enemy death/resource payout. Arena coordinates and ENV02A cell-to-screen conversion aren't interchangeable.
- **Mobile baseline** 1280×720 Android; proof requires real device p95/p99 frame/sim tick/memory/path queue measurements. Windows 8GB PC should be used with bounded tests and no large parallel tasks. Do not claim FPS PASS from design.
- **Save/replay:** selected map difficulty, spawn slots, generations, HP, currently chasing target, 30 assignments and pending path intents/casts/DoTs, Boss HP/status and reward journal all have one writer and within-build snapshot. Owner DEV reset only eliminates cross-build legacy migration, not same-build exact-once correctness.

## 9. Integration dependency order — research/gates, NOT Codex action packet
1. Owner reviews/corrects **ONE MAP WITH 20 CAMPS** topology vs true terrain shapes, 256×192 PROPOSED nav extent and density 10–20 per bãi.
2. Decide whether 300 living monsters “full-supply cap” includes Elite/Boss substitution or allows extra event slots; each rarity frequency and exact respawn time later balance design, no universal guessed fixed number.
3. Approve use **one map-selected difficulty** 1..5, clarify transition from battle-per-encounter odds to world event scheduler and from reward-per-victory to authentic reward-per-kill / CARE. Don't silently keep \`rare=26%\` per killed mob.
4. Approve canonical one-world actor registry and navigation/roads/path obstruction behavior; preserve Combat V2 hit math; decide if map has continuous zone ownership when multi-map/world expands.
5. Review desktop mouse right-click select/attack/farm and right-drag pan conflict, Android touch minimap and Source A rendering with UI owner on an independent future design.
6. Establish same-build snapshot/CARE/OneActiveJob/injury gates and finite benchmark sequence.
7. **Only then**, upon separate owner CODE approval and coordination with Codex PR29 writer, produce constrained packet, allowed files and official Godot4.7.2 focused tests. This document explicitly does **NOT** do so.

### Proposed future design verification checklist (NO tests run)
- T01 static table integrity: 20 unique IDs, 20 reachable nav anchors, sum 300, 195/90/15 demonstration, no more than20 slot/camp, all centers in 256×192 candidate rectangle.
- T02 source parity: selected_level(region_id) and five difficulty exact HP/ATK/DEF/yield/rare/boss/elite semantics copied without false per-camp re-interpretation.
- T03 route crossing: C08→C09 reroutes via C03–C04 bridge or C13–C14, never crosses blocked creek; 6 units don't permanently jam bridges.
- T04 30 actors assigned as 10×2+10×1; focus selected ones/alternate camp, One Active Job and injury check, manual Auto OFF precedence.
- T05 one camp slot HP0/generation12, two attackers and lingering DoT + projectile: one kill and one warehouse credit, generation13 only after due spawn and committed receipt; 15 slots never create16 live.
- T06 Elite at one of20 camps and Boss near C15: one global world Boss, five teams can participate and re-route, not 20 boss copies or duplicate Sect loot pool.
- T07 offscreen camera/minimap moved repeatedly: identical HP, position, casts, monster registry, kill receipts and Tu Vi for same seed/orders and canonical ticks; only VFX may differ.
- T08 difficulty L5 in old finite encounter is Boss guaranteed + two Elites; future world event must be owner approved separately; avoid per-camp guaranteed Boss.
- T09 200→300→400 monster real sim + 30 disciples on Android/Windows test after code: measure path queries, sim-ms/tick, RAM, render frame time, event journal and save restore; 600 as stretch.
- T10 no old DEV save migration required; same-build replay at pre-hit, post-hit before settlement, pre-respawn, Boss defeat and mid-map path transition exactly once.

## 10. Conclusion, open owner decisions
**Recommended working design:** Thanh Trúc Lâm = one continuous open map with20 authored camps, practical population at300 full spawn slots (ranges 10–20 each), 30 freely commanded disciples, organic roads and three creek crossings, one shared monster HP/CARE authority and map-selected difficulty 1..5. Same camp can host one, two or more disciples. New world scheduler must be authored for respawn/Elite/Boss rather than treating 20 camps as 20 copies of a 7-monster V2 encounter.

**Must not call these locked:** 256×192 map nav extent, camp coordinates/names/species counts, bridge count, aggro/chase/assist radii, precise respawn duration, unique-world Boss event cadence, whether 200–400 includes Elite/Boss, conversion of encounter difficulty chances to continuous time, target Android FPS. All require data/profile/owner decision. No code, no PR29, no UI, no merge.
