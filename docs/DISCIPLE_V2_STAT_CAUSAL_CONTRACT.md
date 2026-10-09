# ĐỆ TỬ V2 — HỢP ĐỒNG GỐC → CHỈ SỐ → HIỆU ỨNG → KẾT QUẢ

Ngày: 2026-10-09

**Trạng thái: DESIGN CONTRACT — CONSOLIDATION OF LOCKED V2 LAWS; NO GAMEPLAY IMPLEMENTATION.** Những ô đánh dấu `CẦN THIẾT KẾ/PHÊ DUYỆT` không được biến thành công thức tạm. Tài liệu này tổng hợp các authority hiện có, không thay thế spec gốc.

Nguồn:
- `docs/DISCIPLE_MASTER_SCHEMA.md` và `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`;
- `docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`;
- `docs/COMBAT_STATS_V2_SPEC.md`, `docs/BODY_CULTIVATION_V2_SPEC.md`, `docs/REALM_LADDER_V2_SPEC.md`;
- `docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`, `docs/P3_7_SPIRIT_FIELD_SPEC.md`;
- `docs/TRAITS_V2_SPEC.md`, `docs/DESTINY_V2_SPEC.md`, `docs/SPIRITUAL_ROOT_V2_SPEC.md`, `docs/BLOODLINE_V2_SPEC.md`, `docs/PHYSIQUE_V2_SPEC.md`;
- `docs/DISCIPLE_V2_ROOT_ARCHITECTURE.md`, `docs/DISCIPLE_V2_CHARACTER_IMPLEMENTATION_PLAN.md`.

## 0. Quyết định người dùng 2026-10-09 — XỬ LÝ 3 XUNG ĐỘT THEO V2

1. **Thể Lực Viễn Chinh = outside-map only**: 0–100 base/daily budget as authored by `BODY_CULTIVATION_V2_SPEC`; *không* bị rút bởi công việc trong tông môn, luyện đan, ruộng, mỏ, tu luyện, luyện thể, đi lại trong tông môn, hay chỉ vì tốc độ làm việc cao. Trạng thái nghỉ trong tông môn không được tự phục hồi ngoài luật reset/restore Thể Lực Viễn Chinh. Nếu sau này thiết kế mệt mỏi ca làm, đó là **hệ riêng cần được phê duyệt**, không tái sử dụng meter viễn chinh.
2. **Trait V2 không có cấp 1–5 và không dùng `combat_power_flat`**. Mỗi ID có hiệu ứng cụ thể, trạng thái sinh/lộ/ẩn/hậu thiên/áp chế; chỉ active khi có consumer. **Profession Talent Grade 1–5 là hệ khác**, đã được chốt tại P3.7 và được giữ nguyên; không được coi là Trait V2.
3. **Combat V2 không dùng `combat_power` để giải sát thương, đỡ đòn hoặc xác định sức mạnh gameplay**. Chỉ dùng bộ Combat Stats V2 và effect/rule resolution. `combat_power` cũ ở runtime/saves là **LEGACY COMPATIBILITY** cho đến migration có gate, không phải thẩm quyền V2; một giá trị tổng quan (nếu UI cần) chỉ là nhận định dẫn xuất, không được feed ngược combat.

**Status distinction:** Quyết định thiết kế đã khóa; code P2/P3.7 legacy chưa được sửa. Không khẳng định xung đột runtime đã được sửa hay đã PASS.

## 1. Cây phụ thuộc tổng thể

```text
World / timeline / buildings / economy / named content
                |
    Disciple stable identity, six Foundations and birth history
                |
     +----------+------------+------------+
     |                       |            |
Realm + Body track      Profession XP   Learning/mastery & Path
     |                       |            |
Core HP / ATK / DEF   Profession level   Valid mastered ability
     |                       |            |
     +--- typed sources/filters: Trait, Destiny, Root, Bloodline,
     |    Physique, technique, equipment, building, conditions
     |                       |            |
Combat derived channels | Work-cycle channels | Study/cultivation channels
     |                       |            |
Combat action/result      Job action/result  Progression event/result
     +-----------+------------+------------+
                 |
      Persistent state + significant history
                 |
         Next decision / life event
```

**Base và source khác nhau:** Linh Căn/Đặc Chất/Mệnh/Huyết/Thể không phải 5 bộ chỉ số đối thủ; chúng *cấp nguồn* lên các `channel` được đăng ký và đôi khi thay đổi một luật hành động được xác định.

**Quan hệ không tuyến tính:** Cấp nghề tăng nhờ XP, rồi cải thiện tốc độ công việc; tốc độ giúp hoàn thành nhiều chu kỳ trong cùng thời gian nhưng không mặc định nhân sản lượng của *mỗi* chu kỳ. Thông Tuệ không buff trực tiếp số quặng; Cơ Duyên không buff mỗi tick.

## 2. Tầng chỉ số GỐC — persisted ownership

| Nguồn gốc | Stored authority | Ảnh hưởng canonical đã chốt | Không được tự suy diễn |
|---|---|---|---|
| Tư Chất (Lục Duy) | birth snapshot + current permanent | `cultivation_gain` +0,25% / điểm cho Tu Vi tự nhiên | Không tăng fixed-value Tu Vi hay tất cả các XP |
| Căn Cốt | birth + current | `body_training_gain` +0,20% / điểm | Không nhân work speed, không tăng Thể Lực viễn chinh chung |
| Thông Tuệ | birth + current | `learning/profession_xp` +0,15% / điểm | Không nhân yield hoặc success ngẫu nhiên |
| Tiềm Lực | birth + current | `RealmBodyCore` HP/ATK/DEF +0,05% / điểm; retroactive | Không nhân thanh kiếm +100 ATK hay thưởng vật phẩm cố định |
| Cơ Duyên | birth + current | `LuckScore = RNG(0..9999) + Cơ Duyên − Difficulty` theo check có ý nghĩa | Không buff generic % sản lượng/lucky tick |
| Mị Lực | birth + current | `SocialScore = RNG(0..9999) + Mị Lực − Resistance` và Dẫn Tiên P3.7C1 | Không tăng attack/loyalty một cách bị động |
| Tu Vi | current realm/floor/progress | Realm core / breakthrough và nội dung theo cảnh giới | Không trực tiếp quay ra `combat_power` V2 |
| Luyện Thể | body realm/floor/XP | Body core nhấn mạnh HP > DEF > ATK, expedition body pressure | Không đồng nghĩa có dị Thể Chất |
| Nghề | profession XP; level dẫn xuất | `level=floor(sqrt(XP/24))`, thông qua mức chuyên môn mà thay work-cycle duration | Không tạo global Work Power |
| Thiên phú nghề | unique profession talent state/grade | +5/+10/+15/+20/+25% **profession XP** theo cấp 1–5 | Không bị bỏ cấp cùng Trait V2; không nhân output miễn phí |
| Công Pháp/Kỹ Năng/Chủ Đạo | known IDs, learned/mastery, active loadout, history | Grants authored skills and valid specific modifiers | Không ghi đè birth, không thêm mana/chỉ số chủ đạo mặc định |
| Living state | current HP, expedition stamina, injuries, statuses, region | Condition/context; expedition cost là outside-map only | Không sửa lục duy vĩnh viễn vì bị thương |

Birth snapshots không thay đổi sau khi cải tạo. `disciple_quality` là nhãn từ tổng Lục Duy permanent hiện tại; không phải nguồn buff.

## 3. Tầng dẫn xuất CHIẾN ĐẤU — registry V2 bắt buộc

**14 chỉ số chính + một map kháng nguyên tố với 10 keys (không phải 10 stats gốc độc lập):**

| Nhóm | `channel` / UI | Nguồn vào chính | Consumer |
|---|---|---|---|
| RealmBodyCore | `max_hp` / Sinh Mệnh tối đa | Cảnh giới + Luyện Thể + Tiềm Lực core, trang bị, % và trạng thái | Giới hạn current HP / sát thương / hồi phục |
| RealmBodyCore | `attack` / Công Kích | Realm+Body core, Tiềm Lực, equipment flat, %/context | Base direct/basic/skill damage |
| RealmBodyCore | `defense` / Phòng Ngự | Realm+Body core, Tiềm Lực, equipment/%/context | Mitigation sau trừ buff/debuff và xuyên phòng |
| Timing | `move_speed` / Di Chuyển | base movement + %/status | Đi lại, khoảng cách, ngoại trừ work-cycle speed |
| Timing | `attack_speed` / Đánh thường | base interval + rate-style % | Tần suất đòn thường |
| Timing | `cast_speed` / Thi Pháp | base cast + rate-style % | Thời gian niệm/ra kỹ năng |
| Timing | `cooldown_recovery` / Hồi Chiêu | base cooldown + rate-style % | Tần suất kỹ năng; Phong Thế sau ordinary |
| Critical | `crit_chance` / Bạo Kích | 5% default + pp sources | Roll crit hợp lệ, bị trừ Crit Resistance |
| Critical | `crit_damage` / ST bạo kích | multiplier 1,50× baseline + modifiers | Sát thương của hit được phép crit |
| Critical | `crit_resistance` / Kháng Bạo | default 0pp + pp sources | Giảm Crit Chance của kẻ đánh |
| Defense interaction | `defense_penetration` / Xuyên Phòng | default 0% + % | Phần Defense còn lại bị bỏ qua |
| Status | `effect_hit` / Chính Xác Hiệu Ứng | default 0pp + pp | Chance áp debuff/control hợp lệ |
| Status | `effect_resistance` / Kháng Hiệu Ứng | default 0pp + pp | Chance địch áp hiệu ứng lên mình |
| Defense mitigation | `damage_reduction` / Giảm ST | default 0%; nguồn độc lập giảm phần còn lại | Giảm sát thương đã được xử lý tầng khác |
| Elemental keyed map | `elemental_resistance[element]` | kim/mộc/thủy/hỏa/thổ/lôi/phong/băng/dương/u-minh; independent remaining-damage sources | Chống sát thương đúng element, tách khỏi Ngũ Hành counter |

**Specialized registered effect channels (không phải headline stats):** `all_damage`, `direct_damage`, `basic_damage`, `dot_potency`, `skill_effect`, `healing_done`, `healing_received`, `shield_effect`, `control_duration`, element/path/skill filters, `injury_recovery`; một số luật đặc biệt là triggered effects với provenance và giới hạn kích hoạt.

### 3.1 Công thức/order đã khóa (không thay đổi)

```text
RealmBodyCore = RealmComponent + BodyComponent (numeric V1 now LOCKED in `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md`)
core_after_potential = RealmBodyCore × (1 + 0.0005 × current_TiemLuc)
ATK/DEF/HP_base = core_after_potential + valid unrelated flat bonuses
derived = resolve typed percentage/context/special/status according to owning channel
```

- Speed: `interval/cast/cooldown = base_time / (1+bonus_rate)`; Di Chuyển = `base_move × (1+bonus)`.
- Crit: `clamp(crit_chance - target_crit_resistance, 0, 1)`.
- Ordinary status: `clamp(base_status_chance + EffectHit - EffectResistance, 0, 1)`; guaranteed/immunity là rule explicit.
- Defense: giảm/thêm DEF của target → attacker penetration → mitigation curve **đã khóa** `K/(K+DEF_effective)` with `K=2×attacker_ATK` for eligible Attack-scaled damage; no negative effective DEF.
- Damage Reduction và Elemental Resistance: các nguồn độc lập nhân vào **phần sát thương còn lại**, không cộng thẳng đến 100%.
- Healing: `base_heal × outgoing_healing_done × incoming_healing_received`; Shield Effect là channel riêng.
- No normal accuracy/evasion, Mana/MP, physical vs magical duplicate attack, or damage calculation from combat rating.

**HP maximum change:** `docs/SPIRITUAL_ROOT_V2_SPEC.md` already **locks preservation of current HP ratio** when its permanent Root-derived Max HP changes (not a free full heal). This locked specific case must be honored. General cross-source HP-max-change semantics (equipment/physique/bloodline/realm and runtime injury or buffs) still require a single documented rule, exceptions and tests before DV2-02; do not contradict the root-specific law.

**Numeric V1 user-locked on 2026-10-09:** `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md` governs 300-floor Core and Defense. The file name remains historical; gameplay implementation is pending. Production source-to-output/transaction design: `docs/DV2_PRODUCTION_RESULT_CONTRACT_V1.md`.

**Required before actual combat code:** implement and test the **already-locked numeric** Realm+Body ATK/DEF/HP and Defense curves, then define baseline move/basic/cast/cooldown values and per-skill action coefficients still open. Existing stat contract intentionally does not fabricate these.

## 4. Tầng dẫn xuất SẢN XUẤT — mô hình nhiều kết quả, không một Work Power

Một hành động nghề tiêu thụ bối cảnh/hợp đồng riêng: người làm, nghề, cấp nghề, công trình, vật liệu, đất/cây/mỏ/công thức, thời gian, lệnh và sự kiện.

| Kênh/đầu ra | Inputs được phép | Luật/công thức đã khóa | Chưa khóa/không suy diễn |
|---|---|---|---|
| `profession_level` | XP đã kiếm | `floor(sqrt(XP/24))` cho P3.7 | Không tạo level gacha |
| `profession_speed_factor` | Profession level | `1+0.01×Level` | Không cộng số lượng thành phẩm từ speed |
| `work_speed` | nghề + general work channel + affinity + công trình | `ProfessionSpeed × valid WorkSpeed × optional ContentAffinity × FacilityFactor` | Các building factors theo công trình; không có generic Lục Duy multiplier |
| `work_duration/cycle_progress` | base task duration + work_speed, travel if actual | Công trình/task owns timer; movement only when travel physically exists | Không invent universal time reduction cap |
| `profession_xp_gain` | base XP + Thông Tuệ + profession talent grade + Trait/path/context modifiers | Same-channel additive percentages; profession talent Grade 1–5 +5..25% XP | Không nhân fixed-value XP manuals; không nhân Routine Yield |
| `routine_quantity` | recipe/plot/mine yields + level/facility **chỉ khi spec của content sở hữu** + tagged bonus | Real resulting count from single authorized production outcome | **NEEDS OWNER CONTRACT** for generic quantity bonus, flat/% stacking, integer rounding & overflow |
| `material_consumption` | recipe input, reserve/warehouse, explicitly permitted efficiency/waste/refund sources | Spend real stock only on valid action/recipe according to owner | **NEEDS OWNER CONTRACT** for saving/waste/refund timing, integer rounding; no imaginary negative consumption |
| `product_quality` | recipe/item/plant, owned quality system, profession mastery, valid quality check | Only if the work content defines a quality outcome | **NEEDS PER-RECIPE QUALITY MODEL**; no fake universal quality attribute/stat |
| `rare_outcome` | one meaningful context check, Cơ Duyên, Difficulty + contextual delta | `RNG(0..9999)+Cơ Duyên−Difficulty`; apply owning event's tier table | No per-tick lucky checks; don't conflate `rare_chance` legacy bridge with new authority |
| `work_cultivation_gain` | actually worked time, current stage requirement, level, natural cultivation channel | `Raw Tu Vi/hour = StageRequirement×0.0005×(1+0.0005×ProfessionLevel)`; apply natural Tu Vi once | No grant while idle, in crop autonomous countdown or merely being assigned |
| `trade_price / service` | actual sale/trade order, pricing, relevant trait/fate | Separate economic transaction outcome | No generic 'shop skill' masquerading as routine mining production |
| `work_safety/interruptions` | real explicit authored condition/event if future | No generic risk bar currently locked | Do not create 'stamina work tax' to supply Trait downside |

**P3.7 conditional content affinity:** when a recipe/crop/resource explicitly declares root-compatibility, matching root gives `×1.05` Work Speed; no global elemental profession affinity and no mismatch penalty.

### 4.1 Example — one worker with different strengths

One miner has `Thông Tuệ` high, `Cần Mẫn`, and proposed `Mắt Nhìn Quặng`.

- `Thông Tuệ` → higher `profession_xp_gain`, thus eventually higher `profession_level`.
- `Cần Mẫn` → `work_speed` modifier, finishes actual job sooner; **not** +10% quặng per completed job.
- `Mắt Nhìn Quặng` → `rare_outcome.Difficulty` when mine owns a real rare-ore check, **not** generic extra quặng.
- A valid Mệnh Cách such as `Tài Tinh Nhập Mệnh` may alter one highest-tier work result only within its authored daily quota and stackable-output rules; it does not double unique equipment.
- `Cơ Duyên` resolves only explicit rare-check events.

## 5. Tầng TU LUYỆN, HỌC TẬP, CƠ DUYÊN, XÃ HỘI

| Outcome/consumer | Base | Ordinary modifiers | Trigger / no overlap |
|---|---|---|---|
| Tự nhiên nhận Tu Vi | Base Tu Vi by actual training/work time | Tư Chất 0.25%/pt, matching Root, appropriate Trait/Fate/Bloodline/Physique, công pháp/công trình hợp lệ | Fixed-value pill not multiplied |
| Nhận XP Luyện Thể | Base Body XP from actual action | Căn Cốt 0.20%/pt and valid body XP sources | **Không tiêu hao Expedition Stamina** vì luyện thể trong tông |
| Học Công Pháp / skill/mastery | Base mastery XP from actual study/use | Thông Tuệ 0.15%/pt, matching root, learning Trait, teacher/facility when real | Không đụng birth Thông Tuệ |
| Meaningful Luck check | RNG 0..9999 | Cơ Duyên, context Difficulty, explicit +/-Difficulty/source rules | One check at eligible outcome, not every tick |
| Meaningful social check | RNG 0..9999 | Mị Lực, social resistance, context modifier | Real event/actor/target; not passive friendship |
| Expedition duration | Daily Expedition Stamina (base 100), map pressure/travel/battle costs | explicit map-stamina reduction/budget/refund, body/map effects | NO drain for work/cultivation/sect rest; valid map reset/restoration only |

## 6. Nguồn effect -> channel/rule -> action authority

Each content identity emits zero or more typed `source contributions`:

```text
source_kind / source_id / owner_disciple_id / provenance
channel (registered) / mode (flat, percent_add, percentage_points,
    special_multiplier, override)
value / scope (target, skill, element, profession, map/environment)
condition / start/end/event / stack semantics / readiness
```

- Core source is permanent/current progression; injected content source does not mutate Lục Duy by default.
- A conditional effect can change a named **result** or an owned **rule**, not necessarily a headline stat. Example: `Thiên Công Khai Vật` on qualified craft-completed event refunds legal material exactly once/day. This is a **work transaction hook**, not +100% generic resource quantity.
- No unknown channel is silently accepted.
- Same-channel ordinary % contributions add on base; status/crit pp add as points; remaining-damage reductions and element resistance use their **special independent-source law**.
- Event hooks are deterministic, attributed, no recursion/double-award, use stable actor/action identifiers.
- Action outputs are the **only** place where XP, stock, HP, cooldown, historical advancement etc. commit.
- Consumer readiness: `ready` when owning runtime is tested; `consumer_gated` for identity whose effect waits for a real feature; `future_only` pattern, not active gameplay. Disabled means no hidden buff.
- A special Physique can enter eligible birth pool only under its stricter `PHYSIQUE_V2_SPEC` validation; Kiếm Cốt excluded until its sword dependency closes.

Full source-by-source matrix: `docs/DISCIPLE_V2_EFFECT_SOURCE_MATRIX.md`.

## 7. V2 stat/consumer implementation audit — as of 2026-10-09

| Area | What works currently | V2 work required | Status |
|---|---|---|---|
| World/tick/scheduler | `SimulationScheduler.step`, `SimulationState`, `GameRng` | Reuse with named outcomes and typed sources | LEGACY/REUSE |
| P3.7C1 Lục Duy, Dẫn Tiên | `FoundationSystem`, recruitment | Preserve odds, snapshots, same result on seed | **BACKEND LOCKED P3.7C1** |
| Profession level, XP, work | P3.7 work/warehouse/buildings run | Remove expedition-stamina drains, migrate old Trait grading | P3.7 WORKS / V2 CONFLICT |
| Combat | `CombatSystem` uses `effective_combat_power` | Replace damage with V2 stats/Defense/etc, keep old adapter until real gate | LEGACY |
| General Trait | P2 profile grades; P3.7 profession grade | Trait V2 IDs/modifiers with NO grades; profession talent grade remains | LEGACY / V2 DESIGN |
| Realm & Body | legacy stage/progress | 30×10 each and actual growth/core equations | V2 DESIGN |
| Root/Bloodline/Physique/Destiny | P2 partial profiles; no full V2 | One owner per source, reveal/event effects, proper rarity | V2 DESIGN |
| Production consumption/quality | building-specific results and raw inventory | Canonical material/quality result contract per recipe family | PARTIAL / PENDING |
| UI | real existing tabs showing some legacy output | Real V2 stat breakdown / hidden info redacted | LEGACY UI |
| Save | `SaveService` version 2 + candidate/disciple serialization | V2 versioned profile/seed domain; explicit conversion or approved dev reset | LEGACY |

## 8. Test gates — contract before claiming gameplay

1. Changing one Lục Duy only affects its intended legal consumers, with matching fixed-value exceptions.
2. Two identical miners differing only in work_speed: same output per job, shorter job duration, greater possible per-hour throughput.
3. Two identical miners differing only in profession XP modifier: same immediate job yield/time, different XP and **later** profession level.
4. With low Expedition Stamina, in-sect work/cultivation/field task still runs normally and meter unchanged; outside-map expedition consumes it.
5. Traits V2 active cannot have grade; profession talents can keep 1..5 grades, separate registry and UI.
6. Combat derived stats, skill uses, damage/defense, crit/status/heal share one source breakdown; `combat_power` cannot be read as a V2 damage input.
7. One completed work/recipe event cannot double-credit stock/quality/profession XP after save/restart, even when Mệnh Cách modifies output.
8. Fail unknown channel, invalid active Trait with missing consumer, and Kiếm Cốt active before weapon authority.
9. 1,000–3,000 character simulation does not recompute entire Combat Stat sheets or event diaries every tick.
10. Retain focused and cumulative Godot 4.7.2 gate evidence before calling any V2 behavior BACKEND LOCKED.

## 9. Open decisions — explicit, never silently filled

**Stat/economy numeric balance still open:**
- Realm+Body HP/ATK/DEF and Defense numeric V1 have been LOCKED 2026-10-09; only implementation, monster scale and encounter balance remain open;
- baseline combat timing numbers and specific coefficients/cooldowns not already locked per skill;
- per-content production quantity, material efficiency, refund/rounding, product quality and exceptional-result tables;
- derived Max HP permanent-source changes **preserve current HP ratio by default** (already locked in Combat Stats V2; not an open decision). Source-specific healing/damage overrides remain explicit.
- 101 Trait per-ID `commonality_weight` + 24 Destiny `birth_weight` were approved 2026-10-09 in `docs/DV2_BIRTH_WEIGHTS_TRAIT_FATE_V1_PROPOSAL.md`; the special Fate `birth_override` for **Kiếm Tiên Chuyển Thế** remains blocked, with exactly that ID excluded from the eligible pool; work/social effect readiness is a separate phase.

**DV2-01 birth prerequisite resolved 2026-10-09:** approved per-ID Trait/Destiny weights, explicit exclusion rules and a versioned opt-in birth schema now exist. DV2-01B generates/persists identities without enabling missing combat/work consumers; focused/full Godot gates are recorded by `CURRENT_CHECKPOINT.md`.

**Required before DV2-02/V2 combat:** implement the now-user-locked numeric RealmBodyCore + Defense curve and prove consumers with actual Godot stat/damage tests.

**Required before full V2 production/trait consumer:** per-work-family canonical quantity/consumption/quality contract and no-stamina working implementation.

This document authorizes no gameplay edits by itself. User-approved V2 conflict resolution is a design gate, not proof that legacy runtime has been migrated.
