# TÔNG MÔN BÁ ĐẠO — JX1 / JX2 / KIẾM THẾ: NGHIÊN CỨU VÕ CÔNG VÀ ÁNH XẠ SANG COMBAT V3
## Học cơ chế thật, xây kho skill phong phú, không thay đổi luật V2 đã khóa

**Ngày:** 2026-10-24. **Trạng thái:** DESIGN/RESEARCH ONLY; chưa ủy quyền code, không sửa PR29/Codex, PR27, UI/Source A, không merge.
**Source TMB:** main 29b5fba448b0178cb520a4ada44b375b4b934e31, docs/COMBAT_SKILLS_V2_SPEC.md, docs/TECHNIQUE_V2_SPEC.md, docs/CULTIVATION_PATH_V2_SPEC.md, docs/SPIRITUAL_ROOT_V2_SPEC.md. PR29 S1 9522812e91b7ca5bc0cc108eb92e000e930fe850 still **official Godot QA pending** on last verification.
**User intent:** người chơi thích JX1/JX2/Kiếm Thế vì có số lượng lớn võ công, cách thi triển, liên chiêu, hiệu ứng và tính chuyên biệt. Thiết kế trước đây chỉ tác giả hóa 11 chiêu cho Lâm Thanh quá hẹp nếu bị hiểu là **tổng số skill**. Quy tắc V2 1 Thường +4 Chủ Động +6 Bị động là **số ô EQUIP tối đa**, không giới hạn số chiêu cá nhân biết hoặc toàn catalogue.

## 0. External documentary research — separate observed facts and inference

### JX1/Võ Lâm Truyền Kỳ PC (not automatically same as mobile)
- Early sect skills arranged in **school/weapon and support trees** (Thiếu Lâm quyền/côn/đao/hỗ trợ; Đường Môn phi đao/phi tiêu/tụ tiễn/cạm bẫy) with techniques opening at level/mission gates, not just numerical upgrades. Diagram/reference https://jxdocs.com/s/pages ; historical tree capture from JX docs.
- Official VLTK 150 quest **requires learned skill90 + skill120**, faction-specific quest, content/secret book. This evidences dependency chains, not a TMB proposal to port “player level150” literally. Source VNG https://volammienphi.vnggames.com/tin-tuc/tin-tuc/12-01-chinh-thuc-ra-mat-ky-nang-150.html ; early detailed faction https://gamemoira.org/huong-dan-choi-game/jx-vltk-vo-lam-truyen-ky/mon-phai-vltk/thieu-lam-vltk/
- Lesson: *skill school identity, prerequisites, tier-gated secret arts, support skill as important as main attack*.
- Do not assume every JX1 client version has exactly same level caps/percent; JX1 Mobile is a distinct live variant.

### JX2/Võ Lâm Truyền Kỳ II — verified official guide
- VNG Thiếu Lâm Võ Tông: Vi Đà Quyền and Văn Thù Xuất Vân Thoái can require prior La Hán Quyền/Ca Diệp Thoái; Đại Tu Di Chưởng/Vô Ảnh Cước build on intermediates; Trấn phái Như Lai Thần Chưởng requires an eligible preceding technique. This is **in-battle action/technique sequence** as described in their guide, not a mere "must permanently learn earlier skill" tree.
- **Yếu Quyết + Mật Tịch**: specialized modifier lines in manuals enhance named move effects by percent; not identical to grant-a-skill.
- Source: official https://volam2.vnggames.com/cam-nang/mon-phai/thieu-lam.html
- Lessons: **opener → follow-up → finisher**, conditional combo windows with deterministic timers; individualized technique/manual enhancement to a family, dual-layer moves/passives. Maintain clear target/cast/animation timing; do not assume all JX2 internal formulas accessible without source.

### Kiếm Thế PC — verified official publisher
- Some sect skills are *active attack*, *active support*, *passive support*, *trap*. Levels, limits and advanced skill-specific effects distinct.
- Official Cái Bang catalogue: effects include self dodge/reflect, team buffs, burn chance, attack speed, range, single vs area, and late support skill. Source https://kiemthe.vnggames.com/baiviet/mon-phai/cai-bang.html
- Official Kiếm Thế Trấn Phái examples: Đường Môn Khổng Tước Vũ ranged piercing strike creates an extra child strike on hit; Cổ Mộ Kiếm Cô Thân Chi Ảnh spins twice, gains stack and can trigger a secondary technique; Côn Lôn can call lightning field/secondary AoE; Ngũ Độc can reduce healing and trigger second move. Source https://kiemthe.zing.vn/su-kien/phien-ban-moi-tuyet-ky-tran-phai-495/ky-nang-tran-phai.html
- Official skill cap expansion +5 levels and exception to secret-book skill levels: https://kiemthe.zing.vn/tin-tuc/tin-tuc/huong-dan-mo-rong-ky-nang-chieu-thuc.html
- Lessons: **multi-stage effects/child action, skill chaining, stacking capped mark, named passive synergy and area geometry**, not every skill is just damage.
- Avoid blanket port of Kiếm Thế +20 point skill ladder; TMB five personal mastery milestones are canonical.

**Owned Drive limited evidence:** connected user's Drive contains folder "jx" with skill UI files/PNG (e.g. skill_Page.png, skill_Main.png) and folder "Source VL" with web files, but those visible folders by themselves do NOT establish access to original JX1/JX2/Kiếm Thế executable skill tables, original balance formulas or a runnable server. External publisher documentation is used for claimed mechanics; a future optional source audit must fingerprint real JX tables before importing numeric mechanics or relying on asset content.

## 1. THE CORE DESIGN INSIGHT: 5 dimensions, not a small fixed list

Every skill has:
1. **Ownership/equip slot**: Thường Kỹ (1), Chủ Động (4), combat passive trigger (6), or static self-only derived bonus (not passive slot).
2. **Path/branch**: Kiếm Ngự/Sát/Hộ; Thể Bá/Kim Cương/Huyết; Pháp Ngũ Hành/Y/Huyền. Family/branch is guidance/prerequisite when authored, not an automatic class grant.
3. **Combat roles**: single-hit, multi-hit, pierced projectile, fan/cone/line/circle/chain/ground zone, DoT, guard/shield, heal, cleanse, dispel, cc/control, mobility, traps, attack-support, proc, counter, aura.
4. **Element and stats**: five base, neutral and explicitly authored mutation advanced tags; skill reads real ATK/DEF, TuVi/Body/hybrid, matching roots/resist/matchup through CombatStats V2.
5. **Growth**: grade Phàm/Huyền/Địa/Thiên/Tiên/Thần distinct from five mastery stages Sơ Học→Viên Mãn distinct from Nhân→Tiên→Thần authored successor generations.

**Four slots are EQUIPPED ACTIONS, NOT a restriction to only four animated effects.** One selected skill can own multiple pulses/child effects; a reactive passive can add secondary hit; Tương Sinh triggers can alter legal packet without inventing an unlearned active ability. But one actor one action opportunity, no recursive proc, no parent action spawning free unlimited skills.

## 2. Library size: do not freeze Lâm Thanh at 11 learned skills

Existing LOCKED **content target**, not code fact: EACH base path ~12–15 long-lived active/passive families; ~40–60 active definitions plus20–30 passive definitions **over 30 realms** (including branches/successors). 3 paths × these broad targets yields a large original authored library. **Do not falsely claim hundreds now exist.** To author efficiently:
- Start with ~12–16 diverse base-family concepts for Pháp, ~12–16 for Kiếm, ~12–16 for Thể, then expand selected family successors Nhân→Tiên→Thần and variants; reuse one typed mechanic with authored data per distinct skill.
- Each apprentice might know 1–3 skills, experienced cultivator might know many, but only 4 active+6 trigger passives can be equipped simultaneously; changing loadout occurs out of battle and honors learned/prerequisites.
- Original variant names, lore, effect tuning and atlas are original TMB design; JX teaches function and interplay, not license status or permission to blindly distribute JX art/data.

### 2.1 Pháp Tu: 15 functional families for design library (PROPOSAL, some names in canonical catalogue)

| Family / concept | Branch inclination | Identity (JX-like mechanic) | Example skill |
|---|---|---|---|
| 01 neutral projectile | general | ordinary filler; can later split projectile | Linh Khí Đạn [canonical candidate] |
| 02 Fire burning opener | Ngũ Hành | direct+Burn with real cast/target | Hỏa Cầu [P2 source] |
| 03 Fire payoff | Ngũ Hành | extra bonus if target still burns; later evolved AoE | Liệt Diễm [P2 1 target; V2 advanced AoE content later] |
| 04 chained multi-hit | Ngũ Hành | 2–4 hits with per-hit target validation, child packets | Liên Hỏa Ấn [PROPOSED NEW] |
| 05 fan/line damage | Ngũ Hành | capped fan/line, pierce target order | Linh Bạo Thuật [V2] / Hỏa Phiến [NEW] |
| 06 Water control | Ngũ Hành/Huyền | slow→seal/status control & resist gates | Hàn Sương Ấn [P2 current weaken; V2 successor only if authorized] |
| 07 Kim penetrating spell | Ngũ Hành | armor-penetration tradeoff | Kim Mang Chỉ [V2 candidate] |
| 08 Thổ guard | Ngũ Hành/Y | defensive self/ally shield | Thổ Linh Thuẫn [V2 candidate] |
| 09 Mộc sustain | Y Đạo | effective healing + Sinh Cơ | Hồi Xuân Thuật [V2 candidate] |
| 10 heal-over-time | Y Đạo | applied buff HoT, bounded ticks, not overheal farming | Sinh Cơ Tức [NEW] |
| 11 cleanse/dispel | Y Đạo/Huyền | remove eligible buff/debuff by priority and tier | Thanh Tâm Chú / Tán Linh Chú [V2] |
| 12 defense penetration debuff | Huyền | armor/weaken setup for party | Suy Linh Chú [V2] |
| 13 party aura | Y Đạo/Huyền | contribution-verified buff, strongest-only stacking | Linh Quang Gia Trì [V2] |
| 14 control/formation | Huyền | status-limited root/seal and short-lived zone | Định Thân Ấn / Pháp Trận [V2] |
| 15 emergency save | Y Đạo | bounded anti-lethal/help rather than infinite revive | Hộ Mệnh Thuật [V2] |

The above are **families / catalogue directions**, NOT 15 equip slots, 15 live spells, 15 mandatory skills per Pháp Tu, nor an automatic 15×3 multiplying without gameplay value. Create at most 1–3 representative variants per family initially; author successors later with meaningful new mechanics.

## 3. JX-mechanic → original TMB adapter contract

| Pattern | Verified reference | How TMB might use it | Locked compatibility |
|---|---|---|---|
| School tree | JX1 skill-by-weapon/support + 90/120/150 | skill_family_id, branch tags, authored prereq, Sect manual | no player character level, use TuVi/Body 30×10 & Path instead |
| Opener → follow-up → finisher | JX2 La Hán/Vi Đà/Đại Tu Di | per-actor last meaningful accepted cast state + expiry; follow-up eligibility only if actually produced | 4 active priority, deterministic action, no fake auto-proc |
| Mật tịch/Yếu quyết | JX2 skill-specific % enhancements | Công Pháp active main/support or explicitly learned modifier, one source unique key; manuscripts in Sect archive | 1 Main+2 Support; learning technique != free combat skill |
| On-hit proc extra move | Kiếm Thế Trấn Phái | child_hit/child_effect belongs to existing source cast_id with hit_index and per-cast cap | no extra active slot *if it's authored within parent ability*; no proc recursion |
| Stack up to N | Kiếm Thế Cổ Mộ example 5 layers | typed status state with max stacks, owner, target generation, duration; stack consumption by finisher | not infinite stack, DoT and status source authoritative |
| Active support vs passive support | Kiếm Thế | support skill is an active slot if it requires casting; self stat passive no slot; reactive/party aura consumes combat passive slot | exact V2 passive ownership rules |
| Line/fan/circle/traps | JX1 tree/Kiếm Thế | explicit geometry and max_targets, target cap per skill, tie-break, no free hits | existing generic AoE=3 does not govern every learned skill |
| Rank/skill points | JX1/Kiếm Thế | use content grade + authored progression/mastery milestone gates | DO NOT replace five V2 mastery labels with +20 manual points |
| Weapon/sect restriction | JX1 schools / Kiếm Thế paths | authored style_tag/weapon_requirement and valid learned/Dao/tech conditions | avoid fixed sect-exclusive total skill universe; TMB disciples can have history in multiple Paths |
| Element interaction | JX ecosystem | root purity+R, skill-element vs monster primary element counter, opt-in Tương Sinh | preserve RootV2 locked formulas, no blanket free counter for any spell |

### 3.1 Example: direct skill with two-hit child + on-hit trace (NEW PROPOSAL only)
\`\`\`yaml
id: tmb_spell_fire_chain_01
family_id: fire_chain
generation: nhan
slot: active
element: fire
shape: single
range: 6.0             # PROPOSED illustrative
cast_seconds: 0.6       # PROPOSED illustrative
cooldown_seconds: 6.0   # PROPOSED illustrative
hit_packets:           # no new AI active slot
  - {hit_index: 0, damage_ratio: 0.9, target_count: 1}
  - {hit_index: 1, damage_ratio: 0.7, target_count: 1, delay_seconds: 0.18}
secondary:
  trigger: successful_primary_hit
  condition: target_has_burn
  effect: {type: status, status_id: sear, duration: 2.0}
  max_children_per_cast: 1
source_authority: map_battle_v2
\`\`\`
All sample coefficients are **NOT source-verified JX numbers and NOT TMB locked damage**. Secondary hit is not allowed to self-trigger more secondary hits. No arbitrary dynamic 3D collision/geometry claim.

### 3.2 Example: JX2-like 3-action combo in four slots (NEW PROPOSAL)
- Actor knows **Hỏa Cầu** (opener) → **Linh Hỏa Kích** (follow-up) → **Liệt Diễm** (payoff), 3 equipped slots; the fourth may be heal/shield.
- Hỏa Cầu can apply a genuine Burn on target; follow-up grants a typed short-lived actor **ComboWindow** only after a true hit/cast settlement; Liệt Diễm impact checks target Burn and/or authored combo flag. The existing P2 Liệt Diễm bonus is **1.35 only if actual burn**: do not silently add a second universal 1.35 bonus for combo window.
- Slot AI scans 1→4. **Important scheduling:** if opener is ready and its condition always true it can starve follow-ups. Therefore skill-defined "refresh only if burn absent/near expiry" and "follow-up window present" predicates are needed; do not add a global optimizer contravening canonical priority.
- Combo window should have \`source_actor_id\`, \`target_actor_id\`, \`target_generation\`, \`applied_at\`, \`expire_at\`, source cast_id and state version; save/reload deterministic. On failure/resist/target death, no phantom window.
- Boss resistance, ability and actual party skill contributions must be explicit. No one cast should grant an entire free 4-skill chain because chained effects were described narratively.

### 3.3 JX-like passive synergy without unlimited stacked damage
- Passive A: on effective Burn apply (or valid fire hit), record a capped stack mark once per **source cast** with proper ICD.
- Passive B: at 3 stacks, authorize a single next fire technique to add one child packet / damage modifier; consume stacks atomically at settlement.
- Sect technique: MAIN authored fire-family modifier, SUPPORT Water/wood move/focus/survival; duplicate uniqueness group doesn't stack; no infinite fire proc.
- Root Fire78 matching Fire skill bonus and Fire unconditional all-damage passive belong **different explicit CombatStats channels**, must not be applied twice at skill and child-hit levels.
- No per-frame scans across 1000–3000 disciples; only active MapBattle V2 actors' event transitions.

## 4. Preserve existing P2 skill IDs and V2 canonical design
- P2 9 authored starter skills: 3 sword, 3 body, 3 spell. P2 already has \`Thanh Phong Trảm\`, \`Truy Phong Bộ\`, \`Ngự Kiếm Thuật\`; \`Chấn Sơn Quyền\`, \`Kim Cương Hộ Thể\`, \`Bất Động Thân\`; \`Hỏa Cầu\`, \`Hàn Sương Ấn\`, \`Liệt Diễm\`.
- PR29 S1 changed learned damage/burn/weaken/guard in MapBattle, **not official QA pass yet**; dash/fire combo deferred S2.
- V2 canon: 1 basic+4 active+6 combat passive at maturity; 1 Main+2 Support techniques; five mastery stages; 3-wave descendant families; Path not level class; no universal Mana; enemy/ally geometry and AI slot order. **Do not override any of these from JX input**.
- P2 \`liet_diem\` is single-target damage+Burn bonus, while long-form V2 Pháp catalogue mentions a higher-order AoE/payoff. Keep pilot single-target and design AoE as **an authored evolved skill** unless owner later explicitly approves changing pilot, with geometry and test.
- Liệt Diễm should NOT be silently marked as "guaranteed AoE to 5 targets" merely because Kiếm Thế has area skills.
- Mastery gain from actual effective contribution/Diễn Võ with validated sources, not one free mastery XP per idle attack/no-risk dummy. JX level90/120/150 and +20 skill point caps are references, not TMB progression units.

## 5. Prototype Lâm Thanh with rich learned catalogue vs equip 1/4/6

**Character illustration only**, not code; native roots Fire78 Water46 Wood34 (independent), D7 comprehension120; Pháp Ngũ Hành as active Dao after a learned Main technique.
- **Learned skill LIBRARY eventually**: Hỏa Cầu, Liệt Diễm, Hàn Sương Ấn, Linh Bạo Thuật, Kim Mang Chỉ, Thổ Linh Thuẫn, Hồi Xuân Thuật, Định Thân Ấn, Suy Linh Chú, Linh Quang Gia Trì, Thanh Tâm Chú, Tán Linh Chú, Hộ Mệnh Thuật plus any legal follow-up/advanced manuals. This is neither instant recruitment grant nor current runtime state.
- **Equipped hunt-farm profile example:** Basic Linh Khí Đạn; Active [1 Hỏa Cầu — only when Burn needed, 2 Liệt Diễm — payoff window, 3 Linh Bạo Thuật — ≥2 legal monsters within AoE, 4 Thổ Linh Thuẫn — survival if needed]; Passive [self shield on real low HP, fire-family stack, effective damage mark, Tương Sinh opt-in, meaningful cooldown proc, party support if legal]. Many of these passives are **mechanic proposals** not finalized/owned, do not grant artificially.
- **Equipped Boss-profile example** (out of battle): Basic Linh Khí Đạn; Active [1 Thổ Linh Thuẫn only if threatened, 2 Hỏa Cầu real Burn, 3 Liệt Diễm if real Burn at impact, 4 Suy Linh Chú if debuff helpful]. One character; different legal loadout/auto behavior. No need to make four simultaneously equipped "trấn phái" skills.
- **Equipped healer-profile example** only if legal Y Đạo training: Basic Linh Khí Đạn; Active [Hồi Xuân, Thanh Tâm, Hộ Mệnh, Thổ Linh Thuẫn]. No healer character may auto-teach these with no manuals/requirements.

**Gameplay outcome:** player can farm a specific manual to solve a current challenge: hunting groups need geometry/AoE; elite armor needs Kim penetration/debuff; poison/control Boss needs Cleanse/Shield/Y Đạo; burning Boss may favor Liệt Diễm; heavily Fire-resistant Boss encourages alternative element via learned legal spell. This delivers meaningful build choices beyond a 1.15→1.70 ATK ratio race.

## 6. Technical engine contract to support JX breadth without rewriting renderer

**Single Combat V2 owner.** Extend via typed AUTHORING registries, never one huge hard-coded if/else per skill:

1. \`SkillDefinition\`: id/family/path/element/grade/generation/requirements/slot/weapon/style; basis TuVi/Body/hybrid; cast, CD, range, geometry, AoE max targets, targeting policy.
2. \`SkillEffectPackets\`: direct damage(s), child impact scheduling, buff/debuff/DoT, heal, guard, shield, move/dash, zone, status stack and final proc. Same cast ID with sequential unique hit_index; each source must be legally learned/equipped or authored child (not a new free learned skill).
3. \`SkillPrereq\`: learning/realm/manual plus combat use conditional; separate “learned” vs “can_use_now”, combo window/target status/HP threshold, exact action gate. Never blindly use JX "character level 90".
4. \`SkillModifier\`: JX2 Yếu Quyết-inspired explicit named **technique→skill_family** percentage/conditional effect, SourceKey & unique grouping; matching root bonus, D7 mastery, equipment and status all routed ONCE through canonical stat/effect consumers. Technique doesn't silently grant skill.
5. \`SkillStatus/Proc\`: typed source caster/target generation, duration, stack cap, snapshot, ICD, effect tier, resist, per-cast cap and forbid child triggering itself.
6. \`AutoPolicy\`: V2 4 active fixed priority legality scan + fallback Basic; no global utility AI; supports copied valid build profile outside combat by future UI owner.
7. \`SectAcademy\`: Tàng Kinh Các owned manuals, personal learned/mastery, legal training/Diễn Võ, item/fragment sources. Note no new player permanent save compatibility required for **DEV** according owner reset policy; within-build persistence/exactly-once mandatory.
8. \`VisualEvent\`: semantic cast/secondary_hit/zone/status shown by Source A presentation, no imported JX player sprites or unverified proprietary content. This packet does not change rendering.

**Expected regression hazards before feature permission:** (i) extra-hit duplicating loot after battle save (ii) child proc chain recursion (iii) % modifiers double counted, (iv) 4-slot priority starvation, (v) overpowered all-target AoE when 30 vs40 actors, (vi) status 5 stacks but per-party cap leaks across squads, (vii) elite/boss control lock, (viii) casual dev reset deleting wrong profile.

## 7. Small official Godot acceptance plan, only after owner CODE authorization
- S1 official QA first (PR29), no code overlap.
- **Phase JX-A: skill definition + 4-slot ordered AI** (2 direct + one guard only) parse+focal tests: legal learner vs unknown, range/CD, slot order, no free skill.
- **JX-B: JX2 combo window** on top of accepted S1 Burn and Liệt Diễm; test opener→followup→finish, expiry, target gone, save reload in window; no double multiplier.
- **JX-C: Kiếm Thế-style child packet/multi-hit + status stack**; test hit0/hit1, max target1/3/5 in authored cases, shared Boss, per-cast cap, no recursive child, exact receipt once.
- **JX-D: one JX2-inspired technique modifier** in Main/Support semantics, one true manual->Sect archive->disciple->mastery in CARE, UI read-only.
- **JX-E: represent 3 path starter archetypes** with unique combos, 1 basic+2 active+1 proc passive each; real gameplay screenshot/video via UI writer when source callbacks are available.
- Focused 3–8 fixtures each, real official 4.7.2 and save/replay once, medium seed after complete vertical slice; no full 1240-fixture balance per new skill.

## 8. Open choices for owner, not numerical lock
**A — Recommended:** JX2 chained combo + Kiếm Thế child procs, under canonical 4 active, 6 passives and 5 mastery; content full broad catalogue later. Author one detailed original Pháp build 1/4/6 in next packet after core mechanics.
**B — Broader JX:** also design equipment-triggered hidden effects, traps, formation skills, advanced on-hit chance/stack/chain and counter families for all nine branches; slower to ship. Design only.
**C — JX data audit:** inspect user's actual JX1/JX2/Kiếm Thế client/server skill tables, packet-by-packet, with concrete source paths/fingerprints, and map technical mechanics and animation frames; cannot claim formulas until data extracted. Drive currently contains partial UI/source folders, not confirmed original complete skill table set.

**Recommendation:** use A for practical fun; optionally C to validate authentic mechanics/content before creating 200 new names. Keep JX as functional inspiration; the TMB lore, progression, content and Source A visual style remain canonical and original.

## 9. Research URLs (external, traceable)
- VLTK1 150 requirement, official: https://volammienphi.vnggames.com/tin-tuc/tin-tuc/12-01-chinh-thuc-ra-mat-ky-nang-150.html
- JX1 tree diagram: https://jxdocs.com/s/pages ; https://gamemoira.org/huong-dan-choi-game/jx-vltk-vo-lam-truyen-ky/mon-phai-vltk/thieu-lam-vltk/
- JX2 official Thiếu Lâm, chains, secrets: https://volam2.vnggames.com/cam-nang/mon-phai/thieu-lam.html
- Kiếm Thế class categories/passives: https://kiemthe.vnggames.com/baiviet/mon-phai/cai-bang.html
- Kiếm Thế official signature skill/procs/stacks: https://kiemthe.zing.vn/su-kien/phien-ban-moi-tuyet-ky-tran-phai-495/ky-nang-tran-phai.html
- Kiếm Thế skill point extension official: https://kiemthe.zing.vn/tin-tuc/tin-tuc/huong-dan-mo-rong-ky-nang-chieu-thuc.html
