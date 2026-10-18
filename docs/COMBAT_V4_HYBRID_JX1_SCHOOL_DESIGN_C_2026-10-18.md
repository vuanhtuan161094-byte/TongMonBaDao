# TÔNG MÔN BÁ ĐẠO — COMBAT V4 / HỆ PHÁI HYBRID C (JX1-INSPIRED)
**Date:** 2026-10-18  
**Status:** DESIGN PROPOSAL — PLAYER SELECTED MODEL C — **NO CODE, NO ASSET IMPORT, NO GAMEPLAY APPROVAL**  
**Decision:** disciple has intrinsic/birth martial tendencies; player may train a different school. Combat remains **real-time, autonomous, map-based**, not turn-based.

## 0. Source authority and provenance

- Repo: https://github.com/vuanhtuan161094-byte/TongMonBaDao ; audited `main` = `461caca1171462e0da092f21108c5c1733157ad9`.
- Architecture: `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, `docs/DISCIPLE_MASTER_SCHEMA.md`, `docs/CULTIVATION_PATH_V2_SPEC.md`, `docs/COMBAT_SKILLS_V2_SPEC.md`, `docs/SPIRITUAL_ROOT_V2_SPEC.md`, `docs/TECHNIQUE_V2_SPEC.md`. Status in some old specs says NOT IMPLEMENTED; concrete implementation must be checked against live code.
- Live source inspected: `CombatSkillSystem` blob `275036c94e99d69ffa7be895e969ffe4a067e79f`; `DiscipleCombatLoadoutV2` blob `912cb8a82ec4c91f0fe10bb852810500c6acc93c`; `MapBattleV2` blob `fdef96e73343d01c63df9f1408b821e90ca1b0c6`; `CultivationPathSystem` blob `46de798e3eac5a224046d491f6a389118d3c5532`; `SpiritualRootSystem` blob `c64a6bf04b1053305b1a9834031def60d5e47a84`; `DiscipleState` blob `ca6034910075aaa9806c0bad41fa11ea14ee636a`.
- Prior read-only JX1 asset audit: https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/combat-v4-jx1-drive-skill-audit-20261018/docs/COMBAT_V4_JX1_DRIVE_ASSET_SKILL_AUDIT_2026-10-18.md
- JX1/VLTK Drive catalogue: https://drive.google.com/file/d/1Nd0gP7swCu3yHIAOtWScwMjMisUCY1N2/view ; JSON enumerates **13 source-project factions** and 260 catalogue skills, of which 118 are categorized playable **only by that other project**. This is NOT 118 imported Godot skills, proof of VFX availability or proof of license.
- Reference gameplay documents for `Ta Làm Tông Sư Trong Tiên Môn / 最强祖师` on user's Drive concern **formation, equipment, techniques, disciples**; they are player/community guides, **not licensed code or mechanics authority**:
  - https://docs.google.com/document/d/1i6IJz0V1SO6x7WcKdUM3qnNds-YGBXKDRaFxRWHmAQ4/edit
  - https://docs.google.com/document/d/1BZ6Bjp4ZiPLga45thIsMttW6nc9BIFig598UeoOv_k8/edit
- No JX1/VLTK binary into GitHub, builds or public distribution until lawful reuse rights, provenance and exact-asset identity are established. Having WebP on Google Drive does not grant redistribution rights.
- C4-01 cast schema renderer hotfix branch `c4-01-battle-world-cast-schema-20261018`, HEAD `4e2ca7db07c98a021977bbcb026b6be7c958bbff` is independent and NOT main; Godot focused runtime unproven. This design does not touch it or PR20/G1/production.

## 1. What model C MEANS and what it does NOT mean

**Chosen:** each disciple has a **birth-derived martial inclination**, shown to player as a recommendation; the owner may select **one active martial-school tradition** and its currently used fighting route regardless of that recommendation; mismatching school requires modest extra learning investment, never blocks the disciple or permanently reduces combat stats. A well-trained off-affinity disciple can reach the same authored maximum skill mastery/effect as a naturally suited disciple with otherwise equal actual roots/stats/equipment.

**No permanent fixed class:** `DISCIPLE_MASTER_SCHEMA.md §12` and `CULTIVATION_PATH_V2_SPEC.md` forbid permanent hard class. An active school is not born as fixed identity and does not replace the canonical soft active **Kiếm Tu / Thể Tu / Pháp Tu**, active V2 branch and Dao history. Keep one active Chủ Đạo and branch at once; school is a **curriculum/loadout identity** layered atop those fields, not a fourth stat/class progression.

**Six dimensions:** Birth/current `Tư Chất, Căn Cốt, Cơ Duyên, Thông Tuệ, Mị Lực, Tiềm Lực` keep canonical identities, no added "martial talent" seventh stat. Birth inclination references stored `foundation_birth_values`, root birth snapshot, revealed valid traits/bloodline/physique only if already authored; it does not reroll or rewrite innate identity. Beware that only the birth snapshot, not current trainable attributes, may label *bẩm sinh*.

**Roots vs school label:** JX1 school grouping into the five phases is flavor/reference information. Each individual authored game skill owns its actual `element` for elemental effectiveness, opposition, root-effect boosts and resistances. Do NOT force all skills of one school to have the same element or apply a second school-wide Ngũ Hành counter multiplier. Five-element mutual generation/counter rules from `COMBAT_SKILLS_V2_SPEC.md` retain authority.

**Learned vs equipped:** disciple can historically learn multiple skills/curricula and keep mastery; only skills actually acquired and equipped in valid current slots participate. School selection does not grant all its skills automatically.

**No second AI:** actor uses existing shared `MapBattleV2` scheduler, deterministic selection, event journal, damage, cooldown, cast, target and 0.25s step. VFX is a view of true events, not an authority.

## 2. Ten classic JX1-inspired school references (CONTENT MAP PROPOSAL, not locked mechanics)

The source JSON additionally lists Hoa Sơn, Vũ Hồn and Tiêu Dao; park those for later. These ten are a **school-theme starter registry** for content authors; actual in-game localized naming/IP clearance still a separate issue.

| Reference group | School | Candidate current V2 path / authored branch | Distinct combat language to author | NOT an automatic free bonus |
|---|---|---|---|---|
| Kim | Thiếu Lâm | Thể → Kim Cương / Bá Thể | guard, frontline pressure, staff/fist | no passive +DEF simply for choosing school |
| Kim | Thiên Vương | Thể → Bá Thể; sword-side route only if weapon/style authored | close pressure, sweep, pursuit | no random aggro or universal threat |
| Mộc | Đường Môn | Pháp → Huyền Pháp (projectile/hidden weapons as actual content) | projectiles, trap zone, conditional burst | no unbounded projectiles or instant poison |
| Mộc | Ngũ Độc | Pháp → Ngũ Hành; optional Thể → Huyết Thể if authored | poison/status survival, DoT | Poison mechanism requires a real gameplay packet |
| Thủy | Nga Mi | Pháp → Y Đạo; alternate Kiếm → Hộ Kiếm | party heal, protection, clean-up | no generic instant revive |
| Thủy | Thúy Yên | Pháp → Ngũ Hành; alternate Kiếm → Sát Kiếm | ice/debuff, close blade mobility | no global slow effect |
| Hỏa | Cái Bang | Thể → Bá Thể; alternate Pháp → Ngũ Hành | palm/staff pressure, area control | no permanent AoE against unlimited targets |
| Hỏa | Thiên Nhẫn | Thể → Huyết Thể; alternate Pháp → Ngũ Hành | fire burst, risk/reward offensive tools | no free lifesteal without authored packet |
| Thổ | Võ Đang | Kiếm → Ngự Kiếm; alternate Pháp → Huyền Pháp | sword projectile, internal-control | no forced "earth" damage on lightning techniques |
| Thổ | Côn Lôn | Pháp → Huyền Pháp; alternate Kiếm → Ngự Kiếm | lightning/control, tempo | no automatic stun bypass |

**Canonical-branch names** above are existing *V2 design vocabulary*; **school-to-branch assignments and mechanics are proposals**, not implemented or approved content. For school route, use separate cosmetic/style/content tags, never invent an additional universal stat/class level. A Thiên Vương sword-route with spear weapon is NOT automatically valid: legal weapon/style needs authored `weapon_requirement` and future Weapon V2 approval.

## 3. Data relationships (CONCEPT ONLY — NO NEW STATE FILEDS HAVE BEEN CREATED)

**Persistent/conceptual layers to approve before CODE:**
- `martial_birth_inclination`: preferably **DERIVED** recommendation from stable birth snapshot, not random/new persistent class and no new RNG. For legacy profiles missing adequate original roots/birth snapshot, show `unresolved`; never invent a default birth root, and never mutate stored seed/save.
- `school_transmissions`: school/skill content owned by **Sect**, separately from individual learned skills and equipped slots.
- `active_school_id` + `active_school_route_id`: proposed future one-at-a-time selection, only valid if compatible with presently active canonical Chủ Đạo/branch; if changing route needs changing 主道, use the existing explicit Định Đạo/chuyển Đạo pathway, not an auto silent rewrite.
- `school_study_history`: only meaningful learned content and explicit changes, possibly derive from existing acquired skills/Đạo Lịch when feasible; do not create a duplicative unbounded "school XP" stat. Display historical school associations without stat multipliers.
- `equipped_skill_ids`: canonical **V2** real combat loadout (1 Thường Kỹ, 4 active, 6 combat passive as slots unlock), not a secondary 4-skill array in a school subsystem. Owned skill remains known if inactive; passives obey self-static/triggered slot boundary.
- `art_profile_id` is a **presentation mapping**, not required in simulation save; binds a skill or actor appearance to licensed animation/VFX versions and neutral fallback.

**Existing implementation reality:** live `DiscipleState` has `foundation_birth_values`, `v2_birth_profile`, `spiritual_root_quality/elements`, `cultivation_path_xp`, `learned_combat_skills`, `active_technique_id`, but no V4 school fields; P2 `SpiritualRootSystem` is NOT yet the fully authored V2 per-element root-purity model. `CultivationPathSystem.active_technique_path` currently derives `sword/body/spell` from equipped P2 technique. Avoid pretending the ideal V2 migration has happened or that source A/JX art is installed on main.

## 4. Birth inclination and reasonable mismatch mechanism

**Goal:** feel like "born talented but training matters"; no hard class lock, no double-dipping into elemental effect bonuses and no arbitrary permanent ATK/HP/DEF penalty.

**Recommended deterministic derivation (needs proper V2 birth root snapshot):**
1. Evaluate candidate school's *introductory curriculum's* authored favored element(s), which are **NOT** a global element for all skills, against **birth** root values: a school's introductory element matching the disciple's highest root = `hợp thiên hướng`; matching another present root = `có thể tu`; no matching birth root = `trái thiên hướng`. For multiple authored introductory elements, use best eligible root. Equal value ties resolved by fixed element-ID order, never RNG.
2. Optional birth trait/bloodline/physique may influence a school's *advice label only* if an authored compatible rule exists and its relevant identity is known/revealed. Unknown latent identity must not leak in UI.
3. Do NOT derive birth tendency from current cultivation scores, acquired school choices, or trained current Lục Duy, because it would retcon the birth record.
4. A multi-root disciple may be compatible with several schools; there is no exclusive birth school. A disciple with an unresolved legacy birth profile gets `thiên hướng chưa rõ`, not a fake one.
5. Separate UI **birth inclination** (fixed) from **current readiness** (existing cultivation and learned techniques/weapon/skills), which can improve over time.

**Pilot numeric proposal — NOT LOCKED BALANCE:** affect only the **initial school-learning/intro ceremony's time**, piggybacking on explicit Sect Định Đạo/training authority rather than running another timer:

| Birth-school relation | Learning/intro time multiplier | Long-term effect |
|---|---:|---|
| Hợp thiên hướng | ×0.90 | No direct damage/defense boost |
| Có thể tu | ×1.00 | No direct boost |
| Trái thiên hướng | ×1.10 | No permanent debuff, eventual full mastery remains possible |
| Birth info unresolved | ×1.00 (neutral, visibly unresolved) | Never invent certainty |

**Important:** these factors are **tentative content-balance values**, not an authorization to adjust V2 Định Đạo timing, EXP, training resources, skills, or stat math. Only approve actual numeric effect after baseline comparison and appropriate contracts. If timing semantics cannot be isolated from active jobs/scheduler, use **compatibility-label-only** in the first release instead of creating a new hidden clock. Matching Spiritual Root already increases skill mastery and numeric effects in V2; **do not stack another generic +10% school damage or duplicated same-element bonus**. Lục Duy XP/speed channel uses canonical additive bonus policy; do not multiply incompatible ad hoc rates into it.

**Example A:** Disciple born strongly Thủy, chooses Nga Mi Y Đạo (matches introductory element) — lower proposed entry training time, same skill caps and actual root effect.  
**Example B:** Same disciple chooses Thiên Nhẫn; game shows "Trái thiên hướng, +10% thời gian nhập môn dự kiến" (pilot) but permits it. He gains proficiency legitimately through training; his ultimate Fire performance remains determined by ACTUAL root, skill mastery, technique, gear, V2 damage rules, not a permanent school ban.  
**Example C:** Multi-root Thủy/Hỏa birth may suit either Nga Mi or Thiên Nhẫn; no forced "one birth faction".  
**Example D:** Old save lacks required birthplace root values -> show unresolved/neutral, do not reroll roots or assume mismatch.

## 5. Player operations, teaching and switch rules (proposal)

1. Recruitment displays birth root/foundation already known and **suggested compatible curricula**, not an assigned school that is already learned.
2. Player chooses school + a valid training route + existing path/branch where available. If not yet `Định Đạo`, canonical teaching/path requirements still apply; selecting a school alone grants NO combat power/skill.
3. Sect must own manual/transmission, character satisfies Tu Vi/Luyện Thể/technique/mastery/authored weapon/root prerequisites, pays individual/sect sources under existing policy and spends valid shared scheduler time. No generic learning-failure RNG.
4. Individual learns a named skill *family*; grows `Sơ Học → Nhập Môn → Tiểu Thành → Đại Thành → Viên Mãn`; evolutions remain Nhân Giới (1–10) → Tiên Giới (11–20) → Thần Giới (21–30), named successors, no arbitrary "+Lv" stacking.
5. Equips only up to **1 Thường Kỹ + 4 active + 6 combat passive** when actually unlocked. Skills/prerequisites use actual `path`, branch, weapon and explicit authored tags; school ID alone cannot override the legality.
6. Switching school/route is **explicit outside combat**, potentially with valid time/cost and One Active Job exclusivity; switching active Chủ Đạo/branch, when required, must use the existing canonical switching rules. **Never wipe** learned skills, mastery, Dao history, gear ownership, event history. Inactive path-exclusive skills cannot execute until eligible, but their knowledge remains.
7. There must be no "class level", all-school damage multiplier, independent school XP, sixth universal combat resource or new AI clock.

## 6. Concrete Combat V4 build identity (examples, NOT implemented)

- **Thiếu Lâm Thể/Kim Cương:** frontline pressure, shield/guard when actual HP/conditions require it, draws nearby enemies by positioning; not fake aggro.
- **Thiên Vương Thể/Bá Thể:** closes distance with actual movement, short melee burst in melee geometry; special chase only if skill exists.
- **Đường Môn Pháp/Huyền Pháp:** long-range authored projectile and optional bounded trap radius; no magic fake projectile damage.
- **Ngũ Độc Pháp/Ngũ Hành:** keeps a real authored poison state on a valid target; cannot use an undefined DoT effect.
- **Nga Mi Pháp/Y Đạo:** heals a damaged ally of the same party, cleanse only if a real debuff exists; cannot ordinary-heal a downed disciple.
- **Võ Đang Kiếm/Ngự Kiếm:** sword projectile with cast/real travel time and hit resolution; the VFX follows `skill_cast`/`skill_hit`, not an on-screen fake impact.

**Party example ≤6:** Thiếu Lâm + Thiên Vương + Võ Đang + Đường Môn + Ngũ Độc + Nga Mi. This illustrates complementary role/reach/status/heal; there is no required composition lock or free six-faction combo bonus. Up to 30 participating disciples total and max three AoE targets by default must be preserved unless separately authorized canonical rules.

## 7. AI, timing and player-facing UX authority

- Use **skill slot priority 1 → 4**; only fire if actual cooldown, cast exclusivity, valid target, range/geometry and per-skill conditions pass. Otherwise use Thường Kỹ. No turn order, universal Mana/Rage or arbitrary free GCD.
- Keep normal approach movement and reserve mobility for actual tactical use; e.g. Truy Phong Bộ only if gap genuinely needs closing. Defense only under applicable authored conditions, DoT only after applied, combo only if target has right status. No AI phantom skill from school label.
- Use actual Combat V2 frame-independent **0.25s simulation tick**, deterministic stable ID tie-breaks, 36×20 map arena, real 90s timeout. Presentation does not own HP, damage, hit, cooldown, arrival or RNG.
- VFX contract: `skill_id → (cast_pose, projectile, impact, aura/status, optional audio)` in licensed art registry, event-bound start/end, max-screen-density Android. *Different schools require different actual geometry/effects*, not merely recolored circles.
- Root/school UI: show clear chips `Bẩm sinh: Thủy`, `Học: Thiên Nhẫn`, `Tương thích: Trái thiên hướng`, `Chủ Đạo: Pháp`, `Nhánh: Ngũ Hành`, actual learned active/passive skill cards, mastery and missing manuals, no confusing one badge for all notions. Show exact claimed training time adjustment if/when implemented.
- Combat HUD 1280×720: readable party roles, HP, active skill icon/cooldown, status application, Boss telegraph, small effect density; **never block units/HP with VFX**. Focus on accessible tap targets and lower-end Android budget.
- No licensed JX1 art yet: neutral named silhouettes/telegraphs only; do not assign misleading JX1 source sprite "boss103" to `hac_lang_vuong`.

## 8. Design dependency and implementation gates (NOT AUTHORIZED)

**Before code:** user reviews/locks principle and, if desired, test-only pilot timing coefficient. Any activation on code branches needs separate exact allowlist and needs migration against authoritative Master Schema (particularly "no permanent class" and V2 per-root facts). Do not insert this draft into canonical master schema by stealth.

Potential minimal *future* packets only when user opts in:
1. **School-definition and compatibility read-only packet**: authored school/route metadata and birth recommendation calculation. Show unknown on legacy data. No simulation damage, scheduling or new save state yet; test ten source schools, same-seed stability, multi-root, missing-root.
2. **Real school selection/loadout eligibility packet**: one active school/route using already-authored path/branch, switch with history/mastery preserved, actual legal slot restrictions and save migration; no new school XP or duplicate active job; test old-save recovery, not-yet-learned skill cannot fire, turn off schooling leaves existing PvE deterministic.
3. **Licensed asset, VFX and standalone Combat V4 pilot packet**: wait for complete JX1 source/rights and authentic `SPR/PAK → (skill_id, frame order, dir, fps, anchor)` mapping; preserve Source A actor bundle rules and C4-01 renderer branch integration when authorized. Render real verified events, no gameplay authority in graphics. Minimal focused test + live 1280×720 walkthrough when runner exists; Android performance PENDING.

**Explicitly not allowed by this design:** creating/shipping 10 complete class kits, choosing new skill stats, importing third-party assets, changing 30×10 realms, One Active Job, production, SaveService, RNG or combat balance; copying JX1/最强祖师 formulas/source codes; merging PR20/G1; running CI/FULL; claiming Windows/Android tests.

## 9. Decision register

**OWNER DECIDED:** Model C; born tendencies but free choice of another school; real-time combat (not turn-based); VFX should correspond to actual selected school skill; wait for complete JX1 source before asset integration; NO CODE now.

**CONSISTENT WITH EXISTING LOCKED V2:** soft one-active Chủ Đạo/branch; fixed birth identity vs learned skills; classless stat progression; 1 normal/4 active/6 passives at maturity; Sect manuals and genuine mastery; Ngũ Hành per skill; no universal resource; deterministic simple AI; ≤6/party, ≤30/cluster; presentation purely visual.

**PROPOSED, NOT YET LOCKED:** exact ten school implementations and school-to-path content map; whether school selection lives beside existing path as a separate persistable value; actual birth school suitability rule, +/−10% pilot introductory time, change-school time/resource policy; named skill kit, gear tags; final art identities and VFX.

**BLOCKED/PENDING:** V2 root per-element birth authority not yet production code; no guaranteed exact wolf or VFX binary with distribution rights; 7 of 9 initial P2 skills not implemented as effect-specific MapBattle actions; Combat V4 visual pilot not finished; Godot focused Windows/Android run not part of this design packet.

**Next action:** review as a *design proposal* only. Wait for JX1 source and rights provenance; no code, no CI/FULL, no merge.
