# TÔNG MÔN BÁ ĐẠO — CPV2-C4: SĂN BOSS HAY NGHIÊN CỨU/TRUYỀN THỪA? KIỂM TOÁN NGUỒN RƠI VÀ KINH TẾ CÔNG PHÁP

**Ngày:** 2026-10-23 · **Status:** DESIGN RESEARCH + numerical scenarios, **NOT LIVE OR OWNER-APPROVED RATES**.  
**Base:** trực tiếp `main@29b5fba448b0178cb520a4ada44b375b4b934e31` — verified at this study; separate from Codex MASTER RECOVERY. **No code, merge, CI/FULL, PR #24/#25 edits.**  
**Owner decisions already locked:** C4 **family/role/element/source and actual consumer FIRST; derive catalog size afterward**. Canonical Công Pháp V2: many learned, 1 Chủ Tu+2 Phụ Tu, first complete book Sect archive unlocks transmission, deterministic teaching with requirements/time/Contribution/personal Stones, 5 mastery labels, separate Sect research, authored successor, source-specific unique rules, no generic grade multiplier. S2/F1/Q1 and X1 D2–D5 are unrelated already approved decisions. **CP1/CP2/CP3 still OPEN**, do not silently lock their choices.

## 1. Source-of-truth ledger

| Evidence | Actual SOURCE / LOCK | Scope and limitation |
|---|---|---|
| `docs/TECHNIQUE_V2_SPEC.md` | Grade Phàm/Huyền/Địa/Thiên/Tiên/Thần = rarity/depth, not fixed Tu Vi tier; one Main+two Aux; first archive permanent Sect transmission; active effects only; self-discovery/Khắc Lục and Diễn Hóa named successor | **LOCKED DESIGN — NOT IMPLEMENTED** |
| `godot/src/simulation/technique/technique_system.gd` | Six P2 books, gacha weights `38/20/18/10/9/5`, source fragment thresholds `8/12/12/18/18/30`; `gacha_cost=100`; `roll_farm_loot` fragment chance `26%/34%/42%` by danger1/2/3 **per P2 invocation** | **P2 LEGACY ONLY**, neither CARE normal kill nor Boss drop percent |
| `TechniqueSystem.learn_technique` | In legacy P2, Dưỡng Khí Quyết requires **40 Contribution +15 personal Stones**, Huyền Giáp **75+30**, one book already Sect-archived; personal Stones transferred to Sect on learning | Actual P2 cost/effect; V2 learning *time* and new grades not live; no generic free learning |
| `godot/src/simulation/combat/hunting_map_v2.gd` | R01 `thanh_truc_lam` realm1/floor1; `bach_thach_khe` realm1/floor3; `hac_phong_coc` realm1/floor6. Difficulty2 `boss_chance=.03` **per encounter spawn**, not per paid kill; different levels .01/.03/.08/.16/1.0 | **PILOT encounter composition**, not a guarantee each battle produces a defeated Boss/loot; boss monster may be present among several mobs |
| `MonsterCatalogueV2` | `hac_lang_vuong` and `nham_giap_thu` registered as species but `loot_ready=false` | **No Boss/Elite technique table currently live** |
| `P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC` and newer owner coop design | Sect owns item/book/technique reward; one Boss HP/loot pool, no last hit; a single canonical Sect inventory/receipt root | 60/40 Stones split was illustrative and remains **OPEN**, not study input |
| CPV2-C4 previous branch `docs/cpv2-c4-foundation-drop-sources-20261023` | Family taxonomy/three-book example and probability hierarchy | Design-only; **not main**, not a gameplay source. Do not stack branch histories |

**Honesty boundary:** no verified CARE-specific manual source, no exact Boss respawn/win-rate, no technique V2 time per learning, no rarity-specific research recipe, no actual p50/p90 in game. The analysis below compares synthetic alternatives with CLEAR units.

## 2. Three competing player experiences — same goal, different risk

| Model | What player does | Reward & economy | Advantages | Downsides / design gate |
|---|---|---|---|---|
| **B — Boss-centered** | Identify one named Boss, defeat repeatedly seeking an optional full manuscript | Authored `boss_death_id` Sect book payout, conditional p_full per successful Boss death; one Sect archive and then many teaches | high drama, clear targeted endgame chase; suitable optional exceptional rules | RNG tail very long; spawn/readiness/injury multiply attempts; mandatory Boss-only path creates softlocks |
| **R — Research/transmission-centered** | Farm named normal/Elite source for a named fragment, collect K, reconstruct/research at Tàng Kinh Các; then teach | Authored `paid_kill_id` fragment receipts, `K` distinct count + real named research inputs/time ⇒ one complete book, first archive only | predictable/controllable progression, supports 1k–3k disciples, low-burden AUTO | material sinks/research costs/teacher throughput must prevent trivial instant spread; excessive micro farming undesirable |
| **H — Source-specific hybrid** | Normal/Elite farm named fragment; Boss optionally drops full book and awards fixed 1 milestone fragment per eligible Boss defeat; research completes book | independent normal paid kill and shared Boss death event receipts; either obtain full manual OR assemble K then research; **full book Boss-exclusive**, fragments region-specific | meaningful Boss excitement *and* finite-progress fallback; no last-hit, flexible Sect policy | need precise credited milestone, distribution and research authority; Boss fragment must be once per actual Boss death, never once per team |

**Terminology:** A book whose **full manuscript** is restricted to the Boss but whose fragments are available from normal monsters is **full-manual Boss-exclusive**, not wholly source-exclusive. A truly exclusive Boss book has **zero fragments and zero full-book chance elsewhere**; by default keep it optional or author a guaranteed same-Boss milestone path.

## 3. SOURCE-SPECIFIC content authoring, not global tier loot

| Candidate & status | Targeted origin | Manuscript/fragment candidate | Consumer identity | Mandatory? |
|---|---|---|---|---|
| `duong_khi_quyet` Dưỡng Khí Quyết (**SOURCE P2**) | Sect starter archive milestone **PROPOSED**; alternate Thanh Trúc Lâm normal fragment pathway if approved | first starter book guaranteed by authored milestone **only if owner selects** CP2=A; fragment ID and drop rate NOT LIVE | actual P2 growth role; exact V2 passive source must be defined/validated | designer recommendation: stable first basic cultivation choice |
| `huyen_giap_cong` Huyền Giáp Công (**SOURCE P2**) | proposed R01 `nham_giap_thu` Elite-specific fragments and/or compatible normal sources (actual `loot_ready=false` for Elite) | P2 threshold12 is reference, **new V2 K open**; fragment and full tables PROPOSED | tank/Body defensive identity; exact CombatStats V2 source not implemented | useful alternative, not global forced pick |
| `cpv2_proposed_hac_lang_hon_quyet` (**NEW NAME, NO EFFECT**) | named `hac_lang_vuong` Boss in R01 regions; actual species exists but its loot not ready | B: exclusive full; H: Boss-exclusive **full**, regional named fragment + milestone | effect must be authored with real Combat V2 trigger/unique key; otherwise **CONSUMER BLOCKED** | optional chase only until deterministic accessibility/unique rule proven |
| `cpv2_proposed_co_nguyen_kinh` (**NEW NAME/SECRET NOT REGISTERED**) | `secret:co_nguyen_di_canh` fictitious candidate; P=0 for all normal/Elite/Boss | secret-first-clear authored complete or fragments; exact rates unknown | potential sect research / Diễn Hóa authored successor with separate event | optional and **SOURCE BLOCKED** until Secret exists |
| `thanh_phong_kiem_quyet` Thanh Phong Kiếm Quyết (**SOURCE P2**) | eventual authored sword-aligned Elite or Secret; P2 gacha not V2 normal drop | exact source table unapproved | sword offense/tag consumer must be traced to Combat V2 | optional swordsman path; lower-grade works beyond origin realm |

**All `cpv2_proposed_...` item IDs and `secret:` IDs above do NOT exist in source; these are design probes, not item grants.** Element `nether` on an actual monster is not an automatic sixth human Linh Căn. Every manual must have a genuine role/unique passive/trigger before its content entry can become implementable.

## 4. The probability decision tree

For a single source event with one mutually exclusive category slot:

```
P(book_i full | eligible source event) =
P(category | source)
× P(full manuscript | category,source)
× P(grade_i | full,source)
× w_i / SUM(weights of actually eligible IDs at that source+grade)

P(fragment_i | eligible source event) =
P(category | source)
× P(fragment | category,source)
× P(grade_i | fragment,source)
× w_i / SUM(weights of actually eligible fragment IDs)
```

No global Phàm/Huyền/Thần roll across all regions. Alternative **independent** dedicated full/manual categories are allowed only if explicitly defined as different source slots/rolls with settled distinct identity; avoid accidentally running both old P2 farm and B3 kill rewards for one event. If the eligible pool is empty/unregistered, **fail closed**, don't redistribute rarity to fake titles.

**Illustration only:** normal source category4%, grade Phàm80%, among three authored Phàm eligible IDs weights5:3:2 ⇒ per valid kill **1.60% / .96% / .64%** full book for the three; remaining 20% grade share **UNAUTHORED**, table BLOCKED. A Boss-exclusive manual has `P=0` in that normal pool regardless of grade. Do not turn P2 gacha weights into these percentages.

## 5. Comparison criteria not simply drop chance

**Quality of experience:** time to first useful book (not every skill), optional chase excitement, ability to target source, long-tail protection, clear in-game guide, near-equivalent builds from different rarities.

**Economy:** exactly one Sect archived copy needed, but **per-disciple** learning still costs personal time/Contribution/Stones; duplicate full books and fragments must have sinks (Sect research, Diễn Hóa, salvage only if authored) and cannot be multiplied freely by salvage↔craft↔sale.

**Content governance:** each source→item→archive→learn→active effect points to an existing consumer; Boss/NPC and Secret ID must genuinely exist and be farmable; no universal CP grade power multipliers; successor doesn't double-stack predecessor; no invented Mana/crit-heal source; no separate reward warehouse.

**Scalability:** 1000–3000 disciples are not 1000–3000 full rare books, but individual training time and service throughput still scale; player handles Sect-wide policy/role groups rather than 1000 separate manual clicks. For a 6-person team, books discovered from one paid kill/Boss death are Sect-owned once and accessible via legal transmission for eligible members; contribution divided/awarded by legitimate authority rather than last hit.

## 6. Deterministic receipts and migration

1. **Source event**: `source_id`, `event_kind`, `paid_kill_id` OR `shared_boss_death_id` OR `secret_reward_id`, `pool_revision`; source and target eligibility filters.
2. **Loot draw**: deterministic seed from true event identity, authored conditional grade/type/eligible book weights; one outcome receipt, no retry reroll by save/load or dashboard click. If full manuscript Boss-only and fragment normal accessible, filters enforce exclusive **kind**, not blanket ID.
3. **Sect stock**: true stackable named fragments/book items in canonical Sect inventory/knowledge ledger, no additional loot bag; unique manuscript→first archive once, duplicates persist.
4. **Reconstruction**: check `K` fragments + any documented `ResourceRegistry` material + real Sect research work/time; debit and create manual/knowledge atomically with save replay; no free fragment copy on failed order.
5. **Teaching**: active Sect archive, eligible disciple, per-disciple real time/Contribution/personal Stone debit, learned/mastery history; 1 main+2 aux sources only active, conflict/predecessor guard.
6. **Migration**: old P2 technique six IDs, old 4 rarity categories, weights and saved inventory remain readable; no new V2 source claims until owner grants explicit code paths and tests.

## 7. Recommended interpretation of the quantified results

Companion file `CPV2_C4_PROBABILITY_MODEL_AND_OWNER_OPTIONS_2026-10-23.md` reports analytic exact P50/P90 and seeded 200k-trial experiments for Boss full, normal-fragment reconstruction and optional hybrid. **Recommendation only:** required baseline books should be reachable from Sect teaching/research or genuinely repeatable fair normal sources; Boss-only exceptionally scarce books should be special optional content; for intermediate rare books use hybrid explicit full-book Boss plus finite fragment/progress source. No policy locks CP1/2/3 or fixed numeric chance until owner chooses.

## 8. Future code gate (not authorized)

When separately authorized after recovery, first implement a single genuinely existing ID path (e.g. source-verified `duong_khi_quyet` archive + a real authorized teaching consumer) before adding any invented Boss/Secret technique. Future tests: no illegal source drop, receipt once across reload, correct fragment balance, archive-once teaching to two disciples with personal currencies, optional Boss cooperative one Sect pool, active V2 1+2 and legal effect, no P2 gacha/legacy regression. Keep UI purely read-only and owner visual acceptance separate.

**No gameplay code or live drop table changed in this docs packet.**
