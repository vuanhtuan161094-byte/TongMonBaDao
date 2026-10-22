# TÔNG MÔN BÁ ĐẠO — Source A Safe Conversion: tiếp quản checkpoint 67 QA PASS và tối ưu tốc độ

**Ngày 22/10/2026** — Phân tích tĩnh từ hai tệp do owner vừa gửi: `SAFE_CONTINUE_REPORT_vi.md` và `stage_timings.csv`; **không chạy Godot hay converter ở đây**, không thay đổi dữ liệu gốc, không merge, không chạm luồng B3 runtime.

**Cần đọc trên máy của Codex:** `E:\TongMonBaDaoWorkspace\03_AssetLibrary\SourceA\reports\safe_conversion\SAFE_CONTINUE_REPORT_vi.md`, `stage_timings.csv`, `handoff_summary.json`, `CHECKPOINT_CURRENT.json`, `sourcea_safe_campaign.py`, `sourcea_library.py`, `AGENTS.md`.

## A. Baseline có bằng chứng

- Full Source A inventory: 184,888 files, 16.15 GiB, 0 read errors; Spine parser 6,578/6,578 PASS; 6,243 READY and 335 REVIEW.
- **QA PASS recorded 67 = 58 currently verified outputs + 9 historic requiring refresh**. Không gọi 67/67 là current-fingerprint validated.
- READY chưa PASS **6,166**, bao gồm **3 HELD**; eligible unpassed excluding HELD **6,163**. Refresh jobs **9**; queue size **6,172**. Các số khác nhau bởi bộ lọc, không cộng chồng 3 HELD như nhiệm vụ an toàn.
- 5 PASS mới: `11123003_1`, `1113001_s`, `1113002_1_s`, `1113002_2`, `1113002_2_s`. `1113001` HELD alpha toàn trong suốt ở clip `stand_1`, không được coi source hỏng. Tổng HELD: `1111204_1_s`, `1113001`, `2123019_10`.
- Timeout cũ `1111204_1_s`: prior full capture had **270/354** PNG then 3,600s outer timeout; bounded diag on problematic 4 clips captured **93/93** frame, returncode0, **no packing/publish**, root cause **NOT_REPRODUCED**, preserve HELD. Không tự đánh dấu PASS.
- Focused tests reported 20/20 PASS, SHA 279 file pairs checked per owner, one-worker lock, bounded process-tree watchdog; QA not owner visual. Two initial timing runs used `godot_validation` label where later runs used `runtime_metadata`.
- 43 five-clip candidates `stand/walk/attack1/hit/dead` with verified current output; **0 role_verified/COMBAT_READY**. Parsing 411 AndroidData configs did not prove role linkage, so do not call them protagonist/Boss from ID patterns. **32 groups** have ambiguous duplicated `source_id` with distinct `asset_id`; `source_key` canonical.
- REVIEW: 162 atlas, 173 texture/page. **99 atlas mapping proposals** with page name/dimension/hash evidence; NOT promoted. 61 ambiguous/missing page and 2 dimension conflicts. 173 texture rigs/183 pages: 112 mismatches nonuniform, 3 pages exactly 2×, 62 elsewhere candidates, 4 unresolved page names, 2 cases remaining other-page issue. Filename-only and raw-resize fallback **forbidden**.
- Operator intentionally disabled RAM and CPU stopping gates (`minimum_available_ram_mib=0`, `runtime_ram_floor_mib=0`, CPU telemetry-only). **Respect latest owner choice**. Retain OS writer lock, one child tree, disk preflight, timeouts, resource telemetry, rapid manual halt; do not silently reinstate gate or claim this is Windows/Android safe for unlimited bulk running.

## B. Time profiling — 6 actual converter attempts (from attached CSV)

| Stage | Sum seconds | Fraction of 584.688s converter total |
|---|---:|---:|
| Godot native frame capture | 264.954 | **45.3%** |
| Packing/static validation | 146.500 | **25.1%** |
| Godot import (multiple invocations) | 90.240 | **15.4%** |
| Runtime metadata + validation stage | 12.046 | **2.1%** |
| Unattributed overhead | 70.948 | **12.1%** |

Attempts = 6; PASS=5, FAIL=1, total `converter_total` = 584.688 seconds. **Observed 30.7856 PASS/h** inclusive of one failing converter and ignoring between-batch overhead; not a true sustained machine throughput or ETA. Sample capture ranges 16.031–88.438s, packing 3.437–81.735s, converter total 48.063–202.203s; texture/page/frame complexity matters.

**Scale warning:** 6,163 eligible / 30.7856 PASS per hour ≈ **200.2 converter-hours as arithmetic projection only** under unrealistic equal-mix assumptions. This is not a promised completion time. Avoid running thousands of real Godot conversions in a single unbounded agent call.

## C. Next priority #1: scoped performance diagnosis, then resume

**No change to QA authority:** FAST means genuine frame capture, alpha check, real canvas/crop, manifest/hash and source/converter fingerprint. If a new STATIC-ONLY tier is invented, it must be named differently and **NOT** a PASS replacement. FULL means real Godot playback, not static manifest.

1. On next isolated Codex run, inspect 6 CSV cases plus **10–20 diverse candidate rigs** selected by frame-count, atlas size, clip count and suspected source complexity. Limit each run to manageable batch1–4 and write checkpoint per rig. Respect held excludes. Preserve exact initial measured baseline before editing.
2. **Native capture profiling**: record separate `spine_update`, `frame_post_draw`, `GPU_readback`, `PNG_write` elapsed time and memory/CPU each clip/frame using existing diagnostic hooks. Timeout remains stage240s, no-progress45s, total900s unless separately approved after evidence.
3. **Packing/static QA profiling**: identify time in image reads, alpha scans, canvas bounds, SHA, atlas layout, WebP encoding and compress/repeated disk I/O. Optimize CPU/IO/memory without lossless-to-lossy changes or dropping any manifest checks.
4. **Import reuse audit**: two `godot_import` rows per rig may be distinct stages, not necessarily redundant; inspect actual commands before deciding whether one import/project cache per bounded batch is safe. Preserve source pack revision isolation and process cleanup.
5. Controlled A/B before/after for same approved rigs, **frame pixels/hash or equivalent canonical RGBA comparison**, counts, transparency, alpha bounds, pivot, paths, and stable ZIP/manifest semantics. If converter output/fingerprint changes, refresh only impacted rig QA with appropriately bumped version, do not make historical outputs falsely green. If no safe speed gain, keep existing converter.
6. Continue FAST with `sourcea_safe_campaign.py --limit 1..4 --run` in one worker, sequential and resume, exclude HELD; may keep researching profiler when high load is not suitable. Do not use source `--id 11123003_1` except testing SKIP.
7. Tight report: measured p50/p95 capture and packing per rig/frame, throughput and failure rate, exact changed-file allowlist, new/unchanged fingerprint and SHA, negative test proof and next queue ID. **No large QA ZIP per batch**.

## D. Parallel light metadata work, separate from conversion writer

**Review mapping**: subset of 99 atlas proposals, check full page dependency & attachment region proof, no promotion until validation on isolated representatives; then versioned resolver change and requeue validated families after tests. Texture page cases need source provenance/UV checks; 3 actual uniform ×2 pages are different from 112 arbitrary dimension mismatches. Do not touch raw `02_SourceA`.

**Role identity**: 43 5-clip assets with `role=UNKNOWN`; build a read-only contact-sheet/image proof, attempt cross-reference through content registries/scene names/animation behavior instead of renaming `source_id`. Stable `source_key` primary; `asset_id` output key. Owner or trusted source may later approve role mapping. No “43 COMBAT_READY” announcement.

## E. Recommended scoped Codex prompt

> **TÔNG MÔN BÁ ĐẠO — SOURCE A SINGLE-WORKER THROUGHPUT / QA PARITY PILOT**
>
> Tiếp tục Source A từ checkpoint mới nhất `E:\TongMonBaDaoWorkspace\03_AssetLibrary\SourceA`. Đọc `SAFE_CONTINUE_REPORT_vi.md`, `stage_timings.csv`, report này trên GitHub và `AGENTS.md`. Giữ 67 QA PASS đã ghi = 58 current + 9 refresh, 6,163 eligible chưa PASS, 3 HELD. Không kiểm kê lại 184,888 file và không chạy parser 6,578 rig.
>
> Mục tiêu lần này: tăng **throughput thật** nhưng KHÔNG giảm FAST QA, không giả Godot FULL, không thay source/fingerprint vô chứng cứ. Profile riêng frame capture (update/draw/readback/PNG), packing (alpha/canvas/atlas/WebP/SHA) và hai lần import; baseline 6 converter attempts có 45.3% capture, 25.1% packing. Dùng một worker, SQLite writer lock, watchdog, resource telemetry, disk preflight; **giữ RAM/CPU gate disabled theo quyết định owner** nhưng báo real usage. Chạy tối đa 10–20 rig đa dạng chia batch1–4, có checkpoint sau rig, so sánh A/B mỗi thay đổi trong phạm vi converter-wrapper.
>
> Rig `1111204_1_s` timeout cũ và `1113001` stand_1 trong suốt, `2123019_10` crop giữ HELD; không retry full. Chỉ targeted diagnostics tách biệt và không nâng QA nếu không có capture + pack + validation. 335 REVIEW tiếp tục triage metadata theo family; không promote 99 atlas mapping proposals chỉ vì khớp tên.
>
> Bàn giao `performance_before_after.csv`, profiler stage report, all changed file SHA, focused tests, số PASS/FAIL/HELD, queue position, exact resume command, issue list. Không sửa gameplay, Combat V2, Source A raw, B3/Map/Character Studio/V5, không push/merge, không chạy nhiều Godot process/converter writer cùng lúc. Nếu không chứng minh được tối ưu an toàn, giữ converter hiện hành và tiếp tục READY theo batch.

**This file is a docs-only next-work proposal, not runtime CODE permission nor action on the Source A workspace.**
