# TRANG BỊ V2 — 10 Ô, 12 PHẨM, THUỘC TÍNH VÀ CHÂN VĂN

Updated: 2026-10-08
Status: **USER-APPROVED DESIGN STRUCTURE — NOT IMPLEMENTED**.
Authorities: `docs/COMBAT_STATS_V2_SPEC.md`, `docs/COMBAT_SKILLS_V2_SPEC.md`, `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`, `docs/REALM_LADDER_V2_SPEC.md`, `docs/BODY_CULTIVATION_V2_SPEC.md`, `docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`. Sets: `docs/EQUIPMENT_SETS_V2_SPEC.md`.

## 1. Ten ordinary equipment slots

| ID | Position | Primary identity | Item types |
|---|---|---|---|
| `weapon` | Vũ Khí | Attack, basic action, weapon requirement | Kiếm, Đao, Thương, Quyền Sáo, Pháp Trượng, Pháp Phiến, Linh Châu |
| `head` | Mũ | Resist control/critical; stabilize casting | Chiến Khôi, Đạo Quan, Hồn Quan |
| `armor` | Giáp | HP, Defense, Damage Reduction | Trọng Giáp, Khinh Giáp, Pháp Bào |
| `cloak` | Phi Phong | Movement, Cast Speed, mobility context | Chiến Phi Phong, Phong Ảnh Bào |
| `bracers` | Hộ Uyển | Defense, guarding/counter-skill support | Thiết Uyển, Hộ Đạo Uyển |
| `gloves` | Thủ Sáo | Basic Attack Speed, Cast Speed, professional craft | Chiến Thủ Sáo, Pháp Văn, Bách Nghệ |
| `belt` | Đai Lưng | HP, sustain, expedition | Hộ Mệnh Đái, Viễn Chinh Đái |
| `boots` | Giày | Movement, slow/terrain/travel | Phong Hành Ngoa, Trấn Nhạc Ngoa |
| `pendant` | Ngọc Bội | Elemental skill effect/resistance, cultivation/work | Ngũ Hành Ngọc, Dị Linh Ngọc, Tụ Linh Ngọc |
| `ring` | Nhẫn | Cooldown Recovery, Effect Hit, specialization | Chiến Giới, Huyền Ấn Giới, Bách Nghệ Giới |

All ten are ordinary equippable positions from early game; an actual item has its realm/equip requirements. **Separate**: 3 slots Phù, 2 slots Pháp Bảo, 4 consumable-loadout slots. Thus 15 equip/active positions + 4 consumable positions; old **five ordinary + three Phù + two Pháp Bảo = ten total** is obsolete.

Weapon family names and detailed attack patterns remain content to author, not proof of live Godot implementation. Weaponless is legal where skill `weapon_requirement=none`. Quyền Sáo weapon does not occupy the `gloves` slot. `style_tag=sword` does NOT automatically require sword; actual `weapon_requirement=sword` does. No universal Sword Mastery stat.

## 2. Twelve grades and affix capacities

| Grade | Quality | Normal sub-lines | Rare special-stat lines | Chân Văn capacity |
|---:|---|---:|---:|---:|
| 1 | Phàm | 0 | 0 | 0 |
| 2 | Tinh | 1 | 0 | 0 |
| 3 | Thượng | 2 | 0 | 0 |
| 4 | Cực | 3 | 0 | 0 |
| 5 | Linh | 3 | 0 | 0 |
| 6 | Huyền | 4 | 0 | 0 |
| 7 | Địa | 4 | 1 | 0 |
| 8 | Thiên | 5 | 1 | 0 |
| 9 | Vương | 5 | 1 | 0 |
| 10 | Thánh | 5 | 2 | 0 |
| 11 | Đế | 6 | 2 | 0 |
| 12 | Chí Tôn | **6** | **2** | **1 inscribable slot** |

Three **noninterchangeable layers**:
1. **6 normal sub-lines maximum**: ordinary existing stat/channel modifiers, no extra combat action.
2. **2 rare/special-stat lines maximum**: stronger or narrower conditional existing-stat modifiers. E.g. stronger *own* sword skill against a defense-debuffed target, or Shield Effect for shield skills already learned. These **may NOT** spawn attacks, shields, cleanses, counterstrikes, marks or autonomous effects.
3. **1 individual Chân Văn**: rare mechanic with real trigger/condition, owned event, target, expiry, ICD, stacking and effect tier. The slot is available at Chí Tôn, but **not pre-filled by merely owning Chí Tôn**.

Two grades with same number of affix lines may differ in rarity/quality of rolled lines. Grade != disciple quality; grade and `equipment_realm_index 1..30` are independent. Ten Tu Vi realms per macro world (Nhân 1..10, Tiên 11..20, Thần 21..30), no 300 item realm tiers. A Chí Tôn low-realm item cannot erase arbitrarily many realm gaps. Exact item base stats and grade multipliers are not locked.

## 3. Affix pools: prevent all 10 pieces rolling the same six strongest percentages

A = broad/general existing stats, **at most two A lines per single item**.
B = specialized combat channel, skill/path/element/target condition, **still only modifies an existing outcome**.
C = profession/cultivation/expedition/activity-specific channel, only when a real consumer exists.

Each item template has preferred A/B/C pool, rare explicitly authored off-slot exceptions and source-specific eligibility. No identical affix ID repeated on a single item; normally no more than two B lines augmenting precisely the same skill/action family, pending later benchmark. Professional pieces may take all six lines from eligible B/C; two A are maximum, not compulsory. No dynamic random pools containing every stat for every slot.

| Slot | Normal A pool examples | B specialization examples | C work/other examples |
|---|---|---|---|
| Vũ Khí | Attack, Crit Chance, Penetration | Sword/weapon skill direct damage, basic attack, tagged element | Named crafted specialty only |
| Mũ | HP, Crit Resistance, Effect Resistance | Control duration resisted, own cleanse effect, cast skill effect | Profession XP, technique-study if consumer exists |
| Giáp | HP, Defense, Damage Reduction | Shield Effect, Healing Received, element resistance, existing guard skill | Authored environmental-expedition modifier |
| Phi Phong | Movement, Cast Speed, Effect Resistance | Wind skill, a **real** mobility-skill follow-up | Travel-expedition consumption if map cost exists |
| Hộ Uyển | Defense, HP, Penetration | Existing counter/guard skill effect, vs defense-debuffed targets | Specifically authored hazardous-work consumer |
| Thủ Sáo | Basic Attack Speed, Cast Speed, Effect Hit | Basic/hand-skill effect, healing/shield effect | Luyện Khí/Đan/Phù work speed and XP |
| Đai Lưng | HP, Defense, Healing Received | Eligible shield received, low-HP defensive magnitude | Expedition component; injury recovery once implemented |
| Giày | Movement, Defense, Effect Resistance | Slow mitigation, a real movement skill's effect | Explicit travel/hauling/expedition component |
| Ngọc Bội | HP/Effect Resistance only on authored templates | Element damage/resistance, own Tương Sinh skill effect | Real cultivation gain, Linh Thực XP/crop affinity |
| Nhẫn | Cooldown Recovery, Crit Chance, Effect Hit | Tagged skill, DoT, debuff, weak-target damage | Single profession speed/XP, real rare-outcome check |

The pool above is **eligibility direction**, NOT completed affix database, proc registry or final numeric coefficients. Each numeric line uses canonical flat / percent-add / percentage-point / special multiplier semantics. Crit, Effect Hit and Defense Penetration are not arbitrarily new formulas. No generic Dodge/Accuracy, physical/magical Attack split, universal Mana, turn-order Speed, universal Block/Lifesteal/Reflect/Threat, Kiếm Ý stat, combat-power authority. Skill area/range/projectile/target count are authored action properties, not universal character attributes.

## 4. Example same-realm weapon quality

- Kim Đan Phàm kiếm: realm-scaled base Attack, **0** sub-lines, no specials, no Chân Văn.
- Kim Đan Huyền kiếm: base Attack + **4** legal normal lines, e.g. Crit Chance, Crit Damage, sword skill magnitude, Penetration.
- Thần Nhân Chí Tôn kiếm: base Attack + **6** legal normal lines (max two general) + **2** conditional rare stat lines (e.g. sword-skill bonus vs defense-down target; Crit Damage of a legitimate eligible sword skill vs low HP target) + **one available Chân Văn slot**. A separately acquired/inscribed Chân Văn can create a bounded sword echo. Neither line types nor this example guarantee an ideal roll or numeric %.

A rare special-stat line never creates the echo itself. A set bonus never creates a "Chân Văn Cộng Hưởng": sets modify existing stats, as detailed in `EQUIPMENT_SETS_V2_SPEC.md`.

## 5. Combat / profession boundary and anti-"bánh vẽ" rule

**Already-defined V2 channels**: Attack/Defense/HP, Move/Basic/Cast/Cooldown, Crit/Crit Damage/Crit Resistance, Penetration, Effect Hit/Resistance, Damage Reduction, elemental resistance, Direct/Basic/DoT/Healing Done/Healing Received/Shield/Control Duration/skill-specific and elemental filtered effect modifiers.

**Consumer-gated until implemented**: forging/Alchemy/Talisman result-quality upgrades, special ore outcomes, crafting-material savings, autonomous weapon clones, teleport through obstacles, repeated resurrection, production copies. An attractive line with no existing real work/skill/event consumer is NOT shippable. Named Chân Văn must identify its trigger, eligible owner/source, target, event order, ICD, cancel/expiry, effect tier, cap and actual runtime support.

Permitted overlapping effects across Huyết Mạch, Thể Chất, Mệnh Cách, Linh Căn, Kỹ Năng and Pháp Bảo, using **canonical stacking** (ordinary same-channel percentage add, remaining-damage defense/resist, explicit buff family policies). No unjustified ban on overlap. Do not allow extra-hit, reflect, heal or set to recursively spawn each other forever.

Profession Level remains primary speed source. Same work-speed channel does not also multiply routine production output; rare/quality upgrades require the consumer's true check. Linh Điền snapshots grow-cycle/worker effects at start and only resolves one actual harvest; don't swap one rare item across 100 growing plots. Work buffs never apply merely for wearing while idle.

Expedition Stamina (100/day; matching-body ~18h; body-only max ~22h; ordinary with support max 24h) is outside sect production. Travel and camp/hazard costs require explicit components. Don't add a generic extra productive stamina resource.

## 6. Ownership, legality, scale, open work

**Every gear instance belongs to the Tông Môn**. Equipped disciple is assignee, not owner. All item/material loot enters canonical Sect Warehouse / unique-item registry, no reward loot bag or private gear market. Auto-equip needs team/role templates, locks/reservations and holistic evaluation of 2/3/4 set thresholds at 1,000–3,000 disciples (potentially 30,000 ordinary pieces equipped).

Default equipment legality is Tu Vi OR Luyện Thể tier for ordinary physical gear; spiritual-force-only items use Tu Vi, body-exclusive items use Luyện Thể as explicitly authored. Forge ability is separate from equipment eligibility. Preserve `style_tag` vs `weapon_requirement` and allow cross-path weapons where skills permit.

**OPEN, NOT LOCKED**: RealmBodyCore Attack/Defense/HP and equipment % values; weapon detailed attack patterns; final named 80+ line pool and roll distributions; forging/refining/quality improvement/inheritance; enhancement cap (**old provisional +15 is not the final lock; +10/+20/+30 also not user-confirmed**); recipes/cost/source percentages; individual Chân Văn catalogue and run-time hooks; Kiếm Cốt measurable effect; 30-map/300-cluster content projection independently.

**NO CODE IMPLEMENTED OR GODOT PASS CLAIMED.** Existing P2.6 `equipment_system.gd` has only weapon/armor/talisman and old qualities; it remains legacy compatibility until an explicit tested V2 migration (save/load + deterministic seed + old-item identity).
