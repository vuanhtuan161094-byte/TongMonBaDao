> **QUYẾT ĐỊNH MỚI NHẤT 14/11/2026 — ART-FIRST, ONE SKILL AT A TIME:** Chủ dự án đã bác bỏ hình ảnh batch R4 và chốt quay lại **làm từng kỹ năng cho đẹp**, không nhân hàng loạt template/đổi màu. Mọi batch-production override bên dưới đã bị **superseded**, chỉ giữ hạ tầng mapping/QA. Quy trình đang có hiệu lực: [TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md](TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md). Ba Human Độc Tu đã chốt giữ nguyên; 201 cast master chưa duyệt cần art và video Godot thật từng skill; 216 passive/event chỉ có VFX theo event thật. Không auto-release, V6.3/PvE OFF. Dự báo có điều kiện và các cổng G0–G8 nằm trong SOP V3.

# TMB VFX PRODUCTION STANDARD — Source VL-quality, school by school
Version VFX-SOP-02 | 2026-11-14 | PR #72 Draft | Godot 4.7.2 GL Compatibility | 1280×720
## OWNER BATCH-PRODUCTION OVERRIDE — 2026-11-14 (supersedes old per-skill cadence ONLY)

After approving Cổ Vụ Mê Tung R3 and the first three Độc Tu Human LAB effects, the owner explicitly requested **produce all VFX in larger batches, not wait for individual review per skill**. Hence the earlier rule 'one school, one skill at a time' is replaced by **batch production + batch film QA**, while preservation of approved art, Source VL-quality and exact-skill gameplay contracts remain mandatory.

Batch implementation authority: `docs/operations/TMB_VFX_BULK_BATCH_01_20261114.md` and `res://labs/vfx_batch/manifest.json`. Source-mapped **2,196 IDs → 420 families** (204 cast visual masters + 216 passive/event-only families). **Three Human Poison LAB skills have owner visual approval**; their individual source scenes remain locked. The bulk preview catalogue covers 201 other cast-family **unreviewed WIP materials/motions**, not 201 approved artistic finals. Passive/innate skills NEVER fabricate a cast. Complete actual Godot movie and inspect visual samples on full 1280×720 before marketing or release status.

Batch cadence: map every source ID once; author distinct motif packs per school/branch; render same-clock 4-up reel for navigation AND at least one full-size exact-skill movie per branch/art archetype; group visual fixes and run exact-SHA Godot tests; record OWNER_VISUAL_PENDING per unapproved skill family, with no automatic PvE release. Strengthen unique silhouettes for standout effects before declaring them Source-VL-quality. User need not be asked to approve every intermediate before work on the next batch.

Unchanged locks: no skeletal rigs, no Codex delegation, only existing PR #72 branch, no merged or new branch, and do not change Combat V2 damage/status/target, SaveService, economy, feature gate V6.3 or enable live PvE without independent integration authorization.


## Owner-approved baseline, and its limits

On 2026-11-14 the owner approved the appearance of the real Godot LAB **Xà Ảnh Quấn Mạch**, using an original six-frame flight atlas plus four-position bind sprites rendered as back-coil / victim / front-coil layers. The owner explicitly said **the charge (tụ lực) is still not beautiful, but acceptable for now**. Preserve approved flight and binding. Charge polish remains a specifically recorded TODO, not a perfected master. NEVER return to the old Gaussian noodle POI-01 R1–R5.

Scene: godot/labs/combat_lab/poison02/xa_anh_source_vl_remake.tscn; canonical ID tmb.skill.poison.co_doc.active_02.human. Verified focused native Godot source SHA 0084800e7366847219f1ee3a45ddb27c22ba1b9d, [GitHub run #43544377773](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43544377773) PASS (1280×720 / 4.10sec / 246 fixed-timestep frames). Source/asset evidence at docs/operations/VFX_POI02_CLEAN_SHEET_SOURCE_VL_ART_BRIEF_20261113.md. The lab render is genuine; **live PvE presentation has NOT been integrated**. No skeletal rigs; do not alter Combat V2, real HP/target/hit/DoT, SaveService, economy, AI or V6.3 feature gates.

## Re-verified canonical skills inventory

Read 12 canonical combat JSONs and 12 VFX CSV ledgers at source HEAD 9f748c1e0595a64c741fe2b83c7148ec382bbd11:
- 12 schools × 183 **unique** skill IDs = **2,196 distinct IDs**; zero duplicate/missing Vietnamese names.
- Three branches per school = **36 specialization branches**. There is also one common/shared group per school, so school+branch labels count 48 **including shared**.
- 35 skill families per school = 420 families. Per school: **17 cast/mobility/basic/ultimate visual masters**, **18 passive/innate/event-only families**; globally **204 cast-family masters**, **216 passive/event families**.
- Per school 35 Human + 68 Immortal + 80 Divine variants = 183 IDs. Each new disciple plays the VFX of their *actual equipped/learned skill*, not an individual custom effect cloned for every disciple.
- 794 distinct declared VFX keys are **metadata**, NOT 794 implemented renderers. **183/183 Chú Tu keys** are text_pending, not finished sprites.
- All 12 canonical JSONs explicitly declare enabled=false (V6.3 OFF). A complete catalogue does NOT mean all 2,196 skills have playable, balanced, verified and visually accepted production effects.
- Prior V6.3 P1 implementation has 41 non-numeric A/B pair policies (82 IDs) officially tested at earlier SHA; 196 P2 equal-runtime pairs remain owner-design-review pending. Previous technical QA does not test the latest HEAD. All candidate content source/balance and physical GUI gates remain independent.
- Current owner-accepted VFX LAB covers **one Human cast family** (Xà Ảnh Quấn Mạch, charge pending). **203 other cast families remain without owner-approved LAB visual masters**; higher-tier variants of the same family are not auto-approved.

## Visual production queue

| Order | School | Three branches | Cast families | Passive/event |
|---:|---|---|---:|---:|
| 01 | Độc Tu | Độc Châm / Cổ Độc / Dược Độc | 17 | 18 |
| 02 | Phù Tu | Lôi Phù / Hỏa Phù / Phong Ấn Phù | 17 | 18 |
| 03 | Kiếm Tu | Ngự Kiếm / Sát Kiếm / Hộ Kiếm | 17 | 18 |
| 04 | Cung Tu | Liệp Ảnh / Linh Tiễn / Thiên Vũ | 17 | 18 |
| 05 | Quyền Tu | Bá Quyền / Kim Cang / Huyết Quyền | 17 | 18 |
| 06 | Đao Tu | Cuồng Đao / Trảm Phách Đao / Trấn Đao | 17 | 18 |
| 07 | Song Đao | Ảnh Nhẫn / Liên Hoàn / Huyết Nguyệt | 17 | 18 |
| 08 | Thương Tu | Phá Trận Thương / Long Thương / Hộ Quân Thương | 17 | 18 |
| 09 | Chưởng Tu | Liệt Dương Chưởng / Hàn Ngọc Chưởng / Hồi Phong Chưởng | 17 | 18 |
| 10 | Chú Tu | Trấn Hồn Chú / Phệ Linh Chú / Hộ Mệnh Chú | 17 | 18 |
| 11 | Trận Tu | Tụ Linh Trận / Phong Tỏa Trận / Sát Phạt Trận | 17 | 18 |
| 12 | Triệu Hồi | Kiếm Linh / Linh Thú / Khôi Lỗi Hộ Pháp | 17 | 18 |

Each school has two shared cast families (Basic/Mobility) and three branches with four actives plus one ultimate per branch: 2 + 3 × 5 = 17 master visuals. The remaining 18 are passive/innate families; only create presentation **when a real runtime event warrants one** (never fake another cast, damage tick, summon, proc or buff).

## Mandatory 10-stage production pipeline

| Gate | Required action | Observable exit condition |
|---|---|---|
| G0 skill truth | Pin exact skill ID, school, tier, effect, shape, target cap, rarity, event receipts and caster/target anchors | Source catalogue & Combat V2 authority verified; no invented gameplay |
| G1 reference research | Study **real animated frames** from JX1 / Source VL / praised V9 and/or properly licensed alternatives, note frame timing, silhouette, source rights | Provenance manifest; no assumption from a static screenshot |
| G2 brief | Draw five/six-phase storyboard: **charge**, release, travel/sustain, contact/wrap, dissolve; 8–12 keyframes plus alpha/occlusion plan | Source-VL-grade silhouette, rhythm and color hierarchy defined BEFORE coding |
| G3 sprite master | Author **original transparent sprite/flipbook** showing recognizable body/material, with head/body/tail if serpent; remove reference actor. Front/back coils are independent sprites for wrapping around any actual target | Alpha masks, atlas frames, frame/source hashes and native 1× legibility |
| G4 Godot composition | Actual LAB scene and strict layered occlusion **behind FX → actor → foreground FX**. Base uses alpha/mix; emissive rim uses bounded additive; optional shader/particles only if they improve image. Absolutely **NO RIG** | Godot 4.7.2 Compatibility scene renders under isolated test |
| G5 movie | Export actual Godot 1280×720 native MP4, at least 8 phase checkpoint frames, optional cropped same-clock A/B, GIF and easy-name ZIP fallback (prior user MP4 download failed once) | User can watch real animated skill, not a concept picture |
| G6 visual QA | Inspect charge/release/flight/near-contact/bind/fade at native 1×; inspect target occlusion, ghost actor, broken head-tail, detached glow, visual clutter; iterate **same skill** | Fix bad phase instead of recoloring or padding empty glow; preserve approved phases |
| G7 technical QA | Godot official version, strict import/parse/contract test at exact source SHA/run ID and evidence archive. Separate art judgement from technical PASS. Fixed 60fps export is NOT physical performance | No engine errors in scoped lab and evidence supports claims |
| G8 explicit art gate | Record human art approval **per skill and per phase**, including remaining charge-polish TODO | OWNER_VISUAL_APPROVED for LAB != LIVE_READY; no premature mass-production |
| G9 separate live/release | Only after separate authorized work, bind to real Combat V2 cast/release/confirmed-hit/status; run 1 target→3 positions→6v8→30 disciples/40 monsters; Windows and Android physical QA and rights clearance | No fake hits/HP, V6.3 only enabled by authorized release gate |

### Approved pilot, phase locks and deferred charge polish
- LOCK: original painted six-frame serpent flight; head/eyes/fangs/scales/tapered tail; authored 4-pose front and rear wrap; bite/impact staging and lab timing (0.54s charge end, 1.63s contact, 2.57s bind end, 3.45s dissolve end).
- ART TODO: improve **charge/tụ lực**: clearly gather venom at hand, legible buildup silhouette, restrained source-VL-quality lighting; do not replace accepted flight or alter gameplay times without a distinct event contract.
- POI-01 old R1–R5 is owner rejected; POI-02 authored sprite skill is the visual reference. Owner approves current presentation with a known charge defect; this does **not** approve commercial JX sprite redistribution or actual PvE integration.

## Engineering and management rules

- Every skill packet: ID, family, school/branch/tier, actual effect/shape/target cap, source rights, master art/atlas and hashes, native MP4 and 8+ PNG phases, exact Godot tested SHA/run, self-review, explicit owner decision, LIVE gate and scale gate.
- Reuse shared materials/pooled FX where possible; DO NOT use one identical animation recolored for unlike skills or four branches. Tier A/B/divine VFX differences must respect source descriptions and no fabricated gameplay receipts.
- One school, **one skill at a time**; all 17 cast masters get unique visual review and tier variants review. Event-only passives never receive an artificial cast effect by default.
- NO skeletal rigs. No new Git branch/merge or Codex handoff. Existing PR #72 Draft, one writer per subsystem; preserve production data and gameplay.
- Commercial JX1/Source VL originals may be STUDIED and rendered in closed R&D LABs. Their distribution rights are unverified; before shipping the game, use licensed footage/art or independently authored assets.
- A LAB skill can be approved visually while its connection to runtime Combat V2 is still not implemented; keep these fields separate.

Read-only CI inventory gate: python3 tools/qa/audit_vfx_school_catalogs.py. It checks 12 canonical JSONs versus 12 per-school VFX ledgers for identity, duplicates, tiers, 35 families, 17/18 visual split, 36 paths and unapproved source keys. Do not report this static audit as a full engine test.

## Executed inventory audit evidence

Official automated [GitHub Actions #43548362737](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43548362737) completed **SUCCESS** on exact source SHA `ef25b3de4e018aea04b0a9440ea17dda1a9055bc`. Read-only Python audit validated source JSON versus per-school CSV inventory and full ID/family/tier/branch assertions. Artifact `vfx-school-source-audit-ef25b3de4e018aea04b0a9440ea17dda1a9055bc` ID 14095690543. This is **STATIC CATALOGUE QA ONLY**, not a fresh Godot movie, live PvE, gameplay integration or art-performance acceptance.
