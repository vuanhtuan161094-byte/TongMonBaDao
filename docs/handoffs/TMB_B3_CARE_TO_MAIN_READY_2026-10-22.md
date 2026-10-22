# TÔNG MÔN BÁ ĐẠO — B3 CARE MAIN-INTEGRATION READINESS (2026-10-22)

## Verified from user-provided archive (read-only)
- Archive: `B3_CARE_FASTTRACK_HANDOFF.zip` provided to ChatGPT.
- ZIP top-level entries: 74 (includes manifest). `SHA256SUMS.txt`: **73/73 exact SHA256 PASS** recomputed from ZIP bytes. Digest strings uppercase in manifest and compared case-insensitively; no file missing.
- The included `B3_CARE_CODE.bundle` was extracted and verified with `git bundle verify` (full history, SHA-1 Git format), fetched into a temporary local Git object database for ancestry-only inspection. No external executable or game launch was needed.
- CARE HEAD: `35ffa85fd45da42e43722e7ac74b7423602d4491`. Base B3 FAST-TRACK: `1d686dc8e202f4831fa51373c15e6666f44702f9`.
- Live remote main read on 2026-10-22: `461caca1171462e0da092f21108c5c1733157ad9`.
- **Historical relation PROVED**: `git merge-base --is-ancestor 461caca... 35ffa85...` returned success; merge-base was `461caca...`. CARE is **7 commits ahead of main**, main has **0 commits not reachable from CARE** as of the above remote main check.
- Diff `1d686..35ffa`: 15 CARE-only changed files, exactly matching `DELIVERY_VALIDATION.json` allowlist. Diff `461caca..35ffa`: **25** paths including PH0/B3 FAST-TRACK/CARE additions; 7 commits. No changes to Source A needed.
- `DELIVERY_VALIDATION.json` asserts 540 tracked Git blobs in portable project; Git bundle has complete branch history. This is independent Git relationship verification, not a Godot rerun.
- `FOCUSED_RESULTS.json`: 15 official Godot 4.7.2 focused runs on exact CARE HEAD, all exit0/PASS markers per logs, but these **were run by Codex/local machine, not by ChatGPT**.
- `GUI_RESULT.json` and `NORMAL_1X_RESULT.json`: provided clean project GUI import/smoke records, normal 1x 120 rendered frames. **Human mouse/touch UX and physical Android remain PENDING**.
- `demo/B3_CARE_DEMO_RUN.json`: at tick 131 injury still 1, at tick132 injury0 and same-world auto-return, after return 2 more true kills, 4 `tinh_lang_bi` in canonical warehouse. Shared pill satiety `capacity=1000000`; Tu Khi +10000 fixed Tu Vi (25 points), Hoi Xuan +55HP (10 points), final spent35. Both legitimate alchemy jobs recorded with 6-tick cycles.
- **Latest direct OWNER correction**: daily pill cap is **1,000,000** per disciple per simulation day, not 100,000 (typing omission). This matches the CARE artifact; do not file an invalid CAP defect.

## Current remote integration state
- `main` at `461caca...` during inspection: not yet containing the B3 7 commits; B3 CARE may exist **only** in local Git bundle or worktree. Do not claim remote CARE branch exists.
- Six TMB project skills are installed in the private ChatGPT plugin, but GitHub main lacks them.
- Dedicated **draft [PR #22](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/22)** was created from `main` with exactly eight docs paths (six `.agents/skills` files, addendum to `AGENTS.md`, one registry document). Zero GDScript changes; PR not merged.
- There are numerous open stacked G1/MAP25/Economy V2 PRs with non-main bases. **Do not merge them all**, even after skill integration. Each requires a path/conflict/authority/QA matrix.

## CODEX: recommended next authorized integration workflow
```text
TÔNG MÔN BÁ ĐẠO — Tiếp tục sau B3 CARE handoff. Tôi xác nhận CAP Đan Bão Hòa 1.000.000/ngày/đệ tử. Trước tiên đọc docs/handoffs/TMB_B3_CARE_TO_MAIN_READY_2026-10-22.md từ nhánh docs/tmb-agent-skills-20261022 và PR #22.

1. Kiểm tra PR #22 chứa đúng 8 path docs/skills, không gameplay; kiểm thử Codex nạp được 6 skills trên PR branch. Chỉ merge PR docs sau khi review/pass và được quyền merge. Không lấy nguyên nhánh docs/tmb-agent-skills-20261022 vào main.
2. Trong worktree E: mới, fetch main mới nhất. Giữ nguyên CARE working tree. Tải/recover full Git bundle từ E:/codex/.../B3_CARE_FASTTRACK_HANDOFF.zip. Validate HEAD 35ffa85f... và nguyên vẹn lịch sử, compare main HEAD; tại lần đọc trước main 461caca... là ancestor CARE và CARE đi trước 7 commit, NHƯNG CHECK LẠI main tại thời điểm chạy vì có thể đã đổi.
3. Nếu main mới vẫn là ancestor CARE hoặc chỉ thêm PR skills docs độc lập, dựng branch integration riêng từ main hiện hành, import 7 B3 commits có nguyên gốc. Nếu đã diverge, inspect merge-base, preserve state/save/core authority và test; KHÔNG ép fast-forward / force merge hay giải quyết conflict bằng cách bỏ dữ liệu.
4. Verify full intended diff 25 paths main->CARE: included B3 PH0 + FASTTRACK + CARE. Preserve all existing gameplay authority; CAP 1000000 remains. No extra kill XP, bosses, Source A/JX, maps r2-r30, UI unrelated.
5. Run official Godot4.7.2 focused tests on NEW integration SHA plus affected cumulative regressions (Warehouse/Clock/Save/OneActiveJob/HP/Injury/Alchemy/V2). Distinguish Codex 15/15 old-commit evidence from fresh post-integration tests. Review save v2/v3 and crash/retry; do not mask errors or use old logs to mark new HEAD green.
6. Make distinct B3 CODE integration PR (not stacked into PR #22). Do not merge a failing code PR or claim manual/Android acceptance. Update checkpoint/handoff with actual SHA+regression/QA debts, then provide status and next safe CODE packet.
```

## Gate discipline
No new code was written by ChatGPT during this ancestry audit. PR #22 remains draft and CODE B3 still local; don't treat any GitHub doc as CODE authorization. Godot physical UI, real Android touch and 1000–3000 disciple performance need separately scoped QA. Root AGENTS governance prevails.
