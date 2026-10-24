# NEXT CODEX TASK — TMB MASTER V3 FOLLOW-UP

Continue from the branch and evidence below. This is a proposed next task prompt; obtain owner direction before implementing broader UI or balance changes.

Repository: vuanhtuan161094-byte/TongMonBaDao
Current branch: integration/master-v3-combat-d7-uiux-20261024
Base PR #26: 53ff0b223f4e77ccfbe5c77d2203496ac0cc37a9
Tested code SHA: 80ed0270d2b7370f8feff1ce829f167146f3f341
Godot: official 4.7.2.stable.official.ed1daf0bf

Read these first:
- docs/handoffs/TMB_MASTER_V3_IMPLEMENTATION_REPORT_2026-10-24.md
- docs/handoffs/TMB_MASTER_V3_UI_ISSUE_MATRIX_2026-10-24.md
- docs/handoffs/TMB_CHATGPT_SUMMARY_PACKET_2026-10-24.md
- outputs/TMB_MASTER_V3_20261024/08_before_after_comparisons/current_annotated_mockup_actual/

Current evidence: focused suite PASS 20/20 on fresh isolated userdata; a first run was 19/20 due O9's fresh roster allocation and its cause remains unconfirmed. P3.2 GUI capture PASS at 1280×720, with CARE hit/skill, paid loot, canonical Warehouse and SaveService reload. Injury in the captured frame is 0. Combat fixture PASS is diagnostic only. D7 profile is implemented; map/worksite/combat mockups remain static.

## Suggested next action

Start with owner review of the four current→annotated→mockup→actual sheets. Ask which visual changes are approved for implementation. If approved, make a new draft branch based on this branch and implement only the selected P3.2 presentation changes. Keep the current actual runtime, P3.2 map/building state and CARE data as the source of truth.

Keep these boundaries:
- Keep PR #24/#25/#26 open and unchanged. Do not merge anything.
- Do not change Combat V2/CARE, Injury120, reward/warehouse, scheduler or SaveService ownership.
- Do not implement ×100 rebalance until exact HP/damage/potion/item values are approved.
- Do not add hunt EXP, a new runtime, clock, world, save, actor party, Boss/AoE event or duplicate loot.
- Do not mark mockups, scripted capture, Windows manual, Android or Owner Visual as equivalent.
- Do not run FULL/CI unless separately authorized.

For each approved UI issue, list exact allowed files before editing, make one small checkpoint, run affected focused regressions with official Godot 4.7.2, and capture actual P3.2 before/after at 1280×720 with exact code SHA. Retain any failing first-run logs alongside clean retry results.

Possible separate follow-up prompts:

1. Owner visual: “Review the four image sheets in the handoff ZIP and approve or reject each issue ID in TMB_MASTER_V3_UI_ISSUE_MATRIX_2026-10-24.md. Do not merge PRs.”
2. Balance: “Approve numeric targets for V2 HP, damage, healing pills, caps and item values after reviewing P1 evidence. Do not implement until the complete value table is explicit.”
3. Manual acceptance: “Open the draft branch on Windows Godot 4.7.2 at 1280×720 and perform mouse play/save/load/redeploy; record the steps, observations and any failure. Android remains a separate physical-device gate.”
