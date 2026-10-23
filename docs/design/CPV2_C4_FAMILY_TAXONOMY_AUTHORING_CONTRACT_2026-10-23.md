# TÔNG MÔN BÁ ĐẠO — CPV2-C4: HỌ CÔNG PHÁP, VAI TRÒ, NGŨ HÀNH VÀ NGUYÊN TẮC MỞ RỘNG TỪ GỐC

**Ngày:** 2026-10-23 · **OWNER LOCK:** chọn **C4** cho nghiên cứu quy mô danh mục: **xác định họ/đặc tính/vai trò trước; số lượng là kết quả**, không ấn định 36/51/85.  
**HẠN CHẾ:** Docs-only / PROPOSED, không code, không merge, không PR #24/#25, không chạm worktree Codex MASTER RECOVERY.  
**Gốc:** trực tiếp `main@29b5fba448b0178cb520a4ada44b375b4b934e31`; đây là nhánh nghiên cứu riêng, không phải bản game main và không mặc nhiên thay đổi canonical.  
**Đọc cùng:** `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, `docs/TECHNIQUE_V2_SPEC.md`, `docs/COMBAT_SKILLS_V2_SPEC.md`, `docs/CULTIVATION_PATH_V2_SPEC.md`, `docs/SPIRITUAL_ROOT_V2_SPEC.md`, `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`, `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`, `godot/src/simulation/technique/technique_system.gd`. Later cross-system docs on other branches are research/proposals, not merged main; X1 D2=A,D3=A,D4=A,D5=A and S2/F1/Q1 are recent user decisions, not reversed by this CP document.

## 1. Chốt luật C4 trước khi invent bất kỳ cuốn nào

**SOURCE — Công Pháp V2 spec, locked DESIGN but not live V2 code:** Công Pháp = foundation for Tu Vi, build and passives, not a full combat skill kit. Combat Kỹ Năng is a separate action/passive system. One Chủ Tu + two Phụ Tu ACTIVE; unbounded learned library concept and preservation of inactive knowledge/mastery; first Sect archived **complete manual** unlocks transmission for eligible disciples with real Contribution/possible personal Spirit Stones and learning time; no generic chance to fail learning. Separate five personal mastery stages (Sơ Học, Nhập Môn, Tiểu Thành, Đại Thành, Viên Mãn), Sect Nghiên Tu, Diễn Hóa to named authored successor, self-discovery then Khắc Lục. Predecessor and successor must NOT double-stack. Grade **Phàm/Huyền/Địa/Thiên/Tiên/Thần** is rarity/depth/complexity, **not** a universal damage multiplier or hard mapped one-to-one to Tu Vi rank. Learning lower grade at high realm is legal absent an authored gate.

**C4 AUTHORING RULE:** Every book must make at least **one meaningful player choice** different from existing alternatives: distinct play loop, trigger/eligibility, role, element, cost/efficiency, strength-vs-risk tradeoff, technique/skill synergy, or source/acquisition. Mere rename/color/+7% vs +8% DOES NOT qualify. Reuse existing CombatStats V2 stat/event consumer when live; if not implemented, mark proposed feature **CONSUMER BLOCKED**. An author may add specialization within an existing family; number per grade emerges from demand, not quotas.

**Not a Cartesian product:** do NOT auto-create `6 grades × 5 elements × 7 roles × 30 realms` books. This would generate duplicate content and impossible balancing. An authored family may cover multiple elements and grades only with genuine distinguishing content. Named rare/exclusive variants still reference an actual eligible source and distinct authored rule.

## 2. Six orthogonal, typed axes of every Công Pháp

| Axis | Meaning and data | What is expressly forbidden |
|---|---|---|
| **Family/lineage** | `family_id`, stable name/style, `conflict_group`, predecessor/successor edge; generations only when authored | `CôngPháp+17`; duplicate predecessor/successor buff stacking |
| **Primary role** | `growth`, `offense`, `defense`, `stability` already P2; **support/mobility/profession** only if real V2 consumer and distinct passive rule | generic subclass/lifesteal/Mana/threat stat invented to fill row |
| **Cultivation path/Chủ Đạo** | `sword`, `body`, `spell` evidenced by P2; additional archetype tags only when approved and tied to real actions | technique equals forced permanent class; one learned book grants 4 actions |
| **Element/root** | Kim/Mộc/Thủy/Hỏa/Thổ compatible with actual SpiritualRoot V2 data, optional `none` when legal | blanket root mismatch forbids learn; universal elemental effect formula |
| **Grade** | `pham,huyen,dia,thien,tien,than` rarity/depth, distinct from realm and skill generation | every Thần must be R21+, or 10 Thần titles means 10× drop chance |
| **Source provenance** | `world/region/cluster/species+normal|elite|boss/secret_id/research/sect_inheritance/event` and `manual_full|fragment` | global random loot table includes all books, undefined Boss or fake source |

**Required authoring contract** for each book:
```yaml
technique_id: stable_authored_id                 # new IDs are PROPOSALS, not registered
family_id: exact_lineage
display_name: vietnamese_name
grade: pham|huyen|dia|thien|tien|than
roles: {primary: growth|offense|defense|stability, secondary: []} # new roles only with consumer
path_tags: [sword|body|spell]
element_tags: [metal|wood|water|fire|earth|none]
identity_one_sentence: "why player equips/trains this rather than another"
passives:
  - source_id: named_unique_authority
    channel_or_event: real_authorized_consumer
    mode: flat|percent_add|percentage_points|filtered_effect|named_rule
    magnitude: PROPOSED_OR_SOURCE
    active_slot_rule: main_only|aux_allowed
unique_conflict_keys: [family_or_passive_key]
requirements: {realm: authored_or_null, body: authored_or_null, root: authored_or_null, mastery: []}
skill_relation: independent|tag_synergy|explicit_prerequisite
successors: [authored_ids_only]
origin_sources: [{source_id: registered_or_proposed, scope: normal|elite|boss|secret|research|sect|discovery,
                  full_manual_pool_id: registered_or_proposed,
                  fragment_pool_id: registered_or_proposed,
                  exclusive: true|false}]
fragment_requirements: PROPOSED_OR_SOURCE
archive_once: true
learn_requirements: {time_ticks: PROPOSED, contribution: PROPOSED, personal_stones: PROPOSED}
provenance_status: SOURCE_P2|LOCKED_DESIGN|PROPOSED|LIVE_V2|TESTED|VISUAL_ACCEPTED|BLOCKED
```
The schema is a design contract, **not deployed GDScript/YAML**. `role` names outside existing P2 enum must be kept as design tags until V2 runtime authority exists.

## 3. Family matrix first; count depends on real build/play decisions

| Family identity | Decision/player fantasy | Compatible SOURCE P2 roles/paths | Element affinity (DESIGN CANDIDATE, not hard law) | Existing P2 anchor | New content condition |
|---|---|---|---|---|---|
| **A. Dưỡng Khí / Tu Tâm** | cultivation throughput, stable long-term growth, may sacrifice battle effect | growth, spell | Mộc/Thủy, none | `duong_khi_quyet` | each variant must add actual cultivation behavior or unique precondition, not duplicate raw +XP |
| **B. Hộ Thể / Kim Cương** | body durability vs burst, counter incoming effects with actual mitigation source | defense, body | Thổ/Kim | `huyen_giap_cong` | distinguish sustained defense from shield-specific skill, no free shield proc |
| **C. Huyết Chiến / Võ Đạo** | aggressive physical build, offensive sacrifice or opportunity | offense, body | Hỏa/Thổ | `liet_chien_quyet` | risk/hp conditions must have actual combat trigger and cap; no new generic lifesteal |
| **D. Kiếm Đạo / Phong** | sword synergy, direct vs mobile skill tempo | offense, sword | Kim/Mộc | `thanh_phong_kiem_quyet` | style tags ≠ automatic weapon_requirement; authored sword-skill consumer |
| **E. Ngũ Hành Pháp Tu** | choose fire burn/direct, water stability/control, earth resistance, etc. | offense/stability, spell | Hỏa/Thủy/(others when authored) | `xich_viem_chan_quyet`, `han_nguyet_tam_phap` | do not invent action, freeze, fireball or DoT if not in Combat V2 |
| **F. Định Thần / Tịnh Tâm** | anti-debuff and steady learning/casting | stability, spell | Thủy/Thổ | Hàn Nguyệt overlaps E; choose to **merge** until distinctive supported consumer | must beat redundancy gate, not fill two slots with identical effect |
| **G. Hộ Đạo / Trợ Chiến** | valid ally support, shielding/healing synergy, weaker solo dps | support (NEW PROPOSAL), spell/body | Mộc/Thổ | NONE | requires real support skill channel and active vs aux rules before data authored |
| **H. Bách Nghệ / Ngộ Đạo** | work-specialization or Sect research/teaching utility | profession (NEW PROPOSAL) | any/root conditional | NONE | real production/technique study event consumer + no buff shared across 1,000 off-job disciples |
| **I. Cơ Duyên / Tầm Bảo** | specialty find/event opportunity, **not** a universal rarity multiplier | stability/growth (CANDIDATE) | none | NONE | requires real loot roll/event consumer; if absent leave BLOCKED, no fictional lucky drops |

**C4 decision logic:** Start with A–E as documented actual P2 anchors. F may be merged with E to avoid redundancy; G/H/I remain conditional extension families only after real consumers & distinct benefit. Grade quotas emerge from occupancy after design: e.g. a Thần book might be a rare authored successor of family D, and a separate Thần-origin exclusive book of family G; no fixed requirement that there be 10 Thần books.

## 4. Real inventory: six P2 identities, provenance explicitly preserved

**SOURCE CODE:** `godot/src/simulation/technique/technique_system.gd` at main SHA above. These are **P2 definitions**, not full V2 content identities. P2 has `MAX_LEARNED_TECHNIQUES=3`, **one** active technique, `MAX_TECHNIQUE_LEVEL=5`; old grade enum `common/mysterious/earth/heaven`, NOT V2 Tiên/Thần. Preserve identities/history when V2 migration is separately authorized; do not copy `combat_per_level` into CombatStats V2 Attack.

| P2 ID / name | P2 rarity | Path | Element | Role | Gacha weight, NOT V2 loot rate | P2 fragment_required |
|---|---|---|---|---|---:|---:|
| `duong_khi_quyet` — Dưỡng Khí Quyết | common | spell | wood | growth | **38** | **8** |
| `huyen_giap_cong` — Huyền Giáp Công | mysterious | body | earth | defense | **20** | **12** |
| `liet_chien_quyet` — Liệt Chiến Quyết | mysterious | body | fire | offense | **18** | **12** |
| `thanh_phong_kiem_quyet` — Thanh Phong Kiếm Quyết | earth | sword | metal | offense | **10** | **18** |
| `xich_viem_chan_quyet` — Xích Viêm Chân Quyết | earth | spell | fire | offense | **9** | **18** |
| `han_nguyet_tam_phap` — Hàn Nguyệt Tâm Pháp | heaven | spell | water | stability | **5** | **30** |
| **P2 TOTAL** | 4 legacy grades | 3 paths | source 5 elements subset | 4 roles | **100 old gacha weights** | source P2 only |

**Explicit compatibility finding:** P2 `roll_farm_loot()` uses `danger`1..3, fragments with per-call probability `0.18 + danger*0.08` (26%/34%/42%), and `_weighted_technique_pick(rng,max_rarity)`. This is a P2 `roll_farm_loot` invocation, **not proof of per-monster CARE drop rate**. P2 `gacha()` spends 100 Sect Stones per call; weighted among six eligible books; do not map this draw across 30 realms or let gacha money alter boss drop table. P2 `deposit_special_inventory()` stores fragments in `state.sect.technique_fragments`; V2 canonical archive/warehouse migration must avoid a parallel private reward bag and duplicate receipt. Existing six source examples guide categories only.

## 5. How to decide final counts without choosing a count

For each family: author role choices and spell/weapon/body build coverage FIRST, then `named mechanic/unique key`, then acquisition opportunity, only then grade. Reject proposed technique if:
- same primary passive+same acquisition+same prerequisites as existing book with only different name/number;
- no real Combat V2/cultivation/profession consumer or source registration plan;
- mandatory chapter requires Boss-only full manuscript with no legitimate alternative;
- a high-rarity manual from R30 Boss is required by all R05 characters with no access;
- successor stacks with predecessor, double-archives library or uses unapproved random skill action;
- useless just because character changed cultivation realm.

**Result metrics per family (NOT counts locked):**
`number_of_distinct_working_builds`, `consumer_test_coverage`, `reusable_vs_exclusive_sources`, `acquisition_P50/P90`, `active_1+2_synergies`, `duplication/conflict_cases`, `P2_compatibility_loss=0`. Keep authoring until all needed *player choices* exist; do not author filler just to satisfy ten "God books".

## 6. Grade and source applicability rules

- Phàm/Huyền/Địa/Thiên/Tiên/Thần is rarity/depth; rare full manuals may be exclusive to a Secret Realm, a named boss or personal Diễn Hóa; normal mobs may give fragments of certain rares when deliberately authored.
- High-grade Sect transmission only needs one first complete manual but can have higher **study prerequisites/cost/time**; first rare finding is the main chase, not 1000 rare book consumptions for 1000 disciples.
- Exclusive source means **zero chance from every unlisted source**, not a global `p=0.0001` override for generic farming. For mandatory growth families, stable common/fragment path or justified fallback is needed.
- Every source points to a **real ID** (region/species/encounter/Boss/Secret). `MonsterCatalogueV2` currently has only a few early species, e.g. `hac_lang_vuong` marked `loot_ready=false`; assigning it a V2 manual is **PROPOSED**, not an existing loot.
- Detailed event-scoped math, P50/P90 and policy choices live in companion document `CPV2_C4_DROP_SOURCES_PROBABILITY_AND_ARCHIVE_ECONOMY_2026-10-23.md`.

## 7. Workstream boundary and next decisions

**Already owner selected:** C4; no new fixed book count, no global drops, no universal grade multiplier, S2/F1/Q1 and selected X1 D2–D5 unaffected.  
**Open choices for this CPV2 pack:** catalog family admission rule (strict consumer proof vs reserve designs), source exclusivity + basic fragment fallback policy, and whether first pilot should prioritize full starter manual + repeatable fragments. All percentages in companion document **PROPOSED**.  
**Future code needs separate owner permission.** Nothing here authorizes a new P2 or CARE loot system, a God-tier ability, a new character stat, nor changes to PR #24/#25.

**DESIGN gate CP-01:** owner approves taxonomy/source policy; two source-genuine P2 technique builds and one optional named rare path have source→reward→archive→learn→equip→actual authorized effect with exact consumer evidence. If it fails, report BLOCKED rather than pretending the content is implemented.
