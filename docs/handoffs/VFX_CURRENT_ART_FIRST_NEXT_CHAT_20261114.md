# VFX CURRENT HANDOFF — ART-FIRST / 2026-11-14

## Absolute owner rule
ONE artistic original skill at a time; rejected batch VFX art is NOT the source style. Owner wants Source VL-level art. New chat must automatically read AGENTS.md and docs/operations/TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md before acting. Existing three owner-approved Poison Human LABs are LOCKED. Never switch to rig, Codex, a new branch/merge or V6.3/PvE integration without direct new instructions.

## Current in-progress skill
**Tán Cổ Diễn Nhiễm** `tmb.skill.poison.co_doc.active_04.human`. Official catalogue: Độc Tu/Cổ Độc active, wood, effect=poison, shape=circle, radius=2.5, target_limit=3, cast_time=0.55, cooldown=12, range=7, duration=7, stacks=1. Content data is READ ONLY; actual Combat V2 owns effects, hits, target selection and ticks.
Art direction: **a bone-jade chitin GU seed/cocoon explodes in 12 authored sequential drawn poses, scattering small spore-gu spirits toward three targets with fragile infection filaments and localized sigils**, distinguish absolutely from Cổ Vụ Mê Tung smoke and Phụ Cốt Cổ single-target marking. Correct native-size material, transparent alpha, no repeated batch motifs. 5 phases, 8+ native frame inspections and real 1280x720 MP4.

## Baselines and next action
Official branch: integration/pve-p0-playable-ui-20261103, PR #72 Draft. Re-check HEAD; do not rely on old SHA. Stage A dependency reconstruction workflow pattern in .github/workflows/vfx-poi-04-co-vu-me-tung.yml. Approved scenes: poison02/xa_anh_source_vl_remake, poison03/fu_cot_co, poison04/co_vu_me_tung. They must not be changed. POI05 Lab native Godot QA PASS on tested SHA 0d7e603ce5cfb087253d81c7873fbe4959855899, Actions run #43561162687; 1280x720 4.10s MP4 plus 14 native frames, owner visual still PENDING. Existing POI05 scene and original 12-frame cocoon/4-frame beetle must not be silently replaced. Do not move on until explicit owner decision. Stop prior generic batch R4 production, but retain ID manifest and read-only source audit.

## QA requirements
Read the installed tmb-vfx-art-director skill/reference QA, strict Godot 4.7.2 Compatibility import+parse+focused tests with exact source SHA. Export original Godot 1280x720 fixed-frame movie, optimized MP4, GIF fallback/ZIP, 8+ phase screenshots, inspect the actual frames for obscured characters, no casting fake poison. Record verdict distinct as GODOT_FOCUSED_PASS / OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD. No promise of background work.

## How to resume
User can write only: Tiếp tục VFX Tông Môn Bá Đạo PR #72. The repo's AGENTS.md and this handoff contain all mandatory instructions. If agent reports a different production flow, READ THIS AND SOP V3; it is not the owner request. SOP progress must be updated when producing POI05 results.