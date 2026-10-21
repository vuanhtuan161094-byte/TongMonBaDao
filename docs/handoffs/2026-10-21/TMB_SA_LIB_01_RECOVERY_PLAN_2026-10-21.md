# SA-LIB-01 — SOURCE A SPINE LIBRARY: CONVERSION RECOVERY & DELIVERY PLAN

**Date:** 2026-10-21 · **STATE:** INDEX/CATALOG IMPLEMENTED, FULL CONVERSION BLOCKED · **Scope:** source A asset pipeline, NOT gameplay. Review ZIP: `TMB_SOURCEA_SPINE_LIBRARY_REVIEW_20261021.zip` (47,130,429 bytes; SHA-256 `080c1bc2479f77614a941a096056f75161bf248a2c4ce6af98b0f61d6050b979`).

## A. Ledger: confirmed vs outstanding

| Contract | Evidence | Status |
|---|---|---|
| Spine source coverage | 6,578 groups, 20,507 source files | INDEXED |
| Raw content presence | No missing files reported; cached hash where size/mtime unchanged | VERIFIED WITH CACHE PROVENANCE |
| Source classify | 5,328 READY / 1,250 REVIEW / 11 duplicate aliases | INDEXED; 1,250 REQUIRE REVIEW |
| Batch-01 old assets | 10/10 source+output checks, historical Godot 4.7.2 QA | HISTORICAL PASS ONLY |
| New converter fingerprint | 0 current-fingerprint QA outputs | PENDING |
| New on-demand skin GDScript | source patch exists; Godot runtime QA not run | PENDING |
| Batch queue | 5,309 READY blocked and 9 current-fingerprint refresh blocked | BLOCKED: RAM+5 Godot processes |
| SQLite/canonical catalog | integrity PASS; JSONL, 66 local path-free chunks | LOCAL DONE |
| Source A Godot sample packs | 2 ZIPs, CRC PASS; project-level reimport deferred | SAMPLE ONLY |
| Catalog metadata GitHub upload | Explicitly rejected pending destination consent | **DO NOT RETRY** without owner authorization |
| Codex Cloud/Google Drive share | Cloud cannot see E:; no Drive sync configured | NOT AVAILABLE |

## B. Hard hardware preflight

The tool was correctly blocked by 1,359 MiB available RAM vs 2,200 MiB threshold while 5 Godot processes were running. Measured E: free ~40 GiB. On an 8 GiB Windows computer with prior OS crashes:

1. Save editor work; inventory the 5 Godot processes and their worktrees. Never terminate them blindly.
2. Schedule a conversion window with **one** Godot converter, no parallel GUI editors, no parallel Codex build/load tests.
3. `Run-SourceA-Library.cmd status` must show RAM threshold and >=5 GiB disk headroom; never bypass the guard by lowering RAM threshold just to force work.
4. Ensure conversion writes output/checkpoint on E:; do not use Administrator user profile.
5. Run a *short bounded batch* on 5–10 prioritized READY rigs, then stop, validate output fingerprint, Godot 4.7.2 import/playback, peak RAM and disk growth.
6. Use `resume` only when preflight is green. Checkpoint+resume after every rig. Record failures; preserve no-source-mutation invariant.

## C. Conversion order

**Phase SA-1 (small pilot, high reuse):** refresh 9 historical READY outputs; validate previous 10 evidence; convert Source A rigs needed by Combat V5.1, Character Studio V2 and monster/boss candidates; verify per-skin bake on one multi-skin actor. Source selection is based on verified source IDs and existing manifests, never fabricated roles.

**Phase SA-2 (remaining READY):** systematic resumable conversion of all unique READY rigs. Exclude the 11 duplicate aliases from redundant baking, but keep searchable aliases resolved to the canonical content. Stop on hardware gate; no destructive retries.

**Phase SA-3 (REVIEW cohort):** classify the 1,250 REVIEW cases by actual reason, prioritizing 1,059 parser/source-review states. Do not relabel REVIEW to READY without parser/QA evidence. Continue supported recovered files; preserve UNSUPPORTED/FAILED evidence. Known outliers: `1113001` transparent default `walk`, `Body_430056` canvas bounds.

**Phase SA-4 (packaging):** for each approved actor provide scene, SpriteFrames, atlas, asset manifest, license/source reference, clip names/durations, skin config, foot/pivot, path resolution. Expose `find` / `inspect` / `resolve` / `verify` / `export-pack`. Build searchable thumbnails/contact sheets lazily.

**Phase SA-5 (distribution):** retain full derived library local or on storage designed for large binary; GitHub only for code/docs and limited permitted production packs. Any cloud transfer must be separately authorized and verified accessible from Codex Cloud. A local E: path is not a cloud access path.

## D. Exit criteria and reporting

- 100% of 6,578 source group IDs has a final indexed state, reasons for REVIEW/FAILED, duplicate aliases, QA evidence links; *this is source coverage, not 100% conversion success*.
- Distinguish `SOURCE_READY`, `CONVERTED`, `GODOT_QA_PASS_CURRENT`, `HISTORICAL_QA_PASS`, `PARTIAL`, `BLOCKED`, `UNSUPPORTED`, `MISSING`. These must never be counted as one generic 'PASS'.
- Never change combat gameplay or silently modify original raw skeleton/atlas/PNG. Never overwrite QA_PASS without source/config/fingerprint mismatch.
- QA includes sample pixel fidelity where existing pipeline supports, alpha nonblank, crop/pivot consistency, clip duration, Godot import/scene playback, atlas dependencies. Windows GUI vs headless status clearly separated.
- Publish `TMB_SALIB_BATCH_xxx_REVIEW.zip` with detailed counts delta, input/output fingerprints, changed tools, logs, previews and all patches; preserve previous snapshots.
- Update the **master checkpoint** with exact counts and citation to new ZIP SHA; do not assume queue progress while machine blocked.

## E. Practical next Codex instruction (not automatically executed)

> Tiếp tục SA-LIB-01 đúng worktree. Trước hết chạy `status`; nếu RAM thiếu hoặc có Godot khác đang chạy, dừng và báo rõ, không kill process. Khi có tài nguyên, refresh các output lịch sử và chạy batch nhỏ 5–10 rig đã chọn. Xác minh current converter fingerprint và đường --skin bằng Godot 4.7.2; ghi PASS/PARTIAL/BLOCKED theo từng rig, báo peak RAM/disk, tạo review ZIP có metadata/manifest/ảnh/log. Sau đó mới tiếp tục `resume` theo các batch có checkpoint. Không tự upload 66 catalog chunk metadata lên GitHub, không merge hay sửa gameplay.

### Internal references
- `ASSET_LIBRARY_FOR_CODEX.md` in local library and review ZIP.
- `reports/FINAL_STATUS.md`, `reports/summary.json`, `reports/focused_qa.json`.
- SourceA GitHub tooling branch `sa-lib-01-sourcea-spine-library-20261021` @ `87d6b60123c85930e9eb571949f4aafbb8f8ac7d`.

---

## 2026-10-21 — RESOURCE-STARVED WORKER UPDATE (POST CURRENT-QA AUDIT)

**Evidence as reported by Codex, not independently read from the local E: ZIP:** latest review package `TMB_SALIB_CURRENT_QA_BATCH_REVIEW.zip` has CRC and 383 internal checksums checked by Codex. Current-converter QA **0 PASS**, historical Batch-01 **10/10 source/input hashes and manifests intact but historical QA only**; candidate multi-skin rig `2123019_10` has 12 skins and parse PASS. 1,248 REVIEW not yet classified + 1 REVIEW duplicate alias + 1 historical-QA REVIEW. The new reported machine samples are RAM free **1,011 MiB** earlier, **1,888 MiB** later, versus the **2,200 MiB** gate; E: free **51.28 GiB**; the provided Task Manager screenshot shows **100% CPU / 96% memory** and multiple Godot processes, three shown `Not responding`. The counts are at different instants; do not overwrite one with another as a single synchronous measurement. No rig conversion or new Godot skin QA ran in this audit.

### Audit of the real tool and consequence

GitHub tooling source `tools/sourcea-spine-library/sourcea_library.py` on `sa-lib-01-sourcea-spine-library-20261021`:
- `convert_one()` and `command_resume()` reject **free RAM < 2,200 MiB OR any Godot process**; this is deliberate concurrency protection. It does not become safe merely because the disk is large.
- `convert_one()` launches existing Spine converter with Godot 4.5 capture and Godot 4.7.2 QA inputs as a child process; a one-worker sequential loop does not imply low peak RSS.
- `status` opens `connect_library()`, which sets SQLite `journal_mode=WAL` and creates schema if necessary. Thus an allegedly read-only status **currently needs write access** and can fail under a task read-only writable-root policy. This is a CLI ergonomics improvement candidate; not proof of broken catalog.
- `resume` when blocked can update many queued asset statuses; do **not** rerun it to see whether RAM has recovered. Use passive OS resource checks or an eventual scoped read-only status path.

### New execution policy — no endless RAM waiting

1. **NOW:** mark SA-LIB conversion `BLOCKED_RESOURCE` and close this QA cycle. Preserve review ZIP, SQLite, raw Source A, converter fingerprint and output manifests. B2.4 has priority for the limited Windows CPU/RAM. Never auto-kill Godot, disable Defender, raise priority arbitrarily, lower the guard, or trigger new heavy QA just to seek PASS.
2. **LOW-RAM WORK ONLY:** read-only content source indexing and prioritization for 9 historical READY rigs / multi-skin pilot; parse or inspect existing manifests only as needed. Optional separately authorized **small tool-fix**: add a genuinely SQLite-URI `mode=ro` status/check command with no schema mutation, and a dry-run resource estimator. This is **not permission** to rewrite the converter.
3. **BEST LONG-TERM UNBLOCK:** use a **dedicated adequately resourced Windows worker**, cloud or physical PC, with verified Godot 4.5 and official 4.7.2 binaries, source toolchain and free storage. Transfer **only an owner-authorized small rig+atlas+texture subset**, with SHA-256 manifest and private access; do not assume an E: path or GitHub repo can supply raw Source A to cloud. Do not upload 66 catalog chunks or entire Source A without separate authorization. Test 1 current-fingerprint rig and 1 skin first, record max RAM/CPU, converter SHA, Godot import/playback, result ZIP and ability to bring the evidence back into canonical SQLite before a 5–10-rig batch.
4. **LOCAL FALLBACK:** after the B2.4 owner closes Editor and any Godot work (voluntarily, after saving), recheck live free RAM/CPU/disk. If the existing gates are green run **one rig only**, measure peak memory/CPU and checkpoint. If gates cannot be met in practice, mark local conversion `UNSCHEDULABLE` and use the dedicated worker path rather than polling/resuming indefinitely.
5. **GAME DEPENDENCY:** B3 backend AI farm and Combat V2 simulation do not require completing all 5,328 READY rigs. Source A should first produce **specific approved QA packs** used by Combat V5.1/Character Studio; defer the broad catalog. No current-fingerprint QA PASS means no automatic Character V2 pack-bridge clearance yet.

**Owner decision needed for actual cloud execution:** permission for an external worker and specifically scoped Source A input transfer. This research does not authorize such a transfer, additional Godot tests or code changes. No merge to `main`.
