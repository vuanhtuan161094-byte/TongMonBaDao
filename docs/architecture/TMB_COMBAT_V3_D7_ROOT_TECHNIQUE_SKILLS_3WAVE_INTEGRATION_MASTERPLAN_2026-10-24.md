# TÔNG MÔN BÁ ĐẠO — MASTERPLAN TÍCH HỢP HỆ TU LUYỆN V2 VÀ COMBAT V3
## D7 Tam Căn–Tứ Tính · Linh Căn V2 · Công Pháp V2 · Kỹ Năng V2 · Chủ Đạo · Nhân/Tiên/Thần

**Ngày:** 2026-10-24. **Loại:** Thiết kế hợp đồng dữ liệu/phụ thuộc (DESIGN ONLY). **Không code, không sửa PR Codex/UI, không merge, không phê duyệt cân bằng số.**  
**SOURCE LIVE:** main `29b5fba448b0178cb520a4ada44b375b4b934e31`; PR #27 `deeae081bcfbe1413d4cf60a29db7e58150888b5`; PR #29 S1 `9522812e91b7ca5bc0cc108eb92e000e930fe850` — draft, **Godot 4.7.2 QA pending**.  
**Lưu ý:** Main's `CURRENT_CHECKPOINT.md` is historical to its own branch; PR27/29 statuses were separately verified via GitHub PR objects. Đây là tài liệu thiết kế, không gắn nhãn "implemented" cho bất kỳ tính năng chỉ nằm trong spec.

## 0. Thiết kế này KHÔNG thay các luật đã khóa

**Thứ tự authority:** current owner → `docs/GAME_SYSTEM_ARCHITECTURE.md` + `AGENTS.md` governance → mới nhất có chủ quyền: `docs/COMBAT_SKILLS_V2_SPEC.md`, `docs/TECHNIQUE_V2_SPEC.md`, `docs/SPIRITUAL_ROOT_V2_SPEC.md`, `docs/CULTIVATION_PATH_V2_SPEC.md`, `docs/REALM_LADDER_V2_SPEC.md`, `docs/BODY_CULTIVATION_V2_SPEC.md`, `docs/DISCIPLE_MASTER_SCHEMA.md`, `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`; **D7 owner override/PR27 newest for Tam Căn + Tứ Tính** thay phần Lục Duy sáu điểm trong spec cũ. Source live xác nhận trạng thái, không tự nâng P2 thành chuẩn V2.

**Gameplay người chơi phải thấy:**
> Tuyển đệ tử (D7 + linh căn có độ thuần khiết riêng) → tu luyện Tu Vi/Luyện Thể → học công pháp từ Tàng Kinh Các và Định Đạo → học kỹ năng từ Kỹ Phổ / tự ngộ, phân vào ô chủ động/bị động → tự chiến đấu theo phạm vi/cooldown/trạng thái/ngũ hành → săn vật phẩm/mảnh/nguyên liệu → tăng lĩnh ngộ / Diễn Hóa chiêu và công pháp → đụng quái cao tầng Nhân/Tiên/Thần; dữ liệu người/kiến thức/sở hữu/vật phẩm không mất khi save.

### 0.1 Audit trạng thái thật

| Hệ | Canonical đã khóa | Runtime PR27 / PR29 đang có | Còn thiếu |
|---|---|---|---|
| Tam Căn–Tứ Tính | 3+4, hai quỹ, nguồn điểm người thật | PR27 D7 sinh/serialize/migration và Potential chỉ tác động RealmCore; D7 focused 139 checks được báo | Tâm Tính consumer; mastery skill XP từ Thông Tuệ chưa nối |
| Tu Vi + Luyện Thể | hai track 30×10 | V2 state `DiscipleRealmProgressV2` | Nối gates học SKILL/PATH với hai track |
| Ngũ Hành/Linh Căn | 1–5 root purity1..100, resonance, Dị căn; matching/khắc/sinh | P2 root quality + root elements + one global purity; một số multiplier P2 | V2 individual root + mastery/derived resist/perma passives + mutation; khắc/sinh theo definition |
| Công Pháp | Tàng Kinh Các sở hữu truyền thừa; learned personal mastery; 1 Chủ Tu + 2 Phụ Tu | P2 max3 learned, 1 active, level1–5 | V2 archive vs person mastery, 1+2, uniqueness, successor |
| Kỹ Năng | 1 Thường Kỹ + 4 chủ động + 6 bị động trưởng thành, 5 bậc mastery, families & branches | P2 9 skill dictionary, bool learned, min_stage legacy; PR29 S1 learned direct + burn/weaken/guard **unverified** | Typed skill v2, slot capacity, TuVi/Body gating, mastery XP, dash+combo, Ai canonical |
| Chủ Đạo | Định Đạo/Diễn Đạo, meaningful Đạo Lịch; không class level | P2 3 path XP & flat multiplier | chuyển lifecycle và thành tựu, không giả +20% damage từ Đạo Lịch |
| Combat | real-time V2 owner, 16 stats + elemental resist, single authoritative hit/receipt | MapBattleV2 .25s, movement/range/basic, 2 direct skills, generic healer/guard/AoE; S1 thêm status/timing cần QA | legal V2 skill source, per-skill cap/shape, resist/matchup, boss/mutation consumer |
| Loot/economy | canonical Warehouse, Injury0/1/120, exactly-once | B3/CARE pilot + isolated fixtures | manual/fragment/skill+tech farm pipeline authoritative |

## 1. Master data ownership — không tạo trạng thái trùng

Thiết kế **ba lớp tách biệt**:

1. **Content registry / phiên bản bất biến:** định nghĩa root, công pháp, kỹ năng, family/branch, yêu cầu học, chỉ số/hiệu ứng, loot/source và các recipe; không chứa nhân vật cụ thể. Mỗi ID ổn định, alias/migration rõ.
2. **Persistent provenance và hành trình cá nhân:** lưu root sinh/current; D7 sinh/current; Tu Vi/Luyện Thể; truyền thừa của TÔNG MÔN; mastery learned của CÁ NHÂN; Đạo Lịch; loadout; kho canonical; giao dịch xác thực.
3. **Encounter state có hạn:** ở đúng `MapBattleV2` snapshot — cast/pending/projectile/status/guard/cooldown/AI target/actor ID/RNG/hit-settlement ledger. Không sao chép sang `DiscipleState` như "đã nhận trúng đòn", không biến UI thành chủ nhận loot/skill.

**Giao diện** chỉ phát command hợp lệ và hiển thị dữ liệu đúng từ authority; không tự dựng damage number, ability cooldown, mutation proc hoặc XP học chiêu.

## 2. Contract V2 tối thiểu (schema sketch đề xuất, KHÔNG phải tên trường code đã được duyệt)

### 2.1 SectTransmissionV2 — quyền truyền thụ thuộc tông môn
```yaml
sect_transmissions:
  technique: { technique_id: {archived: true, first_receipt_id: "...", research_flags: []} }
  skill: {skill_id: {archived: true, first_receipt_id: "...", research_flags: []}}
sect_fragments: {definition_id: quantity}  # canonical Warehouse holds material stack
personal_discoveries: {disciple_id: [definition_ids]} # not Sect-wide until khắc lục
```
- **Bản bí tịch hoàn chỉnh đầu tiên** vào Tàng Kinh Các mở truyền thừa vĩnh viễn; đào tạo đệ tử **không trừ một bản nữa**.
- Bí tịch/truyền thừa cá nhân tự ngộ chỉ thuộc người tìm ra cho đến khi Khắc Lục.
- Trùng sách/mảnh/nguyên liệu có nguồn loot + recipe, kết toán đúng một lần. **Một canonical Warehouse**, không tạo túi thưởng vĩnh viễn thứ hai.
- Phân biệt Sect archived transmission với player-owned material, personal learning rights và documented content definition.

### 2.2 DiscipleProgressV2 — trạng thái bền vững trên người
```yaml
foundation:
  model: D7
  birth_points: {aptitude: ..., constitution: ..., mind_nature: ..., potential: ..., comprehension: ..., fortune: ..., charisma: ...}
  current_points: {...}    # source of truth; no cached damage
spiritual_roots:
  model_version: 2
  birth: {fire: 68, metal: 35}
  current: {fire: 78, metal: 35}
  mutations: {schema_version: 2, ...} # follow locked Dị-căn spec, no ad hoc reroll
realm_progress:
  cultivation: {realm: 2, floor: 3, xp: ...}
  body: {realm: 1, floor: 7, xp: ...}
dao:
  active_path_id: "spell"   # Định Đạo / branch, not derived random class
  dao_history: {...}        # Đạo Lịch, not raw generic free combat % bonus
techniques:
  learned: {technique_id: {mastery_xp: ..., milestone: "so_hoc", provenance: "..."}}
  active: {main: technique_id, support: [technique_id1, technique_id2]}
skills:
  learned: {skill_id: {mastery_xp: ..., milestone: "so_hoc", provenance: "..."}}
  loadout: {basic: skill_id, active: [skill_id], combat_passive: [skill_id]}
```
**Sketch semantics:** stable definition IDs; actor unlock/learning/evolution/slot commands validate inside transaction. Stage names are semantic labels; serialize canonical identifiers rather than UI-localized strings. Distinguish `null`/empty when not acquired. **Do not blindly serialize this sketch into legacy `DiscipleState` without schema/version migration.** Retain immutable birth fields, event/receipt provenance, family/successor history. Derived stats/matchups/resonance and skill-card display are computed from authorities, not independent mutable saved totals.

### 2.3 SkillDefinitionV2 — one registry supports 3 generations
```yaml
skill_id: "..."
family_id: "..."
generation: "nhan|tien|than"  # growth wave, NOT rarity
grade: "pham|huyen|dia|thien|tien|than"  # distinct rarity axis
predecessor_id: null
exclusive_successor_group: null
basis: {tuvi: 1.0, body: 0.0}  # per-definition authored, hybrid allowed
element: {base: "fire", advanced: null, weights: null}
path_tags: ["spell"]
requirements:
  min_tuvi: {realm: 2, floor: 1}  # EXAMPLE ONLY, not an authorized gate for any named skill
  min_body: null
  technique_ids: []
  mastery_requirements: []
  transmission_or_personal_discovery: true
action:
  shape: "single|cone|line|circle|chain|self|ally|..."
  range: 6.0
  radius: null
  max_targets: 1
  cast_seconds: 1.0
  cooldown_seconds: 7.0
  initial_readiness: "ready|delay|setup"
  interruptible: true
  target_tiebreaker: "actor_id"
effects:
  - {type: "damage", ratio: 1.45, element: "fire", root_scalable: true}
  - {type: "condition", requires_target_status: "burn", effect_ref: "..."}
mastery:
  milestones: ["so_hoc", "nhap_mon", "tieu_thanh", "dai_thanh", "vien_man"]
  xp_earning_rule_id: "valid_damage_dealt"   # not cast-spam
  authored_milestone_effects: {}
ai:
  slot_type: "active"
  use_if: "authored_condition_id"
  slot_preference: null
event:
  cast_key: "cast_id"
  source_id: "skill_id"
  attribution: "..."
```
**Không áp mọi ví dụ số cho các kỹ năng hiện có**; giữ ratio/range/cast/CD từ 9 skill P2 khi chuyển sang pilot V2 trừ khi owner chuẩn thuận thay đổi. Các trường bảo vệ gồm source/generation, element/mutation tags, hit index, status stacking, proc recursion, nonfriendly-fire mặc định, cancel/refund commit policy, target generation; con số giới hạn/slot opening chính xác chưa chốt để đặt ở content.

### 2.4 TechniqueDefinitionV2 và family data
```yaml
technique_id: "..."
family_id: "..."
generation: "nhan|tien|than"
grade: "..."
tags: {path: "sword", elements: ["metal"], role: "offense"}
learning_requirements: {...}
mastery_milestones: [...]
activation: {eligible_for_main: true, eligible_for_support: true}
passives: [{channel: "attack", mode: "percent_add", magnitude_by_milestone: {...}, uniqueness_group: "..."}]
skill_relationships: [{kind: "independent|tag_synergy|prerequisite", skill_id: "..."}]
successors: [{technique_id: "...", conditions: {...}}]
```
- **Không tự tặng một bộ kỹ năng** khi học công pháp; chỉ những skill có quan hệ/điều kiện công bố rõ mới liên quan.
- Khác biệt "học biết" và "đang kích hoạt" tuyệt đối: chỉ **1 Chủ Tu + 2 Phụ Tu** đóng góp passive/conditional hợp lệ. Inactive vẫn giữ mastery.
- Predecessor/successor cùng uniqueness group không tự cộng dồn. Cấm P2 one-active-only trở thành chuẩn V2 cuối.

### 2.5 RootDefinitionV2
- **1–5 ngũ hành nền**, mỗi root sở hữu **purity 1–100** và birth/current riêng; root count independent D7 disciple quality.
- Derived resonance `R(N)` N perfected roots (N purity100): `R=[1.0,1.10,1.25,1.45,1.70,2.00]` for 0..5. Root-generated effects ONLY are enhanced; other gear, skill mastery, mutations do not gain R recursively.
- Per matching root, `P`: `matching_skill_bonus = P × 0.0030 × R`, `matching_mastery_bonus = P × 0.0015 × R`, `element_resistance = P × 0.0015 × R`, `matching_cultivation = P × 0.0030 × R`. Additional **element permanent passives** follow `SPIRITUAL_ROOT_V2_SPEC.md` sec7; accumulate by appropriate canonical CombatStats channel, not a separate root stat engine.
- Ngũ hành tương khắc **Kim→Mộc→Thổ→Thủy→Hỏa→Kim**; counter `×1.25`, being-countered `×0.85`, otherwise `×1.00` then explicit resist. Target monster must possess REAL primary element/resist; don't insert `1.25` blindly into all fire skills.
- Tương sinh **Mộc→Hỏa→Thổ→Kim→Thủy→Mộc** is opt-in skill tag, not free generic damage; personal caster chain vs party-shared target debuff ownership separate.
- Five mutation families (Lôi/Phong/Băng/Dương/U Minh) should come **after** stable proc, status, snapshot and target-source channels; separate root birth/gen/refinement from advanced mutation consumer rollout.

## 3. Growth / learning / AI transactions — who writes what

### 3.1 New disciple and deterministic first-time creation
`Seed/source/index` → D7 independent pools + quality, V2 root-count/purities/birth mutation identity independently, V2 realm/body1.1 or authorized legacy conversion → create persistent person with source version and immutable birth/provenance once. No reroll on preview, painting UI or save/load; no root quality copied from D7. D7 probability untouched.

### 3.2 Manual acquisition & learning
`Monster/Elite/Boss/Bí Cảnh` real authorized receipt → Warehouse materials/fragments → craft authentic manual → Sect archive transmission once → disciple eligibility by true TuVi/Body coords, Định Đạo/branch, authored prerequisites and cost/time → atomic learn → personal mastery at initial stage → UI displays. No fake kill→TuVi EXP. Failed conditions do not consume stocks or invent mastery.

### 3.3 Mastery accrual
`Combat V2 settled event` → classify real contribution only (damage vs meaningful target, effective heal, actual absorbed shield, successful status, useful movement) → throttled/idempotent author/cast/target event ID → skill mastery XP source. `valid_XP = base authored contribution × (1 + D7 comprehension*0.0015 + matching root mastery P*0.0015*R + other named SAME-CHANNEL bonuses)`, after channel-specific validations; multiplier calculation belongs to **one XP authority**. **This formula is proposed integration of two locked bonus channels, not evidence it currently runs.**
- Milestones Sơ Học→Nhập Môn→Tiểu Thành→Đại Thành→Viên Mãn; gates by appropriate true TuVi/Body and authored costs; XP may bank below gate, can't automatically skip locked milestones. No generic "every level +5% damage."
- Luyện skill/Diễn Võ must not grant endless mastery without cost/risk; don't grant on mere cast spam or full overheal.
- P2 technique XP 12/session and levels1–5 must be migrated deterministically only with owner-approved mapping; **no mathematical equivalence to five named V2 milestones without explicit policy.**

### 3.4 V2 default AI — **critical correction to S2 design**
The locked `COMBAT_SKILLS_V2_SPEC.md` section13 says **fixed ordered 4 active slots (1→4) with validity conditions**, not a large global utility scoring agent. Canonical:
```text
when actor can perform an action:
  preserve existing global life/job/encounter gates
  for slot in [1,2,3,4]:
    if learned + equipped + cooldown ready + casting free
       + range/shape/target/trigger conditions valid:
       choose this slot, commit one action; return
  basic attack if valid; else approach/hold safe position
```
- Conditional skill filters MUST be meaningful: Truy Phong Bộ only if closing meaningful gap; Liệt Diễm may choose a bonus on actual Burn, but **a 'requires_burn' hard filter must be authored as a skill rule**, not secretly lock its normal raw-damage use. Heal needs wounded eligible ally, clean stale buffs, do not spam DoT refresh unnecessarily.
- Role/HP/targeting preference is chosen by **loadout order and per-skill explicit conditions**, plus real priority overrides for unavoidable survival/retreat at owning layer; not a hidden always-best global optimizer. If wanting a utility-auto build later, it needs separate owner change to canonical V2 spec.
- Passive count **6 triggered combat passives at maturity**, static self-only always-on passive is exempt when stat-only. No arbitrary all-disciple 4 slots from birth; slot unlocks gradual through Nhân Giới, exact realm/floor = **CONTENT OPEN**.
- One actor one active action; cooldown, cast, projectile, internal cooldown separate; skill initial readiness may require setup. No universal Mana. AoE max target and deterministic selection per skill; do not apply current generic `MAX_TARGETS_AOE=3` to every future skill.
- `style_tag` and `weapon_requirement` are independent; no 'all Sword skills require sword' hard rule unless definition requires.

### 3.5 Major skill evolution
- **Nhân1–10**: create complete foundational class-language (single/AoE/buff/debuff/control/heal where authored).
- **Tiên11–20**: named family successor(s); authored stronger range/targets/status and branch variants.
- **Thần21–30**: named successor(s) with bounded higher-order mechanics/effect tier; not unrestricted ignore resist or infinite revival.
- `generation` **!=** rarity grade Phàm/Huyền/Địa/Thiên/Tiên/Thần. No global formula forcing grade to a realm; low-grade utility can remain useful at higher realm.
- Family evolution preserves prior learned knowledge/mastery/history, can carry specified mastery, equipped exclusivity group prevents precursor and upgraded active effect stacking. Sect owning successor transmission can allow catch-up chain, **not free personal mastery**.
- Chủ Đạo starts unselected, deterministic Định Đạo from eligible guiding Chủ Tu; real Đạo Lịch is *proven history*, not P2 generic flat path combat bonus. Skill category isn't a permanent class-lock unless authored branch constraint says so.

## 4. Deterministic cross-system event dataflow

```text
Recruit authority (once) ──> D7 current/birth ─────────┐
                          └─> Root V2 birth/current ────┤
TuVi/Body V2 authoritative progression ─────────────────┤
Sect Archive (Kỹ Phổ + Công Pháp owned) ─────────────────┤
Personal learning/mastery + Đạo Lịch ────────────────────┤
Main/Support technique and active/passive skill loadout ─┤
Equipment legitimate source IDs ────────────────────────┘
                 ↓ derive exactly once using CombatStatsV2 channels
MapBattleV2 snapshot & active actors (1 owner) ──> skill trigger by slot/condition
                 ↓ canonical hit + status/element/crit, attribution and ID
                 ├─> settled HP/Injury + contribution + meaningful mastery XP
                 └─> true kill/generation -> CARE reward -> Warehouse receipt once
                            ↓ same authoritative state/save
           UI/Map/HUD reads events, never fabricates gameplay truth
```

**Persistent fact vs derived value:** do not store duplicate root-derived +ATK or computed final skill damage as durable truth. Runtime transients must share one clock, target generation and cast ID to prevent replay/projectile twice on save/resume. One Active Job; hunting, meditation, crafting, training cannot silently run as multiple exclusive simultaneous jobs.

## 5. Migration plan — historical P2 to V2 WITHOUT silent reroll

| Legacy source | V2 destination strategy | Fail / integrity gate |
|---|---|---|
| `learned_combat_skills: {id:bool}` | Preserve true learned skill IDs; create `mastery=so_hoc, XP=0` **only if no authentic old mastery source**, provenance tagged `legacy_P2`; empty/false remain unlearned; user-selected slots based on recorded priority if available | Do not auto-grant 9 skills to all, do not invent elapsed mastery, leave incompatible known skill learn-record but disable illegal equip (no forced deletion) |
| `cultivation_stage_index` (old 17 stages) | Keep as legacy evidence for old P2-only uses. New skill requirement checks `DiscipleRealmProgressV2` **30×10**, authored per definition TuVi and/or Body; explicit mapping table/compat fixtures required | **Never treat legacy `min_stage=9` as V2 realm9/floor9**. Unsupported old save/progression uses fail-safe migration/no silent power/XP reroll |
| P2 root `elements/quality/global_purity` | Record original facts and deterministic versioned mapping to each owned root's birth/current purity once; if full per-element provenance unavailable require owner-chosen deterministic policy; valid V2 recruits generated by V2 separate seed domain | No generative reroll, no copying D7 quality to root quality, no secretly wiping valid mutations; preserve old history |
| P2 `learned_techniques:{id:{level,xp}}`, `active_technique_id` | Preserve IDs, XP and level/history, derive provisional V2 main from P2 active; supports initially empty; adopt exact owner-authorized level→named mastery mapping before mutating values | No silently inventing support slots, second learned copy or extra sect transmission |
| P2 `cultivation_path_xp` flat Sword/Body/Spell | preserve old XP as history/provenance, **do not feed as universal free combat multiplier** in V2; start Đạo Lịch only from authentic trace/approved compatibility rule | No drop of lifetime history, no double count old path bonus and V2 Dao identity |
| PR27 D7 old6→new7 migration | PRESERVE existing PR27 strategy, `birth_values` source and independent two-point budgets; new root/skill migration in separate versioned namespace | no re-trigger D7 migration, no failed provenance forced into false new V2 roots |
| Equipment/active cooldown/DoT/poison/loot | keep actor/cast/target/status and CARE generation receipts versioned; end running old fights safely or version continuation rules before swapping authority | no replay extra hit, EXP, loot, Injury refill or timer reset; stable seed and offscreen/viewed outcome |

**Critical migration checkpoint:** a historic save with a legitimate learned P2 skill that does not meet new V2 gear/slot requirements remains learned (history) but cannot be falsely equipped; offer future legal adjustment through UI. The game never silently deletes a real learned skill.

## 6. Dependency graph & shippable integration packages

### 6.1 The *hard* dependencies — not just planning order
1. **P0 prerequisite: PR29 S1 official Godot focused PASS or documented blocker fix.** Do not stack S2 gameplay on unverified S1 status semantics.
2. **Shared content IDs + versioned SAVE schema / compatibility reader** before any root/technique/skill identity conversion. No parallel `SaveService` writer with PR27/UI; code permission needed.
3. **True V2 Realm/Body requirement adapter** before V2 skill unlock gates. Old `min_stage` remains P2-only provenance; no numeric guess.
4. **MapBattleV2 stable status/proc/attribution** before elemental combos, advanced mutation, Diễn Hóa active-passive procs and extra targets.
5. **Canonical Sect transmission/warehouse receipt** before full farm-manual, research, personal teaching economics.
6. **Root V2 per-element purity+resonance and stat-consumer adapter** before claiming matching V2 skill-effect/mastery strength or mutation bonus.
7. **Mastery event pipeline** and D7 Thông Tuệ consumer before claiming Sơ Học→Viên Mãn level-up gameplay.

### 6.2 Proposed work packages: PLAYABLE FIRST, no huge-bang migration

| Package | Writer ownership (future CODE authorization only) | Dependency | Player-facing outcome | Minimum QA + decision |
|---|---|---|---|---|
| **I0 Baseline S1 QA** | Existing Codex PR29 QA writer | PR29 HEAD verified | Seven existing S1 skill consumers stable (two deferred) | Official 4.7.2 focused; save/CARE exact once; failures retained |
| **I1 Contract & adapters** | One integrations writer (data/schema; no UI) | I0 accepted or prepare docs independent | No visual change: versioned ID, actor V2 Realm skill gate, safe read-old/old state | isolated migration old/new valid/corrupt saves; idempotence; no hidden new skill |
| **I2 S2 playable skill controls** | same Combat owner on new branch stacked after I1 | I1; S1 QA PASS | Truy Phong Bộ dash + Liệt Diễm burn payoff; legal simple slot priority; 9 authored P2 effects usable in V2 skeleton | 1 gap close/blocked, 1 burn impact before/after expiry, 1 cooldown, one save midcast, one CARE loot; no x100, no Boss |
| **I3 Technique V2 + sect archive** | technique/economy owner, serialized command boundaries | I1 and canonical Warehouse | Learn manual once for Sect, 1 Chủ Tu+2 Phụ Tu, personal 5 named milestones, tag synergy without auto skill grant | one manual→archive→2 disciples learn, one duplicate/fragment, invalid cost rollback, 1+2 uniqueness, save/load |
| **I4 Root V2 foundation** | root/character owner, no concurrent D7/save writer | I1, real root source provenance | true 1–5 roots with individual purity, resonance; Kim/Mộc/Thủy/Hỏa/Thổ passives through CombatStats V2 | deterministic born10k seeds vs D7 independent; old migration, 1 root→purity100, five100 resonance, no double boost |
| **I5 Skill mastery & cross-bonuses** | combat/progression owner + explicit integration signoff | I2/I3/I4 | XP mastery for meaningful skill use; D7 Thông Tuệ + root matching improve learning; slot progression/legal technique prereqs; 5 milestones | practice→mastery→gear/realm gate; over-heal/cast spam rejected; save/farm and regen no double XP |
| **I6 Elemental & 3-wave content** | combat/content owner, schema stable | I5; for advanced mutation, proc/status/effect-tier primitives | real Kim khắc Mộc etc, opt-in Tương Sinh, Nhân→Tiên→Thần named successor families, Dị căn stages as dependencies ready | 5 counter cycle cases, neutral/resist, party collaboration, exclusive successors, mutation anti-recursion, offscreen parity |
| **I7 Closed PvE loop & tuning** | CARE/loot + content owner, later UI listens | I2–I6 representative content, true encounters | normal loot→bí tịch/mảnh→learning→elite→Boss→successor, + gear/pill improvement | playable sandbox + focused per feature; later benchmark win/wipe P10/P50/P90 and loot/hour only after complete loop |

**Sequencing note:** I3 and I4 can be designed in parallel and even code in *non-overlapping* modules, but the save/DiscipleState integration commit has **one designated writer**. To maintain speed, I2 can use preexisting nine P2 skills as compatible authored content with explicit V2 adapter, while full RootV2 and TechniqueV2 consumers arrive later. Don't falsely label I2 'full V2 system PASS'.

**Speed-friendly QA:** per package 3–8 targeted fixtures + parse/source invariants + save/idempotent safety; at milestone I5/I7 run medium/macro seeded sweeps, not repeated full 1,240 battle fixture after each tweak. FULL/CI/Windows/Android status only when actually run; don't infer UI acceptance.

## 7. Explicit code ownership map (planning only)

| Namespace / file family | Writer | Safety |
|---|---|---|
| `docs/architecture`, `docs/design` | this chat, docs-only | no runtime changes |
| `godot/src/simulation/foundation/`, `recruitment/` | D7 integration owner | PR27 existing; never concurrent mutation |
| `godot/src/simulation/cultivation/spiritual_root_system.gd`, future V2 root | root owner | no D7 reroll, no legacy destruction |
| `godot/src/simulation/technique/` | technique + Sect archive owner | no secondary warehouse |
| `godot/src/simulation/combat/map_battle_v2.gd`, loadout, snapshot | Combat V3 owner | Codex PR29 S1 QA active; no two writers |
| `godot/src/simulation/state/disciple_state.gd`, `save/` | ONE integration owner per packet | migration serialized; no concurrent PR27+UI writes |
| `godot/src/presentation/`, assets, renderer | OTHER UI/Source A workstream | strictly OUT OF SCOPE here |
| `godot/src/simulation/combat/combat_system.gd` P2 | reference/legacy adapter only | don't maintain two authorities for one live hunt |

## 8. Four anti-dead-end acceptance journeys

**J1 New apprentice → legitimate first skill.** D7 generation deterministic, V2 1–5 root count independent, TuVi/Body1.1, sect has valid starter transmission, learn authored beginner skill, slot opens if eligible, actor uses skill in legitimate Combat V2, save/reload identities unchanged.

**J2 Hỏa-root caster → Hỏa Cầu/Combo mastery.** Two same-TuVi actors with different root purity apply different legal fire bonuses; burn state on real monster target, Liệt Diễm bonus ONLY if Burn exists at canonical impact; one valid contribution XP, no extra reward from multi-hit/DoT/save.

**J3 Công Pháp Chủ/Phụ + Tương Khắc.** Same disciple changes active 1+2 *outside combat*, conditional duplicate unique buffs do not stack; a fire skill vs metal eligible 1.25 matchup and target fire resistance apply in correct canonical channels; historic learned inactive techniques retain mastery.

**J4 Nhân→Tiên→Thần.** Required TuVi/Body+mastery unlock named successor; only one mutually exclusive family evolution equipped; original knowledge/history retained; new skill can have higher max targets/effect tier; Boss control immune/refractory prevents permanent stun; persistent save and no reward duplication.

No false `PASS` on these journeys: they are future acceptance tests only.

## 9. Owner decisions required *later*, already locked decisions not asked again

**ALREADY LOCKED (do not re-poll):**
- Source A style; Godot4.7.2 landscape; Combat V2 owner; D7 two independent birth pools, 7 dimensions; Realm+Body 30×10; 1 basic+4 active+6 combat-passive mature skill slots; 1 Main+2 Support technique slots; five mastery names; three realm waves; no universal mana; deterministic slot-order AI; individual skill elements/geometry/target cap and canonical status/proc; no hidden kill→TuVi XP; Warehouse, one job, Injury0/1/120.
- Ngũ Hành framework and counter/base-root resonance from full locked specs; not arbitrary S2 AI scoring or P2 root bonuses as V2 truth.

**OPEN CONTENT VALUES (do not invent locks):**
- Exact TuVi/Body realm/floor required for first 9 *migrated* prototype skills (old `min_stage` ≠ V2);
- Exact realm/floor slot unlocks and skill mastery XP/cost per milestone/family;
- Specific starter/elite/Boss manual/fragments drop tables and craft recipes (B3 / C4 docs to be reconciled);
- Names, parameters and successor pairs for full Nhân/Tiên/Thần catalogue beyond already authored content;
- Historical P2 `level1..5+XP` to five named V2 milestones conversion and legacy per-root-purity provenance mapping;
- Whether a V2 skill definition should declare a mandatory Burn condition for Liệt Diễm (current P2 does NOT) vs bonus-only; the locked default AI can still use precondition when authored.
- Owner must approve code packet and safe exact branch/head after S1 QA; no permission implied by selecting C design.

## 10. What this masterplan changes about earlier S2 proposal
Earlier docs branch `docs/combat-v3-s2-dash-firecombo-autoai-contract-20261024` proposed five-stage survival/utility and optional global damage-equivalent scoring for AI. **That is now superseded as a default by locked `docs/COMBAT_SKILLS_V2_SPEC.md` sec13**: deterministic legal **slot1→slot4 priority** with per-skill conditions; no global scoring optimizer. Keep previous dash/impact core ideas only where compatible with V2 locked cast/cancel/snapshot rules. Do not implement proposed utility scoring without a specific new owner override.

## 11. Recommended next action while Codex S1 QA continues

**Do NOT launch I2 code yet.** Best docs-only follow-on is to create **I1 compatibility contract / fixture packet** with:
- exact old-save fields, version transitions and no-reroll provenance;
- immutable definition IDs, content registry versioning;
- explicit read/validate/persist gateways for real Realm/Body skill conditions and D7 learning boosts;
- acceptance fixtures for old P2 skill bool, P2 technique level/XP, old root quality, PR27 D7 and current PR29 pending cast.
After Codex reports PR29 S1 actual test SHA/verdict, user may authorize I1 code separately without touching the UI writer.
