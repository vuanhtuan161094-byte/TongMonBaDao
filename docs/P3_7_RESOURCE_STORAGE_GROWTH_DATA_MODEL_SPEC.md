# P3.7 — RESOURCE, STORAGE & BASE GROWTH DATA MODEL SPEC

Status: CANONICAL DESIGN AUTHORITY  
Updated: 2026-10-06

Parents:
- `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`
- `docs/P3_7_BUILDING_TREE_SPEC.md`
- `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`
- `docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`
- `docs/DISCIPLE_MASTER_SCHEMA.md`

This spec owns:
- distinct resource identity;
- realm/tier progression;
- one large Sect Warehouse;
- reserve/lock rules;
- shared passive cultivation direction;
- six-foundation integration.

There is no Phẩm Lực system.

---

# 1. Resource items stay distinct

Do not merge different item identities into one generic material-power pool.

Examples:
- Phàm Thiết;
- Thanh Thiết;
- Huyền Thiết;
- Hàn Tủy Thiết;
- Thanh Linh Thảo;
- Tử Vân Thảo;
- Huyết Linh Sâm;
- Yêu Đan;
- Giao Long Cốt.

Each resource definition has:
- `resource_id`;
- display name;
- family/tags;
- realm/tier;
- stackability;
- source tags;
- usage tags;
- market value;
- optional special properties.

Different resources remain visibly different.

---

# 2. Realm/tier progression

Resources use a cultivation-flavored progression ladder.

Example:
1. Phàm;
2. Luyện Khí;
3. Trúc Cơ;
4. Kim Đan;
5. Nguyên Anh;
6. later realms appended as content expands.

Higher progression reveals higher-tier resource IDs.

Example mineral family:
- Phàm Thiết;
- Thanh Thiết — Luyện Khí;
- Huyền Thiết — Trúc Cơ;
- higher metals later.

The tier is readable category data.
It is not a continuous power number.

---

# 3. No Phẩm Lực

Remove continuous Phẩm Lực from P3.7 resource gameplay.

Do not use:
- base_pham_luc;
- total_pham_luc;
- construction PL;
- processing PL;
- crop PL;
- output PL.

Progression uses:
- explicit resource IDs;
- realm/tier;
- quantities;
- building level;
- profession level;
- recipe/crop requirements.

If a stronger material is materially different, create a different resource ID.

Example:
- Thanh Thiết;
- Huyền Thiết;
- Tinh Luyện Huyền Thiết.

This is easier for the player to read and balance.

---

# 4. No Sect Warehouse capacity limit

Sect resource storage is logically unbounded for normal stackable resources.

Stacks may reach millions or more.

Do not:
- stop production because storage is full;
- require warehouse upgrades merely for numeric capacity;
- split identical resources into many small stacks.

Use a safe integer range.

---

# 5. Warehouse building purpose

Kho Tông Môn remains useful for automation rather than storage-space gating.

Possible functions:
- reserve rules;
- protected/locked resources;
- routing to production;
- routing to market;
- supply restock;
- priority rules;
- reporting/search/filter;
- unique-item handling;
- later multi-location logistics.

Do not add a hidden capacity ceiling without explicit user approval.

---

# 6. Stack model

Canonical commodity stack key:

**resource_id**

A stack stores:
- quantity;
- shared metadata only when needed.

Different realm/tier/material identities use different resource IDs.

---

# 7. Unique items remain individual

Normally individual:
- equipment;
- Pháp Bảo;
- Chí Bảo;
- manuals/unique techniques;
- story/quest objects;
- boss artifacts;
- rolled crafted items.

They may store:
- unique id;
- ownership;
- affixes;
- durability;
- history;
- creator.

They do not use commodity-stack semantics.

---

# 8. Construction material consumption

Normal construction consumes explicit quantities from allowed material families.

Examples:
- Linh Mộc-family quantity;
- Khoáng-family quantity;
- Spirit Stones;
- exact milestone specialty item when needed.

Requirements are quantity-based.

### Economy V2 common bulk-unit rule

The approved opening producer scale treats abundant common resources as bulk commodities:
- Thanh Thiết;
- Linh Mộc;
- Thanh Linh Thảo;
- Linh Cốc production/consumption where an explicit consumer exists.

When the V2 bulk economy is active, existing routine consumers that use **common** materials
must be expressed on the same order of magnitude rather than consuming historical 1–3-unit
amounts. Current compatibility adapter scales routine Forge/common construction inputs by
×1,000. This adapter does **not** scale:
- Yêu Đan;
- Tinh Lang Bì;
- milestone components;
- other rare/discrete drops.

The adapter is a compatibility bridge for existing consumers, not permission to multiply
future recipes blindly. New recipes should author real quantities directly.

Opening minimum sinks include:
- Hồi Xuân Đan: 500 Thanh Linh Thảo → 1 pill per 6-minute base recipe;
- Linh Cốc logistics: 2 units / disciple / 30 simulation minutes (~96/day), respecting Warehouse
  reserve/lock; shortage is audit-only in this packet and has no hunger penalty.

Example:
- bulk common construction quantities;
- explicit rare components;
- Spirit Stones kept in their own currency scale.

Higher-level construction may require higher-tier resource IDs explicitly.

Do not convert mixed materials into one hidden power total.

Warehouse reserve/lock rules must be respected.

---

# 9. Higher progression unlocks higher-grade resources

Examples:
- higher Mining + deeper Mine -> higher-tier ores;
- higher Linh Thực + stronger fields -> higher-tier crops;
- higher hunting regions -> stronger monster materials;
- higher crafting -> recipes using those materials.

Use explicit content unlocks, not continuous PL thresholds.

---

# 10. Universal passive cultivation

Every living disciple passively gains cultivation during ordinary work.

Shared work-cultivation formula is owned by:
`docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`

Profession-specific systems must not invent separate work-Tu-Vi formulas.

Focused cultivation, Secret Chamber and hunting remain different activity categories with stronger progression.

---

# 11. Six-foundation roles

Use the canonical six foundation fields:

- Tư Chất;
- Căn Cốt;
- Cơ Duyên;
- Thông Tuệ;
- Mị Lực;
- Tiềm Lực.

Shared work formulas are owned by:
`docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`

Canonical P3.7C1 meaning:

- Tư Chất -> base cultivation/Tu Vi progression;
- Căn Cốt -> body-training progression, not generic work stamina;
- Cơ Duyên -> meaningful luck/outcome checks;
- Thông Tuệ -> learning/profession/mastery progression;
- Mị Lực -> social power and Dẫn Tiên recruitment;
- Tiềm Lực -> long-term Realm + Body stat-growth quality.

The open-point formulas and Dẫn Tiên rules are owned by:
`docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`.

Do not multiply all six into every profession.

---

# 12. Base cultivation UI

The player should be able to see a derived value such as:

**Tu Vi nền: +120/giờ**

Advanced detail may explain existing cultivation modifiers.

Work adds only the shared profession-level work-cultivation modifier.

---

# 13. At-home autonomous self-investment

A disciple at the sect may autonomously spend personal Spirit Stones on:
- Secret Chamber;
- pills;
- equipment;
- talismans;
- Pháp Bảo;
- market goods;
- later auctions/services.

AI choice depends on:
- personality;
- wealth;
- realm progress;
- injury;
- role;
- policy;
- expected utility.

---

# 14. Pill logic

Pills may support:
- direct cultivation gain;
- cultivation-rate buff;
- breakthrough;
- healing;
- stamina;
- combat preparation.

Lower-tier pills may remain usable at higher realm but become economically inefficient instead of being hard-blocked unless content explicitly requires a restriction.

---

# 15. Locked decisions

1. Resource IDs remain distinct and visible.
2. Realm/tier replaces continuous Phẩm Lực.
3. Resource use is quantity-based.
4. Commodity stacks may become extremely large.
5. No normal warehouse capacity cap.
6. Warehouse progression is automation/logistics, not numeric storage.
7. Higher progression unlocks higher-tier resource IDs.
8. Unique gear/artifacts remain individual.
9. All living disciples have passive cultivation growth.
10. Shared work/foundation formulas come from the profession modifier authority.
