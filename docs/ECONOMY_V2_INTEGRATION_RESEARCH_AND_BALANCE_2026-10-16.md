# Economy V2 integration: evidence, contract, balance and resource ledger (2026-10-16)

Status: **integration pilot on draft branch**. Baseline is draft PR #8 at `b424d9d`. This document records code paths actually present on the integration branch and gaps that remain open. It does not certify Android, visual acceptance, or the whole Disciple V2 lifecycle.

## 1. Reference comparison

| Reference mechanism | Evidence level and source | Gameplay benefit | Current Godot authority | Decision |
|---|---|---|---|---|
| Building manager selection/replacement | **Verified client request/preview only**: Source Knowledge [PROFESSION_PRODUCTION](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/main/docs/PROFESSION_PRODUCTION.md) D12/H08; `zongmencontrol` `reqChangeBuildingManager` / `recv_3_44`; manager UI sends replacement request | Clear one-operator assignment | `BuildingSystem.active_worker_ids`, `WorkforceSystem.assign_worksite` | Apply one worker per Mine/Forest/Field. Do not infer server reward formula. |
| Profession level and building effect preview | **Verified Lua/config client**: `discipleproskillconfig.buildplant_effects`, `zongmenmodel.getDiscipleJobLevel`; Source Knowledge [deep dive](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/main/analysis/SystemResearch/HOME_BUILDING_DEEP_DIVE.md) H11 | Visible specialist advantage | `ProfessionModifierSystem` speed/EXP/rare channels | Apply separated channels; no copied numerical server formula. |
| Final reward timing, inventory and luck | **Unknown server** in Source Knowledge H12. [TapTap production discussion](https://www.taptap.cn/moment/587655210483056999) is a community guide, not server code | Batch completion and legible byproducts | `ProductionPlanRegistry`, `BuildingSystem`, `WarehouseSystem` | Own design: saved job snapshots, Warehouse settlement, rare item not multiplied by common yield. |
| Town Hall controls building expansion | [Official Evil Hunter building guide](https://evilhunter.zendesk.com/hc/en-us/articles/360039886271-Building-Information) | Legible expansion gates | P3.7 Building Tree design; no canonical Hall level/land-placement runtime yet | Adopt only after a real Hall/land authority exists; **not implemented** by adding fake capacity labels. |
| Materials → storage → crafting → character/service | [Official Evil Hunter building guide](https://evilhunter.zendesk.com/hc/en-us/articles/360039886271-Building-Information), [equipment guide](https://evilhunter.zendesk.com/hc/en-us/articles/360039886511-Equipment-Production-and-Sale) | Resource sinks with real inventory transfer | Warehouse, EquipmentSystem, Alchemy, Needs, Economy | Apply to existing recipes/stock. Do not copy hunter classes, reincarnation or PvE rules. |
| Managed market inventory | [Official Evil Hunter building guide](https://evilhunter.zendesk.com/hc/en-us/articles/360039886271-Building-Information) | Prevent infinite currency sales | `EconomySystem` merchant stock, receipt and daily counters | Apply finite Stone purse and bulk lots, preserving player Warehouse reserve. |

Source Knowledge is extracted client/config material. A client request proves that the client sends an action; it does not reveal the server settlement formula. The ×10,000 curve, stock target and merchant budget are **Tông Môn Bá Đạo pilot decisions**.

## 2. Pilot production contract

One scheduler tick is one minute. `ProductionPlanRegistry` owns base cycle, output ID, base amount, building unlock and common-yield curve. The ordinary batch multiplier interpolates geometrically between these targets:

| Lv | 1 | 10 | 20 | 30 | 40 | 50 | 60 | 75 | 90 | 100 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Common yield × | 1 | 2 | 5 | 10 | 30 | 100 | 300 | 1,000 | 3,000 | 10,000 |

Facility speed remains `1 + 0.005 × (Lv − 1)`; profession speed is independent and applies to duration. Field yield uses the common curve once; its cycle-time milestones and profession EXP remain separate. Huyền Thiết (10 / 120 ticks, Mine Lv30) is discrete tier-2 output and never receives ×10,000. Tầm Mạch Bàn has a deterministic 2% base chance on a Thanh Thiết batch, modified by the existing Cơ Duyên rare channel, one item on success. It is a recovered vein instrument, not a scaled commodity.

At Lv100 one Mine yields 100,000,000 Thanh Thiết per successful batch; one Forest yields 80,000,000 Linh Mộc. Ignoring profession speed, the Mine's 60-minute base duration at ×1.495 facility speed is about 41 ticks, or about 146 million ore per real hour while unconstrained. Thirty such Mines could theoretically deliver about 4.39 billion ore per hour **before** stock pauses. Actual completed output is bounded by input/worker availability, job completion and the shared stock target. Each producer refuses a new common batch when the global Warehouse reaches ten of its current-level batches. The Field chooses only crops below their dynamic target; a finished in-flight batch may cross the target once, then planting pauses. Warehouse's `MAX_SAFE_STACK` is a numeric overflow bound, not a normal capacity mechanic.

The market pilot allows 200 units per sale, 1,000 units per day, and a **2,000 Linh Thạch/day merchant purse**. Selling 250 Thanh Thiết at value 8 spends the purse; producing millions more does not create more daily Stones. Old saves retain their serialized policies; the new purse defaults to 2,000 if absent. The player Warehouse reserve and idempotent receipts remain authoritative. This balance is provisional: aggregate upgrade Stone cost and late-game consumption need a multi-instance simulation once Hall and land authorities exist.

## 3. Resource matrix (runtime truth, not wish list)

Legend: **LIVE** means both source and useful consumer found; **PARTIAL** means a source or consumer is only design/paused content; **MISSING** means no verified runtime source. Tiers are Tu Vi/Luyện Thể indexes from `ResourceRegistry`; 0 means no requirement. Exact recipe quantities are in their canonical registries, rather than copied here.

| ID | Family | Tier TV/LT | Source and rate | Consumer / input | Status |
|---|---|---:|---|---|---|
| `linh_moc` | wood | 1/0 | Forest, 8,000/60m at Lv1 | Building upgrades, Forge, market | LIVE |
| `thanh_thiet` | mineral | 2/0 | Mine, 10,000/60m at Lv1 | Building upgrades, Forge, market | LIVE |
| `huyen_thiet` | mineral | 3/0 | Mine Lv30, 10/120m; existing PvE rare | High-level upgrades, technique, Forge | LIVE |
| `tinh_lang_bi` | beast | 2/1 | Existing PvE | Forge recipe | LIVE |
| `yeu_dan` | core | 2/0 | Existing PvE | Technique upgrades | LIVE |
| `linh_tuy` | essence | 2/4 | Existing PvE | Technique, Body gate B | LIVE/PARTIAL gate |
| `tam_mach_ban` | component | 2/0 | Thanh Thiết Mine discrete chance | Mine Lv10/20 | LIVE |
| `thanh_linh_thao` | herb | 2/1 | Field, 2,000/90m/plot at Lv1 | Hồi Xuân Đan 500/recipe, market | LIVE |
| `hoi_xuan_dan` | pill | 2/0 | Alchemy timed recipe | Healing service | LIVE |
| `linh_coc` | crop | 2/0 | Field, 2,500/60m/plot at Lv1 | Needs 2/disciple/30 ticks, market | LIVE |
| `tu_van_thao` | herb | 3/4 | Field Lv30, 1,000/180m/plot; PvE | Body gate B content | PARTIAL: gate runtime |
| `linh_tuyen_chi_tam_manh` | fragment | 2/0 | Field discrete chance | 100 fragments → one heart | LIVE |
| `linh_tuyen_chi_tam` | component | 3/0 | Fragment conversion | Field milestones | LIVE |
| `huyet_linh_sam`, `huyet_thu_tinh_huyet` | gate C | 0/7 | No runtime source found | Body gate C content | MISSING |
| `kim_cot_thao`, `linh_thu_cot_ngoc` | gate D | 0/11 | No runtime source found | Body gate D content | MISSING |
| `tien_tuy_lien`, `tien_thu_chan_cot` | gate E | 0/15 | No runtime source found | Body gate E content | MISSING |
| `bat_hoai_tuy_dich`, `dai_la_kim_cot` | gate F | 0/18 | No runtime source found | Body gate F content | MISSING |
| `than_mach_tinh`, `than_thu_cot` | gate G | 0/21 | No runtime source found | Body gate G content | MISSING |
| `hon_don_tuy_hoa`, `bat_diet_than_cot` | gate H | 0/26 | No runtime source found | Body gate H content | MISSING |
| `an_nhan_gioi`, `an_tien_gioi`, `an_than_gioi` | seals | 0/10, 0/20, 0/29 | No runtime source found | Body gate seal content | MISSING |

The final 15 IDs remain in paused Disciple V2 gate content. This integration does **not** mint them or imply those gates can be completed. No new high-tier wood ID is added until it has a real construction/Forge consumer.

## 4. Six-stat source → formula → consumer → evidence

| Stat | Canonical channel | Runtime consumer / test status |
|---|---|---|
| Tư Chất | `1 + 0.0025 × points` cultivation gain | `CharacterModifierSystem` → cultivation; existing foundation/progression gates |
| Căn Cốt | `1 + 0.0020 × points` body gain | `CharacterModifierSystem` → body training; no ore bonus |
| Thông Tuệ | `1 + 0.0015 × points` learning/EXP | `CharacterModifierSystem` → profession EXP; profession level separately changes speed |
| Cơ Duyên | rare event factor/valid lucky roll | `ProfessionModifierSystem` → Field lucky harvest, Mine discrete byproduct; no routine quantity factor |
| Mị Lực | guidance quality/social score | `RecruitmentSystem` Dẫn Tiên; no global production factor |
| Tiềm Lực | `1 + 0.0005 × points` is defined in `FoundationSystem`; combat core also has a 0.0005 factor | **Growth consumer missing**: no call to `potential_growth_factor` or `add_permanent_points` from normal progression. Do not claim long-term attribute growth until a real progression event owns it. |

## 5. Open integration gates

- No canonical Hall level, 192×192/48×48/16×16 land placement, or construction timer authority exists in the present runtime. Consequently expansion to 30/30/40 instances is not implemented here; `BuildingSystem.create_building` alone is not a paid, placed construction flow.
- Advanced Body gate resources/seals above B have no verified runtime faucet. The locked 30×10 realm ladder remains intact; the absent route must be authored in its own content packet.
- Current GUI controls become readable/unclipped in the 1280×720 live scene. Worker search and profession-speed ranking now use backend data and render at most 50 rows; all-instance production management and one-step worker replacement remain open.
- The authentic V2 disciple profile now displays six profession levels/EXP from `DisciplePresentationSnapshotV2`; its roster supports name/ID search and renders at most 50 entries. Its full equipment consumer remains separately paused.
- Windows Godot 4.7.2 headless tests at `927a5f3` passed the authentic V2 profile and Economy-A landscape UI gates. A one-tick authentic-V2 scheduler probe at `df97f58` measured 139.5 ms (100), 761.0 ms (500), 1,633.1 ms (1,000), and 3,160.6 ms (3,000) in this local checkout. Those are measurements, not an FPS or sustained-load PASS. Manual visual acceptance and Android touch remain untested. The cumulative P3.7C1 FULL gate then passed with process exit 0 at code/test SHA `453df9aa0bc39f31f33cf65fc4aedcf688e7bf74` on official local Windows Godot 4.7.2. This does not certify Android or manual visual acceptance.
