# CURRENT VFX HANDOFF — ART-FIRST / POI05 TÁN CỔ DIỄN NHIỄM R10

**Latest user direction:** beautiful genuine Xianxia/tu tiên VFX, one independently authored skill at a time, not mass template art. User rejected POI05 R5 floral chrysalis and approved only the first three separate Poison Human LAB effects. Read `AGENTS.md`, `docs/operations/TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md` and actual PR #72 HEAD before any new work. Do not rig or use Codex, no new branch/merge and no PvE/V6.3 enable.

## Current skill and evidence
Skill ID `tmb.skill.poison.co_doc.active_04.human` (**Tán Cổ Diễn Nhiễm**), source metadata: poison/circle, radius **2.5**, cap **3**, cast **0.55s**, range 7, cooldown 12, 1 poison stack and duration 7 in catalogue. The VFX-only LAB **does not simulate or apply real poison, damage or targeting**.

Current improved implementation **R10**: Godot scene `res://labs/combat_lab/poison05/remake_r6/tan_co_dien_nhiem_r6.tscn`, original R6 directory is retained for compatibility but script splash now clearly labels R10. Original art: 12 gu segmented living spectral projectile poses (512), six cracked seed poses (512), six infestation marks (320), **8 newly authored jade gu moth swarm poses (384)**, original 1280x720 Tu Tiên valley backdrop. No rig. First ONE spirit GU travels and scatters into three moving gu moth swarms and smaller motes, compact chest-targeted parasite filaments and brief aura. All sprite sources stored on PR.

**Exact tested R10 code SHA `6c8f6f0df48ef27f0c763c33828eda5437da036d`**, official [Godot 4.7.2 Actions run #43569372244](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43569372244) SUCCESS. Strict import, parse, focused `VFX_POI05_R6_RESULT=PASS failures=0 gu=12 seed=6 mark=6 swarm=8`. Actual `--write-movie` 1280×720 native MP4 **4.20s/252 frames fixed encoded 60fps**, 14 screenshots, GIF & checksums archived in artifact `vfx-poi05-r6-6c8f6f0df48ef27f0c763c33828eda5437da036d` ID **14104070538**. NOT measured physical Android/Windows FPS.

## Actual art review and new chat continuity
R8 phase (native images) used three long centipedes and was too similar to serpent; R9 replaced with 8-pose jade moths but obstructed target faces. R10 shrinks flight GU, moves their ending positions 60–76px to either side of actors and draws short wispy links into chest, adds strict test that moth never arrives over victim face. Genuine R10 PNG review: 0.44, 0.96, 1.18, 1.50, 1.65, 1.90, 2.16, 2.50, 2.82, 3.24 and 3.60. Target faces remain readable and multi-target infestation is clearer. Cosmetic quality still subjective; **R10 currently OWNER_VISUAL_PENDING**, NOT published Source-VL-quality art. If user rejects, rework same skill, do not move to another.

State: `GODOT_FOCUSED_PASS / OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD / PHYSICAL_QA_PENDING`. The 3 earlier approved LABs poison02/03/04 unchanged; R5 archived. Never mark ledger approved without user approval. Current PR #72 Draft branch `integration/pve-p0-playable-ui-20261103` and live head must be checked on re-entry.

## How a new chat resumes
The user can say *Tiếp tục VFX Tông Môn Bá Đạo PR #72*. Read source SOP and this file automatically, check GitHub Actions exact run and original MP4. Do not claim Photoshop/concept image is gameplay footage, do not promise later asynchronous deliveries.
