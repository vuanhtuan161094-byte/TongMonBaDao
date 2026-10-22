---
name: tmb-godot-evidence
description: "Kiểm toán và nghiệm thu Godot 4.7.2: focused tests, save/load, crash/retry, ledger, Đan Bão Hòa cap, gameplay receipts, Windows/Android UX, hiệu năng; distinguish test PASS from owner requirement and physical QA."
---
# TMB Godot Evidence & Persistence — SKILL
## Evidence ladder
1. STATIC REVIEW = cannot claim playable.
2. OFFICIAL GODOT 4.7.2 focused runtime + captured exit code + source SHA + test log.
3. Windows physical gameplay and native 1280x720 GUI screenshot, with actual inputs.
4. Android landscape real device playthrough, memory and FPS measurement.
5. Owner visual acceptance. Distinguish untested/PENDING from FAIL.
Do not relabel simulated accelerated time as physical elapsed time.

## Preserve canonical save and exactly-once
- Read existing SaveService, RuntimeOwner, Warehouse receipts, scheduler and snapshot schema before suggesting changes. No second persistence store or naked UI-side debit.
- For command that consumes materials or grants loot/HP/XP: validate guards -> perform canonical debit/effect atomically -> write idempotency receipt/barrier -> save via existing authority. Duplicate callback/replay cannot repeat reward.
- On load: validate schema/version, migrate explicitly, reject impossible stock/caps/receipt relationships, and preserve old saves. Never silently reset 100000 satiety to an obsolete 100.
- Cover crash BEFORE debit, AFTER debit before commit, AFTER commit before UI, mid-job, mid-hunt, world reentry and day rollover. No reset from OS midnight; only sim tick.
- Maintain One Active Job; tests must verify failures produce NO stock/XP/HP changes.

## Headless and visual runtime
Use the project's actual official Godot 4.7.2 test harness. On a fresh clean checkout import when needed; record both exit code and diagnostics. An empty stderr or test count alone is not enough.
Use the smallest targeted tests during iterations and wider regression only when active packet and scope allow; never run FULL/CI under a packet that forbids it. Preserve baseline negative tests; avoid editing unrelated locked tests.
Inspect actual screenshots/video at target 1280x720 for touch targets, readable numbers/status, camera, hit/cast indication, authentic animation and map operation.

## Performance
Reproduce the bottleneck and capture before/after Godot profiler, frame time, draw calls, memory. Test representative many-unit/map cases with a reasonable cap, and separate PC emulator results from Android hardware. Prefer policy batching, scene/resource reuse, culling, atlas import correctness, reduced path queries and event-driven UI over blind optimization.
When local machine has only 8 GB RAM, prefer lightweight focused gates and isolated worktrees; don't require heavy FULL/batch conversions for trivial checks.

## Sources
Methodology adapted from gamedev-skills/awesome-gamedev-agent-skills save-systems, godot-gdscript-headless-testing, performance-optimization and setcodes godot-gamedev. Adapt to current repo's stronger receipts/save authority, not an alternate tutorial SaveManager.
