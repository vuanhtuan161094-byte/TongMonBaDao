# TMB — HỢP ĐỒNG CHUYỂN COMBAT FINITE → WORLD CONTINUOUS KHÔNG MẤT SAVE, KHÔNG NHÂN THƯỞNG

**Ngày:** 2026-10-25; **Status:** PROPOSED DESIGN CONTRACT / NOT CODED / NOT OWNER LOCKED. Baseline CODE-CLEAN `5fbdbc6309c3f1386f0d8b619831e007c5a52824`. Future writer must seek separate CODE authorization, exact allowlist, test gates; không thay CombatStatsV2, Injury0/1 +120, One Active Job, Warehouse, canonical tick hoặc RNG hiện có. Liên kết caller inventory `docs/research/TMB_COMBAT_FINITE_RETIREMENT_EXHAUSTIVE_CALLER_INVENTORY_2026-10-25.md`.

## 1. Save authority — NHỮNG GÌ CODE THỰC SỰ CÓ
| Nhóm | Source / hành vi quan trọng |
|---|---|
| `SaveService` | `godot/src/simulation/save/save_service.gd`: `CURRENT_VERSION=3`, `LEGACY_CARE_VERSION=3`, `CARE_VERSION=4`. `save_to_path` ghi `.tmp` rồi verify; xoay `.bak` và publish; `load_from_path` dùng primary, fallback backup. V4 được kiểm tra bằng `b3_care_version` khi CARE present, sau đó normalize phiên bản để parse. JSON float64 có tag `__float64` giữ precision. Đây không phải “version=2” của main cũ. |
| Sect persisted | `sect_state.gd`: `v2_pve_enabled`, `v2_pve_selected_levels`, `v2_pve_reward_claims`, `v2_pve_active_runs`, `v2_pve_settlement_receipts`, `v2_body_material_progress`; độc lập `b3_hunt` version 1, chứa world/slot/generation/receipt/battle. |
| Disciple persisted | `disciple_state.gd`: `active_pve_encounter_id`, `region_id`, `current_action`, `pending_loot`, HP, Injury, recovery tick, nghề/work reservation, equipment/skills/cultivation progress. |
| V2 finite snapshot | `MapBattleSnapshotV2` wrapper+payload `godot_variant_b64`: writer v1 finite, historical reader v2, v3 PH0 continuous. Typed RNG/HP/positions/casts/events. Finite 90s bound is validation of historical state, NOT World physics. |
| Load normalization | `SimulationState.from_dict`: reconstruct saved disciples/sect; calls `HuntingPveRunV2.reconcile_loaded_v2_pve` **before offline ticks**, then `B3HuntWorld.validate`. Malformed/conflicting PvE rejects entire load. Must not turn rejection into erased state. |
| B3 World | `B3HuntWorld`: one monster slot/generation, single actor life HP0 -> pending event; `PENDING/COMMITTED` receipt and `paid_generation`; Warehouse credit + saved barrier before kill ACK. Respawn belongs to generation; no unearned timer loot. |
| GP-02C1 finite | `HuntingPveRunV2._settle_terminal`: after terminal battle, preflight HP, injury1 if down, return to sect, `injury_recover_at_tick=tick+120`, terminal receipt. Won terminal run persists until `claim()`; defeated run can be removed; `claim_reward` marks `v2_pve_reward_claims`. |

**Warning:** `CombatSystem` scheduler branch (45s or 20 rounds) stores loot in `DiscipleState.pending_loot` and uses action `LOOT`; **khác** finite V2 `v2_pve_reward_claims` and **khác** B3 `paid_generation`. Migration phải xử lý ba authority liên quan loot, không gom/đếm x2.

## 2. QUY TẮC CẮT CHUYỂN
1. **New sessions cutover**: Sau khi World continuous replacement có thật và QA PASS, mọi `HUNT/COMBAT` và lựa chọn map dùng World admission. New `HuntingPveRunV2.begin` bị cấm **chỉ cho brand-new sessions**, không ngăn migrate/resume valid old saves.
2. **Old sessions quarantine/adaptor**: Các `v2_pve_active_runs` hợp lệ tiếp tục được đọc bằng **finite reader isolated** cho đến trạng thái terminal; KHÔNG chuyển một battle đang sống dở thành một quái R11 mới bằng cách tự roll seed/HP/gear. Có thể giữ internal bounded adapter, dẫu public “finite gameplay” đã bị retire.
3. **Old terminal entitlements**: Đã thắng chưa nhận -> vẫn claimable, không auto-credit trên load. Đã claim -> giữ tombstone, không award lại. Thua/rút -> receipt Injury/trả về tông môn, không loot.
4. **Legacy scheduler queued loot**: Nếu `current_action=LOOT` với `pending_loot` persisted, phải có transaction settlement exactly once trước khi chuyển sang World. Tránh reset `pending_loot` rồi mất đồ, hoặc gửi vào Warehouse và sau đó chạy lại `disciple.add_item`.
5. **ID namespaces**: `legacy/scheduler/<save_namespace>/<disciple>/<action_epoch>`, `legacy/v2/<encounter_id>`, `world/<world_instance>/<camp>/<slot>/<life_generation>`, `node/<world_instance>/<zone>/<slot>/<harvest_generation>` có prefix khác nhau. IDs chỉ là **future schema proposal**, không ngụ ý có sẵn `action_epoch` trong save cũ. Nếu không đủ origin để dựng receipt scheduler vô trùng, giữ actor ở compat LOOT cho đến khi settle qua old owner, đừng tự chế epoch.
6. **No global loot reroll**: Những claim đã trả và NO_DROP không reroll khi restore; nếu result cần freeze, dùng original seed/state và entitlement id, không dùng local clock hoặc FPS làm RNG mới.
7. **No hidden time penalty/cap**: World continuous không timeout 45/90, nhưng vẫn có danger/AI retreat, skill cooldown và budgets/backpressure. Không xóa `MAX_PENDING_KILLS`, `MAX_CONTINUOUS_BATCH_STEPS`, `MAX_SAFE_STACK`, nếu là bảo vệ hiệu năng/an toàn.

## 3. Tình huống save FINITE V2 — CONTRACT MATRIX
| S | On-disk input ở checkpoint gốc | Quy trình migration | Expected outcome |
|---|---|---|---|
| S00 | không có `v2_pve_active_runs`, không có `b3_hunt` | parse bình thường, idempotent `legacy=none` | World được tạo CHỈ bởi command hợp lệ sau load |
| S01 | active finite snapshot v1/v2, health và cast/RNG đang diễn ra | Validate typed snapshot, monster provenance, reservations; mark `LEGACY_DRAINING`, giữ combat checkpoint trên disk; cho resume theo old outcome math hoặc manual retreat theo policy có đồng ý | HP, skills, RNG, combat result không tự đổi; **không free win/loot** |
| S02 | active finite snapshot thiếu `active_pve_encounter_id` (old save) | Dùng `reconcile_loaded_v2_pve` tạo reservations sau **two-phase preflight** | Một reservation/actor, không can thiệp work job; offline advances chỉ sau reconcile |
| S03 | terminal `win` đã `_settle_terminal` nhưng **chưa `claim`** | Giữ immutable result & `v2_pve_settlement_receipts`, offer `legacy_claim` exactly once, bằng original `preview_reward` và F3 guaranteed win counter | Warehouse credited one, claim tombstone set, active run removed; **không tự pay khi load** |
| S04 | terminal `win`, claim đã committed | preserve `v2_pve_reward_claims[encounter_id]`; nếu stale run vẫn present -> fail-closed/quarantine & reconcile only with trusted receipt | duplicate click/load = zero extra |
| S05 | terminal `defeat` | settle HP1 + Injury1 (+120 tick) via canonical contract nếu chưa có receipt; existing committed receipt wins | no loot; reservation clears only after safe settlement |
| S06 | terminal `timeout_retreat` historical | preserve old outcome, actual HP ratio, Injury0/1 as already settled | historical result accepted, **không có timeout mới cho World** |
| S07 | conflicting active run ID, duplicate disciple across runs, malformed base64/float/partial legacy receipt | reject preflight, no mutation; backup or user-visible repair path | absolutely no silent data loss |
| S08 | active B3 world v3 snapshot, pending kill, unacked event | B3 owner restores, original `PENDING/COMMITTED`+paid_generation and SAVE barrier | kill settled once, ACK only after durable success |
| S09 | B3 death committed + reload 100 lần | monotonic paid watermark, same world id and gen; all stored receipts consistent | exactly one stock delta for one life |
| S10 | legacy scheduler `LOOT` + `pending_loot` | preserve exact inventory sink and original action until existing one-step settle; or design new persistent `legacy_loot_claim` with documented source lineage first | 0 missing, 0 duplicate items |
| S11 | scheduler mid `COMBAT` action persisted without per-hit state | old model is synchronous per scheduler minute; next tick must not be re-executed twice for same committed action | compare before/after saved tick and RNG, no two rewards from one action |
| S12 | old finite battle and B3 world contend one disciple | honor One Active Job; reject conflicting migration, don't use forced auto-heal/release | fail closed, old save preserved |
| S13 | V3 save without CARE vs CARE V4 with `b3_care_version` | honor current CARE capability guard; retain `__float64` byte fidelity | never downgrade capable save to older reader accidentally |
| S14 | main primary corrupted, good `.bak` | existing fallback; trial migration in private state and stage writes only if full validation | backup remains last known good |
| S15 | warehouse overflow or disk write failure after settlement preparation | do not issue credit or ACK until durable preflight/commit; preserve pending retry | no lost or double materials |

**Exact distinction**: `_settle_terminal` is **not** `claim_reward`. GP-02C1 test includes genuine terminal winning encounter whose claim was delayed through Save/Load. Deleting its `v2_pve_active_runs` immediately would irreversibly lose legitimate owner entitlement.

## 4. LIVE LONG-TERM SOURCE GATE — LỤC DUY/LEGACY MATERIALS
- `HuntingMapV2.early_body_sources_ready` is called by `disciple_body_gate_transaction_v2.gd:17`; must preserve requirements for realms R1–R6 and catalog:
  `thanh_linh_thao`, `tinh_lang_bi`, `tu_van_thao`, `linh_tuy`.
- `v2_body_material_progress["linh_tuy_thanh_truc_wins"]` tracks a **four wins** guarantee, not a time-based reward. If encounter wins no longer exist, new guarantee must be tied to **a player-earned eligible World progress source** with persisted receipt counter and one time exactly-once semantics. Design must prove 4 genuine eligible actions earn same Linh Tủy as locked legacy policy (unless separately authorized adjustment).
- Do not reset counter on cutover; carry historical 0..3 progress into compatible deterministic new counter under one migration transaction, with distinct `source_kind` to avoid two sources advancing same counter.
- `HuntingMapV2.REGION_CONTENT` currently used by B3PilotContent for original zone scales and by body source validator. A new `RegionSourceCatalog` may own source metadata; no free retroactive materials.
- `technique_system.roll_farm_loot`, `equipment_system.forge_loot_for_victory`, profession XP, personal Spirit Stones, Tu Vi, social/memory callbacks, drops and retreat behavior must be explicitly rehomed. No silent disappearance of these production dependencies.
- R11 proposed Tiên Thiết/Vân Mộc/Vân Giác Lộc Bì remain separate future content; **do not convert lower materials into R11**.

## 5. ALGORITHM SKETCH (DESIGN-ONLY, NOT REAL CODE)
```text
load(raw_bytes):
  verify envelope save_version (3 or CARE4) and float64 tags
  parse to private state; preserve raw backup untouched
  validate CANONICAL Warehouse + actors + world + legacy PvE namespaces
  perform LEGACY two-phase reservation reconciliation before offline ticks
  classify every legacy claim/run/pending_loot into S00..S15
  if corrupt/conflicting: return FAIL_CLOSED with path/field, zero mutation
  if valid: enable migration-status markers only in private state
  do not create new World life or award anything on load

legacy_finite_claim(encounter_id):
  preflight: original terminal WIN, valid immutable receipt, not claimed
  calculate original exact registered items incl. four-win guarantee
  preflight Warehouse int + reserve/lock contract
  commit Warehouse stock + old claim tombstone + progress counter + cleanup
  save via staged verified barrier
  only then report success; on I/O failure retain recoverable, not re-awarded state

world_kill(world, slot, generation):
  one authoritative HP0, one kill event, immutable entitlement
  preflight resources+Warehouse bounds; record NO_DROP as an eligible result
  stock + receipt + life settlement in one canonical transaction
  durable save before kill journal ACK and respawn entitlement unlock
  duplicate event returns already-settled, never another credit
```
**Not proven**: legacy `HuntingMapV2.claim_reward` currently mutates in-memory Warehouse and claims but does not itself call `SaveService.save_to_path`; migration needs a **new owner wrapper** for durable barrier, must not assert the old class already has a disk transaction. Any crash after memory mutation but before durable save needs deterministic restore from older canonical disk state (with unclaimed encounter intact), not blind replay from mutated volatile object.

## 6. SAVE VERSIONING PLAN — OWNER CHOICE REQUIRED
Preferred: first CODE packet leaves save V3/CARE4 and old readers intact; records any migration state in already-valid `SectState` fields only if schema already supports it. If new persisted `legacy_migration_receipts` or `world_v2` is introduced, **authorize a new save version and reader** with explicit CARE capability backward/forward guards; don't simply set CURRENT_VERSION=5 while forgetting CARE4 detection or `_migrate` acceptance.
- New app reads V0–V4 and proposed Vnext, always validates full payload, float fidelity, version tags and previously settled reward receipts.
- Older app must **fail closed** on future saves (no silent drop of unknown World receipt state). On rollback, use pre-migration backup on separate path, never downgrade a Vnext save in place.
- Migration commit keyed by `migration_id = sha256(original_save_digest, migration_version)` is **proposal**, not a runtime feature. A replay with same ID must be idempotent; no “fresh” ID on repeated load.

## 7. REQUIRED TESTS AND OUTCOMES
| Fixture | Actual legal-state input | Requirement |
|---|---|---|
| M01–M03 | V1 finite active with valid owner, v2 historical snapshot, missing reservation | exact HP/RNG/casts/roles resume; no duplicate reservation |
| M04 | terminal win, delayed claim after 2 reloads | exactly one old item grant, correct four-win Linh Tủy counter |
| M05 | terminal defeat/timeout | Injury120 and HP/return preserved, zero loot |
| M06 | claimed win, duplicate 100 clicks/reloads | identical Warehouse inventory and entitlement |
| M07 | pending `LOOT` scheduler with materials and equipment loot | original personal inventory delta one; no bypass of source |
| M08 | partial/corrupt old snapshot and B3 collision | fail-closed; unchanged primary/backup |
| M09 | B3 World 120s and >3600s same ID, 3 genuine kills with generations | exactly-once receipt, no 45/90 timeout |
| M10 | kill World then accidental legacy `claim_reward` | zero additional credit |
| M11 | 4 eligible future World earn events with 3 historical progress | migrated guarantee specified and paid once, not 7 rewards |
| M12 | worker/forestry/hunter One Active Job, 30/100/300 roster | no dual activity nor fake offscreen entitlement |
| M13 | save interruption before/after write, backup rollback, reapply migration 100x | exactly-once stock and migration receipts |
| M14 | old finite V1 wrapper, v2 historical wrapper, v3 PH0, CARE v4 | read appropriate schema, reject mislabeled or forged mode |
| M15 | no material from legacy encounter until real replacement source working | fails softlock gate; block legacy public cutover |

**STRICT QA:** official Godot 4.7.2 focused + cumulative; Windows non-privileged build with real saves on E: preferred, Android physical touch/perf later; no unknown runner logs = PASS. Historical 28/28 PR31 focused is not valid evidence for future migration code.

## 8. DECISION — KHÔNG CƯỠNG BỨC XÓA NẾU SAVE CHƯA DRAIN
**Preferred POLICY P1**: disable new finite sessions when World parity is proven, but keep a sealed compatibility reader/claim handler for old saves. This satisfies “bỏ gameplay lỗi thời” without forfeiting saved rewards. Complete removal of all bytes of `HuntingPveRunV2` and finite snapshot decoding requires either (a) proof all supported saves drained/claims archived plus old snapshot loader fixture, or (b) explicit owner decision to drop some old-save compatibility — not currently authorized. **Do not offer forced surrender of active players as the default migration.**

**Verdict**: source-backed migration specification ready for review; migration neither implemented nor tested; preserves Combat V2, Injury120, Warehouse exactly once in the proposed flow.
