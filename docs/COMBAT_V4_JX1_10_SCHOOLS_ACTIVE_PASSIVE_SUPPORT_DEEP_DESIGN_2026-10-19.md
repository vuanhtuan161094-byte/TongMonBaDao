# TÔNG MÔN BÁ ĐẠO — JX1 × COMBAT V4: THIẾT KẾ VÕ HỌC CHỦ ĐỘNG / BỊ ĐỘNG / HỖ TRỢ 10 PHÁI

**Ngày thiết kế:** 2026-10-19. **Trạng thái:** OWNER REVIEW / DESIGN ONLY, NO GAMEPLAY CODE, NO MERGE, NO CI/FULL.
**Source evidence A:** user Drive Võ Lâm Idle, `data.js` (240 definitions), `fx.js` (176 skill→VFX entries; 121 missile templates, 11 other FX templates) and `README.md` (unofficial fan-made research-only, noncommercial notice).
**Source evidence B:** user Drive Giang Hồ Chi Chiến — Community Offline, `data/vltk/faction-coverage.json` (260 IDs, 13 phái, 118 web playable), `data/vltk-fx.json` compressed and JS `native-presentation.js` (cast/launch/impact graph).
**Game authority:** `docs/COMBAT_SKILLS_V2_SPEC.md`, `docs/COMBAT_STATS_V2_SPEC.md`, `docs/CULTIVATION_PATH_V2_SPEC.md`, `docs/REALM_LADDER_V2_SPEC.md`, `docs/DV2_02_GROUP_MAP_COMBAT_CONTRACT.md`, real `godot/src/simulation/combat/{combat_stats_v2,map_battle_v2,disciple_combat_loadout_v2,hunting_pve_run_v2}.gd`.
**Companion:** 330-ID union crosswalk in standalone downloadable archive (generated from both sources, not imported to gameplay). Parent plans in docs branch `docs/combat-v4-integrated-jx1-sourcea-realm-party-plan-20261018`.

## A. NGUYÊN TẮC (HARD LOCKS VS CANDIDATE NUMBERS)

- CombatStatsV2, CombatSkillSystem, MapBattleV2, HuntingPveRunV2, HP/reward/injury/exactly-once and all existing game V2 constraints are authoritative. This document creates **content proposals, not code**.
- Preserve **30 Tu Vi realms ×10 floors and independent 30 Luyện Thể realms×10 floors**. No JX source `req=10/20/30/60` may be misread as Tu Vi realm number; it is MMO source level data.
- A disciple freely chooses JX-inspired school/curriculum even with another birth/root inclination (Model C); only one soft current Chủ Đạo: Kiếm Tu, Thể Tu, Pháp Tu with existing 3 branches each. No class-based experience level. School identity dictates transmission and effect-tag affinity/weapon constraints, not unconditional stat multiplication.
- 1 Thường Kỹ + 4 Active + 6 **combat-trigger/party passive** slots when mature; static personal passives that only contribute registered stat channels are **NOT counted against combat passive slots** (canonical §2.1).
- Legendary signature = **strict owner-exclusive option A**, not teachable/scrapable, occupies existing active slot if active.
- The documented *40 active candidates + 40 passive/alternative source rows* below are examples chosen from source; this is NOT equivalent to 80 implemented skills or a closed content inventory.
- **All numeric damage ratios, cooldowns, timings, stack/duration values here are candidate tuning data, not locked balance.** They are specified concretely so QA can benchmark. Do not silently implement in main.
- Never run untrusted source Windows executables/batches, commit raw ZIPs or treat uploaded files as commercial redistribution rights. Both folders contain JX-related third-party IP; real packaging requires rights clearance.
- V2 by default has no MMO mana/energy bar, no universal JX hit/miss dice, and no automatic school bonus. JX has both physical hit check and mana shield; adapt the gameplay identity through V2 effects rather than copying source engine.

## B. PHÂN LOẠI KỸ NĂNG CHÍNH THỨC TRONG GAME

| Category | Lifecycle/equipping | Skill source examples | Rules |
|---|---|---|---|
| BASIC | 1 skill equipped, evolves per generation | Thiếu Lâm Quyền, Đường Môn ám khí baseline | Performs one direct packet at attack interval; eligible crit and lifesteal as V2 |
| ACTIVE_DAMAGE | 4 slots shared with all actives | Kiếm Phi Kinh Thiên #158, Truy Tâm Tiễn #50 | Explicit cast/launch/hit, target cap and skill ratio; no damage from graphics |
| ACTIVE_CONTROL/DEBUFF | Occupies active slot | Sư Tử Hống #20, Vạn Độc Thực Tâm #73 | Applies effect only on authoritative hit; duration, stack/tiers, Boss resistance |
| ACTIVE_SUPPORT | Occupies active slot | Từ Hàng Phổ Độ #93, Thất Tinh Trận #159 | Heal only effective missing HP, shield absorption real, party_id scope |
| STATIC_PERSONAL_PASSIVE | Learned/owned; no combat-passive slot | Dịch Cân Kinh #21, Thế Vân Tung #160, weapon proficiency | Registered personal stat source only, no runtime trigger/party buff |
| COMBAT_TRIGGER_PASSIVE | 1 of six trigger passive slots | Hộ Thể Hàn Băng #100, Hóa Hiểm Vi Di #129 | Event-triggered with ICD, proper source attribution, cannot recurse indefinitely |
| PARTY_AURA_PASSIVE | 1 of six if active runtime/party | La Hán Trận #16, Võ Đang Thất Tinh (as an authored alternate aura) | Party scope, strength family strongest-only, range/expiry; cannot stack 5-team buff infinitely |
| STATUS/ZONE | Attached to eligible active/trigger, not free slot | Ngũ Độc poison, Côn Lôn lightning, Thúy Yên slow | Owns source_id, snapshot/pulse/cancel metadata; no empty cosmetic statuses |
| PERSONAL_LEGENDARY | Strict owner_id=disciple and declared slot | unique character-only weapon signature | Cannot transmit by any book/manual, copies, reincarnation, tutoring or NPC import |

**Source distinction:** New JX `style` (0/1/2/3) alone is NOT a safe passive/active detector. Read `prop`, `attr`, `aura`, `enemy`, `self`, target geometry, requires, and `JFX` information. Example: new source #91 Phật Quang Phổ Chiếu is an **attack**, #93 Từ Hàng Phổ Độ is **healing**; old source's #93 support is flagged pending JS runtime.

## C. DATA CONTRACT (CANONICAL AUTHORING INTERFACE; DESIGN ONLY)

```text
SkillDefinition:
  game_skill_id, family_id, generation = NHAN|TIEN|THAN, ancestor_id
  source_refs: [{variant_id, skill_id, source_name, file_path, sha256, facts, rights}]
  skill_kind = BASIC|ACTIVE|STATIC_PASSIVE|COMBAT_PASSIVE|PARTY_AURA
  progression_basis = TU_VI|LUYEN_THE|HYBRID; min_realm_floor; required_path/branch
  required_weapon_tags; optional_school_transmission; learned_by, self_comprehended
  requires_manual; learning_time; learned_skill_ownership; mastery_level (5 stages)
  slot_group, mutually_exclusive_family, is_legendary, allowed_owner_id
  tags: combat_element, secondary_advanced_element, physical/magic, attack/heal/guard
  targeting: SELF|ENEMY|ALLY|AREA|LINE|ARC|CHAIN; range, radius, arc, target_cap
  action: cast_time, initial_delay, cooldown, minimum_cd, internal_cd, interruptible
  projectiles: count, spawn_event, velocity, reach, homing, retarget_policy, hit_rule
  damage: ratio_or_heal_scaler, packet_count, eligible_crit, eligible_lifesteal
  effects: source_id, chance, effect_hit, effect_tier, snapshot, expiry, tick_interval,
           stacking_policy, family_cap, party/encounter_scope, cleanse/dispel_level
  AI: slot_priority, conditions, preferred_distance, target_filter, HP/debuff thresholds
  visuals: animation_id, actor_action, cast_vfx, launch_vfx, missile_id, hit_vfx,
           sfx, frame_interval, anchor, draw_priority, max_visible_instances
  QA: source_verified, effect_tested, godot_imported, android_accepted, rights_approved
```

Rules: game skill IDs never equal an external source SkillId by accident; `source_ref` records immutable provenance. Inferences about a missing JX original `SKILLS.TXT` or missile graph remain unverified. Each authored effect demands a real event consumer before a visual cue is marked usable. All scalar skill multipliers affect **an event packet**, not unrelated HP/ATK channels.

## D. DAMAGE / HEAL / STATUS / TIMING SEMANTICS

- **Base stats (live):** `G(r,f)=1.65^(r-1)*1.03^(f-1)` independently for Realm and Body; potential factor `1+0.0005*P`. HP=(100*Gr+90*Gb)*Pfac, ATK=(20*Gr+3*Gb)*Pfac, DEF=(12*Gr+7*Gb)*Pfac, then legal registered flat and % sources. If either realm track differs, don't use a fake averaged school level.
- **Direct packet:** `A * skill_ratio * (2A/(2A+D_eff)) * eligible_crit * element_matchup * (1 - target_element_resistance) * (1-DR)`. Use CombatStatsV2 actual code for exact order/clamps; this is schematic, not a new replacement formula.
- **Ngũ Hành:** Kim khắc Mộc, Mộc khắc Thổ, Thổ khắc Thủy, Thủy khắc Hỏa, Hỏa khắc Kim; favorable ×1.25, unfavorable ×0.85, neutral ×1.0 when existing specific elemental effect qualifies. No JX double bonus from same school's label. Dị căn: Lôi/Phong/Băng/Dương/U Minh consumers are explicit. Personal Tương Sinh is opt-in, party synergy from shared target status, not instant cross-player elemental chains.
- **Critical:** default eligible direct hit only. DoT/reflect/heal/shield/proc and fixed damage cannot crit unless specific approval. Crit chance 5% base, crit damage 1.50×, subject to V2 caps/counters. Lifesteal once from actual capped damage. No extra hit whenever VFX frame changes.
- **Poison candidate:** apply on a true hit; tick at exact 1s intervals, snapshot magnitude at apply; Refresh or Stack N (suggest N=3 preliminary, shared target cap) by explicit `family_id` and source. E.g. independent casters may contribute to same capped stacks, not 5 parties ×3 stacks. A detonate effect consumes authenticated stacks once only and has no lifesteal/crit by default.
- **Burn candidate:** analogous bounded time and source, distinct from Poison; no multiplying with poison except authored combined-effect skill; no recursion.
- **Control candidate:** Slow/Root/Stagger/Interrupt with EffectHit/Resistance; Boss hard crowd control degrades to refractory/soft-control according to V2 tier, no perma-lock. Cleanse respects effect tiers NHAN/TIEN/THAN.
- **Guard/shield:** real absorption and remaining reduction with source_id, not a phantom +DEF; shield expiry/stack family/snapshot. Reflect cannot reflect again or trigger another identical proc without ICD.
- **Heals:** only missing HP counted; no overheal mastery, no revive from ordinary healing; shield contribution tracks absorbed damage. A Legendary revive, if ever authored, needs separate explicit rare skill and encounter-limited gate.
- **One action commit:** cooldown, cast duration, projectile flight and hit event are distinct. V2 step = 0.25s deterministic; animation fps independent. Skill cast may be cancelled before commitment if legal; after commit, outcome is an event, not based on visibility.
- **Multi-hit:** repeated visual sprites (e.g. JX #165 childN=16) do not imply 16 damage hits. `packet_count` and target IDs are authoritative; each has stable (encounter,cast,packet,target) receipt.
- **No global MMO mana**: source mana-cost data are evidence only; cooldown/setup/position/HP conditions are preferred V2. Skills requiring a specific energy system remain PENDING instead of inventing a new universal mana bar.
- **Default AI:** slot1→slot2→slot3→slot4 legal check, then Basic. Avoid global utility AI in first milestone. Condition gates include caster action lock, range, path, target debuff, effective healing, Boss telegraph, setup. Re-target only if declared.

## E. TEN CLASSIC FACTION KITS — CONCRETE BALANCE CANDIDATES

**Numerical convention:** ratio is proposed coefficient of CombatStatsV2 ATK for a *true direct packet*; cast/cd are DESIGN candidates, subject to seed benchmarks; geometry is map logical units. Support effects use explicit unit. Four Active rows are **alternatives** within max four learned equipped slots, NOT free skills at recruitment. Static/passive entries require legitimate learning, and source pending remains pending.


### E1. Thiếu Lâm — Kim

- **Build alignment:** Thể Tu/Kim Cương; optional côn/đao/quyền.
- **JX combat identity to preserve:** Tiền tuyến cứng, phản đòn, áp sát, chấn nhiếp.
- **Active candidate source facts:** names/IDs are backed by Drive; ratio, cooldown, AI and all game mechanics below are authored **proposals**.

| JX SkillId | Active skill | Basis | Geometry | Damage/heal pilot | Cast | CD | Effect/gameplay proposed | Auto-AI condition |
|---:|---|---|---|---|---:|---:|---|---|
| 10 | **Kim Cang Phục Ma** | Hybrid | 1 mục tiêu, cận chiến | 1.10 ATK | 0.25s | 4s | Đòn áp sát có thể nối phá giáp khi target đã có dấu ấn; không tự gây stun | target gần nhất |
| 11 | **Hoành Tảo Lục Hợp** | Luyện Thể | Cung 100°, tối đa 3 mục tiêu | 0.72 ATK/mục tiêu | 0.5s | 7s | Quét côn; tổng nhiều mục tiêu không nhân quá số cap | ≥2 mục tiêu trong cung |
| 20 | **Sư Tử Hống** | Hybrid | Vòng quanh bản thân, tối đa 3 | 0.55 ATK/mục tiêu | 0.5s | 12s | Stagger ngắn, Boss chuyển thành giảm tốc chiêu có kháng | có mục tiêu đang cast hoặc ≥2 kẻ áp sát |
| 318 | **Đạt Ma Độ Giang** | Luyện Thể | Một đích trong đoạn 4.5 đơn vị | 0.90 ATK | 0.4s | 9s | Áp sát có đường đi hợp lệ; dash thật mới bật | khoảng cách >2.5 và không xuyên vật cản |

**Passive / alternate reference and slot separation**:

| JX SkillId | Skill | Classification | Requirement and effect candidate |
|---:|---|---|---|
| 4 | Thiếu Lâm Côn pháp | static/weapon | Tăng hiệu quả võ học côn khi thực cầm côn; không chiếm slot |
| 21 | Dịch Cân Kinh | static | Tăng kháng đã đăng ký; không có miễn nhiễm tuyệt đối |
| 16 | La Hán Trận | combat/party; source pending | Khi dựng trận hợp lệ cấp khiên ngắn party, Strongest Only + ICD; cần engine support |
| 15 | Bất Động Minh Vương | combat self; source pending | Hộ thân dưới ngưỡng HP; chỉ proc theo event & ICD |

**Generation path:** Nhân learns basic attacks/utility; Tiên evolves these specific family effects with bounded additional target/status; Thần adds authored domain/rule interaction constrained by tier, target cap, cooldown and real skill ownership. These successors are **new authored game content**, not authentic source JX titles. Unlocking realm makes study *eligible*, not automatically learned.

### E2. Thiên Vương — Kim

- **Build alignment:** Thể Tu/Bá Thể.
- **JX combat identity to preserve:** Đao, thương, chùy, cường công ổn định và guard tuyến đầu.
- **Active candidate source facts:** names/IDs are backed by Drive; ratio, cooldown, AI and all game mechanics below are authored **proposals**.

| JX SkillId | Active skill | Basis | Geometry | Damage/heal pilot | Cast | CD | Effect/gameplay proposed | Auto-AI condition |
|---:|---|---|---|---|---:|---:|---|---|
| 40 | **Đoạn Hồn Thích** | Luyện Thể | Cận chiến một đích | 1.20 ATK | 0.5s | 6s | Có thể tích một dấu áp chế vật lý theo hit thật | target cận chiến sống |
| 41 | **Huyết Chiến Bát Phương** | Luyện Thể | Vòng quanh caster, tối đa 3 | 0.78 ATK/mục tiêu | 0.6s | 8s | Quần kích vật lý, không lifesteal đa proc mặc định | ≥2 địch trong bán kính |
| 35 | **Dương Quan Tam Điệp** | Luyện Thể | Một địch, 3 hit staged | 0.46 ATK/hit ×3 | 0.75s tổng | 8s | Tính 3 hit có cast_id; proc phụ giới hạn 1/cast | địch trong tầm và đứng được 0.75s |
| 42 | **Kim Chung Tráo** | Hybrid | Self hoặc party cùng đội gần caster | Không sát thương | 0.4s | 15s | Shield/DR 25% trong 4s đề xuất; source web support pending, cần consumer | HP thấp hoặc Boss đang chuẩn bị AoE |

**Passive / alternate reference and slot separation**:

| JX SkillId | Skill | Classification | Requirement and effect candidate |
|---:|---|---|---|
| 23 | Thiên Vương Thương pháp | static/weapon | Tăng võ học thương khi cầm thương đúng tag |
| 36 | Thiên Vương Chiến Ý | static | Nguồn source có lifemax; ánh xạ max_hp kênh hợp lệ |
| 26 | Thiên Vương Chùy Pháp | static/weapon | Giữ tuyến chùy khác thương, không phép cộng phái toàn cục |
| 33 | Tĩnh Tâm Quyết | combat self; source pending | Sẵn sàng tự vệ sau khi chịu đòn đáng kể; ICD cần authored |

**Generation path:** Nhân learns basic attacks/utility; Tiên evolves these specific family effects with bounded additional target/status; Thần adds authored domain/rule interaction constrained by tier, target cap, cooldown and real skill ownership. These successors are **new authored game content**, not authentic source JX titles. Unlocking realm makes study *eligible*, not automatically learned.

### E3. Đường Môn — Mộc

- **Build alignment:** Kiếm Tu/Sát Kiếm hoặc Pháp Tu/Huyền Pháp; binh khí ám khí riêng.
- **JX combat identity to preserve:** Ranged burst/poison, ưu tiên mục tiêu, rải phi tiêu và bẫy.
- **Active candidate source facts:** names/IDs are backed by Drive; ratio, cooldown, AI and all game mechanics below are authored **proposals**.

| JX SkillId | Active skill | Basis | Geometry | Damage/heal pilot | Cast | CD | Effect/gameplay proposed | Auto-AI condition |
|---:|---|---|---|---|---:|---:|---|---|
| 50 | **Truy Tâm Tiễn** | Tu Vi | Projectile đơn đích | 1.15 ATK | 0.35s + bay | 5s | Có đánh dấu địch; chờ hit event thực mới proc | ưu tiên địch thấp HP ngoài tầm cận |
| 54 | **Mạn Thiên Hoa Vũ** | Tu Vi | Quạt 3 projectile, mỗi mục tiêu tối đa 1 hit nếu không multi-hit authored | 0.70 ATK/mục tiêu | 0.55s + bay | 9s | Đa đạn có collision/target cap; không damage ×3 trên một đích ngẫu nhiên | ≥2 địch nằm trong cung |
| 58 | **Thiên La Địa Võng** | Hybrid | Zone/bẫy 2.5 đơn vị, cap 3 | 0.45 ATK khi kích nổ | 0.6s | 13s | Chậm 2s; tối đa 1 trap hoạt động/caster bản pilot | chặn đường Boss/elite hay nhóm quái |
| 249 | **Tiểu Lý Phi Đao** | Tu Vi | Đơn đích có đường bay dài | 1.65 ATK | 0.55s + bay | 12s | Ưu tiên nạn nhân có mark; execute bonus hữu hạn | target dưới 40% HP hoặc elite |

**Passive / alternate reference and slot separation**:

| JX SkillId | Skill | Classification | Requirement and effect candidate |
|---:|---|---|---|
| 43 | Đường Môn Ám Khí | static/weapon | Đúng loại vũ khí mới tăng projectile accuracy/effect theo schema V2 |
| 48 | Tâm Nhãn | static + optional combat proc | Source có tăng độc/băng; nếu triggered cần slot combat và ICD |
| 303 | Độc Thích Cốt | active alternate | Nội công độc thay slot thứ 4 nếu build poison; không tự chuyển thành passive |
| 47 | Đoạt Hồn Tiêu | active alternate | Đòn ám khí thay cho Truy Tâm Tiễn khi tuyển build |

**Generation path:** Nhân learns basic attacks/utility; Tiên evolves these specific family effects with bounded additional target/status; Thần adds authored domain/rule interaction constrained by tier, target cap, cooldown and real skill ownership. These successors are **new authored game content**, not authentic source JX titles. Unlocking realm makes study *eligible*, not automatically learned.

### E4. Ngũ Độc — Mộc

- **Build alignment:** Pháp Tu/Ngũ Hành hoặc Huyền Pháp.
- **JX combat identity to preserve:** Poison DoT, ngấm độc, kháng độc và nguyền rủa.
- **Active candidate source facts:** names/IDs are backed by Drive; ratio, cooldown, AI and all game mechanics below are authored **proposals**.

| JX SkillId | Active skill | Basis | Geometry | Damage/heal pilot | Cast | CD | Effect/gameplay proposed | Auto-AI condition |
|---:|---|---|---|---|---:|---:|---|---|
| 63 | **Độc Sa Chưởng** | Tu Vi | Projectile đơn đích | 0.75 ATK tức thì | 0.35s + bay | 5s | Đặt độc 3s, tick 1s theo policy source/cap cụ thể (đề xuất) | target chưa có độc hoặc cần refresh |
| 68 | **U Minh Khô Lâu** | Tu Vi | Một mục tiêu trong 5 đơn vị | 1.10 ATK | 0.45s + bay | 7s | Cường công độc, tăng tác dụng nếu target có 2 stack độc | target đã bị nhiễm độc |
| 384 | **Bách Độc Xuyên Tâm** | Hybrid | Một mục tiêu | 1.40 ATK | 0.6s + bay | 11s | Tiêu thụ một stack độc để gây bùng nổ capped 0.60 ATK phụ | khi target ≥2 stack độc |
| 73 | **Vạn Độc Thực Tâm** | Tu Vi | Vòng 2.5 quanh target, cap3 | Không damage | 0.5s | 14s | Debuff giảm kháng độc có trần; web source support pending | khi ≥2 địch chưa trúng debuff |

**Passive / alternate reference and slot separation**:

| JX SkillId | Skill | Classification | Requirement and effect candidate |
|---:|---|---|---|
| 62 | Ngũ Độc Chưởng Pháp | static | Tăng hiệu quả kỹ năng chưởng độc với kênh hợp lệ |
| 75 | Ngũ Độc Kỳ Kinh | static/weapon-root | Nguồn tăng poison effect; không mang độc tính lên hit không phép |
| 69 | Vô Hình Độc | combat/party; source pending | Độc trận aura theo vị trí/party có ICD & cap; không tự động gây vô hạn |
| 66 | Tạp Nan Dược Kinh | static | Kháng độc cá nhân, không miễn nhiễm |

**Generation path:** Nhân learns basic attacks/utility; Tiên evolves these specific family effects with bounded additional target/status; Thần adds authored domain/rule interaction constrained by tier, target cap, cooldown and real skill ownership. These successors are **new authored game content**, not authentic source JX titles. Unlocking realm makes study *eligible*, not automatically learned.

### E5. Nga Mi — Thủy

- **Build alignment:** Pháp Tu/Y Đạo hoặc Kiếm Tu/Hộ Kiếm.
- **JX combat identity to preserve:** Điều trị hiệu dụng, bảo vệ, giải độc và tấn công băng.
- **Active candidate source facts:** names/IDs are backed by Drive; ratio, cooldown, AI and all game mechanics below are authored **proposals**.

| JX SkillId | Active skill | Basis | Geometry | Damage/heal pilot | Cast | CD | Effect/gameplay proposed | Auto-AI condition |
|---:|---|---|---|---|---:|---:|---|---|
| 80 | **Phiêu Tuyết Xuyên Vân** | Tu Vi | Projectile đơn đích | 1.00 ATK | 0.4s + bay | 5s | Đòn băng có khả năng đặt Hàn Ấn nếu đã có consumer | khi không có đồng đội cần chữa |
| 91 | **Phật Quang Phổ Chiếu** | Tu Vi | AoE tâm mục tiêu, tối đa 3 | 0.82 ATK/mục tiêu | 0.7s | 10s | Sát thương băng diện rộng, NGUỒN KHÔNG PHẢI heal | ≥2 kẻ đứng gần nhau |
| 93 | **Từ Hàng Phổ Độ** | Tu Vi | Một đồng minh sống cùng party trong tầm6 | 1.35 ATK effective heal | 0.5s | 6s | Heal không overheal, không hồi sinh; source mới có lifereplenish_v, source cũ pending | HP đồng đội dưới 65% |
| 282 | **Thanh Âm Phạn Xướng** | Tu Vi | Đồng minh cùng party | Không damage | 0.5s | 13s | Xóa 1 debuff đúng effect tier; support source web pending | có debuff đủ điều kiện để cleanse |

**Passive / alternate reference and slot separation**:

| JX SkillId | Skill | Classification | Requirement and effect candidate |
|---:|---|---|---|
| 77 | Nga Mi Kiếm Pháp | static/weapon | Hiệu lực khi dùng kiếm; không tự cấp hồi máu |
| 252 | Phật Pháp Vô Biên | static | Gia tốc đánh/thi pháp và băng khi đúng phạm vi nguồn |
| 86 | Lưu Thủy | combat/party aura; pending | Movement buff party hữu hạn thời gian/cự ly; Strongest Only |
| 92 | Phật Tâm Từ Hữu | combat/party aura; pending | Bonus HP tạm thời sau cast hợp lệ; HP ratio preserved |

**Generation path:** Nhân learns basic attacks/utility; Tiên evolves these specific family effects with bounded additional target/status; Thần adds authored domain/rule interaction constrained by tier, target cap, cooldown and real skill ownership. These successors are **new authored game content**, not authentic source JX titles. Unlocking realm makes study *eligible*, not automatically learned.

### E6. Thúy Yên — Thủy

- **Build alignment:** Kiếm Tu/Sát Kiếm hoặc Pháp Tu/Ngũ Hành.
- **JX combat identity to preserve:** Song đao, băng đao, tốc độ, phản kích.
- **Active candidate source facts:** names/IDs are backed by Drive; ratio, cooldown, AI and all game mechanics below are authored **proposals**.

| JX SkillId | Active skill | Basis | Geometry | Damage/heal pilot | Cast | CD | Effect/gameplay proposed | Auto-AI condition |
|---:|---|---|---|---|---:|---:|---|---|
| 99 | **Phong Hoa Tuyết Nguyệt** | Luyện Thể | Một mục tiêu tầm gần | 1.10 ATK | 0.35s | 5s | Đòn vật lý song đao, nhanh và rõ animation | target ngay trước mặt |
| 102 | **Phong Quyển Tàn Tuyết** | Hybrid | Cung phía trước, tối đa 3 | 0.75 ATK/mục tiêu | 0.5s | 9s | Áp Hàn Ấn nếu đã có Hàn status consumer | ≥2 địch hoặc target có slow |
| 111 | **Bích Hải Triều Sinh** | Tu Vi | Cung/đường tầm trung tối đa 3 | 0.90 ATK/mục tiêu | 0.6s | 10s | Băng-thủy wave, không được tự crit nhân mỗi frame VFX | ≥2 địch |
| 336 | **Băng Tung Vô Ảnh** | Hybrid | Đơn đích/trượt vị trí | 1.25 ATK | 0.45s | 11s | Mobility chỉ hoạt động khi path hợp lệ, no map teleport | tránh AoE hoặc tiếp cận vị trí được chọn |

**Passive / alternate reference and slot separation**:

| JX SkillId | Skill | Classification | Requirement and effect candidate |
|---:|---|---|---|
| 95 | Thúy Yên Đao Pháp | static/weapon | Bổ trợ đao khi trang bị đúng loại |
| 114 | Băng Cốt Tuyết Tâm | static | HP/băng hợp lệ, không tạo hai nguồn cộng trùng |
| 100 | Hộ Thể Hàn Băng | combat trigger; pending | Phản damage tại hit hợp lệ, không crit/reflect/proc vòng lặp |
| 109 | Tuyết Ảnh | combat utility; pending | Aura tốc đánh/cast trong party; Strongest Only |

**Generation path:** Nhân learns basic attacks/utility; Tiên evolves these specific family effects with bounded additional target/status; Thần adds authored domain/rule interaction constrained by tier, target cap, cooldown and real skill ownership. These successors are **new authored game content**, not authentic source JX titles. Unlocking realm makes study *eligible*, not automatically learned.

### E7. Cái Bang — Hỏa

- **Build alignment:** Thể Tu/Bá Thể hoặc Pháp Tu/Ngũ Hành.
- **JX combat identity to preserve:** Bổng pháp áp lực gần, chưởng lực/long ảnh tầm xa.
- **Active candidate source facts:** names/IDs are backed by Drive; ratio, cooldown, AI and all game mechanics below are authored **proposals**.

| JX SkillId | Active skill | Basis | Geometry | Damage/heal pilot | Cast | CD | Effect/gameplay proposed | Auto-AI condition |
|---:|---|---|---|---|---:|---:|---|---|
| 125 | **Bổng Đả Ác Cẩu** | Luyện Thể | Đơn đích cận chiến | 1.15 ATK | 0.3s | 5s | Dùng côn, có thể liên tiếp khi break-defense thật | target trong melee range |
| 128 | **Kháng Long Hữu Hối** | Tu Vi | Projectile dạng rồng, cap 3 trên đường | 1.30 ATK mục tiêu chính; 0.55 phụ | 0.6s + bay | 10s | Một projectile cast xác minh graph; nguồn có childN=8, không phải 8 hit mặc định | elite/boss và nhóm quái trên đường |
| 357 | **Phi Long Tại Thiên** | Tu Vi | Đường/cung, cap 3 | 0.90 ATK/mục tiêu | 0.5s + bay | 8s | Tạo áp lực Hỏa có tương tác Burn chỉ nếu authored | ≥2 địch |
| 359 | **Thiên Hạ Vô Cẩu** | Hybrid | AoE tâm caster cap3 | 1.02 ATK/mục tiêu | 0.65s | 12s | Đòn bổng tối thượng; telegraph rõ, không đánh tràn | vòng quanh bị áp sát |

**Passive / alternate reference and slot separation**:

| JX SkillId | Skill | Classification | Requirement and effect candidate |
|---:|---|---|---|
| 115 | Cái Bang Bổng Pháp | static/weapon | Đúng côn mới hưởng mastery hiệu lực côn |
| 274 | Giáng Long Chưởng | static | Nguồn lifemax; không biến thành một active damage khác |
| 129 | Hóa Hiểm Vi Di | combat trigger | Phản kích có ICD và không tự proc đòn phụ dây chuyền |
| 130 | Túy Điệp Cuồng Vũ | combat party; pending | Buff Hỏa có thời hạn, không cộng dồn nhiều người |

**Generation path:** Nhân learns basic attacks/utility; Tiên evolves these specific family effects with bounded additional target/status; Thần adds authored domain/rule interaction constrained by tier, target cap, cooldown and real skill ownership. These successors are **new authored game content**, not authentic source JX titles. Unlocking realm makes study *eligible*, not automatically learned.

### E8. Thiên Nhẫn — Hỏa

- **Build alignment:** Kiếm Tu/Sát Kiếm hoặc Pháp Tu/Ngũ Hành.
- **JX combat identity to preserve:** Ám chiến, hỏa thuật, dồn damage và hiệu ứng tiêu hao.
- **Active candidate source facts:** names/IDs are backed by Drive; ratio, cooldown, AI and all game mechanics below are authored **proposals**.

| JX SkillId | Active skill | Basis | Geometry | Damage/heal pilot | Cast | CD | Effect/gameplay proposed | Auto-AI condition |
|---:|---|---|---|---|---:|---:|---|---|
| 135 | **Tàn Dương Như Huyết** | Tu Vi | Projectile đơn, 4.5 đơn vị | 1.02 ATK | 0.45s + bay | 5s | Đánh Hỏa trực tiếp | target sống ưu tiên mark |
| 141 | **Liệt Hỏa Tình Thiên** | Tu Vi | AoE tâm target cap3 | 0.85 ATK/mục tiêu | 0.6s | 8s | Burn 3s nếu status consumer hợp lệ, không fake | ≥2 địch hoặc mark Burn |
| 148 | **Ma Diệm Thất Sát** | Tu Vi | 7 vệt VFX, cap3 mục tiêu | 1.35 ATK mục tiêu chính | 0.8s | 12s | Số vệt hoạt ảnh KHÔNG tự là 7 damage packet; effect authored 1 cast | target đã Burn |
| 362 | **Thiên Ngoại Lưu Tinh** | Hybrid | AoE cảnh báo tâm target cap3 | 1.15 ATK/mục tiêu | 0.9s | 15s | Tấn công chậm có telegraph, kẻ địch có cơ hội di chuyển | Boss/elite hoặc 3 địch tập trung |

**Passive / alternate reference and slot separation**:

| JX SkillId | Skill | Classification | Requirement and effect candidate |
|---:|---|---|---|
| 131 | Thiên Nhẫn Đao Pháp | static/weapon | Không free buff nếu dùng vũ khí khác |
| 132 | Thiên Nhẫn Mâu Pháp | static/weapon | Kiểm đúng thương/mâu |
| 150 | Thiên Ma Giải Thể | combat/conditional; pending | Bùng nổ theo HP nguy cấp có cost thật; không nhận bất tử |
| 136 | Hỏa Liên Phần Hoa | combat trigger; pending | Phản Hỏa hoặc aura có nguồn hit/timer thực |

**Generation path:** Nhân learns basic attacks/utility; Tiên evolves these specific family effects with bounded additional target/status; Thần adds authored domain/rule interaction constrained by tier, target cap, cooldown and real skill ownership. These successors are **new authored game content**, not authentic source JX titles. Unlocking realm makes study *eligible*, not automatically learned.

### E9. Võ Đang — Thổ (phái JX) / kỹ năng Lôi có element riêng

- **Build alignment:** Kiếm Tu/Ngự Kiếm hoặc Pháp Tu/Huyền Pháp.
- **JX combat identity to preserve:** Kiếm khí, liên kích, trận pháp, thân pháp.
- **Active candidate source facts:** names/IDs are backed by Drive; ratio, cooldown, AI and all game mechanics below are authored **proposals**.

| JX SkillId | Active skill | Basis | Geometry | Damage/heal pilot | Cast | CD | Effect/gameplay proposed | Auto-AI condition |
|---:|---|---|---|---|---:|---:|---|---|
| 158 | **Kiếm Phi Kinh Thiên** | Tu Vi | Projectile đơn/đường ngắn | 1.08 ATK | 0.5s + bay | 5s | Nguồn JX attribute lightingdamage_v; không coi mặc định chỉ Thổ vì nguồn phái Thổ | target tầm xa |
| 165 | **Vô Ngã Vô Kiếm** | Tu Vi | Kiếm khí nhiều vệt, cap3 | 1.30 ATK chính, 0.45 phụ | 0.75s + bay | 10s | Nguồn childN=16 chỉ đồ hình, cần packet cap và tránh 16 hit giả | ≥2 địch hoặc marked target |
| 368 | **Nhân Kiếm Hợp Nhất** | Hybrid | Đơn đích | 1.45 ATK | 0.75s | 12s | Finisher có setup; không tự steal mana vì V2 no universal mana | Boss/elite có dấu ấn kiếm |
| 159 | **Thất Tinh Trận** | Tu Vi | Trận cùng party có radius6 | Không damage | 0.55s | 16s | Buff phòng thủ/đánh chính xác theo consumer hợp lệ; JX web source support pending | khi ≥2 ally còn trong trận và chưa có aura |

**Passive / alternate reference and slot separation**:

| JX SkillId | Skill | Classification | Requirement and effect candidate |
|---:|---|---|---|
| 151 | Võ Đang Kiếm Pháp | static/weapon | Kiếm mới hợp lệ, không free basic-crit |
| 160 | Thế Vân Tung | static | Kênh move_speed nguồn hợp lệ |
| 166 | Thái Cực Thần Công | static | Attack/cast speed có nguồn & tag hợp lệ; không class stats |
| 157 | Tọa Vọng Vô Ngã | combat self; pending | JX là chuyển damage vào mana; V2 không có mana chung → cần authored shield riêng nếu sau này phê duyệt |

**Generation path:** Nhân learns basic attacks/utility; Tiên evolves these specific family effects with bounded additional target/status; Thần adds authored domain/rule interaction constrained by tier, target cap, cooldown and real skill ownership. These successors are **new authored game content**, not authentic source JX titles. Unlocking realm makes study *eligible*, not automatically learned.

### E10. Côn Lôn — Thổ (phái JX) / võ học Lôi

- **Build alignment:** Pháp Tu/Ngũ Hành hoặc Huyền Pháp.
- **JX combat identity to preserve:** Lôi trận, khống chế, giật/giảm khả năng thi triển, lối đánh từ xa.
- **Active candidate source facts:** names/IDs are backed by Drive; ratio, cooldown, AI and all game mechanics below are authored **proposals**.

| JX SkillId | Active skill | Basis | Geometry | Damage/heal pilot | Cast | CD | Effect/gameplay proposed | Auto-AI condition |
|---:|---|---|---|---|---:|---:|---|---|
| 169 | **Hô Phong Pháp** | Tu Vi | Projectile tầm trung | 0.95 ATK | 0.45s + bay | 5s | Lôi/Phong theo từng effect tag đã xác minh, không tự cấp Dị Linh Căn | target tầm xa |
| 179 | **Cuồng Lôi Chấn Địa** | Tu Vi | AoE tâm ground cap3 | 0.85 ATK/mục tiêu | 0.6s | 9s | Có thể đặt Stagger nhỏ với EffectHit và Boss refractory | ≥2 target trong radius |
| 182 | **Ngũ Lôi Chánh Pháp** | Tu Vi | AoE multi-projectile cap3 | 1.24 ATK chính / 0.62 phụ | 0.85s + bay | 12s | Nguồn childN=4 VFX, authored damage cap riêng | elite/boss hoặc ≥2 địch |
| 176 | **Cuồng Phong Sậu Điện** | Hybrid | Đường thẳng cap3 | 1.00 ATK/mục tiêu | 0.5s | 9s | Tấn công và Stagger với điều kiện hợp lệ | kẻ địch đang cast |

**Passive / alternate reference and slot separation**:

| JX SkillId | Skill | Classification | Requirement and effect candidate |
|---:|---|---|---|
| 167 | Côn Lôn Đao Pháp | static/weapon | Thỏa item tag mới hưởng |
| 275 | Sương Ngạo Côn Lôn | static | Nguồn tăng tốc đánh/cast và lôi; register channel hợp lệ |
| 173 | Thiên Thanh Địa Trọc | combat conditional | Buff chặn debuff có cấp tier, không miễn nhiễm hoàn toàn |
| 392 | Thúc Phược Chú | active support alternate; pending | Root ngắn nếu consumer chuẩn, không gắn passive giả |

**Generation path:** Nhân learns basic attacks/utility; Tiên evolves these specific family effects with bounded additional target/status; Thần adds authored domain/rule interaction constrained by tier, target cap, cooldown and real skill ownership. These successors are **new authored game content**, not authentic source JX titles. Unlocking realm makes study *eligible*, not automatically learned.

## F. STATUS REGISTRY AND PASSIVE SAFETY CONTRACT

| Status family | Application / owner | Stack policy to author | Shared scope | Needed focused tests |
|---|---|---|---|---|
| Poison | Real `hit` from poison-tag skill + source_id | Stack N/Refresh per skill, bounded e.g. 3 pilot, poison periodic snapshot | Per target across all parties | exactly 1 tick per expiry timestamp, stacked-caster cap, saved replay |
| Burn | Real Fire effect commit | Refresh/Strongest policy per family | Per target | one proc per cast, no echo loop |
| Chilled/Hàn Ấn | Direct Ice/Water effect with correct mutation tags | Stack N or Unique | Per target | Boss converts Freeze→Hàn Trệ, effect tier checked |
| Root/Stagger | Effect Hit + resist/tier/ICD | Unique/refractory | Per target | Boss CC refractory, no permanent stop |
| Armor Break | Debuff true defense channel | Stack N capped global, example max3 | Per target across 5 parties | no 15 stacks via five teams |
| Mark | Explicit debuff from ranged swords/darts | Refresh | Per target, caster attribution | target dies/revive/swap won't duplicate |
| Guard/Shields | Cast/trigger with HP and time | Strongest Only or authored individual shields | Self/party per author | shield absorption vs DR, only effective participation |
| Heal-over-time | Real heal application/tick | Strongest/Refresh | PartyID | overheal ignored for XP; no ordinary resurrection |
| Party Aura | Real active/trigger passive | Strongest Only + range/expiry | Same party unless explicitly encounter-wide | leader switch/no buff leakage |
| Counter / Reflect | Real damage event | ICD + recursion=none | Attacker only | no reflect→reflect or proc loops |
| Life-save | Explicit limited skill | Encounter limited | Exact owner or party | downed vs dying, no generic immortality |

Passive source bookkeeping must retain `source_id: skill_family/skill_owner/discipline`; generic static passives (Dịch Cân Kinh etc.) contribute ONLY legal CombatStatsV2 channels, never auto-run combat events. Combat-passive equip six-slot loadout guards enforced before simulation. Disabled/latent traits or fate do not apply effects.

## G. REALM PROGRESSION: 30 REALMS × 10 FLOORS × TWO INDEPENDENT TRACKS

- NHÂN r1–r10: by end of r10 foundational grammar single, multi, buff, debuff, control, party support, element, positioning available as *learnable content*. Mastery = Sơ Học→Nhập Môn→Tiểu Thành→Đại Thành→Viên Mãn. A new disciple does not auto-have every skill.
- TIÊN r11–r20: successor family real effects, additional bounded target/status and high mastery gate; predecessor and successor mutually-exclusive in same family. No extra 5th active slot. Tiered cleanse/control counter mandatory.
- THẦN r21–r30: bounded Pháp Tắc, advanced elements, encounter-limited lifesave, domain area cap. Does not override deterministic target, cannot have arbitrary invincibility.
- Propose four active slot opening milestones r2,r3,r7,r9 and combat passives spread through r2–r10 **ONLY AS CANDIDATE**, no implementation before owner review. 10 floors inside each realm grow **core stats**, plus can gate mastery/skill teaching; no 300 individual skill levels.
- Learning gates use `progression_basis` Tu Vi / Luyện Thể / Hybrid, not an average/character level; independent roots/Thể Chất/Traits/Mệnh Cách contribute via their own legal owners. No arbitrary permanent school class buff.
- Mastery XP via effective damage/healing/absorbed shield/real successful debuff, valid proc/positioning, or actual study. No auto-farming mastery by over-heal/0-damage or repeatedly casting on harmless target.

## H. TEAM FIGHTS / JX-INSPIRED PARTY AI — BACKEND V2 OWNED

- **6 disciples per party**, up to **five distinct parties/30 disciples one encounter**, at most 40 monsters, single deterministic MapBattleV2 authority.
- `TeamState` today only holds team/member/leader identity. Presentation design adds a canonical pre-battle six-slot formation record (frontline2/mid2/back2, flexible), order, target role, position, assigned active/passive legal loadout, leader (no free buff).
- Four formation presets candidate: balanced, Boss hunt, farm AoE, poison/attrition. Roles must arise from real learned skills: tank threat and actual protected damage, Y Đạo effective heal, Ngũ Độc DoT/debuff, ranged focus and control. JX emphasis on projectile, weapon roles and faction feel; no user manual attack spam requirement.
- Position AI: nearest enemy current default; policy later target boss/lowestHP/high-threat marked/caster/healer and protect backline with explicit deterministic priority, avoid 2D actor clipping; same encounter outcome whether map viewed.
- Boss: telegraphed AoE, cast windows and interruptible enemy casts, phase script authored with same combat primitives (not separate monster engine); crowd control resistance/refractory; no on-the-fly hidden adjustment of spawned monster stats based on player power.
- **Readiness gap:** existing generic healer <65% HP heals same party for 1.80×ATK every 5s, generic frontline guard when HP<75% for 4s/9s CD, but they are PILOT role actions and NOT learned Nga Mi/Thiếu Lâm skills. No-healer team winning 16/16 old seeded Boss test means composition still needs genuine value-based balance.
- Contribution and after-action UI: damage actual, damage absorbed, damage prevented, tank intercept, effective healing, debuff success/uptime, control, target focus, downed, retreat, loot, injury, time and exact receipt. No DPS-only XP/ranking.
- Stacking: party buffs only same party, target debuffs global per boss/encounter, cross-party buffs only authored. One Active Job: every member reservation competes with crafting/farming/workforce; return/auto-injury/exactly-once when encounter terminal. No save rewrites as part of art integration.

## I. ASSET CONTRACT — JX1 TWO VERSIONS + SOURCE A

- Source A original Spine `.skel/.atlas/.png` + baked Godot4.7.2 frames/rects/anchor/timing and 10-rig Batch-01 output both remain preserved. Prefer Source A disciples when visually coherent; JX monsters/skills/FX may complement them with per-source bind, consistent pixels/scale.
- JX_NEW source facts: 240 defined skills; 191 referenced projectile/impact atlas images in `JFX.m`, plus 11 standalone effects in `JFX.c`; Google Drive `fx/` listing 202 WebP, but compare actual filename+SHA before declaring 202/202 full closure. `doll-data.js` declares 11,171 sheets and 16,238 cells; metadata declaration is **NOT** proof full binary upload, nor acceptable raw JX rights.
- JX_OLD: 260 source skill profiles, 13 faction listings, 118 JS playable, missing original binary dependencies in multiple categories; VFX life-cycle rich cast→launch→projectile→impact→child effects; not proof any particular full native JX assets.
- Multi-version immutable manifest: `variant_id, external_skill_id, original_path, sha256, size, rights, sprite_kind, actor_action, weapon_tag, directions, actual_frames, fps, anchor, layer, start_cast, launch, hit, projectile_graph, sound, dependencies, actual_binary_present, runtime_tested, android_approved`. No versions merge on bare SkillId or filename alone.
- Render adapters: `VFXGraph/ActionAtlas/ActorVisualBinding/SoundBank` are view-only consumers of TRUE V2 actor+skill events; never call RNG/resolve damage. Pool and lazy-load WebP; cap simultaneous expensive effects; quality levels for Android 1280×720. Keep actor facing and HP readable, team overlays minimal.
- Distinguish owner upload permission from rights clearance of original JX artwork; both fan-made source licenses/readmes limit use. Don't claim commercial redistribution rights.

## I.1. SOURCE CROSS-VERSION FORENSICS — NEW FINDINGS

- **330 different external SkillIds, NOT 330 playable game skills**: new Võ Lâm Idle `data.js` has 240 definitions, old Source VL coverage has 260, overlap 170, new-only 70, old-only 90. Among 170 common IDs, 167 labels match after Unicode case/accent/space normalization; 3 label variant pairs explicitly recorded: **#45 Tích Lịch đơn / Phích Lịch đơn**, **#93 Từ Hàng Phổ D / Từ Hàng Phổ Độ**, **#124 Đả Cẩu bổng / Đả Cẩu Bổng Pháp**. Same ID with similar name does not validate identical runtime effect or sprite.
- Source `JFX.m` contains **44 missile `fly` descriptors with 16 authored directions**, **61 with 1 direction**, **85 single-direction hit atlas records**, **one single-direction end atlas**. These are metadata counts, not confirmed imported WebP textures. Preserve 16-direction effect sheets/anchors even if some character sprite rigs are 2- or 8-direction; do not infer source support for other orientations.
- JX new defines 2,151 NPC rows and 992 maps as game-data records; no claim all NPC/maps have actual artwork/binary or suit this game's maps. The new `doll-data.js` declares 11,171 sheets/16,238 cells but Drive-folder recursive binary closure hasn't been independently completed. Never treat a declared sprite as delivered.
- Old Source VL coverage `playable=118` refers to its community web game only; new `JFX.f=176` merely maps skills to FX entries; these are different denominators and **cannot be added** or equated to 294 runnable skills.
- The one-to-many mechanical adapter distinguishes **source native missile physics** from deterministic Godot hit resolution. JX`childN=16` is a source configured missile/count parameter but no evidence 16 individually authorized damage packets inside V2. MapBattleV2 owns packet count, target cap3 default and event settlement.

## J. IMPLEMENTATION INCREMENT (ONLY AFTER SEPARATE OWNER AUTHORIZATION)

1. DESIGN source closure: skill ID crosswalk, auto/manual passive taxonomy, graphs and true effect keys; treat source still downloading and version incomplete.
2. DESIGN ready gates: stat growth 30×10×2 and monster encounter EHP model, party archetypes, skill effect/AI constraints with owner review.
3. IMPLEMENT narrow true consumer pilot: 4 sect identities *not entire 40 skills*: Võ Đang projectile #158→ authored Sword family; Ngũ Độc poison #63→ status; Nga Mi effective heal #93; Thiếu Lâm team guard/threat #16/#20. Each valid hit/heal/status must be real before sprite animations.
4. IMPLEMENT image pilot only after Godot runner: Source A one male/female rig, JX skill FX and actor clips, Boss/monster correct identity, Windows Godot4.7.2 focused+Android midrange FPS. C4-VP01 remains runtime PENDING until real test, regardless of static sha.
5. IMPLEMENT party AI and real HuntingPveRunV2 group from saved disciples, multi-party shared encounter with exactly-once settlement, then gradually ten school content kits; three extension factions later as coverage allows.

**Focused QA per skill:** legal ownership/requirements/slot, mastery prereq; target geometry/range/target cap and projectile cancel; cooldown/cast/interval; status/resistance/stack/expiry; saved deterministic replay, viewer/offscreen equivalence; contribution; injury/save/reservation; frame/sfx event sync; audio/Android budget; license evidence. No CI/FULL/merge as part of this design packet.

### Status accounting
- Source records/VFX data and sample names: READ + MAPPED.
- All tuning ratios/cooldowns/AI and effects in E1..E10: **PROPOSED ONLY**.
- Existing live Combat V2 generic healer/guard and two P2 learned direct-damage skills: **CODE EXISTS**.
- Entire school curriculum, true poison/Burn/Threat/Party-Aura/element-combo, source FX exact JX mapping, Legendary signature mechanics and Source A melee pairing: **NOT IMPLEMENTED**.
- Godot 4.7.2 physical runtime/Android UI acceptance for C4-VP01: **PENDING**.
