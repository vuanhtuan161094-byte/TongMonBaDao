# TÔNG MÔN BÁ ĐẠO — D7-2P: TAM CĂN / TỨ TÍNH, HAI QUỸ ĐIỂM RIÊNG

**Ngày 23/10/2026 · Trạng thái: CHỐT PHƯƠNG ÁN NGHIÊN CỨU VÀ BỘ SỐ ĐỀ XUẤT (PROPOSED-SELECTED), CHƯA CODE / CHƯA OWNER QA**  
**Baseline:** `main@29b5fba448b0178cb520a4ada44b375b4b934e31`. **Docs-only, không sửa runtime / test / CI / FULL / save / PR #24/#25 / Source A / recovery, không merge.**  
**Quyết định mới của chủ dự án:** Tam Căn và Tứ Tính phải có **QUỸ ĐIỂM RIÊNG**, không còn chia chung một lượng 7 stat. Đây là thay đổi lên trên tài liệu D7–C16 cũ trên nhánh `docs/tmb-d7-combat16-birth-odds-freeze-20261023`; mọi mô hình chia 7 từ 1 quỹ trong các tài liệu trước trở thành **SUPERSEDED AS DESIGN PROPOSAL**, không có nghĩa đã thay đổi code.

## 0. Source / tham chiếu / bằng chứng

- **SOURCE** `FoundationSystem` + `DiscipleGeneratorOpenPoints`: P3.7C1 hiện roll một TOTAL cho đúng **6 thuộc tính**, min `floor(total/12)`, max `floor(total/2)`; phẩm chất gốc ở tổng điểm `<360, 360..599, 600..999, 1000..1799, >=1800`. Không được mô tả mã nguồn hiện tại là hai quỹ.
- **SOURCE** `RecruitmentSystem`: Dẫn Tiên thường `65/25/8/1.8/0.2%`; đủ guide Mị Lực 2500: `35/25/20/15/5%` trước khi hết quota; bonus quota Nghịch Thiên/day `ceil(Mị Lực/625)`, không bypass qua Chiêu Mộ Lệnh. `SOURCE_GACHA` fallback (Dẫn Tiên không hoạt động) có `42/30/18/8/2%`, `SOURCE_FATE` có `50/28/14/6/2%`. Không tạo bảng gacha ẩn mới.
- **OWNER directions**: Tu Vi Core HP/ATK/DEF `10000/2000/1200` ×100 từ `100/20/12`; Tiềm Lực chỉ tăng phần **Tu Vi Core**, không tăng Body Core/EXP. V3 design tách Tam Căn=[Tư Chất,Căn Cốt,Tâm Tính]; Tứ Tính=[Tiềm Lực,Thông Tuệ,Cơ Duyên,Mị Lực].
- **SOURCE + PROPOSED-SELECTED**: Căn Cốt +0.20% natural Body XP/pt (source) và +0.025% Body Core/pt (proposed), Tiềm Lực +0.05% **RealmCore**/pt (owner new scope, old coefficient), Tâm Tính +0.20% Luyện Tâm progress/pt (proposed). Combat 16 channels giữ nguyên authority; không thêm điểm thuộc tính thứ tám.
- **Comparative references**: `The Strongest Sect` guides report prioritizing Potential over other six attributes, suggesting risk of one universally optimal combat stat: https://www.taptap.cn/moment/523495672154949004 . `Amazing Cultivation Simulator` separates five birth attributes and derived Potential: https://amazing-cultivation-simulator.fandom.com/wiki/Five_Attributes ; `RimWorld` separates learning passions from skills: https://rimworldwiki.com/wiki/Skills . **Không sao chép xác suất/con số của game khác.**
- Đối chiếu `AGENTS.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, `DISCIPLE_MASTER_SCHEMA.md`, `P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`, `DISCIPLE_V2_STAT_CAUSAL_CONTRACT.md`, `COMBAT_STATS_V2_SPEC.md`, `DiscipleState`, `CandidateState`, `DiscipleRealmProgressV2`, `MonsterCatalogueV2`.

## 1. Kết quả so sánh mô hình A/B/C

| Mô hình | Khả năng chuyên môn | Phẩm chất hiện có | Rủi ro |
|---|---|---|---|
| A: Một S7 và chia cả 7 | Chuyên môn trong 7, nhưng nhóm này tranh điểm với nhóm kia | Dễ giữ | **Sai yêu cầu mới**; thiên tài thể chất cắt điểm giao tiếp/tiềm lực |
| **B: Chọn grade theo nguồn tuyển, roll độc lập S3 và S4 từ hai khoảng theo grade** | **Cao; hai quỹ không bù trừ nhau trong grade** | **Giữ nguyên đúng** | Phải version generator / stat quality / migration và test fairness |
| C: Roll rare-grade riêng cho S3 và S4 rồi tính một grade | Lớn nhất nhưng dễ lệch phẩm/burst rarity | **Không giữ** nếu không có joint distribution mới | Nếu xác suất 0.2% mỗi nhóm độc lập, BOTH Nghịch Thiên = 0.0004% (1/250,000), không phải 0.2% |

**Chọn B**: Hai nguồn RNG/subseeds độc lập có điều kiện theo **grade đã roll theo tỷ lệ cũ**; không roll grade 2 lần. Quan trọng: độc lập *có điều kiện khi grade cố định* chứ toàn dân số có tương quan dương do cấp phẩm chung.

## 2. Bảng hai quỹ điểm tại lúc sinh — CHỌN SỐ CỤ THỂ

`Q` dùng thang chất lượng 6-stat cũ. Mỗi phẩm chất có ngưỡng `L..U`.  
Tam Căn pool `B3` roll integer uniform trong `[ceil(L/2), floor(U/2)]`; Tứ Tính pool `B4` roll integer uniform **độc lập** trong `[ceil(2L/3), floor(2U/3)]`.  
Với Nghịch Thiên (U không tồn tại): **mỗi pool roll một Q_heaven riêng** bằng đúng luật SOURCE tail Nghịch Thiên `start=1800,span=1200, 12% chance advance/loop and double span`, sau đó `B3=ceil(Q_heaven_3/2)`, `B4=ceil(2*Q_heaven_4/3)`. Không đặt trần.

| Phẩm | Grade roll nguồn | Q cũ | **Quỹ Tam Căn (3 trục)** | **Quỹ Tứ Tính (4 trục)** | Ví dụ mức trung tâm B3 / B4 |
|---|---:|---:|---:|---:|---:|
| Phàm Thường | 65% tuyển thường | 120–359 | **60–179** | **80–239** | **120 / 160** |
| Xuất Chúng | 25% | 360–599 | **180–299** | **240–399** | **240 / 320** |
| Thiên Kiêu | 8% | 600–999 | **300–499** | **400–666** | **400 / 533** |
| Tuyệt Luân | 1.8% | 1000–1799 | **500–899** | **667–1199** | **700 / 933** |
| Nghịch Thiên | 0.2% | ≥1800; tail vô hạn | **≥900, no hard cap** | **≥1200, no hard cap** | **~1250 / 1667 chỉ là ví dụ**, không cố định |

**Điểm mạnh của hai quỹ:** Đệ tử Thiên Kiêu hoàn toàn có thể roll Tam Căn 480 **đồng thời** Tứ Tính 640. Không hạ quỹ nọ để trả quỹ kia. Mỗi quỹ riêng vẫn có 3 hoặc 4 thuộc tính tranh phần nội bộ, tạo vai trò đặc trưng.

**Giữ phẩm chất KHÔNG bị tăng giả vì thêm chiều**:
```text
S3 = Aptitude + Constitution + MindNature
S4 = Potential + Comprehension + Fortune + Charisma
Q_normalized = round_half_up((S3+S4)*6/7)
grade = old P3.7 thresholds(Q_normalized)
```
Với [ceil(L/2),floor(U/2)] và [ceil(2L/3),floor(2U/3)], mọi `Q_normalized` đều nằm trong grade gốc (kiểm chứng toàn bộ 250,000 mẫu ở §4). Một số điểm biên có thể không thể sinh ra chính xác Q=U; **không làm dịch chuyển tỷ lệ phẩm chất**. Nghịch Thiên vẫn có tail dài.

## 3. Cách chia một quỹ NỘI BỘ và RNG

**PROPOSED-SELECTED: Uniform feasible integer partition, source-compatible concept, not calling existing 6-way function.**

For a pool `B` with `n` owned dimensions only (`n=3` hoặc `4`):
```text
lo = max(1, floor(B/(2*n)))          # ≈ 0.5 × group mean
hi = max(lo, floor(3*B/n))           # up to 3× mean nominal bound
values = [lo]*n
remaining = B-n*lo
shuffle(indices, group-specific deterministic RNG)
for each shuffled index i except last:
    reserve_right_capacity = sum(hi-values[j] for indices after i)
    add_lo = max(0, remaining-reserve_right_capacity)
    add_hi = min(hi-values[i],remaining)
    add = uniform_int(add_lo, add_hi)
    values[i]+=add; remaining-=add
last gets exact remainder
assert sum(values)==B and every value within lo..hi
```
**No transfer across groups, not even on remainder.** Two RNG domain names `v3/birth/tam_can` and `v3/birth/tu_tinh` seeded via new versioned derivation from stable profile seed; does NOT advance the old P3.7C1 gacha sequence. All seven attributes symmetric in expectation *within* each group; **not seven identical marginal distributions** because n3 and n4 have different feasible partitions. Tứ Tính gets slightly fatter high-point tails. This asymmetry is explicitly measured, not hidden. If owner needs identical marginal distributions across seven, the inner sampler requires a separate calibrated design/gate. The source-FATE old 70% fortune-highest swap must be **contained within Tứ Tính only** after splitting, otherwise it would violate pool isolation. This source-specific change needs later approval/evidence.

**Clarifying “độc lập”**: Source grade g is a shared recruitment contract; after it is fixed, pool totals B3 and B4 and their per-pool allocations use non-overlapping RNG and do not condition on each other's values. After recruitment, each current point can grow permanently in its own stat as before, with no birth envelope hard cap.

## 4. Independent reproducible CLEAN-ROOM Monte Carlo

**Python 3 random.Random(20261023), 250,000 synthetic newborns total: 50,000 samples PER grade**, NOT 250,000 natural Dẫn Tiên rolls and NOT Godot 4.7.2 QA. Generator steps: choose forced grade, sample pool intervals from §2 using independent random draws, apply §3 feasible partition. For heaven, use source 12%-branching infinite tail separately for each pool. Sample fixed index `Tam Căn[0]=Tư Chất` and `Tứ Tính[0]=Tiềm Lực`. Percentiles empirical; simulation outcomes are not exact analytic probabilities.

| Grade | Tam Căn pool P10/P50/P90 | Tứ Tính pool P10/P50/P90 | Tư Chất P10/P50/P90 | Tiềm Lực P10/P50/P90 |
|---|---|---|---|---|
| Phàm Thường | 72/120/168 | 96/159/224 | 17/35/71 | 16/32/76 |
| Xuất Chúng | 192/240/287 | 256/320/384 | 42/71/133 | 39/64/148 |
| Thiên Kiêu | 320/400/479 | 427/534/640 | 70/118/221 | 65/107/248 |
| Tuyệt Luân | 540/700/859 | 720/932/1145 | 120/208/388 | 113/188/431 |
| Nghịch Thiên | 968/1243/1737 | 1291/1655/2298 | 215/384/738 | 201/352/813 |

| Conditional within grade | P(Tư Chất≥200) | P(Tiềm Lực≥200) | P(Tư Chất≥500) | P(Tiềm Lực≥500) |
|---|---:|---:|---:|---:|
| Phàm Thường | 0% | 0% | 0% | 0% |
| Xuất Chúng | 0.004% | 2.044% | 0% | 0% |
| Thiên Kiêu | 15.340% | 18.322% | 0% | 0% |
| Tuyệt Luân | 52.884% | 46.282% | 1.732% | 5.398% |
| Nghịch Thiên | 93.480% | 90.462% | 31.956% | 30.300% |

**Weighted over natural SOURCE distribution (65/25/8/1.8/0.2)**, derived from five conditional MC probability estimates:
- Random newborn P(Tư Chất≥200) ≈ **2.367%**; P(Tiềm Lực≥200) ≈ **2.991%**.
- P(Tư Chất≥500) ≈ **0.0951%**; P(Tiềm Lực≥500) ≈ **0.1578%**.
- P(both Tư Chất≥200 AND Tiềm Lực≥200) ≈ **0.835%**. They are conditionally independent given grade but NOT independent across all ordinary recruits; naive multiply of unconditional probabilities would be wrong.
- Shared-7 old proposal synthetic control (50,000 per grade) shows **correlation between S3 and S4 ≈ −0.54 in Thiên Kiêu**; new two-pool sample **≈ −0.0008** for the same grade. *Across all ranks both pools trend together because grade is shared*, not a violation of conditional independence.
- All simulated grade membership checks **250,000 / 250,000** pass the Q thresholds. This proves arithmetic design behavior for these seeds only, **not a game test**.

**Why two group sizes yield a slight tail bias**: For 3-way group with min 0.5×mean per other field, one stat's effective maximum is near **2× the group mean**; for 4-way group, near **2.5× mean**. Thus Tứ Tính can produce more extreme isolated outliers even if means match. This is an intentional *visible tradeoff of the proposed simple sampler*, not silently 1/7 perfectly equal. If future test shows it makes Tiềm Lực too dominant, first adjust group-local dispersion, not quality rarity or combat law.

## 5. Concrete disciples from separate pools

**Thiên Kiêu specialized in Tam Căn**: B3=480, `Tư Chất315/Căn Cốt80/Tâm Tính85`; B4=427, `Tiềm Lực58/Thông Tuệ62/Cơ Duyên54/Mị Lực253`. Then Q≈**777** (Thiên Kiêu). A strong natural cultivator, yet ordinary Potential.

**Thiên Kiêu specialized in Tứ Tính**: B3=320, `Tư Chất197/Căn Cốt70/Tâm Tính53`; B4=640, `Tiềm Lực95/Thông Tuệ125/Cơ Duyên340/Mị Lực80`. Then Q≈**823**. Cơ Duyên specialist but not forced to sacrifice Tư Chất to reach that budget.

**Thiên Kiêu both groups high**: B3=460, `Tư Chất160/Căn Cốt200/Tâm Tính100`; B4=630, `Tiềm Lực230/Thông Tuệ95/Cơ Duyên180/Mị Lực125`. Then Q≈**934**. No cross-pool compensation: high Body potential and strong combat potential can coexist, rare via independent draws.

## 6. Combat + Body + progression crosscheck

Separate birth pools **DO NOT change** the already selected combat target formula:
```text
G(r,f)=1.65^(r-1)*1.03^(f-1)
RealmCore = [HP10000,ATK2000,DEF1200] * G(tuvi)
BodyCore = [HP9000,ATK300,DEF700] * G(body)
Core = RealmCore*(1+0.0005*Potential) + BodyCore*(1+0.00025*Constitution)
```
Baseline 1.1 Potential0 Constitution0 HP19,000/ATK2,300/DEF1,900. Plus C100=>BodyXP +20% (SOURCE) and proposed BodyCore +2.5%; P100=>RealmCore +5% only (OWNER direction); TưChất100=>natural Tu Vi XP+25% (SOURCE). 16 CombatStatsV2 channels, direct damage/defense formula, no ordinary hit/miss, crit5%/×1.50, timing/DR/lifesteal unchanged. This is **numeric design**, not live code or achieved PvE balance.

**Balance warning**: More independent high Tam and high Tu builds increase joint high-total extremes compared to one shared-pool without increasing grade odds. This is precisely what the user wants but may speed up progression and decrease starter combat difficulty. Re-run fixtures with same-grade P/Tam/Tu P10/P50/P90, all 300 realm/body floors, 1/3/6 actor and two-team Boss, medication+55→proposed+5500HP migration, Source A presentation and save old HP ratio BEFORE coding. Absolutely no automatic nerf or newly invented hard cap.

## 7. Versioned migration, QA contract and ownership

- **Main still six fields**; need new versioned Tam Căn 3 / Tứ Tính 4 generator and a seventh field in CandidateState, DiscipleState, FoundationSystem, SaveService and UI. Separate original birth and current permanent values; retain existing seed histories and all Root/Trait/Bloodline/Physique attributes.
- Existing six-stat V2 saves: set `mind_birth=round(sum(old six BIRTH)/6)`, `mind_current=round(sum(old six CURRENT)/6)` under explicit migration version; **never reroll or take points from either existing group**. Then `round((sum6+mind)*6/7)=sum6` for integer points, so the original grade remains EXACT; record `migration_v3_compat`, not a free future reward. This is a compatibility rule, not new-birth random law.
- Dẫn Tiên's rate curve, 5%-quota and event receipts must be unchanged. Distinguish `SOURCE_GACHA` disabled-Guidance fallback and `SOURCE_FATE` with its Cơ Duyên bias; extend seed domains, no duplicate charge or invitation, no category with undisclosed spawn chance.
- Recruited V2 still begins TuVi1.1 and Body1.1 with zero EXP, One Active Job, Injury0/1/120, warehouse and replay exactly once. No mechanical “reset” of old save. A new mind-training track, if separately approved, cannot silently grant XP/events without a verified activity.
- **Gate A** Godot deterministic same seed/grade + independent subdomains. **Gate B** exact pool sum, integer floor/ceiling, normalized grade invariance including min/max and heaven tail. **Gate C** old-save migration and 100% old quality preservation on genuine saves. **Gate D** 100,000+ official seeded births by source with observed grade confidence intervals and acceptable group skew; 1/3/6 PvE fixture distribution; physical Windows/Android presentation. Nothing in this docs-only packet supplies these PASS results.
- The V3 D7–C16 numeric benchmark list stays **proposed**, not owner ratified merely because new model is selected. **Never rewrite source implementation or merge until separately approved**.

## Design verdict

**SELECT B: TWO independent numeric budgets conditional on the one existing source-quality grade.** Preserve quality rarity and macro tier; split values only within each named group, not across Tam Căn and Tứ Tính. Keep the original seven effects and core combat formulas under separate numeric gate. This supersedes the previous one-shared-budget design recommendation and corrects its core conceptual error.
