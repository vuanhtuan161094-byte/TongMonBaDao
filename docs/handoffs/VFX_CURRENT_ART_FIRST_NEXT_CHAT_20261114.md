# VFX CURRENT HANDOFF — ART-FIRST / 2026-11-14 / R8 REMAKE

## Mandatory owner art rule
**One beautiful original skill at a time**; owner explicitly rejected template batch and POI05 R5 radial flower. Always read AGENTS.md and docs/operations/TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md. No Codex, rig, new branch or merge for VFX; no changes to live Combat V2/HP/target/status, SaveService, AI, economy, PvE or V6.3. Three approved Human Poison scenes poison02/poison03/poison04 stay locked.

## Current skill and exact canonical facts
`tmb.skill.poison.co_doc.active_04.human` — **Tán Cổ Diễn Nhiễm** (Độc Tu/Cổ Độc), poison/circle, radius 2.5, up to 3 targets, cast 0.55, range 7, cooldown 12, poison duration 7, 1 stack as source metadata. All real status/hit/target events are Combat V2-owned. Do not invent a triple hit; isolated lab has three dummy sprites only.

## Art status: R5 REJECTED; NEW XIANXIA R8 is OWNER_VISUAL_PENDING
- Original R5 `res://labs/combat_lab/poison05/tan_co_dien_nhiem.tscn` is kept as archival baseline, **not** approved. The ugly 6-petal star/chrysalis must not be reused.
- New R8 live candidate is `res://labs/combat_lab/poison05/remake_r6/tan_co_dien_nhiem_r6.tscn`, script same folder. It has **12 original living ghost centipede-gu poses** (violet chitin, jade highlights, fangs/legs), **6 cracked black-jade seed poses**, **6 different asymmetric living infection mark poses** + original Xianxia immortal valley environment. NO rig. Frame-based 3-branch animated paths and temporary poisoning marks, but no real gameplay effects.
- Art iterations: R6 large gu lingered over actors; R7 fixed early dissolve but infection light looked like three shield frames; R8 replaced with creeping vertical parasite tendrils and tiny moving spirit-gu. Based on actual 1280x720 video inspection, target heads remain readable and no radial flower remains.
- **Exact R8 code SHA `262f80aaaa87e8391ed8aa779583fa61d25eafd2`**; official pinned Godot 4.7.2 GL Compatibility [Action #43564471099](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43564471099) SUCCESS with `VFX_POI05_R6_RESULT=PASS failures=0` (test retains R6 namespace), native 1280x720 **252 frames / 4.20s** at fixed encoded 60fps. Full artifact ID **14101553006**, filename `vfx-poi05-r6-262f80aaaa87e8391ed8aa779583fa61d25eafd2`; 14 phase PNGs, GIF, MP4 and logs. No physical Windows/Android FPS QA.
- User-facing video, GIF, 4-phase sheet and ZIP built directly from the actual R8 Godot MP4; never pass AI concept posters as runtime. Actual inspected frames 0.44 charge, 1.18 flight, 1.65 split, 1.90 target approach, 2.50 living infection, 3.60 fade.
- Ledger remains `GODOT_LAB_PASS_ART_PENDING / OWNER_VISUAL_PENDING / HOLD_V63_OFF`. **Owner has not yet approved R8**. Do not move to another skill until user explicitly approves or directs another R8 art correction. Do not say all VFX finished.

## How to continue in a new chat
User can write only 'Tiếp tục VFX Tông Môn Bá Đạo PR #72'. Read AGENTS.md and SOP V3; verify latest PR HEAD and this handoff; show existing R8 actual Godot video/QA and solicit user visual decision or follow their corrections. Separate technical PASS from owner art approval. Do not promise background work.
