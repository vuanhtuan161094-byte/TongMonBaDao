# NEXT CHAT HANDOFF — TÔNG MÔN BÁ ĐẠO

Updated: 2026-10-25 (Asia/Ho_Chi_Minh).

## Read and choose the correct source

1. Follow `AGENTS.md` and `docs/GAME_SYSTEM_ARCHITECTURE.md`.
2. Read `CURRENT_CHECKPOINT.md` for the current cross-branch status and exact evidence links.
3. Re-fetch only the target branch HEAD and its active packet/source. Do not search every historical branch unless a concrete missing feature or asset requires it.

The owner requested consolidation/removal of obsolete material. This packet changes documentation only. Existing session authorization remains scoped to its own workstream; this handoff neither cancels it nor authorizes a new gameplay packet or merge.

## Next useful work

| Goal | Correct branch / boundary |
| --- | --- |
| Verify the current sect-map candidate | PR #33, `feature/map-d2-direct-chatgpt-visual-upgrade-20261025`; parent #32 has 29/29 old focused evidence, #33 has none yet |
| Verify PvE scenery and topology preview | PR #34, `feature/pve-map-presentation-upgrade-20261025`; parent #31 has 28/28 old focused evidence |
| Continue finite/continuous baseline QA | `qa/code-r0-finite-world-20261025`; 21 configured tests, zero executed, no-runner investigation recorded |
| Develop equipment/Công Pháp/R11 content | Read the selected docs-only packet and live consumer first; no broad implementation authority from a design approval |

If Godot is unavailable, complete useful source/evidence/asset preparation within the authorized packet and report runtime PENDING. Do not repeatedly retry zero-step CI, infer a billing cause, or invent a new PASS.

## Runtime verification when an execution environment is available

Use official Godot 4.7.2, exact final SHA/tree, isolated userdata and one process on the owner's 8GB Windows machine. Preserve raw exit codes, markers and logs.

- #33: run the D2 visual contract, inherited D1B/map/camera/art/O9 and relevant PR32 focused set; verify Source A hashes and candidate SVG provenance; capture real P3.2 at 1280×720 and measure rendering/memory.
- #34: run landscape/topology contracts and relevant CARE/S1/camera/save/reward tests; capture the live hunt and the independent preview. Do not describe a preview as a working 300-monster world.
- R0: use the existing `tools/qa/Invoke-CodeR0-Focused.ps1` on the R0 branch, verifying the actual installed engine path. Run native git grep and all 21 named tests before any baseline PASS. R1–R6 and finite caller/save removal remain outside R0.
- Combined acceptance requires a separately prepared integration tree and relevant tests on that exact combined SHA. Branch-specific results do not certify a merge.

## Constraints to carry forward

Keep Combat V2 + integrated S1 behavior, D7, CARE, Injury120, One Active Job, canonical Warehouse/time/save/reward receipts and verified Source A art. Sect map and hunting world remain separate. Same-build save/load and exactly-once remain required; the owner does not require carrying every experimental dev save into every future build. This is not permission to delete current save readers/tests or pending entitlements.

Old Economy-A/ENV/Disciple phase prompts, the old README's P2.1 blocker and the unmerged-skills instruction have been removed from active entrypoints. No blanket source/asset/branch deletion or PR closure was performed. Restore historical details through the pinned pre-cleanup links in CURRENT_CHECKPOINT, not by reinstating old NEXT instructions.

## Ready-to-use continuation

“TÔNG MÔN BÁ ĐẠO — Đọc CURRENT_CHECKPOINT.md và NEXT_CHAT_HANDOFF.md tại nhánh dọn tài liệu 25/10 mới nhất. Đối chiếu HEAD PR #33, #34 và CODE-R0; tiếp tục chuẩn bị QA và rà source trong phạm vi đã được giao, ưu tiên mục có thể hoàn tất khi tôi chưa có máy tính. Giữ riêng các nhánh, chỉ sửa lỗi có bằng chứng trong phạm vi tương ứng; không merge hoặc triển khai R1–R6. Báo rõ phần đã code, phần có log runtime và phần chưa kiểm chứng.”
