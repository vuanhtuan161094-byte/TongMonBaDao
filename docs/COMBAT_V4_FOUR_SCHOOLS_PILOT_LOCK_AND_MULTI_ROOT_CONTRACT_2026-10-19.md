# TÔNG MÔN BÁ ĐẠO — C4 FOUR-SCHOOL PILOT v1.0 + ĐA LINH CĂN/NGŨ HÀNH (2026-10-19)

**Trạng thái:** **PILOT PARAMETER BASELINE FROZEN FOR FOCUSED QA** (khóa số liệu để kiểm chứng, **không** khóa cân bằng vĩnh viễn, **chưa code, chưa có Godot runtime PASS**). Chỉ thiết kế; không làm thay đổi authority V2, main, PR #20, Economy/Save hoặc C4-VP01. Thay đổi hệ số sau benchmark phải tạo phiên bản và lý do, không sửa ngầm.

**Mục đích:** cho phép 4 phái Thiếu Lâm/Kim, Võ Đang/Thổ, Ngũ Độc/Mộc, Nga Mi/Thủy có bộ võ học chơi được; giải thích đúng nhân vật 1–5 Linh Căn và toàn bộ 5 hệ Kim/Mộc/Thủy/Hỏa/Thổ. Bộ JX trên hai Drive đã được **owner xác nhận upload đầy đủ**; điều đó chấm dứt khâu đợi owner tải lên, **không** thay các gate manifest/metadata/rights/animation-runtime.

## 0. AUTHORITY — KHÔNG ĐƯỢC PHÁ

1. V2 game law: docs/SPIRITUAL_ROOT_V2_SPEC.md, docs/COMBAT_SKILLS_V2_SPEC.md, docs/COMBAT_STATS_V2_SPEC.md, docs/TECHNIQUE_V2_SPEC.md, docs/CULTIVATION_PATH_V2_SPEC.md, docs/DV2_02_GROUP_MAP_COMBAT_CONTRACT.md, docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md, docs/DISCIPLE_MASTER_SCHEMA.md. Code authority: godot/src/simulation/combat/{combat_stats_v2,map_battle_v2,disciple_combat_loadout_v2,hunting_pve_run_v2}.gd. Prior audit (must read): docs/COMBAT_V4_JX1_DEEP_REVIEW_GAMEPLAY_SKILL_BLUEPRINT_V2_2026-10-19.md.
2. Model C: school = **truyền thừa/phong cách**, NOT permanent class/forced single elemental root/extra blanket stat multiplier. A disciple may switch Chủ Đạo and keep prior knowledge/mastery; incompatible equipped actions are disabled with explanation, never silently deleted.
3. Two progression axes: 30 Tu Vi realms ×10 floors, 30 Luyện Thể realms ×10 floors independently. 1 Thường Kỹ + at most 4 learned/equipped active + 6 triggered/party combat passive (slots open gradually through Nhân Giới). Static personal passives and Công Pháp 1 Chủ Tu+2 Phụ Tu are separate.
4. MapBattleV2 is autonomous, deterministic, 0.25s per simulation tick, arena 36×20, maximum 6/party, 30 disciples per encounter cluster, 40 monsters, 90s encounter, default AoE max3, cooldown and snapshot state authoritatively per cast. No turn-based, no universal Mana, generic dodge/accuracy or universal Threat stat.
5. Current engine does **not** implement these 16 learned JX pilot skills or complete Poison/HoT/Threat/aura consumers. Source JX browser PLAYABLE ≠ Godot gameplay verified. No import of assets in this design task. All legendary signature abilities remain strictly owner-bound and occupy an existing slot.

## 1. MỘT NHÂN VẬT CÓ NHIỀU LINH CĂN — NGUỒN QUY TẮC CHÍNH XÁC

Three distinct fields:

| Layer | Source of truth | Gameplay effect | Never do |
|---|---|---|---|
| \`faction_id\` / phái JX | school affiliation/curriculum; faction series from source | Which manual/teaching line/weapon style is available; purely a school theme otherwise | Force root to match school; add a hidden +50% faction damage; auto-learn 4 abilities |
| \`spiritual_root_values\` | personal **owned** root set, each purity 1–100 | Per-root cultivation, mastery, matching-skill numeric effect, resistance and permanent passive; resonance | Turn multiple roots into one arbitrarily selected "main element"; reroll on changing school |
| \`base_element\` of skill | authored immutable game skill definition (1 of 5 or neutral); special skill may be explicitly multi-element | Which root's matching bonus applies, elemental counter vs target primary element | Always reuse faction element; pick best-owned root automatically; double count same root |
| \`advanced_element\` | explicit mutation-gated skill tag Lôi/Phong/Băng/Dương/U Minh | Additional mutation bonus/proc only if skill and person satisfy actual mutation prerequisites | Auto grant Thiên Lôi to any lightning-looking sprite |

**Nguồn JX thật chứng minh ba lớp không đồng nhất:** Võ Đang has faction series **4=Thổ**; skill #158 Kiếm Phi Kinh Thiên and #165 Vô Ngã Vô Kiếm are declared series **4** but their source attributes include **\`lightingdamage_v\`**. Thus even JX distinguishes faction series and a damage attribute. Our V2 further distinguishes character root and upgraded mutation. A visual lightning sprite alone grants no mutation ability.

### 1.1 Birth/root mechanics already user-locked — copy, do not rebalance

Exactly five base roots: Kim/metal, Mộc/wood, Thủy/water, Hỏa/fire, Thổ/earth.

| Number of base roots at birth | 1 | 2 | 3 | 4 | 5 |
|---|---:|---:|---:|---:|---:|
| Ordinary spawn rate | 7% | 18% | 30% | 28% | 17% |

Each owned root purity P independently in [1,100]. Missing element is *absent*, not a zero-purity owned root. Typical birth purity declines with root count, but can be refined and missing root can later be added deterministically for authored rare materials. Number of roots has no permanent upper disadvantage; five perfected is a powerful long-term goal.

When N owned roots have exactly purity 100, base-root Resonance R is:

| N perfected | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---:|---:|---:|---:|---:|---:|
| R | 1.00 | 1.10 | 1.25 | 1.45 | 1.70 | 2.00 |

R is chosen **once** from this table (never multiplied across rows), amplifies contributions of **all owned base roots only**, not Tu Vi/Body, gear, Fate or mutation stat bonuses.

For *each owned root* purity P:

- cultivation speed for **matching technique activity** = \`P × 0.30% × R\`;
- learning/mastery for **matching technique/skill** = \`P × 0.15% × R\`;
- magnitude of **eligible explicitly marked root-scalable numeric effects in matching skill** = \`P × 0.30% × R\`;
- matching incoming-element resistance = \`P × 0.15% × R\`.

Plus **permanent self-only passive contributions while casting ANY legal elemental skill**:

| Owned root | Root-derived passive amount | CombatStatsV2 channel |
|---|---|---|
| Kim | \`P×0.10%×R\` Defense Penetration | percentage-points penetration |
| Mộc | \`P×0.12%×R\` Max HP | percent-add core max_hp; retain current HP ratio |
| Thủy | \`P×0.08%×R\` Attack Speed **and** Cast Speed | independent rate channels |
| Hỏa | \`P×0.10%×R\` all damage dealt (all elements) | filtered damage channel; not double-applied |
| Thổ | \`P×0.12%×R\` Defense | percent-add DEF |

Do NOT scale cooldown, cast time, control length, projectile distance, proc frequency or fixed non-scaling packets via matching skill effect bonus unless a specific content rule explicitly permits it. The **Thủy root permanent Cast Speed** is a separate legal stat source; it can reduce actual cast time according to CombatStatsV2.

### 1.2 Concrete example to keep UI honest

Disciple chooses Võ Đang/Ngự Kiếm, but owns metal80/wood45/water70/earth60 and NO fire, none perfected so R=1.00. Independent contributions before gear and other systems:
- Kim 80 => eligible Kim skill magnitudes +24%; Defense Penetration +8 percentage points; Kim resistance +12%.
- Mộc 45 => eligible Mộc skill +13.5%; self MaxHP +5.4%; Mộc resistance +6.75%.
- Thủy 70 => eligible Thủy skill +21%; self AttackSpeed +5.6% and CastSpeed +5.6%; Thủy resistance +10.5%.
- Thổ 60 => eligible Thổ skill +18%; self DEF +7.2%; Thổ resistance +9%.
- No Hỏa means **no matching Fire-root bonus and no permanent Hỏa all-damage passive**. Ordinary Fire skill may still be learned if its own prerequisites do not explicitly require Hỏa; it does **not** get a fictitious \`-50% incompatible faction\` penalty.
- If this disciple learns a Thủy sword skill from a valid teaching source, its matching root is Thủy even though the school theme is Thổ; all four personal-root passive contributions are still live.
- This is **not** all bonuses multiplied together into one \`×1.24×1.21×1.18\` for any skill. Registered stat/source channels and filtered matching rules own the order; primary element determines eligible matching bonus.

Full roots metal/wood/water/fire/earth=100 all => R2.00. Each base-element skill magnitude gets +60% (if scalable) and all five root passives coexist: Kim penetration+20pp, Mộc MaxHP+24%, Thủy attack+16%/cast+16%, Hỏa all outgoing damage+20%, Thổ DEF+24%; each matching elemental resistance +30%. This high-end power is intentional and expensive, NOT an extra bonus applied by school.

### 1.3 Khắc/Tương Sinh and multi-element skills

| Matching | Source rule |
|---|---|
| Khắc | Kim→Mộc→Thổ→Thủy→Hỏa→Kim |
| Successful counter | ×1.25 elemental effect/damage |
| Being countered | ×0.85 |
| Neutral, same element, no relation | ×1.00, before explicit resistance |
| Tương Sinh | Mộc→Hỏa→Thổ→Kim→Thủy→Mộc; **opt-in per skill**, not free party chain |

Counter uses **the cast skill's declared game element** against target primary element, NOT user school, strongest root or character's full root set. A target's own multiple elements are not automatically compared against all elements to choose the harshest; monster/content must declare one primary or neutral, optional explicit resistances, and future phases only if authored.

Multi-element skill must list required roots and independent weighted damage/effect packets. V2's starting **multi-root eligibility** purity estimator is \`0.60×min(required_root_purities)+0.40×avg(required_root_purities)\`; for Kim80 & Thủy70 this is \`0.60×70+0.40×75=72\`. **72 is a compatibility/eligibility quantity, not a +72% damage buff**. No automatic strongest-root selection. Skill will not proc twice because it has two elemental visual layers.

### 1.4 Dị Linh Căn != sixth base element / school

V1 transformations: Kim→Lôi, Mộc→Phong, Thủy→Băng, Hỏa→Dương, Thổ→U Minh. Base root is retained and still Resonates; mutation has own stage (Tiềm Ẩn, Hiển Lộ, Thức Tỉnh, Thuế Biến, Viên Mãn), additional specific buffs and unique proc, never multiplied by base Resonance. Multiple mutations may coexist.

- Lôi skill with **explicit** \`advanced_element=lightning\` and requisite mutation can activate Thiên Lôi (once/cast, shared ICD, no recursive proc).
- Băng skill with requisite mutation can apply Hàn Ấn; 3 stacks trigger normal freeze or Boss Hàn Trệ, global 6s refractory.
- Phong Thế needs an actual Phong-tagged cast; Dương Bạo consumes **caster-owned** remaining DoT to do instant damage without duplication; U Minh Minh Mệnh can intercept lethal once/encounter.
- **Võ Đang source nuance:** #158/#165 JX attributes say Lôi damage, faction still Thổ. This pilot defines **ordinary Thổ-based Ngự Kiếm** (Thổ counter/root matching) with JX lightning-themed effect presentation; it **does not** fake Thiên Lôi. A future explicitly authored \`Kim+Lôi\` upgraded variant may opt into mutation mechanics if disciple actually owns the relevant awakened mutation. This is a transparent game adaptation from JX, not a claim the browser source's raw damage type is Thổ.
- This preserves JX artwork and multi-element freedom *without breaking the already locked Kim→Lôi mutation dependency*. Native reference \`series=4 + lightingdamage_v\` stays recorded for provenance.

### 1.5 Cảnh giới/ATK/HP authority — no extra JX faction multiplier

The **user-locked** baseline before gear/Trait/etc. is computed from two *independent* progress tracks:

\`\`\`text
Gr = 1.65^(tu_vi_realm-1) * 1.03^(tu_vi_floor-1)
Gb = 1.65^(body_realm-1) * 1.03^(body_floor-1)
Pfac = 1 + 0.0005 * potential
HP  = (100*Gr + 90*Gb) * Pfac
ATK = (20*Gr +  3*Gb) * Pfac
DEF = (12*Gr +  7*Gb) * Pfac
\`\`\`

V2 \`CombatStatsV2\` then applies legitimate flat/percent-add/pp/remaining-reduction sources. A special skill's **skill ratio multiplies one resolved authorized ATK damage packet**, not \`Gr\` or \`Gb\` again. A faction's native JX stage/level is **not** another player level, extra school multiplier or a reason to ignore Tu Vi/Luyện Thể imbalance. Tu Vi-biased versus Body-biased skill build categories below are **learning/pre-requisite categories**, and the actual base of \`CombatStatsV2.attack\` already includes both progress tracks.

## 2. PILOT COMBAT CONTRACT v1.0 — NUMERIC BASELINE LOCKED FOR QA

### 2.1 Rulebook applying to all 16 active entries

**Numbers below are game-authored PILOT**, NOT source JX's original numeric damage/cooldown. Source facts limited to IDs, name, \`prop\`, \`series\`, \`attr\`, \`style\`, source animation references; do not present authored effects as extracted JX behavior.

- \`ATK\` = currently derived \`CombatStatsV2.attack\`, before each packet goes through authoritative DEF formula \`2ATK/(2ATK+DEF_eff)\`, crit/resistance/counter/DR and single true settlement. Source \`physicsdamage_v\`/ \`lightingdamage_v\` is an external reference, NOT an invitation to introduce extra physical/magic ATK stats.
- Ordinary **direct damage** crit eligible, starting Crit 5% / multiplier 1.50×, may lifesteal only when true effective damage and authorized; **DoT, reflection, HoT, shield and secondary procs** cannot crit/lifesteal unless separately authorized.
- All cast durations and CD are multiple of 0.25s. CD starts at \`cast_committed\`; interrupt **before** commit cancels effect and uses authored interruption policy. One actor cannot simultaneously commit two active actions.
- Root matching skill-effect increase applies **only** to numeric fields explicitly marked scalable: direct damage ratios, DoT tick size, effective HoT heal, shield magnitude; not to +duration/CC chance/stack cap/geometry/CD.
- Pilot projectile speed **8 arena units/s**, delay = \`ceil(distance_at_launch / 8 / 0.25)\` simulation ticks; target-locked single-target shots fizzle if target died before impact (never auto retarget); ground AoE impacts at declared world position and may be dodged; renderer frame count cannot create additional hit packets. Projectile speed is a candidate physics mapping from JX WebP sprite pixels, not a claimed raw source unit.
- Normal AoE **target cap3**; one skill can hit one target once per declared packet; nearest/stable ID tie-break, no friendly fire. Source JX \`childN=16\` does NOT imply 16 valid damage packets.
- Status chance = \`clamp(skill.base_status_chance + attacker.EffectHit - target.EffectResistance, 0,1)\` before immune/tier. Pilot Boss uses explicit refractory, NOT hidden immunity for entire school.
- Status snapshot at apply, deterministic duration/tick expiry; source on target ID/caster ID/encounter/cast ID/stack family; no duplicate source effects from animation frames or reloads.
- Initial slot loadout is **player choice**. Tables give a *fully mature four-active reference build*, not four free skills from recruitment. Primary AI uses slot1→slot4 legal checks then Basic per V2; preset names are UI recommendations only.

### 2.2 Thiếu Lâm — JX faction Kim / frontline, Luyện Thể focus

| Slot | JX reference / original fact | Game element / basis | Target | Pilot coefficient/effect | Cast | CD | AI legality |
|---|---|---|---|---|---:|---:|---|
| Basic | regular côn/quyền | Kim/Luyện Thể | one, melee1.5 | original V2 Basic (no redefinition) | canonical | canonical | available when not locked |
| Active1 | **#15 Bất Động Minh Vương**, source self-defense active | Kim/Hybrid (game adaptation) | self | **25% reduction of remaining incoming damage for 3.0s**; strongest-only with same guard family; no free global Threat | 0.50s | 14.0s | HP<70% or protected Boss AoE within imminent window |
| Active2 | **#20 Sư Tử Hống**, source internal stun attack | Kim/Tu Vi (game adaptation from source neutral) | radius2.5, cap3 | 0.50×ATK per target; 60% base **Stagger** 0.50s normal / 0.25s elite, boss gets 15% cast-time penalty for 1s on accepted effect with 6s target refractory | 0.75s | 12.0s | enemy casting or ≥2 near |
| Active3 | **#11 Hoành Tảo Lục Hợp**, source external attack | Kim/Luyện Thể | frontal 100°, cap3 | 0.80×ATK each; no automatically imported JX cold side packet | 0.75s | 8.0s | at least 2 in cone, otherwise can cast at Boss |
| Active4 | **#10 Kim Cang Phục Ma**, source external attack | Kim/Luyện Thể | melee single1.5 | 1.25×ATK direct, no automatic armor-break proc | 0.50s | 5.0s | target in range |

**Source passive #21 Dịch Cân Kinh** (allres_p): if learned, **+8% elemental resistance** as pilot static personal-only contribution (source literal numerical value is not this 8%). It **does not occupy** six combat-passive slots. **New, explicitly authored combat passive** \`HoChu\` (not a JX SkillId): when alive party ally within 3u would fall under 35% HP from an authorized hit, shield that ally for **0.45×caster ATK**, at most once/10s per caster, no recursion; occupies 1 of 6 combat-passive slots. **Threat** remains a future common target-selection consumer; neither Shaolin label nor #15 grants hidden taunt.

### 2.3 Võ Đang — JX faction Thổ / kiếm khí, Ngự Kiếm focus

| Slot | JX reference / original fact | Game element / basis | Target | Pilot coefficient/effect | Cast | CD | AI legality |
|---|---|---|---|---|---:|---:|---|
| Basic | regular kiếm attack | Thổ/Tu Vi (authored) | one, melee/ranged per equip | original V2 Basic, no extra free sword missile | canonical | canonical | valid weapon |
| Active1 | **#159 Thất Tinh Trận**, source self/area attack-support \`attackratingenhance_p,adddefense_v\` | Thổ/Tu Vi | same-party radius5u | **+10% DEF for 6s**; weakest direct attack-rating JX not mapped because V2 has no universal accuracy; strongest-only same family | 0.50s | 16.0s | ≥2 allies would benefit; no active stronger same-family aura |
| Active2 | **#165 Vô Ngã Vô Kiếm**, source Thổ series, \`lightingdamage_v\`, \`childN=16\` | Thổ/Tu Vi (authored baseline) | main one in range6u + up to 2 near | 1.15×ATK main; 0.45×ATK each secondary; **maximum 3 target IDs**, one packet/target; 16 source visual streaks not 16 hit packets | 0.75s | 10.0s | ≥2 enemies grouped or elite |
| Active3 | **#368 Nhân Kiếm Hợp Nhất**, source external attack \`lightingdamage_v\`, source series Thổ | Thổ/Luyện Thể | one in reach2u | 1.50×ATK direct; source \`stealmana_p\` **not mapped** to nonexistent mana | 0.75s | 12.0s | target elite/Boss in reach; else reposition |
| Active4 | **#158 Kiếm Phi Kinh Thiên**, source Thổ series with \`lightingdamage_v\` | Thổ/Tu Vi, **not auto Lôi mutation** | one, range6u | 1.10×ATK single direct projectile; artistic lightning VFX without automatic Thiên Lôi | 0.50s | 5.0s | legal distant target |

**Source static passive #160 Thế Vân Tung** \`fastwalkrun_p\`: +10% personal Movement Speed pilot (no slot); #166 Thái Cực Thần Công may be future static speed/cast filtered channel, not automatically learned. **New authored combat passive** \`KiemYCongHuong\` (1/6 slots): after two **true skill-hit cast commits** by same caster against same live target within 6s, deal one non-crit, non-lifesteal secondary **0.25×ATK** to that target (one per cast, ICD8s); reset combo after target loss, no self-proc chain. This is new gameplay content, not present under #158 or #165 in source.

**Mandatory elemental-disclosure tooltip** for #158/#165: *“Võ Đang nguồn JX hệ Thổ; bản game pilot dùng sát thương Thổ, dùng VFX lôi làm mỹ thuật; chưa có Thiên Lôi. Phiên bản Lôi cần Dị Căn và định nghĩa riêng.”* After future owner approval, may author a new subfamily tagged \`base_element=metal,advanced_element=lightning\` (Kim/Lôi mutation), never stealth-upgrade this pilot.

### 2.4 Ngũ Độc — JX faction Mộc / Độc công, Pháp Tu focus

| Slot | JX reference / original fact | Game element / basis | Target | Pilot coefficient/effect | Cast | CD | AI legality |
|---|---|---|---|---|---:|---:|---|
| Basic | regular độc chưởng | Mộc/Tu Vi | one | V2 Basic, no free DoT per animation | canonical | canonical | valid target |
| Active1 | **#73 Vạn Độc Thực Tâm**, source attack support \`poisontimereduce_p\`, NOT proved flat -poison resistance | Mộc/Tu Vi (author) | one poisoned enemy range6 | **+1.0s remaining duration to eligible caster-owned poison**, remaining duration cap4.0s; NOT detonate or other caster DoT | 0.50s | 14.0s | target has caster-owned Poison + not at cap |
| Active2 | **#384 Bách Độc Xuyên Tâm**, source poison direct attack, NO source detonate proof | Mộc/Tu Vi | one enemy range5 | **1.30×ATK direct**, no fake stack consumption; +10% packet magnitude if target has valid poison stack (authored) | 0.75s | 11.0s | target poisoned, elite/Boss; otherwise can still attack |
| Active3 | **#68 U Minh Khô Lâu**, source poison damage attack | Mộc/Tu Vi | one enemy range5 | **1.05×ATK direct**, poison interaction only if specified; one projectile hit | 0.50s | 7.0s | enemy poisoned or normal DPS opportunity |
| Active4 | **#63 Độc Sa Chưởng**, source \`poisondamage_v\` attack | Mộc/Tu Vi | one enemy range5 | **0.75×ATK initial direct + poison 0.12×snapshot ATK at t+1,t+2,t+3 seconds**, no crit/lifesteal on ticks | 0.50s | 5.0s | target missing caster's poison or poison near expiry |

**Poison status contract, pilot:**
- Status family \`PoisonJX_P1\`, per-target **global max3 valid stacks across all casters and parties**, each stack has creator/source ID, applied snapshot, next tick and expiry; one caster may own at most one same-skill stack on target. Reapplication owned stack refreshes rather than producing infinite parallel stacks; if global cap is full and caster has none, **reject new stack** instead of stealing another caster's credit.
- Poison application base status chance **85%**, then canonical Effect Hit-Effect Resistance, Boss explicit tolerance; direct damage can still land even if poison fails. DoT 0.12×ATK each second for 3s, no per-tick crit/lifesteal or mutation proc. Resistances and root skill magnitude follow V2 configured channels, at apply snapshot. Boss not universally immune to poison.
- #73 may extend only own stacks if currently active, never total >4 seconds remaining or refresh at no benefit. No DoT detonation without explicit separate skill mechanic/owner approval.
- **Static passive #66 Tạp Nan Dược Kinh:** +10% personal poison resistance pilot, no combat slot. **Authored combat passive** \`DocMacSinhCo\` occupies 1 of 6 slots: once caster successfully applies a Poison status to a live enemy, self-heal up to **0.10×ATK effective missing HP**, ICD10s; does not proc from DoT ticks or other caster's poison and may not grant mastery via overheal.

### 2.5 Nga Mi — JX faction Thủy / Y Đạo, healing and ice attacks

| Slot | JX reference / original fact | Game element / basis | Target | Pilot coefficient/effect | Cast | CD | AI legality |
|---|---|---|---|---|---:|---:|---|
| Basic | regular water/cold-attack motif | Thủy/Tu Vi | one | V2 Basic; no default healing | canonical | canonical | alive enemy |
| Active1 | **#93 Từ Hàng Phổ Độ**, source self support \`lifereplenish_v\` (regen!), not instant team heal | Thủy/Tu Vi (authored party retarget) | damaged ally in own party range6 | **HoT 0.40×snapshot ATK** each t+1,t+2,t+3 seconds (total max 1.20×ATK before modifiers), no revive; choose most useful missing HP ally | 0.50s | 8.0s | wounded living ally HP<70% and meaningful missing HP; no active stronger family HoT |
| Active2 | **#282 Thanh Âm Phạn Xướng**, source party-area/status-duration and hit recovery; NOT instant cleanse | Thủy/Tu Vi (authored party buff) | same-party allies within5u | **shorten duration of newly applied negative control/debuff by 20% for 5.0s**; does not remove an already-active debuff, excludes locked hard-procs | 0.50s | 14.0s | Boss/elite uses statuses, ≥2 party members in range |
| Active3 | **#91 Phật Quang Phổ Chiếu**, source Thủy-series cold attack | Thủy/Tu Vi | target-centered radius2.5, up to3 enemies | **0.80×ATK each**, Water/base Cold visual, attack NOT heal | 0.75s | 10.0s | ≥2 enemies grouped |
| Active4 | **#80 Phiêu Tuyết Xuyên Vân**, source cold direct projectile | Thủy/Tu Vi | one enemy range6 | **1.00×ATK direct**; no automatic Freeze without actual Băng mutation and explicit skill tag | 0.50s | 5.0s | legal target otherwise Basic |

**HoT family:** same-caster same-family refresh/strongest-only; multiple same-party casters obey authored strongest-only on target at a time for **baseline pilot**. Source attribution to actual healer and party, HoT ticks only count positive HP recovered. If a target is **Bị Hạ** (0 HP) ordinary HoT stops and cannot revive; no 0→live by tick. An emergency second heal cast cannot create infinite overwrite-grind mastery.

**Static passive #77 Nga Mi Kiếm Pháp**: weapon-tag-filtered +5% direct sword-skill contribution (pilot, only real compatible weapon, if learned), no active combat slot; role-healer without sword does not receive phantom buff. **Authored combat passive** \`YDaoHoChu\` (1/6 slots): while caster alive, an ally in own party within5u drops below35% HP from true damage, grant noncrit **0.50×caster ATK shield**, ICD12s; not a revive and same effect-key family obeys strongest-only with other rescue shields.

### 2.6 Element coverage without expanding to fifth school

The four full-school pilots cover **Kim (SL), Thổ (VĐ), Mộc (NĐ), Thủy (Nga Mi)**. **Hỏa is not omitted from combat laws.** QA must create enemy with primary Fire and explicitly Fire-tagged authorized packet to test all five elemental counters and Fire root's *all-damage* passive. This is a **focused simulation test fixture**, NOT a fifth production school or free unlocked skill. After 4-school acceptance, first recommended Fire school expansion is **Cái Bang** (physical/ranged Fire) or **Thiên Nhẫn** (burst/DoT Fire), then other 5 of 10 classical factions; no surprise auto-opening.

## 3. AI TARGETING, CAST TIMING, SAVES AND TEAM BUDGET

**AI legal order:** alive, not Bị Hạ, no incompatible weapon/branch, cooldown tick ready, no cast locked, legal path/target, support effect truly useful; check active slots 1→4; otherwise Basic. Players can reorder slots outside encounter, using saved prebattle build; **no AI global utility solver** overriding canonical V2 priority. A safety prompt may recommend better slot order; it does not secretly cast slot4 first. Pilot recommended loadouts place emergency support first and ordinary damage last.

**Default monster behavior:** no hidden per-school aggro. True Threat requires separate source/action and normal enemy target-policy consumer. Boss telegraph must be visible for a meaningful interval and resolved on combat tick independent of animation frames; hard CC never produces unbounded interrupt loops. Nearby support choices require party_id, stable tie by actor ID, avoid overheal.

**Multi-party shared target:** cap3 AoE per actual cast, shared debuff/Poison cap3 total on same Boss across all five parties, buff/shield scoped same party unless explicitly encounter-wide. Six party × five does NOT create 30 automatic stat auras. Guard/shield/DR order authored and receipts stable.

**One cast identity:** \`(encounter_id,caster_id,cast_id,packet_index,target_id)\` stable; status tick plus proc derived from real cast source, not clip frames. Cooldowns/timers stored in integer ticks. Example cast0.75s=3 ticks, CD5s=20 ticks, CD14s=56 ticks. Source JX \`fx.js.ms\` is **render frame timing**, not simulation period.

**Effect eligibility:** ordinary direct eligible crit/lifesteal, DoT/HoT/reflect/mutation proc/shield no crit by default, no hidden universal accuracy. Repeated visual child missiles don't spawn multiple unapproved damage packets; status snapshot/expiry and clip playback are independent.

**Persistence/receipts:** after any save/resume, same seed+initial inputs→same event/journal regardless viewed/offscreen, no extra poison ticks/hoT ticks/triggered passive, no extra loot, no double Injury, no double action job. Existing HuntingPveRunV2 reserves actual members and settles through existing SaveService, not cloned.

**Enemy/scale balancing:** 6v6 group, 6vBoss+guards, 30v40 shared and one 90s cap; all variants compare Mộc root absent/present, Thủy speed, Hỏa all-damage, Kim piercing vs Mộc boss, Thổ vs Thủy boss, Wudang skill Thổ vs Fire boss. Low-tier r1,r5,r10 and boundary r10→11/r20→21 and high r30; independent TuVi/Body imbalance. Benchmark 30–100 fixed seeds per representative build; record win/TTK/downed/injury/remaining HP, damage/HoT effective/heals over time, shield absorbed, CC uptime, AoE target spread, proc rate, runtime event count, per-source stat contributions. The original 16-seed Boss experiment where no-healer team still won 16/16 is only one scenario, not balance lock.

## 4. SOURCE JX EVIDENCE — VERIFIED FIELDS ONLY

The new Drive's \`data.js\` (file id \`1FTnYuDdO0SlZFdvUzlCXjn5r8JPV8K9m\`) was directly parsed 2026-10-19 for exact IDs. Source skill facts:

| SkillId | New source prop/series | Source \`attr\` verified |
|---|---|---|
| 10 | 外功 attack, series=Kim | \`physicsenhance_p\` |
| 11 | 外功 attack, series=Kim | \`physicsenhance_p\`, \`colddamage_v\` |
| 15 | active self-defense, series=-1 | \`adddefense_v\`, \`attackratingenhance_p\` |
| 20 | internal stun-attack, series=-1 | \`stun_p\`, \`physicsdamage_v\` |
| 21 | defense static passive, series=-1 | \`allres_p\` |
| 158 | internal attack, **series=Thổ (4)** | **\`lightingdamage_v\`**, \`physicsenhance_p\` |
| 159 | support area, series=-1 | \`attackratingenhance_p\`, \`adddefense_v\` |
| 160 | static body/utility, series=-1 | \`fastwalkrun_p\` |
| 165 | internal attack, **series=Thổ(4)**, \`childN=16\` | **\`lightingdamage_v\`**, \`stun_p\` |
| 368 | external attack, series=Thổ(4) | \`lightingdamage_v\`, \`stealmana_p\` |
| 63 | internal attack, series=Mộc(1) | \`poisondamage_v\` |
| 66 | defense static passive, series=-1 | \`poisonres_p\` |
| 68 | internal attack, series=Mộc(1) | \`poisondamage_v\` |
| 73 | attack-support, series=-1 | \`poisontimereduce_p\` |
| 384 | internal poison attack, series=Mộc(1) | \`poisondamage_v\` (NOT source detonate) |
| 80 | internal attack, series=Thủy(2) | \`colddamage_v\` |
| 91 | internal AoE attack, series=Thủy(2) | \`colddamage_v\`, **NOT heal** |
| 93 | self-support regen, series=-1 | \`lifereplenish_v\` (NOT native party instant heal) |
| 282 | self/area support, series=-1 | \`freezetimereduce_p, poisontimereduce_p, stuntimereduce_p, fatallystrikeres_p\` |

Original source naming occasionally has variant capitalization/spelling (e.g. source 'Độc Sa chưởng', 'Dịch Cân kinh'); normalized Vietnamese UI labels above are **display aliases**, recorded with source IDs. **The stat ratios, intervals, target cap, support target, marks, combat-passives and Thổ skill adaptation are authored game choices, not raw source facts.**

Asset proof: DRIVE-N 202/202 named FX WebP paths matched, actor \`img/a\` 585 WebP=117 \`at,die,hurt,run,st\` five-clip groups and 232 real \`snd\` MP3; DRIVE-O native 176 WebP+74 WAV, \`char\` 132 WebP, \`fx\`49 WebP, \`sfx\`31 MP3 observed in preceding audit. The owner says upload is complete, but **Godot import, direction, atlas frame rect/anchor/hash and runtime visuals still PENDING**. Do not republish third-party JX copyrighted artwork without separate rights clearance, despite permission to work on user's personal copies.

## 5. FOCUSED ACCEPTANCE GATES TO FREEZE PILOT v1.0

| Gate | Must prove in a real authorized implementation | Blocker if missing |
|---|---|---|
| P0 owner/source | 4×4 active IDs, 4 sourced static passives, four authored combat passives have distinct source vs gameplay metadata | No "JX authentic" claim for invented abilities |
| P1 multi-root | one-root vs 3-root vs 5-root bonuses, all permanent root passives, completed-root resonance, missing-root skill behavior, no school buff | No implicit one-root conversion |
| P2 elemental matchup | 5×5 table and neutral; ×1.25/×0.85/×1, per-skill element, target primary, no best-root auto selection | Do not convert faction→skill element |
| P3 status/AI | poison global cap, true HoT/recovery, both combat-passive ICD, selected target in same party, source attribution | No cosmetic status, overheal mastery, proc loop |
| P4 rate/ticks | cast0.50/0.75 release correctly, CD5/8/14 on ticks, CastSpeed changes legal ticks, no 16-visual-hit duplication | No FPS-driven hit, no 0.35s fake tooltip |
| P5 six vs Boss | 30–100 seed permutations, healer contribution (injury/downed/remaining HP), tank Threat not implicit, AoE target max3 | No 16/16 win-only balancing |
| P6 save/replay | viewed/offscreen same event stream, reload mid-HoT/mid-Poison/mid-cast, One Active Job, exactly-once Injury/reward | No duplicate tick/reward |
| P7 visuals/mobile | TEMP clone, actual Godot 4.7.2 1280×720, per-source FX/clip sound/anchor true, Android texture/FPS/memory | Runtime remains PENDING without runner |

**Implement only on new explicitly approved allowlist branch** after this **design-only parameter freeze**; deploy narrow true consumers first (Poison, HoT, support buff, single projectile, per-caster passive ICD). Then build four school kits, independently validate root consumers and 5-element matchup, and add Fire-themed faction pilot as next wave. No CI/FULL/merge/main/PR20/Economy/Save operations are implied.

**End — C4 FOUR SCHOOLS PILOT v1.0.**
