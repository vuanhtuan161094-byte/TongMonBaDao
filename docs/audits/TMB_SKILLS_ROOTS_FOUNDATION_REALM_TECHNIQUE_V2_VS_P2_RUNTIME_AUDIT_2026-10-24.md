# TÔNG MÔN BÁ ĐẠO — HỆ THỐNG SKILL ĐANG CÓ GÌ? CANONICAL V2 vs P2 RUNTIME / PR #29 S1

**Ngày 2026-10-24** · DOCS/READ-ONLY AUDIT, không sửa code/không cấp quyền lập trình.  
**Source:** main `29b5fba448b0178cb520a4ada44b375b4b934e31`; PR #27 `deeae081bcfbe1413d4cf60a29db7e58150888b5`; PR #29 S1 `9522812e91b7ca5bc0cc108eb92e000e930fe850` QA PENDING. UI workstream độc lập.

## 0. Kết luận quan trọng
Dự án đã **có thiết kế hoàn chỉnh cấp hệ thống** cho kỹ năng V2 và công pháp V2. Chưa được tích hợp hoàn chỉnh trong runtime. KHÔNG tự bịa lại hệ skill mới bằng các quyết định dựa trên P2 cũ.

**Bộ spec thẩm quyền:** `docs/COMBAT_SKILLS_V2_SPEC.md` (DESIGN LOCKED — NOT IMPLEMENTED), `docs/TECHNIQUE_V2_SPEC.md` (DESIGN LOCKED — NOT IMPLEMENTED), `docs/SPIRITUAL_ROOT_V2_SPEC.md` (FULL DESIGN LOCKED — NOT IMPLEMENTED), `docs/REALM_LADDER_V2_SPEC.md`, `docs/BODY_CULTIVATION_V2_SPEC.md`, `docs/DISCIPLE_MASTER_SCHEMA.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`. Exact canonical authority over code proposals; inspect all before S2 CODE packet.

## 1. Sáu tầng trong một đệ tử
1. **D7 Tam Căn + Tứ Tính**, 7 intrinsic attributes, dual independent budget. PR27 implemented/139 checks reported; Tâm Tính no runtime consumer. Potential only buffs Tu Vi Core HP/ATK/DEF. Aptitude +0.25% natural TuVi EXP per point; Constitution +0.20% natural Body EXP per point; Comprehension design +0.15% learning/mastery EXP per point, BUT `FoundationSystem.learning_gain_factor` alone does not show direct use by current `TechniqueSystem.train_active_technique`, which currently uses base12 × P2 root mastery factor. Do not claim D7 Comprehension already boosts combat-skill XP.
2. **Spiritual roots**: P2 legacy runtime `SpiritualRootSystem` has 5 base tags and rarity-specific matching multipliers (ordinary matching skill ×1.08, missing ×0.92). V2 canonical spec instead owns 1–5 individual roots with purity 1..100, matching skill effects, learning, resistance, passive elemental channels and perfected-root resonance; **not implemented**. Do not treat legacy `spiritual_root_purity` scalar as canonical V2 per-element purity.
3. **30 Tu Vi × 10 + 30 Body × 10**: V2 canonical real progression (`DiscipleRealmProgressV2`), not the 17-step legacy `cultivation_stage_index`.
4. **Công Pháp**: runtime legacy P2.3 has max 3 learned, one active, levels 1..5 and mastery XP/material upgrading. Canonical V2 model: 1 Chủ Tu +2 Phụ Tu active, multiple learned, 5 named mastery stages Sơ Học/Nhập Môn/Tiểu Thành/Đại Thành/Viên Mãn, manuscript/archive Tàng Kinh Các; **not implemented in full**. Công Pháp does NOT automatically grant complete move set; may be independent, synergize, or explicit skill prerequisite.
5. **Combat skill**: P2 has 9 authored IDs (element, path, ratio, range, cast, cooldown, min_stage) and `learned_combat_skills: Dictionary[skill_id,bool]`; learned skill itself **has no persisted level/mastery**. P2 legacy CombatSystem handles dash/combo/utility in OLD 1v1, but MapBattleV2 multi-target authoritative runtime on PR29 adds learned damage/burn/weaken/guard only (QA PENDING). Dash/fire_combo still deferred in CARE MapBattle.
6. **Equipment**: equipped item effects enter sanctioned CombatStatsV2 channels and skill multipliers; future item power budget separate. No phony `combat_power` to V2 ATK conversion.

## 2. Canonical Combat Skills V2 — already LOCKED, still not live
- Loadout at maturity: **1 Thường Kỹ + 4 Chủ Động + 6 Bị Động Chiến Đấu**; slots open gradually through Nhân Giới; not guaranteed at birth.
- Three evolution waves: **Nhân Giới Tu Vi realms1–10** builds complete base skill language; **Tiên Giới11–20** advances family to named successor; **Thần Giới21–30** adds bounded law-tier/advanced families. Skills aren't merely +17 star levels; family branches and predecessor/successor mutual exclusion apply.
- Personal mastery: **Sơ Học → Nhập Môn → Tiểu Thành → Đại Thành → Viên Mãn**, continuous mastery XP, milestone gates; progression basis per skill **Tu Vi / Luyện Thể / hybrid**, not generic old stage index. Thông Tuệ accelerates valid mastery XP (not cap). Matching spiritual root helps corresponding mastery (not universal mana).
- Learning requires legitimate Sect manual/transmission or self-comprehension, appropriate true Tu Vi/Body realm, authored path/technique prerequisites and cost/time. No universal hard path prohibition from mere differing element.
- Passive slot only needed for triggered/proc/party/aura effects; static self-only passive can derive its own approved stat channel.
- A skill's authored type, target shape, max targets, cast, cooldown, conditional statuses, buffs/debuffs, element matchup and source IDs must be authoritative and replay-safe. Effect ownership is MapBattle; presentation only listens to settled events.

## 3. Current nine P2 authored values (the prototype set)
| Skill | Path / Element | Ratio | Cast / Cooldown | Legacy min_stage | S1 MapBattle |
|---|---|---:|---|---:|---|
| Thanh Phong Trảm | Sword / Kim |1.35|.30s / 2.8s|0| live |
| Truy Phong Bộ | Sword / Mộc |.75|.25s /5s|4| deferred S2 |
| Ngự Kiếm Thuật | Sword / Kim |1.70|.65s /6.5s|9| live |
| Chấn Sơn Quyền | Body / Thổ |1.45|.45s/3.4s|0| S1 code QA pending |
| Kim Cương Hộ Thể | Body / Thổ |0|.25s/8s|3| S1 code QA pending |
| Bất Động Thân | Body / Thổ |0|.45s/14s|9| S1 code QA pending |
| Hỏa Cầu | Spell / Hỏa |1.15|.65s/3.8s|0| S1 code QA pending |
| Hàn Sương Ấn | Spell / Thủy |.90|.80s/5.5s|3| S1 code QA pending |
| Liệt Diễm | Spell / Hỏa |1.45|1.0s/7s|9| deferred S2 |

**Critical migration defect/debt:** `CombatSkillSystem.can_learn_skill` currently checks `disciple.cultivation_stage_index>=min_stage`; this belongs to `CultivationSystem.STAGES` legacy 17-step track (0=Luyện Khí tầng1, 9=Trúc Cơ early), **NOT** V2 `DiscipleRealmProgressV2.current(...).cultivation` 30×10. New D7 recruitment continues to carry legacy stage index for compatibility. This must be formalized to V2 TuVi/Body skill gates, not remapped by arbitrary numeric identity, before rolling out full V2 catalogue.

**Second debt:** the old P2 CombatSystem has context-sensitive `_skill_utility`, dash and fire combo, but is a separate legacy resolver. DO NOT copy a second authority or let it settle the same CARE encounter. MapBattleV2 is the target.

## 4. Ngũ hành code vs spec
- `CombatStatsV2.ELEMENTS` knows 10 damage/resistance tags (five + lightning, wind, ice, yang, nether). Current `CombatStatsV2.resolve_direct_hit` accepts explicit `elemental_matchup_factor`, but `MapBattleV2._deal_direct` calls with **1.0**; therefore **do not claim complete automatic Kim–Mộc–Thủy–Hỏa–Thổ mutual overcoming cycle / status interactions** is implemented in live CARE.
- P2 `SpiritualRootSystem.technique_effect_multiplier` matches labels with legacy root-quality factors; stage `technique_mastery_multiplier` is 1.15 matching / .90 nonmatch. Legacy P2 technique train session base12×root factor; source does not directly use D7 Comprehension. V2 spiritual roots per-element purity & resonance remain authoritative design NOT CODE.
- Canonical V2 skill effects grow per authored scalable channels, not all aspects: damage/heal/shield may scale, but do not multiply cooldown/range/duration automatically. Root doesn't force every Fire skill to burn.

## 5. Current three DIFFERENT meanings of "lên cấp"
1. **Tu Vi / Body rank-up**: real 30×10 cultivation tracks grow CombatStats core. These are character progression, NOT skill levels.
2. **P2 technique upgrade**: `learned_techniques[technique_id]={level:1..5,xp}`, cost XP `80×level²`, train+12 XP base with P2 root mastery factor, then consume authored materials and call `upgrade_technique`. It is **NOT** the V2 mastery stage system yet and cannot be asserted to level an individual combat skill.
3. **P2 combat skill learned bool**: no XP, level, rank, personal mastery or evolution state in `learned_combat_skills`. Skill ratio static per ID, amplified by D7 Potential (via base ATK), appropriate current P2 roots/path/technique affinity and equipment; no ability to upgrade Thanh Phong Trảm skill level from1→2 presently.
4. **P2 path experience** (different again): sword/body/spell path EXP from cultivation/valid combats; path depth caps at 1200 EXP giving up to +20% matching path-skill effect; this is a specialism proficiency, not an individual skill level.

## 6. D7 seven points — actual and not actual skill effects
| Attribute | Current known SOURCE effect | Direct skill mastery? |
|---|---|---|
| Tư Chất | +0.25% valid natural Tu Vi EXP/pt | Indirect through realm progress, not skill mastery |
| Căn Cốt | +0.20% valid natural Body EXP/pt | Indirect Body progression, not current individual skill level |
| Tâm Tính | D7 stores point and quality; **no runtime consumer yet** | NO |
| Tiềm Lực | +0.05% **RealmCore** HP/ATK/DEF/pt only for D7 | Raises ATK of skill through actual stats |
| Thông Tuệ | +0.15%/pt learning/mastery intended and helper provided | **No confirmed combat skill mastery consumer**; don't mark implemented |
| Cơ Duyên | luck RNG score/loot/fortune sources if explicitly consumed | NO generic skill damage |
| Mị Lực | social/guidance score | NO generic skill damage |

**Do not double-count** one stat as both talent and innate damage. Any proposed Mind skill utility/learning should be separate design permission.

## 7. What must be decided/implemented before large-scale catalogue (not before S1 QA)

**Recommended owner option A: canonical migration in phases after S1 QA, then S2 code** (not full project refactor):
- Prep small **V2 adapter design**: define `SkillLearnRequirementV2` with `min_tuvi_realm/floor`, `min_body_realm/floor`, `path/technique/manual`, no legacy `min_stage` for new skills, old P2 data migration strategy.
- Define canonical `LearnedSkillStateV2` data with immutable learned/owned IDs, 5 named mastery stages and mastery XP, AI loadout slot availability (1 basic, 4 active, 6 triggered passives at full maturity), authored successor family IDs/evolution + backward compatible legacy bool decoding. **This is architecture design, not immediate requirement to code the full catalogue.**
- Link D7 Comprehension and SpiritualRootV2 matching-element mastering bonus exactly once in canonical XP pipeline (once those source systems are actually live).
- Add Truy Phong Bộ + Liệt Diễm and utility AI against valid runtime actors in S2, after S1 tests PASS. No universal mana, no forced all five-root restriction on every skill.
- Preserve per-source deterministic progression, saved cast and persistent loot exactly-once; avoid UI conflict; source V2 spec still owns open details and should be read holistically.

**Other owner choices:** B = only finish nine P2 pilot skills and leave V2 mastery/realm bridging to next packet (lowest immediate risk, can accumulate migration debt); C = produce one bigger integrated V2 Skill + Root + Technique implementation across multiple systems, high worktree overlap and risk.

## 8. QA/provenance and status
- PR27 D7 focused 139 checks and 20/20 official suite belong to earlier SHA. PR29 S1 code is committed but **official 4.7.2 focused QA PENDING**; none of those statuses proves S2 or V2 skill mastery implemented.
- No code/runtime/save/presentation changes in this audit. UI team remains sole writer for GUI.
