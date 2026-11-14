# ECO-BAL-01 — Kết quả kiểm toán kinh tế và mô phỏng

## Trạng thái / provenance

- PR #72 branch: `integration/pve-p0-playable-ui-20261103`.
- Remote HEAD đã xác minh: `a641ee5df691fbc45d062afcfe721ccc63f2145d`.
- QA snapshot: reconstructed content snapshot `16e57fefd1d7122ee335ab2c2cbdabb90c758316`; sandbox không có native `.git`, nên đây **không phải native exact-SHA checkout**.
- 32/32 economy/save/PvE source/test Git blob SHA khớp tree của HEAD hiện tại. Điều này xác nhận các file liên quan không đổi từ snapshot đến HEAD, nhưng không biến import toàn project thành native exact-SHA QA.
- Godot: `4.7.2.stable.official.ed1daf0bf`; console SHA-256 `C8F0A6BC45A19B33541501E57F6F7CD972AB18453743266339D495CBBE846643`; GUI SHA-256 `AB1824F85BFD8E0E4128182C000C4003A3E042245B2967848D089B2A04B22424`.
- Save owner không bị đụng. Godot profile được redirect sang profile QA. Ma trận read-only không giao dịch, không đổi Warehouse, không ghi save. Không sửa code gameplay hoặc economy.

## QA thực hiện

| Nhóm | Kết quả | Ghi chú |
|---|---|---|
| Godot strict import | PASS, exit 0 | Không parse/import errors; Windows báo không đọc được root certificate store nhưng không fatal |
| Economy focused | 14/14 PASS, exit 0 từng bài | Bao gồm Origin Vein, market, seed/wage, R1 taxes, funding/capacity, bulk, 30-day analytical model, Save/replay |
| PvE receipt tests | 2/2 PASS, exit 0 | P0 test dùng engine test API để kích hoạt HP0; R12 test bật flag nội bộ fixture |
| Read-only authority matrix | 47 checks, 54 rows PASS | 32 tax previews; 12 market cases; 3 policy gates; 7 theoretical building curves; không transaction/save |
| GUI vật lý | PENDING | Không có owner desktop interaction trong sandbox |
| CI | UNKNOWN | GitHub check-runs API trả 0 check runs, không phải gameplay failure |

Các marker PvE đã được đọc lại từ raw log để sửa classifier cũ vốn bỏ sót PASS; không bỏ assertion và không chạy lại suite chỉ để sửa nhãn CSV.

## Source of truth

| Mode | Trạng thái |
|---|---|
| Economy-A, Origin Vein, production / market / Warehouse / receipts | LIVE theo code hiện tại |
| Bulk production | `OPT_IN`, chỉ ảnh hưởng job mới; job đang chạy giữ snapshot |
| SX-V55 R12 LT2/W2/T2 | `DESIGN_HOLD`, cấu hình player bị từ chối |
| PvE R12 currency reward | `DESIGN_HOLD`; test pilot chỉ bật flag QA nội bộ |
| 111 medicine identity rows chưa có recipe definition | Nội dung chưa có, không phải công thức craft được |

## Ledger 1/7/30 ngày

Đây là source-based upper model trong `sx_v55_eco_faucet_sink_30d_test.gd`, **không phải 30 ngày runtime**: sáu worker giả định, 360 active sim-min/worker/ngày, hai Mine, hai Forest, một grain và một herb; 34 jobs/day. Buyer demand không được đảm bảo.

| Ngày | Ore earned | Wood earned | Ore sale cap | Ore remainder max | Treasury upper | Hypothetical W2 gap |
|---:|---:|---:|---:|---:|---:|---:|
| 1 | 120,000 | 96,000 | 20 | 119,980 | 558 LT | 67,874 LT |
| 7 | 840,000 | 672,000 | 140 | 839,860 | 906 LT | 475,118 LT |
| 30 | 3,600,000 | 2,880,000 | 600 | 3,599,400 | 2,240 LT | 2,036,220 LT |

Herb/grain, seed/payroll, R12 sensitivity and roster assumptions are in `source_scenario_outputs.csv` and `logs/`. The treasury figures use current modeled flows, not guaranteed market sales. W2 gap is a design-only sensitivity, not a live debt.

Economy-A cashflow in `eco03`: New Game 500 LT, roster6; no NPC/T2; one Origin Vein gross1000/day, seed34/day, production wages68/day and Origin wage2/day gives modeled treasury 1,396 / 6,772 / 27,380 LT at 1/7/30 days. The roster30 projection is explicitly `paid_slots_proven=false` and is not proof 30 workers can be funded.

## Flow and rules

- Origin Vein is the early liquidity source: an eligible real job consumes 60 sim ticks, grants 1,000 LT gross, and is limited to once per sect/day. Funded Economy-A wage2 LT transfers to personal wallet; it is not extra currency.
- Economy-A wages are 2 LT per delivered batch when treasury plus reserve permits. When underfunded, unpaid amount is receipt-backed arrears. W2 is `max(0, floor - gross)`, so it tops up to the floor rather than adding the full floor. Jobs of 60/90/180 minutes gross 60k/90k/180k at R1 against a 2k floor, so top-up is zero.
- T2 tax moves money to the Sect treasury; it does not create money across combined Sect + personal wallets. 0/30/70/100% tax was a read-only preview, not player policy.
- NPC market allows only authored resources, order max5. Current prices: Linh Mộc2, Thanh Thiết8, Thanh Linh Thảo6, Linh Cốc4, Huyền Thiết34 LT/unit. Sale consumes Warehouse stock. Cap is 20/day under roster30 and 240/day at roster30; buy and sell caps are separate. This is capacity, not guaranteed buyer demand.
- With NPC policy disabled, actual buy/sell remaining is zero even where the raw helper reports a minimum cap value (1 or 240); transaction guards and UI close it. This is not a reproduced transaction bug.
- Bulk plans are opt-in for new jobs: ore10,000/60m, wood8,000/60m, Linh Cốc2,500/60m, Thanh Linh Thảo2,000/90m, Tử Vân Thảo1,000/180m. Selected common input costs scale ×1,000. This contributes to a real output-vs-market sink mismatch if enabled broadly.
- Level-1 site worker slots: Mine2, Forest2, Field4. A roster of30 is not 30 funded workers at a site. Hall authorization caps non-Hall buildings at `min(100,max(10,Hall_level×2+8))`; Hall46 allows100 under that cap.
- Current base upgrade cost formula summed lv1→100 is in `building_lv1_100_cost_curve.csv`; totals are theoretical, not affordability/reachability proof. Mine needs 6 Tầm Mạch Bàn; Linh Điền needs29 Linh Tuyền Chi Tâm across milestone gates. Dẫn Tiên Đài hard-gates after lv20 pending sect progression authority. Rèn Thân upgrade returns `body_training_upgrade_content_pending`.
- Market-only heart path: 100 fragments/heart; at20 fragments/day and4 LT/fragment, 29 hearts need at least145 simulated days and11,600 LT. Field rare harvest also exists, but ETA is unknown without verified plot count/rare factor.
- Medicine catalogue has119 identity IDs, but only8 r1/r2 recipe definitions; the other111 have no `recipe_definition`. Item IDs/qualities do not prove a craftable recipe. No r3+ material sourcing was verified.
- Auto-pill source threshold is HP≤80%, combat cooldown5s; B3 satiety cap1,000,000/day with sequence receipts. Full natural combat spend/hour remains unmeasured.
- PvE P0 reward test logs10 HP0 events and exact-once XP/material receipts plus cold reload; damage was forced by test API. PvE R12 Save/reward test uses an internal QA flag; player activation remains held. Neither establishes natural kill rate or PvE net economy/hour.

## Findings

- **No confirmed economy or duplicate-credit defect** reproduced in this focused scope.
- `ECO-F02` output versus market capacity, `F03` R12 inflation sensitivity, `F04` cash-flow dependence and `F06` rare/gated upgrade reachability are **BALANCE_RISK**; no values changed.
- `ECO-F05` tax/wage presentation and `F08` separate buy/sell cap meaning are **DESIGN_DECISION**.
- `ECO-F07` recipe coverage, `F09` natural combat economics, `F11` concurrent funded staffing and `F12` native/physical QA are **INSUFFICIENT_EVIDENCE**.
- Detailed severity, repro, source symbol and unapproved numerical sensitivity options are in `findings.csv`; source→sink trace is `source_sink_map.csv`.

## Limits / exactness

No long-duration live 1/7/30-day run was performed; those day projections are explicitly source-based analytical test output. No physical mouse/GUI, no owner save, no natural-combat economic measurement, and no B3 focused test were run. Static source review confirms auto-pill/B3 constants only. 30-person market cases are count-only fixtures, not 30 workers; `eco05` exercised owned paid annex slots but did not prove30 simultaneous production workers at one site.

The sandbox lacks a native checkout. Strict import used reconstructed snapshot `16e57...`; all32 economy/save/PvE relevant source/test Git blobs matched live HEAD `a641...`. Therefore status is **content-verified relevant-source QA**, not whole-tree native exact-SHA PASS. Sanitized raw logs are archived as `raw_logs_sanitized.zip`; the helper source is under `qa_helper/`.

## Evidence index

- [Run manifest](run_manifest.json)
- [Scenario inputs and assumptions](scenario_inputs.json)
- [Read-only scenario outputs — CSV](read_only_scenario_matrix.csv) / [JSON](read_only_scenario_matrix.json)
- [Theoretical Lv1–100 upgrade curve](building_lv1_100_cost_curve.csv)
- [Godot test matrix and exit codes](godot_test_matrix.csv)
- [32-file remote blob verification](source_blob_verification.csv)
- [Source → sink map](source_sink_map.csv)
- [1/7/30-day source scenario log lines](source_scenario_outputs.csv)
- [Findings and unapproved options](findings.csv)
- [Sanitized raw Godot logs](raw_logs_sanitized.zip)
- [Read-only helper source](qa_helper/eco_bal01_readonly_matrix_test.gd)

