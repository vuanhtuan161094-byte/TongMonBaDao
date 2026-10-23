# X1 — R01–R03 ĐAN DƯỢC · CÔNG PHÁP · KỸ NĂNG · TU VI/LUYỆN THỂ · NGUỒN HỌC

**2026-10-23 | DESIGN PROPOSAL, DOCS ONLY** · Companion to `X1_R01_R03_EQUIPMENT_MONSTERS_MATERIALS_CATALOG_2026-10-23.md`.  
**Source** on `main=29b5fba4`, CARE PR#24 head `4d08984f`: `AlchemyRecipeRegistry`, `SpiritCropRegistry`, `ResourceRegistry`, `TechniqueSystem`, `CombatSkillSystem`, `DiscipleProgressionBalanceV2`, `DiscipleBodyGateContentV2`; canonical `TECHNIQUE_V2_SPEC`, `COMBAT_SKILLS_V2_SPEC`, `CULTIVATION_BREAKTHROUGH_V2_SPEC`, `BODY_CULTIVATION_V2_SPEC`. **No runtime state, gameplay, QA or approval implied by this document.**

## 0. Authority before content

- **LOCKED**: cultivation 30 realms×10 floors, body separately 30×10; core `G(r,f)` only used by **Realm+Body stat authority**, never cloned onto item template IDs. `DiscipleProgressionBalanceV2.REALM_TOTAL_XP`: R01 **10,000,000**, R02 **12,700,000**, R03 **16,200,000**. `FLOOR_WEIGHT_PER_MILLE[1]=700/10000`, so first floor cost (R01/R02/R03) = 700,000 / 889,000 / 1,134,000 Tu Vi respectively. Actual floor residual calculations use the canonical code.
- **LOCKED**: base natural Tu Vi **1,000 XP/simulation minute** before Tư Chất/modifiers; fixed-source pills **do not** get Tư Chất multiplier. Newer owner B3-XP-01: *future* fixed Tu Vi from each credited valid kill, personal once, NOT coded in PR25. Do not also award Tu Vi from `Tinh Nguyên` by default or revive older next-floor percentage reward design.
- **LOCKED**: shared pill satiety **1,000,000 / disciple / canonical simulation day**, `floor(tick/1440)`, across all pill types. No second use-count cap. Hồi Xuân +55 HP / 10 sat; Tụ Khí +10,000 Tu Vi /25 sat. Injury remains 120 simulation ticks, not a lifespan death.
- **LOCKED**: `TECHNIQUE_V2_SPEC`: Sect archive+unlimited learned library, **1 main+2 auxiliary ACTIVE**, five named mastery stages; technique rarity is NOT tied one-to-one to character realm. `COMBAT_SKILLS_V2_SPEC`: mature **1 normal+4 active+6 combat passives**, unlocked gradually over **Nhân**; families evolve by waves Nhân→Tiên→Thần, NOT every realm. Current P2 `TechniqueSystem.MAX_LEARNED_TECHNIQUES=3`, `MAX_TECHNIQUE_LEVEL=5` are old compatibility only.
- **LOCKED**: Tàng Kinh Các archive first complete manual ⇒ Sect transmission, individual learning still costs time + real Contribution/personal Stones where defined; no generic learning-failure RNG. Existing P2 gacha/fragment contract remains operational until a separate V2 migration; never treat new proposed manuals as live.
- **LOCKED**: R01 Phàm Nhân, R02 Luyện Khí, R03 Trúc Cơ are **all Nhân Giới**. Body ranks (Phàm Thân, Luyện Bì, Luyện Nhục) are **independent** and can be lower/higher than Tu Vi. Body gate material recipes in `DiscipleBodyGateContentV2` have `CONTENT_AVAILABLE=false` in inspected main (metadata only) and must not be called live.

## 1. Real pills vs new candidate pill families

R01 SOURCE:
- `AlchemyRecipeRegistry` at PR24 contains `hoi_xuan_dan`: **3 `thanh_linh_thao` →1 Hồi Xuân** in **6 simulation ticks**; CARE receipt uses 10 sat and restores 55 HP. On main only this recipe exists.
- `tu_khi_dan`: **2 `thanh_linh_thao`+1 `linh_coc` →1 Tụ Khí** in **6 ticks**, +10,000 Tu Vi and 25 sat; exists in CARE, not currently main.
- `SpiritCropRegistry` actual pilot crop rows: Thanh Linh Thảo 3 yield/12 ticks, Linh Cốc 5/10, Tử Vân Thảo 3/24. Those are base plot rows subject to actual worker/building/harvest/scheduler, NOT guaranteed daily global output.
- Current resource `market_value` pilot metadata: `thanh_linh_thao=6`, `linh_coc=4`, `yeu_dan=18`, `tu_van_thao=16`, `linh_tuy=14` (Spirit Stone/reference-unit prices from `ResourceRegistry`; **not guaranteed available shop sale/purchase proceeds**).

New pill rows below are **PROPOSED, NOT EXISTING**. Do not auto-transform old pills. A lower pill can remain usable at any realm if it has a valid user/stock, but with lower per-use effect/efficiency.

| R | Pill ID / display name | Proposed source recipe, 1 pill unless stated | Fixed effect (NOT multiplied by Potential/Tư Chất) | Satiety | Base forge/alchemy time | Unit/value label |
|---|---|---|---|---:|---:|---|
| R01 | `hoi_xuan_dan` Hồi Xuân (SOURCE CARE) | `thanh_linh_thao:3` | HP +55 | **10 LOCKED** | **6 ticks SOURCE** | SOURCE/PILOT/OWNER EFFECT |
| R01 | `tu_khi_dan` Tụ Khí (SOURCE CARE) | `thanh_linh_thao:2, linh_coc:1` | Tu Vi +10,000 | **25 LOCKED** | **6 ticks SOURCE** | SOURCE/PILOT/OWNER EFFECT |
| R02 | `x1_r02_duong_mach_dan` Dưỡng Mạch Đan | `thanh_linh_thao:3, yeu_dan:1` | HP +110 | **18 PROPOSED** | **8 ticks PROPOSED** | All new |
| R02 | `x1_r02_ngung_khi_dan` Ngưng Khí Đan | `thanh_linh_thao:3, linh_coc:1, yeu_dan:1` | Tu Vi +25,000 | **40 PROPOSED** | **8 ticks PROPOSED** | All new |
| R03 | `x1_r03_ngoc_tuy_dan` Ngọc Tủy Đan | `tu_van_thao:3, linh_tuy:1` | HP +190 | **26 PROPOSED** | **10 ticks PROPOSED** | All new |
| R03 | `x1_r03_truc_nguyen_dan` Trúc Nguyên Đan | `tu_van_thao:3, yeu_dan:1, linh_coc:2` | Tu Vi +50,000 | **60 PROPOSED** | **10 ticks PROPOSED** | All new |

**Content preconditions:** R02 normal source for `yeu_dan` must be truly repeatable or alternative Sect economy source must exist. R03 `linh_tuy` cannot be Boss-only (it already has an R01 source with guaranteed encounter wins but different owner than CARE); if player cannot access old area later, author a repeatable new early-region or market source *explicitly* rather than gifting essence. All six outputs must have real `ResourceRegistry` IDs **before** they are forgeable/usable; currently `x1_` rows have no registered output. Consumption effect and stock are one actual canonical transaction; satiety checked BEFORE stock debit/effect; same use-receipt cannot double-spend.

### Economy comparison with explicit units (this is STATIC ARITHMETIC, not a runtime/proven throughput claim)

`Opportunity proxy` = sum current pilot `ResourceRegistry.market_value` of ingredients, **not an authoritative market purchase/sale cost**. No labor, profession speed, auto-heal timing, health overfill or shortage penalty included. `Baseline same-rank HP` assumes **Tu Vi realm r/floor1 AND Body realm r/floor1 AND Potential 0**, not every real disciple.

| Item | Ingredient proxy Stones/pill | Effect | Usefulness at equal Realm+Body baseline | Proxy efficiency | Satiety return |
|---|---:|---|---:|---:|---:|
| R01 Hồi Xuân | 3×6 = **18** | HP55 | 55/190 = **28.95% max core HP** | **0.327 Stones/HP** | 5.50 HP/sat |
| R02 Dưỡng Mạch | 3×6+18 = **36** | HP110 | 110/313.5 = **35.09%** | **0.327 Stones/HP** | 6.11 HP/sat |
| R03 Ngọc Tủy | 3×16+14 = **62** | HP190 | 190/517.275 = **36.73%** | **0.326 Stones/HP** | 7.31 HP/sat |
| R01 Tụ Khí | 2×6+4 = **16** | Tu Vi10,000 | **1.43%** of R01 floor1 cost 700k | **1.60 Stones per 1,000 XP** | 400 XP/sat |
| R02 Ngưng Khí | 3×6+4+18 = **40** | Tu Vi25,000 | **2.81%** of R02 floor1 cost 889k | **1.60 Stones per 1,000 XP** | 625 XP/sat |
| R03 Trúc Nguyên | 3×16+18+2×4 = **74** | Tu Vi50,000 | **4.41%** of R03 floor1 cost 1,134k | **1.48 Stones per 1,000 XP** | 833.33 XP/sat |

**Why these numbers:** they avoid the earlier trap where a proposed higher-rank pill is strictly worse than R01 in reference materials per XP. They are **NOT balanced yet**: they may still dominate early natural cultivation or create excessive potion spam; Body/HP relative numbers change whenever cultivation track, Body track, Potential or actual gear differs. Need 24h/7d/30d simulation measured over real gathering/job/kill rates and satiety use; no global hard pill realm requirement unless specifically authored.

**Healing proposal alternatives to owner (NOT locked):** H1 conservative R02 +90, R03 +145 (near 29% equal-tier HP; less power/cost-effective than source R01); **H2 recommended +110/+190** (about 35–37% max core at rank); H3 aggressive +150/+260 (larger combat survivability risks, test normal/Boss attack cadence). Satiety values remain independent and need acceptance.

**Tu Vi proposal alternatives to owner:** V1 slow +15k/+25k for R02/03 (lower economic attractiveness given ingredient mix); **V2 recommended +25k/+50k**; V3 fast +35k/+80k (risk shortening progression across 10 floors, must benchmark). No auto-cultivation booster from unrelated quality or realm number.

## 2. Công Pháp: existing named definitions, proposed sources and V2 active/learned rules

**SOURCE P2** `TechniqueSystem.TECHNIQUES` includes:
- `duong_khi_quyet` (Dưỡng Khí Quyết), rarity P2 `common`, role `growth`, path `spell`, gacha weight38, fragment_required8, learn Contribution40, personal Stones15, `cultivation_per_level=0.05` in **legacy** per-level effect;
- `huyen_giap_cong` (Huyền Giáp Công), rarity `mysterious`, path `body`, `fragment_required=12`, Contribution75, personal Stones30 (legacy);
- `liet_chien_quyet` (Liệt Chiến Quyết), rarity `mysterious`, path `body`, `fragment_required=12`, Contribution80, personal Stones32 (legacy);
- `thanh_phong_kiem_quyet` (Thanh Phong Kiếm Quyết), rarity `earth`, path `sword`, `fragment_required=18`, Contribution145, personal Stones55 (legacy).
The old `MAX_LEARNED_TECHNIQUES=3`, 4-grade `common/mysterious/earth/heaven` and five numeric levels **must not be relabeled** as V2 five mastery milestones or unlimited learned library. The existing P2 gacha fragment IDs do not automatically become V2 Sect archived manuscripts.

**X1 proposed minimal transmission progression** (acquisition placement, not hard applicability):
| Stage | Candidate technique identity (REUSE EXISTING ID) | Acquisition PROPOSAL | Why | Compatibility / active |
|---|---|---|---|---|
| R01 | `duong_khi_quyet` | once-only starter Sect archive via real scripted recruitment/grant **if later authorized**, or 8 manual fragments from repeatable normal enemy at proposed 2% drop | very first basic cultivation path, no Boss necessity | archive first full manual; any legal disciple may learn for actual authored cost; 1 main+2 aux active |
| R02 | `huyen_giap_cong`, `liet_chien_quyet` | 12 fragments each via authored normal/elite source; elite adds 12% fragment chance, not full auto-learn | separate Body tank vs aggressive physical options | rarity not rigidly "must be Luyện Khí"; a Phàm Nhân can learn if actual prereqs permit |
| R03 | `thanh_phong_kiem_quyet` | authored elite/ruin reward, alternative 18-fragment repeatable ordinary source + Tàng Kinh transmission | optional sword progression, no required boss-only gate | low-grade Dưỡng Khí Quyết remains useful where source/skill valid |
| R01–03 | other player-owned techniques | retain current P2 legacy until migration with no wipe | no forced replacement every realm | V2 learned knowledge retained even if inactive |

**Mastery proposal for first V2 pilot:** `Sơ Học` on learning, `Nhập Môn` after documented valid use/cultivation, later `Tiểu Thành/Đại Thành/Viên Mãn` only after true training sinks. **Numeric thresholds NOT YET APPROVED**; no blanket +5% dmg per milestone. Effect of each candidate technique requires explicit V2 `source_id/channel/trigger`; P2 numeric `cultivation_per_level` is not yet a V2 balance approval. Do not generate new formula `technique_effect×1.65^r` or make technique grade equal to equipment rarity.

## 3. Kỹ năng chiến đấu: reuse genuine existing SKILL IDS, only new learning sources are proposed

**SOURCE code** `CombatSkillSystem.SKILLS` has exactly nine initial named skills; these values are P2 pilot/action definitions, **not a guarantee the new V2 skill registry/loadout can already teach them with new manuals**.

| Candidate stage of acquiring manual (PROPOSED, not locked unlock) | SOURCE skill ID | Display | SOURCE P2 path / core effect | SOURCE cooldown | Existing legacy `min_stage` (not V2 realm number) |
|---|---|---|---|---:|---:|
| R01 | `thanh_phong_tram` | Thanh Phong Trảm | sword / direct damage ratio1.35 | 2.8 sec | 0 |
| R01 | `chan_son_quyen` | Chấn Sơn Quyền | body / weaken ratio1.45 | 3.4 sec | 0 |
| R01 | `hoa_cau` | Hỏa Cầu | spell / burn ratio1.15 | 3.8 sec | 0 |
| R02 | `truy_phong_bo` | Truy Phong Bộ | sword / dash ratio0.75 | 5.0 sec | 4 |
| R02 | `kim_cuong_ho_the` | Kim Cương Hộ Thể | body / self guard | 8.0 sec | 3 |
| R02 | `han_suong_an` | Hàn Sương Ấn | spell / weaken ratio0.90 | 5.5 sec | 3 |
| R03 | `ngu_kiem_thuat` | Ngự Kiếm Thuật | sword / projectile damage ratio1.70 | 6.5 sec | 9 |
| R03 | `bat_dong_than` | Bất Động Thân | body / self guard | 14.0 sec | 9 |
| R03 | `liet_diem` | Liệt Diễm | spell / burn combo ratio1.45 | 7.0 sec | 9 |

**Important:** `min_stage=3/4/9` in old code is NOT `realm_index=3/4/9`; map it only after validating historic `CultivationSystem` semantics. Placing a manual as an available R02/R03 drop does NOT bypass actual learning/cooldown/prerequisite authority, and does NOT auto-equip 9 moves on any new disciple. Skills do not automatically come bundled with a Công Pháp; any synergy is authored/tagged. All nine are **Nhân generation** pilot action examples; no Tiên/Thần generation prematurely unlocked.

**Proposed manual acquisition:** normal skill family manual fragments (2% per eligible paid kill, with eligible real region/monster tags), elite 12%, boss one-time authored conditional archive odds; normal full manual only when authored. Each `skill_manual_id` would be a registered item with unique `source_id` and archive/learning consumer; **no such IDs are claimed live**. Avoid a 2% random drop making a mandatory skill the sole viable normal hunt strategy; provide one stable starter skill option for each sword/body/spell path from authorized Sect teaching.

## 4. Tu Vi, Luyện Thể, Body gates and cross-system status

| Track | SOURCE/LOCKED | X1 handoff/avoid fake |
|---|---|---|
| Tu Vi | natural 1,000/min baseline, Tư Chất scales only natural; direct fixed pills; 30×10 EXP curve and separate major breakthrough gates | B3 direct fixed kill XP design supersedes older "must absorb dropped Tinh Nguyên" policy but is **not yet in live CARE**; reward and skill mastery receipts must be distinguishable |
| Luyện Thể | +1,500 base Body EXP/min via valid Rèn Thân training source and Căn Cốt; stage/floor/gate separate from Tu Vi | fixed Body pills only if authored separately; no general monster kill automatically gives Body XP |
| Body gates | metadata in `DiscipleBodyGateContentV2`, `CONTENT_AVAILABLE=false` on main | needed material chain at relevant gate but cannot claim fully active R01→R02 gate. Require legal source for every mandatory material/receipt |
| Combat core | for same rank r1/r2/r3 both tracks, no other buff/Potential: core HP190/313.5/517.275, ATK23/37.95/62.6175, DEF19/31.35/51.7275 | item bonuses via actual `CombatStatsV2` source; do not scale by tooltip "Combat Power" or apply gear through Potential |
| Job/economy | one ACTIVE JOB per disciple; Forge/Alchemy/Work/Hunt exclusive; one Warehouse and clock | automatic priority cannot simultaneously assign crafter to Mine/Hunt; verify real stock (not preview reward) before crafting |
| World difficulty | actual same species scaled by authored monster realm/floor; no general hard Body-rank entry gate | R02/R03 proposed new species aren't real; each later requires Combat V2 fixtures at realistic HP/DEF/skill cooldown with build/corresponding stage |

## 5. First production-ready decision boundary (still design)

- Keep real R01 Hồi Xuân/Tụ Khí untouched.
- Approve or adjust two R02 and two R03 **candidate** pills only after true input production/cost and individual satiety budget inspection. **Never** rewrite the old R01 pills to be automatically upgraded by realm.
- Use existing `duong_khi_quyet`, `huyen_giap_cong`, `liet_chien_quyet`, `thanh_phong_kiem_quyet` as **candidate source identity references**, not newly invented techniques; preserve P2 migration.
- Use existing nine CombatSkillSystem action IDs with new **content source/acquisition placement proposal**, not a renamed/new combat ability engine. Source A clips/visual approvals separate.
- Only after `X1 ECONOMY/RECEIPT QA` and owner numeric/source options are approved may Codex be asked to code a small authorized packet; X1 itself is not code permission.
