# TÔNG MÔN BÁ ĐẠO — MASTER PROGRAM CHECKPOINT (2026-10-21)

**STATUS:** REVIEW / NOT MERGED. **Document-only tracking branch**, based on main `461caca1171462e0da092f21108c5c1733157ad9`. Do not interpret this file as changing the production authority of `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, `AGENTS.md` or gameplay.

## 1. Quyết định owner — cập nhật đến 21/10

- Gameplay authority = **Combat V2**; graphics/source of truth for visual = **Source A**. JX pilot SkillId/VFX may remain where explicitly supported but must not rewrite Combat V2 calculation.
- Map săn đơn giản: nền, hoa/cỏ, không xây đường đi/vật cản/A* phức tạp. Camera pan/zoom/follow tùy chọn; mobile target Android landscape 1280×720.
- 6 disciples/team, max 30 disciples and 40 monsters within V2 battle; One Active Job; Injury 0/1/120 ticks; canonical Warehouse; deterministic & exactly-once save/reward.
- Characters **may visually overlap** if they have distinct true foot positions/ground shadows; never fake on-screen offsets that diverge from hit geometry; do not require rigid separated formation.
- Target future farm: individual mob respawns, occasional elite/boss, per-kill species/tier loot, independent receipts, autonomous farm/crafting. **NOT YET PRODUCTION**.
- B3 hunting+gear experience: mixed Evil Hunter Tycoon autonomous economy and Võ Lâm boss/rare-item chase is **working direction**; exact drop rates, difficulty, rarity, enhancement values **OPEN**, do not silently lock pilot values.
- Every Codex task must produce a review ZIP including code/diff, test logs, screenshots where relevant, SHA manifest, base/branch/HEAD, full tracked+untracked inventory, remaining debt; no automatic merge.
- Do **not** upload Source A full per-asset catalog to GitHub without separate direct destination authorization. Its repository upload was previously rejected; metadata stays local until owner separately approves. This checkpoint deliberately includes no catalog records, per-asset hashes/attachment lists or workspace absolute paths.

## 2. Source A Spine Library — SA-LIB-01

- Local review ZIP: `TMB_SOURCEA_SPINE_LIBRARY_REVIEW_20261021.zip`, SHA-256 `080c1bc2479f77614a941a096056f75161bf248a2c4ce6af98b0f61d6050b979`; ZIP CRC PASS, bundled hash ledger 451/451 valid.
- 6,578 skeleton/atlas groups; 20,507 indexed files (6,578 skeleton, 6,578 atlas, 7,010 texture, 341 animation JSON). 5,328 source READY; 1,250 REVIEW; 11 exact-content aliases; source MISSING = 0, UNSUPPORTED = 0. Parser passed 5,519 skeletons.
- **Library/indexer tooling DONE**: SQLite/JSONL/CSV, metadata query/resolve, versioned manifest, one-worker resumable queue, resource gates, export Godot sample packs, on-demand skin-set implementation (not runtime tested for its new path).
- **FULL CONVERSION NOT DONE**: 0 output QA passes under current converter fingerprint. 10 Batch-01 outputs retain **historical** Godot 4.7.2 QA PASS only (sources+outputs rehashed, 10/10); refresh is pending.
- Conversion blocked at measured 1,359 MiB free RAM / 5 Godot processes against gate 2,200 MiB free; 5,309 READY queued and 9 historical READY waiting for refresh. The 82.5h estimate is a *serial projection*, not an execution commitment or a tested throughput guarantee.
- Two old technical failures still indexed: rig `1113001` default-skin walk alpha-transparent; `Body_430056` canvas edge clipping. No fabricated replacements.
- GitHub branch `sa-lib-01-sourcea-spine-library-20261021`, commit `87d6b60123c85930e9eb571949f4aafbb8f8ac7d` **tooling/schema/docs only**, no PR/merge; 66 local path-free metadata chunks **NOT UPLOADED**.
- **Next gate:** close excess Godot processes only after checking unsaved editor work; recheck available RAM and free disk, then run a *small prioritized* sample `status -> verify -> resume`; verify updated fingerprint, on-demand skin runtime, Godot import and memory before background multi-hour batch. On 8GB/BSOD-prone hardware, do not blindly start an 82-hour all-rig batch; use resumable chunks or provision safer machine.

## 3. Combat V5.1 Source A — presentation slice

- Local review ZIP `TMB_V5_1_VISUAL_FINAL_REVIEW.zip`, SHA-256 `9c57d930492343388594e0543aadd588793223b61ded285b506852219e5c7294`; ZIP CRC PASS; 216/216 actual SHA ledger entries valid (one comment line excluded).
- Branch `feature/v5-1-sourcea-visual-finalization` **local dirty/uncommitted V5.1 change set**, inherited handoff HEAD `ae3f397cef654cd3ff1936261b018476a132e7db`. GitHub **does not** contain those V5.1 dirty changes as a reviewable commit; ZIP includes diff, changed files, runtime assets and evidence.
- Presentational improvements verified in 1280x720 screenshots: softer Source A floor without dark seams; ground shadows, Y-order/readability improvements, selection HUD, mouse pan/wheel zoom/follow/deselect/reset signal; standalone pilot launcher. Existing V2 battle/event authority and five JX pilot IDs preserved.
- Focused test reported PASS (8 actors, 5 skills, 20 animation checks, 7 casts, 1 impact). 32-frame/16s actual GUI capture reported PASS, but capture has 27 hits, 1 downed, 1 telegraph, 4 pilot casts, **0 pilot impact cues in the capture** (the independent focused test has one). This is a coverage limitation, not proof of production VFX.
- Capture performance: avg 14.655 ms, p95 21.717 ms (~46 FPS at p95), terminal engine FPS sample 20; contains PNG capture overhead, **NOT** Android performance acceptance.
- Input caveat: reset via bound `Button.pressed` signal PASSED, synthetic mouse click on reset `false`; manual GUI mouse acceptance outstanding.
- Three pre-existing test failures reproduced on unchanged base `aad7cec1` and on V5 with matching failure signatures: One Active Job extra ore/wage receipt, real hunting UI missing visible deployment confirmation, GP-02C1 T15_PLANT `another_active_action`. **Known baseline debt, NOT PASS and NOT demonstrated newly introduced by V5**.
- Visual owner **PENDING**: sprite crowding and HP labels, Boss AoE telegraph occlusion, generic Boss-slot identity `410041_1` NOT canonical Boss confirmed, actual 30v40/Android and play-first launcher integration not complete.
- **Next gate:** visual review and manual reset/zoom/camera check in Godot; review patch and dirty .import/line-ending files, commit/push only clean scoped V5.1 code to its independent branch *after* approval; no merge without integration tests.

## 4. Other streams — last known, not reverified today

- Spawn & Loot Studio B2.1/B2.2: earlier MVP ZIP reviewed; editor-focused QA PASS, runtime missing at that point; B2.2+B2.3 larger code task dispatched separately. **No new B2.3 handoff ZIP in this checkpoint; status PENDING**. Working branch `feature/b2-spawn-loot-studio` may be local dirty.
- Character Studio MVP: earlier ZIP reviewed, focused QA PASS but GUI/animation completeness pending; Character Studio V2 task dispatched separately. **No new V2 handoff ZIP in this checkpoint; status PENDING**.
- B3 design: farming, items/hour, unique equipment, targeted-farm AI and pilot vertical slice documented; **design only, numeric balance unapproved**.
- Separate SA-LIB transfer and V5.1 changes cannot be treated as merged into main.

## 5. Risks and priority

**P0 safety:** isolate worktrees; no overwrite of dirty work; avoid simultaneous Godot processes on 8GB RAM; preserve user:// saves; maintain V2 ownership and exactly-once semantics.

**P1 delivery:** acquire clean V5.1 commit/evidence and confirm owner visual; test real UI input; give SA-LIB converter small-sample current-fingerprint PASS; finish B2.3 sandbox contracts.

**P2 integration:** establish single integration owner, merge in controlled order: reviewed V5 presentation -> approved/QA'd editor tools -> sandbox B2.3 → tested production hook -> Character Studio/Source A approved packs. Cross-branch collision review mandatory before each merge.

**P3 scale:** continue SA-LIB long batch in resumable chunks when hardware allows; build 60–90 minute B3 vertical slice before multiplying content across 30 cultivation realms.

## 6. Evidence and provenance

1. Uploaded local ZIPs inspected directly (2026-10-21), CRC and internal SHA records validated.
2. `reports/FINAL_STATUS.md`, `reports/summary.json`, `reports/focused_qa.json` within SA-LIB.
3. `docs/V5_1_VISUAL_REVIEW.md`, `docs/v5/REGRESSION_BASELINE_COMPARISON.md`, `qa/capture_report.json`, `qa/gui_input_report.json`, `git/git_status.txt` within V5.1.
4. GitHub live remote `main` at `461caca`, SA-LIB branch at `87d6b60`, as checked during this review.

**Next owner action:** REVIEW V5.1 visual and hardware queue; do not mark SA-LIB full conversion completed, do not auto-merge.
