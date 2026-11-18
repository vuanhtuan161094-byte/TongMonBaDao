## CHỐT QUY TRÌNH VFX TOÀN DỰ ÁN — OWNER LOCK 19/11/2026

**ÁP DỤNG BẮT BUỘC cho TẤT CẢ chat VFX (POISON/FIST/TALISMAN và 12 môn phái/36 nhánh).** Quy trình duy nhất: **Art-First Production System V4** (SOP V3 và addendum V4/V4.3), Art Director Skill, Sprite Layer Pipeline; bản thao tác nhanh **§12** trong [cross-school workflow](docs/operations/TMB_VFX_CROSS_SCHOOL_LESSONS_AND_EFFICIENT_WORKFLOW_20261118.md). Không tạo SOP cạnh tranh; school playbook chỉ chuyên biệt hóa hình tượng/hợp đồng, không được giảm gate.

**THỨ TỰ CỐ ĐỊNH:** G0 canonical/HEAD/3 clocks → G1 tham khảo clip cùng loại skill/quyền nguồn → G2 semantic storyboard riêng → **G3 master tranh RGBA chất lượng cao + pose biến đổi frame-by-frame thật, lưu source bền vững GitHub; xem contact sheet tại 1× (script `tools/vfx/prepare_g3_source_review.py`)**. **G3 ART FAIL = STOP**, không chạy Godot/Actions, không dùng code Bézier/vector neon/poster crop làm hình chủ đạo. G3 đạt → **G3.5 native Godot 4.7.2 / 1280×720 / charge-peak-contact trên quái WALK**, G3.6 tương phản sáng/tối, G3.7 hiểu nghĩa skill không HUD → G4/G5 motion liên tục ngắn, G6/G7 kỹ thuật exact-SHA → owner duyệt đúng revision → G8/PvE chỉ khi có lệnh riêng. **TECH PASS ≠ ART PASS; không rig/GIF mặc định, không Codex Cloud, không merge; giữ tất cả art đã duyệt.** Reuse renderer/hit sparks/particles/shaders có kiểm license, không reuse hình tượng skill sai phái.

**Mẫu owner-approved để đối chiếu chất lượng:** **Độc Tu POI15 Hóa Độc Tán R1B**, owner nhận xét “ok đẹp t thích. tiếp tục skill tiếp theo”, native Godot 7.5s 1280×720 [run #43999563772](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43999563772), exact SHA `1b40811248fcaca9b33a5e4cbc35e8b03e2ca9b5`, [artifact](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43999563772/artifacts/14292200693), quyết định [POI15 record](docs/operations/VFX_POI15_HOA_DOC_TAN_R1_20261117.md). Đây là **benchmark chất liệu sáng, nhịp, trạng thái và tan**, KHÔNG copy hình Độc Tu sang các phái khác. Video artifact có thể hết hạn; nguồn/hồ sơ gốc giữ trong repo.

Mỗi chat VFX khi vào việc phải đọc quyết định này và §12; kết quả ghi `G3_ART_SOURCE`, `G3.5_NATIVE`, `OWNER_ART`, `PVE_HOLD` tách biệt theo exact revision; chỉ một writer cho mỗi path được giao. Các chỉ thị Codex/one-sprite/QA-first cũ mâu thuẫn là LỊCH SỬ, không còn hiệu lực.

---

## OWNER OVERRIDE 2026-11-18 — NO CODEX CLOUD; CHATGPT DIRECT VFX IMPLEMENTATION

**19/11/2026 repo-backed VFX execution optimization:** Keep Art-First V4 unchanged. Before engine/CI, inspect real original painted G3 source at intended 1× via `tools/vfx/prepare_g3_source_review.py` (source-only, **not** native Godot proof); if G3 art self-fails, STOP. Reuse existing Godot renderer and selective MIT techniques (particles/contact/flash) only as supporting layers. FIST14 R6 source changes no longer auto-trigger costly shared native workflows; manual exact-SHA workflow remains. [Read repo/license comparison and fast path](docs/operations/TMB_VFX_CROSS_SCHOOL_LESSONS_AND_EFFICIENT_WORKFLOW_20261118.md#11-19112026--bổ-sung-thực-hành-từ-github-không-thêm-sop-mới). No Codex Cloud, no rig/GIF default, no gameplay/PvE/merge.

**VFX PROCESS ENFORCEMENT (18/11/2026, R6 failure audit):** If VFX source has already been assessed `G3_ART_SELF_FAIL`, **STOP before scene/movie/Actions**, even if first-party PNGs are programmatically generated and their bytes are distinct. The original Art-First V4 is unchanged: start again at actual high-quality illustrated energy source and phase-specific source poses, examine at in-game 1× with actor/target before Godot QA, do not mislabel a Bezier/line+blur prototype as a finished core art source, and do not replace this with posters. For specific evidence see [FIST14 R6 root-cause audit](docs/operations/TMB_FIST14_R6_ART_FAILURE_ROOT_CAUSE_20261118.md). Do not create a new SOP or auto-certify art from CI; minimal technical verification only **after** source visual preflight passes. No Codex Cloud, no rig, PvE HOLD, no merge.



The owner explicitly revoked **all use of Codex Cloud from now on** for Tông Môn Bá Đạo and requested ChatGPT to **directly implement VFX**. This latest owner instruction **supersedes** all prior `Codex primary implementer`, Codex Cloud setup/handoff and execution mandates in this repository. **DO NOT launch, assign, recommend or rely on Codex Cloud** for any future task without a new explicit owner authorization. Keep historical Codex commits/QA provenance intact; **this is a workflow ownership correction, not a git reset**. ChatGPT specialist production and coordination sessions may implement VFX directly in their owned directories, preserving single-writer/file ownership and checking live HEAD before every write.

The original [Art-First V4](docs/operations/TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md), Art Director, real source artwork/pose quality, true Godot 4.7.2 native 1280×720 G3.5/3.6/3.7, and independent owner art sign-off remain binding. Owner requires **translucent luminous skill energy**, light-core + colored semi-transparent body, dynamic directional impact, not opaque fists/banners/posters. FIST14 R6 work is ChatGPT-managed, see [R6 luminous brief](docs/operations/FIST14_R6_LIGHT_ENERGY_ART_DIRECTION_20261118.md). No rig, no default GIF, no gameplay/Combat V2/SaveService edits, no merge. Previously rejected R4 and unapproved R5 kept frozen.

---

## OWNER LOCK 18/11/2026 — FIST14 MUST BE TRANSLUCENT LUMINOUS ENERGY, NOT RED SOLID FIST

The owner **reconfirmed** the established martial VFX look: **energy of light dynamically *forms* a recognizable move**, JX/Võ Lâm/Kiếm Thế-inspired, with near-white tight core, clean saturated crimson/ruby translucent body and small soft halo, short forceful localized contact and target mark. **No dark opaque anatomical fist, long streaming cloth, flying detached hand/orb, generic red ribbon or giant glow.** R5 `f595adec...` TECH PASS is **OWNER REWORK ORDERED** (not approved art). Original Art-First Production System V4 applies FULL: new first-party RGBA illustrated luminous key poses G2/G3 FIRST, then Godot G3.5 at 1×; no R5 shader-only recolor shortcut, no fake source frames. FIST14 `projectile_speed=0` means no projectile; correct the LAB's too-wide actor spacing without changing Combat V2. Preserve R5 and all old assets. Detailed G1/G2/G3 instructions and reference provenance: [FIST14 R6 Luminous Art Direction](docs/operations/FIST14_R6_LIGHT_ENERGY_ART_DIRECTION_20261118.md). Codex permitted as technical producer under V4, never source-art shortcut. No rig, GIF default, gameplay/PvE or merge.

---

## OWNER OVERRIDE 18/11/2026 — RETURN TO ORIGINAL VFX ART-FIRST V4 (HIGHEST CURRENT VFX AUTHORITY)

**The owner explicitly rejected FIST14 R4 Simple and ordered `quay trở về quy trình cũ`.** Restore [original Art-First V3 + Production System V4](docs/operations/TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md) and [Sprite Layer Pipeline](docs/operations/TMB_VFX_SPRITE_LAYER_PIPELINE_20261114.md) IN FULL. **Prior "JX simplified" numeric 2–4 pose targets, one old sprite + Godot effects, and "deliver ugly technical candidate" shortcuts are REVOKED.** Preserve study of JX/Kiếm Thế Mobile as visual reference, not as license to bypass first-party illustrated alpha master and **genuinely distinct authored key poses**. G0 contract → G1 licensed movement reference → G2 semantic silhouette/storyboard → **G3 high-quality original master + real changing frames; visual STOP before coding** → G3.5 native 1280×720 1× moving-contact → G3.6 brightness / G3.7 recognizability → G4/G5 motion only after art preflight → G7 technical exact-SHA → G8 separate owner approval/PvE HOLD.

FIST14 R4 `70cfd81c...` (TECH PASS) / `2e9b9d7b...` (handoff) **ART_SELF_FAIL and OWNER_REJECTED**, NOT production source, NOT accepted. Keep commits/assets archived, **do not delete/reset/force-push/merge**. Codex may remain technical implementer because owner authorized it, but **may not weaken V4 quality gates** or move a single rejected red bitmap as if that were new source art. Refer to [formal V4 reinstatement + R4 rejection](docs/operations/TMB_VFX_REINSTATE_ART_FIRST_V4_AND_FIST14_R4_REJECTION_20261118.md). Previous contradictory instructions below are historical and superseded wherever conflicting. No rig, no default GIF, no gameplay/SaveService/economy changes, no PvE integration and no merge.

---

## OWNER DECISION 2026-11-18 — CODEX PRIMARY VFX IMPLEMENTER (supersedes earlier no-Codex)

The owner explicitly ordered: **"thôi giao cho codex làm thôi"**. For new and authorized VFX technical work, **Codex is approved and becomes the intended primary producer**. No-Codex text elsewhere is superseded **only for scoped VFX production, Godot/GDScript/art asset staging and CI**. All no-rig, frozen approved/provisional sources, G3.5 human visual STOP, gameplay/PvE HOLD, no merge, and safe HEAD/branch write rules remain mandatory.

Start with [Codex simplified FIST14 pilot handoff](docs/operations/TMB_CODEX_VFX_SIMPLE_HANDOFF_20261118.md) rather than mass production. Do not turn each skill into new infrastructure or call technical CI beauty proof. Other POISON/FIST/TALISMAN ChatGPT production chats should **pause new school writes after reading this new owner instruction** and act only as reviewers while Codex is actively handling a scope; absence of a live Codex task means this document is a prepared task, not a running agent. Codex Cloud starts by an explicit user action in the Codex UI, it is NOT launched by committing this file. The assigned initial school scope is FIST14 isolated pilot only; others read-only until later authorization.

---

## OWNER VFX STYLE OVERRIDE — JX/KIẾM THẾ SIMPLIFIED (18/11/2026)

The owner explicitly prioritizes **simpler, more identifiable JX/Kiếm Thế-Mobile-like VFX** for upcoming work: ONE strong silhouette, ONE action, ONE clear impact, and status only if the canonical contract requires it. **Do not require 16–40 poses for routine skills**; suggest 2–4 poses for simple, 4–6 for characteristic, 6–12 only for justified ultimate/iconic content. A high-quality source image plus modest Godot trail/particles is preferred over dozens of procedurally changed frames. Do not overwrite owner-approved/provisional versions or weaken G3.5 native 1× and owner visual gates. Codex **could** help with GDScript/QA if the owner separately authorizes it; current no-Codex school rule remains in force and it does NOT auto-solve art. Read [Style V1](docs/operations/TMB_VFX_JX_SIMPLE_STYLE_V1_20261118.md) and [multi-chat coordination](docs/operations/TMB_VFX_MULTI_CHAT_COORDINATION_AND_RECOVERY_20261118.md).

---

## VFX NATIVE ART DIRECTION REPAIR — 2026-11-18 (ALL SCHOOL CHATS)

The coordinator inspected **genuine exact-SHA Godot native screenshots and videos** for POI18 R3.1 / FIST14 R3 / PAF05 R5F and found **semantic/source-material and 1× art failures despite technical CI PASS**. Before further source production, read the new [three-skill visual audit and official Godot 2D VFX guide](docs/operations/TMB_VFX_MULTI_CHAT_COORDINATION_AND_RECOVERY_20261118.md#9-2026-11-18-native-art-review--actual-godot-frames-not-just-ci). Preserve all approved/provisional art, stay within school-owned paths; owner feedback was a general objection to quality, NOT authorization to overwrite prior approved revisions. Do not fix ugly central sprites with extra CI, many duplicate poses, oversized glowing glyphs, generic line waves or proprietary JX imagery. Godot particle/animation/shader nodes are **supplements to first-party authored hero art**, not replacements. Current Art-First V4/G3.5 art STOP remains authoritative, not a new competing SOP.

---

## OWNER VFX RESPONSE OPTIONS & SCHOOL QA INTEGRITY — 2026-11-18

At the end of **every meaningful school VFX milestone** (POISON/FIST/TALISMAN), provide **3–4 owner-selectable next-step options**, with **A = one recommended action** grounded in the real last gate, explicitly state source permanence, exact-SHA CI, G3.5/3.6/3.7/G5, owner and PvE status. Do not silently advance to a different skill or imply CI PASS is art approval. Read [multi-chat coordination §8](docs/operations/TMB_VFX_MULTI_CHAT_COORDINATION_AND_RECOVERY_20261118.md) for the detailed rule and current POI18/FIST14/PAF05 blocking facts. This changes report/choice behavior only, not the original V4 production or write-scope permissions.

---

## VFX SHARED SKILL PACKET RUNNER — 2026-11-18 (COORDINATOR)

All POISON/FIST/TALISMAN VFX chats: read [shared V4 packet→Godot runner](docs/operations/TMB_VFX_SHARED_SKILL_RUNNER_V1_20261118.md) **before creating another per-skill workflow/QA harness**. Reuse `tools/qa/run_vfx_shared_packet.py` and `.github/workflows/vfx-shared-skill.yml` where skill V4 packet/assets/scene/focused test already exist; only build skill-specific RGBA source, contract and genuine extra tests. Shared command passed Godot 4.7.2 native G3.5 V4 evidence on exact SHA `3fe327ec858404d2965235556c9a609549f82b9f`, [Actions #44230153048](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44230153048). **DO NOT** call that individual technical test a skill-wide art approval or production PvE integration. Existing school workflows remain unchanged until school-specific generated-asset, G3.6/3.7 and semantic coverage parity is proven. Preserve first-party masters, no new Godot project per skill.

---

## VFX MULTI-CHAT COORDINATION / CHAT LIMIT HANDOFF — 2026-11-18

When running Poison / Fist / Talisman VFX production in parallel on Draft PR #72, **first read** [Multi-chat Coordinator & Recovery](docs/operations/TMB_VFX_MULTI_CHAT_COORDINATION_AND_RECOVERY_20261118.md), then the school's own `docs/handoffs/VFX_POISON_CURRENT.md`, `VFX_FIST_CURRENT.md` or `VFX_TALISMAN_CURRENT.md`. These handoffs are the durable state when a ChatGPT chat reaches context/message limits; they do **not** supersede this file or V4 SOP. Every chat must re-fetch live HEAD, follow one-writer-per-overlapping-path and update only its delegated school handoff. Coordinator owns shared presentation/Budget files. New shared design addenda: [A Status/Overlay](docs/design/TMB_VFX_STATUS_BUFF_OVERLAY_RULES_V1_20261118.md), [C Art Bible](docs/operations/TMB_VFX_ART_BIBLE_C_QUALITY_V1_20261118.md), [B/D/E LAB Pilot](docs/operations/TMB_VFX_B_D_E_PILOT_20261118.md). A/C design and B/D/E technical pilot are **not universal owner art approval or G8 PvE integration permission**.

---

## VFX R6 NEGATIVE-CASE GATE — 2026-11-17 (ALL SCHOOL CHATS)

**Read [FIST12 R6 failure postmortem](docs/operations/FIST12_R6_PROCESS_FAILURE_POSTMORTEM_20261117.md) before delivering any new VFX.** Poster/infographic source crops, threshold-keyed alpha cells from labeled artboards, still-montage previews, and offline MP4s are **not accepted** as authored VFX masters, native Godot evidence, or a technical PASS. Alpha>0/unique hash only checks file validity, never motion/art quality. Enforce existing G0–G8 and G3.5 hard STOP: only original isolated true-RGBA source + real Godot 4.7.2 1280×720 charge/peak/moving-contact, followed by actual native video, moving-target/1× art review, exact-SHA V4 packet. If Godot cannot run, explicitly report NOT_EXECUTED and STOP; never hand off an offline proof as the finished skill. FIST12 R6 local poster-crop candidate is REJECTED, R5 remains TECH_PASS/ART_FAIL; neither enters PvE. No rig, GIF by default, Codex, branch or merge.

---

## OWNER VFX NO-GIF OVERRIDE — 2026-11-16 (LATEST, HIGHEST PRIORITY)

**No GIF creation requirement. Do NOT generate GIFs, storyboard GIF previews or GIF exports during VFX production unless the owner explicitly asks for a GIF.** Direct process: canonical skill data → source-preserved original true-RGBA sprite layers → Godot 4.7.2 native 1280×720 charge/peak/moving-contact screenshots → short real Godot MP4 motion review and exact-SHA proof → manual owner art gate. Historical GIF-first experiments are REVOKED and are not a gate. No rig, no Codex, no merges, no gameplay modifications by default.

## VFX MANDATORY PRODUCTION SYSTEM V4 — 2026-11-16 (ALL VFX SCHOOL CHATS, HIGHEST VFX SOP PRIORITY)

**VFX V4 reusable technical gate (pilot 16/11/2026):** All new VFX school chats must also read [V4 packet onboarding](docs/operations/vfx_packets/README.md) and use [shared V4 validator](tools/qa/validate_vfx_v4_packet.py) with a **school-specific** skill packet, real Godot moving-target contract and preflight evidence. [HF02 workflow](.github/workflows/vfx-v4-hf02-preflight.yml) / [verified pilot](docs/operations/vfx_packets/HF02_V4_TECHNICAL_RESULT_20261116.md) are the first implementation example, not blanket CI coverage for 12 schools. A missing packet/3 images/manifest/Godot focused evidence fails technical QA; never auto-PASS art. The pilot explicitly preserves ART/OWNER PENDING and PvE HOLD.

Owner requires every chat/agent producing Tông Môn Bá Đạo VFX to apply the updated existing [Art-First SOP V3, Production System V4 addendum](docs/operations/TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md), the [repo Art Director skill](.agents/skills/tmb-vfx-art-director/SKILL.md), the [sprite-layer pipeline](docs/operations/TMB_VFX_SPRITE_LAYER_PIPELINE_20261114.md), the [mandatory skill packet template](docs/templates/VFX_SKILL_ART_FIRST_TEMPLATE.md), and the exact school catalogue/ledger before creating/revising one skill. **This is mandatory for Poison/Fist/Talisman and every other school, including new chats.** The user does NOT need to repeat the workflow. Older instructions recommending identical 8–12 animation frames, technical frame-hash checks as art evidence, fixed video length, or bulk recoloring do not supersede this rule.

Mandatory workflow: **G0 actual skill contract and event/visual timing matrix → G1 reference rights and motion → G2 distinct storyboard → G3 original full-size transparent sprite master + true key poses (NO RIG) → G3.5 three genuine Godot 1280×720 native 1× frames charge / peak / contact on MOVING monster; manual visual STOP gate → G4 event-aligned motion/anchor and multi-target tests → G5 full genuine video and >=12 timed inspections → G6 human art self-gate (>=4/5 on critical categories) → G7 exact-SHA technical evidence and owner gate → G8 only separate approval for live integration/performance**.

**Three clocks must never be conflated:** catalogue cast/cooldown/duration/projectile speed and actual runtime receipts; local VFX charge/release/contact/fade; QA/demo movie loop and pre-roll. Unknown hit receipt timing = RUNTIME_MAPPING_PENDING, never fabricate a gameplay hit. Persistent 4–6s shield/mark ≠ 4–6s cast animation. Choose pose count by movement/duration, NOT hash uniqueness or a universal frame quota. Approved hero art must be permanently traceable; do not rely on expiring CI artifacts. Art quality cannot be automatically declared PASS by GitHub Actions; compare to owner reference at gameplay scale and check dark/bright terrain, occlusion, saturation, motion and living targets. A three-frame screenshot gate cannot replace the eventual full-motion review.

**Mandatory handoff for each school chat:** latest HEAD, skill ID/contract, three-clock timing matrix with unknowns, reference and rights, source master/alpha/atlas, G3.5 PASS/FAIL/NOT_RUN evidence, moving-target and full-motion QA evidence, per-category art scores, exact-SHA technical result, owner approval vs pending/rework, separate PvE/physical device hold, source SHA and durable storage. A chat that has not performed a gate must state NOT_EXECUTED, not pretend success. One writer per overlapping school file; preserve owner-approved assets. No rig, no Codex by default, no new branch/merge, no Combat V2/SaveService/economy/AI/PvE/V6.3 edits without specific separate authorization.

---

## VFX OWNER ART INTERPRETATION RULE — 2026-11-14 (MANDATORY)
A skill name/description is creative inspiration, NOT an instruction to make the character perform literal actions it cannot animate. Never fake a kick/strike by translating IDLE sprites, rigging characters, duplicating pseudo-actors, or making bright vector circles as a substitute for authored VFX. The actual catalogue effect/shape/target limit/duration remain authoritative: e.g. FIST02 Phi Than Lien Cuoc is a single-target 4-second FIRE GUARD despite the word 'kicks'. Produce a beautiful original isolated sprite hero first, alpha flipbook, thoughtful layers, REAL Godot 1280x720 video and visual repair. Keep actor unchanged if no approved frame-by-frame action exists. OWNER_REJECTED R1-R3 FIST02 visual art; technical CI success does not make it approved. Never mislabel generated promotional images as screenshots or gameplay assets. Read FIST02 V4 art brief before reusing any version.

---

## VFX SPRITE-LAYER ART PIPELINE — owner order 2026-11-14 (MANDATORY)
All VFX school chats MUST read docs/operations/TMB_VFX_SPRITE_LAYER_PIPELINE_20261114.md plus docs/templates/VFX_SKILL_ART_FIRST_TEMPLATE.md. Fist chat also reads docs/operations/TMB_VFX_FIST_SCHOOL_PLAYBOOK_20261114.md. We learned the production method from the existing Loi Phu (talisman01): original master sprite -> pose-specific RGBA atlas -> independent light/impact layers -> real Godot movie -> visual corrections. **Copy the pipeline, not the talisman art**. Continue Fist work here; Talisman chat owns talisman01. Sprite material quality at native 1x and owner explicit approval are obligatory; code PASS alone is not art approval. No rig, Codex, new branches/merges, Combat V2 or SaveService changes.

---

## SPRITE-FIRST VFX OWNER DIRECTIVE — 2026-11-14

For ALL VFX/skill visual work, read [mandatory sprite-first VFX rules](docs/operations/TMB_VFX_SPRITE_FIRST_QUALITY_RULES_20261114.md) and the Art-First SOP V3. **Original multi-frame sprites/PNG flipbooks are expressly permitted and preferred when needed for beautiful motion.** Shader-only/code-only restrictions are rejected; a recolored static vector is not a completed skill. Separate school/chat paths, one original skill at a time, real Godot 1280×720 movie/art review before approval. No rig, Codex, new branch, merge or unauthorized PvE/Combat V2 edits.

---

## VFX ART-FIRST OWNER OVERRIDE — 2026-11-14 (MANDATORY FOR EVERY NEW CHAT)

**LATEST VFX FEEDBACK 14 NOV:** Xà Ảnh painted/4-pose layered serpent is the actual quality baseline. POI05 Tán Cổ R10 'tạm tạm' permits next skill but its electrical charge and rigid centipede are NOT approved as ideal art; backlog is light strands **gathering into a ring** + painted living creature (NO giant vector segmented re-skin). POI06 Vạn Cổ Phệ Giới light-ring experiment is at `docs/handoffs/VFX_CURRENT_ART_FIRST_NEXT_CHAT_20261114.md`. Test PASS is never owner art PASS. Do not copy Source VL copyrighted pixels.


For ANY Tông Môn Bá Đạo combat skill VFX, before generating art/code or handing off, automatically read [VFX ART-FIRST SOP V3](docs/operations/TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md), [VFX current handoff](docs/handoffs/VFX_CURRENT_ART_FIRST_NEXT_CHAT_20261114.md), [tmb-vfx-art-director skill](.agents/skills/tmb-vfx-art-director/SKILL.md), current PR #72 HEAD and actual skill catalogue. Owner REJECTED generic VFX-BATCH-01 R1–R4 as visually ugly. One ORIGINAL high-quality skill at a time; no static vector recolor mass production, no moving on until real Godot video inspected, corrected, and owner approves. Do NOT depend on chat memory or ask user to repeat SOP. Approved Human Poison labs locked; V6.3/PvE OFF; NO rig, Codex (unless explicitly authorized for VFX), new branch or merge. This supersedes older batch-artwork instructions in this file, but not other game-system authority.

---
# AGENTS.md — TÔNG MÔN BÁ ĐẠO

## CURRENT RELEASE-TRAIN OVERRIDE — 2026-11-04 (read first)

Owner direction: **ONE GAME → final `main`; only [PR #72](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72) is the active gameplay integration candidate.** Live gate/work owner: [Issue #56](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56); concise factual source: [canonical release register](docs/operations/TMB_ONE_GAME_RELEASE_TRAIN_CANONICAL_20261104.md); live status: [CURRENT_CHECKPOINT.md](CURRENT_CHECKPOINT.md) and [NEXT_CHAT_HANDOFF.md](NEXT_CHAT_HANDOFF.md).

**This paragraph supersedes dated instructions below on which PR/RC/launcher/QA lane to run, not their still-valid safety/architecture rules.** Do not resume work on old #52/#67/`one-game-v65` based on historical notes; PR #67 is #72's ancestor/base. Do not start a new gameplay branch or a duplicate roadmap. When instructions disagree, use the latest explicit user decision, Issue #56's release gates, live source SHA, then current architecture; do not interpret older QA/status as a current PASS.

- **R0 backup verified on 2026-11-04:** 196 working items + 94 saves, SHA256 manifest `EA753053E1DFBFD490E725C7FDD86B26FF565EA4BB10920805AA74571EDEF509`. Preserve these E: backups and user saves; no forced reset/clean/checkout. Do not merge `main` until R2–R4 release-critical QA PASS and main divergence reconciliation.
- **R1 canonical Godot headless PASS** at code SHA `b56b6fe8fa29ae663994a65098a56b60c3b42513`: 20/20 import+focused test exit 0, D7 Tam Căn(3)/Tứ Tính(4) UI fixed. Windows real GUI **NOT PLAYABLE PASS** (`ig11icd64.dll` OpenGL/Intel crash, PID problem), Android pending; `godot/project.godot` already uses `gl_compatibility`. **Continue R2→R3→R4→R5 automatically** under [Owner order](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72#issuecomment-6627064335), no stopping between gates. Do not report legacy `LOOT_PENDING`: P0 natural test has real reward/receipt on tested SHA, but actual same-save Windows GUI remains unproven.
- Old README/checkpoint/handoff contents were archived under `docs/archive/checkpoints/`. Do not follow the archived version's branch, phase, or commands.
- Character UI labels must respect Owner's **Tam Căn / Tứ Tính** correction. Check live canonical stat authority and UI before editing code; do not add a duplicate `Tâm Tính` gameplay stat from the label alone.
- The request to use **Codex to execute R0–R5 is explicitly authorized by Owner**; older text discouraging Codex is historical. Still enforce one writer per overlapping subsystem, exact-SHA QA, provenance and non-destructive workflow.
- PR backlog cleanup is **administrative**, not `main` merge: 61 → 18 open, 43 closed and branches/history retained (2026-11-04 snapshot); the 14 still-open gameplay PRs have a PORT/SUPERSEDED/DESIGN_HOLD matrix per R1; independent animation labs remain separate.

---

This file is the repository operating contract.

## VFX ART DIRECTOR OWNER LOCK — 2026-11-13 (skill; read for ALL combat FX work)

For ANY Tông Môn Bá Đạo VFX/skill visual/animation/shader task, especially Kiếm/kiếm khí/sét/rắn/Độc/Hỏa/Băng/Source JX/Source A, **read the repo-scoped skill [tmb-vfx-art-director](.agents/skills/tmb-vfx-art-director/SKILL.md) and its reference files before researching, coding or handing off to Codex**. This is the same skill also bundled into the private TMB Project Copilot ChatGPT plugin v0.2.0. Check live HEAD and the owner's newest visual comments; do not follow old VFX variants as if owner accepted them.

Owner visual standard: kiếm khí = *moving tapered luminous energy* (not a solid sword with steel body/hilt), phi kiếm thực thể is a different object class. Owner's liked sét and V9 light serpent are movement/lighting quality references. **A valid GDScript test or 60fps encoded Godot movie is NOT owner visual approval**. Do an art brief and verify actual 1280×720 Godot motion across >=8 phase frames; preserve `OWNER_VISUAL_PENDING` until owner explicitly accepts. Research-only requests do NOT authorize VFX code; no external JX/Source A commercial artwork shipped without verified rights. Live PvE still requires separate permission; combat targeting, damage/HP, SaveService and V6.3 authority remain outside art scope. Research authority: [VFX18 JX/Source A audit](docs/operations/VFX18_JX_SOURCEA_LIGHT_LANGUAGE_RESEARCH_20261113.md).


## 1. Authority order

Before changing code or gameplay design, read in this order:

1. current user instruction;
2. `docs/GAME_SYSTEM_ARCHITECTURE.md`;
3. `CURRENT_CHECKPOINT.md`;
4. `NEXT_CHAT_HANDOFF.md`;
5. the active phase spec;
6. subsystem master specs, especially `docs/DISCIPLE_MASTER_SCHEMA.md` for character changes;
7. current live code.

Do not ask the user to repeat information already available in these authorities.

If two documents conflict:
- newer explicit user decision wins;
- then `docs/GAME_SYSTEM_ARCHITECTURE.md`;
- then the more specific subsystem spec;
- implementation status comes only from `CURRENT_CHECKPOINT.md`.

Design specs must not be treated as progress logs.

---

## Owner Windows workspace directive — 2026-10-27

Canonical playable checkout MUST be E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao. Create new repo/worktrees/QA outputs on E under TongMonBaDaoWorkspace, never default C:\Users\Admin\Documents\Codex as a canonical game checkout. Windows Codex session metadata under C may be app-managed: do not delete while active. Before moving C/E paths inspect junction targets, git worktree list, active sessions, dirty/untracked, save and SHA provenance. Single owner launcher MO_GAME.cmd. See docs/operations/TMB_ONE_WORKSPACE_WINDOWS_20261027.md. This is NOT permission to silently merge main or mass delete PRs/branches/files.

## 2. Engine / branch / workflow

Repository:
`vuanhtuan161094-byte/TongMonBaDao`

Primary branch:
`main`

Engine:
Godot 4.7.2

Before edits:
- fetch live `main`;
- inspect current code;
- do not assume a previous chat's HEAD is still current.

Use GitHub connector for repository edits.
Do not use Codex or Work for repository coding unless the user explicitly changes that instruction.

---

## 3. Scoped CODE ownership rule — USER OVERRIDE 2026-10-15

**Supersedes the old repository-wide one-active-implementation-phase ban.** The owner prioritizes a playable Economy-A while preserving real evidence and locked gameplay.

1. **A CODE packet, not a historical phase, is the unit of implementation.** An OPEN QA debt or PAUSED unrelated phase does not automatically block a new explicitly authorized packet. A parallel DESIGN/QA investigation is allowed. There must be **one writer per overlapping file/subsystem**; concurrent CODE with shared `SimulationState`, `SectState`, `DiscipleState`, `BuildingSystem`, `WorkforceSystem`, `WarehouseSystem`, scheduler, save or scene integration needs one clearly named integration owner and no competing changes.
2. **Separate permission is still compulsory.** Before CODE, obtain the owner's specific authorization naming package, intended behavior, current `main` SHA, allowed paths, disallowed systems, rollback/legacy migration and focused/cumulative tests. A plan, an approved design, or this governance change alone never authorizes runtime, tests, workflows or balance edits.
3. **Preserve the exact statuses.** GP-02C1 is CODE DONE/official Linux focused+FULL PASS but overall QA OPEN because O6 standalone differential and physical Windows/Android debts are unresolved; DV2-03 remains PAUSED NOT CLOSED. Starting Economy-A cannot relabel either as CLOSED/PASS. Never call an old failure green or remove the test to make a dashboard green.
4. **Risk-based dependency check.** Keep a known-red test as a traced baseline debt if demonstrably independent. If Economy-A edits Mine/Forest/warehouse/job timing/currency/save, the affected O6/O5/GP-01/GP-02B1/GP-02C1/SAFE contracts must be reproduced or compared on real commits. A pre-existing failure in the path being changed **blocks integrated acceptance**, though it need not block development; repair requires a separate authorized allowlist or inclusion expressly authorized in the packet.
5. **Honest closure stays strict.** Close a packet only after explicit contract, complete implementation, official Godot 4.7.2 focused gate, cumulative regressions of affected and previously locked features (with any truly unrelated prior failures explicitly documented/owner-accepted, not called PASS), and `CURRENT_CHECKPOINT.md` / `NEXT_CHAT_HANDOFF.md` reflecting evidence, SHA, remaining debts and next permitted work.
6. **No duplicate authority.** One canonical Warehouse, one scheduler/time source, one disciple active job, canonical V2 state/save. Preserve P2 legacy without silently treating `wallet/treasury` as V2 `spirit_stones`. Avoid speculative UI, fake economy outputs or invented game balance.

**Current user decision:** Economy-A may be prepared and proposed for separate CODE authorization without waiting for GP-02C1 QA and DV2-03 administrative closure. The existing Injury 0/1/120-tick behavior remains production authority; 最强祖师-inspired graduated Injury/treatment is an independent DESIGN proposal, NOT a permission to change it. Economy-B/C, FE-02, DV2-04 and historical test repairs do not become authorized.

For any seeming conflict with historical notes, read the matching updated `docs/GAME_SYSTEM_ARCHITECTURE.md` section 4 and the top of `CURRENT_CHECKPOINT.md`.

---

## 4. Gate policy

Never call a phase PASS from static inspection alone.

During iteration:
- use FAST targeted gates;
- parse changed/adjacent scripts;
- run the active contract;
- use the smallest relevant smoke.

Run a FULL cumulative gate:
- when closing a phase;
- when a change crosses a locked subsystem;
- when regression evidence points into an older baseline.

Never weaken persistence, determinism, invariants or contract tests merely to make a gate pass.

GitHub Actions on official Godot 4.7.2 is valid runtime evidence.
Do not relabel CI evidence as Windows evidence.

For Windows:
- `tools/windows/sync/Sync-Main.cmd` is the stable sync entrypoint;
- for a gate use `tools/windows/sync/Sync-Main.cmd Verify-<gate>.cmd`;
- do not create phase-specific Sync launchers as the primary workflow.

---

## 5. Core architecture rule

Gameplay truth lives in simulation/runtime authority, not presentation.

Presentation may display state and issue real commands.
Presentation may not invent:
- resources;
- building levels;
- queues;
- production;
- upgrades;
- injury;
- ownership;
- cultivation;
- profession level;
- hunting rewards.

If backend authority does not exist yet, UI must not fake it.

Read:
`docs/GAME_SYSTEM_ARCHITECTURE.md`

---

## 6. Character authority

Read:
`docs/DISCIPLE_MASTER_SCHEMA.md`

Keep distinct:
- innate foundation;
- learned progression;
- Spiritual Root;
- Bloodline;
- Physique;
- traits/personality;
- equipment/loadout;
- living state;
- organization/social state.

Canonical six foundation dimensions:
- Tư Chất;
- Căn Cốt;
- Cơ Duyên;
- Thông Tuệ;
- Mị Lực;
- Tiềm Lực.

Do not replace them with a new parallel stat block.

---

## 7. Locked earlier baseline

Locked earlier runtime:
- P0–P2.12;
- P3.1;
- P3.2 map/camera/selection/real disciple tabs;
- P3.3 disciple operational flow;
- P3.4 building management;
- P3.5 living-sect cues;
- P3.6A runtime slice.

P3.6A final visual acceptance remains user-owned.
Do not reopen locked phases without real regression evidence.

---

## 8. P3.7 canonical direction

Parent:
`docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`

Children:
- `docs/P3_7_BUILDING_TREE_SPEC.md`
- `docs/P3_7_SPIRIT_FIELD_SPEC.md`
- `docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`
- `docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md`
- `docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md`
- `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`
- `docs/P3_7C1_FOUNDATION_DAN_TIEN_SPEC.md`

Locked high-level rules:
- target scale 1,000–3,000 disciples;
- player manages policy/groups/teams/infrastructure rather than thousands of individuals;
- hunting is primary outward progression;
- rear-base professions support hunting and economy;
- no permanent disciple deletion from lifespan expiry;
- lifespan expiry -> Ma/Hồn state; only expulsion removes from roster;
- no reward Loot Warehouse;
- no persistent Team Loot Bag for rewards;
- ordinary item/material hunting rewards -> main Sect Warehouse immediately;
- one canonical P3.7 stackable-resource warehouse;
- no warehouse capacity gameplay ceiling;
- resource IDs stay distinct;
- realm/tier + explicit resource quantity are canonical; there is no Phẩm Lực system;
- building instances cap at Lv.100;
- normal levels scale numbers; milestones open mechanics;
- construction/upgrades take real simulation time;
- movement speed, attack speed, work speed, cast time and cooldown are separate concepts.

---

## 9. P3.7 backend currently locked through C1

Backend foundation:
- P3.7A1 Building Authority + Mine;
- P3.7A2R Spirit Field;
- P3.7B1 Resource Registry + canonical Sect Warehouse;
- P3.7C1 open-point six-foundation authority + Dẫn Tiên recruitment.

Exact evidence belongs in `CURRENT_CHECKPOINT.md`, not here.

Do not reintroduce:
- permanent P3.7 `forge_materials` authority;
- permanent P3.7 `technique_materials` authority;
- secondary reward warehouse;
- warehouse-capacity gating.

---

## 10. Current phase source

Do not duplicate current-phase status in AGENTS.

Read:
- `CURRENT_CHECKPOINT.md`;
- `NEXT_CHAT_HANDOFF.md`.

If the checkpoint says no CODE packet is authorized, do not start a queued packet without a new explicit user instruction; historical QA OPEN and PAUSED statuses do not themselves bar a new disjoint authorization.


---

## 11. One-tap user continuation / prewritten next prompts (USER WORKFLOW RULE 2026-10-11)

The user explicitly prefers **tap-to-continue, not typing/planning the next prompt**. Treat this as a **durable project working rule** for all project chats. **Owner reaffirmation 2026-10-14:** end every Tông Môn Bá Đạo project-task reply with a clearly labeled, complete, copy-ready **recommended next-work prompt in Vietnamese** (not merely an abstract suggestion), including when QA is deferred or a phase is blocked. This is a communication rule, **not permission to start code or another phase**.

After **every project-task reply**:

1. Present **2–3 concise, context-specific next choices**, with the recommended/most logical next step first. Do **not** overwhelm with 5–10 choices or ask the user to write their own prompt.
2. Wherever the chat UI supports it, use actual **clickable options/actions** that submit a **complete ready-made Vietnamese next-turn instruction**. The user should be able to tap one option and automatically issue the precise next request. Do not create a decorative button with no action. Include proper repo, branch, scope, commit/CI/test obligations, exclusion of adjacent phases and Windows `PENDING USER` in any coding-authorization prompt.
3. If the current channel cannot render active options, provide numbered **copy-ready prompts** with minimal required user effort; never imply a noninteractive markdown label actually sends a command.
4. Mark **what was verified, what remains blocked, and what needs user approval** before any suggested next step. An option to perform code changes is a **request for authorization**, not permission until the user taps/sends it. Do not choose or execute a coding option on the user's behalf.
5. **Keep continuity:** after an authorized packet, update `CURRENT_CHECKPOINT.md` + `NEXT_CHAT_HANDOFF.md` (or authoritative existing spec) with concise verified evidence, exact next permitted packet, unresolved decisions, and any Windows-only tasks as **PENDING USER**. Reuse existing MD files; do not spawn redundant handoff plans.
6. **Minimize cognitive load:** recommend one clear default, allow alternatives such as audit/review or defer, preserve existing locked rules, and never make the user manually reconstruct technical prompts from memory.

This rule governs **conversation workflow**, not game AI/UI. Do not change gameplay, balance or phase scope merely because the user chooses a chat option.


## 12. Mobile orientation authority — LANDSCAPE LOCK (USER CORRECTION 2026-10-11)

**Tông Môn Bá Đạo is a LANDSCAPE / màn hình ngang mobile game.** The current Godot landscape base is **1280×720**, as in `godot/project.godot`, `docs/P3_6A_PLAYABLE_VERTICAL_SLICE_SPEC.md` and `docs/P3_REFERENCE_UI_AUDIT.md`; the opening production UI and controls must remain landscape and finger-friendly. Reference `Ta Là Tông Sư` / `最强祖师` for landscape sect-map/workforce and production-panel interaction, not for permission to replace canonical gameplay.

**Never redirect this project to portrait / màn hình dọc or 390×844 as the primary runtime**, and never conflate it with the separate `Tu Tiên Nhàn Dỗi` portrait art/runtime project. If an older note suggests portrait, this latest explicit user correction controls. 1280×720 is the **current design baseline**; final device aspect ratios/responsive layout remain to verify on an actual user device. Keep all UX acceptance at landscape. Changing primary orientation requires explicit new user decision.


---

## CURRENT GP-PLAY01 OWNER SCOPE — 2026-11-10 (read with release override)

The owner commissioned **GP-PLAY01 whole-game audit and stepwise playable gameplay closure** on the existing Draft PR #72. Authoritative plan: [GP-PLAY01 master audit/gates](docs/operations/GP_PLAY01_WHOLE_GAME_AUDIT_AND_IMPLEMENTATION_PLAN_20261110.md). Dedicated coordinator skill: [`.agents/skills/tmb-gameplay-closure/SKILL.md`](.agents/skills/tmb-gameplay-closure/SKILL.md). The current `CURRENT_CHECKPOINT.md` remains authoritative for actual status.

**Exclusive split:** this GP agent owns the non-combat loop (New Game/onboarding, workforce, Mine/Forest/Field, Warehouse, alchemy/medicine sources, Economy-A/LT2/W2/T2, crafting equipment and Sect management UI, regression/release coordination). **A separate chat owns skills, combat, enemy/Boss AI, DoT, VFX and fighting animation.** GP agent may READ combat receipts for economy/UI but cannot write combat files or shared combat state; get SHA/interface handoff from that writer instead. Only one writer per overlapping `p3_2_landscape_sect.gd`/State/Warehouse/Save/RuntimeOwner file; coordinate first. No new branch, merge, SaveService or fake resources.

**Mandatory execution:** fetch PR HEAD before each change; source-backed GP0 O9 Warehouse herb/Alchemy + GP02/Economy regression first; then GP1–GP8 staged real user loop and physical QA. Mark `CODE`, `FOCUSED_PASS`, `CUMULATIVE_PASS`, `GUI_HARNESS_PASS`, `PHYSICAL_PASS`, `HOLD` distinctly. Update checkpoint/handoff with exact SHA/log and 2–3 ready-to-click Vietnamese next tasks; don't claim all gameplay works from a Godot headless test.

---

## 13. TMB Agent Skills

Use `.agents/skills/tmb-project-director/SKILL.md` for complex TMB work, then one specialist for the active subtask:
- `tmb-balance-lab`: canonical progression, pill/material/economy balance analysis.
- `tmb-autoplay-ai`: safe hunt/recovery policy and One Active Job transitions.
- `tmb-godot-evidence`: official runtime, persistence/replay, regression and platform evidence.
- `tmb-asset-gate`: provenance, manifests, animation/import evidence.
- `tmb-ui-playtest`: real landscape UI journeys, readability and input evidence.

These skills support the authority order above; they never expand CODE/asset/merge permissions or replace canonical runtime. Latest explicit owner decisions and authoritative source win over stale skill examples. Do not auto-load all six or spawn agents merely because six skills exist. Source registry and discovery evidence: `docs/AI_AGENT_SKILLS_TMB_2026-10-22.md` and `docs/AI_AGENT_SKILLS_AUTO_DISCOVERY_CARE_QA_2026-10-22.md`. Main/PR/QA status remains in CURRENT_CHECKPOINT and NEXT_CHAT_HANDOFF.
