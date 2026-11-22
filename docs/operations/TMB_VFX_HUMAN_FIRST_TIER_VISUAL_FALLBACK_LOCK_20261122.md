# OWNER DECISION — HUMAN-FIRST VFX; TEMPORARY TIÊN/THẦN VISUAL FALLBACK (22/11/2026)

**Scope:** Tông Môn Bá Đạo, 12 môn phái / 36 nhánh. This is a **production-scope decision**, NOT a replacement SOP. Latest owner instruction (22/11/2026): **"Làm nhân trc. Tiên và thần thì cứ lấy của nhân. Khi nào có thời gian thì update."** The owner also provisionally accepted the FIST14 R11 native LAB ("tạm được") and locked the direct GitHub → Actions Godot workflow.

**Priority and fallback contract**

1. **Human first:** make or complete the **Nhân / `human`** visual source for each eligible active/cast skill, respecting existing accepted versions and the live skill catalogue. Start from the established 12-school Wave 1 queue in `TMB_VFX_12_SCHOOL_BATCH_PRODUCTION_LOCK_20261119.md`, then expand progressively by branch and skill. Do not generate effects for passive/event skills without an actual visual event.
2. **Tiên / `immortal`, Thần / `divine` TEMPORARILY REUSE THE CORRESPONDING HUMAN VISUAL SOURCE**, if that source exists and its semantic motif can legitimately depict the higher-tier skill. Implement as an explicit **visual alias/fallback**, never as a copied/repainted false independent illustration. Keep the original per-tier **canonical skill ID, effect, range, shape, target limits, targeting, cast/cooldown, damage/mark semantics, gameplay receipts and SaveService unchanged**. No sprite-scale/damage/alpha multiplier invented just to pretend to be Tiên/Thần.
3. If tiers have different gameplay mechanics, VFX binding must honor **each tier's real event anchors/targets/duration**. A Human visual cannot imply extra hits, invented projectiles/status or an inconsistent AoE. Report `VISUAL_FALLBACK_HUMAN_INCOMPATIBLE` and HOLD that tier rather than create a misleading gameplay cue. A missing Human source means `VISUAL_SOURCE_PENDING`, not a completed tier.
4. Track status separately: `HUMAN_G3_SOURCE / HUMAN_G35_NATIVE / HUMAN_OWNER_ART`; `IMMORTAL_VISUAL_FALLBACK_HUMAN_TEMPORARY`; `DIVINE_VISUAL_FALLBACK_HUMAN_TEMPORARY`; `IMMORTAL_OWNER_ART_PENDING`; `DIVINE_OWNER_ART_PENDING`. **Human approval NEVER becomes Tiên/Thần independent art approval.** Keep explicit per-tier fallback provenance and a replacement queue. Later differentiated art is a new owner-requested revision; keep existing accepted source immutable and remove aliases only after dedicated review.
5. This instruction does **not** authorize runtime/PvE G8 wiring. Production remains isolated VFX LAB/Web Review until owner separately authorizes PvE integration. Do not alter any skill catalogue, Combat V2/V6.3 flags, SaveService, AI, economy, actor animation or canonical balance merely to make VFX fallback work.

**Unchanged mandatory production process**

- Read current PR #72 HEAD and `AGENTS.md` first; use Art-First V4 (G0 canonical/3 clocks → G1 rights-cleared motion study → G2 distinctive school/branch storyboard → **G3 truly illustrated RGBA master + changing frame-by-frame source poses, dark/light at in-game 1×, HARD STOP on art FAIL** → G3.5 actual Godot 4.7.2 charge/peak/moving monster contact → G3.6 contrast → G3.7 semantic unlabeled → G4–G7 focused motion/performance/CI exact SHA → owner review → G8 by **separate express authorization**).
- Preserve POI06 R11, POI19 R3, POI15 R1B, HF02 R6, FIST14 R11 and other accepted/provisional art **at its recorded approval scope**. FIST14 R11: **original GIF visual accepted**; 7.5s native LAB technical proof on [Actions #44980449471](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44980449471) exact SHA `b30abcc8f6ae12527be9cedf08ac21d91fe6bc94`; owner said **"tạm được"**, not final PvE approval. Still uses Nữ Độc Tu stand-in caster, real monster WALK. Never call its stand-in a verified Quyền Tu actor.
- **Direct ChatGPT → GitHub PR #72 Draft → GitHub Actions Godot 4.7.2**, no Codex Cloud, no rig, no merge, no false movie/native PASS; keep exact source and revision as durable repository files. Review all actual eligible skill candidates on the **one** `/vfx/` Pages route, and require Chromium actor+monster pixel gate before declaring Web Review functional. Native MP4 is for initial/important checkpoints, not default repeated output every small tweak. On owner request provide native movie/GIF as a review aid.
- Each school/writer owns its subtree; do not overwrite concurrently edited shared renderer, shared workflow, global catalogue or school handoff without HEAD recheck/coordination. Never auto-mark ART PASS from CI TECH PASS.
- At handoff report per skill: canonical ID, school/branch/tier, original art provenance and tier-fallback source ID, G3 source grade, G3.5 native run/SHA, G3.6/3.7, Web pixel gate, owner decision, `PVE_HOLD`, and next actual skill. No fake “all 12 done.”

**Binding documents (unchanged):**

- `AGENTS.md`
- `docs/operations/TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md`
- `docs/operations/TMB_VFX_SPRITE_LAYER_PIPELINE_20261114.md`
- `docs/operations/TMB_VFX_12_SCHOOL_BATCH_PRODUCTION_LOCK_20261119.md`
- `docs/handoffs/TMB_VFX_ALL_SCHOOLS_NEXT_CHAT_20261119.md`
- `docs/operations/TMB_VFX_WEB_REVIEW_FIXED_WORKFLOW_V1_20261119.md`
- `docs/operations/TMB_VFX_CROSS_SCHOOL_LESSONS_AND_EFFICIENT_WORKFLOW_20261118.md`
- `docs/operations/TMB_VFX_MULTI_CHAT_COORDINATION_AND_RECOVERY_20261118.md`

**No gameplay, Save or PvE changes were made by this decision.** Next action: begin Human-tier Wave 1 art source work one school/skill at a time with fresh contract, direct GitHub commits, selective native and single Web Review.
