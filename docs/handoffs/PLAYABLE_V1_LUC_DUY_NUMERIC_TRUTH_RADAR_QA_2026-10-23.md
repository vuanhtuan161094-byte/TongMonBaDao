# TÔNG MÔN BÁ ĐẠO — PLAYABLE V1: LỤC DUY NUMBER TRUTH / RADAR UI CONTRACT

**Owner instruction:** 2026-10-23 — Lục Duy có thể lên hàng nghìn/hàng chục nghìn; mạng nhện chỉ cần biểu diễn tương quan/tỷ lệ, nhưng số hiển thị của cả sáu trục PHẢI đúng với trạng thái thật. Không tạo số fake, không nhân/chia 100 trong trường số gốc.  
**Status:** OWNER-APPROVED DISPLAY REQUIREMENT / UI QA PACKET (DOCS ONLY). No gameplay code, Godot run, CI, merge, O6/PR #24 change.  
**Source baseline:** `main=29b5fba448b0178cb520a4ada44b375b4b934e31` inspected 2026-10-23. Branch docs-only `docs/playable-v1-six-foundations-numeric-truth-20261023`.  
**Skill routing:** tmb-project-director + tmb-ui-playtest.

## 1. Source and display must be separate authorities

Canonical `docs/DISCIPLE_MASTER_SCHEMA.md` §3.1 and `docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md` lock 6 open-point permanent values (no hard cap): Tư Chất `aptitude`, Căn Cốt `constitution`, Cơ Duyên `fortune`, Thông Tuệ `comprehension`, Mị Lực `charisma`, Tiềm Lực `potential`. Each can reach thousands or tens of thousands and is persisted as CURRENT value, with an immutable BIRTH snapshot. `FoundationSystem.MODEL_OPEN_POINTS=2`. P0–P2 legacy use normalized 0..1 model; migration `_legacy_to_points` converts once, not on every UI refresh.

The canonical source for current UI is `DisciplePresentationSnapshotV2.build(state,disciple)["foundations"]` -> `{"model_version":2, "current": six unmodified real values, "birth": original values}`. Combat, Tu Vi and quality derivations use **the same raw permanent values**; never use chart points as gameplay values or persist the normalized chart back into save. `FoundationSystem.quality_for_total` derives quality from exact 6-current sum: below 360 common, 360–599 outstanding, 600–999 prodigy, 1000–1799 peerless, 1800+ heaven-defying, without changing the true total.

**Mandatory distinction:**
- **REAL NUMBER LABEL:** display 2,500 when source contains 2500; NEVER display 250,000 by multiplying 100, or 25 by dividing 100. If fractional upgrades exist, display meaningful precision without claiming an incorrect rounded source; expose exact source in detail/tooltips if needed. Numeric 0 is **0**, not "—" or unavailable.
- **RADAR RADIUS:** may normalize `chart_i = 100 * raw_i / max(max(raw_six), 1)` for readable proportional shape. This is a UI-only metric, not actual stat, not "quality", not % growth/effect, not 0..100 stat authority. E.g. one actor's internal relative shape can be the same as another's even if their absolute stats differ by 100x; explain `Tương quan trong nhân vật` if rendering separate profile radar. No hard clamp of raw stats to 100 or 9999.
- **EFFECT DISPLAY:** show actual derived bonus from canonical channel, not radar value: e.g. Tư Chất 2500 -> natural bonus `+625%` -> factor `×7.25` from Tư Chất alone (before other channel modifiers), never "100 points -> +25%" simply because chart cap=100.
- **TOTAL:** sum exact raw current six; do not add chart values and do not mix BIRTH with CURRENT silently.

## 2. Static code audit — concrete discrepancy on current main

**Backend snapshot is already correct (static inspection):**
- `godot/src/presentation/disciple_presentation_snapshot_v2.gd`, `_foundations()` (near lines 115–132), copies 6 unmodified `disciple.<field>` values and `model_version`.
- `godot/tests/presentation/dv2_03_disciple_presentation_snapshot_v2_test.gd` tests exact snapshot fields, but **does not prove UI text displays correct raw number**.
- `godot/src/presentation/p3_2_landscape_sect.gd`, V2 `_v2_attributes_tab_text` (near lines 3256–3304), extracts current raw values, then calls inherited `_score()` for every value (both normal and "progression not ready" branches).
- Parent `godot/src/presentation/p3_1_landscape_sect.gd`, `_score(value)` at lines 1037–1040 multiplies by **100** unconditionally. This was suitable for normalized legacy 0..1, but causes V2 model2 **display ×100**. Example raw Tư Chất 2500 -> UI 250000; core character value remains 2500. This is a **code-level defect candidate**, NOT a validated actual Android screenshot. Do not assume any old radar prototype shares this source path.
- `godot/src/presentation/p3_2_landscape_sect.gd` candidate list card near lines 902–921 directly prints candidate's raw `%.0f` values (different path) — don't replace with 0..100 normalized points. Formatting may round fractional input; verify before shipping.
- `godot/src/presentation/p2_8_disciple_generation.gd` also uses `value*100` in an older P2.8 testing screen; legacy source was normalized. Don't globally remove its multiplier without testing the model version/older snapshots. Same for parent `p3_1` fallback UI. **Target fix must be VERSION-AWARE, not a blanket rename of six properties or save migration.**

## 3. Exact test vectors

**V2-REAL-01:** Construct one legal V2 test disciple `foundation_model_version=2`, true current six:
`{aptitude:2500, constitution:1800, fortune:1200, comprehension:2000, charisma:900, potential:1600}`. Exact current total `10,000`; quality `Nghịch Thiên`. Its REAL labels must read `2.500, 1.800, 1.200, 2.000, 900, 1.600` (Vietnamese grouping; no leading radar percentages). Proportional radar for display only `[100,72,48,80,36,64]` if selected normalization. Values in snapshot unchanged before/after UI redraw, save/reload and selection. Tư Chất effect +625% natural, factor 7.25 if queried separately.
**V2-REAL-02:** `aptitude=10000`; exact display `10.000`, not `1.000.000` or `100`. Radar peak still 100; engine bonus for that axis follows open-point canonical if shown. Test potential 0 -> visible `0`.
**V2-REAL-03:** birth `{aptitude:1000,...}`, current `{aptitude:2500,...}`; UI can show birth/current separately but cannot overwrite one with other or silently collapse permanent improvements.
**V2-REAL-04:** two disciples with same proportions at ×10 absolute scale -> their six charts may look the same, but exact numeric labels, totals, quality and derived effects differ correctly. This must be clear in the UI (normalized radar **not** cross-disciple absolute metric).
**V2-REAL-05:** change an authentic V2 stat through legitimate permanent-grant authority, persist and reopen: no `*100` at any display layer, no double application, no snapshot mutation.
**LEGACY-01:** an untouched `foundation_model_version<2` founder with `aptitude=0.43` retains `43` on legacy normalized UI (where old `×100` is intentional); never rewrite that save or artificially treat it as V2 points in the label.
**FORM-01:** zero is shown as `0`, negative/NaN/Inf source fails invariant (or clearly `không hợp lệ`), text never silently substitutes `—` for a VALID zero. Real fractional growth is not silently rounded in a way that changes the reported actual value.
**UI-01:** 1280×720 landscape portrait, six labels readable without truncation, character selection/free camera state doesn't recalculate Lục Duy. Display value `10.000` in full somewhere even if compact UI also uses `10K`. Radial chart can clip safely; labels cannot hide total/current truth.

## 4. Future narrow UI code packet (only AFTER O6/Codex CARE integration QA)

**Proposed**: in `p3_2_landscape_sect.gd` implement a V2-only `_format_foundation_points(value)` and replace only six `_score(...)` calls in `_v2_attributes_tab_text` (including the `not ready` branch). The V2 flag is already available in `DisciplePresentationSnapshotV2`; avoid changing legacy `p3_1._score()` used in P0–P2 compatibility. Consider `_format_foundation_for_version(model_version,value)` in a presentation-only formatter utility if needed in both candidate card and profile. Do not alter `DiscipleState`, `FoundationSystem`, generator, SaveService, combat/XP formulas or canonical effect percentages to "fix display". Do not force migrate old saves.

**Tests** (proposed scope only): extend `godot/tests/presentation/dv2_03_p3_v2_disciple_profile_test.gd` with concrete V2 values and exact expected strings, verify `foundation.model_version=2`, no snapshot mutation; keep legacy P2 screen regression. Check `dv2_03_disciple_presentation_snapshot_v2_test.gd`. Source A / character art and radar design may be a separate UI-only change; ensure it never owns game stats.

**No active repair done:** No Godot run, UI code, main change, CI/FULL or merge during this documentation-only review. `PR #24` O6 remains Codex-owned; avoid modifying overlapping runtime. This requirement is included in the PLAYABLE V1 numeric-accuracy gate following the CARE integration.

## 5. General playable numeric-truth gate

Before visual acceptance, use a **source-to-screen table** for at least:
- six foundation current/birth/total/quality,
- current Tu Vi + floor requirement + major-gate status and Body analogue,
- real Combat V2 HP/maxHP/Attack/Defense and Injury120 remaining,
- Mine/Forest/Field/Alchemy output quantity, true worker/job instance, timer/ETA and actually settled Warehouse stock,
- actual hunt kill material/Stone/EXP receipts, pill satiety consumed/remaining out of **1,000,000 per simulation day**.

Every printed number must be traceable to saved simulation state or an explicitly labeled presentation-only derived formula. No dummy numbers, placeholder data, stale QA hardcodes, double conversions, "100" from radar as actual stat, or decimal formatting that distorts the underlying measurement.

## Owner-facing summary

**UX freedom:** 6-axis radar may show 0..100 internal proportions. **Authority constraint:** all visible stat labels show the canonical real six open-point values (thousands/tens of thousands allowed) with the correct model-version conversion, and a total from the real values. No gameplay changes until separate CODE authorization.
