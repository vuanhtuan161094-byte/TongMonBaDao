# TMB — TAM CĂN • TỨ TÍNH / 16 COMBAT STATS / BIRTH ODDS (D7–C16)

Date: 2026-10-23 | Status: **DESIGN NUMBERS SELECTED FOR OWNER REVIEW**, docs only; NO Godot runtime migration, no code, no CI/FULL, no merge.  
Baseline: \`main@29b5fba448b0178cb520a4ada44b375b4b934e31\`. **Do not touch Codex master recovery or draft PR#24/#25.** Earlier design predecessor: \`docs/tmb-tam-can-tu-tinh-v3-numeric-lock-20261023/docs/design/TMB_V3_TAM_CAN_TU_TINH_COMBAT_NUMERIC_DESIGN_LOCK_2026-10-23.md\`.  
**Terminology:** OWNER DIRECTION = explicitly requested ×100 Tu Vi Core, Tu Vi-only Potential, review 3+4. SOURCE = current game code/docs. PROPOSED-SELECTED = exact recommendation fixed in this design doc for testing, not approved gameplay code, not a new permanent locked owner coefficient. DERIVED = mathematically obtained. PILOT = current unvalidated runtime content. This document does not convert proposals into runtime truth.

## 1. Comparative design research

- The Strongest Sect (最强祖师) player guides describe six disciple dimensions and a dominant combat-oriented Potential; insight: prevent all builds from becoming Potential-only. https://www.taptap.cn/moment/523495672154949004 and https://www.taptap.cn/moment/601377068508252716 (community guides, not canonical source code).
- Amazing Cultivation Simulator separates five base attributes, derived Potential and fluctuating Mental State; insight: acquired mind progress should not be a duplicate permanent learning attribute. https://amazing-cultivation-simulator.fandom.com/wiki/Five_Attributes and https://amazing-cultivation-simulator.fandom.com/wiki/Mental_State (community wiki).
- Tale of Immortal gives Luck and Insight distinct gameplay roles; insight: meaningful event odds, not hidden per-hit/per-loot rolls. https://tale-of-immortal.fandom.com/wiki/Stats (community wiki).
- TMB source authority wins over references. Source files read: \`AGENTS.md\`, \`CURRENT_CHECKPOINT.md\`, \`NEXT_CHAT_HANDOFF.md\`, \`docs/DISCIPLE_MASTER_SCHEMA.md\`, \`docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md\`, \`docs/DV2_02_COMBAT_STAT_EXECUTION_CONTRACT.md\`, \`docs/COMBAT_STATS_V2_SPEC.md\`, \`docs/BODY_CULTIVATION_V2_SPEC.md\`; \`foundation_system.gd\`, \`disciple_generator_open_points.gd\`, \`disciple_generator_v2.gd\`, \`recruitment_system.gd\`, \`combat_stats_v2.gd\`, \`combat_skill_system.gd\`, \`disciple_combat_loadout_v2.gd\`, \`monster_catalogue_v2.gd\`, \`map_battle_v2.gd\`.

## 2. The EXACT seven attributes and effects

Choose **Tam Căn (3): Tư Chất, Căn Cốt, Tâm Tính** + **Tứ Tính (4): Tiềm Lực, Thông Tuệ, Cơ Duyên, Mị Lực**. Luyện Tâm remains acquired mind development, not the seventh birth field. All point values are OPEN PERMANENT stats (no hard cap; birth envelope is NOT an afterbirth cap).

| ID / Group | Stat | Effect of +100 points | Exact rule / scope | Status |
|---|---|---|---|---|
| aptitude / Tam Căn | Tư Chất | +25% **natural Tu Vi EXP** | 1 + 0.0025*A; not fixed +EXP pills or stat Core | SOURCE |
| constitution / Tam Căn | Căn Cốt | +20% natural **Body EXP** | 1 + 0.0020*C; one eligible Body source/min, not fixed EXP | SOURCE |
| constitution / Tam Căn | Căn Cốt | +2.5% of **Body Core** | 1 + 0.00025*C, solely HP/ATK/DEF from Body realm | PROPOSED-SELECTED |
| mind_nature / Tam Căn | Tâm Tính | +20% verified active **Luyện Tâm progression** | 1 + 0.0020*M; mental status resistance is a separate bounded tag-only function | PROPOSED-SELECTED |
| potential / Tứ Tính | Tiềm Lực | +5% **Tu Vi Realm Core** | 1 + 0.0005*P; NEVER Body Core or XP or item flat | OWNER SCOPE + SOURCE RATE |
| comprehension / Tứ Tính | Thông Tuệ | +15% study/mastery/profession XP | 1 + 0.0015*I; not ATK, not mental status | SOURCE |
| fortune / Tứ Tính | Cơ Duyên | +100 in a 0..9999 random-event score | LuckScore = RNG(0..9999) + Fortune − Difficulty | SOURCE |
| charisma / Tứ Tính | Mị Lực | +100 in social score; separate Dẫn Tiên rate | SocialScore = RNG(0..9999)+Charisma−Resistance; recruitment §3 | SOURCE |

**Tam Căn expectation = 3/7=42.857% of newborn total point budget; Tứ Tính = 4/7=57.143%**, provided the 7 axes are statistically symmetric. This is an EXPECTATION, **not a mandated 43/57 distribution for every disciple**. A highly specialized individual may have disproportionate Căn Cốt, or Tiềm Lực, or Tâm Tính. No separate "rarity" roll per attribute.

Tâm Tính (only meaningful mental outcomes): startup Tâm Trạng 70/100; five cumulative Tâm Nguyên tier thresholds **0/100/300/700/1500**; verified Tĩnh Tâm +2 Tâm Nguyên per 10 active sim minutes × (1+0.002*M), valid rest +0.10 Tâm Trạng/min, active Tĩnh Tâm +0.50/min × (1+0.002*M), cap Tâm Trạng at100. Mental-tag-only resistance = \`0.10*M/(M+400) + 0.01*mind_tier\`, tier0..4, as decimal probability points; only mental-tag content consumes it. Milestone tier gives Tu Vi major-gate **+1pp per tier**, and Tâm Trạng≥90 **additional +1pp** on eligible event; clamp final to 100%. No compulsory heart-gate and no Body gate RNG. Specific event income and penalties are defined in predecessor doc, PROPOSED-SELECTED, not runtime.

## 3. Exact birth quality odds — SOURCE by path, not invented

These are five mutually exclusive *quality bands*, not seven independent rarity rolls:

| Grade | Q_normalized (six-stat-equivalent) | P3.7 ordinary / unboosted Dẫn Tiên | Legacy opt-in SOURCE_GACHA if Dẫn Tiên OFF | SOURCE_FATE | Dẫn Tiên main guide Mị Lực 2500 (conditional active boost) |
|---|---:|---:|---:|---:|---:|
| Phàm Thường | 120–359 | 65% | 42% | 50% | 35% |
| Xuất Chúng | 360–599 | 25% | 30% | 28% | 25% |
| Thiên Kiêu | 600–999 | 8% | 18% | 14% | 20% |
| Tuyệt Luân | 1000–1799 | 1.8% | 8% | 6% | 15% |
| Nghịch Thiên | >=1800 (no cap) | 0.2% | 2% | 2% | 5% |

Dẫn Tiên Chiêu Mộ Lệnh uses current same-day **Dẫn Tiên** rates and consumes a real recruitment order, **not** the \`SOURCE_GACHA\` fallback while Dẫn Tiên is enabled (see \`RecruitmentSystem.gacha_candidate\`). The fallback 42/30/18/8/2 applies only to relevant **legacy gacha path when guidance is off**, do NOT advertise it as Dẫn Tiên premium rates. \`SOURCE_FATE\` is another separate path, not ordinary Dẫn Tiên. All values in this table are existing SOURCE; new seven-way split must preserve those when replacing birth implementation.

**Guidance interpolation** (SOURCE):
\`t = clamp(MainGuideCharisma / 2500,0,1)\`, \`rate_i = base_i + (max_i-base_i)*t\`. Before daily enhanced-quota expires:

| Main guide Mị Lực | Phàm Thường | Xuất Chúng | Thiên Kiêu | Tuyệt Luân | Nghịch Thiên | Enhanced Nghịch Thiên allowance/day |
|---:|---:|---:|---:|---:|---:|---:|
| 0 | 65% | 25% | 8% | 1.8% | 0.2% | 0 |
| 625 | 57.5% | 25% | 11% | 5.1% | 1.4% | 1 |
| 1250 | 50% | 25% | 14% | 8.4% | 2.6% | 2 |
| 2500 | 35% | 25% | 20% | 15% | 5% | 4 |
| 5000 | 35% | 25% | 20% | 15% | 5% | 8 |

At quota exhaustion, ALL enhanced quality rates revert to base 65/25/8/1.8/0.2 for that day; ordinary 0.2% high-quality remains possible. Event counted on candidate appearance not acceptance; daily parameters snapshot and reset by canonical simulation day. **No independent free 5% Nghịch Thiên forever.**

**Q target draw**: Existing \`DiscipleGeneratorOpenPoints._roll_total_for_quality\` for normal 120..359 uniform, outstanding 360..599, prodigy 600..999, peerless 1000..1799. Heaven-defying: start at floor1800, span1200; with probability 12% advance a tail block, doubling span each advance; Q drawn uniformly in resulting \`[floor, floor+span-1]\`. Not hard-capped at 2999. Avoid inventing a Q cap. Always ensure Q grade aligns with source roll.

## 4. Distribution of 7 *individual* foundation values

**PROPOSED-SELECTED** exact new-birth algorithm, to be implemented with independent deterministic RNG domain, not on current main:

1. Source → quality grade probabilities §3.
2. Roll \`Q_target\` using current grade's Q law (long tail preserved).
3. Set \`S7_target = round(Q_target * 7/6)\`; then \`Q = round(S7 * 6/7)\`, and assert \`Q == Q_target\` (Godot GDScript rounding in dedicated test).
4. Initialize all seven points at \`lo=max(1,floor(S7/14))\`; enforce \`hi=max(lo,floor(3*S7/7))\`. Thus each new-birth dimension is roughly **0.5× to 3× seven-stat mean**, same balance concept as current six-value envelope, but integer exact.
5. Permute indices 0..6 deterministically (Fisher-Yates), allocate \`remaining=S7-7*lo\` sequentially within feasible \`[max(0,remaining-capacity_remaining), min(hi-current,remaining)]\`, uniformly integer per step. Last position receives exact remainder. Assert sum matches and every dimension in [lo,hi].
6. No special bonus weight for any of the seven at ordinary birth. Under seven-axis exchangeability, probability a dimension is the **unique** strict max can be below 1/7 due to ties; with tie-breaking distributed symmetrically, each has **1/7 = 14.2857%** chance to be credited highest, and each of Tam Căn collectively 3/7 in expectation. Birth envelope does not constrain permanent postbirth growth.
7. P3.7 SOURCE_FATE presently has a 70%-probability **Cơ Duyên highest-stat swap** after allocation. Preserve that separate fate-path behavior (with index adapted to 7), not universal ordinary chance. No 70% special bonus for Tâm Tính.

**Representative S7 budget** (DERIVED; not maximum per stat):

| Grade | Example Q | S7 | Average of seven | Born lo..hi per stat |
|---|---:|---:|---:|---:|
| Phàm Thường | 240 | 280 | 40 | 20..120 |
| Xuất Chúng | 500 | 583 | 83.29 | 41..249 |
| Thiên Kiêu | 800 | 933 | 133.29 | 66..399 |
| Tuyệt Luân | 1400 | 1633 | 233.29 | 116..699 |
| Nghịch Thiên | 2400 | 2800 | 400 | 200..1200 |

**Example Thiên Kiêu Q800, S7=933:** \`[TưChất85,CănCốt120,TâmTính71,TiềmLực66,ThôngTuệ366,CơDuyên70,MịLực155]\`. Sum 933; dedicated **learning** talent rather than universal combat monster.

**Independent MONTE CARLO**, not official Godot outcomes. A clean-room Python numerical model of steps 1–5 above (ordinary grade Q logic, random feasible sequential allocation), deterministic seed \`20261023\`, **n=250000 total (50000 per grade)**. Percentiles apply to **a fixed named dimension** (index0), not the *maximum across seven*: under ordinary symmetric roll every named stat has same marginal distribution.

| Grade | P10 / P50 / P90 of ONE attribute | P(attribute>=100) | P(attribute>=200) | P(attribute>=500) | P(attribute>=1000) |
|---|---|---:|---:|---:|---:|
| Phàm Thường | 15 / 29 / 83 | 6.02% | 0% | 0% | 0% |
| Xuất Chúng | 36 / 56 / 167 | 25.98% | 5.02% | 0% | 0% |
| Thiên Kiêu | 61 / 93 / 275 | 46.02% | 19.58% | 0% | 0% |
| Tuyệt Luân | 105 / 164 / 481 | 93.04% | 39.66% | 9.04% | 0% |
| Nghịch Thiên | 187 / 308 / 896 | 100% | 85.19% | 28.92% | 7.16% |

The long-tail Nghịch Thiên sample is **conditional** and uses 50,000 forced Nghịch Thiên, not 50k ordinary recruits; the real occurrence of that *grade* in ordinary is 0.2%. Raw percentage estimates have Monte Carlo error; use official Godot seed/domain tests before implementation. Distributing points this way gives distinct specialists, but leaves weaker builds viable via time/permanent growth. If future gameplay reveals excessively polarized early disciples, revise the explicitly named **birth envelope distribution** after testing, not secretly boost combat to conceal it.

**Migration**: old six stats remain original, do not reroll. New \`mind_nature_birth=round(sum(old_six_birth)/6)\`, current \`mind_nature=round(sum(old_six_current)/6)\` with provenance \`compat_migration_v3\`; normalized quality matches prior six-stat raw sum for integer old points. Requires versioned save/schema, deterministic tests, UI and RNG migration. Existing 6D score thresholds **360/600/1000/1800 remain after Q normalization**. Do not treat additional Tâm Tính as a random free reroll or guaranteed new quality promotion.

## 5. Combat 16 — exact numeric base, application, technical limit and proposed build reference

**OWNER ×100 + Tu Vi-only Potential; PROPOSED Căn Cốt Body affinity; SOURCE combat math otherwise unchanged.** No arbitrary new turn order, Accuracy/Dodge, generalized Mana or combat_power as damage authority.

CORE for Tu Vi and Body both rank1.floor1:
\`\`\`
G(r,f)=1.65^(r-1)*1.03^(f-1)
RealmCore = (HP10000,ATK2000,DEF1200)*G(tu_vi)
BodyCore  = (HP9000,ATK300,DEF700)*G(body)
CoreFinalBeforeFlat = RealmCore*(1+0.0005*Potential) + BodyCore*(1+0.00025*Constitution)
FinalCore = max(channel_floor,(CoreFinalBeforeFlat + independent item/skill flat)*(1+same_channel_percent_add))
\`\`\`

| # | Combat channel | No-source base at 1.1 | Actual rule | Numerical technical bound | Reference future content budget, NOT universal cap |
|---:|---|---:|---|---|---|
| 1 | HP / max_hp | **19,000** (Realm10k+Body9k) | V3 Core, HP ratio rescale; no free HP on modifier change | max(1, HP) | no fixed affix defined yet |
| 2 | ATK / attack | **2,300** (Realm2k+Body300) | V3 Core × skill ratio, attacker ATK controls DEF curve | >=0 | no fixed affix defined yet |
| 3 | DEF / defense | **1,900** (Realm1200+Body700) | V3 Core, attacker penetration after target status | >=0 | no fixed affix defined yet |
| 4 | Movement / move_speed | **1.00×** base action movement | base speed from fighting style ×(1+bonus) | >=0; actor motion floor belongs to action | compare +0/+10/+30/+50% |
| 5 | Attack rate / attack_speed | **+0%** | base attack interval / (1+rate) | invalid <=−100%; map min effective interval 0.25s, 0.25s step quantization | compare +0/+20/+50/+100% |
| 6 | Cast speed / cast_speed | **+0%** | base cast time / (1+rate), where consumer wired | invalid <=−100%; action min frame | compare +0/+15/+35/+50% |
| 7 | Cooldown recovery / cooldown_recovery | **+0%** | authored cooldown / (1+rate), where consumer wired | invalid <=−100%; skill may set own minimum | compare +0/+15/+35/+50% |
| 8 | Crit chance / crit_chance | **5%** | effective clamp(attacker chance−target crit resist,0..100%) | chance 0..100% | compare 5/15/35/55% |
| 9 | Crit damage / crit_damage | **×1.50** (150% of ordinary damage) | additive modifier into multiplier, not multiplicative chaining | >=×1.00; no hard max from source | compare ×1.50/×1.75/×2.20/×3.00 |
| 10 | Crit resist / crit_resistance | **0 percentage points** | subtract from attacker crit chance | 0..100pp | compare 0/10/25/40pp |
| 11 | Defense penetration / defense_penetration | **0%** | target effective DEF = DEF*(1−penetration) | 0..100% | compare 0/10/25/45% |
| 12 | Effect hit / effect_hit | **0pp** | base debuff chance + hit−resistance | signed source permitted; final effect chance 0..100% | compare 0/+10/+25/+40pp |
| 13 | Effect resist / effect_resistance | **0pp** | subtract from eligible debuff application chance | signed source permitted; final chance 0..100% | compare 0/+10/+25/+40pp |
| 14 | Damage reduction / damage_reduction | **0%** | independent sources multiply *remaining* damage | each regular source in [0,100%); no silent absolute immunity | compare 0/10/25/40% actual reduction |
| 15 | Lifesteal / lifesteal | **0%** | max(0, attackerLS−targetAntiLS) × real target HP lost; cap by missing attacker HP | source nonnegative; NO invented hard max 100% | compare 0/5/15/30% |
| 16 | Anti-lifesteal / lifesteal_reduction | **0%** | subtract *percentage points* from attacker LS | source nonnegative; NO invented hard max 100% | compare 0/5/15/30pp |

Other derived **10 keyed elemental resistances**: metal, wood, water, fire, earth, lightning, wind, ice, yang, nether; each no-source 0%; independent sources multiply remaining incoming elemental damage, example resistance30% +20% => 44% actual; benchmark 0/10/30/50% per matched element. These are not ten extra birth attributes. Five-element counter is separate authored match-up, not the same resistance channel.

**Timing style actual SOURCE** (\`CombatSkillSystem.style_profile\`):
| Style | movement world units/s | basic attack interval s | attack ratio | default range world units |
|---|---:|---:|---:|---:|
| Sword | 3.10 | 1.10 | 1.00 | 1.90 |
| Body | 2.50 | 1.45 | 1.15 | 1.35 |
| Spell | 2.70 | 1.65 | 0.85 | 5.50 |
| Balanced | 2.70 | 1.35 | 1.00 | 1.75 |

These values are BASE before gear/context and not proof of same full DPS across roles. Combat step=0.25s and action scheduling quantize attack intervals; cast_speed and cooldown_recovery are **not yet actually consumed for learned skills by \`MapBattleV2._try_learned_damage_skill\`**, an integration debt. The two monster action adapters differ in plain-basic crit eligibility; must reconcile before calling crit PvE balanced.

**Full direct-damage order SOURCE**:
\`\`\`
effective_crit_chance = clamp(CritChanceAttacker - CritResistTarget,0,1)
effective_def = max(0,TargetDEFafterStatus)*(1-clamp(Penetration,0,1))
DEFfactor = 2*AttackerATK/(2*AttackerATK + effective_def)
DirectDamage = AttackerATK*authoredAttackRatio*(crit?CritMultiplier:1)*DEFfactor
               *authoredElementMatchup*(1-targetElementResistance)*(1-targetDamageReduction)
\`\`\`
DoT, fixed damage, shields, heal, mental status each need their explicit action owner. Source bonuses must be registered with provenance; unknown global source/filter cannot silently apply. No fake “attack accuracy/evasion”.

**Illustrative equal-track 1.1 V3** (P=Potential, C=Constitution, no skills/gear/roots):
| P/C | HP | ATK | DEF |
|---|---:|---:|---:|
| 0/0 | 19,000 | 2,300 | 1,900 |
| 100/100 | 19,725 | 2,407.5 | 1,977.5 |
| 200/200 | 20,450 | 2,515 | 2,055 |
| 500/500 | 22,625 | 2,837.5 | 2,287.5 |
| 1000/1000 | 26,250 | 3,375 | 2,675 |
| 2500/2500 | 37,125 | 4,987.5 | 3,837.5 |

**P=100 grants +5% of only RealmCore** = +500HP/+100ATK/+60DEF at 1.1, not +5% of 19k/2.3k/1.9k. **C=100 grants +20% natural Body EXP AND +2.5% BodyCore** = +225HP/+7.5ATK/+17.5DEF at 1.1. High constitution additionally accelerates Body rank progression and thus indirectly stats. These are distinct pathways that require anti-runaway checks on high-point characters.

## 6. Measured vs proposed combat balance & source scaling

- **DERIVED unchanged hit-equivalence when all actors scale ×100**: equal-rank first player baseline HP19k ATK2.3k DEF1.9k vs first **Thanh Lang** source factors, monster HP17,100 ATK2,024 DEF1,368; direct player hit ≈1,773HP -> **10 hits to kill**, wolf hit ≈1,377HP -> **14 hits to kill player** without crit, casts, other actors, movement, regen. Not timing/playtest.
- **PROPOSED TTK target envelope**: naked ordinary same rank 8–14 basic-hit equivalents (species dependent), real normal fight 10–25s, elite small party20–50s, boss team6 30–75s. Future budget test 1/3/6/2 teams, +1/−1 major, TuVi/Body asymmetric R1/3/5/10/20/30, P/C/M 0/100/200/500/1000/2500/10000, all relevant stats & role contributions. **Targets are not Godot PASS**.
- **×100 dependency gate**: V2 monster canonical 190/23/19 must become 19,000/2,300/1,900 only in coordinated code packet; fixed HP potion +55 old → candidate +5500 at first rank; fixed healing from skill and services and flat gear must be audited, not blanket multiply XP/currency/loot. CARE pill shared satiety1,000,000/day untouched; existing +55 is source-locked until new authorization, so do not change in this docs commit. Injury0/1/120, HP1 edge case, legitimate HP-ratio save migration retained.
- **Current monster boss coef** main has 2.50 HP/1.30 ATK/1.18 DEF, not older document ×4.00/×1.60/×1.35. Do not merge historical boss tables without numeric fixture comparisons.
- **Do NOT hard cap** raw foundation values, crit damage, lifesteal or raw source additive % unless a separate player-approved PvE balance contract requires it. An executable action can enforce physical timing >0 and a final probability is clipped to 0..100% as existing SOURCE. Reference build budgets are *testing target cohorts*, not hidden hard limitations on high-level builds.

## 7. Acceptance / gate and implementation order

1. **D7-C16 docs numerical proposal only** (this branch): quality probability authority, seven-value deterministic sampler, all 16 channel base/formula/caps and reference build budgets documented; no code.
2. After recovery released overlapping files, owner-specific CODE authorization for **versioned birth 6→7**. Preserve source odds, quality, old six point snapshots, deterministic migration and test seed, avoid reroll.
3. Separately authorize ×100 CombatCore+Monster+HP service/potion/item/shield/medical + old save HP ratio; no partial scaling.
4. Separately authorize PotentialRealm-only/ConstitutionBody-only and mental progress sources, complete CombatStatsV2 consumer matrix.
5. Godot 4.7.2 focused/Windows/Android/owner visual acceptance, 200k+ seeded birth distributions and scenario 1v1/3v3/6vBoss; only after these quantitative gates call *balance* PASS. No CI/FULL or merge from this docs-only decision.

**Design verdict:** one seven-attribute source with explicit distribution, not seven unrelated gacha tables; current ordinary base 65/25/8/1.8/0.2 retained; no new unavoidable third 30×10 progression track. Numeric initialization and all existing combat source semantics fully specified for a future CODE packet. Actual gameplay runtime remains V2 until authorized migration.