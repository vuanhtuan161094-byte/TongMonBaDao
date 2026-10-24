# TÔNG MÔN BÁ ĐẠO — NGŨ HÀNH / LINH CĂN / DỊ LINH CĂN — COMBAT V3 CONTRACT
## Bản phân tích hệ số, trạng thái, chống cộng dồn, kinh tế nuôi linh căn và thứ tự tích hợp

**Ngày 2026-10-24** · **DESIGN ONLY / ADDITIVE AUDIT** · không thay đổi một dòng spec canonical, Godot runtime, PR Codex/UI, không merge hoặc tự khóa hệ số còn mở.  
**Main read** `29b5fba448b0178cb520a4ada44b375b4b934e31`; PR #27 `deeae081bcfbe1413d4cf60a29db7e58150888b5` D7; PR #29 `9522812e91b7ca5bc0cc108eb92e000e930fe850` S1 DRAFT, official Godot QA pending at review time.  
**Parents:**
- `docs/SPIRITUAL_ROOT_V2_SPEC.md` (**FULL DESIGN LOCKED, NOT IMPLEMENTED**) §§1–39, nguồn độc quyền cho linh căn, nhân tố, khắc, tương sinh, biến dị, nguồn nguyên liệu và chi phí.
- `docs/COMBAT_SKILLS_V2_SPEC.md` (**DESIGN LOCKED, NOT IMPLEMENTED**) §§2–31, nguồn độc quyền cho skill, target, effect tier, proc, AI.
- `docs/COMBAT_STATS_V2_SPEC.md`, `docs/CULTIVATION_PATH_V2_SPEC.md`, `docs/TECHNIQUE_V2_SPEC.md`, `docs/DISCIPLE_MASTER_SCHEMA.md`, `docs/REALM_LADDER_V2_SPEC.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, and newer owner/PR27 D7 contract.
- `docs/architecture/TMB_COMBAT_V3_D7_ROOT_TECHNIQUE_SKILLS_3WAVE_INTEGRATION_MASTERPLAN_2026-10-24.md` in `docs/combat-v3-v2-systems-integration-masterplan-20261024`.

**This document does NOT propose re-voting already locked gameplay.** Classification in tables: `LOCKED SPEC`, `CODE ON PR`, `DEFERRED`, `ILLUSTRATIVE MATH`, `OPEN / CONTENT`.

## 1. Player experience — distinct kinds of strength

A disciple is born with 1–5 specific base roots and one immutable purity per owned root (1–100). Those roots:
- enhance matching-element cultivation, mastery, skill magnitude and resistance;
- generate element-specific always-on passives (Kim penetration / Mộc HP / Thủy speed / Hỏa damage / Thổ defense);
- confer resonance when purity exactly 100, scaling **root-derived contributions only**;
- do not force all Fire skills to Burn, all Water skills to freeze, or all Sword skills to be Metal;
- coexist with D7 and 30×10 Tu Vi / 30×10 Body as independent, persisted sources.
Ngũ Hành **tương khắc** is a skill's element vs target's real element; **tương sinh** is an *opt-in authored combo*, not constant free damage. Mutation is an extra root-attached identity/lifecycle, not an alternative class or an extra global purity.

Game loop: legitimate field → Elite/Boss/Bí Cảnh source of Linh Tủy / Ngũ Hành Bản Nguyên / Dị Bản Nguyên → canonical Warehouse debit for deterministic refinement or mutation → increased matching power + mastery → formerly unsafe field becomes approachable → upgrade skills/equipment; no fake kill→Tu Vi EXP, no second loot inventory, no silently scaling enemy to match disciple.

## 2. Birth, purity, resonance — LOCKED SPEC

| Owned base root count at ordinary birth | Chance | P exponent E | Approx mean owned-root purity |
|---:|---:|---:|---:|
| 1 | 7% |0.45| ~69 |
| 2 |18%|0.70|~59 |
| 3 |30%|1.00|~50 |
| 4 |28%|1.50|~40 |
| 5 |17%|2.30|~30 |

- Exactly 1–5 **distinct** base roots, uniformly sampled without replacement AFTER count roll; no element globally rarer. D7 quality and Mị Lực do not override ordinary count or congenital mutation. Each purity `P=clamp(round(100*U^E),1,100)`, a versioned independent deterministic birth domain per root; birth values persist. Every originally owned root may reach 100, and missing root can be created later by an expensive deterministic ritual.
- Current root count and perfected root count are **derived**, never serialized independently from canonical owned root map.
- `R(N)`: for `N=0,1,2,3,4,5` perfected base roots, `[1.00,1.10,1.25,1.45,1.70,2.00]`. Do **NOT** multiply previous resonance stages sequentially.

**All matching root bonuses from purity P and derived resonance R:**

| Channel | LOCKED SPEC formula | At P=100, N=1, R=1.10 |
|---|---|---:|
| Matching elemental cultivation speed | `P*0.003*R` | +33% |
| Matching skill/technique mastery XP speed | `P*0.0015*R` | +16.5% |
| Matching elemental skill numeric effect | `P*0.003*R` | +33% |
| Matching element resistance | `P*0.0015*R` | +16.5 percentage points as source contribution; final remaining-damage resistance follows CombatStatsV2 canonical composition |

**Permanent one-passive-per-owned-root contributions:**

| Root | CombatStats channel | Formula source contribution | At P=100, N=1 |
|---|---|---|---:|
| Kim | `defense_penetration` (percentage-points) | `P*0.0010*R` | +11 pp |
| Mộc | `max_hp` (percent_add) | `P*0.0012*R` | +13.2% |
| Thủy | `attack_speed` and `cast_speed` (each percent_add) | `P*0.0008*R` | +8.8% each |
| Hỏa | outgoing all-damage channel, not fake ATK | `P*0.0010*R` | +11% |
| Thổ | `defense` (percent_add) | `P*0.0012*R` | +13.2% |

**Special integration caution:** current `CombatStatsV2.valid_source` accepts registered rate, penetration, HP/DEF and resistance channels, but **does not accept a generic always-on `outgoing_damage` global-source channel**; Hỏa +damage therefore needs a canonical context/damage-resolution consumer or an approved registry addition, **not** mislabeling +damage as `attack` or applying it twice in learned skills. Root-specific skill effects must apply at the correct per-skill/per-element magnitude branch; cannot be a global unconditional actor stat source rejected by registry `scope/filter` rules.

Example maximal all-five perfection `P=100` each, `R=2`: matching skill+60%; matching cultivation+60%; matching mastery+30%; matching resistance+30%; Kim penetration+20 pp; Mộc HP+24%; Thủy attack speed+16% and cast speed+16%; Hỏa all damage+20%; Thổ DEF+24%. **Powerful BY DESIGN**, not a reason for an arbitrary 5-root cap or hidden nerf. Sources/additive channels/remaining-resistance must compose correctly; no double-resonance.

## 3. Ngũ Hành counter and Tương Sinh — LOCKED SPEC vs runtime

**Counter directed cycle:** Kim→Mộc→Thổ→Thủy→Hỏa→Kim.
- `M_counter(skill_element, target_primary_element)`:
  - skill element counters target primary element: **1.25**;
  - target primary element counters skill element: **0.85**;
  - neutral/same/unrelated: **1.00**.
- Counter is independent of root purity; owning multiple roots does **not** dynamically select the best match for a skill automatically. Explicit elemental components/weights are required for multi-element skill definitions.
- Enemy species have an element field in `MonsterCatalogueV2`: examples Thanh Lang/Trúc Thử **wood**, Nham Giáp Thú **earth**, Huyết Lang Đầu Đàn **fire**, Hắc Lang Vương **nether**. Nether is **advanced element**, not an ordinary base mutual-counter target without authored rules. Example Hỏa→Kim favorable, Hỏa→Mộc is **NOT** favorable because Kim→Mộc and Mộc→Thổ; follow table, not real-world intuitive color logic.
- **Actual code gap (PR29):** `MapBattleV2._deal_direct` calls `CombatStatsV2.resolve_direct_hit(..., elemental_matchup_factor=1.0,...)`, although skill `damage_element` and monster `element` exist. Thus the V2 ×1.25/×0.85 system is **NOT live** in these fights. This requires separately authorized combat implementation; don't overstate PR29 S1.

**Tương Sinh directed cycle:** Mộc→Hỏa→Thổ→Kim→Thủy→Mộc. Per skill `opt_in=true` and defined magnitude/effect/consumption; last valid element used is one possible **caster-local** state. No generic +25% combo every next elemental skill. Another party member's elemental cast does not automatically extend self-chain; party combinations happen through real **target statuses** (Burn, Phá Giáp, Trấn Áp, Sinh Cơ, Slow). Stable status ownership and active target/generation necessary.

## 4. Illustrative, traceable damage math (NOT Godot executed)

Use **isolated source-channel test** to detect double application. Hold base ATK, ratio, DEF, crit, resistance, item sources constant. Let `D0` = identical *pre-root / before elemental counter* canonical settled direct damage. Across different channels only, for one **matching Fire damage skill** with Fire root100 and only 1 root perfected:
```text
matching skill effect = 1 + 100*0.003*1.10 = 1.33
Fire all-damage passive = 1 + 100*0.001*1.10 = 1.11
Fire vs Metal target counter = 1.25
D_base = D0 * 1.33 * 1.11 * 1.25 = 1.845375 D0 (before explicit resistance/other independent channels)
```
This is **illustrative channel composition**, not an assertion that all source buffs always multiply independently. If a future equipment bonus shares the all-damage channel, canonical same-channel stacking must be additive before final multiplication, e.g. `1+fire_passive+gear_bonus`, **not** `(1+fire_passive)*(1+gear_bonus)`. Elemental damage against actual metal target may be reduced by explicit resistance later.

Full five P100 R2, Fire skill vs Metal neutral other sources:
`D0*(1+0.60 matching fire)*(1+0.20 fire all-damage)*1.25 counter = 2.40 D0`.
No gratuitous ×2 resonance on any previous final damage or additional ×1.25 based on attacker's own roots. The hero's legitimate total damage can be even higher with technique/gear/D7; benchmark, do not arbitrarily cap it.

**Sensitivity examples (math only):**
| Root setup | Matching skill | Passive Fire all damage | With favorable counter (pre-resist) |
|---|---:|---:|---:|
| Fire P80, 0 perfected | +24% | +8% | `1.24*1.08*1.25=1.674` |
| Fire P100, one perfected | +33% | +11% | `1.33*1.11*1.25=1.845375` |
| all five P100 | +60% | +20% | `1.60*1.20*1.25=2.40` |

**Risks without nerfing canon:** multiplicative cross-channel snowball; Fire root boosts both matching spell and all outgoing damage; +20 pp penetration at full five boosts armored-target damage nonlinearly; speed plateaus need S1 QA; elemental resistance comp must not conflate a flat +30 pp with total 30% if stacked; matchups affect monster HP balance only after real elemental source is live. Probe combinations, not rewrite root coefficients today.

## 5. Typed buff/debuff/DoT contract (additive architecture, not changed spec)

**Status-definition obligations from locked Combat Skills V2:** `status_id/family, source_actor, cast_id, target_actor_id, target_generation, element, effect_tier(nhan/tien/than if relevant), magnitude(unit semantics), applied_at, expire_at, tick schedule(if any), stack_policy [Unique|Strongest Only|Refresh|Stack N|Independent], max_stacks(if relevant), dispel/cleanse eligibility, party/encounter scope, proc_parent/chain_depth, flags for crit/proc`. Permanent root passives DO NOT become per-second buff stacks on character.

| Type | Gameplay purpose | Canonical safety | Existing PR29 S1 gap |
|---|---|---|---|
| Direct damage | skill hit(s), single/projectile/AoE | DEF/crit/element/matchup; per-cast hit IDs | Skill effects code, root magnitude/counter integration deferred |
| Burn DoT | damage across seconds | magnitude snapshotted at application by default (SkillsV2 §31), exact expiry, caster attribution, no native crit; stack policy authored | S1 `burn` holds caster/ratio/next_tick/until; damage recalculated using LIVE caster stats at each tick, lacks remaining damage and status per-source stack; coder QA pending |
| Weakening | reduce outgoing skill/direct damage | typed multiplier, single strongest/refresh rules with expiry; effect hit/resistance when status can be resisted | S1 one `weaken` key, no general Effect Hit vs Resist hit authority for status |
| Guard / Shield | reduced incoming vs absorbed HP | guard multiplier vs shield amount remain separate; same shared stacking semantics, no duplicate static root passive | S1 learned guard and generic guard share strongest priority, no typed shield pool |
| Freeze/Slow/Root/Stagger | temporal control, boss soft replacement | effect-tier vs target tier, status-hit/resist, global refractory, save-safe | Băng advanced requires stack/refractory; not implemented |
| Heal/HoT/Cleanse/Dispel | support roles | effective heal contribution, tier-aware cleanse/dispel, no normal-heal revive | basic healer exists, full learned Y Đạo effects deferred |
| Phá Giáp / party auras | enhance team focus and coop | party scope exact, shared stack cap at monster across ALL parties, no last-hit | generic boss stats source only; no multi-party status-cap owner |
| Tương Sinh marks | caster-local chain or target shared status | opt-in per definition, clear consume/reset and non-recursion | no V2 Tương Sinh live |
| Proc (Dị Căn) | event-driven extra effect | one cast/target count guards, cooldown, cannot self-proc or recursively trigger mutations | no mutation live |

**Important unresolved implementation policy for S1:** S1 burn presently terminates if caster is downed. Canonical DoT snapshot/default and Dương Bạo remaining-damage requirement imply this should be **reviewed on official S1 QA** and explicit save/resume design before mutation; don't secretly change during this docs phase.

**Effect-application pipeline recommendation**, without choosing any new numeric status chance:
1. validate legal cast, target, rank/tier, lineage, range and snapshot;
2. derive class/root/technique/D7/equipment channel contributions **once**, with no duplicate source ID;
3. resolve direct hit via canonical `CombatStatsV2`, including counter and explicit elemental resistance when eventually wired;
4. evaluate authorized status application through Effect Hit / Effect Resistance **if effect definition requires a resistible check**; effect tier/refractory/stack rules; snapshot DoT/HoT magnitude at application by default;
5. schedule legitimate ticks and follow-on reactions, preserving cast/source/target-generation/idempotency; secondary mutation effects cannot recursively generate another mutation;
6. settle HP, injury/downed, meaningful support participation/mastery, genuine CARE loot exactly once, independent of rendered UI/frame rate.

Do not apply the same elemental root matching modifier to both the pre-hit damage ratio and to the final settled damage afterward. Do not apply Crit to DoT/reflected/mutation proc by default. Do not multiply root bonus into skill range/cooldown/cast/buff duration unless an explicit future skill content rule authorizes it.

## 6. Dị Linh Căn (five) — LOCKED SPEC & precise dependency

Mutation is attached to one owned base root: **Kim→Lôi; Mộc→Phong; Thủy→Băng; Hỏa→Dương; Thổ→U Minh**. Existing base root unchanged, no extra mutation purity meter; separate mutation `origin/mutation_realm/revealed` and 4 display states:
- `latent` unrevealed Tiềm Ẩn; `latent` revealed Hiển Lộ;
- `awakened` Thức Tỉnh;
- `metamorphosis` Thuế Biến;
- `perfected` Viên Mãn.
Birth whole-person `99.80% none / 0.19% latent / 0.01% already awakened`; one congenital mutation max, independent D7 grade. Reveals at associated P>=70, awakens at P>=80 plus materials; newly acquired requires P100. No reroll at reveal. Every owned root can ultimately mutate after investment.

**Common permanent matching mutation effects by realm** (not increased by base-root resonance):
| Realm | matching cultivation | matching mastery | matching mutation-skill effect | matching mutation resist |
|---|---:|---:|---:|---:|
| awakened | +10% | +10% | +20% | +10% |
| metamorphosis | +20% | +20% | +40% | +20% |
| perfected | +30% | +30% | +60% | +30% |

**Per-mutation numeric contract — all LOCKED SPEC:**

| Root→Mutation | Permanent passives: awakened / metamorphosis / perfected | Proc rule at each realm | Dependencies |
|---|---|---|---|
| Kim→Lôi | Crit chance **+5/+10/+15 pp**, Crit Damage **+15/+30/+50% to canonical multiplier** | Thiên Lôi, ICD **6/5/4s**, primary **30/50/80%** of triggering Lôi direct hit; at most ONE proc/cast; chain at stages2–3 1/2 additional targets at 70%, or 70% then50% | stable cast ID/hit selection, crit/proc no recursion, target identity |
| Mộc→Phong | Move speed **+10/+20/+30%**, Cast speed **+5/+10/+15%** | Phong Thế when valid Phong cast: 5s nonstacking mark; NEXT **different** skill receives **15/25/35%** one-use CD reduction, mark ICD **8/7/6s** | canonical cast/cooldown; mark consume exactly once, cannot reduce crafting/job clocks |
| Thủy→Băng | Effect Hit **+10/+20/+30 pp**, debuff/control duration **+10/+20/+30%** | 1 Hàn Ấn per caster-target-cast, expires15s, at3 stacks: normal Freeze **1/1.5/2s**; boss Hàn Trệ interval/cast ×**1.15/1.25/1.35** for **3/4/5s**; global6s refractory | global per-target refractory, boss control replacement, effect-tier + effect resist |
| Hỏa→Dương | All Damage **+8/+16/+25%**, DoT potency **+15/+30/+50%** | Dương Bạo converts **25/40/60% of own DoT REMAINING DAMAGE** into one burst; same amount removed from future DoT; target ICD **8/6/4s**; at most once/cast/target | caster-owned remaining DoT, snapshot + consume transaction, no cross-caster steal |
| Thổ→U Minh | Effect Resistance **+15/+30/+45 pp**, independent Damage Reduction **+5/+10/+15%** | Minh Mệnh once/encounter prevents lethal; set HP **15/25/35% MAX** then Minh Hộ incoming damage ×**.65/.50/.35** for **2/3/4s** | pre-lethal interception in single damage authority; encounter used flag, downed/heal/revive snapshot |

All five mutation perfected → Ngũ Dị Quy Nhất: **+20% mutation-tagged skill effect** and **+10% resistance to five mutation elements**; no 1–4 mutation resonance; NOT multiplied by base-root R.

**Anti-recursion LOCK:** mutation secondary effects do not activate other mutations by default (Thiên Lôi, Dương Bạo, reflected damage or DoT tick may not spawn another). One cast ID, hit index, target generation and proc ancestry; boss multi-team shared target-state caps and ice refractory are encounter-wide, not per party.

### 6.1 Runtime/data sequencing: no pretending advanced content is live
A legitimate Lôi skill explicitly carries `base_element=metal, advanced_element=lightning`; it receives matching owned metal root contribution + matching lightning mutation bonus + **Metal** base-element counter; it does not implicitly convert all Metal moves into Lightning. Every mutation mechanism uses existing shared CombatStatsV2 stat registry and MapBattleV2 state. If a necessary channel is unsupported, write a scoped future adapter design rather than invent a mutation-only private damage formula.

**S1 status gap to resolve before Dương/Băng/U Minh:** S1 has one `burn` row per actor, no explicit remaining-total-damage amount, no general multi-source status/proc ancestry, no global refractory and no lethal interception hook. It is unsafe to bolt the mature mutations onto that pilot without stronger status/receipt contract; this is a dependency, not permission to rewrite Codex S1.

## 7. Root progression economy and balance — LOCKED COSTS + arithmetic

**Refinement one existing root** deterministic `+1` each upgrade; no fail, no generic late-game return cap:

| Current purity prior to +1 | Linh Tủy consumed | Ngũ Hành Bản Nguyên |
|---|---:|---:|
|1–39|1|0|
|40–59|2|0|
|60–79|4|0|
|80–89|8|0|
|90–94|16|0|
|95–98|32|0|
|99→100|64|1|

**Creating a missing base root** costs `128/256/512/1024` Linh Tủy for count transitions1→2→3→4→5, plus `1/2/4/8` Ngũ Hành Bản Nguyên, created root purity10; selection player-owned, deterministic.

**Deterministic arithmetic example** using listed costs only:
- One root P10→P100 requires `30*1+20*2+20*4+10*8+5*16+4*32+64 = 502` Linh Tủy **and 1 Ngũ Hành Bản Nguyên**.
- An **extreme** character born with **ONE root purity1**, adding four missing roots (each starts10) and perfecting all five requires `511 + (128+256+512+1024) + 4*502 = 4439` Linh Tủy and `5 +(1+2+4+8)=20` Ngũ Hành Bản Nguyên, **EXCLUDING ALL mutation costs, technique/skill training and any authored eligibility/time constraints**. This is **calculated**, not new content pricing.
- An average 5-root-born disciple has much lower "add missing root" cost but ordinarily lower birth purity; once developed, full five-perfected endpoints converge in power, not equal **time/cost**.

**Acquisition-source targets in root spec (design, NOT in live CARE loot today):**
- Linh Tủy from eligible Elite roughly20% for1; Boss guaranteed2–4; rare/world Boss5–10.
- Ngũ Hành Bản Nguyên from eligible first-clear guaranteed1; eligible repeat boss ~5%; rare/world boss ~25%.
- Matching mutation origin from matching Elite ~3%, normal Boss ~15%, designated first clear guaranteed1, rare/world boss guaranteed1–2.
- Do not write loot tables into `SpiritualRootSystem`; they belong to authoritatively versioned monster/region/drop content and canonical Warehouse receipts. No root-refinement button may debit inaccessible resource IDs or offer a progression **deadlock** where the first required source is only obtainable through the build being upgraded.

**Balance gates to check later (not fake acceptance):**
1. Single-root P80 starter vs 3–5 root low purity starter: initial mastery, raw attack, gear/path investment, P10/P50/P90 resource access.
2. One P100 then 2/3/4/5: resonance growth discontinuities AND material opportunity cost; don't compare only peak ATK.
3. Boss with primary element/neutral, penetrations, elemental resist and elemental counter; ensure no invisible forced "use Fire for all".
4. Full-five P100, +D7 high Potential, best technique, rare gear, mutations: measure P10/50/90 direct burst/30s sustained/TTK, not arbitrary nerf against early baseline.
5. 1,000–3,000 disciples auto: event-driven combat actors only; no per-frame/idle root bonus tick or open-ended stack collections.

## 8. Sequential implementation dependencies and approval gates (NO CODE AUTHORIZATION)

| Gate | Depends on | Gameplay output | Minimal robust evidence |
|---|---|---|---|
| **E0: S1 QA** | Codex PR29 official 4.7.2 focused | existing burn/weaken/guard reliable | SHA+official Godot logs, save+CARE exactly once, never infer PR27 PASS |
| **E1: Root V2 save/generation** | I1 schema/migration contract, single Disciple/Save writer | genuine per-element purity1–100, deterministic birth and refinement material feasibility | generator root-count curve/birth-seed independence D7; stable legacy migration; validate corrupted records |
| **E2: Basic root stats and counter** | E1, canonical `CombatStatsV2` source contribution and monster primary element | root effects+resistance/permanent passives, five-element counter | root magnitudes 1/80/100, R0–5, exact ×1.25/×.85/×1.0 & neutral; no double source; HP ratio preserve |
| **E3: Tương Sinh + learned typed statuses** | S1 accepted, canonical skill/source/cast ID, AI slot-order V2 and status/target generation | opted-in personal combo and shared target marks | cast-order, expiry, two parties vs single Boss, no unconditional auto buff, save/replay |
| **E4: Mutation ID + refine/reveal** | E1 + material acquisition real | 0.20% whole-person mutation identity, hidden/reveal, Thức Tỉnh/Thuế Biến/Viên Mãn | seeded birth distribution, unreroll reveal, true resource debit exactly once, no fake inactive mutation power |
| **E5: advanced 5-proc integration** | E2/E3/E4 + proc owner, status remaining damage, refractory, lethal interceptor | actual Lôi/Phong/Băng/Dương/U Minh combat, one encounter authority | one cast/target proc cap, 3 Hàn Ấn, 6s refractory, Dương no duplicate DoT, Minh Mệnh once, battle snapshot replay |
| **E6: Progression/content** | real CARE drops + Sect archive / skill mastery + evolving skill families | lasting loop: farm→refine→unlock→learn→fight harder | one whole vertical slice, legitimate loot, no dead end, final balancing at content milestones |

**Performance:** `MapBattleV2` real-time simulation, no new root-only engine. Derive static root source modifiers from persisted state on change or combat entry with deterministic invalidation; mutation timers are local to active encounters, not idle 3000 disciples. Offscreen/viewed must yield same results.

### One-writer rule
- Current Codex PR29 owns combat S1 QA/fix; do not open overlapping CombatStats/MapBattle/Save PR.
- UI/UX independent writer on presentation; no renderer/Source A change here.
- Future E1 requires ONE migration/DiscipleState/Save integrator; E2–E5 require a single combat-writer per overlapping MapBattle/CombatStats snapshot; separate docs can proceed in parallel.
- Full/CI, Android/manual Windows are not established by this document; tests cited above are **future fixtures**. No merging stacked PR24–29 without authorized acceptance.

## 9. Decision ledger — new recommendations vs ALREADY LOCKED

| Decision | Status | Action |
|---|---|---|
| 1–5 roots, 1–100 purity, birth distribution, resonance 1.00→2.00 | **LOCKED SPEC** | Keep; do not re-vote |
| Kim/Mộc/Thủy/Hỏa/Thổ passives; +25%/-15% counter; opt-in Tương Sinh | **LOCKED SPEC** | Keep; integrate later |
| Mutations 0.20% birth; five named branches/mechanics; global anti-proc | **LOCKED SPEC** | Keep; no early fake proc |
| Five mastery labels; skill active slot order1→4, canonical status ownership | **LOCKED SPEC** | Keep |
| S1 burn/guard/weaken as PR29 implementation | **CODE QA PENDING** | Codex official QA; do not claim PASS |
| New status schema choices (array/map, status ID/version, remaining damage representation) | **PROPOSED ADAPTER, NOT LOCKED** | Prepare I1/E3 schema with migration fixtures; owner CODE packet later |
| Fire all-damage canonical registered channel adapter | **OPEN TECHNICAL DEPENDENCY** | Design one authoritative consumer; no source duplication |
| Exact elemental monster resistance / boss phases and root-region rewards | **OPEN CONTENT / BALANCE** | Choose after real live sources and playtest |
| Transition P2 global purity→V2 per-element purity for incomplete historical provenance | **OPEN MIGRATION POLICY** | No silent reroll; explicit deterministic policy before coding |
| Boss endurance and x100 HP/equipment/heal scaling | **OUT OF SCOPE NOW** | Combat V3 balance after runnable content |
| DoT caster-death handling (S1) / original cast change compatibility | **BLOCKED BY S1 QA/E3 CONTRACT** | Read Codex evidence before changing |

## 10. Canonical acceptance fixtures to hand to future Codex AFTER authorization

- **F01 birth:** seeded 10,000 normal recruits cover root-count 7/18/30/28/17 within statistical tolerance, each base element uniform, D7 quality independent; no repeat root; valid birth/current; no hidden root reveal in UI.
- **F02 resonance:** 1 root P99→100 jumps R1→1.10; two roots both100 R1.25 NOT 1.10*1.25, all five100 R2.00; test HP ratio after max HP buff and no double sources.
- **F03 elemental counter:** fire skill into metal monster ×1.25, water into fire ×1.25, reverse fire vs water ×0.85, fire into wood neutral ×1, nether/neutral no generic five-cycle; monitor proper explicit resistance.
- **F04 buff/status:** Burn/Weakening/Guard different scopes, strengthen/refresh/expiry, 3 targets AoE means 3 hits not 6; two party sources to one target have per-target global stack cap; legitimate heal/DR no downed auto-revive.
- **F05 Lôi:** multi-hit AoE one primary Thiên Lôi per CAST, chain1–2 additional at levels2/3, ICD/crit/proc recursion off; save mid-ICD.
- **F06 Phong:** mark5s, consume on next DIFFERENT skill, 15/25/35% on cooldown after ordinary recovery; no work timer speeding.
- **F07 Băng:** one stack per caster-target-cast, three stack trigger Freeze normal or Hàn Trệ boss, global6s refractory across parties, no eternal stun.
- **F08 Dương:** multiple DoT sources, consume ONLY own greatest remaining damage exactly once, decrement remaining future ticks accordingly, same cast no twice.
- **F09 U Minh:** lethal interception once encounter at right 15/25/35% HP, correctly composed temporary shield incoming multiplier, no infinite trigger after healing/retreat/save.
- **F10 mutation progression:** 0.19% latent/0.01% awakened whole-person; reveal P70, awakening P80, acquired P100, source/material receipts, all-five mutation perfected produces +20% tagged effect and +10% advanced resist only.
- **F11 complete loop:** Elite genuine Linh Tủy drop→Warehouse→+1 purity/ingredient cost→stronger real combat, and first eligible boss grants Ngũ Hành Bản Nguyên→P100. No loot duplication, failed refine no debit, safe reload.
- **F12 static/offscreen scalability:** only active fights process proc/status; 30-disciple encounter max, 1000–3000 owned disciples do not poll status timers per frame; viewed/offscreen seeded battle result matches.

**Test philosophy:** small focused contract each package, broader seeded balance after a playable normal→elite→boss progression loop. No repeated arbitrary 1,240 encounter full sweep every coefficient change.

## 11. Recommended follow-on docs choices
A. **I1/E1 data migration contract**, record-by-record old purity/mutation/D7 and content versioning (recommended technical prerequisite; only docs).
B. **Playable Ngũ Hành early scenario**, one Fire + one Water disciple vs Earth/Fire/Metal monsters with matching root/rare material source and skill cards, represent only verified mechanics as live.
C. **E3 status/proc execution schema**, tight architecting of status snapshotted magnitudes, remaining damage/stack/target generation and legacy S1 transition before future mutation code.

**No code, no merge, no PR27/29/UI edits authorized by this artifact.**
