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
