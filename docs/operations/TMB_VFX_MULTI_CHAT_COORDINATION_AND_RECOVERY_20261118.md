> **OWNER LATEST DIRECTIVE — 18/11/2026: STOP ALL CODEX CLOUD.** The owner explicitly ordered ChatGPT to directly produce VFX and not use Codex Cloud from now on for Tông Môn Bá Đạo. This supersedes all previous sections delegating implementation to Codex. ChatGPT production remains governed by single-writer per school, Art-First V4, Godot 4.7.2, owner ART approval, no rig/GIF by default/PvE/merge. The active FIST14 R6 LAB candidate is directly created by ChatGPT, not Codex; source-art quality remains self-fail and owner pending. See the most recent AGENTS.md. 

> **OWNER OVERRIDE 18/11/2026 — ORIGINAL ART-FIRST V4 RESTORED.** After FIST14 R4 Simple failed its art gate, owner revoked **one static sprite + simple Godot motion as adequate source**, numeric reduced pose budgets, and the "ship ART_FAIL tech candidate" fallback. [Read binding restoration](docs/operations/TMB_VFX_REINSTATE_ART_FIRST_V4_AND_FIST14_R4_REJECTION_20261118.md) and [original V4 SOP](TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md) **before every VFX action**. Earlier sections §10–11 remain as chronology only where they contradict this. Codex is allowed as tool, not as an excuse to bypass illustrated source G2/G3. FIST14 R4 OWNER_REJECTED; preserve its failed history, no merge/PvE, freeze owner-accepted assets.

# TMB VFX — Multi-chat coordinator, work ownership and limit-safe recovery

**Established:** 18 Nov 2026 (UTC+7) · **Repository:** `vuanhtuan161094-byte/TongMonBaDao` · **Branch:** `integration/pve-p0-playable-ui-20261103` · **PR:** #72 Draft.
**Owner request:** One coordinating chat (governance/QA/handoffs) and three production chats (Poison, Fist, Talisman). This document is a durable operational index; new ChatGPT conversations do not automatically inherit ephemeral chat history. All agents MUST re-fetch **live HEAD**, not trust the snapshot SHA below.
**Snapshot baseline at onboarding:** `0d4602c86eb2ad057fecbd5f83d60be1255defc6`. GitHub exact-SHA VFX F LAB showcase TECH PASS `a6557607ebd6245bfd117f4d4dc37c26caafd4b8`, [Actions #44224916665](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44224916665). This was shared-policy/native LAB smoke; it did NOT approve any skill's art, live PvE or physical Android FPS. Never assert all GitHub workflows globally PASS.

## 1. Source of truth and precedence
1. Latest explicit OWNER direction and scope/approval.
2. Live [AGENTS.md](../../AGENTS.md), [Production System V4 / Art-First SOP](TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md), [Art Director](../../.agents/skills/tmb-vfx-art-director/SKILL.md), [Sprite Layer SOP](TMB_VFX_SPRITE_LAYER_PIPELINE_20261114.md), [V4 packet onboarding](vfx_packets/README.md), school-specific catalogues and ledgers.
3. Shared refinements: [cross-school lessons](TMB_VFX_CROSS_SCHOOL_LESSONS_AND_EFFICIENT_WORKFLOW_20261118.md), [status/buff rules A](../design/TMB_VFX_STATUS_BUFF_OVERLAY_RULES_V1_20261118.md), [Art Bible C](TMB_VFX_ART_BIBLE_C_QUALITY_V1_20261118.md). The older cross-school report predates the actual A/C and BDE implementation, so any statement in that report saying the A proposal is *not implemented at all* is stale: **LAB-only pilot exists**, but status art and PvE remain NOT approved.
4. [B/D/E shared LAB pilot and evidence](TMB_VFX_B_D_E_PILOT_20261118.md). Shared sprite layer/budget **cannot** be promoted into Combat V2 without a distinct G8 authorization.
5. Latest exact-SHA committed school handoff and original skill packet. CI checks prove technical conditions, never imply owner visual acceptance.

**No rigs, no GIF by default, no Codex, no new branch, no merge, no unauthorized gameplay/Combat V2/SaveService/V6.3/AI/economy/PvE changes; preserve owner-approved art and all accepted phases.** New image/source production must be first-party/rights-cleared true RGBA with independently authored key poses; real Godot native 1280×720 charge/peak/moving-contact G3.5, G3.6/G3.7, then continuous movie/G7 exact SHA. Don't copy proprietary JX/VLTK assets.

## 2. Four chats and write ownership — one writer per overlapping file
| Chat | School/role | EXCLUSIVE write scope under delegation | READ but DO NOT WRITE without coordinator agreement |
|---|---|---|---|
| COORD | coordination, cross-school status UX, shared LAB renderer/budget, workflow consolidation and proof | This governance file; `AGENTS.md` VFX onboarding pointer only; `godot/labs/combat_lab/vfx_shared_f_pilot/**`; `godot/tests/labs/combat_lab/vfx_shared_f_*.gd`; `.github/workflows/vfx-shared-f-pilot.yml`; common design/policy/docs | Every school's approved assets, school-specific labs/workflows and catalogues |
| POISON | Độc Tu POI series | `godot/labs/combat_lab/poison*/**`, `docs/handoffs/VFX_POISON_CURRENT.md`, school-owned POI source/packets/tests and `vfx-poi*` workflow files | FIST/TALISMANS and shared renderer, status definitions / shared tests / AGENTS |
| FIST | Quyền Tu FIST series | `godot/labs/combat_lab/fist*/**`, `docs/handoffs/VFX_FIST_CURRENT.md`, school-owned FIST source/packets/tests and `vfx-fist*` workflows | POISON/TALISMANS, shared renderer/AGENTS/catalogue |
| TALISMAN | Phù Tu: Phong Ấn Phù PAF, Hỏa Phù HF, Lôi Phù TAL | `godot/labs/combat_lab/talisman*/**`, `docs/handoffs/VFX_TALISMAN_CURRENT.md`, PAF/HF/TAL-specific packets/tests/workflows | POISON/FIST, shared renderer/AGENTS/catalogue |

Owned paths do **not** automatically grant permission to overwrite existing owner-approved asset revisions or all non-VFX files. School-owned `tools/vfx` generators or unique tests must be checked for references before edits; coordinate conflicts on ambiguous shared paths. The coordinator does not silently replace three production authors or make artistic owner decisions. Each agent checks the exact live HEAD and avoids writing to a path another agent is presently editing. This rule is **procedural**, not an enforced GitHub lock.

## 3. Concurrent PR #72 working procedure
- On entry: fetch PR metadata and branch HEAD; inspect school handoff and git diff/recent commits. Verify approved status per exact skill **ID + revision + source SHA + phase** before modifying.
- Work in narrow school-owned paths, one skill/revision at a time. Do not run mass recolor, bulk overwrite or generic renderer edits in a school chat.
- Before committing, re-read branch HEAD. Commit only scoped changes with **fast-forward/optimistic lease**. If HEAD advances, rebase/refresh and confirm the changed files are non-overlapping; NEVER force-push or clobber concurrent changes.
- Keep an immutable source master and native QA proofs for each accepted candidate; 14-day expiring Actions artifacts alone are not durable storage. Distinguish `LAB SOURCE`, `TECH PASS`, `ART SELF PASS`, `OWNER APPROVED/PROVISIONAL/REJECTED/PENDING`, `PVE HOLD`.
- Prefer shared capture/validator if equivalent; school custom contract is still required. New CI must avoid duplicate import/full movie for each small edit; do not delete existing 89+ workflows without parity regression.
- Ask COORD for any change to `AGENTS.md`, shared `vfx_shared_f_pilot`, common status icon/budget scheme, another school's skill, V4 SOP or globally shared scripts. If coordination chat is at limit, **do not edit shared files**; leave a school-local change request in the school handoff.
- Coordinator records cross-school decisions in this single document or the cross-school operating report, not by rewriting each school's handoff while its writer is active.

## 4. Resume after ChatGPT conversation hits a message/context limit
**Source recovery must NOT depend on copying full chat history.** Each school chat maintains exactly one canonical current handoff at:
- [POISON handoff](../handoffs/VFX_POISON_CURRENT.md)
- [FIST handoff](../handoffs/VFX_FIST_CURRENT.md)
- [TALISMAN handoff](../handoffs/VFX_TALISMAN_CURRENT.md)

**Before the current chat ends, or after each meaningful accepted checkpoint**, commit/update that school file with this minimum receipt:
1. Exact HEAD baseline and resulting commit SHA + branch/PR, date; school, canonical skill ID, tier, revision.
2. Owner decision **quoting the relevant decision briefly** and list of **frozen approved phases/assets**. Do not invent owner approval from CI.
3. Current mechanic contract (effect/shape/target cap/timing); three clocks with known vs `RUNTIME_MAPPING_PENDING`.
4. Source master paths + SHA, frames/atlases and generator provenance; status of original source permanence.
5. G3.5/3.6/3.7 and motion/contact/decoy evidence; native video/actions/artifact link and retention or durable proof; exact-SHA CI result.
6. Failures and remaining art debts; next **single** action and exactly which paths are allowed to change.
7. `TECH`, `ART`, `OWNER`, `PVE`, `ANDROID` gates explicitly; unsatisfied gates stay HOLD.
8. File ownership/conflict warnings. If a commit failed, state **NOT_COMMITTED** and provide enough details to reconstruct; never claim the branch changed.

If the agent runs out of context abruptly **before** handing off: new chat reads live HEAD, the last school handoff and latest school-specific commits/packets and reconstructs a conservative status; all unverified approvals are PENDING. The GitHub state, not the old assistant assertion, wins.

### Minimal recovery prompt for a new coordinator chat
> Tiếp quản ĐIỀU PHỐI VFX Tông Môn Bá Đạo. Kiểm tra HEAD mới nhất của Draft PR #72, nhánh `integration/pve-p0-playable-ui-20261103`; đọc `AGENTS.md`, `docs/operations/TMB_VFX_MULTI_CHAT_COORDINATION_AND_RECOVERY_20261118.md`, ba handoff `docs/handoffs/VFX_{POISON,FIST,TALISMAN}_CURRENT.md`, bộ A/C/BDE, GitHub Actions exact-SHA và các commit mới. Không lấy chat cũ làm bằng chứng. Lập bảng status của ba môn phái + xung đột write path + QA pending; tiếp tục điều phối, tuyệt đối không tự duyệt mỹ thuật, không đụng gameplay/merge.

### Minimal recovery prompt for a school chat
> Tiếp quản VFX [POISON/FIST/TALISMAN] từ GitHub thật: đọc `AGENTS.md`, `docs/operations/TMB_VFX_MULTI_CHAT_COORDINATION_AND_RECOVERY_20261118.md`, file `docs/handoffs/VFX_[SCHOOL]_CURRENT.md`, V4 SOP, art skill, current school ledger, latest owner packet/revision, HEAD của Draft PR #72. Tái xác minh exact-SHA/owner approved, chỉ sửa file school-owned. Tiếp tục **một skill đang mở** từ action tiếp theo của handoff; G3.5 trước phim dài; cập nhật handoff và commit trước khi kết thúc; nếu thiếu bằng chứng phải ghi PENDING/NOT_EXECUTED.

## 5. Coordination status on establishment (not global art approval)
| Workstream | Verified scope | Pending |
|---|---|---|
| A status UI vocabulary | Rules document exists | Art icon owner decision, full live Combat V2 mapping |
| C cross-school art | Art Bible/checklist exists | Owner approves each individual new sprite/animation |
| B shared renderer | LAB policy/sprite native smoke TECH PASS SHA `a6557607` | Exact skill-parity evaluation and G8 permission |
| D shared QA | Focused contract/stress CI `#44224916665` PASS | Incremental legacy workflow consolidation with equivalence |
| E stress | 70 synthetic actors, 218 visual cues **policy test** PASS | Physical Android 6v8 and 30+40 FPS/GPU benchmark |
| POISON/FIST/TALISMAN | Existing skill ledgers, school reports, approved and provisional versions | Each school chat to reconcile next actual skill/revision and update own handoff |

**Handoff rule:** No production chat needs permission again just to start a NEW school-owned LAB revision within its assigned scope; it does require separate owner approval for art acceptance and PvE integration. Do not infer approval to replace any owner-approved clip or skill asset.

## 6. School entry paths
- POISON: `docs/operations/TMB_VFX_AREA_PRODUCTION_REPORT_AND_HANDOFF_20261118.md`, `docs/operations/TMB_VFX_AREA_HANDOFF_INDEX_20261118.json`, `docs/operations/vfx_school_ledgers/01_poison_183.csv`.
- FIST: `docs/operations/VFX_FIST_SCHOOL_CONSOLIDATED_HANDOFF_20261118.md`, `docs/operations/TMB_VFX_FIST_SCHOOL_PLAYBOOK_20261114.md`, `docs/operations/vfx_school_ledgers/05_fist_183.csv`.
- TALISMAN: `docs/operations/TMB_VFX_TALISMAN_PLAYBOOK_20261114.md`, `docs/operations/vfx_school_ledgers/02_talisman_183.csv`, `docs/handoffs/VFX_TALISMAN_TAL02_TAL03_NEXT_CHAT_20261114.md` (historical, confirm newest packet).

**New chat must never infer progress from enumeration.** POI01–POI20 are production milestones, not 20 unique approved skills; 183 ledger rows per school are not 183 art-approved skills; technical PASS is not visual acceptance.

## 7. Shared V4 Godot execution — no repeated school harnesses

As of exact-SHA `3fe327ec858404d2965235556c9a609549f82b9f`, **Actions [#44230153048](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44230153048) SUCCESS**: common school V4 packet runner `tools/qa/run_vfx_shared_packet.py` + reusable `.github/workflows/vfx-shared-skill.yml` ran POI19 R3 119-frame genuine Godot G3.5, original atlas, actual focused moving-target test, and V4 evidence TECH PASS. Artifact [#14393914591](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44230153048/artifacts/14393914591) (14-day expiration). See [runner V1 instructions](TMB_VFX_SHARED_SKILL_RUNNER_V1_20261118.md).

**Coordinator policy:** One canonical Godot project; do not create a new engine project or copy a 100-line CI recipe per skill. School supplies source sprite master, atlas, V4 JSON, unique Godot scene/script, focused target/motion tests; common runner supplies strict Godot, video, screenshot and manifest. G3.5 short movie early; G5 full only after actual art self-review. Legacy school workflows with custom generation/strict provenance remain until equivalent outputs and art safety are verified. It is a new reusable option, not automatic live integration and not a blanket PASS.

Current school handoff files may still be BOOTSTRAP while agents are working; only committed checkpoints and code are visible to this coordinator. Do not infer a chat's progress or owner acceptance from absent handoff updates.

## 8. COORD 2026-11-18 — Every school milestone MUST end with actionable options

**OWNER DIRECTIVE:** After every meaningful VFX production checkpoint/revision, each school chat must present **3–4 next-step options** to the owner in its final chat response. **The first option is the recommended one** with explicit reason and gate dependence. This is a response/decision convention, **not an extra QA gate**; do not create another per-skill workflow, renderer or SOP solely to format choices.

Before the options, **show actual artifact/commit SHA and exact-SHA QA scope** plus a one-line status `SOURCE | G3.5 | G3.6/G3.7 | G5 | OWNER | PVE`. Link the native artifact only when it exists. Report the latest observed CI conclusion `SUCCESS/FAILURE/RUNNING/NOT_RUN`, not cached prose. Clearly distinguish source-committed versus master only local/CI artifact; state master permanence and current gate blocker.

**Format (adapt to the school and gate, in Vietnamese):**
- **A — [RECOMMENDED] Repair/finish the CURRENT skill's next failed/unverified gate**, stating exact revision and file/phase that can change (for example: packet schema → CI; isolated RGBA master → G3.5; G3.5 art FAIL → rework same phase, not G5).
- **B — Review/compare proof for the CURRENT skill** only if real G3.5 native material exists; else offer targeted style/reference/contract comparison without implying proof exists.
- **C — Preserve/freeze CURRENT revision and switch to a clearly named NEXT skill** only with owner's explicit choice, after handoff ledger updated and unfinished gates labeled pending; no silent skip of art debt.
- **D — Optional focused audit / owner-decision reconciliation** when a real conflict exists; use no filler options or unrelated tasks.

**Decision behavior:** Finishing a requested scoped change does **not** imply permission to start a different skill. Do not ask for choice prematurely in the middle of technical debugging; fix the known self-owned schema/CI defect as part of the current task and present options at the actual delivery checkpoint. Never gate ordinary bug fixing on repetitive confirmation. Owner may choose by replying simply `A`, `B`, `C` or `D`. Always use next-skill ID, source/target file paths and current evidence, not generic `continue?`.

**Current cross-school coordination review on 18 Nov 2026 (historic receipt, recheck current HEAD & CI):**
- **POISON POI18 R3:** initial commit `f7a7e13df80a8bc39d897dfcf276af84aebd9781`, [Actions #44230593321](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44230593321) **FAILURE at V4 packet**, so G3.5 **NOT_EXECUTED** on that exact SHA. Two school-owned `docs/operations/vfx_packets/POI18_R3_V4_PREFLIGHT.json` metadata fields must use the **existing validator enum**, not invent a new permission: `provenance.master_quality_status = MANUAL_ART_REVIEW_REQUIRED`, `gate_status.art = MANUAL_ART_REVIEW_REQUIRED`. Other states `owner=OWNER_VISUAL_PENDING`, `live=PVE_INTEGRATION_HOLD`, `device=PHYSICAL_QA_PENDING` remain unchanged. **Do not alter global validator or promote owner approval to avoid failure.** POI school owns the patch and CI rerun.
- **FIST FIST14 R3:** [handoff](../handoffs/VFX_FIST_CURRENT.md) honestly says true first-party 1774×887 RGBA master is **LOCAL NOT COMMITTED** and no R3 native proof. The source is at risk of being lost on chat/context expiry. School must preserve the actual approved-rights source bytes and provenance in its owned asset path before generating independent keyframes; if source transport unavailable state `SOURCE_TRANSFER_BLOCKED`, do not invent source or substitute a flat code silhouette. R2 art remains art-failed, R10C/R7 provisional versions frozen. FIST09 owner revision remains to be reconciled separately.
- **TALISMAN PAF05 R5F:** [Actions #44230468688](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44230468688) **SUCCESS technically**, but R5F charge `G3.5 ART_SELF_FAIL` (three tiny lightning forks rather than readable wind talisman). Keep owner-provisional R5E and all inherited phases unchanged. **Rework only R5F charge, G3.5 STOP before any long G5 movie.** Remove irrelevant/unrelated internet image references from evidence; **only actual Godot Actions images and MP4 with SHA are native proofs**.

**Writing permissions:** COORD owns THIS policy and `AGENTS.md` pointer; school chats own only their handoff, packet, VFX scene/source/tests/workflows. Do not alter another writer's school files merely to clear a gate, even when root cause is known. New chats load the latest policy, not cached conversation. Never auto-merge.

## 9. 2026-11-18 native art review — actual Godot frames, not just CI

**Owner observed that the recently generated VFX are visually poor.** On 2026-11-18 the coordinator downloaded **actual source-specific GitHub Actions native screenshots/MP4 artifacts** for the three recently active skills (1280×720 Godot 4.7.2 Compatibility stage), viewed their charge/peak/contact phases at true-size and compared known production-revision provenance. This is a **coordinator qualitative ART SELF REVIEW + owner general negative feedback**, **NOT a per-revision owner final rejection/approval**, and does not overwrite school-specific handoffs. **TECH PASS ≠ ART PASS**. Preserve old owner-approved and provisional source art.

| School/revision | Native exact-SHA evidence | What visibly fails | Revised school direction (within school files only) |
|---|---|---|---|
| **POISON POI18 R3.1** | [run #44240320257](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44240320257), [native artifact #14399411426](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44240320257/artifacts/14399411426), source `f8faec3d`; 1.8s | At peak t0.98 the gu is **two thin turquoise wave strokes** with a faint bluish tail, not a distinguishable living jade/ivory spirit-gu seed. At contact t1.48 a small diffuse cyan bloom covers the selected enemy but lacks a recognizable Liên Tâm bind; little source-to-target material continuity. | Re-author **R3.1 flight head + 16 independent poses only**, strong identifiable jade-gold seed/body/tip and 1–3 trailing living-silk wisps; local additive core and meaningful target wrap at real contact. Keep R2C's frozen 8+12+12 poses, other POI skills and selected target cap unchanged. |
| **FIST FIST14 R3** | [run #44242444811](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44242444811), [native artifact #14401645271](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44242444811/artifacts/14401645271), source `8f663591`; 1.8s | At peak t0.65 a single **red fist-icon composite** appears to slide horizontally with repetitive thin red scribbles; source actor remains visually idle and contact has weak spatial force/reaction. The source provenance confirms 36 phase-specific composites use **one painterly closed-fist master**, not 36 independently illustrated anatomical/foreshortened fist poses. | Do NOT merely add 30 more decorative composites. Draw **separately authored 3–5 major fist silhouettes** for anticipation, compressed release, oblique thrust, compression/impact; morph/repaint between true changed shapes, localized white-hot hit flash, particles only supporting material. Because canonical `projectile_speed=0`, no implied real homing projectile/extra hits. Preserve R2 and other provisional FIST masters. |
| **TALISMAN PAF05 R5F** | [run #44240801625](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44240801625), [native artifact #14399985321](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44240801625/artifacts/14399985321), source `69ca6c74`; 1.7s | At charge .28/.56 the gold `風` is now readable, but it appears as an **oversized flat stand-alone sign/glyph** next to the caster, bordered by weak teal curved ribbons. At peak/contact t1.16/1.49, several repeated golden marks over three monsters look like HUD labels, not wind seals organically receiving a cast. One dark-stage visibility test passing does not establish compelling ceremonial silk/ink material, varied backgrounds or animation. | Keep R5E provisional **entirely unchanged**. For the R5F charge variant, integrate `風` into distinct textured ink/paper/wind-silk mass and a rising/folding talisman flow, not larger block text or neon rings; use selective golden-white hot core and local billowing wisps. Keep 3 actual target contacts and 7s state. Run bright/dark 1× and G3.7 no-HUD semantic review before G5. |

### Why "rendered 60 FPS" still looks cheap
1. **A central source image is not a full skill:** one static anatomical fist or one plain font glyph + 12/36 scaled/moved glow frames gives a moving sticker. Unique PNG hashes and `ART_SELF_PASS` scores cannot change this fact.
2. **FX never takes on convincing spatial causality:** caster gesture/hand charge, legible flight/force, true target contact and small residual status must read as ONE action. No simulated Combat V2 hit or hidden fake projectile is allowed.
3. **Missing material hierarchy:** soft pigmented RGBA body (MIX), small high-intensity local white core (ADD), soft emissive halo, restrained particles, properly fading contact. Pure outline strokes or giant bright word are insufficient.
4. **No comparative art target at same scale:** all three native checks use a convenient dim LAB scene, not a side-by-side approved POI02/POI03/HF02 source or a bright game map. Every candidate must first pass readability at real 1280×720 1× with/without name HUD and static + WALK target.
5. **The engine doesn't draw good artwork for us:** Godot's AnimationPlayer, AnimatedSprite2D, GPUParticles2D/CPUParticles2D, CanvasItemMaterial additive and CanvasItem shaders are tools for timing/compositing; they **cannot replace authentic independent central hero silhouettes** or skill-specific direction.

### Godot official 2D VFX path (do not create a new engine or conflicting SOP)
- [Godot 2D particles](https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html): GPUParticles2D, CPUParticles2D, texture flipbooks and particle-process material; use SMALL supporting sparks, mana wisps, dust, contact breakup, not entire hero silhouette.
- [Godot 2D sprite animation](https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html) and [AnimationPlayer](https://docs.godotengine.org/en/stable/tutorials/animation/introduction.html): stage the separately authored transparent poses, actor-local anchors, reveal/fade, anticipation/release/contact; **animation of VFX nodes is NOT skeletal rigging**.
- [Godot CanvasItem shader](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html) and [2D lights](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html): controlled local additive bloom/tint/flow rather than heavy global overexposure. Compatibility renderer must be tested explicitly on Android; its glow implementation differs from Forward+/Mobile.
- [Official Godot 2D particles demo](https://github.com/godotengine/godot-demo-projects/tree/master/2d/particles): learn nodes/texture animation, not copy gameplay art blindly.
- [GDQuest: Juicing up your game attacks](https://www.gdquest.com/library/juicy_attack/): anticipation, directional smear, impact FX, timed particles, visual response (take ONLY view-only cues; don't modify Combat V2 hit timing/HP/knockback). [GDQuest Godot 4 VFX examples](https://github.com/gdquest-demos/godot-4-VFX-assets): code MIT, **art CC-BY-NC-SA**, so their asset textures should NOT be shipped in a commercial TMB build. Study the technique; draw first-party art.

### Coordinator action, not new QA bureaucracy
- **Art-first STOP on these unapproved revisions.** No long G5 or PvE while main silhouette/semantic visual is not acceptable. Do not expand mass production or change three school files from this coordinator.
- Each specialist revises **one real failing phase** and compares at 1× to an already accepted school reference: central painted source first, independent changed poses, then native charge/peak/contact, then optional particles/shaders, THEN expensive full CI/crowd.
- Do not treat `AGENTS.md`, V4 packet validator or existing automated checks as proof of cinematic quality. The difference is a human visual decision on real native frames. No extra mandatory file type or test command should be imposed unless it solves a specific gap.
- **Most urgent shared lesson:** after source-level 1× silhouette still looks like generic waves, letters or slide-on fist, return to primary art design, NOT to more frames, more moving streaks, shader glow, or bigger G5 movie. One writer per school; three specialist chats must read current GitHub HEAD and these observed defects.

## 10. New owner direction: simplified JX / Kiếm Thế visual style

Owner requires **a drastic reduction in VFX visual complexity** without losing skill recognition, favoring compact bright JX/Kiếm Thế-Mobile-like contact visuals over ribbons/glow/oversized glyphs and 16–40 mandatory frames. See **[authoritative simple visual brief](TMB_VFX_JX_SIMPLE_STYLE_V1_20261118.md)**. Only newly authorized work/reworks; **freeze all old owner-approved or provisional source**, and keep 1× G3.5, exact-SHA verification, owner art decision, no gameplay change. Default one distinctive hero sprite + one deliberate motion + one impact; use a minimal small particle/trail as needed. Codex could help coding/CI **only after separate owner authorization**; existing no-Codex workflow still applies. It cannot substitute authored sprite source or visual review. This supersedes any coordinator guidance that suggested every skill must be a large independently built Hybrid VFX project; V4 technical contract and G0–G8 safeguards remain.

## 11. VFX coding ownership switch to Codex (owner directive, 18/11/2026)

Owner explicitly changed assignment: **Codex should do the VFX technical production now**. Supersedes all blanket "no Codex" statements only for owner-authorized VFX tasks. Coordinator stays source-of-truth for visual quality reviews and handoff, the three prior school chats should stop making further simultaneous VFX writes after seeing this update. [Codex task handoff](TMB_CODEX_VFX_SIMPLE_HANDOFF_20261118.md) details the first single-school pilot (**FIST14 simple candidate**) and exact-SHA, source, technical and art gates.

No Codex Cloud task has yet been started merely by this repository change; a Codex environment/session must be started through the supported Codex UI. Stop the first task after its visual artifact for owner review; don't autonomously rewrite 87 POI main VFX or merge PR #72. Keep previously approved/provisional sources frozen, canonical V4 contracts, other schools, PvE and gameplay untouched.
