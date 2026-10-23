# CPV2-C4 — LUẬT NGUỒN RƠI, BÍ TỊCH/MẢNH, XÁC SUẤT VÀ KINH TẾ TRUYỀN THỪA

**2026-10-23 | DOCS-ONLY | C4 OWNER LOCKED, ALL NEW RATES PROPOSED | NOT CODED/TESTED**  
Base from main 29b5fba448b0178cb520a4ada44b375b4b934e31. No changes to recovery/PR24/25. Read the companion CPV2_C4_FAMILY_TAXONOMY_AUTHORING_CONTRACT_2026-10-23.md, canonical TECHNIQUE_V2_SPEC and P2 technique_system.gd first.

## 1. The event is the root of drop probability

A normal paid monster kill, Elite paid kill, Boss death across ALL teams, Bí Cảnh completion, and Sect research completion are different **event types**, each with their own ID, table, eligibility, owner and save receipt. No probability is defined just by book grade.

**Authoring contract (proposed interface, not runtime):**

~~~yaml
source_event:
  event_kind: paid_normal_kill|paid_elite_kill|shared_boss_death|secret_completion|sect_research
  source_id: actual_registered_id_or_BLOCK
  region_or_secret_id: real_id_or_null
  book_category_probability: proposed_number_between_0_and_1
  full_vs_fragment_shares: {full: proposed, fragment: proposed}
  grade_conditional_distribution: {pham: proposed, huyen: proposed, dia: proposed}
  eligible_pool:
    - {technique_id: existing_or_authored_id, weight: proposed, source_exclusive: true_or_false}
  seed_scope: event_id_plus_pool_revision
  payout_owner: sect_book_fragment_registry_and_canonical_receipt
  payout_once: true
~~~

For one mutually exclusive category roll:
**P(full book i per eligible event) = P(category|source) × P(full|category,source) × P(grade_i|full,source) × weight_i / sum(eligible weights).**

Fragment probability uses P(fragment|category,source) and grade conditional on fragment; a separate independent fragment category may be defined ONLY with explicit category and receipt. Before rolling, filter invalid book IDs, unrealized source IDs, secret-only restrictions, grade, and real event kind. Within one pool, conditional shares sum to 1. If sources and eligible IDs are incomplete, source stays **CONTENT BLOCKED**; do not silently normalize the odds higher or pay a mysterious null reward.

**Source exclusivity:** a book restricted to a named Boss or secret has probability zero in *all other sources*. If ordinary monsters can yield its fragments, describe it as **Boss-exclusive FULL manual**, NOT wholly source-exclusive.

## 2. Real P2 facts: DO NOT port directly to V2 per-kill loot

| Fact from main code technique_system.gd | Current actual meaning | Forbidden reinterpretation |
|---|---|---|
| Gacha weight 38/20/18/10/9/5 (six books) | Relative P2 weighted draw from eligible books; sum100 | 38% of normal monsters drop Dưỡng Khí |
| GACHA_COST=100 Sect Stones | Cost of P2 gacha, legacy state | Price/cost of random future V2 normal kill |
| Danger1/2/3 farm fragment chance = 26%/34%/42% | Result of ONE P2 roll_farm_loot invocation, with rarity cap and P2 item keys | Actual CARE per paid wolf kill percentage |
| Source P2 fragment_required 8/12/12/18/18/30 | Amounts to craft a **P2** complete manual | Newly locked V2 thresholds for all rarity grades |
| P2 deposit_special_inventory | Moves carried special fragments to sect P2 technique_fragments; resources conditional Warehouse or old dict | A license to create a persistent second PvE loot bag in V2 |

Six real book IDs and P2 roles are inventoried in the family taxonomy companion. V2 must preserve P2 learned/manual/archive history when future migration is separately owner-authorized, and never turn P2 one-active/max3 learned into V2 one-main+two-aux status merely by relabeling.

**Main-game source evidence:** HuntingMapV2 has three regions Thanh Trúc Lâm (realm1 floor1), Bạch Thạch Khê (realm1 floor3) and Hắc Phong Cốc (realm1 floor6). MonsterCatalogueV2 marks Nham Giáp Thú and Hắc Lang Vương as loot_ready=false. Proposed Boss books from them are **not currently obtainable**. CARE per-kill root and legacy encounter-win root cannot both mint the same book/mat on the same event.

## 3. Three-Phàm-book conditional example; only ONE is a real P2 identity

| Candidate | Archetype | Real source status | Planned acquisition | Runtime status |
|---|---|---|---|---|
| Dưỡng Khí Quyết (duong_khi_quyet) | Growth / Wood / spell | Defined in P2; V2 transmission and new per-kill drops NOT authored | starter Sect archive **or** repeatable early normal fragments | P2 ID genuine, V2 source PROPOSED |
| Tức Mạch Công (cpv2_proposed_tuc_mach_cong) | Growth/stability with distinct actual study behavior | Entire definition NEW and consumer unimplemented | Sect research candidate / training | BLOCKED pending real consumer |
| Trúc Ảnh Quyết (cpv2_proposed_truc_anh_quyet) | Mobility/expedition path, distinct effect required | Entire definition NEW and consumer not proven | specialty Thanh Trúc Lâm normal fragment | BLOCKED pending real consumer |

These are a **fixture, not a quota**. If the two proposed candidates lack genuinely different consumers, **drop/merge** them, do not manufacture two passive +5% duplicates to reach "three Phàm books".

**Illustrative proposed FULL-book probability F2:** one future paid normal event has P(category)=4%, P(Phàm|category)=80%, Phàm eligible weights 5:3:2, while remaining 20% grade eligibility must be fully authored before live use. Then P per eligible kill:
- Dưỡng Khí: 4%×80%×50% = **1.60%**
- Tức Mạch: 4%×80%×30% = **0.96%**
- Trúc Ảnh: 4%×80%×20% = **0.64%**.

The residual 0.8 percentage point (4%×20%) requires real eligible other-grade definitions; until then F2 **BLOCKED**. F2 is a *math example*, not live CARE drop data.

**Illustrative proposed FRAGMENT-only F1:** P(fragment category)=12%, P(Phàm|fragment)=80%, weights 5:3:2 ⇒ **4.8% / 2.88% / 1.92%** fragment for three named IDs per eligible event. Residual 2.4% needs eligible non-Phàm fragment IDs, otherwise do not activate F1; an explicitly separate all-Phàm option at 12%×100%×5:3:2 would yield **6.0% / 3.6% / 2.4%**. F1 and F2 are ALTERNATIVE scenario tables and must never silently stack into actual game.

## 4. Unique source contracts

| Origin | Specific design case | Whether content exists | Reward semantics | Mandatory? |
|---|---|---|---|---|
| Normal zone | Thanh Trúc Lâm normal species candidate | Actual region/species exist, manual pool NOT | Specific authorized book fragments only, no global table | a repeatable basic path is recommended |
| Elite | Nham Giáp Thú | Source monster exists but loot_ready=false | richer fragment/optional full, needs real kill root | optional accelerator |
| Boss | Hắc Lang Vương | Existing boss species, loot_ready=false; no approved book drops | ONE Sect full-book/chapter-fragment pool per shared Boss death | rare EXCLUSIVE should normally be optional |
| Bí Cảnh | proposed secret id, not yet registered | NOT LIVE | named secret-exclusive full book or guaranteed completion token with one-time receipt | optional unless accessible deterministic path |
| Sect research | duplicate manuscript/fragments/real research process | V2 design, not yet runtime | authored successor/Diễn Hóa with deterministic prerequisites, not a random drop | good alternate path |
| Personal discovery | legal mastery, Chủ Đạo, study, character eligibility | V2 design, not implemented | personal knowledge, later Khắc Lục archive once | authored candidate, not automatic universal skill |

Illustrative rare book: **Hắc Lang Hồn Quyết** (cpv2_proposed_hac_lang_hon_quyet) is a *hypothetical optional* Boss-only full-manual candidate tied to Hắc Lang Vương; its effect is **NOT AUTHORED**, its five-root compatibility is **NOT DECIDED**, and no claim of V2 loot is made. The monster's source element "nether" is not an automatic sixth player Spirit Root. Any damage/control passive must map to real Combat V2 events and satisfy uniqueness before such book can be added.

Do not promise an exclusive technique if it also shows up in common global material packs. A research-created successor may require the rare Boss manuscript, but it is not automatically also eligible for random creature drops. A one-time Boss can only provide an RNG-exclusive mandatory item if there is a repeatable/guaranteed path; otherwise a player can softlock permanently.

## 5. Quantitative: P50/P90 for full manual and fragments

With fixed independently repeated eligible event probability p, chance of obtaining a specific book at least once by n = **1−(1−p)^n**. P50 = ceil(ln(0.5)/ln(1−p)); P90 = ceil(ln(0.1)/ln(1−p)); mean events=1/p. EVENT counts are not wall-clock time and not Godot simulation tests.

| Book chance per eligible event (PROPOSED) | Mean events | P50 events | P90 events |
|---:|---:|---:|---:|
| 1.60% | 62.50 | 43 | 143 |
| 0.96% | 104.17 | 72 | 239 |
| 0.64% | 156.25 | 108 | 359 |
| 0.25% optional Boss book | 400 | 277 | 920 |
| 0.10% exceptional Boss | 1,000 | 693 | 2,302 |

**Danger of empty rarity:** 0.25% exclusive Boss drop means 90% of eligible sects need up to 920 successful repeatable Boss deaths just to archive **one** copy, before considering Boss spawn chance, kill time and injury. Do not propose this as a necessary chapter key. Choices: much higher named-Boss conditional odds, deterministic first-clear/milestone **fragments**, or ultra-rare strictly optional unique. None yet owner-locked.

**Fragment math worked example:** For hypothetical F1 per-kill Dưỡng Khí fragment p=4.8%, if we borrow old P2's eight fragments **only as an analytical reference**, mean paid kills to obtain eight = 8/.048 = **166.67**. Under Binomial(n, .048), P50 for eight or more fragments = **160 kills**, P90 **243 kills**. A required starter skill cannot depend only on this without authored starter archive/teaching or stronger/gated first rewards. P2 threshold8 is NOT a new V2 approval.

## 6. Economy and receipt authority, not a second wallet/bookbag

- One Sect-owned archived manual ID may teach eligible 1,000–3,000 disciples through actual time/Contribution/personal Stones costs. It is NOT one loot copy consumed per disciple, and not 1,000 drops needed for a large Sect.
- Unique first complete book archive transaction is different from fragment assembly, personal study, mastery training, Sect research, and duplicative full-book disposal. Each event gets one canonical receipt and deterministic seed/table revision; save/load offline must never reroll/duplicate.
- Duplicate manuscripts may feed Nghiên Tu, conversion, or priced sale, but must use an explicit real consumer; don't silently auto-sell and mint stones. Sect-owned fragments/archive and canonical resource Warehouse stay distinct data types, but **no new reward loot warehouse or private carried team bag**.
- Teachership/book availability must not invent a learned passive in every disciple. Inactive learned technique sources contribute no stat effect; 1 Chủ Tu+2 Phụ Tu only. Strongest-only/conflict keys and predecessor/successor nonstacking mandatory.
- Converting P2 technique gacha/sale_stones to future V2 rewards is not an economics baseline. Boss Sect/personal Spirit Stones ratio **60/40 remains OPEN**, must not be introduced as a book-loot rule.
- Availability curves measured per **paid eligible kill / actual shared Boss death / Secret completion / Sect research order**, then with real event throughput, rest/Injury120/One Active Job and other production competition converted to simulation days.

## 7. Future validation gates; NOT RUN

1. Cross-references: registered source, event, monster/region, item IDs, pool eligibility; grade shares sum by correct condition and weight; exclusive forbidden source chance EXACTLY 0.
2. Stable seeded deterministic RNG on source root and content revision; no double payout by per-team Boss, retry/save/offline or P2 encounter-win plus B3 paid kill.
3. No crafting technique before required fragment threshold/complete book valid; first archive only, duplicate handled, old-save P2 identity preserved.
4. Active 1+2, no duplicate passive/conflicting predecessor/successor, learn with true Contribution/Stones/time.
5. Real supported effect consumers ONLY, no undocumented free Mana, life-steal, damage effect or Skill kit from technique.
6. Future targeted seeded probability tests 100k eligible outcomes with confidence tolerance, binomial P50/P90 analytical fixture, early-map drop/migration integration; official Godot4.7.2 focused runs only after owner code packet.
7. UI should show exact source and only authored rate if live; hide or label BLOCKED/PROPOSED content instead of advertising nonexistent Boss books.

## 8. Owner options carried forward

C4 catalog structure is LOCKED. Remaining options are: (1) strict consumer-backed admission now versus draft reserve, (2) baseline mandatory starter teaching vs random full manual acquisition, and (3) rare Boss-exclusive compensation: named rate, milestones, or wholly optional exceptionally rare. See owner decision sheet; none of these numeric example rates is locked by this document.
