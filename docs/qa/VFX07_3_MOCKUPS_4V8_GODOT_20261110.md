# VFX-07 — 3 mockup skills, four-corner 4v8, exact-SHA Godot 4.7.2 QA

Date 2026-11-10 · PR #72 only · `integration/pve-p0-playable-ui-20261103` · Draft, unmerged.
**No Codex. No SaveService edits. No new gameplay damage/status/range authority.**
Implementation packet code SHA: `310ea002976c1567e21521eb711162b6b3ab9536`. The final exact-SHA review must be taken from the workflow's emitted `metadata.txt`, not from whichever HEAD was seen later.

## Owner visual gates from 3 original concept mockups

1. **Bách Độc Tán Châm** `tmb.skill.poison.doc_cham.active_03.human` — original purple/mint/silver 7-strand **visual** needle fan, real projectile cue + individual impact glints. Source AoE: radius **3** world cells; up to **3** actual hit targets per cast. Seven artwork strands do **not** imply seven hit receipts.
2. **Cổ Vụ Mê Tung** `tmb.skill.poison.co_doc.active_03.human` — poisonous dark-green mist planes, controlled old-gold glints and living gu motes, *inside* world-projected AoE ellipse. No implicit DoT beyond settled V6.3 `status_tick`.
3. **Giải Độc Hộ Tâm** `tmb.skill.poison.duoc_doc.active_02.human` — clean mint-jade stream between actual caster/ally, translucent jade-lotus under the real recipient's **feet**, upward lift glints, committed heal text. **Heal single-target 6 cells**, not cleanse+AoE or a fictional shield.

## What changed in live Godot code

- `combat_lab_arena.gd`: `v4_effective_render_zoom()` 1.65 **only** for explicit 4v8 `TMB_POISON_V4_CINEMATIC=1` capture with requested zoom `1x`. At zoom2/4/6 and in normal Lab/production, existing zoom remains unchanged. Identical lens factor is applied to actor feet world projection and ellipse radii to avoid false AoE circumference. Existing real actor positions untouched.
- `combat_lab.gd`: 4v8 opt-in framing and on-screen explicit `1x FILM LENS = 1.65x` warning; hide original debug string that overlapped the skill name.
- `combat_lab_arena.gd`: poison female actors on opposite sides face their nearest actual living monster using the **verified horizontal two-way mirror**. This is NOT an independently authored 4-direction rig.
- `combat_lab_poison_v4_layers.gd`: V7 fan shower, Cổ Vụ art planes, committed jade under-foot lotus; reuses the four existing, source-verified RGBA textures and deterministic draw primitives. V4 stays opt-in; V3 default and SaveService are untouched.
- Tests updated: `poison_v4_cinematic_contract_test.gd` (4 real heroes stay in frame, 1.65 cinematic zoom, 2-way facing, radius projection); `poison_v4_render_contract_test.gd` (canonical 3 exact IDs, radius/target limit and single-target heal). Existing `poison_v4_swarm_aoe_contract_test.gd`, `poison_v4_max_range_hold_test.gd` and cumulative Godot tests remain required.

## Current render/QA gate

- [Official VFX07 full Godot workflow](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42810913422) was **IN PROGRESS** when this file was authored; source of truth is its final job/log conclusion.
- The workflow requires official SHA-pinned Godot **4.7.2**, strict import, focused+cumulative tests, **11 original Movie Maker** 1280×720 @ 24 FPS recordings, nine native frame captures from the 3 proposed mockups, SHA256 and self-declared exact code SHA.
- Valid artistic review requires actual images/videos, not a success log alone: inspect (a) stage legibility at 1x recorded /2x (b) distinguishable 3 skills (c) canonical target geometry (d) cast/flight/impact/residue and (e) no HP-bar occlusion.
- **Hardware gate:** Windows 10 physical GUI, Intel driver crash, Android touch/FPS/RAM all remain PENDING USER unless measured in their target environment. An Ubuntu xvfb film is not a Windows/Android performance pass.

## Asset gate and scope protection

- Real current Poison cultivator atlas `nu_doc_tu_grok_01` contains 6 animation sheets and **one authored 3/4-right view plus horizontal mirror**. A validated 4-direction final asset has NOT been verified in the live repo. Keep 4v8 actors using present source; don't fabricate a directional sprite or claim the final four-view character has been integrated.
- All effect drawing remains V4 Lab-only (environment flag), no manual authored hit event, no fabricated resource/EXP/HP change, no new sprites swapped into production.
